import Architect
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Tactic
import Signals.DDF
import Signals.DFT
import Signals.Huygens
import Signals.QEDGravity

namespace Signals.AntimatterGravity

noncomputable section

open Signals.Geometry Signals.Huygens Signals.DDF Signals.DFT Signals.QEDGravity

/-! # Antimatter Annihilation and Gravity Mechanics Across GR, Cachazo–Witten Twistors, QED Scattering Gravity, DDF, and Turner Models 3–15b — Tested Against CERN `ALPHA-g`

Formalizes the correspondence and tension between antimatter annihilation
($e^- + e^+ \to 2\gamma / 3\gamma$ and antihydrogen $\bar{\mathrm{H}}$ annihilation)
and the electron/gravity models across `Signals`:
1. **Electron–Positron Annihilation Kinematics & $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Crossing Symmetry**:
   $2 m_e c^2 \to 2 E_\gamma$ ($E_\gamma = m_e c^2 \approx 511\text{ keV}$), $k_1^2 = k_2^2 = 0$,
   $s = (k_1 + k_2)^2 = 4 E_\gamma^2$, Mandelstam $s + t + u = 2 m_e^2 c^4$ crossing between
   Compton scattering $e^-\gamma \to e^-\gamma$ and pair annihilation $e^- e^+ \to 2\gamma$,
   and $C = (-1)^{L+S}$ positronium photon multiplicity ($2\gamma$ singlet vs. $3\gamma$ triplet).
2. **Active Gravitational Mass Conservation Across $e^- e^+ \to 2\gamma$**:
   - **GR, Cachazo–Skinner ($\pi_I = 1$), QED Scattering Gravity (`BCJ`/Partanen–Tulkki), and
     Turner Models 12, 14a, 15a ($\eta_{\mathrm{act}}^\gamma = 1$)**: Active gravitational mass-energy
     is conserved identically across annihilation (`annihilationActiveMassDeficit m_e 1 = 0`).
   - **Nordström Scalar Gravity ($\gamma_{\mathrm{PPN}} = -1$)**: Trace $T^\mu{}_\mu(d=4)$ drops from
     $2 m_e c^2 > 0$ to `maxwellStressEnergyTraceInDim 4 f_contract = 0`.
   - **Strict Uncoupled DDF & DDF-Coupled Turner Models 13, 14b, 15b ($\eta_{\mathrm{act}}^\gamma = 0$)**:
     Converting two massive $\phi$-sinks ($2 m_e > 0$) into two pure $\varphi$-phonons yields
     `annihilationActiveMassDeficit m_e 0 = 2 * m_e > 0`, isolating a sharp theoretical tension
     unless nonlinear $\varphi$-to-$\phi$ backreaction or cavity confinement restores $\eta_{\mathrm{act}}^\gamma = 1$.
3. **CERN `ALPHA-g` (Anderson et al., *Nature* 621, 716–722, 2023) Hypothesis Tests**:
   Using the published measurement $a_{\bar{g}}/g_0 = 0.75 \pm 0.13\,(\mathrm{stat+syst}) \pm 0.16\,(\mathrm{sim})$
   ($\sigma_{\mathrm{tot}}^2 = 17/400 = 0.0425$), machine-checks:
   - **Normal WEP ($a_{\bar{g}}/g_0 = +1$)**: $\chi^2(1) = 25/17 \approx 1.47 < 4$ ($|z| \approx 1.21\sigma$, consistent).
   - **Zero gravity / Witten scale-free ($\beta_{\mathrm{scale}} = 0 \implies a_{\bar{g}}/g_0 = 0$)**:
     $\chi^2(0) = 225/17 \approx 13.24 > (3.6)^2$ ($|z| \approx 3.64\sigma$, rejected $> 3.6\sigma$).
   - **Repulsive antigravity / DDF anti-sink / odd-$C$ vector ($a_{\bar{g}}/g_0 = -1$)**:
     $\chi^2(-1) = 1225/17 \approx 72.06 > 64$ ($|z| \approx 8.49\sigma$, rejected $> 8\sigma$).
-/

/-! ## Section 1: Pair Annihilation Kinematics & Crossing Symmetry -/

