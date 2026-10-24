---
title: Longitudinal Fields, PolyCBD Waveguides, UPT, and DDF Shear-Jamming
description: >-
  Evidence review of chat-derived polyCBD waveguide, ultrasonic power transfer,
  brittle fracture, DDF shear-jamming, and longitudinal-field applications.
---

# Longitudinal Fields, PolyCBD Waveguides, UPT, and DDF Shear-Jamming

## Scope and summary

This report evaluates the proposed polyCBD waveguide, ultrasonic power transfer
(UPT), and the suggestion that DDF shear-jamming is a better description of
fracture or the main UPT mechanism. It also places those proposals in the
project's broader application set: communications, nanoimaging, nanolithography,
wireless power, plasma-to-electric conversion, and plasma propulsion.

The evidence supports several separate classical technologies: focused vector
beams can create a local longitudinal electric-field component; ENZ structures
can alter field distributions; hBN phonon-polaritons have been used for
near-field imaging; piezoelectric transducers can transfer acoustic power; MHD
generators convert energy from conducting flow; and Hall thrusters accelerate
propellant. These results do not collectively establish a Proca wave, a
polyCBD Proca waveguide, or DDF behavior in a material. Chat proposals remain
proposals unless backed by the relevant calibrated experiment.

The specific 2026 IEEE conference-paper record for hemp-based polycarbonate
substrates exists, but the publisher full text was not accessible in this
review. The chat's claimed 400 GHz and 800 GHz dielectric values therefore
remain unverified here. A low-loss 5G/mmWave substrate result, even if confirmed
in the paper, would not by itself establish a guided mode at 400 GHz, a
longitudinal Proca polarization, or the proposed anti-fire mechanism. This
report assesses polyCBD as a separate candidate material; it does not reuse the
prior lignin/PCLP device assumptions.

## Search record

Searches used the top-level Markdown corpus `data/chats/*.md`, case-insensitive.
The polyCBD query was the proximity regex
`polyCBD.{0,100}waveguide|waveguide.{0,100}polyCBD`: 3 matching lines in 2
files, principally the IQ-sampling chat and the Airy-beam communications chat.
The UPT query combined the whole-word acronym with expanded phrases: 78 matching
lines in 5 files, with repeated simulator/code lines concentrated in the
rail-tie chat. The shear-jamming regex returned 67 matching lines in 5 files;
most matches were in the Population III review, IQ-sampling, Grassmannian-splat,
N-body, and Navier-Stokes/DDF chats. These are line counts, not independent
experiments or independent claims.

