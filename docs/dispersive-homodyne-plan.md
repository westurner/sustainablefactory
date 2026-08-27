# Dispersive Homodyne Coverage and Implementation Plan

**Status:** Implementation in progress; finite homodyne/CV bookkeeping and
Pending interfaces are implemented, including the finite Hawking-like
iGPE/iQFT/Amplituhedron/ALS decoding boundary, while Proca/QND wake
measurements, LVP device validation, M-gate validation, measured-data adapters,
and external runtime work remain.

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

### Hawking-like Decoding Chain: iGPE, iQFT, Amplituhedron, and ALS

The attached Hawking-radiation chat proposes a staged decoding story: a
prepared modulation $X(t)$ is measured as a scattered homodyne signal $Y(t)$,
then corrected with an inverse Gross-Pitaevskii step, phase-processed with an
iQFT, and passed to an Amplituhedron-constrained CANDECOMP/PARAFAC ALS
decomposition (source: `data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`,
lines 2451-2500). The same source describes homodyne phase sweeping for both
quadratures and an inverse Fourier routine before tensor decomposition (source:
`data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines
2390-2440). A later widget specification exposes ALS rank as a 1--10 control
and presents rank 2--3 or rank 2 near-zero reconstruction error as simulation
behavior, not as an experimental result (source:
`data/chats/Superfluid-Quantum-Gravity-and-Hawking-Radiation.md`, lines
2524-2540).

The Pending implementation now records the finite boundaries of that proposal:

- `PreparedModulation` preserves the known finite input trace.
- `ObservedHomodyneTensor` preserves finite $Y(x,y,t)$ data and exposes a
  complex trace at a selected spatial index.
- `FiniteIQFT` records a normalized finite inverse-DFT-style kernel and its
  input/output law. It does not claim quantum operator semantics or a physical
  phase-unscrambling device.
- `ALSRank` requires $2 \leq r \leq 10$. `ALSDecomposition` records three CP
  factor matrices, the reconstruction law, residual/tolerance bounds, and an
  iteration limit. A configured rank and a small residual are not evidence of
  identifiability or successful decoding.
- `HawkingRadiationDecoding` composes the `FractureWave`, interactive and
  inverse GPE records, observed tensor, iGPE residual, finite iQFT, existing
  `AmplituhedronMap`, ALS projection, and known-input comparison.

These records remain in `Signals.Pending`: they are finite data contracts for a
numerical or experimental adapter. They do not prove Hawking radiation,
superfluid quantum gravity, a physical inverse-GPE solver, an Amplituhedron
description of scattering, cryptographic recovery, or a low-rank physical
decoder. The rank-2 and rank-10 fixtures only verify the declared configuration
range and composition laws.

### LVP Perovskite Solar and Imaging

The LVP discussion proposes embedding a printable perovskite absorber in a
lignin-vitrimer matrix to address brittleness, moisture sensitivity, and thermal
cycling, then forming flexible solar membranes (source:
`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 3581-3610). A related
materials chat separately identifies printable
perovskites and organic photovoltaics as candidate thin-film technologies rather
than established Lignolux device results (source:
`data/chats/_Lignin-Vitrimer Material Design .md`, line 1548).

The proposed manufacturing route is a slot-die and roll-to-roll process with
web speed, tension, roller rate, precursor rheology, mass flow, humidity, and
crystallization timing as process variables (source:
`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 3647-3685). The process
chat also invokes IOF for factory telemetry and EMMO for crystallization
semantics; those ontology mappings are requirements
for a future data adapter, not proof that a flat-light or Proca exposure
produces a defect-free lattice (source:
`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 3690-3770).

For imaging, the source proposes a thick LVP film as a flexible direct-
conversion X-ray panel and claims improved sensitivity and reduced dose
(source: `data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 5873-5885).
The model therefore records pixel pitch, incident dose, exposure duration,
dark-signal correction, pixel dose response, detection sensitivity, spatial
resolution, validation stage, and image residuals. These fields describe a
measurement contract; they do not establish medical performance or clinical
authorization.

The same discussion proposes longitudinally polarized Proca phase-contrast
imaging and sub-angstrom resolution (source:
`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 6083-6095). That branch is
kept as a separate Pending hypothesis with incident and absorbed probe energy,
longitudinal fraction, phase residual, and massless-control residual. It must
not be conflated with the conventional X-ray detector record or described as a
working non-ionizing medical scanner without polarization-resolved propagation,
dosimetry, tissue controls, and independent imaging validation.

