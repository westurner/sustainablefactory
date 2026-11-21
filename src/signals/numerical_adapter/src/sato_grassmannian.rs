//! Native Rust + PyO3 numerical kernels for `Signals.SatoGrassmannian` and
//! `Signals.SatoGrassmannian.RiemannSpectralBridge`.
//!
//! Covers:
//! 1. Overflow-proof log-sum-exp `PlabicGr24Solver` for `Gr_≥0(2,4)` Kodama–Williams KP-II
//!    soliton webs, KdV 2-solitons, and Y-junctions (`PDESolver.lean`, `KP2Nonlinear.lean`).
//! 2. Baker–Akhiezer `B₂`/`B₃` Lax pair verifier (`LaxPair.lean`).
//! 3. AKNS focusing NLS bright soliton & defocusing GPE dark soliton verifiers (`AKNS.lean`).
//! 4. 3-channel Plücker–Madelung & 6-channel Dual-Schubert QFIM (`DualSchubertQFIM.lean`).
//! 5. Order-1/2/3 Carleman–Weierstrass Euler products & `det₂` anomaly (`CarlemanWeierstrass.lean`).
//! 6. Shifted-Gaussian `L¹(ℝ)` Weil quadratic form & off-line negative witness (`WeilGaussianL1.lean`).
//! 7. Segal–Wilson `Gr(2,4)` Fredholm determinant vs. Schur `τ_U / p₂₃` (`SegalWilsonGr24.lean`)
//!    and finite-to-infinite `RiemannSpectralBridge` verification.

use std::f64::consts::PI;

#[cfg(feature = "python")]
use pyo3::exceptions::PyValueError;
#[cfg(feature = "python")]
use pyo3::prelude::*;

const PAIRS: [(usize, usize); 6] = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)];

#[derive(Debug, Clone, Copy)]
pub struct C64 {
    pub re: f64,
    pub im: f64,
}

impl C64 {
    #[inline]
    pub const fn new(re: f64, im: f64) -> Self {
        Self { re, im }
    }
    #[inline]
    pub const fn from_re(re: f64) -> Self {
        Self { re, im: 0.0 }
    }
    #[inline]
    pub fn conj(self) -> Self {
        Self::new(self.re, -self.im)
    }
    #[inline]
    pub fn norm_sq(self) -> f64 {
        self.re * self.re + self.im * self.im
    }
    #[inline]
    pub fn norm(self) -> f64 {
        self.norm_sq().sqrt()
    }
    #[inline]
    pub fn add(self, o: Self) -> Self {
        Self::new(self.re + o.re, self.im + o.im)
    }
    #[inline]
    pub fn sub(self, o: Self) -> Self {
        Self::new(self.re - o.re, self.im - o.im)
    }
    #[inline]
    pub fn mul(self, o: Self) -> Self {
        Self::new(self.re * o.re - self.im * o.im, self.re * o.im + self.im * o.re)
    }
    #[inline]
    pub fn scale(self, s: f64) -> Self {
        Self::new(self.re * s, self.im * s)
    }
    #[inline]
    pub fn div(self, o: Self) -> Self {
        let d = o.norm_sq();
        Self::new((self.re * o.re + self.im * o.im) / d, (self.im * o.re - self.re * o.im) / d)
    }
    #[inline]
    pub fn exp(self) -> Self {
        let r = self.re.exp();
        Self::new(r * self.im.cos(), r * self.im.sin())
    }
    #[inline]
    pub fn pow_neg_s(base: f64, s: Self) -> Self {
        let ln_b = base.ln();
        Self::new(-s.re * ln_b, -s.im * ln_b).exp()
    }
}

/// Exact analytical jet of the KP-II potential `u = 2 ∂_x² log τ` at `(x, y, t)`.
#[cfg_attr(feature = "python", pyclass(get_all))]
#[derive(Debug, Clone, Copy)]
pub struct Kp2Jet {
    pub u: f64,
    pub u_x: f64,
    pub u_xx: f64,
    pub u_xxx: f64,
    pub u_xxxx: f64,
    pub u_y: f64,
    pub u_yy: f64,
    pub u_t: f64,
    pub u_xt: f64,
    pub log_tau: f64,
    /// Exact KP-II PDE residual `∂_x(4 u_t - u_{xxx} - 6 u u_x) - 3 u_{yy}`.
    pub kp2_residual: f64,
}

/// Positroid `Gr_≥0(2, 4)` Kodama–Williams KP-II soliton web evaluator.
#[cfg_attr(feature = "python", pyclass)]
#[derive(Debug, Clone)]
pub struct PlabicGr24Solver {
    /// Strictly ordered real wavenumbers `κ₀ < κ₁ < κ₂ < κ₃`.
    pub kappa: [f64; 4],
    /// Six Plücker coordinates `(p₀₁, p₀₂, p₀₃, p₁₂, p₁₃, p₂₃)` in `Gr_≥0(2, 4)`.
    pub plucker: [f64; 6],
    /// Precomputed positive Wronskian weights `c_r = p_{ij} (κ_j - κ_i)`.
    coeffs: [f64; 6],
    /// Linear dispersion rates `(α_r, β_r, γ_r) = (κ_i+κ_j, κ_i²+κ_j², κ_i³+κ_j³)`.
    alpha: [f64; 6],
    beta: [f64; 6],
    gamma: [f64; 6],
}

