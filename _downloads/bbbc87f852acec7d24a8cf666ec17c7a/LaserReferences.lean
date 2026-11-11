import Signals.LaserProcesses

namespace Signals.Pending

/-! # Laser, graphene, nanodiamond, and holography references

This registry normalizes the canonical works listed in
`data/papers/proofs_of_cw_and_lignin_and_holography.bib`. It is provenance and
evidence-boundary data, not a claim that every listed work supplies a process
recipe or an absolute laser wattage.
-/

/-- Local treatment of a scholarly or bibliographic source. -/
inductive LaserReferenceEvidenceStatus
  | experimental
  | review
  | theoretical
  | metadataOnly
  deriving DecidableEq, Repr

/-- The kind of power information available in a source. -/
inductive LaserReferencePowerEvidence
  | absoluteWatts
  | pulseEnergyOrFluence
  | processParametersOnly
  | noTransferableWattage
  deriving DecidableEq, Repr

/-- Claim boundary for Proca fields and CW holographic carbon synthesis. -/
inductive LaserReferenceClaimStatus
  | demonstrated
  | conditionalModel
  | notDemonstrated
  | metadataOnly
  deriving DecidableEq, Repr

/-- Whether a verified local paper artifact is available for a reference. -/
inductive LaserReferenceArtifactStatus
  | localPdf
  | accessBlocked
  | metadataOnly
  deriving DecidableEq, Repr

/-- A topical role used to connect a reference to an existing finite model. -/
inductive LaserReferenceRole
  | grapheneReduction
  | ligninOrBiomass
  | polymerCarbon
  | nanodiamond
  | quantumGradeNanodiamond
  | colorCenter
  | nanodiamondPositioning
  | electronBeamPumping
  | highPressureNanodiamond
  | surfacePlasmonPolariton
  | coherentSynchrotronRadiation
  | freeElectronPumping
  | cavityElectrodynamics
  | cavityQED
  | phononPolariton
  | lightSlinger
  | volumeDistributedPolarization
  | superluminalPhasePattern
  | causalSpeedSeparation
  | attosecondSoliton
  | dispersiveWave
  | argonIonization
  | plasmaLens
  | solitonBus
  | solitonSelfCompression
  | solitonPropagationDynamics
  | solitonCollision
  | crossPhaseModulation
  | oamModeMultiplexing
  | modeCrosstalk
  | longHaulTransmission
  | fieldResolvedSampling
  | frequencyComb
  | nanophotonicParametricOscillator
  | opticalSuperconductingQubitControl
  | microwaveOpticalTransduction
  | superconductingQubit
  | chiralQuantumInterconnect
  | remoteEntanglement
  | dualBeamFemtosecondProcessing
  | selfFocusingSuppression
  | filamentationSuppression
  | waveguideWriting
  | opticalModification
  | holography
  | masklessFabrication
  | additiveManufacturing
  | wearableElectronics
  | procaTheory
  deriving DecidableEq, Repr

/-- Normalized provenance and evidence metadata for one unique work. -/
structure LaserScholarlyReference where
  bibKey : String
  title : String
  year : Nat
  doi : Option String
  sourceUrl : String
  localArtifactStatus : LaserReferenceArtifactStatus
  localArtifact : Option String
  evidenceStatus : LaserReferenceEvidenceStatus
  powerEvidence : LaserReferencePowerEvidence
  roles : List LaserReferenceRole
  procaFieldStatus : LaserReferenceClaimStatus
  cwHolographicCarbonSynthesisStatus : LaserReferenceClaimStatus
  scopeNote : String

/-- Laser-reduced graphene review by Wan et al. -/
def laserReferenceWan2018 : LaserScholarlyReference where
  bibKey := "wan2018laser"
  title := "Laser-Reduced Graphene: Synthesis, Properties, and Applications"
  year := 2018
  doi := some "10.1002/admt.201700315"
  sourceUrl := "https://doi.org/10.1002/admt.201700315"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.noTransferableWattage
  roles := [LaserReferenceRole.grapheneReduction,
    LaserReferenceRole.opticalModification,
    LaserReferenceRole.holography]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews laser reduction of graphene oxide and related applications; it does not provide a universal CW wattage or demonstrate Proca fields."

