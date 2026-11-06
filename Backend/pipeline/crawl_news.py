import json
import os
import re
import time
from datetime import datetime, timedelta, timezone
from email.utils import parsedate_to_datetime

import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

load_dotenv()

KST = timezone(timedelta(hours=9))

STOCK_NAME = "삼성전자"
STOCK_CODE = "005930"  # 문자열! 숫자로 쓰면 앞의 00이 사라짐
MAX_ARTICLES = 5
OUTPUT_PATH = "output/raw-article.json"

HEADERS = {"User-Agent": "Mozilla/5.0"}


# ---------- 기사 목록 가져오기 (NAVER API HUB) ----------
def fetch_news_list(query):
    res = requests.get(
        "https://naverapihub.apigw.ntruss.com/search/v1/news",
        params={"query": query, "display": 100, "sort": "date"},
        headers={
            "X-NCP-APIGW-API-KEY-ID": os.getenv("NAVER_CLIENT_ID"),
            "X-NCP-APIGW-API-KEY": os.getenv("NAVER_CLIENT_SECRET"),
        },
    )
    res.raise_for_status()

    articles = []
    for item in res.json()["items"]:
        title = BeautifulSoup(item["title"], "html.parser").get_text()
        if query not in title:  # 제목에 종목명이 있는 기사만
            continue
        if "n.news.naver.com" not in item["link"]:  # 네이버 뉴스 링크만
            continue
        articles.append(item)
        if len(articles) >= MAX_ARTICLES:
            break
    return articles


# ---------- 본문 추출 ----------
def clean_body(body_tag):
    # 사진, 사진 설명, 스크립트 등 본문이 아닌 태그 제거
    for tag in body_tag.select("span.end_photo_org, em.img_desc, script, style, table"):
        tag.decompose()

    # <br>은 줄바꿈으로, 부제목·블록 태그 뒤에도 줄바꿈
    for br in body_tag.find_all("br"):
        br.replace_with("\n")
    for tag in body_tag.find_all(["b", "strong", "h2", "h3", "h4", "div"]):
        tag.insert_after("\n")
    text = body_tag.get_text()

    text = re.sub(r"\[[^\]]*기자[^\]]*\]", "", text)  # [홍길동 기자 abc@x.com] 형태 바이라인
    text = re.sub(r"[\w.+-]+@[\w-]+\.[\w.]+", "", text)  # 남은 이메일

    lines = []
    for line in text.split("\n"):
        line = line.strip()
        if not line:
            continue
        if any(w in line for w in ("ⓒ", "©", "무단전재", "재배포 금지", "재배포금지")):
            continue  # 저작권 문구 줄 제거
        lines.append(line)
    return "\n".join(lines)


def extract_press(soup):
    # 상단 로고의 alt → 없으면 메타 태그
    logo = soup.select_one(".media_end_head_top_logo img")
    if logo and logo.get("alt"):
        return logo["alt"].strip()
    meta = soup.select_one('meta[property="og:article:author"]')
    if meta and meta.get("content"):
        return meta["content"].split("|")[0].strip()
    return None


def fetch_article(url):
    res = requests.get(url, headers=HEADERS)
    res.raise_for_status()
    soup = BeautifulSoup(res.text, "html.parser")

    body_tag = soup.select_one("#dic_area")
    if body_tag is None:
        return None  # 구조가 다른 페이지면 건너뜀

    title_tag = soup.select_one("#title_area")
    return {
        "title": title_tag.get_text(strip=True) if title_tag else None,
        "body": clean_body(body_tag),
        "press": extract_press(soup),
    }


# ---------- RawArticle 변환 / 저장 ----------
def to_raw_article(item, article, seq):
    published = parsedate_to_datetime(item["pubDate"]).astimezone(KST)
    return {
        "id": f"{published:%Y%m%d}-{STOCK_CODE}-{seq:03d}",
        "stock_code": STOCK_CODE,
        "stock_name": STOCK_NAME,
        "press": article["press"],
        "title": article["title"],
        "content": article["body"],
        "url": item["link"],  # 실제로 크롤링한 기사 링크
        "published_at": published.isoformat(),
        "crawled_at": datetime.now(KST).isoformat(timespec="seconds"),
    }


def save_json(data, path=OUTPUT_PATH):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\n저장 완료: {path} ({len(data)}개)")


# ---------- 실행 ----------
if __name__ == "__main__":
    articles = fetch_news_list(STOCK_NAME)
    print(f"목록 {len(articles)}개 선택됨\n")

    raw_articles = []
    seq_by_date = {}  # 날짜별 순번
    for item in articles:
        article = fetch_article(item["link"])
        time.sleep(1)  # 요청 사이 1초 쉬기
        if article is None:
            print("본문 추출 실패:", item["link"])
            continue

        date = parsedate_to_datetime(item["pubDate"]).astimezone(KST).strftime("%Y%m%d")
        seq_by_date[date] = seq_by_date.get(date, 0) + 1
        raw_articles.append(to_raw_article(item, article, seq_by_date[date]))
        print("수집:", article["press"], "|", article["title"])

    save_json(raw_articles)