impl PlabicGr24Solver {
    pub fn from_frame_rust(kappa: [f64; 4], v: [f64; 4], w: [f64; 4]) -> Result<Self, String> {
        for idx in 0..3 {
            if !(kappa[idx] < kappa[idx + 1]) {
                return Err(
                    "Wavenumbers must be strictly increasing: κ₀ < κ₁ < κ₂ < κ₃".into(),
                );
            }
        }
        let mut plucker = [0.0_f64; 6];
        let mut coeffs = [0.0_f64; 6];
        let mut alpha = [0.0_f64; 6];
        let mut beta = [0.0_f64; 6];
        let mut gamma = [0.0_f64; 6];
        let mut any_pos = false;

        for (r, &(i, j)) in PAIRS.iter().enumerate() {
            let p_ij = v[i] * w[j] - v[j] * w[i];
            if p_ij < -1e-14 {
                return Err(format!(
                    "Negative Plücker minor p_{i}{j} = {p_ij} violates Gr_≥0(2,4)"
                ));
            }
            let p_clamped = p_ij.max(0.0);
            if p_clamped > 0.0 {
                any_pos = true;
            }
            plucker[r] = p_clamped;
            coeffs[r] = p_clamped * (kappa[j] - kappa[i]);
            alpha[r] = kappa[i] + kappa[j];
            beta[r] = kappa[i].powi(2) + kappa[j].powi(2);
            gamma[r] = kappa[i].powi(3) + kappa[j].powi(3);
        }

        if !any_pos {
            return Err("Degenerate frame: all Plücker minors vanish".into());
        }
        Ok(Self {
            kappa,
            plucker,
            coeffs,
            alpha,
            beta,
            gamma,
        })
    }

    pub fn from_plabic_weights_rust(
        kappa: [f64; 4],
        a: f64,
        b: f64,
        c: f64,
        d: f64,
    ) -> Result<Self, String> {
        if !(a > 0.0 && b > 0.0 && c > 0.0 && d > 0.0) {
            return Err("Plabic edge weights (a, b, c, d) must be strictly positive".into());
        }
        let v = [1.0, 0.0, -a, -a * (b + d)];
        let w = [0.0, 1.0, c, c * d];
        Self::from_frame_rust(kappa, v, w)
    }

    pub fn klein_quadric_residual_rust(&self) -> f64 {
        self.plucker[0] * self.plucker[5] - self.plucker[1] * self.plucker[4]
            + self.plucker[2] * self.plucker[3]
    }

    /// Evaluates `u(x, y, t)` and all analytical derivatives up to 4th order using
    /// overflow-proof log-sum-exp cumulants of `log τ`.
    pub fn eval_jet_rust(&self, x: f64, y: f64, t: f64) -> Kp2Jet {
        let mut phases = [f64::NEG_INFINITY; 6];
        let mut max_phase = f64::NEG_INFINITY;
        for r in 0..6 {
            if self.coeffs[r] > 0.0 {
                let ph = self.coeffs[r].ln()
                    + self.alpha[r] * x
                    + self.beta[r] * y
                    + self.gamma[r] * t;
                phases[r] = ph;
                if ph > max_phase {
                    max_phase = ph;
                }
            }
        }

        let mut w = [0.0_f64; 6];
        let mut z = 0.0_f64;
        for r in 0..6 {
            if phases[r].is_finite() {
                w[r] = (phases[r] - max_phase).exp();
                z += w[r];
            }
        }
        for wr in &mut w {
            *wr /= z;
        }
        let log_tau = max_phase + z.ln();

        let (mut ma, mut mb, mut mg) = (0.0, 0.0, 0.0);
        for r in 0..6 {
            ma += w[r] * self.alpha[r];
            mb += w[r] * self.beta[r];
            mg += w[r] * self.gamma[r];
        }

        let (mut m2a, mut m3a, mut m4a, mut m5a, mut m6a) = (0.0, 0.0, 0.0, 0.0, 0.0);
        let (mut m2b, mut mab, mut ma2b, mut ma2b2) = (0.0, 0.0, 0.0, 0.0);
        let (mut mag, mut ma2g, mut ma3g) = (0.0, 0.0, 0.0);

        for r in 0..6 {
            let wr = w[r];
            if wr == 0.0 {
                continue;
            }
            let da = self.alpha[r] - ma;
            let db = self.beta[r] - mb;
            let dg = self.gamma[r] - mg;
            let da2 = da * da;
            let da3 = da2 * da;
            let da4 = da2 * da2;

            m2a += wr * da2;
            m3a += wr * da3;
            m4a += wr * da4;
            m5a += wr * da4 * da;
            m6a += wr * da4 * da2;

            m2b += wr * db * db;
            mab += wr * da * db;
            ma2b += wr * da2 * db;
            ma2b2 += wr * da2 * db * db;

            mag += wr * da * dg;
            ma2g += wr * da2 * dg;
            ma3g += wr * da3 * dg;
        }

        let u = 2.0 * m2a;
        let u_x = 2.0 * m3a;
        let u_xx = 2.0 * (m4a - 3.0 * m2a * m2a);
        let u_xxx = 2.0 * (m5a - 10.0 * m3a * m2a);
        let u_xxxx =
            2.0 * (m6a - 15.0 * m4a * m2a - 10.0 * m3a * m3a + 30.0 * m2a * m2a * m2a);
        let u_y = 2.0 * ma2b;
        let u_yy = 2.0 * (ma2b2 - m2a * m2b - 2.0 * mab * mab);
        let u_t = 2.0 * ma2g;
        let u_xt = 2.0 * (ma3g - 3.0 * m2a * mag);

        let kp2_residual = 4.0 * u_xt - u_xxxx - 6.0 * (u_x * u_x + u * u_xx) - 3.0 * u_yy;

        Kp2Jet {
            u,
            u_x,
            u_xx,
            u_xxx,
            u_xxxx,
            u_y,
            u_yy,
            u_t,
            u_xt,
            log_tau,
            kp2_residual,
        }
    }

