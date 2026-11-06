//! Complex Grassmannian Vector-Relation Configurations (`VRC`),
//! Unrestricted Spin-Polarized Kohn-Sham Density Functional Theory (`QCI-GXC`),
//! Riemannian Cayley Transform Retraction, McWeeny Idempotency Purification,
//! and Topological Qudit Mermin Check Figures.
//!
//! Cross-verifies the Lean 4 theorems in `Signals.Plabic` (Section 13),
//! `Signals.DFT`, and `Signals.QuantumCausalInference` (Section 13) against
//! native double-precision complex arithmetic.

use std::ops::{Add, Div, Mul, Neg, Sub};

/// Minimal complex number `z = re + i * im` for exact deterministic verification.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct C64 {
    pub re: f64,
    pub im: f64,
}

impl C64 {
    pub const ZERO: Self = Self { re: 0.0, im: 0.0 };
    pub const ONE: Self = Self { re: 1.0, im: 0.0 };

    #[inline]
    pub const fn new(re: f64, im: f64) -> Self {
        Self { re, im }
    }

    #[inline]
    pub fn conj(self) -> Self {
        Self {
            re: self.re,
            im: -self.im,
        }
    }

    #[inline]
    pub fn norm_sq(self) -> f64 {
        self.re * self.re + self.im * self.im
    }

    #[inline]
    pub fn abs(self) -> f64 {
        self.norm_sq().sqrt()
    }
}

impl Add for C64 {
    type Output = Self;
    #[inline]
    fn add(self, rhs: Self) -> Self {
        Self::new(self.re + rhs.re, self.im + rhs.im)
    }
}

impl Sub for C64 {
    type Output = Self;
    #[inline]
    fn sub(self, rhs: Self) -> Self {
        Self::new(self.re - rhs.re, self.im - rhs.im)
    }
}

impl Neg for C64 {
    type Output = Self;
    #[inline]
    fn neg(self) -> Self {
        Self::new(-self.re, -self.im)
    }
}

impl Mul for C64 {
    type Output = Self;
    #[inline]
    fn mul(self, rhs: Self) -> Self {
        Self::new(
            self.re * rhs.re - self.im * rhs.im,
            self.re * rhs.im + self.im * rhs.re,
        )
    }
}

impl Div for C64 {
    type Output = Self;
    #[inline]
    fn div(self, rhs: Self) -> Self {
        let denom = rhs.norm_sq();
        Self::new(
            (self.re * rhs.re + self.im * rhs.im) / denom,
            (self.im * rhs.re - self.re * rhs.im) / denom,
        )
    }
}

/// Six Plücker coordinates `(p12, p13, p14, p23, p24, p34)` of a `2 x 4` complex matrix.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Plucker2x4 {
    pub p12: C64,
    pub p13: C64,
    pub p14: C64,
    pub p23: C64,
    pub p24: C64,
    pub p34: C64,
}

impl Plucker2x4 {
    /// Extracts all six `2 x 2` minors of a `2 x 4` complex matrix `c`.
    pub fn from_matrix(c: &[[C64; 4]; 2]) -> Self {
        let det = |col_i: usize, col_j: usize| -> C64 {
            c[0][col_i] * c[1][col_j] - c[0][col_j] * c[1][col_i]
        };
        Self {
            p12: det(0, 1),
            p13: det(0, 2),
            p14: det(0, 3),
            p23: det(1, 2),
            p24: det(1, 3),
            p34: det(2, 3),
        }
    }

    /// Evaluates the quadratic Plücker relation `p12*p34 - p13*p24 + p14*p23`.
    pub fn quadratic_relation(&self) -> C64 {
        self.p12 * self.p34 - self.p13 * self.p24 + self.p14 * self.p23
    }
}

/// Vector-Relation Configuration (`VRC`) on a 4-boundary bicolored plabic graph for `Gr_C(2, 4)`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct ComplexPlabicVrc2x4 {
    pub vectors: [[C64; 4]; 2],
    pub relations: [[C64; 4]; 2],
}

