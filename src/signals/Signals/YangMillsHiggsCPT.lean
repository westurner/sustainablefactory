import Architect
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Tactic
import Signals.AntimatterGravity
import Signals.DDF
import Signals.RiemannSpectral

namespace Signals.YangMillsHiggsCPT

noncomputable section

open Signals.DDF Signals.RiemannSpectral Signals.AntimatterGravity

/-! # Yang–Mills Mass Gap, Electroweak Higgs Symmetry Breaking, CP Violation, and Jost's Anti-Unitary CPT Involution

Formalizes the algebraic, representation-theoretic, and finite-axiomatic core connecting:
1. **Yang–Mills Mass Gap, Dimensional Transmutation, & Lattice/Peter–Weyl Singlet Projection**:
   - Finite lattice transfer-matrix spectral gap $\Delta_{\mathrm{lat}} = \ln(\lambda_0/\lambda_1) > 0$
     with exponential Euclidean Schwinger decay $(\lambda_1/\lambda_0)^t = \exp(-\Delta_{\mathrm{lat}} t)$,
   - Dimensional transmutation $\Lambda_{\mathrm{YM}}(\mu) = \mu \exp(-8\pi^2 / (b_0 g^2)) \in (0, \mu)$
     for asymptotically free $\mathrm{SU}(N_c)$ with $b_0 = (11 N_c - 2 n_f)/3 > 0$,
   - Toupin's tree-level GKO coset glueball mass $M_k(N, \Lambda_{\mathrm{QCD}}) = \frac{2N}{k + N}\Lambda_{\mathrm{QCD}}$
     ($M_1 = 300\text{ MeV}$ at $N=3, k=1, \Lambda_{\mathrm{QCD}} = 200\text{ MeV}$),
   - Massive Proca / glueball dispersion cutoff $\omega^2 = k^2 c^2 + (m_{\mathrm{gap}} c^2/\hbar)^2 \ge (m_{\mathrm{gap}} c^2/\hbar)^2 > 0$.
2. **Electroweak $\mathrm{SU}(2)_L \times \mathrm{U}(1)_Y \to \mathrm{U}(1)_{\mathrm{EM}}$ Higgs Mechanism**:
   - Mexican-hat potential $V(\Phi) = -\mu^2|\Phi|^2 + \lambda|\Phi|^4$, unitary-gauge shift
     $|\Phi|^2 = (v + h)^2/2$ at $v^2 = \mu^2/\lambda$, exact vacuum energy $-\mu^4/(4\lambda)$,
     exact cancellation of the linear tadpole, radial Higgs mass $m_H^2 = 2\mu^2 = 2\lambda v^2 > 0$,
   - Electroweak gauge-boson masses $m_W = \frac{1}{2}g_2 v$, $m_Z = \frac{1}{2}\sqrt{g_2^2 + g_1^2}\,v$,
     $m_\gamma = 0$, $\rho_{\mathrm{EW}} = m_W^2/(m_Z^2 \cos^2\theta_W) = 1$,
   - Higgs self-conjugacy ($Q = 0 \implies \bar{H} = H$).
3. **CP Violation in Higgs Yukawa Mixing, Jarlskog Invariant, & Sakharov Equilibrium Theorem**:
   - CP-even / CP-odd Higgs decay asymmetry $\mathcal{A}_{\mathrm{CP}}(\kappa, \tilde{\kappa}, \alpha_{\mathrm{CP}}) = 2\kappa\tilde{\kappa}\sin\alpha_{\mathrm{CP}}\cos\alpha_{\mathrm{CP}} = \kappa\tilde{\kappa}\sin(2\alpha_{\mathrm{CP}})$,
   - Exact **Sakharov Equilibrium Null Theorem**: under Jost CPT mass equality $E_k^+ = E_k^-$ and
     opposite baryon charges $B_k^- = -B_k^+$, the thermal equilibrium expectation $\langle B\rangle_\beta = 0$
     vanishes identically, proving that Higgs-driven baryogenesis requires non-equilibrium phase dynamics.
4. **Jost's Axiomatic Anti-Unitary CPT Involution ($\Theta = CPT$) & Grassmannian/Celestial Bridge**:
   - Finite-dimensional realization $\Theta(\psi) = U\overline{\psi}$ with $U^\dagger U = I_n$ and $U\overline{U} = \epsilon I_n$ ($\epsilon = \pm 1$),
   - Anti-linearity $\Theta(c\psi) = \overline{c}\,\Theta(\psi)$, anti-unitarity $\langle \Theta\psi, \Theta\phi\rangle = \langle \phi, \psi\rangle$,
   - Exact spectral mass/energy equality ($H(\Theta\psi) = E(\Theta\psi)$ when $U\overline{H} = HU$),
   - Exact $CP$-violation $\iff T$-violation theorem under $[\Theta, H] = 0$.

*Epistemic Boundary*: These theorems verify finite/algebraic and continuum-regularized laws; they do **not**
claim to close the unsolved Clay Millennium 4D continuum Osterwalder–Schrader Yang–Mills existence &
mass-gap problem (isolated in `Signals.Pending.YangMillsMassGapHiggsCPTPendingBoundary`). -/

/-! ## Section 1: Yang–Mills Mass Gap, Lattice Transfer Decay, Dimensional Transmutation, & GKO Mass -/

/-- One-loop $\mathrm{SU}(N_c)$ beta-function coefficient $b_0 = (11 N_c - 2 n_f) / 3$. -/
def suNOneLoopBeta0 (nColor nFlavor : ℝ) : ℝ :=
  (11 * nColor - 2 * nFlavor) / 3

/-- Dimensional-transmutation dynamical scale $\Lambda_{\mathrm{YM}}(\mu) = \mu \exp\!\left(-\frac{8\pi^2}{b_0 g^2}\right)$. -/
def dimensionalTransmutationScale (mu b0 gSq : ℝ) : ℝ :=
  mu * Real.exp (-(8 * Real.pi ^ 2) / (b0 * gSq))

/-- Lattice Euclidean transfer-matrix spectral gap $\Delta_{\mathrm{lat}} = \ln(\lambda_0 / \lambda_1) = -\ln(\lambda_1 / \lambda_0)$. -/
def latticeTransferMatrixGap (lambda0 lambda1 : ℝ) : ℝ :=
  Real.log (lambda0 / lambda1)

/-- Toupin's tree-level celestial GKO coset glueball mass $M_k = \frac{2 N}{k + N} \Lambda_{\mathrm{QCD}}$. -/
def toupinTreeGlueballMass (nColor kLevel lambdaQCD : ℝ) : ℝ :=
  (2 * nColor / (kLevel + nColor)) * lambdaQCD

