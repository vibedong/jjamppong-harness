# Routing Rules

Route session learnings by owner:

- Global user preference: `~/.codex/AGENTS.md` or `~/.codex/AGENTS.override.md`.
- Repository-wide shared rule: repository root `AGENTS.md`.
- Directory-specific project rule: nearest relevant nested `AGENTS.md`.
- Private local-only override: `AGENTS.override.md`.

Global files should stay cross-project and short. Do not move repository workflow, project folder names, product setup steps, or local checkout paths into global instructions.

Do not add:

- One-off task facts.
- Temporary local paths.
- Secrets or credentials.
- Hidden answers, tests, or private references.
- Instructions that contradict higher-priority system, developer, or project rules.
