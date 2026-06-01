# 짬뽕하네스

짬뽕하네스는 Matt Pocock skills, Superpowers, Compound Engineering, gstack review, vowline을 섞어서 모든 작업을 기획 -> PRD -> issue 분해 -> task brief -> writing-plans -> 실행 -> 검증 -> 학습 회수 순서로 강제하는 private agent workflow harness입니다.

이 저장소는 npm package가 아닙니다. 설치란 template 내용을 대상 프로젝트 root에 직접 놓는 것입니다.

GitHub template source는 `vibedong/jjamppong-harness`입니다. 문서와 workflow의 현재 이름은 `짬뽕하네스`입니다.

## Table Of Contents

- [Why](#why)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Directory Layout](#directory-layout)
- [Rules That Matter](#rules-that-matter)
- [Sharing With A Friend](#sharing-with-a-friend)
- [Troubleshooting](#troubleshooting)
- [Maintaining The Template](#maintaining-the-template)

## Why

새 프로젝트는 보통 첫 단추에서 흐트러집니다.

- 요구사항을 덜 물어보고 바로 구현함
- 폴더 구조가 프로젝트마다 달라짐
- 검증 없이 "된 것 같다"고 넘어감
- 다음 채팅에서 맥락이 끊김
- 배운 내용을 다음 프로젝트에 재사용하지 못함

짬뽕하네스는 Codex가 항상 같은 순서로 움직이게 해서 이 문제를 줄입니다.

## Requirements

사용자는 아래 준비가 필요합니다.

- GitHub 계정
- 이 private template 저장소에 접근할 권한
- Git
- GitHub CLI, 선택 사항이지만 추천
- Codex 앱
- Matt Pocock skills
  - `setup-matt-pocock-skills`
  - `grill-with-docs`
  - `to-prd`
  - `to-issues`
- Superpowers
- gstack review skills
  - `plan-ceo-review`
  - `plan-eng-review`
- Compound Engineering `ce-compound`
- vowline

Matt Pocock skills are external requirements. Install them before using the planning gate:

```bash
npx skills@latest add mattpocock/skills
```

Readiness details live at `harness/docs/agents/matt-pocock-skills.md`.

If readiness fails, stop with this message:

```text
Matt Pocock planning skills are required before this harness can continue.
Install them first, then rerun this task.
```

## Installation

이 저장소는 npm package가 아닙니다. 설치란 template 내용을 대상 프로젝트 root에 직접 놓는 것입니다.

### New Project From Template

새 프로젝트를 만들 때는 GitHub template 기능으로 프로젝트 전용 private repository를 만듭니다.

```powershell
Push-Location 'F:/'
gh repo create <project-name> --private --template vibedong/jjamppong-harness --clone
Pop-Location
```

예상 결과:

```text
F:/<project-name>/
  AGENTS.md
  README.md
  handoff.md
  harness/
  modules/
  module-template/
  proposals/
```

완료 후 `origin`은 template source가 아니라 새 project repository를 가리켜야 합니다.

```powershell
git -C 'F:/<project-name>' remote -v
```

### Apply Harness Into Existing Repo Root

이미 `F:/mptech` 같은 프로젝트 repository가 있으면 template source를 중첩 clone하지 않습니다.

Rules:

- Final files must be `F:/mptech/AGENTS.md`, `F:/mptech/harness/`, `F:/mptech/modules/`, not `F:/mptech/jjamppong-harness/AGENTS.md`.
- Copy template contents into the project root excluding `.git/`.
- Preserve the existing project repository `origin`.
- After setup, `git remote -v` in the project root must point to the project repository, not `https://github.com/vibedong/jjamppong-harness.git`.
- The safe command below is for a project root that has no top-level collisions except `.git/`. If files such as `README.md`, `AGENTS.md`, `harness/`, or `modules/` already exist, list the collisions and stop so the user can choose merge, skip, or overwrite path by path.

Safe PowerShell flow:

```powershell
$target = (Resolve-Path -LiteralPath 'F:/mptech').Path
$beforeOrigin = git -C $target remote get-url origin
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($beforeOrigin)) {
  throw "Target must be an existing git repository with an origin remote"
}
$tempBase = (Resolve-Path -LiteralPath ([IO.Path]::GetTempPath())).Path
$tempRoot = Join-Path $tempBase ('jjamppong-harness-' + [guid]::NewGuid().ToString('N'))
try {
  git clone https://github.com/vibedong/jjamppong-harness.git $tempRoot
  if ($LASTEXITCODE -ne 0) { throw "Template clone failed" }
  $source = (Resolve-Path -LiteralPath $tempRoot).Path
  if (-not $source.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar) -or -not (Split-Path -Leaf $source).StartsWith('jjamppong-harness-')) {
    throw "Unexpected temp clone path: $source"
  }
  $collisions = @()
  foreach ($item in Get-ChildItem -LiteralPath $source -Force) {
    if ($item.Name -eq '.git') { continue }
    $destination = Join-Path $target $item.Name
    if (Test-Path -LiteralPath $destination) {
      $collisions += $destination
    }
  }
  if ($collisions) {
    $collisions
    throw "Destination collisions found; choose merge, skip, or overwrite per path before continuing"
  }
  foreach ($item in Get-ChildItem -LiteralPath $source -Force) {
    if ($item.Name -eq '.git') { continue }
    Copy-Item -LiteralPath $item.FullName -Destination $target -Recurse -Force
  }
  $afterOrigin = git -C $target remote get-url origin
  if ($LASTEXITCODE -ne 0 -or $afterOrigin -ne $beforeOrigin) {
    throw "origin changed from $beforeOrigin to $afterOrigin"
  }
  foreach ($required in @('AGENTS.md', 'harness', 'modules')) {
    if (-not (Test-Path -LiteralPath (Join-Path $target $required))) {
      throw "Missing required root item: $required"
    }
  }
  foreach ($nestedName in @('jjamppong-harness', 'ourosuper-harness')) {
    if (Test-Path -LiteralPath (Join-Path $target $nestedName)) {
      throw "Nested $nestedName folder was created"
    }
  }
  git -C $target remote -v
}
finally {
  if (Test-Path -LiteralPath $tempRoot) {
    $resolvedTemp = (Resolve-Path -LiteralPath $tempRoot).Path
    if (-not $resolvedTemp.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar) -or -not (Split-Path -Leaf $resolvedTemp).StartsWith('jjamppong-harness-')) {
      throw "Refusing to remove unexpected temp path: $resolvedTemp"
    }
    Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
  }
}
```

## Quick Start

새 프로젝트 저장소를 만든 뒤, Codex에서 생성된 프로젝트 폴더 자체를 엽니다.

예:

```text
F:/mptech
```

그 다음 Codex에게 이렇게 말합니다.

```text
이 프로젝트를 짬뽕하네스 방식으로 제대로 기획하고 실행 준비해줘.
내 요청을 먼저 정리하고, 모호한 부분을 질문하고, PRD와 실행 이슈로 쪼갠 다음,
PRD 초안 후 내 승인을 받고, issue 분해 후 다시 내 승인을 받은 다음,
task brief와 writing plan까지 만든 뒤 구현 전에 리뷰 여부를 물어봐.
작은 작업이어도 같은 흐름으로 처리해.
```

내부 흐름은 이렇게 기록됩니다.

```text
intake.md
-> setup-matt-pocock-skills readiness check
-> grill-with-docs
-> to-prd
-> user PRD approval
-> to-issues
-> user issue approval
-> brief.md
-> superpowers:writing-plans
-> Mandatory Plan Review Question
```

## How It Works

1. Request Intake
2. setup-matt-pocock-skills Readiness Check
3. grill-with-docs
4. to-prd
5. User PRD Approval
6. to-issues
7. User Issue Approval
8. Task Brief
9. Superpowers Writing Plans
10. Mandatory Plan Review Question
11. Implementation / Apply
12. Verification
13. ce-compound
14. Archive Task Artifacts
15. Learning Update Question

## Directory Layout

```text
<project-root>/
  AGENTS.md
  README.md
  CONTEXT.md
  handoff.md
  harness/docs/agents/
  harness/docs/adr/
  harness/docs/solutions/
  harness/docs/tasks/active/<slug>/
  harness/docs/tasks/archive/<slug>/
  harness/rules/workflow.md
  harness/rules/rules.md
  harness/rules/module-types.md
  harness/state/intake.md
  harness/state/planning.md
  harness/state/module-structure.md
  harness/state/compound.md
  module-template/
  proposals/
  modules/
```

## Rules That Matter

1. 설치 대상 폴더 자체가 하네스 루트입니다. 예: `F:/mptech`
2. `F:/mptech/jjamppong-harness/`처럼 하네스를 중첩 설치하지 않습니다.
3. 실제 프로젝트 root의 `origin`은 project repository를 가리켜야 합니다. 예: `https://github.com/vibedong/mptech.git`
4. 프로젝트 설정 이후의 실질 작업은 `main`이 아니라 `task/<task-slug>` 브랜치에서 시작합니다.
5. `git commit`, `git push`, PR 생성, merge, release는 현재 채팅에서 사용자가 명시 승인해야만 실행합니다.
6. 실제 제품 코드는 하네스 루트의 `modules/` 아래에만 작성합니다.
7. `modules/` 아래에는 `harness/state/module-structure.md`가 승인된 뒤에만 코드를 만듭니다.
8. PRD 초안과 issue 분해는 각각 사용자 승인을 받은 뒤 다음 단계로 넘어갑니다.
9. 구현 전에는 Mandatory Plan Review Question을 거칩니다.
10. 검증 전에는 완료라고 말하지 않습니다.
11. `handoff.md`는 사용자가 요청할 때만 next-chat context로 갱신합니다.
12. 새 규칙 아이디어는 바로 live rule을 바꾸지 않고 `proposals/`에서 검토합니다.

## Sharing With A Friend

이 저장소는 private template입니다. 친구에게 링크만 보내면 볼 수 없습니다.

친구와 함께 쓰려면 둘 중 하나를 선택합니다.

### Template 자체를 같이 관리할 때

`vibedong/jjamppong-harness`에 친구를 collaborator로 초대합니다.

추천 권한:

```text
Write
```

### 실제 프로젝트만 같이 만들 때

이 template에서 `mptech` 같은 실제 project repository를 만든 뒤, 그 project repository에 친구를 초대합니다.

보통은 이 방식이 더 안전합니다. template 원본은 그대로 두고, 실제 프로젝트 루트의 `modules/`에서만 같이 작업할 수 있기 때문입니다.

## Troubleshooting

### 친구가 저장소를 못 봅니다

private 저장소라서 권한이 없으면 볼 수 없습니다. collaborator로 초대했는지 확인하세요.

### Codex가 바로 코드를 만들려고 합니다

`AGENTS.md`, `harness/rules/workflow.md`, `harness/rules/rules.md`를 먼저 읽게 하세요.

```text
이 저장소의 AGENTS.md와 harness/rules를 먼저 읽고,
Full Workflow대로 진행해줘.
```

### F:/mptech/jjamppong-harness 아래에 생겼습니다

한 단계 깊게 들어간 상태입니다. 원하는 구조는 `F:/mptech/AGENTS.md`와 `F:/mptech/modules/`가 바로 보이는 형태입니다.

새로 만들 때는 project repository 이름을 `mptech`로 만들고 `F:/`에서 clone하거나, Codex에게 중첩하지 말고 `F:/mptech` 바로 아래에 하네스 파일을 두라고 말하세요.

### origin이 template source를 가리킵니다

프로젝트 root로 쓰려면 아직 완료된 상태가 아닙니다. `mptech` 같은 프로젝트 전용 private repository를 만들고 origin을 그쪽으로 바꿔야 합니다.

예:

```powershell
gh repo create vibedong/mptech --private
git -C 'F:/mptech' remote set-url origin https://github.com/vibedong/mptech.git
git -C 'F:/mptech' push -u origin main
```

그 뒤 `git -C 'F:/mptech' remote -v`가 `vibedong/mptech.git`를 보여야 합니다.

### modules에 바로 코드를 만들어도 되나요?

아니요. 먼저 `harness/state/module-structure.md`에 module 구조가 승인되어야 합니다.

### handoff.md는 언제 바꾸나요?

새 채팅으로 이어가고 싶을 때만 바꿉니다.

예:

```text
여기까지 새 채팅용으로 저장해줘
```

## Maintaining The Template

template 원본을 고칠 때는 `vibedong/jjamppong-harness`를 clone한 template-maintenance checkout에서 작업합니다.

실제 프로젝트를 만들 때는 이 template 원본을 `F:/mptech/jjamppong-harness`로 clone하지 않습니다. `F:/mptech` 자체가 project repository이자 harness root가 되게 만듭니다.

```powershell
git status --short --branch
```

이미 template에서 만들어진 project root에는 변경사항이 자동으로 반영되지 않습니다. 필요한 변경은 각 project repository에서 따로 반영합니다.

## One-Line Summary

짬뽕하네스는 대상 프로젝트 폴더 자체에 설치되는 private harness template이며, 실제 제품 코드는 그 폴더의 `modules/` 아래에서 시작합니다.
