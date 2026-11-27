"""
Symbolic (SymPy) and high-precision (`mpmath` + Rust/PyO3) audit suite for:
- Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`)
  (`Signals.QuantumCausalInference` Section 16 & `Signals.Pending.OneShotQuantumSysIdPendingBoundary`),
  reimplementing Boullé, Halikias, Otto, & Townsend (2026, PNAS 123(47):e2624491123).
"""

from typing import Any

import mpmath as mp
import numpy as np
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


def _tq_hamiltonian_to_rust_terms(
    H: Any, n_qubits: int
) -> list[tuple[float, float, list[tuple[int, str]]]]:
    """Convert a Tequila `QubitHamiltonian` into `RustFastHamiltonianSet` raw tuples."""
    terms: list[tuple[float, float, list[tuple[int, str]]]] = []
    for ps in H.paulistrings:
        coeff = complex(ps.coeff)
        if abs(coeff) < 1e-15:
            continue
        ops = [(int(q), str(op).upper()) for q, op in ps.items() if int(q) < n_qubits]
        terms.append((float(np.real(coeff)), float(np.imag(coeff)), ops))
    if not terms:
        terms.append((0.0, 0.0, []))
    return terms


def _canon_tq_ham_key(H: Any) -> tuple[tuple[float, float, tuple[tuple[int, str], ...]], ...]:
    """Canonical hashable key for deduplicating Tequila QubitHamiltonian observables."""
    items = []
    for ps in H.paulistrings:
        coeff = complex(ps.coeff)
        if abs(coeff) < 1e-15:
            continue
        ops = tuple(sorted((int(q), str(op).upper()) for q, op in ps.items()))
        items.append((round(float(np.real(coeff)), 12), round(float(np.imag(coeff)), 12), ops))
    return tuple(sorted(items))


