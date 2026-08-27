import Mathlib.Data.Real.Basic
import Mathlib.Tactic
import Signals.Propagation
import Signals.Units

namespace Signals.MHD

open Signals.Propagation
open Signals.Units

/-- The dimensionless electrical loading factor in a Faraday MHD channel. -/
def loadingFactor (load : BoundedFactor) : ℝ :=
  load.value * (1 - load.value)

/-- A bounded load has a nonnegative Faraday extraction factor. -/
lemma loadingFactor_nonnegative (load : BoundedFactor) :
    0 ≤ loadingFactor load := by
  unfold loadingFactor
  exact mul_nonneg load.nonnegative (sub_nonneg.mpr load.le_one)

/-- The Faraday loading factor is maximized at matched loading. -/
lemma loadingFactor_le_quarter (load : BoundedFactor) :
    loadingFactor load ≤ 1 / 4 := by
  unfold loadingFactor
  nlinarith [sq_nonneg (load.value - (1 / 2 : ℝ))]

/-- The matched-load value of the Faraday extraction factor. -/
lemma loadingFactor_half :
    loadingFactor { value := (1 / 2 : ℝ), nonnegative := by norm_num, le_one := by norm_num } =
      1 / 4 := by
  norm_num [loadingFactor]

/-- A classical Faraday MHD power density before the channel volume is applied.

The expression has the SI dimensions of watts per cubic metre when conductivity,
velocity, and magnetic flux density are supplied in their corresponding units.
The loading factor is explicit so impedance matching remains visible. -/
def idealFaradayPowerDensity (conductivity : ElectricalConductivity)
    (velocity : Speed) (magneticFluxDensity : MagneticFluxDensity)
    (load : BoundedFactor) : PowerDensity :=
  { wattsPerCubicMeter :=
      conductivity.siemensPerMeter * velocity.metersPerSecond ^ 2 *
        magneticFluxDensity.tesla ^ 2 * loadingFactor load }

/-- The unloaded Faraday power-density scale without the electrical load factor. -/
def baseFaradayPowerDensity (conductivity : ElectricalConductivity)
    (velocity : Speed) (magneticFluxDensity : MagneticFluxDensity) : PowerDensity :=
  { wattsPerCubicMeter :=
      conductivity.siemensPerMeter * velocity.metersPerSecond ^ 2 *
        magneticFluxDensity.tesla ^ 2 }

/-- The ideal Faraday power density is nonnegative for passive inputs. -/
lemma idealFaradayPowerDensity_nonnegative
    (conductivity : ElectricalConductivity)
    (conductivity_nonnegative : 0 ≤ conductivity.siemensPerMeter)
  (velocity : Speed) (_velocity_nonnegative : 0 ≤ velocity.metersPerSecond)
    (magneticFluxDensity : MagneticFluxDensity)
  (_magneticFluxDensity_nonnegative : 0 ≤ magneticFluxDensity.tesla)
    (load : BoundedFactor) :
    0 ≤ (idealFaradayPowerDensity conductivity velocity magneticFluxDensity load).wattsPerCubicMeter := by
  unfold idealFaradayPowerDensity
  exact mul_nonneg
    (mul_nonneg
      (mul_nonneg conductivity_nonnegative (sq_nonneg _))
      (sq_nonneg _))
    (loadingFactor_nonnegative load)

/-- The Faraday power density is bounded by one quarter of its unloaded scale. -/
lemma idealFaradayPowerDensity_le_quarter_base
    (conductivity : ElectricalConductivity)
    (conductivity_nonnegative : 0 ≤ conductivity.siemensPerMeter)
    (velocity : Speed) (magneticFluxDensity : MagneticFluxDensity)
  (_magneticFluxDensity_nonnegative : 0 ≤ magneticFluxDensity.tesla)
    (load : BoundedFactor) :
    (idealFaradayPowerDensity conductivity velocity magneticFluxDensity load).wattsPerCubicMeter ≤
      (baseFaradayPowerDensity conductivity velocity magneticFluxDensity).wattsPerCubicMeter *
        (1 / 4 : ℝ) := by
  unfold idealFaradayPowerDensity baseFaradayPowerDensity
  have base_nonnegative :
      0 ≤ conductivity.siemensPerMeter * velocity.metersPerSecond ^ 2 *
        magneticFluxDensity.tesla ^ 2 := by
    exact mul_nonneg
      (mul_nonneg conductivity_nonnegative (sq_nonneg _))
      (sq_nonneg _)
  calc
    conductivity.siemensPerMeter * velocity.metersPerSecond ^ 2 *
          magneticFluxDensity.tesla ^ 2 * loadingFactor load =
        (conductivity.siemensPerMeter * velocity.metersPerSecond ^ 2 *
          magneticFluxDensity.tesla ^ 2) * loadingFactor load := by ring
    _ ≤ (conductivity.siemensPerMeter * velocity.metersPerSecond ^ 2 *
          magneticFluxDensity.tesla ^ 2) * (1 / 4 : ℝ) :=
      mul_le_mul_of_nonneg_left (loadingFactor_le_quarter load) base_nonnegative