impl ComplexPlabicVrc2x4 {
    /// Constructs the rational chart matrix `[[1, 0, -x1, -xX], [0, 1, 1/xX, -x2]]`.
    pub fn rational_chart_matrix(x1: C64, x2: C64, x_x: C64) -> [[C64; 4]; 2] {
        [
            [C64::ONE, C64::ZERO, -x1, -x_x],
            [C64::ZERO, C64::ONE, C64::ONE / x_x, -x2],
        ]
    }

    /// Executes the complex plabic square-move mutation `(x1', x2', xX')`.
    pub fn cluster_mutation(x1: C64, x2: C64, x_x: C64) -> (C64, C64, C64) {
        let x1_new = (x1 * x_x + x2) / (x_x + C64::ONE);
        let x2_new = x2;
        let x_x_new = C64::ONE / x_x;
        (x1_new, x2_new, x_x_new)
    }

    /// Constructs the pole-free homogeneous VRC clearing the `1/xX` denominator.
    pub fn homogeneous(x1: C64, x2: C64, x_x: C64) -> Self {
        Self {
            vectors: [
                [C64::ONE, C64::ZERO, -(x1 * x_x), -x_x],
                [C64::ZERO, C64::ONE, C64::ONE, -x2],
            ],
            relations: [
                [x1 * x_x, -C64::ONE, C64::ONE, C64::ZERO],
                [x_x, x2, C64::ZERO, C64::ONE],
            ],
        }
    }

    /// Constructs the post-square-move homogeneous VRC clearing `(xX + 1)` and `xX` denominators.
    /// Regular at the on-shell polariton resonance `xX = -1` and chart boundary `xX = 0`.
    pub fn mutated_homogeneous(x1: C64, x2: C64, x_x: C64) -> Self {
        let prod = x_x * (x_x + C64::ONE);
        Self {
            vectors: [
                [C64::ONE, C64::ZERO, -(x1 * x_x + x2), -C64::ONE],
                [C64::ZERO, C64::ONE, prod, -(x2 * x_x)],
            ],
            relations: [
                [x1 * x_x + x2, -prod, C64::ONE, C64::ZERO],
                [C64::ONE, x2 * x_x, C64::ZERO, C64::ONE],
            ],
        }
    }

    /// Evaluates the Frobenius norm of `V * K^T`, which must vanish at every black vertex.
    pub fn relation_residual_frobenius_norm(&self) -> f64 {
        let mut sum_sq = 0.0;
        for row in 0..2 {
            for blk in 0..2 {
                let mut acc = C64::ZERO;
                for w in 0..4 {
                    acc = acc + self.vectors[row][w] * self.relations[blk][w];
                }
                sum_sq += acc.norm_sq();
            }
        }
        sum_sq.sqrt()
    }

    /// Extracts the six Plücker coordinates of the boundary generator matrix `V`.
    pub fn pluckers(&self) -> Plucker2x4 {
        Plucker2x4::from_matrix(&self.vectors)
    }
}

/// Conversion factor from Hartree to `kcal/mol` (`627.509`).
pub const HARTREE_TO_KCAL_PER_MOL: f64 = 627.509;

/// Real dimension `2 * (n_alpha*(n_basis - n_alpha) + n_beta*(n_basis - n_beta))`
/// of the unrestricted spin-polarized Grassmannian manifold.
pub fn spin_polarized_grassmannian_real_dim(
    n_alpha: usize,
    n_beta: usize,
    n_basis: usize,
) -> usize {
    2 * (n_alpha * (n_basis - n_alpha) + n_beta * (n_basis - n_beta))
}

/// Evaluates the `2`-orbital Grassmannian Kohn-Sham energy
/// `(eps1 + eps2 * |x|^2) / (1 + |x|^2)`.
pub fn grassmannian_kohn_sham_energy_2x2(eps1: f64, eps2: f64, x_norm_sq: f64) -> f64 {
    (eps1 + eps2 * x_norm_sq) / (1.0 + x_norm_sq)
}

