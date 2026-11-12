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
[`Signals/Pending.lean`](../Signals/Pending.lean), and the numerical handoff is
specified in [`RUST_NUMERICAL_ADAPTER_SPEC.md`](RUST_NUMERICAL_ADAPTER_SPEC.md)
(see also the cross-domain synthesis in
[`docs/grassmannian-unification-applications-roadmap-paper.md`](../../../docs/grassmannian-unification-applications-roadmap-paper.md),
the $\mathrm{ER}=\mathrm{EPR}$ unification in
[`docs/grassmannian-er-epr-witten-su4-plucker-tachyons-semi-dirac-paper.md`](../../../docs/grassmannian-er-epr-witten-su4-plucker-tachyons-semi-dirac-paper.md),
the companion comparison paper
[`docs/grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md`](../../../docs/grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md),
and [`docs/plan-index.md`](../../../docs/plan-index.md)).

The Lean Pending boundary now includes `DDFCommunicationMode`,
`DDFFractureCommunicationEvidence`, and the Section 25–25.1 discrimination and critique
theorems `DDFFractureCommunicationEvidence.ddf_fracture_communication_vs_er_epr_wormhole_and_hybrid_synthesis_bounds`
and `DDFFractureCommunicationEvidence.ddf_fracture_attenuation_cayley_saturation_horodecki_and_passivity_critique_bounds`
(backed by `Signals.DFT.ddf_fracture_communication_vs_er_epr_wormhole_and_hybrid_synthesis_identities`
and `Signals.DFT.ddf_fracture_attenuation_cayley_saturation_horodecki_and_passivity_critique_identities`
in [`Signals/DFT.lean`](../Signals/DFT.lean) lines 7104–7534 and Rust evaluators in
[`numerical_adapter/src/dft_plabic_vrc.rs`](../numerical_adapter/src/dft_plabic_vrc.rs) lines 1940–2065).
Its support predicate requires an
independent defect proposition and detectable defect observable, a classical
residual outside tolerance (after subtracting both calibrated acoustic transfer
and Kutta–Joukowski Magnus lift), nonzero coupling, a causal transverse-phonon mode,
replication, held-out agreement, and an energy-closure premise. This is a
typed contract over supplied premises, not a measurement or DDF existence
theorem.

## Updated Hypotheses

### Summary
The revised model is:

- `H0`: ordinary calibrated acoustic, elastic, optical, detector, and environmental effects explain the signal (`ddfFractureTotalChannelSignal y_cl 0 q_ddf = y_cl`).
- `HDDF`: an additional reproducible term exists, tied to an independently measured DDF defect, pressure/enthalpy deficit, phase winding (`plaquette_phase_slip_syndrome`), or transverse-mode signature (`ddfFractureTotalChannelSignal y_cl kappa_ddf q_ddf`).
- DDF propagation remains causal at the declared transverse-phonon speed (`0 ≤ ddfFractureCausalTransitMargin`). FTL, SQG-current, or uncalibrated longitudinal-Proca results reject this DDF model rather than confirm it (`not_supported_by_noncausal_mode`).
- The active-radiation null test is separate and cannot establish fracture communication.
- **Crucial Boundary vs. $\mathrm{ER}=\mathrm{EPR}$ Entanglement/Wormholes**: DDF fracture-based communication is a **local, contiguous topological-defect waveguide** that operates at **zero quantum entanglement** ($\mathcal{C}_{\mathrm{EPR}}^2 = 4|p_{23}|^2 = 0$, $A_{\mathrm{ER}} = 0$) and provides **non-zero standalone classical bit contrast** ($\Delta y_{\mathrm{fracture}} = 2\kappa_{\mathrm{DDF}}q_{\mathrm{DDF}} > 0$), whereas an $\mathrm{ER}=\mathrm{EPR}$ wormhole throat requires $\mathcal{C}_{\mathrm{EPR}}^2 > 0$, has **zero standalone unkeyed signaling contrast** (`erEprTransceiverDifferentialContrast 0 = 0`), and collapses under high-energy overload (`0 < wormholeNetNullDefocusingFlux`). In a hybrid architecture (`hybridFractureKeyedErEprRxProbability`), the causal DDF fracture channel can serve as the classical Gao–Jafferis–Wall (GJW) feed-forward key that unlocks a parallel $\mathrm{ER}=\mathrm{EPR}$ quantum bridge.

