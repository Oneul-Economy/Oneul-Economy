"""포트폴리오 캡처 인식 API (#46 POST /portfolio/scan).

증권 앱 보유 종목 캡처를 받아 AI/portfolio_scan.py의 scan()으로 읽고
{"holdings": [...]}를 돌려준다.

- 캡처 원본은 저장하지 않음: 업로드를 메모리에서 바로 scan()에 넘기고 버린다 (디스크·DB·로그 X)
- 오류 메시지에 수량·금액 같은 값은 넣지 않음
"""
import os
import sys
from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile

AI_DIR = Path(__file__).resolve().parents[2] / "AI"
if str(AI_DIR) not in sys.path:
    sys.path.append(str(AI_DIR))

import portfolio_scan  # noqa: E402  (AI 폴더를 경로에 넣은 뒤에 불러옴)

router = APIRouter()

MAX_BYTES = 10 * 1024 * 1024  # 10MB


def run_scan(image: bytes, media_type: str) -> dict:
    """AI 호출. 테스트에서는 이 함수를 가짜로 바꿔 끼운다"""
    provider = os.getenv("LLM_PROVIDER", "claude")
    return portfolio_scan.scan(image, media_type, provider=provider)


@router.post("/portfolio/scan")
async def scan_portfolio(image: UploadFile = File(...)):
    media_type = (image.content_type or "").lower()
    if media_type == "image/jpg":
        media_type = "image/jpeg"
    if media_type not in portfolio_scan.MEDIA_TYPES:
        raise HTTPException(status_code=415, detail="png, jpeg, webp, gif 이미지만 올릴 수 있어요")

    data = await image.read(MAX_BYTES + 1)
    if len(data) > MAX_BYTES:
        raise HTTPException(status_code=413, detail="이미지가 너무 커요 (10MB까지)")
    if not data:
        raise HTTPException(status_code=400, detail="빈 이미지예요")

    try:
        return run_scan(data, media_type)
    except portfolio_scan.ScanError:
        raise HTTPException(status_code=422, detail="캡처에서 보유 종목을 읽지 못했어요")
    except Exception as e:  # AI API 오류(키 없음, 네트워크 등). 내용 대신 종류만 남김
        print("포트폴리오 인식 실패:", type(e).__name__)
        raise HTTPException(status_code=502, detail="이미지 인식 서버에 문제가 생겼어요")
