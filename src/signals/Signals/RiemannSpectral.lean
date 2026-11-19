import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Signals.GrassmannianEBR
import Signals.QuantumCausalInference

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

/-! ### 7. Griffin–Ono–Rolen–Zagier (PNAS 2019) Jensen Polynomial Hyperbolicity (Degrees 2 & 3) -/

/-- Exact discriminant `Δ₃ = 18abcd - 4b³d + b²c² - 4ac³ - 27a²d²` of a cubic polynomial
`a X³ + b X² + c X + d` (including degree-3 Jensen polynomials `J^{3,n}(X)`). -/
def jensenCubicDiscriminant (a b c d : ℝ) : ℝ :=
  18 * a * b * c * d - 4 * b ^ 3 * d + b ^ 2 * c ^ 2 - 4 * a * c ^ 3 - 27 * a ^ 2 * d ^ 2

/-- **Factored Cubic Discriminant Identity**:
For any cubic `a (X - r₁)(X - r₂)(X - r₃)`, the discriminant equals
`a⁴ (r₁ - r₂)² (r₁ - r₃)² (r₂ - r₃)²`, which is strictly positive whenever `a ≠ 0`
and all three roots are distinct real numbers (`r₁ < r₂ < r₃`). -/
theorem jensenCubicDiscriminant_factored_roots (a r1 r2 r3 : ℝ) :
    let b := -a * (r1 + r2 + r3)
    let c := a * (r1 * r2 + r1 * r3 + r2 * r3)
    let d := -a * r1 * r2 * r3
    jensenCubicDiscriminant a b c d =
      a ^ 4 * (r1 - r2) ^ 2 * (r1 - r3) ^ 2 * (r2 - r3) ^ 2 ∧
      (a ≠ 0 → r1 < r2 → r2 < r3 → 0 < jensenCubicDiscriminant a b c d) := by
  dsimp only
  have h_eq :
      jensenCubicDiscriminant a (-a * (r1 + r2 + r3))
        (a * (r1 * r2 + r1 * r3 + r2 * r3)) (-a * r1 * r2 * r3) =
          a ^ 4 * (r1 - r2) ^ 2 * (r1 - r3) ^ 2 * (r2 - r3) ^ 2 := by
    unfold jensenCubicDiscriminant
    ring
  refine ⟨h_eq, ?_⟩
  intro ha h12 h23
  rw [h_eq]
  have ha4 : 0 < a ^ 4 := by
    have : 0 < a ^ 2 := sq_pos_of_ne_zero ha
    have h4 : a ^ 4 = (a ^ 2) ^ 2 := by ring
    rw [h4]
    exact sq_pos_of_pos this
  have h1 : 0 < (r1 - r2) ^ 2 := sq_pos_of_ne_zero (ne_of_lt (sub_neg.mpr h12))
  have h2 : 0 < (r1 - r3) ^ 2 := sq_pos_of_ne_zero (ne_of_lt (sub_neg.mpr (lt_trans h12 h23)))
  have h3 : 0 < (r2 - r3) ^ 2 := sq_pos_of_ne_zero (ne_of_lt (sub_neg.mpr h23))
  positivity

/-- **Hermite-Normalized Degree-3 Jensen Hyperbolicity Criterion**:
For the depressed Hermite-normalized cubic `Z³ - 3 Z + c`, `Δ₃ = 27 (4 - c²)`, so
strict hyperbolicity (`Δ₃ > 0`, three distinct real roots) holds iff `c² < 4` (`|c| < 2`).
At the Griffin–Ono–Rolen–Zagier probabilists' Hermite limit `He₃(Z) = Z³ - 3Z` (`c = 0`),
`Δ₃ = 108 > 0`. -/
theorem depressedCubic_hermite3_discriminant (c : ℝ) :
    jensenCubicDiscriminant 1 0 (-3) c = 27 * (4 - c ^ 2) ∧
      (0 < jensenCubicDiscriminant 1 0 (-3) c ↔ c ^ 2 < 4) ∧
      jensenCubicDiscriminant 1 0 (-3) 0 = 108 := by
  have h_id : jensenCubicDiscriminant 1 0 (-3) c = 27 * (4 - c ^ 2) := by
    unfold jensenCubicDiscriminant
    ring
  refine ⟨h_id, ?_, ?_⟩
  · rw [h_id]
    constructor <;> intro h <;> linarith
  · unfold jensenCubicDiscriminant
    norm_num

