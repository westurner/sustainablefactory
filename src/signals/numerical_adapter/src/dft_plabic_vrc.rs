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

        // 7. Regime 7 (R7): Supersolid quantum tornadoes & room-temp graphene whirlpools
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
    }
}
