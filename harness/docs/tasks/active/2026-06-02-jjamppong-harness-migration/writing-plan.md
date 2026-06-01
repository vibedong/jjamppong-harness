# Jjamppong Harness Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans for this current dirty worktree. Use superpowers:subagent-driven-development only after pausing this plan, protecting/isolation dirty changes in a user-approved way, and revising the recorded baseline. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the OuroSuper-centered planning flow with 짬뽕하네스, a mandatory workflow that combines Matt Pocock planning skills, Superpowers execution planning, gstack review lenses, Compound Engineering learning, and vowline discipline.

**Architecture:** Keep the repository as a private project-template harness, but move AI-generated planning artifacts into `harness/docs/tasks/active/<slug>/` while keeping `harness/state/` as a small pointer/status area. Preserve root `handoff.md` as the next-chat context transfer file, not a per-task artifact.

**Tech Stack:** Markdown governance files, Codex skills, Matt Pocock skills, Superpowers skills, gstack review skills, Compound Engineering `ce-compound`, Git/GitHub template workflow.

---

## Current Evidence

- Repository: `F:/Folder/ourosuper-harness`
- Current branch: `main`
- Baseline commit before migration execution: `13af545`
- Existing dirty files before this plan revision: `AGENTS.md`, `README.md`, `harness/rules/rules.md`
- Existing dirty changes are branch/commit safety rules. Preserve them.
- This plan file is the canonical AI planning artifact for this migration: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md`
- Do not commit, push, create PRs, merge, or release without explicit user approval in the current chat.
- Do not edit `F:/mptech` during this migration unless the user separately asks to sync the project repo.
- Do not edit official Matt Pocock, Superpowers, Compound, gstack, or OuroSuper plugin sources for this migration.
- Current tracked root docs file before execution: `docs/solutions/.gitkeep`.
- Current obsolete tracked state placeholders before execution: `harness/state/ourosuper/.gitkeep`, `harness/state/superpowers/.gitkeep`, `harness/state/verification/.gitkeep`.

## Final Decisions

- Harness display name: `짬뽕하네스`
- ASCII name: `jjamppong-harness`
- Root `handoff.md`: keep as the global next-chat/context-transfer file.
- Task-specific planning summary: use `brief.md`, not another handoff file.
- AI planning artifacts: store under `harness/docs/tasks/active/<slug>/`.
- Completed task artifacts: archive by default under `harness/docs/tasks/archive/<slug>/`.
- `harness/state/`: keep only current state and pointers.
- `harness/docs/solutions/`: keep long-lived reusable AI learning here, not under `harness/state/`.
- Root `docs/`: remove from the target structure. It should not be used for AI planning outputs.
- `CONTEXT.md`: keep at repo root because Matt Pocock `grill-with-docs` expects that convention.
- Matt Pocock skills: required external skills, not vendored into the template.
- No Fast Lane or Short Loop is restored in this migration because the user explicitly chose one mandatory path for small and large tasks.

## Target Workflow

```text
Request Intake
-> setup-matt-pocock-skills readiness check
-> grill-with-docs
-> to-prd
-> User PRD Approval
-> to-issues
-> User Issue Approval
-> task brief
-> superpowers:writing-plans
-> Mandatory Plan Review Question
-> Implementation / Apply
-> Verification
-> ce-compound
-> Archive Task Artifacts
-> Learning Update Question
```

No task-size bypass. No direct implementation before the full gate.

## Target Directory Model

```text
<project-root>/
  AGENTS.md
  README.md
  CONTEXT.md
  handoff.md

  harness/
    rules/
      workflow.md
      rules.md
      module-types.md

    state/
      intake.md
      planning.md
      module-structure.md
      compound.md

    docs/
      agents/
        issue-tracker.md
        triage-labels.md
        domain.md
      adr/
      solutions/
      tasks/
        active/
          <YYYY-MM-DD-short-topic>/
            prd.md
            issues/
              001-*.md
            brief.md
            writing-plan.md
            reviews.md
            verification.md
        archive/
          <YYYY-MM-DD-short-topic>/

  modules/
  module-template/
  proposals/
```

## State Pointer Contract

`harness/state/planning.md` must stay short. It records only the active task slug, phase, artifact links, and archive status.

Example content:

```markdown
# Planning State

Active task: 2026-06-02-jjamppong-harness-migration
Phase: writing-plan

Artifacts:
- PRD: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md
- Issues: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/
- Brief: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md
- Writing plan: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md
- Reviews: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md
- Verification: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md

Archive policy: move to harness/docs/tasks/archive/<slug>/ after verification and ce-compound unless the user explicitly chooses otherwise.
```

## Mistake Guardrails

- Do not agree with a structure just because the user suggested it. State tradeoffs when a suggestion weakens the harness.
- Do not put long-lived documents under `harness/state/`.
- Do not create root `docs/prd`, `docs/issues`, `docs/handoff`, `docs/superpowers`, or `docs/verification`.
- Do not create a second task handoff path. Use root `handoff.md` for global next-chat handoff and `brief.md` for task summary.
- Do not remove existing branch/commit safety changes.
- Do not leave conceptual `OuroSuper Planning`, `Seed YAML`, `handoff-packet`, `harness/state/ourosuper/`, or `Short Loop` references in live workflow docs.
- Do not vendor-copy Matt Pocock skill files.
- Do not keep an approved proposal file as archive after live rules are updated.
- Do not restore Short Loop, Fast Lane, or task-size bypass unless the user explicitly changes the decision in a later chat.
- Do not use fresh worktrees or subagent workers for live edits while `AGENTS.md`, `README.md`, and `harness/rules/rules.md` have uncommitted safety-rule changes. Execute live edits sequentially in the current dirty worktree for this plan. If the user later approves commit, stash, or branch isolation, stop and revise this plan's baseline before executing.
- Negative `rg` checks must be wrapped so the expected "no matches" case exits successfully.
- Use `2026-06-02-jjamppong-harness-migration` for this migration's real task artifact paths. Use `<slug>` or `<YYYY-MM-DD-short-topic>` only when writing reusable template text into live docs.
- Use `apply_patch` for file edits.

## Review Decisions

- Accepted: make implementation steps more concrete, add exact state/review artifacts, add Matt Pocock skill readiness docs, add ADR, strengthen verification, preserve dirty-worktree safety, and replace old workflow sections completely.
- Rejected: restore a user-owned Fast Lane. This conflicts with the user's explicit decision that small and large tasks follow the same mandatory planning gate.

## File Map

- Modify: `AGENTS.md`
  - Current anchors: `## Always Use`, `## Harness Root Model`, request-intake rule, root handoff rule.
  - Rename the harness identity to `짬뽕하네스`.
  - Replace project request trigger from `run OuroSuper Planning` to the mandatory planning gate.
  - Add required external skills.
  - Keep existing branch/commit safety rules.

- Modify: `README.md`
  - Current anchors: document title, installation section, quick start section, directory layout section, workflow section.
  - Rewrite the public explanation from `OuroSuper Harness` to `짬뽕하네스`.
  - Replace installation and quick-start language that tells Codex to start OuroSuper planning.
  - Document `harness/docs/tasks/active/<slug>/` as the review surface.
  - Explain that the GitHub repo name may remain `ourosuper-harness` as a legacy source URL.

- Modify: `harness/rules/workflow.md`
  - Current anchors: `## Full Workflow`, `## OuroSuper Planning`, `## Mandatory Plan Review Question`, `## Verification`, `## ce-compound`, `## Optional Handoff Update`, `## Short Loop Exception`.
  - Replace the full workflow.
  - Delete Short Loop.
  - Add PRD approval, issue breakdown approval, task brief, review, verification, ce-compound, archive, and learning update steps.
  - Override Superpowers writing-plan output to `harness/docs/tasks/active/<slug>/writing-plan.md`.

- Modify: `harness/rules/rules.md`
  - Current anchors: `## Required Plugins And Skills`, `## 3. User-Owned Exceptions`, artifact path list, branch/commit control section.
  - Replace the `OuroSuper Planning` required skill block with the Matt Pocock planning gate.
  - Remove user-owned Short Loop exceptions.
  - Add `harness/docs/` artifact paths.
  - Keep branch/commit control section.

- Modify: `harness/rules/module-types.md`
  - Current anchors: old workflow sequence block and module workflow references.
  - Replace the old workflow sequence with the new mandatory planning gate.

