import Architect
import Mathlib.Basic.Complex.Basic
import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Signals.Contracts
import Signals.IQ
import Signals.Propagation
import Signals.QISM

namespace Signals.Scattering

open Signals.IQ
open Signals.Contracts
open Signals.Geometry
open Signals.Propagation
open Signals.QISM
open Signals.Units

/-- A coherent incident/return observation represented by I/Q samples. -/
@[blueprint "def:signals-scattering-observation"
  (title := "Coherent incident and scattered I/Q observation")
  (statement := /-- An observation pairs an incident I/Q sample of positive squared norm
    $\lVert\psi_{\mathrm{in}}\rVert^2>0$ with a scattered I/Q sample $\psi_{\mathrm{out}}$. -/)]
structure Observation where
  incident : Sample
  incidentNormSq : ℝ
  incidentNormSq_pos : 0 < incidentNormSq
  incidentNormSqLaw : incidentNormSq = Complex.normSq incident.asComplex
  scattered : Sample

/-- A positive incident norm excludes a zero incident complex field. -/
@[blueprint "lem:signals-scattering-incident-ne-zero"
  (title := "Positive incident norm excludes zero incident field")
  (statement := /-- In any \texttt{Observation}, $\psi_{\mathrm{in}}\ne 0$. -/)
  (proof := /-- A zero incident field would force $\lVert\psi_{\mathrm{in}}\rVert^2=0$,
    contradicting $\lVert\psi_{\mathrm{in}}\rVert^2>0$. -/)
  (latexEnv := "lemma")]
lemma Observation.incident_ne_zero (observation : Observation) :
    observation.incident.asComplex ≠ 0 := by
  intro incident_zero
  have norm_zero : observation.incidentNormSq = 0 := by
    rw [observation.incidentNormSqLaw, incident_zero]
    simp
  linarith [observation.incidentNormSq_pos]

/-- The complex coherent scattering-amplitude ratio. -/
@[blueprint "def:signals-scattering-amplitude-ratio"
  (title := "Complex coherent scattering-amplitude ratio")
  (statement := /-- For an observation, define the complex scattering ratio
    $S=\psi_{\mathrm{out}}/\psi_{\mathrm{in}}$. -/)]
noncomputable def Observation.amplitudeRatio (observation : Observation) : ℂ :=
  observation.scattered.asComplex / observation.incident.asComplex

/-- The measured scattered-to-incident power ratio. -/
@[blueprint "def:signals-scattering-power-ratio"
  (title := "Scattered-to-incident power ratio")
  (statement := /-- Define the scattered power ratio
    $\lVert\psi_{\mathrm{out}}\rVert^2/\lVert\psi_{\mathrm{in}}\rVert^2$. -/)]
noncomputable def Observation.powerRatio (observation : Observation) : ℝ :=
  Complex.normSq observation.scattered.asComplex / observation.incidentNormSq

/-- Scattered power ratio is nonnegative. -/
@[blueprint "lem:signals-scattering-power-ratio-nonneg"
  (title := "Nonnegativity of scattered power ratio")
  (statement := /-- Every \texttt{Observation} has nonnegative scattered-to-incident power ratio. -/)
  (proof := /-- Divide $\lVert\psi_{\mathrm{out}}\rVert^2\ge 0$ by $\lVert\psi_{\mathrm{in}}\rVert^2>0$. -/)
  (latexEnv := "lemma")]
lemma Observation.powerRatio_nonnegative (observation : Observation) :
    0 ≤ observation.powerRatio := by
  unfold Observation.powerRatio
  exact div_nonneg (Complex.normSq_nonneg _) observation.incidentNormSq_pos.le

/-- A round-trip phase model with an explicit reference phase and unwrapped phase. -/
@[blueprint "def:signals-scattering-height-model"
  (title := "Round-trip scattering phase height model")
  (statement := /-- Associates wavenumber $k\ne 0$, reference phase $\phi_0$, height $h$,
    and unwrapped phase $\phi=\phi_0+2kh$. -/)]
structure HeightModel where
  waveNumber : ℝ
  waveNumber_ne_zero : waveNumber ≠ 0
  referencePhase : ℝ
  height : ℝ
  unwrappedPhase : ℝ
  roundTripLaw : unwrappedPhase = referencePhase + 2 * waveNumber * height

/-- Recover height from a reference-subtracted unwrapped scattering phase. -/
@[blueprint "def:signals-scattering-reconstruct-height"
  (title := "Inverse height reconstruction from unwrapped scattering phase")
  (statement := /-- Reconstruct target height as $(\phi-\phi_0)/(2k)$. -/)]
noncomputable def HeightModel.reconstructHeight (model : HeightModel) : ℝ :=
  (model.unwrappedPhase - model.referencePhase) / (2 * model.waveNumber)

/-- The height reconstruction is exact under the round-trip phase model. -/
@[blueprint "lem:signals-scattering-reconstruct-height-eq"
  (title := "Exact round-trip phase-height inversion")
  (statement := /-- Under $\phi=\phi_0+2kh$ with $k\ne 0$, $(\phi-\phi_0)/(2k)=h$. -/)
  (proof := /-- Substitute the round-trip phase law and clear $2k\ne 0$. -/)
  (latexEnv := "lemma")]
lemma HeightModel.reconstructHeight_eq_height (model : HeightModel) :
    model.reconstructHeight = model.height := by
  unfold HeightModel.reconstructHeight
  rw [model.roundTripLaw]
  field_simp [model.waveNumber_ne_zero]
  ring

/-- A scattered-power measurement with a calibrated incident flux. -/
@[blueprint "def:signals-scattering-cross-section-measurement"
  (title := "Calibrated scattering cross-section measurement")
  (statement := /-- Relates positive incident flux $\Phi_{\mathrm{in}}>0$, scattered power
    $P_{\mathrm{scat}}\ge 0$, and cross section $\sigma\ge 0$ via $P_{\mathrm{scat}}=\Phi_{\mathrm{in}}\sigma$. -/)]
structure CrossSectionMeasurement where
  incidentFlux : ℝ
  incidentFlux_pos : 0 < incidentFlux
  scatteredPower : ℝ
  scatteredPower_nonnegative : 0 ≤ scatteredPower
  crossSection : ℝ
  crossSection_nonnegative : 0 ≤ crossSection
  powerLaw : scatteredPower = incidentFlux * crossSection

/-- Cross section is determined by scattered power and incident flux. -/
@[blueprint "lem:signals-scattering-cross-section-ratio"
  (title := "Scattering cross-section inversion from scattered power and flux")
  (statement := /-- In any \texttt{CrossSectionMeasurement}, $\sigma=P_{\mathrm{scat}}/\Phi_{\mathrm{in}}$. -/)
  (proof := /-- Substitute $P_{\mathrm{scat}}=\Phi_{\mathrm{in}}\sigma$ and divide by $\Phi_{\mathrm{in}}>0$. -/)
  (latexEnv := "lemma")]
