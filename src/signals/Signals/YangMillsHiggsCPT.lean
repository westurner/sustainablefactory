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

/-! ## Section 6: Finite-Group Unitary Haar Singlet Projector (`P = |G|⁻¹ ∑_g ρ(g)`), Jarlskog Mass-Splitting, & Out-of-Equilibrium Sakharov Theorem -/

/-- Unitary representation of a finite group `G` on `ℂ^m`, carrying `ρ(g * h) = ρ(g) * ρ(h)`,
`ρ(1) = 1`, and unitarity `ρ(g)† = ρ(g⁻¹)`. -/
structure FiniteGroupUnitaryRep (G : Type*) [Group G] (m : ℕ) where
  rep : G → Matrix (Fin m) (Fin m) ℂ
  rep_one : rep 1 = 1
  rep_mul : ∀ g h : G, rep (g * h) = rep g * rep h
  rep_conjTranspose : ∀ g : G, (rep g).conjTranspose = rep g⁻¹

/-- Normalized Haar singlet projector `P_singlet = (|G|⁻¹ : ℂ) • ∑ g : G, ρ(g)`. -/
def FiniteGroupUnitaryRep.haarProjector {G : Type*} [Group G] [Fintype G] {m : ℕ}
    (rho : FiniteGroupUnitaryRep G m) : Matrix (Fin m) (Fin m) ℂ :=
  ((Fintype.card G : ℂ)⁻¹) • (∑ g : G, rho.rep g)

/-- **Peter–Weyl / Haar Singlet Projector Theorem for Arbitrary Finite Groups (Abelian or Non-Abelian)**:
For any finite group `G` (`SU(N)` finite subgroup proxy such as `S_3` or `Z_N`) and unitary
representation `ρ : G → U(m)`:
1. **Left & Right Gauge Invariance**: `ρ(h) * P = P` and `P * ρ(h) = P` for all `h : G`.
2. **Idempotence**: `P * P = P`.
3. **Hermiticity**: `P† = P`.
4. **Annihilation of Zero-Sum Colored Modes**: Any mode `v : Fin m → ℂ` satisfying `∑ g : G, ρ(g) v = 0`
   is annihilated identically (`P.mulVec v = 0`). -/
@[blueprint "thm:signals-ym-finite-group-haar-projector"
  (title := "Unitary finite-group Haar singlet projector: gauge invariance, idempotence, Hermiticity, and colored-mode annihilation")
  (statement := /-- For any finite group $G$ and unitary representation $\rho : G \to \mathrm{U}(m)$,
    $P = |G|^{-1}\sum_{g\in G}\rho(g)$ satisfies $\rho(h)P = P\rho(h) = P$, $P^2 = P$,
    $P^\dagger = P$, and $Pv = 0$ whenever $\sum_{g\in G}\rho(g)v = 0$. -/)]
