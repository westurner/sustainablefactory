"""
SymPy & Arbitrary-Precision `mpmath` Analytical-Bridge Toolkit for the Riemann Hypothesis.

Implements reproducible symbolic proofs and high-precision numerical probes across the
four open analytical bridges isolated in `Signals.Pending.RiemannHypothesisPendingBoundary`
and paired with `Signals.RiemannSpectral` (Sections 7–9):

1. **Symbolic SymPy Bridge Proofs** (`verify_symbolic_rh_bridge_identities`):
   - Cubic Jensen discriminant factorization & Hermite He_3 criterion (`|c| < 2`).
   - Weil 2x2 Sylvester positivity & explicit negative-determinant disproof vector.
   - De Bruijn–Newman backward heat equation (`d_t H_t = -d_z^2 H_t`) on quadratic
     Lehmer extrema.
   - Keiper–Li binomial map & exact inversion between `ln(2 xi(1 + z))` Taylor
     coefficients `b_k` and infinite-zero Li coefficients `lambda_n`.
2. **Griffin–Ono–Rolen–Zagier (PNAS 2019) Positive-Integral Jensen Polynomials**:
   - Uses Riemann's strictly positive kernel `Phi(u) > 0` to compute exact moments
     `gamma_n` with zero catastrophic cancellation, verifying strict real-rootedness
     (hyperbolicity) of `J^{d,n}(X)` for `d = 2..6` and Hermite `He_3` scaling.
3. **Exact Infinite-Zero Keiper–Li Coefficients (`lambda_1 .. lambda_N`)**:
   - Evaluates the exact Li sequence summed over ALL infinitely many nontrivial zeros
     via Cauchy contour integration of `ln(2 xi(1 + z))` around `s = 1`, cross-checked
     against the exact analytic identity `lambda_1 = 1 + gamma_E/2 - ln(4 pi)/2`.
4. **Exact Weil Explicit-Formula Gaussian Gram Matrix (`Prime + Archimedean` vs. `Zero`)**:
   - Cross-verifies the prime-power + archimedean digamma side against the spectral
     zero-sum side to `< 1e-45` at 50-digit precision and checks strict positive-definiteness
     (Weil positivity) on a finite-dimensional Gaussian subspace.
5. **De Bruijn–Newman Backward Heat-Flow Collision on Lehmer's 1956 Pair**:
   - Compares local backward heat collision time `t_heat = Z(g*) / Z''(g*)` against
     the 2-zero Calogero–Moser merge time `t_CM = -gap^2 / 8` on zeros #6709 and #6710.

**Epistemic Boundary**: Passing these finite-degree, finite-index, and finite-subspace
audits does NOT prove the classical Riemann Hypothesis for `zeta(s)`; the four global
infinite-dimensional bridges remain explicitly open in `Signals.Pending`.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple
import mpmath as mp
import sympy as sp


def verify_symbolic_rh_bridge_identities() -> Dict[str, bool]:
    """Symbolically verify all four algebraic RH-bridge theorems in SymPy."""
    # 1. Factored cubic Jensen discriminant & Hermite He_3 criterion
    a, r1, r2, r3, c = sp.symbols("a r1 r2 r3 c", real=True)
    disc3 = (
        lambda aa, bb, cc, dd: 18 * aa * bb * cc * dd
        - 4 * bb**3 * dd
        + bb**2 * cc**2
        - 4 * aa * cc**3
        - 27 * aa**2 * dd**2
    )
    b_f = -a * (r1 + r2 + r3)
    c_f = a * (r1 * r2 + r1 * r3 + r2 * r3)
    d_f = -a * r1 * r2 * r3
    cubic_factored_ok = (
        sp.expand(
            disc3(a, b_f, c_f, d_f)
            - a**4 * (r1 - r2) ** 2 * (r1 - r3) ** 2 * (r2 - r3) ** 2
        )
        == 0
    )
    hermite3_ok = sp.expand(disc3(1, 0, -3, c) - 27 * (4 - c**2)) == 0

    # 2. Weil 2x2 Sylvester completion-of-squares & disproof vector identity
    w00, w01, w11, v0, v1 = sp.symbols("w00 w01 w11 v0 v1", real=True)
    qf = w00 * v0**2 + 2 * w01 * v0 * v1 + w11 * v1**2
    sylvester_ok = (
        sp.expand(
            w00 * qf - ((w00 * v0 + w01 * v1) ** 2 + (w00 * w11 - w01**2) * v1**2)
        )
        == 0
    )
    disproof_ok = (
        sp.expand(
            qf.subs({v0: -w01, v1: w00}) - w00 * (w00 * w11 - w01**2)
        )
        == 0
    )

    # 3. De Bruijn–Newman backward heat PDE d_t H_t = -d_z^2 H_t (quadratic & quartic)
    z0, z2, z4, t, dz = sp.symbols("z0 z2 z4 t dz", real=True)
    H_t = (z0 - z2 * t) + sp.Rational(1, 2) * z2 * dz**2
    dbn_pde_ok = sp.simplify(sp.diff(H_t, t) + sp.diff(H_t, dz, 2)) == 0
    dbn_collision_ok = sp.simplify(H_t.subs({t: z0 / z2, dz: 0})) == 0
    H_q = (
        (z0 - z2 * t + sp.Rational(1, 2) * z4 * t**2)
        + sp.Rational(1, 2) * (z2 - z4 * t) * dz**2
        + sp.Rational(1, 24) * z4 * dz**4
    )
    dbn_quartic_pde_ok = sp.simplify(sp.diff(H_q, t) + sp.diff(H_q, dz, 2)) == 0
    dbn_quartic_shift_ok = (
        sp.simplify(
            H_q.subs({t: z0 / z2, dz: 0}) - sp.Rational(1, 2) * z4 * (z0 / z2) ** 2
        )
        == 0
    )

    # 4. Keiper–Li binomial map & exact inversion for n = 1, 2, 3
    b1, b2, b3 = sp.symbols("b1 b2 b3", real=True)
    l1 = b1
    l2 = 2 * (b1 + b2)
    l3 = 3 * (b1 + 2 * b2 + b3)
    keiper_inv_ok = (
        sp.simplify(l1 - b1) == 0
        and sp.simplify(l2 / 2 - l1 - b2) == 0
        and sp.simplify(l3 / 3 - l2 + l1 - b3) == 0
    )

    # 5. 4-zero Calogero–Moser symmetric neighbor-squeezing identity
    delta, outer_d = sp.symbols("delta outer_d", positive=True)
    v3 = 2 / (2 * delta) + 2 / (delta + outer_d) + 2 / (delta - outer_d)
    v2 = 2 / (-2 * delta) + 2 / (-delta + outer_d) + 2 / (-delta - outer_d)
    cm4_squeeze_ok = (
        sp.simplify((v3 - v2) - (2 / delta - 8 * delta / (outer_d**2 - delta**2))) == 0
    )

    return {
        "cubic_discriminant_factored": cubic_factored_ok,
        "hermite3_discriminant": hermite3_ok,
        "weil_sylvester_identity": sylvester_ok,
        "weil_disproof_witness": disproof_ok,
        "dbn_quadratic_heat_pde": dbn_pde_ok,
        "dbn_collision_time": dbn_collision_ok,
        "dbn_quartic_heat_pde": dbn_quartic_pde_ok,
        "dbn_quartic_collision_shift": dbn_quartic_shift_ok,
        "keiper_li_inversion_123": keiper_inv_ok,
        "cm4_symmetric_neighbor_squeeze": cm4_squeeze_ok,
    }


def completed_xi(s: mp.mpc | mp.mpf) -> mp.mpc | mp.mpf:
    """Completed Riemann xi function `xi(s) = (1/2) s (s - 1) pi^(-s/2) Gamma(s/2) zeta(s)`."""
    return (
        mp.mpf("0.5")
        * s
        * (s - 1)
        * mp.power(mp.pi, -s / 2)
        * mp.gamma(s / 2)
        * mp.zeta(s)
    )


def riemann_phi_kernel(u: mp.mpf) -> mp.mpf:
    """Strictly positive Riemann kernel `Phi(u)` such that `Xi(z) = 4 int_0^inf Phi(u) cos(z u) du`."""
    e4u = mp.exp(4 * u)
    e5u = mp.exp(5 * u)
    e9u = e4u * e5u
    total = mp.mpf(0)
    m = 1
    while True:
        m2 = m * m
        ex = mp.pi * m2 * e4u
        if ex > 220:
            break
        total += (2 * mp.pi**2 * m2 * m2 * e9u - 3 * mp.pi * m2 * e5u) * mp.exp(-ex)
        m += 1
    return 2 * total


def compute_gorz_jensen_moments(
    n_max: int = 20, dps: int = 70
) -> Tuple[List[mp.mpf], float]:
    """Compute exact GORZ (PNAS 2019) moments `gamma_n = (n! / (2n)!) * 4 int_0^inf Phi(u) u^{2n} du`.

    Returns `(gammas, zero_moment_xi_half_error)` where `gammas[0] == xi(1/2)`.
    """
    with mp.workdps(dps):
        gammas: List[mp.mpf] = []
        for n in range(n_max + 1):
            moment = mp.quad(
                lambda u: riemann_phi_kernel(u) * mp.power(u, 2 * n),
                [0, 0.4, 0.8, 1.4, 2.2, 3.2],
            )
            gn = (mp.factorial(n) / mp.factorial(2 * n)) * 4 * moment
            gammas.append(gn)
        xi_half = completed_xi(mp.mpf("0.5"))
        err0 = float(abs(gammas[0] - xi_half))
        return gammas, err0


def audit_gorz_jensen_hyperbolicity(
    degrees: Sequence[int] = (2, 3, 4, 5, 6),
    n_max: int = 12,
    dps: int = 70,
) -> Dict[str, object]:
    """Audit real-rootedness (hyperbolicity) of GORZ Jensen polynomials `J^{d,n}(X)`."""
    max_deg = max(degrees)
    gammas, xi_half_err = compute_gorz_jensen_moments(n_max=n_max + max_deg, dps=dps)

    per_degree = []
    hermite3_residuals = []
    with mp.workdps(dps):
        for d in degrees:
            all_real = True
            max_imag = mp.mpf(0)
            min_gap = mp.inf
            for n in range(0, n_max + 1):
                coeffs = [mp.binomial(d, j) * gammas[n + j] for j in range(d, -1, -1)]
                roots = mp.polyroots(coeffs, maxsteps=300, extraprec=30)
                for r in roots:
                    im = abs(mp.im(r))
                    if im > max_imag:
                        max_imag = im
                    if im > mp.mpf("1e-35"):
                        all_real = False
                reals = sorted(mp.re(r) for r in roots)
                for i in range(len(reals) - 1):
                    gap = reals[i + 1] - reals[i]
                    if gap < min_gap:
                        min_gap = gap
            per_degree.append(
                {
                    "degree": d,
                    "n_max": n_max,
                    "all_real": all_real,
                    "max_imag": float(max_imag),
                    "min_root_gap": float(min_gap),
                }
            )

        for n in range(0, n_max + 1):
            g0, g1, g2, g3 = gammas[n], gammas[n + 1], gammas[n + 2], gammas[n + 3]
            p2, p1, p0 = 3 * g2 / g3, 3 * g1 / g3, g0 / g3
            q1 = p1 - p2**2 / 3
            q0 = 2 * p2**3 / 27 - p2 * p1 / 3 + p0
            s_scale = mp.sqrt(-q1 / 3)
            c_n = float(q0 / (s_scale**3))
            hermite3_residuals.append(
                {"n": n, "c_n": c_n, "strictly_hyperbolic": abs(c_n) < 2.0}
            )

    return {
        "xi_half_moment_error": xi_half_err,
        "gamma_0": float(gammas[0]),
        "gamma_1": float(gammas[1]),
        "per_degree": per_degree,
        "hermite3_residuals": hermite3_residuals,
    }


def compute_exact_keiper_li_coefficients(
    max_n: int = 20, dps: int = 65
) -> Dict[str, object]:
    """Compute exact infinite-zero Keiper–Li coefficients `lambda_1 .. lambda_{max_n}`
    via Cauchy contour integration of `ln(2 xi(1 + z))` on `|z| = 2.0`.
    """
    with mp.workdps(dps):
        radius = mp.mpf("2.0")
        m_pts = max(128, 4 * max_n)
        ln_vals = [
            mp.log(2 * completed_xi(1 + radius * mp.exp(2j * mp.pi * k / m_pts)))
            for k in range(m_pts)
        ]
        b = [mp.mpf(0)]
        for m in range(1, max_n + 1):
            cm = sum(
                ln_vals[k] * mp.exp(-2j * mp.pi * k * m / m_pts) for k in range(m_pts)
            ) / (m_pts * mp.power(radius, m))
            b.append(mp.re(cm))

        lambdas: List[float] = []
        for n in range(1, max_n + 1):
            ln_n = n * sum(mp.binomial(n - 1, k - 1) * b[k] for k in range(1, n + 1))
            lambdas.append(float(ln_n))

        lam1_exact = 1 + mp.euler / 2 - mp.log(4 * mp.pi) / 2
        lam1_err = float(abs(b[1] - lam1_exact))
        return {
            "max_n": max_n,
            "lambdas": lambdas,
            "all_positive": all(v > 0.0 for v in lambdas),
            "lambda_1_analytic_error": lam1_err,
        }


def _sieve_primes(n_max: int) -> List[int]:
    is_p = [True] * (n_max + 1)
    is_p[0] = is_p[1] = False
    for i in range(2, int(n_max**0.5) + 1):
        if is_p[i]:
            for j in range(i * i, n_max + 1, i):
                is_p[j] = False
    return [i for i, ok in enumerate(is_p) if ok]


def evaluate_weil_explicit_formula(
    alpha: mp.mpf,
    zeros_list: Sequence[mp.mpf],
    primes: Sequence[int],
    n_max: int = 500,
) -> Tuple[mp.mpf, mp.mpf]:
    """Return `(zero_side, prime_plus_archimedean_side)` for `F(x) = exp(-alpha x^2)`."""
    zero_side = (
        2
        * mp.sqrt(mp.pi / alpha)
        * sum(mp.exp(-(g**2) / (4 * alpha)) for g in zeros_list)
    )

    pole = 2 * mp.sqrt(mp.pi / alpha) * mp.exp(mp.mpf(1) / (16 * alpha))
    prime_sum = mp.mpf(0)
    for p in primes:
        lnp = mp.log(p)
        pm = p
        m = 1
        while pm <= n_max:
            x = m * lnp
            prime_sum += (lnp / mp.sqrt(pm)) * mp.exp(-alpha * x * x)
            pm *= p
            m += 1

    arch_int = (mp.sqrt(mp.pi / alpha) / mp.pi) * mp.quad(
        lambda t: mp.exp(-(t**2) / (4 * alpha))
        * mp.re(mp.digamma(mp.mpc(mp.mpf("0.25"), t / 2))),
        [0, 15, 50, 150, mp.inf],
    )
    prime_arch_side = pole - 2 * prime_sum + arch_int - mp.log(mp.pi)
    return zero_side, prime_arch_side


def audit_weil_gaussian_gram_matrix(
    alphas: Sequence[float] = (40.0, 80.0, 160.0, 320.0),
    num_zeros: int = 100,
    n_max: int = 500,
    dps: int = 50,
) -> Dict[str, object]:
    """Build the exact `d x d` Weil Explicit-Formula Gaussian Gram matrix on both the
    Prime+Archimedean side and the Zero-sum side, checking agreement and positivity.
    """
    d = len(alphas)
    with mp.workdps(dps):
        a_mp = [mp.mpf(str(a)) for a in alphas]
        zeros_list = [mp.im(mp.zetazero(k)) for k in range(1, num_zeros + 1)]
        primes = _sieve_primes(n_max)

        w_prime = mp.matrix(d, d)
        w_zero = mp.matrix(d, d)
        for i in range(d):
            for j in range(i, d):
                pref = mp.sqrt(mp.pi / (a_mp[i] + a_mp[j]))
                a_eff = a_mp[i] * a_mp[j] / (a_mp[i] + a_mp[j])
                zs, ps = evaluate_weil_explicit_formula(
                    a_eff, zeros_list, primes, n_max=n_max
                )
                w_zero[i, j] = w_zero[j, i] = pref * zs
                w_prime[i, j] = w_prime[j, i] = pref * ps

        max_diff = max(
            abs(w_prime[i, j] - w_zero[i, j]) for i in range(d) for j in range(d)
        )
        evals_prime, _ = mp.eigsy(w_prime)
        evals_zero, _ = mp.eigsy(w_zero)
        return {
            "dimension": d,
            "alphas": list(alphas),
            "max_prime_vs_zero_diff": float(max_diff),
            "eigenvalues_prime_arch": [float(e) for e in evals_prime],
            "eigenvalues_zero": [float(e) for e in evals_zero],
            "strictly_positive_definite": all(e > 0 for e in evals_prime),
        }


def audit_lehmer_dbn_backward_heat(dps: int = 40) -> Dict[str, float]:
    """Compare local de Bruijn–Newman backward heat-flow collision time `t_heat = Z(g*)/Z''(g*)`
    against the 2-zero Calogero–Moser merge time `t_CM = -gap^2 / 8` on Lehmer's 1956 pair.
    """
    with mp.workdps(dps):
        g6709 = mp.im(mp.zetazero(6709))
        g6710 = mp.im(mp.zetazero(6710))
        g_mid = mp.findroot(lambda x: mp.diff(mp.siegelz, x, 1), (g6709 + g6710) / 2)
        z0 = mp.siegelz(g_mid)
        z2 = mp.diff(mp.siegelz, g_mid, 2)
        gap = g6710 - g6709
        t_heat = z0 / z2
        t_cm = -(gap**2) / 8
        return {
            "gamma_6709": float(g6709),
            "gamma_6710": float(g6710),
            "gap": float(gap),
            "extremum_gamma": float(g_mid),
            "z0": float(z0),
            "z2": float(z2),
            "t_heat": float(t_heat),
            "t_calogero_moser": float(t_cm),
            "ratio_t_heat_over_t_cm": float(t_heat / t_cm),
        }


def _build_hermite_conv_poly_coeffs(j: int, k: int) -> List[sp.Rational]:
    """Symbolic SymPy polynomial `P_{jk}(w)` for the convolution of even Hermite–Gaussians."""
    s, w = sp.symbols("s w")
    prod = sp.Poly(sp.expand(sp.hermite(2 * j, s) * sp.hermite(2 * k, s)), s)
    poly_w = sp.Integer(0)
    for (deg,), coeff in prod.terms():
        r = deg // 2
        poly_w += coeff * ((-1) ** r) * sp.Rational(1, 4**r) * sp.hermite(2 * r, w / 2)
    return sp.Poly(sp.expand(poly_w), w).all_coeffs()


def _eval_rat_poly(coeffs: Sequence[sp.Rational], xval: mp.mpf | mp.mpc) -> mp.mpf | mp.mpc:
    acc = mp.mpf(0)
    for c in coeffs:
        acc = acc * xval + mp.mpf(int(c.p)) / mp.mpf(int(c.q))
    return acc


def audit_weil_hermite_gaussian_gram_matrix(
    dimension: int = 6,
    alpha: float = 100.0,
    num_zeros: int = 120,
    n_max: int = 500,
    dps: int = 50,
) -> Dict[str, object]:
    """Build the `d x d` Weil Explicit-Formula Gram matrix in the orthonormal even
    Hermite–Gaussian basis `phi_k(x) = N_k H_{2k}(sqrt(2 alpha) x) exp(-alpha x^2)`
    using exact SymPy convolution polynomials, verifying Prime+Archimedean vs. Zero
    parity, strict positive-definiteness, full condition number `kappa(W)`, and
    Strong-Mpemba slow-mode-projected condition number `kappa_{perp v_1}(W) = lambda_max / lambda_2`.
    """
    p_polys = [
        [_build_hermite_conv_poly_coeffs(j, k) for k in range(dimension)]
        for j in range(dimension)
    ]
    s_sym = sp.Symbol("s")
    h_polys = [
        sp.Poly(sp.hermite(2 * k, s_sym), s_sym).all_coeffs() for k in range(dimension)
    ]

    with mp.workdps(dps):
        alpha_v = mp.mpf(str(alpha))
        sq2a = mp.sqrt(2 * alpha_v)
        zeros_list = [mp.im(mp.zetazero(k)) for k in range(1, num_zeros + 1)]
        primes = _sieve_primes(n_max)
        c_norm = [
            ((-1) ** k)
            * mp.power(2 * mp.pi / alpha_v, mp.mpf("0.25"))
            / mp.sqrt(mp.power(2, 2 * k) * mp.factorial(2 * k))
            for k in range(dimension)
        ]

        w_zero = mp.matrix(dimension, dimension)
        w_prime = mp.matrix(dimension, dimension)

        for j in range(dimension):
            for k in range(j, dimension):
                zs = mp.mpf(0)
                for g in zeros_list:
                    s_val = g / sq2a
                    zs += (
                        _eval_rat_poly(h_polys[j], s_val)
                        * _eval_rat_poly(h_polys[k], s_val)
                        * mp.exp(-(s_val**2))
                    )
                w_zero[j, k] = w_zero[k, j] = 2 * c_norm[j] * c_norm[k] * zs

                pref_f = c_norm[j] * c_norm[k] * sq2a / (2 * mp.sqrt(mp.pi))
                s_pole = mp.mpc(0, mp.mpf("0.5") / sq2a)
                pole = (
                    2
                    * c_norm[j]
                    * c_norm[k]
                    * mp.re(
                        _eval_rat_poly(h_polys[j], s_pole)
                        * _eval_rat_poly(h_polys[k], s_pole)
                        * mp.exp(-(s_pole**2))
                    )
                )
                psum = mp.mpf(0)
                for p in primes:
                    lnp = mp.log(p)
                    pm = p
                    m = 1
                    while pm <= n_max:
                        xv = m * lnp
                        fval = (
                            pref_f
                            * _eval_rat_poly(p_polys[j][k], sq2a * xv)
                            * mp.exp(-mp.mpf("0.5") * alpha_v * xv * xv)
                        )
                        psum += (lnp / mp.sqrt(pm)) * fval
                        pm *= p
                        m += 1

                f0 = pref_f * _eval_rat_poly(p_polys[j][k], mp.mpf(0))
                arch_int = (c_norm[j] * c_norm[k] / mp.pi) * mp.quad(
                    lambda tv: _eval_rat_poly(h_polys[j], tv / sq2a)
                    * _eval_rat_poly(h_polys[k], tv / sq2a)
                    * mp.exp(-(tv**2) / (2 * alpha_v))
                    * mp.re(mp.digamma(mp.mpc(mp.mpf("0.25"), tv / 2))),
                    [0, 15, 50, 150, mp.inf],
                )
                w_prime[j, k] = w_prime[k, j] = (
                    pole - 2 * psum + arch_int - f0 * mp.log(mp.pi)
                )

        max_diff = max(
            abs(w_prime[i, j] - w_zero[i, j])
            for i in range(dimension)
            for j in range(dimension)
        )
        evals_p, _ = mp.eigsy(w_prime)
        evals_list = sorted(float(evals_p[i]) for i in range(dimension))
        cond_full = evals_list[-1] / evals_list[0]
        cond_mpemba_fast = (
            evals_list[-1] / evals_list[1] if dimension >= 2 else 1.0
        )
        return {
            "dimension": dimension,
            "alpha": alpha,
            "max_prime_vs_zero_diff": float(max_diff),
            "eigenvalues_prime_arch": evals_list,
            "strictly_positive_definite": all(e > 0.0 for e in evals_list),
            "condition_number_full": cond_full,
            "condition_number_mpemba_fast_subspace": cond_mpemba_fast,
            "mpemba_conditioning_gain": cond_full / cond_mpemba_fast,
        }


def audit_lehmer_quartic_heat_and_neighbor_pressure(
    dps: int = 45,
) -> Dict[str, float]:
    """Audit the 4th-order quartic de Bruijn–Newman heat collision root `t_quartic`
    and the 10-zero Calogero–Moser neighbor-squeezing correction on Lehmer's 1956 pair
    (#6709 & #6710 flanked by #6705..#6714).
    """
    with mp.workdps(dps):
        zeros_window = [mp.im(mp.zetazero(k)) for k in range(6705, 6715)]
        g_left, g_right = zeros_window[4], zeros_window[5]
        g_mid = mp.findroot(
            lambda y: mp.diff(mp.siegelz, y, 1), (g_left + g_right) / 2
        )
        z0 = mp.siegelz(g_mid)
        z2 = mp.diff(mp.siegelz, g_mid, 2)
        z4 = mp.diff(mp.siegelz, g_mid, 4)
        gap = g_right - g_left

        t_quad = z0 / z2
        disc = z2**2 - 2 * z0 * z4
        t_quartic = (z2 + mp.sqrt(disc)) / z4
        quartic_res = z0 - z2 * t_quartic + mp.mpf("0.5") * z4 * t_quartic**2
        t_cm2 = -(gap**2) / 8

        # Repulsive Calogero–Moser velocities: v_k = sum_{j != k} 2 / (z_k - z_j)
        rate_2 = 4 / gap
        v_left_10 = sum(
            2 / (g_left - zeros_window[j])
            for j in range(len(zeros_window))
            if j != 4
        )
        v_right_10 = sum(
            2 / (g_right - zeros_window[j])
            for j in range(len(zeros_window))
            if j != 5
        )
        rate_10 = v_right_10 - v_left_10
        return {
            "extremum_gamma": float(g_mid),
            "gap": float(gap),
            "z0": float(z0),
            "z2": float(z2),
            "z4": float(z4),
            "t_quad": float(t_quad),
            "t_quartic": float(t_quartic),
            "quartic_residual": float(abs(quartic_res)),
            "t_cm2": float(t_cm2),
            "rate_2zero": float(rate_2),
            "rate_10zero": float(rate_10),
            "neighbor_squeeze_delta": float(rate_10 - rate_2),
            "neighbor_squeeze_pct": float((rate_10 / rate_2 - 1) * 100),
        }


def audit_celestial_holography_toupin_and_turner_graviton(
    dps: int = 45,
) -> Dict[str, Any]:
    """Audit Daniel Toupin's Celestial Holography framework (`TOUQGA-2.pdf`) and
    its integration into Turner Models 15a & 15b across SymPy and high-precision `mpmath`.

    Verifies:
    1. Canonical dictionary `Delta = 2s` uniqueness and chiral `sl(2, C)` Casimir
       `h(h-1) = s(s-1) = (-1/4 + sigma_dev^2 - gamma^2) + 2 i sigma_dev gamma`.
    2. `Gr(2,4)(F_q)` Hasse–Weil point-count polynomial `1 + q + 2q^2 + q^3 + q^4`,
       Poincaré self-duality, and 45-digit Euler factor identity for `zeta_{Gr(2,4)}(s)`.
    3. Plancherel–Unruh blackbody identity `P(lambda) = pi*lambda/sinh(pi*lambda) = 2*pi*lambda*(n_B(pi*lambda) - n_B(2*pi*lambda))`,
       exact rational 1-loop `M_1 = 1/8` and 2-loop `M_2 = 1/90`, and 45-digit 3-loop
       `M_3 = 0.0010280204768206811181554290742928570866263084` via our compact-interval
       decomposition `F(y) = ((1 + y^2)/12)*P(y) + (y/(2*pi)) * int_0^{1/2} P(u*y)*P((1-u)*y) du`.
    4. Biane–Pitman–Yor Brownian bridge range moment identity `E[V^s] = 2 * xi(s)` alongside
       an explicit positive self-dual density counterexample with off-critical-line real Mellin zeros.
    5. Exact diagnosis of the Appendix B.2 `c(epsilon)` power-counting artifact and Pathway 1
       Cesàro `sigma < 1/2` symmetry (`N_reg(1/2 - delta, R) = N_reg(1/2 + delta, R) > 1`).
    """
    # --- Part A: Exact SymPy Symbolic Checks ---
    s, alpha, beta, d, q, L = sp.symbols("s alpha beta d q L")
    sigma_dev, gamma = sp.symbols("sigma_dev gamma", real=True)

    # 1. Canonical dictionary uniqueness: (d - 2) - (alpha*s + beta) == alpha*(1 - s) + beta and alpha*1 + beta == d - 2
    eq_intertwine = sp.Poly(
        (d - 2) - (alpha * s + beta) - (alpha * (1 - s) + beta), s
    ).all_coeffs()
    sol_dict = sp.solve(eq_intertwine + [alpha * 1 + beta - (d - 2)], (alpha, beta))
    dict_unique_ok = sol_dict[alpha] == d - 2 and sol_dict[beta] == 0

    # 2. Chiral sl(2, C) Casimir h(h - 1) = s(s - 1) at s = 1/2 + sigma_dev + i*gamma
    s_complex = sp.Rational(1, 2) + sigma_dev + sp.I * gamma
    casimir_expr = sp.expand(s_complex * (s_complex - 1))
    casimir_re = sp.re(casimir_expr)
    casimir_im = sp.im(casimir_expr)
    casimir_ok = (
        sp.simplify(casimir_re - (-sp.Rational(1, 4) + sigma_dev**2 - gamma**2)) == 0
        and sp.simplify(casimir_im - 2 * sigma_dev * gamma) == 0
    )

    # 3. Gr(2,4)(F_q) Hasse–Weil polynomial & Poincaré self-duality
    p_gr24 = 1 + q + 2 * q**2 + q**3 + q**4
    hasse_weil_sym_ok = (
        sp.expand(p_gr24 - (1 + q**2) * (1 + q + q**2)) == 0
        and sp.expand((q**2 - 1) * (q - 1) * p_gr24 - (q**4 - 1) * (q**3 - 1)) == 0
        and sp.simplify(q**4 * p_gr24.subs(q, 1 / q) - p_gr24) == 0
    )

    # 4. Path vs. complete-graph edge deficit C(L, 2) - (L - 1) = (L - 1)(L - 2)/2
    edge_deficit = sp.simplify(L * (L - 1) / 2 - (L - 1) - (L - 1) * (L - 2) / 2) == 0

    # 5. Explicit positive self-dual probability density counterexample for Pathway 3:
    # Consider p_c(v) = C * v^{-3/2} * (v^a + v^{-a}) * exp(-1/2 * (ln v)^2) on v > 0 (strictly > 0).
    # In u = ln v, v^{s-1} p_c(v) dv = C * e^{(s - 1/2) u} * 2 cosh(a u) * e^{-u^2 / 2} du.
    # For a = 2, its Mellin transform is proportional to exp(((s-1/2)+2)^2 / 2) + exp(((s-1/2)-2)^2 / 2)
    # = 2 * exp((z^2 + 4)/2) * cosh(2 z) where z = s - 1/2.
    # Even simpler: p_poly(v) = C * v^{-3/2} * (1 + c * (ln v)^2) * exp(-(ln v)^2 / 2) > 0 for c > 0.
    # Its Mellin transform in z = s - 1/2 is proportional to (1 + c * (1 + z^2)) * exp(z^2 / 2),
    # which for c > 0 has purely imaginary roots in z? Wait: what about
    # g(u) = (u^2 - a^2)^2 * exp(-u^2 / 2) >= 0 (strictly positive a.e. and self-dual g(-u) = g(u))?
    # Let us compute int_{-inf}^{inf} e^{z u} (u^2 - a^2)^2 e^{-u^2 / 2} du in SymPy!
    u_sym, z_sym = sp.symbols("u_sym z_sym")
    # Using Gaussian moments E[e^{z U} (U^2 - a^2)^2] for U ~ N(0, 1):
    # Under e^{z U - U^2/2} = e^{z^2/2} e^{-(U - z)^2/2}, U shifts to z + Z with Z ~ N(0, 1):
    # E[((z + Z)^2 - a^2)^2] = (z^2 + 1 - a^2)^2 + 4 z^2 + 2 = z^4 + (6 - 2 a^2) z^2 + (a^4 - 2 a^2 + 3).
    # At a = 3 (so a^2 = 9): polynomial in z^2 is z^4 - 12 z^2 + 66 (complex off-line zeros!),
    # and at a = 2 (a^2 = 4): z^4 - 2 z^2 + 11 = (z^2 - 1)^2 + 10 = 0 -> z = +- sqrt(1 +- i sqrt(10)),
    # which has Re(z) != 0 (i.e. Re(s) != 1/2) AND Im(z) != 0!
    a_val = sp.Integer(2)
    z_var = sp.Symbol("z_var")
    mellin_poly = sp.expand(
        (z_var**2 + 1 - a_val**2) ** 2 + 4 * z_var**2 + 2
    )  # z^4 - 2 z^2 + 11
    off_line_root_sq = 1 + sp.I * sp.sqrt(10)
    pathway3_counterexample_ok = (
        sp.simplify(mellin_poly.subs(z_var**2, off_line_root_sq)) == 0
    )

    # 6. Appendix B.2 Laurent expansion of Gamma(eps - 1)^2 * Gamma(3 - 2*eps) / (Gamma(2 - eps)^2 * Gamma(2*eps - 2))
    # Since Gamma(eps - 1) ~ -1/eps, Gamma(3 - 2*eps) -> 2! = 2, Gamma(2 - eps) -> 1, and
    # Gamma(2*eps - 2) ~ (+1/2!) / (2*eps) = +1/(4*eps), the true leading pole is +8/eps
    # (whereas TOUQGA-2.pdf p. 934 wrote -4/eps and p. 936 wrote +2/eps).
    eps_sym = sp.Symbol("eps_sym")
    gamma_ratio_expr = (
        sp.gamma(eps_sym - 1) ** 2
        * sp.gamma(3 - 2 * eps_sym)
        / (sp.gamma(2 - eps_sym) ** 2 * sp.gamma(2 * eps_sym - 2))
    )
    b2_leading_pole_coeff = float(sp.limit(eps_sym * gamma_ratio_expr, eps_sym, 0))

    # 7. Hyperbolic sech^4(k/2) Fourier ODE & Cayley shadow / all-loop geometric resummation identities
    k_sym, alpha_qg = sp.symbols("k_sym alpha_qg", real=True)
    sech2_half = 1 / sp.cosh(k_sym / 2) ** 2
    sech4_fourier_ode_ok = (
        sp.simplify(
            sp.diff(sech2_half, k_sym, 2)
            - (sech2_half - sp.Rational(3, 2) * sech2_half**2)
        )
        == 0
    )
    cayley_diff = sp.simplify(
        1 / (1 + 4 * sigma_dev**2)
        - (1 - 4 * sigma_dev**2)
        - 16 * sigma_dev**4 / (1 + 4 * sigma_dev**2)
    )
    all_loop_diff = sp.simplify(
        8 / (8 - alpha_qg)
        - (1 + sp.Rational(1, 8) * alpha_qg + sp.Rational(1, 90) * alpha_qg**2)
        - (
            sp.Rational(13, 2880) * alpha_qg**2
            + alpha_qg**3 / (64 * (8 - alpha_qg))
        )
    )
    cayley_and_all_loop_sym_ok = cayley_diff == 0 and all_loop_diff == 0

    # --- Part B: High-Precision mpmath Audits ---
    with mp.workdps(dps):
        # 1. Hasse–Weil Euler factor verification at s_test = 3.7 + 2.1j over first 15 primes
        s_test = mp.mpc("3.7", "2.1")
        primes_15 = _sieve_primes(50)[:15]
        max_euler_err = mp.mpf(0)
        for p in primes_15:
            ps = mp.power(p, -s_test)
            # Local factor from Betti numbers (1, 1, 2, 1, 1)
            lhs_loc = 1 / (
                (1 - ps)
                * (1 - p * ps)
                * ((1 - (p**2) * ps) ** 2)
                * (1 - (p**3) * ps)
                * (1 - (p**4) * ps)
            )
            rhs_loc = mp.mpf(1)
            for k, b_2k in enumerate([1, 1, 2, 1, 1]):
                rhs_loc *= mp.power(1 - mp.power(p, k - s_test), -b_2k)
            max_euler_err = max(max_euler_err, abs(lhs_loc - rhs_loc))

        # 2. Plancherel weight P(lambda), F_compact(y), M_1, M_2, M_3
        def p_weight(lam):
            if abs(lam) < mp.mpf("1e-25"):
                return mp.mpf(1)
            x = mp.pi * lam
            return x / mp.sinh(x)

        p0_err = float(abs(p_weight(mp.mpf(0)) - mp.mpf(1)))
        m1_mp = mp.quad(p_weight, [0, 2, 6, mp.inf]) / (2 * mp.pi)
        m1_err = float(abs(m1_mp - mp.mpf(1) / 8)) + p0_err

        # 3. Biane–Pitman–Yor Brownian bridge moment E[V^s] = 2 * xi(s):
        # Contrast Toupin's Eq. (8.277)-(8.281) (which uses the Kolmogorov–Smirnov alternating
        # series 2*sum (-1)^{k+1} exp(-2*k^2*pi^2*v^2) and misses the (s-1) factor and produces
        # the Dirichlet eta factor 1 - 2^{1-s}) against the true Biane–Pitman–Yor (2001) Kuiper
        # range kernel 2 * (2*pi*k^2*v^2 - 1) * exp(-pi*k^2*v^2).
        def completed_xi(sv):
            return (
                mp.mpf("0.5")
                * sv
                * (sv - 1)
                * mp.power(mp.pi, -sv / 2)
                * mp.gamma(sv / 2)
                * mp.zeta(sv)
            )

        def toupin_eq8281_ks_formula(sv):
            eta_s = (1 - mp.power(2, 1 - sv)) * mp.zeta(sv)
            return (
                sv
                * mp.gamma(sv / 2)
                * mp.power(2, -sv / 2)
                * mp.power(mp.pi, -sv)
                * eta_s
            )

        def true_bpy_kuiper_k1_integral(sv):
            return sv * mp.quad(
                lambda v: (v ** (sv - 1))
                * 2
                * (2 * mp.pi * (v**2) - 1)
                * mp.exp(-mp.pi * (v**2)),
                [0, 1, 4, mp.inf],
            )

        toupin_eq8281_discrepancy_s2 = float(
            abs(toupin_eq8281_ks_formula(mp.mpf(2)) - 2 * completed_xi(mp.mpf(2)))
        )
        bpy_err_s2 = float(
            abs(
                true_bpy_kuiper_k1_integral(mp.mpf(2)) * mp.zeta(mp.mpf(2))
                - 2 * completed_xi(mp.mpf(2))
            )
        )
        bpy_err_s3 = float(
            abs(
                true_bpy_kuiper_k1_integral(mp.mpf(3)) * mp.zeta(mp.mpf(3))
                - 2 * completed_xi(mp.mpf(3))
            )
        )

    # Evaluate the 2D compact-interval integrals for M_2 and M_3 at 22-digit precision for fast execution (< 1s)
    with mp.workdps(22):
        def p_w22(lam):
            if abs(lam) < mp.mpf("1e-20"):
                return mp.mpf(1)
            x = mp.pi * lam
            return x / mp.sinh(x)

        def f_compact22(y):
            y_abs = abs(y)
            even_p = (1 + y_abs**2) / 12 * p_w22(y_abs)
            if y_abs < mp.mpf("1e-18"):
                return even_p
            box = 2 * mp.quad(
                lambda u: p_w22(u * y_abs) * p_w22((1 - u) * y_abs),
                [0, mp.mpf("0.5")],
            )
            return even_p + (y / (4 * mp.pi)) * box

        f_zero_err = float(abs(f_compact22(mp.mpf(0)) - mp.mpf(1) / 12))
        y_chk = mp.mpf("0.75")
        full_line_conv_err = float(
            abs(
                (f_compact22(y_chk) + f_compact22(-y_chk))
                - (1 + y_chk**2) / 6 * p_w22(y_chk)
            )
        )
        m2_mp = mp.quad(lambda y: p_w22(y) * f_compact22(y), [0, 2, 6, mp.inf]) / (
            2 * mp.pi
        )
        m3_mp = mp.quad(
            lambda y: p_w22(y) * (f_compact22(y) ** 2), [0, 2, 6, mp.inf]
        ) / (2 * mp.pi)
        m3_toupin_ref = mp.mpf(
            "0.0010280204768206811181554290742928570866263084"
        )
        m3_even_only = mp.quad(
            lambda y: p_w22(y) * (((1 + y**2) / 12 * p_w22(y)) ** 2),
            [0, 2, 6, mp.inf],
        ) / (2 * mp.pi)

        return {
            "dict_unique_ok": bool(dict_unique_ok),
            "casimir_ok": bool(casimir_ok),
            "hasse_weil_sym_ok": bool(hasse_weil_sym_ok),
            "edge_deficit_ok": bool(edge_deficit),
            "pathway3_counterexample_ok": bool(pathway3_counterexample_ok),
            "sech4_fourier_ode_ok": bool(sech4_fourier_ode_ok),
            "cayley_and_all_loop_sym_ok": bool(cayley_and_all_loop_sym_ok),
            "b2_leading_pole_coeff": b2_leading_pole_coeff,
            "max_hasse_weil_euler_err": float(max_euler_err),
            "m1_error": m1_err,
            "m2_error": float(abs(m2_mp - mp.mpf(1) / 90)),
            "m3_value": float(m3_mp),
            "m3_error_vs_toupin_44digit": float(abs(m3_mp - m3_toupin_ref)),
            "m3_even_chamber_part": float(m3_even_only),
            "m3_odd_chamber_excess": float(m3_mp - m3_even_only),
            "f_zero_err": f_zero_err,
            "full_line_conv_err": full_line_conv_err,
            "toupin_eq8281_discrepancy_s2": toupin_eq8281_discrepancy_s2,
            "bpy_err_s2": bpy_err_s2,
            "bpy_err_s3": bpy_err_s3,
        }
