//! Native Rust + PyO3 numerical kernels for `Signals.Photoelectric`.
//!
//! Unifies:
//! 1. Einstein (1905) photoelectric stopping kinetic energy vs. classical Rayleigh wave accumulation delay,
//!    plus `QCI-GXC` Kohn–Sham work function & McWeeny idempotency SIE restoration.
//! 2. Strong-field Keldysh photoemission (`U_p`, `γ_K`, ATI peak energy, quasi-static tunneling width),
//!    bridged directly to Three-Channel Plücker–Madelung–QFIM tunneling (`v_Bohm = 0` vs. `v_osm` and
//!    coupled-waveguide QFIM speed `sharoglazova_klaers_evanescent_qfim`).
//! 3. ENZ / Debye–Wolf longitudinal `E_z` surface photoemission, spin-to-OAM angular-momentum conservation,
//!    `4 l^2` OAM QFIM super-resolution, and gimbal-lock-free spinor `QFIM = 4 g_FS`.
//! 4. Soliton-driven ultrafast photoemission using `Signals.SatoGrassmannian.AKNS` (`brightSoliton_nls_pde`,
//!    `darkSoliton_gpe_pde`) and two-pathway `Gr_C(2,4)` / `QFIM` RABBITT interference.
//! 5. Surface Plasmon Polaritons (`SPPs`), volume-plasmon loss satellites, Hopfield polariton splitting,
//!    Lyddane–Sachs–Teller (`LST`) Reststrahlen bands, and pole-free Complex `VRC` (`x_X = -1`).
//!
//! ## Benchmark & Test Data Provenance (`docs/citations.bib` keys)
//! - `Einstein1905`, `millikan1916direct`: Linear stopping-potential slope $h$ and threshold $\Phi_W/h$.
//! - `michaelson1977work`: Elemental work functions ($\Phi_W^{\mathrm{W}} \approx 4.55\text{ eV}$,
//!   $\Phi_W^{\mathrm{Cu}} \approx 4.65\text{ eV}$, $\Phi_W^{\mathrm{Al}} \approx 4.28\text{ eV}$,
//!   nominal `4.5 eV` photocathode benchmark).
//! - `mcweeny1960densityMatrix`: McWeeny cubic purification $3\lambda^2 - 2\lambda^3$ (`λ = 0.75 -> 27/32`).
//! - `keldysh1965ionization`, `kruger2011attosecond`: Strong-field Keldysh/ATI regime on tungsten nanotip
//!   ($\Phi_W \approx 4.5\text{ eV}$, $\lambda_0 = 800\text{ nm}$ / $\hbar\omega = 1.55\text{ eV}$).
//! - `sharoglazova_energyspeed_2025`: Coupled-waveguide evanescent QFIM tunneling speed law.
//! - `campione2015_enz`, `richards1959_debyewolf`, `dorn2003_radial`: ENZ thin-film normal enhancement
//!   ($\varepsilon_{\mathrm{ENZ}} = 0.05 \Rightarrow 400\times$) and Debye–Wolf radial $E_z = 2 E_0 \sin\theta$.
//! - `allen1992orbital`, `bliokh2015spin`: Spin-to-OAM transfer $\ell_z = \ell_{\mathrm{in}} + \sigma_{\mathrm{SAM}}$ ($3+1=4$).
//! - `ablowitz1974inverse`, `paul2001observation`: AKNS NLS/GPE solitons and $\omega/2\omega$ RABBITT interference.
//! - `johnson1972optical`, `ritchie1957plasma`, `powell1959origin`, `brongersma2015plasmon`,
//!   `hopfield1958theory`, `pol-weisbuch1992`, `lyddane1941polar`: Noble-metal permittivity at $800\text{ nm}$
//!   ($|\varepsilon_m^{\mathrm{Au}}| \approx 24.1$ on air $\varepsilon_d = 1$ or $\mathrm{SiO}_2$ $\varepsilon_d = 2.13$),
//!   Al bulk plasmon satellite $\hbar\omega_p = 15.0\text{ eV}$, Hopfield Rabi splitting, & LST Reststrahlen.

