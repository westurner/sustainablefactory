import Architect
import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Basic.Real.Basic
import Mathlib.LinearAlgebra.CrossProduct
import Mathlib.LinearAlgebra.Matrix.DotProduct
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Tactic
import Signals.Acoustics
import Signals.Applications
import Signals.Propagation
import Signals.Units

namespace Signals.MHD

open MeasureTheory Interval Matrix
open scoped Matrix
open Signals.Acoustics
open Signals.Applications
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

/-- Ionized Argon mass flow under the supplied bulk ionization fraction. -/
noncomputable def ConductiveArgonFlow.ionizedMassFlow
    (flow : ConductiveArgonFlow) : MassFlowRate :=
  { kilogramsPerSecond :=
      flow.massFlow.kilogramsPerSecond * flow.ionizationFraction.value }

/-- Ionized Argon mass flow is nonnegative. -/
lemma ConductiveArgonFlow.ionized_mass_flow_nonnegative
    (flow : ConductiveArgonFlow) :
    0 ≤ flow.ionizedMassFlow.kilogramsPerSecond := by
  unfold ConductiveArgonFlow.ionizedMassFlow
  exact mul_nonneg flow.massFlow_nonnegative flow.ionizationFraction.nonnegative

/-- A classical electron-cyclotron-resonance drive for Argon ionization.

The gyromagnetic ratio is an explicit calibration input so the model does not
silently identify an acoustic frequency with an electron-cyclotron frequency. -/
structure ElectronCyclotronResonance where
  driveFrequency : Frequency
  driveFrequency_pos : 0 < driveFrequency.hz
  magneticFluxDensity : MagneticFluxDensity
  magneticFluxDensity_pos : 0 < magneticFluxDensity.tesla
  electronGyromagneticRatioHzPerTesla : ℝ
  electronGyromagneticRatio_pos : 0 < electronGyromagneticRatioHzPerTesla
  sourcePower : Power
  sourcePower_nonnegative : 0 ≤ sourcePower.watts
  resonanceLaw : driveFrequency.hz =
    electronGyromagneticRatioHzPerTesla * magneticFluxDensity.tesla

/-- The ECR magnetic field is fixed by the selected drive frequency and the
supplied electron gyromagnetic ratio. -/
lemma ElectronCyclotronResonance.magneticFluxDensity_eq_frequency_div_ratio
    (drive : ElectronCyclotronResonance) :
    drive.magneticFluxDensity.tesla =
      drive.driveFrequency.hz / drive.electronGyromagneticRatioHzPerTesla := by
  apply (eq_div_iff (ne_of_gt drive.electronGyromagneticRatio_pos)).2
  calc
    drive.magneticFluxDensity.tesla * drive.electronGyromagneticRatioHzPerTesla =
        drive.electronGyromagneticRatioHzPerTesla *
          drive.magneticFluxDensity.tesla := by ring
    _ = drive.driveFrequency.hz := drive.resonanceLaw.symm

/-- An ordinary longitudinal acoustic drive coupled through a measured passive
transfer path. The dispersion law is the classical relation `f * λ = cₛ`; no
massive-mode or nonclassical propagation assumption is included. -/
structure LongitudinalAcousticDrive where
  transfer : UltrasonicTransfer
  wavelength : Length
  wavelength_pos : 0 < wavelength.meters
  dispersionLaw :
    transfer.wave.frequencyHz * wavelength.meters = transfer.wave.medium.soundSpeed

/-- The wavelength selected by an ordinary nondispersive longitudinal mode. -/
lemma LongitudinalAcousticDrive.wavelength_eq_soundSpeed_div_frequency
    (drive : LongitudinalAcousticDrive) :
    drive.wavelength.meters =
      drive.transfer.wave.medium.soundSpeed / drive.transfer.wave.frequencyHz := by
  apply (eq_div_iff (ne_of_gt drive.transfer.wave.frequency_positive)).2
  calc
    drive.wavelength.meters * drive.transfer.wave.frequencyHz =
        drive.transfer.wave.frequencyHz * drive.wavelength.meters := by ring
    _ = drive.transfer.wave.medium.soundSpeed := drive.dispersionLaw

/-- Acoustic power deposited after the declared passive transfer factors. -/
noncomputable def LongitudinalAcousticDrive.depositedPower
    (drive : LongitudinalAcousticDrive) : Power :=
  { watts := drive.transfer.receivedPower }

/-- Deposited longitudinal-wave power is nonnegative. -/
lemma LongitudinalAcousticDrive.deposited_power_nonnegative
    (drive : LongitudinalAcousticDrive) :
    0 ≤ drive.depositedPower.watts := by
  simpa [LongitudinalAcousticDrive.depositedPower] using
    drive.transfer.receivedPower_nonnegative

/-- Passive longitudinal-wave coupling cannot deposit more than source power. -/
lemma LongitudinalAcousticDrive.deposited_power_le_source
    (drive : LongitudinalAcousticDrive) :
    drive.depositedPower.watts ≤ drive.transfer.link.sourcePower.watts := by
  simpa [LongitudinalAcousticDrive.depositedPower] using
    drive.transfer.receivedPower_le_sourcePower

/-- Momentum-only axial thrust of an Argon exhaust stream. Pressure-thrust and
nozzle-wall terms require separate measured inputs. -/
noncomputable def argonJetThrust (flow : ConductiveArgonFlow) : Force :=
  { newtons := flow.massFlow.kilogramsPerSecond * flow.velocity.metersPerSecond }

/-- Momentum-only Argon jet thrust is nonnegative. -/
lemma argonJetThrust_nonnegative (flow : ConductiveArgonFlow) :
    0 ≤ (argonJetThrust flow).newtons := by
  unfold argonJetThrust
  exact mul_nonneg flow.massFlow_nonnegative flow.velocity_nonnegative

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

/-- Classical momentum thrust and kinetic jet power obey `F * v = 2 * P`. -/
lemma argonJetThrust_mul_velocity (flow : ConductiveArgonFlow) :
    (argonJetThrust flow).newtons * flow.velocity.metersPerSecond =
      2 * (argonKineticPower flow).watts := by
  unfold argonJetThrust argonKineticPower
  ring

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

/-- A classical Argon MHD operating point with an ordinary longitudinal
acoustic drive. Acoustic source power must be included in the declared control
budget rather than treated as an unaccounted source of motive energy. -/
structure LongitudinalAcousticArgonOperatingPoint where
  plant : ArgonMHDPlant
  drive : LongitudinalAcousticDrive
  acousticSourceWithinControl :
    drive.transfer.link.sourcePower.watts ≤ plant.accounting.controlPower.watts

/-- Deposited acoustic power is bounded by the declared MHD control budget. -/
lemma LongitudinalAcousticArgonOperatingPoint.deposited_power_le_control
    (point : LongitudinalAcousticArgonOperatingPoint) :
    point.drive.depositedPower.watts ≤ point.plant.accounting.controlPower.watts := by
  exact le_trans point.drive.deposited_power_le_source point.acousticSourceWithinControl

/-- A finite cellulose-strip resonator coupled through a measured solid-to-Argon
interface. The MIMO source, strip conversion, interface loss, and downstream
acoustic link are separate power boundaries. -/
structure CelluloseStripArgonOperatingPoint where
  argonPoint : LongitudinalAcousticArgonOperatingPoint
  stripDrive : FireCannonCelluloseStripDrive
  stripToArgonInterface : InterfaceResponse
  transmittedAcousticPower : Power
  transmittedAcousticPower_nonnegative : 0 ≤ transmittedAcousticPower.watts
  transmittedPowerLaw : transmittedAcousticPower.watts =
    stripDrive.resonator.acousticOutputPower.watts *
      stripToArgonInterface.transmissionPower
  acousticSourcePowerLaw :
    argonPoint.drive.transfer.link.sourcePower.watts = transmittedAcousticPower.watts
  frequencyMatch : argonPoint.drive.transfer.wave.frequencyHz =
    stripDrive.resonator.secondHarmonicFrequency.hz
  arraySource_positive : 0 < stripDrive.pump.array.sourcePower
  arraySourceWithinControl :
    stripDrive.pump.array.sourcePower ≤ argonPoint.plant.accounting.controlPower.watts

/-- End-to-end acoustic source efficiency from MIMO array power to the Argon
link boundary. -/
noncomputable def CelluloseStripArgonOperatingPoint.sourceEfficiency
    (point : CelluloseStripArgonOperatingPoint) : ℝ :=
  point.argonPoint.drive.transfer.link.sourcePower.watts /
    point.stripDrive.pump.array.sourcePower

/-- Solid-to-Argon transmission cannot increase strip acoustic power. -/
lemma CelluloseStripArgonOperatingPoint.source_power_le_strip_output
    (point : CelluloseStripArgonOperatingPoint) :
    point.argonPoint.drive.transfer.link.sourcePower.watts ≤
      point.stripDrive.resonator.acousticOutputPower.watts := by
  rw [point.acousticSourcePowerLaw, point.transmittedPowerLaw]
  calc
    point.stripDrive.resonator.acousticOutputPower.watts *
          point.stripToArgonInterface.transmissionPower ≤
        point.stripDrive.resonator.acousticOutputPower.watts * 1 :=
      mul_le_mul_of_nonneg_left point.stripToArgonInterface.transmission_le_one
        point.stripDrive.resonator.acoustic_output_nonnegative
    _ = point.stripDrive.resonator.acousticOutputPower.watts := by ring

/-- The complete passive strip-to-Argon acoustic source is bounded by the MIMO
array source power. -/
lemma CelluloseStripArgonOperatingPoint.source_power_le_array_source
    (point : CelluloseStripArgonOperatingPoint) :
    point.argonPoint.drive.transfer.link.sourcePower.watts ≤
      point.stripDrive.pump.array.sourcePower := by
  exact le_trans point.source_power_le_strip_output
    point.stripDrive.acoustic_output_le_array_source

/-- Strip-to-Argon source efficiency is nonnegative. -/
lemma CelluloseStripArgonOperatingPoint.source_efficiency_nonnegative
    (point : CelluloseStripArgonOperatingPoint) :
    0 ≤ point.sourceEfficiency := by
  unfold CelluloseStripArgonOperatingPoint.sourceEfficiency
  exact div_nonneg point.argonPoint.drive.transfer.link.sourcePower_nonnegative
    point.arraySource_positive.le

/-- A passive strip and interface have source efficiency at most one. -/
lemma CelluloseStripArgonOperatingPoint.source_efficiency_le_one
    (point : CelluloseStripArgonOperatingPoint) :
    point.sourceEfficiency ≤ 1 := by
  unfold CelluloseStripArgonOperatingPoint.sourceEfficiency
  exact (div_le_one point.arraySource_positive).2 point.source_power_le_array_source

