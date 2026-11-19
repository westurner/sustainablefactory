import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Signals.GrassmannianEBR

namespace Signals.RiemannSpectral

noncomputable section

/-!
# Finite Spectral & Algebraic Contracts Related to Riemann Hypothesis Approaches

This module formalizes **only finite, independently checkable algebraic and spectral
identities** extracted and audited from
`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`
(lines 2345–3600 and 4788–5728):

1. **Critical-Line Reflection & Symmetry-Breaking Bifurcation**: even transverse
   quartic bifurcation when stiffness turns negative (`κ < 0, u > 0`).
2. **Finite-Graph Bass–Ihara Zeta & Ramanujan Dichotomy**: both the Ramanujan
   critical-circle lock (`λ² ≤ 4q → |u|² = 1/q`) and the **non-Ramanujan splitting
   converse** (`λ² > 4q →` real roots `u₊ ≠ u₋` with `u₊ u₋ = 1/q` split strictly off
   `|u|² = 1/q`).
3. **Semi-Dirac Transverse Confinement, Slavnov/GUE Quadratic Level Repulsion, and
   Sato Wronskian Hirota Plücker Identity**.
4. **Jensen–Pólya / Transverse QFIM Equivalence, Laguerre–Pólya Product Closure,
   Three-Channel Madelung–Bohm Split, Lehmer Bifurcation Witness, and de Bruijn–Newman
   Two-Zero Repulsion Rate**.
5. **Li's Unit-Circle Criterion**: `|1 - 1/ρ|² = 1 ↔ Re(ρ) = 1/2` (strictly separating
   critical-line zeros from off-line zeros) and non-negativity of critical-line pair terms.

**Epistemic boundary**: None of these finite theorems proves or disproves the Riemann
Hypothesis for `ζ(s)`. The four open infinite-dimensional analytical bridges are isolated
in `Signals.Pending.RiemannHypothesisPendingBoundary`.
-/

/-! ### 1. Critical-Line Reflection & Coulson–Fischer Quartic Bifurcation -/

/-- When transverse stiffness turns negative (`κ < 0`) with stabilizing quartic coupling
(`u > 0`), the symmetry-broken off-line locus `σ_*² = -κ / u` strictly lowers the even
transverse energy below the critical line `σ = 0`. -/
theorem negative_transverse_stiffness_bifurcates_off_line
    (e0 kappa uQuartic sigmaStar : ℝ)
    (h_kappa_neg : kappa < 0)
    (h_u_pos : 0 < uQuartic)
    (h_bifurc : sigmaStar ^ 2 = -kappa / uQuartic) :
    Signals.GrassmannianEBR.criticalStripEvenEnergy e0 kappa uQuartic sigmaStar <
      Signals.GrassmannianEBR.criticalStripEvenEnergy e0 kappa uQuartic 0 := by
  unfold Signals.GrassmannianEBR.criticalStripEvenEnergy
  have h_u_ne : uQuartic ≠ 0 := ne_of_gt h_u_pos
  have h_pow4 : sigmaStar ^ 4 = (sigmaStar ^ 2) ^ 2 := by ring
  rw [h_pow4, h_bifurc]
  have h_drop :
      e0 + kappa / 2 * (-kappa / uQuartic) + uQuartic / 4 * (-kappa / uQuartic) ^ 2 =
        e0 - kappa ^ 2 / (4 * uQuartic) := by
    field_simp [h_u_ne]
    ring
  rw [h_drop]
  have h_k2 : 0 < kappa ^ 2 := sq_pos_of_ne_zero (ne_of_lt h_kappa_neg)
  have h_gap : 0 < kappa ^ 2 / (4 * uQuartic) := by positivity
  linarith

/-! ### 2. Finite-Graph Bass–Ihara Zeta: Non-Ramanujan Off-Circle Splitting Converse -/

/-- Two real roots `u± = (λ ± √(λ² - 4q)) / (2q)` of `q u² - λ u + 1 = 0` when
a finite `(q + 1)`-regular graph violates the Ramanujan bound (`λ² > 4q`). -/
def iharaRealRootPlus (q lam discSqrt : ℝ) : ℝ := (lam + discSqrt) / (2 * q)
def iharaRealRootMinus (q lam discSqrt : ℝ) : ℝ := (lam - discSqrt) / (2 * q)

