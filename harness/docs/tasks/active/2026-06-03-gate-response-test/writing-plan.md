# Gate Response Test Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `jjamppong-harness` open workflow gates only when the user's response clearly answers the immediately preceding gate question, without hardcoding specific approval phrases.

**Architecture:** Add a general `Gate Response Test` and task-local `gate-ledger.md` model to the harness rules, but route live rule changes through `proposals/` first. Keep the user-facing interaction lightweight, but require task artifacts to record the gate question, user answer, approved scope, newly unlocked stage, still locked stages, and deferred unknown decisions. Reset template state files to neutral new-project content for fresh installs while preserving existing project state on reinstall/update.

**Tech Stack:** Markdown harness rules, Markdown task artifacts, PowerShell installer verification, `rg` smoke checks.

---

## File Structure

- Create: `proposals/2026-06-03-gate-response-test.md`
  - Proposal describing the rule change, user problem, affected files, and acceptance tests.
- Modify: `AGENTS.md`
  - Add a short hard rule requiring the Gate Response Test before any workflow gate is opened.
  - Add task-local gate ledger as the source of truth for stage unlocks.
- Modify: `harness/rules/workflow.md`
  - Add `Gate Response Test`, `Gate Question Format`, `Gate Ledger`, `Deferred Unknowns`, `Stage Unlock`, `Skill Evidence`, and lightweight user-facing confirmation rules.
  - Use separate `Gate id` and `Status` fields instead of combined labels.
  - Require gate questions to use the user's language, including Korean when the user writes in Korean.
  - Update PRD/issue/writing-plan stages to depend on exact ledger entries.
- Modify: `harness/rules/rules.md`
  - Add hard rules for no inferred gate approval, no implicit deferrals, ledger-required stage unlocks, and planning write boundaries.
  - Keep deferred unknowns outside gate status values.
  - Strengthen `Explain Simply` so non-developer users get plain-language questions and explanations.
- Modify: `harness/rules/module-types.md`
  - Require module structure approval to be recorded in the task gate ledger before `harness/state/module-structure.md` is treated as approved.
- Create: `harness/docs/tasks/active/2026-06-03-gate-response-test/gate-ledger.md`
  - Record the user approval for this plan review and the proposal gate before live rule edits.
- Modify: `harness/state/intake.md`
  - Reset to neutral new-project content.
- Modify: `harness/state/planning.md`
  - Reset to neutral new-project content and describe how task-local gate ledgers are referenced.
- Modify: `harness/state/compound.md`
  - Reset to neutral new-project content.
- Modify: `README.md`
  - Explain the Gate Response Test in Korean with a short example that is not phrase-list based.
- Modify: `scripts/install-jjamppong-harness.ps1`
  - Verify installed state files are neutral.
  - Preserve existing project state files on reinstall/update instead of forcing neutral state over active project state.
  - Verify installed rules mention `Gate Response Test`, `gate-ledger.md`, no inferred gate approval, and no implicit deferred unknowns.
- Create: `harness/docs/tasks/active/2026-06-03-gate-response-test/verification.md`
  - Record verification and fresh-install smoke test results.
- Create: `harness/docs/tasks/active/2026-06-03-gate-response-test/gate-response-scenarios.md`
  - Record expected behavior for direct approvals, adjacent questions, scope mismatch, conditional answers, and explicit deferrals.

---

## Review Status

This plan was reviewed by three parallel subagents before execution:

- CEO/product review: revise first
- Engineering review: revise first
- Plan Compliance review: revise first
- External harness review: conditional approval after blocking revisions

Accepted review changes:

- Add a `proposals/` step before live harness rule edits.
- Move review before implementation instead of leaving it as the final task.
- Split fresh-install neutral state checks from existing-project reinstall behavior.
- Add missing `module-types.md` task details.
- Add a canonical gate id map.
- Add task-local `gate-ledger.md` creation for this task.
- Add scenario-matrix verification instead of only text-presence checks.
- Add an explicit repo-root precondition for verification commands.
- Split gate id from gate status instead of using combined labels such as `module_structure.approved`.
- Remove `deferred` from gate statuses; deferred unknowns are recorded in a separate field.
- Add explicit gate question format requirements so short answers cannot approve vague questions.
- Add Korean-first gate questions and plain-language explanations for non-developer users.
- Expand Matt Pocock skill evidence requirements for setup, grill, PRD, issues, and writing-plan artifacts.
- Fix nested markdown code fences in plan snippets.

