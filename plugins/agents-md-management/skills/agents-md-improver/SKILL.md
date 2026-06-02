---
name: agents-md-improver
description: Audit and improve Codex AGENTS.md instruction files. Use when the user asks to check, score, update, improve, or fix AGENTS.md or AGENTS.override.md files, especially for Codex instruction-chain quality, command accuracy, override safety, and context-budget issues.
---

# AGENTS.md Improver

Audit first, propose second, edit only after approval.

## Workflow

1. Use `agents-md-chain-audit` or run `<plugin-root>/scripts/discover_agents_chain.py`.
2. Run `<plugin-root>/scripts/score_agents_md.py --scope auto` on selected instruction files.
3. Present a quality report before edits.
4. Propose targeted diffs only.
5. Ask for approval before editing.
6. Preserve owner boundaries: global preferences stay global, repository rules stay in repo files, local private rules stay in `AGENTS.override.md`.

## Scopes

- Use `--scope auto` by default.
- Use `--scope global` for a known global Codex file such as `~/.codex/AGENTS.md`.
- Use `--scope repo` for repository or directory-specific instruction files when path detection is ambiguous.

## Subagents

For broad rewrites or multi-file instruction chains, use read-only subagents when the host supports them:

- Chain Auditor: confirms which files are actually loaded.
- Quality Reviewer: reviews scores, gaps, and context-budget risk.
- Ownership/Policy Reviewer: checks whether proposed rules belong in global, repo, nested, or override files.

Subagents must not edit files. The main agent merges their findings, proposes the final diff, and asks the user for approval before writing.

## Quality Report

```markdown
## AGENTS.md Quality Report

### Summary
- Files scored:
- Average score:
- Files needing update:

### Findings
- File:
- Scope:
- Score:
- Issues:
- Recommended diff:
```
