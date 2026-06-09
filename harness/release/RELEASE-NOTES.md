# Release Notes

## 0.1.0 Release Candidate

This release candidate rebuilds the harness around executable contracts instead of prose-only rules.

Included:

- Contract schemas and regression catalog.
- PermissionDecision MVP for capability and path decisions.
- Verify/doctor commands for installed projects.
- npm/npx installer with install-only stop behavior and `harness.lock.yaml`.
- Task templates based on `task.yaml`, current planning context, implementation approval, and verification summaries.
- Artifact registry and skill-artifact-map contracts without read-receipt event requirements.
- State/content verification for artifact-dependent gates.
- Structured compound learning classifier plus capture and review templates.
- Structured user correction summaries that can become learning candidates.
- Indexed long-term solution buckets for repeated harness mistakes.
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
- `writing_plan` requires substantive PRD, issues, module structure, and checkbox writing plan artifacts.
- `compound_lookup` reads compound state and solution index before detailed solution files.
- `compound_capture` classifies only structured verify, permission, gate-order, hot-context, and user-correction summaries.
- `compound_capture` must produce candidate metadata; an untouched starter capture file is invalid.
- Long-term solution writes require `compound_review`.
- Existing legacy ledger files are warnings unless they remain in live core contracts/templates.
- Fresh task creation does not create legacy ledger artifacts.

Not included:

- Active product tasks.
- Product code.
- GitHub repository creation.
- Automatic commit or push.
- OuroSuper as an active workflow.