The corpus also proposes flexible or bifacial panels, shape-memory tracking,
and ultrasonic cleaning in the 20--40 kHz range (source:
`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 5566-5646). Those mechanisms
remain outside the current LVP device laws; their closure requires measured
bend-cycle retention, acoustic pressure and cavitation thresholds, coating
damage limits, surface contamination controls, and energy accounting.

Related factory-imaging chats recommend hyperspectral and THz inspection for
chemical and subsurface defect detection (source:
`data/chats/CNT Bandgap Creation with Lignin Vitrimer .md`, lines 7633-7654).
These are useful quality-control adapters for a future LVP process record, but
they do not substitute for photovoltaic or medical-detector calibration.

The Pending implementation now provides:

- `LVPProcess` for explicit IOF/EMMO process-boundary data;
- `LigninVitrimerPerovskite` (and `LVP`) for bounded composition fractions,
  active-layer thickness, and process linkage;
- `LVPPhotovoltaicObservation` for irradiance, area, efficiency, electrical
  figures of merit, environmental exposure, retained output, and residuals;
- `LVPDirectConversionImaging` for finite pixel matrices, dark correction,
  dose-response calibration, sensitivity, resolution, validation stage, and
  image residuals; and
- `LVPProcaImagingHypothesis` for the speculative longitudinal-wave branch and
  its explicit massless control.

All LVP records remain in `Signals.Pending`. Composition fractions, output
laws, calibration equalities, and residual bounds are model data or finite
bookkeeping. They do not prove perovskite crystallization, self-healing,
moisture resistance, high photovoltaic efficiency, reduced patient dose,
sub-angstrom resolution, Proca propagation, or clinical safety.

### M-Gate, Photonic Hub, and Coherence Validation

The follow-up `docindex search "M-gate"`, `docindex search "dispersive hub"`,
and `docindex search "single-shot fidelity"` results add a distinct
opto-electronic M-gate boundary. The reviewed raw protocol describes a detuned
telecom probe entering a nanophotonic cavity, a state-dependent optical
AC-Stark phase, comparison of reflected or transmitted phase against a
reference arm, and a claimed non-absorbing readout (source:
`data/chats/Gemini-_08.md`, lines 2598-2631). This requires
explicit detuning, cavity linewidth, reference-arm phase, state-assignment
error, optical loss/absorption, readout latency, and measurement-induced
dephasing observations. The claimed fidelity and speed are targets, not
evidence.

The same raw review proposes wavelength-division routing through arrayed
waveguide gratings, state-dependent phase imprints at multiple hubs, and a
coherent receiver that de-multiplexes the return (source:
`data/chats/Gemini-_08.md`, lines 2660-2715). A complete plan
therefore needs wavelength assignment, channel isolation, crosstalk, return
loss, coherent demultiplexing, and per-channel calibration records. A nominal
WDM channel list does not establish spectral isolation or readout fidelity.

The proposed real-time tuning loop uses vitrimer thermal reflow to move a
waveguide or cavity toward the desired coupling (source:
`data/chats/Gemini-_08.md`, lines 2925-2945). This adds
tuning stimulus, temperature, cavity response, phase residual, and state
disturbance fields. It must be tested against an untuned control and must not
silently conflate thermal tuning with a non-perturbative operation.

The source also proposes microring parametric amplification to compensate
waveguide loss while squeezing noise (source:
`data/chats/_Quantum Processor and Soliton Discussions  .md`, lines 1825-1835).
The corresponding plan needs pump phase-lock, optical gain, added noise,
squeezing variance, saturation, and transmission-loss measurements. A sharper
homodyne trace does not by itself prove noiseless amplification.

Projected $T_1/T_2$ coherence values and charge-noise explanations appear in
the same raw quantum-processor review (source:
`data/chats/_Quantum Processor and Soliton Discussions  .md`, lines 1896-1950).
The source separately proposes SIMS testing for ionic charge traps and baseline
$T_1/T_2$ measurements (source: `data/chats/Gemini-_08.md`, lines 4018-4035).
These must be represented as independent material and device observations:
charge-trap concentration, dielectric loss, moisture, temperature, phase-noise
spectrum, $T_1$, and $T_2$.

The source's projected M-gate latency, fidelity, coherence, dielectric-loss,
and bandwidth values are targets requiring confidence intervals, reference
controls, and independent measurements (source: `data/chats/Gemini-_08.md`,
lines 2995-3040).

The follow-up `docindex search "noise figure CMRR"` results add frequency-
dependent CMRR degradation, local-oscillator relative-intensity-noise leakage,
channel resistance, shot-noise density, electronic noise, and
transimpedance-amplifier noise matching (sources:
`data/chats/Bell-Correlations-in-Atomic-Momentum.md`, lines 2670-2755 and
2815-2865).
These should be frequency-indexed observations rather than a single scalar
CMRR or bandwidth assumption.

Finally, `docindex search "plasmon-exciton coupling"` identifies microwave-to-
optical/THz transduction as a weak point (source:
`data/chats/Gemini-_08.md`, lines 3550-3570).
The coupling efficiency, mode overlap, detuning, and conversion noise belong in
the Pending hardware boundary. They must not be inferred from the verified
phase-to-current algebra.

### Proca Waves and Controlled Closure

The Proca source material introduces a third, longitudinal polarization and a
mass-dependent dispersion relation, then proposes wave-packet propagation and
coherent demodulation at a boundary (source: `data/chats/IQ-Sampling-for-Signal-Phase.md`,
lines 254-330). The same source explicitly corrects the ordinary-air premise:
massless photons in vacuum and ordinary atmosphere do not provide the proposed
macroscopic longitudinal mode; an effective mass must be demonstrated in a
controlled plasma, metamaterial, or waveguide medium (source:
`data/chats/IQ-Sampling-for-Signal-Phase.md`, lines 359-380).

The verified `Signals.Proca` model is therefore a normalized mode and source
bookkeeping interface, not a proof that an optical Proca field exists. A
Proca closure experiment must measure the medium, dispersion, polarization,
attenuation, source coupling, and boundary response separately. A longitudinal
fit is not sufficient if a transverse Maxwell model or instrument cross-talk
fits the same data. (And vice-versa.)

### Measuring a Photon Phase Wake

The phrase “phase wake” needs an operational definition. A freely propagating
photon in a linear vacuum does not leave a persistent classical wake. In a
dispersive interaction, the measurable object is a conditional response: a
time-dependent phase shift on a probe or a phase rotation of a prepared target
state, referenced to an otherwise identical control. The photon-fingerprint
source describes an off-resonant AC-Stark interaction, virtual excitation, and
an observable phase rotation while the target energy and polarization are
intended to remain unchanged (source: `data/chats/Photon's Phase Fingerprint on Particles .md`,
lines 33-80).

