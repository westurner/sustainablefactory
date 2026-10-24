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
  have h_exp_ne : Real.exp ξ ≠ 0 := Real.exp_ne_zero ξ
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

end Signals.Scattering
