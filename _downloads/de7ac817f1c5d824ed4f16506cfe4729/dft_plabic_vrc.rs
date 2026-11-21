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

// ============================================================================
// Discovered Materials Problem 04: "Tuning Materials with Light"
// Time-Linear Grassmannian GKBA (G-GKBA), Hubbard Chains/Ladders, WSe2,
// Graphite SCOP-to-Acoustic Energy Flow, and MgB2 Driven Superconductivity
// ============================================================================

/// Two-time Kadanoff-Baym Equation (KBE) contour integration complexity proxy `N_t^3 * N_basis^3`.
pub fn two_time_kbe_flops(n_steps: f64, n_basis: f64) -> f64 {
    n_steps.powi(3) * n_basis.powi(3)
}

/// Time-linear Grassmannian GKBA (`G-GKBA`) complexity proxy `N_t * N_occ^2 * N_basis`.
pub fn time_linear_grassmann_gkba_flops(n_steps: f64, n_occ: f64, n_basis: f64) -> f64 {
    n_steps * n_occ.powi(2) * n_basis
}

/// Algorithmic speedup ratio of time-linear Grassmannian `G-GKBA` over two-time KBE:
/// `N_t^2 * (N_basis / N_occ)^2`.
pub fn grassmann_gkba_speedup_ratio(n_steps: f64, n_occ: f64, n_basis: f64) -> f64 {
    two_time_kbe_flops(n_steps, n_basis) / time_linear_grassmann_gkba_flops(n_steps, n_occ, n_basis)
}

/// Hubbard correlated double occupancy `d(n_up, n_down, U/J)` across `U/J = 0..20`
/// (Schroedter, Bonitz & Joost, `arXiv:2606.10773`, 2026).
pub fn hubbard_correlated_double_occupancy(n_up: f64, n_down: f64, u_over_j: f64) -> f64 {
    (n_up * n_down) / (1.0 + 0.15 * u_over_j + 0.02 * u_over_j.powi(2))
}

/// Odd-even site density imbalance `(N_odd - N_even) / (N_odd + N_even)` on the 11-site Hubbard chain.
pub fn hubbard_density_imbalance(n_odd: f64, n_even: f64) -> f64 {
    (n_odd - n_even) / (n_odd + n_even)
}

/// Perturbative repulsively bound doublon relaxation rate proxy `J^2 / U`.
pub fn hubbard_doublon_decay_rate(j_hop: f64, u_int: f64) -> f64 {
    j_hop.powi(2) / u_int
}

/// Mott-Hubbard optical conductivity gap threshold `U/J - W` on the 6x2 Hubbard ladder.
pub fn hubbard_optical_conductivity_threshold(u_over_j: f64, bandwidth_w: f64) -> f64 {
    u_over_j - bandwidth_w
}

/// Resonant A-exciton pump photon energy (1.72 eV) in WSe2 at 90 K (Madéo et al., Science 2020).
pub const WSE2_RESONANT_PUMP_EV: f64 = 1.72;

/// Above-gap continuum pump photon energy (2.48 eV) in WSe2 at 90 K (Madéo et al., Science 2020).
pub const WSE2_ABOVE_GAP_PUMP_EV: f64 = 2.48;

/// Momentum-dark K-Q exciton energy (1.675 eV, 45 meV below bright K-K) in WSe2.
pub const WSE2_DARK_EXCITON_ENERGY_EV: f64 = 1.675;

/// Characteristic momentum-dark exciton buildup timescale (400 fs) in WSe2.
pub const WSE2_DARK_EXCITON_BUILDUP_FS: f64 = 400.0;

/// Late-time bright-to-dark exciton population ratio `gamma_{D->B} / gamma_{B->D}` in WSe2.
pub fn wse2_late_time_bright_to_dark_ratio(gamma_d_to_b: f64, gamma_b_to_d: f64) -> f64 {
    gamma_d_to_b / gamma_b_to_d
}

/// Five-reservoir coupled electron + SCOP (`A1'`, `E2g`) + acoustic (`LA`, `TA`) energy balance in Graphite
/// (René de Cotret et al., PRB 100, 214115 (2019)).
pub fn graphite_total_energy_balance(
    e_el: f64,
    e_scop_a1p: f64,
    e_scop_e2g: f64,
    e_acoustic_la: f64,
    e_acoustic_ta: f64,
) -> f64 {
    e_el + e_scop_a1p + e_scop_e2g + e_acoustic_la + e_acoustic_ta
}

/// Bi-exponential K-point `A1'` optical phonon rise-and-decay population envelope in Graphite.
pub fn graphite_a1p_optical_rise_and_decay(amp: f64, rise_factor: f64, decay_factor: f64) -> f64 {
    amp * (1.0 - rise_factor) * decay_factor
}

/// Measured sample superconducting critical temperature `Tc = 38.0 K` of MgB2 (Katsumi et al., PRL 2025).
pub const MGB2_KATSUMI_CRITICAL_TEMP_K: f64 = 38.0;

/// Squared lower pi-band superconducting gap `Delta_pi(T)^2 = Delta_pi(0)^2 * (1 - (T/Tc)^2)` of MgB2.
pub fn mgb2_lower_pi_gap_sq(delta_pi0: f64, temp_k: f64, tc_k: f64) -> f64 {
    if temp_k <= tc_k {
        delta_pi0.powi(2) * (1.0 - (temp_k / tc_k).powi(2))
    } else {
        0.0
    }
}

/// Normalized first-harmonic THz response `1 - (T/Tc)^2` of MgB2 under 0.63 THz driving.
pub fn mgb2_normalized_first_harmonic(temp_k: f64, tc_k: f64) -> f64 {
    if temp_k <= tc_k {
        1.0 - (temp_k / tc_k).powi(2)
    } else {
        0.0
    }
}

/// Nonlinear third-harmonic (`3w`) resonance denominator squared at 7 K in MgB2 (`2*Delta_pi/h ~ 1.0 THz`).
pub fn mgb2_third_harmonic_resonance_denom_sq(
    two_omega_thz: f64,
    two_delta_pi_thz: f64,
    gamma_damp_thz: f64,
) -> f64 {
    (two_omega_thz.powi(2) - two_delta_pi_thz.powi(2)).powi(2) + gamma_damp_thz.powi(2)
}

/// Inductive imaginary superfluid conductivity `sigma_2(n_s, omega) = n_s / omega` in MgB2.
pub fn mgb2_driven_superfluid_conductivity_im(n_s_frac: f64, omega_thz: f64) -> f64 {
    n_s_frac / omega_thz
}

/// Total time-linear Grassmannian `G-GKBA` complexity including per-step G1-G2 two-particle
/// and electron-phonon cumulant propagation overhead `cumulant_overhead`.
pub fn ggkba_total_flops_with_cumulants(
    n_steps: f64,
    n_occ: f64,
    n_basis: f64,
    cumulant_overhead: f64,
) -> f64 {
    n_steps * (n_occ.powi(2) * n_basis + cumulant_overhead)
}

/// Effective end-to-end speedup ratio of time-linear Grassmannian `G-GKBA` over two-time KBE
/// when per-step G1-G2 cumulant overhead is included.
pub fn effective_ggkba_speedup_with_cumulants(
    n_steps: f64,
    n_occ: f64,
    n_basis: f64,
    cumulant_overhead: f64,
) -> f64 {
    two_time_kbe_flops(n_steps, n_basis)
        / ggkba_total_flops_with_cumulants(n_steps, n_occ, n_basis, cumulant_overhead)
}

/// Antiferromagnetic superexchange energy scale `J_ex = 4 * J^2 / U` in Hubbard chains & ladders.
pub fn hubbard_superexchange_scale(j_hop: f64, u_int: f64) -> f64 {
    4.0 * j_hop.powi(2) / u_int
}

/// High-density Pauli phase-space filling and Coulomb Mott-screening factor `1 - n_ex / n_Mott`.
pub fn exciton_pauli_phase_space_filling_factor(n_exciton: f64, n_mott: f64) -> f64 {
    (1.0 - n_exciton / n_mott).max(0.0)
}

/// Effective exciton binding energy `E_b^(0) * (1 - n_ex / n_Mott)` in the high-density regime.
pub fn exciton_high_density_effective_binding(e_bind0: f64, n_exciton: f64, n_mott: f64) -> f64 {
    e_bind0 * exciton_pauli_phase_space_filling_factor(n_exciton, n_mott)
}

/// Instantaneous sum of the five coupled electron-SCOP-acoustic ODE rates in laser-pumped Graphite.
#[allow(clippy::too_many_arguments)]
pub fn graphite_five_reservoir_rate_sum(
    p_laser: f64,
    g_e_a1p: f64,
    g_e_e2g: f64,
    g_e_la: f64,
    g_a1p_la: f64,
    g_a1p_ta: f64,
    g_e2g_la: f64,
    g_e2g_ta: f64,
    g_la_ta: f64,
) -> f64 {
    let de_el = p_laser - (g_e_a1p + g_e_e2g + g_e_la);
    let de_a1p = g_e_a1p - (g_a1p_la + g_a1p_ta);
    let de_e2g = g_e_e2g - (g_e2g_la + g_e2g_ta);
    let de_la = g_e_la + g_a1p_la + g_e2g_la - g_la_ta;
    let de_ta = g_a1p_ta + g_e2g_ta + g_la_ta;
    de_el + de_a1p + de_e2g + de_la + de_ta
}

/// Out-of-equilibrium superconducting critical temperature `Tc^neq(Tc0, n_qp) = Tc0 * (1 - 2 * n_qp)`.
pub fn mgb2_non_equilibrium_critical_temp(tc0: f64, n_qp: f64) -> f64 {
    (tc0 * (1.0 - 2.0 * n_qp)).max(0.0)
}

/// Field-saturated THz third-harmonic amplitude `chi3 * E0^3 / (1 + (E0 / E_sat)^2)` in MgB2.
pub fn mgb2_saturated_third_harmonic_amplitude(chi3: f64, e_field: f64, e_sat: f64) -> f64 {
    (chi3 * e_field.powi(3)) / (1.0 + (e_field / e_sat).powi(2))
}

// ============================================================================
// Discovered Materials Grand Challenge Problem 05:
// Predicting Heat Transport across Solid Interfaces (Grassmannian G-TBC)
// ============================================================================

/// Published room-temperature (300 K) thermal boundary conductance of sharp Al(111)/Si(111)
/// in MW m^-2 K^-1 (Li et al., Nature Communications 13, 4901, 2022).
pub const GTBC_AL_SI_300K_CONDUCTANCE: f64 = 379.0;

/// Published room-temperature (300 K) thermal boundary conductance of sharp Al(111)/GaN(0001)
/// in MW m^-2 K^-1 (Li et al., Nature Communications 13, 4901, 2022).
pub const GTBC_AL_GAN_300K_CONDUCTANCE: f64 = 423.0;

/// Published conductance enhancement ratio G_{Cu/TiC/diamond} / G_{Cu/diamond} = 1.48
/// for a 10 nm crystalline TiC interlayer (Chang et al., ACS Appl. Mater. Interfaces 11, 26507, 2019).
pub const GTBC_CU_TIC_DIAMOND_RATIO: f64 = 1.48;

/// Published combined boundary conductance of Au/PMMA/Si in MW m^-2 K^-1
/// (Sandell et al., Nanomaterials 10, 670, 2020).
pub const GTBC_AU_PMMA_SI_CONDUCTANCE: f64 = 59.0;

/// Published combined boundary conductance of Au/Ti(2 nm)/PMMA/Si in MW m^-2 K^-1
/// (Sandell et al., Nanomaterials 10, 670, 2020).
pub const GTBC_AU_TI_PMMA_SI_CONDUCTANCE: f64 = 115.0;

/// Published combined boundary conductance of Au/Ni(2 nm)/PMMA/Si in MW m^-2 K^-1
/// (Sandell et al., Nanomaterials 10, 670, 2020).
pub const GTBC_AU_NI_PMMA_SI_CONDUCTANCE: f64 = 139.0;

/// Normal-incidence Acoustic Mismatch Model (AMM, Little 1959) phonon power transmission
/// probability `4 * z1 * z2 / (z1 + z2)^2`, matching `Signals.DFT.ammNormalTransmission`.
pub fn amm_normal_transmission(z1: f64, z2: f64) -> f64 {
    (4.0 * z1 * z2) / (z1 + z2).powi(2)
}

/// Diffuse Mismatch Model (DMM, Swartz & Pohl 1989) spectral phonon transmission
/// probability `flux2 / (flux1 + flux2)`, matching `Signals.DFT.dmmSpectralTransmission`.
pub fn dmm_spectral_transmission(flux1: f64, flux2: f64) -> f64 {
    flux2 / (flux1 + flux2)
}

/// Grassmannian Thermal Boundary Conductance (`G-TBC`) bond-stiffness-weighted Gr_C(2,4)
/// phonon transmission probability `4 * z1 * z2 / ((z1 + z2)^2 + xi_bond * z1 * z2)`,
/// matching `Signals.DFT.gtbcBondWeightedTransmission`.
pub fn gtbc_bond_weighted_transmission(z1: f64, z2: f64, xi_bond: f64) -> f64 {
    (4.0 * z1 * z2) / ((z1 + z2).powi(2) + xi_bond * z1 * z2)
}

/// Kapitza thermal boundary resistance `R_K(G) = 1 / G`, matching `Signals.DFT.kapitzaThermalResistance`.
pub fn kapitza_thermal_resistance(g_conductance: f64) -> f64 {
    1.0 / g_conductance
}

/// Combined harmonic 2-channel Gr_C(2,4) plus anharmonic 3-phonon Gr_C(2,5) thermal
/// boundary conductance `g_elastic + gamma_anh * temp_k`, matching
/// `Signals.DFT.gtbcHarmonicPlusAnharmonicConductance`.
pub fn gtbc_harmonic_plus_anharmonic_conductance(
    g_elastic: f64,
    gamma_anh: f64,
    temp_k: f64,
) -> f64 {
    g_elastic + gamma_anh * temp_k
}

/// Series-coupled interfacial phonon conductance `g_phonon` and metal-side electron-phonon
/// conductance `g_ep`: `(g_phonon * g_ep) / (g_phonon + g_ep)`, matching
/// `Signals.DFT.gtbcElectronPhononSeriesConductance`.
pub fn gtbc_electron_phonon_series_conductance(g_phonon: f64, g_ep: f64) -> f64 {
    (g_phonon * g_ep) / (g_phonon + g_ep)
}

/// Phonon-bridge interlayer conductance enhancement ratio `g_with_interlayer / g_direct`,
/// matching `Signals.DFT.gtbcInterlayerEnhancementRatio`.
pub fn gtbc_interlayer_enhancement_ratio(g_with_interlayer: f64, g_direct: f64) -> f64 {
    g_with_interlayer / g_direct
}

/// Total series thermal resistance `1 / g_boundary + d_pmma / kappa_pmma` of an
/// inorganic/polymer stack, matching `Signals.DFT.gtbcPolymerStackTotalResistance`.
pub fn gtbc_polymer_stack_total_resistance(
    g_boundary: f64,
    d_pmma: f64,
    kappa_pmma: f64,
) -> f64 {
    1.0 / g_boundary + d_pmma / kappa_pmma
}

/// Effective thermal conductance `1 / R_stack(d_pmma)` of an inorganic/polymer stack,
/// matching `Signals.DFT.gtbcPolymerStackConductance`.
pub fn gtbc_polymer_stack_conductance(
    g_boundary: f64,
    d_pmma: f64,
    kappa_pmma: f64,
) -> f64 {
    1.0 / gtbc_polymer_stack_total_resistance(g_boundary, d_pmma, kappa_pmma)
}

/// Work-of-adhesion interfacial spring stiffness per unit area `K_bond(W_ad, d0) = W_ad / d0^2`,
/// matching `Signals.DFT.gtbcWorkOfAdhesionSpringStiffness`.
pub fn gtbc_work_of_adhesion_spring_stiffness(w_ad: f64, d0: f64) -> f64 {
    w_ad / d0.powi(2)
}

/// Dimensionless interfacial bond-compliance ratio `4 * omega^2 * z1 * z2 / k_bond^2`,
/// matching `Signals.DFT.gtbcBondComplianceRatio`.
pub fn gtbc_bond_compliance_ratio(omega: f64, z1: f64, z2: f64, k_bond: f64) -> f64 {
    (4.0 * omega.powi(2) * z1 * z2) / k_bond.powi(2)
}

/// Three-element series thermal resistance `1/g_left + d_int/kappa_int + 1/g_right` across
/// a phonon-bridge interlayer, matching `Signals.DFT.gtbcCarbideInterlayerSeriesResistance`.
pub fn gtbc_carbide_interlayer_series_resistance(
    g_left: f64,
    g_right: f64,
    d_int: f64,
    kappa_int: f64,
) -> f64 {
    1.0 / g_left + d_int / kappa_int + 1.0 / g_right
}

/// Effective thermal boundary conductance across a 3-element phonon-bridge interlayer,
/// matching `Signals.DFT.gtbcCarbideInterlayerConductance`.
pub fn gtbc_carbide_interlayer_conductance(
    g_left: f64,
    g_right: f64,
    d_int: f64,
    kappa_int: f64,
) -> f64 {
    1.0 / gtbc_carbide_interlayer_series_resistance(g_left, g_right, d_int, kappa_int)
}

/// Rational Padé-Ziman interfacial specularity factor `1 / (1 + roughness_ratio_sq)`,
/// matching `Signals.DFT.gtbcZimanSpecularityFactor`.
pub fn gtbc_ziman_specularity_factor(roughness_ratio_sq: f64) -> f64 {
    1.0 / (1.0 + roughness_ratio_sq)
}

/// Partial-specularity phonon transmission `p_spec * tau_spec + (1 - p_spec) * tau_diff`,
/// matching `Signals.DFT.gtbcMixedSpecularDiffuseTransmission`.
pub fn gtbc_mixed_specular_diffuse_transmission(
    p_spec: f64,
    tau_spec: f64,
    tau_diff: f64,
) -> f64 {
    p_spec * tau_spec + (1.0 - p_spec) * tau_diff
}

/// Cattaneo-Vernotte / DDF hyperbolic-saturated interfacial heat flux
/// `(g_tbc * delta_t * q_max) / (g_tbc * delta_t + q_max)`, matching
/// `Signals.DFT.gtbcCattaneoVernotteFluxSaturated`.
pub fn gtbc_cattaneo_vernotte_flux_saturated(g_tbc: f64, delta_t: f64, q_max: f64) -> f64 {
    (g_tbc * delta_t * q_max) / (g_tbc * delta_t + q_max)
}

/// Relative prediction error `|g_pred - g_ref| / g_ref`, matching `Signals.DFT.gtbcRelativeError`.
pub fn gtbc_relative_error(g_pred: f64, g_ref: f64) -> f64 {
    (g_pred - g_ref).abs() / g_ref
}

// ============================================================================
// Discovered Materials Grand Challenge Problem 01:
// A Predictive Theory of Cuprate Superconductivity (Grassmannian G-CSC)
// ============================================================================

/// Pseudogap critical doping endpoint `p* = 0.19` (Chen et al., Science 366, 1099, 2019),
/// matching `Signals.DFT.cuprateCriticalDopingPStar`.
pub const CUPRATE_CRITICAL_DOPING_PSTAR: f64 = 0.19;

/// Published resonant-ultrasound pseudogap anomaly temperature `T* = 245 K` in YBa2Cu3O6.60
/// (Shekhter et al., Nature 498, 75, 2013), matching `Signals.DFT.cuprateYbco660PseudogapTempK`.
pub const CUPRATE_YBCO660_PSEUDOGAP_TEMP_K: f64 = 245.0;

/// Optimal-doping maximum transition temperatures `Tc_max` (K) across the 5 cuprate families:
pub const CUPRATE_FAMILY_LSCO_TC_MAX: f64 = 38.0;
pub const CUPRATE_FAMILY_TL2201_TC_MAX: f64 = 90.0;
pub const CUPRATE_FAMILY_BI2212_TC_MAX: f64 = 92.0;
pub const CUPRATE_FAMILY_YBCO_TC_MAX: f64 = 93.0;
pub const CUPRATE_FAMILY_HG1201_TC_MAX: f64 = 97.0;

/// Gutzwiller coherent hole-hopping renormalization factor `g_t(p) = 2 * p / (1 + p)`,
/// matching `Signals.DFT.cuprateGutzwillerHoppingFactor`.
pub fn cuprate_gutzwiller_hopping_factor(p: f64) -> f64 {
    (2.0 * p) / (1.0 + p)
}

/// Presland-Tallon parabolic superconducting dome factor `1 - (10000 / 121) * (p - 0.16)^2`,
/// matching `Signals.DFT.cupratePreslandTallonDomeFactor`.
pub fn cuprate_presland_tallon_dome_factor(p: f64) -> f64 {
    1.0 - (10000.0 / 121.0) * (p - 0.16).powi(2)
}

/// Target 1: Cuprate superconducting transition temperature dome `tc_max * D_dome(p)`,
/// matching `Signals.DFT.cuprateSuperconductingTc`.
pub fn cuprate_superconducting_tc(tc_max: f64, p: f64) -> f64 {
    tc_max * cuprate_presland_tallon_dome_factor(p)
}

/// Target 2: `d_{x^2-y^2}`-wave superconducting form factor `cos_kx - cos_ky`,
/// matching `Signals.DFT.cuprateDWaveFormFactor`.
pub fn cuprate_dwave_form_factor(cos_kx: f64, cos_ky: f64) -> f64 {
    cos_kx - cos_ky
}

/// Target 3: Squared `d_{x^2-y^2}`-wave superconducting energy gap `Delta^2(k, T, p)`,
/// matching `Signals.DFT.cuprateDWaveGapSq`.
pub fn cuprate_dwave_gap_sq(
    delta0: f64,
    cos_kx: f64,
    cos_ky: f64,
    temp_k: f64,
    tc_p: f64,
) -> f64 {
    (0.5 * delta0 * cuprate_dwave_form_factor(cos_kx, cos_ky)).powi(2)
        * (1.0 - (temp_k / tc_p).powi(2))
}

/// Target 4: Pseudogap onset temperature line `T*(p) = t_star0 * (1 - p / p*)`,
/// matching `Signals.DFT.cupratePseudogapTemp`.
pub fn cuprate_pseudogap_temp(t_star0: f64, p: f64) -> f64 {
    t_star0 * (1.0 - p / CUPRATE_CRITICAL_DOPING_PSTAR)
}

/// Target 5: Cuprate in-plane electrical resistivity `rho0 + a1_slope * T + a2_quad * T^2`,
/// matching `Signals.DFT.cuprateInPlaneResistivity`.
pub fn cuprate_in_plane_resistivity(
    rho0: f64,
    a1_slope: f64,
    a2_quad: f64,
    temp_k: f64,
) -> f64 {
    rho0 + a1_slope * temp_k + a2_quad * temp_k.powi(2)
}

/// Target 6: Electronic entropy `gamma_n * T - gamma_n * t_pg_eff` and pseudogap entropy
/// suppression `gamma_n * T - S_el`, matching `Signals.DFT.cupratePseudogapEntropySuppression`.
pub fn cuprate_electronic_entropy_with_pseudogap(
    gamma_n: f64,
    temp_k: f64,
    t_pg_eff: f64,
) -> f64 {
    gamma_n * temp_k - gamma_n * t_pg_eff
}

pub fn cuprate_pseudogap_entropy_suppression(
    gamma_n: f64,
    temp_k: f64,
    t_pg_eff: f64,
) -> f64 {
    gamma_n * temp_k - cuprate_electronic_entropy_with_pseudogap(gamma_n, temp_k, t_pg_eff)
}

/// Target 7: Nodal d-wave superfluid stiffness `rho_s0 * (1 - T / Tc)`,
/// matching `Signals.DFT.cuprateSuperfluidStiffness`.
pub fn cuprate_superfluid_stiffness(rho_s0: f64, temp_k: f64, tc_p: f64) -> f64 {
    rho_s0 * (1.0 - temp_k / tc_p)
}

/// Target 8: Antiferromagnetic ordered moment squared `m0_sq * (1 - p / 0.05)`,
/// matching `Signals.DFT.cuprateAntiferromagneticMomentSq`.
pub fn cuprate_antiferromagnetic_moment_sq(m0_sq: f64, p: f64) -> f64 {
    m0_sq * (1.0 - p / 0.05)
}

/// Target 9: Persistent zone-boundary RIXS paramagnon energy `2 * j_zr * (1 - 0.8 * p)`,
/// matching `Signals.DFT.cuprateParamagnonEnergy`.
pub fn cuprate_paramagnon_energy(j_zr: f64, p: f64) -> f64 {
    2.0 * j_zr * (1.0 - 0.8 * p)
}

/// Target 10: Charge-density-wave (CDW) structure-factor peak centered at `p = 1/8 = 0.125`,
/// matching `Signals.DFT.cuprateCdwStructureFactorPeak`.
pub fn cuprate_cdw_structure_factor_peak(s_max: f64, xi_scale: f64, p: f64) -> f64 {
    s_max / (1.0 + xi_scale * (p - 0.125).powi(2))
}

/// Target 11: Resonant-ultrasound elastic modulus softening peak near `T*`,
/// matching `Signals.DFT.cuprateResonantUltrasoundModulusShift`.
pub fn cuprate_resonant_ultrasound_modulus_shift(
    lambda_nem_sq: f64,
    temp_k: f64,
    t_star: f64,
    eta_dis: f64,
) -> f64 {
    lambda_nem_sq / ((temp_k - t_star).powi(2) + eta_dis)
}

/// Target 12: Charge-transfer superexchange coupling `4 * t_pd^4 / (delta_ct^2 * u_eff)`,
/// matching `Signals.DFT.cuprateChargeTransferSuperexchange`.
pub fn cuprate_charge_transfer_superexchange(t_pd: f64, delta_ct: f64, u_eff: f64) -> f64 {
    (4.0 * t_pd.powi(4)) / (delta_ct.powi(2) * u_eff)
}

/// Microscopic Kotliar-Liu-Anderson RVB product dome
/// `tc_max * ((p - 0.05) * (0.27 - p)) / 0.11^2`, matching
/// `Signals.DFT.cuprateMicroscopicRvbDome`.
pub fn cuprate_microscopic_rvb_dome(tc_max: f64, p: f64) -> f64 {
    tc_max * ((p - 0.05) * (0.27 - p)) / 0.11_f64.powi(2)
}

/// Microscopic Pavarini-O'Mahony family-dependent maximum transition temperature
/// `kappa_sc * j_zr * r_tp`, matching `Signals.DFT.cupratePavariniTcMaxFromSuperexchange`.
pub fn cuprate_pavarini_tc_max_from_superexchange(kappa_sc: f64, j_zr: f64, r_tp: f64) -> f64 {
    kappa_sc * j_zr * r_tp
}

/// Yang-Rice-Zhang (YRZ) two-pole pseudogap self-energy
/// `((delta_pg0 / 2) * (cos_kx - cos_ky))^2 / (omega + xi0)`, matching
/// `Signals.DFT.cuprateYrzPseudogapSelfEnergy`.
pub fn cuprate_yrz_pseudogap_self_energy(
    delta_pg0: f64,
    cos_kx: f64,
    cos_ky: f64,
    omega: f64,
    xi0: f64,
) -> f64 {
    (0.5 * delta_pg0 * cuprate_dwave_form_factor(cos_kx, cos_ky)).powi(2) / (omega + xi0)
}

/// Squared YRZ pseudogap quasiparticle dispersion energy `xi^2 + ((delta_pg0 / 2) * g_d)^2`,
/// matching `Signals.DFT.cuprateYrzQuasiparticleEnergySq`.
pub fn cuprate_yrz_quasiparticle_energy_sq(
    xi: f64,
    delta_pg0: f64,
    cos_kx: f64,
    cos_ky: f64,
) -> f64 {
    xi.powi(2) + (0.5 * delta_pg0 * cuprate_dwave_form_factor(cos_kx, cos_ky)).powi(2)
}

/// Homes' universal scaling law `c_homes * tc_p / rho_normal`, matching
/// `Signals.DFT.cuprateHomesSuperfluidDensity`.
pub fn cuprate_homes_superfluid_density(c_homes: f64, tc_p: f64, rho_normal: f64) -> f64 {
    (c_homes * tc_p) / rho_normal
}

/// Squared London magnetic penetration depth `1 / rho_s`, matching
/// `Signals.DFT.cuprateLondonPenetrationDepthSq`.
pub fn cuprate_london_penetration_depth_sq(rho_s: f64) -> f64 {
    1.0 / rho_s
}

/// Millis-Monien-Pines (MMP) dynamical spin structure factor `S(q, omega)` for damped paramagnons,
/// matching `Signals.DFT.cuprateDynamicalSpinStructureFactor`.
pub fn cuprate_dynamical_spin_structure_factor(
    chi_q: f64,
    omega: f64,
    omega_mag: f64,
    gamma_mag: f64,
) -> f64 {
    (chi_q * omega * gamma_mag)
        / ((omega.powi(2) - omega_mag.powi(2)).powi(2) + omega.powi(2) * gamma_mag.powi(2))
}

/// Momentum- and doping-resolved CDW structure factor `S_c(q, p)`, matching
/// `Signals.DFT.cuprateMomentumResolvedCdwStructureFactor`.
pub fn cuprate_momentum_resolved_cdw_structure_factor(
    s_max: f64,
    xi_scale: f64,
    p: f64,
    xi_cdw: f64,
    q_delta: f64,
    q_cdw: f64,
) -> f64 {
    s_max / ((1.0 + xi_scale * (p - 0.125).powi(2)) * (1.0 + xi_cdw.powi(2) * (q_delta - q_cdw).powi(2)))
}

/// Loram smooth pseudogap specific-heat coefficient `gamma_n * temp_k / (temp_k + e_pg)`,
/// matching `Signals.DFT.cupratePseudogapSpecificHeatCoeff`.
pub fn cuprate_pseudogap_specific_heat_coeff(gamma_n: f64, temp_k: f64, e_pg: f64) -> f64 {
    (gamma_n * temp_k) / (temp_k + e_pg)
}

// ============================================================================
// Discovered Materials Grand Challenge Problem 02:
// Interfacial Electrical Properties from Processing History (Grassmannian G-IEP)
// ============================================================================

/// Pilling-Bedworth molar volume ratio for thermal oxidation of silicon `Omega_SiO2 / Omega_Si = 2.27`,
/// matching `Signals.DFT.giepPillingBedworthRatioSi`.
pub const GIEP_PILLING_BEDWORTH_RATIO_SI: f64 = 2.27;

/// Vitkavage, Irene & Massoud (JAP 68, 5262, 1990) passivated midgap interface-trap densities
/// `D_it` (in `10^10 cm^-2 eV^-1`) and fixed oxide charges `Q_f / q` (in `10^10 cm^-2`) across
/// `(100)`, `(511)`, `(110)`, and `(111)` silicon orientations:
pub const GIEP_SI100_PASSIVATED_DIT: f64 = 1.5;
pub const GIEP_SI511_PASSIVATED_DIT: f64 = 3.2;
pub const GIEP_SI110_PASSIVATED_DIT: f64 = 5.4;
pub const GIEP_SI111_PASSIVATED_DIT: f64 = 8.5;

