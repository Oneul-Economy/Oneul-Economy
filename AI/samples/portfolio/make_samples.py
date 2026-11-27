"""portfolio_scan.py 테스트용 가짜 증권 앱 캡처와 정답 JSON 만들기.

실제 증권사 화면이 아니라 비슷하게 그린 이미지. 정답을 알고 있어서 인식 결과를 자동으로 비교할 수 있음.
사용: python samples/portfolio/make_samples.py   (Pillow 필요: pip install pillow)
"""
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).parent
FONTS = HERE.parents[2] / "Frontend" / "assets" / "fonts"
W, H = 750, 1334


def font(size, bold=False):
    return ImageFont.truetype(str(FONTS / ("NotoSansKR-Bold.ttf" if bold else "NotoSansKR-Regular.ttf")), size)


def holdings_screen(title, total, rows):
    """rows: (이름, 코드 또는 None, 수량 글자, 평균단가 글자 또는 None, 평가금액 글자, 수익금 글자, 수익률 글자)"""
    img = Image.new("RGB", (W, H), "white")
    d = ImageDraw.Draw(img)
    d.text((40, 40), "9:41", font=font(26, True), fill="black")
    d.text((40, 110), title, font=font(40, True), fill="black")
    d.text((40, 180), "총 평가금액", font=font(26), fill="#888")
    d.text((40, 215), total, font=font(48, True), fill="black")
    d.text((40, 290), "보유종목", font=font(30, True), fill="black")
    y = 350
    for name, code, qty, avg, value, profit, rate in rows:
        d.line((40, y - 15, W - 40, y - 15), fill="#eee", width=2)
        d.text((40, y), name, font=font(32, True), fill="black")
        if code:
            d.text((40 + d.textlength(name, font=font(32, True)) + 14, y + 8), code, font=font(22), fill="#999")
        d.text((W - 40, y), value, font=font(32, True), fill="black", anchor="ra")
        red = "#e5303d" if profit.startswith("+") else "#2f6fe4"
        d.text((W - 40, y + 50), f"{profit} ({rate})", font=font(24), fill=red, anchor="ra")
        d.text((40, y + 50), f"{qty}" + (f" · 평균 {avg}" if avg else ""), font=font(24), fill="#666")
        y += 140
    return img


CASES = {
    "kr-basic": (
        holdings_screen("국내주식 잔고", "1,033,000원", [
            ("삼성전자", None, "3주", "71,000원", "225,000원", "+12,000원", "+5.63%"),
            ("SK하이닉스", None, "2주", "180,500원", "410,000원", "+49,000원", "+13.57%"),
            ("카카오", None, "10주", "52,300원", "398,000원", "-125,000원", "-23.90%"),
        ]),
        [
            {"stock_name": "삼성전자", "stock_code": None, "quantity": 3, "avg_price": 71000, "market_value": 225000, "currency": "KRW"},
            {"stock_name": "SK하이닉스", "stock_code": None, "quantity": 2, "avg_price": 180500, "market_value": 410000, "currency": "KRW"},
            {"stock_name": "카카오", "stock_code": None, "quantity": 10, "avg_price": 52300, "market_value": 398000, "currency": "KRW"},
        ],
    ),
    "mixed-usd-partial": (
        holdings_screen("전체 잔고", "604,000원", [
            ("애플", "AAPL", "0.5주", "$182.30", "$96.10", "+$4.95", "+5.43%"),
            ("TIGER 미국S&P500", None, "15주", "17,850원", "291,000원", "+23,250원", "+8.68%"),
            ("NAVER", "035420", "1주", None, "182,400원", "-6,100원", "-3.24%"),
        ]),
        [
            {"stock_name": "애플", "stock_code": "AAPL", "quantity": 0.5, "avg_price": 182.3, "market_value": 96.1, "currency": "USD"},
            {"stock_name": "TIGER 미국S&P500", "stock_code": None, "quantity": 15, "avg_price": 17850, "market_value": 291000, "currency": "KRW"},
            {"stock_name": "NAVER", "stock_code": "035420", "quantity": 1, "avg_price": None, "market_value": 182400, "currency": "KRW"},
        ],
    ),
}


def not_holdings_screen():
    img = Image.new("RGB", (W, H), "white")
    d = ImageDraw.Draw(img)
    d.text((40, 110), "오늘의 시장 뉴스", font=font(40, True), fill="black")
    for i, line in enumerate([
        "코스피, 외국인 매수에 2,650선 회복",
        "삼성전자 3% 상승… 반도체 강세",
        "원·달러 환율 1,380원대 마감",
        "SK하이닉스, HBM 공급 확대 기대",
    ]):
        d.text((40, 220 + i * 90), line, font=font(30), fill="#333")
    return img


if __name__ == "__main__":
    for name, (img, expected) in CASES.items():
        img.save(HERE / f"{name}.png")
        (HERE / f"{name}.expected.json").write_text(
            json.dumps({"holdings": expected}, ensure_ascii=False, indent=2), encoding="utf-8")
    not_holdings_screen().save(HERE / "not-holdings.png")
    (HERE / "not-holdings.expected.json").write_text('{\n  "holdings": []\n}', encoding="utf-8")
    print("만든 파일:", sorted(p.name for p in HERE.glob("*.png")))