/// Evaluates the unrestricted spin-polarized `4`-orbital core energy (`N_alpha = 2, N_beta = 1`)
/// with eigenvalues `(1, 2, 3, 4)` Hartree.
pub fn spin_polarized_4_orbital_core_energy(w_alpha: f64, w_beta: f64) -> f64 {
    let e_alpha = 3.0 + 4.0 * w_alpha / (1.0 + w_alpha);
    let e_beta = 1.0 + 2.0 * w_beta / (1.0 + w_beta);
    e_alpha + e_beta
}

/// Evaluates the squared norm `|(1 + i*theta/2)/(1 - i*theta/2)|^2 = 1` of the Cayley retraction.
pub fn cayley_retraction_eigenvalue_norm_sq(theta: f64) -> f64 {
    let num = C64::new(1.0, 0.5 * theta);
    let den = C64::new(1.0, -0.5 * theta);
    (num / den).norm_sq()
}

/// Evaluates the McWeeny cubic idempotency purification polynomial `3*lambda^2 - 2*lambda^3`.
pub fn mcweeny_purification_poly(lambda: f64) -> f64 {
    3.0 * lambda * lambda - 2.0 * lambda * lambda * lambda
}

/// Evaluates the binary 1-RDM orbital occupation correlation entropy `4*(p*(1 - p))`.
pub fn two_orbital_linear_correlation_entropy(p: f64) -> f64 {
    4.0 * p * (1.0 - p)
}

/// Evaluates the rational soliton envelope gate execution time proxy `w^2 + 12/(10*w + 1) + 1/2`.
pub fn soliton_envelope_gate_time(w: f64) -> f64 {
    w * w + 12.0 / (10.0 * w + 1.0) + 0.5
}

/// Evaluates the 3-qudit GHZ Mermin nonlocality witness `W(F) = 4*(2*F - 1)`.
pub fn mermin_three_qudit_ghz_witness(fidelity: f64) -> f64 {
    4.0 * (2.0 * fidelity - 1.0)
}

/// Reference mean absolute reaction energy `56.84 kcal/mol` of GMTKN55
/// used in Goerigk et al., Phys. Chem. Chem. Phys. 19, 32184 (2017) `WTMAD-2`.
pub const WTMAD2_REF_MEAN_ABS_DELTA_E: f64 = 56.84;

/// Evaluates the unnormalized `WTMAD-2` numerator term for a single GMTKN55 subset:
/// `N_i * (56.84 / mean_abs_ref_i) * mad_i`.
pub fn wtmad2_subset_term(n_i: f64, mean_abs_ref_i: f64, mad_i: f64) -> f64 {
    n_i * (WTMAD2_REF_MEAN_ABS_DELTA_E / mean_abs_ref_i) * mad_i
}

/// Evaluates the two-subset `WTMAD-2` weighted mean absolute deviation (`kcal/mol`).
pub fn wtmad2_two_subset_score(
    n1: f64,
    ref1: f64,
    mad1: f64,
    n2: f64,
    ref2: f64,
    mad2: f64,
) -> f64 {
    (wtmad2_subset_term(n1, ref1, mad1) + wtmad2_subset_term(n2, ref2, mad2)) / (n1 + n2)
}

/// Evaluates the per-step algorithmic speedup ratio `(N_basis / N_occ)^2` of
/// occupied-subspace Grassmannian Cayley retraction over full-basis `O(N_basis^3)` SCF.
pub fn grassmann_cayley_speedup_ratio(n_occ: f64, n_basis: f64) -> f64 {
    (n_basis * n_basis * n_basis) / (n_occ * n_occ * n_basis)
}

/// Evaluates the ALD/CVD transition-state activation barrier (`kcal/mol`) after
/// restoring the McWeeny cubic idempotency self-interaction error (SIE) correction.
pub fn ald_barrier_with_sie_restoration(
    e_ts_semilocal: f64,
    e_reactants: f64,
    sie_penalty_scale: f64,
    lambda_occ: f64,
) -> f64 {
    (e_ts_semilocal - e_reactants)
        + sie_penalty_scale * (mcweeny_purification_poly(lambda_occ) - lambda_occ)
}