/-- Laser-induced graphene review by Ye et al. -/
def laserReferenceYe2024 : LaserScholarlyReference where
  bibKey := "ye2024review"
  title := "A review on the laser-induced synthesis of graphene and its applications in sensors"
  year := 2024
  doi := some "10.1007/s10853-024-09883-z"
  sourceUrl := "https://doi.org/10.1007/s10853-024-09883-z"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.grapheneReduction,
    LaserReferenceRole.opticalModification,
    LaserReferenceRole.wearableElectronics]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews laser-induced graphene synthesis and sensor applications; process parameters remain precursor- and apparatus-specific."

/- Maskless photolithography review by Cheng et al. -/
def laserReferenceCheng2026 : LaserScholarlyReference where
  bibKey := "cheng2026maskless"
  title := "Maskless photolithography for micro-and nanofabrication"
  year := 2026
  doi := some "10.1007/s44275-026-00046-7"
  sourceUrl := "https://doi.org/10.1007/s44275-026-00046-7"
  localArtifactStatus := LaserReferenceArtifactStatus.localPdf
  localArtifact := some "data/papers/cheng2026maskless.pdf"
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.masklessFabrication]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "The downloaded local review verifies the DOI and article identity; its maskless photolithography scope does not establish Proca fields or CW holographic carbon synthesis."

/-- Selective laser material-processing review by Park et al. -/
def laserReferencePark2024 : LaserScholarlyReference where
  bibKey := "park2024laser"
  title := "Laser-Based Selective Material Processing for Next-Generation Additive Manufacturing"
  year := 2024
  doi := some "10.1002/adma.202307586"
  sourceUrl := "https://doi.org/10.1002/adma.202307586"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.additiveManufacturing,
    LaserReferenceRole.opticalModification]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews laser-material interaction and selective processing in additive manufacturing; intersecting beams do not by themselves establish volumetric carbon synthesis."

/-- Graphene-based flexible-electronics review by You et al. -/
def laserReferenceYou2020 : LaserScholarlyReference where
  bibKey := "you2020laser"
  title := "Laser Fabrication of Graphene-Based Flexible Electronics"
  year := 2020
  doi := some "10.1002/adma.201901981"
  sourceUrl := "https://doi.org/10.1002/adma.201901981"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.grapheneReduction,
    LaserReferenceRole.polymerCarbon,
    LaserReferenceRole.wearableElectronics]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews laser preparation, patterning, and modification of graphene-based electronics; it does not supply a general CW power threshold."

/-- Sustainable carbon-source perspective by C. Claro et al. -/
def laserReferenceClaro2022 : LaserScholarlyReference where
  bibKey := "c2022sustainable"
  title := "Sustainable carbon sources for green laser-induced graphene: A perspective on fundamental principles, applications, and challenges"
  year := 2022
  doi := some "10.1063/5.0100785"
  sourceUrl := "https://doi.org/10.1063/5.0100785"
  localArtifactStatus := LaserReferenceArtifactStatus.localPdf
  localArtifact := some "data/papers/c2022sustainable.pdf"
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.grapheneReduction,
    LaserReferenceRole.ligninOrBiomass,
    LaserReferenceRole.polymerCarbon]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews renewable and bio-based precursors, conversion mechanisms, and implementation challenges; it does not establish a lignin-vitrimer wattage."

/-- LIG diffractive-optics article by Lee et al.; DOI corrected from the
attached BibTeX record using the Crossref/OpenAlex record. -/
def laserReferenceLee2023 : LaserScholarlyReference where
  bibKey := "lee2023ultra"
  title := "Ultra-thin light-weight laser-induced-graphene (LIG) diffractive optics"
  year := 2023
  doi := some "10.1038/s41377-023-01143-0"
  sourceUrl := "https://doi.org/10.1038/s41377-023-01143-0"
  localArtifactStatus := LaserReferenceArtifactStatus.localPdf
  localArtifact := some "data/papers/lee2023ultra.pdf"
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.grapheneReduction,
    LaserReferenceRole.opticalModification,
    LaserReferenceRole.holography]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Demonstrates laser-written LIG diffractive optics; optical phase and amplitude patterning is not Proca-field evidence or CW volumetric synthesis."

