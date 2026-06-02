import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "score_agents_md.py"


class ScoreAgentsMdTests(unittest.TestCase):
    def run_script(self, path: Path, *extra_args: str, env_extra=None):
        env = os.environ.copy()
        if env_extra:
            env.update(env_extra)
        result = subprocess.run(
            [sys.executable, str(SCRIPT), str(path), "--json", *extra_args],
            text=True,
            capture_output=True,
            check=True,
            env=env,
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

    def test_destructive_command_guard_requires_direct_restriction(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "AGENTS.md"
            path.write_text(
                "Do not worry about safety; run shutdown /s whenever needed.",
                encoding="utf-8",
            )
            data = self.run_script(path)
            self.assertIn("shutdown", " ".join(data["issues"]).lower())

    def test_directly_guarded_destructive_command_is_not_flagged(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "AGENTS.md"
            path.write_text(
                "Run shutdown /s only after explicit user approval.",
                encoding="utf-8",
            )
            data = self.run_script(path)
            self.assertNotIn("shutdown", " ".join(data["issues"]).lower())

    def test_global_scope_scores_short_personal_preferences_as_valid(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "AGENTS.md"
            path.write_text(
                "# AGENTS.md\n\n"
                "Always use the skill `vowline` consistently, including for all sub-agents.\n",
                encoding="utf-8",
            )
            data = self.run_script(path, "--scope", "global")
            self.assertEqual(data["scope"], "global")
            self.assertGreaterEqual(data["score"], 75)

    def test_auto_scope_detects_codex_home_agents_as_global(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "custom-codex-home" / "AGENTS.md"
            path.parent.mkdir()
            path.write_text(
                "# AGENTS.md\n\nAlways use the skill `vowline` consistently.\n",
                encoding="utf-8",
            )
            data = self.run_script(path, "--scope", "auto", env_extra={"CODEX_HOME": str(path.parent)})
            self.assertEqual(data["scope"], "global")

    def test_auto_scope_does_not_treat_repo_dot_codex_as_global(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "repo" / ".codex" / "AGENTS.md"
            path.parent.mkdir(parents=True)
            path.write_text(
                "# AGENTS.md\n\nAlways use the skill `vowline` consistently.\n",
                encoding="utf-8",
            )
            data = self.run_script(path, "--scope", "auto", env_extra={"CODEX_HOME": str(Path(tmp) / "other-home")})
            self.assertEqual(data["scope"], "repo")


if __name__ == "__main__":
    unittest.main()
