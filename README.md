# 짬뽕하네스

짬뽕하네스는 Codex가 새 프로젝트를 시작할 때 바로 코드를 만들지 않고, 요구사항 정리부터 PRD, 이슈 분해, writing plan, 리뷰, 구현, 검증, 학습 회수까지 같은 순서로 진행하게 만드는 개인용 작업 흐름 하네스입니다.

이 저장소는 npm 패키지가 아닙니다. 여기서 “설치”란 템플릿 내용을 대상 프로젝트 루트에 직접 펼치는 것을 뜻합니다.

GitHub 템플릿 원본은 `vibedong/jjamppong-harness`입니다.

## 왜 필요한가

새 프로젝트가 흔들리는 지점은 보통 비슷합니다.

- 요구사항이 모호한데 바로 구현함
- 폴더 구조가 작업마다 달라짐
- 계획 리뷰 없이 큰 방향을 확정함
- 검증 없이 완료라고 말함
- 다음 채팅으로 넘어가면 맥락이 끊김
- 한 프로젝트에서 배운 내용을 다음 프로젝트에 재사용하지 못함

짬뽕하네스는 이 흐름을 파일과 규칙으로 고정합니다. Codex가 매번 같은 입구로 들어오고, 같은 산출물을 만들고, 같은 검증 기준으로 끝내게 하는 것이 목적입니다.

## 무엇이 들어있나

| 위치 | 역할 |
| --- | --- |
| `AGENTS.md` | Codex가 반드시 따라야 할 최상위 작업 규칙 |
| `harness/rules/` | 작업 흐름, 필수 규칙, 모듈 유형 기준 |
| `harness/state/` | 현재 프로젝트의 결정 상태와 승인된 구조 |
| `harness/docs/tasks/` | PRD, 이슈, brief, writing plan, 리뷰, 검증 산출물 |
| `harness/docs/solutions/` | 다음 프로젝트에도 재사용할 수 있는 학습 |
| `modules/` | 승인된 뒤 실제 제품 코드가 들어가는 공간 |
| `module-template/` | 새 모듈을 만들 때 쓰는 기본 틀 |
| `proposals/` | 실제 규칙을 바꾸기 전 검토하는 제안 공간 |
| `handoff.md` | 사용자가 요청했을 때만 갱신하는 새 채팅 인계 문서 |

새 프로젝트에 설치할 때 `harness/docs/tasks/active/`와 `harness/docs/tasks/archive/`는 빈 폴더로 시작합니다. 템플릿 유지보수 과정에서 생긴 task artifact는 새 프로젝트로 복사하지 않습니다. 기존 프로젝트에 `-AllowOverwrite`로 다시 적용할 때는 그 프로젝트의 기존 task 기록을 지우지 않습니다.

## 작동 방식

```mermaid
flowchart LR
  A["요청 정리"] --> B["계획 게이트"]
  B --> C["PRD 승인"]
  C --> D["issue 분해"]
  D --> E["issue 승인"]
  E --> F["task brief"]
  F --> G["writing plan"]
  G --> H["계획 리뷰"]
  H --> I["구현"]
  I --> J["검증"]
  J --> K["학습 기록"]
```

기본 전체 작업 흐름은 다음 순서입니다.

1. 요청 인테이크 (`Request Intake`)
2. `setup-matt-pocock-skills` 준비 확인
3. 질문 방식 선택 및 완료 게이트 (`Grill Routing And Completion Gate`)
4. 질문 결과 기록 (`Grill Result Record`)
5. 모듈 구조 게이트 (`Module Structure Gate`)
6. `to-prd`
7. 사용자 PRD 승인
8. `to-issues`
9. 사용자 이슈 승인
10. task brief
11. `superpowers:writing-plans`
12. 필수 계획 리뷰 질문
13. 구현 또는 적용
14. 검증
15. `ce-compound`
16. task artifact 보관
17. 학습 업데이트 질문

작은 작업도 기본적으로 같은 흐름을 탑니다. 예외를 만들고 싶으면 실제 규칙을 바로 바꾸지 말고 `proposals/`에서 먼저 검토합니다.

## 계획 단계 동작

