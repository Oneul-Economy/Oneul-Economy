"""로그인 API 테스트. 진짜 Firebase 대신 verify_token을 가짜로 바꿔 끼운다."""
from fastapi.testclient import TestClient

from api import auth
from api.main import app

client = TestClient(app)


def test_me_without_token_401():
    """토큰 없이 /me → 401 login required"""
    r = client.get("/me")
    assert r.status_code == 401
    assert r.json() == {"detail": "login required"}


def test_me_invalid_token_401(monkeypatch):
    """가짜 토큰 → 401 invalid token"""
    def fake_verify(token):
        raise ValueError("bad token")
    monkeypatch.setattr(auth, "verify_token", fake_verify)

    r = client.get("/me", headers={"Authorization": "Bearer abc"})
    assert r.status_code == 401
    assert r.json() == {"detail": "invalid token"}


def test_me_valid_token(monkeypatch):
    """진짜 토큰이라고 가정 → uid, email 반환"""
    monkeypatch.setattr(auth, "verify_token", lambda token: {"uid": "test-uid", "email": "a@b.com"})

    r = client.get("/me", headers={"Authorization": "Bearer good"})
    assert r.status_code == 200
    assert r.json() == {"uid": "test-uid", "email": "a@b.com"}


def test_cors_allows_authorization_header():
    """크롬(localhost)에서 Authorization 헤더를 보내도 되는지"""
    r = client.options("/me", headers={
        "Origin": "http://localhost:5555",
        "Access-Control-Request-Method": "GET",
        "Access-Control-Request-Headers": "authorization",
    })
    assert r.status_code == 200
    assert "authorization" in r.headers["access-control-allow-headers"].lower()