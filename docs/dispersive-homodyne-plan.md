# Dispersive Homodyne Coverage and Implementation Plan

**Status:** Implementation in progress; Phases 1-6 and spatial/runtime
bookkeeping are implemented, while measured-data and external runtime work
remain.

**Scope:** Verify and fully cover the dispersive-homodyne material found by
`docindex search quantum homodyne` in the Signals library, its documentation,
and any future Rust/WASM integration. The earlier `docindex search homodyne`
audit remains useful as a narrower baseline.

## Audit Result

`docindex search quantum homodyne` returned 10 ranked YAML results across six
source artifacts: five MyST chat documents and one rendered HTML duplicate.
Every result reported `source_location: null`, so the YAML locations cannot be
used as line anchors. The snippets remain useful for discovery; the direct
source passages and fallback literal-match lines below are the evidence
locations for implementation decisions. The CLI requires the two-word query
to be quoted as one argument, so the executable form is
`docindex search 'quantum homodyne'`.

The current Signals coverage is **substantially implemented but still partial**.
It now models a finite classical balanced homodyne detector, calibrated
detector observations, dual traces, spatial grids, Pending CV/QND bookkeeping,
and a typed runtime trace boundary. It does not establish measured hardware
performance, quantum operator behavior, or a complete Rust/WASM runtime.

## Evidence Clusters

### CV Homodyne and Quadratures

The source describes homodyne detection as continuous-variable quadrature
measurement using semiconductor photodiodes, especially for squeezed states
([CV architecture](chats/_Superconductivity%20vs.%20QAHE%20in%20Quantum%20Computing%20.myst.md),
line 239; [CV comparison](chats/is-superconductivity-any-more-useful-for-qc-than-qahe.myst.md),
line 246). The primary IQ discussion defines the local oscillator, 50:50 optical
mixing, differential photocurrent, and a rotated quadrature selected by
local-oscillator phase (the [quadrature measurement](chats/IQ-Sampling-for-Signal-Phase.myst.md),
line 825). It also distinguishes the non-commuting quantum quadrature
operators and their uncertainty relation (the [quantum limit](chats/IQ-Sampling-for-Signal-Phase.myst.md),
line 839).

The outward context also connects the detector to CV squeezed states, TMSV
resources, and local-oscillator phase settings. Those state and operator
claims require a separate Pending layer; the verified detector layer should
remain a finite classical amplitude/current model.

### Dispersive QND Readout

The source proposes a signal bus, a probe bus, cross-phase modulation, and a
probe phase measurement intended to preserve the primary signal. The balanced
readout is described as probe/LO mixing followed by two detector outputs and a
current proportional to phase ([dispersive readout](chats/IQ-Sampling-for-Signal-Phase.myst.md),
line 9497). The associated integrated architecture describes balanced homodyne
detection and a nondestructive dispersive parity measurement ([integrated
readout](chats/IQ-Sampling-for-Signal-Phase.myst.md), line 9365).

The source further describes a signal soliton, a probe bus, a Kerr interaction
zone, and a probe phase that is intended to encode parity while preserving the
signal ([QND architecture](chats/IQ-Sampling-for-Signal-Phase.myst.md),
lines 9493-9513). These are model interfaces and experimental requirements,
not proofs that a Kerr interaction, parity coupling, or QND measurement exists.

### Dual Homodyne and CV Correlations

The Bell-correlation material adds two balanced homodyne receivers with
independently selected local-oscillator phases, continuous quadrature outcomes,
sign binning, covariance statistics, and a CHSH analysis
([dual BHD context](chats/Bell-Correlations-in-Atomic-Momentum.myst.md),
lines 2396-2459). Its teleportation section adds a 50:50 Bell-state beam
splitter, dual quadrature measurements, continuous feed-forward currents, and a
phase-space displacement step ([CV teleportation](chats/Bell-Correlations-in-Atomic-Momentum.myst.md),
lines 2556-2606).

The plan should represent the finite measurement plumbing in the verified
layer, while keeping TMSV preparation, entanglement, Wigner negativity, Bell
violation, and teleportation fidelity as Pending state or experiment contracts.

### Detector Noise and Common-Mode Rejection

The same source proposes detector-channel imbalance, shot noise, dark current,
electronic noise, local-oscillator relative-intensity-noise leakage, CMRR, and
frequency-dependent noise figure ([BHD noise model](chats/Bell-Correlations-in-Atomic-Momentum.myst.md),
lines 2676-2721). These requirements are concrete measurement and calibration
surfaces and should not be hidden behind an unqualified “photocurrent is
proportional to phase” assertion.

