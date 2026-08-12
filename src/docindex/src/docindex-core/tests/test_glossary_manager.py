"""Tests for GlossaryManager."""

from __future__ import annotations

from pathlib import Path

import pytest
import yaml

from docindex_core.glossary_manager import GlossaryManager, _GENERATED_MARKER


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

MINIMAL_DATA = {
    "categories": {
        "materials": "Materials & Chemistry",
        "formats": "Formats",
    },
    "terms": {
        "CNT": {
            "definition": "Carbon nanotube — a cylindrical nanostructure.",
            "synonyms": ["carbon nanotube", "carbon nanotubes"],
            "category": "materials",
            "related": ["Lignin"],
        },
        "Lignin": {
            "definition": "A complex aromatic polymer found in plant cell walls.",
            "category": "materials",
        },
        "MyST": {
            "definition": "Markedly Structured Text — a Markdown dialect.",
            "synonyms": ["myst markdown"],
            "category": "formats",
        },
    },
}


def _write_yaml(tmp_path: Path, data: dict) -> Path:
    p = tmp_path / "glossary.yaml"
    with open(p, "w") as fh:
        yaml.dump(data, fh)
    return p


# ---------------------------------------------------------------------------
# load
# ---------------------------------------------------------------------------

def test_load_returns_expected_structure(tmp_path):
    p = _write_yaml(tmp_path, MINIMAL_DATA)
    data = GlossaryManager.load(p)
    assert "terms" in data
    assert "categories" in data
    assert "CNT" in data["terms"]


def test_load_raises_on_missing_file(tmp_path):
    with pytest.raises(FileNotFoundError):
        GlossaryManager.load(tmp_path / "nonexistent.yaml")


def test_load_raises_on_bad_yaml(tmp_path):
    p = tmp_path / "bad.yaml"
    p.write_text("key: [unclosed bracket\n")
    with pytest.raises(ValueError, match="Failed to parse"):
        GlossaryManager.load(p)


def test_load_adds_empty_terms_if_missing(tmp_path):
    p = tmp_path / "g.yaml"
    p.write_text("categories:\n  x: X\n")
    data = GlossaryManager.load(p)
    assert data["terms"] == {}


# ---------------------------------------------------------------------------
# save
# ---------------------------------------------------------------------------

def test_save_round_trips(tmp_path):
    p = _write_yaml(tmp_path, MINIMAL_DATA)
    data = GlossaryManager.load(p)
    out = tmp_path / "out.yaml"
    GlossaryManager.save(data, out)
    loaded = GlossaryManager.load(out)
    assert set(loaded["terms"].keys()) == {"CNT", "Lignin", "MyST"}


# ---------------------------------------------------------------------------
# to_myst
# ---------------------------------------------------------------------------

def test_to_myst_contains_generated_marker():
    myst = GlossaryManager.to_myst(MINIMAL_DATA)
    assert _GENERATED_MARKER in myst


def test_to_myst_contains_all_terms():
    myst = GlossaryManager.to_myst(MINIMAL_DATA)
    assert "CNT" in myst
    assert "Lignin" in myst
    assert "MyST" in myst


def test_to_myst_contains_definitions():
    myst = GlossaryManager.to_myst(MINIMAL_DATA)
    assert "Carbon nanotube" in myst
    assert "Markedly Structured Text" in myst


def test_to_myst_includes_synonyms_note():
    myst = GlossaryManager.to_myst(MINIMAL_DATA)
    assert "Also known as" in myst
    assert "*carbon nanotube*" in myst


def test_to_myst_includes_see_also():
    myst = GlossaryManager.to_myst(MINIMAL_DATA)
    assert "See also" in myst
    assert "{term}`Lignin`" in myst


def test_to_myst_uses_category_sections():
    myst = GlossaryManager.to_myst(MINIMAL_DATA)
    assert "## Materials & Chemistry" in myst
    assert "## Formats" in myst


def test_to_myst_contains_glossary_fence():
    myst = GlossaryManager.to_myst(MINIMAL_DATA)
    assert "```{glossary}" in myst


