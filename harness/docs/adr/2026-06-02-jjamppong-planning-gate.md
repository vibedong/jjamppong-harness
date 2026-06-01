# ADR: Use 짬뽕하네스 Planning Gate

## Status

Accepted after proposal approval.

## Context

The previous harness centered planning on OuroSuper interview, Seed YAML, and handoff-packet concepts. That flow made the harness depend on a planning runtime and produced confusion around missing ambiguity scores, duplicated handoff meanings, and scattered AI artifacts.

## Decision

Use 짬뽕하네스 as the harness workflow. The planning gate combines Matt Pocock planning skills, Superpowers writing plans, gstack review, Compound Engineering learning, and vowline discipline.

AI task artifacts live under `harness/docs/tasks/active/<slug>/` while in progress and move to `harness/docs/tasks/archive/<slug>/` after completion by default. Long-lived reusable learning lives under `harness/docs/solutions/`. `harness/state/` stores only small pointer/status files.

## Alternatives Considered

- Keep OuroSuper as the planning engine.
- Store AI artifacts under root `docs/`.
- Put reusable solutions under `harness/state/`.
- Restore a small-task bypass.

## Consequences

- The workflow is more explicit and easier to audit.
- Every task creates more planning artifacts.
- The user reviews one active task folder during work, then mostly works from `modules/` after approval.
- Root `handoff.md` keeps its original next-chat role.

## Rollback

Reintroduce a proposal that restores the previous workflow and updates `harness/rules/`, README, and AGENTS.md together. Do not partially restore OuroSuper terms without restoring the full old workflow.