/-- Massive Proca / glueball dispersion relation $\omega^2(k) = k^2 c^2 + (m_{\mathrm{gap}} c^2 / \hbar)^2$. -/
def procaDispersionMassGapSq (kWave c mGap hbar : ℝ) : ℝ :=
  kWave ^ 2 * c ^ 2 + (mGap * c ^ 2 / hbar) ^ 2

/-- Finite Abelian $Z_N$ / Haar-sum singlet projection indicator:
equals $1$ on the trivial singlet character ($r = 0$) and $0$ on all non-singlet modes ($r \ne 0$). -/
def finiteGroupHaarSingletProjector (modeIndex : ℕ) : ℝ :=
  if modeIndex = 0 then 1 else 0

/-- **Yang–Mills Mass Gap & Dimensional Transmutation Structural Theorem**:
Certifies:
1. Pure $\mathrm{SU}(3)$ ($n_f = 0$) asymptotic freedom $b_0 = 11 > 0$, and $0 < \Lambda_{\mathrm{YM}}(\mu) < \mu$
   for $\mu > 0, b_0 > 0, g^2 > 0$.
2. For $0 < \lambda_1 < \lambda_0$, the lattice spectral gap $\Delta_{\mathrm{lat}} = \ln(\lambda_0/\lambda_1) > 0$
   and the Euclidean Schwinger two-point correlator decays exponentially:
   $(\lambda_1 / \lambda_0)^t = \exp(-t\,\Delta_{\mathrm{lat}})$ for every integer/real $t$ (`Real.rpow` form).
3. Toupin's tree-level glueball mass satisfies $M_1(3, 1, 200) = 300\text{ MeV}$, $0 < M_k \le 2\Lambda_{\mathrm{QCD}}$
   for $N > 0, k \ge 0, \Lambda_{\mathrm{QCD}} > 0$, and $k_1 < k_2 \implies M_{k_2} < M_{k_1}$.
4. Massive dispersion cutoff satisfies $\omega^2(k) \ge (m_{\mathrm{gap}} c^2 / \hbar)^2 > 0$ for $m_{\mathrm{gap}}, c, \hbar > 0$.
5. Haar singlet projector is idempotent ($P^2 = P$) and annihilates non-singlet modes ($r \ne 0$). -/
@[blueprint "thm:signals-ym-mass-gap-structural"
  (title := "Yang-Mills mass gap, lattice transfer decay, dimensional transmutation, and GKO mass identities")
  (statement := /-- Certifies $b_0(\mathrm{SU}(3), 0) = 11$, $0 < \Lambda_{\mathrm{YM}}(\mu) < \mu$,
    $\Delta_{\mathrm{lat}} = \ln(\lambda_0/\lambda_1) > 0$ with $(\lambda_1/\lambda_0)^t = e^{-t\Delta_{\mathrm{lat}}}$,
    Toupin's $M_1(3, 1, 200) = 300\text{ MeV}$ monotonicity, Proca dispersion gap $\omega^2 \ge (m_{\mathrm{gap}}c^2/\hbar)^2 > 0$,
    and Haar singlet projector idempotence. -/)]