This plan covers classical calibration, PIV/JHTDB flow maps, weak trace/jump controls, mode and arrival-time analysis, blinded waveform transmission, conservation accounting, replication, explicit rejection criteria, and the formal discrimination between DDF fracture waveguides and $\mathrm{ER}=\mathrm{EPR}$ entanglement bridges.


### Classical null hypothesis

`H0` states that every observed signal is explained by the ordinary calibrated
source, medium, instrument, and environment:

$$
y(t) = y_{\mathrm{classical}}(t; \theta) + \epsilon(t).
$$

The classical model must include acoustic/elastic transfer, optical or
radio-link response, detector response, clock synchronization, environmental
backgrounds, missing-data handling, and an input/output energy ledger.

### DDF extension hypothesis

`HDDF` states that a persistent DDF vortex or a fracture-like discontinuity in
the DDF substrate contributes an additional, reproducible perturbation to the
ordinary channel:

$$
y(t) = y_{\mathrm{classical}}(t; \theta)
      + \kappa_{\mathrm{DDF}} q_{\mathrm{DDF}}(t; \psi)
      + \epsilon(t),
$$

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

$$
L'_{\mathrm{classical}} = \rho U \Gamma.
$$

An observed lift or transverse drift explained by this relation belongs to
`H0` (`ddfFractureMagnusSubtractedResidual (y_ac + rho_f * u_in * gamma_c) y_ac rho_f u_in gamma_c = 0`).
A DDF candidate requires a nonzero residual after this control
(`ddfFractureMagnusSubtractedResidual (y_ac + rho_f * u_in * gamma_c + kappa_ddf * q_ddf) y_ac rho_f u_in gamma_c = kappa_ddf * q_ddf`),
an independent circulation/pressure/defect measurement, causal transverse-mode propagation,
and replication. It is invalid to relabel ordinary Magnus lift as DDF
coupling, and the current DDF paper formalization does not itself claim a
Magnus law.

## How DDF Fracture-Based Communication Differs From—and Connects With—$\mathrm{ER}=\mathrm{EPR}$ Entanglement and Wormholes on $\mathrm{Gr}_{\mathbb{C}}(2,4)$

In earlier exploratory chats (`data/chats/_Neutrons-and-Black-Holes-and-Fracture.md`, lines 861–954; `data/chats/Superfluid-Gravity-and-Negative-Energy.md`, lines 243–305; `data/chats/Review-Pop-III-GW-Remnants.md`, lines 1515–1650), **superfluid/DDF shear fractures** ($\mathrm{De}/\mathrm{De}_c > 1$) and **$\mathrm{ER}=\mathrm{EPR}$ wormhole bridges** ($p_{23} = \det\Psi \neq 0$) were discussed alongside one another because both involve non-positive sectors of the Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$. Our formalization in [`Signals/DFT.lean`](../Signals/DFT.lean) Sections 23–25 (`ddf_fracture_communication_vs_er_epr_wormhole_and_hybrid_synthesis_identities`) establishes their exact mathematical separation and their hybrid synthesis:

### 1. Seven-Axis Discrimination Table: DDF Fracture Waveguide vs. $\mathrm{ER}=\mathrm{EPR}$ Entanglement Bridge