/-! ### 8. Weil Explicit-Formula Quadratic Form Positivity & Disproof Witness Gate -/

/-- `2 × 2` symmetric Weil quadratic form `vᵀ W v = w₀₀ v₀² + 2 w₀₁ v₀ v₁ + w₁₁ v₁²`. -/
def weilQuadForm2 (w00 w01 w11 v0 v1 : ℝ) : ℝ :=
  w00 * v0 ^ 2 + 2 * w01 * v0 * v1 + w11 * v1 ^ 2

/-- **Sylvester Positivity Gate for Finite-Dimensional Weil Subspaces**:
Whenever `w₀₀ > 0` and `det W = w₀₀ w₁₁ - w₀₁² > 0`, the Weil quadratic form is strictly
positive for every nonzero test vector `(v₀, v₁) ≠ (0, 0)`. -/
theorem weilQuadForm2_pos_of_sylvester
    (w00 w01 w11 v0 v1 : ℝ)
    (h00 : 0 < w00)
    (hdet : 0 < w00 * w11 - w01 ^ 2)
    (hne : v0 ≠ 0 ∨ v1 ≠ 0) :
    0 < weilQuadForm2 w00 w01 w11 v0 v1 := by
  have h_sq_id :
      w00 * weilQuadForm2 w00 w01 w11 v0 v1 =
        (w00 * v0 + w01 * v1) ^ 2 + (w00 * w11 - w01 ^ 2) * v1 ^ 2 := by
    unfold weilQuadForm2
    ring
  have h_prod_pos : 0 < w00 * weilQuadForm2 w00 w01 w11 v0 v1 := by
    rw [h_sq_id]
    rcases eq_or_ne v1 0 with hv1 | hv1
    · subst hv1
      have hv0 : v0 ≠ 0 := hne.resolve_right (by simp)
      have h1 : 0 < (w00 * v0) ^ 2 := sq_pos_of_ne_zero (mul_ne_zero (ne_of_gt h00) hv0)
      nlinarith
    · have hv1sq : 0 < v1 ^ 2 := sq_pos_of_ne_zero hv1
      have h2 : 0 < (w00 * w11 - w01 ^ 2) * v1 ^ 2 := mul_pos hdet hv1sq
      nlinarith [sq_nonneg (w00 * v0 + w01 * v1)]
  exact (mul_pos_iff_of_pos_left h00).mp h_prod_pos

/-- **Weil Disproof Witness Criterion**:
If a symmetric Weil Gram matrix has `w₀₀ > 0` and a strictly negative `2 × 2` principal minor
`w₀₀ w₁₁ - w₀₁² < 0`, then the explicit test vector `v = (-w₀₁, w₀₀)` violates Weil positivity
(`vᵀ W v = w₀₀ (w₀₀ w₁₁ - w₀₁²) < 0`). -/
theorem weilQuadForm2_neg_witness_of_neg_det
    (w00 w01 w11 : ℝ) (h00 : 0 < w00) (hdet : w00 * w11 - w01 ^ 2 < 0) :
    weilQuadForm2 w00 w01 w11 (-w01) w00 = w00 * (w00 * w11 - w01 ^ 2) ∧
      weilQuadForm2 w00 w01 w11 (-w01) w00 < 0 := by
  have h_eq : weilQuadForm2 w00 w01 w11 (-w01) w00 = w00 * (w00 * w11 - w01 ^ 2) := by
    unfold weilQuadForm2
    ring
  exact ⟨h_eq, by rw [h_eq]; nlinarith⟩

/-! ### 9. De Bruijn–Newman Quadratic Backward-Heat Collision & Keiper–Li Binomial Identity -/

/-- Local quadratic solution of the de Bruijn–Newman backward heat equation
`∂_t H_t = -∂_z² H_t` near a Lehmer extremum `Z(γ*) = z0, Z'(γ*) = 0, Z''(γ*) = z2`. -/
def dbnQuadraticHeatSolution (z0 z2 t dz : ℝ) : ℝ :=
  (z0 - z2 * t) + (1 / 2) * z2 * dz ^ 2

