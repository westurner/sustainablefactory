"""
Tri-language verification suite (SymPy + 35-digit mpmath + Rust/PyO3 `signals_numerical_adapter`)
for `Signals.RiemannSpectral` and `docs/grassmannian-riemann-spectral-ihara-jensen-polya-paper.md`.

Verifies:
1. Exact SymPy symbolic identities (Sato Hirota Plücker, Laguerre–Pólya product closure,
   Cauchy–Riemann transverse QFIM = Jensen–Pólya discriminant, Li unit-circle equivalence,
   and exact characteristic & Bass–Ihara polynomials of Petersen, Heawood, and 14-vertex
   3-regular non-Ramanujan Barbell graph G_14).
2. Rust/PyO3 Euler–Maclaurin + Riemann–Siegel (C_0, C_1, C_2) first 30 nontrivial zeros
   cross-checked against 35-digit `mpmath.zetazero` (< 1e-11 error across all 30 zeros).
3. Rust/PyO3 Gram's Law violations (g_126, g_134) and Lehmer's 1956 near-miss pair
   (#6709 & #6710) cross-checked against 35-digit `mpmath.siegelz`, auditing and correcting
   the uncomputed chat check-figure table.
4. Rust/PyO3 finite-graph Bass–Ihara Ramanujan dichotomy (Petersen & Heawood vs. Barbell G_14).
5. Rust/PyO3 Li partial coefficients (positive on critical line; negative under off-line quartet).
"""

import math
import mpmath as mp
import sympy as sp

import signals_numerical_adapter as sna


def _adj_petersen():
    a = [[0] * 10 for _ in range(10)]
    for i in range(5):
        for u, v in [(i, (i + 1) % 5), (5 + i, 5 + (i + 2) % 5), (i, 5 + i)]:
            a[u][v] = a[v][u] = 1
    return sp.Matrix(a)


def _adj_heawood():
    a = [[0] * 14 for _ in range(14)]
    for i in range(14):
        j1 = (i + 1) % 14
        a[i][j1] = a[j1][i] = 1
        if i % 2 == 0:
            j2 = (i + 5) % 14
            a[i][j2] = a[j2][i] = 1
    return sp.Matrix(a)


def _adj_barbell_14():
    half = [
        (0, 1), (0, 2), (1, 3), (1, 4), (2, 5),
        (2, 6), (3, 4), (3, 5), (4, 6), (5, 6),
    ]
    a = [[0] * 14 for _ in range(14)]
    for u, v in half:
        a[u][v] = a[v][u] = 1
        a[u + 7][v + 7] = a[v + 7][u + 7] = 1
    a[0][7] = a[7][0] = 1
    return sp.Matrix(a)


def test_sympy_symbolic_spectral_and_plucker_identities():
    # 1. Sato Wronskian Hirota Plücker identity
    f1, f2, f3, f4, df1, df2, df3, df4 = sp.symbols("f1 f2 f3 f4 df1 df2 df3 df4")
    w = lambda fi, fj, dfi, dfj: fi * dfj - fj * dfi
    hirota = (
        w(f1, f2, df1, df2) * w(f3, f4, df3, df4)
        - w(f1, f3, df1, df3) * w(f2, f4, df2, df4)
        + w(f1, f4, df1, df4) * w(f2, f3, df2, df3)
    )
    assert sp.expand(hirota) == 0

    # 2. Laguerre–Pólya multiplicative closure J(fg) = g^2 J(f) + f^2 J(g)
    f0, f1p, f2p, g0, g1p, g2p = sp.symbols("f0 f1p f2p g0 g1p g2p")
    J = lambda z0, z1, z2: z1**2 - z0 * z2
    lhs = J(f0 * g0, f1p * g0 + f0 * g1p, f2p * g0 + 2 * f1p * g1p + f0 * g2p)
    rhs = g0**2 * J(f0, f1p, f2p) + f0**2 * J(g0, g1p, g2p)
    assert sp.expand(lhs - rhs) == 0

    # 3. Cauchy–Riemann transverse QFIM = Jensen–Pólya discriminant
    z0, z1, z2, sig = sp.symbols("z0 z1 z2 sig", real=True)
    e_cr = (z0 - sp.Rational(1, 2) * z2 * sig**2) ** 2 + (z1 * sig) ** 2
    assert sp.expand(e_cr - (z0**2 + J(z0, z1, z2) * sig**2 + sp.Rational(1, 4) * z2**2 * sig**4)) == 0
    assert sp.simplify(sp.Rational(1, 2) * sp.diff(e_cr, sig, 2).subs(sig, 0) - J(z0, z1, z2)) == 0

    # 4. Li unit-circle characterization: |1 - 1/rho|^2 - 1 = -2*sigma_dev / |rho|^2
    s_dev, gam = sp.symbols("s_dev gam", real=True)
    mod_sq = ((s_dev - sp.Rational(1, 2)) ** 2 + gam**2) / (
        (s_dev + sp.Rational(1, 2)) ** 2 + gam**2
    )
    diff_one = sp.factor(mod_sq - 1)
    assert sp.simplify(diff_one + 2 * s_dev / ((s_dev + sp.Rational(1, 2)) ** 2 + gam**2)) == 0


