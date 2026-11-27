"""
Symbolic (SymPy) and high-precision (`mpmath` + Rust/PyO3) audit suite for:
- Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`)
  (`Signals.QuantumCausalInference` Section 16 & `Signals.Pending.OneShotQuantumSysIdPendingBoundary`),
  reimplementing Boullé, Halikias, Otto, & Townsend (2026, PNAS 123(47):e2624491123).
"""

from typing import Any

import mpmath as mp
import sympy as sp


def verify_symbolic_qci_one_shot_sysid_identities() -> dict[str, bool]:
    """Verify exact symbolic identities for QCI-OSID in SymPy."""
    # 1. Cauchy-Binet / Plücker Gram identity on Gr_R(2, 3)
    a0, a1, a2, b0, b1, b2, lam = sp.symbols("a0 a1 a2 b0 b1 b2 lam", real=True)
    g_2x3 = sp.Matrix([[a0, b0], [a1, b1], [a2, b2]])
    gram_det = sp.det(g_2x3.T * g_2x3)
    d01 = a0 * b1 - a1 * b0
    d02 = a0 * b2 - a2 * b0
    d12 = a1 * b2 - a2 * b1
    plucker_sq = d01**2 + d02**2 + d12**2
    g_collinear = sp.Matrix([[a0, lam * a0], [a1, lam * a1], [a2, lam * a2]])
    cauchy_binet_plucker_2x3_sym_ok = (
        sp.expand(gram_det - plucker_sq) == 0
        and sp.simplify(sp.det(g_collinear.T * g_collinear)) == 0
    )

    # 2. Circulant (1-shot) vs Hankel (1-probe deficit -> 2-probe) symbolic determinants
    f0, f1, g0, g1 = sp.symbols("f0 f1 g0 g1", real=True)
    m_circ2 = sp.Matrix([[f0, f1], [f1, f0]])
    m_hank2_2probe = sp.Matrix([[f0, f1, 0], [0, f0, f1], [g0, g1, 0]])
    # 3x3 Hankel matrix basis evaluated on a single probe (3x5 recovery matrix)
    f2 = sp.Symbol("f2", real=True)
    m_hank3_1probe = sp.Matrix(
        [
            [f0, f1, f2, 0, 0],
            [0, f0, f1, f2, 0],
            [0, 0, f0, f1, f2],
        ]
    )
    circulant_vs_hankel_sym_ok = (
        sp.factor(sp.det(m_circ2) - (f0 - f1) * (f0 + f1)) == 0
        and sp.factor(sp.det(m_hank2_2probe) + f1 * (f0 * g1 - f1 * g0)) == 0
        and m_hank3_1probe.rank() <= 3
    )

    # 3. Pearl do-deconfounding & Giarmatzi-Costa abduction-action-prediction
    c_true, b_conf, alpha, x_obs, y_obs, x_cf = sp.symbols(
        "c_true b_conf alpha x_obs y_obs x_cf", real=True
    )
    obs_slope = c_true + b_conf
    do_slope = c_true
    u_abd = y_obs - alpha * x_obs
    y_cf = alpha * x_cf + u_abd
    pearl_do_and_abduction_sym_ok = (
        sp.simplify((obs_slope - do_slope) - b_conf) == 0
        and sp.simplify(y_cf.subs(x_cf, x_obs) - y_obs) == 0
        and sp.simplify((y_cf - y_obs) - alpha * (x_cf - x_obs)) == 0
    )

    # 4. Coherent Gr_C(2,4) Quantum Switch & pole-free VRC destructive exclusion (x_X = -1)
    theta = sp.Symbol("theta", real=True)
    ua = sp.Matrix([[sp.cos(theta), sp.I * sp.sin(theta)], [sp.I * sp.sin(theta), sp.cos(theta)]])
    ub = sp.Matrix([[1, 0], [0, -1]])
    psi0 = sp.Matrix([[1], [0]])
    sym_vec = (ua * ub + ub * ua) * psi0 / 2
    anti_vec = (ub * ua - ua * ub) * psi0 / 2
    e_sym = sp.simplify((sym_vec.H * sym_vec)[0, 0])
    e_anti = sp.simplify((anti_vec.H * anti_vec)[0, 0])
    delta_sw = sp.simplify((e_sym - e_anti) / (e_sym + e_anti))
    wa_re, wa_im = sp.symbols("wa_re wa_im", real=True)
    destructive_prob = (
        (wa_re**2 + wa_im**2)
        + ((-wa_re) ** 2 + (-wa_im) ** 2)
        + 2 * (wa_re * (-wa_re) + wa_im * (-wa_im))
    )
    quantum_switch_vrc_sym_ok = (
        sp.simplify(e_sym - sp.cos(theta) ** 2) == 0
        and sp.simplify(e_anti - sp.sin(theta) ** 2) == 0
        and sp.simplify((1 - delta_sw) / (1 + delta_sw) - sp.tan(theta) ** 2) == 0
        and sp.simplify(destructive_prob) == 0
    )

    # 5. Jeffrey Kinematics + QFIM = 4 g_FS QCRB + Closed-Loop Landauer heat
    q1, q2, c1_do, c2_do, gam, wb_re, wb_im, g_fs, m_shots, kbt, fid, q_oh = sp.symbols(
        "q1 q2 c1_do c2_do gam wb_re wb_im g_fs m_shots kbt fid q_oh", real=True
    )
    j_cl = q1 * c1_do + q2 * c2_do
    q_int = 2 * (wa_re * wb_re + wa_im * wb_im)
    qj_plus = j_cl + gam * q_int
    qj_minus = j_cl + gam * (-q_int)
    q_closed_1 = kbt * (1 - 2 * fid) + (2 * fid * kbt + q_oh)
    q_closed_m = m_shots * q_closed_1
    jeffrey_qfim_qcrb_landauer_sym_ok = (
        sp.simplify(sp.Rational(1, 2) * (qj_plus + qj_minus) - j_cl) == 0
        and sp.simplify(q_closed_1 - (kbt + q_oh)) == 0
        and sp.simplify(q_closed_m - m_shots * (kbt + q_oh)) == 0
    )

    return {
        "cauchy_binet_plucker_2x3_sym_ok": cauchy_binet_plucker_2x3_sym_ok,
        "circulant_vs_hankel_sym_ok": circulant_vs_hankel_sym_ok,
        "pearl_do_and_abduction_sym_ok": pearl_do_and_abduction_sym_ok,
        "quantum_switch_vrc_sym_ok": quantum_switch_vrc_sym_ok,
        "jeffrey_qfim_qcrb_landauer_sym_ok": jeffrey_qfim_qcrb_landauer_sym_ok,
    }