/-- **De Bruijn–Newman Lehmer Collision Theorem**:
At an extremum peak (`z0 > 0, z2 < 0`), the local heat-flow peak hits zero at
`t_crit = z0 / z2 < 0` (where the two real roots merge into a double root at `dz = 0`),
and for any strictly earlier backward heat time `t < t_crit`, `H_t(dz) < 0` for EVERY
real `dz`, proving that both real zeros have bifurcated off the real axis. -/
theorem dbnQuadraticHeat_collides_and_leaves_real_axis
    (z0 z2 : ℝ) (hz0 : 0 < z0) (hz2 : z2 < 0) :
    let tCrit := z0 / z2
    tCrit < 0 ∧
      dbnQuadraticHeatSolution z0 z2 tCrit 0 = 0 ∧
      ∀ t dz : ℝ, t < tCrit → dbnQuadraticHeatSolution z0 z2 t dz < 0 := by
  dsimp only
  have hz2_ne : z2 ≠ 0 := ne_of_lt hz2
  refine ⟨div_neg_of_pos_of_neg hz0 hz2, ?_, ?_⟩
  · unfold dbnQuadraticHeatSolution
    field_simp [hz2_ne]
    ring
  · intro t dz ht
    unfold dbnQuadraticHeatSolution
    have h_peak_neg : z0 - z2 * t < 0 := by
      have h_mul : z2 * (z0 / z2) < z2 * t := mul_lt_mul_of_neg_left ht hz2
      have h_simp : z2 * (z0 / z2) = z0 := mul_div_cancel₀ z0 hz2_ne
      linarith
    have h_quad_nonpos : (1 / 2) * z2 * dz ^ 2 ≤ 0 := by
      nlinarith [sq_nonneg dz]
    linarith

/-- First three exact Keiper–Li binomial relations `λ_n = n ∑_{k=1}^n C(n-1, k-1) b_k`
expressing the infinite-zero Li coefficients directly in terms of Taylor coefficients `b_k`
of `ln(2 ξ(1 + z)) = ∑_{k≥1} b_k z^k`. -/
def keiperLi1 (b1 : ℝ) : ℝ := b1
def keiperLi2 (b1 b2 : ℝ) : ℝ := 2 * (b1 + b2)
def keiperLi3 (b1 b2 b3 : ℝ) : ℝ := 3 * (b1 + 2 * b2 + b3)

/-- Exact inverse recovery of the Taylor coefficients `b_1, b_2, b_3` of `ln(2 ξ(1 + z))`
from the first three Keiper–Li coefficients `λ_1, λ_2, λ_3`. -/
theorem keiperLi_binomial_inversion_123 (b1 b2 b3 : ℝ) :
    let l1 := keiperLi1 b1
    let l2 := keiperLi2 b1 b2
    let l3 := keiperLi3 b1 b2 b3
    b1 = l1 ∧
      b2 = l2 / 2 - l1 ∧
      b3 = l3 / 3 - l2 + l1 := by
  dsimp only
  unfold keiperLi1 keiperLi2 keiperLi3
  refine ⟨rfl, by ring, by ring⟩

/-! ### 10. RB-2: Quartic de Bruijn–Newman Heat Flow, Mpemba Weil Projection, & 4-Zero Squeezing -/

/-- Exact 4th-order (quartic) polynomial solution of the de Bruijn–Newman backward heat
equation `∂_t H_t = -∂_z² H_t` near an even extremum `Z(γ*) = z0, Z''(γ*) = z2, Z⁽⁴⁾(γ*) = z4`:
`H_t(dz) = (z0 - z2 t + (1/2) z4 t²) + (1/2) (z2 - z4 t) dz² + (1/24) z4 dz⁴`. -/
def dbnQuarticHeatSolution (z0 z2 z4 t dz : ℝ) : ℝ :=
  (z0 - z2 * t + (1 / 2) * z4 * t ^ 2) +
    (1 / 2) * (z2 - z4 * t) * dz ^ 2 +
    (1 / 24) * z4 * dz ^ 4