---

### Task 0: Proposal Gate And Review Record

**Files:**
- Create: `proposals/2026-06-03-gate-response-test.md`
- Create: `harness/docs/tasks/active/2026-06-03-gate-response-test/gate-ledger.md`
- Create: `harness/docs/tasks/active/2026-06-03-gate-response-test/reviews.md`

- [ ] **Step 1: Create the proposal**

Create `proposals/2026-06-03-gate-response-test.md`:

```markdown
# Gate Response Test Proposal

## Problem

The harness currently has workflow stages, but a user response can be interpreted too broadly. A response to one gate question may be treated as approval for later stages, deferred unknowns, or implementation.

## Proposed Change

Add a general Gate Response Test. A gate opens only when the user's response clearly answers the immediately preceding explicit gate question and the task-local `gate-ledger.md` records the approved scope and newly unlocked stage.

## Non-Goals

- Do not maintain a phrase list of approval words.
- Do not copy another tool's permission mode.
- Do not make every user-facing answer verbose.

## Affected Files

- `AGENTS.md`
- `harness/rules/workflow.md`
- `harness/rules/rules.md`
- `harness/rules/module-types.md`
- `harness/state/intake.md`
- `harness/state/planning.md`
- `harness/state/compound.md`
- `README.md`
- `scripts/install-jjamppong-harness.ps1`

## Acceptance Tests

- A direct answer to a gate question opens only that gate.
- An adjacent technical question does not open the gate.
- A conditional answer opens only the condition-free part, if any, and records the condition as unresolved.
- Deferred unknowns require a named user deferral quote.
- Fresh installs start with neutral state.
- Existing project reinstalls preserve existing state unless explicitly reset.
```

- [ ] **Step 2: Record the review gate ledger entry**

Create `harness/docs/tasks/active/2026-06-03-gate-response-test/gate-ledger.md`:

```markdown
# Gate Ledger

## Active Task

- Task Slug: 2026-06-03-gate-response-test

## Entries

### plan_review

- Stage: plan-review
- Status: completed
- Agent Question: Review the writing plan with CEO, Engineering, and Plan Compliance subagents.
- User Answer Quote: "너 writing plan 한거 리뷰하는거 까지 하자. 좋아 서브에이전트로 하는거 잊지말구"
- Interpreted Scope: run plan review only; do not execute live harness rule edits yet
- Newly Unlocked: proposal drafting
- Still Locked: live rule edits, installer changes, commit, push, merge
- Evidence Artifacts:
  - `harness/docs/tasks/active/2026-06-03-gate-response-test/reviews.md`
```

- [ ] **Step 3: Record reviews**

Create `harness/docs/tasks/active/2026-06-03-gate-response-test/reviews.md` with the three subagent findings and the accepted plan revisions.

- [ ] **Step 4: Stop for proposal approval**

After creating the proposal and review records, ask the user to approve reflecting the proposal into live harness files. Do not edit `AGENTS.md`, `harness/rules/*`, `README.md`, state files, or installer files before this approval is explicit.

---

### Task 1: Add Gate Response Test To Core Rules

**Files:**
- Modify: `AGENTS.md`
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/rules.md`

- [ ] **Step 1: Add `Gate Response Test` hard rule to `AGENTS.md`**

Add this under `## Hard Rules`:

```markdown
- Before opening any workflow gate, run the Gate Response Test from `harness/rules/workflow.md`: the user's response must clearly answer the immediately preceding explicit gate question, the approved scope must match that question, unresolved conditions must be handled, and the task `gate-ledger.md` must record the result. If the test does not pass, keep the gate locked and ask a narrower confirmation question.
```

- [ ] **Step 2: Add task-local ledger rule to `AGENTS.md`**

Add this under `## Harness Root Model` or `## Hard Rules`:

```markdown
- Gate approvals are task-local. Record them in `harness/docs/tasks/active/<slug>/gate-ledger.md`; do not use a global ledger as the source of truth for a task.
```

- [ ] **Step 3: Add `Gate Response Test` section to `workflow.md`**

