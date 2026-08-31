"""
Docstring for tests.test_parser
"""

from textwrap import dedent
from sustainablefactory.parser import (
    parse_markdown_tables,
    ProcessStep,
    parse_and_extract_from_markdown,
    parse_cost_figures,
    parse_latex_math,
    parse_performance_metrics,
    parse_equipment_and_tools,
    parse_materials_and_chemicals,
    parse_citations_and_sources,
)


def test_parse_cost_figures():
    text = """
    Price is $10.50 per kg.
    A credit of -$5.00 was applied.
    Market price is 45 USD.
    It costs 50 cents.
    The goal is $10/kg.
    Ignore $abc.
    """
    figures = parse_cost_figures(text)
    assert "$10.50" in figures
    assert "-$5.00" in figures
    assert "45 USD" in figures
    assert "50 cents" in figures
    assert "$10/kg" in figures


def test_parse_latex_math():
    text = """
    Inline math $E=mc^2$ and block math:
    $$
    a^2 + b^2 = c^2
    $$
    Price is $10 (should be ignored by math parser).
    """
    math = parse_latex_math(text)
    assert "$E=mc^2$" in math
    assert "$$\n    a^2 + b^2 = c^2\n    $$" in math
    assert "$10$" not in math


def test_parse_markdown_tables():
    text = """
| Header 1 | Header 2 |
| --- | --- |
| Val 1 | Val 2 |
| Val 3 | Val 4 |
"""
    tables = parse_markdown_tables(text)
    assert len(tables) == 1
    assert tables[0]["headers"] == ["Header 1", "Header 2"]
    assert len(tables[0]["rows"]) == 2
    assert tables[0]["rows"][0]["Header 1"] == "Val 1"


def test_process_step_init():
    step = ProcessStep("id1", "Label 1")
    assert step.id == "id1"
    assert step.label == "Label 1"
    assert step.inputs == []
    assert step.next_steps == []


def test_parse_myst_paper_comprehensive(tmp_path):
    p = tmp_path / "comprehensive.md"
    p.write_text(
        dedent(
            """
        ## Phase 1: Heat Treatment
        * **Temperature**: 500C
        * **Duration**: 2h
        * Precursor A

        ### Key Outputs: Refined Material
        * Material B

        Code snippet:
            graph TD
            P1["Phase 1: Heat Treatment"] --> P2["Phase 2: Stretching"]

        ```mermaid
        graph LR
            P2 --> P3["Phase 3: Final"]
        ```
    """
        ).strip()
    )
    steps = parse_and_extract_from_markdown(str(p))

    # Check Phase 1
    p1 = next((s for s in steps if s.id == "Phase_1"), None)
    assert p1 is not None
    assert p1.properties["temperature"] == "500C"

    # Mermaid nodes
    assert any(s.id == "P1" for s in steps)
    assert any(s.id == "P2" for s in steps)
    assert any(s.id == "P3" for s in steps)

    # Check Mermaid edges (P1 -> P2, P2 -> P3)
    p1_nodes = [s for s in steps if s.id == "P1"]
    assert "P2" in p1_nodes[0].next_steps

    p2_nodes = [s for s in steps if s.id == "P2"]
    assert "P3" in p2_nodes[0].next_steps


def test_parse_json_chat(tmp_path):
    import json

    p = tmp_path / "chat.json"
    data = {
        "messages": [
            {"content": "## Step 1: Boiling\nIt cost $15."},
            {"content": "| H1 | H2 |\n|---|---|\n| V1 | V2 |"},
        ]
    }
    p.write_text(json.dumps(data))

    steps = parse_and_extract_from_markdown(str(p))
    # Should find Step 1 and the File Summary
    assert any(s.label == "Boiling" for s in steps)
    summary = next(s for s in steps if s.id == "File_Summary")
    assert "$15" in summary.cost_figures
    assert len(summary.tables) == 1


def test_file_summary_aggregation_fixed(tmp_path):
    from textwrap import dedent

    p = tmp_path / "summary_fixed.md"
    p.write_text(
        dedent(
            """
        This is a file with $10/kg cost outside any section.

        | Table 1 |
        | --- |
        | Row 1 |

        ## Section 1
        $20/kg here.

        | Table 2 |
        | --- |
        | Row 2 |
    """
        ).strip()
    )

    steps = parse_and_extract_from_markdown(str(p))
    summary = next(s for s in steps if s.id == "File_Summary")

    # Costs should be aggregated
    assert "$10/kg" in summary.cost_figures
    assert "$20/kg" in summary.cost_figures


def test_metrics_extraction():
    text = "Efficiency of the motor is 95% at 50 bar pressure. Magnet strength 20 MGOe."
    metrics = parse_performance_metrics(text)
    assert "95%" in metrics
    assert "50 bar" in metrics
    assert "20 MGOe" in metrics


def test_material_extraction():
    text = "We use Fe16N2 for the magnets and CNT for cables. Also Fe-N."
    materials = parse_materials_and_chemicals(text)
    assert "Fe16N2" in materials
    assert "CNT" in materials
    assert "Fe-N" in materials


def test_equipment_extraction():
    text = "Uses a Sonic Razor and an Induction Furnace. Maybe a CVD reactor."
    equipment = parse_equipment_and_tools(text)
    assert "Sonic Razor" in equipment
    assert "Induction Furnace" in equipment
    assert "CVD Reactor" in equipment


def test_citation_extraction():
    text = "Source: https://example.com/paper.pdf and doi:10.1000/123"
    citations = parse_citations_and_sources(text)
    assert "https://example.com/paper.pdf" in citations
    assert "doi:10.1000/123" in citations
