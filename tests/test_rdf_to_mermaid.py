"""Tests for rdf_to_mermaid module."""

import pytest
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock, mock_open
from tools.rdf_to_mermaid import ttl_to_mermaid


@pytest.fixture
def mock_rdf_store():
    """Mock RDF store."""
    return Mock()


@pytest.fixture
def temp_ttl_file(tmp_path):
    """Create a temporary TTL file with test RDF data."""
    ttl_file = tmp_path / "test.ttl"
    ttl_content = """
    @prefix ex: <http://example.org/> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:step1 iof:precedes ex:step2 ;
            rdfs:label "Step 1" .
    ex:step2 rdfs:label "Step 2" .
    """
    ttl_file.write_text(ttl_content)
    return ttl_file


@pytest.fixture
def simple_rdf_file(tmp_path):
    """Create a simple RDF file."""
    ttl_file = tmp_path / "simple.ttl"
    ttl_file.write_text("@prefix ex: <http://example.org/> .")
    return ttl_file


@pytest.mark.parametrize("step1_label,step2_label", [
    ("Process A", "Process B"),
    ("Step 1", "Step 2"),
    ("Heating", "Cooling"),
    ("Input", "Output"),
])
def test_ttl_to_mermaid_basic(step1_label, step2_label, tmp_path):
    """Test basic TTL to Mermaid conversion with various labels."""
    ttl_file = tmp_path / "test.ttl"
    ttl_content = f"""
    @prefix ex: <http://example.org/> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:step1 iof:precedes ex:step2 ;
            rdfs:label "{step1_label}" .
    ex:step2 rdfs:label "{step2_label}" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert "graph TD" in result
    assert "step1" in result
    assert "step2" in result
    assert step1_label in result
    assert step2_label in result
    assert "-->" in result


def test_ttl_to_mermaid_multiple_precedes(tmp_path):
    """Test TTL with multiple precedes relationships."""
    ttl_file = tmp_path / "multi.ttl"
    ttl_content = """
    @prefix ex: <http://example.org/> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:step1 iof:precedes ex:step2 ;
            rdfs:label "Step 1" .
    ex:step2 iof:precedes ex:step3 ;
            rdfs:label "Step 2" .
    ex:step3 rdfs:label "Step 3" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert "step1" in result
    assert "step2" in result
    assert "step3" in result
    assert result.count("-->") >= 2


def test_ttl_to_mermaid_with_uri_fragments(tmp_path):
    """Test handling of URIs with fragments."""
    ttl_file = tmp_path / "fragments.ttl"
    ttl_content = """
    @prefix ex: <http://example.org/ontology#> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:ProcessStep_1 iof:precedes ex:ProcessStep_2 ;
            rdfs:label "Fragment Step 1" .
    ex:ProcessStep_2 rdfs:label "Fragment Step 2" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert "graph TD" in result
    # Should extract ID from fragment
    assert "ProcessStep_1" in result or "ProcessStep_2" in result


def test_ttl_to_mermaid_with_url_path_segments(tmp_path):
    """Test handling of URIs with path segments."""
    ttl_file = tmp_path / "paths.ttl"
    ttl_content = """
    @prefix ex: <http://example.org/ontology/processes/> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:process_step1 iof:precedes ex:process_step2 ;
            rdfs:label "Path Step 1" .
    ex:process_step2 rdfs:label "Path Step 2" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert "graph TD" in result


def test_ttl_to_mermaid_empty_file(tmp_path):
    """Test TTL file with no precedes relationships."""
    ttl_file = tmp_path / "empty.ttl"
    ttl_file.write_text("""
    @prefix ex: <http://example.org/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:step1 rdfs:label "Only Step" .
    """)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert "graph TD" in result
    # Should have graph but no arrows
    assert "-->" not in result


def test_ttl_to_mermaid_returns_string(temp_ttl_file):
    """Test that function returns a string."""
    result = ttl_to_mermaid(str(temp_ttl_file))
    
    assert isinstance(result, str)


def test_ttl_to_mermaid_graph_syntax(tmp_path):
    """Test that output has valid Mermaid graph syntax."""
    ttl_file = tmp_path / "syntax.ttl"
    ttl_content = """
    @prefix ex: <http://example.org/> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:a iof:precedes ex:b ; rdfs:label "A" .
    ex:b rdfs:label "B" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    # Check for valid Mermaid graph format
    lines = result.strip().split('\n')
    assert lines[0] == "graph TD"
    
    # Check for proper node notation
    for line in lines[1:]:
        if line.strip():
            # Should contain node ID and arrow or label
            assert "[" in line and "]" in line


@pytest.mark.parametrize("uri_prefix,expected_id", [
    ("http://example.org/", "step1"),
    ("https://spec.industrialontologies.org/ontology/core/Core/", "MyProcess"),
    ("http://example.org/path/to/", "node"),
])
def test_ttl_to_mermaid_uri_extraction(tmp_path, uri_prefix, expected_id):
    """Test ID extraction from various URI formats."""
    ttl_file = tmp_path / f"uri_{expected_id}.ttl"
    ttl_content = f"""
    @prefix ex: <{uri_prefix}> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:{expected_id} iof:precedes ex:next ;
            rdfs:label "Test" .
    ex:next rdfs:label "Next" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert expected_id in result
    assert "graph TD" in result


def test_ttl_to_mermaid_complex_flow(tmp_path):
    """Test TTL with complex process flow."""
    ttl_file = tmp_path / "complex.ttl"
    ttl_content = """
    @prefix ex: <http://example.org/> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:heat iof:precedes ex:cool ;
            rdfs:label "Heating" .
    ex:cool iof:precedes ex:mix ;
            rdfs:label "Cooling" .
    ex:mix iof:precedes ex:package ;
            rdfs:label "Mixing" .
    ex:package rdfs:label "Packaging" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert "heat" in result
    assert "cool" in result
    assert "mix" in result
    assert "package" in result
    # Should have at least 3 arrows for this flow
    assert result.count("-->") >= 3


@patch("tools.rdf_to_mermaid.ox.Store")
def test_ttl_to_mermaid_file_read(mock_store_class, tmp_path):
    """Test that ttl_to_mermaid properly reads file."""
    ttl_file = tmp_path / "mock_test.ttl"
    ttl_file.write_text("test content")
    
    # Create mock store instance
    mock_store = Mock()
    mock_store.query.return_value = []
    mock_store_class.return_value = mock_store
    
    # Mock the dump method
    mock_store.dump = Mock()
    
    result = ttl_to_mermaid(str(ttl_file))
    
    # Verify file was attempted to be loaded
    mock_store.load.assert_called_once()


def test_ttl_to_mermaid_with_multiple_labels(tmp_path):
    """Test that labels are properly extracted and displayed."""
    ttl_file = tmp_path / "labels.ttl"
    ttl_content = """
    @prefix ex: <http://example.org/> .
    @prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
    
    ex:s1 iof:precedes ex:s2 ;
            rdfs:label "Very Long Label With Many Words" .
    ex:s2 iof:precedes ex:s3 ;
            rdfs:label "Another Complex Process Name" .
    ex:s3 rdfs:label "Final Step" .
    """
    ttl_file.write_text(ttl_content)
    
    result = ttl_to_mermaid(str(ttl_file))
    
    assert "Very Long Label With Many Words" in result
    assert "Another Complex Process Name" in result
    assert "Final Step" in result