lemma CrossSectionMeasurement.crossSection_eq_ratio
    (measurement : CrossSectionMeasurement) :
    measurement.crossSection = measurement.scatteredPower / measurement.incidentFlux := by
  rw [measurement.powerLaw]
  field_simp [measurement.incidentFlux_pos.ne']

/-- A measured quantity with an explicit residual and tolerance. -/
@[blueprint "def:signals-scattering-residual-measurement"
  (title := "Scattering residual measurement record")
  (statement := /-- Records predicted value, observed value, nonnegative tolerance, and
    residual $r=\mathrm{observed}-\mathrm{predicted}$. -/)]
structure ResidualMeasurement where
  predicted : ℝ
  observed : ℝ
  residual : ℝ
  tolerance : ℝ
  tolerance_nonnegative : 0 ≤ tolerance
  residualLaw : residual = observed - predicted

/-- A residual is within the calibrated uncertainty. -/
@[blueprint "def:signals-scattering-residual-consistent"
  (title := "Residual consistency within calibrated tolerance")
  (statement := /-- A residual measurement is consistent when $|r|\le\tau$. -/)]
def ResidualMeasurement.consistent (measurement : ResidualMeasurement) : Prop :=
  |measurement.residual| ≤ measurement.tolerance

/-- An out-of-tolerance residual is an anomaly candidate, not a diagnosis. -/
@[blueprint "def:signals-scattering-anomaly-candidate"
  (title := "Out-of-tolerance residual anomaly candidate")
  (statement := /-- Marks a residual measurement with $|r|>\tau$ as an anomaly candidate. -/)]
def ResidualMeasurement.anomalyCandidate (measurement : ResidualMeasurement) : Prop :=
  ¬measurement.consistent

/-- The residual and anomaly predicates expose their intended inequalities. -/
@[blueprint "lem:signals-scattering-consistent-iff"
  (title := "Characterization of residual consistency")
  (statement := /-- Consistency holds if and only if $|r|\le\tau$. -/)
  (proof := /-- Definitional equivalence. -/)
  (latexEnv := "lemma")]
lemma ResidualMeasurement.consistent_iff (measurement : ResidualMeasurement) :
    measurement.consistent ↔ |measurement.residual| ≤ measurement.tolerance := by
  rfl

/-- Characterization of an out-of-tolerance scattering residual anomaly candidate. -/
@[blueprint "lem:signals-scattering-anomaly-iff"
  (title := "Characterization of residual anomaly candidate")
  (statement := /-- An anomaly candidate occurs if and only if $\neg(|r|\le\tau)$. -/)
  (proof := /-- Definitional equivalence. -/)
  (latexEnv := "lemma")]
lemma ResidualMeasurement.anomalyCandidate_iff (measurement : ResidualMeasurement) :
    measurement.anomalyCandidate ↔ ¬|measurement.residual| ≤ measurement.tolerance := by
  rfl

/-- Adapt a scattering residual to the shared measurement contract. -/
@[blueprint "def:signals-scattering-to-residual-contract"
  (title := "Promotion of a consistent scattering residual to ResidualContract")
  (statement := /-- Packages a consistent \texttt{ResidualMeasurement} as a verified
    \texttt{Signals.Contracts.ResidualContract}. -/)]
def ResidualMeasurement.toResidualContract (measurement : ResidualMeasurement)
  (consistent : measurement.consistent) :
    ResidualContract ℝ ℝ ℝ :=
  { measured := measurement.observed
    predicted := measurement.predicted
    residual := measurement.residual
    residualFunction := fun observed predicted => observed - predicted
    residualLaw := measurement.residualLaw
    magnitude := abs
    magnitude_nonnegative := abs_nonneg _
    tolerance := measurement.tolerance
    tolerance_nonnegative := measurement.tolerance_nonnegative
    withinTolerance := by
      exact measurement.consistent_iff.mp consistent }

/-- A nonnegative signal and positive noise power define a linear SNR model. -/
@[blueprint "def:signals-scattering-snr"
  (title := "Linear scattering signal-to-noise record")
  (statement := /-- Pairs nonnegative signal power $P_s\ge 0$ with positive noise power $P_n>0$. -/)]
structure SignalToNoise where
  signalPower : ℝ
  signalPower_nonnegative : 0 ≤ signalPower
  noisePower : ℝ
  noisePower_pos : 0 < noisePower

/-- Signal-to-noise ratio as a dimensionless power ratio. -/
@[blueprint "def:signals-scattering-snr-ratio"
  (title := "Dimensionless scattering signal-to-noise ratio")
  (statement := /-- Defines $\mathrm{SNR}=P_s/P_n$. -/)]
noncomputable def SignalToNoise.ratio (measurement : SignalToNoise) : ℝ :=
  measurement.signalPower / measurement.noisePower

/-- Signal-to-noise ratio is nonnegative. -/
@[blueprint "lem:signals-scattering-snr-nonneg"
  (title := "Nonnegativity of signal-to-noise ratio")
  (statement := /-- For any \texttt{SignalToNoise} record, $\mathrm{SNR}\ge 0$. -/)
  (proof := /-- Divide $P_s\ge 0$ by $P_n>0$. -/)
  (latexEnv := "lemma")]
lemma SignalToNoise.ratio_nonnegative (measurement : SignalToNoise) :
    0 ≤ measurement.ratio := by
  unfold SignalToNoise.ratio
  exact div_nonneg measurement.signalPower_nonnegative measurement.noisePower_pos.le

/-- A scattering-metrology record joins coherent data, height reconstruction,
and an independent residual measurement. -/
@[blueprint "def:signals-scattering-metrology-record"
  (title := "Combined scattering metrology record")
  (statement := /-- Combines an I/Q \texttt{Observation}, a phase \texttt{HeightModel}, and a
    \texttt{ResidualMeasurement}. -/)]
structure MetrologyRecord where
  observation : Observation
  heightModel : HeightModel
  residual : ResidualMeasurement

/-- A metrology record is accepted only when its residual is consistent. -/
@[blueprint "def:signals-scattering-metrology-accepted"
  (title := "Metrology record acceptance predicate")
  (statement := /-- A metrology record is accepted when its residual measurement is within tolerance. -/)]
def MetrologyRecord.accepted (record : MetrologyRecord) : Prop :=
  record.residual.consistent

/-- Acceptance is exactly the residual tolerance condition. -/
@[blueprint "lem:signals-scattering-metrology-accepted-iff"
  (title := "Characterization of metrology record acceptance")
  (statement := /-- Acceptance holds if and only if $|r|\le\tau$. -/)
  (proof := /-- Definitional equivalence. -/)
  (latexEnv := "lemma")]
lemma MetrologyRecord.accepted_iff (record : MetrologyRecord) :
    record.accepted ↔ |record.residual.residual| ≤ record.residual.tolerance := by
  rfl

/-- A passive complex material response at one measured frequency. -/
@[blueprint "def:signals-scattering-material-transfer"
  (title := "Passive complex material transfer function")
  (statement := /-- Records a complex transfer amplitude $H(\omega)$ at frequency $f>0$ with
    transmitted power ratio $0\le |H(\omega)|^2\le 1$. -/)]
structure MaterialTransferFunction where
  frequency : Frequency
  frequency_pos : 0 < frequency.hz
  transfer : ℂ
  transmittedPowerRatio : ℝ
  transmittedPowerRatio_nonnegative : 0 ≤ transmittedPowerRatio
  transmittedPowerRatio_le_one : transmittedPowerRatio ≤ 1
  powerLaw : transmittedPowerRatio = Complex.normSq transfer

/-- The material transfer function exposes its complex power law. -/
@[blueprint "lem:signals-scattering-material-power-law"
  (title := "Material transmitted power equals squared transfer modulus")
  (statement := /-- For any \texttt{MaterialTransferFunction}, the transmitted power ratio
    equals $|H(\omega)|^2$. -/)
  (proof := /-- Apply \texttt{powerLaw}. -/)
  (latexEnv := "lemma")]
lemma MaterialTransferFunction.power_holds
    (response : MaterialTransferFunction) :
    response.transmittedPowerRatio = Complex.normSq response.transfer :=
  response.powerLaw

/-- Frequency-dependent bulk attenuation with an explicit exponential law. -/
@[blueprint "def:signals-scattering-frequency-attenuation"
  (title := "Frequency-dependent exponential bulk attenuation")
  (statement := /-- Models power attenuation $\exp(-2\alpha d)$ for $\alpha\ge 0$ and distance $d\ge 0$. -/)]
structure FrequencyDependentAttenuation where
  frequency : Frequency
  frequency_pos : 0 < frequency.hz
  attenuationPerLength : ℝ
  attenuation_nonnegative : 0 ≤ attenuationPerLength
  distance : Length
  distance_nonnegative : 0 ≤ distance.meters
  factor : ℝ
  factorLaw : factor =
    Real.exp (-2 * attenuationPerLength * distance.meters)

/-- Frequency-dependent attenuation is nonnegative. -/
@[blueprint "lem:signals-scattering-attenuation-nonneg"
  (title := "Nonnegativity of exponential bulk attenuation")
  (statement := /-- Every \texttt{FrequencyDependentAttenuation} factor satisfies $\mathrm{factor}\ge 0$. -/)
  (proof := /-- Exponential of any real argument is positive. -/)
  (latexEnv := "lemma")]
lemma FrequencyDependentAttenuation.factor_nonnegative
    (attenuation : FrequencyDependentAttenuation) :
    0 ≤ attenuation.factor := by
  rw [attenuation.factorLaw]
  exact (Real.exp_pos _).le

/-- Nonnegative frequency-dependent attenuation cannot amplify power. -/
@[blueprint "lem:signals-scattering-attenuation-le-one"
  (title := "Passive upper bound on exponential bulk attenuation")
  (statement := /-- For $\alpha\ge 0$ and $d\ge 0$, $\exp(-2\alpha d)\le 1$. -/)
  (proof := /-- Since $-2\alpha d\le 0$, $\exp(-2\alpha d)\le\exp(0)=1$. -/)
  (latexEnv := "lemma")]
lemma FrequencyDependentAttenuation.factor_le_one
    (attenuation : FrequencyDependentAttenuation) :
    attenuation.factor ≤ 1 := by
  rw [attenuation.factorLaw, ← Real.exp_zero, Real.exp_le_exp]
  nlinarith [attenuation.attenuation_nonnegative,
    attenuation.distance_nonnegative]

/-- Finite speckle covariance metadata for a grid of observations. -/
@[blueprint "def:signals-scattering-speckle-covariance"
  (title := "Finite speckle covariance matrix record")
  (statement := /-- A symmetric $N\times N$ covariance matrix ($N>0$) with nonnegative diagonal variances. -/)]
structure SpeckleCovariance (sampleCount : ℕ) where
  sampleCount_positive : 0 < sampleCount
  covariance : Matrix (Fin sampleCount) (Fin sampleCount) ℝ
  covariance_symmetric : ∀ row column,
    covariance row column = covariance column row
  covariance_diagonal_nonnegative : ∀ index,
    0 ≤ covariance index index

/-- A speckle covariance record exposes its symmetry law. -/
@[blueprint "lem:signals-scattering-speckle-symmetric"
  (title := "Symmetry of speckle covariance matrix")
  (statement := /-- For all indices $i,j$, $C_{ij}=C_{ji}$. -/)
  (proof := /-- Apply \texttt{covariance\_symmetric}. -/)
  (latexEnv := "lemma")]
lemma SpeckleCovariance.symmetric
    {sampleCount : ℕ} (covariance : SpeckleCovariance sampleCount)
    (row column : Fin sampleCount) :
    covariance.covariance row column = covariance.covariance column row :=
  covariance.covariance_symmetric row column

/-- A speckle covariance record exposes nonnegative diagonal variance. -/
@[blueprint "lem:signals-scattering-speckle-diag-nonneg"
  (title := "Nonnegativity of diagonal speckle variances")
  (statement := /-- For every sample index $i$, $C_{ii}\ge 0$. -/)
  (proof := /-- Apply \texttt{covariance\_diagonal\_nonnegative}. -/)
  (latexEnv := "lemma")]
lemma SpeckleCovariance.diagonal_nonnegative
    {sampleCount : ℕ} (covariance : SpeckleCovariance sampleCount)
    (index : Fin sampleCount) :
    0 ≤ covariance.covariance index index :=
  covariance.covariance_diagonal_nonnegative index

/-- A finite scattering grid with residual uncertainty and speckle metadata. -/
@[blueprint "def:signals-scattering-grid-metrology"
  (title := "Two-dimensional scattering grid metrology record")
  (statement := /-- Joins an $M\times N$ grid of observations and residual measurements with
    an $(MN)\times(MN)$ speckle covariance matrix. -/)]
structure GridMetrologyRecord (width height : ℕ) where
  width_positive : 0 < width
  height_positive : 0 < height
  samples : Fin width → Fin height → Observation
  residuals : Fin width → Fin height → ResidualMeasurement
  covariance : SpeckleCovariance (width * height)

/-- A finite grid contains at least one observation in each dimension. -/
@[blueprint "lem:signals-scattering-grid-dims-pos"
  (title := "Positivity of scattering grid dimensions")
  (statement := /-- Every \texttt{GridMetrologyRecord} has positive width and height. -/)
  (proof := /-- Pair \texttt{width\_positive} and \texttt{height\_positive}. -/)
  (latexEnv := "lemma")]
lemma GridMetrologyRecord.dimensions_positive
    {width height : ℕ} (record : GridMetrologyRecord width height) :
    0 < width ∧ 0 < height :=
  ⟨record.width_positive, record.height_positive⟩

/-- Every grid residual retains its calibrated uncertainty predicate. -/
@[blueprint "def:signals-scattering-grid-consistent"
  (title := "Gridwise scattering residual consistency")
  (statement := /-- A grid record is consistent when every cell residual satisfies $|r_{ij}|\le\tau_{ij}$. -/)]
def GridMetrologyRecord.consistent
    {width height : ℕ} (record : GridMetrologyRecord width height) : Prop :=
  ∀ row column, (record.residuals row column).consistent

/-- A grid is consistent when each retained residual is within tolerance. -/
@[blueprint "lem:signals-scattering-grid-consistent-iff"
  (title := "Characterization of gridwise residual consistency")
  (statement := /-- Grid consistency holds if and only if every cell satisfies $|r_{ij}|\le\tau_{ij}$. -/)
  (proof := /-- Unfold cellwise \texttt{consistent\_iff}. -/)
  (latexEnv := "lemma")]
lemma GridMetrologyRecord.consistent_iff
    {width height : ℕ} (record : GridMetrologyRecord width height) :
    record.consistent ↔ ∀ row column,
      |(record.residuals row column).residual| ≤
        (record.residuals row column).tolerance := by
  constructor
  · intro consistent row column
    exact (record.residuals row column).consistent_iff.mp
      (consistent row column)
  · intro consistent row column
    exact (record.residuals row column).consistent_iff.mpr
      (consistent row column)

/-! ## Quantum Inverse Scattering (QISM) Integration & Inverse Reconstruction

Integrates the algebraic QISM and Grassmannian Bethe ansatz structures from
`Signals.QISM` with the scattering metrology and inverse-reconstruction
contracts in `Signals.Scattering`:
1. Exact inverse reconstruction of the spectral rapidity difference $\delta(u,v) = u - v$
   and Yang coupling constant $\eta$ from the symmetric (triplet) and antisymmetric
   (singlet) $R$-matrix channel eigenvalues.
2. Unitary two-body scattering probability conservation
   $T_{\mathrm{prob}}(u,v;\eta) + R_{\mathrm{prob}}(u,v;\eta) = 1$ for Yang's
   rational $R$-matrix.
3. Inverse monodromy reconstruction of the complementary diagonal entry
   $D(u) = t(u) - A(u)$ and off-diagonal magnon creation/annihilation product
   $B(u) C(u) = A(u) D(u) - \Delta_{01}(T(u))$ from the transfer trace and
   $2 \times 2$ Grassmannian minor.
4. Embedding Baxter's $TQ$ difference-equation residual (`baxterTQResidual`) into
   `ResidualMeasurement`, proving that three-point Casorati Wronskian solutions
   on $Gr(2,4)$ are automatically `.consistent` for all tolerances $\tau \ge 0$,
   while off-shell Bethe-root violations beyond $\tau$ trigger `.anomalyCandidate`.
-/

/-- Reconstruct the QISM spectral rapidity difference $\delta(u, v) = u - v$ from the
symmetric (triplet) and antisymmetric (singlet) Yang $R$-matrix channel weights. -/
@[blueprint "def:signals-scattering-reconstruct-spectral-diff"
  (title := "Inverse reconstruction of spectral rapidity difference from R-matrix channels")
  (statement := /-- Given triplet weight $w_{\mathrm{sym}}$ and singlet weight $w_{\mathrm{anti}}$,
    reconstruct the spectral difference as $(w_{\mathrm{sym}}+w_{\mathrm{anti}})/2$. -/)]
noncomputable def reconstructSpectralDiff (w_sym w_anti : ℝ) : ℝ :=
  (w_sym + w_anti) / 2

/-- Reconstruct the QISM coupling constant $\eta$ from the symmetric (triplet) and
antisymmetric (singlet) Yang $R$-matrix channel weights. -/
@[blueprint "def:signals-scattering-reconstruct-yang-coupling"
  (title := "Inverse reconstruction of Yang coupling constant from R-matrix channels")
  (statement := /-- Given triplet weight $w_{\mathrm{sym}}$ and singlet weight $w_{\mathrm{anti}}$,
    reconstruct the coupling constant as $(w_{\mathrm{sym}}-w_{\mathrm{anti}})/2$. -/)]
noncomputable def reconstructYangCoupling (w_sym w_anti : ℝ) : ℝ :=
  (w_sym - w_anti) / 2

/-- Inverse spectral reconstruction recovers the exact rapidity difference
`spectralDiff u v = u - v` and coupling `η` from `yangSymmetricWeight` and
`yangAntisymmetricWeight`. -/
@[blueprint "thm:signals-scattering-reconstruct-yang-parameters"
  (title := "Exact inverse recovery of spectral difference and coupling from R-matrix eigenvalues")
  (statement := /-- For any rapidities $u,v$ and coupling $\eta$,
    $\operatorname{reconstructSpectralDiff}(w_{\mathrm{sym}},w_{\mathrm{anti}})=\delta(u,v)$ and
    $\operatorname{reconstructYangCoupling}(w_{\mathrm{sym}},w_{\mathrm{anti}})=\eta$. -/)
  (proof := /-- Unfold the channel weights and simplify linear combinations. -/)]
theorem reconstruct_yang_parameters (u v η : ℝ) :
    reconstructSpectralDiff (yangSymmetricWeight u v η) (yangAntisymmetricWeight u v η) =
        spectralDiff u v ∧
      reconstructYangCoupling (yangSymmetricWeight u v η) (yangAntisymmetricWeight u v η) = η := by
  constructor
  · unfold reconstructSpectralDiff yangSymmetricWeight yangAntisymmetricWeight
    ring
  · unfold reconstructYangCoupling yangSymmetricWeight yangAntisymmetricWeight
    ring

/-- Rational $R$-matrix transmission probability
$T_{\mathrm{prob}}(u, v; \eta) = (u - v)^2 / ((u - v)^2 + \eta^2)$. -/
@[blueprint "def:signals-scattering-yang-transmission-prob"
  (title := "Yang rational R-matrix transmission probability")
  (statement := /-- For rapidities $u,v$ and coupling $\eta$, the two-body transmission
    probability is $T_{\mathrm{prob}}=\delta(u,v)^2/(\delta(u,v)^2+\eta^2)$. -/)]
noncomputable def yangTransmissionProb (u v η : ℝ) : ℝ :=
  (spectralDiff u v) ^ 2 / ((spectralDiff u v) ^ 2 + η ^ 2)

/-- Rational $R$-matrix reflection probability
$R_{\mathrm{prob}}(u, v; \eta) = \eta^2 / ((u - v)^2 + \eta^2)$. -/
@[blueprint "def:signals-scattering-yang-reflection-prob"
  (title := "Yang rational R-matrix reflection probability")
  (statement := /-- For rapidities $u,v$ and coupling $\eta$, the two-body reflection
    probability is $R_{\mathrm{prob}}=\eta^2/(\delta(u,v)^2+\eta^2)$. -/)]
noncomputable def yangReflectionProb (u v η : ℝ) : ℝ :=
  η ^ 2 / ((spectralDiff u v) ^ 2 + η ^ 2)

/-- **Unitary Two-Body Scattering Flux Conservation**:
Whenever $(u - v)^2 + \eta^2 \neq 0$, the Yang $R$-matrix transmission and reflection
probabilities are nonnegative and sum identically to $1$. -/
@[blueprint "thm:signals-scattering-yang-unitary-partition"
  (title := "Unitary transmission-plus-reflection probability conservation for Yang's R-matrix")
  (statement := /-- When $\delta(u,v)^2+\eta^2\ne 0$, $0\le T_{\mathrm{prob}}$,
    $0\le R_{\mathrm{prob}}$, and $T_{\mathrm{prob}}(u,v;\eta)+R_{\mathrm{prob}}(u,v;\eta)=1$. -/)
  (proof := /-- Nonnegativity follows from squared numerators and denominators; the sum clears
    $\delta(u,v)^2+\eta^2\ne 0$. -/)]
theorem yang_scattering_probability_conservation
    (u v η : ℝ) (h_denom : (spectralDiff u v) ^ 2 + η ^ 2 ≠ 0) :
    0 ≤ yangTransmissionProb u v η ∧
      0 ≤ yangReflectionProb u v η ∧
      yangTransmissionProb u v η + yangReflectionProb u v η = 1 := by
  have h_pos_denom : 0 ≤ (spectralDiff u v) ^ 2 + η ^ 2 :=
    add_nonneg (sq_nonneg _) (sq_nonneg _)
  refine ⟨div_nonneg (sq_nonneg _) h_pos_denom, div_nonneg (sq_nonneg _) h_pos_denom, ?_⟩
  unfold yangTransmissionProb yangReflectionProb
  rw [← add_div, div_self h_denom]

/-- Reconstruct the complementary diagonal monodromy entry $D(u) = t(u) - A(u)$
from the auxiliary transfer trace $t(u)$ and forward vacuum entry $A(u)$, and
recover the off-diagonal magnon creation/annihilation product
$B(u) C(u) = A(u) D(u) - \Delta_{01}(T(u))$ from the $2 \times 2$ Grassmannian minor. -/
@[blueprint "thm:signals-scattering-monodromy-inversion"
  (title := "Inverse monodromy entry and off-diagonal product recovery from trace and Pluecker minor")
  (statement := /-- For any $2\times 2$ monodromy matrix $T=\begin{pmatrix} A & B \\ C & D \end{pmatrix}$,
    $D = T.\mathrm{transferTrace} - A$ and $B C = A D - \Delta_{01}(T)$. -/)
  (proof := /-- Unfold \texttt{transferTrace}, \texttt{classicalDet\_eq\_twoRowMinor}, and close by ring algebra. -/)]
theorem reconstruct_monodromy_from_trace_and_minor (T : MonodromyMatrix2) :
    T.transferTrace - T.A = T.D ∧
      T.A * T.D - twoRowMinor T.toMatrix 0 1 = T.B * T.C := by
  rw [← T.classicalDet_eq_twoRowMinor]
  unfold MonodromyMatrix2.transferTrace MonodromyMatrix2.classicalDet
  constructor <;> ring

/-- Package Baxter's $TQ$ difference-equation residual into a calibrated
`Scattering.ResidualMeasurement`, where `observed = T * Q_u` and
`predicted = a * Q_minus_eta + d * Q_plus_eta`. -/
@[blueprint "def:signals-scattering-baxter-tq-measurement"
  (title := "Calibrated scattering residual measurement for Baxter's TQ equation")
  (statement := /-- Packages observed transfer action $T\,Q(u)$ and predicted shifted sum
    $a\,Q(u-\eta)+d\,Q(u+\eta)$ into a \texttt{ResidualMeasurement} whose residual is
    \texttt{baxterTQResidual}. -/)]
def baxterTQResidualMeasurement
    (T a d Q_u Q_minus_eta Q_plus_eta tolerance : ℝ)
    (tolerance_nonnegative : 0 ≤ tolerance) : ResidualMeasurement :=
  { predicted := a * Q_minus_eta + d * Q_plus_eta
    observed := T * Q_u
    residual := baxterTQResidual T a d Q_u Q_minus_eta Q_plus_eta
    tolerance := tolerance
    tolerance_nonnegative := tolerance_nonnegative
    residualLaw := rfl }

/-- Any three-point Casorati Wronskian solution on $Gr(2,4)$ yields a strictly
consistent `ResidualMeasurement` (`|residual| ≤ tolerance`) for every nonnegative
tolerance. -/
@[blueprint "thm:signals-scattering-wronskian-tq-consistent"
  (title := "Grassmannian Casorati Wronskian TQ solution is metrologically consistent")
  (statement := /-- For any Baxter pair $(Q_+,Q_-)$, rapidity $u$, shift $\eta$, and tolerance
    $\tau\ge 0$, the Wronskian-parameterized \texttt{baxterTQResidualMeasurement} is consistent. -/)
  (proof := /-- Rewrite the residual to $0$ using \texttt{baxterTQResidual\_wronskian\_zero}
    and use $0\le\tau$. -/)]
theorem baxterTQResidualMeasurement_wronskian_consistent
    (Q_plus Q_minus : ℝ → ℝ) (u η tolerance : ℝ)
    (tolerance_nonnegative : 0 ≤ tolerance) :
    (baxterTQResidualMeasurement
      (casoratiWronskian Q_plus Q_minus (u - η) (u + η))
      (casoratiWronskian Q_plus Q_minus u (u + η))
      (casoratiWronskian Q_plus Q_minus (u - η) u)
      (Q_plus u) (Q_plus (u - η)) (Q_plus (u + η))
      tolerance tolerance_nonnegative).consistent := by
  rw [ResidualMeasurement.consistent_iff]
  change |baxterTQResidual
      (casoratiWronskian Q_plus Q_minus (u - η) (u + η))
      (casoratiWronskian Q_plus Q_minus u (u + η))
      (casoratiWronskian Q_plus Q_minus (u - η) u)
      (Q_plus u) (Q_plus (u - η)) (Q_plus (u + η))| ≤ tolerance
  rw [baxterTQResidual_wronskian_zero, abs_zero]
  exact tolerance_nonnegative

/-- At a candidate Bethe root ($Q(u_m) = 0$), if the Bethe Ansatz Equation residual
$|a Q(u_m - \eta) + d Q(u_m + \eta)|$ exceeds `tolerance`, then
`baxterTQResidualMeasurement` flags an off-shell `.anomalyCandidate`. -/
@[blueprint "thm:signals-scattering-offshell-bethe-anomaly"
  (title := "Off-shell Bethe-root residual exceeding tolerance flags an anomaly candidate")
  (statement := /-- If $Q(u_m)=0$ and $|a\,Q(u_m-\eta)+d\,Q(u_m+\eta)|>\tau$, then
    \texttt{baxterTQResidualMeasurement} is an \texttt{anomalyCandidate}. -/)
  (proof := /-- At $Q(u_m)=0$, $|r|=|-(a\,Q(u_m-\eta)+d\,Q(u_m+\eta))|=|a\,Q(u_m-\eta)+d\,Q(u_m+\eta)|>\tau$. -/)]
theorem baxterTQResidualMeasurement_offShell_anomaly
    (T a d Q_minus_eta Q_plus_eta tolerance : ℝ)
    (tolerance_nonnegative : 0 ≤ tolerance)
    (h_off_shell : tolerance < |a * Q_minus_eta + d * Q_plus_eta|) :
    (baxterTQResidualMeasurement T a d 0 Q_minus_eta Q_plus_eta
      tolerance tolerance_nonnegative).anomalyCandidate := by
  rw [ResidualMeasurement.anomalyCandidate_iff, not_le]
  change tolerance < |baxterTQResidual T a d 0 Q_minus_eta Q_plus_eta|
  have h_res :
      baxterTQResidual T a d 0 Q_minus_eta Q_plus_eta =
        - (a * Q_minus_eta + d * Q_plus_eta) := by
    unfold baxterTQResidual
    ring
  rw [h_res, abs_neg]
  exact h_off_shell

/-! ## Inelastic Scattering: Inverse Compton, Stokes/Anti-Stokes Raman, and $Gr_{\mathbb{C}}(2,4)$ Boundaries

Formalizes the algebraic and metrological laws of two fundamental inelastic
scattering processes and their exact relation to $Gr_{\mathbb{C}}(2,4)$ Plücker
channel invariants:
1. **Inverse Compton Scattering (ICS)**:
   - Collinear relativistic Thomson upshift factor
     $\frac{\omega_{\max}^{\mathrm{ICS}}}{\omega_0} = \frac{1 + \beta}{1 - \beta} = \frac{|w_A^{\mathbb{C}}|^2}{|w_B^{\mathbb{C}}|^2}$,
   - Klein–Nishina quantum recoil suppression
     $\frac{\omega_{\mathrm{KN}}^{\mathrm{ICS}}}{\omega_0} = \frac{(1 + \beta)/(1 - \beta)}{1 + \epsilon_{\mathrm{rec}}} < \frac{1 + \beta}{1 - \beta}$
     for $\epsilon_{\mathrm{rec}} = \frac{2\gamma\hbar\omega_0}{m_e c^2}(1 + \beta) > 0$,
     identifying the explicit rest-mass recoil scale that lies beyond scale-free
     projective $Gr_{\mathbb{C}}(2,4)$.
2. **Stokes & Anti-Stokes Raman Scattering**:
   - Stokes ($\omega_S = \omega_L - \Omega_v$) and anti-Stokes ($\omega_{AS} = \omega_L + \Omega_v$)
     sidebands with normalized shift $\delta_R = \Omega_v / \omega_L$,
   - Exact inverse recovery of pump frequency $\omega_L = (\omega_{AS} + \omega_S)/2$
     and vibrational phonon frequency $\Omega_v = (\omega_{AS} - \omega_S)/2$,
   - Plücker channel ratio $\frac{\omega_{AS}}{\omega_S} = \frac{1 + \delta_R}{1 - \delta_R}$
     and covariance determinant product $\omega_S \omega_{AS} = \omega_L^2(1 - \delta_R^2)$,
   - Thermal Bose–Einstein anti-Stokes/Stokes intensity ratio
     $\frac{I_{AS}}{I_S} = \left(\frac{\omega_L + \Omega_v}{\omega_L - \Omega_v}\right)^4 \exp\!\left(-\frac{\hbar\Omega_v}{k_B T}\right)$,
     identifying spontaneous vacuum fluctuations and irreversible thermal bath
     populations as the open-system boundary beyond unitary $Gr_{\mathbb{C}}(2,4)$.
-/

/-- Head-on relativistic Inverse Compton frequency upshift ratio in the Thomson
(negligible-recoil) regime:
$\frac{\omega_{\max}^{\mathrm{ICS}}}{\omega_0} = \frac{1 + \beta}{1 - \beta}$. -/
@[blueprint "def:signals-scattering-inverse-compton-doppler"
  (title := "Relativistic Inverse Compton Thomson frequency upshift ratio")
  (statement := /-- For reduced velocity $\beta = v/c$, define the head-on Thomson
    Inverse Compton frequency upshift ratio $\frac{1+\beta}{1-\beta}$. -/)]
noncomputable def inverseComptonDopplerRatio (β : ℝ) : ℝ :=
  (1 + β) / (1 - β)

/-- Relativistic Inverse Compton frequency upshift ratio with dimensionless
Klein–Nishina quantum recoil parameter $\epsilon_{\mathrm{rec}} \ge 0$:
$\frac{\omega_{\mathrm{KN}}^{\mathrm{ICS}}}{\omega_0} = \frac{(1 + \beta)/(1 - \beta)}{1 + \epsilon_{\mathrm{rec}}}$. -/
@[blueprint "def:signals-scattering-inverse-compton-klein-nishina"
  (title := "Klein-Nishina recoil-corrected Inverse Compton frequency ratio")
  (statement := /-- For reduced velocity $\beta$ and dimensionless quantum recoil parameter
    $\epsilon_{\mathrm{rec}}$, define $\frac{(1+\beta)/(1-\beta)}{1+\epsilon_{\mathrm{rec}}}$. -/)]
noncomputable def inverseComptonKleinNishinaRatio (β ε_rec : ℝ) : ℝ :=
  inverseComptonDopplerRatio β / (1 + ε_rec)

/-- **Inverse Compton Thomson Upshift, Plücker Channel Ratio, and Klein–Nishina Recoil Suppression**:
For subluminal $\beta \in [0, 1)$ and quantum recoil parameter $\epsilon_{\mathrm{rec}} > 0$:
1. The Thomson upshift ratio satisfies $1 \le \frac{1+\beta}{1-\beta}$,
2. Clearing the Lorentz denominator $(1 - \beta^2)$ gives
   $(1 - \beta^2)\,\operatorname{inverseComptonDopplerRatio}(\beta) = (1 + \beta)^2$
   (i.e. $\omega_{\max}^{\mathrm{ICS}}/\omega_0 = \gamma^2(1+\beta)^2$),
3. At zero recoil ($\epsilon_{\mathrm{rec}} = 0$), the Klein–Nishina ratio reduces
   identically to the scale-free $Gr_{\mathbb{C}}(2,4)$ Plücker channel ratio
   $\frac{1+\beta}{1-\beta}$, and
4. For any positive quantum recoil $\epsilon_{\mathrm{rec}} > 0$ (which introduces the
   electron rest-mass scale $m_e c^2$ outside projective $Gr_{\mathbb{C}}(2,4)$),
   the recoil-corrected upshift is strictly smaller than the Thomson ratio. -/
@[blueprint "thm:signals-scattering-inverse-compton-identities"
  (title := "Inverse Compton Thomson upshift and Klein-Nishina recoil suppression theorem")
  (statement := /-- For $0\le\beta<1$ and $\epsilon_{\mathrm{rec}}>0$:
    (1) $1\le\operatorname{inverseComptonDopplerRatio}(\beta)$,
    (2) $(1-\beta^2)\operatorname{inverseComptonDopplerRatio}(\beta)=(1+\beta)^2$,
    (3) $\operatorname{inverseComptonKleinNishinaRatio}(\beta,0)=\operatorname{inverseComptonDopplerRatio}(\beta)$, and
    (4) $\operatorname{inverseComptonKleinNishinaRatio}(\beta,\epsilon_{\mathrm{rec}}) <
    \operatorname{inverseComptonDopplerRatio}(\beta)$. -/)
  (proof := /-- Clear $1-\beta>0$ and $1+\epsilon_{\mathrm{rec}}>1$ by field simplification and linear arithmetic. -/)]
theorem inverseCompton_thomson_and_recoil_identities
    (β ε_rec : ℝ) (hβ_nonneg : 0 ≤ β) (hβ_lt : β < 1) (hε_pos : 0 < ε_rec) :
    1 ≤ inverseComptonDopplerRatio β ∧
      (1 - β ^ 2) * inverseComptonDopplerRatio β = (1 + β) ^ 2 ∧
      inverseComptonKleinNishinaRatio β 0 = inverseComptonDopplerRatio β ∧
      inverseComptonKleinNishinaRatio β ε_rec < inverseComptonDopplerRatio β := by
  have h1m : 0 < 1 - β := by linarith
  have h1p : 0 < 1 + β := by linarith
  have h_dop_pos : 0 < inverseComptonDopplerRatio β := by
    unfold inverseComptonDopplerRatio
    exact div_pos h1p h1m
  have h_ge_one : 1 ≤ inverseComptonDopplerRatio β := by
    unfold inverseComptonDopplerRatio
    rw [le_div_iff₀ h1m]
    linarith
  have h_lorentz : (1 - β ^ 2) * inverseComptonDopplerRatio β = (1 + β) ^ 2 := by
    unfold inverseComptonDopplerRatio
    have h1m_ne : 1 - β ≠ 0 := ne_of_gt h1m
    field_simp [h1m_ne]
    ring
  have h_zero_rec : inverseComptonKleinNishinaRatio β 0 = inverseComptonDopplerRatio β := by
    unfold inverseComptonKleinNishinaRatio
    ring
  have h_rec_lt : inverseComptonKleinNishinaRatio β ε_rec < inverseComptonDopplerRatio β := by
    unfold inverseComptonKleinNishinaRatio
    exact div_lt_self h_dop_pos (by linarith)
  exact ⟨h_ge_one, h_lorentz, h_zero_rec, h_rec_lt⟩

/-- Stokes Raman scattered frequency $\omega_S = \omega_L - \Omega_v$ (phonon creation). -/
@[blueprint "def:signals-scattering-raman-stokes-freq"
  (title := "Stokes Raman scattered frequency")
  (statement := /-- For pump frequency $\omega_L$ and vibrational frequency $\Omega_v$,
    define $\omega_S = \omega_L - \Omega_v$. -/)]
def ramanStokesFreq (ω_pump Ω_vib : ℝ) : ℝ :=
  ω_pump - Ω_vib

/-- Anti-Stokes Raman scattered frequency $\omega_{AS} = \omega_L + \Omega_v$ (phonon absorption). -/
@[blueprint "def:signals-scattering-raman-antistokes-freq"
  (title := "Anti-Stokes Raman scattered frequency")
  (statement := /-- For pump frequency $\omega_L$ and vibrational frequency $\Omega_v$,
    define $\omega_{AS} = \omega_L + \Omega_v$. -/)]
def ramanAntiStokesFreq (ω_pump Ω_vib : ℝ) : ℝ :=
  ω_pump + Ω_vib

/-- Normalized Raman shift $\delta_R = \Omega_v / \omega_L$, acting as the barycentric
parallel-axis shift $d_{\mathrm{bary}}$ between the anti-Stokes and Stokes Plücker channels. -/
@[blueprint "def:signals-scattering-raman-normalized-shift"
  (title := "Normalized Raman shift δ_R = Ω_v / ω_L")
  (statement := /-- Define $\delta_R = \Omega_v / \omega_L$. -/)]
noncomputable def ramanNormalizedShift (ω_pump Ω_vib : ℝ) : ℝ :=
  Ω_vib / ω_pump

/-- Thermal Anti-Stokes to Stokes Raman intensity ratio:
$\frac{I_{AS}}{I_S} = \left(\frac{\omega_L + \Omega_v}{\omega_L - \Omega_v}\right)^4 \exp(-\xi)$,
where $\xi = \frac{\hbar\Omega_v}{k_B T} > 0$ is the dimensionless Boltzmann phonon exponent. -/
@[blueprint "def:signals-scattering-raman-thermal-ratio"
  (title := "Thermal anti-Stokes to Stokes Raman intensity ratio")
  (statement := /-- For pump frequency $\omega_L$, vibrational frequency $\Omega_v$, and
    Boltzmann exponent $\xi = \hbar\Omega_v/(k_B T)$, define
    $R_{AS/S} = \left(\frac{\omega_L+\Omega_v}{\omega_L-\Omega_v}\right)^4 e^{-\xi}$. -/)]
noncomputable def ramanAntiStokesToStokesThermalRatio
    (ω_pump Ω_vib boltzmannExponent : ℝ) : ℝ :=
  (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) ^ 4 *
    Real.exp (-boltzmannExponent)

/-- **Stokes/Anti-Stokes Raman $Gr_{\mathbb{C}}(2,4)$ Channel Identities & Thermal Boltzmann Asymmetry**:
For pump frequency $\omega_L > 0$, vibrational frequency $0 \le \Omega_v < \omega_L$,
and positive Boltzmann exponent $\xi = \hbar\Omega_v / (k_B T) > 0$:
1. Exact inverse recovery of $\omega_L$ and $\Omega_v$ from $\omega_{AS}$ and $\omega_S$
   via `reconstructSpectralDiff` and `reconstructYangCoupling`,
2. Plücker determinant product identity:
   $\omega_S\,\omega_{AS} = \omega_L^2\bigl(1 - \delta_R^2\bigr)$,
3. Plücker channel ratio identity:
   $\frac{\omega_{AS}}{\omega_S} = \frac{1 + \delta_R}{1 - \delta_R}$, and
4. Thermal Boltzmann suppression: because spontaneous Stokes emission includes vacuum
   fluctuations ($\bar{n} + 1$) whereas anti-Stokes requires thermal phonons ($\bar{n}$),
   $0 < \exp(-\xi) < 1$, so the thermal ratio is strictly smaller than the fourth power
   of the coherent Plücker frequency ratio. -/
@[blueprint "thm:signals-scattering-raman-gr24-identities"
  (title := "Stokes/anti-Stokes Raman Gr_C(2,4) channel inversion and thermal asymmetry theorem")
  (statement := /-- For $\omega_L>0$, $0\le\Omega_v<\omega_L$, and $\xi>0$:
    (1) $\operatorname{reconstructSpectralDiff}(\omega_{AS},\omega_S)=\omega_L$ and
    $\operatorname{reconstructYangCoupling}(\omega_{AS},\omega_S)=\Omega_v$,
    (2) $\omega_S\omega_{AS}=\omega_L^2(1-\delta_R^2)$,
    (3) $\frac{\omega_{AS}}{\omega_S}=\frac{1+\delta_R}{1-\delta_R}$, and
    (4) $\operatorname{ramanAntiStokesToStokesThermalRatio}(\omega_L,\Omega_v,\xi) <
    (\omega_{AS}/\omega_S)^4$. -/)
  (proof := /-- Apply ring and field simplification with $\omega_L>0$ and $\omega_L-\Omega_v>0$,
    and use $\exp(-\xi)<\exp(0)=1$ for $\xi>0$. -/)]
theorem raman_stokes_antiStokes_gr24_identities
    (ω_pump Ω_vib ξ : ℝ) (hω_pos : 0 < ω_pump)
    (hΩ_nonneg : 0 ≤ Ω_vib) (hΩ_lt : Ω_vib < ω_pump) (hξ_pos : 0 < ξ) :
    let δ_R := ramanNormalizedShift ω_pump Ω_vib
    reconstructSpectralDiff (ramanAntiStokesFreq ω_pump Ω_vib) (ramanStokesFreq ω_pump Ω_vib) =
        ω_pump ∧
      reconstructYangCoupling (ramanAntiStokesFreq ω_pump Ω_vib) (ramanStokesFreq ω_pump Ω_vib) =
        Ω_vib ∧
      ramanStokesFreq ω_pump Ω_vib * ramanAntiStokesFreq ω_pump Ω_vib =
        ω_pump ^ 2 * (1 - δ_R ^ 2) ∧
      ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib =
        (1 + δ_R) / (1 - δ_R) ∧
      ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib ξ <
        (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) ^ 4 := by
  intro δ_R
  have hω_ne : ω_pump ≠ 0 := ne_of_gt hω_pos
  have h_stokes_pos : 0 < ramanStokesFreq ω_pump Ω_vib := by
    unfold ramanStokesFreq
    linarith
  have h_stokes_ne : ramanStokesFreq ω_pump Ω_vib ≠ 0 := ne_of_gt h_stokes_pos
  have h1m_ne : 1 - δ_R ≠ 0 := by
    dsimp [δ_R, ramanNormalizedShift]
    intro h_eq
    have h_mul : ω_pump * (1 - Ω_vib / ω_pump) = 0 := by rw [h_eq, mul_zero]
    have h_expand : ω_pump * (1 - Ω_vib / ω_pump) = ω_pump - Ω_vib := by
      field_simp [hω_ne]
    linarith
  have h_rec_pump :
      reconstructSpectralDiff (ramanAntiStokesFreq ω_pump Ω_vib) (ramanStokesFreq ω_pump Ω_vib) =
        ω_pump := by
    unfold reconstructSpectralDiff ramanAntiStokesFreq ramanStokesFreq
    ring
  have h_rec_vib :
      reconstructYangCoupling (ramanAntiStokesFreq ω_pump Ω_vib) (ramanStokesFreq ω_pump Ω_vib) =
        Ω_vib := by
    unfold reconstructYangCoupling ramanAntiStokesFreq ramanStokesFreq
    ring
  have h_prod :
      ramanStokesFreq ω_pump Ω_vib * ramanAntiStokesFreq ω_pump Ω_vib =
        ω_pump ^ 2 * (1 - δ_R ^ 2) := by
    dsimp [δ_R, ramanNormalizedShift, ramanStokesFreq, ramanAntiStokesFreq]
    field_simp [hω_ne]
    ring
  have h_ratio :
      ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib =
        (1 + δ_R) / (1 - δ_R) := by
    dsimp [δ_R, ramanNormalizedShift, ramanStokesFreq, ramanAntiStokesFreq]
    field_simp [hω_ne, h_stokes_ne, h1m_ne]
  have h_therm :
      ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib ξ <
        (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) ^ 4 := by
    unfold ramanAntiStokesToStokesThermalRatio
    have h_antistokes_pos : 0 < ramanAntiStokesFreq ω_pump Ω_vib := by
      unfold ramanAntiStokesFreq
      linarith
    have h_rat_pos : 0 < (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) ^ 4 :=
      pow_pos (div_pos h_antistokes_pos h_stokes_pos) 4
    have h_exp_lt : Real.exp (-ξ) < 1 := by
      rw [← Real.exp_zero, Real.exp_lt_exp]
      linarith
    exact mul_lt_of_lt_one_right h_rat_pos h_exp_lt
  exact ⟨h_rec_pump, h_rec_vib, h_prod, h_ratio, h_therm⟩

/-- Bose–Einstein thermal phonon occupation number
$\bar{n}_{\mathrm{BE}}(\xi) = \frac{1}{\exp(\xi) - 1}$ for dimensionless Boltzmann
exponent $\xi = \frac{\hbar\Omega_v}{k_B T} > 0$. -/
@[blueprint "def:signals-scattering-bose-einstein-occupancy"
  (title := "Bose-Einstein thermal phonon occupation number n_BE(ξ) = 1 / (exp(ξ) - 1)")
  (statement := /-- For dimensionless Boltzmann exponent $\xi = \hbar\Omega_v/(k_B T)$, define
    $\bar{n}_{\mathrm{BE}}(\xi) = 1 / (\exp(\xi) - 1)$. -/)]
noncomputable def boseEinsteinOccupancy (ξ : ℝ) : ℝ :=
  1 / (Real.exp ξ - 1)

/-- Inverse Raman Boltzmann thermometer: reconstructs the dimensionless Boltzmann
exponent $\xi = \frac{\hbar\Omega_v}{k_B T}$ from pump frequency $\omega_L$,
vibrational shift $\Omega_v$, and measured anti-Stokes-to-Stokes intensity ratio $R_{AS/S}$:
$\xi = 4\ln\!\left(\frac{\omega_L + \Omega_v}{\omega_L - \Omega_v}\right) - \ln(R_{AS/S})$. -/
@[blueprint "def:signals-scattering-reconstruct-raman-boltzmann"
  (title := "Inverse Raman thermometer reconstruction of Boltzmann exponent ξ")
  (statement := /-- Define $\operatorname{reconstructRamanBoltzmannExponent}(\omega_L,\Omega_v,R)
    = 4\ln(\omega_{AS}/\omega_S) - \ln R$. -/)]
noncomputable def reconstructRamanBoltzmannExponent
    (ω_pump Ω_vib measuredRatio : ℝ) : ℝ :=
  4 * Real.log (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) -
    Real.log measuredRatio

/-- **Bose–Einstein Vacuum-Fluctuation Asymmetry ($\frac{\bar{n}}{\bar{n}+1} = e^{-\xi}$) & Exact Raman Thermometer Inversion**:
For $\omega_L > 0$, $0 \le \Omega_v < \omega_L$, and $\xi = \frac{\hbar\Omega_v}{k_B T} > 0$:
1. The Bose–Einstein phonon occupancy is strictly positive ($0 < \bar{n}_{\mathrm{BE}}(\xi)$),
2. The ratio of anti-Stokes phonon absorption ($\bar{n}_{\mathrm{BE}}(\xi)$) to Stokes
   phonon creation including the $+1$ vacuum zero-point fluctuation ($\bar{n}_{\mathrm{BE}}(\xi) + 1$)
   equals the Boltzmann factor $\exp(-\xi)$:
   $$\frac{\bar{n}_{\mathrm{BE}}(\xi)}{\bar{n}_{\mathrm{BE}}(\xi) + 1} = \exp(-\xi),$$
3. Consequently, `ramanAntiStokesToStokesThermalRatio` factors into the fourth power of the
   coherent $Gr_{\mathbb{C}}(2,4)$ Plücker frequency ratio times the Bose–Einstein
   occupancy ratio $\frac{\bar{n}_{\mathrm{BE}}(\xi)}{\bar{n}_{\mathrm{BE}}(\xi) + 1}$, and
4. `reconstructRamanBoltzmannExponent` recovers $\xi$ identically from
   `ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib ξ`. -/
@[blueprint "thm:signals-scattering-raman-bose-einstein-inversion"
  (title := "Bose-Einstein spontaneous/stimulated Raman ratio and exact thermometer inversion theorem")
  (statement := /-- For $\omega_L>0$, $0\le\Omega_v<\omega_L$, and $\xi>0$:
    (1) $0 < \operatorname{boseEinsteinOccupancy}(\xi)$,
    (2) $\frac{\operatorname{boseEinsteinOccupancy}(\xi)}{\operatorname{boseEinsteinOccupancy}(\xi)+1} = \exp(-\xi)$,
    (3) $\operatorname{ramanAntiStokesToStokesThermalRatio}(\omega_L,\Omega_v,\xi) =
    (\omega_{AS}/\omega_S)^4\,\frac{\operatorname{boseEinsteinOccupancy}(\xi)}{\operatorname{boseEinsteinOccupancy}(\xi)+1}$, and
    (4) $\operatorname{reconstructRamanBoltzmannExponent}\bigl(\omega_L,\Omega_v,\operatorname{ramanAntiStokesToStokesThermalRatio}(\omega_L,\Omega_v,\xi)\bigr) = \xi$. -/)
  (proof := /-- Clear $\exp(\xi)-1>0$ using $\exp(\xi)\exp(-\xi)=1$, and invert $\ln(r^4 e^{-\xi}) = 4\ln r - \xi$
    using positivity of $r = \omega_{AS}/\omega_S$. -/)]
theorem raman_boseEinstein_and_thermometer_inversion
    (ω_pump Ω_vib ξ : ℝ) (hω_pos : 0 < ω_pump)
    (hΩ_nonneg : 0 ≤ Ω_vib) (hΩ_lt : Ω_vib < ω_pump) (hξ_pos : 0 < ξ) :
    0 < boseEinsteinOccupancy ξ ∧
      boseEinsteinOccupancy ξ / (boseEinsteinOccupancy ξ + 1) = Real.exp (-ξ) ∧
      ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib ξ =
        (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) ^ 4 *
          (boseEinsteinOccupancy ξ / (boseEinsteinOccupancy ξ + 1)) ∧
      reconstructRamanBoltzmannExponent ω_pump Ω_vib
          (ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib ξ) = ξ := by
  have h_exp_gt_one : 1 < Real.exp ξ := Real.one_lt_exp_iff.mpr hξ_pos
  have h_denom_pos : 0 < Real.exp ξ - 1 := sub_pos.mpr h_exp_gt_one
  have h_denom_ne : Real.exp ξ - 1 ≠ 0 := ne_of_gt h_denom_pos
  have h_be_pos : 0 < boseEinsteinOccupancy ξ :=
    div_pos zero_lt_one h_denom_pos
  have h_be_ratio :
      boseEinsteinOccupancy ξ / (boseEinsteinOccupancy ξ + 1) = Real.exp (-ξ) := by
    unfold boseEinsteinOccupancy
    rw [Real.exp_neg]
    have h_sum : 1 / (Real.exp ξ - 1) + 1 = Real.exp ξ / (Real.exp ξ - 1) := by
      field_simp [h_denom_ne]
      ring
    rw [h_sum, div_div_div_cancel_right₀ h_denom_ne, one_div]
  have h_therm_be :
      ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib ξ =
        (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) ^ 4 *
          (boseEinsteinOccupancy ξ / (boseEinsteinOccupancy ξ + 1)) := by
    unfold ramanAntiStokesToStokesThermalRatio
    rw [h_be_ratio]
  have h_stokes_pos : 0 < ramanStokesFreq ω_pump Ω_vib := by
    unfold ramanStokesFreq
    linarith
  have h_antistokes_pos : 0 < ramanAntiStokesFreq ω_pump Ω_vib := by
    unfold ramanAntiStokesFreq
    linarith
  have h_rat_pos : 0 < ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib :=
    div_pos h_antistokes_pos h_stokes_pos
  have h_rat_ne : ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib ≠ 0 :=
    ne_of_gt h_rat_pos
  have h_rat4_ne : (ramanAntiStokesFreq ω_pump Ω_vib / ramanStokesFreq ω_pump Ω_vib) ^ 4 ≠ 0 :=
    pow_ne_zero 4 h_rat_ne
  have h_exp_neg_ne : Real.exp (-ξ) ≠ 0 := Real.exp_ne_zero (-ξ)
  have h_inv :
      reconstructRamanBoltzmannExponent ω_pump Ω_vib
          (ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib ξ) = ξ := by
    unfold reconstructRamanBoltzmannExponent ramanAntiStokesToStokesThermalRatio
    rw [Real.log_mul h_rat4_ne h_exp_neg_ne, Real.log_pow, Real.log_exp]
    ring
  exact ⟨h_be_pos, h_be_ratio, h_therm_be, h_inv⟩

/-- Inverse reconstruction of the reduced velocity $\beta = \frac{D - 1}{D + 1}$
from the head-on Thomson Inverse Compton Doppler ratio $D = \frac{1 + \beta}{1 - \beta}$. -/
@[blueprint "def:signals-scattering-reconstruct-ics-beta"
  (title := "Inverse reconstruction of reduced velocity β from Inverse Compton Doppler ratio")
  (statement := /-- Given head-on Thomson Doppler ratio $D$, reconstruct $\beta = (D-1)/(D+1)$. -/)]
noncomputable def reconstructInverseComptonBeta (dopplerRatio : ℝ) : ℝ :=
  (dopplerRatio - 1) / (dopplerRatio + 1)

/-- Inverse reconstruction of the dimensionless Klein–Nishina quantum recoil
parameter $\epsilon_{\mathrm{rec}} = \frac{D}{R_{\mathrm{KN}}} - 1$ from the Thomson
Doppler ratio $D$ and measured Klein–Nishina upshift ratio $R_{\mathrm{KN}}$. -/
@[blueprint "def:signals-scattering-reconstruct-kn-recoil"
  (title := "Inverse reconstruction of Klein-Nishina quantum recoil parameter ε_rec")
  (statement := /-- Given Thomson Doppler ratio $D$ and recoil-corrected ratio $R_{\mathrm{KN}}$,
    reconstruct $\epsilon_{\mathrm{rec}} = D / R_{\mathrm{KN}} - 1$. -/)]
noncomputable def reconstructKleinNishinaRecoil
    (dopplerRatio knRatio : ℝ) : ℝ :=
  dopplerRatio / knRatio - 1

/-- Reconstruct physical absolute temperature $T = \frac{\hbar\Omega_v}{k_B\,\xi}$
from pump frequency $\omega_L$, vibrational shift $\Omega_v$, thermal energy scale
$\hbar\Omega_v / k_B$ (`charTemp = hbar * Ω_vib / k_B`), and measured anti-Stokes-to-Stokes
intensity ratio $R_{AS/S}$. -/
@[blueprint "def:signals-scattering-reconstruct-raman-temperature"
  (title := "Inverse Raman thermometer reconstruction of absolute temperature T")
  (statement := /-- Given characteristic phonon temperature $\Theta_v = \hbar\Omega_v/k_B$ and
    measured ratio $R_{AS/S}$, reconstruct $T = \Theta_v / \operatorname{reconstructRamanBoltzmannExponent}(\omega_L,\Omega_v,R_{AS/S})$. -/)]
noncomputable def reconstructRamanTemperature
    (ω_pump Ω_vib charTemp measuredRatio : ℝ) : ℝ :=
  charTemp / reconstructRamanBoltzmannExponent ω_pump Ω_vib measuredRatio

/-- Calibrated `ResidualMeasurement` for Raman anti-Stokes/Stokes thermometry,
comparing an observed temperature $T_{\mathrm{obs}}$ against a predicted temperature $T_{\mathrm{pred}}$. -/
@[blueprint "def:signals-scattering-raman-temperature-residual"
  (title := "Calibrated Raman thermometry residual measurement")
  (statement := /-- Packages predicted temperature $T_{\mathrm{pred}}$ and reconstructed
    temperature $T_{\mathrm{obs}}$ into a \texttt{ResidualMeasurement}. -/)]
def ramanTemperatureResidualMeasurement
    (T_pred T_obs tolerance : ℝ) (tolerance_nonnegative : 0 ≤ tolerance) :
    ResidualMeasurement :=
  { predicted := T_pred
    observed := T_obs
    residual := T_obs - T_pred
    tolerance := tolerance
    tolerance_nonnegative := tolerance_nonnegative
    residualLaw := rfl }

/-- **Exact Inverse Recovery of $\beta$, Klein–Nishina Recoil $\epsilon_{\mathrm{rec}}$, and Absolute Raman Temperature $T$**:
For subluminal $\beta \in [0, 1)$, quantum recoil $\epsilon_{\mathrm{rec}} \ge 0$,
pump frequency $\omega_L > 0$, vibrational shift $0 \le \Omega_v < \omega_L$,
characteristic phonon temperature $\Theta_v = \hbar\Omega_v / k_B > 0$, and
absolute temperature $T > 0$:
1. `reconstructInverseComptonBeta` recovers $\beta$ identically from
   `inverseComptonDopplerRatio β`,
2. `reconstructKleinNishinaRecoil` recovers $\epsilon_{\mathrm{rec}}$ identically from
   `inverseComptonDopplerRatio β` and `inverseComptonKleinNishinaRatio β ε_rec`,
3. `reconstructRamanTemperature` recovers $T$ identically from
   `ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib (Θ_v / T)`, and
4. The resulting `ramanTemperatureResidualMeasurement` is `.consistent` for every
   nonnegative tolerance $\tau \ge 0$. -/
@[blueprint "thm:signals-scattering-inelastic-complete-inversion"
  (title := "Complete inverse recovery of Inverse Compton β, Klein-Nishina recoil ε_rec, and Raman temperature T")
  (statement := /-- For $0\le\beta<1$, $\epsilon_{\mathrm{rec}}\ge 0$, $\omega_L>0$, $0\le\Omega_v<\omega_L$,
    $\Theta_v>0$, and $T>0$:
    (1) $\operatorname{reconstructInverseComptonBeta}(\operatorname{inverseComptonDopplerRatio}(\beta)) = \beta$,
    (2) $\operatorname{reconstructKleinNishinaRecoil}(\operatorname{inverseComptonDopplerRatio}(\beta), \operatorname{inverseComptonKleinNishinaRatio}(\beta,\epsilon_{\mathrm{rec}})) = \epsilon_{\mathrm{rec}}$,
    (3) $\operatorname{reconstructRamanTemperature}\bigl(\omega_L,\Omega_v,\Theta_v,\operatorname{ramanAntiStokesToStokesThermalRatio}(\omega_L,\Omega_v,\Theta_v/T)\bigr) = T$, and
    (4) the corresponding \texttt{ramanTemperatureResidualMeasurement} is \texttt{.consistent} for all $\tau\ge 0$. -/)
  (proof := /-- Clear $1-\beta>0$ and $1+\epsilon_{\mathrm{rec}}>0$ by field simplification, apply
    \texttt{raman\_boseEinstein\_and\_thermometer\_inversion} to $\xi=\Theta_v/T>0$, and simplify $\Theta_v/(\Theta_v/T)=T$. -/)]
theorem inelastic_compton_and_raman_temperature_inversion
    (β ε_rec ω_pump Ω_vib Θ_v T tolerance : ℝ)
    (hβ_nonneg : 0 ≤ β) (hβ_lt : β < 1) (hε_nonneg : 0 ≤ ε_rec)
    (hω_pos : 0 < ω_pump) (hΩ_nonneg : 0 ≤ Ω_vib) (hΩ_lt : Ω_vib < ω_pump)
    (hΘ_pos : 0 < Θ_v) (hT_pos : 0 < T) (htol : 0 ≤ tolerance) :
    let D := inverseComptonDopplerRatio β
    let R_KN := inverseComptonKleinNishinaRatio β ε_rec
    let R_Raman := ramanAntiStokesToStokesThermalRatio ω_pump Ω_vib (Θ_v / T)
    let T_rec := reconstructRamanTemperature ω_pump Ω_vib Θ_v R_Raman
    reconstructInverseComptonBeta D = β ∧
      reconstructKleinNishinaRecoil D R_KN = ε_rec ∧
      T_rec = T ∧
      (ramanTemperatureResidualMeasurement T T_rec tolerance htol).consistent := by
  intro D R_KN R_Raman T_rec
  have h1m : 0 < 1 - β := by linarith
  have h1p : 0 < 1 + β := by linarith
  have h1m_ne : 1 - β ≠ 0 := ne_of_gt h1m
  have h1p_ne : 1 + β ≠ 0 := ne_of_gt h1p
  have hD_pos : 0 < D := div_pos h1p h1m
  have hD_ne : D ≠ 0 := ne_of_gt hD_pos
  have hD_plus_one_ne : D + 1 ≠ 0 := by linarith
  have h1e_pos : 0 < 1 + ε_rec := by linarith
  have h1e_ne : 1 + ε_rec ≠ 0 := ne_of_gt h1e_pos
  have h_beta_inv : reconstructInverseComptonBeta D = β := by
    dsimp [D, reconstructInverseComptonBeta, inverseComptonDopplerRatio]
    field_simp [h1m_ne]
    ring
  have h_rec_inv : reconstructKleinNishinaRecoil D R_KN = ε_rec := by
    dsimp [R_KN, reconstructKleinNishinaRecoil, inverseComptonKleinNishinaRatio]
    change D / (D / (1 + ε_rec)) - 1 = ε_rec
    field_simp [hD_ne, h1e_ne]
    ring
  have hξ_pos : 0 < Θ_v / T := div_pos hΘ_pos hT_pos
  have h_xi_inv :=
    (raman_boseEinstein_and_thermometer_inversion ω_pump Ω_vib (Θ_v / T)
      hω_pos hΩ_nonneg hΩ_lt hξ_pos).2.2.2
  have hΘ_ne : Θ_v ≠ 0 := ne_of_gt hΘ_pos
  have hT_ne : T ≠ 0 := ne_of_gt hT_pos
  have h_T_inv : T_rec = T := by
    dsimp [T_rec, R_Raman, reconstructRamanTemperature]
    rw [h_xi_inv]
    field_simp [hΘ_ne, hT_ne]
  have h_cons : (ramanTemperatureResidualMeasurement T T_rec tolerance htol).consistent := by
    rw [ResidualMeasurement.consistent_iff]
    change |T_rec - T| ≤ tolerance
    rw [h_T_inv, sub_self, abs_zero]
    exact htol
  exact ⟨h_beta_inv, h_rec_inv, h_T_inv, h_cons⟩

/-! ## Polaritons: Hopfield Bogoliubov Mixing, Vacuum Rabi Anticrossing, $Gr_{\mathbb{C}}(2,4)$ Complementarity, and Lyddane–Sachs–Teller Dispersion -/

/-- Effective polariton Rabi splitting
$\Omega_{\mathrm{eff}}(\Delta_{\mathrm{pol}}, g_{\mathrm{Rabi}}) = \sqrt{\Delta_{\mathrm{pol}}^2 + 4 g_{\mathrm{Rabi}}^2}$
for photon–matter detuning $\Delta_{\mathrm{pol}} = \omega_{\mathrm{ph}} - \omega_{\mathrm{ex}}$
and vacuum Rabi coupling rate $g_{\mathrm{Rabi}}$. -/
@[blueprint "def:signals-scattering-polariton-rabi-splitting"
  (title := "Effective polariton Rabi splitting Ω_eff = √(Δ² + 4g²)")
  (statement := /-- Define $\operatorname{polaritonEffectiveRabiSplitting}(\Delta, g) = \sqrt{\Delta^2 + 4 g^2}$. -/)]
noncomputable def polaritonEffectiveRabiSplitting (detuning rabiCoupling : ℝ) : ℝ :=
  Real.sqrt (detuning ^ 2 + 4 * rabiCoupling ^ 2)

/-- Upper polariton (UP) eigenfrequency
$\omega_{\mathrm{UP}}(\omega_{\mathrm{ph}}, \omega_{\mathrm{ex}}, g_{\mathrm{Rabi}}) = \frac{\omega_{\mathrm{ph}} + \omega_{\mathrm{ex}} + \Omega_{\mathrm{eff}}(\omega_{\mathrm{ph}} - \omega_{\mathrm{ex}}, g_{\mathrm{Rabi}})}{2}$. -/
@[blueprint "def:signals-scattering-upper-polariton-freq"
  (title := "Upper polariton eigenfrequency ω_UP")
  (statement := /-- Define $\operatorname{upperPolaritonFreq}(\omega_{\mathrm{ph}},\omega_{\mathrm{ex}},g)
    = \frac{1}{2}(\omega_{\mathrm{ph}} + \omega_{\mathrm{ex}} + \operatorname{polaritonEffectiveRabiSplitting}(\omega_{\mathrm{ph}}-\omega_{\mathrm{ex}}, g))$. -/)]
noncomputable def upperPolaritonFreq (ω_ph ω_ex rabiCoupling : ℝ) : ℝ :=
  (ω_ph + ω_ex + polaritonEffectiveRabiSplitting (ω_ph - ω_ex) rabiCoupling) / 2

/-- Lower polariton (LP) eigenfrequency
$\omega_{\mathrm{LP}}(\omega_{\mathrm{ph}}, \omega_{\mathrm{ex}}, g_{\mathrm{Rabi}}) = \frac{\omega_{\mathrm{ph}} + \omega_{\mathrm{ex}} - \Omega_{\mathrm{eff}}(\omega_{\mathrm{ph}} - \omega_{\mathrm{ex}}, g_{\mathrm{Rabi}})}{2}$. -/
@[blueprint "def:signals-scattering-lower-polariton-freq"
  (title := "Lower polariton eigenfrequency ω_LP")
  (statement := /-- Define $\operatorname{lowerPolaritonFreq}(\omega_{\mathrm{ph}},\omega_{\mathrm{ex}},g)
    = \frac{1}{2}(\omega_{\mathrm{ph}} + \omega_{\mathrm{ex}} - \operatorname{polaritonEffectiveRabiSplitting}(\omega_{\mathrm{ph}}-\omega_{\mathrm{ex}}, g))$. -/)]
noncomputable def lowerPolaritonFreq (ω_ph ω_ex rabiCoupling : ℝ) : ℝ :=
  (ω_ph + ω_ex - polaritonEffectiveRabiSplitting (ω_ph - ω_ex) rabiCoupling) / 2

/-- Inverse polariton spectroscopy: reconstructs the squared vacuum Rabi coupling
$g_{\mathrm{Rabi}}^2 = \omega_{\mathrm{ph}}\,\omega_{\mathrm{ex}} - \omega_{\mathrm{UP}}\,\omega_{\mathrm{LP}}$
from the bare photon/matter frequencies $(\omega_{\mathrm{ph}}, \omega_{\mathrm{ex}})$ and
measured upper/lower polariton eigenfrequencies $(\omega_{\mathrm{UP}}, \omega_{\mathrm{LP}})$. -/
@[blueprint "def:signals-scattering-reconstruct-polariton-rabi-sq"
  (title := "Inverse polariton reconstruction of squared Rabi coupling g²")
  (statement := /-- Define $\operatorname{reconstructPolaritonRabiCouplingSq}(\omega_{\mathrm{ph}},\omega_{\mathrm{ex}},\omega_{\mathrm{UP}},\omega_{\mathrm{LP}})
    = \omega_{\mathrm{ph}}\omega_{\mathrm{ex}} - \omega_{\mathrm{UP}}\omega_{\mathrm{LP}}$. -/)]
def reconstructPolaritonRabiCouplingSq (ω_ph ω_ex ω_UP ω_LP : ℝ) : ℝ :=
  ω_ph * ω_ex - ω_UP * ω_LP

/-- Normalized Hopfield barycentric photon–matter asymmetry
$d_{\mathrm{Hopfield}}(\Delta_{\mathrm{pol}}, g_{\mathrm{Rabi}}) = \frac{\Delta_{\mathrm{pol}}}{\sqrt{\Delta_{\mathrm{pol}}^2 + 4 g_{\mathrm{Rabi}}^2}} \in (-1, 1)$. -/
@[blueprint "def:signals-scattering-hopfield-barycentric-shift"
  (title := "Normalized Hopfield barycentric photon-matter asymmetry d_Hopfield")
  (statement := /-- Define $\operatorname{hopfieldBarycentricShift}(\Delta,g)
    = \Delta / \operatorname{polaritonEffectiveRabiSplitting}(\Delta,g)$. -/)]
noncomputable def hopfieldBarycentricShift (detuning rabiCoupling : ℝ) : ℝ :=
  detuning / polaritonEffectiveRabiSplitting detuning rabiCoupling

/-- Upper-branch Hopfield photon weight $|C|^2 = \frac{1 + d_{\mathrm{Hopfield}}}{2}$. -/
@[blueprint "def:signals-scattering-hopfield-photon-weight"
  (title := "Hopfield photon fraction |C|² = (1 + d_Hopfield) / 2")
  (statement := /-- Define $\operatorname{hopfieldPhotonWeight}(d_{\mathrm{hop}}) = (1 + d_{\mathrm{hop}})/2$. -/)]
noncomputable def hopfieldPhotonWeight (d_hop : ℝ) : ℝ :=
  (1 + d_hop) / 2

/-- Upper-branch Hopfield matter (exciton/phonon) weight $|X|^2 = \frac{1 - d_{\mathrm{Hopfield}}}{2}$. -/
@[blueprint "def:signals-scattering-hopfield-matter-weight"
  (title := "Hopfield matter fraction |X|² = (1 - d_Hopfield) / 2")
  (statement := /-- Define $\operatorname{hopfieldMatterWeight}(d_{\mathrm{hop}}) = (1 - d_{\mathrm{hop}})/2$. -/)]
noncomputable def hopfieldMatterWeight (d_hop : ℝ) : ℝ :=
  (1 - d_hop) / 2

/-- Lyddane–Sachs–Teller (LST) polariton dielectric function
$\varepsilon_{\mathrm{pol}}(\omega) = \varepsilon_\infty\,\frac{\omega^2 - \omega_{\mathrm{LO}}^2}{\omega^2 - \omega_{\mathrm{TO}}^2}$
near a transverse optical ($\omega_{\mathrm{TO}}$) and longitudinal optical ($\omega_{\mathrm{LO}}$)
phonon or exciton resonance. -/
@[blueprint "def:signals-scattering-lst-permittivity"
  (title := "Lyddane-Sachs-Teller polariton dielectric function ε_pol(ω)")
  (statement := /-- Define $\operatorname{lyddaneSachsTellerPermittivity}(\varepsilon_\infty,\omega_{\mathrm{TO}},\omega_{\mathrm{LO}},\omega)
    = \varepsilon_\infty (\omega^2 - \omega_{\mathrm{LO}}^2) / (\omega^2 - \omega_{\mathrm{TO}}^2)$. -/)]
noncomputable def lyddaneSachsTellerPermittivity
    (eps_inf ω_TO ω_LO ω : ℝ) : ℝ :=
  eps_inf * (ω ^ 2 - ω_LO ^ 2) / (ω ^ 2 - ω_TO ^ 2)

/-- **Polariton Hopfield–Rabi Anticrossing, Inverse Coupling Recovery, & Lyddane–Sachs–Teller Reststrahlen Theorem**:
For bare frequencies $\omega_{\mathrm{ph}}, \omega_{\mathrm{ex}} \in \mathbb{R}$, vacuum Rabi coupling
$g_{\mathrm{Rabi}} > 0$, and LST parameters $\varepsilon_\infty > 0$, $0 < \omega_{\mathrm{TO}} < \omega < \omega_{\mathrm{LO}}$:
1. **Strict Vacuum Rabi Anticrossing**:
   $\omega_{\mathrm{UP}} + \omega_{\mathrm{LP}} = \omega_{\mathrm{ph}} + \omega_{\mathrm{ex}}$ and
   $\omega_{\mathrm{UP}} - \omega_{\mathrm{LP}} = \Omega_{\mathrm{eff}}(\omega_{\mathrm{ph}} - \omega_{\mathrm{ex}}, g_{\mathrm{Rabi}}) \ge 2 g_{\mathrm{Rabi}} > 0$,
   with exact resonance splitting $\omega_{\mathrm{UP}}(\omega_0, \omega_0, g_{\mathrm{Rabi}}) - \omega_{\mathrm{LP}}(\omega_0, \omega_0, g_{\mathrm{Rabi}}) = 2 g_{\mathrm{Rabi}}$,
2. **Determinant Invariance & Exact Inverse Rabi Spectroscopy**:
   $\omega_{\mathrm{UP}}\,\omega_{\mathrm{LP}} = \omega_{\mathrm{ph}}\,\omega_{\mathrm{ex}} - g_{\mathrm{Rabi}}^2$, so
   `reconstructPolaritonRabiCouplingSq` recovers $g_{\mathrm{Rabi}}^2$ identically,
3. **Hopfield Normalization & Pythagorean Hybridization Complementarity**:
   $-1 < d_{\mathrm{Hopfield}} < 1$, $|C|^2 + |X|^2 = 1$, $|C|^2 - |X|^2 = d_{\mathrm{Hopfield}}$, and
   $$4\,|C|^2\,|X|^2 = 1 - d_{\mathrm{Hopfield}}^2 = \frac{4 g_{\mathrm{Rabi}}^2}{(\omega_{\mathrm{ph}} - \omega_{\mathrm{ex}})^2 + 4 g_{\mathrm{Rabi}}^2} > 0,$$
4. **Lyddane–Sachs–Teller Static Limit, ENZ Bulk Longitudinal Cutoff, & Reststrahlen Surface-Polariton Window**:
   - Static limit ($\omega = 0$): $\varepsilon_{\mathrm{pol}}(0) = \varepsilon_\infty \frac{\omega_{\mathrm{LO}}^2}{\omega_{\mathrm{TO}}^2}$,
   - Epsilon-Near-Zero (ENZ) longitudinal polariton mode ($\omega = \omega_{\mathrm{LO}}$): $\varepsilon_{\mathrm{pol}}(\omega_{\mathrm{LO}}) = 0$,
   - Reststrahlen stop-band ($\omega_{\mathrm{TO}} < \omega < \omega_{\mathrm{LO}}$): $\varepsilon_{\mathrm{pol}}(\omega) < 0$ (surface-polariton active regime). -/
@[blueprint "thm:signals-scattering-polariton-hopfield-lst"
  (title := "Polariton Hopfield-Rabi anticrossing, inverse spectroscopy, and Lyddane-Sachs-Teller Reststrahlen theorem")
  (statement := /-- For $\omega_{\mathrm{ph}},\omega_{\mathrm{ex}}\in\mathbb R$, $g>0$, $\varepsilon_\infty>0$, and $0<\omega_{\mathrm{TO}}<\omega<\omega_{\mathrm{LO}}$:
    (1) $\omega_{\mathrm{UP}}+\omega_{\mathrm{LP}}=\omega_{\mathrm{ph}}+\omega_{\mathrm{ex}}$ and $2g \le \omega_{\mathrm{UP}}-\omega_{\mathrm{LP}}$,
    (2) $\operatorname{reconstructPolaritonRabiCouplingSq}(\omega_{\mathrm{ph}},\omega_{\mathrm{ex}},\omega_{\mathrm{UP}},\omega_{\mathrm{LP}}) = g^2$,
    (3) $|C|^2+|X|^2=1$ and $4|C|^2|X|^2 = 1 - d_{\mathrm{Hopfield}}^2 = \frac{4g^2}{(\omega_{\mathrm{ph}}-\omega_{\mathrm{ex}})^2+4g^2} > 0$, and
    (4) $\varepsilon_{\mathrm{pol}}(0) = \varepsilon_\infty\omega_{\mathrm{LO}}^2/\omega_{\mathrm{TO}}^2$, $\varepsilon_{\mathrm{pol}}(\omega_{\mathrm{LO}}) = 0$, and $\varepsilon_{\mathrm{pol}}(\omega) < 0$ for $\omega\in(\omega_{\mathrm{TO}},\omega_{\mathrm{LO}})$. -/)
  (proof := /-- Expand $\Omega_{\mathrm{eff}}^2 = (\omega_{\mathrm{ph}}-\omega_{\mathrm{ex}})^2 + 4g^2$, clear denominators for
    $d_{\mathrm{Hopfield}}$, and analyze the signs of $\omega^2-\omega_{\mathrm{LO}}^2<0$ and $\omega^2-\omega_{\mathrm{TO}}^2>0$ in the Reststrahlen band. -/)]
theorem polariton_hopfield_rabi_and_lst_identities
    (ω_ph ω_ex g eps_inf ω_TO ω_LO ω : ℝ)
    (hg_pos : 0 < g) (heps_pos : 0 < eps_inf)
    (hTO_pos : 0 < ω_TO) (h_gt_TO : ω_TO < ω) (h_lt_LO : ω < ω_LO) :
    let Δ := ω_ph - ω_ex
    let ω_UP := upperPolaritonFreq ω_ph ω_ex g
    let ω_LP := lowerPolaritonFreq ω_ph ω_ex g
    let d_hop := hopfieldBarycentricShift Δ g
    let w_ph := hopfieldPhotonWeight d_hop
    let w_ex := hopfieldMatterWeight d_hop
    ω_UP + ω_LP = ω_ph + ω_ex ∧
      ω_UP - ω_LP = polaritonEffectiveRabiSplitting Δ g ∧
      2 * g ≤ ω_UP - ω_LP ∧
      reconstructPolaritonRabiCouplingSq ω_ph ω_ex ω_UP ω_LP = g ^ 2 ∧
      -1 < d_hop ∧
      d_hop < 1 ∧
      w_ph + w_ex = 1 ∧
      w_ph - w_ex = d_hop ∧
      4 * w_ph * w_ex = 1 - d_hop ^ 2 ∧
      1 - d_hop ^ 2 = (4 * g ^ 2) / (Δ ^ 2 + 4 * g ^ 2) ∧
      lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO 0 =
        eps_inf * (ω_LO ^ 2 / ω_TO ^ 2) ∧
      lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO ω_LO = 0 ∧
      lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO ω < 0 := by
  intro Δ ω_UP ω_LP d_hop w_ph w_ex
  have h_rad_pos : 0 < Δ ^ 2 + 4 * g ^ 2 := by positivity
  have h_rad_nonneg : 0 ≤ Δ ^ 2 + 4 * g ^ 2 := le_of_lt h_rad_pos
  have h_omega_pos : 0 < polaritonEffectiveRabiSplitting Δ g :=
    Real.sqrt_pos.mpr h_rad_pos
  have h_omega_ne : polaritonEffectiveRabiSplitting Δ g ≠ 0 := ne_of_gt h_omega_pos
  have h_omega_sq : (polaritonEffectiveRabiSplitting Δ g) ^ 2 = Δ ^ 2 + 4 * g ^ 2 :=
    Real.sq_sqrt h_rad_nonneg
  have h_sum : ω_UP + ω_LP = ω_ph + ω_ex := by
    dsimp [ω_UP, ω_LP, upperPolaritonFreq, lowerPolaritonFreq]
    ring
  have h_diff : ω_UP - ω_LP = polaritonEffectiveRabiSplitting Δ g := by
    dsimp [ω_UP, ω_LP, upperPolaritonFreq, lowerPolaritonFreq, Δ]
    ring
  have h_anticross : 2 * g ≤ ω_UP - ω_LP := by
    rw [h_diff]
    unfold polaritonEffectiveRabiSplitting
    apply Real.le_sqrt_of_sq_le
    have : 0 ≤ Δ ^ 2 := sq_nonneg Δ
    linarith
  have h_rabi_inv : reconstructPolaritonRabiCouplingSq ω_ph ω_ex ω_UP ω_LP = g ^ 2 := by
    dsimp [reconstructPolaritonRabiCouplingSq, ω_UP, ω_LP, upperPolaritonFreq, lowerPolaritonFreq]
    have h_prod :
        (ω_ph + ω_ex + polaritonEffectiveRabiSplitting Δ g) / 2 *
          ((ω_ph + ω_ex - polaritonEffectiveRabiSplitting Δ g) / 2) =
        ((ω_ph + ω_ex) ^ 2 - (polaritonEffectiveRabiSplitting Δ g) ^ 2) / 4 := by ring
    change ω_ph * ω_ex -
      (ω_ph + ω_ex + polaritonEffectiveRabiSplitting Δ g) / 2 *
        ((ω_ph + ω_ex - polaritonEffectiveRabiSplitting Δ g) / 2) = g ^ 2
    rw [h_prod, h_omega_sq]
    dsimp [Δ]
    ring
  have h_dhop_sq_lt : d_hop ^ 2 < 1 := by
    dsimp [d_hop, hopfieldBarycentricShift]
    rw [div_pow, h_omega_sq, div_lt_iff₀ h_rad_pos]
    have : 0 < 4 * g ^ 2 := by positivity
    linarith
  have h_dhop_gt : -1 < d_hop := by nlinarith
  have h_dhop_lt : d_hop < 1 := by nlinarith
  have h_w_sum : w_ph + w_ex = 1 := by
    dsimp [w_ph, w_ex, hopfieldPhotonWeight, hopfieldMatterWeight]
    ring
  have h_w_diff : w_ph - w_ex = d_hop := by
    dsimp [w_ph, w_ex, hopfieldPhotonWeight, hopfieldMatterWeight]
    ring
  have h_w_prod : 4 * w_ph * w_ex = 1 - d_hop ^ 2 := by
    dsimp [w_ph, w_ex, hopfieldPhotonWeight, hopfieldMatterWeight]
    ring
  have h_comp : 1 - d_hop ^ 2 = (4 * g ^ 2) / (Δ ^ 2 + 4 * g ^ 2) := by
    dsimp [d_hop, hopfieldBarycentricShift]
    rw [div_pow, h_omega_sq]
    have h_ne : Δ ^ 2 + 4 * g ^ 2 ≠ 0 := ne_of_gt h_rad_pos
    field_simp [h_ne]
    ring
  have hTO_sq_ne : ω_TO ^ 2 ≠ 0 := ne_of_gt (sq_pos_of_pos hTO_pos)
  have h_lst_zero :
      lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO 0 =
        eps_inf * (ω_LO ^ 2 / ω_TO ^ 2) := by
    unfold lyddaneSachsTellerPermittivity
    field_simp [hTO_sq_ne]
    ring
  have h_lst_lo :
      lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO ω_LO = 0 := by
    unfold lyddaneSachsTellerPermittivity
    simp
  have h_lst_rest :
      lyddaneSachsTellerPermittivity eps_inf ω_TO ω_LO ω < 0 := by
    unfold lyddaneSachsTellerPermittivity
    have h_omega_pos' : 0 < ω := lt_trans hTO_pos h_gt_TO
    have h_LO_pos : 0 < ω_LO := lt_trans h_omega_pos' h_lt_LO
    have h_num_neg : ω ^ 2 - ω_LO ^ 2 < 0 := by nlinarith
    have h_den_pos : 0 < ω ^ 2 - ω_TO ^ 2 := by nlinarith
    have h_prod_neg : eps_inf * (ω ^ 2 - ω_LO ^ 2) < 0 :=
      mul_neg_of_pos_of_neg heps_pos h_num_neg
    exact div_neg_of_neg_of_pos h_prod_neg h_den_pos
  exact ⟨h_sum, h_diff, h_anticross, h_rabi_inv, h_dhop_gt, h_dhop_lt,
    h_w_sum, h_w_diff, h_w_prod, h_comp, h_lst_zero, h_lst_lo, h_lst_rest⟩

/-! ## Coherent Synchrotron Radiation (CSR) on Cylindrical SPP Microtubes/CNTs, Cavity QED Cooperativity, Cherenkov–Proca Phase Matching, & Grover State Carving -/

/-- Coherent Synchrotron Radiation (CSR) intensity from $N_e$ surface electrons
bunched by a cylindrical Surface Plasmon Polariton (SPP) mode with bunching
form factor $f_{\mathrm{bunch}} \in [0, 1]$ and single-electron intensity $I_{\mathrm{single}}$
(Lei et al., 2025, `10.1103/cnym-16hc`, `arXiv:2507.04561`):
$I_{\mathrm{CSR}}(N_e, f_{\mathrm{bunch}}, I_{\mathrm{single}}) = \bigl(N_e + N_e(N_e - 1) f_{\mathrm{bunch}}^2\bigr)\,I_{\mathrm{single}}$. -/
@[blueprint "def:signals-scattering-csr-bunching-intensity"
  (title := "CSR bunching intensity I_CSR = (N_e + N_e(N_e - 1) f_bunch²) I_single")
  (statement := /-- Define $\operatorname{csrBunchingIntensity}(N_e, f_{\mathrm{bunch}}, I_{\mathrm{single}})
    = (N_e + N_e(N_e - 1) f_{\mathrm{bunch}}^2)\,I_{\mathrm{single}}$. -/)]
def csrBunchingIntensity (N_e f_bunch I_single : ℝ) : ℝ :=
  (N_e + N_e * (N_e - 1) * f_bunch ^ 2) * I_single

/-- Relativistic synchrotron critical frequency $\omega_c^{\mathrm{CSR}} = \frac{3}{2}\,\omega_{\mathrm{rot}}\,\gamma_e^3$
for surface electrons spiraling at angular frequency $\omega_{\mathrm{rot}}$ with
Lorentz factor $\gamma_e \ge 1$ on a near-critical microtube or carbon nanotube (CNT). -/
@[blueprint "def:signals-scattering-csr-critical-freq"
  (title := "Relativistic CSR critical X-ray frequency ω_c = (3/2) ω_rot γ_e³")
  (statement := /-- Define $\operatorname{csrCriticalFrequency}(\omega_{\mathrm{rot}}, \gamma_e)
    = \frac{3}{2}\,\omega_{\mathrm{rot}}\,\gamma_e^3$. -/)]
noncomputable def csrCriticalFrequency (ω_rot γ_e : ℝ) : ℝ :=
  (3 / 2) * ω_rot * γ_e ^ 3

/-- Single-emitter Cavity QED cooperativity $C_1 = \frac{4 g_0^2}{\kappa_{\mathrm{cav}}\,\gamma_{\mathrm{emit}}}$
for single-photon coupling $g_0$, cavity decay rate $\kappa_{\mathrm{cav}}$, and emitter
decay rate $\gamma_{\mathrm{emit}}$ (distinguishing closed-cavity Jaynes–Cummings QED from
open-boundary $N_e^2$ travelling-wave CSR-SPP emission and $N_e$-collective van der Waals
cavity electrodynamics; Kipp et al., 2024, `arXiv:2403.19745`). -/
@[blueprint "def:signals-scattering-cavity-qed-cooperativity"
  (title := "Single-emitter Cavity QED cooperativity C_1 = 4 g_0² / (κ_cav γ_emit)")
  (statement := /-- Define $\operatorname{cavityQEDCooperativity}(g_0, \kappa_{\mathrm{cav}}, \gamma_{\mathrm{emit}})
    = 4 g_0^2 / (\kappa_{\mathrm{cav}}\gamma_{\mathrm{emit}})$. -/)]
noncomputable def cavityQEDCooperativity (g_single κ_cav γ_emit : ℝ) : ℝ :=
  (4 * g_single ^ 2) / (κ_cav * γ_emit)

/-- Squared phase velocity of a transverse electromagnetic wave in an unmagnetized plasma
with plasma frequency $\omega_p$ ($\omega > \omega_p > 0$):
$v_{\mathrm{ph},\perp}^2 = \frac{c^2\,\omega^2}{\omega^2 - \omega_p^2} > c^2$
(superluminal phase velocity forbids subluminal transverse Cherenkov radiation). -/
@[blueprint "def:signals-scattering-transverse-plasma-phase-vel-sq"
  (title := "Superluminal transverse plasma phase velocity squared v_{ph,⊥}² = c² ω² / (ω² - ω_p²)")
  (statement := /-- Define $\operatorname{transversePlasmaPhaseVelSq}(c, \omega, \omega_p)
    = c^2 \omega^2 / (\omega^2 - \omega_p^2)$. -/)]
noncomputable def transversePlasmaPhaseVelSq (c ω ω_p : ℝ) : ℝ :=
  (c ^ 2 * ω ^ 2) / (ω ^ 2 - ω_p ^ 2)

/-- Squared phase velocity of a longitudinal Bohm–Gross / effective-mass plasma wave
($\omega^2 = \omega_p^2 + 3 v_{\mathrm{th}}^2 k^2$, where $m_{\mathrm{eff}} = \hbar\omega_p / c^2$):
$v_{\mathrm{ph},\parallel}^2 = \frac{\omega_p^2}{k^2} + 3 v_{\mathrm{th}}^2$, which becomes
strictly subluminal ($v_{\mathrm{ph},\parallel} < c$) at large wavenumber $k$, enabling
direct Cherenkov / Landau synchronous wakefield excitation. -/
@[blueprint "def:signals-scattering-longitudinal-plasma-phase-vel-sq"
  (title := "Subluminal longitudinal plasma phase velocity squared v_{ph,∥}² = ω_p² / k² + 3 v_th²")
  (statement := /-- Define $\operatorname{longitudinalPlasmaPhaseVelSq}(v_{\mathrm{th}}, \omega_p, k)
    = \omega_p^2 / k^2 + 3 v_{\mathrm{th}}^2$. -/)]
noncomputable def longitudinalPlasmaPhaseVelSq (v_th ω_p k : ℝ) : ℝ :=
  (ω_p ^ 2 / k ^ 2) + 3 * v_th ^ 2

/-- Cherenkov / Smith–Purcell phase-matching cosine $\cos\theta_C = \frac{v_{\mathrm{ph}}}{v_e}$
for wave phase speed $v_{\mathrm{ph}}$ and electron speed $v_e > v_{\mathrm{ph}} > 0$. -/
@[blueprint "def:signals-scattering-cherenkov-cosine"
  (title := "Cherenkov phase-matching cosine cos θ_C = v_ph / v_e")
  (statement := /-- Define $\operatorname{cherenkovCosine}(v_{\mathrm{ph}}, v_e) = v_{\mathrm{ph}} / v_e$. -/)]
noncomputable def cherenkovCosine (v_phase v_electron : ℝ) : ℝ :=
  v_phase / v_electron

/-- Normalized 2D Dirac graphene plasmon squared frequency $\omega_{\mathrm{GPP}}^2(E_F, q) = E_F\,q$
as a function of gate-tuned Fermi energy $E_F$ (in eV) and plasmon wavenumber $q$,
governing how THz/eV graphene circuit gating shifts free-electron SPP amplification
(Zhang et al., 2022, `10.1038/s41586-022-05239-2`). -/
@[blueprint "def:signals-scattering-graphene-dirac-plasmon-freq-sq"
  (title := "Normalized 2D Dirac graphene plasmon squared frequency ω_GPP² = E_F q")
  (statement := /-- Define $\operatorname{grapheneDiracPlasmonFreqSq}(E_F, q) = E_F\,q$. -/)]
def grapheneDiracPlasmonFreqSq (e_fermi q_wave : ℝ) : ℝ :=
  e_fermi * q_wave

/-- Single-step Grover quantum state-carving amplitude $\sin(3\theta) = \sin\theta\,(3 - 4\sin^2\theta)$
from initial target overlap $\sin\theta = 1/\sqrt{N}$ (`10.1103/s3vs-xz7w`). -/
@[blueprint "def:signals-scattering-grover-success-amplitude"
  (title := "Single-step Grover quantum state-carving amplitude sin(3θ) = sin θ (3 - 4 sin²θ)")
  (statement := /-- Define $\operatorname{groverSuccessAmplitude}(s) = s\,(3 - 4 s^2)$. -/)]
def groverSuccessAmplitude (sin_theta : ℝ) : ℝ :=
  sin_theta * (3 - 4 * sin_theta ^ 2)

/-- **CSR-SPP Superradiant Bunching, Cavity QED vs. CSR Distinction, Cherenkov–Proca Longitudinal Phase Matching, Graphene THz-eV Scaling, & Grover State Carving Theorem**:
1. **CSR-SPP Incoherent ($N_e$) to Superradiant ($N_e^2$) Interpolation (Lei et al. 2025)**:
   For $N_e \ge 1$, $0 \le f_{\mathrm{bunch}} \le 1$, and $I_1 \ge 0$:
   - $\operatorname{csrBunchingIntensity}(N_e, 0, I_1) = N_e\,I_1$ (incoherent synchrotron limit),
   - $\operatorname{csrBunchingIntensity}(N_e, 1, I_1) = N_e^2\,I_1$ (ideal SPP microbunched superradiant limit),
   - $N_e\,I_1 \le \operatorname{csrBunchingIntensity}(N_e, f_{\mathrm{bunch}}, I_1) \le N_e^2\,I_1$, and
   - For $\omega_{\mathrm{rot}} > 0$ and $\gamma_e \ge 1$, $\frac{3}{2}\omega_{\mathrm{rot}} \le \operatorname{csrCriticalFrequency}(\omega_{\mathrm{rot}}, \gamma_e)$,
2. **Collective vs. Single-Photon Cavity QED Cooperativity (Kipp et al. 2024 vs. Single-Atom QED)**:
   $\operatorname{cavityQEDCooperativity}(\sqrt{N_e}\,g_0, \kappa_{\mathrm{cav}}, \gamma_{\mathrm{emit}}) = N_e\,\operatorname{cavityQEDCooperativity}(g_0, \kappa_{\mathrm{cav}}, \gamma_{\mathrm{emit}})$,
3. **Transverse Superluminal Prohibition vs. Longitudinal Effective-Mass Cherenkov Cone**:
   - For any propagating transverse plasma wave ($\omega > \omega_p > 0$, $c > 0$),
     $c^2 < \operatorname{transversePlasmaPhaseVelSq}(c, \omega, \omega_p)$, forbidding subluminal transverse Cherenkov emission,
   - Whenever $0 < v_{\mathrm{ph}} < v_e$, the Cherenkov cosine $\chi_C = \operatorname{cherenkovCosine}(v_{\mathrm{ph}}, v_e)$
     satisfies $0 < \chi_C < 1$ and $0 < 1 - \chi_C^2 = \frac{v_e^2 - v_{\mathrm{ph}}^2}{v_e^2} < 1$ (non-degenerate Cherenkov Mach cone),
4. **Graphene THz-eV Gate Tuning of Free-Electron SPP Amplification (Zhang et al. 2022)**:
   Scaling the graphene Fermi energy by $\lambda_E > 0$ scales $\operatorname{grapheneDiracPlasmonFreqSq}(\lambda_E E_F, q) = \lambda_E \operatorname{grapheneDiracPlasmonFreqSq}(E_F, q)$,
5. **Deterministic 4-State Grover Quantum State Carving (`10.1103/s3vs-xz7w`)**:
   At $\sin\theta = 1/\sqrt{4} = 1/2$, a single Grover reflection step achieves unit target amplitude:
   $\operatorname{groverSuccessAmplitude}(1/2) = 1$. -/
@[blueprint "thm:signals-scattering-csr-spp-cherenkov-cavity-grover"
  (title := "CSR-SPP superradiance, Cavity QED cooperativity, Cherenkov-Proca phase matching, Graphene THz-eV scaling, and Grover state carving theorem")
  (statement := /-- For $N_e\ge 1$, $0\le f_{\mathrm{bunch}}\le 1$, $I_1\ge 0$, $\omega_{\mathrm{rot}}>0$, $\gamma_e\ge 1$,
    $c>0$, $0<\omega_p<\omega$, and $0<v_{\mathrm{ph}}<v_e$:
    (1) $\operatorname{csrBunchingIntensity}(N_e,0,I_1)=N_e I_1$, $\operatorname{csrBunchingIntensity}(N_e,1,I_1)=N_e^2 I_1$,
    and $N_e I_1 \le \operatorname{csrBunchingIntensity}(N_e,f_{\mathrm{bunch}},I_1) \le N_e^2 I_1$,
    (2) $\frac{3}{2}\omega_{\mathrm{rot}} \le \operatorname{csrCriticalFrequency}(\omega_{\mathrm{rot}},\gamma_e)$,
    (3) $\operatorname{cavityQEDCooperativity}(\sqrt{N_e}g_0,\kappa,\gamma) = N_e\operatorname{cavityQEDCooperativity}(g_0,\kappa,\gamma)$,
    (4) $c^2 < \operatorname{transversePlasmaPhaseVelSq}(c,\omega,\omega_p)$ and $0 < 1 - \operatorname{cherenkovCosine}(v_{\mathrm{ph}},v_e)^2 < 1$,
    (5) $\operatorname{grapheneDiracPlasmonFreqSq}(\lambda_E E_F, q) = \lambda_E \operatorname{grapheneDiracPlasmonFreqSq}(E_F, q)$, and
    (6) $\operatorname{groverSuccessAmplitude}(1/2) = 1$. -/)
  (proof := /-- Expand `csrBunchingIntensity` at $f_{\mathrm{bunch}}\in\{0,1\}$ and use $0\le f_{\mathrm{bunch}}^2\le 1$,
    clear $\omega^2-\omega_p^2>0$ for transverse superluminality, clear $v_e^2>0$ for the Cherenkov Mach sine,
    and evaluate `groverSuccessAmplitude (1/2)` by `norm_num`. -/)]
theorem csr_spp_cherenkov_cavity_and_grover_identities
    (N_e f_bunch I_single ω_rot γ_e g0 κ_cav γ_emit c ω ω_p v_th k_long v_ph v_e scale_E e_fermi q_wave : ℝ)
    (hN : 1 ≤ N_e) (hf_nonneg : 0 ≤ f_bunch) (hf_le : f_bunch ≤ 1)
    (hI : 0 ≤ I_single) (hω_rot : 0 < ω_rot) (hγ_e : 1 ≤ γ_e)
    (hc : 0 < c) (hωp_pos : 0 < ω_p) (hω_gt : ω_p < ω)
    (hk_pos : 0 < k_long) (h_sub_long : ω_p ^ 2 + 3 * v_th ^ 2 * k_long ^ 2 < c ^ 2 * k_long ^ 2)
    (hv_ph : 0 < v_ph) (hv_lt : v_ph < v_e) :
    let chi_c := cherenkovCosine v_ph v_e
    csrBunchingIntensity N_e 0 I_single = N_e * I_single ∧
      csrBunchingIntensity N_e 1 I_single = N_e ^ 2 * I_single ∧
      N_e * I_single ≤ csrBunchingIntensity N_e f_bunch I_single ∧
      csrBunchingIntensity N_e f_bunch I_single ≤ N_e ^ 2 * I_single ∧
      (3 / 2) * ω_rot ≤ csrCriticalFrequency ω_rot γ_e ∧
      cavityQEDCooperativity (Real.sqrt N_e * g0) κ_cav γ_emit =
        N_e * cavityQEDCooperativity g0 κ_cav γ_emit ∧
      c ^ 2 < transversePlasmaPhaseVelSq c ω ω_p ∧
      longitudinalPlasmaPhaseVelSq v_th ω_p k_long < c ^ 2 ∧
      0 < chi_c ∧
      chi_c < 1 ∧
      1 - chi_c ^ 2 = (v_e ^ 2 - v_ph ^ 2) / v_e ^ 2 ∧
      0 < 1 - chi_c ^ 2 ∧
      grapheneDiracPlasmonFreqSq (scale_E * e_fermi) q_wave =
        scale_E * grapheneDiracPlasmonFreqSq e_fermi q_wave ∧
      groverSuccessAmplitude (1 / 2) = 1 := by
  intro chi_c
  have hN_nonneg : 0 ≤ N_e := le_trans zero_le_one hN
  have hN_sub_nonneg : 0 ≤ N_e - 1 := sub_nonneg.mpr hN
  have hf_sq_le_one : f_bunch ^ 2 ≤ 1 := by nlinarith
  have h_csr0 : csrBunchingIntensity N_e 0 I_single = N_e * I_single := by
    unfold csrBunchingIntensity
    ring
  have h_csr1 : csrBunchingIntensity N_e 1 I_single = N_e ^ 2 * I_single := by
    unfold csrBunchingIntensity
    ring
  have h_csr_ge : N_e * I_single ≤ csrBunchingIntensity N_e f_bunch I_single := by
    unfold csrBunchingIntensity
    have h_term : 0 ≤ N_e * (N_e - 1) * f_bunch ^ 2 := by positivity
    nlinarith
  have h_csr_le : csrBunchingIntensity N_e f_bunch I_single ≤ N_e ^ 2 * I_single := by
    unfold csrBunchingIntensity
    have h_prod_nonneg : 0 ≤ N_e * (N_e - 1) := mul_nonneg hN_nonneg hN_sub_nonneg
    have h_term_le : N_e * (N_e - 1) * f_bunch ^ 2 ≤ N_e * (N_e - 1) :=
      mul_le_of_le_one_right h_prod_nonneg hf_sq_le_one
    have h_sum_le : N_e + N_e * (N_e - 1) * f_bunch ^ 2 ≤ N_e ^ 2 := by nlinarith
    exact mul_le_mul_of_nonneg_right h_sum_le hI
  have h_crit : (3 / 2) * ω_rot ≤ csrCriticalFrequency ω_rot γ_e := by
    unfold csrCriticalFrequency
    have h_pow : 1 ≤ γ_e ^ 3 := one_le_pow₀ hγ_e
    have h_pref : 0 ≤ (3 / 2 : ℝ) * ω_rot := by positivity
    nlinarith
  have h_coop :
      cavityQEDCooperativity (Real.sqrt N_e * g0) κ_cav γ_emit =
        N_e * cavityQEDCooperativity g0 κ_cav γ_emit := by
    unfold cavityQEDCooperativity
    rw [mul_pow, Real.sq_sqrt hN_nonneg]
    ring
  have h_trans_super : c ^ 2 < transversePlasmaPhaseVelSq c ω ω_p := by
    unfold transversePlasmaPhaseVelSq
    have h_diff_pos : 0 < ω ^ 2 - ω_p ^ 2 := by nlinarith
    rw [lt_div_iff₀ h_diff_pos]
    have h_c_sq : 0 < c ^ 2 := sq_pos_of_pos hc
    have h_wp_sq : 0 < ω_p ^ 2 := sq_pos_of_pos hωp_pos
    nlinarith
  have h_long_sub : longitudinalPlasmaPhaseVelSq v_th ω_p k_long < c ^ 2 := by
    unfold longitudinalPlasmaPhaseVelSq
    have hk_sq_pos : 0 < k_long ^ 2 := sq_pos_of_pos hk_pos
    have h_div_lt : ω_p ^ 2 / k_long ^ 2 < c ^ 2 - 3 * v_th ^ 2 := by
      rw [div_lt_iff₀ hk_sq_pos]
      linarith
    linarith
  have hv_e_pos : 0 < v_e := lt_trans hv_ph hv_lt
  have hv_e_ne : v_e ≠ 0 := ne_of_gt hv_e_pos
  have h_chi_pos : 0 < chi_c := div_pos hv_ph hv_e_pos
  have h_chi_lt : chi_c < 1 := (div_lt_one hv_e_pos).mpr hv_lt
  have h_mach_eq : 1 - chi_c ^ 2 = (v_e ^ 2 - v_ph ^ 2) / v_e ^ 2 := by
    dsimp [chi_c, cherenkovCosine]
    field_simp [hv_e_ne]
  have h_mach_pos : 0 < 1 - chi_c ^ 2 := by nlinarith
  have h_gpp :
      grapheneDiracPlasmonFreqSq (scale_E * e_fermi) q_wave =
        scale_E * grapheneDiracPlasmonFreqSq e_fermi q_wave := by
    unfold grapheneDiracPlasmonFreqSq
    ring
  have h_grover : groverSuccessAmplitude (1 / 2) = 1 := by
    unfold groverSuccessAmplitude
    norm_num
  exact ⟨h_csr0, h_csr1, h_csr_ge, h_csr_le, h_crit, h_coop,
    h_trans_super, h_long_sub, h_chi_pos, h_chi_lt, h_mach_eq, h_mach_pos, h_gpp, h_grover⟩

/-! ## Low-Power Integrated Optical Amplification Through Second-Harmonic ($\chi^{(2)}$) Resonance (Dean et al., 2025, `10.1038/s41586-025-09959-z`) -/

/-- Second-order nonlinear polarization $P^{(2)} = \chi^{(2)}\,E^2$: under spatial
inversion $E \mapsto -E$, a centrosymmetric medium satisfies $\chi^{(2)} = -\chi^{(2)}$,
forcing $\chi^{(2)} = 0$ and $P^{(2)} = 0$. -/
@[blueprint "def:signals-scattering-second-order-polarization"
  (title := "Second-order nonlinear polarization P^(2) = χ^(2) E²")
  (statement := /-- Define $\operatorname{secondOrderPolarization}(\chi_2, E) = \chi_2\,E^2$. -/)]
def secondOrderPolarization (chi2 electricField : ℝ) : ℝ :=
  chi2 * electricField ^ 2

/-- Intracavity recirculated second-harmonic ($2\omega_0$) pump power
$P_{2\omega}^{\mathrm{intracav}} = F_{\mathrm{SH}}\,P_{2\omega}^{\mathrm{single}}$
for cavity buildup / finesse enhancement factor $F_{\mathrm{SH}} \ge 1$
(Dean et al., 2025, *Nature*, `10.1038/s41586-025-09959-z`). -/
@[blueprint "def:signals-scattering-shg-intracavity-power"
  (title := "Recirculated second-harmonic intracavity power P_{2ω}^intracav = F_SH P_{2ω}^single")
  (statement := /-- Define $\operatorname{shgResonantIntracavityPower}(F_{\mathrm{SH}}, P_{2\omega})
    = F_{\mathrm{SH}}\,P_{2\omega}$. -/)]
def shgResonantIntracavityPower (finesseBuildup singlePassSHPower : ℝ) : ℝ :=
  finesseBuildup * singlePassSHPower

/-- Phase-mismatched Optical Parametric Amplification (OPA) net squared gain rate
$g_{\mathrm{net}}^2(g_{\mathrm{OPA}}, \Delta k) = g_{\mathrm{OPA}}^2 - (\Delta k / 2)^2$,
governing piezoelectric / electro-optic phase-matching gate control. -/
@[blueprint "def:signals-scattering-opa-net-gain-sq"
  (title := "Phase-mismatched OPA net squared gain rate g_net² = g_OPA² - (Δk/2)²")
  (statement := /-- Define $\operatorname{opaNetGainSq}(g_{\mathrm{OPA}}, \Delta k)
    = g_{\mathrm{OPA}}^2 - (\Delta k / 2)^2$. -/)]
noncomputable def opaNetGainSq (g_opa delta_k : ℝ) : ℝ :=
  g_opa ^ 2 - (delta_k / 2) ^ 2

/-- Phase-sensitive degenerate Optical Parametric Amplifier (OPA) amplified
in-phase quadrature variance $G_+(r_{\mathrm{sq}}) = \exp(2 r_{\mathrm{sq}})$ for
parametric squeeze factor $r_{\mathrm{sq}} = g_{\mathrm{eff}} L \ge 0$. -/
@[blueprint "def:signals-scattering-opa-amplified-quadrature"
  (title := "Phase-sensitive OPA amplified quadrature gain exp(2 r_sq)")
  (statement := /-- Define $\operatorname{opaAmplifiedQuadratureGain}(r_{\mathrm{sq}}) = \exp(2 r_{\mathrm{sq}})$. -/)]
noncomputable def opaAmplifiedQuadratureGain (r_sq : ℝ) : ℝ :=
  Real.exp (2 * r_sq)

/-- Phase-sensitive degenerate Optical Parametric Amplifier (OPA) squeezed
anti-phase quadrature variance $G_-(r_{\mathrm{sq}}) = \exp(-2 r_{\mathrm{sq}})$. -/
@[blueprint "def:signals-scattering-opa-squeezed-quadrature"
  (title := "Phase-sensitive OPA squeezed quadrature factor exp(-2 r_sq)")
  (statement := /-- Define $\operatorname{opaSqueezedQuadratureGain}(r_{\mathrm{sq}}) = \exp(-2 r_{\mathrm{sq}})$. -/)]
noncomputable def opaSqueezedQuadratureGain (r_sq : ℝ) : ℝ :=
  Real.exp (-2 * r_sq)

/-- **Low-Power Second-Harmonic Resonant Optical Parametric Amplification (OPA), Centrosymmetry Selection Rule, & Phase-Matching Gate Theorem**:
1. **Centrosymmetric Inversion Selection Rule ($\chi^{(2)} = 0$)**:
   If spatial inversion invariance forces $\chi_2 = -\chi_2$ (as in centrosymmetric pristine
   graphene or amorphous polymers), then $\chi_2 = 0$ and $\operatorname{secondOrderPolarization}(\chi_2, E) = 0$
   for all $E$, proving that $\chi^{(2)}$ SHG/OPA requires non-centrosymmetric crystals
   (e.g., $\text{LiNbO}_3$, $\alpha$-quartz, or aligned chiral Cellulose Nanocrystals),
2. **Second-Harmonic Resonant Recirculation Enhancement (Dean et al. 2025, `10.1038/s41586-025-09959-z`)**:
   For cavity buildup $F_{\mathrm{SH}} \ge 1$ and $P_{2\omega} \ge 0$,
   $P_{2\omega} \le \operatorname{shgResonantIntracavityPower}(F_{\mathrm{SH}}, P_{2\omega})$,
   and achieving a target intracavity threshold $P_{\mathrm{thresh}}$ requires only
   $P_{2\omega} = P_{\mathrm{thresh}} / F_{\mathrm{SH}} \le P_{\mathrm{thresh}}$,
3. **Phase-Matching Detuning Gate**:
   $\operatorname{opaNetGainSq}(g_{\mathrm{OPA}}, 0) = g_{\mathrm{OPA}}^2$ (maximum gain at $\Delta k = 0$),
   $\operatorname{opaNetGainSq}(g_{\mathrm{OPA}}, \Delta k) \le g_{\mathrm{OPA}}^2$ for all $\Delta k$, and
   $\operatorname{opaNetGainSq}(g_{\mathrm{OPA}}, 2 g_{\mathrm{OPA}}) = 0$ (complete parametric gate shutoff at $\Delta k = 2 g_{\mathrm{OPA}}$),
4. **Symplectic Phase-Sensitive Quadrature Product & Trace Growth**:
   For $r_{\mathrm{sq}} \ge 0$,
   $$1 \le \operatorname{opaAmplifiedQuadratureGain}(r_{\mathrm{sq}}), \qquad
   \operatorname{opaSqueezedQuadratureGain}(r_{\mathrm{sq}}) \le 1,$$
   $$\operatorname{opaAmplifiedQuadratureGain}(r_{\mathrm{sq}})\,\operatorname{opaSqueezedQuadratureGain}(r_{\mathrm{sq}}) = 1.$$ -/
@[blueprint "thm:signals-scattering-second-harmonic-opa"
  (title := "Second-harmonic resonant OPA buildup, centrosymmetry selection rule, phase-matching gate, and symplectic squeezing theorem")
  (statement := /-- For $\chi_2 = -\chi_2$, $F_{\mathrm{SH}}\ge 1$, $P_{2\omega}\ge 0$, and $r_{\mathrm{sq}}\ge 0$:
    (1) $\chi_2 = 0$ and $\operatorname{secondOrderPolarization}(\chi_2, E) = 0$,
    (2) $P_{2\omega} \le \operatorname{shgResonantIntracavityPower}(F_{\mathrm{SH}}, P_{2\omega})$ and
    $\operatorname{shgResonantIntracavityPower}(F_{\mathrm{SH}}, P_{\mathrm{thresh}}/F_{\mathrm{SH}}) = P_{\mathrm{thresh}}$,
    (3) $\operatorname{opaNetGainSq}(g,0) = g^2$, $\operatorname{opaNetGainSq}(g,\Delta k) \le g^2$, and $\operatorname{opaNetGainSq}(g,2g) = 0$, and
    (4) $1 \le \operatorname{opaAmplifiedQuadratureGain}(r_{\mathrm{sq}})$, $\operatorname{opaSqueezedQuadratureGain}(r_{\mathrm{sq}}) \le 1$,
    and $\operatorname{opaAmplifiedQuadratureGain}(r_{\mathrm{sq}})\,\operatorname{opaSqueezedQuadratureGain}(r_{\mathrm{sq}}) = 1$. -/)
  (proof := /-- Solve $\chi_2 = -\chi_2 \implies \chi_2 = 0$ by `linarith`, clear $F_{\mathrm{SH}} > 0$,
    expand $(\Delta k/2)^2 \ge 0$, and use $\exp(2r)\exp(-2r) = \exp(0) = 1$. -/)]
theorem second_harmonic_opa_and_centrosymmetry_identities
    (chi2 E F_sh P_2w P_thresh g_opa delta_k r_sq : ℝ)
    (h_centro : chi2 = -chi2) (hF_ge : 1 ≤ F_sh) (hP : 0 ≤ P_2w)
    (hr_sq : 0 ≤ r_sq) :
    chi2 = 0 ∧
      secondOrderPolarization chi2 E = 0 ∧
      P_2w ≤ shgResonantIntracavityPower F_sh P_2w ∧
      shgResonantIntracavityPower F_sh (P_thresh / F_sh) = P_thresh ∧
      opaNetGainSq g_opa 0 = g_opa ^ 2 ∧
      opaNetGainSq g_opa delta_k ≤ g_opa ^ 2 ∧
      opaNetGainSq g_opa (2 * g_opa) = 0 ∧
      1 ≤ opaAmplifiedQuadratureGain r_sq ∧
      opaSqueezedQuadratureGain r_sq ≤ 1 ∧
      opaAmplifiedQuadratureGain r_sq * opaSqueezedQuadratureGain r_sq = 1 := by
  have h_chi_zero : chi2 = 0 := by linarith
  have h_pol_zero : secondOrderPolarization chi2 E = 0 := by
    unfold secondOrderPolarization
    rw [h_chi_zero, zero_mul]
  have h_buildup_le : P_2w ≤ shgResonantIntracavityPower F_sh P_2w := by
    unfold shgResonantIntracavityPower
    nlinarith
  have hF_pos : 0 < F_sh := lt_of_lt_of_le zero_lt_one hF_ge
  have hF_ne : F_sh ≠ 0 := ne_of_gt hF_pos
  have h_thresh : shgResonantIntracavityPower F_sh (P_thresh / F_sh) = P_thresh := by
    unfold shgResonantIntracavityPower
    exact mul_div_cancel₀ P_thresh hF_ne
  have h_gain0 : opaNetGainSq g_opa 0 = g_opa ^ 2 := by
    unfold opaNetGainSq
    ring
  have h_gain_le : opaNetGainSq g_opa delta_k ≤ g_opa ^ 2 := by
    unfold opaNetGainSq
    have : 0 ≤ (delta_k / 2) ^ 2 := sq_nonneg (delta_k / 2)
    linarith
  have h_gain_cutoff : opaNetGainSq g_opa (2 * g_opa) = 0 := by
    unfold opaNetGainSq
    ring
  have h_amp_ge : 1 ≤ opaAmplifiedQuadratureGain r_sq := by
    unfold opaAmplifiedQuadratureGain
    exact Real.one_le_exp (by linarith)
  have h_sq_le : opaSqueezedQuadratureGain r_sq ≤ 1 := by
    unfold opaSqueezedQuadratureGain
    exact Real.exp_le_one_iff.mpr (by linarith)
  have h_symp_prod :
      opaAmplifiedQuadratureGain r_sq * opaSqueezedQuadratureGain r_sq = 1 := by
    unfold opaAmplifiedQuadratureGain opaSqueezedQuadratureGain
    rw [← Real.exp_add]
    have h_zero : 2 * r_sq + -2 * r_sq = 0 := by ring
    rw [h_zero, Real.exp_zero]
  exact ⟨h_chi_zero, h_pol_zero, h_buildup_le, h_thresh,
    h_gain0, h_gain_le, h_gain_cutoff, h_amp_ge, h_sq_le, h_symp_prod⟩

/-! ## AdS/CFT Correspondence (Maldacena 1998, GKPW 1998, KSS 2005, Ryu–Takayanagi 2006), AdS/CFT Integrability (Beisert et al. 2012, `arXiv:1012.3982`), and Secret Symmetries (`arXiv:1204.2366`) -/

/-- Planar 't Hooft coupling $\lambda = g_{\mathrm{YM}}^2 N_c$ in $SU(N_c)$ $\mathcal{N}=4$
Super Yang–Mills theory (Maldacena 1998, `arXiv:hep-th/9711200`; 't Hooft 1974). -/
@[blueprint "def:signals-scattering-ads-thooft-coupling"
  (title := "Planar 't Hooft coupling λ = g_YM² N_c")
  (statement := /-- Define $\operatorname{adsTftHooftCoupling}(g_{\mathrm{YM}}, N_c) = g_{\mathrm{YM}}^2 N_c$. -/)]
def adsTftHooftCoupling (g_YM N_c : ℝ) : ℝ :=
  g_YM ^ 2 * N_c

/-- AdS/CFT coupling–tension dictionary $\lambda = 4\pi^2 T_{\mathrm{str}}^2$, relating
the planar 't Hooft coupling $\lambda$ to the effective $\text{AdS}_5 \times S^5$ string
tension $T_{\mathrm{str}} = R_{\mathrm{AdS}}^2 / (2\pi\alpha')$
(Beisert et al., 2012, *Review of AdS/CFT Integrability*, `arXiv:1012.3982`). -/
@[blueprint "def:signals-scattering-ads-coupling-from-tension"
  (title := "AdS/CFT coupling-tension dictionary λ = 4π² T_str²")
  (statement := /-- Define $\operatorname{adsCouplingFromStringTension}(T_{\mathrm{str}})
    = 4\pi^2 T_{\mathrm{str}}^2$. -/)]
noncomputable def adsCouplingFromStringTension (T_str : ℝ) : ℝ :=
  4 * Real.pi ^ 2 * T_str ^ 2

/-- Breitenlohner–Freedman (BF) tachyon stability bound $m_{\mathrm{BF}}^2 R_{\mathrm{AdS}}^2 = -d^2 / 4$
for a scalar field in $\text{AdS}_{d+1}$ (Breitenlohner & Freedman, 1982). -/
@[blueprint "def:signals-scattering-ads-bf-bound"
  (title := "Breitenlohner-Freedman stability bound m_BF² R_AdS² = -d² / 4")
  (statement := /-- Define $\operatorname{adsBreitenlohnerFreedmanBound}(d) = -d^2 / 4$. -/)]
noncomputable def adsBreitenlohnerFreedmanBound (d : ℝ) : ℝ :=
  -(d ^ 2) / 4

/-- Gubser–Klebanov–Polyakov–Witten (GKPW) normalizable CFT operator scaling dimension
$\Delta_+(d, m^2 R_{\mathrm{AdS}}^2) = \frac{d}{2} + \sqrt{(d/2)^2 + m^2 R_{\mathrm{AdS}}^2}$
(Gubser, Klebanov & Polyakov 1998, `arXiv:hep-th/9802109`; Witten 1998, `arXiv:hep-th/9802150`). -/
@[blueprint "def:signals-scattering-ads-cft-scaling-dim-plus"
  (title := "GKPW normalizable scaling dimension Δ_+ = d/2 + √((d/2)² + m² R_AdS²)")
  (statement := /-- Define $\operatorname{adsCftScalingDimensionPlus}(d, m_{\mathrm{eff}}^2)
    = d/2 + \sqrt{(d/2)^2 + m_{\mathrm{eff}}^2}$. -/)]
noncomputable def adsCftScalingDimensionPlus (d m_sq_R_sq : ℝ) : ℝ :=
  d / 2 + Real.sqrt ((d / 2) ^ 2 + m_sq_R_sq)

/-- GKPW conjugate (source/shadow) scaling dimension
$\Delta_-(d, m^2 R_{\mathrm{AdS}}^2) = \frac{d}{2} - \sqrt{(d/2)^2 + m^2 R_{\mathrm{AdS}}^2}$. -/
@[blueprint "def:signals-scattering-ads-cft-scaling-dim-minus"
  (title := "GKPW shadow scaling dimension Δ_- = d/2 - √((d/2)² + m² R_AdS²)")
  (statement := /-- Define $\operatorname{adsCftScalingDimensionMinus}(d, m_{\mathrm{eff}}^2)
    = d/2 - \sqrt{(d/2)^2 + m_{\mathrm{eff}}^2}$. -/)]
noncomputable def adsCftScalingDimensionMinus (d m_sq_R_sq : ℝ) : ℝ :=
  d / 2 - Real.sqrt ((d / 2) ^ 2 + m_sq_R_sq)

/-- Kovtun–Son–Starinets (KSS) holographic shear-viscosity-to-entropy-density bound
$(\eta / s)_{\mathrm{KSS}} = \frac{\hbar}{4\pi k_B}$ (Kovtun, Son & Starinets, 2005,
`arXiv:hep-th/0405231`). -/
@[blueprint "def:signals-scattering-kss-viscosity-bound"
  (title := "Kovtun-Son-Starinets holographic viscosity bound η/s = ℏ / (4π k_B)")
  (statement := /-- Define $\operatorname{kssShearViscosityEntropyBound}(\hbar, k_B)
    = \hbar / (4\pi k_B)$. -/)]
noncomputable def kssShearViscosityEntropyBound (hbar k_B : ℝ) : ℝ :=
  hbar / (4 * Real.pi * k_B)

/-- Brown–Henneaux $\text{AdS}_3/\text{CFT}_2$ central charge
$c_{\mathrm{BH}} = \frac{3 R_{\mathrm{AdS}}}{2 G_N^{(3)}}$ (Brown & Henneaux, 1986). -/
@[blueprint "def:signals-scattering-brown-henneaux-central-charge"
  (title := "Brown-Henneaux AdS_3/CFT_2 central charge c_BH = 3 R_AdS / (2 G_N^(3))")
  (statement := /-- Define $\operatorname{brownHenneauxCentralCharge}(R_{\mathrm{AdS}}, G_N)
    = 3 R_{\mathrm{AdS}} / (2 G_N)$. -/)]
noncomputable def brownHenneauxCentralCharge (R_ads G_N3 : ℝ) : ℝ :=
  (3 * R_ads) / (2 * G_N3)

/-- Ryu–Takayanagi $\text{AdS}_3/\text{CFT}_2$ holographic entanglement entropy
$S_{\mathrm{EE}}(\ell, \epsilon_{\mathrm{UV}}) = \frac{R_{\mathrm{AdS}}}{2 G_N^{(3)}}\ln(\ell / \epsilon_{\mathrm{UV}}) = \frac{c_{\mathrm{BH}}}{3}\ln(\ell / \epsilon_{\mathrm{UV}})$
(Ryu & Takayanagi, 2006, `arXiv:hep-th/0603001`). -/
@[blueprint "def:signals-scattering-ryu-takayanagi-ee-ads3"
  (title := "Ryu-Takayanagi AdS_3/CFT_2 entanglement entropy S_EE = (R_AdS / (2 G_N)) ln(ℓ / ε_UV)")
  (statement := /-- Define $\operatorname{ryuTakayanagiEntanglementEntropyAdS3}(R_{\mathrm{AdS}}, G_N, \ell, \epsilon_{\mathrm{UV}})
    = (R_{\mathrm{AdS}} / (2 G_N))\ln(\ell / \epsilon_{\mathrm{UV}})$. -/)]
noncomputable def ryuTakayanagiEntanglementEntropyAdS3
    (R_ads G_N3 l_interval eps_uv : ℝ) : ℝ :=
  (R_ads / (2 * G_N3)) * Real.log (l_interval / eps_uv)

/-- All-loop $\mathfrak{psu}(2|2)^2 \ltimes \mathbb{R}^3$ bound-state magnon squared
dispersion relation $E_{\mathrm{mag}}^2(M, \lambda, p) = M^2 + \frac{\lambda}{\pi^2}\sin^2(p/2)$
(Beisert 2005, `arXiv:hep-th/0511082`; Beisert et al. 2012, `arXiv:1012.3982`, Sec. III.2). -/
@[blueprint "def:signals-scattering-ads-magnon-dispersion-sq"
  (title := "All-loop AdS/CFT bound-state magnon dispersion squared E² = M² + (λ/π²) sin²(p/2)")
  (statement := /-- Define $\operatorname{adsMagnonDispersionSq}(M, \lambda, p)
    = M^2 + (\lambda / \pi^2)\sin^2(p/2)$. -/)]
noncomputable def adsMagnonDispersionSq (M_bound lam p : ℝ) : ℝ :=
  M_bound ^ 2 + (lam / Real.pi ^ 2) * (Real.sin (p / 2)) ^ 2

/-- All-loop AdS/CFT bound-state magnon energy
$E_{\mathrm{mag}}(M, \lambda, p) = \sqrt{M^2 + \frac{\lambda}{\pi^2}\sin^2(p/2)}$. -/
@[blueprint "def:signals-scattering-ads-magnon-dispersion"
  (title := "All-loop AdS/CFT bound-state magnon energy E = √(M² + (λ/π²) sin²(p/2))")
  (statement := /-- Define $\operatorname{adsMagnonDispersion}(M, \lambda, p)
    = \sqrt{\operatorname{adsMagnonDispersionSq}(M, \lambda, p)}$. -/)]
noncomputable def adsMagnonDispersion (M_bound lam p : ℝ) : ℝ :=
  Real.sqrt (adsMagnonDispersionSq M_bound lam p)

/-- Single-magnon one-loop planar Bethe energy contribution
$\delta D_1(\lambda, u) = \frac{\lambda}{8\pi^2}\,\frac{1}{u^2 + 1/4}$
for Bethe rapidity $u$ (Minahan & Zarembo 2003, `arXiv:hep-th/0212208`;
Beisert et al. 2012, `arXiv:1012.3982`, Sec. I.1). -/
@[blueprint "def:signals-scattering-bethe-one-loop-magnon-energy"
  (title := "One-loop planar Bethe magnon anomalous dimension δD_1(λ, u) = (λ / 8π²) / (u² + 1/4)")
  (statement := /-- Define $\operatorname{betheOneLoopMagnonEnergy}(\lambda, u)
    = (\lambda / (8\pi^2)) / (u^2 + 1/4)$. -/)]
noncomputable def betheOneLoopMagnonEnergy (lam u : ℝ) : ℝ :=
  (lam / (8 * Real.pi ^ 2)) / (u ^ 2 + 1 / 4)

/-- Planar one-loop anomalous dimension of the Konishi operator ($L=4, M=2$, Bethe roots
$u_1 = -u_2 = \frac{1}{2\sqrt{3}}$, $u_k^2 = 1/12$):
$\delta D_{\mathrm{Konishi}}^{(1)}(\lambda) = \frac{3\lambda}{4\pi^2}$
(Beisert et al. 2012, `arXiv:1012.3982`, Sec. I.2). -/
@[blueprint "def:signals-scattering-konishi-one-loop"
  (title := "Konishi one-loop anomalous dimension δD_Konishi^(1) = 3λ / (4π²)")
  (statement := /-- Define $\operatorname{konishiOneLoopAnomalousDim}(\lambda)
    = 3\lambda / (4\pi^2)$. -/)]
noncomputable def konishiOneLoopAnomalousDim (lam : ℝ) : ℝ :=
  (3 * lam) / (4 * Real.pi ^ 2)

/-- One-loop planar cusp anomalous dimension
$D_{\mathrm{cusp}}^{(1)}(\lambda) = \frac{\lambda}{2\pi^2}$
(Beisert et al. 2012, `arXiv:1012.3982`, Sec. III.4). -/
@[blueprint "def:signals-scattering-cusp-one-loop"
  (title := "One-loop cusp anomalous dimension D_cusp^(1) = λ / (2π²)")
  (statement := /-- Define $\operatorname{cuspAnomalousDimOneLoop}(\lambda)
    = \lambda / (2\pi^2)$. -/)]
noncomputable def cuspAnomalousDimOneLoop (lam : ℝ) : ℝ :=
  lam / (2 * Real.pi ^ 2)

/-- Three-loop weak-coupling planar cusp anomalous dimension expansion
$D_{\mathrm{cusp}}^{\mathrm{weak},3}(\lambda) = \frac{\lambda}{2\pi^2} - \frac{\lambda^2}{96\pi^2} + \frac{11\lambda^3}{23040\pi^2}$
(Beisert, Eden & Staudacher 2007; Beisert et al. 2012, `arXiv:1012.3982`, Sec. III.4). -/
@[blueprint "def:signals-scattering-cusp-weak-3loop"
  (title := "Three-loop weak-coupling cusp anomalous dimension expansion")
  (statement := /-- Define $\operatorname{cuspAnomalousDimWeak3Loop}(\lambda)
    = \frac{\lambda}{2\pi^2} - \frac{\lambda^2}{96\pi^2} + \frac{11\lambda^3}{23040\pi^2}$. -/)]
noncomputable def cuspAnomalousDimWeak3Loop (lam : ℝ) : ℝ :=
  lam / (2 * Real.pi ^ 2) - lam ^ 2 / (96 * Real.pi ^ 2) +
    (11 * lam ^ 3) / (23040 * Real.pi ^ 2)

/-- Braided central charge $\mathbb{C}(p) = e^{ip} - 1$ of the centrally extended
Hopf superalgebra $\mathfrak{psl}(2|2)_c = D(2,1;-1)$
(de Leeuw, Matsumoto, Moriyama, Regelskis & Torrielli, 2012, *Secret Symmetries in AdS/CFT*,
`arXiv:1204.2366`, Eq. (2.4)). -/
@[blueprint "def:signals-scattering-psl22-braided-c"
  (title := "Centrally extended psl(2|2)_c braided central charge C(p) = e^{ip} - 1")
  (statement := /-- Define $\operatorname{psl22BraidedCentralChargeC}(p) = \exp(ip) - 1$. -/)]
noncomputable def psl22BraidedCentralChargeC (p : ℝ) : ℂ :=
  Complex.exp (Complex.I * ↑p) - 1

/-- Conjugate braided central charge $\mathbb{C}^\dagger(p) = e^{-ip} - 1$ of $\mathfrak{psl}(2|2)_c$
(`arXiv:1204.2366`, Eq. (2.4)). -/
@[blueprint "def:signals-scattering-psl22-braided-cdag"
  (title := "Conjugate braided central charge C†(p) = e^{-ip} - 1")
  (statement := /-- Define $\operatorname{psl22BraidedCentralChargeCDag}(p) = \exp(-ip) - 1$. -/)]
noncomputable def psl22BraidedCentralChargeCDag (p : ℝ) : ℂ :=
  Complex.exp (-Complex.I * ↑p) - 1

/-- Quasi-cocommutative two-site braided coproduct eigenvalue
$\Delta(\mathbb{C})(C_1, C_2) = C_1 + C_2 + C_1 C_2$ (`arXiv:1204.2366`, Eq. (2.5)). -/
@[blueprint "def:signals-scattering-psl22-braided-coproduct-c"
  (title := "Quasi-cocommutative braided coproduct Δ(C) = C_1 + C_2 + C_1 C_2")
  (statement := /-- Define $\operatorname{psl22BraidedCoproductC}(C_1, C_2) = C_1 + C_2 + C_1 C_2$. -/)]
def psl22BraidedCoproductC (C1 C2 : ℂ) : ℂ :=
  C1 + C2 + C1 * C2

/-- Typical (long) representation dimension $\dim V_{\mathrm{long}}(j_1, j_2) = 16(2 j_1 + 1)(2 j_2 + 1)$
of $\mathfrak{gl}(2|2)$ (`arXiv:1204.2366`, Sec. 2.3). -/
@[blueprint "def:signals-scattering-gl22-long-rep-dim"
  (title := "Typical (long) gl(2|2) representation dimension 16(2j_1 + 1)(2j_2 + 1)")
  (statement := /-- Define $\operatorname{gl22LongRepDim}(j_1, j_2) = 16(2j_1 + 1)(2j_2 + 1)$. -/)]
def gl22LongRepDim (j1 j2 : ℝ) : ℝ :=
  16 * (2 * j1 + 1) * (2 * j2 + 1)

/-- Atypical (short / bound-state) representation dimension $\dim V_{\mathrm{short}}(M) = 4 M$
of $\mathfrak{psl}(2|2)_c$ (`arXiv:1204.2366`, Sec. 2.3). -/
@[blueprint "def:signals-scattering-psl22-short-bound-dim"
  (title := "Atypical (short) psl(2|2)_c bound-state dimension 4M")
  (statement := /-- Define $\operatorname{psl22ShortBoundStateDim}(M) = 4 M$. -/)]
def psl22ShortBoundStateDim (M_bound : ℝ) : ℝ :=
  4 * M_bound

/-- Supertrace $\operatorname{STr}(M) = (M_{00} + M_{11}) - (M_{22} + M_{33})$ on a $(2|2)$-graded
matrix $M \in \mathbb{R}^{4 \times 4}$ (`arXiv:1204.2366`, Sec. 2.3 & Sec. 3.4). -/
@[blueprint "def:signals-scattering-supertrace22"
  (title := "(2|2)-graded matrix supertrace STr(M) = M_00 + M_11 - M_22 - M_33")
  (statement := /-- Define $\operatorname{supertrace22}(M) = M_{00} + M_{11} - M_{22} - M_{33}$. -/)]
def supertrace22 (M : Matrix (Fin 4) (Fin 4) ℝ) : ℝ :=
  M 0 0 + M 1 1 - M 2 2 - M 3 3

/-- Indented Yangian secret/bonus symmetry generator
$\widehat{\mathbb{B}}(B_0) = B_0\,\operatorname{diag}(1, 1, -1, -1)$ in the $4$-dimensional
fundamental representation of $\mathfrak{psl}(2|2)_c$
(Matsumoto, Moriyama & Torrielli 2007, `arXiv:0708.1285`; de Leeuw et al. 2012, `arXiv:1204.2366`, Eq. (3.2)). -/
@[blueprint "def:signals-scattering-secret-symmetry-matrix"
  (title := "Indented Yangian secret symmetry matrix B̂ = B_0 diag(1, 1, -1, -1)")
  (statement := /-- Define $\operatorname{secretSymmetryMatrix}(B_0) = \operatorname{diag}(B_0, B_0, -B_0, -B_0)$. -/)]
def secretSymmetryMatrix (B0 : ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  !![B0, 0, 0, 0;
     0, B0, 0, 0;
     0, 0, -B0, 0;
     0, 0, 0, -B0]

/-- Symmetric Cartan matrix $DA$ of the quantum-deformed Hubbard / AdS–CFT affine algebra
$\widehat{Q} = U_q(\widehat{\mathfrak{sl}}(2|2))_c$ (`arXiv:1204.2366`, Eq. (3.15)). -/
@[blueprint "def:signals-scattering-q-deformed-hubbard-cartan-da"
  (title := "Quantum-deformed Hubbard/AdS-CFT symmetric Cartan matrix DA")
  (statement := /-- Define the $4\times 4$ symmetric Cartan matrix $DA$ of `arXiv:1204.2366` Eq. (3.15). -/)]
def qDeformedHubbardCartanDA : Matrix (Fin 4) (Fin 4) ℝ :=
  !![2, -1, 0, -1;
     -1, 0, 1, 0;
     0, 1, -2, 1;
     -1, 0, 1, 0]

/-- **AdS/CFT Dictionary (Maldacena 1998, GKPW 1998, KSS 2005, Ryu–Takayanagi 2006), Planar Integrability (`arXiv:1012.3982`), & Secret Symmetries (`arXiv:1204.2366`) Theorem**:
1. **GKPW Mass–Dimension Dictionary & Breitenlohner–Freedman Stability Bound**:
   For $d > 0$ and $m^2 R_{\mathrm{AdS}}^2 \ge \operatorname{adsBreitenlohnerFreedmanBound}(d) = -d^2 / 4$:
   - $\Delta_+(d, m^2 R_{\mathrm{AdS}}^2) + \Delta_-(d, m^2 R_{\mathrm{AdS}}^2) = d$,
   - $\Delta_+(d, m^2 R_{\mathrm{AdS}}^2)\,\Delta_-(d, m^2 R_{\mathrm{AdS}}^2) = -m^2 R_{\mathrm{AdS}}^2$,
   - $\Delta_+(d, m^2 R_{\mathrm{AdS}}^2)\bigl(\Delta_+(d, m^2 R_{\mathrm{AdS}}^2) - d\bigr) = m^2 R_{\mathrm{AdS}}^2$,
   - At the Breitenlohner–Freedman bound: $\Delta_+(d, -d^2 / 4) = d / 2$,
   - For a massless bulk scalar ($m^2 R_{\mathrm{AdS}}^2 = 0$): $\Delta_+(d, 0) = d$ and $\Delta_-(d, 0) = 0$,
2. **Ryu–Takayanagi $\text{AdS}_3/\text{CFT}_2$ Entanglement Entropy & KSS Viscosity Bound**:
   - $S_{\mathrm{EE}}(\ell, \epsilon_{\mathrm{UV}}) = \frac{c_{\mathrm{BH}}}{3}\ln(\ell / \epsilon_{\mathrm{UV}})$,
   - $0 < \operatorname{kssShearViscosityEntropyBound}(\hbar, k_B)$ for $\hbar > 0, k_B > 0$,
3. **Planar Integrability (`arXiv:1012.3982`): BPS Ground State, All-Loop Magnon Dispersion, & Konishi One-Loop Check Figure**:
   - $\operatorname{adsMagnonDispersion}(M, \lambda, 0) = M$ for $M > 0$ (zero-momentum BPS protection),
   - $M^2 \le \operatorname{adsMagnonDispersionSq}(M, \lambda, p)$ for $\lambda \ge 0$,
   - At the Konishi Bethe root $u_{\mathrm{K}}^2 = 1 / 12$, the two-magnon one-loop anomalous dimension satisfies
     $$2 \cdot \operatorname{betheOneLoopMagnonEnergy}(\lambda, u_{\mathrm{K}}) = \operatorname{konishiOneLoopAnomalousDim}(\lambda) = \frac{3\lambda}{4\pi^2},$$
4. **Secret Symmetries in AdS/CFT (`arXiv:1204.2366`)**:
   - **Braided Central-Charge Quadratic Constraint (`Eq. (2.5)`)**:
     $$\mathbb{C}(p)\,\mathbb{C}^\dagger(p) + \mathbb{C}(p) + \mathbb{C}^\dagger(p) = 0,$$
   - **Quasi-Cocommutativity & Two-Magnon Braided Phase Factorization (`Eq. (2.4)–(2.5)`)**:
     $$\operatorname{psl22BraidedCoproductC}(C_1, C_2) = \operatorname{psl22BraidedCoproductC}(C_2, C_1),$$
     $$(1 + \mathbb{C}(p_1))(1 + \mathbb{C}(p_2)) = 1 + \operatorname{psl22BraidedCoproductC}(\mathbb{C}(p_1), \mathbb{C}(p_2)),$$
   - **Short vs. Long Representation Dimension Compression (`Sec. 2.3`)**:
     $\operatorname{gl22LongRepDim}(0, 0) = 16$, $\operatorname{psl22ShortBoundStateDim}(1) = 4$, and
     $\operatorname{psl22ShortBoundStateDim}(M) < \operatorname{gl22LongRepDim}(M / 2, 0)$ for $M > 0$,
   - **Indented Yangian Secret Generator Supertrace (`Eq. (3.2)` & `Sec. 3.4`)**:
     $\operatorname{Matrix.trace}(\operatorname{secretSymmetryMatrix} B_0) = 0$ and
     $\operatorname{supertrace22}(\operatorname{secretSymmetryMatrix} B_0) = 4 B_0$,
   - **$q$-Deformed Hubbard Affine Cartan Degeneracy (`Eq. (3.15)`)**:
     $\operatorname{Matrix.trace}(\operatorname{qDeformedHubbardCartanDA}) = 0$ and
     $\operatorname{Matrix.det}(\operatorname{qDeformedHubbardCartanDA}) = 0$. -/
@[blueprint "thm:signals-scattering-ads-cft-integrability-secret-symmetry"
  (title := "AdS/CFT GKPW dictionary, Ryu-Takayanagi entropy, KSS bound, Konishi Bethe check figure, and psl(2|2)_c secret symmetry theorem")
  (statement := /-- For $d > 0$, $m_{\mathrm{eff}}^2 \ge -d^2/4$, $\hbar > 0$, $k_B > 0$, $G_N > 0$, $M > 0$, $\lambda \ge 0$, and $u_{\mathrm{K}}^2 = 1/12$:
    (1) $\Delta_+ + \Delta_- = d$, $\Delta_+\Delta_- = -m_{\mathrm{eff}}^2$, $\Delta_+(\Delta_+ - d) = m_{\mathrm{eff}}^2$, $\Delta_+(d, -d^2/4) = d/2$, and $\Delta_+(d, 0) = d$,
    (2) $S_{\mathrm{EE}} = (c_{\mathrm{BH}}/3)\ln(\ell/\epsilon_{\mathrm{UV}})$ and $0 < (\eta/s)_{\mathrm{KSS}}$,
    (3) $E_{\mathrm{mag}}(M, \lambda, 0) = M$, $M^2 \le E_{\mathrm{mag}}^2(M, \lambda, p)$, and $2\delta D_1(\lambda, u_{\mathrm{K}}) = \delta D_{\mathrm{Konishi}}^{(1)}(\lambda) = 3\lambda/(4\pi^2)$, and
    (4) $\mathbb{C}(p)\mathbb{C}^\dagger(p) + \mathbb{C}(p) + \mathbb{C}^\dagger(p) = 0$, $(1+\mathbb{C}(p_1))(1+\mathbb{C}(p_2)) = 1 + \Delta(\mathbb{C})(\mathbb{C}(p_1),\mathbb{C}(p_2))$,
    $\operatorname{STr}(\widehat{\mathbb{B}}(B_0)) = 4 B_0$, and $\det(DA) = 0$. -/)
  (proof := /-- Use `Real.sq_sqrt` above the Breitenlohner-Freedman bound, `Complex.exp_add` for the braided central charges,
    and finite matrix evaluation for $\widehat{\mathbb{B}}$ and $DA$. -/)]
theorem ads_cft_integrability_and_secret_symmetry_identities
    (d m_sq_R_sq hbar k_B R_ads G_N3 l_int eps_uv M_bound lam T_str p u_K p1 p2 B0 : ℝ)
    (hd_pos : 0 < d) (h_bf : adsBreitenlohnerFreedmanBound d ≤ m_sq_R_sq)
    (hhbar : 0 < hbar) (hkB : 0 < k_B) (hGN : 0 < G_N3)
    (hM_pos : 0 < M_bound) (hlam_nonneg : 0 ≤ lam)
    (hu_K : u_K ^ 2 = 1 / 12) :
    let Δ_p := adsCftScalingDimensionPlus d m_sq_R_sq
    let Δ_m := adsCftScalingDimensionMinus d m_sq_R_sq
    let C_p := psl22BraidedCentralChargeC p
    let CDag_p := psl22BraidedCentralChargeCDag p
    let C_1 := psl22BraidedCentralChargeC p1
    let C_2 := psl22BraidedCentralChargeC p2
    Δ_p + Δ_m = d ∧
      Δ_p * Δ_m = -m_sq_R_sq ∧
      Δ_p * (Δ_p - d) = m_sq_R_sq ∧
      adsCftScalingDimensionPlus d (adsBreitenlohnerFreedmanBound d) = d / 2 ∧
      adsCftScalingDimensionPlus d 0 = d ∧
      adsCftScalingDimensionMinus d 0 = 0 ∧
      ryuTakayanagiEntanglementEntropyAdS3 R_ads G_N3 l_int eps_uv =
        (brownHenneauxCentralCharge R_ads G_N3 / 3) * Real.log (l_int / eps_uv) ∧
      0 < kssShearViscosityEntropyBound hbar k_B ∧
      adsCouplingFromStringTension (Real.sqrt lam / (2 * Real.pi)) = lam ∧
      adsMagnonDispersion M_bound lam 0 = M_bound ∧
      adsMagnonDispersionSq M_bound (adsCouplingFromStringTension T_str) Real.pi =
        M_bound ^ 2 + 4 * T_str ^ 2 ∧
      M_bound ^ 2 ≤ adsMagnonDispersionSq M_bound lam p ∧
      2 * betheOneLoopMagnonEnergy lam u_K = konishiOneLoopAnomalousDim lam ∧
      konishiOneLoopAnomalousDim lam = (3 / 2) * cuspAnomalousDimOneLoop lam ∧
      cuspAnomalousDimWeak3Loop 0 = 0 ∧
      C_p * CDag_p + C_p + CDag_p = 0 ∧
      psl22BraidedCoproductC C_1 C_2 = psl22BraidedCoproductC C_2 C_1 ∧
      (1 + C_1) * (1 + C_2) = 1 + psl22BraidedCoproductC C_1 C_2 ∧
      gl22LongRepDim 0 0 = 16 ∧
      psl22ShortBoundStateDim 1 = 4 ∧
      psl22ShortBoundStateDim M_bound < gl22LongRepDim (M_bound / 2) 0 ∧
      Matrix.trace (secretSymmetryMatrix B0) = 0 ∧
      supertrace22 (secretSymmetryMatrix B0) = 4 * B0 ∧
      qDeformedHubbardCartanDA.transpose = qDeformedHubbardCartanDA ∧
      Matrix.mulVec qDeformedHubbardCartanDA ![1, 1, 1, 1] = 0 ∧
      Matrix.trace qDeformedHubbardCartanDA = 0 ∧
      Matrix.det qDeformedHubbardCartanDA = 0 := by
  intro Δ_p Δ_m C_p CDag_p C_1 C_2
  have h_disc_nonneg : 0 ≤ (d / 2) ^ 2 + m_sq_R_sq := by
    unfold adsBreitenlohnerFreedmanBound at h_bf
    linarith
  have h_sqrt_sq : (Real.sqrt ((d / 2) ^ 2 + m_sq_R_sq)) ^ 2 = (d / 2) ^ 2 + m_sq_R_sq :=
    Real.sq_sqrt h_disc_nonneg
  have h_sum : Δ_p + Δ_m = d := by
    dsimp [Δ_p, Δ_m, adsCftScalingDimensionPlus, adsCftScalingDimensionMinus]
    ring
  have h_prod : Δ_p * Δ_m = -m_sq_R_sq := by
    dsimp [Δ_p, Δ_m, adsCftScalingDimensionPlus, adsCftScalingDimensionMinus]
    calc
      (d / 2 + Real.sqrt ((d / 2) ^ 2 + m_sq_R_sq)) *
          (d / 2 - Real.sqrt ((d / 2) ^ 2 + m_sq_R_sq)) =
        (d / 2) ^ 2 - (Real.sqrt ((d / 2) ^ 2 + m_sq_R_sq)) ^ 2 := by ring
      _ = (d / 2) ^ 2 - ((d / 2) ^ 2 + m_sq_R_sq) := by rw [h_sqrt_sq]
      _ = -m_sq_R_sq := by ring
  have h_quad : Δ_p * (Δ_p - d) = m_sq_R_sq := by
    have h_sub : Δ_p - d = -Δ_m := by linarith [h_sum]
    rw [h_sub]
    calc
      Δ_p * (-Δ_m) = -(Δ_p * Δ_m) := by ring
      _ = -(-m_sq_R_sq) := by rw [h_prod]
      _ = m_sq_R_sq := by ring
  have h_at_bf : adsCftScalingDimensionPlus d (adsBreitenlohnerFreedmanBound d) = d / 2 := by
    unfold adsCftScalingDimensionPlus adsBreitenlohnerFreedmanBound
    have h_zero : (d / 2) ^ 2 + -(d ^ 2) / 4 = 0 := by ring
    rw [h_zero, Real.sqrt_zero, add_zero]
  have hd2_nonneg : 0 ≤ d / 2 := by linarith
  have h_massless_p : adsCftScalingDimensionPlus d 0 = d := by
    unfold adsCftScalingDimensionPlus
    rw [add_zero, Real.sqrt_sq hd2_nonneg]
    ring
  have h_massless_m : adsCftScalingDimensionMinus d 0 = 0 := by
    unfold adsCftScalingDimensionMinus
    rw [add_zero, Real.sqrt_sq hd2_nonneg]
    ring
  have hGN_ne : G_N3 ≠ 0 := ne_of_gt hGN
  have h_rt :
      ryuTakayanagiEntanglementEntropyAdS3 R_ads G_N3 l_int eps_uv =
        (brownHenneauxCentralCharge R_ads G_N3 / 3) * Real.log (l_int / eps_uv) := by
    unfold ryuTakayanagiEntanglementEntropyAdS3 brownHenneauxCentralCharge
    field_simp [hGN_ne]
  have h_kss : 0 < kssShearViscosityEntropyBound hbar k_B := by
    unfold kssShearViscosityEntropyBound
    positivity
  have hpi_ne : Real.pi ≠ 0 := Real.pi_ne_zero
  have h_tension_inv :
      adsCouplingFromStringTension (Real.sqrt lam / (2 * Real.pi)) = lam := by
    unfold adsCouplingFromStringTension
    rw [div_pow, Real.sq_sqrt hlam_nonneg]
    field_simp [hpi_ne]
    ring
  have h_mag0 : adsMagnonDispersion M_bound lam 0 = M_bound := by
    unfold adsMagnonDispersion adsMagnonDispersionSq
    simp [Real.sqrt_sq (le_of_lt hM_pos)]
  have h_mag_pi :
      adsMagnonDispersionSq M_bound (adsCouplingFromStringTension T_str) Real.pi =
        M_bound ^ 2 + 4 * T_str ^ 2 := by
    unfold adsMagnonDispersionSq adsCouplingFromStringTension
    rw [Real.sin_pi_div_two]
    field_simp [hpi_ne]
  have h_mag_ge : M_bound ^ 2 ≤ adsMagnonDispersionSq M_bound lam p := by
    unfold adsMagnonDispersionSq
    have h_term_nonneg : 0 ≤ (lam / Real.pi ^ 2) * (Real.sin (p / 2)) ^ 2 := by positivity
    linarith
  have h_konishi :
      2 * betheOneLoopMagnonEnergy lam u_K = konishiOneLoopAnomalousDim lam := by
    unfold betheOneLoopMagnonEnergy konishiOneLoopAnomalousDim
    rw [hu_K]
    field_simp [hpi_ne]
    ring
  have h_konishi_cusp :
      konishiOneLoopAnomalousDim lam = (3 / 2) * cuspAnomalousDimOneLoop lam := by
    unfold konishiOneLoopAnomalousDim cuspAnomalousDimOneLoop
    ring
  have h_cusp0 : cuspAnomalousDimWeak3Loop 0 = 0 := by
    unfold cuspAnomalousDimWeak3Loop
    ring
  have h_exp_cancel :
      Complex.exp (Complex.I * ↑p) * Complex.exp (-Complex.I * ↑p) = 1 := by
    rw [← Complex.exp_add]
    have h_zero : Complex.I * (p : ℂ) + -Complex.I * (p : ℂ) = 0 := by ring
    rw [h_zero, Complex.exp_zero]
  have h_braid_rel : C_p * CDag_p + C_p + CDag_p = 0 := by
    dsimp [C_p, CDag_p, psl22BraidedCentralChargeC, psl22BraidedCentralChargeCDag]
    calc
      (Complex.exp (Complex.I * ↑p) - 1) * (Complex.exp (-Complex.I * ↑p) - 1) +
          (Complex.exp (Complex.I * ↑p) - 1) + (Complex.exp (-Complex.I * ↑p) - 1) =
        Complex.exp (Complex.I * ↑p) * Complex.exp (-Complex.I * ↑p) - 1 := by ring
      _ = 1 - 1 := by rw [h_exp_cancel]
      _ = 0 := sub_self 1
  have h_coprod_comm : psl22BraidedCoproductC C_1 C_2 = psl22BraidedCoproductC C_2 C_1 := by
    unfold psl22BraidedCoproductC
    ring
  have h_coprod_fact : (1 + C_1) * (1 + C_2) = 1 + psl22BraidedCoproductC C_1 C_2 := by
    unfold psl22BraidedCoproductC
    ring
  have h_long16 : gl22LongRepDim 0 0 = 16 := by
    unfold gl22LongRepDim
    norm_num
  have h_short4 : psl22ShortBoundStateDim 1 = 4 := by
    unfold psl22ShortBoundStateDim
    norm_num
  have h_short_lt_long :
      psl22ShortBoundStateDim M_bound < gl22LongRepDim (M_bound / 2) 0 := by
    unfold psl22ShortBoundStateDim gl22LongRepDim
    linarith
  have h_sec_tr : Matrix.trace (secretSymmetryMatrix B0) = 0 := by
    simp [Matrix.trace, Fin.sum_univ_four, secretSymmetryMatrix]
  have h_sec_str : supertrace22 (secretSymmetryMatrix B0) = 4 * B0 := by
    simp [supertrace22, secretSymmetryMatrix]
    ring
  have h_da_symm : qDeformedHubbardCartanDA.transpose = qDeformedHubbardCartanDA := by
    ext i j
    fin_cases i <;> fin_cases j <;> rfl
  have h_da_null : Matrix.mulVec qDeformedHubbardCartanDA ![1, 1, 1, 1] = 0 := by
    ext i
    fin_cases i <;>
      simp [Matrix.mulVec, dotProduct, Fin.sum_univ_four, qDeformedHubbardCartanDA] <;>
      norm_num
  have h_da_tr : Matrix.trace qDeformedHubbardCartanDA = 0 := by
    simp [Matrix.trace, Fin.sum_univ_four, qDeformedHubbardCartanDA]
  have h_da_det : Matrix.det qDeformedHubbardCartanDA = 0 := by
    rw [Matrix.det_succ_row_zero]
    simp [Fin.sum_univ_four, qDeformedHubbardCartanDA, Matrix.det_fin_three,
      Matrix.submatrix, Fin.succAbove]
  exact ⟨h_sum, h_prod, h_quad, h_at_bf, h_massless_p, h_massless_m,
    h_rt, h_kss, h_tension_inv, h_mag0, h_mag_pi, h_mag_ge, h_konishi,
    h_konishi_cusp, h_cusp0,
    h_braid_rel, h_coprod_comm, h_coprod_fact,
    h_long16, h_short4, h_short_lt_long,
    h_sec_tr, h_sec_str, h_da_symm, h_da_null, h_da_tr, h_da_det⟩

end Signals.Scattering
