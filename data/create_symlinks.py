#!/usr/bin/env python3
"""Build tagged chat overlay directories from source documents."""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import sys
from pathlib import Path
from typing import Iterable

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    yaml = None
    _YAML_IMPORT_ERROR = exc


__version__ = "0.1.0"
DEFAULT_INCLUDE_GLOBS = ("*.json", "*.md")
DEFAULT_CONFIG_NAME = "../docs/_toc.yml"
_INVALID_TAG_CHARS = re.compile(r"[^a-zA-Z0-9._-]+")


def _normalise_tags(value: object) -> list[str]:
    if isinstance(value, str):
        values = [value]
    elif isinstance(value, (list, tuple, set)):
        values = list(value)
    else:
        return []

    tags = []
    for item in values:
        tag = str(item).strip()
        if tag and tag not in tags:
            tags.append(tag)
    return tags


def _front_matter(path: Path) -> dict:
    if yaml is None:  # pragma: no cover
        raise RuntimeError("PyYAML is required to read document tags") from _YAML_IMPORT_ERROR

    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    try:
        end = next(index for index, line in enumerate(lines[1:], 1) if line.strip() == "---")
    except StopIteration:
        return {}
    data = yaml.safe_load("\n".join(lines[1:end]))
    return data if isinstance(data, dict) else {}


def document_tags(path: Path) -> list[str]:
    """Read tags from Markdown front matter or a JSON document."""
    if path.suffix.lower() == ".md":
        return _normalise_tags(_front_matter(path).get("tags"))
    if path.suffix.lower() == ".json":
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            return []
        if isinstance(data, dict):
            return _normalise_tags(data.get("tags"))
    return []


def _matches(path: Path, pattern: str, source_root: Path) -> bool:
    relative = path.relative_to(source_root).as_posix()
    return fnmatch.fnmatch(path.name, pattern) or fnmatch.fnmatch(relative, pattern)


def source_documents(
    source_root: Path,
    include_globs: Iterable[str] = DEFAULT_INCLUDE_GLOBS,
    exclude_globs: Iterable[str] = (),
    files: Iterable[str | Path] = (),
) -> list[Path]:
    """Return source documents selected by project-specific globs or files."""
    source_root = Path(source_root)
    selected: set[Path] = set()
    for pattern in include_globs:
        selected.update(path for path in source_root.glob(pattern) if path.is_file())
    for value in files:
        path = Path(value)
        path = path if path.is_absolute() else source_root / path
        if path.is_file():
            selected.add(path)

    excluded = tuple(exclude_globs)
    return sorted(
        path
        for path in selected
        if not any(_matches(path, pattern, source_root) for pattern in excluded)
    )


def _link(source: Path, destination: Path) -> bool:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.is_symlink():
        if destination.resolve() == source.resolve():
            return False
        raise FileExistsError(f"symlink points to another source: {destination}")
    if destination.exists():
        raise FileExistsError(f"refusing to replace existing file: {destination}")
    destination.symlink_to(Path(os.path.relpath(source, destination.parent)))
    return True


def create_chat_symlinks(
    source_chats_path: str | Path,
    overlays: dict[str, str | Path],
    do_print_files: bool = True,
    do_create_overlay_symlinks: bool = True,
    include_globs: Iterable[str] = DEFAULT_INCLUDE_GLOBS,
    exclude_globs: Iterable[str] = (),
    files: Iterable[str | Path] = (),
    tag_root: str | Path | None = None,
) -> dict[str, list[Path]]:
    """Create an ``all`` overlay and one overlay per source-document tag."""
    source_root = Path(source_chats_path)
    source_files = source_documents(source_root, include_globs, exclude_globs, files)
    if do_print_files:
        for path in source_files:
            print(path.relative_to(source_root))

    all_overlay = Path(overlays["all"])
    tag_root_path = Path(tag_root) if tag_root is not None else None
    destinations = {"all": all_overlay}
    tagged_files: dict[str, list[Path]] = {"all": []}
    for source in source_files:
        tags = document_tags(source)
        safe_tags = [
            _INVALID_TAG_CHARS.sub("-", tag.strip()).strip("-.") for tag in tags
        ]
        for safe_tag in safe_tags:
            if safe_tag:
                destinations.setdefault(
                    safe_tag,
                    (tag_root_path / safe_tag)
                    if tag_root_path is not None
                    else all_overlay.parent / f"chats__{safe_tag}",
                )
                tagged_files.setdefault(safe_tag, [])

        if do_create_overlay_symlinks:
            overlay_names = ["all"] + safe_tags
            for overlay_name in dict.fromkeys(name for name in overlay_names if name):
                destination = destinations[overlay_name] / source.name
                if _link(source, destination):
                    tagged_files[overlay_name].append(destination)

    return tagged_files


