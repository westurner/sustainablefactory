"""
Tri-language verification suite (SymPy + 45-digit mpmath + Rust/PyO3 `signals_numerical_adapter`)
for `Signals.QuantumCausalInference` Section 16 (`QCI-OSID`),
`Signals.Pending.OneShotQuantumSysIdPendingBoundary`,
`docs/quantum-causal-one-shot-system-identification-plan.md`, and
`docs/grassmannian-quantum-causal-one-shot-system-identification-paper.md`.
"""

from sustainablefactory.one_shot_sysid import (
    audit_qci_literature_benchmarks_high_precision,
    audit_qci_one_shot_sysid_high_precision,
    verify_symbolic_literature_check_figures,
    verify_symbolic_qci_one_shot_sysid_identities,
)


def test_symbolic_qci_one_shot_sysid_identities():
    sym_res = verify_symbolic_qci_one_shot_sysid_identities()
    assert len(sym_res) == 5
    assert all(sym_res.values()), f"Failed symbolic checks: {sym_res}"


def test_pyo3_and_mpmath_qci_one_shot_sysid_audit():
    rep = audit_qci_one_shot_sysid_high_precision(dps=45)
    assert rep["cauchy_binet_plucker_2x3_sym_ok"]
    assert rep["circulant_vs_hankel_sym_ok"]
    assert rep["pearl_do_and_abduction_sym_ok"]
    assert rep["quantum_switch_vrc_sym_ok"]
    assert rep["jeffrey_qfim_qcrb_landauer_sym_ok"]

    assert rep["cb_diff"] < 1e-14
    assert rep["circ_gram_diff"] < 1e-11
    assert rep["switch_sym_diff"] < 1e-15
    assert rep["switch_anti_diff"] < 1e-15
    assert rep["switch_ratio_diff"] < 1e-15
    assert rep["lorenz_beta_diff"] < 1e-7
    assert rep["jeffrey_diff"] < 1e-14
    assert rep["qcrb1_diff"] < 1e-15
    assert rep["landauer1_diff"] < 1e-15

    rust = rep["rust_report"]
    # Allen-Cahn PDE 1-shot vs degenerate harmonic
    assert rust["ac_generic_rank"] == 3
    assert rust["ac_generic_max_coeff_err"] < 1e-12
    assert rust["ac_generic_sigma_min"] > 1e-5
    assert rust["ac_generic_gram_det"] > 0.0
    assert rust["ac_degenerate_rank"] == 1
    assert rust["ac_degenerate_sigma_min"] < 1e-12
    assert abs(rust["ac_degenerate_gram_det"]) < 1e-24
    assert abs(rust["ac_cross_lag_q4_residual"]) > 0.5

    # Lorenz chaotic ODE 1-shot + Pearl do-deconfounding
    assert rust["lorenz_rank"] == 6
    assert rust["lorenz_max_param_err"] < 1e-6
    assert rust["lorenz_sigma_min"] > 1e-4
    assert abs(rust["lorenz_obs_confounded_slope"] - 10.45) < 1e-12
    assert abs(rust["lorenz_do_deconfounded_slope"] - 10.0) < 1e-12
    assert abs(rust["lorenz_abduced_exogenous_u"] - 1.5) < 1e-12

    # Circulant 1-shot vs Hankel 1-probe deficit / 2-probe recovery + Quantum Switch
    assert rust["circulant_rank_1shot"] == 4
    assert rust["circulant_max_err"] < 1e-12
    assert rust["hankel_1shot_rows"] == 3
    assert rust["hankel_1shot_cols"] == 5
    assert rust["hankel_1shot_rank"] == 3
    assert rust["hankel_2shot_rank"] == 5
    assert rust["hankel_2shot_max_err"] < 1e-12
    assert abs(rust["hankel_2x2_two_probe_det"]) > 0.5
    assert abs(rust["vrc_destructive_minor"]) < 1e-14

    # Jeffrey, QFIM = 4 g_FS QCRB, and Landauer bounds
    assert abs(rust["quantum_jeffrey_phase_avg"] - rust["jeffrey_do_estimate"]) < 1e-14
    assert abs(rust["qfim"] - 5.0) < 1e-14
    assert abs(rust["qcrb_4shot_var_bound"] - 0.05) < 1e-15
    assert abs(rust["landauer_10shot_closed_heat"] - 12.5) < 1e-14


