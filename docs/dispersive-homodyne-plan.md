# Dispersive Homodyne Coverage and Implementation Plan

**Status:** Audit complete; implementation plan ready

**Scope:** Verify and fully cover the dispersive-homodyne material found by
`docindex search homodyne` in the Signals library, its documentation, and any
future Rust/WASM integration.

## Audit Result

`docindex search homodyne` returned 10 ranked YAML results covering 9 unique
chat documents. Several `source_location` values point to an indexed
table-of-contents or chunk location rather than the literal match. The search
results are therefore useful for discovery, while the direct source passages
below are the evidence locations for implementation decisions.

The current Signals coverage is **partial**. It models a guarded dispersive
phase response and preservation assumptions, but it does not yet model a
complete balanced homodyne detector.

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

### Dispersive QND Readout

The source proposes a signal bus, a probe bus, cross-phase modulation, and a
probe phase measurement intended to preserve the primary signal. The balanced
readout is described as probe/LO mixing followed by two detector outputs and a
current proportional to phase ([dispersive readout](chats/IQ-Sampling-for-Signal-Phase.myst.md),
line 9497). The associated integrated architecture describes balanced homodyne
detection and a nondestructive dispersive parity measurement ([integrated
readout](chats/IQ-Sampling-for-Signal-Phase.myst.md), line 9365).

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

### Speculative Analog-Gravity Use

One result uses homodyne sensors to read nonlinear analog Hawking emission
([analog-gravity pipeline](chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md),
line 115).
This use must remain isolated in `Signals.Pending`; a homodyne record cannot
establish an analog-gravity interpretation.

## Search Match Inventory

The YAML search returned these ranked source locations:

1. `_Superconductivity vs. QAHE in Quantum Computing .myst.md:239:7`
2. `IQ-Sampling-for-Signal-Phase.myst.md:26:9` for the response and architecture chunks
3. `IQ-Sampling-for-Signal-Phase.myst.md:26:9` for the OS-integration chunk
4. `Bell-Correlations-in-Atomic-Momentum.myst.md:174:58`
5. `is-superconductivity-any-more-useful-for-qc-than-qahe.myst.md:246:7`
6. `IQ-Sampling-for-Signal-Phase.myst.md:26:9` for the coherent wavefield-camera chunk
7. `IQ-Sampling-for-Signal-Phase.myst.md:26:9` for the Rust demodulation chunk
8. `Superfluid-Quantum-Gravity-and-Hawking-Radiation.myst.md:115:35`
9. `IQ-Sampling-for-Signal-Phase.myst.md:26:9` for the homodyne-camera comparison chunk
10. `Lignin-Vitrimer-Surface-Roughness-Limits.myst.md:120:20`