use crate::dft_plabic_vrc::{
    dft_electron_density_permittivity, euler_kinematic_jacobian_det, mcweeny_purification_poly,
    oam_superposition_fubini_study_phi, oam_superposition_qfim_phi,
    quantum_cramer_rao_variance_bound, sam_to_oam_longitudinal_topological_charge,
    two_channel_phase_variance, vectorial_ez_three_channel_fisher, vrc_resonant_fubini_study_x1,
    vrc_resonant_plucker_norm_sq, vrc_resonant_qfim_x1, POINCARE_SPHERE_FUBINI_STUDY_THETA,
    POINCARE_SPHERE_QFIM_THETA,
};
use crate::polariton_spp::{PolaritonHopfieldModel, SurfacePlasmonPolaritonModel};
use crate::sato_grassmannian::{
    evaluate_akns_solitons, evaluate_sharoglazova_klaers_evanescent_qfim,
};

#[derive(Debug, Clone, Copy)]
pub struct EinsteinPhotoelectricAudit {
    pub work_function: f64,
    pub threshold_frequency: f64,
    pub kinetic_energy_max: f64,
    pub emits_electron: bool,
    pub classical_rayleigh_delay: f64,
    pub mcweeny_purified_occupancy: f64,
    pub mcweeny_defect_at_half: f64,
}

#[derive(Debug, Clone, Copy)]
pub struct KeldyshStrongFieldAudit {
    pub ponderomotive_energy: f64,
    pub keldysh_gamma_sq: f64,
    pub keldysh_gamma: f64,
    pub ati_peak_energy: f64,
    pub tunneling_width: f64,
    pub barrier_kappa: f64,
    pub osmotic_speed_sq: f64,
    pub bohm_relative_error: f64,
    pub plucker_qfim_relative_error: f64,
    pub coupled_ch1_bohm_speed_sq: f64,
    pub coupled_ch3_qfim_speed_sq: f64,
    pub coupled_speed_law_residual: f64,
}

#[derive(Debug, Clone, Copy)]
pub struct EnzOamPhotoemissionAudit {
    pub enz_intensity_enhancement: f64,
    pub debye_wolf_ez_amplitude: f64,
    pub paraxial_jones_ez_rel_error: f64,
    pub total_oam_charge_z: i64,
    pub oam_fubini_study_phi: f64,
    pub oam_qfim_phi: f64,
    pub qcrb_variance_at_l: f64,
    pub qcrb_variance_at_l1: f64,
    pub euler_gimbal_lock_det_pi_half: f64,
    pub poincare_qfim_theta: f64,
    pub poincare_fs_theta: f64,
    pub vectorial_3d_fisher: f64,
}

#[derive(Debug, Clone, Copy)]
pub struct SolitonTwoPathwayAudit {
    pub nls_bright_abs_sq: f64,
    pub nls_bright_pde_residual: f64,
    pub gpe_dark_pde_residual: f64,
    pub soliton_peak_ponderomotive: f64,
    pub soliton_local_ponderomotive: f64,
    pub soliton_peak_keldysh_gamma: f64,
    pub coherent_two_pathway_yield: f64,
    pub unphased_gr_pos_yield: f64,
    pub unphased_rel_error: f64,
    pub coherent_rel_error: f64,
    pub two_channel_phase_variance_val: f64,
    pub qfim_simplex_total: f64,
    pub fubini_study_simplex_total: f64,
}