def test_to_myst_custom_label_and_title():
    myst = GlossaryManager.to_myst(MINIMAL_DATA, label="mygloss", title="My Glossary")
    assert "(mygloss)=" in myst
    assert "# My Glossary" in myst


def test_to_myst_skips_terms_without_definition():
    data = {
        "categories": {},
        "terms": {
            "Empty": {},
            "Full": {"definition": "Has a definition."},
        },
    }
    myst = GlossaryManager.to_myst(data)
    assert "Full" in myst
    assert "Empty" not in myst


# ---------------------------------------------------------------------------
# write_myst_if_changed
# ---------------------------------------------------------------------------

def test_write_myst_if_changed_creates_file(tmp_path):
    out = tmp_path / "glossary.md"
    changed = GlossaryManager.write_myst_if_changed(MINIMAL_DATA, out)
    assert changed is True
    assert out.exists()


def test_write_myst_if_changed_returns_false_on_identical(tmp_path):
    out = tmp_path / "glossary.md"
    GlossaryManager.write_myst_if_changed(MINIMAL_DATA, out)
    changed = GlossaryManager.write_myst_if_changed(MINIMAL_DATA, out)
    assert changed is False


def test_write_myst_if_changed_updates_on_new_term(tmp_path):
    out = tmp_path / "glossary.md"
    GlossaryManager.write_myst_if_changed(MINIMAL_DATA, out)
    import copy
    data2 = copy.deepcopy(MINIMAL_DATA)
    data2["terms"]["NewTerm"] = {"definition": "A brand new term."}
    changed = GlossaryManager.write_myst_if_changed(data2, out)
    assert changed is True


# ---------------------------------------------------------------------------
# merge_synonyms
# ---------------------------------------------------------------------------

def test_merge_synonyms_adds_to_existing_term():
    synonyms = {"cnt": ["mwcnt", "swcnt"]}
    result = GlossaryManager.merge_synonyms(MINIMAL_DATA, synonyms)
    cnt_syns = result["terms"]["CNT"]["synonyms"]
    assert "mwcnt" in cnt_syns
    assert "swcnt" in cnt_syns


def test_merge_synonyms_does_not_mutate_input():
    synonyms = {"cnt": ["mwcnt"]}
    GlossaryManager.merge_synonyms(MINIMAL_DATA, synonyms)
    assert "mwcnt" not in MINIMAL_DATA["terms"]["CNT"].get("synonyms", [])


def test_merge_synonyms_skips_unmatched_keys():
    synonyms = {"unknown_term_xyz": ["alias"]}
    result = GlossaryManager.merge_synonyms(MINIMAL_DATA, synonyms)
    assert "unknown_term_xyz" not in result["terms"]


def test_merge_synonyms_case_insensitive_match():
    synonyms = {"myst": ["mysT markdown extra"]}
    result = GlossaryManager.merge_synonyms(MINIMAL_DATA, synonyms)
    assert "mysT markdown extra" in result["terms"]["MyST"]["synonyms"]


# ---------------------------------------------------------------------------
# extract_synonyms
# ---------------------------------------------------------------------------

def test_extract_synonyms_returns_dict():
    result = GlossaryManager.extract_synonyms(MINIMAL_DATA)
    assert "cnt" in result
    assert "carbon nanotube" in result["cnt"]


def test_extract_synonyms_skips_terms_without_synonyms():
    result = GlossaryManager.extract_synonyms(MINIMAL_DATA)
    assert "lignin" not in result  # Lignin has no synonyms in MINIMAL_DATA


def test_extract_synonyms_lowercases_keys():
    result = GlossaryManager.extract_synonyms(MINIMAL_DATA)
    assert all(k == k.lower() for k in result)


# ---------------------------------------------------------------------------
# export-synonyms workflow (extract + merge/save round-trip)
# ---------------------------------------------------------------------------

