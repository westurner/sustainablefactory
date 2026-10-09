import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Signals.Acoustics
import Signals.Applications
import Signals.Propagation
import Signals.Units

namespace Signals.MHD

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

end Signals.MHD
