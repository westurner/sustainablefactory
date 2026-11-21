//! Native Rust + PyO3 numerical auditors and structure-preserving PDE solvers for
//! `Signals.NavierStokes` (Compressible & Incompressible Navier–Stokes via Three-Channel
//! Plücker–Madelung and Six-Channel Dual-Schubert QFIM `F_μν = 4 g_FS_μν`).
//!
//! Matches the zero-`sorry` Lean 4 formalization in:
//! - `Signals.NavierStokes.PluckerFrame`
//! - `Signals.NavierStokes.Incompressible`
//! - `Signals.NavierStokes.Compressible`
//! - `Signals.Pending.DualSchubertNavierStokesPendingBoundary`

use std::f64::consts::PI;

#[cfg(feature = "python")]
use pyo3::exceptions::PyValueError;
#[cfg(feature = "python")]
use pyo3::prelude::*;

use crate::sato_grassmannian::C64;

/* ============================================================================
 * 1. Analytical Auditors (Machine-Precision Cross-Checks for Lean 4 & SymPy)
 * ============================================================================ */

#[derive(Debug, Clone, Copy)]
pub struct SchubertChartTransitionAudit {
    pub p01_abs: f64,
    pub p02_abs: f64,
    pub klein_quadric_residual: f64,
    pub cancellation_residual: f64,
    pub omega02_u01_abs: f64,
    pub omega02_u13_identity_residual: f64,
    pub qfim_regularized_at_node: f64,
    pub chart_switched_to_omega02: bool,
}

/// Evaluates a `4 × 2` 1-jet Stiefel frame crossing the nodal Schubert divisor `Σ₁ = {p₀₁ = 0}`
/// as `eps -> 0`, verifying Klein quadric closure, `1/p₀₁²` cancellation, and smooth bounded
/// `Ω₀₂` coordinates + projective QFIM across the vortex core.
pub fn evaluate_schubert_chart_transition_vortex(
    eps: f64,
    x: f64,
    y: f64,
) -> SchubertChartTransitionAudit {
    // 4×2 Stiefel jet frame:
    // row 0: (eps + i*0, 1)
    // row 1: (x, y)   -> p01 = eps*y - x
    // row 2: (1, i)   -> p02 = i*eps - 1  (|p02| >= 1 everywhere, even at p01 = 0!)
    // row 3: (0.5, 1.2 + 0.3i)
    let z = [
        [C64::new(eps, 0.0), C64::new(1.0, 0.0)],
        [C64::new(x, 0.0), C64::new(y, 0.0)],
        [C64::new(1.0, 0.0), C64::new(0.0, 1.0)],
        [C64::new(0.5, 0.0), C64::new(1.2, 0.3)],
    ];
    let minor = |i: usize, j: usize| z[i][0].mul(z[j][1]).sub(z[i][1].mul(z[j][0]));
    let p01 = minor(0, 1);
    let p02 = minor(0, 2);
    let p03 = minor(0, 3);
    let p12 = minor(1, 2);
    let p13 = minor(1, 3);
    let p23 = minor(2, 3);

    let klein = p01.mul(p23).sub(p02.mul(p13)).add(p03.mul(p12));
    let cancel_res = if p01.norm() > 1e-12 {
        let lhs = p02.mul(p13).sub(p03.mul(p12)).div(p01.mul(p01));
        let rhs = p23.div(p01);
        lhs.sub(rhs).norm()
    } else {
        // On Σ₁ (`p01 = 0`), check the divisor balance `p02*p13 - p03*p12 = 0`
        p02.mul(p13).sub(p03.mul(p12)).norm()
    };

    // Ω₀₂ chart coordinates normalized by p02 (always nonzero here)
    let u01 = p01.div(p02);
    let u03 = p03.div(p02);
    let u12 = p12.div(p02);
    let u13 = p13.div(p02);
    let u23 = p23.div(p02);
    let u13_res = u13.sub(u03.mul(u12).add(u01.mul(u23))).norm();

    // Projective QFIM along `d/d(eps)` at the node: dp = (y, i, 1.2+0.3i, 0, 0, 0)
    let p_vec = [p01, p02, p03, p12, p13, p23];
    let dp_vec = [
        C64::new(y, 0.0),
        C64::new(0.0, 1.0),
        C64::new(1.2, 0.3),
        C64::new(0.0, 0.0),
        C64::new(0.0, 0.0),
        C64::new(0.0, 0.0),
    ];
    let p_norm_sq: f64 = p_vec.iter().map(|c| c.norm_sq()).sum();
    let dp_norm_sq: f64 = dp_vec.iter().map(|c| c.norm_sq()).sum();
    let mut inner = C64::new(0.0, 0.0);
    for k in 0..6 {
        inner = inner.add(p_vec[k].conj().mul(dp_vec[k]));
    }
    let g_fs = dp_norm_sq / p_norm_sq - inner.norm_sq() / (p_norm_sq * p_norm_sq);
    let qfim = 4.0 * g_fs;

    SchubertChartTransitionAudit {
        p01_abs: p01.norm(),
        p02_abs: p02.norm(),
        klein_quadric_residual: klein.norm(),
        cancellation_residual: cancel_res,
        omega02_u01_abs: u01.norm(),
        omega02_u13_identity_residual: u13_res,
        qfim_regularized_at_node: qfim,
        chart_switched_to_omega02: p01.norm() < 0.25 * p02.norm(),
    }
}

#[derive(Debug, Clone, Copy)]
pub struct BatemanVsChatAudit {
    pub chat_hermiticity_residual: f64,
    pub chat_total_norm_rate: f64,
    pub bateman_primal_norm_rate: f64,
    pub bateman_expected_primal_rate: f64,
    pub bateman_dual_norm_rate: f64,
    pub bateman_pairing_rate_abs: f64,
}