- Modify: `handoff.md`
  - Current anchor: first heading/top-of-file global handoff note.
  - Clarify that root `handoff.md` is the global next-chat/context-transfer file.
  - State that task summaries belong in `harness/docs/tasks/active/<slug>/brief.md`.

- Modify: `harness/state/compound.md`
  - Replace root `docs/solutions/` learning path with `harness/docs/solutions/`.
  - Keep the file as a short pointer/index, not a long learning document.

- Create: `harness/state/planning.md`
  - Record the active task slug, phase, task artifact links, and archive policy.

- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md`
  - Record the PRD for this migration so the migration itself follows the new mandatory gate.

- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/001-jjamppong-harness-migration.md`
  - Record the first executable issue for this migration.

- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md`
  - Preserve the approved decision summary after the proposal is deleted.

- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md`
  - Capture Mandatory Plan Review Question choice, reviewer outputs, user decisions, and skipped-review reasons.

- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md`
  - Capture final verification command output and result.

- Create: `CONTEXT.md`
  - Define glossary terms for `짬뽕하네스`, `planning gate`, `task artifact`, `brief`, `writing plan`, `module`, and `proposal`.

- Create: `harness/docs/adr/2026-06-02-jjamppong-planning-gate.md`
  - Record why the harness moved from OuroSuper-centered planning to 짬뽕하네스.

- Create: `harness/docs/agents/matt-pocock-skills.md`
  - Record required Matt Pocock skills, readiness checks, install command, and blocker message.

- Create: `harness/docs/agents/issue-tracker.md`
  - Set local markdown task issues as the default.
  - Define `harness/docs/tasks/active/<slug>/issues/001-*.md`.

- Create: `harness/docs/agents/triage-labels.md`
  - Record canonical roles for local markdown task issues.

- Create: `harness/docs/agents/domain.md`
  - Record single-context docs layout: root `CONTEXT.md` plus `harness/docs/adr/`.

- Create placeholders:
  - `harness/docs/adr/.gitkeep`
  - `harness/docs/solutions/.gitkeep`
  - `harness/docs/tasks/active/.gitkeep`
  - `harness/docs/tasks/archive/.gitkeep`

- Delete:
  - `docs/solutions/.gitkeep`
  - `harness/state/ourosuper/.gitkeep`
  - `harness/state/superpowers/.gitkeep`
  - `harness/state/verification/.gitkeep`
  - Empty root docs directories after tracked placeholders are removed: `docs/solutions/`, `docs/superpowers/plans/`, `docs/superpowers/`, `docs/`.

## Task 1: Write The Migration Proposal

**Files:**
- Create: `proposals/2026-06-02-jjamppong-harness-migration.md`

- [ ] **Step 1: Create the proposal file**

Use `apply_patch` to add `proposals/2026-06-02-jjamppong-harness-migration.md` with this exact content:

```markdown
# 짬뽕하네스 Migration Proposal

## Decision

Replace the OuroSuper-centered planning flow with 짬뽕하네스.

## Required Flow

Every task, regardless of size, must pass through:

1. Request Intake
2. setup-matt-pocock-skills readiness check
3. grill-with-docs
4. to-prd
5. User PRD Approval
6. to-issues
7. User Issue Approval
8. task brief
9. superpowers:writing-plans
10. Mandatory Plan Review Question
11. Implementation / Apply
12. Verification
13. ce-compound
14. Archive Task Artifacts
15. Learning Update Question

## Artifact Contract

- Active task folder: `harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/`
- Archived task folder: `harness/docs/tasks/archive/<YYYY-MM-DD-short-topic>/`
- PRD: `harness/docs/tasks/active/<slug>/prd.md`
- Issues: `harness/docs/tasks/active/<slug>/issues/001-*.md`
- Brief: `harness/docs/tasks/active/<slug>/brief.md`
- Writing plan: `harness/docs/tasks/active/<slug>/writing-plan.md`
- Reviews: `harness/docs/tasks/active/<slug>/reviews.md`
- Verification: `harness/docs/tasks/active/<slug>/verification.md`
- Long-lived learning: `harness/docs/solutions/`
- State pointers: `harness/state/planning.md`
- Global next-chat handoff: `handoff.md`

## Replacements

- Replace `OuroSuper Planning` with Matt Pocock `grill-with-docs`.
- Replace Seed YAML and handoff-packet with PRD, issues, brief, and writing-plan artifacts.
- Remove Short Loop and small-task bypass.
- Do not use root `docs/` for AI planning artifacts.

## Non-Goals

- Do not rename the GitHub repository in this change.
- Do not vendor Matt Pocock skill files.
- Do not modify official Matt Pocock, Superpowers, Compound, or gstack plugins.
- Do not touch project repositories such as `F:/mptech`.
```

- [ ] **Step 2: Verify proposal exists**

Run:

```powershell
if (-not (Test-Path -LiteralPath 'proposals/2026-06-02-jjamppong-harness-migration.md')) {
  throw "Missing approved proposal file"
}
"OK: proposal exists"
```

Expected: `OK: proposal exists`

- [ ] **Step 3: Ask for approval**

Ask the user:

```text
proposal 기준으로 live rule 반영 진행할까요?
```

Do not continue to Task 2 until the user approves.

## Task 2: Add The Harness Docs Layout

**Files:**
- Create: `harness/docs/adr/.gitkeep`
- Create: `harness/docs/solutions/.gitkeep`
- Create: `harness/docs/tasks/active/.gitkeep`
- Create: `harness/docs/tasks/archive/.gitkeep`

- [ ] **Step 1: Add new placeholder files**

Use `apply_patch` to add the four new `.gitkeep` files under `harness/docs/` with this exact content:

```patch
*** Begin Patch
*** Add File: harness/docs/adr/.gitkeep
+# keep
*** Add File: harness/docs/solutions/.gitkeep
+# keep
*** Add File: harness/docs/tasks/active/.gitkeep
+# keep
*** Add File: harness/docs/tasks/archive/.gitkeep
+# keep
*** End Patch
```

- [ ] **Step 2: Verify the new layout**

Run:

```powershell
$paths = @(
  'harness/docs/adr/.gitkeep',
  'harness/docs/solutions/.gitkeep',
  'harness/docs/tasks/active/.gitkeep',
  'harness/docs/tasks/archive/.gitkeep'
)
foreach ($path in $paths) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing new layout placeholder: $path"
  }
}
"OK: new layout placeholders exist"
```

Expected: `OK: new layout placeholders exist`

## Task 3: Add Matt Pocock Agent Setup Docs

**Files:**
- Create: `CONTEXT.md`
- Create: `harness/docs/agents/matt-pocock-skills.md`
- Create: `harness/docs/agents/issue-tracker.md`
- Create: `harness/docs/agents/triage-labels.md`
- Create: `harness/docs/agents/domain.md`

- [ ] **Step 1: Add `CONTEXT.md`**

Use `apply_patch` with this exact content:

```markdown
# 짬뽕하네스 Context

## Language

**짬뽕하네스**:
A private agent workflow harness that combines Matt Pocock planning skills, Superpowers execution planning, gstack review lenses, Compound Engineering learning, and vowline discipline.
Avoid: calling the whole harness Matt Planning Harness or OuroSuper Harness.

**Planning gate**:
The mandatory pre-implementation sequence that every task must pass before execution.

**Task artifact**:
A file created under `harness/docs/tasks/active/<slug>/` while planning, reviewing, implementing, or verifying a task.

**Brief**:
The task-specific summary at `harness/docs/tasks/active/<slug>/brief.md`. This is not the same as root `handoff.md`.

**Writing plan**:
A Superpowers implementation plan at `harness/docs/tasks/active/<slug>/writing-plan.md`.

**Module**:
Product or application code under `modules/`, created only after approved module structure exists.

**Proposal**:
A pending harness rule change under `proposals/`, used before changing live rules.

## Relationships

