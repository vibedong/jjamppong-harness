import argparse
import json
import os
import re
from pathlib import Path


REPO_CRITERIA = [
    ("instruction_discovery_safety", 15, ["AGENTS.override.md", "AGENTS.md", "CODEX_HOME", "fallback", "project_doc_max_bytes"]),
    ("commands_and_verification", 15, ["run", "test", "verify", "lint", "git diff --check", "pytest", "unittest", "npm"]),
    ("architecture_and_workflow", 15, ["architecture", "workflow", "modules", "directory", "folder", "branch"]),
    ("ownership_separation", 10, ["approval", "do not", "only", "owner", "scope", "origin"]),
    ("override_conflict_safety", 15, ["override", "precedence", "fallback", "global", "project root", "current working directory"]),
    ("context_budget_concision", 10, ["concise", "short", "byte", "32 KiB", "project_doc_max_bytes"]),
    ("currentness", 10, ["current", "active", "today", "updated", "verified"]),
    ("human_readability", 10, ["#", "##", "-", "`"]),
]

GLOBAL_CRITERIA = [
    ("personal_preference_clarity", 25, ["always", "use", "skill", "preference", "default", "consistently"]),
    ("cross_project_scope", 20, ["global", "all", "sub-agents", "subagents", "sessions", "projects"]),
    ("safety_or_skill_policy", 25, ["vowline", "skill", "approval", "do not", "never", "without explicit"]),
    ("human_readability", 15, ["#", "##", "-", "`"]),
]

DANGEROUS = ["shutdown /s", "Stop-Computer", "Restart-Computer", "git reset --hard", "git push --force"]
AGENTS_FILE_NAMES = {"agents.md", "agents.override.md"}


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


def criteria_points(text: str, criteria_spec):
    lower = text.lower()
    criteria = {}
    issues = []
    recommendations = []
    score = 0

    for name, weight, signals in criteria_spec:
        hits = sum(1 for signal in signals if signal.lower() in lower)
        points = min(weight, round(weight * hits / max(2, len(signals) // 2)))
        criteria[name] = points
        score += points
        if points < weight // 2:
            readable_name = name.replace("_", " ")
            issues.append(f"Low {readable_name} coverage.")
            recommendations.append(f"Add concise {readable_name} guidance.")

    return score, criteria, issues, recommendations


def resolved(path: Path) -> Path:
    return path.expanduser().resolve(strict=False)


def codex_home_candidates():
    env_home = os.environ.get("CODEX_HOME")
    if env_home:
        yield resolved(Path(env_home))
    yield resolved(Path.home() / ".codex")


def detect_scope(path: Path, requested_scope: str) -> str:
    if requested_scope != "auto":
        return requested_scope

    if path.name.lower() not in AGENTS_FILE_NAMES:
        return "repo"

    file_path = resolved(path)
    for codex_home in codex_home_candidates():
        if file_path.parent == codex_home:
            return "global"
    return "repo"


def destructive_command_is_guarded(line: str, command: str) -> bool:
    normalized = " ".join(line.lower().split())
    command_pattern = re.escape(command.lower())

    guard_patterns = [
        rf"\b(?:do not|don't|never|must not|should not|cannot|can't)\s+(?:run|use|execute|call|invoke)?\s*{command_pattern}\b",
        rf"\b(?:forbid|forbidden|prohibit|prohibited)\b.{{0,60}}{command_pattern}\b",
        rf"{command_pattern}\b.{{0,60}}\b(?:forbidden|prohibited|not allowed|blocked)\b",
        rf"{command_pattern}\b.{{0,100}}\b(?:only|after|unless|when)\b.{{0,100}}\b(?:explicit|approval|approved|requested|request|confirmation|confirmed)\b.{{0,100}}\b(?:user|human|current chat)\b",
        rf"{command_pattern}\b.{{0,100}}\b(?:must not|should not|cannot|can't)\b.{{0,100}}\bwithout\b.{{0,100}}\b(?:explicit|approval|approved|requested|request|confirmation|confirmed)\b",
    ]
    return any(re.search(pattern, normalized) for pattern in guard_patterns)


def score_text(text: str, byte_count: int, max_bytes: int, scope: str):
    if scope == "global":
        score, criteria, issues, recommendations = criteria_points(text, GLOBAL_CRITERIA)
        criteria["global_concision"] = 15 if byte_count <= min(max_bytes, 8192) else 0
        score += criteria["global_concision"]
        if criteria["global_concision"] == 0:
            issues.append("Global instruction file is too large for a cross-project preference file.")
            recommendations.append("Keep global instructions short and move repository-specific rules into repository AGENTS.md.")
    else:
        score, criteria, issues, recommendations = criteria_points(text, REPO_CRITERIA)

    if byte_count > max_bytes:
        issues.append(f"Instruction file exceeds context budget: {byte_count} bytes > {max_bytes}.")
        recommendations.append("Split or shorten instructions so Codex can load the important files.")
        score = min(score, 89)

    for command in DANGEROUS:
        for line in text.splitlines():
            line_lower = line.lower()
            if command.lower() in line_lower:
                if not destructive_command_is_guarded(line, command):
                    issues.append(f"Unguarded destructive command found: {command}.")
                    recommendations.append(f"Frame `{command}` as forbidden unless explicitly requested.")
                    score = min(score, 59)

    bounded = max(0, min(100, score))
    return {
        "scope": scope,
        "score": bounded,
        "grade": grade(bounded),
        "criteria": criteria,
        "issues": issues,
        "recommended_additions": recommendations,
    }


def score_file(path: Path, max_bytes: int, requested_scope: str):
    data = path.read_bytes()
    text = data.decode("utf-8", errors="replace")
    scope = detect_scope(path, requested_scope)
    result = score_text(text, len(data), max_bytes, scope)
    result["path"] = str(path)
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--max-bytes", type=int, default=32768)
    parser.add_argument("--scope", choices=["auto", "global", "repo"], default="auto")
    args = parser.parse_args()

    results = [score_file(Path(path), args.max_bytes, args.scope) for path in args.paths]
    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        for result in results:
            print(f"{result['path']}: {result['score']}/100 ({result['grade']})")


if __name__ == "__main__":
    main()