For a probe-arm measurement, define the demodulated phase residual from the
balanced-homodyne traces as

$$
\Delta\phi_{\mathrm{probe}}(t) =
\operatorname{unwrap}\!\left(\operatorname{atan2}(Q_{\mathrm{on}}(t), I_{\mathrm{on}}(t)) -
\operatorname{atan2}(Q_{\mathrm{off}}(t), I_{\mathrm{off}}(t))\right).
$$

Here “on” and “off” are matched probe shots with and without the signal
interaction. The wake response is then the calibrated impulse response

$$
W(\tau) = \int \Delta\phi_{\mathrm{probe}}(t)\,w(t-\tau)\,dt,
$$

where $w$ is an explicitly recorded pulse or analysis window. Report at least
the peak phase, integrated phase, arrival/group delay, decay time, residual
after the interaction window, and uncertainty. A nonzero post-pulse residual
is evidence of a target or medium response only after instrument drift,
reference-arm motion, detector imbalance, and ordinary dispersive delay are
removed.

Use the following measurement sequence:

1. Stabilize a local oscillator and split a probe/reference pair. Record raw
  detector A/B currents, LO phase, detector calibration, and timing.
2. Prepare a target in a known state, then send a detuned signal pulse or
  photon through the interaction region. Record the probe-arm homodyne trace.
