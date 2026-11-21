import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Signals.Proca
import Signals.Units

namespace Signals.GrassmannianEBR

noncomputable section

/-! Finite algebraic contracts extracted and corrected from the numbered chat blocks.
They describe consequences of explicit inputs, not measured physical behavior. -/

/-- Six real Pluecker coordinates on the real slice of `Gr(2, 4)`. -/
structure PluckerCoordinatesGr24 where
  p12 : ℝ
  p13 : ℝ
  p14 : ℝ
  p23 : ℝ
  p24 : ℝ
  p34 : ℝ

/-- The Klein-quadric residual in the chosen coordinate convention. -/
def pluckerQuadraticResidual (point : PluckerCoordinatesGr24) : ℝ :=
  point.p12 * point.p34 - point.p13 * point.p24 + point.p14 * point.p23

/-- A point and tangent direction defining an affine line in three dimensions. -/
structure YarnLineFrame where
  positionX : ℝ
  positionY : ℝ
  positionZ : ℝ
  tangentX : ℝ
  tangentY : ℝ
  tangentZ : ℝ

/-- Lift the line spanned by `(1, position)` and `(0, tangent)` to Pluecker coordinates. -/
def yarnLinePlucker (frame : YarnLineFrame) : PluckerCoordinatesGr24 :=
  { p12 := frame.tangentX
    p13 := frame.tangentY
    p14 := frame.tangentZ
    p23 := frame.positionX * frame.tangentY - frame.positionY * frame.tangentX
    p24 := frame.positionX * frame.tangentZ - frame.positionZ * frame.tangentX
    p34 := frame.positionY * frame.tangentZ - frame.positionZ * frame.tangentY }

/-- Every line lift is decomposable and therefore satisfies the Klein relation. -/
theorem yarnLinePlucker_satisfiesKlein (frame : YarnLineFrame) :
    pluckerQuadraticResidual (yarnLinePlucker frame) = 0 := by
  simp [pluckerQuadraticResidual, yarnLinePlucker]
  ring

/-- Reflect a line frame through the plane `z = 0`. -/
def reflectYarnLine (frame : YarnLineFrame) : YarnLineFrame :=
  { frame with positionZ := -frame.positionZ, tangentZ := -frame.tangentZ }

/-- The three Pluecker coordinates involving the reflected axis change sign. -/
theorem yarnLinePlucker_reflection_signs (frame : YarnLineFrame) :
    (yarnLinePlucker (reflectYarnLine frame)).p14 = -(yarnLinePlucker frame).p14 ∧
    (yarnLinePlucker (reflectYarnLine frame)).p24 = -(yarnLinePlucker frame).p24 ∧
    (yarnLinePlucker (reflectYarnLine frame)).p34 = -(yarnLinePlucker frame).p34 := by
  constructor
  · rfl
  constructor
  · simp [yarnLinePlucker, reflectYarnLine]
    ring
  · simp [yarnLinePlucker, reflectYarnLine]
    ring

/-- Algebraic Hodge-star involution on two-form coordinates with the stated signs. -/
def hodgeStarGr24 (point : PluckerCoordinatesGr24) : PluckerCoordinatesGr24 :=
  { p12 := point.p34
    p13 := -point.p24
    p14 := point.p23
    p23 := point.p14
    p24 := -point.p13
    p34 := point.p12 }

/-- Applying the coordinate Hodge star twice returns the original two-form. -/
theorem hodgeStarGr24_involutive (point : PluckerCoordinatesGr24) :
    hodgeStarGr24 (hodgeStarGr24 point) = point := by
  cases point
  simp [hodgeStarGr24]

/-- The Klein-quadric residual is invariant under the coordinate Hodge star. -/
theorem pluckerQuadraticResidual_hodgeStar (point : PluckerCoordinatesGr24) :
    pluckerQuadraticResidual (hodgeStarGr24 point) = pluckerQuadraticResidual point := by
  cases point
  simp [pluckerQuadraticResidual, hodgeStarGr24]
  ring

/-- Abstract Schubert coordinates for the six partitions contained in `(2, 2)`. -/
structure SchubertClassGr24 where
  unit : ℤ
  divisor : ℤ
  rowTwo : ℤ
  columnTwo : ℤ
  hook : ℤ
  point : ℤ
  deriving DecidableEq, Repr

