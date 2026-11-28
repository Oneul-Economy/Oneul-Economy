# Backend

뉴스 크롤러, 서버 DB, 앱이 부르는 API가 들어 있는 폴더입니다.

```
AI/results/*-v2.json (첨삭 결과)
   │  python -m pipeline.load_news     JSON → DB
   ▼
data/oneul.db (news, news_terms)
   │  uvicorn api.main:app             DB → JSON
   ▼
GET /news, GET /news/{id}  →  Flutter 앱
```

| 폴더 | 내용 |
| --- | --- |
| `pipeline/` | 뉴스 크롤러(`crawl_news.py`, 실행 방법은 [`pipeline/README.md`](pipeline/README.md)), 첨삭 결과 넣기(`load_news.py`) |
| `db/` | DB 연결(`database.py`), 테이블 정의(`models.py`), 테이블 만들기(`init_db.py`) |
| `api/` | 응답 형식(`schemas.py`), API 주소와 처리 함수(`main.py`) |
| `tests/` | API 테스트 (`pytest`) |
| `data/` | SQLite DB 파일(`oneul.db`)이 생기는 곳. git에 올리지 않음 |

## 처음 세팅

**모든 명령은 `Backend` 폴더에서 실행합니다.**

### 1. 가상환경 만들기

```bash
python -m venv .venv
```

- Mac/Linux에서 `python`이 없으면 `python3`을 쓰세요.
- 가상환경 폴더 이름은 처음부터 `.venv`로 만드세요. 만든 뒤에 이름을 바꾸면 동작하지 않습니다. 이름이 틀렸다면 지우고 다시 만드세요.

### 2. 가상환경 켜기

```bash
# Mac/Linux
source .venv/bin/activate

# Windows (PowerShell)
.venv\Scripts\Activate.ps1
```

프롬프트 앞에 `(.venv)`가 붙으면 성공입니다. 터미널을 새로 열 때마다 다시 켜야 합니다.

### 3. 라이브러리 설치

```bash
pip install -r requirements.txt
```

크롤러와 서버가 같은 `requirements.txt`를 씁니다.

### 4. DB 만들기

```bash
python -m db.init_db
```

아래처럼 나오면 성공입니다. `data/oneul.db`가 생깁니다.

```
테이블: ['news', 'news_terms', 'raw_articles']
```

- **꼭 `Backend` 폴더에서 `-m`으로 실행하세요.** `python db/init_db.py`로 실행하거나 다른 폴더에서 실행하면 `No module named 'db'` 오류가 납니다.
- 여러 번 실행해도 됩니다. 없는 테이블만 새로 만들고, 있는 테이블과 데이터는 그대로 둡니다.

### 5. 첨삭 결과 넣기

```bash
python -m pipeline.load_news "../AI/results/*-v2.json" ../docs/mock/news.json
```

- 넣을 파일을 인자로 직접 지정합니다. `*`가 들어간 패턴은 따옴표로 감싸세요 (Windows PowerShell은 `*`를 펼쳐 주지 않음).
- 정식 첨삭 결과는 **v2만** 넣습니다. v1과 v2는 id가 같아서, 같이 지정하면 그 기사는 건너뛰고 경고가 나옵니다.
- 같은 파일을 다시 넣으면 새로 추가되지 않고 갱신됩니다 (upsert). 용어 목록도 새 파일 내용으로 바뀝니다.
- 마지막에 `넣음 N개, 건너뜀 M개, 실패 K개`가 나옵니다. 깨진 파일이 있으면 그 파일만 빼고 넣은 뒤 **종료 코드 1**로 끝납니다.

### 6. 서버 켜기

```bash
uvicorn api.main:app --reload
```

