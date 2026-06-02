# Grill Routing And Module Structure Gates Reviews

## Selected Review Option

User selected option 1: CEO + Eng + Plan Compliance.

## CEO Review

Status: issues found, scope accepted after corrections.

Findings:

1. OK: The plan addresses the root cause in harness rules instead of telling users to write longer prompts.
2. WARNING: The gate can become annoying if it asks duplicate questions after reading code. The live rules must say that Codex should answer from files first and ask the user only for decisions that evidence cannot resolve.
3. WARNING: `grill-with-docs` and `grill-me` must not both become mandatory every time. The rule should route by request shape, then use `grill-me` only for remaining user-intent uncertainty.

Accepted changes:

- Keep the gate mandatory.
- Add "no duplicate questioning" language.
- Add a human-readable example for the `dailynara` / 나라장터 crawler scenario.

## Eng Review

Status: issues found, plan needs revision.

Findings:

1. CRITICAL: The original plan told agents to record grill results in `brief.md`, but `brief.md` is created after PRD and issue approval. This creates an impossible order.
2. CRITICAL: The README workflow list would remain stale if only a Planning Behavior section is added. The visible default workflow must also be updated.
3. WARNING: Verification should explicitly catch the old `3. grill-with-docs` full-workflow step so the stale path cannot remain in `workflow.md` or `README.md`.

Accepted changes:

- Add `harness/docs/tasks/active/<slug>/grill.md` as the task-specific grill output.
- Update README's default workflow, not only add explanatory text.
- Add a stale-workflow negative check.

## Plan Compliance Review

Status: issues found, plan needs revision.

Findings:

1. WARNING: The plan must keep the proposal-first rule intact. Live rule edits still require user approval after the proposal is written.
2. WARNING: The plan review result should be visible both in `reviews.md` and at the end of `writing-plan.md`.
3. OK: The plan uses exact file paths, concrete text blocks, deterministic commands, and no placeholders.

Accepted changes:

- Keep Task 1 as a proposal-only task with a hard stop.
- Add a final `GSTACK REVIEW REPORT` section to `writing-plan.md`.
- Do not modify live harness rules during plan revision.

## Verdict

Revise the writing plan before implementation. After revision, the plan is suitable for proposal creation first, then live rule updates only after user approval.

## Second Review: CEO + Eng + Plan Compliance

Status: minor issues found and corrected in the writing plan.

### CEO Review

Findings:

1. OK: The plan still solves the user-visible failure mode: agents should not skip grilling or compensate by requiring longer user prompts.
2. WARNING: A mandatory Module Structure Gate could become annoying if agents ask module-structure questions on non-module tasks.

Accepted change:

- The writing plan now says non-module work records the Module Structure Gate as not applicable and does not ask module-structure questions.

### Eng Review

Findings:

1. WARNING: `grill.md` needed a clear gate status so the next agent knows whether PRD can proceed.
2. WARNING: The `AGENTS.md` verification command searched for `grill completion gate`, but the inserted text used `grill session is not complete`.

Accepted changes:

- `grill.md` must include gate status: `complete`, `blocked`, or `deferred by user`.
- The `AGENTS.md` verification pattern now matches the actual planned wording and `grill.md`.

### Plan Compliance Review

Findings:

1. OK: Proposal-first remains intact.
2. OK: Live rule files remain untouched before proposal approval.
3. WARNING: The plan's self-review type consistency list omitted `Grill Result Record`.

Accepted change:

- The self-review now includes `Grill Result Record` and the `grill.md` path.

### Second Review Verdict

No remaining blocker found. The plan is ready for Task 1 proposal creation only; live rule edits still require user approval after the proposal is created.

## Branch Subagent Review

Status: issues found and corrected.

Reviewers:

- CEO branch reviewer
- Eng branch reviewer
- Plan Compliance branch reviewer

### Findings

1. P2: `grill.md` task artifact was missing even though the new workflow requires a Grill Result Record before PRD.
2. P3: README wording remained somewhat technical for non-technical users.
3. High: `harness/rules/module-types.md` still contained the old `grill-with-docs -> to-prd` module structure flow.
4. High: Module structure ordering was ambiguous because `workflow.md` recorded module structure before PRD while `rules.md` and `module-structure.md` still said module standards must be created through the Full Workflow.
5. Medium: Task artifacts still read as pre-execution artifacts after live rules had already been updated.
6. Medium: Verification did not include `module-types.md` in stale-flow checks.
7. P1: `verification.md` did not record `git status --short --branch`.
8. P2: Install smoke verification was under-recorded because the temp target setup/cleanup was omitted.

### Accepted Fixes

- Added `harness/docs/tasks/active/2026-06-02-grill-module-gates/grill.md`.
- Updated `harness/rules/module-types.md` to use `Grill Routing And Completion Gate`, `Grill Result Record`, and `Module Structure Gate`.
- Updated `harness/state/module-structure.md` to clarify that module type and folder standards are approved through the Module Structure Gate in the Full Workflow.
- Updated `writing-plan.md` to reflect executed status and branch-review corrections.
- Updated `verification.md` to include status output, full install smoke command, `module-types.md` stale-flow checks, and branch review follow-up verification.

