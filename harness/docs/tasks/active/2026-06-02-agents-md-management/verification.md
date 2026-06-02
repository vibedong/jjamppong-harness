# Verification

Status: implementation verification completed

Scope:

- `plugins/agents-md-management/` was implemented as a local Codex plugin.
- The plugin includes three skills, two scripts, and eleven unit tests.
- README and AGENTS.md mention the plugin as optional maintenance tooling.
- No commit, push, PR, merge, release, marketplace install, or shutdown command was run.
- Later install pass: the plugin was installed into the personal Codex marketplace after the user asked to follow the install flow.
- Follow-up pass: global/repo scoring scopes, CODEX_HOME detection, stricter destructive-command guard detection, and read-only subagent guidance were added.

Commands run:

- `python --version`
- `git status --short --branch`
- Source refresh by browsing the OpenAI Codex AGENTS.md, plugin, and skills docs plus Anthropic Claude MD Management sources.
- `python -m unittest discover -s plugins/agents-md-management/tests -p test_discover_agents_chain.py` before implementation, expected RED.
- `python -m unittest discover -s plugins/agents-md-management/tests -p test_score_agents_md.py` before implementation, expected RED.
- `python -m unittest discover -s plugins/agents-md-management/tests -p test_*.py`
- `python -m unittest discover -s plugins\agents-md-management\tests -p test_score_agents_md.py`
- `python -m unittest discover -s plugins\agents-md-management\tests -p test_*.py`
- `python $pluginValidator plugins/agents-md-management`
- `python $skillValidator plugins/agents-md-management/skills/agents-md-chain-audit`
- `python $skillValidator plugins/agents-md-management/skills/agents-md-improver`
- `python $skillValidator plugins/agents-md-management/skills/revise-agents-md`
- Clean scenario forward test for nested `AGENTS.override.md` and empty `AGENTS.md`.
- Risky scenario forward test for `shutdown /s` and `git reset --hard` scoring flags.
- Current repository chain audit smoke test.
- Current repository `AGENTS.md` scoring smoke test.
- `rg -n "F:/mptech|F:\\mptech" plugins/agents-md-management`
- `rg -n "shutdown /s|Stop-Computer|Restart-Computer" plugins/agents-md-management/skills README.md AGENTS.md`
- `git diff --check`
- `python create_basic_plugin.py agents-md-management --with-skills --with-scripts --with-marketplace`
- Copy repository plugin source to `~/plugins/agents-md-management`
- `python validate_plugin.py ~/plugins/agents-md-management`
- `python read_marketplace_name.py`
- `codex plugin add agents-md-management@personal`
- `codex plugin list`
- `python validate_plugin.py ~/.codex/plugins/cache/personal/agents-md-management/0.1.0`
- `python validate_plugin.py ~/.codex/plugins/cache/personal/agents-md-management/0.1.0+codex.20260602022426`
- `codex plugin list | Select-String -Pattern agents-md-management`

Results:

- Python version: 3.14.5.
- Unit tests: initial pass `Ran 6 tests ... OK`; follow-up pass `Ran 11 tests ... OK`.
- Plugin validation: passed.
- Skill validation: all three skills valid.
- Forward clean scenario: passed after correcting the test setup to create a true empty file.
- Forward risky scenario: passed.
- Current repo smoke test: chain audit found global `AGENTS.md` and repository `AGENTS.md`; scoring returned grade A for repository `AGENTS.md`.
- Hardcoded project path scan: no `F:/mptech` path in the plugin.
- Shutdown guidance scan: no executable shutdown guidance in skills, README, or AGENTS.md.
- `git diff --check`: passed.
- Personal marketplace entry: present in `~/.agents/plugins/marketplace.json`.
- Codex install command: added `agents-md-management` from marketplace `personal`.
- Codex plugin list: `agents-md-management@personal` is `installed, enabled`.
- Installed cache root: `~/.codex/plugins/cache/personal/agents-md-management/0.1.0+codex.20260602022426`.
- Installed cache validation: passed.
- Global `~/.codex/AGENTS.md` scoring smoke test: `scope=global`, score 85, grade B.
- Repository `AGENTS.md` scoring smoke test: `scope=repo`, score 93, grade A.
- Subagent reviews: three read-only reviewers ran; accepted fixes for plugin-root script path wording, CODEX_HOME auto-scope detection, and destructive-command guard strictness. No issue was found in approval-gate/subagent-doc wording after the follow-up edits.

Residual risk:

- Real-world skill behavior should still be forward-tested in a fresh Codex thread after install, because current threads usually do not reload newly installed skills.
- `ce-compound` was not available as a command or local skill in this environment, so Compound Engineering learning was not captured.