The direct homodyne occurrences around lines 825, 887, 9365, and 9497 in the
primary IQ document are the controlling technical passages. The indexed line
26 locations should not be treated as exact literal-match locations.

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
- Pending OAM parity preservation over a dispersive readout in
  [Pending](../src/signals/Signals/Pending.lean#L203).
- Compile-time fixtures for these contracts in
  [SignalsTests](../src/signals/SignalsTests.lean#L805) and
  [SignalsPendingTests](../src/signals/SignalsPendingTests.lean#L792).

The current build is a compiling baseline, but it does not yet contain an
explicit local oscillator, beam splitter, detector pair, differential current,
quadrature-angle readout, or detector-noise model.

## Coverage Gaps

The following source requirements are not yet represented as typed verified
records or explicitly Pending hypotheses:

- A local-oscillator amplitude and phase record.
- A 50:50 beam-splitter transformation.
- Two detector outputs and a differential photocurrent.
- The rotated-quadrature law
  `$X_\theta = X_1 \cos(\theta) + X_2 \sin(\theta)$`.
- Detector efficiency, dark current, shot noise, electronic noise, and
  bandwidth.
- Calibrated differential-current observations and residual bounds.
- Spatial detector arrays and per-pixel homodyne reconstruction.
- Kerr-cavity or cross-phase interaction parameters.
- QND repeatability, detector loss, and measured disturbance.
- Quantum commutation and uncertainty assumptions.
- Runtime Rust/WASM demodulation and visualization integration.

There is also a dimensional issue in the current dispersive record:
`absorbedProbeEnergy` is typed as `Power` and proves zero watts. If the claim is
zero absorbed probe energy, it must use `Energy` and prove zero joules.

## Implementation Plan

### Phase 1: Correct Energy Semantics

1. Change `absorbedProbeEnergy : Power` to `absorbedProbeEnergy : Energy`.
2. Rename the accessor if needed so the joule-based invariant is unambiguous.
3. Update verified and Pending fixtures.
4. Add a compile-time regression proving zero absorbed probe energy in joules.
5. Rebuild before beginning the next phase.

### Phase 2: Add a Classical Homodyne Module

Create `Signals.Homodyne` or `Signals.Detection` and reuse
`Signals.IQ.Sample` instead of introducing a second I/Q representation.

Add records for:

- local-oscillator amplitude and phase;
- balanced 50:50 beam-splitter inputs and outputs;
- detector efficiency and responsivity;
- positive and negative detector outputs;
- differential photocurrent.

Prove finite algebraic laws for:

- beam-splitter energy conservation;
- balanced output symmetry;
- common-mode local-oscillator cancellation in the differential current;
- dependence on the selected quadrature angle;
- consistency with the existing I/Q phase convention.

Keep this module classical and finite. Do not encode quantum operator claims as
ordinary real-valued I/Q fields.

### Phase 3: Add Calibrated Detector Observations

Introduce typed current and noise wrappers where they fit the existing unit
style. Represent:

- raw detector currents;
- dark-current offsets;
- detector efficiency;
- shot-noise and electronic-noise bounds;
- detector bandwidth;
- calibrated differential current;
- measured-versus-predicted residuals.

Reuse the existing affine `CalibrationRecord` for gain and offset. Require
explicit residual tolerances instead of using an unqualified proportionality
claim.

### Phase 4: Compose Dispersive Readout with Homodyne Detection

Add a composition record linking:

- the signal state;
- the signal and probe energy records;
- the probe phase shift;
- the local oscillator;
- the beam splitter;
- the two detector outputs;
- the calibrated differential current.

Retain the existing phase-shift law as the classical interface. Add a separate
Pending Kerr-interaction record for nonlinear susceptibility, interaction
length, probe phase response, and the supplied signal observable.

A nonzero phase shift must not be treated as proof of Kerr coupling without
measured calibration.

### Phase 5: Strengthen the Pending QND Boundary

Extend `QuantumNonDemolitionParity` with explicit records for:

- detector loss;
- repeated-readout agreement;
- measured signal disturbance;
- parity-classification residual;
- absorption measurement.

Keep no-backaction, repeatability, and QND behavior Pending. Add accessors that
expose observations without turning fixture equalities into physical theorems.

### Phase 6: Model Quantum Quadrature Assumptions Separately

If quantum-level coverage is needed, add a separate Pending quadrature record
for:

- quadrature variances;
- commutation assumptions;
- uncertainty bounds;
- squeezing parameters;
- detector and state assumptions.

Do not merge these assumptions into the verified classical homodyne module.

### Phase 7: Cover Spatial Homodyne Sensing

Add a finite detector-grid or pixel-array record. It should explicitly model:

- shared or per-pixel local-oscillator phase;
- pixel detector outputs;
- finite indexing and dimensions;
- I/Q reconstruction;
- aggregation or map-level residuals.

Connect pixel I/Q samples to the existing phase-to-height and scattering models
only through explicit finite interfaces.

### Phase 8: Keep Integrated Hardware Claims Pending

Add a hardware-readiness record for:

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

### Phase 9: Define the Rust/WASM Boundary

Treat the Rust iQFT demodulation and visualization references as a runtime layer
separate from the Lean verification target.

Define a stable trace format containing:

- timestamp;
- local-oscillator phase;
- detector A and B currents;
- calibrated differential current;
- residual;
- loss and efficiency metadata.

Add golden vectors generated from the Lean homodyne equations. Validate the Rust
implementation against those vectors, then add WASM compilation and browser
checks independently from the Lean build.

## Acceptance Criteria

Full coverage means:

- Every technical homodyne requirement from the returned documents maps to a
  typed record, theorem, fixture, or explicitly Pending hypothesis.
- Balanced mixing and differential photocurrent are executable compile-time
  models.
- Detector noise, efficiency, calibration, and loss are represented as
  observations rather than silently assumed away.
- QND, squeezed-state, material, and analog-gravity interpretations remain
  conditional.
- `absorbedProbeEnergy` is dimensionally an `Energy` with a joule-based
  invariant.
- `make -C /workspaces/sustainablefactory signals_build` passes.
- `get_errors` reports no issues in touched files.
- `git diff --check` passes.
- Documentation links each model boundary to the relevant chat evidence.

## Recommended Execution Order

1. Correct the probe-energy type and update fixtures.
2. Add the classical balanced-homodyne algebra and compile-time tests.
3. Add detector calibration, loss, noise, and residual records.
4. Compose the detector with the dispersive phase-readout record.
5. Strengthen the Pending QND parity boundary.
6. Add Pending quantum quadrature assumptions and finite spatial arrays.
7. Add hardware-readiness observations.
8. Define Lean-generated golden vectors for Rust/WASM consumers.
9. Update the Signals README and contributor guidance after each completed
   phase.

Each phase should make the smallest testable change, run
`make -C /workspaces/sustainablefactory signals_build`, and record whether the
new statement is verified algebra, a measured observation contract, or a
Pending physical hypothesis.