theorem finiteGroup_haarProjector_properties
    {G : Type*} [Group G] [Fintype G] [Nonempty G] {m : ℕ}
    (rho : FiniteGroupUnitaryRep G m) (h : G) (v : Fin m → ℂ)
    (h_colored : ∑ g : G, (rho.rep g).mulVec v = 0) :
    rho.rep h * rho.haarProjector = rho.haarProjector ∧
      rho.haarProjector * rho.rep h = rho.haarProjector ∧
      rho.haarProjector * rho.haarProjector = rho.haarProjector ∧
      rho.haarProjector.conjTranspose = rho.haarProjector ∧
      rho.haarProjector.mulVec v = 0 := by
  have hcard_ne : (Fintype.card G : ℂ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  have h_left : rho.rep h * rho.haarProjector = rho.haarProjector := by
    unfold FiniteGroupUnitaryRep.haarProjector
    rw [Matrix.mul_smul, Finset.mul_sum]
    have h_shift : ∑ g : G, rho.rep h * rho.rep g = ∑ g : G, rho.rep g := by
      calc
        ∑ g : G, rho.rep h * rho.rep g = ∑ g : G, rho.rep (h * g) := by
          refine Finset.sum_congr rfl ?_
          intro g _; exact (rho.rep_mul h g).symm
        _ = ∑ g : G, rho.rep g := Fintype.sum_bijective (h * ·) (Group.mulLeft_bijective h) _ _ (fun _ => rfl)
    rw [h_shift]
  have h_right_all : ∀ k : G, rho.haarProjector * rho.rep k = rho.haarProjector := by
    intro k
    unfold FiniteGroupUnitaryRep.haarProjector
    rw [Matrix.smul_mul, Finset.sum_mul]
    have h_shift : ∑ g : G, rho.rep g * rho.rep k = ∑ g : G, rho.rep g := by
      calc
        ∑ g : G, rho.rep g * rho.rep k = ∑ g : G, rho.rep (g * k) := by
          refine Finset.sum_congr rfl ?_
          intro g _; exact (rho.rep_mul g k).symm
        _ = ∑ g : G, rho.rep g := Fintype.sum_bijective (· * k) (Group.mulRight_bijective k) _ _ (fun _ => rfl)
    rw [h_shift]
  have h_right : rho.haarProjector * rho.rep h = rho.haarProjector := h_right_all h
  have h_idem : rho.haarProjector * rho.haarProjector = rho.haarProjector := by
    calc
      rho.haarProjector * rho.haarProjector =
          rho.haarProjector * (((Fintype.card G : ℂ)⁻¹) • ∑ g : G, rho.rep g) := rfl
      _ = ((Fintype.card G : ℂ)⁻¹) • (rho.haarProjector * ∑ g : G, rho.rep g) := Matrix.mul_smul _ _ _
      _ = ((Fintype.card G : ℂ)⁻¹) • ∑ g : G, (rho.haarProjector * rho.rep g) := by
        rw [Finset.mul_sum]
      _ = ((Fintype.card G : ℂ)⁻¹) • ∑ _g : G, rho.haarProjector := by
        refine congrArg _ (Finset.sum_congr rfl fun g _ => h_right_all g)
      _ = ((Fintype.card G : ℂ)⁻¹) • ((Fintype.card G : ℕ) • rho.haarProjector) := by
        rw [Finset.sum_const, Finset.card_univ]
      _ = ((Fintype.card G : ℂ)⁻¹) • ((Fintype.card G : ℂ) • rho.haarProjector) := by
        rw [Nat.cast_smul_eq_nsmul]
      _ = (((Fintype.card G : ℂ)⁻¹) * (Fintype.card G : ℂ)) • rho.haarProjector := smul_smul _ _ _
      _ = rho.haarProjector := by rw [inv_mul_cancel₀ hcard_ne, one_smul]
  have h_herm : rho.haarProjector.conjTranspose = rho.haarProjector := by
    unfold FiniteGroupUnitaryRep.haarProjector
    rw [Matrix.conjTranspose_smul, star_inv₀]
    have h_star_card : star (Fintype.card G : ℂ) = (Fintype.card G : ℂ) := by simp
    rw [h_star_card]
    congr 1
    rw [Matrix.conjTranspose_sum]
    calc
      ∑ g : G, (rho.rep g).conjTranspose = ∑ g : G, rho.rep g⁻¹ := by
        refine Finset.sum_congr rfl ?_
        intro g _; exact rho.rep_conjTranspose g
      _ = ∑ g : G, rho.rep g :=
        Fintype.sum_bijective Inv.inv inv_involutive.bijective _ _ (fun _ => rfl)
  have h_ann : rho.haarProjector.mulVec v = 0 := by
    unfold FiniteGroupUnitaryRep.haarProjector
    have h_smul_mv :
        (((Fintype.card G : ℂ)⁻¹) • (∑ g : G, rho.rep g)).mulVec v =
          ((Fintype.card G : ℂ)⁻¹) • ((∑ g : G, rho.rep g).mulVec v) := by
      ext i
      simp only [Matrix.mulVec, dotProduct, Matrix.smul_apply, Pi.smul_apply, smul_eq_mul,
        Finset.mul_sum]
      refine Finset.sum_congr rfl ?_
      intro j _
      ring
    rw [h_smul_mv]
    have h_sum_vec : (∑ g : G, rho.rep g).mulVec v = ∑ g : G, (rho.rep g).mulVec v := by
      ext i
      simp only [Matrix.mulVec, dotProduct, Matrix.sum_apply, Finset.sum_apply]
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl ?_
      intro j _
      rw [Finset.sum_mul]
    rw [h_sum_vec, h_colored, smul_zero]
  exact ⟨h_left, h_right, h_idem, h_herm, h_ann⟩

/-- Standard Model fermion mass-difference prefactor multiplying `J_CP` in the full
CP-violating determinant `Im det[M_u M_u†, M_d M_d†]`:
vanishes if any two up-type quarks (`m_u, m_c, m_t`) or any two down-type quarks (`m_d, m_s, m_b`)
are mass-degenerate. -/
def jarlskogQuarkMassSplitting (mu mc mt md ms mb : ℝ) : ℝ :=
  (mu ^ 2 - mc ^ 2) * (mc ^ 2 - mt ^ 2) * (mt ^ 2 - mu ^ 2) *
    (md ^ 2 - ms ^ 2) * (ms ^ 2 - mb ^ 2) * (mb ^ 2 - md ^ 2)

/-- **Jarlskog Degeneracy Null Law & Out-of-Equilibrium Sakharov Theorem**:
1. `jarlskogQuarkMassSplitting` vanishes if `mu = mc` (or `md = ms`), and is nonzero whenever all
   up-type masses and down-type masses have distinct nonnegative values.
2. For a single particle/antiparticle doublet with nonzero baryon charge `b ≠ 0`, `β > 0`, and
   strictly out-of-equilibrium effective energies `E_plus ≠ E_minus` (such as a transient Higgs-wall
   bias during a first-order electroweak phase transition), `thermalEquilibriumBaryonTrace ≠ 0`. -/
theorem jarlskog_degeneracy_and_sakharov_out_of_equilibrium_nonzero
    (mu mc mt md ms mb beta ePlus eMinus bCharge : ℝ)
    (h_beta : 0 < beta) (h_neq : ePlus ≠ eMinus) (hb : bCharge ≠ 0) :
    jarlskogQuarkMassSplitting mu mu mt md ms mb = 0 ∧
      jarlskogQuarkMassSplitting mu mc mt md md mb = 0 ∧
      (mu ^ 2 ≠ mc ^ 2 → mc ^ 2 ≠ mt ^ 2 → mt ^ 2 ≠ mu ^ 2 →
        md ^ 2 ≠ ms ^ 2 → ms ^ 2 ≠ mb ^ 2 → mb ^ 2 ≠ md ^ 2 →
        jarlskogQuarkMassSplitting mu mc mt md ms mb ≠ 0) ∧
      thermalEquilibriumBaryonTrace beta (fun _ : Fin 1 => ePlus) (fun _ : Fin 1 => eMinus)
        (fun _ : Fin 1 => bCharge) ≠ 0 := by
  refine ⟨by unfold jarlskogQuarkMassSplitting; ring,
    by unfold jarlskogQuarkMassSplitting; ring, ?_, ?_⟩
  · intro h1 h2 h3 h4 h5 h6
    unfold jarlskogQuarkMassSplitting
    exact mul_ne_zero (mul_ne_zero (mul_ne_zero (mul_ne_zero (mul_ne_zero
      (sub_ne_zero.mpr h1) (sub_ne_zero.mpr h2)) (sub_ne_zero.mpr h3))
      (sub_ne_zero.mpr h4)) (sub_ne_zero.mpr h5)) (sub_ne_zero.mpr h6)
  · unfold thermalEquilibriumBaryonTrace
    simp only [Finset.univ_unique, Fin.default_eq_zero, Fin.isValue, Finset.sum_singleton]
    have h_fact :
        bCharge * Real.exp (-beta * ePlus) + (-bCharge) * Real.exp (-beta * eMinus) =
          bCharge * (Real.exp (-beta * ePlus) - Real.exp (-beta * eMinus)) := by ring
    rw [h_fact]
    apply mul_ne_zero hb
    apply sub_ne_zero.mpr
    intro h_exp
    have h_arg : -beta * ePlus = -beta * eMinus := Real.exp_injective h_exp
    have h_nbeta : -beta ≠ 0 := neg_ne_zero.mpr (ne_of_gt h_beta)
    exact h_neq (mul_left_cancel₀ h_nbeta h_arg)

/-! ## Section 7: Gap-Closure Constructive Contracts (Continuum RG Scaling, Finite OS Reflection Positivity, Confined Källén–Lehmann & GKO Obstruction, ATLAS/CMS CP Envelope, & EWPT Sphaleron Washout) -/

/-- 1-loop $\mathrm{SU}(N_c)$ asymptotic lattice spacing in units of $\Lambda_{\mathrm{YM}}$:
$a(\beta)\,\Lambda_{\mathrm{YM}} = \exp\!\left(-\frac{4\pi^2 \beta}{b_0 N_c}\right)$, where $\beta = 2 N_c / g_0^2$. -/
def latticeAsymptoticSpacing (b0 nColor beta : ℝ) : ℝ :=
  Real.exp (-(4 * Real.pi ^ 2 * beta) / (b0 * nColor))

/-- Strong-coupling transfer-matrix gap lower bound $\Delta_{\mathrm{sc}}(\beta, N_c) = -\ln(\beta / (2 N_c^2))$
on a unit lattice, vanishing at $\beta = 2 N_c^2$ and turning negative for $\beta > 2 N_c^2$. -/
def strongCouplingLogGap (beta nColor : ℝ) : ℝ :=
  -Real.log (beta / (2 * nColor ^ 2))

/-- **Gap 1 (Continuum RG Scaling, Strong-Coupling Breakdown, & Conditional Uniform Mass Gap)**:
1. Along 1-loop asymptotic freedom (`b0 > 0, nColor > 0`), increasing $\beta_1 < \beta_2$ strictly
   shrinks the lattice spacing $0 < a(\beta_2) < a(\beta_1)$, and $a(\beta) < 1$ for $\beta > 0$.
2. The strong-coupling gap bound `strongCouplingLogGap` vanishes at $\beta = 2 N_c^2$ and turns
   strictly negative for $\beta > 2 N_c^2$, proving why strong-coupling expansions cannot cross to $\beta \to \infty$.
3. **Conditional Continuum Uniform-Gap Theorem**: if a lattice sequence achieves physical gap
   $M_{\mathrm{phys}}(i) = \Delta_{\mathrm{lat}}(i) / a_i \ge M_0 > 0$ uniformly and converges to $M_\infty$,
   then $M_\infty \ge M_0 > 0$. -/
@[blueprint "thm:signals-ym-continuum-rg-and-sc-breakdown"
  (title := "Lattice 1-loop continuum scaling, strong-coupling breakdown, and conditional uniform mass gap")
  (statement := /-- Proves $0 < a(\beta_2) < a(\beta_1)$ for $\beta_1 < \beta_2$, breakdown of the
    strong-coupling bound at $\beta \ge 2N_c^2$, and $M_\infty \ge M_0 > 0$ under uniform scaling. -/)]
theorem lattice_rg_continuum_scaling_and_strong_coupling_breakdown
    (b0 nColor beta1 beta2 betaHigh m0 mInf : ℝ)
    (physGap : ℕ → ℝ)
    (hb0 : 0 < b0) (hN : 0 < nColor) (h_b1 : 0 < beta1) (h_b12 : beta1 < beta2)
    (h_high : 2 * nColor ^ 2 < betaHigh)
    (hm0 : 0 < m0) (h_unif : ∀ i : ℕ, m0 ≤ physGap i)
    (h_lim : ∀ eps : ℝ, 0 < eps → ∃ i : ℕ, |mInf - physGap i| < eps) :
    0 < latticeAsymptoticSpacing b0 nColor beta2 ∧
      latticeAsymptoticSpacing b0 nColor beta2 < latticeAsymptoticSpacing b0 nColor beta1 ∧
      latticeAsymptoticSpacing b0 nColor beta1 < 1 ∧
      strongCouplingLogGap (2 * nColor ^ 2) nColor = 0 ∧
      strongCouplingLogGap betaHigh nColor < 0 ∧
      0 < mInf ∧ m0 ≤ mInf := by
  have h_bn : 0 < b0 * nColor := mul_pos hb0 hN
  have h_pi2 : 0 < 4 * Real.pi ^ 2 := by positivity
  have h_a2_pos : 0 < latticeAsymptoticSpacing b0 nColor beta2 := by
    unfold latticeAsymptoticSpacing; exact Real.exp_pos _
  have h_a2_lt_a1 :
      latticeAsymptoticSpacing b0 nColor beta2 < latticeAsymptoticSpacing b0 nColor beta1 := by
    unfold latticeAsymptoticSpacing
    apply Real.exp_lt_exp.mpr
    apply div_lt_div_of_pos_right _ h_bn
    nlinarith
  have h_a1_lt1 : latticeAsymptoticSpacing b0 nColor beta1 < 1 := by
    unfold latticeAsymptoticSpacing
    rw [Real.exp_lt_one_iff]
    rw [neg_div]
    exact neg_lt_zero.mpr (div_pos (mul_pos h_pi2 h_b1) h_bn)
  have h_2n2_ne : 2 * nColor ^ 2 ≠ 0 := by positivity
  have h_sc_zero : strongCouplingLogGap (2 * nColor ^ 2) nColor = 0 := by
    unfold strongCouplingLogGap
    rw [div_self h_2n2_ne, Real.log_one, neg_zero]
  have h_sc_neg : strongCouplingLogGap betaHigh nColor < 0 := by
    unfold strongCouplingLogGap
    have h_gt1 : 1 < betaHigh / (2 * nColor ^ 2) := (one_lt_div (by positivity)).mpr h_high
    linarith [Real.log_pos h_gt1]
  have h_m0_le_inf : m0 ≤ mInf := by
    by_contra h_lt
    have h_eps : 0 < m0 - mInf := by linarith
    rcases h_lim (m0 - mInf) h_eps with ⟨i, hi⟩
    have h_lo := (abs_lt.mp hi).1
    linarith [h_unif i]
  exact ⟨h_a2_pos, h_a2_lt_a1, h_a1_lt1, h_sc_zero, h_sc_neg, lt_of_lt_of_le hm0 h_m0_le_inf, h_m0_le_inf⟩

/-- Finite Euclidean Schwinger two-point function $S_2(\tau) = \sum_{k=0}^{m-1} w_k e^{-E_k \tau}$. -/
def finiteOSSchwingerTwoPoint {m : ℕ} (weights energies : Fin m → ℝ) (tau : ℝ) : ℝ :=
  ∑ k : Fin m, weights k * Real.exp (-energies k * tau)

/-- Osterwalder–Schrader reflection-positivity quadratic form
$\sum_{i,j} \overline{f_i}\,f_j\,S_2(t_i + t_j)$ for test weights `f : Fin r → ℂ`
supported at positive Euclidean times `t : Fin r → ℝ`. -/
def finiteOSReflectionForm {m r : ℕ}
    (weights energies : Fin m → ℝ) (times : Fin r → ℝ) (fTest : Fin r → ℂ) : ℂ :=
  ∑ i : Fin r, ∑ j : Fin r,
    star (fTest i) * fTest j * (finiteOSSchwingerTwoPoint weights energies (times i + times j) : ℂ)

/-- **Gap 1 (Finite Osterwalder–Schrader Reflection Positivity & Exponential Clustering)**:
1. **Exact OS Reflection Factorization**: for any non-negative spectral weights `w_k ≥ 0`,
   the OS form equals $\sum_k w_k \lvert \sum_i f_i e^{-E_k t_i} \rvert^2$, proving `.im = 0` and `.re ≥ 0`.
2. **Exponential Clustering**: if all connected states satisfy `0 < E_gap ≤ E_k` and `0 ≤ τ`, then
   $0 \le S_2(\tau) \le \bigl(\sum_k w_k\bigr) e^{-E_{\mathrm{gap}}\tau}$. -/
@[blueprint "thm:signals-ym-os-reflection-positivity"
  (title := "Finite Osterwalder-Schrader reflection positivity and exponential clustering")
  (statement := /-- Proves $\sum_{i,j}\overline{f_i}f_j S_2(t_i+t_j) = \sum_k w_k\lvert\sum_i f_i e^{-E_k t_i}\rvert^2 \ge 0$
    and exponential clustering $0 \le S_2(\tau) \le (\sum_k w_k)e^{-E_{\mathrm{gap}}\tau}$ for $E_k \ge E_{\mathrm{gap}}$. -/)]
theorem osReflectionPositivity_and_clustering_of_spectral_weights
    {m r : ℕ} (weights energies : Fin m → ℝ) (times : Fin r → ℝ) (fTest : Fin r → ℂ)
    (eGap tau : ℝ)
    (hw : ∀ k : Fin m, 0 ≤ weights k)
    (hE : ∀ k : Fin m, eGap ≤ energies k) (htau : 0 ≤ tau) :
    (finiteOSReflectionForm weights energies times fTest).im = 0 ∧
      0 ≤ (finiteOSReflectionForm weights energies times fTest).re ∧
      0 ≤ finiteOSSchwingerTwoPoint weights energies tau ∧
      finiteOSSchwingerTwoPoint weights energies tau ≤
        (∑ k : Fin m, weights k) * Real.exp (-eGap * tau) := by
  have h_factor :
      finiteOSReflectionForm weights energies times fTest =
        ∑ k : Fin m, (weights k : ℂ) *
          (Complex.normSq (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ)) : ℂ) := by
    unfold finiteOSReflectionForm finiteOSSchwingerTwoPoint
    have h_inner_eq :
        (∑ i : Fin r, ∑ j : Fin r, star (fTest i) * fTest j *
          ((∑ k : Fin m, weights k * Real.exp (-energies k * (times i + times j)) : ℝ) : ℂ)) =
          ∑ k : Fin m, (weights k : ℂ) *
            ((star (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ))) *
              (∑ j : Fin r, fTest j * (Real.exp (-energies k * times j) : ℂ))) := by
      calc
        ∑ i : Fin r, ∑ j : Fin r, star (fTest i) * fTest j *
            ((∑ k : Fin m, weights k * Real.exp (-energies k * (times i + times j)) : ℝ) : ℂ)
          = ∑ i : Fin r, ∑ j : Fin r, ∑ k : Fin m,
              (weights k : ℂ) * (star (fTest i) * (Real.exp (-energies k * times i) : ℂ)) *
                (fTest j * (Real.exp (-energies k * times j) : ℂ)) := by
            refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
            push_cast
            rw [Finset.mul_sum]
            refine Finset.sum_congr rfl fun k _ => ?_
            have h_exp :
                Complex.exp (-(energies k : ℂ) * ((times i : ℂ) + (times j : ℂ))) =
                  Complex.exp (-(energies k : ℂ) * (times i : ℂ)) *
                    Complex.exp (-(energies k : ℂ) * (times j : ℂ)) := by
              rw [← Complex.exp_add]
              congr 1; ring
            rw [h_exp]
            ring
        _ = ∑ i : Fin r, ∑ k : Fin m, ∑ j : Fin r,
              (weights k : ℂ) * (star (fTest i) * (Real.exp (-energies k * times i) : ℂ)) *
                (fTest j * (Real.exp (-energies k * times j) : ℂ)) := by
            refine Finset.sum_congr rfl fun i _ => Finset.sum_comm
        _ = ∑ k : Fin m, ∑ i : Fin r, ∑ j : Fin r,
              (weights k : ℂ) * (star (fTest i) * (Real.exp (-energies k * times i) : ℂ)) *
                (fTest j * (Real.exp (-energies k * times j) : ℂ)) := Finset.sum_comm
        _ = ∑ k : Fin m, (weights k : ℂ) *
              ((star (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ))) *
                (∑ j : Fin r, fTest j * (Real.exp (-energies k * times j) : ℂ))) := by
            refine Finset.sum_congr rfl fun k _ => ?_
            symm
            calc
              (weights k : ℂ) *
                  ((star (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ))) *
                    (∑ j : Fin r, fTest j * (Real.exp (-energies k * times j) : ℂ)))
                = (weights k : ℂ) *
                    ∑ i : Fin r, star (fTest i * (Real.exp (-energies k * times i) : ℂ)) *
                      (∑ j : Fin r, fTest j * (Real.exp (-energies k * times j) : ℂ)) := by
                    rw [star_sum, Finset.sum_mul]
              _ = ∑ i : Fin r, (weights k : ℂ) *
                    (star (fTest i * (Real.exp (-energies k * times i) : ℂ)) *
                      (∑ j : Fin r, fTest j * (Real.exp (-energies k * times j) : ℂ))) :=
                    Finset.mul_sum _ _ _
              _ = ∑ i : Fin r, ∑ j : Fin r,
                    (weights k : ℂ) * (star (fTest i) * (Real.exp (-energies k * times i) : ℂ)) *
                      (fTest j * (Real.exp (-energies k * times j) : ℂ)) := by
                    refine Finset.sum_congr rfl fun i _ => ?_
                    rw [← mul_assoc, Finset.mul_sum]
                    refine Finset.sum_congr rfl fun j _ => ?_
                    rw [star_mul, Complex.star_def, Complex.conj_ofReal]
                    ring
    rw [h_inner_eq]
    refine Finset.sum_congr rfl fun k _ => ?_
    congr 1
    set z : ℂ := ∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ)
    apply Complex.ext <;> (simp [Complex.normSq_apply]; try ring)
  have h_im : (finiteOSReflectionForm weights energies times fTest).im = 0 := by
    rw [h_factor]
    change Complex.imLm (∑ k : Fin m, (weights k : ℂ) *
      (Complex.normSq (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ)) : ℂ)) = 0
    rw [map_sum]
    refine Finset.sum_eq_zero fun k _ => ?_
    change ((weights k : ℂ) *
      (Complex.normSq (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ)) : ℂ)).im = 0
    simp
  have h_re : 0 ≤ (finiteOSReflectionForm weights energies times fTest).re := by
    rw [h_factor]
    change 0 ≤ Complex.reLm (∑ k : Fin m, (weights k : ℂ) *
      (Complex.normSq (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ)) : ℂ))
    rw [map_sum]
    refine Finset.sum_nonneg fun k _ => ?_
    change 0 ≤ ((weights k : ℂ) *
      (Complex.normSq (∑ i : Fin r, fTest i * (Real.exp (-energies k * times i) : ℂ)) : ℂ)).re
    simp only [Complex.mul_re, Complex.ofReal_re, Complex.ofReal_im, zero_mul, sub_zero]
    exact mul_nonneg (hw k) (Complex.normSq_nonneg _)
  have h_s2_nn : 0 ≤ finiteOSSchwingerTwoPoint weights energies tau := by
    unfold finiteOSSchwingerTwoPoint
    exact Finset.sum_nonneg fun k _ => mul_nonneg (hw k) (Real.exp_pos _).le
  have h_s2_le : finiteOSSchwingerTwoPoint weights energies tau ≤
      (∑ k : Fin m, weights k) * Real.exp (-eGap * tau) := by
    unfold finiteOSSchwingerTwoPoint
    rw [Finset.sum_mul]
    refine Finset.sum_le_sum fun k _ => ?_
    apply mul_le_mul_of_nonneg_left _ (hw k)
    apply Real.exp_le_exp.mpr
    exact mul_le_mul_of_nonneg_right (neg_le_neg (hE k)) htau
  exact ⟨h_im, h_re, h_s2_nn, h_s2_le⟩