- The planning gate creates a PRD.
- A PRD is decomposed into one or more local task issues.
- The task issues inform the brief and writing plan.
- The writing plan controls implementation.
- Verification and Compound Engineering run after implementation.
- Finished task artifacts move from `harness/docs/tasks/active/` to `harness/docs/tasks/archive/`.
```

- [ ] **Step 2: Add `harness/docs/agents/matt-pocock-skills.md`**

Use `apply_patch` with this exact content:

````markdown
# Matt Pocock Skills

짬뽕하네스 requires these external Matt Pocock skills:

- `setup-matt-pocock-skills`
- `grill-with-docs`
- `to-prd`
- `to-issues`

## Readiness Check

Before the planning gate continues, the agent must verify that the required skills are available in the current Codex skill list or installed skill directories.

Use this readiness command in PowerShell when the visible skill list is unavailable:

```powershell
$required = @(
  'setup-matt-pocock-skills',
  'grill-with-docs',
  'to-prd',
  'to-issues'
)
$roots = @(
  (Join-Path $env:USERPROFILE '.codex/skills'),
  (Join-Path $env:USERPROFILE '.agents/skills')
)
$skillFiles = foreach ($root in $roots) {
  if (Test-Path -LiteralPath $root) {
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'SKILL.md' -ErrorAction SilentlyContinue
  }
}
$missing = foreach ($skill in $required) {
  $found = $skillFiles | Where-Object {
    Select-String -LiteralPath $_.FullName -Pattern "name: $skill" -Quiet
  }
  if (-not $found) { $skill }
}
if ($missing) {
  $missing
  throw "Missing required Matt Pocock planning skills"
}
"OK: all Matt Pocock planning skills available"
```

If any required skill is unavailable, stop and tell the user:

```text
Matt Pocock planning skills are required before this harness can continue.
Install them first, then rerun this task.
```

## Install Reference

Use the official installer when available:

```bash
npx skills@latest add mattpocock/skills
```

Do not vendor-copy the skill files into this repository.
````

- [ ] **Step 3: Add `harness/docs/agents/issue-tracker.md`**

Use `apply_patch` with this exact content:

```markdown
# Issue Tracker

This harness uses local markdown task issues by default.

Issues live under `harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/issues/`.

Each issue is a vertical slice that can be reviewed or implemented independently.

Do not publish issues to GitHub Issues unless the user explicitly asks for that in the current chat.
```

- [ ] **Step 4: Add `harness/docs/agents/triage-labels.md`**

Use `apply_patch` with this exact content:

```markdown
# Triage Labels

Local markdown issues use these canonical roles:

- `needs-triage` - maintainer needs to evaluate
- `needs-info` - waiting on user input
- `ready-for-agent` - ready for AFK agent work
- `ready-for-human` - requires human judgment or external access
- `wontfix` - will not be actioned

For local markdown issues, record the role in the issue body instead of applying a GitHub label.
```

- [ ] **Step 5: Add `harness/docs/agents/domain.md`**

Use `apply_patch` with this exact content:

```markdown
# Domain Docs

This harness uses a single-context documentation layout.

Required files:

- Root glossary: `CONTEXT.md`
- Architecture decisions: `harness/docs/adr/`

Consumer rules:

- `CONTEXT.md` is a glossary, not a PRD or scratch pad.
- ADRs are for decisions that are hard to reverse, surprising without context, and chosen after a real trade-off.
- Do not create ADRs for routine implementation details.
```

- [ ] **Step 6: Verify files**

Run:

```powershell
$paths = @(
  'CONTEXT.md',
  'harness/docs/agents/matt-pocock-skills.md',
  'harness/docs/agents/issue-tracker.md',
  'harness/docs/agents/triage-labels.md',
  'harness/docs/agents/domain.md'
)
foreach ($path in $paths) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required agent doc: $path"
  }
}
"OK: agent docs exist"
```

Expected: `OK: agent docs exist`

## Task 4: Add Current Task State, Review Surface, And ADR

**Files:**
- Create: `harness/state/planning.md`
- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md`
- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/001-jjamppong-harness-migration.md`
- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md`
- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md`
- Create: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md`
- Create: `harness/docs/adr/2026-06-02-jjamppong-planning-gate.md`

- [ ] **Step 1: Add `harness/state/planning.md`**

Use `apply_patch` with this exact content:

```markdown
# Planning State

Active task: 2026-06-02-jjamppong-harness-migration
Phase: writing-plan

Artifacts:
- PRD: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md
- Issues: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/
- Brief: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md
- Writing plan: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md
- Reviews: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md
- Verification: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md

Archive policy: move to harness/docs/tasks/archive/2026-06-02-jjamppong-harness-migration/ after verification and ce-compound unless the user explicitly chooses otherwise.
```

- [ ] **Step 2: Add `prd.md`**

Use `apply_patch` with this exact content:

```markdown
# PRD: 짬뽕하네스 Migration

## Problem

The current harness still documents OuroSuper-centered planning, root `docs/` AI artifacts, and Short Loop exceptions. That conflicts with the user's decision to use one mandatory planning gate for every task.

## Goals

- Rename the live workflow to 짬뽕하네스.
- Store AI task artifacts under `harness/docs/tasks/active/<slug>/`.
- Keep `harness/state/` as pointer/status only.
- Keep root `handoff.md` as global next-chat handoff.
- Replace OuroSuper planning with Matt Pocock planning skills, Superpowers writing plans, gstack reviews, Compound Engineering, and vowline.
- Document installation so applying the template to an existing project root does not create a nested `ourosuper-harness/` folder.

## Non-Goals

- Do not rename the GitHub repository URL in this migration.
- Do not vendor-copy Matt Pocock skill files.
- Do not restore Short Loop or Fast Lane.
```

- [ ] **Step 3: Add first issue**

Use `apply_patch` with this exact content:

```markdown
# Issue 001: Migrate Live Harness Governance To 짬뽕하네스

## Scope

Update the live harness docs and rules so the template uses 짬뽕하네스 as the mandatory planning and execution workflow.

## Acceptance Criteria

- `AGENTS.md`, `README.md`, `harness/rules/workflow.md`, `harness/rules/rules.md`, and `harness/rules/module-types.md` no longer instruct agents to run OuroSuper Planning.
- Root `docs/` is not part of the target installed project layout.
- Reusable learning points to `harness/docs/solutions/`.
- Task artifacts for this migration include `prd.md`, this issue, `brief.md`, `writing-plan.md`, `reviews.md`, and `verification.md`.
- Verification records deterministic command output before completion.
```

- [ ] **Step 4: Add `brief.md`**

Use `apply_patch` with this exact content:

```markdown
# 짬뽕하네스 Migration Brief

## Decision

Replace the OuroSuper-centered planning flow with 짬뽕하네스.

## User Decisions

- Use one mandatory planning path for small and large tasks.
- Store AI planning artifacts under `harness/docs/tasks/active/<slug>/`.
- Move completed task artifacts to `harness/docs/tasks/archive/<slug>/` by default.
- Keep root `handoff.md` as the global next-chat/context-transfer file.
- Use `brief.md` for task-specific summaries.
- Store reusable AI learning under `harness/docs/solutions/`.
- Keep `CONTEXT.md` at the repository root for Matt Pocock compatibility.

## Approval Record

- Approval date: 2026-06-02
- Approved proposal path before deletion: `proposals/2026-06-02-jjamppong-harness-migration.md`
- User decision: proceed with the 짬뽕하네스 migration plan and use one mandatory planning path for small and large tasks.

## Artifact Links

- PRD: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md`
- Issue 001: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/001-jjamppong-harness-migration.md`
- Writing plan: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md`
- Reviews: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md`
- Verification: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md`
```

- [ ] **Step 5: Add `reviews.md`**

Use `apply_patch` with this exact content:

```markdown
# Reviews

## Mandatory Plan Review Question

구현으로 넘어가기 전에 리뷰를 실행할까요?

추천: 일반 작업은 CEO/제품전략 리뷰와 엔지니어링 리뷰를 둘 다 실행합니다.

하네스 규칙, workflow, 설치 방식, artifact topology를 바꾸는 작업은 Plan Compliance 리뷰도 함께 실행합니다.

A. CEO + Eng + Plan Compliance
B. CEO + Eng
C. Eng only
D. 이번에는 생략

If the user chooses D, say:

리뷰를 생략하면 범위를 잘못 잡거나, 검증이 약해지거나, 나중에 다시 고칠 가능성이 커집니다. 그래도 구현으로 진행할까요?

## Review Log

- Status: pending
- Selected option:
- Reviewers:
- Findings:
- User decisions:
- Skipped reason:
```

- [ ] **Step 6: Add `verification.md`**

Use `apply_patch` with this exact content:

```markdown
# Verification

Status: pending

Commands:

- `git status --short --branch`
- markdown fence check
- forbidden old path check
- required new path check
- task artifact existence check

Result:
```

- [ ] **Step 7: Add ADR**

Use `apply_patch` with this exact content:

```markdown
# ADR: Use 짬뽕하네스 Planning Gate

