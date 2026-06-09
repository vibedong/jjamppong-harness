# Planning State

No active task is in progress.

When a task starts, record:

- Active Task Slug
- Current Gate
- Task YAML Current State
- Current Planning Context
- Current Allowed Capability Scope
- Next Locked Gate

Task-specific gate status belongs in `harness/docs/tasks/active/<slug>/task.yaml`.

`planning/00-current-planning-context.md` is the short hot-context summary for the active task.

`implementation-approval.md` is the human-readable approval summary for implementation scope.

This state file points to the active task only. It is not the source of truth for gate approvals or permissions.