/-- The full array source, rather than only transmitted acoustic power, is
included in the plant control budget. -/
lemma CelluloseStripArgonOperatingPoint.source_power_le_control
    (point : CelluloseStripArgonOperatingPoint) :
    point.argonPoint.drive.transfer.link.sourcePower.watts ≤
      point.argonPoint.plant.accounting.controlPower.watts := by
  exact le_trans point.source_power_le_array_source point.arraySourceWithinControl

/-- One calibrated candidate in a joint ECR and longitudinal-acoustic Argon
frequency sweep. ECR source power is charged to the ionization budget, while
the acoustic source remains inside the plant control budget. -/
structure ArgonFrequencySweepPoint where
  ecr : ElectronCyclotronResonance
  operatingPoint : LongitudinalAcousticArgonOperatingPoint
  operatingCosts : MHDOperatingCosts
  ecrSourceWithinIonizationCost :
    ecr.sourcePower.watts ≤ operatingCosts.ionizationPower.watts
  ionizationPower_positive : 0 < operatingCosts.ionizationPower.watts
  fullInput_positive :
    0 < (operatingPoint.plant.accounting.fullInputPower operatingCosts).watts

/-- Ionized Argon mass flow per ionization joule. This metric compares plasma
production across frequencies without conflating it with MHD output power. -/
noncomputable def ArgonFrequencySweepPoint.ionizationYield
    (point : ArgonFrequencySweepPoint) : ℝ :=
  point.operatingPoint.plant.argon.ionizedMassFlow.kilogramsPerSecond /
    point.operatingCosts.ionizationPower.watts

/-- Electrical output per total input power at one measured frequency point. -/
noncomputable def ArgonFrequencySweepPoint.electricalYield
    (point : ArgonFrequencySweepPoint) : ℝ :=
  point.operatingPoint.plant.accounting.fullEfficiency point.operatingCosts

/-- Momentum thrust per total input watt at one measured frequency point. -/
noncomputable def ArgonFrequencySweepPoint.thrustPerInputPower
    (point : ArgonFrequencySweepPoint) : ℝ :=
  (argonJetThrust point.operatingPoint.plant.argon).newtons /
    (point.operatingPoint.plant.accounting.fullInputPower point.operatingCosts).watts

/-- A calibrated Argon sweep point has nonnegative electrical yield. -/
lemma ArgonFrequencySweepPoint.electrical_yield_nonnegative
    (point : ArgonFrequencySweepPoint) :
    0 ≤ point.electricalYield := by
  unfold ArgonFrequencySweepPoint.electricalYield MHDPowerAccounting.fullEfficiency
  exact div_nonneg
    point.operatingPoint.plant.accounting.electricalOutputPower_nonnegative
    point.fullInput_positive.le

/-- Ionized Argon mass flow per ionization joule is nonnegative. -/
lemma ArgonFrequencySweepPoint.ionization_yield_nonnegative
    (point : ArgonFrequencySweepPoint) :
    0 ≤ point.ionizationYield := by
  unfold ArgonFrequencySweepPoint.ionizationYield
  exact div_nonneg point.operatingPoint.plant.argon.ionized_mass_flow_nonnegative
    point.ionizationPower_positive.le

/-- Passive electrical yield remains bounded by one at every sweep point. -/
lemma ArgonFrequencySweepPoint.electrical_yield_le_one
    (point : ArgonFrequencySweepPoint) :
    point.electricalYield ≤ 1 := by
  exact point.operatingPoint.plant.accounting.full_efficiency_le_one
    point.operatingCosts point.fullInput_positive

/-- Momentum thrust per total input watt is nonnegative. -/
lemma ArgonFrequencySweepPoint.thrust_per_input_power_nonnegative
    (point : ArgonFrequencySweepPoint) :
    0 ≤ point.thrustPerInputPower := by
  unfold ArgonFrequencySweepPoint.thrustPerInputPower
  exact div_nonneg (argonJetThrust_nonnegative point.operatingPoint.plant.argon)
    point.fullInput_positive.le

/-- A finite family of measured Argon frequency candidates. -/
structure ArgonFrequencySweep (count : ℕ) where
  point : Fin count → ArgonFrequencySweepPoint

/-- A candidate maximizes measured full electrical efficiency over the finite
sweep. Equal-scoring candidates are all optimal. -/
def ArgonFrequencySweep.IsElectricalYieldOptimal {count : ℕ}
    (sweep : ArgonFrequencySweep count) (candidate : Fin count) : Prop :=
  ∀ index, (sweep.point index).electricalYield ≤
    (sweep.point candidate).electricalYield

/-- A candidate maximizes ionized Argon mass flow per ionization joule over
the finite sweep. -/
def ArgonFrequencySweep.IsIonizationYieldOptimal {count : ℕ}
    (sweep : ArgonFrequencySweep count) (candidate : Fin count) : Prop :=
  ∀ index, (sweep.point index).ionizationYield ≤
    (sweep.point candidate).ionizationYield

/-- A candidate maximizes momentum thrust per total input watt over the finite
sweep. This objective is distinct from electrical generation efficiency. -/
def ArgonFrequencySweep.IsThrustPerPowerOptimal {count : ℕ}
    (sweep : ArgonFrequencySweep count) (candidate : Fin count) : Prop :=
  ∀ index, (sweep.point index).thrustPerInputPower ≤
    (sweep.point candidate).thrustPerInputPower

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

/-! ## Classical Ponderomotive Cycle-Averaging, Aerodynamic Moments, Halbach Deflection,
Centrifugal Cooling, Langmuir Dispersion, Landau Resonance, and Beltrami States

The definitions and lemmas below formalize the classical mathematical identities
from the wakefield/MHD analysis (`Twistors-and-Positive-Grassmannian-Interference.md`):
1. Ponderomotive potential, downward intensity-gradient force, RF cycle cancellation of
   first-order quiver motion, and pulsed duty-cycle average-force bounds.
2. Classical Bernoulli dynamic pressure, differential surface normal force, and
   torque orthogonality to both the lever arm and normal force.
3. Halbach transverse magnetic Lorentz deflection and work-free orthogonality
   (`F ⬝ᵥ v = 0`), showing why electrical power extraction requires an opposing
   Faraday load electric field (`FaradayChannel`) rather than magnetic turning alone.
4. Radial centrifugal pump head integration, closed-loop thermosyphon buoyancy head
   (vanishing for isothermal loops), and 3D rigid-body gyroscopic precession torque.
5. Bohm-Gross warm Langmuir dispersion, the `v_φ * v_g = 3 * v_th²` invariant, and
   the Dawson wave-breaking electrostatic energy-density bound.
6. Linear Vlasov-Poisson Landau growth/damping rate, bump-on-tail amplification,
   thermal damping, quasilinear plateau saturation, and wave-particle power balance.
7. Force-free Woltjer-Taylor Beltrami currents (`J ⨯₃ B = 0`), active cooling margin
   against Ohmic heating, and discrete 4-cycle 1-cocycle gauge invariance.
-/

/-- Three-component real spatial vector representation (`Fin 3 → ℝ`). -/
@[blueprint "def:signals-mhd-vec3"
  (title := "Three-dimensional spatial vector representation")
  (statement := /-- A three-dimensional spatial vector is represented by a function
    $\operatorname{Fin}(3)\to\mathbb R$, supporting componentwise dot and cross products. -/)]
abbrev Vec3 := Fin 3 → ℝ

/-- Squared Euclidean norm `‖v‖² = v ⬝ᵥ v` on `Vec3`. -/
@[blueprint "def:signals-mhd-norm-sq"
  (title := "Squared Euclidean norm on Vec3")
  (statement := /-- For $\mathbf v\in\mathbb R^3$, define
    $\lVert\mathbf v\rVert^2=\mathbf v\cdot\mathbf v$. -/)]
def normSqVec3 (v : Vec3) : ℝ := v ⬝ᵥ v

/-- The squared Euclidean norm on `Vec3` is nonnegative. -/
@[blueprint "lem:signals-mhd-norm-sq-nonneg"
  (title := "Nonnegativity of squared Euclidean norm")
  (statement := /-- For every $\mathbf v\in\mathbb R^3$, $\lVert\mathbf v\rVert^2\ge 0$. -/)
  (proof := /-- Expand the three coordinate squares and sum nonnegativities. -/)
  (latexEnv := "lemma")]
lemma normSqVec3_nonneg (v : Vec3) : 0 ≤ normSqVec3 v := by
  simp only [normSqVec3, dotProduct, Fin.sum_univ_three]
  nlinarith [sq_nonneg (v 0), sq_nonneg (v 1), sq_nonneg (v 2)]

/-- High-frequency oscillating electric field `E(x, t) = cos(ωt) • E0(x)`. -/
@[blueprint "def:signals-oscillating-electric-field"
  (title := "Harmonic electric-field envelope")
  (statement := /-- A harmonic electric field with spatial amplitude $\mathbf E_0(\mathbf x)$
    and carrier frequency $\omega$ evaluates to $\cos(\omega t)\,\mathbf E_0(\mathbf x)$. -/)]
noncomputable def oscillatingElectricField (ω : ℝ) (E0 : Vec3 → Vec3) (x : Vec3) (t : ℝ) : Vec3 :=
  (Real.cos (ω * t)) • E0 x

/-- Classical ponderomotive potential `U_p(x) = (e² / (4 m_e ω²)) ‖E0(x)‖²`. -/
@[blueprint "def:signals-ponderomotive-potential"
  (title := "Classical ponderomotive potential")
  (statement := /-- The cycle-averaged ponderomotive potential of a carrier wave of frequency
    $\omega$ acting on charge $e$ and mass $m_e$ is
    $U_p(\mathbf x)=\frac{e^2}{4 m_e\omega^2}\lVert\mathbf E_0(\mathbf x)\rVert^2$. -/)]
noncomputable def ponderomotivePotential (m_e e ω : ℝ) (E0 : Vec3 → Vec3) (x : Vec3) : ℝ :=
  (e ^ 2 / (4 * m_e * ω ^ 2)) * normSqVec3 (E0 x)

/-- The ponderomotive potential is nonnegative for nonnegative mass. -/
@[blueprint "lem:signals-ponderomotive-potential-nonneg"
  (title := "Nonnegativity of ponderomotive potential")
  (statement := /-- When $m_e\ge 0$, the ponderomotive potential satisfies $U_p(\mathbf x)\ge 0$. -/)
  (proof := /-- Combine the nonnegative prefactor $e^2/(4 m_e\omega^2)$ with $\lVert\mathbf E_0(\mathbf x)\rVert^2\ge 0$. -/)
  (latexEnv := "lemma")]
lemma ponderomotivePotential_nonneg (m_e e ω : ℝ) (E0 : Vec3 → Vec3) (x : Vec3)
    (hm : 0 ≤ m_e) :
    0 ≤ ponderomotivePotential m_e e ω E0 x := by
  unfold ponderomotivePotential
  have h_coeff : 0 ≤ e ^ 2 / (4 * m_e * ω ^ 2) := by positivity
  exact mul_nonneg h_coeff (normSqVec3_nonneg (E0 x))

