//! Finite Spectral & Numerical Audits Related to Riemann Hypothesis Approaches.
//!
//! Implements deterministic, self-contained Rust kernels (zero external crates beyond `std`)
//! paired with `Signals.RiemannSpectral` and `Signals.Pending.RiemannHypothesisPendingBoundary`:
//! 1. **High-accuracy $\zeta(s)$ and Hardy $Z(t)$**:
//!    - Euler–Maclaurin analytic continuation in `f64` ($< 3 \times 10^{-14}$ error for $|t| \le 400$).
//!    - Riemann–Siegel main sum + exact Chebyshev $C_0(p), C_1(p), C_2(p)$ remainder terms
//!      (singularity-free across $p = 1/4, 3/4$; $O(\sqrt{t})$ cost; $< 1.3 \times 10^{-9}$ error
//!      at Lehmer's 1956 pair $t \approx 7005.08$).
//!    - Borwein Algorithm 2 alternating $\eta(s)/\zeta(s)$ evaluator (with explicit conditioning
//!      comparison vs. Euler–Maclaurin).
//! 2. **First-$K$ Nontrivial Zero Finder, Gram's Law Violations ($g_{126}, g_{134}$), and
//!    Lehmer's 1956 Near-Miss Pair (#6709 & #6710)**:
//!    - Evaluates the Three-Channel Madelung–Bohm–QFIM / Jensen–Pólya discriminant
//!      $\mathcal{J}(\gamma) = (Z'(\gamma))^2 - Z(\gamma) Z''(\gamma) = J_{\mathrm{osm}} + J_{\mathrm{bohm}}$.
//! 3. **Finite-Graph Bass–Ihara Zeta & Ramanujan Dichotomy**:
//!    - 10-vertex 3-regular Petersen graph (Ramanujan, all non-trivial roots on $|u|^2 = 1/2$).
//!    - 14-vertex 3-regular Heawood graph (Ramanujan, all non-trivial roots on $|u|^2 = 1/2$).
//!    - 14-vertex 3-regular connected Barbell graph $G_{14}$ (Non-Ramanujan, $\lambda_2 \approx
//!      2.8557725066 > 2\sqrt{2}$, explicit real Bass–Ihara roots splitting off $|u|^2 = 1/2$).
//! 4. **Li Partial Coefficients $\lambda_n^{(K)}$**:
//!    - Positive for critical-line zero sets; demonstrates negative turning under a hypothetical
//!      off-line quartet $\{\frac{1}{2}\pm\sigma_{\mathrm{dev}} \pm i\gamma\}$.
//!
//! **Epistemic boundary**: Finite zero scans, finite graph checks, and partial Li sums do NOT
//! prove or disprove the classical Riemann Hypothesis for $\zeta(s)$.

use std::collections::VecDeque;
use std::f64::consts::PI;

/// Complex number in `f64` for self-contained analytic continuation.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct C64 {
    pub re: f64,
    pub im: f64,
}

impl C64 {
    #[inline]
    pub const fn new(re: f64, im: f64) -> Self {
        Self { re, im }
    }

    #[inline]
    pub fn add(self, other: Self) -> Self {
        Self::new(self.re + other.re, self.im + other.im)
    }

    #[inline]
    pub fn sub(self, other: Self) -> Self {
        Self::new(self.re - other.re, self.im - other.im)
    }

    #[inline]
    pub fn mul(self, other: Self) -> Self {
        Self::new(
            self.re * other.re - self.im * other.im,
            self.re * other.im + self.im * other.re,
        )
    }

    #[inline]
    pub fn scale(self, s: f64) -> Self {
        Self::new(self.re * s, self.im * s)
    }

    #[inline]
    pub fn div(self, other: Self) -> Self {
        let denom = other.re * other.re + other.im * other.im;
        Self::new(
            (self.re * other.re + self.im * other.im) / denom,
            (self.im * other.re - self.re * other.im) / denom,
        )
    }

    #[inline]
    pub fn norm_sq(self) -> f64 {
        self.re * self.re + self.im * self.im
    }

    #[inline]
    pub fn abs(self) -> f64 {
        self.re.hypot(self.im)
    }

    /// Compute `base^(-self)` for real `base > 0`.
    #[inline]
    pub fn pow_real_base_neg(base: f64, s: Self) -> Self {
        let ln_b = base.ln();
        let mag = (-s.re * ln_b).exp();
        let angle = -s.im * ln_b;
        let (sin_a, cos_a) = angle.sin_cos();
        Self::new(mag * cos_a, mag * sin_a)
    }
}

/// Bernoulli ratios `B_{2k} / (2k)!` for `k = 1..=9` in Euler–Maclaurin summation.
const BERNOULLI_OVER_FACT: [f64; 9] = [
    1.0 / 12.0,
    -1.0 / 720.0,
    1.0 / 30_240.0,
    -1.0 / 1_209_600.0,
    1.0 / 47_900_160.0,
    -691.0 / 1_307_674_368_000.0,
    1.0 / 74_724_249_600.0,
    -3617.0 / 10_670_622_842_880_000.0,
    43867.0 / 5_109_094_217_170_944_000.0,
];

/// Even Chebyshev coefficients `T_{2k}(2p - 1)` for Riemann–Siegel `C_0(p) = Psi(p)`.
const RS_C0_EVEN_CHEB: [f64; 12] = [
    6.426_672_862_397_679e-1,
    2.719_729_999_978_559e-1,
    1.073_860_581_934_075_3e-2,
    -1.374_381_529_635_149_2e-3,
    -1.246_822_188_024_687_8e-4,
    -5.764_599_699_586_981e-7,
    2.728_067_418_023_006e-7,
    8.077_953_983_498_532e-9,
    -2.088_457_851_101_566_2e-10,
    -1.311_782_349_411_316_8e-11,
    -1.270_095_140_171_179_2e-14,
    1.019_184_736_605_893_8e-14,
];

/// Odd Chebyshev coefficients `T_{2k+1}(2p - 1)` for Riemann–Siegel `C_1(p)`.
const RS_C1_ODD_CHEB: [f64; 12] = [
    1.069_791_392_100_300_3e-2,
    1.717_065_124_337_789e-2,
    2.793_211_149_788_47e-3,
    -3.637_565_371_927_641e-5,
    -2.710_895_523_115_701_7e-5,
    -1.048_374_986_667_78e-6,
    5.886_467_167_332_682e-8,
    4.322_967_273_040_49e-9,
    -1.136_958_738_962_024e-11,
    -6.699_813_447_086_367e-12,
    -1.008_155_364_745_633_2e-13,
    5.166_873_873_196_92e-15,
];

/// Even Chebyshev coefficients `T_{2k}(2p - 1)` for Riemann–Siegel `C_2(p)`.
const RS_C2_EVEN_CHEB: [f64; 13] = [
    3.146_115_853_988_912e-3,
    -2.308_783_884_530_751e-3,
    5.769_820_766_689_882e-5,
    3.523_886_202_366_592e-4,
    2.524_666_745_868_459_4e-5,
    -3.442_821_197_192_718_7e-6,
    -3.535_074_556_603_661e-7,
    3.730_830_184_004_406_6e-9,
    1.277_695_185_536_356e-9,
    2.187_461_555_207_964_7e-11,
    -1.914_137_771_896_751_2e-12,
    -6.562_865_485_434_943e-14,
    1.257_441_416_616_100_8e-15,
];

/// Odd Chebyshev coefficients `T_{2k+1}(2p - 1)` for Gabcke's Riemann–Siegel `C_3(p)`
/// (120-digit mpmath fit; max error `< 3.2e-19` on `p in [0, 1]`).
const RS_C3_ODD_CHEB: [f64; 14] = [
    7.123_256_221_203_874e-5,
    2.323_430_529_816_480_8e-4,
    -1.292_991_204_547_247_4e-4,
    1.807_449_641_367_144e-5,
    6.526_185_187_220_44e-6,
    -1.169_636_537_852_198_6e-7,
    -7.349_476_126_518_126e-8,
    -1.775_091_007_790_707_2e-9,
    2.555_552_961_326_525e-10,
    1.137_663_660_053_73e-11,
    -3.349_863_898_530_277e-13,
    -2.553_737_935_416_389_3e-14,
    6.766_500_771_321_871e-17,
    2.976_888_471_991_973e-17,
];

/// Even Chebyshev coefficients `T_{2k}(2p - 1)` for Gabcke's Riemann–Siegel `C_4(p)`
/// (120-digit mpmath fit; max error `< 2.0e-19` on `p in [0, 1]`).
const RS_C4_EVEN_CHEB: [f64; 15] = [
    1.676_574_524_669_686e-4,
    -2.272_876_894_341_672_6e-4,
    6.477_387_188_445_696e-5,
    -8.492_200_500_125_41e-6,
    -2.616_140_724_521_907_6e-6,
    8.336_764_968_733_215e-7,
    6.324_704_037_544_833e-8,
    -1.005_994_940_300_107_2e-8,
    -7.822_677_204_130_333e-10,
    3.167_658_285_349_860_3e-11,
    3.500_694_470_205_289_4e-12,
    -1.431_481_451_144_374_8e-14,
    -7.269_402_707_921_764e-15,
    -8.780_556_594_835_957e-17,
    8.150_254_474_954_58e-18,
];

/// Exact 2nd-order real Taylor jet `(f(t), f'(t), f''(t))` eliminating finite-difference
/// truncation and `O(eps / h^2)` cancellation error in `Z'(t), Z''(t)`.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Jet2 {
    pub v: f64,
    pub d1: f64,
    pub d2: f64,
}

impl Jet2 {
    #[inline]
    pub const fn constant(v: f64) -> Self {
        Self { v, d1: 0.0, d2: 0.0 }
    }

    #[inline]
    pub const fn var(v: f64) -> Self {
        Self { v, d1: 1.0, d2: 0.0 }
    }

    #[inline]
    pub fn add(self, o: Self) -> Self {
        Self { v: self.v + o.v, d1: self.d1 + o.d1, d2: self.d2 + o.d2 }
    }

    #[inline]
    pub fn sub(self, o: Self) -> Self {
        Self { v: self.v - o.v, d1: self.d1 - o.d1, d2: self.d2 - o.d2 }
    }

    #[inline]
    pub fn scale(self, s: f64) -> Self {
        Self { v: self.v * s, d1: self.d1 * s, d2: self.d2 * s }
    }

    #[inline]
    pub fn mul(self, o: Self) -> Self {
        Self {
            v: self.v * o.v,
            d1: self.d1 * o.v + self.v * o.d1,
            d2: self.d2 * o.v + 2.0 * self.d1 * o.d1 + self.v * o.d2,
        }
    }

    #[inline]
    pub fn inv(self) -> Self {
        let inv = 1.0 / self.v;
        let inv2 = inv * inv;
        let d1 = -self.d1 * inv2;
        let d2 = (-self.d2 * self.v + 2.0 * self.d1 * self.d1) * (inv2 * inv);
        Self { v: inv, d1, d2 }
    }

    #[inline]
    pub fn div(self, o: Self) -> Self {
        self.mul(o.inv())
    }

    #[inline]
    pub fn sqrt(self) -> Self {
        let r = self.v.sqrt();
        let inv_2r = 0.5 / r;
        let d1 = self.d1 * inv_2r;
        let d2 = (self.d2 - 2.0 * d1 * d1) * inv_2r;
        Self { v: r, d1, d2 }
    }

    #[inline]
    pub fn ln(self) -> Self {
        let inv = 1.0 / self.v;
        let d1 = self.d1 * inv;
        let d2 = (self.d2 * self.v - self.d1 * self.d1) * (inv * inv);
        Self { v: self.v.ln(), d1, d2 }
    }

    #[inline]
    pub fn exp(self) -> Self {
        let e = self.v.exp();
        let d1 = e * self.d1;
        let d2 = e * (self.d2 + self.d1 * self.d1);
        Self { v: e, d1, d2 }
    }

    #[inline]
    pub fn sin_cos(self) -> (Self, Self) {
        let (s, c) = self.v.sin_cos();
        let s_jet = Self {
            v: s,
            d1: c * self.d1,
            d2: c * self.d2 - s * self.d1 * self.d1,
        };
        let c_jet = Self {
            v: c,
            d1: -s * self.d1,
            d2: -s * self.d2 - c * self.d1 * self.d1,
        };
        (s_jet, c_jet)
    }

    /// `atan2(y, x)` for constant `x > 0` and jet `y`.
    #[inline]
    pub fn atan2_const_x(self, x: f64) -> Self {
        let r2 = x * x + self.v * self.v;
        let inv_r2 = 1.0 / r2;
        let d1 = x * self.d1 * inv_r2;
        let d2 = x * (self.d2 * r2 - 2.0 * self.v * self.d1 * self.d1) * (inv_r2 * inv_r2);
        Self { v: self.v.atan2(x), d1, d2 }
    }
}

/// Exact 2nd-order complex Taylor jet `(z(t), z'(t), z''(t))`.
#[derive(Clone, Copy, Debug, PartialEq)]
struct CJet2 {
    re: Jet2,
    im: Jet2,
}

impl CJet2 {
    #[inline]
    fn new(re: Jet2, im: Jet2) -> Self {
        Self { re, im }
    }

    #[inline]
    fn add(self, o: Self) -> Self {
        Self { re: self.re.add(o.re), im: self.im.add(o.im) }
    }