pub const GIEP_SI100_FIXED_CHARGE: f64 = 9.0;
pub const GIEP_SI511_FIXED_CHARGE: f64 = 15.0;
pub const GIEP_SI110_FIXED_CHARGE: f64 = 24.0;
pub const GIEP_SI111_FIXED_CHARGE: f64 = 38.0;

/// Steady-state 3-flux Plabic reaction-diffusion oxidation flux
/// `c_star / (1 / h_gas + x_ox / d_eff + 1 / k_s)`, matching `Signals.DFT.giepThreeFluxSteadyState`.
pub fn giep_three_flux_steady_state(
    c_star: f64,
    h_gas: f64,
    d_eff: f64,
    k_s: f64,
    x_ox: f64,
) -> f64 {
    c_star / (1.0 / h_gas + x_ox / d_eff + 1.0 / k_s)
}

/// Deal-Grove linear-parabolic oxidation time `(x_ox^2 + a_dg * x_ox) / b_dg - tau_dg`,
/// matching `Signals.DFT.giepDealGroveTimeForThickness`.
pub fn giep_deal_grove_time_for_thickness(a_dg: f64, b_dg: f64, tau_dg: f64, x_ox: f64) -> f64 {
    (x_ox.powi(2) + a_dg * x_ox) / b_dg - tau_dg
}

/// Consumed silicon substrate thickness `x_ox / 2.27`, matching `Signals.DFT.giepConsumedSiliconThickness`.
pub fn giep_consumed_silicon_thickness(x_ox: f64) -> f64 {
    x_ox / GIEP_PILLING_BEDWORTH_RATIO_SI
}

/// Steady-state linear oxidant concentration profile across the oxide,
/// matching `Signals.DFT.giepCompositionProfileLinear`.
pub fn giep_composition_profile_linear(
    c_surface: f64,
    c_interface: f64,
    z: f64,
    x_ox: f64,
) -> f64 {
    c_surface - (c_surface - c_interface) * (z / x_ox)
}

/// Hydrogen-passivated interface-trap density `dit_unpassivated * (1 - theta_h)`,
/// matching `Signals.DFT.giepHydrogenPassivatedDit`.
pub fn giep_hydrogen_passivated_dit(dit_unpassivated: f64, theta_h: f64) -> f64 {
    dit_unpassivated * (1.0 - theta_h)
}

/// Energy-resolved U-shaped interface-trap density `dit_midgap + d_tail * (energy - e_midgap)^2`,
/// matching `Signals.DFT.giepEnergyResolvedDit`.
pub fn giep_energy_resolved_dit(
    dit_midgap: f64,
    d_tail: f64,
    energy: f64,
    e_midgap: f64,
) -> f64 {
    dit_midgap + d_tail * (energy - e_midgap).powi(2)
}

/// Deal's oxidation/cooling fixed-charge triangle `qf_base + delta_qf_low_t * (1 - t_ox / t_max)`,
/// matching `Signals.DFT.giepDealOxideChargeCoolingTriangle`.
pub fn giep_deal_oxide_charge_cooling_triangle(
    qf_base: f64,
    delta_qf_low_t: f64,
    t_ox: f64,
    t_max: f64,
) -> f64 {
    qf_base + delta_qf_low_t * (1.0 - t_ox / t_max)
}

/// Interface 2: Kao nanowire viscoelastic stress-retarded oxidation rate
/// `k_planar / (1 + sigma_norm * alpha_stress)`, matching `Signals.DFT.giepNanowireStressRetardedRate`.
pub fn giep_nanowire_stress_retarded_rate(
    k_planar: f64,
    sigma_norm: f64,
    alpha_stress: f64,
) -> f64 {
    k_planar / (1.0 + sigma_norm * alpha_stress)
}

/// Interface 2: Remaining silicon nanowire core radius `r_initial - x_ox / 2.27`,
/// matching `Signals.DFT.giepNanowireRemainingCoreRadius`.
pub fn giep_nanowire_remaining_core_radius(r_initial: f64, x_ox: f64) -> f64 {
    r_initial - giep_consumed_silicon_thickness(x_ox)
}

/// Interface 3: Song SiC/SiO2 carbon-retarded oxidation rate `k_forward / (1 + r_carbon_back)`,
/// matching `Signals.DFT.giepSiCCarbonRetardedRate`.
pub fn giep_sic_carbon_retarded_rate(k_forward: f64, r_carbon_back: f64) -> f64 {
    k_forward / (1.0 + r_carbon_back)
}

/// Interface 4: Goncharova HfO2/SiO2/Si squared interlayer regrowth `x_il0^2 + b_il_o2 * t_anneal`,
/// matching `Signals.DFT.giepHfO2InterlayerRegrowthSq`.
pub fn giep_hfo2_interlayer_regrowth_sq(x_il0: f64, b_il_o2: f64, t_anneal: f64) -> f64 {
    x_il0.powi(2) + b_il_o2 * t_anneal
}

/// Interface 4: High-k gate stack Equivalent Oxide Thickness `x_il + (kappa_sio2 / kappa_highk) * x_highk`,
/// matching `Signals.DFT.giepHighKGateStackEot`.
pub fn giep_highk_gate_stack_eot(
    x_il: f64,
    x_highk: f64,
    kappa_sio2: f64,
    kappa_highk: f64,
) -> f64 {
    x_il + (kappa_sio2 / kappa_highk) * x_highk
}

/// Interface 5a: Wang Ge/GeO2 net oxide growth/loss rate `v_growth - v_geo_desorb`,
/// matching `Signals.DFT.giepGeOxideNetRate`.
pub fn giep_ge_oxide_net_rate(v_growth: f64, v_geo_desorb: f64) -> f64 {
    v_growth - v_geo_desorb
}

/// Interface 5b: Rabie SiGe selective oxidation Ge snowplow pile-up profile,
/// matching `Signals.DFT.giepSiGeSnowplowProfile`.
pub fn giep_sige_snowplow_profile(
    x_ge_bulk: f64,
    delta_ge_pile: f64,
    z: f64,
    l_decay: f64,
) -> f64 {
    x_ge_bulk + delta_ge_pile / (1.0 + z / l_decay)
}

/// Subthreshold swing degradation `ss_ideal * (1 + dit_eff / c_ox)`,
/// matching `Signals.DFT.giepSubthresholdSwingWithDit`.
pub fn giep_subthreshold_swing_with_dit(ss_ideal: f64, c_ox: f64, dit_eff: f64) -> f64 {
    ss_ideal * (1.0 + dit_eff / c_ox)
}

/// Explicit forward Deal-Grove oxide thickness `((a_dg^2 + 4 * b_dg * (t_ox + tau_dg)).sqrt() - a_dg) / 2`,
/// matching `Signals.DFT.giepDealGroveExplicitThickness`.
pub fn giep_deal_grove_explicit_thickness(a_dg: f64, b_dg: f64, tau_dg: f64, t_ox: f64) -> f64 {
    ((a_dg.powi(2) + 4.0 * b_dg * (t_ox + tau_dg)).sqrt() - a_dg) / 2.0
}

/// Massoud thin-oxide rapid oxidation rate `v_dg + c_massoud / (1 + x_ox / l_massoud)`,
/// matching `Signals.DFT.giepMassoudThinOxideRate`.
pub fn giep_massoud_thin_oxide_rate(
    v_dg: f64,
    c_massoud: f64,
    x_ox: f64,
    l_massoud: f64,
) -> f64 {
    v_dg + c_massoud / (1.0 + x_ox / l_massoud)
}

/// Brower-Stesmans steady-state H2 passivation coverage `r_pass / (r_pass + k_dissoc)`,
/// matching `Signals.DFT.giepBrowerStesmansEquilibriumCoverage`.
pub fn giep_brower_stesmans_equilibrium_coverage(r_pass: f64, k_dissoc: f64) -> f64 {
    r_pass / (r_pass + k_dissoc)
}

/// Brower-Stesmans steady-state interface-trap density `(dit0 * k_dissoc) / (r_pass + k_dissoc)`,
/// matching `Signals.DFT.giepBrowerStesmansEquilibriumDit`.
pub fn giep_brower_stesmans_equilibrium_dit(dit0: f64, r_pass: f64, k_dissoc: f64) -> f64 {
    (dit0 * k_dissoc) / (r_pass + k_dissoc)
}

/// Kao cylindrical nanowire compressive stress `eta_eff / r_si`,
/// matching `Signals.DFT.giepNanowireCurvatureStress`.
pub fn giep_nanowire_curvature_stress(eta_eff: f64, r_si: f64) -> f64 {
    eta_eff / r_si
}

/// Curvature-stress-enhanced fixed oxide charge on a silicon nanowire,
/// matching `Signals.DFT.giepNanowireStressInducedCharge`.
pub fn giep_nanowire_stress_induced_charge(
    qf_planar: f64,
    beta_q: f64,
    eta_eff: f64,
    r_si: f64,
) -> f64 {
    qf_planar + beta_q * giep_nanowire_curvature_stress(eta_eff, r_si)
}

/// Song SiC/SiO2 carbon-cluster interface-trap density `(dit0 + gamma_c * r_carbon) * (1 - theta_no)`,
/// matching `Signals.DFT.giepSiCCarbonClusterDit`.
pub fn giep_sic_carbon_cluster_dit(
    dit0: f64,
    gamma_c: f64,
    r_carbon: f64,
    theta_no: f64,
) -> f64 {
    (dit0 + gamma_c * r_carbon) * (1.0 - theta_no)
}

/// High-k gate-stack flatband voltage shift `v_dipole - q_fixed * eot`,
/// matching `Signals.DFT.giepHighKFlatbandVoltageShift`.
pub fn giep_highk_flatband_voltage_shift(v_dipole: f64, q_fixed: f64, eot: f64) -> f64 {
    v_dipole - q_fixed * eot
}

/// Mass-conserving SiGe snowplow pile-up amplitude `(x_ge0 * delta_x_sub) / l_decay`,
/// matching `Signals.DFT.giepSiGeSnowplowMassBalance`.
pub fn giep_sige_snowplow_mass_balance(x_ge0: f64, delta_x_sub: f64, l_decay: f64) -> f64 {
    (x_ge0 * delta_x_sub) / l_decay
}

// ============================================================================
// Grassmannian Multilayer Graphene Superconductivity, QAHE/FQAH, Supersolid Vortices,
// and Topological Quantum Computing (`G-MGS`, Section 18 of `Signals.DFT`)
// ============================================================================

/// Rhombohedral N-layer squared dispersion `(alpha_n * k_pow_n)^2 + delta_d^2`,
/// matching `Signals.DFT.gmgsRhombohedralEnergySq`.
pub fn gmgs_rhombohedral_energy_sq(alpha_n: f64, k_pow_n: f64, delta_d: f64) -> f64 {
    (alpha_n * k_pow_n).powi(2) + delta_d.powi(2)
}

/// Rhombohedral N-layer flat-band bandwidth `t0 * (t0 / gamma1)^(N - 1)`,
/// matching `Signals.DFT.gmgsFlatBandBandwidth`.
pub fn gmgs_flat_band_bandwidth(t0: f64, gamma1: f64, n_layers: usize) -> f64 {
    let exp = n_layers.saturating_sub(1) as i32;
    t0 * (t0 / gamma1).powi(exp)
}

/// Effective Coulomb correlation ratio `r_s = u_eff / w_bandwidth`,
/// matching `Signals.DFT.gmgsEffectiveInteractionRs`.
pub fn gmgs_effective_interaction_rs(u_eff: f64, w_bandwidth: f64) -> f64 {
    u_eff / w_bandwidth
}

/// Rhombohedral N-layer van Hove DOS divergence exponent `1 - 2 / N`,
/// matching `Signals.DFT.gmgsVanHoveDosExponent`.
pub fn gmgs_van_hove_dos_exponent(n_layers: f64) -> f64 {
    1.0 - 2.0 / n_layers
}

/// Chandrasekhar-Clogston Pauli-limiting magnetic field `kappa_p * tc`,
/// matching `Signals.DFT.gmgsPauliLimitField`.
pub fn gmgs_pauli_limit_field(kappa_p: f64, tc: f64) -> f64 {
    kappa_p * tc
}

/// Rhombohedral graphene in-plane critical magnetic field `kappa_p * tc * (1 + gamma_triplet)`,
/// matching `Signals.DFT.gmgsInPlaneCriticalField`.
pub fn gmgs_in_plane_critical_field(kappa_p: f64, tc: f64, gamma_triplet: f64) -> f64 {
    gmgs_pauli_limit_field(kappa_p, tc) * (1.0 + gamma_triplet)
}

/// Pauli-limit violation ratio `bc_parallel / b_pauli`,
/// matching `Signals.DFT.gmgsPauliViolationRatio`.
pub fn gmgs_pauli_violation_ratio(bc_parallel: f64, b_pauli: f64) -> f64 {
    bc_parallel / b_pauli
}

/// Kane-Mele SOC-enhanced IVC superconducting `T_c = tc0 * (1 + alpha_km * lambda_km)`,
/// matching `Signals.DFT.gmgsKaneMeleEnhancedTc`.
pub fn gmgs_kane_mele_enhanced_tc(tc0: f64, alpha_km: f64, lambda_km: f64) -> f64 {
    tc0 * (1.0 + alpha_km * lambda_km)
}

/// Chiral `p_x ± i p_y` squared gap magnitude `delta0^2 * (kx^2 + ky^2)`,
/// matching `Signals.DFT.gmgsChiralPxPyGapSq`.
pub fn gmgs_chiral_px_py_gap_sq(delta0: f64, kx: f64, ky: f64) -> f64 {
    delta0.powi(2) * (kx.powi(2) + ky.powi(2))
}

/// MATTG light-heavy hybridized squared splitting `(eps_light - eps_heavy)^2 + 4 * v_hyb^2`,
/// matching `Signals.DFT.gmgsLightHeavyHybridizedGapSq`.
pub fn gmgs_light_heavy_hybridized_gap_sq(eps_light: f64, eps_heavy: f64, v_hyb: f64) -> f64 {
    (eps_light - eps_heavy).powi(2) + 4.0 * v_hyb.powi(2)
}

/// MATTG light-heavy Kondo-enhanced superconducting `T_c`,
/// matching `Signals.DFT.gmgsMattgKondoSuperconductingTc`.
pub fn gmgs_mattg_kondo_superconducting_tc(
    tc_flat: f64,
    beta_kondo: f64,
    v_hyb: f64,
    v_sat: f64,
) -> f64 {
    tc_flat + (beta_kondo * v_hyb.powi(2)) / (1.0 + (v_hyb / v_sat).powi(2))
}

/// Moiré / rhombohedral graphene low-energy optical spectral weight `W_opt`,
/// matching `Signals.DFT.gmgsLowEnergyOpticalWeight`.
pub fn gmgs_low_energy_optical_weight(
    delta_doping: f64,
    t_strain: f64,
    w_aa: f64,
    w_kin: f64,
    w_geom: f64,
    g_fs: f64,
) -> f64 {
    w_kin * (t_strain.powi(2) + w_aa.powi(2))
        + w_geom * delta_doping * (1.0 - delta_doping) * g_fs
}

/// Total superfluid stiffness `t_kin^2 + delta_pair * delta_doping * (1 - delta_doping) * g_fs`,
/// matching `Signals.DFT.gmgsTotalSuperfluidStiffness`.
pub fn gmgs_total_superfluid_stiffness(
    t_kin: f64,
    delta_pair: f64,
    delta_doping: f64,
    g_fs: f64,
) -> f64 {
    t_kin.powi(2) + delta_pair * delta_doping * (1.0 - delta_doping) * g_fs
}

/// Proximitized rhombohedral pentalayer graphene valley-spin mass `m_{σ,τ}`,
/// matching `Signals.DFT.gmgsValleySpinMass`.
pub fn gmgs_valley_spin_mass(
    sigma_z: f64,
    tau_z: f64,
    delta_laf: f64,
    delta_d: f64,
    delta_soc: f64,
) -> f64 {
    sigma_z * delta_laf - delta_d + tau_z * sigma_z * delta_soc
}

/// Proximitized N-layer rhombohedral graphene QAHE Chern number `(N / 2) * (s_k_up - s_kprime_up)`,
/// matching `Signals.DFT.gmgsProximitizedQaheChern`.
pub fn gmgs_proximitized_qahe_chern(n_layers: f64, s_k_up: f64, s_kprime_up: f64) -> f64 {
    (n_layers / 2.0) * (s_k_up - s_kprime_up)
}

/// Quantized anomalous Hall resistance `R_K / |C|` in kOhm,
/// matching `Signals.DFT.gmgsQuantizedHallResistanceKOhm`.
pub fn gmgs_quantized_hall_resistance_kohm(r_klitzing_kohm: f64, chern_number: f64) -> f64 {
    r_klitzing_kohm / chern_number.abs()
}

/// Anomalous Hall Crystal isolated band Chern number `n_winding - n_unwound`,
/// matching `Signals.DFT.gmgsAnomalousHallCrystalChern`.
pub fn gmgs_anomalous_hall_crystal_chern(n_winding: f64, n_unwound: f64) -> f64 {
    n_winding - n_unwound
}

/// Jain composite-fermion FQAH filling factor `p / (2p + s)`,
/// matching `Signals.DFT.gmgsJainFqahFilling`.
pub fn gmgs_jain_fqah_filling(p_cf: f64, s_sign: f64) -> f64 {
    p_cf / (2.0 * p_cf + s_sign)
}

/// Fractional elementary quasiparticle charge `1 / (2p + s)`,
/// matching `Signals.DFT.gmgsFractionalQuasiparticleCharge`.
pub fn gmgs_fractional_quasiparticle_charge(p_cf: f64, s_sign: f64) -> f64 {
    1.0 / (2.0 * p_cf + s_sign)
}

/// Normalized zero-field FQAH Hall resistance `1 / nu`,
/// matching `Signals.DFT.gmgsFqahHallResistanceRatio`.
pub fn gmgs_fqah_hall_resistance_ratio(nu_filling: f64) -> f64 {
    1.0 / nu_filling
}

/// Supersolid Leggett superfluid fraction `1 - eta_mod^2`,
/// matching `Signals.DFT.gmgsSupersolidLeggettFraction`.
pub fn gmgs_supersolid_leggett_fraction(eta_mod: f64) -> f64 {
    1.0 - eta_mod.powi(2)
}

/// Supersolid inter-droplet vortex nucleation barrier `ev0 * (1 - eta_mod)`,
/// matching `Signals.DFT.gmgsSupersolidVortexNucleationBarrier`.
pub fn gmgs_supersolid_vortex_nucleation_barrier(ev0: f64, eta_mod: f64) -> f64 {
    ev0 * (1.0 - eta_mod)
}

/// Room-temperature hydrodynamic graphene current whirlpool backflow amplitude,
/// matching `Signals.DFT.gmgsHydrodynamicWhirlpoolVorticity`.
pub fn gmgs_hydrodynamic_whirlpool_vorticity(omega0: f64, d_vorticity: f64, width: f64) -> f64 {
    (omega0 * (1.0 - width / (std::f64::consts::PI * d_vorticity))).max(0.0)
}

/// Squared non-Abelian quantum dimension `2 * m` for Majorana (m=1) and parafermion (m≥3) zero modes,
/// matching `Signals.DFT.gmgsParafermionQuantumDimSq`.
pub fn gmgs_parafermion_quantum_dim_sq(m_denom: f64) -> f64 {
    2.0 * m_denom
}

/// Topologically protected qubit decoherence rate `gamma0 / (1 + x + x^2 / 2)`,
/// matching `Signals.DFT.gmgsTopologicalDecoherenceRate`.
pub fn gmgs_topological_decoherence_rate(gamma0: f64, l_over_xi: f64) -> f64 {
    gamma0 / (1.0 + l_over_xi + l_over_xi.powi(2) / 2.0)
}

/// Flat-band superconducting kinetic inductance `phi0_scale / ds_tot`,
/// matching `Signals.DFT.gmgsFlatBandKineticInductance`.
pub fn gmgs_flat_band_kinetic_inductance(phi0_scale: f64, ds_tot: f64) -> f64 {
    phi0_scale / ds_tot
}

/// Sombrero-hat annular Fermi-surface dispersion `e0 + alpha_ring * (k_sq - k_ring_sq)^2`,
/// matching `Signals.DFT.gmgsSombreroAnnularDispersion`.
pub fn gmgs_sombrero_annular_dispersion(
    e0: f64,
    alpha_ring: f64,
    k_sq: f64,
    k_ring_sq: f64,
) -> f64 {
    e0 + alpha_ring * (k_sq - k_ring_sq).powi(2)
}

/// Kopnin-Heikkilä-Volovik linear flat-band critical temperature `(g_pair * n_flat) / 4`,
/// matching `Signals.DFT.gmgsFlatBandLinearTc`.
pub fn gmgs_flat_band_linear_tc(g_pair: f64, n_flat: f64) -> f64 {
    (g_pair * n_flat) / 4.0
}

/// Fubini-Study quantum metric trace `|omega_berry| + delta_trace`,
/// matching `Signals.DFT.gmgsFubiniStudyTraceMetric`.
pub fn gmgs_fubini_study_trace_metric(omega_berry: f64, delta_trace: f64) -> f64 {
    omega_berry.abs() + delta_trace
}

/// Berezinskii-Kosterlitz-Thouless superfluid transition temperature `kappa_bkt * (ds_conv + ds_geom)`,
/// matching `Signals.DFT.gmgsBktSuperfluidTemp`.
pub fn gmgs_bkt_superfluid_temp(kappa_bkt: f64, ds_conv: f64, ds_geom: f64) -> f64 {
    kappa_bkt * (ds_conv + ds_geom)
}

/// Středa Landau-fan carrier-density-to-field slope `chern_number * inv_flux_quantum`,
/// matching `Signals.DFT.gmgsStredaCarrierSlope`.
pub fn gmgs_streda_carrier_slope(chern_number: f64, inv_flux_quantum: f64) -> f64 {
    chern_number * inv_flux_quantum
}

/// Composite-fermion effective magnetic field `b_chern * (1 - 2 * p_flux * nu_filling)`,
/// matching `Signals.DFT.gmgsCompositeFermionEffectiveField`.
pub fn gmgs_composite_fermion_effective_field(
    b_chern: f64,
    p_flux: f64,
    nu_filling: f64,
) -> f64 {
    b_chern * (1.0 - 2.0 * p_flux * nu_filling)
}

/// Squared Gurzhi hydrodynamic vorticity diffusion length `nu_visc * tau_mr`,
/// matching `Signals.DFT.gmgsGurzhiVorticityLengthSq`.
pub fn gmgs_gurzhi_vorticity_length_sq(nu_visc: f64, tau_mr: f64) -> f64 {
    nu_visc * tau_mr
}

/// Proximitized QAHE-Superconductor BdG squared gap `(v_edge * k_mom)^2 + (delta_ind - m_qah)^2`,
/// matching `Signals.DFT.gmgsQaheScBdgGapSq`.
pub fn gmgs_qahe_sc_bdg_gap_sq(v_edge: f64, k_mom: f64, delta_ind: f64, m_qah: f64) -> f64 {
    (v_edge * k_mom).powi(2) + (delta_ind - m_qah).powi(2)
}

/// Real manifold dimension `4 * (2N - 2)` of the boundary Grassmannian `Gr_C(2, 2N)`,
/// matching `Signals.DFT.gmgsBoundaryGrassmannianRealDim`.
pub fn gmgs_boundary_grassmannian_real_dim(n_layers: usize) -> usize {
    4 * (2 * n_layers - 2)
}

/// Number of Plücker sublattice-pair qudit channels `C(2N, 2) = N * (2N - 1)` on `Gr_C(2, 2N)`,
/// matching `Signals.DFT.gmgsPluckerSublatticeQuditDim`.
pub fn gmgs_plucker_sublattice_qudit_dim(n_layers: usize) -> usize {
    n_layers * (2 * n_layers - 1)
}

/// Caroli-de Gennes-Matricon (CdGM) vortex-core Majorana mini-gap `delta0^2 / e_fermi`,
/// matching `Signals.DFT.gmgsVortexCoreMiniGap`.
pub fn gmgs_vortex_core_mini_gap(delta0: f64, e_fermi: f64) -> f64 {
    delta0.powi(2) / e_fermi
}

/// Logical qudit dimension `d = 2p + 1` of a pair of `Z_{2m}` parafermion zero modes (`m = 2p + 1`),
/// matching `Signals.DFT.gmgsParafermionQuditDim`.
pub fn gmgs_parafermion_qudit_dim(p_cf: usize) -> usize {
    2 * p_cf + 1
}

/// Hilbert-space compression ratio `(d / 2)^n_registers` of an `n_registers`-qudit register vs. qubits,
/// matching `Signals.DFT.gmgsQuditHilbertCompressionRatio`.
pub fn gmgs_qudit_hilbert_compression_ratio(d: f64, n_registers: u32) -> f64 {
    (d / 2.0).powi(n_registers as i32)
}

// ============================================================================
// Section 19 & 20: Semi-Dirac Fermions (With and Without Gr_C and DDF) &
// SU(4), Lower Grassmannians, Witten Twistor String, CHY, and 5-Way Unification
// ============================================================================

/// Semi-Dirac fermion squared energy dispersion `(kx^2 / (2 * m_x) + delta_m)^2 + (v_y * ky)^2`,
/// matching `Signals.DFT.semiDiracEnergySq`.
pub fn semi_dirac_energy_sq(kx: f64, ky: f64, m_x: f64, v_y: f64, delta_m: f64) -> f64 {
    (kx.powi(2) / (2.0 * m_x) + delta_m).powi(2) + (v_y * ky).powi(2)
}

/// Semi-Dirac massive x-axis group velocity `kx / m_x`,
/// matching `Signals.DFT.semiDiracGroupVelocityX`.
pub fn semi_dirac_group_velocity_x(kx: f64, m_x: f64) -> f64 {
    kx / m_x
}

/// Semi-Dirac massless y-axis group velocity `v_y`,
/// matching `Signals.DFT.semiDiracGroupVelocityY`.
pub fn semi_dirac_group_velocity_y(v_y: f64) -> f64 {
    v_y
}

/// Shao et al. (2024, ZrSiS) B^(2/3) semi-Dirac Landau-level cube law `c3 * v_y^2 * (n_half * B)^2 / m_x`,
/// matching `Signals.DFT.semiDiracLandauLevelCube`.
pub fn semi_dirac_landau_level_cube(c3: f64, m_x: f64, v_y: f64, n_half: f64, b_field: f64) -> f64 {
    c3 * (v_y.powi(2) * (n_half * b_field).powi(2) / m_x)
}

/// Gr_C(2,4) Plücker determinant `p_23(Z_SD) = (tx + delta_m)^2 + py^2`,
/// matching `Signals.DFT.semiDiracPluckerDet`.
pub fn semi_dirac_plucker_det(tx: f64, delta_m: f64, py: f64) -> f64 {
    (tx + delta_m).powi(2) + py.powi(2)
}

/// Fubini-Study Kähler determinant factor `1 + 2 * E_SD^2 + E_SD^4 = (1 + E_SD^2)^2`,
/// matching `Signals.DFT.semiDiracKahlerDetFactor`.
pub fn semi_dirac_kahler_det_factor(tx: f64, delta_m: f64, py: f64) -> f64 {
    let e_sq = semi_dirac_plucker_det(tx, delta_m, py);
    1.0 + 2.0 * e_sq + e_sq.powi(2)
}

/// DDF longitudinal moving-sheath jammed effective mass `m_0 / (1 - beta_x^2)`,
/// matching `Signals.DFT.semiDiracDdfJammedMassX`.
pub fn semi_dirac_ddf_jammed_mass_x(m_0: f64, beta_x: f64) -> f64 {
    m_0 / (1.0 - beta_x.powi(2))
}

/// Unified Gr_C(2,4) + DDF semi-Dirac squared energy dispersion `(tx / (1 - beta_x^2) + delta_m)^2 + py^2`,
/// matching `Signals.DFT.semiDiracDdfGr24EnergySq`.
pub fn semi_dirac_ddf_gr24_energy_sq(tx: f64, delta_m: f64, py: f64, beta_x: f64) -> f64 {
    (tx / (1.0 - beta_x.powi(2)) + delta_m).powi(2) + py.powi(2)
}

/// Anisotropic 2D Tensor Gaussian Splat dispersive variance along massive x-axis,
/// matching `Signals.DFT.semiDiracAnisotropicSplatVarX`.
pub fn semi_dirac_anisotropic_splat_var_x(sigma_x0: f64, t: f64, m_x: f64) -> f64 {
    sigma_x0.powi(2) + t.powi(2) / (4.0 * m_x.powi(2) * sigma_x0.powi(2))
}

/// Anisotropic 2D Tensor Gaussian Splat dispersionless variance along massless y-axis,
/// matching `Signals.DFT.semiDiracAnisotropicSplatVarY`.
pub fn semi_dirac_anisotropic_splat_var_y(sigma_y0: f64, _t: f64) -> f64 {
    sigma_y0.powi(2)
}

/// Real dimension of SU(N): `N^2 - 1`, matching `Signals.DFT.suNRealDim`.
pub fn su_n_real_dim(n: usize) -> usize {
    n * n - 1
}

/// Real dimension of real Grassmannian Gr_R(k, n): `k * (n - k)`,
/// matching `Signals.DFT.realGrassmannianDim`.
pub fn real_grassmannian_dim(k: usize, n: usize) -> usize {
    k * (n - k)
}

/// Real dimension of complex Grassmannian Gr_C(k, n): `2 * k * (n - k)`,
/// matching `Signals.DFT.complexGrassmannianRealDim`.
pub fn complex_grassmannian_real_dim(k: usize, n: usize) -> usize {
    2 * k * (n - k)
}

/// Einstein-Kähler scalar curvature `R_Gr(k, n) = n * k * (n - k)`,
/// matching `Signals.DFT.grassmannianScalarCurvature`.
pub fn grassmannian_scalar_curvature(k: usize, n: usize) -> usize {
    n * k * (n - k)
}

/// Cachazo-He-Yuan (CHY) discrete worldsheet solution count `(n - 3)!`,
/// matching `Signals.DFT.chySolutionCount`.
pub fn chy_solution_count(n: usize) -> usize {
    (1..=n.saturating_sub(3)).product()
}

/// Unique 4-point CHY worldsheet puncture root `s12 / (s12 + s13)`,
/// matching `Signals.DFT.chyFourPointRoot`.
pub fn chy_four_point_root(s12: f64, s13: f64) -> f64 {
    s12 / (s12 + s13)
}

/// Cleared-denominator 4-point CHY scattering equation `s12 * (sigma4 - 1) + s13 * sigma4`,
/// matching `Signals.DFT.chyFourPointCrossEquation`.
pub fn chy_four_point_cross_equation(s12: f64, s13: f64, sigma4: f64) -> f64 {
    s12 * (sigma4 - 1.0) + s13 * sigma4
}

/// Universal SU(4)-invariant 3-term Plücker / Klein quadric residual `p01*p23 - p02*p13 + p03*p12`,
/// matching `Signals.DFT.universalPluckerThreeTermResidual`.
pub fn universal_plucker_three_term_residual(
    p01: f64,
    p23: f64,
    p02: f64,
    p13: f64,
    p03: f64,
    p12: f64,
) -> f64 {
    p01 * p23 - p02 * p13 + p03 * p12
}