def test_export_synonyms_merge_adds_new_entries(tmp_path):
    """Glossary extract merged into an existing synonyms file gains new keys."""
    from docindex_core.synonyms_manager import SynonymsManager

    existing_syns = {"lca": ["life cycle assessment"]}
    syn_path = tmp_path / "synonyms.yaml"
    SynonymsManager.save(existing_syns, syn_path)

    extracted = GlossaryManager.extract_synonyms(MINIMAL_DATA)
    merged = SynonymsManager.merge(existing_syns, extracted)
    SynonymsManager.save(merged, syn_path)

    reloaded = SynonymsManager.load(syn_path)
    assert "lca" in reloaded          # original preserved
    assert "cnt" in reloaded          # from glossary
    assert "myst" in reloaded         # from glossary
    assert "carbon nanotube" in reloaded["cnt"]


def test_export_synonyms_replace_discards_non_glossary_entries(tmp_path):
    """Replace mode: only glossary-defined synonyms survive."""
    from docindex_core.synonyms_manager import SynonymsManager

    existing_syns = {"lca": ["life cycle assessment"], "cnt": ["nanotube"]}
    syn_path = tmp_path / "synonyms.yaml"
    SynonymsManager.save(existing_syns, syn_path)

    extracted = GlossaryManager.extract_synonyms(MINIMAL_DATA)
    # Replace mode: save extracted directly without merging
    SynonymsManager.save(extracted, syn_path)

    reloaded = SynonymsManager.load(syn_path)
    assert "lca" not in reloaded      # not in glossary, so gone
    assert "cnt" in reloaded          # glossary has CNT synonyms


def test_export_synonyms_idempotent(tmp_path):
    """Running export twice produces the same result as running once."""
    from docindex_core.synonyms_manager import SynonymsManager

    syn_path = tmp_path / "synonyms.yaml"
    extracted = GlossaryManager.extract_synonyms(MINIMAL_DATA)

    SynonymsManager.save(extracted, syn_path)
    first = SynonymsManager.load(syn_path)

    # Merge again (simulates running export-synonyms --mode merge twice)
    merged = SynonymsManager.merge(first, extracted)
    SynonymsManager.save(merged, syn_path)
    second = SynonymsManager.load(syn_path)

    assert first == second


def test_generate_glossary_export_synonyms_flag_writes_synonyms(tmp_path):
    """generate-glossary with --export-synonyms updates the synonyms file."""
    from docindex_core.synonyms_manager import SynonymsManager

    glossary_yaml = tmp_path / "glossary.yaml"
    import yaml as _yaml
    with open(glossary_yaml, "w") as fh:
        _yaml.dump(MINIMAL_DATA, fh)

    data = GlossaryManager.load(glossary_yaml)
    output_md = tmp_path / "glossary.md"
    GlossaryManager.write_myst_if_changed(data, output_md, source_path=glossary_yaml)

    # Simulate --export-synonyms: extract + merge + save
    syn_path = tmp_path / "synonyms.yaml"
    extracted = GlossaryManager.extract_synonyms(data)
    existing = SynonymsManager.load(syn_path)  # empty (file missing)
    SynonymsManager.save(SynonymsManager.merge(existing, extracted), syn_path)

    reloaded = SynonymsManager.load(syn_path)
    assert "cnt" in reloaded
    assert "myst" in reloaded


def test_glossary_manager_malformed_entries(tmp_path):
    import yaml as _yaml
    bad_yaml = tmp_path / "bad_glossary.yaml"
    # YAML with no categories, and terms with string value instead of dict
    with open(bad_yaml, "w") as fh:
        _yaml.dump({
            "terms": {
                "CNT": "this is a string, not a dict",
                "Lignin": {"definition": "real definition"}
            }
        }, fh)
    
    data = GlossaryManager.load(bad_yaml)
    assert data["categories"] == {}
    
    # Try merging synonyms
    merged = GlossaryManager.merge_synonyms(data, {"cnt": ["nano"]})
    assert merged["terms"]["CNT"] == "this is a string, not a dict"
    
    # Try generating myst
    myst = GlossaryManager.to_myst(data)
    assert "real definition" in myst
    
    # Try extracting synonyms
    syns = GlossaryManager.extract_synonyms(data)
    assert "cnt" not in syns


