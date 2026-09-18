---
title: Flat Light, Proca, and N-LIG Waveguide Validation Plan
description: >-
  A falsifiable, dataset-backed validation plan for Flat Light, N-LIG
  waveguides, and multi-beam holography.
---

# Flat Light, Proca, and N-LIG Waveguide Validation Plan

## Executive Summary

This document turns the Flat Light proposal into a staged experimental and
computational adjudication program. Here, **prove** means satisfy preregistered
measurement, calibration, replication, and model-comparison criteria. It does
not mean that a chat proposal, a fitted effective index, or a visually sharp
beam is treated as proof of a new field.

The proposal combines three different claims that must be separated:

1. **Material claim:** a reproducible nitrogen-doped laser-induced graphene
   (N-LIG) or lignin-derived carbon structure can be fabricated with the stated
   composition, conductivity, optical response, and defect statistics.
2. **Guided-mode claim:** the material and geometry support a measured classical
   optical or terahertz mode with a known propagation constant, loss, group
   delay, polarization, and mode profile.
3. **Multi-beam holography claim:** a phase-retrieved hologram can synthesize
  four or more independently addressable beams, locate a target by
  trilateration, and improve target-plane fidelity when an rGO-vitrimer mask
  is activated.
4. **Low-power CW N-LIG success claim:** graphene formation on lignin at the
  lowest reproducible continuous-wave optical input, with measured sheet
  resistance, Raman/XPS signature, pattern fidelity, and heat-affected zone.
  A successful result here is valuable even if every optical field remains
  classical.
5. **Proca/Flat Light claim:** an additional massive-vector or zero-diffraction
  signature remains after the classical material and waveguide model is
  calibrated, with a transferable mass parameter, a matched longitudinal
  polarization prediction, and independent replication.

A classical effective photon mass, plasma cutoff, photonic-crystal band edge,
slow-light mode, plasmon-polariton, or anisotropic dielectric response is not
by itself a fundamental Proca photon mass. A finite-aperture Bessel or Airy
beam is not zero diffraction. A phase-dependent chemical response is not a
phase-slip cleavage mechanism until absorbed energy, temperature, carrier
excitation, and ordinary photochemistry are matched.

For this application, the first engineering success should be the least
extraordinary one: reproducible graphene-on-lignin processing with a lower-power
CW laser and a measured process window. A nominal 20 W fiber laser is an upper
bound for the initial apparatus, not a required threshold. If $N$ independently
calibrated beams share total power $P_{\mathrm{total}}$, report both total and
per-beam power $P_j$; convergence can improve spatial dose uniformity but cannot
create energy or silently replace absorbed-dose accounting.

## Provenance and Claim Boundary