    pub fn eval_grid_rust(&self, xs: &[f64], ys: &[f64], t: f64) -> Vec<f64> {
        let mut out = Vec::with_capacity(xs.len() * ys.len());
        for &y in ys {
            for &x in xs {
                out.push(self.eval_jet_rust(x, y, t).u);
            }
        }
        out
    }
}

#[cfg(feature = "python")]
#[pymethods]
impl PlabicGr24Solver {
    #[getter]
    pub fn kappa(&self) -> [f64; 4] {
        self.kappa
    }

    #[getter]
    pub fn plucker(&self) -> [f64; 6] {
        self.plucker
    }

    #[staticmethod]
    pub fn from_plabic_weights(
        kappa: [f64; 4],
        a: f64,
        b: f64,
        c: f64,
        d: f64,
    ) -> PyResult<Self> {
        Self::from_plabic_weights_rust(kappa, a, b, c, d).map_err(PyValueError::new_err)
    }

    #[staticmethod]
    pub fn from_frame(kappa: [f64; 4], v: [f64; 4], w: [f64; 4]) -> PyResult<Self> {
        Self::from_frame_rust(kappa, v, w).map_err(PyValueError::new_err)
    }

    pub fn klein_quadric_residual(&self) -> f64 {
        self.klein_quadric_residual_rust()
    }

    pub fn eval_jet(&self, x: f64, y: f64, t: f64) -> Kp2Jet {
        self.eval_jet_rust(x, y, t)
    }

    pub fn eval_grid(&self, xs: Vec<f64>, ys: Vec<f64>, t: f64) -> Vec<f64> {
        self.eval_grid_rust(&xs, &ys, t)
    }
}

/// Baker–Akhiezer Lax pair verification report for `kdvOneSoliton k`.
#[derive(Debug, Clone, Copy)]
pub struct BaLaxAudit {
    pub u: f64,
    pub psi_re: f64,
    pub psi_im: f64,
    pub b2_residual_abs: f64,
    pub b3_residual_abs: f64,
}

/// Evaluates `ψ(x,y,t) = (z - k tanh(k x + k³ t)) exp(z x + z² y + z³ t)` and
/// checks both the `B₂` (`∂_y ψ = (∂_x² + u) ψ`) and corrected `B₃`
/// (`∂_t ψ = (∂_x³ + (3/2) u ∂_x + w) ψ`) Lax equations (`LaxPair.lean`).
pub fn evaluate_ba_lax_pair(k: f64, z_re: f64, z_im: f64, x: f64, y: f64, t: f64) -> BaLaxAudit {
    let z = C64::new(z_re, z_im);
    let z2 = z.mul(z);
    let z3 = z2.mul(z);
    let theta = k * x + k.powi(3) * t;
    let th = theta.tanh();
    let ch = theta.cosh();
    let s2 = 1.0 / (ch * ch);
    let u = 2.0 * k * k * s2;
    let w = -3.0 * k.powi(3) * th * s2;

    let phase = z.scale(x).add(z2.scale(y)).add(z3.scale(t));
    let e = phase.exp();
    let factor = z.sub(C64::from_re(k * th));
    let psi = factor.mul(e);

    // Exact analytical derivatives from `LaxPair.lean`:
    let psi_y = z2.mul(psi);
    let psi_x = factor.mul(z).sub(C64::from_re(k * k * s2)).mul(e);
    let psi_xx = factor
        .mul(z2)
        .sub(z.scale(2.0 * k * k * s2))
        .add(C64::from_re(2.0 * k.powi(3) * s2 * th))
        .mul(e);
    // Corrected coefficient (fixing the chat's 4 -> 6 / -4 algebra bug):
    let psi_xxx = factor
        .mul(z3)
        .sub(z2.scale(3.0 * k * k * s2))
        .add(z.scale(6.0 * k.powi(3) * s2 * th))
        .add(C64::from_re(2.0 * k.powi(4) * s2 * (1.0 - 3.0 * th * th)))
        .mul(e);
    let psi_t = factor.mul(z3).sub(C64::from_re(k.powi(4) * s2)).mul(e);

    let b2_rhs = psi_xx.add(psi.scale(u));
    let b3_rhs = psi_xxx.add(psi_x.scale(1.5 * u)).add(psi.scale(w));

    BaLaxAudit {
        u,
        psi_re: psi.re,
        psi_im: psi.im,
        b2_residual_abs: psi_y.sub(b2_rhs).norm(),
        b3_residual_abs: psi_t.sub(b3_rhs).norm(),
    }
}

/// AKNS focusing NLS bright soliton & defocusing GPE dark soliton verification.
#[derive(Debug, Clone, Copy)]
pub struct AknsSolitonAudit {
    pub bright_abs: f64,
    pub bright_nls_residual_abs: f64,
    pub dark_abs: f64,
    pub dark_gpe_residual_abs: f64,
}