/-- Rest-frame single-photon energy $E_\gamma = m_e c^2$ in two-photon $e^- e^+ \to 2\gamma$ annihilation. -/
@[blueprint "def:signals-antimatter-annihilation-photon-energy"
  (title := "Two-photon e- e+ annihilation photon energy E_gamma = m_e c^2")
  (statement := /-- Define $\operatorname{annihilationPhotonEnergy}(m_e, c) = m_e c^2$. -/)]
def annihilationPhotonEnergy (m_e c : ℝ) : ℝ :=
  m_e * c ^ 2

/-- Center-of-mass squared invariant mass $s = (k_1 + k_2)^2 = 4 E_\gamma^2$ of back-to-back massless
annihilation photons ($k_1^2 = k_2^2 = 0$). -/
@[blueprint "def:signals-antimatter-two-photon-invariant-mass-sq"
  (title := "Center-of-mass squared invariant mass of back-to-back annihilation photons")
  (statement := /-- Define $\operatorname{twoPhotonInvariantMassSq}(E_\gamma) = (2 E_\gamma)^2$. -/)]
def twoPhotonInvariantMassSq (E_gamma : ℝ) : ℝ :=
  (2 * E_gamma) ^ 2

/-- Positronium charge-conjugation photon multiplicity $C = (-1)^{L+S}$:
$2$ photons for para-positronium ($^1S_0, C = +1$) and $3$ photons for ortho-positronium ($^3S_1, C = -1$). -/
def positroniumPhotonMultiplicity (spinSinglet : Bool) : ℕ :=
  if spinSinglet then 2 else 3

/-- Mandelstam sum for Compton scattering $e^- \gamma \to e^- \gamma$ and its crossing-channel
partner $e^- e^+ \to 2\gamma$: $s + t + u = 2 m_e^2 c^4$. -/
def comptonAnnihilationMandelstamSum (s_mand t_mand u_mand : ℝ) : ℝ :=
  s_mand + t_mand + u_mand

/-! ## Section 2: Active Gravitational Mass Conservation Across $e^- e^+ \to 2\gamma$ -/

/-- Total active gravitational mass of an $e^- e^+$ pair before annihilation (CPT-symmetric positive mass $2 m_e$). -/
def activeGravitationalMassBefore (m_e : ℝ) : ℝ :=
  2 * m_e

/-- Effective active gravitational mass of the two annihilation photons ($2 m_e \eta_{\mathrm{act}}^\gamma$),
parameterized by the active photon-sourcing coupling $\eta_{\mathrm{act}}^\gamma \in \{0, 1\}$. -/
def activeGravitationalMassAfter (m_e eta_act_gamma : ℝ) : ℝ :=
  2 * m_e * eta_act_gamma

/-- Active gravitational mass deficit $\Delta M_{\mathrm{act}} = 2 m_e (1 - \eta_{\mathrm{act}}^\gamma)$
across $e^- + e^+ \to 2\gamma$. Equals $0$ in GR, Cachazo–Skinner, QED scattering gravity, and Turner
Models 12/14a/15a ($\eta_{\mathrm{act}}^\gamma = 1$), and equals $2 m_e > 0$ in strict uncoupled DDF
and Models 13/14b/15b ($\eta_{\mathrm{act}}^\gamma = 0$). -/
@[blueprint "def:signals-antimatter-active-mass-deficit"
  (title := "Active gravitational mass deficit across e- e+ -> 2 gamma annihilation")
  (statement := /-- Define $\operatorname{annihilationActiveMassDeficit}(m_e, \eta_{\mathrm{act}}^\gamma) = 2 m_e - 2 m_e \eta_{\mathrm{act}}^\gamma$. -/)]
def annihilationActiveMassDeficit (m_e eta_act_gamma : ℝ) : ℝ :=
  activeGravitationalMassBefore m_e - activeGravitationalMassAfter m_e eta_act_gamma

/-! ## Section 3: CERN `ALPHA-g` (2023) Parameters & Per-Model Antihydrogen Free-Fall Predictions -/

/-- Published CERN `ALPHA-g` (Anderson et al., *Nature* 621, 716–722, 2023) measured antihydrogen
gravitational acceleration ratio $a_{\bar{g}}/g_0 = 0.75$. -/
def alphaGMeasuredRatio : ℝ := 3 / 4

/-- Published CERN `ALPHA-g` (2023) combined statistical + systematic uncertainty $\sigma_{\mathrm{stat+syst}} = 0.13\,g_0$. -/
def alphaGStatSystSigma : ℝ := 13 / 100