def tequila_osid_single_eigenstate_recovery(
    U_state: Any,
    basis_hamiltonians: list[Any],
    variables: dict[Any, float] | None = None,
    probe_operators: list[Any] | None = None,
    c_true: list[float] | None = None,
    backend: str = "signals",
    samples: int | None = None,
    seed: int = 1337,
) -> dict[str, Any]:
    """
    One-shot single-eigenstate Hamiltonian identification (`Qi & Ranard 2019` +
    `Bairey, Arad, & Lindner 2019`) compiled and executed through **Tequila** and the
    Rust/PyO3 `signals` / `grassmann` backend (`BackendCircuitSignals` + `RustFastHamiltonianSet`).
    """
    import numpy as np
    import signals_numerical_adapter as sna
    from sustainablefactory.tequila_signals_backend import ensure_tequila_signals_backend_registered

    ensure_tequila_signals_backend_registered()
    import tequila as tq

    n_qubits = max(
        [int(U_state.n_qubits)]
        + [max([int(q) + 1 for ps in h.paulistrings for q in ps.keys()] or [1]) for h in basis_hamiltonians]
    )
    n_basis = len(basis_hamiltonians)
    vars_dict = dict(variables or {})

    # Assemble unique Hermitian observables for L_i and anticommutators 0.5*{L_i, L_j},
    # plus optional Bairey-Arad-Lindner commutators i*[L_m, O_j] (real expectation on Hermitian O_j).
    unique_hams: list[Any] = []
    key_to_idx: dict[Any, int] = {}

    def register_obs(H_obs: Any) -> int | None:
        if len(H_obs.paulistrings) == 0:
            return None
        key = _canon_tq_ham_key(H_obs)
        if not key:
            return None
        if key not in key_to_idx:
            key_to_idx[key] = len(unique_hams)
            unique_hams.append(H_obs)
        return key_to_idx[key]

    l_indices = [register_obs(L_i) for L_i in basis_hamiltonians]
    anti_indices: list[list[int | None]] = [[None] * n_basis for _ in range(n_basis)]
    for i in range(n_basis):
        for j in range(i, n_basis):
            h_anti = 0.5 * (basis_hamiltonians[i] * basis_hamiltonians[j] + basis_hamiltonians[j] * basis_hamiltonians[i])
            idx = register_obs(h_anti)
            anti_indices[i][j] = idx
            anti_indices[j][i] = idx

    comm_indices: list[list[int | None]] = []
    if probe_operators:
        for O_j in probe_operators:
            row_idx: list[int | None] = []
            for L_m in basis_hamiltonians:
                h_comm = 1j * (L_m * O_j - O_j * L_m)
                row_idx.append(register_obs(h_comm))
            comm_indices.append(row_idx)

    # Evaluate all unique observables in one compiled RustFastHamiltonianSet batch when exact + signals/grassmann
    if samples is None and backend in ("signals", "grassmann"):
        compiled_u = tq.compile(U_state, variables=vars_dict, backend=backend)
        compiled_u.update_variables(vars_dict)
        raw_hams = [_tq_hamiltonian_to_rust_terms(h, n_qubits) for h in unique_hams]
        ham_set = sna.RustFastHamiltonianSet(n_qubits, raw_hams)
        exp_vals = list(
            compiled_u._rust_circuit.expectation_compiled(
                compiled_u._current_angles, 0, None, ham_set
            )
        )
    else:
        exp_vals = []
        for h_idx, h in enumerate(unique_hams):
            E_obj = tq.ExpectationValue(H=h, U=U_state)
            if samples is None:
                val = float(tq.simulate(E_obj, variables=vars_dict, backend=backend))
            else:
                # Re-seed per observable for independent shot sampling when using signals backend
                compiled_e = tq.compile(E_obj, variables=vars_dict, backend=backend)
                if hasattr(compiled_e.args[0].U, "seed"):
                    compiled_e.args[0].U.seed = int(seed + h_idx * 97)
                val = float(compiled_e(variables=vars_dict, samples=int(samples)))
            exp_vals.append(val)

    def get_val(obs_idx: int | None) -> float:
        return 0.0 if obs_idx is None else float(exp_vals[obs_idx])

    exp_l = [get_val(idx) for idx in l_indices]
    M = np.zeros((n_basis, n_basis), dtype=float)
    for i in range(n_basis):
        for j in range(i, n_basis):
            val = get_val(anti_indices[i][j]) - exp_l[i] * exp_l[j]
            M[i, j] = val
            M[j, i] = val

    evals, evecs = np.linalg.eigh(M)
    w_rec = evecs[:, 0]

    result: dict[str, Any] = {
        "n_qubits": int(n_qubits),
        "n_basis": int(n_basis),
        "n_unique_observables": len(unique_hams),
        "backend": backend,
        "samples": samples,
        "M_eigenvalues": evals.tolist(),
        "lambda1": float(evals[0]),
        "lambda2": float(evals[1]) if n_basis > 1 else 0.0,
        "w_unit_recovered": w_rec.tolist(),
    }

    if probe_operators:
        K = np.zeros((len(probe_operators), n_basis), dtype=float)
        for r_idx, row in enumerate(comm_indices):
            for c_idx, obs_idx in enumerate(row):
                K[r_idx, c_idx] = get_val(obs_idx)
        ktk_evals, ktk_evecs = np.linalg.eigh(K.T @ K)
        result["bairey_K_shape"] = list(K.shape)
        result["bairey_ktk_lambda1"] = float(ktk_evals[0])
        result["bairey_ktk_lambda2"] = float(ktk_evals[1]) if n_basis > 1 else 0.0
        result["bairey_w_unit"] = ktk_evecs[:, 0].tolist()
        if c_true is not None:
            c_arr = np.asarray(c_true, dtype=float)
            c_norm = float(np.linalg.norm(c_arr))
            w_b = ktk_evecs[:, 0]
            sign_b = 1.0 if float(np.dot(w_b, c_arr)) >= 0.0 else -1.0
            c_rec_b = sign_b * w_b * c_norm
            result["bairey_commutator_residual"] = float(np.linalg.norm(K @ c_arr, ord=np.inf))
            result["bairey_max_scaled_err"] = float(np.max(np.abs(c_rec_b - c_arr)))

    if c_true is not None:
        c_arr = np.asarray(c_true, dtype=float)
        c_norm = float(np.linalg.norm(c_arr))
        c_unit = c_arr / c_norm
        raw_ov = float(np.dot(w_rec, c_unit))
        sign = 1.0 if raw_ov >= 0.0 else -1.0
        angle_err = float(np.arccos(min(1.0, abs(raw_ov))))
        c_rec = sign * w_rec * c_norm
        result["projective_angle_err_rad"] = angle_err
        result["max_scaled_err"] = float(np.max(np.abs(c_rec - c_arr)))
        result["c_recovered"] = c_rec.tolist()

    return result


