# 오늘의 경제 — Flutter 앱

## 실행 방법

```bash
cd Frontend
flutter pub get
flutter run -d chrome
```

- Flutter **3.47.9** 이상이 필요해요 (`flutter --version`으로 확인).
- 폰트(Noto Sans KR / Noto Serif KR)는 `assets/fonts/`에 넣어 둬서 인터넷 없이도 떠요. 원본이 너무 커서(굵기당 6~14MB) 자주 쓰는 한글 2,350자 + 영문·숫자·기호만 남긴 파일이에요. 목록에 없는 글자는 기본 폰트로 보여요.

### 오류가 수백 개 뜨거나 `version solving failed`가 나오면

Flutter 버전이 낮은 경우예요. 코드 문제가 아니니 아래 명령을 실행해 주세요.

```bash
flutter upgrade
cd Frontend
flutter pub get
```

그래도 빨간 줄이 남아 있으면 VS Code에서 `Dart: Restart Analysis Server`를 실행해 주세요.

새로 clone하거나 worktree를 만들 때마다 `flutter pub get`도 다시 실행해야 해요.

## CI

`Frontend/`를 수정한 PR을 `develop`·`main`에 올리면 GitHub Actions가 `flutter analyze`와 `flutter test`를 자동으로 돌려요. 올리기 전에 로컬에서 같은 명령으로 미리 확인할 수 있어요.

Flutter 버전을 올릴 때는 `.github/workflows/frontend-ci.yml`의 `flutter-version`과 이 문서의 버전도 같이 바꿔 주세요.

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
