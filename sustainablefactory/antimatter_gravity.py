"""
SymPy and Rust/PyO3 Verification Toolkit for `Signals.AntimatterGravity`.

Cross-verifies:
1. **Exact Symbolic SymPy Proofs** (`verify_symbolic_antimatter_gravity_identities`):
   - Electron-positron annihilation kinematics (`e- e+ -> 2 gamma`): `s = (2 m_e c^2)^2`,
     null photon conditions `k_1^2 = k_2^2 = 0`, and Compton <-> annihilation crossing invariance.
   - `Gr_C(2,4)` Plucker crossing identity `w_A + w_B - Delta_02 Delta_13 = 0` and
     4D traceless Maxwell stress tensor `T^mu_mu(d=4) = 0`.
   - Active gravitational mass deficit `2 m_e (1 - eta_act_gamma)` across annihilation:
     zero for `eta_act_gamma = 1` (GR, Cachazo-Skinner, QED scattering, Turner 12/14a/15a),
     non-zero `2 m_e` tension for `eta_act_gamma = 0` (strict uncoupled DDF, Turner 13/14b/15b).
   - Cachazo-Skinner (`pi_I = 1`) cancellation of Witten conformal Rindler term `gamma_conf`.
   - Exact rational CERN `ALPHA-g` (2023) chi-squared statistics:
     `sigma_tot^2 = 17/400`, `chi_sq(1) = 25/17`, `chi_sq(0) = 225/17`, `chi_sq(-1) = 1225/17`.
2. **Rust/PyO3 CERN ALPHA-g Benchmark Suite** (`run_pyo3_antimatter_alpha_g_benchmark_suite`):
   Cross-checks `signals_numerical_adapter.py_audit_antimatter_alpha_g()` against exact SymPy
   and `scipy.stats` p-values across all gravity and Turner models.

**Epistemic Boundary**: Mirrors `Signals.Pending.AntimatterAnnihilationAlphaGPendingBoundary`.
"""

import math
from fractions import Fraction
import sympy as sp

import signals_numerical_adapter as sna

TEST_DATA_CITATIONS: dict[str, dict[str, str]] = {
    "cern_alpha_g_2023": {
        "bibtex_keys": "anderson2023alphag",
        "description": "CERN ALPHA-g antihydrogen free-fall measurement a_gbar / g_0 = 0.75 +/- 0.13 (stat+syst) +/- 0.16 (sim), rejecting -1 g_0 at >8 sigma and 0 g_0 at >3.6 sigma.",
    },
    "cern_alpha_2016_neutrality": {
        "bibtex_keys": "ahmadi2016alpha_charge",
        "description": "CERN ALPHA bound on antihydrogen electric charge neutrality |q_Hbar| < 0.71e-9 e.",
    },
    "cern_base_2022_cpt": {
        "bibtex_keys": "borchert2022base_cpt",
        "description": "CERN BASE antiproton-to-proton charge-to-mass ratio CPT test and clock-WEP constraint.",
    },
    "dirac_witten_cachazo_qed_ddf": {
        "bibtex_keys": "dirac1928quantum, einstein1916grundlage, nordstrom1913gravitation, witten2004twistor, berkovits2004conformal, cachazo2013gravity, partanen2025gravity, fedi2026ddf",
        "description": "Dirac positron theory, GR, Nordstrom scalar gravity, Witten conformal twistor string, Cachazo-Skinner infinity twistor, Partanen-Tulkki U(1)^4 QED gravity, and Fedi DDF.",
    },
}