/-- Published CERN `ALPHA-g` (2023) simulation uncertainty $\sigma_{\mathrm{sim}} = 0.16\,g_0$. -/
def alphaGSimSigma : ℝ := 16 / 100

/-- Total quadrature variance $\sigma_{\mathrm{tot}}^2 = 0.13^2 + 0.16^2 = 17/400 = 0.0425$. -/
def alphaGTotalSigmaSq : ℝ :=
  alphaGStatSystSigma ^ 2 + alphaGSimSigma ^ 2

/-- Single-parameter chi-squared statistic $\chi^2(a_{\mathrm{pred}}) = (0.75 - a_{\mathrm{pred}})^2 / \sigma_{\mathrm{tot}}^2$
against CERN `ALPHA-g` (2023). -/
@[blueprint "def:signals-antimatter-alpha-g-chi-sq"
  (title := "CERN ALPHA-g 2023 chi-squared statistic")
  (statement := /-- Define $\operatorname{alphaGChiSq}(a_{\mathrm{pred}}) = (3/4 - a_{\mathrm{pred}})^2 / (17/400)$. -/)]
noncomputable def alphaGChiSq (a_pred : ℝ) : ℝ :=
  (alphaGMeasuredRatio - a_pred) ^ 2 / alphaGTotalSigmaSq

/-- Einstein General Relativity ($\gamma_{\mathrm{PPN}} = 1, \beta_{\mathrm{PPN}} = 1$) antihydrogen
acceleration ratio $a_{\bar{g}}/g_0 = 1$. -/
def einsteinGRAntihydrogenAccelRatio : ℝ := 1

/-- Witten (2004) conformal twistor string antihydrogen acceleration ratio with scale factor
$\beta_{\mathrm{scale}}$ and biharmonic Rindler slope $\gamma_{\mathrm{conf}}$. -/
noncomputable def wittenConformalAntihydrogenAccelRatio
    (beta_scale gamma_conf c_sq g0 : ℝ) : ℝ :=
  beta_scale - gamma_conf * c_sq / (2 * g0)

/-- Cachazo–Skinner (2012) infinity-twistor projected antihydrogen acceleration ratio ($\pi_I \in [0, 1]$).
At $\pi_I = 1$, projects out $\gamma_{\mathrm{conf}}$ identically to yield $+1$. -/
noncomputable def cachazoSkinnerAntihydrogenAccelRatio
    (pi_proj gamma_conf c_sq g0 : ℝ) : ℝ :=
  pi_proj + (1 - pi_proj) * wittenConformalAntihydrogenAccelRatio 1 gamma_conf c_sq g0

/-- QED Scattering Gravity (`BCJ` double copy / Partanen–Tulkki 2025 $\mathrm{U}(1)^4$) antihydrogen
acceleration ratio $a_{\bar{g}}/g_0 = 1$. -/
def qedScatteringAntihydrogenAccelRatio : ℝ := 1

/-- Special-relativistic spin-1 vector gravity antihydrogen acceleration ratio, parameterized by
charge-conjugation coupling polarity `cpt_charge_sign` (`+1` universal positive; `-1` odd-$C$ baryon/lepton). -/
def spinOneVectorAntihydrogenAccelRatio (cpt_charge_sign : ℝ) : ℝ :=
  cpt_charge_sign

/-- Dilatant Dark Fluid (`DDF`) antihydrogen acceleration ratio parameterized by sink polarity
(`+1` positive-inertia $\phi$-sink; `-1` falsified anti-sink hypothesis). -/
def ddfAntihydrogenAccelRatio (sink_polarity : ℝ) : ℝ :=
  sink_polarity

/-- Turner Model 12 (flat-space $\mathrm{Gr}_{\mathbb{C}}(2,4)$ `BCJ` + 1-loop PM QFT, no DDF) ratio. -/
def turnerModel12AntihydrogenAccelRatio : ℝ := 1

/-- Turner Model 13 (unified $\mathrm{Gr}_{\mathbb{C}}(2,4)$ + DDF + 3D splat) ratio. -/
def turnerModel13AntihydrogenAccelRatio (sink_polarity : ℝ) : ℝ :=
  sink_polarity

/-- Turner Model 14a ($\mathcal{Q}_4$ Kähler + Dual-`iGPE`, no DDF) ratio with Josephson asymmetry $\delta_{\mathrm{Jos}}^{\bar{\mathrm{H}}}$. -/
def turnerModel14aAntihydrogenAccelRatio (delta_jos_bar : ℝ) : ℝ :=
  1 + delta_jos_bar

