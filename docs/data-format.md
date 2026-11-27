## 🎯 목표
크롤링(BE) → 첨삭(AI) → 화면(FE)으로 넘어가는 뉴스 데이터의 **형식(어떤 이름의 값이 어떤 모양으로 들어가는지)**을 하나로 정하기.

## 📄 최종본

### 1. `RawArticle` — 크롤링 결과 = AI 입력
```json
{
  "id": "20261102-005930-050-0000112859",
  "stock_code": "005930",
  "stock_name": "삼성전자",
  "press": "한국경제",
  "title": "원문 제목",
  "content": "원문 본문 전체 (HTML·광고 제거한 텍스트)",
  "url": "https://...",
  "published_at": "2026-11-02T09:00:00+09:00",
  "crawled_at": "2026-11-02T09:05:00+09:00"
}
```

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `id` | 문자열 | `{발행일 YYYYMMDD}-{종목코드}-{언론사번호}-{기사번호}`. 언론사번호·기사번호는 네이버 기사 주소(`/article/050/0000112859`)의 번호. 같은 기사는 언제 크롤링해도 같은 id이고, RawArticle·News에서 같은 id |
| `stock_code` | 문자열 | 6자리 종목코드 (삼성전자 `005930`). 앞자리 0 유지를 위해 숫자 아닌 문자열 |
| `stock_name` | 문자열 | 종목 이름 |
| `press` | 문자열 | 언론사 |
| `title` | 문자열 | 원문 제목 그대로 |
| `content` | 문자열 | 원문 본문. HTML 태그·광고·기자 이메일 제거 |
| `url` | 문자열 | 원문 링크 |
| `published_at` | 문자열 | 기사 발행 시각. ISO 8601 + 한국 시간(`+09:00`) |
| `crawled_at` | 문자열 | 수집 시각. 형식 동일 |

### 2. `News` — AI 첨삭 결과 = 화면 입력
```json
{
  "id": "20261102-005930-050-0000112859",
  "stock_name": "삼성전자",
  "title": "HBM이 뭐길래 주가가 오를까",
  "summary": "카드에 보일 한두 줄 요약",
  "read_minutes": 3,
  "body": ["문단 1", "문단 2", "문단 3"],
  "terms": [
    { "word": "HBM", "meaning": "메모리 칩을 층층이 쌓아 데이터를 한 번에 많이 보내는 반도체예요." }
  ],
  "source": {
    "press": "한국경제",
    "url": "https://...",
    "published_at": "2026-11-02T09:00:00+09:00"
  }
}
```

| 필드 | 타입 | 설명 | 화면 위치 |
| --- | --- | --- | --- |
| `id` | 문자열 | RawArticle의 id와 동일 | (표시 안 함) |
| `stock_name` | 문자열 | 종목 이름 | 카드 상단, 본문 상단 |
| `title` | 문자열 | 초보자용으로 다시 쓴 제목 | 카드, 본문 |
| `summary` | 문자열 | 1~2문장 요약 | 카드 |
| `read_minutes` | 숫자 | 읽는 데 걸리는 분 (최소 1) | 카드, 본문 상단 |
| `body` | 문자열 배열 | 첨삭한 본문. 배열 한 칸 = 문단 하나 | 본문 |
| `terms` | 배열 | 어려운 용어 2~4개. `word`(용어), `meaning`(쉬운 설명) | 본문 아래 용어 박스 |
| `source` | 객체 | 원문 정보. `press`, `url`, `published_at` | 본문 맨 아래 출처 |

### 3. `Quiz` — 용어 퀴즈 = 퀴즈 화면 입력
`News`와 별도 파일. `news_id`로 기사와 연결. AI 결과: `AI/results/quiz/{news_id}-quiz-{provider}-{ver}.json`, 앱 목업: `Frontend/assets/mock/quiz.json`
```json
{
  "news_id": "20261105-005930-366-0001202773",
  "quizzes": [
    {
      "id": "20261105-005930-366-0001202773-q1",
      "word": "성과급",
      "question": "다음 중 '성과급'의 뜻으로 맞는 것은?",
      "choices": ["보기 1", "보기 2", "보기 3", "보기 4"],
      "answer_index": 1,
      "explanation": "회사 성과에 따라 월급 외에 더 주는 보너스예요."
    }
  ]
}
```

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `news_id` | 문자열 | 퀴즈를 만든 기사의 id (`News.id`와 같음) |
| `quizzes` | 배열 | 기사당 최대 3문제. `News.terms` 앞에서부터 용어 하나당 한 문제 |
| `quizzes[].id` | 문자열 | `{news_id}-q{번호}` (1부터). 결과를 저장할 때 키로 씀 |
| `quizzes[].word` | 문자열 | `News.terms[].word`와 글자까지 같음 |
| `quizzes[].question` | 문자열 | 문제. 용어 단어가 들어가도 됨 |
| `quizzes[].choices` | 문자열 배열 | 보기 4개, 서로 다름. 용어 단어는 보기에 들어가지 않음 |
| `quizzes[].answer_index` | 숫자 | 정답 보기 위치 (0~3). 코드가 보기를 섞은 뒤 정함 |
| `quizzes[].explanation` | 문자열 | 정답 해설, "~해요"체 |

### 4. `OxQuiz` — 기사 내용 OX 퀴즈 = OX 퀴즈 화면 입력
`News`와 별도 파일. `news_id`로 기사와 연결. AI 결과: `AI/results/ox/{news_id}-ox-{provider}-{ver}.json` (용어 퀴즈를 읽는 `load_quiz`의 `results/quiz/` 패턴과 섞이지 않게 별도 폴더). 앱 모델: `Frontend/lib/models/ox_quiz.dart`
```json
{
  "news_id": "20261105-005930-366-0001202773",
  "quizzes": [
    {
      "id": "20261105-005930-366-0001202773-ox1",
      "question": "초기업노조는 2027년 임금교섭에서 동행노조와 공동교섭단을 만들겠다고 밝혔다.",
      "answer": false,
      "hint": "초기업노조가 어떤 교섭 방식을 택했는지 살펴보세요.",
      "explanation": "초기업노조는 동행노조와 공동교섭단을 만들지 않겠다고 전했어요.",
      "evidence": "초기업노조는 2027년 교섭에서 동행노조와 공동교섭단을 만들지 않겠다고 전했어요."
    }
  ]
}
```

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| `news_id` | 문자열 | 퀴즈를 만든 기사의 id (`News.id`와 같음) |
| `quizzes` | 배열 | 기사당 2~3문제. O와 X가 둘 다 있음 |
| `quizzes[].id` | 문자열 | `{news_id}-ox{번호}` (1부터) |
| `quizzes[].question` | 문자열 | 기사 내용에 대한 평서문 |
| `quizzes[].answer` | 참/거짓 | `true` = O, `false` = X |
| `quizzes[].hint` | 문자열 | 풀기 전에 보여 주는 힌트 |
| `quizzes[].explanation` | 문자열 | 정답 해설, "~해요"체 |
| `quizzes[].evidence` | 문자열 | 근거. `News.body`의 문장을 글자 그대로 (화면에서 따옴표로 인용) |
