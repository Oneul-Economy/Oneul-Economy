# Backend

뉴스 크롤러(`pipeline/`)와 서버 DB(`db/`)가 들어 있는 폴더입니다.

| 폴더 | 내용 |
| --- | --- |
| `pipeline/` | 뉴스 크롤러. 실행 방법은 [`pipeline/README.md`](pipeline/README.md) |
| `db/` | DB 연결(`database.py`), 테이블 정의(`models.py`), 테이블 만들기(`init_db.py`) |
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