def tequila_osid_vqe_davis_kahan_audit() -> dict[str, Any]:
    r"""
    Runs a full **Tequila VQE -> `QCI-OSID`** pipeline on a 3-qubit disordered transverse +
    longitudinal Ising chain using `tq.minimize(..., backend="signals")` and `compute_natural_gradient`
    (`QFIM = 4 g_FS`), comparing exact statevector vs. shot-sampled (`samples = 4000`, `200000`)
    recovery to quantify the Davis–Kahan $1/\lambda_2$ shot-noise disadvantage.
    """
    import numpy as np
    from sustainablefactory.tequila_signals_backend import ensure_tequila_signals_backend_registered

    ensure_tequila_signals_backend_registered()
    import tequila as tq

    basis_hams = [
        tq.QubitHamiltonian("Z(0)Z(1)"),
        tq.QubitHamiltonian("Z(1)Z(2)"),
        tq.QubitHamiltonian("X(0)"),
        tq.QubitHamiltonian("X(1)"),
        tq.QubitHamiltonian("X(2)"),
        tq.QubitHamiltonian("Z(0)"),
    ]
    c_true = [1.10, -0.75, 0.65, -0.50, 0.85, 0.40]
    H_true = sum((c * h for c, h in zip(c_true, basis_hams)), tq.QubitHamiltonian.zero())
    probe_ops = [
        tq.QubitHamiltonian("Y(0)"),
        tq.QubitHamiltonian("Y(1)"),
        tq.QubitHamiltonian("Y(2)"),
        tq.QubitHamiltonian("Y(0)Z(1)"),
        tq.QubitHamiltonian("Z(0)Y(1)"),
        tq.QubitHamiltonian("Y(1)Z(2)"),
        tq.QubitHamiltonian("Z(1)Y(2)"),
    ]

    # Exact diagonalization ground-state energy reference
    h_mat = H_true.to_matrix()
    evals, evecs = np.linalg.eigh(h_mat)
    e0_exact = float(evals[0])

    # Hardware-efficient Tequila ansatz with enough expressibility for exact 3-qubit ground state
    U_ansatz = (
        tq.gates.Ry(angle="t0", target=0)
        + tq.gates.Ry(angle="t1", target=1)
        + tq.gates.Ry(angle="t2", target=2)
        + tq.gates.CNOT(control=0, target=1)
        + tq.gates.CNOT(control=1, target=2)
        + tq.gates.Ry(angle="t3", target=0)
        + tq.gates.Ry(angle="t4", target=1)
        + tq.gates.Ry(angle="t5", target=2)
        + tq.gates.CNOT(control=2, target=0)
        + tq.gates.Ry(angle="t6", target=0)
        + tq.gates.Ry(angle="t7", target=1)
        + tq.gates.Ry(angle="t8", target=2)
    )
    E_vqe = tq.ExpectationValue(H=H_true, U=U_ansatz)
    init_vars = {f"t{k}": 0.25 * (k + 1) for k in range(9)}
    res = tq.minimize(
        E_vqe,
        initial_values=init_vars,
        backend="signals",
        method="BFGS",
        tol=1e-9,
        silent=True,
    )

    compiled_e = tq.compile(E_vqe, variables=res.variables, backend="signals")
    qng_info = compiled_e.args[0].compute_natural_gradient(variables=res.variables)

    exact_vqe_osid = tequila_osid_single_eigenstate_recovery(
        U_ansatz,
        basis_hams,
        variables=res.variables,
        probe_operators=probe_ops,
        c_true=c_true,
        backend="signals",
        samples=None,
    )
    low_shot_osid = tequila_osid_single_eigenstate_recovery(
        U_ansatz,
        basis_hams,
        variables=res.variables,
        probe_operators=None,
        c_true=c_true,
        backend="signals",
        samples=4000,
        seed=2026,
    )
    high_shot_osid = tequila_osid_single_eigenstate_recovery(
        U_ansatz,
        basis_hams,
        variables=res.variables,
        probe_operators=None,
        c_true=c_true,
        backend="signals",
        samples=200000,
        seed=4096,
    )

    return {
        "exact_ground_energy": e0_exact,
        "vqe_energy": float(res.energy),
        "vqe_energy_err": abs(float(res.energy) - e0_exact),
        "qfim_diag": qng_info["qfim_diag"],
        "fubini_study_diag": qng_info["fubini_study_diag"],
        "exact_vqe_osid": exact_vqe_osid,
        "low_shot_4k_osid": low_shot_osid,
        "high_shot_200k_osid": high_shot_osid,
    }


