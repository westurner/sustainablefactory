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

   - **Also known as:**
     - *basic formal ontology*
   - **abbreviation:** BFO
   - **category:** Knowledge Representation
   - **See also:**
     - {term}`IOF`
     - {term}`RDF`

IOF
   Industrial Ontologies Foundry — a consortium of ontology developers and
   industrial stakeholders that publishes a suite of interoperable foundational
   ontologies for manufacturing, supply chain, and related domains.

   - **Also known as:**
     - *industrial ontology foundry*
     - *iof core*
   - **abbreviation:** IOF
   - **category:** Knowledge Representation
   - **See also:**
     - {term}`BFO`
     - {term}`RDF`

Knowledge Graph
   A structured representation of entities and the relationships between them,
   encoded as an RDF graph and queryable with SPARQL.

   - **Also known as:**
     - *knowledge representation*
     - *semantic model*
   - **category:** Knowledge Representation
   - **See also:**
     - {term}`RDF`
     - {term}`SPARQL`

Ontology
   A formal, machine-readable specification of the concepts within a domain
   and the relationships between them. In this project, ontologies are encoded
   as RDF/OWL and follow the IOF architecture.

   - **Also known as:**
     - *ontology*
     - *knowledge representation*
     - *semantic model*
   - **category:** Knowledge Representation
   - **See also:**
     - {term}`IOF`
     - {term}`RDF`

QUDT
   Quantities, Units, Dimensions, and Types — an ontology suite that provides
   a machine-readable vocabulary for physical quantities and their units of
   measure, used to annotate numeric data in the knowledge graph.

   - **Also known as:**
     - *quantities units dimensions types*
     - *units of measure*
     - *uom*
   - **abbreviation:** QUDT
   - **category:** Knowledge Representation
   - **See also:**
     - {term}`RDF`

RDF
   Resource Description Framework — a W3C standard for representing information
   as subject–predicate–object triples, forming the basis of linked data and
   knowledge graphs.

   - **Also known as:**
     - *resource description framework*
     - *semantic web*
     - *linked data*
   - **abbreviation:** RDF
   - **category:** Knowledge Representation
   - **See also:**
     - {term}`Turtle`
     - {term}`SPARQL`
     - {term}`Knowledge Graph`

RDF-star
   An extension of RDF that allows triples to be used as the subject or object
   of another triple, enabling metadata (such as confidence scores or
   provenance) to be attached directly to individual statements.

   - **category:** Knowledge Representation
   - **See also:**
     - {term}`RDF`
     - {term}`Turtle-star`

SPARQL
   SPARQL Protocol and RDF Query Language — the W3C-standard query language
   for retrieving and manipulating data stored in RDF format.

   - **abbreviation:** SPARQL
   - **category:** Knowledge Representation
   - **See also:**
     - {term}`RDF`

```

## Materials & Chemistry

```{glossary}
Biochar
   A carbon-rich solid produced by pyrolysis of biomass in a low-oxygen
   environment.  Used as a soil amendment, reductant in carbothermic
   processes, and precursor to activated carbon.

   - **Also known as:**
     - *activated carbon*
     - *pyrolytic carbon*
     - *charcoal*
   - **category:** Materials \& Chemistry
   - **See also:**
     - {term}`Pyrolysis`
     - {term}`Lignin`

CNT
   Carbon nanotube — a cylindrical nanostructure of graphitic carbon with
   exceptional mechanical, thermal, and electrical properties.  Both
   single-walled (SWCNT) and multi-walled (MWCNT) forms are studied as
   reinforcing agents in polymer composites.

   - **Also known as:**
     - *carbon nanotube*
     - *carbon nanotubes*
     - *multi\-walled carbon nanotube*
     - *single\-walled carbon nanotube*
     - *mwcnt*
     - *swcnt*
     - *nanotube*
   - **abbreviation:** CNT
   - **category:** Materials \& Chemistry
   - **See also:**
     - {term}`Vitrimer`