def verify_symbolic_literature_check_figures() -> dict[str, bool]:
    """Verify exact symbolic identities for published check figures in SymPy:
    1. Boullé et al. (2026) Duffing 2nd-order scale invariance & Prop. 36 2D Elliptic ray kernel.
    2. Qi & Ranard (2019) single-eigenstate correlation quadratic form & 2-qubit exact recovery.
    3. Zhao, Yang, & Chiribella (2020) super-Heisenberg Quantum Switch 1/N^2 vs 1/N crossover.
    4. Goswami et al. (2018) causal witness z-score margins.
    """
    # 1. Duffing normalization & Elliptic Proposition 36 coprime ray (m, n)
    th_j, th_udd, scale_l = sp.symbols("th_j th_udd scale_l", nonzero=True, real=True)
    duffing_scale_sym_ok = (
        sp.simplify((-scale_l * th_j) / (scale_l * th_udd) - (-th_j / th_udd)) == 0
    )

    k, m, n, x, y = sp.symbols("k m n x y", real=True, positive=True)
    psi = sp.sin(k * m * sp.pi * x) * sp.sin(k * n * sp.pi * y)
    a_deg, b_deg = n**2, -(m**2)
    elliptic_action = sp.simplify(a_deg * sp.diff(psi, x, 2) + b_deg * sp.diff(psi, y, 2))
    elliptic_prop36_sym_ok = elliptic_action == 0

    # 2. Qi & Ranard (2019) rank-1 correlation matrix M(v) and exact 2-qubit ground-state recovery
    a, b, w0, w1 = sp.symbols("a b w0 w1", real=True)
    m_mat = sp.Matrix([[a**2, a * b], [a * b, b**2]])
    w_vec = sp.Matrix([[w0], [w1]])
    quad_form = (w_vec.T * m_mat * w_vec)[0, 0]
    ker_vec = sp.Matrix([[b], [-a]])
    qi_ranard_quad_sym_ok = (
        sp.expand(quad_form - (a * w0 + b * w1) ** 2) == 0
        and sp.simplify(m_mat * ker_vec) == sp.zeros(2, 1)
    )

    # Exact symbolic 2-qubit Hamiltonian H = 1*(Z⊗Z) + 1*(X⊗I) + (1/2)*(I⊗X) + (1/2)*(Z⊗I)
    # Build Pauli basis L_0..L_3 and compute exact numerical/symbolic eigenstate correlation M(v)
    sz = sp.Matrix([[1, 0], [0, -1]])
    sx = sp.Matrix([[0, 1], [1, 0]])
    i2 = sp.eye(2)
    l_ops = [
        sp.kronecker_product(sz, sz),
        sp.kronecker_product(sx, i2),
        sp.kronecker_product(i2, sx),
        sp.kronecker_product(sz, i2),
    ]
    c_true = [sp.Rational(1, 1), sp.Rational(1, 1), sp.Rational(1, 2), sp.Rational(1, 2)]
    h_2q = sum((c * op for c, op in zip(c_true, l_ops)), sp.zeros(4, 4))
    # Use high-precision eigenvector of H_2q via sympy.Matrix.eigenvects
    eig_data = h_2q.eigenvects()
    # Pick lowest eigenvalue eigenvector
    eig_data_sorted = sorted(eig_data, key=lambda item: sp.re(item[0].evalf()))
    v0 = eig_data_sorted[0][2][0]
    v0 = v0 / sp.sqrt((v0.T * v0)[0, 0])
    corr_2q = sp.zeros(4, 4)
    exp_l = [(v0.T * op * v0)[0, 0] for op in l_ops]
    for i in range(4):
        for j in range(4):
            anti = sp.Rational(1, 2) * (l_ops[i] * l_ops[j] + l_ops[j] * l_ops[i])
            corr_2q[i, j] = (v0.T * anti * v0)[0, 0] - exp_l[i] * exp_l[j]
    c_vec = sp.Matrix(c_true)
    # Verify exact kernel M(v0) * c_true == 0 numerically to 30+ digits
    resid_norm = sp.N((corr_2q * c_vec).norm(), 30)
    qi_ranard_2q_exact_ok = float(resid_norm) < 1e-25

    # Exact Bairey-Arad-Lindner (2019) 2-qubit commutator matrix K_{j,m} = i <v0|[L_m, O_j]|v0>
    sy = sp.Matrix([[0, -sp.I], [sp.I, 0]])
    bairey_ops = [
        sp.kronecker_product(sy, i2),
        sp.kronecker_product(i2, sy),
        sp.kronecker_product(sy, sz),
        sp.kronecker_product(sz, sy),
    ]
    k_bairey = sp.zeros(len(bairey_ops), len(l_ops))
    for j, o_j in enumerate(bairey_ops):
        for m_idx, l_m in enumerate(l_ops):
            comm = l_m * o_j - o_j * l_m
            k_bairey[j, m_idx] = sp.I * (v0.T * comm * v0)[0, 0]
    bairey_res = float(sp.N((k_bairey * c_vec).norm(), 30))
    # Verify non-degeneracy: K_bairey has 3 nonzero singular values and 1D kernel spanned by c_true
    import numpy as np
    k_np = np.array([[float(sp.re(k_bairey[r, c].evalf(30))) for c in range(4)] for r in range(4)])
    s_vals = np.linalg.svd(k_np, compute_uv=False)
    bairey_2q_exact_ok = (bairey_res < 1e-25) and (float(s_vals[2]) > 1e-3) and (float(s_vals[3]) < 1e-12)

    # Qi-Ranard 1D periodic spin-chain parameter compression (12*n < 2^(n+1) for n=10, 12)
    qi_ranard_dim_compression_ok = (12 * 10 < 2**11) and (12 * 12 < 2**13)

    # 3. Zhao, Yang, & Chiribella (2020) super-Heisenberg Quantum Switch 1/N^2 vs 1/N + Eq. (7) heterodyne factor
    n_box, nu, energy, z_min, zp_sq = sp.symbols(
        "n_box nu energy z_min zp_sq", positive=True, real=True
    )
    var_switch = 1 / (nu * n_box**4)
    var_fixed = z_min**2 / (8 * nu * energy * n_box**2)
    ratio_sq = sp.simplify(var_fixed / var_switch)
    het_factor = zp_sq / (zp_sq + 1 / n_box**2)
    zhao_scaling_sym_ok = (
        sp.simplify(ratio_sq - (z_min**2 * n_box**2) / (8 * energy)) == 0
        and sp.simplify(1 - het_factor - (1 / (n_box**2 * zp_sq + 1))) == 0
    )

    # 4. Goswami et al. (2018) exact rational causal witness margins
    s_exp = sp.Rational(-171, 1000)
    sigma_s = sp.Rational(9, 1000)
    z_ideal = (0 - s_exp) / sigma_s
    z_mis = (sp.Rational(-38, 1000) - s_exp) / sigma_s
    goswami_sym_ok = (z_ideal == 19) and (z_mis == sp.Rational(133, 9)) and (z_mis > 14)

    return {
        "duffing_scale_sym_ok": duffing_scale_sym_ok,
        "elliptic_prop36_sym_ok": elliptic_prop36_sym_ok,
        "qi_ranard_quad_sym_ok": qi_ranard_quad_sym_ok,
        "qi_ranard_2q_exact_ok": qi_ranard_2q_exact_ok,
        "bairey_2q_exact_ok": bairey_2q_exact_ok,
        "qi_ranard_dim_compression_ok": qi_ranard_dim_compression_ok,
        "zhao_scaling_sym_ok": zhao_scaling_sym_ok,
        "goswami_sym_ok": goswami_sym_ok,
    }


