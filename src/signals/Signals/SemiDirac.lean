import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Propagation
import Signals.Units

namespace Signals.Pending

open Signals.Propagation
open Signals.Units

/-! # Semi-Dirac and optical-pumping models

The semi-Dirac records below extract the anisotropic low-energy dispersion and
pump-response bookkeeping discussed by Ghosh, Bandyopadhyay, and Singh and by
Uchoa et al. They are finite conditional models. They do not assert that a
lignin-vitrimer, rGO, Proca resonator, graphene layer, or fiber laser realizes
these equations, and they do not infer an absolute process power from the
papers.
-/

/-- A two-dimensional semi-Dirac dispersion with a linear y direction and a
quadratic x direction. The energy scale is normalized so the coefficients have
already absorbed the relevant unit conversions. -/
structure SemiDiracDispersion where
  mass : ℝ
  mass_pos : 0 < mass
  linearVelocity : ℝ
  linearVelocity_pos : 0 < linearVelocity
  momentumX : ℝ
  momentumY : ℝ
  energy : ℝ
  energy_nonnegative : 0 ≤ energy
  dispersionLaw :
    energy ^ 2 =
      (momentumX ^ 2 / (2 * mass)) ^ 2 +
        (linearVelocity * momentumY) ^ 2

/-- The semi-Dirac energy shell is the supplied anisotropic dispersion law. -/
lemma SemiDiracDispersion.dispersion_holds
    (dispersion : SemiDiracDispersion) :
    dispersion.energy ^ 2 =
      (dispersion.momentumX ^ 2 / (2 * dispersion.mass)) ^ 2 +
        (dispersion.linearVelocity * dispersion.momentumY) ^ 2 :=
  dispersion.dispersionLaw

/-- Along the quadratic axis, the model energy is quadratic in momentum when
there is no momentum on the linear axis. -/
lemma SemiDiracDispersion.quadratic_axis_energy_squared
    (dispersion : SemiDiracDispersion)
    (momentumY_zero : dispersion.momentumY = 0) :
    dispersion.energy ^ 2 =
      (dispersion.momentumX ^ 2 / (2 * dispersion.mass)) ^ 2 := by
  rw [dispersion.dispersionLaw, momentumY_zero]
  ring

/-- Along the linear axis, the model energy is linear in the absolute momentum
at the level of squared energy. -/
lemma SemiDiracDispersion.linear_axis_energy_squared
    (dispersion : SemiDiracDispersion)
    (momentumX_zero : dispersion.momentumX = 0) :
    dispersion.energy ^ 2 =
      (dispersion.linearVelocity * dispersion.momentumY) ^ 2 := by
  rw [dispersion.dispersionLaw, momentumX_zero]
  ring

/-- A pump-dependent anisotropic response, stored as a conditional linear
response law. The pump is a nonnegative optical power and the two response
coefficients are measured or supplied model inputs. -/
structure SemiDiracOpticalResponse where
  pumpPower : Power
  pumpPower_nonnegative : 0 ≤ pumpPower.watts
  quadraticResponse : ℝ
  quadraticResponse_nonnegative : 0 ≤ quadraticResponse
  linearResponse : ℝ
  linearResponse_nonnegative : 0 ≤ linearResponse
  quadraticResponseGain : ℝ
  quadraticResponseGain_nonnegative : 0 ≤ quadraticResponseGain
  linearResponseGain : ℝ
  linearResponseGain_nonnegative : 0 ≤ linearResponseGain
  quadraticSignal : ℝ
  quadraticSignal_nonnegative : 0 ≤ quadraticSignal
  linearSignal : ℝ
  linearSignal_nonnegative : 0 ≤ linearSignal
  quadraticResponseLaw : quadraticSignal =
    quadraticResponse + quadraticResponseGain * pumpPower.watts
  linearResponseLaw : linearSignal =
    linearResponse + linearResponseGain * pumpPower.watts

/-- Optical pumping changes the quadratic-axis response according to the
supplied calibration law. -/
lemma SemiDiracOpticalResponse.quadratic_response_holds
    (response : SemiDiracOpticalResponse) :
    response.quadraticSignal =
      response.quadraticResponse +
        response.quadraticResponseGain * response.pumpPower.watts :=
  response.quadraticResponseLaw

/-- Optical pumping changes the linear-axis response according to the supplied
calibration law. -/
lemma SemiDiracOpticalResponse.linear_response_holds
    (response : SemiDiracOpticalResponse) :
    response.linearSignal =
      response.linearResponse +
        response.linearResponseGain * response.pumpPower.watts :=
  response.linearResponseLaw

/-- A positive pump and strictly positive calibrated gain increase an axis
response. -/
lemma SemiDiracOpticalResponse.quadratic_response_increases
    (response : SemiDiracOpticalResponse)
    (pumpPower_pos : 0 < response.pumpPower.watts)
    (gain_pos : 0 < response.quadraticResponseGain) :
    response.quadraticResponse < response.quadraticSignal := by
  rw [response.quadraticResponseLaw]
  nlinarith