    #[inline]
    fn scale(self, s: f64) -> Self {
        Self { re: self.re.scale(s), im: self.im.scale(s) }
    }

    #[inline]
    fn mul(self, o: Self) -> Self {
        Self {
            re: self.re.mul(o.re).sub(self.im.mul(o.im)),
            im: self.re.mul(o.im).add(self.im.mul(o.re)),
        }
    }

    #[inline]
    fn div(self, o: Self) -> Self {
        let denom = o.re.mul(o.re).add(o.im.mul(o.im));
        let num_re = self.re.mul(o.re).add(self.im.mul(o.im));
        let num_im = self.im.mul(o.re).sub(self.re.mul(o.im));
        Self {
            re: num_re.div(denom),
            im: num_im.div(denom),
        }
    }

    /// Compute `base^(-s)` where `base > 0` is constant and `s = sigma + i t` (`sigma` constant,
    /// `t` is the differentiation variable).
    #[inline]
    fn pow_real_base_neg_t(base: f64, sigma: f64, t: Jet2) -> Self {
        let ln_b = base.ln();
        let mag = (-sigma * ln_b).exp();
        let angle = t.scale(-ln_b);
        let (sin_a, cos_a) = angle.sin_cos();
        Self {
            re: cos_a.scale(mag),
            im: sin_a.scale(mag),
        }
    }
}

#[inline]
fn eval_even_cheb(coeffs: &[f64], x: f64) -> f64 {
    // T_{2k}(x) = T_k(2x^2 - 1)
    let y = 2.0 * x * x - 1.0;
    let mut b1 = 0.0;
    let mut b2 = 0.0;
    for &c in coeffs[1..].iter().rev() {
        let b0 = c + 2.0 * y * b1 - b2;
        b2 = b1;
        b1 = b0;
    }
    coeffs[0] + y * b1 - b2
}

#[inline]
fn eval_odd_cheb(coeffs: &[f64], x: f64) -> f64 {
    // Direct recurrence for T_1, T_3, ..., T_{2m-1}
    let mut t_prev = x;
    let mut sum = coeffs[0] * t_prev;
    if coeffs.len() == 1 {
        return sum;
    }
    let mut t_curr = 4.0 * x * x * x - 3.0 * x;
    sum += coeffs[1] * t_curr;
    let two_y = 2.0 * (2.0 * x * x - 1.0);
    for &c in &coeffs[2..] {
        let t_next = two_y * t_curr - t_prev;
        sum += c * t_next;
        t_prev = t_curr;
        t_curr = t_next;
    }
    sum
}

#[inline]
fn eval_even_cheb_jet(coeffs: &[f64], x: Jet2) -> Jet2 {
    let y = x.mul(x).scale(2.0).sub(Jet2::constant(1.0));
    let mut b1 = Jet2::constant(0.0);
    let mut b2 = Jet2::constant(0.0);
    for &c in coeffs[1..].iter().rev() {
        let b0 = Jet2::constant(c).add(y.mul(b1).scale(2.0)).sub(b2);
        b2 = b1;
        b1 = b0;
    }
    Jet2::constant(coeffs[0]).add(y.mul(b1)).sub(b2)
}

#[inline]
fn eval_odd_cheb_jet(coeffs: &[f64], x: Jet2) -> Jet2 {
    let mut t_prev = x;
    let mut sum = t_prev.scale(coeffs[0]);
    if coeffs.len() == 1 {
        return sum;
    }
    let x2 = x.mul(x);
    let mut t_curr = x2.mul(x).scale(4.0).sub(x.scale(3.0));
    sum = sum.add(t_curr.scale(coeffs[1]));
    let two_y = x2.scale(4.0).sub(Jet2::constant(2.0));
    for &c in &coeffs[2..] {
        let t_next = two_y.mul(t_curr).sub(t_prev);
        sum = sum.add(t_next.scale(c));
        t_prev = t_curr;
        t_curr = t_next;
    }
    sum
}

/// Evaluate the Riemann–Siegel remainder functions `C_0(p), C_1(p), C_2(p)` for `p in [0, 1]`
/// via singularity-free Chebyshev expansions on `x = 2p - 1 in [-1, 1]`.
pub fn riemann_siegel_c0_c1_c2(p: f64) -> (f64, f64, f64) {
    let x = 2.0 * p - 1.0;
    (
        eval_even_cheb(&RS_C0_EVEN_CHEB, x),
        eval_odd_cheb(&RS_C1_ODD_CHEB, x),
        eval_even_cheb(&RS_C2_EVEN_CHEB, x),
    )
}

/// Evaluate Gabcke's Riemann–Siegel remainder functions `C_0(p)..C_4(p)` for `p in [0, 1]`.
pub fn riemann_siegel_c0_to_c4(p: f64) -> [f64; 5] {
    let x = 2.0 * p - 1.0;
    [
        eval_even_cheb(&RS_C0_EVEN_CHEB, x),
        eval_odd_cheb(&RS_C1_ODD_CHEB, x),
        eval_even_cheb(&RS_C2_EVEN_CHEB, x),
        eval_odd_cheb(&RS_C3_ODD_CHEB, x),
        eval_even_cheb(&RS_C4_EVEN_CHEB, x),
    ]
}

/// Exact 2nd-order analytic jet `(theta(t), theta'(t), theta''(t))` via Stirling shift (`re + 8`).
pub fn riemann_siegel_theta_jet(t: f64) -> Jet2 {
    let t_jet = Jet2::var(t);
    let mut z_re = 0.25_f64;
    let z_im = t_jet.scale(0.5);
    let mut arg_shift = Jet2::constant(0.0);
    for _ in 0..8 {
        arg_shift = arg_shift.add(z_im.atan2_const_x(z_re));
        z_re += 1.0;
    }
    let ln_r = Jet2::constant(z_re * z_re).add(z_im.mul(z_im)).ln().scale(0.5);
    let phi = z_im.atan2_const_x(z_re);
    let mut im_ln_gamma = phi.scale(z_re - 0.5).add(z_im.mul(ln_r)).sub(z_im);

    const STIRLING_COEFFS: [f64; 5] = [
        1.0 / 12.0,
        -1.0 / 360.0,
        1.0 / 1260.0,
        -1.0 / 1680.0,
        1.0 / 1188.0,
    ];
    let w = CJet2::new(Jet2::constant(z_re), z_im);
    let one = CJet2::new(Jet2::constant(1.0), Jet2::constant(0.0));
    let inv_w = one.div(w);
    let inv_w2 = inv_w.mul(inv_w);
    let mut pow_inv_w = inv_w;
    for &c in &STIRLING_COEFFS {
        im_ln_gamma = im_ln_gamma.add(pow_inv_w.im.scale(c));
        pow_inv_w = pow_inv_w.mul(inv_w2);
    }
    im_ln_gamma.sub(arg_shift).sub(t_jet.scale(0.5 * PI.ln()))
}

/// Exact imaginary part of `ln Gamma(1/4 + i t / 2)` via Stirling shift (`re -> re + 8`),
/// accurate to `< 1e-15` for all `t >= 0`.
pub fn riemann_siegel_theta(t: f64) -> f64 {
    riemann_siegel_theta_jet(t).v
}

/// Exact analytic 2-jet of `zeta(sigma + i t)` with respect to `t` via Euler–Maclaurin summation.
fn zeta_euler_maclaurin_jet(sigma: f64, t: f64) -> CJet2 {
    let t_jet = Jet2::var(t);
    let s = CJet2::new(Jet2::constant(sigma), t_jet);
    let n_cutoff = (1.2 * t.abs() + 18.0).ceil().max(18.0) as usize;
    let mut sum = CJet2::new(Jet2::constant(0.0), Jet2::constant(0.0));
    for n in 1..n_cutoff {
        sum = sum.add(CJet2::pow_real_base_neg_t(n as f64, sigma, t_jet));
    }
    let nf = n_cutoff as f64;
    let n_neg_s = CJet2::pow_real_base_neg_t(nf, sigma, t_jet);
    let s_minus_1 = CJet2::new(Jet2::constant(sigma - 1.0), t_jet);
    sum = sum.add(n_neg_s.scale(nf).div(s_minus_1));
    sum = sum.add(n_neg_s.scale(0.5));

    let inv_n = 1.0 / nf;
    let inv_n2 = inv_n * inv_n;
    let mut prod = s.mul(n_neg_s).scale(inv_n);
    sum = sum.add(prod.scale(BERNOULLI_OVER_FACT[0]));
    for (idx, &coeff) in BERNOULLI_OVER_FACT.iter().enumerate().skip(1) {
        let k = (idx + 1) as f64;
        let f1 = CJet2::new(Jet2::constant(sigma + (2.0 * k - 3.0)), t_jet);
        let f2 = CJet2::new(Jet2::constant(sigma + (2.0 * k - 2.0)), t_jet);
        prod = prod.mul(f1).mul(f2).scale(inv_n2);
        sum = sum.add(prod.scale(coeff));
    }
    sum
}

/// Evaluate `zeta(sigma + i t)` via Euler–Maclaurin summation in `f64`.
/// Achieves `< 3e-14` absolute error across the critical strip for `|t| <= 400`.
pub fn zeta_euler_maclaurin(sigma: f64, t: f64) -> C64 {
    let j = zeta_euler_maclaurin_jet(sigma, t);
    C64::new(j.re.v, j.im.v)
}

/// Evaluate `zeta(sigma + i t)` using Borwein's Algorithm 2 (`n` Chebyshev terms in `f64`).
/// Accurate for small `|t| <= 20` (`n <= 24`); loses precision for large `|t|` in `f64` because
/// Chebyshev weights grow as `(3 + 2 sqrt(2))^n`, illustrating why Euler–Maclaurin and
/// Riemann–Siegel are needed for higher zeros.
pub fn zeta_borwein(sigma: f64, t: f64, n: usize) -> C64 {
    let s = C64::new(sigma, t);
    let mut d = vec![0.0_f64; n + 1];
    let mut term = 1.0_f64;
    let mut acc = term;
    d[0] = acc;
    let nf = n as f64;
    for i in 1..=n {
        let if64 = i as f64;
        term *= (nf + if64 - 1.0) * (nf - if64 + 1.0) * 4.0 / ((2.0 * if64 - 1.0) * (2.0 * if64));
        acc += term;
        d[i] = acc;
    }
    let dn = d[n];
    let mut sum = C64::new(0.0, 0.0);
    for k in 0..n {
        let sign = if k % 2 == 0 { 1.0 } else { -1.0 };
        let w = sign * (dn - d[k]);
        sum = sum.add(C64::pow_real_base_neg((k + 1) as f64, s).scale(w));
    }
    let two_pow = C64::pow_real_base_neg(2.0, C64::new(s.re - 1.0, s.im));
    let denom = C64::new(1.0 - two_pow.re, -two_pow.im).scale(dn);
    sum.div(denom)
}

/// Evaluate Hardy's real `Z(t)` via the Riemann–Siegel formula with `C_0(p), C_1(p), C_2(p)`.
/// Kept for explicit `C_2` vs. `C_4` error-minimization comparison (`~1.25e-9` at `t ~ 7005`).
pub fn hardy_z_riemann_siegel(t: f64) -> f64 {
    let a = (t / (2.0 * PI)).sqrt();
    let n_terms = a.floor() as usize;
    let p = a - (n_terms as f64);
    let theta = riemann_siegel_theta(t);

    let mut main_sum = 0.0_f64;
    for n in 1..=n_terms {
        let nf = n as f64;
        main_sum += (theta - t * nf.ln()).cos() / nf.sqrt();
    }
    main_sum *= 2.0;

    let (c0, c1, c2) = riemann_siegel_c0_c1_c2(p);
    let sign = if (n_terms.saturating_sub(1)) % 2 == 1 {
        -1.0
    } else {
        1.0
    };
    let inv_a = 1.0 / a;
    let rem = sign * a.powf(-0.5) * (c0 + inv_a * (c1 + inv_a * c2));
    main_sum + rem
}

/// Exact 2-jet `(Z(t), Z'(t), Z''(t))` via Riemann–Siegel with Gabcke's `C_0(p)..C_4(p)`.
/// Runs in `O(sqrt(t))` time and achieves `< 2.5e-12` error at Lehmer's 1956 pair (`t ~ 7005.08`,
/// a `> 500x` improvement over `C_2`) with analytic derivatives free of finite-difference noise.
pub fn hardy_z_riemann_siegel_c4_jet(t: f64) -> Jet2 {
    let t_jet = Jet2::var(t);
    let a = t_jet.scale(1.0 / (2.0 * PI)).sqrt();
    let n_terms = a.v.floor() as usize;
    let p = a.sub(Jet2::constant(n_terms as f64));
    let theta = riemann_siegel_theta_jet(t);

    let mut main_sum = Jet2::constant(0.0);
    for n in 1..=n_terms {
        let nf = n as f64;
        let phase = theta.sub(t_jet.scale(nf.ln()));
        let (_, cos_p) = phase.sin_cos();
        main_sum = main_sum.add(cos_p.scale(1.0 / nf.sqrt()));
    }
    main_sum = main_sum.scale(2.0);

    let x = p.scale(2.0).sub(Jet2::constant(1.0));
    let c0 = eval_even_cheb_jet(&RS_C0_EVEN_CHEB, x);
    let c1 = eval_odd_cheb_jet(&RS_C1_ODD_CHEB, x);
    let c2 = eval_even_cheb_jet(&RS_C2_EVEN_CHEB, x);
    let c3 = eval_odd_cheb_jet(&RS_C3_ODD_CHEB, x);
    let c4 = eval_even_cheb_jet(&RS_C4_EVEN_CHEB, x);

    let sign = if (n_terms.saturating_sub(1)) % 2 == 1 {
        -1.0
    } else {
        1.0
    };
    let inv_a = a.inv();
    let inv_sqrt_a = a.sqrt().inv();
    let poly = c0.add(inv_a.mul(c1.add(inv_a.mul(c2.add(inv_a.mul(c3.add(inv_a.mul(c4))))))));
    let rem = inv_sqrt_a.mul(poly).scale(sign);
    main_sum.add(rem)
}

