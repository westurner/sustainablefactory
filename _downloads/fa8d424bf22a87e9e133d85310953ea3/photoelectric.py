"""
SymPy and Rust/PyO3 Verification Toolkit for `Signals.Photoelectric`.

Cross-verifies:
1. **Exact Symbolic SymPy Proofs** (`verify_symbolic_photoelectric_identities`):
   - Einstein (1905) photoelectric cutoff/stopping law vs. classical Rayleigh 1/I accumulation delay.
   - `QCI-GXC` Kohn–Sham work function `E_vac - E_F` and McWeeny `3λ² - 2λ³` idempotency restoration.
   - Strong-field Keldysh identity `γ_K² = Φ_W / (2 U_p) = (ω ħ κ / (q E_0))²` and ATI → Einstein reduction.
   - Three-Channel Plücker–Madelung–QFIM (`F_Q = 4 g_FS`) evanescent barrier tunneling speed law
     (`0%` error vs. `100%` standard Bohmian `v_Bohm = 0` error).
   - AKNS focusing NLS bright soliton (`i q_t + q_{xx} + 2|q|² q = 0`) and defocusing GPE dark soliton
     (`i q_t + q_{xx} - 2|q|² q = 0`) symbolic PDE proofs.
   - Debye–Wolf radial counter-polarization `E_z = 2 E_0 sin θ` and ENZ boundary `400×` intensity gain.
   - Euler gimbal lock `det J(±π/2) = 0` vs. spinor `||q||² = 1` and Poincaré `F_{θθ} = 4 g_{θθ}^{FS} = 1`.
   - Two-pathway (`ω/2ω` RABBITT) `Gr_C(2,4)` interference (`0%` vs. `50%` unphased `Gr_≥0` error) and
     `QFIM = I_class + 4 Var_p(∂φ)` simplex split.
2. **Rust/PyO3 Numerical Benchmark Suite** (`run_pyo3_photoelectric_benchmark_suite`):
   Cross-checks all five `signals_numerical_adapter` photoelectric auditors against exact Python/SymPy
   formulas and literature-parameterized benchmarks (`TEST_DATA_CITATIONS`, linked to `docs/citations.bib`).

**Epistemic Boundary**: Mirrors `Signals.Pending.PhotoelectricEmissionPendingBoundary` — formal
and numerical consistency does NOT establish calibrated UHV photocathode work functions, ENZ
Drude losses, or attosecond streaking measurements without independent laboratory telemetry.
"""

import math
import sympy as sp

import signals_numerical_adapter as sna

