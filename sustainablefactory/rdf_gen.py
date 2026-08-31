"""
RDF generation module for Sustainable Factory Process data.

This module is responsible for converting parsed process steps into RDF (Resource Description Framework)
representations, specifically leveraging RDF-star / RDF 1.2 patterns for statement-level metadata.
"""

import io
import pyoxigraph as ox
import re
from sustainablefactory.parser import ProcessStep
from typing import Iterable, Optional


def sanitize_id(text: Optional[str]) -> str:
    """
    Sanitizes a string to be used as a valid Turtle local name / IRI segment.

    Args:
        text: The input string to sanitize.

    Returns:
        A sanitized string containing only alphanumeric characters and underscores.
        Returns "unknown" if input is None or empty.
    """
    if not text:
        return "unknown"
    # Keep only a-z, A-Z, 0-9, and _ for absolute safety in Turtle local names
    s = re.sub(r"[^a-zA-Z0-9_]", "_", text)
    # Ensure it starts with a letter or underscore
    if not re.match(r"^[a-zA-Z_]", s):
        s = "id_" + s
    # Clean up double underscores
    s = re.sub(r"_+", "_", s).strip("_")
    return s or "id"


class Namespace:
    """Helper to create pyoxigraph.NamedNode from a base URI prefix."""

    def __init__(self, base_uri: str):
        self.base_uri = base_uri

    def __getitem__(self, name: str) -> ox.NamedNode:
        return ox.NamedNode(self.base_uri + name)

    def __call__(self, name: str) -> ox.NamedNode:
        return ox.NamedNode(self.base_uri + name)


