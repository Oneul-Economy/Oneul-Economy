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