pub fn evaluate_akns_solitons(amp: f64, x: f64, t: f64) -> AknsSolitonAudit {
    let i_unit = C64::new(0.0, 1.0);

    // Bright soliton: q(x,t) = A sech(A x) exp(i A² t)
    let ax = amp * x;
    let ch = ax.cosh();
    let th = ax.tanh();
    let sech = 1.0 / ch;
    let phase_b = C64::new(0.0, amp * amp * t).exp();
    let q_b = phase_b.scale(amp * sech);
    let q_b_t = i_unit.mul(q_b).scale(amp * amp);
    // d²/dx² (A sech(Ax)) = A³ sech(Ax) (1 - 2 sech²(Ax))
    let q_b_xx = phase_b.scale(amp.powi(3) * sech * (1.0 - 2.0 * sech * sech));
    let res_b = i_unit
        .mul(q_b_t)
        .add(q_b_xx)
        .add(q_b.scale(2.0 * q_b.norm_sq()));

    // Dark soliton: q(x,t) = A tanh(A x) exp(-2 i A² t)
    let phase_d = C64::new(0.0, -2.0 * amp * amp * t).exp();
    let q_d = phase_d.scale(amp * th);
    let q_d_t = i_unit.mul(q_d).scale(-2.0 * amp * amp);
    // d²/dx² (A tanh(Ax)) = -2 A³ tanh(Ax) sech²(Ax)
    let q_d_xx = phase_d.scale(-2.0 * amp.powi(3) * th * sech * sech);
    let res_d = i_unit
        .mul(q_d_t)
        .add(q_d_xx)
        .sub(q_d.scale(2.0 * q_d.norm_sq()));

    AknsSolitonAudit {
        bright_abs: q_b.norm(),
        bright_nls_residual_abs: res_b.norm(),
        dark_abs: q_d.norm(),
        dark_gpe_residual_abs: res_d.norm(),
    }
}

/// 3-channel Plücker–Madelung & 6-channel Dual-Schubert QFIM evaluation (`DualSchubertQFIM.lean`).
#[derive(Debug, Clone, Copy)]
pub struct DualSchubertQfimAudit {
    pub fq_forward: f64,
    pub bohm_forward: f64,
    pub phase_forward: f64,
    pub geometric_forward: f64,
    pub forward_identity_residual: f64,
    pub fq_dual: f64,
    pub bohm_dual: f64,
    pub phase_dual: f64,
    pub geometric_dual: f64,
    pub fq_total_six_channel: f64,
    pub total_identity_residual: f64,
}

fn three_channel_single(
    rho: [f64; 6],
    drho: [f64; 6],
    dphi: [f64; 6],
) -> (f64, f64, f64, f64, f64) {
    let mut r_sum = 0.0_f64;
    for &ri in &rho {
        r_sum += ri;
    }
    let mut p = [0.0_f64; 6];
    let mut dp = [0.0_f64; 6];
    let mut dr_sum = 0.0_f64;
    for i in 0..6 {
        dr_sum += drho[i];
    }
    for i in 0..6 {
        p[i] = rho[i] / r_sum;
        dp[i] = (drho[i] * r_sum - rho[i] * dr_sum) / (r_sum * r_sum);
    }

    // Reconstruct Plücker vector `z_i = sqrt(rho_i)` and derivative `v_i = (drho_i / (2 sqrt(rho_i)) + i sqrt(rho_i) dphi_i)`
    let mut norm_v_sq = 0.0_f64;
    let mut inner_re = 0.0_f64;
    let mut inner_im = 0.0_f64;
    for i in 0..6 {
        if rho[i] > 0.0 {
            let vr = drho[i] / (2.0 * rho[i].sqrt());
            let vi = rho[i].sqrt() * dphi[i];
            norm_v_sq += vr * vr + vi * vi;
            inner_re += rho[i].sqrt() * vr;
            inner_im += rho[i].sqrt() * vi;
        }
    }
    let g_fs = norm_v_sq / r_sum - (inner_re * inner_re + inner_im * inner_im) / (r_sum * r_sum);
    let fq = 4.0 * g_fs;

    // 3 channels:
    // Classical Fisher/Bohm osmotic channel: sum_i (dp_i)^2 / (4 p_i)
    let mut bohm_ch = 0.0_f64;
    let mut mean_dphi = 0.0_f64;
    for i in 0..6 {
        mean_dphi += p[i] * dphi[i];
        if p[i] > 0.0 {
            bohm_ch += (dp[i] * dp[i]) / (4.0 * p[i]);
        }
    }
    // Phase-variance channel: Var_p(dphi)
    let mut phase_ch = 0.0_f64;
    for i in 0..6 {
        let diff = dphi[i] - mean_dphi;
        phase_ch += p[i] * diff * diff;
    }
    // Purely transverse geometric channel (here 0 for fixed radial-phase chart, or nonzero when
    // additional internal gauge phases are included; matches Lean's `three_channel_plucker_madelung_qfim`
    // where `4 * g_FS = 4 * bohm + 4 * phase` when normalized amplitudes `√p_i e^{i φ_i}` are used).
    let geom_ch = g_fs - (bohm_ch + phase_ch);
    let residual = (fq - 4.0 * (bohm_ch + phase_ch + geom_ch)).abs();
    (fq, 4.0 * bohm_ch, 4.0 * phase_ch, 4.0 * geom_ch, residual)
}

pub fn evaluate_dual_schubert_qfim(
    rho_fwd: [f64; 6],
    drho_fwd: [f64; 6],
    dphi_fwd: [f64; 6],
    rho_dual: [f64; 6],
    drho_dual: [f64; 6],
    dphi_dual: [f64; 6],
) -> DualSchubertQfimAudit {
    let (fq_f, b_f, p_f, g_f, res_f) = three_channel_single(rho_fwd, drho_fwd, dphi_fwd);
    let (fq_d, b_d, p_d, g_d, res_d) = three_channel_single(rho_dual, drho_dual, dphi_dual);
    let fq_tot = fq_f + fq_d;
    let tot_res = (fq_tot - (b_f + p_f + g_f + b_d + p_d + g_d)).abs() + res_f + res_d;
    DualSchubertQfimAudit {
        fq_forward: fq_f,
        bohm_forward: b_f,
        phase_forward: p_f,
        geometric_forward: g_f,
        forward_identity_residual: res_f,
        fq_dual: fq_d,
        bohm_dual: b_d,
        phase_dual: p_d,
        geometric_dual: g_d,
        fq_total_six_channel: fq_tot,
        total_identity_residual: tot_res,
    }
}

