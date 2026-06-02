# Issue 001: Agents MD Management Plugin

## Goal

Implement a local Codex plugin named `agents-md-management` that audits, scores, and revises Codex instruction files.

## Scope

- Add `plugins/agents-md-management/.codex-plugin/plugin.json`.
- Add `agents-md-chain-audit`, `agents-md-improver`, and `revise-agents-md` skills.
- Add deterministic Python scripts for chain discovery and scoring.
- Add standard-library tests.
- Add optional README and AGENTS.md notes after review approval.

## Acceptance Criteria

- Plugin manifest validates.
- All three skill folders validate.
- Script tests pass.
- Chain audit handles global override, project override, empty files, nested directories, and fallback names.
- Scoring flags missing commands, missing verification, context budget risk, and unguarded destructive commands.
- No implementation path hardcodes the user's example project path.
- Commit and push are gated behind explicit user approval.
