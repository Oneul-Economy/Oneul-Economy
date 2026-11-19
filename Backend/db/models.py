from sqlalchemy import ForeignKey, JSON, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db.database import Base


class News(Base):
    __tablename__ = "news"

    id: Mapped[str] = mapped_column(primary_key=True)
    stock_name: Mapped[str]
    title: Mapped[str]
    summary: Mapped[str]
    read_minutes: Mapped[int]
    body: Mapped[list[str]] = mapped_column(JSON)
    source_press: Mapped[str]
    source_url: Mapped[str]
    published_at: Mapped[str]
    loaded_from: Mapped[str]

    terms: Mapped[list["NewsTerm"]] = relationship(
        back_populates="news",
        order_by="NewsTerm.position",
        cascade="all, delete-orphan",
    )


class NewsTerm(Base):
    __tablename__ = "news_terms"

    news_id: Mapped[str] = mapped_column(ForeignKey("news.id"), primary_key=True)
    position: Mapped[int] = mapped_column(primary_key=True)
    word: Mapped[str]
    meaning: Mapped[str]

    news: Mapped["News"] = relationship(back_populates="terms")

class RawArticle(Base):
    __tablename__ = "raw_articles"

    id: Mapped[str] = mapped_column(primary_key=True)
    stock_code: Mapped[str]
    stock_name: Mapped[str]
    press: Mapped[str]
    title: Mapped[str]
    content: Mapped[str] = mapped_column(Text)
    url: Mapped[str]
    published_at: Mapped[str]
    crawled_at: Mapped[str]