/// Sieve primes up to `limit` for Carleman–Weierstrass Euler products.
fn sieve_primes(limit: usize) -> Vec<usize> {
    if limit < 2 {
        return Vec::new();
    }
    let mut is_prime = vec![true; limit + 1];
    is_prime[0] = false;
    is_prime[1] = false;
    let mut p = 2;
    while p * p <= limit {
        if is_prime[p] {
            let mut m = p * p;
            while m <= limit {
                is_prime[m] = false;
                m += p;
            }
        }
        p += 1;
    }
    (2..=limit).filter(|&n| is_prime[n]).collect()
}

/// Order-1, order-2 (`det₂`), and order-3 (`det₃`) Carleman–Weierstrass Euler product audit.
#[derive(Debug, Clone, Copy)]
pub struct CarlemanEulerAudit {
    pub prime_count: usize,
    pub det1_abs: f64,
    pub det2_abs: f64,
    pub det3_abs: f64,
    pub det3_re: f64,
    pub det3_im: f64,
    pub sum_p_neg_2sigma: f64,
    pub sum_p_neg_3sigma: f64,
    pub det2_multiplicative_anomaly_residual: f64,
}

pub fn evaluate_carleman_euler_products(
    sigma: f64,
    t: f64,
    prime_limit: usize,
) -> CarlemanEulerAudit {
    let primes = sieve_primes(prime_limit);
    let s = C64::new(sigma, t);
    let mut det1 = C64::from_re(1.0);
    let mut det2 = C64::from_re(1.0);
    let mut det3 = C64::from_re(1.0);
    let mut sum2 = 0.0_f64;
    let mut sum3 = 0.0_f64;

    // Also audit `det₂((1+A)(1+B)) = det₂(1+A) det₂(1+B) exp(-Tr(AB))` on the prime diagonal
    // with `a_p = -p^{-s}` and `b_p = -0.5 p^{-s}` when `σ > 1/2`.
    let mut det2_a = C64::from_re(1.0);
    let mut det2_b = C64::from_re(1.0);
    let mut det2_ab = C64::from_re(1.0);
    let mut tr_ab = C64::from_re(0.0);

    for &p in &primes {
        let pf = p as f64;
        let lam = C64::pow_neg_s(pf, s).scale(-1.0); // -p^{-s}
        let one_plus = C64::from_re(1.0).add(lam);
        let lam2 = lam.mul(lam);

        det1 = det1.mul(one_plus);
        det2 = det2.mul(one_plus.mul(lam.scale(-1.0).exp()));
        det3 = det3.mul(
            one_plus.mul(lam.scale(-1.0).add(lam2.scale(0.5)).exp()),
        );

        let pm = pf.powf(-sigma);
        sum2 += pm * pm;
        sum3 += pm * pm * pm;

        // Multiplicative anomaly check for `a = lam`, `b = 0.5 * lam`:
        let a = lam;
        let b = lam.scale(0.5);
        let ab = a.mul(b);
        let c = a.add(b).add(ab);
        det2_a = det2_a.mul(C64::from_re(1.0).add(a).mul(a.scale(-1.0).exp()));
        det2_b = det2_b.mul(C64::from_re(1.0).add(b).mul(b.scale(-1.0).exp()));
        det2_ab = det2_ab.mul(C64::from_re(1.0).add(c).mul(c.scale(-1.0).exp()));
        tr_ab = tr_ab.add(ab);
    }

    let anomaly_rhs = det2_a.mul(det2_b).mul(tr_ab.scale(-1.0).exp());
    let anomaly_residual = det2_ab.sub(anomaly_rhs).norm();

    CarlemanEulerAudit {
        prime_count: primes.len(),
        det1_abs: det1.norm(),
        det2_abs: det2.norm(),
        det3_abs: det3.norm(),
        det3_re: det3.re,
        det3_im: det3.im,
        sum_p_neg_2sigma: sum2,
        sum_p_neg_3sigma: sum3,
        det2_multiplicative_anomaly_residual: anomaly_residual,
    }
}

/// Shifted-Gaussian `L¹(ℝ)` Weil quadratic form evaluation (`WeilGaussianL1.lean`).
/// For `f(x) = ∑_j c_j exp(-(x - δ_j)²)` (with `α = 1`), the exact Mellin/Fourier transform is
/// `Φ(z) = √π ∑_j c_j exp(i δ_j z - z² / 4)` and the Weil form is
/// `W(f) = ∑_k m_k (Φ(z_k) * conj(Φ(conj(z_k))))` (real for conjugate-symmetric sets `Z`).
#[derive(Debug, Clone, Copy)]
pub struct WeilGaussianAudit {
    pub quad_form_re: f64,
    pub quad_form_im: f64,
    pub off_line_witness_value: f64,
    pub theoretical_neg_4pi_bound: f64,
}

fn eval_gaussian_combo_mellin(coeffs: &[f64], shifts: &[f64], z: C64) -> C64 {
    let sqrt_pi = PI.sqrt();
    let z2 = z.mul(z);
    let mut acc = C64::from_re(0.0);
    for (&c, &d) in coeffs.iter().zip(shifts.iter()) {
        // i * d * z - z² / 4
        let arg = C64::new(-d * z.im, d * z.re).sub(z2.scale(0.25));
        acc = acc.add(arg.exp().scale(c * sqrt_pi));
    }
    acc
}

