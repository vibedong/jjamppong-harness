# Workflow

This file is a human-readable projection of:

```text
harness/contracts/gate-contract-matrix.yaml
harness/contracts/capability-catalog.yaml
harness/contracts/task.schema.yaml
```

If this file conflicts with the contracts, the contracts win.

## User-Facing Flow

Explain the workflow to users in simple Korean when they write in Korean.

```text
1. 설치만 하기
2. 만들고 싶은 것 질문하기
3. 자료조사하기
4. 기획/이슈/구조/계획 세우기
5. 진짜 작업 범위 승인받기
6. 승인된 범위만 작업하기
7. 검증하고 사용자 확인받기
8. 배운 점 정리하고 보관하기
```

Do not show every internal gate first. Show the simple label and the internal gate id when asking for approval.

## Artifact Language Policy

Human-facing artifacts use the user's language.

Human-facing artifacts include `gate-ledger.md`, planning artifacts, `archive-summary.md`, `verification.md`, and `handoff.md`.

gate-ledger.md, planning artifacts, archive-summary.md, verification.md, and handoff.md are human-facing.

Static templates may use Korean starter copy. This phase does not add lifecycle-level localization. When an agent presents or updates live human-facing artifacts, the agent writes them in the current user's language.

Agents write live human-facing artifacts in the current user's language.

Machine-readable artifacts keep stable schema keys.

Machine-readable artifacts include `events.jsonl`, `task.yaml`, contracts, and PermissionDecision outputs. events.jsonl, task.yaml, contracts, and PermissionDecision outputs keep stable machine-readable keys.

## Canonical Gate Order

```text
install
-> intake
-> grill
-> research
-> compound_lookup
-> architecture_orientation
-> prd
-> issues
-> module_structure
-> compile_current_planning_context
-> writing_plan
-> plan_review
-> folder_skeleton, if needed
-> implementation
-> work
-> verification
-> acceptance
-> compound_capture
-> compound_review
-> proposal, if needed
-> archive
-> handoff, only if requested
```

`research` is canonical. `evidence_check` is a legacy alias only.

## Install Gate

Install means install and verify, then stop.

Install must not start planning, create active product tasks, create modules, create code/tests/fixtures, access live targets, install packages beyond the installer itself, create GitHub repos, commit, or push.

The installed project root must contain:

```text
AGENTS.md
README.md
CONTEXT.md
handoff.md
harness/
modules/
module-template/
proposals/
harness.lock.yaml
```

Nested `jjamppong-harness/` or `ourosuper-harness/` install results are invalid.

## Grill Before Read

Product/task planning starts with `grill`.

Before `grill`, do not scan existing project files, old docs, source history, candidate lists, or prior implementation folders as if they were user intent.

After `grill`, `research` may read approved project evidence and general web research. General web research does not authorize live target access.

## Planning Gates

PRD comes after `grill` and `research`.

`issues` comes after approved PRD.

`module_structure` comes after PRD/issues and organizes implementation. It does not create folders.

`writing_plan` reads `planning/00-current-planning-context.md` and the approved planning artifacts. It does not read every raw log by default.

`plan_review` reviews the plan.

Important:

```text
plan_review completed != implementation approved
```

Plan review completion only opens the implementation approval question.

## Artifact Routing

Before a gate or skill starts, check:

```text
harness/contracts/artifact-registry.yaml
harness/contracts/skill-artifact-map.yaml
```

Do not rely on memory for required artifacts.

Read receipts prove that the required artifacts were actually read.

Read receipts are recorded as `artifact_read` events in `events.jsonl`.

`compound_lookup` reads solution indexes before detailed solution files.

Plain rule: compound_lookup reads solution indexes before detailed solution files.

`compound_capture` records candidates in `learning-capture.md`.

Plain rule: compound_capture records candidates in `learning-capture.md`.

Plain rule: compound_capture records candidates before archive.

`compound_review` decides long-term promotion before anything under `harness/docs/solutions/` is changed.

Plain rule: compound_review decides long-term promotion.

`learning-capture.md` and `compound-review.md` are human-facing artifacts and use the user's language.

## Folder Skeleton

`folder_skeleton` is a separate gate.

It may create approved empty folders, `.gitkeep`, and approved non-executable placeholder docs.

It must not create source code, tests, fixtures, runtime config, dependency manifests, package files, crawlers, extractors, evaluators, live access code, or git operations.

## Implementation And Work

`implementation` records the exact-scope approval.

`work` performs only actions allowed by PermissionDecision.

Every risky action needs a capability:

```text
file.read.project
file.read.archive
file.read.raw_artifact
file.read.secret
file.write.task_artifact
file.write.folder_skeleton
file.write.module
file.write.outside_modules
file.write.harness_core
file.delete
file.move
file.symlink
exec.readonly_info
exec.test
exec.build
exec.mutating
exec.destructive
exec.networked
network.web_research
network.live_target
network.package_registry
network.authenticated
package.install
package.update
git.commit
git.push
git.remote_change
installer.install
installer.update
installer.repair
installer.rollback
harness.core_change
project.policy_change
parallel.write
```

Missing or ambiguous capability defaults to deny.

## Approval Rule

Approval is a relationship, not a word list.

A short affirmation such as "좋아" approves only the exact scope in the immediately preceding explicit gate question.

It never adds code, tests, fixtures, live target access, package install, git commit, git push, outside module writes, or harness-core changes unless those were explicitly named as allowed in that question.

Approval evidence must be recorded in:

```text
events.jsonl
```

`gate-ledger.md` is only a human-readable projection.

`task.yaml` is only a derived cache.

If projections disagree with `events.jsonl`, verification fails and `events.jsonl` wins.

## Approval Invalidation

Downstream approvals are invalidated when scope changes:

```text
PRD goal/success criteria/excluded scope
issue set
module path or boundary
writing_plan target files
target path or glob
live/package/git/secret/outside_modules requirement
new user restriction
source artifact hash mismatch
harness core rule changes
```

When uncertain, fail closed and ask a narrower gate question.

## Task Types

Task type must be explicit in `task.yaml` and `events.jsonl`.

```text
install
module_bootstrap
product_feature
product_bugfix
template_maintenance
project_policy_change
harness_update
knowledge_maintenance
archive_maintenance
```

`module_bootstrap` creates a module/workspace only. It must not create product source code, tests, fixtures, executable config, dependency manifests, live access, package install, commit, or push.

After module bootstrap is verified and archived, actual feature work starts as a new product task with `grill` again.

## Verification, Acceptance, Archive

Verification records commands, expected/actual results, exit codes, and risk status.

Verification must not add new feature work. A failed verification that requires product changes re-enters an approved work path.

Archive requires `archive-summary.md`.

Archive is cold context. Future tasks read indexes and summaries before detailed archived artifacts.

`handoff.md` is updated only when the user asks for a new-chat handoff.

handoff.md is a status summary, not the restart prompt container.

The next-chat prompt is returned in the chat response.