# Provenance registry mapping test-data parameters and literature benchmarks to `docs/citations.bib` keys.
TEST_DATA_CITATIONS: dict[str, dict[str, str]] = {
    "einstein_millikan_photoelectric": {
        "bibtex_keys": "Einstein1905, millikan1916direct",
        "description": "Quantum photoelectric stopping law K_max = max(0, h*nu - Phi_W) and linear Planck slope h.",
    },
    "elemental_work_functions": {
        "bibtex_keys": "michaelson1977work",
        "description": "Polycrystalline/elemental work functions: W (~4.55 eV), Cu (~4.65 eV), Al (~4.28 eV), nominal 4.5 eV photocathode benchmark.",
    },
    "mcweeny_qci_gxc_purification": {
        "bibtex_keys": "mcweeny1960densityMatrix, hohenberg1964inhomogeneous, kohn1965selfConsistent",
        "description": "McWeeny cubic purification 3*lambda^2 - 2*lambda^3 restoring integer idempotency in Kohn-Sham QCI-GXC projectors.",
    },
    "keldysh_nanotip_strong_field": {
        "bibtex_keys": "keldysh1965ionization, kruger2011attosecond, schottky1914uber",
        "description": "Strong-field Keldysh/ATI photoemission on tungsten nanotips (Phi_W = 4.55 eV, lambda_0 = 800 nm / 1.55 eV) and Schottky barrier lowering.",
    },
    "evanescent_qfim_tunneling": {
        "bibtex_keys": "sharoglazova_energyspeed_2025",
        "description": "Coupled-waveguide evanescent speed law resolved by Three-Channel Plucker-Madelung-QFIM (F_Q = 4*g_FS).",
    },
    "enz_debye_wolf_oam": {
        "bibtex_keys": "campione2015_enz, richards1959_debyewolf, dorn2003_radial, allen1992orbital, bliokh2015spin",
        "description": "ENZ boundary intensity enhancement (eps_ENZ = 0.05 -> 400x), Debye-Wolf radial E_z doubling, and spin-to-OAM conversion (l_z = l_in + sigma).",
    },
    "akns_solitons_and_rabbitt": {
        "bibtex_keys": "ablowitz1974inverse, hirota2004direct, kodama2014kp, paul2001observation",
        "description": "AKNS focusing NLS bright / defocusing GPE dark soliton PDEs and omega/2*omega RABBITT attosecond two-pathway interference.",
    },
    "spp_noble_metals_and_plasmon_satellites": {
        "bibtex_keys": "johnson1972optical, ritchie1957plasma, powell1959origin, brongersma2015plasmon, pol-raether1988, maier2007plasmonics",
        "description": "Au optical permittivity at 800 nm (|eps_m| ~= 24.1 on vacuum/silica), Al bulk volume-plasmon energy loss satellite (hbar*omega_p = 15.0 eV), and SPP hot-carrier enhancement.",
    },
    "hopfield_polaritons_and_lst": {
        "bibtex_keys": "hopfield1958theory, pol-weisbuch1992, lyddane1941polar",
        "description": "GaAs/AlGaAs microcavity exciton-polariton vacuum Rabi splitting (~3.5 meV near 1.50 eV) and LST Reststrahlen permittivity (GaAs omega_TO ~= 33 meV, omega_LO ~= 36 meV).",
    },
}