/-- A finite Faraday channel with conductive plasma and explicit volume output. -/
structure FaradayChannel where
  conductivity : ElectricalConductivity
  conductivity_nonnegative : 0 ≤ conductivity.siemensPerMeter
  velocity : Speed
  velocity_nonnegative : 0 ≤ velocity.metersPerSecond
  magneticFluxDensity : MagneticFluxDensity
  magneticFluxDensity_nonnegative : 0 ≤ magneticFluxDensity.tesla
  load : BoundedFactor
  channelVolume : Volume
  channelVolume_pos : 0 < channelVolume.cubicMeters
  powerDensity : PowerDensity
  powerDensityLaw : powerDensity.wattsPerCubicMeter =
    (idealFaradayPowerDensity conductivity velocity magneticFluxDensity load).wattsPerCubicMeter
  extractedPower : Power
  extractedPower_nonnegative : 0 ≤ extractedPower.watts
  extractedPowerLaw : extractedPower.watts =
    powerDensity.wattsPerCubicMeter * channelVolume.cubicMeters

/-- The Faraday channel power density is nonnegative. -/
lemma FaradayChannel.power_density_nonnegative (channel : FaradayChannel) :
    0 ≤ channel.powerDensity.wattsPerCubicMeter := by
  rw [channel.powerDensityLaw]
  exact idealFaradayPowerDensity_nonnegative channel.conductivity
    channel.conductivity_nonnegative channel.velocity channel.velocity_nonnegative
    channel.magneticFluxDensity channel.magneticFluxDensity_nonnegative channel.load

/-- The integrated Faraday channel output is nonnegative. -/
lemma FaradayChannel.extracted_power_nonnegative (channel : FaradayChannel) :
    0 ≤ channel.extractedPower.watts := by
  rw [channel.extractedPowerLaw]
  exact mul_nonneg channel.power_density_nonnegative channel.channelVolume_pos.le

/-- The loaded Faraday channel cannot exceed one quarter of its unloaded
power-density scale after volume integration. -/
lemma FaradayChannel.power_density_le_quarter_base (channel : FaradayChannel) :
    channel.powerDensity.wattsPerCubicMeter ≤
      (baseFaradayPowerDensity channel.conductivity channel.velocity
        channel.magneticFluxDensity).wattsPerCubicMeter * (1 / 4 : ℝ) := by
  rw [channel.powerDensityLaw]
  exact idealFaradayPowerDensity_le_quarter_base channel.conductivity
    channel.conductivity_nonnegative channel.velocity
    channel.magneticFluxDensity channel.magneticFluxDensity_nonnegative channel.load

/-- Auxiliary operating powers that are not part of the Argon stream's motive
kinetic power. These include pump, ionization, magnetic-field, and cooling
requirements and must be included in a plant-level efficiency calculation. -/
structure MHDOperatingCosts where
  pumpPower : Power
  pumpPower_nonnegative : 0 ≤ pumpPower.watts
  ionizationPower : Power
  ionizationPower_nonnegative : 0 ≤ ionizationPower.watts
  fieldPower : Power
  fieldPower_nonnegative : 0 ≤ fieldPower.watts
  coolingPower : Power
  coolingPower_nonnegative : 0 ≤ coolingPower.watts

/-- The declared auxiliary MHD operating powers. -/
def MHDOperatingCosts.auxiliaryPower (costs : MHDOperatingCosts) : Power :=
  { watts := costs.pumpPower.watts + costs.ionizationPower.watts +
      costs.fieldPower.watts + costs.coolingPower.watts }

/-- Auxiliary MHD operating power is nonnegative. -/
lemma MHDOperatingCosts.auxiliary_power_nonnegative (costs : MHDOperatingCosts) :
    0 ≤ costs.auxiliaryPower.watts := by
  unfold MHDOperatingCosts.auxiliaryPower
  exact add_nonneg
    (add_nonneg
      (add_nonneg costs.pumpPower_nonnegative costs.ionizationPower_nonnegative)
      costs.fieldPower_nonnegative)
    costs.coolingPower_nonnegative

/-- A power balance separating control power, motive power, output, and losses. -/
structure MHDPowerAccounting where
  controlPower : Power
  controlPower_nonnegative : 0 ≤ controlPower.watts
  motivePower : Power
  motivePower_nonnegative : 0 ≤ motivePower.watts
  electricalOutputPower : Power
  electricalOutputPower_nonnegative : 0 ≤ electricalOutputPower.watts
  lossPower : Power
  lossPower_nonnegative : 0 ≤ lossPower.watts
  energyBalance : electricalOutputPower.watts + lossPower.watts =
    controlPower.watts + motivePower.watts