## Status

Accepted after proposal approval.

## Context

The previous harness centered planning on OuroSuper interview, Seed YAML, and handoff-packet concepts. That flow made the harness depend on a planning runtime and produced confusion around missing ambiguity scores, duplicated handoff meanings, and scattered AI artifacts.

## Decision

Use 짬뽕하네스 as the harness workflow. The planning gate combines Matt Pocock planning skills, Superpowers writing plans, gstack review, Compound Engineering learning, and vowline discipline.

AI task artifacts live under `harness/docs/tasks/active/<slug>/` while in progress and move to `harness/docs/tasks/archive/<slug>/` after completion by default. Long-lived reusable learning lives under `harness/docs/solutions/`. `harness/state/` stores only small pointer/status files.

## Alternatives Considered

- Keep OuroSuper as the planning engine.
- Store AI artifacts under root `docs/`.
- Put reusable solutions under `harness/state/`.
- Restore a small-task bypass.

## Consequences

- The workflow is more explicit and easier to audit.
- Every task creates more planning artifacts.
- The user reviews one active task folder during work, then mostly works from `modules/` after approval.
- Root `handoff.md` keeps its original next-chat role.

## Rollback

Reintroduce a proposal that restores the previous workflow and updates `harness/rules/`, README, and AGENTS.md together. Do not partially restore OuroSuper terms without restoring the full old workflow.
```

- [ ] **Step 8: Verify files**

Run:

```powershell
$paths = @(
  'harness/state/planning.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/001-jjamppong-harness-migration.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md',
  'harness/docs/adr/2026-06-02-jjamppong-planning-gate.md'
)
foreach ($path in $paths) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required planning artifact: $path"
  }
}
"OK: planning artifacts exist"
```

Expected: `OK: planning artifacts exist`

## Task 5: Rewrite The Live Workflow

**Files:**
- Modify: `harness/rules/workflow.md`

- [ ] **Step 1: Replace workflow intro sentence**

Replace the sentence under `## Full Workflow` with:

```markdown
Every substantive task follows this workflow. There is no task-size bypass unless the user explicitly changes the harness rules in a later approved proposal.
```

- [ ] **Step 2: Replace `## Full Workflow` list**

Change the list to:

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

- [ ] **Step 3: Replace the old `## OuroSuper Planning` section**

Replace it with a `## Matt Pocock Planning Gate` section that states:

```markdown
Every task uses Matt Pocock planning skills before implementation.

1. Verify `setup-matt-pocock-skills` output exists.
2. Run `grill-with-docs`.
3. Produce `harness/docs/tasks/active/<slug>/prd.md` with `to-prd`.
4. Stop and ask the user to approve or revise the PRD before issue decomposition.
5. Decompose the approved PRD into `harness/docs/tasks/active/<slug>/issues/001-*.md` with `to-issues`.
6. Stop and ask the user to approve or revise the issue breakdown before writing the implementation plan.
7. Produce `harness/docs/tasks/active/<slug>/brief.md`.

No task may skip this gate because it appears small.
```

- [ ] **Step 4: Update writing-plan path**

Replace any old writing-plan path with:

```text
harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/writing-plan.md
```

- [ ] **Step 5: Replace `## Mandatory Plan Review Question` section**

Replace any old plan review section with:

````markdown
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
````

- [ ] **Step 6: Replace `## Verification` section**

Replace any old verification section with:

```markdown
## Verification

Before claiming completion, use `superpowers:verification-before-completion`.

Record commands, expected output, actual output summary, and unresolved risk in:

`harness/docs/tasks/active/<slug>/verification.md`

Negative `rg` checks must treat exit code 1 as success when the expected result is "no matches".
```

- [ ] **Step 7: Replace `## ce-compound` section**

Replace any old Compound Engineering section with:

```markdown
## ce-compound

After verification, run Compound Engineering learning capture.

Reusable learning belongs under:

`harness/docs/solutions/`

Do not store reusable learning under `harness/state/`.
```

- [ ] **Step 8: Remove `## Optional Handoff Update` section**

Delete any section titled `## Optional Handoff Update`.

Add this replacement section if the workflow needs handoff guidance:

```markdown
## Global Handoff

Root `handoff.md` is only for next-chat/context transfer.

Task-specific summaries belong in:

`harness/docs/tasks/active/<slug>/brief.md`
```

- [ ] **Step 9: Add Archive Task Artifacts section**

Add a section that states:

```markdown
## Archive Task Artifacts

After verification and ce-compound, move the task folder from `harness/docs/tasks/active/<slug>/` to `harness/docs/tasks/archive/<slug>/` unless the user explicitly chooses to keep it active or delete it.

Do not delete task artifacts by default.
```

- [ ] **Step 10: Delete Short Loop section**

Remove the entire `## Short Loop Exception` section.

- [ ] **Step 11: Verify workflow no longer names old conceptual flow**

Run:

```powershell
$pattern = "OuroSuper Planning|Short Loop|harness/state/ourosuper|harness/state/superpowers|harness/state/verification|docs/prd|docs/issues|docs/handoff|docs/superpowers|handoff packet|Seed|Optional Handoff Update"
rg -n $pattern harness/rules/workflow.md
if ($LASTEXITCODE -eq 1) {
  rg -n "(^|[^A-Za-z0-9_/-])docs/solutions(/|$)" harness/rules/workflow.md
  if ($LASTEXITCODE -eq 1) {
    "OK: no forbidden workflow terms"
    exit 0
  }
}
if ($LASTEXITCODE -eq 0) {
  throw "Forbidden workflow terms found"
}
exit $LASTEXITCODE
```

Expected: `OK: no forbidden workflow terms`

## Task 6: Update Core Rules

**Files:**
- Modify: `harness/rules/rules.md`

- [ ] **Step 1: Replace Required Plugins And Skills block**

Use this sequence:

```text
Matt Pocock Planning Gate
  Verify setup-matt-pocock-skills readiness.
  Use grill-with-docs.
  Use to-prd.
  Stop for User PRD Approval.
  Use to-issues.
  Stop for User Issue Approval.
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

- [ ] **Step 2: Replace Plan Review Question rule**

Replace the `## 4. Plan Review Question Is Mandatory` section with:

````markdown
## 4. Plan Review Question Is Mandatory

After `superpowers:writing-plans`, use the exact Mandatory Plan Review Question in `harness/rules/workflow.md`.

Store review choice, reviewer names, findings, user decisions, and skipped-review reasons in:

```text
harness/docs/tasks/active/<slug>/reviews.md
```

Do not implement before this question is answered.
````

- [ ] **Step 3: Remove user-owned Short Loop exceptions**

Delete the section titled:

```markdown
## 3. User-Owned Exceptions
```

Renumber later headings so the document stays sequential.

- [ ] **Step 4: Update fixed state and artifact paths**

Replace the fixed state/artifact path block with this exact block:

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

- [ ] **Step 5: Verify old conceptual terms and old root docs paths are gone**

Run:

```powershell
$pattern = "OuroSuper Planning|Short Loop|harness/state/ourosuper|harness/state/superpowers|harness/state/verification|Seed YAML|handoff-packet|docs/prd|docs/issues|docs/handoff|docs/superpowers"
rg -n $pattern harness/rules/rules.md
if ($LASTEXITCODE -eq 1) {
  rg -n "(^|[^A-Za-z0-9_/-])docs/solutions(/|$)" harness/rules/rules.md
  if ($LASTEXITCODE -eq 1) {
    "OK: no forbidden rules terms"
    exit 0
  }
}
if ($LASTEXITCODE -eq 0) {
  throw "Forbidden rules terms found"
}
exit $LASTEXITCODE
```

Expected: `OK: no forbidden rules terms`

## Task 7: Update AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: Rename scope**

Replace:

```markdown
This repository uses OuroSuper Harness.
```

with:

```markdown
This repository uses 짬뽕하네스 (`jjamppong-harness`), a private agent workflow harness.
```

- [ ] **Step 2: Update Harness Root Model install tree**

Replace the install-tree bullet under `## Harness Root Model` with:

```markdown
- When installing the harness into a project folder such as `F:/mptech`, `AGENTS.md`, `harness/`, `modules/`, `module-template/`, and `proposals/` must live directly under `F:/mptech`. AI task artifacts live under `harness/docs/`; the project-root artifact area must not be used for AI task output.
```

- [ ] **Step 3: Update project request trigger**