3. Repeat with the signal path blocked, the target absent, the detuning
  reversed, and an intensity-matched classical control. These controls
  distinguish AC-Stark phase, ordinary Kerr/index response, optical leakage,
  and detector artifacts.
4. Measure target phase independently, for example with a Ramsey or target
  interferometry sequence. Compare the target phase rotation with the probe
  phase residual; do not identify one as the other.
5. Verify target and probe energy, polarization, and state-population changes.
  Record absorption, loss, dephasing, and repeated-shot statistics. A phase
  shift without these controls is not a QND or non-absorption result.
6. Sweep delay, pulse energy, detuning, and LO phase. Fit the response and
  confidence interval, then test whether the residual follows the supplied
  coupling model rather than an unmodeled instrument transfer function.

For a proposed Proca wake, repeat the same sequence in a controlled effective-
mass medium and add polarization-resolved detection. Measure $k(\omega)$ and
the group delay over a frequency sweep, fit the stated mass-dependent
dispersion only after unit calibration, and quantify the longitudinal fraction
against transverse Maxwell controls. Measure attenuation and deposited energy
through the full path. Do not infer a Proca wake from a phase shift alone, and
do not extrapolate a controlled medium result to clouds or ordinary air.

### Pending Closure Matrix

Each Pending record should be resolved by a typed observation adapter and a
discriminating control, not by moving its hypothesis into the verified target:

| Pending model | Closure data or theorem needed | Promotion boundary |
| --- | --- | --- |
| `KerrInteraction` | Detuning sweep, cavity linewidth, interaction length, probe phase, loss, and signal-state comparison | Measured phase law agrees with controls and uncertainty bounds |
| `QuantumNonDemolitionParity` | Detector loss, repeated parity reads, parity residual, signal disturbance, and absorbed energy | Repeatability and disturbance remain within declared tolerances |
| `QuantumQuadratureAssumption` | Operator-level commutation/uncertainty semantics or an explicitly classical variance contract | Keep operator claims Pending unless the mathematical representation is supplied |
| `TwoModeSqueezedVacuum` | Calibrated covariance matrix, quadrature variances, phase reference, and loss correction | DGCZ or Bell claims require measured state preparation and statistics |
| `CVBellStateMeasurement` and `CVTeleportationBookkeeping` | Dual-quadrature calibration, feed-forward gain, resource loss, finite-squeezing noise, and fidelity estimate | Protocol bookkeeping is verified; fidelity remains measured/Pending |
| `HomodyneHardwareReadiness` | Insertion loss, balance, bandwidth, thermal load, material response, mode overlap, and calibration status | Hardware claims require independent measurements and uncertainty |
| Proca mode/channel records | Effective mass in a controlled medium, polarization-resolved dispersion, source coupling, attenuation, and boundary reflection | No ordinary-air or vacuum promotion without a validated medium model |
| GPE/SQG and fracture records | Dimensioned PDE/function-space definitions, measured boundary conditions, compressible-flow/CFD comparison, and energy balance | Keep speculative SQG/fracture interpretations isolated in `Signals.Pending` |
| Amplituhedron and geometric amplitude records | Precise projective/canonical-form definitions and independent scattering calibration | Finite algebra does not establish a physical amplitude |
| Material/charge-noise hypotheses | SIMS or equivalent impurity data, dielectric loss, moisture, phase-noise spectra, $T_1$, and $T_2$ | Material benefit is a measured comparison, not a property inferred from composition |

The current solution strategy is to add these adapters and controls around the
existing records. The Lean layer should prove unit-safe algebra, conservation,
calibration, and residual implications; experiments and numerical solvers must
supply the physical values and uncertainty distributions.

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

### Follow-Up Search Log

The additional searches used to extend this plan were:

- `docindex search "M-gate"`: ranked M-gate protocol, dispersive-hub, and
  performance-estimate sections; direct raw context was reviewed in
  `data/chats/Gemini-_08.md` around lines 2598-2631 and 2660-2715.