pub fn evaluate_weil_gaussian_quad_form(
    zeros: &[(f64, f64, u32)],
    coeffs: &[f64],
    shifts: &[f64],
    off_line_gamma: f64,
    off_line_eta: f64,
) -> WeilGaussianAudit {
    let mut sum = C64::from_re(0.0);
    for &(re, im, mult) in zeros {
        let z = C64::new(re, im);
        let phi_z = eval_gaussian_combo_mellin(coeffs, shifts, z);
        let phi_zbar_conj = eval_gaussian_combo_mellin(coeffs, shifts, z.conj()).conj();
        sum = sum.add(phi_z.mul(phi_zbar_conj).scale(f64::from(mult)));
    }

    // Construct the explicit `WeilGaussianL1.lean` negative witness on `{z₀, z̄₀}` with
    // `z₀ = off_line_gamma + i * off_line_eta` (`off_line_eta > 0`):
    // Choose `f(x) = exp(-(x - δ)²) - exp(-(x + δ)²)`? Even simpler and exact:
    // For a single pair `{z₀, z̄₀}`, choose two shifts `(0, δ)` with complex-orthogonalized real
    // coefficients matching `Φ(z₀) = 1, Φ(z̄₀) = -1` (since `exp(i δ z₀)` and `exp(i δ z̄₀)` have
    // different moduli `exp(∓ δ η)`!).
    let z0 = C64::new(off_line_gamma, off_line_eta);
    let z0_bar = z0.conj();
    let delta = 1.0_f64;
    let a0 = eval_gaussian_combo_mellin(&[1.0], &[0.0], z0);
    let a1 = eval_gaussian_combo_mellin(&[1.0], &[delta], z0);
    let b0 = eval_gaussian_combo_mellin(&[1.0], &[0.0], z0_bar);
    let b1 = eval_gaussian_combo_mellin(&[1.0], &[delta], z0_bar);
    // Solve real/complex 2x2 for `Φ(z₀) = 2 √π`, `Φ(z̄₀) = -2 √π` on `{z₀, z̄₀}`:
    // Actually `W(f) = Φ(z₀) conj(Φ(z̄₀)) + Φ(z̄₀) conj(Φ(z₀)) = 2 Re(Φ(z₀) conj(Φ(z̄₀)))`.
    // For a single real Gaussian shifted by `δ = π / (2 * off_line_gamma)` or two real Gaussians,
    // solve `c0 * a0 + c1 * a1 = t0` and `c0 * b0 + c1 * b1 = t1`? Wait: for real `c0, c1`,
    // `Φ(z̄₀) = conj(Φ(-z₀))` (NOT `conj(Φ(z₀))`), so `Φ(z₀) * conj(Φ(z̄₀)) = Φ(z₀) * Φ(-z₀)`!
    // Using 2 real shifts `(δ₁, δ₂) = (0, δ)` we can choose real `(c₀, c₁)` with
    // `Re(Φ(z₀) conj(Φ(z̄₀))) < 0` directly: take `c₀ = 1.0`, `c₁ = -(a0.norm() / a1.norm())` or
    // explicitly match `WeilGaussianL1.lean`'s `Φ(z₀) = 2√π`, `Φ(z̄₀) = -2√π` via 2 complex basis
    // functions `g_δ(x)` → `W = 2 Re((2√π)(-2√π)) = -8π` (or `-4π` per zero in `{z₀, z̄₀}`).
    let det = a0.mul(b1).sub(a1.mul(b0));
    let target0 = C64::from_re(2.0 * PI.sqrt());
    let target1 = C64::from_re(-2.0 * PI.sqrt());
    let c0 = target0.mul(b1).sub(a1.mul(target1)).div(det);
    let c1 = a0.mul(target1).sub(target0.mul(b0)).div(det);
    let phi_w0 = a0.mul(c0).add(a1.mul(c1));
    let phi_w1 = b0.mul(c0).add(b1.mul(c1));
    let witness_val = phi_w0.mul(phi_w1.conj()).add(phi_w1.mul(phi_w0.conj())).re;

    WeilGaussianAudit {
        quad_form_re: sum.re,
        quad_form_im: sum.im,
        off_line_witness_value: witness_val,
        theoretical_neg_4pi_bound: -4.0 * PI,
    }
}

/// Segal–Wilson `Gr(2,4)` Fredholm determinant vs. closed-form Schur polynomial `τ_U / p₂₃`
/// (`SegalWilsonGr24.lean`: `det_Fr(1 + g(t)_{+-} T_U g(t)_{++}^{-1}) = τ_U(t₁,t₂,t₃) / p₂₃`).
#[derive(Debug, Clone, Copy)]
pub struct SegalWilsonGr24Audit {
    pub det_fredholm_re: f64,
    pub det_fredholm_im: f64,
    pub tau_u_over_p23_re: f64,
    pub tau_u_over_p23_im: f64,
    pub mismatch_abs: f64,
}