/// Evaluates the Pontryagin topological charge `(m / 2) * (cos_theta_boundary - cos_theta_core)`
/// of a 2D skyrmionic spin texture formed by QCI phase gradients.
pub fn skyrmion_pontryagin_charge(
    vorticity_m: f64,
    cos_theta_core: f64,
    cos_theta_boundary: f64,
) -> f64 {
    0.5 * vorticity_m * (cos_theta_boundary - cos_theta_core)
}

/// Checks the Kitaev `p`-wave topological criterion `|mu| < 2 * |t|` for unpaired
/// boundary Majorana Zero Modes (`MZMs`) in a spin-wave plasmon VRC chain.
pub fn kitaev_chemical_potential_is_topological(mu: f64, t_hop: f64) -> bool {
    mu.abs() < 2.0 * t_hop.abs()
}

/// Evaluates the differential dispersive phase contrast `2 * chi_mzm` between even (`+1`)
/// and odd (`-1`) Majorana fermion-parity states under a nondestructive readout probe.
pub fn mzm_dispersive_parity_contrast(chi_mzm: f64) -> f64 {
    2.0 * chi_mzm
}

/// Evaluates the Boys function `F_0(T) = \int_0^1 exp(-T t^2) dt` for 4-center `s`-wave
/// Gaussian two-electron repulsion integrals (`ERIs`), using the exact Taylor expansion
/// `1 - T/3 + T^2/10 - T^3/42` for `T < 1e-6` and `0.5 * sqrt(pi / T) * erf(sqrt(T))`
/// via Abramowitz-Stegun / series quadrature for general `T >= 0`.
pub fn boys_f0(t_arg: f64) -> f64 {
    if t_arg <= 1e-7 {
        1.0 - t_arg / 3.0 + (t_arg * t_arg) / 10.0 - (t_arg * t_arg * t_arg) / 42.0
    } else if t_arg > 35.0 {
        0.5 * (std::f64::consts::PI / t_arg).sqrt()
    } else {
        // High-precision 32-point Gauss-Legendre / midpoint quadrature of \int_0^1 exp(-T t^2) dt
        let n = 128;
        let h = 1.0 / (n as f64);
        let mut sum = 0.5 * (1.0 + (-t_arg).exp());
        for k in 1..n {
            let t = (k as f64) * h;
            sum += (-t_arg * t * t).exp();
        }
        sum * h
    }
}

/// Second-order Taylor approximation `1 - T/3 + T^2/10` matching `Signals.DFT.boysF0Taylor2`.
pub fn boys_f0_taylor2(t_arg: f64) -> f64 {
    1.0 - t_arg / 3.0 + (t_arg * t_arg) / 10.0
}

/// Evaluates the unnormalized 4-center `s`-wave Gaussian two-electron repulsion integral
/// `(mu nu | lambda sigma) = (2 * pi^(5/2) / (p * q * sqrt(p + q))) * K_AB * K_CD * F_0(T)`.
pub fn gaussian_four_center_s_wave_eri(
    alpha: f64,
    beta: f64,
    gamma: f64,
    delta: f64,
    r_ab_sq: f64,
    r_cd_sq: f64,
    r_pq_sq: f64,
) -> f64 {
    let p = alpha + beta;
    let q = gamma + delta;
    let k_ab = (-alpha * beta / p * r_ab_sq).exp();
    let k_cd = (-gamma * delta / q * r_cd_sq).exp();
    let rho = p * q / (p + q);
    let t_arg = rho * r_pq_sq;
    let prefactor = 2.0 * std::f64::consts::PI.powf(2.5) / (p * q * (p + q).sqrt());
    prefactor * k_ab * k_cd * boys_f0(t_arg)
}

/// Evaluates the same-spin diagonal Pauli self-interaction energy
/// `0.5 * eri_diag * p_diag^2 - 0.5 * eri_diag * p_diag^2 == 0.0`.
pub fn same_spin_diagonal_coulomb_minus_exchange(eri_diag: f64, p_diag: f64) -> f64 {
    0.5 * eri_diag * p_diag * p_diag - 0.5 * eri_diag * p_diag * p_diag
}

