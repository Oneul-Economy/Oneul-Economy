"""첨삭 결과 자동 점검. 평가 표(results/README.md)의 기계적으로 확인 가능한 칸을 채움.

사용: python check.py results/*-v2.json
원문은 id로 samples/ 와 크롤러 결과(Backend/pipeline/output/)에서 찾음. 파일은 객체·배열 모두 가능.
'쉬운가?'는 사람이 직접 판단.

실패 조건 (하나라도 있으면 종료 코드 1, 그 결과는 앱·DB에 넣지 않음):
  - 본문에 없는 용어: 앱이 본문에서 terms[].word를 글자 그대로 찾아 밑줄을 치므로, 없으면 누를 수 없음
  - 중복 용어: 같은 단어가 terms에 두 번
  - 파일을 읽을 수 없음 (깨진 JSON, 원문을 못 찾음 등)
경고 (실패 아님): 겹치는 용어. 앱이 긴 용어부터 밑줄을 쳐서 동작에는 문제없음
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
    words = [t["word"] for t in n["terms"]]
    return {
        "형식": set(n) == FIELDS and 3 <= len(n["body"]) <= 5 and 2 <= len(n["terms"]) <= 4,
        "원문에 없는 숫자": sorted({x for x in re.findall(r"\d[\d,.]*\d|\d", text) if x not in src}),
        "본문에 없는 용어": [t["word"] for t in n["terms"] if t["word"] not in body],
        "중복 용어": sorted({w for w in words if words.count(w) > 1}),
        "겹치는 용어": [[a, b] for a in words for b in words if a != b and a in b],
        "권유 표현": re.findall(INVEST, text),
        "본문 글자": len("".join(n["body"])),
        "문단별 문장": [len(re.findall(r"[요다][.!?]", p)) for p in n["body"]],
        "영문 약어": sorted(set(re.findall(r"[A-Z]{2,}", body))),
    }


FAIL_KEYS = ["본문에 없는 용어", "중복 용어"]
WARN_KEYS = ["겹치는 용어"]


def dumps(x) -> str:
    return json.dumps(x, ensure_ascii=False)


def main(args: list[str]) -> int:
    failures, warnings = [], []
    # Windows처럼 셸이 *를 안 펼쳐도 동작하게 glob. 첫 실패에서 멈추지 않고 모든 파일을 검사
    for path in [Path(p) for arg in args for p in sorted(glob.glob(arg)) or [arg]]:
        try:
            result = check(path)
        except Exception as e:
            failures.append(f"{path.name}: 읽을 수 없음 ({type(e).__name__}: {e})")
            continue
        print(path.name, dumps(result))
        failures += [f"{path.name}: {k} {dumps(result[k])}" for k in FAIL_KEYS if result[k]]
        warnings += [f"{path.name}: {k} {dumps(result[k])}" for k in WARN_KEYS if result[k]]

    if warnings:
        print(f"\n경고 {len(warnings)}개 (실패 아님)")
        print("\n".join(f"- {w}" for w in warnings))
    print(f"\n실패 {len(failures)}개")
    print("\n".join(f"- {f}" for f in failures))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
