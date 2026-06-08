# Global Handoff

Root `handoff.md` is the global next-chat/context-transfer file.

Write this file in the user's language when the user requests a handoff.

Include status summary, current decisions, remaining work, risks, and files the next agent should read.

Do not store the next-chat restart prompt here by default. Return that prompt in the chat response after creating the handoff.

Task-specific summaries belong under:

`harness/docs/tasks/active/<YYYY-MM-DD-short-topic>/brief.md`