/-- Exact `∂_t H_t` and `∂_dz² H_t` of `dbnQuarticHeatSolution`, proving `∂_t H_t + ∂_dz² H_t = 0`
identically and exact peak residual `H_{z0/z2}(0) = (1/2) z4 (z0 / z2)²` at the quadratic collision
time `t_quad = z0 / z2`. -/
theorem dbnQuarticHeat_pde_and_shift
    (z0 z2 z4 t dz : ℝ) (hz2 : z2 ≠ 0) :
    let dtH := (-z2 + z4 * t) - (1 / 2) * z4 * dz ^ 2
    let dzzH := (z2 - z4 * t) + (1 / 2) * z4 * dz ^ 2
    dtH + dzzH = 0 ∧
      dbnQuarticHeatSolution z0 z2 z4 (z0 / z2) 0 = (1 / 2) * z4 * (z0 / z2) ^ 2 ∧
      (0 < z4 → z0 ≠ 0 → 0 < dbnQuarticHeatSolution z0 z2 z4 (z0 / z2) 0) := by
  dsimp only
  have h_peak :
      dbnQuarticHeatSolution z0 z2 z4 (z0 / z2) 0 = (1 / 2) * z4 * (z0 / z2) ^ 2 := by
    unfold dbnQuarticHeatSolution
    field_simp [hz2]
    ring
  refine ⟨by ring, h_peak, ?_⟩
  intro hz4 hz0
  rw [h_peak]
  have h_sq : 0 < (z0 / z2) ^ 2 := sq_pos_of_ne_zero (div_ne_zero hz0 hz2)
  positivity

/-- Symmetric `2 × 2` spectral Weil operator `W = λ_slow v_slow v_slowᵀ + λ_fast v_fast v_fastᵀ`
with orthonormal eigenbasis `v_slow = (c, s)`, `v_fast = (-s, c)` (`c² + s² = 1`). -/
def weilSpectralForm2 (lamSlow lamFast c s x0 x1 : ℝ) : ℝ :=
  lamSlow * (c * x0 + s * x1) ^ 2 + lamFast * (-s * x0 + c * x1) ^ 2

/-- **Strong Mpemba Projection Lifts Weil Spectral Conditioning**:
Reusing `Signals.QuantumCausalInference.mpembaProjector00..11`, projecting any test vector
`x = (x0, x1)` onto `y = P_{⊥ v_slow} x` annihilates the slow mode identically and yields
`yᵀ W y = λ_fast ‖y‖²`, strictly raising the Rayleigh quotient whenever `0 < λ_slow < λ_fast`
and `y ≠ 0`. -/
theorem mpemba_projection_eliminates_slow_weil_mode
    (lamSlow lamFast c s x0 x1 : ℝ)
    (h_unit : c ^ 2 + s ^ 2 = 1) :
    let y0 := Signals.QuantumCausalInference.mpembaProjector00 c s * x0 +
      Signals.QuantumCausalInference.mpembaProjector01 c s * x1
    let y1 := Signals.QuantumCausalInference.mpembaProjector01 c s * x0 +
      Signals.QuantumCausalInference.mpembaProjector11 c s * x1
    Signals.QuantumCausalInference.mpembaProjectedSlowOverlap c s x0 x1 = 0 ∧
      weilSpectralForm2 lamSlow lamFast c s y0 y1 = lamFast * (y0 ^ 2 + y1 ^ 2) ∧
      (lamSlow < lamFast → 0 < y0 ^ 2 + y1 ^ 2 →
        lamSlow * (y0 ^ 2 + y1 ^ 2) < weilSpectralForm2 lamSlow lamFast c s y0 y1) := by
  dsimp only
  have h_zero : Signals.QuantumCausalInference.mpembaProjectedSlowOverlap c s x0 x1 = 0 := by
    unfold Signals.QuantumCausalInference.mpembaProjectedSlowOverlap
      Signals.QuantumCausalInference.mpembaProjector00
      Signals.QuantumCausalInference.mpembaProjector01
      Signals.QuantumCausalInference.mpembaProjector11
    ring
  have h_quad :
      weilSpectralForm2 lamSlow lamFast c s
        (Signals.QuantumCausalInference.mpembaProjector00 c s * x0 +
          Signals.QuantumCausalInference.mpembaProjector01 c s * x1)
        (Signals.QuantumCausalInference.mpembaProjector01 c s * x0 +
          Signals.QuantumCausalInference.mpembaProjector11 c s * x1) =
        lamFast *
          ((Signals.QuantumCausalInference.mpembaProjector00 c s * x0 +
            Signals.QuantumCausalInference.mpembaProjector01 c s * x1) ^ 2 +
           (Signals.QuantumCausalInference.mpembaProjector01 c s * x0 +
            Signals.QuantumCausalInference.mpembaProjector11 c s * x1) ^ 2) := by
    unfold weilSpectralForm2
      Signals.QuantumCausalInference.mpembaProjector00
      Signals.QuantumCausalInference.mpembaProjector01
      Signals.QuantumCausalInference.mpembaProjector11
    have h_alg :
        lamSlow * (c * (s ^ 2 * x0 + -(c * s) * x1) + s * (-(c * s) * x0 + c ^ 2 * x1)) ^ 2 +
          lamFast * (-s * (s ^ 2 * x0 + -(c * s) * x1) + c * (-(c * s) * x0 + c ^ 2 * x1)) ^ 2 -
          lamFast * ((s ^ 2 * x0 + -(c * s) * x1) ^ 2 + (-(c * s) * x0 + c ^ 2 * x1) ^ 2) =
        lamFast * (c ^ 2 + s ^ 2 - 1) * (c ^ 2 + s ^ 2) * (s * x0 - c * x1) ^ 2 := by
      ring
    have h_diff_zero : c ^ 2 + s ^ 2 - 1 = 0 := by linarith
    rw [h_diff_zero] at h_alg
    linarith
  refine ⟨h_zero, h_quad, ?_⟩
  intro h_lt h_norm
  rw [h_quad]
  exact mul_lt_mul_of_pos_right h_lt h_norm