Lignin
   A complex aromatic polymer found in plant cell walls and a major
   by-product of pulping processes.  Kraft lignin (from the kraft pulping
   process) is the most abundant industrial form and is being explored as a
   renewable carbon source for binders, carbon fibers, and biochar.

   - **Also known as:**
     - *kraft lignin*
     - *kraft\-lignin*
     - *organosolv lignin*
     - *soda lignin*
   - **category:** Materials \& Chemistry
   - **See also:**
     - {term}`Biochar`
     - {term}`Pyrolysis`

Vitrimer
   A class of covalent adaptable network (CAN) polymer that behaves like a
   thermoset at low temperatures but can be reshaped, welded, or recycled
   above an activation temperature via bond-exchange reactions, offering a
   route to closed-loop recyclability.

   - **Also known as:**
     - *vitrimer polymer*
     - *vitrimeric*
     - *Covalent Adaptable Network*
     - *CAN polymer*
   - **category:** Materials \& Chemistry
   - **See also:**
     - {term}`CNT`

```

## Industrial Processes

```{glossary}
Additive Manufacturing
   Layer-by-layer fabrication of parts directly from a digital model,
   including fused deposition modeling (FDM), selective laser sintering (SLS),
   and other techniques.  Enables complex geometries and low-waste production.

   - **Also known as:**
     - *3d printing*
     - *Fused Deposition Modeling*
     - *FDM*
     - *Selective Laser Sintering*
     - *SLS*
   - **category:** Industrial Processes
   - **See also:**
     - {term}`Sintering`

Carbothermic
   A high-temperature reduction process in which a carbon source (coke,
   biochar, or graphite) reacts with a metal oxide to produce the elemental
   metal or carbide and CO/CO₂ off-gas.

   - **Also known as:**
     - *carbothermal reduction*
     - *carbothermal*
   - **category:** Industrial Processes
   - **See also:**
     - {term}`Biochar`
     - {term}`Ultrasonic`

Extrusion
   A continuous forming process in which material is forced through a shaped
   die.  Twin-screw extrusion is widely used for melt-compounding of polymers
   and composites.

   - **Also known as:**
     - *twin\-screw extrusion*
     - *single\-screw extrusion*
     - *melt processing*
   - **category:** Industrial Processes

Process
   In the sustainablefactory model, a discrete industrial or manufacturing
   operation described by input materials, equipment, parameters, outputs,
   costs, and associated metrics.

   - **category:** Industrial Processes
   - **See also:**
     - {term}`Knowledge Graph`

Pyrolysis
   Thermal decomposition of organic material at elevated temperatures in the
   absence of oxygen, converting biomass or polymers into biochar, bio-oil,
   and syngas.

   - **Also known as:**
     - *thermal decomposition*
     - *thermolysis*
     - *thermal cracking*
   - **category:** Industrial Processes
   - **See also:**
     - {term}`Biochar`
     - {term}`Lignin`

Sintering
   A powder consolidation process that bonds particles by heating below the
   melting point.  Spark plasma sintering (SPS) applies pulsed DC current for
   rapid densification.

   - **Also known as:**
     - *solid\-state sintering*
     - *Spark Plasma Sintering*
     - *SPS*
   - **category:** Industrial Processes
   - **See also:**
     - {term}`Additive Manufacturing`

Ultrasonic
   Processing that uses high-frequency (> 20 kHz) acoustic waves.  In
   ultrasonication (sonochemistry), cavitation micro-bubbles are exploited
   for dispersion, surface activation, or driving chemical reactions.

   - **Also known as:**
     - *ultrasonication*
     - *sonochemical*
     - *sonication*
     - *acoustic cavitation*
   - **category:** Industrial Processes
   - **See also:**
     - {term}`Carbothermic`

```

## Sustainability Metrics

```{glossary}
Circularity
   The degree to which materials and energy flows in an industrial system
   are recovered and re-used rather than discharged as waste, as measured
   by material circularity indicators and closed-loop recycling rates.

   - **Also known as:**
     - *circular economy*
     - *material circularity*
     - *closed\-loop recycling*
   - **category:** Sustainability Metrics
   - **See also:**
     - {term}`LCA`