/-- Secular ponderomotive drift force `F_p(x) = -(e² / (4 m_e ω²)) • ∇(‖E0(x)‖²)`. -/
@[blueprint "def:signals-ponderomotive-force"
  (title := "Secular ponderomotive drift force")
  (statement := /-- Given the spatial intensity gradient $\mathbf g(\mathbf x)=\nabla(\lVert\mathbf E_0(\mathbf x)\rVert^2)$,
    the secular ponderomotive force is
    $\mathbf F_p(\mathbf x)=-\frac{e^2}{4 m_e\omega^2}\mathbf g(\mathbf x)$. -/)]
noncomputable def ponderomotiveForce (m_e e ω : ℝ) (grad_E0_sq : Vec3 → Vec3) (x : Vec3) : Vec3 :=
  (- (e ^ 2 / (4 * m_e * ω ^ 2))) • grad_E0_sq x

/-- The ponderomotive force acts opposite to the electric-field intensity gradient. -/
@[blueprint "lem:signals-ponderomotive-down-gradient"
  (title := "Ponderomotive drift opposes intensity gradient")
  (statement := /-- For $m_e\ge 0$, $\mathbf F_p(\mathbf x)\cdot\nabla(\lVert\mathbf E_0(\mathbf x)\rVert^2)\le 0$,
    expelling charged particles from high-intensity field regions. -/)
  (proof := /-- Factor out the nonpositive scalar $-\frac{e^2}{4 m_e\omega^2}$ from the squared gradient norm. -/)
  (latexEnv := "lemma")]
lemma ponderomotiveForce_down_gradient (m_e e ω : ℝ) (grad_E0_sq : Vec3 → Vec3) (x : Vec3)
    (hm : 0 ≤ m_e) :
    (ponderomotiveForce m_e e ω grad_E0_sq x) ⬝ᵥ (grad_E0_sq x) ≤ 0 := by
  unfold ponderomotiveForce
  rw [smul_dotProduct, smul_eq_mul]
  have h_coeff : 0 ≤ e ^ 2 / (4 * m_e * ω ^ 2) := by positivity
  have h_norm : 0 ≤ normSqVec3 (grad_E0_sq x) := normSqVec3_nonneg (grad_E0_sq x)
  change (- (e ^ 2 / (4 * m_e * ω ^ 2))) * normSqVec3 (grad_E0_sq x) ≤ 0
  nlinarith

/-- The linear oscillatory quiver factor `cos(ωt)` integrates to zero over one RF period `T = 2π/ω`. -/
@[blueprint "lem:signals-oscillatory-lorentz-cancels"
  (title := "First-order quiver oscillation cancels over one RF period")
  (statement := /-- For $\omega\ne 0$ and period $T=2\pi/\omega$,
    $\int_0^T \cos(\omega t)\,dt=0$. -/)
  (proof := /-- Substitute $u=\omega t$ over $[0,2\pi]$ and evaluate $\sin(2\pi)-\sin(0)=0$. -/)
  (latexEnv := "lemma")]
lemma oscillatory_lorentz_cancels (ω : ℝ) (h_ω : ω ≠ 0) (T : ℝ) (hT : T = 2 * Real.pi / ω) :
    ∫ t in (0 : ℝ)..T, Real.cos (ω * t) = 0 := by
  subst hT
  rw [intervalIntegral.integral_comp_mul_left (fun x => Real.cos x) h_ω]
  have h_upper : ω * (2 * Real.pi / ω) = 2 * Real.pi := mul_div_cancel₀ (2 * Real.pi) h_ω
  rw [mul_zero, h_upper, integral_cos, Real.sin_two_pi, Real.sin_zero, sub_self, smul_zero]

/-- Cycle-averaging the decomposed Lorentz force (secular ponderomotive drift plus
first-order oscillatory quiver term `F_osc * cos(ωt)`) over `T = 2π/ω` recovers the
exact secular ponderomotive force along each coordinate axis. -/
@[blueprint "thm:signals-ponderomotive-cycle-average"
  (title := "Cycle-averaged Lorentz force isolates secular ponderomotive drift")
  (statement := /-- Averaging $\mathbf F_{\mathrm{inst}}(t)=\mathbf F_p(\mathbf x)+\mathbf F_{\mathrm{osc}}(\mathbf x)\cos(\omega t)$
    over one full RF cycle $T=2\pi/\omega$ ($\omega\ne 0$) yields $\mathbf F_p(\mathbf x)$ componentwise. -/)
  (proof := /-- Split the interval integral by linearity, integrate the constant drift term over $[0,T]$,
    and cancel the oscillatory quiver integral using \texttt{oscillatory\_lorentz\_cancels}. -/)]
theorem ponderomotive_cycle_average
    (m_e e ω : ℝ) (h_ω : ω ≠ 0)
    (grad_E0_sq F_osc : Vec3 → Vec3)
    (x : Vec3) (T : ℝ) (hT : T = 2 * Real.pi / ω) (i : Fin 3) :
    let F_inst (t : ℝ) : ℝ :=
      ponderomotiveForce m_e e ω grad_E0_sq x i + F_osc x i * Real.cos (ω * t)
    (1 / T) * (∫ t in (0 : ℝ)..T, F_inst t) =
      ponderomotiveForce m_e e ω grad_E0_sq x i := by
  intro F_inst
  have hT_ne : T ≠ 0 := by
    rw [hT]
    exact div_ne_zero (mul_ne_zero two_ne_zero Real.pi_ne_zero) h_ω
  have h_int_const :
      IntervalIntegrable (fun _ : ℝ => ponderomotiveForce m_e e ω grad_E0_sq x i) volume 0 T :=
    continuous_const.intervalIntegrable 0 T
  have h_int_cos : IntervalIntegrable (fun t => F_osc x i * Real.cos (ω * t)) volume 0 T :=
    (continuous_const.mul
      (Real.continuous_cos.comp (continuous_const.mul continuous_id))).intervalIntegrable 0 T
  change (1 / T) * (∫ t in (0 : ℝ)..T,
    (ponderomotiveForce m_e e ω grad_E0_sq x i + F_osc x i * Real.cos (ω * t))) = _
  rw [intervalIntegral.integral_add h_int_const h_int_cos]
  rw [intervalIntegral.integral_const, intervalIntegral.integral_const_mul]
  rw [oscillatory_lorentz_cancels ω h_ω T hT]
  simp [smul_eq_mul, hT_ne]

/-- Time-averaged force of a pulsed electromagnetic or ponderomotive drive with
bounded duty cycle `dutyCycle ∈ [0, 1]`. -/
@[blueprint "def:signals-pulsed-average-force"
  (title := "Duty-cycle-weighted pulsed average force")
  (statement := /-- A pulsed thruster with peak force $F_{\mathrm{peak}}$ and duty cycle
    $d\in[0,1]$ delivers time-averaged force $F_{\mathrm{avg}}=d\,F_{\mathrm{peak}}$. -/)]
def pulsedAverageForce (peakForce : Force) (dutyCycle : BoundedFactor) : Force :=
  { newtons := peakForce.newtons * dutyCycle.value }

/-- A passive pulsed drive with nonnegative peak force has time-averaged force
bounded above by its peak pulse force; high peak pulse power does not bypass
duty-cycle scaling of average momentum transfer. -/
@[blueprint "lem:signals-pulsed-average-force-le-peak"
  (title := "Pulsed time-averaged force bound")
  (statement := /-- For $F_{\mathrm{peak}}\ge 0$ and duty cycle $d\in[0,1]$,
    $F_{\mathrm{avg}}=d\,F_{\mathrm{peak}}\le F_{\mathrm{peak}}$. -/)
  (proof := /-- Multiply $d\le 1$ by the nonnegative peak force $F_{\mathrm{peak}}$. -/)
  (latexEnv := "lemma")]
lemma pulsedAverageForce_le_peak (peakForce : Force) (h_peak : 0 ≤ peakForce.newtons)
    (dutyCycle : BoundedFactor) :
    (pulsedAverageForce peakForce dutyCycle).newtons ≤ peakForce.newtons := by
  unfold pulsedAverageForce
  calc
    peakForce.newtons * dutyCycle.value ≤ peakForce.newtons * 1 :=
      mul_le_mul_of_nonneg_left dutyCycle.le_one h_peak
    _ = peakForce.newtons := by ring

/-- Classical Bernoulli dynamic pressure `q(x) = (1/2) ρ ‖V(x)‖²`. -/
@[blueprint "def:signals-bernoulli-dynamic-pressure"
  (title := "Bernoulli dynamic pressure field")
  (statement := /-- For fluid density $\rho$ and wake velocity field $\mathbf V(\mathbf x)$,
    the classical dynamic pressure is $q(\mathbf x)=\tfrac12\rho\lVert\mathbf V(\mathbf x)\rVert^2$. -/)]
noncomputable def dynamicPressure (ρ_fluid : ℝ) (V_wake : Vec3 → Vec3) (x : Vec3) : ℝ :=
  0.5 * ρ_fluid * normSqVec3 (V_wake x)

/-- Dynamic pressure is nonnegative for nonnegative fluid density. -/
@[blueprint "lem:signals-dynamic-pressure-nonneg"
  (title := "Nonnegativity of Bernoulli dynamic pressure")
  (statement := /-- When $\rho\ge 0$, dynamic pressure satisfies $q(\mathbf x)\ge 0$ everywhere. -/)
  (proof := /-- Combine $\rho\ge 0$ with nonnegativity of the squared velocity norm. -/)
  (latexEnv := "lemma")]
lemma dynamicPressure_nonneg (ρ_fluid : ℝ) (V_wake : Vec3 → Vec3)
    (h_ρ : 0 ≤ ρ_fluid) (x : Vec3) :
    0 ≤ dynamicPressure ρ_fluid V_wake x := by
  unfold dynamicPressure
  have h_norm := normSqVec3_nonneg (V_wake x)
  nlinarith

/-- Uncalibrated dynamic-pressure surface load proxy `dF_proxy(x) = -q(x) • n(x)`.

This retains the source chat's literal `-½ρ‖V‖² n` expression as a dynamic-pressure
load proxy. It is not the static Bernoulli surface traction: at a stagnation point
(`V(x) = 0`) this proxy vanishes whereas static Bernoulli pressure reaches its
stagnation maximum `p_0`. Use `bernoulliSurfaceTraction` for static-pressure loading. -/
@[blueprint "def:signals-differential-pressure-force"
  (title := "Uncalibrated dynamic-pressure surface load proxy")
  (statement := /-- At hull point $\mathbf x$ with outward normal $\mathbf n(\mathbf x)$,
    the dynamic-pressure load proxy is $-q(\mathbf x)\,\mathbf n(\mathbf x)$. Because $q(\mathbf x)$
    vanishes at stagnation ($\mathbf V(\mathbf x)=\mathbf 0$), this is a dynamic-pressure proxy
    rather than static Bernoulli traction; see \texttt{bernoulliSurfaceTraction}. -/)]