/-- Turner Model 14b ($\mathcal{Q}_4$ Kähler + Dual-`iGPE` + DDF) ratio with sink polarity and $\delta_{\mathrm{Jos}}^{\bar{\mathrm{H}}}$. -/
def turnerModel14bAntihydrogenAccelRatio (sink_polarity delta_jos_bar : ℝ) : ℝ :=
  sink_polarity + delta_jos_bar

/-- Integrated Turner Model 15a (Celestial $O_\Delta^{\pm 2}$ + $\mathcal{Q}_4$ Kähler + Plancherel–Unruh loops, no DDF) ratio. -/
noncomputable def turnerModel15aAntihydrogenAccelRatio
    (sigma_dev alpha_qg delta_jos_bar : ℝ) : ℝ :=
  celestialSpinTwoShadowNormFactor sigma_dev *
    celestialPlancherelLoopCorrectionFactor alpha_qg + delta_jos_bar

/-- Integrated Turner Model 15b (Celestial $O_\Delta^{\pm 2}$ + $\mathcal{Q}_4$ Kähler + Plancherel–Unruh loops + DDF) ratio. -/
noncomputable def turnerModel15bAntihydrogenAccelRatio
    (sink_polarity sigma_dev alpha_qg delta_jos_bar : ℝ) : ℝ :=
  sink_polarity * celestialSpinTwoShadowNormFactor sigma_dev *
    celestialPlancherelLoopCorrectionFactor alpha_qg + delta_jos_bar

/-- Phenomenological `ALPHA-g` vertical trap downward-escape fraction
$P_{\mathrm{down}}(b; a_{\mathrm{pred}}, \sigma_b) = \bigl(1 + \exp(-(b + a_{\mathrm{pred}})/\sigma_b)\bigr)^{-1}$
as a function of dimensionless bias acceleration $b$ (in units of $g_0$). -/
noncomputable def alphaGTrapDownwardFraction (bias_g a_pred sigma_b : ℝ) : ℝ :=
  1 / (1 + Real.exp (- (bias_g + a_pred) / sigma_b))

/-! ## Section 4: Master Verification Theorem -/

/-- **Master Theorem for Antimatter Annihilation and CERN `ALPHA-g` Model Verification**:
Simultaneously proves:
1. **Pair Annihilation Kinematics & Crossing Symmetry**:
   - $s = (2 E_\gamma)^2 = 4 m_e^2 c^4$ at $E_\gamma = m_e c^2$,
   - singlet vs. triplet positronium photon counts ($2 < 3$),
   - `comptonAnnihilationMandelstamSum` invariance under $s \leftrightarrow t$ crossing,
   - `twoPhotonInvariantMassSq` strictly positive for $m_e > 0, c > 0$.
2. **Active Gravitational Mass Conservation vs. Nordström / Uncoupled DDF Tension**:
   - GR, Cachazo–Skinner, QED scattering gravity, and Turner Models 12/14a/15a ($\eta_{\mathrm{act}}^\gamma = 1$)
     conserve active mass identically: `annihilationActiveMassDeficit m_e 1 = 0`,
   - Strict uncoupled DDF and Turner Models 13/14b/15b ($\eta_{\mathrm{act}}^\gamma = 0$) suffer active
     mass deficit `annihilationActiveMassDeficit m_e 0 = 2 * m_e > 0` (for $m_e > 0$),
   - Nordström 4D electromagnetic stress trace vanishes (`maxwellStressEnergyTraceInDim 4 f_contract = 0`).