GWP
   Global Warming Potential — the climate impact of a product or process
   expressed in CO₂-equivalent (CO₂eq) mass over a 100-year horizon,
   as quantified in a life cycle assessment.

   - **Also known as:**
     - *global warming potential*
     - *co2 equivalent*
     - *co2eq*
     - *carbon footprint*
   - **abbreviation:** GWP
   - **category:** Sustainability Metrics
   - **See also:**
     - {term}`LCA`

LCA
   Life Cycle Assessment — a systematic method for quantifying the
   environmental impacts of a product or process across its entire life
   cycle, from raw-material extraction through end-of-life treatment.

   - **Also known as:**
     - *life cycle analysis*
     - *life cycle assessment*
     - *lifecycle assessment*
   - **abbreviation:** LCA
   - **category:** Sustainability Metrics
   - **See also:**
     - {term}`GWP`
     - {term}`Circularity`

```

## Formats & Serializations

```{glossary}
Mermaid
   A JavaScript-based diagramming tool that renders graph, flowchart, and
   sequence diagrams from plain-text markup embedded in Markdown fences.

   - **category:** Formats \& Serializations
   - **See also:**
     - {term}`MyST`

MyST
   Markedly Structured Text — a rich Markdown dialect (a superset of
   CommonMark) that supports Sphinx roles, directives, and cross-references,
   enabling technical documentation to be written in plain text files.

   - **Also known as:**
     - *myst markdown*
     - *markedly structured text*
     - *sphinx markdown*
   - **abbreviation:** MyST
   - **category:** Formats \& Serializations
   - **See also:**
     - {term}`Sphinx`

Sphinx
   A documentation build tool written in Python that converts reStructuredText
   and MyST Markdown source files into HTML, PDF, and other output formats.
   Used in this project to produce the HTML documentation site.

   - **category:** Formats \& Serializations
   - **See also:**
     - {term}`MyST`

Turtle
   Terse RDF Triple Language — a compact, human-readable text serialization
   format for RDF graphs. Files use the ``.ttl`` extension.

   - **category:** Formats \& Serializations
   - **See also:**
     - {term}`RDF`
     - {term}`Turtle-star`

Turtle-star
   A serialization format that extends Turtle with RDF-star syntax, allowing
   nested or annotated triples to be written concisely.

   - **category:** Formats \& Serializations
   - **See also:**
     - {term}`Turtle`
     - {term}`RDF-star`