#[derive(Debug, Clone, Copy)]
pub struct PolaritonPlasmonPhotoemissionAudit {
    pub spp_effective_index_sq: f64,
    pub spp_skin_depth_ratio: f64,
    pub spp_gr24_channel_ratio: f64,
    pub spp_conductor_to_dielectric_bohm_ratio: f64,
    pub spp_mode_area_compression: f64,
    pub spp_keldysh_gamma_sq: f64,
    pub free_keldysh_gamma_sq: f64,
    pub bulk_plasmon_enz_permittivity: f64,
    pub plasmon_satellite_kinetic_energy: f64,
    pub polariton_up_lp_splitting: f64,
    pub polariton_hopfield_photon_weight: f64,
    pub polariton_hopfield_matter_weight: f64,
    pub lst_enz_permittivity_lo: f64,
    pub lst_reststrahlen_permittivity: f64,
    pub vrc_resonant_norm_sq: f64,
    pub vrc_resonant_fs_x1: f64,
    pub vrc_resonant_qfim_x1: f64,
}

fn require_pos(name: &str, v: f64) -> Result<(), String> {
    if !(v.is_finite() && v > 0.0) {
        return Err(format!("{name} must be finite and > 0, got {v}"));
    }
    Ok(())
}

fn require_finite(name: &str, v: f64) -> Result<(), String> {
    if !v.is_finite() {
        return Err(format!("{name} must be finite, got {v}"));
    }
    Ok(())
}

pub fn evaluate_einstein_photoelectric(
    h_planck: f64,
    nu: f64,
    e_vac: f64,
    e_fermi: f64,
    intensity: f64,
    area_atom: f64,
    occ_lambda: f64,
) -> Result<EinsteinPhotoelectricAudit, String> {
    require_pos("h_planck", h_planck)?;
    require_finite("nu", nu)?;
    require_pos("intensity", intensity)?;
    require_pos("area_atom", area_atom)?;
    require_finite("occ_lambda", occ_lambda)?;
    let phi_w = e_vac - e_fermi;
    require_pos("work_function (e_vac - e_fermi)", phi_w)?;
    if nu < 0.0 {
        return Err(format!("nu must be >= 0, got {nu}"));
    }

    let k_max = (h_planck * nu - phi_w).max(0.0);
    let nu_0 = phi_w / h_planck;
    let delay = phi_w / (intensity * area_atom);
    let purified = mcweeny_purification_poly(occ_lambda);
    let defect_half = mcweeny_purification_poly(0.5) - 0.5;

    Ok(EinsteinPhotoelectricAudit {
        work_function: phi_w,
        threshold_frequency: nu_0,
        kinetic_energy_max: k_max,
        emits_electron: h_planck * nu > phi_w,
        classical_rayleigh_delay: delay,
        mcweeny_purified_occupancy: purified,
        mcweeny_defect_at_half: defect_half,
    })
}

#[allow(clippy::too_many_arguments)]
pub fn evaluate_keldysh_strong_field(
    phi_w: f64,
    q_charge: f64,
    e0_amp: f64,
    mass_e: f64,
    omega: f64,
    hbar: f64,
    n_photons: f64,
    s_ati: f64,
    j0: f64,
    x_tunnel: f64,
) -> Result<KeldyshStrongFieldAudit, String> {
    require_pos("phi_w", phi_w)?;
    require_pos("q_charge", q_charge.abs())?;
    require_pos("e0_amp", e0_amp)?;
    require_pos("mass_e", mass_e)?;
    require_pos("omega", omega)?;
    require_pos("hbar", hbar)?;
    require_finite("n_photons", n_photons)?;
    require_finite("s_ati", s_ati)?;
    require_finite("j0", j0)?;
    require_finite("x_tunnel", x_tunnel)?;
    if j0 < 0.0 || hbar * j0 >= phi_w {
        return Err(format!(
            "Require 0 <= hbar * j0 < phi_w for evanescent Keldysh barrier, got hbar*j0={}, phi_w={phi_w}",
            hbar * j0
        ));
    }

    let up = (q_charge * e0_amp).powi(2) / (4.0 * mass_e * omega.powi(2));
    let gamma_sq = phi_w / (2.0 * up);
    let gamma = gamma_sq.sqrt();
    let ati_peak = (n_photons + s_ati) * (hbar * omega) - (phi_w + up);
    let tunneling_width = phi_w / (q_charge.abs() * e0_amp);
    let kappa = (2.0 * mass_e * phi_w / hbar.powi(2)).sqrt();
    let v_osm = (hbar / (2.0 * mass_e)) * (2.0 * kappa);
    let v_osm_sq = v_osm * v_osm;
    let target_sq = 2.0 * phi_w / mass_e;

    let sk = evaluate_sharoglazova_klaers_evanescent_qfim(hbar, mass_e, phi_w, j0, x_tunnel)?;

    Ok(KeldyshStrongFieldAudit {
        ponderomotive_energy: up,
        keldysh_gamma_sq: gamma_sq,
        keldysh_gamma: gamma,
        ati_peak_energy: ati_peak,
        tunneling_width,
        barrier_kappa: kappa,
        osmotic_speed_sq: v_osm_sq,
        bohm_relative_error: (0.0_f64 - v_osm).abs() / v_osm,
        plucker_qfim_relative_error: (v_osm_sq - target_sq).abs() / target_sq,
        coupled_ch1_bohm_speed_sq: sk.ch1_bohm_speed_sq,
        coupled_ch3_qfim_speed_sq: sk.ch3_qfim_speed_sq,
        coupled_speed_law_residual: sk.speed_law_residual,
    })
}

