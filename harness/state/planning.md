# Planning State

No active task is in progress.

When a task starts, record:

- Active Task Slug
- Current Gate
- Canonical Event Log
- Gate Ledger Projection
- Task YAML Cache
- Current Allowed Capability Scope
- Next Locked Gate

Task-specific gate approvals belong in `harness/docs/tasks/active/<slug>/events.jsonl`.

`gate-ledger.md` is a human-readable projection.

`task.yaml` is a derived cache.

This state file points to the active task only. It is not the source of truth for gate approvals or permissions.