```

## Other

````{glossary}
1PN
   {term}`Post-Newtonian expansion` of the {term}`GR` metric tensor
   (for predicting the orbits of celestial bodies including Perihelion of Mercury)

   - 1PN: {term}`GR` {term}`Gravity`

2.5PN
   {term}`Post-Newtonian expansion` of the {term}`GR` metric tensor
   (for predicting the {term}`Gravitational waves <GW>`
   of celestial bodies including Perihelion of Mercury)
   GW gravity

   - 2.5PN: {term}`GR` {term}`Gravitational waves<GW>`

Amplituhedron
   Grassmannian Yang-Mills Twistor String theory method for
   calculating scattering amplitude path integrals
   (without Feynman diagrams).

   - Tree-level $n$-point $\mathrm{N}^{k-2}\mathrm{MHV}$ amplitudes live in the positive Grassmannian $\mathrm{Gr}_{\ge 0}(k, n)$ mapped into $\mathrm{Gr}(k, k+4)$ (with $k=2, n=4$ MHV amplitudes on $\mathrm{Gr}_{\ge 0}(2,4)$ and lifted to $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4$ for complex phase interference).

   Our work here (with the "Turner models" etc.)
   gratefully extends from the Amplituhedron
   to additional applied domains of particle simulation.

   FWIU, Amplituhedron is integrated with B-model string theories,
   and our work with Witten {term}`Twistor string theory`
   and Cachazo's $\mathrm{SU}(4)$-based models (`CSW`, `BCFW`, `Cachazo–Skinner`, `CHY`)
   is unified via $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ (`docs/grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md`).

   - **wikipedia:** <https://en.wikipedia.org/wiki/Amplituhedron>
   - **definedBy:**
     - {cite:p}`arkani2014amplituhedron`
     - {cite:p}`arkani\-hamed\-bai\-lam2017`
     - {cite:p}`su4\-arkani2016`

BCFW
   Britto-Cachazo-Feng-Witten recursion method (2012) calculate
   {term}`Scattering amplitudes <Scattering amplitude>`

   - **Also known as:**
     - *Britto\-Cachazo\-Feng\-Witten*
     - *BCFW recursion*
   - **wikipedia:** <https://en.wikipedia.org/wiki/BCFW_recursion>

BCJ
   Gravity = Gauge x Gauge

   - **Also known as:**
     - *BCJ Double\-Copy*
     - *BCJ Duality*
     - *Double copy theory*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Double_copy_theory>

BEC
   Bose-Einstein Condensate

   - **Also known as:**
     - *Bose\-Einstein Condensate*
     - *Superfluid*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Bose%E2%80%93Einstein_condensate>

Bohmian blowup
   The blowup of $Q = -\frac{\hbar^2}{2m}\frac{\nabla^2\sqrt{\rho}}{\sqrt{\rho}}$ and $V = j/\rho$ as $\rho \to 0$ in
   {term}`de Broglie-Bohm theory` ({cite:p}`hirschfelder1974streamlines,hirschfelder1976vortices,philippidis1979quantum,wyatt1999quantum`),
   which causes nodal singularities and numerical instability in quantum trajectory simulation,
   alongside the vanishing of phase-gradient velocity $v_S = 0$ in stationary evanescent barriers ({cite:p}`sharoglazova_energyspeed_2025`).
   Resolved in our Three-Channel Plücker–Madelung–QFIM and Dual-`iGPE` trajectory model (`docs/grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md`).

Cachazo-Geyer gravity
   1PN-equivalent gravity from SU(4) {term}`Twistor string theory`

   - **definedBy:**
     - {cite:p}`su4\-cachazogeyer2012`

Classical mechanics
   - Newton, Leibniz, Euler

   - Newtonian mechanics: {term}`Newton's laws`

   - **Also known as:**
     - *CM*
     - *NM*
     - *Newtonian mechanics*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Classical_mechanics>

DDF
   Dilatant Dark Fluid is a quantum superhydrodynamic theory 
   of quantum mechanics with psi and phi and GPE,
   which has E_rel=0 against 1PN ({term}`GR` Gravity)

   - **Also known as:**
     - *Dilatant Dark Fluid*
   - **definedBy:** {cite:p}`fedi2026ddf`

e
   - e is a unversal constant
   - e is a transcendental number: in any radix other than e,
     e has a nonterminating decimal representation
   - 2.718... tran

   - **Also known as:**
     - *e*
     - *Euler\'s number*
     - *Napier\'s constant*
   - **wikipedia:** <https://en.wikipedia.org/wiki/E_(mathematical_constant)>

Energy-momentum relation
   More complete form of the {term}`Mass-energy equivalence`

   ```
   E^2 = (pc)^2 + (mc^2)^2

   E  = ((pc)^2 + (mc^2)^2)^(1/2)
   ```

   $$
     E^2 = (pc)^2 + (mc^2)^2
   $$

   $$
     E  = ((pc)^2 + (mc^2)^2)^(1/2)
   $$

   - **wikipedia:** <https://en.wikipedia.org/wiki/Energy%E2%80%93momentum_relation>

Eulerian mechanics
   - Compressible and incompressible fluid flows

   - **Also known as:**
     - *Euler equations*
   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Euler_equations_(fluid_dynamics)>
     - <https://en.wikipedia.org/wiki/Lagrangian_and_Eulerian_specification_of_the_flow_field>
     - <https://en.wikipedia.org/wiki/Continuum_mechanics#Eulerian_description>

Exterior algebgra
   Exterior algebra (or Grassmann algebra) of a vector space
   which defines a *wedge product* (*exterior product*).

   - **wikipedia:** <https://en.wikipedia.org/wiki/Exterior_algebra>