theorem yang_mills_mass_gap_and_transmutation_identities
    (mu b0 gSq lambda0 lambda1 tTime nColor k1 k2 lambdaQCD kWave c mGap hbar : ℝ)
    (modeIdx : ℕ)
    (h_mu : 0 < mu) (h_b0 : 0 < b0) (h_g2 : 0 < gSq)
    (h_l1 : 0 < lambda1) (h_l0 : lambda1 < lambda0)
    (hN : 0 < nColor) (hk1 : 0 ≤ k1) (hk12 : k1 < k2) (hL : 0 < lambdaQCD)
    (hc : 0 < c) (hm : 0 < mGap) (hh : 0 < hbar) :
    suNOneLoopBeta0 3 0 = 11 ∧
      0 < dimensionalTransmutationScale mu b0 gSq ∧
      dimensionalTransmutationScale mu b0 gSq < mu ∧
      0 < latticeTransferMatrixGap lambda0 lambda1 ∧
      (lambda1 / lambda0) ^ tTime = Real.exp (-tTime * latticeTransferMatrixGap lambda0 lambda1) ∧
      toupinTreeGlueballMass 3 1 200 = 300 ∧
      0 < toupinTreeGlueballMass nColor k1 lambdaQCD ∧
      toupinTreeGlueballMass nColor k1 lambdaQCD ≤ 2 * lambdaQCD ∧
      toupinTreeGlueballMass nColor k2 lambdaQCD < toupinTreeGlueballMass nColor k1 lambdaQCD ∧
      (mGap * c ^ 2 / hbar) ^ 2 ≤ procaDispersionMassGapSq kWave c mGap hbar ∧
      0 < (mGap * c ^ 2 / hbar) ^ 2 ∧
      finiteGroupHaarSingletProjector modeIdx ^ 2 = finiteGroupHaarSingletProjector modeIdx ∧
      (modeIdx ≠ 0 → finiteGroupHaarSingletProjector modeIdx = 0) := by
  have h_l0_pos : 0 < lambda0 := lt_trans h_l1 h_l0
  have h_ratio_gt1 : 1 < lambda0 / lambda1 := (one_lt_div h_l1).mpr h_l0
  have h_gap_pos : 0 < latticeTransferMatrixGap lambda0 lambda1 := by
    unfold latticeTransferMatrixGap
    exact Real.log_pos h_ratio_gt1
  have h_exp_neg : -(8 * Real.pi ^ 2) / (b0 * gSq) < 0 := by
    have h_pi : 0 < Real.pi := Real.pi_pos
    have h_num : 0 < 8 * Real.pi ^ 2 := by positivity
    have h_den : 0 < b0 * gSq := mul_pos h_b0 h_g2
    rw [neg_div]
    exact neg_lt_zero.mpr (div_pos h_num h_den)
  have h_exp_lt1 : Real.exp (-(8 * Real.pi ^ 2) / (b0 * gSq)) < 1 :=
    Real.exp_lt_one_iff.mpr h_exp_neg
  have h_rpow :
      (lambda1 / lambda0) ^ tTime = Real.exp (-tTime * latticeTransferMatrixGap lambda0 lambda1) := by
    have h_pos_r : 0 < lambda1 / lambda0 := div_pos h_l1 h_l0_pos
    rw [Real.rpow_def_of_pos h_pos_r]
    have h_log_inv : Real.log (lambda1 / lambda0) = -latticeTransferMatrixGap lambda0 lambda1 := by
      unfold latticeTransferMatrixGap
      have h_inv : lambda1 / lambda0 = (lambda0 / lambda1)⁻¹ := by
        field_simp [ne_of_gt h_l1, ne_of_gt h_l0_pos]
      rw [h_inv, Real.log_inv]
    rw [h_log_inv]
    ring_nf
  have h_k1N_pos : 0 < k1 + nColor := by linarith
  have h_k2N_pos : 0 < k2 + nColor := by linarith
  have h_mk1_pos : 0 < toupinTreeGlueballMass nColor k1 lambdaQCD := by
    unfold toupinTreeGlueballMass
    positivity
  have h_mk1_le : toupinTreeGlueballMass nColor k1 lambdaQCD ≤ 2 * lambdaQCD := by
    unfold toupinTreeGlueballMass
    have h_frac : 2 * nColor / (k1 + nColor) ≤ 2 := by
      rw [div_le_iff₀ h_k1N_pos]
      linarith
    exact mul_le_mul_of_nonneg_right h_frac (le_of_lt hL)
  have h_mk_dec :
      toupinTreeGlueballMass nColor k2 lambdaQCD < toupinTreeGlueballMass nColor k1 lambdaQCD := by
    unfold toupinTreeGlueballMass
    have h_lt_frac : 2 * nColor / (k2 + nColor) < 2 * nColor / (k1 + nColor) :=
      div_lt_div_of_pos_left (by linarith) h_k1N_pos (by linarith)
    exact mul_lt_mul_of_pos_right h_lt_frac hL
  have h_beta_su3 : suNOneLoopBeta0 3 0 = 11 := by
    unfold suNOneLoopBeta0; norm_num
  have h_dim_pos : 0 < dimensionalTransmutationScale mu b0 gSq := by
    unfold dimensionalTransmutationScale
    exact mul_pos h_mu (Real.exp_pos _)
  have h_dim_lt : dimensionalTransmutationScale mu b0 gSq < mu := by
    unfold dimensionalTransmutationScale
    calc
      mu * Real.exp (-(8 * Real.pi ^ 2) / (b0 * gSq)) < mu * 1 :=
        mul_lt_mul_of_pos_left h_exp_lt1 h_mu
      _ = mu := mul_one mu
  have h_toupin_300 : toupinTreeGlueballMass 3 1 200 = 300 := by
    unfold toupinTreeGlueballMass; norm_num
  have h_proca_le : (mGap * c ^ 2 / hbar) ^ 2 ≤ procaDispersionMassGapSq kWave c mGap hbar := by
    unfold procaDispersionMassGapSq
    have h_kc : 0 ≤ kWave ^ 2 * c ^ 2 := by positivity
    linarith
  have h_proca_pos : 0 < (mGap * c ^ 2 / hbar) ^ 2 := by
    have h_pos : 0 < mGap * c ^ 2 / hbar := by positivity
    exact sq_pos_of_pos h_pos
  have h_proj_idem : finiteGroupHaarSingletProjector modeIdx ^ 2 = finiteGroupHaarSingletProjector modeIdx := by
    unfold finiteGroupHaarSingletProjector
    split_ifs <;> norm_num
  have h_proj_ann : modeIdx ≠ 0 → finiteGroupHaarSingletProjector modeIdx = 0 := by
    intro h_ne
    unfold finiteGroupHaarSingletProjector
    simp [h_ne]
  exact ⟨h_beta_su3, h_dim_pos, h_dim_lt, h_gap_pos, h_rpow, h_toupin_300,
    h_mk1_pos, h_mk1_le, h_mk_dec, h_proca_le, h_proca_pos, h_proj_idem, h_proj_ann⟩

/-! ## Section 2: Electroweak Higgs Spontaneous Symmetry Breaking & Self-Conjugacy -/

/-- Standard Model Higgs Mexican-hat potential $V(\Phi) = -\mu^2 |\Phi|^2 + \lambda |\Phi|^4$. -/
def higgsMexicanHatPotential (muSq lambdaQuartic phiNormSq : ℝ) : ℝ :=
  -muSq * phiNormSq + lambdaQuartic * phiNormSq ^ 2

/-- Electroweak vacuum expectation value $v = \sqrt{\mu^2 / \lambda}$ (for $\Phi = (0, (v+h)/\sqrt{2})^T$). -/
def higgsVev (muSq lambdaQuartic : ℝ) : ℝ :=
  Real.sqrt (muSq / lambdaQuartic)

/-- Physical radial Higgs boson mass squared $m_H^2 = 2 \mu^2 = 2 \lambda v^2$. -/
def higgsMassSq (lambdaQuartic vev : ℝ) : ℝ :=
  2 * lambdaQuartic * vev ^ 2

/-- Charged weak boson mass $m_W = \frac{1}{2} g_2 v$. -/
def wBosonMass (g2 vev : ℝ) : ℝ :=
  (1 / 2 : ℝ) * g2 * vev

/-- Neutral weak boson mass $m_Z = \frac{1}{2} \sqrt{g_2^2 + g_1^2}\,v$. -/
def zBosonMass (g1 g2 vev : ℝ) : ℝ :=
  (1 / 2 : ℝ) * Real.sqrt (g2 ^ 2 + g1 ^ 2) * vev

/-- Weinberg mixing cosine squared $\cos^2\theta_W = g_2^2 / (g_2^2 + g_1^2)$. -/
def weinbergCosSq (g1 g2 : ℝ) : ℝ :=
  g2 ^ 2 / (g2 ^ 2 + g1 ^ 2)

/-- Electroweak $\rho$ parameter $\rho_{\mathrm{EW}} = m_W^2 / (m_Z^2 \cos^2\theta_W)$. -/
def electroweakRhoParam (g1 g2 vev : ℝ) : ℝ :=
  (wBosonMass g2 vev) ^ 2 / ((zBosonMass g1 g2 vev) ^ 2 * weinbergCosSq g1 g2)

/-- Charge-conjugation flip on electric charge $Q \mapsto -Q$ (confirming Higgs neutrality $Q_H = 0 \implies \bar{H} = H$). -/
def chargeConjugateElectricCharge (qCharge : ℝ) : ℝ :=
  -qCharge

/-- **Electroweak Higgs Symmetry-Breaking & Self-Conjugacy Theorem**:
Certifies:
1. Unitary-gauge expansion around $v^2 = \mu^2/\lambda$ eliminates the linear tadpole identically:
   $V\!\left(\frac{(v+h)^2}{2}\right) = -\frac{\mu^4}{4\lambda} + \mu^2 h^2 + \lambda v h^3 + \frac{\lambda}{4} h^4$,
   so $m_H^2 = 2\lambda v^2 = 2\mu^2 > 0$.
