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

    # Cross-check 5-graph 3-regular Ramanujan tower vs. Barbell G_14 with Rust/PyO3
    audits = sna.py_audit_regular_graphs_bass_ihara()
    assert len(audits) == 5
    k33, pet, hea, mk16, bar = audits

    assert k33["is_regular"] and k33["is_connected"] and k33["is_ramanujan"]
    assert k33["max_nontrivial_abs_eigenvalue"] < 1e-11
    assert abs(k33["markov_spectral_gap"] - 1.0) < 1e-11
    assert k33["nontrivial_off_circle_count"] == 0

    assert pet["is_regular"] and pet["is_connected"] and pet["is_ramanujan"]
    assert pet["nontrivial_off_circle_count"] == 0

    assert hea["is_regular"] and hea["is_connected"] and hea["is_ramanujan"]
    assert abs(hea["max_nontrivial_abs_eigenvalue"] - math.sqrt(2.0)) < 1e-11
    assert hea["nontrivial_off_circle_count"] == 0

    assert mk16["is_regular"] and mk16["is_connected"] and mk16["is_ramanujan"]
    assert abs(mk16["max_nontrivial_abs_eigenvalue"] - math.sqrt(3.0)) < 1e-11
    assert mk16["nontrivial_off_circle_count"] == 0

    assert bar["is_regular"] and bar["is_connected"] and (not bar["is_ramanujan"])
    assert bar["max_nontrivial_abs_eigenvalue"] > 2.0 * math.sqrt(2.0)
    assert abs(bar["max_nontrivial_abs_eigenvalue"] - 2.8557725066) < 1e-8
    assert bar["ramanujan_margin"] < 0.0
    assert bar["markov_spectral_gap"] < pet["markov_spectral_gap"]
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
    # RB-1: Verify RS-C4 reaches the f64 phase-rounding floor (< 1e-11, > 150x lower error than RS-C2)
    leh_t = 7005.08185509661
    cmp_leh = sna.py_compare_rs_c2_vs_c4(leh_t)
    z_ref = float(mp.siegelz(mp.mpf(leh_t)))
    err_c2 = abs(cmp_leh["z_rs_c2"] - z_ref)
    err_c4 = abs(cmp_leh["z_rs_c4"] - z_ref)
    assert err_c4 < 1e-11
    assert err_c2 / err_c4 > 150.0