Replace the old request intake sentence with:

```markdown
- In the project harness root: record request intake in `harness/state/intake.md`, then run the full mandatory planning gate: setup-matt-pocock-skills readiness check, grill-with-docs, to-prd, User PRD Approval, to-issues, User Issue Approval, task brief, superpowers:writing-plans, and the Mandatory Plan Review Question. Record the choice and results in `harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/reviews.md`; do not implement before that review choice is recorded.
```

- [ ] **Step 4: Add required skill summary**

Under `## Always Use`, preserve every existing bullet, including the `vowline` bullet and branch/commit safety bullets, then add:

```markdown
- Use Matt Pocock planning skills for the mandatory planning gate: `setup-matt-pocock-skills`, `grill-with-docs`, `to-prd`, and `to-issues`.
- Use Superpowers for writing plans, implementation, and verification.
- Use gstack review skills when running plan review.
- Use Compound Engineering after verification.
```

- [ ] **Step 5: Update solutions conditional read**

Replace the old `docs/solutions/` conditional-read bullet with:

```markdown
- Search `harness/docs/solutions/` only when a related prior solution may help, when running Compound Engineering refresh work, or when `ce-compound` needs existing learning context.
```

- [ ] **Step 6: Update handoff hard rule**

Replace the old root handoff rule with:

```markdown
- Use root `handoff.md` only for global next-chat/context transfer. Task summaries belong under `harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/brief.md`.
```

- [ ] **Step 7: Verify**

Run:

```powershell
$pattern = "OuroSuper Planning|harness/state/ourosuper|harness/state/superpowers|harness/state/verification|Seed YAML|handoff-packet|docs/prd|docs/issues|docs/handoff|docs/superpowers"
rg -n $pattern AGENTS.md
if ($LASTEXITCODE -eq 1) {
  rg -n "(^|[^A-Za-z0-9_/-])docs/solutions(/|$)" AGENTS.md
  if ($LASTEXITCODE -eq 1) {
    "OK: no forbidden AGENTS terms"
    exit 0
  }
}
if ($LASTEXITCODE -eq 0) {
  throw "Forbidden AGENTS terms found"
}
exit $LASTEXITCODE
```

Expected: `OK: no forbidden AGENTS terms`

Then verify the mandatory review gate is explicitly named:

```powershell
$matches = rg -n "Mandatory Plan Review Question|reviews\.md|do not implement before that review choice is recorded" AGENTS.md
if ($LASTEXITCODE -ne 0 -or $matches.Count -lt 3) {
  $matches
  throw "AGENTS.md does not enforce mandatory plan review recording"
}
"OK: AGENTS review gate is explicit"
```

Expected: `OK: AGENTS review gate is explicit`

## Task 8: Update Module-Type Workflow

**Files:**
- Modify: `harness/rules/module-types.md`

- [ ] **Step 1: Replace workflow block**

Replace the old workflow sequence with:

```text
Request Intake
-> setup-matt-pocock-skills Readiness Check
-> grill-with-docs
-> to-prd
-> User PRD Approval
-> to-issues
-> User Issue Approval
-> Task Brief
-> Superpowers Writing Plans
-> Mandatory Plan Review Question
-> Implementation / Apply
-> Verification
-> ce-compound
-> Archive Task Artifacts
-> Learning Update Question
```

- [ ] **Step 2: Verify**

Run:

```powershell
$pattern = "OuroSuper Planning|Short Loop|Seed|harness/state/ourosuper|harness/state/superpowers|harness/state/verification|docs/prd|docs/issues|docs/superpowers"
rg -n $pattern harness/rules/module-types.md
if ($LASTEXITCODE -eq 1) {
  rg -n "(^|[^A-Za-z0-9_/-])docs/solutions(/|$)" harness/rules/module-types.md
  if ($LASTEXITCODE -eq 1) {
    "OK: no forbidden module-type terms"
    exit 0
  }
}
if ($LASTEXITCODE -eq 0) {
  throw "Forbidden module-type terms found"
}
exit $LASTEXITCODE
```

Expected: `OK: no forbidden module-type terms`

## Task 9: Rewrite README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Rename title and intro**

Use this title:

```markdown
# 짬뽕하네스
```

Use this intro:

```markdown
짬뽕하네스는 Matt Pocock skills, Superpowers, Compound Engineering, gstack review, vowline을 섞어서 모든 작업을 기획 -> PRD -> issue 분해 -> task brief -> writing-plans -> 실행 -> 검증 -> 학습 회수 순서로 강제하는 private agent workflow harness입니다.
```

- [ ] **Step 2: Update Requirements**

Required workflow tools must include:

```markdown
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
```

Also add:

````markdown
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
````

- [ ] **Step 3: Rewrite Installation section**

Replace the installation section with two explicit flows:

````markdown
## Installation

이 저장소는 npm package가 아닙니다. 설치란 template 내용을 대상 프로젝트 root에 직접 놓는 것입니다.

### New Project From Template

새 프로젝트를 만들 때는 GitHub template 기능으로 프로젝트 전용 private repository를 만듭니다.

