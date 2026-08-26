import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace Signals.Fabrication

/-- A finite scalar field over a rectangular voxel grid. -/
structure VoxelField (width height depth : ℕ) where
  value : Fin width → Fin height → Fin depth → ℝ

/-- A programmable phase mask with a pointwise phase bound. -/
structure ActiveMask (width height : ℕ) where
  phase : Fin width → Fin height → ℝ
  phaseBound : ∀ x y, |phase x y| ≤ Real.pi

/-- A calibration result with an explicit absolute-error tolerance. -/
structure Calibration where
  expected : ℝ
  measured : ℝ
  tolerance : ℝ
  tolerance_nonneg : 0 ≤ tolerance
  errorBound : |measured - expected| ≤ tolerance

/-- The calibration error is bounded by the recorded tolerance. -/
lemma Calibration.error_le_tolerance (calibration : Calibration) :
    |calibration.measured - calibration.expected| ≤ calibration.tolerance :=
  calibration.errorBound

/-- A thermal execution budget with its safety condition recorded as data. -/
structure ThermalBudget where
  peakTemperature : ℝ
  limitTemperature : ℝ
  safe : peakTemperature ≤ limitTemperature

/-- A recorded thermal budget is safe by its explicit bound. -/
lemma ThermalBudget.peak_le_limit (budget : ThermalBudget) :
    budget.peakTemperature ≤ budget.limitTemperature :=
  budget.safe

/-- A rectangular height map for a wafer, ocean patch, or other surface. -/
structure HeightMap (width height : ℕ) where
  elevation : Fin width → Fin height → ℝ

/-- A height map lies in an engineering range when every pixel satisfies it. -/
def HeightMap.WithinBounds (map : HeightMap width height) (lower upper : ℝ) : Prop :=
  ∀ x y, lower ≤ map.elevation x y ∧ map.elevation x y ≤ upper

/-- A bounded height map has the advertised lower bound at every pixel. -/
lemma HeightMap.lower_bound {map : HeightMap width height} {lower upper : ℝ}
    (bounds : map.WithinBounds lower upper) (x : Fin width) (y : Fin height) :
  lower ≤ map.elevation x y :=
  (bounds x y).1

/-- A bounded height map has the advertised upper bound at every pixel. -/
lemma HeightMap.upper_bound {map : HeightMap width height} {lower upper : ℝ}
    (bounds : map.WithinBounds lower upper) (x : Fin width) (y : Fin height) :
  map.elevation x y ≤ upper :=
  (bounds x y).2

end Signals.Fabrication