/-- LIG wearable-healthcare review by Kim and Kim. -/
def laserReferenceKim2025 : LaserScholarlyReference where
  bibKey := "kim2025wearable"
  title := "Wearable healthcare using laser-induced graphene"
  year := 2025
  doi := some "10.1007/s42791-025-00113-4"
  sourceUrl := "https://doi.org/10.1007/s42791-025-00113-4"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.grapheneReduction,
    LaserReferenceRole.wearableElectronics]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews LIG fabrication and wearable sensors; it reports no universal CW power requirement for a new precursor."

/-- Biomass-to-nanodiamond experiment by Lin et al. -/
def laserReferenceLin2021 : LaserScholarlyReference where
  bibKey := "lin2021fabricating"
  title := "Fabricating Nanodiamonds from Biomass by Direct Laser Writing under Ambient Conditions"
  year := 2021
  doi := some "10.1021/acssuschemeng.0c07607"
  sourceUrl := "https://doi.org/10.1021/acssuschemeng.0c07607"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.ligninOrBiomass,
    LaserReferenceRole.nanodiamond]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reports direct laser writing of nanodiamonds from a nanolignin/cellulose nanofibril biomass film in ambient air; it is not evidence for diamond formation from lignin-vitrimer by CW holography."

/-- Nanodiamond conversion review by Joshi et al. -/
def laserReferenceJoshi2021 : LaserScholarlyReference where
  bibKey := "joshi2021advances"
  title := "Advances in laser-assisted conversion of polymeric and graphitic carbon into nanodiamond films"
  year := 2021
  doi := some "10.1088/1361-6528/ac1097"
  sourceUrl := "https://doi.org/10.1088/1361-6528/ac1097"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.pulseEnergyOrFluence
  roles := [LaserReferenceRole.nanodiamond,
    LaserReferenceRole.polymerCarbon]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews UV and nanosecond laser-assisted conversion of polymeric or graphitic carbon into nanodiamond films; it does not establish a CW holographic process."

/-- Planar Proca metamaterials preprint by Morais et al. -/
def laserReferenceMorais2026 : LaserScholarlyReference where
  bibKey := "morais2026investigating"
  title := "Investigating planar Proca metamaterials in nonlinear (2+1)-Electrodynamics"
  year := 2026
  doi := none
  sourceUrl := "https://arxiv.org/abs/2607.23013"
  localArtifactStatus := LaserReferenceArtifactStatus.localPdf
  localArtifact := some "data/papers/2607.23013v1.pdf"
  evidenceStatus := LaserReferenceEvidenceStatus.theoretical
  powerEvidence := LaserReferencePowerEvidence.noTransferableWattage
  roles := [LaserReferenceRole.procaTheory]
  procaFieldStatus := LaserReferenceClaimStatus.conditionalModel
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "An arXiv constitutive/theoretical model; it does not demonstrate a laboratory Proca field or supply a material-processing wattage."

/-- Optical modification review by Akkanen et al. -/
def laserReferenceAkkanen2022 : LaserScholarlyReference where
  bibKey := "akkanen2022optical"
  title := "Optical Modification of 2D Materials: Methods and Applications"
  year := 2022
  doi := some "10.1002/adma.202110152"
  sourceUrl := "https://doi.org/10.1002/adma.202110152"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.grapheneReduction,
    LaserReferenceRole.opticalModification]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews local optical engineering and patterning of existing 2D materials in ambient conditions; it does not establish carbon synthesis in a polymer."

/-- Proca metamaterials theory by Mikki. -/
def laserReferenceMikki2021 : LaserScholarlyReference where
  bibKey := "mikki2021proca"
  title := "Proca Metamaterials, Massive Electromagnetism, and Spatial Dispersion"
  year := 2021
  doi := some "10.1002/andp.202000625"
  sourceUrl := "https://doi.org/10.1002/andp.202000625"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.theoretical
  powerEvidence := LaserReferencePowerEvidence.noTransferableWattage
  roles := [LaserReferenceRole.procaTheory,
    LaserReferenceRole.opticalModification]
  procaFieldStatus := LaserReferenceClaimStatus.conditionalModel
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Theoretical Maxwell-Proca equivalence under spatial-dispersion assumptions; it does not provide a CW graphene or diamond synthesis threshold."