/-- The total physical input includes both control and motive power. -/
def MHDPowerAccounting.totalInputPower (accounting : MHDPowerAccounting) : Power :=
  { watts := accounting.controlPower.watts + accounting.motivePower.watts }

/-- Total MHD input power is nonnegative. -/
lemma MHDPowerAccounting.total_input_nonnegative (accounting : MHDPowerAccounting) :
    0 ≤ accounting.totalInputPower.watts := by
  unfold MHDPowerAccounting.totalInputPower
  exact add_nonneg accounting.controlPower_nonnegative accounting.motivePower_nonnegative

/-- Passive MHD conversion cannot output more power than total physical input. -/
lemma MHDPowerAccounting.output_le_total_input (accounting : MHDPowerAccounting) :
    accounting.electricalOutputPower.watts ≤ accounting.totalInputPower.watts := by
  unfold MHDPowerAccounting.totalInputPower
  linarith [accounting.energyBalance, accounting.lossPower_nonnegative]

/-- Total plant input including auxiliary pump, ionization, field, and cooling
power. -/
def MHDPowerAccounting.fullInputPower
    (accounting : MHDPowerAccounting) (costs : MHDOperatingCosts) : Power :=
  { watts := accounting.totalInputPower.watts + costs.auxiliaryPower.watts }

/-- Passive MHD output cannot exceed total input including operating costs. -/
lemma MHDPowerAccounting.output_le_full_input
    (accounting : MHDPowerAccounting) (costs : MHDOperatingCosts) :
    accounting.electricalOutputPower.watts ≤
      (accounting.fullInputPower costs).watts := by
  unfold MHDPowerAccounting.fullInputPower
  exact le_trans accounting.output_le_total_input
    (le_add_of_nonneg_right costs.auxiliary_power_nonnegative)

/-- Plant-level efficiency including all declared auxiliary operating powers. -/
noncomputable def MHDPowerAccounting.fullEfficiency
    (accounting : MHDPowerAccounting) (costs : MHDOperatingCosts) : ℝ :=
  accounting.electricalOutputPower.watts / (accounting.fullInputPower costs).watts

/-- A positive-input passive MHD plant has full efficiency at most one. -/
lemma MHDPowerAccounting.full_efficiency_le_one
    (accounting : MHDPowerAccounting) (costs : MHDOperatingCosts)
    (fullInput_positive : 0 < (accounting.fullInputPower costs).watts) :
    accounting.fullEfficiency costs ≤ 1 := by
  unfold MHDPowerAccounting.fullEfficiency
  apply (div_le_iff₀ fullInput_positive).2
  simpa using accounting.output_le_full_input costs

/-- The ordinary conversion efficiency, defined only as a ratio of powers. -/
noncomputable def MHDPowerAccounting.efficiency (accounting : MHDPowerAccounting) : ℝ :=
  accounting.electricalOutputPower.watts / accounting.totalInputPower.watts

/-- A positive-input passive MHD balance has efficiency at most one. -/
lemma MHDPowerAccounting.efficiency_le_one
    (accounting : MHDPowerAccounting)
    (totalInput_positive : 0 < accounting.totalInputPower.watts) :
    accounting.efficiency ≤ 1 := by
  unfold MHDPowerAccounting.efficiency
  apply (div_le_iff₀ totalInput_positive).2
  simpa using accounting.output_le_total_input

/-- A positive-input passive MHD balance has nonnegative efficiency. -/
lemma MHDPowerAccounting.efficiency_nonnegative
    (accounting : MHDPowerAccounting)
    (totalInput_positive : 0 < accounting.totalInputPower.watts) :
    0 ≤ accounting.efficiency := by
  unfold MHDPowerAccounting.efficiency
  exact div_nonneg accounting.electricalOutputPower_nonnegative totalInput_positive.le

/-- A conductive argon stream with explicit ionization and flow data. -/
structure ConductiveArgonFlow where
  massFlow : MassFlowRate
  massFlow_nonnegative : 0 ≤ massFlow.kilogramsPerSecond
  velocity : Speed
  velocity_nonnegative : 0 ≤ velocity.metersPerSecond
  ionizationFraction : BoundedFactor
  ionizationFraction_positive : 0 < ionizationFraction.value
  conductivity : ElectricalConductivity
  conductivity_positive : 0 < conductivity.siemensPerMeter

