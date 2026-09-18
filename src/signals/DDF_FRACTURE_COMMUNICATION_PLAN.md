# DDF Fracture-Communication Validation Plan

## Scope

This plan replaces the earlier SQG-centered interpretation with a conditional
Dilatant Dark Fluid (DDF) hypothesis. It does not promote DDF from a formal
model to an established physical medium.

The relevant formal boundary is [`Signals/DDF.lean`](Signals/DDF.lean):

- the continuous `phi` phase carries persistent vortex pressure/enthalpy
  deficits;
- the dispersed `varphi` phase supplies a saturated transverse-phonon speed
  `c`;
- the DDF active-radiation discriminator sets `eta_act^gamma = 0` rather than
  importing the GR value `1`;
- the current module does not define a fracture evolution law, an interface
  transmission operator, a detector coupling, or a faster-than-light channel.

The finite trace and acoustic boundaries remain in
[`Signals/Pending.lean`](Signals/Pending.lean), and the numerical handoff is
specified in [`RUST_NUMERICAL_ADAPTER_SPEC.md`](RUST_NUMERICAL_ADAPTER_SPEC.md).

The Lean Pending boundary now includes `DDFCommunicationMode` and
`DDFFractureCommunicationEvidence`. Its support predicate requires an
independent defect proposition and detectable defect observable, a classical
residual outside tolerance, nonzero coupling, a causal transverse-phonon mode,
replication, held-out agreement, and an energy-closure premise. This is a
typed contract over supplied premises, not a measurement or DDF existence
theorem.

## Updated Hypotheses

### Summary
The revised model is:

- `H0`: ordinary calibrated acoustic, elastic, optical, detector, and environmental effects explain the signal.
- `HDDF`: an additional reproducible term exists, tied to an independently measured DDF defect, pressure/enthalpy deficit, phase winding, or transverse-mode signature.
- DDF propagation remains causal at the declared transverse-phonon speed. FTL, SQG-current, or longitudinal-Proca results reject this DDF model rather than confirm it.
- The active-radiation null test is separate and cannot establish fracture communication.

This plan covers classical calibration, PIV/JHTDB flow maps, weak trace/jump controls, mode and arrival-time analysis, blinded waveform transmission, conservation accounting, replication, and explicit rejection criteria.


### Classical null hypothesis

`H0` states that every observed signal is explained by the ordinary calibrated
source, medium, instrument, and environment:

\[
y(t) = y_{\mathrm{classical}}(t; \theta) + \epsilon(t).
\]

The classical model must include acoustic/elastic transfer, optical or
radio-link response, detector response, clock synchronization, environmental
backgrounds, missing-data handling, and an input/output energy ledger.

### DDF extension hypothesis

`HDDF` states that a persistent DDF vortex or a fracture-like discontinuity in
the DDF substrate contributes an additional, reproducible perturbation to the
ordinary channel:

\[
y(t) = y_{\mathrm{classical}}(t; \theta)
      + \kappa_{\mathrm{DDF}} q_{\mathrm{DDF}}(t; \psi)
      + \epsilon(t),
\]

where `q_DDF` is not a free residual. It must be tied to independently measured
or solver-supplied defect geometry, pressure/enthalpy deficit, transverse-mode
content, and propagation path. The coupling `kappa_DDF`, phase, attenuation,
and uncertainty must be estimated before the model is compared with `H0`.

The first DDF-compatible prediction is **ordinary causal propagation at the
emergent transverse-phonon speed `c`**, not FTL communication. A result that
requires superluminal information transport, a longitudinal massive photon, or
an SQG current is outside this DDF model and rejects the present hypothesis
rather than confirming it.

### Separate discriminator hypothesis

`HDDF-active-null` is the crossed-radiation test already represented by the DDF
model: freely propagating, non-co-propagating radiation has no active
DDF-gravitational sourcing (`eta_act^gamma = 0`). This is a separate
measurement. It must not be used as evidence for a fracture channel, and a null
beam-deflection result does not establish substrate fracture or communication.

### Excluded substitutions

