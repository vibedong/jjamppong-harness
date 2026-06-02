# Agents MD Management Brief

## Decision

Build a Codex-native `agents-md-management` plugin rather than renaming Claude MD Management directly.

## Why

Claude and Codex both use repository instruction files, but their discovery and quality risks differ. Codex needs chain-aware checks for `AGENTS.override.md`, fallback filenames, root-to-current-directory merge order, and instruction byte budget.

## Execution Shape

1. Write a proposal.
2. Scaffold a Codex plugin.
3. Add deterministic chain discovery and scoring scripts.
4. Add three focused skills.
5. Validate with unit tests and skill/plugin validators.
6. Record review and verification artifacts.

## Current Gate

The user selected review option A: CEO + Eng + Plan Compliance.

## Implementation Status

- Proposal was applied and removed according to the harness proposal rule.
- Local plugin files were created under `plugins/agents-md-management/`.
- README and AGENTS.md describe the plugin as an optional maintenance tool, not a mandatory workflow step.
