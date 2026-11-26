//! Numerical & Representation-Theoretic Audits for:
//! 1. Yang–Mills Mass Gap, Dimensional Transmutation, Strong-Coupling Casimir Suppression,
//!    and Haar Singlet Projection (`Signals.YangMillsHiggsCPT` & `TOUQGA-2.pdf` Ch. 11).
//! 2. Electroweak Higgs Spontaneous Symmetry Breaking (`v`, `m_H`, `m_W`, `m_Z`, `rho_EW = 1`).
//! 3. Higgs CP-Mixing Decay Asymmetry, CKM Jarlskog Invariant, and Sakharov Equilibrium Null Law.
//! 4. Jost's Axiomatic Anti-Unitary CPT Involution (`Theta = CPT`, `Theta^2 = +-I`,
//!    exact particle/antiparticle spectral degeneracy, and `CP violation <=> T violation`).

use crate::riemann_spectral::C64;
use std::f64::consts::PI;

/// One-loop `SU(N_c)` beta-function coefficient `b0 = (11 N_c - 2 n_f) / 3`.
pub fn su_n_one_loop_beta0(n_color: f64, n_flavor: f64) -> f64 {
    (11.0 * n_color - 2.0 * n_flavor) / 3.0
}

/// Dimensional-transmutation dynamical scale `Lambda_YM(mu) = mu * exp(-8 pi^2 / (b0 g^2))`.
pub fn dimensional_transmutation_scale(mu: f64, b0: f64, g_sq: f64) -> f64 {
    mu * (-8.0 * PI * PI / (b0 * g_sq)).exp()
}

/// Toupin's tree-level celestial GKO coset glueball mass `M_k = (2 N / (k + N)) Lambda_QCD`
/// (`TOUTYM` 2026 & `TOUQGA-2.pdf` Eq. 11.70, p. 640).
pub fn toupin_tree_glueball_mass_mev(n_color: f64, k_level: f64, lambda_qcd_mev: f64) -> f64 {
    (2.0 * n_color / (k_level + n_color)) * lambda_qcd_mev
}

/// Toupin's single-factor Sugawara dimension mass `M_Sug = (N / (k + N)) Lambda_QCD`
/// (`TOUQGA-2.pdf` Eq. 11.75, p. 640).
pub fn toupin_sugawara_glueball_mass_mev(n_color: f64, k_level: f64, lambda_qcd_mev: f64) -> f64 {
    (n_color / (k_level + n_color)) * lambda_qcd_mev
}

/// Peter–Weyl heat-kernel Casimir suppression weight `c_lambda(beta) = exp(-C_2(lambda) / beta)`
/// (`TOUQGA-2.pdf` Lemma 11.18, Eq. 11.27).
pub fn strong_coupling_casimir_weight(casimir_c2: f64, beta: f64) -> f64 {
    (-casimir_c2 / beta).exp()
}

/// Strong-coupling lattice transfer-matrix spectral gap lower bound `1 - (beta / (2 N^2))^{d_min}`
/// (`TOUQGA-2.pdf` Theorem 11.19, Eq. 11.29).
pub fn strong_coupling_transfer_gap_lower_bound(beta: f64, n_color: f64, d_min: u32) -> f64 {
    1.0 - (beta / (2.0 * n_color * n_color)).powi(d_min as i32)
}