| Discrimination Axis | DDF Fracture-Based Communication (`HDDF` in `Signals.Pending`) | $\mathrm{ER}=\mathrm{EPR}$ Entanglement / Wormhole Bridge (`Signals.DFT` Sec. 23) | Hybrid Fracture-Keyed $\mathrm{ER}=\mathrm{EPR}$ Transceiver (`Signals.DFT` Sec. 25) |
| --- | --- | --- | --- |
| **1. Physical & Topological Mechanism** | **Local, contiguous 1D/2D defect waveguide**: a vortex core or shear-fracture interface ($\mathrm{De} = \tau_{\mathrm{relax}}\dot{\gamma} > 1$, FTLE $\sigma > \sigma_{\mathrm{crit}}$, plaquette holonomy $2\pi n$) spanning the medium between $A$ and $B$. | **Non-local bipartite conifold bridge**: a deformed twistor conifold throat $\det Z_{2\times 2} = p_{23} = g_s N_c \neq 0$ on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ connecting entangled mouths $A, B$ without a contiguous mechanical crack in 3D space. | **Dual-channel architecture**: an $\mathrm{ER}=\mathrm{EPR}$ entangled bridge ($p_{23} \neq 0$) paired with a parallel causal DDF fracture/phonon waveguide carrying the classical GJW key. |
| **2. Plücker Entanglement Concurrence $\mathcal{C}_{\mathrm{EPR}}^2 = 4\|p_{23}\|^2$** | **Not required** ($\mathcal{C}_{\mathrm{EPR}}^2 = 0$, $p_{23} = 0$, $A_{\mathrm{ER}} = 0$): works for completely unentangled product states (`erEprPluckerConcurrenceSq 0 = 0`). | **Strictly required** ($\mathcal{C}_{\mathrm{EPR}}^2 = 4\|p_{23}\|^2 > 0 \implies A_{\mathrm{ER}} = 16\ell_P^2 S_{\max}\|p_{23}\|^2 > 0$); vanishes if $p_{23} = 0$. | **Required on quantum arm** ($\|p_{23}\|^2 = 1/4 \implies \mathcal{C}_{\mathrm{EPR}}^2 = 1$), while key arm is classical ($p_{23} = 0$). |
| **3. Unassisted Standalone Bit Contrast ($\Delta P$)** | **Non-zero** ($\Delta y_{\mathrm{fracture}} = 2\kappa_{\mathrm{DDF}}q_{\mathrm{DDF}} > 0$, `ddfFractureStandaloneBitContrast`) after causal transit $t_{\mathrm{arr}} \ge L_{\mathrm{path}}/c_{\mathrm{emergent}}$. | **Identically zero** when unkeyed ($g_{\mathrm{GJW}} = 0 \implies \Delta P_{\mathrm{RX}} = 0$, `erEprTransceiverDifferentialContrast 0 = 0`, `erEprNoSignalingMarginalA`). | **Zero before key arrival** ($1/2$ coin flip at $\kappa_{\mathrm{DDF}} = 0$); **$100\%$ contrast** ($\Delta P_{\mathrm{RX}}^{\mathrm{hybrid}} = 1$) once causal fracture key $\kappa_{\mathrm{DDF}}q_{\mathrm{DDF}} = 1$ arrives. |
| **4. Quantum State Transfer Fidelity Ceiling** | **Classical limit** ($F_{\mathrm{eq}}(0, \sin 2\theta) = 1/2$ equatorial; $F_{\mathrm{avg}}^{\mathrm{Horodecki}}(0) = 2/3$ Haar-averaged 3D Bloch sphere, `horodeckiAverageTeleportationFidelity 0 = 2 / 3`). | **Unit quantum teleportation fidelity** ($F_{\mathrm{eq}}(1/4, 1) = 1$ and $F_{\mathrm{avg}}^{\mathrm{Horodecki}}(1) = 1 > 2/3$) when unlocked by $2\theta_{\mathrm{GJW}} = \pi/2$. | **Unit quantum fidelity** ($F_{\mathrm{avg}}^{\mathrm{Horodecki}}(1) = 1$) with $> 9{,}800\times$ dilatant-attenuated corridor key gain (`ddfFractureAttenuatedCorridorGain`) and unconditionally bounded Cayley receiver probability $P_{\mathrm{RX}}^{\mathrm{sat}} \in [0, 1]$ (`hybridSaturatedFractureKeyedErEprRxProbability`). |
| **5. High-Power Overload Behavior** | **Widens / sustains fracture**: driving shear $\tau_{\mathrm{drive}} > \tau_{\mathrm{crit}}$ increases excess fracture shear (`0 < ddfFractureOverloadExcessShear 15 10`). | **Collapses wormhole throat**: driving energy $E_{\mathrm{transit}} > \mathcal{B}_{\mathrm{Bohm}}$ yields positive Raychaudhuri focusing flux (`0 < wormholeNetNullDefocusingFlux 15 10`), pinching off the throat. | Soft quantum symbols ($N_{\mathrm{sym}}E_{\mathrm{sym}} \le \mathcal{B}_{\mathrm{Bohm}}$) transit the throat while high-power classical key pulses travel safely along the separate fracture corridor. |
| **6. Dominant Loss & Failure Mode** | Dilatant high-$k$ viscosity $\eta(k) = \eta_0(1+\alpha k^2) \ge \eta_0$ (`dilatantViscosity_ge_baseline`), damping $\gamma_{\mathrm{damp}}(k) \ge 0$, or crack healing when $\mathrm{De} < 1$. | 3D Bethe sub-wavelength diffraction ($\eta_{\mathrm{Bethe}} = 1/10{,}001$ unless Semi-Dirac/`TRUE`/QISM matched), DDF rest-mass throat jamming $\gamma_\varphi^4$, and decoherence of $p_{23}$. | Protected by directional Semi-Dirac mode isolation ($\mathcal{R}_{\mathrm{iso}}(10) = 101$) + 1-pass McWeeny / distance-3 Plücker QEC ($p_L = 2.98\times 10^{-4}$). |
| **7. Owning `Signals` Verification Contract** | `DDFFractureCommunicationEvidence`, `DDFVortexObservable`, `MagnusEffectControl`, `WeakTraceJumpContract` | `er_epr_su4_plucker_tachyon_offshell_and_semi_dirac_wormhole_identities`, `semi_dirac_er_epr_wormhole_transceiver_identities` | `ddf_fracture_communication_vs_er_epr_wormhole_and_hybrid_synthesis_identities` & `ddf_fracture_communication_vs_er_epr_wormhole_and_hybrid_synthesis_bounds` |

