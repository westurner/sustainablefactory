(glossary)=
# Glossary

% AUTO-GENERATED from glossary.yaml
% Source: glossary.yaml
% Run `docindex generate-glossary` to update.

## Knowledge Representation

```{glossary}
BFO
   Basic Formal Ontology — a top-level foundational ontology that provides
   abstract categories (continuant, occurrent, etc.) used as upper classes by
   IOF and many domain ontologies.
   *Also known as*: *basic formal ontology*.
   *See also*: {term}`IOF`, {term}`RDF`.

IOF
   Industrial Ontologies Foundry — a consortium of ontology developers and
   industrial stakeholders that publishes a suite of interoperable foundational
   ontologies for manufacturing, supply chain, and related domains.
   *Also known as*: *industrial ontology foundry*, *iof core*.
   *See also*: {term}`BFO`, {term}`RDF`.

Knowledge Graph
   A structured representation of entities and the relationships between them,
   encoded as an RDF graph and queryable with SPARQL.
   *Also known as*: *knowledge representation*, *semantic model*.
   *See also*: {term}`RDF`, {term}`SPARQL`.

Ontology
   A formal, machine-readable specification of the concepts within a domain
   and the relationships between them. In this project, ontologies are encoded
   as RDF/OWL and follow the IOF architecture.
   *Also known as*: *ontology*, *knowledge representation*, *semantic model*.
   *See also*: {term}`IOF`, {term}`RDF`.

QUDT
   Quantities, Units, Dimensions, and Types — an ontology suite that provides
   a machine-readable vocabulary for physical quantities and their units of
   measure, used to annotate numeric data in the knowledge graph.
   *Also known as*: *quantities units dimensions types*, *units of measure*, *uom*.
   *See also*: {term}`RDF`.

RDF
   Resource Description Framework — a W3C standard for representing information
   as subject–predicate–object triples, forming the basis of linked data and
   knowledge graphs.
   *Also known as*: *resource description framework*, *semantic web*, *linked data*.
   *See also*: {term}`Turtle`, {term}`SPARQL`, {term}`Knowledge Graph`.

RDF-star
   An extension of RDF that allows triples to be used as the subject or object
   of another triple, enabling metadata (such as confidence scores or
   provenance) to be attached directly to individual statements.
   *See also*: {term}`RDF`, {term}`Turtle-star`.

SPARQL
   SPARQL Protocol and RDF Query Language — the W3C-standard query language
   for retrieving and manipulating data stored in RDF format.
   *See also*: {term}`RDF`.

```

## Materials & Chemistry

```{glossary}
Biochar
   A carbon-rich solid produced by pyrolysis of biomass in a low-oxygen
   environment.  Used as a soil amendment, reductant in carbothermic
   processes, and precursor to activated carbon.
   *Also known as*: *activated carbon*, *pyrolytic carbon*, *charcoal*.
   *See also*: {term}`Pyrolysis`, {term}`Lignin`.

CNT
   Carbon nanotube — a cylindrical nanostructure of graphitic carbon with
   exceptional mechanical, thermal, and electrical properties.  Both
   single-walled (SWCNT) and multi-walled (MWCNT) forms are studied as
   reinforcing agents in polymer composites.
   *Also known as*: *carbon nanotube*, *carbon nanotubes*, *multi-walled carbon nanotube*, *single-walled carbon nanotube*, *mwcnt*, *swcnt*, *nanotube*.
   *See also*: {term}`Vitrimer`.

Lignin
   A complex aromatic polymer found in plant cell walls and a major
   by-product of pulping processes.  Kraft lignin (from the kraft pulping
   process) is the most abundant industrial form and is being explored as a
   renewable carbon source for binders, carbon fibers, and biochar.
   *Also known as*: *kraft lignin*, *kraft-lignin*, *lig*, *organosolv lignin*, *soda lignin*.
   *See also*: {term}`Biochar`, {term}`Pyrolysis`.

Vitrimer
   A class of covalent adaptable network (CAN) polymer that behaves like a
   thermoset at low temperatures but can be reshaped, welded, or recycled
   above an activation temperature via bond-exchange reactions, offering a
   route to closed-loop recyclability.
   *Also known as*: *vitrimer polymer*, *vitrimeric*, *covalent adaptable network*, *can polymer*.
   *See also*: {term}`CNT`.

```

## Industrial Processes