/-- Effective continuous level $k_{\mathrm{eff}}(N_c, \Lambda_{\mathrm{QCD}}, M_{\mathrm{phys}}) = N_c (2\Lambda_{\mathrm{QCD}} / M_{\mathrm{phys}} - 1)$
matching `toupinTreeGlueballMass nColor kEff lambdaQCD = mPhys`. -/
def toupinEffectiveRunningLevel (nColor lambdaQCD mPhys : ℝ) : ℝ :=
  nColor * (2 * lambdaQCD / mPhys - 1)

/-- **Gaps 2 & 3 (Källén–Lehmann Confined Spectral Integrability & Tree-Level GKO Integer-Level Obstruction)**:
1. On `[mGap, ∞)` with `mGap > 0`, soft `ω = 0` poles are strictly excluded (`ω ≠ 0`), and for `2 ≤ delta`,
   `(ω^2 - mGap^2)^((delta-2)/2) * ω * (A * exp(-μ ω)) ≤ A * ω^(delta-1) * exp(-μ ω)`.
2. For any `nColor > 0`, `0 ≤ kLevel`, and `lambdaQCD > 0`, `toupinTreeGlueballMass nColor kLevel lambdaQCD ≤ 2 * lambdaQCD`;
   consequently, at `lambdaQCD = 220` MeV and lattice QCD `0++` scalar mass `1610` MeV, **no** nonnegative
   level `kLevel ≥ 0` reaches `1610` MeV (`toupinTreeGlueballMass nColor kLevel 220 < 1610`).
