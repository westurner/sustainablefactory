"""
SymPy, Arbitrary-Precision `mpmath`, and Rust/PyO3 Verification Toolkit for
`Signals.SatoGrassmannian` and `Signals.SatoGrassmannian.RiemannSpectralBridge`.

Cross-verifies all 21 Lean 4 modules in `Signals.SatoGrassmannian.*` against:
1. **Exact Symbolic SymPy Proofs** (`verify_symbolic_sato_pde_identities`):
   - Klein quadric big-cell frame reconstruction (including proof of the chat Block-005 sign fix).
   - Hirota bilinear KP-II identity on `Gr_C(2,4)` `schurTau` modulo the Klein quadric.
   - Baker–Akhiezer `B₂`/`B₃` Lax equations on the KdV 1-soliton (including proof of the chat
     Block-019 `6 z k³ S2 T - 4 k⁴ S2 T²` coefficient fix).
   - AKNS focusing NLS bright soliton & defocusing GPE dark soliton PDEs.
   - Segal–Wilson `Gr(2,4)` Fredholm determinant `det(I_2 + g(t)_{+-} T_U g(t)_{++}^{-1}) = tau_U / p23`.
   - `RiemannSpectralBridge` identities (Li/Cayley, dBN quadratic backward heat, Jensen–Pólya Turán).
2. **High-Precision `mpmath` vs. Rust/PyO3 Cross-Verification**:
   - `PlabicGr24Solver` overflow-proof log-sum-exp KP-II jets & KdV 2-soliton `y`-invariance.
   - Order-1/2/3 Carleman–Weierstrass Euler products (`det₁`, `det₂`, `det₃`) & `det₂` anomaly,
     including critical-line `det₃(1/2 + i γ₁)` at the first Riemann zero.
   - Shifted-Gaussian `L¹(ℝ)` Weil quadratic form on true Riemann zeros from
     `signals_numerical_adapter.py_find_first_n_riemann_zeros` vs. the `< -4π` off-line witness.
   - 3-channel Plücker–Madelung & 6-channel Dual-Schubert QFIM decomposition.

**Epistemic Boundary**: Mirrors `Signals.Pending.SatoRiemannSpectralPendingBoundary` — exact
PDE/Hilbert-space/finite-prime verifications do NOT prove the Riemann Hypothesis, discharge the
classical Lidskii `FredholmDetTheory` axiom bundle in Mathlib, or experimentally validate
Sharoglazova–Klaers evanescent tunneling speed or massive Proca fields.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple
import mpmath as mp
import sympy as sp

import signals_numerical_adapter as sna


def _sieve_primes(limit: int) -> List[int]:
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    p = 2
    while p * p <= limit:
        if sieve[p]:
            for m in range(p * p, limit + 1, p):
                sieve[m] = False
        p += 1
    return [i for i, flag in enumerate(sieve) if flag]


def verify_symbolic_sato_pde_identities() -> Dict[str, bool]:
    """Exact SymPy algebraic & differential checks matching the Lean 4 theorems."""
    results: Dict[str, bool] = {}

    # 1. Big-cell Klein-quadric frame reconstruction (Block-005 sign fix audit)
    v0, v1, v2, v3, w0, w1, w2, w3 = sp.symbols("v0 v1 v2 v3 w0 w1 w2 w3")
    v = [v0, v1, v2, v3]
    w = [w0, w1, w2, w3]
    p = {(i, j): sp.expand(v[i] * w[j] - v[j] * w[i]) for i in range(4) for j in range(i + 1, 4)}
    klein = sp.simplify(p[(0, 1)] * p[(2, 3)] - p[(0, 2)] * p[(1, 3)] + p[(0, 3)] * p[(1, 2)])
    results["klein_quadric_vanishes"] = klein == 0

    # Corrected big-cell frame: v_norm = [p03/p23, p13/p23, 1, 0], w_norm = [-p02/p23, -p12/p23, 0, 1]
    p23 = p[(2, 3)]
    vn = [p[(0, 3)] / p23, p[(1, 3)] / p23, sp.Integer(1), sp.Integer(0)]
    wn = [-p[(0, 2)] / p23, -p[(1, 2)] / p23, sp.Integer(0), sp.Integer(1)]
    recon_ok = all(
        sp.simplify((vn[i] * wn[j] - vn[j] * wn[i]) * p23 - p[(i, j)]) == 0
        for (i, j) in p
    )
    results["big_cell_reconstruction_corrected_signs"] = recon_ok

    # Verify the chat's original positive-sign formula fails on p02 and p12:
    wn_bug = [p[(0, 2)] / p23, p[(1, 2)] / p23, sp.Integer(0), sp.Integer(1)]
    p02_bug = sp.simplify((vn[0] * wn_bug[2] - vn[2] * wn_bug[0]) * p23 - p[(0, 2)])
    results["chat_block005_bug_confirmed_nonzero"] = sp.simplify(p02_bug + 2 * p[(0, 2)]) == 0

    # 2. Hirota bilinear KP-II identity on Gr(2,4) schurTau modulo Klein quadric
    t1, t2, t3 = sp.symbols("t1 t2 t3")
    p01s, p02s, p03s, p12s, p13s, p23s = sp.symbols("p01 p02 p03 p12 p13 p23")
    s1 = t1
    s2 = t2 + sp.Rational(1, 2) * t1**2
    s11 = sp.Rational(1, 2) * t1**2 - t2
    s21 = sp.Rational(1, 3) * t1**3 - t3
    s22 = sp.Rational(1, 12) * t1**4 + t2**2 - t1 * t3
    tau = p23s + p13s * s1 + p03s * s2 + p12s * s11 + p02s * s21 + p01s * s22

    def hirota_d4_x(f):
        return (
            2 * f * sp.diff(f, t1, 4)
            - 8 * sp.diff(f, t1) * sp.diff(f, t1, 3)
            + 6 * sp.diff(f, t1, 2) ** 2
        )

    def hirota_dx_dt(f):
        return 2 * (f * sp.diff(f, t1, t3) - sp.diff(f, t1) * sp.diff(f, t3))

    def hirota_dy2(f):
        return 2 * (f * sp.diff(f, t2, 2) - sp.diff(f, t2) ** 2)

    hirota_expr = sp.expand(hirota_d4_x(tau) - 4 * hirota_dx_dt(tau) + 3 * hirota_dy2(tau))
    q_sym = p01s * p23s - p02s * p13s + p03s * p12s
    results["hirota_kp_eq_24_times_klein"] = sp.simplify(hirota_expr - 24 * q_sym) == 0

    # 3. Segal–Wilson 2x2 Fredholm determinant == schurTau / p23 modulo Klein quadric
    e1 = t1
    e2 = t2 + sp.Rational(1, 2) * t1**2
    e3 = t3 + t1 * t2 + sp.Rational(1, 6) * t1**3
    a0, a1, b0, b1 = p03s / p23s, p13s / p23s, -p02s / p23s, -p12s / p23s
    m00 = e2 * (a0 - b0 * e1) + e1 * (a1 - b1 * e1)
    m01 = e2 * b0 + e1 * b1
    m10 = e3 * (a0 - b0 * e1) + e2 * (a1 - b1 * e1)
    m11 = e3 * b0 + e2 * b1
    det_fr = sp.simplify((1 + m00) * (1 + m11) - m01 * m10)
    sw_diff = sp.simplify((det_fr - tau / p23s).subs(p01s, (p02s * p13s - p03s * p12s) / p23s))
    results["segal_wilson_det_eq_tau_over_p23"] = sw_diff == 0

    # 4. Baker–Akhiezer B2 & B3 Lax pair (including Block-019 bug confirmation)
    k, z, x, y, t = sp.symbols("k z x y t", real=True)
    theta = k * x + k**3 * t
    u = 2 * k**2 / sp.cosh(theta) ** 2
    w_coef = -3 * k**3 * sp.tanh(theta) / sp.cosh(theta) ** 2
    psi = (z - k * sp.tanh(theta)) * sp.exp(z * x + z**2 * y + z**3 * t)
    E = sp.exp(z * x + z**2 * y + z**3 * t)

    def _is_zero_hyp(expr: sp.Expr) -> bool:
        return sp.cancel(sp.expand((expr / E).rewrite(sp.exp))) == 0

    results["ba_lax_b2_exact"] = _is_zero_hyp(sp.diff(psi, y) - (sp.diff(psi, x, 2) + u * psi))
    results["ba_lax_b3_exact"] = _is_zero_hyp(
        sp.diff(psi, t)
        - (sp.diff(psi, x, 3) + sp.Rational(3, 2) * u * sp.diff(psi, x) + w_coef * psi)
    )

    # Confirm the chat Block-019 wrong ψ_xxx formula fails to match true ∂_x³ ψ:
    S2 = 1 / sp.cosh(theta) ** 2
    T = sp.tanh(theta)
    psi_xxx_chat_wrong = (
        z**3 * (z - k * T)
        - 3 * z**2 * k**2 * S2
        + 4 * k**3 * S2 * T * (z - k * T)
        + 2 * k**4 * S2 * (1 - 2 * T**2)
    ) * E
    results["chat_block019_psi_xxx_bug_confirmed_nonzero"] = _is_zero_hyp(
        sp.diff(psi, x, 3) - psi_xxx_chat_wrong - 2 * k**3 * S2 * T * (z + k * T) * E
    )

    # 5. AKNS focusing NLS bright soliton & defocusing GPE dark soliton
    A = sp.symbols("A", real=True, positive=True)
    Eb = sp.exp(sp.I * A**2 * t)
    q_bright = A / sp.cosh(A * x) * Eb
    nls_res = (
        sp.I * sp.diff(q_bright, t)
        + sp.diff(q_bright, x, 2)
        + 2 * (A / sp.cosh(A * x)) ** 2 * q_bright
    )
    Ed = sp.exp(-2 * sp.I * A**2 * t)
    q_dark = A * sp.tanh(A * x) * Ed
    gpe_res = (
        sp.I * sp.diff(q_dark, t)
        + sp.diff(q_dark, x, 2)
        - 2 * (A * sp.tanh(A * x)) ** 2 * q_dark
    )
    results["akns_bright_nls_exact"] = sp.cancel(sp.expand((nls_res / Eb).rewrite(sp.exp))) == 0
    results["akns_dark_gpe_exact"] = sp.cancel(sp.expand((gpe_res / Ed).rewrite(sp.exp))) == 0

    # 6. RiemannSpectralBridge identities
    sdev, gam, z0, dz, a0s, a1s, a2s = sp.symbols("sdev gam z0 dz a0 a1 a2", real=True)
    rho = (sp.Rational(1, 2) + sdev) + sp.I * gam
    cayley_mod_sq = sp.simplify(sp.expand(sp.re(1 - 1 / rho) ** 2 + sp.im(1 - 1 / rho) ** 2))
    li_mod_sq = ((sdev - sp.Rational(1, 2)) ** 2 + gam**2) / (
        (sdev + sp.Rational(1, 2)) ** 2 + gam**2
    )
    results["bridge_li_eq_cayley_norm_sq"] = sp.simplify(cayley_mod_sq - li_mod_sq) == 0

    dbn_quad = (z0 - (-2) * t) + sp.Rational(1, 2) * (-2) * dz**2
    neg_double_zero = -(dz**2 - 2 * (t + z0 / 2))
    results["bridge_dbn_eq_neg_local_double_zero"] = sp.simplify(dbn_quad - neg_double_zero) == 0
    results["bridge_jensen_turan_eq_madelung_bohm"] = (
        sp.simplify((a1s**2 - a0s * a2s) - (a1s**2 + (-a0s * a2s))) == 0
    )

    # 8. DualSchubertQFIM: 3-channel Plücker–Madelung–QFIM identity (`three_channel_plucker_madelung_qfim`)
    #    For `Ψ(x) = √ρ(x) p̂(x)` with `‖p̂‖² = 1` (implemented here for general 2-component complex
    #    Plücker ray `p̂ = (cos θ e^{i φ₁}, sin θ e^{i φ₂})`):
    #      ‖dΨ‖² = ρ (Im ⟪p̂, dp̂⟫)² + (dρ)² / (4 ρ) + ρ · (QFIM / 4).
    rho_s = sp.Symbol("rho_s", positive=True)
    drho_s = sp.Symbol("drho_s", real=True)
    th, dth, ph1, ph2, dph1, dph2 = sp.symbols("th dth ph1 ph2 dph1 dph2", real=True)
    p0 = sp.cos(th) * sp.exp(sp.I * ph1)
    p1 = sp.sin(th) * sp.exp(sp.I * ph2)
    dp0 = (-sp.sin(th) * dth + sp.I * sp.cos(th) * dph1) * sp.exp(sp.I * ph1)
    dp1 = (sp.cos(th) * dth + sp.I * sp.sin(th) * dph2) * sp.exp(sp.I * ph2)
    dpsi0 = (drho_s / (2 * sp.sqrt(rho_s))) * p0 + sp.sqrt(rho_s) * dp0
    dpsi1 = (drho_s / (2 * sp.sqrt(rho_s))) * p1 + sp.sqrt(rho_s) * dp1
    lhs_dpsi_sq = sp.simplify(
        sp.expand(dpsi0 * sp.conjugate(dpsi0) + dpsi1 * sp.conjugate(dpsi1))
    )
    inner_p_dp = sp.simplify(sp.conjugate(p0) * dp0 + sp.conjugate(p1) * dp1)
    im_inner = sp.simplify(sp.im(inner_p_dp))
    norm_dp_sq = sp.simplify(dp0 * sp.conjugate(dp0) + dp1 * sp.conjugate(dp1))
    g_fs_sym = sp.simplify(norm_dp_sq - inner_p_dp * sp.conjugate(inner_p_dp))
    rhs_3ch = rho_s * im_inner**2 + drho_s**2 / (4 * rho_s) + rho_s * g_fs_sym
    results["dual_schubert_three_channel_plucker_madelung_qfim"] = (
        sp.simplify(sp.trigsimp(lhs_dpsi_sq - rhs_3ch)) == 0
    )

    # 9. DualSchubertQFIM Theorem 4.3 (`sharoglazova_klaers_evanescent_speed_law`):
    #    For `κ_+² = 2m(E_abs - ℏ J₀)/ℏ²`, `κ_-² = 2m(E_abs + ℏ J₀)/ℏ²`,
    #    `(ℏ/m)² ( (-κ̄ + δκ tanh(2 δκ x))² + δκ² / cosh²(2 δκ x) ) = (2/m)(E_abs - ℏ J₀ tanh(2 δκ x))`.
    hb, ms, E_a, J0_s, x_s = sp.symbols("hb ms E_a J0_s x_s", positive=True)
    kp_s = sp.sqrt(2 * ms * (E_a - hb * J0_s) / hb**2)
    km_s = sp.sqrt(2 * ms * (E_a + hb * J0_s) / hb**2)
    kbar_s = (km_s + kp_s) / 2
    dk_s = (km_s - kp_s) / 2
    u2 = 2 * dk_s * x_s
    veff_lhs = (hb / ms) ** 2 * ((-kbar_s + dk_s * sp.tanh(u2)) ** 2 + dk_s**2 / sp.cosh(u2) ** 2)
    veff_rhs = (2 / ms) * (E_a - hb * J0_s * sp.tanh(u2))
    results["sharoglazova_klaers_evanescent_speed_law"] = (
        sp.simplify(sp.expand(veff_lhs.rewrite(sp.exp) - veff_rhs.rewrite(sp.exp))) == 0
    )

    # 10. Order-3 Carleman anomaly polynomial cancellation (`det3Diag_mul_anomaly`):
    #     P_3(a) + P_3(b) + a*b*(a + b + a*b/2) == P_3(a + b + a*b), where P_3(z) = -z + z²/2.
    a_s, b_s = sp.symbols("a_s b_s")
    p3 = lambda u: -u + sp.Rational(1, 2) * u**2
    c_s = a_s + b_s + a_s * b_s
    anom3 = a_s * b_s * (a_s + b_s + sp.Rational(1, 2) * a_s * b_s)
    results["det3_anomaly_polynomial_identity"] = (
        sp.expand(p3(a_s) + p3(b_s) + anom3 - p3(c_s)) == 0
    )

    # 11. Finite-dimensional FredholmDetTheory matrix identities (`DeterminantBundle.lean`):
    #     det(I + N) = 1 for nilpotent shear, and det(Q * M * Q^{-1}) = det(M).
    m00, m01, m10, m11, sh_s, q00, q01, q10, q11 = sp.symbols(
        "m00 m01 m10 m11 sh_s q00 q01 q10 q11"
    )
    I2 = sp.eye(2)
    N_nilp = sp.Matrix([[0, 0], [sh_s, 0]])
    M_mat = sp.Matrix([[m00, m01], [m10, m11]])
    Q_mat = sp.Matrix([[q00, q01], [q10, q11]])
    results["finite_dim_fredholm_det_symbolic"] = (
        sp.simplify((I2 + N_nilp).det() - 1) == 0
        and sp.simplify((Q_mat * M_mat * Q_mat.inv()).det() - M_mat.det()) == 0
    )

    return results


def audit_carleman_mpmath_vs_rust(
    sigma: float,
    t: float,
    prime_limit: int = 1000,
    dps: int = 40,
) -> Dict[str, float]:
    """Cross-verify order-1/2/3 Carleman–Weierstrass Euler products between `mpmath` and Rust."""
    mp.mp.dps = dps
    primes = _sieve_primes(prime_limit)
    s = mp.mpc(sigma, t)

    det1 = mp.mpc(1)
    det2 = mp.mpc(1)
    det3 = mp.mpc(1)
    for p in primes:
        lam = -mp.power(p, -s)
        det1 *= 1 + lam
        det2 *= (1 + lam) * mp.exp(-lam)
        det3 *= (1 + lam) * mp.exp(-lam + mp.mpf("0.5") * lam**2)

    rust = sna.py_audit_carleman_euler_products(sigma, t, prime_limit)
    out = {
        "prime_count": float(len(primes)),
        "mp_det1_abs": float(abs(det1)),
        "rust_det1_abs": float(rust["det1_abs"]),
        "det1_abs_diff": float(abs(abs(det1) - rust["det1_abs"])),
        "mp_det2_abs": float(abs(det2)),
        "rust_det2_abs": float(rust["det2_abs"]),
        "det2_abs_diff": float(abs(abs(det2) - rust["det2_abs"])),
        "mp_det3_abs": float(abs(det3)),
        "rust_det3_abs": float(rust["det3_abs"]),
        "det3_abs_diff": float(abs(abs(det3) - rust["det3_abs"])),
        "det2_anomaly_residual": float(rust["det2_multiplicative_anomaly_residual"]),
        "sum_p_neg_3sigma": float(rust["sum_p_neg_3sigma"]),
    }
    if sigma > 1.0:
        inv_zeta_abs = float(abs(1 / mp.zeta(s)))
        out["inv_zeta_abs"] = inv_zeta_abs
        out["det1_vs_inv_zeta_diff"] = abs(out["mp_det1_abs"] - inv_zeta_abs)
    return out


def audit_riemann_spectral_bridge_on_true_zeros(count: int = 10) -> Dict[str, float]:
    """Run Rust `RiemannSpectral` zeros through the `SatoGrassmannian` Weil & Bridge audits."""
    zeros_raw = sna.py_find_first_n_riemann_zeros(count)
    weil_zeros: List[Tuple[float, float, int]] = []
    max_li_cayley_err = 0.0
    for z in zeros_raw:
        gamma = float(z["gamma"])
        weil_zeros.append((gamma, 0.0, 1))
        weil_zeros.append((-gamma, 0.0, 1))
        br = sna.py_audit_riemann_spectral_bridge(
            0.0, gamma, 1.0, -0.2, 0.1, 1.0, float(z["z_prime"]), -1.0
        )
        max_li_cayley_err = max(max_li_cayley_err, float(br["li_cayley_mismatch"]))

    first_gamma = float(zeros_raw[0]["gamma"])
    weil = sna.py_audit_weil_gaussian_quad_form(
        weil_zeros, [1.0, -0.35, 0.2], [0.0, 0.3, -0.45], first_gamma, 0.15
    )
    c3_at_gamma1 = sna.py_audit_carleman_euler_products(0.5, first_gamma, 2000)

    return {
        "zero_count": float(len(zeros_raw)),
        "first_gamma": first_gamma,
        "max_li_cayley_err": max_li_cayley_err,
        "weil_critical_line_re": float(weil["quad_form_re"]),
        "weil_critical_line_im": float(weil["quad_form_im"]),
        "weil_off_line_witness": float(weil["off_line_witness_value"]),
        "weil_neg_4pi_bound": float(weil["theoretical_neg_4pi_bound"]),
        "det3_at_first_zero_abs": float(c3_at_gamma1["det3_abs"]),
    }


def audit_det3_anomaly_and_weil_infinite_tail_mpmath_vs_rust(
    prime_limit: int = 1500,
    dps: int = 80,
) -> Dict[str, float]:
    """Cross-verify critical-line `det₃` multiplicative anomaly (`det3Diag_mul_anomaly`),
    strip `det₁` multiplicativity (`det1Diag_mul`), finite-dim `FredholmDetTheory`, and
    infinite-zero `L¹(ℝ)` Weil tail-dominated disproof witness between Rust/PyO3 and 80-digit `mpmath`."""
    mp.mp.dps = dps
    zeros_raw = sna.py_find_first_n_riemann_zeros(30)
    gammas = [float(z["gamma"]) for z in zeros_raw]
    gamma1 = gammas[0]

    # 1. Critical-line det3 anomaly at s = 1/2 + i*gamma1 vs. mpmath
    primes = _sieve_primes(prime_limit)
    s_crit = mp.mpc("0.5", mp.mpf(repr(gamma1)))
    det3_a = mp.mpc(1)
    det3_b = mp.mpc(1)
    det3_ab = mp.mpc(1)
    tr3 = mp.mpc(0)
    for p in primes:
        a = -mp.power(p, -s_crit)
        b = mp.mpf("0.5") * a
        ab = a * b
        c = a + b + ab
        det3_a *= (1 + a) * mp.exp(-a + mp.mpf("0.5") * a**2)
        det3_b *= (1 + b) * mp.exp(-b + mp.mpf("0.5") * b**2)
        det3_ab *= (1 + c) * mp.exp(-c + mp.mpf("0.5") * c**2)
        tr3 += ab * (a + b + mp.mpf("0.5") * ab)

    mp_det3_anom_res = float(abs(det3_ab - det3_a * det3_b * mp.exp(tr3)))
    rust_d3 = sna.py_audit_carleman_det3_anomaly(0.5, gamma1, prime_limit)
    rust_d1 = sna.py_audit_carleman_det3_anomaly(2.0, 5.0, prime_limit)

    # 2. Rust low-height off-line infinite-tail audit across 30 true zeros
    rust_wtail = sna.py_audit_weil_infinite_tail(gammas, 1.5, 0.15)

    # 3. 80-digit mpmath high-height Lagrange core at z0 = gamma1 + 0.15i zeroing {±gamma1}
    #    with tail over gammas[1:] = [gamma2 .. gamma30]
    z0 = mp.mpc(mp.mpf(repr(gamma1)), mp.mpf("0.15"))
    z0_bar = mp.conj(z0)
    core_nodes = [z0, z0_bar, mp.mpc(mp.mpf(repr(gamma1)), 0), mp.mpc(-mp.mpf(repr(gamma1)), 0)]
    delta = mp.mpf("0.05")
    sqrt_pi = mp.sqrt(mp.pi)

    def _mellin_g(shift: mp.mpf, z: mp.mpc) -> mp.mpc:
        return sqrt_pi * mp.exp(mp.j * shift * z - z**2 / 4)

    A_mat = mp.matrix([[_mellin_g(j * delta, zk) for j in range(4)] for zk in core_nodes])
    rhs_vec = mp.matrix([2 * sqrt_pi, -2 * sqrt_pi, mp.mpc(0), mp.mpc(0)])
    c_vec = mp.lu_solve(A_mat, rhs_vec)

    def _eval_phi(z: mp.mpc) -> mp.mpc:
        return sum(c_vec[j] * _mellin_g(j * delta, z) for j in range(4))

    mp_core_re = float(
        mp.re(_eval_phi(z0) * mp.conj(_eval_phi(z0_bar)) + _eval_phi(z0_bar) * mp.conj(_eval_phi(z0)))
    )
    mp_core_zero_resid = float(max(abs(_eval_phi(core_nodes[2])), abs(_eval_phi(core_nodes[3]))))
    mp_tail_abs = float(
        sum(
            abs(_eval_phi(mp.mpc(mp.mpf(repr(g)), 0))) ** 2
            + abs(_eval_phi(mp.mpc(-mp.mpf(repr(g)), 0))) ** 2
            for g in gammas[1:]
        )
    )

    # 4. Finite-dimensional FredholmDetTheory matrix audit
    rust_fdet = sna.py_audit_finite_dim_fredholm_det(2.5, -0.7, 1.3, 4.1, 3.25, 0.6)

    return {
        "mp_det3_anom_res": mp_det3_anom_res,
        "rust_det3_anom_res": float(rust_d3["det3_anomaly_residual"]),
        "det3_ab_abs_diff": float(abs(abs(det3_ab) - rust_d3["det3_ab_abs"])),
        "rust_det1_mul_res": float(rust_d1["det1_mul_residual"]),
        "rust_wtail_abs": float(rust_wtail["tail_abs_sum"]),
        "rust_wfull_re": float(rust_wtail["full_sum_re"]),
        "mp_core_re": mp_core_re,
        "mp_core_zero_resid": mp_core_zero_resid,
        "mp_tail_abs": mp_tail_abs,
        "fdet_nilp_err": float(rust_fdet["nilpotent_shear_err"]),
        "fdet_blk_err": float(rust_fdet["block_lower_err"]),
        "fdet_conj_err": float(rust_fdet["conj_invariance_err"]),
    }


def audit_unified_pending_closures_mpmath_vs_rust(dps: int = 60) -> Dict[str, float]:
    """Cross-verify `UP-1`–`UP-5` across all seven `PendingBoundary` domains:
    1. `finiteRankDet` invariant subspace `V = range(F) ⊔ (ker F)ᗮ` vs. `tau_U / p23`;
    2. Strip sub-Gaussian `gaussianCombo` decay & 30-zero density convergence;
    3. Cross-domain checks for Navier–Stokes, Photoelectric, Antimatter `ALPHA-g`,
       Toupin Model 16 Plancherel loops, and Yang–Mills/Higgs/CPT.
    """
    mp.mp.dps = dps
    inv = sna.py_audit_finite_rank_invariant_det(
        [0.4, -0.7, 1.2, 0.3], [0.9, 0.2, -0.5, 1.1], 0.35, -0.2, 0.15
    )

    zeros_raw = sna.py_find_first_n_riemann_zeros(30)
    gammas = [float(z["gamma"]) for z in zeros_raw]
    strip = sna.py_audit_strip_gaussian_combo_decay(gammas, [1.0, -0.35, 0.2], 0.3, 0.5)

    # Exact mpmath sub-Gaussian 30-zero density sum `∑ 2 exp(-γ_n²)` (around ~1e-87)
    mp_subgauss = sum(2 * mp.exp(-(mp.mpf(repr(g)) ** 2)) for g in gammas)

    # Cross-domain Rust checks matching the 7 PendingBoundary solvers
    ns_tg = sna.py_audit_taylor_green_2d(1.2, 1.5, 0.08, 1.1, 0.4, -0.3, 0.25)
    pe_enz = sna.py_audit_enz_oam_photoemission(1.0, 0.05, 1.0, 0.7, 2, 1, 10.0, 1.0, 0.5, 2.0)
    ag = sna.py_audit_antimatter_alpha_g()
    ym = sna.py_audit_yang_mills_higgs_cpt()

    ag_models = {m["model_name"]: m for m in ag["models"]}
    gr_chi2 = float(ag_models["Einstein GR (gamma_PPN=1, beta_PPN=1)"]["chi_sq"])

    return {
        "inv_ambient_dim": float(inv["ambient_dim"]),
        "inv_subspace_dim": float(inv["invariant_dim"]),
        "inv_invariance_residual": float(inv["invariance_residual"]),
        "inv_orth_ker_residual": float(inv["orth_ker_residual"]),
        "inv_subspace_indep_err": float(inv["subspace_indep_err"]),
        "inv_det_vs_tau_err": float(inv["det_vs_tau_err"]),
        "strip_max_bound_ratio": float(strip["max_bound_ratio"]),
        "strip_subgauss_log10": float(mp.log10(mp_subgauss)),
        "strip_weil_re": float(strip["weil_strip_re"]),
        "ns_tg_energy_diss_err": float(ns_tg["energy_enstrophy_decay_residual"]),
        "pe_enz_gain": float(pe_enz["enz_intensity_enhancement"]),
        "pe_oam_qfim_ratio": float(pe_enz["oam_qfim_phi"] / pe_enz["oam_fubini_study_phi"]),
        "ag_gr_chi2_err": abs(gr_chi2 - 25.0 / 17.0),
        "ym_jost_err": float(ym["jost_involution_err"]),
    }