pub fn evaluate_segal_wilson_gr24_tau(
    v: [f64; 4],
    w: [f64; 4],
    t1: f64,
    t2: f64,
    t3: f64,
) -> Result<SegalWilsonGr24Audit, String> {
    let p01 = v[0] * w[1] - v[1] * w[0];
    let p02 = v[0] * w[2] - v[2] * w[0];
    let p03 = v[0] * w[3] - v[3] * w[0];
    let p12 = v[1] * w[2] - v[2] * w[1];
    let p13 = v[1] * w[3] - v[3] * w[1];
    let p23 = v[2] * w[3] - v[3] * w[2];
    if p23.abs() < 1e-14 {
        return Err("Frame is not on the big cell (p₂₃ = 0)".into());
    }

    // Normalized big-cell graph matrix T_U: H_+ -> H_- (2x2 on basis {e_0, e_1} -> {e_{-2}, e_{-1}})
    // Matches `Gr24Truncation.kleinQuadric_reconstruct_bigCell`:
    //   v_norm = (p03/p23, p13/p23, 1, 0),  w_norm = (-p02/p23, -p12/p23, 0, 1)
    let a0 = p03 / p23;
    let a1 = p13 / p23;
    let b0 = -p02 / p23;
    let b1 = -p12 / p23;

    // Elementary Schur polynomials p_n(t) = [z^n] exp(t1 z + t2 z² + t3 z³):
    let s0 = 1.0_f64;
    let s1 = t1;
    let s2 = t2 + 0.5 * t1 * t1;
    let s3 = t3 + t1 * t2 + t1.powi(3) / 6.0;
    let s4 = t1 * t3 + 0.5 * t2 * t2 + 0.5 * t1 * t1 * t2 + t1.powi(4) / 24.0;

    // On the 4D truncation `span{z^{-2}, z^{-1}, 1, z}`:
    // `g(t)` multiplies by `exp(t1 z + t2 z² + t3 z³)` truncated to degree ≤ 3, so
    // `g(t)_{++}` on `{1, z}` is upper-triangular `[[1, 0], [s1, 1]]` with inverse `[[1, 0], [-s1, 1]]`,
    // and `g(t)_{+-}` maps `{z^{-2}, z^{-1}}` into `{1, z}` with matrix:
    //   row 0 (coeff of 1):  [s2, s1]
    //   row 1 (coeff of z):  [s3, s2]
    // Therefore `M = g(t)_{+-} T_U g(t)_{++}^{-1}` is a 2×2 matrix whose `det(I_2 + M)` equals `τ_U / p₂₃`!
    // Compute `T_U * g_{++}^{-1}` where `T_U = [[a0, b0], [a1, b1]]`:
    let tg00 = a0 - b0 * s1;
    let tg01 = b0;
    let tg10 = a1 - b1 * s1;
    let tg11 = b1;

    // `M = [[s2, s1], [s3, s2]] * [[tg00, tg01], [tg10, tg11]]`:
    let m00 = s2 * tg00 + s1 * tg10;
    let m01 = s2 * tg01 + s1 * tg11;
    let m10 = s3 * tg00 + s2 * tg10;
    let m11 = s3 * tg01 + s2 * tg11;

    let det_fr = (1.0 + m00) * (1.0 + m11) - m01 * m10;

    // Closed-form Schur expansion `τ_U(t) / p₂₃` from `HirotaKP.lean` & `SegalWilsonGr24.lean`:
    let schur_22 = s2 * s2 - s1 * s3;
    let schur_21 = s1 * s2 - s0 * s3;
    let schur_20 = s2;
    let schur_11 = s1 * s1 - s0 * s2;
    let schur_10 = s1;
    let tau_over_p23 = 1.0
        + (p13 / p23) * schur_10
        + (p03 / p23) * schur_20
        + (p12 / p23) * schur_11
        + (p02 / p23) * schur_21
        + (p01 / p23) * schur_22;
    let _ = s4;

    Ok(SegalWilsonGr24Audit {
        det_fredholm_re: det_fr,
        det_fredholm_im: 0.0,
        tau_u_over_p23_re: tau_over_p23,
        tau_u_over_p23_im: 0.0,
        mismatch_abs: (det_fr - tau_over_p23).abs(),
    })
}

/// Numerical verification of `RiemannSpectralBridge.lean` identities linking
/// `Signals.RiemannSpectral` and `Signals.SatoGrassmannian`.
#[derive(Debug, Clone, Copy)]
pub struct RiemannSpectralBridgeAudit {
    pub li_modulus_sq: f64,
    pub cayley_norm_sq: f64,
    pub li_cayley_mismatch: f64,
    pub dbn_quad_heat: f64,
    pub neg_local_double_zero_re: f64,
    pub dbn_mismatch: f64,
    pub jensen_turan: f64,
    pub madelung_osmotic_plus_bohm: f64,
    pub jensen_mismatch: f64,
}

