"""Preview or remove duplicate files in a directory.

The script groups files first by size, then by a shared prefix of their
contents. Files that still match after that are compared byte-for-byte; if the
contents are identical, the later file is removed.

By default this runs in preview mode and prints the commands that would run.
Pass -y/--yes to remove files in place.
"""

from __future__ import annotations

import argparse
import filecmp
import shlex
import sys
from pathlib import Path
from typing import NamedTuple


DEFAULT_PREFIX_BYTES = 64


class RemovalPlanItem(NamedTuple):
    keep: Path
    remove: Path
    size: int
    prefix: bytes


def _filename_sort_key(path: Path) -> tuple[int, str, str]:
    return (len(path.name), path.name, str(path))


def _iter_files(root: Path) -> list[Path]:
    if root.is_file():
        return [root]
    if not root.is_dir():
        return []

    files = [path for path in root.rglob("*") if path.is_file()]
    return sorted(files)


def _prefix_bytes(path: Path, prefix_bytes: int) -> bytes:
    with path.open("rb") as handle:
        return handle.read(prefix_bytes)


def _prefix_preview(prefix: bytes) -> str:
    text = prefix.decode("utf-8", errors="replace").replace("\n", "\\n")
    if len(text) > 32:
        return text[:29] + "..."
    return text


def build_removal_plan(
    root: Path, prefix_bytes: int = DEFAULT_PREFIX_BYTES
) -> list[RemovalPlanItem]:
    """Build a deterministic plan for removing identical files."""
    plan: list[RemovalPlanItem] = []
    size_groups: dict[int, list[Path]] = {}

    for path in _iter_files(root):
        size_groups.setdefault(path.stat().st_size, []).append(path)

    for size in sorted(size_groups):
        files = size_groups[size]
        if len(files) < 2:
            continue

        prefix_groups: dict[bytes, list[Path]] = {}
        for path in files:
            prefix_groups.setdefault(_prefix_bytes(path, prefix_bytes), []).append(path)

        for prefix in sorted(prefix_groups, key=lambda value: value):
            candidates = prefix_groups[prefix]
            if len(candidates) < 2:
                continue

            clusters: list[list[Path]] = []
            for candidate in candidates:
                for cluster in clusters:
                    if filecmp.cmp(cluster[0], candidate, shallow=False):
                        cluster.append(candidate)
                        break
                else:
                    clusters.append([candidate])

            for cluster in clusters:
                if len(cluster) < 2:
                    continue

                keep = min(cluster, key=_filename_sort_key)
                removals = sorted(
                    (path for path in cluster if path != keep),
                    key=_filename_sort_key,
                    reverse=True,
                )
                for remove in removals:
                    plan.append(
                        RemovalPlanItem(
                            keep=keep, remove=remove, size=size, prefix=prefix
                        )
                    )

    return plan


def _format_command(plan_item: RemovalPlanItem) -> str:
    keep = shlex.quote(str(plan_item.keep))
    remove = shlex.quote(str(plan_item.remove))
    prefix = _prefix_preview(plan_item.prefix)
    return f"cmp -s {keep} {remove} && rm {remove}  # size={plan_item.size} prefix={prefix}"


def apply_removal_plan(plan: list[RemovalPlanItem]) -> None:
    for plan_item in plan:
        if plan_item.keep == plan_item.remove:
            continue
        plan_item.remove.unlink()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Preview or remove duplicate files by size, prefix, and exact content.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("path", type=Path, help="Directory or file to inspect")
    parser.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Actually remove duplicate files instead of previewing the commands",
    )
    parser.add_argument(
        "--prefix-bytes",
        type=int,
        default=DEFAULT_PREFIX_BYTES,
        help="Number of leading bytes used to group candidate files",
    )
    args = parser.parse_args(argv)

    plan = build_removal_plan(args.path, prefix_bytes=args.prefix_bytes)
    if not plan:
        print(f"No duplicate files found under {args.path}", file=sys.stderr)
        return 0

    for plan_item in plan:
        print(_format_command(plan_item))

    if args.yes:
        apply_removal_plan(plan)
    else:
        print("Add -y to remove these files.", file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
