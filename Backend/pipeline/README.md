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
