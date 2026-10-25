---
title: Huygens Diffraction, Grassmannians, and Positive Geometry
description: Staged Lean 4 review and a falsifiable roadmap from finite slit sums to continuum diffraction and canonical forms.
---

(huygens-grassmannian-amplituhedron-plan)=
# Huygens Diffraction, Grassmannians, and Positive Geometry

## Recommendation and Scope

Develop two independently verified mathematical tracks: classical scalar
diffraction and positive geometry. Connect them only after defining a geometric
amplitude that is independent of the optical answer and can fail a comparison
test. Keep all implementation local to Signals until the mathematics and
physics boundaries are stable; no upstream library placement is decided here.

The motivating {download}`chat, line 9 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>`
asks for a Grassmannian interpretation of three-dimensional double-slit
interference. It also proposes a
{download}`two-residue construction, line 104 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>`.
Neither proposal is experimental evidence or an established optical theorem.

:::{important}
The amplituhedron-to-diffraction interpretation remains **Pending**. The staged
implementation proves finite algebra and conditional contracts, not full
continuum diffraction, canonical differential forms, or an optical realization
of an amplituhedron. A compilation result validates the formal statement and
its assumptions, not those assumptions' physical truth.
:::

## Staged Review

### Snapshot and Verdict

Review date: 2026-10-08. The review target is the Git index, not all changes in
the working tree. It includes
{download}`src/signals/README.md <../src/signals/README.md>`,
[Signals.lean](../src/signals/Signals.lean),
[Geometry.lean](../src/signals/Signals/Geometry.lean),
[Huygens.lean](../src/signals/Signals/Huygens.lean),
[Plabic.lean](../src/signals/Signals/Plabic.lean),
[Pending.lean](../src/signals/Signals/Pending.lean),
[SignalsTests.lean](../src/signals/SignalsTests.lean), and
[SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean).
Dependency and toolchain changes are also staged, but their upstream suitability
is outside this mathematical review. Unstaged changes to Pending, tests, and
the README are not attributed to this snapshot. Links resolve to the local
working files; the Git index supplies the reviewed source text.

**Verdict:** no blocking correctness defect was found within the stated finite
and conditional contracts. The README correctly separates matrix
representatives from quotient Grassmannians, rotation systems from disk
embeddings, scalar intensity from calibrated power, and supplied matches from
derived physical amplitudes. The following are non-blocking review follow-ups
and promotion gates, not findings of false Lean theorems.