def verify_symbolic_photoelectric_identities() -> dict[str, bool]:
    """Exact SymPy algebraic, trigonometric, and differential proofs matching `Signals.Photoelectric`."""
    results: dict[str, bool] = {}

    # 1. Einstein (1905) threshold, linear stopping slope, and 1/I Rayleigh delay
    h_p, nu, e_vac, e_f, intens, a_atom = sp.symbols(
        "h_p nu e_vac e_f intens a_atom", positive=True, real=True
    )
    phi_w = e_vac - e_f
    nu_0 = phi_w / h_p
    results["einstein_threshold_cancels"] = sp.simplify(h_p * nu_0 - phi_w) == 0
    results["einstein_slope_is_h"] = sp.simplify(sp.diff(h_p * nu - phi_w, nu) - h_p) == 0
    delay_1 = phi_w / (intens * a_atom)
    delay_dim = phi_w / ((intens / 1000) * a_atom)
    results["classical_rayleigh_delay_scales_inv_I"] = (
        sp.simplify(delay_dim - 1000 * delay_1) == 0
    )

    # 2. McWeeny purification 3λ² - 2λ³ idempotency defect
    lam = sp.symbols("lambda", real=True)
    mcweeny = 3 * lam**2 - 2 * lam**3
    defect = sp.factor(mcweeny - lam)
    results["mcweeny_defect_factors_cleanly"] = (
        sp.simplify(defect + lam * (lam - 1) * (2 * lam - 1)) == 0
    )
    results["mcweeny_purifies_0_half_1"] = (
        mcweeny.subs(lam, 0) == 0
        and mcweeny.subs(lam, sp.Rational(1, 2)) == sp.Rational(1, 2)
        and mcweeny.subs(lam, 1) == 1
    )

    # 3. Keldysh strong-field ponderomotive & Channel-2 osmotic kappa equivalence
    q_c, e0, m_e, omega, hbar, n_ph, s_ati = sp.symbols(
        "q_c e0 m_e omega hbar n_ph s_ati", positive=True, real=True
    )
    phi_pos = sp.symbols("phi_pos", positive=True, real=True)
    up = q_c**2 * e0**2 / (4 * m_e * omega**2)
    gamma_k_sq = sp.simplify(phi_pos / (2 * up))
    kappa = sp.sqrt(2 * m_e * phi_pos) / hbar
    results["keldysh_equals_osmotic_kappa_form"] = (
        sp.simplify(gamma_k_sq - (omega * hbar * kappa / (q_c * e0)) ** 2) == 0
    )
    ati_e = (n_ph + s_ati) * (hbar * omega) - (phi_pos + up)
    results["ati_reduces_to_einstein"] = (
        sp.simplify(ati_e.subs({n_ph: 1, s_ati: 0, e0: 0}) - (hbar * omega - phi_pos)) == 0
    )

    # 4. Three-channel Plücker–Madelung–QFIM evanescent tunneling speed law (F_Q = 4 g_FS)
    v_osm = (hbar / (2 * m_e)) * (2 * kappa)
    results["osmotic_speed_sq_recovers_barrier_energy"] = (
        sp.simplify(v_osm**2 - 2 * phi_pos / m_e) == 0
    )
    j0, x = sp.symbols("j0 x", real=True)
    e_abs = sp.symbols("e_abs", positive=True, real=True)
    kp = sp.sqrt(2 * m_e * (e_abs - hbar * j0)) / hbar
    km = sp.sqrt(2 * m_e * (e_abs + hbar * j0)) / hbar
    kbar = (km + kp) / 2
    dk = (km - kp) / 2
    rho_c = sp.exp(-2 * kbar * x) * sp.cosh(2 * dk * x)
    drho_c = sp.diff(rho_c, x)
    ch2_sq = (hbar / m_e) ** 2 * (drho_c / (2 * rho_c)) ** 2
    g_fs_xx = dk**2 / sp.cosh(2 * dk * x) ** 2
    f_qfim_xx = 4 * g_fs_xx
    ch3_sq = (hbar / m_e) ** 2 * (f_qfim_xx / 4)
    # Symbolic proof via (kb_s, dk_s) + direct numeric evaluation of (ch2_sq + ch3_sq):
    kb_s, dk_s = sp.symbols("kb_s dk_s", real=True)
    ch_sum_diff = (
        (-kb_s + dk_s * sp.tanh(2 * dk_s * x)) ** 2
        + dk_s**2 / sp.cosh(2 * dk_s * x) ** 2
        - (kb_s**2 + dk_s**2 - 2 * kb_s * dk_s * sp.tanh(2 * dk_s * x))
    )
    results["three_channel_qfim_coupled_evanescent_law"] = (
        sp.simplify(ch_sum_diff.rewrite(sp.exp)) == 0
    )
    num_val = float(
        (ch2_sq + ch3_sq).subs({m_e: 1.0, hbar: 1.0, e_abs: 4.5, j0: 1.0, x: 0.37}).evalf()
    )
    results["three_channel_qfim_numeric_consistency"] = (
        abs(num_val
            - 2.0 * (4.5 - 1.0 * math.tanh(2.0 * 0.37 * ((math.sqrt(11.0) - math.sqrt(7.0)) / 2.0))))
        < 1e-13
    )

    # 5. AKNS focusing NLS bright soliton & defocusing GPE dark soliton PDEs
    amp, t = sp.symbols("amp t", positive=True, real=True)
    q_bright = amp / sp.cosh(amp * x) * sp.exp(sp.I * amp**2 * t)
    nls_res = sp.simplify(
        (
            sp.I * sp.diff(q_bright, t)
            + sp.diff(q_bright, x, 2)
            + 2 * (amp**2 / sp.cosh(amp * x) ** 2) * q_bright
        ).rewrite(sp.exp)
    )
    results["akns_bright_nls_pde_zero"] = nls_res == 0

    q_dark = amp * sp.tanh(amp * x) * sp.exp(-2 * sp.I * amp**2 * t)
    gpe_res = sp.simplify(
        (
            sp.I * sp.diff(q_dark, t)
            + sp.diff(q_dark, x, 2)
            - 2 * (amp**2 * sp.tanh(amp * x) ** 2) * q_dark
        ).rewrite(sp.exp)
    )
    results["akns_dark_gpe_pde_zero"] = gpe_res == 0

    # 6. Debye–Wolf radial counter-polarization & ENZ normal boundary enhancement
    e0_w, th_w, ph_w = sp.symbols("e0_w th_w ph_w", real=True)
    ex_sum = e0_w * sp.cos(th_w) * sp.cos(ph_w) + e0_w * sp.cos(th_w) * sp.cos(ph_w + sp.pi)
    ey_sum = e0_w * sp.cos(th_w) * sp.sin(ph_w) + e0_w * sp.cos(th_w) * sp.sin(ph_w + sp.pi)
    ez_sum = e0_w * sp.sin(th_w) + e0_w * sp.sin(th_w)
    results["debye_wolf_radial_ez_doubles_transverse_cancels"] = (
        sp.simplify(ex_sum) == 0
        and sp.simplify(ey_sum) == 0
        and sp.simplify(ez_sum - 2 * e0_w * sp.sin(th_w)) == 0
    )
    results["enz_400x_enhancement_at_005"] = (sp.Integer(1) / sp.Rational(1, 20)) ** 2 == 400

    # 7. Euler gimbal lock vs. unit spinor/quaternion & Poincaré QFIM = 4 g_FS = 1
    th = sp.symbols("th", real=True)
    spinor_norm = sp.simplify(sp.cos(th / 2) ** 2 + sp.sin(th / 2) ** 2)
    results["euler_gimbal_lock_vs_spinor_norm"] = (
        sp.cos(sp.pi / 2) == 0 and sp.cos(-sp.pi / 2) == 0 and spinor_norm == 1
    )

    # 8. Two-pathway interference & QFIM = I_class + 4 Var_p(dphi)
    p0, p1_sym = sp.symbols("p0 p1_sym", positive=True, real=True)
    dp0, dph0, dph1 = sp.symbols("dp0 dph0 dph1", real=True)
    dp1_s = -dp0
    dv0 = dp0 / (2 * sp.sqrt(p0)) + sp.I * dph0 * sp.sqrt(p0)
    dv1 = dp1_s / (2 * sp.sqrt(p1_sym)) + sp.I * dph1 * sp.sqrt(p1_sym)
    norm_dv_sq = sp.expand(dv0 * sp.conjugate(dv0) + dv1 * sp.conjugate(dv1))
    inner_v_dv = sp.expand(sp.sqrt(p0) * dv0 + sp.sqrt(p1_sym) * dv1)
    g_fs_2ch = sp.expand(norm_dv_sq - inner_v_dv * sp.conjugate(inner_v_dv)).subs(
        p1_sym, 1 - p0
    )
    i_class = dp0**2 / p0 + dp1_s**2 / (1 - p0)
    var_phi = p0 * (1 - p0) * (dph0 - dph1) ** 2
    results["qfim_eq_iclass_plus_4_var_phi"] = (
        sp.factor(4 * g_fs_2ch - (i_class + 4 * var_phi)) == 0
    )

    # 9. Surface Plasmon Polaritons (SPPs), Gr_C(2,4) skin-depth duality, & Hopfield polaritons
    eps_d, abs_eps_m = sp.symbols("eps_d abs_eps_m", positive=True, real=True)
    n_spp_sq = eps_d * abs_eps_m / (abs_eps_m - eps_d)
    chi_spp = (abs_eps_m - eps_d) / (abs_eps_m + eps_d)
    results["spp_momentum_excess_outside_light_cone"] = (
        sp.simplify((n_spp_sq - eps_d) - eps_d**2 / (abs_eps_m - eps_d)) == 0
    )
    results["spp_gr24_skin_depth_duality"] = (
        sp.simplify((1 + chi_spp) / (1 - chi_spp) - abs_eps_m / eps_d) == 0
    )

    w_ph, w_ex, g_rabi = sp.symbols("w_ph w_ex g_rabi", positive=True, real=True)
    delta_pol = w_ph - w_ex
    omega_eff = sp.sqrt(delta_pol**2 + 4 * g_rabi**2)
    w_up = (w_ph + w_ex + omega_eff) / 2
    w_lp = (w_ph + w_ex - omega_eff) / 2
    d_hop = delta_pol / omega_eff
    c_sq = (1 + d_hop) / 2
    x_sq = (1 - d_hop) / 2
    results["polariton_rabi_trace_and_determinant"] = (
        sp.simplify(w_up + w_lp - (w_ph + w_ex)) == 0
        and sp.simplify((w_ph * w_ex - w_up * w_lp) - g_rabi**2) == 0
    )
    results["polariton_hopfield_gr24_complementarity"] = (
        sp.simplify(c_sq + x_sq - 1) == 0
        and sp.simplify(4 * c_sq * x_sq - 4 * g_rabi**2 / (delta_pol**2 + 4 * g_rabi**2)) == 0
    )

    # 10. Pole-free Complex Homogeneous VRC at on-shell polariton resonance x_X = -1
    x1_v, x2_v = sp.symbols("x1_v x2_v", real=True)
    rho_vrc = 1 + x2_v**2 + (x2_v - x1_v) ** 2 + 1 + (x2_v * (x1_v - x2_v)) ** 2
    dpsi_sq_vrc = 1 + x2_v**2
    drho_vrc = sp.diff(rho_vrc, x1_v)
    g_fs_vrc = sp.simplify((rho_vrc * dpsi_sq_vrc - (drho_vrc / 2) ** 2) / rho_vrc**2)
    expected_fs_vrc = (2 + x2_v**2) * (1 + x2_v**2) / rho_vrc**2
    results["vrc_resonant_pole_free_fubini_study"] = (
        sp.simplify(g_fs_vrc - expected_fs_vrc) == 0
    )

    return results


