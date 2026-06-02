# Agents MD Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` if independent task workers are available, or `superpowers:executing-plans` if execution must stay in one session. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Codex-native `agents-md-management` plugin that audits, improves, and safely revises `AGENTS.md` instruction chains.

**Architecture:** Package the work as a Codex plugin under `plugins/agents-md-management/` with three skills and deterministic Python scripts. Keep Claude MD Management's useful loop, but adapt the model to Codex's global/project instruction chain, override semantics, fallback filenames, and byte budget.

**Tech Stack:** Codex plugin manifest, Codex skills, Python standard library scripts, Markdown reference files, PowerShell verification commands, Git.

---

## Current Evidence

- Repository: current checkout of `vibedong/jjamppong-harness`
- Branch for this plan: `task/agents-md-management-plan`
- Plan path: `harness/docs/tasks/active/2026-06-02-agents-md-management/writing-plan.md`
- User intent: replace a Claude-oriented `CLAUDE.md` maintenance idea with a Codex-oriented `AGENTS.md` management plugin.
- Required behavior from the user: do not hardcode one-off local project paths; write reusable logic.
- Safety rule from the user: do not shut down the computer unless the user explicitly asks in the current moment.
- Commit/push rule: do not commit, push, create a PR, merge, or release without explicit approval in the current chat.

## Source Model

Use these sources during implementation and record their retrieval date in the proposal:

- OpenAI Codex AGENTS.md guide: `https://developers.openai.com/codex/guides/agents-md`
- OpenAI Codex plugin build guide: `https://developers.openai.com/codex/plugins/build`
- OpenAI Codex skills guide: `https://developers.openai.com/codex/skills`
- Anthropic Claude MD Management plugin: `https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management`
- Claude MD improver skill: `https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/claude-md-management/skills/claude-md-improver/SKILL.md`
- Claude revise command: `https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/claude-md-management/commands/revise-claude-md.md`

Codex-specific facts to preserve:

- Codex reads global instructions from `CODEX_HOME` or `~/.codex`.
- At global scope, `AGENTS.override.md` wins over `AGENTS.md`; Codex uses only the first non-empty file at that level.
- At project scope, Codex walks from the project root to the current working directory.
- In each project directory, Codex includes at most one instruction file, checked in this order: `AGENTS.override.md`, `AGENTS.md`, then configured fallback filenames.
- Codex concatenates files from root to current directory; closer files appear later and override earlier guidance.
- Codex skips empty files and stops adding instruction files when combined bytes reach `project_doc_max_bytes`, 32 KiB by default.
- Codex skills are directories with `SKILL.md`; optional `scripts/`, `references/`, `assets/`, and `agents/openai.yaml` can support progressive disclosure.
- Codex plugins require `.codex-plugin/plugin.json`; plugin paths in the manifest must be relative to the plugin root.

## Execution Variables

Run implementation commands from the repository root and define these variables first:

```powershell
$repo = (Resolve-Path '.').Path
$pluginRoot = Join-Path $repo 'plugins/agents-md-management'
$pluginCreatorRoot = Join-Path $env:USERPROFILE '.codex/skills/.system/plugin-creator'
$skillCreatorRoot = Join-Path $env:USERPROFILE '.codex/skills/.system/skill-creator'
$pluginCreator = Join-Path $pluginCreatorRoot 'scripts/create_basic_plugin.py'
$pluginValidator = Join-Path $pluginCreatorRoot 'scripts/validate_plugin.py'
$skillValidator = Join-Path $skillCreatorRoot 'scripts/quick_validate.py'
```

## Product Shape

The plugin has three skills:

1. `agents-md-chain-audit`
   - Finds the active Codex instruction chain for a target working directory.
   - Reports loaded files, skipped files, override relationships, fallback usage, empty files, and byte budget risk.
   - Does not edit files.

2. `agents-md-improver`
   - Scores instruction files and proposes targeted diffs.
   - Requires user approval before editing.
   - Scores Codex-specific categories instead of Claude-specific categories.

3. `revise-agents-md`
   - Converts session learnings into concise proposed additions.
   - Routes each addition to the correct owner surface: global user preferences, repo `AGENTS.md`, nested `AGENTS.md`, or private `AGENTS.override.md`.
   - Requires user approval before editing.

## Quality Rubric

Each scored file receives 100 points:

- Instruction discovery safety: 15
- Commands and verification: 15
- Architecture and workflow clarity: 15
- Role and ownership separation: 10
- Override and conflict safety: 15
- Context budget and concision: 10
- Currentness: 10
- Human readability: 10

Grade mapping:

- A: 90-100
- B: 75-89
- C: 60-74
- D: 40-59
- F: 0-39

## File Map

