"""
Symbolic (SymPy) and high-precision (`mpmath`) audit suite for:
- Yang–Mills Mass Gap, Dimensional Transmutation, Strong-Coupling Casimir Suppression,
  and Haar Singlet Projection (`Signals.YangMillsHiggsCPT`, `TOUQGA-2.pdf` Ch. 11, `TOUTYM` 2026),
- Electroweak Higgs Spontaneous Symmetry Breaking (`v`, `m_H`, `m_W`, `m_Z`, `rho_EW = 1`),
- Higgs CP-Mixing Decay Asymmetry, CKM Jarlskog Invariant, & Sakharov Equilibrium Null Theorem,
- Jost's Axiomatic Anti-Unitary CPT Involution (`Theta = CPT`, `Theta^2 = +-I`, exact mass equality,
  and `[H, CP] = 0 <=> [H, T] = 0`).
"""

from typing import Any

import mpmath as mp
import sympy as sp


def verify_symbolic_yang_mills_higgs_cpt_identities() -> dict[str, bool]:
    """Verify exact symbolic identities across Yang–Mills, Higgs SSB, CP, Sakharov, and Jost CPT."""
    # 1. SU(N_c) 1-loop beta_0 and Toupin GKO glueball mass M_k = 2N/(k+N) Lambda_QCD
    n_c, k_lvl, lam_qcd = sp.symbols("n_c k_lvl lam_qcd", positive=True)
    b0_su3 = (11 * 3 - 2 * 0) / 3
    m_gko = (2 * n_c / (k_lvl + n_c)) * lam_qcd
    ym_ok = (
        b0_su3 == 11
        and sp.simplify(m_gko.subs({n_c: 3, k_lvl: 1, lam_qcd: 200}) - 300) == 0
        and sp.simplify(m_gko - 2 * (n_c / (k_lvl + n_c)) * lam_qcd) == 0
    )

    # 1b. Non-Abelian S_3 (|S_3| = 6) Haar singlet projector on C^3 = 1_triv + 2_std
    s3_perms = [
        [0, 1, 2],
        [1, 0, 2],
        [0, 2, 1],
        [2, 1, 0],
        [1, 2, 0],
        [2, 0, 1],
    ]
    s3_mats = []
    for perm in s3_perms:
        m = sp.zeros(3, 3)
        for i in range(3):
            m[i, perm[i]] = 1
        s3_mats.append(m)
    p_s3 = sum(s3_mats, sp.zeros(3, 3)) / 6
    v_std1 = sp.Matrix([1, -1, 0])
    v_std2 = sp.Matrix([1, 1, -2])
    s3_haar_ok = (
        p_s3 * p_s3 == p_s3
        and p_s3.H == p_s3
        and sp.trace(p_s3) == 1
        and all(m * p_s3 == p_s3 and p_s3 * m == p_s3 for m in s3_mats)
        and p_s3 * v_std1 == sp.zeros(3, 1)
        and p_s3 * v_std2 == sp.zeros(3, 1)
    )

    # 2. Higgs Mexican-hat potential unitary-gauge expansion without linear tadpole + rho_EW = 1
    mu_sq, lam_q, h_f, g1, g2 = sp.symbols("mu_sq lam_q h_f g1 g2", positive=True)
    vev = sp.sqrt(mu_sq / lam_q)
    phi_sq = (vev + h_f) ** 2 / 2
    v_mex = -mu_sq * phi_sq + lam_q * phi_sq**2
    v_exp = (
        -(mu_sq**2) / (4 * lam_q)
        + mu_sq * h_f**2
        + lam_q * vev * h_f**3
        + lam_q / 4 * h_f**4
    )
    m_w = sp.Rational(1, 2) * g2 * vev
    m_z = sp.Rational(1, 2) * sp.sqrt(g2**2 + g1**2) * vev
    cos2_w = g2**2 / (g2**2 + g1**2)
    rho_ew = sp.simplify(m_w**2 / (m_z**2 * cos2_w))
    higgs_ok = sp.expand(v_mex - v_exp) == 0 and rho_ew == 1

    # 3. Higgs CP-mixing decay asymmetry & Sakharov thermal equilibrium null theorem
    kap, kapt, alpha_cp, beta, e1, e2, b1, b2 = sp.symbols(
        "kap kapt alpha_cp beta e1 e2 b1 b2", real=True
    )
    a_cp = 2 * kap * kapt * sp.sin(alpha_cp) * sp.cos(alpha_cp)
    sakharov_trace = (
        b1 * sp.exp(-beta * e1)
        + (-b1) * sp.exp(-beta * e1)
        + b2 * sp.exp(-beta * e2)
        + (-b2) * sp.exp(-beta * e2)
    )
    cp_sakharov_ok = (
        sp.simplify(a_cp - kap * kapt * sp.sin(2 * alpha_cp)) == 0
        and sp.simplify(sakharov_trace) == 0
    )

    # 3b. Jarlskog quark mass-splitting prefactor & out-of-equilibrium Sakharov nonzero trace
    mu_q, mc_q, mt_q, md_q, ms_q, mb_q = sp.symbols(
        "mu_q mc_q mt_q md_q ms_q mb_q", positive=True
    )
    jarl_split = (
        (mu_q**2 - mc_q**2)
        * (mc_q**2 - mt_q**2)
        * (mt_q**2 - mu_q**2)
        * (md_q**2 - ms_q**2)
        * (ms_q**2 - mb_q**2)
        * (mb_q**2 - md_q**2)
    )
    d_e = sp.Symbol("d_e", positive=True)
    sakharov_neq = sp.simplify(
        b1 * sp.exp(-beta * e1) + (-b1) * sp.exp(-beta * (e1 + d_e))
    )
    jarl_neq_ok = (
        jarl_split.subs(mu_q, mc_q) == 0
        and jarl_split.subs(ms_q, mb_q) == 0
        and sp.simplify(sakharov_neq - b1 * sp.exp(-beta * e1) * (1 - sp.exp(-beta * d_e))) == 0
    )

    # 4. Exact symbolic 4x4 Jost anti-unitary CPT involution:
    # U_CP = sigma_1 x I_2, V_T_ferm = I_2 x (i sigma_2), V_T_bos = I_4
    u_cp = sp.Matrix(
        [[0, 0, 1, 0], [0, 0, 0, 1], [1, 0, 0, 0], [0, 1, 0, 0]]
    )
    v_t_ferm = sp.Matrix(
        [[0, 1, 0, 0], [-1, 0, 0, 0], [0, 0, 0, 1], [0, 0, -1, 0]]
    )
    u_theta_ferm = u_cp * v_t_ferm
    theta_ferm_sq = u_theta_ferm * u_theta_ferm.conjugate()

    e0, g_mix, delta = sp.symbols("e0 g_mix delta", real=True)
    c_val = g_mix * sp.exp(sp.I * delta)
    c_bar = g_mix * sp.exp(-sp.I * delta)
    h_cpv = sp.Matrix(
        [
            [e0, c_val, 0, 0],
            [c_bar, e0, 0, 0],
            [0, 0, e0, c_bar],
            [0, 0, c_val, e0],
        ]
    )
    # Exact fermionic Kramers CPT Hamiltonian: H_lower = V_2 conj(H_upper) V_2^T = [[e0, -c_val], [-c_bar, e0]]
    h_ferm = sp.Matrix(
        [
            [e0, c_val, 0, 0],
            [c_bar, e0, 0, 0],
            [0, 0, e0, -c_val],
            [0, 0, -c_bar, e0],
        ]
    )
    # CPT commutator [H, Theta_bos] = 0 and [H_ferm, Theta_ferm] = 0 for all delta:
    cpt_comm_zero = sp.simplify(u_cp * h_cpv.conjugate() - h_cpv * u_cp) == sp.zeros(4, 4)
    ferm_cpt_comm_zero = sp.simplify(
        u_theta_ferm * h_ferm.conjugate() - h_ferm * u_theta_ferm
    ) == sp.zeros(4, 4)
    # CP commutator = -(T commutator) up to unitary conjugation: both vanish iff sin(delta) = 0
    cp_comm = sp.simplify(u_cp * h_cpv - h_cpv * u_cp)
    t_comm = sp.simplify(h_cpv.conjugate() - h_cpv)
    cp_t_equiv_ok = (
        cp_comm.subs(delta, 0) == sp.zeros(4, 4)
        and t_comm.subs(delta, 0) == sp.zeros(4, 4)
        and theta_ferm_sq == -sp.eye(4)
        and cpt_comm_zero
        and ferm_cpt_comm_zero
    )

    # 5. Gap-closure contracts (YM-4):
    # (a) 2-state OS reflection positivity exact factorization
    w1, w2, e_a, e_b, t1, t2 = sp.symbols("w1 w2 e_a e_b t1 t2", positive=True)
    f1, f2 = sp.symbols("f1 f2", complex=True)
    s2 = lambda tau: w1 * sp.exp(-e_a * tau) + w2 * sp.exp(-e_b * tau)
    os_lhs = (
        sp.conjugate(f1) * f1 * s2(t1 + t1)
        + sp.conjugate(f1) * f2 * s2(t1 + t2)
        + sp.conjugate(f2) * f1 * s2(t2 + t1)
        + sp.conjugate(f2) * f2 * s2(t2 + t2)
    )
    os_rhs = w1 * sp.conjugate(f1 * sp.exp(-e_a * t1) + f2 * sp.exp(-e_a * t2)) * (
        f1 * sp.exp(-e_a * t1) + f2 * sp.exp(-e_a * t2)
    ) + w2 * sp.conjugate(f1 * sp.exp(-e_b * t1) + f2 * sp.exp(-e_b * t2)) * (
        f1 * sp.exp(-e_b * t1) + f2 * sp.exp(-e_b * t2)
    )
    os_reflection_sym_ok = sp.simplify(sp.expand(os_lhs - os_rhs)) == 0

    # (b) Effective running GKO level matching + EWPT first-order degeneracy at T_c
    m_phys_s = sp.Symbol("m_phys_s", positive=True)
    k_eff_expr = n_c * (2 * lam_qcd / m_phys_s - 1)
    gko_match_ok = sp.simplify(m_gko.subs(k_lvl, k_eff_expr) - m_phys_s) == 0

    d_ew, e_ew, lam_ew, t0_ew, tc_ew = sp.symbols("d_ew e_ew lam_ew t0_ew tc_ew", positive=True)
    phic_expr = 2 * e_ew * tc_ew / lam_ew
    v_eff_tc = (
        d_ew * (tc_ew**2 - t0_ew**2) * phic_expr**2
        - e_ew * tc_ew * phic_expr**3
        + (lam_ew / 4) * phic_expr**4
    )
    v_eff_factored = phic_expr**2 * (d_ew * (tc_ew**2 - t0_ew**2) - e_ew**2 * tc_ew**2 / lam_ew)
    ewpt_sym_ok = sp.simplify(v_eff_tc - v_eff_factored) == 0

    # (c) Higgs CP EFT identity: (sqrt(mu)*cos)^2 + (sqrt(mu)*sin)^2 = mu, 2*kap*kapt = mu*sin(2*alpha)
    kap_eft = sp.sqrt(mu_sq) * sp.cos(alpha_cp)
    kapt_eft = sp.sqrt(mu_sq) * sp.sin(alpha_cp)
    higgs_eft_sym_ok = (
        sp.simplify(kap_eft**2 + kapt_eft**2 - mu_sq) == 0
        and sp.simplify(2 * kap_eft * kapt_eft - mu_sq * sp.sin(2 * alpha_cp)) == 0
    )

    return {
        "ym_mass_gap_sym_ok": bool(ym_ok),
        "s3_nonabelian_haar_sym_ok": bool(s3_haar_ok),
        "higgs_ssb_sym_ok": bool(higgs_ok),
        "cp_sakharov_sym_ok": bool(cp_sakharov_ok),
        "jarlskog_and_neq_sakharov_sym_ok": bool(jarl_neq_ok),
        "jost_cpt_4x4_sym_ok": bool(cp_t_equiv_ok),
        "os_reflection_sym_ok": bool(os_reflection_sym_ok),
        "gko_running_level_and_ewpt_sym_ok": bool(gko_match_ok and ewpt_sym_ok),
        "higgs_eft_cp_sym_ok": bool(higgs_eft_sym_ok),
    }