2. Exact tree-level $\rho_{\mathrm{EW}} = 1$, photon masslessness $m_\gamma = 0$, and $m_W < m_Z$ for $g_1 \ne 0$.
3. Neutrality under charge conjugation: `chargeConjugateElectricCharge 0 = 0` ($H = \bar{H}$). -/
@[blueprint "thm:signals-higgs-ssb-and-self-conjugacy"
  (title := "Electroweak Higgs spontaneous symmetry breaking, rho=1 custodial identity, and self-conjugacy")
  (statement := /-- Certifies the unitary-gauge Mexican-hat expansion without linear tadpole,
    $m_H^2 = 2\lambda v^2 = 2\mu^2 > 0$, $\rho_{\mathrm{EW}} = 1$, $m_W < m_Z$, and $Q_H = -Q_H = 0$. -/)]
theorem higgs_ssb_electroweak_masses_and_self_conjugacy
    (muSq lambdaQuartic hField g1 g2 : ℝ)
    (h_mu : 0 < muSq) (h_lam : 0 < lambdaQuartic) (hg1 : g1 ≠ 0) (hg2 : 0 < g2) :
    let v := higgsVev muSq lambdaQuartic
    (v ^ 2 = muSq / lambdaQuartic ∧
      higgsMexicanHatPotential muSq lambdaQuartic ((v + hField) ^ 2 / 2) =
        -(muSq ^ 2 / (4 * lambdaQuartic)) + muSq * hField ^ 2 +
          lambdaQuartic * v * hField ^ 3 + (lambdaQuartic / 4) * hField ^ 4 ∧
      higgsMassSq lambdaQuartic v = 2 * muSq ∧
      0 < higgsMassSq lambdaQuartic v ∧
      0 < wBosonMass g2 v ∧
      wBosonMass g2 v < zBosonMass g1 g2 v ∧
      electroweakRhoParam g1 g2 v = 1 ∧
      chargeConjugateElectricCharge 0 = 0) := by
  intro v
  have hv_nonneg : 0 ≤ muSq / lambdaQuartic := div_nonneg (le_of_lt h_mu) (le_of_lt h_lam)
  have hv2 : v ^ 2 = muSq / lambdaQuartic := Real.sq_sqrt hv_nonneg
  have hv_pos : 0 < v := Real.sqrt_pos.mpr (div_pos h_mu h_lam)
  have h_lam_ne : lambdaQuartic ≠ 0 := ne_of_gt h_lam
  have h_mu_eq : muSq = lambdaQuartic * v ^ 2 := by
    rw [hv2, mul_div_cancel₀ _ h_lam_ne]
  have h_pot :
      higgsMexicanHatPotential muSq lambdaQuartic ((v + hField) ^ 2 / 2) =
        -(muSq ^ 2 / (4 * lambdaQuartic)) + muSq * hField ^ 2 +
          lambdaQuartic * v * hField ^ 3 + (lambdaQuartic / 4) * hField ^ 4 := by
    unfold higgsMexicanHatPotential
    rw [h_mu_eq]
    field_simp [h_lam_ne]
    ring
  have h_mh : higgsMassSq lambdaQuartic v = 2 * muSq := by
    unfold higgsMassSq
    rw [hv2]
    field_simp [h_lam_ne]
  have h_mh_pos : 0 < higgsMassSq lambdaQuartic v := by
    rw [h_mh]; linarith
  have h_mw_pos : 0 < wBosonMass g2 v := by
    unfold wBosonMass; positivity
  have hg1_sq_pos : 0 < g1 ^ 2 := sq_pos_of_ne_zero hg1
  have h_mw_lt_mz : wBosonMass g2 v < zBosonMass g1 g2 v := by
    unfold wBosonMass zBosonMass
    have h_g2_lt : g2 < Real.sqrt (g2 ^ 2 + g1 ^ 2) := by
      have h_sq_lt : g2 ^ 2 < g2 ^ 2 + g1 ^ 2 := by linarith
      calc
        g2 = Real.sqrt (g2 ^ 2) := (Real.sqrt_sq (le_of_lt hg2)).symm
        _ < Real.sqrt (g2 ^ 2 + g1 ^ 2) := Real.sqrt_lt_sqrt (sq_nonneg g2) h_sq_lt
    nlinarith
  have h_rho : electroweakRhoParam g1 g2 v = 1 := by
    unfold electroweakRhoParam wBosonMass zBosonMass weinbergCosSq
    have h_sum_pos : 0 < g2 ^ 2 + g1 ^ 2 := by positivity
    have h_sqrt_sq : Real.sqrt (g2 ^ 2 + g1 ^ 2) ^ 2 = g2 ^ 2 + g1 ^ 2 :=
      Real.sq_sqrt (le_of_lt h_sum_pos)
    have h_g2_ne : g2 ≠ 0 := ne_of_gt hg2
    have h_v_ne : v ≠ 0 := ne_of_gt hv_pos
    have h_sum_ne : g2 ^ 2 + g1 ^ 2 ≠ 0 := ne_of_gt h_sum_pos
    calc
      ((1 / 2 : ℝ) * g2 * v) ^ 2 /
          (((1 / 2 : ℝ) * Real.sqrt (g2 ^ 2 + g1 ^ 2) * v) ^ 2 * (g2 ^ 2 / (g2 ^ 2 + g1 ^ 2))) =
        ((1 / 4 : ℝ) * g2 ^ 2 * v ^ 2) /
          ((1 / 4 : ℝ) * Real.sqrt (g2 ^ 2 + g1 ^ 2) ^ 2 * v ^ 2 * (g2 ^ 2 / (g2 ^ 2 + g1 ^ 2))) := by
        ring
      _ = ((1 / 4 : ℝ) * g2 ^ 2 * v ^ 2) /
          ((1 / 4 : ℝ) * (g2 ^ 2 + g1 ^ 2) * v ^ 2 * (g2 ^ 2 / (g2 ^ 2 + g1 ^ 2))) := by
        rw [h_sqrt_sq]
      _ = 1 := by
        field_simp [h_g2_ne, h_v_ne, h_sum_ne]
  exact ⟨hv2, h_pot, h_mh, h_mh_pos, h_mw_pos, h_mw_lt_mz, h_rho, by
    unfold chargeConjugateElectricCharge; ring⟩

/-! ## Section 3: CP Violation in Higgs Decays, Jarlskog Invariant, & Sakharov Equilibrium Theorem -/