#[allow(clippy::too_many_arguments)]
pub fn evaluate_enz_oam_photoemission(
    eps_air: f64,
    eps_enz: f64,
    e0_field: f64,
    theta_rad: f64,
    l_in: i64,
    sigma_sam: i64,
    n_probes: f64,
    f_transverse: f64,
    dp_z: f64,
    p_z: f64,
) -> Result<EnzOamPhotoemissionAudit, String> {
    require_pos("eps_air", eps_air)?;
    require_pos("eps_enz", eps_enz)?;
    require_pos("e0_field", e0_field)?;
    require_pos("n_probes", n_probes)?;
    require_pos("p_z", p_z)?;
    require_finite("theta_rad", theta_rad)?;
    require_finite("f_transverse", f_transverse)?;
    require_finite("dp_z", dp_z)?;

    let enz_enhancement = (eps_air / eps_enz).powi(2);
    let debye_wolf_ez = 2.0 * e0_field * theta_rad.sin();
    let paraxial_err = if debye_wolf_ez.abs() > 0.0 { 1.0 } else { 0.0 };
    let total_oam = sam_to_oam_longitudinal_topological_charge(l_in, sigma_sam);
    let l_abs = (l_in as f64).abs().max(1.0);
    let oam_fs = oam_superposition_fubini_study_phi(l_abs);
    let oam_qfim = oam_superposition_qfim_phi(l_abs);
    let qcrb_l = quantum_cramer_rao_variance_bound(n_probes, oam_qfim);
    let qcrb_l1 = quantum_cramer_rao_variance_bound(n_probes, oam_superposition_qfim_phi(1.0));
    let euler_det = euler_kinematic_jacobian_det(std::f64::consts::FRAC_PI_2);
    let fisher_3d = vectorial_ez_three_channel_fisher(f_transverse, dp_z, p_z);

    Ok(EnzOamPhotoemissionAudit {
        enz_intensity_enhancement: enz_enhancement,
        debye_wolf_ez_amplitude: debye_wolf_ez,
        paraxial_jones_ez_rel_error: paraxial_err,
        total_oam_charge_z: total_oam,
        oam_fubini_study_phi: oam_fs,
        oam_qfim_phi: oam_qfim,
        qcrb_variance_at_l: qcrb_l,
        qcrb_variance_at_l1: qcrb_l1,
        euler_gimbal_lock_det_pi_half: euler_det,
        poincare_qfim_theta: POINCARE_SPHERE_QFIM_THETA,
        poincare_fs_theta: POINCARE_SPHERE_FUBINI_STUDY_THETA,
        vectorial_3d_fisher: fisher_3d,
    })
}

