# Signals

`Signals` is a small Lean 4 project for checking the mathematics used in the
signal-processing parts of the sustainablefactory research notes. It is a
research companion, not a claim that the proposed hardware or physical
mechanisms have been experimentally validated.

## Current Scope

The current build deliberately implements statements with a clear mathematical
interpretation while keeping experimental premises explicit:

- `Signals.Units` provides named wrappers for frequency, length, and power.
- `Signals.IQ` represents an in-phase/quadrature sample as a complex baseband
   value, exposes its magnitude and principal phase, records carrier and
   quadrature conventions, and provides a conditional phase-to-height formula.
- `Signals.Acoustics` models classical ultrasonic transfer from pressure
   amplitude and acoustic impedance through aperture, transducer, link, and
   receiver efficiencies. It proves passive received power is bounded by
   incident power.
- `Signals.Sampling` defines finite sampled tones, exact buffer reconstruction,
   integer-rate aliases, and a strict Nyquist no-alias consequence. The finite
   model is intentional; it is not a replacement for a continuous
   band-limited Fourier theorem.
- `Signals.Coherence` records the polarization/entanglement complementarity
   identity as explicit model data and states the scalar Huygens-Steiner
   parallel-axis identity.
- `Signals.OAM` represents a finite normalized OAM qudit and computes its basis
  state count. The exact identity `100^10 = 10^20` is a combinatorial result,
  not a performance or physical-realizability claim.
- `Signals.Physlib` imports Physlib's compatible free-space parameter model and
   proves a small interface lemma over its `FreeSpace` parameters.
- `Signals.Proca` provides a normalized massive-vector mode with explicit mass,
   medium, coupling, boundary, dispersion, and longitudinal-polarization data.
   It now also models a source-driven field equation, current continuity,
   constitutive response, and conditional phase-height measurements.
- `Signals.Maxwell` provides a coordinate-free three-vector formulation of
   Maxwell's equations, including Gauss, Faraday, and Ampere-Maxwell laws. It
   also includes the isotropic-vacuum form often used as a compact pre-tensor
   formulation; fields are represented directly as vectors, with no Euler-angle
   or gimbal-lock state.
- `Signals.Scattering` models coherent I/Q observations, scattered-to-incident
   power ratios, reference-subtracted phase-height reconstruction, scattering
   cross-section inversion, SNR, and residual-based anomaly candidates.
- `Signals.Propagation` models far-field and near-field coupling, antenna
   efficiency, impedance matching, aperture coupling, alignment, radiation,
   bulk attenuation, interface reflection/transmission/absorption, and passive
   link-power bounds.
- `Signals.Applications` defines measured-model application contracts for
   finite Airy packets, waveguides, nonlinear frequency conversion, MIMO
   pumping, wireless power transfer, and plasma-drive power balance. It does not
   import the pending SQG/fracture claims.
- `Signals.Pending` is an intentionally separate submodule for the requested
   SQG, fracture-state, anti-Amplituhedron, deterministic-fusion, and
   spacetime-energy formalisms. These models are explicit mathematical
   hypotheses and are not imported by `Signals`. It also contains
   `SQGMaxwellSystem`, which adds effective constitutive parameters and an
   explicit SQG current to Maxwell's equations.
   It also contains LF/VLF radio test vectors for Earth, named planets,
   asteroids, and arbitrary named bodies, plus a conditional ultrasonic
   fracture-evidence protocol.
- `Signals.Geometry` contains Weyl spinors, twistors, antisymmetric minors, and
   the finite $2 \times 4$ Pluecker relation.
- `Signals.Fabrication` models voxel fields, active phase masks, calibration
   tolerances, height-map bounds, and thermal budgets as data with accessor
   lemmas.
- `SignalsTests` contains compile-time examples for the verified identities and
   edge cases. `SignalsPendingTests` separately compiles examples of the pending
   hypotheses and their conditional consequences. `make signals_build` builds
   all four targets.

