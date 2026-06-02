---
name: revise-agents-md
description: Convert session learnings into concise proposed updates for Codex AGENTS.md instruction files. Use when the user asks to remember lessons, update AGENTS.md from this session, capture workflow learnings, or revise Codex project instructions after a task.
---

# Revise AGENTS.md

Capture only reusable learnings from the session.

## Workflow

1. List session learnings that would help future Codex runs.
2. Remove one-off facts, temporary paths, hidden answers, and private session-only details.
3. Route each learning using `references/routing-rules.md`.
4. Show proposed diffs.
5. Ask for approval before editing.

## Subagents

For large sessions or repeated failures, use read-only subagents when the host supports them:

- Learning Extractor: lists reusable lessons and removes one-off facts.
- Routing Reviewer: checks whether each lesson belongs in global, repo, nested, or override instructions.

Subagents report only. The main agent owns the final diff and approval request.

## Output

````markdown
## Proposed AGENTS.md Updates

### Update: <path>
Why:

```diff
+ <concise reusable instruction>
```
````
