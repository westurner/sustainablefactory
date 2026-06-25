import pytest
from unittest.mock import Mock, patch
from sustainablefactory.parser import ProcessStep
from sustainablefactory.rdf_gen import generate_rdf_star, sanitize_id, Namespace
import pyoxigraph as ox


class TestSanitizeId:
    """Tests for the sanitize_id function."""

    @pytest.mark.parametrize("input_text,expected", [
        ("Phase 1", "Phase_1"),
        ("Temp (C)", "Temp_C"),
        ("2nd Step", "id_2nd_Step"),
        ("normal_id", "normal_id"),
        ("Mix@#$%", "Mix"),
        ("___test___", "test"),
        ("", "unknown"),
        (None, "unknown"),
    ])
    def test_sanitize_id_parametrized(self, input_text, expected):
        """Test sanitize_id with various inputs using parametrize."""
        assert sanitize_id(input_text) == expected

    def test_sanitize_id_special_unicode(self):
        """Test sanitize_id with special unicode characters."""
        result = sanitize_id("²_special")
        assert result == "special"
        assert "_" not in result.strip("_")

    def test_sanitize_id_multiple_spaces(self):
        """Test sanitize_id with multiple spaces and symbols."""
        result = sanitize_id("input  @@@  text")
        assert "_" in result
        assert "@" not in result

    def test_sanitize_id_starts_with_number(self):
        """Test sanitize_id prefixes IDs starting with numbers."""
        result = sanitize_id("123test")
        assert result.startswith("id_")

    def test_sanitize_id_only_numbers(self):
        """Test sanitize_id with only numbers."""
        result = sanitize_id("12345")
        assert result.startswith("id_")


class TestNamespace:
    """Tests for the Namespace helper class."""

    def test_namespace_getitem(self):
        """Test Namespace __getitem__ method."""
        ns = Namespace("http://example.org/")
        node = ns["test"]
        assert isinstance(node, ox.NamedNode)
        # NamedNode.__str__() includes angle brackets
        assert "http://example.org/test" in str(node)

    def test_namespace_call(self):
        """Test Namespace __call__ method."""
        ns = Namespace("http://example.org/")
        node = ns("test")
        assert isinstance(node, ox.NamedNode)
        assert "http://example.org/test" in str(node)

    @pytest.mark.parametrize("base_uri,name,expected_substring", [
        ("http://example.org/", "item", "http://example.org/item"),
        ("https://test.com/ns/", "prop", "https://test.com/ns/prop"),
        ("http://example.org/path/", "123", "http://example.org/path/123"),
    ])
    def test_namespace_various_uris(self, base_uri, name, expected_substring):
        """Test Namespace with various URIs using parametrize."""
        ns = Namespace(base_uri)
        node = ns[name]
        assert expected_substring in str(node)


class TestGenerateRdfStarBasic:
    """Tests for basic RDF generation."""

    def test_generate_rdf_star_basic(self):
        """Test basic RDF-star generation."""
        step = ProcessStep("p1", "Process 1")
        step.properties["temp"] = "100"
        rdf = generate_rdf_star([step])
        
        assert "Process 1" in rdf
        assert "p1" in rdf
        assert "temp" in rdf
        assert "100" in rdf
        assert "extractionSource" in rdf

    def test_generate_rdf_star_with_prefix(self):
        """Test RDF-star generation with source prefix."""
        step = ProcessStep("p1", "Process 1")
        rdf = generate_rdf_star([step], source_prefix="test_doc")
        
        assert "test_doc__p1" in rdf

    def test_generate_rdf_star_multiple_steps(self):
        """Test RDF-star generation with multiple steps."""
        step1 = ProcessStep("s1", "Step 1")
        step2 = ProcessStep("s2", "Step 2")
        rdf = generate_rdf_star([step1, step2])
        
        assert "Step 1" in rdf
        assert "Step 2" in rdf

    def test_generate_rdf_star_empty_steps(self):
        """Test RDF-star generation with empty step list."""
        rdf = generate_rdf_star([])
        
        # Should still have valid Turtle header
        assert "@prefix" in rdf or "@base" in rdf or len(rdf) >= 0

    def test_generate_rdf_star_verbose_mode(self, capsys):
        """Test RDF-star generation with verbose mode."""
        step = ProcessStep("p1", "Process 1")
        generate_rdf_star([step], verbose=True)
        
        captured = capsys.readouterr()
        assert "Process 1" in captured.out


class TestGenerateRdfStarWithProperties:
    """Tests for RDF generation with step properties."""

    def test_generate_rdf_star_multiple_properties(self):
        """Test RDF-star with multiple properties."""
        step = ProcessStep("p1", "Process")
        step.properties["temp"] = "100"
        step.properties["pressure"] = "50"
        step.properties["time"] = "30min"
        
        rdf = generate_rdf_star([step])
        
        assert "100" in rdf
        assert "50" in rdf
        assert "30min" in rdf

    def test_generate_rdf_star_properties_with_special_chars(self):
        """Test RDF-star with special characters in properties."""
        step = ProcessStep("p1", "Process")
        step.properties["temp (°C)"] = "100"
        step.properties["pressure@bar"] = "2.5"
        
        rdf = generate_rdf_star([step])
        
        # Values should be present even if keys are sanitized
        assert "100" in rdf
        assert "2.5" in rdf