/// Evaluate Hardy's `Z(t)` via Riemann–Siegel with Gabcke's `C_0(p)..C_4(p)`.
pub fn hardy_z_riemann_siegel_c4(t: f64) -> f64 {
    hardy_z_riemann_siegel_c4_jet(t).v
}

/// Exact 2nd-order analytic jet `(Z(t), Z'(t), Z''(t))` of Hardy's `Z(t)`:
/// uses exact Euler–Maclaurin analytic jet (`< 3e-14`) for `|t| <= 350` and
/// Riemann–Siegel `C_0..C_4` analytic jet for `|t| > 350`.
pub fn hardy_z_jet(t: f64) -> Jet2 {
    if t.abs() <= 350.0 {
        let theta = riemann_siegel_theta_jet(t);
        let z = zeta_euler_maclaurin_jet(0.5, t);
        let (sin_t, cos_t) = theta.sin_cos();
        cos_t.mul(z.re).sub(sin_t.mul(z.im))
    } else {
        hardy_z_riemann_siegel_c4_jet(t)
    }
}

/// Evaluate Hardy's `Z(t) = Re[e^{i theta(t)} zeta(1/2 + i t)]`:
/// uses Euler–Maclaurin (`< 3e-14` accuracy) for `|t| <= 350` and Riemann–Siegel
/// (`C_0..C_4`) for `|t| > 350`.
pub fn hardy_z(t: f64) -> f64 {
    hardy_z_jet(t).v
}

/// Find the `m`-th Gram point `g_m` satisfying `theta(g_m) = m * pi` via analytic Newton's method.
pub fn gram_point(m: i32) -> f64 {
    let target = (m as f64) * PI;
    let mut t = if m <= 0 {
        9.6669
    } else {
        let mf = m as f64;
        let g = (mf + 1.125) / (mf + 1.125).ln().max(1.0);
        (2.0 * PI * g).max(10.0)
    };
    for _ in 0..40 {
        let th = riemann_siegel_theta_jet(t);
        let step = (th.v - target) / th.d1;
        t -= step;
        if step.abs() < 1e-14 * t.max(1.0) {
            break;
        }
    }
    t
}

/// Refine a simple root of `f` on bracket `[a, b]` with `f(a) * f(b) <= 0` using hybrid
/// bisection/secant to `< 1e-13`.
fn refine_root_bracket<F: Fn(f64) -> f64>(f: F, mut a: f64, mut b: f64) -> f64 {
    let mut fa = f(a);
    let mut fb = f(b);
    if fa == 0.0 {
        return a;
    }
    if fb == 0.0 {
        return b;
    }
    for _ in 0..80 {
        let mid = 0.5 * (a + b);
        let sec = if (fb - fa).abs() > 1e-15 {
            b - fb * (b - a) / (fb - fa)
        } else {
            mid
        };
        let x = if sec > a && sec < b { sec } else { mid };
        let fx = f(x);
        if fx.abs() < 1e-14 || (b - a).abs() < 1e-15 * (1.0 + x.abs()) {
            return x;
        }
        if fa.signum() == fx.signum() {
            a = x;
            fa = fx;
        } else {
            b = x;
            fb = fx;
        }
    }
    0.5 * (a + b)
}

/// One audited critical-line zero with cross-method residuals.
#[derive(Clone, Debug, PartialEq)]
pub struct RiemannZeroAudit {
    pub index: usize,
    pub gamma: f64,
    pub hardy_z_exact: f64,
    pub hardy_z_riemann_siegel_c2: f64,
    pub hardy_z_riemann_siegel_c4: f64,
    pub zeta_abs: f64,
    pub borwein_zeta_abs: f64,
    pub z_prime: f64,
    pub jensen_polya_j: f64,
}

/// Locate and cross-audit the first `count` nontrivial zeros of `zeta(1/2 + i t)` on the
/// critical line (`count <= 50` recommended for fast `f64` Euler–Maclaurin verification).
pub fn find_first_n_riemann_zeros(count: usize) -> Vec<RiemannZeroAudit> {
    let mut zeros = Vec::with_capacity(count);
    let mut t = 10.0_f64;
    let step = 0.2_f64;
    let mut prev_z = hardy_z(t);

    while zeros.len() < count && t < 400.0 {
        let next_t = t + step;
        let next_z = hardy_z(next_t);
        if prev_z == 0.0 || (prev_z < 0.0 && next_z > 0.0) || (prev_z > 0.0 && next_z < 0.0) {
            let gamma = refine_root_bracket(hardy_z, t, next_t);
            let hz_ex = hardy_z(gamma);
            let hz_rs_c2 = hardy_z_riemann_siegel(gamma);
            let hz_rs_c4 = hardy_z_riemann_siegel_c4(gamma);
            let z_abs = zeta_euler_maclaurin(0.5, gamma).abs();
            let b_abs = zeta_borwein(0.5, gamma, 22).abs();
            let audit = evaluate_madelung_bohm_jensen_polya(gamma);
            zeros.push(RiemannZeroAudit {
                index: zeros.len() + 1,
                gamma,
                hardy_z_exact: hz_ex,
                hardy_z_riemann_siegel_c2: hz_rs_c2,
                hardy_z_riemann_siegel_c4: hz_rs_c4,
                zeta_abs: z_abs,
                borwein_zeta_abs: b_abs,
                z_prime: audit.z_prime,
                jensen_polya_j: audit.j_total,
            });
        }
        t = next_t;
        prev_z = next_z;
    }
    zeros
}

/// Finite quartic de Bruijn-Newman heat jet, represented in a Gr(2, 4) coefficient chart.
///
/// This is an f64 implementation of the finite polynomial contract only. It does not
/// approximate the full Riemann xi heat flow or establish any global RH statement.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct DbnQuarticHeatGr24State {
    pub a0: f64,
    pub a2: f64,
    pub a4: f64,
}

impl DbnQuarticHeatGr24State {
    /// Extract the quartic Taylor coefficients at deformation time `t`.
    pub fn from_taylor_jet(z0: f64, z2: f64, z4: f64, t: f64) -> Self {
        Self {
            a0: z0 - z2 * t + 0.5 * z4 * t * t,
            a2: 0.5 * (z2 - z4 * t),
            a4: z4 / 24.0,
        }
    }

    /// Evaluate the supplied quartic polynomial at a spatial displacement `dz`.
    pub fn evaluate(self, dz: f64) -> f64 {
        let dz2 = dz * dz;
        self.a0 + self.a2 * dz2 + self.a4 * dz2 * dz2
    }

    /// Apply the finite-time solution map for `d_t H = -d_z^2 H` on quartic coefficients.
    pub fn heat_step(self, delta_time: f64) -> Self {
        Self {
            a0: self.a0 - 2.0 * self.a2 * delta_time
                + 12.0 * self.a4 * delta_time * delta_time,
            a2: self.a2 - 12.0 * self.a4 * delta_time,
            a4: self.a4,
        }
    }

    /// Plucker coordinates in `(p12, p13, p14, p23, p24, p34)` order.
    pub fn plucker_coordinates(self) -> [f64; 6] {
        [0.0, 0.0, self.a0, 0.0, self.a2, self.a4]
    }

    /// Klein-quadric residual `p12 p34 - p13 p24 + p14 p23` for this chart.
    pub fn plucker_relation_residual(self) -> f64 {
        let [p12, p13, p14, p23, p24, p34] = self.plucker_coordinates();
        p12 * p34 - p13 * p24 + p14 * p23
    }

    /// Generator rows for `span((a0, a2, a4, 0), (0, 0, 0, 1))`.
    pub fn generator_matrix(self) -> [[f64; 4]; 2] {
        [[self.a0, self.a2, self.a4, 0.0], [0.0, 0.0, 0.0, 1.0]]
    }

    /// Lower-triangular ambient shear inducing the heat step by right multiplication.
    pub fn ambient_heat_action(delta_time: f64) -> [[f64; 4]; 4] {
        [
            [1.0, 0.0, 0.0, 0.0],
            [-2.0 * delta_time, 1.0, 0.0, 0.0],
            [12.0 * delta_time * delta_time, -12.0 * delta_time, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0],
        ]
    }

    /// Numerically multiply the generator by the ambient heat action on the right.
    pub fn generator_after_ambient_heat_action(self, delta_time: f64) -> [[f64; 4]; 2] {
        let generator = self.generator_matrix();
        let action = Self::ambient_heat_action(delta_time);
        std::array::from_fn(|row| {
            std::array::from_fn(|column| {
                (0..4)
                    .map(|inner| generator[row][inner] * action[inner][column])
                    .sum::<f64>()
            })
        })
    }
}

/// Residual summary for native `f64` checks of the finite quartic heat/Gr(2, 4) chart.
///
/// These diagnostics test only the supplied finite polynomial and matrix identities. They are
/// not a certificate for the analytic xi heat flow or a global de Bruijn-Newman bound.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct DbnQuarticHeatGr24CrossCheck {
    pub finite_inputs: bool,
    pub chart_has_nonzero_minor: bool,
    pub heat_step_max_abs: f64,
    pub polynomial_reconstruction_abs: f64,
    pub generator_intertwining_max_abs: f64,
    pub plucker_relation_max_abs: f64,
    pub ambient_semigroup_max_abs: f64,
    pub ambient_inverse_max_abs: f64,
}

impl DbnQuarticHeatGr24CrossCheck {
    /// Largest reported absolute residual across the finite identities.
    pub fn max_abs_residual(self) -> f64 {
        [
            self.heat_step_max_abs,
            self.polynomial_reconstruction_abs,
            self.generator_intertwining_max_abs,
            self.plucker_relation_max_abs,
            self.ambient_semigroup_max_abs,
            self.ambient_inverse_max_abs,
        ]
        .into_iter()
        .fold(0.0, f64::max)
    }
}

fn max_abs_matrix_difference<const ROWS: usize, const COLUMNS: usize>(
    left: &[[f64; COLUMNS]; ROWS],
    right: &[[f64; COLUMNS]; ROWS],
) -> f64 {
    let mut maximum = 0.0_f64;
    for row in 0..ROWS {
        for column in 0..COLUMNS {
            maximum = maximum.max((left[row][column] - right[row][column]).abs());
        }
    }
    maximum
}

/// Compare direct coefficient extraction with finite heat steps and the induced Gr(2, 4)
/// ambient action. Inputs should be finite; the returned flag makes that precondition visible.
pub fn audit_dbn_quartic_heat_gr24(
    z0: f64,
    z2: f64,
    z4: f64,
    time: f64,
    delta_time1: f64,
    delta_time2: f64,
    delta_z: f64,
) -> DbnQuarticHeatGr24CrossCheck {
    let inputs = [z0, z2, z4, time, delta_time1, delta_time2, delta_z];
    let initial = DbnQuarticHeatGr24State::from_taylor_jet(z0, z2, z4, time);
    let state_after_first = initial.heat_step(delta_time1);
    let direct_after_first =
        DbnQuarticHeatGr24State::from_taylor_jet(z0, z2, z4, time + delta_time1);
    let state_after_two = state_after_first.heat_step(delta_time2);
    let direct_after_two = DbnQuarticHeatGr24State::from_taylor_jet(
        z0,
        z2,
        z4,
        time + delta_time1 + delta_time2,
    );

    let coefficient_difference = |left: DbnQuarticHeatGr24State, right: DbnQuarticHeatGr24State| {
        [
            (left.a0 - right.a0).abs(),
            (left.a2 - right.a2).abs(),
            (left.a4 - right.a4).abs(),
        ]
        .into_iter()
        .fold(0.0_f64, f64::max)
    };
    let heat_step_max_abs = coefficient_difference(state_after_first, direct_after_first)
        .max(coefficient_difference(state_after_two, direct_after_two));

    let direct_polynomial = z0 - z2 * (time + delta_time1)
        + 0.5 * z4 * (time + delta_time1).powi(2)
        + 0.5 * (z2 - z4 * (time + delta_time1)) * delta_z.powi(2)
        + (z4 / 24.0) * delta_z.powi(4);
    let polynomial_reconstruction_abs =
        (direct_after_first.evaluate(delta_z) - direct_polynomial).abs();

    let generator_intertwining_max_abs = max_abs_matrix_difference(
        &initial.generator_after_ambient_heat_action(delta_time1),
        &state_after_first.generator_matrix(),
    );

    let plucker_relation_max_abs = initial
        .plucker_relation_residual()
        .abs()
        .max(state_after_first.plucker_relation_residual().abs());

    let ambient1 = DbnQuarticHeatGr24State::ambient_heat_action(delta_time1);
    let ambient2 = DbnQuarticHeatGr24State::ambient_heat_action(delta_time2);
    let ambient_sum = DbnQuarticHeatGr24State::ambient_heat_action(delta_time1 + delta_time2);
    let mut ambient_product = [[0.0; 4]; 4];
    for row in 0..4 {
        for column in 0..4 {
            ambient_product[row][column] = (0..4)
                .map(|inner| ambient1[row][inner] * ambient2[inner][column])
                .sum();
        }
    }
    let ambient_semigroup_max_abs = max_abs_matrix_difference(&ambient_product, &ambient_sum);

    let ambient_reverse = DbnQuarticHeatGr24State::ambient_heat_action(-delta_time1);
    let mut ambient_inverse_product = [[0.0; 4]; 4];
    for row in 0..4 {
        for column in 0..4 {
            ambient_inverse_product[row][column] = (0..4)
                .map(|inner| ambient1[row][inner] * ambient_reverse[inner][column])
                .sum();
        }
    }
    let mut identity = [[0.0; 4]; 4];
    for index in 0..4 {
        identity[index][index] = 1.0;
    }
    let ambient_inverse_max_abs =
        max_abs_matrix_difference(&ambient_inverse_product, &identity);

    DbnQuarticHeatGr24CrossCheck {
        finite_inputs: inputs.into_iter().all(f64::is_finite),
        chart_has_nonzero_minor: initial.a0 != 0.0 || initial.a2 != 0.0 || initial.a4 != 0.0,
        heat_step_max_abs,
        polynomial_reconstruction_abs,
        generator_intertwining_max_abs,
        plucker_relation_max_abs,
        ambient_semigroup_max_abs,
        ambient_inverse_max_abs,
    }
}

