//! Multi-model quantum trajectory evaluators, experimental check figures, and relative
//! predictive error comparisons across Open-System Quantum Trajectory Theory (`QTT`/`MCWF`),
//! Superconducting Qubit Homodyne/Heterodyne Diffusion (Murch et al. 2013; Roch et al. 2014;
//! Campagne-Ibarcq et al. 2016; Santos et al. 2012), Evanescent Coupled-Waveguide Energy–Speed
//! Measurements (Sharoglazova et al., *Nature* 2025; Klaers et al. 2023, 2025/2026), Relativistic
//! Weak-Value Photon Trajectories (Foo et al. 2022–2025), Temporal Double-Slit Diffraction at
//! Optical Frequencies (Tirole et al., *Nat. Phys.* 2023; 2024), and Strongly Interacting
//! Rydberg Photon Vortices in Nonlinear Optics (Drori et al., *Science* 2023/2024).
//!
//! Mirrors the machine-checked declarations and theorems in
//! `src/signals/Signals/QuantumTrajectories.lean`.

/// Relative predictive error `|predicted - reference| / |reference|`.
#[must_use]
pub fn relative_predictive_error(predicted: f64, reference: f64) -> f64 {
    (predicted - reference).abs() / reference.abs()
}

// ============================================================================
// Section 1: Open-System Quantum Trajectory Theory (QTT / MCWF) & Superconducting Qubits
// ============================================================================

/// Lindblad master equation density-matrix component count `N^2`.
#[must_use]
pub const fn lindblad_density_matrix_dim(n_hilbert: usize) -> usize {
    n_hilbert * n_hilbert
}

/// Quantum Trajectory Theory / MCWF statevector component count `N`.
#[must_use]
pub const fn mcwf_trajectory_vector_dim(n_hilbert: usize) -> usize {
    n_hilbert
}

/// Binomial coefficient `C(n, k)`.
#[must_use]
pub fn binomial_choose(n: usize, k: usize) -> usize {
    if k > n {
        return 0;
    }
    let k_eff = k.min(n - k);
    let mut acc = 1usize;
    for i in 0..k_eff {
        acc = acc * (n - i) / (i + 1);
    }
    acc
}

/// Grassmannian Plücker trajectory compression ratio `(2^n)^2 / C(n, k)` over full Lindblad density matrices.
#[must_use]
pub fn plucker_lindblad_compression_ratio(n: usize, k: usize) -> f64 {
    let lindblad_dim = (1usize << n).pow(2) as f64;
    let plucker_dim = binomial_choose(n, k) as f64;
    lindblad_dim / plucker_dim
}

/// Murch et al. (2013/2014) dispersive homodyne meridian drift along Bloch `z`:
/// `mu_z = g_meas * (1 - z^2) * sin(phi_lo)`.
#[must_use]
pub fn homodyne_meridian_drift_z(g_meas: f64, z: f64, phi_lo: f64) -> f64 {
    g_meas * (1.0 - z * z) * phi_lo.sin()
}

/// Murch et al. (2013/2014) dispersive homodyne azimuthal phase kick along Bloch equator:
/// `omega_phi = g_meas * cos(phi_lo)`.
#[must_use]
pub fn homodyne_equator_phase_kick_phi(g_meas: f64, phi_lo: f64) -> f64 {
    g_meas * phi_lo.cos()
}

/// Murch et al. (2013/2014) conditional Bloch purity evolution rate:
/// `2 * gamma_m * (1 - z^2) * (eta * (1 - z^2) - (1 - eta))`.
#[must_use]
pub fn homodyne_bloch_purity_rate(gamma_m: f64, eta: f64, z: f64) -> f64 {
    let one_minus_z2 = 1.0 - z * z;
    2.0 * gamma_m * one_minus_z2 * (eta * one_minus_z2 - (1.0 - eta))
}

/// Roch et al. (2014) cascaded two-qubit cavity dispersive phase shift `chi * (s1 + s2)`.
#[must_use]
pub fn cascaded_cavity_parity_phase_shift(chi: f64, s1: f64, s2: f64) -> f64 {
    chi * (s1 + s2)
}

/// Roch et al. (2014) remote two-qubit trajectory Wootters concurrence squared `4 * |p_23|^2`.
#[must_use]
pub fn remote_trajectory_concurrence_sq(p23_norm_sq: f64) -> f64 {
    4.0 * p23_norm_sq
}

/// Campagne-Ibarcq et al. (2016) heterodyne fluorescence deterministic transverse coherence squared
/// `x^2 + y^2 = 4 * eta * p_e * p_g_eff`.
#[must_use]
pub fn heterodyne_deterministic_coherence_sq(eta: f64, p_e: f64, p_g_eff: f64) -> f64 {
    4.0 * eta * p_e * p_g_eff
}

