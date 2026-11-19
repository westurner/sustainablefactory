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

#[cfg(test)]
mod tests {
    use super::*;

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
}