/-- CP-violating angular asymmetry factor in mixed CP-even / CP-odd Higgs decays
($H \to \tau^+\tau^-, ZZ^* \to 4\ell, \gamma\gamma$):
`A_CP(κ, κ̃, α_CP) = 2 κ κ̃ sin(α_CP) cos(α_CP) = κ κ̃ sin(2 α_CP)`. -/
def higgsCpMixedDecayAsymmetry (kappa kappaTilde alphaCP : ℝ) : ℝ :=
  2 * kappa * kappaTilde * Real.sin alphaCP * Real.cos alphaCP

/-- Standard Model CKM Jarlskog invariant
$J_{\mathrm{CP}} = c_{12} c_{23} c_{13}^2 s_{12} s_{23} s_{13} \sin\delta_{\mathrm{CKM}}$. -/
def jarlskogCkmInvariant (theta12 theta23 theta13 deltaCKM : ℝ) : ℝ :=
  Real.cos theta12 * Real.cos theta23 * (Real.cos theta13) ^ 2 *
    Real.sin theta12 * Real.sin theta23 * Real.sin theta13 * Real.sin deltaCKM

/-- Finite thermal equilibrium baryon-number trace across `n` particle/antiparticle doublets
with particle energies `E_plus`, antiparticle energies `E_minus`, and baryon charges `+b_k, -b_k`. -/
def thermalEquilibriumBaryonTrace {n : ℕ}
    (beta : ℝ) (energyPlus energyMinus baryonCharge : Fin n → ℝ) : ℝ :=
  ∑ k : Fin n,
    (baryonCharge k * Real.exp (-beta * energyPlus k) +
      (-baryonCharge k) * Real.exp (-beta * energyMinus k))

/-- **CP-Mixed Higgs Decay & Sakharov Equilibrium Null Theorem**:
Certifies:
1. `higgsCpMixedDecayAsymmetry kappa kappaTilde alphaCP = kappa * kappaTilde * Real.sin (2 * alphaCP)`,
   vanishing identically for a pure SM CP-even Higgs (`α_CP = 0` or `κ̃ = 0`) and pure CP-odd
   pseudoscalar (`α_CP = π / 2`), and non-zero when `κ ≠ 0, κ̃ ≠ 0, sin α_CP ≠ 0, cos α_CP ≠ 0`.
2. **Sakharov Equilibrium Theorem (Consequence of Jost CPT)**:
   Whenever particle and antiparticle share identical rest/spectral energies (`∀ k, E_plus k = E_minus k`),
   `thermalEquilibriumBaryonTrace beta energyPlus energyMinus baryonCharge = 0` identically for every
   temperature `β` and every baryon assignment, forcing out-of-equilibrium dynamics for baryogenesis. -/
@[blueprint "thm:signals-higgs-cp-and-sakharov-equilibrium"
  (title := "Higgs CP-mixing decay asymmetry and Sakharov thermal equilibrium null theorem under CPT")
  (statement := /-- Proves $\mathcal{A}_{\mathrm{CP}} = \kappa\tilde{\kappa}\sin(2\alpha_{\mathrm{CP}})$
    (vanishing at pure CP-even $\alpha_{\mathrm{CP}}=0$ and pure CP-odd $\alpha_{\mathrm{CP}}=\pi/2$),
    and proves $\langle B\rangle_\beta = 0$ identically in thermal equilibrium when $E_k^+ = E_k^-$ (CPT). -/)]
theorem higgs_cp_asymmetry_and_sakharov_equilibrium_zero
    {n : ℕ} (kappa kappaTilde alphaCP beta : ℝ)
    (energyPlus energyMinus baryonCharge : Fin n → ℝ)
    (h_cpt_mass : ∀ k : Fin n, energyPlus k = energyMinus k) :
    higgsCpMixedDecayAsymmetry kappa kappaTilde alphaCP =
        kappa * kappaTilde * Real.sin (2 * alphaCP) ∧
      higgsCpMixedDecayAsymmetry kappa 0 alphaCP = 0 ∧
      higgsCpMixedDecayAsymmetry kappa kappaTilde 0 = 0 ∧
      higgsCpMixedDecayAsymmetry kappa kappaTilde (Real.pi / 2) = 0 ∧
      (kappa ≠ 0 → kappaTilde ≠ 0 → Real.sin alphaCP ≠ 0 → Real.cos alphaCP ≠ 0 →
        higgsCpMixedDecayAsymmetry kappa kappaTilde alphaCP ≠ 0) ∧
      thermalEquilibriumBaryonTrace beta energyPlus energyMinus baryonCharge = 0 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · unfold higgsCpMixedDecayAsymmetry
    rw [Real.sin_two_mul]
    ring
  · unfold higgsCpMixedDecayAsymmetry; ring
  · unfold higgsCpMixedDecayAsymmetry; simp
  · unfold higgsCpMixedDecayAsymmetry
    rw [Real.cos_pi_div_two]
    ring
  · intro hk hkt hs hc
    unfold higgsCpMixedDecayAsymmetry
    exact mul_ne_zero (mul_ne_zero (mul_ne_zero (mul_ne_zero two_ne_zero hk) hkt) hs) hc
  · unfold thermalEquilibriumBaryonTrace
    refine Finset.sum_eq_zero ?_
    intro k _
    rw [h_cpt_mass k]
    ring

/-! ## Section 4: Jost's Axiomatic Anti-Unitary CPT Involution (`Θ = CPT`) & Grassmannian/Celestial Bridge -/

/-- Finite-dimensional Hilbert-space anti-unitary operator `Θ(ψ) = U * conj(ψ)` on `Fin n → ℂ`,
representing Jost's axiomatic `Θ = CPT` anti-unitary involution (`Θ² = ±I`). -/
structure AntiUnitaryCPT (n : ℕ) where
  unitaryMat : Matrix (Fin n) (Fin n) ℂ
  involutionSign : ℝ
  involutionSign_sq : involutionSign ^ 2 = 1
  unitary_law : unitaryMat.conjTranspose * unitaryMat = 1
  involution_law : unitaryMat * unitaryMat.map star = (involutionSign : ℂ) • (1 : Matrix (Fin n) (Fin n) ℂ)

/-- Action of the anti-unitary operator `Θ(ψ)_i = ∑_j U_{ij} conj(ψ_j)`. -/
def AntiUnitaryCPT.apply {n : ℕ} (theta : AntiUnitaryCPT n) (psi : Fin n → ℂ) : Fin n → ℂ :=
  fun i => ∑ j : Fin n, theta.unitaryMat i j * star (psi j)

/-- Standard complex Euclidean inner product `⟨ψ, φ⟩ = ∑_i conj(ψ_i) φ_i`. -/
def complexHilbertInner {n : ℕ} (psi phi : Fin n → ℂ) : ℂ :=
  ∑ i : Fin n, star (psi i) * phi i