def test_pyo3_gram_violations_and_lehmer_1956_match_35digit_mpmath():
    mp.mp.dps = 35
    rep = sna.py_audit_gram_law_and_lehmer()

    # Cross-check Gram window against 35-digit mpmath (RB-1 exact Jet2 derivatives < 1e-8!)
    for row in rep["gram_window"]:
        m = row["gram_index"]
        gm_ref = mp.grampoint(m)
        z0_ref = float(mp.siegelz(gm_ref))
        z1_ref = float(mp.diff(mp.siegelz, gm_ref, 1))
        z2_ref = float(mp.diff(mp.siegelz, gm_ref, 2))
        j_ref = z1_ref**2 - z0_ref * z2_ref

        assert abs(row["gamma"] - float(gm_ref)) < 1e-10
        assert abs(row["z0"] - z0_ref) < 1e-10
        assert abs(row["z_prime"] - z1_ref) < 1e-9
        assert abs(row["z_double_prime"] - z2_ref) < 1e-8
        assert abs(row["j_total"] - j_ref) < 1e-7
        assert row["j_total"] > 0.0
        if m in (126, 134):
            assert not row["gram_holds"]
        else:
            assert row["gram_holds"]

    # Cross-check Lehmer 1956 pair (#6709 & #6710) against 35-digit mpmath
    leh = rep["lehmer_1956"]
    g6709_ref = float(mp.im(mp.zetazero(6709)))
    g6710_ref = float(mp.im(mp.zetazero(6710)))
    assert abs(leh["gamma_left"] - g6709_ref) < 1e-9
    assert abs(leh["gamma_right"] - g6710_ref) < 1e-9
    assert abs(leh["gap"] - (g6710_ref - g6709_ref)) < 1e-9
    # Verify corrected sign: positive peak Z(g*) > 0, Z''(g*) < 0, J_bohm = -Z Z'' > 0
    assert leh["z0"] > 0.0039 and leh["z_double_prime"] < -22.0
    assert abs(leh["j_bohm"] - 0.0886551841) < 1e-7
    assert abs(leh["bohm_ratio"] - 1.0) < 1e-9


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
        audit_lehmer_quartic_heat_and_neighbor_pressure,
        audit_weil_gaussian_gram_matrix,
        audit_weil_hermite_gaussian_gram_matrix,
        compute_exact_keiper_li_coefficients,
        verify_symbolic_rh_bridge_identities,
    )

    # 1. All 10 SymPy symbolic RH-bridge identities hold identically
    sym_res = verify_symbolic_rh_bridge_identities()
    assert len(sym_res) == 10
    assert all(sym_res.values()), f"Failed symbolic checks: {sym_res}"

    # 2. GORZ (PNAS 2019) positive-integral Jensen polynomials J^{d,n}(X) for d = 2..8
    gorz = audit_gorz_jensen_hyperbolicity(
        degrees=(2, 3, 4, 5, 6, 7, 8), n_max=10, dps=70
    )
    assert gorz["xi_half_moment_error"] < 1e-55
    for row in gorz["per_degree"]:
        assert row["all_real"], f"Non-real root found for degree {row['degree']}"
        assert row["max_imag"] == 0.0
        assert row["min_root_gap"] > 0.0
    assert all(r["strictly_hyperbolic"] for r in gorz["hermite3_residuals"])

    # 3. Exact infinite-zero Keiper–Li coefficients lambda_1..lambda_20
    kli = compute_exact_keiper_li_coefficients(max_n=20, dps=65)
    assert kli["all_positive"]
    assert kli["lambda_1_analytic_error"] < 1e-55
    assert abs(kli["lambdas"][0] - 0.023095708966121034) < 1e-15
    assert abs(kli["lambdas"][9] - 2.279339363193158) < 1e-12
    assert abs(kli["lambdas"][19] - 8.769276872093215) < 1e-11

    # 4. Exact 50-digit Weil Explicit-Formula 4x4 raw Gaussian vs 6x6 Orthonormal Hermite–Gaussian
    weil_raw = audit_weil_gaussian_gram_matrix(
        alphas=(40.0, 80.0, 160.0, 320.0), num_zeros=120, n_max=500, dps=50
    )
    assert weil_raw["max_prime_vs_zero_diff"] < 1e-45
    assert weil_raw["strictly_positive_definite"]
    raw_cond = max(weil_raw["eigenvalues_prime_arch"]) / min(weil_raw["eigenvalues_prime_arch"])

    weil_herm = audit_weil_hermite_gaussian_gram_matrix(
        dimension=6, alpha=100.0, num_zeros=120, n_max=500, dps=50
    )
    assert weil_herm["max_prime_vs_zero_diff"] < 1e-45
    assert weil_herm["strictly_positive_definite"]
    # Higher-dimensional (6x6) orthonormal Hermite-Gaussian beats 4x4 raw Gaussian conditioning,
    # and Strong Mpemba slow-mode projection collapses kappa from ~1,389 down to ~3.24 (>400x gain)!
    assert weil_herm["condition_number_full"] < raw_cond
    assert weil_herm["condition_number_mpemba_fast_subspace"] < 5.0
    assert weil_herm["mpemba_conditioning_gain"] > 400.0

    # 5. De Bruijn–Newman quadratic vs quartic backward heat & 10-zero Calogero–Moser squeeze
    dbn = audit_lehmer_dbn_backward_heat(dps=40)
    assert dbn["t_heat"] < 0.0 and dbn["t_calogero_moser"] < 0.0
    assert abs(dbn["t_heat"] - (-0.0001775410)) < 1e-8
    assert abs(dbn["ratio_t_heat_over_t_cm"] - 0.999403) < 1e-4

    dbn_q = audit_lehmer_quartic_heat_and_neighbor_pressure(dps=45)
    assert dbn_q["z4"] > 200.0
    assert dbn_q["t_quartic"] < dbn_q["t_quad"] < 0.0
    assert dbn_q["quartic_residual"] < 1e-40
    assert dbn_q["neighbor_squeeze_delta"] < 0.0
    assert abs(dbn_q["neighbor_squeeze_pct"] - (-0.1373)) < 1e-3


