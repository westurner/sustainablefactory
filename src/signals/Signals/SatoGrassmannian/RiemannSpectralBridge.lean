import Mathlib.Analysis.InnerProductSpace.PiL2
import Signals.RiemannSpectral
import Signals.SatoGrassmannian.Gr24Truncation
import Signals.SatoGrassmannian.HirotaKP
import Signals.SatoGrassmannian.RHGaps
import Signals.SatoGrassmannian.RemainingGaps
import Signals.SatoGrassmannian.CarlemanWeierstrass
import Signals.SatoGrassmannian.WeilPositivity
import Signals.SatoGrassmannian.WeilGaussianL1
import Signals.SatoGrassmannian.SegalWilsonGr24
import Signals.SatoGrassmannian.DualSchubertQFIM

/-!
# Formal Bridge Between `Signals.RiemannSpectral` and `Signals.SatoGrassmannian`

Connects the finite-dimensional `RB-6` Grassmannian / Li / de Bruijn–Newman / Jensen–Pólya /
Weil / celestial-holography theorems in `Signals.RiemannSpectral` to the infinite-dimensional
Hilbert-space Sato Grassmannian stack `Signals.SatoGrassmannian.*`:

1. **Li / Cayley bridge** (`liTransformModulusSq_eq_norm_sq_cayley`): exact identity
   `‖cayley ((1/2 + σ_dev) + i γ)‖² = liTransformModulusSq σ_dev γ`, uniting
   `RiemannSpectral.liTransformModulusSq_eq_one_iff_critical_line` with
   `RHGaps.norm_sq_cayley_sub_one`, `liSummand_nonneg_of_re_ge_half`, and
   `cayley_pow_unbounded_of_re_lt_half`.
2. **de Bruijn–Newman backward-heat collision bridge** (`dbnQuadraticHeatSolution_eq_localDoubleZero`):
   exact normalization matching `RiemannSpectral.dbnQuadraticHeatSolution` to
   `RHGaps.localDoubleZero`.
3. **Jensen–Pólya Madelung–Bohm / Turán bridge** (`jensen2_turan_iff_madelung_bohm`):
   degree-2 real-rootedness in `RHGaps` equals nonnegativity of the osmotic + Bohm
   discriminant in `Signals.RiemannSpectral`.
4. **Sato Hirota bilinear Plücker bridge** (`wronskianMinor_eq_pluckerCoord_cast`):
   real Wronskian minors in `Signals.RiemannSpectral` lift directly to `Gr24Truncation.pluckerCoord`
   on the Klein quadric `𝒬₄`, feeding into `HirotaKP.hirotaKP_tauU_eq_zero` and
   `SegalWilsonGr24.segalWilson_tau_gr24_eq_tauU`.
5. **Finite-to-infinite Kato–Rellich promotion** (`finiteDiagonalSymmetricOp`):
   promotes any real finite diagonal matrix `d : Fin n → ℝ` (`RiemannSpectral.finiteDiagonalOperator`)
   to an everywhere-defined `SymmetricOp (EuclideanSpace ℂ (Fin n))` satisfying the symmetric
   operator contract of `RHGaps.katoRellich_closure`.
6. **Celestial chiral Casimir & Cayley critical-line equivalence**
   (`celestialChiralCasimir_and_cayley_critical_line_equiv`):
   combines `RiemannSpectral.celestialChiralCasimir_im_eq_zero_iff_critical_line` with
   the Cayley unit-circle characterization `‖cayley ρ‖ = 1 ↔ σ_dev = 0`.
-/

open scoped InnerProductSpace BigOperators

namespace Signals.SatoGrassmannian.RiemannSpectralBridge

open Signals.RiemannSpectral
open Signals.SatoGrassmannian
open Signals.SatoGrassmannian.Gr24Truncation
open Signals.SatoGrassmannian.HirotaKP
open Signals.SatoGrassmannian.RHGaps
open Signals.SatoGrassmannian.RemainingGaps
open Signals.SatoGrassmannian.WeilPositivity
open Signals.SatoGrassmannian.WeilGaussianL1

