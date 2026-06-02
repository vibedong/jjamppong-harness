---
name: agents-md-chain-audit
description: Audit Codex AGENTS.md instruction discovery. Use when the user asks which AGENTS.md files Codex loads, why instructions are ignored, whether AGENTS.override.md is shadowing AGENTS.md, or how global/project/fallback instruction files interact.
---

# AGENTS.md Chain Audit

Run this skill before changing instruction files when discovery behavior is unclear.

## Workflow

1. Resolve the target working directory.
2. Resolve the plugin root as the parent directory that contains both `skills/` and `scripts/`, then run `<plugin-root>/scripts/discover_agents_chain.py`.
3. Report selected global file, selected project chain, ignored same-directory files, empty skipped files, fallback names, and byte-budget status.
4. Do not edit files.

## Subagents

- Use the local script directly for ordinary audits.
- For broad repositories, many nested instruction files, or confusing override behavior, dispatch read-only subagents when the host supports them:
  - Chain Auditor: verify selected global and project chain.
  - Override Reviewer: check ignored same-directory files and shadowing risk.
  - Budget Reviewer: check file sizes and likely context-budget pressure.
- Subagents report findings only. The main agent consolidates the audit and decides the recommended next action.

## Output

Use this format:

```markdown
## AGENTS.md Chain Audit

- Target cwd:
- Project root:
- Global selected:
- Project chain:
- Ignored:
- Empty skipped:
- Byte budget:
- Risks:
- Recommended next action:
```
