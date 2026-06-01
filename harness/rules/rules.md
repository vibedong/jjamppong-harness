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

If a required plugin or skill is unavailable, stop and tell the user. Do not silently replace it with an informal flow.

## 3. Plan Review Question Is Mandatory

After `superpowers:writing-plans`, use the exact Mandatory Plan Review Question in `harness/rules/workflow.md`.

Store review choice, reviewer names, findings, user decisions, and skipped-review reasons in:

```text
harness/docs/tasks/active/<slug>/reviews.md
```

Do not implement before this question is answered.

## 4. Module Structure Is Not Invented Inline

Module type and folder standards are not decided ad hoc.

Creating or changing module types and folder standards is itself substantive work and follows the Full Workflow.

Approved results are recorded in:

```text
harness/state/module-structure.md
```

Codex must not create module folders that conflict with the recorded module structure.

## 5. Progress Display Uses The Codex App

For substantive work, maintain the Codex app progress checklist.

Do not create `harness/state/progress.md`.

## 6. State Paths Are Fixed

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

## 7. Proposals Protect Live Rules

New harness rule changes first go into `proposals/`.

After user approval, reflect the proposal into the live file and delete the proposal file.

Do not keep approved proposal files as archive.

After `ce-compound`, use the exact Learning Update Question in `harness/rules/workflow.md`. Do not change live rules until a proposal is approved.

## 8. Handoff Is Conditional

Do not automatically update `handoff.md`.

Update it only when the user explicitly asks for next-chat handoff.

## 9. Explain Simply

The user may be non-technical.

Ask deep questions in simple language. When recommending Python, TypeScript, tests, Git, worktrees, or GitHub, explain why in plain language.

## 10. Git Branch And Commit Control

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