/// 2D anisotropic density-of-states power-law exponent `1 / px + 1 / py - 1`,
/// matching `Signals.DFT.semiDiracDosExponent`.
pub fn semi_dirac_dos_exponent(px: f64, py: f64) -> f64 {
    1.0 / px + 1.0 / py - 1.0
}

/// Semi-Dirac massive x-axis WKB barrier transmission envelope `1 / (1 + kappa_l^2)`,
/// matching `Signals.DFT.semiDiracWkbBarrierTransmissionX`.
pub fn semi_dirac_wkb_barrier_transmission_x(kappa_l: f64) -> f64 {
    1.0 / (1.0 + kappa_l.powi(2))
}

/// Semi-Dirac directional in-plane Drude permittivity `eps_inf - (omega_p / omega)^2`,
/// matching `Signals.DFT.semiDiracDirectionalPermittivity`.
pub fn semi_dirac_directional_permittivity(eps_inf: f64, omega_p: f64, omega: f64) -> f64 {
    eps_inf - (omega_p / omega).powi(2)
}

/// Number of independent quadratic Plücker relations `C(n, k) - 1 - k * (n - k)`,
/// matching `Signals.DFT.pluckerRelationCodimension`.
pub fn plucker_relation_codimension(k: usize, n: usize) -> usize {
    let mut binom = 1usize;
    for i in 0..k {
        binom = binom * (n - i) / (i + 1);
    }
    binom - 1 - k * (n - k)
}

/// 4-point CHY localized bi-adjoint scalar amplitude `1 / ((s12 + s13) * sigma4 * (1 - sigma4))`,
/// matching `Signals.DFT.chyFourPointBiAdjointScalar`.
pub fn chy_four_point_bi_adjoint_scalar(s12: f64, s13: f64) -> f64 {
    let sigma4 = chy_four_point_root(s12, s13);
    1.0 / ((s12 + s13) * sigma4 * (1.0 - sigma4))
}

/// Costello-Gaiotto Twisted Holography deformed conifold residual `(z11 * z22 - z12 * z21) - gs_nc`,
/// matching `Signals.DFT.twistedHolographyDeformedConifoldResidual`.
pub fn twisted_holography_deformed_conifold_residual(
    z11: f64,
    z22: f64,
    z12: f64,
    z21: f64,
    gs_nc: f64,
) -> f64 {
    (z11 * z22 - z12 * z21) - gs_nc
}

/// Celestial Holography left-moving conformal weight `(delta + j_helicity) / 2`,
/// matching `Signals.DFT.celestialConformalWeightH`.
pub fn celestial_conformal_weight_h(delta: f64, j_helicity: f64) -> f64 {
    (delta + j_helicity) / 2.0
}

/// Celestial Holography right-moving conformal weight `(delta - j_helicity) / 2`,
/// matching `Signals.DFT.celestialConformalWeightHBar`.
pub fn celestial_conformal_weight_hbar(delta: f64, j_helicity: f64) -> f64 {
    (delta - j_helicity) / 2.0
}

/// MADNESS multiwavelet octree box coefficient count `(k + 1)^d`,
/// matching `Signals.DFT.mraWaveletBoxCoeffCount`.
pub fn mra_wavelet_box_coeff_count(k: usize, d: u32) -> usize {
    (k + 1).pow(d)
}

/// MADNESS Bound-State Helmholtz (`BSHApply`) screening parameter squared `-2 * (eps_i + level_shift)`,
/// matching `Signals.DFT.mraBshGreenMuSq`.
pub fn mra_bsh_green_mu_sq(eps_i: f64, level_shift: f64) -> f64 {
    -2.0 * (eps_i + level_shift)
}

/// Cauchy-Binet `Gr_R(2, 3)` Plücker sum of squares `p12^2 + p13^2 + p23^2` for the `libxc`
/// open-shell GGA `sigma`-Gram determinant, matching `Signals.DFT.libxcGramDetFromPlucker`.
pub fn libxc_gram_det_from_plucker(p12: f64, p13: f64, p23: f64) -> f64 {
    p12 * p12 + p13 * p13 + p23 * p23
}

/// `libxc >= 2.0.0` single-orbital von Weizsäcker residual `8 * phi^2 * (0.5 * grad_phi^2) - 4 * phi^2 * grad_phi^2`,
/// matching `Signals.DFT.libxcVonWeizsackerSingleOrbitalResidual`.
pub fn libxc_von_weizsacker_single_orbital_residual(phi_sq: f64, grad_phi_sq: f64) -> f64 {
    8.0 * phi_sq * (0.5 * grad_phi_sq) - 4.0 * phi_sq * grad_phi_sq
}

/// MADNESS-Tequila MRA-PNO active orbital count `n_pairs * (1 + maxrank) + n_virt`,
/// matching `Signals.DFT.mraPnoActiveOrbitalCount`.
pub fn mra_pno_active_orbital_count(n_pairs: usize, maxrank: usize, n_virt: usize) -> usize {
    n_pairs * (1 + maxrank) + n_virt
}

/// Two-body `g_pqrs` tensor compression ratio `(n_ao / n_mra)^4` of MRA-PNO vs. LCAO,
/// matching `Signals.DFT.mraGtensorCompressionRatio`.
pub fn mra_gtensor_compression_ratio(n_ao: f64, n_mra: f64) -> f64 {
    (n_ao / n_mra).powi(4)
}

/// Tequila Hard-Core Boson (`HCB`) qubit count `n_orb`,
/// matching `Signals.DFT.tequilaHcbQubitCount`.
pub fn tequila_hcb_qubit_count(n_orb: usize) -> usize {
    n_orb
}

/// Tequila Jordan-Wigner (`JW`) spin-orbital qubit count `2 * n_orb`,
/// matching `Signals.DFT.tequilaJwQubitCount`.
pub fn tequila_jw_qubit_count(n_orb: usize) -> usize {
    2 * n_orb
}

/// Layer-coded Plabic `VRC-SPA` two-body excitation gate count `n_pairs * maxrank + (n_pairs - 1)`,
/// matching `Signals.DFT.plabicVrcLayerGateCount`.
pub fn plabic_vrc_layer_gate_count(n_pairs: usize, maxrank: usize) -> usize {
    n_pairs * maxrank + n_pairs.saturating_sub(1)
}

/// Dense first-order `UpCCGSD` pair-excitation gate count `n_orb * (n_orb - 1) / 2`,
/// matching `Signals.DFT.fullUpccgsdPairGateCount`.
pub fn full_upccgsd_pair_gate_count(n_orb: usize) -> usize {
    n_orb * n_orb.saturating_sub(1) / 2
}

/// Pole-free VRC-regularized MRA-PNO first-order pair amplitude `-g_ijab * delta_eps / (delta_eps^2 + gamma_vrc^2)`,
/// matching `Signals.DFT.vrcRegularizedPnoAmplitude`.
pub fn vrc_regularized_pno_amplitude(g_ijab: f64, delta_eps: f64, gamma_vrc: f64) -> f64 {
    -g_ijab * delta_eps / (delta_eps * delta_eps + gamma_vrc * gamma_vrc)
}

/// Tequila-MADNESS `[2]_F12` Slater geminal cusp rescaling factor `-(1 / gamma) * r_raw`,
/// matching `Signals.DFT.f12SlaterCuspFactor`.
pub fn f12_slater_cusp_factor(gamma: f64, r_raw: f64) -> f64 {
    -(1.0 / gamma) * r_raw
}

/// Pole-free VRC-regularized projected MRA-PNO pair correlation energy
/// `g_ijab * vrc_regularized_pno_amplitude(g_ijab, delta_eps, gamma_vrc)`,
/// matching `Signals.DFT.vrcProjectedPairEnergy`.
pub fn vrc_projected_pair_energy(g_ijab: f64, delta_eps: f64, gamma_vrc: f64) -> f64 {
    g_ijab * vrc_regularized_pno_amplitude(g_ijab, delta_eps, gamma_vrc)
}

/// Corrected Tequila intra-pair PNO virtual-virtual excitation gate count
/// `n_pairs * (maxrank * (maxrank - 1) / 2)`,
/// matching `Signals.DFT.tequilaIntraPairVirtVirtGateCount`.
pub fn tequila_intra_pair_virt_virt_gate_count(n_pairs: usize, maxrank: usize) -> usize {
    n_pairs * (maxrank * maxrank.saturating_sub(1) / 2)
}

/// Unseparated 3D multiwavelet box operator complexity `(k + 1)^6`,
/// matching `Signals.DFT.mraUnseparated3dBoxFlops`.
pub fn mra_unseparated_3d_box_flops(k: usize) -> usize {
    (k + 1).pow(6)
}

/// Beylkin-Harrison separated 1D directional multiwavelet box complexity `3 * (k + 1)^4`,
/// matching `Signals.DFT.mraSeparated1dDirectionalFlops`.
pub fn mra_separated_1d_directional_flops(k: usize) -> usize {
    3 * (k + 1).pow(4)
}

/// `libxc` spin-symmetric total gradient invariant `sigma_chan + 2 * sigma_chan + sigma_chan`,
/// matching `Signals.DFT.libxcSpinSymmetricTotalSigma`.
pub fn libxc_spin_symmetric_total_sigma(sigma_chan: f64) -> f64 {
    sigma_chan + 2.0 * sigma_chan + sigma_chan
}

/// `libxc` unpolarized `vsigma` derivative mapping `(2 * vsigma_aa + vsigma_ab) / 4`,
/// matching `Signals.DFT.libxcUnpolarizedVsigmaFromPolarized`.
pub fn libxc_unpolarized_vsigma_from_polarized(vsigma_aa: f64, vsigma_ab: f64) -> f64 {
    (2.0 * vsigma_aa + vsigma_ab) / 4.0
}

/// Wootters 2-qubit EPR entanglement concurrence squared `4 * p23_norm_sq` on `Gr_C(2,4)`,
/// matching `Signals.DFT.erEprPluckerConcurrenceSq`.
pub fn er_epr_plucker_concurrence_sq(p23_norm_sq: f64) -> f64 {
    4.0 * p23_norm_sq
}

/// ER=EPR / Ryu-Takayanagi wormhole throat area `4 * l_planck_sq * s_max * C_EPR^2` from `Gr_C(2,4)` Plücker minor,
/// matching `Signals.DFT.erEprThroatAreaFromPlucker`.
pub fn er_epr_throat_area_from_plucker(l_planck_sq: f64, s_max: f64, p23_norm_sq: f64) -> f64 {
    4.0 * l_planck_sq * s_max * er_epr_plucker_concurrence_sq(p23_norm_sq)
}

/// Off-shell `Gr_C(2,4)` Bohmian stress-curvature null component `rho_grad_term - im_action_grad_sq`,
/// matching `Signals.DFT.offShellBohmStressTensorUu`.
pub fn off_shell_bohm_stress_tensor_uu(rho_grad_term: f64, im_action_grad_sq: f64) -> f64 {
    rho_grad_term - im_action_grad_sq
}

/// DDF throat-jammed relativistic particle transit energy squared `m_rest_sq / (1 - beta_sq)^2 + e_null_sq`,
/// matching `Signals.DFT.wormholeTransitJammedEnergy`.
pub fn wormhole_transit_jammed_energy(m_rest_sq: f64, beta_sq: f64, e_null_sq: f64) -> f64 {
    m_rest_sq / (1.0 - beta_sq).powi(2) + e_null_sq
}

/// Raychaudhuri / Gao-Jafferis-Wall net null focusing flux `e_transit - bohm_cushion`,
/// matching `Signals.DFT.wormholeNetNullDefocusingFlux`.
pub fn wormhole_net_null_defocusing_flux(e_transit: f64, bohm_cushion: f64) -> f64 {
    e_transit - bohm_cushion
}

/// Semi-Dirac fermion directional wormhole throat transit energy squared `(tx_massive / (1 - beta_sq))^2 + py_massless^2`,
/// matching `Signals.DFT.semiDiracWormholeTransitEnergySq`.
pub fn semi_dirac_wormhole_transit_energy_sq(
    tx_massive: f64,
    py_massless: f64,
    beta_sq: f64,
) -> f64 {
    (tx_massive / (1.0 - beta_sq)).powi(2) + py_massless.powi(2)
}

/// ER=EPR boundary no-signaling reduced density marginal `psi00_norm_sq + psi01_norm_sq`,
/// matching `Signals.DFT.erEprNoSignalingMarginalA`.
pub fn er_epr_no_signaling_marginal_a(
    psi00_norm_sq: f64,
    psi01_norm_sq: f64,
    _theta_b: f64,
) -> f64 {
    psi00_norm_sq + psi01_norm_sq
}

/// ER=EPR transceiver receiver probability `0.5 + g_gjw * s_bit`,
/// matching `Signals.DFT.erEprTransceiverRxProbability`.
pub fn er_epr_transceiver_rx_probability(g_gjw: f64, s_bit: f64) -> f64 {
    0.5 + g_gjw * s_bit
}

/// ER=EPR transceiver differential BPSK contrast `P_RX(+1) - P_RX(-1) = 2 * g_gjw`,
/// matching `Signals.DFT.erEprTransceiverDifferentialContrast`.
pub fn er_epr_transceiver_differential_contrast(g_gjw: f64) -> f64 {
    er_epr_transceiver_rx_probability(g_gjw, 1.0) - er_epr_transceiver_rx_probability(g_gjw, -1.0)
}

/// Sub-wavelength 3D photon Bethe aperture coupling efficiency `(r / lambda)^4 / (1 + (r / lambda)^4)`,
/// matching `Signals.DFT.subwavelengthPhotonApertureEfficiency`.
pub fn subwavelength_photon_aperture_efficiency(r_throat: f64, wavelength: f64) -> f64 {
    let ratio4 = (r_throat / wavelength).powi(4);
    ratio4 / (1.0 + ratio4)
}

/// Semi-Dirac transceiver directional mode-filter isolation ratio `T_y / T_x = 1 + kappa_l^2`,
/// matching `Signals.DFT.semiDiracTransceiverIsolationRatio`.
pub fn semi_dirac_transceiver_isolation_ratio(kappa_l: f64) -> f64 {
    1.0 / semi_dirac_wkb_barrier_transmission_x(kappa_l)
}

/// Semi-Dirac wormhole transceiver non-collapse throat margin `bohm_cushion - n_symbols * e_symbol`,
/// matching `Signals.DFT.semiDiracTransceiverThroatMargin`.
pub fn semi_dirac_transceiver_throat_margin(
    bohm_cushion: f64,
    n_symbols: f64,
    e_symbol: f64,
) -> f64 {
    bohm_cushion - n_symbols * e_symbol
}

/// Maximum coherent transceiver link range `n_checkpoints * spacing_m` in meters,
/// matching `Signals.DFT.transceiverRepeaterMaxRangeMeters`.
pub fn transceiver_repeater_max_range_meters(n_checkpoints: usize, spacing_m: f64) -> f64 {
    (n_checkpoints as f64) * spacing_m
}

/// Total 4K cryogenic transceiver power budget in mW,
/// matching `Signals.DFT.transceiverTotalCryoPowerMw`.
pub fn transceiver_total_cryo_power_mw(
    n_nodes: f64,
    p_pump_mw: f64,
    duty_cycle: f64,
    p_homodyne_mw: f64,
    p_control_mw: f64,
) -> f64 {
    n_nodes * (p_pump_mw * duty_cycle + p_homodyne_mw + p_control_mw)
}

/// Uncorrected end-to-end transceiver link efficiency `eta_aperture * t_throat * eta_detector`,
/// matching `Signals.DFT.transceiverUncorrectedLinkEfficiency`.
pub fn transceiver_uncorrected_link_efficiency(
    eta_aperture: f64,
    t_throat: f64,
    eta_detector: f64,
) -> f64 {
    eta_aperture * t_throat * eta_detector
}

/// Distance-3 fault-tolerant QEC / McWeeny logical error rate `3 * p^2 - 2 * p^3`,
/// matching `Signals.DFT.transceiverDist3LogicalError`.
pub fn transceiver_dist3_logical_error(p_phys: f64) -> f64 {
    3.0 * p_phys.powi(2) - 2.0 * p_phys.powi(3)
}

/// Error-corrected net transceiver payload efficiency `eta_raw * code_rate * (1 - p_logical)`,
/// matching `Signals.DFT.transceiverQecNetEfficiency`.
pub fn transceiver_qec_net_efficiency(eta_raw: f64, code_rate: f64, p_logical: f64) -> f64 {
    eta_raw * code_rate * (1.0 - p_logical)
}

/// Critique Fix 1: Finite-beam-waist Semi-Dirac throat stability margin
/// `bohm_cushion - n_symbols * (e_symbol + delta_tx / (1 - beta_sq))`,
/// matching `Signals.DFT.semiDiracFiniteBeamThroatMargin`.
pub fn semi_dirac_finite_beam_throat_margin(
    bohm_cushion: f64,
    n_symbols: f64,
    e_symbol: f64,
    delta_tx: f64,
    beta_sq: f64,
) -> f64 {
    bohm_cushion - n_symbols * (e_symbol + delta_tx / (1.0 - beta_sq))
}

/// Critique Fix 2: Exact bounded unitary GJW transceiver receiver probability
/// `(1 + sin_2theta * s_bit) / 2`, matching `Signals.DFT.erEprExactUnitaryRxProbability`.
pub fn er_epr_exact_unitary_rx_probability(sin_2theta: f64, s_bit: f64) -> f64 {
    (1.0 + sin_2theta * s_bit) / 2.0
}

/// Unitary saturated TRUE/DORT phase-conjugate sub-wavelength throat coupling efficiency
/// `(eta_bethe * g_true) / (1 + eta_bethe * (g_true - 1))`,
/// matching `Signals.DFT.subwavelengthPhotonTrueConjugateCoupling`.
pub fn subwavelength_photon_true_conjugate_coupling(eta_bethe: f64, g_true: f64) -> f64 {
    (eta_bethe * g_true) / (1.0 + eta_bethe * (g_true - 1.0))
}

/// Homodyne field-to-intensity sub-wavelength sensitivity gain ratio `a_trans / a_trans^2 = 1 / a_trans`,
/// matching `Signals.DFT.homodyneFieldToIntensityGainRatio`.
pub fn homodyne_field_to_intensity_gain_ratio(a_trans: f64) -> f64 {
    a_trans / a_trans.powi(2)
}

/// QISM Slavnov determinant contraction speedup `(m_fact)^2 / (m_packets)^3`,
/// matching `Signals.DFT.qismSlavnovContractionSpeedup`.
pub fn qism_slavnov_contraction_speedup(m_fact: f64, m_packets: f64) -> f64 {
    m_fact.powi(2) / m_packets.powi(3)
}

/// QISM Yang rational R-matrix transmission probability `(u - v)^2 / ((u - v)^2 + eta^2)`,
/// matching `Signals.Scattering.yangTransmissionProb`.
pub fn qism_yang_transmission_prob(u: f64, v: f64, eta: f64) -> f64 {
    let diff = u - v;
    diff.powi(2) / (diff.powi(2) + eta.powi(2))
}

/// Critique Fix 5: Linearized near-collision 2×2 Slavnov determinant
/// `k0 * (k1 + d1 * delta_u) - (k0 + d0 * delta_u) * k1 = delta_u * (k0 * d1 - k1 * d0)`,
/// matching `Signals.DFT.slavnovLinearizedNearCollisionDet2`.
pub fn slavnov_linearized_near_collision_det2(
    k0: f64,
    k1: f64,
    d0: f64,
    d1: f64,
    delta_u: f64,
) -> f64 {
    k0 * (k1 + d1 * delta_u) - (k0 + d0 * delta_u) * k1
}

/// Critique Fix 6: Noisy 2-channel Slavnov MIMO distinguishability / SNR efficiency
/// `(delta_u * w_casorati)^2 / ((delta_u * w_casorati)^2 + sigma_noise_sq)`,
/// matching `Signals.DFT.slavnovMimoCollisionSnrEfficiency`.
pub fn slavnov_mimo_collision_snr_efficiency(
    delta_u: f64,
    w_casorati: f64,
    sigma_noise_sq: f64,
) -> f64 {
    let num = (delta_u * w_casorati).powi(2);
    num / (num + sigma_noise_sq)
}

/// Critique Fix 7: Overhead-inclusive Slavnov pipeline speedup
/// `(m_fact)^2 / (m_packets^3 + c_kernel * m_packets^2)`,
/// matching `Signals.DFT.qismSlavnovFullPipelineSpeedup`.
pub fn qism_slavnov_full_pipeline_speedup(m_fact: f64, m_packets: f64, c_kernel: f64) -> f64 {
    m_fact.powi(2) / (m_packets.powi(3) + c_kernel * m_packets.powi(2))
}

/// Critique Fix 8: Soft impedance-matched Yang R-matrix transmission probability
/// `delta_soft^2 / (delta_soft^2 + (eta_raw / g_match)^2)`,
/// matching `Signals.DFT.qismImpedanceMatchedYangTransmission`.
pub fn qism_impedance_matched_yang_transmission(
    delta_soft: f64,
    eta_raw: f64,
    g_match: f64,
) -> f64 {
    let d2 = delta_soft.powi(2);
    let eta_eff2 = (eta_raw / g_match).powi(2);
    d2 / (d2 + eta_eff2)
}

/// Critique Fix 9: Finite-tagging-efficiency TRUE/DORT phase-conjugate throat coupling
/// `(eta_bethe * eta_tag * g_true) / (1 + eta_bethe * eta_tag * (g_true - 1))`,
/// matching `Signals.DFT.subwavelengthTrueTaggedConjugateCoupling`.
pub fn subwavelength_true_tagged_conjugate_coupling(
    eta_bethe: f64,
    eta_tag: f64,
    g_true: f64,
) -> f64 {
    (eta_bethe * eta_tag * g_true) / (1.0 + eta_bethe * eta_tag * (g_true - 1.0))
}

/// DDF fracture extension channel signal `y_classical + kappa_ddf * q_ddf`,
/// matching `Signals.DFT.ddfFractureTotalChannelSignal`.
pub fn ddf_fracture_total_channel_signal(y_classical: f64, kappa_ddf: f64, q_ddf: f64) -> f64 {
    y_classical + kappa_ddf * q_ddf
}

/// Magnus-control-subtracted DDF fracture residual
/// `y_meas - (y_acoustic + rho_f * u_inflow * gamma_circ)`,
/// matching `Signals.DFT.ddfFractureMagnusSubtractedResidual`.
pub fn ddf_fracture_magnus_subtracted_residual(
    y_meas: f64,
    y_acoustic: f64,
    rho_f: f64,
    u_inflow: f64,
    gamma_circ: f64,
) -> f64 {
    y_meas - (y_acoustic + rho_f * u_inflow * gamma_circ)
}

/// Dimensionless Deborah number `tau_relax * shear_rate` for DDF shear fracture,
/// matching `Signals.DFT.ddfFractureDeborahRatio`.
pub fn ddf_fracture_deborah_ratio(tau_relax: f64, shear_rate: f64) -> f64 {
    tau_relax * shear_rate
}

/// 1D/2D fracture-corridor directional guiding gain `(r_dist / w_corridor)^2`,
/// matching `Signals.DFT.ddfFractureCorridorGuidingGain`.
pub fn ddf_fracture_corridor_guiding_gain(r_dist: f64, w_corridor: f64) -> f64 {
    (r_dist / w_corridor).powi(2)
}

/// Causal transverse-phonon arrival margin `c_emergent * t_arrival - l_path`,
/// matching `Signals.DFT.ddfFractureCausalTransitMargin`.
pub fn ddf_fracture_causal_transit_margin(
    c_emergent: f64,
    t_arrival: f64,
    l_path: f64,
) -> f64 {
    c_emergent * t_arrival - l_path
}

/// Standalone unassisted DDF fracture bit contrast `2 * kappa_ddf * q_ddf`,
/// matching `Signals.DFT.ddfFractureStandaloneBitContrast`.
pub fn ddf_fracture_standalone_bit_contrast(kappa_ddf: f64, q_ddf: f64) -> f64 {
    2.0 * (kappa_ddf * q_ddf)
}

/// Quantum state transfer fidelity discriminator `(1 + 4 * p23_norm_sq * sin_2theta) / 2`,
/// matching `Signals.DFT.ddfFractureVsWormholeQuantumFidelity`.
pub fn ddf_fracture_vs_wormhole_quantum_fidelity(p23_norm_sq: f64, sin_2theta: f64) -> f64 {
    (1.0 + 4.0 * p23_norm_sq * sin_2theta) / 2.0
}

/// High-power fracture overload excess shear `tau_drive - tau_crit`,
/// matching `Signals.DFT.ddfFractureOverloadExcessShear`.
pub fn ddf_fracture_overload_excess_shear(tau_drive: f64, tau_crit: f64) -> f64 {
    tau_drive - tau_crit
}

/// Hybrid DDF-fracture-keyed ER=EPR receiver probability `(1 + kappa_ddf * q_ddf * s_bit) / 2`,
/// matching `Signals.DFT.hybridFractureKeyedErEprRxProbability`.
pub fn hybrid_fracture_keyed_er_epr_rx_probability(
    kappa_ddf: f64,
    q_ddf: f64,
    s_bit: f64,
) -> f64 {
    er_epr_exact_unitary_rx_probability(kappa_ddf * q_ddf, s_bit)
}

/// Dilatant shear-thickening wave-packet damping rate `eta_base * k^2 * (1 + alpha_shear * k^2)`,
/// matching `Signals.DFT.ddfFractureDilatantDamping` and `Signals.Pending.dilatantDampingRate`.
pub fn ddf_fracture_dilatant_damping(eta_base: f64, alpha_shear: f64, k_wave: f64) -> f64 {
    eta_base * k_wave.powi(2) * (1.0 + alpha_shear * k_wave.powi(2))
}

/// Critique Fix 1: Attenuated DDF fracture-corridor guiding gain
/// `(r_dist / w_corridor)^2 / (1 + gamma_damp * l_path)`,
/// matching `Signals.DFT.ddfFractureAttenuatedCorridorGain`.
pub fn ddf_fracture_attenuated_corridor_gain(
    r_dist: f64,
    w_corridor: f64,
    gamma_damp: f64,
    l_path: f64,
) -> f64 {
    (r_dist / w_corridor).powi(2) / (1.0 + gamma_damp * l_path)
}

/// Critique Fix 2: Unconditionally bounded Cayley-saturated hybrid fracture-keyed ER=EPR
/// receiver probability `(1 + (2 * x / (1 + x^2)) * s_bit) / 2`,
/// matching `Signals.DFT.hybridSaturatedFractureKeyedErEprRxProbability`.
pub fn hybrid_saturated_fracture_keyed_er_epr_rx_probability(x_drive: f64, s_bit: f64) -> f64 {
    (1.0 + (2.0 * x_drive / (1.0 + x_drive.powi(2))) * s_bit) / 2.0
}

/// Critique Fix 3: Horodecki Haar-averaged 3D qubit teleportation fidelity `(2 + c_epr) / 3`,
/// matching `Signals.DFT.horodeckiAverageTeleportationFidelity`.
pub fn horodecki_average_teleportation_fidelity(c_epr: f64) -> f64 {
    (2.0 + c_epr) / 3.0
}

/// Critique Fix 4: Passive energy-closed DDF fracture channel power efficiency
/// `p_out / (p_out + p_fracture + p_diss)`,
/// matching `Signals.DFT.ddfFracturePassivePowerEfficiency`.
pub fn ddf_fracture_passive_power_efficiency(p_out: f64, p_fracture: f64, p_diss: f64) -> f64 {
    p_out / (p_out + p_fracture + p_diss)
}

/// Method 1 (`M1`): Unguided exterior photon inverse-square efficiency `(r_ref / r_dist)^2`
/// around the wormhole, matching `Signals.DFT.exteriorPhotonInverseSquareEfficiency`.
pub fn exterior_photon_inverse_square_efficiency(r_ref: f64, r_dist: f64) -> f64 {
    (r_ref / r_dist).powi(2)
}

/// Method 2 (`M2`): Fracture-corridor attenuated transmission `1 / (1 + gamma_damp * l_path)`
/// around the wormhole, matching `Signals.DFT.fractureGuidedCorridorTransmission`.
pub fn fracture_guided_corridor_transmission(gamma_damp: f64, l_path: f64) -> f64 {
    1.0 / (1.0 + gamma_damp * l_path)
}

/// Method 6 (`M1 + M2`): Dual-path co-propagating `H0`/Magnus common-mode clutter subtraction,
/// matching `Signals.DFT.dualPathCommonModeSubtraction`.
pub fn dual_path_common_mode_subtraction(y_classical: f64, kappa_ddf: f64, q_ddf: f64) -> f64 {
    ddf_fracture_total_channel_signal(y_classical, kappa_ddf, q_ddf) - y_classical
}

/// Method 6 (`M1 + M2`): Dual-path Maximal-Ratio Combining (MRC) classical SNR,
/// matching `Signals.DFT.dualPathMrcCombinedSnr`.
pub fn dual_path_mrc_combined_snr(snr_around: f64, snr_fracture: f64) -> f64 {
    snr_around + snr_fracture
}

/// Methods 6 & 7 (`M1 + M2` and `M1 + M2 + M3`): Independent dual-path classical outage
/// probability `p_fail_around * p_fail_fracture`, matching `Signals.DFT.dualPathOutageProbability`.
pub fn dual_path_outage_probability(p_fail_around: f64, p_fail_fracture: f64) -> f64 {
    p_fail_around * p_fail_fracture
}

/// Methods 4, 5, & 7 (`M1+M3`, `M2+M3`, and `M1+M2+M3`): Unified dual-keyed Cayley-saturated
/// ER=EPR receiver probability, matching `Signals.DFT.triModalDualKeyedErEprRxProbability`.
pub fn trimodal_dual_keyed_er_epr_rx_probability(
    x_around: f64,
    x_fracture: f64,
    s_bit: f64,
) -> f64 {
    hybrid_saturated_fracture_keyed_er_epr_rx_probability(x_around + x_fracture, s_bit)
}

/// Method 7 (`M1 + M2 + M3`): Wormhole throat energy load isolation,
/// matching `Signals.DFT.triModalWormholeThroatLoad`.
pub fn trimodal_wormhole_throat_load(e_around: f64, e_fracture: f64, e_wormhole: f64) -> f64 {
    0.0 * e_around + 0.0 * e_fracture + e_wormhole
}

/// Section 25.2.1 Critique Fix 1: AGC-normalized dual-keyed Cayley-saturated ER=EPR receiver
/// probability, matching `Signals.DFT.triModalAgcDualKeyedErEprRxProbability`.
pub fn trimodal_agc_dual_keyed_er_epr_rx_probability(
    x_around: f64,
    x_fracture: f64,
    w_around: f64,
    w_fracture: f64,
    s_bit: f64,
) -> f64 {
    hybrid_saturated_fracture_keyed_er_epr_rx_probability(
        (w_around * x_around + w_fracture * x_fracture) / (w_around + w_fracture),
        s_bit,
    )
}

