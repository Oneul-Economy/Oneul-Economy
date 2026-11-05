import os
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

load_dotenv()

res = requests.get(
    "https://naverapihub.apigw.ntruss.com/search/v1/news",
    params={"query": "삼성전자", "display": 100, "sort": "date"},  # 5 → 100
    headers={
        "X-NCP-APIGW-API-KEY-ID": os.getenv("NAVER_CLIENT_ID"),
        "X-NCP-APIGW-API-KEY": os.getenv("NAVER_CLIENT_SECRET"),
    },
)
res.raise_for_status()

articles = []
for item in res.json()["items"]:
    title = BeautifulSoup(item["title"], "html.parser").get_text()
    if "삼성전자" not in title:                 # 제목에 종목명이 있는 기사만
        continue
    if "n.news.naver.com" not in item["link"]:  # 네이버 뉴스 링크만
        continue
    articles.append(item)
    print(title, item["link"])
    ALLOWED_SECTIONS = ("sid=101", "sid=105")  # 경제, IT/과학
    if not any(s in item["link"] for s in ALLOWED_SECTIONS):
        continue
    if len(articles) >= 5:   # 5개 모이면 중단
        break