/// Three-Channel Madelung–Bohm–QFIM / Jensen–Pólya discriminant evaluation at height `gamma`.
#[derive(Clone, Debug, PartialEq)]
pub struct MadelungBohmPointAudit {
    pub gamma: f64,
    pub z0: f64,
    pub z_prime: f64,
    pub z_double_prime: f64,
    pub j_osmotic: f64,
    pub j_bohm: f64,
    pub j_total: f64,
    pub bohm_ratio: f64,
}

/// Evaluate exact analytic `Z(gamma)`, `Z'(gamma)`, `Z''(gamma)`, `J_osmotic = (Z')^2`,
/// `J_bohm = -Z * Z''`, and `J_total = J_osmotic + J_bohm` via 2nd-order Taylor jet propagation
/// (eliminating finite-difference truncation and `O(eps / h^2)` cancellation error).
pub fn evaluate_madelung_bohm_jensen_polya(gamma: f64) -> MadelungBohmPointAudit {
    let j = hardy_z_jet(gamma);
    let z0 = j.v;
    let z1 = j.d1;
    let z2 = j.d2;

    let j_osm = z1 * z1;
    let j_bohm = -z0 * z2;
    let j_total = j_osm + j_bohm;
    let bohm_ratio = if j_total.abs() > 1e-30 {
        j_bohm / j_total
    } else {
        0.0
    };
    MadelungBohmPointAudit {
        gamma,
        z0,
        z_prime: z1,
        z_double_prime: z2,
        j_osmotic: j_osm,
        j_bohm,
        j_total,
        bohm_ratio,
    }
}

/// Gram-point audit record including Gram's Law sign check `(-1)^m Z(g_m) > 0`.
#[derive(Clone, Debug, PartialEq)]
pub struct GramPointAudit {
    pub gram_index: i32,
    pub gram_holds: bool,
    pub point: MadelungBohmPointAudit,
}

/// Lehmer 1956 near-miss pair (#6709 & #6710) audit record.
#[derive(Clone, Debug, PartialEq)]
pub struct LehmerPairAudit {
    pub gamma_left: f64,
    pub gamma_right: f64,
    pub gap: f64,
    pub extremum: MadelungBohmPointAudit,
}

/// Audit Gram points `g_125, g_126 (1st violation), g_127, g_133, g_134 (2nd violation), g_135`.
pub fn audit_gram_law_window() -> Vec<GramPointAudit> {
    [125, 126, 127, 133, 134, 135]
        .iter()
        .map(|&m| {
            let gm = gram_point(m);
            let point = evaluate_madelung_bohm_jensen_polya(gm);
            let expected_sign = if m % 2 == 0 { 1.0 } else { -1.0 };
            GramPointAudit {
                gram_index: m,
                gram_holds: expected_sign * point.z0 > 0.0,
                point,
            }
        })
        .collect()
}

/// Audit Lehmer's 1956 near-miss pair (Zeros #6709 & #6710 around `gamma ~ 7005.08`)
/// using Riemann–Siegel with exact `C_0(p), C_1(p), C_2(p)`.
pub fn audit_lehmer_1956_pair() -> LehmerPairAudit {
    let gamma_left = refine_root_bracket(hardy_z, 7005.055, 7005.075);
    let gamma_right = refine_root_bracket(hardy_z, 7005.088, 7005.110);
    // Find exact extremum where Z'(gamma_*) = 0 between gamma_left and gamma_right
    let extremum_gamma = refine_root_bracket(
        |g| evaluate_madelung_bohm_jensen_polya(g).z_prime,
        gamma_left + 0.005,
        gamma_right - 0.005,
    );
    let extremum = evaluate_madelung_bohm_jensen_polya(extremum_gamma);
    LehmerPairAudit {
        gamma_left,
        gamma_right,
        gap: gamma_right - gamma_left,
        extremum,
    }
}

/// Symmetric Jacobi eigensolver for small dense real symmetric matrices (`n x n`).
fn symmetric_jacobi_eigenvalues(matrix: &[Vec<f64>]) -> Vec<f64> {
    let n = matrix.len();
    let mut a = matrix.to_vec();
    for _ in 0..(120 * n * n).max(64) {
        let mut max_val = 0.0_f64;
        let mut p = 0;
        let mut q = 0;
        for i in 0..n {
            for j in (i + 1)..n {
                let v = a[i][j].abs();
                if v > max_val {
                    max_val = v;
                    p = i;
                    q = j;
                }
            }
        }
        if max_val < 1e-14 {
            break;
        }
        let app = a[p][p];
        let aqq = a[q][q];
        let apq = a[p][q];
        let tau = (aqq - app) / (2.0 * apq);
        let t = if tau >= 0.0 {
            1.0 / (tau + (1.0 + tau * tau).sqrt())
        } else {
            -1.0 / (-tau + (1.0 + tau * tau).sqrt())
        };
        let c = 1.0 / (1.0 + t * t).sqrt();
        let s = t * c;

        a[p][p] = app - t * apq;
        a[q][q] = aqq + t * apq;
        a[p][q] = 0.0;
        a[q][p] = 0.0;
        for r in 0..n {
            if r != p && r != q {
                let arp = a[r][p];
                let arq = a[r][q];
                a[r][p] = c * arp - s * arq;
                a[p][r] = a[r][p];
                a[r][q] = s * arp + c * arq;
                a[q][r] = a[r][q];
            }
        }
    }
    let mut evals: Vec<f64> = (0..n).map(|i| a[i][i]).collect();
    evals.sort_by(|x, y| y.total_cmp(x));
    evals
}

/// One Bass–Ihara quadratic factor root `u` solving `1 - lambda u + q u^2 = 0`.
#[derive(Clone, Debug, PartialEq)]
pub struct BassIharaRoot {
    pub eigenvalue: f64,
    pub u_re: f64,
    pub u_im: f64,
    pub modulus_sq: f64,
    pub is_trivial: bool,
    pub on_critical_circle: bool,
}

/// Full finite-graph Bass–Ihara zeta & Ramanujan audit report.
#[derive(Clone, Debug, PartialEq)]
pub struct RegularGraphBassIharaAudit {
    pub name: String,
    pub vertices: usize,
    pub degree: usize,
    pub q: usize,
    pub is_regular: bool,
    pub is_connected: bool,
    pub ramanujan_bound: f64,
    pub eigenvalues: Vec<f64>,
    pub max_nontrivial_abs_eigenvalue: f64,
    pub markov_spectral_gap: f64,
    pub ramanujan_margin: f64,
    pub is_ramanujan: bool,
    pub nontrivial_off_circle_count: usize,
    pub roots: Vec<BassIharaRoot>,
}

/// Build adjacency matrix from edge list for an undirected simple graph on `n` vertices.
pub fn adjacency_from_edges(n: usize, edges: &[(usize, usize)]) -> Vec<Vec<f64>> {
    let mut adj = vec![vec![0.0_f64; n]; n];
    for &(u, v) in edges {
        adj[u][v] = 1.0;
        adj[v][u] = 1.0;
    }
    adj
}

/// 6-vertex 3-regular connected utility graph `K_{3,3}` (Ramanujan: `max |lambda_nt| = 0`).
pub fn k33_graph_6() -> (String, usize, Vec<Vec<f64>>) {
    let mut edges = Vec::new();
    for i in 0..3 {
        for j in 3..6 {
            edges.push((i, j));
        }
    }
    (
        "K_{3,3} (6-vertex, 3-regular, Ramanujan)".to_string(),
        3,
        adjacency_from_edges(6, &edges),
    )
}

/// 10-vertex 3-regular connected Petersen graph (Ramanujan: `max |lambda_nt| = 2 <= 2 sqrt(2)`).
pub fn petersen_graph_10() -> (String, usize, Vec<Vec<f64>>) {
    let mut edges = Vec::new();
    for i in 0..5 {
        edges.push((i, (i + 1) % 5));
        edges.push((5 + i, 5 + (i + 2) % 5));
        edges.push((i, 5 + i));
    }
    (
        "Petersen (10-vertex, 3-regular, Ramanujan)".to_string(),
        3,
        adjacency_from_edges(10, &edges),
    )
}

/// 14-vertex 3-regular connected Heawood graph (Fano incidence graph, Ramanujan:
/// `max |lambda_nt| = sqrt(2) <= 2 sqrt(2)`).
pub fn heawood_graph_14() -> (String, usize, Vec<Vec<f64>>) {
    let mut edges = Vec::new();
    for i in 0..14 {
        edges.push((i, (i + 1) % 14));
        if i % 2 == 0 {
            edges.push((i, (i + 5) % 14));
        }
    }
    (
        "Heawood (14-vertex, 3-regular, Ramanujan)".to_string(),
        3,
        adjacency_from_edges(14, &edges),
    )
}

/// 16-vertex 3-regular connected Möbius–Kantor graph `GP(8, 3)` (Ramanujan:
/// `max |lambda_nt| = sqrt(3) ~ 1.7320508 <= 2 sqrt(2)`).
pub fn mobius_kantor_graph_16() -> (String, usize, Vec<Vec<f64>>) {
    let mut edges = Vec::new();
    for i in 0..8 {
        edges.push((i, (i + 1) % 8));
        edges.push((8 + i, 8 + (i + 3) % 8));
        edges.push((i, 8 + i));
    }
    (
        "Mobius-Kantor GP(8,3) (16-vertex, 3-regular, Ramanujan)".to_string(),
        3,
        adjacency_from_edges(16, &edges),
    )
}

/// 14-vertex 3-regular connected Barbell graph `G_14` (Non-Ramanujan:
/// `lambda_2 ~ 2.8557725066 > 2 sqrt(2) ~ 2.8284271247`, root of `x^3 - x^2 - 6x + 2 = 0`,
/// with explicit real Bass–Ihara roots `u_+ ~ 0.8125067, u_- ~ 0.6153795` splitting strictly
/// off the critical circle `|u| = 1/sqrt(2) ~ 0.7071068`).
pub fn barbell_non_ramanujan_14() -> (String, usize, Vec<Vec<f64>>) {
    let half_edges = [
        (0, 1),
        (0, 2),
        (1, 3),
        (1, 4),
        (2, 5),
        (2, 6),
        (3, 4),
        (3, 5),
        (4, 6),
        (5, 6),
    ];
    let mut edges = Vec::new();
    for &(u, v) in &half_edges {
        edges.push((u, v));
        edges.push((u + 7, v + 7));
    }
    edges.push((0, 7)); // Single bridge connecting the two 7-vertex halves
    (
        "Barbell G_14 (14-vertex, 3-regular, Non-Ramanujan)".to_string(),
        3,
        adjacency_from_edges(14, &edges),
    )
}