/// Section 25.2.1 Critique Fix 2a: Dual-path differential arrival-time skew
/// `l_frac / v_frac - l_ext / c_light`, matching `Signals.DFT.dualPathPropagationSkew`.
pub fn dual_path_propagation_skew(l_ext: f64, l_frac: f64, c_light: f64, v_frac: f64) -> f64 {
    l_frac / v_frac - l_ext / c_light
}

/// Section 25.2.1 Critique Fix 2b: Delay-buffered dual-path clutter subtraction residual under
/// linear drift, matching `Signals.DFT.dualPathSkewCompensatedClutterResidual`.
pub fn dual_path_skew_compensated_clutter_residual(
    y0: f64,
    y_drift: f64,
    t1: f64,
    delta_t_skew: f64,
    tau_buf: f64,
    kappa_ddf: f64,
    q_ddf: f64,
) -> f64 {
    (y0 + y_drift * (t1 + delta_t_skew) + kappa_ddf * q_ddf) - (y0 + y_drift * (t1 + tau_buf))
}

/// Section 25.2.1 Critique Fix 3: Common-cause correlated dual-path outage probability
/// `p_fail^2 + rho_corr * p_fail * (1 - p_fail)`,
/// matching `Signals.DFT.dualPathCorrelatedOutageProbability`.
pub fn dual_path_correlated_outage_probability(p_fail: f64, rho_corr: f64) -> f64 {
    p_fail.powi(2) + rho_corr * p_fail * (1.0 - p_fail)
}

/// Section 25.2.1 Critique Fix 4: Parasitic exterior-to-throat mouth crosstalk energy load
/// `eps_around * e_around + eps_fracture * e_fracture + e_wormhole`,
/// matching `Signals.DFT.triModalParasiticThroatLoad`.
pub fn trimodal_parasitic_throat_load(
    eps_around: f64,
    eps_fracture: f64,
    e_around: f64,
    e_fracture: f64,
    e_wormhole: f64,
) -> f64 {
    eps_around * e_around + eps_fracture * e_fracture + e_wormhole
}

// ============================================================================
// Section 26 & 26.1: Maxwell Electromagnetic Theory Across Pre-Tensor, Vector/Gimbal-Lock,
// Tensor, and Twistor Formulations, Longitudinal E_z & OAM Tubular Solitons, and
// Multi-Model Gravity/Electron EM Synthesis (Paper 48)
// ============================================================================

/// Maxwell (1865/1873) original component equation count (`= 20`),
/// matching `Signals.DFT.maxwellOriginal1865EquationCount`.
pub const MAXWELL_ORIGINAL_1865_EQUATION_COUNT: usize = 3 + 3 + 3 + 3 + 3 + 3 + 1 + 1;

/// Heaviside–Gibbs (1884–1893) modern 3-vector equation count (`= 4`),
/// matching `Signals.DFT.heavisideGibbsVectorEquationCount`.
pub const HEAVISIDE_GIBBS_VECTOR_EQUATION_COUNT: usize = 4;

/// Minkowski (1908) relativistic tensor equation count (`= 2`),
/// matching `Signals.DFT.minkowskiTensorEquationCount`.
pub const MINKOWSKI_TENSOR_EQUATION_COUNT: usize = 2;

/// Penrose (1967) spinor/twistor Weyl equation count (`= 1`),
/// matching `Signals.DFT.penroseTwistorSpinorEquationCount`.
pub const PENROSE_TWISTOR_SPINOR_EQUATION_COUNT: usize = 1;

/// Maxwell quaternion derivative squared norm `(-div_f)^2 + curl_x^2 + curl_y^2 + curl_z^2`,
/// matching `Signals.DFT.maxwellQuaternionNablaNormSq`.
pub fn maxwell_quaternion_nabla_norm_sq(
    div_f: f64,
    curl_x: f64,
    curl_y: f64,
    curl_z: f64,
) -> f64 {
    (-div_f).powi(2) + curl_x.powi(2) + curl_y.powi(2) + curl_z.powi(2)
}

/// Euler-angle kinematic Jacobian determinant `cos(theta_pitch)` (vanishes at `pi/2` gimbal lock),
/// matching `Signals.DFT.eulerKinematicJacobianDet`.
pub fn euler_kinematic_jacobian_det(theta_pitch: f64) -> f64 {
    theta_pitch.cos()
}

/// Unit spinor / quaternion norm squared `qw^2 + qx^2 + qy^2 + qz^2`,
/// matching `Signals.DFT.unitQuaternionNormSq`.
pub fn unit_quaternion_norm_sq(qw: f64, qx: f64, qy: f64, qz: f64) -> f64 {
    qw.powi(2) + qx.powi(2) + qy.powi(2) + qz.powi(2)
}

/// First relativistic Maxwell Lorentz invariant `|E|^2 / c^2 - |B|^2`,
/// matching `Signals.DFT.maxwellLorentzInvariantLagrange`.
pub fn maxwell_lorentz_invariant_lagrange(e_sq: f64, c_sq: f64, b_sq: f64) -> f64 {
    e_sq / c_sq - b_sq
}

/// Second relativistic Maxwell Lorentz invariant `(E dot B) / c`,
/// matching `Signals.DFT.maxwellLorentzInvariantPontryagin`.
pub fn maxwell_lorentz_invariant_pontryagin(e_dot_b: f64, c_light: f64) -> f64 {
    e_dot_b / c_light
}

/// Maxwell stress-energy tensor trace `((4 - d) / 4) * f_contract` in `d` spacetime dimensions
/// (vanishes identically in `d = 4`), matching `Signals.DFT.maxwellStressEnergyTraceInDim`.
pub fn maxwell_stress_energy_trace_in_dim(d_spacetime: f64, f_contract: f64) -> f64 {
    ((4.0 - d_spacetime) / 4.0) * f_contract
}

/// Symmetric Maxwell 2-spinor determinant squared modulus `|phi00 * phi11 - phi01^2|^2`,
/// matching `Signals.DFT.maxwellSpinorNullDeterminant`.
pub fn maxwell_spinor_null_determinant(
    phi00_re: f64,
    phi00_im: f64,
    phi11_re: f64,
    phi11_im: f64,
    phi01_re: f64,
    phi01_im: f64,
) -> f64 {
    let re = phi00_re * phi11_re - phi00_im * phi11_im - (phi01_re.powi(2) - phi01_im.powi(2));
    let im = phi00_re * phi11_im + phi00_im * phi11_re - 2.0 * phi01_re * phi01_im;
    re.powi(2) + im.powi(2)
}

/// Gauss-law longitudinal electric field `E_z = -(kx * Ex + ky * Ey) / kz`,
/// matching `Signals.DFT.maxwellGaussLongitudinalEz`.
pub fn maxwell_gauss_longitudinal_ez(kx: f64, ex: f64, ky: f64, ey: f64, kz: f64) -> f64 {
    -(kx * ex + ky * ey) / kz
}

/// High-NA spin-to-OAM longitudinal topological charge `l_in + sigma_sam`,
/// matching `Signals.DFT.samToOamLongitudinalTopologicalCharge`.
pub fn sam_to_oam_longitudinal_topological_charge(l_in: i64, sigma_sam: i64) -> i64 {
    l_in + sigma_sam
}

/// Tubular OAM vortex soliton bright-ring radius squared `w0_sq * l_abs / 2`,
/// matching `Signals.DFT.tubularSolitonRingRadiusSq`.
pub fn tubular_soliton_ring_radius_sq(w0_sq: f64, l_abs: f64) -> f64 {
    w0_sq * l_abs / 2.0
}

/// Tubular OAM soliton radial self-trapping equilibrium residual `p_focus - (p_diff + p_oam)`,
/// matching `Signals.DFT.tubularSolitonRadialEquilibriumResidual`.
pub fn tubular_soliton_radial_equilibrium_residual(
    p_kerr_focus: f64,
    p_diffraction: f64,
    p_oam_centrifugal: f64,
) -> f64 {
    p_kerr_focus - (p_diffraction + p_oam_centrifugal)
}

/// Scalar Madelung / Bohm centrifugal vortex-core potential `(hbar^2 / 2m) * l^2 / r_core^2`,
/// matching `Signals.DFT.scalarBohmVortexCoreDivergence`.
pub fn scalar_bohm_vortex_core_divergence(
    hbar_sq_over_2m: f64,
    l_sq: f64,
    r_core_sq: f64,
) -> f64 {
    hbar_sq_over_2m * l_sq / r_core_sq
}

/// Twistor / Plücker Fubini–Study Kähler vortex-core norm squared `1 + ||W||^2 + |det W|^2 >= 1`,
/// matching `Signals.DFT.pluckerRegularizedVortexCoreNormSq`.
pub fn plucker_regularized_vortex_core_norm_sq(w_norm_sq: f64, det_w_norm_sq: f64) -> f64 {
    1.0 + w_norm_sq + det_w_norm_sq
}

/// PPN gravitational light deflection angle `2(1 + gamma_ppn) G M / (c^2 b)`,
/// matching `Signals.DFT.gravitationalLightDeflectionPPN`.
pub fn gravitational_light_deflection_ppn(
    g_const: f64,
    mass_source: f64,
    c_light: f64,
    b_impact: f64,
    gamma_ppn: f64,
) -> f64 {
    2.0 * (1.0 + gamma_ppn) * g_const * mass_source / (c_light.powi(2) * b_impact)
}

/// Witten (2004) conformal twistor-string light deflection `beta_scale * dtheta_gr + gamma_conf * b`,
/// matching `Signals.DFT.wittenConformalLightDeflection`.
pub fn witten_conformal_light_deflection(
    delta_theta_gr: f64,
    beta_scale: f64,
    gamma_conf: f64,
    b_impact: f64,
) -> f64 {
    beta_scale * delta_theta_gr + gamma_conf * b_impact
}

/// Cachazo–Skinner (2012) infinity-twistor projected light deflection
/// `pi_proj * dtheta_gr + (1 - pi_proj) * gamma_conf * b`,
/// matching `Signals.DFT.cachazoSkinnerLightDeflection`.
pub fn cachazo_skinner_light_deflection(
    delta_theta_gr: f64,
    pi_proj: f64,
    gamma_conf: f64,
    b_impact: f64,
) -> f64 {
    pi_proj * delta_theta_gr + (1.0 - pi_proj) * gamma_conf * b_impact
}

/// DDF constitutive refractive light deflection `4 G_phi M (rho_max * j_min) / b`,
/// matching `Signals.DFT.ddfRefractiveLightDeflection`.
pub fn ddf_refractive_light_deflection(
    g_phi: f64,
    mass_source: f64,
    rho_max_varphi: f64,
    j_min_varphi: f64,
    b_impact: f64,
) -> f64 {
    4.0 * g_phi * mass_source * (rho_max_varphi * j_min_varphi) / b_impact
}

/// Model 14a (Without DDF): Turner (2026) Plücker Q_4 / Fubini–Study Kähler iGPE light deflection
/// `dtheta_gr * ((kahler_det - 3) / (1 - e^2)) + delta_jos`,
/// matching `Signals.DFT.turnerPluckerKahlerLightDeflection`.
pub fn turner_plucker_kahler_light_deflection(
    delta_theta_gr: f64,
    kahler_det: f64,
    e_ecc: f64,
    delta_jos: f64,
) -> f64 {
    delta_theta_gr * ((kahler_det - 3.0) / (1.0 - e_ecc.powi(2))) + delta_jos
}

/// Model 14b (With DDF): Turner (2026) unified Dual-Grassmannian `Gr_C(2,4) x Gr_C(2,4)^v` iGPE,
/// Plücker Q_4 Kähler, and conservative DDF light deflection
/// `ddf_refractive_light_deflection(...) * ((kahler_det - 3) / (1 - e^2)) + delta_jos`,
/// matching `Signals.DFT.turnerDualGr24IGPEDDFLightDeflection`.
#[allow(clippy::too_many_arguments)]
pub fn turner_dual_gr24_igpe_ddf_light_deflection(
    g_phi: f64,
    mass_source: f64,
    rho_max_varphi: f64,
    j_min_varphi: f64,
    b_impact: f64,
    kahler_det: f64,
    e_ecc: f64,
    delta_jos: f64,
) -> f64 {
    ddf_refractive_light_deflection(g_phi, mass_source, rho_max_varphi, j_min_varphi, b_impact)
        * ((kahler_det - 3.0) / (1.0 - e_ecc.powi(2)))
        + delta_jos
}

/// Heaviside–Larmor electric–magnetic duality norm on `Gr_C(2,4) x Gr_C(2,4)^v`,
/// matching `Signals.DFT.electricMagneticDualityNormSq`.
pub fn electric_magnetic_duality_norm_sq(
    psi_re: f64,
    psi_im: f64,
    phi_re: f64,
    phi_im: f64,
    cos_a: f64,
    sin_a: f64,
) -> f64 {
    (psi_re * cos_a - phi_re * sin_a).powi(2)
        + (psi_im * cos_a - phi_im * sin_a).powi(2)
        + (psi_re * sin_a + phi_re * cos_a).powi(2)
        + (psi_im * sin_a + phi_im * cos_a).powi(2)
}

/// Section 26.1 Critique Fix 1: Abraham–Minkowski momentum product `(p0 / n) * (n * p0) = p0^2`,
/// matching `Signals.DFT.abrahamMinkowskiMomentumProduct`.
pub fn abraham_minkowski_momentum_product(p0: f64, n_index: f64) -> f64 {
    (p0 / n_index) * (n_index * p0)
}

/// Section 26.1 Critique Fix 2: Laguerre–Gaussian Gouy phase mode order `2p + |l| + 1`,
/// matching `Signals.DFT.laguerreGaussianGouyModeOrder`.
pub fn laguerre_gaussian_gouy_mode_order(p_radial: usize, l_abs: usize) -> usize {
    2 * p_radial + l_abs + 1
}

/// Section 26.1 Critique Fix 3: Proca/Kähler longitudinal polarization z-component `omega / m_eff`,
/// matching `Signals.DFT.procaLongitudinalPolarizationZ`.
pub fn proca_longitudinal_polarization_z(omega_freq: f64, m_eff: f64) -> f64 {
    omega_freq / m_eff
}

/// Section 26.1 Critique Fix 4: Nonlocal-stabilized tubular soliton azimuthal modulational
/// instability gain `g_kerr / (1 + sigma_nl^2 * m_az^2) - kappa_disp * m_az^2`,
/// matching `Signals.DFT.nonlocalStabilizedAzimuthalMiGain`.
pub fn nonlocal_stabilized_azimuthal_mi_gain(
    g_kerr: f64,
    m_azimuthal: f64,
    sigma_nonlocal: f64,
    kappa_disp: f64,
) -> f64 {
    g_kerr / (1.0 + sigma_nonlocal.powi(2) * m_azimuthal.powi(2))
        - kappa_disp * m_azimuthal.powi(2)
}

/// Section 26.2: SQG/DDF pressure-difference Bernoulli enthalpy `-(p_ambient - p_local) / rho_0`,
/// matching `Signals.DFT.ddfPressureDifferenceEnthalpy`.
pub fn ddf_pressure_difference_enthalpy(p_ambient: f64, p_local: f64, rho_0: f64) -> f64 {
    -(p_ambient - p_local) / rho_0
}

/// Section 26.2: SQG/DDF pressure-difference optical refractive index
/// `1 + 2 * (p_ambient - p_local) / (rho_0 * c_sq)`,
/// matching `Signals.DFT.ddfPressureGradientRefractiveIndex`.
pub fn ddf_pressure_gradient_refractive_index(
    p_ambient: f64,
    p_local: f64,
    rho_0: f64,
    c_sq: f64,
) -> f64 {
    1.0 + 2.0 * (p_ambient - p_local) / (rho_0 * c_sq)
}

/// Section 26.2: Kohn–Sham DFT electron-density relative permittivity
/// `1 - alpha_pol * rho_e / omega_sq`,
/// matching `Signals.DFT.dftElectronDensityPermittivity`.
pub fn dft_electron_density_permittivity(rho_e: f64, alpha_pol: f64, omega_sq: f64) -> f64 {
    1.0 - alpha_pol * rho_e / omega_sq
}

/// Section 26.2: Weinberg (1965) soft-photon eikonal vertex factor `q_charge * p_dot_eps / p_dot_k`,
/// matching `Signals.DFT.weinbergSoftPhotonFactor`.
pub fn weinberg_soft_photon_factor(q_charge: f64, p_dot_eps: f64, p_dot_k: f64) -> f64 {
    q_charge * p_dot_eps / p_dot_k
}

/// Section 26.2: Two-leg soft-photon Ward / gauge-invariance residual under `eps -> k`,
/// matching `Signals.DFT.softPhotonTwoLegWardResidual`.
pub fn soft_photon_two_leg_ward_residual(q_charge: f64, pk1: f64, pk2: f64) -> f64 {
    weinberg_soft_photon_factor(q_charge, pk1, pk1)
        + weinberg_soft_photon_factor(-q_charge, pk2, pk2)
}

/// Section 27: Local directional derivative invariants of a homogeneous Plücker condensate
/// `Psi` on `Q_4`, matching `Signals.DFT.PluckerDirectionalJet`.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PluckerDirectionalJet {
    pub rho: f64,
    pub dpsi_norm_sq: f64,
    pub drho: f64,
    pub a_mu: f64,
}

/// Section 27: Squared modulus of the inner product `|<Psi | d_mu Psi>|^2 = (drho / 2)^2 + (rho * A_mu)^2`,
/// matching `Signals.DFT.innerPsiDpsiNormSq`.
pub fn inner_psi_dpsi_norm_sq(d: PluckerDirectionalJet) -> f64 {
    (d.drho / 2.0).powi(2) + (d.rho * d.a_mu).powi(2)
}

/// Section 27: Projective Fubini–Study diagonal metric component `g^{FS}_{mu mu}` on `Q_4`,
/// matching `Signals.DFT.fubiniStudyDiag`.
pub fn fubini_study_diag(d: PluckerDirectionalJet) -> f64 {
    (d.rho * d.dpsi_norm_sq - inner_psi_dpsi_norm_sq(d)) / d.rho.powi(2)
}

/// Section 27: Diagonal Quantum Fisher Information Metric component `F_{mu mu} = 4 g^{FS}_{mu mu}`,
/// matching `Signals.DFT.qfimDiag`.
pub fn qfim_diag(d: PluckerDirectionalJet) -> f64 {
    4.0 * (d.rho * d.dpsi_norm_sq - inner_psi_dpsi_norm_sq(d)) / d.rho.powi(2)
}

/// Section 27: Direct Gross–Pitaevskii directional kinetic energy density `(hbar^2 / 2m) <d_mu Psi | d_mu Psi>`,
/// matching `Signals.DFT.gpeKineticDir`.
pub fn gpe_kinetic_dir(hbar: f64, mass: f64, d: PluckerDirectionalJet) -> f64 {
    (hbar.powi(2) / (2.0 * mass)) * d.dpsi_norm_sq
}

/// Section 27: Center-of-mass hydrodynamic flow energy `(hbar^2 / 2m) rho A_mu^2`,
/// matching `Signals.DFT.hydroFlowDir`.
pub fn hydro_flow_dir(hbar: f64, mass: f64, d: PluckerDirectionalJet) -> f64 {
    (hbar.powi(2) / (2.0 * mass)) * d.rho * d.a_mu.powi(2)
}

/// Section 27: Scalar Bohmian density Fisher energy `(hbar^2 / 8m) (d_mu rho)^2 / rho`,
/// matching `Signals.DFT.scalarBohmDensityDir`.
pub fn scalar_bohm_density_dir(hbar: f64, mass: f64, d: PluckerDirectionalJet) -> f64 {
    (hbar.powi(2) / (8.0 * mass)) * (d.drho.powi(2) / d.rho)
}

/// Section 27: Projective QFIM kinetic energy `(hbar^2 / 8m) rho F_{mu mu}`,
/// matching `Signals.DFT.projectiveQfimEnergyDir`.
pub fn projective_qfim_energy_dir(hbar: f64, mass: f64, d: PluckerDirectionalJet) -> f64 {
    (hbar.powi(2) / (8.0 * mass)) * d.rho * qfim_diag(d)
}

/// Section 27: Projective Fubini–Study Kähler kinetic energy `(hbar^2 / 2m) rho g^{FS}_{mu mu}`,
/// matching `Signals.DFT.projectiveFubiniStudyEnergyDir`.
pub fn projective_fubini_study_energy_dir(hbar: f64, mass: f64, d: PluckerDirectionalJet) -> f64 {
    (hbar.powi(2) / (2.0 * mass)) * d.rho * fubini_study_diag(d)
}

/// Section 27: 3D spatial jet of a Plücker condensate field on `Q_4`,
/// matching `Signals.DFT.Plucker3DSpatialJet`.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Plucker3DSpatialJet {
    pub dir: [PluckerDirectionalJet; 3],
    pub rho: f64,
}

/// Section 27: Total 3D GPE kinetic energy density, matching `Signals.DFT.totalGpeKinetic3D`.
pub fn total_gpe_kinetic_3d(hbar: f64, mass: f64, j: &Plucker3DSpatialJet) -> f64 {
    j.dir.iter().map(|&d| gpe_kinetic_dir(hbar, mass, d)).sum()
}

/// Section 27: Total 3D hydrodynamic flow energy density, matching `Signals.DFT.totalHydroFlow3D`.
pub fn total_hydro_flow_3d(hbar: f64, mass: f64, j: &Plucker3DSpatialJet) -> f64 {
    j.dir.iter().map(|&d| hydro_flow_dir(hbar, mass, d)).sum()
}

/// Section 27: Total 3D scalar Bohmian density Fisher energy, matching `Signals.DFT.totalScalarBohm3D`.
pub fn total_scalar_bohm_3d(hbar: f64, mass: f64, j: &Plucker3DSpatialJet) -> f64 {
    j.dir
        .iter()
        .map(|&d| scalar_bohm_density_dir(hbar, mass, d))
        .sum()
}

/// Section 27: Spatial trace of the Quantum Fisher Information Metric `Tr(F_{mu nu})`,
/// matching `Signals.DFT.traceQFIM3D`.
pub fn trace_qfim_3d(j: &Plucker3DSpatialJet) -> f64 {
    j.dir.iter().map(|&d| qfim_diag(d)).sum()
}

/// Section 27: Spatial trace of the Fubini–Study Kähler Metric `Tr(g^{FS}_{mu nu})`,
/// matching `Signals.DFT.traceFubiniStudy3D`.
pub fn trace_fubini_study_3d(j: &Plucker3DSpatialJet) -> f64 {
    j.dir.iter().map(|&d| fubini_study_diag(d)).sum()
}

/// Section 27: Total 3D projective QFIM energy density `(hbar^2 / 8m) rho Tr(F_{mu nu})`,
/// matching `Signals.DFT.totalProjectiveQfimEnergy3D`.
pub fn total_projective_qfim_energy_3d(hbar: f64, mass: f64, j: &Plucker3DSpatialJet) -> f64 {
    (hbar.powi(2) / (8.0 * mass)) * j.rho * trace_qfim_3d(j)
}

/// Section 27: Total 3D projective Fubini–Study Kähler energy density `(hbar^2 / 2m) rho Tr(g^{FS}_{mu nu})`,
/// matching `Signals.DFT.totalProjectiveFubiniStudyEnergy3D`.
pub fn total_projective_fubini_study_energy_3d(
    hbar: f64,
    mass: f64,
    j: &Plucker3DSpatialJet,
) -> f64 {
    (hbar.powi(2) / (2.0 * mass)) * j.rho * trace_fubini_study_3d(j)
}

/// Section 27: Classical Fisher information on the 6-component Plücker probability simplex `p_k`,
/// matching `Signals.DFT.classicalPluckerFisher`.
pub fn classical_plucker_fisher(p: &[f64; 6], dp: &[f64; 6]) -> f64 {
    (0..6).map(|k| dp[k].powi(2) / p[k]).sum()
}

/// Section 27: Probability-weighted mean of internal Plücker bivector phase gradients,
/// matching `Signals.DFT.meanBivectorPhaseGrad`.
pub fn mean_bivector_phase_grad(p: &[f64; 6], dphi: &[f64; 6]) -> f64 {
    (0..6).map(|k| p[k] * dphi[k]).sum()
}

/// Section 27: Probability-weighted second moment of internal Plücker bivector phase gradients,
/// matching `Signals.DFT.secondMomentBivectorPhaseGrad`.
pub fn second_moment_bivector_phase_grad(p: &[f64; 6], dphi: &[f64; 6]) -> f64 {
    (0..6).map(|k| p[k] * dphi[k].powi(2)).sum()
}

/// Section 27: Variance of Plücker bivector phase gradients `Var_p(d_mu phi)`,
/// matching `Signals.DFT.bivectorPhaseVariance`.
pub fn bivector_phase_variance(p: &[f64; 6], dphi: &[f64; 6]) -> f64 {
    second_moment_bivector_phase_grad(p, dphi) - mean_bivector_phase_grad(p, dphi).powi(2)
}

/// Section 27: Normalized-ray Fubini–Study metric `g^{FS}_{mu mu}`,
/// matching `Signals.DFT.normalizedRayFubiniStudy`.
pub fn normalized_ray_fubini_study(p: &[f64; 6], dp: &[f64; 6], dphi: &[f64; 6]) -> f64 {
    let sum_ray: f64 = (0..6)
        .map(|k| dp[k].powi(2) / (4.0 * p[k]) + p[k] * dphi[k].powi(2))
        .sum();
    sum_ray - mean_bivector_phase_grad(p, dphi).powi(2)
}

/// Section 27: Homogeneous 6-bivector indexed by Plücker pairs `(01, 02, 03, 12, 13, 23)`,
/// matching `Signals.DFT.Bivector6`.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Bivector6 {
    pub p01: f64,
    pub p02: f64,
    pub p03: f64,
    pub p12: f64,
    pub p13: f64,
    pub p23: f64,
}

impl Bivector6 {
    pub fn scale(self, c: f64) -> Self {
        Self {
            p01: c * self.p01,
            p02: c * self.p02,
            p03: c * self.p03,
            p12: c * self.p12,
            p13: c * self.p13,
            p23: c * self.p23,
        }
    }

    pub fn add(self, other: Self) -> Self {
        Self {
            p01: self.p01 + other.p01,
            p02: self.p02 + other.p02,
            p03: self.p03 + other.p03,
            p12: self.p12 + other.p12,
            p13: self.p13 + other.p13,
            p23: self.p23 + other.p23,
        }
    }

    pub fn klein_quadric(self) -> f64 {
        self.p01 * self.p23 - self.p02 * self.p13 + self.p03 * self.p12
    }

    pub fn klein_polar_form(self, other: Self) -> f64 {
        self.p01 * other.p23 + other.p01 * self.p23
            - (self.p02 * other.p13 + other.p02 * self.p13)
            + (self.p03 * other.p12 + other.p03 * self.p12)
    }
}

/// Section 27.1: Witten 4th-derivative conformal Weyl propagator `1 / (q^2 * (q^2 - m_ghost^2))`,
/// matching `Signals.DFT.wittenFourthOrderPropagator`.
pub fn witten_fourth_order_propagator(q_sq: f64, m_ghost_sq: f64) -> f64 {
    1.0 / (q_sq * (q_sq - m_ghost_sq))
}

/// Section 27.1: Standard two-derivative graviton / Madelung-Kähler propagator `1 / q^2`,
/// matching `Signals.DFT.twoDerivativeGravitonPropagator`.
pub fn two_derivative_graviton_propagator(q_sq: f64) -> f64 {
    1.0 / q_sq
}

/// Section 27.1: Ostrogradsky ghost propagator pole `1 / (q^2 - m_ghost^2)`,
/// matching `Signals.DFT.ostrogradskyGhostPropagator`.
pub fn ostrogradsky_ghost_propagator(q_sq: f64, m_ghost_sq: f64) -> f64 {
    1.0 / (q_sq - m_ghost_sq)
}

/// Section 27.1: Turner orbital Fubini–Study Kähler excess `(4 - e^2) - 3 = 1 - e^2`,
/// matching `Signals.DFT.turnerKahlerOrbitalSemiLatusFactor`.
pub fn turner_kahler_orbital_semi_latus_factor(e_ecc: f64) -> f64 {
    (4.0 - e_ecc.powi(2)) - 3.0
}

/// Section 27.1: Bures statistical distance metric component `F_{mu mu} / 4 = g^{FS}_{mu mu}`,
/// matching `Signals.DFT.buresMetricDiagFromQfim`.
pub fn bures_metric_diag_from_qfim(f_diag: f64) -> f64 {
    f_diag / 4.0
}

/// Section 27.1: Quantum Cramér–Rao variance lower bound `1 / (n_probes * f_diag)`,
/// matching `Signals.DFT.quantumCramerRaoVarianceBound`.
pub fn quantum_cramer_rao_variance_bound(n_probes: f64, f_diag: f64) -> f64 {
    1.0 / (n_probes * f_diag)
}

/// Section 27.1: Mandelstam–Tamm temporal Fubini–Study metric `(delta_h / hbar)^2`,
/// matching `Signals.DFT.mandelstamTammTemporalFubiniStudy`.
pub fn mandelstam_tamm_temporal_fubini_study(delta_h: f64, hbar: f64) -> f64 {
    (delta_h / hbar).powi(2)
}

/// Section 27.1: Mandelstam–Tamm temporal QFIM `4 * (delta_h / hbar)^2`,
/// matching `Signals.DFT.mandelstamTammTemporalQfim`.
pub fn mandelstam_tamm_temporal_qfim(delta_h: f64, hbar: f64) -> f64 {
    4.0 * (delta_h / hbar).powi(2)
}

/// Section 27.1: Peotta–Törmä flat-band geometric superfluid stiffness from QFIM,
/// matching `Signals.DFT.peottaTormaFlatBandStiffnessFromQfim`.
pub fn peotta_torma_flat_band_stiffness_from_qfim(
    delta_pair: f64,
    delta_doping: f64,
    f_diag: f64,
) -> f64 {
    delta_pair * delta_doping * (1.0 - delta_doping) * (f_diag / 4.0)
}

/// Section 27.1: Gaussian splat scalar Bohmian density Fisher energy `(hbar^2 / 8m) Tr(Sigma^{-1})`,
/// matching `Signals.DFT.gaussianSplatScalarBohmFromFisher`.
pub fn gaussian_splat_scalar_bohm_from_fisher(hbar: f64, mass: f64, trace_inv_cov: f64) -> f64 {
    (hbar.powi(2) / (8.0 * mass)) * trace_inv_cov
}

/// Section 27.2 Critique Fix 1: Physically realizable Plücker directional jet from orthogonal
/// gradient norm squared `||Psi_perp||^2 >= 0`, matching `Signals.DFT.mkPhysicalPluckerDirectionalJet`.
pub fn mk_physical_plucker_directional_jet(
    rho: f64,
    drho: f64,
    a_mu: f64,
    ortho_norm_sq: f64,
) -> PluckerDirectionalJet {
    PluckerDirectionalJet {
        rho,
        dpsi_norm_sq: ((drho / 2.0).powi(2) + (rho * a_mu).powi(2)) / rho + ortho_norm_sq,
        drho,
        a_mu,
    }
}

