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
    if cwd == root:
        return parts
    relative = cwd.relative_to(root)
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
