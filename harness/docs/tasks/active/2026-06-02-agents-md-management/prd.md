# Agents MD Management PRD

## Problem

Claude MD Management is useful for maintaining `CLAUDE.md`, but Codex follows a different instruction model. Codex uses `AGENTS.md`, `AGENTS.override.md`, global and project scopes, fallback filenames, root-to-current-directory merge order, and a default 32 KiB instruction byte budget.

A direct rename from Claude MD Management to AGENTS.md Management would miss Codex-specific failure modes such as override shadowing, fallback files being ignored, empty files being skipped, nested directory precedence, and instruction truncation.

## Goal

Create a Codex-native `agents-md-management` plugin plan that can be implemented as a reusable local plugin for auditing, improving, and revising Codex instruction files.

## Users

- The repository maintainer who wants reusable harness rules.
- Future Codex agents that need a clear maintenance workflow for `AGENTS.md`.
- Project collaborators who need readable, stable instructions without one-off local path assumptions.

## Requirements

- Provide an instruction-chain audit skill.
- Provide an AGENTS.md quality improvement skill.
- Provide a session-learning revision skill.
- Use Codex plugin and skill structure.
- Include deterministic scripts and tests.
- Avoid hardcoding one-off project paths.
- Do not edit official OpenAI, Anthropic, Superpowers, Matt Pocock, gstack, or Compound plugin sources.
- Do not install into a personal marketplace unless the user separately asks.
- Do not run shutdown commands.

## Non-Goals

- No product code under `modules/`.
- No GitHub PR or release in this planning task.
- No live harness rule change until proposal and review steps are approved.

## Success Criteria

- `writing-plan.md` explains exact files, test commands, review gates, and verification.
- `reviews.md` records CEO, Eng, and Plan Compliance review findings.
- The plan can be executed without guessing where major files belong.
