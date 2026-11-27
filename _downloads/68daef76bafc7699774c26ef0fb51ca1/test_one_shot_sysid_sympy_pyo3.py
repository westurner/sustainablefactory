"""
Tri-language verification suite (SymPy + 45-digit mpmath + Rust/PyO3 `signals_numerical_adapter`)
for `Signals.QuantumCausalInference` Section 16 (`QCI-OSID`),
`Signals.Pending.OneShotQuantumSysIdPendingBoundary`,
`docs/quantum-causal-one-shot-system-identification-plan.md`, and
`docs/grassmannian-quantum-causal-one-shot-system-identification-paper.md`.
"""

from signals_numerical_adapter.one_shot_sysid import (
    audit_qci_literature_benchmarks_high_precision,
    audit_qci_one_shot_sysid_high_precision,
    audit_qci_sato_pde_solvers_high_precision,
    tequila_osid_noisy_mcweeny_pure_vs_mixed_audit,
    tequila_osid_quantum_switch_circuit,
    tequila_osid_single_eigenstate_recovery,
    tequila_osid_sparse_plucker_126qubit_audit,
    tequila_osid_vqe_davis_kahan_audit,
    verify_symbolic_literature_check_figures,
    verify_symbolic_qci_one_shot_sysid_identities,
    verify_symbolic_sato_osid_identities,
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
    assert rust["circulant_n40_rank"] == 40
    assert rust["circulant_n40_max_err"] < 1e-12
    assert rust["hankel_1shot_rows"] == 3
    assert rust["hankel_1shot_cols"] == 5
    assert rust["hankel_1shot_rank"] == 3
    assert rust["hankel_2shot_rank"] == 5
    assert rust["hankel_2shot_max_err"] < 1e-12
    assert rust["hankel_n40_1shot_rank"] == 40
    assert rust["hankel_n40_2shot_rank"] == 79
    assert rust["hankel_n40_2shot_max_err"] < 1e-11
    assert abs(rust["hankel_2x2_two_probe_det"]) > 0.5
    assert abs(rust["vrc_destructive_minor"]) < 1e-14

    # Jeffrey, QFIM = 4 g_FS QCRB, and Landauer bounds
    assert abs(rust["quantum_jeffrey_phase_avg"] - rust["jeffrey_do_estimate"]) < 1e-14
    assert abs(rust["qfim"] - 5.0) < 1e-14
    assert abs(rust["qcrb_4shot_var_bound"] - 0.05) < 1e-15
    assert abs(rust["landauer_10shot_closed_heat"] - 12.5) < 1e-14


def test_symbolic_literature_check_figures():
    sym_res = verify_symbolic_literature_check_figures()
    assert len(sym_res) == 8
    assert all(sym_res.values()), f"Failed literature symbolic checks: {sym_res}"


def test_pyo3_and_mpmath_literature_benchmarks_audit():
    rep = audit_qci_literature_benchmarks_high_precision(dps=45)
    assert rep["duffing_scale_sym_ok"]
    assert rep["elliptic_prop36_sym_ok"]
    assert rep["qi_ranard_quad_sym_ok"]
    assert rep["qi_ranard_2q_exact_ok"]
    assert rep["bairey_2q_exact_ok"]
    assert rep["qi_ranard_dim_compression_ok"]
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

    # 2D Allen-Cahn, Elliptic Prop. 36, and Navier-Stokes continuity + 16-term momentum
    assert rust["allen_cahn_2d_rank"] == 9
    assert rust["allen_cahn_2d_max_coeff_err"] < 1e-10
    assert rust["elliptic_coprime_rank"] == 1
    assert 0.0 <= rust["elliptic_coprime_gram_det"] < 1e-18
    assert rust["elliptic_coprime_ray_residual"] < 1e-12
    assert rust["elliptic_multimode_rank"] == 2
    assert rust["elliptic_multimode_max_err"] < 1e-11
    assert rust["ns_continuity_rank"] == 3
    assert rust["ns_continuity_sigma4"] < 1e-12
    assert rust["ns_continuity_max_coeff_err"] < 1e-12
    assert rust["ns_momentum_rank"] == 16
    assert abs(rust["ns_momentum_recovered_nu"] - 1e-3) < 1e-12
    assert rust["ns_momentum_max_coeff_err"] < 1e-10

    # Qi & Ranard (2019) & Bairey et al. (2019) single-eigenstate 4-qubit recovery
    assert rust["qi_ranard_num_qubits"] == 4
    assert rust["qi_ranard_local_basis_dim"] == 8
    assert rust["qi_ranard_hilbert_dim"] == 16
    assert abs(rust["qi_ranard_lambda1"]) < 1e-12
    assert rust["qi_ranard_lambda2"] > 1e-3
    assert rust["qi_ranard_angle_err_rad"] < 1e-10
    assert rust["qi_ranard_max_scaled_coeff_err"] < 1e-10
    assert 0.0 < rust["qi_ranard_dk_lhs"] <= rust["qi_ranard_dk_rhs"]
    assert rust["bairey_commutator_residual"] < 1e-12
    assert abs(rust["bairey_ktk_lambda1"]) < 1e-12
    assert rust["bairey_ktk_lambda2"] > 1e-4
    assert rust["bairey_recovered_max_err"] < 1e-11

    # Zhao et al. (2020) & Goswami et al. (2018)
    assert abs(rust["zhao_n5_switch_fisher"] - 625.0) < 1e-12
    assert abs(rust["zhao_n15_switch_fisher"] - 50625.0) < 1e-12
    assert rust["zhao_n15_switch_rmse_ideal"] < rust["zhao_n15_fixed_heisenberg_bound"]
    assert rust["goswami_z_ideal_bound"] >= 18.0
    assert rust["goswami_z_misaligned_bound"] > 14.0


def test_tequila_osid_vqe_davis_kahan_and_backend_parity():
    import tequila as tq
    from sustainablefactory.tequila_signals_backend import ensure_tequila_signals_backend_registered

    ensure_tequila_signals_backend_registered()
    vqe_rep = tequila_osid_vqe_davis_kahan_audit()
    assert vqe_rep["vqe_energy_err"] < 1e-6
    assert len(vqe_rep["qfim_diag"]) > 0
    assert all(
        abs(q - 4.0 * g) < 1e-12
        for q, g in zip(vqe_rep["qfim_diag"], vqe_rep["fubini_study_diag"])
    )

    exact = vqe_rep["exact_vqe_osid"]
    assert exact["lambda1"] < 1e-6
    assert exact["lambda2"] > 1e-3
    assert exact["projective_angle_err_rad"] < 1e-3
    assert exact["max_scaled_err"] < 1e-3
    assert exact["bairey_ktk_lambda1"] < 1e-6
    assert exact["bairey_max_scaled_err"] < 1e-3

    # Shot-noise disadvantage: 200k shots beats 4k shots on Davis-Kahan recovery
    low = vqe_rep["low_shot_4k_osid"]
    high = vqe_rep["high_shot_200k_osid"]
    assert high["projective_angle_err_rad"] < low["projective_angle_err_rad"]

    # Cross-backend parity on a symmetry-broken 2-qubit Ising ground state (signals vs grassmann vs symbolic)
    basis_2q = [
        tq.QubitHamiltonian("Z(0)Z(1)"),
        tq.QubitHamiltonian("X(0)"),
        tq.QubitHamiltonian("X(1)"),
        tq.QubitHamiltonian("Z(0)"),
    ]
    c2 = [1.0, 0.7, 0.4, 0.3]
    H2 = sum((c * h for c, h in zip(c2, basis_2q)), tq.QubitHamiltonian.zero())
    U2 = (
        tq.gates.Ry(angle="a0", target=0)
        + tq.gates.Ry(angle="a1", target=1)
        + tq.gates.CNOT(control=0, target=1)
        + tq.gates.Ry(angle="a2", target=0)
        + tq.gates.Ry(angle="a3", target=1)
    )
    res2 = tq.minimize(
        tq.ExpectationValue(H=H2, U=U2),
        initial_values={"a0": 0.4, "a1": 0.4, "a2": -0.3, "a3": 0.2},
        backend="signals",
        method="BFGS",
        tol=1e-10,
        silent=True,
    )
    rec_sig = tequila_osid_single_eigenstate_recovery(
        U2, basis_2q, variables=res2.variables, c_true=c2, backend="signals"
    )
    rec_gr = tequila_osid_single_eigenstate_recovery(
        U2, basis_2q, variables=res2.variables, c_true=c2, backend="grassmann"
    )
    rec_sym = tequila_osid_single_eigenstate_recovery(
        U2, basis_2q, variables=res2.variables, c_true=c2, backend="symbolic"
    )
    assert abs(rec_sig["lambda1"]) < 1e-9
    assert rec_sig["max_scaled_err"] < 1e-5
    assert abs(rec_sig["lambda2"] - rec_gr["lambda2"]) < 1e-12
    assert abs(rec_sig["lambda2"] - rec_sym["lambda2"]) < 1e-12


def test_tequila_osid_quantum_switch_126qubit_and_mcweeny_tradeoffs():
    # 1. Circuit-level Gr_C(2,4) Quantum Switch across signals, grassmann, and symbolic
    sw = tequila_osid_quantum_switch_circuit()
    assert abs(sw["delta_signals"] - sw["delta_grassmann"]) < 1e-13
    assert abs(sw["delta_signals"] - sw["delta_symbolic"]) < 1e-13
    assert abs(sw["e_plus"] - sw["exact_e_plus"]) < 1e-13
    assert abs(sw["e_minus"] - sw["exact_e_minus"]) < 1e-13
    assert abs(sw["plucker_ratio"] - sw["exact_plucker_ratio"]) < 1e-13

    # 2. 126-qubit 128-bit sparse Plucker HCB-SPA identification advantage
    sp126 = tequila_osid_sparse_plucker_126qubit_audit()
    assert sp126["n_qubits"] == 126
    assert sp126["active_support_size"] == 64
    assert sp126["sparse_bytes"] == 1024
    assert sp126["dense_bytes_log2"] == 130
    assert abs(sp126["lambda1"]) < 1e-12
    assert sp126["lambda2"] > 0.2
    assert sp126["max_scaled_err"] < 1e-12

    # 3. McWeeny purification: heals depolarized pure eigenstate, distorts thermal Gibbs state
    mcw = tequila_osid_noisy_mcweeny_pure_vs_mixed_audit()
    assert mcw["purity_purified"] > mcw["purity_raw"]
    assert mcw["pure_depolarized_angle_err_purified"] < mcw["pure_depolarized_angle_err_raw"]
    assert mcw["gibbs_p0_after_mcweeny"] > 0.65
    assert mcw["gibbs_p1_after_mcweeny"] < 0.35
    assert mcw["gibbs_trace_distortion"] > 0.05


def test_qci_osid_sato_kp2_kdv_akns_and_qfim_bridge():
    sym_sato = verify_symbolic_sato_osid_identities()
    assert len(sym_sato) == 5
    assert all(sym_sato.values()), f"Failed Sato-OSID symbolic checks: {sym_sato}"

    rep = audit_qci_sato_pde_solvers_high_precision(dps=45)
    assert rep["far_field_rel_diff"] < 1e-12
    assert rep["kdv3_u_diff"] < 1e-14
    assert abs(rep["kdv3_jet_kp2_res"]) < 1e-12
    assert rep["gr25_num_terms"] == 10
    assert abs(rep["gr25_kp2_res"]) < 1e-12
    assert rep["gr36_num_terms"] == 20
    assert abs(rep["gr36_kp2_res"]) < 1e-12
    rust = rep["rust_report"]

    # Positroid & N-soliton stratification zero-one dichotomy:
    assert rust["kp2_top_cell_rank"] == 3
    assert rust["kp2_top_cell_sigma_min"] > 0.1
    assert rust["kp2_top_cell_max_coeff_err"] < 1e-9
    assert abs(rust["kp2_far_field_residual"]) < 1e-12
    assert rust["kdv2_on_kp2_dict_rank"] == 2
    assert rust["kdv2_on_kp2_dict_sigma_min"] < 1e-12
    assert rust["kdv2_subdict_rank"] == 2
    assert rust["kdv2_subdict_max_coeff_err"] < 1e-12
    assert rust["kdv1_traveling_wave_rank"] == 2
    assert rust["kdv1_on_3term_kdv_rank"] == 2
    assert rust["kdv1_on_3term_sigma_min"] < 1e-12

    # Arbitrary N-soliton & Gr_>0(k, n) solvers inside QCI-OSID:
    assert rust["kdv3_on_kp2_dict_rank"] == 2
    assert rust["kdv3_on_3term_kdv_rank"] == 3
    assert rust["kdv3_max_coeff_err"] < 1e-11
    assert abs(rust["kdv3_far_field_residual"]) < 1e-12
    assert rust["kdv4_on_3term_kdv_rank"] == 3
    assert rust["kdv4_max_coeff_err"] < 1e-11
    assert rust["gr25_kp2_rank"] == 3
    assert rust["gr25_kp2_max_coeff_err"] < 1e-11
    assert rust["gr36_kp2_rank"] == 3
    assert rust["gr36_kp2_max_coeff_err"] < 1e-11

    # AKNS focusing NLS bright (+2) vs defocusing GPE dark (-2)
    assert rust["akns_bright_rank"] == 2
    assert rust["akns_bright_max_err"] < 1e-12
    assert rust["akns_dark_rank"] == 2
    assert rust["akns_dark_max_err"] < 1e-12

    # 6-channel Dual-Schubert QFIM tightening of QCRB
    assert rust["qfim_six_channel_total"] > rust["qfim_forward_only"]
    assert rust["qcrb_six_channel_1shot"] < rust["qcrb_forward_only_1shot"]
