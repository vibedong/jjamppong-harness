# 짬뽕하네스 Context

## Language

**짬뽕하네스**:
A private agent workflow harness that combines Matt Pocock planning skills, Superpowers execution planning, gstack review lenses, Compound Engineering learning, and vowline discipline.
Avoid: calling the whole harness Matt Planning Harness or OuroSuper Harness.

**Planning gate**:
The mandatory pre-implementation sequence that every task must pass before execution.

**Task artifact**:
A file created under `harness/docs/tasks/active/<slug>/` while planning, reviewing, implementing, or verifying a task.

**Event log**:
The append-only canonical task record at `harness/docs/tasks/active/<slug>/events.jsonl`.
This is the source of truth for gate questions, user answers, approval decisions, permission decisions, verification results, and archive events.

**Gate ledger**:
The human-readable projection at `harness/docs/tasks/active/<slug>/gate-ledger.md`.
It helps people review decisions, but it does not grant permission by itself.

**Task cache**:
The compact derived state at `harness/docs/tasks/active/<slug>/task.yaml`.
If it disagrees with `events.jsonl`, verification fails and `events.jsonl` wins.

**Brief**:
The task-specific summary at `harness/docs/tasks/active/<slug>/brief.md`. This is not the same as root `handoff.md`.

**Writing plan**:
A Superpowers implementation plan at `harness/docs/tasks/active/<slug>/writing-plan.md`.

**Module**:
Product or application code under `modules/`, created only after approved module structure exists.

**Proposal**:
A pending harness rule change under `proposals/`, used before changing live rules.

**Archive summary**:
The required cold-context summary at `archive-summary.md` before moving a task from `active/` to `archive/YYYY/MM/`.

## Relationships

- The event log records gate questions, user answers, approval decisions, and permission decisions.
- `gate-ledger.md`, `task.yaml`, and `planning-pack.md` are projections or manifests derived from approved state.
- The planning gate creates a PRD.
- A PRD is decomposed into one or more local task issues.
- The task issues inform the brief and writing plan.
- The writing plan controls implementation.
- Verification and Compound Engineering run after implementation.
- Finished task artifacts move from `harness/docs/tasks/active/` to `harness/docs/tasks/archive/YYYY/MM/` only after `archive-summary.md` exists.