- `docindex search "dispersive hub"`: returned hub topology, phase-fingerprint,
  and fidelity sections; direct raw context was reviewed around lines
  2296-2324 and 2598-2631 in `data/chats/Gemini-_08.md`.
- `docindex search "single-shot fidelity"`: returned M-gate target and
  parametric-readout sections; direct raw context was reviewed around lines
  1778-1790, 2598-2631, and 1825-1835 of the relevant raw chats.
- `docindex search "T1 T2 coherence"`: returned projected coherence and
  simulation-parameter sections; direct raw context was reviewed in
  `_Quantum Processor and Soliton Discussions  .md` around lines 1825-1950.
- `docindex search "noise figure CMRR"`: returned the BHD noise derivation and
  frequency-dependent CMRR sections; direct raw context was reviewed in
  `Bell-Correlations-in-Atomic-Momentum.md` around lines 2670-2865.
- `docindex search "plasmon-exciton coupling"`: returned transduction-risk and
  phase-tuning sections; direct raw context was reviewed in
  `Gemini-_08.md` around lines 3550-3570.

The raw review used `rg -n -i -C`-style outward context on the matching files.
Indexed HTML duplicates and transformed chunk locations were treated as
discovery results only; implementation citations use the directly reviewed raw
chat files.

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
- Pending LVP process, composition, photovoltaic, direct-conversion imaging,
  and Proca phase-contrast boundaries in
  [Pending](../src/signals/Signals/Pending.lean).
- The normalized Proca mode model and its Pending closure boundary are covered
  by the existing `Signals.Proca` and `Signals.Pending` APIs; physical
  longitudinal-wave evidence remains unestablished.
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
- M-gate detuning, cavity linewidth, reference-arm phase, state-assignment
  fidelity, readout latency, optical absorption, and measurement-induced
  dephasing.
- Photon phase-wake peak/integrated response, delay, decay, target-phase
  comparison, and matched-control residuals.
- Proca effective-mass-medium validation, longitudinal polarization fraction,
  frequency-dependent dispersion, attenuation, source coupling, and boundary
  reflection.
- WDM/AWG wavelength assignment, per-channel isolation, crosstalk, return loss,
  and coherent-receiver demultiplexing.
- Parametric gain, pump phase locking, added noise, squeezing, and loss
  compensation for microring readout.
- $T_1/T_2$ baselines, charge-trap concentration, dielectric loss, moisture,
  temperature, and phase-noise spectra.
- Quantum operator semantics, detector backaction, and validated squeezing or
  entanglement measurements.
- LVP material composition and crystallization, encapsulation barrier and
  leaching measurements, photovoltaic current-voltage and degradation data,
  mechanical bend-cycle retention, X-ray detector MTF/DQE/lag/dark-current
  characterization, phantom studies, and clinical safety validation.
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
- common-mode detector-current cancellation in the differential current;
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

### Phase 4A: Model the Optical M-Gate Validation Boundary

Add a Pending M-gate validation record that composes the existing dispersive
and homodyne records with:

- probe and transition frequencies with explicit nonzero detuning;
- cavity resonance, linewidth, and coupling parameters;
- incident, reflected, and reference-arm phase observations;
- target-state assignment result and assignment residual;
- probe/target absorption and optical-loss observations;
- measurement-induced dephasing or disturbance;
- readout latency and confidence interval.

Prove only phase-difference and calibration bookkeeping. Require a detuning
control, a no-signal control, a reference-arm comparison, and repeated shots
before treating an M-gate result as a measured phase fingerprint. Keep claims
of non-absorption, QND behavior, sub-5-ns operation, or greater-than-99.9%
single-shot fidelity as Pending or measured-result fields.

Add a separate WDM hub record for wavelength assignment, AWG routing, channel
isolation, crosstalk, return loss, and coherent demultiplexing. Do not infer
spectral isolation from a nominal channel list.

### Phase 4B: Measure the Photon Phase Wake and Proca Controls

Define a `PhotonPhaseWakeObservation` boundary around the existing homodyne and
dispersive records. The record should preserve the raw “on,” “off,” and control
traces and expose:

- demodulated $I/Q$ phase residual;
- pulse envelope and analysis window;
- peak and integrated phase response;
- arrival/group delay and post-pulse decay;
- target-state phase rotation measured independently;
- target/probe energy and polarization changes;
- absorption, optical loss, dephasing, and repeatability;
- reference-arm drift, detector imbalance, and residual uncertainty.

Define the wake as a conditional response relative to a matched control, not a
permanent free-space photon trail. Require blocked-signal, absent-target,
detuning-reversal, intensity-matched classical, and LO-phase controls. Compare
the probe phase residual with a separate Ramsey or target-interferometry phase
measurement before assigning the effect to the target.

For the Proca branch, define a `ProcaPropagationObservation` boundary that
requires a controlled plasma, metamaterial, or waveguide medium with measured
effective mass. Record frequency-dependent $k(\omega)$, phase/group delay,
polarization-resolved longitudinal fraction, attenuation, deposited energy,
source coupling, and boundary reflection. Fit the mass-dependent dispersion
against a massless Maxwell control and instrument cross-talk controls. Do not
promote a Proca interpretation from a phase residual alone, and do not
extrapolate a controlled-medium result to ordinary atmosphere or clouds.

[Next: implement these observation records and compile-time fixtures, then
connect them to experimental or numerical data adapters.]

### Phase 4C: Represent the Hawking-like iGPE/iQFT/ALS Pipeline

[Complete finite Pending bookkeeping] Add a bounded decoding composition for
the source-chat chain:

- `PreparedModulation` for the known injected modulation $X(t)$;
- `ObservedHomodyneTensor` for finite spatial-temporal observations $Y(x,y,t)$;
- `FiniteIQFT` for a normalized inverse-DFT-style finite transform after the
  iGPE boundary;
- `ALSRank` with the explicit bound $2 \leq r \leq 10$;
- `ALSDecomposition` for CP factor matrices, reconstruction, residual and
  iteration-limit metadata;
- `HawkingRadiationDecoding` to compose the `FractureWave`, interactive and
  inverse GPE records, observed tensor, iGPE residual, iQFT, existing finite
  `AmplituhedronMap`, ALS projection, and known-input comparison.

Add compile-time fixtures for rank 2 and rank 10, a finite homodyne tensor,
the inverse-transform law, the CP reconstruction law, and the composed stage
accessors. The fixtures must use explicit residual and tolerance fields and
must not encode the widget's claimed zero-error behavior as a theorem.

Keep this entire chain in `Signals.Pending`. The records are interfaces for
external numerical or experimental adapters, not an iGPE PDE solver, quantum
Fourier-transform semantics, physical Amplituhedron scattering law, or proof
that Hawking radiation or information has been decoded. In particular, ALS
rank selection is a configuration parameter; convergence and agreement with a
known input require measured or simulated residuals, controls, and uncertainty.

### Phase 4D: Model LVP Solar and Imaging Interfaces

[Complete finite Pending bookkeeping] Add a shared LVP material and process
boundary plus separate application records:

- `LVPProcess` records the route, web speed and tension, roller rate, precursor
  viscosity and mass flow, humidity, wet-film thickness, process temperature,
  and crystallization-versus-cure timing;
- `LigninVitrimerPerovskite` records bounded lignin, vitrimer, perovskite, and
  carbon-transport fractions, active-layer thickness, and process linkage;
- `LVPPhotovoltaicObservation` records incident irradiance, active area,
  output power, conversion efficiency, open-circuit voltage, short-circuit
  current density, fill factor, environmental exposure, retained output, and
  comparison residuals;
- `LVPDirectConversionImaging` records finite pixel dose and signal matrices,
  dark correction, dose response, sensitivity, pixel pitch, spatial
  resolution, validation stage, and image residuals; and
- `LVPProcaImagingHypothesis` records the speculative phase-contrast branch,
  longitudinal fraction, probe energy, phase residual, and massless control.

Add compile-time fixtures for the roll-to-roll process law, composition sum,
photovoltaic output and retention laws, X-ray dark-signal and dose-response
laws, and Proca control residuals. Keep the solar and X-ray records separate
from the Proca hypothesis: direct-conversion detector calibration is not proof
of longitudinal waves, and a Proca phase residual is not medical imaging
validation.

