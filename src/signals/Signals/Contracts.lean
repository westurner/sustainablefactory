import Mathlib.Data.Real.Basic

namespace Signals.Contracts

/-! Generic contracts shared by measured observations and model predictions. -/

/-- A measured-versus-predicted result with an explicit residual law.

The residual and magnitude functions are parameters of the contract rather than
global subtraction or norm operations. This keeps units and domain semantics in
the specialized adapter while allowing common acceptance tooling. -/
structure ResidualContract (Measurement Prediction Residual : Type*) where
  measured : Measurement
  predicted : Prediction
  residual : Residual
  residualFunction : Measurement → Prediction → Residual
  residualLaw : residual = residualFunction measured predicted
  magnitude : Residual → ℝ
  magnitude_nonnegative : 0 ≤ magnitude residual
  tolerance : ℝ
  tolerance_nonnegative : 0 ≤ tolerance
  withinTolerance : magnitude residual ≤ tolerance

/-- The residual is computed by the contract's supplied residual function. -/
lemma ResidualContract.residual_holds
    {Measurement Prediction Residual : Type*}
    (contract : ResidualContract Measurement Prediction Residual) :
    contract.residual = contract.residualFunction contract.measured contract.predicted :=
  contract.residualLaw

/-- The contract's residual satisfies its declared acceptance bound. -/
def ResidualContract.accepted
    {Measurement Prediction Residual : Type*}
    (contract : ResidualContract Measurement Prediction Residual) : Prop :=
  contract.magnitude contract.residual ≤ contract.tolerance

/-- Acceptance is exactly the supplied residual bound. -/
lemma ResidualContract.accepted_iff
    {Measurement Prediction Residual : Type*}
    (contract : ResidualContract Measurement Prediction Residual) :
    contract.accepted ↔ contract.magnitude contract.residual ≤ contract.tolerance :=
  Iff.rfl

end Signals.Contracts