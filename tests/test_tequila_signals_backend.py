"""
End-to-End Pytest Suite for the Rust/PyO3 (`maturin`) Grassmannian, Plabic VRC,
Madelung/DDF, and Quantum Causal Inference (`QCI`) Quantum Simulation Backend
for Tequila (`sustainablefactory/tequila_signals_backend.py`,
`src/tequila/src/tequila/simulators/simulator_signals.py`, and
`src/signals/numerical_adapter/src/tequila_simulator.rs`).
"""

from __future__ import annotations

import numpy as np
import tequila as tq
from tequila.circuit.noise import BitFlip, DepolarizingError, PhaseFlip

from sustainablefactory.tequila_signals_backend import (
    SignalsTequilaGrassmannSimulator,
    ensure_tequila_signals_backend_registered,
)
import signals_numerical_adapter as sna


def test_tequila_signals_backend_registration_and_universal_gates():
    installed = ensure_tequila_signals_backend_registered()
    assert "signals" in installed
    assert "grassmann" in installed
    assert tq.pick_backend() == "signals"

    # Build a multi-qubit circuit exercising X, Y, Z, H, Rx, Ry, Rz, Phase, SWAP,
    # CNOT, Toffoli (multi-control), and ExpPauli
    U = (
        tq.gates.H(target=0)
        + tq.gates.Rx(angle="a", target=1)
        + tq.gates.Ry(angle="b", target=2)
        + tq.gates.CNOT(control=0, target=1)
        + tq.gates.Rz(angle="c", target=2, control=1)
        + tq.gates.ExpPauli(angle="a", paulistring="X(0)Y(1)Z(2)")
        + tq.gates.X(target=2, control=[0, 1])
    )
    variables = {"a": np.pi / 3.0, "b": np.pi / 5.0, "c": np.pi / 7.0}

    wfn_sig = tq.simulate(U, variables=variables, backend="signals")
    wfn_gr = tq.simulate(U, variables=variables, backend="grassmann")
    wfn_sym = tq.simulate(U, variables=variables, backend="symbolic")

    assert np.isclose(abs(wfn_sig.inner(wfn_sym)) ** 2, 1.0, atol=1e-13)
    assert np.isclose(abs(wfn_gr.inner(wfn_sym)) ** 2, 1.0, atol=1e-13)

    H = tq.QubitHamiltonian("1.25*Z(0) - 0.75*X(0)Y(1) + 0.5*Z(0)Z(1)Z(2)")
    E = tq.ExpectationValue(H=H, U=U)
    e_sig = float(tq.simulate(E, variables=variables, backend="signals"))
    e_sym = float(tq.simulate(E, variables=variables, backend="symbolic"))
    assert np.isclose(e_sig, e_sym, atol=1e-13)


def test_tequila_signals_braket_gradients_and_vqe_minimization():
    ensure_tequila_signals_backend_registered()

    # 1. Exact parameter-shift gradient & VQE minimization on Bell-rotation model
    # E(a) = -cos(a) - 0.5*sin(a), exact minimum -sqrt(5)/2 = -1.118033988749895
    U_vqe = tq.gates.Ry(angle="a", target=0) + tq.gates.CNOT(control=0, target=1)
    H_vqe = tq.QubitHamiltonian("-1.0*Z(0) - 0.5*X(0)X(1)")
    E_vqe = tq.ExpectationValue(H=H_vqe, U=U_vqe)

    dE_da = tq.grad(E_vqe, "a")
    angle_test = {"a": 0.6}
    grad_sig = float(tq.simulate(dE_da, variables=angle_test, backend="signals"))
    grad_exact = float(np.sin(0.6) - 0.5 * np.cos(0.6))
    assert np.isclose(grad_sig, grad_exact, atol=1e-12)

    res = tq.minimize(E_vqe, backend="signals", silent=True)
    assert np.isclose(res.energy, -np.sqrt(5.0) / 2.0, atol=1e-6)
    assert np.isclose(res.energy**2, 5.0 / 4.0, atol=1e-5)

    # 2. BackendBraKetSignals overlap & transition matrix elements
    U_bra = tq.gates.H(target=0) + tq.gates.CNOT(control=0, target=1)
    U_ket = tq.gates.Ry(angle=np.pi / 2.0, target=0) + tq.gates.CNOT(
        control=0, target=1
    )
    bk_overlap = tq.BraKet(bra=U_bra, ket=U_ket)
    ov_sig = tq.simulate(bk_overlap, backend="signals")
    assert np.isclose(ov_sig, 1.0, atol=1e-13)

    bk_op = tq.BraKet(
        bra=U_bra, ket=U_ket, operator=tq.QubitHamiltonian("Z(0)Z(1) + X(0)X(1)")
    )
    op_sig = tq.simulate(bk_op, backend="signals")
    assert np.isclose(op_sig, 2.0, atol=1e-13)