### Branch Review Verdict

Corrected. No branch-review blocker remains after the accepted fixes and fresh verification.

## Second Branch Subagent Review

Status: issues found and corrected.

Reviewers:

- CEO branch reviewer
- Eng branch reviewer
- Plan Compliance branch reviewer

### Findings

1. P1/P3: `grill.md` recorded selected route as `grill-with-docs then plan review`, which did not match the new Grill Result Record schema. The allowed route values are `grill-with-docs`, `grill-me`, or `grill-with-docs then grill-me`.
2. P2: `writing-plan.md` still had an internal contradiction: it said to modify `harness/state/module-structure.md` and also said not to modify it.
3. P2: `writing-plan.md` still expected the old module-state sentence `created through the Full Workflow`, while the implemented state correctly says `approved through the Module Structure Gate in the Full Workflow`.
4. P2: `writing-plan.md` install-smoke command still omitted `harness/rules/module-types.md`, while the final verification includes it.
5. P2: Installer copied template-maintenance task artifacts into new local-source installs, which could leak active branch artifacts into new projects.

### Accepted Fixes

- Updated `grill.md` selected route to `grill-with-docs`.
- Clarified that plan review happened after the grill route and is not part of the selected route value.
- Updated `writing-plan.md` to preserve the default module-structure state while allowing the explanatory process sentence to change.
- Updated `writing-plan.md` verification commands and expected text to include `module-types.md` and the final Module Structure Gate wording.
- Updated `scripts/install-jjamppong-harness.ps1` so fresh installs start with empty `harness/docs/tasks/active/` and `harness/docs/tasks/archive/` directories without deleting an existing target project's task artifacts on `-AllowOverwrite`.
- Updated README to document that template-maintenance task artifacts are not copied into new projects and existing project task records are preserved.

### Second Branch Review Verdict

Corrected. Fresh verification must run after these fixes before commit or push.

## Third Branch Subagent Review

Status: one issue found and corrected.

Reviewers:

- CEO branch reviewer
- Eng branch reviewer
- Plan Compliance branch reviewer

### Findings

1. High: README still documented a direct GitHub template clone path for new projects, while task artifact cleanup only runs through `scripts/install-jjamppong-harness.ps1`. Users following that README path could inherit template-maintenance task artifacts and contradict the new install promise.
2. OK: Eng branch reviewer found no blocker.
3. OK: Plan Compliance branch reviewer found no blocker.

### Accepted Fixes

- Replaced the direct GitHub template clone documentation with a single Project Bootstrap With Installer flow.
- Kept GitHub template source as an input to the installer, not as a user-facing clone workflow.
- Updated the installer to back up existing target task artifacts, clear copied template-maintenance task artifacts, then restore the target's own task artifacts on `-AllowOverwrite`.
- Added verification for fresh install empty task artifact directories, existing task artifact preservation, and no template-maintenance artifact leak.

### Third Branch Review Verdict

Corrected. Fresh verification must run after these fixes before commit or push.

## Fourth Branch Subagent Review

Status: issues found and corrected.

Reviewers:

- CEO branch reviewer
- Plan Compliance branch reviewer

### Findings

1. P1: Existing-repo installs could still create or check a derived default remote before preserving the existing project `origin`. This contradicted README's promise that existing project origins are preserved.
2. P2: README still had a recovery path that pointed users toward the old template clone flow and a direct push command.
3. Blocker: The initial approved proposal listed a narrower file scope than the final branch. Later changes to `harness/rules/module-types.md`, `harness/state/module-structure.md`, and `scripts/install-jjamppong-harness.ps1` were accepted in reviews, but the scope expansion approval was not recorded in the task artifacts.
4. Medium: Required task artifacts are untracked until commit time. A tracked-files-only commit would omit `grill.md`, `reviews.md`, `verification.md`, and `writing-plan.md`.

### Accepted Fixes

- Changed the installer to read an existing non-template `origin` before deriving a project repo candidate.
- Skipped GitHub repo creation/checking when an existing project `origin` is being preserved.
- Replaced the stale README recovery path with installer-based recovery and removed the direct push command.
- Recorded the user's scope-expansion approval: "전체다 변경해도돼. 지금 하네스안쓰고있어."
- Recorded the task artifact files as intended commit scope. No commit or staging was performed because commit/push still require explicit user approval.

### Fourth Branch Review Verdict

Corrected. Fresh verification must run after these fixes before commit or push.

## Final Branch Subagent Review

Status: clear.

Reviewers:

- CEO branch reviewer
- Eng branch reviewer
- Plan Compliance branch reviewer

### Findings

No blocker remains.

### Final Review Verdict

CEO + Eng + Plan Compliance cleared after the installer preflight/origin/fail-safe fixes, README installer-only cleanup, scope expansion record, and full installer regression verification.

## Post-Review README Scenario Addition

Status: added after user request.

Change:

- Added `README.md` section `Expected Harness Scenario`.
- The section describes the expected 나라장터/dailynara flow, spaghetti-code handling, and bad behavior the harness should prevent.

Verification:

- Covered by the README Expected Scenario Check in `verification.md`.