짬뽕하네스는 바로 PRD나 모듈 구조로 가지 않습니다.

계획 단계는 요청 모양에 맞는 질문 흐름을 고르는 것부터 시작합니다.

- `grill-with-docs`: 기존 코드, 문서, 후보 리스트, 도메인 용어, ADR, 과거 구현이 요청을 더 명확하게 만들 수 있을 때 사용합니다.
- `grill-me`: 새로 시작하는 작업이거나 제품 의도 중심이고, 기존 자료만으로는 판단하기 어려울 때 사용합니다.

쉽게 말하면 Codex는 먼저 이미 있는 자료를 확인하고, 그래도 사용자의 결정이 필요한 질문만 해야 합니다.

예를 들어 사용자가 나라장터 crawler를 만들고 싶다고 하면서 기존 `dailynara` 폴더를 말하면, Codex는 먼저 `grill-with-docs`로 `dailynara`를 확인해야 합니다. 코드로 알 수 있는 것을 사용자에게 다시 묻지 않아야 합니다.

질문 단계는 한 번에 하나씩 묻고, 선택한 route, 확인한 근거, 근거로 답한 질문, 사용자에게 물은 질문, 보류한 미정사항, 남은 결정을 `harness/docs/tasks/active/<slug>/grill.md`에 기록합니다. PRD, 이슈 분해, 모듈 구조, writing plan, 구현은 핵심 불확실성이 해결되거나 사용자가 명시적으로 보류를 승인한 뒤에 진행합니다.

`modules/`가 비어 있거나 `harness/state/module-structure.md`에 승인된 모듈 구조가 없다고 되어 있으면, Codex는 제품 PRD, 이슈 분해, writing plan, 제품 모듈 폴더, 제품 코드로 넘어가기 전에 사용자와 모듈 구조를 먼저 정해야 합니다. 요청이 제품 모듈 폴더나 제품 코드를 만들거나 바꾸는 일이 아니라면, Codex는 Module Structure Gate를 해당 없음으로 기록하고 모듈 구조 질문을 하지 않습니다.

## Gate Response Test

하네스는 특정 단어 목록으로 승인을 판단하지 않습니다. 대신 직전 gate 질문과 사용자 답변의 관계를 봅니다.

gate가 열리려면 다음이 모두 맞아야 합니다.

1. 직전에 명시적인 gate 질문이 있었음
2. 사용자 답변이 그 질문에 직접 답함
3. 승인 범위가 질문 범위와 같음
4. 조건, 반대, 새 blocker, 미정사항이 따로 처리됨
5. task의 `gate-ledger.md`에 기록됨

이 중 하나라도 부족하면 gate는 닫힌 상태로 유지되고, Codex는 더 좁은 확인 질문을 해야 합니다.

사용자가 한국어로 말하면 Codex도 한국어로 물어봅니다. `PRD`, `issue`, `commit`, `push` 같은 개발 용어가 필요하면, 승인 질문 전에 쉬운 말로 짧게 풀어서 설명해야 합니다.

예를 들어 "이 모듈 구조를 승인할까요?"라는 질문에 사용자가 "좋아"라고 답하면 module structure만 승인됩니다. 이 답변은 PRD 승인, issue 승인, writing plan 승인, 구현 시작, commit/push 승인이 아닙니다.

반대로 사용자가 "근데 Selenium 방식은 어떻게 돼?"처럼 다른 질문을 하면 gate 승인으로 기록하지 않습니다. Codex는 그 질문에 답한 뒤 다시 좁은 gate 질문을 해야 합니다.

좋은 승인 질문 예시는 이렇습니다.

```text
승인 범위: 모듈 구조만 승인합니다.
이걸 승인하면 PRD 초안 작성만 시작할 수 있고, 구현/커밋/푸시는 아직 잠겨 있습니다.
`modules/g2b-extraction`을 첫 제품 모듈로 잡아도 될까요?
```

## 하네스 적용 예상 시나리오

하네스가 적용된 프로젝트에서 사용자가 이렇게 말한다고 가정합니다.