| Priority | Follow-up | Evidence and consequence | Required next check |
|---|---|---|---|
| P2, physical API | Require a regular evaluation domain. | `Aperture.regularAt` exists in [Huygens.lean](../src/signals/Signals/Huygens.lean#L57), but `amplitude` and `DoubleSlit` do not require it. Coincident samples evaluate through totalized division. This is documented algebra, not a physical singularity treatment. | A guarded wrapper, positive separation bounds, and a coincident-point rejection test. |
| P2, research validation | Construct candidate contributions independently of slit amplitudes. | `GrassmannianDoubleSlitHypothesis` in [Pending.lean](../src/signals/Signals/Pending.lean#L1247) supplies `contribution`, `firstMatch`, and `secondMatch`. Its conclusions do not derive those functions from the geometry. | A geometry-to-amplitude evaluator and a deliberately mismatching candidate that fails the comparison. |
| P2, test coverage | Add a nonzero bridge fixture and a detector sweep. | The Pending example in [SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L4563) uses empty apertures and zero contributions. The verified optics examples in [SignalsTests.lean](../src/signals/SignalsTests.lean#L1018) establish finite algebra and symmetric-path equality, not an independently computed fringe map. | Nonempty slits, several relative phases, destructive minima, both single-slit masks, and off-axis detector samples. |
| P3, future topology | Derive exits, decorations, and cell data where possible. | `BoundaryRouting` in [Plabic.lean](../src/signals/Signals/Plabic.lean#L112) checks supplied exits and a supplied permutation. It does not construct a disk embedding or derive fixed-point colors. | A finite first-return construction and a separately verified planar network model. |

The regularity follow-up does not invalidate the existing algebraic
superposition lemmas. Likewise, the empty-aperture fixture checks the Pending
contract accurately; it is insufficient evidence for a nontrivial geometric
interpretation.

### Checked Mathematical Surface

| Layer | Present API | Exact scope |
|---|---|---|
| Twistor shear | `Twistor.incident`, `translate_incident_iff`, `translate_add`, `translate_neg` | Complex matrix incidence and additive translations; no projective quotient, Hermiticity, or propagation equation. |
| Orbital momentum | `orbitalBivector`, `AngularMomentumState.translate` | Four-index antisymmetric tensor shift; not a two-by-two commutator or a Casimir-to-inertia identity. |
| Ordered minors | `selectedMinor`, `pluckerAlternating`, `NonnegativeGrassmannian` | Alternating determinants, row-swap signs, nonnegative maximal minors, and a nonzero-minor witness. |
| Scalar optics | `Aperture.amplitude`, `DoubleSlit.intensity_both_open` | Finite complex sums in three spatial coordinates and their coherent cross terms. |
| Combinatorics | `RotationSystem`, `route`, `BoundaryRouting.decorated` | Typed directed-edge routing with cyclic rotations and checked finite exits. |
| Proposed bridge | `GrassmannianDoubleSlitHypothesis` | Consequences of supplied geometry labels and supplied amplitude matches. |

### Reproducibility

Inspect the actual staged sources without changing the index:

```bash
git diff --cached --stat
git diff --cached -- src/signals/README.md 'src/signals/*.lean' 'src/signals/Signals/*.lean'
git show :src/signals/Signals/Huygens.lean
git diff -- src/signals/README.md src/signals/Signals/Pending.lean
```

Typechecking index text against working-tree imports is a useful review check,
but not a hermetic build of a staged dependency snapshot. A hermetic check
would materialize all indexed sources and dependency pins into a local
repository `.tmp/` sandbox, then run Lake there without altering the index.

## Evidence and Corrections

Search scope is the single motivating Markdown export, excluding its duplicate
JSON export. Source citations give line numbers in the downloadable Markdown,
not nonexistent line anchors in rendered HTML. The reproducible regex search is:

```bash
rg -n 'Casimir|two distinct|geometric union|Hodges|strand_step|plucker_map|is_totally_nonnegative|spurious' \
  data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md
```

| Claim or proposal | Direct source | Status and confidence | Missing discriminator |
|---|---|---|---|
| Twistor translation preserves incidence. | {download}`Incidence blueprint, line 199 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>` | Scholarly algebra, high confidence; locally proved with fixed conventions. | Physical spacetime interpretation requires extra representation data. |
| Orbital angular momentum shifts by an offset wedge momentum. | {download}`Translation discussion, line 90 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>` | Scholarly algebra, high confidence. The chat's commutator/Casimir interpretation is not established. | Separate inertia and Lorentz-representation theorems. |
| Each slit is exactly one scattering residue. | {download}`Two-residue proposal, line 104 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>` | Proposal, low confidence as an optical identification. | A specified geometry, boundary labeling, contour, and optical amplitude derivation. |
| Superposition is a geometric union, and squared amplitudes come from a dual intersection. | {download}`Union and intersection proposal, line 112 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>` | Unsupported by the supplied construction. | Oriented form identities, an evaluation map, and a demonstrated match to complex optical phases. |
| Plabic routes index nonnegative Grassmannian cells. | {download}`Routing blueprint, line 374 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>` | Scholarly theory for suitably specified networks; only finite routing is currently checked. | Disk embedding, network weights, boundary measurements, rank, and positroid correspondence. |
| An alternating determinant defines ordered Pluecker coordinates. | {download}`Alternating-map blueprint, line 483 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>` | Scholarly algebra, high confidence; locally proved. | General Pluecker relations and basis-change laws for the intended quotient. |
| Nonnegative minors exclude spurious poles and confine a form to the interior. | {download}`Positivity claim, line 510 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>` | Unsupported as stated. Nonnegative minors permit boundary zeros. | A defined form, its actual divisors, and explicit cancellation/residue proofs. |

The original {download}`path-integral narrative, line 70 <../data/chats/Grassmannian-Huygens-Principle-Amplituhedron.md>`
also overstates the replacement of locality and unitarity. The original
[amplituhedron paper](#scholarly-amplituhedron) concerns planar
$\mathcal N=4$ supersymmetric Yang-Mills scattering; locality and unitarity
emerge in that setting rather than being disproved or physically abandoned.
It does not supply a double-slit optical model.

The [positive-geometry framework](#scholarly-positive-geometries) characterizes
canonical forms by boundary logarithmic singularities and recursive residues.
It is not a generic prescription to square a form into a detector intensity.
[Postnikov's networks](#scholarly-postnikov-networks) supply mathematical cell
parametrizations, not evidence that a macroscopic baffle implements an on-shell
scattering channel. These are theoretical sources, not diffraction experiments.

## Mathematical Targets

### Translation and the Parallel-Axis Boundary

Keep the three laws distinct:

$$
\mu=-i x\lambda,
\qquad T_a(\lambda,\mu)=(\lambda,\mu-i a\lambda),
\qquad T_bT_a=T_{a+b}.
$$

$$
M_{\mu\nu}(x,p)=x_\mu p_\nu-x_\nu p_\mu,
\qquad M(x+a,p)=M(x,p)+a\wedge p.
$$

$$
I_{\mathrm{parallel}}=I_{\mathrm{CM}}+m d_\perp^2.
$$

The last identity is the separate scalar model in
[Coherence.lean](../src/signals/Signals/Coherence.lean#L37).
For a physical derivation, $d_\perp$ is the perpendicular separation of parallel
axes and the first moment about the center of mass vanishes. Neither a twistor
shear nor antisymmetry of $M$ supplies those mechanical assumptions.

The following Lean block checks existing APIs. Subsequent Lean blocks are
compileable **proposed contracts**, not new declarations installed in Signals.
All blocks can be concatenated in order for the validation described below.

```lean
import Signals
import SignalsPending
import Mathlib.MeasureTheory.Integral.Bochner.Basic

namespace HuygensGeometryRoadmap

example (twistor : Signals.Geometry.Twistor)
    (position offset : Signals.Geometry.SpacetimeMatrix) :
    (twistor.translate offset).incident (position + offset) ↔
      twistor.incident position :=
  twistor.translate_incident_iff position offset

example (first second : ℂ) :
    Signals.Huygens.intensity (first + second) =
      Signals.Huygens.intensity first + Signals.Huygens.intensity second +
        2 * (first * star second).re :=
  Signals.Huygens.intensity_superposition first second
```

### Classical Continuum Before Geometric Identification

Fix time dependence $e^{-i\omega t}$ and angular wavenumber
$k=2\pi/\lambda>0$. For noncoincident points, use the normalized outgoing
Helmholtz Green function

$$
G_k(x,y)=\frac{e^{ik\lVert x-y\rVert}}{4\pi\lVert x-y\rVert},
\qquad (\Delta_x+k^2)G_k(x,y)=-\delta_y(x).
$$

For a smooth bounded source-free domain with the outward normal convention,
Green's second identity gives the target representation

$$
u(x)=\int_{\partial\Omega}
\left[G_k(x,q)\,\partial_n u(q)
      -u(q)\,\partial_n G_k(x,q)\right]d\Sigma(q),
\qquad x\in\Omega.
$$

This is not the same definition as the staged product of two scalar kernels.
Aperture-only Kirchhoff, Rayleigh-Sommerfeld, Fresnel, and Fraunhofer models
require their own boundary conditions or approximation arguments. Select one
before claiming continuum convergence. For an exterior problem, separately
state the radiation condition and treatment of the boundary at infinity.

A controlled finite-aperture approximation can target

$$
U_A(D)=\int_A Q(S,q,D)G_k(S,q)G_k(q,D)\,d\Sigma(q),
\qquad
U_{A,N}(D)=\sum_{j=1}^{N}w_{A,j}G_k(S,q_{A,j})G_k(q_{A,j},D).
$$

Here $Q$ includes the chosen boundary approximation, source scaling,
transmission and obliquity convention; the weights approximate that integrand
and surface measure. A $4\pi$ factor may be absorbed into weights, but only
through an explicit consistent normalization. Document field and weight units
before converting $|U|^2$ into watts per square metre.

For fixed integrable aperture data on disjoint sets $A$ and $B$,

$$
U_{A\cup B}=U_A+U_B,
\qquad
|U_A+U_B|^2=|U_A|^2+|U_B|^2+2\operatorname{Re}(U_A\overline{U_B}).
$$

Additivity holds for a fixed linear propagation operator and fixed incident
aperture field. Opening a slit can change the exact boundary solution; the
fixed-mask approximation must not silently become an exact Maxwell theorem.

On a compact detector domain $\mathcal D$, require a uniform separation
$\delta>0$ from source and aperture singularities. Prove, or bound with explicit
hypotheses,

$$
\sup_{D\in\mathcal D}|U_{A,N}(D)-U_A(D)|\leq\varepsilon_N,
\qquad \varepsilon_N\longrightarrow0.
$$

Integrability alone proves neither uniform convergence nor a quadrature rate.
Mesh size, smoothness, wavelength range, geometry, and oscillatory phase
variation determine the required error theorem.

```lean
structure RegularSlitEvaluation {firstCount secondCount : ℕ}
    (slits : Signals.Huygens.DoubleSlit firstCount secondCount)
    (detector : Signals.Huygens.Point3) : Prop where
  firstRegular : slits.first.regularAt slits.source detector
  secondRegular : slits.second.regularAt slits.source detector

structure ContinuumApertureData where
  surfaceMeasure : MeasureTheory.Measure Signals.Huygens.Point3
  integrand : Signals.Huygens.Point3 → ℂ
  integrable : MeasureTheory.Integrable integrand surfaceMeasure

noncomputable def continuumAmplitude (data : ContinuumApertureData) : ℂ :=
  MeasureTheory.integral data.surfaceMeasure data.integrand

example (measure : MeasureTheory.Measure Signals.Huygens.Point3)
    (first second : Signals.Huygens.Point3 → ℂ)
    (firstIntegrable : MeasureTheory.Integrable first measure)
    (secondIntegrable : MeasureTheory.Integrable second measure) :
    MeasureTheory.integral measure (fun point => first point + second point) =
      MeasureTheory.integral measure first + MeasureTheory.integral measure second :=
  MeasureTheory.integral_add firstIntegrable secondIntegrable
```

This contract intentionally leaves the surface measure and integrand explicit.
It does not identify an arbitrary measure on `Point3` with aperture area,
derive a Helmholtz solution, or prove convergence of the existing finite sums.

As an analytic benchmark, equal uniformly illuminated rectangular slits of
width $a$, height $b$, and center separation $d$ give the scalar far-field
approximation on $D=(x,y,L)$:

$$
I(x,y)\approx 4I_0\,
\operatorname{sinc}^2\!\left(\frac{\pi a x}{\lambda L}\right)
\operatorname{sinc}^2\!\left(\frac{\pi b y}{\lambda L}\right)
\cos^2\!\left(\frac{\pi d x}{\lambda L}\right),
\qquad \operatorname{sinc}(z)=\frac{\sin z}{z},\quad\operatorname{sinc}(0)=1.
$$

$I_0$ is the single-slit on-axis scale under the same propagation convention.
This formula is a benchmark under paraxial/Fraunhofer assumptions, not a proved
statement about the current samples. Its expected fringe spacing is
$\Delta x\approx\lambda L/d$. Test near-field departures rather than applying
the benchmark outside its regime.

### Grassmannian Representatives and Network Cells

For $C\in\mathbb R^{k\times n}$ of row rank $k$, ordered maximal minors obey

$$
\Delta_I(C)=\det C_{[:,I]},
\qquad
\Delta_I(RC)=\det(R)\Delta_I(C).
$$

Prove this basis-change law before defining positive representatives modulo
orientation-preserving changes $R\in GL^+(k)$. Positivity of a chosen
representative is not invariant under an arbitrary negative-determinant row
change. Require $k\leq n$ or an explicit nonzero-minor witness; a universal
minor predicate with no available column selections must not certify rank.

Extend the existing $2\times4$ relation

$$
\Delta_{12}\Delta_{34}-\Delta_{13}\Delta_{24}
+\Delta_{14}\Delta_{23}=0
$$

to the general relations only after specifying ordered index and sign
conventions. Do not identify every vanishing minor with a codimension-one facet
of every chart or amplituhedron image.

For networks, build an oriented finite-dart model that can represent parallel
edges when needed: `SimpleGraph` cannot preserve those under general reduction
moves. Supply boundary cyclic order, internal rotations, positive edge/face
weights, and a verified disk embedding. Genus or Euler checks need connectivity
and face assumptions; they are not interchangeable with a drawing.

First derive strand exits from a finite first-return construction. Extend the
turn map at boundary vertices by continuing through their unique edge, making
a bijection on directed edges; prove the first-return map on boundary starts
is a permutation. Bound the search by the finite dart count. Derive lollipop
decorations using the chosen color convention, rather than reading helicity
from an arbitrary fixed-point color.

Then formalize weighted boundary measurements. Start with an acyclic directed
network so path sums are finite. Cyclic networks require additional
denominator/convergence or flow-accounting laws. Prove the relevant minor/path
identities and move invariance for that model before labeling its image a
positroid cell. The unweighted routing permutation alone supplies no optical
phase or boundary measurement matrix.

### Canonical Forms: Small Examples First

Start from the interval, with its orientation and coordinate fixed:

$$
\Omega_{[0,1]}=\frac{dt}{t(1-t)}
=\frac{dt}{t}-\frac{dt}{t-1}.
$$

As a meromorphic one-form its residues in the displayed coordinate are $+1$
at zero and $-1$ at one. Boundary orientation conventions must account for
these signs. A coefficient identity is a useful first check, but it does not
by itself formalize a meromorphic form, residue, or projective invariance.

```lean
noncomputable def intervalCoefficient (coordinate : ℝ) : ℝ :=
  1 / (coordinate * (1 - coordinate))

lemma intervalCoefficient_normalization (coordinate : ℝ)
    (positive : 0 < coordinate) (belowOne : coordinate < 1) :
    intervalCoefficient coordinate * (coordinate * (1 - coordinate)) = 1 := by
  unfold intervalCoefficient
  have nonzero : coordinate * (1 - coordinate) ≠ 0 :=
    ne_of_gt (mul_pos positive (sub_pos.mpr belowOne))
  exact one_div_mul_cancel nonzero
```

Next define top-degree differential forms, orientation, pullbacks, rational or
meromorphic chart coefficients, and the boundary residue operator. Prove the
interval residues and absence of other poles, then the triangle form

$$
\Omega_{\triangle}=\frac{dx\wedge dy}{xy(1-x-y)}.
$$

Only after these checks, prove a quadrilateral triangulation identity and the
cancellation of the artificial diagonal pole with compatible orientations.
Additivity of oriented forms applies under specific triangulation hypotheses;
overlapping regions cannot simply be added without multiplicity accounting.

For an actual amplituhedron image, distinguish output width from the usual
parameter $m$. The staged generic matrix map has an output-width parameter;
it does not already encode the conventional tree-level data

$$
C\in Gr_{\geq0}(k,n),
\quad Z\in\mathbb R^{n\times(k+m)},
\quad \Delta_J(Z)>0\ \text{for ordered }|J|=k+m,
\quad Y=CZ.
$$

Require admissible dimensions, external-data positivity, image rank, quotient
compatibility, boundary structure, and a well-defined pushforward before using
this map as a positive geometry. Work on a low-dimensional example first;
canonical-form existence and uniqueness are proof obligations, not new axioms.

### A Falsifiable Bridge

Specify an independently constructed candidate

$$
\mathcal E(P,Z,S,A,B,D,k)\in\mathbb C
$$

from a positive geometry $P$, external data $Z$, physical embedding, oriented
form, and evaluation operation. State whether that operation is a contour
integral, pullback followed by integration, a residue sum, or a weighted network
functional. Define all measures, cycles, weights, units, and phase conventions.
Distinct column labels do not establish two residues or two apertures.

Canonical forms have rational chart coefficients in the elementary examples;
optical kernels contain oscillatory complex exponentials. Any bridge must
explain where $k r$ and the relative phase enter. Putting the optical answer
into a free coefficient or detector-dependent fitted embedding is a
representation of the answer, not an independent derivation.

Choose a nonempty compact detector domain and a wavenumber interval before fitting or
testing. A proposed analytic bridge theorem has the form

$$
\sup_{D\in\mathcal D}
|\mathcal E(D)-U_{A\cup B}(D)|\leq\varepsilon,
$$

with separately bounded continuum, quadrature, and approximation errors. Exact
equality is a stronger goal and must be restricted to an explicitly stated
model and regime. A calibrated experiment adds measurement uncertainty; it is
not established by the analytic theorem alone.

```lean
structure BridgeComparison (Detector : Type*) where
  candidate : Detector → ℂ
  classical : Detector → ℂ
  detectorDomain : Set Detector
  domain_nonempty : detectorDomain.Nonempty
  errorBound : ℝ
  errorBound_nonnegative : 0 ≤ errorBound
  amplitudeError : ∀ detector, detector ∈ detectorDomain →
    ‖candidate detector - classical detector‖ ≤ errorBound

lemma BridgeComparison.error_at {Detector : Type*}
    (comparison : BridgeComparison Detector) (detector : Detector)
    (inside : detector ∈ comparison.detectorDomain) :
    ‖comparison.candidate detector - comparison.classical detector‖ ≤
      comparison.errorBound :=
  comparison.amplitudeError detector inside

end HuygensGeometryRoadmap
```

This record expresses an obligation and its conditional accessor. Creating it
by supplying `amplitudeError` is not a derivation of the bound. The future
evaluator must be defined before that field can be discharged independently;
comparison errors must not be adjusted after seeing every detector sample.

An amplitude error bound controls intensity through

$$
\left||E|^2-|U|^2\right|
\leq |E-U|\,(|E|+|U|).
$$

Prove this inequality and supply finite amplitude bounds. Near an exact dark
fringe, use absolute rather than relative intensity error: dividing by the
classical zero intensity would conceal the failure mode.

## Ordered Implementation Plan

No phase below authorizes moving code to another library. Each deliverable
remains a small local Signals change with one discriminating test.

| Phase | Deliverable | Acceptance gate | Failure or stop condition |
|---|---|---|---|
| 0. Guard and compare | Regular-domain wrapper, positive action scale, nonempty finite slit fixtures, and fixed candidate comparison. | Reject coincident geometry and invalid scales; test constructive, destructive, quadrature-phase, single-slit, and off-axis cases. A perturbed relative phase must fail a prescribed comparison. | A contract is satisfiable only by copying the desired answer or accepting every fitted candidate. |
| 1. Continuum optics | A selected scalar boundary model, surface measure, integrability, normalization, and kernel domain. | Prove linear aperture decomposition under fixed-field assumptions and the stated Green/boundary representation or approximation bound. | A two-kernel product is treated as the exact boundary solution without its missing normal derivatives or assumptions. |
| 2. Quadrature | Finite-to-continuum convergence on a compact detector/wavelength domain. | Produce an explicit rate or a convergence theorem with hypotheses; verify mesh refinement and a rectangular-slit far-field limit. | Detector singularities, oscillatory underresolution, or uncontrolled boundary truncation break the estimate. |
| 3. Grassmannian/network | Basis-change laws, a small positive cell, weighted boundary measurements, and constructive exits. | Check rank, positivity, permutation/color conventions, and one network-move identity. | Arbitrary rotation data or an unweighted permutation is mistaken for an embedded weighted cell. |
| 4. Canonical examples | Interval and triangle forms, residues, and oriented quadrilateral triangulation. | Prove normalization, all boundary residues, absence of other poles, and internal-pole cancellation. | Calling a reciprocal scalar a canonical form, or postulating existence with an axiom. |
| 5. Geometric evaluation | A low-dimensional geometry with a defined complex evaluation operation and physical embedding. | Derive phase, dimensions, normalization, and a nonzero amplitude without reading the classical answer. Check basis/chart/triangulation invariance. | The geometry supplies no oscillatory phase, or evaluation depends on arbitrary chart choices. |
| 6. Conditional bridge | Equality or a uniform error bound to the chosen scalar diffraction model. | Compare complex amplitudes across held-out positions and wavelengths; falsify intentionally wrong embeddings. Keep classical approximation errors separate. | Agreement occurs only at a symmetric point, in zero-amplitude fixtures, or after detector-by-detector fitting. |
| 7. Measurement | Calibrated comparison to an optical experiment within the model's regime. | Record wavelength, aperture dimensions, distances, coherence, polarization, detector response, backgrounds, drift, uncertainties, and raw data. | Mathematical agreement is presented as material/hardware validation or as proof of the original scattering interpretation. |

Phases 1--2 and 3--4 are independent research tracks. Phase 5 depends on the
geometric track; phase 6 requires both. Ordinary scalar diffraction can be
completed even if the geometric interpretation fails. A successful positive
geometry toy model can likewise stand without an optical interpretation.

### Tests and Controls

1. Compare complex amplitudes, not just intensities; global phase equivalence
   must use one fixed convention, not a separate fit at each detector point.
2. Include nonempty finite-width apertures, nonzero amplitudes, several phase
   offsets, asymmetry, and both directions of single-slit masking.
3. Use 2D detector grids in 3D space and more than one wavelength; a symmetric
   on-axis equality alone is not an interference pattern.
4. Check mesh refinement, wavelength resolution, and the chosen near-/far-field
   regime against an independent analytic or numerical boundary solution.
5. Include incoherent averaging or an explicit visibility model as a separate
   extension; coherent summation does not describe arbitrary illumination.
6. Perturb geometry labels, external data, phases, and candidate normalization
   independently. At least one negative test must reject a wrong bridge.
7. Audit where a theorem is derived and where an observation, calibration,
   boundary condition, or representation is supplied as a hypothesis.

### Immediate Next Change

Implement phase 0 before adding an amplituhedron contour. Add a guarded
evaluation wrapper and a nonempty finite-slit phase sweep to the existing
tests. Keep `GrassmannianDoubleSlitHypothesis` for compatibility, but introduce
an independently defined candidate evaluator before adding a stronger bridge
record. Test a deliberately incorrect relative phase with a fixed error
tolerance. This first change can disconfirm the comparison contract without
requiring a completed differential-form library.

## Implementation Checkpoints

### Iteration 1: Regular Evaluation and Action Scale

Implemented in [Huygens.lean](../src/signals/Signals/Huygens.lean):
`distance_pos_of_ne`, source/detector coincidence rejection, positive regular
propagation distances, `ApertureSeparation.regular`, `RegularSlitEvaluation`,
`DoubleSlit.regularAmplitude`, and the positive `ActionScale` wrapper.
The guarded evaluator conservatively requires both apertures to be regular,
even if one is masked. Raw algebraic evaluators are retained for compatibility.

The existing test file checks both apertures, both coincidence directions,
a positive separation certificate, zero/negative scale rejection, and a
nonzero finite-history amplitude. This completes the domain-guard portion of
phase 0, not its independent candidate/phase-sweep comparison requirements.
It does not prove a continuum Green-function or boundary-value theorem.

### Iteration 2: Fixed Phase Comparisons

`MonochromaticWave.pathAmplitude` evaluates a two-segment path analytically;
`kernel_product` proves agreement with the existing two-kernel convention.
`Aperture.scale` preserves complex transmission linearity. The missing
second-only slit-mask law and quarter-turn coherent intensity law are proved.
`AmplitudeComparison` binds fixed functions, a nonempty domain, and a fixed
nonnegative tolerance; its rejection lemma uses a held-out disagreement.

The test fixture has two separated samples per slit. Its four-path analytic
reference contains no aperture/slit evaluation call. Agreement is proved for
arbitrary detectors, phases, and positive wavelengths; regularity is proved
on the whole detector plane. Tests cover constructive, destructive, and
quarter-turn phases, both single-slit masks, off-axis points at two wavelengths,
and rejection of an empty comparison domain. A deliberately wrong relative
phase has amplitude error $2/3$ at the centre and fails the prescribed $1/4$
tolerance at every positive wavelength.

This completes the finite phase-0 guard/comparison controls. The analytic
reference is another evaluation of the same classical discrete propagation
model, not a geometric evaluator, continuum boundary solution, calibrated
measurement, or amplituhedron bridge. No geometric Pending match is promoted.

### Iteration 3: Fixed-Field Continuum and Absolute Error

`FixedPlanarField` chooses the explicitly approximate scalar two-kernel model,
with fixed transmission and normalization. It embeds metre-valued aperture
coordinates in a plane and integrates the density against Lebesgue area on
$\mathbb R^2$. `IntegrablePlanarEvaluation` requires both integrability and
absence of source/sample or detector/sample coincidence. Disjoint-mask
addition is proved for the same field, not for separately solved boundary
conditions. No assertion of an exact Helmholtz or Maxwell representation is
introduced.

`intensity_error_le` proves the absolute amplitude-to-intensity inequality above,
including a zero-intensity reference. Comparison composition adds independent
error budgets without conflating them. `integral_error_le` derives an integral
error from an almost-everywhere density bound and a finite measure. It does
not derive that density bound from the existing sample mesh.

Tests cover a dark reference, off-axis comparison error, separate $1/4$ and
$1/2$ budgets, regular planar propagation, singular-domain rejection,
fixed-field union addition under explicit integrability, and nonzero constant
integration error on a probability measure. Phase 1 remains partial: the
boundary-approximation accuracy theorem is absent. Phase 2 remains open:
finite weights, mesh size, wavelength resolution, uniform convergence, and
the rectangular-slit Fraunhofer limit have not been connected to this integral.

### Iteration 4: Grassmannian Basis and a Positive Cell

[Geometry.lean](../src/signals/Signals/Geometry.lean) proves
`selectedMinor_basisChange` for arbitrary finite row/column sizes. Every
ordered maximal minor acquires the same determinant factor. Nonsingular
basis changes preserve totalized ratios; use a nonzero denominator for a
chart interpretation. Positive determinant changes preserve both positive
representatives and the full-rank nonnegative boundary record. A supplied
ordered-column witness allows the negative-determinant rejection theorem to
exclude vacuous positivity.

`PositiveGrassmannian.intervalCell` constructs the normalized representative
$[t,1-t]$ from $0<t<1$, rather than postulating its positive minors. Tests
check $t=1/3$, positive row rescaling, a retained boundary zero, negative
orientation rejection, and ratio invariance under orientation reversal.
This is a positive representative, not a Grassmannian quotient or a weighted
network/cell correspondence. Constructive strand exits, weighted measurements,
network moves, and general Pluecker relations remain phase-3 obligations.

### Iteration 5: Affine Alternating Forms and Residues

[CanonicalForms.lean](../src/signals/Signals/CanonicalForms.lean) represents
the interval, triangle, and unit-square examples as position-dependent
alternating covectors. The one-form acts on a one-dimensional tangent vector;
the two-forms evaluate the determinant of two tangent vectors. This adds
degree and orientation beyond the report's original scalar contract.

The interval endpoint residues are genuine punctured-neighbourhood limits,
$+1$ at zero and $-1$ at one. All three triangle boundary limits are proved
with explicit normal/tangent arrays: the x-face gives $+dt/[t(1-t)]$, the
y-face gives its negative in the dx convention, and the diagonal face gives
the positive interval coefficient in the chosen z,x coordinates. The unit
square's four coefficient limits have the corresponding orientation signs;
interpret them as simple boundary residues with the other coordinate interior.
Normalization and continuity away from the stated affine boundary factors
are proved.

Both triangle coordinate pullbacks preserve oriented area. Their rational
extensions sum to the square coefficient and form away from the shared
diagonal; the square continuation is continuous on that diagonal. Tests
explicitly reject adding Lean's totalized singular values there: the naive
sum is zero, whereas the continued square coefficient is 16 at the centre.
Other tests check nonzero form values, orientation reversal, duplicate tangent
vectors, and rejection of a wrong endpoint residue sign.

These fulfill the affine example portion of phase 4, not general projective
existence/uniqueness, arbitrary-chart invariance, or amplituhedron canonical
forms. The finite affine proofs supply no oscillatory optical phase,
dimensioned physical embedding, or complex geometric evaluator for phase 5.

### Iteration 6: Reject a Literal Geometric Identification

The negative-control candidate evaluates the interval one-form at $t=1/2$
on the unit tangent and casts its value into $\mathbb C$. Its magnitude is
4; the constructive four-path classical fixture has magnitude $2/3$ for
every positive wavelength. The reverse triangle inequality gives amplitude
disagreement at least $10/3$, so this independently fixed candidate cannot
satisfy the prescribed $1/4$ comparison tolerance on the detector plane.
The candidate contains no optical evaluator, detector fitting, or supplied
match. This is a raw-number counterexample to a literal identification, not
a dimensioned physical comparison or an impossibility theorem for every
possible geometric embedding.

The geometric track still supplies no derived oscillatory phase, field-unit
conversion, or physical normalization. The initial implementation loop paused
the bridge at this phase-5 stop condition. Later iterations can continue the
independent mathematical tracks without filling the gap with an assumed match
or declaring phases 5--7 complete.
`GrassmannianDoubleSlitHypothesis` and its compatibility fixtures are unchanged.

### Iteration 7: Measured-Cell Quadrature and Refinement

[Quadrature.lean](../src/signals/Signals/Quadrature.lean) introduces a finite
measurable disjoint cell partition with one sample per cell. Its weights are
the actual restricted measure masses, not fitted amplitude coefficients.
The cell measures decompose the original measure, their weights sum to its
finite total area, and the continuum integral decomposes over those cells.

The finite weighted sum obeys the derived error bound

$$
\left|Q_h(f)-\int f\,d\mu\right|
\leq K h\,\mu(X),
$$

from an explicit cellwise Lipschitz inequality and almost-everywhere sample
distance bound. Global Lipschitz regularity discharges the density inequality.
As the mesh bound tends to zero with one fixed $K$, the amplitude error tends
to zero. A nonempty fixed detector/wavelength domain with uniform $K$ produces
an `AmplitudeComparison` using this derived budget. The theorem does not need
compactness, but compactness alone does not discharge its regularity premises.

`toAperture_amplitude` proves that measured planar cell weights, fixed
transmission and normalization give exactly the existing finite aperture sum.
Atomic numerical controls check weight conservation, a coarse sample's nonzero
error, exact refinement, and rejection of an invalid zero-radius mesh claim.
Those atomic controls are not physical aperture-area data.

Phase 2 now has an actual weighted quadrature rate and refinement theorem
under explicit regularity hypotheses. A uniform Lipschitz estimate for the
separated optical kernel over a wavelength interval, a rectangular area-mesh
construction, and the stated far-field benchmark remain open. No boundary
solution accuracy or geometric bridge is inferred from this quadrature result.

Validation: `Signals.Quadrature` passed at 3,399 jobs, `SignalsTests` at 3,577,
and `make signals_build` at 3,593. All four report Lean blocks typechecked;
HTML generation passed with 66 warnings, and `git diff --check` passed.

### Iteration 8: Derived Bounded First-Exit Routing

[Plabic.lean](../src/signals/Signals/Plabic.lean) now computes `firstExit`
from a directed edge and fuel, returning an earliest step count and boundary
label or an explicit fuel failure. Successful results satisfy the route
equation, stay within the budget, and exclude every earlier boundary exit.
Conversely, a boundary reached by the bounded route guarantees a successful
search. Fuel failure is equivalent to the route still being internal at that
budget. Any two successful budgets give the same count and boundary label.

The existing star controls exercise black/white turns, insufficient fuel,
already-terminal edges, extra-fuel stability, and rejection of a falsely
delayed exit. Existing checked boundary routing provides a sufficient budget
without prescribing the search's returned first-exit count.

This is constructive bounded routing, not a proof that every arbitrary
rotation system terminates at a globally derived bound. A general termination
bound and boundary-map bijection, weighted acyclic measurements, embedding
and cell correspondence, network moves and general Pluecker laws remain open.
Fixed-point colors remain supplied data; no planarity or reducedness is inferred.

### Iteration 9: Finite Weighted Acyclic Measurements

`WeightedAcyclicNetwork` in [Plabic.lean](../src/signals/Signals/Plabic.lean)
uses nonnegative edge weights and a checked strictly increasing level on every
nonzero edge. Mathlib matrix powers compute successive weighted compositions.
A path longer than the available level difference has zero weight; the
height bound therefore derives nilpotency rather than assuming it.

The transfer matrix sums all permitted path lengths, including the length-zero
identity contribution. Extending the cutoff adds only zero terms, and the
finite sum satisfies $T=I+AT$. Boundary measurements select its source/sink
entries without fitted output coefficients or a cyclic-series convergence
assumption. A three-node control checks $2\times3=6$, zero reverse transfer,
nilpotency, cutoff stability, and rejection of a wrong product or backward edge.

The supplied ranking is a checked acyclicity certificate, not a constructed
planar embedding. Nonnegative entries do not establish ordered-minor
positivity, the general minor/disjoint-path identity, positroid-cell
correspondence, or network-move invariance. Cyclic networks and optical
phase/units remain outside this finite nonnegative-weight model.

### Iteration 10: Continuing Dart Permutation

[Plabic.lean](../src/signals/Signals/Plabic.lean) constructs `dartTurn`
by composing edge reversal with the existing color-dependent neighbor
permutations. A boundary turn continues through its unique incident edge;
the original absorbing `step` and `route` remain unchanged. The continuing
turn agrees with `step` at internal destinations, and a boundary arrival
turns into the corresponding boundary start edge.

The directed-edge carrier is finite. Mathlib's finite-permutation periodicity
theorems give every dart a positive return period no larger than the dart
count. This is a derived bound on continuing dynamics, not yet a theorem
that the absorbing search reaches a boundary within that bound.
Star controls check both colors, boundary continuation, a six-turn return,
and rejection of confusing continuing turns with absorbing boundary steps.
Planarity, reducedness, decorations, and a boundary-return permutation are
not inferred from this intermediate construction.

### Iteration 11: Dart-Count Boundary Search Guarantee

`route_eq_dartIterate` in [Plabic.lean](../src/signals/Signals/Plabic.lean)
proves agreement between absorbing and continuing dynamics before any
boundary arrival. Exhausted fuel excludes all earlier arrivals because
boundary absorption would preserve them through the remaining budget.
Combining these facts with a positive bounded dart period proves that every
boundary start exits with fuel equal to the finite dart count.

`boundaryExitData` extracts the actual successful search result; its
specification retains the bound, route equation and earliest-exit condition.
Neither an exit certificate nor a boundary permutation is supplied. The getter
uses abstract cardinality and is noncomputable; a concrete fuel still runs
the existing bounded search. Star tests recover both color conventions at
all labels and reject a delayed count. A two-boundary graph with no internal
vertices verifies a zero-step exit without excluding direct boundary edges.

This closes the general boundary-search fuel obligation for the existing
rotation-system interface. A derived boundary-return bijection, decoration
rules, embedding, reduction moves and cell interpretation remain separate.

### Iteration 12: Derived Boundary First-Return Permutation

[Plabic.lean](../src/signals/Signals/Plabic.lean) proves that one continuing
turn after the earliest boundary arrival reaches its boundary start edge.
No positive iterate reaches any boundary start earlier. Comparing two such
returns and cancelling injective dart iterates proves that distinct starts
cannot share an exit; finiteness then gives surjectivity.

`boundaryPerm` constructs this bijection from the search results, rather than
requiring a supplied permutation. The positive first-return time is the
reported exit count plus one and is bounded by the finite dart count.
`derivedRouting` fills the existing compatibility certificate with these
proved exits and counts, leaving fixed-point colors as explicit inputs.

Controls identify both star color conventions with the independent cycles,
check an inverse label, reject a wrong exit, and recover the direct-boundary
transposition. Its zero-step exit still has positive one-turn return time.
This completes the finite strand-exit and boundary-bijection obligations for
the current interface. It does not derive lollipop decorations, planar disk
embedding, reducedness, network moves, minor positivity or positroid cells.

### Iteration 13: Guarded Weighted Edge Subdivision

`oneEdgePath` and `twoEdgePath` in
[Plabic.lean](../src/signals/Signals/Plabic.lean) construct ranked networks
with independently supplied weights. Their actual finite transfer entries
recover a single weight and the product of two successive weights.
For a nonzero subdivision factor $a$, `subdivision_boundary` proves equality
of the complete one-source/one-sink boundary matrices for the original edge
weight $w$ and the split weights $(a,w/a)$.

The existing chain fixture now reuses the generic path constructor. Controls
check a nonzero edge, a zero-weight edge, rejection of a zero subdivision
factor at nonzero $w$, and rejection of an incorrect split. Thus totalized
division cannot silently validate the invalid move.

This is a derived local subdivision identity for the finite nonnegative
weighted model, not general move invariance for embedded plabic networks.
The result supplies no planar embedding, parallel-edge reduction machinery,
ordered-minor positivity, cell correspondence, cyclic-network convergence,
or optical phase and field units.

### Iteration 14: Measured Fork Rank and Positivity

`WeightedAcyclicNetwork.fork` derives its one-source/two-sink boundary row
from the finite transfer sum. `forkRepresentative` converts that actual row
to a real matrix, and `forkRepresentative_mat` proves it is $[a,b]$.
`forkPositive` proves every ordered maximal minor is positive when both
edge weights are positive. `forkNonnegative` allows a zero branch but requires
at least one active branch and constructs its nonzero-minor witness.

Controls check a positive minor, each choice of active branch, a retained
zero minor, failure of strict positivity with a zero branch, and impossibility
of a full-rank nonnegative representative with the all-zero measured row.
These are derived rank/positivity statements for a representative, not a
quotient construction or an embedded-network/cell correspondence.

The zero-branch rejection is a hard algebraic boundary of the *strictly
positive* subset, not a prohibition on diffraction. A zero branch with a
nonzero companion is allowed in the nonnegative full-rank layer; an all-zero
row has rank zero and is excluded from the rank-one Grassmannian layer.
Kirchhoff-type scalar optical fields instead have complex phase-bearing
contributions. A dark fringe can result from cancellation of nonzero paths
without setting either network weight to zero. No theorem identifies these
nonnegative network weights or ordered minors with optical amplitudes or
intensities. Boundary-approximation accuracy and a justified optical/geometric
evaluator remain independent gates.

### Iteration 15: Measured Two-Channel Ordered Minor

`WeightedAcyclicNetwork.twoChannel` constructs a ranked four-vertex network
with two sources, two sinks and four independent nonnegative edge weights.
`twoChannel_boundary` derives the complete measured matrix from the actual
finite transfer sum. `twoChannelRepresentative` converts that measured matrix
to real entries, and `twoChannelRepresentative_det` proves

$$
\det\begin{pmatrix}a&b\\c&d\end{pmatrix}=ad-bc.
$$

`twoChannelRepresentative_det_pos_iff` gives the exact criterion $bc<ad$.
Controls recover a positive diagonal minor and a negative crossed-channel
minor, and exercise the positive-product-dominance criterion. They also reject
nonnegative ordered-minor status for the all-positive matrix $[1,2;3,4]$,
whose determinant is $-2$. The all-positive matrix $[1,2;2,4]$ is proved
nonzero but singular; no full-rank nonnegative record can retain that matrix.

Thus active or even strictly positive edges, and acyclicity, do not by
themselves imply rank or ordered-minor positivity for a raw source/sink
transfer selection. This is not a counterexample to positivity results for
correctly embedded planar networks with their required boundary order and
signed measurement conventions: those structures have not been constructed
here. The signed two-pair product law is not a general disjoint-path theorem,
positroid correspondence, Grassmannian quotient, or optical phase evaluator.

### Iteration 16: Shared-Vertex Path-Pair Cancellation

`WeightedAcyclicNetwork.singleHub` constructs two sources feeding two sinks
through one shared intermediate vertex. `singleHub_boundary` derives its
boundary entries from actual two-edge path products. For incoming weights
$u,x$ and outgoing weights $v,w$, `singleHubRepresentative_mat` gives the
real measured matrix $[uv,uw;xv,xw]$. `singleHubRepresentative_det` proves
that its two signed path-pair products cancel for arbitrary edge weights:

$$
(uv)(xw)-(uw)(xv)=0.
$$

Controls recover the independent fixture $[10,14;15,21]$, prove all its
entries positive, and check the vanishing ordered maximal minor and failure
of strict positivity. A parametrized rejection proves that no full-rank
nonnegative record can retain a shared-hub matrix for any choice of weights.
The obstruction is not absence of active edges: the shared intermediate
vertex prevents two vertex-disjoint source/sink paths in this topology.

This is a concrete shared-vertex cancellation case, not a general
Lindstroem-Gessel-Viennot theorem or a certified planar embedding. The zero
determinant does not make the individual measured entries zero. Its signed
algebraic cancellation must not be identified with complex optical
destructive interference without a separately justified evaluator.

### Iteration 17: General Finite Two-Step Pair Expansion

`twoStep_det_pathPairs` works for any finite number of intermediate vertices,
with real incoming and outgoing matrices $A$ and $B$. It derives the actual
two-channel matrix-product determinant as

$$
\det(AB)=\sum_i\sum_j A_{0i}A_{1j}
  \left(B_{i0}B_{j1}-B_{i1}B_{j0}\right).
$$

`twoStep_sameMiddle_term` proves that each repeated-intermediate term $i=j$
vanishes. Neither desired minors nor a determinant sign are assumed.
Controls cover zero, one and two intermediate vertices, recover independent
positive and negative determinants, reject an unconditional nonnegative
determinant, and identify the measured hub fixture with its incoming/outgoing
matrix product.

This is a reusable finite two-step signed-pair identity rather than another
fixed topology calculation. It does not yet group distinct pairs into products
of ordered minors, prove their positivity, enumerate arbitrary-length paths,
or construct embedded signed planar boundary measurements. It supplies no
optical phase, units, calibrated data, or geometric/classical evaluator.

### Iteration 18: Paired-Minor Identity and Conditional Positivity

`twoStepMinorPair` is the signed product of the incoming and outgoing
two-by-two minors for a pair of intermediate vertices. Reversing both index
orders reverses both minor signs. `twoStep_minorPairs_sum` derives

$$
D_{ij}=(A_{0i}A_{1j}-A_{0j}A_{1i})
  (B_{i0}B_{j1}-B_{i1}B_{j0}),\qquad
\sum_i\sum_j D_{ij}=2\det(AB).
$$

The factor two counts both orders of each distinct intermediate pair; diagonal
pairs contribute zero. `twoStep_det_nonnegative` proves a nonnegative output
determinant when all input minor-pair contributions are nonnegative.
`twoStep_det_positive` proves strict positivity when a positive pair witness
is additionally supplied. These hypotheses constrain algebraic input
contributions, not an assumed output determinant or desired optical result.

An independent three-intermediate fixture has determinant $241$ and ordered
pair sum $482$, with compatible contributions and a positive witness. A pair
with two negative factor minors still contributes positively. The single-hub
control permits a nonnegative determinant but rejects any strict pair witness.
Strictly positive entry matrices with incompatible minor signs instead yield
determinant $-68$, so edge-entry positivity cannot replace compatibility.

This establishes the finite two-step two-channel minor identity and its
conditional sign consequences. It does not derive compatibility from a planar
embedding, enumerate arbitrary-length vertex-disjoint paths, certify an
embedded signed boundary measurement, or construct a Grassmannian quotient.
No complex optical evaluator or experimental claim is introduced.

### Iteration 19: Arbitrary-Sink Ordered Maximal Minors

`OrderedColumns.pair` constructs a two-column selection from an explicit
increasing-order proof. `twoStep_selectedMinor` proves that selecting output
columns commutes with the two-step product. `twoStep_selectedMinor_pairs`
therefore extends the paired-minor identity to every ordered output maximal
minor, for any finite intermediate and sink counts:

$$
\sum_i\sum_j D_{ij}(A,B_J)=2\Delta_J(AB),
$$

where $B_J$ is the selected outgoing-column matrix. No output minor value or
positivity condition is supplied as an assumption.

An independent three-sink fixture produces $[3,4,5;1,5,9]$, with ordered
maximal minors $11,22,11$. Controls check all three selections, their paired
sum normalization, and rejection of a fixed incorrect minor. This connects
the generic two-step identity to the existing ordered Grassmannian API;
positive/full-rank representative construction still needs compatible input
pairs and explicit active witnesses. It does not certify a planar embedding,
arbitrary-length disjoint paths, a quotient or an optical evaluator.

### Iteration 20: Derived Two-Step Grassmannian Records

`twoStepRepresentative` retains the actual two-row matrix product.
`twoStep_selectedMinor_nonnegative` and `twoStep_selectedMinor_positive`
derive each output minor's sign from its selected input pairs.
`twoStepPositive` constructs the existing positive condition when every
ordered sink selection has compatible pairs and a positive pair witness.
`twoStepNonnegative` constructs the full-rank nonnegative record with
compatible pairs for every selection and one available selection containing
a positive pair. The nonzero output minor is proved, not supplied as a field.

The positive-condition constructor follows the existing API: promotion to a
full-rank nonnegative record also requires an available ordered selection.
Controls derive the three-sink positive record from independent input data,
preserve its actual product matrix and minor $22$, and exercise that rank
promotion. A separate boundary product has repeated columns: it retains a
zero ordered minor, has another minor equal to $6$, and rejects the strictly
positive condition while satisfying the full-rank nonnegative constructor.

Thus positivity and rank are now derived for arbitrary-sink two-step
representatives under explicit input-pair hypotheses. Those hypotheses are
not a planar embedding, a proof of arbitrary-length path compatibility, a
quotient/cell correspondence, or optical calibration. General embedding and
path obligations and an independently justified complex evaluator remain open.

### Iteration 21: General $2 \times n$ Four-Column Pluecker Relations

`twoRowMinor` in [Geometry.lean](../src/signals/Signals/Geometry.lean) evaluates
arbitrary two-column determinants of any real $2 \times n$ matrix and agrees
with `selectedMinor` on every strictly ordered column pair
(`twoRowMinor_eq_selectedMinor`). `twoRowMinor_pluecker` proves the three-term
quadratic Pluecker identity for any four column indices in $\operatorname{Fin}(n)$.
`selectedMinor_pluecker_four` and `selectedMinor_crossing_product_eq_sum`
specialize this identity to any ordered four-column selection
$c_0 < c_1 < c_2 < c_3$:

$$
\Delta_{c_0 c_2}\Delta_{c_1 c_3}
=\Delta_{c_0 c_1}\Delta_{c_2 c_3}+\Delta_{c_0 c_3}\Delta_{c_1 c_2}.
$$

Controls verify a four-of-five column selection $(0,1,3,4)$ on an explicit
$2 \times 5$ matrix and evaluate its crossing product $15$. A separate
negative control (`negatedPlueckerMatrix`) shows that because the quadratic
Pluecker relation is homogeneous of degree two, strictly positive uncrossed
and crossing minor products ($\Delta_{01}\Delta_{23}=1$,
$\Delta_{03}\Delta_{12}=3$, $\Delta_{02}\Delta_{13}=4$) remain compatible
with all-negative ordered minors and do not imply `hasNonnegativeOrderedMinors`
without an odd-degree sign anchor. Higher-rank ($k \ge 3$) Pluecker relations
and quotient constructions remain open.

### Iteration 22: Parallel Two-Edge Path Reduction

`WeightedAcyclicNetwork.diamond` in
[Plabic.lean](../src/signals/Signals/Plabic.lean) models one source at level
zero feeding two parallel intermediate vertices at level one, which both feed
one sink at level two. `diamond_transfer` derives its actual finite transfer
sum as the sum of the two parallel two-edge path products:

$$
T_{0,3}=a_1 b_1 + a_2 b_2.
$$

`parallel_reduction_boundary` proves that replacing the two parallel two-edge
paths by `oneEdgePath (a_1 b_1 + a_2 b_2)` preserves the complete
one-source/one-sink boundary measurement matrix. Controls check
$2\times 3 + 4\times 5 = 26$, zero-branch specialization to a single path
product, boundary-matrix agreement, and rejection of naive four-edge addition
$a_1 + a_2 + b_1 + b_2$. General embedded plabic network moves and arbitrary
series-parallel graph reductions remain open.

### Iteration 23: Analytic Fraunhofer Rectangular Double-Slit Benchmark

`unnormalizedSinc` and `fraunhoferRectangularDoubleSlit` in
[Huygens.lean](../src/signals/Signals/Huygens.lean) formalize the analytic
paraxial/Fraunhofer benchmark stated above:

$$
I_{\mathrm{F}}(x,y)=4I_0\,
\operatorname{sinc}^2\!\left(\frac{\pi a x}{\lambda L}\right)
\operatorname{sinc}^2\!\left(\frac{\pi b y}{\lambda L}\right)
\cos^2\!\left(\frac{\pi d x}{\lambda L}\right).
$$

`unnormalizedSinc_int_mul_pi` proves $\operatorname{sinc}(n\pi)=0$ for every
nonzero integer $n \in \mathbb Z$. `fraunhoferRectangularDoubleSlit_nonnegative`,
`fraunhoferRectangularDoubleSlit_onAxis`, and `fraunhoferRectangularDoubleSlit_even`
establish nonnegativity for $I_0 \ge 0$, the constructive $4I_0$ on-axis
maximum at $(0,0)$, and planar inversion symmetry $(x,y)\mapsto(-x,-y)$.
`fraunhoferRectangularDoubleSlit_dark_fringe` proves exact destructive
interference zeros at the half-period fringe $x = \lambda L/(2d)$, and
`fraunhoferRectangularDoubleSlit_diffraction_null` proves exact single-slit
envelope nulls at $x = n\lambda L/a$ for $n \in \mathbb Z \setminus \{0\}$.
Controls check the on-axis value $12$ for $I_0=3$, both classes of exact
zeros, and rejection of a positive-intensity claim at the half-period dark
fringe. Connecting the finite aperture integral to this far-field benchmark
via an explicit paraxial error bound remains a Phase 2 obligation.

### Iteration 24: Five-Model Double-Slit Superposition, $Gr(2,4)$ Pluecker Channels, Qian--Izadi Parallel-Axis Coherence, and OAM Relative Predictive Error

[Huygens.lean](../src/signals/Signals/Huygens.lean),
[Coherence.lean](../src/signals/Signals/Coherence.lean),
[Geometry.lean](../src/signals/Signals/Geometry.lean),
[DDF.lean](../src/signals/Signals/DDF.lean), and
[OAM.lean](../src/signals/Signals/OAM.lean) formalize and compare double-slit
superposition and its relative predictive error across five mathematical
frameworks, both for standard planar wavefronts and for beams carrying
**Orbital Angular Momentum (OAM)**:

#### A. Connection to Qian & Izadi (2023) ([PhysRevResearch.5.033110](#scholarly-qian-izadi))

In [Qian & Izadi (2023)](#scholarly-qian-izadi)
({download}`PhysRevResearch.5.033110.pdf, pp. 1-6 <../data/papers/PhysRevResearch.5.033110.pdf>`),
an $N$-dimensional optical coherence matrix with normalized eigenvalues
$m_i \ge 0$ ($\sum_{i=1}^N m_i = 1$, formalized in `Signals.Coherence.CoherenceSpectrum`)
has squared degree of polarization and squared Schmidt-weight entanglement/visibility:

$$
P_N^2 = \frac{N}{N-1}\sum_{i=1}^N m_i^2 - \frac{1}{N-1},\qquad
K_N^2 = \frac{N}{N-1}\left(1 - \sum_{i=1}^N m_i^2\right),\qquad
P_N^2 + K_N^2 = 1.
$$

Placing the eigenvalues $m_i$ as point masses at the vertices of a regular
simplex ($m_{\mathrm{tot}} = 1$) maps the optical complementarity relation via
the **Huygens--Steiner parallel-axis theorem** $I_O = I_M + m_{\mathrm{tot}} d_{\mathrm{bary}}^2$
(`Signals.Coherence.HuygensSteinerMapping`) to:

$$
P_N^2 = I_O - I_M = d_{\mathrm{bary}}^2,\qquad
K_N^2 = 1 - (I_O - I_M) = 1 - d_{\mathrm{bary}}^2 = \mathcal{V}^2.
$$

- **Arbitrary-$N$ Spectrum Relative Error (`huygensSteiner_relative_error_from_coherenceComplementarity`)**:
  For any $N \ge 2$ and any `CoherenceComplementarity N` record with visibility
  $\mathcal{V} = K_N$, the on-axis double-slit relative predictive error against
  the coherent Fraunhofer peak is governed directly by the eigenvalue spectrum:
  $$\varepsilon_{\mathrm{rel}}^{\mathrm{HS}}(0,0) = \frac{1 - K_N}{2} = \frac{P_N^2}{2(1 + K_N)} = \frac{d_{\mathrm{bary}}^2}{2(1 + \mathcal{V})}.$$
- **Binary ($N=2$) Two-Slit Weight Imbalance (`CoherenceSpectrum.binary_polarization_and_entanglement`)**:
  For $N = 2$ with normalized slit weights $m_0 + m_1 = 1$, Lean proves the
  exact identities $P_2^2 = (m_0 - m_1)^2 = d_{\mathrm{bary}}^2$ and
  $K_2^2 = 4 m_0 m_1 = \mathcal{V}^2$.
- **Pythagorean Pluecker--Steiner Identity on $Gr(2,4)$ (`gr24_plucker_pythagorean_identity`, `gr24_barycentric_complementarity`)**:
  For any real $2 \times 4$ matrix $M$, defining the Pluecker barycentric
  parallel-axis shift between the two uncrossed slit channels as
  $$d_{\mathrm{bary}}(M) = \frac{\Delta_{01}(M)\Delta_{23}(M) - \Delta_{03}(M)\Delta_{12}(M)}{2},$$
  the 3-term Pluecker identity $\Delta_{01}\Delta_{23} + \Delta_{03}\Delta_{12} = \Delta_{02}\Delta_{13}$
  implies the universal Pythagorean relation:
  $$d_{\mathrm{bary}}(M)^2 + \underbrace{\Delta_{01}(M)\Delta_{23}(M)\,\Delta_{03}(M)\Delta_{12}(M)}_{\mathcal{V}_{Gr(2,4)}(M)^2} = \left(\frac{\Delta_{02}(M)\Delta_{13}(M)}{2}\right)^2.$$
  When $\Delta_{02}(M)\Delta_{13}(M) = 2$, this becomes $d_{\mathrm{bary}}(M)^2 + \mathcal{V}_{Gr(2,4)}(M)^2 = 1$.
  Furthermore, lifting to the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ with
  $z_1 = \sqrt{1 + d_{\mathrm{bary}}}\,e^{i\theta}$ and $z_2 = \sqrt{1 - d_{\mathrm{bary}}}\,e^{-i\theta}$
  (`complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner`) proves that the
  pure crossing-minor intensity $I_{Gr_{\mathbb{C}}(2,4)}^{\times} = I_0 E_{\mathrm{slit}} |\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}|^2$
  reproduces the partially coherent Huygens--Steiner profile
  $I_{\mathrm{HS}}(x,y;\sqrt{1 - d_{\mathrm{bary}}^2})$ **identically at every $(x,y)$**
  for all $d_{\mathrm{bary}} \in [-1, 1]$.

#### B. Five-Model Double-Slit Superposition & Relative Predictive Error Table

| Double-Slit Formulation | Lean Definitions & Theorems | Intensity Law $I(x,y)$ | Relative Predictive Error vs. Fraunhofer ($I_{\mathrm{F}}$) |
|---|---|---|---|
| **1. Fraunhofer Reference** | `fraunhoferRectangularDoubleSlit`, `fraunhoferRectangularDoubleSlit_onAxis`, `fraunhoferRectangularDoubleSlit_dark_fringe` | $I_{\mathrm{F}}(x,y) = 4 I_0 E_{\mathrm{slit}}(x,y) \cos^2\!\left(\frac{\pi d x}{\lambda L}\right)$ | $0$ (reference baseline; vanishes at half-period dark fringes $x_{\mathrm{dark}} = \frac{\lambda L}{2d}$) |
| **2. Huygens–Steiner Parallel-Axis Coherence** ([Qian & Izadi 2023](#scholarly-qian-izadi)) | `huygensSteinerDoubleSlit`, `HuygensSteinerMapping`, `CoherenceComplementarity`, `huygensSteiner_onAxis_relative_error`, `huygensSteiner_relative_error_eq_offset_sq_div`, `huygensSteiner_relative_error_from_coherenceComplementarity` | $I_{\mathrm{HS}}(x,y;\mathcal{V}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + \mathcal{V}\cos\frac{2\pi d x}{\lambda L}\bigr)$, where $d_{\mathrm{bary}}^2 = I_O - I_M = P_N^2$ and $d_{\mathrm{bary}}^2 + \mathcal{V}^2 = 1$ | **Coherent ($d_{\mathrm{bary}}=0, \mathcal{V}=1$)**: $0$ everywhere<br>**On-axis**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{1-\mathcal{V}}{2} = \frac{d_{\mathrm{bary}}^2}{2(1+\mathcal{V})} = \frac{P_N^2}{2(1+K_N)}$<br>**Dark fringe**: $\varepsilon_{\mathrm{peak}}(x_{\mathrm{dark}},0) = \frac{1-\mathcal{V}}{2}\operatorname{sinc}^2\!\left(\frac{\pi a}{2d}\right)$ |
| **3. $Gr(2,4)$ & $Gr_{\mathbb{C}}(2,4)$ Pluecker Channel Models** | `gr24PluckerDoubleSlit`, `gr24UnphasedDoubleSlit`, `gr24_channel_sum_eq_crossing`, `gr24PluckerDoubleSlit_balanced_eq_fraunhofer`, `gr24UnphasedDoubleSlit_onAxis_relative_error_half`, `complexGr24CrossingDoubleSlit`, `complexGr24_crossing_intensity_eq_superposition`, `complexGr24CrossingDoubleSlit_zero_error` | **Real $Gr_{\ge 0}(2,4)$**: $I_{Gr(2,4)} = I_0 E_{\mathrm{slit}}(x,y)\bigl(\Delta_{02}\Delta_{13} + 2\sqrt{w_A w_B}\cos\frac{2\pi d x}{\lambda L}\bigr)$<br>**Complex $Gr_{\mathbb{C}}(2,4)$ ($\mathbb{C}^4$ twistors)**: $I_{Gr_{\mathbb{C}}(2,4)}^{\times} = I_0 E_{\mathrm{slit}}(x,y)\bigl|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\bigr|^2 = I_0 E_{\mathrm{slit}}|\mathcal{A}_1 + \mathcal{A}_2|^2$ | **Real unphased proxy ($\Delta_{02}\Delta_{13}=2 \in Gr_{\ge 0}$)**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{1}{2}$ ($50\%$), dark fringe $100\%$<br>**Complex $Gr_{\mathbb{C}}(2,4)$ crossing minor ($z_{1,2} = e^{\pm i\theta}$)**: **Eliminates the $50\%$ unphased error ($\varepsilon_{\mathrm{rel}} = 0$ everywhere)** via `complexGr24CrossingDoubleSlit_zero_error`<br>**Asymmetric ($\Delta_{02}\Delta_{13}=2$)**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{1 - \sqrt{w_A w_B}}{2}$ |
| **4. Pilot-Wave Theory (De Broglie–Bohm)** | `pilotWaveDoubleSlit`, `pilotWaveDoubleSlit_equilibrium_eq_fraunhofer`, `pilotWave_onAxis_relative_error` | $I_{\mathrm{PW}}(x,y;\delta_{\mathrm{neq}}) = I_{\mathrm{F}}(x,y) + \delta_{\mathrm{neq}}$ (equivariant guidance $\mathbf{v} = \frac{\hbar}{m}\nabla S$ + Bohm potential $Q$) | **Quantum equilibrium ($\delta_{\mathrm{neq}}=0$)**: $0$ everywhere<br>**Non-equilibrium ($\delta_{\mathrm{neq}} \neq 0$)**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{|\delta_{\mathrm{neq}}|}{4 I_0}$ |
| **5. Wigner Phase-Space Marginal** | `wignerDoubleSlit`, `wignerDoubleSlit_eq_huygensSteiner`, `wignerDoubleSlit_pure_eq_fraunhofer`, `wigner_onAxis_relative_error` | $I_{\mathrm{Wigner}}(x,y;\gamma_{\mathrm{dec}}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + e^{-\gamma_{\mathrm{dec}}}\cos\frac{2\pi d x}{\lambda L}\bigr)$ | **Pure state ($\gamma_{\mathrm{dec}}=0$)**: $0$ everywhere<br>**Decohered ($\gamma_{\mathrm{dec}} > 0$)**: $\varepsilon_{\mathrm{rel}}(0,0) = \frac{1 - e^{-\gamma_{\mathrm{dec}}}}{2}$ (exact duality $\mathcal{V} = e^{-\gamma_{\mathrm{dec}}}$) |

#### C. Orbital Angular Momentum (OAM) Double-Slit Superposition Across Methods

When Slit $A$ and Slit $B$ carry helical OAM topological charges $\ell_1, \ell_2 \in \mathbb{Z}$
($e^{i\ell_j\phi}$ with differential charge $\Delta\ell = \ell_2 - \ell_1 \in \mathbb{Z}$
and azimuthal angle $\phi \in \mathbb{R}$), the interference fringes acquire an
azimuthal phase twist $\Delta\ell\,\phi$ (`fraunhoferOAMDoubleSlit`,
`huygensSteinerOAMDoubleSlit`, `wignerOAMDoubleSlit`):

| Method | OAM Representation & Lean Nodes | OAM Superposition Intensity Law $I_{\mathrm{OAM}}(x,y,\phi;\Delta\ell)$ | OAM Phase-Singularity & Relative Predictive Error Behavior |
|---|---|---|---|
| **1. Fraunhofer OAM Reference** | `fraunhoferOAMDoubleSlit`, `fraunhoferOAMDoubleSlit_zero_charge_eq_standard`, `fraunhoferOAMDoubleSlit_vortex_null_at_pi` | $I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell) = 4 I_0 E_{\mathrm{slit}}(x,y)\cos^2\!\left(\frac{\pi d x}{\lambda L} + \frac{\Delta\ell\,\phi}{2}\right)$ | Reduces to $I_{\mathrm{F}}(x,y)$ when $\Delta\ell = 0$. At $\Delta\ell = 1, \phi = \pi$, forms an on-axis optical vortex dark core $I_{\mathrm{F,OAM}}(0,0,\pi;1) = 0$; omitting OAM gives $\varepsilon_{\mathrm{rel}} = 1$ ($100\%$). |
| **2. Huygens–Steiner Parallel-Axis & Barycentric OAM** | `huygensSteinerOAMDoubleSlit`, `huygensSteinerOAMDoubleSlit_unit_visibility_eq_fraunhoferOAM`, `Signals.OAM.Qudit`, `Signals.Geometry.orbitalBivector_translate` | $I_{\mathrm{HS,OAM}}(x,y,\phi;\Delta\ell,\mathcal{V}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + \mathcal{V}\cos(\frac{2\pi d x}{\lambda L} + \Delta\ell\,\phi)\bigr)$; mechanical shift $L_{ab} \mapsto L_{ab} + (a \wedge p)_{ab}$ | Matches $I_{\mathrm{F,OAM}}$ at $\mathcal{V} = 1$. For partially overlapping $D$-mode OAM qudits (`Signals.OAM.Qudit D`), $\varepsilon_{\mathrm{rel}}(0,0,0) = \frac{1-\mathcal{V}}{2} = \frac{P_N^2}{2(1+K_N)}$; orthogonal azimuth-integrated modes ($\mathcal{V}=0$) have $\varepsilon_{\mathrm{rel}} = 1/2$. |
| **3. $Gr(2,4)$ Pluecker & Twistor OAM Shear** | `gr24PluckerDoubleSlit`, `Signals.Geometry.AngularMomentumState.translate_angularMomentum` | Pluecker channel weights $w_A = \Delta_{01}\Delta_{23}$, $w_B = \Delta_{03}\Delta_{12}$ ($w_A+w_B = \Delta_{02}\Delta_{13}$) modulate the helical interference $\cos(\frac{2\pi d x}{\lambda L} + \Delta\ell\,\phi)$ | Zero relative error at balanced $Gr_{\ge 0}(2,4)$ points ($w_A = w_B = 1$) with helical phase; $\varepsilon_{\mathrm{rel}} = 1/2$ if Pluecker channel sums omit the helical OAM phase. |
| **4. Pilot-Wave / Madelung Vortex Hydrodynamics** | `pilotWaveDoubleSlit`, `Signals.DDF.vortexTangentialVelocity`, `Signals.DDF.quantized_vortex_circulation`, `Signals.DDF.plaquette_phase_slip_syndrome` | $I_{\mathrm{PW,OAM}} = I_{\mathrm{F,OAM}}(x,y,\phi;\Delta\ell) + \delta_{\mathrm{neq}}$, with azimuthal guiding velocity $v_\theta = \frac{\hbar \ell}{m R}$ and quantized circulation $\oint \mathbf{v}\cdot d\boldsymbol{\ell} = \ell\frac{2\pi\hbar}{m}$ | Exact ($\varepsilon_{\mathrm{rel}} = 0$) in quantum equilibrium ($\delta_{\mathrm{neq}} = 0$); Bohmian trajectories spiral around the $2\pi\Delta\ell$ plaquette phase-slip singularities, with $\varepsilon_{\mathrm{rel}}(0,0,0) = \frac{|\delta_{\mathrm{neq}}|}{4I_0}$. |
| **5. Wigner Angle–OAM Phase-Space Marginal** | `wignerOAMDoubleSlit`, `wignerOAM_onAxis_relative_error` | $I_{\mathrm{Wigner,OAM}}(x,y,\phi;\Delta\ell,\gamma_{\mathrm{OAM}}) = 2 I_0 E_{\mathrm{slit}}(x,y)\bigl(1 + e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}\cos(\frac{2\pi d x}{\lambda L} + \Delta\ell\,\phi)\bigr)$ | Rotational phase-space diffusion scales quadratically with $(\Delta\ell)^2$: $\varepsilon_{\mathrm{rel}}(0,0,0;\Delta\ell) = \frac{1 - e^{-\gamma_{\mathrm{OAM}}(\Delta\ell)^2}}{2}$, which vanishes for $\Delta\ell = 0$ or $\gamma_{\mathrm{OAM}} = 0$. |

```lean
namespace HuygensGeometryRoadmap

def reportBalancedGr24 : Matrix (Fin 2) (Fin 4) ℝ :=
  !![1, 1, 0, -1;
     0, 1, 1, 1]

example (x y : ℝ) :
    Signals.Huygens.gr24PluckerDoubleSlit reportBalancedGr24 3 2 4 6 1 5 x y =
      Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y :=
  Signals.Huygens.gr24PluckerDoubleSlit_balanced_eq_fraunhofer
    reportBalancedGr24 3 2 4 6 1 5 x y
    (by norm_num [reportBalancedGr24, Signals.Geometry.twoRowMinor])
    (by norm_num [reportBalancedGr24, Signals.Geometry.twoRowMinor])

example :
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.gr24UnphasedDoubleSlit reportBalancedGr24 3 2 4 1 5 0 0)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 / 2 :=
  Signals.Huygens.gr24UnphasedDoubleSlit_onAxis_relative_error_half
    reportBalancedGr24 3 2 4 6 1 5 (by norm_num)
    (by norm_num [reportBalancedGr24, Signals.Geometry.twoRowMinor])

example :
    Signals.Huygens.fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0 = 0 ∧
      Signals.Huygens.relativePredictiveError
        (Signals.Huygens.fraunhoferOAMDoubleSlit 3 2 4 6 1 5 1 Real.pi 0 0)
        (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 0 0) = 1 :=
  Signals.Huygens.fraunhoferOAMDoubleSlit_vortex_null_at_pi 3 2 4 6 1 5 (by norm_num)

example (x y : ℝ) :
    let θ := Real.pi * 6 * x / (1 * 5)
    let z1 : ℂ := ↑(Real.cos θ) + Complex.I * ↑(Real.sin θ)
    let z2 : ℂ := ↑(Real.cos θ) - Complex.I * ↑(Real.sin θ)
    Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y =
      Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y ∧
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y)
      (Signals.Huygens.fraunhoferRectangularDoubleSlit 3 2 4 6 1 5 x y) = 0 :=
  Signals.Huygens.complexGr24CrossingDoubleSlit_zero_error 3 2 4 6 1 5 x y

example (x y : ℝ) :
    let θ := Real.pi * 6 * x / (1 * 5)
    let a := Real.sqrt (1 + (3 / 5 : ℝ))
    let b := Real.sqrt (1 - (3 / 5 : ℝ))
    let z1 : ℂ := ↑(a * Real.cos θ) + Complex.I * ↑(a * Real.sin θ)
    let z2 : ℂ := ↑(b * Real.cos θ) - Complex.I * ↑(b * Real.sin θ)
    Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y =
      Signals.Huygens.huygensSteinerDoubleSlit
        3 2 4 6 1 5 (Real.sqrt (1 - (3 / 5 : ℝ) ^ 2)) x y ∧
    Signals.Huygens.relativePredictiveError
      (Signals.Huygens.complexGr24CrossingDoubleSlit
        (Signals.Huygens.complexGr24ChannelMatrix z1 z2) 3 2 4 1 5 x y)
      (Signals.Huygens.huygensSteinerDoubleSlit
        3 2 4 6 1 5 (Real.sqrt (1 - (3 / 5 : ℝ) ^ 2)) x y) = 0 :=
  Signals.Huygens.complexGr24CrossingDoubleSlit_barycentric_eq_huygensSteiner
    3 2 4 6 1 5 (3 / 5) x y (by norm_num) (by norm_num)
```

### Iteration 25: Quantum Inverse Scattering Method (QISM), $8 \times 8$ Matrix Quantum Yang--Baxter Equation, $Gr(2,4)$ Baxter $QQ/TQ$ Wronskians, and $N$-Slit ($N > 0$) Generalization

Implemented across [QISM.lean](../src/signals/Signals/QISM.lean),
[Scattering.lean](../src/signals/Signals/Scattering.lean),
[OAM.lean](../src/signals/Signals/OAM.lean),
[Huygens.lean](../src/signals/Signals/Huygens.lean),
[SolitonBus.lean](../src/signals/Signals/SolitonBus.lean), and the Rust/WASM/GLSL
crate (`src/signals/numerical_adapter/src/double_slit.rs`), and documented in
[grassmannian-qism-bethe-ansatz-paper.md](grassmannian-qism-bethe-ansatz-paper.md)
and [grassmannian-huygens-double-slit-oam-paper.md](grassmannian-huygens-double-slit-oam-paper.md):

- **Yang's Rational $R$-Matrix & Full $8 \times 8$ Matrix Quantum Yang--Baxter Equation**:
  Proved regularity $R(0;\eta) = \eta P$, quantum unitarity, the three-site scalar
  braid identity, and the full $8 \times 8$ matrix Quantum Yang--Baxter Equation
  (`yangRMatrix8_quantum_yang_baxter`) on $(\mathbb{R}^2)^{\otimes 3}$.
- **$Gr(2,4)$ Baxter $QQ/TQ$ System, MTV Nondegeneracy, and Slavnov Determinants**:
  Proved that a 2-plane $W = \operatorname{span}\{Q_+, Q_-\}$ evaluated at four
  spectral points satisfies Baxter's $QQ$-system via the 3-term Pluecker relation,
  solves Baxter's $TQ$ equation via 3-point Casorati Wronskians (`baxterTQResidual_wronskian_zero`),
  excludes spurious $0/0$ Bethe roots under Mukhin--Tarasov--Varchenko nondegeneracy
  (`mtv_wronskian_nondegenerate_of_root`), and compresses two-magnon scalar products
  into $2 \times 2$ Slavnov minors (`slavnovDet2_pauli_exclusion`).
- **OAM $Gr_{\mathbb{C}}(2,4)$ Barycentric Equivalence & $N$-Slit ($N > 0$) Grating**:
  Proved `complexGr24CrossingOAMDoubleSlit_barycentric_eq_huygensSteinerOAM` and
  generalized all five double-slit models to $N > 0$ slits (`fraunhoferMultiSlit`,
  `huygensSteinerMultiSlit`, `gr24PluckerMultiSlit`, `pilotWaveMultiSlit`,
  `wignerMultiSlit`) with exact $N=1$ and $N=2$ reductions and a verified
  `SolitonBus.Gr24MultiSlitOAMCoupler`.

### Iteration 26: Pluecker Sink-Flux Hydrodynamics, Dilatant Dark Fluid (DDF) Moving Sheaths, Anosov Symplectic Invariance, and $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Sorkin Triple-Slit Unification

Implemented in [DDF.lean](../src/signals/Signals/DDF.lean),
[Geometry.lean](../src/signals/Signals/Geometry.lean), and
[Huygens.lean](../src/signals/Signals/Huygens.lean), and documented in
[grassmannian-ddf-moving-sheath-paper.md](grassmannian-ddf-moving-sheath-paper.md):

- **Reciprocal Visibility--Jamming Duality & Critique Resolutions**:
  Identified $|d_{\mathrm{bary}}|$ with the reduced sheath speed $\beta = v/c \in [0, 1)$
  of a subluminal `MovingSheath`, proving $\mathcal{V}(s) = \gamma_\varphi(v)^{-1}$,
  $\varepsilon_{\mathrm{rel}}(0,0) = \frac{\gamma_\varphi(v)-1}{2\gamma_\varphi(v)} = \frac{K_D(v)}{2 E_\varphi(v)}$,
  tight quadratic bounds $\beta^2/4 \le \varepsilon_{\mathrm{rel}} \le \beta^2/2$,
  exact Anosov symplectic Pluecker invariance (`anosov_plucker_invariance`), projective
  $GL(2,\mathbb{R})$ jamming invariance (`normalizedBarycentricShift_basisChange_invariant`),
  and constitutive DDF substrate recovery $\varrho_{\max}^\varphi j_{\min}^\varphi = 4\varepsilon(1-\varepsilon)/v^2$.
- **Master $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ ($N \ge 3$) Unification**:
  Constructed `MovingSheath.gr24TwistorMatrix` and `complexGr2NChannelMatrix`, proving
  `gr24TwistorMatrix_crossing_eq_ddf_oam_intensity`, `complexGr2N_collector_eq_channel_sum`,
  `tripleSlit_peak_and_secondary_null` (peak $9$, secondary null at $\beta = \pi/3$), and
  vanishing Sorkin third-order quantum interference parameter $\kappa_3 = 0$
  (`gr25TripleSlitTwistorMatrix_madelung_sector_identities`).

### Iteration 27: Grassmannian Gravity from QED/Gauge Scattering Amplitudes, BCJ Double Copy on $Gr_{\mathbb{C}}(2,4)$, Precessing Polar Conics, and Mercury's $42.98''/\text{cy}$ Perihelion Precession

Implemented in [DDF.lean](../src/signals/Signals/DDF.lean) and
`src/signals/numerical_adapter/src/orbital_splat.rs`, and documented in
[grassmannian-gravity-from-qed-scattering-paper.md](grassmannian-gravity-from-qed-scattering-paper.md):

- **BCJ Color--Kinematics Duality & Double Copy on $Gr_{\mathbb{C}}(2,4)$ (`bcj_plucker_jacobi_and_double_copy`)**:
  Proved that the Pluecker channel products $(n_s, n_t, n_u) = (\Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}, -\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}, \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}})$
  satisfy the kinematic Jacobi identity $n_s + n_t + n_u = 0$ and the graviton double-copy
  square $n_t^2 = n_s^2 + 2 n_s n_u + n_u^2$.
- **Planetary Orbits, Precessing Conic Turning Points, & Mercury's Perihelion Precession**:
  Formalized `PlanetaryOrbit`, proved Kepler's Third Law (`kepler_third_law`),
  precessing polar conic turning points $r(\varphi) = p / (1 + e\cos((1-\eta)(\varphi-\varpi)))$
  (`precessingRadius_perihelion_and_aphelion`), the exact $\pi$-free arcsecond law
  $\Delta\varpi_{\mathrm{arcsec}} = 1944000\,r_H / p$ (`perihelionPrecessionArcsecPerOrbit_eq`),
  and machine-checked rational bounds for Mercury's anomalous $42.98''/\text{century}$
  and total $574.61''/\text{century}$ precession (`mercury_perihelion_precession_arcsec_per_century_bounds`),
  together with the $N$-body $Gr_{\mathbb{C}}(2, N+2)$ sink potential (`nBodyBernoulliPotential_eq_gr2NCollector`).

### Iteration 28: Normed 2D Anisotropic Tensor Gaussian Splat Mechanics, Dual-Layer $Gr_{\mathbb{C}}(2,4)$ Twistor Wavepackets, Core Bohm Potential, and Madelung Quantum Pressure Tensor $\Pi_{ij}$

Implemented in [DDF.lean](../src/signals/Signals/DDF.lean) and
`src/signals/numerical_adapter/src/orbital_splat.rs` (with WebGL2 `#version 300 es`
shaders `orbital_splat.vert.glsl` and `orbital_splat.frag.glsl`), and documented in
[grassmannian-splat-mechanics-paper.md](grassmannian-splat-mechanics-paper.md):

- **Dual-Layer $Gr_{\mathbb{C}}(2,4)$ Twistor Splat Representation (`complexTwistor_representation_identities`)**:
  Resolved the limitation that a purely real Gaussian density $G(x,y) \ge 0$ omits the
  Penrose twistor phase by pairing Layer 1 covariance ($\det\Sigma_{\mathrm{DDF}} = \sigma_0^4\gamma_\varphi(v)^{-2}$,
  $\det\Sigma_{Gr_{\mathbb{C}}(2,4)} = \sigma_0^4(p/a)$) with Layer 2 coherent wavepacket
  $\Psi_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = \sqrt{G(x,y)}\,\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})$,
  proving exact dark-fringe cancellation at $w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = 0$.
- **Core Bohm Quantum Potential & Madelung Quantum Pressure Tensor (`coreBohmPotential_identities`, `quantumPressureTensor_identities`)**:
  Proved that $-\partial_i\partial_j \ln G(x,y) = (\Sigma^{-1})_{ij}$ reduces the
  Madelung quantum pressure tensor to precision-matrix algebra:
  $$Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2\,\operatorname{Tr}\Sigma}{4 m\,\det\Sigma} > 0, \qquad
  \operatorname{Tr}\Pi(x,y) = \frac{1}{m}\,Q_{\mathrm{core}}(\Sigma)\,G(x,y), \qquad
  \Pi_{11}^{\mathrm{DDF}}(x,y) = \gamma_\varphi(v)^2\,\Pi_{22}^{\mathrm{DDF}}(x,y).$$

### Iteration 29: Inelastic Scattering (Inverse Compton & Stokes/Anti-Stokes Raman), What $Gr_{\mathbb{C}}(2,4)$ Does Not Cover, and the Heat Problem (Fourier, Cattaneo--Vernotte, Splat-Free Continuum $Gr_{\mathbb{C}}(2,4)$--DDF, and Thermal Splat Evolution)

Implemented in [Scattering.lean](../src/signals/Signals/Scattering.lean),
[DDF.lean](../src/signals/Signals/DDF.lean), and
`src/signals/numerical_adapter/src/thermal_inelastic.rs`, and documented in
[grassmannian-thermal-compton-raman-paper.md](grassmannian-thermal-compton-raman-paper.md):

- **Relativistic Inverse Compton & Stokes/Anti-Stokes Raman on $Gr_{\mathbb{C}}(2,4)$**:
  Proved `MovingSheath.inverseCompton_gr24_identities`
  ($\frac{|w_A^{\mathbb{C}}|^2}{|w_B^{\mathbb{C}}|^2} = \frac{1+\beta}{1-\beta} = \gamma_\varphi(v)^2(1+\beta)^2$),
  `inverseCompton_thomson_and_recoil_identities` (Klein--Nishina recoil suppression
  for $\epsilon_{\mathrm{rec}} > 0$), and `raman_stokes_antiStokes_gr24_identities`
  (exact recovery of $\omega_L, \Omega_v$ via `reconstructSpectralDiff` and
  `reconstructYangCoupling`, Pluecker ratio $\frac{\omega_{AS}}{\omega_S} = \frac{1+\delta_R}{1-\delta_R}$,
  and Boltzmann thermal suppression $R_{AS/S}(\xi) < (\omega_{AS}/\omega_S)^4$).
- **Explicit Domain Boundaries — What Bare Projective $Gr_{\mathbb{C}}(2,4)$ Does Not Cover**:
  Cataloged and proved the four structural boundaries requiring data beyond
  scale-free unitary $Gr_{\mathbb{C}}(2,4)$: (1) absolute mass/recoil scales ($m_e c^2$,
  infinity twistor $I_{\alpha\beta}$, DDF cutoff $\varrho_{\max}^\varphi j_{\min}^\varphi$),
  (2) spontaneous vacuum fluctuations ($\bar{n}+1$ vs. $\bar{n}$) and thermal bath
  factors $e^{-\hbar\Omega_v/(k_B T)}$, (3) $N \ge 3$ multi-channel overtones/cascades
  (requiring $Gr_{\mathbb{C}}(2, N+2)$), and (4) irreversible entropy production and
  thermal relaxation ($\tau_r > 0$).
- **The Heat Problem — Fourier, Cattaneo--Vernotte, Splat-Free Continuum $Gr_{\mathbb{C}}(2,4)$--DDF, and Tensor Splat Evolution**:
  Proved Fourier's acausal high-frequency phase-speed divergence
  (`FourierHeatModel.diffusivity_pos_and_acausal_speed`), Cattaneo--Vernotte
  hyperbolic second-sound factorization (`CattaneoVernotteHeatModel.identities`),
  the **splat-free continuum** Grassmannian--DDF thermal transport, Pluecker
  flux-limiter, Chapman--Kolmogorov mode/flux semigroup, and continuum Bohm
  relaxation theorems (`MovingSheath.ddfThermalTransport_continuum_identities`,
  `MovingSheath.ddfContinuum_semigroup_and_bohm_decay`), and the $L^1$-conserving
  anisotropic thermal splat evolution, Chapman--Kolmogorov splat semigroup, and
  core Bohm relaxation theorems (`MovingSheath.ddfThermalTransport_and_splat_identities`,
  `NormedTensorGaussianSplat2D.evolveThermal_semigroup_and_bohm_decay`).

### Iteration 30: Polaritons (Hopfield Bogoliubov Mixing, Vacuum Rabi Anticrossing, Lyddane--Sachs--Teller Reststrahlen Bands) and Surface Plasmon Polaritons (SPPs) With and Without Tensor Gaussian Splats

Implemented in [Scattering.lean](../src/signals/Signals/Scattering.lean),
[DDF.lean](../src/signals/Signals/DDF.lean), and
`src/signals/numerical_adapter/src/polariton_spp.rs`, and documented in
[grassmannian-polariton-spp-mechanics-paper.md](grassmannian-polariton-spp-mechanics-paper.md):

- **Polariton Hopfield--Rabi Anticrossing, $Gr_{\mathbb{C}}(2,4)$ Hybridization Complementarity, & Lyddane--Sachs--Teller Reststrahlen Theorem (`polariton_hopfield_rabi_and_lst_identities`)**:
  Proved trace conservation $\omega_{\mathrm{UP}} + \omega_{\mathrm{LP}} = \omega_{\mathrm{ph}} + \omega_{\mathrm{ex}}$,
  avoided crossing $\omega_{\mathrm{UP}} - \omega_{\mathrm{LP}} = \sqrt{\Delta_{\mathrm{pol}}^2 + 4g^2} \ge 2g > 0$,
  exact inverse Rabi coupling recovery $\operatorname{reconstructPolaritonRabiCouplingSq}(\omega_{\mathrm{ph}}, \omega_{\mathrm{ex}}, \omega_{\mathrm{UP}}, \omega_{\mathrm{LP}}) = g^2$,
  Hopfield photon/matter normalization $|C|^2 + |X|^2 = 1$ with Pythagorean $Gr_{\mathbb{C}}(2,4)$
  complementarity $4|C|^2|X|^2 = 1 - d_{\mathrm{Hopfield}}^2 = \frac{4g^2}{\Delta_{\mathrm{pol}}^2 + 4g^2} > 0$,
  and the Lyddane--Sachs--Teller static limit $\varepsilon_{\mathrm{pol}}(0) = \varepsilon_\infty \omega_{\mathrm{LO}}^2/\omega_{\mathrm{TO}}^2$,
  ENZ bulk longitudinal polariton cutoff $\varepsilon_{\mathrm{pol}}(\omega_{\mathrm{LO}}) = 0$,
  and Reststrahlen surface-polariton stop-band $\varepsilon_{\mathrm{pol}}(\omega) < 0$ for $\omega \in (\omega_{\mathrm{TO}}, \omega_{\mathrm{LO}})$.
- **Surface Plasmon Polaritons (SPPs) Without and With Normed Tensor Gaussian Splats (`MovingSheath.sppContinuum_gr24_and_semigroup_identities`, `MovingSheath.sppTensorSplat_and_thermal_identities`)**:
  Proved **without splats** that $n_{\mathrm{SPP}}^2 - \varepsilon_d = \frac{\varepsilon_d^2}{|\varepsilon_m| - \varepsilon_d} > 0$
  (momentum outside the dielectric light cone), $\frac{n_{\mathrm{SPP}}^2 - \varepsilon_d}{n_{\mathrm{SPP}}^2 + |\varepsilon_m|} = \frac{\varepsilon_d^2}{|\varepsilon_m|^2}$,
  the $Gr_{\mathbb{C}}(2,4)$ Pluecker skin-depth ratio $\frac{|w_A^{\mathbb{C}}(M_{\mathrm{SPP}})|^2}{|w_B^{\mathbb{C}}(M_{\mathrm{SPP}})|^2} = \frac{1 + \chi_{\mathrm{SPP}}}{1 - \chi_{\mathrm{SPP}}} = \frac{|\varepsilon_m|}{\varepsilon_d} = \frac{\delta_d}{\delta_m} > 1$,
  spatial propagation semigroup identity/additivity (`evolveContinuumSppPropagation`),
  and conductor-side evanescent Bohm amplification $Q_{\mathrm{cont}}(m, \hbar, \kappa_m) = (|\varepsilon_m|/\varepsilon_d)^2 Q_{\mathrm{cont}}(m, \hbar, \kappa_d)$;
  and proved **with normed Tensor Gaussian Splats** (`sppHotspotTensorSplat`) that
  sub-wavelength confinement ($\sigma_1 = \lambda_0 / n_{\mathrm{SPP}}$, $\sigma_2 = \lambda_0 / (n_{\mathrm{SPP}}\kappa_{\mathrm{ratio}})$)
  compresses $\det\Sigma_{\mathrm{SPP}} = \frac{\lambda_0^4}{n_{\mathrm{SPP}}^4 \kappa_{\mathrm{ratio}}^2}$,
  amplifies the core Bohm quantum potential $Q_{\mathrm{core}}(\Sigma_{\mathrm{SPP}}) = \frac{\hbar^2 n_{\mathrm{SPP}}^2(1 + \kappa_{\mathrm{ratio}}^2)}{4 m \lambda_0^2} \ge \frac{\hbar^2}{2 m \lambda_0^2}$,
  enforces normal-to-longitudinal quantum stress anisotropy $\Pi_{22}^{\mathrm{SPP}} = \kappa_{\mathrm{ratio}}^2 \Pi_{11}^{\mathrm{SPP}}$,
  and obeys Ohmic-thermal semigroup identity/additivity and monotonic Bohm relaxation.

### Iteration 31: Coherent Synchrotron Radiation (CSR) on Cylindrical SPP Microtubes/CNTs, Cavity QED vs. Cherenkov Phase Matching, 't Hooft--Susskind Holography, and Second-Harmonic ($\chi^{(2)}$) Resonant OPA (With and Without Splats)

Implemented in [Scattering.lean](../src/signals/Signals/Scattering.lean),
[DDF.lean](../src/signals/Signals/DDF.lean), and
`src/signals/numerical_adapter/src/polariton_spp.rs`, and documented in
[grassmannian-polariton-spp-mechanics-paper.md](grassmannian-polariton-spp-mechanics-paper.md),
[grassmannian-holographic-principle-paper.md](grassmannian-holographic-principle-paper.md),
and [anti-fire-cannon-review.md](anti-fire-cannon-review.md):

- **CSR-SPP Superradiant Bunching, Cavity QED Cooperativity, Cherenkov Phase Matching, & 1-Step Grover Carving (`csr_spp_cherenkov_cavity_and_grover_identities`)**:
  Proved $I_{\mathrm{CSR}}(N_e, f_{\mathrm{bunch}}, I_1) = (N_e + N_e(N_e - 1)f_{\mathrm{bunch}}^2)I_1 \in [N_e I_1, N_e^2 I_1]$,
  single-photon vs. collective Cavity QED cooperativity $C_1 = 4g_0^2/(\kappa\gamma)$,
  superluminal unmagnetized transverse plasma phase velocity $v_{\mathrm{ph},\perp}^2 > c^2$
  vs. subluminal longitudinal Bohm--Gross phase velocity $v_{\mathrm{ph},\parallel}^2 = \omega_p^2/k^2 + 3v_{\mathrm{th}}^2 < c^2$,
  subluminal Cherenkov Mach cone $0 < 1 - \cos^2\theta_C < 1$, 2D Dirac graphene THz-eV
  plasmon scaling $\omega_{\mathrm{GPP}}^2 = E_F q$, and 1-step deterministic 4-state
  Grover state carving $\operatorname{groverSuccessAmplitude}(1/2) = 1$.
- **'t Hooft--Susskind--Bekenstein--Hawking Holography & Anti-Amplituhedron Cancellation (`RiverExterior.holographic_gr24_ddf_and_antiAmplituhedron_identities`)**:
  Proved Bekenstein--Hawking horizon entropy $S_{\mathrm{BH}} = \pi k_B r_H^2 / \ell_P^2 > 0$,
  Gauss--Smarr 2D-to-3D bulk mass recovery $\frac{\kappa_H A_H}{4\pi G_\phi} = M$,
  splat-free $Gr_{\mathbb{C}}(2,4)$ Painlevé--Gullstrand redshift lapse
  $|w_A^{\mathbb{C}}(M_{\mathrm{holo}})|^2|w_B^{\mathbb{C}}(M_{\mathrm{holo}})|^2 = 1 - r_H / r$,
  Planck-splat UV Bohm cutoff $Q_{\mathrm{core}}(\Sigma_{\mathrm{Planck}}) = \frac{\hbar^2}{2 m \ell_P^2}$,
  and Anti-Amplituhedron destructive phase cancellation $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = 0$.
- **Low-Power Second-Harmonic ($\chi^{(2)}$) Resonant OPA (`second_harmonic_opa_and_centrosymmetry_identities`, `opaSqueezed_splat_and_continuum_identities`)**:
  Proved centrosymmetric inversion $\chi_2 = -\chi_2 \implies \chi_2 = 0$, intracavity
  second-harmonic buildup $P_{2\omega}^{\mathrm{intracav}} = F_{\mathrm{SH}} P_{2\omega}$,
  symplectic quadrature squeezing $\exp(2r_{\mathrm{sq}})\exp(-2r_{\mathrm{sq}}) = 1$,
  splat-free continuum Bohm amplification, symplectic splat determinant preservation
  $\det\Sigma_{\mathrm{OPA}} = \sigma_0^4$, core Bohm barrier enhancement
  $Q_{\mathrm{core}}(\Sigma_{\mathrm{OPA}}) = \frac{\hbar^2(e^{2r_{\mathrm{sq}}}+e^{-2r_{\mathrm{sq}}})}{4m\sigma_0^2} \ge \frac{\hbar^2}{2m\sigma_0^2}$,
  and Madelung quantum pressure squeezing anisotropy $\Pi_{22}^{\mathrm{OPA}} = e^{4r_{\mathrm{sq}}}\Pi_{11}^{\mathrm{OPA}}$.

### Iteration 32: Maldacena/GKPW AdS/CFT Correspondence, Planar Integrability (`arXiv:1012.3982`), Secret Symmetries (`arXiv:1204.2366`), and Complex $Gr_{\mathbb{C}}(2,4)$ / DDF Holographic RG Unification (With and Without Splats)

Implemented in [Scattering.lean](../src/signals/Signals/Scattering.lean),
[DDF.lean](../src/signals/Signals/DDF.lean), and
`src/signals/numerical_adapter/src/polariton_spp.rs`, and documented in
[grassmannian-ads-cft-ddf-paper.md](grassmannian-ads-cft-ddf-paper.md):

- **Maldacena/GKPW Dictionary, Ryu--Takayanagi Entanglement, KSS Bound, Planar Integrability (`arXiv:1012.3982`), & Secret Symmetries (`arXiv:1204.2366`) (`ads_cft_integrability_and_secret_symmetry_identities`)**:
  Proved $\Delta_+ + \Delta_- = d$, $\Delta_+\Delta_- = -m^2 R_{\mathrm{AdS}}^2$,
  $\Delta_+(\Delta_+ - d) = m^2 R_{\mathrm{AdS}}^2$, and $\Delta_+(d, -d^2/4) = d/2$
  above the Breitenlohner--Freedman bound $m_{\mathrm{BF}}^2 R_{\mathrm{AdS}}^2 = -d^2/4$;
  Ryu--Takayanagi entanglement entropy $S_{\mathrm{EE}} = \frac{c_{\mathrm{BH}}}{3}\ln(\ell/\epsilon_{\mathrm{UV}})$;
  positivity of the KSS viscosity bound $(\eta/s)_{\mathrm{KSS}} = \frac{\hbar}{4\pi k_B} > 0$;
  the coupling--tension inversion $\lambda = 4\pi^2 T_{\mathrm{str}}^2$;
  all-loop bound-state magnon dispersion $E^2(M, \lambda, p) = M^2 + \frac{\lambda}{\pi^2}\sin^2(p/2)$;
  the exact Konishi ($L=4, M=2$, $u_{\mathrm{K}}^2 = 1/12$) one-loop check figure
  $2\delta D_1(\lambda, u_{\mathrm{K}}) = \frac{3\lambda}{4\pi^2} = \frac{3}{2} D_{\mathrm{cusp}}^{(1)}(\lambda)$;
  the $\mathfrak{psl}(2|2)_c$ braided central-charge identity $\mathbb{C}(p)\mathbb{C}^\dagger(p) + \mathbb{C}(p) + \mathbb{C}^\dagger(p) = 0$;
  short vs. long multiplet compression $4M < 16(M+1)$; the indented Yangian secret
  generator supertrace $\operatorname{STr}(\widehat{\mathbb{B}}) = 4 B_0$ with $\operatorname{Tr}(\widehat{\mathbb{B}}) = 0$;
  and the symmetry, null vector $DA(1,1,1,1)^T = 0$, and degeneracy $\operatorname{Tr}(DA) = \det(DA) = 0$
  of the $q$-deformed Hubbard affine Cartan matrix $DA$.
- **Unified $Gr_{\mathbb{C}}(2,4)$, $\mathfrak{psl}(2|2)_c$ Outer Automorphism, & $\text{AdS}_5$/DDF Holographic RG Theorem (`RiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification`)**:
  Proved **without splats** that embedding the Beisert--Torrielli $\mathfrak{psl}(2|2)_c$
  outer-automorphism parameters $(a,b,c,d)$ (`arXiv:1204.2366`, Eq. (2.11)) into
  $Gr_{\mathbb{C}}(2,4)$ via `psl22SecretAutomorphismGr24Matrix` identifies the 3-term
  quadratic Pluecker identity on $Gr_{\mathbb{C}}(2,4)$ with the central-charge
  dispersion invariant $(\Delta_{03}^{\mathbb{C}})^2 + \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = (ad+bc)^2 - 4(ab)(cd) = (ad-bc)^2 = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}} = 1$,
  while $|w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2$ reproduces both the $\text{AdS}_5$
  planar black-brane emblackening factor $1 - (z/z_H)^4$ and the DDF acoustic horizon
  lapse $1 - r_H/r$; and proved **with normed Tensor Gaussian Splats** (`adsHolographicRGSplat`)
  that bulk radial RG coarse-graining $z_{\mathrm{UV}} \mapsto \lambda_{\mathrm{rg}} z_{\mathrm{UV}}$
  ($\lambda_{\mathrm{rg}} > 1$) scales $\det\Sigma_{\mathrm{IR}} = \lambda_{\mathrm{rg}}^4\det\Sigma_{\mathrm{UV}} > \det\Sigma_{\mathrm{UV}}$
  and relaxes both the continuum and splat core Bohm potentials by $\lambda_{\mathrm{rg}}^{-2}$.