3. **CERN `ALPHA-g` (2023) Statistical Hypothesis Separation**:
   - `alphaGTotalSigmaSq = 17 / 400`,
   - Normal WEP ($a_{\bar{g}}/g_0 = +1$): `alphaGChiSq 1 = 25 / 17` and `alphaGChiSq 1 < 4` ($< 2\sigma$, consistent),
   - Scale-free Witten / zero gravity ($a_{\bar{g}}/g_0 = 0$): `alphaGChiSq 0 = 225 / 17` and `(36 / 10 : ℝ) ^ 2 < alphaGChiSq 0` ($> 3.6\sigma$, rejected),
   - Repulsive antigravity / DDF anti-sink / odd-$C$ vector ($a_{\bar{g}}/g_0 = -1$):
     `alphaGChiSq (-1) = 1225 / 17` and `64 < alphaGChiSq (-1)` ($> 8\sigma$, rejected),
   - Cachazo–Skinner ($\pi_I = 1$) projects out $\gamma_{\mathrm{conf}}$ for all $\gamma_{\mathrm{conf}}$,
     and Turner Models 12, 13 (positive-sink), 14a/14b ($\delta_{\mathrm{Jos}} = 0$), and 15a/15b
     ($\sigma_{\mathrm{dev}} = 0, \alpha_{\mathrm{QG}} = 0, \delta_{\mathrm{Jos}} = 0$) all predict $+1$,
   - Trap downward escape probability separates $-1 < 0 < +1$ strictly at every bias $b \in \mathbb{R}$. -/
@[blueprint "thm:signals-antimatter-annihilation-alpha-g-master"
  (title := "Master theorem: antimatter annihilation kinematics, active gravitational mass deficit, and CERN ALPHA-g model separation")
  (statement := /-- Certifies $e^- e^+ \to 2\gamma$ invariant mass, crossing invariance, active mass
    conservation ($\eta_{\mathrm{act}}^\gamma = 1 \implies \Delta M = 0$ vs. $\eta_{\mathrm{act}}^\gamma = 0 \implies \Delta M = 2 m_e > 0$),
    exact CERN ALPHA-g $\chi^2$ separation ($\chi^2(1) = 25/17 < 4$, $\chi^2(0) = 225/17 > 3.6^2$,
    $\chi^2(-1) = 1225/17 > 64$), Cachazo–Skinner and Turner Models 12–15b alignment with $+1$,
    and strict monotonicity of the ALPHA-g trap downward-escape logistic curve. -/)
  (proof := /-- Unfold definitions, close algebraic equalities by \texttt{ring} and \texttt{norm\_num},
    and prove trap monotonicity via \texttt{Real.exp\_lt\_exp}. -/)]
