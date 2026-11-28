import json
import sys
from pathlib import Path

from db.database import SessionLocal
from db.models import RawArticle

FIELDS = (
    "id", "stock_code", "stock_name", "press", "title",
    "content", "url", "published_at", "crawled_at",
)


def to_raw(item):
    """크롤러 JSON 항목(dict) → RawArticle. 필드가 빠졌거나 문자열이 아니면 예외"""
    values = {}
    for key in FIELDS:
        value = item[key]  # 필드가 없으면 KeyError
        if not isinstance(value, str):  # null(None)이나 숫자면 ValueError (README 계약: 모든 값은 문자열)
            raise ValueError(f"{key} 값이 문자열이 아님: {value!r}")
        values[key] = value
    return RawArticle(**values)


def label(item, index):
    """실패 메시지에 쓸 이름: id가 있으면 id, 없으면 몇 번째 항목인지"""
    if isinstance(item, dict) and isinstance(item.get("id"), str):
        return item["id"]
    return f"{index}번째 항목"


def main(path):
    # 1) 파일 읽기
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8"))
    except (OSError, ValueError) as e:  # 없는 파일, 깨진 JSON, UTF-8이 아닌 파일
        sys.exit(f"파일 읽기 실패: {path} ({type(e).__name__} {e})")

    items = data if isinstance(data, list) else [data]

    new_count, updated_count, failed = 0, 0, []
    seen = set()

    # 2) DB에 넣기
    with SessionLocal() as session:
        for i, item in enumerate(items):
            try:
                raw = to_raw(item)
            except (KeyError, TypeError, ValueError) as e:
                failed.append(f"{label(item, i)}: {type(e).__name__} {e}")
                continue

            if raw.id in seen:
                print(f"경고: 같은 id가 또 나와서 처음 것만 넣음: {raw.id}")
                continue
            seen.add(raw.id)

            if session.get(RawArticle, raw.id) is None:
                new_count += 1
            else:
                updated_count += 1
            session.merge(raw)

        session.commit()

    print(f"원문 {new_count + updated_count}개 (새로 {new_count}개, 갱신 {updated_count}개)")
    if failed:
        print(f"실패 {len(failed)}개")
        for msg in failed:
            print(" -", msg)
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("사용법: python -m pipeline.load_raw pipeline/output/raw-article.json")
    main(sys.argv[1])