#!/usr/bin/env python3
"""Convert warned author-year fragment links to verified MyST BibTeX citations."""

from __future__ import annotations

import argparse
import json
import re
from bisect import bisect_right
from pathlib import Path
from typing import Any


WORKSPACE_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DOCS_ROOT = WORKSPACE_ROOT / "docs"
DEFAULT_LOG = WORKSPACE_ROOT / ".tmp" / "sphinx-build.log"
DEFAULT_REPORT = WORKSPACE_ROOT / ".tmp" / "sphinx-bibtex-citation-fixes.json"
DEFAULT_ALIASES = DEFAULT_DOCS_ROOT / "bibtex-key-aliases.json"
DEFAULT_BIBFILES = [DEFAULT_DOCS_ROOT / "citations.bib"]

WARNING = re.compile(
    r"^(?P<source>.+\.md):(?P<line>\d*):\s*WARNING:.*?"
    r"cross-reference target not found:\s*['\"](?P<target>[^'\"]+)['\"].*"
    r"\[myst\.xref_missing\]"
)
LINK = re.compile(r"\[(?P<label>[^\]]+)\]\(#(?P<target>[^)]+)\)", re.DOTALL)
GROUP = re.compile(r"\((?P<body>(?:\s*\[[^\]]+\]\(#[^)]+\)\s*,?)+)\)", re.DOTALL)
FENCE_START = re.compile(r"^\s*(`{3,}|~{3,})")
YEAR = re.compile(r"\b(?:18|19|20|21)\d{2}\b")
INLINE_CODE = re.compile(r"(?<!`)`+[^`\n]*?`+(?!`)")


def parse_warnings(log_text: str) -> list[dict[str, Any]]:
    """Extract MyST missing-target warnings from a Sphinx log."""
    warnings: list[dict[str, Any]] = []
    for log_line, line in enumerate(log_text.splitlines(), start=1):
        match = WARNING.match(line)
        if not match:
            continue
        source_line = match.group("line")
        warnings.append(
            {
                "source": match.group("source"),
                "source_line": int(source_line) if source_line else None,
                "target": match.group("target"),
                "log_line": log_line,
            }
        )
    return warnings


def _fenced_ranges(text: str) -> list[tuple[int, int]]:
    lines = text.splitlines(keepends=True)
    ranges: list[tuple[int, int]] = []
    offset = 0
    open_start: int | None = None
    fence_character: str | None = None
    fence_length = 0

    for line in lines:
        match = FENCE_START.match(line)
        if match:
            marker = match.group(1)
            if fence_character is None:
                open_start = offset
                fence_character = marker[0]
                fence_length = len(marker)
            elif marker[0] == fence_character and len(marker) >= fence_length:
                ranges.append((open_start if open_start is not None else offset, offset + len(line)))
                open_start = None
                fence_character = None
                fence_length = 0
        offset += len(line)

    if open_start is not None:
        ranges.append((open_start, len(text)))
    return ranges


def _overlaps(start: int, end: int, ranges: list[tuple[int, int]]) -> bool:
    return any(start < range_end and range_start < end for range_start, range_end in ranges)


def _citation_key(target: str, bib_keys: set[str], aliases: dict[str, str]) -> str | None:
    key = aliases.get(target, target)
    return key if key in bib_keys else None


def fix_text(
    text: str,
    warned_targets: set[str],
    bib_keys: set[str],
    aliases: dict[str, str],
    role: str = "p",
    relative_path: str = "<text>",
) -> tuple[str, list[dict[str, Any]]]:
    """Rewrite only warned local author-year links backed by a BibTeX entry."""
    fenced_ranges = _fenced_ranges(text)
    code_ranges = [match.span() for match in INLINE_CODE.finditer(text)]
    line_offsets = [0]
    line_offsets.extend(match.end() for match in re.finditer("\n", text))
    links_by_target: dict[str, list[re.Match[str]]] = {}
    eligible: dict[int, tuple[re.Match[str], str]] = {}
    findings: list[dict[str, Any]] = []

    for match in LINK.finditer(text):
        target = match.group("target")
        if target not in warned_targets:
            continue
        if _overlaps(*match.span(), fenced_ranges) or _overlaps(*match.span(), code_ranges):
            continue
        links_by_target.setdefault(target, []).append(match)
        label = " ".join(match.group("label").split())
        if not YEAR.search(label):
            findings.append(
                {
                    "file": relative_path,
                    "target": target,
                    "status": "not-author-year-link",
                    "label": label,
                }
            )
            continue
        key = _citation_key(target, bib_keys, aliases)
        if key is None:
            findings.append(
                {
                    "file": relative_path,
                    "target": target,
                    "status": "missing-bibtex-key",
                    "label": label,
                    "suggested_key": aliases.get(target, target),
                }
            )
            continue
        eligible[match.start()] = (match, key)
        line = bisect_right(line_offsets, match.start())
        findings.append(
            {
                "file": relative_path,
                "line": line,
                "target": target,
                "bibtex_key": key,
                "status": "ready-to-fix",
            }
        )

    for target in sorted(warned_targets):
        if target not in links_by_target:
            findings.append(
                {
                    "file": relative_path,
                    "target": target,
                    "status": "no-local-fragment-link",
                }
            )

    replacements: list[tuple[int, int, str]] = []
    grouped_links: set[int] = set()
    for group in GROUP.finditer(text):
        if _overlaps(*group.span(), fenced_ranges) or _overlaps(*group.span(), code_ranges):
            continue
        body = group.group("body")
        group_links = list(LINK.finditer(body))
        if not group_links:
            continue
        keys: list[str] = []
        all_eligible = True
        previous_end = 0
        for body_link in group_links:
            gap = body[previous_end : body_link.start()]
            if gap.strip(" \t\r\n,"):
                all_eligible = False
                break
            absolute_start = group.start("body") + body_link.start()
            eligible_link = eligible.get(absolute_start)
            if eligible_link is None:
                all_eligible = False
                break
            keys.append(eligible_link[1])
            grouped_links.add(absolute_start)
            previous_end = body_link.end()
        if not all_eligible or body[previous_end:].strip(" \t\r\n,"):
            continue
        replacements.append(
            (group.start(), group.end(), f"{{cite:{role}}}`{','.join(keys)}`")
        )

    for start, (match, key) in eligible.items():
        if start not in grouped_links:
            replacements.append(
                (match.start(), match.end(), f"{{cite:{role}}}`{key}`")
            )

    fixed_text = text
    for start, end, replacement in sorted(replacements, reverse=True):
        fixed_text = fixed_text[:start] + replacement + fixed_text[end:]

    return fixed_text, findings