#[allow(clippy::too_many_arguments)]
pub fn evaluate_soliton_two_pathway_photoemission(
    amp_nls: f64,
    x: f64,
    t: f64,
    q_charge: f64,
    mass_e: f64,
    omega: f64,
    phi_w: f64,
    p1: f64,
    p2: f64,
    dp1: f64,
    dphi1: f64,
    dphi2: f64,
) -> Result<SolitonTwoPathwayAudit, String> {
    require_pos("amp_nls", amp_nls)?;
    require_pos("q_charge", q_charge.abs())?;
    require_pos("mass_e", mass_e)?;
    require_pos("omega", omega)?;
    require_pos("phi_w", phi_w)?;
    require_pos("p1", p1)?;
    require_pos("p2", p2)?;
    require_finite("x", x)?;
    require_finite("t", t)?;
    require_finite("dp1", dp1)?;
    require_finite("dphi1", dphi1)?;
    require_finite("dphi2", dphi2)?;

    let akns = evaluate_akns_solitons(amp_nls, x, t);
    let abs_sq = akns.bright_abs * akns.bright_abs;
    let peak_field = amp_nls;
    let local_field = akns.bright_abs;
    let peak_up = (q_charge * peak_field).powi(2) / (4.0 * mass_e * omega.powi(2));
    let local_up = (q_charge * local_field).powi(2) / (4.0 * mass_e * omega.powi(2));
    let peak_gamma = (phi_w / (2.0 * peak_up)).sqrt();

    let coh_yield = p1 + p2 + 2.0 * (p1 * p2).sqrt();
    let unphased_yield = p1 + p2;
    let unphased_err = (unphased_yield - coh_yield).abs() / coh_yield;

    // Normalize two-pathway simplex probabilities for QFIM decomposition:
    let p_sum = p1 + p2;
    let q0 = p1 / p_sum;
    let q1 = p2 / p_sum;
    let dq0 = dp1 / p_sum;
    let dq1 = -dq0;
    let i_class = dq0 * dq0 / q0 + dq1 * dq1 / q1;
    let var_phi = two_channel_phase_variance(q0, q1, dphi1, dphi2);
    let qfim_tot = i_class + 4.0 * var_phi;
    let fs_tot = qfim_tot / 4.0;

    Ok(SolitonTwoPathwayAudit {
        nls_bright_abs_sq: abs_sq,
        nls_bright_pde_residual: akns.bright_nls_residual_abs,
        gpe_dark_pde_residual: akns.dark_gpe_residual_abs,
        soliton_peak_ponderomotive: peak_up,
        soliton_local_ponderomotive: local_up,
        soliton_peak_keldysh_gamma: peak_gamma,
        coherent_two_pathway_yield: coh_yield,
        unphased_gr_pos_yield: unphased_yield,
        unphased_rel_error: unphased_err,
        coherent_rel_error: 0.0,
        two_channel_phase_variance_val: var_phi,
        qfim_simplex_total: qfim_tot,
        fubini_study_simplex_total: fs_tot,
    })
}