```powershell
Push-Location 'F:/'
gh repo create <project-name> --private --template vibedong/ourosuper-harness --clone
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

### Apply Harness Into Existing Repo Root

이미 `F:/mptech` 같은 프로젝트 repository가 있으면 template source를 중첩 clone하지 않습니다.

Rules:

- Final files must be `F:/mptech/AGENTS.md`, `F:/mptech/harness/`, `F:/mptech/modules/`, not `F:/mptech/ourosuper-harness/AGENTS.md`.
- Copy template contents into the project root excluding `.git/`.
- Preserve the existing project repository `origin`.
- After setup, `git remote -v` in the project root must point to the project repository, not `https://github.com/vibedong/ourosuper-harness.git`.
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
  git clone https://github.com/vibedong/ourosuper-harness.git $tempRoot
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
  if (Test-Path -LiteralPath (Join-Path $target 'ourosuper-harness')) {
    throw "Nested ourosuper-harness folder was created"
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
````

- [ ] **Step 4: Update Quick Start prompt**

Replace the old OuroSuper prompt with a human-facing prompt first:

```text
이 프로젝트를 짬뽕하네스 방식으로 제대로 기획하고 실행 준비해줘.
내 요청을 먼저 정리하고, 모호한 부분을 질문하고, PRD와 실행 이슈로 쪼갠 다음,
PRD 초안 후 내 승인을 받고, issue 분해 후 다시 내 승인을 받은 다음,
task brief와 writing plan까지 만든 뒤 구현 전에 리뷰 여부를 물어봐.
작은 작업이어도 같은 흐름으로 처리해.
```

- [ ] **Step 5: Add internal tool sequence below Quick Start**

After the human-facing prompt, document this exact internal sequence:

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

- [ ] **Step 6: Update How It Works**

Replace the How It Works section with this exact sequence:

```markdown
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
```

- [ ] **Step 7: Update Directory Layout**

Document:

```text
CONTEXT.md
handoff.md
harness/docs/agents/
harness/docs/adr/
harness/docs/solutions/
harness/docs/tasks/active/<slug>/
harness/docs/tasks/archive/<slug>/
harness/state/planning.md
```

Remove references to:

```text
docs/solutions/
harness/state/ourosuper/
docs/prd/
docs/issues/
docs/handoff/
docs/superpowers/
```

- [ ] **Step 8: Add legacy repo-name note**

Add:

```markdown
이 template repository의 GitHub 이름은 기존 호환성 때문에 `ourosuper-harness`로 남아 있을 수 있습니다. 문서와 workflow의 현재 이름은 `짬뽕하네스`입니다.
```

- [ ] **Step 9: Verify**

Run:

```powershell
$pattern = "OuroSuper Planning|harness/state/ourosuper|harness/state/superpowers|harness/state/verification|Seed YAML|handoff-packet|Short Loop|docs/prd|docs/issues|docs/handoff|docs/superpowers"
rg -n $pattern README.md
if ($LASTEXITCODE -eq 1) {
  rg -n '(^|[^A-Za-z0-9_/-])docs/($|[^A-Za-z0-9_/-])|(^|[^A-Za-z0-9_/-])docs/solutions(/|$)|root docs|  docs/' README.md
  if ($LASTEXITCODE -eq 1) {
    "OK: no forbidden README terms"
    exit 0
  }
}
if ($LASTEXITCODE -eq 0) {
  throw "Forbidden README terms found"
}
exit $LASTEXITCODE
```

Expected: `OK: no forbidden README terms`

`vibedong/ourosuper-harness` URL may remain if it is clearly described as the legacy template repository URL.

## Task 10: Update Root Handoff

**Files:**
- Modify: `handoff.md`

- [ ] **Step 1: Add global handoff notice at top**

Use:

```markdown
# Global Handoff

Root `handoff.md` is the global next-chat/context-transfer file.

Task-specific summaries belong under:

`harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/brief.md`
```

- [ ] **Step 2: Verify**

Run:

```powershell
Get-Content -LiteralPath handoff.md -TotalCount 10
```

Expected: the global handoff notice appears first.

## Task 11: Remove Old OuroSuper And Root Docs Placeholders

**Files:**
- Delete: `harness/state/ourosuper/.gitkeep`
- Delete: `harness/state/superpowers/.gitkeep`
- Delete: `harness/state/verification/.gitkeep`
- Remove if empty: `harness/state/ourosuper/`
- Remove if empty: `harness/state/superpowers/`
- Remove if empty: `harness/state/verification/`
- Delete: `docs/solutions/.gitkeep`

- [ ] **Step 1: Confirm exact obsolete placeholders**

Run:

```powershell
$paths = @(
  'harness/state/ourosuper/.gitkeep',
  'harness/state/superpowers/.gitkeep',
  'harness/state/verification/.gitkeep',
  'docs/solutions/.gitkeep'
)
foreach ($path in $paths) {
  "$path exists=$((Test-Path -LiteralPath $path))"
}
```

Expected: four `exists=True` lines.

- [ ] **Step 2: Delete exact obsolete placeholders**

Use `apply_patch` to delete these exact files:

```text
harness/state/ourosuper/.gitkeep
harness/state/superpowers/.gitkeep
harness/state/verification/.gitkeep
docs/solutions/.gitkeep
```

- [ ] **Step 3: Verify obsolete placeholders are gone**

Run:

```powershell
$paths = @(
  'harness/state/ourosuper/.gitkeep',
  'harness/state/superpowers/.gitkeep',
  'harness/state/verification/.gitkeep',
  'docs/solutions/.gitkeep'
)
foreach ($path in $paths) {
  "$path exists=$((Test-Path -LiteralPath $path))"
}
```

Expected: four `exists=False` lines.

- [ ] **Step 4: Remove empty root docs directories safely**

Run this after the tracked root docs placeholder is deleted:

```powershell
$root = (Resolve-Path -LiteralPath '.').Path
$docsRoot = Join-Path $root 'docs'
$dirs = @(
  'docs/solutions',
  'docs/superpowers/plans',
  'docs/superpowers',
  'docs'
)
foreach ($rel in $dirs) {
  $path = Join-Path $root $rel
  if (Test-Path -LiteralPath $path) {
    $resolved = (Resolve-Path -LiteralPath $path).Path
    if ($resolved -ne $docsRoot -and -not $resolved.StartsWith($docsRoot + [IO.Path]::DirectorySeparatorChar)) {
      throw "Unexpected docs cleanup path: $resolved"
    }
    $children = Get-ChildItem -LiteralPath $resolved -Force
    if ($children) {
      throw "Directory is not empty: $resolved"
    }
    Remove-Item -LiteralPath $resolved
  }
}
```

Expected: command exits with no output and no error.

- [ ] **Step 5: Remove empty obsolete state directories safely**

Run this after the tracked state placeholders are deleted:

```powershell
$root = (Resolve-Path -LiteralPath '.').Path
$stateRoot = (Resolve-Path -LiteralPath (Join-Path (Join-Path $root 'harness') 'state')).Path
$dirs = @(
  'harness/state/verification',
  'harness/state/superpowers',
  'harness/state/ourosuper'
)
foreach ($rel in $dirs) {
  $path = Join-Path $root $rel
  if (Test-Path -LiteralPath $path) {
    $resolved = (Resolve-Path -LiteralPath $path).Path
    if (-not $resolved.StartsWith($stateRoot + [IO.Path]::DirectorySeparatorChar)) {
      throw "Unexpected state cleanup path: $resolved"
    }
    $children = Get-ChildItem -LiteralPath $resolved -Force
    if ($children) {
      throw "Directory is not empty: $resolved"
    }
    Remove-Item -LiteralPath $resolved
  }
}
```

Expected: command exits with no output and no error.

- [ ] **Step 6: Verify removed directories are gone**

Run:

```powershell
$paths = @(
  'docs',
  'harness/state/ourosuper',
  'harness/state/superpowers',
  'harness/state/verification'
)
foreach ($path in $paths) {
  if (Test-Path -LiteralPath $path) {
    throw "Obsolete directory still exists: $path"
  }
}
"OK: obsolete directories removed"
```

Expected: `OK: obsolete directories removed`

- [ ] **Step 7: Verify no live docs require old paths**

Run:

```powershell
$pattern = "harness/state/ourosuper|harness/state/superpowers|harness/state/verification|OuroSuper Planning|Seed YAML|handoff-packet|docs/prd|docs/issues|docs/handoff|docs/superpowers"
rg -n $pattern AGENTS.md README.md harness/rules
if ($LASTEXITCODE -eq 1) {
  rg -n '(^|[^A-Za-z0-9_/-])docs/($|[^A-Za-z0-9_/-])|(^|[^A-Za-z0-9_/-])docs/solutions(/|$)' AGENTS.md README.md harness/rules
  if ($LASTEXITCODE -eq 1) {
    "OK: no obsolete path references"
    exit 0
  }
}
if ($LASTEXITCODE -eq 0) {
  throw "Obsolete path references found"
}
exit $LASTEXITCODE
```

Expected: `OK: no obsolete path references`, except allowed legacy repo URL text in README if present.

## Task 12: Delete Approved Proposal

**Files:**
- Delete: `proposals/2026-06-02-jjamppong-harness-migration.md`

- [ ] **Step 1: Delete after live files pass verification**

Use `apply_patch` to delete `proposals/2026-06-02-jjamppong-harness-migration.md`.

- [ ] **Step 2: Verify proposal removed**

Run:

```powershell
if (Test-Path -LiteralPath 'proposals/2026-06-02-jjamppong-harness-migration.md') {
  throw "Proposal still exists"
}
"OK: proposal removed"
```

Expected: `OK: proposal removed`

## Task 13: Pre-Closeout Verification

**Files:**
- Verify all modified files.

- [ ] **Step 1: Check git status**

Run:

```powershell
$status = git status --short --branch
$required = @(
  '## main...origin/main',
  ' M AGENTS.md',
  ' M README.md',
  ' M handoff.md',
  ' M harness/rules/module-types.md',
  ' M harness/rules/rules.md',
  ' M harness/rules/workflow.md',
  ' D docs/solutions/.gitkeep',
  ' D harness/state/ourosuper/.gitkeep',
  ' D harness/state/superpowers/.gitkeep',
  ' D harness/state/verification/.gitkeep',
  '?? CONTEXT.md',
  '?? harness/docs/',
  '?? harness/state/planning.md'
)
$missing = $required | Where-Object { $status -notcontains $_ }
if ($missing) {
  $missing
  throw "Missing expected git status lines"
}
"OK: git status contains required migration lines"
```

Expected: `OK: git status contains required migration lines`

Do not expect a commit. Do not expect a push.

- [ ] **Step 2: Check markdown fences**

Run:

```powershell
$files = @(
  'AGENTS.md',
  'README.md',
  'handoff.md',
  'CONTEXT.md',
  'harness/state/planning.md',
  'harness/state/compound.md',
  'harness/rules/workflow.md',
  'harness/rules/rules.md',
  'harness/rules/module-types.md',
  'harness/docs/agents/matt-pocock-skills.md',
  'harness/docs/agents/issue-tracker.md',
  'harness/docs/agents/triage-labels.md',
  'harness/docs/agents/domain.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/001-jjamppong-harness-migration.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md',
  'harness/docs/adr/2026-06-02-jjamppong-planning-gate.md'
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file)) {
    throw "Missing markdown file before fence check: $file"
  }
  $fence = [string]([char]96) * 3
  $count = (Select-String -Path $file -Pattern $fence -AllMatches).Matches.Count
  if ($count % 2 -ne 0) {
    throw "Odd markdown fence count in $file: $count"
  }
  $quadFence = [string]([char]96) * 4
  $quadCount = (Select-String -Path $file -Pattern $quadFence -AllMatches).Matches.Count
  if ($quadCount % 2 -ne 0) {
    throw "Odd nested markdown fence count in $file: $quadCount"
  }
}
"OK: markdown fences are balanced"
```

Expected: `OK: markdown fences are balanced`

- [ ] **Step 3: Check forbidden conceptual terms and old root docs paths**

Run:

```powershell
$pattern = "OuroSuper Planning|harness/state/ourosuper|harness/state/superpowers|harness/state/verification|Seed YAML|handoff-packet|Short Loop|docs/prd|docs/issues|docs/handoff|docs/superpowers|Optional Handoff Update"
rg -n $pattern AGENTS.md README.md handoff.md CONTEXT.md harness/rules harness/docs/agents
if ($LASTEXITCODE -eq 1) {
  rg -n '(^|[^A-Za-z0-9_/-])docs/($|[^A-Za-z0-9_/-])|(^|[^A-Za-z0-9_/-])docs/solutions(/|$)|root docs|  docs/' AGENTS.md README.md handoff.md CONTEXT.md harness/rules harness/docs/agents
  if ($LASTEXITCODE -eq 1) {
    "OK: no forbidden live-governance terms"
    exit 0
  }
}
if ($LASTEXITCODE -eq 0) {
  throw "Forbidden live-governance terms found"
}
exit $LASTEXITCODE
```

Expected: `OK: no forbidden live-governance terms`

- [ ] **Step 4: Check required new terms**

Run:

```powershell
$patterns = @(
  '짬뽕하네스',
  'grill-with-docs',
  'to-prd',
  'to-issues',
  'harness/docs/tasks/active',
  'harness/docs/tasks/archive',
  'harness/docs/solutions',
  'brief.md',
  'writing-plan.md'
)
foreach ($pattern in $patterns) {
  rg -n $pattern AGENTS.md README.md CONTEXT.md harness/rules harness/docs/agents
  if ($LASTEXITCODE -ne 0) {
    throw "Missing required term: $pattern"
  }
}
"OK: required new terms found"
```

Expected: `OK: required new terms found`

- [ ] **Step 5: Run Matt Pocock readiness check**

Run the readiness command from `harness/docs/agents/matt-pocock-skills.md`. If it fails because one or more required skills are missing, stop and report the blocker instead of claiming the migration is complete.

Expected success output:

```text
OK: all Matt Pocock planning skills available
```

- [ ] **Step 6: Check task pointer and review artifacts exist**

Run:

```powershell
$paths = @(
  'harness/state/planning.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/001-jjamppong-harness-migration.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md',
  'harness/docs/adr/2026-06-02-jjamppong-planning-gate.md'
)
foreach ($path in $paths) {
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required artifact: $path"
  }
}
"OK: required task artifacts exist"
```

Expected: `OK: required task artifacts exist`

- [ ] **Step 7: Check planning pointer content**

Run:

```powershell
$matches = rg -n "Active task: 2026-06-02-jjamppong-harness-migration|Phase: writing-plan|PRD: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md|Issues: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/|Reviews: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md|Verification: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md" harness/state/planning.md
if ($LASTEXITCODE -ne 0 -or $matches.Count -ne 6) {
  $matches
  throw "Planning pointer content mismatch"
}
"OK: planning pointer content found"
```

Expected: `OK: planning pointer content found`

- [ ] **Step 8: Check root docs is not used for AI artifacts**

Run:

```powershell
$docsExists = Test-Path -LiteralPath 'docs'
$docsStatus = git status --short -- docs
if ($docsExists) {
  throw "Root docs directory still exists"
}
if ($docsStatus -notcontains ' D docs/solutions/.gitkeep') {
  $docsStatus
  throw "Expected tracked deletion for docs/solutions/.gitkeep"
}
"OK: root docs directory removed and tracked deletion remains"
```

Expected: `OK: root docs directory removed and tracked deletion remains`

- [ ] **Step 9: Check no commit or push happened**

Run:

```powershell
$head = git rev-parse --short HEAD
if ($head -ne '13af545') {
  throw "HEAD changed: $head"
}
"OK: HEAD unchanged at $head"
```

Expected: `OK: HEAD unchanged at 13af545`

## Task 14: Compound And Archive Closeout

**Files:**
- Modify: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md`
- Modify: `harness/state/compound.md`
- Modify: `harness/state/planning.md`

- [ ] **Step 1: Update `reviews.md` with actual review outcome**

Replace the pending review log with:

```markdown
# Reviews

## Mandatory Plan Review Question

Selected option: CEO + Eng + Plan Compliance

## Review Log

- Status: completed
- Reviewers: plan-ceo-review, plan-eng-review, Superpowers Plan Compliance
- Accepted findings: PRD/issues artifacts, approval-gate sequence consistency, README installation commands, root docs cleanup, root docs path verification, final verification after closeout, completed reviews/verification artifacts, archive status wording, Matt Pocock readiness verification, AGENTS mandatory review recording, self-forbidden term removal, existing-repo origin/collision safety, empty state directory cleanup, deterministic markdown checks, final verification after `verification.md`, and GSTACK report refresh.
- Rejected findings: restore Fast Lane; force Plan Compliance for every normal task; convert every create-file step into a full patch body when exact path, anchor, and final content are already specified.
- User decisions: one mandatory planning path for small and large tasks; root `handoff.md` remains global; task artifacts live under `harness/docs/tasks/active/<slug>/`.
- Skipped reason: none.
```

- [ ] **Step 2: Run Compound Engineering learning capture**

Run `ce-compound` after pre-closeout verification and before final verification. If the tool is unavailable, record the blocker in `harness/state/compound.md` and do not invent learning.

- [ ] **Step 3: Update `harness/state/compound.md`**

Use `apply_patch` with this exact baseline content if no reusable learning is captured:

````markdown
# Compound State

No ce-compound learning has been captured for `2026-06-02-jjamppong-harness-migration` yet.

This file stores only a short index of Compound Engineering learning documents.

Long-lived learning documents stay under:

```text
harness/docs/solutions/
```
````

- [ ] **Step 4: Ask the Learning Update Question**

Ask:

```text
이번 작업에서 다음 프로젝트에도 재사용할 만한 배움이 있나요?
있다면 harness/docs/solutions/ 아래에 짧게 기록할까요?
```

- [ ] **Step 5: Record archive decision**

Normal completed tasks archive by default. For this migration, archive now is recommended after the user reviews the completed migration. Because this plan file is the active execution guide, treat archive as user-deferred unless the user explicitly approves archive now.

If archive is deferred, append this line to `harness/state/planning.md`:

```markdown
Archive status: user-deferred until the user approves archive after reviewing this migration.
```

- [ ] **Step 6: Verify closeout state**

Run:

```powershell
$matches = rg -n "harness/docs/solutions|Archive status: user-deferred|Status: completed|Selected option: CEO \\+ Eng \\+ Plan Compliance" harness/state/compound.md harness/state/planning.md harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md
if ($LASTEXITCODE -ne 0 -or $matches.Count -lt 4) {
  $matches
  throw "Closeout terms missing"
}
$status = git status --short -- harness/state/compound.md harness/state/planning.md
if ($status -notcontains ' M harness/state/compound.md') {
  $status
  throw "compound state was not updated"
}
"OK: closeout state recorded"
```

Expected: `OK: closeout state recorded`

## Task 15: Final Verification After Closeout

**Files:**
- Modify: `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md`
- Verify all modified files after closeout edits.

- [ ] **Step 1: Complete `verification.md`**

Replace `verification.md` with this summary after closeout state is recorded:

```markdown
# Verification

Status: completed

Commands:

- `git status --short --branch`
- markdown fence check
- forbidden conceptual term check
- root docs path check
- required new term check
- task artifact existence check
- planning pointer content check
- Matt Pocock readiness check
- root docs deletion check
- HEAD unchanged check
- final closeout verification

Result:

- final closeout verification passed.
- No commit or push was performed.
- Residual risk: the GitHub repository URL may still contain `ourosuper-harness` until the user separately renames the template repository.
```

- [ ] **Step 2: Rerun full final checks after `verification.md` update**

Run:

```powershell
$status = git status --short --branch
$required = @(
  '## main...origin/main',
  ' M AGENTS.md',
  ' M README.md',
  ' M handoff.md',
  ' M harness/rules/module-types.md',
  ' M harness/rules/rules.md',
  ' M harness/rules/workflow.md',
  ' M harness/state/compound.md',
  ' D docs/solutions/.gitkeep',
  ' D harness/state/ourosuper/.gitkeep',
  ' D harness/state/superpowers/.gitkeep',
  ' D harness/state/verification/.gitkeep',
  '?? CONTEXT.md',
  '?? harness/docs/',
  '?? harness/state/planning.md'
)
$missing = $required | Where-Object { $status -notcontains $_ }
if ($missing) {
  $missing
  throw "Missing expected final git status lines"
}

$files = @(
  'AGENTS.md',
  'README.md',
  'handoff.md',
  'CONTEXT.md',
  'harness/state/planning.md',
  'harness/state/compound.md',
  'harness/rules/workflow.md',
  'harness/rules/rules.md',
  'harness/rules/module-types.md',
  'harness/docs/agents/matt-pocock-skills.md',
  'harness/docs/agents/issue-tracker.md',
  'harness/docs/agents/triage-labels.md',
  'harness/docs/agents/domain.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/001-jjamppong-harness-migration.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/brief.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md',
  'harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md',
  'harness/docs/adr/2026-06-02-jjamppong-planning-gate.md'
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file)) {
    throw "Missing final markdown file: $file"
  }
  $fence = [string]([char]96) * 3
  $count = (Select-String -Path $file -Pattern $fence -AllMatches).Matches.Count
  if ($count % 2 -ne 0) {
    throw "Odd markdown fence count in $file: $count"
  }
  $quadFence = [string]([char]96) * 4
  $quadCount = (Select-String -Path $file -Pattern $quadFence -AllMatches).Matches.Count
  if ($quadCount % 2 -ne 0) {
    throw "Odd nested markdown fence count in $file: $quadCount"
  }
}

