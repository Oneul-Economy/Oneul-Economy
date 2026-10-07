# 오늘의 경제

관심·보유 종목을 교재 삼아, 경제를 처음 배우는 대학생이 하루 10분씩 공부하는 학습 서비스.
종목별 뉴스·공시를 수집하고, AI가 초보자용 해설·용어 설명·퀴즈로 변환한다.

GDGoC KU Worktree 프로젝트

## 링크

| 항목 | 링크 |
| --- | --- |
| 노션 팀 홈 | https://app.notion.com/p/886b062e08d382a3933101af3d03715d |
| Figma | 추가 예정 |
| Discord | 추가 예정 |

## 팀

| 이름 | 역할 | GitHub |
| --- | --- | --- |
| 박재윤 | PM · 팀장 | @chrispark0304 |
| 진승연 | FE · BE | |
| 이승연 | Designer | |
| 형유진 | BE · AI | |
| 배경민 | AI · BE | |
| 오정원 | AI · FE | |

> 첫 PR: 위 표에 본인 GitHub 아이디 추가하기

## 폴더 구조

```
Oneul-Economy/
├── app/            프론트엔드 (웹/앱 여부는 킥오프에서 확정)
├── server/
│   ├── api/        FastAPI 엔드포인트
│   ├── pipeline/   뉴스·공시 수집, 배치 스케줄
│   ├── ai/         프롬프트, 해설·용어·퀴즈 생성
│   └── db/         모델, 마이그레이션
├── .github/        PR·이슈 템플릿, CODEOWNERS
├── .env.example    필요한 환경 변수 목록
└── README.md
```

## 시작하기

```bash
git clone https://github.com/Oneul-Economy/Oneul-Economy.git
cd Oneul-Economy
git checkout develop
cp .env.example .env    # 키 값은 별도로 공유 (레포에 올리지 않음)
```

- 파트별 실행 방법: 세팅 후 추가

---

## 협업 규칙

> 초안. 킥오프에서 확정

### 브랜치 전략

| 브랜치 | 용도 | 규칙 |
| --- | --- | --- |
| `main` | 발표·데모용 안정 버전 | 직접 push 금지. 발표·데모 전에 develop → main PR로 반영 (PM) |
| `develop` | 개발 통합 브랜치 (기본 브랜치) | 직접 push 금지. 작업 브랜치에서 PR로만 반영 |
| `feat/...` 등 | 개인 작업 브랜치 | develop에서 생성, merge 후 삭제 |

### 작업 흐름

1. 이슈 생성 또는 담당 이슈 확인
2. develop 최신화 후 작업 브랜치 생성
   ```bash
   git checkout develop
   git pull
   git checkout -b feat/server-login
   ```
3. 작업 후 작은 단위로 커밋
   ```bash
   git add .
   git commit -m "feat: 로그인 API 추가"
   ```
4. 작업 브랜치 push
   ```bash
   git push -u origin feat/server-login
   ```
5. GitHub에서 PR 생성
   - base: `develop`
   - 템플릿 작성, 본문에 `Closes #이슈번호`
6. 리뷰 1명 이상 승인 후 PR 작성자가 **Squash and merge**
7. merge 후 브랜치 정리
   ```bash
   git checkout develop
   git pull
   git branch -D feat/server-login   # squash merge라 -d 대신 -D
   ```
   - 원격 브랜치는 PR 화면의 **Delete branch** 버튼으로 삭제

### 이름 규칙

**브랜치**: `종류/파트-내용` (소문자, 하이픈)

- 종류: `feat` 기능 · `fix` 버그 수정 · `docs` 문서 · `refactor` 구조 개선 · `chore` 설정·기타
- 파트: `app` · `server` · `ai` (구분이 없으면 생략)
- 예: `feat/app-quiz-screen`, `fix/server-login-error`, `refactor/ai-prompt`, `docs/readme`

**커밋 메시지**: `종류: 내용` (한국어 가능)

- 예: `feat: 퀴즈 채점 API 추가`, `fix: 용어 팝업 닫힘 오류 수정`

**PR 제목**: 커밋 메시지와 같은 형식

- 예: `feat: 오늘의 공부 홈 화면`

### 이슈 라벨

| 라벨 | 대상 |
| --- | --- |
| `app` | 프론트엔드 |
| `server` | API, DB, 배치 |
| `ai` | 프롬프트, 생성, 검수 |
| `design` | 화면 설계, Figma |
| `bug` | 버그 |

### PR 충돌 해결

다른 PR이 develop에 먼저 merge돼서 충돌이 난 경우:

```bash
git checkout feat/server-login
git pull origin develop      # develop 최신 내용 합치기
# 충돌 난 파일 수정
git add .
git commit -m "chore: develop 충돌 해결"
git push
```

### 금지 사항

- `main`, `develop`에 직접 push
- 공유 브랜치에 `git push --force`
- `.env`, API 키(Gemini, OpenDART 등) 커밋
- 다른 사람의 작업 브랜치에 허락 없이 push