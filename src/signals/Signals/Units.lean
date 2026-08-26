import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace Signals.Units

/-- A frequency measured in hertz. -/
structure Frequency where
  hz : ℝ

/-- A length measured in metres. -/
structure Length where
  meters : ℝ

/-- A power measured in watts. -/
structure Power where
  watts : ℝ

/-- A peak electric-field amplitude measured in volts per metre. -/
structure ElectricFieldAmplitude where
  voltsPerMeter : ℝ

/-- Plane-wave irradiance measured in watts per square metre. -/
structure Irradiance where
  wattsPerSquareMeter : ℝ

/-- The vacuum speed of light used by the irradiance calibration model. -/
def vacuumSpeedOfLight : ℝ := 299792458

/-- The vacuum permittivity used by the irradiance calibration model. -/
noncomputable def vacuumPermittivity : ℝ := 8.8541878128 * 10 ^ (-12 : ℤ)

/-- Irradiance of a plane wave from its peak electric-field amplitude. -/
noncomputable def planeWaveIrradiance (field : ElectricFieldAmplitude) : Irradiance :=
  { wattsPerSquareMeter :=
      (1 / 2 : ℝ) * vacuumSpeedOfLight * vacuumPermittivity *
        field.voltsPerMeter ^ 2 }

/-- Convert watts per square metre to watts per square centimetre. -/
noncomputable def wattsPerSquareCentimeter (irradiance : Irradiance) : ℝ :=
  irradiance.wattsPerSquareMeter / 10000

/-- Construct a frequency from a value expressed in gigahertz. -/
def gigahertz (value : ℝ) : Frequency :=
  { hz := value * 10 ^ 9 }

/-- The representation of 400 GHz in hertz. -/
lemma gigahertz_400_hz : (gigahertz 400).hz = 400 * 10 ^ 9 := by
  rfl

/-- A 1e6 V/m peak field corresponds to about 1.33e9 W/m² in vacuum. -/
lemma irradiance_one_megavolt_per_meter_bounds :
    1.3 * 10 ^ 9 <
        (planeWaveIrradiance ⟨10 ^ 6⟩).wattsPerSquareMeter ∧
      (planeWaveIrradiance ⟨10 ^ 6⟩).wattsPerSquareMeter < 1.4 * 10 ^ 9 := by
  have hten : (10 : ℝ) ^ 12 = 1000000000000 := by norm_num
  norm_num [planeWaveIrradiance, vacuumSpeedOfLight, vacuumPermittivity, zpow_neg,
    hten]

/-- The same field is about 132.7 kW/cm², not 1.3--2.5 kW/cm². -/
lemma irradiance_one_megavolt_per_meter_watts_per_square_centimeter_bounds :
    132000 < wattsPerSquareCentimeter (planeWaveIrradiance ⟨10 ^ 6⟩) ∧
      wattsPerSquareCentimeter (planeWaveIrradiance ⟨10 ^ 6⟩) < 134000 := by
  have hten : (10 : ℝ) ^ 12 = 1000000000000 := by norm_num
  norm_num [wattsPerSquareCentimeter, planeWaveIrradiance, vacuumSpeedOfLight,
    vacuumPermittivity, zpow_neg, hten]

end Signals.Units
