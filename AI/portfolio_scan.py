"""증권 앱 보유 종목 캡처 -> Holdings JSON (#43 PUT /users/{login_id}/holdings 요청 형식).

사용:
  python portfolio_scan.py 캡처.png --provider claude            # 결과를 화면에 출력
  python portfolio_scan.py 캡처.png -o holdings.json              # 파일로 저장
  python portfolio_scan.py samples/portfolio/kr-basic.png --expect samples/portfolio/kr-basic.expected.json
                                                                  # 정답과 비교, 다르면 종료 코드 1

서버에서 쓸 때 (#46의 POST /portfolio/scan):
  from portfolio_scan import scan
  holdings = scan(image_bytes, "image/png", provider="claude")   # {"holdings": [...]}

- 화면에서 못 읽은 값은 추측하지 않고 null (#43 규칙)
- 결과는 #43 규칙(이름 1~100자, 종목코드 20자 이하, 숫자 0 이상, 통화 대문자 3글자, 최대 200개)으로 검사.
  규칙에 안 맞으면 ScanError, CLI는 종료 코드 1
"""
import argparse
import base64
import json
import mimetypes
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from pydantic import BaseModel, Field, ValidationError

HERE = Path(__file__).parent
load_dotenv(HERE / ".env")

DEFAULT_MODELS = {
    "gemini": "gemini-3.6-flash",
    "claude": "claude-sonnet-5-5",
    "openai": "gpt-5.6-terra",
}
PROMPT = HERE / "prompts" / "portfolio_scan_v1.md"
MEDIA_TYPES = {"image/png", "image/jpeg", "image/webp", "image/gif"}


# 모델 응답 형식: 느슨하게 (구조화 출력이 모든 JSON Schema 제약을 지원하지는 않음)
class ScannedHolding(BaseModel):
    stock_name: str
    stock_code: str | None
    quantity: float | None
    avg_price: float | None
    market_value: float | None
    currency: str


class ScannedHoldings(BaseModel):
    holdings: list[ScannedHolding]


# 서버로 보내기 전 검사: #43 HoldingIn과 같은 규칙
class HoldingIn(BaseModel):
    stock_name: str = Field(min_length=1, max_length=100)
    stock_code: str | None = Field(default=None, max_length=20)
    quantity: float | None = Field(default=None, ge=0)
    avg_price: float | None = Field(default=None, ge=0)
    market_value: float | None = Field(default=None, ge=0)
    currency: str = Field(default="KRW", pattern=r"^[A-Z]{3}$")


class HoldingsIn(BaseModel):
    holdings: list[HoldingIn] = Field(max_length=200)


class ScanError(Exception):
    pass


def call_claude(image: bytes, media_type: str, prompt: str, model: str) -> ScannedHoldings:
    import anthropic

    res = anthropic.Anthropic().messages.parse(
        model=model,
        max_tokens=16000,
        messages=[{
            "role": "user",
            "content": [
                {"type": "image", "source": {
                    "type": "base64", "media_type": media_type,
                    "data": base64.standard_b64encode(image).decode("utf-8"),
                }},
                {"type": "text", "text": prompt},
            ],
        }],
        output_format=ScannedHoldings,
        extra_headers={"anthropic-beta": "server-side-fallback-2026-07-01"},
        extra_body={"fallbacks": "default"},
    )
    if res.stop_reason == "refusal":
        raise ScanError(f"Claude가 거절함: {res.stop_details}")
    return res.parsed_output


def call_gemini(image: bytes, media_type: str, prompt: str, model: str) -> ScannedHoldings:
    from google import genai
    from google.genai import types

    res = genai.Client().models.generate_content(
        model=model,
        contents=[types.Part.from_bytes(data=image, mime_type=media_type), prompt],
        config={"response_mime_type": "application/json", "response_schema": ScannedHoldings},
    )
    return res.parsed


def call_openai(image: bytes, media_type: str, prompt: str, model: str) -> ScannedHoldings:
    from openai import OpenAI

    data_url = f"data:{media_type};base64,{base64.standard_b64encode(image).decode('utf-8')}"
    res = OpenAI().responses.parse(
        model=model,
        input=[{"role": "user", "content": [
            {"type": "input_image", "image_url": data_url, "detail": "high"},
            {"type": "input_text", "text": prompt},
        ]}],
        text_format=ScannedHoldings,
    )
    return res.output_parsed


PROVIDERS = {"gemini": call_gemini, "claude": call_claude, "openai": call_openai}


def normalize(scanned: ScannedHoldings) -> dict:
    """작은 차이는 코드가 맞추고(통화 대문자, 빈 코드 -> null), #43 규칙으로 검사."""
    rows = []
    for h in scanned.holdings:
        row = h.model_dump()
        row["stock_name"] = row["stock_name"].strip()
        row["stock_code"] = (row["stock_code"] or "").strip() or None
        row["currency"] = (row["currency"] or "KRW").strip().upper()
        rows.append(row)
    try:
        return HoldingsIn.model_validate({"holdings": rows}).model_dump()
    except ValidationError as e:
        raise ScanError(f"#43 규칙에 안 맞음: {e}") from e


def scan(image: bytes, media_type: str, provider: str = "claude", model: str | None = None) -> dict:
    if media_type not in MEDIA_TYPES:
        raise ScanError(f"지원하지 않는 이미지 형식: {media_type} (png, jpeg, webp, gif만)")
    prompt = PROMPT.read_text(encoding="utf-8")
    scanned = PROVIDERS[provider](image, media_type, prompt, model or DEFAULT_MODELS[provider])
    return normalize(scanned)


def compare(got: dict, expected: dict) -> int:
    """정답과 칸 단위로 비교. 숫자는 float로 맞춰 비교 (3 == 3.0)."""
    want = HoldingsIn.model_validate(expected).model_dump()["holdings"]
    rows = got["holdings"]
    diffs = [f"종목 수: 결과 {len(rows)}개, 정답 {len(want)}개"] if len(rows) != len(want) else []
    for i, (g, w) in enumerate(zip(rows, want), 1):
        diffs += [f"{i}번 {w['stock_name']} {k}: 결과 {g[k]!r}, 정답 {w[k]!r}" for k in w if g[k] != w[k]]
    print(f"{len(want)}개 종목 중 다른 칸 {len(diffs)}개" + "".join(f"\n- {d}" for d in diffs))
    return 1 if diffs else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image", type=Path, help="보유 종목 화면 캡처 (png, jpg, webp, gif)")
    ap.add_argument("--provider", choices=PROVIDERS, default=os.getenv("LLM_PROVIDER", "gemini"))
    ap.add_argument("--model", help="기본값: DEFAULT_MODELS")
    ap.add_argument("-o", "--output", type=Path, help="저장할 파일 (없으면 화면에 출력)")
    ap.add_argument("--expect", type=Path, help="정답 JSON. 결과와 비교해서 다르면 종료 코드 1")
    args = ap.parse_args()

    media_type = mimetypes.guess_type(args.image.name)[0] or ""
    try:
        holdings = scan(args.image.read_bytes(), media_type, args.provider, args.model)
    except ScanError as e:
        print(f"실패: {e}", file=sys.stderr)
        sys.exit(1)
    if args.expect:
        sys.exit(compare(holdings, json.loads(args.expect.read_text(encoding="utf-8"))))
    text = json.dumps(holdings, ensure_ascii=False, indent=2)
    if args.output:
        args.output.write_text(text, encoding="utf-8")
        print(f"{len(holdings['holdings'])}개 종목 -> {args.output}")
    else:
        print(text)


if __name__ == "__main__":
    main()
