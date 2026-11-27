"""첨삭 결과 자동 점검. 평가 표(results/README.md)의 기계적으로 확인 가능한 칸을 채움.

사용: python check.py results/*-v2.json
원문은 id로 samples/ 와 크롤러 결과(Backend/pipeline/output/)에서 찾음. 파일은 객체·배열 모두 가능.
'쉬운가?'는 사람이 직접 판단.
"""
import glob
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).parent
FIELDS = {"id", "stock_name", "title", "summary", "read_minutes", "body", "terms", "source"}
INVEST = r"사세요|파세요|매수하세요|매도하세요|투자의견|목표주가|추천|오를 것|내릴 것"

RAW_DIRS = [HERE / "samples", HERE.parent / "Backend" / "pipeline" / "output"]

raws = {}
for d in RAW_DIRS:
    for p in d.glob("*.json"):
        data = json.loads(p.read_text(encoding="utf-8"))
        for r in data if isinstance(data, list) else [data]:
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
    # Windows처럼 셸이 *를 안 펼쳐도 동작하게 glob
    for path in [p for arg in sys.argv[1:] for p in sorted(glob.glob(arg)) or [arg]]:
        print(Path(path).name, json.dumps(check(Path(path)), ensure_ascii=False))