/// Audits Chat Defect #2: proves `H_chat` is Hermitian with zero dissipation while the corrected
/// Bateman operator dissipates primal energy at `-2 ν k² |ψ|²` and conserves `conj(ψ̃) ψ`.
pub fn evaluate_bateman_vs_chat_heff(
    e_val: f64,
    hbar: f64,
    nu: f64,
    k: f64,
    psi_re: f64,
    psi_im: f64,
    psit_re: f64,
    psit_im: f64,
) -> Result<BatemanVsChatAudit, String> {
    if hbar <= 0.0 {
        return Err("hbar must be strictly positive".to_string());
    }
    let psi = C64::new(psi_re, psi_im);
    let psit = C64::new(psit_re, psit_im);
    let d = hbar * nu * k * k;

    // H_chat = [[E, +i d], [-i d, E]]
    let h00 = C64::new(e_val, 0.0);
    let h01 = C64::new(0.0, d);
    let h10 = C64::new(0.0, -d);
    let h11 = C64::new(e_val, 0.0);
    let herm_res = (h00.sub(h00.conj())).norm()
        + (h01.sub(h10.conj())).norm()
        + (h10.sub(h01.conj())).norm()
        + (h11.sub(h11.conj())).norm();

    let minus_i_over_h = C64::new(0.0, -1.0 / hbar);
    let dpsi_chat = minus_i_over_h.mul(h00.mul(psi).add(h01.mul(psit)));
    let dpsit_chat = minus_i_over_h.mul(h10.mul(psi).add(h11.mul(psit)));
    let chat_norm_rate =
        2.0 * (psi.conj().mul(dpsi_chat).add(psit.conj().mul(dpsit_chat))).re;

    // H_bateman = diag(E - i d, E + i d)
    let b00 = C64::new(e_val, -d);
    let b11 = C64::new(e_val, d);
    let dpsi_bat = minus_i_over_h.mul(b00.mul(psi));
    let dpsit_bat = minus_i_over_h.mul(b11.mul(psit));
    let primal_rate = 2.0 * (psi.conj().mul(dpsi_bat)).re;
    let dual_rate = 2.0 * (psit.conj().mul(dpsit_bat)).re;
    let expected_primal = -2.0 * nu * k * k * psi.norm_sq();
    let pairing_rate = dpsit_bat.conj().mul(psi).add(psit.conj().mul(dpsi_bat)).norm();

    Ok(BatemanVsChatAudit {
        chat_hermiticity_residual: herm_res,
        chat_total_norm_rate: chat_norm_rate,
        bateman_primal_norm_rate: primal_rate,
        bateman_expected_primal_rate: expected_primal,
        bateman_dual_norm_rate: dual_rate,
        bateman_pairing_rate_abs: pairing_rate,
    })
}

#[derive(Debug, Clone, Copy)]
pub struct ClebschSpinorAudit {
    pub unit_norm_residual: f64,
    pub berry_velocity_x: f64,
    pub berry_velocity_y: f64,
    pub qfim_xx: f64,
    pub fubini_study_xx: f64,
    pub qfim_identity_residual: f64,
    pub vorticity_z: f64,
}

/// Evaluates the 2-component Clebsch spinor lift (`PluckerFrame.lean` Sec. 2).
#[allow(clippy::too_many_arguments)]
pub fn evaluate_clebsch_spinor_vorticity(
    hbar: f64,
    mass: f64,
    theta: f64,
    dtheta_x: f64,
    dtheta_y: f64,
    dphi1_x: f64,
    dphi1_y: f64,
    dphi2_x: f64,
    dphi2_y: f64,
) -> Result<ClebschSpinorAudit, String> {
    if hbar <= 0.0 || mass <= 0.0 {
        return Err("hbar and mass must be strictly positive".to_string());
    }
    let c = (0.5 * theta).cos();
    let s = (0.5 * theta).sin();
    let norm_res = (c * c + s * s - 1.0).abs();
    let ax = c * c * dphi1_x + s * s * dphi2_x;
    let ay = c * c * dphi1_y + s * s * dphi2_y;
    let vx = (hbar / mass) * ax;
    let vy = (hbar / mass) * ay;
    let g_fs_xx = 0.25 * (dtheta_x * dtheta_x + theta.sin().powi(2) * (dphi1_x - dphi2_x).powi(2));
    let qfim_xx = 4.0 * g_fs_xx;
    let dp_sq_x = 0.25 * dtheta_x * dtheta_x + c * c * dphi1_x * dphi1_x + s * s * dphi2_x * dphi2_x;
    let qfim_res = (qfim_xx - 4.0 * (dp_sq_x - ax * ax)).abs();
    let vort_z = (hbar / (2.0 * mass))
        * theta.sin()
        * (dtheta_x * (dphi2_y - dphi1_y) - dtheta_y * (dphi2_x - dphi1_x));
    Ok(ClebschSpinorAudit {
        unit_norm_residual: norm_res,
        berry_velocity_x: vx,
        berry_velocity_y: vy,
        qfim_xx,
        fubini_study_xx: g_fs_xx,
        qfim_identity_residual: qfim_res,
        vorticity_z: vort_z,
    })
}

#[derive(Debug, Clone, Copy)]
pub struct TaylorGreen2DAudit {
    pub u: f64,
    pub v: f64,
    pub pressure: f64,
    pub vorticity: f64,
    pub div_residual: f64,
    pub mom_x_residual: f64,
    pub mom_y_residual: f64,
    pub energy: f64,
    pub enstrophy: f64,
    pub energy_enstrophy_decay_residual: f64,
    pub ch2_osmotic_energy: f64,
}

/// Evaluates the exact 2D Taylor–Green decaying vortex incompressible NS residuals.
pub fn evaluate_taylor_green_2d(
    rho0: f64,
    u0: f64,
    nu: f64,
    k: f64,
    x: f64,
    y: f64,
    t: f64,
) -> Result<TaylorGreen2DAudit, String> {
    if rho0 <= 0.0 || nu < 0.0 {
        return Err("rho0 must be > 0 and nu >= 0".to_string());
    }
    let decay = (-2.0 * nu * k * k * t).exp();
    let cx = (k * x).cos();
    let sx = (k * x).sin();
    let cy = (k * y).cos();
    let sy = (k * y).sin();

    let u = u0 * cx * sy * decay;
    let v = -u0 * sx * cy * decay;
    let p = -0.25 * rho0 * u0 * u0 * ((2.0 * k * x).cos() + (2.0 * k * y).cos()) * decay * decay;
    let vort = -2.0 * k * u0 * cx * cy * decay;

    let ux = -k * u0 * sx * sy * decay;
    let uy = k * u0 * cx * cy * decay;
    let ut = -2.0 * nu * k * k * u;
    let lap_u = -2.0 * k * k * u;

    let vx = -k * u0 * cx * cy * decay;
    let vy = k * u0 * sx * sy * decay;
    let vt = -2.0 * nu * k * k * v;
    let lap_v = -2.0 * k * k * v;

    let px = 0.5 * rho0 * u0 * u0 * k * (2.0 * k * x).sin() * decay * decay;
    let py = 0.5 * rho0 * u0 * u0 * k * (2.0 * k * y).sin() * decay * decay;

    let div_res = (ux + vy).abs();
    let mom_x = (ut + u * ux + v * uy + px / rho0 - nu * lap_u).abs();
    let mom_y = (vt + u * vx + v * vy + py / rho0 - nu * lap_v).abs();

    let energy = 0.25 * u0 * u0 * decay * decay;
    let enstrophy = 0.5 * k * k * u0 * u0 * decay * decay;
    let de_dt = -4.0 * nu * k * k * energy;
    let decay_res = (de_dt + 2.0 * nu * enstrophy).abs();

    Ok(TaylorGreen2DAudit {
        u,
        v,
        pressure: p,
        vorticity: vort,
        div_residual: div_res,
        mom_x_residual: mom_x,
        mom_y_residual: mom_y,
        energy,
        enstrophy,
        energy_enstrophy_decay_residual: decay_res,
        ch2_osmotic_energy: 0.0,
    })
}

