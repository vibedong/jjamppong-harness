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
