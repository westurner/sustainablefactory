from tools.fix_markdown_display_math_spacing import fix_text, scan_text


def test_finds_display_math_adjacent_to_list_prose():
    text = "1. Uses\n   $$\n   x^2\n   $$\n   and continues.\n"

    assert scan_text(text, "fixture.md") == [
        {
            "kind": "standalone-display-block",
            "file": "fixture.md",
            "open_line": 2,
            "close_line": 4,
            "missing_blank_before": True,
            "missing_blank_after": True,
            "math": "x^2",
        }
    ]


def test_ignores_well_spaced_blocks_and_fenced_examples():
    text = (
        "Text before.\n\n$$\nx^2\n$$\n\nText after.\n"
        "```markdown\n$$\nx^2\n$$\n```\n"
    )

    assert scan_text(text) == []


def test_fixes_missing_spacing_and_is_idempotent():
    text = "1. Uses\n   $$\n   x^2\n   $$\n   and continues.\n"

    fixed, findings = fix_text(text)

    assert len(findings) == 1
    assert fixed == "1. Uses\n\n   $$\n   x^2\n   $$\n\n   and continues.\n"
    assert scan_text(fixed) == []
    assert fix_text(fixed) == (fixed, [])


def test_finds_and_splits_same_line_display_math_with_surrounding_prose():
    equation = r"\operatorname{qdet}_L(T(u),T(u-\eta)) = \operatorname{qdet}_R(T(u),T(u-\eta))"
    text = f"- **Law**: before $${equation}$$ after.\n"

    findings = scan_text(text, "fixture.md")
    fixed, applied = fix_text(text)

    assert len(findings) == 1
    assert findings[0]["kind"] == "inline-display-math"
    assert findings[0]["math"] == equation
    assert applied == scan_text(text)
    assert fixed == f"- **Law**: before\n\n  $$\n  {equation}\n  $$\n\n  after.\n"
    assert scan_text(fixed) == []


def test_ignores_short_same_line_math_tokens_by_default():
    assert scan_text("- Value: $$x^2$$\n") == []


def test_ignores_same_line_display_delimiters_in_inline_code_and_tables():
    text = (
        "Inline code `$$x^2$$` remains literal.\n"
        "| Math | $$x^2$$ |\n"
    )

    assert scan_text(text) == []