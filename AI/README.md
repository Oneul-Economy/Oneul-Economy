# AI 첨삭

크롤링한 기사(`RawArticle`)를 경제 초보 대학생용으로 다시 써서 `News` JSON으로 만든다. 형식은 #3 참고.

## 실행

```bash
cd AI
python -m venv .venv
.venv\Scripts\activate          # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
cp ../.env.example .env         # 쓰는 모델의 키만 채우고 LLM_PROVIDER 맞추기

python rewrite.py samples/raw-article-1.json --prompt prompts/rewrite_v2.md
python check.py results/news-1-claude-v2.json
```

- 모델 선택: `--provider gemini|claude|openai` (기본값은 `.env`의 `LLM_PROVIDER`), 모델 이름은 `--model`로 변경
- 결과: `results/news-{기사}-{모델}-{프롬프트 버전}.json`

## 보유 종목 캡처 인식 (`portfolio_scan.py`)

증권 앱 보유 종목(잔고) 화면 캡처를 읽어 #43 `PUT /users/{login_id}/holdings` 요청 형식(`{"holdings": [...]}`)으로 만든다.

```bash
python portfolio_scan.py 캡처.png --provider claude              # 화면에 출력
python portfolio_scan.py 캡처.png -o holdings.json                # 파일로 저장
python portfolio_scan.py samples/portfolio/kr-basic.png --expect samples/portfolio/kr-basic.expected.json
```

- 서버(#46 `POST /portfolio/scan`)에서는 `from portfolio_scan import scan` → `scan(이미지 bytes, "image/png", provider="claude")`
- 화면에서 못 읽은 값은 **추측하지 않고 `null`** (#43 규칙). 이름만 보이면 `stock_code`도 `null`
- 결과는 #43 규칙(이름 1~100자, 코드 20자 이하, 숫자 0 이상, 통화 대문자 3글자, 최대 200개)으로 검사. 안 맞거나 png·jpeg·webp·gif가 아니면 `ScanError`, CLI는 **종료 코드 1**
- 보유 종목 화면이 아니면 `{"holdings": []}`
- 테스트 이미지: `samples/portfolio/`의 가짜 증권 앱 캡처 3장과 정답 JSON. `--expect`로 비교하면 다른 칸을 출력하고 종료 코드 1. 다시 만들려면 `pip install pillow` 후 `python samples/portfolio/make_samples.py`

## 파일

| 파일 | 내용 |
| --- | --- |
| `guidelines.md` | 첨삭 기준 |
| `prompts/rewrite_v*.md` | 프롬프트. `{title}`, `{content}` 자리에 원문이 들어감 |
| `rewrite.py` | 첨삭 실행. `id`·`stock_name`·`source`는 원문에서 복사, `read_minutes`는 코드로 계산 |
| `portfolio_scan.py`, `prompts/portfolio_scan_v1.md` | 보유 종목 캡처 → Holdings JSON |
| `check.py` | 결과 자동 점검 (숫자, 용어, 권유 표현, 분량) |
| `samples/` | 입력 기사 (#6 크롤러 결과) |
| `results/` | 결과와 평가 표 (`results/README.md`) |