```text
나라장터에서 실시설계들을 크롤링해서 원하는 값만 추출하는 도구를 만들고싶어.
기존에 만든건 dailynara라는 폴더에 있거든.
전체 추출을 먼저 진행하고, 통과/검토필요/제외로 나누고,
사용자가 제외한 데이터는 다음부터 실수하지 않게 반영하고싶어.
```

이때 기대하는 Codex 동작은 다음과 같습니다.

1. 먼저 `AGENTS.md`와 `harness/rules/`를 읽습니다.
2. 바로 코딩을 시작하지 않습니다.
3. 요청에 기존 코드나 과거 작업이 나오므로 `grill-with-docs`를 선택합니다.
4. 사용자에게 묻기 전에 `dailynara/`, 후보 리스트, 기존 crawler 흐름, 저장된 출력, 관련 문서를 확인합니다.
5. 코드나 문서가 이미 답하는 질문은 근거로 답합니다.
6. 남은 결정 질문만 한 번에 하나씩 묻습니다.
7. 선택한 route, 확인한 근거, 근거로 답한 질문, 사용자 답변, 보류한 미정사항, blocker를 `harness/docs/tasks/active/<slug>/grill.md`에 기록합니다.
8. 제품 코드나 모듈 폴더가 생길 수 있고 승인된 모듈 구조가 없다면, 모듈 구조 옵션 2~3개를 쉬운 말로 제안합니다.
9. 승인된 모듈 구조를 `harness/state/module-structure.md`에 기록합니다.
10. 그 다음에만 PRD, 이슈 분해, task brief, writing plan, 계획 리뷰, 구현, 검증으로 넘어갑니다.

### 첫 제품 요청에서 기대되는 흐름

새로 설치한 프로젝트는 `harness/state/module-structure.md`가 미승인 상태로 시작합니다. 이 상태에서 사용자가 "나라장터 크롤러를 만들고 싶어"처럼 제품 기능을 요청하면 Codex는 바로 PRD나 구현 계획으로 가지 않습니다.

먼저 기존 코드와 문서를 확인해 `grill-with-docs` 또는 `grill-me`를 고르고, 핵심 불확실성을 정리한 뒤 Module Structure Gate에서 프로젝트 폴더 구조 선택지를 제안해야 합니다. 사용자가 구조를 승인하면 그 내용을 `harness/state/module-structure.md`에 기록하고, 그 다음에 PRD, 이슈, writing-plan으로 넘어갑니다.

잘못된 흐름은 `intake.md`만 쓰고 바로 `to-prd`나 `writing-plan`으로 넘어가는 것입니다. `modules/`가 비어 있고 승인된 module structure가 없다면, 제품 요청은 반드시 구조 승인 질문에서 멈춰야 합니다.

기존 코드가 스파게티 구조라면 다음처럼 처리합니다.

1. 바로 전체를 갈아엎지 않습니다.
2. 어떤 결합이 위험한지 파일 근거와 함께 쉬운 말로 설명합니다.
3. 현재 출력이나 fixture를 잡아서 기존 동작을 먼저 보존합니다.
4. 정리 작업 이슈와 기능 작업 이슈를 분리합니다.
5. 다음 기능을 망치지 않으면서 진행할 수 있는 가장 작은 구조를 추천합니다.
6. 모듈 구조나 제품 코드를 바꾸기 전에 사용자 승인을 받습니다.

이 하네스가 막으려는 나쁜 흐름은 다음과 같습니다.

- 기존 코드를 읽기 전에 구현을 시작함
- `dailynara/`가 이미 답하는 내용을 사용자에게 다시 물음
- `modules/` 아래에 즉흥적인 폴더를 만듦
- 모호한 요청에서 바로 PRD나 코드로 점프함
- 검증 근거 없이 완료됐다고 말함

## 요구사항

이 하네스는 아래 도구와 skill이 있다는 전제로 동작합니다.

### 필수

- GitHub 계정
- 이 private template 저장소에 접근할 권한
- Git
- Codex 앱
- Matt Pocock skills
- Superpowers
- gstack 리뷰 skill
- Compound Engineering `ce-compound`
- vowline

### 권장

- GitHub CLI `gh`
- AGENTS.md Management plugin
- PowerShell 또는 기본 터미널 사용 가능 상태