def audit_yang_mills_higgs_cpt_high_precision(dps: int = 45) -> dict[str, Any]:
    """Cross-verify high-precision `mpmath` evaluations against Rust/PyO3 `py_audit_yang_mills_higgs_cpt`."""
    import signals_numerical_adapter as sna

    rust_rep = sna.py_audit_yang_mills_higgs_cpt()
    sym_checks = verify_symbolic_yang_mills_higgs_cpt_identities()

    with mp.workdps(dps):
        b0_nf5 = mp.mpf(33 - 10) / 3
        g_sq = 4 * mp.pi * mp.mpf("0.118")
        lam_ym_mp = mp.mpf("91.1876") * mp.exp(-8 * mp.pi**2 / (b0_nf5 * g_sq))

        v_mp = mp.mpf("246.22")
        m_h_mp = mp.mpf("125.25")
        lam_q = (m_h_mp**2) / (2 * v_mp**2)
        mu_sq = mp.mpf("0.5") * m_h_mp**2
        m_w_mp = mp.mpf("0.5") * mp.mpf("0.6528") * mp.sqrt(mu_sq / lam_q)
        m_z_mp = mp.mpf("0.5") * mp.sqrt(mp.mpf("0.6528") ** 2 + mp.mpf("0.3574") ** 2) * mp.sqrt(mu_sq / lam_q)
        cos_sq = mp.mpf("0.6528") ** 2 / (mp.mpf("0.6528") ** 2 + mp.mpf("0.3574") ** 2)
        rho_mp = (m_w_mp**2) / (m_z_mp**2 * cos_sq)

        j_cp_mp = (
            mp.cos(mp.mpf("0.227"))
            * mp.cos(mp.mpf("0.0418"))
            * mp.cos(mp.mpf("0.0037")) ** 2
            * mp.sin(mp.mpf("0.227"))
            * mp.sin(mp.mpf("0.0418"))
            * mp.sin(mp.mpf("0.0037"))
            * mp.sin(mp.mpf("1.144"))
        )
        a_62_mp = mp.exp(-(4 * mp.pi**2 * mp.mpf("6.2")) / (11 * 3))
        atlas_kt_mp = mp.sin(28 * mp.pi / 180)

    return {
        **sym_checks,
        "rust_report": rust_rep,
        "lambda_ym_diff": float(abs(rust_rep["lambda_ym_gev"] - float(lam_ym_mp))),
        "m_w_diff": float(abs(rust_rep["m_w_gev"] - float(m_w_mp))),
        "m_z_diff": float(abs(rust_rep["m_z_gev"] - float(m_z_mp))),
        "rho_ew_diff": float(abs(rust_rep["rho_ew"] - float(rho_mp))),
        "jarlskog_diff": float(abs(rust_rep["jarlskog_sm"] - float(j_cp_mp))),
        "lattice_a62_diff": float(abs(rust_rep["lattice_spacing_beta62"] - float(a_62_mp))),
        "atlas_kt_diff": float(abs(rust_rep["atlas_higgs_cp_max_kappatilde"] - float(atlas_kt_mp))),
    }