G-CSC
   Grassmannian Cuprate Superconductivity theory of superconductivity in Copper superconductors

   - **definedBy:** docs\/grassmannian\-cuprate\-superconductivity\-paper\.md

GPE
   Gross-Pitaevskii Equation; a nonlinear Schrödinger equation for simulating {term}`BEC` ("superfluids")

   - The {term}`Madelung equations` map the GPE into Eulerian quantum hydrodynamic equations.
     - However, in scalar representations there is {term}`Bohmian blowup` ($1/\rho$ divergence at $\rho \to 0$).
     - Our Homogeneous Plücker $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ Kähler formulation (`det(I_2 + W W^\dagger) >= 1`) and Three-Channel Plücker–Madelung–QFIM decomposition ($F_{\mu\nu} = 4 g_{\mu\nu}^{\mathrm{FS}}$) regularize vortex cores and dark fringes (`docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md`, `docs/grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md`, `docs/grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md`).

   - **Also known as:**
     - *Gross\-Pitaevskii Equation*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Gross%E2%80%93Pitaevskii_equation>

GR
   General Relativity (Einstein)

   Post-Newtonian expansions of the GR metric tensor:
   - {term}`1PN`
   - {term}`2.5PN`

   - **Also known as:**
     - *General Relativity*
   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/General_relativity>
     - <https://en.wikipedia.org/wiki/Tests_of_general_relativity>
   - **definedBy:**
     - {cite:p}`einstein1915perihelion`
     - {cite:p}`einstein1916grundlage`
     - {cite:p}`einstein1917relativitat`
     - {cite:p}`einstein1920relativity`
     - https:\/\/en\.wikipedia\.org\/wiki\/Relativity:\_The\_Special\_and\_the\_General\_Theory

Gr>0
   The Positive Grassmannian $\mathrm{Gr}_{\ge 0}(k, n)$ of real $k$-planes in $\mathbb{R}^n$ whose ordered $k \times k$ Plücker minors are all non-negative ($\Delta_I \ge 0$, {cite:p}`postnikov2006plabic,arkani2014amplituhedron`).

   - **Also known as:**
     - *Positive Grassmannian*
     - *Non\-negative Grassmannian*

Gravity
   The behavior of objects with mass in motion.

   Newton's calculus and Newtonian mechanics were developed
   to model the movements and the forces of massful bodies.

   See also:
   - {term}`QG` (Quantum gravity)
     - {term}`Turner models`

   - **Also known as:**
     - *G*
   - **wikipedia:** <https://en.wikipedia.org/Gravity>

GrC
   The Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k, n) = \mathrm{U}(n)/(\mathrm{U}(k)\times\mathrm{U}(n-k))$ of complex $k$-planes in $\mathbb{C}^n$, a compact Einstein–Kähler manifold of real dimension $2k(n-k)$, Plücker coordinate count $\binom{n}{k}$, and scalar curvature $R_{\mathrm{Gr}}(k, n) = n k (n - k)$.

   - **Also known as:**
     - *Complex Grassmannian*

GrC(2,4)
   The Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{CP}^5$ ($\dim_{\mathbb{R}} = 8$, $\binom{4}{2} = 6$ Plücker coordinates, $1$ quadratic Klein quadric relation $p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12} = 0$, Kähler scalar curvature $R_{\mathrm{Gr}}(2,4) = 16$).

   See Section 2 (Master Taxonomy Table of Lower Grassmannians) in `docs/grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md`.

iGPE
   Four distinct formulations unified in `Signals`: (1) Interactive GPE (`InteractiveGPEPoint`), (2) Inhomogeneous GPE (`InhomogeneousGPEPoint`), (3) Inverse GPE (`InverseGPEPoint`, `pluckerInversePotentialReconstruction`), and (4) Coupled Dual-Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee$ iGPE (`CoupledDualGrassmannianState`).

   - **Also known as:**
     - *inverse GPE*
     - *interactive GPE*
     - *inhomogeneous GPE*

