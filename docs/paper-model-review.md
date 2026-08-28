# Paper Model Review

This page reviews every PDF currently supplied in `data/papers/`, the earlier
linked articles, and the latest sources requested for review. The
equations below are transcribed as finite model contracts in the verified and
Pending Signals modules. Lean checks the stated algebra and inequalities; it
does not establish that a Proca field exists in vacuum, that a material
realizes a response tensor, that a code is fault tolerant on hardware, or that
any proposed device has been independently benchmarked.

## Status boundary

The implementation uses three levels of interpretation:

| Level | Meaning in this project |
| --- | --- |
| Checked algebra | A finite equation, normalization, positivity result, or pattern identity is proved by Lean from explicit fields and hypotheses. |
| Conditional model | A paper-specific constitutive, cavity, source, or quantum-response equation is stored as supplied model data. Its assumptions remain visible in the record. |
| Experimental status | A realization, calibration, loss measurement, boundary-condition determination, or device performance claim. The source set does not provide this evidence for the Sustainable Factory proposals. |

The paper equations therefore support the first two levels only. They do not
support SQG, spacetime fracture, Amplituhedron, Hawking decoding, vacuum-energy,
Proca propulsion, FRC-density, Argon-ionization, or over-unity MHD claims.

## Evidence table

| Source | Main models | Lean extraction | Evidence status |
| --- | --- | --- | --- |
| [PhysRevResearch.5.033110.pdf](../data/papers/PhysRevResearch.5.033110.pdf) | Polarization coherence spectrum; normalized Schmidt weight; $P_N^2+K_N^2=1$; barycentric center of mass; Huygens-Steiner inertia mapping | `Signals.Coherence.CoherenceSpectrum`, `CoherenceComplementarity`, `HuygensSteinerMapping` | peer-reviewed theoretical and mathematical model; not a QND or Amplituhedron result |
| [s41467-021-24493-y.pdf](../data/papers/s41467-021-24493-y.pdf) | Scalar phase singularities; polarization singularities; phase-gradient optimization; finite-aperture metasurface realization | No dedicated record yet; measured fields can use `Signals.IQ` and `Signals.Scattering` | experimental optical field engineering; not QND, loop-amplitude, or Amplituhedron evidence |
| [2403.19745](https://arxiv.org/abs/2403.19745) | Graphite/graphene plasmonic cavity; gate-tunable carrier-density resonances; avoided crossings; spectral-weight transfer; ultrastrong coupling | `CoupledCavityModes`, `CarrierDensityResonance`, `SpectralWeightTransfer` | on-chip THz experiment and analytical model; not a generic optical cavity or QND result |
| [2501.18881](https://arxiv.org/abs/2501.18881) | Grover state preparation; two-dimensional target-state rotation; cavity reflection phase oracle; collective dispersive atom-cavity shift | `GroverRotation`, `CavityQEDPhaseOracle`, `DickeStateOverlap` | theoretical proposal/companion letter; ideal unitary limit requires explicit cavity assumptions |
| [2501.18884](https://arxiv.org/abs/2501.18884) | Deterministic Dicke/GHZ/Cat preparation; global rotations; photon reflections; mode matching; Kraus error model; heralding | `GroverCavityFidelityScaling` plus shared Pending records | theoretical long paper with numerical error analysis; “deterministic” refers to the ideal protocol, not unit-fidelity hardware |
| [2607.23013v1.pdf](../data/papers/2607.23013v1.pdf) | Nonlinear planar Proca plus Chern-Simons electrodynamics; background-field response; transverse/longitudinal dielectric laws | `PlanarProcaCSResponse` | arXiv preprint; theoretical constitutive model |
| [Annalen der Physik - 2023 - Mikki - On the Interaction of Massive Photons and Mechanical Oscillators in Cavity.pdf](../data/papers/Annalen%20der%20Physik%20-%202023%20-%20Mikki%20-%20On%20the%20Interaction%20of%20Massive%20Photons%20and%20Mechanical%20Oscillators%20in%20Cavity.pdf) | Proca dispersion; Fabry-Perot resonance; radiation pressure; quantum cavity Hamiltonian | `MassiveCavityMode` | theoretical paper; the authors state that laboratory realization of Proca material had not yet been achieved |
| [On_the_Directivity_of_Radiating_Quantum_Electromagnetic_Systems.pdf](../data/papers/On_the_Directivity_of_Radiating_Quantum_Electromagnetic_Systems.pdf) | Density-operator photon detection; quantum directivity; two-mode interference; nonlocalizability | `QuantumSourceDirectivity`, `NonlocalityDecay` | theoretical operator and detection-rate model |
| [proca-metamaterials-massive-electromagnetism-and-nonlocality-3u1dghjsii.pdf](../data/papers/proca-metamaterials-massive-electromagnetism-and-nonlocality-3u1dghjsii.pdf) | Maxwell-Proca equivalence through a nonlocal dielectric tensor; cutoff; longitudinal/transverse waves; dipole patterns | `ProcaDispersion`, `ProcaMaterialResponse`, `ProcaDipolePattern` | exact mathematical equivalence under response assumptions; material design and realization remain open |
| [Low-power integrated optical amplification through second-harmonic resonance](https://doi.org/10.1038/s41586-025-09959-z) | Thin-film lithium-niobate $\chi^{(2)}$ integrated OPA; second-harmonic resonance; gain, bandwidth, input/pump power, output, and loss bookkeeping | `SecondHarmonicResonance`, `ActiveOpticalAmplifier`, `LowPowerIntegratedOPA` | peer-reviewed Nature device report; reported $>17$ dB gain and $<200$ mW input power, not a Lignolux validation or free-energy result |
| [Coherent surface plasmon polariton amplification via free-electron pumping](https://doi.org/10.1038/s41586-022-05239-2) | Free-electron-pumped THz SPP; phase-matched coherent gain; interaction length; twofold redshift; pump and loss accounting | `SPPFreeElectronAmplifier` | peer-reviewed Nature experiment/theory; the user-linked Nature page is news coverage, while phase-matched superradiant growth remains a model prediction |
| [Coherent synchrotron radiation by excitation of surface plasmon polariton on near-critical solid microtube surface](https://doi.org/10.1103/cnym-16hc) | Cylindrical SPP mode; edge and azimuthal phase matching; overlap; Vavilov-Cherenkov angle; coherent $N^2$ versus incoherent $N$ scaling | `CylindricalSPPMode`, `CoherentRadiationScaling`, `CherenkovAngleModel` | theory and 3D PIC simulation; reported coherence enhancement is simulated, with fabrication, contrast, alignment, and survivability limits |
| [Layer codes](https://doi.org/10.1038/s41467-024-53881-3) | CSS-to-3D topological-code lift; surface-code layers and 1D junctions; check-weight bound six; logical/distance and energy-barrier scaling metadata | `CSSStabilizerCode`, `LayerCodeLift` | peer-reviewed mathematical construction; no decoder, threshold, or NISQ hardware benchmark is encoded |
| [Protocol Z.8 repository](https://github.com/ENKI-420/consensus-quantum-protocol) | Ten-node majority rule; reported IBM backend/job/counts; five-run heartbeat fidelities; evidence-status boundary | `majorityDecision`, `ConsensusObservation`, `HeartbeatExperiment`, `ProtocolZ8ReportedBenchmark` | self-reported repository evidence, including a rounded 92.42% five-run average; incomplete raw-count/reproduction evidence means 98.85% is not independently verified |
| [Logical states for fault-tolerant quantum computation with propagating light](https://doi.org/10.1126/science.adk7560) | Propagating optical GKP qubit; displacement stabilizers; cat-state interference; homodyne characterization | `GKPQuditModel` as a Pending geometry analogue; existing `Signals.Homodyne` for classical readout adapters | peer-reviewed optical experiment; one-step finite GKP-state demonstration, not a completed fault-tolerant processor or 100-mode OAM code |
| [Quantum error correction of qudits beyond break-even](https://doi.org/10.1038/s41586-025-08899-y) | GKP qutrit/ququart; generalized Weyl operators; finite-energy envelope; decay-rate QEC gain | `GKPQuditModel`, `QuditQECGainObservation`, `OAM100QuditQECDesign` | peer-reviewed experiment; logical qutrit/ququart gains above break-even, not an OAM-100 implementation |
| [Optical pumping controls anisotropic response in semi-Dirac systems](https://doi.org/10.1103/dfbv-9vcj) | Two-band semi-Dirac dispersion; CW pump-dependent nonthermal occupations; anisotropic probe conductivity and polarization rotation | `SemiDiracDispersion`, `SemiDiracOpticalResponse`, `SemiDiracOpticalPowerBudget` | peer-reviewed theoretical optical-response study; no transferable graphene-formation power specification |
| [Colloquium: Semi-Dirac Fermions in Quantum Matter](https://arxiv.org/abs/2607.20627) | Review of linear/quadratic quasiparticle dispersion, Lifshitz-transition context, synthetic lattices, and quantum materials | `SemiDiracDispersion` as a normalized conditional model | arXiv review submitted in 2026; not a process recipe or material-realization benchmark |

## 1. Polarization-entanglement complementarity and Huygens-Steiner mapping

**Citation.** Xiao-Feng Qian and Misagh Izadi, "Bridging coherence optics and
classical mechanics: A generic light polarization-entanglement complementary
relation," *Physical Review Research* 5, 033110 (2023), DOI
[10.1103/PhysRevResearch.5.033110](https://doi.org/10.1103/PhysRevResearch.5.033110).
The supplied file is [PhysRevResearch.5.033110.pdf](../data/papers/PhysRevResearch.5.033110.pdf).
The title page identifies the authors, citation, publication date, and DOI
(p. 1).

### Models extracted

1. **Finite coherence spectrum.** A normalized light field is decomposed into
   polarization and amplitude degrees of freedom. The normalized coherence
   matrix has eigenvalues $m_i$ with $\sum_i m_i=1$ (pp. 1-2, Eqs. (1)-(3)).
2. **Degree of polarization.** For an $N$-dimensional field, the squared
   normalized degree of polarization is
   $$
   P_N^2 = \frac{N}{N-1}\sum_i m_i^2 - \frac{1}{N-1}.
   $$
   This follows from Eq. (15) and the eigenvalue form in the Appendix (pp. 2
   and 5-6).
3. **Schmidt-weight entanglement.** The normalized Schmidt weight has squared
   value
   $$
   K_N^2 = \frac{N}{N-1}\left(1-\sum_i m_i^2\right).
   $$
   The paper derives $P_N^2+K_N^2=1$ in Eq. (18) and Appendix Eq. (A7) (pp.
   4-6).
4. **Barycentric mapping.** The eigenvalues are mapped to point masses at the
   vertices of a regular simplex. The distance from the geometric center to
   the center of mass represents $P_N$, while the complementary distance
   represents $K_N$ (pp. 2-5, Eqs. (9)-(11) and (19)).
5. **Huygens-Steiner relation.** The mapped point masses obey
   $$
   I_O=I_M+m_{tot}d^2.
   $$
   Under the paper's normalized $m_{tot}=1$ convention, the squared optical
   quantities are related to the inertia difference and its complement (p. 3,
   Eqs. (12)-(13)).
6. **Interpretation boundary.** The paper notes an analogy with quantum pure
   states, but this classical vector-space nonseparability is not a QND
   measurement, a no-collapse theorem, or evidence for Amplituhedron physics
   (p. 5).

### Lean boundary

`CoherenceSpectrum` stores the finite normalized eigenvalue data and defines
the two squared measures. `CoherenceSpectrum.squared_complementarity` proves
the paper's identity directly from normalization. `CoherenceComplementarity`
attaches explicit nonnegative $P_N$ and $K_N$ values to those squared laws.
`HuygensSteinerMapping` stores the unit-mass inertia relation and proves the
parallel-axis displacement identity. These records are verified algebra and
finite model data; they do not formalize arbitrary Hilbert spaces, optical
propagation, quantum collapse, or an Amplituhedron realization.

### Connections to Signals metrology

The paper's amplitude vectors and coherence quantities connect naturally to
the existing finite coherent-receiver layer, but the connection is a
composition of models rather than an additional physical theorem:

- [Signals/IQ.lean](../src/signals/Signals/IQ.lean) represents a complex
   baseband amplitude as `I + iQ`, with checked magnitude and principal-phase
   identities. This is the coordinate representation needed before estimating
   a coherence matrix from sampled field components.
- [Signals/Homodyne.lean](../src/signals/Signals/Homodyne.lean) proves that an
   ideal 50:50 mixer conserves finite I/Q energy and that the balanced detector
   difference is the interference term, equivalently a local-oscillator-phase
   rotated quadrature. This supplies the interferometric observable, not a proof
   of the paper's polarization-entanglement identity from detector data.
- [Signals/Scattering.lean](../src/signals/Signals/Scattering.lean) stores a
   coherent incident/return pair, proves nonnegative scattered-to-incident
   power ratio, reconstructs height from a reference-subtracted round-trip
   phase, and accepts a metrology record only within an explicit residual
   tolerance. This supplies a scattering-metrology adapter for measuring the
   field amplitudes used by a coherence analysis.

A defensible measurement pipeline is therefore: acquire polarization-resolved
complex samples; estimate a finite coherence matrix or its normalized spectrum;
compute $P_N$ and $K_N$; and independently retain homodyne energy conservation,
scattering power, phase-to-height reconstruction, calibration, and residual
controls. A phase shift or a nonzero $K_N$ is not by itself a QND or
no-collapse result. The project’s [phase-wake protocol](dispersive-homodyne-plan.md)
requires matched controls, independent target-phase measurements, absorption,
loss, dephasing, and repeatability checks.

### Related experimental extension: phase and polarization singularity sheets

**Citation.** Soon Wei Daniel Lim, Joon-Suh Park, Maryna L. Meretska, Ahmed
H. Dorrah, and Federico Capasso, "Engineering phase and polarization
singularity sheets," *Nature Communications* 12, 4190 (2021), DOI
[10.1038/s41467-021-24493-y](https://doi.org/10.1038/s41467-021-24493-y). The
supplied file is [s41467-021-24493-y.pdf](../data/papers/s41467-021-24493-y.pdf).

This paper supplies an experimental optical extension of the phase and
polarization discussion, not an extension of the Qian-Izadi complementarity
identity or of amplitude geometry.

1. **Scalar phase singularity.** For a complex time-harmonic scalar field
   $E(\mathbf r)=\operatorname{Re}E+i\operatorname{Im}E$, the phase
   $\phi=\arg(E)$ is undefined where both real and imaginary parts vanish.
   The zero-isosurfaces can form point, line, or sheet singularities (pp. 2-3).
2. **Topological charge.** For a one-dimensional singularity, the paper uses
   $$
   s=\oint_C \frac{\nabla\phi}{2\pi}\cdot d\mathbf r,
   $$
   which is integer-valued when the phase is continuous on the enclosing loop
   and no singularity crosses it (p. 3). First-order line singularities are
   robust under small field perturbations, whereas point, higher-order line,
   and two-dimensional sheet structures are generally unstable (pp. 2-4).
3. **Engineering objective.** The paper maximizes a directed phase gradient at
   selected positions to align the real and imaginary zero-isosurfaces and
   produce an approximately dark sheet. It explicitly notes that a finite
   aperture and early termination of the optimization yield approximate,
   finite structures rather than an infinite exact singularity (pp. 3-5).
4. **Polarization singularity.** For a paraxial vector field, the complex
   scalar
   $$
   \sigma=|E_x|^2-|E_y|^2+2i\operatorname{Re}(E_xE_y^*)=s_1+i s_2
   $$
   has $\arg(\sigma)=2\Psi$, where $\Psi$ is the polarization-ellipse
   azimuth. The zeros of $s_1$ and $s_2$ define the corresponding azimuthal
   singularity; total intensity can remain nonzero through the $s_3$ component
   (p. 6).
5. **Experiment and limits.** The authors fabricate TiO2-on-SiO2 metasurfaces
   and characterize 532 nm heart-shaped phase and polarization singularity
   sheets with intensity, phase retrieval, and rotating-quarter-wave-plate
   polarimetry (pp. 5-8). The reported result validates optical field shaping
   for that apparatus. It does not establish a persistent photon wake, a
   non-destructive quantum measurement, a material-independent singularity, or
   a QED/amplitude-polytope correspondence.

The useful metrology connection is conditional: a known singularity pattern
can act as a phase-sensitive probe whose displacement or distortion is
compared against a weak-scattering model. The paper discusses reconstruction of
density fluctuations and currents in transparent or weakly scattering media
as a possible application, but that discussion is not a demonstrated ocean,
cloud, Lignolux, or quantum-device measurement (p. 7). In the Signals library,
`Signals.IQ` can store the complex samples and `Signals.Scattering` can store
coherent-return power, phase reconstruction, and residuals. A future Pending
record would still need a sampled field grid, a propagation kernel, a
phase-gradient estimator that handles branch cuts, singularity/topological
charge conditions, finite-aperture constraints, and calibration controls.

## Amplituhedron relationship

The attached paper does not use Amplituhedron geometry. Its central object is a
normalized polarization coherence matrix and its eigenvalue spectrum; the
Huygens-Steiner construction maps those eigenvalues to point masses on a
regular simplex. An Amplituhedron construction instead starts with a matrix
$C$ in a positive Grassmannian and a kinematic matrix $Z$, then studies the
image $Y=CZ$ and its canonical form. These are different mathematical
objects.

There is a possible interface for a larger scattering model:

1. Arrange measured polarization/mode amplitudes into a finite matrix $C$.
2. Use [Signals/Geometry.lean](../src/signals/Signals/Geometry.lean) to retain
    the unrestricted matrix and, only when experimentally or mathematically
    justified, impose positive ordered minors and Pluecker relations.
3. Form a normalized coherence matrix from the amplitude data and extract its
    eigenvalues $m_i$.
4. Apply the paper’s $P_N/K_N$ spectrum formulas to those eigenvalues.

Step 2 is an additional positive-Grassmannian assumption, not implied by
coherence, polarization, Huygens propagation, or scattering. The existing
`GrassmannianMatrix`, `PositiveGrassmannian`, and finite Pluecker identity are
therefore useful bookkeeping for a proposed kinematic embedding, while the
paper’s complementarity theorem remains independent of that embedding. No
current Lean theorem identifies the coherence spectrum with an Amplituhedron
canonical form, and none should be added without an explicit amplitude map,
positivity domain, boundary behavior, and a proof of the claimed relationship.

## Halohedron and Stokes-polytope extensions

The following statements are useful extensions of the positive-geometry
discussion, but they are narrower than the quoted summary. These papers are
external references rather than additional files in `data/papers/`.

### Halohedron: precise scope

**Primary references.** Giulio Salvatori, "1-loop Amplitudes from the
Halohedron," [Salvatori 2019](https://doi.org/10.1007/JHEP12(2019)074), arXiv:1806.01842v2
[hep-th] (2019), JHEP 12 (2019) 074, DOI
[10.1007/JHEP12(2019)074](https://doi.org/10.1007/JHEP12(2019)074), and
Giulio Salvatori and Sergio Cacciatori, "Hyperbolic Geometry and Amplituhedra
in 1+2 dimensions," [Salvatori and Cacciatori 2018](https://doi.org/10.1007/JHEP08(2018)167),
arXiv:1803.05809 [hep-th] (2018), DOI
[10.1007/JHEP08(2018)167](https://doi.org/10.1007/JHEP08(2018)167).

The accurate statement is:

> The Halohedron is a positive geometry proposed, and subsequently used, as a
> one-loop Amplituhedron for planar massless $\phi^3$ or bi-adjoint $\phi^3$
> scattering. Its canonical form yields a planar one-loop **integrand** after
> the paper's abstract propagator variables are related back to physical
> kinematic variables.

This is a meaningful loop-level extension of the tree-level associahedron, but
it is not a general geometry for all loop corrections. The construction uses
abstract variables associated with one-loop propagators and initially relaxes
some momentum-conservation identifications. That separation avoids problems
such as coincident propagators and double poles while the canonical form is
constructed; the physical substitutions restore the relevant kinematic
relations later. The Halohedron therefore organizes a particular planar
one-loop scalar integrand. It does not perform the loop integration, model
virtual particles as physical objects, or prove a general all-loop theorem.

The phrase "quantum fluctuations where virtual particles pop in and out of
existence" is a heuristic description of perturbative loop diagrams, not the
mathematical content of the Halohedron. A loop integrand is a rational
function/form in external and loop kinematic variables; whether it is
integrated, regularized, renormalized, and matched to an observable is a
separate QFT calculation.

### Stokes polytopes: precise scope

**Primary references.** Pinaki Banerjee, Alok Laddha, and Prashanth Raman,
"Stokes Polytopes: The positive geometry for $\phi^4$ interactions,"
[Banerjee et al. 2019](https://doi.org/10.1007/JHEP08(2019)067), arXiv:1811.05904v3 [hep-th]
(2019), JHEP 08 (2019) 067, DOI
[10.1007/JHEP08(2019)067](https://doi.org/10.1007/JHEP08(2019)067); Giulio
Salvatori and Stefan Stanojevic, "Scattering Amplitudes and Simple Canonical
Forms for Simple Polytopes," [Salvatori and Stanojevic 2021](https://doi.org/10.1007/JHEP03(2021)067),
arXiv:1912.06125v3 [hep-th] (2020); and Nikhil Kalyanapuram, "Stokes
Polytopes and Intersection Theory," [Kalyanapuram 2020](https://doi.org/10.1103/PhysRevD.101.105010),
arXiv:1910.12195v2 [hep-th] (2020), *Physical Review D* 101, 105010, DOI
[10.1103/PhysRevD.101.105010](https://doi.org/10.1103/PhysRevD.101.105010).

The accurate statement is:

> Stokes polytopes are positive geometries used to organize planar tree-level
> amplitudes in massless quartic $\phi^4$ theory. Their canonical forms have
> logarithmic boundary singularities associated with factorization channels,
> but one Stokes polytope is not enough in general: constituent polytopes must
> be combined with weights determined by combinatorial data to obtain the full
> planar amplitude.

Thus the quoted phrase "more generalized scalar field theories" is too broad.
The construction is a specific quartic planar scalar result. It is not a
generic replacement for an arbitrary scalar theory, and it does not mean that
every pole of every amplitude is automatically encoded by one Stokes polytope.
The factorization statement is conditional on the specified planar kinematics,
positive geometry, canonical form, and weighted assembly.

The intersection-theory extension introduces projective-space cycles and
Koba-Nielsen-like factors; its vanishing-$\alpha'$ limit reproduces the
$\phi^4$ amplitudes to leading order. This is an additional worldsheet/
intersection construction, not experimental evidence for a material or a
detector response.

### Light-by-light scattering is not automatically Halohedral

In ordinary abelian QED, the four-photon amplitude vanishes at tree level: the
classical Maxwell/QED Lagrangian has no direct four-photon vertex. The first
nonzero low-energy light-by-light amplitude is generated by a charged-matter
loop, such as the electron box diagram, and higher-loop corrections can then be
added. The Euler-Heisenberg $F^4$ interaction is an effective low-energy
description of this loop-induced physics; writing an $F^4$ term in an effective
Lagrangian does not turn it into a tree-level prediction of the underlying
renormalizable QED theory.

That fact does not make the Halohedron a QED photon-scattering geometry. The
Halohedron result is for planar scalar $\phi^3$ one-loop integrands. QED
light-by-light scattering additionally requires charged-fermion or charged-
matter loop numerators, gauge invariance, helicity/polarization dependence,
crossing, thresholds, and the appropriate unitarity cuts. A valid positive-
geometry claim for QED would need an explicitly defined kinematic space and
positive region whose canonical form or residues reproduce the QED amplitude.
No such identification follows from the Halohedron or Stokes-polytope papers.

### Relation to the Signals library

The current implementation has useful neighboring layers, but they must not be
collapsed into one claim:

- [Signals/Geometry.lean](../src/signals/Signals/Geometry.lean) provides finite
   matrices, ordered minors, optional positive ordered minors, and a Pluecker
   identity. These are prerequisites for positive-geometry bookkeeping, not a
   Halohedron, Stokes polytope, canonical differential form, or QFT amplitude.
- [Signals/Pending.lean](../src/signals/Signals/Pending.lean) contains the
   finite `AmplituhedronMap` and `LogarithmicChart`. Their $Y=CZ$ map, reciprocal
   chart, and measured-amplitude equality are explicit Pending data contracts;
   they do not prove that a measured optical or material signal is a scattering
   amplitude.
- [Signals/Scattering.lean](../src/signals/Signals/Scattering.lean) and
   [Signals/Homodyne.lean](../src/signals/Signals/Homodyne.lean) provide
   classical coherent-return, power-ratio, phase-reconstruction, residual, and
   quadrature-interference laws. These can supply calibrated measurements from
   which one might estimate event features, but they are not an S-matrix or a
   loop-integrand evaluator.
- [Signals/Coherence.lean](../src/signals/Signals/Coherence.lean) proves a
   normalized polarization/Schmidt-weight identity and a barycentric inertia
   relation. Those spectral and mechanical constructions are independent of
   the facet incidence and canonical forms used by amplitude polytopes.

If these extensions are formalized further, the conservative boundary is to
keep `Halohedron`, `StokesPolytope`, propagator labels, face incidence, and
canonical-form/residue laws in `Signals.Pending`. Verified code can prove
finite combinatorial identities and supplied rational-form equalities. It
should not assert `Halohedron = all quantum loop corrections`,
`StokesPolytope = arbitrary scalar amplitudes`, or
`coherence/scattering measurement = QED amplitude` without the missing
kinematic map, positivity, factorization, gauge, and validation assumptions.

### Extensions worth pursuing

1. **Higher $\phi^p$ tree interactions.** Positive tropical Grassmannian,
    accordiohedron, and related constructions provide candidate constituent
    geometries, but the appropriate combinatorial family and weighted assembly
    depend on the interaction and planar ordering.
2. **Higher loops.** The one-loop Halohedron is a model-specific starting point.
    Higher-loop geometries require new boundary strata, loop variables, and
    prescriptions for bubbles, tadpoles, overlapping channels, and
    regularization. They should not be inferred by simply adding more halos.
3. **Gauge theories and QED.** A transfer requires polarization/helicity data,
    gauge-invariant numerators, factorization and unitarity checks, thresholds,
    and a demonstrated canonical-form or residue map. The existing finite
    Grassmannian code is useful scaffolding but is not that proof.
4. **Scattering metrology.** A laboratory pipeline may use polarization-resolved
    I/Q acquisition, coherent scattering ratios, phase residuals, and control
    data to test an ordinary wave model. Only after a separate event-kinematic
    map and amplitude validation could those data be compared with a positive
    geometry; a good metrology residual alone is not evidence for an
    Amplituhedron, Halohedron, or QED loop interpretation.

## 2. Cavity electrodynamics of van der Waals heterostructures

**Citation.** Gunda Kipp, Hope M. Bretscher, Benedikt Schulte, Dorothee
Herrmann, Kateryna Kusyak, Matthew W. Day, Sivasruthi Kesavan, Toru Matsuyama,
Xinyu Li, Sara Maria Langner, Jesse Hagelstein, Felix Sturm, Alexander M.
Potts, Christian J. Eckhardt, Yunfei Huang, Kenji Watanabe, Takashi Taniguchi,
Angel Rubio, Dante M. Kennes, Michael A. Sentef, Emmanuel Baudin, Guido Meier,
Marios H. Michael, and James W. McIver, "Cavity electrodynamics of van der
Waals heterostructures," arXiv:2403.19745 [cond-mat.mes-hall] (2024), later
*Nature Physics* 21, 1926-1933 (2025), DOI
[10.1038/s41567-025-03064-8](https://doi.org/10.1038/s41567-025-03064-8). The
supplied source is [arXiv:2403.19745](https://arxiv.org/abs/2403.19745).

### Models extracted

1. **Graphite/graphene plasmonic cavity.** Finite graphite gates form a
   sub-wavelength plasmonic cavity with discrete standing current modes. The
   cavity and graphene collective modes lie in the GHz-THz range and are
   probed with on-chip THz time-domain spectroscopy (pp. 1-3).
2. **Gate-tunable matter resonance.** Graphene carrier density shifts the
   collective plasmon frequencies. The paper fits mode spectra with Lorentzian
   resonances and extracts frequency, linewidth, conductivity, and quality
   factor from the measured time-domain/reference response (pp. 3-5).
3. **Two-mode hybridization.** Near a cavity/matter resonance, the coupled
   frequencies are the eigenvalues of a two-mode interaction. In the
   resonant case, the splitting is $2g$ and the normalized coupling is
   $\eta=g/\nu_0$. The reported experiment finds $g\approx50\,\mathrm{GHz}$,
   $\nu_0\approx0.43\,\mathrm{THz}$, and $\eta\approx0.12$, placing that
   device in the paper's ultrastrong-coupling criterion $\eta>0.1$ (pp. 2 and
   6-7).
4. **Spectral-weight transfer.** The upper and lower hybrid branches exchange
   fitted Lorentzian spectral weight across the avoided crossing. The paper
   compares this transfer with analytical modeling and finite-element
   simulations (pp. 6-8).
5. **Sensing versus control geometry.** Thick hBN/graphite and near-complete
   coplanar coverage suppress mode overlap for sensing, while geometry that
   breaks momentum conservation increases overlap and coupling for control
   (pp. 7-8). These are device-design conclusions for the measured platform,
   not generic properties of graphite, graphene, or an arbitrary optical
   cavity.

### Lean boundary

`Signals.Pending.CoupledCavityModes` stores the real two-mode hybrid-frequency
law and proves the resonant splitting formula. `CarrierDensityResonance` keeps
a fitted carrier-density power law as model data, and
`SpectralWeightTransfer` proves equal-and-opposite transfer under an explicit
conservation field. The records do not assert that a Lignolux or graphite /
graphene cavity has the reported parameters, nor do they turn ultrastrong
coupling into QND readout, mass generation, or a Proca mode.

## 3. Efficient preparation of entangled states in cavity QED with Grover's algorithm

**Citation.** Omar Nagib, M. Saffman, and K. Mølmer, "Efficient preparation
of entangled states in cavity QED with Grover's algorithm," arXiv:2501.18881v4
[quant-ph] (2025), *Physical Review Letters* 135, 050601 (2025), DOI
[10.1103/3fzf-wsr2](https://doi.org/10.1103/3fzf-wsr2). The source is
[arXiv:2501.18881](https://arxiv.org/abs/2501.18881).

### Models extracted

1. **Two-dimensional Grover subspace.** Decompose the initial state into a
   target and orthogonal component,
   $$
   |\psi_i\rangle=\sin(\theta/2)|\psi_t\rangle+
   \cos(\theta/2)|\psi_{t,\perp}\rangle.
   $$
   A Grover iteration is the product of two phase inversions. After $k$
   iterations, the target amplitude is $\sin((2k+1)\theta/2)$ and ideal
   fidelity is its squared magnitude (pp. 1-2, Eqs. (1)-(7)).
2. **Exact finite-step condition.** Modified phase inversions can reach unit
   fidelity in an integer number of steps when the phase and initial overlap
   satisfy the stated trigonometric condition (p. 3, Eqs. (8)-(11)).
3. **Dicke-state overlap.** For a globally rotated product state, the overlap
   with the Dicke state having $m$ excitations is
   $$
   \binom{N}{m}^{1/2}\cos^{N-m}(\varphi/2)\sin^m(\varphi/2).
   $$
   Choosing the global rotation to maximize this overlap gives the favorable
   $m^{1/4}$ or $N^{1/4}$ step scaling in the stated regimes (pp. 3-5).
4. **Cavity-QED phase oracle.** In the dispersive regime $|\Delta|\gg g$,
   eliminating the excited state gives
   $$
   H=\hbar\Omega\hat m\hat n_c,\qquad \Omega=\frac{g^2}{\Delta},
   $$
   where $\hat m$ counts atoms in $|1\rangle$. The cavity resonance shifts as
   $\omega_m=\omega_0+m\Omega$, so a frequency-selective reflected photon can
   implement a conditional phase inversion on a selected Dicke component (p.
   2, Eqs. (3)-(5)).
5. **State targets and resources.** The paper applies the construction to
   Dicke, GHZ, and Cat states using global rotations and two or three photon
   reflections per iteration, without individual addressing. The claimed
   ideal resource scaling is algorithmic and conditional on the physical
   phase-oracle implementation (pp. 2-4).

### Lean boundary

`GroverRotation` stores the two-dimensional rotation and proves the ideal
one-step perfect-preparation case. `DickeStateOverlap` stores the finite
binomial overlap formula. `CavityQEDPhaseOracle` stores the dispersive shift,
selected-excitation resonance shift, and ideal reflected phase. These records
do not prove a cavity realizes the oracle, that a photon is perfectly
reflected, or that the prepared state survives loss and decoherence.

## 4. Deterministic carving of quantum states with Grover's algorithm

**Citation.** Omar Nagib, M. Saffman, and K. Mølmer, "Deterministic carving
of quantum states with Grover's algorithm," arXiv:2501.18884v4 [quant-ph]
(2025), *Physical Review A* 112, 012621 (2025), DOI
[10.1103/s3vs-xz7w](https://doi.org/10.1103/s3vs-xz7w). The source is
[arXiv:2501.18884](https://arxiv.org/abs/2501.18884).

### Models extracted

1. **Ideal deterministic protocol.** The long paper uses the same target-plane
   Grover rotation as the companion letter, with global single-qubit rotations
   and cavity-reflected photons implementing phase inversions. It gives exact
   integer-step conditions for Dicke states and extensions to GHZ and Cat
   states (pp. 2-7, Eqs. (1)-(35)).
2. **Cavity dispersive model.** With $\Omega=g^2/\Delta$, a selected Dicke
   component shifts the cavity resonance by $m\Omega$. A resonant photon
   reflection supplies the ideal sign change, while an off-resonant component
   is intended to receive no sign change (pp. 7-8, Eqs. (36)-(37)).
3. **Mode-mismatch channel.** If $\zeta$ is spatial mode-matching efficiency,
   the ideal phase inversion is replaced by a mixture of interacting and
   noninteracting branches,
   $$
   \rho\longmapsto\zeta\,\chi\rho\chi^\dagger+(1-\zeta)\rho.
   $$
   This is an error model, not a harmless calibration factor (p. 8, Eq. (38)).
4. **Finite-bandwidth/loss model.** The paper gives frequency-dependent
   reflection, transmission, spontaneous-emission, and mirror-scattering
   amplitudes, then combines their corresponding Kraus operators into a
   frequency-averaged quantum channel (pp. 8-11, Eqs. (40)-(47)).
5. **Fidelity scaling and heralding.** In the paper's leading estimates,
   unheralded phase-inversion infidelity scales as $C^{-1/2}$ and heralded
   infidelity as $C^{-2/3}$ for the nonzero selected-excitation cases, with
   $C=g^2/(\gamma\kappa)$. Finite wavepacket bandwidth and mode mismatch add
   further error. The paper estimates that high fidelity requires much larger
   cooperativity than the illustrative $C=100$ simulations (pp. 3-5 and
   9-12).
6. **Meaning of deterministic.** “Deterministic” describes the ideal
   protocol's absence of probabilistic restart or individual addressing. It
   does not mean unit fidelity in a lossy, finite-bandwidth, imperfectly
   mode-matched cavity. Heralding can improve conditional fidelity at the cost
   of success probability (pp. 4 and 11-12).

### Lean boundary

`GroverCavityFidelityScaling` stores cooperativity, bandwidth, mode matching,
heralding probability, and the two reported leading exponents. The ideal
rotation and phase-oracle records are shared with the companion article. No
Lean theorem treats the scaling exponents as measured constants, or identifies
the cavity protocol with a no-backaction/QND measurement.

## 5. Planar Proca metamaterials in nonlinear (2+1)-Electrodynamics

**Citation.** Widervan Morais, S. Strikos, R. Thibes, and J. A. Helayël-Neto,
"Investigating planar Proca metamaterials in nonlinear (2+1)-Electrodynamics,"
arXiv:2607.23013v1 [physics.optics], 25 July 2026. The supplied file is
[2607.23013v1.pdf](../data/papers/2607.23013v1.pdf). The title page supplies
the author list and arXiv identifier (p. 1).

### Models extracted

1. **Planar nonlinear field model.** The paper defines a (1+2)-dimensional
   field invariant, splits a propagating field from a constant electromagnetic
   background, and expands a nonlinear Lagrangian to second order. It adds a
   de Broglie-Proca mass, a Chern-Simons mass, and external source terms. The
   coefficients `C1` and `D1` are derivatives of the nonlinear Lagrangian with
   respect to the background invariant (p. 2). The field equations and
   subsidiary condition are given as Eq. (5) (p. 3).
2. **General response tensor.** After Fourier transformation, the paper writes
   an induced current response and normalized dielectric tensor. For electric
   and magnetic background fields, Eq. (23) contains the Proca term, the
   longitudinal $k_i k_j$ term, a background-field nonlinear contribution, and
   the Chern-Simons contribution (p. 4).
3. **Magnetic-background specialization.** With only a constant magnetic
   background, the paper obtains Eq. (24), then decomposes the response using
   transverse, longitudinal, symmetric, antisymmetric, and nilpotent operators
   (pp. 4-5). The transverse, longitudinal, and Chern-Simons scalar response
   components are listed in Eqs. (30)-(34):
   $$
   \bar\epsilon_T = 1 - \frac{M^2}{\omega^2},\qquad
   \bar\epsilon_L = 1 - \frac{M^2 + k^2}{\omega^2},\qquad
   \bar\epsilon_{CS} = \frac{i m}{\omega^3}.
   $$
4. **Dispersion and response conclusion.** In this specialization, the paper
   states that the transverse and longitudinal response laws are unchanged by
   the nonlinear and Chern-Simons terms, while the Chern-Simons contribution
   remains nonzero in the full tensor. It reports a small effective planar
   contribution, not a measured material response (pp. 5-7).

### Lean boundary

`PlanarProcaCSResponse` stores the transverse law, the spatially dispersive
longitudinal law, and a complex Chern-Simons response as explicit fields. Lean
checks those supplied equalities. The record does not assert that a planar
material has been fabricated, that the background equations describe a
particular Sustainable Factory material, or that the small contribution is
experimentally observable. The magnetic-background cancellation is represented
by the specialized response fields rather than promoted to a general theorem
about arbitrary backgrounds.

## 6. Massive photons and mechanical oscillators in cavity optomechanics

**Citation.** Said Mikki, "On the Interaction of Massive Photons and Mechanical
Oscillators in Cavity Optomechanics: Basic Model and Quantization," *Annalen
der Physik* 536 (2024), 2300288, DOI
[10.1002/andp.202300288](https://doi.org/10.1002/andp.202300288). The supplied
file is [the Annalen PDF](../data/papers/Annalen%20der%20Physik%20-%202023%20-%20Mikki%20-%20On%20the%20Interaction%20of%20Massive%20Photons%20and%20Mechanical%20Oscillators%20in%20Cavity.pdf).
The title page identifies Said Mikki and the DOI (p. 1).

### Models extracted

1. **Massive dispersion and cutoff.** The paper uses
   $$
   \omega^2 = c^2 k^2 + c^2 m^2
   $$
   and defines the photon-mass frequency
   $\omega_{ph}=m_{ph}c^2/\hbar$ (p. 4, Eqs. (3)-(4)). For real mass, real
   propagating wave number requires operation above the cutoff $\omega_{ph}$
   (p. 4).
2. **Fabry-Perot cavity.** For a cavity with dynamic length
   $L(t)=L_0+x(t)$, the fundamental resonance is
   $$
   \omega_l = \sqrt{\left(\frac{l\pi c}{L}\right)^2+\omega_{ph}^2}.
   $$
   This is Eq. (13), with the massless limit in Eq. (14) (p. 5). The paper
   explicitly assumes a single bulk mode and notes that additional waves at
   nonlocal interfaces are omitted from the subsequent simplified treatment
   (p. 4).
3. **Radiation pressure.** The paper derives the average massive-mode force
   from photon momentum transfer and obtains
   $\langle F_{msv}\rangle=\hbar\omega_{msv}\langle a^\dagger a\rangle/L$
   (p. 5, Eq. (18)). Relative to a massless cavity, the normalized ratio is
   $$
   \frac{\langle F_{msv}\rangle}{\langle F_0\rangle}
   = \sqrt{l^2+\alpha^2},
   \qquad \alpha=\frac{\omega_{ph}}{\omega_0},
   $$
   in the paper's mode normalization (p. 6, Eqs. (21)-(23)).
4. **Mechanical expansion.** The displaced resonance is expanded in powers of
   $x/L_0$, with coefficients $\beta_0$, $\beta_1$, and $\beta_2$ given in
   Eqs. (34)-(37) (pp. 7-8). The interaction Hamiltonian contains linear and
   quadratic displacement terms (p. 9, Eqs. (38)-(41)); the mechanical
   self-energy is $H_m=\omega_m b^\dagger b$ (p. 7, Eq. (27)).
5. **Realization boundary.** The experimental section requires construction
   of a Proca material and isolation/measurement of its bulk dispersion. The
   authors state that, to their knowledge, laboratory realization of the
   Proca material had not yet been achieved and that spatial dispersion
   requires material-specific additional boundary conditions (p. 10). The
   conclusion presents the work as a theoretical model and future experimental
   direction (p. 10).

### Lean boundary

`MassiveCavityMode` records positive massless and massive frequencies, the
square-root resonance relation in squared form, and the radiation-pressure
ratio. Lean proves that the massive frequency and ratio are at least the
massless values, and strictly larger when the supplied photon-mass frequency
is positive. These are consequences of the record's explicit resonance law;
they are not claims that a massive photon or a Proca cavity has been observed.

## 7. Directivity of radiating quantum electromagnetic systems

**Citation.** Said Mikki, "On the Directivity of Radiating Quantum Electromagnetic
Systems," *Electromagnetic Science* 2, no. 3, article 0070222 (2024), DOI
[10.23919/emsci.2024.0022](https://doi.org/10.23919/emsci.2024.0022). The supplied
file is [On_the_Directivity_of_Radiating_Quantum_Electromagnetic_Systems.pdf](../data/papers/On_the_Directivity_of_Radiating_Quantum_Electromagnetic_Systems.pdf).
The title page identifies Said Mikki, publication details, and DOI (p. 1).
The PDF metadata reports `SoWise` as author, which conflicts with the title
page and is treated here as a metadata error, not a second attribution.

### Models extracted

1. **Density-operator directivity.** Given field operator $E=E^{(+)}+E^{(-)}$
and radiation density operator $\rho$, Definition 1 defines the space-time
   directivity as a local detection-rate expectation divided by its angular
   average:
   $$
   D_q(|x|,\Omega;t)=
   \frac{\operatorname{Tr}(\rho E^{(-)}(x,t)\cdot E^{(+)}(x,t))}
   {\frac{1}{4\pi}\int_{4\pi}
   \operatorname{Tr}(\rho E^{(-)}(x,t)\cdot E^{(+)}(x,t))\,d\Omega}.
   $$
   The directivity is undefined when the denominator is identically zero
   (pp. 5-6, Definition 1).
2. **Positive local detector operator.** The paper contrasts the global number
   operator with the proposed local operator
   $$
   N(V)=\frac{2\epsilon_0\omega}{\hbar c}
   \int_V E^{(-)}(x,t)\cdot E^{(+)}(x,t)\,d^3x.
   $$
   Its integrand is positive, and Theorem 1 identifies it as a local number
   operator (p. 7, Eq. (4) and Theorem 1).
3. **Nonlocalizability.** For disjoint regions, the paper defines
   nonlocalizability through a nonzero commutator and proves that its proposed
   local operator is nonlocalizable (pp. 8-9, Definition 3 and Theorem 2). It
   estimates the separated-region commutator decay as $|x-x'|^{-4}$ (p. 9,
   Theorem 3), while noting that the correlation can be small at large
   separation.
4. **Single and two modes.** A single Fourier mode gives unit, isotropic
   directivity (p. 10, Eq. (19)). For two modes, the directivity contains
   interference through $\alpha_{ij}$ and a sinc factor depending on the
   wave-vector difference and position (pp. 10-12, Eqs. (20)-(27)). The paper
   treats the density operator as known input to the calculation (p. 10).

### Lean boundary

`QuantumSourceDirectivity` is a finite scalar ratio with an explicit positive
angular-average hypothesis. It proves nonnegativity and unit directivity for
the equal-rate isotropic case. `NonlocalityDecay` stores only the paper's
scalar inverse-fourth-power decay estimate and proves positivity; it does not
formalize field operators, commutators, Hilbert spaces, photon localization,
or a quantum antenna device. No claim of quantum hardware validation is made.

## 8. Proca metamaterials, massive electromagnetism, and nonlocality

**Citation.** Said Mikki, "Proca Metamaterials, Massive Electromagnetism, and
Nonlocality," supplied PDF [proca-metamaterials-massive-electromagnetism-and-nonlocality-3u1dghjsii.pdf](../data/papers/proca-metamaterials-massive-electromagnetism-and-nonlocality-3u1dghjsii.pdf).
The title page identifies Said Mikki (p. 1). The supplied copy does not expose
a journal DOI or publication venue in its front matter, so no DOI is inferred.

### Models extracted

1. **Maxwell-Proca equivalence target.** The paper defines a nonlocal,
   spatially dispersive response in Fourier space and chooses the induced
   current so Maxwell's material equations reproduce the Maxwell-Proca field
   equations. The conductivity tensor is Eq. (27), and the dielectric tensor
   is Eq. (28) (p. 5):
   $$
   \epsilon(k,\omega)=
   \left(1-\frac{m^2c^2}{\omega^2}\right)I
   -\frac{k^2c^2}{\omega^2}\hat{k}\hat{k}.
   $$
2. **Transverse/longitudinal decomposition.** Equations (29)-(34) split the
   response into
   $$
   \epsilon_T=1-\frac{m^2c^2}{\omega^2},\qquad
   \epsilon_L=1-\frac{c^2(k^2+m^2)}{\omega^2},
   $$
   with spatial dispersion present in the longitudinal component (p. 5).
   The paper emphasizes that this is a specially designed isotropic nonlocal
   medium, not an ordinary local dielectric (p. 6).
3. **Shared dispersion and cutoff.** The transverse and longitudinal modes
   satisfy the same law (p. 7, Eqs. (39)-(44)):
   $$
   \omega^2=c^2k^2+c^2m^2.
   $$
   For real mass, $k(\omega)$ is real only above $\omega_{ph}=mc$; below
   cutoff the solution is evanescent rather than a propagating power-transfer
   mode (p. 8). The paper also discusses imaginary mass as a separate formal
   case; it is not used in the Lean fixture.
4. **Design restrictions.** The nonlocality length scale is
   $\lambda_{ph}=2\pi/m$, and the paper requires restricted wavelength or
   wavenumber ranges for a practical quadratic-in-$k$ response. It gives an
   example design procedure, while noting tradeoffs between temporal cutoff,
   spatial dispersion, and higher-order response terms (pp. 10-12).
5. **Proca dipole radiation.** For an electrically small dipole, the transverse
   and longitudinal patterns are proportional to $|\hat{k}\times\hat{\alpha}|^2$
   and $|\hat{k}\cdot\hat{\alpha}|^2$, respectively (pp. 13-16, Eqs. (58)-(81)).
   For a dipole oriented along $z$, the paper gives complementary $\sin^2\theta$
   and $\cos^2\theta$ patterns and states that their total is isotropic (pp.
   13-14, Eqs. (61)-(64)).
6. **Realization boundary.** The paper distinguishes designing a response
   function from realizing a microscopic material. It presents the Proca MTM
   as a proposed nonlocal medium and discusses loss, interface, wavelength,
   and fabrication constraints; it does not provide a built prototype or
   evidence for Lignolux, atmospheric, propulsion, or MHD operation (pp. 3,
   10-12, and 15-16).

### Lean boundary

`ProcaDispersion` records a normalized positive-frequency mode, its nonnegative
mass and wave number, the real-wave cutoff, and the squared dispersion law.
`ProcaMaterialResponse` records the transverse and longitudinal dielectric laws
and proves that the longitudinal response is zero on the supplied dispersion
shell. `ProcaDipolePattern` records complementary finite angular patterns and
proves their sum is the isotropic scale. These are checked consequences of
explicit model assumptions, not a proof that a physical nonlocal metamaterial
exists.

## 9. Low-power integrated optical amplification through second-harmonic resonance

**Citation.** Devin J. Dean, Taewon Park, Hubert S. Stokowski, Luke Qi, Sam
Robison, Alexander Y. Hwang, Jason F. Herrmann, Martin M. Fejer, and Amir H.
Safavi-Naeini, "Low-power integrated optical amplification through
second-harmonic resonance," *Nature* 649, 1159-1164 (2026), DOI
[10.1038/s41586-025-09959-z](https://doi.org/10.1038/s41586-025-09959-z).

The public metadata and article summary identify an integrated optical
parametric amplifier on thin-film lithium niobate, with more than 17 dB gain
and less than 200 mW input power. The publisher's full-text endpoint was not
available during this review, so the finite equations below are a transparent
model abstraction rather than a claim that every device equation has been
transcribed from the inaccessible PDF.

### Models extracted

1. **Second-harmonic resonance.** The frequency relation used by the model is
   $$
   \omega_{2}=2\omega_{1},\qquad \omega_{r}=\omega_{2},
   $$
   with positive frequencies. This captures the resonance condition relevant
   to a chi^(2) parametric process without asserting a particular resonator
   geometry or phase-matching design.
2. **Active gain.** For a finite signal-power abstraction, let $G$ be the
   linear signal gain:
   $$
   P_{\mathrm{out}}=G P_{\mathrm{sig}},\qquad
   G_{\mathrm{dB}}=10\log_{10}G.
   $$
   The Lean record stores $G$ and the reported dB value separately; it does
   not manufacture a logarithmic conversion from a rounded headline number.
3. **Energy accounting.** An active amplifier must include its drive power and
   losses:
   $$
   P_{\mathrm{out}}+P_{\mathrm{diss}}
     =P_{\mathrm{sig}}+P_{\mathrm{pump}}.
   $$
   Consequently, nonnegative dissipation implies
   $P_{\mathrm{out}}\leq P_{\mathrm{sig}}+P_{\mathrm{pump}}$. Gain is not
   passive over-unity behavior or evidence of free energy.

### Lean boundary

`SecondHarmonicResonance` stores the frequency and resonance laws.
`ActiveOpticalAmplifier` stores signal input, pump, output, dissipation,
linear gain, and the active power balance. `LowPowerIntegratedOPA` adds the
reported gain floor, a positive bandwidth field, and a declared input-power
limit. The fixture bounds the supplied pump power by that limit, which keeps
the source's ambiguous public "input power" wording explicit rather than
silently treating signal and pump power as the same quantity. These records do
not establish thin-film material parameters, conversion efficiency, noise
figure, or Lignolux performance.

## 10. Coherent surface plasmon polariton amplification via free-electron pumping

**Primary citation.** Dongdong Zhang, Yushan Zeng, Yafeng Bai, Zhongpeng Li,
Ye Tian, and Ruxin Li, "Coherent surface plasmon polariton amplification via
free-electron pumping," *Nature* 611, 55-60 (2022), DOI
[10.1038/s41586-022-05239-2](https://doi.org/10.1038/s41586-022-05239-2).
The user-supplied DOI [10.1038/d41586-022-03455-4](https://doi.org/10.1038/d41586-022-03455-4)
is a *Nature* news item, "Electrons turn a piece of wire into a laser-like
light source," by Nicholas Rivera; it is not the primary research article.

### Models extracted

1. **Cylindrical SPP field.** The primary paper describes a cylindrical mode
   with axial field
   $$
   E_{z}^{(m)}=A f_{m}(\kappa r)
     e^{i(k_{z}z+m\phi-\omega t)},
   $$
   where the vacuum and plasma radial profiles use modified Bessel functions.
   A representative transverse decay parameter is
   $\kappa^2=k_z^2-\epsilon_d\omega^2/c^2$.
2. **Edge and azimuthal matching.** A sharp edge supplies the momentum needed
   for coupling. The axial resonance condition is
   $$k_l=k_{\mathrm{SPP}}.$$
   A circularly polarized laser has azimuthal index $l=\pm1$ and couples
   efficiently to the matching SPP index $m=\pm1$. The overlap amplitude is
   modeled as $A\approx\mathcal O E_0$; the paper reports an overlap of about
   $0.19$ for its simulation parameters.
3. **Electron-pump amplification.** The femtosecond optical pulse produces an
   in-phase free-electron pulse that coherently amplifies the THz surface wave.
   The article reports a twofold redshift over a 1 mm interaction length. The
   finite record represents this as
   $$
   \omega_{\mathrm{final}}=\omega_{\mathrm{initial}}/2,
   $$
   together with pump, loss, and output power fields.
4. **Prediction boundary.** Phase-matched electron bunching and superradiant
   growth are model conditions. The observed coherent SPP amplification does
   not by itself prove a lossless amplifier, a quantum laser, or an energy
   source independent of the electron pump.

### Lean boundary

`SPPFreeElectronAmplifier` stores nonnegative signal, electron-pump, output,
and loss powers; the twofold redshift; a positive interaction length; and a
bounded phase-alignment factor. It proves only the active power bound and
exposes the supplied redshift law. It does not formalize the Bessel boundary
value problem, electron distribution function, or a phase-matched
superradiance theorem. `CylindricalSPPMode` stores the axial and azimuthal
matching rules, overlap factor, and near-critical density ratio for the
related cylindrical model.

## 11. Coherent synchrotron radiation from cylindrical SPPs

**Citation.** Bifeng Lei, Hao Zhang, Daniel Seipt, Alexandre Bonatto, Bin Qiao,
Javier Resta-Lopez, Guoxing Xia, and Carsten Welsch, "Coherent synchrotron
radiation by excitation of surface plasmon polariton on near-critical solid
microtube surface," *Physical Review Letters* 135, 205001 (2025), DOI
[10.1103/cnym-16hc](https://doi.org/10.1103/cnym-16hc). The available source is
[arXiv:2507.04561v2](https://arxiv.org/abs/2507.04561).

### Models extracted

1. **Cylindrical mode and overlap.** The paper uses the mode in the previous
   section and gives an edge-coupling overlap of the form
   $$
   A\propto\int_{0}^{a}\int_{0}^{2\pi}
   E_{\mathrm{SPP},\perp}\cdot E_{\mathrm{laser},\perp}^{*}
   \,r\,dr\,d\phi.
   $$
   Matching the beam waist to the tube radius and matching azimuthal indices
   increase the coupling in the model.
2. **Rotating electron modulation.** For the simulated helical modulation,
   the paper uses $\omega_m=\omega_l$ and gives a kinematic relation for the
   modulation phase velocity, together with the Vavilov-Cherenkov angle
   $$
   \phi_{\mathrm{vc}}\simeq
   \arccos\left(1-\frac{\omega_r}{\omega_m}\right).
   $$
   The Lean `CherenkovAngleModel` stores the cosine relation without claiming
   that every stored value is a physically realizable angle.
3. **Coherent versus incoherent intensity.** With phase-symmetric electrons,
   the radiation field adds before squaring, so the idealized scaling is
   $$
   I_{\mathrm{coh}}\propto N^2 I_1,
   \qquad I_{\mathrm{incoh}}\propto N I_1.
   $$
   Finite radial spread reduces the form factor and therefore reduces perfect
   coherence. The paper's 3D PIC results report coherence enhancement of up to
   two orders of magnitude compared with an incoherent calculation.
4. **Simulation boundary.** The mechanism is a theory/PIC proposal with
   explicit challenges in microtube fabrication, laser contrast, polarization,
   alignment, target survivability, diagnostics, and repetition rate. The PIC
   result is not a demonstrated X-ray source or a measured coherence gain.

### Lean boundary

`CylindricalSPPMode` keeps axial and azimuthal matching and near-critical
density bookkeeping explicit. `CoherentRadiationScaling` proves the finite
inequality $I_{\mathrm{incoh}}\leq I_{\mathrm{coh}}$ from its supplied $N\geq1$
and nonnegative single-electron intensity assumptions. The record does not
implement particle trajectories, Bessel profiles, PIC dynamics, spectral
harmonics, or a plasma boundary condition.

## 12. Layer codes

**Citation.** Dominic J. Williamson and Nouedyn Baspin, "Layer codes," *Nature
Communications* 15, article 9528 (2024), DOI
[10.1038/s41467-024-53881-3](https://doi.org/10.1038/s41467-024-53881-3). The
preprint is [arXiv:2309.16503v2](https://arxiv.org/abs/2309.16503).

### Models extracted

1. **Input/output construction.** The paper maps an input CSS stabilizer code
   with parameters $[[n,k,d]]$ to a three-dimensional topological CSS code.
   Its Eq. (4) gives output scaling in terms of the numbers of $X$ and $Z$
   checks, $n_X$, $n_Z$, the minimum $n_* = \min(n_X,n_Z)$, and input maximum
   check weight $w$. The construction preserves the encoded-qubit count $k$.
2. **Layer geometry.** Physical-qubit, $X$-check, and $Z$-check layers are
   placed on the three coordinate-plane families and joined at one-dimensional
   junctions determined by the input Tanner graph. The output checks have
   weight at most six.
3. **Asymptotic theorem.** Theorem 1 states that suitable families of good CSS
   LDPC codes produce three-dimensional families with parameters
   $[[\Theta(L^3),\Theta(L),\Theta(L^2)]]$, checks of weight at most six, and a
   $\Theta(L)$ energy barrier. These are asymptotic mathematical properties
   under the specified family assumptions, not a performance claim for a
   finite NISQ device.

### Lean boundary

`CSSStabilizerCode` stores finite input qubit, logical-qubit, distance, check
weight, and commutation-residual data. `LayerCodeLift` stores output sizes,
logical-count preservation, three-dimensional and one-dimensional geometry,
the check-weight bound, and a polynomial energy-barrier metadata law. It does
not implement Pauli generators, chain complexes, homology, syndrome decoding,
logical operators, thresholds, or a proof of the asymptotic Eq. (4)/(5)
scalings. The `optimalScalingClaimed` flag is provenance data, not a theorem.

### Reference-only status

The Error Correction Zoo [Kitaev surface-code entry](https://errorcorrectionzoo.org/c/surface)
defines the surface code as a two-dimensional CSS stabilizer code on a
cellulation, with qubits on edges and star/plaquette Pauli generators. Its
[quantum surface-code list](https://errorcorrectionzoo.org/list/quantum_surface)
collects related families and includes Layer codes among the surface-code
relatives. The [Layer code entry](https://errorcorrectionzoo.org/c/layer)
describes geometrically local three-dimensional qubit QLDPC codes assembled
from surface-code layers coupled through the input check-qubit incidence
structure and lattice surgery. The supplied
`https://errorcorrectionzoo.org/list/quantum_layer` URL currently returns 404,
so it is not treated as a live list citation.

The local [QECReferences.lean](../src/signals/Signals/QECReferences.lean)
registry records these URLs, primary references, and the external
[QECLean](https://github.com/Stavan-Jain/QECLean) candidate with an explicit
`referenceOnly` or `localParameterMetadata` status. It does not import QECLean
or implement a quantum code. QECLean is currently the strongest Lean 4 project
to study for a future integration: its public documentation describes
Pauli/binary-symplectic algebra, stabilizer and CSS codes, toric and rotated
surface codes, chain-complex infrastructure, and axiom-clean distance proofs.
It pins Lean `v4.30.0-rc2`, whereas this workspace pins `v4.34.0-rc2`, so a
future dependency would require a deliberate port or toolchain alignment.

## 13. Protocol Z.8 distributed consensus claim

**Repository source.** [ENKI-420/consensus-quantum-protocol](https://github.com/ENKI-420/consensus-quantum-protocol),
main branch, inspected August 2026. The [raw README](https://raw.githubusercontent.com/ENKI-420/consensus-quantum-protocol/refs/heads/main/README.md)
describes a "fault-tolerant consensus architecture for NISQ hardware," displays
a 98.85% logical-fidelity badge for `ibm_torino`, and includes a dated five-run
heartbeat table. The [raw THEORY.md](https://raw.githubusercontent.com/ENKI-420/consensus-quantum-protocol/refs/heads/main/THEORY.md)
contains the repository's separate CRSM/"11D thermodynamics" interpretation;
that internal theory prose is not independent experimental evidence.

### Evidence audit

1. **Classical rule.** A ten-node council can be modeled by a strict majority
   function: a measured Hamming weight below five decodes to zero, a weight
   above five decodes to one, and a tie remains explicitly undecided. This is
   valid finite post-processing, but majority voting is not by itself a
   fault-tolerant quantum error-correcting code.
2. **Heartbeat evidence.** The README reports five sequential runs on
   2026-01-09 with logical fidelities 93.53%, 90.80%, 93.63%, 92.04%, and
   92.11%, each marked `PASSED`, and prints an average of 92.42%. The exact
   arithmetic mean of the displayed rounded inputs is 92.422%, which rounds to
   92.42%. This is meaningful additional self-reported evidence for the
   repository's repeated-run claim; it is not the same as independent
   verification because the README does not provide signed job results,
   complete raw shots, calibration data, transpiled circuits, decoder code,
   or a third-party reproduction for these five values.
3. **Displayed telemetry.** The README also lists job ID `d5gk867ea9qs739131u0`
   and partial counts including 1,983 all-zero shots, 1,674 all-one shots, and
   56 plus 47 labeled corrected shots. The ellipsis means the displayed rows
   are not a complete raw-count artifact. The README separately reports a
   10.72% correction rate and 98.85% logical fidelity, but the checked-in
   scripts do not provide a reproducible calculation linking those values to a
   complete shot file and decoder.
4. **Circuit scope.** `layer_code_protocol.py` is a seven-qubit anchor/via
   circuit, not the Layer-code construction above. `gain_validation_10k.py`
   prepares and submits a GHZ-like ten-qubit circuit but does not calculate a
   10,000-fold gain, and `final_signature.py` submits a one-shot twenty-qubit
   GHZ chain. These circuits and the repository's theory prose are not a
   formal stabilizer decoder or an independent benchmark.
5. **Evidence status.** The appropriate status is now more precisely described
   as self-reported repository evidence for reported hardware runs, not
   independently verified public-cloud hardware evidence. No IBM Runtime job
   was submitted by this review.

### Lean boundary

`majorityDecision` proves the finite threshold cases. `ConsensusObservation`
stores a shot-derived success ratio with explicit bounds, while
`MajorityDecodedObservation` connects that ratio to a declared council and
majority rule. `HeartbeatRun` and `HeartbeatExperiment` preserve the five
reported fidelities, pass flags, exact arithmetic mean, and rounded README
average. `ProtocolZ8ReportedBenchmark` preserves backend, job, total shots,
threshold, listed counts, physical/logical fidelity, correction rate, and
evidence flags. Its independent-verification predicate requires complete raw
counts and reproduction; the supplied fixture deliberately has neither, so
Lean proves only that it is not independently verified. It does not encode
98.85% or 92.42% as hardware theorems, and it does not call the IBM scripts.

## 14. Logical states for fault-tolerant quantum computation with propagating light

**Citation.** Shunya Konno, Warit Asavanant, Fumiya Hanamura, Hironari
Nagayoshi, Kosuke Fukui, Atsushi Sakaguchi, Ryuhoh Ide, Fumihiro China,
Masahiro Yabuno, Shigehito Miki, Hirotaka Terai, Kan Takase, Mamoru Endo,
Petr Marek, Radim Filip, Peter van Loock, and Akira Furusawa, "Logical states
for fault-tolerant quantum computation with propagating light," *Science* 383,
289-293 (2024), DOI
[10.1126/science.adk7560](https://doi.org/10.1126/science.adk7560).

The Hacker News item ["A physical qubit with built-in error correction"](https://news.ycombinator.com/item?id=39243929)
is a secondary pointer to a *Phys.org* news article. It is useful provenance
for the discussion, but it is not an additional peer-reviewed experiment or a
separate QEC implementation.

### Models extracted

1. **Optical GKP qubit.** The paper realizes a finite, propagating optical GKP
   state at telecommunication wavelength using interference of cat/kitten
   states, homodyne conditioning, and tomography. The target is a bosonic
   oscillator code that protects against small phase-space displacement errors,
   not a finite OAM register.
2. **Grid stabilizers.** With quadrature operators satisfying
   $[\hat{x},\hat{p}]=i$, the logical displacements are
   $$
   \bar{X}=e^{-i\pi\hat{p}},\qquad
   \bar{Z}=e^{i\pi\hat{x}},
   $$
   and the GKP lattice stabilizers are
   $$
   S_x=\bar{X}^{2}=e^{-i2\pi\hat{p}},\qquad
   S_p=\bar{Z}^{2}=e^{i2\pi\hat{x}}.
   $$
   Homodyne measurements and feed-forward displacements are the relevant
   syndrome/recovery primitives in the proposed optical architecture.
3. **Measured boundary.** The experiment generated one step of a finite,
   faint GKP state and reports effective squeezing around 2.5 dB. Its measured
   stabilizer expectations were approximately $S_x=0.170\pm0.003$ and
   $S_1=0.216\pm0.006$; the paper explicitly identifies optical loss, mode
   mismatch, cat-state amplitude, and the absence of iteration as limitations.
   It therefore demonstrates a logical-state precursor, not fault-tolerant
   computation or completed error correction.

### Relevance to 100 OAM states

The result helps architecturally: it identifies a practical pattern of
syndrome measurement and correction using a propagating optical field, and it
shows why a large optical Hilbert space can host structured logical states.
It does not provide the encoding map for an OAM qudit with $d=100$. An OAM
register has a finite cyclic mode label and must separately characterize
mode-dependent loss, radial-mode coupling, aperture truncation, phase noise,
and inter-mode crosstalk. The two GKP displacement stabilizers are therefore
analogous design axes, not already available OAM stabilizers.

### Lean boundary

`GKPQuditModel` stores the dimension-independent GKP spacing, stabilizer length,
and finite-energy envelope relations. It is a geometry/parameter model and
does not implement oscillator operators or a GKP state. Existing
`Signals.Homodyne` and `Signals.OAM.Qudit` provide the classical homodyne
adapter and finite normalized register needed for a future experimental
interface. The Science paper's optical result is not promoted to a 100-mode
OAM QEC theorem.

## 15. Quantum error correction of qudits beyond break-even

**Citation.** Benjamin L. Brock, Shraddha Singh, Alec Eickbusch, Volodymyr V.
Sivak, Andy Z. Ding, Luigi Frunzio, Steven M. Girvin, and Michel H. Devoret,
"Quantum error correction of qudits beyond break-even," *Nature* 641, 612-618
(2025), DOI
[10.1038/s41586-025-08899-y](https://doi.org/10.1038/s41586-025-08899-y).

### Models extracted

1. **Generalized Weyl operators.** For logical dimension $d$, the paper uses
   oscillator displacement operators $D(\alpha)$ and logical operators
   $X_d=D(\sqrt{\pi/d})$ and $Z_d=D(i\sqrt{\pi/d})$. Their action on grid
   codewords is the finite-dimensional shift/phase action
   $$
   Z_d|Z_n\rangle_d=\omega_d^n|Z_n\rangle_d,\qquad
   X_d|Z_n\rangle_d=|Z_{(n+1)\bmod d}\rangle_d,
   \qquad \omega_d=e^{2\pi i/d}.
   $$
   The commuting stabilizers have length
   $$
   \ell_d=\sqrt{\pi d},
   $$
   and the finite-energy code applies an envelope of the form
   $E_\Delta=e^{-\Delta^2a^\dagger a}$.
2. **Experimental dimensions.** The experiment realizes an error-corrected
   logical qutrit ($d=3$) and ququart ($d=4$) in a microwave cavity oscillator,
   using a transmon ancilla and an engineered small-big-small dissipative
   stabilization protocol. It is not an OAM experiment.
3. **QEC gain.** The paper defines a short-time effective decay rate from
   average channel fidelity and compares logical and physical qudits by
   $$
   G_d=\frac{\Gamma_d^{\mathrm{physical}}}
             {\Gamma_d^{\mathrm{logical}}},
   $$
   with break-even at $G_d=1$. It reports $G_3=1.82\pm0.03$ and
   $G_4=1.87\pm0.03$. The gain is a memory-lifetime comparison, not a gate
   fidelity, computational speedup, or claim of free error removal.

### Relevance to 100 OAM states

The paper supplies a useful validation target, not a direct solution. For an
OAM register, define a finite cyclic shift and phase family on the selected
100 modes, then measure whether a physically specified recovery map makes the
logical decay rate smaller than the best unencoded 100-mode comparison. The
generalized phase pairing can be written over `ZMod 100`, but `ZMod 100` is a
ring rather than a field. Any CSS-like or stabilizer construction must account
for this composite dimension; relabeling a binary CSS matrix as 100-level is
not sufficient. The factorization $100=4\cdot25$ is a possible subsystem
layout, but it is not automatically a tensor-product code or an error model.

The practical sequence is: choose the 100 OAM mode window; calibrate shift,
phase, leakage, radial-mode, and crosstalk channels; implement at least two
independent syndrome observables; define a recovery map; and compare logical
and physical decay under the same preparation/readout workload. Only then can
one claim a QEC gain or break-even crossing for OAM.

### Lean boundary

`cyclicShift` and `quditSymplecticPhase` provide finite composite-dimension
arithmetic without assuming a field. `QuditQECGainObservation` stores the
paper's decay-rate ratio and uncertainty margin, and `OAM100QuditQECDesign`
stores a normalized 100-mode register, centered OAM labels, the $4\times25$
factorization, two syndrome-axis metadata, and explicit loss/dephasing fields.
The qutrit and ququart fixtures prove the reported gains lie above break-even;
the 100-mode fixture deliberately leaves syndrome readout and recovery as
`false` readiness fields.

## 16. Semi-Dirac fermions and optical pumping

**Citations.** Bristi Ghosh, Malay Bandyopadhyay, and Ashutosh Singh, "Optical
pumping controls anisotropic response in semi-Dirac systems," *Physical Review
B* 111, 245414 (2025), DOI
[10.1103/dfbv-9vcj](https://doi.org/10.1103/dfbv-9vcj); and Bruno Uchoa,
Mohamed M. Elsayed, Valeri N. Kotov, Yinming Shao, and Dmitri N. Basov,
"Colloquium: Semi-Dirac Fermions in Quantum Matter," arXiv:2607.20627 (2026),
[arXiv:2607.20627](https://arxiv.org/abs/2607.20627).

### Models extracted

1. **Anisotropic dispersion.** The shared low-energy idealization has one
   linear momentum direction and one quadratic direction. In normalized
   coordinates, a useful energy-shell form is
   $$
   E^2 = (a k_x^2)^2 + (v k_y)^2,
   $$
   where $a>0$ is the quadratic-axis coefficient and $v>0$ is the linear-axis
   velocity. The equation is a conditional model after unit normalization;
   material-specific effective masses, velocities, doping, and gaps remain
   inputs.
2. **Continuous-wave optical pumping.** Ghosh et al. use a two-band density
   matrix and a quasi-steady-state CW illumination model. Pump amplitude,
   polarization, and frequency determine nonthermal band occupations, which in
   turn modify the probe optical-conductivity tensor, transmission, and
   polarization rotation. This is a response calculation, not a universal
   pump-power threshold.
3. **Review context.** Uchoa et al. place semi-Dirac fermions at a boundary
   between linear and quadratic dispersion regimes and review synthetic-lattice
   and quantum-material evidence. The review does not specify a route for
   converting lignin-vitrimer, rGO-vitrimer, or another hydrocarbon into
   graphene.

### Lean extraction

`SemiDiracDispersion` stores the normalized energy-shell equation and proves
the quadratic-axis and linear-axis reductions. `SemiDiracOpticalResponse`
stores pump power, independently calibrated axis responses, and linearized
pump-response gains; its monotonicity lemmas require positive pump power and
positive measured gain. These are algebraic response contracts, not claims
that an optical pump creates semi-Dirac fermions in a proposed material.

`SemiDiracOpticalPowerBudget` records fiber-laser input, CW resonator load,
rGO-vitrimer/metamaterial load, process load, and losses. It proves that
declared outputs plus losses cannot exceed the fiber-laser input. The
`SemiDiracGrapheneProcess` record adds a measured end-to-end efficiency and an
absorbed-power threshold, then proves the necessary bound
$$
P_{\rm laser} \geq
\frac{P_{\rm absorbed,required}}{\eta_{\rm end-to-end}}.
$$
The record also keeps material calibration, phase identification, and
graphene-formation verification as separate flags.

### What power is necessary?

There is no defensible universal answer in watts from these two sources. They
describe anisotropic response under CW pumping, but do not establish the
absorbed energy, temperature-time history, reaction kinetics, optical
coupling, damage threshold, or graphene yield for lignin-vitrimer, rGO-vitrimer,
plastic, or another hydrocarbon. A Proca resonator is additionally a Pending
conditional interface in this project; it cannot be assigned a motive or
conversion efficiency without independent mode, coupling, loss, and
polarization measurements.

For a real apparatus, determine the minimum power in this order:

1. Measure the absorbed-power threshold for the specified precursor and target
   graphene signature under controlled atmosphere, pressure, temperature, and
   exposure time.
2. Measure fiber-laser-to-sample end-to-end efficiency, including coupling,
   resonator enhancement, metamaterial absorption, reflection, scattering,
   and thermal losses.
3. Use the inequality above to compute the minimum incident laser power, then
   validate the result across area, scan speed, CW duty cycle, and sample
   thickness.
4. Independently verify graphene formation and properties with spectroscopy,
   microscopy, electrical transport, and mass/energy accounting. Semi-Dirac
   optical response is not evidence of graphene formation.

Thus the Lean fixture's $4\,\mathrm W$ absorbed threshold, $\eta=0.5$, and
$10\,\mathrm W$ fiber-laser budget are a deliberately transparent arithmetic
example: they imply an $8\,\mathrm W$ lower bound and leave $2\,\mathrm W$ of
declared losses in the fixture. They are not an operating recommendation or
an experimental result.

## 17. Laser power, pulse energy, fluence, and beam type

The two requested chat files use the word "power" for quantities that are not
interchangeable. A complete laser-process specification must distinguish:

| Quantity | Definition | Use |
| --- | --- | --- |
| Average optical power, $P_{\rm avg}$ | Energy delivered per unit time, in W | CW exposure, scan throughput, and pulse-train average |
| Pulse energy, $E_p$ | Energy in one pulse, in J | Shock drive and single-pulse ablation |
| Fluence, $F$ | Pulse energy per illuminated area, in J/cm$^2$ | Local ablation or shock coupling |
| Pulse duration, $\tau$ | Pulse width, in s | Peak power and thermal/nonthermal interaction regime |
| Peak power, $P_{\rm peak}$ | $E_p/\tau$, in W | Instantaneous field intensity and shock drive |
| Shock pressure, $p$ | Pressure in the target, in Pa or GPa | Phase transformation criterion, not a laser-head rating |

For a pulsed beam with spot area $A$,
$$
F=\frac{E_p}{A},\qquad
P_{\rm peak}=\frac{E_p}{\tau},\qquad
P_{\rm avg}=E_p f_{\rm rep}.
$$
For a CW scanned beam, the relevant material dose is instead a function of
average power, spot area, scan speed, dwell time, absorption, and thermal
transport. A lower power setting changes the dose; it does not necessarily
shrink the physical optical mode.

The maximum-watt value below is a declared source or equipment ceiling for the
finite model, not a universal material threshold. For CW tasks it is a maximum
average optical power; for pulsed tasks it is a maximum peak power; for the
unsupported holographic records it is a maximum source-power budget. Fluence
and internal intensity remain separate quantities and cannot be converted to
watts without a defined illuminated area and temporal profile.

### Requested task matrix

| Task | Appropriate beam type | Defensible power/energy statement | Maximum watts in the finite model | Evidence status and recommendation |
| --- | --- | --- | --- | --- |
| Laser ablation | Pulsed nanosecond, picosecond, or femtosecond beam selected for the target | Specify $E_p$, $\tau$, repetition rate, spot area, and $F$; no universal W value | 20 MW maximum peak power in the fixture; 10 MW is the operating example | Polymer-ablation literature treats wavelength, pulse duration, repetition rate, fluence, and substrate as coupled parameters. Calibrate the ablation threshold and heat-affected zone for the actual polymer. |
| LCS laser compression shock | Pulsed high-energy shock-drive beam, not CW engraving | A demonstrated graphite shock experiment used two 527 nm beams up to 16 J per beam with 10 ns pulses and 150--200 $\mu$m spots; the resulting target pressure was about 20--230 GPa | 2 GW maximum peak power in the fixture; 1.6 GW is the operating example | Kraus et al. demonstrated diamond formation from graphite under shock compression, but the 2025 SWCNT-film LSC paper reports about 2.27 GPa pressure rather than a transferable laser wattage. Do not apply a planar shock recipe to a finished polymer-sheathed cable without a new target and confinement study. |
| Graphene / LIG | CW or scanned CO$_2$ direct-write beam for the demonstrated lignin route; other precursors use other wavelengths | Kraft-lignin LIG was demonstrated with a 40 W, 10.6 $\mu$m CO$_2$ laser, 30--90% power settings, 100 $\mu$m beam size, 1000 PPI, and 20 cm/s scan speed; 80% was reported as the best setting in that apparatus | 40 W maximum average power in the fixture; 32 W is the operating example | This is a source-specific process window for a kraft-lignin/PEO film, not a universal lignin-vitrimer or rGO-vitrimer recipe. Validate Raman/XPS/HRTEM, sheet resistance, gas release, temperature, and yield. |
| Convergent holographic graphene | No demonstrated beam type for the proposed volumetric Proca process; classical analogs use focused femtosecond multiphoton writing or holographic/SLM beam shaping | The chat proposes 4--8 beams at 10--15 mW each, but supplies no measured focal-volume threshold, absorption, or conversion law | 0.12 W maximum source budget for the 8-beam proposal; 0.06 W is the 4-beam operating example | `120 mW` is chat-derived unsupported proposal metadata, not a graphene requirement. Classical femtosecond 3D writing demonstrates localized nonlinear modification in transparent materials, not graphene formation inside lignin-vitrimer. |
| Diamond | Pulsed high-energy shock compression of graphite, or established HPHT/CVD routes; not a CW diode or unverified Proca focus | The graphite experiment observed diamond beginning near 50 GPa and used up to 16 J per 527 nm beam with 10 ns pulses; it did not establish diamond formation from plastic or lignin | 2 GW maximum peak power inherited from the pulsed shock fixture; pressure is a separate field | Pressure, temperature, starting phase, confinement, and timescale must be measured. A higher optical intensity alone does not prove $sp^3$ diamond formation. |
| Convergent holographic graphene and diamond | No demonstrated beam type or process | The chat proposes about 10--25 kW system input and a 1.5--2.5 TW/cm$^2$ internal intensity, but these values have no independently validated coupling or material-transformation basis | 25 kW maximum source budget in the fixture; proposal metadata only | Treat as unsupported Proca/holographic proposal metadata. There is no scholarly demonstration of simultaneous volumetric graphene and diamond synthesis in plastic or lignin using convergent CW beams. |

### What the named chats establish, and what they do not

The AlgoLaser discussion describes consumer and desktop diode-head classes from
roughly 3 W to 40 W, including 20 W and 40 W blue-diode configurations. It also
notes that lower software power changes the reacted Gaussian footprint rather
than making the emitted optical mode physically smaller. Those are equipment
or process-planning statements in the chat, not independently verified
calibrations for this workspace ([AlgoLaser chat](chats/detail-the-algolaser-laser-engraver-products.myst.md#L105-L130), [power and focus discussion](chats/detail-the-algolaser-laser-engraver-products.myst.md#L435-L565)).

The IQ-Sampling chat proposes 10--15 mW per beam for a 4--8-beam internal
intersection, a 10--25 kW CW system range in another design passage, and
1.5--2.5 TW/cm$^2$ internal intensity ([sub-threshold beam proposal](chats/IQ-Sampling-for-Signal-Phase.myst.md#L8490-L8560), [holographic graphene/diamond proposal](chats/IQ-Sampling-for-Signal-Phase.myst.md#L8940-L9115)). These values should not be combined: they refer to different speculative architectures and lack measured focal volume, absorption, thermal, damage, and conversion data. A claimed convergent phase pattern is not evidence that a Proca field exists, is longitudinal, is non-diffracting in a material, or can rearrange carbon bonds.

### Scholarly comparison

The polymer-ablation review by Ravi-Kumar et al. identifies pulsed-laser type,
wavelength, power, repetition rate, fluence, and pulse duration as the relevant
variables for polymer ablation ([Ravi-Kumar et al.](https://doi.org/10.1002/pi.5834)). Mahmood et al. demonstrated direct-write photothermal LIG from a kraft-lignin/PEO film using a 40 W 10.6 $\mu$m CO$_2$ laser and reported an apparatus-specific optimum at 80% power ([Mahmood et al.](https://doi.org/10.1021/acsomega.0c01293)). Li et al.'s 2025 LSC paper reports a chemical-free conversion of SWCNT networks to graphene-rich films by repetitive laser-induced shockwaves at about 2.27 GPa, not a recipe for lignin or a finished cable ([Li et al.](https://doi.org/10.1002/adfm.202511015)). Kraus et al. used two 527 nm, 10 ns, up-to-16-J-per-beam drive lasers to shock graphite and observed diamond formation beginning near 50 GPa ([Kraus et al.](https://doi.org/10.1038/ncomms10970)).

The femtosecond 3D-fabrication review supports focused ultrashort-pulse
volumetric modification through nonlinear absorption and two-photon
polymerization ([Sugioka and Cheng](https://doi.org/10.1063/1.4904320)). It does not support the proposed inference from holographic interference to volumetric graphene or diamond. Holographic beam control can shape where energy is delivered; it does not supply the missing material reaction pathway or threshold.

### Scholarly CW holography

The scholarly record supports two narrower conclusions: explicit continuous-
wave holography exists in holographic metrology, and optical metasurfaces or
adaptive elements can shape and reconstruct optical fields. Neither result
supports the proposed material transformation:

- Binfield, Galloway, and Watson publish an article explicitly titled
   *Reciprocity failure in continuous-wave holography*. Its subject is
   holographic reciprocity, not a CW laser-processing recipe or carbon-phase
   synthesis ([Binfield et al. 1993](#binfield1993cwholography)).

- Huang et al. demonstrate a three-dimensional optical hologram with a
   plasmonic metasurface whose nanorod orientation encodes a phase profile for
   circularly polarized illumination. The result is an optical reconstruction;
   it is not a carbon-conversion experiment ([Huang et al. 2013](#huang2013holography)).
- Ren et al. demonstrate OAM-conserving, OAM-selective, and OAM-multiplexing
   metasurface holograms at 632 nm, reconstructing distinct optical images.
   This supports phase/OAM multiplexing as a classical optical analogue, not
   volumetric writing of graphene or diamond ([Ren et al. 2019](#ren2019oam)).
- Hu et al. demonstrate a stacked metasurface and Fabry--Perot colour-filter
   device for full-colour holography and microprint under RGB laser
   illumination. The device is an optical component, not a reactive volumetric
   precursor ([Hu et al. 2019](#hu2019holography)).
- Salter and Booth review adaptive optics for laser processing: aberration
   correction, focal-intensity shaping, and parallelization, with particular
   emphasis on ultrafast three-dimensional fabrication. They do not establish
   that a shaped CW field supplies a new reaction pathway or a material
   transformation threshold ([Salter and Booth 2019](#salter2019adaptive)).

Together, these papers justify modeling holography as a calibrated optical
wavefront or focal-distribution control layer. They do not justify treating a
CW hologram as a Proca field, as non-diffracting light in a polymer, or as
evidence for simultaneous graphene and diamond synthesis. The IQ chat's
10--15 mW-per-beam, 50 mW focal-node, 1--2.5 W output-range, and 10--25 kW
system figures therefore remain proposal metadata, with the task-specific
ceilings above kept separate from experimental laser-process evidence
([sub-threshold beam proposal](chats/IQ-Sampling-for-Signal-Phase.myst.md#L8490-L8560), [3D CW holographic proposal](chats/IQ-Sampling-for-Signal-Phase.myst.md#L8940-L9115)).

### Lean extraction

`LaserBeamKind`, `LaserTask`, and `LaserTaskStatus` classify the requested
processes and preserve whether the evidence is a demonstrated process, an
analog, calibration-required, or unsupported proposal.
`ContinuousWaveLaserTask` stores average power, scan speed, spot area,
efficiency, an absorbed threshold, and a maximum average-power ceiling.
`PulsedLaserTask` separately stores pulse energy, duration, repetition rate,
spot area, `LaserFluence`, peak power, and a maximum peak-power ceiling, with
proved energy/fluence/power identities. `PulsedLaserAveragePower` adds a
maximum pulse-train average-power ceiling. `LaserShockTask` adds the shock
pressure threshold. `HolographicLaserTaskBoundary` records the proposed
source power, maximum source-power budget, and beam count while requiring
independent phase, focal-volume, and structural verification before any
transformation claim.

The corresponding fixtures intentionally use the following status split:
direct-write Kraft-lignin graphene is a demonstrated process analog; laser
ablation and SWCNT-film LSC are demonstrated analogs; shock-synthesized
diamond is a demonstrated graphite process; and both convergent holographic
tasks remain `unsupportedProposal`.

## Lean mapping

The paper-derived API is in [Signals/Coherence.lean](../src/signals/Signals/Coherence.lean),
[Signals/PaperModels.lean](../src/signals/Signals/PaperModels.lean),
[Signals/ActiveOptics.lean](../src/signals/Signals/ActiveOptics.lean),
[Signals/LayerCodes.lean](../src/signals/Signals/LayerCodes.lean), and
[Signals/ProtocolZ8.lean](../src/signals/Signals/ProtocolZ8.lean):

| Definition | Paper content | Checked consequence |
| --- | --- | --- |
| `CoherenceSpectrum` | Normalized coherence-matrix eigenvalues | Finite $P_N^2$ and $K_N^2$ formulas |
| `CoherenceComplementarity` | Explicit normalized polarization and Schmidt-weight values | $P_N^2+K_N^2=1$ |
| `HuygensSteinerMapping` | Barycentric point-mass inertia relation | Unit-mass displacement and complementarity identities |
| `CoupledCavityModes` | Graphite/graphene or analogous two-mode cavity hybridization | Resonant splitting equals twice the coupling |
| `CarrierDensityResonance` | Gate-tunable collective-mode frequency fit | Explicit power-law fit contract |
| `SpectralWeightTransfer` | Upper/lower hybrid-branch spectral-weight exchange | Equal-and-opposite transfer |
| `GroverRotation` | Two-dimensional target-state amplitude amplification | Nonnegative fidelity and one-step ideal case |
| `DickeStateOverlap` | Globally rotated product-state/Dicke overlap | Explicit finite binomial overlap |
| `CavityQEDPhaseOracle` | Dispersive collective atom-cavity phase oracle | Shifted resonance and unit reflected phase |
| `GroverCavityFidelityScaling` | Cooperativity, bandwidth, mode matching, and heralding metadata | Explicit reported exponents |
| `ProcaDispersion` | Shared normalized Proca dispersion and real cutoff | Dispersion accessor and cutoff accessor |
| `ProcaMaterialResponse` | Transverse and spatially dispersive longitudinal dielectric laws | Longitudinal response vanishes on dispersion shell |
| `PlanarProcaCSResponse` | Planar Proca/Chern-Simons response components | Supplied response equalities |
| `MassiveCavityMode` | Massive Fabry-Perot resonance and force ratio | Frequency and ratio monotonicity |
| `ProcaDipolePattern` | Complementary transverse/longitudinal dipole patterns | Total pattern equals its angular scale |
| `QuantumSourceDirectivity` | Detection-rate ratio with positive denominator | Nonnegative and isotropic-unit cases |
| `NonlocalityDecay` | Scalar inverse-fourth-power separation estimate | Positive finite witness |
| `SecondHarmonicResonance` | Fundamental/second-harmonic and resonant-frequency relation | Explicit frequency laws |
| `ActiveOpticalAmplifier` | Signal gain with pump input and dissipative power balance | Output bounded by signal plus pump input |
| `LowPowerIntegratedOPA` | Thin-film lithium-niobate OPA metadata | Reported gain/input limit and positive bandwidth fields |
| `SPPFreeElectronAmplifier` | Free-electron-pumped SPP gain, redshift, and phase alignment | Active output bound and twofold-redshift accessor |
| `CylindricalSPPMode` | Cylindrical SPP axial/azimuthal matching and density ratio | Supplied phase-matching laws |
| `CoherentRadiationScaling` | Coherent $N^2$ versus incoherent $N$ intensity model | Coherent intensity dominates for $N\geq1$ |
| `CherenkovAngleModel` | Rotating-modulation Vavilov-Cherenkov cosine relation | Supplied angle-cosine accessor |
| `CSSStabilizerCode` | Finite CSS input-code parameters | Explicit commutation residual law |
| `LayerCodeLift` | Finite 3D layer-code construction metadata | Logical-count, geometry, check-weight, and barrier laws |
| `majorityDecision` | Finite council majority post-processing | Strict zero/one majority cases |
| `ConsensusObservation` | Shot-derived logical success ratio | Explicit fidelity bounds |
| `HeartbeatRun` | One reported Protocol Z.8 heartbeat run | Explicit run fidelity bounds and pass flag |
| `HeartbeatExperiment` | Five reported sequential runs and displayed average | Exact average of displayed inputs and rounded reported average |
| `ProtocolZ8ReportedBenchmark` | Repository backend, job, counts, and claimed rates | Incomplete report cannot satisfy independent-verification predicate |
| `cyclicShift` | Finite cyclic qudit label shift | Zero-offset identity, valid for composite dimension |
| `quditSymplecticPhase` | Generalized qudit phase pairing | Antisymmetry over `ZMod d` without a field assumption |
| `GKPQuditModel` | GKP logical spacing, stabilizer length, and finite-energy envelope | Explicit geometry and envelope laws |
| `QuditQECGainObservation` | Physical/logical decay-rate comparison and break-even gain | Gain-above-one consequence and reported uncertainty margin |
| `OAM100QuditQECDesign` | 100-mode OAM register and QEC-readiness metadata | Mode-label injectivity, $4\times25$ factorization, and two-axis metadata |
| `SemiDiracDispersion` | Normalized linear/quadratic energy shell | Axis-specific dispersion reductions |
| `SemiDiracOpticalResponse` | CW pump-dependent anisotropic response | Response monotonicity under positive calibrated gain |
| `SemiDiracOpticalPowerBudget` | Fiber-laser, resonator, metamaterial, process, and loss accounting | Declared outputs plus loss bounded by laser input |
| `SemiDiracGrapheneProcess` | Calibrated absorbed-power threshold and end-to-end efficiency | Necessary fiber-laser lower bound; no formation claim |

Coherence fixtures are compiled in [SignalsTests.lean](../src/signals/SignalsTests.lean).
The Proca-paper and cavity/Grover records and fixtures are compiled through the
explicit Pending target in [SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean).

### Scholarly References

<a id="qian2023"></a> Qian, X.-F., and Izadi, M. (2023). *Bridging coherence optics and classical mechanics: A generic light polarization-entanglement complementary relation*. Physical Review Research, 5, 033110. DOI: [10.1103/PhysRevResearch.5.033110](https://doi.org/10.1103/PhysRevResearch.5.033110). Supplied PDF: [PhysRevResearch.5.033110.pdf](../data/papers/PhysRevResearch.5.033110.pdf).

<a id="kipp2025cavity"></a> Kipp, G., Bretscher, H. M., Schulte, B., Herrmann, D., Kusyak, K., Day, M. W., Kesavan, S., Matsuyama, T., Li, X., Langner, S. M., Hagelstein, J., Sturm, F., Potts, A. M., Eckhardt, C. J., Huang, Y., Watanabe, K., Taniguchi, T., Rubio, A., Kennes, D. M., Sentef, M. A., Baudin, E., Meier, G., Michael, M. H., and McIver, J. W. (2025). *Cavity electrodynamics of van der Waals heterostructures*. Nature Physics, 21, 1926-1933. DOI: [10.1038/s41567-025-03064-8](https://doi.org/10.1038/s41567-025-03064-8). Preprint: [arXiv:2403.19745](https://arxiv.org/abs/2403.19745).

<a id="nagib2025grover"></a> Nagib, O., Saffman, M., and Mølmer, K. (2025). *Efficient preparation of entangled states in cavity QED with Grover's algorithm*. Physical Review Letters, 135, 050601. DOI: [10.1103/3fzf-wsr2](https://doi.org/10.1103/3fzf-wsr2). Preprint: [arXiv:2501.18881](https://arxiv.org/abs/2501.18881).

<a id="nagib2025carving"></a> Nagib, O., Saffman, M., and Mølmer, K. (2025). *Deterministic carving of quantum states with Grover's algorithm*. Physical Review A, 112, 012621. DOI: [10.1103/s3vs-xz7w](https://doi.org/10.1103/s3vs-xz7w). Preprint: [arXiv:2501.18884](https://arxiv.org/abs/2501.18884).

<a id="lim2021singularity"></a> Lim, S. W. D., Park, J.-S., Meretska, M. L., Dorrah, A. H., and Capasso, F. (2021). *Engineering phase and polarization singularity sheets*. Nature Communications, 12, 4190. DOI: [10.1038/s41467-021-24493-y](https://doi.org/10.1038/s41467-021-24493-y). Supplied PDF: [s41467-021-24493-y.pdf](../data/papers/s41467-021-24493-y.pdf).

<a id="salvatori2018halohedron"></a> Salvatori, G., and Cacciatori, S. (2018). *Hyperbolic Geometry and Amplituhedra in 1+2 dimensions*. arXiv:1803.05809 [hep-th]. DOI: [10.1007/JHEP08(2018)167](https://doi.org/10.1007/JHEP08(2018)167).

<a id="salvatori2019halohedron"></a> Salvatori, G. (2019). *1-loop Amplitudes from the Halohedron*. arXiv:1806.01842v2 [hep-th]. JHEP 12 (2019) 074. DOI: [10.1007/JHEP12(2019)074](https://doi.org/10.1007/JHEP12(2019)074).

<a id="chhatoi2019halohedron"></a> Chhatoi, S. (2019). *A Note on Convex Realization of Halohedron*. arXiv:1910.13786 [hep-th].

<a id="banerjee2019stokes"></a> Banerjee, P., Laddha, A., and Raman, P. (2019). *Stokes Polytopes: The positive geometry for $\phi^4$ interactions*. arXiv:1811.05904v3 [hep-th]. JHEP 08 (2019) 067. DOI: [10.1007/JHEP08(2019)067](https://doi.org/10.1007/JHEP08(2019)067).

<a id="kalyanapuram2020stokes"></a> Kalyanapuram, N. (2020). *Stokes Polytopes and Intersection Theory*. arXiv:1910.12195v2 [hep-th]. Physical Review D, 101, 105010. DOI: [10.1103/PhysRevD.101.105010](https://doi.org/10.1103/PhysRevD.101.105010).

<a id="salvatori2021simplepolytopes"></a> Salvatori, G., and Stanojevic, S. (2021). *Scattering amplitudes and simple canonical forms for simple polytopes*. arXiv:1912.06125v3 [hep-th]. JHEP 03 (2021) 067. DOI: [10.1007/JHEP03(2021)067](https://doi.org/10.1007/JHEP03(2021)067).

<a id="morais2026"></a> Morais, W., Strikos, S., Thibes, R., and Helayeel-Neto, J. A. (2026). *Investigating planar Proca metamaterials in nonlinear (2+1)-Electrodynamics*. arXiv:2607.23013v1 [physics.optics]. Supplied PDF: [2607.23013v1.pdf](../data/papers/2607.23013v1.pdf).

<a id="mikki2024cavity"></a> Mikki, S. (2024). *On the Interaction of Massive Photons and Mechanical Oscillators in Cavity Optomechanics: Basic Model and Quantization*. Annalen der Physik, 536, 2300288. DOI: [10.1002/andp.202300288](https://doi.org/10.1002/andp.202300288). Supplied PDF: [Annalen der Physik - 2023 - Mikki - On the Interaction of Massive Photons and Mechanical Oscillators in Cavity.pdf](../data/papers/Annalen%20der%20Physik%20-%202023%20-%20Mikki%20-%20On%20the%20Interaction%20of%20Massive%20Photons%20and%20Mechanical%20Oscillators%20in%20Cavity.pdf).

<a id="mikki2024directivity"></a> Mikki, S. (2024). *On the Directivity of Radiating Quantum Electromagnetic Systems*. Electromagnetic Science, 2(3), 0070222. DOI: [10.23919/emsci.2024.0022](https://doi.org/10.23919/emsci.2024.0022). Supplied PDF: [On_the_Directivity_of_Radiating_Quantum_Electromagnetic_Systems.pdf](../data/papers/On_the_Directivity_of_Radiating_Quantum_Electromagnetic_Systems.pdf).

<a id="mikki-proca-mtm"></a> Mikki, S. (n.d.). *Proca Metamaterials, Massive Electromagnetism, and Nonlocality*. Supplied PDF: [proca-metamaterials-massive-electromagnetism-and-nonlocality-3u1dghjsii.pdf](../data/papers/proca-metamaterials-massive-electromagnetism-and-nonlocality-3u1dghjsii.pdf). The supplied copy does not provide enough publication metadata to infer a venue or DOI.

<a id="dean2026opa"></a> Dean, D. J., Park, T., Stokowski, H. S., Qi, L., Robison, S., Hwang, A. Y., Herrmann, J. F., Fejer, M. M., and Safavi-Naeini, A. H. (2026). *Low-power integrated optical amplification through second-harmonic resonance*. Nature, 649, 1159-1164. DOI: [10.1038/s41586-025-09959-z](https://doi.org/10.1038/s41586-025-09959-z).

<a id="zhang2022spp"></a> Zhang, D., Zeng, Y., Bai, Y., Li, Z., Tian, Y., and Li, R. (2022). *Coherent surface plasmon polariton amplification via free-electron pumping*. Nature, 611, 55-60. DOI: [10.1038/s41586-022-05239-2](https://doi.org/10.1038/s41586-022-05239-2). Related news item: Nicholas Rivera, ["Electrons turn a piece of wire into a laser-like light source"](https://doi.org/10.1038/d41586-022-03455-4), Nature News (2022).

<a id="lei2025csr"></a> Lei, B., Zhang, H., Seipt, D., Bonatto, A., Qiao, B., Resta-Lopez, J., Xia, G., and Welsch, C. (2025). *Coherent synchrotron radiation by excitation of surface plasmon polariton on near-critical solid microtube surface*. Physical Review Letters, 135, 205001. DOI: [10.1103/cnym-16hc](https://doi.org/10.1103/cnym-16hc). Preprint: [arXiv:2507.04561v2](https://arxiv.org/abs/2507.04561).

<a id="williamson2024layer"></a> Williamson, D. J., and Baspin, N. (2024). *Layer codes*. Nature Communications, 15, article 9528. DOI: [10.1038/s41467-024-53881-3](https://doi.org/10.1038/s41467-024-53881-3). Preprint: [arXiv:2309.16503v2](https://arxiv.org/abs/2309.16503).

<a id="protocolz8"></a> ENKI-420. (2026). *consensus-quantum-protocol* [Computer software repository]. GitHub: [ENKI-420/consensus-quantum-protocol](https://github.com/ENKI-420/consensus-quantum-protocol). Source artifacts: [raw README](https://raw.githubusercontent.com/ENKI-420/consensus-quantum-protocol/refs/heads/main/README.md) and [raw THEORY.md](https://raw.githubusercontent.com/ENKI-420/consensus-quantum-protocol/refs/heads/main/THEORY.md). Repository claims are treated as self-reported evidence, not independent benchmark evidence.

<a id="konno2024gkp"></a> Konno, S., Asavanant, W., Hanamura, F., Nagayoshi, H., Fukui, K., Sakaguchi, A., Ide, R., China, F., Yabuno, M., Miki, S., Terai, H., Takase, K., Endo, M., Marek, P., Filip, R., van Loock, P., and Furusawa, A. (2024). *Logical states for fault-tolerant quantum computation with propagating light*. Science, 383, 289-293. DOI: [10.1126/science.adk7560](https://doi.org/10.1126/science.adk7560). Related secondary pointer: [Hacker News item 39243929](https://news.ycombinator.com/item?id=39243929).

<a id="brock2025qudit"></a> Brock, B. L., Singh, S., Eickbusch, A., Sivak, V. V., Ding, A. Z., Frunzio, L., Girvin, S. M., and Devoret, M. H. (2025). *Quantum error correction of qudits beyond break-even*. Nature, 641, 612-618. DOI: [10.1038/s41586-025-08899-y](https://doi.org/10.1038/s41586-025-08899-y). Open-access article: [Nature PDF](https://www.nature.com/articles/s41586-025-08899-y.pdf).

<a id="ghosh2025semidirac"></a> Ghosh, B., Bandyopadhyay, M., and Singh, A. (2025). *Optical pumping controls anisotropic response in semi-Dirac systems*. Physical Review B, 111, 245414. DOI: [10.1103/dfbv-9vcj](https://doi.org/10.1103/dfbv-9vcj). The article studies a two-band CW density-matrix response; it does not provide a graphene-formation power specification for the proposed materials.

<a id="uchoa2026semidirac"></a> Uchoa, B., Elsayed, M. M., Kotov, V. N., Shao, Y., and Basov, D. N. (2026). *Colloquium: Semi-Dirac Fermions in Quantum Matter*. arXiv:2607.20627. [arXiv record](https://arxiv.org/abs/2607.20627). This is a review of semi-Dirac quasiparticles and experimental context, not a process recipe.

<a id="ravikumar2019ablation"></a> Ravi-Kumar, S., Lies, B., Zhang, X., Lyu, H., and Qin, H. (2019). *Laser ablation of polymers: A review*. Polymer International. DOI: [10.1002/pi.5834](https://doi.org/10.1002/pi.5834). The review identifies laser type, wavelength, power, repetition rate, fluence, and pulse duration as coupled process variables.

<a id="mahmood2020ligninlig"></a> Mahmood, F., Zhang, H., Lin, J., and Wan, C. (2020). *Laser-Induced Graphene Derived from Kraft Lignin for Flexible Supercapacitors*. ACS Omega, 5, 14611-14618. DOI: [10.1021/acsomega.0c01293](https://doi.org/10.1021/acsomega.0c01293). Open article: [PMC7315590](https://pmc.ncbi.nlm.nih.gov/articles/PMC7315590/).

<a id="li2025lsc"></a> Li, J., Seo, J., Feng, P., Seo, D., Kim, J., Oosthuizen, D. N., Cho, J., Cho, B., Busnaina, A., Jung, H. Y., Kim, D., and Jung, Y. J. (2025). *One-Step Transformation of Single-Walled Carbon Nanotube Networks into High-Performance Multilayer Graphene-Rich Films via Laser Shockwave Compaction*. Advanced Functional Materials. DOI: [10.1002/adfm.202511015](https://doi.org/10.1002/adfm.202511015).

<a id="kraus2016diamondshock"></a> Kraus, D., Ravasio, A., Gauthier, M., Gericke, D. O., Vorberger, J., Frydrych, S., Helfrich, J., Fletcher, L. B., Schaumann, G., Nagler, B., et al. (2016). *Nanosecond formation of diamond and lonsdaleite by shock compression of graphite*. Nature Communications, 7, 10970. DOI: [10.1038/ncomms10970](https://doi.org/10.1038/ncomms10970). Open article: [PMC4793081](https://pmc.ncbi.nlm.nih.gov/articles/PMC4793081/).

<a id="sugioka2014femtosecond3d"></a> Sugioka, K., and Cheng, Y. (2014). *Femtosecond laser three-dimensional micro- and nanofabrication*. Applied Physics Reviews, 1, 041303. DOI: [10.1063/1.4904320](https://doi.org/10.1063/1.4904320).

<a id="binfield1993cwholography"></a> Binfield, P., Galloway, R., and Watson, J. (1993). *Reciprocity failure in continuous-wave holography*. Applied Optics, 32(23), 4337. DOI: [10.1364/AO.32.004337](https://doi.org/10.1364/AO.32.004337).

<a id="huang2013holography"></a> Huang, L., Chen, X., Mühlenbernd, H., Zhang, H., Chen, S., Bai, B., Tan, Q., Jin, G., Cheah, K.-W., Qiu, C.-W., Li, J., Zentgraf, T., and Zhang, S. (2013). *Three-dimensional optical holography using a plasmonic metasurface*. Nature Communications, 4, 2808. DOI: [10.1038/ncomms3808](https://doi.org/10.1038/ncomms3808). Open article: [Nature PDF](https://www.nature.com/articles/ncomms3808.pdf).

<a id="ren2019oam"></a> Ren, H., Briere, G., Fang, X., Ni, P., Sawant, R., Héron, S., Chenot, S., Vezian, S., Damilano, B., Brändli, V., Maier, S. A., and Genevet, P. (2019). *Metasurface orbital angular momentum holography*. Nature Communications, 10, 2986. DOI: [10.1038/s41467-019-11030-1](https://doi.org/10.1038/s41467-019-11030-1). Open article: [Nature PDF](https://www.nature.com/articles/s41467-019-11030-1.pdf).

<a id="hu2019holography"></a> Hu, Y., Luo, X., Chen, Y., Liu, Q., Li, X., Wang, Y., Liu, N., and Duan, H. (2019). *3D-Integrated metasurfaces for full-colour holography*. Light: Science & Applications, 8, 86. DOI: [10.1038/s41377-019-0198-y](https://doi.org/10.1038/s41377-019-0198-y). Open article: [Nature PDF](https://www.nature.com/articles/s41377-019-0198-y.pdf).

<a id="salter2019adaptive"></a> Salter, P. S., and Booth, M. J. (2019). *Adaptive optics in laser processing*. Light: Science & Applications, 8, 110. DOI: [10.1038/s41377-019-0215-1](https://doi.org/10.1038/s41377-019-0215-1). Open article: [Nature PDF](https://www.nature.com/articles/s41377-019-0215-1.pdf).

### BibTeX

```bibtex
@article{qian2023coherence,
   author       = {Qian, Xiao-Feng and Izadi, Misagh},
   title        = {Bridging coherence optics and classical mechanics: A generic light polarization-entanglement complementary relation},
   journal      = {Physical Review Research},
   volume       = {5},
   pages        = {033110},
   year         = {2023},
   doi          = {10.1103/PhysRevResearch.5.033110},
   note         = {Supplied PDF: data/papers/PhysRevResearch.5.033110.pdf}
}

@article{kipp2025cavity,
   author       = {Kipp, Gunda and Bretscher, Hope M. and Schulte, Benedikt and Herrmann, Dorothee and Kusyak, Kateryna and Day, Matthew W. and Kesavan, Sivasruthi and Matsuyama, Toru and Li, Xinyu and Langner, Sara Maria and Hagelstein, Jesse and Sturm, Felix and Potts, Alexander M. and Eckhardt, Christian J. and Huang, Yunfei and Watanabe, Kenji and Taniguchi, Takashi and Rubio, Angel and Kennes, Dante M. and Sentef, Michael A. and Baudin, Emmanuel and Meier, Guido and Michael, Marios H. and McIver, James W.},
   title        = {Cavity electrodynamics of van der Waals heterostructures},
   journal      = {Nature Physics},
   volume       = {21},
   pages        = {1926--1933},
   year         = {2025},
   doi          = {10.1038/s41567-025-03064-8},
   eprint       = {2403.19745},
   archivePrefix = {arXiv}
}

@article{nagib2025grover,
   author       = {Nagib, Omar and Saffman, M. and Mølmer, K.},
   title        = {Efficient preparation of entangled states in cavity QED with Grover's algorithm},
   journal      = {Physical Review Letters},
   volume       = {135},
   pages        = {050601},
   year         = {2025},
   doi          = {10.1103/3fzf-wsr2},
   eprint       = {2501.18881},
   archivePrefix = {arXiv}
}

@article{nagib2025carving,
   author       = {Nagib, Omar and Saffman, M. and Mølmer, K.},
   title        = {Deterministic carving of quantum states with Grover's algorithm},
   journal      = {Physical Review A},
   volume       = {112},
   pages        = {012621},
   year         = {2025},
   doi          = {10.1103/s3vs-xz7w},
   eprint       = {2501.18884},
   archivePrefix = {arXiv}
}

@article{lim2021singularity,
   author       = {Lim, Soon Wei Daniel and Park, Joon-Suh and Meretska, Maryna L. and Dorrah, Ahmed H. and Capasso, Federico},
   title        = {Engineering phase and polarization singularity sheets},
   journal      = {Nature Communications},
   volume       = {12},
   pages        = {4190},
   year         = {2021},
   doi          = {10.1038/s41467-021-24493-y},
   note         = {Supplied PDF: data/papers/s41467-021-24493-y.pdf}
}

@article{salvatori2019halohedron,
   author       = {Salvatori, Giulio},
   title        = {1-loop Amplitudes from the Halohedron},
   journal      = {Journal of High Energy Physics},
   year         = {2019},
   doi          = {10.1007/JHEP12(2019)074},
   eprint       = {1806.01842},
   archivePrefix = {arXiv}
}

@article{banerjee2019stokes,
   author       = {Banerjee, Pinaki and Laddha, Alok and Raman, Prashanth},
   title        = {Stokes Polytopes: The positive geometry for phi4 interactions},
   journal      = {Journal of High Energy Physics},
   year         = {2019},
   doi          = {10.1007/JHEP08(2019)067},
   eprint       = {1811.05904},
   archivePrefix = {arXiv}
}

@article{kalyanapuram2020stokes,
   author       = {Kalyanapuram, Nikhil},
   title        = {Stokes Polytopes and Intersection Theory},
   journal      = {Physical Review D},
   volume       = {101},
   pages        = {105010},
   year         = {2020},
   doi          = {10.1103/PhysRevD.101.105010},
   eprint       = {1910.12195},
   archivePrefix = {arXiv}
}

@article{salvatori2021simplepolytopes,
   author       = {Salvatori, Giulio and Stanojevic, Stefan},
   title        = {Scattering amplitudes and simple canonical forms for simple polytopes},
   journal      = {Journal of High Energy Physics},
   year         = {2021},
   doi          = {10.1007/JHEP03(2021)067},
   eprint       = {1912.06125},
   archivePrefix = {arXiv}
}

@misc{morais2026planar,
  author       = {Morais, Widervan and Strikos, Stamatios and Thibes, Ronaldo and Helayeel-Neto, Jose Abdalla},
  title        = {Investigating planar Proca metamaterials in nonlinear (2+1)-Electrodynamics},
  year         = {2026},
  eprint       = {2607.23013v1},
  archivePrefix = {arXiv},
  primaryClass = {physics.optics},
  note         = {Supplied PDF: data/papers/2607.23013v1.pdf}
}

@article{mikki2024cavity,
  author       = {Mikki, Said},
  title        = {On the Interaction of Massive Photons and Mechanical Oscillators in Cavity Optomechanics: Basic Model and Quantization},
  journal      = {Annalen der Physik},
  volume       = {536},
  pages        = {2300288},
  year         = {2024},
  doi          = {10.1002/andp.202300288},
  note         = {Supplied PDF: data/papers/Annalen der Physik - 2023 - Mikki - On the Interaction of Massive Photons and Mechanical Oscillators in Cavity.pdf}
}

@article{mikki2024directivity,
  author       = {Mikki, Said},
  title        = {On the Directivity of Radiating Quantum Electromagnetic Systems},
  journal      = {Electromagnetic Science},
  volume       = {2},
  number       = {3},
  pages        = {0070222},
  year         = {2024},
  doi          = {10.23919/emsci.2024.0022},
  note         = {Supplied PDF: data/papers/On_the_Directivity_of_Radiating_Quantum_Electromagnetic_Systems.pdf}
}

@misc{mikkiProcaMetamaterials,
  author       = {Mikki, Said},
  title        = {Proca Metamaterials, Massive Electromagnetism, and Nonlocality},
  note         = {Supplied PDF: data/papers/proca-metamaterials-massive-electromagnetism-and-nonlocality-3u1dghjsii.pdf; publication metadata not supplied}
}

@article{dean2026opa,
   author       = {Dean, Devin J. and Park, Taewon and Stokowski, Hubert S. and Qi, Luke and Robison, Sam and Hwang, Alexander Y. and Herrmann, Jason F. and Fejer, Martin M. and Safavi-Naeini, Amir H.},
   title        = {Low-power integrated optical amplification through second-harmonic resonance},
   journal      = {Nature},
   volume       = {649},
   pages        = {1159--1164},
   year         = {2026},
   doi          = {10.1038/s41586-025-09959-z}
}

@article{zhang2022spp,
   author       = {Zhang, Dongdong and Zeng, Yushan and Bai, Yafeng and Li, Zhongpeng and Tian, Ye and Li, Ruxin},
   title        = {Coherent surface plasmon polariton amplification via free-electron pumping},
   journal      = {Nature},
   volume       = {611},
   pages        = {55--60},
   year         = {2022},
   doi          = {10.1038/s41586-022-05239-2}
}

@article{lei2025csr,
   author       = {Lei, Bifeng and Zhang, Hao and Seipt, Daniel and Bonatto, Alexandre and Qiao, Bin and Resta-Lopez, Javier and Xia, Guoxing and Welsch, Carsten},
   title        = {Coherent synchrotron radiation by excitation of surface plasmon polariton on near-critical solid microtube surface},
   journal      = {Physical Review Letters},
   volume       = {135},
   pages        = {205001},
   year         = {2025},
   doi          = {10.1103/cnym-16hc},
   eprint       = {2507.04561},
   archivePrefix = {arXiv}
}

@article{williamson2024layer,
   author       = {Williamson, Dominic J. and Baspin, Nouedyn},
   title        = {Layer codes},
   journal      = {Nature Communications},
   volume       = {15},
   pages        = {9528},
   year         = {2024},
   doi          = {10.1038/s41467-024-53881-3},
   eprint       = {2309.16503},
   archivePrefix = {arXiv}
}

@misc{protocolz8,
   author       = {{ENKI-420}},
   title        = {consensus-quantum-protocol},
   year         = {2026},
   howpublished = {GitHub repository},
   url          = {https://github.com/ENKI-420/consensus-quantum-protocol},
   note         = {Repository claim reviewed as reported, not independently verified, January 2026}
}

@article{konno2024gkp,
   author       = {Konno, Shunya and Asavanant, Warit and Hanamura, Fumiya and Nagayoshi, Hironari and Fukui, Kosuke and Sakaguchi, Atsushi and Ide, Ryuhoh and China, Fumihiro and Yabuno, Masahiro and Miki, Shigehito and Terai, Hirotaka and Takase, Kan and Endo, Mamoru and Marek, Petr and Filip, Radim and van Loock, Peter and Furusawa, Akira},
   title        = {Logical states for fault-tolerant quantum computation with propagating light},
   journal      = {Science},
   volume       = {383},
   pages        = {289--293},
   year         = {2024},
   doi          = {10.1126/science.adk7560}
}

@article{brock2025qudit,
   author       = {Brock, Benjamin L. and Singh, Shraddha and Eickbusch, Alec and Sivak, Volodymyr V. and Ding, Andy Z. and Frunzio, Luigi and Girvin, Steven M. and Devoret, Michel H.},
   title        = {Quantum error correction of qudits beyond break-even},
   journal      = {Nature},
   volume       = {641},
   pages        = {612--618},
   year         = {2025},
   doi          = {10.1038/s41586-025-08899-y},
   eprint       = {2409.15065},
   archivePrefix = {arXiv}
}

@article{binfield1993cwholography,
   author       = {Binfield, P. and Galloway, R. and Watson, J.},
   title        = {Reciprocity failure in continuous-wave holography},
   journal      = {Applied Optics},
   volume       = {32},
   number       = {23},
   pages        = {4337},
   year         = {1993},
   doi          = {10.1364/AO.32.004337}
}

@article{huang2013holography,
   author       = {Huang, Lingling and Chen, Xianzhong and Mühlenbernd, Holger and Zhang, Hao and Chen, Shumei and Bai, Benfeng and Tan, Qiaofeng and Jin, Guofan and Cheah, Kok-Wai and Qiu, Cheng-Wei and Li, Jensen and Zentgraf, Thomas and Zhang, Shuang},
   title        = {Three-dimensional optical holography using a plasmonic metasurface},
   journal      = {Nature Communications},
   volume       = {4},
   pages        = {2808},
   year         = {2013},
   doi          = {10.1038/ncomms3808}
}

@article{ren2019oam,
   author       = {Ren, Haoran and Briere, Gauthier and Fang, Xinyuan and Ni, Peinan and Sawant, Rajath and Héron, Sébastien and Chenot, Sébastien and Vezian, Stéphane and Damilano, Benjamin and Brändli, Virginie and Maier, Stefan A. and Genevet, Patrice},
   title        = {Metasurface orbital angular momentum holography},
   journal      = {Nature Communications},
   volume       = {10},
   pages        = {2986},
   year         = {2019},
   doi          = {10.1038/s41467-019-11030-1}
}

@article{hu2019holography,
   author       = {Hu, Yueqiang and Luo, Xuhao and Chen, Yiqin and Liu, Qing and Li, Xin and Wang, Yasi and Liu, Na and Duan, Huigao},
   title        = {3D-Integrated metasurfaces for full-colour holography},
   journal      = {Light: Science & Applications},
   volume       = {8},
   pages        = {86},
   year         = {2019},
   doi          = {10.1038/s41377-019-0198-y}
}

@article{salter2019adaptive,
   author       = {Salter, Patrick S. and Booth, Martin J.},
   title        = {Adaptive optics in laser processing},
   journal      = {Light: Science & Applications},
   volume       = {8},
   pages        = {110},
   year         = {2019},
   doi          = {10.1038/s41377-019-0215-1}
}
```
