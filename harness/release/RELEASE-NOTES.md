# Release Notes

## 0.1.0 Release Candidate

This release candidate rebuilds the harness around executable contracts instead of prose-only rules.

Included:

- Contract schemas and regression catalog.
- PermissionDecision MVP for capability and path decisions.
- Verify/doctor commands for installed projects.
- npm/npx installer with install-only stop behavior and `harness.lock.yaml`.
- Task templates based on `events.jsonl` as canonical state.
- Short `AGENTS.md` and Korean README.
- Empty `harness/docs/tasks/active/` template state.

Important behavior:

- Installation stops after install and verify.
- `grill` happens before project reads for product planning.
- `research` is canonical; `evidence_check` is only a legacy alias.
- `plan_review completed` does not approve implementation.
- `module_structure` does not create folders.
- `folder_skeleton` does not create code, tests, fixtures, runtime config, package files, live access, commits, or pushes.
- Package install, live target access, commit, and push each require separate explicit approval.

Not included:

- Active product tasks.
- Product code.
- GitHub repository creation.
- Automatic commit or push.
- OuroSuper as an active workflow.