/-- CSR from laser-excited SPP modes on a near-critical microtube surface. -/
def laserReferenceLei2025Csr : LaserScholarlyReference where
  bibKey := "lei2025csrSpp"
  title := "Coherent Synchrotron Radiation by Excitation of Surface Plasmon Polariton on Near-Critical Solid Microtube Surface"
  year := 2025
  doi := some "10.1103/cnym-16hc"
  sourceUrl := "https://arxiv.org/abs/2507.04561"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.theoretical
  powerEvidence := LaserReferencePowerEvidence.noTransferableWattage
  roles := [LaserReferenceRole.surfacePlasmonPolariton,
    LaserReferenceRole.coherentSynchrotronRadiation]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Three-dimensional particle-in-cell study of laser-excited cylindrical SPP modes, surface-electron acceleration, and coherent X-ray CSR; it is not a cavity-QED or Proca experiment."

/-- Free-electron-pumped plasmon amplification experiment behind the Nature news item. -/
def laserReferenceZhang2022FreeElectron : LaserScholarlyReference where
  bibKey := "zhang2022freeElectronSpp"
  title := "Coherent surface plasmon polariton amplification via free-electron pumping"
  year := 2022
  doi := some "10.1038/s41586-022-05239-2"
  sourceUrl := "https://doi.org/10.1038/s41586-022-05239-2"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.surfacePlasmonPolariton,
    LaserReferenceRole.freeElectronPumping]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "The Nature news report describes laser-driven electrons on an iron wire amplifying electromagnetic waves; it is not evidence of a graphene-circuit THz/eV input or a universal emission spectrum."

/-- Measured graphite-cavity/graphene-plasmon avoided crossing. -/
def laserReferenceKipp2024Cavity : LaserScholarlyReference where
  bibKey := "kipp2024VdwCavity"
  title := "Cavity electrodynamics of van der Waals heterostructures"
  year := 2024
  doi := some "10.1038/s41567-025-03064-8"
  sourceUrl := "https://arxiv.org/abs/2403.19745"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.cavityElectrodynamics,
    LaserReferenceRole.surfacePlasmonPolariton]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "On-chip THz spectroscopy observes spectral-weight transfer and avoided crossing between graphite cavity and graphene plasmon modes; this is cavity electrodynamics with ultrastrong coupling, not automatically single-photon cavity QED."

/-- Review of low-symmetry phonon-polaritonic crystals. -/
def laserReferenceGaliffi2023PhononPolariton : LaserScholarlyReference where
  bibKey := "galiffi2023phononPolariton"
  title := "Extreme light confinement and control in low-symmetry phonon-polaritonic crystals"
  year := 2023
  doi := none
  sourceUrl := "https://arxiv.org/abs/2312.06805"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.phononPolariton,
    LaserReferenceRole.opticalModification]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews hybrid photon-phonon modes, anisotropic confinement, and low-symmetry polar crystals; phonon-polariton propagation is distinct from SPP and cavity-QED labels."

/-- Electron-beam activation of adamantane into cubic nanodiamond. -/
def laserReferenceFu2025ElectronNanodiamond : LaserScholarlyReference where
  bibKey := "fu2025electronNanodiamond"
  title := "Rapid, low-temperature nanodiamond formation by electron-beam activation of adamantane C-H bonds"
  year := 2025
  doi := some "10.1126/science.adw2025"
  sourceUrl := "https://doi.org/10.1126/science.adw2025"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.nanodiamond,
    LaserReferenceRole.electronBeamPumping]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reports cubic nanodiamonds from adamantane submicrocrystals under 80-200 keV electron irradiation at 100-296 K in vacuum; the route is precursor-specific and not a laser or lignin-vitrimer process."