Add this section after `## Matt Pocock Planning Gate`:

```markdown
## Gate Response Test

A workflow gate opens only when all of these are true:

1. The agent asked an explicit gate question immediately before the user's relevant answer.
2. The user's answer clearly responds to that gate question.
3. The interpreted approval scope matches the question scope.
4. Any conditions, objections, new blockers, or unresolved unknowns in the answer are recorded and handled before moving on.
5. The task gate ledger records the question, user answer, interpreted scope, newly unlocked stage, still locked stages, and evidence artifact.

If any check fails, the gate remains locked. Answer the user's adjacent question if needed, then ask a narrower gate question.

Do not maintain a phrase list of approval words. Judge the relationship between the gate question and the user's answer.
```

- [ ] **Step 4: Add `Gate Question Format` section to `workflow.md`**

Add:

```markdown
## Gate Question Format

Every gate question must state:

- Approval scope
- Artifact or decision being approved
- This unlocks
- This remains locked
- Deferred unknowns that require separate approval

Ask gate questions in the user's language. If the user writes in Korean, ask the gate question in Korean and include a short plain-language explanation of any technical term needed to make the decision.

If the gate question does not state these fields, a short affirmative answer must not open the gate. Ask a narrower confirmation question instead.
```

- [ ] **Step 5: Add `Gate Ledger` section to `workflow.md`**

Add:

````markdown
## Gate Ledger

Every substantive task keeps a task-local ledger at `harness/docs/tasks/active/<slug>/gate-ledger.md`.

The ledger is the source of truth for stage unlocks. Artifact existence alone does not unlock the next stage.

Each entry records:

- Gate id
- Stage
- Status: `pending`, `approved`, `existing-approved`, `revised`, `blocked`, `completed`, or `not-applicable`
- Agent question
- User answer quote
- Interpreted scope
- Newly unlocked stage
- Still locked stages
- Deferred unknown decisions, if any
- Evidence artifact paths

Canonical gate ids:

- `grill`
- `module_structure`
- `prd`
- `issues`
- `plan_review`
- `implementation`
- `archive`

A matching ledger entry means `Gate id` equals the required gate id and `Status` equals the required status. Do not concatenate them as labels such as `module_structure.approved` in live rules.

Deferred unknowns are not gate statuses. Record deferred unknowns in the `Deferred unknown decisions` field with:

- Unknown
- User quote
- Why non-blocking now
- Revisit before
````

- [ ] **Step 6: Add hard rule sections to `rules.md`**

Add these sections after `## 3. Plan Review Question Is Mandatory`:

```markdown
## 4. No Inferred Gate Approval

Do not open a workflow gate by implication.

A gate opens only when the user's response clearly answers the immediately preceding explicit gate question. Recommendations, summaries, silence, topic changes, adjacent technical discussion, or artifact existence do not approve a gate.

If the response is ambiguous, choose the narrower interpretation and keep later stages locked.
```

```markdown
## 5. No Implicit Deferrals

Unknowns are blockers unless resolved or explicitly deferred.

An unknown may be marked deferred only when the user explicitly defers that named unknown. A general direction approval, module structure approval, PRD approval, issue approval, or plan approval does not approve deferred unknowns.

Each deferred unknown must record:

- Unknown
- User quote approving deferral
- Why it is non-blocking now
- Revisit stage
```

```markdown
## 6. Stage Unlocks Require Ledger Evidence

Before entering a stage, verify the task gate ledger contains the matching approval entry:

| Stage | Required task-local ledger entry |
|---|---|
| product/module PRD drafting | `Gate id: module_structure` and `Status: approved` or `Status: existing-approved` |
| non-product/non-module PRD drafting | `Gate id: module_structure` and `Status: not-applicable` |
| issue decomposition | `Gate id: prd` and `Status: approved` |
| task brief and writing-plan | `Gate id: issues` and `Status: approved` |
| implementation | `Gate id: plan_review` and `Status: completed` |

No matching ledger entry means the stage is still locked.
```

```markdown
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
```

- [ ] **Step 7: Update `module-types.md`**

Add this after the output-location section:

```markdown
## Ledger Requirement

Module structure approval must be traceable to the active task gate ledger.

For the task that creates or changes module structure, the task gate ledger must contain `Gate id: module_structure` with `Status: approved` before `harness/state/module-structure.md` is treated as approved.

Future tasks may rely on `harness/state/module-structure.md` as the long-lived module structure record, but they must record one of these task-local entries before product PRD drafting:

- `Gate id: module_structure` with `Status: existing-approved`: existing approved structure applies.
- `Gate id: module_structure` with `Status: approved`: this task approved a new or changed structure.
- `Gate id: module_structure` with `Status: not-applicable`: this task cannot create or change product module folders or product code.

The state file records the approved structure. The task ledger records the user response that opened the gate.
```

- [ ] **Step 8: Strengthen `Explain Simply`**

Replace the existing `## Explain Simply` section with:

```markdown
## Explain Simply

The user may be non-technical.

Use the user's language for user-facing questions and confirmations. If the user writes in Korean, ask gate questions in Korean.

When a decision requires technical terms, explain them in plain language before asking for approval. Keep the explanation short enough that a non-developer can decide what is being approved.

Do not hide the actual gate scope behind developer labels. Developer labels such as `Gate id`, `Status`, `PRD`, `issue`, `module`, `branch`, `commit`, and `push` may be shown, but they must be paired with a simple explanation of what changes for the user.
```

- [ ] **Step 9: Renumber existing `rules.md` sections**

After inserting the new sections, use this final heading map:

```text
## 1. Full Workflow Is The Default
## 2. Required Plugins And Skills
## 3. Plan Review Question Is Mandatory
## 4. No Inferred Gate Approval
## 5. No Implicit Deferrals
## 6. Stage Unlocks Require Ledger Evidence
## 7. Planning Write Boundary
## 8. Skill Evidence Is Required
## 9. Module Structure Is Not Invented Inline
## 10. Progress Display Uses The Codex App
## 11. State Paths Are Fixed
## 12. Proposals Protect Live Rules
## 13. Handoff Is Conditional
## 14. Explain Simply
## 15. Git Branch And Commit Control
```

- [ ] **Step 10: Verify rule text**

Run:

```powershell
Set-Location 'F:\Folder\ourosuper-harness'
rg -n "Gate Response Test|Gate Question Format|gate-ledger.md|No Inferred Gate Approval|No Implicit Deferrals|Stage Unlocks Require Ledger Evidence|Planning Write Boundary|Gate id.*Status|If the user writes in Korean|non-technical" AGENTS.md harness/rules
```

Expected: matches in `AGENTS.md`, `harness/rules/workflow.md`, and `harness/rules/rules.md`.

---

### Task 2: Add Skill Evidence And Stage Metadata

**Files:**
- Modify: `harness/rules/workflow.md`
- Modify: `harness/rules/rules.md`

- [ ] **Step 1: Add skill evidence section to `workflow.md`**

Add after `## Gate Ledger`:

```markdown
## Skill Evidence

Required skill-produced artifacts must record the skill name, source artifacts, upstream gates, and skill-specific confirmation points.

`setup-matt-pocock-skills` evidence must include:

- Issue tracker decision
- Triage label vocabulary decision
- Domain docs layout decision
- User confirmation quote
- Written docs under `harness/docs/agents/` or documented harness-local mapping

`grill.md` evidence must include:

- Selected skill: `grill-with-docs`, `grill-me`, or both
- Evidence inspected before asking the user
- Questions answered from repo/docs
- Questions asked to the user, one at a time
- User answers
- Unresolved unknowns
- Explicit deferred unknown decisions, if any

`prd.md` must include:

- `Generated-By: to-prd`
- Repo exploration evidence
- Domain glossary or ADR evidence considered
- Testing seams proposed
- `Source-Grill`
- `Seam-Confirmation-Gate`
- `Seam-Confirmation-Quote`
- `Upstream-Gates`
- `Next-Locked-Gate`

`issues/*.md` must include:

- `Generated-By: to-issues`
- `Source-PRD`
- Vertical slice breakdown
- `Issue-Breakdown-Approval-Gate`
- `Issue-Breakdown-Approval-Quote`
- `Dependency-Validation`
- `HITL-AFK-Validation`
- `Upstream-Gates`
- `Next-Locked-Gate`

`writing-plan.md` must include:

- `Generated-By: superpowers:writing-plans`
- `Source-Issues`
- `Upstream-Gates`
- `Next-Locked-Gate`

When using Matt Pocock skills in this harness, do not publish external GitHub issues or PRD issues unless the current workflow gate and the user explicitly approve that publication. Prefer local task artifacts under `harness/docs/tasks/active/<slug>/` until the relevant approval gate is recorded.

If a required skill is unavailable, stop and tell the user. Do not silently replace it with an untracked manual artifact.
```

- [ ] **Step 2: Add skill evidence hard rule to `rules.md`**

Add:

```markdown
## 7. Skill Evidence Is Required

Do not treat PRD, issue, or writing-plan artifacts as complete unless they record the skill used, source artifact, upstream gate ledger entries, required skill-specific confirmation evidence, and next locked gate.

Required confirmations:

- `setup-matt-pocock-skills`: issue tracker decision, triage label vocabulary decision, domain docs layout decision, and user confirmation quote.
- `grill-with-docs` or `grill-me`: evidence inspected, questions answered from repo/docs, questions asked to the user, user answers, unresolved unknowns, and explicit deferred unknown decisions.
- `to-prd`: seam confirmation gate and user quote.
- `to-issues`: issue breakdown approval gate and user quote, including dependency and HITL/AFK validation.
- `superpowers:writing-plans`: source issues, upstream gates, and next locked gate.

Do not publish external GitHub issues, PRD issues, pull requests, or releases unless the current gate ledger and the user explicitly approve that publication.
```

- [ ] **Step 3: Update workflow stage descriptions**

In `workflow.md`, update these existing steps:

```markdown
5. Produce `harness/docs/tasks/active/<slug>/prd.md` with `to-prd`.
```

to:

```markdown
5. Produce `harness/docs/tasks/active/<slug>/prd.md` with `to-prd` only after the task gate ledger unlocks product PRD drafting.
```

Update issue and writing-plan descriptions the same way:

```markdown
7. Decompose the approved PRD into `harness/docs/tasks/active/<slug>/issues/001-*.md` with `to-issues` only after `Gate id: prd` with `Status: approved` is recorded.
```

```markdown
Use `superpowers:writing-plans` only after `Gate id: issues` with `Status: approved` is recorded.
```

- [ ] **Step 4: Verify metadata terms**

Run:

```powershell
Set-Location 'F:\Folder\ourosuper-harness'
rg -n "setup-matt-pocock-skills|grill-with-docs|Repo exploration evidence|Vertical slice breakdown|HITL-AFK-Validation|Generated-By: superpowers:writing-plans|external GitHub issues" harness/rules
```

Expected: metadata requirements are visible in `workflow.md` and `rules.md`.

---

### Task 3: Reset Template State To Neutral

**Files:**
- Modify: `harness/state/intake.md`
- Modify: `harness/state/planning.md`
- Modify: `harness/state/compound.md`
- Verify: `harness/state/module-structure.md`

- [ ] **Step 1: Reset `intake.md`**

Replace the file with:

```markdown
# Request Intake

No active request has been recorded for this project yet.

When a substantive user request starts, record:

- User Request
- Plain-Language Interpretation
- Workflow Decision
- Required Plugins Or Skills
- Current Blockers
```

- [ ] **Step 2: Reset `planning.md`**

Replace the file with:

```markdown
# Planning State

No active task is in progress.

When a task starts, record:

- Active Task Slug
- Current Stage
- Current Gate
- Task Gate Ledger
- Current Allowed Write Scope
- Next Locked Gate

Task-specific gate approvals belong in `harness/docs/tasks/active/<slug>/gate-ledger.md`.

This state file points to the active task only. It is not the source of truth for gate approvals.
```

- [ ] **Step 3: Reset `compound.md`**

Replace the file with:

```markdown
# Compound State

No reusable learning has been captured for this project yet.

Reusable learning belongs under `harness/docs/solutions/`.

This file stores only a short index of reusable learning documents.
```

- [ ] **Step 4: Verify stale task names are gone**

Run:

```powershell
rg -n "agents-md-management|jjamppong-harness-migration|implementation-verified|Active task:" harness/state
```

Expected: no matches. `rg` exit code 1 is success for this negative check.

- [ ] **Step 5: Verify module structure starts unapproved**

Run:

```powershell
Set-Location 'F:\Folder\ourosuper-harness'
rg -n "No project module structure has been approved" harness/state/module-structure.md
```

Expected: one match.

---

### Task 4: Update Installer Verification

**Files:**
- Modify: `scripts/install-jjamppong-harness.ps1`

- [ ] **Step 1: Add required gate text checks**

Extend `$requiredTextChecks` in `Verify-Install` with:

```powershell
@{ Path = 'AGENTS.md'; Pattern = 'Gate Response Test' },
@{ Path = 'harness/rules/workflow.md'; Pattern = 'Gate Response Test' },
@{ Path = 'harness/rules/workflow.md'; Pattern = 'Gate Question Format' },
@{ Path = 'harness/rules/workflow.md'; Pattern = 'gate-ledger.md' },
@{ Path = 'harness/rules/workflow.md'; Pattern = 'Gate id' },
@{ Path = 'harness/rules/rules.md'; Pattern = 'No Inferred Gate Approval' },
@{ Path = 'harness/rules/rules.md'; Pattern = 'No Implicit Deferrals' },
@{ Path = 'harness/rules/rules.md'; Pattern = 'Stage Unlocks Require Ledger Evidence' }
```

- [ ] **Step 2: Add neutral state checks**

Still inside `Verify-Install`, add neutral state checks for fresh installs only. Existing project reinstalls must preserve project state unless the user explicitly requests a reset.

Add or preserve an installer-level variable before copying:

```powershell
$hadExistingHarnessState = Test-Path -LiteralPath (Join-Path $target 'harness/state')
```

Back up and restore existing state files when `$hadExistingHarnessState` is true:

```powershell
$stateBackupRoot = Join-Path $tempBase ('jjamppong-state-' + [guid]::NewGuid().ToString('N'))

function Backup-TargetState {
  param([string]$Target, [string]$BackupRoot)

  $stateDir = Join-Path $Target 'harness/state'
  if (-not (Test-Path -LiteralPath $stateDir)) {
    return
  }
  New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
  Copy-Item -LiteralPath $stateDir -Destination $BackupRoot -Recurse -Force
}

function Restore-TargetState {
  param([string]$Target, [string]$BackupRoot)

  $backupState = Join-Path $BackupRoot 'state'
  if (-not (Test-Path -LiteralPath $backupState)) {
    return
  }
  $stateDir = Join-Path $Target 'harness/state'
  Remove-Item -LiteralPath $stateDir -Recurse -Force
  Copy-Item -LiteralPath $backupState -Destination (Join-Path $Target 'harness') -Recurse -Force
}
```

Then add checks equivalent to:

```powershell
if (-not $hadExistingHarnessState) {
  $neutralStateChecks = @(
    @{ Path = 'harness/state/intake.md'; Pattern = 'No active request has been recorded for this project yet.' },
    @{ Path = 'harness/state/planning.md'; Pattern = 'No active task is in progress.' },
    @{ Path = 'harness/state/compound.md'; Pattern = 'No reusable learning has been captured for this project yet.' },
    @{ Path = 'harness/state/module-structure.md'; Pattern = 'No project module structure has been approved.' }
  )

  foreach ($check in $neutralStateChecks) {
    $path = Join-Path $Target $check.Path
    $content = Get-Content -LiteralPath $path -Raw
    if (-not $content.Contains($check.Pattern)) {
      throw "Installed harness state is not neutral in $($check.Path): $($check.Pattern)"
    }
  }
}
```

- [ ] **Step 3: Parser check**

Run:

```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  'scripts/install-jjamppong-harness.ps1',
  [ref]$tokens,
  [ref]$errors
) | Out-Null
$errors.Count
```

Expected: `0`.

---

### Task 5: README Scenario And Smoke Verification

**Files:**
- Modify: `README.md`
- Create: `harness/docs/tasks/active/2026-06-03-gate-response-test/verification.md`
- Create: `harness/docs/tasks/active/2026-06-03-gate-response-test/gate-response-scenarios.md`

- [ ] **Step 1: Add Korean README explanation**

Under the harness scenario section, add:

```markdown
### Gate Response Test

하네스는 특정 단어 목록으로 승인을 판단하지 않습니다. 대신 직전 gate 질문과 사용자 답변의 관계를 봅니다.

gate가 열리려면 다음이 모두 맞아야 합니다.

1. 직전에 명시적인 gate 질문이 있었음
2. 사용자 답변이 그 질문에 직접 답함
3. 승인 범위가 질문 범위와 같음
4. 조건, 반대, 새 blocker, 미정사항이 따로 처리됨
5. task의 `gate-ledger.md`에 기록됨

이 중 하나라도 부족하면 gate는 닫힌 상태로 유지되고, Codex는 더 좁은 확인 질문을 해야 합니다.

사용자가 한국어로 말하면 Codex도 한국어로 물어봅니다. `PRD`, `issue`, `commit`, `push` 같은 개발 용어가 필요하면, 승인 질문 전에 쉬운 말로 짧게 풀어서 설명해야 합니다.
```

- [ ] **Step 2: Add concise example**

Add:

```markdown
예를 들어 "이 모듈 구조를 승인할까요?"라는 질문에 사용자가 "좋아"라고 답하면 module structure만 승인됩니다. 이 답변은 PRD 승인, issue 승인, writing plan 승인, 구현 시작, commit/push 승인이 아닙니다.

반대로 사용자가 "근데 Selenium 방식은 어떻게 돼?"처럼 다른 질문을 하면 gate 승인으로 기록하지 않습니다. Codex는 그 질문에 답한 뒤 다시 좁은 gate 질문을 해야 합니다.

좋은 승인 질문 예시는 이렇습니다:

"승인 범위: 모듈 구조만 승인합니다. 이걸 승인하면 PRD 초안 작성만 시작할 수 있고, 구현/커밋/푸시는 아직 잠겨 있습니다. `modules/g2b-extraction`을 첫 제품 모듈로 잡아도 될까요?"
```

- [ ] **Step 3: Run rule text checks**

Run:

```powershell
rg -n "Gate Response Test|Gate Question Format|No Inferred Gate Approval|No Implicit Deferrals|Stage Unlocks Require Ledger Evidence|Generated-By: to-prd|Gate id.*Status|한국어로 물어봅니다|쉬운 말" AGENTS.md README.md harness/rules scripts/install-jjamppong-harness.ps1
```

Expected: matches across rules, README, and installer.

- [ ] **Step 4: Run fresh install smoke**

Run:

```powershell
$target = Join-Path ([IO.Path]::GetTempPath()) ('jjamppong-gate-smoke-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $target -Force | Out-Null
& .\scripts\install-jjamppong-harness.ps1 . $target -ProjectRepo 'https://github.com/vibedong/jjamppong-gate-smoke.git' -SkipGitHubRepo
```

Expected output includes:

```text
Verified harness root:
Verified project origin: https://github.com/vibedong/jjamppong-gate-smoke.git
Install complete. Commit and push still require explicit user approval.
```

- [ ] **Step 5: Verify installed state and gate text**

Run:

```powershell
rg -n "Gate Response Test|No active task is in progress|No active request has been recorded|No Inferred Gate Approval" $target
```

Expected: matches in installed `AGENTS.md`, `README.md`, `harness/rules`, and `harness/state`.

- [ ] **Step 6: Verify no task artifact leak**

Run:

```powershell
$active = @(Get-ChildItem -LiteralPath (Join-Path $target 'harness/docs/tasks/active') -Force | Where-Object { $_.Name -ne '.gitkeep' })
$archive = @(Get-ChildItem -LiteralPath (Join-Path $target 'harness/docs/tasks/archive') -Force | Where-Object { $_.Name -ne '.gitkeep' })
$active.Count
$archive.Count
```

Expected:

```text
0
0
```

- [ ] **Step 7: Add scenario matrix verification**

Create `harness/docs/tasks/active/2026-06-03-gate-response-test/gate-response-scenarios.md`:

```markdown
# Gate Response Scenario Matrix

| Scenario | Gate question | User response | Expected gate result | Expected ledger result |
|---|---|---|---|---|
| Narrow yes | Approve module structure only? | 좋아 | Opens module structure only | `Gate id: module_structure`, `Status: approved`; PRD drafting unlocked only; PRD approval, issues, writing plan, implementation remain locked |
| Adjacent technical question | Approve this module structure? | Selenium은 어떻게 해? | Gate stays locked | No approval entry; agent answers adjacent question then asks a narrower gate question |
| Deferred unknown requires named approval | Approve module structure only? | 좋아 | Module structure may open; unrelated unknown remains unresolved | No deferred unknown entry without an explicit user quote naming that unknown |
| PRD approval unlocks only issues | Approve PRD for issue decomposition? | ㅇㅇ | Opens issue decomposition only | `Gate id: prd`, `Status: approved`; issue approval, writing plan, implementation remain locked |
| Issue approval unlocks only writing plan | Approve issue breakdown? | 그렇게 하자 | Opens task brief and writing-plan only | `Gate id: issues`, `Status: approved`; implementation remains locked until `Gate id: plan_review`, `Status: completed` |
| Ambiguous gate question | 이 방향으로 갈까요? | 좋아 | Gate stays locked | No approval entry; agent asks a narrower question with explicit approval scope |
| Writing plan direction approval | 이 writing plan 방향 괜찮나요? | 좋아 | Plan direction may be recorded as feedback | Implementation remains locked; agent must ask the mandatory plan review choice before implementation |

This matrix is not a phrase list. It verifies whether the answer clearly responds to the immediately preceding gate question.
```

Verify:

```powershell
Set-Location 'F:\Folder\ourosuper-harness'
rg -n "Narrow yes|Adjacent technical question|Deferred unknown requires named approval|Ambiguous gate question|Writing plan direction approval|This matrix is not a phrase list" harness/docs/tasks/active/2026-06-03-gate-response-test/gate-response-scenarios.md
```

Expected: all six phrases appear.

- [ ] **Step 8: Record verification**

Write `harness/docs/tasks/active/2026-06-03-gate-response-test/verification.md` with:

- Parser check result
- Rule text check result
- Negative stale-state check result
- Fresh install smoke result
- Scenario matrix verification result
- Remaining risk: this verifies installed rules and state, not a full live Codex conversation.

- [ ] **Step 9: Remove temp target**

Run:

```powershell
Remove-Item -LiteralPath $target -Recurse -Force
```

Expected: temp target removed.

---

### Task 6: Final Review And Commit Readiness

**Files:**
- No source changes beyond previous tasks.

- [ ] **Step 1: Review changed files**

Run:

```powershell
git status --short
git diff --stat
```

Expected changed files:

```text
AGENTS.md
README.md
harness/rules/workflow.md
harness/rules/rules.md
harness/rules/module-types.md
harness/state/intake.md
harness/state/planning.md
harness/state/compound.md
scripts/install-jjamppong-harness.ps1
harness/docs/tasks/active/2026-06-03-gate-response-test/writing-plan.md
harness/docs/tasks/active/2026-06-03-gate-response-test/verification.md
harness/docs/tasks/active/2026-06-03-gate-response-test/gate-ledger.md
harness/docs/tasks/active/2026-06-03-gate-response-test/reviews.md
harness/docs/tasks/active/2026-06-03-gate-response-test/gate-response-scenarios.md
proposals/2026-06-03-gate-response-test.md
```

- [ ] **Step 2: Confirm review record exists**

Run:

```powershell
Set-Location 'F:\Folder\ourosuper-harness'
rg -n "CEO/product review|Engineering review|Plan Compliance review|Verdict" harness/docs/tasks/active/2026-06-03-gate-response-test/reviews.md
```

Expected: all reviewer labels and verdict lines appear.

- [ ] **Step 3: Ask for commit and push approval**

Show the user:

```text
Current branch
Changed files
Verification summary
Proposal reflection state
```

Do not commit or push until the user explicitly approves that git action.

---

## Self-Review

**Spec coverage:** The plan covers the user's stated goal: avoid hardcoded approval phrases and instead use a general response-to-gate-question test. It also covers the two review findings: stale template state and missing skill evidence.

**Placeholder scan:** No placeholder instructions remain. Each task names exact files, text to add, and verification commands.

**Type consistency:** The same names are used throughout: `Gate Response Test`, `gate-ledger.md`, `No Inferred Gate Approval`, `No Implicit Deferrals`, `Stage Unlocks Require Ledger Evidence`, `Generated-By`.