/-- **Non-Ramanujan Off-Circle Splitting Theorem (Converse of Graph RH)**:
When an adjacency eigenvalue violates the Ramanujan bound (`discSqrt > 0` with
`discSqrt² = λ² - 4q` and `q > 0`), both real roots satisfy `q u² - λ u + 1 = 0`,
their product is `u₊ u₋ = 1 / q`, and they split strictly off the critical circle
`|u|² = 1 / q` (`u₊² ≠ 1 / q` and `u₋² ≠ 1 / q`). -/
theorem ihara_non_ramanujan_splits_off_critical_circle
    (q lam discSqrt : ℝ)
    (hq : 0 < q)
    (h_disc_pos : 0 < discSqrt)
    (h_disc_sq : discSqrt ^ 2 = lam ^ 2 - 4 * q) :
    let uP := iharaRealRootPlus q lam discSqrt
    let uM := iharaRealRootMinus q lam discSqrt
    q * uP ^ 2 - lam * uP + 1 = 0 ∧
      q * uM ^ 2 - lam * uM + 1 = 0 ∧
      uP * uM = 1 / q ∧
      uP ≠ uM ∧
      uP ^ 2 ≠ 1 / q ∧
      uM ^ 2 ≠ 1 / q := by
  dsimp only
  unfold iharaRealRootPlus iharaRealRootMinus
  have hq_ne : q ≠ 0 := ne_of_gt hq
  have h_lam_ne : lam ≠ 0 := by
    intro h0
    rw [h0] at h_disc_sq
    nlinarith [sq_nonneg discSqrt]
  have h_root_p : q * ((lam + discSqrt) / (2 * q)) ^ 2 - lam * ((lam + discSqrt) / (2 * q)) + 1 = 0 := by
    field_simp [hq_ne]
    nlinarith [h_disc_sq]
  have h_root_m : q * ((lam - discSqrt) / (2 * q)) ^ 2 - lam * ((lam - discSqrt) / (2 * q)) + 1 = 0 := by
    field_simp [hq_ne]
    nlinarith [h_disc_sq]
  have h_prod : ((lam + discSqrt) / (2 * q)) * ((lam - discSqrt) / (2 * q)) = 1 / q := by
    field_simp [hq_ne]
    nlinarith [h_disc_sq]
  have h_ne : (lam + discSqrt) / (2 * q) ≠ (lam - discSqrt) / (2 * q) := by
    intro heq
    have h1 : lam + discSqrt = lam - discSqrt := by
      have := congrArg (fun x => x * (2 * q)) heq
      field_simp [hq_ne] at this
      linarith
    linarith
  have h_up_ne : ((lam + discSqrt) / (2 * q)) ^ 2 ≠ 1 / q := by
    intro heq
    have h1 : (lam + discSqrt) ^ 2 = 4 * q := by
      have := congrArg (fun x => x * (4 * q ^ 2)) heq
      field_simp [hq_ne] at this
      linarith
    have h2 : lam * discSqrt + discSqrt ^ 2 = 0 := by nlinarith [h1, h_disc_sq]
    have h3 : (lam + discSqrt) * discSqrt = 0 := by linarith
    have h_sum_zero : lam + discSqrt = 0 :=
      (mul_eq_zero.mp h3).resolve_right (ne_of_gt h_disc_pos)
    rw [h_sum_zero] at h1
    linarith
  have h_um_ne : ((lam - discSqrt) / (2 * q)) ^ 2 ≠ 1 / q := by
    intro heq
    have h1 : (lam - discSqrt) ^ 2 = 4 * q := by
      have := congrArg (fun x => x * (4 * q ^ 2)) heq
      field_simp [hq_ne] at this
      linarith
    have h2 : -lam * discSqrt + discSqrt ^ 2 = 0 := by nlinarith [h1, h_disc_sq]
    have h3 : (discSqrt - lam) * discSqrt = 0 := by linarith
    have h_diff_zero : discSqrt - lam = 0 :=
      (mul_eq_zero.mp h3).resolve_right (ne_of_gt h_disc_pos)
    have h_eq : lam - discSqrt = 0 := by linarith
    rw [h_eq] at h1
    linarith
  exact ⟨h_root_p, h_root_m, h_prod, h_ne, h_up_ne, h_um_ne⟩