- SQG current terms are not silently relabeled as DDF.
- Proca longitudinal-mode claims require a separate frequency, polarization,
  mass, coupling, and power/loss contract.
- A nonzero weak trace jump, FTLE ridge, or acoustic residual is not a DDF
  defect diagnosis.
- A fitted residual is not `q_DDF` until a mechanism-specific observable is
  specified.

### DDF observables and the Magnus control

The current DDF formalization and paper summary expose candidate observables:
quantized circulation, Bernoulli pressure/enthalpy deficit, radial river
inflow, swirl velocity, the emergent transverse-phonon speed, and the separate
active-radiation null. The local workspace does not contain the cited SSRN PDF,
so these are treated as model/API observables until the appendix source is
available for page-level verification.

The inflow Magnus effect is a classical control, not a DDF observable. With a
declared circulation sign convention, the first control law is the
Kutta-Joukowski relation per unit span:

\[
L'_{\mathrm{classical}} = \rho U \Gamma.
\]

An observed lift or transverse drift explained by this relation belongs to
`H0`. A DDF candidate requires a residual after this control, an independent
circulation/pressure/defect measurement, causal transverse-mode propagation,
and replication. It is invalid to relabel ordinary Magnus lift as DDF
coupling, and the current DDF paper formalization does not itself claim a
Magnus law.

## What Each Analysis Can Establish

| Analysis | Positive result can establish | It cannot establish by itself |
| --- | --- | --- |
| Calibrated acoustic/elastic transfer | Ordinary channel response and residuals | DDF, fracture, or a new carrier |
| PIV/LDV velocity and pressure data | Measured flow field, masks, gradients, and uncertainty | A DDF substrate or pressure deficit |
| JHTDB velocity/pressure/gradient query | Solver-produced flow and interpolation sensitivity | Experimental validation or a full-domain flow map |
| Particle advection and FTLE/LCS | Finite transport structures and flow-map deformation | Fractures, causal interfaces, or DDF coupling |
| Weak trace/jump residual | Consistency with a declared interface law | Crack evolution or physical fracture |
| Spectral/polarization mode analysis | Classical mode content and residual coupling | A massive longitudinal mode without a matched control |
| Crossed-beam deflection | Test of active radiation sourcing | Communication through a fracture |
| Energy/momentum accounting | Whether the measured result closes classically | DDF energy extraction |
| Blinded encoded waveform test | Reproducible channel information transfer | FTL or DDF without causal and mechanism controls |

## Dataset Roles

The source-specific attribution and file identities are maintained in
[`OPEN_FLOW_DATASETS.md`](OPEN_FLOW_DATASETS.md).

1. **JHTDB channel probe:** solver-produced 3D velocity, pressure, and velocity
   gradients. Use it first for interpolation checks, gradient consistency,
   particle-advection prototypes, and a bounded FTLE pipeline. The testing token
   is limited to at most 4096 spatial points per request; the current probe is
   not a full-domain validation.
2. **Zenodo cylinder PIV:** measured 2D `u/v/x/y` at 20 Hz and Re=413. Use it
   for the first measured flow-map/FTLE adapter, missing-mask propagation, and
   measured-versus-solver comparison. It has no pressure, density, or 3D
   velocity.
3. **RSPID:** synthetic particle images with known flow families and validation
   files. Use it as a positive-control suite for PIV reconstruction, image
   noise, displacement, out-of-plane effects, and missing vectors. It is not
   physical evidence.
4. **MorphoDunes:** compact measured `uPIV/vPIV` spatial fields with NaNs and
   bed-coordinate data. Use it for measured spatial statistics and missing-mask
   controls unless an external run record supplies a valid time axis.
5. **PDEBench Sod6:** solver-produced parser/provenance fixture only. Its zero
   `Vx` field and coordinate discrepancy do not support a resolved FTLE field.

## Staged Work Plan

### Stage 0: Preregister the claim boundary

Record the source, detector, channel geometry, clocks, units, calibration,
control conditions, primary endpoint, exclusion rules, and stopping rule before
looking at the proposed residual. Define `H0`, `HDDF`, and the classical
positive/negative controls separately.

### Stage 1: Establish the classical channel