theorem antimatter_annihilation_and_alpha_g_unification_identities
    (m_e c f_contract gamma_conf c_sq g0 bias_g sigma_b s_m t_m u_m : ℝ)
    (hm : 0 < m_e) (hc : 0 < c) (hσ : 0 < sigma_b) :
    twoPhotonInvariantMassSq (annihilationPhotonEnergy m_e c) = (2 * m_e * c ^ 2) ^ 2 ∧
      0 < twoPhotonInvariantMassSq (annihilationPhotonEnergy m_e c) ∧
      positroniumPhotonMultiplicity true < positroniumPhotonMultiplicity false ∧
      comptonAnnihilationMandelstamSum s_m t_m u_m =
        comptonAnnihilationMandelstamSum t_m s_m u_m ∧
      annihilationActiveMassDeficit m_e 1 = 0 ∧
      annihilationActiveMassDeficit m_e 0 = 2 * m_e ∧
      0 < annihilationActiveMassDeficit m_e 0 ∧
      maxwellStressEnergyTraceInDim 4 f_contract = 0 ∧
      alphaGTotalSigmaSq = 17 / 400 ∧
      alphaGChiSq einsteinGRAntihydrogenAccelRatio = 25 / 17 ∧
      alphaGChiSq einsteinGRAntihydrogenAccelRatio < 4 ∧
      alphaGChiSq (wittenConformalAntihydrogenAccelRatio 0 0 c_sq g0) = 225 / 17 ∧
      (36 / 10 : ℝ) ^ 2 < alphaGChiSq (wittenConformalAntihydrogenAccelRatio 0 0 c_sq g0) ∧
      alphaGChiSq (ddfAntihydrogenAccelRatio (-1)) = 1225 / 17 ∧
      64 < alphaGChiSq (ddfAntihydrogenAccelRatio (-1)) ∧
      cachazoSkinnerAntihydrogenAccelRatio 1 gamma_conf c_sq g0 = 1 ∧
      qedScatteringAntihydrogenAccelRatio = 1 ∧
      ddfAntihydrogenAccelRatio 1 = 1 ∧
      turnerModel12AntihydrogenAccelRatio = 1 ∧
      turnerModel13AntihydrogenAccelRatio 1 = 1 ∧
      turnerModel14aAntihydrogenAccelRatio 0 = 1 ∧
      turnerModel14bAntihydrogenAccelRatio 1 0 = 1 ∧
      turnerModel15aAntihydrogenAccelRatio 0 0 0 = 1 ∧
      turnerModel15bAntihydrogenAccelRatio 1 0 0 0 = 1 ∧
      alphaGTrapDownwardFraction bias_g (-1) sigma_b <
        alphaGTrapDownwardFraction bias_g 0 sigma_b ∧
      alphaGTrapDownwardFraction bias_g 0 sigma_b <
        alphaGTrapDownwardFraction bias_g 1 sigma_b := by
  have h_inv_pos : 0 < twoPhotonInvariantMassSq (annihilationPhotonEnergy m_e c) := by
    unfold twoPhotonInvariantMassSq annihilationPhotonEnergy
    have hmc : 0 < 2 * (m_e * c ^ 2) := by positivity
    exact sq_pos_of_pos hmc
  have h_def_0_pos : 0 < annihilationActiveMassDeficit m_e 0 := by
    unfold annihilationActiveMassDeficit activeGravitationalMassBefore activeGravitationalMassAfter
    linarith
  have h_trap_1 :
      alphaGTrapDownwardFraction bias_g (-1) sigma_b <
        alphaGTrapDownwardFraction bias_g 0 sigma_b := by
    unfold alphaGTrapDownwardFraction
    have h_arg : -(bias_g + 0) / sigma_b < -(bias_g + -1) / sigma_b := by
      apply div_lt_div_of_pos_right _ hσ
      linarith
    have h_exp : Real.exp (-(bias_g + 0) / sigma_b) < Real.exp (-(bias_g + -1) / sigma_b) :=
      Real.exp_lt_exp.mpr h_arg
    have h_den_pos : 0 < 1 + Real.exp (-(bias_g + 0) / sigma_b) := by positivity
    exact one_div_lt_one_div_of_lt h_den_pos (by linarith)
  have h_trap_2 :
      alphaGTrapDownwardFraction bias_g 0 sigma_b <
        alphaGTrapDownwardFraction bias_g 1 sigma_b := by
    unfold alphaGTrapDownwardFraction
    have h_arg : -(bias_g + 1) / sigma_b < -(bias_g + 0) / sigma_b := by
      apply div_lt_div_of_pos_right _ hσ
      linarith
    have h_exp : Real.exp (-(bias_g + 1) / sigma_b) < Real.exp (-(bias_g + 0) / sigma_b) :=
      Real.exp_lt_exp.mpr h_arg
    have h_den_pos : 0 < 1 + Real.exp (-(bias_g + 1) / sigma_b) := by positivity
    exact one_div_lt_one_div_of_lt h_den_pos (by linarith)
  refine ⟨
    by unfold twoPhotonInvariantMassSq annihilationPhotonEnergy; ring,
    h_inv_pos,
    by unfold positroniumPhotonMultiplicity; norm_num,
    by unfold comptonAnnihilationMandelstamSum; ring,
    by unfold annihilationActiveMassDeficit activeGravitationalMassBefore activeGravitationalMassAfter; ring,
    by unfold annihilationActiveMassDeficit activeGravitationalMassBefore activeGravitationalMassAfter; ring,
    h_def_0_pos,
    by unfold maxwellStressEnergyTraceInDim; ring,
    by unfold alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma; norm_num,
    by unfold alphaGChiSq alphaGMeasuredRatio einsteinGRAntihydrogenAccelRatio alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma; norm_num,
    by unfold alphaGChiSq alphaGMeasuredRatio einsteinGRAntihydrogenAccelRatio alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma; norm_num,
    by unfold alphaGChiSq alphaGMeasuredRatio wittenConformalAntihydrogenAccelRatio alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma; norm_num,
    by unfold alphaGChiSq alphaGMeasuredRatio wittenConformalAntihydrogenAccelRatio alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma; norm_num,
    by unfold alphaGChiSq alphaGMeasuredRatio ddfAntihydrogenAccelRatio alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma; norm_num,
    by unfold alphaGChiSq alphaGMeasuredRatio ddfAntihydrogenAccelRatio alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma; norm_num,
    by unfold cachazoSkinnerAntihydrogenAccelRatio wittenConformalAntihydrogenAccelRatio; ring,
    rfl,
    rfl,
    rfl,
    rfl,
    by unfold turnerModel14aAntihydrogenAccelRatio; ring,
    by unfold turnerModel14bAntihydrogenAccelRatio; ring,
    by unfold turnerModel15aAntihydrogenAccelRatio celestialSpinTwoShadowNormFactor celestialPlancherelLoopCorrectionFactor; norm_num,
    by unfold turnerModel15bAntihydrogenAccelRatio celestialSpinTwoShadowNormFactor celestialPlancherelLoopCorrectionFactor; norm_num,
    h_trap_1,
    h_trap_2⟩