#[derive(Debug, Clone, Copy)]
pub struct LambOseen2DAudit {
    pub vorticity: f64,
    pub peak_core_vorticity: f64,
    pub heat_pde_residual: f64,
}

/// Evaluates the exact 2D Lamb–Oseen viscous vortex vorticity heat PDE residual.
pub fn evaluate_lamb_oseen_2d(
    gamma: f64,
    nu: f64,
    x: f64,
    y: f64,
    t: f64,
) -> Result<LambOseen2DAudit, String> {
    if nu <= 0.0 || t <= 0.0 {
        return Err("nu and t must be strictly positive".to_string());
    }
    let r2 = x * x + y * y;
    let peak = gamma / (4.0 * PI * nu * t);
    let omega = peak * (-r2 / (4.0 * nu * t)).exp();
    let omega_t = (r2 / (4.0 * nu * t * t) - 1.0 / t) * omega;
    let omega_xx = (x * x / (4.0 * nu * nu * t * t) - 1.0 / (2.0 * nu * t)) * omega;
    let omega_yy = (y * y / (4.0 * nu * nu * t * t) - 1.0 / (2.0 * nu * t)) * omega;
    let res = (omega_t - nu * (omega_xx + omega_yy)).abs();
    Ok(LambOseen2DAudit {
        vorticity: omega,
        peak_core_vorticity: peak,
        heat_pde_residual: res,
    })
}

#[derive(Debug, Clone, Copy)]
pub struct BeltramiABC3DAudit {
    pub eigen_curl_residual: f64,
    pub laplacian_residual: f64,
    pub momentum_max_residual: f64,
    pub helicity: f64,
}

/// Evaluates the exact 3D decaying Beltrami / ABC incompressible NS solution.
#[allow(clippy::too_many_arguments)]
pub fn evaluate_beltrami_abc_3d(
    rho0: f64,
    a: f64,
    b: f64,
    c: f64,
    nu: f64,
    k: f64,
    x: f64,
    y: f64,
    z: f64,
    t: f64,
) -> Result<BeltramiABC3DAudit, String> {
    if rho0 <= 0.0 || nu < 0.0 {
        return Err("rho0 must be > 0 and nu >= 0".to_string());
    }
    let d = (-nu * k * k * t).exp();
    let u = (a * (k * z).sin() + c * (k * y).cos()) * d;
    let v = (b * (k * x).sin() + a * (k * z).cos()) * d;
    let w = (c * (k * y).sin() + b * (k * x).cos()) * d;

    let uy = -k * c * (k * y).sin() * d;
    let uz = k * a * (k * z).cos() * d;
    let vx = k * b * (k * x).cos() * d;
    let vz = -k * a * (k * z).sin() * d;
    let wx = -k * b * (k * x).sin() * d;
    let wy = k * c * (k * y).cos() * d;

    let curl_x = wy - vz;
    let curl_y = uz - wx;
    let curl_z = vx - uy;
    let eigen_curl_res = ((curl_x - k * u).powi(2)
        + (curl_y - k * v).powi(2)
        + (curl_z - k * w).powi(2))
    .sqrt();

    let lap_u = (-k * k * c * (k * y).cos() - k * k * a * (k * z).sin()) * d;
    let lap_v = (-k * k * b * (k * x).sin() - k * k * a * (k * z).cos()) * d;
    let lap_w = (-k * k * b * (k * x).cos() - k * k * c * (k * y).sin()) * d;
    let lap_res = ((lap_u + k * k * u).powi(2)
        + (lap_v + k * k * v).powi(2)
        + (lap_w + k * k * w).powi(2))
    .sqrt();

    let ut = -nu * k * k * u;
    let vt = -nu * k * k * v;
    let wt = -nu * k * k * w;
    let px = -rho0 * (v * vx + w * wx);
    let py = -rho0 * (u * uy + w * wy);
    let pz = -rho0 * (u * uz + v * vz);

    let mx = (ut + v * uy + w * uz + px / rho0 - nu * lap_u).abs();
    let my = (vt + u * vx + w * vz + py / rho0 - nu * lap_v).abs();
    let mz = (wt + u * wx + v * wy + pz / rho0 - nu * lap_w).abs();

    Ok(BeltramiABC3DAudit {
        eigen_curl_residual: eigen_curl_res,
        laplacian_residual: lap_res,
        momentum_max_residual: mx.max(my).max(mz),
        helicity: u * curl_x + v * curl_y + w * curl_z,
    })
}

#[derive(Debug, Clone, Copy)]
pub struct ViscousBurgersColeHopfAudit {
    pub velocity: f64,
    pub burgers_pde_residual: f64,
    pub cole_hopf_tau_heat_residual: f64,
    pub cole_hopf_velocity_residual: f64,
}

/// Evaluates the exact moving viscous Burgers tanh shock and its Sato/Cole–Hopf `τ`-function.
pub fn evaluate_viscous_burgers_cole_hopf(
    c: f64,
    a: f64,
    nu: f64,
    x: f64,
    t: f64,
) -> Result<ViscousBurgersColeHopfAudit, String> {
    if nu <= 0.0 {
        return Err("nu must be strictly positive".to_string());
    }
    let xi = (a / (2.0 * nu)) * (x - c * t);
    let th = xi.tanh();
    let sech2 = 1.0 - th * th;
    let v = c - a * th;
    let vx = -(a * a / (2.0 * nu)) * sech2;
    let vxx = (a * a * a / (2.0 * nu * nu)) * th * sech2;
    let vt = (c * a * a / (2.0 * nu)) * sech2;
    let burgers_res = (vt + v * vx - nu * vxx).abs();

    // Sato / Cole–Hopf 2-exponential τ-function (shifted for numerical safety):
    // τ(x, t) = exp(α₁ x + ν α₁² t) + exp(α₂ x + ν α₂² t) with α₁ = -(c+a)/(2ν), α₂ = -(c-a)/(2ν)
    let a1 = -(c + a) / (2.0 * nu);
    let a2 = -(c - a) / (2.0 * nu);
    let p1 = a1 * x + nu * a1 * a1 * t;
    let p2 = a2 * x + nu * a2 * a2 * t;
    let m = p1.max(p2);
    let e1 = (p1 - m).exp();
    let e2 = (p2 - m).exp();
    let tau = e1 + e2;
    let tau_x = a1 * e1 + a2 * e2;
    let tau_xx = a1 * a1 * e1 + a2 * a2 * e2;
    let tau_t = (nu * a1 * a1) * e1 + (nu * a2 * a2) * e2;
    let heat_res = (tau_t - nu * tau_xx).abs();
    let ch_vel = -2.0 * nu * tau_x / tau;
    let ch_vel_res = (v - ch_vel).abs();

    Ok(ViscousBurgersColeHopfAudit {
        velocity: v,
        burgers_pde_residual: burgers_res,
        cole_hopf_tau_heat_residual: heat_res,
        cole_hopf_velocity_residual: ch_vel_res,
    })
}