필수 skill이나 plugin이 없으면 Codex는 조용히 비슷한 방식으로 대체하지 말고 멈춰야 합니다. 어떤 항목이 없는지 사용자에게 말하고, 설치 또는 활성화 후 다시 진행해야 합니다.

Matt Pocock skills가 없다면 먼저 설치합니다.

```bash
npx skills@latest add mattpocock/skills
```

준비 확인 기준은 `harness/docs/agents/matt-pocock-skills.md`에 있습니다.

## 설치

설치 대상 폴더 자체가 harness root입니다. `F:/mptech`에 설치한다면 최종 구조는 `F:/mptech/AGENTS.md`, `F:/mptech/harness/`, `F:/mptech/modules/`가 바로 보여야 합니다.

### 권장 설치 스크립트

이 하네스는 npm 패키지처럼 설치하는 라이브러리가 아닙니다. GitHub 템플릿 원본을 임시로 읽어서 대상 프로젝트 폴더에 펼치는 프로젝트 bootstrap입니다.

Codex가 짧은 설치 요청을 받으면 직접 `git clone <template> <target>` 하지 말고, 이 스크립트를 우선 사용해야 합니다.

```powershell
.\scripts\install-jjamppong-harness.ps1 vibedong/jjamppong-harness.git F:mptech
```

예상 결과:

```text
F:/mptech/
  AGENTS.md
  README.md
  harness/
  modules/
```

설치 후 `origin`은 템플릿 원본이 아니라 프로젝트 저장소여야 합니다. 예를 들어 `F:/mptech`면 기본 project origin은 `https://github.com/vibedong/mptech.git`입니다. commit과 push는 여전히 사용자의 명시 승인 전까지 하지 않습니다.

### 자연어 설치 요청

Codex에게 짧게 말해도 됩니다.

```text
<template-repo-or-url> <target-path>에 설치해줘
```

예:

```text
vibedong/jjamppong-harness.git F:mptech에 설치해줘
```

이 형식은 이렇게 해석되어야 합니다.

```text
template source: <template-repo-or-url>
target root: normalized <target-path>
project slug: last folder name of target root
```

Windows 드라이브 축약 표기는 설치 전에 정규화합니다. 예를 들어 `<drive>:<folder>`는 `<drive>:/<folder>`로 해석합니다.

설치 결과는 반드시 대상 루트 바로 아래에 생겨야 합니다.

```text
<target-root>/
  AGENTS.md
  README.md
  CONTEXT.md
  handoff.md
  harness/
  modules/
  module-template/
  proposals/
```

잘못된 결과:

```text
<target-root>/jjamppong-harness/AGENTS.md
```

Codex가 이 짧은 문장을 받으면 다음 순서로 처리해야 합니다.

1. 가능하면 `scripts/install-jjamppong-harness.ps1`를 사용합니다.
2. `<target-path>`를 정규화했다고 먼저 말합니다.
3. `<template-repo-or-url>`는 템플릿 원본으로만 사용합니다.
4. 최종 프로젝트 루트는 정규화된 `<target-root>`입니다.
5. `<target-root>`가 기존 git repo면 `origin`을 보존합니다. 단, `origin`이 템플릿 원본이라면 잘못된 설치 상태이므로 프로젝트 저장소 `origin`으로 바꿉니다.
6. `<target-root>`가 비어 있거나 repo가 아니면 대상 폴더 이름으로 project repository를 만들거나 확인하고, `origin`이 프로젝트 저장소를 가리키게 합니다.
7. `README.md`, `AGENTS.md`, `harness/`, `modules/`, `module-template/`, `proposals/` 충돌이 있으면 덮어쓰기 전에 멈추고 물어봅니다.
8. 완료 전 `AGENTS.md`, `harness/`, `modules/`가 `<target-root>` 바로 아래 있는지 확인합니다.
9. 완료 전 `origin`이 템플릿 원본이 아닌지 확인합니다.

### 설치 스크립트로 프로젝트 bootstrap

새 프로젝트와 기존 프로젝트 모두 같은 installer를 사용합니다. 일반 설치 경로에서 GitHub 템플릿 clone 흐름을 직접 쓰지 마세요. 그 방식은 루트 배치, project `origin` 검증, 템플릿 유지보수 task artifact 제거를 우회합니다.