noncomputable def differentialPressureForce
    (ρ_fluid : ℝ) (V_wake n : Vec3 → Vec3) (x : Vec3) : Vec3 :=
  (- dynamicPressure ρ_fluid V_wake x) • (n x)

/-- At a stagnation point (`V_wake x = 0`), the dynamic-pressure load proxy vanishes. -/
@[blueprint "lem:signals-pressure-force-proxy-at-stagnation"
  (title := "Dynamic-pressure load proxy vanishes at stagnation")
  (statement := /-- At a stagnation point $\mathbf V(\mathbf x)=\mathbf 0$, the dynamic-pressure
    load proxy satisfies $-q(\mathbf x)\,\mathbf n(\mathbf x)=\mathbf 0$. -/)
  (proof := /-- Substitute $\mathbf V(\mathbf x)=\mathbf 0$ into $q(\mathbf x)$. -/)
  (latexEnv := "lemma")]
lemma differentialPressureForce_at_stagnation
    (ρ_fluid : ℝ) (V_wake n : Vec3 → Vec3) (x : Vec3) (h_stag : V_wake x = 0) :
    differentialPressureForce ρ_fluid V_wake n x = 0 := by
  simp [differentialPressureForce, dynamicPressure, normSqVec3, h_stag]

/-- Differential aerodynamic torque proxy `dτ_proxy(x) = (x - CM) ⨯₃ dF_proxy(x)` relative to `CM`. -/
@[blueprint "def:signals-differential-aerodynamic-moment"
  (title := "Differential dynamic-pressure moment proxy")
  (statement := /-- Relative to center of mass $\mathbf x_{\mathrm{CM}}$, the differential
    moment of the dynamic-pressure load proxy is
    $(\mathbf x-\mathbf x_{\mathrm{CM}})\times (-q(\mathbf x)\,\mathbf n(\mathbf x))$. -/)]
noncomputable def differentialAerodynamicMoment
    (ρ_fluid : ℝ) (V_wake n : Vec3 → Vec3) (CM x : Vec3) : Vec3 :=
  (x - CM) ⨯₃ (differentialPressureForce ρ_fluid V_wake n x)

/-- Total dynamic-pressure moment proxy integrated over `hullSurface` with respect to
surface-area measure `μ`. -/
@[blueprint "def:signals-total-aerodynamic-moment"
  (title := "Surface-integrated dynamic-pressure moment proxy")
  (statement := /-- Integrating the differential dynamic-pressure moment proxy componentwise over a hull
    surface with respect to surface measure $\mu$ yields the total moment proxy vector. -/)]
noncomputable def totalAerodynamicMoment
    (ρ_fluid : ℝ) (V_wake n : Vec3 → Vec3) (hullSurface : Set Vec3) (CM : Vec3)
    [MeasurableSpace Vec3] (μ : Measure Vec3) : Vec3 :=
  fun i => ∫ x in hullSurface, differentialAerodynamicMoment ρ_fluid V_wake n CM x i ∂μ

/-- The differential aerodynamic torque vector at any hull point `x` is orthogonal
to the lever arm `x - CM`. -/
@[blueprint "lem:signals-aerodynamic-moment-orthogonal-lever"
  (title := "Aerodynamic torque is orthogonal to lever arm")
  (statement := /-- At every hull point $\mathbf x$,
    $((\mathbf x-\mathbf x_{\mathrm{CM}})\times d\mathbf F(\mathbf x))\cdot(\mathbf x-\mathbf x_{\mathrm{CM}})=0$. -/)
  (proof := /-- Apply cross-product self-orthogonality \texttt{dot\_self\_cross}. -/)
  (latexEnv := "lemma")]
lemma differentialAerodynamicMoment_orthogonal_lever_arm
    (ρ_fluid : ℝ) (V_wake n : Vec3 → Vec3) (CM x : Vec3) :
    (differentialAerodynamicMoment ρ_fluid V_wake n CM x) ⬝ᵥ (x - CM) = 0 := by
  simp only [differentialAerodynamicMoment, dotProduct_comm, dot_self_cross]

/-- The differential aerodynamic torque vector at any hull point `x` is orthogonal
to the local normal pressure force. -/
@[blueprint "lem:signals-aerodynamic-moment-orthogonal-force"
  (title := "Aerodynamic torque is orthogonal to surface pressure force")
  (statement := /-- At every hull point $\mathbf x$,
    $((\mathbf x-\mathbf x_{\mathrm{CM}})\times d\mathbf F(\mathbf x))\cdot d\mathbf F(\mathbf x)=0$. -/)
  (proof := /-- Apply cross-product orthogonality \texttt{dot\_cross\_self}. -/)
  (latexEnv := "lemma")]
lemma differentialAerodynamicMoment_orthogonal_force
    (ρ_fluid : ℝ) (V_wake n : Vec3 → Vec3) (CM x : Vec3) :
    (differentialAerodynamicMoment ρ_fluid V_wake n CM x) ⬝ᵥ
      (differentialPressureForce ρ_fluid V_wake n x) = 0 := by
  simp only [differentialAerodynamicMoment, dotProduct_comm, dot_cross_self]

/-- Incompressible inviscid Bernoulli static pressure `p(x) = p_0 - (1/2) ρ ‖V(x)‖²`
from stagnation (total) pressure `p_0`. -/
@[blueprint "def:signals-bernoulli-static-pressure"
  (title := "Bernoulli static pressure from stagnation pressure")
  (statement := /-- Along an incompressible inviscid streamline with stagnation pressure $p_0$,
    the local static pressure is $p(\mathbf x)=p_0-q(\mathbf x)=p_0-\tfrac12\rho\lVert\mathbf V(\mathbf x)\rVert^2$. -/)]
noncomputable def bernoulliStaticPressure
    (p_stagnation ρ_fluid : ℝ) (V_flow : Vec3 → Vec3) (x : Vec3) : ℝ :=
  p_stagnation - dynamicPressure ρ_fluid V_flow x

/-- Dimensionless aerodynamic pressure coefficient `C_p(x) = 1 - ‖V(x)‖² / V_ref²`. -/
@[blueprint "def:signals-pressure-coefficient"
  (title := "Incompressible aerodynamic pressure coefficient")
  (statement := /-- Relative to squared reference speed $V_{\mathrm{ref}}^2$, the incompressible
    pressure coefficient is $C_p(\mathbf x)=1-\lVert\mathbf V(\mathbf x)\rVert^2/V_{\mathrm{ref}}^2$. -/)]
noncomputable def pressureCoefficient (V_ref_sq : ℝ) (V_flow : Vec3 → Vec3) (x : Vec3) : ℝ :=
  1 - normSqVec3 (V_flow x) / V_ref_sq

/-- Static pressure reconstructed from freestream static pressure `p_inf`, density `ρ_fluid`,
and squared freestream speed `V_inf_sq`: `p(x) = p_inf + q_inf * C_p(x)`. -/
@[blueprint "def:signals-bernoulli-freestream-pressure"
  (title := "Freestream pressure-coefficient static pressure reconstruction")
  (statement := /-- From freestream static pressure $p_\infty$, density $\rho$, and squared reference
    speed $V_\infty^2$, reconstruct static pressure as
    $p_{\mathrm{fs}}(\mathbf x)=p_\infty+\tfrac12\rho V_\infty^2\,C_p(\mathbf x)$. -/)]
noncomputable def bernoulliStaticPressureFromFreestream
    (p_inf ρ_fluid V_inf_sq : ℝ) (V_flow : Vec3 → Vec3) (x : Vec3) : ℝ :=
  p_inf + (0.5 * ρ_fluid * V_inf_sq) * pressureCoefficient V_inf_sq V_flow x

/-- Reconstructing static pressure from `p_inf + q_inf * C_p(x)` agrees identically with
`p_0 - q(x)` when `p_0 = p_inf + (1/2) ρ V_inf²` and `V_inf² ≠ 0`. -/
@[blueprint "thm:signals-bernoulli-static-eq-freestream"
  (title := "Bernoulli static pressure matches pressure-coefficient reconstruction")
  (statement := /-- When $V_\infty^2\ne 0$ and $p_0=p_\infty+\tfrac12\rho V_\infty^2$,
    $p_0-q(\mathbf x)=p_\infty+q_\infty C_p(\mathbf x)$. -/)
  (proof := /-- Unfold \texttt{pressureCoefficient} and clear $V_\infty^2\ne 0$. -/)]
theorem bernoulliStaticPressure_eq_freestream
    (p_0 p_inf ρ_fluid V_inf_sq : ℝ) (V_flow : Vec3 → Vec3) (x : Vec3)
    (h_Vref : V_inf_sq ≠ 0) (h_p0 : p_0 = p_inf + 0.5 * ρ_fluid * V_inf_sq) :
    bernoulliStaticPressure p_0 ρ_fluid V_flow x =
      bernoulliStaticPressureFromFreestream p_inf ρ_fluid V_inf_sq V_flow x := by
  unfold bernoulliStaticPressure bernoulliStaticPressureFromFreestream
    dynamicPressure pressureCoefficient
  rw [h_p0]
  field_simp [h_Vref]
  ring

/-- At a stagnation point (`V_flow x = 0`), the pressure coefficient is `+1` and static
Bernoulli pressure attains its stagnation maximum `p_0`. -/
@[blueprint "thm:signals-bernoulli-stagnation-recovery"
  (title := "Stagnation point recovers full total pressure and unit pressure coefficient")
  (statement := /-- If $\mathbf V(\mathbf x)=\mathbf 0$, then $C_p(\mathbf x)=1$ and
    $p(\mathbf x)=p_0$, whereas $q(\mathbf x)=0$. -/)
  (proof := /-- Substitute $\mathbf V(\mathbf x)=\mathbf 0$ into $q(\mathbf x)$, $C_p(\mathbf x)$, and $p(\mathbf x)$. -/)]
theorem bernoulliStaticPressure_at_stagnation
    (p_0 ρ_fluid V_ref_sq : ℝ) (V_flow : Vec3 → Vec3) (x : Vec3)
    (h_stag : V_flow x = 0) :
    pressureCoefficient V_ref_sq V_flow x = 1 ∧
      bernoulliStaticPressure p_0 ρ_fluid V_flow x = p_0 ∧
      dynamicPressure ρ_fluid V_flow x = 0 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [pressureCoefficient, normSqVec3, h_stag]
  · simp [bernoulliStaticPressure, dynamicPressure, normSqVec3, h_stag]
  · simp [dynamicPressure, normSqVec3, h_stag]