#[derive(Debug, Clone, Copy)]
pub struct CompressibleNskKortewegBdAudit {
    pub viscous_dissipation: f64,
    pub dissipation_split_residual: f64,
    pub korteweg_force_residual: f64,
    pub bd_dual_schubert_residual: f64,
    pub stokes_omega_re: f64,
    pub stokes_omega_im: f64,
    pub stokes_dispersion_residual: f64,
}

/// Evaluates compressible viscous dissipation, Korteweg stress divergence, Bresch–Desjardins
/// Dual-Schubert energy split, and linearized compressible Stokes acoustic dispersion.
#[allow(clippy::too_many_arguments)]
pub fn evaluate_compressible_nsk_korteweg_bd(
    hbar: f64,
    mass: f64,
    mu: f64,
    zeta: f64,
    rho: f64,
    rho_x: f64,
    rho_xx: f64,
    rho_xxx: f64,
    s11: f64,
    s22: f64,
    s33: f64,
    s12: f64,
    s13: f64,
    s23: f64,
    v: f64,
    cs: f64,
    k: f64,
) -> Result<CompressibleNskKortewegBdAudit, String> {
    if hbar <= 0.0 || mass <= 0.0 || rho <= 0.0 || mu < 0.0 || zeta < 0.0 || cs <= 0.0 {
        return Err("invalid physical parameters (hbar, mass, rho, cs > 0; mu, zeta >= 0)".to_string());
    }
    let div_v = s11 + s22 + s33;
    let lam = zeta - (2.0 / 3.0) * mu;
    let phi_visc = (2.0 * mu * s11 + lam * div_v) * s11
        + (2.0 * mu * s22 + lam * div_v) * s22
        + (2.0 * mu * s33 + lam * div_v) * s33
        + 2.0 * (2.0 * mu * (s12 * s12 + s13 * s13 + s23 * s23));
    let phi_split = (2.0 * mu / 3.0)
        * ((s11 - s22).powi(2) + (s22 - s33).powi(2) + (s33 - s11).powi(2))
        + 4.0 * mu * (s12 * s12 + s13 * s13 + s23 * s23)
        + zeta * div_v * div_v;
    let split_res = (phi_visc - phi_split).abs();

    // Korteweg stress divergence vs. -(ρ/m) ∂_x Q
    let q_x = -(hbar * hbar / (4.0 * mass))
        * (rho_xxx / rho - 2.0 * rho_x * rho_xx / (rho * rho) + rho_x.powi(3) / rho.powi(3));
    let k_xx_x = (hbar * hbar / (4.0 * mass * mass))
        * (rho_xxx - 2.0 * rho_x * rho_xx / rho + rho_x.powi(3) / (rho * rho));
    let korteweg_res = (-(rho / mass) * q_x - k_xx_x).abs();

    // Bresch–Desjardins Dual-Schubert energy identity (ν = μ / ρ)
    let nu = mu / rho;
    let vp = v + nu * (rho_x / rho);
    let vm = v - nu * (rho_x / rho);
    let bd_lhs = 0.5 * rho * (vp * vp + vm * vm);
    let bd_rhs = rho * v * v + nu * nu * (rho_x * rho_x / rho);
    let bd_res = (bd_lhs - bd_rhs).abs();

    // Linearized compressible Stokes acoustic dispersion
    let delta = (4.0 / 3.0) * nu + zeta / rho;
    let disc = cs * cs * k * k - 0.25 * delta * delta * k.powi(4);
    if disc < 0.0 {
        return Err("overdamped Stokes acoustic regime (delta * |k| > 2 * cs)".to_string());
    }
    let omega = C64::new(disc.sqrt(), -0.5 * delta * k * k);
    let disp = omega
        .mul(omega)
        .add(C64::new(0.0, delta * k * k).mul(omega))
        .sub(C64::from_re(cs * cs * k * k));

    Ok(CompressibleNskKortewegBdAudit {
        viscous_dissipation: phi_visc,
        dissipation_split_residual: split_res,
        korteweg_force_residual: korteweg_res,
        bd_dual_schubert_residual: bd_res,
        stokes_omega_re: omega.re,
        stokes_omega_im: omega.im,
        stokes_dispersion_residual: disp.norm(),
    })
}

/* ============================================================================
 * 2. Incompressible 2D Dual-Schubert Spectral/Projection Solver
 * ============================================================================ */

/// Diagnostics snapshot for `IncompressibleDualSchubertSolver2D`.
#[cfg_attr(feature = "python", pyclass(get_all))]
#[derive(Debug, Clone, Copy)]
pub struct IncompressibleSnapshot2D {
    pub time: f64,
    pub kinetic_energy: f64,
    pub enstrophy: f64,
    pub max_divergence: f64,
    pub ch1_hydro_energy: f64,
    pub ch2_osmotic_energy: f64,
    pub ch3_qfim_energy: f64,
    pub dual_schubert_qfim_total: f64,
    pub schubert_omega02_cells: usize,
}

/// Pure-Rust 2D periodic incompressible Navier–Stokes solver on `[0, 2π)²` using exact
/// spectral Helmholtz–Leray projection + RK2 viscous-convective integration, tracking the
/// incompressible Dual-Schubert QFIM channels (`Ch. 2 ≡ 0`) and Schubert chart transitions.
#[cfg_attr(feature = "python", pyclass)]
#[derive(Debug, Clone)]
pub struct IncompressibleDualSchubertSolver2D {
    pub n: usize,
    pub nu: f64,
    pub rho0: f64,
    pub time: f64,
    u: Vec<f64>,
    v: Vec<f64>,
}

fn dft_2d_forward(n: usize, field: &[f64]) -> Vec<C64> {
    // Separable 2D DFT: transform rows, then columns.
    let inv_n = 1.0 / (n as f64);
    let mut tmp = vec![C64::new(0.0, 0.0); n * n];
    for j in 0..n {
        for kx in 0..n {
            let mut sum = C64::new(0.0, 0.0);
            for i in 0..n {
                let ang = -2.0 * PI * ((kx * i) as f64) * inv_n;
                let val = field[j * n + i];
                sum.re += val * ang.cos();
                sum.im += val * ang.sin();
            }
            tmp[j * n + kx] = sum.scale(inv_n);
        }
    }
    let mut out = vec![C64::new(0.0, 0.0); n * n];
    for kx in 0..n {
        for ky in 0..n {
            let mut sum = C64::new(0.0, 0.0);
            for j in 0..n {
                let ang = -2.0 * PI * ((ky * j) as f64) * inv_n;
                let w = C64::new(ang.cos(), ang.sin());
                sum = sum.add(tmp[j * n + kx].mul(w));
            }
            out[ky * n + kx] = sum.scale(inv_n);
        }
    }
    out
}