/-- The corresponding monotonicity result for the linear axis. -/
lemma SemiDiracOpticalResponse.linear_response_increases
    (response : SemiDiracOpticalResponse)
    (pumpPower_pos : 0 < response.pumpPower.watts)
    (gain_pos : 0 < response.linearResponseGain) :
    response.linearResponse < response.linearSignal := by
  rw [response.linearResponseLaw]
  nlinarith

/-- Power allocated to an optical control chain. `fiberLaserPower` is the
laser electrical/optical input budget, while the remaining powers are declared
loads or losses. -/
structure SemiDiracOpticalPowerBudget where
  fiberLaserPower : Power
  fiberLaserPower_nonnegative : 0 ≤ fiberLaserPower.watts
  resonatorPower : Power
  resonatorPower_nonnegative : 0 ≤ resonatorPower.watts
  metamaterialPower : Power
  metamaterialPower_nonnegative : 0 ≤ metamaterialPower.watts
  processPower : Power
  processPower_nonnegative : 0 ≤ processPower.watts
  lossPower : Power
  lossPower_nonnegative : 0 ≤ lossPower.watts
  inputPower : Power
  inputPower_nonnegative : 0 ≤ inputPower.watts
  powerBalance : resonatorPower.watts + metamaterialPower.watts +
    processPower.watts + lossPower.watts = inputPower.watts
  laserInputLaw : inputPower.watts = fiberLaserPower.watts

/-- The declared fiber-laser input supplies all listed control, process, and
loss powers. -/
lemma SemiDiracOpticalPowerBudget.declared_outputs_plus_loss_equals_input
    (budget : SemiDiracOpticalPowerBudget) :
    budget.resonatorPower.watts + budget.metamaterialPower.watts +
        budget.processPower.watts + budget.lossPower.watts =
      budget.fiberLaserPower.watts := by
  rw [← budget.laserInputLaw]
  exact budget.powerBalance

/-- No declared process or control output can exceed the fiber-laser input. -/
lemma SemiDiracOpticalPowerBudget.outputs_le_fiber_laser
    (budget : SemiDiracOpticalPowerBudget) :
    budget.resonatorPower.watts + budget.metamaterialPower.watts +
        budget.processPower.watts ≤ budget.fiberLaserPower.watts := by
  have balance : budget.resonatorPower.watts + budget.metamaterialPower.watts +
      budget.processPower.watts + budget.lossPower.watts =
        budget.inputPower.watts := budget.powerBalance
  rw [budget.laserInputLaw] at balance
  linarith [budget.powerBalance, budget.lossPower_nonnegative]

/-- A calibrated absorbed-power requirement gives a necessary lower bound on
fiber-laser power after an explicit end-to-end efficiency. -/
structure SemiDiracGrapheneProcess where
  budget : SemiDiracOpticalPowerBudget
  endToEndEfficiency : BoundedFactor
  absorbedPower : Power
  absorbedPower_nonnegative : 0 ≤ absorbedPower.watts
  absorbedPowerLaw : absorbedPower.watts =
    endToEndEfficiency.value * budget.fiberLaserPower.watts
  requiredAbsorbedPower : Power
  requiredAbsorbedPower_nonnegative : 0 ≤ requiredAbsorbedPower.watts
  thresholdLaw : requiredAbsorbedPower.watts ≤ absorbedPower.watts
  materialCalibrationSpecified : Bool
  phaseIdentificationSpecified : Bool
  grapheneFormationVerified : Bool

/-- The process threshold is met only when the declared absorbed power reaches
its calibrated requirement. -/
lemma SemiDiracGrapheneProcess.threshold_holds
    (process : SemiDiracGrapheneProcess) :
    process.requiredAbsorbedPower.watts ≤ process.absorbedPower.watts :=
  process.thresholdLaw

/-- Under a positive end-to-end efficiency, meeting the calibrated threshold
requires at least threshold divided by efficiency at the fiber-laser input. -/
lemma SemiDiracGrapheneProcess.fiber_laser_power_lower_bound
    (process : SemiDiracGrapheneProcess)
    (efficiency_pos : 0 < process.endToEndEfficiency.value) :
    process.requiredAbsorbedPower.watts /
        process.endToEndEfficiency.value ≤ process.budget.fiberLaserPower.watts := by
  have threshold : process.requiredAbsorbedPower.watts ≤
      process.endToEndEfficiency.value * process.budget.fiberLaserPower.watts := by
    calc
      process.requiredAbsorbedPower.watts ≤ process.absorbedPower.watts :=
        process.thresholdLaw
      _ = process.endToEndEfficiency.value * process.budget.fiberLaserPower.watts :=
        process.absorbedPowerLaw
  apply (div_le_iff₀ efficiency_pos).2
  simpa [mul_comm] using threshold

end Signals.Pending