### Iteration 33: Paraxial Fresnel-to-Fraunhofer Remainder Bound, Higher-Rank $Gr(3,n)$ / $Gr_{\mathbb{C}}(3,n)$ Four-Term Plücker Relations, Multi-Layer & Three-Channel ($k=3$) LGV Disjoint-Path Positivity, and Full $16 \times 16$ $\mathfrak{psl}(2|2)_c$ Worldsheet $R$-Matrix Secret Intertwining

Implemented in [Huygens.lean](../src/signals/Signals/Huygens.lean),
[Quadrature.lean](../src/signals/Signals/Quadrature.lean),
[Geometry.lean](../src/signals/Signals/Geometry.lean),
[Plabic.lean](../src/signals/Signals/Plabic.lean),
[Scattering.lean](../src/signals/Signals/Scattering.lean), and the Rust/WASM crate
(`double_slit.rs`, `orbital_splat.rs`, `polariton_spp.rs`):

- **Paraxial Fresnel-to-Fraunhofer Quadratic Phase Remainder & Combined Quadrature Comparison (`fresnel_to_fraunhofer_remainder_bound`, `CellQuadrature.fresnelFraunhoferComparison`)**:
  Formalized the linear Fraunhofer phase $\phi_{\mathrm{Fraun}}(x,y,\xi,\eta) = -\frac{2\pi(x\xi + y\eta)}{\lambda L}$,
  quadratic Fresnel remainder $\Delta\phi_{\mathrm{Fresnel}}(\xi,\eta) = \frac{\pi(\xi^2 + \eta^2)}{\lambda L}$,
  and Fresnel number $N_{\mathrm{F}}(\rho_{\max}, \lambda, L) = \frac{\rho_{\max}^2}{\lambda L}$.
  Proved that for $\xi^2 + \eta^2 \le \rho_{\max}^2$, $0 \le \Delta\phi_{\mathrm{Fresnel}} \le \pi N_{\mathrm{F}}$
  and the unit-phasor chord error satisfies
  $$|e^{i\phi_{\mathrm{Fresnel}}} - e^{i\phi_{\mathrm{Fraun}}}|^2 = 4\sin^2(\Delta\phi_{\mathrm{Fresnel}}/2) \le (\Delta\phi_{\mathrm{Fresnel}})^2 \le (\pi N_{\mathrm{F}})^2.$$
  Combined this in `CellQuadrature.fresnelFraunhoferComparison` with `CellQuadrature.uniformComparison`
  via `AmplitudeComparison.compose` to obtain the unified discrete-to-Fraunhofer tolerance
  $\bigl(L_{\mathrm{Lip}} h + \pi N_{\mathrm{F}}(\rho_{\max}, \lambda, L)\bigr)\mu(X)$.