fn dft_2d_inverse_real(n: usize, hat: &[C64]) -> Vec<f64> {
    let inv_n = 1.0 / (n as f64);
    let mut tmp = vec![C64::new(0.0, 0.0); n * n];
    for ky in 0..n {
        for i in 0..n {
            let mut sum = C64::new(0.0, 0.0);
            for kx in 0..n {
                let ang = 2.0 * PI * ((kx * i) as f64) * inv_n;
                let w = C64::new(ang.cos(), ang.sin());
                sum = sum.add(hat[ky * n + kx].mul(w));
            }
            tmp[ky * n + i] = sum;
        }
    }
    let mut out = vec![0.0; n * n];
    for i in 0..n {
        for j in 0..n {
            let mut sum = 0.0;
            for ky in 0..n {
                let ang = 2.0 * PI * ((ky * j) as f64) * inv_n;
                let c = tmp[ky * n + i];
                sum += c.re * ang.cos() - c.im * ang.sin();
            }
            out[j * n + i] = sum;
        }
    }
    out
}

#[inline]
fn signed_wavenumber(k: usize, n: usize) -> f64 {
    if k <= n / 2 {
        k as f64
    } else {
        (k as isize - n as isize) as f64
    }
}

impl IncompressibleDualSchubertSolver2D {
    pub fn from_taylor_green_rust(n: usize, u0: f64, nu: f64, k_mode: f64) -> Result<Self, String> {
        if n < 8 || n > 64 {
            return Err("n must be between 8 and 64".to_string());
        }
        if nu < 0.0 {
            return Err("nu must be >= 0".to_string());
        }
        let dx = 2.0 * PI / (n as f64);
        let mut u = vec![0.0; n * n];
        let mut v = vec![0.0; n * n];
        for j in 0..n {
            let y = (j as f64) * dx;
            for i in 0..n {
                let x = (i as f64) * dx;
                u[j * n + i] = u0 * (k_mode * x).cos() * (k_mode * y).sin();
                v[j * n + i] = -u0 * (k_mode * x).sin() * (k_mode * y).cos();
            }
        }
        Ok(Self {
            n,
            nu,
            rho0: 1.0,
            time: 0.0,
            u,
            v,
        })
    }

    fn spectral_rhs(&self, u_hat: &[C64], v_hat: &[C64]) -> (Vec<C64>, Vec<C64>) {
        let n = self.n;
        let u = dft_2d_inverse_real(n, u_hat);
        let v = dft_2d_inverse_real(n, v_hat);

        // Compute vorticity ω_hat = i (kx v_hat - ky u_hat) for rotational form (u×ω)
        // which is exact & energy-conserving on periodic domains.
        let mut omega_hat = vec![C64::new(0.0, 0.0); n * n];
        for ky_idx in 0..n {
            let ky = signed_wavenumber(ky_idx, n);
            for kx_idx in 0..n {
                let kx = signed_wavenumber(kx_idx, n);
                let idx = ky_idx * n + kx_idx;
                let diff = v_hat[idx].scale(kx).sub(u_hat[idx].scale(ky));
                omega_hat[idx] = C64::new(-diff.im, diff.re);
            }
        }
        let omega = dft_2d_inverse_real(n, &omega_hat);

        // Lamb vector: nl_u = +v * omega, nl_v = -u * omega (since -(v·∇)v = v×ω - ∇(|v|²/2))
        let mut nl_u = vec![0.0; n * n];
        let mut nl_v = vec![0.0; n * n];
        for idx in 0..(n * n) {
            nl_u[idx] = v[idx] * omega[idx];
            nl_v[idx] = -u[idx] * omega[idx];
        }
        let mut nl_u_hat = dft_2d_forward(n, &nl_u);
        let mut nl_v_hat = dft_2d_forward(n, &nl_v);

        // 2/3 Orszag dealiasing + exact Helmholtz–Leray projection + viscous damping
        let k_cut = (n as f64) / 3.0;
        for ky_idx in 0..n {
            let ky = signed_wavenumber(ky_idx, n);
            for kx_idx in 0..n {
                let kx = signed_wavenumber(kx_idx, n);
                let idx = ky_idx * n + kx_idx;
                let k2 = kx * kx + ky * ky;
                if kx.abs() > k_cut || ky.abs() > k_cut {
                    nl_u_hat[idx] = C64::new(0.0, 0.0);
                    nl_v_hat[idx] = C64::new(0.0, 0.0);
                } else if k2 > 0.0 {
                    // Leray projection P = I - k k^T / |k|²
                    let dot = nl_u_hat[idx].scale(kx).add(nl_v_hat[idx].scale(ky));
                    nl_u_hat[idx] = nl_u_hat[idx].sub(dot.scale(kx / k2));
                    nl_v_hat[idx] = nl_v_hat[idx].sub(dot.scale(ky / k2));
                }
                // Viscous term -ν k² u_hat
                nl_u_hat[idx] = nl_u_hat[idx].sub(u_hat[idx].scale(self.nu * k2));
                nl_v_hat[idx] = nl_v_hat[idx].sub(v_hat[idx].scale(self.nu * k2));
            }
        }
        (nl_u_hat, nl_v_hat)
    }

    pub fn step_rk2_rust(&mut self, dt: f64, steps: usize) -> Result<IncompressibleSnapshot2D, String> {
        if dt <= 0.0 {
            return Err("dt must be strictly positive".to_string());
        }
        let n = self.n;
        let mut u_hat = dft_2d_forward(n, &self.u);
        let mut v_hat = dft_2d_forward(n, &self.v);

        for _ in 0..steps {
            let (ku1, kv1) = self.spectral_rhs(&u_hat, &v_hat);
            let mut u_mid = vec![C64::new(0.0, 0.0); n * n];
            let mut v_mid = vec![C64::new(0.0, 0.0); n * n];
            for idx in 0..(n * n) {
                u_mid[idx] = u_hat[idx].add(ku1[idx].scale(dt));
                v_mid[idx] = v_hat[idx].add(kv1[idx].scale(dt));
            }
            let (ku2, kv2) = self.spectral_rhs(&u_mid, &v_mid);
            for idx in 0..(n * n) {
                u_hat[idx] = u_hat[idx].add(ku1[idx].add(ku2[idx]).scale(0.5 * dt));
                v_hat[idx] = v_hat[idx].add(kv1[idx].add(kv2[idx]).scale(0.5 * dt));
            }
            self.time += dt;
        }
        self.u = dft_2d_inverse_real(n, &u_hat);
        self.v = dft_2d_inverse_real(n, &v_hat);
        Ok(self.snapshot_rust())
    }

