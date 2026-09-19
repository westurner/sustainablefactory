# Chat Physics Catalog

This catalog reviews the Markdown chat corpus for physics and engineering
claims that could justify changes to the Lean `Signals` library. Chat exports
are design evidence, not measurements. A claim is promoted only when its
equation, calibration path, or scholarly experiment is explicit; otherwise it
stays a Pending contract or a process/product annotation.

## Triage Summary

| Disposition | Topics | Lean action |
| --- | --- | --- |
| Already covered | Soliton transport, WDM/MDM/OAM addressing, homodyne algebra, OAM counting, SHG power bookkeeping, classical MHD, acoustic transfer, QND evidence boundaries | Reuse and extend existing records; no duplicate physics model. |
| Pending extension justified | NV/Purcell readout, widefield CASR diagnostics, measured LBGPC conductivity, display-stack optical calibration | Add finite observation records only after units, calibration, loss, and uncertainty fields are defined. |
| Process/catalog only | LIFT placement, N-LIG roughness, plasma ammonia, cold-plasma carbon recovery, Lignin-PEG thermal apparel, multi-chemistry batteries | Keep in process/RDF or Pending material records; these are not yet Signals physics. |
| Exclude from promotion | Vacuum-energy extraction, SQG plasma coupling, room-temperature quantum advantage, 10 nm LIFT, entropy siphoning, lossless OAM/QPU claims | Preserve as explicitly unsupported or conditional proposals. |

## Applications

### Soliton transport and quantum photonics