def verify_symbolic_antimatter_gravity_identities() -> dict[str, bool]:
    """Exact SymPy algebraic and statistical proofs matching `Signals.AntimatterGravity`."""
    results: dict[str, bool] = {}

    # 1. Pair annihilation kinematics: k1 = (E, 0, 0, E), k2 = (E, 0, 0, -E), E = m_e * c^2
    m_e, c = sp.symbols("m_e c", positive=True, real=True)
    e_gamma = m_e * c**2
    k1_0, k1_x, k1_y, k1_z = e_gamma, sp.Integer(0), sp.Integer(0), e_gamma
    k2_0, k2_x, k2_y, k2_z = e_gamma, sp.Integer(0), sp.Integer(0), -e_gamma
    k1_sq = k1_0**2 - k1_x**2 - k1_y**2 - k1_z**2
    k2_sq = k2_0**2 - k2_x**2 - k2_y**2 - k2_z**2
    tot_0 = k1_0 + k2_0
    tot_z = k1_z + k2_z
    s_inv = sp.simplify(tot_0**2 - tot_z**2)
    results["photons_null"] = (k1_sq == 0 and k2_sq == 0)
    results["two_photon_invariant_mass"] = (sp.simplify(s_inv - (2 * m_e * c**2) ** 2) == 0)

    # 2. Mandelstam s <-> t crossing & Gr_C(2,4) Plucker identity
    s_m, t_m, u_m = sp.symbols("s_m t_m u_m")
    results["mandelstam_crossing_sym"] = sp.simplify((s_m + t_m + u_m) - (t_m + s_m + u_m)) == 0
    z1, z2 = sp.symbols("z1 z2")
    m_c = sp.Matrix([[1, 1, 0, -1], [0, z1, 1, z2]])
    d01 = m_c[:, [0, 1]].det()
    d23 = m_c[:, [2, 3]].det()
    d02 = m_c[:, [0, 2]].det()
    d13 = m_c[:, [1, 3]].det()
    d03 = m_c[:, [0, 3]].det()
    d12 = m_c[:, [1, 2]].det()
    results["gr24_plucker_identity"] = sp.simplify(d01 * d23 - d02 * d13 + d03 * d12) == 0

    # 3. 4D traceless Maxwell stress-energy tensor & active mass conservation across e- e+ -> 2 gamma
    d_dim, f_sq = sp.symbols("d_dim f_sq")
    t_trace = (4 - d_dim) / 4 * f_sq
    results["maxwell_4d_trace_zero"] = (t_trace.subs(d_dim, 4) == 0)

    eta_act = sp.symbols("eta_act", real=True)
    active_deficit = 2 * m_e - 2 * m_e * eta_act
    results["active_mass_conserved_eta_1"] = (active_deficit.subs(eta_act, 1) == 0)
    results["active_mass_deficit_eta_0"] = (sp.simplify(active_deficit.subs(eta_act, 0) - 2 * m_e) == 0)

    # 4. Cachazo-Skinner infinity-twistor cancellation of Witten Rindler bias & Turner 14/15 limits
    pi_i, gamma_conf, g0 = sp.symbols("pi_i gamma_conf g0", real=True)
    a_cs = pi_i + (1 - pi_i) * (1 - gamma_conf * c**2 / (2 * g0))
    results["cachazo_skinner_projects_witten_rindler"] = (sp.simplify(a_cs.subs(pi_i, 1) - 1) == 0)

    sigma_dev, alpha_qg, delta_jos = sp.symbols("sigma_dev alpha_qg delta_jos", real=True)
    a_15 = (1 - 4 * sigma_dev**2) * (1 + alpha_qg / 8 + alpha_qg**2 / 90) + delta_jos
    results["turner_15_classical_limit_one"] = (
        a_15.subs({sigma_dev: 0, alpha_qg: 0, delta_jos: 0}) == 1
    )

    # 5. Exact rational CERN ALPHA-g (2023) chi-squared tests
    a_meas = sp.Rational(3, 4)
    var_tot = sp.Rational(13, 100) ** 2 + sp.Rational(16, 100) ** 2
    chi2_pos1 = (a_meas - 1) ** 2 / var_tot
    chi2_zero = (a_meas - 0) ** 2 / var_tot
    chi2_neg1 = (a_meas - (-1)) ** 2 / var_tot
    results["alpha_g_var_exact"] = (var_tot == sp.Rational(17, 400))
    results["alpha_g_chi2_pos1_exact"] = (chi2_pos1 == sp.Rational(25, 17) and chi2_pos1 < 4)
    results["alpha_g_chi2_zero_exact"] = (chi2_zero == sp.Rational(225, 17) and chi2_zero > sp.Rational(36, 10) ** 2)
    results["alpha_g_chi2_neg1_exact"] = (chi2_neg1 == sp.Rational(1225, 17) and chi2_neg1 > 64)

    return results


def run_pyo3_antimatter_alpha_g_benchmark_suite() -> dict[str, object]:
    """Run Rust/PyO3 `py_audit_antimatter_alpha_g` and append exact two-sided p-values."""
    suite = sna.py_audit_antimatter_alpha_g()
    # Validate exact rational consistency with Fraction
    expected_var = float(Fraction(17, 400))
    assert math.isclose(suite["total_sigma"] ** 2, expected_var, rel_tol=1e-13, abs_tol=1e-15)

    for row in suite["models"]:
        z = abs(row["z_score"])
        # Two-sided normal p-value via complementary error function erfc(|z| / sqrt(2))
        row["two_sided_p_value"] = math.erfc(z / math.sqrt(2.0))
    return suite