/-- Higher local flow speed lowers the static Bernoulli pressure (`∂p/∂(|V|²) ≤ 0`). -/
@[blueprint "lem:signals-bernoulli-static-decreases-with-speed"
  (title := "Static Bernoulli pressure decreases with flow speed")
  (statement := /-- For $\rho\ge 0$ and $\lVert\mathbf V_1(\mathbf x)\rVert^2\le\lVert\mathbf V_2(\mathbf x)\rVert^2$,
    $p_0-\tfrac12\rho\lVert\mathbf V_2(\mathbf x)\rVert^2\le p_0-\tfrac12\rho\lVert\mathbf V_1(\mathbf x)\rVert^2$. -/)
  (proof := /-- Scale the squared-speed inequality by $-\tfrac12\rho\le 0$. -/)
  (latexEnv := "lemma")]
lemma bernoulliStaticPressure_decreases_with_speed
    (p_0 ρ_fluid : ℝ) (V_1 V_2 : Vec3 → Vec3) (x : Vec3)
    (h_ρ : 0 ≤ ρ_fluid) (h_speed : normSqVec3 (V_1 x) ≤ normSqVec3 (V_2 x)) :
    bernoulliStaticPressure p_0 ρ_fluid V_2 x ≤
      bernoulliStaticPressure p_0 ρ_fluid V_1 x := by
  unfold bernoulliStaticPressure dynamicPressure
  nlinarith

/-- Physical normal surface pressure traction `dF_static(x) = -p(x) • n(x)` using
Bernoulli static pressure `p(x) = p_0 - (1/2) ρ ‖V(x)‖²`. -/
@[blueprint "def:signals-bernoulli-surface-traction"
  (title := "Static Bernoulli normal surface traction")
  (statement := /-- At hull point $\mathbf x$ with outward normal $\mathbf n(\mathbf x)$,
    the static pressure traction is $-p(\mathbf x)\,\mathbf n(\mathbf x)=-(p_0-q(\mathbf x))\,\mathbf n(\mathbf x)$. -/)]
noncomputable def bernoulliSurfaceTraction
    (p_stagnation ρ_fluid : ℝ) (V_flow n : Vec3 → Vec3) (x : Vec3) : Vec3 :=
  (- bernoulliStaticPressure p_stagnation ρ_fluid V_flow x) • (n x)

/-- At a stagnation point (`V_flow x = 0`), the static Bernoulli surface traction equals
`(-p_0) • n(x)` rather than zero. -/
@[blueprint "lem:signals-bernoulli-traction-at-stagnation"
  (title := "Nonvanishing static Bernoulli traction at stagnation")
  (statement := /-- At a stagnation point $\mathbf V(\mathbf x)=\mathbf 0$,
    the static Bernoulli surface traction is $-p_0\,\mathbf n(\mathbf x)$. -/)
  (proof := /-- Apply \texttt{bernoulliStaticPressure\_at\_stagnation}. -/)
  (latexEnv := "lemma")]
lemma bernoulliSurfaceTraction_at_stagnation
    (p_0 ρ_fluid : ℝ) (V_flow n : Vec3 → Vec3) (x : Vec3)
    (h_stag : V_flow x = 0) :
    bernoulliSurfaceTraction p_0 ρ_fluid V_flow n x = (- p_0) • (n x) := by
  have h := (bernoulliStaticPressure_at_stagnation p_0 ρ_fluid 1 V_flow x h_stag).2.1
  simp [bernoulliSurfaceTraction, h]

/-- Differential aerodynamic moment `dτ(x) = (x - CM) ⨯₃ (-p(x) • n(x))` from static
Bernoulli surface traction. -/
@[blueprint "def:signals-bernoulli-aerodynamic-moment"
  (title := "Differential static-Bernoulli aerodynamic moment")
  (statement := /-- The differential torque from static Bernoulli surface traction is
    $(\mathbf x-\mathbf x_{\mathrm{CM}})\times(-p(\mathbf x)\,\mathbf n(\mathbf x))$. -/)]
noncomputable def bernoulliAerodynamicMoment
    (p_stagnation ρ_fluid : ℝ) (V_flow n : Vec3 → Vec3) (CM x : Vec3) : Vec3 :=
  (x - CM) ⨯₃ (bernoulliSurfaceTraction p_stagnation ρ_fluid V_flow n x)

/-- Total aerodynamic moment integrated over `hullSurface` using static Bernoulli traction. -/
@[blueprint "def:signals-total-bernoulli-aerodynamic-moment"
  (title := "Surface-integrated static-Bernoulli aerodynamic moment")
  (statement := /-- Integrating the static-Bernoulli differential moment componentwise over a hull
    surface with respect to surface measure $\mu$ yields the total static-Bernoulli aerodynamic moment. -/)]
noncomputable def totalBernoulliAerodynamicMoment
    (p_stagnation ρ_fluid : ℝ) (V_flow n : Vec3 → Vec3) (hullSurface : Set Vec3) (CM : Vec3)
    [MeasurableSpace Vec3] (μ : Measure Vec3) : Vec3 :=
  fun i => ∫ x in hullSurface, bernoulliAerodynamicMoment p_stagnation ρ_fluid V_flow n CM x i ∂μ

/-- The differential static-Bernoulli aerodynamic moment at any hull point `x` is
orthogonal to the lever arm `x - CM`. -/
@[blueprint "lem:signals-bernoulli-moment-orthogonal-lever"
  (title := "Static-Bernoulli aerodynamic moment is orthogonal to lever arm")
  (statement := /-- At every hull point $\mathbf x$,
    $((\mathbf x-\mathbf x_{\mathrm{CM}})\times(-p(\mathbf x)\,\mathbf n(\mathbf x)))\cdot(\mathbf x-\mathbf x_{\mathrm{CM}})=0$. -/)
  (proof := /-- Apply cross-product self-orthogonality \texttt{dot\_self\_cross}. -/)
  (latexEnv := "lemma")]
lemma bernoulliAerodynamicMoment_orthogonal_lever_arm
    (p_stagnation ρ_fluid : ℝ) (V_flow n : Vec3 → Vec3) (CM x : Vec3) :
    (bernoulliAerodynamicMoment p_stagnation ρ_fluid V_flow n CM x) ⬝ᵥ (x - CM) = 0 := by
  simp only [bernoulliAerodynamicMoment, dotProduct_comm, dot_self_cross]

/-- The differential static-Bernoulli aerodynamic moment at any hull point `x` is
orthogonal to the local static-Bernoulli normal surface traction. -/
@[blueprint "lem:signals-bernoulli-moment-orthogonal-force"
  (title := "Static-Bernoulli aerodynamic moment is orthogonal to surface traction")
  (statement := /-- At every hull point $\mathbf x$,
    $((\mathbf x-\mathbf x_{\mathrm{CM}})\times(-p(\mathbf x)\,\mathbf n(\mathbf x)))\cdot(-p(\mathbf x)\,\mathbf n(\mathbf x))=0$. -/)
  (proof := /-- Apply cross-product orthogonality \texttt{dot\_cross\_self}. -/)
  (latexEnv := "lemma")]
lemma bernoulliAerodynamicMoment_orthogonal_force
    (p_stagnation ρ_fluid : ℝ) (V_flow n : Vec3 → Vec3) (CM x : Vec3) :
    (bernoulliAerodynamicMoment p_stagnation ρ_fluid V_flow n CM x) ⬝ᵥ
      (bernoulliSurfaceTraction p_stagnation ρ_fluid V_flow n x) = 0 := by
  simp only [bernoulliAerodynamicMoment, dotProduct_comm, dot_cross_self]

/-- Purely longitudinal particle velocity `(0, 0, vz)`. -/
@[blueprint "def:signals-longitudinal-velocity"
  (title := "Longitudinal axial velocity vector")
  (statement := /-- A purely axial velocity along the $z$-axis is $(0,0,v_z)$. -/)]
def longitudinalVelocity (vz : ℝ) : Vec3 :=
  ![0, 0, vz]

/-- Static transverse Halbach magnetic field `(0, By, 0)`. -/
@[blueprint "def:signals-transverse-halbach-field"
  (title := "Transverse Halbach magnetic field vector")
  (statement := /-- A static transverse Halbach magnetic field along the $y$-axis is $(0,B_y,0)$. -/)]
def transverseHalbachField (By : ℝ) : Vec3 :=
  ![0, By, 0]

/-- Classical magnetic Lorentz force `F = q • (v ⨯₃ B)`. -/
@[blueprint "def:signals-magnetic-lorentz-force"
  (title := "Magnetic Lorentz force")
  (statement := /-- A particle of charge $q$ moving at velocity $\mathbf v$ in magnetic field
    $\mathbf B$ experiences magnetic Lorentz force $\mathbf F=q(\mathbf v\times\mathbf B)$. -/)]
def magneticLorentzForce (q : ℝ) (v B : Vec3) : Vec3 :=
  q • (v ⨯₃ B)

/-- A purely longitudinal velocity `(0, 0, vz)` entering a purely Y-axis magnetic
field `(0, By, 0)` experiences a purely X-axis magnetic Lorentz force `(-q * vz * By, 0, 0)`. -/
@[blueprint "thm:signals-halbach-transverse-conversion"
  (title := "Halbach transverse Lorentz deflection")
  (statement := /-- A longitudinal velocity $(0,0,v_z)$ crossing a transverse magnetic field
    $(0,B_y,0)$ experiences the orthogonal force $(-q v_z B_y,0,0)$ along the $x$-axis. -/)
  (proof := /-- Evaluate the cross product across all three $\operatorname{Fin}(3)$ indices and simplify by ring algebra. -/)]
theorem halbach_transverse_conversion (q vz By : ℝ) :
    magneticLorentzForce q (longitudinalVelocity vz) (transverseHalbachField By) =
      ![-q * vz * By, 0, 0] := by
  ext i
  fin_cases i
  · simp [magneticLorentzForce, longitudinalVelocity, transverseHalbachField, cross_apply]
    ring
  · simp [magneticLorentzForce, longitudinalVelocity, transverseHalbachField, cross_apply]
  · simp [magneticLorentzForce, longitudinalVelocity, transverseHalbachField, cross_apply]

/-- Pure magnetic Lorentz deflection is strictly orthogonal to velocity (`F ⬝ᵥ v = 0`)
and therefore performs zero mechanical work; net electrical extraction requires an
opposing transverse load electric field as modeled in `FaradayChannel`. -/
@[blueprint "thm:signals-magnetic-lorentz-work-free"
  (title := "Pure magnetic deflection is work-free")
  (statement := /-- For any charge $q$, velocity $\mathbf v$, and magnetic field $\mathbf B$,
    $q(\mathbf v\times\mathbf B)\cdot\mathbf v=0$; harvesting electrical power therefore requires
    an opposing Faraday load electric field rather than magnetic deflection alone. -/)
  (proof := /-- Pull out the scalar $q$ and apply \texttt{dot\_self\_cross}. -/)]