The A2Q chats propose a monolithic soliton bus carrying WDM, MDM, OAM,
squeezed states, homodyne probes, and nondestructive parity signals
[signal-phase chat](../data/chats/IQ-Sampling-for-Signal-Phase.md#L8547). The
same proposal describes nested N-LIG tubes, helical OAM waveguides, and a Kerr
probe path [bus architecture](../data/chats/IQ-Sampling-for-Signal-Phase.md#L8589).

**Status:** proposal. The defensible model is already in
`Signals.SolitonBus`: lane addresses, selectors, routing, quadrature maps,
finite operators, propagation lengths, XPM collision data, and OAM crosstalk
metadata. No new verified physics is justified by these chats alone.

### Homodyne and continuous-variable readout

The CV design replaces single-photon counting with balanced homodyne detection,
PIN receivers, and squeezed-state quadrature measurements
[homodyne proposal](../data/chats/Bell-Correlations-in-Atomic-Momentum.md#L2037).
The DGCZ variance criterion is a standard CV-QI concept, while the proposed
room-temperature N-LIG implementation is unvalidated.

**Status:** classical detector algebra is already covered by
`Signals.Homodyne`; quantum squeezing, QND, and backaction remain in Pending
contracts. The correct update is calibration data, not a new proof of quantum
readout.

### NV-center diagnostics and widefield measurements

The hardware-architecture chats propose an N-LIG/nanodiamond cavity with
Purcell-enhanced NV emission and a target lifetime reduction, followed by
widefield NMR/CASR diagnostics for drift and decoherence
[NV cavity proposal](../data/chats/_Quantum%20Computing%20Hardware%20Architectures%20Review%20%20.md#L1165)
and [widefield diagnostic proposal](../data/chats/_Quantum%20Computing%20Hardware%20Architectures%20Review%20%20.md#L1405).

**Status:** the Purcell equation and CASR aliasing are defensible finite-model
physics, but the N-LIG cavity, mode volume, thermal resolution, and “soliton
shadow” interpretation are not demonstrated.

**Smallest future Pending additions:**

- `NVCenterReadout`: wavelength, refractive index, cavity $Q$, mode volume,
  bulk/cavity lifetime, collection efficiency, and calibration residual;
- `WidefieldNMRDiagnostics`: camera frame rate, synchronisation frequency,
  alias order, $T_2^*$ estimate, thermal-map residual, and provenance.

### Displays and optical products

The display chats combine rGO-vitrimer shutters, nanodiamond SHG, Bragg
structural color, and cellulose nanospheres for amber, RGB, and white display
states [display architecture](../data/chats/_Induction%20Welding,%20Rail,%20Rolllercoasters%20.md#L918).
The chat also proposes high-speed rGO-vitrimer shutters for signage
[rGO-vitrimer display](../data/chats/_Induction%20Welding,%20Rail,%20Rolllercoasters%20.md#L887).

**Status:** SHG and Bragg reflection are existing physics already represented
by `Signals.ActiveOptics` and laser/Bragg contracts. The stacked RGB product,
video-rate switching, spectral crosstalk, lifetime, and display gamut require
measured optical and thermal observations before a new verified record is
appropriate.

## Processes

| Process | Chat evidence | Status and model disposition |
| --- | --- | --- |
| N-LIG/CNT nonlinear transmission line | N-LIG plus periodic CNT varactors are proposed to balance resistance and dispersion [NLTL proposal](../data/chats/Speckle,%20Metamaterials,%20and%20Fast%20Sensing%20.md#L3193) | Classical KdV/Sine-Gordon dynamics can be a future finite model; room-temperature loss and scattering remain unmeasured. |
| Laser-induced graphene and roughness control | N-LIG smoothness, laser choice, and sub-10 nm surface targets are proposed in the hardware review [N-LIG process](../data/chats/_Quantum%20Computing%20Hardware%20Architectures%20Review%20%20.md#L425) | Material/process annotation only until profilometry, loss, and laser-dose data exist. |
| LIFT nanodiamond placement | Yb-fibre fs pulses, donor/receiver gaps, aperture masks, and 10 nm placement are proposed [LIFT proposal](../data/chats/_Quantum%20Computing%20Hardware%20Architectures%20Review%20%20.md#L1280) | Do not promote the 10 nm claim. Model pulse dose and placement residuals only if measured. |
| Plasma ammonia/nitrogenated lignin | Non-thermal plasma ammonia is proposed as an upstream nitrogen source [ammonia plasma proposal](../data/chats/_Ammonia-plasma,-membranes,-fertilizer,-nitrogenated-lignin.md#L244) | Process/RDF candidate; requires full H2 source, conversion, energy, and nitrogen-balance accounting. |
| Cold-plasma waste gasification | Mixed plastics are proposed to yield hydrogen and carbon allotropes for VACNT/rGO products [plasma recovery process](../data/chats/_Induction%20Welding,%20Rail,%20Rolllercoasters%20.md#L949) | Process proposal; gas yield, carbon purity, energy use, and allotrope selectivity are missing. |
| Ultrasonic magnetic ball milling | A sealed 20--40 kHz wet mill with magnetic-bearing isolation is proposed [ultrasonic mill](../data/chats/_Magnetic-Bearings-in-Ultrasonic-Ball-Mills.md#L13) | Reuse `Signals.Acoustics` for transfer; add coupled bearing/isolation data only with measured damping and cavitation thresholds. |
| LBGPC/LBGP MHD pumping | Graphene/phytic-acid conductivity is proposed for a silent moving-part-free pump [LBGPC pump](../data/chats/_Algae%20Textiles,%20Bio-TPU,%20Insulation,%20Lignin-PEG-Graphene,%20.md#L395) | Reuse `Signals.MHD`; a Pending conductivity observation is justified, not a performance claim. |

## Products and Material Systems

| Product/system | Evidence boundary | Existing or recommended model |
| --- | --- | --- |
| N-LIG soliton/CV processor | Integrated room-temperature operation, lossless routing, and quantum advantage are proposals [A2Q design](../data/chats/IQ-Sampling-for-Signal-Phase.md#L8567) | Existing `SolitonBus`, `Homodyne`, `OAM`, and Pending QND; no composite verified product record yet. |
| NV nanodiamond cavity/readout module | NV products and positioning have scholarly records, but the N-LIG Purcell stack is proposed [NV proposal](../data/chats/_Quantum%20Computing%20Hardware%20Architectures%20Review%20%20.md#L1165) | Existing `Signals.Lasers` nanodiamond products; add a Pending Purcell observation only with $Q/V$ and lifetime calibration. |
| rGO-vitrimer amber/RGB display | Shutter, SHG, Bragg, and cellulose-scattering layers are proposed [display product](../data/chats/_Induction%20Welding,%20Rail,%20Rolllercoasters%20.md#L918) | Existing `ActiveOptics`/Bragg contracts cover equations; product validation belongs in a material/process record. |
| LBGPC thermal-fluid apparel and cooling | Lignin-PEG phase-change pads, LBGP fluidics, MHD pumps, and hydrophobic layers are proposed [thermal apparel](../data/chats/_Algae%20Textiles,%20Bio-TPU,%20Insulation,%20Lignin-PEG-Graphene,%20.md#L395) | Process/material catalog candidate; requires viscosity, conductivity, phase-change, toxicity, and pressure data. |
| Hydrogen and carbon recovery products | Plasma gasification proposes H2 fuel and VACNT/rGO feedstock [recovery outputs](../data/chats/_Induction%20Welding,%20Rail,%20Rolllercoasters%20.md#L949) | RDF/process inventory; do not encode purity or closed-loop yield as Lean theorems without measurements. |

## Exclusions

The following chat claims should not be promoted into verified Signals:

- CW Proca vacuum-gradient energy extraction for Argon;
- SQG as a plasma coupling medium;
- “entropy siphoning” as a heat-extraction mechanism;
- 10 nm LIFT placement and lossless OAM/QPU routing;
- room-temperature quantum advantage from an unmeasured N-LIG platform.

The safe representation is a Pending hypothesis with explicit input power,
loss, calibration, conservation, and experimental-status fields. Existing
`AGENTS.md` guidance requires those boundaries to remain visible.

## Recommended Update Order

1. Add Pending `NVCenterReadout` and `WidefieldNMRDiagnostics` records with
   dimensional calibration and residual fields.
2. Add a Pending `LBGPCConductivityObservation` to the existing MHD accounting
   rather than assuming graphene/phytic-acid conductivity.
3. Keep display, plasma, battery, packaging, and apparel work in process/RDF
   catalogs until transferable measurements exist.
4. Do not add new verified equations for the unsupported Proca/SQG/QPU claims.

### Scholarly References

<a id="travers2019"></a> Travers et al. (2019), [High-energy pulse self-compression and ultraviolet generation through soliton dynamics in hollow capillary fibres](https://doi.org/10.1038/s41566-019-0416-4).

<a id="wang2018"></a> Wang et al. (2018), [Directly using 88-km conventional multi-mode fiber for 6-mode orbital angular momentum multiplexing transmission](https://doi.org/10.1364/oe.26.010038).

<a id="bao2025"></a> Bao et al. (2025), [Quantum-Grade Nanodiamonds from a Single-Step, Industrial-Scale Pressure and Temperature Process](https://doi.org/10.1002/adfm.202520907).

<a id="kim2025"></a> Kim et al. (2025), [Scalable nanoscale positioning of highly coherent color centers in prefabricated diamond nanostructures](https://doi.org/10.1038/s41467-025-64758-4).