LIG
   Laser-Induced Graphene is {term}`Graphene` which is manufactured by laser processing.

   - **Also known as:**
     - *Laser\-Induced Graphene*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Graphene_production_techniques#Laser-Induced_Graphene_(LIG)>

Madelung equations
   Equations of quantum hydrodynamics

   - The Madelung equations are a quantum mechanical implementation of the Euler equations.
   - The Madelung equations are an alternative to the Schrödinger equation.
   - The Madelung equations can be simulated with {term}`Euler equations <Eulerian mechanics>`:
     - Runga-Kutta (RK) + Euler-Korteweg equations
     - Lifted onto $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{CP}^5$ in `docs/grassmannian-madelung-lagrangian-ddf-jamming-paper.md`, `docs/grassmannian-complex-gpe-igpe-plucker-madelung-paper.md`, `src/signals/Signals/DDF.lean`, and `src/signals/numerical_adapter/src/madelung_lagrangian.rs`.
   - The {term}`Madelung equations` map the {term}`GPE` into Eulerian quantum hydrodynamic equations.

   - **wikipedia:** <https://en.wikipedia.org/wiki/Madelung_equations>

MAPE
   Mean Absolute Percentage Error

   - **wikipedia:** <https://en.wikipedia.org/wiki/Mean_absolute_percentage_error>

Mass-energy equivalance
   Theory that Energy (E) equal mass (m) times the speed of light squared (c^2),
   wherein "times" is the (metric) tensor product operator.

   ```
   E = mc^2
   ```

   $$
     E = mc^2
   $$

   - **wikipedia:** <https://en.wikipedia.org/wiki/Mass%E2%80%93energy_equivalence>

Minkowski spacetime
   flat space

   - **wikipedia:** <https://en.wikipedia.org/wiki/Minkowski_spacetime>

MZM
   Majorana Zero Fermion; topologically protected quantum state

   - **Also known as:**
     - *Majorana near\-zero Fermion*
   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Majorana_fermion>

Newton's laws of motion
   Newton's laws:

   1. inertia / conservation symmetry
   2. `F = ma` Force = mass \* acceleration
   3. equal and opposite forces

   - **Also known as:**
     - *Newton\'s laws*
     - *Newtonian mechanics*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Newton%27s_laws_of_motion>

Orbit
   - Copernicus
   - Ptolemy
   - Galileo proposed that the universe revolves around the sun 
     (heliocentrism) which was heretical at the time.
   - Kepler
   - Einstein ({term}`GR` {term}`1PN`, {term}`2.5PN`)

   - **wikipedia:** <https://en.wikipedia.org/wiki/Orbit>

pi
   - pi (`π`) is approximately equal to 3.14159265359... in radix-10 (decimal notation).
   - pi is a universal constant.
   . pi is a transcendental number: in any radix other than pi,
     pi has a nonterminating decimal representation.
   - pi is the ratio of the circumference of a perfect circle to its radius/diameter:  
     `circumference = (2*radius)*pi`.
   - Approximations of pi:
     ```
     pi      = 3.14159265359
     22/7    = 
     355/113 = 
     666/212 = 3.14150...
     ```

   - **Also known as:**
     - *π*
   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Pi>
     - <https://en.wikipedia.org/wiki/Approximations_of_pi>

Planck constant
   - `h = 1 quanta`
   - Unit of mass (`Joule-second = kg*m^2*s^{-1}`)
   - Is now the basis for the kilogram SI unit

   - **Also known as:**
     - *h*
     - *quantum of action*
     - *1 quanta*
   - **symbol:**
     - h
   - **year:** 1900
   - **wikipedia:** <https://en.wikipedia.org/wiki/Planck_constant>

Post-Newtonian expansion
   - 1PN: {term}`GR` {term}`Gravity`
   - 2.5PN: {term}`GR` {term}`Gravitational waves<GW>` 
   - TODO: on 3 and 3.5PN

   - **Also known as:**
     - *1PN*
     - *2\.5PN*
     - *3PN*
     - *3\.5PN*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Post-Newtonian_expansion>

