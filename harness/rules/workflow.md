# Workflow

## Full Workflow

Every substantive task follows this workflow unless the user explicitly requests a Short Loop.

1. Request Intake
2. OuroSuper Planning
3. Superpowers Writing Plans
4. Mandatory Plan Review Question
5. Implementation / Apply
6. Verification
7. ce-compound
8. Learning Update Question
9. Optional Handoff Update

## Request Intake

Restate the user's request in simple language and record the current interpretation in `harness/state/intake.md`.

## OuroSuper Planning

Use OuroSuper for implementation-affecting planning. The expected flow is interview, seed, and handoff packet.

Store outputs under:

```text
harness/state/ourosuper/
```

## Superpowers Writing Plans

Use `superpowers:writing-plans` after OuroSuper produces a ready handoff.

Store the plan under:

```text
harness/state/superpowers/plan.md
```

## Mandatory Plan Review Question

After writing the plan, do not move directly into implementation. Ask this exact question:

```text
구현으로 넘어가기 전에 리뷰를 실행할까요?

추천: CEO/제품전략 리뷰와 엔지니어링 리뷰를 둘 다 실행합니다.

A. 둘 다 실행
B. 엔지니어링 리뷰만 실행
C. 이번에는 생략
```

If the user chooses `C`, say this exact Korean warning first:

```text
리뷰를 생략하면 범위를 잘못 잡거나, 검증이 약해지거나, 나중에 다시 고칠 가능성이 커집니다. 그래도 구현으로 진행할까요?
```

Then record the skip reason in `harness/state/superpowers/reviews.md` and continue only after the user explicitly confirms implementation can proceed.

Store review output and reflection notes under:

```text
harness/state/superpowers/reviews.md
```

## Implementation / Apply

Use the Superpowers implementation flow defined in `harness/rules/rules.md`.

In a project harness root, product or project code belongs under `modules/` only after the approved module structure allows it.

## Verification

Use fresh verification evidence before claiming completion.

Store verification notes under:

```text
harness/state/verification/report.md
```

## ce-compound

Run Compound Engineering `ce-compound` after verification. Store long-lived learning documents under:

```text
docs/solutions/
```

Record only links and status under:

```text
harness/state/compound.md
```

## Learning Update Question

After `ce-compound`, ask this exact question:

```text
ce-compound 결과에서 다음 프로젝트에도 재사용할 배움이 있나요?

A. `docs/solutions/` 학습 문서를 추가하거나 갱신
B. `proposals/`에 새 규칙 제안 작성
C. 배움 없음
```

Do not change live rules from `ce-compound` output without user approval.

## Optional Handoff Update

Update `handoff.md` only when the user explicitly asks for next-chat handoff.

## Short Loop Exception

Short Loop is allowed only when the user explicitly says the task is small, asks to skip planning, or asks for a direct edit.

Codex must not decide on its own that a task is small.

Short Loop still requires:

1. Request confirmation
2. Change
3. Verification
4. Result report
