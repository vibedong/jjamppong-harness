# Harness Rules

## 1. Full Workflow Is The Default

All substantive work follows the Full Workflow in `harness/rules/workflow.md`.

Examples of substantive work:

- New project setup
- New feature
- New module
- Module type or folder standard changes
- Project structure changes
- Harness rule changes
- Important technical choices
- User workflow changes

## 2. Required Plugins And Skills

Use the required plugin or skill at each stage.

```text
Matt Pocock Planning Gate
  Verify setup-matt-pocock-skills readiness.
  Run Grill Routing And Completion Gate.
  Use grill-with-docs when existing code/docs/candidate lists/domain docs can sharpen the request.
  Use grill-me when the request is greenfield or mostly product-intent driven.
  Ask one user-facing question at a time and wait for the user's answer.
  Do not ask duplicate user-facing questions for facts already answered by inspected code/docs.
  Record grill route, inspected evidence, answered questions, deferred unknowns, and remaining decisions in harness/docs/tasks/active/<slug>/grill.md.
  Run Module Structure Gate before product PRD, issue decomposition, writing plans, product module folders, or product code when no module structure is approved.
  For non-module work, record Module Structure Gate as not applicable and do not ask module-structure questions.
  Use to-prd only after the grill gate has resolved or explicitly deferred core uncertainties.
  Stop for User PRD Approval.
  Use to-issues.
  Stop for User Issue Approval, including issue granularity, dependency order, and HITL/AFK classification.
  Write the task brief.

Superpowers Writing Plans
  Use superpowers:writing-plans.
  Store the plan at harness/docs/tasks/active/<slug>/writing-plan.md.

gstack Review
  Use plan-ceo-review and plan-eng-review for normal Mandatory Plan Review.
  Add a Plan Compliance reviewer for harness rules, workflow, installation, or artifact topology changes.
  Store selected option, reviewers, findings, user decisions, and skipped reason in harness/docs/tasks/active/<slug>/reviews.md.

Implementation / Apply
  If the worktree already has uncommitted safety-rule edits, continue sequentially in the current worktree for this plan.
  Use superpowers:using-git-worktrees first only when the current worktree is clean or the plan baseline has been revised after user-approved protection/isolation.
  Use superpowers:subagent-driven-development by default.
  Use superpowers:executing-plans only when subagents are not available or the user asks for a separate execution session.
  Use superpowers:test-driven-development for features, bug fixes, behavior changes, and refactoring.
  Use superpowers:systematic-debugging before fixing bugs, failing tests, build failures, or unexpected behavior.
  Use superpowers:requesting-code-review for major work and review checkpoints.

Verification
  Use superpowers:verification-before-completion before claiming completion.
  Store verification at harness/docs/tasks/active/<slug>/verification.md.

Compound Engineering
  Use ce-compound after verification.
  Store reusable learning under harness/docs/solutions/.
```

If a required plugin or skill is unavailable, stop and tell the user. Do not silently replace it with an informal flow.

## 3. Plan Review Question Is Mandatory

After `superpowers:writing-plans`, use the exact Mandatory Plan Review Question in `harness/rules/workflow.md`.

Store review choice, reviewer names, findings, user decisions, and skipped-review reasons in:

```text
harness/docs/tasks/active/<slug>/reviews.md
```

Do not implement before this question is answered.

## 4. No Inferred Gate Approval

Do not open a workflow gate by implication.

A gate opens only when the user's response clearly answers the immediately preceding explicit gate question. Recommendations, summaries, silence, topic changes, adjacent technical discussion, or artifact existence do not approve a gate.

If the response is ambiguous, choose the narrower interpretation and keep later stages locked.

## 5. No Implicit Deferrals

Unknowns are blockers unless resolved or explicitly deferred.

An unknown may be marked deferred only when the user explicitly defers that named unknown. A general direction approval, module structure approval, PRD approval, issue approval, or plan approval does not approve deferred unknowns.

Each deferred unknown must record:

- Unknown
- User quote approving deferral
- Why it is non-blocking now
- Revisit stage

## 6. Stage Unlocks Require Ledger Evidence

Before entering a stage, verify the task gate ledger contains the matching approval entry:

| Stage | Required task-local ledger entry |
| --- | --- |
| product/module PRD drafting | `Gate id: module_structure` and `Status: approved` or `Status: existing-approved` |
| non-product/non-module PRD drafting | `Gate id: module_structure` and `Status: not-applicable` |
| issue decomposition | `Gate id: prd` and `Status: approved` |
| task brief and writing-plan | `Gate id: issues` and `Status: approved` |
| implementation | `Gate id: plan_review` and `Status: completed` |

No matching ledger entry means the stage is still locked.

## 7. Planning Write Boundary

Before `Gate id: plan_review` with `Status: completed` is recorded, writes are limited to planning, state, review, and verification artifacts allowed by the current stage.

Allowed before implementation:

- Intake/Grill: `harness/state/intake.md`, task `grill.md`, task `gate-ledger.md`, and evidence notes.
- Module Structure Gate: `harness/state/module-structure.md`, task `gate-ledger.md`, and module-structure proposal notes.
- PRD drafting: task `prd.md` and task `gate-ledger.md`.
- Issue drafting: task `issues/*.md` and task `gate-ledger.md`.
- Writing Plan: task `brief.md`, `writing-plan.md`, `reviews.md`, and task `gate-ledger.md`.

Forbidden before implementation:

- product code changes
- product module implementation files
- out-of-plan file edits
- git commit, push, PR, merge, or release

Module folders may be created only after the relevant module structure gate is approved. Product code inside those folders remains locked until `Gate id: implementation` with `Status: approved` is recorded.

## 8. Skill Evidence Is Required

Do not treat PRD, issue, or writing-plan artifacts as complete unless they record the skill used, source artifact, upstream gate ledger entries, required skill-specific confirmation evidence, and next locked gate.

Required confirmations:

- `setup-matt-pocock-skills`: issue tracker decision, triage label vocabulary decision, domain docs layout decision, and user confirmation quote.
- `grill-with-docs` or `grill-me`: evidence inspected, questions answered from repo/docs, questions asked to the user, user answers, unresolved unknowns, and explicit deferred unknown decisions.
- `to-prd`: seam confirmation gate and user quote.
- `to-issues`: issue breakdown approval gate and user quote, including dependency and HITL/AFK validation.
- `superpowers:writing-plans`: source issues, upstream gates, and next locked gate.

Do not publish external GitHub issues, PRD issues, pull requests, or releases unless the current gate ledger and the user explicitly approve that publication.

## 9. Module Structure Is Not Invented Inline

Module type and folder standards are not decided ad hoc.

Creating or changing module types and folder standards is itself substantive work and follows the Full Workflow.

The Module Structure Gate runs before `to-prd`, `to-issues`, `writing-plan`, product module folder creation, product module folder changes, or product code writing when the project has no approved module structure.

If the request cannot create or change product module folders or product code, Codex records `Module Structure Gate: not applicable` in `harness/docs/tasks/active/<slug>/grill.md`, does not ask module-structure questions, and continues with the applicable workflow.

If `modules/` is empty, or if `harness/state/module-structure.md` says no project module structure has been approved, Codex must not run product `to-prd`, product `to-issues`, product `writing-plan`, create product module folders, or write product code.

Before product module work starts, Codex must:

1. Use the Grill Routing And Completion Gate to understand the request.
2. Propose two or three module structure options in plain language.
3. Recommend one option with reasoning.
4. Ask the user to approve or revise the module structure using the Gate Question Format.
5. Record `Gate id: module_structure` with `Status: approved` in the active task `gate-ledger.md`.
6. Record the approved structure in:

```text
harness/state/module-structure.md
```

The recorded structure must include:

- Project Module Types
- Folder Set For Each Module Type
- Active Modules
- Deferred Modules
- Extra Folders And Reasons

Codex must not create module folders that conflict with the recorded module structure.

## 10. Progress Display Uses The Codex App

For substantive work, maintain the Codex app progress checklist.

Do not create `harness/state/progress.md`.

## 11. State Paths Are Fixed

Use these paths:

```text
harness/state/intake.md
harness/state/planning.md
harness/state/module-structure.md
harness/state/compound.md
harness/docs/agents/
harness/docs/adr/
harness/docs/solutions/
harness/docs/tasks/active/
harness/docs/tasks/archive/
CONTEXT.md
handoff.md
```

## 12. Proposals Protect Live Rules

New harness rule changes first go into `proposals/`.

After user approval, reflect the proposal into the live file and delete the proposal file.

Do not keep approved proposal files as archive.

After `ce-compound`, use the exact Learning Update Question in `harness/rules/workflow.md`. Do not change live rules until a proposal is approved.

## 13. Handoff Is Conditional

Do not automatically update `handoff.md`.

Update it only when the user explicitly asks for next-chat handoff.

## 14. Explain Simply

The user may be non-technical.

Use the user's language for user-facing questions and confirmations. If the user writes in Korean, ask gate questions in Korean.

When a decision requires technical terms, explain them in plain language before asking for approval. Keep the explanation short enough that a non-developer can decide what is being approved.

Do not hide the actual gate scope behind developer labels. Developer labels such as `Gate id`, `Status`, `PRD`, `issue`, `module`, `branch`, `commit`, and `push` may be shown, but they must be paired with a simple explanation of what changes for the user.

## 15. Git Branch And Commit Control

Substantive project work must not happen directly on `main` after project setup is complete.

Before the first file edit for a substantive task, create or switch to a task branch unless the user explicitly says to work on the current branch.

Branch names use a short ASCII slug:

```text
task/<task-slug>
```

Examples:

```text
task/g2b-lighting-daily-lookup
task/module-structure
task/readme-cleanup
```

Do not run these commands without explicit user approval in the current chat:

```text
git commit
git push
gh pr create
merge
release
```

Before asking for approval, show:

- Current branch
- Changed files
- Short summary of the intended commit or push
- Verification already run or still needed

If approval is not given, leave the changes uncommitted and report `git status --short`.