theorem magneticLorentzForce_work_free (q : ℝ) (v B : Vec3) :
    (magneticLorentzForce q v B) ⬝ᵥ v = 0 := by
  rw [magneticLorentzForce, smul_dotProduct, dotProduct_comm, dot_self_cross, smul_zero]

/-- The magnetic Lorentz force is also orthogonal to the magnetic field (`F ⬝ᵥ B = 0`). -/
@[blueprint "lem:signals-magnetic-lorentz-orthogonal-field"
  (title := "Magnetic Lorentz force is orthogonal to magnetic field")
  (statement := /-- For any charge $q$, velocity $\mathbf v$, and magnetic field $\mathbf B$,
    $q(\mathbf v\times\mathbf B)\cdot\mathbf B=0$. -/)
  (proof := /-- Pull out the scalar $q$ and apply \texttt{dot\_cross\_self}. -/)
  (latexEnv := "lemma")]
lemma magneticLorentzForce_orthogonal_field (q : ℝ) (v B : Vec3) :
    (magneticLorentzForce q v B) ⬝ᵥ B = 0 := by
  rw [magneticLorentzForce, smul_dotProduct, dotProduct_comm, dot_cross_self, smul_zero]

/-- Radial centrifugal pressure gradient `dP/dr = ρ * ω² * r` in a rotating fluid leg. -/
@[blueprint "def:signals-centrifugal-pressure-gradient"
  (title := "Radial centrifugal pressure gradient")
  (statement := /-- A fluid of density $\rho$ rotating at angular speed $\omega$ experiences
    radial pressure gradient $\frac{dP}{dr}=\rho\omega^2 r$. -/)]
noncomputable def centrifugalPressureGradient (ρ ω r : ℝ) : ℝ :=
  (ρ * ω ^ 2) * r

/-- Integrating the radial centrifugal pressure gradient from `r_inner` to `r_outer`
yields `(1 / 2) * ρ * ω² * (r_outer² - r_inner²)`. -/
@[blueprint "thm:signals-centrifugal-pump-head"
  (title := "Integrated radial centrifugal pressure head")
  (statement := /-- Integrating $\rho\omega^2 r$ from inner hub radius $r_{\mathrm{in}}$ to outer rim
    radius $r_{\mathrm{out}}$ yields $\Delta P=\tfrac12\rho\omega^2(r_{\mathrm{out}}^2-r_{\mathrm{in}}^2)$. -/)
  (proof := /-- Factor out $\rho\omega^2$ and apply the fundamental theorem of calculus for $\int r\,dr$. -/)]
theorem centrifugal_pump_head (ρ ω r_inner r_outer : ℝ) :
    ∫ r in r_inner..r_outer, centrifugalPressureGradient ρ ω r =
      (1 / 2) * ρ * ω ^ 2 * (r_outer ^ 2 - r_inner ^ 2) := by
  unfold centrifugalPressureGradient
  rw [intervalIntegral.integral_const_mul, integral_id]
  ring

/-- The radial centrifugal pressure head is nonnegative when `0 ≤ ρ` and `0 ≤ r_inner ≤ r_outer`. -/
@[blueprint "lem:signals-centrifugal-pump-head-nonneg"
  (title := "Nonnegativity of outward centrifugal pressure head")
  (statement := /-- When $\rho\ge 0$ and $0\le r_{\mathrm{in}}\le r_{\mathrm{out}}$,
    the radial centrifugal pressure head is nonnegative. -/)
  (proof := /-- Factor $r_{\mathrm{out}}^2-r_{\mathrm{in}}^2=(r_{\mathrm{out}}-r_{\mathrm{in}})(r_{\mathrm{out}}+r_{\mathrm{in}})\ge 0$. -/)
  (latexEnv := "lemma")]
lemma centrifugal_pump_head_nonneg (ρ ω r_inner r_outer : ℝ)
    (h_ρ : 0 ≤ ρ) (h_inner : 0 ≤ r_inner) (h_radii : r_inner ≤ r_outer) :
    0 ≤ ∫ r in r_inner..r_outer, centrifugalPressureGradient ρ ω r := by
  rw [centrifugal_pump_head]
  have h_diff : 0 ≤ r_outer - r_inner := sub_nonneg.mpr h_radii
  have h_sum : 0 ≤ r_outer + r_inner := by linarith
  have h_sq : 0 ≤ r_outer ^ 2 - r_inner ^ 2 := by
    calc
      0 ≤ (r_outer - r_inner) * (r_outer + r_inner) := mul_nonneg h_diff h_sum
      _ = r_outer ^ 2 - r_inner ^ 2 := by ring
  have h_factor : 0 ≤ (1 / 2 : ℝ) * ρ * ω ^ 2 := by positivity
  exact mul_nonneg h_factor h_sq

/-- In a closed rotating cooling loop, the net driving pressure head between an
outward cold leg (`ρ_cold`) and an inward hot return leg (`ρ_hot`) is governed by
the thermosyphon density differential `(1/2) * (ρ_cold - ρ_hot) * ω² * (r_outer² - r_inner²)`. -/
@[blueprint "thm:signals-centrifugal-thermosyphon-head"
  (title := "Closed-loop centrifugal thermosyphon driving head")
  (statement := /-- The net circulation head between an outward cold leg of density $\rho_{\mathrm{cold}}$
    and an inward hot leg of density $\rho_{\mathrm{hot}}$ in a rotating spool is
    $\Delta P_{\mathrm{loop}}=\tfrac12(\rho_{\mathrm{cold}}-\rho_{\mathrm{hot}})\omega^2(r_{\mathrm{out}}^2-r_{\mathrm{in}}^2)$. -/)
  (proof := /-- Evaluate both radial leg integrals via \texttt{centrifugal\_pump\_head} and subtract. -/)]
theorem centrifugal_thermosyphon_net_head (ρ_cold ρ_hot ω r_inner r_outer : ℝ) :
    (∫ r in r_inner..r_outer, centrifugalPressureGradient ρ_cold ω r) -
      (∫ r in r_inner..r_outer, centrifugalPressureGradient ρ_hot ω r) =
      (1 / 2) * (ρ_cold - ρ_hot) * ω ^ 2 * (r_outer ^ 2 - r_inner ^ 2) := by
  rw [centrifugal_pump_head, centrifugal_pump_head]
  ring

/-- An isothermal closed rotating loop (`ρ_cold = ρ_hot`) has zero net centrifugal
circulation head because the outward and inward radial pressure heads cancel. -/
@[blueprint "lem:signals-centrifugal-isothermal-zero"
  (title := "Isothermal closed rotating loop has zero net pumping head")
  (statement := /-- When $\rho_{\mathrm{cold}}=\rho_{\mathrm{hot}}$, the outward and inward
    centrifugal pressure heads cancel identically ($\Delta P_{\mathrm{loop}}=0$). -/)
  (proof := /-- Specialize \texttt{centrifugal\_thermosyphon\_net\_head} to equal leg densities. -/)
  (latexEnv := "lemma")]
lemma centrifugal_closed_loop_isothermal_zero (ρ ω r_inner r_outer : ℝ) :
    (∫ r in r_inner..r_outer, centrifugalPressureGradient ρ ω r) -
      (∫ r in r_inner..r_outer, centrifugalPressureGradient ρ ω r) = 0 := by
  rw [centrifugal_thermosyphon_net_head]
  ring

/-- Angular velocity vector `(0, 0, ω_z)` of a rotor spinning about the Z axis. -/
@[blueprint "def:signals-spool-angular-velocity"
  (title := "Spool axial angular velocity vector")
  (statement := /-- A spool spinning about the $z$-axis has angular velocity vector $(0,0,\omega_z)$. -/)]
def spoolAngularVelocity (ω_z : ℝ) : Vec3 :=
  ![0, 0, ω_z]

/-- Axial angular momentum vector `L = I_spool • (0, 0, ω_z)`. -/
@[blueprint "def:signals-spool-angular-momentum"
  (title := "Spool axial angular momentum vector")
  (statement := /-- For axial moment of inertia $I_{\mathrm{spool}}$, the spool angular momentum is
    $\mathbf L=(0,0,I_{\mathrm{spool}}\omega_z)$. -/)]
def spoolAngularMomentum (I_spool ω_z : ℝ) : Vec3 :=
  I_spool • (spoolAngularVelocity ω_z)

/-- Gyroscopic torque vector `τ = Ω ⨯₃ L` required to precess the rotor at rate `Ω`. -/
@[blueprint "def:signals-gyroscopic-torque"
  (title := "Gyroscopic precession torque vector")
  (statement := /-- Precessing the spool at angular rate $\boldsymbol\Omega$ requires gyroscopic
    torque $\boldsymbol\tau=\boldsymbol\Omega\times\mathbf L$. -/)]
def gyroscopicTorque (I_spool : ℝ) (Ω : Vec3) (ω_z : ℝ) : Vec3 :=
  Ω ⨯₃ (spoolAngularMomentum I_spool ω_z)

/-- Precessing a Z-axis rotor purely about the X axis (pitch) induces a pure Y-axis
(yaw) gyroscopic torque `(0, -Ω_x * I_spool * ω_z, 0)`. -/
@[blueprint "thm:signals-pitch-induces-yaw-torque"
  (title := "Pitch precession induces orthogonal yaw gyroscopic torque")
  (statement := /-- Precessing a $z$-axis spool at pitch rate $\boldsymbol\Omega=(\Omega_x,0,0)$
    produces the orthogonal $y$-axis yaw torque $(0,-\Omega_x I_{\mathrm{spool}}\omega_z,0)$. -/)
  (proof := /-- Expand the three components of $\boldsymbol\Omega\times\mathbf L$ and simplify by ring algebra. -/)]
theorem pitch_induces_yaw_torque (I_spool Ω_x ω_z : ℝ) :
    let Ω_pitch : Vec3 := ![Ω_x, 0, 0]
    gyroscopicTorque I_spool Ω_pitch ω_z = ![0, -Ω_x * I_spool * ω_z, 0] := by
  intro Ω_pitch
  ext i
  fin_cases i
  · simp [Ω_pitch, gyroscopicTorque, spoolAngularMomentum, spoolAngularVelocity, cross_apply]
  · simp [Ω_pitch, gyroscopicTorque, spoolAngularMomentum, spoolAngularVelocity, cross_apply]
    ring
  · simp [Ω_pitch, gyroscopicTorque, spoolAngularMomentum, spoolAngularVelocity, cross_apply]

