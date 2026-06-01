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
OuroSuper Planning
  Use OuroSuper interview, seed, and handoff flow.

Superpowers Writing Plans
  Use superpowers:writing-plans.

Implementation / Apply
  Use superpowers:using-git-worktrees first when code changes are expected.
  Use superpowers:subagent-driven-development by default.
  Use superpowers:executing-plans only when subagents are not available or the user asks for a separate execution session.
  Use superpowers:test-driven-development for features, bug fixes, behavior changes, and refactoring.
  Use superpowers:systematic-debugging before fixing bugs, failing tests, build failures, or unexpected behavior.
  Use superpowers:requesting-code-review for major work and review checkpoints.

Verification
  Use superpowers:verification-before-completion before claiming completion.
  Use superpowers:finishing-a-development-branch after implementation and verification.

Compound Engineering
  Use ce-compound after verification.
```

If a required plugin or skill is unavailable, stop and tell the user. Do not silently replace it with an informal flow.

## 3. User-Owned Exceptions

Only the user can request Short Loop.

Acceptable user phrases include:

- "이건 작은 작업이야"
- "기획 생략하고 바로 해"
- "바로 수정해"
- "폴더명만 바꿔"

## 4. Plan Review Question Is Mandatory

After `superpowers:writing-plans`, use the exact Mandatory Plan Review Question in `harness/rules/workflow.md`.

If the user chooses `C`, use the exact Korean warning in `harness/rules/workflow.md`, then record the skip reason in `harness/state/superpowers/reviews.md`, then continue only after explicit user confirmation.

Do not implement before this question is answered.

## 5. Module Structure Is Not Invented Inline

Module type and folder standards are not decided ad hoc.

Creating or changing module types and folder standards is itself substantive work and follows the Full Workflow.

Approved results are recorded in:

```text
harness/state/module-structure.md
```

Codex must not create module folders that conflict with the recorded module structure.

## 6. Progress Display Uses The Codex App

For substantive work, maintain the Codex app progress checklist.

Do not create `harness/state/progress.md`.

## 7. State Paths Are Fixed

Use these paths:

```text
harness/state/intake.md
harness/state/ourosuper/
harness/state/module-structure.md
harness/state/superpowers/
harness/state/verification/
harness/state/compound.md
docs/solutions/
```

## 8. Proposals Protect Live Rules

New harness rule changes first go into `proposals/`.

After user approval, reflect the proposal into the live file and delete the proposal file.

Do not keep approved proposal files as archive.

After `ce-compound`, use the exact Learning Update Question in `harness/rules/workflow.md`. Do not change live rules until a proposal is approved.

## 9. Handoff Is Conditional

Do not automatically update `handoff.md`.

Update it only when the user explicitly asks for next-chat handoff.

## 10. Explain Simply

The user may be non-technical.

Ask deep questions in simple language. When recommending Python, TypeScript, tests, Git, worktrees, or GitHub, explain why in plain language.