3. Solving for the target physical mass `mPhys > 0` fixes `kEff = toupinEffectiveRunningLevel nColor lambdaQCD mPhys`,
   which must be negative (`kEff < 0`) whenever `2 * lambdaQCD < mPhys`! -/
@[blueprint "thm:signals-ym-kl-and-gko-obstruction"
  (title := "Kallen-Lehmann confined Mellin envelope and tree-level GKO integer-level obstruction")
  (statement := /-- Proves soft-pole exclusion $\omega \ne 0$ and Mellin tail domination on $[m_{\mathrm{gap}},\infty)$,
    plus the exact algebraic obstruction $M_k(N_c, 220) \le 440 < 1610\text{ MeV}$ for all $k \ge 0$. -/)]
theorem kallenLehmann_confined_envelope_and_gko_obstruction
    (mGap omega delta ampBound muIr nColor kLevel lambdaQCD mPhys : ℝ)
    (hm : 0 < mGap) (homega : mGap ≤ omega) (hdelta : 2 ≤ delta) (hA : 0 ≤ ampBound)
    (hN : 0 < nColor) (hk : 0 ≤ kLevel) (hL : 0 < lambdaQCD) (hmp : 0 < mPhys) :
    omega ≠ 0 ∧
      (omega ^ 2 - mGap ^ 2) ^ ((delta - 2) / 2) * omega * (ampBound * Real.exp (-muIr * omega)) ≤
        ampBound * omega ^ (delta - 1) * Real.exp (-muIr * omega) ∧
      toupinTreeGlueballMass nColor kLevel 220 < 1610 ∧
      toupinTreeGlueballMass nColor (toupinEffectiveRunningLevel nColor lambdaQCD mPhys) lambdaQCD = mPhys ∧
      (2 * lambdaQCD < mPhys → toupinEffectiveRunningLevel nColor lambdaQCD mPhys < 0) := by
  have homega_pos : 0 < omega := lt_of_lt_of_le hm homega
  have h_w2_diff : 0 ≤ omega ^ 2 - mGap ^ 2 := by nlinarith
  have h_w2_le : omega ^ 2 - mGap ^ 2 ≤ omega ^ 2 := by nlinarith [sq_pos_of_pos hm]
  have h_pow_nn : 0 ≤ (delta - 2) / 2 := by linarith
  have h_rpow_le : (omega ^ 2 - mGap ^ 2) ^ ((delta - 2) / 2) ≤ (omega ^ 2) ^ ((delta - 2) / 2) :=
    Real.rpow_le_rpow h_w2_diff h_w2_le h_pow_nn
  have h_w2_rpow : (omega ^ 2) ^ ((delta - 2) / 2) = omega ^ (delta - 2) := by
    rw [show (omega ^ 2 : ℝ) = omega ^ (2 : ℝ) by norm_cast]
    rw [← Real.rpow_mul homega_pos.le]
    congr 1; ring
  rw [h_w2_rpow] at h_rpow_le
  have h_mul_omega : (omega ^ 2 - mGap ^ 2) ^ ((delta - 2) / 2) * omega ≤ omega ^ (delta - 1) := by
    calc
      (omega ^ 2 - mGap ^ 2) ^ ((delta - 2) / 2) * omega ≤ omega ^ (delta - 2) * omega :=
        mul_le_mul_of_nonneg_right h_rpow_le homega_pos.le
      _ = omega ^ (delta - 2) * omega ^ (1 : ℝ) := by rw [Real.rpow_one]
      _ = omega ^ (delta - 2 + 1) := (Real.rpow_add homega_pos _ _).symm
      _ = omega ^ (delta - 1) := by congr 1; ring
  have h_env_le :
      (omega ^ 2 - mGap ^ 2) ^ ((delta - 2) / 2) * omega * (ampBound * Real.exp (-muIr * omega)) ≤
        ampBound * omega ^ (delta - 1) * Real.exp (-muIr * omega) := by
    have h_ae : 0 ≤ ampBound * Real.exp (-muIr * omega) := mul_nonneg hA (Real.exp_pos _).le
    calc
      (omega ^ 2 - mGap ^ 2) ^ ((delta - 2) / 2) * omega * (ampBound * Real.exp (-muIr * omega))
        ≤ omega ^ (delta - 1) * (ampBound * Real.exp (-muIr * omega)) :=
          mul_le_mul_of_nonneg_right h_mul_omega h_ae
      _ = ampBound * omega ^ (delta - 1) * Real.exp (-muIr * omega) := by ring
  have h_gko_lt : toupinTreeGlueballMass nColor kLevel 220 < 1610 := by
    unfold toupinTreeGlueballMass
    have h_kN : 0 < kLevel + nColor := by linarith
    have h_frac : 2 * nColor / (kLevel + nColor) ≤ 2 := by
      rw [div_le_iff₀ h_kN]; linarith
    nlinarith
  have h_keff_eq :
      toupinTreeGlueballMass nColor (toupinEffectiveRunningLevel nColor lambdaQCD mPhys) lambdaQCD = mPhys := by
    unfold toupinTreeGlueballMass toupinEffectiveRunningLevel
    have h_m_ne : mPhys ≠ 0 := ne_of_gt hmp
    have h_N_ne : nColor ≠ 0 := ne_of_gt hN
    have h_den : nColor * (2 * lambdaQCD / mPhys - 1) + nColor = 2 * nColor * lambdaQCD / mPhys := by
      field_simp [h_m_ne]
      ring
    rw [h_den]
    have h_lam_ne : lambdaQCD ≠ 0 := ne_of_gt hL
    field_simp [h_N_ne, h_lam_ne, h_m_ne]
  have h_keff_neg : 2 * lambdaQCD < mPhys → toupinEffectiveRunningLevel nColor lambdaQCD mPhys < 0 := by
    intro h_gt
    unfold toupinEffectiveRunningLevel
    have h_div_lt : 2 * lambdaQCD / mPhys < 1 := (div_lt_one hmp).mpr h_gt
    nlinarith
  exact ⟨ne_of_gt homega_pos, h_env_le, h_gko_lt, h_keff_eq, h_keff_neg⟩