def test_tequila_signals_sampling_noisy_density_and_mcweeny_purification():
    ensure_tequila_signals_backend_registered()

    # 1. Deterministic shot sampling on GHZ state
    U_ghz = (
        tq.gates.H(target=0)
        + tq.gates.CNOT(control=0, target=1)
        + tq.gates.CNOT(control=1, target=2)
    )
    sampled_wfn = tq.simulate(U_ghz, samples=2000, backend="signals")
    total_shots = sum(abs(v) for v in sampled_wfn.values())
    assert np.isclose(total_shots, 2000.0)
    # Only |000> (0) and |111> (7) can appear in ideal GHZ sampling
    for k in sampled_wfn.keys():
        assert k.integer in (0, 7)

    # 2. Noisy Kraus density-matrix evolution + McWeeny cubic purification
    noise = DepolarizingError(p=0.06, level=1) + PhaseFlip(p=0.02, level=1)
    compiled_raw = tq.compile(
        U_ghz, backend="signals", noise=noise, mcweeny_passes=0
    )
    compiled_healed = tq.compile(
        U_ghz, backend="signals", noise=noise, mcweeny_passes=2
    )

    dm_raw = compiled_raw.do_simulate_density()
    dm_healed = compiled_healed.do_simulate_density()
    rho_raw = dm_raw.get_density_as_array()
    rho_healed = dm_healed.get_density_as_array()

    purity_raw = float(np.real(np.trace(rho_raw @ rho_raw)))
    purity_healed = float(np.real(np.trace(rho_healed @ rho_healed)))
    assert np.isclose(np.real(np.trace(rho_raw)), 1.0, atol=1e-12)
    assert np.isclose(np.real(np.trace(rho_healed)), 1.0, atol=1e-12)
    assert purity_raw < purity_healed <= 1.0 + 1e-12