/// Campagne-Ibarcq et al. (2016) heterodyne fluorescence deterministic Bloch surface radius squared
/// `x^2 + y^2 + z^2 = 4 * eta * p_e * p_g_eff + (2 * p_e - 1)^2`.
#[must_use]
pub fn heterodyne_deterministic_purity(eta: f64, p_e: f64, p_g_eff: f64) -> f64 {
    heterodyne_deterministic_coherence_sq(eta, p_e, p_g_eff) + (2.0 * p_e - 1.0).powi(2)
}

/// Campagne-Ibarcq et al. (2016) heterodyne fluorescence excitation probability increment
/// `dp_e = -gamma1 * p_e * dt + i_stoch`.
#[must_use]
pub fn heterodyne_excitation_increment(gamma1: f64, p_e: f64, dt: f64, i_stoch: f64) -> f64 {
    -gamma1 * p_e * dt + i_stoch
}

/// Santos et al. (2012) quantum-jump heralded gate fidelity `1 - (1 - eta_herald) * gamma_dec`.
#[must_use]
pub fn quantum_jump_heralded_gate_fidelity(gamma_dec: f64, eta_herald: f64) -> f64 {
    1.0 - (1.0 - eta_herald) * gamma_dec
}

// ============================================================================
// Section 2: Sharoglazova et al. (2025) & Klaers et al. (2023, 2025/2026) Evanescent Energy–Speed Law
// ============================================================================

/// Standard de Broglie–Bohm phase-gradient velocity in a stationary evanescent barrier state (`0.0`).
pub const STANDARD_BOHM_EVANESCENT_VELOCITY: f64 = 0.0;

/// Three-channel Plücker–Madelung–QFIM local squared speed `v_phase^2 + v_osm^2 + v_fs^2`.
#[must_use]
pub fn plucker_three_channel_speed_sq(v_phase: f64, v_osm: f64, v_fs: f64) -> f64 {
    v_phase * v_phase + v_osm * v_osm + v_fs * v_fs
}

/// Channel 2 evanescent osmotic / density-gradient speed `(hbar / (2 * mass)) * (2 * kappa) = hbar * kappa / mass`.
#[must_use]
pub fn evanescent_osmotic_speed(hbar: f64, mass: f64, kappa: f64) -> f64 {
    (hbar / (2.0 * mass)) * (2.0 * kappa)
}

/// Mirror-symmetric energy–speed squared `2 * |delta_energy| / mass`.
#[must_use]
pub fn mirror_symmetric_energy_speed_sq(mass: f64, delta_energy: f64) -> f64 {
    2.0 * delta_energy.abs() / mass
}

/// Channel 3 coupled-waveguide clock speed squared `j0^2 / g_fs_xx` from projective Fubini–Study metric.
#[must_use]
pub fn coupled_waveguide_clock_speed_sq_from_fubini_study(j0: f64, g_fs_xx: f64) -> f64 {
    (j0 * j0) / g_fs_xx
}

/// Channel 3 coupled-waveguide clock speed squared `4 * j0^2 / f_qfim_xx` from projective QFIM.
#[must_use]
pub fn coupled_waveguide_clock_speed_sq_from_qfim(j0: f64, f_qfim_xx: f64) -> f64 {
    (4.0 * j0 * j0) / f_qfim_xx
}

/// Klaers–Sharoglazova exact finite-coupling waveguide speed squared (Eq. 20 of `arXiv:2509.06584`).
/// Both branches have dimensions of `Energy / Mass = Speed^2`, match continuously at
/// `|delta_energy| = hbar * j0`, and reduce at `j0 = 0` to `2 * |delta_energy| / mass`.
#[must_use]
pub fn klaers_coupled_waveguide_speed_sq(
    hbar: f64,
    mass: f64,
    j0: f64,
    delta_energy: f64,
) -> f64 {
    let hj = hbar * j0;
    if delta_energy.abs() <= hj {
        hj / mass
    } else {
        (delta_energy.abs() + (delta_energy * delta_energy - hj * hj).sqrt()) / mass
    }
}

/// Klaers–Sharoglazova leading quadratic measurement back-action factor `1 - (1/8) * (hbar * j0 / delta)^2`.
#[must_use]
pub fn klaers_backaction_quadratic_factor(hbar: f64, j0: f64, delta_energy: f64) -> f64 {
    1.0 - 0.125 * ((hbar * j0) / delta_energy).powi(2)
}

