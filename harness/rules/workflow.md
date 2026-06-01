# Workflow

## Full Workflow

Every substantive task follows this workflow. There is no task-size bypass unless the user explicitly changes the harness rules in a later approved proposal.

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

## Request Intake

Restate the user's request in simple language and record the current interpretation in `harness/state/intake.md`.

## Matt Pocock Planning Gate

Every task uses Matt Pocock planning skills before implementation.

1. Verify `setup-matt-pocock-skills` output exists.
2. Run `grill-with-docs`.
3. Produce `harness/docs/tasks/active/<slug>/prd.md` with `to-prd`.
4. Stop and ask the user to approve or revise the PRD before issue decomposition.
5. Decompose the approved PRD into `harness/docs/tasks/active/<slug>/issues/001-*.md` with `to-issues`.
6. Stop and ask the user to approve or revise the issue breakdown before writing the implementation plan.
7. Produce `harness/docs/tasks/active/<slug>/brief.md`.

No task may skip this gate because it appears small.

## Superpowers Writing Plans

Use `superpowers:writing-plans` after the Matt Pocock planning gate is approved.

Store the plan under:

```text
harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/writing-plan.md
```

## Mandatory Plan Review Question

Before implementation, ask whether to run plan review.

Default recommendation:

```text
구현 전에 계획 리뷰를 실행할까요?

추천: 일반 작업은 CEO/제품전략 리뷰와 엔지니어링 리뷰를 둘 다 실행합니다.

하네스 규칙, workflow, 설치 방식, artifact topology를 바꾸는 작업은 Plan Compliance 리뷰도 함께 실행합니다.

A. CEO + Eng + Plan Compliance
B. CEO + Eng
C. Eng only
D. 이번에는 생략
```

Record the user's choice and review results in:

`harness/docs/tasks/active/<slug>/reviews.md`

If the user chooses D, warn once:

```text
리뷰를 생략하면 범위 오판, 누락된 검증, 재작업 가능성이 커집니다. 그래도 구현으로 진행할까요?
```

If the user still chooses to proceed, write the skipped reason in `reviews.md`.

## Implementation / Apply

Use the Superpowers implementation flow defined in `harness/rules/rules.md`.

In a project harness root, product or project code belongs under `modules/` only after the approved module structure allows it.

## Verification

Before claiming completion, use `superpowers:verification-before-completion`.

Record commands, expected output, actual output summary, and unresolved risk in:

`harness/docs/tasks/active/<slug>/verification.md`

Negative `rg` checks must treat exit code 1 as success when the expected result is "no matches".

## ce-compound

After verification, run Compound Engineering learning capture.

Reusable learning belongs under:

`harness/docs/solutions/`

Do not store reusable learning under `harness/state/`.

## Global Handoff

Root `handoff.md` is only for next-chat/context transfer.

Task-specific summaries belong in:

`harness/docs/tasks/active/<slug>/brief.md`

## Archive Task Artifacts

After verification and ce-compound, move the task folder from `harness/docs/tasks/active/<slug>/` to `harness/docs/tasks/archive/<slug>/` unless the user explicitly chooses to keep it active or delete it.

Do not delete task artifacts by default.

## Learning Update Question

After `ce-compound`, ask this exact question:

```text
이번 작업에서 다음 프로젝트에도 재사용할 만한 배움이 있나요?
있다면 harness/docs/solutions/ 아래에 짧게 기록할까요?
```

Do not change live rules from `ce-compound` output without user approval.