- Create: `proposals/2026-06-02-agents-md-management.md`
  - Approves adding a plugin directory and, if accepted, future live harness references.

- Create: `plugins/agents-md-management/.codex-plugin/plugin.json`
  - Codex plugin manifest.

- Create: `plugins/agents-md-management/skills/agents-md-chain-audit/SKILL.md`
  - Audit workflow for active instruction chain discovery.

- Create: `plugins/agents-md-management/skills/agents-md-chain-audit/references/codex-instruction-chain.md`
  - Compact reference for Codex discovery rules.

- Create: `plugins/agents-md-management/skills/agents-md-improver/SKILL.md`
  - Quality report and approved edit workflow.

- Create: `plugins/agents-md-management/skills/agents-md-improver/references/quality-criteria.md`
  - Scoring rubric and report format.

- Create: `plugins/agents-md-management/skills/revise-agents-md/SKILL.md`
  - Session learning extraction and approved update workflow.

- Create: `plugins/agents-md-management/skills/revise-agents-md/references/routing-rules.md`
  - Rules for deciding where each learning belongs.

- Create: `plugins/agents-md-management/scripts/discover_agents_chain.py`
  - Deterministic instruction-chain discovery script.

- Create: `plugins/agents-md-management/scripts/score_agents_md.py`
  - Deterministic scoring helper.

- Create: `plugins/agents-md-management/tests/test_discover_agents_chain.py`
  - Standard-library unit tests for chain discovery.

- Create: `plugins/agents-md-management/tests/test_score_agents_md.py`
  - Standard-library unit tests for scoring.

- Create: `harness/docs/tasks/active/2026-06-02-agents-md-management/reviews.md`
  - Records mandatory plan review choice and findings.

- Create: `harness/docs/tasks/active/2026-06-02-agents-md-management/verification.md`
  - Records final verification commands and outcomes.

- Modify only after review approval: `README.md`
  - Adds a short optional section pointing to the plugin.

- Modify only after review approval: `AGENTS.md`
  - Adds an optional maintenance note only if the user wants this plugin to become part of the harness defaults.

## Task 1: Proposal And Source Refresh

**Files:**

- Create: `proposals/2026-06-02-agents-md-management.md`

- [ ] **Step 1: Refresh source documents**

Run:

```powershell
python --version
git status --short --branch
```

Expected:

```text
Python prints a version.
Git status shows the current branch and any local planning files.
```

Then browse the six URLs listed in `Source Model` and note the current date in the proposal.

- [ ] **Step 2: Write the proposal**

Create `proposals/2026-06-02-agents-md-management.md` with this structure:

```markdown
# Agents MD Management Proposal

## Decision

Create a Codex-native `agents-md-management` plugin under `plugins/agents-md-management/`.

## Why

Claude MD Management is useful, but it assumes Claude Code's `CLAUDE.md` model. Codex uses `AGENTS.md`, `AGENTS.override.md`, `CODEX_HOME`, project-root-to-cwd discovery, fallback filenames, and a combined byte budget. A direct rename would miss the main failure modes.

## Scope

- Add a local Codex plugin package.
- Add three skills: `agents-md-chain-audit`, `agents-md-improver`, and `revise-agents-md`.
- Add deterministic scripts for chain discovery and scoring.
- Add unit tests for the scripts.
- Add README notes only after review approval.

## Non-Goals

- Do not edit official OpenAI, Anthropic, Superpowers, Matt Pocock, gstack, or Compound plugin files.
- Do not update a personal marketplace file unless the user separately asks to install the plugin locally.
- Do not hardcode the user's example target path or any other one-off project path.
- Do not create product code under `modules/`.
- Do not run shutdown commands.

## Source Snapshot

- Retrieved on: 2026-06-02
- OpenAI Codex AGENTS.md guide: https://developers.openai.com/codex/guides/agents-md
- OpenAI Codex plugin build guide: https://developers.openai.com/codex/plugins/build
- OpenAI Codex skills guide: https://developers.openai.com/codex/skills
- Anthropic Claude MD Management plugin: https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management
```

- [ ] **Step 3: Ask for proposal approval**

Ask:

```text
이 proposal 기준으로 plugin 구현 계획을 실행해도 될까요?
```

Stop until the user approves.

## Task 2: Scaffold The Plugin

**Files:**

- Create: `plugins/agents-md-management/.codex-plugin/plugin.json`
- Create directory: `plugins/agents-md-management/skills/`
- Create directory: `plugins/agents-md-management/scripts/`
- Create directory: `plugins/agents-md-management/tests/`

- [ ] **Step 1: Scaffold with plugin-creator**

Run:

```powershell
$repo = (Resolve-Path '.').Path
$pluginCreator = Join-Path $env:USERPROFILE '.codex/skills/.system/plugin-creator/scripts/create_basic_plugin.py'
python $pluginCreator agents-md-management --path (Join-Path $repo 'plugins') --with-skills --with-scripts
```