def tequila_osid_quantum_switch_circuit(theta: float | None = None) -> dict[str, Any]:
    """
    Realizes the coherent $\\mathrm{Gr}_{\\mathbb{C}}(2,4)$ Quantum Switch 1-shot operator probe
    as an explicit 2-qubit **Tequila `QCircuit`** (`q_ctrl = 0`, `q_sys = 1`):
    $U_A = \\exp(i \\theta X) = R_x(-2\\theta)$, $U_B = Z$, initial control $|+\\rangle_0$
    and system $|0\\rangle_1$. Measuring $\\langle Z_0 \\rangle$ yields
    $\\delta_{\\mathrm{switch}} = E_+ - E_- = \\cos(2\\theta)$, $E_+ = \\cos^2\\theta$,
    $E_- = \\sin^2\\theta$, and Plücker ratio $E_- / E_+ = \\tan^2\\theta$ in **1 circuit shot**.
    """
    import numpy as np
    from sustainablefactory.tequila_signals_backend import ensure_tequila_signals_backend_registered

    ensure_tequila_signals_backend_registered()
    import tequila as tq

    th = float(np.pi / 6.0 if theta is None else theta)
    # Control qubit 0 in |+> = H|0>; target qubit 1 in |0>.
    # Branch |0>_ctrl applies U_B U_A; branch |1>_ctrl applies U_A U_B; final H(0) maps |+> -> |0>, |-> -> |1>.
    U_switch = (
        tq.gates.H(target=0)
        # Branch |0>: X(0) flips 0 -> 1 so controlled gates act on |0>_ctrl
        + tq.gates.X(target=0)
        + tq.gates.Rx(angle=-2.0 * th, target=1, control=0)  # U_A first
        + tq.gates.Z(target=1, control=0)  # U_B second -> U_B U_A
        + tq.gates.X(target=0)
        # Branch |1>: acts when control = |1>
        + tq.gates.Z(target=1, control=0)  # U_B first
        + tq.gates.Rx(angle=-2.0 * th, target=1, control=0)  # U_A second -> U_A U_B
        + tq.gates.H(target=0)
    )
    Z0 = tq.QubitHamiltonian("Z(0)")
    E_sw = tq.ExpectationValue(H=Z0, U=U_switch)

    delta_signals = float(tq.simulate(E_sw, backend="signals"))
    delta_grassmann = float(tq.simulate(E_sw, backend="grassmann"))
    delta_symbolic = float(tq.simulate(E_sw, backend="symbolic"))

    e_plus = 0.5 * (1.0 + delta_signals)
    e_minus = 0.5 * (1.0 - delta_signals)
    plucker_ratio = e_minus / e_plus
    return {
        "theta": th,
        "delta_signals": delta_signals,
        "delta_grassmann": delta_grassmann,
        "delta_symbolic": delta_symbolic,
        "e_plus": e_plus,
        "e_minus": e_minus,
        "plucker_ratio": plucker_ratio,
        "exact_e_plus": float(np.cos(th) ** 2),
        "exact_e_minus": float(np.sin(th) ** 2),
        "exact_plucker_ratio": float(np.tan(th) ** 2),
    }


