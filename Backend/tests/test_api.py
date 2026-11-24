"""읽기 API 테스트 (#24 3단계).

흐름: client fixture가 메모리 DB를 만들고 샘플 기사 2건을 넣는다
→ app.dependency_overrides로 get_db를 메모리 DB 세션으로 바꿔 끼운다
→ TestClient가 실제 서버 없이 app에 HTTP 요청을 보낸다.
진짜 DB(data/oneul.db)는 건드리지 않는다.
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from api.main import app, get_db
from db.database import Base
from db.models import News, NewsTerm

NEWS_ID = "20261105-005930-002"      # 최신 기사 (용어 2개)
OLDER_ID = "20261104-005930-001"     # 하루 전 기사 (용어 없음)


def make_news(news_id, published_at, terms=()):
    return News(
        id=news_id, stock_name="삼성전자", title="제목", summary="요약", read_minutes=3,
        body=["문단1", "문단2"], source_press="시사저널", source_url="https://n.news.naver.com/x",
        published_at=published_at, loaded_from="test.json", terms=list(terms),
    )


@pytest.fixture
def client():
    # sqlite:// = 메모리 DB. StaticPool이 연결 하나를 계속 재사용해서
    # 여기서 넣은 데이터를 API 쪽 세션에서도 볼 수 있다.
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    Base.metadata.create_all(engine)
    TestSession = sessionmaker(bind=engine)

    with TestSession() as s:
        s.add(make_news(
            NEWS_ID, "2026-11-05T12:00:00+09:00",
            # 일부러 position 역순으로 넣는다 → 응답이 position 순으로 정렬되는지 확인
            terms=[NewsTerm(position=1, word="임금교섭", meaning="뜻2"),
                   NewsTerm(position=0, word="노동조합", meaning="뜻1")],
        ))
        s.add(make_news(OLDER_ID, "2026-11-04T09:00:00+09:00"))
        s.commit()

    def override_get_db():
        with TestSession() as s:
            yield s

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


def test_keys_match_news_format(client):
    """응답 키가 #3 News 형식과 똑같다 (loaded_from 같은 내부 열은 안 나간다)."""
    news = client.get(f"/news/{NEWS_ID}").json()
    assert set(news) == {"id", "stock_name", "title", "summary", "read_minutes", "body", "terms", "source"}
    assert set(news["source"]) == {"press", "url", "published_at"}
    assert set(news["terms"][0]) == {"word", "meaning"}


def test_published_at_keeps_kst(client):
    """시간 문자열이 바뀌지 않고 +09:00이 그대로 나온다."""
    published_at = client.get(f"/news/{NEWS_ID}").json()["source"]["published_at"]
    assert published_at == "2026-11-05T12:00:00+09:00"


def test_terms_in_position_order(client):
    """역순으로 넣어도 position 순으로 나온다 (relationship의 order_by)."""
    words = [t["word"] for t in client.get(f"/news/{NEWS_ID}").json()["terms"]]
    assert words == ["노동조합", "임금교섭"]


def test_list_newest_first(client):
    """GET /news는 published_at 최신순 목록이다."""
    r = client.get("/news")
    assert r.status_code == 200
    assert [n["id"] for n in r.json()] == [NEWS_ID, OLDER_ID]


def test_list_limit(client):
    """limit=1이면 가장 최신 1건만 온다."""
    r = client.get("/news", params={"limit": 1})
    assert [n["id"] for n in r.json()] == [NEWS_ID]


def test_unknown_id_404(client):
    r = client.get("/news/nope")
    assert r.status_code == 404
    assert r.json() == {"detail": "news not found"}


def test_cors_allows_localhost_any_port(client):
    """Flutter 웹(chrome)은 매번 다른 포트로 뜨므로 localhost의 어떤 포트든 허용한다."""
    r = client.get("/news", headers={"Origin": "http://localhost:54321"})
    assert r.headers["access-control-allow-origin"] == "http://localhost:54321"


def test_quiz_placeholder_404(client):
    """퀴즈는 아직 자리표시(#31): 기사가 있어도 404 'quiz not found'."""
    r = client.get(f"/news/{NEWS_ID}/quiz")
    assert r.status_code == 404
    assert r.json() == {"detail": "quiz not found"}
