"""News(첨삭 결과) -> 용어 퀴즈 (docs/data-format.md 3. Quiz).

사용:
  python quiz.py "results/*-v2.json" --provider claude
  python quiz.py results/20261105-005930-366-0001202773-claude-v2.json --no-verify

- terms 앞에서부터 최대 3개, 용어 하나당 4지선다 1문제
- 모델은 정답 1개와 오답 3개를 따로 주고, 보기 순서와 answer_index는 코드가 정함
- 자동 검사 + 2차 검증(모델이 정답을 모른 채 다시 풀어 봄)을 모두 통과한 기사만 저장
- 기사 하나가 실패해도 나머지는 계속 처리하고, 실패가 있으면 종료 코드 1
"""
import argparse
import glob
import json
import os
import random
import re
import sys
from pathlib import Path

from dotenv import load_dotenv
from pydantic import BaseModel

from check import INVEST

HERE = Path(__file__).parent
load_dotenv(HERE / ".env")

DEFAULT_MODELS = {
    "gemini": "gemini-3.6-flash",
    "claude": "claude-sonnet-5-5",
    "openai": "gpt-5.6-terra",
}
MAX_QUIZZES = 3
MAX_CORRECT_RATIO = 1.5  # 정답 길이 <= 오답 평균 길이 x 이 값


class GenQuiz(BaseModel):
    word: str
    question: str
    correct: str
    wrong: list[str]
    explanation: str


class GenQuizSet(BaseModel):
    quizzes: list[GenQuiz]


class Answer(BaseModel):
    answer_index: int
    multiple_correct: bool


class AnswerSet(BaseModel):
    answers: list[Answer]


# 모델 호출: rewrite.py와 같은 세 회사. 응답 형식(schema)만 인자로 받음
def call_gemini(prompt: str, model: str, schema):
    from google import genai

    res = genai.Client().models.generate_content(
        model=model,
        contents=prompt,
        config={"response_mime_type": "application/json", "response_schema": schema},
    )
    return res.parsed


def call_claude(prompt: str, model: str, schema):
    import anthropic

    res = anthropic.Anthropic().messages.parse(
        model=model,
        max_tokens=16000,
        messages=[{"role": "user", "content": prompt}],
        output_format=schema,
        extra_headers={"anthropic-beta": "server-side-fallback-2026-07-01"},
        extra_body={"fallbacks": "default"},
    )
    if res.stop_reason == "refusal":
        raise RuntimeError(f"Claude가 거절함: {res.stop_details}")
    return res.parsed_output


def call_openai(prompt: str, model: str, schema):
    from openai import OpenAI

    res = OpenAI().responses.parse(model=model, input=prompt, text_format=schema)
    return res.output_parsed


PROVIDERS = {"gemini": call_gemini, "claude": call_claude, "openai": call_openai}


def fill(template: str, **values: str) -> str:
    # .format() 대신 replace: 프롬프트 안의 JSON 예시 중괄호와 충돌하지 않게
    for k, v in values.items():
        template = template.replace("{" + k + "}", v)
    return template


def build_quiz_set(news: dict, gen: GenQuizSet) -> dict:
    """모델 결과에 id를 붙이고 보기를 섞음. 한 기사 안에서는 정답 위치가 겹치지 않게."""
    gen_quizzes = gen.quizzes[:MAX_QUIZZES]
    positions = random.Random(news["id"]).sample(range(4), len(gen_quizzes))
    quizzes = []
    for i, (q, pos) in enumerate(zip(gen_quizzes, positions), 1):
        choices = list(q.wrong)
        choices.insert(pos, q.correct)
        quizzes.append({
            "id": f"{news['id']}-q{i}",
            "word": q.word,
            "question": q.question,
            "choices": choices,
            "answer_index": pos,
            "explanation": q.explanation,
        })
    return {"news_id": news["id"], "quizzes": quizzes}


def validate(quiz_set: dict, news: dict) -> list[str]:
    """자동 검사. 실패 이유 목록 (비어 있으면 통과)."""
    words = [t["word"] for t in news["terms"]]
    errors = []
    if not quiz_set["quizzes"]:
        errors.append(f"{quiz_set['news_id']}: 퀴즈가 하나도 없음")
    quiz_words = [q["word"] for q in quiz_set["quizzes"]]
    if dup := sorted({w for w in quiz_words if quiz_words.count(w) > 1}):
        errors.append(f"{quiz_set['news_id']}: 같은 용어의 문제가 두 번 나옴 ({json.dumps(dup, ensure_ascii=False)})")
    for q in quiz_set["quizzes"]:
        qid, choices, ans = q["id"], q["choices"], q["answer_index"]

        def fail(reason):
            errors.append(f"{qid}: {reason}")

        if len(choices) != 4 or len(set(choices)) != 4:
            fail(f"보기가 서로 다른 4개가 아님 ({len(choices)}개, 중복 {len(choices) - len(set(choices))}개)")
        if not 0 <= ans < len(choices):
            fail(f"answer_index 범위 밖 ({ans})")
            continue
        if q["word"] not in words:
            fail(f"기사 terms에 없는 용어 ({json.dumps(q['word'], ensure_ascii=False)})")
        if any(q["word"] in c for c in choices):
            fail(f"보기에 정답 단어가 들어 있음 ({json.dumps(q['word'], ensure_ascii=False)})")
        wrong = [c for i, c in enumerate(choices) if i != ans]
        if wrong and len(choices[ans]) > MAX_CORRECT_RATIO * sum(map(len, wrong)) / len(wrong):
            fail(f"정답 보기만 너무 김 (정답 {len(choices[ans])}자, 오답 평균 {sum(map(len, wrong)) / len(wrong):.0f}자)")
        text = " ".join([q["question"], *choices, q["explanation"]])
        if found := re.findall(INVEST, text):
            fail(f"권유 표현 {json.dumps(found, ensure_ascii=False)}")
    return errors