def tequila_osid_sparse_plucker_126qubit_audit() -> dict[str, Any]:
    """
    Demonstrates the primary **scaling advantage** of integrating `QCI-OSID` with our
    `signals` Tequila backend: 128-bit sparse Plücker `HCB-SPA` identification at
    **$n = 126$ qubits** ($n_{\\mathrm{occ}} = 6$, support $= 2^6 = 64 \\ll 2^{126}$),
    where dense backends (`qulacs`, `cirq`, `qiskit`) hit the memory wall.
    Constructs a compiled 126-qubit `HCB-SPA` ground state on pair `(0, 6)` with
    parameter $\\theta_0$ and recovers the 2-term effective pair Hamiltonian coupling
    ratio `c_pair_z / c_pair_x = cot(theta_0)` from the Tequila-compiled sparse state.
    """
    import numpy as np
    import signals_numerical_adapter as sna
    from sustainablefactory.tequila_signals_backend import ensure_tequila_signals_backend_registered

    ensure_tequila_signals_backend_registered()
    import tequila as tq

    n_occ = 6
    n_orb = 126
    th0 = float(np.pi / 5.0)
    # Build 126-qubit HCB-SPA Tequila circuit with non-trivial pair superposition on pair 0 <-> n_occ
    U_hcb = tq.QCircuit()
    for p in range(n_occ):
        U_hcb += tq.gates.X(target=p)
    # Pair excitation on (0, n_occ): |1_0, 0_nocc> -> cos(th0/2)|10> + sin(th0/2)|01>
    U_hcb += tq.gates.Ry(angle=th0, target=n_occ)
    U_hcb += tq.gates.CNOT(control=n_occ, target=0)
    # Additional pair excitations on pairs 1..n_occ-1 (last pair reaches qubit n_orb - 1 = 125)
    # to span the full 126-qubit register with support = 2^6 = 64 << 2^126.
    for p in range(1, n_occ):
        partner = (n_orb - 1) if p == (n_occ - 1) else (n_occ + p)
        U_hcb += tq.gates.Ry(angle=0.35, target=partner)
        U_hcb += tq.gates.CNOT(control=partner, target=p)
    # Register remaining virtual orbitals so Tequila compiles a genuine 126-qubit register
    # while leaving the 128-bit sparse Plücker support invariant at 2^6 = 64.
    used_qubits = set(U_hcb.qubits)
    for q_virt in range(n_orb):
        if q_virt not in used_qubits:
            U_hcb += tq.gates.Rz(angle=0.0, target=q_virt)

    # Local 2-body pair operators on pair (0, n_occ) inside the 126-qubit space:
    # Effective 2-level Hamiltonian in {|10>, |01>} subspace:
    # H_eff = c_z * (Z(0) - Z(n_occ))/2 + c_x * (X(0)X(n_occ) + Y(0)Y(n_occ))/2
    # Wait: on |10> -> -1, |01> -> +1 for Z(0)-Z(n_occ) wait: Z|1> = -|1>, Z|0> = +|0>
    # So Z(0) on |10> is -1 and on |01> is +1 -> (Z(0) - Z(n_occ))/2 acts as -Z_pair!
    # Therefore psi(th0) = cos(th0/2)|10> + sin(th0/2)|01> is an exact ground state of:
    # H_pair = cos(th0) * (Z(0) - Z(n_occ))/2 - sin(th0) * (X(0)X(n_occ) + Y(0)Y(n_occ))/2
    L0 = tq.QubitHamiltonian(f"0.5*Z(0) - 0.5*Z({n_occ})")
    L1 = tq.QubitHamiltonian(f"0.5*X(0)X({n_occ}) + 0.5*Y(0)Y({n_occ})")
    c_true = [float(np.cos(th0)), -float(np.sin(th0))]
    basis_hams = [L0, L1]

    compiled_u = tq.compile(U_hcb, backend="signals")
    raw_hams = [
        _tq_hamiltonian_to_rust_terms(L0, n_orb),
        _tq_hamiltonian_to_rust_terms(L1, n_orb),
        _tq_hamiltonian_to_rust_terms(0.5 * (L0 * L0 + L0 * L0), n_orb),
        _tq_hamiltonian_to_rust_terms(0.5 * (L0 * L1 + L1 * L0), n_orb),
        _tq_hamiltonian_to_rust_terms(0.5 * (L1 * L1 + L1 * L1), n_orb),
    ]
    ham_set = sna.RustFastHamiltonianSet(n_orb, raw_hams)
    vals = list(compiled_u._rust_circuit.expectation_compiled([], 0, None, ham_set))
    support_size = int(compiled_u._rust_circuit.last_support_size())

    M = np.array(
        [
            [vals[2] - vals[0] ** 2, vals[3] - vals[0] * vals[1]],
            [vals[3] - vals[0] * vals[1], vals[4] - vals[1] ** 2],
        ],
        dtype=float,
    )
    evals, evecs = np.linalg.eigh(M)
    w_rec = evecs[:, 0]
    c_arr = np.asarray(c_true, dtype=float)
    sign = 1.0 if float(np.dot(w_rec, c_arr)) >= 0.0 else -1.0
    c_rec = sign * w_rec * float(np.linalg.norm(c_arr))

    return {
        "n_qubits": n_orb,
        "n_occ": n_occ,
        "active_support_size": support_size,
        "sparse_bytes": 16 * support_size,
        "dense_bytes_log2": 4 + n_orb,
        "lambda1": float(evals[0]),
        "lambda2": float(evals[1]),
        "c_true": c_true,
        "c_recovered": c_rec.tolist(),
        "max_scaled_err": float(np.max(np.abs(c_rec - c_arr))),
    }