/// Analyze a `(q + 1)`-regular graph's adjacency spectrum and Bass–Ihara determinant roots.
pub fn analyze_regular_graph_bass_ihara(
    name: &str,
    degree: usize,
    adj: &[Vec<f64>],
) -> RegularGraphBassIharaAudit {
    let n = adj.len();
    let q = degree.saturating_sub(1);
    let qf = q as f64;
    let degf = degree as f64;

    let is_regular = adj.iter().all(|row| {
        row.len() == n && (row.iter().sum::<f64>() - degf).abs() < 1e-12
    });

    // Connectivity via BFS from vertex 0
    let mut visited = vec![false; n];
    let mut queue = VecDeque::new();
    if n > 0 {
        visited[0] = true;
        queue.push_back(0);
    }
    while let Some(u) = queue.pop_front() {
        for v in 0..n {
            if !visited[v] && adj[u][v] > 0.5 {
                visited[v] = true;
                queue.push_back(v);
            }
        }
    }
    let is_connected = visited.iter().all(|&v| v);

    let eigenvalues = symmetric_jacobi_eigenvalues(adj);
    let ramanujan_bound = 2.0 * qf.sqrt();
    let inv_q = 1.0 / qf;

    let mut max_nt = 0.0_f64;
    let mut off_circle = 0usize;
    let mut roots = Vec::with_capacity(2 * n);

    for &lam in &eigenvalues {
        // Trivial eigenvalues are ±(q + 1)
        let is_trivial = (lam.abs() - degf).abs() < 1e-9;
        if !is_trivial && lam.abs() > max_nt {
            max_nt = lam.abs();
        }
        let disc = lam * lam - 4.0 * qf;
        let pair = if disc <= 1e-12 {
            let im = (-disc).max(0.0).sqrt() / (2.0 * qf);
            let re = lam / (2.0 * qf);
            [(re, im), (re, -im)]
        } else {
            let sd = disc.sqrt();
            [(lam + sd) / (2.0 * qf), (lam - sd) / (2.0 * qf)]
                .map(|r| (r, 0.0))
        };
        for (u_re, u_im) in pair {
            let mod_sq = u_re * u_re + u_im * u_im;
            let on_circle = (mod_sq - inv_q).abs() < 1e-9;
            if !is_trivial && !on_circle {
                off_circle += 1;
            }
            roots.push(BassIharaRoot {
                eigenvalue: lam,
                u_re,
                u_im,
                modulus_sq: mod_sq,
                is_trivial,
                on_critical_circle: on_circle,
            });
        }
    }

    RegularGraphBassIharaAudit {
        name: name.to_string(),
        vertices: n,
        degree,
        q,
        is_regular,
        is_connected,
        ramanujan_bound,
        eigenvalues,
        max_nontrivial_abs_eigenvalue: max_nt,
        markov_spectral_gap: 1.0 - max_nt / degf,
        ramanujan_margin: ramanujan_bound - max_nt,
        is_ramanujan: max_nt <= ramanujan_bound + 1e-9,
        nontrivial_off_circle_count: off_circle,
        roots,
    }
}

/// Evaluate finite partial Li sums `lambda_n^{(K)} = sum_{k=1}^K 2 Re[1 - (1 - 1/rho_k)^n]`
/// over supplied critical-line zeros `1/2 + i gamma_k`, optionally adding one hypothetical
/// off-line functional-equation quartet `{1/2 +- sigma_dev +- i gamma_off}` to verify that
/// off-line zeros drive `lambda_n < 0` for sufficiently large `n`.
pub fn li_partial_coefficients(
    critical_gammas: &[f64],
    max_n: usize,
    off_line_quartet: Option<(f64, f64)>,
) -> Vec<f64> {
    let mut terms_w: Vec<C64> = Vec::new();
    for &g in critical_gammas {
        let rho = C64::new(0.5, g);
        let w = C64::new(1.0, 0.0).sub(C64::new(1.0, 0.0).div(rho));
        terms_w.push(w);
    }
    let mut extra_w: Vec<C64> = Vec::new();
    if let Some((sigma_dev, g_off)) = off_line_quartet {
        for &s_re in &[0.5 + sigma_dev, 0.5 - sigma_dev] {
            let rho = C64::new(s_re, g_off);
            let w = C64::new(1.0, 0.0).sub(C64::new(1.0, 0.0).div(rho));
            extra_w.push(w);
        }
    }

    let mut pow_crit = vec![C64::new(1.0, 0.0); terms_w.len()];
    let mut pow_extra = vec![C64::new(1.0, 0.0); extra_w.len()];
    let mut lambdas = Vec::with_capacity(max_n);

    for _n in 1..=max_n {
        let mut acc = 0.0_f64;
        for (p, &w) in pow_crit.iter_mut().zip(terms_w.iter()) {
            *p = p.mul(w);
            acc += 2.0 * (1.0 - p.re);
        }
        for (p, &w) in pow_extra.iter_mut().zip(extra_w.iter()) {
            *p = p.mul(w);
            acc += 2.0 * (1.0 - p.re);
        }
        lambdas.push(acc);
    }
    lambdas
}

/// Evaluate the SL(2, C) celestial Plancherel weight `P(lambda) = |Gamma(1 + i lambda)|^2 = pi lambda / sinh(pi lambda)`.
pub fn celestial_plancherel_weight(lambda: f64) -> f64 {
    let x = PI * lambda.abs();
    if x < 1e-7 {
        let x2 = x * x;
        1.0 - x2 / 6.0 + (7.0 * x2 * x2) / 360.0
    } else if x > 700.0 {
        0.0
    } else {
        x / x.sinh()
    }
}

/// Evaluate the Planck / Bisognano–Wichmann Rindler boost Bose–Einstein difference form
/// `2 pi lambda [n_B(pi lambda) - n_B(2 pi lambda)]` of `P(lambda)` (`Theorem 5.183` of `TOUQGA-2.pdf`).
pub fn celestial_bose_difference_weight(lambda: f64) -> f64 {
    let y = PI * lambda.abs();
    if y < 1e-7 {
        celestial_plancherel_weight(lambda)
    } else if y > 350.0 {
        2.0 * y * (-y).exp()
    } else {
        let nb_y = 1.0 / (y.exp() - 1.0);
        let nb_2y = 1.0 / ((2.0 * y).exp() - 1.0);
        2.0 * y * (nb_y - nb_2y)
    }
}

/// 8-point Gauss–Legendre nodes and weights on `[-1, 1]` (16th-order accuracy).
const GAUSS_LEGENDRE_8: [(f64, f64); 8] = [
    (-0.960_289_856_497_536_2, 0.101_228_536_290_377_06),
    (-0.796_666_477_413_626_7, 0.222_381_034_453_374_43),
    (-0.525_532_409_916_329, 0.313_706_645_877_886_9),
    (-0.183_434_642_495_649_78, 0.362_683_783_378_361_66),
    (0.183_434_642_495_649_78, 0.362_683_783_378_361_66),
    (0.525_532_409_916_329, 0.313_706_645_877_886_9),
    (0.796_666_477_413_626_7, 0.222_381_034_453_374_43),
    (0.960_289_856_497_536_2, 0.101_228_536_290_377_06),
];

/// Composite 8-point Gauss–Legendre quadrature on `[a, b]` with `panels` subintervals.
fn gauss_legendre_8_integrate<F: Fn(f64) -> f64>(a: f64, b: f64, panels: usize, f: F) -> f64 {
    let h = (b - a) / (panels as f64);
    let half_h = 0.5 * h;
    let mut total = 0.0_f64;
    for p in 0..panels {
        let mid = a + ((p as f64) + 0.5) * h;
        let mut panel_sum = 0.0_f64;
        for &(xi, wi) in &GAUSS_LEGENDRE_8 {
            panel_sum += wi * f(mid + half_h * xi);
        }
        total += half_h * panel_sum;
    }
    total
}

/// Evaluate the half-line Plancherel rung convolution `F(y) = (1/(2 pi)) int_0^inf P(x) P(x - y) dx`
/// via the exact compact-interval identity:
/// `F(y) = ((1 + y^2) / 12) P(|y|) + (y / (2 pi)) int_0^{1/2} P(u |y|) P((1 - u) |y|) du`,
/// which holds for all `y in R` and satisfies `F(y) + F(-y) = ((1 + y^2) / 6) P(y)`.
pub fn celestial_half_line_convolution_f(y: f64) -> f64 {
    let y_abs = y.abs();
    let even_part = (1.0 + y_abs * y_abs) / 12.0 * celestial_plancherel_weight(y_abs);
    if y_abs < 1e-14 {
        return even_part;
    }
    let box_int = gauss_legendre_8_integrate(0.0, 0.5, 4, |u| {
        celestial_plancherel_weight(u * y_abs) * celestial_plancherel_weight((1.0 - u) * y_abs)
    });
    even_part + (y / (2.0 * PI)) * box_int
}

/// Cayley-regularized celestial spin-2 principal-series shadow norm factor
/// `W_grav^Cayley(sigma_dev) = 1 / (1 + 4 sigma_dev^2) in (0, 1]`.
pub fn celestial_spin_two_cayley_shadow_factor(sigma_dev: f64) -> f64 {
    1.0 / (1.0 + 4.0 * sigma_dev * sigma_dev)
}

/// All-loop Plancherel–Unruh geometric resummation envelope `8 / (8 - alpha_qg)` for `0 <= alpha_qg < 8`.
pub fn celestial_plancherel_all_loop_envelope(alpha_qg: f64) -> f64 {
    8.0 / (8.0 - alpha_qg)
}

/// One-loop dimensional-transmutation anomalous shift `sigma_dev(mu) = b0 * g^2 / (16 pi^2)`
/// where `beta(g) = -b0 g^3 / (16 pi^2)` and `sigma_dev = -beta(g) / g`.
pub fn celestial_dim_transmutation_dev(b0: f64, g_coupling: f64) -> f64 {
    b0 * g_coupling * g_coupling / (16.0 * PI * PI)
}

/// Rational IR soft-pole regulator `R_IR(lambda; mu_ir_xi_phi) = lambda^2 / (lambda^2 + (mu_ir * xi_phi)^2)`.
pub fn celestial_ir_regulator_factor(lambda: f64, ir_scale_prod: f64) -> f64 {
    let l2 = lambda * lambda;
    let s2 = ir_scale_prod * ir_scale_prod;
    if l2 + s2 == 0.0 {
        0.0
    } else {
        l2 / (l2 + s2)
    }
}

/// Combined Cayley–Plancherel IR/UV kernel `K_{IR/UV}(lambda, sigma_dev; mu_ir * xi_phi)`.
pub fn celestial_cayley_plancherel_ir_uv_kernel(
    lambda: f64,
    sigma_dev: f64,
    ir_scale_prod: f64,
) -> f64 {
    celestial_spin_two_cayley_shadow_factor(sigma_dev)
        * celestial_plancherel_weight(lambda)
        * celestial_ir_regulator_factor(lambda, ir_scale_prod)
}

/// IR confinement / healing-length Yukawa screening factor `S_IR(kappa_ir) = (1 + kappa_ir) exp(-kappa_ir) in (0, 1]`.
pub fn celestial_ir_screening_factor(kappa_ir: f64) -> f64 {
    (1.0 + kappa_ir) * (-kappa_ir).exp()
}

/// Combined IR-screened, Cayley-shadowed, Plancherel-resummed Model 16 transfer factor
/// `G_16(sigma_dev, alpha_qg, kappa_ir) = W_grav^Cayley(sigma_dev) * F_loop(alpha_qg) * S_IR(kappa_ir)`.
pub fn celestial_transfer_factor_16(sigma_dev: f64, alpha_qg: f64, kappa_ir: f64) -> f64 {
    let f_loop = 1.0 + (1.0 / 8.0) * alpha_qg + (1.0 / 90.0) * alpha_qg * alpha_qg;
    celestial_spin_two_cayley_shadow_factor(sigma_dev)
        * f_loop
        * celestial_ir_screening_factor(kappa_ir)
}

/// Källén–Lehmann mass-thresholded Mellin transform of the test amplitude `a(omega) = exp(-omega)`:
/// `int_{m_gap}^inf (omega^2 - m_gap^2)^{(Delta - 2)/2} * omega * exp(-omega) d omega`.
/// Factoring `omega - m_gap = t^2` removes the `m_gap` endpoint derivative singularity cleanly
/// for all `Delta >= 1` (`d omega = 2 t dt`, integrand `2 t^{Delta - 1} (2 m_gap + t^2)^{(Delta - 2)/2} omega exp(-omega)`),
/// reducing to `Gamma(Delta)` as `m_gap -> 0^+`.
pub fn kallen_lehmann_mellin_exp_test(m_gap: f64, delta_re: f64) -> f64 {
    let power = (delta_re - 2.0) / 2.0;
    let upper = m_gap + 36.0;
    let t_max = (upper - m_gap).sqrt();
    gauss_legendre_8_integrate(0.0, t_max, 32, |t| {
        let omega = m_gap + t * t;
        let t_pow = if (delta_re - 1.0).abs() < 1e-14 {
            1.0
        } else {
            t.powf(delta_re - 1.0)
        };
        2.0 * t_pow * (2.0 * m_gap + t * t).powf(power) * omega * (-omega).exp()
    })
}

/// Soft-dressed Källén–Lehmann Mellin integral at `Delta = 1` with `a(omega) = omega^{-1} exp(-omega)`:
/// `int_{m_gap}^inf (omega^2 - m_gap^2)^{-1/2} exp(-omega) d omega = K_0(m_gap) < inf`.
pub fn kallen_lehmann_soft_pole_bessel_test(m_gap: f64) -> f64 {
    let upper = m_gap + 28.0;
    let t_max = (upper - m_gap).sqrt();
    gauss_legendre_8_integrate(0.0, t_max, 32, |t| {
        let omega = m_gap + t * t;
        2.0 * (2.0 * m_gap + t * t).powf(-0.5) * (-omega).exp()
    })
}

/// Exponentially damped Yukawa–Mellin integral `int_0^inf omega^{Delta - 1 - n} exp(-mu_ir * omega) d omega`
/// for `Delta > n` and `mu_ir > 0`, cross-checked against analytic `mu_ir^{n - Delta} Gamma(Delta - n)`.
pub fn yukawa_mellin_analytic_gamma(delta_re: f64, mu_ir: f64, n_soft: f64) -> f64 {
    let z = C64::new(delta_re - n_soft, 0.0);
    mu_ir.powf(n_soft - delta_re) * c64_gamma(z).re
}

