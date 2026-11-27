# AI 첨삭

크롤링한 기사(`RawArticle`)를 경제 초보 대학생용으로 다시 써서 `News` JSON으로 만든다. 형식은 #3 참고.

## 실행

```bash
cd AI
python -m venv .venv
.venv\Scripts\activate          # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
cp ../.env.example .env         # 쓰는 모델의 키만 채우고 LLM_PROVIDER 맞추기

# 크롤러 결과(기사 배열)를 그대로 넣기
python rewrite.py ../Backend/pipeline/output/raw-article.json
# 기사 하나짜리 파일도 그대로 동작
python rewrite.py samples/raw-article-1.json

python check.py "results/*-v2.json"
```

- 입력: 기사 하나(객체) 파일과 크롤러 결과(배열) 파일 모두 받음. 여러 파일·`*` 패턴도 가능
- 모델 선택: `--provider gemini|claude|openai` (기본값은 `.env`의 `LLM_PROVIDER`), 모델 이름은 `--model`로 변경
- 프롬프트: 기본값 `prompts/rewrite_v2.md` (평가에서 v2가 우세). 다른 버전은 `--prompt prompts/rewrite_v1.md`
- 결과: `results/{기사 id}-{모델}-{프롬프트 버전}.json`. 기사 1건 = 파일 1개 = `News` 객체 하나
- 실패: 기사 하나가 실패해도(API 오류, 거절, 필드 누락) 나머지는 계속 처리. 마지막에 실패한 id 목록을 출력하고 **종료 코드 1**
  ```
  실패 1개
  - 20261119-005930-018-0006412574: KeyError: 'content'
  ```
  고치는 방법: 실패한 기사만 다시 실행

## 결과 검사 (`check.py`)

```bash
python check.py "results/*-v2.json"
echo $?                      # Windows PowerShell은 echo $LASTEXITCODE
```

모든 파일을 끝까지 검사한 뒤 실패 목록을 출력하고, 실패가 하나라도 있으면 **종료 코드 1**.

| 구분 | 조건 | 이유 |
| --- | --- | --- |
| 실패 | 본문에 없는 용어 | 앱이 본문에서 `terms[].word`를 글자 그대로 찾아 밑줄을 침. 없으면 누를 수 없는 용어가 됨 |
| 실패 | 중복 용어 | 같은 단어가 `terms`에 두 번 |
| 실패 | 읽을 수 없음 | 깨진 JSON, 원문을 `samples/`·`Backend/pipeline/output/`에서 못 찾음 |
| 경고 | 겹치는 용어 (예: `["교섭", "단독교섭"]`) | 앱이 긴 용어부터 밑줄을 쳐서 동작에는 문제없음. 자주 나오면 프롬프트에서 피하게 개선 |

```
실패 2개
- 20261105-005930-366-0001202773-claude-v2.json: 본문에 없는 용어 ["단체교섭"]
- 20261105-005930-366-0001202773-claude-v2.json: 중복 용어 ["공동교섭단"]
```

- **실패한 결과는 앱(`Frontend/assets/mock/`)이나 DB(`load_news`)에 넣지 않음**
- 고치는 방법: 그 기사를 `rewrite.py`로 다시 첨삭 → `check.py`로 재검사 → 통과하면 사용

## 파일

| 파일 | 내용 |
| --- | --- |
| `guidelines.md` | 첨삭 기준 |
| `prompts/rewrite_v*.md` | 프롬프트. `{title}`, `{content}` 자리에 원문이 들어감 |
| `rewrite.py` | 첨삭 실행. `id`·`stock_name`·`source`는 원문에서 복사, `read_minutes`는 코드로 계산 |
| `check.py` | 결과 자동 점검 (숫자, 용어, 권유 표현, 분량). 원문은 `samples/`와 `Backend/pipeline/output/`에서 id로 찾음 |
| `samples/` | 입력 기사 (#6 크롤러 결과) |
| `results/` | 결과와 평가 표 (`results/README.md`) |
