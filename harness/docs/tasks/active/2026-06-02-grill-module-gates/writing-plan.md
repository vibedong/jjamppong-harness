# Grill Routing And Module Structure Gates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Tighten 짬뽕하네스 planning rules so agents choose `grill-with-docs` or `grill-me` correctly, complete one-question-at-a-time grilling before PRD synthesis, and require approved module structure before product module folders or product code are created.

**Architecture:** Treat this as a harness rules change, not product work. Add a proposal first, then update the live governance files after approval: `AGENTS.md`, `harness/rules/workflow.md`, `harness/rules/rules.md`, and human-facing README guidance. Add `harness/docs/tasks/active/<slug>/grill.md` as the task-specific grill record so interview results are captured before PRD synthesis. Keep `harness/state/module-structure.md` as the installed-project state file that starts with "not approved"; the new rules should explain how agents must handle that state.

**Tech Stack:** Markdown governance files, Matt Pocock skills (`grill-with-docs`, `grill-me`, `to-prd`, `to-issues`), Superpowers writing plans, Git verification commands, PowerShell smoke checks.

---

## Evidence And Decisions

- Matt Pocock `grill-with-docs` is not just a document scan. It says to interview relentlessly, ask one question at a time, wait for feedback before continuing, and inspect the codebase when code can answer the question.
- Matt Pocock `grill-me` is the general plan/design interview skill for cases without existing code or domain docs.
- Matt Pocock `to-prd` says not to interview the user; it should synthesize what is already known.
- Matt Pocock `to-issues` asks the user to review issue granularity, dependencies, and HITL/AFK classification before publishing issues.
- Current harness rules require `grill-with-docs`, but they do not define a completion gate. This lets agents jump from a shallow scan to PRD/module structure too early.
- Current harness rules say module structure must be approved before creating folders, but they do not make the "empty modules / no approved module structure" case prominent enough in the planning gate.
- The initial proposal listed only `AGENTS.md`, `harness/rules/workflow.md`, `harness/rules/rules.md`, and `README.md`. During branch review, additional coupled surfaces were found. The user then approved expanding the branch scope with: "전체다 변경해도돼. 지금 하네스안쓰고있어." This covers the follow-up changes to `harness/rules/module-types.md`, `harness/state/module-structure.md`, `scripts/install-jjamppong-harness.ps1`, and task artifacts.

## File Structure

- Modify `AGENTS.md`
  - Add short routing guidance under `Always Use` or `New Project Request Trigger`.
  - Add a hard rule: no product module folder or product code when `modules/` is empty or `harness/state/module-structure.md` says no structure is approved.
- Modify `harness/rules/workflow.md`
  - Replace the simple `grill-with-docs` step with a `Grill Routing And Completion Gate`.
  - Add a `Module Structure Gate` before PRD/module folder decisions.
  - Define `harness/docs/tasks/active/<slug>/grill.md` as the grill output written before PRD.
- Modify `harness/rules/rules.md`
  - Mirror the new required skill sequence.
  - Make the `Module Structure Is Not Invented Inline` rule operational and testable.
- Modify `harness/rules/module-types.md`
  - Replace the old module structure process with the new grill/module gate vocabulary.
- Modify `harness/state/module-structure.md`
  - Preserve the default unapproved state while clarifying that it is resolved through the Module Structure Gate in the Full Workflow.
- Modify `scripts/install-jjamppong-harness.ps1`
  - Keep fresh installs from receiving template-maintenance task artifacts in `harness/docs/tasks/active/` and `archive/`.
  - Preserve an existing target project's task artifacts when `-AllowOverwrite` is used.
- Modify `README.md`
  - Update the visible default workflow list so it matches the live workflow.
  - Explain the expected planning behavior for users in plain language.
  - Clarify that `grill-with-docs` and `grill-me` are situational, not duplicate mandatory work.
- Create then later delete `proposals/2026-06-02-grill-module-gates.md`
  - Required by the existing `Proposals Protect Live Rules` rule before changing live harness rules.