def test_symbolic_literature_check_figures():
    sym_res = verify_symbolic_literature_check_figures()
    assert len(sym_res) == 6
    assert all(sym_res.values()), f"Failed literature symbolic checks: {sym_res}"


def test_pyo3_and_mpmath_literature_benchmarks_audit():
    rep = audit_qci_literature_benchmarks_high_precision(dps=45)
    assert rep["duffing_scale_sym_ok"]
    assert rep["elliptic_prop36_sym_ok"]
    assert rep["qi_ranard_quad_sym_ok"]
    assert rep["qi_ranard_2q_exact_ok"]
    assert rep["zhao_scaling_sym_ok"]
    assert rep["goswami_sym_ok"]

    assert rep["zhao_rmse5_diff"] < 1e-15
    assert rep["zhao_het5_diff"] < 1e-15
    assert rep["zhao_fixed5_diff"] < 1e-15
    assert rep["zhao_rmse15_diff"] < 1e-15
    assert rep["zhao_fixed15_diff"] < 1e-15
    assert rep["zhao_ratio15_diff"] < 1e-14
    assert rep["goswami_z_ideal_diff"] < 1e-13
    assert rep["goswami_z_mis_diff"] < 1e-13
    assert rep["hankel_1000_params"] == 1999
    assert rep["hankel_1000_1shot_deficit"] == 999

    rust = rep["rust_report"]
    # Forced Duffing (NBoulle/wias 02_duffing.ipynb, Fig. 1D)
    assert rust["duffing_rank"] == 11
    assert abs(rust["duffing_alpha"] - 1.0) < 1e-6
    assert abs(rust["duffing_delta"] - 0.02) < 1e-6
    assert abs(rust["duffing_beta"] - 5.0) < 1e-6
    assert abs(rust["duffing_gamma"] - 8.0) < 1e-6
    assert rust["duffing_max_coeff_err"] < 1e-6

    # 2D Allen-Cahn, Elliptic Prop. 36, and Navier-Stokes continuity
    assert rust["allen_cahn_2d_rank"] == 9
    assert rust["allen_cahn_2d_max_coeff_err"] < 1e-10
    assert rust["elliptic_coprime_rank"] == 1
    assert abs(rust["elliptic_coprime_gram_det"]) < 1e-6
    assert rust["elliptic_coprime_ray_residual"] < 1e-12
    assert rust["elliptic_multimode_rank"] == 2
    assert rust["elliptic_multimode_max_err"] < 1e-11
    assert rust["ns_continuity_rank"] == 3
    assert rust["ns_continuity_sigma4"] < 1e-12
    assert rust["ns_continuity_max_coeff_err"] < 1e-12

    # Qi & Ranard (2019) & Bairey et al. (2019) single-eigenstate 4-qubit recovery
    assert rust["qi_ranard_num_qubits"] == 4
    assert rust["qi_ranard_local_basis_dim"] == 8
    assert rust["qi_ranard_hilbert_dim"] == 16
    assert abs(rust["qi_ranard_lambda1"]) < 1e-12
    assert rust["qi_ranard_lambda2"] > 1e-3
    assert rust["qi_ranard_angle_err_rad"] < 1e-10
    assert rust["qi_ranard_max_scaled_coeff_err"] < 1e-10
    assert rust["bairey_commutator_residual"] < 1e-12

    # Zhao et al. (2020) & Goswami et al. (2018)
    assert abs(rust["zhao_n5_switch_fisher"] - 625.0) < 1e-12
    assert abs(rust["zhao_n15_switch_fisher"] - 50625.0) < 1e-12
    assert rust["zhao_n15_switch_rmse_ideal"] < rust["zhao_n15_fixed_heisenberg_bound"]
    assert rust["goswami_z_ideal_bound"] >= 18.0
    assert rust["goswami_z_misaligned_bound"] > 14.0