def verify(quiz_set: dict, news: dict, template: str, provider: str, model: str) -> list[str]:
    """2차 검증: 정답을 숨기고 모델에게 다시 풀게 함. 다른 답을 고르거나 답이 둘 이상이면 실패."""
    questions = "\n\n".join(
        f"{i}. {q['question']}\n" + "\n".join(f"  {j}) {c}" for j, c in enumerate(q["choices"]))
        for i, q in enumerate(quiz_set["quizzes"], 1)
    )
    prompt = fill(template, title=news["title"], body="\n".join(news["body"]), questions=questions)
    answers = PROVIDERS[provider](prompt, model, AnswerSet).answers
    if len(answers) != len(quiz_set["quizzes"]):
        return [f"{quiz_set['news_id']}: 2차 검증 답 개수가 다름 ({len(answers)}/{len(quiz_set['quizzes'])})"]
    errors = []
    for q, a in zip(quiz_set["quizzes"], answers):
        if a.multiple_correct:
            errors.append(f"{q['id']}: 2차 검증에서 정답이 둘 이상이라고 함")
        elif a.answer_index != q["answer_index"]:
            errors.append(f"{q['id']}: 2차 검증에서 다른 답을 고름 (정답 {q['answer_index']}, 고른 답 {a.answer_index})")
    return errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inputs", nargs="+", help="News JSON 파일 (results/*-v2.json)")
    ap.add_argument("--provider", choices=PROVIDERS, default=os.getenv("LLM_PROVIDER", "gemini"))
    ap.add_argument("--model", help="기본값: DEFAULT_MODELS")
    ap.add_argument("--prompt", type=Path, default=HERE / "prompts" / "quiz_v1.md")
    ap.add_argument("--verify-prompt", type=Path, default=HERE / "prompts" / "quiz_verify_v1.md")
    ap.add_argument("--no-verify", action="store_true", help="2차 검증 끄기 (호출 수 절반)")
    args = ap.parse_args()

    template = args.prompt.read_text(encoding="utf-8")
    verify_template = args.verify_prompt.read_text(encoding="utf-8")
    model = args.model or DEFAULT_MODELS[args.provider]
    version = args.prompt.stem.removeprefix("quiz_")
    out_dir = HERE / "results" / "quiz"  # results/*-v2.json 패턴에 섞이지 않게 하위 폴더
    out_dir.mkdir(parents=True, exist_ok=True)

    failed = []
    # Windows처럼 셸이 *를 안 펼쳐도 동작하게 glob
    for path in [Path(p) for arg in args.inputs for p in sorted(glob.glob(arg)) or [arg]]:
        try:
            news = json.loads(path.read_text(encoding="utf-8"))
            terms = news["terms"][:MAX_QUIZZES]
            prompt = fill(
                template,
                title=news["title"],
                body="\n".join(news["body"]),
                terms="\n".join(f"- {t['word']}: {t['meaning']}" for t in terms),
            )
            quiz_set = build_quiz_set(news, PROVIDERS[args.provider](prompt, model, GenQuizSet))
            errors = validate(quiz_set, news)
            if not errors and not args.no_verify:
                errors = verify(quiz_set, news, verify_template, args.provider, model)
        except Exception as e:  # API 오류, 거절, 깨진 파일 등: 이 기사만 실패로 두고 계속
            errors = [f"{path.name}: {type(e).__name__}: {e}"]
        if errors:  # 실패한 기사는 저장하지 않음
            failed += errors
            print(f"실패 {path.name}", file=sys.stderr)
            continue
        out = out_dir / f"{news['id']}-quiz-{args.provider}-{version}.json"
        out.write_text(json.dumps(quiz_set, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"{args.provider}/{model} -> quiz/{out.name} (정답 위치 {[q['answer_index'] for q in quiz_set['quizzes']]})")

    if failed:
        print(f"\n퀴즈 실패 {len(failed)}개", file=sys.stderr)
        print("\n".join(f"- {e}" for e in failed), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