def test_celestial_holography_toupin_and_turner_model15_sympy_mpmath_pyo3():
    from sustainablefactory.riemann_rh_bridges import (
        audit_celestial_holography_toupin_and_turner_graviton,
    )

    # 1. Rust/PyO3 native celestial holography & Turner Model 15 audit
    rust_cel = sna.py_audit_celestial_holography_and_turner_graviton()
    assert rust_cel["plancherel_bose_max_diff"] < 1e-14
    assert rust_cel["m1_abs_error"] < 1e-12
    assert rust_cel["m2_abs_error"] < 1e-12
    assert rust_cel["m3_abs_error"] < 1e-12
    assert rust_cel["m3_quadrature"] < rust_cel["m3_upper_bound"]
    assert rust_cel["googly_principal_series_rel_err"] < 1e-14
    assert rust_cel["googly_off_line_symmetry_breaking"] > 0.1
    assert rust_cel["gr24_f2_points"] == 35
    assert rust_cel["gr24_f3_points"] == 130
    assert rust_cel["gr24_f5_points"] == 806
    assert rust_cel["gr24_f7_points"] == 2850
    assert rust_cel["gr24_rref_matches_polynomial"]
    assert abs(rust_cel["plancherel_two_loop_deficit_coeff"] - 13.0 / 2880.0) < 1e-16
    assert abs(rust_cel["cesaro_at_half"] - 1.0) < 1e-14
    assert rust_cel["cesaro_at_quarter"] > 10.0
    assert rust_cel["cesaro_at_three_quarters"] > 10.0
    assert rust_cel["cesaro_even_symmetry_diff"] < 1e-13
    assert abs(rust_cel["turner_model15_mercury_arcsec_century"] - 42.9814) < 0.01
    assert rust_cel["turner_model15_rel_err_vs_gr"] < 1e-15
    assert abs(rust_cel["turner_model15_solar_light_bending_arcsec"] - 1.7505) < 0.001
    assert abs(rust_cel["turner_model15_cayley_shadow_norm_at_half"] - 0.5) < 1e-15
    assert abs(rust_cel["turner_model15_cayley_shadow_norm_at_one"] - 0.2) < 1e-15
    assert rust_cel["turner_model15a_active_laser_deflection"] == 1.0
    assert rust_cel["turner_model15b_active_laser_deflection"] == 0.0

    # 2. SymPy + 45-digit mpmath celestial & Turner graviton audit
    py_cel = audit_celestial_holography_toupin_and_turner_graviton(dps=45)
    assert py_cel["dict_unique_ok"]
    assert py_cel["casimir_ok"]
    assert py_cel["hasse_weil_sym_ok"]
    assert py_cel["edge_deficit_ok"]
    assert py_cel["pathway3_counterexample_ok"]
    assert py_cel["sech4_fourier_ode_ok"]
    assert py_cel["cayley_and_all_loop_sym_ok"]
    assert abs(py_cel["b2_leading_pole_coeff"] - 8.0) < 1e-12
    assert py_cel["max_hasse_weil_euler_err"] < 1e-38
    assert py_cel["m1_error"] < 1e-40
    assert py_cel["m2_error"] < 1e-20
    assert py_cel["m3_error_vs_toupin_44digit"] < 1e-20
    assert py_cel["m3_even_chamber_part"] > 0.0
    assert py_cel["m3_odd_chamber_excess"] > 0.0
    assert py_cel["f_zero_err"] < 1e-20
    assert py_cel["full_line_conv_err"] < 1e-20
    assert py_cel["toupin_eq8281_discrepancy_s2"] > 0.9
    assert py_cel["bpy_err_s2"] < 1e-40
    assert py_cel["bpy_err_s3"] < 1e-40
    assert abs(rust_cel["m3_quadrature"] - py_cel["m3_value"]) < 1e-12
    assert abs(rust_cel["m3_even_part"] - py_cel["m3_even_chamber_part"]) < 1e-12
    assert abs(rust_cel["m3_odd_excess"] - py_cel["m3_odd_chamber_excess"]) < 1e-12


def test_celestial_ir_regularization_and_turner_model16_sympy_mpmath_pyo3():
    from sustainablefactory.riemann_rh_bridges import (
        audit_celestial_ir_and_turner_model16,
    )

    rust_16 = sna.py_audit_celestial_ir_and_turner_model16()
    assert rust_16["rg_sigma_dev_su3"] > 0.0
    assert rust_16["rg_casimir_im_nonzero"] > 0.0
    assert rust_16["k_ir_uv_at_zero"] == 0.0
    assert 0.0 < rust_16["k_ir_uv_at_one"] < 1.0
    assert rust_16["k_ir_uv_unreg_limit_diff"] < 1e-16
    assert rust_16["kl_mellin_mgap_1"] > 0.0
    assert rust_16["kl_mellin_mgap_0_vs_gamma"] < 1e-8
    assert rust_16["yukawa_mellin_quad_vs_gamma_diff"] < 1e-11
    assert abs(rust_16["s_ir_zero"] - 1.0) < 1e-16
    assert abs(rust_16["g16_classical"] - 1.0) < 1e-16
    assert rust_16["g16_off_line_positive"] > 0.0
    assert abs(rust_16["model16a_mercury_arcsec_cy"] - 42.9814) < 0.01
    assert abs(rust_16["model16b_mercury_arcsec_cy"] - 42.9814) < 0.01
    assert rust_16["model16_rel_err_vs_gr"] < 1e-15
    assert abs(rust_16["model16_solar_light_bending_arcsec"] - 1.7505) < 0.001
    assert rust_16["model16a_gw_below_gap"] == 0.0
    assert rust_16["model16b_gw_gapless_ratio"] > 0.9999999999
    assert rust_16["model16a_active_laser_deflection"] == 1.0
    assert rust_16["model16b_active_laser_deflection"] == 0.0
    assert abs(rust_16["d_cft_4d_re_delta"] - 1.0) < 1e-16

    py_16 = audit_celestial_ir_and_turner_model16(dps=45)
    assert py_16["rg_casimir_ok"]
    assert py_16["toutrr_intertwine_ok"]
    assert py_16["ir_kernel_sym_ok"]
    assert py_16["s_ir_taylor_ok"]
    assert py_16["g16_reduction_ok"]
    assert py_16["kl_crit_soft_finite_abs"] > 0.0
    assert py_16["kl_crit_bessel_err"] < 1e-35
    assert py_16["kl_m0_gamma_err"] < 1e-25
    assert py_16["yukawa_complex_gamma_err"] < 1e-25
    assert abs(rust_16["g16_off_line_positive"] - py_16["g16_off_line"]) < 1e-15