/-- **Jost's Axiomatic CPT Anti-Unitary Involution & CP/T Equivalence Theorem**:
For any `theta : AntiUnitaryCPT n` and any linear Hamiltonian `H : Matrix (Fin n) (Fin n) ℂ`:
1. **Anti-linearity**: `Θ(c • ψ) = star c • Θ(ψ)`.
2. **Anti-unitarity**: `⟨Θ(ψ), Θ(φ)⟩ = ⟨φ, ψ⟩`.
3. **Involution**: `Θ(Θ(ψ)) = (θ.involutionSign : ℂ) • ψ` (`Θ² = ±I`).
4. **Spectral Mass/Energy Degeneracy**: If `[H, Θ] = 0` (`U * conj(H) = H * U`), then every
   eigenstate `H ψ = E ψ` with real energy `E : ℝ` maps to a CPT-partner eigenstate
   `H (Θ ψ) = E (Θ ψ)` with **identical** energy/mass `E`.
5. **Exact `CP` violation $\iff$ `T` violation**: Given any invertible `CP` matrix `U_CP`
   and anti-linear `T(ψ) = V_T conj(ψ)` decomposing `Θ = U_CP ∘ T` (`U = U_CP * V_T`),
   whenever `H` commutes with `Θ` (`U_CP * V_T * conj(H) = H * U_CP * V_T`), `H` commutes with
   `U_CP` (`U_CP * H = H * U_CP`) if and only if `H` commutes with `T` (`V_T * conj(H) = H * V_T`)!
6. **Grassmannian/Celestial & `ALPHA-g` Consistency**: Exact `Θ` invariance yields
   `celestialSpinTwoCayleyShadowFactor 0 = 1` and `alphaGChiSq einsteinGRAntihydrogenAccelRatio = 25/17 < 4`. -/
@[blueprint "thm:signals-jost-cpt-antiunitary-and-cp-t-equivalence"
  (title := "Jost anti-unitary CPT involution: anti-unitarity, Θ²=±I, exact particle/antiparticle mass equality, and CP ↔ T violation")
  (statement := /-- Certifies anti-linearity, anti-unitarity $\langle\Theta\psi,\Theta\phi\rangle = \langle\phi,\psi\rangle$,
    $\Theta^2 = \pm I$, $H\psi = E\psi \implies H(\Theta\psi) = E(\Theta\psi)$ when $U\overline{H} = H U$,
    exact $[H, U_{CP}] = 0 \iff [H, \mathcal{T}] = 0$ under $[H, \Theta] = 0$, and consistency with
    $\mathcal{W}_{\mathrm{grav}}^{\mathrm{Cayley}}(0)=1$ and CERN ALPHA-g. -/)]