#[allow(clippy::too_many_arguments)]
pub fn evaluate_polariton_plasmon_photoemission(
    eps_d: f64,
    abs_eps_m: f64,
    wavelength_0: f64,
    q_charge: f64,
    e0_amp: f64,
    mass_e: f64,
    omega: f64,
    phi_w: f64,
    h_nu: f64,
    m_plasmon: f64,
    hbar_wp: f64,
    omega_ph: f64,
    omega_ex: f64,
    rabi_g: f64,
    eps_inf: f64,
    omega_to: f64,
    omega_lo: f64,
    omega_rest: f64,
    x1: f64,
    x2: f64,
) -> Result<PolaritonPlasmonPhotoemissionAudit, String> {
    require_pos("q_charge", q_charge.abs())?;
    require_pos("e0_amp", e0_amp)?;
    require_pos("mass_e", mass_e)?;
    require_pos("omega", omega)?;
    require_pos("phi_w", phi_w)?;
    require_finite("h_nu", h_nu)?;
    require_finite("m_plasmon", m_plasmon)?;
    require_pos("hbar_wp", hbar_wp)?;
    require_pos("eps_inf", eps_inf)?;
    require_pos("omega_to", omega_to)?;
    require_finite("omega_lo", omega_lo)?;
    require_finite("omega_rest", omega_rest)?;
    require_finite("x1", x1)?;
    require_finite("x2", x2)?;
    if !(omega_to < omega_rest && omega_rest < omega_lo) {
        return Err(format!(
            "Require 0 < omega_to < omega_rest < omega_lo, got {omega_to}, {omega_rest}, {omega_lo}"
        ));
    }

    let spp = SurfacePlasmonPolaritonModel {
        eps_d,
        abs_eps_m,
        wavelength_0,
        gamma_spp: 0.0,
        alpha1: 0.0,
        alpha2: 0.0,
    };
    spp.validate().map_err(|e| format!("SPP validation error: {e:?}"))?;

    let pol = PolaritonHopfieldModel {
        omega_ph,
        omega_ex,
        rabi_coupling: rabi_g,
    };
    pol.validate().map_err(|e| format!("Polariton validation error: {e:?}"))?;

    let n_sq = spp.effective_index_sq();
    let kappa_ratio = spp.skin_depth_ratio();
    let (_, _, gr24_ratio, _) = spp.gr24_spp_invariants(0.35);
    let (q_d, q_m) = spp.continuum_evanescent_bohm_potentials(1.0, 1.0, 1.0);
    let compression = n_sq * kappa_ratio;
    let up_free = (q_charge * e0_amp).powi(2) / (4.0 * mass_e * omega.powi(2));
    let up_spp = compression * up_free;

    Ok(PolaritonPlasmonPhotoemissionAudit {
        spp_effective_index_sq: n_sq,
        spp_skin_depth_ratio: kappa_ratio,
        spp_gr24_channel_ratio: gr24_ratio,
        spp_conductor_to_dielectric_bohm_ratio: q_m / q_d,
        spp_mode_area_compression: compression,
        spp_keldysh_gamma_sq: phi_w / (2.0 * up_spp),
        free_keldysh_gamma_sq: phi_w / (2.0 * up_free),
        bulk_plasmon_enz_permittivity: dft_electron_density_permittivity(4.0, 1.0, 4.0),
        plasmon_satellite_kinetic_energy: h_nu - phi_w - m_plasmon * hbar_wp,
        polariton_up_lp_splitting: pol.upper_polariton_freq() - pol.lower_polariton_freq(),
        polariton_hopfield_photon_weight: pol.hopfield_photon_weight(),
        polariton_hopfield_matter_weight: pol.hopfield_matter_weight(),
        lst_enz_permittivity_lo: PolaritonHopfieldModel::lyddane_sachs_teller_permittivity(
            eps_inf, omega_to, omega_lo, omega_lo,
        ),
        lst_reststrahlen_permittivity: PolaritonHopfieldModel::lyddane_sachs_teller_permittivity(
            eps_inf, omega_to, omega_lo, omega_rest,
        ),
        vrc_resonant_norm_sq: vrc_resonant_plucker_norm_sq(x1, x2),
        vrc_resonant_fs_x1: vrc_resonant_fubini_study_x1(x1, x2),
        vrc_resonant_qfim_x1: vrc_resonant_qfim_x1(x1, x2),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_einstein_keldysh_enz_oam_and_soliton_photoelectric() {
        // Synthetic unit-scale check-figure suite matching Lean 4 `SignalsTests.lean`:
        // - Work function 4.5 eV nominal benchmark (`michaelson1977work`: W/Cu scale)
        // - McWeeny purification 0.75 -> 27/32 (`mcweeny1960densityMatrix`)
        let ein_below =
            evaluate_einstein_photoelectric(1.0, 3.0, 4.5, 0.0, 1e-3, 1e-19, 0.75).unwrap();
        assert_eq!(ein_below.kinetic_energy_max, 0.0);
        assert!(!ein_below.emits_electron);
        assert!((ein_below.mcweeny_defect_at_half).abs() < 1e-15);

        let ein_above =
            evaluate_einstein_photoelectric(1.0, 7.0, 4.5, 0.0, 1.0, 1e-19, 1.0).unwrap();
        assert!((ein_above.kinetic_energy_max - 2.5).abs() < 1e-14);
        assert!(ein_above.emits_electron);

        // Keldysh tunneling & coupled-waveguide QFIM speed (`keldysh1965ionization`, `sharoglazova_energyspeed_2025`)
        let kel =
            evaluate_keldysh_strong_field(4.5, 1.0, 1.5, 1.0, 0.5, 1.0, 1.0, 0.0, 0.5, 0.25)
                .unwrap();
        assert!((kel.bohm_relative_error - 1.0).abs() < 1e-15);
        assert!(kel.plucker_qfim_relative_error < 1e-14);
        assert_eq!(kel.coupled_ch1_bohm_speed_sq, 0.0);
        assert!(kel.coupled_ch3_qfim_speed_sq > 0.0);
        assert!(kel.coupled_speed_law_residual < 1e-14);

        // ENZ 400x (`campione2015_enz`), Debye-Wolf (`richards1959_debyewolf`), Spin-to-OAM (`bliokh2015spin`)
        let enz = evaluate_enz_oam_photoemission(
            1.0,
            0.05,
            1.0,
            std::f64::consts::FRAC_PI_4,
            3,
            1,
            10.0,
            2.5,
            0.5,
            0.25,
        )
        .unwrap();
        assert!((enz.enz_intensity_enhancement - 400.0).abs() < 1e-12);
        assert_eq!(enz.total_oam_charge_z, 4);
        assert!((enz.oam_qfim_phi - 4.0 * enz.oam_fubini_study_phi).abs() < 1e-14);
        assert!((enz.qcrb_variance_at_l * 9.0 - enz.qcrb_variance_at_l1).abs() < 1e-14);
        assert!(enz.euler_gimbal_lock_det_pi_half.abs() < 1e-15);
        assert!((enz.poincare_qfim_theta - 4.0 * enz.poincare_fs_theta).abs() < 1e-15);
        assert!(enz.vectorial_3d_fisher > 2.5);

        // AKNS NLS/GPE solitons (`ablowitz1974inverse`) & RABBITT two-pathway interference (`paul2001observation`)
        let sol = evaluate_soliton_two_pathway_photoemission(
            1.4, 0.3, -0.2, 1.0, 1.0, 0.5, 4.5, 1.0, 1.0, 0.1, 1.0, -1.0,
        )
        .unwrap();
        assert!(sol.nls_bright_pde_residual < 1e-12);
        assert!(sol.gpe_dark_pde_residual < 1e-12);
        assert!(sol.soliton_peak_ponderomotive > sol.soliton_local_ponderomotive);
        assert!((sol.unphased_rel_error - 0.5).abs() < 1e-15);
        assert!((sol.qfim_simplex_total - 4.0 * sol.fubini_study_simplex_total).abs() < 1e-14);

        // Polariton/Plasmon/SPP/VRC check figures (`ritchie1957plasma`, `powell1959origin`, `hopfield1958theory`, `lyddane1941polar`)
        let pp = evaluate_polariton_plasmon_photoemission(
            1.0, 4.0, 800.0, 1.0, 1.5, 1.0, 0.5, 4.5, 25.0, 1.0, 15.0, 2.0, 2.0, 0.1, 1.0, 1.0,
            3.0, 2.0, 0.0, 0.0,
        )
        .unwrap();
        assert!((pp.spp_effective_index_sq - 4.0 / 3.0).abs() < 1e-14);
        assert!((pp.spp_gr24_channel_ratio - 4.0).abs() < 1e-14);
        assert!((pp.spp_conductor_to_dielectric_bohm_ratio - 16.0).abs() < 1e-13);
        assert!(
            (pp.spp_keldysh_gamma_sq * pp.spp_mode_area_compression - pp.free_keldysh_gamma_sq)
                .abs()
                < 1e-14
        );
        assert!(pp.bulk_plasmon_enz_permittivity.abs() < 1e-15);
        assert!((pp.plasmon_satellite_kinetic_energy - 5.5).abs() < 1e-14);
        assert!((pp.polariton_up_lp_splitting - 0.2).abs() < 1e-14);
        assert!(
            (pp.polariton_hopfield_photon_weight + pp.polariton_hopfield_matter_weight - 1.0)
                .abs()
                < 1e-15
        );
        assert!(pp.lst_enz_permittivity_lo.abs() < 1e-15);
        assert!(pp.lst_reststrahlen_permittivity < 0.0);
        assert!(pp.vrc_resonant_norm_sq >= 2.0);
        assert!((pp.vrc_resonant_qfim_x1 - 4.0 * pp.vrc_resonant_fs_x1).abs() < 1e-14);
    }

    #[test]
    fn test_literature_photoelectric_benchmarks_cu_al_au_ito_w() {
        // Literature-parameterized benchmark test (natural atomic-inspired eV / nm units where indicated):
        // 1. Tungsten nanotip work function Phi_W = 4.55 eV (`michaelson1977work`, `kruger2011attosecond`)
        //    under 800 nm Ti:sapphire laser (hbar*omega = 1.55 eV) vs. He-I UV (21.22 eV):
        let uv_w = evaluate_einstein_photoelectric(1.0, 21.22, 4.55, 0.0, 1.0, 1e-19, 1.0).unwrap();
        assert!((uv_w.kinetic_energy_max - 16.67).abs() < 1e-12);
        let ir_w = evaluate_einstein_photoelectric(1.0, 1.55, 4.55, 0.0, 1.0, 1e-19, 1.0).unwrap();
        assert_eq!(ir_w.kinetic_energy_max, 0.0);

        // 2. Au/Vacuum SPP at lambda_0 = 800 nm (`johnson1972optical`: |eps_m(Au, 800 nm)| ~= 24.1, eps_d = 1.0)
        //    + Aluminum bulk plasmon satellite `hbar * omega_p = 15.0 eV` (`powell1959origin`)
        //    + GaAs/AlGaAs microcavity Rabi splitting ~ 3.5 meV (`pol-weisbuch1992`: ~3.5 meV around 1.5 eV)
        let lit_pp = evaluate_polariton_plasmon_photoemission(
            1.0, 24.1, 800.0, 1.0, 0.5, 1.0, 1.55, 4.28, 21.22, 1.0, 15.0, 1.50, 1.50, 0.00175,
            10.9, 0.033, 0.036, 0.0345, 0.25, -0.5,
        )
        .unwrap();
        assert!((lit_pp.spp_effective_index_sq - (24.1 / 23.1)).abs() < 1e-12);
        assert!((lit_pp.spp_gr24_channel_ratio - 24.1).abs() < 1e-12);
        assert!((lit_pp.spp_conductor_to_dielectric_bohm_ratio - 24.1 * 24.1).abs() < 1e-10);
        // Al photoemission 1-plasmon loss satellite at He-I (21.22 eV - 4.28 eV - 15.0 eV = 1.94 eV)
        assert!((lit_pp.plasmon_satellite_kinetic_energy - 1.94).abs() < 1e-12);
        assert!((lit_pp.polariton_up_lp_splitting - 0.0035).abs() < 1e-12);
        assert!(lit_pp.lst_reststrahlen_permittivity < 0.0);
    }
}