/-- CP-even Yukawa modifier $\kappa_f = \sqrt{\mu_{\mathrm{sig}}} \cos\alpha_{\mathrm{CP}}$. -/
def higgsCpKappa (muSig alphaCP : ℝ) : ℝ :=
  Real.sqrt muSig * Real.cos alphaCP

/-- CP-odd Yukawa modifier $\tilde{\kappa}_f = \sqrt{\mu_{\mathrm{sig}}} \sin\alpha_{\mathrm{CP}}$. -/
def higgsCpKappaTilde (muSig alphaCP : ℝ) : ℝ :=
  Real.sqrt muSig * Real.sin alphaCP

/-- **Gate 3 (ATLAS/CMS Higgs CP-Mixing EFT & Exclusion-Envelope Theorem)**:
1. `κ_f^2 + κ̃_f^2 = μ_sig` and `2 κ_f κ̃_f = μ_sig sin(2 α_CP)`.
2. Under experimental upper bounds `0 ≤ μ_sig ≤ μ_max` and `|α_CP| ≤ α_max ≤ π/2`,
   the CP-odd modifier satisfies `|κ̃_f| ≤ √μ_max sin(α_max)`. -/
@[blueprint "thm:signals-ym-higgs-cp-eft-envelope"
  (title := "Higgs CP-mixing EFT decomposition and ATLAS/CMS exclusion envelope")
  (statement := /-- Proves $\kappa_f^2 + \tilde{\kappa}_f^2 = \mu_{\mathrm{sig}}$,
    $2\kappa_f\tilde{\kappa}_f = \mu_{\mathrm{sig}}\sin(2\alpha_{\mathrm{CP}})$, and
    $\lvert\tilde{\kappa}_f\rvert \le \sqrt{\mu_{\max}}\sin\alpha_{\max}$ under $\lvert\alpha_{\mathrm{CP}}\rvert \le \alpha_{\max} \le \pi/2$. -/)]