def test_sympy_and_pyo3_bass_ihara_ramanujan_vs_barbell_14():
    x, u = sp.symbols("x u")

    # Exact SymPy factored characteristic polynomials
    cp_pet = sp.factor(_adj_petersen().charpoly(x).as_expr())
    assert cp_pet == (x - 3) * (x - 1) ** 5 * (x + 2) ** 4

    cp_hea = sp.factor(_adj_heawood().charpoly(x).as_expr())
    assert cp_hea == (x - 3) * (x + 3) * (x**2 - 2) ** 6

    cp_bar = sp.factor(_adj_barbell_14().charpoly(x).as_expr())
    assert cp_bar == x**2 * (x - 3) * (x + 2) ** 2 * (x**2 - 2) ** 3 * (
        x**3 - x**2 - 6 * x + 2
    )

    # Exact Bass–Ihara determinant for Barbell G_14 includes factor (1 - lam*u + 2*u^2)
    # for the cubic non-Ramanujan polynomial x^3 - x^2 - 6*x + 2
    det_bar = sp.factor((sp.eye(14) - u * _adj_barbell_14() + 2 * u**2 * sp.eye(14)).det())
    # Substitute u = 1/x to verify reciprocity with charpoly
    cubic_factor = 8 * u**6 - 4 * u**5 - 12 * u**4 + 6 * u**3 - 6 * u**2 - u + 1
    # Check remainder is zero when dividing det_bar by the cubic's Bass-Ihara resultant
    res = sp.resultant(x**3 - x**2 - 6 * x + 2, 2 * u**2 - x * u + 1, x)
    assert sp.simplify(sp.rem(det_bar, sp.Poly(res, u), u)) == 0

    # Cross-check with Rust/PyO3
    audits = sna.py_audit_regular_graphs_bass_ihara()
    assert len(audits) == 3
    pet, hea, bar = audits

    assert pet["is_regular"] and pet["is_connected"] and pet["is_ramanujan"]
    assert pet["nontrivial_off_circle_count"] == 0

    assert hea["is_regular"] and hea["is_connected"] and hea["is_ramanujan"]
    assert abs(hea["max_nontrivial_abs_eigenvalue"] - math.sqrt(2.0)) < 1e-11
    assert hea["nontrivial_off_circle_count"] == 0

    assert bar["is_regular"] and bar["is_connected"] and (not bar["is_ramanujan"])
    assert bar["max_nontrivial_abs_eigenvalue"] > 2.0 * math.sqrt(2.0)
    assert abs(bar["max_nontrivial_abs_eigenvalue"] - 2.8557725066) < 1e-8
    assert bar["nontrivial_off_circle_count"] == 2

    off_roots = [r for r in bar["roots"] if (not r["is_trivial"]) and (not r["on_critical_circle"])]
    assert len(off_roots) == 2
    assert abs(off_roots[0]["u_re"] * off_roots[1]["u_re"] - 0.5) < 1e-12


def test_pyo3_first_30_zeros_match_35digit_mpmath():
    mp.mp.dps = 35
    zeros = sna.py_find_first_n_riemann_zeros(30)
    assert len(zeros) == 30

    max_gamma_err = 0.0
    max_rs_c2_res = 0.0
    for k, z in enumerate(zeros, start=1):
        ref = float(mp.im(mp.zetazero(k)))
        err = abs(z["gamma"] - ref)
        max_gamma_err = max(max_gamma_err, err)
        max_rs_c2_res = max(max_rs_c2_res, abs(z["hardy_z_riemann_siegel_c2"]))
        assert err < 1e-11, f"Zero #{k}: rust={z['gamma']} vs mpmath={ref}, err={err}"
        assert z["zeta_abs"] < 1e-11
        assert z["jensen_polya_j"] > 0.0

    assert max_gamma_err < 1e-11
    assert max_rs_c2_res < 1e-4


