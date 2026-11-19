import glob
import json
import sys
from pathlib import Path

from db.database import SessionLocal
from db.models import News, NewsTerm


def expand(patterns):
    """인자로 받은 패턴(*)을 실제 파일 목록으로 펼치기. 매칭이 없으면 그대로 두고, 열 때 실패로 잡힘"""
    files = []
    for p in patterns:
        files.extend(sorted(glob.glob(p)) or [p])
    return files


def to_news(data, filename):
    # TODO 1: data(dict) → News 객체로
    #  - 키가 같은 것: id, stock_name, title, summary, read_minutes, body
    #  - 펼칠 것: data["source"]의 press, url, published_at → source_press, source_url, published_at
    #  - terms: enumerate로 NewsTerm(position=i, word=..., meaning=...) 목록
    #  - loaded_from=filename

    src = data["source"]
    return News(
        id=data["id"],
        stock_name=data["stock_name"],
        title=data["title"],
        summary=data["summary"],
        read_minutes=data["read_minutes"],
        body=data["body"],
        source_press=src["press"],
        source_url=src["url"],
        published_at=src["published_at"],
        loaded_from=filename,
        terms=[
            NewsTerm(position=i, word=t["word"], meaning=t["meaning"])
            for i, t in enumerate(data["terms"])
        ],
    )


    

def main(patterns):
    loaded, skipped, failed = 0, 0, []

    # 1) 먼저 전부 읽어서 id별로 모으기 (같은 id가 두 번 나오는지 보려고)
    by_id = {}
    for f in expand(patterns):
        try:
            data = json.loads(Path(f).read_text(encoding="utf-8"))
            news = to_news(data, Path(f).name)
        except (OSError, json.JSONDecodeError, KeyError, TypeError) as e:
            failed.append(f"{f}: {type(e).__name__} {e}")
            continue
        by_id.setdefault(news.id, []).append((f, news))

    # 2) DB에 넣기
    with SessionLocal() as session:
        for news_id, items in by_id.items():
            # TODO 2:
            #  - items가 2개 이상이면: 경고 출력(파일 이름들), skipped += 1, 넣지 않고 다음으로
            #  - 아니면: session.merge(items[0][1]), loaded += 1
            if(len(items) > 1):
                print(f"경고: {news_id}가 여러 번 나옴: {[f for f, _ in items]}")
                skipped += 1
                continue
            session.merge(items[0][1])
            loaded += 1
        session.commit()

    print(f"넣음 {loaded}개, 건너뜀 {skipped}개, 실패 {len(failed)}개")
    for msg in failed:
        print(" -", msg)
    if failed:
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("사용법: python -m pipeline.load_news <파일 또는 패턴> ...")
    main(sys.argv[1:])