/-! ### 3. Semi-Dirac Confinement, Slavnov/GUE Level Repulsion & Sato Hirota Identity -/

/-- Anisotropic Semi-Dirac critical-strip model energy (massless along `γ`, quadratic along `σ`). -/
def semiDiracCriticalStripEnergy
    (vF gamma gammaN invTwoMPerp conifoldThroat sigmaDev : ℝ) : ℝ :=
  (vF * (gamma - gammaN)) ^ 2 +
    (invTwoMPerp * sigmaDev ^ 2 + conifoldThroat) ^ 2 - conifoldThroat ^ 2

/-- Transverse QFIM Hessian `∂²E / ∂σ² |_{σ=0} = 4 · (1 / 2m_⊥) · Δ_throat`. -/
def semiDiracTransverseQfimHessian (invTwoMPerp conifoldThroat : ℝ) : ℝ :=
  4 * invTwoMPerp * conifoldThroat

/-- Under positive supplied transverse inverse mass and conifold throat, the Semi-Dirac
model has positive transverse Hessian and strictly higher energy off `σ = 0`. -/
theorem semi_dirac_transverse_hessian_pos
    (vF gamma gammaN invTwoMPerp conifoldThroat sigmaDev : ℝ)
    (h_mass : 0 < invTwoMPerp) (h_throat : 0 < conifoldThroat) (h_off : sigmaDev ≠ 0) :
    0 < semiDiracTransverseQfimHessian invTwoMPerp conifoldThroat ∧
      semiDiracCriticalStripEnergy vF gamma gammaN invTwoMPerp conifoldThroat 0 <
        semiDiracCriticalStripEnergy vF gamma gammaN invTwoMPerp conifoldThroat sigmaDev := by
  unfold semiDiracTransverseQfimHessian semiDiracCriticalStripEnergy
  refine ⟨by positivity, ?_⟩
  have h_sq : 0 < sigmaDev ^ 2 := sq_pos_of_ne_zero h_off
  have h_m : 0 < invTwoMPerp * sigmaDev ^ 2 := mul_pos h_mass h_sq
  have h_c : 0 < 2 * conifoldThroat * (invTwoMPerp * sigmaDev ^ 2) := by positivity
  have h_q : 0 < (invTwoMPerp * sigmaDev ^ 2) ^ 2 := sq_pos_of_pos h_m
  linarith

/-- `2 × 2` symmetric sine-kernel / Slavnov correlation determinant `1 - (1 - c δ² / 2)²`. -/
def gueSineKernel2x2Det (c deltaU : ℝ) : ℝ :=
  let k12 := 1 - (c / 2) * deltaU ^ 2
  1 - k12 * k12

/-- **GUE Quadratic Level Repulsion**: `det K_{2×2}(δ) = c δ² - (c² / 4) δ⁴`, vanishing at `δ = 0`. -/
theorem slavnov_gue_2x2_quadratic_level_repulsion (c deltaU : ℝ) :
    gueSineKernel2x2Det c 0 = 0 ∧
      gueSineKernel2x2Det c deltaU = c * deltaU ^ 2 - (c ^ 2 / 4) * deltaU ^ 4 := by
  unfold gueSineKernel2x2Det
  constructor <;> ring

/-- Wronskian Plücker minor `τ_{ij} = f_i f'_j - f_j f'_i` on the Sato Grassmannian. -/
def wronskianMinor (fi fj dfi dfj : ℝ) : ℝ :=
  fi * dfj - fj * dfi

