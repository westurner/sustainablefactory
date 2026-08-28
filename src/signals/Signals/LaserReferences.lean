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