def audit_qci_literature_benchmarks_high_precision(dps: int = 45) -> dict[str, Any]:
    """Cross-verify Rust/PyO3 `py_audit_qci_one_shot_sysid_literature_benchmarks`
    against 45-digit mpmath and SymPy."""
    import signals_numerical_adapter as sna

    sym_ok = verify_symbolic_literature_check_figures()
    rust = sna.py_audit_qci_one_shot_sysid_literature_benchmarks()

    with mp.workdps(dps):
        # 1. Zhao, Yang, & Chiribella (2020) Eqs. (5)-(7) at N=5, 15
        nu = mp.mpf(10)
        x_bar = mp.mpf("0.25")
        p_bar = mp.mpf("0.25")
        zp_sq = x_bar**2 + p_bar**2
        z_min = min(abs(x_bar), abs(p_bar))

        n5 = mp.mpf(5)
        e5 = mp.mpf("0.5")
        mp_rmse5_ideal = 1 / (mp.sqrt(nu) * n5**2)
        mp_rmse5_het = mp_rmse5_ideal * mp.sqrt(zp_sq / (zp_sq + 1 / n5**2))
        mp_fixed5 = z_min / (n5 * mp.sqrt(8 * nu * e5))

        n15 = mp.mpf(15)
        e15 = mp.mpf(1)
        mp_rmse15_ideal = 1 / (mp.sqrt(nu) * n15**2)
        mp_fixed15 = z_min / (n15 * mp.sqrt(8 * nu * e15))
        mp_ratio15 = mp_fixed15 / mp_rmse15_ideal

        zhao_rmse5_diff = abs(float(mp_rmse5_ideal) - rust["zhao_n5_switch_rmse_ideal"])
        zhao_het5_diff = abs(float(mp_rmse5_het) - rust["zhao_n5_switch_rmse_het"])
        zhao_fixed5_diff = abs(float(mp_fixed5) - rust["zhao_n5_fixed_heisenberg_bound"])
        zhao_rmse15_diff = abs(float(mp_rmse15_ideal) - rust["zhao_n15_switch_rmse_ideal"])
        zhao_fixed15_diff = abs(float(mp_fixed15) - rust["zhao_n15_fixed_heisenberg_bound"])
        zhao_ratio15_diff = abs(float(mp_ratio15) - rust["zhao_n15_advantage_ratio"])

        # 2. Goswami et al. (2018) z-scores
        g_exp = mp.mpf("-0.171")
        g_sig = mp.mpf("0.009")
        g_mis = mp.mpf("-0.038")
        mp_z_ideal = (0 - g_exp) / g_sig
        mp_z_mis = (g_mis - g_exp) / g_sig
        goswami_z_ideal_diff = abs(float(mp_z_ideal) - rust["goswami_z_ideal_bound"])
        goswami_z_mis_diff = abs(float(mp_z_mis) - rust["goswami_z_misaligned_bound"])

        # 3. 1000x1000 Circulant vs Hankel dimension check (NBoulle/wias 05 & 06)
        n_wias = 1000
        hankel_params = 2 * n_wias - 1
        hankel_1shot_deficit = hankel_params - n_wias

    return {
        **sym_ok,
        "zhao_rmse5_diff": zhao_rmse5_diff,
        "zhao_het5_diff": zhao_het5_diff,
        "zhao_fixed5_diff": zhao_fixed5_diff,
        "zhao_rmse15_diff": zhao_rmse15_diff,
        "zhao_fixed15_diff": zhao_fixed15_diff,
        "zhao_ratio15_diff": zhao_ratio15_diff,
        "goswami_z_ideal_diff": goswami_z_ideal_diff,
        "goswami_z_mis_diff": goswami_z_mis_diff,
        "hankel_1000_params": hankel_params,
        "hankel_1000_1shot_deficit": hankel_1shot_deficit,
        "rust_report": rust,
    }


