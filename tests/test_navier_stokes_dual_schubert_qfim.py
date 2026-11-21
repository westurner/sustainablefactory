"""End-to-end SymPy and Rust/PyO3 verification for `Signals.NavierStokes`."""

from __future__ import annotations

import math
import pytest
import signals_numerical_adapter as sna

from sustainablefactory.navier_stokes import (
    run_pyo3_navier_stokes_benchmark_suite,
    verify_symbolic_navier_stokes_qfim_identities,
)


def test_symbolic_navier_stokes_dual_schubert_qfim_identities():
    res = verify_symbolic_navier_stokes_qfim_identities()
    assert len(res) == 20
    for name, ok in res.items():
        assert ok, f"Symbolic identity failed: {name}"


def test_pyo3_analytical_auditors_and_defect_proofs():
    # Schubert divisor Σ₁ (`p01 = 0`) chart transition Ω₀ -> Ω₀₂
    node = sna.py_audit_schubert_chart_transition_vortex(0.0, 0.0, 0.8)
    assert node["p01_abs"] < 1e-15
    assert node["p02_abs"] >= 1.0
    assert node["chart_switched_to_omega02"] is True
    assert node["klein_quadric_residual"] < 1e-15
    assert node["cancellation_residual"] < 1e-15
    assert node["omega02_u13_identity_residual"] < 1e-15
    assert math.isfinite(node["qfim_regularized_at_node"]) and node["qfim_regularized_at_node"] > 0.0

    # Chat Defect #2 vs. Bateman doubled viscous operator
    bat = sna.py_audit_bateman_vs_chat_heff(1.2, 1.0, 0.05, 3.0, 0.7, -0.4, 0.5, 0.6)
    assert bat["chat_hermiticity_residual"] < 1e-15
    assert abs(bat["chat_total_norm_rate"]) < 1e-15
    assert bat["bateman_primal_norm_rate"] < 0.0
    assert math.isclose(
        bat["bateman_primal_norm_rate"], bat["bateman_expected_primal_rate"], rel_tol=1e-13
    )
    assert bat["bateman_pairing_rate_abs"] < 1e-14

    # Clebsch spinor continuous vorticity + QFIM = 4 g_FS
    cl = sna.py_audit_clebsch_spinor_vorticity(1.0, 1.0, 0.5 * math.pi, 1.0, 0.0, 0.2, 0.0, 0.2, 1.0)
    assert cl["unit_norm_residual"] < 1e-15
    assert cl["qfim_identity_residual"] < 1e-14
    assert math.isclose(cl["qfim_xx"], 4.0 * cl["fubini_study_xx"], rel_tol=1e-14)
    assert math.isclose(cl["vorticity_z"], 0.5, rel_tol=1e-14)


def test_pyo3_incompressible_and_compressible_solvers_and_benchmarks():
    bench = run_pyo3_navier_stokes_benchmark_suite()
    assert bench["schubert_klein_res"] < 1e-14
    assert bench["schubert_node_qfim"] > 0.0
    assert bench["chat_hermitian_norm_rate"] < 1e-15
    assert bench["bateman_pairing_res"] < 1e-14
    assert bench["riccati_horiz_res"] < 1e-14
    assert bench["riccati_gram_res"] < 1e-14
    assert bench["clebsch_qfim_res"] < 1e-14
    assert bench["tg_max_res"] < 1e-14
    assert bench["lo_heat_res"] < 1e-14
    assert bench["lo_curl_res"] < 1e-14
    assert bench["abc_max_res"] < 1e-14
    assert bench["burgers_max_res"] < 1e-14
    assert bench["nsk_max_res"] < 1e-14
    assert bench["bs_ddf_rh_max_res"] < 1e-14
    # Incompressible 2D spectral solver (Taylor–Green + multi-mode nonlinear + true projective QFIM)
    assert bench["incomp_2d_max_div"] < 1e-13
    assert bench["incomp_2d_tg_l2_err"] < 1e-4
    assert bench["incomp_2d_ch2_osmotic"] == 0.0
    assert bench["incomp_2d_qfim_fs_res"] < 1e-14
    assert bench["incomp_2d_multimode_max_div"] < 1e-13
    assert bench["incomp_2d_multimode_high_k_energy"] > 0.0
    # Compressible 1D NSK finite-volume solver (Rusanov + zero-artificial-diffusion central Stokes law)
    assert bench["comp_1d_mass_drift"] < 1e-12
    assert bench["comp_1d_mom_drift"] < 1e-12
    assert bench["comp_1d_bd_res"] < 1e-14
    assert 0.0 < bench["comp_1d_amp_ratio"] < 1.0
    assert bench["comp_1d_central_stokes_damping_rel_err"] < 0.005


def test_pyo3_incompressible_rk2_time_convergence_order():
    # Halving dt should reduce RK2 Taylor-Green L2 error by ~4x (second-order temporal convergence)
    s_coarse = sna.IncompressibleDualSchubertSolver2D.from_taylor_green(16, 1.0, 0.1, 1.0)
    s_coarse.step_rk2(0.02, 25)
    err_coarse = s_coarse.taylor_green_l2_error(1.0, 1.0)

    s_fine = sna.IncompressibleDualSchubertSolver2D.from_taylor_green(16, 1.0, 0.1, 1.0)
    s_fine.step_rk2(0.01, 50)
    err_fine = s_fine.taylor_green_l2_error(1.0, 1.0)

    assert err_fine < err_coarse / 3.5


def test_pyo3_invalid_parameter_rejection():
    with pytest.raises(ValueError):
        sna.py_audit_taylor_green_2d(-1.0, 1.0, 0.1, 1.0, 0.0, 0.0, 0.0)
    with pytest.raises(ValueError):
        sna.py_audit_lamb_oseen_2d(1.0, 0.1, 0.0, 0.0, 0.0)
    with pytest.raises(ValueError):
        sna.py_audit_viscous_burgers_cole_hopf(0.5, 1.0, -0.1, 0.0, 0.0)
    with pytest.raises(ValueError):
        sna.CompressibleNskDualSchubertSolver1D.from_acoustic_wave(
            32, 2.0 * math.pi, 1.0, 0.8, 1.0, 0.0, 0.05, 0.0, 0.0
        )