/-- **Sato Grassmannian Hirota Bilinear Plücker Identity**:
`τ_{12} τ_{34} - τ_{13} τ_{24} + τ_{14} τ_{23} = 0` holds identically for all Wronskian minors. -/
theorem sato_hirota_bilinear_plucker_identity
    (f1 f2 f3 f4 df1 df2 df3 df4 : ℝ) :
    wronskianMinor f1 f2 df1 df2 * wronskianMinor f3 f4 df3 df4 -
      wronskianMinor f1 f3 df1 df3 * wronskianMinor f2 f4 df2 df4 +
      wronskianMinor f1 f4 df1 df4 * wronskianMinor f2 f3 df2 df3 = 0 := by
  unfold wronskianMinor
  ring

/-! ### 4. Jensen–Pólya Multiplicative Closure, Madelung–Bohm Split, Lehmer Witness & dBN Flow -/

/-- Osmotic Fisher channel on the critical line: `J_osmotic(γ) = (Z'(γ))²`. -/
def jensenPolyaOsmoticChannel (z1 : ℝ) : ℝ := z1 ^ 2

/-- Bohm quantum-curvature channel on the critical line: `J_bohm(γ) = -Z(γ) Z''(γ)`. -/
def jensenPolyaBohmChannel (z0 z2 : ℝ) : ℝ := -z0 * z2

/-- Exact decomposition `J(γ) = J_osmotic(γ) + J_bohm(γ)` and extremum rescue:
at `Z'(γ_*) = 0` with opposite-sign curvature `Z(γ_*) Z''(γ_*) < 0`, 100% of the
transverse restoring stiffness is supplied by `J_bohm > 0`. -/
theorem jensen_polya_madelung_bohm_split_and_extremum_rescue (z0 z1 z2 : ℝ) :
    Signals.GrassmannianEBR.jensenPolyaDiscriminant z0 z1 z2 =
      jensenPolyaOsmoticChannel z1 + jensenPolyaBohmChannel z0 z2 ∧
    (z0 * z2 < 0 → 0 < Signals.GrassmannianEBR.jensenPolyaDiscriminant z0 0 z2 ∧
      Signals.GrassmannianEBR.jensenPolyaDiscriminant z0 0 z2 = jensenPolyaBohmChannel z0 z2) := by
  unfold Signals.GrassmannianEBR.jensenPolyaDiscriminant jensenPolyaOsmoticChannel
    jensenPolyaBohmChannel
  constructor
  · ring
  · intro h_opp
    constructor <;> linarith

/-- **Laguerre–Pólya Multiplicative Closure Identity**:
For any two twice-differentiable real factors `f, g` with `(fg)' = f'g + fg'` and
`(fg)'' = f''g + 2 f'g' + f g''`, the Jensen–Pólya discriminant obeys the exact
nonnegative-weight product rule `J(fg) = g² J(f) + f² J(g)`.
Consequently, any finite product of real-rooted factors (each having `J ≥ 0`) satisfies
`J ≥ 0` everywhere on the real axis. -/
theorem jensenPolyaDiscriminant_mul_product_rule
    (f0 f1 f2 g0 g1 g2 : ℝ) :
    Signals.GrassmannianEBR.jensenPolyaDiscriminant
      (f0 * g0) (f1 * g0 + f0 * g1) (f2 * g0 + 2 * f1 * g1 + f0 * g2) =
        g0 ^ 2 * Signals.GrassmannianEBR.jensenPolyaDiscriminant f0 f1 f2 +
          f0 ^ 2 * Signals.GrassmannianEBR.jensenPolyaDiscriminant g0 g1 g2 := by
  unfold Signals.GrassmannianEBR.jensenPolyaDiscriminant
  ring