/-- The integral Schubert product for `Gr(2, 4)`, using the Pieri multiplication table. -/
def schubertProductGr24 (left right : SchubertClassGr24) : SchubertClassGr24 where
  unit := left.unit * right.unit
  divisor := left.unit * right.divisor + left.divisor * right.unit
  rowTwo := left.unit * right.rowTwo + left.divisor * right.divisor + left.rowTwo * right.unit
  columnTwo := left.unit * right.columnTwo + left.divisor * right.divisor + left.columnTwo * right.unit
  hook := left.unit * right.hook + left.divisor * (right.rowTwo + right.columnTwo) +
    (left.rowTwo + left.columnTwo) * right.divisor + left.hook * right.unit
  point := left.unit * right.point + left.divisor * right.hook + left.rowTwo * right.rowTwo +
    left.columnTwo * right.columnTwo + left.hook * right.divisor + left.point * right.unit

/-- The divisor class `sigma_1`. -/
def sigmaOneGr24 : SchubertClassGr24 := ⟨0, 1, 0, 0, 0, 0⟩

/-- The row class `sigma_2`. -/
def sigmaTwoGr24 : SchubertClassGr24 := ⟨0, 0, 1, 0, 0, 0⟩

/-- The column class `sigma_(1,1)`. -/
def sigmaOneOneGr24 : SchubertClassGr24 := ⟨0, 0, 0, 1, 0, 0⟩

/-- The Schubert multiplication identities used by the finite intersection check figure. -/
theorem schubertGr24_intersectionIdentities :
    let divisorSquare := schubertProductGr24 sigmaOneGr24 sigmaOneGr24
    let divisorFourth := schubertProductGr24 divisorSquare divisorSquare
    let rowColumn := schubertProductGr24 sigmaTwoGr24 sigmaOneOneGr24
    divisorSquare.rowTwo = 1 ∧ divisorSquare.columnTwo = 1 ∧
      rowColumn.point = 0 ∧ divisorFourth.point = 2 := by
  norm_num [schubertProductGr24, sigmaOneGr24, sigmaTwoGr24, sigmaOneOneGr24]

/-- Number of representatives in the even-square `D4` orbit-count model. -/
def p4mOrbitCount (halfWidth : ℕ) : ℕ :=
  halfWidth + halfWidth * (halfWidth - 1) / 2

/-- Multiplicity-weighted site count in the even-square `D4` orbit-count model. -/
def p4mOrbitMultiplicitySum (halfWidth : ℕ) : ℕ :=
  4 * halfWidth + 8 * (halfWidth * (halfWidth - 1) / 2)

/-- Exact p4m orbit-count check figures for 8- and 16-cell square grids. -/
theorem p4mOrbitCount_checkFigures :
    p4mOrbitCount 4 = 10 ∧ p4mOrbitMultiplicitySum 4 = 64 ∧
      p4mOrbitCount 8 = 36 ∧ p4mOrbitMultiplicitySum 8 = 256 := by
  norm_num [p4mOrbitCount, p4mOrbitMultiplicitySum]

/-- Product of a planar point-group order and a layer-reflection order. -/
def layerGroupOrder (planarOrder layerOrder : ℕ) : ℕ := planarOrder * layerOrder

/-- The supplied `p6m` and layer-reflection factors multiply to 24. -/
theorem layerGroupOrder_checkFigure : layerGroupOrder 12 2 = 24 := by
  norm_num [layerGroupOrder]

/-- Hooke-style scalar energy for supplied trace, shear, and link residuals. -/
def knittedHookeEnergy
    (bulkModulus shearModulus linkStiffness traceStrain shearNormSq linkResidual : ℝ) : ℝ :=
  (1 / 2) * bulkModulus * traceStrain ^ 2 + shearModulus * shearNormSq +
    (1 / 2) * linkStiffness * linkResidual ^ 2

/-- Energy difference for the explicitly parameterized shear damping and link reset. -/
def deborahStickSlipEnergyDrop
    (bulkModulus shearModulus linkStiffness traceStrain shearNormSq linkResidual damping : ℝ) : ℝ :=
  knittedHookeEnergy bulkModulus shearModulus linkStiffness traceStrain shearNormSq linkResidual -
    knittedHookeEnergy bulkModulus shearModulus linkStiffness traceStrain
      (damping * shearNormSq) 0

/-- The exact algebraic energy difference under this scalar update. -/
theorem deborahStickSlipEnergyDrop_eq
    (bulkModulus shearModulus linkStiffness traceStrain shearNormSq linkResidual damping : ℝ) :
    deborahStickSlipEnergyDrop bulkModulus shearModulus linkStiffness traceStrain
      shearNormSq linkResidual damping =
        shearModulus * (1 - damping) * shearNormSq +
          (1 / 2) * linkStiffness * linkResidual ^ 2 := by
  unfold deborahStickSlipEnergyDrop knittedHookeEnergy
  ring