### Spatial Coherent Sensing

The wavefield-camera section extends single-mode homodyne detection to a
spatial optical mixing matrix and per-pixel I/Q reconstruction
([coherent wavefield camera](chats/IQ-Sampling-for-Signal-Phase.myst.md),
line 887).
This is a separate finite-array requirement from the single-channel detector.

### Squeezed-State and Integrated Hardware

The returned documents connect homodyne detection with squeezed-state readout,
feedback loops, detector replacement, insertion loss, and integrated material
stacks ([momentum-entanglement review](chats/Bell-Correlations-in-Atomic-Momentum.myst.md),
line 174; [integrated sensor topology](chats/Lignin-Vitrimer-Surface-Roughness-Limits.myst.md),
line 120).
These are hardware and measurement claims, not consequences of the current
finite algebra.

The returned analog-pipeline document also proposes a Rust/WASM/WebGPU path for
ingesting continuous homodyne arrays, calibrating them, and processing
covariance tensors ([Rust/WASM pipeline](chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md),
lines 402-446). This is a runtime integration concern and must consume a stable,
calibrated trace format rather than establish the underlying physics.

### Speculative Analog-Gravity Use

One result uses homodyne sensors to read nonlinear analog Hawking emission
([analog-gravity pipeline](chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md),
line 115).
This use must remain isolated in `Signals.Pending`; a homodyne record cannot
establish an analog-gravity interpretation.

## Search Match Inventory

The current YAML search returned these ranked results. All ten had
`source_location: null`; the fallback lines below come from outward review of
the corresponding `source_uri` files.

1. `_Superconductivity vs. QAHE in Quantum Computing .myst.md`, title
  “How A2Q Materials Power the CV Path”; fallback CV detector context at
  line 239.
2. `IQ-Sampling-for-Signal-Phase.myst.md`, title “Response: 97”; fallback
  architecture and formal-core context at lines 9401-9415 and 9618-9621.
3. `IQ-Sampling-for-Signal-Phase.myst.md`, title “3. Fedora Silverblue &
  Ansiblers OS Integration”; fallback runtime/orchestration context at lines
  9560-9577.
4. `is-superconductivity-any-more-useful-for-qc-than-qahe.myst.md`, title
  “How A2Q Materials Power the CV Path”; fallback CV detector and feedback
  context at lines 246 and 329.
5. `IQ-Sampling-for-Signal-Phase.myst.md`, title “3. Rust Implementation:
  iQFT Demodulation Loop”; fallback homodyne expectation-value context at
  line 1444.
6. `Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md`, title “The
  Ultimate Theoretical Pipeline”; fallback phase-sweep and GPU-pipeline
  context at lines 2438-2471 and 402-446.
7. `IQ-Sampling-for-Signal-Phase.myst.md`, title “Response: 95”; fallback
  integrated BHD/QND context at lines 9330-9366.
8. `Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md`, title matching
  the full chat; fallback analog-gravity homodyne context at lines 374-380
  and 991.
9. Rendered HTML for `_Superconductivity vs. QAHE in Quantum Computing`; this
  duplicates the CV detection-stack material, whose MyST source is cited at
  line 239.
10. `Bell-Correlations-in-Atomic-Momentum.myst.md`, title “Platform Comparison:
   Quantum Dots vs. Continuous-Variable Squeezing”; fallback BHD, dual
   quadrature, and detector-noise context at lines 2365-2437, 2556-2606, and
   2676-2721.

The controlling primary-IQ passages are the literal homodyne sections around
lines 821-855, 876-935, 9359-9366, and 9487-9553. The quantum-homodyne query
also requires the Bell-correlation and runtime passages listed above; they are
not covered by the earlier single-channel plan alone.

### Context Review by Requirement

The grep-style outward review maps the search results to these requirements:

- **Single BHD:** local oscillator, 50:50 mixing, detector difference, and
  quadrature-angle selection ([primary quadrature context](chats/IQ-Sampling-for-Signal-Phase.myst.md),
  lines 821-855).
- **Spatial BHD:** optical hybrid, per-pixel I/Q, phase-to-height conversion,
  and speckle/phase stability ([wavefield-camera context](chats/IQ-Sampling-for-Signal-Phase.myst.md),
  lines 876-935).