/-- **Lehmer-Pair Bifurcation / Disproof Criterion**:
If `Z'(γ_*) = 0` and `Z(γ_*) Z''(γ_*) > 0` (peak/trough fails to cross zero), then
`J(γ_*) < 0` and the quadratic-truncated critical-strip energy vanishes off-axis at
`σ_*² = 2 z0 / z2 > 0`. -/
theorem lehmer_pair_failure_destabilizes_and_splits
    (z0 z2 sigmaStar : ℝ)
    (h_same_sign : 0 < z0 * z2)
    (h_z2_ne : z2 ≠ 0)
    (h_split : sigmaStar ^ 2 = (2 * z0) / z2) :
    Signals.GrassmannianEBR.jensenPolyaDiscriminant z0 0 z2 < 0 ∧
      Signals.GrassmannianEBR.criticalStripPolynomialEnergy z0 0 z2 sigmaStar = 0 := by
  unfold Signals.GrassmannianEBR.jensenPolyaDiscriminant
    Signals.GrassmannianEBR.criticalStripPolynomialEnergy
  constructor
  · linarith
  · have h_cancel : z0 - (1 / 2) * z2 * sigmaStar ^ 2 = 0 := by
      rw [h_split]
      field_simp [h_z2_ne]
      ring
    rw [h_cancel]
    ring

/-- De Bruijn–Newman / Calogero–Moser 2-zero separation velocity `d(z₂ - z₁)/dt = 4 / (z₂ - z₁)`
under forward heat flow (`t > 0`): for `z₁ < z₂`, the zeros repel symmetrically with
`dz₁/dt = -2 / (z₂ - z₁) < 0` and `dz₂/dt = +2 / (z₂ - z₁) > 0`, widening the gap at rate
`4 / (z₂ - z₁) > 0`. -/
def dbnTwoZeroForwardSeparationRate (z1 z2 : ℝ) : ℝ :=
  (2 / (z2 - z1)) - (-2 / (z2 - z1))

theorem dbnTwoZeroForwardSeparationRate_pos (z1 z2 : ℝ) (h : z1 < z2) :
    dbnTwoZeroForwardSeparationRate z1 z2 = 4 / (z2 - z1) ∧
      0 < dbnTwoZeroForwardSeparationRate z1 z2 := by
  unfold dbnTwoZeroForwardSeparationRate
  have h_gap : 0 < z2 - z1 := sub_pos.mpr h
  have h_eq : 2 / (z2 - z1) - -2 / (z2 - z1) = 4 / (z2 - z1) := by ring
  exact ⟨h_eq, by rw [h_eq]; positivity⟩

/-! ### 5. Li's Positivity Criterion: Unit-Circle Characterization of Critical-Line Zeros -/

/-- Squared modulus `|1 - 1 / ρ|² = ((Re ρ - 1)² + (Im ρ)²) / ((Re ρ)² + (Im ρ)²)`
for `ρ = (1/2 + σ_dev) + i γ`. -/
def liTransformModulusSq (sigmaDev gamma : ℝ) : ℝ :=
  ((sigmaDev - 1 / 2) ^ 2 + gamma ^ 2) / ((sigmaDev + 1 / 2) ^ 2 + gamma ^ 2)

