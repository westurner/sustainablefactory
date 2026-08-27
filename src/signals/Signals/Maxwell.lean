import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace Signals.Maxwell

/-- A three-component real spatial vector.

Vector fields are represented directly, without Euler angles or orientation
charts. This is the representation-level reason the model has no gimbal-lock
state. -/
abbrev Vector3 := Fin 3 → ℝ

/-- Abstract vector-calculus operators used by the pointwise Maxwell model.

The two identities record the differential facts needed below. A concrete
calculus implementation must provide them; they are not global axioms. -/
structure VectorCalculus where
  divergence : Vector3 → ℝ
  curl : Vector3 → Vector3
  vectorTimeDerivative : Vector3 → Vector3
  scalarTimeDerivative : ℝ → ℝ
  divergence_curl : ∀ vector, divergence (curl vector) = 0
  divergence_add : ∀ left right,
    divergence (left + right) = divergence left + divergence right
  divergence_timeDerivative : ∀ vector,
    divergence (vectorTimeDerivative vector) = scalarTimeDerivative (divergence vector)

/-- Positive permittivity and permeability for an isotropic material model. -/
structure MaterialParameters where
  permittivity : ℝ
  permittivity_pos : 0 < permittivity
  permeability : ℝ
  permeability_pos : 0 < permeability

/- A source view shared by classical field models. -/
structure Source where
  chargeDensity : ℝ
  current : Vector3
  continuityResidual : ℝ

/-- Macroscopic Maxwell fields and sources in three-vector notation.

The fields use the standard $(E,D,B,H)$ convention and the source terms are
charge density `rho` and current density `current`. -/
structure System (calculus : VectorCalculus) where
  electricField : Vector3
  displacementField : Vector3
  magneticField : Vector3
  magneticIntensity : Vector3
  rho : ℝ
  current : Vector3
  gaussElectric : calculus.divergence displacementField = rho
  gaussMagnetic : calculus.divergence magneticField = 0
  faraday : calculus.curl electricField = -calculus.vectorTimeDerivative magneticField
  ampere : calculus.curl magneticIntensity =
    current + calculus.vectorTimeDerivative displacementField

/- The source view of a Maxwell system's scalar and vector source fields. -/
def System.source {calculus : VectorCalculus} (system : System calculus) : Source :=
  { chargeDensity := system.rho
    current := system.current
    continuityResidual :=
      calculus.scalarTimeDerivative system.rho + calculus.divergence system.current }

/-- Gauss's electric equation is available directly from the system record. -/
lemma System.gauss_electric {calculus : VectorCalculus} (system : System calculus) :
    calculus.divergence system.displacementField = system.rho :=
  system.gaussElectric

/-- Gauss's magnetic equation excludes magnetic monopole density in this model. -/
lemma System.gauss_magnetic {calculus : VectorCalculus} (system : System calculus) :
    calculus.divergence system.magneticField = 0 :=
  system.gaussMagnetic

/-- Faraday's induction equation in three-vector notation. -/
lemma System.faraday_law {calculus : VectorCalculus} (system : System calculus) :
    calculus.curl system.electricField = -calculus.vectorTimeDerivative system.magneticField :=
  system.faraday

/-- Ampere-Maxwell's equation in three-vector notation. -/
lemma System.ampere_maxwell_law {calculus : VectorCalculus} (system : System calculus) :
    calculus.curl system.magneticIntensity =
      system.current + calculus.vectorTimeDerivative system.displacementField :=
  system.ampere

/-- Charge conservation follows from Ampere-Maxwell and Gauss's electric law.

This theorem uses only the supplied `divergence_curl` and
`divergence_timeDerivative` identities, so it separates the vector-calculus
content from the electromagnetic field equations. -/
lemma System.charge_continuity {calculus : VectorCalculus} (system : System calculus) :
    calculus.scalarTimeDerivative system.rho + calculus.divergence system.current = 0 := by
  have divergence_ampere := congrArg calculus.divergence system.ampere
  rw [calculus.divergence_curl, calculus.divergence_add,
    calculus.divergence_timeDerivative,
    system.gaussElectric] at divergence_ampere
  linarith

/- The Maxwell source view has zero continuity residual. -/
lemma System.source_continuity_residual {calculus : VectorCalculus}
    (system : System calculus) :
    system.source.continuityResidual = 0 := by
  exact system.charge_continuity

/-- A source-free macroscopic Maxwell system has zero current and charge density. -/
structure SourceFreeSystem (calculus : VectorCalculus) extends System calculus where
  rho_zero : rho = 0
  current_zero : current = 0

/-- Maxwell's equations after imposing isotropic vacuum constitutive laws.

This is the compact pre-tensor vector-calculus form often used for Maxwell's
original field equations: no metric tensor, coordinate frame, or Euler-angle
orientation is part of the representation. -/
structure OriginalVacuumSystem (calculus : VectorCalculus) where
  parameters : MaterialParameters
  electricField : Vector3
  magneticField : Vector3
  rho : ℝ
  current : Vector3
  gaussElectric : calculus.divergence electricField =
    rho / parameters.permittivity
  gaussMagnetic : calculus.divergence magneticField = 0
  faraday : calculus.curl electricField = -calculus.vectorTimeDerivative magneticField
  ampere : calculus.curl magneticField =
    parameters.permeability • current +
      (parameters.permeability * parameters.permittivity) •
        calculus.vectorTimeDerivative electricField

/-- The electric Gauss law for the original isotropic-vacuum form. -/
lemma OriginalVacuumSystem.gauss_electric {calculus : VectorCalculus}
    (system : OriginalVacuumSystem calculus) :
    calculus.divergence system.electricField =
      system.rho / system.parameters.permittivity :=
  system.gaussElectric

/-- The magnetic Gauss law for the original isotropic-vacuum form. -/
lemma OriginalVacuumSystem.gauss_magnetic {calculus : VectorCalculus}
    (system : OriginalVacuumSystem calculus) :
    calculus.divergence system.magneticField = 0 :=
  system.gaussMagnetic

/-- The displacement-current term uses the product of vacuum permeability and
permittivity in this normalized vector form. -/
lemma OriginalVacuumSystem.ampere_maxwell_law {calculus : VectorCalculus}
    (system : OriginalVacuumSystem calculus) :
    calculus.curl system.magneticField =
      system.parameters.permeability • system.current +
        (system.parameters.permeability * system.parameters.permittivity) •
          calculus.vectorTimeDerivative system.electricField :=
  system.ampere

end Signals.Maxwell