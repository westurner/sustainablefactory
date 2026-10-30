from tools.fix_markdown_table_math_pipes import fix_text, scan_text


def test_finds_unescaped_pipe_inside_inline_math_on_table_row():
    text = "| Quantity | Expression |\n| --- | --- |\n| 1 | $x | y$ |\n"

    findings = scan_text(text, "fixture.md")

    assert findings == [
        {
            "file": "fixture.md",
            "line": 3,
            "column": 10,
            "expression": "x | y",
            "pipe": "|",
        }
    ]


def test_ignores_outside_math_escaped_pipes_and_code_fences():
    text = (
        "| Header | Math |\n"
        "| --- | --- |\n"
        "| prose | $x+y$ |\n"
        "| prose | $x \\| y$ |\n"
        "```markdown\n"
        "| code | $x | y$ |\n"
        "```\n"
    )

    assert scan_text(text) == []


def test_ignores_currency_spans_but_finds_plain_absolute_value_math():
    text = (
        "| Label | Cost A | Cost B |\n"
        "| --- | --- | --- |\n"
        "| Tool Cost | ~$380 Million per machine. | ~$5-10 Million per tool. |\n"
        "| Material Cost | $4,000+ per gallon | $1-5 per kg |\n"
        "| Unit Cost | $400/kg | $15/kg |\n"
        "| Math | $|x|$ | Text |\n"
    )

    findings = scan_text(text)

    assert len(findings) == 2
    assert {finding["expression"] for finding in findings} == {"|x|"}


def test_fixes_only_unescaped_math_pipes_in_table_rows():
    text = (
        "Paragraph: $x | y$.\n"
        "| A | Left | Right |\n"
        "| --- | --- | --- |\n"
        "| A | $x | y$ | $u \\\\| v$ |\n"
        "```markdown\n"
        "| code | $p | q$ |\n"
        "```\n"
    )

    fixed, findings = fix_text(text)

    assert len(findings) == 2
    assert fixed == (
        "Paragraph: $x | y$.\n"
        "| A | Left | Right |\n"
        "| --- | --- | --- |\n"
        "| A | $x \\| y$ | $u \\\\\\| v$ |\n"
        "```markdown\n"
        "| code | $p | q$ |\n"
        "```\n"
    )
    assert scan_text(fixed) == []


def test_does_not_flag_currency_pipes_that_match_table_columns():
    text = (
        "| Item | Cost A | Cost B |\n"
        "| --- | --- | --- |\n"
        "| Lens | $500 | <$1.00 |\n"
        "| Wafer | $2,000 per wafer ($^{28}$Si) | **$45 per roll** |\n"
    )

    assert scan_text(text) == []