/// Dual-Grassmannian / Bidirectional Bohmian evanescent barrier entry probability `2 k kappa / (k^2 + kappa^2)`.
#[must_use]
pub fn evanescent_entry_probability(k: f64, kappa: f64) -> f64 {
    (2.0 * k * kappa) / (k * k + kappa * kappa)
}

/// Conditional-to-unconditional dwell-time correction factor `F = (k^2 + kappa^2) / (2 k kappa)`.
#[must_use]
pub fn dwell_time_correction_factor(k: f64, kappa: f64) -> f64 {
    (k * k + kappa * kappa) / (2.0 * k * kappa)
}

/// Conditional evanescent residence time `mass / (hbar * kappa^2)`.
#[must_use]
pub fn conditional_residence_time(hbar: f64, mass: f64, kappa: f64) -> f64 {
    mass / (hbar * kappa * kappa)
}

/// Unconditional quantum dwell time `2 * mass * k / (hbar * kappa * (k^2 + kappa^2))`.
#[must_use]
pub fn unconditional_quantum_dwell_time(hbar: f64, mass: f64, k: f64, kappa: f64) -> f64 {
    (2.0 * mass * k) / (hbar * kappa * (k * k + kappa * kappa))
}

/// Complex gain/loss potential fourth-power speed-up ratio `1 + (v0_imag / energy)^2`.
#[must_use]
pub fn complex_potential_fourth_power_speed_ratio(energy: f64, v0_imag: f64) -> f64 {
    1.0 + (v0_imag / energy).powi(2)
}

// ============================================================================
// Section 3: Foo et al. (2022–2025) Relativistic Weak-Value Photon Trajectories
// ============================================================================

/// Operational relativistic weak-value velocity `j_kg / rho_kg`.
#[must_use]
pub fn relativistic_weak_value_velocity(j_kg: f64, rho_kg: f64) -> f64 {
    j_kg / rho_kg
}

/// Lorentz-boosted Klein–Gordon current `gamma * (j_kg - v_boost * rho_kg)`.
#[must_use]
pub fn lorentz_boosted_current(gamma: f64, v_boost: f64, j_kg: f64, rho_kg: f64) -> f64 {
    gamma * (j_kg - v_boost * rho_kg)
}

/// Lorentz-boosted Klein–Gordon density `gamma * (rho_kg - v_boost * j_kg)`.
#[must_use]
pub fn lorentz_boosted_density(gamma: f64, v_boost: f64, j_kg: f64, rho_kg: f64) -> f64 {
    gamma * (rho_kg - v_boost * j_kg)
}

/// Einstein relativistic velocity addition rule `(v_vel - v_boost) / (1 - v_boost * v_vel)`.
#[must_use]
pub fn relativistic_velocity_addition(v_vel: f64, v_boost: f64) -> f64 {
    (v_vel - v_boost) / (1.0 - v_boost * v_vel)
}

/// Foo et al. (2022) equal-frequency center-of-momentum boost velocity `(k0_r - k0_l) / (k0_r + k0_l)`.
#[must_use]
pub fn equal_frequency_boost_velocity(k0_r: f64, k0_l: f64) -> f64 {
    (k0_r - k0_l) / (k0_r + k0_l)
}

/// Foo, Bellamy, & Ralph (2025) Schwarzschild–Alcubierre null geodesic coordinate velocity `f_r * (v_s + sigma_dir)`.
#[must_use]
pub fn schwarzschild_alcubierre_coord_velocity(f_r: f64, v_s: f64, sigma_dir: f64) -> f64 {
    f_r * (v_s + sigma_dir)
}

/// Foo, Lund, & Ralph (2024) two-photon energy-normalized Klein–Gordon density `(rho1 + rho2) / (2 * (k0_r + k0_l))`.
#[must_use]
pub fn two_photon_energy_normalized_density(rho1: f64, rho2: f64, k0_r: f64, k0_l: f64) -> f64 {
    (rho1 + rho2) / (2.0 * (k0_r + k0_l))
}

// ============================================================================
// Section 4: Tirole et al. (2023–2024) Double-Slit Time Diffraction at Optical Frequencies
// ============================================================================

/// Temporal double-slit spectral fringe period `1 / s_delay`.
#[must_use]
pub fn time_double_slit_fringe_period(s_delay: f64) -> f64 {
    1.0 / s_delay
}

/// Temporal slit rise-time spectral bandwidth envelope `1 / (1 + (delta_omega * tau_rise)^2)`.
#[must_use]
pub fn time_slit_bandwidth_envelope(delta_omega: f64, tau_rise: f64) -> f64 {
    1.0 / (1.0 + (delta_omega * tau_rise).powi(2))
}

/// Time-varying second-harmonic susceptibility modulation `2 * delta_chi1_rel`.
#[must_use]
pub fn time_varying_shg_modulation(delta_chi1_rel: f64) -> f64 {
    2.0 * delta_chi1_rel
}