$pattern = "OuroSuper Planning|harness/state/ourosuper|harness/state/superpowers|harness/state/verification|Seed YAML|handoff-packet|Short Loop|docs/prd|docs/issues|docs/handoff|docs/superpowers|Optional Handoff Update"
rg -n $pattern AGENTS.md README.md handoff.md CONTEXT.md harness/rules harness/state harness/docs/agents
if ($LASTEXITCODE -ne 1) {
  throw "Forbidden conceptual terms found"
}

rg -n '(^|[^A-Za-z0-9_/-])docs/($|[^A-Za-z0-9_/-])|(^|[^A-Za-z0-9_/-])docs/solutions(/|$)|root docs|  docs/' AGENTS.md README.md handoff.md CONTEXT.md harness/rules harness/state harness/docs/agents
if ($LASTEXITCODE -ne 1) {
  throw "Forbidden root docs references found"
}

$newTerms = @(
  '짬뽕하네스',
  'grill-with-docs',
  'to-prd',
  'to-issues',
  'harness/docs/tasks/active',
  'harness/docs/tasks/archive',
  'harness/docs/solutions',
  'brief.md',
  'writing-plan.md',
  'Mandatory Plan Review Question'
)
foreach ($term in $newTerms) {
  rg -n $term AGENTS.md README.md CONTEXT.md harness/rules harness/docs/agents
  if ($LASTEXITCODE -ne 0) {
    throw "Missing required final term: $term"
  }
}