theorem higgsCpEftExclusion_envelope
    (muSig muMax alphaCP alphaMax : ℝ)
    (h_mu : 0 ≤ muSig) (h_mu_le : muSig ≤ muMax)
    (h_alpha : |alphaCP| ≤ alphaMax) (h_alpha_le : alphaMax ≤ Real.pi / 2) :
    higgsCpKappa muSig alphaCP ^ 2 + higgsCpKappaTilde muSig alphaCP ^ 2 = muSig ∧
      2 * higgsCpKappa muSig alphaCP * higgsCpKappaTilde muSig alphaCP =
        muSig * Real.sin (2 * alphaCP) ∧
      |higgsCpKappaTilde muSig alphaCP| ≤ Real.sqrt muMax * Real.sin alphaMax := by
  have h_mu_max_nn : 0 ≤ muMax := le_trans h_mu h_mu_le
  have h_alpha_max_nn : 0 ≤ alphaMax := le_trans (abs_nonneg alphaCP) h_alpha
  have h_sum_sq :
      higgsCpKappa muSig alphaCP ^ 2 + higgsCpKappaTilde muSig alphaCP ^ 2 = muSig := by
    unfold higgsCpKappa higgsCpKappaTilde
    have h_sq_sqrt : Real.sqrt muSig ^ 2 = muSig := Real.sq_sqrt h_mu
    calc
      (Real.sqrt muSig * Real.cos alphaCP) ^ 2 + (Real.sqrt muSig * Real.sin alphaCP) ^ 2
        = Real.sqrt muSig ^ 2 * (Real.cos alphaCP ^ 2 + Real.sin alphaCP ^ 2) := by ring
      _ = muSig * 1 := by rw [h_sq_sqrt, Real.cos_sq_add_sin_sq]
      _ = muSig := mul_one muSig
  have h_cross :
      2 * higgsCpKappa muSig alphaCP * higgsCpKappaTilde muSig alphaCP =
        muSig * Real.sin (2 * alphaCP) := by
    unfold higgsCpKappa higgsCpKappaTilde
    have h_sq_sqrt : Real.sqrt muSig ^ 2 = muSig := Real.sq_sqrt h_mu
    rw [Real.sin_two_mul]
    calc
      2 * (Real.sqrt muSig * Real.cos alphaCP) * (Real.sqrt muSig * Real.sin alphaCP)
        = Real.sqrt muSig ^ 2 * (2 * Real.sin alphaCP * Real.cos alphaCP) := by ring
      _ = muSig * (2 * Real.sin alphaCP * Real.cos alphaCP) := by rw [h_sq_sqrt]
  have h_abs_sin : |Real.sin alphaCP| ≤ Real.sin alphaMax := by
    have h_eq : |Real.sin alphaCP| = Real.sin |alphaCP| := by
      rcases le_total 0 alphaCP with h_pos | h_neg
      · have h_abs_eq : |alphaCP| = alphaCP := abs_of_nonneg h_pos
        rw [h_abs_eq]
        exact abs_of_nonneg (Real.sin_nonneg_of_nonneg_of_le_pi h_pos (by linarith))
      · have h_abs_eq : |alphaCP| = -alphaCP := abs_of_nonpos h_neg
        rw [h_abs_eq]
        have h_nonneg_neg : 0 ≤ -alphaCP := by linarith
        have h_sin_nn : 0 ≤ Real.sin (-alphaCP) :=
          Real.sin_nonneg_of_nonneg_of_le_pi h_nonneg_neg (by linarith)
        have h_sin_np : Real.sin alphaCP ≤ 0 := by linarith [Real.sin_neg alphaCP]
        rw [abs_of_nonpos h_sin_np, ← Real.sin_neg]
    rw [h_eq]
    have h_diff : Real.sin alphaMax - Real.sin |alphaCP| =
        2 * Real.sin ((alphaMax - |alphaCP|) / 2) * Real.cos ((alphaMax + |alphaCP|) / 2) := by
      simpa using Real.sin_sub_sin alphaMax |alphaCP|
    have h_sin_half : 0 ≤ Real.sin ((alphaMax - |alphaCP|) / 2) :=
      Real.sin_nonneg_of_nonneg_of_le_pi (by linarith) (by linarith [abs_nonneg alphaCP, Real.pi_pos])
    have h_cos_half : 0 ≤ Real.cos ((alphaMax + |alphaCP|) / 2) := by
      rw [← Real.sin_pi_div_two_sub]
      exact Real.sin_nonneg_of_nonneg_of_le_pi (by linarith) (by linarith [abs_nonneg alphaCP, Real.pi_pos])
    have h_prod : 0 ≤ Real.sin alphaMax - Real.sin |alphaCP| := by
      rw [h_diff]
      positivity
    linarith
  have h_env : |higgsCpKappaTilde muSig alphaCP| ≤ Real.sqrt muMax * Real.sin alphaMax := by
    unfold higgsCpKappaTilde
    rw [abs_mul, abs_of_nonneg (Real.sqrt_nonneg muSig)]
    exact mul_le_mul (Real.sqrt_le_sqrt h_mu_le) h_abs_sin (abs_nonneg _) (Real.sqrt_nonneg muMax)
  exact ⟨h_sum_sq, h_cross, h_env⟩

