"""Tri-language verification (SymPy + Rust/PyO3 `signals_numerical_adapter` + Tequila)
covering Workstreams WS-1 through WS-9 of `docs/grassmannian-gebr-chat-porting-plan.md`.
"""

from __future__ import annotations

import math

import pytest
import sympy as sp

import signals_numerical_adapter as sna


def test_ws1_pauli_spinor_minkowski_and_lorentz_invariance_sympy():
    """WS-1: Symbolic Hermitian Pauli spinor det K(k) = k0^2 - kx^2 - ky^2 - kz^2 and z-boost invariance."""
    k0, kx, ky, kz, eta = sp.symbols("k0 kx ky kz eta", real=True)
    K = sp.Matrix([[k0 + kz, kx - sp.I * ky], [kx + sp.I * ky, k0 - kz]])
    det_k = sp.expand(K.det())
    minkowski = k0**2 - kx**2 - ky**2 - kz**2
    assert sp.simplify(det_k - minkowski) == 0

    # z-axis Lorentz boost with cosh^2(eta) - sinh^2(eta) = 1
    k0_p = sp.cosh(eta) * k0 + sp.sinh(eta) * kz
    kz_p = sp.sinh(eta) * k0 + sp.cosh(eta) * kz
    K_boost = sp.Matrix([[k0_p + kz_p, kx - sp.I * ky], [kx + sp.I * ky, k0_p - kz_p]])
    assert sp.simplify(sp.trigsimp(K_boost.det() - det_k)) == 0


def test_ws2_closed_cycle_landauer_and_qfim_bures_dimensions_sympy():
    """WS-2: Single-shot negative conditional erasure vs. closed-cycle Second Law and QFIM-Bures units."""
    kBln2, T, S_cond, N_bits, hbar, L_qfim, tau, W_ctrl = sp.symbols(
        "kBln2 T S_cond N_bits hbar L_qfim tau W_ctrl", positive=True
    )
    S_signed = sp.Symbol("S_signed", real=True)
    Q_single = kBln2 * T * S_signed * N_bits
    Q_reset_min = kBln2 * T * (1 - S_signed) * N_bits
    W_bures = hbar * L_qfim**2 / (4 * tau)
    Q_closed = sp.simplify(Q_single + Q_reset_min + W_bures + W_ctrl)
    # The conditional entropy S_signed cancels identically over the closed cycle
    assert S_signed not in Q_closed.free_symbols
    assert sp.simplify(Q_closed - (kBln2 * T * N_bits + W_bures + W_ctrl)) == 0


def test_ws3_all_80_layer_groups_pyo3_and_sympy_hexagonal_generators():
    """WS-3: Exact verification of all 80 International Tables Vol. E layer groups via PyO3 + SymPy."""
    # Symbolic hexagonal generator algebra matching Signals.LayerGroups
    C6 = sp.Matrix([[1, -1], [1, 0]])
    C3 = sp.Matrix([[0, -1], [1, -1]])
    M110 = sp.Matrix([[0, 1], [1, 0]])
    assert C6**2 == C3
    assert C6**3 == -sp.eye(2)
    assert C6**6 == sp.eye(2)
    assert M110 * C6 * M110 == C6**5

    groups = sna.py_verify_all_80_layer_groups()
    assert len(groups) == 80
    wallpapers = set()
    for g in groups:
        assert g["has_identity"]
        assert g["closed_under_composition"]
        assert g["all_have_inverses"]
        assert g["order_matches"], f"order mismatch for L_{g['number']} ({g['symbol']})"
        wallpapers.add(g["wallpaper_projection"])
    assert len(wallpapers) == 17

    # Canonical stitch & graphene groups: L_7 (p112/a), L_19 (p222), L_37 (pmmm), L_80 (p6/mmm)
    orders = {g["number"]: (g["symbol"], g["actual_order"]) for g in groups}
    assert orders[7] == ("p112/a", 4)
    assert orders[19] == ("p222", 4)
    assert orders[37] == ("pmmm", 8)
    assert orders[61] == ("p4/mmm", 16)
    assert orders[80] == ("p6/mmm", 24)

    orbit_l80 = sna.py_layer_group_orbit(80, 0.137, 0.293, 0.411)
    assert len(orbit_l80) == 24


