"""
Tests for schema.py - ontology constants and NamedNode definitions.
"""

import importlib.util
import pyoxigraph as ox
from pathlib import Path

# Load schema.py directly (since schema/ directory shadows it)
schema_py_path = Path(__file__).parent.parent / "schema.py"
spec = importlib.util.spec_from_file_location("schema_module", schema_py_path)
schema = importlib.util.module_from_spec(spec)
spec.loader.exec_module(schema)


def test_schema_imports():
    """Test that schema module imports successfully."""
    assert schema is not None


def test_as_ontology_exists():
    """Test that AS ontology class exists with correct base URI."""
    assert hasattr(schema, "AS")
    assert schema.AS._BASE_URI == "https://www.w3.org/ns/activitystreams#"
    assert schema.AS.AS == "https://www.w3.org/ns/activitystreams#"


def test_bfo_ontology_exists():
    """Test that BFO ontology class exists with correct base URI."""
    assert hasattr(schema, "BFO")
    assert schema.BFO._BASE_URI == "http://purl.obolibrary.org/obo/bfo.owl/"
    assert schema.BFO.BFO == "http://purl.obolibrary.org/obo/bfo.owl/"


def test_bfo_named_nodes():
    """Test that BFO has expected NamedNode constants."""
    # Test that constants exist and are NamedNode instances
    assert hasattr(schema.BFO, "BFO_0000001")
    assert isinstance(schema.BFO.BFO_0000001, ox.NamedNode)

    assert hasattr(schema.BFO, "BFO_0000015")
    assert isinstance(schema.BFO.BFO_0000015, ox.NamedNode)

    # Test that the NamedNode contains the correct URI
    assert "BFO_0000001" in str(schema.BFO.BFO_0000001)
    assert "BFO_0000015" in str(schema.BFO.BFO_0000015)


def test_dcat_ontology_exists():
    """Test that DCAT ontology class exists."""
    assert hasattr(schema, "DCAT")
    assert hasattr(schema.DCAT, "_BASE_URI")


def test_org_ontology_exists():
    """Test that ORG ontology class exists."""
    assert hasattr(schema, "ORG")
    assert hasattr(schema.ORG, "_BASE_URI")


def test_prov_ontology_exists():
    """Test that PROV ontology class exists."""
    assert hasattr(schema, "PROV")
    assert hasattr(schema.PROV, "_BASE_URI")


def test_qudt_ontology_exists():
    """Test that QUDT ontology class exists."""
    assert hasattr(schema, "QUDT")
    assert hasattr(schema.QUDT, "_BASE_URI")


def test_iof_ontology_exists():
    """Test that IOF ontology class exists."""
    assert hasattr(schema, "IOF")
    assert hasattr(schema.IOF, "_BASE_URI")


def test_brick_ontology_exists():
    """Test that BRICK ontology class exists."""
    assert hasattr(schema, "BRICK")
    assert hasattr(schema.BRICK, "_BASE_URI")


def test_skosxl_ontology_exists():
    """Test that SKOSXL ontology class exists."""
    assert hasattr(schema, "SKOSXL")
    assert hasattr(schema.SKOSXL, "_BASE_URI")


def test_vcard_ontology_exists():
    """Test that VCARD ontology class exists."""
    assert hasattr(schema, "VCARD")
    assert hasattr(schema.VCARD, "_BASE_URI")


def test_wrds_ontology_exists():
    """Test that WRDS ontology class exists."""
    assert hasattr(schema, "WRDS")
    assert hasattr(schema.WRDS, "_BASE_URI")


def test_schema_base_uris_are_strings():
    """Test that all _BASE_URI attributes are strings."""
    ontology_classes = [
        schema.AS,
        schema.BFO,
        schema.DCAT,
        schema.ORG,
        schema.PROV,
        schema.QUDT,
        schema.IOF,
        schema.BRICK,
        schema.VCARD,
        schema.WRDS,
    ]

    for ontology in ontology_classes:
        assert hasattr(ontology, "_BASE_URI")
        assert isinstance(ontology._BASE_URI, str)
        assert len(ontology._BASE_URI) > 0


def test_named_nodes_are_valid():
    """Test that NamedNode instances can be converted to strings."""
    # Test a few NamedNodes
    node = schema.BFO.BFO_0000001
    node_str = str(node)
    assert len(node_str) > 0
    assert "BFO" in node_str or "bfo" in node_str


def test_schema_structure():
    """Test that schema has both _BASE_URI and ontology references."""
    # Each ontology class should have _BASE_URI and a reference to itself
    for ontology_name in ["AS", "BFO", "DCAT"]:
        ontology = getattr(schema, ontology_name)
        assert hasattr(ontology, "_BASE_URI")
        # Most have a reference to their own namespace
        if hasattr(ontology, ontology_name):
            base_uri = getattr(ontology, "_BASE_URI")
            assert base_uri.endswith("#") or base_uri.endswith("/")


def test_multiple_ontologies_have_distinct_base_uris():
    """Test that different ontologies have different base URIs."""
    base_uris = {
        "AS": schema.AS._BASE_URI,
        "BFO": schema.BFO._BASE_URI,
        "DCAT": schema.DCAT._BASE_URI,
        "IOF": schema.IOF._BASE_URI,
        "BRICK": schema.BRICK._BASE_URI,
    }

    # Check that all base URIs are unique
    unique_uris = set(base_uris.values())
    assert len(unique_uris) == len(base_uris)


def test_bfo_entity_hierarchy():
    """Test that BFO has entity and continuant concepts."""
    # These represent the top-level hierarchy in BFO
    assert hasattr(schema.BFO, "BFO_0000001")  # entity
    assert hasattr(schema.BFO, "BFO_0000002")  # continuant
    assert hasattr(schema.BFO, "BFO_0000003")  # occurrent


def test_pyoxigraph_integration():
    """Test that schema correctly uses pyoxigraph NamedNode."""
    # Verify that BFO constants are created with pyoxigraph
    assert isinstance(schema.BFO.BFO_0000001, ox.NamedNode)

    # Verify that the URI format is correct
    node = schema.BFO.BFO_0000001
    node_str = str(node)
    assert "<" in node_str and ">" in node_str  # NamedNodes render with angle brackets