/-- Classical kinetic power carried by a mass flow at a given speed. -/
noncomputable def argonKineticPower (flow : ConductiveArgonFlow) : Power :=
  { watts := (1 / 2 : ℝ) * flow.massFlow.kilogramsPerSecond *
      flow.velocity.metersPerSecond ^ 2 }

/-- Kinetic power of a conductive argon flow is nonnegative. -/
lemma argonKineticPower_nonnegative (flow : ConductiveArgonFlow) :
    0 ≤ (argonKineticPower flow).watts := by
  unfold argonKineticPower
  exact mul_nonneg
    (mul_nonneg (by norm_num) flow.massFlow_nonnegative)
    (sq_nonneg _)

/-- A classical Argon MHD plant ties channel output to a full power balance.

The motive input is the kinetic power supplied to the channel. Control power
such as field excitation or a phase modulator is recorded separately and is not
silently treated as a substitute for motive energy. -/
structure ArgonMHDPlant where
  argon : ConductiveArgonFlow
  channel : FaradayChannel
  accounting : MHDPowerAccounting
  kineticInputPower : Power
  kineticInputPowerLaw : kineticInputPower.watts =
    (argonKineticPower argon).watts
  motivePowerLaw : accounting.motivePower.watts = kineticInputPower.watts
  outputPowerLaw : accounting.electricalOutputPower.watts = channel.extractedPower.watts

/-- The Argon MHD plant's motive input is its classical flow kinetic power. -/
lemma ArgonMHDPlant.motive_power_eq_kinetic (plant : ArgonMHDPlant) :
    plant.accounting.motivePower.watts = (argonKineticPower plant.argon).watts := by
  rw [plant.motivePowerLaw, plant.kineticInputPowerLaw]

/-- The Argon MHD plant cannot output more than motive plus control input. -/
lemma ArgonMHDPlant.output_le_declared_input (plant : ArgonMHDPlant) :
    plant.accounting.electricalOutputPower.watts ≤
      plant.accounting.controlPower.watts +
        (argonKineticPower plant.argon).watts := by
  rw [← plant.motive_power_eq_kinetic]
  exact plant.accounting.output_le_total_input

/-- A closed-loop Argon MHD balance with no hidden vacuum-energy source. -/
structure ClosedLoopArgonMHD where
  plant : ArgonMHDPlant
  controlPower : Power
  controlPower_nonnegative : 0 ≤ controlPower.watts
  externalMotivePower : Power
  externalMotivePower_nonnegative : 0 ≤ externalMotivePower.watts
  exportedPower : Power
  exportedPower_nonnegative : 0 ≤ exportedPower.watts
  loopLossPower : Power
  loopLossPower_nonnegative : 0 ≤ loopLossPower.watts
  controlPowerLaw : controlPower.watts = plant.accounting.controlPower.watts
  externalMotivePowerLaw : externalMotivePower.watts = plant.accounting.motivePower.watts
  exportedPowerLaw : exportedPower.watts = plant.accounting.electricalOutputPower.watts
  closedLoopEnergyBalance : exportedPower.watts + loopLossPower.watts =
    controlPower.watts + externalMotivePower.watts

/-- A closed-loop plant cannot deliver more exported power than its declared
control and motive inputs. -/
lemma ClosedLoopArgonMHD.exported_le_declared_input
    (plant : ClosedLoopArgonMHD) :
    plant.exportedPower.watts ≤
      plant.controlPower.watts + plant.externalMotivePower.watts := by
  linarith [plant.closedLoopEnergyBalance, plant.loopLossPower_nonnegative]

/-- With zero control, zero motive input, and nonnegative loop losses, a closed
loop has zero electrical export. -/
lemma ClosedLoopArgonMHD.zero_export_of_zero_inputs
    (plant : ClosedLoopArgonMHD)
    (control_zero : plant.controlPower.watts = 0)
    (motive_zero : plant.externalMotivePower.watts = 0) :
    plant.exportedPower.watts = 0 := by
  linarith [plant.closedLoopEnergyBalance, plant.loopLossPower_nonnegative,
    plant.exportedPower_nonnegative]

/-- A control-only output ratio can exceed one only because motive input is
excluded from its denominator. It is not an energy efficiency. -/
noncomputable def controlOnlyRatio (outputPower controlPower : Power) : ℝ :=
  outputPower.watts / controlPower.watts

/-- A control-only ratio above a threshold is equivalent to output exceeding the
threshold times the omitted control denominator. -/
lemma controlOnlyRatio_gt_iff
    (outputPower controlPower : Power)
    (controlPower_positive : 0 < controlPower.watts)
    (threshold : ℝ) :
    controlOnlyRatio outputPower controlPower > threshold ↔
      threshold * controlPower.watts < outputPower.watts := by
  unfold controlOnlyRatio
  rw [gt_iff_lt, (lt_div_iff₀ controlPower_positive)]

end Signals.MHD
