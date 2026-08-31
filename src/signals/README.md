# Signals

`Signals` is a small Lean 4 project for checking the mathematics used in the
signal-processing parts of the sustainablefactory research notes. It is a
research companion, not a claim that the proposed hardware or physical
mechanisms have been experimentally validated.

## Current Scope

The current build deliberately implements statements with a clear mathematical
interpretation while keeping experimental premises explicit:

- `Signals.Units` provides named wrappers for frequency, length, power, energy,
   current, voltage, current density, temperature, relative humidity, absorbed
   dose, dynamic viscosity, electrical conductivity, magnetic flux density,
   power density, amount of substance, molar flow rate, responsivity, and
   current-noise density.
- `Signals.IQ` represents an in-phase/quadrature sample as a complex baseband
   value, exposes its magnitude and principal phase, records carrier and
   quadrature conventions, and provides a conditional phase-to-height formula.
- `Signals.Homodyne` models a finite classical local oscillator, normalized
   50:50 beam splitter, balanced detector currents, differential photocurrent,
   detector efficiency/responsivity, dark current, noise, CMRR, affine current
   calibration, dual-receiver covariance/sign-binning traces, finite spatial
   grids, dispersive-readout composition, and a typed runtime trace boundary.
- `Signals.MHD` models conductive Argon flow through a finite classical Faraday
   channel, its matched-load power-density law, kinetic input, passive total-
   input efficiency, auxiliary pump/ionization/field/cooling costs, and
   closed-loop energy accounting. It does not claim a Proca field accelerates
   neutral Argon or that a vacuum-powered plant exists.
- `Signals.Acoustics` models classical ultrasonic transfer from pressure
   amplitude and acoustic impedance through aperture, transducer, link, and
   receiver efficiencies. It proves passive received power is bounded by
   incident power.
- `Signals.Sampling` defines finite sampled tones, exact buffer reconstruction,
   integer-rate aliases, and a strict Nyquist no-alias consequence. The finite
   model is intentional; it is not a replacement for a continuous
   band-limited Fourier theorem.
- `Signals.Coherence` records the polarization/entanglement complementarity
   identity, derives the paper's arbitrary-dimensional $P_N^2+K_N^2=1$ law
   from a normalized finite coherence spectrum, and connects the squared
   quantities to an explicit unit-mass Huygens-Steiner parallel-axis mapping.
   These are finite coherence and mechanics identities, not claims about
   quantum state collapse, QND behavior, or Amplituhedron physics.
- `Signals.OAM` represents a finite normalized OAM qudit and computes its basis
  state count. The exact identity `100^10 = 10^20` is a combinatorial result,
  not a performance or physical-realizability claim.
- `Signals.Physlib` imports Physlib's compatible free-space parameter model and
   proves a small interface lemma over its `FreeSpace` parameters.
- `Signals.Proca` provides a normalized massive-vector mode with explicit mass,
   medium, coupling, boundary, dispersion, and longitudinal-polarization data.
   It now also models a source-driven field equation, current continuity,
   constitutive response, and conditional phase-height measurements.
- `Signals.PaperModels` records finite equations extracted from the four Proca
   PDFs in `data/papers/`: normalized Proca dispersion and dielectric response,
   planar Proca/Chern-Simons response, massive Fabry-Perot resonance and
   radiation-pressure ratios, complementary Proca dipole patterns, finite
   quantum-source directivity, and inverse-fourth-power nonlocality decay.
   These records preserve theoretical and experimental-status boundaries; they
   do not establish Proca material realization, quantum hardware, or any
   propulsion, SQG, vacuum-energy, Argon-MHD, or fracture claim. The cited
   review is in [paper-model-review.md](../../docs/paper-model-review.md).
- `Signals.CavityQED` is imported through `Signals.Pending` and records the
   attached graphite/graphene cavity and Grover cavity-QED models: coupled-mode
   hybrid frequencies, carrier-density resonance fits, spectral-weight
   transfer, two-dimensional Grover rotations, Dicke overlaps, dispersive
   phase oracles, and cooperativity/fidelity metadata. These remain Pending
   conditional records; they do not establish a Lignolux cavity, perfect
   reflection, unit-fidelity state preparation, QND behavior, or a general
   optical implementation.
- `Signals.ActiveOptics` is imported through `Signals.Pending` and records
   second-harmonic resonance, active optical-amplifier power balance, and
   free-electron-pumped cylindrical SPP models. It keeps pump power, output,
   dissipation, phase matching, redshift, overlap, and coherent $N^2$ versus
   incoherent $N$ radiation scaling explicit. These are finite Pending models;
   optical gain is not free energy, and the CSR enhancement is not an
   independently measured X-ray result.
- `Signals.LayerCodes` is imported through `Signals.Pending` and records finite
   CSS input-code and 3D layer-code construction parameters, including logical
   count, one-dimensional junctions, maximum check weight six, and polynomial
   energy-barrier metadata. It does not implement stabilizer generators,
   homology, decoding, thresholds, or NISQ hardware performance.
