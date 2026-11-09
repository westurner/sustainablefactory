"""Unit tests for sustainablefactory.qci_grassmannian_dft."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import sympy as sp

from sustainablefactory.qci_grassmannian_dft import (
    HARTREE_TO_KCAL_MOL,
    AdvancedComplexGrassmannianXC,
    AnyonLeakageCorrector,
    ChallengePayloadExporter,
    ComplexPlabicGraphXC,
    ComplexPlabicVRC,
    FaultTolerantGrassmannianComputer,
    OpenQASM3Interpreter,
    OpenQASM3MultiQuditCompiler,
    OpenQASMToPlabicCompiler,
    PlabicBraidingSimulator,
    ProductionPipelineOptimizer,
    QCIChannelTracker,
    RiemannianGrassmannianOptimizer,
    SolitonPerformanceProfiler,
    SpinPolarizedGrassmannianGXC,
    SpinPolarizedManifoldGXC,
    TopologicalCheckFigures,
    TopologicalGrassmannianEngine,
    TopologicalNoiseProfiler,
    TuningMaterialsWithLightEngine,
    UniversalGeometryParser,
    UniversalSolitonQuditEngine,
    calculate_symbolic_plucker_relation,
    demonstrate_lambdify,
    setup_symbolic_gr24,
    setup_symbolic_vrc_gr24,
)


def test_complex_plabic_vrc_and_resonance_pole_resolution() -> None:
    V_hom, K_hom, V_mut, K_mut, (x1, x2, xX) = setup_symbolic_vrc_gr24()
    assert sp.simplify(V_hom * K_hom.T) == sp.zeros(2, 2)
    assert sp.simplify(V_mut * K_mut.T) == sp.zeros(2, 2)

    rel_hom, _ = calculate_symbolic_plucker_relation(V_hom)
    rel_mut, _ = calculate_symbolic_plucker_relation(V_mut)
    assert rel_hom == 0
    assert rel_mut == 0

    t_x1 = 0.5 + 0.2j
    t_x2 = -0.3 + 0.7j
    t_xX = 1.2 - 0.4j

    vrc_pre = ComplexPlabicVRC.gr24_homogeneous_vrc(t_x1, t_x2, t_xX)
    assert vrc_pre.is_valid()
    assert np.isclose(abs(vrc_pre.plucker_quadratic_residual()), 0.0, atol=1e-15)

    # GL(2, C) and black-vertex transformations preserve validity and Plücker relation
    g = np.array([[1.2 + 0.3j, -0.4 + 0.1j], [0.2 - 0.5j, 0.9 + 0.2j]], dtype=complex)
    m = np.array([[2.0 + 0.0j, -1.0 + 0.5j], [0.5 - 0.2j, 1.5 + 0.0j]], dtype=complex)
    vrc_gl = vrc_pre.transform_gl(g).transform_black_relations(m)
    assert vrc_gl.is_valid()
    assert np.isclose(abs(vrc_gl.plucker_quadratic_residual()), 0.0, atol=1e-14)

    # At on-shell polariton resonance xX = -1, mutated VRC remains completely regular
    vrc_res = ComplexPlabicVRC.gr24_mutated_homogeneous_vrc(t_x1, t_x2, -1.0 + 0.0j)
    assert vrc_res.is_valid()
    p_res = vrc_res.get_pluckers_gr24()
    assert np.isclose(p_res["12"], 1.0 + 0.0j)
    assert np.isclose(p_res["13"], 0.0 + 0.0j, atol=1e-15)
    assert np.isclose(p_res["14"], t_x2, atol=1e-15)
    assert np.isclose(p_res["23"], t_x2 - t_x1, atol=1e-15)
    assert np.isclose(p_res["24"], 1.0 + 0.0j, atol=1e-15)
    assert np.isclose(p_res["34"], t_x2 * (t_x1 - t_x2), atol=1e-15)
    assert np.isclose(abs(vrc_res.plucker_quadratic_residual()), 0.0, atol=1e-15)


def test_sympy_gr24_and_complex_plabic_graph_xc_check_figures() -> None:
    C_sym, (x1, x2, xX) = setup_symbolic_gr24()
    rel_sym, minors = calculate_symbolic_plucker_relation(C_sym)
    assert rel_sym == 0

    t_x1 = 0.5 + 0.2j
    t_x2 = -0.3 + 0.7j
    t_xX = 1.2 - 0.4j
    subs = {x1: t_x1, x2: t_x2, xX: t_xX}
    assert np.isclose(complex(minors["p12"].subs(subs)), 1.0 + 0.0j)
    assert np.isclose(complex(minors["p13"].subs(subs)), 0.75 + 0.25j)
    assert np.isclose(complex(minors["p14"].subs(subs)), 0.3 - 0.7j)
    assert np.isclose(complex(minors["p23"].subs(subs)), 0.5 + 0.2j)
    assert np.isclose(complex(minors["p24"].subs(subs)), 1.2 - 0.4j)
    assert np.isclose(complex(minors["p34"].subs(subs)), 0.71 + 0.29j)

    p14_fast, mutation_fast = demonstrate_lambdify()
    assert np.isclose(p14_fast(t_x1, t_x2, t_xX), 0.3 - 0.7j)
    x1_new, x2_new, xX_new = mutation_fast(t_x1, t_x2, t_xX)
    assert np.isclose(xX_new, 0.75 + 0.25j)
    assert np.isclose(x2_new, t_x2)

    solver = ComplexPlabicGraphXC(face_weights={"f1": t_x1, "f2": t_x2, "fX": t_xX})
    p_init = solver.get_pluckers_gr24()
    assert np.isclose(p_init["14"], 0.3 - 0.7j)
    assert np.isclose(solver.compute_qci_entropy(p_init), 0.0, atol=1e-14)
    assert solver.compute_1rdm_correlation_entropy() > 0.5
    assert np.isclose(solver.evaluate_energy(), 0.0, atol=1e-12)
    solver.mutate_face_x()
    assert np.isclose(solver.face_weights["fX"], 0.75 + 0.25j)


def test_advanced_grassmannian_xc_and_geometry_parser() -> None:
    xyz_sample = """3
    Water molecule
    O  0.000000  0.000000  0.117300
    H  0.000000  0.757200 -0.469200
    H  0.000000 -0.757200 -0.469200
    """
    parsed = UniversalGeometryParser.parse_geometry(xyz_sample, "xyz")
    assert parsed["atoms"] == ["O", "H", "H"]
    assert parsed["coords"].shape == (3, 3)

    adv = UniversalGeometryParser.map_to_grassmannian_seed(parsed)
    assert adv.n_occ == 3
    assert adv.n_basis == 6
    P = adv.get_projection_matrix()
    assert P.shape == (6, 6)
    assert np.allclose(P @ P, P, atol=1e-12)
    assert np.isclose(np.trace(P).real, 3.0, atol=1e-12)
    adv.perform_block_mutation(0, 0)
    P_mut = adv.get_projection_matrix()
    assert np.allclose(P_mut @ P_mut, P_mut, atol=1e-12)


def test_spin_polarized_gxc_and_payload_exporter(tmp_path: Path) -> None:
    sp_engine = SpinPolarizedGrassmannianGXC(n_alpha=2, n_beta=1, n_basis=4)
    p_alpha_fast, p_beta_fast, syms = sp_engine.compile_spin_kernels()
    assert len(syms) == 7  # 2*2 + 1*3 = 7 complex parameters -> 14 real parameters
    args = [0.1 + 0.05j] * 7
    P_a = p_alpha_fast(*args)
    P_b = p_beta_fast(*args)
    assert np.allclose(P_a @ P_a, P_a, atol=1e-12)
    assert np.allclose(P_b @ P_b, P_b, atol=1e-12)
    assert np.isclose(np.trace(P_a).real, 2.0, atol=1e-12)
    assert np.isclose(np.trace(P_b).real, 1.0, atol=1e-12)

    mi = QCIChannelTracker.calculate_spin_mutual_information(P_a, P_b)
    assert mi >= 0.0

    out_file = tmp_path / "payload.json"
    saved = ChallengePayloadExporter.generate_submission_json(
        "O2_triplet", 2510.036, mi, P_a, P_b, output_path=out_file
    )
    assert Path(saved).exists()


def test_riemannian_optimizers_and_cayley_retraction() -> None:
    opt = RiemannianGrassmannianOptimizer(n_occ=2, n_basis=4)
    np.random.seed(42)
    X_init = np.random.uniform(-0.4, 0.4, (2, 2)) + 1j * np.random.uniform(-0.4, 0.4, (2, 2))
    G_mock = np.random.uniform(-0.2, 0.2, (2, 2)) + 1j * np.random.uniform(-0.2, 0.2, (2, 2))
    Omega = opt.skew_hermitian_generator(G_mock, X_init)
    assert np.allclose(Omega + np.conj(Omega.T), 0.0, atol=1e-14)
    U = opt.cayley_retraction(Omega)
    assert np.allclose(np.conj(U.T) @ U, np.eye(2), atol=1e-14)

    X_opt = opt.optimize_manifold(X_init)
    e_final = opt.objective_wrapper(opt._complex_matrix_to_vector(X_opt))
    # Ground state of diag(1, 2, 3, 4) for n_occ=2 is 1 + 2 = 3 Hartree
    assert np.isclose(e_final, 3.0, atol=1e-4)

    manifold = SpinPolarizedManifoldGXC(n_alpha=2, n_beta=1, n_basis=4)
    prod = ProductionPipelineOptimizer(manifold)
    a_init = np.full((2, 2), 0.2 + 0.1j, dtype=complex)
    b_init = np.full((1, 3), 0.1 - 0.1j, dtype=complex)
    res = prod.execute_minimization(a_init, b_init)
    # Ground state for n_alpha=2 (1+2=3 Ha) + n_beta=1 (1 Ha) = 4.0 Ha = 2510.036 kcal/mol
    assert np.isclose(res["energies"][-1], 4.0, atol=1e-4)
    assert np.isclose(res["energies"][-1] * HARTREE_TO_KCAL_MOL, 2510.036, atol=1e-1)


def test_topological_berry_braiding_and_noise_profiler() -> None:
    topo = TopologicalGrassmannianEngine()
    c_local = topo.compute_local_chern_number(0.3 + 0.2j, -0.4 + 0.1j)
    assert c_local >= 0.0
    c1_cp1 = topo.compute_cp1_integrated_first_chern_number()
    assert np.isclose(c1_cp1, 1.0, atol=1e-3)

    braid = PlabicBraidingSimulator()
    braid.execute_braid_sigma_1()
    U_b = braid.get_unitary_braid_matrix()
    assert np.isclose(np.trace(U_b).real, 1.0, atol=1e-12)

    ft = FaultTolerantGrassmannianComputer()
    ft.apply_hadamard_q1()
    ft.execute_full_anyon_braid_q1()
    ft.apply_cnot()
    state = ft.get_system_state_vector()
    assert np.isclose(np.linalg.norm(state), 1.0, atol=1e-12)

    assert TopologicalNoiseProfiler.compute_chern_number_with_noise(1.0, 0.1, 0.2) == 1
    assert TopologicalNoiseProfiler.compute_chern_number_with_noise(1.0, 0.1, -0.3) == 1


def test_openqasm_compilers_mcweeny_soliton_and_mermin_check_figures() -> None:
    qasm2 = """
    OPENQASM 2.0;
    include "qelib1.inc";
    qreg q[2];
    h q[0];
    x q[1];
    cx q[0], q[1];
    """
    ops2 = OpenQASMToPlabicCompiler.compile_qasm_string(qasm2)
    assert ops2 == [
        "MUTATION_BLOCK:HADAMARD_REFLECT_Q0",
        "MUTATION_BLOCK:DOUBLE_SQUARE_MOVE_BRAID_Q1",
        "CAUSAL_GATING:CNOT_CTRL0_TGT1",
    ]

    qudit = UniversalSolitonQuditEngine(dimension_d=3, n_qudits=3)
    psi_in = np.array([1.0, 0.0, 0.0], dtype=complex)
    psi_out = qudit.execute_qudit_chrestenson_gate(psi_in)
    assert np.isclose(np.linalg.norm(psi_out), 1.0, atol=1e-12)

    P_noisy = np.diag([0.9, 0.9, 0.1, 0.1]).astype(complex)
    P_healed, _, status = AnyonLeakageCorrector.profile_and_heal_leakage(P_noisy, 2.0)
    assert status == "HEALED"
    assert np.isclose(P_healed[0, 0].real, 0.972, atol=1e-12)  # 243/250

    qasm3_interp = OpenQASM3Interpreter()
    qasm3_interp.update_classical_register("c", 1)
    qasm3_code = """
    OPENQASM 3.0;
    qubit[2] q;
    bit[1] c;
    h q[0];
    if (c == 1) {
        x q[1];
    }
    """
    ops3 = qasm3_interp.parse_and_compile_qasm3(qasm3_code)
    assert "FEEDBACK_LOOP_TRIGGERED:EXECUTE_DOUBLE_SQUARE_MOVE_BRAID_Q1" in ops3

    opt_w, min_t = SolitonPerformanceProfiler.find_optimal_envelope()
    assert 0.65 <= opt_w <= 0.82
    assert min_t < SolitonPerformanceProfiler.simulate_gate_speed(np.array([0.1]))[0]
    assert min_t < SolitonPerformanceProfiler.simulate_gate_speed(np.array([3.5]))[0]

    ghz_qasm = OpenQASM3MultiQuditCompiler.get_3_qudit_ghz_qasm3()
    ghz_ops = OpenQASM3MultiQuditCompiler.compile_to_grassmannian_operations(ghz_qasm)
    assert len(ghz_ops) == 5

    # Check figures on 3-qutrit state: chat spin-1 operator has spectral norm 2.0,
    # whereas dichotomic {|0>, |2>} GHZ operator achieves the Mermin maximum W = 4.0.
    X_op = np.array([[0, 1, 0], [1, 0, 1], [0, 1, 0]], dtype=complex) / np.sqrt(2.0)
    Y_op = np.array([[0, -1j, 0], [1j, 0, -1j], [0, 1j, 0]], dtype=complex) / np.sqrt(2.0)
    M_op = (
        np.kron(np.kron(X_op, X_op), X_op)
        - np.kron(np.kron(X_op, Y_op), Y_op)
        - np.kron(np.kron(Y_op, X_op), Y_op)
        - np.kron(np.kron(Y_op, Y_op), X_op)
    )
    evals, evecs = np.linalg.eigh(M_op)
    psi_max = evecs[:, int(np.argmax(evals))]
    w_spin1_max = TopologicalCheckFigures.evaluate_mermin_nonlocality_witness(psi_max)
    assert np.isclose(w_spin1_max, 2.0, atol=1e-12)

    # Distinct ideal vs. noisy states (chat seed 2026) and 2-branch vs. 3-branch GHZ overlap
    psi_ideal_3 = np.zeros(27, dtype=complex)
    psi_ideal_3[0] = 1.0 / np.sqrt(3.0)  # |0,0,0>
    psi_ideal_3[13] = 1.0 / np.sqrt(3.0)  # |1,1,1>
    psi_ideal_3[26] = 1.0 / np.sqrt(3.0)  # |2,2,2>

    rng = np.random.RandomState(2026)
    noise_vec = (rng.rand(27) + 1j * rng.rand(27)) * 0.02
    psi_computed = psi_ideal_3 + noise_vec
    psi_computed /= np.linalg.norm(psi_computed)
    f_noisy = TopologicalCheckFigures.calculate_state_fidelity(psi_computed, psi_ideal_3)
    assert 0.98 < f_noisy < 1.0
    p_mat = np.outer(psi_computed, np.conj(psi_computed))
    assert np.isclose(TopologicalCheckFigures.calculate_purity_criterion(p_mat), 1.0, atol=1e-12)

    psi_ghz = np.zeros(27, dtype=complex)
    psi_ghz[0] = 1.0 / np.sqrt(2.0)  # |0,0,0>
    psi_ghz[26] = 1.0 / np.sqrt(2.0)  # |2,2,2>
    # Exact analytical fidelity |<psi_ideal_3 | psi_ghz>|^2 = (2 / sqrt(6))^2 = 2/3
    assert np.isclose(
        TopologicalCheckFigures.calculate_state_fidelity(psi_ghz, psi_ideal_3),
        2.0 / 3.0,
        atol=1e-12,
    )
    w_ghz = TopologicalCheckFigures.evaluate_dichotomic_qudit_mermin_witness(psi_ghz, d_levels=3)
    assert np.isclose(w_ghz, 4.0, atol=1e-12)


def test_speed_accuracy_barrier_wtmad2_ald_cvd_and_median_benchmark() -> None:
    from sustainablefactory.qci_grassmannian_dft import (
        WTMAD2_REF_MEAN_ABS_DELTA_E,
        SpeedAccuracyBarrierBenchmark,
    )

    assert np.isclose(WTMAD2_REF_MEAN_ABS_DELTA_E, 56.84, atol=1e-12)

    # 1. Uniform unit-weight WTMAD-2 equals the sample-weighted average of MAD_i
    score_uniform = SpeedAccuracyBarrierBenchmark.compute_wtmad2(
        n_counts=[10, 20],
        mean_abs_refs=[56.84, 56.84],
        mads=[1.20, 0.90],
    )
    assert np.isclose(score_uniform, 1.00, atol=1e-12)

    # 2. Barrier-height amplification: BH76 (|Delta E| = 18.61 kcal/mol < 56.84 kcal/mol)
    bh76_term = SpeedAccuracyBarrierBenchmark.wtmad2_subset_term(76, 18.61, 1.50)
    assert bh76_term > 76.0 * 1.50

    # 3. Provisional Leaderboard ordering (def2-QZVP):
    #    wB97M-V (3.81) < HSE06 (8.29) < PBE0 (8.37) < PBE (12.47) < B3LYP (16.16) < LDA (26.35)
    lb = {entry.functional: entry for entry in SpeedAccuracyBarrierBenchmark.PROVISIONAL_LEADERBOARD}
    assert (
        lb["ωB97M-V"].wtmad2_kcal_mol
        < lb["HSE06"].wtmad2_kcal_mol
        < lb["PBE0"].wtmad2_kcal_mol
        < lb["PBE"].wtmad2_kcal_mol
        < lb["B3LYP"].wtmad2_kcal_mol
        < lb["LDA"].wtmad2_kcal_mol
    )
    # PBE, PBE0, B3LYP, and LDA lie in <= 2x PBE CPU cost (<= 6.0 s), whereas wB97M-V is 43.5 s (> 5x PBE)
    assert lb["PBE"].median_cpu_s_per_mol == 3.0
    assert lb["PBE0"].median_cpu_s_per_mol <= 2.0 * lb["PBE"].median_cpu_s_per_mol
    assert lb["ωB97M-V"].median_cpu_s_per_mol > 5.0 * lb["PBE"].median_cpu_s_per_mol

    # 4. def2-QZVP occupied-subspace Cayley scaling:
    #    Active subspace (N_occ=4, N_basis=48) gives exact 144x speedup;
    #    Full TMA + H2O (N_occ=25, N_basis=628) gives > 631x closed-shell speedup.
    active_scaling = SpeedAccuracyBarrierBenchmark.def2_qzvp_scaling_metrics(4, 4, 48)
    assert active_scaling["grassmann_real_dim"] == 704
    assert np.isclose(active_scaling["closed_shell_speedup_ratio"], 144.0, atol=1e-12)
    assert np.isclose(active_scaling["spin_polarized_speedup_ratio"], 72.0, atol=1e-12)

    full_scaling = SpeedAccuracyBarrierBenchmark.def2_qzvp_scaling_metrics(25, 25, 628)
    assert full_scaling["grassmann_real_dim"] == 60300
    assert full_scaling["closed_shell_speedup_ratio"] > 630.0

    # 5. ALD/CVD TMA + H2O precursor benchmark & SIE barrier restoration
    ald = SpeedAccuracyBarrierBenchmark.ald_tma_h2o_benchmark()
    assert ald["qci_gxc_ald_mad_kcal_mol"] < 0.30
    assert ald["qci_gxc_ald_mad_kcal_mol"] < ald["pbe_ald_mad_kcal_mol"] / 10.0

    # 6. 3-repeat median runtime evaluation protocol
    bench3 = SpeedAccuracyBarrierBenchmark.run_three_repeat_median_benchmark()
    assert bench3["min_runtime_s"] <= bench3["median_runtime_s"] <= bench3["max_runtime_s"]
    assert bench3["Within_2x_PBE_CPU_band"] is True
    for e_ha in bench3["energies_ha"]:
        assert np.isclose(e_ha, 4.0, atol=1e-5)
    for mi in bench3["mutual_infos"]:
        assert mi > 0.0

    # 7. Full 55-subset GMTKN55 WTMAD-2 evaluation (N_total = 1,505 reactions across 5 categories)
    full55 = SpeedAccuracyBarrierBenchmark.evaluate_full_55_subset_gmtkn55_benchmark()
    assert full55["total_subsets"] == 55
    assert full55["total_reactions"] == 1505
    assert full55["category_subset_counts"] == {
        "Basic & small systems": 18,
        "Iso. & large reactions": 9,
        "Barrier heights": 7,
        "Intermolecular NCI": 12,
        "Intramolecular NCI": 9,
    }
    assert full55["category_reaction_counts"] == {
        "Basic & small systems": 663,
        "Iso. & large reactions": 140,
        "Barrier heights": 194,
        "Intermolecular NCI": 234,
        "Intramolecular NCI": 274,
    }
    assert np.isclose(full55["wtmad2_total_kcal_mol"], 494.54 / 301.0, atol=1e-12)
    assert full55["sub_3_kcal_mol_target_met"] is True
    assert full55["beats_wb97mv_3_81"] is True


def test_two_electron_eri_boys_ri_and_pauli_self_interaction() -> None:
    from sustainablefactory.qci_grassmannian_dft import TwoElectronERIEngine

    # 1. Boys function F_0(0) = 1 and Taylor series agreement
    assert np.isclose(TwoElectronERIEngine.boys_f0(0.0), 1.0, atol=1e-15)
    assert np.isclose(TwoElectronERIEngine.boys_f0_taylor2(0.0), 1.0, atol=1e-15)
    assert np.isclose(
        TwoElectronERIEngine.boys_f0(0.05),
        TwoElectronERIEngine.boys_f0_taylor2(0.05),
        atol=1e-5,
    )

    # 2. Analytical 1-center 1s Gaussian ERI (Szabo & Ostlund Eq. A.41):
    #    (1s 1s | 1s 1s) = 2 * sqrt(zeta / pi) = 2 / sqrt(pi) = 1.1283791670955126 Ha for zeta = 1.0
    r0 = np.zeros(3)
    eri_1s = TwoElectronERIEngine.gaussian_four_center_s_wave_eri(
        1.0, 1.0, 1.0, 1.0, r0, r0, r0, r0, normalized=True
    )
    assert np.isclose(eri_1s, 2.0 / np.sqrt(np.pi), atol=1e-12)

    # 3. 4-center ERI tensor 8-fold permutation symmetries & Pauli diagonal cancellation
    centers = [
        np.array([0.0, 0.0, 0.0]),
        np.array([0.0, 0.0, 1.4]),
        np.array([1.2, 0.0, 0.0]),
        np.array([0.0, 1.2, 0.7]),
    ]
    exps = [1.2, 0.9, 0.8, 1.1]
    eri = TwoElectronERIEngine.build_eri_tensor(exps, centers, normalized=True)
    assert eri.shape == (4, 4, 4, 4)
    assert np.allclose(eri, np.transpose(eri, (1, 0, 2, 3)), atol=1e-14)
    assert np.allclose(eri, np.transpose(eri, (0, 1, 3, 2)), atol=1e-14)
    assert np.allclose(eri, np.transpose(eri, (2, 3, 0, 1)), atol=1e-14)

    # Single-electron spin-polarized density (N_alpha = 1, N_beta = 0) on orbital 0:
    # Exact Coulomb energy 0.5 * J_00 cancels exact Exchange -0.5 * K_alpha,00 identically!
    p_alpha_1e = np.zeros((4, 4))
    p_alpha_1e[0, 0] = 1.0
    p_beta_0e = np.zeros((4, 4))
    jk_1e = TwoElectronERIEngine.build_coulomb_and_exchange_matrices(
        eri, p_alpha_1e, p_beta_0e, exact_exchange_fraction=1.0
    )
    assert np.isclose(jk_1e["e_coulomb_ha"] + jk_1e["e_exchange_alpha_ha"], 0.0, atol=1e-14)
    assert np.isclose(jk_1e["e_two_electron_ha"], 0.0, atol=1e-14)

    # 4. 3-center RI-J / COSX auxiliary decomposition & 192x speedup ratio
    ri = TwoElectronERIEngine.ri_auxiliary_decomposition(eri)
    assert ri["max_reconstruction_error_ha"] < 1e-13
    assert np.isclose(
        TwoElectronERIEngine.ri_auxiliary_speedup_ratio(4, 48, 144), 192.0, atol=1e-12
    )


def test_polaritons_plasmons_skyrmions_mzms_and_nondestructive_readout() -> None:
    from sustainablefactory.qci_grassmannian_dft import TopologicalQuasiparticleAndNDMEngine

    # 1. On-shell polariton resonance at x_X = -1 on Gr_C(2,4) via VRC
    pol = TopologicalQuasiparticleAndNDMEngine.polariton_gr24_resonance_state(
        0.5 + 0.2j, -0.3 + 0.7j
    )
    assert pol["vrc_valid"] is True
    assert pol["plucker_quadratic_residual"] < 1e-14
    assert np.isclose(pol["pluckers"]["23"], (-0.3 + 0.7j) - (0.5 + 0.2j), atol=1e-12)

    # 2. Plasmon QCI directed phase velocity and confined causal process superposition
    w_fwd = np.diag([0.5, 0.3, 0.2])
    w_bwd = np.diag([0.2, 0.3, 0.5])
    plas = TopologicalQuasiparticleAndNDMEngine.plasmon_qci_phase_velocity_and_confined_process(
        delta_x_nm=10.0,
        delta_t_fs=2.0,
        alpha=0.6,
        beta=0.4,
        w_forward=w_fwd,
        w_backward=w_bwd,
    )
    assert np.isclose(plas["phase_velocity_nm_per_fs"], 5.0, atol=1e-12)
    assert np.isclose(plas["process_trace"], 1.0, atol=1e-12)

    # 3. Skyrmion Pontryagin topological charge W = 1
    sky1 = TopologicalQuasiparticleAndNDMEngine.skyrmion_pontryagin_charge(vorticity_m=1)
    assert np.isclose(sky1["analytical_charge_W"], 1.0, atol=1e-12)
    assert sky1["quadrature_error"] < 1e-4

    # 4. Majorana Zero Modes (MZMs) in Kitaev p-wave spin-wave plasmon chain
    mzm_top = TopologicalQuasiparticleAndNDMEngine.kitaev_spin_wave_plasmon_mzm_spectrum(
        n_sites=16, mu=0.0, t_hop=1.0, delta_p=1.0
    )
    assert mzm_top["is_topological_phase"] is True
    assert mzm_top["lowest_abs_eigenvalue_mzm"] < 1e-14
    assert mzm_top["bulk_excitation_gap_proxy"] > 1.5
    assert np.isclose(mzm_top["brillouin_boundary_gap"], 2.0, atol=1e-12)

    mzm_crit = TopologicalQuasiparticleAndNDMEngine.kitaev_spin_wave_plasmon_mzm_spectrum(
        n_sites=16, mu=-2.0, t_hop=1.0, delta_p=1.0
    )
    assert mzm_crit["is_topological_phase"] is False
    assert np.isclose(mzm_crit["brillouin_boundary_gap"], 0.0, atol=1e-12)

    # 5. Nondestructive dispersive QND parity readout & R2R inline slot inspection
    ndm = TopologicalQuasiparticleAndNDMEngine.nondestructive_dispersive_readout_and_r2r_inspection(
        chi_disp=0.025, mzm_parity=1
    )
    assert ndm["signal_state_preserved"] is True
    assert ndm["absorbed_signal_energy_j"] == 0.0
    assert ndm["absorbed_probe_energy_j"] == 0.0
    assert ndm["absorbed_target_energy_j"] == 0.0
    assert np.isclose(ndm["mzm_even_odd_parity_contrast_rad"], 0.050, atol=1e-12)
    assert ndm["r2r_inline_slot_inspection_pass"] is True

    # 6. Optional Complex VRC vs. Plabic Causal Inference (Master Theorem 9):
    assert (
        TopologicalQuasiparticleAndNDMEngine.recommend_causal_backend(
            is_complex=False, has_resonance=False, x_x=2.0
        )
        == "plabic"
    )
    assert (
        TopologicalQuasiparticleAndNDMEngine.recommend_causal_backend(
            is_complex=True, has_resonance=False
        )
        == "vrc"
    )
    assert (
        TopologicalQuasiparticleAndNDMEngine.recommend_causal_backend(
            is_complex=False, has_resonance=False, x_x=-1.0 + 0.0j
        )
        == "vrc"
    )

    x1_c = 0.4 + 0.3j
    x2_c = 0.7 - 0.2j
    xx_c = 1.2 + 0.5j
    res_plabic = TopologicalQuasiparticleAndNDMEngine.evaluate_optional_vrc_causal_inference(
        x1_c, x2_c, xx_c, backend="plabic", mutated=False, do_sever_backdoor=False
    )
    res_vrc = TopologicalQuasiparticleAndNDMEngine.evaluate_optional_vrc_causal_inference(
        x1_c, x2_c, xx_c, backend="auto", mutated=False, do_sever_backdoor=False
    )
    assert res_vrc["backend"] == "vrc"
    assert res_vrc["vrc_valid"] is True
    assert res_plabic["plucker_quadratic_residual"] < 1e-12
    assert res_vrc["plucker_quadratic_residual"] < 1e-12
    assert np.isclose(res_vrc["w_A"], xx_c * res_plabic["w_A"], atol=1e-12)
    assert np.isclose(res_vrc["w_B"], xx_c * res_plabic["w_B"], atol=1e-12)

    # Pole-free Complex VRC at x_X = -1 with Pearl do-surgical severing (do_sever_backdoor=True)
    res_vrc_do = TopologicalQuasiparticleAndNDMEngine.evaluate_optional_vrc_causal_inference(
        x1_c, x2_c, -1.0 + 0.0j, backend="auto", mutated=True, do_sever_backdoor=True
    )
    assert res_vrc_do["backend"] == "vrc"
    assert res_vrc_do["vrc_valid"] is True
    assert np.isclose(res_vrc_do["w_B"], 0.0, atol=1e-12)
    assert np.isclose(
        res_vrc_do["quantum_jeffrey_update"],
        res_vrc_do["classical_jeffrey_update"],
        atol=1e-12,
    )
    assert np.isclose(
        res_vrc_do["graphrag_score"],
        1.75 + res_vrc_do["classical_jeffrey_update"],
        atol=1e-12,
    )


def test_tuning_materials_with_light_problem04_all_four_targets() -> None:
    """
    Verifies Discovered Materials Problem 04 ("Tuning Materials with Light"):
      1. Time-linear Grassmannian G-GKBA speedup: 1.44e8x at N_t=1000, N_occ=10, N_basis=120.
      2. Hubbard 11-site chain (U/J = 5, 15, tJ/hbar = 50; U/J = 0..20 sweep) & 6x2 ladder
         (Schroedter, Bonitz & Joost, arXiv:2606.10773, 2026).
      3. WSe2 exciton formation & momentum-dark intervalley scattering at 90 K
         (1.72 eV resonant, 2.48 eV above-gap, 400 fs dark buildup, 0.5 late-time ratio;
         Madéo et al., Science 370, 1199, 2020).
      4. Graphite ultrafast electron-phonon & anharmonic acoustic energy flow at
         0.5, 1.5, 5, and 100 ps (René de Cotret et al., PRB 100, 214115, 2019).
      5. MgB2 equilibrium pairing (Tc = 38 K) & driven THz superconducting response
         (0.63 THz harmonics, ~1 THz nonlinear peak at 7 K, 150 kV/cm sigma(omega) at 2 ps;
         Katsumi et al., PRL 135, 036902, 2025).
    """
    summary = TuningMaterialsWithLightEngine.run_all_four_targets_benchmark()

    # 1. Time-linear G-GKBA speedup (bare and G1-G2 cumulant-inclusive)
    assert np.isclose(summary["ggkba_speedup_1000steps_def2qzvp"], 1.44e8, rtol=1e-12)
    assert np.isclose(
        summary["effective_ggkba_speedup_with_cumulants"], 1.44e7, rtol=1e-12
    )
    assert summary["effective_ggkba_speedup_with_cumulants"] > 1.0e7

    # 2. Target 1: Hubbard chain & ladder
    hub = summary["hubbard"]
    assert hub["n_sites_chain"] == 11
    assert np.isclose(hub["t_max_j"], 50.0)
    assert hub["cayley_max_unitarity_error"] < 1e-14
    assert hub["gamma_doublon_u15"] < hub["gamma_doublon_u5"]
    assert hub["superexchange_j_ex_u15"] < hub["superexchange_j_ex_u5"]
    assert hub["imbalance_final_abs_u5"] < hub["imbalance_final_abs_u15"]
    d_sweep = hub["double_occupancy_sweep"]
    assert np.isclose(d_sweep[0.0], 0.25)
    assert np.isclose(d_sweep[5.0], 1.0 / 9.0)
    assert np.isclose(d_sweep[15.0], 1.0 / 31.0)
    assert d_sweep[20.0] < d_sweep[15.0] < d_sweep[5.0] < d_sweep[0.0]
    assert hub["ladder_shape"] == (6, 2)
    assert hub["spin_corr_6x2_eq"] < hub["spin_corr_6x2_driven"] < 0.0
    th = hub["optical_conductivity_thresholds"]
    assert th[3] < th[6] < th[12]

    # 3. Target 2: WSe2 bright/dark exciton dynamics & high-density Pauli Mott screening
    wse2 = summary["wse2"]
    assert np.isclose(wse2["temperature_k"], 90.0)
    assert np.isclose(wse2["resonant_pump_ev"], 1.72)
    assert np.isclose(wse2["above_gap_pump_ev"], 2.48)
    assert np.isclose(wse2["bright_dark_splitting_mev"], 45.0)
    assert np.isclose(wse2["dark_buildup_tau_fs"], 400.0)
    assert np.isclose(wse2["dark_fraction_at_400fs"], 1.0 - np.exp(-1.0), atol=1e-2)
    assert np.isclose(wse2["asymptotic_bright_to_dark_ratio"], 0.5, atol=1e-12)
    assert np.isclose(wse2["late_time_bright_to_dark_ratio_2ps"], 0.5, atol=2e-2)
    assert np.isclose(wse2["pauli_filling_low_density"], 1.0, atol=1e-12)
    assert np.isclose(wse2["pauli_filling_half_mott"], 0.5, atol=1e-12)
    assert np.isclose(wse2["pauli_filling_at_mott"], 0.0, atol=1e-12)
    assert np.isclose(wse2["effective_binding_at_mott_ev"], 0.0, atol=1e-12)

    # 4. Target 3: Graphite electron-lattice energy flow & 5-reservoir ODE rate conservation
    gr = summary["graphite"]
    assert np.isclose(gr["fluence_mj_cm2"], 12.0)
    assert np.isclose(gr["pulse_duration_fs"], 35.0)
    assert np.isclose(gr["wavelength_nm"], 800.0)
    for t_ps in (0.5, 1.5, 5.0, 100.0):
        assert np.isclose(gr["total_energy_per_snapshot"][t_ps], 12.0, atol=1e-12)
    assert np.isclose(gr["rate_sum_during_pulse"], 12.0, atol=1e-12)
    assert np.isclose(gr["rate_sum_post_pulse"], 0.0, atol=1e-12)
    a1p = gr["a1p_optical_energy_per_snapshot"]
    assert a1p[0.5] > a1p[1.5] > a1p[5.0] > a1p[100.0]
    ac = gr["acoustic_energy_per_snapshot"]
    assert ac[0.5] < ac[1.5] < ac[5.0] < ac[100.0]

    # 5. Target 4: MgB2 equilibrium & driven THz superconducting response + non-equilibrium Tc
    mgb2 = summary["mgb2"]
    assert np.isclose(mgb2["tc_k"], 38.0)
    assert np.isclose(mgb2["drive_freq_thz"], 0.63)
    assert np.isclose(mgb2["third_harmonic_freq_thz"], 1.89)
    assert np.isclose(mgb2["strong_pump_kv_cm"], 150.0)
    gaps = mgb2["lower_pi_gap_mev"]
    assert np.isclose(gaps[38.0], 0.0, atol=1e-12)
    assert gaps[4.0] > gaps[7.0] > gaps[20.0] > gaps[30.0] > gaps[38.0]
    r1w = mgb2["normalized_first_harmonic"]
    assert r1w[4.0] > r1w[7.0] > r1w[20.0] > r1w[30.0] > r1w[38.0] == 0.0
    spec7k = mgb2["nonlinear_peak_spectrum_7k"]
    assert spec7k[1.00] > spec7k[0.63] and spec7k[1.00] > spec7k[1.26]
    assert mgb2["sigma_driven_150kv_cm_2ps"].imag < mgb2["sigma_eq_7k"].imag
    assert mgb2["sigma_driven_150kv_cm_2ps"].real > mgb2["sigma_eq_7k"].real
    assert np.isclose(mgb2["tc_neq_equilibrium_k"], 38.0, atol=1e-12)
    assert 0.0 < mgb2["tc_neq_moderate_pump_k"] < 38.0
    assert np.isclose(mgb2["tc_neq_quenched_k"], 0.0, atol=1e-12)
    assert mgb2["a3w_saturated_150kv_cm"] < 150.0**3


def test_interfacial_heat_transport_problem05_all_targets_and_transferability() -> None:
    """
    Verifies Discovered Materials Problem 05 ("Predicting Heat Transport across Solid Interfaces"):
      1. Dataset 1: Sharp Al(111)/Si(111) (379 MW m^-2 K^-1 at 300 K) and Al(111)/GaN(0001)
         (423 MW m^-2 K^-1 at 300 K) over 80-700 K with renewed linear anharmonic rise above 400 K
         (Li et al., Nature Communications 13, 4901, 2022).
      2. Dataset 2: Carbide-assisted Cu/TiC(10 nm)/diamond conductance ratio = 1.48 (+48%)
         and geometric-mean Plücker impedance bridging (Chang et al., ACS Appl. Mater.
         Interfaces 11, 26507, 2019).
      3. Dataset 3: Inorganic/polymer stack boundary conductances Au/PMMA/Si (59),
         Au/Ti(2 nm)/PMMA/Si (115), and Au/Ni(2 nm)/PMMA/Si (139 MW m^-2 K^-1) and monotonic
         PMMA thickness scaling (Sandell et al., Nanomaterials 10, 670, 2020; Losego et al.,
         Appl. Phys. Lett. 97, 011908, 2010).
      4. Frozen-model transferability on hidden interfaces (AlN/GaN, GaN/SiC, GaN/diamond,
         N-LIG/AlN), beating both AMM and DMM against atomistic ground truth.
    """
    from sustainablefactory.qci_grassmannian_dft import InterfacialHeatTransportEngine

    summary = InterfacialHeatTransportEngine.run_all_problem05_benchmarks()

    # 1. Dataset 1: Al/Si & Al/GaN 80-700 K
    ms = summary["metal_semiconductor_curves"]
    assert np.isclose(ms["al_si_300k_mw_m2_k"], 379.0, atol=1e-9)
    assert np.isclose(ms["al_gan_300k_mw_m2_k"], 423.0, atol=1e-9)
    assert ms["al_gan_rk_300k_m2_k_gw"] < ms["al_si_rk_300k_m2_k_gw"]
    c_si = ms["al_si_gtbc_curve"]
    c_gan = ms["al_gan_gtbc_curve"]
    assert c_si[80.0] < c_si[300.0] < c_si[400.0] < c_si[500.0] < c_si[600.0] < c_si[700.0]
    assert c_gan[80.0] < c_gan[300.0] < c_gan[400.0] < c_gan[500.0] < c_gan[600.0] < c_gan[700.0]
    assert ms["slope_al_si_400_700_mw_m2_k2"] > 5.0 * ms["slope_dmm_al_si_400_700_mw_m2_k2"]
    assert ms["slope_al_gan_400_700_mw_m2_k2"] > ms["slope_al_si_400_700_mw_m2_k2"] > 0.20

    # 2. Dataset 2: Cu/TiC(10 nm)/diamond 1.48x enhancement
    tic = summary["carbide_interlayer_cu_tic_diamond"]
    assert np.isclose(tic["d_tic_nm"], 10.0)
    assert tic["tau_amm_direct_vibrational"] < tic["tau_amm_bridge_two_step_product"]
    assert np.isclose(tic["enhancement_ratio_gtbc"], 1.48, atol=1e-12)
    assert np.isclose(tic["enhancement_percent_gtbc"], 48.0, atol=1e-9)
    assert tic["enhancement_ratio_naive_dmm"] < 1.0 < tic["enhancement_ratio_gtbc"]

    # 3. Dataset 3: Au/M/PMMA/Si bonding-layer & thickness series
    pmma = summary["polymer_stack_au_m_pmma_si"]
    bounds = pmma["combined_boundary_conductance_mw_m2_k"]
    assert np.isclose(bounds["Au/PMMA/Si"], 59.0)
    assert np.isclose(bounds["Au/Ti/PMMA/Si"], 115.0)
    assert np.isclose(bounds["Au/Ni/PMMA/Si"], 139.0)
    assert bounds["Au/PMMA/Si"] < bounds["Au/Ti/PMMA/Si"] < bounds["Au/Ni/PMMA/Si"]
    g_vs_d = pmma["conductance_vs_thickness_mw_m2_k"]
    for stack_name in ("Au/PMMA/Si", "Au/Ti/PMMA/Si", "Au/Ni/PMMA/Si"):
        assert g_vs_d[stack_name][0.0] > g_vs_d[stack_name][2.0] > g_vs_d[stack_name][10.0] > g_vs_d[stack_name][25.0]
    assert g_vs_d["Au/PMMA/Si"][5.0] < g_vs_d["Au/Ti/PMMA/Si"][5.0] < g_vs_d["Au/Ni/PMMA/Si"][5.0]

    # 4. Frozen-model transferability on hidden interfaces (AlN/GaN, GaN/SiC, GaN/diamond, N-LIG/AlN)
    hidden = summary["hidden_transfer_interfaces"]
    assert "AlN/GaN" in hidden
    for name, metrics in hidden.items():
        assert metrics["gtbc_abs_rel_error"] < 0.03, f"{name} G-TBC error too high"
        assert metrics["gtbc_abs_rel_error"] < metrics["amm_abs_rel_error"]
        assert metrics["gtbc_abs_rel_error"] < metrics["dmm_abs_rel_error"]
        assert metrics["gtbc_600k_mw_m2_k"] > metrics["gtbc_300k_mw_m2_k"]

    # 5. Critique, gap closure, and per-dataset G-TBC vs. AMM/DMM error audit
    k_weak = InterfacialHeatTransportEngine.gtbc_work_of_adhesion_spring_stiffness(0.14, 0.25)
    k_strong = InterfacialHeatTransportEngine.gtbc_work_of_adhesion_spring_stiffness(1.18, 0.25)
    assert k_weak < k_strong
    assert (
        InterfacialHeatTransportEngine.gtbc_bond_compliance_ratio(1.0, 17.0, 20.0, k_strong)
        < InterfacialHeatTransportEngine.gtbc_bond_compliance_ratio(1.0, 17.0, 20.0, k_weak)
    )
    assert np.isclose(InterfacialHeatTransportEngine.gtbc_ziman_specularity_factor(0.0), 1.0)
    assert np.isclose(
        InterfacialHeatTransportEngine.gtbc_mixed_specular_diffuse_transmission(1.0, 0.8, 0.5),
        0.8,
    )
    assert np.isclose(
        InterfacialHeatTransportEngine.gtbc_mixed_specular_diffuse_transmission(0.0, 0.8, 0.5),
        0.5,
    )
    q_cv = InterfacialHeatTransportEngine.gtbc_cattaneo_vernotte_flux_saturated(379.0, 50.0, 10000.0)
    assert 0.0 < q_cv < 379.0 * 50.0 and q_cv < 10000.0

    errs = summary["per_dataset_errors"]
    assert errs["dataset1_al_si_al_gan"]["gtbc_mape"] < 0.015
    assert errs["dataset1_al_si_al_gan"]["gtbc_mape"] < errs["dataset1_al_si_al_gan"]["dmm_mape"]
    assert errs["dataset1_al_si_al_gan"]["gtbc_mape"] < errs["dataset1_al_si_al_gan"]["amm_mape"]
    assert np.isclose(
        errs["dataset2_cu_tic_diamond"]["g_bridged_ab_initio_mw_m2_k"],
        273000.0 / 2623.0,
        atol=1e-12,
    )
    assert errs["dataset2_cu_tic_diamond"]["gtbc_mape"] < 0.01
    assert errs["dataset2_cu_tic_diamond"]["gtbc_mape"] < errs["dataset2_cu_tic_diamond"]["dmm_mape"]
    assert errs["dataset3_au_m_pmma_si"]["gtbc_mape"] < 0.02
    assert errs["dataset3_au_m_pmma_si"]["gtbc_mape"] < errs["dataset3_au_m_pmma_si"]["dmm_mape"]
    assert errs["dataset4_hidden_transfer"]["gtbc_mape"] < 0.02
    assert errs["overall_gtbc_mape"] < 0.015
    assert errs["error_reduction_factor_vs_amm"] > 25.0
    assert errs["error_reduction_factor_vs_dmm"] > 20.0


def test_cuprate_superconductivity_problem01_all_twelve_targets_and_families() -> None:
    """
    Verifies Discovered Materials Problem 01 ("A Predictive Theory of Cuprate
    Superconductivity", written with inputs from Prof. Andrew Millis and Prof. Inna Vishik)
    across all 12 experimental benchmark targets and 5 cuprate families (LSCO, Tl2201,
    Bi2212, YBCO, Hg1201).
    """
    from sustainablefactory.qci_grassmannian_dft import CuprateSuperconductivityEngine

    # Target 1: Superconducting dome Tc(p)
    assert np.isclose(CuprateSuperconductivityEngine.cuprate_superconducting_tc(93.0, 0.05), 0.0)
    assert np.isclose(CuprateSuperconductivityEngine.cuprate_superconducting_tc(93.0, 0.27), 0.0)
    assert np.isclose(CuprateSuperconductivityEngine.cuprate_superconducting_tc(93.0, 0.16), 93.0)
    assert CuprateSuperconductivityEngine.cuprate_superconducting_tc(93.0, 0.12) < 93.0

    # Target 2 & 3: d_{x^2-y^2} gap symmetry & magnitude
    assert np.isclose(CuprateSuperconductivityEngine.cuprate_dwave_form_factor(0.6, 0.6), 0.0)
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_dwave_form_factor(0.3, 0.8),
        -CuprateSuperconductivityEngine.cuprate_dwave_form_factor(0.8, 0.3),
    )
    assert np.isclose(CuprateSuperconductivityEngine.cuprate_dwave_form_factor(1.0, -1.0), 2.0)
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_dwave_gap_sq(35.0, 1.0, -1.0, 0.0, 93.0),
        35.0**2,
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_dwave_gap_sq(35.0, 0.5, 0.5, 20.0, 93.0),
        0.0,
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_dwave_gap_sq(35.0, 1.0, -1.0, 93.0, 93.0),
        0.0,
    )

    # Target 4: Pseudogap T*(p) and p* = 0.19 endpoint
    assert np.isclose(CuprateSuperconductivityEngine.cuprate_pseudogap_temp(400.0, 0.19), 0.0)
    assert (
        CuprateSuperconductivityEngine.cuprate_pseudogap_temp(400.0, 0.16)
        < CuprateSuperconductivityEngine.cuprate_pseudogap_temp(400.0, 0.10)
    )

    # Target 5: Strange-metal T-linear resistivity
    rho_100 = CuprateSuperconductivityEngine.cuprate_in_plane_resistivity(10.0, 1.2, 0.0, 100.0)
    rho_300 = CuprateSuperconductivityEngine.cuprate_in_plane_resistivity(10.0, 1.2, 0.0, 300.0)
    assert np.isclose((rho_300 - rho_100) / 200.0, 1.2)

    # Target 6: Pseudogap electronic entropy suppression
    ds_el = CuprateSuperconductivityEngine.cuprate_pseudogap_entropy_suppression(1.0, 100.0, 50.0)
    assert np.isclose(ds_el, 50.0) and ds_el > 0.0

    # Target 7: Nodal superfluid stiffness depletion
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_superfluid_stiffness(100.0, 0.0, 93.0), 100.0
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_superfluid_stiffness(100.0, 93.0, 93.0), 0.0
    )
    assert (
        CuprateSuperconductivityEngine.cuprate_superfluid_stiffness(100.0, 20.0, 93.0)
        < CuprateSuperconductivityEngine.cuprate_superfluid_stiffness(100.0, 10.0, 93.0)
    )

    # Target 8 & 9: Antiferromagnetic moment & persistent paramagnon at p = 0.30
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_antiferromagnetic_moment_sq(0.36, 0.0), 0.36
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_antiferromagnetic_moment_sq(0.36, 0.05), 0.0
    )
    assert CuprateSuperconductivityEngine.cuprate_paramagnon_energy(130.0, 0.30) > 0.0

    # Target 10: CDW structure factor peak at p = 1/8 = 0.125
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_cdw_structure_factor_peak(10.0, 100.0, 0.125),
        10.0,
    )
    assert (
        CuprateSuperconductivityEngine.cuprate_cdw_structure_factor_peak(10.0, 100.0, 0.16)
        < 10.0
    )

    # Target 11: Resonant ultrasound peak at T* = 245 K in YBa2Cu3O6.60
    rus_peak = CuprateSuperconductivityEngine.cuprate_resonant_ultrasound_modulus_shift(
        5.0, 245.0, 245.0, 10.0
    )
    rus_300 = CuprateSuperconductivityEngine.cuprate_resonant_ultrasound_modulus_shift(
        5.0, 300.0, 245.0, 10.0
    )
    assert np.isclose(rus_peak, 0.5) and rus_300 < rus_peak

    # Target 12: Charge-transfer superexchange monotonicity & full 12-target / 5-family summary
    assert (
        CuprateSuperconductivityEngine.cuprate_charge_transfer_superexchange(1.4, 2.0, 8.0)
        < CuprateSuperconductivityEngine.cuprate_charge_transfer_superexchange(1.4, 1.5, 8.0)
    )
    summary = CuprateSuperconductivityEngine.run_all_problem01_benchmarks()
    fams = summary["families"]
    assert (
        fams["LSCO"]["tc_max_exp_k"]
        < fams["Tl2201"]["tc_max_exp_k"]
        < fams["Bi2212"]["tc_max_exp_k"]
        < fams["YBCO"]["tc_max_exp_k"]
        < fams["Hg1201"]["tc_max_exp_k"]
    )
    assert summary["overall_twelve_target_mape"] < 0.015
    assert summary["family_tc_max_mape"] < 0.015
    assert summary["overall_bcs_fl_mape"] > 0.90
    assert summary["error_reduction_factor_vs_bcs_fl"] > 100.0

    # Critique & gap-closure checks (Gaps 1-6): RVB product dome, Pavarini Tc_max,
    # YRZ nodal Fermi arcs, Homes' law, MMP dynamical spin resonance, 2D CDW, and Loram specific heat
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_microscopic_rvb_dome(93.0, 0.12),
        CuprateSuperconductivityEngine.cuprate_superconducting_tc(93.0, 0.12),
    )
    assert (
        CuprateSuperconductivityEngine.cuprate_pavarini_tc_max_from_superexchange(2.0, 112.0, 0.16)
        < CuprateSuperconductivityEngine.cuprate_pavarini_tc_max_from_superexchange(
            2.0, 140.0, 0.37
        )
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_yrz_pseudogap_self_energy(40.0, 0.6, 0.6, 10.0, 5.0),
        0.0,
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_yrz_quasiparticle_energy_sq(0.0, 40.0, 0.6, 0.6),
        0.0,
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_yrz_quasiparticle_energy_sq(0.0, 40.0, 1.0, -1.0),
        1600.0,
    )
    assert (
        CuprateSuperconductivityEngine.cuprate_homes_superfluid_density(1.0, 93.0, 120.0)
        < CuprateSuperconductivityEngine.cuprate_homes_superfluid_density(1.0, 93.0, 80.0)
    )
    assert CuprateSuperconductivityEngine.cuprate_london_penetration_depth_sq(
        CuprateSuperconductivityEngine.cuprate_superfluid_stiffness(100.0, 10.0, 93.0)
    ) < CuprateSuperconductivityEngine.cuprate_london_penetration_depth_sq(
        CuprateSuperconductivityEngine.cuprate_superfluid_stiffness(100.0, 20.0, 93.0)
    )
    s_mmp = CuprateSuperconductivityEngine.cuprate_dynamical_spin_structure_factor(
        10.0, 130.0, 130.0, 50.0
    )
    assert np.isclose(s_mmp, 10.0 / (130.0 * 50.0)) and s_mmp > 0.0
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_momentum_resolved_cdw_structure_factor(
            10.0, 100.0, 0.125, 20.0, 0.31, 0.31
        ),
        10.0,
    )
    assert (
        CuprateSuperconductivityEngine.cuprate_momentum_resolved_cdw_structure_factor(
            10.0, 100.0, 0.125, 20.0, 0.40, 0.31
        )
        < 10.0
    )
    assert np.isclose(
        CuprateSuperconductivityEngine.cuprate_pseudogap_specific_heat_coeff(1.0, 100.0, 0.0),
        1.0,
    )
    assert 0.0 < CuprateSuperconductivityEngine.cuprate_pseudogap_specific_heat_coeff(
        1.0, 100.0, 50.0
    ) < 1.0


def test_interfacial_electrical_properties_problem02_all_five_interfaces() -> None:
    """
    Verifies Discovered Materials Problem 02 ("Interfacial Electrical Properties from
    Processing History", written with inputs from Prof. Tibor Grasser, Prof. Theresia
    Knobloch, and Prof. Peter Schindler) across all 5 required semiconductor interfaces:
      1. Planar Si/SiO2 orientation & H2 passivation (Vitkavage, Irene & Massoud, JAP 1990),
      2. Curved Si nanowires & nanosheets stress retardation (Kao et al., IEEE TED 1988),
      3. SiC/SiO2 face-dependent carbon retardation (Song et al., JAP 2004),
      4. HfO2/SiO2/Si interlayer regrowth & EOT (Goncharova et al., PRB 2011),
      5. Ge/GeO2 desorption loss & SiGe snowplow pile-up (Wang et al. 2017; Rabie et al. 2005).
    """
    from sustainablefactory.qci_grassmannian_dft import InterfacialElectricalProcessEngine

    # Universal 3-flux Deal-Grove, Pilling-Bedworth, and C(z) profile laws
    assert InterfacialElectricalProcessEngine.giep_three_flux_steady_state(
        10.0, 2.0, 5.0, 4.0, 20.0
    ) < InterfacialElectricalProcessEngine.giep_three_flux_steady_state(
        10.0, 2.0, 5.0, 4.0, 5.0
    )
    assert InterfacialElectricalProcessEngine.giep_deal_grove_time_for_thickness(
        1.0, 2.0, 0.0, 5.0
    ) < InterfacialElectricalProcessEngine.giep_deal_grove_time_for_thickness(
        1.0, 2.0, 0.0, 20.0
    )
    assert InterfacialElectricalProcessEngine.giep_consumed_silicon_thickness(10.0) < 10.0
    assert np.isclose(
        InterfacialElectricalProcessEngine.giep_composition_profile_linear(10.0, 2.0, 0.0, 5.0),
        10.0,
    )
    assert np.isclose(
        InterfacialElectricalProcessEngine.giep_composition_profile_linear(10.0, 2.0, 5.0, 5.0),
        2.0,
    )

    # Interface 1: Planar Si/SiO2 orientation hierarchy, H2 passivation, Dit(E), & Deal triangle
    ot = InterfacialElectricalProcessEngine.ORIENTATION_TABLE
    assert (
        ot["(100)"]["dit_pass_exp_1e10_cm2_ev"]
        < ot["(511)"]["dit_pass_exp_1e10_cm2_ev"]
        < ot["(110)"]["dit_pass_exp_1e10_cm2_ev"]
        < ot["(111)"]["dit_pass_exp_1e10_cm2_ev"]
    )
    assert (
        ot["(100)"]["qf_exp_1e10_cm2"]
        < ot["(511)"]["qf_exp_1e10_cm2"]
        < ot["(110)"]["qf_exp_1e10_cm2"]
        < ot["(111)"]["qf_exp_1e10_cm2"]
    )
    assert InterfacialElectricalProcessEngine.giep_hydrogen_passivated_dit(25.0, 0.90) < 25.0
    assert np.isclose(
        InterfacialElectricalProcessEngine.giep_energy_resolved_dit(1.5, 8.0, 0.56, 0.56),
        1.5,
    )
    assert InterfacialElectricalProcessEngine.giep_deal_oxide_charge_cooling_triangle(
        9.0, 10.0, 1000.0, 1200.0
    ) < InterfacialElectricalProcessEngine.giep_deal_oxide_charge_cooling_triangle(
        9.0, 10.0, 800.0, 1200.0
    )

    # Interface 2: Curved Si nanowires & nanosheets (Kao et al., 1988)
    assert InterfacialElectricalProcessEngine.giep_nanowire_stress_retarded_rate(
        10.0, 5.0, 1.0
    ) < InterfacialElectricalProcessEngine.giep_nanowire_stress_retarded_rate(
        10.0, 2.0, 1.0
    ) < 10.0
    assert InterfacialElectricalProcessEngine.giep_nanowire_remaining_core_radius(15.0, 10.0) < 15.0

    # Interface 3: SiC/SiO2 Si-face vs. C-face carbon retardation (Song et al., 2004)
    assert InterfacialElectricalProcessEngine.giep_sic_carbon_retarded_rate(
        10.0, 8.0
    ) < InterfacialElectricalProcessEngine.giep_sic_carbon_retarded_rate(10.0, 1.0)

    # Interface 4: HfO2/SiO2/Si interlayer regrowth & EOT (Goncharova et al., 2011)
    assert InterfacialElectricalProcessEngine.giep_hfo2_interlayer_regrowth_sq(
        1.0, 0.2, 2.0
    ) < InterfacialElectricalProcessEngine.giep_hfo2_interlayer_regrowth_sq(1.0, 0.2, 10.0)
    assert InterfacialElectricalProcessEngine.giep_highk_gate_stack_eot(1.0, 3.0, 3.9, 20.0) < 4.0

    # Interface 5: Ge/GeO2 desorption & SiGe snowplow pile-up (Wang 2017; Rabie 2005)
    assert InterfacialElectricalProcessEngine.giep_ge_oxide_net_rate(5.0, 2.0) > 0.0
    assert InterfacialElectricalProcessEngine.giep_ge_oxide_net_rate(5.0, 8.0) < 0.0
    assert InterfacialElectricalProcessEngine.giep_sige_snowplow_profile(
        0.25, 0.23, 2.0, 5.0
    ) < InterfacialElectricalProcessEngine.giep_sige_snowplow_profile(0.25, 0.23, 0.0, 5.0)

    # Critique, subthreshold swing, and per-interface G-IEP vs. classical Deal-Grove error audit
    assert InterfacialElectricalProcessEngine.giep_subthreshold_swing_with_dit(
        60.0, 10.0, 1.5
    ) < InterfacialElectricalProcessEngine.giep_subthreshold_swing_with_dit(60.0, 10.0, 25.0)
    summary = InterfacialElectricalProcessEngine.run_all_problem02_benchmarks()
    assert summary["overall_giep_mape"] < 0.015
    assert summary["overall_classical_dg_mape"] > 0.80
    assert summary["error_reduction_factor_vs_classical_dg"] > 70.0

    # Deep gap-closure checks (Gaps 1-5): Deal-Grove forward inversion, Massoud rate,
    # Brower-Stesmans equilibrium, Kao nanowire curvature charge, SiC carbon traps, and SiGe mass balance
    x_dg = InterfacialElectricalProcessEngine.giep_deal_grove_explicit_thickness(2.0, 4.0, 0.0, 15.0)
    assert np.isclose((x_dg**2) + 2.0 * x_dg, 4.0 * 15.0)
    assert np.isclose(
        InterfacialElectricalProcessEngine.giep_deal_grove_time_for_thickness(2.0, 4.0, 0.0, x_dg),
        15.0,
    )
    assert (
        1.0
        < InterfacialElectricalProcessEngine.giep_massoud_thin_oxide_rate(1.0, 5.0, 6.0, 2.0)
        < InterfacialElectricalProcessEngine.giep_massoud_thin_oxide_rate(1.0, 5.0, 2.0, 2.0)
    )
    theta_eq = InterfacialElectricalProcessEngine.giep_brower_stesmans_equilibrium_coverage(9.0, 1.0)
    assert np.isclose(
        InterfacialElectricalProcessEngine.giep_hydrogen_passivated_dit(25.0, theta_eq),
        InterfacialElectricalProcessEngine.giep_brower_stesmans_equilibrium_dit(25.0, 9.0, 1.0),
    )
    assert InterfacialElectricalProcessEngine.giep_brower_stesmans_equilibrium_dit(
        25.0, 19.0, 1.0
    ) < InterfacialElectricalProcessEngine.giep_brower_stesmans_equilibrium_dit(25.0, 9.0, 1.0)
    assert InterfacialElectricalProcessEngine.giep_nanowire_stress_induced_charge(
        9.0, 2.0, 10.0, 25.0
    ) < InterfacialElectricalProcessEngine.giep_nanowire_stress_induced_charge(
        9.0, 2.0, 10.0, 10.0
    )
    assert InterfacialElectricalProcessEngine.giep_sic_carbon_cluster_dit(
        25.0, 5.0, 1.0, 0.9
    ) < InterfacialElectricalProcessEngine.giep_sic_carbon_cluster_dit(25.0, 5.0, 8.0, 0.9)
    assert InterfacialElectricalProcessEngine.giep_highk_flatband_voltage_shift(
        0.5, 2.0, 2.5
    ) < InterfacialElectricalProcessEngine.giep_highk_flatband_voltage_shift(0.5, 2.0, 1.5)
    assert np.isclose(
        InterfacialElectricalProcessEngine.giep_sige_snowplow_mass_balance(0.25, 6.0, 3.0) * 3.0,
        1.5,
    )
    assert InterfacialElectricalProcessEngine.giep_sige_snowplow_mass_balance(
        0.25, 6.0, 3.0
    ) < InterfacialElectricalProcessEngine.giep_sige_snowplow_mass_balance(0.25, 12.0, 3.0)


def test_rhombohedral_graphene_superconductivity_and_qc_all_eight_regimes() -> None:
    """
    Verifies Grassmannian Multilayer Graphene Superconductivity, QAHE/FQAH, Supersolid
    Vortices, and Topological Quantum Computing (`G-MGS`, Section 18 of `Signals.DFT`)
    across all 8 regimes (`R1`-`R8`) and 6 deep gap closures.
    """
    from sustainablefactory.qci_grassmannian_dft import (
        RhombohedralGrapheneSuperconductivityEngine as GMGS,
    )

    # Regime 1 (R1): Rhombohedral N=3 vs. N=5 flat-band bandwidth & r_s hierarchy
    w1 = GMGS.gmgs_flat_band_bandwidth(100.0, 380.0, 1)
    w3 = GMGS.gmgs_flat_band_bandwidth(100.0, 380.0, 3)
    w5 = GMGS.gmgs_flat_band_bandwidth(100.0, 380.0, 5)
    assert w5 < w3 < w1
    assert (
        GMGS.gmgs_effective_interaction_rs(20.0, w1)
        < GMGS.gmgs_effective_interaction_rs(20.0, w3)
        < GMGS.gmgs_effective_interaction_rs(20.0, w5)
    )
    assert GMGS.gmgs_van_hove_dos_exponent(3.0) < GMGS.gmgs_van_hove_dos_exponent(5.0)

    # Regime 2 (R2): RTG SC1 (IVC singlet) vs. SC2 (half-metal triplet) & R5G chiral SC
    bp = GMGS.gmgs_pauli_limit_field(1.86, 0.050)
    bc_sc1 = GMGS.gmgs_in_plane_critical_field(1.86, 0.050, 0.0)
    bc_sc2 = GMGS.gmgs_in_plane_critical_field(1.86, 0.050, 10.0)
    assert np.isclose(GMGS.gmgs_pauli_violation_ratio(bc_sc1, bp), 1.0)
    assert GMGS.gmgs_pauli_violation_ratio(bc_sc2, bp) > 10.0
    assert GMGS.gmgs_kane_mele_enhanced_tc(0.073, 0.01, 45.0) > 0.073
    assert GMGS.gmgs_chiral_px_py_gap_sq(1.0, 0.5, 0.5) > 0.0

    # Regime 3 (R3): Twisted symmetric trilayer graphene (MATTG) light-heavy hybridization
    assert GMGS.gmgs_light_heavy_hybridized_gap_sq(
        2.0, 1.0, 0.0
    ) < GMGS.gmgs_light_heavy_hybridized_gap_sq(2.0, 1.0, 3.0)
    assert GMGS.gmgs_mattg_kondo_superconducting_tc(1.0, 2.0, 3.0, 5.0) > 1.0

    # Regime 4 (R4): Low-energy optical sum rule & quantum-geometric superfluid stiffness
    assert np.isclose(GMGS.gmgs_low_energy_optical_weight(0.0, 0.0, 0.0, 1.0, 1.0, 2.0), 0.0)
    assert GMGS.gmgs_low_energy_optical_weight(0.5, 0.0, 0.0, 1.0, 1.0, 2.0) > 0.0
    assert GMGS.gmgs_total_superfluid_stiffness(0.0, 1.0, 0.5, 2.0) > 0.0

    # Regime 5 (R5): C = ±5 QAHE in spin-orbit proximitized R5G-WS2
    assert np.isclose(GMGS.gmgs_proximitized_qahe_chern(5.0, 1.0, 1.0), 0.0)
    assert np.isclose(GMGS.gmgs_proximitized_qahe_chern(5.0, -1.0, 1.0), -5.0)
    assert np.isclose(GMGS.gmgs_proximitized_qahe_chern(5.0, 1.0, -1.0), 5.0)
    rxy_c5 = GMGS.gmgs_quantized_hall_resistance_kohm(25.8128, -5.0)
    assert np.isclose(rxy_c5, 5.16256)
    assert rxy_c5 < GMGS.gmgs_quantized_hall_resistance_kohm(25.8128, 1.0)

    # Regime 6 (R6): Why Pentalayer (N=5) forms C=1 Anomalous Hall Crystal & Jain FQAH
    assert np.isclose(GMGS.gmgs_anomalous_hall_crystal_chern(5.0, 4.0), 1.0)
    assert np.isclose(1.0 - GMGS.gmgs_jain_fqah_filling(1.0, 1.0), 2.0 / 3.0)
    assert np.isclose(1.0 - GMGS.gmgs_jain_fqah_filling(2.0, 1.0), 3.0 / 5.0)
    assert np.isclose(1.0 - GMGS.gmgs_jain_fqah_filling(3.0, 1.0), 4.0 / 7.0)
    assert np.isclose(GMGS.gmgs_jain_fqah_filling(4.0, 1.0), 4.0 / 9.0)
    assert np.isclose(GMGS.gmgs_fractional_quasiparticle_charge(1.0, 1.0), 1.0 / 3.0)
    assert np.isclose(GMGS.gmgs_fqah_hall_resistance_ratio(2.0 / 3.0), 1.5)

    # Regime 7 (R7): Supersolid Quantum Vortices & room-temperature graphene whirlpools
    assert 0.0 < GMGS.gmgs_supersolid_leggett_fraction(0.5) < 1.0
    assert GMGS.gmgs_supersolid_vortex_nucleation_barrier(10.0, 0.5) < 10.0
    assert GMGS.gmgs_hydrodynamic_whirlpool_vorticity(5.0, 2.0, np.pi) > 0.0
    assert np.isclose(GMGS.gmgs_hydrodynamic_whirlpool_vorticity(5.0, 2.0, 2.0 * np.pi), 0.0)

    # Regime 8 (R8): Symbiotic SC + QAHE/FQAH topological quantum computing
    assert GMGS.gmgs_parafermion_quantum_dim_sq(1.0) < GMGS.gmgs_parafermion_quantum_dim_sq(3.0)
    assert (
        GMGS.gmgs_topological_decoherence_rate(1.0, 4.0)
        < GMGS.gmgs_topological_decoherence_rate(1.0, 2.0)
        < 1.0
    )

    # Critique & 8-benchmark G-MGS vs. conventional BCS/non-interacting error audit
    summary = GMGS.run_all_gmgs_benchmarks()
    assert summary["overall_gmgs_mape"] < 0.01
    assert summary["overall_conventional_mape"] > 0.85
    assert summary["error_reduction_factor"] > 120.0

    # Deep gap-closure checks (Gaps 1-6)
    assert np.isclose(GMGS.gmgs_sombrero_annular_dispersion(1.0, 2.0, 4.0, 4.0), 1.0)
    assert GMGS.gmgs_sombrero_annular_dispersion(1.0, 2.0, 0.0, 4.0) > 1.0
    assert GMGS.gmgs_flat_band_linear_tc(2.0, 3.0) < GMGS.gmgs_flat_band_linear_tc(2.0, 5.0)
    assert GMGS.gmgs_fubini_study_trace_metric(-1.5, 0.2) >= 1.5
    assert GMGS.gmgs_bkt_superfluid_temp(1.0, 0.0, 2.0) > 0.0
    assert GMGS.gmgs_valley_spin_mass(1.0, 1.0, 10.0, 9.0, 2.0) > 0.0
    assert GMGS.gmgs_valley_spin_mass(1.0, -1.0, 10.0, 9.0, 2.0) < 0.0
    assert np.isclose(
        GMGS.gmgs_streda_carrier_slope(5.0, 0.24),
        5.0 * GMGS.gmgs_streda_carrier_slope(1.0, 0.24),
    )
    assert np.isclose(GMGS.gmgs_composite_fermion_effective_field(10.0, 1.0, 0.5), 0.0)
    assert GMGS.gmgs_gurzhi_vorticity_length_sq(2.0, 3.0) < GMGS.gmgs_gurzhi_vorticity_length_sq(
        2.0, 5.0
    )
    assert GMGS.gmgs_flat_band_kinetic_inductance(
        10.0, 5.0
    ) < GMGS.gmgs_flat_band_kinetic_inductance(10.0, 2.0)
    assert np.isclose(GMGS.gmgs_qahe_sc_bdg_gap_sq(1.0, 0.0, 3.0, 3.0), 0.0)
    assert GMGS.gmgs_qahe_sc_bdg_gap_sq(1.0, 0.0, 5.0, 3.0) > 0.0

    # Section 18.4: Gr_C(2,6) / Gr_C(2,10), CdGM Majorana mini-gap, parafermion/Plücker qudits
    assert GMGS.gmgs_boundary_grassmannian_real_dim(3) == 16
    assert GMGS.gmgs_boundary_grassmannian_real_dim(5) == 32
    assert GMGS.gmgs_plucker_sublattice_qudit_dim(2) == 6
    assert GMGS.gmgs_plucker_sublattice_qudit_dim(3) == 15
    assert GMGS.gmgs_plucker_sublattice_qudit_dim(5) == 45
    assert (
        GMGS.gmgs_vortex_core_mini_gap(0.2, w1)
        < GMGS.gmgs_vortex_core_mini_gap(0.2, w3)
        < GMGS.gmgs_vortex_core_mini_gap(0.2, w5)
    )
    assert GMGS.gmgs_parafermion_qudit_dim(1) == 3
    assert GMGS.gmgs_parafermion_qudit_dim(2) == 5
    assert (
        1.0
        < GMGS.gmgs_qudit_hilbert_compression_ratio(3.0, 4)
        < GMGS.gmgs_qudit_hilbert_compression_ratio(4.0, 4)
        < GMGS.gmgs_qudit_hilbert_compression_ratio(15.0, 4)
    )

    # Section 19 & 20: Semi-Dirac fermions (with/without Gr_C and DDF) & SU(4)/Witten/CHY unification
    from sustainablefactory.qci_grassmannian_dft import (
        SemiDiracAndSU4WittenUnificationEngine as SDSU4,
    )

    assert np.isclose(SDSU4.semi_dirac_energy_sq(2.0, 0.0, 1.0, 3.0, 0.0), 4.0)
    assert np.isclose(SDSU4.semi_dirac_energy_sq(0.0, 2.0, 1.0, 3.0, 0.0), 36.0)
    assert np.isclose(SDSU4.semi_dirac_plucker_det(-2.5, 2.5, 0.0), 0.0)
    assert np.isclose(
        SDSU4.semi_dirac_landau_level_cube(1.0, 1.0, 1.0, 1.0, 8.0),
        64.0 * SDSU4.semi_dirac_landau_level_cube(1.0, 1.0, 1.0, 1.0, 1.0),
    )
    assert np.isclose(
        SDSU4.semi_dirac_kahler_det_factor(2.0, 0.0, 3.0),
        (1.0 + SDSU4.semi_dirac_plucker_det(2.0, 0.0, 3.0)) ** 2,
    )
    assert np.isclose(SDSU4.semi_dirac_ddf_jammed_mass_x(1.0, 0.6), 25.0 / 16.0)
    assert SDSU4.semi_dirac_plucker_det(
        16.0, 0.0, 0.0
    ) < SDSU4.semi_dirac_ddf_gr24_energy_sq(16.0, 0.0, 0.0, 0.6)
    assert SDSU4.semi_dirac_anisotropic_splat_var_x(
        1.0, 0.0, 1.0
    ) < SDSU4.semi_dirac_anisotropic_splat_var_x(1.0, 2.0, 1.0)
    assert np.isclose(
        SDSU4.semi_dirac_anisotropic_splat_var_y(1.0, 2.0),
        SDSU4.semi_dirac_anisotropic_splat_var_y(1.0, 0.0),
    )
    assert SDSU4.su_n_real_dim(4) == 15
    assert SDSU4.real_grassmannian_dim(2, 4) == 4
    assert SDSU4.complex_grassmannian_real_dim(2, 4) == 8
    assert SDSU4.grassmannian_scalar_curvature(2, 4) == 16
    assert SDSU4.complex_grassmannian_real_dim(2, 6) == 16
    assert SDSU4.grassmannian_scalar_curvature(2, 6) == 48
    assert SDSU4.chy_solution_count(4) == 1
    assert SDSU4.chy_solution_count(6) == 6
    assert SDSU4.chy_solution_count(8) == 120
    sigma4 = SDSU4.chy_four_point_root(3.0, 5.0)
    assert np.isclose(SDSU4.chy_four_point_cross_equation(3.0, 5.0, sigma4), 0.0)
    assert np.isclose(
        SDSU4.universal_plucker_three_term_residual(2.0, 1.0, 1.0, 5.0, 3.0, 1.0),
        0.0,
    )
    assert np.isclose(
        SDSU4.universal_plucker_three_term_residual(
            1.6, 0.4, 1.0, 1.0 - 0.36, 0.0, 1.0
        ),
        0.0,
    )

    # Section 20.2: Deep gap-closure checks for Papers 29 & 30
    assert np.isclose(SDSU4.semi_dirac_dos_exponent(2.0, 2.0), 0.0)
    assert np.isclose(SDSU4.semi_dirac_dos_exponent(2.0, 1.0), 0.5)
    assert np.isclose(SDSU4.semi_dirac_dos_exponent(1.0, 1.0), 1.0)
    assert SDSU4.semi_dirac_wkb_barrier_transmission_x(2.0) < 1.0
    assert (
        SDSU4.semi_dirac_directional_permittivity(1.0, 1.0, 2.0)
        * SDSU4.semi_dirac_directional_permittivity(1.0, 4.0, 2.0)
        < 0.0
    )
    assert SDSU4.plucker_relation_codimension(1, 4) == 0
    assert SDSU4.plucker_relation_codimension(2, 4) == 1
    assert SDSU4.plucker_relation_codimension(2, 5) == 3
    assert SDSU4.plucker_relation_codimension(2, 6) == 6
    assert SDSU4.plucker_relation_codimension(3, 6) == 10
    assert SDSU4.plucker_relation_codimension(2, 10) == 28
    assert np.isclose(
        SDSU4.chy_four_point_bi_adjoint_scalar(3.0, 5.0), 1.0 / 3.0 + 1.0 / 5.0
    )
    assert np.isclose(
        SDSU4.twisted_holography_deformed_conifold_residual(3.0, 4.0, 2.0, 5.0, 2.0),
        0.0,
    )
    h_cel = SDSU4.celestial_conformal_weight_h(2.5, 2.0)
    hbar_cel = SDSU4.celestial_conformal_weight_hbar(2.5, 2.0)
    assert np.isclose(h_cel + hbar_cel, 2.5)
    assert np.isclose(h_cel - hbar_cel, 2.0)

    # Semi-Dirac 4 Applications + Phase-Varying Lasing of Carbon-Based Qudits
    assert np.isclose(SDSU4.semi_dirac_strain_merging_gap(1.2, 2.0, 0.6), 0.0)
    assert np.isclose(SDSU4.semi_dirac_klein_rectification_ratio(10.0), 101.0)
    assert SDSU4.semi_dirac_drude_anisotropy_sq(
        1.0, 1.0, 1.0, 4.0
    ) < SDSU4.semi_dirac_drude_anisotropy_sq(1.0, 1.0, 1.0, 1.0)
    assert np.isclose(
        SDSU4.semi_dirac_hyperbolic_canalization_tan_sq(0.75, -3.0), 0.25
    )
    assert (
        0.0
        < SDSU4.semi_dirac_bolometer_polarization_contrast(10.0, 1.0)
        < 1.0
    )
    assert (
        SDSU4.semi_dirac_thermoelectric_zt(2.0, 1.0, 300.0, 1.0, 2.0)
        < SDSU4.semi_dirac_thermoelectric_zt(2.0, 10.0, 300.0, 1.0, 2.0)
        < SDSU4.semi_dirac_thermoelectric_zt(2.0, 10.0, 300.0, 1.0, 1.0)
    )
    assert np.isclose(
        SDSU4.semi_dirac_etch_free_coherence_gain(1.0e12, 1.0e10), 100.0
    )
    assert np.isclose(
        SDSU4.helical_phase_lasing_azimuthal_shift(3.0, np.pi),
        SDSU4.helical_phase_lasing_azimuthal_shift(1.0, np.pi)
        + SDSU4.helical_phase_lasing_azimuthal_shift(2.0, np.pi),
    )
    assert np.isclose(
        SDSU4.spiral_phase_plate_step_height(1.0, 1550.0, 1.5), 3100.0
    )
    assert np.isclose(
        SDSU4.cp_rank_3d_voxel_compression_ratio(1000, 50), 20000.0 / 3.0
    )
    assert (
        SDSU4.oam_carbon_qudit_hilbert_dim(2, 4)
        < SDSU4.oam_carbon_qudit_hilbert_dim(6, 4)
        < SDSU4.oam_carbon_qudit_hilbert_dim(15, 4)
        < SDSU4.oam_carbon_qudit_hilbert_dim(100, 4)
    )
    assert SDSU4.oam_carbon_qudit_hilbert_dim(
        2, 66
    ) < SDSU4.oam_carbon_qudit_hilbert_dim(100, 10)
    assert np.isclose(SDSU4.semi_dirac_oblique_klein_transmission_y(0.0, 2.0), 1.0)
    assert 0.0 < SDSU4.semi_dirac_oblique_klein_transmission_y(1.0, 2.0) < 1.0
    assert (
        1.0
        < SDSU4.semi_dirac_hyperbolic_quality_factor(10.0, 2.0)
        < SDSU4.semi_dirac_hyperbolic_quality_factor(10.0, 1.0)
    )
    assert (
        0.0
        < SDSU4.semi_dirac_thermoelectric_reduced_efficiency(1.5)
        < SDSU4.semi_dirac_thermoelectric_reduced_efficiency(2.0)
        < 1.0
    )
    assert np.isclose(
        SDSU4.semi_dirac_thermoelectric_reduced_efficiency(2.0), 1.0 / 3.0
    )
    assert np.isclose(
        SDSU4.compensated_oam_phase_residual(3.0, 1.0e-5, 10.0, 3.0e-4), 0.0
    )
    assert SDSU4.cglmp_classical_bound() < SDSU4.cglmp_qutrit_quantum_benchmark()

    # Papers 33 & 34: Semi-Dirac Soliton Bus, CROW Delay, 128->64b RDMA, & Multi-Band CNC / c-BAs Photonics
    assert np.isclose(
        SDSU4.co2_carbonate_chi3_cphase_length(1550.0, 5.0, 1.0),
        0.2 * SDSU4.co2_carbonate_chi3_cphase_length(1550.0, 1.0, 1.0),
    )
    assert (
        SDSU4.crow_slow_light_delay_length(12.0, 0.5, 0.3, 300.0)
        < SDSU4.crow_slow_light_delay_length(12.0, 0.5, 0.3, 5.0)
        < SDSU4.crow_slow_light_delay_length(12.0, 0.5, 0.3, 1.5)
    )
    assert SDSU4.tiered_qnic_stripped_payload_bits(128, 64) == 64
    assert np.isclose(
        SDSU4.lut_plus_cordic_oam_phase(4.0, 0.5, 0.125), 4.0 * 0.625
    )
    assert (
        250.0 * SDSU4.nlig_internal_pump_avg_power_mw(1.5, 500.0, 0.375)
        < 110.0
        < 250.0 * SDSU4.nlig_internal_pump_avg_power_mw(1.5, 500.0, 1.0)
    )
    assert np.isclose(
        SDSU4.cnc_periodic_booster_net_link_gain_db(10000.0, 10.0, 0.05, 0.5),
        0.0,
    )
    assert SDSU4.cnc_checkpoint_count(10000, 10) == 1000
    assert SDSU4.cnc_checkpoint_count(10000, 100) == 100
    assert SDSU4.adiabatic_scarf_taper_loss() < SDSU4.fresnel_butt_joint_reflectance(
        1.55, 3.20
    )
    assert SDSU4.nv_purcell_factor_normalized(100.0, 0.10) > 12.0
    assert (
        405.0
        < 475.0
        < SDSU4.multiband_third_harmonic_wavelength_nm(1550.0)
        < 532.0
        < 540.0
        < 590.0
        < 650.0
        < 775.0
        < 785.0
        < 800.0
        < 1030.0
        < 1310.0
        < 1550.0
    )

    # Papers 35–38: Nanodiamond & Biodegradable Carbon Photonics, VortexVias & SHG-OPA AQM,
    # LHAT Archival Tape, and Pressed-LLM Soliton QRAM Steering
    assert (
        SDSU4.pet_endogenous_oxygen_shock_threshold_gpa()
        < SDSU4.hydrocarbon_unassisted_shock_threshold_gpa()
    )
    assert np.isclose(
        SDSU4.methane_pyrolysis_net_carbon_cost_per_kg(0.20, 0.67), -0.47
    )
    assert np.isclose(
        SDSU4.h2_plasma_sp2_to_sp3_etch_selectivity(100.0, 1.0), 100.0
    )
    assert SDSU4.biodegradable_ox_scnt_butt_joint_reflectance(
        1.55, 1.65
    ) < SDSU4.fresnel_butt_joint_reflectance(1.55, 3.20)
    assert (
        SDSU4.phosphorus_cqd_purcell_lifetime_ns(1.5, 15.0)
        < 0.25
        < 11.6
    )
    assert SDSU4.vortex_via_oam_charge_step(2, 1) == 3
    assert SDSU4.vortex_via_helical_arc_factor_sq(
        10.0, 2.0, 0.0
    ) < SDSU4.vortex_via_helical_arc_factor_sq(10.0, 2.0, 1.0)
    assert np.isclose(
        SDSU4.aqm_kelvin_linearized_voltage_sq(500.0, 0.02, 0.5),
        500.0 * (0.02 * 0.5),
    )
    assert (
        0.0
        < SDSU4.aqm_cbf_safe_heater_power(80.0, 65.0, 1.5)
        < SDSU4.aqm_cbf_safe_heater_power(85.0, 65.0, 1.5)
    )
    assert SDSU4.vacnt_kapitza_cooling_time_ps(1.3e-8, 1.4e-3, 100.0) < 1.0
    assert SDSU4.lhat_volumetric_multiplex_factor(10, 30, 10) == 3000
    assert (
        18.0
        < 480.0
        < SDSU4.lhat_cartridge_capacity_tb(24.0, 3000.0)
    )
    assert np.isclose(
        SDSU4.log_polar_unwrapped_phase(4.0, 0.75, 0.25),
        4.0 * (0.75 + 0.25),
    )
    assert (
        SDSU4.qft_rk_required_temp_delta(155.0, 25.0, 95.2)
        < 60.0
        < SDSU4.qft_rk_required_temp_delta(155.0, 25.0, 0.0)
    )
    assert np.isclose(
        SDSU4.pressed_llm_steered_activation(10.0, 0.25) - 10.0, 0.25
    )

    # Carbon scrubbing (CO2 -> C + O2) efficiency, relative costs, and scrubbing efficiency incentive
    assert np.isclose(
        1.0 + SDSU4.co2_to_oxygen_byproduct_mass_ratio(),
        SDSU4.co2_to_carbon_mass_ratio(),
    )
    e_min_c = SDSU4.co2_splitting_theoretical_min_kwh_per_kg_c()
    eta_unrec = SDSU4.co2_scrubbing_thermodynamic_efficiency(e_min_c, 45.5)
    eta_rec = SDSU4.co2_scrubbing_thermodynamic_efficiency(e_min_c, 13.0)
    assert np.isclose(eta_unrec, 0.20)
    assert np.isclose(eta_rec, 0.70)
    assert eta_unrec < eta_rec
    net_cost_low_eff = SDSU4.co2_scrubbing_net_carbon_cost_per_kg(
        e_min_c, 0.20, 0.03, 0.20, 0.18, 0.10
    )
    net_cost_high_eff = SDSU4.co2_scrubbing_net_carbon_cost_per_kg(
        e_min_c, 0.70, 0.03, 0.20, 0.18, 0.10
    )
    assert net_cost_low_eff > 0.0
    assert np.isclose(net_cost_high_eff, -101.0 / 300.0)
    assert net_cost_high_eff < 0.0
    assert SDSU4.co2_lifecycle_net_scrubbing_factor(12.5, 0.10) < 0.0
    assert SDSU4.co2_lifecycle_net_scrubbing_factor(3.5, 0.10) > 0.60

    # Paper 39: Quantum Causal Next-Concept Modeling (QCI-NCM, arXiv:2610.14162)
    z_hat_k = SDSU4.ncm_cumulative_reconstruction_step(7.0, 3.25)
    z_res_k = SDSU4.ncm_residual_at_level(12.5, z_hat_k)
    assert np.isclose(z_hat_k + z_res_k, 12.5)
    z_cf = SDSU4.ncm_counterfactual_concept_reconstruction(10.0, 6.0, 8.5)
    assert np.isclose(z_cf - 10.0, 8.5 - 6.0)
    assert np.isclose(SDSU4.ncm_story_concept_composition(0.35, 4.0, 4.0), 4.0)
    assert SDSU4.ncm_elbo_posterior_kl_gap(-10.0, -6.0, -5.0) >= 0.0
    assert SDSU4.ncm_corruption_deconfounded_bias(0.5, 0.2) < 0.2
    assert np.isclose(
        SDSU4.qci_ncm_coherent_pairwise_code_prob(0.6, -0.3, -0.6, 0.3), 0.0
    )
    c_dlm = SDSU4.dlm_full_sequence_attention_complexity(128.0, 128.0, 64.0)
    c_ncm = SDSU4.ncm_four_level_block_diagonal_attention_complexity(
        16.0, 32.0, 64.0, 128.0, 64.0
    )
    c_qci_g_ncm = SDSU4.qci_grassmann_ncm_four_level_complexity(
        16.0, 32.0, 64.0, 128.0, 2.0, 10.0
    )
    assert (c_dlm / c_ncm) > 96.0
    assert (c_dlm / c_qci_g_ncm) > 27_962.0
    assert np.isclose(SDSU4.ncm_nfe_speedup_ratio(1024.0, 32.0), 32.0)
    z_steered = SDSU4.ncm_pressed_two_scale_steered_latent(
        5.0, 2.0, 0.8, 1.5, -0.4, 2.5
    )
    assert np.isclose(z_steered - 7.0, 0.8 * 1.5 - 0.4 * 2.5)
    seq_mbr, oam_mbr = SDSU4.ncm_sequential_vs_oam_parallel_mbr_steps(16, 8)
    assert seq_mbr == 128 and oam_mbr == 8
    assert SDSU4.ncm_flag_manifold_two_step_real_dim(16, 32, 128) == 3328
    assert np.isclose(
        SDSU4.ncm_classifier_free_guided_logit(3.5, 1.5, 0.8) - 1.5,
        1.8 * (3.5 - 1.5),
    )
    assert SDSU4.ncm_nested_dropout_active_bragg_layers(5, 12) == 5
