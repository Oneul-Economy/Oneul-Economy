"""RawArticle JSON -> News JSON (이슈 #3 형식).

사용:
  python rewrite.py samples/raw-article-1.json                    # .env의 LLM_PROVIDER (기본 gemini)
  python rewrite.py samples/raw-article-1.json --provider claude
  python rewrite.py samples/raw-article-1.json --provider openai --model gpt-5.6-terra
  python rewrite.py samples/raw-article-1.json --prompt prompts/rewrite_v2.md
"""
import argparse
import json
import os
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input", type=Path, help="RawArticle JSON 파일")
    ap.add_argument("--provider", choices=PROVIDERS, default=os.getenv("LLM_PROVIDER", "gemini"))
    ap.add_argument("--model", help="기본값: DEFAULT_MODELS")
    ap.add_argument("--prompt", type=Path, default=HERE / "prompts" / "rewrite_v1.md")
    args = ap.parse_args()

    raw = json.loads(args.input.read_text(encoding="utf-8"))
    # .format() 대신 replace: 프롬프트 안의 JSON 예시 중괄호와 충돌하지 않게
    prompt = (args.prompt.read_text(encoding="utf-8")
              .replace("{title}", raw["title"])
              .replace("{content}", raw["content"]))

    model = args.model or DEFAULT_MODELS[args.provider]
    news = build_news(raw, PROVIDERS[args.provider](prompt, model))

    # samples/raw-article-1.json + rewrite_v1.md -> results/news-1-claude-v1.json (모델·프롬프트끼리 비교하기 쉽게)
    version = args.prompt.stem.removeprefix("rewrite_")
    out = HERE / "results" / f"{args.input.stem.replace('raw-article', 'news')}-{args.provider}-{version}.json"
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(news, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{args.provider}/{model} -> {out}")


if __name__ == "__main__":
    main()