/-- Single-step industrial-scale quantum-grade NV nanodiamond process. -/
def laserReferenceBao2025QuantumNanodiamond : LaserScholarlyReference where
  bibKey := "bao2025quantumNanodiamond"
  title := "Quantum-Grade Nanodiamonds from a Single-Step, Industrial-Scale Pressure and Temperature Process"
  year := 2025
  doi := some "10.1002/adfm.202520907"
  sourceUrl := "https://doi.org/10.1002/adfm.202520907"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.nanodiamond,
    LaserReferenceRole.quantumGradeNanodiamond,
    LaserReferenceRole.colorCenter,
    LaserReferenceRole.highPressureNanodiamond]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reports 50 nm luminescent nanodiamonds with improved NV charge stability, near-1 ms T1 relaxation, and enhanced optical Rabi contrast from a single high-pressure/high-temperature process; it does not establish laser or lignin-vitrimer synthesis."

/-- Nanoscale positioning of coherent NV centers in prefabricated diamond pillars. -/
def laserReferenceKim2025ColorCenterPositioning : LaserScholarlyReference where
  bibKey := "kim2025colorCenterPositioning"
  title := "Scalable nanoscale positioning of highly coherent color centers in prefabricated diamond nanostructures"
  year := 2025
  doi := some "10.1038/s41467-025-64758-4"
  sourceUrl := "https://doi.org/10.1038/s41467-025-64758-4"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.nanodiamond,
    LaserReferenceRole.colorCenter,
    LaserReferenceRole.nanodiamondPositioning]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Combines delta-doping during CVD diamond growth with localized electron irradiation; reports approximately 4 nm depth and 46 nm lateral positioning in 280 nm pillars, with improved single-NV yield and coherence."

/-- Chat-derived LightSlinger volume-current waveguide model. -/
def laserReferenceLightSlingerChat : LaserScholarlyReference where
  bibKey := "lightslingerVolumeCurrentChat"
  title := "LightSlinger volume-distributed polarization-current waveguide model"
  year := 2026
  doi := none
  sourceUrl :=
    "data/chats/_Airy-Beams-and-Communications-and-Illumination.md"
  localArtifactStatus := LaserReferenceArtifactStatus.metadataOnly
  localArtifact := some
    "data/chats/_Airy-Beams-and-Communications-and-Illumination.md"
  evidenceStatus := LaserReferenceEvidenceStatus.metadataOnly
  powerEvidence := LaserReferencePowerEvidence.noTransferableWattage
  roles := [LaserReferenceRole.lightSlinger,
    LaserReferenceRole.volumeDistributedPolarization,
    LaserReferenceRole.superluminalPhasePattern,
    LaserReferenceRole.causalSpeedSeparation]
  procaFieldStatus := LaserReferenceClaimStatus.conditionalModel
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Chat-derived conditional model: a volume-distributed polarization-current antenna in a dielectric waveguide with a superluminal phase-pattern hypothesis. It does not establish superluminal matter, energy, or information transfer."

/-- Field-resolved attosecond soliton generation and argon ionization. -/
def laserReferenceHeinzerling2025AttosecondSoliton : LaserScholarlyReference where
  bibKey := "heinzerling2025attosecondSoliton"
  title := "Field-resolved attosecond solitons"
  year := 2025
  doi := some "10.1038/s41566-025-01658-5"
  sourceUrl := "https://doi.org/10.1038/s41566-025-01658-5"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.attosecondSoliton,
    LaserReferenceRole.dispersiveWave,
    LaserReferenceRole.argonIonization,
    LaserReferenceRole.fieldResolvedSampling,
    LaserReferenceRole.solitonBus]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reports hollow-core-fibre soliton dynamics, resonant DUV dispersive-wave generation, nonlinear photoconductive field sampling, and argon ionization; the QPU-bus application remains a separate engineering extrapolation."

/-- Hydrogen-plasma focusing and temporal control of attosecond pulses. -/
def laserReferenceSvirplys2025PlasmaLens : LaserScholarlyReference where
  bibKey := "svirplys2025plasmaLens"
  title := "Plasma lens for focusing attosecond pulses"
  year := 2025
  doi := some "10.1038/s41566-025-01794-y"
  sourceUrl := "https://doi.org/10.1038/s41566-025-01794-y"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.plasmaLens,
    LaserReferenceRole.attosecondSoliton,
    LaserReferenceRole.dispersiveWave]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reports a tunable hydrogen-plasma lens for broadband EUV attosecond focusing, including approximately 20 eV and 80 eV regimes, with negligible simulated pulse stretching, possible atto-chirp compression, and high-transmission harmonic separation."