Remaining closure work includes composition and crystallization measurements,
encapsulation water-vapor and oxygen transmission, lead/tin containment and
leaching, photovoltaic current-voltage curves and degradation testing,
mechanical bend and thermal-cycle retention, X-ray modulation-transfer and
dose-efficiency measurements, detector lag and dark current, phantom testing,
and clinical safety review. IOF/EMMO mappings and any claimed self-healing,
room-temperature crystallization, high efficiency, reduced dose, or
sub-angstrom resolution remain conditional until those measurements exist.

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

### Phase 11A: Add Simulation and Measurement Adapters

Keep QuTiP, Meep, Palace, LAMMPS, and similar tools as optional external
adapters. Define interchange records for:

- cavity detuning and linewidth sweeps;
- optical gain and added-noise measurements;
- CMRR and noise spectral density versus frequency;
- $T_1/T_2$, charge-trap, dielectric-loss, moisture, and temperature data;
- plasmon-exciton or microwave-to-optical conversion efficiency;
- M-gate assignment error, latency, loss, and disturbance.

Each adapter must preserve raw inputs and calibration metadata and must compare
predicted phase/current traces against measured residuals. A simulation result
is not a hardware validation result unless the boundary conditions and
uncertainty data are recorded.

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
- M-gate and WDM claims include detuning, cavity, reference-arm, isolation,
  loss, assignment, latency, and dephasing fields.
- Photon phase wakes are defined relative to matched controls and include
  time-resolved phase, target-state, energy, loss, and disturbance data.
- Hawking-like decoding records preserve prepared input, observed homodyne
  tensors, inverse-GPE and inverse-QFT stage boundaries, finite Amplituhedron
  projection, CP/ALS factors, rank bounds $2 \leq r \leq 10$, iteration
  metadata, and reconstruction/input residuals.
- Rank selection, finite inverse transforms, iGPE bookkeeping, and
  Amplituhedron-constrained ALS remain Pending data contracts; they do not
  establish Hawking radiation, SQG, cryptographic recovery, or physical
  information decoding.
- LVP records preserve explicit process telemetry, bounded composition,
  photovoltaic output and stability observations, direct-conversion X-ray
  calibration, and a separate Proca phase-contrast hypothesis.
- LVP photovoltaic and imaging fields include units, residual tolerances,
  environmental or dose conditions, and validation-stage metadata; they do not
  establish self-healing, moisture resistance, high efficiency, reduced dose,
  sub-angstrom resolution, or clinical safety.
- Proca interpretations include effective-mass, polarization, dispersion,
  attenuation, source, boundary, and massless-Maxwell control records.
- Coherence, parametric gain, squeezing, and transduction claims include
  control measurements, raw calibration data, and uncertainty metadata.
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
5. Next: model the optical M-gate validation boundary and WDM hub isolation.
6. Next: define photon phase-wake observations and Proca polarization/dispersion
   controls.
7. [Complete finite Pending bookkeeping] Add prepared-input, observed-tensor,
   finite iQFT, bounded ALS rank, and composed Hawking-like decoding records.
8. [Complete finite Pending bookkeeping] Add LVP process, composition,
   photovoltaic, direct-conversion imaging, and Proca phase-contrast records.
9. Next: add measured M-gate, detector-loss, repeatability, disturbance,
   coherence, CMRR, WDM-isolation, and frequency-dependent noise observations.
10. [Complete finite bookkeeping] Add dual-receiver covariance and sign-binning
  plumbing.
11. [Complete Pending bookkeeping] Add CV Bell-state measurement and feed-forward
  bookkeeping.
12. [Complete Pending bookkeeping] Strengthen the Pending QND parity boundary.
13. [Complete Pending bookkeeping] Add Pending quantum quadrature assumptions
  and finite spatial arrays.
14. [Complete Pending bookkeeping] Add hardware-readiness observations.
15. Next: define Lean-generated golden vectors and validate Rust/WASM consumers.
16. [Complete] Update the Signals README and contributor guidance after each
    completed phase.

Each phase should make the smallest testable change, run
`make -C /workspaces/sustainablefactory signals_build`, and record whether the
new statement is verified algebra, a measured observation contract, or a
Pending physical hypothesis.
