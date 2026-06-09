# Ledgerless Workflow Core Design

## 결정

짬뽕하네스의 코어 목표는 모든 행동을 감사 원장으로 재생하는 것이 아니라, AI가 사용자와 합의한 워크플로우를 빠뜨리지 않고 따르게 하는 것이다.

따라서 `events.jsonl`, `gate-ledger.md`, `artifact_read`, `artifact_written`, event hash chain은 코어 권한 모델에서 제거한다.

## 문제

현재 하네스는 `events.jsonl`을 canonical log로 두고, 각 gate마다 read/write receipt와 SHA-256 hash를 검사한다. 이 구조는 감사 가능성은 높이지만 다음 문제가 있다.

- 새 채팅 시작과 grill 단계에서 불필요한 컨텍스트가 커진다.
- 사용자가 이해해야 하는 파일과 개념이 많아진다.
- `verify`와 `doctor`가 실제 워크플로우 실패보다 원장 보정 문제를 더 자주 드러낸다.
- AI가 “무엇을 해야 하는가”보다 “어떤 이벤트를 남겨야 하는가”에 토큰을 쓰게 된다.

사용자의 실제 목표는 workflow adherence이다. 즉, 바로 구현하지 않고 질문, 기획, 승인, 실행, 검증 순서를 지키게 하는 것이다.

## 새 코어 표면

일반 작업에서 AI가 읽고 갱신해야 하는 표면은 아래로 제한한다.

```text
task.yaml
planning/00-current-planning-context.md
planning/01-grill-summary.md
planning/02-research-summary.md
planning/03-prd.md
planning/04-issues.md
planning/05-module-structure.md
planning/06-writing-plan.md
planning/07-plan-review.md
implementation-approval.md
verification.md
handoff.md
```

`task.yaml`은 현재 단계, 승인 상태, 다음 액션을 담는 machine-readable 상태 파일이다.

`planning/00-current-planning-context.md`는 새 채팅과 handoff가 읽는 짧은 현재 요약이다.

나머지 planning 문서는 각 단계의 사람이 읽는 산출물이다. 사람용 문서는 기본적으로 사용자 언어로 작성한다.

## Hot-read 원칙

문서가 존재한다는 것과 항상 읽어야 한다는 것은 다르다.

일반 시작, handoff 이어가기, grill 질문 준비에서 AI가 hot-read로 읽는 표면은 아래로 제한한다.

```text
1. AGENTS.md와 harness/rules/workflow.md
2. active task의 task.yaml
3. planning/00-current-planning-context.md 또는 현재 gate 문서 하나
```

과거 gate 문서 전체, 큰 research 결과, plan review 전문, legacy archive는 시작 컨텍스트가 아니다.

크기 목표:

- 기본 시작 컨텍스트는 작게 유지한다. `AGENTS.md`, `workflow.md`, `task.yaml`, `planning/00-current-planning-context.md` 합산이 과하게 커지면 verify가 경고한다.
- `planning/00-current-planning-context.md`는 현재 결정, 미결정, 다음 액션만 담는다. 전체 대화 전문을 누적하지 않는다.
- `planning/01-grill-summary.md`는 질문/답변 원문 저장소가 아니라 결정, 미결정, 사용자 답변 요약을 담는다.
- `handoff.md`는 다음 채팅 시작에 필요한 최소 문맥과 붙여넣을 문구를 담는다.

## 권한 모델

권한 판단은 event receipt가 아니라 현재 상태와 승인 문서로 한다.

- 구현 전에는 `implementation-approval.md`가 있어야 한다.
- 승인 문서에는 허용 작업, 금지 작업, 파일 범위, 테스트 범위, 네트워크/패키지/commit/push 여부가 명시되어야 한다.
- `task.yaml`은 현재 gate, 승인 상태, 다음 액션, 수정 가능 범위만 요약한다. 과거 히스토리를 담지 않는다.
- `implementation-approval.md`는 사람용 승인 근거이고, `task.yaml`은 machine-readable 승인 요약이다. 둘이 어긋나면 구현을 멈추고 사용자 확인을 요구한다.
- 사용자의 짧은 반응은 자동으로 넓은 승인으로 해석하지 않는다. 승인 범위가 불명확하면 구현 전에 다시 좁혀 묻는다.

`implementation-approval.md`는 최소한 아래 항목을 포함한다.

```text
승인 질문
사용자 답변 요약
허용 작업
금지 작업
파일 범위
테스트 범위
network/package install/live access 허용 여부
commit/push 허용 여부
승인 만료 또는 철회 조건
```

`좋아`, `ㅇ`, `그래` 같은 짧은 답변은 직전 메시지가 구현 승인 질문일 때만 구현 승인으로 본다. 그 외에는 대화 진행 의사일 뿐, 삭제, 설치, package install, live access, commit, push 승인으로 보지 않는다.

## verify/doctor 변경

`verify`는 원장 검사가 아니라 워크플로우 상태 검사로 바꾼다.

검사할 것:

- active task가 하나인지
- `task.yaml`의 current gate가 허용 enum인지
- 현재 gate에 필요한 산출물이 존재하는지
- 구현 승인 없이 product code가 변경되지 않았는지
- `implementation-approval.md`가 필요한 권한 항목을 명확히 적었는지
- `verification.md`가 실제 검증 결과를 담는지
- handoff가 있을 때 다음 채팅용 문구가 포함되는지
- 핵심 context 문서가 과하게 커지지 않았는지

검사하지 않을 것:

- `events.jsonl` 존재 여부
- event hash chain
- `artifact_read` receipt
- `artifact_written` receipt
- `gate-ledger.md` projection 일치 여부

`doctor`는 자동으로 큰 수정을 하지 않는다. 진단과 제안까지가 기본 동작이다. 상태 파일 수정, migration, archive 정리는 사용자가 명시적으로 승인했을 때만 수행한다.

## Legacy task 정책

기존 ledger 기반 task가 남아 있을 수 있다. 새 코어는 이를 일반 시작 컨텍스트로 읽지 않는다.

정책:

- legacy `events.jsonl`과 `gate-ledger.md`는 read-only archive로 취급한다.
- 새 task 생성 시 `events.jsonl`, `gate-ledger.md`, `events.jsonl.template`을 만들지 않는다.
- migration이 필요하면 별도 승인된 작업으로 처리한다.
- 구현 테스트에서 `events.jsonl` 금지 검사는 live harness surface에만 적용한다. 과거 `docs/superpowers/plans/*` 같은 historical docs는 실패 근거로 삼지 않는다.

Live harness surface:

```text
AGENTS.md
README.md
CONTEXT.md
harness/**
module-template/**
tests/**
```

## Compound Engineering

Compound Engineering은 제거하지 않는다. 다만 코어 startup context가 아니다.

트리거는 사용자가 직접 관리하는 모드가 아니라 하네스가 감지하는 사건이다.

예시:

- 같은 하네스 오해가 반복됨
- 사용자가 AI 흐름을 다시 잡아줌
- verify/doctor가 workflow drift를 감지함
- 설치, 승인, handoff 같은 운영 실수가 반복됨

이때 기록은 `learning-capture.md`와 `compound-review.md` 같은 사람이 읽는 문서에 남긴다. 장기 반영이 승인된 내용만 `harness/docs/solutions/`로 승격한다.

Compound Engineering은 startup, permission, verify, implementation gate의 필수 입력이 아니다.

Compound 진입은 아래 조건 중 하나가 있을 때만 한다.

- 사용자가 `기록해둬`, `재발방지`, `컴파운드`처럼 명시한다.
- verify/doctor가 같은 workflow drift를 반복 감지한다.
- 사용자가 같은 흐름을 두 번 이상 바로잡는다.

## 예상 사용자 흐름

```text
1. 사용자가 작업을 요청한다.
2. AI가 AGENTS.md와 workflow.md를 읽는다.
3. active task가 없으면 task.yaml과 planning context를 만든다.
4. 바로 구현하지 않고 grill 질문을 시작한다.
5. 필요한 경우 research를 한다.
6. PRD, issue, module structure, writing plan을 만든다.
7. plan review를 한다.
8. 구현 전 approval을 다시 묻고 implementation-approval.md를 쓴다.
9. 승인 범위만 구현한다.
10. verification.md를 작성하고 verify를 실행한다.
11. handoff가 필요하면 handoff.md와 다음 채팅용 입력 문구를 출력한다.
```

## 비목표

- 완전한 감사 원장 시스템
- 모든 읽기/쓰기의 cryptographic proof
- 과거 작업 재생
- 사용자가 이해하기 어려운 gate ledger 관리
- 시작할 때 큰 로그를 읽는 구조
- `task.yaml`에 과거 히스토리를 쌓아 작은 원장을 재발명하는 구조

## 구현 순서

구현은 README나 AGENTS부터 시작하지 않는다. 옛 원장 모델과 새 ledgerless 모델이 공존하지 않도록 아래 순서로 진행한다.

```text
1. contracts/schema 정리
2. ledgerless 실패 테스트 작성
3. lifecycle/templates에서 events.jsonl/gate-ledger 생성 제거
4. PermissionDecision을 task.yaml + implementation-approval.md 기준으로 변경
5. verify/doctor를 workflow 상태 검사로 단순화
6. rules/workflow/AGENTS/README를 새 모델로 정리
7. installer, verify, doctor, 새 task 생성 시나리오 검증
```

## 성공 기준

- 새 작업 시작 시 AI가 읽는 기본 컨텍스트가 작다.
- grill 단계가 긴 원장 로그 때문에 막히지 않는다.
- 사용자는 `task.yaml`, planning 문서, approval, verification, handoff만 이해하면 된다.
- 구현 전 승인 gate는 유지된다.
- Compound Engineering은 유지되지만 평소 시작 컨텍스트에는 들어가지 않는다.
- `events.jsonl` 없이도 install, verify, doctor, task progression이 동작한다.
- 새 task 생성 결과에 `events.jsonl`과 `gate-ledger.md`가 없다.
- ledger 제거 검사는 live harness surface에만 적용하고 historical docs 때문에 실패하지 않는다.