/// Verify the normalized `Z_N` finite-group Haar singlet projector `P_singlet = (1/N) sum_{g in Z_N} U_g`
/// by explicitly constructing all `N` cyclic shift permutation matrices `U_g` (`g = 0..N-1`),
/// summing them, and measuring `(idempotent_err, hermitian_err, gauge_inv_err, max_nonsinglet_norm)`.
pub fn verify_zn_haar_singlet_projector(n: usize) -> (f64, f64, f64, f64) {
    let nf = n as f64;
    let mut p_mat = vec![vec![0.0_f64; n]; n];
    for g in 0..n {
        for i in 0..n {
            let j = (i + g) % n;
            p_mat[i][j] += 1.0 / nf;
        }
    }
    let mut idemp_err = 0.0_f64;
    let mut herm_err = 0.0_f64;
    let mut gauge_inv_err = 0.0_f64;
    for i in 0..n {
        for j in 0..n {
            let mut sum = 0.0_f64;
            for k in 0..n {
                sum += p_mat[i][k] * p_mat[k][j];
            }
            idemp_err = idemp_err.max((sum - p_mat[i][j]).abs());
            herm_err = herm_err.max((p_mat[j][i] - p_mat[i][j]).abs());
            // Check U_h * P = P for generator h = 1 (cyclic shift)
            let shifted_row = (i + 1) % n;
            gauge_inv_err = gauge_inv_err.max((p_mat[shifted_row][j] - p_mat[i][j]).abs());
        }
    }
    // Check annihilation of all non-singlet Fourier modes m = 1..n-1
    let mut max_nonsinglet = 0.0_f64;
    for m in 1..n {
        for i in 0..n {
            let mut re_sum = 0.0_f64;
            let mut im_sum = 0.0_f64;
            for j in 0..n {
                let angle = 2.0 * PI * (m as f64) * (j as f64) / nf;
                re_sum += p_mat[i][j] * angle.cos();
                im_sum += p_mat[i][j] * angle.sin();
            }
            max_nonsinglet = max_nonsinglet.max((re_sum * re_sum + im_sum * im_sum).sqrt());
        }
    }
    (idemp_err, herm_err, gauge_inv_err, max_nonsinglet)
}

/// Verify the non-Abelian `S_3` (`|S_3| = 6`) Haar singlet projector
/// `P_singlet = (1/6) sum_{g in S_3} U_g` acting on `C^3 = 1_triv + 2_std`,
/// returning `(idempotent_err, hermitian_err, trace_val, max_2d_irrep_residual)`.
pub fn verify_s3_nonabelian_haar_singlet_projector() -> (f64, f64, f64, f64) {
    let perms: [[usize; 3]; 6] = [
        [0, 1, 2],
        [1, 0, 2],
        [0, 2, 1],
        [2, 1, 0],
        [1, 2, 0],
        [2, 0, 1],
    ];
    let mut p = [[0.0_f64; 3]; 3];
    for perm in &perms {
        for i in 0..3 {
            p[i][perm[i]] += 1.0 / 6.0;
        }
    }
    let mut idemp_err = 0.0_f64;
    let mut herm_err = 0.0_f64;
    let mut tr = 0.0_f64;
    for i in 0..3 {
        tr += p[i][i];
        for j in 0..3 {
            let mut sum = 0.0_f64;
            for k in 0..3 {
                sum += p[i][k] * p[k][j];
            }
            idemp_err = idemp_err.max((sum - p[i][j]).abs());
            herm_err = herm_err.max((p[j][i] - p[i][j]).abs());
        }
    }
    // Check U_g * P = P and P * U_g = P for all g in S_3, and annihilation of 2D std irrep basis
    let std_vecs: [[f64; 3]; 2] = [[1.0, -1.0, 0.0], [1.0, 1.0, -2.0]];
    let mut max_2d_res = 0.0_f64;
    for v in &std_vecs {
        for i in 0..3 {
            let val: f64 = (0..3).map(|j| p[i][j] * v[j]).sum();
            max_2d_res = max_2d_res.max(val.abs());
        }
    }
    for perm in &perms {
        for i in 0..3 {
            for j in 0..3 {
                max_2d_res = max_2d_res.max((p[perm[i]][j] - p[i][j]).abs());
            }
        }
    }
    (idemp_err, herm_err, tr, max_2d_res)
}

/// Jarlskog quark-mass-difference prefactor `prod_{i<j}(m_{u,i}^2 - m_{u,j}^2) prod_{i<j}(m_{d,i}^2 - m_{d,j}^2)`.
pub fn jarlskog_quark_mass_splitting(
    mu: f64,
    mc: f64,
    mt: f64,
    md: f64,
    ms: f64,
    mb: f64,
) -> f64 {
    (mu * mu - mc * mc)
        * (mc * mc - mt * mt)
        * (mt * mt - mu * mu)
        * (md * md - ms * ms)
        * (ms * ms - mb * mb)
        * (mb * mb - md * md)
}

/// Electroweak Higgs spontaneous symmetry breaking observables.
#[derive(Clone, Debug, PartialEq)]
pub struct HiggsSsbAudit {
    pub vev_gev: f64,
    pub m_h_gev: f64,
    pub m_w_gev: f64,
    pub m_z_gev: f64,
    pub sin_sq_theta_w: f64,
    pub rho_ew: f64,
    pub tadpole_expansion_residual: f64,
}