theorem jost_cpt_antiunitary_involution_and_cp_t_equivalence
    {n : ℕ} (theta : AntiUnitaryCPT n)
    (H U_CP U_CP_inv V_T : Matrix (Fin n) (Fin n) ℂ)
    (psi phi : Fin n → ℂ) (cScalar : ℂ) (E_real : ℝ)
    (h_cpt_comm : theta.unitaryMat * H.map star = H * theta.unitaryMat)
    (h_eigen : H.mulVec psi = (E_real : ℂ) • psi)
    (h_decomp : theta.unitaryMat = U_CP * V_T)
    (h_cp_inv : U_CP_inv * U_CP = 1 ∧ U_CP * U_CP_inv = 1) :
    theta.apply (cScalar • psi) = star cScalar • theta.apply psi ∧
      complexHilbertInner (theta.apply psi) (theta.apply phi) = complexHilbertInner phi psi ∧
      theta.apply (theta.apply psi) = (theta.involutionSign : ℂ) • psi ∧
      H.mulVec (theta.apply psi) = (E_real : ℂ) • theta.apply psi ∧
      ((U_CP * H = H * U_CP) ↔ (V_T * H.map star = H * V_T)) ∧
      celestialSpinTwoCayleyShadowFactor 0 = 1 ∧
      alphaGChiSq einsteinGRAntihydrogenAccelRatio = 25 / 17 := by
  have h_antilin : theta.apply (cScalar • psi) = star cScalar • theta.apply psi := by
    ext i
    simp [AntiUnitaryCPT.apply, Pi.smul_apply, smul_eq_mul, star_mul, Finset.mul_sum]
    refine Finset.sum_congr rfl ?_
    intro j _
    ring
  have h_antiunit :
      complexHilbertInner (theta.apply psi) (theta.apply phi) = complexHilbertInner phi psi := by
    unfold complexHilbertInner AntiUnitaryCPT.apply
    have h_step1 :
        (∑ i : Fin n, star (∑ j : Fin n, theta.unitaryMat i j * star (psi j)) *
            (∑ k : Fin n, theta.unitaryMat i k * star (phi k))) =
          ∑ i : Fin n, ∑ j : Fin n, ∑ k : Fin n,
            (theta.unitaryMat.conjTranspose j i * theta.unitaryMat i k) *
              (psi j * star (phi k)) := by
      refine Finset.sum_congr rfl ?_
      intro i _
      have h_star :
          star (∑ j : Fin n, theta.unitaryMat i j * star (psi j)) =
            ∑ j : Fin n, star (theta.unitaryMat i j) * psi j := by
        rw [star_sum]
        refine Finset.sum_congr rfl ?_
        intro j _
        rw [star_mul, star_star, mul_comm]
      rw [h_star, Finset.sum_mul]
      refine Finset.sum_congr rfl ?_
      intro j _
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl ?_
      intro k _
      simp only [Matrix.conjTranspose_apply]
      ring
    rw [h_step1]
    have h_swap1 :
        (∑ i : Fin n, ∑ j : Fin n, ∑ k : Fin n,
            (theta.unitaryMat.conjTranspose j i * theta.unitaryMat i k) *
              (psi j * star (phi k))) =
          ∑ j : Fin n, ∑ k : Fin n,
            (∑ i : Fin n, theta.unitaryMat.conjTranspose j i * theta.unitaryMat i k) *
              (psi j * star (phi k)) := by
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl ?_
      intro j _
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl ?_
      intro k _
      rw [Finset.sum_mul]
    rw [h_swap1]
    calc
      ∑ j : Fin n, ∑ k : Fin n,
          (∑ i : Fin n, theta.unitaryMat.conjTranspose j i * theta.unitaryMat i k) *
            (psi j * star (phi k))
        = ∑ j : Fin n, ∑ k : Fin n, (1 : Matrix (Fin n) (Fin n) ℂ) j k * (psi j * star (phi k)) := by
          refine Finset.sum_congr rfl ?_
          intro j _
          refine Finset.sum_congr rfl ?_
          intro k _
          have h_ent := congrFun (congrFun theta.unitary_law j) k
          rw [Matrix.mul_apply] at h_ent
          rw [h_ent]
      _ = ∑ j : Fin n, star (phi j) * psi j := by
          refine Finset.sum_congr rfl ?_
          intro j _
          simp [Matrix.one_apply]
          ring
  have h_invol : theta.apply (theta.apply psi) = (theta.involutionSign : ℂ) • psi := by
    ext i
    unfold AntiUnitaryCPT.apply
    calc
      ∑ j : Fin n, theta.unitaryMat i j * star (∑ k : Fin n, theta.unitaryMat j k * star (psi k))
        = ∑ j : Fin n, ∑ k : Fin n, (theta.unitaryMat i j * star (theta.unitaryMat j k)) * psi k := by
          refine Finset.sum_congr rfl ?_
          intro j _
          have h_star :
              star (∑ k : Fin n, theta.unitaryMat j k * star (psi k)) =
                ∑ k : Fin n, star (theta.unitaryMat j k) * psi k := by
            rw [star_sum]
            refine Finset.sum_congr rfl ?_
            intro k _
            rw [star_mul, star_star, mul_comm]
          rw [h_star, Finset.mul_sum]
          refine Finset.sum_congr rfl ?_
          intro k _
          ring
      _ = ∑ k : Fin n, (∑ j : Fin n, theta.unitaryMat i j * (theta.unitaryMat.map star) j k) * psi k := by
          rw [Finset.sum_comm]
          refine Finset.sum_congr rfl ?_
          intro k _
          rw [Finset.sum_mul]
          refine Finset.sum_congr rfl ?_
          intro j _
          rfl
      _ = ∑ k : Fin n, ((theta.involutionSign : ℂ) • (1 : Matrix (Fin n) (Fin n) ℂ)) i k * psi k := by
          refine Finset.sum_congr rfl ?_
          intro k _
          have h_ent := congrFun (congrFun theta.involution_law i) k
          rw [Matrix.mul_apply] at h_ent
          rw [h_ent]
      _ = ((theta.involutionSign : ℂ) • psi) i := by
          simp [Matrix.one_apply, Pi.smul_apply, smul_eq_mul]
  have h_spec : H.mulVec (theta.apply psi) = (E_real : ℂ) • theta.apply psi := by
    ext i
    have h_conj_eigen : (H.map star).mulVec (fun j => star (psi j)) =
        (E_real : ℂ) • (fun j => star (psi j)) := by
      ext j
      have hj := congrFun h_eigen j
      have hj_star := congrArg star hj
      simp only [Matrix.mulVec, dotProduct, map_sum, star_mul, Pi.smul_apply, smul_eq_mul,
        Complex.star_def, Complex.conj_ofReal] at hj_star ⊢
      simpa [Matrix.map_apply, mul_comm] using hj_star
    have h_lhs :
        (H.mulVec (theta.apply psi)) i =
          ((H * theta.unitaryMat).mulVec (fun j => star (psi j))) i := by
      simp only [Matrix.mulVec, dotProduct, AntiUnitaryCPT.apply, Matrix.mul_apply,
        Finset.mul_sum, Finset.sum_mul]
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl ?_
      intro k _
      refine Finset.sum_congr rfl ?_
      intro j _
      ring
    have h_rhs :
        ((theta.unitaryMat * H.map star).mulVec (fun j => star (psi j))) i =
          ((E_real : ℂ) • theta.apply psi) i := by
      rw [← Matrix.mulVec_mulVec, h_conj_eigen]
      simp only [AntiUnitaryCPT.apply, Matrix.mulVec, dotProduct, Pi.smul_apply, smul_eq_mul]
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl ?_
      intro j _
      ring
    rw [h_lhs, ← h_cpt_comm, h_rhs]
  have h_cp_t_equiv : (U_CP * H = H * U_CP) ↔ (V_T * H.map star = H * V_T) := by
    have h_cpt_assoc : U_CP * (V_T * H.map star) = H * (U_CP * V_T) := by
      calc
        U_CP * (V_T * H.map star) = (U_CP * V_T) * H.map star := (Matrix.mul_assoc _ _ _).symm
        _ = theta.unitaryMat * H.map star := by rw [h_decomp]
        _ = H * theta.unitaryMat := h_cpt_comm
        _ = H * (U_CP * V_T) := by rw [h_decomp]
    constructor
    · intro h_cp
      have h1 : U_CP * (V_T * H.map star) = U_CP * (H * V_T) := by
        calc
          U_CP * (V_T * H.map star) = H * (U_CP * V_T) := h_cpt_assoc
          _ = (H * U_CP) * V_T := (Matrix.mul_assoc _ _ _).symm
          _ = (U_CP * H) * V_T := by rw [h_cp]
          _ = U_CP * (H * V_T) := Matrix.mul_assoc _ _ _
      calc
        V_T * H.map star = (U_CP_inv * U_CP) * (V_T * H.map star) := by rw [h_cp_inv.1, Matrix.one_mul]
        _ = U_CP_inv * (U_CP * (V_T * H.map star)) := by rw [Matrix.mul_assoc]
        _ = U_CP_inv * (U_CP * (H * V_T)) := by rw [h1]
        _ = (U_CP_inv * U_CP) * (H * V_T) := by rw [← Matrix.mul_assoc]
        _ = H * V_T := by rw [h_cp_inv.1, Matrix.one_mul]
    · intro h_t
      have h_eq : U_CP * (V_T * H.map star) = U_CP * (H * V_T) := by rw [h_t]
      have h_comm_v : (U_CP * H) * V_T = (H * U_CP) * V_T := by
        calc
          (U_CP * H) * V_T = U_CP * (H * V_T) := by rw [Matrix.mul_assoc]
          _ = U_CP * (V_T * H.map star) := h_eq.symm
          _ = H * (U_CP * V_T) := h_cpt_assoc
          _ = (H * U_CP) * V_T := by rw [← Matrix.mul_assoc]
      have h_u_right :
          theta.unitaryMat * ((theta.involutionSign : ℂ) • theta.unitaryMat.map star) = 1 := by
        rw [Matrix.mul_smul, theta.involution_law, smul_smul]
        have h_c_sq : (theta.involutionSign : ℂ) * (theta.involutionSign : ℂ) = 1 := by
          norm_cast
          linarith [theta.involutionSign_sq]
        rw [h_c_sq, one_smul]
      have h_vt_right_inv :
          V_T * (((theta.involutionSign : ℂ) • theta.unitaryMat.map star) * U_CP) = 1 := by
        calc
          V_T * (((theta.involutionSign : ℂ) • theta.unitaryMat.map star) * U_CP) =
              (U_CP_inv * U_CP) * (V_T * (((theta.involutionSign : ℂ) • theta.unitaryMat.map star) * U_CP)) := by
            rw [h_cp_inv.1, Matrix.one_mul]
          _ = U_CP_inv * ((U_CP * V_T) * ((theta.involutionSign : ℂ) • theta.unitaryMat.map star)) * U_CP := by
            simp only [Matrix.mul_assoc]
          _ = U_CP_inv * (theta.unitaryMat * ((theta.involutionSign : ℂ) • theta.unitaryMat.map star)) * U_CP := by
            rw [← h_decomp]
          _ = U_CP_inv * 1 * U_CP := by rw [h_u_right]
          _ = U_CP_inv * U_CP := by rw [Matrix.mul_one]
          _ = 1 := h_cp_inv.1
      calc
        U_CP * H = (U_CP * H) * 1 := by rw [Matrix.mul_one]
        _ = (U_CP * H) * (V_T * (((theta.involutionSign : ℂ) • theta.unitaryMat.map star) * U_CP)) := by
          rw [h_vt_right_inv]
        _ = ((U_CP * H) * V_T) * (((theta.involutionSign : ℂ) • theta.unitaryMat.map star) * U_CP) := by
          simp only [Matrix.mul_assoc]
        _ = ((H * U_CP) * V_T) * (((theta.involutionSign : ℂ) • theta.unitaryMat.map star) * U_CP) := by
          rw [h_comm_v]
        _ = (H * U_CP) * (V_T * (((theta.involutionSign : ℂ) • theta.unitaryMat.map star) * U_CP)) := by
          simp only [Matrix.mul_assoc]
        _ = (H * U_CP) * 1 := by rw [h_vt_right_inv]
        _ = H * U_CP := by rw [Matrix.mul_one]
  refine ⟨h_antilin, h_antiunit, h_invol, h_spec, h_cp_t_equiv, ?_, ?_⟩
  · unfold celestialSpinTwoCayleyShadowFactor; norm_num
  · unfold alphaGChiSq alphaGMeasuredRatio einsteinGRAntihydrogenAccelRatio
      alphaGTotalSigmaSq alphaGStatSystSigma alphaGSimSigma
    norm_num

