# AGENTS.md

## Scope

This repository uses Jjamppong Harness, an AI work safety harness.

The directory containing this file is the harness root.

## Required Reads

For any substantive task, read these first:

```text
harness/contracts/gate-contract-matrix.yaml
harness/contracts/artifact-registry.yaml
harness/contracts/skill-artifact-map.yaml
harness/contracts/capability-catalog.yaml
harness/contracts/task.schema.yaml
harness/contracts/permission-decision.schema.yaml
harness/rules/workflow.md
harness/rules/rules.md
harness/state/planning.md
active task task.yaml, if one exists
active task planning/00-current-planning-context.md, if one exists
active task implementation-approval.md, only when implementation/work permission is requested
```

If required files are missing, stale, or contradictory, stop and run verify/doctor.

## Permission Source Of Truth

Permission is granted only by:

```text
harness/contracts/*.yaml
active task task.yaml
active task implementation-approval.md
PermissionDecision result
```

`task.yaml` records the current gate and approval_summary.

`implementation-approval.md` is a human-readable exact-scope approval summary.

This file may restrict behavior further, but it must not grant permission beyond contracts and PermissionDecision result.

## Hard Rules

- Use `vowline` for substantive work, including subagents.
- Do not start with README or AGENTS rewrites before contracts/tests/verify are in place.
- Install requests stop after install and verify. Do not continue into planning.
- Product planning starts with `grill` before project file reads.
- `research` comes after `grill`; web research is not live target access.
- `plan_review completed` never unlocks implementation.
- `module_structure` never creates folders.
- `folder_skeleton` never creates code, tests, fixtures, runtime config, package files, live access, commit, or push.
- Short approvals approve only the immediately preceding explicit gate question and named scope.
- Missing or ambiguous capabilities are denied.
- Product code belongs under `modules/` unless exact `file.write.outside_modules` approval exists.
- Secrets are deny-by-default.
- Package install, live target access, commit, and push each need separate explicit capability approval.
- Harness-core changes in product tasks must become proposals, not live edits.
- Doctor/update/repair are proposal-only by default for modified managed files.
- Before running a gate or skill, check `harness/contracts/skill-artifact-map.yaml` for required artifacts and inspect only the current gate artifact surface.
- Root `handoff.md` changes only when the user asks for handoff.

## User Language

Ask user-facing gate questions in the user's language.

If the user writes Korean, ask in Korean and explain technical labels briefly in plain language.

- Human-facing artifacts use the user's language.
- Machine-readable artifacts keep stable schema keys.
- Static templates may use Korean starter copy; agents write live human-facing artifacts in the current user's language when presenting or updating them.

## Git

Do not run `git commit`, `git push`, PR, merge, tag, or release commands unless the user explicitly approves that exact action in the current chat.

Before asking for git approval, show changed files and the exact operation.
