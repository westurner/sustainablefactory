#!/usr/bin/env python3
"""Find and optionally fix Markdown display-math blocks adjacent to prose."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


WORKSPACE_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ROOT = WORKSPACE_ROOT / "docs"
DEFAULT_REPORT = WORKSPACE_ROOT / ".tmp" / "markdown-display-math-spacing.json"
DEFAULT_INLINE_MATH_MIN_LENGTH = 64
FENCE_START = re.compile(r"^\s*(`{3,}|~{3,})")
DISPLAY_DELIMITER = re.compile(r"^\s*\$\$\s*(?:\r?\n)?$")
INLINE_DISPLAY_MATH = re.compile(r"\$\$(.+?)\$\$")


def _is_unescaped(text: str, index: int) -> bool:
    backslashes = 0
    index -= 1
    while index >= 0 and text[index] == "\\":
        backslashes += 1
        index -= 1
    return backslashes % 2 == 0


def _inline_code_spans(line: str) -> list[tuple[int, int]]:
    return [
        (match.start(), match.end())
        for match in re.finditer(r"(?<!\\)(`+).*?\1", line)
    ]


def _continuation_indent(line: str) -> str:
    list_prefix = re.match(r"^(\s*(?:[-+*]|\d+[.)])\s+)", line)
    if list_prefix:
        return " " * len(list_prefix.group(1))
    return re.match(r"^\s*", line).group(0)


def scan_text(
    text: str,
    relative_path: str = "<text>",
    inline_math_min_length: int = DEFAULT_INLINE_MATH_MIN_LENGTH,
) -> list[dict[str, object]]:
    """Find standalone $$ blocks missing a blank line on either side."""
    lines = text.splitlines(keepends=True)
    fenced_lines: set[int] = set()
    fence_character: str | None = None
    fence_length = 0

    for line_index, line in enumerate(lines):
        match = FENCE_START.match(line)
        if match:
            marker = match.group(1)
            if fence_character is None:
                fence_character = marker[0]
                fence_length = len(marker)
            elif marker[0] == fence_character and len(marker) >= fence_length:
                fence_character = None
                fence_length = 0
            fenced_lines.add(line_index)
        elif fence_character is not None:
            fenced_lines.add(line_index)

    findings: list[dict[str, object]] = []
    opening: int | None = None
    for line_index, line in enumerate(lines):
        if line_index in fenced_lines or not DISPLAY_DELIMITER.match(line):
            continue

        if opening is None:
            opening = line_index
            continue

        closing = line_index
        content = "".join(lines[opening + 1 : closing])
        if content.strip():
            missing_before = opening > 0 and bool(lines[opening - 1].strip())
            missing_after = closing + 1 < len(lines) and bool(lines[closing + 1].strip())
            if missing_before or missing_after:
                findings.append(
                    {
                        "kind": "standalone-display-block",
                        "file": relative_path,
                        "open_line": opening + 1,
                        "close_line": closing + 1,
                        "missing_blank_before": missing_before,
                        "missing_blank_after": missing_after,
                        "math": content.strip(),
                    }
                )
        opening = None

    for line_index, line in enumerate(lines):
        if line_index in fenced_lines or re.match(r"^\s*\|", line):
            continue
        code_spans = _inline_code_spans(line)
        for match in INLINE_DISPLAY_MATH.finditer(line):
            closing_start = match.end() - 2
            math = match.group(1).strip()
            if len(math) < inline_math_min_length:
                continue
            if not _is_unescaped(line, match.start()) or not _is_unescaped(
                line, closing_start
            ):
                continue
            if any(start <= match.start() < end for start, end in code_spans):
                continue
            findings.append(
                {
                    "kind": "inline-display-math",
                    "file": relative_path,
                    "line": line_index + 1,
                    "start_column": match.start() + 1,
                    "end_column": match.end() + 1,
                    "math": math,
                }
            )

    return findings


def fix_text(
    text: str,
    inline_math_min_length: int = DEFAULT_INLINE_MATH_MIN_LENGTH,
) -> tuple[str, list[dict[str, object]]]:
    """Split inline display math, then space standalone blocks from prose."""
    findings = scan_text(text, inline_math_min_length=inline_math_min_length)
    if not findings:
        return text, findings

    lines = text.splitlines(keepends=True)
    newline = "\r\n" if "\r\n" in text else "\n"
    inline_by_line: dict[int, list[dict[str, object]]] = {}
    for finding in findings:
        if finding["kind"] == "inline-display-math":
            inline_by_line.setdefault(int(finding["line"]) - 1, []).append(finding)

    for line_index, line_findings in inline_by_line.items():
        original_line = lines[line_index]
        body = original_line.rstrip("\r\n")
        line_ending = original_line[len(body) :]
        indent = _continuation_indent(body)
        segments: list[str] = []
        cursor = 0

        for finding in sorted(line_findings, key=lambda item: int(item["start_column"])):
            start = int(finding["start_column"]) - 1
            end = int(finding["end_column"]) - 1
            before = body[cursor:start]
            if before.strip():
                segments.append(before.rstrip() if not segments else indent + before.strip())
            math = str(finding["math"])
            segments.append(
                f"{indent}$$\n{indent}{math}\n{indent}$$"
            )
            cursor = end

        after = body[cursor:]
        if after.strip():
            segments.append(indent + after.strip())
        lines[line_index] = (newline + newline).join(segments) + line_ending

    fixed_text = "".join(lines)
    block_findings = [
        finding
        for finding in scan_text(
            fixed_text, inline_math_min_length=inline_math_min_length
        )
        if finding["kind"] == "standalone-display-block"
    ]
    if not block_findings:
        return fixed_text, findings

    lines = fixed_text.splitlines(keepends=True)
    for finding in sorted(block_findings, key=lambda item: int(item["open_line"]), reverse=True):
        opening = int(finding["open_line"]) - 1
        closing = int(finding["close_line"]) - 1
        if finding["missing_blank_after"]:
            lines.insert(closing + 1, newline)
        if finding["missing_blank_before"]:
            lines.insert(opening, newline)

    return "".join(lines), findings


def _read_text(path: Path) -> str:
    with path.open("r", encoding="utf-8", newline="") as source_file:
        return source_file.read()


def _markdown_files(root: Path):
    for path in sorted(root.rglob("*.md")):
        if "_build" in path.parts or ".tmp" in path.parts:
            continue
        yield path


def _selected_files(root: Path, selected: list[Path] | None):
    if not selected:
        yield from _markdown_files(root)
        return
    for path in selected:
        candidate = path if path.is_absolute() else (WORKSPACE_ROOT / path)
        candidate = candidate.resolve()
        if candidate.suffix != ".md" or not candidate.is_file():
            raise FileNotFoundError(f"Markdown file not found: {candidate}")
        yield candidate


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    parser.add_argument(
        "--file",
        type=Path,
        action="append",
        help="scan only this Markdown file; may be supplied more than once",
    )
    parser.add_argument(
        "--inline-math-min-length",
        type=int,
        default=DEFAULT_INLINE_MATH_MIN_LENGTH,
        help="minimum TeX length for same-line $$...$$ candidates (default: 64)",
    )
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument(
        "--fix",
        action="store_true",
        help="insert missing blank lines in place, then verify the scan",
    )
    args = parser.parse_args(argv)

    root = args.root.resolve()
    report_path = args.report.resolve()
    if not root.is_dir():
        parser.error(f"Markdown root is not a directory: {root}")
    if args.inline_math_min_length < 0:
        parser.error("--inline-math-min-length must be nonnegative")

    report_path.parent.mkdir(parents=True, exist_ok=True, mode=0o1777)
    if report_path.parent.name == ".tmp":
        report_path.parent.chmod(0o1777)

    findings: list[dict[str, object]] = []
    fixed_files = 0
    if args.fix:
        for path in _selected_files(root, args.file):
            original = _read_text(path)
            relative_path = (
                path.relative_to(WORKSPACE_ROOT).as_posix()
                if path.is_relative_to(WORKSPACE_ROOT)
                else path.as_posix()
            )
            file_findings = scan_text(
                original, relative_path, args.inline_math_min_length
            )
            findings.extend(file_findings)
            if file_findings:
                corrected, _ = fix_text(original, args.inline_math_min_length)
                with path.open("w", encoding="utf-8", newline="") as destination_file:
                    destination_file.write(corrected)
                fixed_files += 1
    else:
        for path in _selected_files(root, args.file):
            relative_path = (
                path.relative_to(WORKSPACE_ROOT).as_posix()
                if path.is_relative_to(WORKSPACE_ROOT)
                else path.as_posix()
            )
            findings.extend(
                scan_text(_read_text(path), relative_path, args.inline_math_min_length)
            )

    remaining: list[dict[str, object]] = []
    if args.fix:
        for path in _selected_files(root, args.file):
            relative_path = (
                path.relative_to(WORKSPACE_ROOT).as_posix()
                if path.is_relative_to(WORKSPACE_ROOT)
                else path.as_posix()
            )
            remaining.extend(
                scan_text(_read_text(path), relative_path, args.inline_math_min_length)
            )

    report = {
        "root": root.as_posix(),
        "fixed": args.fix,
        "fixed_files": fixed_files,
        "finding_count": len(findings),
        "remaining_count": len(remaining) if args.fix else len(findings),
        "findings": findings,
        "remaining": remaining,
    }
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    if args.fix:
        print(
            f"Fixed {len(findings) - len(remaining)} display-math block(s) in "
            f"{fixed_files} file(s); {len(remaining)} finding(s) remain."
        )
    else:
        print(f"Found {len(findings)} display-math block(s) missing blank lines.")
    print(f"Report: {report_path}")
    return 1 if remaining else 0


if __name__ == "__main__":
    raise SystemExit(main())