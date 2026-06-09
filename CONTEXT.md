# 짬뽕하네스 Context

## Language

**짬뽕하네스**:
A private agent workflow harness that combines Matt Pocock planning skills, Superpowers execution planning, gstack review lenses, Compound Engineering learning, and vowline discipline.
Avoid: calling the whole harness Matt Planning Harness or OuroSuper Harness.

**Planning gate**:
The mandatory pre-implementation sequence that every task must pass before execution.

**Task artifact**:
A file created under `harness/docs/tasks/active/<slug>/` while planning, reviewing, implementing, or verifying a task.

**Task state**:
The compact current state at `harness/docs/tasks/active/<slug>/task.yaml`.
It records `current_gate`, `next_action`, and `approval_summary`, but it does not store history.

**Implementation approval**:
The human-readable approval summary at `harness/docs/tasks/active/<slug>/implementation-approval.md`.
Dangerous work requires both this summary and matching `task.yaml approval_summary`.

**Current planning context**:
The short hot-context summary at `harness/docs/tasks/active/<slug>/planning/00-current-planning-context.md`.
It should contain only decisions, open questions, and the next action.

**Brief**:
The task-specific summary at `harness/docs/tasks/active/<slug>/brief.md`. This is not the same as root `handoff.md`.

**Writing plan**:
A Superpowers implementation plan at `harness/docs/tasks/active/<slug>/planning/06-writing-plan.md`.

**Module**:
Product or application code under `modules/`, created only after approved module structure exists.

**Proposal**:
A pending harness rule change under `proposals/`, used before changing live rules.

**Archive summary**:
The required cold-context summary at `archive-summary.md` before moving a task from `active/` to `archive/YYYY/MM/`.

## Relationships

- `task.yaml` records current gate and approval summary, not full history.
- `implementation-approval.md` explains approved implementation scope in the user's language.
- `planning/00-current-planning-context.md` is the short context a new chat should read first.
- The planning gate creates a PRD.
- A PRD is decomposed into one or more local task issues.
- The task issues inform the brief and writing plan.
- The writing plan controls implementation.
- Verification and Compound Engineering run after implementation.
- Finished task artifacts move from `harness/docs/tasks/active/` to `harness/docs/tasks/archive/YYYY/MM/` only after `archive-summary.md` exists.
