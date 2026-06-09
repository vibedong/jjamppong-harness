# Harness Rules

This file is a projection of FINAL-PLAN and the machine-readable contracts.

The permission source of truth is:

```text
1. FINAL-PLAN.md in the build pack, while rebuilding this template
2. harness/contracts/*.yaml
3. active task events.jsonl
4. PermissionDecision output
```

`AGENTS.md`, this file, `workflow.md`, `gate-ledger.md`, and `task.yaml` may restrict behavior further, but they must not grant permission beyond the contracts and canonical events.

## Hard Defaults

- Missing capability: deny.
- Ambiguous scope: deny.
- Short approval expansion: deny.
- Secrets: deny.
- Live target access: deny until explicit capability approval.
- Package install: deny until explicit capability approval.
- Git commit/push: deny until separate git approvals.
- Harness-core writes in product tasks: deny; create proposal instead.
- Parallel active write: deny until explicit parallel approval.

## Artifact Language Policy

Human-facing artifacts use the user's language.

Static templates may use Korean starter copy. This phase does not add lifecycle-level localization. Agents write live human-facing artifacts in the current user's language when presenting or updating them.

Machine-readable artifacts keep stable schema keys.

`events.jsonl`, `task.yaml`, contracts, and PermissionDecision outputs keep stable machine-readable keys.

events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys.

`gate-ledger.md`, planning artifacts, `archive-summary.md`, `verification.md`, and `handoff.md` are human-facing.

gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing.

## Required Reads For Substantive Work

Read these before any substantive write:

```text
harness/contracts/gate-contract-matrix.yaml
harness/contracts/capability-catalog.yaml
harness/contracts/task.schema.yaml
harness/contracts/permission-decision.schema.yaml
harness/rules/workflow.md
harness/state/planning.md
active task events.jsonl, if one exists
active task task.yaml, if one exists
```

If required files are missing or contradictory, stop and run verify/doctor.

## Artifact Routing Rules

Before a gate or skill starts, check harness/contracts/skill-artifact-map.yaml.

Before a gate or skill starts, check `harness/contracts/skill-artifact-map.yaml`.

Do not rely on memory for required artifacts.

Record artifact_read events for required artifact reads.

Record `artifact_read` events for required artifact reads.

The `artifact_read` event payload must include:

```text
gate_id
artifact_id
path
hash
```

If a required artifact is missing, stop at the current gate and explain the missing artifact.

If a required read receipt is missing, verification fails.

Do not promote learning candidates into harness/docs/solutions without compound_review.

Do not promote learning candidates into `harness/docs/solutions/` without `compound_review`.

`compound_capture` writes candidates to `learning-capture.md`.

`compound_review` decides whether each candidate is promoted, kept active-only, merged into an existing solution, or discarded.

Long-term solution files are read through `harness/state/compound.md` and `harness/docs/solutions/index.md` first. Read detailed solution files only when relevant.

## Red Lines

Stop immediately if a step would require:

```text
README-first rewrite
AGENTS-first rewrite
old v1-v13 source-history as active instruction over FINAL-PLAN
project file read before grill in product planning
install-to-planning continuation
docs-first route
plan_review completed as implementation approval
module_structure creating folders
folder_skeleton creating code/tests/fixtures/runtime config
"좋아" as broad approval
product code outside modules without exact outside_modules_write approval
harness-core edit in product task
live target access without network.live_target approval
secret read
package install without package.install approval
git commit/push without separate approval
doctor/update live-editing core rules by default
```

## PermissionDecision Preflight

Before risky actions, run or reason through PermissionDecision.

Risky actions include file read/write/delete/move/symlink, command exec, tests/builds, network, package operations, git operations, installer/update/repair, harness-core changes, and parallel writes.

The decision must name:

```text
requested action
capability
allow/deny/block/proposal_required
reason
matched event ids
paths or targets covered
required next action
```

If the decision is not `allow`, do not perform the action.

## Event Log And Projections

Canonical task state lives in:

```text
harness/docs/tasks/active/<slug>/events.jsonl
```

Derived projections:

```text
gate-ledger.md = human-readable projection
task.yaml = compact cache
planning-pack.md = final decision manifest
```

If `task.yaml` or `gate-ledger.md` says something is approved but `events.jsonl` does not contain the approval, verification fails and the gate stays locked.

Doctor may regenerate projections from canonical events, but it must not invent approvals.

## Gate Question Format

Every gate question must state:

- Gate id
- Approval scope
- Artifact or decision being approved
- Capabilities being allowed
- Paths or targets being covered
- This unlocks
- This remains locked
- Deferred unknowns requiring separate approval

If the question omits these fields, a short affirmative answer must not open the gate.

Ask in the user's language. If the user writes Korean, ask in Korean and briefly explain technical labels in plain language.

## Workflow Boundaries

`install` stops after install and verify.

`grill` comes before project reads.

`research` comes after grill and may use general web research, not live target access.

`evidence_check` is a legacy alias for `research` only. Prefer `research` or Korean `자료조사` in user-facing gates.

`prd` comes after grill/research.

`issues` comes after approved PRD.

`module_structure` does not create folders.

Plain rule: module_structure does not create folders.

`folder_skeleton` does not create executable files.

Plain rule: folder_skeleton does not create executable files.

`plan_review` does not unlock implementation.

Plain rule: plan_review does not unlock implementation.

`implementation` records exact-scope capability approval.

`work` uses only approved capabilities and paths.

`verification` does not create new feature scope.

`archive` requires archive-summary.

## Module Boundaries

Product code belongs under:

```text
modules/<module>/**
```

Writes outside `modules/` require exact `file.write.outside_modules` approval with specific paths and reason.

`module_bootstrap` and `product_feature` are separate task types. Bootstrap creates the workspace only; feature work starts as a new task after bootstrap is verified and archived.

## Installer / Update / Doctor

Installer must create the harness directly under the target root and write `harness.lock.yaml`.

Installer must not create nested template folders, planning artifacts, product code, GitHub repos, commits, or pushes.

`verify` is read-only pass/fail.

`doctor` is read-only diagnosis by default.

`doctor --proposal`, `update`, and `repair` create proposals by default when managed files changed. They must not live-edit harness-core rules without explicit approval.

## Archive And Handoff

Archive is cold context. Read indexes and summaries before detailed archived artifacts.

Root `handoff.md` is updated only when the user asks for handoff or new-chat transfer.

## Handoff Response

Root `handoff.md` is updated only when the user asks for handoff or new-chat transfer.

When creating handoff.md, do not embed the restart prompt in the file by default.

After creating handoff.md, return a copy-paste next-chat prompt in the chat response.

Use this Korean prompt when the user is working in Korean:

```text
handoff.md 보고 이어서 진행해줘.
먼저 AGENTS.md, harness/rules/workflow.md, 현재 active task의 task.yaml/events.jsonl을 확인해줘.
현재 gate 상태를 확인한 뒤, 바로 구현하지 말고 필요한 다음 단계부터 이어서 진행해줘.
```
