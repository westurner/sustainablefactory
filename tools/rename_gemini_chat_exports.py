"""Rename Gemini chat export files using the first user prompt.

By default this runs in preview mode and prints the proposed rename mapping.
Pass -y/--yes to perform the renames in place.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import sys
import unicodedata
from pathlib import Path
from typing import Iterable


GEMINI_PREFIX = "Gemini-_"
GEMINI_EXTENSIONS = {".md", ".json"}
MAX_FILENAME_STEM_LENGTH = 128


def slugify(text: str) -> str:
    """Convert text to a filesystem-safe slug."""
    text = re.sub(r"https?://\S+|www\.\S+", " ", text)
    normalized = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode(
        "ascii"
    )
    normalized = normalized.lower().strip()
    normalized = re.sub(r"[^a-z0-9\s-]", "", normalized)
    normalized = re.sub(r"[-\s]+", "-", normalized)
    return normalized.strip("-")


def _truncate_stem(stem: str, suffix: str = "") -> str:
    """Limit the filename stem to the configured maximum length including suffix."""
    max_stem_length = MAX_FILENAME_STEM_LENGTH - len(suffix)
    if len(stem) <= max_stem_length:
        return stem
    truncated = stem[:max_stem_length].rstrip("-_. ")
    return truncated or "untitled"


def _first_text_from_json(data: object) -> str:
    """Extract the first user-facing prompt text from a Gemini-style JSON export."""
    entries: Iterable[object]
    if isinstance(data, list):
        entries = data
    elif isinstance(data, dict):
        messages = data.get("messages")
        entries = messages if isinstance(messages, list) else []
    else:
        return ""

    for entry in entries:
        if not isinstance(entry, dict):
            continue

        role = str(entry.get("role") or entry.get("author") or "").lower()
        if role not in {"user", "prompt"}:
            continue

        content = entry.get("content")
        if isinstance(content, str) and content.strip():
            return content.strip()

        contents = entry.get("contents")
        if isinstance(contents, list):
            for part in contents:
                if not isinstance(part, dict):
                    continue
                for key in ("content", "text", "value"):
                    text = part.get(key)
                    if isinstance(text, str) and text.strip():
                        return text.strip()

        message = entry.get("message")
        if isinstance(message, dict):
            text = message.get("text")
            if isinstance(text, str) and text.strip():
                return text.strip()

    return ""


def _first_text_from_markdown(text: str) -> str:
    """Extract the first prompt from the standard Gemini markdown export format."""
    match = re.search(
        r"(?is)^[> ]*#\s*you asked\s*\n(?:.*?\n)*?message time:.*?\n\s*(?P<prompt>.*?)(?:\n\s*---\s*\n|\n\s*#\s*gemini response\b|\Z)",
        text,
    )
    if match:
        prompt = match.group("prompt").strip()
        if prompt:
            return prompt

    lines = text.splitlines()
    seen_header = False
    seen_time = False
    prompt_lines: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not seen_header:
            if stripped.lower().startswith("# you asked"):
                seen_header = True
            continue
        if not seen_time:
            if stripped.lower().startswith("message time:"):
                seen_time = True
            continue
        if stripped.startswith("---") or stripped.lower().startswith("# gemini response"):
            break
        if not stripped and not prompt_lines:
            continue
        prompt_lines.append(line)

    return "\n".join(prompt_lines).strip()


def extract_first_prompt(path: Path) -> str:
    """Read a Gemini export and return the first prompt text."""
    if path.suffix.lower() == ".json":
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            return ""
        return _first_text_from_json(data)

    if path.suffix.lower() == ".md":
        return _first_text_from_markdown(path.read_text(encoding="utf-8"))

    return ""


def candidate_files(root: Path) -> list[Path]:
    """Return Gemini export files that live directly in root."""
    if root.is_file():
        return [root] if root.name.startswith(GEMINI_PREFIX) and root.suffix.lower() in GEMINI_EXTENSIONS else []

    if not root.is_dir():
        return []

    files = []
    for path in sorted(root.iterdir()):
        if path.is_file() and path.name.startswith(GEMINI_PREFIX) and path.suffix.lower() in GEMINI_EXTENSIONS:
            files.append(path)
    return files


def build_rename_plan(root: Path) -> list[tuple[Path, Path, str]]:
    """Build a collision-safe rename plan for Gemini exports."""
    plan: list[tuple[Path, Path, str]] = []
    used: set[Path] = set()
    slug_counts: dict[tuple[str,int], int] = {}

    for src in candidate_files(root):
        prompt = extract_first_prompt(src)
        slug = slugify(prompt) if prompt else "untitled"
        if not slug:
            slug = "untitled"

        fileext = os.path.splitext(src)[-1]
        slug = (slug, fileext)

        slug_counts[slug] = slug_counts.get(slug, 0) + 1
        suffix = "" if slug_counts[slug] == 1 else f"-{slug_counts[slug]}"
        stem = _truncate_stem(slug[0], suffix)
        dst = src.with_name(f"{stem}{suffix}{src.suffix.lower()}")

        while dst in used or (dst.exists() and dst != src):
            slug_counts[slug] += 1
            suffix = f"-{slug_counts[slug]}"
            stem = _truncate_stem(slug[0], suffix)
            dst = src.with_name(f"{stem}{suffix}{src.suffix.lower()}")

        used.add(dst)
        plan.append((src, dst, prompt))

    return plan


def apply_rename_plan(plan: list[tuple[Path, Path, str]]) -> None:
    """Rename files in place using a precomputed plan."""
    for src, dst, _prompt in plan:
        if src == dst:
            continue
        src.rename(dst)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Preview or rename Gemini chat export files based on the first prompt.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("path", type=Path, help="Directory or file to process")
    parser.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Actually rename files instead of previewing the mapping",
    )
    args = parser.parse_args(argv)

    plan = build_rename_plan(args.path)
    if not plan:
        print(f"No Gemini exports found under {args.path}")
        return 0

    for src, dst, prompt in plan:
        preview = prompt.replace("\n", " ").strip()
        if len(preview) > 80:
            preview = preview[:77] + "..."
        if args.yes:
            print(f"mv {shlex.quote(src.name)} {shlex.quote(dst.name)}")   # {preview}")
        else:
            print(f"mv {shlex.quote(src.name)} {shlex.quote(dst.name)}")   # {preview}")

    if args.yes:
        apply_rename_plan(plan)
    else:
        print("Add -y to apply these renames.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))