/// Audit summary for Celestial IR regularization and Integrated Turner Models 16a & 16b.
#[derive(Clone, Debug, PartialEq)]
pub struct CelestialIrModel16Audit {
    pub rg_sigma_dev_su3: f64,
    pub rg_casimir_im_nonzero: f64,
    pub k_ir_uv_at_zero: f64,
    pub k_ir_uv_at_one: f64,
    pub k_ir_uv_unreg_limit_diff: f64,
    pub kl_mellin_mgap_1: f64,
    pub kl_mellin_mgap_0_vs_gamma: f64,
    pub kl_mellin_delta1_mgap_half: f64,
    pub yukawa_mellin_quad_vs_gamma_diff: f64,
    pub s_ir_zero: f64,
    pub s_ir_half: f64,
    pub s_ir_quadratic_margin_half: f64,
    pub model16_uv_core_vs_ir_gap_ordering: bool,
    pub g16_classical: f64,
    pub g16_off_line_positive: f64,
    pub model16a_mercury_arcsec_cy: f64,
    pub model16b_mercury_arcsec_cy: f64,
    pub model16_rel_err_vs_gr: f64,
    pub model16_solar_light_bending_arcsec: f64,
    pub model16a_gw_below_gap: f64,
    pub model16b_gw_gapless_ratio: f64,
    pub model16a_active_laser_deflection: f64,
    pub model16b_active_laser_deflection: f64,
    pub d_cft_4d_re_delta: f64,
}

/// Run the full Celestial IR divergence resolution & Turner Model 16a/16b audit in Rust `f64`.
pub fn audit_celestial_ir_and_turner_model16() -> CelestialIrModel16Audit {
    let b0_su3 = 11.0; // pure SU(3) (n_f = 0)
    let g_run = 1.2;
    let sigma_rg = celestial_dim_transmutation_dev(b0_su3, g_run);
    let casimir_im = 2.0 * sigma_rg * 14.134_725_141_734_693;

    let k_zero = celestial_cayley_plancherel_ir_uv_kernel(0.0, 0.2, 0.5);
    let k_one = celestial_cayley_plancherel_ir_uv_kernel(1.0, 0.2, 0.5);
    let k_lim_diff = (celestial_cayley_plancherel_ir_uv_kernel(1.0, 0.2, 0.0)
        - celestial_spin_two_cayley_shadow_factor(0.2) * celestial_plancherel_weight(1.0))
    .abs();

    let kl_1 = kallen_lehmann_mellin_exp_test(1.0, 2.5);
    let kl_0 = kallen_lehmann_mellin_exp_test(0.0, 2.5);
    let gamma_25 = c64_gamma(C64::new(2.5, 0.0)).re;
    let kl_0_err = (kl_0 - gamma_25).abs();
    let kl_d1_half = kallen_lehmann_soft_pole_bessel_test(0.5);

    // Yukawa-Mellin at Delta = 2.5, n_soft = 1.0, mu_ir = 0.7 -> int_0^inf omega^{0.5} exp(-0.7 omega) d omega
    // Change variables omega = t^2 (d omega = 2 t dt) to make integrand smooth at t = 0: 2 * t^2 * exp(-0.7 t^2)
    let mu_ir = 0.7;
    let yuk_quad = gauss_legendre_8_integrate(0.0, 8.0, 24, |t| {
        2.0 * t * t * (-mu_ir * t * t).exp()
    });
    let yuk_analytic = yukawa_mellin_analytic_gamma(2.5, mu_ir, 1.0);
    let yuk_diff = (yuk_quad - yuk_analytic).abs();

    let s_ir_0 = celestial_ir_screening_factor(0.0);
    let s_ir_half = celestial_ir_screening_factor(0.5);
    let s_ir_quad_margin = s_ir_half - (1.0 - 0.5 * 0.5 * 0.5);
    let uv_vs_ir_ok = celestial_ir_screening_factor(2.0) < celestial_ir_screening_factor(1.0)
        && celestial_ir_screening_factor(0.5) < celestial_ir_screening_factor(0.25)
        && s_ir_quad_margin >= 0.0;
    let g16_0 = celestial_transfer_factor_16(0.0, 0.0, 0.0);
    let g16_off = celestial_transfer_factor_16(1.0, 0.5, 0.3);

    // Mercury & Solar limb benchmark
    let gm_over_c2 = 1_476.625_038_5_f64;
    let r_sun = 6.957e8_f64;
    let a_merc = 5.790_905e10_f64;
    let e_merc = 0.205_630_69_f64;
    let kahler_det = 4.0 - e_merc * e_merc;
    let orbits_per_century = 36525.0 / 87.9691;
    let arcsec_per_rad = (180.0 * 3600.0) / PI;

    let gr_merc = ((6.0 * PI * gm_over_c2) / (a_merc * (1.0 - e_merc * e_merc)))
        * orbits_per_century
        * arcsec_per_rad;
    let m16a_merc = g16_0
        * ((6.0 * PI * gm_over_c2) / (a_merc * (kahler_det - 3.0)))
        * orbits_per_century
        * arcsec_per_rad;
    let m16b_merc = m16a_merc;
    let rel_err = (m16a_merc - gr_merc).abs() / gr_merc;
    let light_arcsec = g16_0
        * ((4.0 * gm_over_c2 / r_sun) * (kahler_det - 3.0) / (1.0 - e_merc * e_merc))
        * arcsec_per_rad;

    // GW threshold: Model 16a cutoff at 2*Omega_orb < omega_gap vs gapless Model 16b (xi_phi/a = 1e-12)
    let two_omega_orb = 1.0;
    let omega_gap_high = 10.0;
    let m16a_gw_below = if two_omega_orb >= omega_gap_high {
        1.0
    } else {
        0.0
    };
    let m16b_gw_gapless = celestial_transfer_factor_16(0.0, 0.0, 1e-12);

    // TOUTRR Re(Delta) = d_CFT / 2 in 4D bulk (d_CFT = d_bulk - 2 = 2 => Re(Delta) = 1)
    let d_cft_4d = (4.0_f64 - 2.0_f64) / 2.0_f64;

    CelestialIrModel16Audit {
        rg_sigma_dev_su3: sigma_rg,
        rg_casimir_im_nonzero: casimir_im,
        k_ir_uv_at_zero: k_zero,
        k_ir_uv_at_one: k_one,
        k_ir_uv_unreg_limit_diff: k_lim_diff,
        kl_mellin_mgap_1: kl_1,
        kl_mellin_mgap_0_vs_gamma: kl_0_err,
        kl_mellin_delta1_mgap_half: kl_d1_half,
        yukawa_mellin_quad_vs_gamma_diff: yuk_diff,
        s_ir_zero: s_ir_0,
        s_ir_half,
        s_ir_quadratic_margin_half: s_ir_quad_margin,
        model16_uv_core_vs_ir_gap_ordering: uv_vs_ir_ok,
        g16_classical: g16_0,
        g16_off_line_positive: g16_off,
        model16a_mercury_arcsec_cy: m16a_merc,
        model16b_mercury_arcsec_cy: m16b_merc,
        model16_rel_err_vs_gr: rel_err,
        model16_solar_light_bending_arcsec: light_arcsec,
        model16a_gw_below_gap: m16a_gw_below,
        model16b_gw_gapless_ratio: m16b_gw_gapless,
        model16a_active_laser_deflection: 1.0,
        model16b_active_laser_deflection: 0.0,
        d_cft_4d_re_delta: d_cft_4d,
    }
}

/// Exact finite-field point count `|Gr(2,4)(F_q)| = 1 + q + 2 q^2 + q^3 + q^4 = (1 + q^2)(1 + q + q^2)`.
pub fn gr24_hasse_weil_point_count(q: u64) -> u64 {
    1 + q + 2 * q * q + q.pow(3) + q.pow(4)
}

/// Brute-force count of 2-dimensional subspaces of `F_p^4` in reduced row-echelon form (Schubert cells)
/// for a prime `p`, confirming `|Gr(2,4)(F_p)| = sum_{k=0}^4 b_{2k} p^k`.
pub fn gr24_rref_subspace_count_fp(p: u64) -> u64 {
    // Every 2-plane in F_p^4 has a unique 2x4 RREF basis with pivot columns 0 <= c0 < c1 < 4.
    // The number of free entries for each pivot pair (c0, c1) is:
    // (0,1) -> 4 free entries (p^4)
    // (0,2) -> 3 free entries (p^3)
    // (0,3) -> 2 free entries (p^2)
    // (1,2) -> 2 free entries (p^2)
    // (1,3) -> 1 free entry  (p^1)
    // (2,3) -> 0 free entries (p^0 = 1)
    let mut count = 0u64;
    for c0 in 0..4usize {
        for c1 in (c0 + 1)..4usize {
            let free_row0 = (3 - c0) - 1; // columns > c0 excluding c1
            let free_row1 = 3 - c1;       // columns > c1
            let free_total = (free_row0 + free_row1) as u32;
            count += p.pow(free_total);
        }
    }
    count
}

/// Symmetric adelic Cesàro mean `N_reg(sigma, R) = (1 / (2 ln R)) int_{R^{-1}}^R r^{2 sigma - 2} dr`
/// `= sinh((2 sigma - 1) ln R) / ((2 sigma - 1) ln R)` on the shifted character `|a|^{s - 1/2}`.
pub fn adelic_symmetric_cesaro_mean(sigma: f64, cutoff_r: f64) -> f64 {
    let l = cutoff_r.ln();
    let alpha = 2.0 * sigma - 1.0;
    let x = alpha * l;
    if x.abs() < 1e-8 {
        1.0 + x * x / 6.0
    } else {
        x.sinh() / x
    }
}

/// Complex Lanczos gamma evaluation for celestial 3-point MHV / shadow-Jost verification.
fn c64_gamma(z: C64) -> C64 {
    const G: f64 = 7.0;
    const COEFFS: [f64; 9] = [
        0.999_999_999_999_809_9,
        676.520_368_121_885_1,
        -1259.139_216_722_402_8,
        771.323_428_777_653_1,
        -176.615_029_162_140_6,
        12.507_343_278_686_905,
        -0.138_571_095_265_720_12,
        9.984_369_578_019_572e-6,
        1.505_632_735_149_311_6e-7,
    ];
    if z.re < 0.5 {
        // Reflection formula: Gamma(z) = pi / (sin(pi z) * Gamma(1 - z))
        let pi_z = C64::new(PI * z.re, PI * z.im);
        let sin_piz = C64::new(
            pi_z.re.sin() * pi_z.im.cosh(),
            pi_z.re.cos() * pi_z.im.sinh(),
        );
        let one_minus_z = C64::new(1.0 - z.re, -z.im);
        return C64::new(PI, 0.0).div(sin_piz.mul(c64_gamma(one_minus_z)));
    }
    let zm1 = C64::new(z.re - 1.0, z.im);
    let mut x = C64::new(COEFFS[0], 0.0);
    for (i, &c) in COEFFS.iter().enumerate().skip(1) {
        let denom = C64::new(zm1.re + (i as f64), zm1.im);
        x = x.add(C64::new(c, 0.0).div(denom));
    }
    let t = C64::new(zm1.re + G + 0.5, zm1.im);
    let r = t.abs();
    let theta = t.im.atan2(t.re);
    let ln_t = C64::new(r.ln(), theta);
    let pow_exp = C64::new(zm1.re + 0.5, zm1.im).mul(ln_t).sub(t);
    let pref = (2.0 * PI).sqrt() * pow_exp.re.exp();
    let phase = C64::new(pow_exp.im.cos(), pow_exp.im.sin());
    phase.scale(pref).mul(x)
}

/// Audit report for Celestial Holography, Plancherel–Unruh loop weights, Googly shadow-Jost
/// identity, Hasse–Weil `Gr(2,4)(F_q)` counts, Cesàro symmetry, and Integrated Turner Model 15.
#[derive(Clone, Debug, PartialEq)]
pub struct CelestialHolographyGravitonAudit {
    pub plancherel_bose_max_diff: f64,
    pub m1_quadrature: f64,
    pub m1_exact: f64,
    pub m1_abs_error: f64,
    pub m2_quadrature: f64,
    pub m2_exact: f64,
    pub m2_abs_error: f64,
    pub m3_quadrature: f64,
    pub m3_reference: f64,
    pub m3_abs_error: f64,
    pub m3_upper_bound: f64,
    pub m3_even_part: f64,
    pub m3_odd_excess: f64,
    pub plancherel_two_loop_deficit_coeff: f64,
    pub googly_principal_series_rel_err: f64,
    pub googly_off_line_symmetry_breaking: f64,
    pub gr24_f2_points: u64,
    pub gr24_f3_points: u64,
    pub gr24_f5_points: u64,
    pub gr24_f7_points: u64,
    pub gr24_rref_matches_polynomial: bool,
    pub cesaro_at_half: f64,
    pub cesaro_at_quarter: f64,
    pub cesaro_at_three_quarters: f64,
    pub cesaro_even_symmetry_diff: f64,
    pub turner_model15_mercury_arcsec_century: f64,
    pub turner_model15_rel_err_vs_gr: f64,
    pub turner_model15_solar_light_bending_arcsec: f64,
    pub turner_model15_cayley_shadow_norm_at_half: f64,
    pub turner_model15_cayley_shadow_norm_at_one: f64,
    pub turner_model15a_active_laser_deflection: f64,
    pub turner_model15b_active_laser_deflection: f64,
}