/-- A nonzero link residual makes the modeled energy drop strictly positive under the stated bounds. -/
theorem deborahStickSlipEnergyDrop_pos
    (bulkModulus shearModulus linkStiffness traceStrain shearNormSq linkResidual damping : ℝ)
    (shearModulus_pos : 0 < shearModulus)
    (linkStiffness_pos : 0 < linkStiffness)
    (shearNormSq_nonneg : 0 ≤ shearNormSq)
    (damping_le_one : damping ≤ 1)
    (linkResidual_ne_zero : linkResidual ≠ 0) :
    0 < deborahStickSlipEnergyDrop bulkModulus shearModulus linkStiffness traceStrain
      shearNormSq linkResidual damping := by
  rw [deborahStickSlipEnergyDrop_eq]
  have shear_drop_nonneg : 0 ≤ shearModulus * (1 - damping) * shearNormSq := by
    positivity
  have link_drop_pos : 0 < (1 / 2 : ℝ) * linkStiffness * linkResidual ^ 2 := by
    have link_sq_pos : 0 < linkResidual ^ 2 := sq_pos_of_ne_zero linkResidual_ne_zero
    positivity
  linarith

/-- McWeeny scalar polynomial used as a finite algebraic sharpening map. -/
def mcweenyScalarSharpen (value : ℝ) : ℝ := 3 * value ^ 2 - 2 * value ^ 3

/-- The McWeeny polynomial fixes binary values and has the stated exact displacement factorization. -/
theorem mcweenyScalarSharpen_identities (value : ℝ) :
    mcweenyScalarSharpen 0 = 0 ∧ mcweenyScalarSharpen 1 = 1 ∧
      mcweenyScalarSharpen value - value = value * (1 - value) * (2 * value - 1) := by
  unfold mcweenyScalarSharpen
  constructor
  · norm_num
  constructor
  · norm_num
  · ring

/-- Strictly sub-half values move downward under the scalar McWeeny polynomial. -/
theorem mcweenyScalarSharpen_lt_of_lt_half
    (value : ℝ) (value_pos : 0 < value) (value_lt_half : value < 1 / 2) :
    mcweenyScalarSharpen value < value := by
  have one_minus_pos : 0 < 1 - value := by linarith
  have one_minus_twice_pos : 0 < 1 - 2 * value := by linarith
  have displacement := mcweenyScalarSharpen_identities value
  have product_pos : 0 < value * (1 - value) * (1 - 2 * value) :=
    mul_pos (mul_pos value_pos one_minus_pos) one_minus_twice_pos
  have rearranged : mcweenyScalarSharpen value - value =
      -(value * (1 - value) * (1 - 2 * value)) := by
    rw [displacement.2.2]
    ring
  linarith

/-- Strictly super-half values move upward; the midpoint remains a fractional fixed point. -/
theorem mcweenyScalarSharpen_gt_of_gt_half
    (value : ℝ) (value_lt_one : value < 1) (half_lt_value : 1 / 2 < value) :
    value < mcweenyScalarSharpen value := by
  have value_pos : 0 < value := by linarith
  have one_minus_pos : 0 < 1 - value := by linarith
  have twice_minus_one_pos : 0 < 2 * value - 1 := by linarith
  have displacement := mcweenyScalarSharpen_identities value
  have product_pos : 0 < value * (1 - value) * (2 * value - 1) :=
    mul_pos (mul_pos value_pos one_minus_pos) twice_minus_one_pos
  linarith [displacement.2.2]

/-- Two reference determinants with an explicit overlap and coupling parameter. -/
structure TwoReferenceEnergyModel where
  brokenSymmetryEnergy : ℝ
  overlap : ℝ
  coupling : ℝ
  overlap_gt_neg_one : -1 < overlap
  coupling_pos : 0 < coupling

/-- Conditional two-state secular energy implied by the supplied overlap/coupling model. -/
def TwoReferenceEnergyModel.mixedEnergy (model : TwoReferenceEnergyModel) : ℝ :=
  model.brokenSymmetryEnergy - model.coupling / (1 + model.overlap)

