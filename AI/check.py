"""첨삭 결과 자동 점검. 평가 표(results/README.md)의 기계적으로 확인 가능한 칸을 채움.

사용: python check.py results/news-1-claude-v2.json [...]
원문은 id로 samples/ 에서 찾음. '쉬운가?'는 사람이 직접 판단.
"""
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).parent
FIELDS = {"id", "stock_name", "title", "summary", "read_minutes", "body", "terms", "source"}
INVEST = r"사세요|파세요|매수하세요|매도하세요|투자의견|목표주가|추천|오를 것|내릴 것"

raws = {}
for p in (HERE / "samples").glob("*.json"):
    r = json.loads(p.read_text(encoding="utf-8"))
    raws[r["id"]] = r


def check(path: Path) -> dict:
    n = json.loads(path.read_text(encoding="utf-8"))
    raw = raws[n["id"]]
    src = raw["title"] + raw["content"]
    text = " ".join([n["title"], n["summary"], *n["body"]])
    body = " ".join(n["body"])
    return {
        "형식": set(n) == FIELDS and 3 <= len(n["body"]) <= 5 and 2 <= len(n["terms"]) <= 4,
        "원문에 없는 숫자": sorted({x for x in re.findall(r"\d[\d,.]*\d|\d", text) if x not in src}),
        "본문에 없는 용어": [t["word"] for t in n["terms"] if t["word"] not in body],
        "권유 표현": re.findall(INVEST, text),
        "본문 글자": len("".join(n["body"])),
        "문단별 문장": [len(re.findall(r"[요다][.!?]", p)) for p in n["body"]],
        "영문 약어": sorted(set(re.findall(r"[A-Z]{2,}", body))),
    }


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        print(Path(arg).name, json.dumps(check(Path(arg)), ensure_ascii=False))