### 2. Where Both Phenomena Live on the Four-Stratum $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Manifold

1. **Stratum 1 — Positive Grassmannian Interior $\mathrm{Gr}_{>0}(2,4)$ ($\mathcal{I}_{\mathrm{lc}} = 1 - \beta^2 > 0$, Causal Propagation)**:
   Houses both the causal transverse-phonon signal `DDFCommunicationMode.transversePhonon` propagating along a DDF fracture boundary ($v_g \le c_{\mathrm{emergent}} \le c$, `0 ≤ ddfFractureCausalTransitMargin`) and the causal classical GJW feed-forward key channel required to unlock an $\mathrm{ER}=\mathrm{EPR}$ bridge.
2. **Stratum 2 — Positive Boundary $\partial\mathrm{Gr}_{\ge 0}(2,4)$ ($\mathcal{I}_{\mathrm{lc}} = 0$, Horizon / Cherenkov Locus)**:
   Represents the acoustic event horizon $r = r_H$ ($|v_\phi| = c$) in `RiverExterior` and the dielectric Cherenkov threshold $v_{\mathrm{sweep}} = c_{\mathrm{med}}$ in `Signals.DFT` Section 24.
3. **Stratum 3 — Spacelike / Tachyonic Shear-Fracture Sector in $\mathrm{Gr}_{\mathbb{C}}(2,4) \setminus \mathrm{Gr}_{\ge 0}(2,4)$ ($\mathrm{De}/\mathrm{De}_c > 1 \iff \hbar^2\omega^2 < 0$)**:
   By `grassmannian_bogoliubov_proca_and_deborah_fracture_identities`, exceeding the critical Deborah ratio $\mathrm{De}/\mathrm{De}_c > 1$ softens the Bogoliubov dispersion to $\hbar^2\omega^2 < 0$. In a DDF medium, this **nucleates the topological vortex/fracture sheet** (`DDFVortexObservable`); in an $\mathrm{ER}=\mathrm{EPR}$ geometry, it describes the spacelike bridge interior ($r < r_H$) and throat pinch-off instability. Crucially, **neither permits superluminal boundary signaling** (`not_supported_by_noncausal_mode` and `erEprNoSignalingMarginalA`).
