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
