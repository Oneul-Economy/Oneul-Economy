import os
import re
import time

import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

load_dotenv()

MAX_ARTICLES = 5

# ---------- 기사 목록 가져오기 ----------
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
        if query not in title:
            continue
        if "n.news.naver.com" not in item["link"]:
            continue
        articles.append(item)
        if len(articles) >= MAX_ARTICLES:
            break
    return articles


# ---------- 본문 추출 ----------
def clean_body(body_tag):
    for tag in body_tag.select("span.end_photo_org, em.img_desc, script, style, table"):
        tag.decompose()

    for br in body_tag.find_all("br"):
        br.replace_with("\n")
    for tag in body_tag.find_all(["b", "strong", "h2", "h3", "h4", "div"]):
        tag.insert_after("\n")   # 부제목·블록 태그 뒤 줄바꿈
    text = body_tag.get_text()

    text = re.sub(r"\[[^\]]*기자[^\]]*\]", "", text)
    text = re.sub(r"[\w.+-]+@[\w-]+\.[\w.]+", "", text)

    lines = []
    for line in text.split("\n"):
        line = line.strip()
        if not line:
            continue
        if any(w in line for w in ("ⓒ", "©", "무단전재", "재배포 금지", "재배포금지")):
            continue
        lines.append(line)
    return "\n".join(lines)


def fetch_article(url):
    res = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
    res.raise_for_status()
    soup = BeautifulSoup(res.text, "html.parser")

    body_tag = soup.select_one("#dic_area")
    if body_tag is None:
        return None

    title_tag = soup.select_one("#title_area")
    return {
        "title": title_tag.get_text(strip=True) if title_tag else None,
        "body": clean_body(body_tag),
    }


# ---------- 실행 ----------
if __name__ == "__main__":
    articles = fetch_news_list("삼성전자")
    print(f"목록 {len(articles)}개 선택됨\n")

    results = []
    for item in articles:
        article = fetch_article(item["link"])
        time.sleep(1)
        if article is None:
            print("본문 추출 실패:", item["link"])
            continue
        results.append({"item": item, **article})
        print("=" * 60)
        print(article["title"])
        print("-" * 60)
        print(article["body"])

    print(f"\n본문 추출 성공: {len(results)}개")