4. **Stratum 4 — Off-Shell / Complex Boundary-Jump Sector in $\mathrm{Gr}_{\mathbb{C}}(2,4) \setminus \mathrm{Gr}_{\ge 0}(2,4)$ ($\operatorname{Im}\mathcal{S} \neq 0$)**:
   Across a DDF fracture, the spatial discontinuity is governed by the weak trace and flux jump `WeakTraceJumpContract` and quantized $2\pi n$ plaquette phase slip (`plaquette_phase_slip_syndrome`). Across a traversable $\mathrm{ER}=\mathrm{EPR}$ throat, $\operatorname{Im}\mathcal{S} \neq 0$ generates the negative Bohmian null stress cushion $\Sigma_{uu}^{\mathrm{Bohm}} = R_\rho - G_{\operatorname{Im}\mathcal{S}} < 0$ (`offShellBohmStressTensorUu`) and Dual-Schubert Josephson current $J_{\mathrm{Josephson}}$ that prevent Raychaudhuri collapse.

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
- the result fails an independent replication or held-out waveform test;
- an unentangled fracture/phonon residual ($\mathcal{C}_{\mathrm{EPR}}^2 = 4|p_{23}|^2 = 0$) is
  claimed as evidence of an $\mathrm{ER}=\mathrm{EPR}$ wormhole bridge without independent Bell/tomography
  certification of $|p_{23}| > 0$, or an unkeyed $\mathrm{ER}=\mathrm{EPR}$ state ($g_{\mathrm{GJW}} = 0$)
  is claimed to transmit standalone information (`erEprNoSignalingMarginalA`).

A failure of one dataset to contain a time axis, pressure, density, or 3D field
is **inconclusive**, not evidence against DDF. A failure of the complete
pre-registered test after those fields and controls are present is evidence
against the hypothesis.

## Next Implementation Loops

1. [Complete] Add a MATLAB reader for the measured cylinder PIV artifact with `u/v/x/y`,
   20 Hz metadata, NaN/mask preservation, MD5/SHA-256 verification, and a
   bounded time-window selector.
2. [Complete] Add one RSPID validation subset reader for paired images, generator
   parameters, validation fields, and reconstruction-error summaries.
3. [Complete, bounded diagnostic] Convert the bounded JHTDB NPZ probe to the
   common `VectorFieldDataset` JSON contract and add bounded RK2 particle
   advection, out-of-domain coverage, and velocity-gradient consistency checks.
   This remains a solver-produced diagnostic and is not experimental evidence.
4. [Complete, contract boundary] Add a flow-map/FTLE result contract with interpolation, seed, window, and
   convergence metadata; keep it separate from fracture evidence.
5. [Complete, contract boundary] Add the DDF-specific defect/mode contract and
   the classical Magnus control. Populate it only after an independent
   observable and a classical control are available; no current fixture is
   physical DDF evidence.
6. [Complete, formal discrimination & seven-mode multi-path synthesis] Formalize the quantitative
   discrimination between DDF fracture-based communication (`HDDF`, $p_{23}=0$,
   standalone causal contrast $\Delta y = 2\kappa_{\mathrm{DDF}}q_{\mathrm{DDF}} > 0$)
   and $\mathrm{ER}=\mathrm{EPR}$ entanglement/wormholes ($\mathcal{C}_{\mathrm{EPR}}^2 = 4|p_{23}|^2 > 0$,
   unkeyed contrast $0$, Raychaudhuri overload collapse) together with Section 25.1 critique
   gap-closures and the Section 25.2 seven-mode multi-path taxonomy across photons around ($M_1$),
   photons/phonons through fracture around ($M_2$), and Semi-Dirac / soft modes through the
   wormhole ($M_3$) plus their four composite combinations $M_1+M_3$, $M_2+M_3$, $M_1+M_2$, and
   $M_1+M_2+M_3$ (`Signals.DFT` Sections 25–25.2.1,
   `ddf_fracture_communication_vs_er_epr_wormhole_and_hybrid_synthesis_identities`,
   `seven_mode_multipath_wormhole_fracture_and_trimodal_synthesis_identities`,
   `seven_mode_multipath_agc_skew_correlated_outage_and_leakage_critique_identities`,
   and [`docs/grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md`](../../../docs/grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md)).

