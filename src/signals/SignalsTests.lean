import Mathlib.Tactic
import Signals

namespace SignalsTests

open Signals.Fabrication
open Signals.Geometry
open Signals.IQ
open Signals.Proca
open Signals.Sampling

example : (⟨0, 0⟩ : Sample).magnitude = 0 := by
  rw [Sample.zero_magnitude_iff]
  norm_num

example : (⟨3, 4⟩ : Sample).magnitude = 5 := by
  rw [Sample.magnitude, Sample.normSq_eq]
  norm_num

example : (⟨-1, 0⟩ : Sample).phase = Real.pi := by
  rw [Sample.phase]
  change Complex.arg ({ re := -1, im := 0 } : ℂ) = Real.pi
  have negative_one : ({ re := (-1 : ℝ), im := 0 } : ℂ) = (-1 : ℂ) := by
    apply Complex.ext <;> norm_num
  rw [negative_one]
  exact Complex.arg_neg_one

example (convention : Convention) (sample : Sample) :
    (convention.orient sample).magnitude = sample.magnitude := by
  exact convention.orient_magnitude sample

example (frequency phase : ℝ) (rate : SamplingRate) (aliasIndex : ℤ) (index : ℕ) :
    toneSample 1 (aliasedFrequency frequency rate aliasIndex) rate.hz phase index =
      toneSample 1 frequency rate.hz phase index := by
  exact toneSample_aliased 1 frequency phase rate aliasIndex index

example : ¬ (InBand ⟨1, by norm_num⟩ 1 ∧ InBand ⟨1, by norm_num⟩ 4) := by
  intro frequencies
  exact no_one_rate_alias (bandwidth := ⟨1, by norm_num⟩)
    (rate := ⟨3, by norm_num⟩) (by norm_num [NyquistCondition]) frequencies.1 frequencies.2
      (by norm_num)

def toyModel : Model :=
  { mass := 3
    mass_pos := by norm_num
    coupling := 1
    medium := { refractiveIndex := 1, refractiveIndex_pos := by norm_num }
    boundary :=
      { reflectionMagnitude := 1
        reflectionMagnitude_nonneg := by norm_num
        reflectionMagnitude_le_one := by norm_num } }

def toyMode : Mode toyModel :=
  { frequency := 5
    frequency_pos := by norm_num
    transverseWaveNumber := 0
    longitudinalWaveNumber := 4
    dispersion := by norm_num [toyModel] }

example : minkowskiDot toyMode.momentum toyMode.longitudinalPolarization = 0 := by
  exact Mode.momentum_dot_longitudinalPolarization_eq_zero toyMode

def toyMeasurement : PhaseHeightMeasurement :=
  { waveNumber := 2
    waveNumber_ne_zero := by norm_num
    height := 3
    unwrappedPhase := 12
    roundTripPhase := by norm_num }

example : toyMeasurement.height =
  Signals.IQ.heightFromPhase toyMeasurement.waveNumber toyMeasurement.unwrappedPhase := by
  exact toyMeasurement.height_eq_heightFromPhase

example (matrix : Matrix2x4) :
    minor matrix 0 1 * minor matrix 2 3 -
      minor matrix 0 2 * minor matrix 1 3 +
      minor matrix 0 3 * minor matrix 1 2 = 0 := by
  exact pluecker_relation matrix

def toyCalibration : Calibration :=
  { expected := 10
    measured := 10.1
    tolerance := 0.1
    tolerance_nonneg := by norm_num
    errorBound := by norm_num }

example : |toyCalibration.measured - toyCalibration.expected| ≤ toyCalibration.tolerance := by
  exact toyCalibration.error_le_tolerance

def toyBudget : ThermalBudget :=
  { peakTemperature := 400
    limitTemperature := 450
    safe := by norm_num }

example : toyBudget.peakTemperature ≤ toyBudget.limitTemperature := by
  exact toyBudget.peak_le_limit

end SignalsTests