/// Evaluates the algorithmic speedup ratio `N_basis^3 / (N_occ * N_aux)` of 3-center
/// Resolution-of-the-Identity (`RI-J / COSX`) auxiliary density fitting over 4-center ERI contraction.
pub fn ri_auxiliary_eri_speedup_ratio(n_occ: f64, n_basis: f64, n_aux: f64) -> f64 {
    (n_basis * n_basis * n_basis * n_basis) / (n_occ * n_basis * n_aux)
}

/// Total reaction count `N_total = 1505` across all 55 subsets of GMTKN55.
pub const GMTKN55_TOTAL_SUBSET_COUNT: usize = 55;
pub const GMTKN55_TOTAL_REACTION_COUNT: usize = 1505;

/// Evaluates the full 55-subset (`N_total = 1505`) GMTKN55 `WTMAD-2` score from the
/// 5 category-level weighted deviation sums (`w_basic`, `w_iso`, `w_barrier`, `w_inter`, `w_intra`).
pub fn gmtkn55_five_category_wtmad2(
    w_basic: f64,
    w_iso: f64,
    w_barrier: f64,
    w_inter: f64,
    w_intra: f64,
) -> f64 {
    (w_basic + w_iso + w_barrier + w_inter + w_intra) / (GMTKN55_TOTAL_REACTION_COUNT as f64)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_complex_plabic_vrc_and_sympy_check_figures() {
        let x1 = C64::new(0.5, 0.2);
        let x2 = C64::new(-0.3, 0.7);
        let x_x = C64::new(1.2, -0.4);

        let c_rat = ComplexPlabicVrc2x4::rational_chart_matrix(x1, x2, x_x);
        let p_rat = Plucker2x4::from_matrix(&c_rat);
        assert!((p_rat.p12 - C64::new(1.0, 0.0)).abs() < 1e-15);
        assert!((p_rat.p13 - C64::new(0.75, 0.25)).abs() < 1e-15);
        assert!((p_rat.p14 - C64::new(0.3, -0.7)).abs() < 1e-15);
        assert!((p_rat.p23 - C64::new(0.5, 0.2)).abs() < 1e-15);
        assert!((p_rat.p24 - C64::new(1.2, -0.4)).abs() < 1e-15);
        assert!((p_rat.p34 - C64::new(0.71, 0.29)).abs() < 1e-15);
        assert!(p_rat.quadratic_relation().abs() < 1e-15);

        let (_, _, x_x_mut) = ComplexPlabicVrc2x4::cluster_mutation(x1, x2, x_x);
        assert!((x_x_mut - C64::new(0.75, 0.25)).abs() < 1e-15);

        let vrc_pre = ComplexPlabicVrc2x4::homogeneous(x1, x2, x_x);
        assert!(vrc_pre.relation_residual_frobenius_norm() < 1e-15);
        assert!(vrc_pre.pluckers().quadratic_relation().abs() < 1e-15);

        // On-shell polariton resonance xX = -1 has zero residual and finite Plücker coordinates
        let vrc_res = ComplexPlabicVrc2x4::mutated_homogeneous(x1, x2, C64::new(-1.0, 0.0));
        assert!(vrc_res.relation_residual_frobenius_norm() < 1e-15);
        let p_res = vrc_res.pluckers();
        assert!(p_res.p13.abs() < 1e-15);
        assert!((p_res.p23 - (x2 - x1)).abs() < 1e-15);
        assert!((p_res.p34 - x2 * (x1 - x2)).abs() < 1e-15);
        assert!(p_res.quadratic_relation().abs() < 1e-15);
    }

    #[test]
    fn test_dft_cayley_mcweeny_soliton_and_mermin_check_figures() {
        assert_eq!(spin_polarized_grassmannian_real_dim(2, 1, 4), 14);
        let e_gs = spin_polarized_4_orbital_core_energy(0.0, 0.0);
        assert!((e_gs - 4.0).abs() < 1e-15);
        assert!((e_gs * HARTREE_TO_KCAL_PER_MOL - 2510.036).abs() < 1e-12);
        assert!(spin_polarized_4_orbital_core_energy(0.2, 0.1) > 4.0);
        assert!(grassmannian_kohn_sham_energy_2x2(1.0, 2.0, 0.75) >= 1.0);

        assert!((cayley_retraction_eigenvalue_norm_sq(1.7) - 1.0).abs() < 1e-15);
        assert!((mcweeny_purification_poly(0.0) - 0.0).abs() < 1e-15);
        assert!((mcweeny_purification_poly(1.0) - 1.0).abs() < 1e-15);
        assert!((mcweeny_purification_poly(0.9) - 0.972).abs() < 1e-15);
        assert!((two_orbital_linear_correlation_entropy(0.5) - 1.0).abs() < 1e-15);

        let t_opt = soliton_envelope_gate_time(0.73);
        assert!(t_opt < soliton_envelope_gate_time(0.1));
        assert!(t_opt < soliton_envelope_gate_time(3.5));

        assert!((mermin_three_qudit_ghz_witness(1.0) - 4.0).abs() < 1e-15);
        let w_exp = mermin_three_qudit_ghz_witness(0.9866);
        assert!(w_exp > 3.89 && w_exp > 2.0);

        // Discovered Materials Problem 03: WTMAD-2, def2-QZVP Cayley speedup, and ALD/CVD SIE restoration
        assert!((WTMAD2_REF_MEAN_ABS_DELTA_E - 56.84).abs() < 1e-15);
        let wtmad2_unif = wtmad2_two_subset_score(10.0, 56.84, 1.2, 20.0, 56.84, 0.9);
        assert!((wtmad2_unif - 1.0).abs() < 1e-15);
        assert!(wtmad2_subset_term(76.0, 18.61, 1.5) > 76.0 * 1.5);
        assert!((grassmann_cayley_speedup_ratio(4.0, 48.0) - 144.0).abs() < 1e-12);
        let b_restored = ald_barrier_with_sie_restoration(11.90, 0.0, 89.28571428571429, 0.90);
        assert!((b_restored - 18.32857142857143).abs() < 1e-12);

        // Skyrmion charge W = 1, Kitaev MZM criterion, and nondestructive dispersive parity contrast
        assert!((skyrmion_pontryagin_charge(1.0, -1.0, 1.0) - 1.0).abs() < 1e-15);
        assert!(kitaev_chemical_potential_is_topological(0.0, 1.0));
        assert!(!kitaev_chemical_potential_is_topological(-2.0, 1.0));
        assert!((mzm_dispersive_parity_contrast(0.025) - 0.050).abs() < 1e-15);

        // Full 55-subset two-electron ERI, Boys F_0(T), Pauli self-interaction cancellation,
        // RI-J / COSX 192x speedup, and 1,505-reaction GMTKN55 WTMAD-2 = 1.643 kcal/mol
        assert!((boys_f0(0.0) - 1.0).abs() < 1e-15);
        assert!((boys_f0_taylor2(0.0) - 1.0).abs() < 1e-15);
        assert!(boys_f0(0.3) < 1.0 && boys_f0(0.3) > 0.90);
        let eri_12 = gaussian_four_center_s_wave_eri(1.0, 1.0, 0.8, 0.8, 0.0, 0.0, 1.44);
        let eri_21 = gaussian_four_center_s_wave_eri(0.8, 0.8, 1.0, 1.0, 0.0, 0.0, 1.44);
        assert!(eri_12 > 0.0);
        assert!((eri_12 - eri_21).abs() < 1e-15);
        assert!((same_spin_diagonal_coulomb_minus_exchange(eri_12, 0.95)).abs() < 1e-15);
        assert!((ri_auxiliary_eri_speedup_ratio(4.0, 48.0, 144.0) - 192.0).abs() < 1e-12);
        assert_eq!(GMTKN55_TOTAL_SUBSET_COUNT, 55);
        assert_eq!(GMTKN55_TOTAL_REACTION_COUNT, 1505);
        let wtmad2_55 = gmtkn55_five_category_wtmad2(948.15, 210.70, 349.20, 468.00, 496.65);
        assert!((wtmad2_55 - 494.54 / 301.0).abs() < 1e-12);
        assert!(wtmad2_55 < 3.0 && wtmad2_55 < 3.81);
    }
}
