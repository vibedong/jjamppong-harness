# AGENTS.md

## Scope

This repository uses OuroSuper Harness.

## Harness Root Model

- The directory containing this `AGENTS.md` is the harness root.
- When installing the harness into a project folder such as `F:/mptech`, `AGENTS.md`, `harness/`, `modules/`, `docs/`, `module-template/`, and `proposals/` must live directly under `F:/mptech`.
- Do not create a nested `F:/mptech/ourosuper-harness/` folder unless the user explicitly wants to maintain a separate copy of the template source.
- Product or application work lives under `modules/` only after the Full Workflow has approved the relevant module structure.
- The template-maintenance checkout at `F:/Folder/ourosuper-harness` is for updating the reusable harness template. Do not create product or application code there.
- If the repository role is unclear, stop and ask the user before writing product code, changing `modules/`, or starting request intake.

## New Project Request Trigger

If the user says they want to make, start, or build a project, for example "ERP 프로젝트 만들고 싶어", first decide whether the current directory is the intended harness root or the template-maintenance checkout.

- For a new project folder: create or clone the private project repository so the harness files land directly under the target folder, for example `F:/mptech/AGENTS.md`, not `F:/mptech/ourosuper-harness/AGENTS.md`.
- In the project harness root: record request intake in `harness/state/intake.md`, run OuroSuper Planning, then continue through the Full Workflow.
- Do not create folders under `modules/` until `harness/state/module-structure.md` approves the module structure.

## Always Use

- Use the `vowline` skill for substantive work, including subagents.
- Use the Codex app progress checklist for substantive work.
- Explain technical choices in simple language because the user may be non-technical.

## Required Reads

At the start of a substantive task, read:

1. `harness/rules/workflow.md`
2. `harness/rules/rules.md`

## Conditional Reads

- Read `handoff.md` only when the user asks to continue from a previous chat, asks for handoff, or says the work should be prepared for a new chat.
- Read `harness/rules/module-types.md` when creating or changing module types, module folders, or module structure.
- Read `README.md` when explaining the harness to a person or updating repository documentation.
- Read `proposals/` only when the user asks to review, create, approve, or reflect a pending harness change.
- Search `docs/solutions/` only when a related prior solution may help, when running Compound Engineering refresh work, or when `ce-compound` needs existing learning context.

## Hard Rules

- Do not silently skip the Full Workflow.
- Do not invent module folders outside the approved module structure.
- Do not update `handoff.md` unless the user explicitly asks for next-chat handoff.
- Do not write product code in the `ourosuper-harness` source/template repository.
- Do not change live harness rules directly from a new idea; use `proposals/` first.