- Preserve `harness/state/module-structure.md`
  - The current "No project module structure has been approved" default remains correct for the template. Only the explanatory process sentence may change.

---

### Task 1: Create The Rule Change Proposal

**Files:**
- Create: `proposals/2026-06-02-grill-module-gates.md`

- [x] **Step 1: Add the proposal file**

Use `apply_patch` to create `proposals/2026-06-02-grill-module-gates.md` with this content:

```markdown
# Proposal: Grill Routing And Module Structure Gates

Status: proposed

## Problem

Agents can currently satisfy the harness by mentioning `grill-with-docs`, then move too quickly into PRD, module structure, or implementation without completing the one-question-at-a-time grilling behavior intended by Matt Pocock's skills.

Agents also may see an empty `modules/` directory and a user feature request, then propose or create module folders before the project module structure is approved.

## Decision

Add a mandatory Grill Routing And Completion Gate:

- Use `grill-with-docs` when existing code, docs, candidate lists, domain glossary, ADRs, or prior implementations can answer or sharpen the request.
- Use `grill-me` when the request is greenfield, product-intent driven, or lacks enough existing project evidence.
- If both apply, inspect existing code/docs first with `grill-with-docs`, then use `grill-me` only for remaining user-intent uncertainties.
- Ask one question at a time and wait for the user's answer before continuing.
- Do not ask the user for facts that can be answered by existing code, docs, candidate lists, domain glossary, ADRs, or prior implementations.
- Record the grill route, inspected evidence, answered questions, deferred unknowns, and remaining decisions in `harness/docs/tasks/active/<slug>/grill.md`.
- Do not run `to-prd`, `to-issues`, write module structure, create module folders, or write product code until core uncertainties are resolved or explicitly deferred by the user.

Add a mandatory Module Structure Gate:

- If `modules/` is empty or `harness/state/module-structure.md` says no module structure is approved, stop before creating module folders or product code.
- Use the planning gate to propose module structure options in plain language.
- Record the approved structure in `harness/state/module-structure.md`.
- Only then create product module folders.
- If the request cannot create or change product module folders or product code, record the Module Structure Gate as not applicable and do not ask module-structure questions.

## Consequences

- Planning will ask more targeted questions before PRD synthesis.
- `to-prd` will be used as synthesis, not as a substitute for user interview.
- New projects will not accumulate ad hoc folders under `modules/`.
- Some small tasks may feel slower, but the harness already has no task-size bypass for substantive work.

## Files To Change

- `AGENTS.md`
- `harness/rules/workflow.md`
- `harness/rules/rules.md`
- `README.md`
```

- [x] **Step 2: Verify proposal exists**

Run:

```powershell
Test-Path -LiteralPath 'proposals/2026-06-02-grill-module-gates.md'
```

Expected output:

```text
True
```

- [x] **Step 3: Stop for proposal approval**

Ask:

```text
이 proposal대로 live harness rules에 반영할까요?
승인하면 AGENTS.md, workflow.md, rules.md, README.md를 수정하고 proposal 파일은 삭제하겠습니다.
```

Do not continue to Task 2 until the user approves.

---

### Task 2: Update `workflow.md` Planning Gate

**Files:**
- Modify: `harness/rules/workflow.md`

- [x] **Step 1: Replace the Full Workflow grill step**

Change the Full Workflow list from:

```markdown
3. grill-with-docs
4. to-prd
```

to:

```markdown
3. Grill Routing And Completion Gate
4. Grill Result Record
5. Module Structure Gate
6. to-prd
```

Then renumber later steps so the sequence remains continuous. In the explanatory text below the list, state that the Module Structure Gate is active only when the request may create or change product module folders or product code. For non-module work, record it as not applicable and continue without asking module-structure questions.

- [x] **Step 2: Replace the Matt Pocock Planning Gate steps**

Replace the current section:

```markdown
1. Verify `setup-matt-pocock-skills` output exists.
2. Run `grill-with-docs`.
3. Produce `harness/docs/tasks/active/<slug>/prd.md` with `to-prd`.
4. Stop and ask the user to approve or revise the PRD before issue decomposition.
5. Decompose the approved PRD into `harness/docs/tasks/active/<slug>/issues/001-*.md` with `to-issues`.
6. Stop and ask the user to approve or revise the issue breakdown before writing the implementation plan.
7. Produce `harness/docs/tasks/active/<slug>/brief.md`.
```

with:

```markdown
1. Verify `setup-matt-pocock-skills` output exists.
2. Run the Grill Routing And Completion Gate.
3. Record the grill route and results in `harness/docs/tasks/active/<slug>/grill.md`.
4. Run the Module Structure Gate when the request may create or change product modules.
5. Produce `harness/docs/tasks/active/<slug>/prd.md` with `to-prd`.
6. Stop and ask the user to approve or revise the PRD before issue decomposition.
7. Decompose the approved PRD into `harness/docs/tasks/active/<slug>/issues/001-*.md` with `to-issues`.
8. Stop and ask the user to approve or revise issue granularity, dependency order, and HITL/AFK classification before writing the implementation plan.
9. Produce `harness/docs/tasks/active/<slug>/brief.md`.
```

- [x] **Step 3: Add the Grill Routing And Completion Gate section**

Add this section immediately after `## Matt Pocock Planning Gate`:

```markdown
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
```

- [x] **Step 4: Add the Grill Result Record section**

Add this section after the Grill Routing section:

```markdown
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
```

- [x] **Step 5: Add the Module Structure Gate section**

Add this section after the Grill Result Record section:

```markdown
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
```

- [x] **Step 6: Verify workflow text**

Run:

```powershell
rg -n "Grill Routing And Completion Gate|Grill Result Record|Module Structure Gate|Ask one question at a time|grill.md|to-prd" harness/rules/workflow.md
```

Expected:

- Matches for all new workflow step names.
- A match for `Ask one question at a time`.
- A match for `grill.md`.
- `to-prd` appears after the gate descriptions.

---

### Task 3: Update `rules.md` Required Skills And Module Rule

**Files:**
- Modify: `harness/rules/rules.md`

- [x] **Step 1: Update the Required Plugins And Skills block**

Replace:

```text
Matt Pocock Planning Gate
  Verify setup-matt-pocock-skills readiness.
  Use grill-with-docs.
  Use to-prd.
  Stop for User PRD Approval.
  Use to-issues.
  Stop for User Issue Approval.
  Write the task brief.
```

with:

```text
Matt Pocock Planning Gate
  Verify setup-matt-pocock-skills readiness.
  Run Grill Routing And Completion Gate.
  Use grill-with-docs when existing code/docs/candidate lists/domain docs can sharpen the request.
  Use grill-me when the request is greenfield or mostly product-intent driven.
  Ask one user-facing question at a time and wait for the user's answer.
  Do not ask the user for facts already answered by inspected code/docs.
  Record grill route, inspected evidence, answered questions, deferred unknowns, and remaining decisions in harness/docs/tasks/active/<slug>/grill.md.
  Run Module Structure Gate before creating or changing product module folders.
  For non-module work, record Module Structure Gate as not applicable and do not ask module-structure questions.
  Use to-prd only after the grill gate has resolved or explicitly deferred core uncertainties.
  Stop for User PRD Approval.
  Use to-issues.
  Stop for User Issue Approval, including issue granularity, dependency order, and HITL/AFK classification.
  Write the task brief.
```

- [x] **Step 2: Replace section 4 with an operational module gate**

Replace the section body under `## 4. Module Structure Is Not Invented Inline` with:

```markdown
Module type and folder standards are not decided ad hoc.

Creating or changing module types and folder standards is itself substantive work and follows the Full Workflow.

If `modules/` is empty, or if `harness/state/module-structure.md` says no project module structure has been approved, Codex must not create product module folders or write product code.

Before product module work starts, Codex must:

1. Use the Grill Routing And Completion Gate to understand the request.
2. Propose two or three module structure options in plain language.
3. Recommend one option with reasoning.
4. Ask the user to approve or revise the module structure.
5. Record the approved structure in:

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
```