The source chat's extracted Lean corpus is available at
`../../data/chats/IQ-Sampling-for-Signal-Phase.lean` from this project directory.
The motivating I/Q equations and phase extraction are in the
[source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L7-L80); its
later Proca discussion explicitly corrects the ordinary-air premise and states
the effective-mass requirement
([source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L359-L377)).
The chat's iGPE/waveguide proposal is recorded at
([source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L564-L571)),
while its anti-fire and vacuum-expansion claims are recorded at
([source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L1451-L1465)).
The neutron/fracture chat proposes an acoustic-to-photonic chain: machinery
vibration creates underwater pressure waves, surface micro-ripples modulate
reflected optical phase, and Brillouin scattering can expose acoustic or density
changes
([fracture chat](../../data/chats/_Neutrons-and-Black-Holes-and-Fracture.md#L94-L129)).
It further proposes LDV, LiDAR, SAR, and DAS as complementary readout paths and
calls out ocean-wave background and orbital coherence requirements
([fracture chat](../../data/chats/_Neutrons-and-Black-Holes-and-Fracture.md#L133-L147)).
The implementation treats these as ordinary scattering/metrology observables.
An ultrasonic transfer result becomes a Pending fracture candidate only when
its calibrated classical residual is outside tolerance; transfer by itself is
not evidence of a massive photon or spacetime fracture.
The companion Airy discussion describes the proposed Proca equation and later
reuses it for lithospheric, ionospheric, and through-space channels
([Airy chat](../../data/chats/_Airy-Beams-and-Communications-and-Illumination.md#L2147-L2206),
[Airy chat](../../data/chats/_Airy-Beams-and-Communications-and-Illumination.md#L2378-L2390)).
The primary chat later proposes 400 GHz beam mixing, nonlinear conversion, and
an intensity estimate
([source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L1546-L1591),
[source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L1645-L1686)).
The Signals model corrects the reported intensity: $10^6$ V/m gives about
$1.33 \times 10^9$ W/m², or $132.7$ kW/cm², under the stated vacuum plane-wave
formula. The source's later atmospheric-scavenging and bow-shock sections reuse
the unverified SQG premise
([source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L2579-L2611),
[source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L2648-L2660)).

The companion Airy-beam chat proposes four routing modes: lithospheric chord,
surface Airy arc, ionospheric MHD ducting, and through-space ballistic
propagation
([Airy chat](../../data/chats/_Airy-Beams-and-Communications-and-Illumination.md#L2198-L2240),
[Airy chat](../../data/chats/_Airy-Beams-and-Communications-and-Illumination.md#L2378-L2390)).
It also identifies the relevant unresolved engineering variables: interface
impedance, finite Airy truncation, space-weather variation, insertion loss,
re-entry loss, and the absence of a supporting nonlinear medium in vacuum
([Airy chat](../../data/chats/_Airy-Beams-and-Communications-and-Illumination.md#L2858-L2933)).
The current propagation layer makes those quantities explicit and bounded; it
does not assert the proposed channel performance.
The extracted corpus also names future areas including spinors, twistors,
Grassmannians, Amplituhedron forms, Proca-SQG models, holography, quantum
states, and thermodynamics, but those names are not evidence for the associated
hardware claims.

## Build

The project currently selects Lean `v4.34.0-rc2`; the sibling Physlib checkout
must remain on a compatible revision.
From the repository root:

```text
make signals_build
```

This builds `Signals`, `SignalsTests`, `SignalsPending`, and
`SignalsPendingTests`. The two test targets use Lean `example` declarations as
executable compile-time tests.

Or from this directory:

```text
make lean-cache
make lean-build
```

The devcontainer builds Signals after the workspace is mounted, rather than
compiling it while the Docker image is built. It mounts the named volume
`sustainablefactory-${localWorkspaceFolderBasename}-signals-lake` at
`src/signals/.lake`, so compiled Mathlib, Physlib, and Signals artifacts remain
available when the container is recreated. The first workspace build can still
take time; subsequent builds are incremental.

The Lake file uses the sibling checkouts at `../mathlib4` and `../physlib`.
Those checkouts must target compatible revisions. At the time this project was
started, the local mathlib checkout reported `v4.34.0-rc2` while Physlib
reported `v4.33.0`; do not mix their build artifacts. A clean CI checkout pins
the matching dependency revisions before running Lean.

The local toolchain is available in the dev container, and the same build is
used as the local and CI check.

## Development Plan

### Phase 1: Stabilize the base API

1. [Implemented] Keep the I/Q API aligned with complex baseband magnitude and
   principal-phase definitions.
2. [Implemented] Test zero magnitude, orientation conventions, and the
   principal-argument boundary.
3. Keep the scalar unit wrappers until a demonstrated dimensional error
   justifies a larger unit representation.

### Phase 2: Formalize standard signal and field models

1. [Implemented] Define a convention record for carrier sign, quadrature
   orientation, and phase range.
2. [Implemented, finite model] Prove exact sampled-tone aliasing and a strict
   Nyquist no-alias consequence. Continuous Shannon reconstruction remains
   future work.
3. Retain the compatible Physlib `FreeSpace` interface; importing the full
   harmonic-wave module currently crosses an incompatible local dependency
   boundary.
4. [Implemented] Add a normalized Proca mode with mass, dispersion, medium,
   coupling, boundary, and longitudinal-polarization assumptions visible in
   the types.
5. [Implemented] Add source continuity, constitutive response, lossy
   propagation, interface power conservation, near-field coupling, and
   application-level power budgets.
6. [Implemented] Add the coordinate-free three-vector Maxwell equations and
   their derived charge-continuity law. Keep the SQG-modified Maxwell system in
   `Signals.Pending`.
7. [Implemented] Add classical acoustic transfer and scattering-metrology
   primitives, including I/Q backscatter, cross section, SNR, phase-height
   reconstruction, and residual classification.

### Phase 3: Add geometry and fabrication abstractions

1. [Implemented, finite algebra] Introduce spinors and twistors as data and
   prove their elementary antisymmetry identities.
2. [Implemented, finite algebra] Prove a $2 \times 4$ Pluecker relation with
   determinants; do not encode an Amplituhedron volume as an axiom.
3. [Implemented] Model masks, voxels, calibration, height bounds, and thermal
   budgets as data plus proved bounds. Fabrication execution remains outside
   the theorem-proving core.
4. Keep OAM state-space counting separate from claims about computational
   speed, fault tolerance, or device capacity.
5. [Moved to Pending] Represent SQG fracture states and finite Amplituhedron
    phase profiles as explicit hypotheses without importing them into the
    verified library.

### Pending Physical Formalisms

`Signals.Pending` develops the requested precedent formalisms in an isolated
namespace and build target:

- `IGPEPoint` records the local iGPE balance with effective mass, potential,
   coupling, density, time derivative, and Laplacian terms.
- `SQGMaxwellSystem` records Maxwell's vector equations with effective
   permittivity/permeability, an explicit extra SQG current, and a classical
   Maxwell reduction when that current is disabled.
- `EffectiveAcousticMetric` records the pending acoustic metric law and its
   ergoregion sign condition.
- `PhaseSlip` records integer winding and the corresponding $2\pi$ phase jump.
- `ProcaChannel` joins a massive-vector mode to an explicitly assumed
   longitudinal channel, a lossy link budget, and a propagation domain.
- `RadioBand`, `RadioTestVector`, `BodyTarget`, and
   `ThroughBodyRadioTestVector` represent LF/VLF through-body test cases without
   claiming that a particular body is a viable propagation medium.
- `AcousticFractureEvidence` links a classical ultrasonic transfer measurement
   to an out-of-tolerance residual as a candidate for further fracture testing;
   it does not diagnose the cause of that residual.
- `WKBBarrier` records a proper-distance factor, effective barrier, WKB
   exponent, and bounded Gamow probability.
- `AntiAmplituhedronProfile` and `SQGVacuumExpansion` record divergent-profile
   and negative-coupling hypotheses.
- `AntiFireSuppression` records suppression as an explicit rate inequality.
- `FusionReaction` and `DeterministicFusionClaim` make reaction probability and
   energy per reaction explicit rather than replacing probability with a theorem.
- `EnergyLedger` and `SpacetimeExtractionClaim` require any output beyond
   control and fuel power to appear as a declared spacetime input.

The pending target proves only conditional algebraic consequences of these
records. It does not establish that SQG, anti-Amplituhedron fields,
deterministic fusion, or spacetime energy extraction exist physically.

### Scattering Metrology Plan

1. [Implemented] Validate I/Q phase and magnitude from coherent returns.
2. [Implemented] Tie acoustic pressure, impedance, aperture area, and transfer
   efficiency to a passive power budget.
3. [Implemented] Represent phase-height inversion, cross section, SNR, and
   calibrated residuals.
4. Next: add finite array/grid observations, complex material transfer
   functions, frequency-dependent attenuation, speckle covariance, and
   uncertainty propagation.
5. Pending: add weak-derivative, trace, and jump-condition structures for a
   fracture boundary only after the relevant measure, function-space, and flux
   assumptions are supplied.
6. Pending: add a numerical Madelung/GP splat model with variable covariance,
   compressibility, healing length, and FTLE diagnostics. A fixed determinant
   must not be treated as incompressibility; the source chat itself notes that
   air and superfluids are compressible
   ([fracture chat](../../data/chats/_Neutrons-and-Black-Holes-and-Fracture.md#L1258-L1308)).

### Phase 4: Upstream contributions

- Candidate Physlib contributions: reusable mainstream definitions and lemmas
  for electromagnetic wave conventions, polarization, sampling interfaces,
  and massive-vector fields when they have a clear physics reference.
- Candidate Mathlib contributions: general theorems about finite-dimensional
  linear algebra, complex coordinates, matrix minors, or analysis that do not
  depend on a particular physical interpretation.
- The Signals repository should first carry an independently tested proposal,
  then submit small focused pull requests upstream. Each proposal must name
  its mathematical statement, references, assumptions, and proof dependencies.

## Research Boundaries

The chats include claims about longitudinal optical waves in ordinary air,
SQG vacuum coupling, lithospheric or ionospheric routing, over-unity power
generation, deterministic fusion, and sub-diffraction lithography.

> Those claims are not represented by the verified `Signals` library. Lean
> checks consequences of definitions and hypotheses; it does not turn
> unsupported physical premises into evidence. The separate `Signals.Pending`
> target represents Proca/SQG/fracture/Amplituhedron concepts as explicit model
> objects because they are part of the requested mathematical framework, but
> their medium support, coupling coefficients, attenuation, and performance
> remain hypotheses. The source chat itself acknowledges the distinction
> between theorem proving and physical validation ([source chat](../../data/chats/IQ-Sampling-for-Signal-Phase.md#L4350-L4354)).

In particular, no current module proves that a massive longitudinal photon
propagates through ordinary tropospheric air, that SQG changes vacuum pressure,
that a fracture state transmits information faster than light, or that a
Proca/SQG device extracts net energy without an input budget. Those are future
experimental or theoretical work items, not consequences of the formal
definitions.