/-- **4-Zero Calogero–Moser Symmetric Neighbor-Squeezing Theorem**:
For an inner Lehmer pair at `(-δ, +δ)` flanked by symmetric outer neighbors at `(-D, +D)`
with `0 < δ < D`, the inner pair's forward separation rate `d(z₃ - z₂)/dt` equals the
2-zero repulsion `2 / δ` reduced by the exact inward squeezing term `8 δ / (D² - δ²) > 0`. -/
def dbnFourZeroSymmetricInnerRate (delta outerD : ℝ) : ℝ :=
  let v3 := 2 / (2 * delta) + 2 / (delta + outerD) + 2 / (delta - outerD)
  let v2 := 2 / (-2 * delta) + 2 / (-delta + outerD) + 2 / (-delta - outerD)
  v3 - v2

theorem dbnFourZero_symmetric_neighbor_squeeze
    (delta outerD : ℝ) (hd : 0 < delta) (hD : delta < outerD) :
    dbnFourZeroSymmetricInnerRate delta outerD =
      2 / delta - (8 * delta) / (outerD ^ 2 - delta ^ 2) ∧
      dbnFourZeroSymmetricInnerRate delta outerD < 2 / delta := by
  have hd_ne : delta ≠ 0 := ne_of_gt hd
  have h_sum_ne : delta + outerD ≠ 0 := ne_of_gt (by linarith)
  have h_diff_ne : delta - outerD ≠ 0 := ne_of_lt (by linarith)
  have h_neg_sum_ne : -delta - outerD ≠ 0 := ne_of_lt (by linarith)
  have h_pos_diff_ne : -delta + outerD ≠ 0 := ne_of_gt (by linarith)
  have h_sq_diff_pos : 0 < outerD ^ 2 - delta ^ 2 := by nlinarith
  have h_sq_diff_ne : outerD ^ 2 - delta ^ 2 ≠ 0 := ne_of_gt h_sq_diff_pos
  have h_id :
      dbnFourZeroSymmetricInnerRate delta outerD =
        2 / delta - (8 * delta) / (outerD ^ 2 - delta ^ 2) := by
    unfold dbnFourZeroSymmetricInnerRate
    field_simp [hd_ne, h_sum_ne, h_diff_ne, h_neg_sum_ne, h_pos_diff_ne, h_sq_diff_ne]
    ring
  refine ⟨h_id, ?_⟩
  rw [h_id]
  have h_sqz : 0 < (8 * delta) / (outerD ^ 2 - delta ^ 2) := by positivity
  linarith

/-! ### 11. Finite, Bounded Proxies for RB-6 (Not Global Bridge Closures)

These theorems cover only explicit finite cutoffs, diagonal operators, and the local quartic
heat polynomial. They do not establish any of the four infinite-dimensional RH bridges. -/