- **Dispersive QND:** signal/probe buses, Kerr cross-phase, signal preservation,
  and parity readout ([QND context](chats/IQ-Sampling-for-Signal-Phase.myst.md),
  lines 9487-9553).
- **Dual BHD:** two LO settings, continuous quadrature outcomes, sign-binning,
  covariance, and CHSH statistics ([dual-BHD context](chats/Bell-Correlations-in-Atomic-Momentum.myst.md),
  lines 2396-2534).
- **CV teleportation:** dual homodyne Bell-state measurement and classical
  feed-forward ([teleportation context](chats/Bell-Correlations-in-Atomic-Momentum.myst.md),
  lines 2556-2606).
- **Noise and calibration:** detector mismatch, dark current, shot noise,
  electronic noise, RIN, CMRR, and bandwidth ([noise context](chats/Bell-Correlations-in-Atomic-Momentum.myst.md),
  lines 2676-2721).
- **Runtime:** calibrated homodyne data flowing through Rust/WASM, SharedArrayBuffer,
  WebGPU staging, and WGSL processing ([runtime context](chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md),
  lines 402-446).
- **Speculative boundary:** analog-gravity homodyne sensing and material claims
  remain Pending and cannot be inferred from a detector trace ([analog-gravity
  context](chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md),
  lines 374-380).

## Current Coverage

The existing verified library covers:

- Classical I/Q samples, magnitude, phase, and quadrature orientation in
  [Signals.IQ](../src/signals/Signals/IQ.lean).