/-- Gyroscopic torque is orthogonal to the precession angular velocity `Ω`. -/
@[blueprint "lem:signals-gyroscopic-torque-orthogonal-precession"
  (title := "Gyroscopic torque is orthogonal to precession rate")
  (statement := /-- For any precession vector $\boldsymbol\Omega$,
    $(\boldsymbol\Omega\times\mathbf L)\cdot\boldsymbol\Omega=0$. -/)
  (proof := /-- Apply \texttt{dot\_self\_cross}. -/)
  (latexEnv := "lemma")]
lemma gyroscopicTorque_orthogonal_precession (I_spool : ℝ) (Ω : Vec3) (ω_z : ℝ) :
    (gyroscopicTorque I_spool Ω ω_z) ⬝ᵥ Ω = 0 := by
  simp only [gyroscopicTorque, dotProduct_comm, dot_self_cross]

/-- Gyroscopic torque is orthogonal to the rotor angular momentum `L`. -/
@[blueprint "lem:signals-gyroscopic-torque-orthogonal-momentum"
  (title := "Gyroscopic torque is orthogonal to angular momentum")
  (statement := /-- For any precession vector $\boldsymbol\Omega$,
    $(\boldsymbol\Omega\times\mathbf L)\cdot\mathbf L=0$. -/)
  (proof := /-- Apply \texttt{dot\_cross\_self}. -/)
  (latexEnv := "lemma")]
lemma gyroscopicTorque_orthogonal_angularMomentum (I_spool : ℝ) (Ω : Vec3) (ω_z : ℝ) :
    (gyroscopicTorque I_spool Ω ω_z) ⬝ᵥ (spoolAngularMomentum I_spool ω_z) = 0 := by
  simp only [gyroscopicTorque, dotProduct_comm, dot_cross_self]

/-- Squared Bohm-Gross frequency for warm electrostatic Langmuir oscillations:
`ω²(k) = ω_p² + 3 * k² * v_th²`. -/
@[blueprint "def:signals-bohm-gross-omega-sq"
  (title := "Bohm-Gross warm Langmuir dispersion relation")
  (statement := /-- For plasma frequency $\omega_p$, wavenumber $k$, and electron thermal speed
    $v_{\mathrm{th}}$, the squared Bohm-Gross frequency is $\omega^2(k)=\omega_p^2+3k^2 v_{\mathrm{th}}^2$. -/)]
def bohmGrossOmegaSq (ω_p k v_th : ℝ) : ℝ :=
  ω_p ^ 2 + 3 * k ^ 2 * v_th ^ 2

/-- Electrostatic wave phase velocity `v_φ = ω / k`. -/
@[blueprint "def:signals-langmuir-phase-velocity"
  (title := "Langmuir wave phase velocity")
  (statement := /-- For angular frequency $\omega$ and wavenumber $k$, the phase velocity is $v_\phi=\omega/k$. -/)]
noncomputable def langmuirPhaseVelocity (ω k : ℝ) : ℝ :=
  ω / k

/-- Bohm-Gross group velocity `v_g = ∂ω/∂k = (3 * k * v_th²) / ω`. -/
@[blueprint "def:signals-bohm-gross-group-velocity"
  (title := "Bohm-Gross wave group velocity")
  (statement := /-- Differentiating $\omega^2=\omega_p^2+3k^2 v_{\mathrm{th}}^2$ gives the group velocity
    $v_g=\frac{\partial\omega}{\partial k}=\frac{3 k v_{\mathrm{th}}^2}{\omega}$. -/)]
noncomputable def bohmGrossGroupVelocity (ω k v_th : ℝ) : ℝ :=
  (3 * k * v_th ^ 2) / ω

/-- Bohm-Gross velocity coupling invariant: for any nonzero wavenumber `k` and
frequency `ω`, `v_φ * v_g = 3 * v_th²`. -/
@[blueprint "thm:signals-bohm-gross-velocity-product"
  (title := "Bohm-Gross phase-group velocity invariant")
  (statement := /-- For any $k\ne 0$ and $\omega\ne 0$, the product of phase and group velocity
    satisfies $v_\phi v_g = 3 v_{\mathrm{th}}^2$. -/)
  (proof := /-- Clear denominators with $k\ne 0$ and $\omega\ne 0$. -/)]
theorem bohm_gross_phase_group_product (ω k v_th : ℝ) (h_k : k ≠ 0) (h_ω : ω ≠ 0) :
    langmuirPhaseVelocity ω k * bohmGrossGroupVelocity ω k v_th = 3 * v_th ^ 2 := by
  unfold langmuirPhaseVelocity bohmGrossGroupVelocity
  field_simp [h_k, h_ω]

/-- Under the Bohm-Gross dispersion relation `ω² = ω_p² + 3 * k² * v_th²` with `k ≠ 0`,
the squared phase velocity satisfies `3 * v_th² ≤ v_φ²`. -/
@[blueprint "thm:signals-bohm-gross-phase-velocity-bound"
  (title := "Bohm-Gross phase velocity lower bound")
  (statement := /-- Whenever $\omega^2=\omega_p^2+3k^2 v_{\mathrm{th}}^2$ and $k\ne 0$,
    the squared phase velocity satisfies $3 v_{\mathrm{th}}^2\le v_\phi^2$. -/)
  (proof := /-- Divide the dispersion relation by $k^2>0$ and use $\omega_p^2/k^2\ge 0$. -/)]
theorem bohm_gross_phase_velocity_sq_ge_three_vth_sq
    (ω ω_p k v_th : ℝ) (h_k : k ≠ 0) (h_disp : ω ^ 2 = bohmGrossOmegaSq ω_p k v_th) :
    3 * v_th ^ 2 ≤ (langmuirPhaseVelocity ω k) ^ 2 := by
  unfold langmuirPhaseVelocity bohmGrossOmegaSq at *
  have hk2 : 0 < k ^ 2 := sq_pos_of_ne_zero h_k
  rw [div_pow, h_disp]
  have h_split : (ω_p ^ 2 + 3 * k ^ 2 * v_th ^ 2) / k ^ 2 = ω_p ^ 2 / k ^ 2 + 3 * v_th ^ 2 := by
    field_simp [h_k]
  rw [h_split]
  have h_pos : 0 ≤ ω_p ^ 2 / k ^ 2 := div_nonneg (sq_nonneg ω_p) (le_of_lt hk2)
  linarith

/-- Electrostatic wave energy density `u_E = (1 / 2) * ε0 * E_z²`. -/
@[blueprint "def:signals-electrostatic-wave-energy-density"
  (title := "Electrostatic wave energy density")
  (statement := /-- For permittivity $\varepsilon_0$ and axial field amplitude $E_z$,
    the electrostatic energy density is $u_E=\tfrac12\varepsilon_0 E_z^2$. -/)]
noncomputable def electrostaticWaveEnergyDensity (ε0 E_z : ℝ) : ℝ :=
  0.5 * ε0 * E_z ^ 2

/-- Dawson wave-breaking energy-density bound: when `0 ≤ ε0` and `0 ≤ E_z ≤ E_dawson`,
the electrostatic energy density cannot exceed the Dawson saturation limit. -/
@[blueprint "thm:signals-dawson-energy-density-bound"
  (title := "Dawson wave-breaking energy-density ceiling")
  (statement := /-- For $\varepsilon_0\ge 0$ and $0\le E_z\le E_{\mathrm{Dawson}}$,
    $u_E(\varepsilon_0,E_z)\le u_E(\varepsilon_0,E_{\mathrm{Dawson}})$. -/)
  (proof := /-- Factor $E_{\mathrm{Dawson}}^2-E_z^2=(E_{\mathrm{Dawson}}-E_z)(E_{\mathrm{Dawson}}+E_z)\ge 0$
    and scale by $\tfrac12\varepsilon_0\ge 0$. -/)]
theorem dawson_energy_density_bound (ε0 E_z E_dawson : ℝ)
    (h_ε0 : 0 ≤ ε0) (h_Ez : 0 ≤ E_z) (h_dawson : E_z ≤ E_dawson) :
    electrostaticWaveEnergyDensity ε0 E_z ≤ electrostaticWaveEnergyDensity ε0 E_dawson := by
  unfold electrostaticWaveEnergyDensity
  have h_diff : 0 ≤ E_dawson - E_z := sub_nonneg.mpr h_dawson
  have h_sum : 0 ≤ E_dawson + E_z := by linarith
  have h_sq_diff : 0 ≤ E_dawson ^ 2 - E_z ^ 2 := by
    calc
      0 ≤ (E_dawson - E_z) * (E_dawson + E_z) := mul_nonneg h_diff h_sum
      _ = E_dawson ^ 2 - E_z ^ 2 := by ring
  nlinarith

/-- Linear Vlasov-Poisson Landau growth/damping rate with signed wavenumber convention
`γ = (π * ω_p³ / (2 * k * |k| * n_0)) * (∂f₀/∂v)|_{v = ω/k}`.

The signed factor `k * |k|` (from the Plemelj residue of `1 / (k * v - ω)` for `ω > 0`)
ensures that a thermal Maxwellian damps (`γ < 0`) both forward waves (`k > 0`, `v_φ > 0`,
`∂f₀/∂v < 0`) and backward waves (`k < 0`, `v_φ < 0`, `∂f₀/∂v > 0`). -/
@[blueprint "def:signals-landau-growth-rate"
  (title := "Linear Vlasov-Poisson Landau growth/damping rate")
  (statement := /-- Given plasma frequency $\omega_p$, signed wavenumber $k$, background density $n_0$,
    and resonant distribution slope $\partial_v f_0$, the linear Landau rate is
    $\gamma=\frac{\pi\omega_p^3}{2k|k| n_0}\,\partial_v f_0$. -/)]
noncomputable def landauGrowthRate (ω_p k n_0 df_dv : ℝ) : ℝ :=
  (Real.pi * ω_p ^ 3 / (2 * k * |k| * n_0)) * df_dv

/-- For a forward-propagating wave (`0 < k`), `k * |k| = k²`. -/
@[blueprint "lem:signals-landau-growth-rate-pos-k"
  (title := "Forward-wave reduction of signed Landau rate")
  (statement := /-- When $k>0$, $k|k|=k^2$ and
    $\gamma=\frac{\pi\omega_p^3}{2k^2 n_0}\,\partial_v f_0$. -/)
  (proof := /-- Rewrite $|k|=k$ for $k>0$ and simplify by ring algebra. -/)
  (latexEnv := "lemma")]
lemma landauGrowthRate_pos_k (ω_p k n_0 df_dv : ℝ) (h_k : 0 < k) :
    landauGrowthRate ω_p k n_0 df_dv =
      (Real.pi * ω_p ^ 3 / (2 * k ^ 2 * n_0)) * df_dv := by
  unfold landauGrowthRate
  rw [abs_of_pos h_k]
  ring