def test_tequila_signals_grassmann_plucker_hcb_vrc_and_qci_mechanics():
    ensure_tequila_signals_backend_registered()

    # 1. Grassmannian Plücker HCB sector simulation on Gr_C(2, 6) and Gr_C(2, 10)
    wfn_gr26 = SignalsTequilaGrassmannSimulator.simulate_plucker_hcb_wavefunction(
        n_occ=2,
        n_orb=6,
        rotations=[(0, 2, np.pi / 4.0), (1, 3, np.pi / 3.0), (2, 4, np.pi / 6.0)],
    )
    probs_gr26 = sum(abs(v) ** 2 for v in wfn_gr26.values())
    assert np.isclose(probs_gr26, 1.0, atol=1e-13)
    assert len(list(wfn_gr26.keys())) <= 15  # C(6, 2) = 15 Plücker coordinates vs. 2^6 = 64

    wfn_gr210 = SignalsTequilaGrassmannSimulator.simulate_plucker_hcb_wavefunction(
        n_occ=2,
        n_orb=10,
        rotations=[(0, 2, 0.4), (1, 5, -0.3), (2, 8, 0.25)],
    )
    probs_gr210 = sum(abs(v) ** 2 for v in wfn_gr210.values())
    assert np.isclose(probs_gr210, 1.0, atol=1e-13)
    assert len(list(wfn_gr210.keys())) <= 45  # C(10, 2) = 45 Plücker coordinates vs. 2^10 = 1024

    # 2. End-to-End MADNESS MRA-PNO surrogate + Tequila HCB-SPA VQE on signals backend
    h_surr = np.diag([-1.5, -1.0, 0.4, 0.8]).astype(float)
    g_surr = np.zeros((4, 4, 4, 4), dtype=float)
    for i in range(4):
        g_surr[i, i, i, i] = 0.25
    g_surr[0, 2, 0, 2] = g_surr[2, 0, 2, 0] = 0.12
    g_surr[1, 3, 1, 3] = g_surr[3, 1, 3, 1] = 0.10

    vqe_res = SignalsTequilaGrassmannSimulator.evaluate_vqe_mra_pno_surrogate(
        h_tensor=h_surr,
        g_tensor=g_surr,
        pairinfo=[(0, 0), (1, 1), (0, 0), (1, 1)],
        occinfo=[2.0, 2.0, 0.0, 0.0],
        nuclear_repulsion=0.5,
    )
    assert vqe_res["hf_abs_diff"] < 1e-13
    assert vqe_res["corr_abs_diff"] < 1e-13
    diag = vqe_res["diagnostics"]
    assert diag["kahler_det_factor"] >= 1.0
    assert diag["plucker_relation_residual"] < 1e-14
    assert diag["vrc_orthogonality_residual"] < 1e-14
    assert np.isclose(diag["cayley_unitarity_norm_sq"], 1.0, atol=1e-14)
    assert np.isclose(diag["mcweeny_090"], 0.972, atol=1e-14)

    # 3. Pearl causal do(q0 = 1) intervention in Rust engine (both legacy and RustFastCircuit)
    gates_do = [
        {"kind": "basic", "name": "H", "targets": [0], "controls": []},
        {"kind": "basic", "name": "X", "targets": [1], "controls": [0]},
        {"kind": "causal_do", "qubit": 0, "bit_value": 1},
    ]
    state_do = sna.py_simulate_circuit_msb(2, gates_do, None)
    assert np.isclose(state_do[0][0], 0.0) and np.isclose(state_do[3][0], 1.0)

    fast_do = sna.RustFastCircuit(2)
    fast_do.add_basic("H", [0], [])
    fast_do.add_basic("X", [1], [0])
    fast_do.add_causal_do(0, 1)
    sp_do = fast_do.simulate_sparse_plucker([], 0)
    assert len(sp_do) == 1 and sp_do[0][0] == 3 and np.isclose(sp_do[0][1], 1.0)

    # 4. Fermionic determinant (JW Koszul sign) vs. Bosonic permanent (HCB sign-free) on Gr_C(2,4)
    wfn_ferm = SignalsTequilaGrassmannSimulator.simulate_plucker_hcb_wavefunction(
        n_occ=2,
        n_orb=4,
        rotations=[(0, 2, np.pi / 2.0), (1, 3, np.pi / 2.0)],
        fermionic_jw_sign=True,
    )
    wfn_bos = SignalsTequilaGrassmannSimulator.simulate_plucker_hcb_wavefunction(
        n_occ=2,
        n_orb=4,
        rotations=[(0, 2, np.pi / 2.0), (1, 3, np.pi / 2.0)],
        fermionic_jw_sign=False,
    )
    # Crossed orbital state |0110> (index 6 in MSB): det gives -0.5, perm gives +0.5
    assert np.isclose(wfn_ferm[6], -0.5, atol=1e-13)
    assert np.isclose(wfn_bos[6], +0.5, atol=1e-13)


