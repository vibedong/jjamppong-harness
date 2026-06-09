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

## 권한 모델

권한 판단은 event receipt가 아니라 현재 상태와 승인 문서로 한다.

- 구현 전에는 `implementation-approval.md`가 있어야 한다.
- 승인 문서에는 허용 작업, 금지 작업, 파일 범위, 테스트 범위, 네트워크/패키지/commit/push 여부가 명시되어야 한다.
- `task.yaml`은 현재 gate와 승인 상태를 요약하지만, 애매할 때는 사람용 승인 문서가 우선한다.
- 사용자의 짧은 반응은 자동으로 넓은 승인으로 해석하지 않는다. 승인 범위가 불명확하면 구현 전에 다시 좁혀 묻는다.

## verify/doctor 변경

`verify`는 원장 검사가 아니라 워크플로우 상태 검사로 바꾼다.

검사할 것:

- active task가 하나인지
- `task.yaml`의 current gate가 실제 문서 상태와 맞는지
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

## Compound Engineering

Compound Engineering은 제거하지 않는다. 다만 코어 startup context가 아니다.

트리거는 사용자가 직접 관리하는 모드가 아니라 하네스가 감지하는 사건이다.

예시:

- 같은 하네스 오해가 반복됨
- 사용자가 AI 흐름을 다시 잡아줌
- verify/doctor가 workflow drift를 감지함
- 설치, 승인, handoff 같은 운영 실수가 반복됨

이때 기록은 `learning-capture.md`와 `compound-review.md` 같은 사람이 읽는 문서에 남긴다. 장기 반영이 승인된 내용만 `harness/docs/solutions/`로 승격한다.

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

## 성공 기준

- 새 작업 시작 시 AI가 읽는 기본 컨텍스트가 작다.
- grill 단계가 긴 원장 로그 때문에 막히지 않는다.
- 사용자는 `task.yaml`, planning 문서, approval, verification, handoff만 이해하면 된다.
- 구현 전 승인 gate는 유지된다.
- Compound Engineering은 유지되지만 평소 시작 컨텍스트에는 들어가지 않는다.
- `events.jsonl` 없이도 install, verify, doctor, task progression이 동작한다.
