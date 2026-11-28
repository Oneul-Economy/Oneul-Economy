"""News(첨삭 결과) -> 기사 내용 OX 퀴즈 (docs/data-format.md 4. OxQuiz).

사용:
  python ox_quiz.py "results/*-v2.json" --provider claude
  python ox_quiz.py results/20261105-005930-366-0001202773-claude-v2.json --no-verify

- 기사당 OX 문제 최대 3개, O와 X가 둘 다 있어야 함
- 자동 검사 + 2차 검증(모델이 정답을 모른 채 다시 풀어 봄)을 모두 통과한 기사만 저장
- 결과는 results/ox/ (results/quiz/*-v1.json 을 읽는 load_quiz에 섞이지 않게 별도 폴더)
- 모델 호출은 quiz.py 것을 그대로 씀. 실패가 있으면 종료 코드 1
"""
import argparse
import glob
import json
import os
import random
import re
import sys
from pathlib import Path

from pydantic import BaseModel

from check import INVEST
from quiz import DEFAULT_MODELS, PROVIDERS, fill

HERE = Path(__file__).parent
MAX_QUIZZES = 3


class GenOx(BaseModel):
    question: str
    answer: bool
    hint: str
    explanation: str
    evidence: str


class GenOxSet(BaseModel):
    quizzes: list[GenOx]


class OxAnswer(BaseModel):
    answer: bool
    unclear: bool


class OxAnswerSet(BaseModel):
    answers: list[OxAnswer]


def build_ox_set(news: dict, gen: GenOxSet) -> dict:
    """문제 순서는 코드가 섞음. 모델은 O, X를 늘 같은 순서로 내는 경향이 있음 (예: 매번 OXO)."""
    quizzes = gen.quizzes[:MAX_QUIZZES]
    random.Random(news["id"]).shuffle(quizzes)
    return {
        "news_id": news["id"],
        "quizzes": [{"id": f"{news['id']}-ox{i}", **q.model_dump()} for i, q in enumerate(quizzes, 1)],
    }


def validate(ox_set: dict, news: dict) -> list[str]:
    """자동 검사. 실패 이유 목록 (비어 있으면 통과)."""
    body = "\n".join(news["body"])
    quizzes = ox_set["quizzes"]
    errors = []
    answers = {q["answer"] for q in quizzes}
    if len(quizzes) < 2:
        errors.append(f"{ox_set['news_id']}: 문제가 2개 미만 ({len(quizzes)}개)")
    elif answers != {True, False}:
        errors.append(f"{ox_set['news_id']}: O와 X가 둘 다 있지 않음 (전부 {'O' if True in answers else 'X'})")
    for q in quizzes:
        def fail(reason):
            errors.append(f"{q['id']}: {reason}")

        if not q["evidence"] or q["evidence"] not in body:
            fail(f"근거가 본문에 글자 그대로 없음 ({json.dumps(q['evidence'][:40], ensure_ascii=False)})")
        if q["question"].rstrip().endswith("?"):
            fail("문제가 질문형 (평서문이어야 O/X로 답할 수 있음)")
        text = " ".join([q["question"], q["hint"], q["explanation"]])
        if found := re.findall(INVEST, text):
            fail(f"권유 표현 {json.dumps(found, ensure_ascii=False)}")
    return errors


def verify(ox_set: dict, news: dict, template: str, provider: str, model: str) -> list[str]:
    """2차 검증: 정답을 숨기고 기사만 주고 다시 풀게 함. 답이 다르거나 판단할 수 없다고 하면 실패."""
    questions = "\n".join(f"{i}. {q['question']}" for i, q in enumerate(ox_set["quizzes"], 1))
    prompt = fill(template, title=news["title"], body="\n".join(news["body"]), questions=questions)
    answers = PROVIDERS[provider](prompt, model, OxAnswerSet).answers
    if len(answers) != len(ox_set["quizzes"]):
        return [f"{ox_set['news_id']}: 2차 검증 답 개수가 다름 ({len(answers)}/{len(ox_set['quizzes'])})"]
    errors = []
    for q, a in zip(ox_set["quizzes"], answers):
        if a.unclear:
            errors.append(f"{q['id']}: 2차 검증에서 기사만으로 판단할 수 없다고 함")
        elif a.answer != q["answer"]:
            errors.append(f"{q['id']}: 2차 검증에서 다른 답을 고름 (정답 {'O' if q['answer'] else 'X'})")
    return errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inputs", nargs="+", help="News JSON 파일 (results/*-v2.json)")
    ap.add_argument("--provider", choices=PROVIDERS, default=os.getenv("LLM_PROVIDER", "gemini"))
    ap.add_argument("--model", help="기본값: quiz.py의 DEFAULT_MODELS")
    ap.add_argument("--prompt", type=Path, default=HERE / "prompts" / "ox_v1.md")
    ap.add_argument("--verify-prompt", type=Path, default=HERE / "prompts" / "ox_verify_v1.md")
    ap.add_argument("--no-verify", action="store_true", help="2차 검증 끄기 (호출 수 절반)")
    ap.add_argument("--force", action="store_true", help="결과 파일이 있어도 다시 만들기")
    args = ap.parse_args()

    template = args.prompt.read_text(encoding="utf-8")
    verify_template = args.verify_prompt.read_text(encoding="utf-8")
    model = args.model or DEFAULT_MODELS[args.provider]
    version = args.prompt.stem.removeprefix("ox_")
    out_dir = HERE / "results" / "ox"
    out_dir.mkdir(parents=True, exist_ok=True)

    failed = []
    done = skipped = bad = 0
    # Windows처럼 셸이 *를 안 펼쳐도 동작하게 glob
    for path in [Path(p) for arg in args.inputs for p in sorted(glob.glob(arg)) or [arg]]:
        try:
            news = json.loads(path.read_text(encoding="utf-8"))
            out = out_dir / f"{news['id']}-ox-{args.provider}-{version}.json"
            # 이미 있고 지금 기사로 검사해도 통과하면 AI를 부르지 않음.
            # 기사를 --force로 다시 첨삭해 근거 문장이 본문에서 사라졌으면 검사에 걸려 다시 만듦
            if out.exists() and not args.force:
                if not validate(json.loads(out.read_text(encoding="utf-8")), news):
                    print(f"건너뜀 {news['id']} (이미 있음)")
                    skipped += 1
                    continue
                print(f"다시 만듦 {news['id']} (기사가 바뀌어 예전 OX 퀴즈가 안 맞음)")
            prompt = fill(template, title=news["title"], body="\n".join(news["body"]))
            ox_set = build_ox_set(news, PROVIDERS[args.provider](prompt, model, GenOxSet))
            errors = validate(ox_set, news)
            if not errors and not args.no_verify:
                errors = verify(ox_set, news, verify_template, args.provider, model)
        except Exception as e:  # API 오류, 거절, 깨진 파일 등: 이 기사만 실패로 두고 계속
            errors = [f"{path.name}: {type(e).__name__}: {e}"]
        if errors:  # 실패한 기사는 저장하지 않음
            failed += errors
            bad += 1
            print(f"실패 {path.name}", file=sys.stderr)
            continue
        out.write_text(json.dumps(ox_set, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"{args.provider}/{model} -> ox/{out.name} (답 {''.join('O' if q['answer'] else 'X' for q in ox_set['quizzes'])})")
        done += 1

    print(f"\nOX 퀴즈 {done}개, 건너뜀 {skipped}개, 실패 {bad}개")
    if failed:
        print("\n".join(f"- {e}" for e in failed), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
