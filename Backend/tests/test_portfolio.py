"""포트폴리오 캡처 인식 API 테스트. 진짜 AI 대신 run_scan을 가짜로 바꿔 끼운다."""
from fastapi.testclient import TestClient

from api import portfolio
from api.main import app

client = TestClient(app)

PNG = b"\x89PNG\r\n\x1a\n" + b"0" * 32
RESULT = {"holdings": [{
    "stock_name": "삼성전자", "stock_code": None, "quantity": 3.0,
    "avg_price": 71000.0, "market_value": 225000.0, "currency": "KRW",
}]}


def post(data=PNG, content_type="image/png"):
    return client.post("/portfolio/scan", files={"image": ("cap.png", data, content_type)})


def test_scan_ok(monkeypatch):
    got = {}

    def fake(image, media_type):
        got["args"] = (image, media_type)
        return RESULT
    monkeypatch.setattr(portfolio, "run_scan", fake)

    r = post()
    assert r.status_code == 200
    assert r.json() == RESULT
    assert got["args"] == (PNG, "image/png")


def test_scan_jpg_alias(monkeypatch):
    monkeypatch.setattr(portfolio, "run_scan", lambda image, media_type: {"holdings": [], "t": media_type})
    assert post(content_type="image/jpg").json()["t"] == "image/jpeg"


def test_scan_wrong_type_415():
    assert post(content_type="application/pdf").status_code == 415


def test_scan_empty_400():
    assert post(data=b"").status_code == 400


def test_scan_too_big_413(monkeypatch):
    monkeypatch.setattr(portfolio, "MAX_BYTES", 10)
    assert post().status_code == 413


def test_scan_error_422(monkeypatch):
    def fake(image, media_type):
        raise portfolio.portfolio_scan.ScanError("x")
    monkeypatch.setattr(portfolio, "run_scan", fake)
    assert post().status_code == 422


def test_scan_ai_failure_502(monkeypatch):
    def fake(image, media_type):
        raise RuntimeError("network")
    monkeypatch.setattr(portfolio, "run_scan", fake)
    assert post().status_code == 502
