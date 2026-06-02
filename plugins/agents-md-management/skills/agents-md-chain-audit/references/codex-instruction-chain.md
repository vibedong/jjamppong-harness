# Codex Instruction Chain

Codex reads global instructions from `CODEX_HOME` or `~/.codex`.

Global scope:

1. `AGENTS.override.md`
2. `AGENTS.md`

Project scope:

1. Start at the project root.
2. Walk down to the current working directory.
3. In each directory, select the first non-empty file from `AGENTS.override.md`, `AGENTS.md`, then configured fallback filenames.
4. Concatenate selected files from root to current directory.
5. Later files are closer to the working directory and override earlier guidance.

Default byte limit:

- `project_doc_max_bytes` defaults to 32 KiB.