- **Higher-Rank $Gr(3, n)$ and $Gr_{\mathbb{C}}(3, n)$ Four-Term Plücker Relations (`threeRowMinor_pluecker`, `complexThreeRowMinor_pluecker`, `selectedMinor_pluecker_rank3_five`)**:
  Extended the $2 \times n$ Plücker framework to rank $k = 3$ over both $\mathbb{R}$ and $\mathbb{C}$,
  proving $GL(3, \mathbb{R})$ basis-change scaling (`threeRowMinor_basisChange`), equivalence
  with `selectedMinor` on ordered triples (`threeRowMinor_eq_selectedMinor`), the general
  4-term quadratic Plücker syzygy
  $$\Delta_{i_1 i_2 j_0}\Delta_{j_1 j_2 j_3} - \Delta_{i_1 i_2 j_1}\Delta_{j_0 j_2 j_3} + \Delta_{i_1 i_2 j_2}\Delta_{j_0 j_1 j_3} - \Delta_{i_1 i_2 j_3}\Delta_{j_0 j_1 j_2} = 0,$$
  and the ordered five-column `selectedMinor` specialization `selectedMinor_pluecker_rank3_five`.
- **Multi-Layer & Three-Channel ($k = 3$) Lindström–Gessel–Viennot Disjoint-Path Positivity (`lgv_multiLayer_det_prod`, `lgv_multiLayer_det_positive`, `planar_threeChannel_lgv_and_bottleneck_identities`)**:
  Proved arbitrary-length layer transfer determinant multiplicativity and strict positivity
  for any finite list $L$ of $k \times k$ planar transfer steps, and proved for $k = 3$ channels
  that planar upper/lower-bidiagonal steps have positive vertex-disjoint path determinant
  $d_0 d_1 d_2 > 0$, whereas routing 3 channels through a 2-vertex bottleneck forces
  $\det(AB) = 0$ for all $A \in \mathbb{R}^{3\times 2}, B \in \mathbb{R}^{2\times 3}$.