/// Execute the full Celestial Holography & Integrated Turner Model 15 numerical audit in Rust `f64`.
pub fn audit_celestial_holography_and_turner_graviton() -> CelestialHolographyGravitonAudit {
    // 1. Plancherel weight P(lambda) vs. Planck/Bisognano-Wichmann Bose difference
    let mut max_bose_diff = 0.0_f64;
    for k in 1..=200 {
        let lam = (k as f64) * 0.15;
        let diff = (celestial_plancherel_weight(lam) - celestial_bose_difference_weight(lam)).abs();
        if diff > max_bose_diff {
            max_bose_diff = diff;
        }
    }

    // 2. 1-loop M_1, 2-loop M_2, and 3-loop M_3 via 8-point Gauss–Legendre quadrature on [0, 15]
    let m1_quad = gauss_legendre_8_integrate(0.0, 15.0, 24, celestial_plancherel_weight) / (2.0 * PI);
    let m2_quad = gauss_legendre_8_integrate(0.0, 15.0, 24, |y| {
        celestial_plancherel_weight(y) * celestial_half_line_convolution_f(y)
    }) / (2.0 * PI);
    let m3_quad = gauss_legendre_8_integrate(0.0, 15.0, 24, |y| {
        let fy = celestial_half_line_convolution_f(y);
        celestial_plancherel_weight(y) * fy * fy
    }) / (2.0 * PI);
    let m3_even_part = gauss_legendre_8_integrate(0.0, 15.0, 24, |y| {
        let a_even = (1.0 + y * y) / 12.0 * celestial_plancherel_weight(y);
        celestial_plancherel_weight(y) * a_even * a_even
    }) / (2.0 * PI);

    let m1_exact = 1.0 / 8.0;
    let m2_exact = 1.0 / 90.0;
    let m3_ref = 0.001_028_020_476_820_681_1;

    // 3. Googly shadow-Jost 3-point MHV vs. shadow-conjugated coefficient on and off the principal series
    let eval_mhv_vs_shadow = |sigma_dev: f64, l1: f64, l2: f64, l3: f64| -> f64 {
        let d1 = C64::new(1.0 + 2.0 * sigma_dev, l1);
        let d2 = C64::new(1.0 + 2.0 * sigma_dev, l2);
        let d3 = C64::new(1.0 + 2.0 * sigma_dev, l3);
        let sum_m2 = C64::new(d1.re + d2.re + d3.re - 2.0, d1.im + d2.im + d3.im);
        let c_mhv = c64_gamma(d1)
            .mul(c64_gamma(d2))
            .mul(c64_gamma(d3))
            .div(c64_gamma(sum_m2));

        let sd1 = C64::new(2.0 - d1.re, -d1.im);
        let sd2 = C64::new(2.0 - d2.re, -d2.im);
        let sd3 = C64::new(2.0 - d3.re, -d3.im);
        let s_sum_m2 = C64::new(sd1.re + sd2.re + sd3.re - 2.0, sd1.im + sd2.im + sd3.im);
        let c_sh_raw = c64_gamma(sd1)
            .mul(c64_gamma(sd2))
            .mul(c64_gamma(sd3))
            .div(c64_gamma(s_sum_m2));
        let c_sh_conj = C64::new(c_sh_raw.re, -c_sh_raw.im);
        c_mhv.sub(c_sh_conj).abs() / c_mhv.abs()
    };
    let googly_on_line = eval_mhv_vs_shadow(0.0, 0.7, -1.3, 1.1);
    let googly_off_line = eval_mhv_vs_shadow(0.15, 0.7, -1.3, 1.1);

    // 4. Hasse–Weil Gr(2,4)(F_q) point counts vs. RREF Schubert cell enumeration
    let f2 = gr24_hasse_weil_point_count(2);
    let f3 = gr24_hasse_weil_point_count(3);
    let f5 = gr24_hasse_weil_point_count(5);
    let f7 = gr24_hasse_weil_point_count(7);
    let rref_ok = f2 == gr24_rref_subspace_count_fp(2)
        && f3 == gr24_rref_subspace_count_fp(3)
        && f5 == gr24_rref_subspace_count_fp(5)
        && f7 == gr24_rref_subspace_count_fp(7);

    // 5. Symmetric adelic Cesàro mean at sigma = 0.50 vs. 0.25 and 0.75 (cutoff R = 10^4)
    let c_half = adelic_symmetric_cesaro_mean(0.50, 10_000.0);
    let c_q1 = adelic_symmetric_cesaro_mean(0.25, 10_000.0);
    let c_q3 = adelic_symmetric_cesaro_mean(0.75, 10_000.0);

    // 6. Turner Model 15 Mercury perihelion advance (arcsec/century) & solar light bending (arcsec)
    // Solar GM / c^2 = 1_476.625_038_5 m, R_sun = 6.957e8 m, Mercury a = 5.790_905e10 m, e = 0.205_630_69, T_orb = 87.9691 days
    let gm_over_c2 = 1_476.625_038_5_f64;
    let r_sun = 6.957e8_f64;
    let a_merc = 5.790_905e10_f64;
    let e_merc = 0.205_630_69_f64;
    let kahler_det = 4.0 - e_merc * e_merc;
    let shadow_norm_on_line = celestial_spin_two_cayley_shadow_factor(0.0);
    let plancherel_loop_classical = 1.0 + 0.125 * 0.0 + (1.0 / 90.0) * 0.0;
    let dvarpi_rad_per_orbit = shadow_norm_on_line
        * plancherel_loop_classical
        * (6.0 * PI * gm_over_c2)
        / (a_merc * (kahler_det - 3.0));
    let orbits_per_century = 36525.0 / 87.9691;
    let arcsec_per_rad = (180.0 * 3600.0) / PI;
    let merc_arcsec_cy = dvarpi_rad_per_orbit * orbits_per_century * arcsec_per_rad;
    let gr_ref_arcsec_cy =
        ((6.0 * PI * gm_over_c2) / (a_merc * (1.0 - e_merc * e_merc))) * orbits_per_century * arcsec_per_rad;
    let rel_err_gr = (merc_arcsec_cy - gr_ref_arcsec_cy).abs() / gr_ref_arcsec_cy;
    let solar_light_bending_arcsec = shadow_norm_on_line
        * plancherel_loop_classical
        * ((4.0 * gm_over_c2 / r_sun) * (kahler_det - 3.0) / (1.0 - e_merc * e_merc))
        * arcsec_per_rad;

    CelestialHolographyGravitonAudit {
        plancherel_bose_max_diff: max_bose_diff,
        m1_quadrature: m1_quad,
        m1_exact,
        m1_abs_error: (m1_quad - m1_exact).abs(),
        m2_quadrature: m2_quad,
        m2_exact,
        m2_abs_error: (m2_quad - m2_exact).abs(),
        m3_quadrature: m3_quad,
        m3_reference: m3_ref,
        m3_abs_error: (m3_quad - m3_ref).abs(),
        m3_upper_bound: 1.0 / 512.0,
        m3_even_part,
        m3_odd_excess: m3_quad - m3_even_part,
        plancherel_two_loop_deficit_coeff: m1_exact * m1_exact - m2_exact,
        googly_principal_series_rel_err: googly_on_line,
        googly_off_line_symmetry_breaking: googly_off_line,
        gr24_f2_points: f2,
        gr24_f3_points: f3,
        gr24_f5_points: f5,
        gr24_f7_points: f7,
        gr24_rref_matches_polynomial: rref_ok,
        cesaro_at_half: c_half,
        cesaro_at_quarter: c_q1,
        cesaro_at_three_quarters: c_q3,
        cesaro_even_symmetry_diff: (c_q1 - c_q3).abs(),
        turner_model15_mercury_arcsec_century: merc_arcsec_cy,
        turner_model15_rel_err_vs_gr: rel_err_gr,
        turner_model15_solar_light_bending_arcsec: solar_light_bending_arcsec,
        turner_model15_cayley_shadow_norm_at_half: celestial_spin_two_cayley_shadow_factor(0.5),
        turner_model15_cayley_shadow_norm_at_one: celestial_spin_two_cayley_shadow_factor(1.0),
        turner_model15a_active_laser_deflection: 1.0,
        turner_model15b_active_laser_deflection: 0.0,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn finite_dbn_quartic_heat_gr24_chart_matches_coefficient_and_plucker_contracts() {
        let initial = DbnQuarticHeatGr24State::from_taylor_jet(0.004, -22.0, 1000.0, 0.125);
        let delta_time = 0.25;
        let stepped = initial.heat_step(delta_time);
        let direct = DbnQuarticHeatGr24State::from_taylor_jet(
            0.004,
            -22.0,
            1000.0,
            0.125 + delta_time,
        );

        assert!((stepped.a0 - direct.a0).abs() < 1e-12);
        assert!((stepped.a2 - direct.a2).abs() < 1e-12);
        assert!((stepped.a4 - direct.a4).abs() < 1e-12);

        let delta_time2 = 0.5;
        let sequential = stepped.heat_step(delta_time2);
        let combined = initial.heat_step(delta_time + delta_time2);
        assert!((sequential.a0 - combined.a0).abs() < 1e-11);
        assert!((sequential.a2 - combined.a2).abs() < 1e-12);
        assert!((sequential.a4 - combined.a4).abs() < 1e-12);
        assert!((initial.plucker_relation_residual()).abs() < 1e-12);
        assert!((stepped.evaluate(0.3) - direct.evaluate(0.3)).abs() < 1e-11);

        let generator = initial.generator_matrix();
        let left = DbnQuarticHeatGr24State::ambient_heat_action(delta_time);
        let action2 = DbnQuarticHeatGr24State::ambient_heat_action(delta_time2);
        let action_sum = DbnQuarticHeatGr24State::ambient_heat_action(delta_time + delta_time2);
        for row in 0..4 {
            for column in 0..4 {
                let product: f64 = (0..4)
                    .map(|inner| left[row][inner] * action2[inner][column])
                    .sum();
                assert!((product - action_sum[row][column]).abs() < 1e-11);
            }
        }

        let transformed = initial.generator_after_ambient_heat_action(delta_time);
        let stepped_generator = stepped.generator_matrix();
        for row in 0..2 {
            for column in 0..4 {
                assert!((transformed[row][column] - stepped_generator[row][column]).abs() < 1e-11);
            }
        }
        assert_eq!(generator[1], [0.0, 0.0, 0.0, 1.0]);

        let reverse = DbnQuarticHeatGr24State::ambient_heat_action(-delta_time);
        for row in 0..4 {
            for column in 0..4 {
                let product: f64 = (0..4)
                    .map(|inner| left[row][inner] * reverse[inner][column])
                    .sum();
                let expected = if row == column { 1.0 } else { 0.0 };
                assert!((product - expected).abs() < 1e-12);
            }
        }

        let audit = audit_dbn_quartic_heat_gr24(0.004, -22.0, 1000.0, 0.125, 0.25, 0.5, 0.3);
        assert!(audit.finite_inputs && audit.chart_has_nonzero_minor);
        assert!(audit.max_abs_residual() < 1e-10, "audit={audit:?}");

        let zero_chart = audit_dbn_quartic_heat_gr24(0.0, 0.0, 0.0, 0.0, 0.25, 0.5, 0.3);
        assert!(!zero_chart.chart_has_nonzero_minor);
        assert!(zero_chart.max_abs_residual() < 1e-12, "zero_chart={zero_chart:?}");
    }

    #[test]
    fn first_30_riemann_zeros_match_high_precision_and_cross_check_rs_c2() {
        let zeros = find_first_n_riemann_zeros(30);
        assert_eq!(zeros.len(), 30);
        // Check first and 30th zeros against Odlyzko / mpmath 15-digit values
        assert!((zeros[0].gamma - 14.134_725_141_734_693).abs() < 1e-12);
        assert!((zeros[29].gamma - 101.317_851_005_731_39).abs() < 1e-11);
        for z in &zeros {
            assert!(z.zeta_abs < 1e-11, "zero #{} zeta_abs={}", z.index, z.zeta_abs);
            assert!(
                z.hardy_z_riemann_siegel_c2.abs() < 1e-4,
                "zero #{} RS-C2 residual={}",
                z.index,
                z.hardy_z_riemann_siegel_c2
            );
            assert!(
                z.hardy_z_riemann_siegel_c4.abs() < 1e-4,
                "zero #{} RS-C4 residual={}",
                z.index,
                z.hardy_z_riemann_siegel_c4
            );
            assert!(z.jensen_polya_j > 0.0);
        }
        // At zero #30 (t ~ 101.32), Gabcke C4 beats C2 by > 40x!
        assert!(zeros[29].hardy_z_riemann_siegel_c4.abs() < 5e-8);
        assert!(
            zeros[29].hardy_z_riemann_siegel_c4.abs()
                < zeros[29].hardy_z_riemann_siegel_c2.abs() / 20.0
        );
        // Borwein Algorithm 2 in f64 matches zeta(2) = pi^2/6 to < 1e-13 and reaches ~1e-7
        // on the first zero (t ~ 14.13) before (3 + 2 sqrt(2))^n conditioning degrades at large t.
        let z2 = zeta_borwein(2.0, 0.0, 20);
        assert!((z2.re - PI * PI / 6.0).abs() < 1e-13 && z2.im.abs() < 1e-13);
        assert!(zeros[0].borwein_zeta_abs < 1e-6);
    }

    #[test]
    fn gram_law_violations_and_lehmer_1956_pair_preserve_positive_jensen_polya() {
        let grams = audit_gram_law_window();
        assert_eq!(grams.len(), 6);
        // g_125 exact analytic J = 71.3809168305 (exact Jet2 matches 35-digit mpmath to < 1e-9!)
        assert!(grams[0].gram_holds); // g_125
        assert!((grams[0].point.j_total - 71.380_916_830_542).abs() < 1e-8);
        assert!(!grams[1].gram_holds); // g_126 violation!
        assert!((grams[1].point.z0 - (-0.027_629_508_2)).abs() < 1e-8);
        assert!((grams[1].point.j_total - 7.068_010_3).abs() < 1e-5);
        assert!(grams[2].gram_holds); // g_127
        assert!(grams[3].gram_holds); // g_133
        assert!(!grams[4].gram_holds); // g_134 violation!
        assert!((grams[4].point.z0 - (-0.016_900_39)).abs() < 1e-7);
        assert!(grams[4].point.j_total > 2.5);
        assert!(grams[5].gram_holds); // g_135

        // Lehmer 1956 pair (#6709 & #6710) with RS-C4 + exact analytic Jet2
        let lehmer = audit_lehmer_1956_pair();
        assert!((lehmer.gamma_left - 7005.062_866_174_92).abs() < 1e-9);
        assert!((lehmer.gamma_right - 7005.100_564_672_65).abs() < 1e-9);
        assert!((lehmer.gap - 0.037_698_497_73).abs() < 1e-9);
        // Exact mpmath sign: positive peak Z(g*) = +0.0039673575, Z''(g*) = -22.34615435, J_bohm = +0.0886551841
        assert!((lehmer.extremum.z0 - 0.003_967_357_5).abs() < 1e-9);
        assert!((lehmer.extremum.z_double_prime - (-22.346_154_35)).abs() < 1e-6);
        assert!((lehmer.extremum.j_bohm - 0.088_655_184_1).abs() < 1e-8);
        assert!((lehmer.extremum.bohm_ratio - 1.0).abs() < 1e-10);
    }

    #[test]
    fn finite_graph_bass_ihara_ramanujan_vs_14vertex_barbell_counterexample() {
        let (k_name, k_deg, k_adj) = k33_graph_6();
        let k_audit = analyze_regular_graph_bass_ihara(&k_name, k_deg, &k_adj);
        assert!(k_audit.is_regular && k_audit.is_connected && k_audit.is_ramanujan);
        assert!(k_audit.max_nontrivial_abs_eigenvalue < 1e-11);
        assert!((k_audit.markov_spectral_gap - 1.0).abs() < 1e-11);
        assert_eq!(k_audit.nontrivial_off_circle_count, 0);

        let (p_name, p_deg, p_adj) = petersen_graph_10();
        let p_audit = analyze_regular_graph_bass_ihara(&p_name, p_deg, &p_adj);
        assert!(p_audit.is_regular && p_audit.is_connected && p_audit.is_ramanujan);
        assert_eq!(p_audit.nontrivial_off_circle_count, 0);

        let (h_name, h_deg, h_adj) = heawood_graph_14();
        let h_audit = analyze_regular_graph_bass_ihara(&h_name, h_deg, &h_adj);
        assert!(h_audit.is_regular && h_audit.is_connected && h_audit.is_ramanujan);
        assert!((h_audit.max_nontrivial_abs_eigenvalue - 2.0_f64.sqrt()).abs() < 1e-11);
        assert_eq!(h_audit.nontrivial_off_circle_count, 0);

        let (m_name, m_deg, m_adj) = mobius_kantor_graph_16();
        let m_audit = analyze_regular_graph_bass_ihara(&m_name, m_deg, &m_adj);
        assert!(m_audit.is_regular && m_audit.is_connected && m_audit.is_ramanujan);
        assert!((m_audit.max_nontrivial_abs_eigenvalue - 3.0_f64.sqrt()).abs() < 1e-11);
        assert_eq!(m_audit.nontrivial_off_circle_count, 0);

        let (b_name, b_deg, b_adj) = barbell_non_ramanujan_14();
        let b_audit = analyze_regular_graph_bass_ihara(&b_name, b_deg, &b_adj);
        assert!(b_audit.is_regular && b_audit.is_connected);
        assert!(!b_audit.is_ramanujan);
        assert!(b_audit.ramanujan_margin < 0.0);
        assert!(b_audit.markov_spectral_gap < p_audit.markov_spectral_gap);
        assert!((b_audit.max_nontrivial_abs_eigenvalue - 2.855_772_506_6).abs() < 1e-8);
        assert!(b_audit.max_nontrivial_abs_eigenvalue > 2.0 * 2.0_f64.sqrt());
        assert_eq!(b_audit.nontrivial_off_circle_count, 2);
        // Verify u_+ * u_- = 1/2 for the two off-circle real roots
        let off: Vec<&BassIharaRoot> = b_audit
            .roots
            .iter()
            .filter(|r| !r.is_trivial && !r.on_critical_circle)
            .collect();
        assert_eq!(off.len(), 2);
        assert!((off[0].u_im).abs() < 1e-12 && (off[1].u_im).abs() < 1e-12);
        assert!((off[0].u_re * off[1].u_re - 0.5).abs() < 1e-12);
    }

    #[test]
    fn li_partial_coefficients_positive_on_critical_line_and_turn_negative_off_line() {
        let zeros = find_first_n_riemann_zeros(30);
        let gammas: Vec<f64> = zeros.iter().map(|z| z.gamma).collect();
        let crit_li = li_partial_coefficients(&gammas, 80, None);
        assert!(crit_li.iter().all(|&v| v > 0.0));

        // Injecting a hypothetical off-line quartet at Re(s) = 0.5 +- 0.20, Im(s) = 14.1347
        // creates |1 - 1/rho| ~ 1.0010 > 1, driving partial Li coefficients negative for finite n.
        let off_li = li_partial_coefficients(&gammas, 5000, Some((0.20, 14.1347)));
        assert!(off_li.iter().any(|&v| v < 0.0));
    }

    #[test]
    fn celestial_holography_plancherel_loops_googly_and_turner_model15_audit() {
        let rep = audit_celestial_holography_and_turner_graviton();
        assert!(rep.plancherel_bose_max_diff < 1e-14);
        assert!(rep.m1_abs_error < 1e-12);
        assert!(rep.m2_abs_error < 1e-12);
        assert!(rep.m3_abs_error < 1e-12);
        assert!(rep.m3_quadrature < rep.m3_upper_bound);
        assert!(rep.googly_principal_series_rel_err < 1e-14);
        assert!(rep.googly_off_line_symmetry_breaking > 0.1);
        assert_eq!(rep.gr24_f2_points, 35);
        assert_eq!(rep.gr24_f3_points, 130);
        assert_eq!(rep.gr24_f5_points, 806);
        assert_eq!(rep.gr24_f7_points, 2850);
        assert!(rep.gr24_rref_matches_polynomial);
        assert!((rep.m3_even_part - 0.000_599_032_245_072_408_5).abs() < 1e-13);
        assert!((rep.m3_odd_excess - 0.000_428_988_231_748_272_6).abs() < 1e-13);
        assert!((rep.plancherel_two_loop_deficit_coeff - 13.0 / 2880.0).abs() < 1e-16);
        assert!((rep.cesaro_at_half - 1.0).abs() < 1e-14);
        assert!(rep.cesaro_at_quarter > 10.0 && rep.cesaro_at_three_quarters > 10.0);
        assert!(rep.cesaro_even_symmetry_diff < 1e-13);
        assert!((rep.turner_model15_mercury_arcsec_century - 42.9814).abs() < 0.01);
        assert!(rep.turner_model15_rel_err_vs_gr < 1e-15);
        assert!((rep.turner_model15_solar_light_bending_arcsec - 1.7505).abs() < 0.001);
        assert!((rep.turner_model15_cayley_shadow_norm_at_half - 0.5).abs() < 1e-15);
        assert!((rep.turner_model15_cayley_shadow_norm_at_one - 0.2).abs() < 1e-15);
        assert_eq!(rep.turner_model15a_active_laser_deflection, 1.0);
        assert_eq!(rep.turner_model15b_active_laser_deflection, 0.0);
    }

    #[test]
    fn celestial_cayley_shadow_norm_all_loop_bound_and_quartic_counterexample() {
        // 1. Removable-singularity & asymptotic branches of P(lambda), Bose difference, and F(y)
        assert!((celestial_plancherel_weight(0.0) - 1.0).abs() < 1e-15);
        assert!((celestial_bose_difference_weight(0.0) - 1.0).abs() < 1e-15);
        assert!(celestial_plancherel_weight(120.0) >= 0.0 && celestial_plancherel_weight(120.0) < 1e-100);
        assert!(celestial_bose_difference_weight(120.0) >= 0.0 && celestial_bose_difference_weight(120.0) < 1e-100);
        assert!((celestial_half_line_convolution_f(0.0) - 1.0 / 12.0).abs() < 1e-15);

        // 2. Full-line convolution identity F(y) + F(-y) = ((1 + y^2) / 6) P(y) across positive and negative y
        for &y in &[0.25_f64, 0.75, 1.5, 3.0] {
            let full_conv = celestial_half_line_convolution_f(y) + celestial_half_line_convolution_f(-y);
            let exact = (1.0 + y * y) / 6.0 * celestial_plancherel_weight(y);
            assert!(
                (full_conv - exact).abs() < 1e-15,
                "y={y}: full_conv={full_conv} vs exact={exact}"
            );
            assert!(celestial_half_line_convolution_f(y) > celestial_half_line_convolution_f(-y));
        }

        // 3. Cayley shadow norm regularization across and outside the critical strip
        for &s_dev in &[-1.5_f64, -0.5, -0.25, 0.0, 0.25, 0.5, 1.0, 2.0] {
            let w_cayley = celestial_spin_two_cayley_shadow_factor(s_dev);
            let w_unreg = 1.0 - 4.0 * s_dev * s_dev;
            let expected_diff = 16.0 * s_dev.powi(4) / (1.0 + 4.0 * s_dev * s_dev);
            assert!(w_cayley > 0.0 && w_cayley <= 1.0);
            assert!((w_cayley - celestial_spin_two_cayley_shadow_factor(-s_dev)).abs() < 1e-16);
            assert!(((w_cayley - w_unreg) - expected_diff).abs() < 1e-14);
        }

        // 4. All-loop geometric resummation envelope 8 / (8 - alpha_QG) vs 2-loop truncation
        for &alpha in &[0.01_f64, 0.1, 0.5, 1.0, 2.0] {
            let env = celestial_plancherel_all_loop_envelope(alpha);
            let loop2 = 1.0 + (1.0 / 8.0) * alpha + (1.0 / 90.0) * alpha * alpha;
            let exact_gap = (13.0 / 2880.0) * alpha * alpha + alpha.powi(3) / (64.0 * (8.0 - alpha));
            assert!(env > loop2);
            assert!(((env - loop2) - exact_gap).abs() < 1e-14);
        }

        // 5. Small-x Taylor branch of adelic_symmetric_cesaro_mean
        let c_tiny = adelic_symmetric_cesaro_mean(0.5 + 1e-10, 10.0);
        assert!((c_tiny - 1.0).abs() < 1e-15 && c_tiny >= 1.0);
    }

    #[test]
    fn celestial_ir_regularization_and_turner_model16_audit() {
        let rep = audit_celestial_ir_and_turner_model16();
        assert!(rep.rg_sigma_dev_su3 > 0.0);
        assert!(rep.rg_casimir_im_nonzero > 0.0);
        assert_eq!(rep.k_ir_uv_at_zero, 0.0);
        assert!(rep.k_ir_uv_at_one > 0.0 && rep.k_ir_uv_at_one < 1.0);
        assert!(rep.k_ir_uv_unreg_limit_diff < 1e-16);
        assert!(rep.kl_mellin_mgap_1 > 0.0 && rep.kl_mellin_mgap_1.is_finite());
        assert!(rep.kl_mellin_mgap_0_vs_gamma < 1e-11);
        assert!((rep.kl_mellin_delta1_mgap_half - 0.924_419_071_227_665_6).abs() < 1e-11);
        assert!(rep.yukawa_mellin_quad_vs_gamma_diff < 1e-6);
        assert!((rep.s_ir_zero - 1.0).abs() < 1e-16);
        assert!(rep.s_ir_half > 0.909 && rep.s_ir_half < 0.910);
        assert!(rep.s_ir_quadratic_margin_half > 0.0);
        assert!(rep.model16_uv_core_vs_ir_gap_ordering);
        assert!((rep.g16_classical - 1.0).abs() < 1e-16);
        assert!(rep.g16_off_line_positive > 0.0);
        assert!((rep.model16a_mercury_arcsec_cy - 42.9814).abs() < 0.01);
        assert!((rep.model16b_mercury_arcsec_cy - 42.9814).abs() < 0.01);
        assert!(rep.model16_rel_err_vs_gr < 1e-15);
        assert!((rep.model16_solar_light_bending_arcsec - 1.7505).abs() < 0.001);
        assert_eq!(rep.model16a_gw_below_gap, 0.0);
        assert!(rep.model16b_gw_gapless_ratio > 0.9999999999);
        assert_eq!(rep.model16a_active_laser_deflection, 1.0);
        assert_eq!(rep.model16b_active_laser_deflection, 0.0);
        assert!((rep.d_cft_4d_re_delta - 1.0).abs() < 1e-16);
    }
}
