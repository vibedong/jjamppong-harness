# AGENTS.md

## Scope

This repository uses 짬뽕하네스 (`jjamppong-harness`), a private agent workflow harness.

## Harness Root Model

- The directory containing this `AGENTS.md` is the harness root.
- When installing the harness into a project folder such as `F:/mptech`, `AGENTS.md`, `harness/`, `modules/`, `module-template/`, and `proposals/` must live directly under `F:/mptech`. AI task artifacts live under `harness/docs/`; the project-root artifact area must not be used for AI task output.
- Do not create a nested `F:/mptech/ourosuper-harness/` folder unless the user explicitly wants to maintain a separate copy of the template source.
- Product or application work lives under `modules/` only after the Full Workflow has approved the relevant module structure.
- The template-maintenance checkout at `F:/Folder/ourosuper-harness` is for updating the reusable harness template. Do not create product or application code there.
- A project harness root must not keep `origin` pointed at `https://github.com/vibedong/ourosuper-harness.git`. That remote is only for the template-maintenance checkout.
- If the repository role is unclear, stop and ask the user before writing product code, changing `modules/`, or starting request intake.

## New Project Request Trigger

If the user says they want to make, start, or build a project, for example "ERP 프로젝트 만들고 싶어", first decide whether the current directory is the intended harness root or the template-maintenance checkout.

- For a new project folder: create or clone the private project repository so the harness files land directly under the target folder, for example `F:/mptech/AGENTS.md`, not `F:/mptech/ourosuper-harness/AGENTS.md`.
- If the user names `vibedong/ourosuper-harness.git` as the install source, treat it as a template source, not as the final project remote.
- Unless the user gives a different project slug, derive the project slug from the target folder name. Example: `F:/mptech` uses `mptech`.
- Create or verify the private project repository, for example `vibedong/mptech`, then set the project harness root `origin` to that project repository and push `main` only after explicit user approval for push.
- Before reporting setup complete, verify `git remote -v` in the project harness root points to the project repository, not to `vibedong/ourosuper-harness.git`.
- In the project harness root: record request intake in `harness/state/intake.md`, then run the full mandatory planning gate: setup-matt-pocock-skills readiness check, grill-with-docs, to-prd, User PRD Approval, to-issues, User Issue Approval, task brief, superpowers:writing-plans, and the Mandatory Plan Review Question. Record the choice and results in `harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/reviews.md`; do not implement before that review choice is recorded.
- Do not create folders under `modules/` until `harness/state/module-structure.md` approves the module structure.

## Branch And Commit Control

- For substantive work in a project harness root, create or switch to a task branch before the first file edit unless the user explicitly says to work on the current branch.
- Use a short ASCII branch name derived from the task, for example `task/g2b-lighting-daily-lookup`.
- Do not create product, module, or workflow changes directly on `main` after project setup is complete.
- Do not run `git commit`, `git push`, `gh pr create`, merge, or release commands unless the user explicitly approves that exact action in the current chat.
- Before asking for commit or push approval, show the changed files and a short summary of what will be committed or pushed.
- If the work stops before approval, leave changes uncommitted and report the branch name and `git status --short`.

## Always Use

- Use the `vowline` skill for substantive work, including subagents.
- Use the Codex app progress checklist for substantive work.
- Explain technical choices in simple language because the user may be non-technical.
- Use Matt Pocock planning skills for the mandatory planning gate: `setup-matt-pocock-skills`, `grill-with-docs`, `to-prd`, and `to-issues`.
- Use Superpowers for writing plans, implementation, and verification.
- Use gstack review skills when running plan review.
- Use Compound Engineering after verification.

## Required Reads

At the start of a substantive task, read:

1. `harness/rules/workflow.md`
2. `harness/rules/rules.md`

## Conditional Reads

- Read `handoff.md` only when the user asks to continue from a previous chat, asks for handoff, or says the work should be prepared for a new chat.
- Read `harness/rules/module-types.md` when creating or changing module types, module folders, or module structure.
- Read `README.md` when explaining the harness to a person or updating repository documentation.
- Read `proposals/` only when the user asks to review, create, approve, or reflect a pending harness change.
- Search `harness/docs/solutions/` only when a related prior solution may help, when running Compound Engineering refresh work, or when `ce-compound` needs existing learning context.

## Hard Rules

- Do not silently skip the Full Workflow.
- Do not invent module folders outside the approved module structure.
- Use root `handoff.md` only for global next-chat/context transfer. Task summaries belong under `harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/brief.md`.
- Do not write product code in the `ourosuper-harness` source/template repository.
- Do not finish new project setup while the project harness root `origin` still points to `vibedong/ourosuper-harness.git`.
- Do not commit or push without explicit user approval in the current chat.
- Do not change live harness rules directly from a new idea; use `proposals/` first.