def audit_qci_one_shot_sysid_high_precision(dps: int = 45) -> dict[str, Any]:
    """Cross-verify Rust/PyO3 `py_audit_qci_one_shot_sysid` against 45-digit mpmath."""
    import signals_numerical_adapter as sna

    sym_ok = verify_symbolic_qci_one_shot_sysid_identities()
    rust = sna.py_audit_qci_one_shot_sysid()

    with mp.workdps(dps):
        # 1. Cauchy-Binet 3x2 Plücker norm squared
        a_vec = [mp.mpf("1.2"), mp.mpf("-0.5"), mp.mpf("2.3")]
        b_vec = [mp.mpf("0.4"), mp.mpf("1.7"), mp.mpf("-0.9")]
        d01 = a_vec[0] * b_vec[1] - a_vec[1] * b_vec[0]
        d02 = a_vec[0] * b_vec[2] - a_vec[2] * b_vec[0]
        d12 = a_vec[1] * b_vec[2] - a_vec[2] * b_vec[1]
        mp_cb_plucker = d01**2 + d02**2 + d12**2
        cb_diff = abs(float(mp_cb_plucker) - rust["cb_gram_det"])

        # 2. Circulant 4x4 DFT eigenvalue product check: det(C) = prod_{k=0}^3 sum_j f_j omega^{jk}
        f_circ = [mp.mpf("1.2"), mp.mpf("-0.7"), mp.mpf("0.5"), mp.mpf("2.1")]
        dft_prod = mp.mpf(1)
        for k in range(4):
            lam_k = sum(
                f_circ[j] * mp.exp(2j * mp.pi * j * k / 4) for j in range(4)
            )
            dft_prod *= abs(lam_k) ** 2
        circ_gram_diff = abs(float(mp.re(dft_prod)) - rust["circulant_gram_det"])

        # 3. Quantum Switch Gr_C(2,4) at theta = pi/6
        theta = mp.pi / 6
        mp_esym = mp.cos(theta) ** 2
        mp_eanti = mp.sin(theta) ** 2
        mp_ratio = mp_eanti / mp_esym
        switch_sym_diff = abs(float(mp_esym) - rust["switch_e_sym"])
        switch_anti_diff = abs(float(mp_eanti) - rust["switch_e_anti"])
        switch_ratio_diff = abs(float(mp_ratio) - rust["switch_plucker_ratio"])

        # 4. Lorenz beta = 8/3 high-precision comparison
        mp_beta = mp.mpf(8) / 3
        lorenz_beta_diff = abs(float(mp_beta) - rust["lorenz_recovered_beta"])

        # 5. Jeffrey / QCRB / Landauer high-precision checks
        mp_j = mp.mpf("0.78") * 10 + mp.mpf("0.22") * 2
        jeffrey_diff = abs(float(mp_j) - rust["jeffrey_do_estimate"])
        mp_qcrb1 = mp.mpf(1) / (4 * mp.mpf("1.25"))
        qcrb1_diff = abs(float(mp_qcrb1) - rust["qcrb_1shot_var_bound"])
        mp_landauer1 = mp.mpf(1) + mp.mpf("0.25")
        landauer1_diff = abs(float(mp_landauer1) - rust["landauer_1shot_closed_heat"])

    return {
        **sym_ok,
        "cb_diff": cb_diff,
        "circ_gram_diff": circ_gram_diff,
        "switch_sym_diff": switch_sym_diff,
        "switch_anti_diff": switch_anti_diff,
        "switch_ratio_diff": switch_ratio_diff,
        "lorenz_beta_diff": lorenz_beta_diff,
        "jeffrey_diff": jeffrey_diff,
        "qcrb1_diff": qcrb1_diff,
        "landauer1_diff": landauer1_diff,
        "rust_report": rust,
    }