def test_ws4_gram_dpp_cholesky_gradients_match_sympy_and_oracle_coverage():
    """WS-4: Exact match between SymPy symbolic ∂log det(X^T X + εI)/∂X and Rust Cholesky PyO3."""
    x00, x01, x10, x11, eps_s = sp.symbols("x00 x01 x10 x11 eps", real=True)
    X = sp.Matrix([[x00, x01], [x10, x11]])  # rows are feature vectors
    G = X * X.T + eps_s * sp.eye(2)
    log_det_sym = sp.log(G.det())
    grad_sym = sp.Matrix(
        [
            [sp.diff(log_det_sym, x00), sp.diff(log_det_sym, x01)],
            [sp.diff(log_det_sym, x10), sp.diff(log_det_sym, x11)],
        ]
    )

    subs = {x00: 0.8, x01: -0.3, x10: 0.4, x11: 0.9, eps_s: 0.05}
    res = sna.py_evaluate_gram_dpp([[0.8, -0.3], [0.4, 0.9]], 0.05)
    assert math.isclose(res["log_det"], float(log_det_sym.subs(subs)), rel_tol=1e-12, abs_tol=1e-12)
    for r in range(2):
        for c in range(2):
            expected = float(grad_sym[r, c].subs(subs))
            assert math.isclose(res["grad_features"][r][c], expected, rel_tol=1e-11, abs_tol=1e-11)

    # Raw vs D4-orbifold N-Queens oracle coverage via PyO3
    raw = sna.py_nqueens_oracle_dpp_coverage(8, 12, 1e-4, False)
    orb = sna.py_nqueens_oracle_dpp_coverage(8, 12, 1e-4, True)
    assert raw["total_exact_solutions"] == 92
    assert raw["selected_distinct_solutions"] == 12
    assert orb["total_exact_solutions"] == 12
    assert orb["selected_distinct_d4_orbits"] == 12


def test_ws5_stretched_h2_noci_sympy_pyo3_and_tequila_cross_check():
    """WS-5: SymPy exact 2-site Hubbard FCI/UHF vs. Rust Löwdin NOCI & Tequila JW Pauli expectation."""
    t_s, u_s = sp.symbols("t u", positive=True)
    H_sym = sp.Matrix(
        [
            [u_s, 0, -t_s, -t_s],
            [0, u_s, -t_s, -t_s],
            [-t_s, -t_s, 0, 0],
            [-t_s, -t_s, 0, 0],
        ]
    )
    e_fci_exact = (u_s - sp.sqrt(u_s**2 + 16 * t_s**2)) / 2
    assert sp.simplify(H_sym.charpoly().as_expr().subs(sp.Symbol("lambda"), e_fci_exact)) == 0

    for t_val, u_val in [(1.0, 3.0), (1.0, 5.0), (0.5, 4.0)]:
        b = sna.py_benchmark_stretched_h2_noci(t_val, u_val)
        fci_sym = float(e_fci_exact.subs({t_s: t_val, u_s: u_val}))
        uhf_sym = -2.0 * t_val**2 / u_val
        s2_uhf_sym = 1.0 - (2.0 * t_val / u_val) ** 2

        assert math.isclose(b["fci_ground_energy"], fci_sym, abs_tol=1e-11)
        assert math.isclose(b["uhf_energy"], uhf_sym, abs_tol=1e-11)
        assert math.isclose(b["uhf_s_squared"], s2_uhf_sym, abs_tol=1e-11)
        # Strict variational hierarchy: E_FCI = E_NOCI(3) < E_NOCI(2/PUHF) < E_UHF < E_RHF
        assert b["noci_3state_minus_fci_error"] < 1e-11
        assert b["noci_3state_energy"] < b["noci_2state_energy"] < b["uhf_energy"] < b["rhf_energy"]
        assert abs(b["noci_2state_s_squared"]) < 1e-12
        assert abs(b["noci_3state_s_squared"]) < 1e-12
        assert abs(b["tequila_pauli_noci_energy"] - b["noci_3state_energy"]) < 1e-12