```{glossary}
Additive Manufacturing
   Layer-by-layer fabrication of parts directly from a digital model,
   including fused deposition modeling (FDM), selective laser sintering (SLS),
   and other techniques.  Enables complex geometries and low-waste production.
   *Also known as*: *3d printing*, *fused deposition modeling*, *fdm*, *selective laser sintering*, *sls*.
   *See also*: {term}`Sintering`.

Carbothermic
   A high-temperature reduction process in which a carbon source (coke,
   biochar, or graphite) reacts with a metal oxide to produce the elemental
   metal or carbide and CO/CO₂ off-gas.
   *Also known as*: *carbothermal reduction*, *carbothermal*.
   *See also*: {term}`Biochar`, {term}`Ultrasonic`.

Extrusion
   A continuous forming process in which material is forced through a shaped
   die.  Twin-screw extrusion is widely used for melt-compounding of polymers
   and composites.
   *Also known as*: *twin-screw extrusion*, *single-screw extrusion*, *melt processing*.

Process
   In the sustainablefactory model, a discrete industrial or manufacturing
   operation described by input materials, equipment, parameters, outputs,
   costs, and associated metrics.
   *See also*: {term}`Knowledge Graph`.

Pyrolysis
   Thermal decomposition of organic material at elevated temperatures in the
   absence of oxygen, converting biomass or polymers into biochar, bio-oil,
   and syngas.
   *Also known as*: *thermal decomposition*, *thermolysis*, *thermal cracking*.
   *See also*: {term}`Biochar`, {term}`Lignin`.

Sintering
   A powder consolidation process that bonds particles by heating below the
   melting point.  Spark plasma sintering (SPS) applies pulsed DC current for
   rapid densification.
   *Also known as*: *solid-state sintering*, *spark plasma sintering*, *sps*.
   *See also*: {term}`Additive Manufacturing`.

Ultrasonic
   Processing that uses high-frequency (> 20 kHz) acoustic waves.  In
   ultrasonication (sonochemistry), cavitation micro-bubbles are exploited
   for dispersion, surface activation, or driving chemical reactions.
   *Also known as*: *ultrasonication*, *sonochemical*, *sonication*, *acoustic cavitation*.
   *See also*: {term}`Carbothermic`.

```

## Sustainability Metrics

```{glossary}
Circularity
   The degree to which materials and energy flows in an industrial system
   are recovered and re-used rather than discharged as waste, as measured
   by material circularity indicators and closed-loop recycling rates.
   *Also known as*: *circular economy*, *material circularity*, *closed-loop recycling*.
   *See also*: {term}`LCA`.

GWP
   Global Warming Potential — the climate impact of a product or process
   expressed in CO₂-equivalent (CO₂eq) mass over a 100-year horizon,
   as quantified in a life cycle assessment.
   *Also known as*: *global warming potential*, *co2 equivalent*, *co2eq*, *carbon footprint*.
   *See also*: {term}`LCA`.

LCA
   Life Cycle Assessment — a systematic method for quantifying the
   environmental impacts of a product or process across its entire life
   cycle, from raw-material extraction through end-of-life treatment.
   *Also known as*: *life cycle analysis*, *life cycle assessment*, *lifecycle assessment*.
   *See also*: {term}`GWP`, {term}`Circularity`.

```

## Formats & Serializations

```{glossary}
Mermaid
   A JavaScript-based diagramming tool that renders graph, flowchart, and
   sequence diagrams from plain-text markup embedded in Markdown fences.
   *See also*: {term}`MyST`.

MyST
   Markedly Structured Text — a rich Markdown dialect (a superset of
   CommonMark) that supports Sphinx roles, directives, and cross-references,
   enabling technical documentation to be written in plain text files.
   *Also known as*: *myst markdown*, *markedly structured text*, *sphinx markdown*.
   *See also*: {term}`Sphinx`.

Sphinx
   A documentation build tool written in Python that converts reStructuredText
   and MyST Markdown source files into HTML, PDF, and other output formats.
   Used in this project to produce the HTML documentation site.
   *See also*: {term}`MyST`.

Turtle
   Terse RDF Triple Language — a compact, human-readable text serialization
   format for RDF graphs. Files use the ``.ttl`` extension.
   *See also*: {term}`RDF`, {term}`Turtle-star`.

Turtle-star
   A serialization format that extends Turtle with RDF-star syntax, allowing
   nested or annotated triples to be written concisely.
   *See also*: {term}`Turtle`, {term}`RDF-star`.

```