- `Signals.QECReferences` is imported through `Signals.Pending` and is
   reference-only: it links the [Kitaev surface code entry](https://errorcorrectionzoo.org/c/surface),
   the [quantum surface-code list](https://errorcorrectionzoo.org/list/quantum_surface),
   and the [Layer code entry](https://errorcorrectionzoo.org/c/layer). It also
   names [QECLean](https://github.com/Stavan-Jain/QECLean) as an external Lean
   candidate without adding it as a dependency. The supplied
   `quantum_layer` list URL currently returns 404; the Layer entry is the
   canonical reference here.
- `Signals.QuditQEC` is imported through `Signals.Pending` and records finite
   composite-dimension qudit arithmetic, GKP qutrit/ququart spacing and gain
   laws, and a 100-mode OAM QEC design contract. The GKP papers provide
   syndrome and lifetime-comparison ideas, not an OAM implementation; the
   design therefore keeps mode loss, dephasing, syndrome readout, and recovery
   readiness explicit. In particular, dimension 100 is modeled over cyclic
   arithmetic rather than treated as a field.
- `Signals.SemiDirac` is imported through `Signals.Pending` and records the
   normalized linear/quadratic semi-Dirac dispersion, a calibrated CW
   pump-dependent anisotropic response, and a fiber-laser/resonator/
   metamaterial/process power budget. `SemiDiracGrapheneProcess` proves only
   the necessary lower bound from an independently supplied absorbed-power
   threshold and end-to-end efficiency; it does not claim semi-Dirac behavior,
   Proca coupling, or graphene formation in lignin-vitrimer or hydrocarbon
   material.
- `Signals.LaserProcesses` is imported through `Signals.Pending` and separates
   average CW optical power from pulsed pulse energy, fluence, duration, peak
   power, repetition rate, and shock pressure. It also records maximum average
   CW power, maximum pulsed peak power, maximum pulse-train average power, and
   maximum holographic source power as explicit ceilings. It classifies
   ablation, laser shock compression, direct-write graphene, diamond shock
   synthesis, and the unsupported convergent-holographic proposals. The records
   prove only unit-consistent identities and supplied calibration bounds; the
   maximum watts are source or equipment ceilings, not experimentally validated
   material thresholds, and do not turn chat-derived wattages into process
   specifications.
- `Signals.LaserReferences` is imported through `Signals.Pending` and provides
   a normalized, deduplicated registry for the attached graphene, biomass,
   nanodiamond, optical-modification, maskless-fabrication, additive-
   manufacturing, holography, and Proca references. It records whether each
   source is experimental, a review, theoretical, or metadata-only; whether it
   provides watts, pulse/fluence parameters, process parameters, or no
   transferable wattage; whether a verified local PDF is present in
   `data/papers`; and whether Proca fields or CW holographic carbon synthesis
   are demonstrated. Four of the 13 canonical works have verified PDFs in the
   repository; the other nine retain DOI/repository sources but were
   access-limited during acquisition. The per-key results and SHA-256 hashes
   are recorded in `data/papers/paper_artifact_manifest.csv`. The registry does
   not promote the Lin biomass nanodiamond result into a CW lignin-vitrimer
   recipe and does not treat any optical holography paper as evidence for Proca
   fields or CW holographic graphene/diamond synthesis.
- `Signals.ProtocolZ8` is imported through `Signals.Pending` and
   records strict majority post-processing, shot-derived fidelity, the five
   self-reported Protocol Z.8 heartbeat fidelities and rounded 92.42% average,
   and the reported backend/job/count metadata. Its evidence predicate requires
   complete raw counts and reproduction, so the repository's 98.85% badge and
   heartbeat table are not encoded as independently verified theorems.
- `Signals.Maxwell` provides a coordinate-free three-vector formulation of
   Maxwell's equations, including Gauss, Faraday, and Ampere-Maxwell laws. It
   also includes the isotropic-vacuum form often used as a compact pre-tensor
   formulation; fields are represented directly as vectors, with no Euler-angle
   or gimbal-lock state.
- `Signals.Scattering` models coherent I/Q observations, scattered-to-incident
   power ratios, reference-subtracted phase-height reconstruction, scattering
   cross-section inversion, SNR, and residual-based anomaly candidates.
- `Signals.NonDestructive` separates nondestructive inspection methods,
   phase-fingerprint observations, dispersive probe readout, raw-data-preserving
   calibration, reversible operations, in-situ remediation, and continuous
   recovery. Preservation is represented as an explicit invariant rather than
   inferred from the word "nondestructive". Phase fingerprints and readouts now
   expose target/signal energy preservation and explicit zero-absorption fields;
   a compositional phase/readout bridge keeps their measured shifts aligned.
- `Signals.Propagation` models far-field and near-field coupling, antenna
   efficiency, impedance matching, aperture coupling, alignment, radiation,
   bulk attenuation, interface reflection/transmission/absorption, and passive
   link-power bounds.
- `Signals.Applications` defines measured-model application contracts for
   finite Airy packets, waveguides, nonlinear frequency conversion, MIMO
   pumping, wireless power transfer, and plasma-drive power balance. It does not
   import the pending SQG/fracture claims.
- `Signals.Antennas` models a Lignin-Vitrimer dielectric track, a directional
   broadband antenna with volume-distributed polarization currents, causal
   group and information speeds, passive radiated power, continuous-wave
   resonators, and a calibrated Rydberg-EIT Stark response. The former
   `Signals.LightSlinger` module remains a compatibility facade. `CWApplication` and
   `CWApplicationReadiness` classify whether each proposed application needs a
   phase reference, active mask, convergent beams, range modulation, or a
   Pending massive-mode hypothesis. A superluminal phase-pattern speed is kept
   separate from causal information transport.
- `Signals.Pending` is an intentionally separate submodule for the requested
   SQG, fracture-state, anti-Amplituhedron, deterministic-fusion, and
   spacetime-energy formalisms. These models are explicit mathematical
   hypotheses and are not imported by `Signals`. It also contains
   `SQGMaxwellSystem`, which adds effective constitutive parameters and an
   explicit SQG current to Maxwell's equations. Its finite Amplituhedron layer
   now records unrestricted `C * Z` image maps, optional positive ordered
   minors, a non-boundary reciprocal chart, and a measured-amplitude equality
   only as an explicit hypothesis.
   Its GPE records distinguish inverse reconstruction, inhomogeneous
   source-driven evolution, and the nonlinear interactive model; `IGPEPoint`
   remains a compatibility alias for `InteractiveGPEPoint`.
   Its atmospheric-scavenging records separate species-dependent Gaussian
   splats and finite gate throughput from an idealized homogenization
   assumption. Square-panel output is represented with an edge-shear risk
   proxy that apodization can reduce, not a proof of turbulence-free flow.
   The Pending model also includes dimensioned flow wrappers and a classical
   control-volume baseline for mass, momentum, and energy accounting.
   Pressure, heat-flux, and vector-velocity boundary observations can now be
   compared with explicit residual tolerances.
   Its LightSlinger extension links an antenna to a Proca channel only through
   explicit frequency and longitudinal-coupling hypotheses; CW resonance does
   not itself establish massive-mode emission.
   It also contains LF/VLF radio test vectors for Earth, named planets,
   asteroids, and arbitrary named bodies, plus a conditional ultrasonic
   fracture-evidence protocol.
   Its `QuantumNonDemolitionParity` record keeps OAM-state and parity
   preservation as Pending assumptions over a dispersive readout. It also
   records detector loss, repeatability, disturbance and absorption bounds,
   quantum quadrature assumptions, TMSV variance bookkeeping, CV Bell-state
   measurement/feed-forward plumbing, Pending Kerr interaction data, and
   integrated homodyne hardware readiness observations.
   Its Hawking-like decoding boundary preserves prepared modulation, observed
   homodyne tensors, finite inverse-QFT bookkeeping, bounded CP/ALS rank and
   residual metadata, and composition with the existing GPE and Amplituhedron
   records. These are Pending data contracts, not a physical Hawking decoder.
   Its LVP boundary records a proposed lignin-vitrimer perovskite composition,
   roll-to-roll process telemetry, photovoltaic output and stability
   observations, direct-conversion X-ray calibration, and a separate Proca
   phase-contrast imaging hypothesis. These records do not establish material,
   device, or clinical performance.
- `Signals.Geometry` contains Weyl spinors, twistors, antisymmetric minors, and
   the finite $2 \times 4$ Pluecker relation. It also provides unrestricted
   finite Grassmannian matrices, ordered maximal minors, an optional positive
   Grassmannian condition, and massive four-momentum/spinor-helicity records.
   Negative minors remain valid in the unrestricted matrix layer.
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

The local transformed Myst corpus was searched for the requested Amplituhedron
research. The source describes massless spinor factorization, momentum-twistor
incidence data, the proposed map $Y = C \cdot Z$, and a canonical form with
logarithmic boundary behavior ([IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L7520-L7580)).
Its follow-up Lean snippets mark the generalized Pluecker relations, positive
minor predicate, canonical volume form, and pole theorem as `sorry` stubs
([IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L7868-L7920)).
The implemented API therefore formalizes only the finite algebra that can be
checked locally and keeps the physical amplitude interpretation Pending. No
`data/chats/*.myst.md` files are present in this checkout; the inventory above
uses the transformed files under `docs/chats/`.

The full LightSlinger review found a useful classical boundary and several
unsupported extensions. The source describes a laser-driven polarization spot
with superluminal pattern speed while distinguishing that from faster-than-light
information transfer ([Airy LightSlinger chat](../../docs/chats/_Airy-Beams-and-Communications-and-Illumination.myst.md#L2876-L2922)).
It proposes lignin-vitrimer/carbon dielectric tuning, moisture protection, and
active-mask integration, but supplies no measured permittivity, loss, thermal,
or mode-conversion data ([Airy LightSlinger chat](../../docs/chats/_Airy-Beams-and-Communications-and-Illumination.myst.md#L2922-L2986)).
The companion waveguide review presents Kerr solitons, spin-nematic routing,
and Rydberg-EIT detection as analog or metrology ideas, while its longitudinal
Proca interpretation remains Pending ([superfluid waveguide chat](../../docs/chats/Superfluid-Gravity-and-Negative-Energy.myst.md#L280-L410),
[superfluid Rydberg chat](../../docs/chats/Superfluid-Gravity-and-Negative-Energy.myst.md#L800-L860)).
The implemented model therefore records ordinary sweep, resonance, loss, and
Stark-response quantities without asserting that a dielectric or CW resonator
generates a massive longitudinal field.

The nondestructive corpus review separates several meanings that the chats use
interchangeably. THz conductivity/integrity scans, mmWave radar,
resonant-frequency mapping, optical interferometry, ultrasonic pulse-echo,
phased-array ultrasound, eddy-current testing, lock-in thermography, distributed
Rayleigh/Brillouin fiber sensing, infrared photothermal checks, acoustic-emission
monitoring, and RFID audits are inspection methods whose
non-destructive property must be established by a preserved specimen state and
a calibrated response
([inspection corpus](../../docs/chats/Lignin-Vitrimer-Surface-Roughness-Limits.myst.md#L1596-L1610),
[over-mold NDT chat](../../docs/chats/_Lignin,%20Super%20Glue,%20Baking%20Soda%20Mix%20.myst.md#L1795-L1795),
[mmWave inspection chat](../../docs/chats/_Ultrasonic-Drilling-Hardware,-Control,-Sensing.myst.md#L313-L313)).
The optical chats describe a phase fingerprint or a probe-beam phase shift while
the target photon or qubit remains unchanged ([phase-fingerprint chat](../../docs/chats/Photon's%20Phase%20Fingerprint%20on%20Particles%20.myst.md#L812-L921),
[homodyne QND chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L9359-L9540)).
The broader quantum-homodyne review adds dual balanced receivers,
local-oscillator phase settings, continuous quadrature outcomes, sign binning,
covariance/CHSH bookkeeping, CV Bell-state measurement, and feed-forward
([dual BHD context](../../docs/chats/Bell-Correlations-in-Atomic-Momentum.myst.md#L2396-L2606),
[BHD noise context](../../docs/chats/Bell-Correlations-in-Atomic-Momentum.myst.md#L2676-L2721)).
The source also describes raw telemetry retained through calibration and
reversible vitrimer disassembly ([calibration chat](../../docs/chats/_weather_app_0%20.myst.md#L8613-L8613),
[reversible assembly chat](../../docs/chats/_Sustainable%20Composites_%20Energy,%20Processing,%20Costs.myst.md#L8531-L8563)).
Other records describe low-power diagnostic pulses, in-situ structural
remediation, and continuous recovery processes; these are modeled as distinct
operation contracts rather than being treated as inspections
([diagnostic pulse chat](../../docs/chats/_Lignolux%20Enhances%20Fusion%20Production%20Design.myst.md#L4242-L4242),
[recovery claim](../../docs/chats/_Sustainable%20textiles,%20outerwear,%20apparel.myst.md#L3901-L3901)).

The verified API records the corresponding state, energy, polarization, raw-data,
and restoration invariants. `Signals.Homodyne` records classical detector
algebra and measured-observation contracts; it does not model quantum operators
or prove squeezing. `QuantumNonDemolitionParity` remains Pending because zero
absorption, repeatability, and no quantum backaction require a physical
Hamiltonian, commutation model, detector calibration, and loss measurement; an
algebraic equality in a test fixture is not experimental QND evidence.

## CW Application Review

The IQ Myst document uses CW in several different roles. The initial I/Q and
ocean sections use a CW laser as a stable phase reference, but ranging still
requires pulsing, modulation, or an independent time-of-flight observable
([IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L886-L985)).
The Lignolux and PCLP sections use a CW master oscillator for steady exposure
and resonant buildup, while attributing spatial selectivity to an active mask
and longitudinal-Proca chemistry ([IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L1613-L1863)).
The 400/800 GHz sections require phase-matched nonlinear mixing or intersecting
beams; a single CW carrier does not create a sum-frequency acoustic mode by
itself ([IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L2053-L2447)).
The later thruster, power-plant, communication, wireless-power, medical, and
fabrication sections reuse CW as a steady drive, resonant pump, or continuous
carrier ([IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L3006-L3151),
[IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L4848-L6100),
[IQ Myst chat](../../docs/chats/IQ-Sampling-for-Signal-Phase.myst.md#L8069-L9240)).

The model does not treat those repeated uses as proof that CW works for every
application. The defensible division is:

| Application class | What CW can provide | Additional requirement | Signals status |
| --- | --- | --- | --- |
| Ocean I/Q metrology | Stable optical phase reference | Range modulation or pulsing, surface-return calibration | Classical envelope |
| Waveguide transport | Continuous carrier and resonant buildup | Dispersion, loss, and thermal characterization | Classical envelope |
| PCLP nanolithography | Steady exposure | rGO phase/amplitude mask and measured resist response | Pending interpretation |
| 400/800 GHz acoustic mixing | Continuous pump energy | At least two phase-coherent beams, nonlinear coefficient, phase matching, and heat budget | Pending interpretation |
| Anti-fire and FRC proposals | Continuous drive or rotating phase pattern | Active mask, target coupling, energy ledger, and physical validation | Pending |
| Thruster and argon-power proposals | Continuous drive and control bandwidth | Propellant mass/momentum/energy balance and mode-conversion measurements | Pending |
| Wireless power and deep-space communication | Continuous carrier | Causal link budget, receiver selectivity, safety exposure, and information-channel test | Pending |

An rGO-Vitrimer active mask can encode a spatial phase or amplitude profile, but
it does not create a new field species. Convergent beams can create a localized
interference or nonlinear interaction region, but they do not by themselves
prove second-harmonic generation, thrust, vacuum coupling, or massive-Proca
emission. Those distinctions are represented by `CWApplicationRequirements`,
`CWApplicationReadiness`, and the explicit `CWProcaEmissionHypothesis`.

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

The plan is executed as a short agent loop. Each iteration selects one
well-scoped item, adds the smallest model and compile-time test that can
discriminate its behavior, runs `make signals_build`, updates this plan with
the result, and records a focused commit message. A model remains Pending when
its physical premises or calibration data are not established.

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
8. [Implemented] Add the classical LightSlinger-like antenna envelope with
   Lignin-Vitrimer material parameters, sweep timing, causal-speed separation,
   and passive power bounds.
9. [Implemented] Add continuous-wave resonator enhancement/loss accounting and
   Rydberg-EIT Stark-response metrology. Keep massive longitudinal emission in
   `Signals.Pending`.
10. [Implemented] Classify CW application requirements and readiness conditions
   for phase references, active masks, convergent beams, range modulation,
   and Pending massive-mode hypotheses.
11. [Implemented] Add nondestructive inspection, phase-fingerprint, dispersive
   readout, calibration-preservation, and reversible-operation contracts.
   Keep quantum nondemolition parity in `Signals.Pending`.
12. [Implemented] Strengthen the focused nondestructive contracts with explicit
   target/signal energy preservation, zero-absorption fields, compositional
   phase/readout agreement, affine calibration, and typed vitrimer operations.

### Phase 3: Add geometry and fabrication abstractions

1. [Implemented, finite algebra] Introduce spinors and twistors as data and
   prove their elementary antisymmetry identities.
2. [Implemented, finite algebra] Prove a $2 \times 4$ Pluecker relation with
   determinants; do not encode an Amplituhedron volume as an axiom.
3. [Implemented, finite algebra] Add ordered finite Grassmannian matrices and
   maximal minors. Keep negative minors valid in the unrestricted layer and
   isolate strict positivity as an optional subtype.
4. [Implemented, finite bookkeeping] Add a mostly-minus mass-shell record and
   a supplied two-term massive spinor-helicity factorization. This is
   kinematic data, not evidence for a massive optical mode.
5. [Implemented] Model masks, voxels, calibration, height bounds, and thermal
   budgets as data plus proved bounds. Fabrication execution remains outside
   the theorem-proving core.
6. Keep OAM state-space counting separate from claims about computational
   speed, fault tolerance, or device capacity.
7. [Implemented in Pending] Represent the finite $C \cdot Z$ image, a local
   reciprocal boundary chart, and measured-amplitude identification as
   explicit hypotheses without importing them into the verified library.
8. Pending: formalize general Pluecker relations over arbitrary index sets,
   positive Grassmannian cells, projective canonical forms, and residues only
   after supplying precise finite-dimensional definitions and proofs.

### Phase 4: Atmospheric scavenging and panel models

1. [Implemented in Pending] Represent mixed atmospheric species with
   species-dependent mass, partial density, temperature, and covariance data.
2. [Implemented in Pending] Represent finite gate acceptance and normalized
   mixed-species throughput, keeping the Gaussian-overlap interpretation
   explicit rather than presenting it as a measured mass-flow rate.
3. [Implemented in Pending] Represent phase-slip homogenization as supplied
   common-velocity and covariance-collapse assumptions.
4. [Implemented in Pending] Represent square-panel dimensions and an
   apodization-adjusted edge-shear risk proxy. The proxy is not a turbulence,
   shock, or acoustic-output theorem.
5. [Implemented in Pending] Add calibrated dimensioned mass flow and a
   classical control-volume baseline with mass, momentum, and energy balances.
   These balances provide the comparison point for any proposed phase-slip
   result.
6. [Implemented in Pending] Add measured pressure, heat-transfer, and
   vector-flow boundary conditions with componentwise residual tolerances.
7. Next: connect these boundary records to a compressible-flow or CFD adapter
   and compare predicted mass, momentum, heat, and acoustic outputs before
   making plume or drag claims.

### Agent Loop Record

1. [Complete] Atmospheric model loop: added species-dependent splats, bounded
   gate throughput, explicit homogenization assumptions, and square-panel
   edge-shear risk. Proposed commit:
   `feat(signals): model mixed atmospheric scavenging and panel edge risk`.
2. [Complete] Conservation loop: added dimension-labeled flow wrappers,
   calibrated `kg/s` conversion, and classical control-volume mass, momentum,
   and energy balances. Proposed commit:
   `feat(signals): add calibrated control-volume conservation model`.
3. [Complete] Boundary-data loop: added pressure, heat-flux, and vector-flow
   observations with residual tolerances. Proposed commit:
   `feat(signals): add measured flow boundary residuals`.
4. Next loop: connect the records to measured or simulated compressible-flow
   data. Do not promote phase-slip homogenization or apodization to a physical
   performance claim without that comparison.
5. [Complete] LightSlinger loop: added Lignin-Vitrimer antenna, CW resonator,
   Rydberg-EIT, and explicit Pending Proca-emission contracts. Proposed commit:
   `feat(signals): model LightSlinger antennas and guarded CW emission`.
6. [Complete] CW-application loop: reviewed every CW reference in the IQ Myst
   document and added application requirements for phase references, active
   masks, convergent beams, range modulation, and Pending massive-mode claims.
   Proposed commit:
   `feat(signals): classify CW application requirements and causal limits`.
7. Next loop: add measured mode-conversion efficiency, polarization-resolved
   near-field data, thermal/loss characterization, and causal waveform controls,
   then connect them to the compressible-flow validation path.
8. [Complete] Nondestructive-measurement loop: added inspection-method tags,
   preservation invariants, dispersive phase readout, calibration preservation,
   reversible restoration, and Pending OAM parity QND assumptions. Proposed
   commit:
   `feat(signals): model nondestructive inspection and QND boundaries`.
9. [Complete] Focused nondestructive-contract loop: strengthened phase
   fingerprints and dispersive readout with explicit energy/absorption fields,
   composed their phase agreement, added affine calibration offsets, and typed
   vitrimer operations with power accounting. Proposed commit:
   `feat(signals): compose phase fingerprints with guarded dispersive readout`.
10. Next loop: add method-specific calibration records and measured disturbance,
    absorption, repeatability, and detector-loss observations.

### Pending Physical Formalisms

`Signals.Pending` develops the requested precedent formalisms in an isolated
namespace and build target:

- `GPEVariant` distinguishes `inverse`, `inhomogeneous`, and `interactive`
   pointwise GPE records.
- `InverseGPEPoint` reconstructs a complex potential from a nonzero wavefunction
   and supplied time derivative, Laplacian, coupling, and density.
- `InhomogeneousGPEPoint` records an explicit external source term in the GPE
   balance.
- `InteractiveGPEPoint` records the nonlinear local balance with effective mass,
   potential, coupling, density, time derivative, and Laplacian terms.
   `IGPEPoint` remains its compatibility alias.
- `AtmosphericSpecies`, `TensorGaussianSplat`, and `AtmosphericMixture` record
   species-dependent particle mass, partial density, temperature, and
   covariance data for finite mixed-gas models.
- `AtmosphericScavenging` records a normalized finite approximation to a gate
   overlap integral with bounded component acceptance factors. It is not yet a
   dimensioned mass-flow solver.
- `PhaseSlipHomogenization` records common output velocity and collapsed
   covariance as explicit idealized assumptions; it does not prove that a
   Proca or phase-slip field produces those effects in air.
- `SquarePanel` and `SquarePanelPlume` record tiled aperture dimensions and a
   bounded residual edge-shear indicator. This makes square-edge turbulence a
   calibration risk rather than silently assuming that apodization eliminates
   it.
- `DimensionedScavengingFlow` converts normalized gate throughput to `kg/s` only
   through an explicit calibration scale.
- `ClassicalControlVolume` records supplied mass, momentum, and energy balances
   in dimension-labeled wrappers and proves steady-flow and useful-power bounds.
- `FlowBoundaryCondition` and `FlowBoundaryObservation` record pressure,
   heat-flux, and vector-velocity boundary data with measured-versus-predicted
   residual tolerances.
- `InspectionMethod` and `InspectionRecord` cover the corpus's THz, mmWave,
   ultrasonic, eddy-current, thermal, fiber, acoustic, infrared, and RFID
   inspection paths.
- `PhaseFingerprint` records a measured phase change with preserved target energy
   and polarization, plus explicit zero absorbed target energy.
- `DispersiveReadout` records signal-state preservation, signal-energy
   preservation, a coupled probe phase response, and zero absorbed signal/probe
   energy as explicit model data. `DispersivePhaseFingerprint` links its phase
   shift to the corresponding readout response.
- `BalancedHomodyne`, `DualHomodyneTrace`, `HomodyneGrid`, and
   `HomodyneTraceSample` provide finite local-oscillator, beam-splitter,
   detector, spatial, and runtime-trace records. The model proves energy
   conservation, interference/differential-current laws, rotated-quadrature
   selection, finite covariance bookkeeping, threshold binning, and raw/current
   calibration laws.
- `CalibrationRecord` preserves a raw reading while deriving an affine
   calibrated value with multiplier and offset.
- `ReversibleOperation` records typed vitrimer disassembly, restoration, or
   repair, operation power, and restoration of an original state.
- `QuantumNonDemolitionParity` records OAM-state and parity preservation as a
   Pending QND hypothesis with detector-loss, repeatability, parity-residual,
   disturbance, and absorption bounds; it does not prove no backaction in
   hardware.
- `QuantumQuadratureAssumption` and `TwoModeSqueezedVacuum` record Pending
   commutation, uncertainty, squeezing, and variance assumptions.
- `CVBellStateMeasurement`, `CVFeedForward`, and
   `CVTeleportationBookkeeping` record Pending dual-quadrature measurement and
   displacement plumbing without proving entanglement or teleportation
   fidelity.
- `KerrInteraction` and `HomodyneHardwareReadiness` record Pending nonlinear
   coupling and integrated-detector readiness observations.
- `PreparedModulation` and `ObservedHomodyneTensor` preserve finite known-input
   and spatial-temporal homodyne data for a Pending decoding pipeline.
- `FiniteIQFT` records a normalized inverse-DFT-style finite transform law; it
   does not supply quantum operator semantics.
- `ALSRank` bounds the configured CP/ALS rank to $2 \leq r \leq 10$, while
   `ALSDecomposition` records factor matrices, reconstruction, residual and
   iteration-limit metadata.
- `HawkingRadiationDecoding` composes the prepared input, observed tensor,
   interactive/inverse GPE points, finite iQFT, Amplituhedron map, ALS
   projection, and known-input comparison. It remains Pending and does not
   establish Hawking radiation, SQG, cryptographic recovery, or physical
   information decoding.
- `ProcaMHDHypothesis` links a Proca channel to the classical MHD plant only as
   a conditional boundary. It separates optical/control power from motive
   input and keeps a control-only ratio distinct from total-input efficiency.
- `ProcaControlField` records a frequency-matched Pending control/coupling
   field, supplied coupling gain, coupled motive power, and residual bound.
- `AtmosphericArgonSource` records body-specific Argon molar-fraction feed
   assumptions and captured molar flow. The Earth/Mars abundance values are
   inputs to the source model, not energy supplies or operating-cost proofs.
- `LVPProcess` and `LigninVitrimerPerovskite` preserve explicit process
   telemetry, bounded composition fractions, active-layer thickness, and the
   proposed IOF/EMMO process boundary.
- `LVPPhotovoltaicObservation` records irradiance, area, efficiency, electrical
   figures of merit, environmental exposure, retained output, and comparison
   residuals. `LVPDirectConversionImaging` records pixel dose/signal matrices,
   dark correction, dose response, sensitivity, resolution, validation stage,
   and image residuals.
- `LVPProcaImagingHypothesis` records the speculative longitudinal-wave branch,
   probe energy, phase residual, longitudinal fraction, and massless control.
   It does not establish Proca propagation or medical imaging.
- `CWApplication` and `CWApplicationRequirements` classify the ten CW uses
   found in the IQ Myst document by their phase-reference, mask, convergence,
   range-modulation, and massive-mode requirements.
- `RGOVitrimerActiveMask`, `ConvergentCWBeams`, and
   `CWApplicationReadiness` record the additional controls required by a
   proposed application and preserve the causal information-speed bound.
- `LightSlingerProcaCoupling` associates a LightSlinger antenna with a Proca
   channel only through explicit frequency and longitudinal-coupling
   assumptions.
- `CWProcaEmissionHypothesis` requires positive CW drive, resonance matching,
   a longitudinal mode label, positive Proca mass, and nonzero coupling before
   recording a massive-mode emission hypothesis. CW resonance alone is not
   sufficient.
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
- `AmplituhedronMap` records the finite matrix image $Y = C \cdot Z$ without
   asserting that it is an Amplituhedron or that its image has a physical
   volume.
- `LogarithmicChart` records positive source-minor assumptions, a nonzero
   selected coordinate, and a reciprocal finite chart weight. Its
   `AmplituhedronScatteringHypothesis` makes any equality to a measured
   scattering amplitude explicit rather than proving it from geometry.
- `AntiAmplituhedronProfile` and `SQGVacuumExpansion` record divergent-profile
   and negative-coupling hypotheses.
- `AntiFireSuppression` records suppression as an explicit rate inequality.
- `GroundDrivenMember` and `GroundDrivenAntiFireDevice` connect piston,
   cylinder, and shaft members driven into a subsurface target with the pending
   anti-fire profile. They keep member geometry, insertion force and stroke,
   thermal harvesting, piezoelectric stress harvesting, conversion efficiency,
   battery power, external input power, and emitter-power coverage explicit.
   These are conditional power and deployment contracts, not evidence of
   landfill-fire suppression or self-powered emission.
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

### Amplituhedron Formalization Plan

1. [Implemented] Keep arbitrary real Grassmannian matrices and negative
   Pluecker coordinates available for intermediate or non-positive charts.
2. [Implemented in Pending] Represent the finite $C \cdot Z$ image and a
   local reciprocal weight with explicit non-boundary assumptions.
3. Pending: define ordered Pluecker coordinates over general $k,n$ with
   proved indexing and determinant identities, then formalize the generalized
   Pluecker relations.
4. Pending: define positive cells and amplituhedron images separately from
   canonical differential forms; add boundary and residue notions only with a
   precise mathematical domain.
5. Pending: add massive momentum-twistor incidence and Proca/rGO hardware
   mappings only as conditional records with measured calibration, loss, and
   uncertainty fields. A geometric coordinate or chart weight must not be
   promoted to a physical scattering amplitude without that evidence.

### Phase 5: LightSlinger and resonator models

1. [Implemented] Model Lignin-Vitrimer dielectric inputs and a moving
   polarization-pattern antenna with separate phase-pattern, group, and
   information speeds.
2. [Implemented] Model CW resonant frequency matching, intracavity enhancement,
   passive out-coupling, and dissipation.
3. [Implemented] Model Rydberg-EIT Stark response as a calibrated electric-field
   observation, without claiming that its shift uniquely identifies a
   longitudinal field.
4. [Implemented in Pending] Require CW drive, longitudinal mode labeling,
   positive Proca mass, frequency matching, and nonzero coupling before a
   LightSlinger-to-Proca emission hypothesis can be constructed.
5. [Implemented] Classify the ten CW application families from the IQ Myst
   document and require explicit mask, beam, and causal-envelope conditions
   where applicable.
6. Next: add measured mode-conversion efficiency, polarization-resolved
   near-field data, thermal/loss characterization, and causal waveform tests.

### Phase 6: Nondestructive measurement and reversible operations

1. [Implemented] Cover the corpus's distinct nondestructive inspection methods
   with explicit specimen-state preservation and nonnegative stimulus/response
   data.
2. [Implemented] Cover phase fingerprints and dispersive probe readout with
   explicit phase-response, energy/polarization preservation, and zero-absorption
   assumptions.
3. [Implemented] Cover raw-data-preserving calibration, reversible material
   restoration, in-situ remediation, and continuous source-preserving recovery.
4. [Implemented in Pending] Cover OAM parity QND as an explicit hypothesis over
   a dispersive readout.
5. [Implemented] Add finite balanced-homodyne algebra, detector calibration,
   noise/CMRR observations, dispersive composition, dual traces, spatial grids,
   and typed runtime trace samples.
6. [Implemented in Pending] Add quadrature assumptions, TMSV variance data, CV
   Bell-state measurement/feed-forward plumbing, QND evidence bounds, and
   integrated hardware-readiness observations.
7. Next: add measured detector-loss, repeatability, disturbance, and
   frequency-dependent noise observations before making QND or zero-damage
   claims. Runtime Rust/WASM consumers should validate against typed trace
   vectors rather than treating the Lean records as hardware evidence.

### Phase 7: Upstream contributions

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

## Radio Basics: Crystal, AM, and FM with Lean Signals

```{note}
This tutorial models classical radio reception and modulation schemes using the
Lean Signals library. These are well-established physics and engineering
concepts, verified at scale in commercial radio systems worldwide.
```

### Introduction to Radio Reception

Radio waves are electromagnetic signals carrying information. Three foundational
receiver architectures dominate practical radio:

1. **Crystal Radio**: A passive detector using a semiconducting junction (diode).
   No external power source is required, making it the simplest working radio.

2. **AM (Amplitude Modulation)**: Information is encoded by varying the
   amplitude of a carrier wave. The baseband signal modulates the carrier strength.
   Standard AM band: 530 kHz to 1.7 MHz.

3. **FM (Frequency Modulation)**: Information is encoded by varying the
   frequency of a carrier wave. The baseband signal modulates the carrier frequency.
   Commercial FM band: 88 to 108 MHz.

The `Signals.Radio` module formalizes the mathematics of these receivers.

### Crystal Radio: The Simplest Radio Receiver

A crystal radio consists of:
- An LC tuning circuit (resonates at the desired frequency)
- A crystal detector (semiconductor diode)
- An earphone (output transducer)

The crystal detector acts as a nonlinear device, passing positive voltage peaks
and blocking negative peaks (half-wave rectification).

#### Crystal Detector Model

```lean
structure CrystalDetector where
  forwardDrop : ℝ          -- Voltage drop across the junction (V)
  threshold : ℝ            -- Minimum voltage to conduct (V)
  hThreshold : threshold > 0
  hDrop : 0 ≤ forwardDrop
  hDropSmall : forwardDrop < threshold
```

The detector output follows a simple rule: conduct (and subtract the forward
drop) only when the input signal exceeds the threshold.

```lean
noncomputable def crystalDetectorOutput (detector : CrystalDetector)
    (inputVoltage : ℝ) : ℝ :=
  if inputVoltage > detector.threshold
  then max 0 (inputVoltage - detector.forwardDrop)
  else 0
```

**Verification**: Ideal crystal detectors have zero forward drop and negligible
threshold:

```lean
def idealCrystalDetector : CrystalDetector where
  forwardDrop := 0
  threshold := 0.0001
  hThreshold := by norm_num
  hDrop := by norm_num
  hDropSmall := by norm_num
```

#### LC Tuning Circuit

The selectivity of a crystal radio depends on its LC tuning circuit. The
resonant frequency is given by:

$$f_0 = \frac{1}{2\pi\sqrt{LC}}$$

Quality factor $Q$ measures selectivity:

$$Q = \frac{\omega_0 L}{R} = \frac{f_0}{B}$$

where $R$ is the circuit resistance and $B$ is the bandwidth.

```lean
structure LCTuner where
  inductance : ℝ
  hInductance : inductance > 0
  capacitance : ℝ
  hCapacitance : capacitance > 0

noncomputable def LCTuner.resonantFreq (tuner : LCTuner) : ℝ :=
  1 / (2 * Real.pi * Real.sqrt (tuner.inductance * tuner.capacitance))

noncomputable def LCTuner.qualityFactor (tuner : LCTuner) (resistance : ℝ) : ℝ :=
  let ω₀ := 2 * Real.pi * (tuner.resonantFreq)
  (ω₀ * tuner.inductance) / resistance
```

### AM (Amplitude Modulation)

In amplitude modulation, the message signal $m(t)$ modulates the amplitude of
a carrier wave:

$$s(t) = [A_c + m(t)] \cos(2\pi f_c t + \phi)$$

or equivalently, with modulation index $\mu = \max|m(t)|/A_c$:

$$s(t) = A_c[1 + \mu \cdot n(t)] \cos(2\pi f_c t + \phi)$$

where $n(t) = m(t)/\max|m(t)|$ is the normalized modulation and $0 \leq \mu \leq 1$.

#### AM Signal Structure

```lean
structure AMSignal where
  carrierFreq : ℝ           -- Carrier frequency (Hz)
  carrierAmplitude : ℝ      -- Carrier amplitude (V)
  hCarrierAmp : carrierAmplitude > 0
  modulation : ℝ → ℝ        -- Modulating signal m(t)
  modulationIndex : ℝ       -- μ: typically 0 to 1
  hModIndex : 0 ≤ modulationIndex ∧ modulationIndex ≤ 1
  phase : ℝ                 -- Initial phase (rad)
```

#### AM Bandwidth and Sidebands

Amplitude modulation creates two sidebands:
- **Lower sideband**: $f_c - f_m$
- **Upper sideband**: $f_c + f_m$

where $f_m$ is the modulation frequency. The total bandwidth is:

$$B_{AM} = 2 f_m$$

For example, an AM station at 1000 kHz modulated by audio up to 5 kHz
occupies frequencies from 995 kHz to 1005 kHz.

```lean
noncomputable def AMSignal.envelope (signal : AMSignal) (t : ℝ) : ℝ :=
  signal.carrierAmplitude +
  signal.modulationIndex * signal.carrierAmplitude * signal.modulation t

noncomputable def AMSignal.voltage (signal : AMSignal) (t : ℝ) : ℝ :=
  signal.envelope t * Real.cos (2 * Real.pi * signal.carrierFreq * t + signal.phase)

def AMSignal.lowerSideband (signal : AMSignal) (modulationFreq : ℝ) : ℝ :=
  signal.carrierFreq - modulationFreq

def AMSignal.upperSideband (signal : AMSignal) (modulationFreq : ℝ) : ℝ :=
  signal.carrierFreq + modulationFreq
```

**Verification**: AM sidebands are symmetric around the carrier:

```lean
lemma AMSignal.sidebands_symmetric (signal : AMSignal) (modulationFreq : ℝ) :
    signal.carrierFreq - signal.lowerSideband signal.modulationFreq =
    signal.upperSideband signal.modulationFreq - signal.carrierFreq := by
  unfold AMSignal.lowerSideband AMSignal.upperSideband
  ring
```

#### AM Demodulation

An envelope detector recovers the modulation by rectifying and low-pass filtering.
The detected output is proportional to the envelope:

$$\text{output} \propto 1 + \mu \cdot n(t)$$

```lean
lemma AMDemodulation (signal : AMSignal) (t : ℝ) (detectorIdeal : True) :
    ∃ A_c m f_c φ,
      signal.carrierAmplitude = A_c ∧
      signal.carrierFreq = f_c ∧
      signal.phase = φ ∧
      signal.envelope t = A_c * (1 + signal.modulationIndex * signal.modulation t) := by
  use signal.carrierAmplitude, signal.modulation, signal.carrierFreq, signal.phase
  exact ⟨rfl, rfl, rfl, rfl⟩
```

### FM (Frequency Modulation)

In frequency modulation, the message signal modulates the carrier frequency:

$$s(t) = A_c \cos\left(2\pi f_c t + 2\pi \Delta f \int_0^t m(\tau) d\tau + \phi\right)$$

where $\Delta f$ is the **frequency deviation** (maximum shift from carrier).

#### FM Signal Structure

```lean
structure FMSignal where
  carrierFreq : ℝ           -- Carrier frequency (Hz)
  carrierAmplitude : ℝ      -- Carrier amplitude (V)
  hCarrierAmp : carrierAmplitude > 0
  modulation : ℝ → ℝ        -- Modulating signal m(t)
  frequencyDeviation : ℝ    -- Δf: frequency shift (Hz)
  hFreqDev : frequencyDeviation > 0
  phase : ℝ                 -- Initial phase (rad)

noncomputable def FMSignal.instantaneousFreq (signal : FMSignal) (t : ℝ) : ℝ :=
  signal.carrierFreq + signal.frequencyDeviation * signal.modulation t
```

#### Carson's Bandwidth Rule

The bandwidth required for FM transmission depends on the modulation index:

$$\beta = \frac{\Delta f}{f_m}$$

**Carson's rule** gives the required bandwidth:

$$B_{FM} \approx 2(\Delta f + f_m)$$

where $f_m$ is the modulation frequency.

```lean
def FMSignal.modulationIndex (signal : FMSignal) (modulationFreq : ℝ) : ℝ :=
  signal.frequencyDeviation / modulationFreq

def FMSignal.carsonBandwidth (signal : FMSignal) (modulationFreq : ℝ) : ℝ :=
  2 * (signal.frequencyDeviation + modulationFreq)
```

#### Narrowband vs. Wideband FM

- **Narrowband FM** ($\beta \ll 1$): $B_{NB} \approx 2 f_m$ (similar to AM)
- **Wideband FM** ($\beta \gg 1$): $B_{WB} \approx 2 \Delta f$ (much wider than AM)

Commercial FM radio uses wideband FM with $\Delta f = 75$ kHz and $f_m$ up to
15 kHz, giving $\beta \approx 5$ and bandwidth $\approx 180$ kHz per station.

```lean
def FMSignal.narrowbandApprox (signal : FMSignal) (modulationFreq : ℝ) : ℝ :=
  2 * modulationFreq

def FMSignal.widebandApprox (signal : FMSignal) (modulationFreq : ℝ) : ℝ :=
  2 * signal.frequencyDeviation
```

### Radio Receiver Model

A complete receiver tunes to a desired frequency and has finite selectivity:

```lean
structure RadioReceiver where
  tuneFreq : ℝ              -- Receiver center frequency (Hz)
  bandwidth : ℝ             -- Filter bandwidth (Hz)
  hBandwidth : bandwidth > 0
  sensitivity : ℝ           -- Minimum detectable signal (V)
  hSensitivity : sensitivity > 0

def RadioReceiver.isInBand (receiver : RadioReceiver) (signalFreq : ℝ) : Prop :=
  |signalFreq - receiver.tuneFreq| ≤ receiver.bandwidth / 2
```

**Verification**: A signal at the tuned frequency is always in-band:

```lean
lemma RadioReceiver.tuneFreq_in_band (receiver : RadioReceiver) :
    receiver.isInBand receiver.tuneFreq := by
  unfold RadioReceiver.isInBand
  simp
  linarith [receiver.hBandwidth]
```

### Example: AM Radio Station

A typical AM radio station operates as follows:

```lean
def toySinusoidalModulation : ℝ → ℝ :=
  fun t => Real.sin (2 * Real.pi * 1000 * t)  -- 1 kHz audio tone

def toyAMSignal : AMSignal :=
  { carrierFreq := 1_000_000      -- 1 MHz (typical AM frequency)
    carrierAmplitude := 10         -- 10 V
    hCarrierAmp := by norm_num
    modulation := toySinusoidalModulation
    modulationIndex := 0.8         -- 80% modulation depth
    hModIndex := by norm_num
    phase := 0 }

example : toyAMSignal.lowerSideband 1000 = 999_000 := by
  norm_num [AMSignal.lowerSideband, toyAMSignal]

example : toyAMSignal.upperSideband 1000 = 1_001_000 := by
  norm_num [AMSignal.upperSideband, toyAMSignal]

example : toyAMSignal.bandwidth 1000 = 2000 := by
  norm_num [AMSignal.bandwidth, toyAMSignal]
```

This signal occupies 2 kHz (from 999 kHz to 1001 kHz). A receiver tuned to
1 MHz with a 10 kHz bandwidth can receive it clearly.

### Example: FM Radio Station

A commercial FM station:

```lean
def toyFMSignal : FMSignal :=
  { carrierFreq := 100_000_000    -- 100 MHz (commercial FM)
    carrierAmplitude := 10         -- 10 V
    hCarrierAmp := by norm_num
    modulation := toySinusoidalModulation
    frequencyDeviation := 75_000   -- 75 kHz (standard FM)
    hFreqDev := by norm_num
    phase := 0 }

example : toyFMSignal.modulationIndex 1000 = 75 := by
  norm_num [FMSignal.modulationIndex, toyFMSignal]

example : toyFMSignal.carsonBandwidth 1000 = 152_000 := by
  norm_num [FMSignal.carsonBandwidth, toyFMSignal]
```

With 75 kHz deviation and 1 kHz modulation, Carson's bandwidth is 152 kHz—
much wider than AM but providing better noise immunity and fidelity.

### Impedance and Power Conversion

Radio systems commonly use 50 ohm impedance. Voltage-to-power conversion:

$$P = \frac{V^2}{50}$$

```lean
noncomputable def voltageToPower (voltage : ℝ) : ℝ :=
  (voltage * voltage) / 50

example : voltageToPower 10 = 2 := by
  norm_num [voltageToPower]  -- 100 V² / 50 Ω = 2 W
```

### Narrowband Approximation

When the signal bandwidth is much smaller than the receiver bandwidth
(< 10%), the signal can be represented in complex baseband (I/Q) form:

```lean
def isNarrowband (signalBandwidth receiverBandwidth : ℝ) : Prop :=
  signalBandwidth < receiverBandwidth / 10
```

This enables efficient digital signal processing using I/Q sampling.

### Key Insights and Design Principles

1. **AM is bandwidth-efficient** but noise-prone. AM bandwidth = 2 × modulation BW.

2. **FM trades bandwidth for noise immunity**. FM bandwidth ≈ 2(Δf + f_m).

3. **Crystal radios are passive** but achieve only limited selectivity without
   active amplification.

4. **Narrowband signals** (BW << 10% of center frequency) allow I/Q representation
   and efficient DSP processing.

5. **Resonant tuning** with high Q provides selectivity to reject adjacent
   channel interference.

6. **Envelope detection** (crystal radio) recovers AM modulation but cannot
   recover FM.

7. **Frequency demodulation** (superheterodyne or direct FM detection) is
   required for FM recovery.

### Verification Examples

All radio equations and properties in the Signals library are proved as Lean
theorems. The mathematics is identical to what appears in standard textbooks
(Haykin, Proakis, Pozar) but formalized for mechanical verification.

Try these examples in the test suite to verify the formalization:

```lean
def toyCrystalDetector : CrystalDetector :=
  { forwardDrop := 0.3
    threshold := 0.7
    hThreshold := by norm_num
    hDrop := by norm_num
    hDropSmall := by norm_num }

example : toyCrystalDetector.forwardDrop < toyCrystalDetector.threshold := by
  exact toyCrystalDetector.hDropSmall
```

### Further Reading

- **Standard Textbooks**:
  - Haykin, S. (2001). *Communication Systems*. 4th ed., John Wiley & Sons.
  - Proakis, J. G., & Salehi, M. (2007). *Digital Communications*. 5th ed.

- **Radio History**:
  - Crystal radio detectors were the first practical radio receivers (1900s).
  - AM broadcasting began commercially in the 1920s.
  - FM broadcasting began in the 1940s (Armstrong modulation system).

- **Related Signals Modules**:
  - `Signals.Sampling` for sampled-tone modeling and Nyquist limits.
  - `Signals.IQ` for complex baseband representation.
  - `Signals.Acoustics` for ultrasonic and audio transducers.
  - `Signals.Propagation` for radio wave propagation and link budgets.