/-- Bound the quartic heat polynomial's peak value on `|t| ≤ timeBound` from coefficient
bounds. This controls a finite local model only; it is not a global de Bruijn-Newman bound. -/
theorem dbnQuarticHeat_peak_abs_le
    (z0 z2 z4 t bound0 bound2 bound4 timeBound : ℝ)
    (h_z0 : |z0| ≤ bound0)
    (h_z2 : |z2| ≤ bound2)
    (h_z4 : |z4| ≤ bound4)
    (h_t : |t| ≤ timeBound)
    (h_bound2 : 0 ≤ bound2)
    (h_bound4 : 0 ≤ bound4) :
    |dbnQuarticHeatSolution z0 z2 z4 t 0| ≤
      bound0 + bound2 * timeBound + bound4 * timeBound ^ 2 / 2 := by
  have h_peak :
      dbnQuarticHeatSolution z0 z2 z4 t 0 =
        z0 + (-(z2 * t)) + ((1 / 2 : ℝ) * z4 * t ^ 2) := by
    unfold dbnQuarticHeatSolution
    ring
  have h_z2_term : |z2 * t| ≤ bound2 * timeBound := by
    calc
      |z2 * t| = |z2| * |t| := abs_mul _ _
      _ ≤ bound2 * timeBound :=
        mul_le_mul h_z2 h_t (abs_nonneg t) h_bound2
  have h_time_sq : t ^ 2 ≤ timeBound ^ 2 := by
    rcases abs_le.mp h_t with ⟨h_lower, h_upper⟩
    have h_left : 0 ≤ timeBound - t := sub_nonneg.mpr h_upper
    have h_right : 0 ≤ timeBound + t := by linarith
    have h_product := mul_nonneg h_left h_right
    nlinarith
  have h_z4_product : |z4| * t ^ 2 ≤ bound4 * timeBound ^ 2 :=
    mul_le_mul h_z4 h_time_sq (sq_nonneg t) h_bound4
  have h_z4_term :
      |(1 / 2 : ℝ) * z4 * t ^ 2| ≤ bound4 * timeBound ^ 2 / 2 := by
    calc
      |(1 / 2 : ℝ) * z4 * t ^ 2| = (1 / 2 : ℝ) * (|z4| * t ^ 2) := by
        rw [abs_mul, abs_mul]
        rw [abs_of_nonneg (by norm_num : 0 ≤ (1 / 2 : ℝ)),
          abs_of_nonneg (sq_nonneg t)]
        ring
      _ ≤ (1 / 2 : ℝ) * (bound4 * timeBound ^ 2) :=
        mul_le_mul_of_nonneg_left h_z4_product (by norm_num)
      _ = bound4 * timeBound ^ 2 / 2 := by ring
  rw [h_peak]
  apply abs_le.mpr
  obtain ⟨h0_lower, h0_upper⟩ := abs_le.mp h_z0
  obtain ⟨h2_lower, h2_upper⟩ := abs_le.mp h_z2_term
  obtain ⟨h4_lower, h4_upper⟩ := abs_le.mp h_z4_term
  constructor <;> linarith