Expected:

```text
plugins/agents-md-management/.codex-plugin/plugin.json exists.
plugins/agents-md-management/skills exists.
plugins/agents-md-management/scripts exists.
```

- [ ] **Step 2: Replace the manifest with Codex-specific metadata**

Edit `plugins/agents-md-management/.codex-plugin/plugin.json` to:

```json
{
  "name": "agents-md-management",
  "version": "0.1.0",
  "description": "Audit, improve, and revise Codex AGENTS.md instruction chains.",
  "author": {
    "name": "vibedong"
  },
  "repository": "https://github.com/vibedong/jjamppong-harness",
  "license": "UNLICENSED",
  "keywords": ["codex", "agents-md", "instructions", "skills"],
  "skills": "./skills/",
  "interface": {
    "displayName": "AGENTS.md Management",
    "shortDescription": "Audit and improve Codex instruction files",
    "longDescription": "Codex-native AGENTS.md management skills for instruction-chain audit, quality scoring, and approved session-learning updates.",
    "developerName": "vibedong",
    "category": "Productivity",
    "capabilities": ["Read", "Write"],
    "defaultPrompt": [
      "Use AGENTS.md Management to audit this repo's Codex instruction chain.",
      "Use AGENTS.md Management to propose concise updates from this session."
    ]
  }
}
```

- [ ] **Step 3: Validate plugin structure**

Run:

```powershell
$repo = (Resolve-Path '.').Path
$pluginValidator = Join-Path $env:USERPROFILE '.codex/skills/.system/plugin-creator/scripts/validate_plugin.py'
python $pluginValidator (Join-Path $repo 'plugins/agents-md-management')
```

Expected:

```text
Validation succeeds with no manifest errors.
```

## Task 3: Implement Chain Discovery Script

**Files:**

- Create: `plugins/agents-md-management/scripts/discover_agents_chain.py`
- Create: `plugins/agents-md-management/tests/test_discover_agents_chain.py`

- [ ] **Step 1: Write failing tests**

Create `plugins/agents-md-management/tests/test_discover_agents_chain.py` with tests for:

```python
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "discover_agents_chain.py"

class DiscoverAgentsChainTests(unittest.TestCase):
    def run_script(self, cwd: Path, codex_home: Path):
        result = subprocess.run(
            [sys.executable, str(SCRIPT), "--cwd", str(cwd), "--codex-home", str(codex_home), "--json"],
            text=True,
            capture_output=True,
            check=True,
        )
        return json.loads(result.stdout)

    def test_global_override_wins_over_global_agents(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            codex_home = root / "codex-home"
            work = root / "repo"
            codex_home.mkdir()
            work.mkdir()
            (codex_home / "AGENTS.md").write_text("base", encoding="utf-8")
            (codex_home / "AGENTS.override.md").write_text("override", encoding="utf-8")
            data = self.run_script(work, codex_home)
            self.assertEqual(data["global"]["selected_name"], "AGENTS.override.md")
            self.assertEqual(data["global"]["ignored"][0]["name"], "AGENTS.md")

    def test_project_override_ignores_same_directory_agents(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            codex_home = root / "codex-home"
            repo = root / "repo"
            child = repo / "service"
            codex_home.mkdir()
            child.mkdir(parents=True)
            (repo / ".git").mkdir()
            (repo / "AGENTS.md").write_text("root", encoding="utf-8")
            (child / "AGENTS.md").write_text("child-base", encoding="utf-8")
            (child / "AGENTS.override.md").write_text("child-override", encoding="utf-8")
            data = self.run_script(child, codex_home)
            selected = [item["name"] for item in data["project_chain"]]
            self.assertEqual(selected, ["AGENTS.md", "AGENTS.override.md"])

    def test_empty_files_are_reported_as_skipped(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            codex_home = root / "codex-home"
            repo = root / "repo"
            codex_home.mkdir()
            repo.mkdir()
            (repo / ".git").mkdir()
            (repo / "AGENTS.md").write_text("", encoding="utf-8")
            data = self.run_script(repo, codex_home)
            self.assertEqual(data["project_chain"], [])
            self.assertEqual(data["skipped_empty"][0]["name"], "AGENTS.md")

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run tests and confirm failure**

Run:

```powershell
python -m unittest discover -s 'plugins/agents-md-management/tests' -p 'test_*.py'
```

Expected:

```text
Tests fail because discover_agents_chain.py does not exist.
```

- [ ] **Step 3: Implement the script**

Create `plugins/agents-md-management/scripts/discover_agents_chain.py` with the complete content from Appendix A.

- [ ] **Step 4: Run tests and confirm pass**

Run:

```powershell
python -m unittest discover -s 'plugins/agents-md-management/tests' -p 'test_*.py'
```

Expected:

```text
Ran 3 tests
OK
```

## Task 4: Implement Scoring Script

**Files:**

- Create: `plugins/agents-md-management/scripts/score_agents_md.py`
- Create: `plugins/agents-md-management/tests/test_score_agents_md.py`

- [ ] **Step 1: Write failing tests**

Create `plugins/agents-md-management/tests/test_score_agents_md.py` with the complete content from Appendix B.

- [ ] **Step 2: Implement the scorer**

Create `plugins/agents-md-management/scripts/score_agents_md.py` with the complete content from Appendix C.

- [ ] **Step 3: Run tests**

Run:

```powershell
python -m unittest discover -s 'plugins/agents-md-management/tests' -p 'test_*.py'
```

Expected:

```text
All script tests pass.
```

## Task 5: Write The Three Skills

**Files:**

- Create: `plugins/agents-md-management/skills/agents-md-chain-audit/SKILL.md`
- Create: `plugins/agents-md-management/skills/agents-md-chain-audit/references/codex-instruction-chain.md`
- Create: `plugins/agents-md-management/skills/agents-md-improver/SKILL.md`
- Create: `plugins/agents-md-management/skills/agents-md-improver/references/quality-criteria.md`
- Create: `plugins/agents-md-management/skills/revise-agents-md/SKILL.md`
- Create: `plugins/agents-md-management/skills/revise-agents-md/references/routing-rules.md`

- [ ] **Step 1: Write `agents-md-chain-audit`**

Create `plugins/agents-md-management/skills/agents-md-chain-audit/SKILL.md` with the complete content from Appendix D.

Create `plugins/agents-md-management/skills/agents-md-chain-audit/references/codex-instruction-chain.md` with the complete content from Appendix G.

- [ ] **Step 2: Write `agents-md-improver`**

Create `plugins/agents-md-management/skills/agents-md-improver/SKILL.md` with the complete content from Appendix E.

Create `plugins/agents-md-management/skills/agents-md-improver/references/quality-criteria.md` with the complete content from Appendix H.

- [ ] **Step 3: Write `revise-agents-md`**

Create `plugins/agents-md-management/skills/revise-agents-md/SKILL.md` with the complete content from Appendix F.

Create `plugins/agents-md-management/skills/revise-agents-md/references/routing-rules.md` with the complete content from Appendix I.

- [ ] **Step 4: Validate skills**

Run:

```powershell
$repo = (Resolve-Path '.').Path
$skillValidator = Join-Path $env:USERPROFILE '.codex/skills/.system/skill-creator/scripts/quick_validate.py'
python $skillValidator (Join-Path $repo 'plugins/agents-md-management/skills/agents-md-chain-audit')
python $skillValidator (Join-Path $repo 'plugins/agents-md-management/skills/agents-md-improver')
python $skillValidator (Join-Path $repo 'plugins/agents-md-management/skills/revise-agents-md')
```

Expected:

```text
Each skill validates successfully.
```

## Task 6: Add Documentation Hooks

**Files:**

- Modify: `README.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Add a README section**

Add a short section named `AGENTS.md Management Plugin` that explains:

- It audits Codex instruction chains.
- It proposes changes before writing.
- It is not automatically installed into personal Codex unless the user chooses that.
- It must not hardcode a local path.

- [ ] **Step 2: Add an AGENTS.md maintenance note**

Add a short note that says:

- Use `agents-md-chain-audit` when instruction discovery looks wrong.
- Use `agents-md-improver` before broad AGENTS.md rewrites.
- Use `revise-agents-md` only for reusable learnings.

Do not make the plugin mandatory for every task unless the user separately approves that policy.

## Task 7: Verification

**Files:**

- Create: `harness/docs/tasks/active/2026-06-02-agents-md-management/verification.md`

- [ ] **Step 1: Run unit tests**

Run:

```powershell
python -m unittest discover -s 'plugins/agents-md-management/tests' -p 'test_*.py'
```

Expected:

```text
OK
```

- [ ] **Step 2: Validate plugin**

Run:

```powershell
$repo = (Resolve-Path '.').Path
$pluginValidator = Join-Path $env:USERPROFILE '.codex/skills/.system/plugin-creator/scripts/validate_plugin.py'
python $pluginValidator (Join-Path $repo 'plugins/agents-md-management')
```

Expected:

```text
Validation succeeds.
```

- [ ] **Step 3: Validate all skills**

Run the three `quick_validate.py` commands from Task 5.

Expected:

```text
All three skills validate successfully.
```

- [ ] **Step 4: Test against this repository**

Run:

```powershell
$repo = (Resolve-Path '.').Path
python 'plugins/agents-md-management/scripts/discover_agents_chain.py' --cwd $repo --codex-home (Join-Path $env:USERPROFILE '.codex') --json
python 'plugins/agents-md-management/scripts/score_agents_md.py' 'AGENTS.md' --json
```

Expected:

```text
The chain script reports the repository AGENTS.md.
The scoring script returns JSON with score, grade, criteria, issues, and recommended_additions.
```

- [ ] **Step 5: Run diff checks**

Run:

```powershell
git diff --check
$pattern = "F:/mptech|F:\\mptech|shutdown /s|Stop-Computer|Restart-Computer"
rg -n $pattern plugins/agents-md-management README.md AGENTS.md
if ($LASTEXITCODE -eq 1) {
  "OK: no hardcoded example paths or shutdown commands"
  exit 0
}
if ($LASTEXITCODE -eq 0) {
  throw "Forbidden hardcoded path or shutdown command found"
}
exit $LASTEXITCODE
```

Expected:

```text
git diff --check passes.
rg returns no hardcoded project path or shutdown command in plugin/docs changes.
```

- [ ] **Step 6: Record verification**

Write `harness/docs/tasks/active/2026-06-02-agents-md-management/verification.md` with:

```markdown
# Verification

Status: completed

Commands:

- `python -m unittest discover -s plugins/agents-md-management/tests -p test_*.py`
- `python $pluginValidator $pluginRoot`
- three `quick_validate.py` skill checks
- repository chain audit smoke test
- repository scoring smoke test
- `git diff --check`
- hardcoded-path and shutdown-command scan

Result:

- Record the actual command result lines after execution.

Residual risk:

- Record the unresolved risks found during execution, or write `none found` if verification finds no residual risk.
```

## Task 8: Forward Test

**Files:**

- Modify: `harness/docs/tasks/active/2026-06-02-agents-md-management/verification.md`

- [ ] **Step 1: Run a clean scenario**

Run:

```powershell
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('agents-chain-scenario-' + [guid]::NewGuid().ToString('N'))
$codexHome = Join-Path $temp 'codex-home'
$repo = Join-Path $temp 'repo'
$nested = Join-Path $repo 'app'
New-Item -ItemType Directory -Force -Path $codexHome, (Join-Path $repo '.git'), $nested | Out-Null
Set-Content -LiteralPath (Join-Path $codexHome 'AGENTS.md') -Value 'global base' -Encoding UTF8
Set-Content -LiteralPath (Join-Path $repo 'AGENTS.md') -Value 'repo base' -Encoding UTF8
New-Item -ItemType File -Force -Path (Join-Path $nested 'AGENTS.md') | Out-Null
Set-Content -LiteralPath (Join-Path $nested 'AGENTS.override.md') -Value 'nested override' -Encoding UTF8
$json = python 'plugins/agents-md-management/scripts/discover_agents_chain.py' --cwd $nested --codex-home $codexHome --json | ConvertFrom-Json
$chain = @($json.project_chain)
$empty = @($json.skipped_empty)
if ($chain[-1].name -ne 'AGENTS.override.md') { throw 'Nested override was not selected' }
if (($empty | Where-Object { $_.name -eq 'AGENTS.md' }).Count -lt 1) { throw 'Empty AGENTS.md was not reported' }
Remove-Item -LiteralPath $temp -Recurse -Force
'OK: clean scenario passed'
```

Expected: `OK: clean scenario passed`

- [ ] **Step 2: Run a risky-content scenario**

Run:

```powershell
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('agents-score-scenario-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $temp | Out-Null
$path = Join-Path $temp 'AGENTS.md'
Set-Content -LiteralPath $path -Value 'Agents may run shutdown /s and git reset --hard.' -Encoding UTF8
$json = python 'plugins/agents-md-management/scripts/score_agents_md.py' $path --json | ConvertFrom-Json
$issues = (@($json)[0].issues -join ' ').ToLowerInvariant()
if (-not $issues.Contains('shutdown')) { throw 'shutdown was not flagged' }
if (-not $issues.Contains('git reset --hard')) { throw 'git reset --hard was not flagged' }
Remove-Item -LiteralPath $temp -Recurse -Force
'OK: risky scenario passed'
```

Expected: `OK: risky scenario passed`

- [ ] **Step 3: Record results**

Append scenario outcomes to `verification.md`.

## Task 9: Mandatory Plan Review Recording

**Files:**

- Create: `harness/docs/tasks/active/2026-06-02-agents-md-management/reviews.md`

- [ ] **Step 1: Ask the mandatory review question before implementation**

Ask:

```text
구현 전에 계획 리뷰를 실행할까요?

추천: 이 작업은 Codex plugin, skill behavior, harness documentation을 바꾸므로 CEO/제품전략 리뷰, 엔지니어링 리뷰, Plan Compliance 리뷰를 같이 실행하는 게 좋습니다.

A. CEO + Eng + Plan Compliance
B. CEO + Eng
C. Eng only
D. 이번에는 생략
```

- [ ] **Step 2: Record the choice**

Create `reviews.md` with this initial state before the user answers:

```markdown
# Reviews

Status: review choice not selected

Selected option: not selected by user

Reviewers:

- none yet

Findings:

- none yet

Decisions:

- Implementation is blocked until the user selects a review option.
```

After the user chooses, replace the status, selected option, reviewers, findings, and decisions with the actual review result.

## Appendix A: `discover_agents_chain.py`

```python
import argparse
import json
from pathlib import Path

PRIMARY_NAMES = ["AGENTS.override.md", "AGENTS.md"]

def file_info(path: Path):
    data = path.read_bytes()
    return {"path": str(path), "name": path.name, "bytes": len(data)}

def is_non_empty(path: Path) -> bool:
    return path.exists() and path.is_file() and len(path.read_bytes()) > 0

def find_project_root(cwd: Path) -> Path:
    current = cwd.resolve()
    for candidate in [current, *current.parents]:
        if (candidate / ".git").exists():
            return candidate
    return current

def path_chain(root: Path, cwd: Path):
    root = root.resolve()
    cwd = cwd.resolve()
    parts = [root]
    relative = cwd.relative_to(root) if cwd != root else Path()
    current = root
    for part in relative.parts:
        current = current / part
        parts.append(current)
    return parts

def select_first(directory: Path, names, skipped_empty):
    existing = [directory / name for name in names if (directory / name).exists()]
    selected = None
    ignored = []
    for path in existing:
        if is_non_empty(path) and selected is None:
            selected = file_info(path)
        elif path.exists() and path.is_file() and len(path.read_bytes()) == 0:
            skipped_empty.append(file_info(path))
        elif selected is not None:
            ignored.append(file_info(path))
    return selected, ignored

def discover(cwd: Path, codex_home: Path, fallback_names, max_bytes: int):
    skipped_empty = []
    selected_global, global_ignored = select_first(codex_home, PRIMARY_NAMES, skipped_empty)
    project_root = find_project_root(cwd)
    project_chain = []
    project_ignored = []
    for directory in path_chain(project_root, cwd):
        selected, ignored = select_first(directory, [*PRIMARY_NAMES, *fallback_names], skipped_empty)
        if selected:
            selected["directory"] = str(directory)
            project_chain.append(selected)
        project_ignored.extend(ignored)
    selected_files = ([selected_global] if selected_global else []) + project_chain
    total_bytes = sum(item["bytes"] for item in selected_files)
    return {
        "cwd": str(cwd.resolve()),
        "codex_home": str(codex_home.resolve()),
        "project_root": str(project_root),
        "global": {
            "selected_name": selected_global["name"] if selected_global else None,
            "selected": selected_global,
            "ignored": global_ignored,
        },
        "project_chain": project_chain,
        "ignored": project_ignored,
        "skipped_empty": skipped_empty,
        "total_selected_bytes": total_bytes,
        "max_bytes": max_bytes,
        "byte_budget_exceeded": total_bytes > max_bytes,
    }

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cwd", default=".")
    parser.add_argument("--codex-home", default=str(Path.home() / ".codex"))
    parser.add_argument("--fallback", action="append", default=[])
    parser.add_argument("--max-bytes", type=int, default=32768)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    data = discover(Path(args.cwd), Path(args.codex_home), args.fallback, args.max_bytes)
    if args.json:
        print(json.dumps(data, ensure_ascii=False, indent=2))
    else:
        print(f"Project root: {data['project_root']}")
        for item in data["project_chain"]:
            print(f"Loaded: {item['path']} ({item['bytes']} bytes)")

if __name__ == "__main__":
    main()
```

## Appendix B: `test_score_agents_md.py`

```python
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "score_agents_md.py"

class ScoreAgentsMdTests(unittest.TestCase):
    def run_script(self, path: Path):
        result = subprocess.run(
            [sys.executable, str(SCRIPT), str(path), "--json"],
            text=True,
            capture_output=True,
            check=True,
        )
        return json.loads(result.stdout)[0]

    def test_specific_file_scores_higher_than_vague_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            strong = root / "strong.md"
            vague = root / "vague.md"
            strong.write_text(
                "# AGENTS.md\n\nRun `python -m unittest` before completion. "
                "Architecture lives under modules/. Use AGENTS.override.md only for local overrides. "
                "Do not commit or push without approval. Verify with `git diff --check`.",
                encoding="utf-8",
            )
            vague.write_text("Be helpful and write good code.", encoding="utf-8")
            self.assertGreater(self.run_script(strong)["score"], self.run_script(vague)["score"])

    def test_large_file_gets_budget_warning(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "AGENTS.md"
            path.write_text("x" * 33000, encoding="utf-8")
            data = self.run_script(path)
            self.assertIn("context budget", " ".join(data["issues"]).lower())

    def test_unguarded_destructive_commands_are_flagged(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "AGENTS.md"
            path.write_text("Agents may run shutdown /s and git reset --hard.", encoding="utf-8")
            data = self.run_script(path)
            joined = " ".join(data["issues"]).lower()
            self.assertIn("shutdown", joined)
            self.assertIn("git reset --hard", joined)

if __name__ == "__main__":
    unittest.main()
```

