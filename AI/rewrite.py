"""RawArticle JSON -> News JSON (docs/data-format.md 형식).

입력 파일은 기사 하나(객체)든 크롤러 결과(배열)든 모두 받음. 결과는 기사 1건 = 파일 1개.

사용:
  python rewrite.py ../Backend/pipeline/output/raw-article.json   # 크롤러 결과 그대로
  python rewrite.py samples/*.json --provider claude
  python rewrite.py samples/raw-article-1.json --provider openai --model gpt-5.6-terra
  python rewrite.py samples/raw-article-1.json --prompt prompts/rewrite_v1.md

기사 하나가 실패해도 나머지는 계속 처리하고, 실패가 있으면 종료 코드 1.
"""
import argparse
import glob
import json
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from pydantic import BaseModel

HERE = Path(__file__).parent
load_dotenv(HERE / ".env")

# 모델 이름은 --model 로 바꿀 수 있음
DEFAULT_MODELS = {
    "gemini": "gemini-3.6-flash",
    "claude": "claude-sonnet-5-5",
    "openai": "gpt-5.6-terra",
}


class Term(BaseModel):
    word: str
    meaning: str


class Rewrite(BaseModel):
    """AI가 채우는 부분만. 나머지 필드는 원문에서 코드로 채움."""
    title: str
    summary: str
    body: list[str]
    terms: list[Term]


def call_gemini(prompt: str, model: str) -> Rewrite:
    from google import genai  # GEMINI_API_KEY 사용

    res = genai.Client().models.generate_content(
        model=model,
        contents=prompt,
        config={"response_mime_type": "application/json", "response_schema": Rewrite},
    )
    return res.parsed


def call_claude(prompt: str, model: str) -> Rewrite:
    import anthropic  # ANTHROPIC_API_KEY 사용

    res = anthropic.Anthropic().messages.parse(
        model=model,
        max_tokens=16000,
        messages=[{"role": "user", "content": prompt}],
        output_format=Rewrite,
        # 안전 필터가 거절하면 서버가 다른 모델로 자동 재시도
        extra_headers={"anthropic-beta": "server-side-fallback-2026-07-01"},
        extra_body={"fallbacks": "default"},
    )
    if res.stop_reason == "refusal":
        raise RuntimeError(f"Claude가 거절함: {res.stop_details}")
    return res.parsed_output


def call_openai(prompt: str, model: str) -> Rewrite:
    from openai import OpenAI  # OPENAI_API_KEY 사용

    res = OpenAI().responses.parse(model=model, input=prompt, text_format=Rewrite)
    return res.output_parsed


PROVIDERS = {"gemini": call_gemini, "claude": call_claude, "openai": call_openai}


def load_articles(paths: list[str]) -> list[dict]:
    """파일마다 객체면 [객체], 배열이면 배열 그대로. Windows처럼 셸이 *를 안 펼쳐도 동작하게 glob."""
    articles = []
    for pattern in paths:
        for p in sorted(glob.glob(pattern)) or [pattern]:
            data = json.loads(Path(p).read_text(encoding="utf-8"))
            articles += data if isinstance(data, list) else [data]
    return articles


def build_news(raw: dict, ai: Rewrite) -> dict:
    return {
        "id": raw["id"],
        "stock_name": raw["stock_name"],
        "title": ai.title,
        "summary": ai.summary,
        "read_minutes": max(1, round(len("".join(ai.body)) / 500)),
        "body": ai.body,
        "terms": [t.model_dump() for t in ai.terms],
        "source": {"press": raw["press"], "url": raw["url"], "published_at": raw["published_at"]},
    }


def rewrite_one(raw: dict, template: str, provider: str, model: str) -> dict:
    # .format() 대신 replace: 프롬프트 안의 JSON 예시 중괄호와 충돌하지 않게
    prompt = template.replace("{title}", raw["title"]).replace("{content}", raw["content"])
    return build_news(raw, PROVIDERS[provider](prompt, model))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inputs", nargs="+", help="RawArticle JSON 파일 (객체 또는 배열)")
    ap.add_argument("--provider", choices=PROVIDERS, default=os.getenv("LLM_PROVIDER", "gemini"))
    ap.add_argument("--model", help="기본값: DEFAULT_MODELS")
    ap.add_argument("--prompt", type=Path, default=HERE / "prompts" / "rewrite_v2.md")
    args = ap.parse_args()

    template = args.prompt.read_text(encoding="utf-8")
    model = args.model or DEFAULT_MODELS[args.provider]
    version = args.prompt.stem.removeprefix("rewrite_")
    out_dir = HERE / "results"
    out_dir.mkdir(exist_ok=True)

    failed = []
    for i, raw in enumerate(load_articles(args.inputs)):
        article_id = raw.get("id", f"(id 없음 #{i + 1})")
        try:
            news = rewrite_one(raw, template, args.provider, model)
        except Exception as e:  # API 오류, 거절, 필드 누락 등: 이 기사만 실패로 두고 계속
            failed.append((article_id, f"{type(e).__name__}: {e}"))
            print(f"실패 {article_id}: {failed[-1][1]}", file=sys.stderr)
            continue
        # 파일 이름은 기사 id 기준: 배열 하나에서 여러 결과가 나와도 서로 덮어쓰지 않음
        out = out_dir / f"{article_id}-{args.provider}-{version}.json"
        out.write_text(json.dumps(news, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"{args.provider}/{model} -> {out.name}")

    if failed:
        print(f"\n실패 {len(failed)}개", file=sys.stderr)
        for article_id, reason in failed:
            print(f"- {article_id}: {reason}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
