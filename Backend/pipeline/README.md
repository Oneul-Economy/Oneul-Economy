뉴스 크롤러 (pipeline)

종목 관련 최신 뉴스를 NAVER API HUB 뉴스 검색으로 가져온 뒤, 기사 본문을 추출해서 RawArticle 형식(#3) JSON으로 저장합니다.

실행 방법

모든 명령은 Backend/pipeline 폴더에서 실행합니다.

1. 가상환경 만들기
bash
python -m venv .venv

Mac/Linux에서 python이 없으면 python3을 쓰세요.

2. 가상환경 켜기
bash
# Windows (PowerShell)
.venv\Scripts\Activate.ps1

# Mac/Linux
source .venv/bin/activate

프롬프트 앞에 (.venv)가 붙으면 성공입니다.

Windows에서 "스크립트를 실행할 수 없습니다" 오류가 나면 한 번만 실행하세요. Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

3. 라이브러리 설치
bash
pip install -r requirements.txt
4. .env 만들기

Backend/pipeline/.env 파일을 만들고 키를 넣습니다. 필요한 키 이름은 저장소 루트의 .env.example에 있습니다.

NAVER_CLIENT_ID=발급받은값
NAVER_CLIENT_SECRET=발급받은값
키는 네이버 클라우드 플랫폼 → Services → Application Service → NAVER API HUB에서 앱을 등록하고 발급받습니다. 앱 등록 시 뉴스 검색을 선택하세요.
기존 네이버 개발자센터(developers.naver.com)에서는 검색 API 신규 신청이 종료되었습니다.
.env는 절대 커밋하지 마세요.
5. 실행
bash
python crawl_news.py

실행하면 수집한 기사가 화면에 출력되고, 결과가 output/raw-article.json에 저장됩니다.

결과 형식

output/raw-article.json에 기사 여러 개가 배열로 저장됩니다. 각 기사는 #3 RawArticle 형식입니다.

json
[
  {
    "id": "20261105-005930-001",
    "stock_code": "005930",
    "stock_name": "삼성전자",
    "press": "시사저널",
    "title": "기사 제목",
    "content": "사진 설명·기자 이메일·저작권 문구를 제거한 본문",
    "url": "https://n.news.naver.com/mnews/article/...",
    "published_at": "2026-11-05T11:46:00+09:00",
    "crawled_at": "2026-11-05T12:34:38+09:00"
  }
]
수집 기준
종목명(STOCK_NAME)으로 최신순 검색 후, 제목에 종목명이 들어간 기사만 사용
본문 구조가 같은 네이버 뉴스(n.news.naver.com) 기사만 사용
최대 MAX_ARTICLES(기본 5)개 수집, 요청 사이 1초 대기
종목을 바꾸려면 crawl_news.py 위쪽의 STOCK_NAME, STOCK_CODE를 수정
알려진 한계
언론사 사이트로만 연결되는 기사(네이버 뉴스에 없는 기사)는 수집하지 않음
같은 사건을 다룬 기사가 여러 개 수집될 수 있음 (중복 제거 없음)
언론사별 면책 문구 등 일부 문구는 본문에 남을 수 있음