The local scholarly overview describes a CW master oscillator, an N-LIG
cellulose waveguide, a high-effective-mass non-diffracting state, an rGO mask,
and phase-slip resist cleavage as **pending speculative mechanisms**
([existing Flat Light overview](flat-light-nanolithography-scholarly.myst.md#L9-L30)).
The primary chat provenance includes a request to use longitudinally polarized
Proca waves and explicitly discusses an effective mass and a third polarization
state ([IQ-Sampling chat](../data/chats/IQ-Sampling-for-Signal-Phase.json#L104-L120)),
as well as N-LIG waveguides and nanolithographic use
([IQ-Sampling chat](../data/chats/IQ-Sampling-for-Signal-Phase.json#L170-L190)).
The same export contains the Flat Light/effective-mass framing
([IQ-Sampling chat](../data/chats/IQ-Sampling-for-Signal-Phase.json#L240-L260)).

The waveguide discussion in the corpus treats resonant structures as coupled
oscillators and proposes dielectric waveguide behavior
([waveguide chat](../data/chats/_Pyramid%20Star%20Shafts_%20Waveguides%20and%20Resonance%20.json#L27-L31),
[waveguide chat](../data/chats/_Pyramid%20Star%20Shafts_%20Waveguides%20and%20Resonance%20.json#L76-L88)).
Those lines are provenance for the hypothesis, not evidence that the proposed
structures or mechanisms exist.

The material chat correctly identifies lignin-derived LIG as sensitive to
precursor heterogeneity, laser fluence, ablation, oxidation, and defects
([LIG defect-control chat](../data/chats/_Preventing-LIG-Defects-on-Lignin.json#L11-L27)).
Those variables become controlled factors in this plan rather than assumed
properties of N-LIG.

The current Lean boundary is deliberately weaker than the proposal. `ProcaChannel`
and `ProcaControlField` carry a longitudinal mode, coupling, power, and
frequency as supplied model data ([Pending.lean](../src/signals/Signals/Pending.lean#L1345-L1400)).
`FlatLightLithography` records positive effective mass and idealized zero blur,
while `PhaseSlipCleavage` records a supplied rate law
([Pending.lean](../src/signals/Signals/Pending.lean#L2126-L2162)). These are
contracts to be tested, not existence theorems.

## Accepted Mechanics and Pending Contracts

The library already separates accepted mechanics from speculative extensions:

- `Signals.Maxwell.System` derives charge continuity from Gauss, Faraday, and
  Ampere-Maxwell equations; an added SQG current is a separate source term,
  not free energy ([Maxwell.lean](../src/signals/Signals/Maxwell.lean#L20-L95),
  [Pending.lean](../src/signals/Signals/Pending.lean#L953-L1020)).
- `Signals.MHD.MHDPowerAccounting` requires output plus losses to equal control
  plus motive input and proves ordinary efficiency is at most one when total
  input is positive ([MHD.lean](../src/signals/Signals/MHD.lean#L167-L246)).
- `Signals.Pending.ArgonMHDPlant` identifies motive input with classical Argon
  kinetic power, while `ProcaMHDHypothesis` keeps optical control power separate
  from motive power ([MHD.lean](../src/signals/Signals/MHD.lean#L250-L300),
  [Pending.lean](../src/signals/Signals/Pending.lean#L1403-L1460)).
- `Signals.Pending.ActiveOpticalAmplifier` and the OPA record include pump power,
  dissipation, and signal output; gain above one is active amplification, not
  passive energy creation ([ActiveOptics.lean](../src/signals/Signals/ActiveOptics.lean#L25-L88)).
- `EnergyLedger` and `SpacetimeExtractionClaim` make a claimed excess over
  control plus fuel require an explicitly positive additional source; they do
  not prove that a spacetime source exists ([Pending.lean](../src/signals/Signals/Pending.lean#L2271-L2305)).
- `HelicalBeamApparatus` records classical q-plate/SLM/vector-vortex
  bookkeeping, OAM charge, polarization purity, longitudinal near-field
  fraction, alignment, and source/mode calibration. Its beam-power bound and
  calibration predicates do not assert Proca propagation
  ([Pending.lean](../src/signals/Signals/Pending.lean#L1815-L1875)).

The literature supports the same division. Poynting-theorem energy balance is
the classical accounting boundary; parametric and second-harmonic amplifiers
are pump-driven systems; and dynamical-Casimir observations in superconducting
circuits are driven, time-dependent boundary experiments. Relevant anchors are
DCE in superconducting circuits (Wilson et al., DOI
`10.1038/nature10561`; Johansson et al., DOI `10.1103/physreva.82.052509`),
active optical amplification and nonlinear optics (Boyd, *Nonlinear Optics*,
and the project’s `ActiveOptics.lean` record), and photon-mass propagation
constraints from FRB catalogs (Bonetti et al., DOI `10.3847/2041-8205/822/1/l15`;
Wu et al., DOI `10.1103/PhysRevD.95.123010`). None of these references supports
passive over-unity output or a laboratory Proca detection.

The `EnergyExtractionEvidence` contract records control, motive, pump,
auxiliary, exported, loss, and stored-energy channels, plus calibration,
negative controls, replication, and a residual tolerance. A candidate
additional-source result is accepted only as a supplied interpretation after
those fields are measured; the contract deliberately does not manufacture a
vacuum-power term.

## Hypotheses

### H0: Calibrated classical model

The measured output is explained by the material, geometry, source, detector,
and environment:

$$
y(t,\mathbf r) = y_{\mathrm{Maxwell+material}}(t,\mathbf r;\theta)
                 + y_{\mathrm{thermal}} + y_{\mathrm{detector}}
                 + \epsilon.
$$

The H0 model must include complex permittivity and permeability, conductivity,
roughness, temperature, nonlinear response, waveguide boundary conditions,
source phase noise, detector response, and missing-data rules.

### H1: Effective guided-mode mass or cutoff

An engineered medium may have a mode dispersion that can be written locally as

$$
\omega^2 = c^2 k^2 + \omega_{\mathrm{eff}}^2,
$$

where $\omega_{\mathrm{eff}}$ is a cutoff or effective-medium parameter. This
is a useful engineering fit. It is not a fundamental photon mass unless the
same parameter survives changes of geometry, material, boundary condition,
and propagation environment and is accompanied by the predicted field degrees
of freedom.

### H2: Fundamental Proca photon mass

Define

$$
\omega_m = \frac{m_\gamma c^2}{\hbar}.
$$

A free massive vector mode would satisfy

$$
\omega^2 = c^2 k^2 + \omega_m^2,
\qquad
v_g = c\sqrt{1 - \frac{\omega_m^2}{\omega^2}}.
$$

The device claim is supported only if a nonzero $\omega_m$ improves the fit
against H0 and H1, is stable across independent devices and media, predicts
longitudinal field content with the correct phase and power, and survives
external propagation controls. A fitted $\omega_m$ that changes with waveguide
cutoff is classified as an effective mode parameter.

### H3: Flat Light / zero-diffraction limit

For a declared input aperture, wavelength, polarization, power, and propagation
interval, define a measured second-moment radius $w(z)$, point-spread function
(PSF), modulation-transfer function (MTF), and encircled-power radius. The
strict claim is not "the image looks sharp"; it is

$$
\Delta w(z) = w(z)-w(0) = 0
$$

within a preregistered uncertainty bound over the declared interval. A finite
experiment can only establish an upper bound on broadening. The controls must
include Gaussian, Bessel, Airy, fiber, and ordinary photonic-crystal modes with
the same aperture and detector sampling.

### H4: Phase-slip lithography

The proposed phase-slip channel must add a reproducible chemical rate term
beyond ordinary absorbed-photon, carrier, and thermal chemistry:

$$
R_{\mathrm{cleavage}}
 = R_{\mathrm{Beer-Lambert+thermal}}(P_{\mathrm{abs}},T,t,\theta)
 + \kappa_{\mathrm{slip}} q_{\mathrm{slip}}(t,\mathbf r).
$$

$q_{\mathrm{slip}}$ must be measured independently from the receiver residual;
it cannot be defined as the residual after the fact.

### H5: Multi-beam holography and activated-mask ablation

The holography subclaim is a classical inverse-propagation hypothesis before it
is a metamaterial or Proca hypothesis. For $N\geq4$ phase-locked beams, solve a
measured propagation model for a target field $U_t$:

$$
U(\mathbf r,z) = \mathcal P_z\left[
  M_s(\mathbf r)\sum_{j=1}^{N} A_j(\mathbf r)
  e^{i(\mathbf k_j\cdot\mathbf r+\phi_j(\mathbf r))}
\right],
$$

where $M_s$ is the measured mask-state transfer function. The mask-state
factor is randomized and recorded:

- `S0`: no mask or transparent substrate;
- `S1`: fabricated but passive rGO-vitrimer mask, activation drive off;
- `S2`: activated rGO-vitrimer mask under the preregistered control input;
- `S3`: sham activation, detuned drive, or spatially displaced activation with
  matched power and temperature.

Gerchberg-Saxton or weighted Gerchberg-Saxton is the classical reconstruction
baseline. It can explain a successful multi-spot pattern through ordinary
Fourier optics and therefore cannot establish an activated metamaterial or a
Proca field. The activated-mask claim requires a paired improvement from `S1`
to `S2` that survives `S3`, measured transmission/phase calibration, source
power matching, temperature control, and independent replication.

For a point target, estimate location from independent ranges or wavefront
sensors, not from the intended hologram. With beam origins $\mathbf p_j$ and
measured ranges $\rho_j$, use

$$
\widehat{\mathbf r} = \arg\min_{\mathbf r,b}
\sum_{j=1}^{N}
\frac{\left(\|\mathbf r-\mathbf p_j\|-\rho_j-b\right)^2}{\sigma_j^2},
$$

where $b$ is a shared timing/path-delay nuisance parameter. The primary
endpoints are 3D position error/covariance, complex target-plane field RMSE,
spot uniformity, side-lobe ratio, crosstalk, axial/lateral resolution, phase
synchronization residual, and delivered/absorbed power. This is a holography
and metrology result; it enters the Proca evidence path only through the
independent dispersion and polarization tests in H2 and WP4.

## What Would Count as Evidence?

| Claim | Minimum positive result | Mandatory classical alternative | Rejection condition |
| --- | --- | --- | --- |
| N-LIG material | Raman/XPS/SEM or AFM/electrical/optical measurements match a preregistered batch specification | Unirradiated lignin, non-nitrogen LIG, and commercial graphene controls | Composition or properties are not reproducible across batches |
| Low-power CW N-LIG | A reproducible graphene signature and sheet resistance are obtained while stepping CW power downward and measuring fluence, scan speed, HAZ, and temperature | Pulsed/UV and higher-power CW references, unexposed lignin, and sham scans | No graphene conversion below the declared power, or apparent conversion is thermal damage/char |
| Classical waveguide | Measured complex $S_{11}/S_{21}$ or optical transfer, mode profile, loss, group delay, and polarization agree with Maxwell/material simulation | Fused silica, silicon photonics, ordinary graphene, and geometry-only waveguides | Classical model explains the result within uncertainty |
| Effective mass/cutoff | A stable dispersion parameter improves prediction over H0 and transfers across geometry | Photonic-crystal cutoff, plasma frequency, plasmon-polariton, slow-light, and anisotropic-index fits | Parameter tracks geometry, loss, or material dispersion |
| Fundamental Proca mode | Nonzero longitudinal field plus the Proca dispersion and a transferable $m_\gamma$ | Classical TM mode, near-field probe cross-talk, anisotropy, and boundary-charge artifacts | No longitudinal mode, no transferable mass, or power/phase mismatch |
| Flat Light | Aperture-matched PSF/MTF broadening remains below the preregistered bound over distance | Gaussian, Bessel, Airy, self-healing, and ordinary guided modes | Broadening, side-lobe power, or resolution follows classical propagation |
| Phase-slip cleavage | Blinded chemical endpoint exceeds matched classical dose/temperature controls and tracks an independent phase-slip observable | UV/EUV, thermal, acoustic, carrier, photochemical, and mask-on/off controls | Cleavage follows absorbed energy or ordinary photochemistry |
| Multi-beam holography | Four-or-more-beam target fidelity and independent trilateration improve under the activated-mask state with matched power and temperature | Gerchberg-Saxton, weighted GS, angular-spectrum propagation, no-mask, passive-mask, and sham-activation controls | Error is explained by phase retrieval, ordinary mask diffraction, detector sampling, power redistribution, or activation drift |

## Significance of the Model Layers

The model layers answer different questions. Lignin-to-graphene conversion is a
materials and process result. A CW fiber laser, a q-plate, a spatial light
modulator, and a phase mask are classical apparatus components. A helical beam
has a measurable azimuthal phase factor $e^{i\ell\phi}$ and can improve focusing,
mode selectivity, or multi-beam addressing; it does not imply a massive photon.
An rGO-vitrimer mask can be a useful electro-thermal or thermo-optic phase
modulator without being a Proca metamaterial. Only a residual field signature
that survives these classical explanations enters the Proca branch.

## Open Dataset Register

The datasets below are open or publicly archived inputs for calibration and
null testing. They do not prove Proca physics. Each downloaded artifact must
retain its URL/DOI, license, retrieval date, file checksum, schema, units, and
processing script.

| Source | Access and attribution | Fields/use in this plan | Boundary |
| --- | --- | --- | --- |
| [Zenodo WDM-MZI silicon photonics dataset](https://doi.org/10.5281/zenodo.22819801) | CC BY 4.0; `WDM-MZI-Silicon-Photonics-Data.zip`; MD5 `86e2e1f949fab4d969f8441eba772bfe`; acquired local SHA-256 `d57ab4932fa8bef635f22377007103e69050ff12e54a99cc1a57948cf965ead9` | Spectral responses, directional couplers, Y-splitters, eye diagrams, and scripts for validating classical transfer, group delay, passbands, and signal-quality analysis | Simulated/classical silicon-photonics control, not N-LIG or Proca evidence |
| [Figshare LIG comparison record](https://doi.org/10.6084/m9.figshare.33483753) | CC BY 4.0; supplementary DOCX, file `ymte_a_2728021_sm1745.docx`; acquired local SHA-256 `f1ce6531b1448d71720f0310523c2cfea7972378dbba7d7a8d925c9163f5405a` | Open laser-induced-graphene process/characterization comparison on a non-lignin polymer substrate; use to test the acquisition and spectroscopy pipeline | Not lignin-derived N-LIG; use as a positive process control only |
| [Zenodo polymer-to-graphene record](https://doi.org/10.5281/zenodo.21389501) | CC BY 4.0; figures and README | Processing taxonomy, graphitization, heteroatom, and precursor comparison context | Review/supporting figures, not a raw quantitative N-LIG dataset |
| [RefractiveIndex.INFO](https://refractiveindex.info/about) and [raw silica YAML](https://refractiveindex.info/database/data/main/SiO2/nk/Malitson.yml) | Database CC0; cite Polyanskiy, *Sci. Data* 11, 94 (2024), DOI `10.1038/s41597-023-02898-2`; acquired local SHA-256 `6b0e570b582a96f68c3f43400f942284afde1a579e95001cac6ffa3049b0e0bd` | Complex optical constants, dispersion, group index, and baseline material fits for classical Maxwell/FDTD/FEM models | Does not provide N-LIG constants; measured N-LIG ellipsometry/THz data are still required |
| [GWOSC public datasets](https://gwosc.org/data/) | Public releases are listed with CC BY 4.0 data terms and acknowledgement requirements; acquired event-catalog metadata local SHA-256 `b2e3db64abb2c86be05a6a86e4cee740b048ca56a9d62fd5d553b34e0d59f12d` | Open strain/time-series and auxiliary data for timing, calibration, cross-correlation, and propagation null methodology | Gravitational-wave data are not a direct optical Proca test |
| [CHIME/FRB Catalog 1 archive](https://www.canfar.net/storage/list/AstroDataCitationDOI/CISTI.CANFAR/21.0007/data) and [Baseband Catalog 1](https://doi.org/10.11570/23.0029) | Public archival records; follow each archive's current access and citation terms | Burst arrival times, frequencies, dispersion measures, polarization, and high-time-resolution morphology for an independent frequency-dependent propagation constraint | Plasma dispersion, source structure, and calibration are degenerate with a photon-mass delay; a bound is not a detection |
| [JHTDB channel cutout](https://doi.org/10.7281/T10K26QW) | ODC-By; project-verified HDF5/XMF artifacts and checksums in [OPEN_FLOW_DATASETS.md](../src/signals/OPEN_FLOW_DATASETS.md#L32-L70) | Reusable provenance, interpolation, convergence, and numerical-flow-map controls for the project pipeline | Solver-produced fluid data, not optical or Proca evidence |
| [Zenodo cylinder PIV](https://doi.org/10.5281/zenodo.20765567) and [RSPID](https://doi.org/10.5281/zenodo.7832205) | CC BY 4.0; project readers and checksums documented in [OPEN_FLOW_DATASETS.md](../src/signals/OPEN_FLOW_DATASETS.md#L70-L115) | Missing-mask, reproducibility, and flow-map software controls | Measured/synthetic fluid controls, not waveguide evidence |

### Acquisition policy

Use the workspace-local `.tmp/` directory for downloads and never commit raw
large artifacts or credentials. Example bounded acquisitions:

```bash
mkdir -p .tmp/flat-light && chmod 1777 .tmp/flat-light
curl -L 'https://zenodo.org/api/records/22819801/files/WDM-MZI-Silicon-Photonics-Data.zip/content' \
  -o .tmp/flat-light/WDM-MZI-Silicon-Photonics-Data.zip
printf '%s  %s\n' \
  '86e2e1f949fab4d969f8441eba772bfe' \
  .tmp/flat-light/WDM-MZI-Silicon-Photonics-Data.zip | md5sum -c -
curl -L 'https://ndownloader.figshare.com/files/68363334' \
  -o .tmp/flat-light/lig-pesf-supplement.docx
curl -L 'https://refractiveindex.info/database/data/main/SiO2/nk/Malitson.yml' \
  -o .tmp/flat-light/SiO2-Malitson.yml
```

The WDM and LIG comparison files are controls, not device validation. The
first N-LIG-specific experiment should publish raw Raman/XPS/SEM/AFM/electrical/
optical files with an open license or a clearly documented access exception.

## Experimental Work Packages

### WP0: Preregister the claim and model comparison

Record sample composition, nitrogen source, lignin lot, film thickness,
substrate, laser wavelength, pulse duration, fluence, scan speed, atmosphere,
humidity, temperature, waveguide geometry, source power, detector calibration,
and mask settings before looking at residuals.

The primary endpoint must be selected in advance. Recommended primary endpoints
are:

- classical fit residual in complex transfer data;
- independent longitudinal-to-transverse field ratio;
- cross-device fitted $\omega_m$ with uncertainty;
- aperture-normalized PSF broadening;
- blinded excess cleavage rate after matched absorbed energy.

Declare exclusions, stopping rules, batch count, calibration uncertainty, and
whether a result is intended to estimate a parameter or test a null.

### WP1: Fabricate and characterize N-LIG

Use a factorial material matrix rather than one optimized sample:

- lignin type and ash/moisture content;
- nitrogen precursor and nitrogen loading;
- laser wavelength, fluence, pulse overlap, and defocus;
- air, nitrogen, argon, and forming-gas atmosphere;
- film thickness, binder fraction, and post-anneal;
- unirradiated lignin, non-N LIG, N-LIG, and commercial graphene controls.

Measure Raman $D/G$, $2D$ shape, XPS C/N/O bonding, SEM/AFM morphology,
four-point-sheet resistance, Hall response where possible, thickness, contact
resistance, optical absorption/ellipsometry, and THz conductivity. Preserve
raw spectra and images, calibration files, sample map, and batch identifiers.

Acceptance is material reproducibility and a complete uncertainty budget. It is
not evidence of a guided Proca mode.

### WP1A: Find the lowest-power CW N-LIG process window

Use a calibrated fiber-laser or diode-laser source with a nominal ceiling of
20 W, but begin below that ceiling and step downward. A useful first matrix is
0.5, 1, 2, 5, 10, and 20 W total source power, with scan speed, spot area,
line overlap, wavelength, duty factor, atmosphere, and substrate thickness
recorded for every run. The actual dose is the primary variable:

$$
F = \frac{P_{\mathrm{abs}}}{v_{\mathrm{scan}} w_{\mathrm{spot}}},
\qquad
P_{\mathrm{abs}} = \eta_{\mathrm{abs}} P_{\mathrm{incident}}.
$$

For each power step, measure Raman $D/G$ and $2D$, XPS C/N/O bonding, sheet
resistance, thickness, morphology, HAZ width, substrate temperature, and
pattern continuity. Use pulsed UV/femtosecond and higher-power CW references to
separate photochemical or multiphoton conversion from ordinary thermal
carbonization. The minimum-power success point is the lowest total power whose
confidence interval meets the preregistered graphene, resistance, continuity,
and HAZ thresholds across independent batches.

Do not call a darkened, ablated, or electrically discontinuous track graphene.
Do not call a lower laser power an efficiency improvement until absorbed power,
throughput, yield, cooling, and post-processing energy are included.

### WP2: Establish the classical guide

Build a geometry-matched Maxwell model using measured complex material constants.
Measure either optical transfer or calibrated microwave/terahertz $S$-parameters
across frequency, length, temperature, input polarization, and bend radius.
Acquire near-field or end-fire mode maps and measure group delay:

$$
E_m(x,y,z,t) = e_m(x,y;\omega)\exp[i\beta_m(\omega)z-i\omega t],
\qquad
\tau_g = L\frac{d\beta_m}{d\omega}.
$$

Fit $\beta_m(\omega)$, insertion loss, phase delay, Q, mode overlap, and
polarization. Validate the analysis on the CC BY WDM-MZI dataset and
RefractiveIndex.INFO before interpreting N-LIG measurements.

H0 passes when measured responses, including loss and mode conversion, are
predicted within the preregistered uncertainty by the measured-material
classical model. H0 passing is a successful classical result, not a failure of
the project.

### WP2A: Build and calibrate the helical-beam apparatus

The helical apparatus is a classical vector-vortex measurement system. Use a
CW fiber or diode source up to 20 W, attenuated during alignment, followed by:

1. beam expander and spatial filter;
2. polarization cleanup and power monitor;
3. q-plate, geometric-phase plate, or phase-only SLM for radial/azimuthal
  vector polarization and OAM charge $\ell$;
4. optional four-way splitter/star coupler with independently calibrated phase
  shifters;
5. rGO-vitrimer mask in passive and activated states, plus ordinary SLM and
  dielectric phase-plate controls;
6. relay/focusing optics, wavefront sensor, polarization camera, power meter,
  and independent position/range sensors;
7. target plane with thermal, chemical, AFM/SEM, or camera readout.

Measure Stokes parameters, phase residual, OAM spectrum, topological-charge
fidelity, longitudinal near-field fraction, insertion loss, alignment error,
thermal drift, and power at every plane. The apparatus is ready only when
source, polarization, and mode calibrations are independently recorded. A
measured $E_z$ component from tight focusing or an evanescent field is a
classical result unless the Proca-specific dispersion and polarization tests
also pass.

For four or more convergent beams, compare total-power and per-beam-power
scaling. The useful engineering question is whether distributing a fixed total
power improves target uniformity, HAZ, and throughput; it is not whether beam
convergence creates energy.

### WP3: Test an effective mass without calling it fundamental

Fit three nested models to the same data:

1. Maxwell plus measured dispersive material;
2. Maxwell plus waveguide cutoff/plasma/photonic-crystal parameters;
3. Proca-like dispersion with a common $\omega_m$.

Use held-out frequencies and a held-out device. Compare likelihood, residual
structure, parameter stability, and predictive coverage. A Proca-like fit must
not be allowed to absorb unknown cable delay, thermal drift, substrate
roughness, or detector phase.

Repeat the fit after changing guide length, cross-section, cladding, nitrogen
loading, and surrounding medium. If the fitted mass changes with geometry or
tracks a classical cutoff, classify it as an effective mode parameter.

### WP4: Polarization and longitudinal-mode test

Use polarization-resolved near-field probes, calibrated interferometry, or
vector network analysis to measure the full field vector. The longitudinal
claim requires all of:

- a reproducible component parallel to the propagation vector;
- the phase and amplitude relation predicted by the chosen Proca model;
- a nonzero result after probe cross-talk and boundary-charge subtraction;
- frequency scaling consistent with one mass parameter;
- power and energy accounting for all drive, absorption, and detector channels;
- disappearance or transformation under controls that should remove the
  effective medium but not a fundamental field.

Classical TM modes, plasmonic modes, anisotropic media, evanescent fields, and
near-field probe loading are mandatory positive controls because they can all
produce apparent longitudinal electric fields.

### WP5: Measure the Flat Light claim

Use the same input aperture, numerical aperture, wavelength, polarization, and
power for N-LIG, ordinary dielectric, Bessel, Airy, and Gaussian controls.
Measure beam/guide cross-sections at multiple propagation distances and compute
PSF, MTF, second-moment width, encircled energy, side-lobe energy, wavefront
error, and pointing drift.

Report resolution as a function of distance and aperture. A finite-energy
non-diffracting beam may preserve a central lobe over a finite zone while moving
power into side lobes; that is not zero diffraction. The primary result should
be an upper confidence bound on $\Delta w(z)$, not an exact zero.

Reject the Flat Light claim if broadening or resolution is predicted by the
classical guide model, if the result depends on aperture truncation, or if
side-lobe energy is omitted from the resolution metric.

### WP6: Test phase-slip lithography

Use a blinded, randomized sample layout with:

- no exposure;
- classical UV/EUV or visible exposure at matched absorbed energy;
- N-LIG guide with the proposed phase control off;
- N-LIG guide with phase control on;
- thermal-only and acoustic-only controls;
- mask-on/off and detuned-frequency controls;
- an ordinary waveguide with the same source and detector.

Measure absorption, temperature, carrier density, local electric field, Raman
changes, FTIR/XPS chemistry, mass loss, bond fragments, AFM/SEM pattern geometry,
and resist contrast. Register the spatial dose map and the chemical endpoint
separately.

A phase-slip result requires an excess chemical rate after ordinary absorbed
energy, heat, photochemistry, carrier excitation, and mechanical stress are
matched. An atomic-scale image without a calibrated point-spread function and
chemical control is insufficient.

### WP7: Test multi-beam holography and trilateration

The chat corpus discusses holographic spatial-light-modulator splitting into
eight or more spots, Gerchberg-Saxton/weighted Gerchberg-Saxton phase retrieval,
and an rGO-vitrimer phase modulator ([rGO-vitrimer holography chat](../data/chats/_rGO-Vitrimer%20Applications%20and%20Properties%20.json#L528-L583)).
Related laser-engraving and metamaterial conversations describe computer-
generated holography, beam arrays, and phase-mask pre-distortion
([laser-engraving holography chat](../data/chats/_Laser-Engraving-circuits-on-Lignin-and-other-materials%20(1).json#L475-L537),
[metamaterial holography chat](../data/chats/_Ball%20Milling%20Metal%20Under%20Protective%20Gas%20.json#L620-L675)).
These records establish proposal provenance only.

Use at least four mutually non-coplanar or independently phase-addressable
beams, with recorded source phase, power, polarization, waist, numerical
aperture, incidence vector, coherence, and timing. Compare four mask states:

1. `S0`: no mask or transparent substrate;
2. `S1`: fabricated rGO-vitrimer mask, activation off;
3. `S2`: activated rGO-vitrimer/metamaterial mask;
4. `S3`: sham, detuned, displaced, or thermally matched activation.

Measure the mask transfer function for each state: amplitude, phase,
polarization conversion, insertion loss, temperature, resistance, switching
latency, hysteresis, and recovery. Include an ordinary SLM, DMD, dielectric
phase plate, or calibrated static diffractive optic with the same nominal phase
pattern as a classical positive control.

Use Gerchberg-Saxton, weighted Gerchberg-Saxton, and direct angular-spectrum or
adjoint optimization as separate solvers. Record initial phase, iteration
count, target amplitude, propagation operator, sampling grid, regularization,
and held-out target patterns. Do not tune the solver on the final masked-state
endpoint.

For each state and beam count, measure target-plane complex field, intensity,
PSF/MTF, spot centroid and width, side-lobe power, inter-spot crosstalk,
wavefront error, axial/lateral resolution, and total delivered/absorbed power.
Use independent phase/time-of-flight or wavefront sensors for trilateration.
With beam origins $\mathbf p_j$ and measured ranges $\rho_j$, report the
solution and covariance from:

$$
\widehat{\mathbf r} = \arg\min_{\mathbf r,b}
\sum_{j=1}^{N}
\frac{\left(\|\mathbf r-\mathbf p_j\|-\rho_j-b\right)^2}{\sigma_j^2},
\qquad N\geq4.
$$

Primary comparisons are paired `S2-S1` and `S2-S3` differences with identical
beam phases, power, target, detector, and temperature. Randomize mask-state
order, blind target patterns, and reserve devices and target geometries for
held-out evaluation. A lower error in `S2` is a classical activated-mask result
unless an independent longitudinal field, transferable dispersion parameter,
and energy-accounted coupling also satisfy H2/H3/WP4.

Reject the activated-metamaterial interpretation when Gerchberg-Saxton or the
ordinary measured transfer model predicts the result, when improvement vanishes
after transmission/phase/temperature matching, when `S2` and `S3` are
indistinguishable, or when the apparent trilateration gain is caused by detector
recalibration, aperture truncation, phase wrapping, source drift, or side-lobe
power omitted from the metric.

### WP8: Test energy extraction and over-unity claims

An over-unity claim is a closed measurement problem, not an output-versus-
control-power ratio. Preregister the observation window and measure every
channel at the same time base:

$$
P_{\mathrm{out}} + P_{\mathrm{loss}} + \frac{dE_{\mathrm{stored}}}{dt}
 = P_{\mathrm{control}} + P_{\mathrm{motive}} + P_{\mathrm{pump}}
   + P_{\mathrm{aux}} + P_{\mathrm{unmodeled}}.
$$

The primary energy-extraction endpoint is the posterior or confidence interval
for $P_{\mathrm{unmodeled}}$ after calibration and nuisance terms, not a
control-only Q-factor. Measure electrical input with four-wire power analyzers,
optical/RF pump power at the device plane, gas or fluid mass flow and enthalpy,
mechanical torque/force where applicable, auxiliary pumps and cooling, thermal
storage, chemical/fuel inventory, exported electrical power, radiated power, and
all relevant electromagnetic/acoustic leakage.

For any DCE, parametric, OPA, or active-metamaterial test, the modulation drive
is an input channel. Compare passive, static-boundary, actively pumped, and
detuned controls. A signal generated by a time-dependent boundary can be a
valid actively pumped quantum-optical result while still obeying the complete
ledger; it is not passive vacuum-energy extraction.

Required controls and stopping rules:

- zero-output dummy load with the same meters and cabling;
- source-only, device-only, and pump-only runs;
- activation off/on and detuned-frequency runs with matched temperature;
- storage-energy discharge and charge-cycle tests;
- blind meter-swapping and independent calorimetry;
- at least three independent replications and held-out operating points;
- abort if any channel is unmeasured, saturated, phase-uncalibrated, or
  excluded after seeing the residual.

Classify results as `classicalConversion`, `activelyPumped`, `unresolvedLedger`,
or `candidateAdditionalSource`. Promote the last category only when the
complete ledger residual is outside tolerance, the negative control passes,
storage change is accounted for, calibration is independent, and replication
survives. A positive residual is an anomaly candidate, not evidence of SQG,
DCE vacuum extraction, Proca coupling, or over-unity power until those gates
are met.

### WP9: Independent propagation and astrophysical nulls

Use the public CHIME/FRB catalogs as an external constraint on frequency-
dependent propagation. Fit the standard plasma dispersion jointly with a Proca
term:

$$
\Delta t(\nu) = K_{\mathrm{DM}}\,\mathrm{DM}\,\nu^{-2}
 + \frac{D}{c}\frac{\omega_m^2}{2\omega^2}
 + \delta t_{\mathrm{source}} + \delta t_{\mathrm{instrument}}.
$$

Use independent DM estimates, multiple bursts, multiple sources, polarization,
scintillation, redshift/distance uncertainty, and instrument calibration. Because
both plasma and a small photon-mass term can produce inverse-frequency-squared
behavior, this work package is a bound or consistency test, not a device
confirmation.

Use GWOSC public data and auxiliary channels for an independent timing and
cross-correlation pipeline. Do not claim that a null in gravitational-wave data
measures optical photon mass; use it to test calibration, propagation, and false
positive controls.

### WP10: Blind replication and public release

A result can advance from Pending to a conditional physical hypothesis only
after:

- three independently fabricated batches and two independent analysis paths;
- a preregistered negative control and classical positive control;
- held-out frequencies, devices, and waveforms;
- raw data, calibration, source code, and checksums released;
- an independent laboratory replication;
- a closed energy and momentum ledger;
- no requirement for FTL, unsupported longitudinal modes, or an unmodeled
  detector channel.

## Analysis and Statistics

Use a hierarchical model with batch, device, run, and detector random effects.
Do not pool spectra or images before preserving their calibration metadata.
Report:

- complex residuals, not only magnitude;
- confidence or credible intervals for $\beta$, loss, $\tau_g$, $\omega_m$,
  longitudinal fraction, and beam broadening;
- train/validation/test splits by device and frequency;
- sensitivity to background subtraction, probe position, mask, and temperature;
- correction for multiple frequencies and multiple candidate endpoints;
- preregistered missing-data and failed-run rules.

For model selection, report H0, H1, and H2 predictions on held-out data. A
lower residual for a more flexible model is not evidence unless the complexity
penalty and out-of-sample prediction improve.

## Rejection and Promotion Criteria

### Reject the Proca/Flat Light interpretation when

- Maxwell plus measured material predicts the transfer and mode data;
- the longitudinal field disappears under probe calibration or is explained by
  a classical TM/plasmonic/evanescent control;
- the fitted mass varies with waveguide geometry, cladding, or frequency window;
- the claimed zero diffraction disappears under aperture-matched controls;
- phase-slip cleavage follows absorbed power, heat, carrier density, or ordinary
  photochemistry;
- four-or-more-beam target fidelity or trilateration is explained by
  Gerchberg-Saxton, weighted phase retrieval, ordinary mask diffraction, or
  detector/calibration changes;
- the activated rGO-vitrimer state is not distinguishable from passive, sham,
  or thermally matched states;
- the complete energy ledger requires an unmeasured channel, excludes pump or
  auxiliary power, omits stored-energy change, or fails an independent
  calorimetric/electrical replication;
- a DCE, OPA, parametric, or active-metamaterial output is reported against
  control power alone rather than against all pump and motive inputs;
- the signal does not replicate or fails held-out prediction;
- energy, momentum, or detector accounting does not close;
- the interpretation requires superluminal information transfer.

### Promote only a conditional effective-mode result when

A stable nonzero cutoff or Proca-like parameter improves held-out prediction,
but changes with the engineered medium or is fully represented by a classical
constitutive model. Label this as an effective photon mass, polariton, plasma
cutoff, slow-light mode, or photonic-crystal mode as appropriate.

### Promote only a conditional fundamental-Proca result when

A single nonzero mass parameter, polarization structure, dispersion law, power
balance, and causal propagation law survive all material, geometry, detector,
and astrophysical controls and replicate independently. Even then, report the
result as evidence for a model-compatible massive-vector field, not as proof
that the N-LIG proposal or a vacuum Proca photon exists without further tests.

## Implementation Handoff

The next repository implementation should add:

1. a source manifest for the WDM-MZI ZIP, Figshare LIG supplement,
   RefractiveIndex.INFO YAML, CHIME catalog metadata, and GWOSC release;
2. checksummed downloads under `.tmp/` with no raw artifacts committed;
3. parsers that normalize spectra, $S$-parameters, optical constants, timing,
   polarization, and calibration metadata into a common dataset contract;
4. a classical waveguide fit with held-out prediction and uncertainty;
5. a Proca nested-model fit that reports effective-cutoff versus transferable-mass
   behavior;
6. a PSF/MTF propagation analysis with aperture-matched controls;
7. a four-or-more-beam holography solver and trilateration analyzer with
  Gerchberg-Saxton/WGS baselines, `S0`-`S3` mask-state ablations, independent
  wavefront/range sensors, and held-out target patterns;
8. a power-stepped CW N-LIG process search from sub-watt/low-watt operation to
  a 20 W ceiling, with dose, HAZ, sheet resistance, Raman/XPS, yield, and
  throughput accounting;
9. a helical/vector-vortex apparatus using q-plate/SLM phase control, Stokes
  polarimetry, OAM-spectrum recovery, longitudinal near-field controls, and
  four-beam power-scaling measurements;
10. a blinded phase-slip/resist analysis that keeps chemistry separate from
   field residuals;
11. an energy-ledger report implementing `EnergyExtractionEvidence`, tracking
  storage change and pump/motive/auxiliary channels, and classifying results as
  classical, actively pumped, unresolved, or candidate additional source;
12. a report generator with source DOI, license, checksum, schema, and
   interpretation boundary for every artifact.

No implementation should populate `FlatLightLithography` or
`PhaseSlipCleavage` with physical evidence until the independent measurements,
classical controls, and replication criteria above are satisfied.

## Source Register

### Local hypothesis provenance

- [IQ-Sampling-for-Signal-Phase.json](../data/chats/IQ-Sampling-for-Signal-Phase.json#L104-L120),
  lines 104-120: longitudinal Proca and effective-mass proposal.
- [IQ-Sampling-for-Signal-Phase.json](../data/chats/IQ-Sampling-for-Signal-Phase.json#L170-L190),
  lines 170-190: N-LIG waveguide/nanolithography proposal.
- [IQ-Sampling-for-Signal-Phase.json](../data/chats/IQ-Sampling-for-Signal-Phase.json#L240-L260),
  lines 240-260: Flat Light/effective-mass framing.
- [_Pyramid Star Shafts_ Waveguides and Resonance .json](../data/chats/_Pyramid%20Star%20Shafts_%20Waveguides%20and%20Resonance%20.json#L27-L31),
  lines 27-31: coupled-oscillator and waveguide conjecture.
- [_Preventing-LIG-Defects-on-Lignin.json](../data/chats/_Preventing-LIG-Defects-on-Lignin.json#L11-L27),
  lines 11-27: LIG-on-lignin defect and processing variables.
- [Pending.lean](../src/signals/Signals/Pending.lean#L1345-L1400),
  lines 1345-1400: supplied-data Proca channel and coupling contract.
- [Pending.lean](../src/signals/Signals/Pending.lean#L2126-L2162),
  lines 2126-2162: pending Flat Light and phase-slip contracts.
- [Pending.lean helical apparatus contracts](../src/signals/Signals/Pending.lean#L1815-L1865),
  lines 1815-1865: classical OAM/helical-beam apparatus fields, power,
  polarization, alignment, and calibration boundaries.
- [Extreme dielectric nanolaser chat](../data/chats/Breakthrough-in-Extreme-Dielectric-Nanolasers.json#L53-L88),
  lines 53-88: tight-confinement $E_z$, OAM, and evanescent-coupling proposals;
  these require classical vector-field controls.
- [Convergent holography chat](../data/chats/Longitudinally-polarized-Continuous-Wave-Laser-emissions-from-Sunlight.json#L142-L173),
  lines 142-173: proposed q-plate, radial-vector, and metamaterial validation
  architecture; this is hypothesis provenance, not validation.
- [_rGO-Vitrimer Applications and Properties .json](../data/chats/_rGO-Vitrimer%20Applications%20and%20Properties%20.json#L528-L583),
  lines 528-583: multi-spot holographic SLM, Gerchberg-Saxton, and rGO-vitrimer
  phase-modulator discussion.
- [_Laser-Engraving-circuits-on-Lignin-and-other-materials (1).json](../data/chats/_Laser-Engraving-circuits-on-Lignin-and-other-materials%20(1).json#L475-L537),
  lines 475-537: computer-generated holography, beam arrays, and phase-map
  discussion.
- [_Ball Milling Metal Under Protective Gas .json](../data/chats/_Ball%20Milling%20Metal%20Under%20Protective%20Gas%20.json#L620-L675),
  lines 620-675: rGO-vitrimer/metamaterial holography and Gerchberg-Saxton
  discussion.

### External data and methods

- WDM-MZI dataset, Zenodo record `10.5281/zenodo.22819801`, CC BY 4.0,
  ZIP MD5 `86e2e1f949fab4d969f8441eba772bfe`.
- LIG comparison supplement, Figshare DOI `10.6084/m9.figshare.33483753`,
  CC BY 4.0, file `ymte_a_2728021_sm1745.docx`.
- Polymer-to-graphene processing record, Zenodo DOI
  `10.5281/zenodo.21389501`, CC BY 4.0.
- RefractiveIndex.INFO database and Polyanskiy, *Scientific Data* 11, 94
  (2024), DOI `10.1038/s41597-023-02898-2`; database CC0.
- GWOSC public data portal, <https://gwosc.org/data/>; use the release-specific
  acknowledgement and CC BY 4.0 terms.
- CHIME/FRB Catalog 1 public archive,
  <https://www.canfar.net/storage/list/AstroDataCitationDOI/CISTI.CANFAR/21.0007/data>;
  Baseband Catalog 1 DOI `10.11570/23.0029`.
- JHTDB, cylinder PIV, and RSPID provenance already recorded in
  [`OPEN_FLOW_DATASETS.md`](../src/signals/OPEN_FLOW_DATASETS.md).

## Scholarly and Dataset References

<a id="polyanskiy2024"></a> M. N. Polyanskiy, "Refractiveindex.info database of
optical constants," *Scientific Data* 11, 94 (2024),
<https://doi.org/10.1038/s41597-023-02898-2>.

<a id="gwosc"></a> Gravitational Wave Open Science Center, "Data Sets,"
<https://gwosc.org/data/>.

<a id="chimecatalog"></a> CHIME/FRB Collaboration, "Catalog 1," public data
record `CISTI.CANFAR/21.0007`,
<https://www.canfar.net/storage/list/AstroDataCitationDOI/CISTI.CANFAR/21.0007/data>.

<a id="wdmmzi"></a> Zenodo, "Simulation Data and Analysis Scripts for an
Eight-Channel WDM Demultiplexer Based on Cascaded Mach-Zehnder Interferometers
in Silicon Photonics," DOI `10.5281/zenodo.22819801`.

<a id="ligfigshare"></a> Figshare, "Impact of visible laser on graphene
formation via laser-induced graphene on polyethersulfone membranes," DOI
`10.6084/m9.figshare.33483753`.

### Chat-derived BibTeX

```bibtex
@misc{chat_iq_sampling_flatlight_2026,
  author       = {Unknown},
  title        = {IQ-Sampling-for-Signal-Phase: Proca, Flat Light, and N-LIG Waveguides},
  year         = {2026},
  howpublished = {AI chat export},
  note         = {Source: data/chats/IQ-Sampling-for-Signal-Phase.json, lines 104-120, 170-190, 240-260}
}

@misc{chat_pyramid_waveguides_2026,
  author       = {Unknown},
  title        = {Pyramid Star Shafts, Waveguides and Resonance},
  year         = {2026},
  howpublished = {AI chat export},
  note         = {Source: data/chats/_Pyramid Star Shafts_ Waveguides and Resonance .json, lines 27-31}
}

@misc{chat_lig_defects_2026,
  author       = {Unknown},
  title        = {Preventing LIG Defects on Lignin},
  year         = {2026},
  howpublished = {AI chat export},
  note         = {Source: data/chats/_Preventing-LIG-Defects-on-Lignin.json, lines 11-27}
}

@misc{chat_rgo_vitrimer_holography_2026,
  author       = {Unknown},
  title        = {rGO-Vitrimer Applications and Properties: Gerchberg-Saxton and Holography},
  year         = {2026},
  howpublished = {AI chat export},
  note         = {Source: data/chats/_rGO-Vitrimer Applications and Properties .json, lines 528-583}
}

@misc{chat_lignin_holography_2026,
  author       = {Unknown},
  title        = {Laser Engraving Circuits on Lignin: Holographic Beam Shaping},
  year         = {2026},
  howpublished = {AI chat export},
  note         = {Source: data/chats/_Laser-Engraving-circuits-on-Lignin-and-other-materials (1).json, lines 475-537}
}

@misc{chat_helical_nanolasers_2026,
  author       = {Unknown},
  title        = {Extreme Dielectric Nanolasers, Longitudinal Fields, and OAM Coupling},
  year         = {2026},
  howpublished = {AI chat export},
  note         = {Source: data/chats/Breakthrough-in-Extreme-Dielectric-Nanolasers.json, lines 53-88}
}
```

### Machine-readable provenance

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Flat Light, Proca, and N-LIG Waveguide Validation Plan",
  "isBasedOn": [
    "data/chats/IQ-Sampling-for-Signal-Phase.json",
    "data/chats/_Pyramid Star Shafts_ Waveguides and Resonance .json",
    "data/chats/_Preventing-LIG-Defects-on-Lignin.json",
    "data/chats/_rGO-Vitrimer Applications and Properties .json",
    "data/chats/_Laser-Engraving-circuits-on-Lignin-and-other-materials (1).json",
    "data/chats/_Ball Milling Metal Under Protective Gas .json",
    "https://doi.org/10.5281/zenodo.22819801",
    "https://doi.org/10.6084/m9.figshare.33483753",
    "https://refractiveindex.info/",
    "https://gwosc.org/data/"
  ],
  "about": [
    "Flat Light",
    "Proca model discrimination",
    "N-LIG materials",
    "classical waveguides",
    "multi-beam holography",
    "Gerchberg-Saxton phase retrieval",
    "rGO-vitrimer active masks",
    "trilateration",
    "nanolithography"
  ],
  "dateModified": "2026-09-18"
}
```
