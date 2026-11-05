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

## 파일

| 파일 | 내용 |
| --- | --- |
| `guidelines.md` | 첨삭 기준 |
| `prompts/rewrite_v*.md` | 프롬프트. `{title}`, `{content}` 자리에 원문이 들어감 |
| `rewrite.py` | 첨삭 실행. `id`·`stock_name`·`source`는 원문에서 복사, `read_minutes`는 코드로 계산 |
| `check.py` | 결과 자동 점검 (숫자, 용어, 권유 표현, 분량) |
| `samples/` | 입력 기사 (#6 크롤러 결과) |
| `results/` | 결과와 평가 표 (`results/README.md`) |
