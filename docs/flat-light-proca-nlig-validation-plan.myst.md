---
title: Flat Light, Proca, and N-LIG Waveguide Validation Plan
description: >-
  A falsifiable, dataset-backed validation plan for the Flat Light and
  nitrogen-doped laser-induced graphene waveguide hypothesis.
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
3. **Proca/Flat Light claim:** an additional massive-vector or zero-diffraction
   signature remains after the classical material and waveguide model is
   calibrated, with a transferable mass parameter, a matched longitudinal
   polarization prediction, and independent replication.

A classical effective photon mass, plasma cutoff, photonic-crystal band edge,
slow-light mode, plasmon-polariton, or anisotropic dielectric response is not
by itself a fundamental Proca photon mass. A finite-aperture Bessel or Airy
beam is not zero diffraction. A phase-dependent chemical response is not a
phase-slip cleavage mechanism until absorbed energy, temperature, carrier
excitation, and ordinary photochemistry are matched.

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

## What Would Count as Evidence?

| Claim | Minimum positive result | Mandatory classical alternative | Rejection condition |
| --- | --- | --- | --- |
| N-LIG material | Raman/XPS/SEM or AFM/electrical/optical measurements match a preregistered batch specification | Unirradiated lignin, non-nitrogen LIG, and commercial graphene controls | Composition or properties are not reproducible across batches |
| Classical waveguide | Measured complex $S_{11}/S_{21}$ or optical transfer, mode profile, loss, group delay, and polarization agree with Maxwell/material simulation | Fused silica, silicon photonics, ordinary graphene, and geometry-only waveguides | Classical model explains the result within uncertainty |
| Effective mass/cutoff | A stable dispersion parameter improves prediction over H0 and transfers across geometry | Photonic-crystal cutoff, plasma frequency, plasmon-polariton, slow-light, and anisotropic-index fits | Parameter tracks geometry, loss, or material dispersion |
| Fundamental Proca mode | Nonzero longitudinal field plus the Proca dispersion and a transferable $m_\gamma$ | Classical TM mode, near-field probe cross-talk, anisotropy, and boundary-charge artifacts | No longitudinal mode, no transferable mass, or power/phase mismatch |
| Flat Light | Aperture-matched PSF/MTF broadening remains below the preregistered bound over distance | Gaussian, Bessel, Airy, self-healing, and ordinary guided modes | Broadening, side-lobe power, or resolution follows classical propagation |
| Phase-slip cleavage | Blinded chemical endpoint exceeds matched classical dose/temperature controls and tracks an independent phase-slip observable | UV/EUV, thermal, acoustic, carrier, photochemical, and mask-on/off controls | Cleavage follows absorbed energy or ordinary photochemistry |

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

### WP7: Independent propagation and astrophysical nulls

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

### WP8: Blind replication and public release

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
7. a blinded phase-slip/resist analysis that keeps chemistry separate from
   field residuals;
8. a report generator with source DOI, license, checksum, schema, and
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
    "nanolithography"
  ],
  "dateModified": "2026-09-18"
}
```