/-- Finite diagonal transfer residual, the sum of absolute coordinate errors. This is the
trace-norm proxy only for real diagonal matrices, not an adelic operator convergence claim. -/
def finiteDiagonalTransferTraceDistance {n : Nat}
    (approx target : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, |approx i - target i|

/-- A uniform coordinate error `ε` bounds the finite diagonal residual by `n ε`. -/
theorem finiteDiagonalTransferTraceDistance_le {n : Nat}
    (approx target : Fin n → ℝ) (epsilon : ℝ)
    (h_error : ∀ i, |approx i - target i| ≤ epsilon) :
    finiteDiagonalTransferTraceDistance approx target ≤ (n : ℝ) * epsilon := by
  unfold finiteDiagonalTransferTraceDistance
  calc
    (∑ i : Fin n, |approx i - target i|) ≤ ∑ _i : Fin n, epsilon :=
      Finset.sum_le_sum (fun i _ => h_error i)
    _ = (n : ℝ) * epsilon := by simp

/-- If a finite target diagonal has spectral values bounded by `radius`, an approximation with
coordinate error at most `epsilon` stays within `radius + epsilon`. -/
theorem finiteDiagonalTransfer_radius_le {n : Nat}
    (approx target : Fin n → ℝ) (radius epsilon : ℝ)
    (h_target : ∀ i, |target i| ≤ radius)
    (h_error : ∀ i, |approx i - target i| ≤ epsilon) :
    ∀ i, |approx i| ≤ radius + epsilon := by
  intro i
  have h_decomp : approx i = (approx i - target i) + target i := by ring
  rw [h_decomp]
  apply abs_le.mpr
  obtain ⟨h_error_lower, h_error_upper⟩ := abs_le.mp (h_error i)
  obtain ⟨h_target_lower, h_target_upper⟩ := abs_le.mp (h_target i)
  constructor <;> linarith

/-- Positivity of the first `cutoff` Li-like entries; this is a finite prefix condition only. -/
def finiteLiPositivePrefix (cutoff : Nat) (li : Nat → ℝ) : Prop :=
  ∀ n, 1 ≤ n → n ≤ cutoff → 0 ≤ li n

/-- Sum of the Li-like entries in the explicit finite index interval `[1, cutoff]`. -/
def finiteLiPrefixSum (cutoff : Nat) (li : Nat → ℝ) : ℝ :=
  ∑ n ∈ Finset.Icc 1 cutoff, li n

/-- Nonnegative entries through a finite cutoff give a nonnegative finite prefix sum. -/
theorem finiteLiPrefixSum_nonneg
    (cutoff : Nat) (li : Nat → ℝ)
    (h_positive : finiteLiPositivePrefix cutoff li) :
    0 ≤ finiteLiPrefixSum cutoff li := by
  unfold finiteLiPrefixSum
  apply Finset.sum_nonneg
  intro n hn
  exact h_positive n (Finset.mem_Icc.mp hn).1 (Finset.mem_Icc.mp hn).2

/-- Real diagonal operator on the finite Euclidean space `Fin n → ℝ`. -/
def finiteDiagonalOperator {n : Nat}
    (eigenvalues : Fin n → ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => eigenvalues i * x i

/-- Standard finite Euclidean inner product on coordinate vectors. -/
def finiteEuclideanInner {n : Nat} (x y : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, x i * y i

/-- A finite diagonal real operator is symmetric with respect to the finite Euclidean inner
product. This does not construct an essentially self-adjoint infinite-dimensional operator. -/
theorem finiteDiagonalOperator_symmetric {n : Nat}
    (eigenvalues x y : Fin n → ℝ) :
    finiteEuclideanInner (finiteDiagonalOperator eigenvalues x) y =
      finiteEuclideanInner x (finiteDiagonalOperator eigenvalues y) := by
  unfold finiteEuclideanInner finiteDiagonalOperator
  apply Finset.sum_congr rfl
  intro i hi
  ring

/-- Finite eigenpair relation for a real diagonal operator. -/
def finiteDiagonalEigenvalue {n : Nat}
    (eigenvalues : Fin n → ℝ) (lambda : ℝ) : Prop :=
  ∃ x : Fin n → ℝ,
    x ≠ (fun _ => 0) ∧
      finiteDiagonalOperator eigenvalues x = (fun i => lambda * x i)

/-- The eigenvalues of the finite diagonal model are exactly the supplied finite list,
in the elementary eigenpair sense. This is not a claim about the zeta zero spectrum. -/
theorem finiteDiagonalEigenvalue_iff_mem_range {n : Nat}
    (eigenvalues : Fin n → ℝ) (lambda : ℝ) :
    finiteDiagonalEigenvalue eigenvalues lambda ↔ ∃ i, eigenvalues i = lambda := by
  constructor
  · rintro ⟨x, hx, h_eigen⟩
    by_contra h_not_exists
    apply hx
    funext i
    have h_ne : eigenvalues i - lambda ≠ 0 := by
      intro h_eq
      apply h_not_exists
      exact ⟨i, by linarith⟩
    have h_eq := congrFun h_eigen i
    have h_mul : (eigenvalues i - lambda) * x i = 0 := by
      dsimp [finiteDiagonalOperator] at h_eq
      nlinarith [h_eq]
    exact (mul_eq_zero.mp h_mul).resolve_left h_ne
  · rintro ⟨j, h_j⟩
    refine ⟨(fun i => if i = j then 1 else 0), ?_, ?_⟩
    · intro h_zero
      have h_at := congrFun h_zero j
      simp at h_at
    · funext i
      by_cases h_ij : i = j
      · subst i
        simp [finiteDiagonalOperator, h_j]
      · simp [finiteDiagonalOperator, h_ij]

end

end Signals.RiemannSpectral