    pub fn snapshot_rust(&self) -> IncompressibleSnapshot2D {
        let n = self.n;
        let u_hat = dft_2d_forward(n, &self.u);
        let v_hat = dft_2d_forward(n, &self.v);
        let mut div_hat = vec![C64::new(0.0, 0.0); n * n];
        let mut omega_hat = vec![C64::new(0.0, 0.0); n * n];
        for ky_idx in 0..n {
            let ky = signed_wavenumber(ky_idx, n);
            for kx_idx in 0..n {
                let kx = signed_wavenumber(kx_idx, n);
                let idx = ky_idx * n + kx_idx;
                let sum = u_hat[idx].scale(kx).add(v_hat[idx].scale(ky));
                div_hat[idx] = C64::new(-sum.im, sum.re);
                let diff = v_hat[idx].scale(kx).sub(u_hat[idx].scale(ky));
                omega_hat[idx] = C64::new(-diff.im, diff.re);
            }
        }
        let div = dft_2d_inverse_real(n, &div_hat);
        let omega = dft_2d_inverse_real(n, &omega_hat);

        let inv_n2 = 1.0 / ((n * n) as f64);
        let mut energy = 0.0;
        let mut enstrophy = 0.0;
        let mut max_div = 0.0_f64;
        let mut omega02_cells = 0usize;
        for idx in 0..(n * n) {
            let v2 = self.u[idx] * self.u[idx] + self.v[idx] * self.v[idx];
            energy += 0.5 * v2 * inv_n2;
            enstrophy += 0.5 * omega[idx] * omega[idx] * inv_n2;
            max_div = max_div.max(div[idx].abs());
            // Track cells where velocity stagnation + nonzero vorticity triggers Schubert chart Ω₀₂
            if v2.sqrt() < 0.2 * omega[idx].abs() {
                omega02_cells += 1;
            }
        }
        // Incompressible 3-channel / Dual-Schubert QFIM budget:
        // Ch. 1 = primal macroscopic kinetic energy, Ch. 2 = 0 (∇ρ = 0),
        // Ch. 3 = projective spin-vorticity QFIM energy = enstrophy (F_Q = 4 g_FS).
        let ch1 = self.rho0 * energy;
        let ch3 = self.rho0 * enstrophy;
        IncompressibleSnapshot2D {
            time: self.time,
            kinetic_energy: energy,
            enstrophy,
            max_divergence: max_div,
            ch1_hydro_energy: ch1,
            ch2_osmotic_energy: 0.0,
            ch3_qfim_energy: ch3,
            dual_schubert_qfim_total: 4.0 * ch3,
            schubert_omega02_cells: omega02_cells,
        }
    }

    pub fn taylor_green_l2_error_rust(&self, u0: f64, k_mode: f64) -> f64 {
        let n = self.n;
        let dx = 2.0 * PI / (n as f64);
        let decay = (-2.0 * self.nu * k_mode * k_mode * self.time).exp();
        let mut err_sq = 0.0;
        for j in 0..n {
            let y = (j as f64) * dx;
            for i in 0..n {
                let x = (i as f64) * dx;
                let u_ex = u0 * (k_mode * x).cos() * (k_mode * y).sin() * decay;
                let v_ex = -u0 * (k_mode * x).sin() * (k_mode * y).cos() * decay;
                let du = self.u[j * n + i] - u_ex;
                let dv = self.v[j * n + i] - v_ex;
                err_sq += du * du + dv * dv;
            }
        }
        (err_sq / ((n * n) as f64)).sqrt()
    }
}

#[cfg(feature = "python")]
#[pymethods]
impl IncompressibleDualSchubertSolver2D {
    #[staticmethod]
    fn from_taylor_green(n: usize, u0: f64, nu: f64, k_mode: f64) -> PyResult<Self> {
        Self::from_taylor_green_rust(n, u0, nu, k_mode).map_err(PyValueError::new_err)
    }

    fn step_rk2(&mut self, dt: f64, steps: usize) -> PyResult<IncompressibleSnapshot2D> {
        self.step_rk2_rust(dt, steps).map_err(PyValueError::new_err)
    }

    fn snapshot(&self) -> IncompressibleSnapshot2D {
        self.snapshot_rust()
    }

    fn taylor_green_l2_error(&self, u0: f64, k_mode: f64) -> f64 {
        self.taylor_green_l2_error_rust(u0, k_mode)
    }
}

/* ============================================================================
 * 3. Compressible 1D Navier–Stokes–Korteweg Dual-Schubert Finite-Volume Solver
 * ============================================================================ */

/// Diagnostics snapshot for `CompressibleNskDualSchubertSolver1D`.
#[cfg_attr(feature = "python", pyclass(get_all))]
#[derive(Debug, Clone, Copy)]
pub struct CompressibleSnapshot1D {
    pub time: f64,
    pub total_mass: f64,
    pub total_momentum: f64,
    pub min_density: f64,
    pub ch1_hydro_energy: f64,
    pub ch2_osmotic_fisher_energy: f64,
    pub bd_dual_schubert_energy: f64,
    pub bd_identity_residual: f64,
    pub wave_amplitude: f64,
}

/// 1D periodic finite-volume solver for compressible barotropic Navier–Stokes–Korteweg (NSK):
///   `∂_t ρ + ∂_x (ρ u) = 0`
///   `∂_t (ρ u) + ∂_x (ρ u² + P(ρ) - τ_xx - K_xx) = 0`
/// with `P(ρ) = c_s² ρ + (g/2) ρ²`, `τ_xx = ((4/3) μ + ζ) ∂_x u`, and conservative
/// Korteweg capillary stress `K_xx = κ_K (ρ_xx - ρ_x² / ρ)` where `κ_K = ℏ² / (4 m²)`.
#[cfg_attr(feature = "python", pyclass)]
#[derive(Debug, Clone)]
pub struct CompressibleNskDualSchubertSolver1D {
    pub n: usize,
    pub length: f64,
    pub cs: f64,
    pub g_gp: f64,
    pub nu_bd: f64,
    pub zeta: f64,
    pub kappa_korteweg: f64,
    pub time: f64,
    rho: Vec<f64>,
    mom: Vec<f64>,
}

impl CompressibleNskDualSchubertSolver1D {
    #[allow(clippy::too_many_arguments)]
    pub fn from_acoustic_wave_rust(
        n: usize,
        length: f64,
        rho0: f64,
        amp: f64,
        cs: f64,
        g_gp: f64,
        nu_bd: f64,
        zeta: f64,
        kappa_korteweg: f64,
    ) -> Result<Self, String> {
        if n < 16 || length <= 0.0 || rho0 <= 0.0 || cs <= 0.0 || nu_bd < 0.0 || zeta < 0.0 || kappa_korteweg < 0.0 {
            return Err("invalid compressible NSK solver parameters".to_string());
        }
        if amp.abs() >= 0.5 * rho0 {
            return Err("wave amplitude must satisfy |amp| < 0.5 * rho0".to_string());
        }
        let dx = length / (n as f64);
        let k = 2.0 * PI / length;
        let c_eff = (cs * cs + g_gp * rho0).sqrt();
        let mut rho = vec![0.0; n];
        let mut mom = vec![0.0; n];
        for i in 0..n {
            let x = (i as f64 + 0.5) * dx;
            let r = rho0 + amp * (k * x).cos();
            // Right-traveling acoustic eigenmode: u = (c_eff / rho0) * (r - rho0)
            let u = (c_eff / rho0) * amp * (k * x).cos();
            rho[i] = r;
            mom[i] = r * u;
        }
        Ok(Self {
            n,
            length,
            cs,
            g_gp,
            nu_bd,
            zeta,
            kappa_korteweg,
            time: 0.0,
            rho,
            mom,
        })
    }