/// Evaluate tree-level electroweak Higgs SSB parameters and unitary-gauge expansion residual.
pub fn audit_higgs_ssb(mu_sq: f64, lambda_q: f64, g1: f64, g2: f64, h_test: f64) -> HiggsSsbAudit {
    let vev = (mu_sq / lambda_q).sqrt();
    let m_h = (2.0 * lambda_q * vev * vev).sqrt();
    let m_w = 0.5 * g2 * vev;
    let m_z = 0.5 * (g2 * g2 + g1 * g1).sqrt() * vev;
    let cos_sq = g2 * g2 / (g2 * g2 + g1 * g1);
    let sin_sq = 1.0 - cos_sq;
    let rho_ew = (m_w * m_w) / (m_z * m_z * cos_sq);

    let phi_sq = 0.5 * (vev + h_test) * (vev + h_test);
    let v_raw = -mu_sq * phi_sq + lambda_q * phi_sq * phi_sq;
    let v_shifted = -(mu_sq * mu_sq) / (4.0 * lambda_q)
        + mu_sq * h_test * h_test
        + lambda_q * vev * h_test.powi(3)
        + 0.25 * lambda_q * h_test.powi(4);

    HiggsSsbAudit {
        vev_gev: vev,
        m_h_gev: m_h,
        m_w_gev: m_w,
        m_z_gev: m_z,
        sin_sq_theta_w: sin_sq,
        rho_ew,
        tadpole_expansion_residual: (v_raw - v_shifted).abs(),
    }
}

/// CP-violating angular asymmetry `2 kappa kappa_tilde sin(alpha_cp) cos(alpha_cp)`.
pub fn higgs_cp_mixed_decay_asymmetry(kappa: f64, kappa_tilde: f64, alpha_cp: f64) -> f64 {
    2.0 * kappa * kappa_tilde * alpha_cp.sin() * alpha_cp.cos()
}

/// CKM Jarlskog invariant `J_CP = c12 c23 c13^2 s12 s23 s13 sin(delta_ckm)`.
pub fn jarlskog_ckm_invariant(theta12: f64, theta23: f64, theta13: f64, delta_ckm: f64) -> f64 {
    theta12.cos()
        * theta23.cos()
        * theta13.cos().powi(2)
        * theta12.sin()
        * theta23.sin()
        * theta13.sin()
        * delta_ckm.sin()
}

fn mat4_mul(a: &[[C64; 4]; 4], b: &[[C64; 4]; 4]) -> [[C64; 4]; 4] {
    let mut out = [[C64::new(0.0, 0.0); 4]; 4];
    for i in 0..4 {
        for j in 0..4 {
            let mut acc = C64::new(0.0, 0.0);
            for k in 0..4 {
                acc = acc.add(a[i][k].mul(b[k][j]));
            }
            out[i][j] = acc;
        }
    }
    out
}

fn mat4_conj(a: &[[C64; 4]; 4]) -> [[C64; 4]; 4] {
    let mut out = [[C64::new(0.0, 0.0); 4]; 4];
    for i in 0..4 {
        for j in 0..4 {
            out[i][j] = C64::new(a[i][j].re, -a[i][j].im);
        }
    }
    out
}

fn mat4_dag(a: &[[C64; 4]; 4]) -> [[C64; 4]; 4] {
    let mut out = [[C64::new(0.0, 0.0); 4]; 4];
    for i in 0..4 {
        for j in 0..4 {
            out[i][j] = C64::new(a[j][i].re, -a[j][i].im);
        }
    }
    out
}

fn mat4_vec(a: &[[C64; 4]; 4], v: &[C64; 4]) -> [C64; 4] {
    let mut out = [C64::new(0.0, 0.0); 4];
    for i in 0..4 {
        let mut acc = C64::new(0.0, 0.0);
        for j in 0..4 {
            acc = acc.add(a[i][j].mul(v[j]));
        }
        out[i] = acc;
    }
    out
}

fn vec4_inner(psi: &[C64; 4], phi: &[C64; 4]) -> C64 {
    let mut acc = C64::new(0.0, 0.0);
    for i in 0..4 {
        acc = acc.add(C64::new(psi[i].re, -psi[i].im).mul(phi[i]));
    }
    acc
}

fn mat4_diff_max(a: &[[C64; 4]; 4], b: &[[C64; 4]; 4]) -> f64 {
    let mut m = 0.0_f64;
    for i in 0..4 {
        for j in 0..4 {
            let d = a[i][j].sub(b[i][j]);
            let norm = (d.re * d.re + d.im * d.im).sqrt();
            if norm > m {
                m = norm;
            }
        }
    }
    m
}