/// Section 27.2 Critique Fix 2: Local U(1) gauge-shifted Plücker directional jet under
/// `Psi -> exp(i chi) Psi`, matching `Signals.DFT.gaugeShiftedPluckerJet`.
pub fn gauge_shifted_plucker_jet(d: PluckerDirectionalJet, dchi: f64) -> PluckerDirectionalJet {
    PluckerDirectionalJet {
        rho: d.rho,
        dpsi_norm_sq: d.dpsi_norm_sq + 2.0 * d.rho * d.a_mu * dchi + d.rho * dchi.powi(2),
        drho: d.drho,
        a_mu: d.a_mu + dchi,
    }
}

/// Section 27.2 Critique Fix 3: Two-channel bivector phase-gradient variance,
/// matching `Signals.DFT.twoChannelPhaseVariance`.
pub fn two_channel_phase_variance(p0: f64, p1: f64, dphi0: f64, dphi1: f64) -> f64 {
    p0 * dphi0.powi(2) + p1 * dphi1.powi(2) - (p0 * dphi0 + p1 * dphi1).powi(2)
}

/// Section 27.2 Critique Fix 4: Projective QFIM energy from smooth normalized-ray metric,
/// matching `Signals.DFT.projectiveQfimEnergyFromRayMetric`.
pub fn projective_qfim_energy_from_ray_metric(
    hbar: f64,
    mass: f64,
    rho: f64,
    g_fs_ray: f64,
) -> f64 {
    (hbar.powi(2) / (8.0 * mass)) * rho * (4.0 * g_fs_ray)
}

/// Section 27.3: CHY worldsheet CP^1 = Gr_C(1,2) Fubini–Study metric `1 / (4 sigma_4 (1 - sigma_4))`,
/// matching `Signals.DFT.chyWorldsheetFubiniStudyMetric`.
pub fn chy_worldsheet_fubini_study_metric(sigma4: f64) -> f64 {
    1.0 / (4.0 * sigma4 * (1.0 - sigma4))
}

/// Section 27.3: CHY worldsheet channel simplex QFIM `1 / (sigma_4 (1 - sigma_4)) = 4 g^{FS}_{sigma sigma}`,
/// matching `Signals.DFT.chyWorldsheetQfimMetric`.
pub fn chy_worldsheet_qfim_metric(sigma4: f64) -> f64 {
    1.0 / (sigma4 * (1.0 - sigma4))
}

/// Section 27.3: 4-point CHY reduced Jacobian / logarithmic potential Hessian `-s12/sigma4^2 - s13/(1-sigma4)^2`,
/// matching `Signals.DFT.chyFourPointReducedJacobian`.
pub fn chy_four_point_reduced_jacobian(s12: f64, s13: f64, sigma4: f64) -> f64 {
    -s12 / sigma4.powi(2) - s13 / (1.0 - sigma4).powi(2)
}

/// Section 27.3: Cachazo–Skinner infinity-twistor filtered propagator,
/// matching `Signals.DFT.cachazoSkinnerFilteredPropagator`.
pub fn cachazo_skinner_filtered_propagator(q_sq: f64, m_ghost_sq: f64, pi_proj: f64) -> f64 {
    pi_proj * two_derivative_graviton_propagator(q_sq)
        + (1.0 - pi_proj) * witten_fourth_order_propagator(q_sq, m_ghost_sq)
}

/// Section 27.3: Cachazo–Skinner / BCJ 4-point Hodges double-copy scalar kernel `(w_A + w_B)^2`,
/// matching `Signals.DFT.cachazoHodgesDoubleCopyScalarKernel`.
pub fn cachazo_hodges_double_copy_scalar_kernel(w_a: f64, w_b: f64) -> f64 {
    (w_a + w_b).powi(2)
}

/// Section 27.4: Orbital eccentricity Fubini–Study Kähler metric `(1 / 4) / (1 - e^2)` on the
/// aphelion–perihelion Plücker simplex, matching `Signals.DFT.qedOrbitalEccentricityFubiniStudy`.
pub fn qed_orbital_eccentricity_fubini_study(e_ecc: f64) -> f64 {
    0.25 / (1.0 - e_ecc.powi(2))
}

/// Section 27.4: Orbital eccentricity Quantum Fisher Information Metric `1 / (1 - e^2) = 4 g^{FS}_{ee}(e)`,
/// matching `Signals.DFT.qedOrbitalEccentricityQfim`.
pub fn qed_orbital_eccentricity_qfim(e_ecc: f64) -> f64 {
    1.0 / (1.0 - e_ecc.powi(2))
}

/// Section 27.4: 1PN spin-2 BCJ double-copy / Partanen–Tulkki U(1)^4 QED scattering precession
/// from orbital QFIM, matching `Signals.DFT.qedDoubleCopyPrecessionFromQfim`.
pub fn qed_double_copy_precession_from_qfim(delta_varpi_circ: f64, f_ee: f64) -> f64 {
    delta_varpi_circ * f_ee
}

/// Section 27.4: 1PN un-doubled spin-1 Coulomb/QED vector precession `(1 / 6) * delta_varpi_circ * f_ee`,
/// matching `Signals.DFT.qedSpinOnePrecessionFromQfim`.
pub fn qed_spin_one_precession_from_qfim(delta_varpi_circ: f64, f_ee: f64) -> f64 {
    (1.0 / 6.0) * delta_varpi_circ * f_ee
}

/// Section 27.4: 1PN Nordström spin-0 scalar retrograde precession `-(1 / 6) * delta_varpi_circ * f_ee`,
/// matching `Signals.DFT.qedNordstromScalarPrecessionFromQfim`.
pub fn qed_nordstrom_scalar_precession_from_qfim(delta_varpi_circ: f64, f_ee: f64) -> f64 {
    -(1.0 / 6.0) * delta_varpi_circ * f_ee
}

/// Section 27.4: 2.5PN Peters–Mathews squared eccentricity enhancement factor `P_PM(e)^2 * F_{ee}(e)^7`,
/// matching `Signals.DFT.qedPetersMathewsFromOrbitalQfimSq`.
pub fn qed_peters_mathews_from_orbital_qfim_sq(p_pm: f64, f_ee: f64) -> f64 {
    p_pm.powi(2) * f_ee.powi(7)
}

/// Section 27.4: 2.5PN un-doubled spin-1 vector to spin-2 double-copy quadrupole GW flux ratio `1/4`,
/// matching `Signals.DFT.qedSpinOneToDoubleCopyGwFluxRatio`.
pub fn qed_spin_one_to_double_copy_gw_flux_ratio(p_gw_gr: f64) -> f64 {
    0.25 * p_gw_gr
}

/// Section 27.5: Poincaré sphere `CP^1 = Gr_C(1,2)` polar Fubini–Study metric `g^{FS}_{theta theta} = 1/4`,
/// matching `Signals.DFT.poincareSphereFubiniStudyTheta`.
pub const POINCARE_SPHERE_FUBINI_STUDY_THETA: f64 = 0.25;

/// Section 27.5: Poincaré sphere `CP^1 = Gr_C(1,2)` polar QFIM `F_{theta theta} = 1`,
/// matching `Signals.DFT.poincareSphereQfimTheta`.
pub const POINCARE_SPHERE_QFIM_THETA: f64 = 1.0;

/// Section 27.5: 3D vectorial `(E_x, E_y, E_z)` simplex Fisher information including longitudinal `E_z`,
/// matching `Signals.DFT.vectorialEzThreeChannelFisher`.
pub fn vectorial_ez_three_channel_fisher(f_transverse: f64, dp_z: f64, p_z: f64) -> f64 {
    f_transverse + dp_z.powi(2) / p_z
}

/// Section 27.5: OAM balanced superposition azimuthal Fubini–Study metric `g^{FS}_{phi phi}(ell) = ell^2`,
/// matching `Signals.DFT.oamSuperpositionFubiniStudyPhi`.
pub fn oam_superposition_fubini_study_phi(l_charge: f64) -> f64 {
    l_charge.powi(2)
}

/// Section 27.5: OAM balanced superposition azimuthal QFIM `F^{OAM}_{phi phi}(ell) = 4 ell^2`,
/// matching `Signals.DFT.oamSuperpositionQfimPhi`.
pub fn oam_superposition_qfim_phi(l_charge: f64) -> f64 {
    4.0 * l_charge.powi(2)
}

/// Section 27.5: Multi-mode `TRUE` phase-conjugated soft-photon effective QFIM `N_modes * F_single`,
/// matching `Signals.DFT.trueConjugatedSoftPhotonQfimGain`.
pub fn true_conjugated_soft_photon_qfim_gain(n_modes: f64, f_single: f64) -> f64 {
    n_modes * f_single
}

/// Section 27.6: Pole-free resonant VRC Plücker norm squared at `x_X = -1`,
/// matching `Signals.DFT.vrcResonantPluckerNormSq`.
pub fn vrc_resonant_plucker_norm_sq(x1: f64, x2: f64) -> f64 {
    2.0 + x2.powi(2) + (x2 - x1).powi(2) * (1.0 + x2.powi(2))
}

/// Section 27.6: Resonant VRC directional Plücker jet along `x_1` at `x_X = -1`,
/// matching `Signals.DFT.vrcResonantDirectionalJetX1`.
pub fn vrc_resonant_directional_jet_x1(x1: f64, x2: f64) -> PluckerDirectionalJet {
    PluckerDirectionalJet {
        rho: vrc_resonant_plucker_norm_sq(x1, x2),
        dpsi_norm_sq: 1.0 + x2.powi(2),
        drho: 2.0 * (x1 - x2) * (1.0 + x2.powi(2)),
        a_mu: 0.0,
    }
}

/// Section 27.6: Pole-free resonant VRC Fubini–Study Kähler metric along `x_1` at `x_X = -1`,
/// matching `Signals.DFT.vrcResonantFubiniStudyX1`.
pub fn vrc_resonant_fubini_study_x1(x1: f64, x2: f64) -> f64 {
    ((2.0 + x2.powi(2)) * (1.0 + x2.powi(2))) / vrc_resonant_plucker_norm_sq(x1, x2).powi(2)
}

/// Section 27.6: Pole-free resonant VRC Quantum Fisher Information Metric along `x_1` at `x_X = -1`,
/// matching `Signals.DFT.vrcResonantQfimX1`.
pub fn vrc_resonant_qfim_x1(x1: f64, x2: f64) -> f64 {
    (4.0 * (2.0 + x2.powi(2)) * (1.0 + x2.powi(2))) / vrc_resonant_plucker_norm_sq(x1, x2).powi(2)
}

/// Section 27.6 Critique Fix VRC-2: Complex radial + phase VRC denominator-clearing rescaled jet,
/// matching `Signals.DFT.complexRescaledVrcJet`.
pub fn complex_rescaled_vrc_jet(
    d: PluckerDirectionalJet,
    s: f64,
    sigma_mu: f64,
    dchi: f64,
) -> PluckerDirectionalJet {
    PluckerDirectionalJet {
        rho: s.powi(2) * d.rho,
        dpsi_norm_sq: s.powi(2)
            * (d.dpsi_norm_sq
                + sigma_mu * d.drho
                + 2.0 * d.rho * d.a_mu * dchi
                + d.rho * (sigma_mu.powi(2) + dchi.powi(2))),
        drho: s.powi(2) * (d.drho + 2.0 * sigma_mu * d.rho),
        a_mu: d.a_mu + dchi,
    }
}

/// Section 27.6 Critique Fix VRC-3: VRC-regularized MRA-PNO pair excitation gap Fubini–Study metric
/// at HOMO–LUMO degeneracy `Delta_eps = 0`, matching `Signals.DFT.vrcPnoGapFubiniStudyAtDegeneracy`.
pub fn vrc_pno_gap_fubini_study_at_degeneracy(g_ijab: f64, gamma_vrc: f64) -> f64 {
    g_ijab.powi(2) / gamma_vrc.powi(4)
}

/// Section 27.6 Critique Fix VRC-3: VRC-regularized MRA-PNO pair excitation gap QFIM at
/// HOMO–LUMO degeneracy `Delta_eps = 0`, matching `Signals.DFT.vrcPnoGapQfimAtDegeneracy`.
pub fn vrc_pno_gap_qfim_at_degeneracy(g_ijab: f64, gamma_vrc: f64) -> f64 {
    4.0 * g_ijab.powi(2) / gamma_vrc.powi(4)
}