/-- Finite-temperature 1-loop electroweak effective Higgs potential
$V_{\mathrm{eff}}(\phi, T) = D(T^2 - T_0^2)\phi^2 - E T \phi^3 + \frac{\lambda_T}{4}\phi^4$. -/
def electroweakEffPotential (dCoeff eCoeff lamT t0 temp phi : ℝ) : ℝ :=
  dCoeff * (temp ^ 2 - t0 ^ 2) * phi ^ 2 - eCoeff * temp * phi ^ 3 + (lamT / 4) * phi ^ 4

/-- Critical-temperature broken-minimum order parameter $\phi_c = 2 E T_c / \lambda_T$. -/
def electroweakCriticalVev (eCoeff lamT tc : ℝ) : ℝ :=
  (2 * eCoeff * tc) / lamT

/-- **Gate 4 (First-Order Electroweak Phase Transition & Sphaleron Washout Bound)**:
At the critical temperature `T_c > 0` with `E > 0, λ_T > 0`:
1. The broken minimum $\phi_c = 2 E T_c / \lambda_T$ is degenerate with the symmetric vacuum
   `V_eff(φ_c, T_c) = 0` iff `D (T_c^2 - T_0^2) = E^2 T_c^2 / λ_T`.
2. The dimensionless sphaleron-washout ratio equals $\phi_c / T_c = 2 E / \lambda_T$.
3. Strong first-order transition criterion `φ_c / T_c ≥ 1` holds iff `λ_T ≤ 2 E` (which fails
   in the pure SM at $m_H = 125.25\text{ GeV}$ where $\lambda_T \approx 0.129 > 2 E_{\mathrm{SM}} \approx 0.0192$). -/