The polyCBD waveguide proposal is explicit in the IQ-sampling chat: it proposes
polyCBD for a Proca metamaterial and cannon, claims low dielectric loss, and
suggests 400 GHz waveguides ([material request](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L15106),
[claimed loss rationale](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L15146),
[waveguide proposal](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L15155)). A
separate Airy-beam chat proposes converting lignin or polyCBD surfaces to N-LIG
waveguides ([proposal](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Airy-Beams-and-Communications-and-Illumination.md#L2775)).
The chat's plotted 28, 100, 400, and 800 GHz values are widget inputs, not
reported calibrated measurements ([widget values](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L15179)).

The rail-tie UPT chat explicitly calls an engineered acoustic-impedance boundary
a "fracture plane" and proposes piezoelectric transfer ([analogy](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Engineer-sustainable-alternatives-to-creosote-treated-wooden-ties.md#L1713),
[UPT architecture](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Engineer-sustainable-alternatives-to-creosote-treated-wooden-ties.md#L1754)).
It models a 1 MHz path ([model proposal](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Engineer-sustainable-alternatives-to-creosote-treated-wooden-ties.md#L1861))
and later claims 68% net transfer after a quarter-wave matching layer
([claimed efficiency](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Engineer-sustainable-alternatives-to-creosote-treated-wooden-ties.md#L2189));
these are design calculations, not experimental results. The DDF source describes
shear-jamming in its high-shear model ([DDF chat](https://github.com/westurner/sustainablefactory/blob/main/data/chats/Navier-Stokes-Breakthrough,-FTLE,-and-SQG.md#L416),
[high-strain claim](https://github.com/westurner/sustainablefactory/blob/main/data/chats/Navier-Stokes-Breakthrough,-FTLE,-and-SQG.md#L494)).
A separate composites chat uses brittle fracture as a materials-performance
category ([fracture-toughness comparison](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Sustainable%20Composites_%20Energy,%20Processing,%20Costs%20.md#L2336)).

## PolyCBD and the waveguide claim

Crossref/IEEE metadata confirms a June 2026 conference publication titled
"Sustainable Hemp-based Polycarbonate Substrates Enabling Low-Loss 5G and mmWave
Electronic Systems" ([Xu et al. 2026](#xu2026)). That supports the existence
of a relevant substrate study, not the additional details inserted into the
chat. The full paper was not retrievable from IEEE in this review, so its exact
polymer formulation, test fixtures, frequency span, uncertainty, and measured
loss values still need primary-source verification.

| Claim | Evidence status | What the result would establish | Missing check |
| --- | --- | --- | --- |
| Hemp-based polycarbonate is a candidate low-loss 5G/mmWave substrate | Scholarly conference-paper record located; full methods not reviewed | Potentially useful ordinary dielectric substrate data in the paper's measured bands | Read the paper; confirm polymer identity, frequency points, test method, moisture/temperature conditioning, uncertainty, and loss values |
| The same polyCBD has `tan delta = 0.0052` and `3.40 dB/cm` at 400 GHz, and specified 800 GHz values | Proposal / unsupported by the accessible paper metadata | Nothing until the primary data and units are verified | Calibrated sub-THz material characterization at 400 and 800 GHz, with thickness, surface finish, fixture de-embedding, repeatability, and uncertainty |
| A polyCBD block forms a guided Proca mode or a Proca metamaterial | Unsupported | A material can guide ordinary Maxwell modes; that is not a fundamental Proca mass or third polarization | Measure complex constitutive response, full-vector modal fields, dispersion, propagation loss, source coupling, and a massless Maxwell control |
| The material yields efficient 400-to-800 GHz acoustic/Proca conversion or hydroxyl quenching | Proposal | Only measured output spectrum, conversion efficiency, absorbed power, chemistry, and thermal response could test this | Demonstrate phase matching, calibrated acoustic/electromagnetic output, heat accounting, and controlled reaction-kinetics data |

"5G/mmWave" should not be read as evidence at 400 GHz: 400 GHz is in the
sub-terahertz region, and 800 GHz is higher still. A low dielectric loss is a
material property, not a waveguide by itself. The geometry, boundary conditions,
mode profile, phase and group dispersion, insertion loss, and material
variability must all be measured. The chat's generated attenuation table must
not be treated as paper data until checked against the article and reproduced.

The chat also blends material families. PolyCBD-carbonate is discussed as a
linear thermoplastic ([material comparison](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Hemp-Derived-Polycarbonate-A-Sustainable-Material.md#L242)),
while polyCBD-disulfide/lignin and CNC composites are proposed hybrids
([hybrid proposal](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L15143)). Those are distinct compositions and cannot inherit one another's
mechanical, dielectric, or nonlinear coefficients without measurements. PCLP
(photo-cleavable lignin polymer) is outside this report's polyCBD substrate
scope.

## Shear-jamming, brittle fracture, and UPT

These are different physical descriptions:

| Concept | State variable / observable | Appropriate model | Evidence boundary |
| --- | --- | --- | --- |
| Brittle fracture | Crack initiation/growth, stress intensity or energy-release rate, fracture toughness, and failure surface | Linear-elastic or nonlinear fracture mechanics, cohesive-zone/damage models, with material-specific tests | The chat's fracture-toughness table is a design claim, not test data; DDF shear-jamming does not substitute for crack measurements |
| Shear-jamming | Stress-induced rigidity and force-network formation in dense frictional granular matter under shear | Granular rheology/constitutive model with packing fraction, friction, confining pressure, shear rate, and hysteresis | Shear-jamming has experimental granular-material precedents, but those do not validate Fedi's proposed vacuum/DDF substrate or a brittle-polymer fracture law ([Bi et al. 2011](#bi2011)) |
| UPT | Acoustic pressure/particle-velocity wave, layer/interface reflection and attenuation, piezoelectric source and receiver conversion, load power | Linear or nonlinear elastodynamics/acoustics plus piezoelectric constitutive and circuit models | Piezoelectric UPT has laboratory demonstrations; the railroad-tie geometry and its claimed 68% link efficiency remain proposals ([Shahab et al. 2015](#shahab2015), [Tseng et al. 2020](#tseng2020)) |
| Cavitation or mechanochemistry | Bubble dynamics, local pressure/temperature, reaction yield, polymer chain scission | Nonlinear acoustics, cavitation dynamics, and reaction/thermal models | Not implied by jamming, a Proca label, or an impedance boundary; requires direct imaging, calorimetry, and chemical controls |

**Answer to the fracture question:** DDF shear-jamming may be a candidate
constitutive description for a dense granular or suspension-like material if
its stress/rheology measurements support that regime. It is not a better
general description of brittle fracture. A solid can shear-fracture, and a
granular material can jam, but crack growth and jamming are not synonyms. In
the DDF chat, jamming is a theoretical high-shear/relativistic-vacuum claim,
not an experimental result for polyCBD, lignin, concrete, or an acoustic
waveguide ([DDF source](https://github.com/westurner/sustainablefactory/blob/main/data/chats/Navier-Stokes-Breakthrough,-FTLE,-and-SQG.md#L416)).

**Answer to the UPT question:** No, shear-jamming is not the best default UPT
model. UPT is already modeled as ordinary passive acoustic transfer in
`Signals.Acoustics.UltrasonicTransfer`; the relevant next step is a layered
acoustic/piezoelectric model with measured impedance, thickness, attenuation,
transducer efficiencies, receiver load, heat, and interfaces. Jamming could be
added as an optional stress-dependent material state only if it is measured to
change the layer's acoustic velocity, modulus, or attenuation. A jammed boundary
may increase stiffness or reflection; it does not automatically improve power
transfer.

The rail-tie chat uses "fracture" as an analogy for a deliberately engineered
impedance discontinuity and calls the carbon skin an acoustic waveguide
([UPT impedance-plane proposal](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Engineer-sustainable-alternatives-to-creosote-treated-wooden-ties.md#L1713)).
For normal-incidence plane waves, an impedance step gives a finite reflection
coefficient, not automatically total internal reflection. A quarter-wave
matching layer can improve transmission near its design frequency, but its
thickness, frequency bandwidth, bond layers, stress state, temperature, and
loss must be measured. The chat's 1 MHz and 68% figures are not measured rail-tie
performance ([UPT calculation](https://github.com/westurner/sustainablefactory/blob/main/data/chats/_Engineer-sustainable-alternatives-to-creosote-treated-wooden-ties.md#L2189)).

## Application disposition

| Objective | Demonstrated route to develop | Current status of the chat-specific claim |
| --- | --- | --- |
| Communications | Conventional optical/RF waveguides or antennas with ordinary Maxwell link budgets; use guided modes when a physical path is available | The 1 W deep-space Proca/fracture link is a proposal without a demonstrated carrier, receiver, or link budget ([chat claim](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L2032)) |
| Nanoimaging | Near-field optical microscopy and polaritonic near-field imaging | Sub-diffraction hBN phonon-polariton imaging is demonstrated; it is not a Proca wave or an Angstrom-scale full-wafer measurement ([Li et al. 2015](#hbn2015)) |
| Nanolithography | High-NA vector-beam focusing, measured dose and point-spread function, then material-specific resist processing | A 2024 radial-beam study reports a 67 nm ablation hole in glass; it does not validate polyCBD, PCLP, or the chat's large-area Proca mask ([Tsuru et al. 2024](#tsuru2024)) |
| Wireless power | Piezoelectric acoustic UPT through a solid path, or conventional inductive/resonant electromagnetic transfer | Acoustic piezoelectric source-to-receiver transfer is experimentally validated in a specific apparatus; it does not validate the tie stack or fracture-state safety ([Shahab et al. 2015](#shahab2015)) |
| Electricity from plasma | MHD conversion from conducting plasma flow, with full thermal, magnetic, pump, and input-power accounting | MHD is a conventional conversion architecture; the chat's Proca-powered/gigawatt claim is unsupported ([MHD analysis](#mhd2005), [chat proposal](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L14116)) |
| Thrust from plasma | Hall/electric propulsion or another measured plasma-exhaust device, closing mass-flow and power balances | Hall-thruster tests report measured thrust and specific impulse with nitrogen propellant; the proposed topological thruster's extreme performance remains unverified ([Marchioni & Cappelli 2021](#hall2021), [chat claim](https://github.com/westurner/sustainablefactory/blob/main/data/chats/IQ-Sampling-for-Signal-Phase.md#L1394)) |

## Recommended evidence sequence

1. **PolyCBD:** obtain the IEEE full text; confirm the exact resin and processing route; replicate its dielectric measurements; then extend characterization only as needed into 400-800 GHz. Keep the polyCBD thermoplastic and any polyCBD-lignin/disulfide hybrid as separate material records.
2. **Waveguide:** use an ordinary Maxwell eigenmode/S-parameter model first. Measure full vector fields, mode dispersion, insertion loss, group delay, temperature and humidity dependence, and mode conversion. Add a Proca hypothesis only if a transferable massive-mode dispersion and polarization signature survive calibrated Maxwell/ENZ/plasma controls.
3. **UPT:** construct a layered acoustic path with source, each layer's density/sound speed/attenuation, measured interfaces, receiver transduction, load, and complete input/output/loss accounting. Verify claimed transfer efficiency with a calibrated wattmeter and independent receiver, then replicate.
4. **Shear-jamming:** test a candidate granular or composite material in a rheometer while measuring shear stress, storage/loss modulus, acoustic velocity, attenuation, and hysteresis across the proposed jam transition. Do not infer fracture toughness or power-transfer efficiency from a jamming observation.
5. **Brittle fracture:** separately measure tensile/compressive strength, fracture toughness or critical energy-release rate, crack path, fatigue, and post-damage acoustic loss. Do not intentionally introduce a physical crack to serve as an acoustic matching plane.

## Scholarly References

(xu2026)=
<a id="xu2026"></a> Xu et al. (2026), "Sustainable Hemp-based Polycarbonate Substrates Enabling Low-Loss 5G and mmWave Electronic Systems," IEEE MTT-S Radio Frequency Systems and Applications Symposium. [DOI](https://doi.org/10.1109/imsrfsa70221.2026.11624319). Crossref confirms the conference-paper record and title; the full text was not accessible in this review, so its numerical material claims remain unverified here.

(shahab2015)=
<a id="shahab2015"></a> Shahab, Gray, and Erturk (2015), "Ultrasonic power transfer from a spherical acoustic wave source to a free-free piezoelectric receiver: Modeling and experiment," *Journal of Applied Physics* 117, 104903. [DOI](https://doi.org/10.1063/1.4914130).

(tseng2020)=
<a id="tseng2020"></a> Tseng et al. (2020), "Ultrasonic Lamb Waves for Wireless Power Transfer," *IEEE Transactions on Ultrasonics, Ferroelectrics, and Frequency Control* 67, 664-670. [DOI](https://doi.org/10.1109/TUFFC.2019.2949467).

(bi2011)=
<a id="bi2011"></a> Bi, Zhang, Chakraborty, and Behringer (2011), "Jamming by shear," *Nature* 480, 355-358. [DOI](https://doi.org/10.1038/nature10667).

(griffith1921)=
<a id="griffith1921"></a> Griffith (1921), "The phenomena of rupture and flow in solids," *Philosophical Transactions of the Royal Society A* 221. [DOI](https://doi.org/10.1098/rsta.1921.0006).

(hbn2015)=
<a id="hbn2015"></a> Li et al. (2015), "Hyperbolic phonon-polaritons in boron nitride for near-field optical imaging and focusing," *Nature Communications* 6, 7507. [DOI](https://doi.org/10.1038/ncomms8507).

(tsuru2024)=
<a id="tsuru2024"></a> Tsuru et al. (2024), "Laser nanoprocessing via an enhanced longitudinal electric field of a radially polarized beam," *Optics Letters* 49. [DOI](https://doi.org/10.1364/OL.517382).

(mhd2005)=
<a id="mhd2005"></a> Li, Keefer, Rhodes, Merkle, Kolokolnikov, and Thibodeaux (2005), "Analysis of Magnetohydrodynamic Generator Power Generation," *Journal of Propulsion and Power* 21, 424-432. [DOI](https://doi.org/10.2514/1.4415).

(hall2021)=
<a id="hall2021"></a> Marchioni and Cappelli (2021), "Extended channel Hall thruster for air-breathing electric propulsion," *Journal of Applied Physics* 130, 053306. [DOI](https://doi.org/10.1063/5.0048283).
