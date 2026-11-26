//! Antimatter annihilation ($e^- e^+ \to 2\gamma / 3\gamma$) and CERN `ALPHA-g` (2023)
//! model-testing diagnostics mirroring `Signals.AntimatterGravity`.

use std::f64::consts::LN_2;

pub const ELECTRON_REST_ENERGY_KEV: f64 = 510.998_950_00;
pub const ALPHA_G_MEASURED_RATIO: f64 = 0.75;
pub const ALPHA_G_STAT_SYST_SIGMA: f64 = 0.13;
pub const ALPHA_G_SIM_SIGMA: f64 = 0.16;
pub const ALPHA_G_STANDARD_G0_MPS2: f64 = 9.806_65;
pub const ALPHA_G_CERN_LOCAL_G_MPS2: f64 = 9.805_6;
pub const SPEED_OF_LIGHT_MPS: f64 = 299_792_458.0;

/// Calibrated logistic trap-width `sigma_b` in units of `g0` matching `P_down(0; +1 g0) = 0.80`
/// (`1 / (1 + exp(-1 / sigma_b)) = 0.80 => sigma_b = 1 / ln(4)`).
pub fn calibrated_alpha_g_trap_sigma_b() -> f64 {
    1.0 / (2.0 * LN_2)
}

pub fn alpha_g_total_sigma() -> f64 {
    (ALPHA_G_STAT_SYST_SIGMA.powi(2) + ALPHA_G_SIM_SIGMA.powi(2)).sqrt()
}

pub fn alpha_g_chi_sq(a_pred: f64) -> f64 {
    let diff = ALPHA_G_MEASURED_RATIO - a_pred;
    let var = ALPHA_G_STAT_SYST_SIGMA.powi(2) + ALPHA_G_SIM_SIGMA.powi(2);
    (diff * diff) / var
}

pub fn alpha_g_z_score(a_pred: f64) -> f64 {
    (ALPHA_G_MEASURED_RATIO - a_pred) / alpha_g_total_sigma()
}

pub fn alpha_g_trap_downward_fraction(bias_g: f64, a_pred: f64, sigma_b: f64) -> Result<f64, String> {
    if sigma_b <= 0.0 || !sigma_b.is_finite() {
        return Err("sigma_b must be positive and finite".to_string());
    }
    Ok(1.0 / (1.0 + (-(bias_g + a_pred) / sigma_b).exp()))
}

#[derive(Debug, Clone)]
pub struct AntimatterModelEvaluation {
    pub model_name: String,
    pub predicted_a_over_g0: f64,
    pub eta_act_gamma: f64,
    pub active_mass_deficit_fraction: f64,
    pub z_score: f64,
    pub chi_sq: f64,
    pub consistent_within_2sigma: bool,
    pub active_mass_conserved: bool,
    pub zero_bias_downward_fraction: f64,
}

#[derive(Debug, Clone)]
pub struct AlphaGSuiteSummary {
    pub total_sigma: f64,
    pub calibrated_sigma_b: f64,
    pub e_gamma_kev: f64,
    pub two_photon_invariant_mass_kev: f64,
    pub witten_gamma_conf_2sigma_upper_bound_inv_m: f64,
    pub witten_gamma_conf_2sigma_lower_bound_inv_m: f64,
    pub models: Vec<AntimatterModelEvaluation>,
    pub bias_scan_g: Vec<f64>,
    pub p_down_normal_wep: Vec<f64>,
    pub p_down_zero_g: Vec<f64>,
    pub p_down_antigravity: Vec<f64>,
}

fn eval_model(
    name: &str,
    a_pred: f64,
    eta_act_gamma: f64,
    sigma_b: f64,
) -> Result<AntimatterModelEvaluation, String> {
    let chi_sq = alpha_g_chi_sq(a_pred);
    let z = alpha_g_z_score(a_pred);
    let deficit_frac = 1.0 - eta_act_gamma;
    let p_down_0 = alpha_g_trap_downward_fraction(0.0, a_pred, sigma_b)?;
    Ok(AntimatterModelEvaluation {
        model_name: name.to_string(),
        predicted_a_over_g0: a_pred,
        eta_act_gamma,
        active_mass_deficit_fraction: deficit_frac,
        z_score: z,
        chi_sq,
        consistent_within_2sigma: z.abs() <= 2.0,
        active_mass_conserved: deficit_frac.abs() < 1e-12,
        zero_bias_downward_fraction: p_down_0,
    })
}