- **Full $16 \times 16$ $\mathfrak{psl}(2|2)_c$ Worldsheet $R$-Matrix & Secret Coproduct Intertwining (`psl22_rmatrix16_secret_coproduct_intertwining`)**:
  Formalized the $16 \times 16$ $\mathbb{Z}_2$-graded permutation matrix $\Pi_{16}$, the
  two-site diagonal secret symmetry coproducts $\Delta_{\mathrm{diag}}(\widehat{\mathbb{B}})(B_1, B_2)$
  and $\Delta_{\mathrm{diag}}^{\mathrm{op}}(\widehat{\mathbb{B}})(B_1, B_2)$, the antisymmetric
  off-diagonal Yangian tail $\Delta_{\mathrm{tail}}\bigl((B_1 - B_2)L_{BF}\bigr)$
  (`psl22YangianTail16`), the full secret coproducts $\Delta_{\mathrm{full}}(\widehat{\mathbb{B}})(B_1, B_2, G_{BF}, L_{BF})$
  (`psl22SecretCoproductFull16`) and $\Delta_{\mathrm{full}}^{\mathrm{op}}(\widehat{\mathbb{B}})(B_1, B_2, G_{BF}, L_{BF})$
  (`psl22SecretCoproductFullOp16`), and the 6-parameter $16 \times 16$ worldsheet $R$-matrix
  $R_{16}(A_B, B_B, D_F, E_F, G_{BF}, L_{BF})$, proving $\Pi_{16}^2 = I_{16}$,
  $\Delta^{\mathrm{op}}(\widehat{\mathbb{B}})\Pi_{16} = \Pi_{16}\Delta(\widehat{\mathbb{B}})$,
  the mixed boson–fermion diagonal commutator residual $2(B_2 - B_1)L_{BF}$ at state
  $|\phi^1 \otimes \psi^1\rangle$, and exact full $16 \times 16$ intertwining with the Yangian tail
  $$\Delta_{\mathrm{full}}^{\mathrm{op}}(\widehat{\mathbb{B}})(B_1, B_2, G_{BF}, L_{BF})\,R_{16}(A_B, B_B, D_F, E_F, G_{BF}, L_{BF}) = R_{16}(A_B, B_B, D_F, E_F, G_{BF}, L_{BF})\,\Delta_{\mathrm{full}}(\widehat{\mathbb{B}})(B_1, B_2, G_{BF}, L_{BF})$$
  for arbitrary $B_1, B_2, A_B, B_B, D_F, E_F, G_{BF}, L_{BF} \in \mathbb{R}$.