// ============================================================================
// Section 5: Drori et al. (2023/2024) Quantum Vortices of Strongly Interacting Photons
// ============================================================================

/// Cubic Kerr / Gross–Pitaevskii nonlinear superposition breakdown residual `g (psi1 + psi2)^3 - g psi1^3 - g psi2^3`.
#[must_use]
pub fn nonlinear_kerr_superposition_residual(g_kerr: f64, psi1: f64, psi2: f64) -> f64 {
    g_kerr * (psi1 + psi2).powi(3) - g_kerr * psi1.powi(3) - g_kerr * psi2.powi(3)
}

/// Quadratic `chi^(2)` second-harmonic superposition breakdown residual `chi2 (psi1 + psi2)^2 - chi2 psi1^2 - chi2 psi2^2`.
#[must_use]
pub fn chi2_second_harmonic_superposition_residual(chi2: f64, psi1: f64, psi2: f64) -> f64 {
    chi2 * (psi1 + psi2).powi(2) - chi2 * psi1.powi(2) - chi2 * psi2.powi(2)
}

/// Pairwise quantum-Kerr `n`-photon conditional phase `(n * (n - 1) / 2) * phi2`.
#[must_use]
pub fn pairwise_kerr_multi_photon_phase(n_photons: f64, phi2: f64) -> f64 {
    (n_photons * (n_photons - 1.0) / 2.0) * phi2
}

/// Grassmannian `Gr_C(n, 2n)` blockade-saturated `n`-photon conditional phase `(n - 1) * phi2`.
#[must_use]
pub fn saturated_blockade_multi_photon_phase(n_photons: f64, phi2: f64) -> f64 {
    (n_photons - 1.0) * phi2
}

/// Pairwise McGuire (1964) 1D three-photon bound-state energy `4 * e2`.
#[must_use]
pub fn pairwise_mcguire_three_body_energy(e2: f64) -> f64 {
    4.0 * e2
}

/// Grassmannian `Gr_C(3,6)` blockade-saturated three-photon bound-state energy `3 * e2`.
#[must_use]
pub fn saturated_blockade_three_body_energy(e2: f64) -> f64 {
    3.0 * e2
}

/// Disconnected pairwise three-photon correlation `g12 + g13 + g23 - 2`.
#[must_use]
pub fn disconnected_three_photon_correlation(g12: f64, g13: f64, g23: f64) -> f64 {
    g12 + g13 + g23 - 2.0
}

/// Connected genuine three-body photon correlation `g3 - (g12 + g13 + g23 - 2)`.
#[must_use]
pub fn connected_three_photon_correlation(g3: f64, g12: f64, g13: f64, g23: f64) -> f64 {
    g3 - disconnected_three_photon_correlation(g12, g13, g23)
}

// ============================================================================
// Section 6: Adversarial Critique & Gap-Closure Functions
// ============================================================================

/// Critique Fix QT-1: Lindblad unraveling master-equation gauge residual under local-oscillator shift.
#[must_use]
pub fn unraveling_master_equation_gauge_residual(
    l_i: f64,
    l_j: f64,
    alpha_lo: f64,
    rho_ij: f64,
) -> f64 {
    let shifted = (l_i + alpha_lo) * rho_ij * (l_j + alpha_lo)
        - 0.5 * ((l_i + alpha_lo).powi(2) + (l_j + alpha_lo).powi(2)) * rho_ij;
    let unshifted = l_i * rho_ij * l_j - 0.5 * (l_i.powi(2) + l_j.powi(2)) * rho_ij;
    shifted - unshifted
}

/// Critique Fix QT-2: Bidirectional Dual-Grassmannian evanescent net current `j_forward + (-j_forward)`.
#[must_use]
pub fn bidirectional_evanescent_net_current(j_forward: f64) -> f64 {
    j_forward + (-j_forward)
}

/// Critique Fix QT-2: Bidirectional stationary density match residual.
#[must_use]
pub fn bidirectional_density_match_residual(
    t_sq: f64,
    v: f64,
    j_in: f64,
    exp_decay: f64,
) -> f64 {
    2.0 * (((t_sq * v / (2.0 * j_in)) * j_in) / v) * exp_decay - t_sq * exp_decay
}

/// Critique Fix QT-3: Plücker `Q_4` Kähler-regularized weak-value velocity.
#[must_use]
pub fn kahler_regularized_weak_velocity(j_num: f64, w_hs_sq: f64, det_w: f64) -> f64 {
    j_num / (1.0 + w_hs_sq + det_w * det_w)
}