def test_tequila_signals_high_n_scaling_and_comparative_backends():
    ensure_tequila_signals_backend_registered()

    # 1. Cross-backend numerical parity at n = 6 across signals, qulacs, cirq, qiskit, symbolic
    nq = 6
    U6 = tq.QCircuit()
    for q in range(nq):
        U6 += tq.gates.Ry(angle=f"a_{q}", target=q)
    for q in range(nq - 1):
        U6 += tq.gates.CNOT(control=q, target=q + 1)
    U6 += tq.gates.ExpPauli(angle="ep", paulistring="X(0)Y(1)Z(2)")
    H6 = tq.QubitHamiltonian("0.4*Z(0)Z(1) - 0.3*X(1)Y(2) + 0.25*Z(3)Z(5)")
    E6 = tq.ExpectationValue(H=H6, U=U6)
    vars6 = {v: 0.31 for v in E6.extract_variables()}

    val_sig = float(tq.compile(E6, variables=vars6, backend="signals")(variables=vars6))
    for b in ("qulacs", "cirq", "qiskit", "symbolic"):
        if b in tq.INSTALLED_SIMULATORS:
            val_b = float(tq.compile(E6, variables=vars6, backend=b)(variables=vars6))
            assert np.isclose(val_sig, val_b, atol=1e-5)

    # 2. High-n 128-bit sparse Plücker HCB-SPA scaling beyond 64 qubits up to n = 126 qubits (FeMoco scale)
    for n_occ, n_orb in [(6, 26), (6, 64), (8, 120), (8, 126)]:
        U_hcb = tq.QCircuit()
        for p in range(n_occ):
            U_hcb += tq.gates.X(target=p)
            target_virt = n_occ + p
            U_hcb += tq.gates.Ry(angle=f"th_{p}", target=target_virt)
            U_hcb += tq.gates.CNOT(control=target_virt, target=p)
        for q in range(2 * n_occ, n_orb):
            src = q % (2 * n_occ)
            U_hcb += tq.gates.Rz(angle=f"phi_{q}", target=q)
            U_hcb += tq.gates.CNOT(control=src, target=q)
            U_hcb += tq.gates.CNOT(control=q, target=src)
        H_hcb = tq.QubitHamiltonian(
            f"-1.5 + 0.25*Z(0)Z({n_orb - 1}) + 0.12*X(0)X({n_occ}) + 0.12*Y(0)Y({n_occ})"
        )
        E_hcb = tq.ExpectationValue(H=H_hcb, U=U_hcb)
        vars_hcb = {v: 0.35 for v in E_hcb.extract_variables()}
        c_hcb = tq.compile(E_hcb, variables=vars_hcb, backend="signals")
        energy_val = float(c_hcb(variables=vars_hcb))
        assert np.isfinite(energy_val)
        assert c_hcb.args[0].U._rust_circuit.last_support_size() == (1 << n_occ)


