from tools.fix_sphinx_bibtex_citations import fix_text, parse_warnings


def test_parse_myst_missing_target_warnings_with_and_without_source_line():
    log = "\n".join(
        [
            "docs/example.md:27: WARNING: 'myst' cross-reference target not found: 'old-key' [myst.xref_missing]",
            "docs/other.md:: WARNING: 'myst' cross-reference target not found: 'other-key' [myst.xref_missing]",
            "docs/example.md:8: WARNING: Unknown source document 'data/chat' [myst.xref_missing]",
        ]
    )

    warnings = parse_warnings(log)

    assert warnings == [
        {
            "source": "docs/example.md",
            "source_line": 27,
            "target": "old-key",
            "log_line": 1,
        },
        {
            "source": "docs/other.md",
            "source_line": None,
            "target": "other-key",
            "log_line": 2,
        },
    ]


def test_convert_verified_parenthetical_citation_group_and_leave_heading_link():
    source = (
        "References ([Kolda and Bader 2009](#kolda2009), "
        "[Carusotto et al. 2008](#carusotto2008)); see [Methods](#methods).\n"
    )

    corrected, findings = fix_text(
        source,
        {"kolda2009", "carusotto2008", "methods"},
        {"kolda2009", "carusotto2008"},
        {},
    )

    assert corrected == (
        "References {cite:p}`kolda2009,carusotto2008`; "
        "see [Methods](#methods).\n"
    )
    assert sum(item["status"] == "ready-to-fix" for item in findings) == 2
    assert any(item["status"] == "not-author-year-link" for item in findings)


def test_convert_author_year_link_inside_mixed_parenthetical_group():
    source = "([Author et al. 2020](#paper), [Methods](#methods))\n"

    corrected, _ = fix_text(source, {"paper", "methods"}, {"paper"}, {})

    assert corrected == "({cite:p}`paper`, [Methods](#methods))\n"


def test_require_alias_and_bibtex_entry_before_rewriting():
    source = "[Wan et al. 2018](#wan2018)\n[Missing et al. 2020](#missing2020)\n"

    corrected, findings = fix_text(
        source,
        {"wan2018", "missing2020"},
        {"wan2018laser"},
        {"wan2018": "wan2018laser"},
    )

    assert corrected == "{cite:p}`wan2018laser`\n[Missing et al. 2020](#missing2020)\n"
    assert any(item["status"] == "missing-bibtex-key" for item in findings)