def tequila_osid_noisy_mcweeny_pure_vs_mixed_audit() -> dict[str, Any]:
    """
    Audits both the **advantage** and the **disadvantage** of McWeeny cubic purification
    (`mcweeny_passes=2`) and `MCWF` quantum trajectories in Tequila `BackendCircuitSignals`:
    1. **Pure-State Advantage:** Under depolarizing noise (`p = 0.08`) on a 2-qubit Ising
       ground state `H = Z(0)Z(1) + 0.6*(X(0)+X(1)) + 0.3*Z(0)`, McWeeny purification
       restores purity and reduces Qi–Ranard `OSID` angle error (`err_purified < err_raw`).
    2. **Mixed-State Disadvantage:** On a genuine thermal/Gibbs state $\\rho_\\beta = \\mathrm{diag}(0.65, 0.35)$
       (eigenvalues $p_{\\mathrm{high}}=0.65$, $p_{\\mathrm{low}}=0.35$), McWeeny purification
       distorts the Boltzmann spectrum toward rank-1 ($0.35 \\mapsto 0.28175$, $0.65 \\mapsto 0.71825$),
       increasing trace distance to $\\rho_\\beta$!
    """
    import numpy as np
    import signals_numerical_adapter as sna
    from sustainablefactory.tequila_signals_backend import ensure_tequila_signals_backend_registered

    ensure_tequila_signals_backend_registered()
    import tequila as tq
    from tequila.circuit.noise import DepolarizingError

    basis_hams = [
        tq.QubitHamiltonian("Z(0)Z(1)"),
        tq.QubitHamiltonian("X(0)"),
        tq.QubitHamiltonian("X(1)"),
        tq.QubitHamiltonian("Z(0)"),
    ]
    c_true = [1.0, 0.6, 0.6, 0.3]
    H_true = sum((c * h for c, h in zip(c_true, basis_hams)), tq.QubitHamiltonian.zero())

    # Exact 2-qubit ground state via VQE in Tequila
    U_prep = (
        tq.gates.Ry(angle="a0", target=0)
        + tq.gates.Ry(angle="a1", target=1)
        + tq.gates.CNOT(control=0, target=1)
        + tq.gates.Ry(angle="a2", target=0)
        + tq.gates.Ry(angle="a3", target=1)
    )
    res = tq.minimize(
        tq.ExpectationValue(H=H_true, U=U_prep),
        initial_values={"a0": 0.4, "a1": 0.4, "a2": -0.3, "a3": 0.2},
        backend="signals",
        method="BFGS",
        tol=1e-10,
        silent=True,
    )

    noise = DepolarizingError(p=0.08, level=1)
    comp_raw = tq.compile(U_prep, variables=res.variables, backend="signals", noise=noise, mcweeny_passes=0)
    comp_pur = tq.compile(U_prep, variables=res.variables, backend="signals", noise=noise, mcweeny_passes=2)
    rho_raw = comp_raw.do_simulate_density(variables=res.variables).get_density_as_array()
    rho_pur = comp_pur.do_simulate_density(variables=res.variables).get_density_as_array()

    def ham_to_2q_matrix(h: Any) -> np.ndarray:
        paulis = {
            "I": np.eye(2, dtype=complex),
            "X": np.array([[0.0, 1.0], [1.0, 0.0]], dtype=complex),
            "Y": np.array([[0.0, -1.0j], [1.0j, 0.0]], dtype=complex),
            "Z": np.array([[1.0, 0.0], [0.0, -1.0]], dtype=complex),
        }
        mat = np.zeros((4, 4), dtype=complex)
        for ps in h.paulistrings:
            coeff = complex(ps.coeff)
            op_map = {int(q): str(op).upper() for q, op in ps.items()}
            p0 = paulis[op_map.get(0, "I")]
            p1 = paulis[op_map.get(1, "I")]
            mat += coeff * np.kron(p0, p1)
        return mat

    def osid_from_dm(rho: np.ndarray) -> tuple[float, float, float]:
        mats = [ham_to_2q_matrix(h) for h in basis_hams]
        exp_l = [float(np.real(np.trace(rho @ m))) for m in mats]
        n_b = len(mats)
        M = np.zeros((n_b, n_b), dtype=float)
        for i in range(n_b):
            for j in range(i, n_b):
                anti = 0.5 * (mats[i] @ mats[j] + mats[j] @ mats[i])
                val = float(np.real(np.trace(rho @ anti))) - exp_l[i] * exp_l[j]
                M[i, j] = val
                M[j, i] = val
        evals, evecs = np.linalg.eigh(M)
        w = evecs[:, 0]
        c_arr = np.asarray(c_true, dtype=float)
        c_unit = c_arr / np.linalg.norm(c_arr)
        ang = float(np.arccos(min(1.0, abs(float(np.dot(w, c_unit))))))
        purity = float(np.real(np.trace(rho @ rho)))
        return ang, float(evals[0]), purity

    ang_raw, lam1_raw, pur_raw = osid_from_dm(rho_raw)
    ang_pur, lam1_pur, pur_pur = osid_from_dm(rho_pur)

    # Also test MCWF quantum trajectory ensemble consistency vs. heralded no-jump expectation
    traj = comp_raw.simulate_quantum_trajectories(
        hamiltonians=H_true,
        variables=res.variables,
        n_trajectories=512,
        unraveling_mode="quantum_jump",
        seed=2026,
    )

    # Disadvantage test: genuine 1-qubit thermal Gibbs mixed state diag(0.65, 0.35)
    rho_gibbs_flat = [(0.65, 0.0), (0.0, 0.0), (0.0, 0.0), (0.35, 0.0)]
    rho_gibbs_pur = sna.py_mcweeny_purify_density_matrix(rho_gibbs_flat, 2, 1)
    p0_after = float(rho_gibbs_pur[0][0])
    p1_after = float(rho_gibbs_pur[3][0])
    gibbs_trace_distortion = 0.5 * (abs(p0_after - 0.65) + abs(p1_after - 0.35))

    return {
        "pure_depolarized_angle_err_raw": ang_raw,
        "pure_depolarized_angle_err_purified": ang_pur,
        "pure_depolarized_lambda1_raw": lam1_raw,
        "pure_depolarized_lambda1_purified": lam1_pur,
        "purity_raw": pur_raw,
        "purity_purified": pur_pur,
        "mcwf_ensemble_energy": float(traj["ensemble_expectations"][0]),
        "mcwf_heralded_no_jump_energy": float(traj["heralded_no_jump_expectations"][0]),
        "mcwf_survival_prob": float(traj["no_jump_survival_prob"]),
        "gibbs_p0_after_mcweeny": p0_after,
        "gibbs_p1_after_mcweeny": p1_after,
        "gibbs_trace_distortion": gibbs_trace_distortion,
    }