def test_tequila_signals_benchmark_functions_and_cli_main(tmp_path, capsys):
    import json
    import subprocess
    import sys
    from tequila.simulators import benchmark_signals, simulator_signals
    from sustainablefactory.tequila_signals_backend import (
        benchmark_dense_expectation_scaling,
        benchmark_dense_memory_wall_limit,
        benchmark_grassmann_plucker_permanent_vs_determinant,
        benchmark_plucker_hcb_chemistry_scaling,
        benchmark_vqe_optimization_and_wavefunction,
        build_arg_parser,
        format_benchmark_markdown_tables,
        main,
        run_all_benchmarks,
    )

    ensure_tequila_signals_backend_registered()

    # 1. Direct programmatic benchmark function calls
    dense_rows = benchmark_dense_expectation_scaling(
        configs=[(4, 2, 12), (6, 2, 16)],
        backends=["signals", "qulacs"],
        repeats=2,
        include_symbolic_max_qubits=0,
    )
    assert len(dense_rows) >= 2
    assert all(r["status"] == "OK" for r in dense_rows if r["backend"] == "signals")

    mw_rows = benchmark_dense_memory_wall_limit(
        qubits_list=[10, 29],
        backends=["signals"],
        max_dense_ram_gb=1.0,
    )
    assert mw_rows[0]["status"] == "OK" and mw_rows[0]["warm_ms"] > 0.0
    assert mw_rows[1]["status"] == "SKIPPED_RAM_LIMIT"

    chem_rows = benchmark_plucker_hcb_chemistry_scaling(
        configs=[(2, 6, 20), (8, 126, 20)],
        backends=["signals"],
        repeats=2,
    )
    assert len(chem_rows) == 2
    assert chem_rows[0]["active_support_size"] == 4
    assert chem_rows[1]["active_support_size"] == 256
    assert chem_rows[1]["n_qubits"] == 126

    vqe_rows = benchmark_vqe_optimization_and_wavefunction(
        backends=["signals"],
        samples=200,
    )
    assert len(vqe_rows) == 1
    assert vqe_rows[0]["status"] == "OK"
    assert np.isclose(vqe_rows[0]["optimal_energy"], -1.40998396, atol=1e-5)
    assert vqe_rows[0]["sample_ms"] is not None and vqe_rows[0]["sample_ms"] > 0.0

    pl_rows = benchmark_grassmann_plucker_permanent_vs_determinant(
        configs=[(2, 4), (2, 6)]
    )
    assert len(pl_rows) == 2
    assert np.isclose(pl_rows[0]["det_norm_sq"], 1.0, atol=1e-12)
    assert np.isclose(pl_rows[0]["perm_norm_sq"], 1.0, atol=1e-12)

    all_res = run_all_benchmarks(
        suite="quick",
        backends=["signals"],
        qubits=[4, 6],
        chemistry_configs=[(2, 6, 16), (8, 126, 16)],
        repeats=1,
    )
    assert set(all_res.keys()) == {
        "dense_expectation",
        "dense_memory_wall",
        "plucker_hcb_chemistry",
        "vqe_optimization",
        "plucker_det_vs_perm",
    }
    md_tables = format_benchmark_markdown_tables(all_res)
    assert "### Table 1:" in md_tables
    assert "### Table 5:" in md_tables

    # 2. Test build_arg_parser() and main() in-process
    parser = build_arg_parser()
    parsed = parser.parse_args(
        [
            "--suite",
            "chemistry",
            "--quick",
            "--backends",
            "signals",
            "--chemistry-configs",
            "2:6:16,8:126:16",
            "--repeats",
            "1",
        ]
    )
    assert parsed.suite == "chemistry"
    assert parsed.quick is True

    json_file = tmp_path / "bench.json"
    md_file = tmp_path / "bench.md"
    rc = simulator_signals.main(
        [
            "--suite",
            "quick",
            "--backends",
            "signals",
            "--qubits",
            "4,6",
            "--chemistry-configs",
            "2:6:16,8:126:16",
            "--repeats",
            "1",
            "--json-out",
            str(json_file),
            "--markdown-out",
            str(md_file),
        ]
    )
    assert rc == 0
    captured = capsys.readouterr()
    assert "### Table 1:" in captured.out
    assert json_file.exists() and md_file.exists()
    loaded_json = json.loads(json_file.read_text(encoding="utf-8"))
    assert "plucker_hcb_chemistry" in loaded_json

    rc_bm = benchmark_signals.main(
        ["--suite", "plucker", "--quiet"]
    )
    assert rc_bm == 0
    rc_sf = main(
        ["--suite", "dense", "--qubits", "4", "--backends", "signals", "--repeats", "1", "--quiet"]
    )
    assert rc_sf == 0

    # 3. Subprocess invocation of `python -m <module>`
    for mod_name in (
        "tequila.simulators.simulator_signals",
        "tequila.simulators.benchmark_signals",
        "tequila",
        "sustainablefactory.tequila_signals_backend",
    ):
        proc = subprocess.run(
            [
                sys.executable,
                "-m",
                mod_name,
                "--suite",
                "plucker",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        assert proc.returncode == 0
        assert "Table 5: Grassmannian Plücker Fermionic Determinant" in proc.stdout

