"""End-to-end SymPy, `mpmath`, and Rust/PyO3 verification for `Signals.SatoGrassmannian`."""

from __future__ import annotations

import math
import pytest
import signals_numerical_adapter as sna

from sustainablefactory.sato_grassmannian import (
    audit_carleman_mpmath_vs_rust,
    audit_riemann_spectral_bridge_on_true_zeros,
    verify_symbolic_sato_pde_identities,
)


def test_symbolic_sato_pde_and_bridge_identities():
    res = verify_symbolic_sato_pde_identities()
    assert len(res) == 13
    for name, ok in res.items():
        assert ok, f"Symbolic identity failed: {name}"


@pytest.mark.parametrize(
    "kappa,weights,pt",
    [
        ([-2.0, -0.5, 0.7, 1.8], (1.2, 0.8, 1.5, 2.1), (0.0, 0.0, 0.0)),
        ([-2.0, -0.5, 0.7, 1.8], (1.2, 0.8, 1.5, 2.1), (1.3, -2.4, 0.9)),
        ([-1.5, -0.3, 0.4, 1.2], (0.5, 3.0, 0.7, 1.1), (-5.0, 4.0, -2.5)),
        ([-1.0, 0.0, 1.0, 2.0], (2.0, 2.0, 2.0, 2.0), (100.0, -50.0, 20.0)),
    ],
)
def test_pyo3_plabic_gr24_solver_kp2(kappa, weights, pt):
    solver = sna.PlabicGr24Solver.from_plabic_weights(kappa, *weights)
    assert abs(solver.klein_quadric_residual()) < 1e-13
    jet = solver.eval_jet(*pt)
    assert jet.u >= 0.0
    assert abs(jet.kp2_residual) < 1e-11
    grid = solver.eval_grid([pt[0], pt[0] + 0.25], [pt[1]], pt[2])
    assert len(grid) == 2
    assert math.isclose(grid[0], jet.u, rel_tol=1e-12, abs_tol=1e-12)


def test_pyo3_kdv_two_soliton_and_lax_and_akns_and_qfim():
    k1, k2, c1, c2 = 0.6, 1.3, 1.4, 0.9
    solver = sna.PlabicGr24Solver.from_frame(
        [-k2, -k1, k1, k2], [1.0, 0.0, 0.0, -c2], [0.0, 1.0, c1, 0.0]
    )
    j0 = solver.eval_jet(0.7, 0.0, 0.4)
    j1 = solver.eval_jet(0.7, 17.5, 0.4)
    assert abs(j0.u - j1.u) < 1e-13
    assert abs(j0.u_y) < 1e-13
    assert abs(j0.u_yy) < 1e-13
    assert abs(j0.kp2_residual) < 1e-11

    lax = sna.py_audit_ba_lax_pair(0.8, 0.3, 1.1, 0.4, -0.2, 0.5)
    assert lax["b2_residual_abs"] < 1e-12
    assert lax["b3_residual_abs"] < 1e-12

    akns = sna.py_audit_akns_solitons(1.3, 0.7, -0.4)
    assert akns["bright_nls_residual_abs"] < 1e-12
    assert akns["dark_gpe_residual_abs"] < 1e-12

    qfim = sna.py_audit_dual_schubert_qfim(
        [0.3, 0.2, 0.15, 0.1, 0.15, 0.1],
        [0.1, -0.05, 0.04, -0.03, -0.04, -0.02],
        [0.2, 0.5, -0.3, 0.7, -0.1, 0.4],
        [0.25, 0.25, 0.1, 0.2, 0.1, 0.1],
        [-0.08, 0.06, 0.02, -0.01, 0.03, -0.02],
        [-0.4, 0.1, 0.6, -0.2, 0.3, -0.5],
    )
    assert qfim["total_identity_residual"] < 1e-13
    assert qfim["fq_total_six_channel"] > 0.0

    sw = sna.py_audit_segal_wilson_gr24_tau(
        [0.4, -0.7, 1.2, 0.3], [0.9, 0.2, -0.5, 1.1], 0.35, -0.2, 0.15
    )
    assert sw["mismatch_abs"] < 1e-13


def test_carleman_mpmath_vs_rust_and_critical_line_det3():
    # Classical convergence strip σ = 2.0: det₁ matches 1/|ζ(2 + 5i)| closely
    c_strip = audit_carleman_mpmath_vs_rust(2.0, 5.0, prime_limit=1000, dps=40)
    assert c_strip["det1_abs_diff"] < 1e-12
    assert c_strip["det2_abs_diff"] < 1e-12
    assert c_strip["det3_abs_diff"] < 1e-12
    assert c_strip["det2_anomaly_residual"] < 1e-12
    assert c_strip["det1_vs_inv_zeta_diff"] < 1e-3

    # Critical line σ = 1/2 at first Riemann zero γ₁ ≈ 14.134725: det₃ converges and is nonzero
    c_crit = audit_carleman_mpmath_vs_rust(0.5, 14.134725141734694, prime_limit=1500, dps=40)
    assert c_crit["det3_abs_diff"] < 1e-11
    assert c_crit["mp_det3_abs"] > 0.0
    assert c_crit["sum_p_neg_3sigma"] < 2.0


def test_riemann_spectral_bridge_on_first_10_true_zeros():
    rep = audit_riemann_spectral_bridge_on_true_zeros(count=10)
    assert rep["zero_count"] == 10.0
    assert abs(rep["first_gamma"] - 14.134725141734694) < 1e-8
    assert rep["max_li_cayley_err"] < 1e-14
    assert rep["weil_critical_line_re"] >= 0.0
    assert abs(rep["weil_critical_line_im"]) < 1e-12
    assert rep["weil_off_line_witness"] < rep["weil_neg_4pi_bound"]
    assert rep["det3_at_first_zero_abs"] > 0.0