## Appendix C: `score_agents_md.py`

```python
import argparse
import json
from pathlib import Path

CRITERIA = [
    ("instruction_discovery_safety", 15, ["AGENTS.override.md", "AGENTS.md", "CODEX_HOME", "fallback", "project_doc_max_bytes"]),
    ("commands_and_verification", 15, ["run", "test", "verify", "lint", "git diff --check", "pytest", "unittest", "npm"]),
    ("architecture_and_workflow", 15, ["architecture", "workflow", "modules", "directory", "folder", "branch"]),
    ("ownership_separation", 10, ["approval", "do not", "only", "owner", "scope", "origin"]),
    ("override_conflict_safety", 15, ["override", "precedence", "fallback", "global", "project root", "current working directory"]),
    ("context_budget_concision", 10, ["concise", "short", "byte", "32 KiB", "project_doc_max_bytes"]),
    ("currentness", 10, ["current", "active", "today", "updated", "verified"]),
    ("human_readability", 10, ["#", "##", "-", "`"]),
]

DANGEROUS = ["shutdown /s", "Stop-Computer", "Restart-Computer", "git reset --hard", "git push --force"]
FORBIDDEN_WORDS = ["do not", "never", "forbidden", "without explicit", "unless the user explicitly"]

def grade(score: int) -> str:
    if score >= 90:
        return "A"
    if score >= 75:
        return "B"
    if score >= 60:
        return "C"
    if score >= 40:
        return "D"
    return "F"