def build_config() -> dict:
    root = Path(__file__).resolve().parent
    return {
        "source_chats": root / "chats",
        "overlays": {"all": root / "chatoverlay" / "chats__all"},
        "do_print_files": True,
        "do_create_overlay_symlinks": True,
    }


def load_config(path: Path) -> dict:
    """Load chat settings from a Jupyter Book or project TOC YAML file."""
    if yaml is None:  # pragma: no cover
        raise RuntimeError("PyYAML is required to read project settings") from _YAML_IMPORT_ERROR
    document = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(document, dict):
        raise ValueError(f"project settings must be a mapping: {path}")
    data = document.get("chat_sources")
    if data is None:
        project = document.get("sustainablefactory", {})
        data = project.get("chat_sources") if isinstance(project, dict) else None
    if not isinstance(data, dict):
        raise ValueError(f"chat_sources settings not found in TOC: {path}")
    data = dict(data)
    base = path.parent.resolve()
    if data.get("source"):
        data["source_chats"] = (base / data.pop("source")).resolve()
    if data.get("overlay_root"):
        data["overlay_root"] = (base / data.pop("overlay_root")).resolve()
    if data.get("tag_root"):
        data["tag_root"] = (base / data.pop("tag_root")).resolve()
    return data


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--config",
        type=Path,
        help="Project/Jupyter Book TOC YAML file (default: docs/_toc.yml)",
    )
    parser.add_argument("--source", type=Path, help="Source document directory")
    parser.add_argument(
        "--overlay-root",
        type=Path,
        help="Directory containing chats__all and generated chats__TAG directories",
    )
    parser.add_argument(
        "--include", dest="include_globs", action="append", help="Input glob (repeatable)"
    )
    parser.add_argument(
        "--exclude", dest="exclude_globs", action="append", default=[], help="Excluded glob (repeatable)"
    )
    parser.add_argument(
        "--file", dest="files", action="append", default=[], help="Explicit source file (repeatable)"
    )
    parser.add_argument("--quiet", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--version", action="version", version=__version__)
    args = parser.parse_args(argv)

    defaults = build_config()
    config_path = args.config or Path(__file__).resolve().parent / DEFAULT_CONFIG_NAME
    config = load_config(config_path) if config_path.exists() else defaults
    source = args.source or config.get("source_chats", defaults["source_chats"])
    default_overlay_root = Path(defaults["overlays"]["all"]).parent
    overlay_root = args.overlay_root or config.get("overlay_root", default_overlay_root)
    include_globs = args.include_globs or config.get(
        "include", config.get("include_globs", DEFAULT_INCLUDE_GLOBS)
    )
    exclude_globs = args.exclude_globs or config.get(
        "exclude", config.get("exclude_globs", [])
    )
    files = args.files or config.get("files", [])
    tag_root = config.get("tag_root")
    overlays = {"all": overlay_root / "chats__all"}
    create_chat_symlinks(
        source,
        overlays,
        do_print_files=not args.quiet,
        do_create_overlay_symlinks=not args.dry_run,
        include_globs=include_globs,
        exclude_globs=exclude_globs,
        files=files,
        tag_root=tag_root,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
