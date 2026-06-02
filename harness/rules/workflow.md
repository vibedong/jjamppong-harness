# Workflow

## Full Workflow

Every substantive task follows this workflow. There is no task-size bypass unless the user explicitly changes the harness rules in a later approved proposal.

1. Request Intake
2. setup-matt-pocock-skills Readiness Check
3. Grill Routing And Completion Gate
4. Grill Result Record
5. Module Structure Gate
6. to-prd
7. User PRD Approval
8. to-issues
9. User Issue Approval
10. Task Brief
11. Superpowers Writing Plans
12. Mandatory Plan Review Question
13. Implementation / Apply
14. Verification
15. ce-compound
16. Archive Task Artifacts
17. Learning Update Question

The Module Structure Gate is active only when the request may create or change product module folders or product code. For non-module work, record it as not applicable and continue without asking module-structure questions.

## Request Intake

Restate the user's request in simple language and record the current interpretation in `harness/state/intake.md`.

## Matt Pocock Planning Gate

Every task uses Matt Pocock planning skills before implementation.

1. Verify `setup-matt-pocock-skills` output exists.
2. Run the Grill Routing And Completion Gate.
3. Record the grill route and results in `harness/docs/tasks/active/<slug>/grill.md`.
4. Run the Module Structure Gate when the request may create or change product module folders or product code.
5. Produce `harness/docs/tasks/active/<slug>/prd.md` with `to-prd`.
6. Stop and ask the user to approve or revise the PRD before issue decomposition.
7. Decompose the approved PRD into `harness/docs/tasks/active/<slug>/issues/001-*.md` with `to-issues`.
8. Stop and ask the user to approve or revise issue granularity, dependency order, and HITL/AFK classification before writing the implementation plan.
9. Produce `harness/docs/tasks/active/<slug>/brief.md`.

No task may skip this gate because it appears small.

### Grill Routing And Completion Gate

Choose the grilling skill from the request shape:

- Use `grill-with-docs` when existing code, docs, candidate lists, domain glossary, ADRs, or prior implementations can answer or sharpen the user's request.
- Use `grill-me` when the request is greenfield, product-intent driven, or lacks enough existing project evidence.
- If both apply, inspect existing code/docs first with `grill-with-docs`, then use `grill-me` only for remaining user-intent uncertainties.

Completion rules:

- Ask one question at a time.
- Wait for the user's answer before continuing to the next user-facing question.
- If code or docs can answer a question, inspect those instead of asking the user.
- Do not ask duplicate questions that the inspected evidence already answered.
- Record the selected grill route, inspected evidence, answered questions, deferred unknowns, and remaining user decisions in `harness/docs/tasks/active/<slug>/grill.md`.
- Do not run `to-prd`, write issue breakdowns, decide module structure, create module folders, or write product code until core uncertainties are resolved or explicitly deferred by the user.

### Grill Result Record

Before `to-prd`, write `harness/docs/tasks/active/<slug>/grill.md`.

The file must include:

- Selected route: `grill-with-docs`, `grill-me`, or `grill-with-docs then grill-me`.
- Evidence inspected: code paths, docs, candidate lists, domain glossary, ADRs, prior implementations, or "none found".
- Questions answered from evidence.
- Questions asked to the user.
- User answers.
- Deferred unknowns explicitly accepted by the user.
- Remaining decisions that still block PRD, issues, module structure, writing plan, or implementation.
- Gate status: `complete`, `blocked`, or `deferred by user`.

If a question was answerable from evidence, do not ask it again in user-facing prose.

### Module Structure Gate

Run this gate before creating or changing product module folders.

If the request cannot create or change product module folders or product code, record `Module Structure Gate: not applicable` in `harness/docs/tasks/active/<slug>/grill.md` and do not ask module-structure questions.

If `modules/` is empty or `harness/state/module-structure.md` says no module structure is approved:

1. Stop before creating module folders or product code.
2. Explain in plain language that the project has no approved module structure yet.
3. Propose two or three module structure options based on the resolved grilling context.
4. Give one recommendation with reasoning.
5. Ask the user to approve or revise the module structure.
6. Record approved module types, folder sets, active modules, deferred modules, and extra folders in `harness/state/module-structure.md`.

Only after this record exists may Codex create product folders under `modules/`.

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
