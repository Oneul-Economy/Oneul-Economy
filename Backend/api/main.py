from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware # 다른 출처의 요청을 허용한다는데... 어려움(Fluttter의 chrome 요청에서 출처 오류 방지용)
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from api.auth import router as auth_router
from api.portfolio import router as portfolio_router
from api.schemas import NewsOut, to_out
from db.database import SessionLocal
from db.models import News

app = FastAPI(title="오늘의 경제 API")
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization"],
)
app.include_router(auth_router)
app.include_router(portfolio_router)

def get_db():
    with SessionLocal() as session:
        yield session            # 요청 처리하는 동안 빌려주고, 끝나면 with가 닫음


@app.get("/news", response_model=list[NewsOut])
def list_news(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    stmt = (
        select(News)
        .options(selectinload(News.terms))
        .order_by(News.published_at.desc())
        .limit(limit)
        .offset(offset)
    )
    return [to_out(n) for n in db.scalars(stmt)]


@app.get("/news/{news_id}", response_model=NewsOut)
def get_news(news_id: str, db: Session = Depends(get_db)):
    # TODO 4:
    #  - db.get(News, news_id)로 PK 조회 (SELECT ... WHERE id = ?)
    #  - 없으면 raise HTTPException(status_code=404, detail="news not found")
    #  - 있으면 to_out(news) 반환

    news = db.get(News, news_id)
    if news is None:
        raise HTTPException(status_code=404, detail="news not found")
    return to_out(news)


@app.get("/news/{news_id}/quiz")
def get_quiz(news_id: str, db: Session = Depends(get_db)):
    if db.get(News, news_id) is None:
        raise HTTPException(status_code=404, detail="news not found")
    # TODO(#31): news_quizzes에서 position 순으로 조회해 QuizSetOut으로 반환
    raise HTTPException(status_code=404, detail="quiz not found")