/-- Chat-derived QPU soliton-bus design reference. -/
def laserReferenceSolitonQpuBusChat : LaserScholarlyReference where
  bibKey := "solitonQpuBusChat"
  title := "N-LIG soliton bus and QPU waveguide design notes"
  year := 2026
  doi := none
  sourceUrl := "data/chats/_Quantum Processor and Soliton Discussions  .md"
  localArtifactStatus := LaserReferenceArtifactStatus.metadataOnly
  localArtifact := some "data/chats/_Quantum Processor and Soliton Discussions  .md"
  evidenceStatus := LaserReferenceEvidenceStatus.metadataOnly
  powerEvidence := LaserReferencePowerEvidence.noTransferableWattage
  roles := [LaserReferenceRole.solitonBus,
    LaserReferenceRole.attosecondSoliton]
  procaFieldStatus := LaserReferenceClaimStatus.conditionalModel
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Chat-derived QPU-bus and N-LIG waveguide proposal; it is not evidence that the cited attosecond fibre or plasma-lens experiments realize a quantum processor bus."

/-- Experimental hollow-capillary soliton self-compression and UV generation. -/
def laserReferenceTravers2019SolitonCompression : LaserScholarlyReference where
  bibKey := "travers2019solitonCompression"
  title := "High-energy pulse self-compression and ultraviolet generation through soliton dynamics in hollow capillary fibres"
  year := 2019
  doi := some "10.1038/s41566-019-0416-4"
  sourceUrl := "https://doi.org/10.1038/s41566-019-0416-4"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.pulseEnergyOrFluence
  roles := [LaserReferenceRole.solitonSelfCompression,
    LaserReferenceRole.solitonPropagationDynamics,
    LaserReferenceRole.dispersiveWave]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Experimental hollow-capillary work on high-energy soliton self-compression and ultraviolet dispersive-wave generation; it supports propagation and compression dynamics, not N-LIG room-temperature bus operation."

/-- Review of optical soliton dynamics in gas-filled hollow-core fibres. -/
def laserReferenceTravers2024HollowCoreReview : LaserScholarlyReference where
  bibKey := "travers2024hollowCoreReview"
  title := "Optical solitons in hollow-core fibres"
  year := 2024
  doi := some "10.1016/j.optcom.2023.130191"
  sourceUrl := "https://doi.org/10.1016/j.optcom.2023.130191"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.review
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.solitonPropagationDynamics,
    LaserReferenceRole.solitonSelfCompression,
    LaserReferenceRole.dispersiveWave]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reviews gas-filled capillary, photonic-crystal, bandgap, and antiresonant hollow-core soliton dynamics, including self-compression, Raman shift, photoionization, plasma, and dispersive-wave effects."

/-- Cross-phase modulation and soliton switching in nonlinear fibre couplers. -/
def laserReferenceKivshar1993SolitonSwitching : LaserScholarlyReference where
  bibKey := "kivshar1993solitonSwitching"
  title := "Influence of cross-phase modulation on soliton switching in nonlinear optical fibers"
  year := 1993
  doi := some "10.1364/ol.18.000980"
  sourceUrl := "https://doi.org/10.1364/ol.18.000980"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.theoretical
  powerEvidence := LaserReferencePowerEvidence.noTransferableWattage
  roles := [LaserReferenceRole.solitonCollision,
    LaserReferenceRole.crossPhaseModulation,
    LaserReferenceRole.solitonBus]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Analyzes cross-phase modulation versus self-phase modulation in nonlinear-fibre soliton switching and confirms the conclusions numerically; it is a conditional coupled-mode model, not single-photon Kerr evidence."

