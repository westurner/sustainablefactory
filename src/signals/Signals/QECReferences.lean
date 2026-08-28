namespace Signals.Pending

/-! # Reference-only quantum error-correction registry

This module records external references for quantum surface and layer codes. It
intentionally contains no Pauli operators, codespaces, stabilizer groups,
syndrome maps, decoders, homology, or hardware model. URL fields are provenance
strings, not imports or theorem dependencies.
-/

/-- Status of the local treatment of an externally defined quantum-code family. -/
inductive QECReferenceStatus
  | referenceOnly
  | localParameterMetadata
  deriving DecidableEq, Repr

/-- Provenance for a quantum-code family that is not implemented locally. -/
structure QECCodeReference where
  name : String
  zooEntryUrl : String
  zooListUrl : Option String
  primaryReferences : List String
  externalLeanCandidate : Option String
  localStatus : QECReferenceStatus
  scopeNote : String

/-- Reference-only entry for the Kitaev surface code. -/
def surfaceCodeReference : QECCodeReference where
  name := "Kitaev surface code"
  zooEntryUrl := "https://errorcorrectionzoo.org/c/surface"
  zooListUrl := some "https://errorcorrectionzoo.org/list/quantum_surface"
  primaryReferences :=
    [ "https://doi.org/10.1070/RM1997V052N06ABEH002155",
      "https://arxiv.org/abs/quant-ph/9811052" ]
  externalLeanCandidate := some "https://github.com/Stavan-Jain/QECLean"
  localStatus := QECReferenceStatus.referenceOnly
  scopeNote :=
    "A 2D CSS stabilizer code on a cellulation; no local implementation yet."

/-- Reference-only entry for Williamson-Baspin layer codes. -/
def layerCodeReference : QECCodeReference where
  name := "Layer code"
  zooEntryUrl := "https://errorcorrectionzoo.org/c/layer"
  zooListUrl := some "https://errorcorrectionzoo.org/list/quantum_surface"
  primaryReferences :=
    [ "https://doi.org/10.1038/s41467-024-53881-3",
      "https://arxiv.org/abs/2309.16503" ]
  externalLeanCandidate := some "https://github.com/Stavan-Jain/QECLean"
  localStatus := QECReferenceStatus.localParameterMetadata
  scopeNote :=
    "A 3D QLDPC construction from coupled surface-code layers; local code and decoder are not implemented. The supplied quantum_layer list URL currently returns 404; the c/layer entry and quantum_surface list are the stable references."

end Signals.Pending