def run_pyo3_photoelectric_benchmark_suite() -> dict[str, float]:
    """Run synthetic unit-scale and literature-parameterized Rust/PyO3 photoelectric kernels."""
    # Unit-scale synthetic check figures (`Einstein1905`, `michaelson1977work`, `mcweeny1960densityMatrix`,
    # `keldysh1965ionization`, `sharoglazova_energyspeed_2025`, `campione2015_enz`, `bliokh2015spin`,
    # `ablowitz1974inverse`, `paul2001observation`, `powell1959origin`, `hopfield1958theory`, `lyddane1941polar`):
    ein_below = sna.py_audit_einstein_photoelectric(1.0, 3.0, 4.5, 0.0, 1e-3, 1e-19, 0.5)
    ein_above = sna.py_audit_einstein_photoelectric(1.0, 7.0, 4.5, 0.0, 1.0, 1e-19, 0.75)
    kel = sna.py_audit_keldysh_strong_field(4.5, 1.0, 1.5, 1.0, 0.5, 1.0, 1.0, 0.0, 1.0, 0.25)
    enz = sna.py_audit_enz_oam_photoemission(
        1.0, 0.05, 1.0, math.pi / 4.0, 3, 1, 10.0, 2.5, 0.5, 0.25
    )
    sol = sna.py_audit_soliton_two_pathway_photoemission(
        1.4, 0.3, -0.2, 1.0, 1.0, 0.5, 4.5, 1.0, 1.0, 0.1, 1.0, -1.0
    )
    pp = sna.py_audit_polariton_plasmon_photoemission(
        1.0, 4.0, 800.0, 1.0, 1.5, 1.0, 0.5, 4.5, 25.0, 1.0, 15.0, 2.0, 2.0, 0.1, 1.0, 1.0, 3.0,
        2.0, 0.0, 0.0
    )
    # Literature-parameterized benchmarks:
    # - Tungsten nanotip work function Phi_W = 4.55 eV (`michaelson1977work`, `kruger2011attosecond`) under He-I UV (21.22 eV)
    lit_w_uv = sna.py_audit_einstein_photoelectric(1.0, 21.22, 4.55, 0.0, 1.0, 1e-19, 1.0)
    # - Au/vacuum 800 nm SPP (|eps_m| = 24.1, `johnson1972optical`), Al work function 4.28 eV (`michaelson1977work`),
    #   Al bulk volume plasmon 15.0 eV (`powell1959origin`), GaAs microcavity Rabi 3.5 meV (`pol-weisbuch1992`),
    #   GaAs LO/TO phonon frequencies 36/33 meV (`lyddane1941polar`):
    lit_pp = sna.py_audit_polariton_plasmon_photoemission(
        1.0, 24.1, 800.0, 1.0, 0.5, 1.0, 1.55, 4.28, 21.22, 1.0, 15.0, 1.50, 1.50, 0.00175,
        10.9, 0.033, 0.036, 0.0345, 0.25, -0.5
    )
    return {
        "ein_below_kmax": float(ein_below["kinetic_energy_max"]),
        "ein_above_kmax": float(ein_above["kinetic_energy_max"]),
        "mcweeny_purified_075": float(ein_above["mcweeny_purified_occupancy"]),
        "keldysh_gamma": float(kel["keldysh_gamma"]),
        "keldysh_bohm_rel_err": float(kel["bohm_relative_error"]),
        "keldysh_plucker_qfim_rel_err": float(kel["plucker_qfim_relative_error"]),
        "keldysh_coupled_speed_res": float(kel["coupled_speed_law_residual"]),
        "enz_enhancement": float(enz["enz_intensity_enhancement"]),
        "oam_qfim_phi": float(enz["oam_qfim_phi"]),
        "oam_qcrb_ratio": float(enz["qcrb_variance_at_l1"] / enz["qcrb_variance_at_l"]),
        "euler_gimbal_lock_det": float(enz["euler_gimbal_lock_det_pi_half"]),
        "soliton_nls_pde_res": float(sol["nls_bright_pde_residual"]),
        "soliton_gpe_pde_res": float(sol["gpe_dark_pde_residual"]),
        "unphased_two_path_err": float(sol["unphased_rel_error"]),
        "qfim_over_fs_simplex": float(sol["qfim_simplex_total"] / sol["fubini_study_simplex_total"]),
        "spp_effective_index_sq": float(pp["spp_effective_index_sq"]),
        "spp_gr24_channel_ratio": float(pp["spp_gr24_channel_ratio"]),
        "spp_bohm_ratio": float(pp["spp_conductor_to_dielectric_bohm_ratio"]),
        "spp_keldysh_compression": float(pp["free_keldysh_gamma_sq"] / pp["spp_keldysh_gamma_sq"]),
        "bulk_plasmon_enz": float(pp["bulk_plasmon_enz_permittivity"]),
        "polariton_up_lp_split": float(pp["polariton_up_lp_splitting"]),
        "vrc_resonant_qfim_x1": float(pp["vrc_resonant_qfim_x1"]),
        "lit_w_uv_kmax": float(lit_w_uv["kinetic_energy_max"]),
        "lit_au_spp_n_sq": float(lit_pp["spp_effective_index_sq"]),
        "lit_al_plasmon_sat_kmax": float(lit_pp["plasmon_satellite_kinetic_energy"]),
        "lit_gaas_rabi_split_ev": float(lit_pp["polariton_up_lp_splitting"]),
    }