Measure or ingest synchronized source and receiver traces. Fit the ordinary
acoustic/elastic/optical model, including transfer functions, attenuation,
reflection, detector noise, environmental drift, and missing-value masks. Require
held-out prediction and repeatability before inspecting DDF residuals.

### Stage 2: Build the flow-map diagnostic

Use the JHTDB probe to validate the array and gradient path. Then ingest a
bounded cylinder-PIV time sequence. Record spatial interpolation, temporal
interpolation, trajectory integrator, seed spacing, time window, deformation
estimator, and convergence/sensitivity results. Treat FTLE ridges as transport
features only.

### Stage 3: Test discontinuity and defect observables

Specify the interface normal, one-sided traces, flux pairing, and jump law.
Compare the trace/jump residual with positive and negative classical controls.
For a DDF interpretation, add an independent defect observable: vortex
circulation, pressure/enthalpy deficit, phase winding, or a calibrated
transverse-mode signature. Do not infer this observable from the communication
residual itself.

Before interpreting inflow-induced transverse force, fit the classical Magnus
control with density, inflow speed, signed circulation, lift-per-span, and
calibrated uncertainty. The `MagnusEffectControl` record in
`Signals.Pending` preserves this law and its residual separately from
`DDFVortexObservable`.

### Stage 4: Test DDF mode and causality predictions

Measure polarization/mode content, arrival time, dispersion, attenuation, and
path-length scaling. The DDF-compatible prediction is a causal transverse
mode with speed bounded by the declared emergent `c`; the control model predicts
ordinary acoustic/elastic or electromagnetic propagation. Any FTL claim is a
failure of the present DDF model, not a confirmation.

Run the crossed-radiation active-source test as a separate preregistered
experiment. A null result supports only the active-radiation discriminator and
must not be folded into the fracture-channel likelihood without a declared
coupling model.

### Stage 5: Information-channel and conservation tests

Transmit blinded, independently generated symbols. Compare receiver decoding
against a conventional channel with the same clocks, bandwidth, exposure,
shielding, and detector path. Report bit error rate, latency, mutual
information, false-positive rate, and run-to-run stability. Close mass,
momentum, and energy accounting, including pump, actuator, detector, and
auxiliary power.

### Stage 6: Independent replication and promotion decision

Repeat with a new artifact or laboratory setup, a negative control, a classical
positive control, and a held-out waveform. Promote only a conditional DDF
interface if the extra term remains after classical calibration, tracks the
independent defect observable, has the predicted mode/speed/attenuation law,
replicates, and closes conservation. Otherwise classify the result as classical,
anomaly candidate, inconclusive, or rejected.

## Rejection Criteria

Reject the current `HDDF` hypothesis when any necessary condition fails:

- the apparent signal is predicted by the calibrated classical model;
- the effect disappears under a blinded or negative control;
- no independent defect observable correlates with the effect;
- the inferred propagation requires superluminal information or an unsupported
  longitudinal massive mode;
- the fitted coupling changes with detector, interpolation, mask, or clock
  settings rather than physical source parameters;
- the energy or momentum ledger does not close;
- the result fails an independent replication or held-out waveform test.

A failure of one dataset to contain a time axis, pressure, density, or 3D field
is **inconclusive**, not evidence against DDF. A failure of the complete
pre-registered test after those fields and controls are present is evidence
against the hypothesis.

## Next Implementation Loops

1. Add a MATLAB reader for the measured cylinder PIV artifact with `u/v/x/y`,
   20 Hz metadata, NaN/mask preservation, MD5/SHA-256 verification, and a
   bounded time-window selector.
2. Add one RSPID validation subset reader for paired images, generator
   parameters, validation fields, and reconstruction-error summaries.
3. Convert the bounded JHTDB NPZ probe to the common field-summary contract and
   add particle advection/gradient consistency checks before requesting a cutout.
4. Add a flow-map/FTLE result contract with interpolation, seed, window, and
   convergence metadata; keep it separate from fracture evidence.
5. [Complete, contract boundary] Add the DDF-specific defect/mode contract;
   populate it only after an independent observable and a classical control are
   available.
