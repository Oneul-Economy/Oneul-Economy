# 오늘의 경제 — Flutter 앱

## 실행 방법

```bash
cd Frontend
flutter pub get
flutter run -d chrome
```

- Flutter SDK가 필요해요 (`flutter doctor`로 확인).
- 폰트(Noto Sans KR / Noto Serif KR)는 `assets/fonts/`에 넣어 둬서 인터넷 없이도 떠요. 원본이 너무 커서(굵기당 6~14MB) 자주 쓰는 한글 2,350자 + 영문·숫자·기호만 남긴 파일이에요. 목록에 없는 글자는 기본 폰트로 보여요.

## 폴더 구조

```
Frontend/
├── pubspec.yaml               패키지·assets 등록
├── assets/mock/news.json      샘플 뉴스 (#3 News 형식, 서버 연결 전 임시)
└── lib/
    ├── main.dart              앱 시작점
    ├── models/news.dart       News · Term · NewsSource 데이터 클래스
    ├── theme/app_colors.dart  Figma 색상
    ├── screens/
    │   ├── home_screen.dart         홈 (샘플 JSON 로드 → 카드 표시)
    │   └── news_detail_screen.dart  본문 (#5에서 구현)
    └── widgets/news_card.dart       홈 뉴스 카드
```

## 디자인

[Figma — 오늘의 경제 홈 화면](https://www.figma.com/design/rOHMIiwk4vIGPQspseCEp1/?node-id=15-2)