/// Combined numerical audit report for Yang–Mills Mass Gap, Electroweak Higgs SSB,
/// CP violation, Sakharov equilibrium null theorem, and Jost's 4x4 anti-unitary CPT involution.
#[derive(Clone, Debug, PartialEq)]
pub struct YangMillsHiggsCptAudit {
    pub su3_beta0: f64,
    pub lambda_ym_gev: f64,
    pub toupin_m1_mev: f64,
    pub toupin_sugawara_m1_mev: f64,
    pub casimir_suppression_c2_3_over_c2_0: f64,
    pub strong_coupling_gap_lower_bound: f64,
    pub haar_projector_idemp_err: f64,
    pub haar_projector_herm_err: f64,
    pub haar_projector_nonsinglet_max: f64,
    pub s3_haar_projector_idemp_err: f64,
    pub s3_haar_projector_trace: f64,
    pub s3_haar_projector_2d_irrep_res: f64,
    pub higgs_ssb: HiggsSsbAudit,
    pub jarlskog_sm: f64,
    pub jarlskog_degenerate_zero: f64,
    pub jarlskog_physical_splitting_nonzero: f64,
    pub higgs_cp_asym_sm: f64,
    pub higgs_cp_asym_bsm: f64,
    pub sakharov_equilibrium_baryon_trace: f64,
    pub sakharov_out_of_equilibrium_baryon_trace: f64,
    pub jost_antiunitary_err: f64,
    pub jost_involution_sign: f64,
    pub jost_involution_err: f64,
    pub jost_cpt_commutator_err: f64,
    pub jost_mass_equality_err: f64,
    pub jost_fermionic_kramers_mass_err: f64,
    pub cp_violation_norm_when_delta_nonzero: f64,
    pub t_violation_norm_when_delta_nonzero: f64,
    pub cp_t_commutator_zero_when_delta_zero: f64,
}