/-- **Photonic Deflection & Active Annihilation Mass Bridge (`annihilation_and_photonic_deflection_bridge`)**:
Links `Signals.DDF.ActiveRadiationSourcing` (`mutualPhotonDeflection`, `gr_photon_deflection_active`,
`ddf_photon_deflection_null`) and `Signals.DFT` / `Signals.DDF` passive solar light deflection
(`gravitationalLightDeflectionPPN`, `cachazoSkinnerLightDeflection`, `turnerPluckerKahlerLightDeflection`,
`turnerDualGr24IGPEDDFLightDeflection`, `turnerCelestialPluckerGravitonLightDeflection`,
`turnerCelestialDualGr24DDFGravitonLightDeflection`) directly to `annihilationActiveMassDeficit`:
1. In `ActiveRadiationSourcing.generalRelativity` (`GR`, `Cachazo–Skinner`, `QED`, `Models 12/14a/15a`),
   $\eta_{\mathrm{act}}^\gamma = 1$ yields both `0 < mutualPhotonDeflection` and zero annihilation active-mass
   deficit (`annihilationActiveMassDeficit m_e _ = 0`).
2. In `ActiveRadiationSourcing.dilatantDarkFluid` (`DDF`, `Models 13/14b/15b`),
   $\eta_{\mathrm{act}}^\gamma = 0$ yields both `mutualPhotonDeflection = 0` and the non-zero active-mass
   deficit `annihilationActiveMassDeficit m_e _ = 2 * m_e > 0`.
3. Passive solar light deflection matches $\Delta\theta_{\mathrm{GR}} = \frac{4 G_\phi M}{c^2 b}$ across
   GR, Cachazo–Skinner ($\pi_I = 1$), DDF, and Turner Models 14a/14b/15a/15b, while Nordström ($\gamma_{\mathrm{PPN}} = -1$)
   predicts `0` and Newtonian/spin-1 ($\gamma_{\mathrm{PPN}} = 0$) has $50\%$ error. -/
@[blueprint "thm:signals-antimatter-photonic-deflection-bridge"
  (title := "Photonic deflection (passive solar lensing vs. active photon-photon deflection) and annihilation active-mass bridge")
  (statement := /-- Proves that $\eta_{\mathrm{act}}^\gamma = 1$ simultaneously gives positive mutual
    photon--photon gravitational deflection and zero $e^-e^+\to 2\gamma$ active-mass deficit, whereas
    $\eta_{\mathrm{act}}^\gamma = 0$ gives null mutual photon deflection and $\Delta M_{\mathrm{act}} = 2 m_e > 0$,
    alongside exact $\Delta\theta_{\mathrm{GR}}$ passive solar lensing across GR, Cachazo--Skinner, DDF, and Turner Models 14a--15b. -/)
  (proof := /-- Combine \texttt{gr\_photon\_deflection\_active}, \texttt{ddf\_photon\_deflection\_null},
    \texttt{turnerDualGr24IGPEDDFLightDeflection\_eq\_model14a\_of\_ddf}, and
    \texttt{turner\_model\_15\_critique\_cayley\_shadow\_all\_loop\_and\_light\_deflection\_identities}. -/)]