QCI-GXC
   Quantum Causal Inference Grassmannian Exchange-Correlation (`QCI-GXC`) unrestricted spin-polarized Kohn–Sham Density Functional Theory on $\mathrm{Gr}_{\mathbb{C}}(N_\alpha, M) \times \mathrm{Gr}_{\mathbb{C}}(N_\beta, M)$ with unitary Cayley retractions and McWeeny idempotency purification.

   - **name:** QCI\-GXC
   - **hame:** QCIGXC
   - **hame\_lower:** qcigxc
   - **name\_full:** Quantum Causal Inference Grassmannian Exchange\-Correlation Functional
   - **Also known as:**
     - *Quantum Causal Inference Grassmannian Exchange\-Correlation Functional*
   - **definedBy:** \/workspaces\/sustainablefactory\/docs\/grassmannian\-kohn\-sham\-dft\-complex\-plabic\-vrc\-paper\.md

QED
   Quantum Electrodynamics

   - **wikipedia:** <https://en.wikipedia.org/wiki/Quantum_electrodynamics>

QFT
   Quantum Field theory

   - **wikipedia:** <https://en.wikipedia.org/wiki/Quantum_field_theory>

QFTCS
   Quantum Field theory in curved Minkowski spacetime

   - **wikipedia:** <https://en.wikipedia.org/wiki/Quantum_field_theory_in_curved_spacetime>

QG
   Quantum Gravity

   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Quantum_gravity>

QTT
   Quantum Trajectory Theory ({cite:p}`carmichael1993open,dalibard1992wave,plenio1998quantum,murch2013observing,roch2014observation,campagne2016observing,santos2012quantum,minev2019catch`).
   See `docs/grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md`.

   - **Also known as:**
     - *Quantum Trajectory Theory*
     - *quantum jump method*
     - *Monte Carlo Wave Function method*
     - *MCWF*
   - **wikipedia:** <https://en.wikipedia.org/wiki/Quantum_Trajectory_Theory>

Quantum mechanics
   - {term}`Scattering amplitudes`
   - {term}`Probability_amplitude`
   - {term}`Quantum superposition`

   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Quantum_mechanics>
     - <https://en.wikipedia.org/wiki/Mathematical_formulation_of_quantum_mechanics>

Qudit
   - {cite:p}`deutsch1985churchturing`

   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Qudit>
     - <https://en.wikipedia.org/wiki/Qudit#Qudit_states>
     - <https://en.wikipedia.org/wiki/Qudit#Physical_implementations>

Reduced Planck constant
   {term}`Planck constant` divided by 2 times {term}`Pi`

   - ℏ = h/2*pi
   - hbar = h/2*pi

   - **Also known as:**
     - *ℏ*
     - *h\-bar*
   - **symbol:**
     - ℏ

Semilatus rectum
   Length ℓ of the chord through one focus which is perpendicular to the major axis directrix (Latus rectum) times 1/2.

   - **symbol:** ℓ
   - **mathworld:** https\:\/\/mathworld\.wolfram\.com\/SemilatusRectum\.html
   - **wikipedia:** <https://en.wikipedia.org/wiki/Ellipse#Semi-latus_rectum>

SPH
   Smoothed-Particle Hydrodynamics — a meshfree Lagrangian particle method for simulating continuum fluid flows.

   - **wikipedia:** <https://en.wikipedia.org/wiki/Smoothed-particle_hydrodynamics>

SQG
   Superfluid Quantum Gravity; post-SPH Smoothed Particle Hydrodynamics (1970s) theories of gravity:

   - Fedi's SQG (2016, 2017)

   - **definedBy:**
     - {cite:p}`fedi2017darksuperfluid`
     - {cite:p}`unif\-fedi2017`