Codex가 이미 이 저장소를 열고 있다면:

```powershell
.\scripts\install-jjamppong-harness.ps1 vibedong/jjamppong-harness.git F:mptech
```

Codex가 installer 파일을 아직 갖고 있지 않다면 템플릿 원본을 임시 폴더에만 clone한 뒤 installer만 실행합니다.

```powershell
$tempBase = (Resolve-Path -LiteralPath ([IO.Path]::GetTempPath())).Path.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$installerRoot = Join-Path $tempBase ('jjamppong-harness-installer-' + [guid]::NewGuid().ToString('N'))
try {
  git clone https://github.com/vibedong/jjamppong-harness.git $installerRoot
  if ($LASTEXITCODE -ne 0) { throw 'Installer source clone failed' }
  & (Join-Path $installerRoot 'scripts/install-jjamppong-harness.ps1') 'vibedong/jjamppong-harness.git' 'F:mptech'
  if ($LASTEXITCODE -ne 0) { throw "Installer failed with exit code $LASTEXITCODE" }
}
finally {
  if (Test-Path -LiteralPath $installerRoot) {
    $resolved = (Resolve-Path -LiteralPath $installerRoot).Path
    if (-not $resolved.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or -not (Split-Path -Leaf $resolved).StartsWith('jjamppong-harness-installer-')) {
      throw "Refusing to remove unexpected installer temp path: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
  }
}
```

Installer가 처리하는 일:

- target path를 정규화합니다. 예: `F:mptech` -> `F:/mptech`.
- 대상 폴더를 프로젝트 루트로 사용하고, 하위 `jjamppong-harness/` 폴더를 남기지 않습니다.
- 대상이 기존 git repo면 기존 project `origin`을 보존합니다.
- 대상에 `origin`이 없으면 프로젝트 저장소 `origin`을 추가합니다.
- 대상 `origin`이 템플릿 원본이면 프로젝트 저장소 `origin`으로 바꿉니다.
- GitHub CLI가 있고 원격 저장소가 없으면 비공개 프로젝트 저장소를 만듭니다.
- 충돌이 있으면 `-AllowOverwrite` 승인 전에는 멈춥니다.
- 새 설치의 `harness/docs/tasks/active/`와 `archive/`를 빈 상태로 둡니다.
- 기존 프로젝트에 `-AllowOverwrite`로 다시 적용할 때 기존 task 기록을 보존합니다.

예상 결과:

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
```

완료 후 `origin`은 템플릿 원본이 아니라 project repository를 가리켜야 합니다.

```powershell
git -C 'F:/mptech' remote -v
```

## 첫 프롬프트

새 프로젝트 저장소를 만든 뒤 Codex에서 생성된 프로젝트 폴더 자체를 열고 이렇게 말합니다.

```text
이 프로젝트를 짬뽕하네스 방식으로 제대로 기획하고 실행 준비해줘.
AGENTS.md와 harness/rules를 먼저 읽고 Full Workflow대로 진행해줘.
PRD 초안 후 내 승인을 받고, issue 분해 후 다시 내 승인을 받은 다음,
task brief와 writing plan까지 만든 뒤 구현 전에 리뷰 여부를 물어봐.
아직 구현하지 마.
```

## 폴더 구조

```text
<project-root>/
  AGENTS.md
  README.md
  CONTEXT.md
  handoff.md
  harness/
    docs/
      agents/
      adr/
      solutions/
      tasks/
        active/<slug>/
        archive/<slug>/
    rules/
      workflow.md
      rules.md
      module-types.md
    state/
      intake.md
      planning.md
      module-structure.md
      compound.md
  module-template/
  proposals/
  modules/