/-- The two-state model lowers the reference energy under its explicit assumptions. -/
theorem TwoReferenceEnergyModel.mixedEnergy_lt
    (model : TwoReferenceEnergyModel) : model.mixedEnergy < model.brokenSymmetryEnergy := by
  have denominator_pos : 0 < 1 + model.overlap := by linarith [model.overlap_gt_neg_one]
  have correction_pos : 0 < model.coupling / (1 + model.overlap) :=
    div_pos model.coupling_pos denominator_pos
  exact sub_lt_self _ correction_pos

/-- Coordinates centered on the Riemann critical line; this is only a symmetry model. -/
structure CriticalStripCoordinates where
  sigmaDeviation : ℝ
  ordinate : ℝ

/-- Reflection across the line `sigmaDeviation = 0`. -/
def criticalLineReflection (point : CriticalStripCoordinates) : CriticalStripCoordinates :=
  { sigmaDeviation := -point.sigmaDeviation, ordinate := point.ordinate }

/-- A point is fixed by the reflection exactly when it lies on the symmetry axis. -/
theorem criticalLineReflection_fixed_iff (point : CriticalStripCoordinates) :
    criticalLineReflection point = point ↔ point.sigmaDeviation = 0 := by
  constructor
  · intro fixed
    have coordinate_eq := congrArg CriticalStripCoordinates.sigmaDeviation fixed
    dsimp [criticalLineReflection] at coordinate_eq
    linarith
  · intro on_axis
    cases point with
    | mk sigmaDeviation ordinate =>
      change sigmaDeviation = 0 at on_axis
      simp [criticalLineReflection, on_axis]

/-- Even polynomial energy used to encode reflection symmetry, with no zero-location conclusion. -/
def criticalStripEvenEnergy
    (base curvature quartic sigmaDeviation : ℝ) : ℝ :=
  base + (curvature / 2) * sigmaDeviation ^ 2 + (quartic / 4) * sigmaDeviation ^ 4

/-- The model energy is invariant under critical-line reflection. -/
theorem criticalStripEvenEnergy_reflection
    (base curvature quartic sigmaDeviation : ℝ) :
    criticalStripEvenEnergy base curvature quartic (-sigmaDeviation) =
      criticalStripEvenEnergy base curvature quartic sigmaDeviation := by
  unfold criticalStripEvenEnergy
  ring

/-- Scalar Cauchy-Riemann-inspired polynomial used in the chat's strip model. -/
def criticalStripPolynomialEnergy
    (zValue zPrime zDoublePrime sigmaDeviation : ℝ) : ℝ :=
  (zValue - (1 / 2) * zDoublePrime * sigmaDeviation ^ 2) ^ 2 +
    (zPrime * sigmaDeviation) ^ 2

/-- The quadratic coefficient of the scalar strip polynomial. -/
def jensenPolyaDiscriminant (zValue zPrime zDoublePrime : ℝ) : ℝ :=
  zPrime ^ 2 - zValue * zDoublePrime

/-- Exact polynomial expansion; no analytic zeta-function property is assumed. -/
theorem criticalStripPolynomialEnergy_expansion
    (zValue zPrime zDoublePrime sigmaDeviation : ℝ) :
    criticalStripPolynomialEnergy zValue zPrime zDoublePrime sigmaDeviation =
      zValue ^ 2 + jensenPolyaDiscriminant zValue zPrime zDoublePrime * sigmaDeviation ^ 2 +
        (1 / 4) * zDoublePrime ^ 2 * sigmaDeviation ^ 4 := by
  unfold criticalStripPolynomialEnergy jensenPolyaDiscriminant
  ring

/-- Positive supplied discriminant makes the polynomial energy larger off the axis. -/
theorem criticalStripPolynomialEnergy_gt_on_axis
    (zValue zPrime zDoublePrime sigmaDeviation : ℝ)
    (discriminant_pos : 0 < jensenPolyaDiscriminant zValue zPrime zDoublePrime)
    (off_axis : sigmaDeviation ≠ 0) :
    criticalStripPolynomialEnergy zValue zPrime zDoublePrime 0 <
      criticalStripPolynomialEnergy zValue zPrime zDoublePrime sigmaDeviation := by
  rw [criticalStripPolynomialEnergy_expansion, criticalStripPolynomialEnergy_expansion]
  have sigma_sq_pos : 0 < sigmaDeviation ^ 2 := sq_pos_of_ne_zero off_axis
  have quadratic_pos : 0 <
      jensenPolyaDiscriminant zValue zPrime zDoublePrime * sigmaDeviation ^ 2 :=
    mul_pos discriminant_pos sigma_sq_pos
  have quartic_nonneg : 0 ≤ (1 / 4 : ℝ) * zDoublePrime ^ 2 * sigmaDeviation ^ 4 := by
    positivity
  linarith

