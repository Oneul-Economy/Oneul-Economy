from pydantic import BaseModel

from db.models import News


class Term(BaseModel):
    word: str
    meaning: str


class Source(BaseModel):
    press: str
    url: str
    published_at: str        # datetime으로 바꾸지 않기 (+09:00 유지)


class NewsOut(BaseModel):
    id: str
    stock_name: str
    title: str
    summary: str
    read_minutes: int
    body: list[str]
    terms: list[Term]
    source: Source


def to_out(news: News) -> NewsOut:
    # TODO 3: News(DB 행) → NewsOut
    #  - 키가 같은 것: id, stock_name, title, summary, read_minutes, body
    #  - terms: news.terms(NewsTerm 목록)를 Term(word=..., meaning=...) 목록으로
    #  - source: Source(press=news.source_press, url=..., published_at=...)
    return NewsOut(
        id=news.id,
        stock_name=news.stock_name,
        title=news.title,
        summary=news.summary,
        read_minutes=news.read_minutes,
        body=news.body,
        terms=[Term(word=t.word, meaning=t.meaning) for t in news.terms],
        source=Source(press=news.source_press, url=news.source_url, published_at=news.published_at)
        )