- [x] **Step 3: Verify rules text**

Run:

```powershell
rg -n "grill-me|grill-with-docs|Module Structure Gate|no project module structure|HITL/AFK" harness/rules/rules.md
```

Expected:

- `grill-me` and `grill-with-docs` both appear.
- `Module Structure Gate` appears.
- `HITL/AFK` appears.

---

### Task 4: Update `AGENTS.md` High-Level Rules

**Files:**
- Modify: `AGENTS.md`

- [x] **Step 1: Add grill routing to `Always Use`**

Under `## Always Use`, after the Matt Pocock planning skills bullet, add:

```markdown
- During planning, choose `grill-with-docs` when existing code, docs, candidate lists, domain glossary, ADRs, or prior implementations can answer or sharpen the request. Choose `grill-me` when the request is greenfield, product-intent driven, or lacks enough existing project evidence. If both apply, use `grill-with-docs` first and `grill-me` only for remaining user-intent uncertainties.
- A grill session is not complete until core uncertainties are resolved or explicitly deferred. Ask one user-facing question at a time, wait for the user's answer, do not ask duplicate questions already answered by inspected evidence, and record the grill result in `harness/docs/tasks/active/<slug>/grill.md` before moving to PRD, issues, module structure, writing plan, or implementation.
```

- [x] **Step 2: Add module structure hard rule**

Under `## Hard Rules`, after `Do not invent module folders outside the approved module structure.`, add:

```markdown
- If `modules/` is empty or `harness/state/module-structure.md` says no module structure is approved, stop before product module folders or product code. Use the planning gate to propose and approve module structure first, then record it in `harness/state/module-structure.md`.
```

- [x] **Step 3: Verify AGENTS text**

Run:

```powershell
rg -n "grill-me|grill-with-docs|grill session is not complete|grill.md|modules/.*empty|module-structure.md" AGENTS.md
```

Expected:

- Both grill skill names appear.
- The grill completion behavior appears.
- `grill.md` appears.
- `module-structure.md` appears in the new hard rule.

---

### Task 5: Update README For Human Readers

**Files:**
- Modify: `README.md`

- [x] **Step 1: Update the visible default workflow list**

In `README.md`, replace the default full workflow list:

```markdown
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
```

with:

```markdown
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
```

- [x] **Step 2: Add a planning behavior section**

Add this section near the workflow explanation:

```markdown
## Planning Behavior

짬뽕하네스는 바로 PRD나 module 구조로 가지 않습니다.

Planning starts by choosing the right grilling flow:

- `grill-with-docs`: use when existing code, docs, candidate lists, domain glossary, ADRs, or prior implementations can answer or sharpen the request.
- `grill-me`: use when the request is greenfield, product-intent driven, or lacks enough existing project evidence.

For example, if a user asks for a 나라장터 crawler and mentions an existing `dailynara` folder, Codex should inspect `dailynara` first with `grill-with-docs`. It should ask the user only for decisions that the code cannot answer.

The grill phase asks one question at a time and records the route, inspected evidence, answered questions, deferred unknowns, and remaining decisions in `harness/docs/tasks/active/<slug>/grill.md`. PRD, issue breakdown, module structure, writing plan, and implementation wait until core uncertainties are resolved or explicitly deferred.

If `modules/` is empty or `harness/state/module-structure.md` says no module structure is approved, Codex must decide module structure with the user before creating product module folders. If the request cannot create or change product module folders or product code, Codex records the Module Structure Gate as not applicable and does not ask module-structure questions.
```

- [x] **Step 3: Verify README text**

Run:

```powershell
rg -n "Planning Behavior|Grill Routing And Completion Gate|Grill Result Record|Module Structure Gate|grill-with-docs|grill-me|dailynara|modules/.*empty" README.md
```

Expected:

- The planning behavior heading appears.
- The visible default workflow contains the new gate names.
- Both grill skill names appear.
- The `dailynara` example appears.

---

### Task 6: Delete Approved Proposal

**Files:**
- Delete: `proposals/2026-06-02-grill-module-gates.md`

- [x] **Step 1: Delete the proposal after live rules are updated**

Use `apply_patch` to delete:

```text
proposals/2026-06-02-grill-module-gates.md
```

- [x] **Step 2: Verify proposal removal**

Run:

```powershell
Test-Path -LiteralPath 'proposals/2026-06-02-grill-module-gates.md'
```

Expected output:

```text
False
```

---

### Task 7: Verification

**Files:**
- No file edits unless a verification failure identifies a required correction.

- [x] **Step 1: Run deterministic text checks**

Run:

```powershell
rg -n "Grill Routing And Completion Gate|Grill Result Record|Module Structure Gate|grill-me|grill-with-docs|HITL/AFK|grill.md" AGENTS.md README.md harness/rules/workflow.md harness/rules/rules.md harness/rules/module-types.md
```

Expected:

- Matches in all intended governance surfaces.

- [x] **Step 2: Verify the old full-workflow shortcut is gone**

Run:

```powershell
$stale = Select-String -LiteralPath 'AGENTS.md','README.md','harness/rules/workflow.md','harness/rules/rules.md','harness/rules/module-types.md' -Pattern '^\s*3\.\s+grill-with-docs\s*$','setup-matt-pocock-skills readiness check, grill-with-docs, to-prd','-> grill-with-docs','gh repo create .*--template','git -C ''F:/mptech'' push'
if ($stale) {
  $stale
  throw 'Stale planning, installer, or push shortcut remains'
}
Write-Output 'No stale planning, installer, or push shortcut'
```

Expected output:

```text
No stale planning, installer, or push shortcut
```

- [x] **Step 3: Verify no proposal remains**

Run:

```powershell
Test-Path -LiteralPath 'proposals/2026-06-02-grill-module-gates.md'
```

Expected output:

```text
False
```

- [x] **Step 4: Verify module default state is still conservative**

Run:

```powershell
Get-Content -LiteralPath 'harness/state/module-structure.md'
```

Expected:

```text
# Module Structure

No project module structure has been approved.

Module types and folder standards must be approved through the Module Structure Gate in the Full Workflow before product modules are created.

When approved, record:

- Project Module Types
- Folder Set For Each Module Type
- Active Modules
- Deferred Modules
- Extra Folders And Reasons
```

- [x] **Step 5: Run install smoke test**

Run:

```powershell
$tempBase = (Resolve-Path -LiteralPath ([IO.Path]::GetTempPath())).Path.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$target = Join-Path $tempBase ('jjamppong-grill-gate-smoke-' + [guid]::NewGuid().ToString('N'))
try {
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-jjamppong-harness.ps1 'F:\Folder\ourosuper-harness' $target -ProjectRepo 'https://github.com/vibedong/install-test-project.git' -SkipGitHubRepo
  if ($LASTEXITCODE -ne 0) { throw "installer exited with $LASTEXITCODE" }
  foreach ($required in @('AGENTS.md','README.md','harness','modules','module-template','proposals')) {
    if (-not (Test-Path -LiteralPath (Join-Path $target $required))) { throw "Missing $required" }
  }
  rg -n "Grill Routing And Completion Gate|Grill Result Record|Module Structure Gate|grill-me|grill-with-docs|grill.md" (Join-Path $target 'AGENTS.md') (Join-Path $target 'README.md') (Join-Path $target 'harness/rules/workflow.md') (Join-Path $target 'harness/rules/rules.md') (Join-Path $target 'harness/rules/module-types.md')
  if ($LASTEXITCODE -ne 0) { throw 'Installed copy is missing grill/module gate text' }
  $stale = Select-String -LiteralPath (Join-Path $target 'README.md'),(Join-Path $target 'harness/rules/workflow.md'),(Join-Path $target 'AGENTS.md'),(Join-Path $target 'harness/rules/module-types.md') -Pattern '^\s*3\.\s+grill-with-docs\s*$','setup-matt-pocock-skills readiness check, grill-with-docs, to-prd','-> grill-with-docs','gh repo create .*--template'
  if ($stale) { throw 'Installed copy still has stale planning or installer shortcut' }
  foreach ($taskArtifactDir in @((Join-Path $target 'harness/docs/tasks/active'), (Join-Path $target 'harness/docs/tasks/archive'))) {
    $taskArtifacts = @(Get-ChildItem -LiteralPath $taskArtifactDir -Force)
    if ($taskArtifacts.Count -ne 0) { throw "Installed task artifact directory is not empty: $taskArtifactDir" }
  }
  Write-Output 'Install smoke passed'
}
finally {
  if (Test-Path -LiteralPath $target) {
    $resolved = (Resolve-Path -LiteralPath $target).Path
    if (-not $resolved.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or -not (Split-Path -Leaf $resolved).StartsWith('jjamppong-grill-gate-smoke-')) {
      throw "Refusing to remove unexpected temp target: $resolved"
    }
    Remove-Item -LiteralPath $resolved -Recurse -Force
  }
}
```