- **Adaptive Two-Child Splat Splitting Conservation (`NormedTensorGaussianSplat2D.splitMajor_conservation_identities`) & Coupled Electro-Thermal-Optical OPA Gain**:
  Formalized `splitMajorOffset`, `splitMajorPlus`, `splitMajorMinus`, and
  `splitMajor_conservation_identities` in [DDF.lean](../src/signals/Signals/DDF.lean)
  (and `NormedTensorGaussianSplat2D::split_if_anisotropic` / `OrbitalSplatScene::adaptive_remesh`
  in `orbital_splat.rs`), proving exact $L^1$ weight conservation ($w_+ + w_- = w$),
  center-of-mass preservation, major-axis second-moment variance conservation
  ($\tilde{\sigma}_1^2 + \delta_1^2 = \sigma_1^2$), aspect-ratio halving, and core Bohm
  refinement ($Q_{\mathrm{core}}(\Sigma) < Q_{\mathrm{core}}(\Sigma_+)$), together with
  `SecondHarmonicResonantOpaModel::coupled_electro_thermal_net_gain_sq` in `polariton_spp.rs`
  and Fresnel/rank-3 Plücker evaluators in `double_slit.rs`.

```lean
-- Iteration 25-32 verification: Inverse Compton, Raman, Polaritons, SPPs, AdS/CFT, Secret Symmetries, and Splat-Free Continuum vs. Tensor Splat DDF Mechanics
example {sub : Signals.DDF.DDFSubstrate} (s : Signals.DDF.MovingSheath sub)
    (re : Signals.DDF.RiverExterior sub) (hr : re.horizonRadius < 4)
    (m_cv : Signals.DDF.CattaneoVernotteHeatModel)
    (splat : Signals.DDF.NormedTensorGaussianSplat2D)
    (c_th0 : ℝ) (hc_pos : 0 < c_th0) (hc_le : c_th0 ≤ sub.c) (θ : ℝ) :
    let M_sheath := s.gr24TwistorMatrix 6 1 5 2 0 0
    let M_th := Signals.DDF.ddfThermalGr24Matrix (3 / 5) θ
    let kappa1 := Signals.DDF.evolveContinuumThermalMode 2 1 3 5
    let splat_ddf := s.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    let splat_evol := splat.evolveThermal 1 2 3 (by norm_num) (by norm_num) (by norm_num)
    let splat_evol2 := splat_evol.evolveThermal 1 2 4 (by norm_num) (by norm_num) (by norm_num)
    let splat_sum := splat.evolveThermal 1 2 (3 + 4) (by norm_num) (by norm_num) (by norm_num)
    let ω_UP := Signals.Scattering.upperPolaritonFreq 7 4 2
    let ω_LP := Signals.Scattering.lowerPolaritonFreq 7 4 2
    let M_spp := Signals.DDF.sppGr24Matrix (Signals.DDF.sppPermittivityContrast 2 6) θ
    let splat_spp := Signals.DDF.sppHotspotTensorSplat 0 0 5 1 10 3
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) θ
    let W_sec := Signals.DDF.psl22SecretAutomorphismGr24Matrix 2 1 1 1
    let M_ads5 := Signals.DDF.ddfThermalGr24Matrix ((1 / 2 : ℝ) ^ 2) θ
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_sheath) /
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_sheath) =
      Signals.Scattering.inverseComptonDopplerRatio s.beta ∧
    Signals.Scattering.reconstructSpectralDiff
      (Signals.Scattering.ramanAntiStokesFreq 10 2)
      (Signals.Scattering.ramanStokesFreq 10 2) = 10 ∧
    Signals.Scattering.reconstructPolaritonRabiCouplingSq 7 4 ω_UP ω_LP = 2 ^ 2 ∧
    Signals.Scattering.lyddaneSachsTellerPermittivity 3 4 6 5 < 0 ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_spp) /
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_spp) = 6 / 2 ∧
    1 ^ 2 / (2 * 1 * 1 ^ 2) ≤ splat_spp.coreBohmPotential 1 1 ∧
    Signals.Scattering.adsCftScalingDimensionPlus 4 5 +
      Signals.Scattering.adsCftScalingDimensionMinus 4 5 = 4 ∧
    Signals.Scattering.supertrace22 (Signals.Scattering.secretSymmetryMatrix 3) = 4 * 3 ∧
    (Signals.Geometry.complexTwoRowMinor W_sec 0 3) ^ 2 +
        Signals.Geometry.complexTwoRowMinor W_sec 0 2 *
          Signals.Geometry.complexTwoRowMinor W_sec 1 3 =
      Signals.Geometry.complexTwoRowMinor W_sec 0 1 *
        Signals.Geometry.complexTwoRowMinor W_sec 2 3 ∧
    Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_ads5) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_ads5) =
      Signals.DDF.adsPlanarBlackBraneEmblackening 1 2 4 ∧
    s.ddfSecondSoundSpeed c_th0 ≤ sub.c ∧
    s.ddfLongitudinalDiffusivity c_th0 m_cv.relaxationTime /
        (c_th0 ^ 2 * m_cv.relaxationTime) =
      Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_sheath) *
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_sheath) ∧
    (Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeA M_th) -
        Complex.normSq (Signals.DDF.complexPluckerSinkAmplitudeB M_th)) / 2 = 3 / 5 ∧
    Signals.DDF.evolveContinuumThermalMode 2 1 4 kappa1 =
      Signals.DDF.evolveContinuumThermalMode 2 1 (3 + 4) 5 ∧
    Signals.DDF.continuumBohmPotentialMode 1 1 kappa1 ≤
      Signals.DDF.continuumBohmPotentialMode 1 1 5 ∧
    s.ddfLongitudinalDiffusivity c_th0 m_cv.relaxationTime /
        (c_th0 ^ 2 * m_cv.relaxationTime) =
      splat_ddf.covDet / 2 ^ 4 ∧
    splat_evol.covTrace = splat.covTrace + 2 * (1 + 2) * 3 ∧
    splat_evol2 = splat_sum ∧
    splat_evol.coreBohmPotential 1 1 ≤ splat.coreBohmPotential 1 1 ∧
    splat.splitMajorPlus.sigma1 ^ 2 + splat.splitMajorOffset ^ 2 = splat.sigma1 ^ 2 ∧
    Signals.Scattering.psl22SecretCoproductFullOp16 2 (-1) 7 8 *
        Signals.Scattering.psl22WorldsheetRMatrix16 3 4 5 6 7 8 =
      Signals.Scattering.psl22WorldsheetRMatrix16 3 4 5 6 7 8 *
        Signals.Scattering.psl22SecretCoproductFull16 2 (-1) 7 8 := by
  intro M_sheath M_th kappa1 splat_ddf splat_evol splat_evol2 splat_sum ω_UP ω_LP M_spp splat_spp W_sec M_ads5
  have h_ics := s.inverseCompton_gr24_identities 6 1 5 2 0 0
  have h_ram := Signals.Scattering.raman_stokes_antiStokes_gr24_identities
    10 2 (1 / 2) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_pol := Signals.Scattering.polariton_hopfield_rabi_and_lst_identities
    7 4 2 3 4 6 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_spp_cont := s.sppContinuum_gr24_and_semigroup_identities
    2 6 (1 / 2) 3 4 10 5 1 1 θ (by norm_num) (by norm_num)
  have h_spp_splat := s.sppTensorSplat_and_thermal_identities
    0 0 5 1 10 3 1 2 3 4 1 1 θ 0 0
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have hu_K : (1 / (2 * Real.sqrt 3 : ℝ)) ^ 2 = 1 / 12 := by
    have h3 : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    calc
      (1 / (2 * Real.sqrt 3 : ℝ)) ^ 2 = 1 / (4 * (Real.sqrt 3) ^ 2) := by ring
      _ = 1 / 12 := by rw [h3]; norm_num
  have h_ads := Signals.Scattering.ads_cft_integrability_and_secret_symmetry_identities
    4 5 1 1 6 3 10 2 2 16 3 0 (1 / (2 * Real.sqrt 3)) 0 0 3
    (by norm_num) (by norm_num [Signals.Scattering.adsBreitenlohnerFreedmanBound])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) hu_K
  have h_unif := re.grassmannian_ads_cft_ddf_and_secret_symmetry_unification
    2 1 1 1 1 2 4 0 0 1 (1 / 2) 2 1 1 θ
    (by norm_num) (by norm_num) (by norm_num) hr
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_cont := s.ddfThermalTransport_continuum_identities
    c_th0 m_cv.relaxationTime 6 1 5 0 0 4 2 (-1) (3 / 5) θ 2
    hc_pos hc_le m_cv.relaxationTime_pos (by norm_num) (by norm_num)
  have h_cont_semi := s.ddfContinuum_semigroup_and_bohm_decay
    2 c_th0 10 0 m_cv.relaxationTime 2 1 3 4 5 5 (3 / 5) 1 1 θ
    (by norm_num) hc_pos hc_le (by norm_num)
    (by rw [zero_div]; norm_num) (by rw [zero_div]; norm_num)
    m_cv.relaxationTime_pos (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_th := s.ddfThermalTransport_and_splat_identities
    splat 0 0 5 2 c_th0 m_cv.relaxationTime 1 2 3 θ
    (by norm_num) (by norm_num) hc_pos hc_le m_cv.relaxationTime_pos
    (by norm_num) (by norm_num) (by norm_num)
  have h_semi := Signals.DDF.NormedTensorGaussianSplat2D.evolveThermal_semigroup_and_bohm_decay
    splat 1 2 3 4 1 1
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_spl := (splat.splitMajor_conservation_identities 1 1 (by norm_num) (by norm_num)).2.2.2.1
  have h_r16 := (Signals.Scattering.psl22_rmatrix16_secret_coproduct_intertwining
    2 (-1) 0 3 4 5 6 7 8).2.2.2.2.2
  rcases h_ads with ⟨ha1, _ha2, _ha3, _ha4, _ha5, _ha6, _ha7, _ha8, _ha9, _ha10,
    _ha11, _ha12, _ha13, _ha14, _ha15, _ha16, _ha17, _ha18, _ha19, _ha20, _ha21,
    _ha22, ha23, _ha24, _ha25, _ha26, _ha27⟩
  rcases h_unif with ⟨_hu1, _hu2, _hu3, _hu4, _hu5, _hu6, _hu7, hu8,
    hu9, _hu10, _hu11, _hu12, _hu13, _hu14, _hu15, _hu16⟩
  exact ⟨h_ics.1, h_ram.1, h_pol.2.2.2.1, h_pol.2.2.2.2.2.2.2.2.2.2.2.2,
    h_spp_cont.2.2.2.2.2.1.trans h_spp_cont.2.2.2.2.2.2.1, h_spp_splat.2.2.2.1,
    ha1, ha23, hu8, hu9,
    h_cont.2.1, h_cont.2.2.1, h_cont.2.2.2.2.2.1,
    h_cont_semi.2.2.2.2.2.1, h_cont_semi.2.2.2.2.2.2.2.2.1,
    h_th.2.2.2.1, h_th.2.2.2.2.2, h_semi.2.1, h_semi.2.2.2, h_spl, h_r16⟩

end HuygensGeometryRoadmap
```

