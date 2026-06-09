# Source Manifest

This manifest describes the release candidate source surfaces for Jjamppong Harness.

## Canonical Surfaces

- `harness/contracts/`: machine-readable gate, permission, path, installer, and task contracts.
- `harness/contracts/artifact-registry.yaml`: artifact role, language, lifecycle, and state/content check policy.
- `harness/contracts/skill-artifact-map.yaml`: gate-to-artifact read/write routing contract.
- `tests/contracts/`: regression tests that prove the contracts stay enforced.
- `harness/permission/`: PermissionDecision MVP.
- `harness/verify/`: installed-project verifier.
- `harness/doctor/`: read-only diagnosis and proposal generator.
- `harness/lifecycle/learning-classifier.js`: structured evidence classifier for compound learning candidates.
- `harness/installer/` and `bin/`: npm/npx installer and CLI entry points.
- `harness/templates/`: task and module artifact templates.
- `harness/docs/solutions/`: long-term compound learning summaries read through indexes before detailed bodies.
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
