"""SymPy, Rust/PyO3, and CERN ALPHA-g (2023) verification tests for `Signals.AntimatterGravity`."""

import math
from fractions import Fraction

from sustainablefactory.antimatter_gravity import (
    TEST_DATA_CITATIONS,
    run_pyo3_antimatter_alpha_g_benchmark_suite,
    verify_symbolic_antimatter_gravity_identities,
)


def test_symbolic_antimatter_gravity_identities() -> None:
    res = verify_symbolic_antimatter_gravity_identities()
    assert res, "symbolic identity dictionary must not be empty"
    failed = [k for k, v in res.items() if not v]
    assert not failed, f"Failed symbolic checks: {failed}"


def test_pyo3_cern_alpha_g_model_suite() -> None:
    suite = run_pyo3_antimatter_alpha_g_benchmark_suite()

    # Published CERN ALPHA-g (Anderson et al. 2023) quadrature error and kinematics
    assert math.isclose(suite["total_sigma"], math.sqrt(17.0 / 400.0), rel_tol=1e-13)
    assert math.isclose(suite["e_gamma_kev"], 510.99895, rel_tol=1e-12)
    assert math.isclose(suite["two_photon_invariant_mass_kev"], 1021.9979, rel_tol=1e-12)

    # Witten conformal Rindler 2-sigma bound from ALPHA-g: |gamma_conf| <~ 1e-16 m^-1
    assert abs(suite["witten_gamma_conf_2sigma_upper_bound_inv_m"]) < 1.5e-16
    assert abs(suite["witten_gamma_conf_2sigma_lower_bound_inv_m"]) < 5.0e-17

    # 7-point bias scan separation at 0 bias: +1g -> 0.80, 0g -> 0.50, -1g -> 0.20
    assert suite["bias_scan_g"] == [-9.5, -3.5, -1.5, 0.0, 1.5, 3.5, 9.5]
    assert math.isclose(suite["p_down_normal_wep"][3], 0.80, rel_tol=1e-12)
    assert math.isclose(suite["p_down_zero_g"][3], 0.50, rel_tol=1e-12)
    assert math.isclose(suite["p_down_antigravity"][3], 0.20, rel_tol=1e-12)

    models_by_name = {m["model_name"]: m for m in suite["models"]}
    assert len(models_by_name) == 16

    # GR, Cachazo-Skinner, QED scattering, Turner 3/6, 12, 14a, 15a: consistent AND active-mass conserved
    for name in [
        "Einstein GR (gamma_PPN=1, beta_PPN=1)",
        "Cachazo-Skinner (2012) Infinity-Twistor (pi_I=1, Lambda=0)",
        "QED Scattering Gravity (BCJ / Partanen-Tulkki 2025 U(1)^4)",
        "Turner Model 3 / Model 6 (Gr_C(2,4)/Q_4 coherent escape)",
        "Turner Model 12 (Gr_C(2,4) BCJ + 3D Splat, No DDF)",
        "Turner Model 14a (Q_4 Kahler + Dual-iGPE, No DDF)",
        "Turner Model 15a (Celestial + Q_4 + Plancherel, No DDF)",
    ]:
        row = models_by_name[name]
        assert row["consistent_within_2sigma"] is True
        assert row["active_mass_conserved"] is True
        assert math.isclose(row["chi_sq"], float(Fraction(25, 17)), rel_tol=1e-12)
        assert row["two_sided_p_value"] > 0.20

    # DDF positive-inertia sink and Turner 13, 14b, 15b: consistent with ALPHA-g, but eta_act=0 deficit
    for name in [
        "DDF Positive-Inertia Sink (Fedi 2026, m_g=+m_i, eta_act=0)",
        "Turner Model 13 (Gr_C(2,4) + DDF + 3D Splat)",
        "Turner Model 14b (Q_4 Kahler + Dual-iGPE + DDF)",
        "Turner Model 15b (Celestial + Q_4 + Plancherel + DDF)",
    ]:
        row = models_by_name[name]
        assert row["consistent_within_2sigma"] is True
        assert row["active_mass_conserved"] is False
        assert math.isclose(row["active_mass_deficit_fraction"], 1.0, rel_tol=1e-12)
        assert math.isclose(row["chi_sq"], float(Fraction(25, 17)), rel_tol=1e-12)

    # Witten scale-free (0 g0): rejected at > 3.6 sigma
    witten0 = models_by_name["Witten (2004) Scale-Free Conformal (beta_scale=0)"]
    assert witten0["consistent_within_2sigma"] is False
    assert abs(witten0["z_score"]) > 3.6
    assert math.isclose(witten0["chi_sq"], float(Fraction(225, 17)), rel_tol=1e-12)
    assert witten0["two_sided_p_value"] < 3e-4

    # DDF speculative anti-sink & odd-C vector antigravity (-1 g0): rejected at > 8 sigma
    for name in [
        "DDF Speculative Anti-Sink (m_g=-m_i)",
        "Spin-1 Vector Gravity (odd-C baryon/lepton graviphoton -1)",
    ]:
        row = models_by_name[name]
        assert row["consistent_within_2sigma"] is False
        assert abs(row["z_score"]) > 8.4
        assert math.isclose(row["chi_sq"], float(Fraction(1225, 17)), rel_tol=1e-12)
        assert row["two_sided_p_value"] < 1e-15

    assert "cern_alpha_g_2023" in TEST_DATA_CITATIONS