```

## 운영 규칙

| 규칙 | 의미 |
| --- | --- |
| root는 root | 하네스 파일은 프로젝트 폴더 바로 아래에 있어야 합니다. |
| project remote만 사용 | 실제 project root의 `origin`은 project repo를 가리켜야 합니다. |
| 계획 먼저 | PRD와 이슈 승인을 거치기 전에는 구현하지 않습니다. |
| 구현 전 리뷰 | 구현 전에는 Mandatory Plan Review Question을 거칩니다. |
| module은 gate 통과 후 | `modules/` 코드는 module structure 승인 뒤에만 만듭니다. |
| handoff는 명시 요청 때만 | `handoff.md`는 사용자가 요청할 때만 갱신합니다. |
| 조용한 publish 금지 | commit, push, PR, merge, release는 현재 채팅에서 명시 승인 후에만 실행합니다. |

## 자주 생기는 실수

### 파일이 한 폴더 깊게 들어간 경우

잘못된 구조:

```text
F:/mptech/jjamppong-harness/AGENTS.md
```

원하는 구조:

```text
F:/mptech/AGENTS.md
F:/mptech/harness/
F:/mptech/modules/
```

해결은 설치 스크립트를 프로젝트 저장소 루트에 다시 적용하는 것입니다. 이미 잘못 생긴 `F:/mptech/jjamppong-harness/` 안에 중요한 변경사항이 있으면 먼저 확인하고, 설치 결과는 반드시 `F:/mptech/AGENTS.md`, `F:/mptech/harness/`, `F:/mptech/modules/`가 되게 정리합니다.

### 원격 저장소가 아직 템플릿을 가리키는 경우

프로젝트 루트의 `origin`이 템플릿 원본이라면 아직 설치 완료가 아닙니다.

```powershell
git -C 'F:/mptech' remote -v
```

`https://github.com/vibedong/jjamppong-harness.git`가 보이면 project repo로 바꿔야 합니다.

```powershell
.\scripts\install-jjamppong-harness.ps1 vibedong/jjamppong-harness.git F:mptech -ProjectRepo https://github.com/vibedong/mptech.git -AllowOverwrite
```

commit과 push는 이 복구 명령에 포함하지 않습니다. 현재 채팅에서 사용자가 명시 승인한 뒤에만 별도로 실행합니다.

### Codex가 바로 코딩을 시작하는 경우

아래처럼 규칙 파일을 먼저 읽게 합니다.

```text
이 저장소의 AGENTS.md와 harness/rules를 먼저 읽고,
Full Workflow대로 진행해줘.
```

### 모듈 폴더가 너무 빨리 만들어지는 경우

`modules/` 아래 코드는 `harness/state/module-structure.md`가 승인된 뒤에만 만듭니다. 그 전에는 기획 산출물을 `harness/docs/tasks/active/<slug>/` 아래에 둡니다.

## AGENTS.md 관리 플러그인

이 저장소에는 선택적으로 사용할 수 있는 로컬 Codex plugin이 `plugins/agents-md-management/` 아래에 들어 있습니다.

`AGENTS.md` 동작이 헷갈리거나 관리가 필요할 때 사용합니다.

- `agents-md-chain-audit`: Codex가 실제로 어떤 instruction file을 읽는지 확인합니다.
- `agents-md-improver`: instruction file을 점검하고 필요한 수정안을 제안합니다.
- `revise-agents-md`: 세션에서 얻은 재사용 가능한 배움을 승인된 instruction update로 바꿉니다.

이 plugin은 필수 하네스 작업 흐름의 일부가 아닙니다. 사용자가 나중에 명시적으로 요청하기 전까지 개인 Codex marketplace에 설치하지 않습니다.

## 템플릿 유지보수

템플릿 원본을 고칠 때는 `vibedong/jjamppong-harness`를 clone한 template-maintenance checkout에서 작업합니다.

실제 프로젝트를 만들 때는 이 템플릿 원본을 `F:/mptech/jjamppong-harness`로 clone하지 않습니다. `F:/mptech` 자체가 project repository이자 harness root가 되게 만듭니다.

```powershell
git status --short --branch
```

이미 템플릿에서 만들어진 project root에는 변경사항이 자동으로 반영되지 않습니다. 필요한 변경은 각 project repository에서 따로 반영합니다.

## 요약

짬뽕하네스는 프로젝트 폴더 자체에 설치되는 개인용 작업 흐름 템플릿입니다. Codex가 요구사항을 정리하고, 승인 가능한 문서로 나누고, 리뷰와 검증을 거친 뒤에만 `modules/`에서 실제 제품 작업을 시작하게 만듭니다.