def test_ws6_ebr_nqueens_seeded_benchmark_pyo3():
    """WS-6: Deterministic seeded EBR + adaptive halting + DPP benchmark via PyO3."""
    r1 = sna.py_run_ebr_nqueens_benchmark(4, 10, 120, 0.15, 1e-4, 0.02, 42)
    r2 = sna.py_run_ebr_nqueens_benchmark(4, 10, 120, 0.15, 1e-4, 0.02, 42)
    assert r1["valid_trajectories"] == r2["valid_trajectories"]
    assert r1["exact_oracle_solutions"] == 2
    assert r1["valid_trajectories"] >= 1
    assert 0.0 < r1["pass_at_1"] <= 1.0


def test_ws7_arc_dsl_tequila_circuits_and_multi_array_imaging_invariants():
    """WS-7: Compositional GridOp DSL, multi_array_imaging PCA object invariants, and Tequila D4 circuits."""
    grid = [
        [1, 2, 0, 0],
        [0, 2, 0, 3],
        [0, 0, 4, 3],
        [5, 0, 0, 0],
    ]
    objs_orig = {o["color"]: o for o in sna.py_extract_grid_objects(grid)}
    for op_name in ["rotate90", "rotate180", "rotate270", "flip_horizontal", "flip_vertical", "transpose"]:
        transformed = sna.py_apply_d4_grid_op_tequila(grid, op_name)
        objs_rot = {o["color"]: o for o in sna.py_extract_grid_objects(transformed)}
        assert math.isclose(objs_orig[2]["cov_det_2d"], objs_rot[2]["cov_det_2d"], abs_tol=1e-12)
        assert math.isclose(objs_orig[2]["aspect_ratio"], objs_rot[2]["aspect_ratio"], abs_tol=1e-12)

    # Multi-step program synthesis + held-out generalization
    train_pairs = [
        (
            [[0, 1, 0, 0, 0], [0, 0, 0, 2, 2], [0, 0, 0, 2, 0], [0, 0, 0, 0, 0]],
            [[5, 5, 5, 5], [5, 0, 0, 5]],
        ),
        (
            [[3, 0, 0, 0], [0, 2, 2, 0], [0, 0, 2, 0]],
            [[5, 5, 5, 5], [0, 5, 5, 0]],
        ),
    ]
    test_in = [[0, 0, 4, 0], [2, 0, 0, 0], [2, 2, 0, 0]]
    ops, pred = sna.py_synthesize_grid_program(train_pairs, test_in, 3)
    assert len(ops) <= 3
    assert pred == [[5, 0, 0, 5], [5, 5, 5, 5]]


def test_ws8_and_ws9_sympy_yarn_plucker_klein_and_petersen_ihara_zeta():
    """WS-8 & WS-9: 3D yarn centerline Klein residual == 0 and Petersen Bass-Ihara Ramanujan factorization."""
    # WS-8: Parametric 3D knitted loop centerline r(s) -> Plücker lift satisfies Klein relation identically
    s, A, B, omega = sp.symbols("s A B omega", real=True)
    r = sp.Matrix([s, A * sp.sin(omega * s), B * sp.cos(2 * omega * s)])
    t = r.diff(s)
    p12, p13, p14 = t[0], t[1], t[2]
    p23 = r[0] * t[1] - r[1] * t[0]
    p24 = r[0] * t[2] - r[2] * t[0]
    p34 = r[1] * t[2] - r[2] * t[1]
    klein_residual = sp.simplify(p12 * p34 - p13 * p24 + p14 * p23)
    assert klein_residual == 0

    # WS-9: Exact Bass-Ihara determinant det(I - u A + q u^2 I) on 10-vertex 3-regular Petersen graph (q = 2)
    edges = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),
    ]
    A_pet = sp.zeros(10, 10)
    for i, j in edges:
        A_pet[i, j] = 1
        A_pet[j, i] = 1
    u = sp.Symbol("u")
    q = 2
    ihara_poly = sp.factor((sp.eye(10) - u * A_pet + q * u**2 * sp.eye(10)).det())
    expected_poly = (1 - 3 * u + 2 * u**2) * (1 - u + 2 * u**2) ** 5 * (1 + 2 * u + 2 * u**2) ** 4
    assert sp.expand(ihara_poly - expected_poly) == 0

    # Verify all non-trivial roots lie strictly on the Ramanujan critical circle |u|^2 = 1/q = 1/2
    for factor in [1 - u + 2 * u**2, 1 + 2 * u + 2 * u**2]:
        for root in sp.solve(factor, u):
            assert sp.simplify(sp.Abs(root) ** 2 - sp.Rational(1, q)) == 0
