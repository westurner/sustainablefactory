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

### Remaining Acceptance Obligations

| Phase | Verified checkpoint | Still required |
|---|---|---|
| 0 | Regularity/positive-scale guards, nonempty finite-extent slit samples, arbitrary-wavelength analytic reference, phase/mask/off-axis controls, fixed-tolerance rejection. | Finite-area slit geometry and refinement belong to the continuum/quadrature track; fixtures are not measurements. |
| 1 | Selected fixed-field planar area integral, guarded integrability, disjoint-mask addition. | Boundary approximation accuracy, incident/boundary data, dimensioned field normalization, and a justified Green representation or approximation bound. |
| 2 | Actual measured-cell weights, derived Lipschitz/mesh/area error rate, refinement convergence, uniform-domain comparison and finite-aperture correspondence. | Prove uniform optical-kernel regularity from separation and a wavelength interval; construct a rectangular area mesh and prove the Fraunhofer limit. |
| 3 | General determinant basis law, orientation controls, ratio invariance, normalized positive interval representative. | Weighted acyclic network measurements, constructive first-return exits, embedding/cell correspondence, network moves, general Pluecker relations, and any quotient construction. |
| 4 | Affine alternating interval/triangle/square forms, oriented boundary limits, normalization, pullbacks, and diagonal cancellation/continuation. | General projective canonical-form existence/uniqueness, arbitrary-chart invariance and higher-dimensional amplituhedron forms. |
| 5 | A literal unphased form-evaluation candidate is falsified without fitting. | Derive a dimensioned oscillatory complex evaluator and its invariances independently of the optical answer. |
| 6 | Nonempty fixed-function comparisons, amplitude/intensity bounds and separate error-budget composition. | A genuine geometric/classical equality or held-out uniform error theorem after both tracks meet their gates. |
| 7 | No experimental claim introduced. | Calibrated raw optical data, uncertainty, backgrounds, drift and model-regime controls. |

No theorem here promotes a supplied Pending match, a checked fixture, or a
canonical-form identity into optical or hardware validation. The next bridge
iteration needs a justified evaluator rather than another match assumption;
the independent boundary, quadrature and network proof tracks remain available.

## Validation and Status

The implementation loop's final gates passed: `SignalsTests` at 3,576 jobs,
`make signals_build` at 3,592 jobs, all four concatenated report Lean fences,
Sphinx HTML, and scoped whitespace checks. Sphinx reported 66 warnings, with
none attributed to this report by the focused warning filter. This is build
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