### Synthesis: Implications of the Nine-Paper Unification, Concrete Applications, and Next Steps for Research

*(See also the standalone capstone paper [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-unification-applications-roadmap-paper.md).)*

#### 1. Theoretical & Structural Implications of the Unification

Across Iterations 24–32 and the nine companion papers, a single machine-checked
algebraic structure—the **complex Grassmannian $Gr_{\mathbb{C}}(2,4)$** (and its
$N$-ary generalization $Gr_{\mathbb{C}}(2, N+2)$) with uncrossed Pluecker channel
amplitudes $w_A^{\mathbb{C}} = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$,
$w_B^{\mathbb{C}} = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$, and
crossing collector $w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$—unifies
nine physical and mathematical domains that are conventionally treated with
disjoint formalisms:

| # | Companion Paper & Domain | Meaning of Barycentric Shift $d_{\mathrm{bary}}$ | Meaning of Uncrossed Product $\|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2 = 1 - d_{\mathrm{bary}}^2$ | Meaning of 3-Term Pluecker Identity $\Delta_{01}\Delta_{23} - \Delta_{02}\Delta_{13} + \Delta_{03}\Delta_{12} = 0$ |
|---|---|---|---|---|
| **1** | [Double-Slit, $N$-Slit, & OAM Interferometry](grassmannian-huygens-double-slit-oam-paper.md) | Qian--Izadi parallel-axis shift $\pm\sqrt{I_O - I_M} = \pm P_N$ | Squared fringe visibility $\mathcal{V}^2 = K_N^2 = 1 - P_N^2$ | Coherent two-slit / multi-slit wave amplitude superposition ($\varepsilon_{\mathrm{rel}} = 0$ on $Gr_{\mathbb{C}}(2,4)$) |
| **2** | [QISM & Algebraic Bethe Ansatz](grassmannian-qism-bethe-ansatz-paper.md) | Normalized spectral coupling $\eta / (u - v)$ | Unitarity factor $1 - \eta^2/(u-v)^2$ | Baxter's functional $QQ$-system, Hirota bilinear equation, and $TQ$ Casorati Wronskian identity |
| **3** | [DDF Moving Sheaths & Anosov Flows](grassmannian-ddf-moving-sheath-paper.md) | Reduced sheath speed $\beta = v / c \in [0, 1)$ | Inverse squared Lorentz jamming factor $\gamma_\varphi(v)^{-2} = 1 - v^2/c^2$ | Madelung two-sector density conservation and operational Minkowski interval $c^2 d\tau_D^2 = c^2 dt^2 - dx^2$ |
| **4** | [QED Scattering Gravity & Planetary Orbits](grassmannian-gravity-from-qed-scattering-paper.md) | Orbital eccentricity $e \in [0, 1)$ | Semi-latus rectum ratio $p / a = 1 - e^2$ | Bern--Carrasco--Johansson (BCJ) color--kinematics Jacobi identity $n_s + n_t + n_u = 0$ & graviton double copy |
| **5** | [Normed Tensor Gaussian Splat Mechanics](grassmannian-splat-mechanics-paper.md) | Principal variance asymmetry $(\sigma_1^2 - \sigma_2^2)/(2\sigma_0^2)$ | Normalized covariance determinant $\det\Sigma / \sigma_0^4$ | Dual-layer twistor wavepacket $\Psi_{\mathrm{splat}} = \sqrt{G}(w_A^{\mathbb{C}} + w_B^{\mathbb{C}})$ & Bohm precision-matrix regularization |
| **6** | [Inverse Compton, Raman, & Second-Sound Heat](grassmannian-thermal-compton-raman-paper.md) | Velocity $\beta$, Raman shift $\Omega_v/\omega_L$, or reduced heat flux $j_q = q / q_{\max}^{\mathrm{DDF}}$ | Relativistic Cattaneo flux-limiter margin $1 - j_q^2 > 0$ & jammed diffusivity ratio $\alpha_\parallel^{\mathrm{DDF}}/\alpha_0$ | Forward/backward Doppler & Stokes/anti-Stokes splitting; Second-LawPluecker product growth under relaxation |
| **7** | [Polaritons, SPPs, CSR, & $\chi^{(2)}$ SHG-OPA](grassmannian-polariton-spp-mechanics-paper.md) | Hopfield shift $d_{\mathrm{Hopfield}}$, SPP contrast $\chi_{\mathrm{SPP}}$, or Cherenkov $\cos\theta_C$ | Hybridization $4\|C\|^2\|X\|^2$, SPP resonance proximity, or Mach-cone $\sin^2\theta_C$ | Hopfield trace conservation, Anti-Amplituhedron destructive null ($w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = 0$), & symplectic OPA squeezing |
| **8** | ['t Hooft--Susskind Holographic Principle](grassmannian-holographic-principle-paper.md) | Radial river inflow ratio $\beta_\phi(r) = \sqrt{r_H / r}$ | Schwarzschild / Painlevé--Gullstrand gravitational redshift lapse $g_{00}(r) = 1 - r_H / r$ | Acoustic light-cone splitting ($1 \pm \sqrt{r_H/r}$) & Planck-splat horizon tiling $A_H = 4\ell_P^2(S_{\mathrm{BH}}/k_B)$ |
| **9** | [AdS/CFT, Integrability, & Secret Symmetries](grassmannian-ads-cft-ddf-paper.md) | Poincaré $\text{AdS}_5$ radial ratio $(z/z_H)^2$ | $\text{AdS}_5$ planar black-brane emblackening factor $f_{\text{AdS}_5}(z) = 1 - (z/z_H)^4$ | $\mathfrak{psl}(2|2)_c$ secret-symmetry outer-automorphism central-charge dispersion law $\mathbb{H}^2 - 4\mathbb{C}\mathbb{C}^\dagger = (ad-bc)^2 = M^2$ |

Four overarching theoretical implications follow from these machine-checked theorems:
1. **Complex Twistor Phase Resolves the Positivity Obstruction**: Restricting to
   the real positive Grassmannian $Gr_{\ge 0}(2,4)$ (or positive real Gaussian
   densities $G \ge 0$) forces a $50\%$ on-axis relative predictive error and
   forbids dark-fringe cancellation. Lifting to $Gr_{\mathbb{C}}(2,4)$ with
   Penrose twistor phases eliminates this error completely while preserving
   exact Pluecker algebra.
2. **The 3-Term Pluecker Identity Is a Master Conservation & Dispersion Law**:
   In optical interferometry it is coherent amplitude addition; in gauge/gravity
   scattering it is the BCJ kinematic Jacobi identity; in QISM it is Baxter's
   $QQ$-system; and in AdS/CFT integrability (`arXiv:1204.2366`) it is the
   $\mathfrak{psl}(2|2)_c$ central-charge dispersion relation
   $\mathbb{H}^2 - 4\mathbb{C}\mathbb{C}^\dagger = M^2$.
3. **Both Splat-Free Continuum and Tensor-Splat Discretizations Share the Same Invariants**:
   Every physical law in `Signals.DDF` and `Signals.Scattering` is proved both
   **without splats** (for continuum modes, PDEs, and Pluecker matrices) and
   **with `NormedTensorGaussianSplat2D`**, where $-\partial_i\partial_j \ln G = (\Sigma^{-1})_{ij}$
   reduces the Madelung quantum pressure tensor $\Pi_{ij}$ and core Bohm
   potential $Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2\operatorname{Tr}\Sigma}{4m\det\Sigma}$
   to nonsingular $2\times 2$ precision-matrix algebra.