def generate_rdf_star(
    steps: Iterable[ProcessStep], source_prefix: str = "", verbose: bool = False
) -> str:
    """
    Generate RDF-star serialization for a sequence of ProcessStep objects.

    This function constructs an RDF graph using pyoxigraph, mapping ProcessStep objects to
    IOF PlannedProcess entities and their related inputs, outputs, and properties.
    Statement-level metadata (such as extraction confidence and source) is attached using
    RDF 1.2 triple terms (where the triple itself is the object of a reification quad).

    Args:
        steps: An iterable of ProcessStep objects to be converted to RDF.
        source_prefix: An optional prefix string to prepend to generated IDs to
            ensure uniqueness across sources.
        verbose: If True, prints the generated Turtle string to stdout.

    Returns:
        The complete RDF graph serialized as a Turtle string.
    """
    store = ox.Store()

    # Prefix for this specific export to avoid ID collisions
    pfx = sanitize_id(source_prefix) + "__" if source_prefix else ""

    # Namespaces
    sfpro = Namespace("http://westurner.github.io/sustainablefactory/process/#")
    iof = Namespace("https://spec.industrialontologies.org/ontology/core/Core/")
    rdf = Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    rdfs = Namespace("http://www.w3.org/2000/01/rdf-schema#")
    xsd = Namespace("http://www.w3.org/2001/XMLSchema#")

    # Common Nodes
    RDF_TYPE = rdf["type"]

    # Property for reification (RDF 1.2 style or custom)
    REIFIES = rdf["reifies"]

    for step in steps:
        step_id = pfx + sanitize_id(step.id)
        step_node = sfpro[step_id]

        # Type and Label
        store.add(ox.Quad(step_node, RDF_TYPE, iof["PlannedProcess"]))
        store.add(ox.Quad(step_node, rdfs["label"], ox.Literal(step.label)))

        if step.properties:
            for prop, val in step.properties.items():
                prop_id = sanitize_id(prop)
                prop_node = sfpro[prop_id]
                val_node = ox.Literal(str(val))

                # Main triple
                triple = ox.Triple(step_node, prop_node, val_node)
                store.add(ox.Quad(step_node, prop_node, val_node))

                # Reification (RDF 1.2 Triple Term)
                # Create a reifier node (Blank Node)
                reifier = ox.BlankNode()

                # Link reifier to triple term
                store.add(ox.Quad(reifier, REIFIES, triple))

                # Add metadata to reifier
                store.add(
                    ox.Quad(
                        reifier,
                        sfpro["confidence"],
                        ox.Literal("0.8", datatype=xsd["decimal"]),
                    )
                )
                store.add(
                    ox.Quad(
                        reifier,
                        sfpro["extractionSource"],
                        ox.Literal("MyST-Parser-Regex"),
                    )
                )

        if step.inputs:
            for i, input_item in enumerate(step.inputs):
                input_id = f"Input_{step_id}_{i}"
                input_node = sfpro[input_id]
                store.add(ox.Quad(input_node, RDF_TYPE, iof["MaterialResource"]))
                store.add(ox.Quad(input_node, rdfs["label"], ox.Literal(input_item)))
                store.add(
                    ox.Quad(step_node, iof["participates_in_at_some_time"], input_node)
                )

        if step.outputs:
            for i, output_item in enumerate(step.outputs):
                output_id = f"Output_{step_id}_{i}"
                output_node = sfpro[output_id]
                store.add(ox.Quad(output_node, RDF_TYPE, iof["Product"]))
                store.add(ox.Quad(output_node, rdfs["label"], ox.Literal(output_item)))
                store.add(ox.Quad(output_node, iof["is_output_of"], step_node))

        if step.next_steps:
            for next_id in step.next_steps:
                sanitized_next_id = pfx + sanitize_id(next_id)
                store.add(ox.Quad(step_node, iof["precedes"], sfpro[sanitized_next_id]))

        if hasattr(step, "cost_figures") and step.cost_figures:
            for i, figure in enumerate(step.cost_figures):
                figure_id = f"Cost_{step_id}_{i}"
                figure_node = sfpro[figure_id]
                store.add(ox.Quad(figure_node, RDF_TYPE, sfpro["CostFigure"]))
                store.add(ox.Quad(figure_node, rdfs["label"], ox.Literal(figure)))
                store.add(ox.Quad(step_node, sfpro["hasCost"], figure_node))

        if hasattr(step, "latex_math") and step.latex_math:
            for i, math_item in enumerate(step.latex_math):
                math_id = f"Math_{step_id}_{i}"
                math_node = sfpro[math_id]
                store.add(ox.Quad(math_node, RDF_TYPE, sfpro["LatexMath"]))
                store.add(ox.Quad(math_node, rdfs["label"], ox.Literal(math_item)))
                store.add(ox.Quad(step_node, sfpro["hasMath"], math_node))

        if hasattr(step, "metrics") and step.metrics:
            for i, metric in enumerate(step.metrics):
                metric_node = sfpro[f"Metric_{step_id}_{i}"]
                store.add(ox.Quad(metric_node, RDF_TYPE, sfpro["PerformanceMetric"]))
                store.add(ox.Quad(metric_node, rdfs["label"], ox.Literal(metric)))
                store.add(ox.Quad(step_node, sfpro["hasMetric"], metric_node))

        if hasattr(step, "equipment") and step.equipment:
            for i, tool in enumerate(step.equipment):
                tool_node = sfpro[f"Tool_{step_id}_{i}"]
                store.add(ox.Quad(tool_node, RDF_TYPE, sfpro["Equipment"]))
                store.add(ox.Quad(tool_node, rdfs["label"], ox.Literal(tool)))
                store.add(ox.Quad(step_node, sfpro["usesEquipment"], tool_node))

        if hasattr(step, "materials") and step.materials:
            for i, mat in enumerate(step.materials):
                mat_node = sfpro[f"Material_{step_id}_{i}"]
                store.add(ox.Quad(mat_node, RDF_TYPE, sfpro["ChemicalMaterial"]))
                store.add(ox.Quad(mat_node, rdfs["label"], ox.Literal(mat)))
                store.add(ox.Quad(step_node, sfpro["consumesMaterial"], mat_node))

        if hasattr(step, "citations") and step.citations:
            for i, cit in enumerate(step.citations):
                cit_node = sfpro[f"Source_{step_id}_{i}"]
                store.add(ox.Quad(cit_node, RDF_TYPE, sfpro["InformationSource"]))
                store.add(ox.Quad(cit_node, rdfs["label"], ox.Literal(cit)))
                store.add(ox.Quad(step_node, sfpro["hasSource"], cit_node))

        if step.tables:
            for tidx, table in enumerate(step.tables):
                table_id = f"Table_{step_id}_{tidx}"
                table_node = sfpro[table_id]
                store.add(ox.Quad(table_node, RDF_TYPE, sfpro["DataTable"]))
                store.add(
                    ox.Quad(
                        table_node,
                        rdfs["label"],
                        ox.Literal(f"Data Table in {step.label}"),
                    )
                )
                store.add(ox.Quad(step_node, sfpro["hasDataTable"], table_node))

                for ridx, row in enumerate(table["rows"]):
                    row_node = sfpro[f"{table_id}_Row_{ridx}"]
                    store.add(ox.Quad(row_node, RDF_TYPE, sfpro["TableRow"]))
                    store.add(ox.Quad(table_node, sfpro["hasRow"], row_node))
                    for col, val in row.items():
                        col_id = sanitize_id(col)
                        store.add(
                            ox.Quad(row_node, sfpro[col_id], ox.Literal(str(val)))
                        )

    # Serialize store to Turtle (now safe via pyoxigraph 0.5+)
    output = io.BytesIO()

    # We rely on pyoxigraph to serialize the graph, including reified triples, correctly.
    # RDF 1.2 triple terms are supported as object terms.
    store.dump(output, ox.RdfFormat.TURTLE, from_graph=ox.DefaultGraph())

    ttl_star = output.getvalue().decode("utf-8")

    if verbose:
        print(ttl_star)

    return ttl_star