    fn rhs(&self, rho: &[f64], mom: &[f64]) -> (Vec<f64>, Vec<f64>) {
        let n = self.n;
        let dx = self.length / (n as f64);
        let inv_dx = 1.0 / dx;

        let mut u = vec![0.0; n];
        let mut p = vec![0.0; n];
        let mut c_loc = vec![0.0; n];
        for i in 0..n {
            let r = rho[i].max(1e-12);
            u[i] = mom[i] / r;
            p[i] = self.cs * self.cs * r + 0.5 * self.g_gp * r * r;
            c_loc[i] = (self.cs * self.cs + self.g_gp * r).max(1e-12).sqrt();
        }

        // Cell-centered Korteweg stress K_xx = κ_K (ρ_xx - ρ_x² / ρ)
        let mut k_stress = vec![0.0; n];
        if self.kappa_korteweg > 0.0 {
            for i in 0..n {
                let im = (i + n - 1) % n;
                let ip = (i + 1) % n;
                let rho_x = 0.5 * (rho[ip] - rho[im]) * inv_dx;
                let rho_xx = (rho[ip] - 2.0 * rho[i] + rho[im]) * inv_dx * inv_dx;
                k_stress[i] = self.kappa_korteweg * (rho_xx - rho_x * rho_x / rho[i].max(1e-12));
            }
        }

        // Interface fluxes F_{i+1/2} (Rusanov convective + central viscous & Korteweg)
        let mut f_rho = vec![0.0; n];
        let mut f_mom = vec![0.0; n];
        for i in 0..n {
            let ip = (i + 1) % n;
            let s_max = (u[i].abs() + c_loc[i]).max(u[ip].abs() + c_loc[ip]);
            // Mass flux
            f_rho[i] = 0.5 * (mom[i] + mom[ip]) - 0.5 * s_max * (rho[ip] - rho[i]);

            // Viscous stress at interface i+1/2: μ(ρ) = ν_bd * ρ_face
            let rho_face = 0.5 * (rho[i] + rho[ip]);
            let mu_face = self.nu_bd * rho_face;
            let du_dx = (u[ip] - u[i]) * inv_dx;
            let tau_xx = ((4.0 / 3.0) * mu_face + self.zeta) * du_dx;

            // Korteweg flux averaged to interface
            let k_face = 0.5 * (k_stress[i] + k_stress[ip]);

            let conv_l = mom[i] * u[i] + p[i];
            let conv_r = mom[ip] * u[ip] + p[ip];
            f_mom[i] = 0.5 * (conv_l + conv_r)
                - 0.5 * s_max * (mom[ip] - mom[i])
                - tau_xx
                - k_face;
        }

        let mut drho = vec![0.0; n];
        let mut dmom = vec![0.0; n];
        for i in 0..n {
            let im = (i + n - 1) % n;
            drho[i] = -(f_rho[i] - f_rho[im]) * inv_dx;
            dmom[i] = -(f_mom[i] - f_mom[im]) * inv_dx;
        }
        (drho, dmom)
    }

    pub fn step_rk2_rust(&mut self, dt: f64, steps: usize) -> Result<CompressibleSnapshot1D, String> {
        if dt <= 0.0 {
            return Err("dt must be strictly positive".to_string());
        }
        let n = self.n;
        for _ in 0..steps {
            let (dr1, dm1) = self.rhs(&self.rho, &self.mom);
            let mut r1 = vec![0.0; n];
            let mut m1 = vec![0.0; n];
            for i in 0..n {
                r1[i] = self.rho[i] + dt * dr1[i];
                m1[i] = self.mom[i] + dt * dm1[i];
                if r1[i] <= 0.0 || !r1[i].is_finite() {
                    return Err("density became non-positive or non-finite; reduce dt".to_string());
                }
            }
            let (dr2, dm2) = self.rhs(&r1, &m1);
            for i in 0..n {
                self.rho[i] = 0.5 * (self.rho[i] + r1[i] + dt * dr2[i]);
                self.mom[i] = 0.5 * (self.mom[i] + m1[i] + dt * dm2[i]);
                if self.rho[i] <= 0.0 || !self.rho[i].is_finite() {
                    return Err("density became non-positive or non-finite; reduce dt".to_string());
                }
            }
            self.time += dt;
        }
        Ok(self.snapshot_rust())
    }

    pub fn snapshot_rust(&self) -> CompressibleSnapshot1D {
        let n = self.n;
        let dx = self.length / (n as f64);
        let mut total_mass = 0.0;
        let mut total_mom = 0.0;
        let mut min_rho = f64::INFINITY;
        let mut max_rho = f64::NEG_INFINITY;
        let mut ch1 = 0.0;
        let mut ch2_osm = 0.0;
        let mut bd_dual = 0.0;

        for i in 0..n {
            let im = (i + n - 1) % n;
            let ip = (i + 1) % n;
            let r = self.rho[i];
            let u = self.mom[i] / r;
            let dr_dx = 0.5 * (self.rho[ip] - self.rho[im]) / dx;
            total_mass += r * dx;
            total_mom += self.mom[i] * dx;
            min_rho = min_rho.min(r);
            max_rho = max_rho.max(r);

            let e_hyd = 0.5 * r * u * u;
            let e_osm = 0.5 * self.nu_bd * self.nu_bd * (dr_dx * dr_dx / r);
            let vp = u + self.nu_bd * (dr_dx / r);
            let vm = u - self.nu_bd * (dr_dx / r);
            ch1 += e_hyd * dx;
            ch2_osm += e_osm * dx;
            bd_dual += 0.25 * r * (vp * vp + vm * vm) * dx;
        }
        CompressibleSnapshot1D {
            time: self.time,
            total_mass,
            total_momentum: total_mom,
            min_density: min_rho,
            ch1_hydro_energy: ch1,
            ch2_osmotic_fisher_energy: ch2_osm,
            bd_dual_schubert_energy: bd_dual,
            bd_identity_residual: (bd_dual - (ch1 + ch2_osm)).abs(),
            wave_amplitude: 0.5 * (max_rho - min_rho),
        }
    }
}

#[cfg(feature = "python")]
#[pymethods]
impl CompressibleNskDualSchubertSolver1D {
    #[staticmethod]
    #[allow(clippy::too_many_arguments)]
    fn from_acoustic_wave(
        n: usize,
        length: f64,
        rho0: f64,
        amp: f64,
        cs: f64,
        g_gp: f64,
        nu_bd: f64,
        zeta: f64,
        kappa_korteweg: f64,
    ) -> PyResult<Self> {
        Self::from_acoustic_wave_rust(n, length, rho0, amp, cs, g_gp, nu_bd, zeta, kappa_korteweg)
            .map_err(PyValueError::new_err)
    }

    fn step_rk2(&mut self, dt: f64, steps: usize) -> PyResult<CompressibleSnapshot1D> {
        self.step_rk2_rust(dt, steps).map_err(PyValueError::new_err)
    }