- Signal-state preservation and signal-energy preservation in
  [NonDestructive](../src/signals/Signals/NonDestructive.lean#L95).
- Target and signal zero-absorption assumptions, plus a probe phase response.
- Composition between a phase fingerprint and a dispersive readout in
  [NonDestructive](../src/signals/Signals/NonDestructive.lean#L153).
- Affine calibration with raw-telemetry preservation.
- Typed vitrimer operations and operation-power accounting.
- Finite classical homodyne algebra, typed detector/noise/calibration records,
  dual trace statistics, spatial grids, and typed runtime trace samples in
  [Homodyne](../src/signals/Signals/Homodyne.lean).
- Pending OAM parity preservation over a dispersive readout in
  [Pending](../src/signals/Signals/Pending.lean#L203).
- Pending quadrature uncertainty assumptions, TMSV variance bookkeeping,
  CV Bell-state/feed-forward plumbing, QND evidence bounds, and integrated
  hardware-readiness observations in [Pending](../src/signals/Signals/Pending.lean).
- Pending Kerr interaction data for nonlinear signal/probe phase coupling in
  [Pending](../src/signals/Signals/Pending.lean).
- Pending Kerr interaction data for nonlinear signal/probe phase coupling in
  [Pending](../src/signals/Signals/Pending.lean).
- Compile-time fixtures for these contracts in
  [SignalsTests](../src/signals/SignalsTests.lean#L805) and
  [SignalsPendingTests](../src/signals/SignalsPendingTests.lean#L792).

The current build is a compiling baseline containing explicit local-oscillator,
beam-splitter, detector-pair, differential-current, dual-receiver, spatial-grid,
calibration/noise, and runtime-trace records. The existing `Signals.IQ` sample
remains the classical baseband representation; the Pending layer contains
quantum quadrature and CV-state assumptions rather than verified operator
semantics.

## Remaining Gaps

The following source requirements remain beyond the current finite bookkeeping
implementation:

- Measured detector-loss, repeatability, disturbance, and frequency-dependent
  noise observations.
- Physical Kerr-cavity calibration and experimentally validated cross-phase
  coupling. The Pending `KerrInteraction` record is only the supplied finite
  coupling interface.
- Quantum operator semantics, detector backaction, and validated squeezing or
  entanglement measurements.
- Runtime Rust/WASM demodulation, tensor processing, and visualization
  integration against the typed trace boundary.
- A Linux- and YAML-oriented orchestration implementation that does not couple
  the project to a particular distro or configuration management tool.

`absorbedProbeEnergy` is now typed as `Energy` and proves zero joules. The
remaining non-absorption gap is measured detector and system loss rather than
the dimensional type of the probe field.

The source corpus also contains numerical claims about room-temperature
operation, detector efficiency, CMRR, bandwidth, squeezing, CHSH violation,
teleportation fidelity, and material performance. These values must enter the
library as measured observations or explicit Pending assumptions; they must not
be derived from the existence of a homodyne record.

## Implementation Plan

### Phase 1: Correct Energy Semantics

1. [Complete] Change `absorbedProbeEnergy : Power` to `absorbedProbeEnergy : Energy`.
2. [Complete] Update the accessor, verified/Pending fixtures, and compile-time
  regression for zero absorbed probe energy in joules.
3. [Complete] Rebuild before beginning the next phase.

### Phase 2: Add a Classical Homodyne Module

[Complete] Create `Signals.Homodyne` and reuse
`Signals.IQ.Sample` instead of introducing a second I/Q representation.

Implemented records:

- local-oscillator amplitude and phase;
- balanced 50:50 beam-splitter inputs and outputs using an explicit sign and
  normalization convention;
- detector efficiency and responsivity;
- positive and negative detector outputs;
- differential photocurrent, common-mode output, and rotated-quadrature
  selection.

Proved finite algebraic laws for:

- beam-splitter energy conservation;
- balanced output symmetry;
- common-mode local-oscillator cancellation in the differential current;
- dependence on the selected quadrature angle;
- consistency with the existing I/Q phase convention.

Keep this module classical and finite. Do not encode quantum operator claims as
ordinary real-valued I/Q fields. [Complete finite algebra]

### Phase 3: Add Calibrated Detector Observations

[Complete finite bookkeeping] Introduce typed current and noise wrappers where
they fit the existing unit style. Represent:

- raw detector currents;
- dark-current offsets;
- detector efficiency;
- shot-noise and electronic-noise bounds;
- local-oscillator relative-intensity noise and common-mode rejection ratio;
- detector bandwidth;
- channel responsivity mismatch and beam-splitter imbalance;
- calibrated differential current;
- measured-versus-predicted residuals.

Reuse the existing affine `CalibrationRecord` for gain and offset. Require
explicit residual tolerances instead of using an unqualified proportionality
claim. Measured frequency-bin or time-window
observations and power spectral density formulas remain.

### Phase 4: Compose Dispersive Readout with Homodyne Detection

[Complete] Add a composition record linking:

- the signal state;
- the signal and probe energy records;
- the probe phase shift;
- the local oscillator;
- the beam splitter;
- the two detector outputs;
- the calibrated differential current.

Retain the existing phase-shift law as the classical interface. Add a separate
Pending `KerrInteraction` record for nonlinear susceptibility, interaction
length, probe phase response, signal preservation, and the supplied signal
observable. [Complete Pending interface]

A nonzero phase shift must not be treated as proof of Kerr coupling without
measured calibration.

### Phase 5: Add Dual Homodyne and CV Correlation Records

[Complete finite bookkeeping] Add a dual-receiver composition for the
Bell-correlation material. It records:

- two signal modes and their local-oscillator phases;
- two balanced detector outputs per receiver;
- continuous quadrature outcomes;
- finite covariance and correlation estimators;
- sign-binning thresholds and dichotomic outcomes;
- sample counts, missing samples, and residual tolerance metadata.

The implementation proves only finite data-structure and estimator laws in the
verified layer. TMSV preparation, entanglement, Wigner negativity, DGCZ
witnesses, CHSH violation, and any claimed optimum remain in `Signals.Pending`.
[Complete finite bookkeeping; measured correlation analysis remains]

### Phase 6: Strengthen the Pending QND Boundary

[Complete Pending bookkeeping] Extend `QuantumNonDemolitionParity` with explicit
records for:

- detector loss;
- repeated-readout agreement;
- measured signal disturbance;
- parity-classification residual;
- absorption measurement.

Keep no-backaction, repeatability, and QND behavior Pending. Add accessors that
expose observations without turning fixture equalities into physical theorems.

### Phase 7: Model Quantum Quadrature Assumptions Separately

[Complete Pending bookkeeping] Add a separate Pending quadrature record
for:

- quadrature variances;
- commutation assumptions;
- uncertainty bounds;
- squeezing parameters;
- detector and state assumptions.

Do not merge these assumptions into the verified classical homodyne module.

### Phase 8: Cover CV Bell-State Measurement and Teleportation Plumbing

[Complete Pending bookkeeping] Represent the finite protocol plumbing described
by the CV teleportation
context:

- input mode and entangled resource mode;
- 50:50 Bell-state beam splitter;
- dual homodyne outcomes for the orthogonal quadratures;
- continuous classical feed-forward values;
- phase-space displacement parameters;
- loss, gain, and finite-squeezing noise terms.

Keep resource generation, teleportation fidelity, non-Gaussian state claims,
and classical-bound comparisons as Pending or measured-result records. A
protocol record must not imply that a material platform produces TMSV states or
room-temperature quantum efficiency.

### Phase 9: Cover Spatial Homodyne Sensing

[Complete finite bookkeeping] Add a finite detector-grid or pixel-array record.
It explicitly models:

- shared or per-pixel local-oscillator phase;
- pixel detector outputs;
- finite indexing and dimensions;
- I/Q reconstruction;
- aggregation or map-level residuals.

Connect pixel I/Q samples to the existing phase-to-height and scattering models
only through explicit finite interfaces.

### Phase 10: Keep Integrated Hardware Claims Pending

[Complete Pending bookkeeping] Add a hardware-readiness record for:

- insertion loss;
- beam-splitter balance;
- detector bandwidth;
- thermal load;
- material response;
- mode overlap;
- calibration status.

Reuse existing antenna and dielectric records where possible. Keep N-LIG,
vitrimer, squeezed-state, and room-temperature performance claims conditional
on measured observations.

### Phase 11: Define the Rust/WASM Boundary

[Partially complete] Treat the Rust iQFT demodulation and visualization references
as a runtime layer
separate from the Lean verification target.

The stable trace format is implemented as `HomodyneTraceSample`. It contains:

- timestamp;
- local-oscillator phase;
- detector A and B currents;
- calibrated differential current;
- residual;
- loss and efficiency metadata.

Add golden vectors generated from the Lean homodyne equations. Validate the Rust
implementation against those vectors, then add WASM compilation and browser
checks independently from the Lean build. Use Linux as the supported host
boundary and YAML playbooks as an optional declarative input; do not encode a
Fedora Silverblue, `rpm-ostree`, or external Ansiblers dependency in the core
model.

## Acceptance Criteria

Full coverage means:

- Every technical homodyne requirement from the returned documents maps to a
  typed record, theorem, fixture, or explicitly Pending hypothesis. The finite
  apparatus and bookkeeping portions below are implemented; measured and
  external-runtime validation remain.
- Balanced mixing and differential photocurrent are executable compile-time
  models.
- Single- and dual-receiver local-oscillator phase selection, quadrature
  outcomes, finite covariance, and sign-binning are represented.
- CV Bell-state measurement and feed-forward bookkeeping are represented
  without asserting teleportation fidelity or entanglement generation.
- Detector noise, efficiency, calibration, and loss are represented as
  observations rather than silently assumed away.
- Channel mismatch, CMRR, RIN leakage, bandwidth, and residual conventions are
  dimensioned or explicitly labeled as calibration data.
- QND, squeezed-state, material, and analog-gravity interpretations remain
  conditional.
- `absorbedProbeEnergy` is dimensionally an `Energy` with a joule-based
  invariant. [Complete]
- `make -C /workspaces/sustainablefactory signals_build` passes.
- `get_errors` reports no issues in touched files.
- `git diff --check` passes.
- Documentation links each model boundary to the relevant chat evidence.

## Recommended Execution Order

1. [Complete] Correct the probe-energy type and update fixtures.
2. [Complete] Add the classical balanced-homodyne algebra and compile-time tests.
3. [Complete finite bookkeeping] Add detector calibration, loss, noise, CMRR,
  and residual records.
4. [Complete] Compose the detector with the dispersive phase-readout record.
5. [Complete finite bookkeeping] Add dual-receiver covariance and sign-binning
  plumbing.
6. [Complete Pending bookkeeping] Add CV Bell-state measurement and feed-forward
  bookkeeping.
7. [Complete Pending bookkeeping] Strengthen the Pending QND parity boundary.
8. [Complete Pending bookkeeping] Add Pending quantum quadrature assumptions
  and finite spatial arrays.
9. [Complete Pending bookkeeping] Add hardware-readiness observations.
10. Next: define Lean-generated golden vectors and validate Rust/WASM consumers.
11. Next: add measured detector-loss, repeatability, disturbance, and
   frequency-dependent noise observations.
12. [Complete] Update the Signals README and contributor guidance after each
  completed phase.

Each phase should make the smallest testable change, run
`make -C /workspaces/sustainablefactory signals_build`, and record whether the
new statement is verified algebra, a measured observation contract, or a
Pending physical hypothesis.
