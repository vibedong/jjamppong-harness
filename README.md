# OuroSuper Harness

Codex가 새 프로젝트를 시작할 때 바로 코딩부터 하지 않도록 잡아주는 private project template입니다.

`ourosuper-harness`는 제품 코드가 들어가는 저장소가 아닙니다. ERP, CRM, 업무 자동화 도구 같은 실제 프로젝트는 이 template에서 새 private 저장소를 만든 뒤 그 저장소에서 시작합니다.

## Table Of Contents

- [Why](#why)
- [What This Gives You](#what-this-gives-you)
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

OuroSuper Harness는 이 문제를 줄이기 위해 Codex가 항상 같은 순서로 움직이게 합니다.

## What This Gives You

- 새 프로젝트용 private template
- Codex가 따라야 할 workflow 규칙
- 요청 정리, 기획, 계획, 검증 상태를 저장할 위치
- module 구조를 승인 전까지 막는 안전장치
- 다음 채팅용 handoff 파일
- 반복해서 쓸 수 있는 학습 문서 위치

## Requirements

사용자는 아래 준비가 필요합니다.

- GitHub 계정
- 이 private template 저장소에 접근할 권한
- Git
- GitHub CLI, 선택 사항이지만 추천
- Codex 앱
- Codex에서 사용할 workflow 도구
  - OuroSuper
  - Superpowers
  - Compound Engineering `ce-compound`

GitHub CLI 없이도 GitHub 웹사이트의 **Use this template** 버튼으로 사용할 수 있습니다.

## Installation

이 프로젝트의 "설치"는 npm package처럼 설치하는 것이 아닙니다.

이 template에서 새 private project repository를 만드는 것이 설치입니다.

### Option A: GitHub Website

1. `vibedong/ourosuper-harness` 저장소를 엽니다.
2. **Use this template**을 누릅니다.
3. 새 repository name을 정합니다. 예: `erp-system`
4. visibility는 **Private**로 둡니다.
5. 생성된 저장소를 로컬에 clone합니다.

추천 로컬 위치:

```text
F:/Folder/projects/<project-name>
```

### Option B: GitHub CLI

```powershell
New-Item -ItemType Directory -Force -Path 'F:/Folder/projects' | Out-Null
Push-Location 'F:/Folder/projects'
gh repo create <project-name> --private --template vibedong/ourosuper-harness --clone
Pop-Location
```

예:

```powershell
New-Item -ItemType Directory -Force -Path 'F:/Folder/projects' | Out-Null
Push-Location 'F:/Folder/projects'
gh repo create erp-system --private --template vibedong/ourosuper-harness --clone
Pop-Location
```

## Quick Start

새 프로젝트 저장소를 만든 뒤, Codex에서 생성된 프로젝트 폴더를 엽니다.

예:

```text
F:/Folder/projects/erp-system
```

그 다음 Codex에게 이렇게 말합니다.

```text
ERP 프로젝트 만들고 싶어.
먼저 harness/state/intake.md에 요청을 정리하고,
OuroSuper 기획부터 시작해줘.
```

또는 template에서 프로젝트 생성까지 Codex에게 맡길 때는 이렇게 말합니다.

```text
private 프로젝트로 <project-name> 만들어줘.
템플릿은 ourosuper-harness를 쓰고,
F:/Folder/projects/<project-name> 아래에서 시작해줘.
```

## How It Works

Codex는 실제 구현 전에 아래 흐름을 따릅니다.

```text
Request Intake
-> OuroSuper Planning
-> Superpowers Writing Plans
-> Mandatory Plan Review Question
-> Implementation / Apply
-> Verification
-> ce-compound
-> Learning Update Question
-> Optional Handoff Update
```

한국어로 보면 이렇게 생각하면 됩니다.

```text
요청 정리
-> 기획
-> 구현 계획 작성
-> 구현 전 리뷰 질문
-> 구현
-> 검증
-> 배운 점 정리
-> 다음 프로젝트에 반영할지 질문
-> 필요할 때만 handoff 갱신
```

## Directory Layout

```text
harness/
  rules/
    workflow.md          Codex가 따르는 전체 workflow
    rules.md             필수 스킬, 검증, proposal 규칙
    module-types.md      module 구조를 정하는 방법

  state/
    intake.md            현재 요청 정리
    module-structure.md  승인된 module 구조
    compound.md          ce-compound 결과 링크와 상태
    ourosuper/           OuroSuper 산출물
    superpowers/         Superpowers 계획/리뷰 산출물
    verification/        검증 결과

docs/
  solutions/             재사용 가능한 학습 문서

module-template/         새 module을 만들 때 복사하는 기본 템플릿
proposals/               승인 전 harness/workflow 변경 제안
modules/                 실제 프로젝트에서 제품 코드가 들어가는 곳
handoff.md               새 채팅용 인수인계 파일
AGENTS.md                Codex가 먼저 읽는 작업 규칙
```

## Rules That Matter

가장 중요한 규칙은 이렇습니다.

1. `ourosuper-harness` 원본 저장소에는 제품 코드를 만들지 않습니다.
2. 실제 제품 코드는 template에서 만든 새 project repository에만 작성합니다.
3. `modules/` 아래에는 `harness/state/module-structure.md`가 승인된 뒤에만 코드를 만듭니다.
4. 구현 전에는 계획 리뷰 질문을 거칩니다.
5. 검증 전에는 완료라고 말하지 않습니다.
6. `handoff.md`는 사용자가 요청할 때만 갱신합니다.
7. 새 규칙 아이디어는 바로 live rule을 바꾸지 않고 `proposals/`에서 검토합니다.

## Sharing With A Friend

이 저장소는 private template입니다. 친구에게 링크만 보내면 볼 수 없습니다.

친구와 함께 쓰려면 둘 중 하나를 선택합니다.

### Template 자체를 같이 관리할 때

`vibedong/ourosuper-harness`에 친구를 collaborator로 초대합니다.

추천 권한:

```text
Write
```

### 실제 프로젝트만 같이 만들 때

이 template에서 새 private project repository를 만든 뒤, 그 project repository에 친구를 초대합니다.

보통은 이 방식이 더 안전합니다. template 원본은 그대로 두고, 실제 프로젝트만 같이 작업할 수 있기 때문입니다.

## Troubleshooting

### 친구가 저장소를 못 봅니다

private 저장소라서 권한이 없으면 볼 수 없습니다. collaborator로 초대했는지 확인하세요.

### Codex가 바로 코드를 만들려고 합니다

`AGENTS.md`, `harness/rules/workflow.md`, `harness/rules/rules.md`를 먼저 읽게 하세요.

```text
이 저장소의 AGENTS.md와 harness/rules를 먼저 읽고,
Full Workflow대로 진행해줘.
```

### modules에 바로 코드를 만들어도 되나요?

아니요. 먼저 `harness/state/module-structure.md`에 module 구조가 승인되어야 합니다.

### handoff.md는 언제 바꾸나요?

새 채팅으로 이어가고 싶을 때만 바꿉니다.

예:

```text
여기까지 새 채팅용으로 저장해줘
```

## Maintaining The Template

template 원본을 고칠 때는 `F:/Folder/ourosuper-harness`에서 작업합니다.

```powershell
git -C 'F:/Folder/ourosuper-harness' status --short --branch
git -C 'F:/Folder/ourosuper-harness' add README.md
git -C 'F:/Folder/ourosuper-harness' commit -m 'docs: update README'
git -C 'F:/Folder/ourosuper-harness' push origin main
```

이미 template에서 만들어진 프로젝트에는 변경사항이 자동으로 반영되지 않습니다. 필요한 변경은 각 project repository에서 따로 반영합니다.

## One-Line Summary

OuroSuper Harness는 실제 제품을 담는 저장소가 아니라, 실제 제품 저장소를 안전하게 시작하기 위한 private template입니다.