$planningMatches = rg -n "Active task: 2026-06-02-jjamppong-harness-migration|Phase: writing-plan|PRD: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/prd.md|Issues: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/issues/|Reviews: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md|Verification: harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md|Archive status: user-deferred" harness/state/planning.md
if ($LASTEXITCODE -ne 0 -or $planningMatches.Count -lt 7) {
  $planningMatches
  throw "Planning pointer content mismatch"
}

$absentPaths = @(
  'docs',
  'harness/state/ourosuper',
  'harness/state/superpowers',
  'harness/state/verification',
  'proposals/2026-06-02-jjamppong-harness-migration.md'
)
foreach ($path in $absentPaths) {
  if (Test-Path -LiteralPath $path) {
    throw "Obsolete path still exists: $path"
  }
}

$docsStatus = git status --short -- docs
if ($docsStatus -notcontains ' D docs/solutions/.gitkeep') {
  $docsStatus
  throw "Expected tracked deletion for docs/solutions/.gitkeep"
}

$requiredSkills = @(
  'setup-matt-pocock-skills',
  'grill-with-docs',
  'to-prd',
  'to-issues'
)
$skillRoots = @(
  (Join-Path $env:USERPROFILE '.codex/skills'),
  (Join-Path $env:USERPROFILE '.agents/skills')
)
$skillFiles = foreach ($root in $skillRoots) {
  if (Test-Path -LiteralPath $root) {
    Get-ChildItem -LiteralPath $root -Recurse -Filter 'SKILL.md' -ErrorAction SilentlyContinue
  }
}
$missingSkills = foreach ($skill in $requiredSkills) {
  $found = $skillFiles | Where-Object {
    Select-String -LiteralPath $_.FullName -Pattern "name: $skill" -Quiet
  }
  if (-not $found) { $skill }
}
if ($missingSkills) {
  $missingSkills
  throw "Missing required Matt Pocock planning skills"
}

$matches = rg -n "Status: completed|final closeout verification|No commit or push" harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/verification.md
if ($LASTEXITCODE -ne 0 -or $matches.Count -lt 3) {
  $matches
  throw "verification.md was not completed"
}

$reviewMatches = rg -n "Selected option: CEO \+ Eng \+ Plan Compliance|Status: completed|Reviewers: plan-ceo-review, plan-eng-review, Superpowers Plan Compliance" harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/reviews.md
if ($LASTEXITCODE -ne 0 -or $reviewMatches.Count -lt 3) {
  $reviewMatches
  throw "reviews.md was not completed"
}

$head = git rev-parse --short HEAD
if ($head -ne '13af545') {
  throw "HEAD changed: $head"
}
"OK: final verification passed after verification.md update"
```

Expected: `OK: final verification passed after verification.md update`

## Self-Review

- Spec coverage: This revised plan covers name, required skills, mandatory gate, PRD/issues artifacts, installation into project root, artifact paths, root handoff semantics, `harness/docs` consolidation, root `docs/` cleanup, `harness/state` pointer-only rule, archive default, OuroSuper removal, local issue storage, Compound closeout, and no-commit safety.
- Placeholder scan: No deferred-detail steps are allowed in execution.
- Path consistency: Active task artifacts are always under `harness/docs/tasks/active/<slug>/`; archived task artifacts are always under `harness/docs/tasks/archive/<slug>/`; root `handoff.md` is global only.
- Known residual risk: The GitHub repository URL may still contain `ourosuper-harness` until the user separately renames the repo. Treat that as a legacy source URL, not a workflow concept.

## Execution Handoff

Plan complete and saved to `harness/docs/tasks/active/2026-06-02-jjamppong-harness-migration/writing-plan.md`.

Execution options:

1. Inline Sequential Execution (recommended for the current repo state): implement Tasks 1-15 in this session using `superpowers:executing-plans`, because `AGENTS.md`, `README.md`, and `harness/rules/rules.md` already contain uncommitted safety-rule edits.
2. Subagent-Driven Execution: pause this plan first, protect or isolate the dirty changes in a user-approved way, revise the recorded baseline, then use `superpowers:subagent-driven-development` task by task.

Do not start subagent workers against this dirty worktree under the current `13af545` baseline.

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 4 | revised | Fourth pass found AGENTS review-gate recording gaps, README approval prompt gaps, existing-repo collision handling gaps, temp cleanup safety, and stale review report. |
| Eng Review | `/plan-eng-review` | Architecture & tests | 4 | revised | Fourth pass found self-forbidden workflow and AGENTS text, final verification ordering after `verification.md`, leftover empty state dirs, origin validation gaps, and non-deterministic checks. |
| Superpowers Plan Compliance | `superpowers:requesting-code-review` | Plan quality | 4 | revised | Fourth pass found broken nested fences, recursive temp delete validation gaps, final verification after artifact update, and stale review report; full patch-body conversion remains intentionally rejected. |

- **UNRESOLVED:** 0 accepted review items remain open in this plan revision. Rejected items: restoring a Fast Lane, making the third Plan Compliance reviewer mandatory for every normal task, and converting every create-file step into a full `apply_patch` body when exact path, anchor, and final content are already specified.
- **VERDICT:** CEO + ENG + Superpowers compliance reviews found real execution risks; this plan revision absorbs the actionable findings and is ready for inline/sequential execution under the current dirty-worktree baseline.