/-- For a backward-propagating wave (`k < 0`), `k * |k| = -k²`. -/
@[blueprint "lem:signals-landau-growth-rate-neg-k"
  (title := "Backward-wave reduction of signed Landau rate")
  (statement := /-- When $k<0$, $k|k|=-k^2$ and
    $\gamma=-\frac{\pi\omega_p^3}{2k^2 n_0}\,\partial_v f_0$. -/)
  (proof := /-- Rewrite $|k|=-k$ for $k<0$ and simplify by ring algebra. -/)
  (latexEnv := "lemma")]
lemma landauGrowthRate_neg_k (ω_p k n_0 df_dv : ℝ) (h_k : k < 0) :
    landauGrowthRate ω_p k n_0 df_dv =
      - ((Real.pi * ω_p ^ 3 / (2 * k ^ 2 * n_0)) * df_dv) := by
  unfold landauGrowthRate
  rw [abs_of_neg h_k]
  ring

/-- For a forward wave (`0 < k`), a positive velocity-distribution slope (`df_dv > 0`,
bump-on-tail instability) at the resonant phase velocity yields a strictly positive
linear growth rate (`0 < γ`). -/
@[blueprint "thm:signals-inverse-landau-growth-pos"
  (title := "Forward bump-on-tail positive slope drives inverse Landau amplification")
  (statement := /-- When $\omega_p>0$, $k>0$, $n_0>0$, and $\partial_v f_0>0$,
    the linear growth rate satisfies $\gamma>0$. -/)
  (proof := /-- Rewrite $k|k|=k^2$ for $k>0$ and apply positivity to $\pi\omega_p^3/(2k^2 n_0)>0$ and $\partial_v f_0>0$. -/)]
theorem inverse_landau_growth_pos (ω_p k n_0 df_dv : ℝ)
    (h_ωp : 0 < ω_p) (h_k : 0 < k) (h_n0 : 0 < n_0) (h_bump : 0 < df_dv) :
    0 < landauGrowthRate ω_p k n_0 df_dv := by
  rw [landauGrowthRate_pos_k ω_p k n_0 df_dv h_k]
  positivity

/-- For a forward wave (`0 < k`), a negative velocity-distribution slope (`df_dv < 0`,
thermal Maxwellian tail at `v_φ = ω/k > 0`) yields linear Landau damping (`γ < 0`). -/
@[blueprint "thm:signals-thermal-landau-damping-neg"
  (title := "Forward thermal Maxwellian slope induces Landau damping")
  (statement := /-- When $\omega_p>0$, $k>0$, $n_0>0$, and $\partial_v f_0<0$,
    the linear Landau rate is strictly negative ($\gamma<0$). -/)
  (proof := /-- Rewrite $k|k|=k^2$ for $k>0$ and multiply the positive prefactor $\pi\omega_p^3/(2k^2 n_0)>0$ by $\partial_v f_0<0$. -/)]
theorem thermal_landau_damping_neg (ω_p k n_0 df_dv : ℝ)
    (h_ωp : 0 < ω_p) (h_k : 0 < k) (h_n0 : 0 < n_0) (h_thermal : df_dv < 0) :
    landauGrowthRate ω_p k n_0 df_dv < 0 := by
  rw [landauGrowthRate_pos_k ω_p k n_0 df_dv h_k]
  have h_prefactor : 0 < Real.pi * ω_p ^ 3 / (2 * k ^ 2 * n_0) := by positivity
  exact mul_neg_of_pos_of_neg h_prefactor h_thermal

/-- For a backward wave (`k < 0`), a positive velocity-distribution slope (`0 < df_dv`,
as in a symmetric thermal Maxwellian evaluated at negative phase velocity `v_φ = ω/k < 0`)
also yields linear Landau damping (`γ < 0`). -/
@[blueprint "thm:signals-backward-thermal-landau-damping"
  (title := "Backward wave in a thermal Maxwellian also undergoes Landau damping")
  (statement := /-- When $\omega_p>0$, $k<0$, $n_0>0$, and $\partial_v f_0>0$ at $v_\phi=\omega/k<0$,
    the signed-wavenumber Landau rate satisfies $\gamma<0$. -/)
  (proof := /-- Rewrite $k|k|=-k^2$ for $k<0$ and negate the positive product $(\pi\omega_p^3/(2k^2 n_0))\partial_v f_0>0$. -/)]
theorem backward_thermal_landau_damping_neg (ω_p k n_0 df_dv : ℝ)
    (h_ωp : 0 < ω_p) (h_k : k < 0) (h_n0 : 0 < n_0) (h_thermal_back : 0 < df_dv) :
    landauGrowthRate ω_p k n_0 df_dv < 0 := by
  rw [landauGrowthRate_neg_k ω_p k n_0 df_dv h_k]
  have hk2 : 0 < k ^ 2 := sq_pos_of_ne_zero (ne_of_lt h_k)
  have h_pos : 0 < (Real.pi * ω_p ^ 3 / (2 * k ^ 2 * n_0)) * df_dv := by positivity
  linarith

/-- Quasilinear plateau saturation: when resonant trapping flattens the distribution
slope (`df_dv = 0`), the linear Landau growth rate vanishes (`γ = 0`). -/
@[blueprint "lem:signals-quasilinear-plateau-saturation"
  (title := "Quasilinear plateau saturation")
  (statement := /-- When wave-particle trapping flattens the distribution slope ($\partial_v f_0=0$),
    the linear Landau growth rate vanishes ($\gamma=0$). -/)
  (proof := /-- Ring simplification with zero slope factor. -/)
  (latexEnv := "lemma")]
lemma quasilinear_plateau_saturation (ω_p k n_0 : ℝ) :
    landauGrowthRate ω_p k n_0 0 = 0 := by
  unfold landauGrowthRate
  ring

/-- Resonant wave-particle power conservation: the electrostatic energy growth rate
`2 * γ * U_wave` plus the resonant beam kinetic-energy loss rate `-(2 * γ * U_wave)` sums to zero. -/
@[blueprint "thm:signals-resonant-energy-conservation"
  (title := "Resonant wave-particle power balance")
  (statement := /-- The cavity wave-energy growth rate $2\gamma U_{\mathrm{wave}}$ and the resonant
    beam kinetic-power loss rate $-2\gamma U_{\mathrm{wave}}$ sum identically to zero. -/)
  (proof := /-- Additive cancellation in $\mathbb R$. -/)]
theorem resonant_energy_transfer_conservation (γ U_wave : ℝ) :
    let dU_wave_dt := 2 * γ * U_wave
    let dK_beam_dt := - (2 * γ * U_wave)
    dU_wave_dt + dK_beam_dt = 0 := by
  intro dU_wave_dt dK_beam_dt
  ring

/-- Woltjer-Taylor Beltrami current `J = α • B` collinear with the magnetic field. -/
@[blueprint "def:signals-taylor-beltrami-current"
  (title := "Woltjer-Taylor Beltrami current")
  (statement := /-- In a relaxed constant-$\alpha$ Taylor state, the current density is collinear
    with the magnetic field: $\mathbf J=\alpha\mathbf B$. -/)]
def taylorBeltramiCurrent (α : ℝ) (B : Vec3) : Vec3 :=
  α • B

/-- In a relaxed Beltrami/Taylor state `J = α • B`, the internal magnetic Lorentz
force density `J ⨯₃ B` vanishes identically across all three spatial axes.
Note: By the MHD virial theorem, global confinement still requires external boundary
coils or wall pressure because a force-free interior exerts zero radial pinch gradient. -/
@[blueprint "thm:signals-taylor-state-force-free"
  (title := "Beltrami/Taylor state has zero internal magnetic Lorentz force")
  (statement := /-- When $\mathbf J=\alpha\mathbf B$, the internal Lorentz force density satisfies
    $\mathbf J\times\mathbf B=\mathbf 0$ componentwise. -/)
  (proof := /-- Expand all three components of $(\alpha\mathbf B)\times\mathbf B$ and cancel. -/)]
theorem taylor_state_force_free (α : ℝ) (B : Vec3) :
    (taylorBeltramiCurrent α B) ⨯₃ B = ![0, 0, 0] := by
  ext i
  fin_cases i <;> simp [taylorBeltramiCurrent]

/-- Radial magnetic pinch pressure margin under active thermal extraction:
if `P_thermal_init ≤ P_mag` and active cooling removes thermal pressure faster
than Ohmic dissipation adds it (`ΔP_ohm < ΔP_cool`), the net radial confinement
margin `P_mag - P_thermal_eff` remains strictly positive. -/
@[blueprint "thm:signals-active-cooling-stabilizes-pinch"
  (title := "Active cooling preserves radial magnetic pinch margin")
  (statement := /-- If $P_{\mathrm{th,0}}\le P_{\mathrm{mag}}$ and active thermal extraction exceeds
    Ohmic heating ($\Delta P_{\mathrm{ohm}}<\Delta P_{\mathrm{cool}}$), then
    $P_{\mathrm{mag}}-(P_{\mathrm{th,0}}+\Delta P_{\mathrm{ohm}}-\Delta P_{\mathrm{cool}})>0$. -/)
  (proof := /-- Linear arithmetic from the initial pressure balance and cooling dominance. -/)]
theorem active_cooling_stabilizes_pinch
    (P_mag P_thermal_init ΔP_ohm ΔP_cool : ℝ)
    (h_init_bal : P_thermal_init ≤ P_mag)
    (h_cool_dom : ΔP_ohm < ΔP_cool) :
    let P_thermal_eff := P_thermal_init + ΔP_ohm - ΔP_cool
    0 < P_mag - P_thermal_eff := by
  intro P_thermal_eff
  dsimp [P_thermal_eff]
  linarith

/-- Discrete 1-cocycle gauge invariance on a 4-link closed magnetic loop:
under any discrete scalar gauge transformation `A_{ij} ↦ A_{ij} + (χ_j - χ_i)`,
the vertex potentials `χ_i` telescope to zero around the cycle. -/
@[blueprint "thm:signals-discrete-four-cycle-gauge-invariance"
  (title := "Discrete 4-cycle 1-cocycle gauge invariance")
  (statement := /-- Adding vertex coboundary differences $\chi_j-\chi_i$ to each directed link
    $A_{ij}$ around a closed 4-cycle leaves the loop holonomy sum invariant. -/)
  (proof := /-- Telescope the vertex scalar potentials around the 4-cycle by ring algebra. -/)]
theorem discrete_four_cycle_gauge_invariance (A01 A12 A23 A30 χ0 χ1 χ2 χ3 : ℝ) :
    let A'_01 := A01 + (χ1 - χ0)
    let A'_12 := A12 + (χ2 - χ1)
    let A'_23 := A23 + (χ3 - χ2)
    let A'_30 := A30 + (χ0 - χ3)
    A'_01 + A'_12 + A'_23 + A'_30 = A01 + A12 + A23 + A30 := by
  intro A'_01 A'_12 A'_23 A'_30
  ring

end Signals.MHD