pub fn evaluate_alpha_g_model_suite() -> Result<AlphaGSuiteSummary, String> {
    let sigma_tot = alpha_g_total_sigma();
    let sigma_b = calibrated_alpha_g_trap_sigma_b();

    // Witten conformal linear Rindler term a_Weyl/g0 = 1 - gamma_conf * c^2 / (2 * g0)
    // 2-sigma ALPHA-g interval: a_pred in [0.75 - 2*sigma_tot, 0.75 + 2*sigma_tot]
    // => gamma_conf in [(1 - (0.75 + 2*sigma_tot)) * 2*g0/c^2, (1 - (0.75 - 2*sigma_tot)) * 2*g0/c^2]
    let c_sq = SPEED_OF_LIGHT_MPS * SPEED_OF_LIGHT_MPS;
    let scale = 2.0 * ALPHA_G_STANDARD_G0_MPS2 / c_sq;
    let a_upper = ALPHA_G_MEASURED_RATIO + 2.0 * sigma_tot;
    let a_lower = ALPHA_G_MEASURED_RATIO - 2.0 * sigma_tot;
    let witten_gamma_lower = (1.0 - a_upper) * scale;
    let witten_gamma_upper = (1.0 - a_lower) * scale;

    let models = vec![
        eval_model("Einstein GR (gamma_PPN=1, beta_PPN=1)", 1.0, 1.0, sigma_b)?,
        eval_model("Witten (2004) Scale-Free Conformal (beta_scale=0)", 0.0, 1.0, sigma_b)?,
        eval_model("Cachazo-Skinner (2012) Infinity-Twistor (pi_I=1, Lambda=0)", 1.0, 1.0, sigma_b)?,
        eval_model("QED Scattering Gravity (BCJ / Partanen-Tulkki 2025 U(1)^4)", 1.0, 1.0, sigma_b)?,
        // Note: Nordstrom couples to trace T^mu_mu; slow H_bar has T^mu_mu = -rho c^2 (~+1 g0 fall),
        // while 2 gamma after annihilation has T^mu_mu = 0 (eta_act_trace = 0).
        eval_model("Nordstrom (1913) Scalar Gravity (trace-coupled)", 1.0, 0.0, sigma_b)?,
        eval_model("Spin-1 Vector Gravity (even-C +1, misses light bending)", 1.0, 0.5, sigma_b)?,
        eval_model("Spin-1 Vector Gravity (odd-C baryon/lepton graviphoton -1)", -1.0, 0.5, sigma_b)?,
        eval_model("DDF Positive-Inertia Sink (Fedi 2026, m_g=+m_i, eta_act=0)", 1.0, 0.0, sigma_b)?,
        eval_model("DDF Speculative Anti-Sink (m_g=-m_i)", -1.0, 0.0, sigma_b)?,
        eval_model("Turner Model 3 / Model 6 (Gr_C(2,4)/Q_4 coherent escape)", 1.0, 1.0, sigma_b)?,
        eval_model("Turner Model 12 (Gr_C(2,4) BCJ + 3D Splat, No DDF)", 1.0, 1.0, sigma_b)?,
        eval_model("Turner Model 13 (Gr_C(2,4) + DDF + 3D Splat)", 1.0, 0.0, sigma_b)?,
        eval_model("Turner Model 14a (Q_4 Kahler + Dual-iGPE, No DDF)", 1.0, 1.0, sigma_b)?,
        eval_model("Turner Model 14b (Q_4 Kahler + Dual-iGPE + DDF)", 1.0, 0.0, sigma_b)?,
        eval_model("Turner Model 15a (Celestial + Q_4 + Plancherel, No DDF)", 1.0, 1.0, sigma_b)?,
        eval_model("Turner Model 15b (Celestial + Q_4 + Plancherel + DDF)", 1.0, 0.0, sigma_b)?,
    ];

    let bias_scan_g = vec![-9.5, -3.5, -1.5, 0.0, 1.5, 3.5, 9.5];
    let mut p_down_normal_wep = Vec::with_capacity(bias_scan_g.len());
    let mut p_down_zero_g = Vec::with_capacity(bias_scan_g.len());
    let mut p_down_antigravity = Vec::with_capacity(bias_scan_g.len());
    for &b in &bias_scan_g {
        p_down_normal_wep.push(alpha_g_trap_downward_fraction(b, 1.0, sigma_b)?);
        p_down_zero_g.push(alpha_g_trap_downward_fraction(b, 0.0, sigma_b)?);
        p_down_antigravity.push(alpha_g_trap_downward_fraction(b, -1.0, sigma_b)?);
    }

    Ok(AlphaGSuiteSummary {
        total_sigma: sigma_tot,
        calibrated_sigma_b: sigma_b,
        e_gamma_kev: ELECTRON_REST_ENERGY_KEV,
        two_photon_invariant_mass_kev: 2.0 * ELECTRON_REST_ENERGY_KEV,
        witten_gamma_conf_2sigma_upper_bound_inv_m: witten_gamma_upper,
        witten_gamma_conf_2sigma_lower_bound_inv_m: witten_gamma_lower,
        models,
        bias_scan_g,
        p_down_normal_wep,
        p_down_zero_g,
        p_down_antigravity,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_alpha_g_exact_chi_sq_and_trap_curve() {
        let suite = evaluate_alpha_g_model_suite().expect("suite succeeds");
        assert!((suite.total_sigma - (0.0425_f64).sqrt()).abs() < 1e-15);
        assert!((alpha_g_chi_sq(1.0) - 25.0 / 17.0).abs() < 1e-13);
        assert!((alpha_g_chi_sq(0.0) - 225.0 / 17.0).abs() < 1e-13);
        assert!((alpha_g_chi_sq(-1.0) - 1225.0 / 17.0).abs() < 1e-13);

        // Zero-bias calibrated escape probability: P_down(0; +1) == 0.80, P_down(0; 0) == 0.50, P_down(0; -1) == 0.20
        assert!((suite.p_down_normal_wep[3] - 0.80).abs() < 1e-12);
        assert!((suite.p_down_zero_g[3] - 0.50).abs() < 1e-12);
        assert!((suite.p_down_antigravity[3] - 0.20).abs() < 1e-12);

        // Rejections > 3.6 sigma (0 g) and > 8 sigma (-1 g)
        assert!(alpha_g_z_score(0.0) > 3.6);
        assert!(alpha_g_z_score(-1.0) > 8.4);
        assert!(alpha_g_z_score(1.0).abs() < 1.25);

        // Check active mass conservation separation
        let gr = &suite.models[0];
        let ddf_pos = &suite.models[7];
        assert!(gr.consistent_within_2sigma && gr.active_mass_conserved);
        assert!(ddf_pos.consistent_within_2sigma && !ddf_pos.active_mass_conserved);
        assert!((ddf_pos.active_mass_deficit_fraction - 1.0).abs() < 1e-15);
    }
}