Expected:

- Installer completes.
- Required root files exist.
- Installed copy contains the new grill/module gate text, including `module-types.md`.
- Installed copy has no stale planning shortcut.
- Installed copy has no direct GitHub template clone install command.
- Installed task artifact directories start empty.
- Temporary target is removed.

- [x] **Step 6: Run git diff checks**

Run:

```powershell
git diff --check
git status --short --branch
```

Expected:

- `git diff --check` exits 0.
- `git status` shows only the intended governance/state changes and task artifacts.

---

## Self-Review

**Spec coverage:** This plan covers situational use of `grill-with-docs` and `grill-me`, one-question-at-a-time completion gating, task-specific `grill.md` output before PRD, `to-prd` as synthesis after grilling, `to-issues` user approval details, README workflow consistency, stale workflow checks, `module-types.md` consistency, non-module no-op handling for the Module Structure Gate, and empty `modules/` / unapproved module structure protection.

**Placeholder scan:** No forbidden placeholder tokens from the plan-writing rules are present. Every file path and command is concrete.

**Type consistency:** The public labels are consistent across tasks: `Grill Routing And Completion Gate`, `Grill Result Record`, `Module Structure Gate`, `grill-with-docs`, `grill-me`, `to-prd`, `to-issues`, `harness/docs/tasks/active/<slug>/grill.md`, and `harness/state/module-structure.md`.

## Execution Handoff

Plan executed and saved to `harness/docs/tasks/active/2026-06-02-grill-module-gates/writing-plan.md`.

Plan review option 1 was selected and completed: CEO + Eng + Plan Compliance.

Execution status:

- Proposal was created and approved.
- Live rule files were updated.
- Approved proposal was deleted.
- Branch subagent review found follow-up issues, which were corrected.
- README expected harness scenario was added after the final review at the user's request.
- Final verification is recorded in `verification.md`.

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `plan-ceo-review` + branch subagent | Scope & strategy | 5 | clear | Added `grill.md`, kept the non-module no-op, removed direct template clone install paths, and final CEO review found no blocker. |
| Eng Review | `plan-eng-review` + branch subagent | Architecture & tests | 5 | clear | Updated `module-types.md`, clarified module gate ordering, fixed installer preflight/origin/fail-safe behavior, and final Eng review found no blocker. |
| Plan Compliance | writing-plan self-review + branch subagent | Harness workflow compliance | 5 | clear | Proposal-first was followed, scope expansion approval is recorded, proposal was removed, task artifacts are listed, and final Plan Compliance review found no blocker. |

- **UNRESOLVED:** 0 branch-review blockers remain.
- **VERDICT:** CEO + ENG + PLAN COMPLIANCE CLEARED for commit/push review. Commit and push still require explicit user approval.