theorem annihilation_and_photonic_deflection_bridge
    {sub : DDFSubstrate} (re : RiverExterior sub) (orb : PlanetaryOrbit)
    (m_e impactParam beamEnergy kernel gamma_conf deltaVarpi : ℝ)
    (hm : 0 < m_e) (hb : 0 < impactParam) (hE : 0 < beamEnergy) (hK : 0 < kernel) :
    let Δθ_GR := 4 * re.G_phi * re.sourceMass / (sub.c ^ 2 * impactParam)
    let e_ecc := orb.eccentricity
    0 < mutualPhotonDeflection ActiveRadiationSourcing.generalRelativity
          re.G_phi sub.c beamEnergy impactParam kernel ∧
      annihilationActiveMassDeficit m_e ActiveRadiationSourcing.generalRelativity.eta = 0 ∧
      mutualPhotonDeflection ActiveRadiationSourcing.dilatantDarkFluid
        re.G_phi sub.c beamEnergy impactParam kernel = 0 ∧
      annihilationActiveMassDeficit m_e ActiveRadiationSourcing.dilatantDarkFluid.eta = 2 * m_e ∧
      0 < annihilationActiveMassDeficit m_e ActiveRadiationSourcing.dilatantDarkFluid.eta ∧
      gravitationalLightDeflectionPPN re.G_phi re.sourceMass sub.c impactParam 1 = Δθ_GR ∧
      gravitationalLightDeflectionPPN re.G_phi re.sourceMass sub.c impactParam (-1) = 0 ∧
      Signals.Huygens.relativePredictiveError
          (gravitationalLightDeflectionPPN 1 1 1 1 0)
          (gravitationalLightDeflectionPPN 1 1 1 1 1) = 1 / 2 ∧
      cachazoSkinnerLightDeflection Δθ_GR 1 gamma_conf impactParam = Δθ_GR ∧
      turnerPluckerKahlerLightDeflection Δθ_GR (4 - e_ecc ^ 2) e_ecc 0 = Δθ_GR ∧
      turnerDualGr24IGPEDDFLightDeflection
          re.G_phi re.sourceMass (1 / sub.c ^ 2) 1 impactParam (4 - e_ecc ^ 2) e_ecc 0 = Δθ_GR ∧
      PlanetaryOrbit.turnerCelestialPluckerGravitonLightDeflection orb Δθ_GR deltaVarpi 0 0 0 = Δθ_GR ∧
      re.turnerCelestialDualGr24DDFGravitonLightDeflection orb impactParam deltaVarpi 0 0 0 = Δθ_GR := by
  intro Δθ_GR e_ecc
  have he0 := orb.eccentricity_nonneg
  have he1 := orb.eccentricity_lt_one
  have he_pos : 0 < 1 - e_ecc ^ 2 := by nlinarith
  have he_ne : 1 - e_ecc ^ 2 ≠ 0 := ne_of_gt he_pos
  have h_m15 := turner_model_15_critique_cayley_shadow_all_loop_and_light_deflection_identities
    re orb 0 1 deltaVarpi impactParam beamEnergy kernel
    (by norm_num) (by norm_num) hb hE hK
  have h_14b := (turnerDualGr24IGPEDDFLightDeflection_eq_model14a_of_ddf
    re.G_phi re.sourceMass (1 / sub.c ^ 2) 1 sub.c impactParam (4 - e_ecc ^ 2) e_ecc 0 he_ne).2
  have h_gr_ppn :
      gravitationalLightDeflectionPPN re.G_phi re.sourceMass sub.c impactParam 1 = Δθ_GR := by
    unfold gravitationalLightDeflectionPPN
    dsimp [Δθ_GR]
    ring
  have h_14a :
      turnerPluckerKahlerLightDeflection Δθ_GR (4 - e_ecc ^ 2) e_ecc 0 = Δθ_GR := by
    unfold turnerPluckerKahlerLightDeflection
    have h_sub : 4 - e_ecc ^ 2 - 3 = 1 - e_ecc ^ 2 := by ring
    rw [h_sub, div_self he_ne]
    ring
  refine ⟨
    h_m15.2.2.2.2.1,
    by unfold annihilationActiveMassDeficit activeGravitationalMassBefore activeGravitationalMassAfter ActiveRadiationSourcing.eta; ring,
    h_m15.2.2.2.2.2,
    by unfold annihilationActiveMassDeficit activeGravitationalMassBefore activeGravitationalMassAfter ActiveRadiationSourcing.eta; ring,
    by unfold annihilationActiveMassDeficit activeGravitationalMassBefore activeGravitationalMassAfter ActiveRadiationSourcing.eta; linarith,
    h_gr_ppn,
    by unfold gravitationalLightDeflectionPPN; ring,
    by unfold Signals.Huygens.relativePredictiveError gravitationalLightDeflectionPPN; norm_num,
    by unfold cachazoSkinnerLightDeflection; ring,
    h_14a,
    by rw [h_14b, add_zero]; exact h_gr_ppn,
    h_m15.2.2.1,
    h_m15.2.2.2.1⟩

end

end Signals.AntimatterGravity
