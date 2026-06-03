# Planning State

No active task is in progress.

When a task starts, record:

- Active Task Slug
- Current Stage
- Current Gate
- Task Gate Ledger
- Current Allowed Write Scope
- Next Locked Gate

Task-specific gate approvals belong in `harness/docs/tasks/active/<slug>/gate-ledger.md`.

This state file points to the active task only. It is not the source of truth for gate approvals.