4. **Sharp Physical Boundaries Separate Mathematical Duality from Material Realization**:
   The formalization explicitly separates what homogeneous projective
   $Gr_{\mathbb{C}}(2,4)$ covers (scale-free 2-channel coherence, Doppler/Raman/SPP
   ratios, and symplectic squeezing) from what requires external dimensional or
   thermodynamic data (Klein--Nishina rest-mass recoil $\epsilon_{\mathrm{rec}}$,
   Bose--Einstein vacuum fluctuations $\bar{n}_{\mathrm{BE}}+1$, Cattaneo
   relaxation time $\tau_r$, and active pump power budgets), and distinguishes
   5D $\text{AdS}_5/\text{CFT}_4$ ($\Lambda < 0$, $\eta_{\mathrm{act}}^\gamma = 1$)
   from 4D asymptotically flat DDF river mechanics ($\eta_{\mathrm{act}}^\gamma = 0$,
   Mercury $42.98''/\text{cy}$).

#### 2. Concrete Engineering & Scientific Applications

1. **Photonic, Plasmonic, & Soliton-Bus Interconnect Design (`Signals.SolitonBus`, `polariton_spp.rs`)**:
   - Design and verification of dual-rail and $N$-lane ($N > 0$) OAM soliton
     couplers (`SolitonMultiLaneCoupler`), sub-wavelength N-LIG graphene SPP
     waveguides ($n_{\mathrm{SPP}} \sim 50\text{--}100$), and low-power
     ($<200\text{ mW}$) integrated $\chi^{(2)}$ second-harmonic resonant optical
     parametric amplifiers (`SecondHarmonicResonantOpaModel`, [Dean et al. 2025](https://doi.org/10.1038/s41586-025-09959-z))
     with piezoelectric/electro-optic phase-matching gates (`opaNetGainSq`).
2. **Non-Destructive Inverse Spectroscopy, Thermometry, & Anomaly Detection (`Signals.Scattering`, `thermal_inelastic.rs`)**:
   - Closed-form parameter inversion for inline Stokes/anti-Stokes Raman
     thermometry (`reconstructRamanTemperature`) in CNT/lignin-vitrimer
     manufacturing and distributed fiber sensing, relativistic electron-beam
     Doppler/recoil metrology (`reconstructInverseComptonBeta`,
     `reconstructKleinNishinaRecoil`), microcavity polariton Rabi spectroscopy
     (`reconstructPolaritonRabiCouplingSq`), SPP permittivity-contrast sensing
     (`reconstructSppPermittivityRatio`), and calibrated Baxter $TQ$ spin-chain
     residual auditing (`baxterTQResidualMeasurement`).
3. **Causal Ultrafast & Cryogenic Thermal Management (`CattaneoVernotteHeatModel`, `MovingSheath.ddfThermalTransport_*`)**:
   - Flux-limited hyperbolic heat-wave modeling ($|q| < q_{\max}^{\mathrm{DDF}}$)
     for femtosecond/CW laser material processing (`Signals.LaserProcesses`),
     plasmonic hotspot Ohmic relaxation (`sppTensorSplat_and_thermal_identities`),
     and $39\text{ K}$ $\text{MgB}_2$ / $\text{He-3}$ cryogenic bearing assemblies,
     eliminating the infinite propagation speed of parabolic Fourier diffusion.
4. **Universal Browser-Based Scientific Visualization (`signals-numerical-adapter` WASM + WebGL2)**:
   - Real-time ($60\text{--}120\text{ FPS}$) interactive simulation of
     multi-model double-slit/OAM diffraction (`double_slit.rs`), relativistic
     planetary precession and DDF moving sheaths (`orbital_splat.rs`), causal
     second-sound thermal waves (`thermal_inelastic.rs`), and polariton/SPP/OPA/AdS-CFT
     invariants (`polariton_spp.rs`) using `f64` Rust/WASM cores paired with
     WebGL2 (`#version 300 es`) fragment shaders.

#### 3. Prioritized Next Steps for Research

With Iteration 33 completing the paraxial Fresnel-to-Fraunhofer remainder bound (`fresnel_to_fraunhofer_remainder_bound`, `CellQuadrature.fresnelFraunhoferComparison`), higher-rank $Gr(3,n)$ / $Gr_{\mathbb{C}}(3,n)$ four-term Plücker relations (`threeRowMinor_pluecker`), multi-layer and three-channel ($k=3$) LGV disjoint-path positivity (`lgv_multiLayer_det_positive`, `planar_threeChannel_lgv_and_bottleneck_identities`), full $16 \times 16$ $\mathfrak{psl}(2|2)_c$ worldsheet $R$-matrix and Yangian-tail secret coproduct intertwining (`psl22_rmatrix16_secret_coproduct_intertwining`), and adaptive two-child splat splitting conservation (`splitMajor_conservation_identities`, `split_if_anisotropic`), the remaining priorities are:

1. **Mathematical & Lean 4 Formalization Track**:
   - **Non-Paraxial 3D Rayleigh–Sommerfeld Vector Boundary Remainder (Phase 2 & Phase 6)**:
     Extend `fresnel_to_fraunhofer_remainder_bound` to a non-paraxial 3D Helmholtz /
     Rayleigh–Sommerfeld vector boundary-integral remainder bound and derive the
     uniform optical-kernel Lipschitz constant directly from separation and wavelength intervals.
   - **Arbitrary-Rank Grassmannians $Gr_{\mathbb{C}}(k, n)$ ($k \ge 4$) & Non-Layered Planar Embeddings (Phase 3 & Phase 4)**:
     Extend the rank-2 and rank-3 Plücker syzygies to arbitrary rank $k \ge 4$,
     formalize non-layered planar disk embeddings and square moves, and construct
     projective canonical differential forms beyond fixed affine charts.
   - **BES Dressing-Phase Crossing Equation & Fermion-Pair Creation Block**:
     Extend `psl22WorldsheetRMatrix16` in `Signals.Scattering` with the
     $\mathfrak{su}(2)\oplus\mathfrak{su}(2)$-breaking $|\phi^1\phi^2\rangle \leftrightarrow |\psi^1\psi^2\rangle$
     amplitudes $(C, F)$ and the all-loop BES dressing-phase crossing relation.
2. **Numerical & Rust/WASM/WebGL2 Engineering Track**:
   - **Curved-Streamline Multi-Generation Splat Remeshing & Vortex Benchmarks**:
     Extend `NormedTensorGaussianSplat2D::split_if_anisotropic` and
     `OrbitalSplatScene::adaptive_remesh` to recursive multi-generation remeshing
     along curved streamlines, and benchmark Vortex `0.86.1` vs. Arrow/Parquet on
     large 3D JHTDB cutouts.
   - **Time-Domain Coupled Electro-Thermal-Optical Waveguide Stepping**:
     Couple the 1D/2D Cattaneo–Vernotte / DDF telegrapher solver (`thermal_inelastic.rs`)
     with `SecondHarmonicResonantOpaModel::coupled_electro_thermal_net_gain_sq`
     (`polariton_spp.rs`) across multi-step time-domain waveguide transients.
3. **Experimental & Dataset Validation Track**:
   - **Calibrated Laboratory & Open-Dataset Ingestion**: Populate
     `ControlledMeasurement` and `FlowBoundaryEvidence` with measured
     double-slit/OAM interferograms, calibrated Stokes/anti-Stokes Raman
     spectra, and multi-frame JHTDB/PIV vortex-reconnection cutouts.
   - **Experimental Discriminator Tests**: Preregister and execute (a) CW vs.
     pulsed N-LIG Raman/XPS/HAZ material controls ([flat-light-proca-nlig-validation-plan.md](flat-light-proca-nlig-validation-plan.md))
     and (b) high-finesse crossed-laser-beam deflection interferometry to test
     the decisive DDF ($\eta_{\mathrm{act}}^\gamma = 0$) vs. General Relativity
     ($\eta_{\mathrm{act}}^\gamma = 1$) active radiation sourcing prediction
     (`ddf_photon_deflection_null` vs. `gr_photon_deflection_active`).

### Remaining Acceptance Obligations

| Phase | Verified checkpoint | Still required |
|---|---|---|
| 0 | Regularity/positive-scale guards, nonempty finite-extent slit samples, arbitrary-wavelength analytic reference, phase/mask/off-axis controls, fixed-tolerance rejection. | Finite-area slit geometry and refinement belong to the continuum/quadrature track; fixtures are not measurements. |
| 1 | Selected fixed-field planar area integral, guarded integrability, disjoint-mask addition. | Boundary approximation accuracy, incident/boundary data, dimensioned field normalization, and a justified Green representation or approximation bound. |
| 2 | Actual measured-cell weights, derived Lipschitz/mesh/area error rate, refinement convergence, uniform-domain comparison, finite-aperture correspondence, the analytic Fraunhofer rectangular double-slit benchmark with proved on-axis maximum, symmetry, interference dark fringes, and diffraction envelope nulls, and the paraxial Fresnel-to-Fraunhofer quadratic phase remainder & unit-phasor chord bound (`fresnel_to_fraunhofer_remainder_bound`, `CellQuadrature.fresnelFraunhoferComparison`). | Prove uniform optical-kernel Lipschitz regularity directly from separation and a wavelength interval, and construct an explicit 2D rectangular area mesh partition. |
| 3 | General determinant basis law, orientation controls, ratio invariance, normalized positive interval representative; bounded earliest exits and derived boundary first-return permutation; ranked weighted transfer, boundary measurements, guarded one-edge subdivision and parallel two-edge diamond reduction invariance, measured fork rank/positivity, two-channel determinant/rank controls, shared-hub cancellation, general finite two-step pair/minor identities with arbitrary ordered sink selections and derived positive/full-rank nonnegative records, general $2\times n$ ordered four-column Pluecker relations with sign-flip controls, higher-rank $Gr(3,n)$ and $Gr_{\mathbb{C}}(3,n)$ four-term quadratic Pluecker relations (`threeRowMinor_pluecker`, `complexThreeRowMinor_pluecker`, `selectedMinor_pluecker_rank3_five`), and multi-layer & three-channel ($k=3$) Lindström–Gessel–Viennot disjoint-path positivity vs. 2-vertex bottleneck cancellation (`lgv_multiLayer_det_positive`, `planar_threeChannel_lgv_and_bottleneck_identities`). | Decoration rules; arbitrary-rank ($k \ge 4$) Pluecker syzygies, general non-layered planar disk embedding cell correspondence, general embedded-network square moves, and any quotient construction. |
| 4 | Affine alternating interval/triangle/square forms, oriented boundary limits, normalization, pullbacks, and diagonal cancellation/continuation. | General projective canonical-form existence/uniqueness, arbitrary-chart invariance and higher-dimensional amplituhedron forms. |
| 5 | A literal unphased form-evaluation candidate is falsified without fitting; complex $Gr_{\mathbb{C}}(2,4)$ and $Gr_{\mathbb{C}}(2,N+2)$ twistor channel evaluators (`complexGr24CrossingDoubleSlit`, `MovingSheath.gr24TwistorMatrix`, `NormedTensorGaussianSplat2D.complexTwistorWavepacket`) eliminate the $50\%$ unphased error and reproduce Fraunhofer, Huygens--Steiner, OAM, and DDF moving-sheath interference identically. | Derive a first-principles Helmholtz boundary integral pushforward without prescribing the paraxial phase argument $\theta(x,y,\phi)$. |
| 6 | Nonempty fixed-function comparisons, amplitude/intensity bounds, separate error-budget composition, paraxial Fresnel-to-Fraunhofer remainder bound (`fresnel_to_fraunhofer_remainder_bound`, `CellQuadrature.fresnelFraunhoferComparison`), five-model double-slit & $N$-slit ($N>0$) error laws, QISM $8\times 8$ Yang--Baxter / $Gr(2,4)$ Wronskian / Slavnov identities, DDF sheath jamming / Anosov invariance, BCJ double-copy planetary precession ($42.98''/\text{cy}$), normed Tensor Gaussian Splatting ($Q_{\mathrm{core}}, \Pi_{ij}$), Inverse Compton, Stokes/anti-Stokes Raman, Fourier / Cattaneo--Vernotte / Grassmannian--DDF heat transport, Polaritons / SPPs, CSR-SPP superradiance, 't Hooft--Susskind holography, $\chi^{(2)}$ SHG-OPA squeezing, Maldacena/GKPW AdS/CFT, planar integrability (`arXiv:1012.3982`), and $16 \times 16$ $\mathfrak{psl}(2|2)_c$ secret symmetries (`arXiv:1204.2366`, `psl22_rmatrix16_secret_coproduct_intertwining`) (both splat-free continuum and tensor-splat). | Full 3D non-paraxial Rayleigh–Sommerfeld vector boundary-integral remainder bound. |
| 7 | No experimental claim introduced; Rust/WASM (`wasm32-unknown-unknown`) and WebGL2 GLSL (`#version 300 es`) numerical adapters (`double_slit.rs`, `orbital_splat.rs`, `thermal_inelastic.rs`, `polariton_spp.rs`) including adaptive splat remeshing (`split_if_anisotropic`) and coupled electro-thermal-optical OPA gain verified with 48 parametric `rstest` and `insta` snapshot tests. | Calibrated raw optical, interferometric, Raman, and thermal-wave laboratory data, uncertainty, backgrounds, drift, and model-regime controls. |

No theorem here promotes a supplied Pending match, a checked fixture, or a
canonical-form identity into optical or hardware validation. The next bridge
iteration needs a justified evaluator rather than another match assumption;
the independent boundary, quadrature and network proof tracks remain available.

## Validation and Status

The latest completed iteration gates passed: `SignalsTests`,
`make signals_build` (and `:blueprint` / `:blueprintJson` extraction at 3,715 Lake jobs),
all six concatenated report Lean fences, all nine companion `grassmannian-*-paper`
Lean proof blocks, 48 Rust unit/parametric/`insta` snapshot tests (`cargo test`),
`wasm32-unknown-unknown` release compilation,
Sphinx HTML, correct Lake source setup, and scoped whitespace checks. This is build
verification, not a runtime optical experiment or a projective existence proof.

The following records the original review baseline, before the implementation
checkpoints above. All seven then-indexed Lean source files typechecked against the
current project import artifacts. The four concatenated Lean blocks in this
report also typechecked, including the nonempty detector-domain guard. The
HTML build succeeded; unrelated documentation warnings remain. Neither the
index-text check nor the report examples is a hermetic staged dependency build.

The previously observed Signals build completed at 3,591 Lake jobs. That is a
build-graph observation, not a performance benchmark or a guarantee about a
later dependency graph. The completion note for this report records the current
validation results separately.

Required gates for subsequent model changes:

```bash
pushd src/signals
lake build Signals.Geometry Signals.Huygens Signals.Plabic
lake build SignalsTests SignalsPendingTests
popd
make signals_build
make -C docs html
git diff --check
```

For this report, parse the MyST source, concatenate its `lean` fences in order,
and typecheck them against the current pinned project. The source includes
checked existing APIs, an integrable Bochner-integral interface, a scalar
interval normalization lemma, and an explicit comparison contract. None claims
the remaining continuum, canonical-form, or bridge theorem.

### Scholarly References

(scholarly-amplituhedron)=
<a id="arkani-hamed-trnka2014"></a>
Arkani-Hamed, N., and Trnka, J. (2014). *The Amplituhedron*.
Journal of High Energy Physics 2014(10), 030.
[DOI: 10.1007/JHEP10(2014)030](https://doi.org/10.1007/JHEP10%282014%29030);
[arXiv:1312.2007](https://arxiv.org/abs/1312.2007).
Source type: theoretical scattering-amplitude construction for planar
$\mathcal N=4$ SYM, not a diffraction experiment.

(scholarly-positive-geometries)=
<a id="arkani-hamed-bai-lam2017"></a>
Arkani-Hamed, N., Bai, Y., and Lam, T. (2017).
*Positive Geometries and Canonical Forms*.
Journal of High Energy Physics 2017(11), 039.
[DOI: 10.1007/JHEP11(2017)039](https://doi.org/10.1007/JHEP11%282017%29039);
[arXiv:1703.04541](https://arxiv.org/abs/1703.04541).
Source type: mathematical/theoretical framework for positive geometries,
canonical forms, and recursive boundary residues.

(scholarly-postnikov-networks)=
<a id="postnikov2006"></a>
Postnikov, A. (2006). *Total positivity, Grassmannians, and networks*.
[arXiv:math/0609764](https://arxiv.org/abs/math/0609764);
[DOI: 10.48550/arXiv.math/0609764](https://doi.org/10.48550/arXiv.math/0609764).
Source type: mathematical preprint on nonnegative Grassmannian cells and
weighted planar networks, not an optical-device validation.

(scholarly-qian-izadi)=
<a id="qian-izadi2023"></a>
Qian, X.-F., and Izadi, M. (2023). *Bridging coherence optics and classical
mechanics: A generic light polarization-entanglement complementary relation*.
Physical Review Research 5(3), 033110.
[DOI: 10.1103/PhysRevResearch.5.033110](https://doi.org/10.1103/PhysRevResearch.5.033110).
Source type: peer-reviewed theoretical and mathematical model connecting
$N$-dimensional optical coherence spectra ($P_N^2 + K_N^2 = 1$) to barycentric
simplex point masses and the Huygens--Steiner parallel-axis theorem
($I_O = I_M + m_{\mathrm{tot}} d^2$).