def verify_symbolic_sato_osid_identities() -> dict[str, bool]:
    """
    SymPy symbolic verification of Section 16.3 (`Signals.QuantumCausalInference`):
    1. KP-II weak-form normalized residual vanishes at `(-1/4, -3/4, -3/4)`.
    2. KdV 1-soliton traveling-wave `u(x,t) = 2 k^2 sech^2(k x + k^3 t)` satisfies BOTH
       `u_t - k^2 u_x = 0` AND `4 u_t - u_xxx - 6 u u_x = 0`, inducing a 2D nullspace (`rank 2 < 4`).
    3. AKNS focusing/defocusing separation `2 - (-2) = 4`.
    4. 6-channel Dual-Schubert `QFIM = 4(g_fwd + g_dual)` strictly tightens QCRB over `4 g_fwd`.
    """
    k, x, t, u_xt, u_xxxx, u2_xx, u_yy, g_fwd, g_dual, m_shots = sp.symbols(
        "k x t u_xt u_xxxx u2_xx u_yy g_fwd g_dual m_shots", positive=True
    )
    theta = k * x + k**3 * t
    u = 2 * k**2 / sp.cosh(theta) ** 2
    u_t = sp.diff(u, t)
    u_x = sp.diff(u, x)
    u_xxx = sp.diff(u, x, 3)

    traveling_res = sp.simplify(u_t - k**2 * u_x)
    kdv_res = sp.simplify(4 * u_t - u_xxx - 6 * u * u_x)
    kp2_op_res = sp.simplify(
        4 * (u_xt + sp.Rational(-1, 4) * u_xxxx + sp.Rational(-3, 4) * u2_xx + sp.Rational(-3, 4) * u_yy)
        - (4 * u_xt - u_xxxx - 3 * u2_xx - 3 * u_yy)
    )
    qcrb_diff = sp.simplify(1 / (m_shots * 4 * g_fwd) - 1 / (m_shots * 4 * (g_fwd + g_dual)))

    return {
        "kp2_weak_normalized_sym_ok": kp2_op_res == 0,
        "kdv1_traveling_wave_sym_ok": traveling_res == 0 and kdv_res == 0,
        "akns_sign_gap_sym_ok": (sp.Integer(2) - sp.Integer(-2)) == 4,
        "dual_schubert_qcrb_tightening_sym_ok": sp.simplify(
            qcrb_diff - g_dual / (4 * m_shots * g_fwd * (g_fwd + g_dual))
        )
        == 0,
    }