def _load_bib_keys(paths: list[Path]) -> set[str]:
    try:
        from pybtex.database import parse_file
    except ImportError as error:
        raise RuntimeError(
            "pybtex is required to parse BibTeX files; install the docs requirements"
        ) from error
    keys: set[str] = set()
    for path in paths:
        database = parse_file(str(path), bib_format="bibtex")
        keys.update(database.entries)
    return keys


def _resolve_path(path: Path) -> Path:
    return path.resolve() if path.is_absolute() else (WORKSPACE_ROOT / path).resolve()


def _load_aliases(path: Path) -> dict[str, str]:
    if not path.is_file():
        return {}
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict) or not all(
        isinstance(alias, str) and isinstance(key, str)
        for alias, key in value.items()
    ):
        raise ValueError(f"Expected a JSON object of citation aliases in {path}")
    return value


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--log", type=Path, default=DEFAULT_LOG)
    parser.add_argument("--docs-root", type=Path, default=DEFAULT_DOCS_ROOT)
    parser.add_argument("--bib", type=Path, action="append", help="BibTeX file; repeatable")
    parser.add_argument("--aliases", type=Path, default=DEFAULT_ALIASES)
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument("--role", choices=("p", "t"), default="p")
    parser.add_argument(
        "--fix",
        action="store_true",
        help="write verified citation-role replacements in place",
    )
    args = parser.parse_args(argv)

    log_path = _resolve_path(args.log)
    root = _resolve_path(args.docs_root)
    bib_files = [_resolve_path(path) for path in (args.bib or DEFAULT_BIBFILES)]
    aliases_path = _resolve_path(args.aliases)
    report_path = _resolve_path(args.report)
    if not log_path.is_file():
        parser.error(f"Sphinx log not found: {log_path}")
    if not root.is_dir():
        parser.error(f"Documentation root not found: {root}")
    missing_bibs = [path for path in bib_files if not path.is_file()]
    if missing_bibs:
        parser.error("BibTeX file(s) not found: " + ", ".join(map(str, missing_bibs)))

    try:
        bib_keys = _load_bib_keys(bib_files)
        aliases = _load_aliases(aliases_path)
    except (RuntimeError, ValueError, OSError) as error:
        parser.error(str(error))

    warnings = parse_warnings(log_path.read_text(encoding="utf-8", errors="replace"))
    warnings_by_file: dict[Path, set[str]] = {}
    skipped_warnings: list[dict[str, Any]] = []
    for warning in warnings:
        source = Path(warning["source"])
        source = source.resolve() if source.is_absolute() else (WORKSPACE_ROOT / source).resolve()
        if not source.is_relative_to(root) or not source.is_file():
            skipped_warnings.append({**warning, "status": "source-outside-docs-root"})
            continue
        warnings_by_file.setdefault(source, set()).add(warning["target"])

    findings: list[dict[str, Any]] = []
    changed_files = 0
    for source, targets in sorted(warnings_by_file.items()):
        relative = source.relative_to(WORKSPACE_ROOT).as_posix() if source.is_relative_to(WORKSPACE_ROOT) else source.as_posix()
        original = source.read_text(encoding="utf-8")
        corrected, file_findings = fix_text(
            original, targets, bib_keys, aliases, args.role, relative
        )
        if args.fix and corrected != original:
            source.write_text(corrected, encoding="utf-8")
            changed_files += 1
            for finding in file_findings:
                if finding["status"] == "ready-to-fix":
                    finding["status"] = "converted"
        findings.extend(file_findings)
    findings.extend(skipped_warnings)

    report = {
        "log": log_path.as_posix(),
        "bib_files": [path.as_posix() for path in bib_files],
        "fixed": args.fix,
        "role": args.role,
        "changed_files": changed_files,
        "findings": findings,
        "warning_count": len(warnings),
        "citation_conversions": sum(
            finding["status"] in {"ready-to-fix", "converted"}
            for finding in findings
        ),
        "unresolved_citation_keys": sum(
            finding["status"] == "missing-bibtex-key" for finding in findings
        ),
    }
    report_path.parent.mkdir(parents=True, exist_ok=True, mode=0o1777)
    if report_path.parent.name == ".tmp":
        report_path.parent.chmod(0o1777)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    convertible_files = {
        finding["file"]
        for finding in findings
        if finding.get("status") in {"ready-to-fix", "converted"}
    }
    verb = "Converted" if args.fix else "Can convert"
    print(
        f"{verb} {report['citation_conversions']} citation link(s) across "
        f"{changed_files if args.fix else len(convertible_files)} file(s); "
        f"{report['unresolved_citation_keys']} citation(s) need a verified BibTeX key."
    )
    print(f"Report: {report_path}")
    return 1 if report["unresolved_citation_keys"] else 0


if __name__ == "__main__":
    raise SystemExit(main())