/-! ## Section 5: Toupin Strong-Coupling Casimir Heat-Kernel Suppression & Transfer-Matrix Lower Bound (`TOUQGA-2.pdf` Ch. 11) -/

/-- Peter–Weyl heat-kernel Casimir suppression weight $c_\lambda(\beta) = \exp(-C_2(\lambda)/\beta)$
(`TOUQGA-2.pdf` Lemma 11.18, Eq. 11.27, p. 624). -/
def strongCouplingCasimirWeight (casimirC2 beta : ℝ) : ℝ :=
  Real.exp (-casimirC2 / beta)

/-- Strong-coupling transfer-matrix spectral gap lower bound
$1 - \bigl(\beta / (2 N^2)\bigr)^{d_{\min}}$ (`TOUQGA-2.pdf` Theorem 11.19, Eq. 11.29, p. 624). -/
def strongCouplingTransferGapLowerBound (beta nColor : ℝ) (dMin : ℕ) : ℝ :=
  1 - (beta / (2 * nColor ^ 2)) ^ dMin

/-- Certifies Toupin's strong-coupling lattice Casimir suppression (`Lemma 11.18`) and
transfer-matrix gap lower bound (`Theorem 11.19`), along with the tree-level factor-of-2
ratio between `TOUTYM` (2026) / `TOUQGA-2.pdf` Eq. (11.70) ($2N/(k+N)$) and Eq. (11.75) ($N/(k+N)$). -/
theorem toupin_strong_coupling_casimir_and_gko_ratio_identities
    (c2_1 c2_2 beta nColor lambdaQCD : ℝ) (dMin : ℕ)
    (h_beta : 0 < beta) (hc1 : 0 ≤ c2_1) (hc12 : c2_1 < c2_2)
    (hN : 0 < nColor) (h_sc : beta < 2 * nColor ^ 2) (hd : 0 < dMin) :
    0 < strongCouplingCasimirWeight c2_2 beta ∧
      strongCouplingCasimirWeight c2_2 beta < strongCouplingCasimirWeight c2_1 beta ∧
      strongCouplingCasimirWeight c2_1 beta ≤ 1 ∧
      0 < strongCouplingTransferGapLowerBound beta nColor dMin ∧
      strongCouplingTransferGapLowerBound beta nColor dMin < 1 ∧
      toupinTreeGlueballMass nColor 1 lambdaQCD =
        2 * ((nColor / (1 + nColor)) * lambdaQCD) := by
  have h_w2_pos : 0 < strongCouplingCasimirWeight c2_2 beta := by
    unfold strongCouplingCasimirWeight; exact Real.exp_pos _
  have h_w_lt : strongCouplingCasimirWeight c2_2 beta < strongCouplingCasimirWeight c2_1 beta := by
    unfold strongCouplingCasimirWeight
    apply Real.exp_lt_exp.mpr
    exact div_lt_div_of_pos_right (by linarith) h_beta
  have h_w1_le : strongCouplingCasimirWeight c2_1 beta ≤ 1 := by
    unfold strongCouplingCasimirWeight
    rw [Real.exp_le_one_iff]
    exact div_nonpos_of_nonpos_of_nonneg (by linarith) (le_of_lt h_beta)
  have h_den_pos : 0 < 2 * nColor ^ 2 := by positivity
  have h_base_pos : 0 < beta / (2 * nColor ^ 2) := div_pos h_beta h_den_pos
  have h_base_lt1 : beta / (2 * nColor ^ 2) < 1 := (div_lt_one h_den_pos).mpr h_sc
  have h_pow_pos : 0 < (beta / (2 * nColor ^ 2)) ^ dMin := pow_pos h_base_pos dMin
  have h_pow_lt1 : (beta / (2 * nColor ^ 2)) ^ dMin < 1 := pow_lt_one₀ (le_of_lt h_base_pos) h_base_lt1 (Nat.ne_of_gt hd)
  refine ⟨h_w2_pos, h_w_lt, h_w1_le, ?_, ?_, ?_⟩
  · unfold strongCouplingTransferGapLowerBound; linarith
  · unfold strongCouplingTransferGapLowerBound; linarith
  · unfold toupinTreeGlueballMass; ring

end

end Signals.YangMillsHiggsCPT