- 브라우저에서 http://127.0.0.1:8000/docs 를 열면 API 목록이 나옵니다. 각 API를 펼쳐 **Try it out → Execute**로 바로 요청해 볼 수 있습니다.
- `--reload`: 코드를 저장하면 서버가 자동으로 다시 켜집니다.
- 끌 때는 `Ctrl+C`.
- `GET`은 명령어가 아닙니다. 터미널에서 요청하려면 다른 창에서 `curl http://127.0.0.1:8000/news`를 쓰세요.

| 요청 | 응답 |
| --- | --- |
| `GET /news?limit=20&offset=0` | News 배열, 최신순. `limit`은 1~100 |
| `GET /news/{id}` | News 하나. 없으면 `404` + `{"detail": "news not found"}` |
| `GET /news/{id}/quiz` | 아직 자리만 있음. 항상 `404` (구현은 #31) |

응답 형식은 `docs/data-format.md`의 `News`(#3)와 같습니다.

### 7. 앱에서 접속할 주소

| 앱 실행 환경 | 서버 주소 |
| --- | --- |
| Chrome (`flutter run -d chrome`), iOS 시뮬레이터 | `http://127.0.0.1:8000` |
| Android 에뮬레이터 | `http://10.0.2.2:8000` (에뮬레이터 안에서 `127.0.0.1`은 에뮬레이터 자신을 가리킴) |
| 실제 휴대폰 | 같은 Wi-Fi에서 `http://<컴퓨터 IP>:8000`. 서버를 `uvicorn api.main:app --host 0.0.0.0`으로 켜야 함 |

- Chrome에서 실행한 앱은 다른 포트에서 요청하기 때문에 CORS 설정이 필요합니다. `api/main.py`에서 `localhost`, `127.0.0.1`의 GET 요청만 허용해 두었습니다.

### 8. 테스트

```bash
pytest
```

- 진짜 DB(`data/oneul.db`)는 건드리지 않습니다. 테스트마다 메모리 DB를 새로 만들어 씁니다.
- `StarletteDeprecationWarning ... httpx2` 경고가 하나 나오는데, 결과와는 상관없습니다.

# 뉴스 크롤러 (pipeline)

종목 관련 최신 뉴스를 NAVER API HUB 뉴스 검색으로 가져온 뒤, 기사 본문을 추출해서 RawArticle 형식(#3) JSON으로 저장합니다.

## 실행 방법

1~3단계(가상환경, 설치)는 `Backend` 폴더에서, 4~5단계는 `Backend/pipeline` 폴더에서 실행합니다.
가상환경(`Backend/.venv`)과 `requirements.txt`(`Backend/requirements.txt`)는 서버(`Backend/db`)와 함께 씁니다.

### 1. 가상환경 만들기

```bash
cd Backend
python -m venv .venv
```

Mac/Linux에서 `python`이 없으면 `python3`을 쓰세요.

### 2. 가상환경 켜기

```bash
# Windows (PowerShell)
.venv\Scripts\Activate.ps1

# Mac/Linux
source .venv/bin/activate
```

프롬프트 앞에 `(.venv)`가 붙으면 성공입니다.

Windows에서 "스크립트를 실행할 수 없습니다" 오류가 나면 아래 명령을 한 번만 실행하세요.

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 3. 라이브러리 설치

```bash
pip install -r requirements.txt
cd pipeline
```

설치 후 4단계부터는 `Backend/pipeline` 폴더에서 진행합니다.

### 4. .env 만들기

`Backend/pipeline/.env` 파일을 만들고 키를 넣습니다. 필요한 키 이름은 저장소 루트의 `.env.example`에 있습니다.

```
NAVER_CLIENT_ID=발급받은값
NAVER_CLIENT_SECRET=발급받은값
```

- 키는 네이버 클라우드 플랫폼 → Services → Application Service → NAVER API HUB에서 앱을 등록하고 발급받습니다. 앱 등록 시 뉴스 검색을 선택하세요.
- 기존 네이버 개발자센터(developers.naver.com)에서는 검색 API 신규 신청이 종료되었습니다.
- `.env`는 절대 커밋하지 마세요.

### 5. 실행

```bash
python crawl_news.py
```

실행하면 수집한 기사가 화면에 출력되고, 결과가 `output/raw-article.json`에 저장됩니다.

## 결과 형식

> 형식이 바뀌면 AI 담당자와 먼저 합의 후 README와 #3을 같이 수정합니다.

- **파일 하나 = 한 번 실행한 결과 = RawArticle의 배열**
- `output/raw-article.json`에 기사 여러 개가 배열로 저장됩니다. 각 기사는 #3 RawArticle 형식입니다.
- **모든 값은 문자열이고, `null`인 값은 없습니다.**

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `id` | string | `{발행일 YYYYMMDD}-{종목코드}-{언론사번호}-{기사번호}` (네이버 기사 주소의 번호 사용, 슬래시 없음) | `20261105-005930-050-0000112859` |
| `stock_code` | string | 종목 코드 (6자리) | `005930` |
| `stock_name` | string | 종목 이름 | `삼성전자` |
| `press` | string | 언론사 이름 | `한국경제` |
| `title` | string | 원문 제목 | `삼성전자, ...` |
| `content` | string | 원문 본문 전체 (HTML·광고 제거한 텍스트) | `...` |
| `url` | string | 네이버 뉴스 기사 주소 | `https://n.news.naver.com/mnews/article/050/0000112859?sid=101` |
| `published_at` | string | 기사 발행 시각, ISO 8601 (KST) | `2026-11-05T09:00:00+09:00` |
| `crawled_at` | string | 수집 시각, ISO 8601 (KST) | `2026-11-05T09:05:00+09:00` |

### 예시

```json
[
  {
    "id": "20261105-005930-050-0000112859",
    "stock_code": "005930",
    "stock_name": "삼성전자",
    "press": "한국경제",
    "title": "원문 제목",
    "content": "원문 본문 전체",
    "url": "https://n.news.naver.com/mnews/article/050/0000112859?sid=101",
    "published_at": "2026-11-05T09:00:00+09:00",
    "crawled_at": "2026-11-05T09:05:00+09:00"
  },
  {
    "id": "20261105-005930-015-0005123456",
    "...": "..."
  }
]
```

## 수집 기준

- 종목명(`STOCK_NAME`)으로 최신순 검색 후, 제목에 종목명이 들어간 기사만 사용
- 본문 구조가 같은 네이버 뉴스(`n.news.naver.com`) 기사만 사용
- 최대 `MAX_ARTICLES`(기본 5)개 수집, 요청 사이 1초 대기
- 종목을 바꾸려면 `crawl_news.py` 위쪽의 `STOCK_NAME`, `STOCK_CODE`를 수정

## 전체 실행 순서 (크롤링 → 첨삭 → 적재 → API)

기사 하나가 같은 id(`{발행일}-{종목코드}-{언론사번호}-{기사번호}`)로 끝까지 이어집니다.

```
1. crawl_news.py   네이버 뉴스 → pipeline/output/raw-article.json (RawArticle 배열)
2. load_raw        raw-article.json → DB raw_articles
3. rewrite.py      raw-article.json → AI/results/{id}-{모델}-v2.json (News)
4. check.py        첨삭 결과 검사. 실패한 결과는 DB에 넣지 않음
5. load_news       첨삭 결과 → DB news, news_terms
6. 서버            GET /news, GET /news/{id}
```

- 1·2·5·6은 `Backend` 가상환경, 3·4는 `AI` 가상환경에서 실행합니다 (AI 세팅은 [`AI/README.md`](../AI/README.md)).
- 지금은 단계마다 직접 실행합니다. 한 번에 돌리는 스크립트는 자동 실행(스케줄러) 단계에서 만듭니다.

### 1. 크롤링 (Backend)

```bash
cd Backend
python pipeline/crawl_news.py
```

`저장 완료: ... (N개)`가 나오면 성공입니다. 키 설정은 [`pipeline/README.md`](pipeline/README.md) 참고.

### 2. 원문 넣기 (Backend)

```bash
python -m pipeline.load_raw pipeline/output/raw-article.json
```

- `원문 N개 (새로 M개, 갱신 K개)`가 나옵니다. 같은 기사를 다시 넣으면 새로 추가되지 않고 갱신됩니다 (upsert).
- 같은 실행 안에 같은 id가 두 번 있으면 처음 것만 넣고 경고합니다.
- 필드가 빠졌거나 값이 문자열이 아닌 기사는 그 기사만 빼고 넣은 뒤 **종료 코드 1**로 끝납니다.

### 3. 첨삭 (AI)

```bash
cd ../AI                         # AI 가상환경 켜기
python rewrite.py ../Backend/pipeline/output/raw-article.json
```

- 결과: `AI/results/{기사 id}-{모델}-v2.json`. 기사 하나가 실패해도 나머지는 계속하고, 마지막에 실패 id를 출력합니다 (종료 코드 1).
- 이미 첨삭한 기사(결과 파일이 있는 기사)는 AI를 부르지 않고 건너뜁니다. 마지막에 `첨삭 N개, 건너뜀 M개, 실패 K개`가 나옵니다.
- 다시 첨삭하려면 `--force`를 붙입니다. 다시 첨삭하면 내용이 바뀌므로 그 기사의 퀴즈도 다시 만듭니다 (`AI/README.md` 참고).

### 4. 결과 검사 (AI)

이번에 크롤링한 기사의 결과만 검사합니다.

```bash
# Mac/Linux
IDS=$(python -c "import json; print(' '.join(a['id'] for a in json.load(open('../Backend/pipeline/output/raw-article.json', encoding='utf-8'))))")
python check.py $(for i in $IDS; do echo "results/$i-*-v2.json"; done)

# Windows (PowerShell)
$ids = (Get-Content ..\Backend\pipeline\output\raw-article.json -Raw -Encoding UTF8 | ConvertFrom-Json).id
python check.py ($ids | ForEach-Object { "results/$_-*-v2.json" })
```

- 종료 코드 `0`이면 통과입니다 (`echo $?`, PowerShell은 `echo $LASTEXITCODE`).
- 실패한 기사(예: 본문에 없는 용어)는 그 결과 파일을 지우고 3단계를 다시 실행합니다. 파일이 없는 그 기사만 다시 첨삭되고 나머지는 건너뜁니다. 그다음 다시 검사합니다. 계속 실패하면 그 기사는 5단계에서 빼고 넣습니다.

### 5. 첨삭 결과 넣기 (Backend)

4단계와 같은 id 목록으로 넣습니다.

```bash
cd ../Backend                    # Backend 가상환경 켜기

# Mac/Linux
python -m pipeline.load_news $(for i in $IDS; do echo "../AI/results/$i-*-v2.json"; done)

# Windows (PowerShell)
python -m pipeline.load_news ($ids | ForEach-Object { "../AI/results/$_-*-v2.json" })
```

- `넣음 N개, 건너뜀 M개, 실패 K개`가 나옵니다.
- 넣는 기사의 id가 `raw_articles`에 없으면 `원문 없음: {id}` 경고가 나옵니다 (넣는 것은 막지 않음). **2단계를 했는데 이 경고가 나오면 id 형식이 어긋난 것**입니다.
- `"../AI/results/*-v2.json"`처럼 전부 넣으면 예전에 만든 다른 기사 결과까지 들어가고, 그 기사들은 원문이 없어서 `원문 없음` 경고가 나옵니다.

### 6. 서버에서 확인 (Backend)

```bash
uvicorn api.main:app --reload
```

http://127.0.0.1:8000/docs 에서 `GET /news`로 목록을, `GET /news/{id}`로 크롤링한 기사 id 그대로 첨삭 결과를 확인합니다.

### 다시 실행할 때

1~5를 다시 돌리면 겹치는 기사는 **추가되지 않고 갱신**됩니다. 행 개수로 확인할 수 있습니다.

```bash
python -c "import sqlite3; c=sqlite3.connect('data/oneul.db'); print({t: c.execute(f'select count(*) from {t}').fetchone()[0] for t in ('raw_articles','news')})"
```

`raw_articles`와 `news`는 2단계의 "새로 M개"만큼만 늘어나야 합니다.

### 커밋하지 않는 것

테스트로 실행하면 아래 파일이 바뀌거나 생깁니다. 커밋하지 말고 되돌리세요.

| 파일 | 되돌리기 |
| --- | --- |
| `Backend/pipeline/output/raw-article.json` | `git restore Backend/pipeline/output/raw-article.json` |
| `AI/results/`의 새 결과 파일 | `git clean -n AI/results`로 목록 확인 후 `git clean -f AI/results` |
| `Backend/data/oneul.db` | `.gitignore`로 이미 제외됨 |

## DB 위치 바꾸기 (선택)

기본 DB는 `Backend/data/oneul.db`입니다. 다른 DB를 쓰려면 환경 변수 `DATABASE_URL`을 지정합니다.

```bash
DATABASE_URL=sqlite:////절대/경로/test.db python -m db.init_db
```

비워 두거나 지정하지 않으면 기본값을 씁니다.

## 테이블

| 테이블 | 내용 |
| --- | --- |
| `raw_articles` | 크롤러가 모은 원문 (`RawArticle` 형식, #3) |
| `news` | AI 첨삭 결과 (`News` 형식, #3) |
| `news_terms` | 기사별 용어. `news`의 `terms`를 한 줄씩 나눠 저장 |

- 시간(`published_at`, `crawled_at`)은 받은 문자열 그대로 저장합니다. `DateTime`으로 바꾸면 SQLite에서 `+09:00`이 사라지기 때문입니다.
- 실제로 만들어진 테이블 구조는 `sqlite3 data/oneul.db ".schema"`로 확인할 수 있습니다.

## 테이블 구조를 바꿨을 때

이 프로젝트는 마이그레이션 도구(Alembic)를 쓰지 않습니다. `init_db`는 **이미 있는 테이블의 열을 바꾸지 않습니다.**

- 새 테이블 추가: `python -m db.init_db`만 다시 실행하면 됩니다.
- 기존 테이블의 열을 바꿈: `data/oneul.db`를 지우고 `python -m db.init_db`를 다시 실행한 뒤, 데이터를 다시 넣습니다.

## 로그인 (Firebase)

앱은 Firebase로 로그인하고, 서버는 앱이 보낸 ID 토큰만 확인합니다. 사용자 데이터(프로필, 저장, 일지)는 Firestore에 있고 서버 DB에는 저장하지 않습니다.

### 설정
1. Firebase 서비스 계정 키(JSON)를 `Backend/firebase-service-account.json`으로 저장 (키는 형유진에게 개인적으로 받기, **절대 커밋 금지**)
2. `Backend/.env`에 경로 추가
   ```
   FIREBASE_CREDENTIALS=firebase-service-account.json
   ```

키가 없어도 서버는 켜지고 `/news`는 동작합니다. 로그인이 필요한 API만 `500 firebase not configured`가 됩니다.

### API
| 요청 | 응답 |
| --- | --- |
| `GET /me` (헤더 `Authorization: Bearer <ID 토큰>`) | `{"uid": "...", "email": "..."}` |
| 토큰 없음 | `401 {"detail": "login required"}` |
| 잘못되거나 만료된 토큰 | `401 {"detail": "invalid token"}` |

로그인이 필요한 API를 새로 만들 때는 `user: CurrentUser = Depends(get_current_user)`를 붙이면 됩니다 (`api/auth.py`).