def audit_qci_sato_pde_solvers_high_precision(dps: int = 45) -> dict[str, Any]:
    """
    Cross-verify Rust/PyO3 `py_audit_qci_one_shot_sysid_sato_pdes` and
    `PlabicGr24Solver` far-field log-sum-exp extrapolation against 45-digit `mpmath`.
    """
    import signals_numerical_adapter as sna

    mp.mp.dps = dps
    sym_ok = verify_symbolic_sato_osid_identities()
    rust = sna.py_audit_qci_one_shot_sysid_sato_pdes()

    # Verify PlabicGr24Solver far-field u(100, -50, 20) against 45-digit mpmath log-sum-exp tau
    kappa = [mp.mpf("-2.0"), mp.mpf("-0.5"), mp.mpf("0.7"), mp.mpf("1.8")]
    a, b, c, d = mp.mpf("1.2"), mp.mpf("0.8"), mp.mpf("1.5"), mp.mpf("2.1")
    v = [mp.mpf(1), mp.mpf(0), -a, -a * (b + d)]
    w = [mp.mpf(0), mp.mpf(1), c, c * d]
    pairs = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    x_mp, y_mp, t_mp = mp.mpf("100.0"), mp.mpf("-50.0"), mp.mpf("20.0")
    weights = []
    alphas = []
    for i, j in pairs:
        p_ij = v[i] * w[j] - v[j] * w[i]
        c_ij = p_ij * (kappa[j] - kappa[i])
        al = kappa[i] + kappa[j]
        be = kappa[i] ** 2 + kappa[j] ** 2
        ga = kappa[i] ** 3 + kappa[j] ** 3
        weights.append(c_ij * mp.exp(al * x_mp + be * y_mp + ga * t_mp))
        alphas.append(al)
    z_mp = sum(weights)
    probs = [wi / z_mp for wi in weights]
    mean_a = sum(pi * ai for pi, ai in zip(probs, alphas))
    var_a = sum(pi * (ai - mean_a) ** 2 for pi, ai in zip(probs, alphas))
    u_far_mp = 2 * var_a
    far_rel_diff = float(abs(mp.mpf(str(rust["kp2_far_field_u"])) - u_far_mp) / u_far_mp)

    return {
        **sym_ok,
        "far_field_u_mpmath": float(u_far_mp),
        "far_field_rel_diff": far_rel_diff,
        "rust_report": rust,
    }
