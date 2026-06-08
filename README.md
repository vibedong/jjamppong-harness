# 짬뽕하네스

짬뽕하네스는 AI가 바로 코드를 만들지 않고, **질문 → 기획 → 승인 → 실행 → 검증** 순서로 움직이게 하는 안전 하네스입니다.

목표는 빠른 코딩만이 아닙니다. 사용자가 승인하지 않은 파일, 코드, 테스트, 웹 접속, 패키지 설치, commit, push로 AI가 튀지 못하게 막는 것입니다.

README는 안내서입니다. 실제 기준은 `harness/contracts/`, `harness/rules/`, `verify`, `doctor`, `PermissionDecision`입니다.

## 설치

권장 설치 방식은 npm/npx CLI입니다.

```bash
npx @vibedong/jjamppong-harness@0.1.0 install --target F:/mptech
```

로컬 템플릿에서 테스트하거나 직접 설치할 때는:

```bash
node bin/jjamppong.js install --target F:/mptech --template .
```

PowerShell wrapper도 있습니다.

```powershell
.\scripts\install-jjamppong-harness.ps1 . F:mptech -SkipGitHubRepo
```

설치 결과는 대상 폴더 바로 아래에 생겨야 합니다.

```text
F:/mptech/
  AGENTS.md
  README.md
  CONTEXT.md
  handoff.md
  harness/
  modules/
  module-template/
  proposals/
  harness.lock.yaml
```

잘못된 설치:

```text
F:/mptech/jjamppong-harness/AGENTS.md
F:/mptech/ourosuper-harness/AGENTS.md
```

설치는 설치와 검증만 하고 멈춥니다. 설치만 요청했는데 PRD, 이슈, 모듈, 코드, commit, push가 생기면 실패입니다.

## 핵심 개념

| 말 | 쉬운 뜻 |
| --- | --- |
| `gate` | 다음 단계로 넘어가기 전에 잠긴 문 |
| `capability` | AI가 할 수 있는 구체 행동 권한 |
| `events.jsonl` | 실제 승인 기록 원본 |
| `gate-ledger.md` | 사람이 보기 쉬운 승인 기록 보기 |
| `task.yaml` | 빠르게 읽는 현재 상태 요약 |
| `PermissionDecision` | 지금 이 행동을 해도 되는지 판정하는 검사 |

## 작업 흐름

사용자에게는 이렇게 보이면 됩니다.

```text
1. 설치만 하기
2. 만들고 싶은 것 질문하기
3. 자료조사하기
4. 기획/이슈/구조/계획 세우기
5. 진짜 작업 범위 승인받기
6. 승인된 범위만 작업하기
7. 검증하고 사용자 확인받기
8. 배운 점 정리하고 보관하기
```

작은 작업도 같은 흐름을 탑니다. 다만 질문이 빨리 끝날 수 있을 뿐입니다.

## 기획 시작

제품이나 기능을 만들 때 AI는 먼저 `grill`로 사용자 의도를 묻습니다.

기존 폴더나 문서가 있어도 먼저 사용자가 원하는 결과, 제외할 범위, 성공 기준을 확인합니다.

그 다음 `research`에서 기존 코드, 문서, 일반 웹 검색을 확인합니다.

일반 웹 검색과 실제 대상 사이트 접속은 다릅니다. 예를 들어 검색엔진으로 문서를 찾는 것은 `network.web_research`이고, 나라장터 같은 실제 대상 사이트에 접속하거나 크롤링하는 것은 `network.live_target`입니다. live access는 따로 승인받아야 합니다.

## 진짜 작업 승인

계획 리뷰가 끝났다고 구현이 열리지 않습니다.

```text
plan_review completed != implementation approved
```

진짜 작업 전에는 AI가 이렇게 물어야 합니다.

```text
승인 범위: modules/g2b/src/** 안의 코드만 수정합니다.
허용: code
잠김: tests, fixtures, live access, package install, commit, push
이 범위로 작업을 시작해도 될까요?
```

사용자가 “좋아”라고 답해도 위 질문에 적힌 범위만 승인됩니다. 나중 단계나 다른 파일은 자동 승인되지 않습니다.

## 폴더틀, 코드, 테스트, fixture

각각 따로 잠겨 있습니다.

| 항목 | 의미 | 따로 승인 필요 |
| --- | --- | --- |
| 폴더틀 | 빈 폴더, `.gitkeep`, 설명용 placeholder 문서 | 예 |
| 코드 | 실제 동작하는 source file | 예 |
| 테스트 | test/spec 파일과 테스트 실행 | 예 |
| fixture | 샘플 HTML, CSV, JSON 같은 검증 자료 | 예 |
| live access | 실제 사이트/API 접속, 크롤링, 다운로드 | 예 |
| package install | npm/pip/apt 등 의존성 설치 | 예 |
| commit | git commit 생성 | 예 |
| push | GitHub 등 원격 저장소로 push | 예 |

`folder_skeleton` 승인은 코드, 테스트, fixture, runtime config, package file 생성을 허용하지 않습니다.

## 기본 파일 위치

| 위치 | 역할 |
| --- | --- |
| `harness/contracts/` | 기계가 읽는 권한 계약 |
| `harness/rules/` | 사람이 읽는 workflow 설명 |
| `harness/permission/` | PermissionDecision MVP |
| `harness/verify/` | verify pass/fail 검사 |
| `harness/doctor/` | doctor 진단 및 proposal 생성 |
| `harness/templates/` | task/module 산출물 템플릿 |
| `harness/docs/tasks/active/` | 현재 작업 |
| `harness/docs/tasks/archive/` | 끝난 작업 요약과 보관 |
| `modules/` | 승인된 제품 코드 |
| `proposals/` | 하네스 규칙 변경 제안 |

## 검증

계약 테스트:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/contracts/run-all.ps1
```

설치된 프로젝트 검증:

```bash
node bin/jjamppong.js verify --target F:/mptech
```

문제 진단:

```bash
node bin/jjamppong.js doctor --target F:/mptech
```

proposal까지 만들려면:

```bash
node bin/jjamppong.js doctor --target F:/mptech --proposal
```

doctor는 기본적으로 live file을 고치지 않습니다. proposal을 만들어도 사용자가 따로 승인해야 합니다.

## 안전 기준

짬뽕하네스가 막는 흐름:

- 설치만 했는데 planning을 시작함
- 사용자 의도 질문 전에 기존 폴더부터 읽음
- 기존 문서를 사용자 의도처럼 취급함
- plan review만 끝나고 바로 코드 작성
- module structure 승인만으로 폴더 생성
- folder skeleton 승인만으로 코드/테스트/fixture 생성
- “좋아”를 넓은 승인으로 해석
- live target access를 일반 웹 검색처럼 처리
- package install, commit, push를 묵시적으로 실행
- product task에서 harness-core rules를 직접 수정

좋은 문서가 아니라, AI가 통과해야 하는 문을 만든다.