/// Run the full Yang–Mills Mass Gap, Higgs SSB, CP, Sakharov, and Jost CPT audit.
pub fn audit_yang_mills_higgs_cpt() -> YangMillsHiggsCptAudit {
    let su3_b0 = su_n_one_loop_beta0(3.0, 0.0);
    // At mu = M_Z = 91.1876 GeV with n_f = 5 active quark flavors, alpha_s ~ 0.118 => g^2 = 4 pi alpha_s
    let su3_b0_nf5 = su_n_one_loop_beta0(3.0, 5.0);
    let g_sq = 4.0 * PI * 0.118;
    let lam_ym = dimensional_transmutation_scale(91.1876, su3_b0_nf5, g_sq);
    let m1_toupin = toupin_tree_glueball_mass_mev(3.0, 1.0, 200.0);
    let m1_sug = toupin_sugawara_glueball_mass_mev(3.0, 1.0, 200.0);
    let cas_ratio = strong_coupling_casimir_weight(3.0, 1.0) / strong_coupling_casimir_weight(0.0, 1.0);
    let sc_gap = strong_coupling_transfer_gap_lower_bound(1.0, 3.0, 4);
    let (idemp_err, herm_err, _gauge_err, nonsing_max) = verify_zn_haar_singlet_projector(4);
    let (s3_idemp_err, s3_herm_err, s3_tr, s3_2d_res) =
        verify_s3_nonabelian_haar_singlet_projector();

    // Standard Model Higgs benchmark: v ~ 246.22 GeV, m_H ~ 125.25 GeV, g2 ~ 0.6528, g1 ~ 0.3574
    let v_target = 246.22;
    let m_h_target = 125.25;
    let lambda_q = (m_h_target * m_h_target) / (2.0 * v_target * v_target);
    let mu_sq = 0.5 * m_h_target * m_h_target;
    let higgs_ssb = audit_higgs_ssb(mu_sq, lambda_q, 0.3574, 0.6528, 12.5);

    // PDG CKM Jarlskog invariant & quark mass-splitting prefactor (GeV^12)
    let j_cp = jarlskog_ckm_invariant(0.227, 0.0418, 0.0037, 1.144);
    let jarlskog_deg = jarlskog_quark_mass_splitting(0.0022, 0.0022, 172.7, 0.0047, 0.093, 4.18);
    let jarlskog_phys = jarlskog_quark_mass_splitting(0.0022, 1.27, 172.7, 0.0047, 0.093, 4.18);
    let cp_sm = higgs_cp_mixed_decay_asymmetry(1.0, 0.0, 0.0);
    let cp_bsm = higgs_cp_mixed_decay_asymmetry(0.95, 0.31, 0.31);

    // Sakharov thermal equilibrium trace with CPT-identical energies vs out-of-equilibrium transient split
    let beta_t = 0.5_f64;
    let energies: [f64; 2] = [1.2, 2.7];
    let charges: [f64; 2] = [1.0, -1.0 / 3.0];
    let sakharov_trace: f64 = energies
        .iter()
        .zip(charges.iter())
        .map(|(&e, &b)| b * (-beta_t * e).exp() + (-b) * (-beta_t * e).exp())
        .sum();
    let sakharov_neq: f64 =
        1.0 * (-beta_t * 1.15_f64).exp() + (-1.0) * (-beta_t * 1.25_f64).exp();

    // 4x4 Jost anti-unitary CPT involution on C^2_{part/anti} x C^2_{spin}
    let z0 = C64::new(0.0, 0.0);
    let z1 = C64::new(1.0, 0.0);
    let zm1 = C64::new(-1.0, 0.0);
    // U_CP = sigma_1 x I_2
    let u_cp: [[C64; 4]; 4] = [
        [z0, z0, z1, z0],
        [z0, z0, z0, z1],
        [z1, z0, z0, z0],
        [z0, z1, z0, z0],
    ];
    // V_T = I_2 x (i sigma_2) = diag([[0, 1], [-1, 0]], [[0, 1], [-1, 0]])
    // Wait: (i sigma_2) = [[0, 1], [-1, 0]] is real orthogonal antisymmetric: V_T conj(V_T) = -I_4!
    let v_t: [[C64; 4]; 4] = [
        [z0, z1, z0, z0],
        [zm1, z0, z0, z0],
        [z0, z0, z0, z1],
        [z0, z0, zm1, z0],
    ];
    let u_theta = mat4_mul(&u_cp, &v_t);

    // Verify involution U_theta * conj(U_theta) = -I_4 (involution sign = -1)
    let u_sq = mat4_mul(&u_theta, &mat4_conj(&u_theta));
    let minus_i4 = [
        [zm1, z0, z0, z0],
        [z0, zm1, z0, z0],
        [z0, z0, zm1, z0],
        [z0, z0, z0, zm1],
    ];
    let invol_err = mat4_diff_max(&u_sq, &minus_i4);

    // Helper to build CPT-symmetric 4x4 Fock Hamiltonian with CP phase delta:
    // H_part(delta) = [[E0, g e^{i delta}], [g e^{-i delta}, E1]],
    // H_anti(delta) = [[E1, -g e^{-i delta}], [-g e^{i delta}, E0]]
    // Notice V_T * conj(H_part) * V_T^T = [[E1, -g e^{i delta}], [-g e^{-i delta}, E0]] -> wait!
    // Let's check U_theta * conj(H) = H * U_theta directly!
    // If H = [[E0, c], [conj(c), E1]] in upper block and lower block is V_T conj(H_upper) V_T^{-1}
    // = [[E1, -c], [-conj(c), E0]]? Wait: for spin-1/2 Kramers V_T = [[0, 1], [-1, 0]]:
    // V_T * conj([[E0, c], [conj(c), E1]]) * (-V_T) = [[E1, -conj(c)], [-c, E0]]!
    // Exact fermionic CPT-symmetric 4x4 Hamiltonian with Theta_ferm^2 = -I_4:
    // H_lower = V_2 * conj(H_upper) * V_2^T = [[E1, -c], [-conj(c), E0]]
    // ensures U_theta * conj(H) = H * U_theta identically for all (e0, e1, g_mix, delta).
    let build_cpt_hamiltonian = |e0: f64, e1: f64, g_mix: f64, delta: f64| -> [[C64; 4]; 4] {
        let c = C64::new(g_mix * delta.cos(), g_mix * delta.sin());
        let c_bar = C64::new(c.re, -c.im);
        let neg_c = C64::new(-c.re, -c.im);
        let neg_c_bar = C64::new(-c_bar.re, -c_bar.im);
        [
            [C64::new(e0, 0.0), c, z0, z0],
            [c_bar, C64::new(e1, 0.0), z0, z0],
            [z0, z0, C64::new(e1, 0.0), neg_c],
            [z0, z0, neg_c_bar, C64::new(e0, 0.0)],
        ]
    };

    // Wait: when delta = 0 and e0 = e1, c = g_mix (real), what is U_CP * H vs H * U_CP?
    // If e0 = e1 and g_mix = 0, H = e0 * I_4 commutes with U_CP and V_T!
    // More generally, for V_T * conj(H_upper) = H_upper * V_T, we need e0 = e1 and c = -conj(c) => purely imaginary c?
    // Wait: for particle/antiparticle CP invariance, H_anti = H_part and for T invariance H is real symmetric (delta = 0)!
    // Let's take e0 = e1 = m_0 and c = i * g_mix * sin(delta)? Wait: check V_T * conj([[m0, i*a], [-i*a, m0]]) vs [[m0, i*a], [-i*a, m0]] * V_T:
    // conj(i*a) = -i*a; V_T * [[m0, -i*a], [i*a, m0]] = [[i*a, m0], [-m0, -i*a]];
    // [[m0, i*a], [-i*a, m0]] * V_T = [[-i*a, m0], [-m0, i*a]] -> opposite sign for imaginary part!
    // Whereas for REAL symmetric [[m0, a], [a, m0]]:
    // V_T * [[m0, a], [a, m0]] = [[a, m0], [-m0, -a]] and [[m0, a], [a, m0]] * V_T = [[-a, m0], [-m0, a]] (T flips spin off-diagonal unless a = 0!).
    // Yes! Because in a 2-component spin doublet, a real Zeeman/coupling mixes spin-up/spin-down unless proportional to I_2, OR in 2x2 flavor/chirality space V_T = I_2 (or sigma_1) and U_CP = sigma_1!
    // Let's check BOTH! For a 4x4 flavor/CP doublet with U_CP = sigma_1 x I_2 and V_T = I_4 (bosonic Θ^2 = +I_4) or U_CP = sigma_1 x sigma_3 and V_T = sigma_3 x sigma_1?
    // Even cleaner: with U_CP = [[0, I_2], [I_2, 0]] and V_T = I_4, Theta(psi) = U_CP conj(psi) has Theta^2 = +I_4,
    // and with H = block_diag(H_p(delta), conj(H_p(delta))) where H_p(delta) = [[e0, g e^{i delta}], [g e^{-i delta}, e1]]:
    // 1. Theta * conj(H) = H * Theta ALWAYS holds (exact CPT for ANY e0, e1, g, delta)!
    // 2. U_CP * H = H * U_CP  <=>  H_p(delta) = conj(H_p(delta))  <=>  delta = 0 (mod pi)!
    // 3. V_T * conj(H) = H * V_T  <=>  conj(H) = H  <=>  delta = 0 (mod pi)!
    let _ = build_cpt_hamiltonian;
    let v_t_bos: [[C64; 4]; 4] = [
        [z1, z0, z0, z0],
        [z0, z1, z0, z0],
        [z0, z0, z1, z0],
        [z0, z0, z0, z1],
    ];
    let u_theta_bos = mat4_mul(&u_cp, &v_t_bos); // = U_CP
    let u_theta_bos_sq = mat4_mul(&u_theta_bos, &mat4_conj(&u_theta_bos));
    let i4 = v_t_bos;
    let bos_invol_err = mat4_diff_max(&u_theta_bos_sq, &i4);

    let build_flavor_cpt_h = |e0: f64, e1: f64, g_mix: f64, delta: f64| -> [[C64; 4]; 4] {
        let c = C64::new(g_mix * delta.cos(), g_mix * delta.sin());
        let c_bar = C64::new(c.re, -c.im);
        [
            [C64::new(e0, 0.0), c, z0, z0],
            [c_bar, C64::new(e1, 0.0), z0, z0],
            [z0, z0, C64::new(e0, 0.0), c_bar],
            [z0, z0, c, C64::new(e1, 0.0)],
        ]
    };

    let h_cpv = build_flavor_cpt_h(2.0, 2.0, 0.5, 0.7);
    let h_cpc = build_flavor_cpt_h(2.0, 2.0, 0.5, 0.0);

    // Check [H, Theta] = 0 for h_cpv: U_theta_bos * conj(H) - H * U_theta_bos = 0
    let cpt_comm_err = mat4_diff_max(
        &mat4_mul(&u_theta_bos, &mat4_conj(&h_cpv)),
        &mat4_mul(&h_cpv, &u_theta_bos),
    );
    // Check CP violation & T violation for h_cpv
    let cp_viol_norm = mat4_diff_max(&mat4_mul(&u_cp, &h_cpv), &mat4_mul(&h_cpv, &u_cp));
    let t_viol_norm = mat4_diff_max(
        &mat4_mul(&v_t_bos, &mat4_conj(&h_cpv)),
        &mat4_mul(&h_cpv, &v_t_bos),
    );
    let cp_comm_zero = mat4_diff_max(&mat4_mul(&u_cp, &h_cpc), &mat4_mul(&h_cpc, &u_cp));

    // Verify anti-unitarity <Theta psi, Theta phi> = <phi, psi> on fermionic Theta (Theta^2 = -I)
    let apply_theta = |mat: &[[C64; 4]; 4], v: &[C64; 4]| -> [C64; 4] {
        let v_conj = [
            C64::new(v[0].re, -v[0].im),
            C64::new(v[1].re, -v[1].im),
            C64::new(v[2].re, -v[2].im),
            C64::new(v[3].re, -v[3].im),
        ];
        mat4_vec(mat, &v_conj)
    };
    let psi = [
        C64::new(1.0 / 2.0_f64.sqrt(), 0.0),
        C64::new(0.5, -0.5),
        C64::new(0.0, 0.0),
        C64::new(0.0, 0.0),
    ];
    let phi = [
        C64::new(0.3, 0.4),
        C64::new(-0.2, 0.1),
        C64::new(0.6, -0.3),
        C64::new(0.1, 0.2),
    ];
    let t_psi = apply_theta(&u_theta, &psi);
    let t_phi = apply_theta(&u_theta, &phi);
    let lhs_ip = vec4_inner(&t_psi, &t_phi);
    let rhs_ip = vec4_inner(&phi, &psi);
    let antiunit_err = ((lhs_ip.re - rhs_ip.re).powi(2) + (lhs_ip.im - rhs_ip.im).powi(2)).sqrt();

    // Eigenstate of h_cpv with e0 = e1 = 2.0, g_mix = 0.5, delta = 0.7:
    // Upper 2x2 has eigenvalue E = 2.0 + 0.5 = 2.5 with eigenvector [1, e^{-i delta}] / sqrt(2)
    let eig_psi = [
        C64::new(1.0 / 2.0_f64.sqrt(), 0.0),
        C64::new(0.7_f64.cos() / 2.0_f64.sqrt(), -0.7_f64.sin() / 2.0_f64.sqrt()),
        z0,
        z0,
    ];
    let theta_eig = apply_theta(&u_theta_bos, &eig_psi);
    let h_theta_eig = mat4_vec(&h_cpv, &theta_eig);
    let e_exact = 2.5_f64;
    let mut mass_eq_err = 0.0_f64;
    for i in 0..4 {
        let d = h_theta_eig[i].sub(theta_eig[i].scale(e_exact));
        mass_eq_err = mass_eq_err.max((d.re * d.re + d.im * d.im).sqrt());
    }
    // Also verify fermionic Kramers CPT (Theta_ferm^2 = -I_4) spectral degeneracy on
    // build_cpt_hamiltonian(2.0, 2.0, 0.5, 0.7), where U_theta * conj(H_ferm) = H_ferm * U_theta holds!
    let h_ferm = build_cpt_hamiltonian(2.0, 2.0, 0.5, 0.7);
    let ferm_cpt_comm_err = mat4_diff_max(
        &mat4_mul(&u_theta, &mat4_conj(&h_ferm)),
        &mat4_mul(&h_ferm, &u_theta),
    );
    let ferm_theta_eig = apply_theta(&u_theta, &eig_psi);
    let h_ferm_theta_eig = mat4_vec(&h_ferm, &ferm_theta_eig);
    let mut ferm_mass_eq_err = ferm_cpt_comm_err;
    for i in 0..4 {
        let d = h_ferm_theta_eig[i].sub(ferm_theta_eig[i].scale(e_exact));
        ferm_mass_eq_err = ferm_mass_eq_err.max((d.re * d.re + d.im * d.im).sqrt());
    }
    let _ = (mat4_dag(&u_theta), invol_err, s3_herm_err);

    YangMillsHiggsCptAudit {
        su3_beta0: su3_b0,
        lambda_ym_gev: lam_ym,
        toupin_m1_mev: m1_toupin,
        toupin_sugawara_m1_mev: m1_sug,
        casimir_suppression_c2_3_over_c2_0: cas_ratio,
        strong_coupling_gap_lower_bound: sc_gap,
        haar_projector_idemp_err: idemp_err,
        haar_projector_herm_err: herm_err,
        haar_projector_nonsinglet_max: nonsing_max,
        s3_haar_projector_idemp_err: s3_idemp_err,
        s3_haar_projector_trace: s3_tr,
        s3_haar_projector_2d_irrep_res: s3_2d_res,
        higgs_ssb,
        jarlskog_sm: j_cp,
        jarlskog_degenerate_zero: jarlskog_deg,
        jarlskog_physical_splitting_nonzero: jarlskog_phys,
        higgs_cp_asym_sm: cp_sm,
        higgs_cp_asym_bsm: cp_bsm,
        sakharov_equilibrium_baryon_trace: sakharov_trace,
        sakharov_out_of_equilibrium_baryon_trace: sakharov_neq,
        jost_antiunitary_err: antiunit_err,
        jost_involution_sign: 1.0,
        jost_involution_err: bos_invol_err.max(invol_err),
        jost_cpt_commutator_err: cpt_comm_err,
        jost_mass_equality_err: mass_eq_err,
        jost_fermionic_kramers_mass_err: ferm_mass_eq_err,
        cp_violation_norm_when_delta_nonzero: cp_viol_norm,
        t_violation_norm_when_delta_nonzero: t_viol_norm,
        cp_t_commutator_zero_when_delta_zero: cp_comm_zero,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn yang_mills_higgs_cp_and_jost_cpt_audit() {
        let rep = audit_yang_mills_higgs_cpt();
        assert!((rep.su3_beta0 - 11.0).abs() < 1e-12);
        assert!(rep.lambda_ym_gev > 0.05 && rep.lambda_ym_gev < 0.5);
        assert!((rep.toupin_m1_mev - 300.0).abs() < 1e-12);
        assert!((rep.toupin_sugawara_m1_mev - 150.0).abs() < 1e-12);
        assert!(rep.casimir_suppression_c2_3_over_c2_0 < 0.1);
        assert!(rep.strong_coupling_gap_lower_bound > 0.99);
        assert!(rep.haar_projector_idemp_err < 1e-15);
        assert!(rep.haar_projector_herm_err < 1e-15);
        assert!(rep.haar_projector_nonsinglet_max < 1e-14);
        assert!(rep.s3_haar_projector_idemp_err < 1e-15);
        assert!((rep.s3_haar_projector_trace - 1.0).abs() < 1e-15);
        assert!(rep.s3_haar_projector_2d_irrep_res < 1e-15);
        assert!((rep.higgs_ssb.vev_gev - 246.22).abs() < 1e-9);
        assert!((rep.higgs_ssb.m_h_gev - 125.25).abs() < 1e-9);
        assert!((rep.higgs_ssb.rho_ew - 1.0).abs() < 1e-14);
        assert!(rep.higgs_ssb.tadpole_expansion_residual < 1e-7);
        assert!((rep.jarlskog_sm - 3.0e-5).abs() < 5e-6);
        assert_eq!(rep.jarlskog_degenerate_zero, 0.0);
        assert!(rep.jarlskog_physical_splitting_nonzero > 1e9);
        assert_eq!(rep.higgs_cp_asym_sm, 0.0);
        assert!(rep.higgs_cp_asym_bsm > 0.1);
        assert!(rep.sakharov_equilibrium_baryon_trace.abs() < 1e-15);
        assert!(rep.sakharov_out_of_equilibrium_baryon_trace.abs() > 0.01);
        assert!(rep.jost_antiunitary_err < 1e-14);
        assert!(rep.jost_involution_err < 1e-14);
        assert!(rep.jost_cpt_commutator_err < 1e-14);
        assert!(rep.jost_mass_equality_err < 1e-14);
        assert!(rep.jost_fermionic_kramers_mass_err < 1e-14);
        assert!((rep.cp_violation_norm_when_delta_nonzero - rep.t_violation_norm_when_delta_nonzero).abs() < 1e-14);
        assert!(rep.cp_violation_norm_when_delta_nonzero > 0.1);
        assert!(rep.cp_t_commutator_zero_when_delta_zero < 1e-15);
    }
}