/// Critique Fix QT-4: Drori et al. (2023/2024) two-photon vortex-core correlation floor `0.24 = 6/25`.
pub const DRORI_VORTEX_CORE_CORRELATION_FLOOR: f64 = 6.0 / 25.0;

/// Critique Fix QT-5: Explicit two-mode evanescent waveguide `PluckerDirectionalJet` at `x = 0`.
#[must_use]
pub fn evanescent_waveguide_directional_jet(
    rho0: f64,
    kappa: f64,
    k1: f64,
) -> crate::dft_plabic_vrc::PluckerDirectionalJet {
    crate::dft_plabic_vrc::PluckerDirectionalJet {
        rho: rho0,
        dpsi_norm_sq: rho0 * (kappa * kappa + k1 * k1),
        drho: -2.0 * kappa * rho0,
        a_mu: 0.0,
    }
}

/// Critique Fix QT-6: Propagating coupled-waveguide quartic auxiliary population response `x_tilde^2 - (1/3) x_tilde^4`.
#[must_use]
pub fn waveguide_prop_pop_quartic(x_tilde: f64) -> f64 {
    x_tilde.powi(2) - (1.0 / 3.0) * x_tilde.powi(4)
}

/// Critique Fix QT-6: Evanescent coupled-waveguide quartic auxiliary population response `x_tilde^2 - (5/3) x_tilde^4`.
#[must_use]
pub fn waveguide_ev_pop_quartic(x_tilde: f64) -> f64 {
    x_tilde.powi(2) - (5.0 / 3.0) * x_tilde.powi(4)
}

/// Critique Fix QT-7: Drori et al. (2023/2024) Rydberg polariton dispersive enhancement factor `q_0`.
#[must_use]
pub fn rydberg_polariton_te_enhancement(
    omega_rabi: f64,
    delta_two_photon: f64,
    delta_probe: f64,
) -> f64 {
    omega_rabi.powi(2) / (omega_rabi.powi(2) - delta_two_photon * delta_probe)
}

/// Critique Fix QT-7: Drori et al. (2023/2024) dimensionless Rydberg polariton interaction strength `lambda`.
#[must_use]
pub fn rydberg_polariton_interaction_lambda(
    q0: f64,
    gamma_e: f64,
    delta_probe: f64,
    odb: f64,
) -> f64 {
    (q0 * gamma_e * odb / (2.0 * delta_probe)).powi(2)
}

/// Section 9: Kähler-regularized off-shell Bohmian throat cushion on `Q_4 = Gr_C(2,4)`,
/// `im_action_sq / (1 + w_hs_sq + det_w^2)^2`, eliminating the `1 / rho_0^2 -> inf` nodal blowup.
#[must_use]
pub fn kahler_regularized_bohm_cushion(im_action_sq: f64, w_hs_sq: f64, det_w: f64) -> f64 {
    im_action_sq / (1.0 + w_hs_sq + det_w.powi(2)).powi(2)
}

/// Section 9: Six-channel Dual-Schubert Plücker-QFIM + GJW wormhole stabilization cushion
/// `B_Bohm_QFIM = B_osm_reg + (hbar^2 / (8 m)) * (rho_+ F_+ + rho_- F_-) + 2 |lambda_GJW| sqrt(rho_+ rho_-) C_EPR`.
#[must_use]
#[allow(clippy::too_many_arguments)]
pub fn dual_schubert_qfim_wormhole_cushion(
    b_osm_reg: f64,
    hbar: f64,
    mass: f64,
    rho_plus: f64,
    f_qfim_plus: f64,
    rho_minus: f64,
    f_qfim_minus: f64,
    lambda_gjw: f64,
    c_epr: f64,
) -> f64 {
    b_osm_reg
        + (hbar.powi(2) / (8.0 * mass)) * (rho_plus * f_qfim_plus + rho_minus * f_qfim_minus)
        + 2.0 * lambda_gjw * (rho_plus * rho_minus).sqrt() * c_epr
}