/-- Conditional recurrent-step model for a slow-rate and a faster-rate trajectory. -/
structure TwoPhaseHaltingRates where
  logGradientRatio : ℝ
  slowRate : ℝ
  fastRate : ℝ
  baselineBarrierSteps : ℝ
  phaseOneSteps : ℝ

/-- Baseline steps under the supplied slow relaxation rate. -/
def TwoPhaseHaltingRates.baselineSteps (model : TwoPhaseHaltingRates) : ℝ :=
  model.logGradientRatio / model.slowRate + model.baselineBarrierSteps

/-- Two-phase steps under the supplied fast rate and phase-one cost. -/
def TwoPhaseHaltingRates.twoPhaseSteps (model : TwoPhaseHaltingRates) : ℝ :=
  model.phaseOneSteps + model.logGradientRatio / model.fastRate

/-- The two-phase arithmetic model is faster under the explicitly stated inequalities. -/
theorem TwoPhaseHaltingRates.twoPhaseSteps_lt
    (model : TwoPhaseHaltingRates)
    (logGradientRatio_pos : 0 < model.logGradientRatio)
    (slowRate_pos : 0 < model.slowRate)
    (fastRate_gt_slow : model.slowRate < model.fastRate)
    (phaseOne_cost : model.phaseOneSteps ≤ model.baselineBarrierSteps) :
    model.twoPhaseSteps < model.baselineSteps := by
  unfold TwoPhaseHaltingRates.twoPhaseSteps TwoPhaseHaltingRates.baselineSteps
  have fastRate_pos : 0 < model.fastRate := lt_trans slowRate_pos fastRate_gt_slow
  have inverse_step_better : model.logGradientRatio / model.fastRate <
      model.logGradientRatio / model.slowRate :=
    div_lt_div_of_pos_left logGradientRatio_pos slowRate_pos fastRate_gt_slow
  linarith

/-- Scalar wave-number inputs for an effective dispersion interval on the real slice. -/
structure Gr24DispersionParameters where
  omegaOverC : ℝ
  kParallel : ℝ
  kzReal : ℝ

/-- Effective dispersion interval `(omega/c)^2 - kParallel^2 - kzReal^2`. -/
def gr24DispersionInterval (mode : Gr24DispersionParameters) : ℝ :=
  mode.omegaOverC ^ 2 - mode.kParallel ^ 2 - mode.kzReal ^ 2

/-- Every real-valued dispersion interval lies in exactly one sign sector. -/
theorem gr24DispersionInterval_trichotomy (mode : Gr24DispersionParameters) :
    gr24DispersionInterval mode < 0 ∨ gr24DispersionInterval mode = 0 ∨
      0 < gr24DispersionInterval mode := by
  exact lt_trichotomy (gr24DispersionInterval mode) 0

/-- Concrete scalar witnesses for negative, null, and positive intervals. -/
theorem gr24DispersionInterval_checkFigures :
    gr24DispersionInterval ⟨1, 2, 0⟩ < 0 ∧
      gr24DispersionInterval ⟨1, 1, 0⟩ = 0 ∧
      0 < gr24DispersionInterval ⟨2, 1, 1⟩ := by
  norm_num [gr24DispersionInterval]

/-- The supplied above-cutoff, zero-real-`kz` case has a negative interval. -/
theorem gr24DispersionInterval_neg_of_aboveCutoff
    (mode : Gr24DispersionParameters)
    (frequency_nonneg : 0 ≤ mode.omegaOverC)
    (above_cutoff : mode.omegaOverC < mode.kParallel)
    (no_real_kz : mode.kzReal = 0) :
    gr24DispersionInterval mode < 0 := by
  unfold gr24DispersionInterval
  rw [no_real_kz]
  have square_lt : mode.omegaOverC ^ 2 < mode.kParallel ^ 2 := by
    nlinarith
  linarith

/-- A positive effective mass term makes the supplied dispersion interval positive. -/
theorem gr24DispersionInterval_pos_of_mass
    (mode : Gr24DispersionParameters)
    (massSquared : ℝ)
    (massSquared_pos : 0 < massSquared)
    (dispersion : mode.omegaOverC ^ 2 =
      mode.kParallel ^ 2 + mode.kzReal ^ 2 + massSquared) :
    0 < gr24DispersionInterval mode := by
  unfold gr24DispersionInterval
  linarith