def score_text(text: str, byte_count: int, max_bytes: int):
    lower = text.lower()
    criteria = {}
    issues = []
    recommendations = []
    score = 0
    for name, weight, signals in CRITERIA:
        hits = sum(1 for signal in signals if signal.lower() in lower)
        points = min(weight, round(weight * hits / max(2, len(signals) // 2)))
        criteria[name] = points
        score += points
        if points < weight // 2:
            issues.append(f"Low {name.replace('_', ' ')} coverage.")
            recommendations.append(f"Add concise {name.replace('_', ' ')} guidance.")
    if byte_count > max_bytes:
        issues.append(f"Instruction file exceeds context budget: {byte_count} bytes > {max_bytes}.")
        recommendations.append("Split or shorten instructions so Codex can load the important files.")
        score = min(score, 89)
    for command in DANGEROUS:
        for line in text.splitlines():
            line_lower = line.lower()
            if command.lower() in line_lower:
                guarded = any(word in line_lower for word in FORBIDDEN_WORDS)
                if not guarded:
                    issues.append(f"Unguarded destructive command found: {command}.")
                    recommendations.append(f"Frame `{command}` as forbidden unless explicitly requested.")
                    score = min(score, 59)
    return {
        "score": max(0, min(100, score)),
        "grade": grade(max(0, min(100, score))),
        "criteria": criteria,
        "issues": issues,
        "recommended_additions": recommendations,
    }

def score_file(path: Path, max_bytes: int):
    data = path.read_bytes()
    text = data.decode("utf-8", errors="replace")
    result = score_text(text, len(data), max_bytes)
    result["path"] = str(path)
    return result

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--max-bytes", type=int, default=32768)
    args = parser.parse_args()
    results = [score_file(Path(path), args.max_bytes) for path in args.paths]
    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        for result in results:
            print(f"{result['path']}: {result['score']}/100 ({result['grade']})")

if __name__ == "__main__":
    main()
```

## Appendix D: `agents-md-chain-audit/SKILL.md`

````markdown
---
name: agents-md-chain-audit
description: Audit Codex AGENTS.md instruction discovery. Use when the user asks which AGENTS.md files Codex loads, why instructions are ignored, whether AGENTS.override.md is shadowing AGENTS.md, or how global/project/fallback instruction files interact.
---

# AGENTS.md Chain Audit

Run this skill before changing instruction files when discovery behavior is unclear.

## Workflow

1. Resolve the target working directory.
2. Run `scripts/discover_agents_chain.py` from this plugin.
3. Report selected global file, selected project chain, ignored same-directory files, empty skipped files, fallback names, and byte-budget status.
4. Do not edit files.

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
````

## Appendix E: `agents-md-improver/SKILL.md`

````markdown
---
name: agents-md-improver
description: Audit and improve Codex AGENTS.md instruction files. Use when the user asks to check, score, update, improve, or fix AGENTS.md or AGENTS.override.md files, especially for Codex instruction-chain quality, command accuracy, override safety, and context-budget issues.
---

# AGENTS.md Improver

Audit first, propose second, edit only after approval.

## Workflow

1. Use `agents-md-chain-audit` or run `scripts/discover_agents_chain.py`.
2. Run `scripts/score_agents_md.py` on selected instruction files.
3. Present a quality report before edits.
4. Propose targeted diffs only.
5. Ask for approval before editing.
6. Preserve owner boundaries: global preferences stay global, repository rules stay in repo files, local private rules stay in `AGENTS.override.md`.

## Quality Report

```markdown
## AGENTS.md Quality Report

### Summary
- Files scored:
- Average score:
- Files needing update:

### Findings
- File:
- Score:
- Issues:
- Recommended diff:
```
````

## Appendix F: `revise-agents-md/SKILL.md`

````markdown
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

## Output

```markdown
## Proposed AGENTS.md Updates

### Update: <path>
Why:

```diff
+ <concise reusable instruction>
```
```
````

## Appendix G: `codex-instruction-chain.md`

```markdown
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
```

## Appendix H: `quality-criteria.md`

```markdown
# AGENTS.md Quality Criteria

Score each instruction file out of 100:

- Instruction discovery safety: 15
- Commands and verification: 15
- Architecture and workflow clarity: 15
- Role and ownership separation: 10
- Override and conflict safety: 15
- Context budget and concision: 10
- Currentness: 10
- Human readability: 10

Grades:

- A: 90-100
- B: 75-89
- C: 60-74
- D: 40-59
- F: 0-39
```

## Appendix I: `routing-rules.md`

```markdown
# Routing Rules

Route session learnings by owner:

- Global user preference: `~/.codex/AGENTS.md` or `~/.codex/AGENTS.override.md`.
- Repository-wide shared rule: repository root `AGENTS.md`.
- Directory-specific project rule: nearest relevant nested `AGENTS.md`.
- Private local-only override: `AGENTS.override.md`.

Do not add:

- One-off task facts.
- Temporary local paths.
- Secrets or credentials.
- Hidden answers, tests, or private references.
- Instructions that contradict higher-priority system, developer, or project rules.
```

## Task 10: Commit And Push Gate

**Files:**

- No new files.

- [ ] **Step 1: Show commit scope**

Run:

```powershell
git status --short --branch
git diff --stat
```

Expected:

```text
The output shows only the proposal, plugin files, tests, review artifacts, verification artifacts, and approved README/AGENTS.md notes.
```

- [ ] **Step 2: Ask for explicit approval**

Ask:

```text
이 변경사항을 커밋하고 푸시할까요?
```

Do not run `git commit` or `git push` until the user approves in the current chat.

## Self-Review

- Spec coverage: The plan covers Claude MD Management analysis, Codex AGENTS.md discovery behavior, plugin packaging, skill creation, deterministic scripts, tests, documentation hooks, verification, and mandatory review.
- Placeholder scan: The plan avoids deferred-detail labels and records concrete paths, commands, and expected outcomes.
- Type/path consistency: All plugin files live under `plugins/agents-md-management/`; all task artifacts live under `harness/docs/tasks/active/2026-06-02-agents-md-management/`.
- Hardcoding guard: The implementation must accept paths through CLI arguments and must not encode a one-off local project path.
- Safety guard: The implementation must not execute shutdown, reset, force-push, or destructive commands.

## Execution Handoff

Plan complete and saved to `harness/docs/tasks/active/2026-06-02-agents-md-management/writing-plan.md`.

Recommended next step: run plan review before implementation.

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `plan-ceo-review` | Scope & strategy | 1 | revised | Keep first pass local and deterministic; avoid marketplace install, release scope, or automatic live-rule changes. |
| Eng Review | `plan-eng-review` | Architecture & tests | 1 | revised | Added exact script/test/skill appendices, validator-safe manifest fields, line-level safety scoring, and concrete forward tests. |
| Plan Compliance | `superpowers:requesting-code-review` | Harness and writing-plan compliance | 1 | revised | Added PRD/issue/brief artifacts, variable-based paths, commit/push gate, and review artifact updates. |

- **UNRESOLVED:** 0 accepted findings remain open in this plan revision.
- **VERDICT:** CEO + Eng + Plan Compliance reviews are recorded; the plan is ready for implementation after the user explicitly asks to execute it.
