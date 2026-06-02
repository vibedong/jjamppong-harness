# Request Intake

## Active Request

User Request: Create a writing plan for a Codex-native replacement for Claude MD Management.

Plain-Language Interpretation: The user wants a plan for an `AGENTS.md` management plugin/skill set that keeps the useful parts of Anthropic's Claude MD Management, but follows OpenAI Codex behavior: `AGENTS.md`, `AGENTS.override.md`, global/project instruction chains, fallback filenames, byte limits, Codex skills, and Codex plugin packaging.

Workflow Decision: This is a harness/tooling change. Create a writing plan first under `harness/docs/tasks/active/2026-06-02-agents-md-management/writing-plan.md`. Do not implement, commit, push, create a PR, or change live harness rules before the plan review step.

Required Plugins Or Skills:

- `vowline`
- `superpowers:writing-plans`
- `plugin-creator`
- `skill-creator`

Current Blockers:

- Implementation must wait until the user chooses the Mandatory Plan Review option.
- If the plan changes live harness behavior, execution must start from a proposal under `proposals/`.