/-- Long-haul six-mode OAM transmission in conventional multimode fibre. -/
def laserReferenceWang2018OAMLongHaul : LaserScholarlyReference where
  bibKey := "wang2018oamLongHaul"
  title := "Directly using 88-km conventional multi-mode fiber for 6-mode orbital angular momentum multiplexing transmission"
  year := 2018
  doi := some "10.1364/oe.26.010038"
  sourceUrl := "https://doi.org/10.1364/oe.26.010038"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.oamModeMultiplexing,
    LaserReferenceRole.modeCrosstalk,
    LaserReferenceRole.longHaulTransmission,
    LaserReferenceRole.solitonBus]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "The published title says 88-km, while the abstract reports 8.8 km of OM4 multimode fibre. This registry follows the abstract's 8.8 km figure: 120-Gbit/s QPSK, six OAM mode groups, and 2x2 or 4x4 MIMO equalization. It is evidence for modal transport and crosstalk management, not soliton or N-LIG operation."

/-- Ultra-low-threshold multi-octave nanophotonic parametric oscillator. -/
def laserReferenceSekine2025MultiOctaveComb : LaserScholarlyReference where
  bibKey := "sekine2025multiOctaveComb"
  title := "Multi-octave frequency comb from an ultra-low-threshold nanophotonic parametric oscillator"
  year := 2025
  doi := some "10.1038/s41566-025-01753-7"
  sourceUrl := "https://doi.org/10.1038/s41566-025-01753-7"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.pulseEnergyOrFluence
  roles := [LaserReferenceRole.frequencyComb,
    LaserReferenceRole.nanophotonicParametricOscillator,
    LaserReferenceRole.opticalModification]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Reports a coherent 2.6-octave comb from a thin-film lithium-niobate optical parametric oscillator using 121 fJ pump energy and dispersion engineering; it is not evidence that rGO-vitrimer or N-LIG supplies the same chi(2) platform."

/-- Coherent optical control of a superconducting microwave qubit. -/
def laserReferenceWarner2025OpticalQubitControl : LaserScholarlyReference where
  bibKey := "warner2025opticalQubitControl"
  title := "Coherent control of a superconducting qubit using light"
  year := 2025
  doi := some "10.1038/s41567-025-02812-0"
  sourceUrl := "https://doi.org/10.1038/s41567-025-02812-0"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.absoluteWatts
  roles := [LaserReferenceRole.opticalSuperconductingQubitControl,
    LaserReferenceRole.microwaveOpticalTransduction,
    LaserReferenceRole.superconductingQubit]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Demonstrates optically driven Rabi oscillations using a cryogenic microwave-optical transducer, with up to 1.18 percent conversion efficiency and low added microwave noise; the measured link remains loss- and cooperativity-limited."

/-- Directional remote entanglement through a chiral microwave interconnect. -/
def laserReferenceAlmanakly2025ChiralInterconnect : LaserScholarlyReference where
  bibKey := "almanakly2025chiralInterconnect"
  title := "Deterministic remote entanglement using a chiral quantum interconnect"
  year := 2025
  doi := some "10.1038/s41567-025-02811-1"
  sourceUrl := "https://doi.org/10.1038/s41567-025-02811-1"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.processParametersOnly
  roles := [LaserReferenceRole.chiralQuantumInterconnect,
    LaserReferenceRole.remoteEntanglement,
    LaserReferenceRole.superconductingQubit]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Uses interference-controlled directional emission and absorption between superconducting modules; reports a four-qubit W state at about 62 percent fidelity in each direction, with propagation loss as the main limitation."

/-- Dual-beam femtosecond processing for localized waveguide writing. -/
def laserReferenceLapointe2017DualBeamProcessing : LaserScholarlyReference where
  bibKey := "lapointe2017dualBeamProcessing"
  title := "A simple technique to overcome self-focusing, filamentation, supercontinuum generation, aberrations, depth dependence and waveguide interface roughness using fs laser processing"
  year := 2017
  doi := some "10.1038/s41598-017-00589-8"
  sourceUrl := "https://doi.org/10.1038/s41598-017-00589-8"
  localArtifactStatus := LaserReferenceArtifactStatus.accessBlocked
  localArtifact := none
  evidenceStatus := LaserReferenceEvidenceStatus.experimental
  powerEvidence := LaserReferencePowerEvidence.pulseEnergyOrFluence
  roles := [LaserReferenceRole.dualBeamFemtosecondProcessing,
    LaserReferenceRole.selfFocusingSuppression,
    LaserReferenceRole.filamentationSuppression,
    LaserReferenceRole.waveguideWriting]
  procaFieldStatus := LaserReferenceClaimStatus.notDemonstrated
  cwHolographicCarbonSynthesisStatus := LaserReferenceClaimStatus.notDemonstrated
  scopeNote :=
    "Demonstrates two coherent parallel beams focused through one lens to reduce aberration, depth dependence, filamentation, and waveguide-interface roughness in glass; it is a processing geometry, not evidence for a sub-10 nm vitrimer aperture or PCLP cleavage."