@[blueprint "thm:signals-ym-ewpt-sphaleron-washout"
  (title := "First-order electroweak phase transition degeneracy and sphaleron washout bound")
  (statement := /-- Proves degeneracy $V_{\mathrm{eff}}(\phi_c, T_c) = 0 \iff D(T_c^2-T_0^2) = E^2 T_c^2/\lambda_T$,
    exact order-parameter ratio $\phi_c/T_c = 2E/\lambda_T$, and strong first-order washout avoidance
    $\phi_c/T_c \ge 1 \iff \lambda_T \le 2E$. -/)]
theorem electroweak_first_order_washout_criterion
    (dCoeff eCoeff lamT t0 tc : ℝ)
    (he : 0 < eCoeff) (hlam : 0 < lamT) (htc : 0 < tc) :
    let phic := electroweakCriticalVev eCoeff lamT tc
    (electroweakEffPotential dCoeff eCoeff lamT t0 tc phic = 0 ↔
        dCoeff * (tc ^ 2 - t0 ^ 2) = eCoeff ^ 2 * tc ^ 2 / lamT) ∧
      phic / tc = 2 * eCoeff / lamT ∧
      (1 ≤ phic / tc ↔ lamT ≤ 2 * eCoeff) := by
  intro phic
  have h_lam_ne : lamT ≠ 0 := ne_of_gt hlam
  have h_tc_ne : tc ≠ 0 := ne_of_gt htc
  have h_phic_pos : 0 < phic := by
    dsimp [phic, electroweakCriticalVev]
    positivity
  have h_phic_sq_ne : phic ^ 2 ≠ 0 := pow_ne_zero 2 (ne_of_gt h_phic_pos)
  have h_pot_eq :
      electroweakEffPotential dCoeff eCoeff lamT t0 tc phic =
        phic ^ 2 * (dCoeff * (tc ^ 2 - t0 ^ 2) - eCoeff ^ 2 * tc ^ 2 / lamT) := by
    unfold electroweakEffPotential
    dsimp [phic, electroweakCriticalVev]
    field_simp [h_lam_ne]
    ring
  have h_deg :
      electroweakEffPotential dCoeff eCoeff lamT t0 tc phic = 0 ↔
        dCoeff * (tc ^ 2 - t0 ^ 2) = eCoeff ^ 2 * tc ^ 2 / lamT := by
    rw [h_pot_eq, mul_eq_zero]
    constructor
    · intro h
      rcases h with h0 | h1
      · exact absurd h0 h_phic_sq_ne
      · exact sub_eq_zero.mp h1
    · intro h
      right
      exact sub_eq_zero.mpr h
  have h_ratio : phic / tc = 2 * eCoeff / lamT := by
    dsimp [phic, electroweakCriticalVev]
    field_simp [h_tc_ne, h_lam_ne]
  have h_wash : 1 ≤ phic / tc ↔ lamT ≤ 2 * eCoeff := by
    rw [h_ratio, one_le_div hlam]
  exact ⟨h_deg, h_ratio, h_wash⟩

end

end Signals.YangMillsHiggsCPT