/// Section 9: Evanescent wormhole throat steady-state residence energy load `p_in * (l_throat / v_eff)`.
#[must_use]
pub fn evanescent_throat_stored_energy(p_in: f64, l_throat: f64, v_eff: f64) -> f64 {
    p_in * (l_throat / v_eff)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::dft_plabic_vrc::{
        fubini_study_diag, gpe_kinetic_dir, hydro_flow_dir, projective_qfim_energy_from_ray_metric,
        qfim_diag, scalar_bohm_density_dir,
    };
    use rstest::rstest;
    use std::f64::consts::{FRAC_PI_2, PI};

    #[test]
    fn test_qtt_superconducting_qubit_trajectories() {
        assert_eq!(
            lindblad_density_matrix_dim(16),
            16 * mcwf_trajectory_vector_dim(16)
        );
        assert!((plucker_lindblad_compression_ratio(4, 2) - 128.0 / 3.0).abs() < 1e-12);
        assert!(homodyne_meridian_drift_z(2.5, 0.3, 0.0).abs() < 1e-15);
        assert!(homodyne_equator_phase_kick_phi(2.5, FRAC_PI_2).abs() < 1e-15);
        assert!(cascaded_cavity_parity_phase_shift(0.675, 1.0, -1.0).abs() < 1e-15);
        assert!(cascaded_cavity_parity_phase_shift(0.675, -1.0, 1.0).abs() < 1e-15);
        assert!((remote_trajectory_concurrence_sq(0.25) - 1.0).abs() < 1e-15);
        assert!(
            (relative_predictive_error(remote_trajectory_concurrence_sq(0.0), 1.0) - 1.0).abs()
                < 1e-15
        );
        assert!((heterodyne_deterministic_purity(1.0, 0.37, 1.0 - 0.37) - 1.0).abs() < 1e-15);
        assert!(heterodyne_excitation_increment(1.0, 0.5, 1.0, 1.0) > 0.0);
        assert!((quantum_jump_heralded_gate_fidelity(0.15, 1.0) - 1.0).abs() < 1e-15);
    }

    #[test]
    fn test_sharoglazova_klaers_evanescent_energy_speed() {
        let v_osm = evanescent_osmotic_speed(1.0, 2.0, 4.0);
        assert!((v_osm - 2.0).abs() < 1e-15);
        assert!(
            (relative_predictive_error(STANDARD_BOHM_EVANESCENT_VELOCITY, v_osm) - 1.0).abs()
                < 1e-15
        );
        assert!((relative_predictive_error(30.0, 2000.0) - 197.0 / 200.0).abs() < 1e-15);
        assert!(
            relative_predictive_error(plucker_three_channel_speed_sq(0.0, v_osm, 0.0), 4.0) < 1e-15
        );
        assert!(
            (mirror_symmetric_energy_speed_sq(2.0, -0.538)
                - mirror_symmetric_energy_speed_sq(2.0, 0.538))
            .abs()
                < 1e-15
        );
        assert!(
            (klaers_coupled_waveguide_speed_sq(1.0, 2.0, 3.0, -5.0)
                - klaers_coupled_waveguide_speed_sq(1.0, 2.0, 3.0, 5.0))
            .abs()
                < 1e-15
        );
        assert!(klaers_coupled_waveguide_speed_sq(1.0, 2.0, 3.0, 0.0) > 0.0);
        assert!(
            (klaers_backaction_quadratic_factor(1.0, 3.0, -5.0)
                - klaers_backaction_quadratic_factor(1.0, 3.0, 5.0))
            .abs()
                < 1e-15
        );
        assert!(
            (coupled_waveguide_clock_speed_sq_from_qfim(3.0, 20.0)
                - coupled_waveguide_clock_speed_sq_from_fubini_study(3.0, 5.0))
            .abs()
                < 1e-15
        );
        let a = evanescent_entry_probability(3.0, 4.0);
        let f = dwell_time_correction_factor(3.0, 4.0);
        assert!((a * f - 1.0).abs() < 1e-15);
        assert!(a <= 1.0 && f >= 1.0);
        assert!((evanescent_entry_probability(3.0, 3.0) - 1.0).abs() < 1e-15);
        assert!((dwell_time_correction_factor(3.0, 3.0) - 1.0).abs() < 1e-15);
        let d_bary: f64 = (3.0_f64.powi(2) - 4.0_f64.powi(2)) / (3.0_f64.powi(2) + 4.0_f64.powi(2));
        assert!((d_bary.powi(2) + a.powi(2) - 1.0).abs() < 1e-15);
        let tau_cond = conditional_residence_time(1.0, 2.0, 4.0);
        let tau_dwell = unconditional_quantum_dwell_time(1.0, 2.0, 3.0, 4.0);
        assert!((a * tau_cond - tau_dwell).abs() < 1e-15);
        assert!(complex_potential_fourth_power_speed_ratio(2.0, 1.0) > 1.0);
    }

    #[test]
    fn test_foo_ralph_relativistic_weak_values_and_tirole_drori() {
        let j_prime = lorentz_boosted_current(2.0, 0.25, 1.0, 2.0);
        let rho_prime = lorentz_boosted_density(2.0, 0.25, 1.0, 2.0);
        let v_orig = relativistic_weak_value_velocity(1.0, 2.0);
        assert!(
            (relativistic_weak_value_velocity(j_prime, rho_prime)
                - relativistic_velocity_addition(v_orig, 0.25))
            .abs()
                < 1e-15
        );
        let v_star = equal_frequency_boost_velocity(3.0, 1.0);
        assert!(((1.0 - v_star) * 4.0 - 2.0).abs() < 1e-15);
        assert!(((1.0 + v_star) * 4.0 - 6.0).abs() < 1e-15);
        assert!(
            (schwarzschild_alcubierre_coord_velocity(0.75, 1.5 - 1.0, 1.0) - 0.75 * 1.5).abs()
                < 1e-15
        );
        assert!(
            (two_photon_energy_normalized_density(2.0 * 3.0 * 0.8, 2.0 * 3.0 * 0.8, 3.0, 3.0)
                - 0.8)
            .abs()
                < 1e-15
        );

        // Tirole et al. (2023-2024)
        assert!((5.0 * time_double_slit_fringe_period(5.0) - 1.0).abs() < 1e-15);
        assert!(time_slit_bandwidth_envelope(1.0, 110.0) < time_slit_bandwidth_envelope(1.0, 4.4));
        assert!((time_varying_shg_modulation(0.465) - 0.93).abs() < 1e-15);

        // Drori et al. (2023/2024)
        let r3 = nonlinear_kerr_superposition_residual(2.0, 3.0, 4.0);
        assert!((r3 - 3.0 * 2.0 * 3.0 * 4.0 * 7.0).abs() < 1e-12 && r3 > 0.0);
        let r2 = chi2_second_harmonic_superposition_residual(2.0, 3.0, 4.0);
        assert!((r2 - 2.0 * 2.0 * 3.0 * 4.0).abs() < 1e-12 && r2 > 0.0);
        assert!((relative_predictive_error(0.0, -PI) - 1.0).abs() < 1e-15);
        assert!(
            (relative_predictive_error(pairwise_kerr_multi_photon_phase(3.0, -PI), -2.0 * PI)
                - 0.5)
            .abs()
                < 1e-15
        );
        assert!(
            relative_predictive_error(saturated_blockade_multi_photon_phase(3.0, -PI), -2.0 * PI)
                < 1e-15
        );
        assert!(
            (relative_predictive_error(
                pairwise_mcguire_three_body_energy(5.0),
                saturated_blockade_three_body_energy(5.0),
            ) - 1.0 / 3.0)
                .abs()
                < 1e-15
        );
        assert!(
            (connected_three_photon_correlation(7.4, 11.9 / 3.0, 11.9 / 3.0, 11.9 / 3.0) - (-2.5))
                .abs()
                < 1e-14
        );
        assert!(
            (connected_three_photon_correlation(3.9, 5.0 / 3.0, 5.0 / 3.0, 5.0 / 3.0) - 0.9)
                .abs()
                < 1e-14
        );

        // Critique & gap-closure
        assert!(unraveling_master_equation_gauge_residual(1.2, -0.8, 2.5, 0.4).abs() < 1e-14);
        assert!(bidirectional_evanescent_net_current(3.7).abs() < 1e-15);
        assert!(bidirectional_density_match_residual(0.64, 2.0, 1.5, 0.3).abs() < 1e-15);
        assert!(kahler_regularized_weak_velocity(0.0, 4.0, 1.2).abs() < 1e-15);
        assert!(
            DRORI_VORTEX_CORE_CORRELATION_FLOOR > 0.0
                && (DRORI_VORTEX_CORE_CORRELATION_FLOOR - 0.24).abs() < 1e-15
        );
        assert!(projective_qfim_energy_from_ray_metric(1.0, 2.0, 0.0, 3.0).abs() < 1e-15);
    }

    #[rstest]
    #[case(2.0, 3.5, 1.8, 0.25, 0.4, 0.3, 9.5, 28.5, 3.03, 22.0)]
    #[case(1.5, 5.0, 2.4, 0.10, -0.6, 0.5, 12.0, 30.0, 3.0, 18.0)]
    #[case(4.2, 0.8, 0.6, 0.50, 0.8, -0.25, 8.0, 24.0, 2.5, 15.0)]
    fn parametric_evanescent_waveguide_three_channel_and_lorentz_invariance(
        #[case] rho0: f64,
        #[case] kappa: f64,
        #[case] k1: f64,
        #[case] x_tilde: f64,
        #[case] v_vel: f64,
        #[case] v_boost: f64,
        #[case] omega_rabi: f64,
        #[case] delta_probe: f64,
        #[case] gamma_e: f64,
        #[case] odb: f64,
    ) {
        let hbar = 1.0_f64;
        let mass = 2.0_f64;
        let d_wg = evanescent_waveguide_directional_jet(rho0, kappa, k1);

        // Critique Fix QT-5: Channel 1 = 0, Channel 2 = (1/2) m rho0 v_osm^2, Channel 3 = k1^2 & 4 k1^2
        assert!(hydro_flow_dir(hbar, mass, d_wg).abs() < 1e-15);
        let v_osm = evanescent_osmotic_speed(hbar, mass, kappa);
        let ch2_expected = 0.5 * mass * rho0 * v_osm.powi(2);
        assert!((scalar_bohm_density_dir(hbar, mass, d_wg) - ch2_expected).abs() < 1e-13);
        assert!((fubini_study_diag(d_wg) - k1 * k1).abs() < 1e-13);
        assert!((qfim_diag(d_wg) - 4.0 * k1 * k1).abs() < 1e-13);

        // Normalized 3-channel speed squared identity from gpe_kinetic_dir
        let v_tot_sq_from_gpe = (2.0 / (mass * rho0)) * gpe_kinetic_dir(hbar, mass, d_wg);
        let v_tot_sq_from_channels =
            plucker_three_channel_speed_sq(0.0, v_osm, (hbar / mass) * k1);
        assert!((v_tot_sq_from_gpe - v_tot_sq_from_channels).abs() < 1e-13);

        // Critique Fix QT-6: Crossover continuity at |Delta| = hbar * J0, J0 = 0 reduction, and quartic difference
        let j0 = 3.0_f64;
        let v_sq_at_threshold = klaers_coupled_waveguide_speed_sq(hbar, mass, j0, hbar * j0);
        let v_sq_outer_limit = ((hbar * j0).abs() + 0.0) / mass;
        assert!((v_sq_at_threshold - v_sq_outer_limit).abs() < 1e-15);
        assert!(
            (klaers_coupled_waveguide_speed_sq(hbar, mass, 0.0, 1.5)
                - mirror_symmetric_energy_speed_sq(mass, 1.5))
            .abs()
                < 1e-15
        );
        let diff_quartic = waveguide_prop_pop_quartic(x_tilde) - waveguide_ev_pop_quartic(x_tilde);
        assert!((diff_quartic - (4.0 / 3.0) * x_tilde.powi(4)).abs() < 1e-15);

        // Critique Fix QT-3 / QT-5: Subluminal Lorentz velocity addition invariance
        let v_prime = relativistic_velocity_addition(v_vel, v_boost);
        let lhs_sublum = 1.0 - v_prime.powi(2);
        let rhs_sublum =
            (1.0 - v_boost.powi(2)) * (1.0 - v_vel.powi(2)) / (1.0 - v_boost * v_vel).powi(2);
        assert!((lhs_sublum - rhs_sublum).abs() < 1e-14);
        assert!(lhs_sublum > 0.0);

        // Critique Fix QT-7: Rydberg polariton Transmission Equality q_0 = 2 and 4x interaction boost
        assert!((rydberg_polariton_te_enhancement(omega_rabi, 0.0, delta_probe) - 1.0).abs() < 1e-14);
        let delta_te = omega_rabi.powi(2) / (2.0 * delta_probe);
        assert!(
            (rydberg_polariton_te_enhancement(omega_rabi, delta_te, delta_probe) - 2.0).abs()
                < 1e-14
        );
        let lambda_eit = rydberg_polariton_interaction_lambda(1.0, gamma_e, delta_probe, odb);
        let lambda_te = rydberg_polariton_interaction_lambda(2.0, gamma_e, delta_probe, odb);
        assert!((lambda_te - 4.0 * lambda_eit).abs() < 1e-12);
    }

    #[test]
    fn test_er_epr_wormhole_bohm_blowup_and_sharoglazova_klaers_qfim_cushion() {
        let b_reg = kahler_regularized_bohm_cushion(10.0, 0.5, 0.25);
        assert!((0.0..=10.0).contains(&b_reg));
        let b_saddle =
            dual_schubert_qfim_wormhole_cushion(0.0, 2.0, 1.0, 1.0, 6.0, 1.0, 4.0, 0.5, 1.0);
        assert!(b_saddle > 0.0);
        let b_qfim =
            dual_schubert_qfim_wormhole_cushion(10.0, 2.0, 1.0, 1.0, 6.0, 1.0, 4.0, 0.5, 0.0);
        assert!((b_qfim - 15.0).abs() < 1e-15);
        assert!(evanescent_throat_stored_energy(1.0, 1.0, 0.01) > b_qfim);
        assert!(evanescent_throat_stored_energy(1.0, 1.0, 2.0) <= b_qfim);
        assert!(
            saturated_blockade_three_body_energy(4.0) <= b_qfim
                && b_qfim < pairwise_mcguire_three_body_energy(4.0)
        );
    }
}
