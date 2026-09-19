import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Units

namespace Signals.Saser

open Signals.Units

/-! # SASER and phonon-source bookkeeping

Sound Amplification by Stimulated Emission of Radiation, with acoustic or
phonon-vortex output. These records preserve the modeled momentum and thrust
relations without treating them as demonstrated hardware performance.

See also `Signals.Lasers`
-/

/-- Modeled SASER source families. -/
inductive SaserKind
  | polaritonVortexRing
  | phononCavity
  | acousticCavity
  deriving DecidableEq, Repr

/-- Evidence boundary for a SASER model. -/
inductive SaserStatus
  | modeledOnly
  | calibrationRequired
  | experimentallyObserved
  deriving DecidableEq, Repr

/-- Planck action used by the normalized vortex-ring impulse model. -/
structure PlanckAction where
  jouleSeconds : ℝ
  jouleSeconds_nonnegative : 0 ≤ jouleSeconds

/-- Parameters for the modeled vortex-ring SASER relation. -/
structure VortexRingParameters where
  numberDensity : ℝ
  numberDensity_nonnegative : 0 ≤ numberDensity
  planckAction : PlanckAction
  ringRadius : Length
  ringRadius_pos : 0 < ringRadius.meters
  emissionRate : Frequency
  emissionRate_nonnegative : 0 ≤ emissionRate.hz

/-- Momentum assigned to one emitted vortex ring in the normalized model. -/
noncomputable def VortexRingParameters.ringImpulse
    (parameters : VortexRingParameters) : ℝ :=
  Real.pi * parameters.numberDensity * parameters.planckAction.jouleSeconds *
    parameters.ringRadius.meters ^ 2

/-- Thrust assigned to a steady vortex-ring emission rate. -/
noncomputable def VortexRingParameters.thrust
    (parameters : VortexRingParameters) : ℝ :=
  parameters.emissionRate.hz * parameters.ringImpulse

/-- The normalized ring impulse is nonnegative. -/
lemma VortexRingParameters.ringImpulse_nonnegative
    (parameters : VortexRingParameters) :
    0 ≤ parameters.ringImpulse := by
  unfold VortexRingParameters.ringImpulse
  have pi_nonnegative : 0 ≤ Real.pi := le_of_lt Real.pi_pos
  have radius_squared_nonnegative :
      0 ≤ parameters.ringRadius.meters ^ 2 := sq_nonneg _
  exact mul_nonneg
    (mul_nonneg
      (mul_nonneg pi_nonnegative parameters.numberDensity_nonnegative)
      parameters.planckAction.jouleSeconds_nonnegative)
    radius_squared_nonnegative

/-- The normalized SASER thrust is nonnegative. -/
lemma VortexRingParameters.thrust_nonnegative
    (parameters : VortexRingParameters) :
    0 ≤ parameters.thrust := by
  unfold VortexRingParameters.thrust
  exact mul_nonneg parameters.emissionRate_nonnegative
    parameters.ringImpulse_nonnegative

/-- A complete, evidence-labeled SASER profile. -/
structure Profile where
  kind : SaserKind
  status : SaserStatus
  parameters : VortexRingParameters

end Signals.Saser