def test_pyo3_gram_violations_and_lehmer_1956_match_35digit_mpmath():
    mp.mp.dps = 35
    rep = sna.py_audit_gram_law_and_lehmer()

    # Cross-check Gram window against 35-digit mpmath
    for row in rep["gram_window"]:
        m = row["gram_index"]
        gm_ref = mp.grampoint(m)
        z0_ref = float(mp.siegelz(gm_ref))
        z1_ref = float(mp.diff(mp.siegelz, gm_ref, 1))
        z2_ref = float(mp.diff(mp.siegelz, gm_ref, 2))
        j_ref = z1_ref**2 - z0_ref * z2_ref

        assert abs(row["gamma"] - float(gm_ref)) < 1e-9
        assert abs(row["z0"] - z0_ref) < 1e-9
        assert abs(row["j_total"] - j_ref) < 1e-4
        assert row["j_total"] > 0.0
        if m in (126, 134):
            assert not row["gram_holds"]
        else:
            assert row["gram_holds"]

    # Cross-check Lehmer 1956 pair (#6709 & #6710) against 35-digit mpmath
    leh = rep["lehmer_1956"]
    g6709_ref = float(mp.im(mp.zetazero(6709)))
    g6710_ref = float(mp.im(mp.zetazero(6710)))
    assert abs(leh["gamma_left"] - g6709_ref) < 1e-6
    assert abs(leh["gamma_right"] - g6710_ref) < 1e-6
    assert abs(leh["gap"] - (g6710_ref - g6709_ref)) < 1e-6
    # Verify corrected sign: positive peak Z(g*) > 0, Z''(g*) < 0, J_bohm = -Z Z'' > 0
    assert leh["z0"] > 0.0039 and leh["z_double_prime"] < -22.0
    assert abs(leh["j_bohm"] - 0.088655) < 5e-4
    assert abs(leh["bohm_ratio"] - 1.0) < 1e-4


def test_pyo3_li_partial_coefficients_critical_vs_off_line_quartet():
    zeros = sna.py_find_first_n_riemann_zeros(30)
    gammas = [z["gamma"] for z in zeros]

    crit_li = sna.py_li_partial_coefficients(gammas, 100)
    assert all(v > 0.0 for v in crit_li)

    off_li = sna.py_li_partial_coefficients(gammas, 5000, 0.20, gammas[0])
    neg_indices = [i + 1 for i, v in enumerate(off_li) if v < 0.0]
    assert len(neg_indices) > 0


def test_sympy_rh_analytical_bridges_gorz_keiper_li_weil_and_dbn():
    from sustainablefactory.riemann_rh_bridges import (
        audit_gorz_jensen_hyperbolicity,
        audit_lehmer_dbn_backward_heat,
        audit_weil_gaussian_gram_matrix,
        compute_exact_keiper_li_coefficients,
        verify_symbolic_rh_bridge_identities,
    )

    # 1. All 7 SymPy symbolic RH-bridge identities hold identically
    sym_res = verify_symbolic_rh_bridge_identities()
    assert all(sym_res.values()), f"Failed symbolic checks: {sym_res}"

    # 2. GORZ (PNAS 2019) positive-integral Jensen polynomials J^{d,n}(X) for d = 2..6
    gorz = audit_gorz_jensen_hyperbolicity(degrees=(2, 3, 4, 5, 6), n_max=10, dps=65)
    assert gorz["xi_half_moment_error"] < 1e-50
    for row in gorz["per_degree"]:
        assert row["all_real"], f"Non-real root found for degree {row['degree']}"
        assert row["max_imag"] == 0.0
        assert row["min_root_gap"] > 0.0
    assert all(r["strictly_hyperbolic"] for r in gorz["hermite3_residuals"])

    # 3. Exact infinite-zero Keiper–Li coefficients lambda_1..lambda_15
    kli = compute_exact_keiper_li_coefficients(max_n=15, dps=60)
    assert kli["all_positive"]
    assert kli["lambda_1_analytic_error"] < 1e-50
    assert abs(kli["lambdas"][0] - 0.023095708966121034) < 1e-15
    assert abs(kli["lambdas"][9] - 2.279339363193158) < 1e-12

    # 4. Exact 50-digit Weil Explicit-Formula 4x4 Gaussian Gram matrix (Prime+Arch vs Zero)
    weil = audit_weil_gaussian_gram_matrix(
        alphas=(40.0, 80.0, 160.0, 320.0), num_zeros=120, n_max=500, dps=50
    )
    assert weil["max_prime_vs_zero_diff"] < 1e-45
    assert weil["strictly_positive_definite"]
    assert min(weil["eigenvalues_prime_arch"]) > 3.4e-5

    # 5. De Bruijn–Newman backward heat collision on Lehmer's 1956 pair
    dbn = audit_lehmer_dbn_backward_heat(dps=40)
    assert dbn["t_heat"] < 0.0 and dbn["t_calogero_moser"] < 0.0
    assert abs(dbn["t_heat"] - (-0.0001775410)) < 1e-8
    assert abs(dbn["ratio_t_heat_over_t_cm"] - 0.999403) < 1e-4