    fn snapshot(&self) -> CompressibleSnapshot1D {
        self.snapshot_rust()
    }
}

/* ============================================================================
 * 4. Rust Unit Tests
 * ============================================================================ */

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_schubert_chart_transition_across_nodal_divisor() {
        // Away from node (Ω₀)
        let a_away = evaluate_schubert_chart_transition_vortex(1.5, 0.4, 0.8);
        assert!(a_away.klein_quadric_residual < 1e-14);
        assert!(a_away.cancellation_residual < 1e-14);
        assert!(a_away.omega02_u13_identity_residual < 1e-14);
        // Exactly ON the Schubert divisor Σ₁ (`p01 = 0`, set eps = x = 0)
        let a_node = evaluate_schubert_chart_transition_vortex(0.0, 0.0, 0.8);
        assert!(a_node.p01_abs < 1e-15);
        assert!(a_node.p02_abs >= 1.0);
        assert!(a_node.chart_switched_to_omega02);
        assert!(a_node.klein_quadric_residual < 1e-15);
        assert!(a_node.cancellation_residual < 1e-15);
        assert!(a_node.omega02_u13_identity_residual < 1e-15);
        assert!(a_node.qfim_regularized_at_node.is_finite() && a_node.qfim_regularized_at_node > 0.0);
    }

    #[test]
    fn test_bateman_vs_chat_heff_defect_audit() {
        let a = evaluate_bateman_vs_chat_heff(1.2, 1.0, 0.05, 3.0, 0.7, -0.4, 0.5, 0.6).unwrap();
        assert!(a.chat_hermiticity_residual < 1e-15);
        assert!(a.chat_total_norm_rate.abs() < 1e-15);
        assert!(a.bateman_primal_norm_rate < 0.0);
        assert!((a.bateman_primal_norm_rate - a.bateman_expected_primal_rate).abs() < 1e-14);
        assert!(a.bateman_dual_norm_rate > 0.0);
        assert!(a.bateman_pairing_rate_abs < 1e-14);
    }

    #[test]
    fn test_clebsch_spinor_nonzero_vorticity_and_qfim() {
        let a = evaluate_clebsch_spinor_vorticity(1.0, 1.0, 0.5 * PI, 1.0, 0.0, 0.2, 0.0, 0.2, 1.0).unwrap();
        assert!(a.unit_norm_residual < 1e-15);
        assert!(a.qfim_identity_residual < 1e-14);
        assert!((a.qfim_xx - 4.0 * a.fubini_study_xx).abs() < 1e-15);
        assert!((a.vorticity_z - 0.5).abs() < 1e-15);
    }

    #[test]
    fn test_taylor_green_2d_exact_audit() {
        let a = evaluate_taylor_green_2d(1.2, 0.8, 0.05, 2.0, 0.37, -1.12, 0.45).unwrap();
        assert!(a.div_residual < 1e-14);
        assert!(a.mom_x_residual < 1e-14);
        assert!(a.mom_y_residual < 1e-14);
        assert!(a.energy_enstrophy_decay_residual < 1e-14);
        assert_eq!(a.ch2_osmotic_energy, 0.0);
    }

    #[test]
    fn test_lamb_oseen_2d_exact_audit() {
        let a = evaluate_lamb_oseen_2d(2.5, 0.04, 0.3, -0.5, 0.8).unwrap();
        assert!(a.heat_pde_residual < 1e-14);
        assert!(a.peak_core_vorticity > 0.0);
    }

    #[test]
    fn test_beltrami_abc_3d_exact_audit() {
        let a = evaluate_beltrami_abc_3d(1.3, 1.0, 0.7, -0.5, 0.03, 1.5, 0.4, -0.8, 1.1, 0.25).unwrap();
        assert!(a.eigen_curl_residual < 1e-14);
        assert!(a.laplacian_residual < 1e-14);
        assert!(a.momentum_max_residual < 1e-14);
        assert!(a.helicity > 0.0);
    }

    #[test]
    fn test_viscous_burgers_cole_hopf_audit() {
        let a = evaluate_viscous_burgers_cole_hopf(0.6, 1.2, 0.15, 0.9, 0.4).unwrap();
        assert!(a.burgers_pde_residual < 1e-14);
        assert!(a.cole_hopf_tau_heat_residual < 1e-14);
        assert!(a.cole_hopf_velocity_residual < 1e-14);
    }

    #[test]
    fn test_compressible_nsk_korteweg_bd_and_stokes_audit() {
        let a = evaluate_compressible_nsk_korteweg_bd(
            1.0, 1.0, 0.08, 0.02, 1.5, 0.3, -0.4, 0.2, 0.5, -0.2, 0.1, 0.3, -0.1, 0.2, 0.7, 2.0, 1.2,
        )
        .unwrap();
        assert!(a.viscous_dissipation > 0.0);
        assert!(a.dissipation_split_residual < 1e-14);
        assert!(a.korteweg_force_residual < 1e-14);
        assert!(a.bd_dual_schubert_residual < 1e-14);
        assert!(a.stokes_omega_im < 0.0);
        assert!(a.stokes_dispersion_residual < 1e-14);
    }

    #[test]
    fn test_incompressible_2d_solver_tracks_taylor_green_decay() {
        let mut solver = IncompressibleDualSchubertSolver2D::from_taylor_green_rust(16, 1.0, 0.1, 1.0).unwrap();
        let s0 = solver.snapshot_rust();
        assert!(s0.max_divergence < 1e-13);
        assert_eq!(s0.ch2_osmotic_energy, 0.0);
        assert!(s0.schubert_omega02_cells > 0);
        let s1 = solver.step_rk2_rust(0.01, 50).unwrap();
        assert!(s1.max_divergence < 1e-13);
        assert!(s1.kinetic_energy < s0.kinetic_energy);
        assert_eq!(s1.ch2_osmotic_energy, 0.0);
        let l2_err = solver.taylor_green_l2_error_rust(1.0, 1.0);
        assert!(l2_err < 1e-4, "Taylor-Green L2 error too large: {l2_err}");
    }

    #[test]
    fn test_compressible_1d_nsk_solver_mass_conservation_and_bd_identity() {
        let mut solver = CompressibleNskDualSchubertSolver1D::from_acoustic_wave_rust(
            64, 2.0 * PI, 1.0, 0.05, 1.0, 0.2, 0.05, 0.01, 0.002,
        )
        .unwrap();
        let s0 = solver.snapshot_rust();
        assert!(s0.bd_identity_residual < 1e-14);
        assert!(s0.ch2_osmotic_fisher_energy > 0.0);
        let s1 = solver.step_rk2_rust(0.002, 100).unwrap();
        assert!((s1.total_mass - s0.total_mass).abs() < 1e-12);
        assert!((s1.total_momentum - s0.total_momentum).abs() < 1e-12);
        assert!(s1.bd_identity_residual < 1e-14);
        assert!(s1.min_density > 0.0);
        assert!(s1.wave_amplitude < s0.wave_amplitude, "viscous wave must damp");
    }
}