The bounded Rust JHTDB loop is complete: the reader validates the HDF5
checksum, root time-index attributes, `(z,y,x,vector)` velocity datasets, and
coordinate axes; the CLI performs 3D RK2 flow-map integration, centered
deformation gradients, Cauchy-Green FTLE, and `N` versus `2N` temporal-substep
sensitivity. HDF5 time indices are not treated as physical seconds without an
explicit `--physical-time-step` calibration. The tested 16 x 8 x 16 x 2
cutout uses the JHTDB channel metadata interval `25.9935 / 3999` and retains
845 of 1,176 interior FTLE cells (71.85%); its result is intentionally
`incomplete`, and the refinement estimate is a temporal sensitivity diagnostic,
not a proof of continuum convergence.

The next numerical loop is a larger or more temporally resolved cutout with
independent spatial and source-time convergence checks. Physical DDF evidence
remains a separate, unpopulated boundary.

## Alternative Independent Observables

The current DDF contract needs an observable measured independently of the
proposed communication residual. These alternatives are ordered by how directly
they can satisfy that requirement, not by whether they support DDF:

| Alternative | Independent observable | Classical controls | Access and attribution | DDF boundary |
| --- | --- | --- | --- | --- |
| Open acoustic-emission fracture data | Sensor waveforms, onset times, source location, frequency content, and load-linked event rate | Load/displacement curve, sensor calibration, arrival-time triangulation, known Mode I/II specimens, and blind negative controls | Zenodo 10565566, `10.5281/zenodo.10565566`, open; waveform data for microscopic fracturing in tight reservoir rocks | Ordinary elastic fracture/acoustic emission only; not a DDF defect or carrier |
| Hydraulic-fracture interaction data | Crack geometry and interaction with discontinuities under controlled injection/loading | Pump pressure/flow, boundary conditions, imaging, and injected-volume/energy accounting | Zenodo 6811452, `10.5281/zenodo.6811452`, open; inspect files and license before acquisition | Mechanical fracture control; residuals remain classical without a separate DDF observable |
| AE plus time-frequency shale data | Event timing and time-frequency features tied to bedding-dependent tensile failure | Stress path, specimen geometry, sensor response, and held-out failure mode | Zenodo 18501172, `10.5281/zenodo.18501172`, open; seven files reported by the record | Mode/arrival control, not evidence of transverse-phonon propagation |
| Distributed fiber-optic fracture monitoring | Spatially resolved strain during fracture propagation and caging | Fiber gauge calibration, mechanical load, boundary conditions, and independent crack imaging | Zenodo 20780049, `10.5281/zenodo.20780049`, open; 22 files reported by the record | Strong strain-defect candidate, but ordinary elastic strain is the null |
| Superfluid-vortex analog | Processed vortex shedding, circulation/wake observables, force response, and selected wavefunction snapshots | Gross-Pitaevskii parameter recovery, obstacle geometry, grid/time-step convergence, and classical-fluid benchmark | Kwon and Shin, Zenodo 20068724, `10.5281/zenodo.20068724`, CC BY 4.0; 18.7 MB processed archive, raw time-dependent wavefunctions excluded | Analog/model control only; cannot confirm a terrestrial DDF medium |

### Recommended DDF evidence sequence

1. Start with an open AE or fiber-optic record to build an independent defect
   observable and calibrate event timing, strain, energy release, and ordinary
   elastic propagation.
2. Pair it with controlled force/pressure or hydraulic-fracture data to estimate
   classical coupling and reject load, pump, boundary, and sensor explanations.
3. Use the superfluid-vortex archive only as a model/API control for circulation,
   pressure-deficit, mode, and wake extraction. It is not a physical DDF test.
4. Populate `DDFVortexObservable` only when the observable is acquired through a
   channel independent of the communication residual and its calibration data
   are retained. Populate `DDFFractureCommunicationEvidence` only after a
   held-out waveform, replication, causal mode/arrival test, and energy closure.

The restricted fatigue-crack-growth record `10.5281/zenodo.20610375` links
crack growth, acoustic emission, and fractography, but it is not currently an
open acquisition target. The open alternatives above are the reproducible first
choices.