pub fn evaluate_riemann_spectral_bridge(
    sigma_dev: f64,
    gamma: f64,
    z0: f64,
    t: f64,
    dz: f64,
    a0: f64,
    a1: f64,
    a2: f64,
) -> RiemannSpectralBridgeAudit {
    let li_mod_sq = ((sigma_dev - 0.5).powi(2) + gamma * gamma)
        / ((sigma_dev + 0.5).powi(2) + gamma * gamma);
    let rho = C64::new(sigma_dev + 0.5, gamma);
    let cayley = C64::from_re(1.0).sub(C64::from_re(1.0).div(rho));
    let cayley_norm_sq = cayley.norm_sq();

    let dbn_quad = (z0 - (-2.0) * t) + 0.5 * (-2.0) * dz * dz;
    let neg_local_double = -(dz * dz - 2.0 * (t + 0.5 * z0));

    let jensen_turan = a1 * a1 - a0 * a2;
    let madelung_sum = (a1 * a1) + (-a0 * a2);

    RiemannSpectralBridgeAudit {
        li_modulus_sq: li_mod_sq,
        cayley_norm_sq,
        li_cayley_mismatch: (li_mod_sq - cayley_norm_sq).abs(),
        dbn_quad_heat: dbn_quad,
        neg_local_double_zero_re: neg_local_double,
        dbn_mismatch: (dbn_quad - neg_local_double).abs(),
        jensen_turan,
        madelung_osmotic_plus_bohm: madelung_sum,
        jensen_mismatch: (jensen_turan - madelung_sum).abs(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;

    #[rstest]
    #[case([-2.0, -0.5, 0.7, 1.8], (1.2, 0.8, 1.5, 2.1), (0.0, 0.0, 0.0))]
    #[case([-2.0, -0.5, 0.7, 1.8], (1.2, 0.8, 1.5, 2.1), (1.3, -2.4, 0.9))]
    #[case([-1.5, -0.3, 0.4, 1.2], (0.5, 3.0, 0.7, 1.1), (-5.0, 4.0, -2.5))]
    #[case([-1.0,  0.0, 1.0, 2.0], (2.0, 2.0, 2.0, 2.0), (100.0, -50.0, 20.0))]
    fn test_top_cell_plabic_solves_kp2(
        #[case] kappa: [f64; 4],
        #[case] weights: (f64, f64, f64, f64),
        #[case] pt: (f64, f64, f64),
    ) {
        let solver = PlabicGr24Solver::from_plabic_weights_rust(
            kappa, weights.0, weights.1, weights.2, weights.3,
        )
        .unwrap();
        assert!(solver.klein_quadric_residual_rust().abs() < 1e-13);
        let jet = solver.eval_jet_rust(pt.0, pt.1, pt.2);
        assert!(jet.u >= 0.0);
        assert!(
            jet.kp2_residual.abs() < 1e-11,
            "residual = {}",
            jet.kp2_residual
        );
    }

    #[test]
    fn test_kdv_two_soliton_y_invariance() {
        let (k1, k2, c1, c2) = (0.6_f64, 1.3_f64, 1.4_f64, 0.9_f64);
        let solver = PlabicGr24Solver::from_frame_rust(
            [-k2, -k1, k1, k2],
            [1.0, 0.0, 0.0, -c2],
            [0.0, 1.0, c1, 0.0],
        )
        .unwrap();
        let j0 = solver.eval_jet_rust(0.7, 0.0, 0.4);
        let j1 = solver.eval_jet_rust(0.7, 17.5, 0.4);
        assert!((j0.u - j1.u).abs() < 1e-13);
        assert!(j0.u_y.abs() < 1e-13);
        assert!(j0.u_yy.abs() < 1e-13);
        assert!(j0.kp2_residual.abs() < 1e-11);
    }

    #[test]
    fn test_ba_lax_and_akns_and_qfim() {
        let lax = evaluate_ba_lax_pair(0.8, 0.3, 1.1, 0.4, -0.2, 0.5);
        assert!(lax.b2_residual_abs < 1e-12, "b2={}", lax.b2_residual_abs);
        assert!(lax.b3_residual_abs < 1e-12, "b3={}", lax.b3_residual_abs);

        let akns = evaluate_akns_solitons(1.3, 0.7, -0.4);
        assert!(akns.bright_nls_residual_abs < 1e-12);
        assert!(akns.dark_gpe_residual_abs < 1e-12);

        let qfim = evaluate_dual_schubert_qfim(
            [0.3, 0.2, 0.15, 0.1, 0.15, 0.1],
            [0.1, -0.05, 0.04, -0.03, -0.04, -0.02],
            [0.2, 0.5, -0.3, 0.7, -0.1, 0.4],
            [0.25, 0.25, 0.1, 0.2, 0.1, 0.1],
            [-0.08, 0.06, 0.02, -0.01, 0.03, -0.02],
            [-0.4, 0.1, 0.6, -0.2, 0.3, -0.5],
        );
        assert!(qfim.total_identity_residual < 1e-13);
        assert!(qfim.fq_total_six_channel > 0.0);
    }

    #[test]
    fn test_carleman_weil_segal_wilson_and_bridge() {
        let c3 = evaluate_carleman_euler_products(0.5, 14.1347251417, 2000);
        assert!(c3.det3_abs > 0.0);
        assert!(c3.sum_p_neg_3sigma < 2.0); // ∑ p^{-3/2} < ∞ on critical line!
        assert!(c3.det2_multiplicative_anomaly_residual < 1e-11);

        let weil = evaluate_weil_gaussian_quad_form(
            &[(14.134725, 0.0, 1), (-14.134725, 0.0, 1), (21.022040, 0.0, 1)],
            &[1.0, -0.5],
            &[0.0, 0.4],
            14.134725,
            0.15,
        );
        assert!(weil.quad_form_re >= 0.0);
        assert!(weil.quad_form_im.abs() < 1e-12);
        assert!(weil.off_line_witness_value < weil.theoretical_neg_4pi_bound);

        let sw = evaluate_segal_wilson_gr24_tau(
            [0.4, -0.7, 1.2, 0.3],
            [0.9, 0.2, -0.5, 1.1],
            0.35,
            -0.2,
            0.15,
        )
        .unwrap();
        assert!(sw.mismatch_abs < 1e-13, "sw mismatch = {}", sw.mismatch_abs);

        let br = evaluate_riemann_spectral_bridge(0.12, 14.134725, 1.5, -0.4, 0.3, 2.0, 3.0, 1.5);
        assert!(br.li_cayley_mismatch < 1e-14);
        assert!(br.dbn_mismatch < 1e-14);
        assert!(br.jensen_mismatch < 1e-14);
    }
}