/-! ### 1. Li / Cayley Unit-Circle Bridge -/

/-- Exact identity between `Signals.RiemannSpectral.liTransformModulusSq` and
`‖RHGaps.cayley ρ‖²` at `ρ = (1/2 + σ_dev) + i γ ≠ 0`. -/
theorem liTransformModulusSq_eq_norm_sq_cayley (sigmaDev gamma : ℝ)
    (h_rho_ne_zero : 0 < (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2) :
    let ρ : ℂ := ⟨sigmaDev + 1 / 2, gamma⟩
    ‖cayley ρ‖ ^ 2 = liTransformModulusSq sigmaDev gamma := by
  intro ρ
  have hden : (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2 ≠ 0 := ne_of_gt h_rho_ne_zero
  have hρ : ρ ≠ 0 := by
    intro h0
    have hre : sigmaDev + 1 / 2 = 0 := congrArg Complex.re h0
    have him : gamma = 0 := congrArg Complex.im h0
    rw [hre, him] at h_rho_ne_zero
    norm_num at h_rho_ne_zero
  have hnorm_sq_ρ : ‖ρ‖ ^ 2 = (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2 := by
    rw [← Complex.normSq_eq_norm_sq, Complex.normSq_apply]
    simp [ρ]; ring
  have hnorm_sq_sub : ‖ρ - 1‖ ^ 2 = (sigmaDev - 1 / 2) ^ 2 + gamma ^ 2 := by
    rw [← Complex.normSq_eq_norm_sq, Complex.normSq_apply]
    simp [ρ]; ring
  unfold cayley liTransformModulusSq
  have hfrac : (1 : ℂ) - ρ⁻¹ = (ρ - 1) / ρ := by field_simp [hρ]
  rw [hfrac, norm_div, div_pow, hnorm_sq_ρ, hnorm_sq_sub]

/-- Unified critical-line equivalence combining `Signals.RiemannSpectral` and `RHGaps`:
for `ρ = (1/2 + σ_dev) + i γ ≠ 0`, `‖cayley ρ‖² = 1 ↔ liTransformModulusSq σ_dev γ = 1 ↔ σ_dev = 0`,
and on the critical line (`σ_dev = 0`) every `n`-th Li summand is nonnegative. -/
theorem li_cayley_critical_line_bridge (sigmaDev gamma : ℝ)
    (h_rho_ne_zero : 0 < (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2) :
    let ρ : ℂ := ⟨sigmaDev + 1 / 2, gamma⟩
    (‖cayley ρ‖ ^ 2 = 1 ↔ sigmaDev = 0) ∧
    (liTransformModulusSq sigmaDev gamma = 1 ↔ ‖cayley ρ‖ ^ 2 = 1) ∧
    (sigmaDev = 0 → ∀ n : ℕ, 0 ≤ liSummand ρ n) := by
  intro ρ
  have heq := liTransformModulusSq_eq_norm_sq_cayley sigmaDev gamma h_rho_ne_zero
  have hiff := liTransformModulusSq_eq_one_iff_critical_line sigmaDev gamma h_rho_ne_zero
  refine ⟨by rw [heq]; exact hiff, by rw [heq], fun h0 n => ?_⟩
  have hρ : ρ ≠ 0 := by
    intro hzero
    have hre : sigmaDev + 1 / 2 = 0 := congrArg Complex.re hzero
    have him : gamma = 0 := congrArg Complex.im hzero
    rw [hre, him] at h_rho_ne_zero; norm_num at h_rho_ne_zero
  have hre : (1 : ℝ) / 2 ≤ ρ.re := by simp [ρ, h0]
  exact liSummand_nonneg_of_re_ge_half hρ hre n

/-! ### 2. de Bruijn–Newman Backward-Heat Collision Bridge -/

/-- Exact match between `Signals.RiemannSpectral.dbnQuadraticHeatSolution` (with curvature `z₂ = -2`)
and the real part of `RHGaps.localDoubleZero`:
`dbnQuadraticHeatSolution z0 (-2) t dz = -(localDoubleZero (t + z0 / 2) dz).re`. -/
theorem dbnQuadraticHeatSolution_eq_localDoubleZero (z0 t dz : ℝ) :
    dbnQuadraticHeatSolution z0 (-2) t dz = -(localDoubleZero (t + z0 / 2) dz).re := by
  unfold dbnQuadraticHeatSolution localDoubleZero
  have hre : (((dz : ℂ) ^ 2 - (2 : ℂ) * ((t + z0 / 2 : ℝ) : ℂ))).re =
      dz ^ 2 - 2 * (t + z0 / 2) := by
    have hcast : ((dz : ℂ) ^ 2 - (2 : ℂ) * ((t + z0 / 2 : ℝ) : ℂ)) =
        ((dz ^ 2 - 2 * (t + z0 / 2) : ℝ) : ℂ) := by push_cast; ring
    rw [hcast, Complex.ofReal_re]
  rw [hre]; ring

/-- Unified de Bruijn–Newman collision threshold: at `z₀ > 0, z₂ = -2`, the critical time is
`t_crit = -z₀ / 2 < 0`; for `t ≥ t_crit` the local double-zero polynomial has all real zeros,
while for `t < t_crit` `dbnQuadraticHeatSolution z0 (-2) t dz < 0` for every real `dz`. -/
theorem dbn_collision_bridge (z0 : ℝ) (hz0 : 0 < z0) :
    let tCrit := -(z0 / 2)
    tCrit < 0 ∧
    (∀ t : ℝ, tCrit ≤ t ↔ ∀ w : ℂ, localDoubleZero (t + z0 / 2) w = 0 → w.im = 0) ∧
    (∀ t dz : ℝ, t < tCrit → dbnQuadraticHeatSolution z0 (-2) t dz < 0) := by
  intro tCrit
  have hcol := dbnQuadraticHeat_collides_and_leaves_real_axis z0 (-2) hz0 (by norm_num)
  have htCrit_eq : z0 / (-2 : ℝ) = tCrit := by dsimp [tCrit]; ring
  refine ⟨by dsimp [tCrit]; linarith, fun t => ?_, fun t dz ht => ?_⟩
  · have hiff := localDoubleZero_allRealZeros_iff (t + z0 / 2)
    have hle : tCrit ≤ t ↔ 0 ≤ t + z0 / 2 := by dsimp [tCrit]; constructor <;> intro h <;> linarith
    exact hle.trans hiff.symm
  · exact hcol.2.2 t dz (by rw [htCrit_eq]; exact ht)

/-! ### 3. Jensen–Pólya Madelung–Bohm / Turán Bridge -/

/-- Exact equivalence between degree-2 Jensen–Pólya real-rootedness in `RHGaps`
and nonnegativity of the osmotic + Bohm channel sum in `Signals.RiemannSpectral`. -/
theorem jensen2_turan_iff_madelung_bohm (a0 a1 a2 : ℝ) (ha2 : 0 < a2) :
    (∀ z : ℂ, jensen2 a0 a1 a2 z = 0 → z.im = 0) ↔
      0 ≤ jensenPolyaOsmoticChannel a1 + jensenPolyaBohmChannel a0 a2 := by
  have hiff := jensen2_allRealZeros_iff_turan (γ₀ := a0) (γ₁ := a1) (γ₂ := a2) ha2
  unfold AllRealZeros at hiff
  rw [hiff]
  unfold jensenPolyaOsmoticChannel jensenPolyaBohmChannel
  constructor <;> intro h <;> linarith

/-! ### 4. Sato Hirota Bilinear Plücker Bridge -/

/-- Lifting a real 4-component Wronskian pair `(f, df)` into `C4 = Fin 4 → ℂ` identifies
`RiemannSpectral.wronskianMinor` with `Gr24Truncation.pluckerCoord` and automatically
satisfies both `sato_hirota_bilinear_plucker_identity` and `HirotaKP.hirotaKP_tauU_eq_zero`. -/
theorem wronskianMinor_eq_pluckerCoord_cast (f df : Fin 4 → ℝ) (i j : Fin 4) :
    ((wronskianMinor (f i) (f j) (df i) (df j) : ℝ) : ℂ) =
      pluckerCoord (fun k => (f k : ℂ)) (fun k => (df k : ℂ)) i j := by
  unfold wronskianMinor pluckerCoord
  push_cast
  ring

theorem riemannSpectral_wronskian_solves_hirotaKP (f df : Fin 4 → ℝ) (t₁ t₂ t₃ : ℂ) :
    let v : C4 := fun k => (f k : ℂ)
    let w : C4 := fun k => (df k : ℂ)
    pluckerCoord v w 0 1 * pluckerCoord v w 2 3 -
      pluckerCoord v w 0 2 * pluckerCoord v w 1 3 +
      pluckerCoord v w 0 3 * pluckerCoord v w 1 2 = 0 ∧
    hirotaKP (tauU v w) t₁ t₂ t₃ = 0 :=
  ⟨kleinQuadric_relation _ _, hirotaKP_tauU_eq_zero _ _ t₁ t₂ t₃⟩

/-! ### 5. Finite-to-Infinite Kato–Rellich Operator Promotion -/

/-- Promote a real finite diagonal spectrum `d : Fin n → ℝ` (the `RB-6` finite diagonal
operator from `Signals.RiemannSpectral.finiteDiagonalOperator`) to an everywhere-defined
`SymmetricOp (EuclideanSpace ℂ (Fin n))` in the unbounded Hilbert–Pólya framework of
`RHGaps.katoRellich_closure`. -/
noncomputable def finiteDiagonalSymmetricOp {n : ℕ} (d : Fin n → ℝ) :
    SymmetricOp (EuclideanSpace ℂ (Fin n)) where
  dom := ⊤
  op :=
    { toFun := fun x => WithLp.toLp 2 (fun i : Fin n => (d i : ℂ) * x.1.ofLp i)
      map_add' := fun x y => by
        ext i; simp [mul_add]
      map_smul' := fun c x => by
        ext i; simp; ring }
  symm := fun x y => by
    simp only [PiLp.inner_apply, RCLike.inner_apply]
    refine Finset.sum_congr rfl fun i _ => ?_
    change y.1.ofLp i * (starRingEnd ℂ) ((d i : ℂ) * x.1.ofLp i) =
      ((d i : ℂ) * y.1.ofLp i) * (starRingEnd ℂ) (x.1.ofLp i)
    rw [map_mul, Complex.conj_ofReal]
    ring

/-- Every real diagonal value `d i` is a genuine real eigenvalue of `finiteDiagonalSymmetricOp d`. -/
theorem finiteDiagonalSymmetricOp_eigenvalue {n : ℕ} (d : Fin n → ℝ) (i : Fin n) :
    let e : EuclideanSpace ℂ (Fin n) := EuclideanSpace.single i (1 : ℂ)
    (finiteDiagonalSymmetricOp d).op ⟨e, Submodule.mem_top⟩ = (d i : ℂ) • e := by
  intro e
  ext j
  change (d j : ℂ) * (EuclideanSpace.single i (1 : ℂ)).ofLp j =
    (d i : ℂ) * (EuclideanSpace.single i (1 : ℂ)).ofLp j
  by_cases hji : j = i
  · subst hji; rfl
  · simp [hji]

/-! ### 6. Celestial Chiral Casimir & Cayley Critical-Line Equivalence -/

/-- Combines `Signals.RiemannSpectral.celestialChiralCasimir_im_eq_zero_iff_critical_line`
with `li_cayley_critical_line_bridge`: for any nontrivial zero height `γ ≠ 0`,
vanishing of the celestial chiral Casimir imaginary part, unit-circle membership of the
Li/Cayley transform, and `σ_dev = 0` are mutually equivalent. -/
theorem celestialChiralCasimir_and_cayley_critical_line_equiv
    (sigmaDev gamma : ℝ) (h_gamma_ne : gamma ≠ 0) :
    let ρ : ℂ := ⟨sigmaDev + 1 / 2, gamma⟩
    (celestialChiralCasimirIm sigmaDev gamma = 0 ↔ ‖cayley ρ‖ ^ 2 = 1) ∧
    (‖cayley ρ‖ ^ 2 = 1 ↔ sigmaDev = 0) := by
  intro ρ
  have h_rho_ne : 0 < (sigmaDev + 1 / 2) ^ 2 + gamma ^ 2 := by
    have h1 : 0 ≤ (sigmaDev + 1 / 2) ^ 2 := sq_nonneg _
    have h2 : 0 < gamma ^ 2 := sq_pos_of_ne_zero h_gamma_ne
    linarith
  have hcas := celestialChiralCasimir_im_eq_zero_iff_critical_line sigmaDev gamma h_gamma_ne
  have hcas_iff : celestialChiralCasimirIm sigmaDev gamma = 0 ↔ sigmaDev = 0 := by
    rw [← hcas.2.1]; exact hcas.2.2.1
  have hcay := (li_cayley_critical_line_bridge sigmaDev gamma h_rho_ne).1
  exact ⟨hcas_iff.trans hcay.symm, hcay⟩

/-- **Dimensional Transmutation RG Shift & Cayley Contraction Bridge**:
Connects `Signals.RiemannSpectral.celestialDimTransmutationDev`, `toupin_re_delta_eq_d_cft_half_bridge`,
and `RHGaps.norm_cayley_le_one_iff` / `liSummand_nonneg_of_re_ge_half` / `cayley_pow_unbounded_of_re_lt_half`:
1. In an asymptotically free gauge theory (`b0 > 0, g ≠ 0`), `σ_rg = celestialDimTransmutationDev b0 g > 0`,
   so `s_rg = (1/2 + σ_rg) + i γ` satisfies `Re(s_rg) > 1/2`, `‖cayley s_rg‖ < 1` (contractive interior
   of the Cayley disk), and `0 ≤ liSummand s_rg n` for all `n`, while breaking chiral Casimir reality
   (`celestialChiralCasimirIm σ_rg γ ≠ 0`) and shifting `Δ_re = d_CFT * (1/2 + σ_rg) > d_CFT / 2`.
2. Conversely, any negative shift `σ_neg < 0` gives `Re(s) < 1/2`, triggering exponential blowup
   `‖(cayley s)^n‖ → ∞` (`RHGaps.cayley_pow_unbounded_of_re_lt_half`). -/
theorem celestialDimTransmutation_cayley_contraction_and_ir_bridge
    (b0 gCoupling gamma dBulk sigmaNeg : ℝ)
    (hb0 : 0 < b0) (hg : gCoupling ≠ 0) (hgam : gamma ≠ 0)
    (hd : 2 < dBulk) (h_neg : sigmaNeg < 0) :
    let σ_rg := celestialDimTransmutationDev b0 gCoupling
    let s_rg : ℂ := ⟨1 / 2 + σ_rg, gamma⟩
    let s_neg : ℂ := ⟨1 / 2 + sigmaNeg, gamma⟩
    let dCft := dBulk - 2
    0 < σ_rg ∧
      celestialChiralCasimirIm σ_rg gamma ≠ 0 ∧
      dCft / 2 < dCft * s_rg.re ∧
      ‖cayley s_rg‖ ≤ 1 ∧
      ‖cayley s_rg‖ ≠ 1 ∧
      (∀ n : ℕ, 0 ≤ liSummand s_rg n) ∧
      Filter.Tendsto (fun n : ℕ => ‖(cayley s_neg) ^ n‖) Filter.atTop Filter.atTop := by
  intro σ_rg s_rg s_neg dCft
  have h_rg_pos : 0 < σ_rg := by
    dsimp [σ_rg, celestialDimTransmutationDev]
    have hg2 : 0 < gCoupling ^ 2 := sq_pos_of_ne_zero hg
    have hpi : 0 < Real.pi := Real.pi_pos
    positivity
  have h_cas_ne : celestialChiralCasimirIm σ_rg gamma ≠ 0 := by
    unfold celestialChiralCasimirIm
    exact mul_ne_zero (mul_ne_zero two_ne_zero (ne_of_gt h_rg_pos)) hgam
  have h_dcft_pos : 0 < dCft := by dsimp [dCft]; linarith
  have h_srg_re : (1 / 2 : ℝ) < s_rg.re := by simp [s_rg]; linarith
  have h_delta_gt : dCft / 2 < dCft * s_rg.re := by
    calc
      dCft / 2 = dCft * (1 / 2 : ℝ) := by ring
      _ < dCft * s_rg.re := mul_lt_mul_of_pos_left h_srg_re h_dcft_pos
  have h_srg_ne : s_rg ≠ 0 := by
    intro h0
    have him : gamma = 0 := congrArg Complex.im h0
    exact hgam him
  have h_sneg_ne : s_neg ≠ 0 := by
    intro h0
    have him : gamma = 0 := congrArg Complex.im h0
    exact hgam him
  have h_cay_le : ‖cayley s_rg‖ ≤ 1 :=
    (norm_cayley_le_one_iff h_srg_ne).mpr (le_of_lt h_srg_re)
  have h_cay_ne1 : ‖cayley s_rg‖ ≠ 1 := by
    intro h1
    have hre := (norm_cayley_eq_one_iff h_srg_ne).mp h1
    linarith
  have h_li_nn : ∀ n : ℕ, 0 ≤ liSummand s_rg n :=
    liSummand_nonneg_of_re_ge_half h_srg_ne (le_of_lt h_srg_re)
  have h_sneg_lt : s_neg.re < 1 / 2 := by simp [s_neg]; linarith
  have h_blowup := cayley_pow_unbounded_of_re_lt_half h_sneg_ne h_sneg_lt
  exact ⟨h_rg_pos, h_cas_ne, h_delta_gt, h_cay_le, h_cay_ne1, h_li_nn, h_blowup⟩

/-! ### 7. Critical-Line `det₃` Anomaly & Infinite-Zero Weil / Evanescent QFIM Bridges -/

/-- **Critical-Line `det₃` Anomaly & Li/Cayley Bridge**:
Directly on the critical line `ρ = 1/2 + i t`, `‖cayley ρ‖² = 1`, every Li summand is
nonnegative, and the order-3 Carleman–Weierstrass prime product `det3Diag` both converges
non-vanishingly (`det₃ ≠ 0`) and obeys the exact `ℓ³` multiplicative trace anomaly. -/
theorem det3_critical_line_and_li_cayley_bridge (t : ℝ) :
    let s : ℂ := (1 / 2 : ℂ) + (t : ℂ) * Complex.I
    let lam : Nat.Primes → ℂ := fun p => -(((p : ℕ) : ℂ) ^ (-s))
    let μ : Nat.Primes → ℂ := fun p => (1 / 2 : ℂ) * lam p
    ‖cayley s‖ ^ 2 = 1 ∧
      (∀ n : ℕ, 0 ≤ liSummand s n) ∧
      CarlemanWeierstrass.detKDiag 3 lam ≠ 0 ∧
      CarlemanWeierstrass.det3Diag (fun p => lam p + μ p + lam p * μ p) =
        CarlemanWeierstrass.det3Diag lam * CarlemanWeierstrass.det3Diag μ *
          Complex.exp (∑' p : Nat.Primes, lam p * μ p * (lam p + μ p + (1 / 2 : ℂ) * lam p * μ p)) := by
  intro s lam μ
  have hs_eq : s = ⟨0 + 1 / 2, t⟩ := by
    apply Complex.ext <;> simp [s]
  have h_rho_pos : 0 < (0 + 1 / 2 : ℝ) ^ 2 + t ^ 2 := by positivity
  have hli := li_cayley_critical_line_bridge 0 t h_rho_pos
  have hcay : ‖cayley s‖ ^ 2 = 1 := by
    rw [hs_eq]
    exact hli.1.mpr rfl
  have hlinn : ∀ n : ℕ, 0 ≤ liSummand s n := by
    intro n
    rw [hs_eq]
    exact hli.2.2 rfl n
  have hd3 := CarlemanWeierstrass.det3_eulerPrimes_critical_line t
  have hanom := CarlemanWeierstrass.det3_eulerPrimes_critical_line_anomaly t
  exact ⟨hcay, hlinn, hd3.2, hanom.2⟩

/-- **Infinite-Zero `L¹(ℝ)` Weil Positivity & Evanescent QFIM Bridge**:
Pairs real-axis infinite-zero `L¹(ℝ)` Weil positivity (`weilInfiniteSum_nonneg_of_allRealZeros`)
with the exact Sharoglazova–Klaers evanescent speed law (`DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law`),
keeping finite/analytic QFIM verification distinct from physical calibration gates. -/
theorem weil_infinite_real_vs_evanescent_qfim_bridge
    (z : ℕ → ℂ) (m : ℕ → ℕ) (hReal : ∀ n : ℕ, (z n).im = 0)
    {f : ℝ → ℂ} (hf : AdmissibleL1All f)
    (hSumm : Summable (fun n : ℕ => (m n : ℝ) * ‖mellinTransform f (z n)‖ ^ 2))
    {ℏ mass eAbs j0 kPlus kMinus : ℝ} (hℏ : 0 < ℏ) (hm : 0 < mass)
    (hkp : kPlus ^ 2 = 2 * mass * (eAbs - ℏ * j0) / ℏ ^ 2)
    (hkm : kMinus ^ 2 = 2 * mass * (eAbs + ℏ * j0) / ℏ ^ 2) (x : ℝ) :
    0 ≤ (weilInfiniteSum z m f).re ∧
      (weilInfiniteSum z m f).im = 0 ∧
      (let κbar : ℝ := (kMinus + kPlus) / 2
       let δκ : ℝ := (kMinus - kPlus) / 2
       let ρ : ℝ := Real.exp (-2 * κbar * x) * Real.cosh (2 * δκ * x)
       let dρ : ℝ := 2 * ρ * (-κbar + δκ * Real.tanh (2 * δκ * x))
       let r : ℝ := Real.sqrt (Real.cosh (2 * δκ * x))
       let p : DualSchubertQFIM.Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
         if i = 0 then ((Real.cosh (δκ * x) / r : ℝ) : ℂ)
         else if i = 1 then ((Real.sinh (δκ * x) / r : ℝ) : ℂ)
         else 0)
       let dp : DualSchubertQFIM.Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
         if i = 0 then ((-(δκ * Real.sinh (δκ * x)) / (r * Real.cosh (2 * δκ * x)) : ℝ) : ℂ)
         else if i = 1 then (((δκ * Real.cosh (δκ * x)) / (r * Real.cosh (2 * δκ * x)) : ℝ) : ℂ)
         else 0)
       DualSchubertQFIM.fubiniStudy p dp = δκ ^ 2 / Real.cosh (2 * δκ * x) ^ 2 ∧
       (ℏ / mass) ^ 2 * ((⟪p, dp⟫_ℂ).im ^ 2 + (dρ / (2 * ρ)) ^ 2 + DualSchubertQFIM.qfim p dp / 4) =
         (2 / mass) * (eAbs - ℏ * j0 * Real.tanh (2 * δκ * x))) := by
  have hweil := weilInfiniteSum_nonneg_of_allRealZeros z m hReal hf hSumm
  have hsk := DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law hℏ hm hkp hkm x
  exact ⟨hweil.1, hweil.2, hsk.2.2.1, hsk.2.2.2⟩

/-- **Upgraded Strip-Automatic `L¹(ℝ)` Weil Positivity & Evanescent QFIM Bridge**:
Replaces the per-test-function `hSumm` hypothesis with the intrinsic sub-Gaussian zero-density
condition `Summable (fun n => (m n : ℝ) * Real.exp (-((z n).re ^ 2)))`, proving `Re ≥ 0, Im = 0`
for every `gaussianCombo δ P` automatically while pairing with the Sharoglazova–Klaers QFIM
evanescent speed law. -/
theorem weil_infinite_gaussianCombo_strip_vs_evanescent_qfim_bridge
    (z : ℕ → ℂ) (m : ℕ → ℕ) (hReal : ∀ n : ℕ, (z n).im = 0)
    (hGauss : Summable (fun n : ℕ => (m n : ℝ) * Real.exp (-((z n).re ^ 2))))
    (δ : ℝ) (P : Polynomial ℂ)
    {ℏ mass eAbs j0 kPlus kMinus : ℝ} (hℏ : 0 < ℏ) (hm : 0 < mass)
    (hkp : kPlus ^ 2 = 2 * mass * (eAbs - ℏ * j0) / ℏ ^ 2)
    (hkm : kMinus ^ 2 = 2 * mass * (eAbs + ℏ * j0) / ℏ ^ 2) (x : ℝ) :
    0 ≤ (weilInfiniteSum z m (gaussianCombo δ P)).re ∧
      (weilInfiniteSum z m (gaussianCombo δ P)).im = 0 ∧
      (let κbar : ℝ := (kMinus + kPlus) / 2
       let δκ : ℝ := (kMinus - kPlus) / 2
       let ρ : ℝ := Real.exp (-2 * κbar * x) * Real.cosh (2 * δκ * x)
       let dρ : ℝ := 2 * ρ * (-κbar + δκ * Real.tanh (2 * δκ * x))
       let r : ℝ := Real.sqrt (Real.cosh (2 * δκ * x))
       let p : DualSchubertQFIM.Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
         if i = 0 then ((Real.cosh (δκ * x) / r : ℝ) : ℂ)
         else if i = 1 then ((Real.sinh (δκ * x) / r : ℝ) : ℂ)
         else 0)
       let dp : DualSchubertQFIM.Plucker6 := WithLp.toLp 2 (fun i : Fin 6 =>
         if i = 0 then ((-(δκ * Real.sinh (δκ * x)) / (r * Real.cosh (2 * δκ * x)) : ℝ) : ℂ)
         else if i = 1 then (((δκ * Real.cosh (δκ * x)) / (r * Real.cosh (2 * δκ * x)) : ℝ) : ℂ)
         else 0)
       DualSchubertQFIM.fubiniStudy p dp = δκ ^ 2 / Real.cosh (2 * δκ * x) ^ 2 ∧
       (ℏ / mass) ^ 2 * ((⟪p, dp⟫_ℂ).im ^ 2 + (dρ / (2 * ρ)) ^ 2 + DualSchubertQFIM.qfim p dp / 4) =
         (2 / mass) * (eAbs - ℏ * j0 * Real.tanh (2 * δκ * x))) := by
  have hweil := weilInfiniteSum_gaussianCombo_nonneg_of_allRealZeros z m hReal hGauss δ P
  have hsk := DualSchubertQFIM.sharoglazova_klaers_evanescent_speed_law hℏ hm hkp hkm x
  exact ⟨hweil.1, hweil.2, hsk.2.2.1, hsk.2.2.2⟩

end Signals.SatoGrassmannian.RiemannSpectralBridge
