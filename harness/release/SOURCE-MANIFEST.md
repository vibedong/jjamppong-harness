# Source Manifest

This manifest describes the release candidate source surfaces for Jjamppong Harness.

## Canonical Surfaces

- `harness/contracts/`: machine-readable gate, permission, path, installer, and task contracts.
- `tests/contracts/`: regression tests that prove the contracts stay enforced.
- `harness/permission/`: PermissionDecision MVP.
- `harness/verify/`: installed-project verifier.
- `harness/doctor/`: read-only diagnosis and proposal generator.
- `harness/installer/` and `bin/`: npm/npx installer and CLI entry points.
- `harness/templates/`: task and module artifact templates.
- `harness/rules/`: human-readable projections of the contracts.
- `AGENTS.md`: short runtime instruction entry point.
- `README.md`: Korean human guide.

## Non-Canonical Or Isolated Surfaces

- `harness/docs/tasks/active/` must be empty except `.gitkeep` in the template release candidate.
- `harness/docs/tasks/archive/` is cold storage and should be read through summaries/indexes first.
- `source-history/` is audit trail only if present. It must not outrank `FINAL-PLAN.md`, contracts, or tests.
- Historical references to OuroSuper may appear only as rationale or invalid nested-install examples, never as an active route.

## Alias Rule

`research` is the canonical gate id. `evidence_check` is a legacy alias only.

## Release Surface

Release checksums are recorded in `harness/release/CHECKSUMS.sha256`.