/-- **Li Unit-Circle Characterization Theorem**:
For any `ρ = (1/2 + σ_dev) + i γ ≠ 0`, `|1 - 1/ρ|² = 1 ↔ σ_dev = 0` (i.e., `Re(ρ) = 1/2`).
Off-line zeros (`σ_dev ≠ 0`) have `|1 - 1/ρ| ≠ 1`, so one member of each functional-equation
pair `{ρ, 1 - ρ}` lies strictly outside the unit circle (`|1 - 1/ρ| > 1`), driving oscillatory
growth that makes Li's coefficients `λ_n` negative for sufficiently large `n`. -/
theorem liTransformModulusSq_eq_one_iff_critical_line
    (sigmaDev gamma : ℝ)
    (h_rho_ne_zero : 0 < (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2) :
    liTransformModulusSq sigmaDev gamma = 1 ↔ sigmaDev = 0 := by
  unfold liTransformModulusSq
  have h_den_ne : (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2 ≠ 0 := ne_of_gt h_rho_ne_zero
  rw [div_eq_one_iff_eq h_den_ne]
  constructor
  · intro h
    linarith
  · intro h
    rw [h]
    ring

/-- First Li coefficient contribution `Re(1 - (1 - 1/ρ)) + Re(1 - (1 - 1/ρ̄)) = 1 / (1/4 + γ²)`
for a conjugate pair of critical-line zeros `1/2 ± i γ` is strictly positive. -/
def liFirstPairContributionCriticalLine (gamma : ℝ) : ℝ :=
  1 / ((1 / 4 : ℝ) + gamma ^ 2)

theorem liFirstPairContributionCriticalLine_pos (gamma : ℝ) :
    0 < liFirstPairContributionCriticalLine gamma := by
  unfold liFirstPairContributionCriticalLine
  positivity

/-- For any critical-line zero mapped to the unit circle `1 - 1/ρ = e^{i θ}`, the conjugate-pair
contribution to the `n`-th Li coefficient `2 (1 - cos(n θ))` is always non-negative (`≥ 0`). -/
theorem liCriticalLinePairTerm_nonneg (cosNTheta : ℝ) (h_le : cosNTheta ≤ 1) :
    0 ≤ 2 * (1 - cosNTheta) := by
  linarith

/-- **Off-Line Li Unit-Circle Splitting Theorem**:
For any off-line zero `ρ = (1/2 + σ_dev) + i γ` with `σ_dev > 0`, `|1 - 1/ρ|² < 1`,
while its functional-equation partner `1 - ρ̄ = (1/2 - σ_dev) + i γ` satisfies
`|1 - 1/(1 - ρ̄)|² > 1`, placing one member of every off-line pair strictly outside the
unit circle. -/
theorem liTransformModulusSq_off_line_splits
    (sigmaDev gamma : ℝ) (h_pos : 0 < sigmaDev)
    (h_den_p : 0 < (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2)
    (h_den_m : 0 < (-sigmaDev + 1 / 2) ^ 2 + gamma ^ 2) :
    liTransformModulusSq sigmaDev gamma < 1 ∧
      1 < liTransformModulusSq (-sigmaDev) gamma := by
  unfold liTransformModulusSq
  constructor
  · rw [div_lt_one h_den_p]
    nlinarith
  · rw [one_lt_div h_den_m]
    nlinarith

/-- **De Bruijn–Newman / Calogero–Moser 3-Zero Velocity Conservation**:
Under `dz_k / dt = ∑_{j ≠ k} 2 / (z_j - z_k)`, the sum of velocities of any three
distinct real zeros `z₁, z₂, z₃` vanishes identically (center-of-mass invariance). -/
def dbnThreeZeroVelocitySum (z1 z2 z3 : ℝ) : ℝ :=
  (2 / (z2 - z1) + 2 / (z3 - z1)) +
    (2 / (z1 - z2) + 2 / (z3 - z2)) +
    (2 / (z1 - z3) + 2 / (z2 - z3))

theorem dbnThreeZero_center_of_mass_conserved
    (z1 z2 z3 : ℝ) (h12 : z2 - z1 ≠ 0) (h13 : z3 - z1 ≠ 0) (h23 : z3 - z2 ≠ 0) :
    dbnThreeZeroVelocitySum z1 z2 z3 = 0 := by
  unfold dbnThreeZeroVelocitySum
  have h21 : z1 - z2 ≠ 0 := by intro h; apply h12; linarith
  have h31 : z1 - z3 ≠ 0 := by intro h; apply h13; linarith
  have h32 : z2 - z3 ≠ 0 := by intro h; apply h23; linarith
  field_simp [h12, h13, h23, h21, h31, h32]
  ring

/-- `3 × 3` Vandermonde / Slavnov 3-body repulsion determinant
`det [[1, u₁, u₁²], [1, u₂, u₂²], [1, u₃, u₃²]]`. -/
def vandermondeDet3 (u1 u2 u3 : ℝ) : ℝ :=
  (u2 * u3 ^ 2 - u3 * u2 ^ 2) - (u1 * u3 ^ 2 - u3 * u1 ^ 2) + (u1 * u2 ^ 2 - u2 * u1 ^ 2)

/-- Exact 3-body Vandermonde factorization: vanishes on any pair collision and is
strictly positive for strictly ordered rapidities `u₁ < u₂ < u₃`. -/
theorem vandermondeDet3_factorization_and_pos (u1 u2 u3 : ℝ) :
    vandermondeDet3 u1 u2 u3 = (u2 - u1) * (u3 - u1) * (u3 - u2) ∧
      (u1 < u2 → u2 < u3 → 0 < vandermondeDet3 u1 u2 u3) := by
  have h_fac : vandermondeDet3 u1 u2 u3 = (u2 - u1) * (u3 - u1) * (u3 - u2) := by
    unfold vandermondeDet3
    ring
  refine ⟨h_fac, ?_⟩
  intro h12 h23
  rw [h_fac]
  have a : 0 < u2 - u1 := sub_pos.mpr h12
  have b : 0 < u3 - u1 := sub_pos.mpr (lt_trans h12 h23)
  have c : 0 < u3 - u2 := sub_pos.mpr h23
  positivity

/-! ### 6. Explicit 14-Vertex 3-Regular Connected Non-Ramanujan Graph vs. Heawood Graph -/

/-- Characteristic polynomial `p(λ) = λ³ - λ² - 6λ + 2` of the `3 × 3` antisymmetric
equitable quotient matrix `Q_anti = [[-1, 2, 0], [1, 0, 2], [0, 1, 2]]` of the
14-vertex 3-regular connected barbell graph `G₁₄` (`q = 2`, Ramanujan bound `λ² ≤ 8`). -/
def nonRamanujan14CharPoly (lam : ℝ) : ℝ :=
  lam ^ 3 - lam ^ 2 - 6 * lam + 2

/-- For any root `λ` of `nonRamanujan14CharPoly`, the explicit nonzero vector
`(a, b, c) = (2, λ + 1, (λ² + λ - 2) / 2)` is an exact eigenvector of the antisymmetric
equitable quotient matrix `Q_anti` of `G₁₄` (lifting by symmetry across the bridge `(0, 7)`
to an exact 14-component eigenvector of `A(G₁₄)` with eigenvalue `λ`). -/
theorem nonRamanujan14_equitable_eigenvector
    (lam : ℝ) (h_root : nonRamanujan14CharPoly lam = 0) :
    let a : ℝ := 2
    let b : ℝ := lam + 1
    let c : ℝ := (lam ^ 2 + lam - 2) / 2
    (-a + 2 * b = lam * a) ∧
      (a + 2 * c = lam * b) ∧
      (b + 2 * c = lam * c) := by
  dsimp only
  unfold nonRamanujan14CharPoly at h_root
  refine ⟨by ring, by ring, ?_⟩
  linarith

/-- Exact sign-change check figures for `nonRamanujan14CharPoly` on `[57/20, 143/50]`:
`p(2.85) = -587/8000 < 0` and `p(2.86) = 6757/125000 > 0`, while `2.85² = 3249/400 > 8`. -/
theorem nonRamanujan14_bracket_sign_change :
    nonRamanujan14CharPoly (57 / 20) < 0 ∧
      0 < nonRamanujan14CharPoly (143 / 50) ∧
      (8 : ℝ) < (57 / 20 : ℝ) ^ 2 := by
  unfold nonRamanujan14CharPoly
  constructor <;> [norm_num; constructor <;> norm_num]

/-- **14-Vertex 3-Regular Non-Ramanujan Off-Circle Witness**:
There exists a real eigenvalue `λ₂ ∈ (57/20, 143/50)` of the 14-vertex 3-regular connected
graph `G₁₄` (`q = 2`) strictly exceeding the Ramanujan bound (`λ₂² > 8 = 4q`), with positive
discriminant `discSqrt = √(λ₂² - 8) > 0` whose two real Bass–Ihara roots `u₊, u₋` satisfy
`2 u² - λ₂ u + 1 = 0`, `u₊ u₋ = 1/2`, and split strictly off the critical circle `|u|² = 1/2`. -/
theorem nonRamanujan14_exists_super_ramanujan_off_circle_roots :
    ∃ lam2 discSqrt : ℝ,
      (57 / 20 : ℝ) < lam2 ∧
      lam2 < (143 / 50 : ℝ) ∧
      nonRamanujan14CharPoly lam2 = 0 ∧
      (8 : ℝ) < lam2 ^ 2 ∧
      0 < discSqrt ∧
      discSqrt ^ 2 = lam2 ^ 2 - 4 * 2 ∧
      let uP := iharaRealRootPlus 2 lam2 discSqrt
      let uM := iharaRealRootMinus 2 lam2 discSqrt
      2 * uP ^ 2 - lam2 * uP + 1 = 0 ∧
        2 * uM ^ 2 - lam2 * uM + 1 = 0 ∧
        uP * uM = 1 / 2 ∧
        uP ≠ uM ∧
        uP ^ 2 ≠ 1 / 2 ∧
        uM ^ 2 ≠ 1 / 2 := by
  have hcont : Continuous nonRamanujan14CharPoly := by
    unfold nonRamanujan14CharPoly
    fun_prop
  have h_le : (57 / 20 : ℝ) ≤ 143 / 50 := by norm_num
  have h_signs := nonRamanujan14_bracket_sign_change
  have h_zero_mem :
      (0 : ℝ) ∈ Set.Icc (nonRamanujan14CharPoly (57 / 20)) (nonRamanujan14CharPoly (143 / 50)) :=
    ⟨le_of_lt h_signs.1, le_of_lt h_signs.2.1⟩
  obtain ⟨lam2, h_mem, h_root⟩ :=
    intermediate_value_Icc h_le hcont.continuousOn h_zero_mem
  have h_gt : (57 / 20 : ℝ) < lam2 := by
    rcases lt_or_eq_of_le h_mem.1 with hlt | heq
    · exact hlt
    · exfalso
      rw [← heq] at h_root
      linarith [h_signs.1]
  have h_lt : lam2 < (143 / 50 : ℝ) := by
    rcases lt_or_eq_of_le h_mem.2 with hlt | heq
    · exact hlt
    · exfalso
      rw [heq] at h_root
      linarith [h_signs.2.1]
  have h_sq_gt : (8 : ℝ) < lam2 ^ 2 := by
    nlinarith [h_gt, h_signs.2.2]
  have h_disc_pos_sq : 0 < lam2 ^ 2 - 4 * 2 := by linarith
  refine ⟨lam2, Real.sqrt (lam2 ^ 2 - 4 * 2), h_gt, h_lt, h_root, h_sq_gt,
    Real.sqrt_pos.mpr h_disc_pos_sq, Real.sq_sqrt (le_of_lt h_disc_pos_sq), ?_⟩
  exact ihara_non_ramanujan_splits_off_critical_circle 2 lam2 (Real.sqrt (lam2 ^ 2 - 4 * 2))
    (by norm_num) (Real.sqrt_pos.mpr h_disc_pos_sq) (Real.sq_sqrt (le_of_lt h_disc_pos_sq))

/-- **14-Vertex 3-Regular Heawood Graph Ramanujan Contrast**:
For the 14-vertex 3-regular Heawood graph (`q = 2`, non-trivial adjacency eigenvalues
`λ = ±√2`, so `λ² = 2 ≤ 8 = 4q`), every non-trivial Bass–Ihara root lies strictly on the
Ramanujan critical circle `|u|² = 1/2`. -/
theorem heawood_graph_ramanujan_critical_circle (lam : ℝ) (h_sq : lam ^ 2 = 2) :
    Signals.GrassmannianEBR.iharaQuadraticDiscriminant lam 2 ≤ 0 ∧
      (lam / 4) ^ 2 + (4 * 2 - lam ^ 2) / (4 * 2 ^ 2) = 1 / 2 := by
  have h_ram : lam ^ 2 ≤ 4 * 2 := by linarith
  have h_circ := Signals.GrassmannianEBR.ihara_ramanujan_critical_circle_modulus_sq lam 2
    (by norm_num) h_ram
  constructor
  · unfold Signals.GrassmannianEBR.iharaQuadraticDiscriminant
    linarith
  · simpa [show (2 : ℝ) * 2 = 4 by norm_num] using h_circ.2

end

end Signals.RiemannSpectral