/-! ### WS-1: Dimensioned Four-Vector, Hermitian Pauli Spinor Map, and Lorentz Boost Invariance -/

/-- SI-dimensioned wavevector `(f / c, kx, ky, kz)` in cycles per metre (`m⁻¹`). -/
structure DimensionedWavevector where
  frequency : Signals.Units.Frequency
  speedOfLight : Signals.Units.Speed
  frequency_pos : 0 < frequency.hz
  speedOfLight_pos : 0 < speedOfLight.metersPerSecond
  kx : ℝ
  ky : ℝ
  kz : ℝ

/-- Convert a dimensioned wavevector into a `Signals.Proca.FourVector` with signature `(+,-,-,-)`. -/
def DimensionedWavevector.toFourVector (w : DimensionedWavevector) : Signals.Proca.FourVector :=
  { time := w.frequency.hz / w.speedOfLight.metersPerSecond
    x := w.kx
    y := w.ky
    z := w.kz }

/-- Determinant of the Hermitian `2 × 2` Pauli spinor matrix
`K(k) = [[k0 + kz, kx - i ky], [kx + i ky, k0 - kz]]`. -/
def pauliSpinorDet (k : Signals.Proca.FourVector) : ℝ :=
  (k.time + k.z) * (k.time - k.z) - (k.x ^ 2 + k.y ^ 2)

/-- The Pauli spinor map preserves the `(+,-,-,-)` Minkowski quadratic form exactly. -/
theorem pauliSpinorDet_eq_minkowskiDot (k : Signals.Proca.FourVector) :
    pauliSpinorDet k = Signals.Proca.minkowskiDot k k := by
  unfold pauliSpinorDet Signals.Proca.minkowskiDot
  ring

/-- A Lorentz boost along the `z`-axis parameterized by `(cosh η, sinh η)` with `c² - s² = 1`. -/
def lorentzBoostZ (coshEta sinhEta : ℝ) (k : Signals.Proca.FourVector) :
    Signals.Proca.FourVector :=
  { time := coshEta * k.time + sinhEta * k.z
    x := k.x
    y := k.y
    z := sinhEta * k.time + coshEta * k.z }

/-- The Pauli spinor determinant (and hence dispersion sign sector) is Lorentz-boost invariant. -/
theorem pauliSpinorDet_lorentzBoostZ
    (coshEta sinhEta : ℝ) (h_hyper : coshEta ^ 2 - sinhEta ^ 2 = 1)
    (k : Signals.Proca.FourVector) :
    pauliSpinorDet (lorentzBoostZ coshEta sinhEta k) = pauliSpinorDet k := by
  unfold pauliSpinorDet lorentzBoostZ
  calc
    (coshEta * k.time + sinhEta * k.z + (sinhEta * k.time + coshEta * k.z)) *
        (coshEta * k.time + sinhEta * k.z - (sinhEta * k.time + coshEta * k.z)) -
        (k.x ^ 2 + k.y ^ 2)
        = (coshEta ^ 2 - sinhEta ^ 2) * (k.time ^ 2 - k.z ^ 2) - (k.x ^ 2 + k.y ^ 2) := by
          ring
    _ = 1 * (k.time ^ 2 - k.z ^ 2) - (k.x ^ 2 + k.y ^ 2) := by rw [h_hyper]
    _ = (k.time + k.z) * (k.time - k.z) - (k.x ^ 2 + k.y ^ 2) := by ring

/-- Exact equivalence between the dimensioned `(+,-,-,-)` Minkowski form and `gr24DispersionInterval`
in the `(kx, kz)` incidence plane (`ky = 0`). -/
theorem dimensionedWavevector_minkowski_eq_dispersionInterval
    (w : DimensionedWavevector) (h_planar : w.ky = 0) :
    pauliSpinorDet w.toFourVector =
      gr24DispersionInterval ⟨w.frequency.hz / w.speedOfLight.metersPerSecond, w.kx, w.kz⟩ := by
  unfold pauliSpinorDet DimensionedWavevector.toFourVector gr24DispersionInterval
  rw [h_planar]
  ring

/-- A purely longitudinal `Signals.Proca.Mode` (`k_⊥ = 0`) maps to a strictly timelike Pauli spinor
whose determinant equals the squared Proca mass. -/
theorem procaMode_pauliSpinorDet_eq_mass_sq
    {model : Signals.Proca.Model} (mode : Signals.Proca.Mode model)
    (h_no_transverse : mode.transverseWaveNumber = 0) :
    pauliSpinorDet mode.momentum = model.mass ^ 2 ∧ 0 < pauliSpinorDet mode.momentum := by
  have h_disp := mode.dispersion
  rw [h_no_transverse] at h_disp
  have h_det : pauliSpinorDet mode.momentum = model.mass ^ 2 := by
    unfold pauliSpinorDet Signals.Proca.Mode.momentum
    nlinarith
  exact ⟨h_det, by rw [h_det]; exact sq_pos_of_pos model.mass_pos⟩

