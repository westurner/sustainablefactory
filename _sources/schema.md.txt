# Process Schema

The project builds upon the **Industrial Ontologies Foundry (IOF)** Core, which is rooted in **Basic Formal Ontology (BFO)**.

## Key Classes

The following Mermaid diagram visualizes our usage of the IOF schema:

```{mermaid}
classDiagram
    class PlannedProcess {
        rdfs:label string
        ex:hasDataTable DataTable
    }
    class MaterialResource {
        rdfs:label string
    }
    class Product {
        rdfs:label string
    }

    PlannedProcess --|> BFO_0000015 : is a
    PlannedProcess "*" --> "*" MaterialResource : participates_in
    Product --> "1" PlannedProcess : is_output_of
    PlannedProcess --> "1" PlannedProcess : precedes
```

## Namespace Prefixes
We use the following standard prefixes:

- `iof:` `<https://spec.industrialontologies.org/ontology/core/Core/>`
- `ex:` `<http://westurner.github.io/sustainablefactory/process/#>` (Custom extensions)
- `rdf-star`: Enabled for extraction metadata (e.g., `ex:confidence`)

## Schema Directory Structure
The foundational ontologies and local extensions are organized as follows. Click the links to download or view the raw source files:

*   **schema/**
    *   {download}`sustainable-factory.ttl <../schema/sustainable-factory.ttl>` (Local Extensions)
    *   {download}`iof-core/iof-core.ttl <../schema/iof-core/iof-core.ttl>` (Foundational Ontology - Turtle)
    *   {download}`iof-core/iof-core.rdf <../schema/iof-core/iof-core.rdf>` (Foundational Ontology - RDF/XML)
    *   {download}`iof-core/LICENSE <../schema/iof-core/LICENSE>`
    *   {download}`iof-core/README.md <../schema/iof-core/README.md>` (IOF Core Info)
    *   {download}`README.md <../schema/README.md>` (Schema Overview)