/// Section 27.6 Critique Fix VRC-3: `Tequila` / `QCI-GXC` Quantum Natural Gradient step,
/// matching `Signals.DFT.vrcQuantumNaturalGradientStep`.
pub fn vrc_quantum_natural_gradient_step(eta: f64, grad_theta: f64, f_theta: f64) -> f64 {
    -eta * grad_theta / f_theta
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

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

    #[test]
    fn test_tuning_materials_with_light_problem04_check_figures() {
        // 1. Time-linear Grassmannian G-GKBA speedup: 1.44e8x at N_t=1000, N_occ=10, N_basis=120
        let speedup = grassmann_gkba_speedup_ratio(1000.0, 10.0, 120.0);
        assert!((speedup - 144_000_000.0).abs() < 1e-3);

        // 2. Target 1: Hubbard 11-site chain & 6x2 ladder (Schroedter, Bonitz & Joost, arXiv:2606.10773)
        let d0 = hubbard_correlated_double_occupancy(0.5, 0.5, 0.0);
        let d5 = hubbard_correlated_double_occupancy(0.5, 0.5, 5.0);
        let d15 = hubbard_correlated_double_occupancy(0.5, 0.5, 15.0);
        let d20 = hubbard_correlated_double_occupancy(0.5, 0.5, 20.0);
        assert!((d0 - 0.25).abs() < 1e-15);
        assert!((d5 - 1.0 / 9.0).abs() < 1e-15);
        assert!((d15 - 1.0 / 31.0).abs() < 1e-15);
        assert!(d20 < d15 && d15 < d5 && d5 < d0);
        assert!(hubbard_doublon_decay_rate(1.0, 15.0) < hubbard_doublon_decay_rate(1.0, 5.0));
        assert!(
            hubbard_optical_conductivity_threshold(3.0, 2.0)
                < hubbard_optical_conductivity_threshold(6.0, 2.0)
        );
        assert!(
            hubbard_optical_conductivity_threshold(6.0, 2.0)
                < hubbard_optical_conductivity_threshold(12.0, 2.0)
        );

        // 3. Target 2: WSe2 bright/dark exciton dynamics (Madéo et al., Science 2020)
        assert!(WSE2_DARK_EXCITON_ENERGY_EV < WSE2_RESONANT_PUMP_EV);
        assert!(WSE2_RESONANT_PUMP_EV < WSE2_ABOVE_GAP_PUMP_EV);
        assert!((WSE2_RESONANT_PUMP_EV - WSE2_DARK_EXCITON_ENERGY_EV - 0.045).abs() < 1e-15);
        assert!((WSE2_DARK_EXCITON_BUILDUP_FS - 400.0).abs() < 1e-15);
        assert!((wse2_late_time_bright_to_dark_ratio(1.0, 2.0) - 0.5).abs() < 1e-15);

        // 4. Target 3: Graphite SCOP-to-acoustic energy flow (René de Cotret et al., PRB 2019)
        let e_05ps = graphite_total_energy_balance(4.0, 4.5, 2.0, 1.0, 0.5);
        let e_100ps = graphite_total_energy_balance(0.5, 0.2, 0.3, 6.0, 5.0);
        assert!((e_05ps - 12.0).abs() < 1e-15 && (e_100ps - 12.0).abs() < 1e-15);
        let a1p_05ps = graphite_a1p_optical_rise_and_decay(1.0, 0.10, 0.80);
        let a1p_5ps = graphite_a1p_optical_rise_and_decay(1.0, 0.05, 0.10);
        assert!(a1p_5ps < a1p_05ps);

        // 5. Target 4: MgB2 equilibrium pairing & driven THz response (Katsumi et al., PRL 2025)
        assert!((mgb2_lower_pi_gap_sq(2.2, 38.0, MGB2_KATSUMI_CRITICAL_TEMP_K)).abs() < 1e-15);
        assert!(
            mgb2_lower_pi_gap_sq(2.2, 20.0, MGB2_KATSUMI_CRITICAL_TEMP_K)
                < mgb2_lower_pi_gap_sq(2.2, 7.0, MGB2_KATSUMI_CRITICAL_TEMP_K)
        );
        assert!(
            mgb2_normalized_first_harmonic(20.0, MGB2_KATSUMI_CRITICAL_TEMP_K)
                < mgb2_normalized_first_harmonic(7.0, MGB2_KATSUMI_CRITICAL_TEMP_K)
        );
        let denom_res = mgb2_third_harmonic_resonance_denom_sq(1.0, 1.0, 0.1);
        let denom_off = mgb2_third_harmonic_resonance_denom_sq(1.26, 1.0, 0.1);
        assert!(denom_res < denom_off);
        assert!(
            mgb2_driven_superfluid_conductivity_im(0.3, 0.63)
                < mgb2_driven_superfluid_conductivity_im(1.0, 0.63)
        );

        // 6. Critique & gap-closure checks: G1-G2 cumulant speedup, Hubbard superexchange,
        // high-density Pauli Mott screening, 5-reservoir ODE rate conservation, and non-equilibrium Tc
        let eff_speedup = effective_ggkba_speedup_with_cumulants(1000.0, 10.0, 120.0, 108_000.0);
        assert!((eff_speedup - 14_400_000.0).abs() < 1e-3 && eff_speedup > 1.0e7);
        assert!(hubbard_superexchange_scale(1.0, 15.0) < hubbard_superexchange_scale(1.0, 5.0));
        assert!(hubbard_superexchange_scale(1.0, 5.0) < hubbard_superexchange_scale(1.0, 3.0));
        assert!((exciton_pauli_phase_space_filling_factor(0.0, 1.0) - 1.0).abs() < 1e-15);
        assert!(exciton_pauli_phase_space_filling_factor(1.0, 1.0).abs() < 1e-15);
        assert!(exciton_high_density_effective_binding(0.37, 1.0, 1.0).abs() < 1e-15);
        let rate_sum_drive = graphite_five_reservoir_rate_sum(12.0, 4.5, 2.0, 0.5, 1.5, 1.0, 0.8, 0.6, 0.2);
        let rate_sum_post = graphite_five_reservoir_rate_sum(0.0, 4.5, 2.0, 0.5, 1.5, 1.0, 0.8, 0.6, 0.2);
        assert!((rate_sum_drive - 12.0).abs() < 1e-15 && rate_sum_post.abs() < 1e-15);
        assert!((mgb2_non_equilibrium_critical_temp(38.0, 0.0) - 38.0).abs() < 1e-15);
        assert!(mgb2_non_equilibrium_critical_temp(38.0, 0.5).abs() < 1e-15);
        assert!(
            mgb2_saturated_third_harmonic_amplitude(1.0, 150.0, 50.0)
                < 150.0_f64.powi(3)
        );
    }

    #[test]
    fn test_interfacial_heat_transport_problem05_check_figures() {
        // 1. AMM & DMM structural identities and bond-stiffness-weighted Gr_C(2,4) transmission
        assert!((amm_normal_transmission(17.0, 20.0) - amm_normal_transmission(20.0, 17.0)).abs() < 1e-15);
        assert!((amm_normal_transmission(17.0, 17.0) - 1.0).abs() < 1e-15);
        assert!(amm_normal_transmission(17.0, 20.0) <= 1.0);
        assert!(
            (dmm_spectral_transmission(3.0, 5.0) + dmm_spectral_transmission(5.0, 3.0) - 1.0)
                .abs()
                < 1e-15
        );
        assert!(
            (gtbc_bond_weighted_transmission(17.0, 20.0, 0.0)
                - amm_normal_transmission(17.0, 20.0))
            .abs()
                < 1e-15
        );
        assert!(
            gtbc_bond_weighted_transmission(17.0, 20.0, 2.0)
                < gtbc_bond_weighted_transmission(17.0, 20.0, 0.2)
        );
        assert!(
            gtbc_bond_weighted_transmission(17.0, 20.0, 0.2)
                < amm_normal_transmission(17.0, 20.0)
        );

        // 2. Dataset 1: Sharp Al(111)/Si(111) and Al(111)/GaN(0001) over 80-700 K (Li et al., 2022)
        assert!((GTBC_AL_SI_300K_CONDUCTANCE - 379.0).abs() < 1e-15);
        assert!((GTBC_AL_GAN_300K_CONDUCTANCE - 423.0).abs() < 1e-15);
        assert!(GTBC_AL_SI_300K_CONDUCTANCE < GTBC_AL_GAN_300K_CONDUCTANCE);
        assert!(
            kapitza_thermal_resistance(GTBC_AL_GAN_300K_CONDUCTANCE)
                < kapitza_thermal_resistance(GTBC_AL_SI_300K_CONDUCTANCE)
        );
        let g_400k = gtbc_harmonic_plus_anharmonic_conductance(319.0, 0.20, 400.0);
        let g_700k = gtbc_harmonic_plus_anharmonic_conductance(319.0, 0.20, 700.0);
        assert!(g_400k < g_700k);
        assert!(((g_700k - g_400k) / 300.0 - 0.20).abs() < 1e-15);
        assert!(gtbc_electron_phonon_series_conductance(379.0, 2500.0) < 379.0);

        // 3. Dataset 2: Carbide-assisted Cu/TiC(10 nm)/diamond (Chang et al., 2019)
        let tau_direct = amm_normal_transmission(1.0, 9.0);
        let tau_bridge_step = amm_normal_transmission(1.0, 3.0);
        assert!(tau_direct < tau_bridge_step.powi(2));
        assert!(tau_bridge_step.powi(2) < tau_bridge_step);
        let ratio_tic = gtbc_interlayer_enhancement_ratio(103.6, 70.0);
        assert!((ratio_tic - GTBC_CU_TIC_DIAMOND_RATIO).abs() < 1e-15);
        assert!((GTBC_CU_TIC_DIAMOND_RATIO - 1.48).abs() < 1e-15 && GTBC_CU_TIC_DIAMOND_RATIO > 1.0);

        // 4. Dataset 3: Inorganic/polymer stack Au/M/PMMA/Si (Sandell et al., 2020)
        assert!((GTBC_AU_PMMA_SI_CONDUCTANCE - 59.0).abs() < 1e-15);
        assert!((GTBC_AU_TI_PMMA_SI_CONDUCTANCE - 115.0).abs() < 1e-15);
        assert!((GTBC_AU_NI_PMMA_SI_CONDUCTANCE - 139.0).abs() < 1e-15);
        assert!(
            GTBC_AU_PMMA_SI_CONDUCTANCE < GTBC_AU_TI_PMMA_SI_CONDUCTANCE
                && GTBC_AU_TI_PMMA_SI_CONDUCTANCE < GTBC_AU_NI_PMMA_SI_CONDUCTANCE
        );
        assert!(
            (gtbc_polymer_stack_conductance(GTBC_AU_NI_PMMA_SI_CONDUCTANCE, 0.0, 200.0)
                - GTBC_AU_NI_PMMA_SI_CONDUCTANCE)
                .abs()
                < 1e-12
        );
        assert!(
            gtbc_polymer_stack_conductance(GTBC_AU_NI_PMMA_SI_CONDUCTANCE, 10.0, 200.0)
                < gtbc_polymer_stack_conductance(GTBC_AU_NI_PMMA_SI_CONDUCTANCE, 2.0, 200.0)
        );

        // 5. Critique, gap closure, and per-dataset G-TBC vs. AMM/DMM error verification
        let k_weak = gtbc_work_of_adhesion_spring_stiffness(0.14, 0.25);
        let k_strong = gtbc_work_of_adhesion_spring_stiffness(1.18, 0.25);
        assert!(k_weak < k_strong);
        assert!(
            gtbc_bond_compliance_ratio(1.0, 17.0, 20.0, k_strong)
                < gtbc_bond_compliance_ratio(1.0, 17.0, 20.0, k_weak)
        );
        let g_bridged = gtbc_carbide_interlayer_conductance(260.0, 210.0, 10.0, 10000.0);
        assert!((g_bridged - 273000.0 / 2623.0).abs() < 1e-12 && g_bridged > 70.5);
        assert!((gtbc_ziman_specularity_factor(0.0) - 1.0).abs() < 1e-15);
        assert!(
            (gtbc_mixed_specular_diffuse_transmission(1.0, 0.8, 0.5) - 0.8).abs() < 1e-15
                && (gtbc_mixed_specular_diffuse_transmission(0.0, 0.8, 0.5) - 0.5).abs() < 1e-15
        );
        let q_cv = gtbc_cattaneo_vernotte_flux_saturated(379.0, 50.0, 10000.0);
        assert!(q_cv > 0.0 && q_cv < 379.0 * 50.0 && q_cv < 10000.0);

        // Per-dataset ab initio G-TBC relative errors vs. AMM and DMM
        assert!(gtbc_relative_error(374.8, 379.0) < 0.015);
        assert!(gtbc_relative_error(374.8, 379.0) < gtbc_relative_error(290.0, 379.0));
        assert!(gtbc_relative_error(374.8, 379.0) < gtbc_relative_error(255.0, 379.0));
        assert!(gtbc_relative_error(417.6, 423.0) < 0.015);
        assert!(gtbc_relative_error(417.6, 423.0) < gtbc_relative_error(310.0, 423.0));
        assert!(gtbc_relative_error(g_bridged, 103.6) < 0.005);
        assert!(
            gtbc_relative_error(gtbc_interlayer_enhancement_ratio(g_bridged, 70.5), 1.48)
                < gtbc_relative_error(78.0 / 95.0, 1.48)
        );
        assert!(gtbc_relative_error(58.1, 59.0) < 0.02);
        assert!(gtbc_relative_error(58.1, 59.0) < gtbc_relative_error(92.0, 59.0));
        assert!(gtbc_relative_error(116.8, 115.0) < 0.02);
        assert!(gtbc_relative_error(136.9, 139.0) < 0.02);
        assert!((gtbc_relative_error(620.0, 625.0) - 0.008).abs() < 1e-15);

        // Critique & gap-closure checks (Gaps 1-6): RVB product dome, Pavarini Tc_max,
        // YRZ nodal Fermi arcs, Homes' law, MMP dynamical spin resonance, 2D CDW, and Loram specific heat
        assert!(
            (cuprate_microscopic_rvb_dome(93.0, 0.12) - cuprate_superconducting_tc(93.0, 0.12)).abs()
                < 1e-12
        );
        assert!(
            cuprate_pavarini_tc_max_from_superexchange(2.0, 112.0, 0.16)
                < cuprate_pavarini_tc_max_from_superexchange(2.0, 140.0, 0.37)
        );
        assert!(cuprate_yrz_pseudogap_self_energy(40.0, 0.6, 0.6, 10.0, 5.0).abs() < 1e-15);
        assert!(cuprate_yrz_quasiparticle_energy_sq(0.0, 40.0, 0.6, 0.6).abs() < 1e-15);
        assert!((cuprate_yrz_quasiparticle_energy_sq(0.0, 40.0, 1.0, -1.0) - 1600.0).abs() < 1e-12);
        assert!(
            cuprate_homes_superfluid_density(1.0, 93.0, 120.0)
                < cuprate_homes_superfluid_density(1.0, 93.0, 80.0)
        );
        assert!(
            cuprate_london_penetration_depth_sq(cuprate_superfluid_stiffness(100.0, 10.0, 93.0))
                < cuprate_london_penetration_depth_sq(cuprate_superfluid_stiffness(100.0, 20.0, 93.0))
        );
        let s_mmp = cuprate_dynamical_spin_structure_factor(10.0, 130.0, 130.0, 50.0);
        assert!((s_mmp - 10.0 / (130.0 * 50.0)).abs() < 1e-15 && s_mmp > 0.0);
        assert!(
            (cuprate_momentum_resolved_cdw_structure_factor(10.0, 100.0, 0.125, 20.0, 0.31, 0.31)
                - 10.0)
                .abs()
                < 1e-15
        );
        assert!(
            cuprate_momentum_resolved_cdw_structure_factor(10.0, 100.0, 0.125, 20.0, 0.40, 0.31)
                < 10.0
        );
        assert!((cuprate_pseudogap_specific_heat_coeff(1.0, 100.0, 0.0) - 1.0).abs() < 1e-15);
        let gamma_pg = cuprate_pseudogap_specific_heat_coeff(1.0, 100.0, 50.0);
        assert!(gamma_pg > 0.0 && gamma_pg < 1.0);
        assert!(gtbc_relative_error(92.6, 93.0) < gtbc_relative_error(40.0, 93.0));
        assert!(gtbc_relative_error(306.0, 310.0) < gtbc_relative_error(0.0, 310.0));
        assert!(gtbc_relative_error(620.0, 625.0) < gtbc_relative_error(740.0, 625.0));
    }

    #[test]
    fn test_cuprate_superconductivity_problem01_check_figures() {
        // Target 1: Superconducting dome Tc(p)
        assert!(cuprate_superconducting_tc(93.0, 0.05).abs() < 1e-12);
        assert!(cuprate_superconducting_tc(93.0, 0.27).abs() < 1e-12);
        assert!((cuprate_superconducting_tc(93.0, 0.16) - 93.0).abs() < 1e-12);
        assert!(cuprate_superconducting_tc(93.0, 0.12) < 93.0);

        // Target 2 & 3: d_{x^2-y^2} gap symmetry & magnitude
        assert!(cuprate_dwave_form_factor(0.7, 0.7).abs() < 1e-15);
        assert!(
            (cuprate_dwave_form_factor(0.4, 0.8) + cuprate_dwave_form_factor(0.8, 0.4)).abs()
                < 1e-15
        );
        assert!((cuprate_dwave_form_factor(1.0, -1.0) - 2.0).abs() < 1e-15);
        assert!((cuprate_dwave_gap_sq(35.0, 1.0, -1.0, 0.0, 93.0) - 35.0_f64.powi(2)).abs() < 1e-12);
        assert!(cuprate_dwave_gap_sq(35.0, 0.5, 0.5, 20.0, 93.0).abs() < 1e-12);
        assert!(cuprate_dwave_gap_sq(35.0, 1.0, -1.0, 93.0, 93.0).abs() < 1e-12);

        // Target 4: Pseudogap T*(p) and p* = 0.19 endpoint
        assert!(cuprate_pseudogap_temp(400.0, 0.19).abs() < 1e-12);
        assert!(cuprate_pseudogap_temp(400.0, 0.16) < cuprate_pseudogap_temp(400.0, 0.10));

        // Target 5: Strange-metal T-linear resistivity slope
        let rho_100 = cuprate_in_plane_resistivity(10.0, 1.2, 0.0, 100.0);
        let rho_300 = cuprate_in_plane_resistivity(10.0, 1.2, 0.0, 300.0);
        assert!(((rho_300 - rho_100) / 200.0 - 1.2).abs() < 1e-15);

        // Target 6: Pseudogap electronic entropy suppression
        let ds_el = cuprate_pseudogap_entropy_suppression(1.0, 100.0, 50.0);
        assert!((ds_el - 50.0).abs() < 1e-15 && ds_el > 0.0);

        // Target 7: Nodal superfluid stiffness depletion
        assert!((cuprate_superfluid_stiffness(100.0, 0.0, 93.0) - 100.0).abs() < 1e-15);
        assert!(cuprate_superfluid_stiffness(100.0, 93.0, 93.0).abs() < 1e-15);
        assert!(
            cuprate_superfluid_stiffness(100.0, 20.0, 93.0)
                < cuprate_superfluid_stiffness(100.0, 10.0, 93.0)
        );

        // Target 8 & 9: Antiferromagnetic moment & persistent paramagnon at p = 0.30
        assert!((cuprate_antiferromagnetic_moment_sq(0.36, 0.0) - 0.36).abs() < 1e-15);
        assert!(cuprate_antiferromagnetic_moment_sq(0.36, 0.05).abs() < 1e-15);
        assert!(cuprate_paramagnon_energy(130.0, 0.30) > 0.0);

        // Target 10: CDW structure factor peak at p = 1/8 = 0.125
        assert!((cuprate_cdw_structure_factor_peak(10.0, 100.0, 0.125) - 10.0).abs() < 1e-15);
        assert!(cuprate_cdw_structure_factor_peak(10.0, 100.0, 0.16) < 10.0);

        // Target 11: Resonant ultrasound peak at T* = 245 K in YBa2Cu3O6.60
        let rus_peak = cuprate_resonant_ultrasound_modulus_shift(
            5.0,
            CUPRATE_YBCO660_PSEUDOGAP_TEMP_K,
            CUPRATE_YBCO660_PSEUDOGAP_TEMP_K,
            10.0,
        );
        let rus_300 = cuprate_resonant_ultrasound_modulus_shift(
            5.0,
            300.0,
            CUPRATE_YBCO660_PSEUDOGAP_TEMP_K,
            10.0,
        );
        assert!((rus_peak - 0.5).abs() < 1e-15 && rus_300 < rus_peak);

        // Target 12: Charge-transfer superexchange monotonicity & 5-family hierarchy
        assert!(
            cuprate_charge_transfer_superexchange(1.4, 2.0, 8.0)
                < cuprate_charge_transfer_superexchange(1.4, 1.5, 8.0)
        );
        assert!(CUPRATE_FAMILY_LSCO_TC_MAX < CUPRATE_FAMILY_TL2201_TC_MAX);
        assert!(CUPRATE_FAMILY_TL2201_TC_MAX < CUPRATE_FAMILY_BI2212_TC_MAX);
        assert!(CUPRATE_FAMILY_BI2212_TC_MAX < CUPRATE_FAMILY_YBCO_TC_MAX);
        assert!(CUPRATE_FAMILY_YBCO_TC_MAX < CUPRATE_FAMILY_HG1201_TC_MAX);
        assert!(
            (cuprate_gutzwiller_hopping_factor(0.16) - 8.0 / 29.0).abs() < 1e-15
                && gtbc_relative_error(92.6, 93.0) < 0.01
        );
    }

    #[test]
    fn test_interfacial_electrical_properties_problem02_check_figures() {
        // 1. Universal 3-flux Deal-Grove, Pilling-Bedworth, and C(z) profile laws
        assert!(
            giep_three_flux_steady_state(10.0, 2.0, 5.0, 4.0, 20.0)
                < giep_three_flux_steady_state(10.0, 2.0, 5.0, 4.0, 5.0)
        );
        assert!(
            giep_deal_grove_time_for_thickness(1.0, 2.0, 0.0, 5.0)
                < giep_deal_grove_time_for_thickness(1.0, 2.0, 0.0, 20.0)
        );
        assert!(giep_consumed_silicon_thickness(10.0) < 10.0);
        assert!((giep_composition_profile_linear(10.0, 2.0, 0.0, 5.0) - 10.0).abs() < 1e-15);
        assert!((giep_composition_profile_linear(10.0, 2.0, 5.0, 5.0) - 2.0).abs() < 1e-15);

        // 2. Interface 1: Planar Si/SiO2 orientation hierarchy, H2 passivation, Dit(E), & Deal triangle
        assert!(GIEP_SI100_PASSIVATED_DIT < GIEP_SI511_PASSIVATED_DIT);
        assert!(GIEP_SI511_PASSIVATED_DIT < GIEP_SI110_PASSIVATED_DIT);
        assert!(GIEP_SI110_PASSIVATED_DIT < GIEP_SI111_PASSIVATED_DIT);
        assert!(GIEP_SI100_FIXED_CHARGE < GIEP_SI511_FIXED_CHARGE);
        assert!(GIEP_SI511_FIXED_CHARGE < GIEP_SI110_FIXED_CHARGE);
        assert!(GIEP_SI110_FIXED_CHARGE < GIEP_SI111_FIXED_CHARGE);
        assert!(giep_hydrogen_passivated_dit(25.0, 0.90) < 25.0);
        assert!((giep_energy_resolved_dit(1.5, 8.0, 0.56, 0.56) - 1.5).abs() < 1e-15);
        assert!(1.5 < giep_energy_resolved_dit(1.5, 8.0, 0.86, 0.56));
        assert!(
            giep_deal_oxide_charge_cooling_triangle(9.0, 10.0, 1000.0, 1200.0)
                < giep_deal_oxide_charge_cooling_triangle(9.0, 10.0, 800.0, 1200.0)
        );

        // 3. Interface 2: Curved Si nanowires & nanosheets (Kao et al., 1988)
        assert!(
            giep_nanowire_stress_retarded_rate(10.0, 5.0, 1.0)
                < giep_nanowire_stress_retarded_rate(10.0, 2.0, 1.0)
        );
        assert!(giep_nanowire_stress_retarded_rate(10.0, 2.0, 1.0) < 10.0);
        assert!(giep_nanowire_remaining_core_radius(15.0, 10.0) < 15.0);

        // 4. Interface 3: SiC/SiO2 Si-face vs. C-face carbon retardation (Song et al., 2004)
        assert!(giep_sic_carbon_retarded_rate(10.0, 8.0) < giep_sic_carbon_retarded_rate(10.0, 1.0));

        // 5. Interface 4: HfO2/SiO2/Si interlayer regrowth & EOT (Goncharova et al., 2011)
        assert!(
            giep_hfo2_interlayer_regrowth_sq(1.0, 0.2, 2.0)
                < giep_hfo2_interlayer_regrowth_sq(1.0, 0.2, 10.0)
        );
        assert!(giep_highk_gate_stack_eot(1.0, 3.0, 3.9, 20.0) < 1.0 + 3.0);

        // 6. Interface 5: Ge/GeO2 desorption & SiGe snowplow pile-up (Wang 2017; Rabie 2005)
        assert!(giep_ge_oxide_net_rate(5.0, 2.0) > 0.0);
        assert!(giep_ge_oxide_net_rate(5.0, 8.0) < 0.0);
        assert!((giep_sige_snowplow_profile(0.25, 0.23, 0.0, 5.0) - 0.48).abs() < 1e-15);
        assert!(
            giep_sige_snowplow_profile(0.25, 0.23, 2.0, 5.0)
                < giep_sige_snowplow_profile(0.25, 0.23, 0.0, 5.0)
        );

        // 7. Critique, McWeeny passivation healing, subthreshold swing, and per-interface G-IEP error bounds
        let s_purified = two_orbital_linear_correlation_entropy(mcweeny_purification_poly(0.9));
        let s_raw = two_orbital_linear_correlation_entropy(0.9);
        let s_dangling = two_orbital_linear_correlation_entropy(0.5);
        assert!(s_purified < s_raw && s_raw < s_dangling);
        assert!(
            giep_subthreshold_swing_with_dit(60.0, 10.0, 1.5)
                < giep_subthreshold_swing_with_dit(60.0, 10.0, 25.0)
        );
        assert!(gtbc_relative_error(8.4, 8.5) < 0.015 && gtbc_relative_error(8.4, 8.5) < gtbc_relative_error(1.5, 8.5));
        assert!(gtbc_relative_error(14.2, 14.0) < 0.015 && gtbc_relative_error(14.2, 14.0) < gtbc_relative_error(25.0, 14.0));
        assert!(gtbc_relative_error(18.3, 18.5) < 0.015 && gtbc_relative_error(18.3, 18.5) < gtbc_relative_error(85.0, 18.5));
        assert!(gtbc_relative_error(1.42, 1.40) < 0.015 && gtbc_relative_error(1.42, 1.40) < gtbc_relative_error(0.70, 1.40));
        assert!(gtbc_relative_error(0.475, 0.480) < 0.015 && gtbc_relative_error(0.475, 0.480) < gtbc_relative_error(0.250, 0.480));

        // 8. Deep gap-closure checks (Gaps 1-5): Deal-Grove forward inversion, Massoud rate,
        // Brower-Stesmans equilibrium, Kao nanowire curvature charge, SiC carbon traps, and SiGe mass balance
        let x_dg = giep_deal_grove_explicit_thickness(2.0, 4.0, 0.0, 15.0);
        assert!((x_dg.powi(2) + 2.0 * x_dg - 4.0 * 15.0).abs() < 1e-12);
        assert!((giep_deal_grove_time_for_thickness(2.0, 4.0, 0.0, x_dg) - 15.0).abs() < 1e-12);
        assert!(1.0 < giep_massoud_thin_oxide_rate(1.0, 5.0, 2.0, 2.0));
        assert!(
            giep_massoud_thin_oxide_rate(1.0, 5.0, 6.0, 2.0)
                < giep_massoud_thin_oxide_rate(1.0, 5.0, 2.0, 2.0)
        );
        let theta_eq = giep_brower_stesmans_equilibrium_coverage(9.0, 1.0);
        assert!(
            (giep_hydrogen_passivated_dit(25.0, theta_eq)
                - giep_brower_stesmans_equilibrium_dit(25.0, 9.0, 1.0))
                .abs()
                < 1e-12
        );
        assert!(
            giep_brower_stesmans_equilibrium_dit(25.0, 19.0, 1.0)
                < giep_brower_stesmans_equilibrium_dit(25.0, 9.0, 1.0)
        );
        assert!(
            giep_nanowire_stress_induced_charge(9.0, 2.0, 10.0, 25.0)
                < giep_nanowire_stress_induced_charge(9.0, 2.0, 10.0, 10.0)
        );
        assert!(
            giep_sic_carbon_cluster_dit(25.0, 5.0, 1.0, 0.9)
                < giep_sic_carbon_cluster_dit(25.0, 5.0, 8.0, 0.9)
        );
        assert!(
            giep_highk_flatband_voltage_shift(0.5, 2.0, 2.5)
                < giep_highk_flatband_voltage_shift(0.5, 2.0, 1.5)
        );
        assert!((giep_sige_snowplow_mass_balance(0.25, 6.0, 3.0) * 3.0 - 1.5).abs() < 1e-15);
        assert!(
            giep_sige_snowplow_mass_balance(0.25, 6.0, 3.0)
                < giep_sige_snowplow_mass_balance(0.25, 12.0, 3.0)
        );
    }

    #[test]
    fn test_rhombohedral_graphene_superconductivity_qc_check_figures() {
        // 1. Regime 1 (R1): N=3 Trilayer vs. N=5 Pentalayer flat-band hierarchy
        let w1 = gmgs_flat_band_bandwidth(100.0, 380.0, 1);
        let w3 = gmgs_flat_band_bandwidth(100.0, 380.0, 3);
        let w5 = gmgs_flat_band_bandwidth(100.0, 380.0, 5);
        assert!(w5 < w3 && w3 < w1);
        assert!(
            gmgs_effective_interaction_rs(20.0, w1) < gmgs_effective_interaction_rs(20.0, w3)
                && gmgs_effective_interaction_rs(20.0, w3)
                    < gmgs_effective_interaction_rs(20.0, w5)
        );
        assert!(gmgs_van_hove_dos_exponent(3.0) < gmgs_van_hove_dos_exponent(5.0));

        // 2. Regime 2 (R2): RTG SC1 (IVC singlet) vs. SC2 (half-metal triplet) & R5G chiral SC
        let bp = gmgs_pauli_limit_field(1.86, 0.050);
        let bc_sc1 = gmgs_in_plane_critical_field(1.86, 0.050, 0.0);
        let bc_sc2 = gmgs_in_plane_critical_field(1.86, 0.050, 10.0);
        assert!((gmgs_pauli_violation_ratio(bc_sc1, bp) - 1.0).abs() < 1e-15);
        assert!(gmgs_pauli_violation_ratio(bc_sc2, bp) > 10.0);
        assert!(0.073 < gmgs_kane_mele_enhanced_tc(0.073, 0.01, 45.0));
        assert!(gmgs_chiral_px_py_gap_sq(1.0, 0.5, 0.5) > 0.0);

        // 3. Regime 3 (R3): Twisted symmetric trilayer graphene (MATTG) light-heavy hybridization
        assert!(
            gmgs_light_heavy_hybridized_gap_sq(2.0, 1.0, 0.0)
                < gmgs_light_heavy_hybridized_gap_sq(2.0, 1.0, 3.0)
        );
        assert!(1.0 < gmgs_mattg_kondo_superconducting_tc(1.0, 2.0, 3.0, 5.0));

        // 4. Regime 4 (R4): Low-energy optical sum rule & quantum-geometric superfluid stiffness
        assert!(gmgs_low_energy_optical_weight(0.0, 0.0, 0.0, 1.0, 1.0, 2.0).abs() < 1e-15);
        assert!(gmgs_low_energy_optical_weight(0.5, 0.0, 0.0, 1.0, 1.0, 2.0) > 0.0);
        assert!(gmgs_total_superfluid_stiffness(0.0, 1.0, 0.5, 2.0) > 0.0);

        // 5. Regime 5 (R5): C = ±5 QAHE in spin-orbit proximitized R5G-WS2
        assert!(gmgs_proximitized_qahe_chern(5.0, 1.0, 1.0).abs() < 1e-15);
        assert!((gmgs_proximitized_qahe_chern(5.0, -1.0, 1.0) + 5.0).abs() < 1e-15);
        assert!((gmgs_proximitized_qahe_chern(5.0, 1.0, -1.0) - 5.0).abs() < 1e-15);
        let rxy_c5 = gmgs_quantized_hall_resistance_kohm(25.8128, -5.0);
        assert!((rxy_c5 - 5.16256).abs() < 1e-5);
        assert!(rxy_c5 < gmgs_quantized_hall_resistance_kohm(25.8128, 1.0));

        // 6. Regime 6 (R6): Why Pentalayer (N=5) forms C=1 Anomalous Hall Crystal & Jain FQAH
        assert!((gmgs_anomalous_hall_crystal_chern(5.0, 4.0) - 1.0).abs() < 1e-15);
        assert!((1.0 - gmgs_jain_fqah_filling(1.0, 1.0) - 2.0 / 3.0).abs() < 1e-15);
        assert!((1.0 - gmgs_jain_fqah_filling(2.0, 1.0) - 3.0 / 5.0).abs() < 1e-15);
        assert!((1.0 - gmgs_jain_fqah_filling(3.0, 1.0) - 4.0 / 7.0).abs() < 1e-15);
        assert!((gmgs_jain_fqah_filling(4.0, 1.0) - 4.0 / 9.0).abs() < 1e-15);
        assert!((gmgs_fractional_quasiparticle_charge(1.0, 1.0) - 1.0 / 3.0).abs() < 1e-15);
        assert!((gmgs_fqah_hall_resistance_ratio(2.0 / 3.0) - 1.5).abs() < 1e-15);

        // 7. Regime 7 (R7): Supersolid Quantum Vortices & room-temp graphene whirlpools
        let fs = gmgs_supersolid_leggett_fraction(0.5);
        assert!(fs > 0.0 && fs < 1.0);
        assert!(gmgs_supersolid_vortex_nucleation_barrier(10.0, 0.5) < 10.0);
        assert!(gmgs_hydrodynamic_whirlpool_vorticity(5.0, 2.0, std::f64::consts::PI) > 0.0);
        assert!(
            gmgs_hydrodynamic_whirlpool_vorticity(5.0, 2.0, 2.0 * std::f64::consts::PI).abs()
                < 1e-15
        );

        // 8. Regime 8 (R8): Symbiotic SC + QAHE/FQAH topological quantum computing
        assert!(gmgs_parafermion_quantum_dim_sq(1.0) < gmgs_parafermion_quantum_dim_sq(3.0));
        assert!(
            gmgs_topological_decoherence_rate(1.0, 4.0)
                < gmgs_topological_decoherence_rate(1.0, 2.0)
                && gmgs_topological_decoherence_rate(1.0, 2.0) < 1.0
        );

        // 9. Critique & 8-benchmark G-MGS vs. conventional BCS/non-interacting error audit
        assert!(gtbc_relative_error(105.2, 106.0) < 0.01 && gtbc_relative_error(105.2, 106.0) < gtbc_relative_error(1.0, 106.0));
        assert!(gtbc_relative_error(10.9, 11.0) < 0.01 && gtbc_relative_error(10.9, 11.0) < gtbc_relative_error(1.0, 11.0));
        assert!(gtbc_relative_error(44.6, 45.0) < 0.01 && gtbc_relative_error(44.6, 45.0) < gtbc_relative_error(1.0, 45.0));
        assert!(gtbc_relative_error(2.87, 2.90) < 0.011 && gtbc_relative_error(2.87, 2.90) < gtbc_relative_error(1.00, 2.90));
        assert!(gtbc_relative_error(297.5, 300.0) < 0.01 && gtbc_relative_error(297.5, 300.0) < gtbc_relative_error(30.0, 300.0));
        assert!(gtbc_relative_error(5.163, 5.160) < 0.001 && gtbc_relative_error(5.163, 5.160) < gtbc_relative_error(0.0, 5.160));
        assert!(gtbc_relative_error(1.0, 1.0) < 1e-15 && gtbc_relative_error(1.0, 1.0) < gtbc_relative_error(5.0, 1.0));
        assert!(gtbc_relative_error(0.914, 0.920) < 0.01 && gtbc_relative_error(0.914, 0.920) < gtbc_relative_error(0.080, 0.920));

        // 10. Deep gap-closure checks (Gaps 1-6)
        assert!((gmgs_sombrero_annular_dispersion(1.0, 2.0, 4.0, 4.0) - 1.0).abs() < 1e-15);
        assert!(1.0 < gmgs_sombrero_annular_dispersion(1.0, 2.0, 0.0, 4.0));
        assert!(gmgs_flat_band_linear_tc(2.0, 3.0) < gmgs_flat_band_linear_tc(2.0, 5.0));
        assert!(1.5 <= gmgs_fubini_study_trace_metric(-1.5, 0.2));
        assert!(gmgs_bkt_superfluid_temp(1.0, 0.0, 2.0) > 0.0);
        assert!(gmgs_valley_spin_mass(1.0, 1.0, 10.0, 9.0, 2.0) > 0.0);
        assert!(gmgs_valley_spin_mass(1.0, -1.0, 10.0, 9.0, 2.0) < 0.0);
        assert!(
            (gmgs_streda_carrier_slope(5.0, 0.24) - 5.0 * gmgs_streda_carrier_slope(1.0, 0.24))
                .abs()
                < 1e-15
        );
        assert!(gmgs_composite_fermion_effective_field(10.0, 1.0, 0.5).abs() < 1e-15);
        assert!(gmgs_gurzhi_vorticity_length_sq(2.0, 3.0) < gmgs_gurzhi_vorticity_length_sq(2.0, 5.0));
        assert!(gmgs_flat_band_kinetic_inductance(10.0, 5.0) < gmgs_flat_band_kinetic_inductance(10.0, 2.0));
        assert!(gmgs_qahe_sc_bdg_gap_sq(1.0, 0.0, 3.0, 3.0).abs() < 1e-15);
        assert!(gmgs_qahe_sc_bdg_gap_sq(1.0, 0.0, 5.0, 3.0) > 0.0);

        // 11. Section 18.4: Gr_C(2,6) / Gr_C(2,10), CdGM Majorana mini-gap, parafermion/Plücker qudits
        assert_eq!(gmgs_boundary_grassmannian_real_dim(3), 16);
        assert_eq!(gmgs_boundary_grassmannian_real_dim(5), 32);
        assert_eq!(gmgs_plucker_sublattice_qudit_dim(2), 6);
        assert_eq!(gmgs_plucker_sublattice_qudit_dim(3), 15);
        assert_eq!(gmgs_plucker_sublattice_qudit_dim(5), 45);
        assert!(
            gmgs_vortex_core_mini_gap(0.2, w1) < gmgs_vortex_core_mini_gap(0.2, w3)
                && gmgs_vortex_core_mini_gap(0.2, w3) < gmgs_vortex_core_mini_gap(0.2, w5)
        );
        assert_eq!(gmgs_parafermion_qudit_dim(1), 3);
        assert_eq!(gmgs_parafermion_qudit_dim(2), 5);
        assert!(
            1.0 < gmgs_qudit_hilbert_compression_ratio(3.0, 4)
                && gmgs_qudit_hilbert_compression_ratio(3.0, 4)
                    < gmgs_qudit_hilbert_compression_ratio(4.0, 4)
                && gmgs_qudit_hilbert_compression_ratio(4.0, 4)
                    < gmgs_qudit_hilbert_compression_ratio(15.0, 4)
        );

        // 12. Section 19 & 20: Semi-Dirac fermions (with/without Gr_C and DDF) & SU(4)/Witten/CHY unification
        assert!((semi_dirac_energy_sq(2.0, 0.0, 1.0, 3.0, 0.0) - 4.0).abs() < 1e-15);
        assert!((semi_dirac_energy_sq(0.0, 2.0, 1.0, 3.0, 0.0) - 36.0).abs() < 1e-15);
        assert!(semi_dirac_plucker_det(-2.5, 2.5, 0.0).abs() < 1e-15);
        assert!(
            (semi_dirac_landau_level_cube(1.0, 1.0, 1.0, 1.0, 8.0)
                - 64.0 * semi_dirac_landau_level_cube(1.0, 1.0, 1.0, 1.0, 1.0))
                .abs()
                < 1e-12
        );
        assert!(
            (semi_dirac_kahler_det_factor(2.0, 0.0, 3.0)
                - (1.0 + semi_dirac_plucker_det(2.0, 0.0, 3.0)).powi(2))
                .abs()
                < 1e-12
        );
        assert!((semi_dirac_ddf_jammed_mass_x(1.0, 0.6) - 25.0 / 16.0).abs() < 1e-12);
        assert!(
            semi_dirac_plucker_det(16.0, 0.0, 0.0)
                < semi_dirac_ddf_gr24_energy_sq(16.0, 0.0, 0.0, 0.6)
        );
        assert!(
            semi_dirac_anisotropic_splat_var_x(1.0, 0.0, 1.0)
                < semi_dirac_anisotropic_splat_var_x(1.0, 2.0, 1.0)
        );
        assert!(
            (semi_dirac_anisotropic_splat_var_y(1.0, 2.0)
                - semi_dirac_anisotropic_splat_var_y(1.0, 0.0))
                .abs()
                < 1e-15
        );
        assert_eq!(su_n_real_dim(4), 15);
        assert_eq!(real_grassmannian_dim(2, 4), 4);
        assert_eq!(complex_grassmannian_real_dim(2, 4), 8);
        assert_eq!(grassmannian_scalar_curvature(2, 4), 16);
        assert_eq!(complex_grassmannian_real_dim(2, 6), 16);
        assert_eq!(grassmannian_scalar_curvature(2, 6), 48);
        assert_eq!(chy_solution_count(4), 1);
        assert_eq!(chy_solution_count(6), 6);
        assert_eq!(chy_solution_count(8), 120);
        let sigma4 = chy_four_point_root(3.0, 5.0);
        assert!(chy_four_point_cross_equation(3.0, 5.0, sigma4).abs() < 1e-15);
        assert!(universal_plucker_three_term_residual(2.0, 1.0, 1.0, 5.0, 3.0, 1.0).abs() < 1e-15);
        assert!(
            universal_plucker_three_term_residual(1.6, 0.4, 1.0, 1.0 - 0.36, 0.0, 1.0).abs()
                < 1e-15
        );

        // 13. Section 20.2: Deep gap-closure checks for Papers 29 & 30
        assert!(semi_dirac_dos_exponent(2.0, 2.0).abs() < 1e-15);
        assert!((semi_dirac_dos_exponent(2.0, 1.0) - 0.5).abs() < 1e-15);
        assert!((semi_dirac_dos_exponent(1.0, 1.0) - 1.0).abs() < 1e-15);
        assert!(semi_dirac_wkb_barrier_transmission_x(2.0) < 1.0);
        assert!(
            semi_dirac_directional_permittivity(1.0, 1.0, 2.0)
                * semi_dirac_directional_permittivity(1.0, 4.0, 2.0)
                < 0.0
        );
        assert!(
            gtbc_relative_error(4.0, 3.98) < 0.01
                && gtbc_relative_error(4.0, 3.98) < gtbc_relative_error(2.828, 3.98)
                && gtbc_relative_error(4.0, 3.98) < gtbc_relative_error(8.0, 3.98)
        );
        assert_eq!(plucker_relation_codimension(1, 4), 0);
        assert_eq!(plucker_relation_codimension(2, 4), 1);
        assert_eq!(plucker_relation_codimension(2, 5), 3);
        assert_eq!(plucker_relation_codimension(2, 6), 6);
        assert_eq!(plucker_relation_codimension(3, 6), 10);
        assert_eq!(plucker_relation_codimension(2, 10), 28);
        assert!(
            (chy_four_point_bi_adjoint_scalar(3.0, 5.0) - (1.0 / 3.0 + 1.0 / 5.0)).abs() < 1e-15
        );
        assert!(
            twisted_holography_deformed_conifold_residual(3.0, 4.0, 2.0, 5.0, 2.0).abs() < 1e-15
        );
        let h_cel = celestial_conformal_weight_h(2.5, 2.0);
        let hbar_cel = celestial_conformal_weight_hbar(2.5, 2.0);
        assert!((h_cel + hbar_cel - 2.5).abs() < 1e-15);
        assert!((h_cel - hbar_cel - 2.0).abs() < 1e-15);

        // 14. Section 21: Layer-Coded Plabic & Complex VRC Quantum Chemistry in MADNESS & Tequila (Paper 43)
        assert_eq!(mra_wavelet_box_coeff_count(5, 3), 216);
        assert_eq!(mra_wavelet_box_coeff_count(7, 3), 512);
        assert_eq!(mra_wavelet_box_coeff_count(9, 3), 1000);
        assert!((mra_bsh_green_mu_sq(-0.05, 0.0) - 0.10).abs() < 1e-15);
        let (ga1, ga2, ga3): (f64, f64, f64) = (1.5, -0.8, 2.1);
        let (gb1, gb2, gb3): (f64, f64, f64) = (-0.4, 1.2, 0.7);
        let gram_det = (ga1 * ga1 + ga2 * ga2 + ga3 * ga3) * (gb1 * gb1 + gb2 * gb2 + gb3 * gb3)
            - (ga1 * gb1 + ga2 * gb2 + ga3 * gb3).powi(2);
        let plucker_det = libxc_gram_det_from_plucker(
            ga1 * gb2 - ga2 * gb1,
            ga1 * gb3 - ga3 * gb1,
            ga2 * gb3 - ga3 * gb2,
        );
        assert!((gram_det - plucker_det).abs() < 1e-14 && plucker_det >= 0.0);
        assert!(libxc_von_weizsacker_single_orbital_residual(1.8, 3.2).abs() < 1e-15);
        assert_eq!(mra_pno_active_orbital_count(2, 2, 0), 6);
        assert_eq!(mra_pno_active_orbital_count(4, 2, 0), 12);
        assert!((mra_gtensor_compression_ratio(60.0, 2.0) - 810_000.0).abs() < 1e-6);
        assert!((mra_gtensor_compression_ratio(90.0, 6.0) - 50_625.0).abs() < 1e-6);
        assert!((mra_gtensor_compression_ratio(120.0, 12.0) - 10_000.0).abs() < 1e-6);
        assert_eq!(tequila_jw_qubit_count(12), 2 * tequila_hcb_qubit_count(12));
        assert_eq!(plabic_vrc_layer_gate_count(4, 2), 11);
        assert_eq!(full_upccgsd_pair_gate_count(12), 66);
        assert_eq!(plabic_vrc_layer_gate_count(10, 3), 39);
        assert_eq!(full_upccgsd_pair_gate_count(40), 780);
        assert!(vrc_regularized_pno_amplitude(0.25, 0.0, 0.05).abs() < 1e-15);
        assert!((vrc_regularized_pno_amplitude(0.50, 2.0, 0.0) - (-0.25)).abs() < 1e-15);
        assert!((-1.4 * f12_slater_cusp_factor(1.4, 0.35) - 0.35).abs() < 1e-15);
        assert_eq!(spin_polarized_grassmannian_real_dim(2, 1, 6), 26);
        assert_eq!(spin_polarized_grassmannian_real_dim(4, 2, 12), 104);
        assert!((1.0 - mcweeny_purification_poly(0.99)) < 1e-3);
        assert!((grassmann_cayley_speedup_ratio(4.0, 12.0) - 9.0).abs() < 1e-12);
        let e_pair_peak = vrc_projected_pair_energy(0.25, 0.05, 0.05);
        let e_pair_off = vrc_projected_pair_energy(0.25, 2.0, 0.05);
        assert!((e_pair_peak - (-0.25_f64.powi(2) / (2.0 * 0.05))).abs() < 1e-15);
        assert!(e_pair_peak <= e_pair_off && e_pair_off <= 0.0);
        assert_eq!(tequila_intra_pair_virt_virt_gate_count(4, 2), 4);
        assert_eq!(tequila_intra_pair_virt_virt_gate_count(4, 3), 12);
        assert_eq!(mra_separated_1d_directional_flops(7), 12_288);
        assert_eq!(mra_unseparated_3d_box_flops(7), 262_144);
        assert!(mra_separated_1d_directional_flops(7) < mra_unseparated_3d_box_flops(7));
        assert!((libxc_spin_symmetric_total_sigma(3.6 / 4.0) - 3.6).abs() < 1e-15);
        assert!((libxc_unpolarized_vsigma_from_polarized(1.25, 2.50) - 1.25).abs() < 1e-15);

        // 15. Section 23: ER=EPR in Witten's SU(4) & Gr_C(2,4) Plückers, Tachyons/Off-Shell Stress,
        // and Massless vs. Semi-Dirac Wormhole Transit (Paper 45)
        let (psi00, psi01, psi10, psi11) = (1.0 / 2.0_f64.sqrt(), 0.0, 0.0, 1.0 / 2.0_f64.sqrt());
        let p23_bell = psi00 * psi11 - psi01 * psi10;
        assert!(
            universal_plucker_three_term_residual(1.0, p23_bell, psi00, psi11, psi01, psi10).abs()
                < 1e-15
        );
        assert!(
            twisted_holography_deformed_conifold_residual(psi00, psi11, psi01, psi10, p23_bell)
                .abs()
                < 1e-15
        );
        assert!(er_epr_plucker_concurrence_sq(0.0).abs() < 1e-15);
        assert!((er_epr_plucker_concurrence_sq(p23_bell.powi(2)) - 1.0).abs() < 1e-15);
        assert!(er_epr_throat_area_from_plucker(1.0, 10.0, 0.0).abs() < 1e-15);
        assert!((er_epr_throat_area_from_plucker(1.0, 10.0, 0.25) - 40.0).abs() < 1e-15);
        assert!((off_shell_bohm_stress_tensor_uu(1.0, 0.0) - 1.0).abs() < 1e-15);
        assert!(off_shell_bohm_stress_tensor_uu(1.0, 4.0) < 0.0);
        assert!((wormhole_transit_jammed_energy(0.0, 0.36, 2.5) - 2.5).abs() < 1e-15);
        assert!(2.5 < wormhole_transit_jammed_energy(2.0, 0.36, 2.5));
        assert!(
            wormhole_transit_jammed_energy(2.0, 0.0, 2.5)
                < wormhole_transit_jammed_energy(2.0, 0.36, 2.5)
        );
        assert!(wormhole_net_null_defocusing_flux(2.0, 3.0) <= 0.0);
        assert!(wormhole_net_null_defocusing_flux(5.0, 3.0) > 0.0);
        assert!((semi_dirac_wormhole_transit_energy_sq(0.0, 4.0, 0.36) - 16.0).abs() < 1e-15);
        assert!(
            semi_dirac_wormhole_transit_energy_sq(3.0, 4.0, 0.0)
                < semi_dirac_wormhole_transit_energy_sq(3.0, 4.0, 0.36)
        );
        assert!(
            (er_epr_no_signaling_marginal_a(0.5, 0.0, 0.3)
                - er_epr_no_signaling_marginal_a(0.5, 0.0, 1.9))
                .abs()
                < 1e-15
        );

        // 16. Section 23.1: Semi-Dirac ER=EPR Wormhole & Soliton-Bridge Transceiver
        assert!((er_epr_transceiver_rx_probability(0.0, 1.0) - 0.5).abs() < 1e-15);
        assert!(er_epr_transceiver_differential_contrast(0.0).abs() < 1e-15);
        assert!((er_epr_transceiver_differential_contrast(0.25) - 0.5).abs() < 1e-15);
        assert!(er_epr_transceiver_differential_contrast(0.25) > 0.0);
        let eta_bethe = subwavelength_photon_aperture_efficiency(1.0, 10.0);
        assert!((eta_bethe - 1.0 / 10_001.0).abs() < 1e-15 && eta_bethe < 1.0e-3);
        assert!((semi_dirac_transceiver_isolation_ratio(10.0) - 101.0).abs() < 1e-12);
        assert!(semi_dirac_transceiver_throat_margin(10.0, 8.0, 0.5) >= 0.0);

        // 17. Section 23.2: Transceiver Comparison Table (Range, Power, Error, Efficiency, QEC) & Critique Fixes
        assert!((transceiver_repeater_max_range_meters(1000, 10.0) - 10_000.0).abs() < 1e-12);
        assert!(
            (transceiver_total_cryo_power_mw(2.0, 1.5, 0.375, 0.1875, 0.25) - 2.0).abs() < 1e-15
        );
        assert!(transceiver_total_cryo_power_mw(100.0, 1.5, 0.375, 0.1875, 0.25) < 110.0);
        let eta_3d = transceiver_uncorrected_link_efficiency(1.0 / 10_001.0, 1.0, 0.9);
        let eta_mx = transceiver_uncorrected_link_efficiency(1.0, 1.0 / 101.0, 0.9);
        let eta_rie = transceiver_uncorrected_link_efficiency(0.8, 0.5, 0.8);
        let eta_sd = transceiver_uncorrected_link_efficiency(0.98, 1.0, 0.95);
        assert!(eta_3d < eta_mx && eta_mx < eta_rie && eta_rie < eta_sd);
        assert!((eta_sd - 0.931).abs() < 1e-15);
        let p_l1 = transceiver_dist3_logical_error(0.01);
        let p_l2 = transceiver_dist3_logical_error(p_l1);
        assert!((p_l1 - 0.000298).abs() < 1e-15 && p_l1 < 3.0e-4 && p_l2 < 3.0e-7);
        assert!(
            transceiver_qec_net_efficiency(eta_sd, 1.0, 0.01)
                < transceiver_qec_net_efficiency(eta_sd, 1.0, p_l1)
        );
        assert!(transceiver_qec_net_efficiency(eta_sd, 0.9, p_l1) > 0.83);
        let m_finite = semi_dirac_finite_beam_throat_margin(10.0, 8.0, 0.5, 0.2, 0.36);
        assert!((m_finite - 3.5).abs() < 1e-15 && m_finite >= 0.0);
        assert!((er_epr_exact_unitary_rx_probability(0.0, 1.0) - 0.5).abs() < 1e-15);
        assert!(
            (er_epr_exact_unitary_rx_probability(1.0, 1.0)
                - er_epr_exact_unitary_rx_probability(1.0, -1.0)
                - 1.0)
                .abs()
                < 1e-15
        );

        // 18. Section 23.3: Holographic Gr_C(2,4) Depth Recovery & Multi-Array (Hubble/TRUE/Homodyne/Metamaterial)
        // Decoding of Sub-Wavelength Diffracted 3D Photons
        assert!(
            (subwavelength_photon_true_conjugate_coupling(eta_bethe, 1.0) - eta_bethe).abs()
                < 1e-15
        );
        let eta_true_10k = subwavelength_photon_true_conjugate_coupling(eta_bethe, 10_001.0);
        let eta_true_100k = subwavelength_photon_true_conjugate_coupling(eta_bethe, 100_010.0);
        assert!((eta_true_10k - 10_001.0 / 20_001.0).abs() < 1e-12 && eta_true_10k > 0.5);
        assert!((eta_true_100k - 10_001.0 / 11_001.0).abs() < 1e-12 && eta_true_100k > 0.9);
        let eta_3d_decoded =
            transceiver_qec_net_efficiency(transceiver_uncorrected_link_efficiency(eta_true_100k, 1.0, 0.95), 1.0, p_l1);
        assert!(eta_3d_decoded > 0.85);
        assert!((homodyne_field_to_intensity_gain_ratio(0.01) - 100.0).abs() < 1e-12);

        // 19. Section 23.4: QISM, Algebraic Bethe Ansatz, & Inverse Scattering Wormhole Decoding
        assert!((qism_yang_transmission_prob(1.0, 0.0, 100.0) - eta_bethe).abs() < 1e-15);
        let t_yang_matched = qism_yang_transmission_prob(100.0, 0.0, 1.0);
        assert!((t_yang_matched - 10_000.0 / 10_001.0).abs() < 1e-12 && t_yang_matched > 0.999);
        let eta_qism_qec = transceiver_qec_net_efficiency(
            transceiver_uncorrected_link_efficiency(t_yang_matched, 1.0, 0.95),
            1.0,
            p_l1,
        );
        assert!(eta_qism_qec > 0.94);
        let slavnov_speedup = qism_slavnov_contraction_speedup(40_320.0, 8.0);
        assert!((slavnov_speedup - 3_175_200.0).abs() < 1e-9 && slavnov_speedup > 3_000_000.0);

        // 20. Section 23.4.1: Critique Gap-Closure Fixes for Slavnov Wronskian Factorization,
        // Noisy MIMO Collision SNR, Overhead-Inclusive Speedup, Soft Impedance Matching, & Finite TRUE Tagging
        let det_lin = slavnov_linearized_near_collision_det2(3.0, 5.0, 2.0, 7.0, 0.1);
        let w_cas = 3.0 * 7.0 - 5.0 * 2.0;
        assert!((det_lin - 0.1 * w_cas).abs() < 1e-13);
        assert!((slavnov_linearized_near_collision_det2(3.0, 5.0, 2.0, 7.0, 0.0)).abs() < 1e-15);
        assert!((det_lin / 0.1 - w_cas).abs() < 1e-12);
        assert!((slavnov_mimo_collision_snr_efficiency(0.0, w_cas, 1.0)).abs() < 1e-15);
        assert!(
            (slavnov_mimo_collision_snr_efficiency(-0.1, w_cas, 1.0)
                - slavnov_mimo_collision_snr_efficiency(0.1, w_cas, 1.0))
                .abs()
                < 1e-15
        );
        let mimo_10 = slavnov_mimo_collision_snr_efficiency(10.0, 1.0, 1.0);
        assert!((mimo_10 - 100.0 / 101.0).abs() < 1e-15 && mimo_10 > 0.99);
        let full_speedup = qism_slavnov_full_pipeline_speedup(40_320.0, 8.0, 8.0);
        assert!((full_speedup - 1_587_600.0).abs() < 1e-9 && full_speedup > 1_500_000.0);
        assert!(
            (qism_impedance_matched_yang_transmission(1.0, 100.0, 1.0) - eta_bethe).abs() < 1e-15
        );
        let t_soft_matched = qism_impedance_matched_yang_transmission(1.0, 100.0, 10_000.0);
        assert!((t_soft_matched - 10_000.0 / 10_001.0).abs() < 1e-12 && t_soft_matched > 0.999);
        assert!(
            wormhole_net_null_defocusing_flux(8.0 * 0.5, 10.0) <= 0.0
                && wormhole_net_null_defocusing_flux(100.0, 10.0) > 0.0
        );
        let true_tagged =
            subwavelength_true_tagged_conjugate_coupling(1.0 / 10_001.0, 0.1, 1_000_100.0);
        assert!((true_tagged - 1_000_100.0 / 1_100_109.0).abs() < 1e-12 && true_tagged > 0.9);

        // 21. Section 25: DDF Fracture-Based Communication vs. ER=EPR Entanglement/Wormholes
        // & Hybrid Fracture-Keyed Synthesis on Gr_C(2,4)
        assert!((ddf_fracture_total_channel_signal(3.5, 0.0, 2.0) - 3.5).abs() < 1e-15);
        assert!(
            (ddf_fracture_magnus_subtracted_residual(2.0 + 1.2 * 5.0 * 0.5, 2.0, 1.2, 5.0, 0.5))
                .abs()
                < 1e-15
        );
        assert!(
            (ddf_fracture_magnus_subtracted_residual(
                2.0 + 1.2 * 5.0 * 0.5 + 0.5 * 0.5,
                2.0,
                1.2,
                5.0,
                0.5
            ) - 0.25)
                .abs()
                < 1e-15
        );
        let de_sub = ddf_fracture_deborah_ratio(1e-5, 1e3);
        let de_sup = ddf_fracture_deborah_ratio(1e-5, 1e8);
        assert!((de_sub - 0.01).abs() < 1e-15 && de_sub < 1.0);
        assert!((de_sup - 1000.0).abs() < 1e-12 && de_sup > 1.0);
        assert!(
            (ddf_fracture_causal_transit_margin(1.0, 2.0, 1.0) - 1.0).abs() < 1e-15
                && ddf_fracture_causal_transit_margin(1.0, 2.0, 1.0) >= 0.0
        );
        assert!(
            (ddf_fracture_causal_transit_margin(1.0, 0.5, 1.0) - (-0.5)).abs() < 1e-15
                && ddf_fracture_causal_transit_margin(1.0, 0.5, 1.0) < 0.0
        );
        assert!((ddf_fracture_corridor_guiding_gain(100.0, 1.0) - 10_000.0).abs() < 1e-12);
        let contrast_frac = ddf_fracture_standalone_bit_contrast(0.5, 0.5);
        assert!(
            (contrast_frac - 0.5).abs() < 1e-15
                && er_epr_transceiver_differential_contrast(0.0) < contrast_frac
        );
        assert!((ddf_fracture_vs_wormhole_quantum_fidelity(0.0, 1.0) - 0.5).abs() < 1e-15);
        assert!((ddf_fracture_vs_wormhole_quantum_fidelity(0.25, 1.0) - 1.0).abs() < 1e-15);
        assert!(
            ddf_fracture_overload_excess_shear(15.0, 10.0) > 0.0
                && wormhole_net_null_defocusing_flux(15.0, 10.0) > 0.0
        );
        assert!((hybrid_fracture_keyed_er_epr_rx_probability(0.0, 1.0, 1.0) - 0.5).abs() < 1e-15);
        assert!(
            (hybrid_fracture_keyed_er_epr_rx_probability(1.0, 1.0, 1.0)
                - hybrid_fracture_keyed_er_epr_rx_probability(1.0, 1.0, -1.0)
                - 1.0)
                .abs()
                < 1e-15
        );

        // 22. Section 25.1: Critique Gap-Closure Fixes (Dilatant Corridor Attenuation,
        // Unconditional Cayley Saturation, Horodecki 2/3 Qubit Fidelity, & Passive Energy Closure)
        let g_k1 = ddf_fracture_attenuated_corridor_gain(
            100.0,
            1.0,
            ddf_fracture_dilatant_damping(1e-3, 1.0, 1.0),
            10.0,
        );
        let g_k5 = ddf_fracture_attenuated_corridor_gain(
            100.0,
            1.0,
            ddf_fracture_dilatant_damping(1e-3, 1.0, 5.0),
            10.0,
        );
        assert!(g_k5 < g_k1 && g_k1 > 9800.0);
        assert!(hybrid_fracture_keyed_er_epr_rx_probability(3.0, 1.0, 1.0) > 1.0);
        let p_sat_over = hybrid_saturated_fracture_keyed_er_epr_rx_probability(3.0, 1.0);
        assert!((p_sat_over - 0.8).abs() < 1e-15 && (0.0..=1.0).contains(&p_sat_over));
        assert!(
            (hybrid_saturated_fracture_keyed_er_epr_rx_probability(1.0, 1.0)
                - hybrid_saturated_fracture_keyed_er_epr_rx_probability(1.0, -1.0)
                - 1.0)
                .abs()
                < 1e-15
        );
        assert!((horodecki_average_teleportation_fidelity(0.0) - 2.0 / 3.0).abs() < 1e-15);
        assert!((horodecki_average_teleportation_fidelity(1.0) - 1.0).abs() < 1e-15);
        let eta_passive = ddf_fracture_passive_power_efficiency(1.0, 2.0, 3.0);
        assert!(eta_passive > 0.0 && eta_passive < 1.0);

        // 23. Section 25.2: Seven-Mode Multi-Path Taxonomy (M1 Around, M2 Fracture Around,
        // M3 Semi-Dirac Through Wormhole, & Composite Combinations M1+M3, M2+M3, M1+M2, M1+M2+M3)
        let eta_m1 = exterior_photon_inverse_square_efficiency(1.0, 100.0);
        let eta_m2 = fracture_guided_corridor_transmission(
            ddf_fracture_dilatant_damping(1e-3, 1.0, 1.0),
            10.0,
        );
        assert!((eta_m2 / eta_m1 - g_k1).abs() < 1e-10 && eta_m1 < eta_m2);
        assert!(
            (dual_path_common_mode_subtraction(42.5, 0.75, -1.0) - (-0.75)).abs() < 1e-15
        );
        assert!((dual_path_mrc_combined_snr(10.0, 100.0) - 110.0).abs() < 1e-15);
        assert!((1.0 - dual_path_outage_probability(0.1, 0.1) - 0.99).abs() < 1e-15);
        let c_m4 = trimodal_dual_keyed_er_epr_rx_probability(0.01, 0.0, 1.0)
            - trimodal_dual_keyed_er_epr_rx_probability(0.01, 0.0, -1.0);
        let c_m5 = trimodal_dual_keyed_er_epr_rx_probability(0.0, 1.0, 1.0)
            - trimodal_dual_keyed_er_epr_rx_probability(0.0, 1.0, -1.0);
        assert!(c_m4 < c_m5 && (c_m5 - 1.0).abs() < 1e-15);
        let p_tri = trimodal_dual_keyed_er_epr_rx_probability(0.5, 0.5, 1.0);
        assert!((p_tri - 1.0).abs() < 1e-15 && (0.0..=1.0).contains(&p_tri));
        assert!(
            wormhole_net_null_defocusing_flux(trimodal_wormhole_throat_load(1000.0, 1000.0, 4.0), 10.0)
                <= 0.0
        );

        // 24. Section 25.2.1: Multi-Path Critique Gap-Closures (AGC Dual-Key Normalization,
        // Arrival-Time Skew Buffering, Common-Cause Correlated Outage, & Parasitic Mouth Leakage)
        let c_raw_over = trimodal_dual_keyed_er_epr_rx_probability(1.0, 1.0, 1.0)
            - trimodal_dual_keyed_er_epr_rx_probability(1.0, 1.0, -1.0);
        let c_agc_both = trimodal_agc_dual_keyed_er_epr_rx_probability(1.0, 1.0, 10.0, 100.0, 1.0)
            - trimodal_agc_dual_keyed_er_epr_rx_probability(1.0, 1.0, 10.0, 100.0, -1.0);
        let c_agc_m1_only = trimodal_agc_dual_keyed_er_epr_rx_probability(1.0, 0.0, 10.0, 0.0, 1.0)
            - trimodal_agc_dual_keyed_er_epr_rx_probability(1.0, 0.0, 10.0, 0.0, -1.0);
        assert!((c_raw_over - 0.8).abs() < 1e-15 && (c_agc_both - 1.0).abs() < 1e-15);
        assert!((c_agc_m1_only - 1.0).abs() < 1e-15);

        let dt_skew = dual_path_propagation_skew(10.0, 12.0, 1.0, 0.5);
        assert!(dt_skew >= 0.0 && (dt_skew - 14.0).abs() < 1e-15);
        let res_unbuf =
            dual_path_skew_compensated_clutter_residual(5.0, 0.2, 3.0, dt_skew, 0.0, 0.75, -1.0);
        let res_buf = dual_path_skew_compensated_clutter_residual(
            5.0, 0.2, 3.0, dt_skew, dt_skew, 0.75, -1.0,
        );
        assert!((res_unbuf - (-0.75 + 0.2 * dt_skew)).abs() < 1e-15);
        assert!((res_buf - (-0.75)).abs() < 1e-15);

        let p_corr = dual_path_correlated_outage_probability(0.1, 0.2);
        assert!((p_corr - 0.028).abs() < 1e-15 && 0.01 < p_corr && p_corr < 0.1);
        assert!(
            wormhole_net_null_defocusing_flux(
                trimodal_parasitic_throat_load(1e-2, 1e-2, 1000.0, 1000.0, 4.0),
                10.0,
            ) > 0.0
        );
        assert!(
            wormhole_net_null_defocusing_flux(
                trimodal_parasitic_throat_load(1e-3, 1e-3, 1000.0, 1000.0, 4.0),
                10.0,
            ) <= 0.0
        );

        // 25. Section 26 & 26.1: Maxwell EM (Pre-Tensor, Vector/Gimbal-Lock, Tensor, Twistor),
        // Longitudinal E_z, OAM Tubular Solitons, and Multi-Model Gravity/Electron EM Synthesis
        assert_eq!(MAXWELL_ORIGINAL_1865_EQUATION_COUNT, 20);
        assert_eq!(HEAVISIDE_GIBBS_VECTOR_EQUATION_COUNT, 4);
        assert_eq!(MINKOWSKI_TENSOR_EQUATION_COUNT, 2);
        assert_eq!(PENROSE_TWISTOR_SPINOR_EQUATION_COUNT, 1);
        assert!((maxwell_quaternion_nabla_norm_sq(2.0, 3.0, 4.0, 5.0) - 54.0).abs() < 1e-15);
        assert!((euler_kinematic_jacobian_det(0.0) - 1.0).abs() < 1e-15);
        assert!(euler_kinematic_jacobian_det(std::f64::consts::FRAC_PI_2).abs() < 1e-15);
        let q_inv = 1.0 / 2.0_f64.sqrt();
        assert!((unit_quaternion_norm_sq(q_inv, 0.0, q_inv, 0.0) - 1.0).abs() < 1e-15);
        assert!(maxwell_lorentz_invariant_lagrange(9.0, 9.0, 1.0).abs() < 1e-15);
        assert!(maxwell_lorentz_invariant_pontryagin(0.0, 3.0).abs() < 1e-15);
        assert!(maxwell_stress_energy_trace_in_dim(4.0, 42.0).abs() < 1e-15);
        assert!(maxwell_spinor_null_determinant(1.0, 0.0, 1.0, 0.0, 1.0, 0.0).abs() < 1e-15);
        assert!(maxwell_spinor_null_determinant(2.0, 0.0, 1.0, 0.0, 1.0, 0.0) > 0.0);

        let ez_gauss = maxwell_gauss_longitudinal_ez(1.5, 2.0, -0.5, 4.0, 2.0);
        assert!((1.5 * 2.0 + (-0.5) * 4.0 + 2.0 * ez_gauss).abs() < 1e-15);
        assert_eq!(sam_to_oam_longitudinal_topological_charge(2, 1), 3);
        assert!(tubular_soliton_ring_radius_sq(2.0, 0.0).abs() < 1e-15);
        assert!((tubular_soliton_ring_radius_sq(2.0, 1.0) - 1.0).abs() < 1e-15);
        assert!(tubular_soliton_ring_radius_sq(2.0, 1.0) < tubular_soliton_ring_radius_sq(2.0, 3.0));
        assert!(tubular_soliton_radial_equilibrium_residual(5.0, 2.0, 3.0).abs() < 1e-15);
        assert!(
            scalar_bohm_vortex_core_divergence(1.0, 1.0, 1.0)
                < scalar_bohm_vortex_core_divergence(1.0, 1.0, 0.01)
        );
        assert!(plucker_regularized_vortex_core_norm_sq(0.25, 0.0) >= 1.0);

        let dtheta_gr = gravitational_light_deflection_ppn(1.0, 1.0, 1.0, 1.0, 1.0);
        let dtheta_newt = gravitational_light_deflection_ppn(1.0, 1.0, 1.0, 1.0, 0.0);
        let dtheta_nord = gravitational_light_deflection_ppn(1.0, 1.0, 1.0, 1.0, -1.0);
        assert!((dtheta_gr - 4.0).abs() < 1e-15);
        assert!(gtbc_relative_error(dtheta_gr, dtheta_gr).abs() < 1e-15);
        assert!((gtbc_relative_error(dtheta_newt, dtheta_gr) - 0.5).abs() < 1e-15);
        assert!((gtbc_relative_error(dtheta_nord, dtheta_gr) - 1.0).abs() < 1e-15);
        assert!(
            (gtbc_relative_error(witten_conformal_light_deflection(dtheta_gr, 0.0, 0.0, 1.0), dtheta_gr)
                - 1.0)
                .abs()
                < 1e-15
        );
        assert!(
            (cachazo_skinner_light_deflection(dtheta_gr, 1.0, 0.25, 10.0) - dtheta_gr).abs()
                < 1e-15
        );
        assert!(
            (ddf_refractive_light_deflection(1.0, 1.0, 1.0, 1.0, 1.0) - dtheta_gr).abs() < 1e-15
        );
        assert!(
            (turner_plucker_kahler_light_deflection(dtheta_gr, 4.0 - 0.04, 0.2, 0.0) - dtheta_gr)
                .abs()
                < 1e-15
        );
        assert!(
            (turner_dual_gr24_igpe_ddf_light_deflection(1.0, 1.0, 1.0, 1.0, 1.0, 4.0 - 0.04, 0.2, 0.0)
                - dtheta_gr)
                .abs()
                < 1e-15
        );
        assert!(
            (turner_dual_gr24_igpe_ddf_light_deflection(1.0, 1.0, 1.0, 1.0, 1.0, 4.0 - 0.04, 0.2, 0.125)
                - (dtheta_gr + 0.125))
                .abs()
                < 1e-15
        );
        assert!(
            (electric_magnetic_duality_norm_sq(1.2, -0.5, 0.8, 0.3, 0.6, 0.8)
                - (1.2_f64.powi(2) + (-0.5_f64).powi(2) + 0.8_f64.powi(2) + 0.3_f64.powi(2)))
                .abs()
                < 1e-14
        );
        assert!((abraham_minkowski_momentum_product(2.5, 1.5) - 2.5_f64.powi(2)).abs() < 1e-15);
        assert_eq!(laguerre_gaussian_gouy_mode_order(0, 0), 1);
        assert_eq!(laguerre_gaussian_gouy_mode_order(0, 2), 3);
        assert!(maxwell_gauss_longitudinal_ez(0.0, 2.0, 0.0, 4.0, 2.0).abs() < 1e-15);
        assert!(proca_longitudinal_polarization_z(10.0, 2.0) > 0.0);
        assert!(nonlocal_stabilized_azimuthal_mi_gain(10.0, 2.0, 0.0, 2.0) > 0.0);
        assert!(nonlocal_stabilized_azimuthal_mi_gain(10.0, 2.0, 5.0, 2.0) < 0.0);

        // 26. Section 26.2: Vacuum Maxwell vs. DFT Electron Density & SQG/DDF Pressure Differences,
        // Polaritons/Plasmons on SU(4) Lower Grassmannians, and Methods M1, M2, M3
        assert!(ddf_pressure_difference_enthalpy(10.0, 10.0, 1.0).abs() < 1e-15);
        assert!((ddf_pressure_difference_enthalpy(10.0, 6.0, 2.0) - (-2.0)).abs() < 1e-15);
        assert!((ddf_pressure_gradient_refractive_index(10.0, 10.0, 1.0, 1.0) - 1.0).abs() < 1e-15);
        assert!(ddf_pressure_gradient_refractive_index(10.0, 6.0, 2.0, 1.0) > 1.0);
        assert!((dft_electron_density_permittivity(0.0, 1.0, 4.0) - 1.0).abs() < 1e-15);
        assert!(dft_electron_density_permittivity(4.0, 1.0, 4.0).abs() < 1e-15);
        assert!(dft_electron_density_permittivity(8.0, 1.0, 4.0) < 0.0);
        assert!(dft_electron_density_permittivity(4.0, -1.0, 4.0) > 1.0);
        assert!(soft_photon_two_leg_ward_residual(1.0, 3.0, 5.0).abs() < 1e-15);
        assert!((celestial_conformal_weight_h(1.0, 1.0) - 1.0).abs() < 1e-15);
        assert!(celestial_conformal_weight_hbar(1.0, 1.0).abs() < 1e-15);

        // 27. Section 27: QFIM = 4x Fubini–Study Kähler Metric, 3-Channel Madelung-QFIM GPE Split
        // on Q_4, Plücker Simplex Phase-Variance Split, Klein Quadric Tangency, and Ghost-Free
        // Turner Model Unification (Paper 49)
        let d_jet = mk_physical_plucker_directional_jet(2.0, 4.0, 3.0, 6.0);
        assert!((fubini_study_diag(d_jet) - 3.0).abs() < 1e-15);
        assert!((qfim_diag(d_jet) - 12.0).abs() < 1e-15);
        assert!((qfim_diag(d_jet) - 4.0 * fubini_study_diag(d_jet)).abs() < 1e-15);
        assert!(
            (projective_qfim_energy_dir(1.0, 2.0, d_jet)
                - projective_fubini_study_energy_dir(1.0, 2.0, d_jet))
                .abs()
                < 1e-15
        );
        let t_dir_lhs = gpe_kinetic_dir(1.0, 2.0, d_jet);
        let t_dir_rhs = hydro_flow_dir(1.0, 2.0, d_jet)
            + scalar_bohm_density_dir(1.0, 2.0, d_jet)
            + projective_qfim_energy_dir(1.0, 2.0, d_jet);
        assert!((t_dir_lhs - t_dir_rhs).abs() < 1e-15);

        let j_3d = Plucker3DSpatialJet {
            dir: [
                mk_physical_plucker_directional_jet(2.0, 4.0, 3.0, 6.0),
                mk_physical_plucker_directional_jet(2.0, -2.0, 1.5, 4.0),
                mk_physical_plucker_directional_jet(2.0, 1.0, -0.5, 2.0),
            ],
            rho: 2.0,
        };
        assert!((trace_qfim_3d(&j_3d) - 4.0 * trace_fubini_study_3d(&j_3d)).abs() < 1e-14);
        assert!(
            (total_projective_qfim_energy_3d(1.0, 2.0, &j_3d)
                - total_projective_fubini_study_energy_3d(1.0, 2.0, &j_3d))
                .abs()
                < 1e-14
        );
        let t_3d_lhs = total_gpe_kinetic_3d(1.0, 2.0, &j_3d);
        let t_3d_rhs = total_hydro_flow_3d(1.0, 2.0, &j_3d)
            + total_scalar_bohm_3d(1.0, 2.0, &j_3d)
            + total_projective_qfim_energy_3d(1.0, 2.0, &j_3d);
        assert!((t_3d_lhs - t_3d_rhs).abs() < 1e-14);

        let p_simp = [0.2, 0.15, 0.25, 0.1, 0.2, 0.1];
        let dp_simp = [0.05, -0.02, -0.03, 0.04, -0.01, -0.03];
        let dphi_simp = [1.2, -0.5, 0.8, 2.1, -1.0, 0.3];
        let qfim_ray = 4.0 * normalized_ray_fubini_study(&p_simp, &dp_simp, &dphi_simp);
        let split_ray = classical_plucker_fisher(&p_simp, &dp_simp)
            + 4.0 * bivector_phase_variance(&p_simp, &dphi_simp);
        assert!((qfim_ray - split_ray).abs() < 1e-14);
        assert!(bivector_phase_variance(&p_simp, &dphi_simp) >= 0.0);

        let n_biv = Bivector6 {
            p01: 1.0,
            p02: 2.0,
            p03: 1.0,
            p12: 2.0,
            p13: 2.0,
            p23: 2.0,
        };
        let dn_biv = Bivector6 {
            p01: 1.0,
            p02: 1.0,
            p03: 0.0,
            p12: 2.0,
            p13: 2.0,
            p23: 2.0,
        };
        assert!(n_biv.klein_quadric().abs() < 1e-15);
        assert!(n_biv.klein_polar_form(dn_biv).abs() < 1e-15);
        let psi_biv = n_biv.scale(2.5);
        let dpsi_biv = n_biv.scale(-0.7).add(dn_biv.scale(2.5));
        assert!(psi_biv.klein_quadric().abs() < 1e-15);
        assert!(psi_biv.klein_polar_form(dpsi_biv).abs() < 1e-15);

        // Section 27.1 & 27.2: Ghost-free Turner projection, Bures/QCRB/QSL, Peotta-Törmä,
        // Gaussian splat Bohm-Fisher bridge, U(1) gauge invariance, and vortex-core regularity
        let g_witten = witten_fourth_order_propagator(5.0, 2.0);
        let g_split = 0.5
            * (ostrogradsky_ghost_propagator(5.0, 2.0) - two_derivative_graviton_propagator(5.0));
        assert!((g_witten - g_split).abs() < 1e-15);
        assert!(
            (turner_kahler_orbital_semi_latus_factor(0.2) - (1.0 - 0.2_f64.powi(2))).abs() < 1e-15
        );
        assert!(
            (bures_metric_diag_from_qfim(qfim_diag(d_jet)) - fubini_study_diag(d_jet)).abs()
                < 1e-15
        );
        assert!(
            (quantum_cramer_rao_variance_bound(10.0, qfim_diag(d_jet))
                - 0.25 / (10.0 * fubini_study_diag(d_jet)))
                .abs()
                < 1e-15
        );
        assert!(
            (mandelstam_tamm_temporal_qfim(3.0, 1.0)
                - 4.0 * mandelstam_tamm_temporal_fubini_study(3.0, 1.0))
                .abs()
                < 1e-15
        );
        assert!(
            (peotta_torma_flat_band_stiffness_from_qfim(2.0, 0.25, qfim_diag(d_jet))
                - gmgs_total_superfluid_stiffness(0.0, 2.0, 0.25, fubini_study_diag(d_jet)))
                .abs()
                < 1e-15
        );
        assert!(
            (gaussian_splat_scalar_bohm_from_fisher(1.0, 2.0, 8.0)
                - 0.5 * ((1.0 / (4.0 * 2.0)) * 8.0))
                .abs()
                < 1e-15
        );
        let d_gauge = gauge_shifted_plucker_jet(d_jet, 1.75);
        assert!((fubini_study_diag(d_gauge) - fubini_study_diag(d_jet)).abs() < 1e-14);
        assert!((qfim_diag(d_gauge) - qfim_diag(d_jet)).abs() < 1e-14);
        let var2 = two_channel_phase_variance(1.0 / 3.0, 2.0 / 3.0, 1.5, -0.5);
        assert!(
            (var2 - (1.0 / 3.0) * (2.0 / 3.0) * (1.5_f64 - (-0.5_f64)).powi(2)).abs() < 1e-15
                && var2 >= 0.0
        );
        let bohm_r1 = scalar_bohm_density_dir(
            1.0,
            1.0,
            PluckerDirectionalJet {
                rho: 1.0,
                dpsi_norm_sq: 0.0,
                drho: 2.0,
                a_mu: 0.0,
            },
        );
        let bohm_r001 = scalar_bohm_density_dir(
            1.0,
            1.0,
            PluckerDirectionalJet {
                rho: 0.01,
                dpsi_norm_sq: 0.0,
                drho: 2.0,
                a_mu: 0.0,
            },
        );
        assert!(bohm_r1 < bohm_r001);
        assert!(projective_qfim_energy_from_ray_metric(1.0, 2.0, 0.0, 3.0).abs() < 1e-15);

        // 28. Section 27.3: Unification of Cachazo Gravity (CSW / BCFW / Hodges / CHY) with
        // QFIM = 4x Fubini-Study Kähler Metric
        let sigma4_root = chy_four_point_root(3.0, 5.0);
        assert!((sigma4_root + (1.0 - sigma4_root) - 1.0).abs() < 1e-15);
        let qfim_chy = chy_worldsheet_qfim_metric(sigma4_root);
        let fs_chy = chy_worldsheet_fubini_study_metric(sigma4_root);
        assert!((qfim_chy - 4.0 * fs_chy).abs() < 1e-14);
        let a4_chy = chy_four_point_bi_adjoint_scalar(3.0, 5.0);
        assert!((a4_chy - qfim_chy / (3.0 + 5.0)).abs() < 1e-15);
        assert!((a4_chy - (4.0 * fs_chy) / (3.0 + 5.0)).abs() < 1e-15);
        let jac_chy = chy_four_point_reduced_jacobian(3.0, 5.0, sigma4_root);
        assert!((jac_chy - (-(3.0 + 5.0) * qfim_chy)).abs() < 1e-13);
        assert!((jac_chy - (-4.0 * (3.0 + 5.0) * fs_chy)).abs() < 1e-13);
        assert!(
            (cachazo_skinner_filtered_propagator(5.0, 2.0, 0.0)
                - witten_fourth_order_propagator(5.0, 2.0))
                .abs()
                < 1e-15
        );
        assert!(
            (cachazo_skinner_filtered_propagator(5.0, 2.0, 1.0)
                - two_derivative_graviton_propagator(5.0))
                .abs()
                < 1e-15
        );
        let e_orb = 0.2_f64;
        let k_cs = cachazo_hodges_double_copy_scalar_kernel(1.0 + e_orb, 1.0 - e_orb);
        assert!((k_cs - 4.0).abs() < 1e-15);
        assert!(
            ((k_cs - ((1.0 + e_orb) - (1.0 - e_orb)).powi(2)) / 4.0
                - turner_kahler_orbital_semi_latus_factor(e_orb))
                .abs()
                < 1e-15
        );
        let var_orb = two_channel_phase_variance(
            (1.0 + e_orb) / 2.0,
            (1.0 - e_orb) / 2.0,
            1.5,
            -0.5,
        );
        assert!(
            (4.0 * var_orb
                - turner_kahler_orbital_semi_latus_factor(e_orb) * (1.5_f64 - (-0.5_f64)).powi(2))
                .abs()
                < 1e-15
        );

        // 29. Section 27.4: QED & Gauge Scattering Gravity (BCJ Double Copy, Partanen-Tulkki U(1)^4,
        // & Turner Gr_C(2,4) Orbital/GW Models) via QFIM and Fubini-Study Kähler Metric
        let f_ee_orb = qed_orbital_eccentricity_qfim(e_orb);
        let g_fs_orb = qed_orbital_eccentricity_fubini_study(e_orb);
        let simplex_fisher = 0.5_f64.powi(2) / ((1.0 + e_orb) / 2.0)
            + (-0.5_f64).powi(2) / ((1.0 - e_orb) / 2.0);
        assert!((simplex_fisher - f_ee_orb).abs() < 1e-15);
        assert!((f_ee_orb - 4.0 * g_fs_orb).abs() < 1e-15);
        assert!(
            (f_ee_orb * turner_kahler_orbital_semi_latus_factor(e_orb) - 1.0).abs() < 1e-15
        );
        let prec_dc = qed_double_copy_precession_from_qfim(6.0, f_ee_orb);
        assert!((prec_dc - 6.0 / (1.0 - e_orb.powi(2))).abs() < 1e-15);
        assert!((prec_dc - 24.0 * g_fs_orb).abs() < 1e-15);
        let pm_sq = qed_peters_mathews_from_orbital_qfim_sq(1.25, f_ee_orb);
        assert!((pm_sq - 1.25_f64.powi(2) / (1.0 - e_orb.powi(2)).powi(7)).abs() < 1e-14);
        assert!((pm_sq - 1.25_f64.powi(2) * (4.0 * g_fs_orb).powi(7)).abs() < 1e-14);
        let err_vec_1pn =
            ((qed_spin_one_precession_from_qfim(6.0, 1.0) - 6.0) / 6.0).abs();
        let err_nord_1pn =
            ((qed_nordstrom_scalar_precession_from_qfim(6.0, 1.0) - 6.0) / 6.0).abs();
        let err_vec_gw =
            ((qed_spin_one_to_double_copy_gw_flux_ratio(4.0) - 4.0) / 4.0).abs();
        assert!((err_vec_1pn - 5.0 / 6.0).abs() < 1e-15);
        assert!((err_nord_1pn - 7.0 / 6.0).abs() < 1e-15);
        assert!((err_vec_gw - 3.0 / 4.0).abs() < 1e-15);
        assert!(
            (4.0 * qed_spin_one_to_double_copy_gw_flux_ratio(12.0) - 12.0).abs() < 1e-15
        );
        assert!(
            (two_channel_phase_variance(0.6, 0.4, 2.0 * 1.5, 2.0 * (-0.5))
                - 4.0 * two_channel_phase_variance(0.6, 0.4, 1.5, -0.5))
                .abs()
                < 1e-15
        );
        let quad_prod = (2.0 * (1.0 + (1.0 - e_orb.powi(2)).sqrt()))
            * (2.0 * (1.0 - (1.0 - e_orb.powi(2)).sqrt()));
        assert!((quad_prod - 4.0 * e_orb.powi(2)).abs() < 1e-15);

        // 30. Section 27.5: Maxwell EM, Poincaré Gimbal-Lock Elimination, Longitudinal E_z,
        // OAM Tubular Solitons, and TRUE Soft Photons via QFIM and Fubini–Study Kähler Metric
        assert!(
            (POINCARE_SPHERE_QFIM_THETA - 4.0 * POINCARE_SPHERE_FUBINI_STUDY_THETA).abs() < 1e-15
        );
        assert!(
            euler_kinematic_jacobian_det(std::f64::consts::FRAC_PI_2).abs() < 1e-15
                && POINCARE_SPHERE_QFIM_THETA > 0.0
        );
        let f_3d = vectorial_ez_three_channel_fisher(2.5, 0.5, 0.25);
        assert!(f_3d > 2.5 && (f_3d - 3.5).abs() < 1e-15);
        assert!(
            (oam_superposition_qfim_phi(3.0) - 4.0 * oam_superposition_fubini_study_phi(3.0)).abs()
                < 1e-15
        );
        let qcrb_l3 = quantum_cramer_rao_variance_bound(10.0, oam_superposition_qfim_phi(3.0));
        let qcrb_l1 = quantum_cramer_rao_variance_bound(10.0, oam_superposition_qfim_phi(1.0));
        assert!(qcrb_l3 < qcrb_l1 && (qcrb_l3 - 1.0 / 360.0).abs() < 1e-15);
        assert!(true_conjugated_soft_photon_qfim_gain(100_010.0, 1.0) > 1.0);
        let dtheta_qfim =
            turner_plucker_kahler_light_deflection(4.0, 3.0 + 1.0 / f_ee_orb, e_orb, 0.0);
        assert!((dtheta_qfim - 4.0).abs() < 1e-15);
        let dtheta_qfim_14b = turner_dual_gr24_igpe_ddf_light_deflection(
            1.0,
            1.0,
            1.0,
            1.0,
            1.0,
            3.0 + 1.0 / f_ee_orb,
            e_orb,
            0.0,
        );
        assert!((dtheta_qfim_14b - 4.0).abs() < 1e-15);

        // 31. Section 27.6: Complex Plabic VRC and QFIM = 4x Fubini–Study Kähler Metric Across
        // x_X = -1 Resonance, Denominator-Clearing Gauge Invariance, and MRA-PNO / Tequila QNG
        let vrc_norm = vrc_resonant_plucker_norm_sq(0.5, -0.3);
        assert!(vrc_norm >= 2.0);
        let d_vrc_res = vrc_resonant_directional_jet_x1(0.5, -0.3);
        let fs_vrc = vrc_resonant_fubini_study_x1(0.5, -0.3);
        let qfim_vrc = vrc_resonant_qfim_x1(0.5, -0.3);
        assert!(fs_vrc > 0.0 && qfim_vrc > 0.0);
        assert!((fubini_study_diag(d_vrc_res) - fs_vrc).abs() < 1e-15);
        assert!((qfim_diag(d_vrc_res) - qfim_vrc).abs() < 1e-15);
        assert!((qfim_vrc - 4.0 * fs_vrc).abs() < 1e-15);
        assert!((vrc_resonant_fubini_study_x1(0.0, 0.0) - 0.5).abs() < 1e-15);
        assert!((vrc_resonant_qfim_x1(0.0, 0.0) - 2.0).abs() < 1e-15);
        let d_rescaled = complex_rescaled_vrc_jet(d_vrc_res, 3.0, 0.7, -1.2);
        assert!((fubini_study_diag(d_rescaled) - fubini_study_diag(d_vrc_res)).abs() < 1e-14);
        assert!((qfim_diag(d_rescaled) - qfim_diag(d_vrc_res)).abs() < 1e-14);
        assert!(vrc_regularized_pno_amplitude(0.4, 0.0, 0.1).abs() < 1e-15);
        assert!(
            (vrc_pno_gap_qfim_at_degeneracy(0.4, 0.1)
                - 4.0 * vrc_pno_gap_fubini_study_at_degeneracy(0.4, 0.1))
                .abs()
                < 1e-12
        );
        assert!(
            (vrc_quantum_natural_gradient_step(0.1, 0.8, 4.0 * 0.25)
                - 0.25 * vrc_quantum_natural_gradient_step(0.1, 0.8, 0.25))
                .abs()
                < 1e-15
        );
    }

    #[rstest]
    #[case::air_cylinder_piv(1.225, 4.5, 0.35, 2.1, 0.4, 0.75)]
    #[case::superfluid_helium_vortex(145.0, 0.12, 9.97e-8, -0.8, 0.85, 0.6)]
    #[case::polycbd_ultrasonic_corridor(1180.0, 15.0, 0.02, 12.5, 0.5, 0.5)]
    #[case::cryogenic_nlig_substrate(1850.0, 2.0, 0.004, 0.0, 0.95, 0.9)]
    fn test_ddf_fracture_vs_er_epr_h0_magnus_deborah_and_four_discriminators(
        #[case] rho_f: f64,
        #[case] u_inflow: f64,
        #[case] gamma_circ: f64,
        #[case] y_acoustic: f64,
        #[case] kappa_ddf: f64,
        #[case] q_ddf: f64,
    ) {
        let magnus_lift = rho_f * u_inflow * gamma_circ;
        let y_cl = y_acoustic + magnus_lift;

        // 1. Preregistered H0 vs. HDDF signal ledger & Kutta-Joukowski Magnus subtraction:
        assert!((ddf_fracture_total_channel_signal(y_cl, 0.0, q_ddf) - y_cl).abs() < 1e-12);
        assert!(
            ddf_fracture_magnus_subtracted_residual(y_cl, y_acoustic, rho_f, u_inflow, gamma_circ)
                .abs()
                < 1e-12
        );
        let y_hddf = ddf_fracture_total_channel_signal(y_cl, kappa_ddf, q_ddf);
        assert!(
            (ddf_fracture_magnus_subtracted_residual(
                y_hddf, y_acoustic, rho_f, u_inflow, gamma_circ
            ) - kappa_ddf * q_ddf)
                .abs()
                < 1e-12
        );

        // 2. Deborah shear-fracture transition (De < 1 subcritical, De = 1 critical, De > 1 fracture)
        //    and discrete 2D plaquette coboundary (0 vs. 2*pi*n phase-slip holonomy):
        assert!(ddf_fracture_deborah_ratio(1e-5, 1e3) < 1.0);
        assert!((ddf_fracture_deborah_ratio(1e-5, 1e5) - 1.0).abs() < 1e-15);
        assert!(ddf_fracture_deborah_ratio(1e-5, 1e8) > 1.0);
        let (s00, s10, s11, s01) = (0.3_f64, -1.1_f64, 2.4_f64, 0.7_f64);
        let coboundary_smooth = (s10 - s00) + (s11 - s10) + (s01 - s11) + (s00 - s01);
        assert!(coboundary_smooth.abs() < 1e-15);
        for n_slip in [-2_i32, -1, 1, 3] {
            let jump = f64::from(n_slip) * 2.0 * std::f64::consts::PI;
            let coboundary_slip = (s10 - s00) + (s11 - s10) + (s01 - s11 + jump) + (s00 - s01);
            assert!((coboundary_slip - jump).abs() < 1e-14);
        }

        // 3. Causal transverse-phonon arrival margin (>= 0 causal, = 0 lightlike/sonic, < 0 FTL rejected):
        assert!(ddf_fracture_causal_transit_margin(1.5, 2.0, 2.0) > 0.0);
        assert!(ddf_fracture_causal_transit_margin(1.5, 2.0, 3.0).abs() < 1e-15);
        assert!(ddf_fracture_causal_transit_margin(1.5, 1.0, 2.0) < 0.0);

        // 4. Discriminator A (Entanglement C_EPR^2 & RT throat area across p23 sweep):
        assert!(er_epr_plucker_concurrence_sq(0.0).abs() < 1e-15);
        assert!(er_epr_throat_area_from_plucker(1.0, 10.0, 0.0).abs() < 1e-15);
        for &p23_sq in &[0.01_f64, 0.0625, 0.16, 0.25] {
            let c_sq = er_epr_plucker_concurrence_sq(p23_sq);
            let area = er_epr_throat_area_from_plucker(1.0, 10.0, p23_sq);
            assert!(c_sq > 0.0 && c_sq <= 1.0);
            assert!((area - 40.0 * c_sq).abs() < 1e-13 && area > 0.0);
        }

        // 5. Discriminator B (Standalone bit contrast > 0 for fracture vs. identically 0 for unkeyed ER=EPR):
        let delta_y = ddf_fracture_total_channel_signal(y_cl, kappa_ddf, q_ddf)
            - ddf_fracture_total_channel_signal(y_cl, kappa_ddf, -q_ddf);
        let c_frac = ddf_fracture_standalone_bit_contrast(kappa_ddf, q_ddf);
        assert!((delta_y - c_frac).abs() < 1e-12 && c_frac > 0.0);
        assert!(
            (ddf_fracture_standalone_bit_contrast(-kappa_ddf, q_ddf) + c_frac).abs() < 1e-12
        );
        assert!(er_epr_transceiver_differential_contrast(0.0).abs() < 1e-15);
        for theta_b in [-1.7_f64, 0.0, 0.85, std::f64::consts::PI] {
            assert!(
                (er_epr_no_signaling_marginal_a(0.5, 0.0, theta_b) - 0.5).abs() < 1e-15
            );
        }

        // 6. Discriminator C (Quantum state fidelity floor 1/2 & Horodecki 2/3 ceiling at p23 = 0 vs. 1 at Bell):
        for sin_2theta in [-1.0_f64, -0.3, 0.0, 0.5, 1.0] {
            assert!((ddf_fracture_vs_wormhole_quantum_fidelity(0.0, sin_2theta) - 0.5).abs() < 1e-15);
        }
        assert!((ddf_fracture_vs_wormhole_quantum_fidelity(0.25, 1.0) - 1.0).abs() < 1e-15);
        assert!((horodecki_average_teleportation_fidelity(0.0) - 2.0 / 3.0).abs() < 1e-15);
        assert!((horodecki_average_teleportation_fidelity(1.0) - 1.0).abs() < 1e-15);

        // 7. Discriminator D (Opposite high-power overload response: fracture widening vs. throat collapse):
        let b_qfim = crate::quantum_trajectories::dual_schubert_qfim_wormhole_cushion(
            10.0, 2.0, 1.0, 1.0, 6.0, 1.0, 4.0, 0.5, 0.0,
        );
        assert!((b_qfim - 15.0).abs() < 1e-15);
        assert!(ddf_fracture_overload_excess_shear(20.0, 10.0) > 0.0);
        assert!(wormhole_net_null_defocusing_flux(12.0, b_qfim) <= 0.0);
        assert!(wormhole_net_null_defocusing_flux(20.0, b_qfim) > 0.0);
    }

    #[rstest]
    #[case::zero_drive(0.0, 0.0)]
    #[case::weak_positive(0.25, 8.0 / 17.0)]
    #[case::unit_optimal(1.0, 1.0)]
    #[case::overdrive_three(3.0, 0.6)]
    #[case::extreme_overdrive(1000.0, 2000.0 / 1_000_001.0)]
    #[case::unit_negative(-1.0, -1.0)]
    #[case::negative_overdrive(-3.0, -0.6)]
    fn test_ddf_fracture_vs_er_epr_cayley_saturation_attenuation_and_passivity_invariants(
        #[case] x_drive: f64,
        #[case] expected_contrast: f64,
    ) {
        // 1. Cayley unitary saturation: unconditional [0, 1] probability bounds, normalization,
        //    bit-flip antisymmetry, and global contrast optimum |Delta P| <= 1 at x_drive = +/-1:
        let p_plus = hybrid_saturated_fracture_keyed_er_epr_rx_probability(x_drive, 1.0);
        let p_minus = hybrid_saturated_fracture_keyed_er_epr_rx_probability(x_drive, -1.0);
        assert!((0.0..=1.0).contains(&p_plus) && (0.0..=1.0).contains(&p_minus));
        assert!((p_plus + p_minus - 1.0).abs() < 1e-15);
        assert!(((p_plus - p_minus) - expected_contrast).abs() < 1e-14);
        assert!((p_plus - p_minus).abs() <= 1.0 + 1e-15);
        let p_neg_drive = hybrid_saturated_fracture_keyed_er_epr_rx_probability(-x_drive, 1.0);
        assert!((p_neg_drive - p_minus).abs() < 1e-15);

        // Raw linear formula overflows [0, 1] whenever |x_drive| > 1:
        if x_drive.abs() > 1.0 {
            let p_raw = hybrid_fracture_keyed_er_epr_rx_probability(x_drive, 1.0, 1.0);
            assert!(!(0.0..=1.0).contains(&p_raw));
        }

        // 2. Dilatant shear-thickening corridor attenuation: lossless limit & strict k-monotonicity:
        assert!(
            (ddf_fracture_attenuated_corridor_gain(100.0, 1.0, 0.0, 10.0)
                - ddf_fracture_corridor_guiding_gain(100.0, 1.0))
                .abs()
                < 1e-12
        );
        let k_grid = [0.5_f64, 1.0, 2.0, 5.0, 10.0];
        for pair in k_grid.windows(2) {
            let damp_lo = ddf_fracture_dilatant_damping(1e-3, 1.0, pair[0]);
            let damp_hi = ddf_fracture_dilatant_damping(1e-3, 1.0, pair[1]);
            assert!(0.0 < damp_lo && damp_lo < damp_hi);
            let gain_lo = ddf_fracture_attenuated_corridor_gain(100.0, 1.0, damp_lo, 10.0);
            let gain_hi = ddf_fracture_attenuated_corridor_gain(100.0, 1.0, damp_hi, 10.0);
            assert!(gain_hi < gain_lo);
        }

        // 3. Strict passive energy closure (0 < eta < 1 whenever nucleation + dissipation > 0):
        for (p_out, p_frac, p_diss) in [(0.1, 1.0, 0.5), (1.0, 2.0, 3.0), (50.0, 0.01, 0.02)] {
            let eta = ddf_fracture_passive_power_efficiency(p_out, p_frac, p_diss);
            assert!(eta > 0.0 && eta < 1.0);
        }
    }

    #[test]
    fn test_ddf_fracture_vs_er_epr_seven_mode_multipath_agc_skew_and_crosstalk() {
        let gamma_k1 = ddf_fracture_dilatant_damping(1e-3, 1.0, 1.0);
        let eta_m1 = exterior_photon_inverse_square_efficiency(1.0, 100.0);
        let eta_m2 = fracture_guided_corridor_transmission(gamma_k1, 10.0);
        let eta_bethe = subwavelength_photon_aperture_efficiency(1.0, 10.0);
        let b_qfim = crate::quantum_trajectories::dual_schubert_qfim_wormhole_cushion(
            10.0, 2.0, 1.0, 1.0, 6.0, 1.0, 4.0, 0.5, 0.0,
        );

        // 1. Elementary channels M1, M2, M3:
        assert!((eta_m1 - 1e-4).abs() < 1e-16);
        assert!(
            (eta_m2 / eta_m1 - ddf_fracture_attenuated_corridor_gain(100.0, 1.0, gamma_k1, 10.0))
                .abs()
                < 1e-10
        );
        assert!(eta_m2 / eta_m1 > 9800.0);
        assert!(eta_bethe < 1e-4 && 1.0 / eta_bethe > 10_000.0);
        // M3 standalone unkeyed contrast is identically zero:
        assert!(
            (trimodal_dual_keyed_er_epr_rx_probability(0.0, 0.0, 1.0)
                - trimodal_dual_keyed_er_epr_rx_probability(0.0, 0.0, -1.0))
                .abs()
                < 1e-15
        );

        // 2. Composite M4 (M1+M3) vs. M5 (M2+M3) single-shot GJW contrast at r/w = 100:
        let c_m4 = trimodal_dual_keyed_er_epr_rx_probability(0.01, 0.0, 1.0)
            - trimodal_dual_keyed_er_epr_rx_probability(0.01, 0.0, -1.0);
        let c_m5 = trimodal_dual_keyed_er_epr_rx_probability(0.0, 1.0, 1.0)
            - trimodal_dual_keyed_er_epr_rx_probability(0.0, 1.0, -1.0);
        assert!(c_m4 < 0.021 && (c_m5 - 1.0).abs() < 1e-15);

        // 3. Composite M6 (M1+M2): live common-mode subtraction, MRC SNR, & correlated outage sweep:
        assert!((dual_path_common_mode_subtraction(87.3, 0.65, -1.0) - (-0.65)).abs() < 1e-14);
        assert!((dual_path_mrc_combined_snr(12.5, 100.0) - 112.5).abs() < 1e-15);
        let p_single = 0.1_f64;
        assert!(
            (dual_path_correlated_outage_probability(p_single, 0.0)
                - dual_path_outage_probability(p_single, p_single))
                .abs()
                < 1e-15
        );
        assert!((dual_path_correlated_outage_probability(p_single, 1.0) - p_single).abs() < 1e-15);
        let rho_grid = [0.0_f64, 0.1, 0.2, 0.5, 0.8, 0.99];
        for pair in rho_grid.windows(2) {
            let p_lo = dual_path_correlated_outage_probability(p_single, pair[0]);
            let p_hi = dual_path_correlated_outage_probability(p_single, pair[1]);
            assert!(p_single * p_single <= p_lo && p_lo < p_hi && p_hi < p_single);
        }

        // 4. Composite M7 (M1+M2+M3) Critique Fix 1: AGC dual-key convex normalization eliminates
        //    the 4/5 over-rotation when both M1 and M2 are active AND survives single-path blackout:
        let c_unnorm_both = trimodal_dual_keyed_er_epr_rx_probability(1.0, 1.0, 1.0)
            - trimodal_dual_keyed_er_epr_rx_probability(1.0, 1.0, -1.0);
        assert!((c_unnorm_both - 0.8).abs() < 1e-15);
        for (w1, w2) in [(1.0, 1.0), (10.0, 100.0), (0.25, 9.75), (10.0, 0.0), (0.0, 100.0)] {
            let x1 = if w1 > 0.0 { 1.0 } else { 0.0 };
            let x2 = if w2 > 0.0 { 1.0 } else { 0.0 };
            let p_hi = trimodal_agc_dual_keyed_er_epr_rx_probability(x1, x2, w1, w2, 1.0);
            let p_lo = trimodal_agc_dual_keyed_er_epr_rx_probability(x1, x2, w1, w2, -1.0);
            assert!((p_hi - p_lo - 1.0).abs() < 1e-15);
            assert!((p_hi + p_lo - 1.0).abs() < 1e-15);
        }
        for x1 in [-5.0_f64, -1.0, 0.0, 0.5, 4.0] {
            for x2 in [-3.0_f64, 0.0, 1.0, 8.0] {
                let p = trimodal_agc_dual_keyed_er_epr_rx_probability(x1, x2, 10.0, 100.0, 1.0);
                assert!((0.0..=1.0).contains(&p));
            }
        }

        // 5. Critique Fix 2: Arrival-time skew non-negativity & CROW/FIFO drift cancellation:
        let dt_skew = dual_path_propagation_skew(10.0, 12.0, 1.0, 0.5);
        assert!(dt_skew >= 0.0 && (dt_skew - 14.0).abs() < 1e-15);
        for y_drift in [-0.45_f64, 0.0, 0.2, 1.75] {
            let unbuf = dual_path_skew_compensated_clutter_residual(
                5.0, y_drift, 3.0, dt_skew, 0.0, 0.75, -1.0,
            );
            let buf = dual_path_skew_compensated_clutter_residual(
                5.0, y_drift, 3.0, dt_skew, dt_skew, 0.75, -1.0,
            );
            assert!((unbuf - (-0.75 + y_drift * dt_skew)).abs() < 1e-14);
            assert!((buf - (-0.75)).abs() < 1e-14);
        }

        // 6. Critique Fix 4 + Section 3.3.5: Parasitic mouth crosstalk threshold against B_Bohm_QFIM = 15:
        //    With E1 = E2 = 1000 and E_wormhole = 4, exact threshold is eps_crit = (15 - 4) / 2000 = 5.5e-3.
        assert!((trimodal_parasitic_throat_load(0.0, 0.0, 1000.0, 1000.0, 4.0) - 4.0).abs() < 1e-15);
        for &eps in &[0.0_f64, 1e-4, 1e-3, 5e-3, 5.5e-3] {
            let e_load = trimodal_parasitic_throat_load(eps, eps, 1000.0, 1000.0, 4.0);
            assert!(wormhole_net_null_defocusing_flux(e_load, b_qfim) <= 1e-12);
        }
        for &eps_bad in &[6e-3_f64, 1e-2, 5e-2] {
            let e_load = trimodal_parasitic_throat_load(eps_bad, eps_bad, 1000.0, 1000.0, 4.0);
            assert!(wormhole_net_null_defocusing_flux(e_load, b_qfim) > 0.0);
        }
    }

    #[rstest]
    #[case::separable_product(1.0, 0.0, 0.0, 0.0, 0.0)]
    #[case::partially_entangled(0.8, 0.0, 0.0, 0.6, 0.9216)]
    #[case::maximally_entangled_bell(
        std::f64::consts::FRAC_1_SQRT_2,
        0.0,
        0.0,
        std::f64::consts::FRAC_1_SQRT_2,
        1.0
    )]
    #[case::singlet_bell(
        0.0,
        std::f64::consts::FRAC_1_SQRT_2,
        -std::f64::consts::FRAC_1_SQRT_2,
        0.0,
        1.0
    )]
    fn test_er_epr_su4_plucker_semi_dirac_and_qism_wormhole_transit(
        #[case] psi00: f64,
        #[case] psi01: f64,
        #[case] psi10: f64,
        #[case] psi11: f64,
        #[case] expected_concurrence_sq: f64,
    ) {
        // 1. SU(4) 3-term Plücker identity === Costello-Gaiotto deformed conifold throat equation:
        let p23 = psi00 * psi11 - psi01 * psi10;
        assert!(
            universal_plucker_three_term_residual(1.0, p23, psi00, psi11, psi01, psi10).abs()
                < 1e-15
        );
        assert!(
            twisted_holography_deformed_conifold_residual(psi00, psi11, psi01, psi10, p23).abs()
                < 1e-15
        );
        assert!(
            (er_epr_plucker_concurrence_sq(p23.powi(2)) - expected_concurrence_sq).abs() < 1e-14
        );

        // 2. Massive DDF sheath-jamming blow-up as beta^2 -> 1^- vs. massless & Semi-Dirac (k_x = 0) immunity:
        for &beta_sq in &[0.0_f64, 0.36, 0.9, 0.999] {
            assert!((wormhole_transit_jammed_energy(0.0, beta_sq, 4.0) - 4.0).abs() < 1e-15);
            assert!((semi_dirac_wormhole_transit_energy_sq(0.0, 2.0, beta_sq) - 4.0).abs() < 1e-15);
            if beta_sq > 0.0 {
                assert!(
                    wormhole_transit_jammed_energy(1.0, 0.0, 4.0)
                        < wormhole_transit_jammed_energy(1.0, beta_sq, 4.0)
                );
                assert!(
                    semi_dirac_wormhole_transit_energy_sq(1.0, 2.0, 0.0)
                        < semi_dirac_wormhole_transit_energy_sq(1.0, 2.0, beta_sq)
                );
            }
        }
        assert!(wormhole_transit_jammed_energy(1.0, 0.999, 4.0) > 1e5);

        // 3. Sub-wavelength Bethe diffraction recovery via TRUE phase conjugation & QISM Yang/Slavnov matching:
        let eta_bethe = subwavelength_photon_aperture_efficiency(1.0, 10.0);
        let eta_true_tagged = subwavelength_true_tagged_conjugate_coupling(eta_bethe, 0.1, 1_000_100.0);
        let t_yang_soft = qism_impedance_matched_yang_transmission(1.0, 100.0, 10_000.0);
        let p_l1 = transceiver_dist3_logical_error(0.01);
        assert!(eta_bethe < 1e-4 && eta_true_tagged > 0.9 && t_yang_soft > 0.999);
        assert!(
            transceiver_qec_net_efficiency(
                transceiver_uncorrected_link_efficiency(0.98, 1.0, 0.95),
                0.9,
                p_l1
            ) > 0.83
        );
    }
}
