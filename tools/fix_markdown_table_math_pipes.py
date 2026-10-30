#!/usr/bin/env python3
"""Find and optionally escape pipes inside LaTeX in Markdown table rows."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


WORKSPACE_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ROOT = WORKSPACE_ROOT / "docs"
DEFAULT_REPORT = WORKSPACE_ROOT / ".tmp" / "markdown-table-math-pipes.json"
TABLE_ROW = re.compile(r"^\s*\|")
FENCE_START = re.compile(r"^\s*(`{3,}|~{3,})")
TABLE_SEPARATOR_CELL = re.compile(r":?-{3,}:?")


def _is_unescaped(text: str, index: int) -> bool:
    backslashes = 0
    index -= 1
    while index >= 0 and text[index] == "\\":
        backslashes += 1
        index -= 1
    return backslashes % 2 == 0


def _run_length(text: str, index: int, character: str) -> int:
    end = index
    while end < len(text) and text[end] == character:
        end += 1
    return end - index


def _looks_like_latex(expression: str) -> bool:
    has_tex_command = bool(re.search(r"\\(?:[A-Za-z]+|.)", expression))
    words = re.findall(r"[A-Za-z]+", expression)
    if not has_tex_command and (
        "**" in expression or "__" in expression or any(len(word) > 2 for word in words)
    ):
        return False

    if has_tex_command or re.search(r"[_^{}=<>]", expression):
        return True

    compact_absolute_value = re.fullmatch(
        r"\s*\|[\sA-Za-z0-9.+*/()\-]+\|\s*", expression
    )
    if compact_absolute_value:
        return True

    stripped = expression.strip()
    if stripped.startswith("|") or stripped.endswith("|"):
        return False

    return bool(words) and all(len(word) <= 2 for word in words) and bool(
        re.fullmatch(r"[\s|A-Za-z0-9.,:+*/<>=!()\-]+", expression)
    )


def _math_pipe_positions(line: str) -> list[tuple[int, str]]:
    positions: list[tuple[int, str]] = []
    math_delimiter: str | None = None
    math_start = 0
    code_ticks = 0
    index = 0

    while index < len(line):
        character = line[index]

        if code_ticks:
            if character == "`":
                run = _run_length(line, index, "`")
                if run == code_ticks:
                    code_ticks = 0
                index += run
            else:
                index += 1
            continue

        if math_delimiter is None:
            if character == "`" and _is_unescaped(line, index):
                code_ticks = _run_length(line, index, "`")
                index += code_ticks
                continue
            if character == "$" and _is_unescaped(line, index):
                math_delimiter = "$$" if line.startswith("$$", index) else "$"
                math_start = index + len(math_delimiter)
                index = math_start
                continue
        elif (
            character == "$"
            and _is_unescaped(line, index)
            and line.startswith(math_delimiter, index)
        ):
            expression = line[math_start:index]
            if _looks_like_latex(expression):
                positions.extend(
                    (pipe_index, expression)
                    for pipe_index, value in enumerate(
                        line[math_start:index], math_start
                    )
                    if value == "|" and _is_unescaped(line, pipe_index)
                )
            index += len(math_delimiter)
            math_delimiter = None
            continue

        index += 1

    return positions


def _separator_columns(line: str) -> int | None:
    if not TABLE_ROW.match(line):
        return None
    cells = line.strip().strip("|").split("|")
    if cells and all(TABLE_SEPARATOR_CELL.fullmatch(cell.strip()) for cell in cells):
        return len(cells)
    return None


def _unescaped_pipe_positions(line: str) -> list[int]:
    return [
        index
        for index, character in enumerate(line)
        if character == "|" and _is_unescaped(line, index)
    ]


def _trailing_pipe(line: str) -> bool:
    trimmed = line.rstrip()
    return bool(trimmed) and trimmed[-1] == "|" and _is_unescaped(trimmed, len(trimmed) - 1)


def scan_text(text: str, relative_path: str = "<text>") -> list[dict[str, object]]:
    """Return unescaped pipe occurrences inside math on Markdown table rows."""
    findings: list[dict[str, object]] = []
    fence_character: str | None = None
    fence_length = 0
    lines = text.splitlines(keepends=True)
    fenced_lines: set[int] = set()

    for line_index, line in enumerate(lines):
        fence_match = FENCE_START.match(line)
        if fence_match:
            marker = fence_match.group(1)
            if fence_character is None:
                fence_character = marker[0]
                fence_length = len(marker)
            elif marker[0] == fence_character and len(marker) >= fence_length:
                fence_character = None
                fence_length = 0
            fenced_lines.add(line_index)
            continue

        if fence_character is not None:
            fenced_lines.add(line_index)

    line_index = 0
    while line_index + 1 < len(lines):
        if line_index in fenced_lines or not TABLE_ROW.match(lines[line_index]):
            line_index += 1
            continue

        expected_columns = _separator_columns(lines[line_index + 1])
        if line_index + 1 in fenced_lines or expected_columns is None:
            line_index += 1
            continue

        table_end = line_index
        while table_end < len(lines) and table_end not in fenced_lines and TABLE_ROW.match(lines[table_end]):
            table_end += 1

        for row_index in range(line_index, table_end):
            line = lines[row_index]
            pipe_positions = _unescaped_pipe_positions(line)
            expected_separators = expected_columns + int(_trailing_pipe(line))
            excess_separators = max(0, len(pipe_positions) - expected_separators)
            math_pipes = _math_pipe_positions(line)

            if not excess_separators or not math_pipes:
                continue

            for column, expression in math_pipes[:excess_separators]:
                findings.append(
                    {
                        "file": relative_path,
                        "line": row_index + 1,
                        "column": column + 1,
                        "expression": expression,
                        "pipe": "|",
                    }
                )

        line_index = table_end

    return findings


def fix_text(text: str) -> tuple[str, list[dict[str, object]]]:
    """Escape only reported pipes, processing source offsets from right to left."""
    findings = scan_text(text)
    if not findings:
        return text, findings

    lines = text.splitlines(keepends=True)
    offsets_by_line: dict[int, list[int]] = {}
    for finding in findings:
        offsets_by_line.setdefault(int(finding["line"]), []).append(
            int(finding["column"]) - 1
        )

    for line_number, offsets in offsets_by_line.items():
        line_index = line_number - 1
        line = lines[line_index]
        for offset in sorted(offsets, reverse=True):
            line = line[:offset] + "\\" + line[offset:]
        lines[line_index] = line

    return "".join(lines), findings


def _read_text(path: Path) -> str:
    with path.open("r", encoding="utf-8", newline="") as source_file:
        return source_file.read()


def _write_text(path: Path, text: str) -> None:
    with path.open("w", encoding="utf-8", newline="") as destination_file:
        destination_file.write(text)


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
        candidate = path if path.is_absolute() else WORKSPACE_ROOT / path
        candidate = candidate.resolve()
        if candidate.suffix != ".md" or not candidate.is_file():
            raise FileNotFoundError(f"Markdown file not found: {candidate}")
        if not candidate.is_relative_to(root):
            raise ValueError(f"Selected Markdown file is outside --root: {candidate}")
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
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument(
        "--fix",
        action="store_true",
        help="escape detected pipes in place, then verify the files are clean",
    )
    args = parser.parse_args(argv)

    root = args.root.resolve()
    report_path = args.report.resolve()
    if not root.is_dir():
        parser.error(f"Markdown root is not a directory: {root}")

    try:
        paths = list(_selected_files(root, args.file))
    except (FileNotFoundError, ValueError) as error:
        parser.error(str(error))

    report_path.parent.mkdir(parents=True, exist_ok=True, mode=0o1777)
    if report_path.parent.name == ".tmp":
        report_path.parent.chmod(0o1777)

    findings: list[dict[str, object]] = []
    fixed_files = 0
    for path in paths:
        original = _read_text(path)
        relative_path = (
            path.relative_to(WORKSPACE_ROOT).as_posix()
            if path.is_relative_to(WORKSPACE_ROOT)
            else path.as_posix()
        )
        file_findings = scan_text(original, relative_path)
        findings.extend(file_findings)
        if args.fix and file_findings:
            corrected, _ = fix_text(original)
            _write_text(path, corrected)
            fixed_files += 1

    remaining: list[dict[str, object]] = []
    if args.fix:
        for path in paths:
            relative_path = (
                path.relative_to(WORKSPACE_ROOT).as_posix()
                if path.is_relative_to(WORKSPACE_ROOT)
                else path.as_posix()
            )
            remaining.extend(scan_text(_read_text(path), relative_path))

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
            f"Escaped {len(findings) - len(remaining)} pipe(s) in {fixed_files} file(s); "
            f"{len(remaining)} finding(s) remain."
        )
    else:
        print(f"Found {len(findings)} unescaped math pipe(s) in table rows.")
    print(f"Report: {report_path}")
    return 1 if remaining else 0


if __name__ == "__main__":
    raise SystemExit(main())