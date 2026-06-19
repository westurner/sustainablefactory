"""Tests for SynonymsManager."""

from __future__ import annotations

import textwrap
from pathlib import Path

import pytest
import yaml

from docindex_core.synonyms_manager import SynonymsManager
from docindex_core.config import DEFAULT_INDEX_SETTINGS


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _write_yaml(tmp_path: Path, data: dict) -> Path:
    p = tmp_path / "synonyms.yaml"
    p.write_text(yaml.dump(data))
    return p


# ---------------------------------------------------------------------------
# load
# ---------------------------------------------------------------------------

def test_load_returns_dict_from_yaml(tmp_path):
    p = _write_yaml(tmp_path, {"cnt": ["carbon nanotube", "carbon nanotubes"]})
    result = SynonymsManager.load(p)
    assert result == {"cnt": ["carbon nanotube", "carbon nanotubes"]}


def test_load_missing_file_returns_empty(tmp_path):
    result = SynonymsManager.load(tmp_path / "nonexistent.yaml")
    assert result == {}


def test_load_strips_non_list_entries(tmp_path):
    p = tmp_path / "s.yaml"
    p.write_text("cnt:\n  - nanotube\nbad_key: not_a_list\n")
    result = SynonymsManager.load(p)
    assert "bad_key" not in result
    assert "cnt" in result


def test_load_bundled_yaml_contains_known_terms():
    result = SynonymsManager.load()
    assert "lignin" in result
    assert "cnt" in result
    assert "rdf" in result


# ---------------------------------------------------------------------------
# save
# ---------------------------------------------------------------------------

def test_save_round_trips(tmp_path):
    original = {"lca": ["life cycle assessment", "life cycle analysis"]}
    p = tmp_path / "out.yaml"
    SynonymsManager.save(original, p)
    assert SynonymsManager.load(p) == {"lca": ["life cycle analysis", "life cycle assessment"]}


def test_save_deduplicates_and_sorts(tmp_path):
    data = {"x": ["b", "a", "b", "c"]}
    p = tmp_path / "out.yaml"
    SynonymsManager.save(data, p)
    loaded = SynonymsManager.load(p)
    assert loaded["x"] == ["a", "b", "c"]


# ---------------------------------------------------------------------------
# merge
# ---------------------------------------------------------------------------

def test_merge_adds_new_term():
    base = {"cnt": ["nanotube"]}
    additions = {"lca": ["life cycle assessment"]}
    result = SynonymsManager.merge(base, additions)
    assert "lca" in result
    assert "cnt" in result


def test_merge_extends_existing_term():
    base = {"cnt": ["nanotube"]}
    additions = {"cnt": ["carbon nanotube"]}
    result = SynonymsManager.merge(base, additions)
    assert set(result["cnt"]) == {"nanotube", "carbon nanotube"}


def test_merge_does_not_mutate_base():
    base = {"cnt": ["nanotube"]}
    _ = SynonymsManager.merge(base, {"cnt": ["carbon nanotube"]})
    assert base == {"cnt": ["nanotube"]}


def test_merge_deduplicates():
    base = {"cnt": ["nanotube", "carbon nanotube"]}
    additions = {"cnt": ["carbon nanotube"]}
    result = SynonymsManager.merge(base, additions)
    assert result["cnt"].count("carbon nanotube") == 1


# ---------------------------------------------------------------------------
# suggest_from_text
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("text,expected_key,expected_syn", [
    ("carbon nanotubes (CNT) are widely used", "cnt", "carbon nanotubes"),
    ("CNT (carbon nanotube) improves strength", "cnt", "carbon nanotube"),
    ("life cycle assessment (LCA) methodology", "lca", "life cycle assessment"),
])
def test_suggest_from_text_detects_acronym_patterns(text, expected_key, expected_syn):
    result = SynonymsManager.suggest_from_text(text)
    assert expected_key in result
    assert expected_syn in result[expected_key]


def test_suggest_from_text_empty_returns_empty():
    assert SynonymsManager.suggest_from_text("no patterns here at all") == {}


# ---------------------------------------------------------------------------
# suggest_from_files
# ---------------------------------------------------------------------------

def test_suggest_from_files_scans_directory(tmp_path):
    (tmp_path / "doc1.md").write_text("carbon nanotubes (CNT) are strong.\n" * 3)
    (tmp_path / "doc2.md").write_text("life cycle assessment (LCA) is important.\n" * 2)
    results = SynonymsManager.suggest_from_files(tmp_path)
    acronyms = [a for a, _, _ in results]
    assert "cnt" in acronyms
    assert "lca" in acronyms


def test_suggest_from_files_returns_sorted_by_count(tmp_path):
    (tmp_path / "a.md").write_text("carbon nanotubes (CNT) " * 5)
    (tmp_path / "b.md").write_text("life cycle assessment (LCA) " * 2)
    results = SynonymsManager.suggest_from_files(tmp_path)
    counts = [c for _, _, c in results]
    assert counts == sorted(counts, reverse=True)


# ---------------------------------------------------------------------------
# Integration: DEFAULT_INDEX_SETTINGS uses YAML file
# ---------------------------------------------------------------------------

def test_default_index_settings_synonyms_loaded_from_yaml():
    """IndexSettings default synonyms come from synonyms.yaml, not hardcoded."""
    synonyms = DEFAULT_INDEX_SETTINGS.synonyms
    # Verify broader YAML content is present
    assert "vitrimer" in synonyms
    assert "pyrolysis" in synonyms or "lignin" in synonyms
