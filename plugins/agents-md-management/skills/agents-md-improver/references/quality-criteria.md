# AGENTS.md Quality Criteria

Score each instruction file out of 100. Use the right scope before judging quality.

## Repository Scope

Use for repository root and nested project instruction files:

- Instruction discovery safety: 15
- Commands and verification: 15
- Architecture and workflow clarity: 15
- Role and ownership separation: 10
- Override and conflict safety: 15
- Context budget and concision: 10
- Currentness: 10
- Human readability: 10

## Global Scope

Use for global Codex preference files directly under `CODEX_HOME` or `~/.codex`, such as `~/.codex/AGENTS.md`:

- Personal preference clarity: 25
- Cross-project scope: 20
- Safety or skill policy: 25
- Global concision: 15
- Human readability: 15

Global files can be short. Do not mark them down for omitting repository workflow, module layout, branch policy, or project-specific verification commands.

Grades:

- A: 90-100
- B: 75-89
- C: 60-74
- D: 40-59
- F: 0-39