/-! ### WS-4: PSD-Verified Finite Slavnov–Gram DPP Kernel & Log-Det Identities -/

/-- Determinant of a regularized `2 × 2` symmetric Gram matrix
`G_ε = [[a + ε, c], [c, b + ε]]` where `a = ‖u‖²`, `b = ‖v‖²`, `c = ⟨u, v⟩`. -/
def gramDet2Reg (a b c eps : ℝ) : ℝ :=
  (a + eps) * (b + eps) - c ^ 2

/-- Whenever Cauchy–Schwarz (`c² ≤ a·b`) holds with `a, b ≥ 0` and regularization `ε > 0`,
the regularized `2 × 2` Gram determinant is strictly positive (`G_ε ≻ 0`). -/
theorem gramDet2Reg_pos
    (a b c eps : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (h_cs : c ^ 2 ≤ a * b) (heps : 0 < eps) :
    0 < gramDet2Reg a b c eps := by
  unfold gramDet2Reg
  nlinarith

/-- Identical candidates (`a = b = c`) collapse the unregularized Gram determinant to zero
(Pauli / DPP repulsion null). -/
theorem gramDet2_duplicate_zero (a : ℝ) : gramDet2Reg a a a 0 = 0 := by
  unfold gramDet2Reg
  ring

/-- Exact `2 × 2` inverse entries for `G_ε` and verification `G_ε · G_ε⁻¹ = I_2`,
establishing the exact matrix factor of `∇_G log det(G_ε) = G_ε⁻¹`. -/
theorem gram2Reg_inverse_identities
    (a b c eps : ℝ) (hdet : gramDet2Reg a b c eps ≠ 0) :
    let d := gramDet2Reg a b c eps
    let inv00 := (b + eps) / d
    let inv01 := -c / d
    let inv10 := -c / d
    let inv11 := (a + eps) / d
    (a + eps) * inv00 + c * inv10 = 1 ∧
      (a + eps) * inv01 + c * inv11 = 0 ∧
      c * inv00 + (b + eps) * inv10 = 0 ∧
      c * inv01 + (b + eps) * inv11 = 1 := by
  dsimp only
  unfold gramDet2Reg at hdet ⊢
  refine ⟨?_, ?_, ?_, ?_⟩ <;> field_simp [hdet] <;> ring

/-! ### WS-5: VRC-3 Pair-Excitation Regularity, 1/4 QNG Step, and Exact 2-State NOCI Lowering -/

/-- Homogeneous VRC pair-excitation amplitude `V / (Δε² + V²)` avoiding the perturbative
`1 / Δε` pole at HOMO–LUMO degeneracy `Δε = 0`. -/
def vrcPairExcitationSmooth (deltaEps coupling : ℝ) : ℝ :=
  coupling / (deltaEps ^ 2 + coupling ^ 2)

/-- At exact degeneracy `Δε = 0` with nonzero coupling `V ≠ 0`, the VRC pair amplitude
evaluates smoothly to `1 / V` without division by zero. -/
theorem vrcPairExcitationSmooth_at_degeneracy (coupling : ℝ) (hc : coupling ≠ 0) :
    vrcPairExcitationSmooth 0 coupling = 1 / coupling := by
  unfold vrcPairExcitationSmooth
  field_simp [hc]
  ring

/-- Quantum Natural Gradient step using the QFIM `F = 4 g_FS` equals `1 / 4` of the
Fubini–Study Riemannian gradient step. -/
def qngStepFromQfim (grad fubiniStudy : ℝ) : ℝ :=
  grad / (4 * fubiniStudy)

theorem qngStepFromQfim_eq_quarter_fubiniStudy (grad fubiniStudy : ℝ) (hg : fubiniStudy ≠ 0) :
    qngStepFromQfim grad fubiniStudy = (1 / 4) * (grad / fubiniStudy) := by
  unfold qngStepFromQfim
  field_simp [hg]

/-- Symmetric Ritz eigenvalue `(E_BS + h) / (1 + s)` of the `2 × 2` symmetric NOCI
generalized eigenproblem `H c = E S c` with `H_00 = H_11 = E_BS`, `H_01 = h`, `S_01 = s`. -/
def nociSymmetricEnergy (eBS coupling overlap : ℝ) : ℝ :=
  (eBS + coupling) / (1 + overlap)

/-- Antisymmetric Ritz eigenvalue `(E_BS - h) / (1 - s)` of the `2 × 2` symmetric NOCI
generalized eigenproblem `H c = E S c`. -/
def nociAntisymmetricEnergy (eBS coupling overlap : ℝ) : ℝ :=
  (eBS - coupling) / (1 - overlap)

/-- Exact variational lowering for `2 × 2` symmetric NOCI: whenever the overlap matrix is
strictly positive definite (`-1 < s < 1`) and the secular coupling is non-trivial
(`h ≠ E_BS · s`), the lower Ritz eigenvalue strictly lowers the broken-symmetry energy `E_BS`. -/
theorem nociTwoState_variational_lowering
    (eBS coupling overlap : ℝ)
    (hs_gt : -1 < overlap) (hs_lt : overlap < 1)
    (h_nontrivial : coupling ≠ eBS * overlap) :
    min (nociSymmetricEnergy eBS coupling overlap)
      (nociAntisymmetricEnergy eBS coupling overlap) < eBS := by
  have h_pos_plus : 0 < 1 + overlap := by linarith
  have h_pos_minus : 0 < 1 - overlap := by linarith
  rcases lt_or_gt_of_ne h_nontrivial with h_lt | h_gt
  · apply lt_of_le_of_lt (min_le_left _ _)
    unfold nociSymmetricEnergy
    rw [div_lt_iff₀ h_pos_plus]
    nlinarith
  · apply lt_of_le_of_lt (min_le_right _ _)
    unfold nociAntisymmetricEnergy
    rw [div_lt_iff₀ h_pos_minus]
    nlinarith

/-! ### WS-9: Isolated Finite-Graph Ihara–Selberg Ramanujan Critical-Circle Equivalence

This section formalizes **only** the established finite-graph Ramanujan quadratic-factor
property of the Bass–Ihara graph zeta function `ζ_G(u)⁻¹ = (1 - u²)^(r - 1) det(I - u A + u² q I)`
on a finite `(q + 1)`-regular graph. It makes **no claim** about the Riemann zeta function `ζ(s)`
or the Riemann Hypothesis.
-/

/-- Discriminant `λ² - 4q` of one adjacency-eigenvalue quadratic factor `1 - λ u + q u²`
in the Bass–Ihara determinant of a finite `(q + 1)`-regular graph. -/
def iharaQuadraticDiscriminant (lambda q : ℝ) : ℝ :=
  lambda ^ 2 - 4 * q

/-- For a non-trivial eigenvalue `λ` satisfying the Ramanujan bound `λ² ≤ 4q` with `q > 0`,
the complex-conjugate roots `u = (λ ± i √(4q - λ²)) / (2q)` of `1 - λ u + q u² = 0` satisfy
`|u|² = u_re² + u_im² = 1 / q` (the Ramanujan critical circle). -/
theorem ihara_ramanujan_critical_circle_modulus_sq
    (lambda q : ℝ) (hq : 0 < q) (h_ramanujan : lambda ^ 2 ≤ 4 * q) :
    let u_re := lambda / (2 * q)
    let u_im_sq := (4 * q - lambda ^ 2) / (4 * q ^ 2)
    0 ≤ u_im_sq ∧ u_re ^ 2 + u_im_sq = 1 / q := by
  dsimp only
  have h_nonneg : 0 ≤ 4 * q - lambda ^ 2 := by linarith
  have h_den_pos : 0 < 4 * q ^ 2 := by positivity
  refine ⟨div_nonneg h_nonneg (le_of_lt h_den_pos), ?_⟩
  have hq_ne : q ≠ 0 := ne_of_gt hq
  field_simp [hq_ne]
  ring

/-- Concrete check figures for the 10-vertex 3-regular Petersen graph (`q = 2`, non-trivial
adjacency eigenvalues `λ ∈ {1, -2}`): both satisfy the Ramanujan bound `λ² ≤ 8 = 4q`. -/
theorem petersen_graph_ramanujan_checkFigures :
    iharaQuadraticDiscriminant 1 2 ≤ 0 ∧ iharaQuadraticDiscriminant (-2) 2 ≤ 0 := by
  norm_num [iharaQuadraticDiscriminant]

end

end Signals.GrassmannianEBR
