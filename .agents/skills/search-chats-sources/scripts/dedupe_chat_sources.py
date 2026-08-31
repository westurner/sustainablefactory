#!/usr/bin/env python3
"""Build a deduplicated list of chat export files.

When both .md and .json exist for the same basename, keep only the
preferred extension. This is intended as a companion utility for the
search-chats-sources skill.
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


SUPPORTED_EXTENSIONS = ("md", "json")


@dataclass(frozen=True)
class SelectedFile:
    basename: str
    extension: str
    path: str
    duplicate_pair: bool


def iter_chat_files(root: Path) -> Iterable[Path]:
    for extension in SUPPORTED_EXTENSIONS:
        yield from sorted(root.glob(f"*.{extension}"))


def dedupe_chat_files(
    root: Path, prefer: str
) -> tuple[list[SelectedFile], list[dict[str, str]]]:
    grouped: dict[str, dict[str, Path]] = {}
    skipped: list[dict[str, str]] = []

    for path in iter_chat_files(root):
        grouped.setdefault(path.stem, {})[path.suffix.lstrip(".")] = path

    selected: list[SelectedFile] = []
    for basename in sorted(grouped):
        variants = grouped[basename]
        duplicate_pair = all(
            extension in variants for extension in SUPPORTED_EXTENSIONS
        )

        if duplicate_pair:
            chosen_extension = prefer
            skipped_extension = "json" if prefer == "md" else "md"
            skipped.append(
                {
                    "basename": basename,
                    "kept": str(variants[chosen_extension]),
                    "skipped": str(variants[skipped_extension]),
                }
            )
        else:
            chosen_extension = "md" if "md" in variants else "json"

        selected.append(
            SelectedFile(
                basename=basename,
                extension=chosen_extension,
                path=str(variants[chosen_extension]),
                duplicate_pair=duplicate_pair,
            )
        )

    return selected, skipped


def build_summary(
    selected: list[SelectedFile], skipped: list[dict[str, str]], prefer: str
) -> dict[str, object]:
    counts = Counter(item.extension for item in selected)
    return {
        "root": str(Path(selected[0].path).parent) if selected else "",
        "prefer": prefer,
        "selected_count": len(selected),
        "skipped_duplicate_pairs": len(skipped),
        "counts_by_extension": dict(sorted(counts.items())),
        "selected": [asdict(item) for item in selected],
        "skipped": skipped,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root", default="data/chats", help="Directory containing chat export files"
    )
    parser.add_argument(
        "--prefer",
        choices=SUPPORTED_EXTENSIONS,
        default="md",
        help="Preferred extension when both .md and .json exist",
    )
    parser.add_argument(
        "--format",
        choices=("lines", "json"),
        default="lines",
        help="Output as newline-delimited paths or structured JSON",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.root)

    if not root.exists():
        raise SystemExit(f"Chat source directory not found: {root}")
    if not root.is_dir():
        raise SystemExit(f"Chat source path is not a directory: {root}")

    selected, skipped = dedupe_chat_files(root, prefer=args.prefer)

    if args.format == "lines":
        for item in selected:
            print(item.path)
        return 0

    print(
        json.dumps(
            build_summary(selected, skipped, prefer=args.prefer),
            indent=2,
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