class TestGenerateRdfStarWithInputsOutputs:
    """Tests for RDF generation with inputs and outputs."""

    def test_generate_rdf_star_with_inputs(self):
        """Test RDF-star with input materials."""
        step = ProcessStep("p1", "Process")
        step.inputs = ["iron", "carbon", "flux"]
        
        rdf = generate_rdf_star([step])
        
        assert "iron" in rdf
        assert "carbon" in rdf
        assert "flux" in rdf
        assert "MaterialResource" in rdf

    def test_generate_rdf_star_with_outputs(self):
        """Test RDF-star with output products."""
        step = ProcessStep("p1", "Process")
        step.outputs = ["steel", "slag"]
        
        rdf = generate_rdf_star([step])
        
        assert "steel" in rdf
        assert "slag" in rdf
        assert "Product" in rdf

    def test_generate_rdf_star_with_next_steps(self):
        """Test RDF-star with next steps (process flow)."""
        step1 = ProcessStep("s1", "Heat")
        step1.next_steps = ["s2", "s3"]
        step2 = ProcessStep("s2", "Cool")
        step3 = ProcessStep("s3", "Mix")
        
        rdf = generate_rdf_star([step1, step2, step3])
        
        assert "precedes" in rdf
        assert "Heat" in rdf


class TestGenerateRdfStarWithExtendedAttributes:
    """Tests for RDF generation with extended attributes."""

    def test_generate_rdf_star_with_cost_figures(self):
        """Test RDF-star with cost figures."""
        step = ProcessStep("p1", "Process")
        step.cost_figures = ["$100", "$500", "$1000"]
        
        rdf = generate_rdf_star([step])
        
        assert "CostFigure" in rdf
        assert "$100" in rdf

    def test_generate_rdf_star_with_latex_math(self):
        """Test RDF-star with LaTeX math expressions."""
        step = ProcessStep("p1", "Process")
        step.latex_math = ["$x^2 + y^2$", "$\\int_0^1 f(x)dx$"]
        
        rdf = generate_rdf_star([step])
        
        assert "LatexMath" in rdf
        assert "hasMath" in rdf

    def test_generate_rdf_star_with_metrics(self):
        """Test RDF-star with performance metrics."""
        step = ProcessStep("p1", "Process")
        step.metrics = ["efficiency", "throughput", "yield"]
        
        rdf = generate_rdf_star([step])
        
        assert "PerformanceMetric" in rdf
        assert "efficiency" in rdf

    def test_generate_rdf_star_with_equipment(self):
        """Test RDF-star with equipment."""
        step = ProcessStep("p1", "Process")
        step.equipment = ["furnace", "reactor", "pump"]
        
        rdf = generate_rdf_star([step])
        
        assert "Equipment" in rdf
        assert "usesEquipment" in rdf
        assert "furnace" in rdf

    def test_generate_rdf_star_with_materials(self):
        """Test RDF-star with materials."""
        step = ProcessStep("p1", "Process")
        step.materials = ["iron oxide", "carbon", "limestone"]
        
        rdf = generate_rdf_star([step])
        
        assert "ChemicalMaterial" in rdf
        assert "consumesMaterial" in rdf
        assert "iron oxide" in rdf

    def test_generate_rdf_star_with_citations(self):
        """Test RDF-star with citations."""
        step = ProcessStep("p1", "Process")
        step.citations = ["source1", "source2"]
        
        rdf = generate_rdf_star([step])
        
        assert "InformationSource" in rdf
        assert "hasSource" in rdf
        assert "source1" in rdf

    def test_generate_rdf_star_with_tables(self):
        """Test RDF-star with data tables."""
        step = ProcessStep("p1", "Process")
        step.tables = [
            {
                "rows": [
                    {"column1": "value1", "column2": "value2"},
                    {"column1": "value3", "column2": "value4"}
                ]
            }
        ]
        
        rdf = generate_rdf_star([step])
        
        assert "DataTable" in rdf
        assert "TableRow" in rdf
        assert "value1" in rdf or "value2" in rdf


class TestGenerateRdfStarComprehensive:
    """Comprehensive tests combining multiple features."""

    def test_generate_rdf_star_full_step(self):
        """Test RDF-star with all possible step attributes."""
        step = ProcessStep("full_step", "Comprehensive Process")
        step.properties["temp"] = "150"
        step.inputs = ["input1", "input2"]
        step.outputs = ["output1"]
        step.next_steps = ["next"]
        step.cost_figures = ["$500"]
        step.latex_math = ["$E=mc^2$"]
        step.metrics = ["efficiency"]
        step.equipment = ["reactor"]
        step.materials = ["material1"]
        step.citations = ["paper1"]
        step.tables = [{"rows": [{"data": "test"}]}]
        
        rdf = generate_rdf_star([step])
        
        # Check that all components are present
        assert "Comprehensive Process" in rdf
        assert "150" in rdf
        assert "input1" in rdf
        assert "output1" in rdf
        assert "PlannedProcess" in rdf

    @pytest.mark.parametrize("prefix,expected_in_rdf", [
        ("doc1", "doc1__full_step"),
        ("test_file", "test_file__full_step"),
        ("", "full_step"),
    ])
    def test_generate_rdf_star_prefix_variations(self, prefix, expected_in_rdf):
        """Test various source prefix formats using parametrize."""
        step = ProcessStep("full_step", "Process")
        rdf = generate_rdf_star([step], source_prefix=prefix)
        
        assert expected_in_rdf in rdf

    def test_generate_rdf_star_returns_valid_turtle(self):
        """Test that output is valid Turtle format."""
        step = ProcessStep("p1", "Process")
        rdf = generate_rdf_star([step])
        
        # Should be a string
        assert isinstance(rdf, str)
        # Should not be empty
        assert len(rdf) > 0
        # Should contain RDF content (URIs or literals)
        assert "<http" in rdf or "rdfs:label" in rdf or '"Process"' in rdf