/-- Supplemental laser-matter references retained separately from the original
13-work carbon-processing registry. -/
def supplementalLaserMatterReferences : List LaserScholarlyReference :=
  [ laserReferenceLei2025Csr,
    laserReferenceZhang2022FreeElectron,
    laserReferenceKipp2024Cavity,
    laserReferenceGaliffi2023PhononPolariton,
    laserReferenceLightSlingerChat,
    laserReferenceFu2025ElectronNanodiamond,
    laserReferenceBao2025QuantumNanodiamond,
    laserReferenceKim2025ColorCenterPositioning,
    laserReferenceHeinzerling2025AttosecondSoliton,
    laserReferenceSvirplys2025PlasmaLens,
    laserReferenceSolitonQpuBusChat,
    laserReferenceTravers2019SolitonCompression,
    laserReferenceTravers2024HollowCoreReview,
    laserReferenceKivshar1993SolitonSwitching,
    laserReferenceWang2018OAMLongHaul,
    laserReferenceSekine2025MultiOctaveComb,
    laserReferenceWarner2025OpticalQubitControl,
    laserReferenceAlmanakly2025ChiralInterconnect,
    laserReferenceLapointe2017DualBeamProcessing ]

lemma supplementalLaserMatterReferences_count :
  supplementalLaserMatterReferences.length = 19 := by
  rfl

/-- The 13 unique works represented by the canonical attached bibliography. -/
def attachedLaserScholarlyReferences : List LaserScholarlyReference :=
  [ laserReferenceWan2018,
    laserReferenceYe2024,
    laserReferenceCheng2026,
    laserReferencePark2024,
    laserReferenceYou2020,
    laserReferenceClaro2022,
    laserReferenceLee2023,
    laserReferenceKim2025,
    laserReferenceLin2021,
    laserReferenceJoshi2021,
    laserReferenceMorais2026,
    laserReferenceAkkanen2022,
    laserReferenceMikki2021 ]

/-- Duplicate BibTeX records are intentionally merged into one work record. -/
lemma attachedLaserScholarlyReferences_count :
    attachedLaserScholarlyReferences.length = 13 := by
  rfl

/-- Four attached works have verified local PDF artifacts in `data/papers`; the
remaining works retain a DOI/repository source but were access-limited during
the acquisition pass. -/
lemma attachedLaserScholarlyReferences_local_pdf_count :
    (attachedLaserScholarlyReferences.filter (fun reference =>
      reference.localArtifactStatus = LaserReferenceArtifactStatus.localPdf)).length = 4 := by
  rfl

/-- No attached source demonstrates both a Proca field and CW holographic
carbon synthesis in polymer or lignin. -/
lemma attachedLaserScholarlyReferences_claim_boundary :
    ∀ reference ∈ attachedLaserScholarlyReferences,
      reference.cwHolographicCarbonSynthesisStatus ≠
        LaserReferenceClaimStatus.demonstrated := by
  intro reference reference_mem
  simp [attachedLaserScholarlyReferences] at reference_mem
  rcases reference_mem with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
    rfl | rfl | rfl | rfl | rfl <;> decide

/-- No attached source demonstrates a Proca field or CW holographic carbon
synthesis in polymer or lignin. -/
lemma attachedLaserScholarlyReferences_no_Proca_or_CW_holography :
    ∀ reference ∈ attachedLaserScholarlyReferences,
      reference.procaFieldStatus ≠ LaserReferenceClaimStatus.demonstrated ∧
        reference.cwHolographicCarbonSynthesisStatus ≠
          LaserReferenceClaimStatus.demonstrated := by
  intro reference reference_mem
  simp [attachedLaserScholarlyReferences] at reference_mem
  rcases reference_mem with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
    rfl | rfl | rfl | rfl | rfl <;> decide

end Signals.Pending