SR
   Special Relativity (Einstein, Galilei, Michelson, Lorentz, Poincaré, Planck, Minkowski,)

   - **Also known as:**
     - *Special Relativity*
   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Special_relativity>
     - <https://en.wikipedia.org/wiki/History_of_special_relativity>
     - <https://en.wikipedia.org/wiki/Tests_of_special_relativity>
     - <https://en.wikipedia.org/wiki/Minkowski_spacetime>
   - **definedBy:**
     - {cite:p}`Einstein1905`
     - https:\/\/en\.wikipedia\.org\/wiki\/Annus\_mirabilis\_papers\#Special\_relativity

Standard Model
   Standard Model of particle physics

   https://en.wikipedia.org/wiki/Elementary_particle#Beyond_the_Standard_Model

   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Standard_Model>

String theory
   Theory of physics with strings instead of point-like particles

   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/String_theory>

SU
   Special Unitary group

   SU(4) is a Special Unitary group of degree 4.

   - **wikipedia:** <https://en.wikipedia.org/wiki/Special_unitary_group>

SU(4)
   Special Unitary group of degree 4 (the Lie group of 4x4 matrices with determinant 1)

   SU(4) has a real dimension of 15 (n^2-1).

   SU(4) is locally isomorphic to spin group Spin(6).

   SU(4) is the R-symmetry group in 4D N=4 supersymmetric Yang-Mills theory.

   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/Special_unitary_group#SU(4)>

SYM
   N=4 supersymmetric Yang-Mills theory

   SYM does not model gravity.

   - **wikipedia:**
     - <https://en.wikipedia.org/wiki/N_%3D_4_supersymmetric_Yang%E2%80%93Mills_theory>

Turner Model 12
   Flat-Space GrC(2,4) BCJ Double Copy + Splats, No DDF

   Gimbal-lock-free spinor splat orientation + 3D GrC(3,6) focal E_z

   - **definedBy:** docs\/grassmannian\-gravity\-from\-qed\-scattering\-paper\.md

Turner Model 13
   Unified GrC(2,4) + Conservative DDF + 3D Splat

   Combines 3D splat Bohm–Fisher core 
   1/2 Q_core(Σ) with nonlocal DDF tubular soliton stability

   - **definedBy:** docs\/grassmannian\-gravity\-from\-qed\-scattering\-paper\.md

Turner Model 14a
   Klein Quadric Q_4 Kähler (without DDF)

   Exact Heaviside–Larmor duality norm ∣Ψ′∣^2 + ∣Φ′∣^2,
   ghost-free 2-derivative Kähler action,
   M1-M3 TRUE soft-photon bridge

   - **definedBy:** docs\/grassmannian\-complex\-gpe\-igpe\-plucker\-madelung\-paper\.md

Turner Model 14b
   Klein Quadric Q_4 Kähler (with DDF)

   Exact Heaviside–Larmor duality norm ∣Ψ′∣^2 + ∣Φ′∣^2,
   ghost-free 2-derivative Kähler action,
   M1-M3 TRUE soft-photon bridge

   - **definedBy:** docs\/grassmannian\-complex\-gpe\-igpe\-plucker\-madelung\-paper\.md

Turner Model 15a
   - No-DDF
   - Does predict photon deflection

   - **definedBy:** TODO

Turner Model 15b
   - DDF
   - Does not do deflection

   - **definedBy:** TODO

Turner Model 6
   Homogeneous Plücker $\mathcal{Q}_4$ Madelung & Dual-`iGPE` Superposition (`Signals.DDF.pluckerMadelungSuperpositionOAMDoubleSlit`, `SlitModelKind::PluckerMadelungDualIgpe`).

   - **definedBy:** docs\/grassmannian\-complex\-gpe\-igpe\-plucker\-madelung\-paper\.md

Turner Models
   Models of Electrons, Photons, and Gravity (and Polaritons, Plasmons)

   These "Turner Models" are currently named
   according to the table row number in:
   - `docs/grassmannian-gravity-from-qed-scattering-paper.md` (Section 6.2 & Section 8.2, Models `1`–`13`, `14a`, & `14b`)

   They are further compared in, for example:
   - `docs/grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md` (Section 3, `#sec-em-master-table`)
   - `docs/grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md` (Section 2, `#sec-qt-master-comparison-table`)

````
