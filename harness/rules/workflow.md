# Workflow Rules

Read `harness/contracts/gate-contract-matrix.yaml` before changing workflow behavior.

Canonical gate order:

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
-> writing_plan
-> plan_review
-> folder_skeleton
-> implementation
-> work
-> verification
-> acceptance
-> compound_capture
-> compound_review
-> archive
-> handoff
```

`plan_review completed != implementation approved`.

`folder_skeleton` may create approved empty folders, `.gitkeep`, and approved non-executable placeholder docs only.

`module_structure` decides folder/module shape but does not create folders.

`implementation` requires `implementation-approval.md` and matching `task.yaml approval_summary`.

`PermissionDecision` decides whether a capability may run.

`research` is canonical. `evidence_check` is a legacy alias only.

## Artifact Language Policy

Human-facing artifacts use the user's language.

Human-facing artifacts include planning files, `implementation-approval.md`, `archive-summary.md`, `verification.md`, and `handoff.md`.

Agents write live human-facing artifacts in the current user's language.

Machine-readable artifacts keep stable schema keys.

Machine-readable artifacts include `task.yaml`, contracts, and PermissionDecision outputs.

## Artifact Routing

Before a gate or skill starts, check:

```text
harness/contracts/artifact-registry.yaml
harness/contracts/skill-artifact-map.yaml
```

Do not rely on memory for required artifacts.

Use the current gate artifact list to decide the smallest required read/write surface.

Verification checks required artifacts by existence and content.

Plain rule: compound_lookup reads solution indexes before detailed solution files.

`compound_lookup` reads solution indexes before detailed solution files.

`compound_capture` records candidates in `learning-capture.md`.

`compound_review` decides long-term promotion.

compound_capture records candidates in `learning-capture.md`.

compound_review decides long-term promotion.

`learning-capture.md` and `compound-review.md` are human-facing artifacts and use the user's language.

## Capability Gates

These capabilities require explicit approval:

```text
network.live_target
package.install
git.commit
git.push
file.write.outside_modules
file.write.harness_core
```

Web research is not live target access.

Package install, live target access, commit, and push are separate approvals.

## Current State

`task.yaml` is the current state cache.

`planning/00-current-planning-context.md` is the short hot-context summary for the active task.

`implementation-approval.md` is the human-facing implementation approval summary.

## Archive And Handoff

Archive requires `archive-summary.md`.

Archive is cold context. Future tasks read indexes and summaries before detailed archived artifacts.

`handoff.md` is updated only when the user asks for a new-chat handoff.

handoff.md is a status summary, not the restart prompt container.

The next-chat prompt is returned in the chat response.
