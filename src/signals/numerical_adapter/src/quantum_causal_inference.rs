//! Grassmannian Quantum Causal Inference, Counterfactual Semantics (`arXiv:2302.11783`),
//! Indefinite Causal Order (Quantum Switch), Constructor Theory, Landau vs. QRT Mpemba Effect,
//! and Conditional Landauer / Entropy-Siphoning Audit (`Signals.QuantumCausalInference`).

use crate::{ValidationError, require_finite, require_nonnegative, require_positive};

/// Boltzmann constant $k_B = 1.380649 \times 10^{-23}\text{ J/K}$.
pub const BOLTZMANN_CONSTANT_J_PER_K: f64 = 1.380_649e-23;

/// Chat-specified Boltzmann constant $1.38 \times 10^{-23}\text{ J/K}$ from `lignolux_entropy_siphon_sim.py`
/// (`data/chats/_Quantum Processor and Soliton Discussions  .md`, line 4488).
pub const CHAT_BOLTZMANN_CONSTANT_J_PER_K: f64 = 1.38e-23;

// ============================================================================
// 1. Grassmannian Geometry of Causal Networks, d-Separation, & Pearl Do-Calculus
// ============================================================================

/// Observational transfer weight $C_{\mathrm{obs}} = d + b$ between $X$ and $Y$ in a confounded
/// causal diamond, summing the direct causal edge $d = w_{X \to Y}$ and the backdoor trek
/// $b = w_{U \to X} w_{U \to Y}$ (`Signals.QuantumCausalInference.causalObservationalTransfer`).
#[inline]
pub fn causal_observational_transfer(direct_causal: f64, backdoor_trek: f64) -> f64 {
    direct_causal + backdoor_trek
}

/// Interventional transfer weight $C_{\mathrm{do}} = d$ under Pearl's $\operatorname{do}(X := x)$
/// incoming-edge surgery (`Signals.QuantumCausalInference.causalInterventionalDoTransfer`).
#[inline]
pub fn causal_interventional_do_transfer(direct_causal: f64, _backdoor_trek: f64) -> f64 {
    direct_causal
}

/// Spurious confounding bias $C_{\mathrm{obs}} - C_{\mathrm{do}} = b$
/// (`Signals.QuantumCausalInference.causalConfoundingBias`).
#[inline]
pub fn causal_confounding_bias(direct_causal: f64, backdoor_trek: f64) -> f64 {
    causal_observational_transfer(direct_causal, backdoor_trek)
        - causal_interventional_do_transfer(direct_causal, backdoor_trek)
}

/// Evaluates the $3 \times 3$ acyclic causal transfer matrix $T = I + W + W^2$ of a 3-node DAG
/// ($0 \to 1, 0 \to 2, 1 \to 2$, where node 0 is an upstream confounder $U$, node 1 is treatment $X$,
/// and node 2 is outcome $Y$) both before and after Pearl's $\operatorname{do}(X_i := x_i)$
/// graph surgery (which severs all incoming edges into `do_vertex`).
pub fn causal_dag_do_surgery_3x3(
    w01: f64,
    w02: f64,
    w12: f64,
    do_vertex: usize,
) -> ([[f64; 3]; 3], [[f64; 3]; 3]) {
    let w_obs = [[0.0, w01, w02], [0.0, 0.0, w12], [0.0, 0.0, 0.0]];
    let mut w_do = w_obs;
    if do_vertex < 3 {
        for r in 0..3 {
            w_do[r][do_vertex] = 0.0;
        }
    }
    let eval_transfer = |w: &[[f64; 3]; 3]| -> [[f64; 3]; 3] {
        let mut w2 = [[0.0f64; 3]; 3];
        for i in 0..3 {
            for k in 0..3 {
                for j in 0..3 {
                    w2[i][j] += w[i][k] * w[k][j];
                }
            }
        }
        let mut t = [[0.0f64; 3]; 3];
        for i in 0..3 {
            for j in 0..3 {
                let id_ij = if i == j { 1.0 } else { 0.0 };
                t[i][j] = id_ij + w[i][j] + w2[i][j];
            }
        }
        t
    };
    (eval_transfer(&w_obs), eval_transfer(&w_do))
}

/// Relativistic / DDF lightcone causal interval $1 - \beta^2$, matching the product of squared
/// Plücker channel amplitudes $\|w_A^{\mathbb{C}}\|^2 \|w_B^{\mathbb{C}}\|^2$ on $\mathrm{Gr}_{\mathbb{C}}(2,4)$
/// (`Signals.QuantumCausalInference.causalLightconeInterval`).
#[inline]
pub fn causal_lightcone_interval(beta: f64) -> f64 {
    1.0 - beta * beta
}

// ============================================================================
// 2. Quantum Causal Counterfactuals (arXiv:2302.11783) & the Quantum Switch
// ============================================================================

/// Step 1 (Abduction) of Pearl / Giarmatzi–Costa (`arXiv:2302.11783`) counterfactual semantics:
/// recovers the exogenous background variable $u_E = y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}}$
/// (`Signals.QuantumCausalInference.abducedExogenousState`).
#[inline]
pub fn abduced_exogenous_state(alpha: f64, x_obs: f64, y_obs: f64) -> f64 {
    y_obs - alpha * x_obs
}

/// Steps 2 & 3 (Action & Prediction) of counterfactual semantics:
/// evaluates $Y_{x_{\mathrm{cf}}}(u_E) = \alpha x_{\mathrm{cf}} + (y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}})$
/// (`Signals.QuantumCausalInference.counterfactualStructuralOutcome`).
#[inline]
pub fn counterfactual_structural_outcome(alpha: f64, x_obs: f64, y_obs: f64, x_cf: f64) -> f64 {
    alpha * x_cf + abduced_exogenous_state(alpha, x_obs, y_obs)
}

/// Counterfactual interventional difference $\Delta Y_{\mathrm{cf}} = Y_{x_{\mathrm{cf}}} - Y_{x_{\mathrm{obs}}} = \alpha(x_{\mathrm{cf}} - x_{\mathrm{obs}})$
/// (`Signals.QuantumCausalInference.counterfactualInterventionalDifference`).
#[inline]
pub fn counterfactual_interventional_difference(
    alpha: f64,
    x_obs: f64,
    y_obs: f64,
    x_cf: f64,
) -> f64 {
    counterfactual_structural_outcome(alpha, x_obs, y_obs, x_cf)
        - counterfactual_structural_outcome(alpha, x_obs, y_obs, x_obs)
}

/// Quantum Switch causal-order asymmetry $\delta_{\mathrm{switch}} = \frac{E_+ - E_-}{E_+ + E_-} \in [-1, 1]$
/// (`Signals.QuantumCausalInference.quantumSwitchCausalAsymmetry`).
/// Returns `0.0` if `e_sym + e_anti` is zero to avoid `0.0 / 0.0` NaN on a zero target vector.
#[inline]
pub fn quantum_switch_causal_asymmetry(e_sym: f64, e_anti: f64) -> f64 {
    let denom = e_sym + e_anti;
    if denom.abs() <= 1e-15 {
        0.0
    } else {
        (e_sym - e_anti) / denom
    }
}

/// Oreshkov–Costa–Brukner (2012) / Branciard et al. (2015) causal inequality bounds:
/// returns `(p_causal_separable, p_quantum_indefinite, quantum_advantage)`:
/// - `p_causal_separable = 3/4 = 0.75` (`Signals.QuantumCausalInference.ocbCausalSeparableBound`),
/// - `p_quantum_indefinite = (2 + √2)/4 ≈ 0.85355339` (`Signals.QuantumCausalInference.ocbQuantumIndefiniteBound`),
/// - `quantum_advantage = (√2 - 1)/4 ≈ 0.10355339`.
#[inline]
pub fn ocb_causal_inequality_bounds() -> (f64, f64, f64) {
    let p_causal = 0.75;
    let p_quantum = (2.0 + std::f64::consts::SQRT_2) / 4.0;
    (p_causal, p_quantum, p_quantum - p_causal)
}

/// Evaluates the complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker channel squared norms
/// $(\|w_A^{\mathbb{C}}\|^2, \|w_B^{\mathbb{C}}\|^2) = (1 + \delta_{\mathrm{switch}}, 1 - \delta_{\mathrm{switch}})$
/// and their ratio $\|w_B^{\mathbb{C}}\|^2 / \|w_A^{\mathbb{C}}\|^2 = E_- / E_+$ for a Quantum Switch.
#[inline]
pub fn quantum_switch_gr24_plucker_channels(e_sym: f64, e_anti: f64) -> (f64, f64, f64) {
    let delta = quantum_switch_causal_asymmetry(e_sym, e_anti);
    let w_a_sq = 1.0 + delta;
    let w_b_sq = 1.0 - delta;
    (w_a_sq, w_b_sq, w_b_sq / w_a_sq)
}

/// Evaluates the exact 2-qubit Quantum Switch (Chiribella et al. 2013; Oreshkov, Costa, & Brukner 2012)
/// on a 2D target state `psi = [(re0, im0), (re1, im1)]` and two $2\times 2$ complex unitary gates
/// `u_a` and `u_b` with control qubit prepared in $|+\rangle_c = \frac{|0\rangle + |1\rangle}{\sqrt{2}}$:
/// returns `(e_sym, e_anti, delta_switch)`, where:
/// - `e_sym` $= \frac{1}{4}\|\{U_A, U_B\}\psi\|^2$ is the $|+\rangle_c$ (anticommutator) branch probability,
/// - `e_anti` $= \frac{1}{4}\|[U_B, U_A]\psi\|^2$ is the $|-\rangle_c$ (commutator) branch probability.
pub fn evaluate_quantum_switch_2x2(
    u_a: &[[(f64, f64); 2]; 2],
    u_b: &[[(f64, f64); 2]; 2],
    psi: &[(f64, f64); 2],
) -> (f64, f64, f64) {
    let c_mul = |x: (f64, f64), y: (f64, f64)| -> (f64, f64) {
        (x.0 * y.0 - x.1 * y.1, x.0 * y.1 + x.1 * y.0)
    };
    let c_add = |x: (f64, f64), y: (f64, f64)| -> (f64, f64) { (x.0 + y.0, x.1 + y.1) };
    let c_sub = |x: (f64, f64), y: (f64, f64)| -> (f64, f64) { (x.0 - y.0, x.1 - y.1) };
    let mat_vec = |m: &[[(f64, f64); 2]; 2], v: &[(f64, f64); 2]| -> [(f64, f64); 2] {
        [
            c_add(c_mul(m[0][0], v[0]), c_mul(m[0][1], v[1])),
            c_add(c_mul(m[1][0], v[0]), c_mul(m[1][1], v[1])),
        ]
    };

    // Path A ≺ B: U_B (U_A |ψ⟩)
    let ua_psi = mat_vec(u_a, psi);
    let ub_ua_psi = mat_vec(u_b, &ua_psi);

    // Path B ≺ A: U_A (U_B |ψ⟩)
    let ub_psi = mat_vec(u_b, psi);
    let ua_ub_psi = mat_vec(u_a, &ub_psi);

    let mut e_sym = 0.0f64;
    let mut e_anti = 0.0f64;
    for i in 0..2 {
        let sym_i = c_add(ub_ua_psi[i], ua_ub_psi[i]);
        let anti_i = c_sub(ub_ua_psi[i], ua_ub_psi[i]);
        e_sym += 0.25 * (sym_i.0 * sym_i.0 + sym_i.1 * sym_i.1);
        e_anti += 0.25 * (anti_i.0 * anti_i.0 + anti_i.1 * anti_i.1);
    }
    let delta = quantum_switch_causal_asymmetry(e_sym, e_anti);
    (e_sym, e_anti, delta)
}

/// Real manifold dimension $2 k (d_{\mathrm{in}} d_{\mathrm{out}} - k)$ of the complex Grassmannian
/// $\mathrm{Gr}_{\mathbb{C}}(k, d_{\mathrm{in}} d_{\mathrm{out}})$ parameterizing rank-$k$
/// Choi–Jamiołkowski quantum causal process subspaces
/// (`Signals.QuantumCausalInference.quantumChoiGrassmannianRealDim`).
#[inline]
pub fn quantum_choi_grassmannian_real_dim(k: usize, d_in: usize, d_out: usize) -> usize {
    let n = d_in * d_out;
    if k >= n { 0 } else { 2 * k * (n - k) }
}

// ============================================================================
// 3. Landau Free-Energy vs. Quantum Resource Theory (QRT) Models of Mpemba
// ============================================================================

/// Landau quartic free-energy density $F(\eta, a, b, h) = \frac{1}{2} a \eta^2 + \frac{1}{4} b \eta^4 - h \eta$
/// (`Holtzman & Raz 2022`, `Signals.QuantumCausalInference.landauFreeEnergy`).
#[inline]
pub fn landau_free_energy(eta: f64, a: f64, b: f64, h: f64) -> f64 {
    0.5 * a * eta * eta + 0.25 * b * eta.powi(4) - h * eta
}

/// Two-eigenmode Markovian / Liouvillian relaxation distance from equilibrium at time $t$:
/// $D(t) = a_2 e^{-\lambda_2 t} + a_3 e^{-\lambda_3 t}$ ($0 < \lambda_2 < \lambda_3$)
/// (`Signals.QuantumCausalInference.mpembaTwoModeDistance`).
#[inline]
pub fn mpemba_two_mode_trajectory(a2: f64, a3: f64, lambda2: f64, lambda3: f64, t: f64) -> f64 {
    a2 * (-lambda2 * t).exp() + a3 * (-lambda3 * t).exp()
}

/// Exact Strong Mpemba crossing time $t_{\mathrm{cross}} = \frac{\ln(a_{3,\mathrm{hot}} / a_{2,\mathrm{cold}})}{\lambda_3 - \lambda_2}$
/// when $a_{2,\mathrm{hot}} = 0$ and $a_{3,\mathrm{cold}} = 0$
/// (`Signals.QuantumCausalInference.strongMpembaCrossingTime`).
#[inline]
pub fn strong_mpemba_crossing_time(
    a3_hot: f64,
    a2_cold: f64,
    lambda2: f64,
    lambda3: f64,
) -> Result<f64, ValidationError> {
    require_positive("a3_hot", a3_hot)?;
    require_positive("a2_cold", a2_cold)?;
    require_positive("lambda3 - lambda2", lambda3 - lambda2)?;
    Ok((a3_hot / a2_cold).ln() / (lambda3 - lambda2))
}

/// Constructs the rank-1 orthogonal complement projector
/// $P_{\perp v_2} = \begin{pmatrix} s^2 & -c s \\ -c s & c^2 \end{pmatrix} \in \mathrm{Gr}_{\mathbb{R}}(1, 2)$
/// annihilating the normalized slow Liouvillian eigenmode $v_{\mathrm{slow}} = (c, s)^{\mathsf{T}}$
/// (`Signals.QuantumCausalInference.mpembaProjector00`, `mpembaProjector01`, `mpembaProjector11`)
/// and projects an initial mode-amplitude vector `x = [x0, x1]` onto the Strong Mpemba fast subspace,
/// returning `(projector_2x2, projected_x, slow_mode_overlap_after)`.
pub fn apply_strong_mpemba_gr12_projector(
    c: f64,
    s: f64,
    x: [f64; 2],
) -> Result<([[f64; 2]; 2], [f64; 2], f64), ValidationError> {
    require_finite("c", c)?;
    require_finite("s", s)?;
    require_finite("x[0]", x[0])?;
    require_finite("x[1]", x[1])?;
    let norm_sq = c * c + s * s;
    require_positive("c^2 + s^2", norm_sq)?;
    let inv_norm = 1.0 / norm_sq.sqrt();
    let cn = c * inv_norm;
    let sn = s * inv_norm;
    let p00 = sn * sn;
    let p01 = -cn * sn;
    let p11 = cn * cn;
    let proj = [[p00, p01], [p01, p11]];
    let x_proj = [p00 * x[0] + p01 * x[1], p01 * x[0] + p11 * x[1]];
    let slow_overlap = cn * x_proj[0] + sn * x_proj[1];
    Ok((proj, x_proj, slow_overlap))
}

/// Van der Waals 3D $P\text{--}V\text{--}T$ equation-of-state pressure
/// $P_{\mathrm{vdW}}(R, T, V, b_{\mathrm{cov}}, a_{\mathrm{attr}}) = \frac{R T}{V - b_{\mathrm{cov}}} - \frac{a_{\mathrm{attr}}}{V^2}$
/// (`_Mpemba Effect_ Landau vs. Quantum .md`, lines 140–180;
/// `Signals.QuantumCausalInference.vanDerWaalsPressure`).
pub fn van_der_waals_pressure(
    r_gas: f64,
    temp_k: f64,
    volume: f64,
    b_covolume: f64,
    a_attraction: f64,
) -> Result<f64, ValidationError> {
    require_positive("r_gas", r_gas)?;
    require_finite("temp_k", temp_k)?;
    require_positive("volume", volume)?;
    require_positive("volume - b_covolume", volume - b_covolume)?;
    require_finite("a_attraction", a_attraction)?;
    Ok((r_gas * temp_k) / (volume - b_covolume) - a_attraction / (volume * volume))
}

/// Piecewise molar volume of water across the freezing boundary $T_{\mathrm{freeze}}$, capturing
/// water's anomalous expansion ("the Ice Hump", $\Delta V_{\mathrm{ice}} > 0$ for $T < T_{\mathrm{freeze}}$;
/// `Signals.QuantumCausalInference.waterAnomalousFreezingVolume`).
#[inline]
pub fn water_anomalous_freezing_volume(
    v_liquid: f64,
    delta_v_ice: f64,
    temp_k: f64,
    t_freeze_k: f64,
) -> f64 {
    if temp_k < t_freeze_k {
        v_liquid + delta_v_ice
    } else {
        v_liquid
    }
}

/// Temperature-dependent quadratic Landau coefficient $a(T) = a_0 (T - T_c)$ across critical
/// phase-transition temperature $T_c$ (`Holtzman & Raz 2022`;
/// `Signals.QuantumCausalInference.landauOrderCoeff`).
#[inline]
pub fn landau_order_coeff(a0: f64, temp_k: f64, t_critical_k: f64) -> f64 {
    a0 * (temp_k - t_critical_k)
}

/// Metastable hilltop-to-valley activation barrier height
/// $\Delta F_{\mathrm{barrier}}(T) = F(0, T) - F(\eta_\pm, T) = \frac{a_0^2 (T - T_c)^2}{4 b}$
/// in the symmetry-broken multi-phase regime $T < T_c$ (`Holtzman & Raz 2022`;
/// `Signals.QuantumCausalInference.landauDoubleWellBarrierHeight`).
pub fn landau_double_well_barrier_height(
    a0: f64,
    temp_k: f64,
    t_critical_k: f64,
    b_quartic: f64,
) -> Result<f64, ValidationError> {
    require_positive("a0", a0)?;
    require_finite("temp_k", temp_k)?;
    require_finite("t_critical_k", t_critical_k)?;
    require_positive("b_quartic", b_quartic)?;
    let a_t = landau_order_coeff(a0, temp_k, t_critical_k);
    Ok((a_t * a_t) / (4.0 * b_quartic))
}

/// Quantum Resource Theory (QRT) non-equilibrium free-energy difference
/// $\Delta F(\rho \| \gamma_\beta) = k_B T \ln 2 \cdot D_{\mathrm{KL}}(\rho \| \gamma_\beta)$
/// (`Summer et al. 2026`, `Signals.QuantumCausalInference.qrtNonEquilibriumFreeEnergy`).
#[inline]
pub fn qrt_nonequilibrium_free_energy(kbt_ln2: f64, relative_entropy_bits: f64) -> f64 {
    kbt_ln2 * relative_entropy_bits
}

/// Resource-theoretic Mpemba / entropy-siphon majorization shortcut gap
/// $\Delta D_{\mathrm{QRT}} = D_{\mathrm{alone}} - D_{\mathrm{siphon}}$
/// (`Signals.QuantumCausalInference.qrtMajorizationShortcutGap`).
#[inline]
pub fn qrt_majorization_shortcut_gap(d_alone: f64, d_siphon: f64) -> f64 {
    d_alone - d_siphon
}

/// Evaluates the exact Kullback–Leibler relative entropy $D_{\mathrm{KL}}(p \| \gamma)$ (in bits)
/// between a discrete state distribution `p` and the thermal Gibbs state `gibbs`, quantifying
/// the QRT athermality resource (`Summer et al. 2026 PRX`).
pub fn qrt_kl_divergence_bits(p: &[f64], gibbs: &[f64]) -> Result<f64, ValidationError> {
    if p.is_empty() || gibbs.is_empty() {
        return Err(ValidationError::EmptyDataset);
    }
    if p.len() != gibbs.len() {
        return Err(ValidationError::ShapeMismatch("p vs gibbs length"));
    }
    let mut kl = 0.0f64;
    for (&pi, &gi) in p.iter().zip(gibbs.iter()) {
        require_nonnegative("p_i", pi)?;
        require_positive("gibbs_i", gi)?;
        if pi > 1e-15 {
            kl += pi * (pi / gi).log2();
        }
    }
    Ok(kl)
}

/// Checks whether state `p` **thermo-majorizes** state `q` ($p \succ_{\mathrm{th}} q$) relative to
/// the thermal Gibbs distribution `gibbs` (`Horodecki & Oppenheim 2013`; `Summer et al. 2026 PRX`)
/// by β-ordering both distributions in descending order of $p_i / \gamma_i$ and $q_i / \gamma_i$
/// and verifying that the piecewise-linear Lorenz curve $L_p(x)$ lies on or above $L_q(x)$ at all
/// cumulative Gibbs breakpoints.
pub fn thermo_majorization_dominates(
    p: &[f64],
    q: &[f64],
    gibbs: &[f64],
    tol: f64,
) -> Result<bool, ValidationError> {
    if p.is_empty() || q.is_empty() || gibbs.is_empty() {
        return Err(ValidationError::EmptyDataset);
    }
    if p.len() != q.len() || p.len() != gibbs.len() {
        return Err(ValidationError::ShapeMismatch("p, q, gibbs length"));
    }
    let n = p.len();
    let mut idx_p: Vec<usize> = (0..n).collect();
    let mut idx_q: Vec<usize> = (0..n).collect();
    let mut sum_p = 0.0f64;
    let mut sum_q = 0.0f64;
    let mut sum_g = 0.0f64;
    for i in 0..n {
        require_nonnegative("p_i", p[i])?;
        require_nonnegative("q_i", q[i])?;
        require_positive("gibbs_i", gibbs[i])?;
        sum_p += p[i];
        sum_q += q[i];
        sum_g += gibbs[i];
    }
    let norm_tol = tol.max(1e-9);
    if (sum_p - sum_q).abs() > norm_tol || (sum_p - sum_g).abs() > norm_tol {
        return Err(ValidationError::ResidualTooLarge(
            "thermo_majorization distributions must have matching total probability mass",
        ));
    }
    idx_p.sort_by(|&a, &b| {
        let ra = p[a] / gibbs[a];
        let rb = p[b] / gibbs[b];
        rb.total_cmp(&ra)
    });
    idx_q.sort_by(|&a, &b| {
        let ra = q[a] / gibbs[a];
        let rb = q[b] / gibbs[b];
        rb.total_cmp(&ra)
    });

    let build_curve = |idx: &[usize], dist: &[f64]| -> Vec<(f64, f64)> {
        let mut pts = Vec::with_capacity(n + 1);
        pts.push((0.0, 0.0));
        let mut x = 0.0;
        let mut y = 0.0;
        for &k in idx {
            x += gibbs[k];
            y += dist[k];
            pts.push((x, y));
        }
        pts
    };

    let curve_p = build_curve(&idx_p, p);
    let curve_q = build_curve(&idx_q, q);

    let eval_lorenz = |curve: &[(f64, f64)], x: f64| -> f64 {
        if x <= 0.0 {
            return 0.0;
        }
        for w in curve.windows(2) {
            let (x0, y0) = w[0];
            let (x1, y1) = w[1];
            if x <= x1 + 1e-15 {
                let dx = x1 - x0;
                if dx.abs() <= 1e-15 {
                    return y1;
                }
                let t = ((x - x0) / dx).clamp(0.0, 1.0);
                return y0 + t * (y1 - y0);
            }
        }
        curve.last().unwrap().1
    };

    for &(xq, yq) in &curve_q {
        let yp = eval_lorenz(&curve_p, xq);
        if yp + tol < yq {
            return Ok(false);
        }
    }
    for &(xp, yp) in &curve_p {
        let yq = eval_lorenz(&curve_q, xp);
        if yp + tol < yq {
            return Ok(false);
        }
    }
    Ok(true)
}

// ============================================================================
// 4. Constructor Theory Task Algebra (Deutsch & Marletto)
// ============================================================================

/// A Constructor Theory thermodynamic/information task $\mathcal{T} = \{i \to o\}$
/// (`Signals.QuantumCausalInference.ConstructorTask`).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct ConstructorTask {
    pub delta_system_entropy_bits: f64,
    pub work_supplied_joules: f64,
    pub side_info_resource_bits: f64,
}

impl ConstructorTask {
    /// Net thermodynamic free-energy surplus (in joules):
    /// $\Sigma_{\mathrm{task}} = W_{\mathrm{supplied}} + k_B T \ln 2 \cdot (\Delta S_{\mathrm{sys}} + I_{\mathrm{side}})$
    /// (`ConstructorTask.thermodynamicSurplus`).
    #[inline]
    pub fn thermodynamic_surplus(&self, kbt_ln2: f64) -> f64 {
        self.work_supplied_joules
            + kbt_ln2 * (self.delta_system_entropy_bits + self.side_info_resource_bits)
    }

    /// Whether the task is thermodynamically possible ($\Sigma_{\mathrm{task}} \ge 0$)
    /// (`ConstructorTask.isPossible`).
    #[inline]
    pub fn is_possible(&self, kbt_ln2: f64) -> bool {
        self.thermodynamic_surplus(kbt_ln2) >= 0.0
    }

    /// Serial/parallel composition of two Constructor Theory tasks (`ConstructorTask.compose`).
    #[inline]
    pub fn compose(&self, other: &Self) -> Self {
        Self {
            delta_system_entropy_bits: self.delta_system_entropy_bits
                + other.delta_system_entropy_bits,
            work_supplied_joules: self.work_supplied_joules + other.work_supplied_joules,
            side_info_resource_bits: self.side_info_resource_bits + other.side_info_resource_bits,
        }
    }
}

// ============================================================================
// 5. Conditional Landauer Erasure (del Rio et al. 2011) & Entropy Siphoning Audit
// ============================================================================

/// Linearized conditional von Neumann entropy $S(A \mid O) = 1 - 2 F$ (in bits) for a two-Bell
/// mixture $F|\Phi^+\rangle\langle\Phi^+| + (1-F)|0\rangle\langle 0|\otimes \frac{I}{2}$
/// (`Signals.QuantumCausalInference.conditionalEntropyLinearBits`).
#[inline]
pub fn conditional_entropy_linear_bits(fidelity: f64) -> f64 {
    1.0 - 2.0 * fidelity
}

/// Exact von Neumann conditional entropy $S(A \mid O)_{\mathrm{Werner}} = S(\rho_{AO}) - S(\rho_O)$
/// (in bits) of an isotropic 2-qubit Werner state
/// $\rho_W(F) = F|\Phi^+\rangle\langle\Phi^+| + \frac{1-F}{3}(I_4 - |\Phi^+\rangle\langle\Phi^+|)$
/// with Bell fidelity $F \in [0, 1]$ (`del Rio et al. 2011`, *Nature* 474, 61–63).
/// Note that for an isotropic Werner state, $S(A\mid O)_{\mathrm{Werner}} < 0$ requires
/// Bell singlet fidelity $F > F_* \approx 0.810710$ (Werner visibility $p > p_* \approx 0.747614$),
/// whereas the chat's linear formula $1 - 2F$ assumes a rank-2 mixture with zero-crossing at $F = 0.5$.
pub fn exact_werner_conditional_entropy_bits(fidelity: f64) -> Result<f64, ValidationError> {
    require_finite("fidelity", fidelity)?;
    if !(0.0..=1.0).contains(&fidelity) {
        return Err(ValidationError::ResidualTooLarge("fidelity out of [0, 1]"));
    }
    let eigs = [
        fidelity,
        (1.0 - fidelity) / 3.0,
        (1.0 - fidelity) / 3.0,
        (1.0 - fidelity) / 3.0,
    ];
    let mut s_ao = 0.0f64;
    for &lam in &eigs {
        if lam > 1e-15 {
            s_ao -= lam * lam.log2();
        }
    }
    // Reduced state \rho_O = I_2 / 2 has S(\rho_O) = 1 bit
    Ok(s_ao - 1.0)
}

/// Converts isotropic 2-qubit Werner visibility $p \in [-1/3, 1]$ in
/// $\rho_W(p) = p|\Phi^+\rangle\langle\Phi^+| + (1-p)\frac{I_4}{4}$ to Bell singlet fidelity
/// $F = \langle\Phi^+|\rho_W(p)|\Phi^+\rangle = \frac{3p + 1}{4}$
/// (`Signals.QuantumCausalInference.wernerFidelityFromVisibility`).
#[inline]
pub fn werner_fidelity_from_visibility(p: f64) -> f64 {
    (3.0 * p + 1.0) / 4.0
}

/// Converts Bell singlet fidelity $F \in [0, 1]$ to isotropic 2-qubit Werner visibility
/// $p = \frac{4F - 1}{3}$ (`Signals.QuantumCausalInference.wernerVisibilityFromFidelity`).
#[inline]
pub fn werner_visibility_from_fidelity(fidelity: f64) -> f64 {
    (4.0 * fidelity - 1.0) / 3.0
}

/// Computes the exact Bell fidelity threshold $F_* \approx 0.8107103750847682$ (corresponding to
/// Werner visibility $p_* = \frac{4 F_* - 1}{3} \approx 0.7476138334463576$) at which the
/// isotropic 2-qubit Werner state conditional von Neumann entropy $S(A \mid O)_{\mathrm{Werner}}(F_*)$
/// crosses zero (`exact_werner_conditional_entropy_bits(F_*) == 0.0`).
/// Above $F_*$, single-shot conditional Landauer erasure extracts heat ($Q < 0$);
/// for $0.5 < F < F_*$, the chat's linear proxy $1 - 2F < 0$ falsely predicts cooling whereas
/// the isotropic Werner state actually dissipates heat ($S(A\mid O)_{\mathrm{Werner}}(F) > 0$).
pub fn werner_cooling_threshold_fidelity() -> f64 {
    let mut lo = 0.5f64;
    let mut hi = 1.0f64;
    for _ in 0..80 {
        let mid = 0.5 * (lo + hi);
        let s = exact_werner_conditional_entropy_bits(mid).unwrap_or(0.0);
        if s > 0.0 {
            lo = mid;
        } else {
            hi = mid;
        }
    }
    0.5 * (lo + hi)
}

/// Exact isotropic 2-qubit Werner conditional Landauer heat
/// $Q_{\mathrm{Werner}}(F) = k_B T \ln 2 \cdot S(A \mid O)_{\mathrm{Werner}}(F)$.
pub fn del_rio_werner_conditional_landauer_heat(
    kbt_ln2: f64,
    fidelity: f64,
) -> Result<f64, ValidationError> {
    require_finite("kbt_ln2", kbt_ln2)?;
    let s_bits = exact_werner_conditional_entropy_bits(fidelity)?;
    Ok(kbt_ln2 * s_bits)
}

/// Conditional Landauer heat dissipated into the bath per 1-bit reset (`del Rio et al. 2011`):
/// $Q_{\mathrm{erasure}}(F) = k_B T \ln 2 \cdot (1 - 2 F)$
/// (`Signals.QuantumCausalInference.delRioConditionalLandauerHeat`).
#[inline]
pub fn del_rio_conditional_landauer_heat(kbt_ln2: f64, fidelity: f64) -> f64 {
    kbt_ln2 * conditional_entropy_linear_bits(fidelity)
}

/// Interventional counterfactual heat difference $\mathcal{Q}^* = Q(\operatorname{do}(F = f_{\mathrm{active}})) - Q(\operatorname{do}(F = f_{\mathrm{control}}))$
/// (`Signals.QuantumCausalInference.entropySiphonCounterfactualGain`).
#[inline]
pub fn entropy_siphon_counterfactual_gain(kbt_ln2: f64, f_active: f64, f_control: f64) -> f64 {
    del_rio_conditional_landauer_heat(kbt_ln2, f_active)
        - del_rio_conditional_landauer_heat(kbt_ln2, f_control)
}

/// Closed-loop net heat across single-shot entangled erasure of $A$ plus subsequent Landauer
/// reset of the observer memory $O$ (`Signals.QuantumCausalInference.closedLoopErasureAndMemoryResetHeat`).
#[inline]
pub fn closed_loop_erasure_and_memory_reset_heat(
    kbt_ln2: f64,
    fidelity: f64,
    q_overhead: f64,
) -> f64 {
    del_rio_conditional_landauer_heat(kbt_ln2, fidelity) + (2.0 * fidelity * kbt_ln2 + q_overhead)
}

/// Evaluates the chat's `lignolux_entropy_siphon_sim.py` cooling power (in watts)
/// (`Signals.QuantumCausalInference.lignoluxTapeSiphonPowerWatts`).
#[inline]
pub fn lignolux_tape_siphon_power_watts(
    t_kelvin: f64,
    fidelity: f64,
    n_ancillas: f64,
    f_qec_hz: f64,
) -> f64 {
    let kbt_ln2 = CHAT_BOLTZMANN_CONSTANT_J_PER_K * t_kelvin * std::f64::consts::LN_2;
    del_rio_conditional_landauer_heat(kbt_ln2, fidelity) * n_ancillas * f_qec_hz
}

// ============================================================================
// 6. JEV vs. QCDT Decision Models, Zhang (2025) Grassmann Flows, De Clercq (2026)
//    Tautological Bundle-Transformers, and Spatiotemporal VideoGen
// ============================================================================

/// Jeffrey Expected Value (`JEV`, Jeffrey 1965) over a binary state partition
/// conditioned observationally on action/token $A$: $P(s_1 \mid A) u_1 + P(s_2 \mid A) u_2$.
#[must_use]
pub fn jev_evidential_expected_utility(p_cond_1: f64, p_cond_2: f64, u1: f64, u2: f64) -> f64 {
    p_cond_1 * u1 + p_cond_2 * u2
}

/// Causal Expected Value (`CEV`, Pearl 2000; Joyce 1999) under interventional
/// incoming-edge surgery $\operatorname{do}(A)$: $P(s_1 \mid \operatorname{do}(A)) u_1 + P(s_2 \mid \operatorname{do}(A)) u_2$.
#[must_use]
pub fn cev_causal_do_expected_utility(p_do_1: f64, p_do_2: f64, u1: f64, u2: f64) -> f64 {
    p_do_1 * u1 + p_do_2 * u2
}

/// Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Plücker interference / Yukalov-Sornette
/// quantum decision attraction term $q_{\mathrm{Pl\ddot{u}cker}} = 2(w_{A,\mathrm{re}} w_{B,\mathrm{re}} + w_{A,\mathrm{im}} w_{B,\mathrm{im}})$.
#[must_use]
pub fn qcdt_plucker_interference_term(w_a_re: f64, w_a_im: f64, w_b_re: f64, w_b_im: f64) -> f64 {
    2.0 * (w_a_re * w_b_re + w_a_im * w_b_im)
}

/// Quantum Causal Decision Theory (`QCDT`) expected utility combining Pearl's $\operatorname{do}(A)$
/// distribution with a zero-sum Complex Grassmannian Plücker interference shift $q_{\mathrm{int}}$.
#[must_use]
pub fn qcdt_quantum_causal_expected_utility(
    p_do_1: f64,
    p_do_2: f64,
    q_int: f64,
    u1: f64,
    u2: f64,
) -> f64 {
    (p_do_1 + q_int) * u1 + (p_do_2 - q_int) * u2
}

/// Jevons (1865/1871) effective compute/energy cost per token $c_0 / \eta_{\mathrm{eff}}$
/// and total compute energy $E_{\mathrm{total}} = (c_0 / \eta_{\mathrm{eff}}) D_0 \eta_{\mathrm{eff}} (1 + \varepsilon_{\mathrm{ex}})$.
pub fn jevons_total_compute_energy(
    c0: f64,
    eta_eff: f64,
    d0: f64,
    elasticity_excess: f64,
) -> Result<f64, ValidationError> {
    require_positive("eta_eff", eta_eff)?;
    let eff_cost = c0 / eta_eff;
    let demand = d0 * eta_eff * (1.0 + elasticity_excess);
    Ok(eff_cost * demand)
}

/// Pairwise Plücker coordinate dimension $\binom{r}{2} = r(r - 1)/2$ for $\mathrm{Gr}(2, r)$
/// (`Zhang 2025`, `arXiv:2512.19428`, Section 2.2 & 3.2).
#[must_use]
pub const fn plucker_pair_dimension(r: usize) -> usize {
    (r * r.saturating_sub(1)) / 2
}

/// Parameter count of a `MultiHeadAttention` sub-block in `kanenorman/grassmann` (`README.md`, lines 125-136).
#[must_use]
pub const fn multi_head_attention_block_params(d: usize) -> usize {
    2 * d + (3 * d * d + 3 * d) + (d * d + d)
}

/// Parameter count of a `GrassmannMixing` sub-block in `kanenorman/grassmann` (`README.md`, lines 138-150).
#[must_use]
pub const fn kanenorman_grassmann_block_params(d: usize, r: usize) -> usize {
    let d_plucker = plucker_pair_dimension(r);
    2 * d + (d * r + r) + (d_plucker * d + d) + (2 * d * d + d)
}

/// Convex gated fusion $\alpha h + (1 - \alpha) g$ (`Zhang 2025`, `arXiv:2512.19428`, Section 3.2.5).
#[must_use]
pub fn zhang_convex_gated_fusion(alpha: f64, h: f64, g: f64) -> f64 {
    alpha * h + (1.0 - alpha) * g
}

/// Additive gated residual $h + \alpha g$ (`kanenorman/grassmann/model.py`, lines 116-117, 163-176).
#[must_use]
pub fn kanenorman_additive_gated_residual(alpha: f64, h: f64, g: f64) -> f64 {
    h + alpha * g
}

/// Pairwise $2 \times 2$ Plücker minor $p_{ij}(z_{\mathrm{curr}}, z_{\mathrm{past}}) = z_{c,i} z_{p,j} - z_{c,j} z_{p,i}$.
#[must_use]
pub fn plucker_2d_coord(z_curr_i: f64, z_curr_j: f64, z_past_i: f64, z_past_j: f64) -> f64 {
    z_curr_i * z_past_j - z_curr_j * z_past_i
}

/// Computes the normalized Plücker feature vector $\hat{p} \in \mathbb{R}^{\binom{r}{2}}$
/// for a pair of reduced token states $(z_{\mathrm{curr}}, z_{\mathrm{past}}) \in \mathbb{R}^r \times \mathbb{R}^r$
/// (`Zhang 2025`, `arXiv:2512.19428`, Section 3.2.3).
pub fn causal_grassmann_plucker_vector(
    z_curr: &[f64],
    z_past: &[f64],
    eps: f64,
) -> Result<Vec<f64>, ValidationError> {
    if z_curr.len() != z_past.len() || z_curr.len() < 2 {
        return Err(ValidationError::ShapeMismatch(
            "z_curr and z_past must have equal length >= 2",
        ));
    }
    require_positive("eps", eps)?;
    let r = z_curr.len();
    let mut plucker = Vec::with_capacity(plucker_pair_dimension(r));
    let mut norm_sq = 0.0;
    for i in 0..r {
        for j in (i + 1)..r {
            let p_ij = plucker_2d_coord(z_curr[i], z_curr[j], z_past[i], z_past[j]);
            norm_sq += p_ij * p_ij;
            plucker.push(p_ij);
        }
    }
    let scale = norm_sq.sqrt().max(eps);
    for p in &mut plucker {
        *p /= scale;
    }
    Ok(plucker)
}

/// Squared chordal distance $d_{\mathrm{chord}}(Z_1, Z_2)^2 = k - \|Z_1^\top Z_2\|_F^2$
/// on $\mathrm{Gr}(k, n)$ (`De Clercq 2026`, *Bundle-Transformer*, Section 2.1).
#[must_use]
pub fn grassmann_chordal_dist_sq(k: f64, frob_overlap_sq: f64) -> f64 {
    k - frob_overlap_sq
}

/// Concept similarity score $s_{ij}^{\mathrm{concept}} = \gamma \exp(-d_{\mathrm{chord}}(Z_i, Z_j)^2 / \sigma)$
/// (`De Clercq 2026`, Section 3.2).
#[must_use]
pub fn bundle_concept_similarity(gamma: f64, k: f64, frob_overlap_sq: f64, sigma: f64) -> f64 {
    gamma * (-grassmann_chordal_dist_sq(k, frob_overlap_sq) / sigma).exp()
}

/// Hybrid Bundle-Transformer attention score $s_{ij} = \lambda_{\mathrm{inst}} s_{ij}^{\mathrm{inst}} + \lambda_{\mathrm{concept}} s_{ij}^{\mathrm{concept}}$
/// (`De Clercq 2026`, Section 3.2).
#[must_use]
pub fn bundle_hybrid_attention_score(
    lam_inst: f64,
    s_inst: f64,
    lam_concept: f64,
    s_concept: f64,
) -> f64 {
    lam_inst * s_inst + lam_concept * s_concept
}

/// A 2D tautological bundle token $(Z, v) \in \mathcal{T} \to \mathrm{Gr}_{\mathbb{R}}(1, 2)$,
/// where $Z = (c, s)^\top$ ($c^2 + s^2 = 1$) is the orthonormal concept frame and
/// $v = Z\alpha = (c\alpha, s\alpha)^\top \in Z$ is the contextual instance vector
/// (`De Clercq 2026`, *Bundle-Transformer*, Sections 2.2 & 3.1-3.4).
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct TautologicalBundleToken2D {
    pub z_c: f64,
    pub z_s: f64,
    pub alpha: f64,
}

impl TautologicalBundleToken2D {
    /// Encodes a raw rank-1 direction $(m_x, m_y)$ and fiber coordinate $\alpha$ via QR normalization.
    pub fn from_qr_1d(m_x: f64, m_y: f64, alpha: f64) -> Result<Self, ValidationError> {
        let norm = (m_x * m_x + m_y * m_y).sqrt();
        require_positive("subspace_column_norm", norm)?;
        Ok(Self {
            z_c: m_x / norm,
            z_s: m_y / norm,
            alpha,
        })
    }

    /// Ambient contextual instance vector $v = Z \alpha \in Z \subset \mathbb{R}^2$.
    #[must_use]
    pub fn instance_vec(&self) -> [f64; 2] {
        [self.z_c * self.alpha, self.z_s * self.alpha]
    }

    /// Projects an arbitrary ambient vector $(x, y) \in \mathbb{R}^2$ onto the fiber subspace $Z$:
    /// $\Pi_Z(w) = Z Z^\top w$.
    #[must_use]
    pub fn project_onto_fiber(&self, x: f64, y: f64) -> [f64; 2] {
        let dot = self.z_c * x + self.z_s * y;
        [self.z_c * dot, self.z_s * dot]
    }

    /// Squared chordal distance $d_{\mathrm{chord}}(Z_1, Z_2)^2 = 1 - (Z_1^\top Z_2)^2 \in [0, 1]$.
    #[must_use]
    pub fn chordal_dist_sq(&self, other: &Self) -> f64 {
        let dot = self.z_c * other.z_c + self.z_s * other.z_s;
        grassmann_chordal_dist_sq(1.0, dot * dot)
    }

    /// Applies shared linear transport $A \in \mathbb{R}^{2 \times 2}$ simultaneously to the
    /// concept subspace $Z^{\mathrm{new}} = \operatorname{QR}(A Z)$ and instance $\tilde{v} = A v \in Z^{\mathrm{new}}$
    /// (`De Clercq 2026`, Section 3.4 Step 1).
    pub fn linear_transport_2x2(
        &self,
        a00: f64,
        a01: f64,
        a10: f64,
        a11: f64,
    ) -> Result<Self, ValidationError> {
        let az_x = a00 * self.z_c + a01 * self.z_s;
        let az_y = a10 * self.z_c + a11 * self.z_s;
        let r_norm = (az_x * az_x + az_y * az_y).sqrt();
        require_positive("transported_subspace_norm", r_norm)?;
        // Since A v = A (Z alpha) = (A Z) alpha = (Z_new * r_norm) * alpha = Z_new * (r_norm * alpha),
        // the transported vector lies identically in Z_new with fiber coordinate r_norm * alpha!
        Ok(Self {
            z_c: az_x / r_norm,
            z_s: az_y / r_norm,
            alpha: r_norm * self.alpha,
        })
    }
}

/// Fiber-preserving Rotary Position Embedding (`RoPE`) coordinate rotation in $\mathbb{R}^2$
/// (`Su et al. 2021`, `arXiv:2104.09864`; `De Clercq 2026`, Section 3.3).
#[must_use]
pub fn rope_fiber_rotate(cos_t: f64, sin_t: f64, a1: f64, a2: f64) -> [f64; 2] {
    [cos_t * a1 - sin_t * a2, sin_t * a1 + cos_t * a2]
}

/// Quadratic 3D spatiotemporal video self-attention complexity $(T H W)^2 d_{\mathrm{head}}$.
#[must_use]
pub fn spatiotemporal_full_attention_complexity(t: f64, h: f64, w: f64, d_head: f64) -> f64 {
    let l = t * h * w;
    l * l * d_head
}

/// Linear-in-volume 3D spatiotemporal Causal Grassmann video complexity $(T H W) m_{\mathrm{lags}} d_{\mathrm{pl\ddot{u}cker}}$.
#[must_use]
pub fn spatiotemporal_grassmann_video_complexity(
    t: f64,
    h: f64,
    w: f64,
    m_lags: f64,
    d_plucker: f64,
) -> f64 {
    (t * h * w) * m_lags * d_plucker
}

/// Kapitza thermal relaxation time $t_{\mathrm{cool}} = R_K C_v d_{\mathrm{thick}}$ for an
/// `rGO-Vitrimer` / `A-CNT` QRAM soliton steering metasurface (`_LLMs, Fourier, and Quantum Logic .md`, lines 660-685).
#[must_use]
pub fn rgo_vitrimer_kapitza_cool_time(r_k: f64, c_v: f64, d_thick: f64) -> f64 {
    r_k * c_v * d_thick
}

/// 4D Plücker Klein quadric decomposability residual
/// $\mathcal{Q}_4 = p_{01} p_{23} - p_{02} p_{13} + p_{03} p_{12}$.
/// Equals $0$ for any rank-2 decomposable blade (including any shared-anchor multi-lag sum)
/// and equals $c_1 c_{12} \neq 0$ for a rank-4 cross-lag superposition $c_1(e_0\wedge e_1) + c_{12}(e_2\wedge e_3)$.
#[must_use]
pub fn plucker_quadric_4d_residual(
    p01: f64,
    p02: f64,
    p03: f64,
    p12: f64,
    p13: f64,
    p23: f64,
) -> f64 {
    p01 * p23 - p02 * p13 + p03 * p12
}

/// Cross-frame inner product $\langle u, \operatorname{diag}(1, \sigma_2) w \rangle = u_0 w_0 + \sigma_2 u_1 w_1$
/// between two 2D fiber vectors evaluated across concept subspaces $Z_i, Z_j \in \mathrm{Gr}(2, n)$
/// with principal singular value $\sigma_2$.
#[must_use]
pub fn rope_cross_frame_inner_product(u: [f64; 2], w: [f64; 2], sigma2: f64) -> f64 {
    u[0] * w[0] + sigma2 * u[1] * w[1]
}

/// Total latency $T_{\mathrm{total}} = T_{\mathrm{prep}} + T_{\mathrm{QFT}}$ of a QFT Holographic
/// Associative Memory lookup (`_LLMs, Fourier, and Quantum Logic .md`, lines 20-23, 81-83).
#[must_use]
pub fn qft_associative_total_latency(t_prep: f64, t_qft: f64) -> f64 {
    t_prep + t_qft
}

/// Transverse linear momentum $k_y = \ell / a_{\mathrm{scale}}$ produced by a log-polar OAM unwrapper
/// (`_LLMs, Fourier, and Quantum Logic .md`, lines 509-548).
pub fn oam_log_polar_transverse_momentum(
    l_charge: f64,
    a_scale: f64,
) -> Result<f64, ValidationError> {
    require_positive("a_scale", a_scale)?;
    Ok(l_charge / a_scale)
}

// ============================================================================
// 8. Beyond 6,400x Splat-Grassmann Volumetric Efficiency, Jeffrey's Kinematic Engine,
//    3D Volumetric Splat Nanoimaging/Surgery, and Quantum Causal Semantic GraphRAG
// ============================================================================

/// Spatiotemporal FLOP complexity $N_{\mathrm{splats}} \cdot m_{\mathrm{lags}} \cdot d_{\mathrm{pl\ddot{u}cker}}$
/// of adaptive 3D Normed Tensor Gaussian Splat (`NormedTensorGaussianSplat3D`) Grassmannian mixing
/// (`Signals.QuantumCausalInference.splatSparseGrassmannVideoComplexity`).
#[must_use]
pub fn splat_sparse_grassmann_video_complexity(
    n_splats: f64,
    m_lags: f64,
    d_plucker: f64,
) -> f64 {
    n_splats * m_lags * d_plucker
}

/// Dimensionless volumetric attention efficiency gain ratio
/// $\eta_{\mathrm{vol}} = \frac{(T \cdot H \cdot W)^2 d_{\mathrm{head}}}{N_{\mathrm{splats}} \cdot m_{\mathrm{lags}} \cdot d_{\mathrm{pl\ddot{u}cker}}}$
/// measuring the exact speedup of splat-sparse Grassmannian mixing over dense 3D spatiotemporal
/// self-attention (`Signals.QuantumCausalInference.volumetricAttentionEfficiencyRatio`).
pub fn volumetric_attention_efficiency_ratio(
    t: f64,
    h: f64,
    w: f64,
    d_head: f64,
    n_splats: f64,
    m_lags: f64,
    d_plucker: f64,
) -> Result<f64, ValidationError> {
    require_positive("n_splats", n_splats)?;
    require_positive("m_lags", m_lags)?;
    require_positive("d_plucker", d_plucker)?;
    let num = spatiotemporal_full_attention_complexity(t, h, w, d_head);
    let den = splat_sparse_grassmann_video_complexity(n_splats, m_lags, d_plucker);
    Ok(num / den)
}

/// Richard Jeffrey's Probability Kinematics (`Jeffrey's Rule`, Jeffrey 1965) two-partition update
/// $Q(S) = q_1 c_1 + q_2 c_2$ (`Signals.QuantumCausalInference.jeffreyKinematicUpdate`).
#[must_use]
pub fn jeffrey_kinematic_update(q1: f64, q2: f64, c1: f64, c2: f64) -> f64 {
    q1 * c1 + q2 * c2
}

/// Kinematic shift $\Delta Q(S) = Q(S) - P(S) = (q_1 - p_1) c_1 + (q_2 - p_2) c_2$
/// induced by Jeffrey's Kinematic Engine (`Signals.QuantumCausalInference.jeffreyKinematicShift`).
#[must_use]
pub fn jeffrey_kinematic_shift(p1: f64, p2: f64, q1: f64, q2: f64, c1: f64, c2: f64) -> f64 {
    (q1 - p1) * c1 + (q2 - p2) * c2
}

/// Quantum Causal / Lüders–Plücker Kinematic Update (`Quantum Jeffrey Kinematics`)
/// $Q_{\mathrm{QJE}}(S) = q_1 c_1 + q_2 c_2 + \gamma_{\mathrm{coh}} \cdot I_{\mathrm{Pl\ddot{u}cker}}$
/// (`Signals.QuantumCausalInference.quantumJeffreyPluckerKinematicUpdate`).
#[must_use]
pub fn quantum_jeffrey_plucker_kinematic_update(
    q1: f64,
    q2: f64,
    c1: f64,
    c2: f64,
    gamma_coh: f64,
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    jeffrey_kinematic_update(q1, q2, c1, c2)
        + gamma_coh * qcdt_plucker_interference_term(wa_re, wa_im, wb_re, wb_im)
}

/// Quantum Causal Semantic GraphRAG Subspace-Deconfounded Retrieval Score
/// combining De Clercq tautological subspace projection $s_{\mathrm{taut}}$, Pearl $\operatorname{do}$-deconfounded
/// Jeffrey kinematic update, and complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker path interference
/// (`Signals.QuantumCausalInference.quantumCausalGraphRAGScore`).
#[must_use]
pub fn quantum_causal_graphrag_score(
    s_taut: f64,
    q1: f64,
    q2: f64,
    c1_do: f64,
    c2_do: f64,
    gamma_coh: f64,
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    s_taut
        + quantum_jeffrey_plucker_kinematic_update(
            q1, q2, c1_do, c2_do, gamma_coh, wa_re, wa_im, wb_re, wb_im,
        )
}

/// 3D Normed Tensor Gaussian Splat (`NormedTensorGaussianSplat3D`) with Jeffrey Kinematic Engine
/// weight update, adaptive two-child major-axis splitting (`splitMajorPlus` / `splitMajorMinus`),
/// and holographic $\mathrm{Gr}_{\mathbb{C}}(2,4)$ depth variance recovery (`recoverDepthVarianceSq`)
/// for volumetric nanoimaging and surgical navigation.
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct SurgicalVolumetricSplat3D {
    pub center: [f64; 3],
    pub weight: f64,
    pub sigma: [f64; 3],
}

impl SurgicalVolumetricSplat3D {
    /// Constructs a validated 3D Normed Tensor Gaussian Splat.
    pub fn new(center: [f64; 3], weight: f64, sigma: [f64; 3]) -> Result<Self, ValidationError> {
        require_nonnegative("weight", weight)?;
        require_positive("sigma1", sigma[0])?;
        require_positive("sigma2", sigma[1])?;
        require_positive("sigma3", sigma[2])?;
        Ok(Self {
            center,
            weight,
            sigma,
        })
    }

    /// 3D covariance determinant $\det\Sigma_{\mathrm{3D}} = \sigma_1^2 \sigma_2^2 \sigma_3^2$.
    #[must_use]
    pub fn cov_det(&self) -> f64 {
        (self.sigma[0] * self.sigma[1] * self.sigma[2]).powi(2)
    }

    /// Orthographic 2D projection trace $\operatorname{Tr}\Sigma_{\mathrm{2D}} = \sigma_1^2 + \sigma_2^2$.
    #[must_use]
    pub fn ortho_2d_cov_trace(&self) -> f64 {
        self.sigma[0] * self.sigma[0] + self.sigma[1] * self.sigma[1]
    }

    /// Updates the voxel weight via Jeffrey's Kinematic Engine (`jeffreyKinematicWeightUpdate`)
    /// while preserving the 3D covariance fiber (`Jeffrey rigidity`).
    pub fn jeffrey_kinematic_weight_update(
        &self,
        q1: f64,
        q2: f64,
        c1_do: f64,
        c2_do: f64,
    ) -> Result<Self, ValidationError> {
        require_nonnegative("q1", q1)?;
        require_nonnegative("q2", q2)?;
        require_nonnegative("c1_do", c1_do)?;
        require_nonnegative("c2_do", c2_do)?;
        Ok(Self {
            center: self.center,
            weight: jeffrey_kinematic_update(q1, q2, c1_do, c2_do),
            sigma: self.sigma,
        })
    }

    /// Adaptive two-child splitting (`splitMajorPlus`, `splitMajorMinus`) along the first principal axis:
    /// halves the weight ($w_\pm = w/2$) and halves $\sigma_1$ ($\sigma_{1,\pm} = \sigma_1 / 2$),
    /// reducing $\det\Sigma_{\mathrm{3D}}$ by $1/4$ while conserving total $L^1$ mass $w_+ + w_- = w$.
    #[must_use]
    pub fn split_major_children(&self) -> (Self, Self) {
        let half_w = 0.5 * self.weight;
        let half_s1 = 0.5 * self.sigma[0];
        let offset = (0.75_f64).sqrt() * self.sigma[0];
        let child_plus = Self {
            center: [self.center[0] + offset, self.center[1], self.center[2]],
            weight: half_w,
            sigma: [half_s1, self.sigma[1], self.sigma[2]],
        };
        let child_minus = Self {
            center: [self.center[0] - offset, self.center[1], self.center[2]],
            weight: half_w,
            sigma: [half_s1, self.sigma[1], self.sigma[2]],
        };
        (child_plus, child_minus)
    }

    /// Recovers the exact 3rd principal depth variance $\sigma_3^2 = \operatorname{Tr}\Sigma_{\mathrm{2D}} / R_{\mathrm{depth}}$
    /// from the 2D orthographic trace and the $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker channel ratio
    /// $R_{\mathrm{depth}} = \|w_A^{\mathbb{C}}\|^2 / \|w_B^{\mathbb{C}}\|^2 = (\sigma_1^2 + \sigma_2^2) / \sigma_3^2$
    /// (`Signals.DDF.recoverDepthVarianceSq`).
    pub fn recover_depth_variance_sq(&self, r_depth: f64) -> Result<f64, ValidationError> {
        require_positive("r_depth", r_depth)?;
        Ok(self.ortho_2d_cov_trace() / r_depth)
    }
}

/// End-to-end volumetric speedup ratio including per-splat linear projection ($W_{\mathrm{red}}, W_{\mathrm{pl\ddot{u}}}$)
/// and 3D spatial radix/octree sorting overhead $C_{\mathrm{overhead}} \ge 0$:
/// $\eta_{\mathrm{overhead}} = \frac{(T \cdot H \cdot W)^2 d_{\mathrm{head}}}{N_{\mathrm{splats}} \cdot m_{\mathrm{lags}} \cdot d_{\mathrm{pl\ddot{u}cker}} + C_{\mathrm{overhead}}}$
/// (`Signals.QuantumCausalInference.effectiveVolumetricSpeedupWithOverhead`).
pub fn effective_volumetric_speedup_with_overhead(
    t: f64,
    h: f64,
    w: f64,
    d_head: f64,
    n_splats: f64,
    m_lags: f64,
    d_plucker: f64,
    c_overhead: f64,
) -> Result<f64, ValidationError> {
    require_positive("n_splats", n_splats)?;
    require_positive("m_lags", m_lags)?;
    require_positive("d_plucker", d_plucker)?;
    require_nonnegative("c_overhead", c_overhead)?;
    let num = spatiotemporal_full_attention_complexity(t, h, w, d_head);
    let den = splat_sparse_grassmann_video_complexity(n_splats, m_lags, d_plucker) + c_overhead;
    Ok(num / den)
}

/// Partition-weighted Quantum Lüders–Jeffrey kinematic update
/// $Q_{\mathrm{pw}}(S) = q_1 c_1 + q_2 c_2 + q_1 q_2 \,\gamma_{\mathrm{coh}}\,I_{\mathrm{Pl\ddot{u}cker}}$,
/// which satisfies **Boundary Rigidity** ($Q_{\mathrm{pw}}(1,0) = c_1$, $Q_{\mathrm{pw}}(0,1) = c_2$)
/// (`Signals.QuantumCausalInference.partitionWeightedQuantumJeffreyUpdate`).
#[must_use]
pub fn partition_weighted_quantum_jeffrey_update(
    q1: f64,
    q2: f64,
    c1: f64,
    c2: f64,
    gamma_coh: f64,
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    jeffrey_kinematic_update(q1, q2, c1, c2)
        + q1 * q2 * gamma_coh * qcdt_plucker_interference_term(wa_re, wa_im, wb_re, wb_im)
}

/// Sequential two-stage soft-evidence linear Jeffrey pooling
/// $(1 - \lambda_2)((1 - \lambda_1) p_0 + \lambda_1 q_1) + \lambda_2 q_2$
/// (`Signals.QuantumCausalInference.sequentialJeffreyPool`; Diaconis & Zabell 1982).
#[must_use]
pub fn sequential_jeffrey_pool(p0: f64, q1: f64, q2: f64, lam1: f64, lam2: f64) -> f64 {
    (1.0 - lam2) * ((1.0 - lam1) * p0 + lam1 * q1) + lam2 * q2
}

/// Diaconis–Zabell commutative additive log-odds kinematic update
/// $\ell_0 + \Delta\ell_1 + \Delta\ell_2$
/// (`Signals.QuantumCausalInference.diaconisZabellLogOddsUpdate`; Diaconis & Zabell 1982, Theorem 2.1).
#[must_use]
pub fn diaconis_zabell_log_odds_update(l0: f64, dl1: f64, dl2: f64) -> f64 {
    l0 + dl1 + dl2
}

// ============================================================================
// 8b. Optional Complex VRC vs. Plabic Parameterization for Grassmannian QCI
// ============================================================================

/// Selector for Grassmannian Quantum Causal Inference (`QCI`) parameterization
/// (`Signals.QuantumCausalInference.GrassmannianCausalBackend`):
/// - `PlabicRationalChart`: standard Postnikov Plabic boundary measurement chart (`x_X != 0`, `x_X != -1`).
/// - `ComplexHomogeneousVrc`: homogeneous Complex Vector-Relation Configuration (`V K^T = 0`),
///   which clears all `1/x_X` and `1/(1 + x_X)` denominators so on-shell destructive-interference
///   and polariton resonance poles (`x_X = -1`, `x_X = 0`) remain regular points in `Gr_C(k, n)`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GrassmannianCausalBackend {
    PlabicRationalChart,
    ComplexHomogeneousVrc,
}

/// Automatically recommends `ComplexHomogeneousVrc` whenever Complex Grassmannians (`is_complex = true`)
/// or on-shell destructive-interference / polariton resonances (`has_resonance = true`) are present,
/// and falls back to `PlabicRationalChart` otherwise (`Signals.QuantumCausalInference.qciRecommendBackend`).
#[must_use]
pub const fn qci_recommend_backend(
    is_complex: bool,
    has_resonance: bool,
) -> GrassmannianCausalBackend {
    if is_complex || has_resonance {
        GrassmannianCausalBackend::ComplexHomogeneousVrc
    } else {
        GrassmannianCausalBackend::PlabicRationalChart
    }
}

/// Evaluates the $2 \times 4$ boundary subspace matrix $C \in \mathbb{C}^{2 \times 4}$ on $\mathrm{Gr}_{\mathbb{C}}(2,4)$
/// under either `PlabicRationalChart` or `ComplexHomogeneousVrc`, with optional cluster square-move
/// mutation (`mutated`) and Pearl $\operatorname{do}$-surgical backdoor severing (`do_sever_backdoor`, which sets $x_2 \mapsto 0$)
/// (`Signals.QuantumCausalInference.qciGr24BoundaryMatrix`).
#[must_use]
pub fn qci_gr24_boundary_matrix(
    backend: GrassmannianCausalBackend,
    mutated: bool,
    x1: crate::dft_plabic_vrc::C64,
    x2: crate::dft_plabic_vrc::C64,
    x_x: crate::dft_plabic_vrc::C64,
    do_sever_backdoor: bool,
) -> [[crate::dft_plabic_vrc::C64; 4]; 2] {
    use crate::dft_plabic_vrc::{C64, ComplexPlabicVrc2x4};
    let x2_eff = if do_sever_backdoor { C64::ZERO } else { x2 };
    match (backend, mutated) {
        (GrassmannianCausalBackend::PlabicRationalChart, false) => {
            ComplexPlabicVrc2x4::rational_chart_matrix(x1, x2_eff, x_x)
        }
        (GrassmannianCausalBackend::PlabicRationalChart, true) => {
            let (x1_m, x2_m, xx_m) = ComplexPlabicVrc2x4::cluster_mutation(x1, x2_eff, x_x);
            ComplexPlabicVrc2x4::rational_chart_matrix(x1_m, x2_m, xx_m)
        }
        (GrassmannianCausalBackend::ComplexHomogeneousVrc, false) => {
            ComplexPlabicVrc2x4::homogeneous(x1, x2_eff, x_x).vectors
        }
        (GrassmannianCausalBackend::ComplexHomogeneousVrc, true) => {
            ComplexPlabicVrc2x4::mutated_homogeneous(x1, x2_eff, x_x).vectors
        }
    }
}

/// Evaluates the six $2 \times 2$ Plücker minors `(p12, p13, p14, p23, p24, p34)` of the $\mathrm{Gr}_{\mathbb{C}}(2,4)$
/// causal boundary matrix under the selected `GrassmannianCausalBackend`
/// (`Signals.QuantumCausalInference.qciGr24PluckerMinor`).
#[must_use]
pub fn qci_gr24_plucker_minors(
    backend: GrassmannianCausalBackend,
    mutated: bool,
    x1: crate::dft_plabic_vrc::C64,
    x2: crate::dft_plabic_vrc::C64,
    x_x: crate::dft_plabic_vrc::C64,
    do_sever_backdoor: bool,
) -> crate::dft_plabic_vrc::Plucker2x4 {
    let mat = qci_gr24_boundary_matrix(backend, mutated, x1, x2, x_x, do_sever_backdoor);
    crate::dft_plabic_vrc::Plucker2x4::from_matrix(&mat)
}

/// Evaluates the two uncrossed complex Plücker channels $w_A^{\mathbb{C}} = p_{12} p_{34}$ and
/// $w_B^{\mathbb{C}} = p_{14} p_{23}$ under the selected `GrassmannianCausalBackend`
/// (`Signals.QuantumCausalInference.qciGr24UncrossedChannelA`, `qciGr24UncrossedChannelB`).
#[must_use]
pub fn qci_gr24_uncrossed_channels(
    backend: GrassmannianCausalBackend,
    mutated: bool,
    x1: crate::dft_plabic_vrc::C64,
    x2: crate::dft_plabic_vrc::C64,
    x_x: crate::dft_plabic_vrc::C64,
    do_sever_backdoor: bool,
) -> (crate::dft_plabic_vrc::C64, crate::dft_plabic_vrc::C64) {
    let p = qci_gr24_plucker_minors(backend, mutated, x1, x2, x_x, do_sever_backdoor);
    (p.p12 * p.p34, p.p14 * p.p23)
}

/// Evaluates the Quantum Lüders–Jeffrey Plücker kinematic update using the selected
/// `GrassmannianCausalBackend` (`PlabicRationalChart` vs. `ComplexHomogeneousVrc`)
/// (`Signals.QuantumCausalInference.qciOptionalVrcJeffreyKinematicUpdate`).
#[must_use]
pub fn qci_optional_vrc_jeffrey_kinematic_update(
    backend: GrassmannianCausalBackend,
    mutated: bool,
    q1: f64,
    q2: f64,
    c1: f64,
    c2: f64,
    gamma_coh: f64,
    x1: crate::dft_plabic_vrc::C64,
    x2: crate::dft_plabic_vrc::C64,
    x_x: crate::dft_plabic_vrc::C64,
    do_sever_backdoor: bool,
) -> f64 {
    let (wa, wb) = qci_gr24_uncrossed_channels(backend, mutated, x1, x2, x_x, do_sever_backdoor);
    quantum_jeffrey_plucker_kinematic_update(
        q1, q2, c1, c2, gamma_coh, wa.re, wa.im, wb.re, wb.im,
    )
}

/// Evaluates the Quantum Causal Semantic GraphRAG score using the selected
/// `GrassmannianCausalBackend` (`PlabicRationalChart` vs. `ComplexHomogeneousVrc`)
/// (`Signals.QuantumCausalInference.qciOptionalVrcGraphRAGScore`).
#[must_use]
pub fn qci_optional_vrc_graphrag_score(
    backend: GrassmannianCausalBackend,
    mutated: bool,
    s_taut: f64,
    q1: f64,
    q2: f64,
    c1_do: f64,
    c2_do: f64,
    gamma_coh: f64,
    x1: crate::dft_plabic_vrc::C64,
    x2: crate::dft_plabic_vrc::C64,
    x_x: crate::dft_plabic_vrc::C64,
    do_sever_backdoor: bool,
) -> f64 {
    let (wa, wb) = qci_gr24_uncrossed_channels(backend, mutated, x1, x2, x_x, do_sever_backdoor);
    quantum_causal_graphrag_score(
        s_taut, q1, q2, c1_do, c2_do, gamma_coh, wa.re, wa.im, wb.re, wb.im,
    )
}

// ============================================================================
// 9. WASM32 / C-ABI Exports
// ============================================================================

/// C-ABI / WASM export: evaluates the Quantum Switch $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker
/// channel ratio $\|w_B^{\mathbb{C}}\|^2 / \|w_A^{\mathbb{C}}\|^2 = E_- / E_+$.
#[unsafe(no_mangle)]
pub extern "C" fn signals_quantum_switch_gr24_ratio(e_sym: f64, e_anti: f64) -> f64 {
    quantum_switch_gr24_plucker_channels(e_sym, e_anti).2
}

/// C-ABI / WASM export: evaluates `del_rio_conditional_landauer_heat`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_del_rio_conditional_landauer_heat(kbt_ln2: f64, fidelity: f64) -> f64 {
    del_rio_conditional_landauer_heat(kbt_ln2, fidelity)
}

/// C-ABI / WASM export: evaluates `lignolux_tape_siphon_power_watts`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_lignolux_tape_siphon_power_watts(
    t_kelvin: f64,
    fidelity: f64,
    n_ancillas: f64,
    f_qec_hz: f64,
) -> f64 {
    lignolux_tape_siphon_power_watts(t_kelvin, fidelity, n_ancillas, f_qec_hz)
}

/// C-ABI / WASM export: evaluates `landau_double_well_barrier_height` (returns `NaN` on invalid inputs).
#[unsafe(no_mangle)]
pub extern "C" fn signals_landau_double_well_barrier_height(
    a0: f64,
    temp_k: f64,
    t_critical_k: f64,
    b_quartic: f64,
) -> f64 {
    landau_double_well_barrier_height(a0, temp_k, t_critical_k, b_quartic).unwrap_or(f64::NAN)
}

/// C-ABI / WASM export: evaluates `bundle_hybrid_attention_score`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_bundle_hybrid_attention_score(
    lam_inst: f64,
    s_inst: f64,
    lam_concept: f64,
    s_concept: f64,
) -> f64 {
    bundle_hybrid_attention_score(lam_inst, s_inst, lam_concept, s_concept)
}

/// C-ABI / WASM export: evaluates `spatiotemporal_grassmann_video_complexity`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_spatiotemporal_grassmann_video_complexity(
    t: f64,
    h: f64,
    w: f64,
    m_lags: f64,
    d_plucker: f64,
) -> f64 {
    spatiotemporal_grassmann_video_complexity(t, h, w, m_lags, d_plucker)
}

/// C-ABI / WASM export: evaluates `volumetric_attention_efficiency_ratio` (returns `NaN` on invalid inputs).
#[unsafe(no_mangle)]
pub extern "C" fn signals_volumetric_attention_efficiency_ratio(
    t: f64,
    h: f64,
    w: f64,
    d_head: f64,
    n_splats: f64,
    m_lags: f64,
    d_plucker: f64,
) -> f64 {
    volumetric_attention_efficiency_ratio(t, h, w, d_head, n_splats, m_lags, d_plucker)
        .unwrap_or(f64::NAN)
}

/// C-ABI / WASM export: evaluates `jeffrey_kinematic_update`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_jeffrey_kinematic_update(q1: f64, q2: f64, c1: f64, c2: f64) -> f64 {
    jeffrey_kinematic_update(q1, q2, c1, c2)
}

/// C-ABI / WASM export: evaluates `quantum_jeffrey_plucker_kinematic_update`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_quantum_jeffrey_plucker_kinematic_update(
    q1: f64,
    q2: f64,
    c1: f64,
    c2: f64,
    gamma_coh: f64,
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    quantum_jeffrey_plucker_kinematic_update(
        q1, q2, c1, c2, gamma_coh, wa_re, wa_im, wb_re, wb_im,
    )
}

/// C-ABI / WASM export: evaluates `quantum_causal_graphrag_score`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_quantum_causal_graphrag_score(
    s_taut: f64,
    q1: f64,
    q2: f64,
    c1_do: f64,
    c2_do: f64,
    gamma_coh: f64,
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    quantum_causal_graphrag_score(
        s_taut, q1, q2, c1_do, c2_do, gamma_coh, wa_re, wa_im, wb_re, wb_im,
    )
}

/// C-ABI / WASM export: evaluates `effective_volumetric_speedup_with_overhead` (returns `NaN` on invalid inputs).
#[unsafe(no_mangle)]
pub extern "C" fn signals_effective_volumetric_speedup_with_overhead(
    t: f64,
    h: f64,
    w: f64,
    d_head: f64,
    n_splats: f64,
    m_lags: f64,
    d_plucker: f64,
    c_overhead: f64,
) -> f64 {
    effective_volumetric_speedup_with_overhead(
        t, h, w, d_head, n_splats, m_lags, d_plucker, c_overhead,
    )
    .unwrap_or(f64::NAN)
}

/// C-ABI / WASM export: evaluates `partition_weighted_quantum_jeffrey_update`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_partition_weighted_quantum_jeffrey_update(
    q1: f64,
    q2: f64,
    c1: f64,
    c2: f64,
    gamma_coh: f64,
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    partition_weighted_quantum_jeffrey_update(
        q1, q2, c1, c2, gamma_coh, wa_re, wa_im, wb_re, wb_im,
    )
}

/// C-ABI / WASM export: evaluates `qci_optional_vrc_jeffrey_kinematic_update`
/// (`use_vrc != 0` selects `ComplexHomogeneousVrc`, `0` selects `PlabicRationalChart`).
#[unsafe(no_mangle)]
pub extern "C" fn signals_qci_optional_vrc_jeffrey_kinematic_update(
    use_vrc: i32,
    mutated: i32,
    q1: f64,
    q2: f64,
    c1: f64,
    c2: f64,
    gamma_coh: f64,
    x1_re: f64,
    x1_im: f64,
    x2_re: f64,
    x2_im: f64,
    xx_re: f64,
    xx_im: f64,
    do_sever_backdoor: i32,
) -> f64 {
    use crate::dft_plabic_vrc::C64;
    let backend = if use_vrc != 0 {
        GrassmannianCausalBackend::ComplexHomogeneousVrc
    } else {
        GrassmannianCausalBackend::PlabicRationalChart
    };
    qci_optional_vrc_jeffrey_kinematic_update(
        backend,
        mutated != 0,
        q1,
        q2,
        c1,
        c2,
        gamma_coh,
        C64::new(x1_re, x1_im),
        C64::new(x2_re, x2_im),
        C64::new(xx_re, xx_im),
        do_sever_backdoor != 0,
    )
}

/// C-ABI / WASM export: evaluates `qci_optional_vrc_graphrag_score`
/// (`use_vrc != 0` selects `ComplexHomogeneousVrc`, `0` selects `PlabicRationalChart`).
#[unsafe(no_mangle)]
pub extern "C" fn signals_qci_optional_vrc_graphrag_score(
    use_vrc: i32,
    mutated: i32,
    s_taut: f64,
    q1: f64,
    q2: f64,
    c1_do: f64,
    c2_do: f64,
    gamma_coh: f64,
    x1_re: f64,
    x1_im: f64,
    x2_re: f64,
    x2_im: f64,
    xx_re: f64,
    xx_im: f64,
    do_sever_backdoor: i32,
) -> f64 {
    use crate::dft_plabic_vrc::C64;
    let backend = if use_vrc != 0 {
        GrassmannianCausalBackend::ComplexHomogeneousVrc
    } else {
        GrassmannianCausalBackend::PlabicRationalChart
    };
    qci_optional_vrc_graphrag_score(
        backend,
        mutated != 0,
        s_taut,
        q1,
        q2,
        c1_do,
        c2_do,
        gamma_coh,
        C64::new(x1_re, x1_im),
        C64::new(x2_re, x2_im),
        C64::new(xx_re, xx_im),
        do_sever_backdoor != 0,
    )
}

// ---------------------------------------------------------------------------
// 10. Quantum Causal Next-Concept Modeling (`QCI-NCM`), Multiscale Residual
//     Counterfactuals, Deconfounded Conditioning Corruption, Plücker/VRC
//     Intra-Level Constraint Coupling, & Pressed-LLM `LHAT` Hardware
//     (`arXiv:2610.14162`, Section 15 of `Signals.QuantumCausalInference`)
// ---------------------------------------------------------------------------

/// Cumulative multiscale residual reconstruction step at level `k` (`ncmCumulativeReconstructionStep`):
/// `z_hat_k = z_prev + delta_k` where `delta_k = R_k(e_k(r_k))`.
pub fn ncm_cumulative_reconstruction_step(z_prev: f64, delta_k: f64) -> f64 {
    z_prev + delta_k
}

/// Remaining latent residual after level `k` (`ncmResidualAtLevel`):
/// `z_k = z - z_hat_k`.
pub fn ncm_residual_at_level(z: f64, z_hat_k: f64) -> f64 {
    z - z_hat_k
}

/// Giarmatzi–Costa / Pearl abduced fine-scale exogenous residual at coarse cutoff `k_0`
/// (`ncmTwoScaleAbducedFineResidual`): `u_fine = z_obs - z_coarse_obs`.
pub fn ncm_two_scale_abduced_fine_residual(z_obs: f64, z_coarse_obs: f64) -> f64 {
    z_obs - z_coarse_obs
}

/// Counterfactual concept reconstruction under coarse-level intervention
/// `do(z_hat^(k_0) := z_coarse_int)` (`ncmCounterfactualConceptReconstruction`):
/// `z_cf = z_coarse_int + (z_obs - z_coarse_obs)`.
pub fn ncm_counterfactual_concept_reconstruction(
    z_obs: f64,
    z_coarse_obs: f64,
    z_coarse_int: f64,
) -> f64 {
    z_coarse_int + ncm_two_scale_abduced_fine_residual(z_obs, z_coarse_obs)
}

/// Convex coarse-concept story composition (`ncmStoryConceptComposition`, `arXiv:2610.14162` Appendix C.2):
/// `z_mix = (1 - lam) * z_coarse_a + lam * z_coarse_b`.
pub fn ncm_story_concept_composition(lam: f64, z_coarse_a: f64, z_coarse_b: f64) -> f64 {
    (1.0 - lam) * z_coarse_a + lam * z_coarse_b
}

/// Deterministic point-mass variational ELBO (`ncmPointMassElbo`, `arXiv:2610.14162` Appendix A):
/// `L_ELBO(x) = log_p_recon + log_p_gen`.
pub fn ncm_point_mass_elbo(log_p_recon: f64, log_p_gen: f64) -> f64 {
    log_p_recon + log_p_gen
}

/// Exact posterior KL divergence gap (`ncmElboPosteriorKlGap`):
/// `log_p_marginal - L_ELBO(x) = D_KL(q(r_{1:K}|x) || p_{theta,psi}(r_{1:K}|x)) >= 0`.
pub fn ncm_elbo_posterior_kl_gap(
    log_p_marginal: f64,
    log_p_recon: f64,
    log_p_gen: f64,
) -> f64 {
    log_p_marginal - ncm_point_mass_elbo(log_p_recon, log_p_gen)
}

/// Residual exposure confounding bias under NCM conditioning corruption
/// (`ncmCorruptionDeconfoundedBias`, `arXiv:2610.14162` Section 3.4):
/// `(1 - p_corr) * b_conf`.
pub fn ncm_corruption_deconfounded_bias(p_corr: f64, b_conf: f64) -> f64 {
    (1.0 - p_corr) * b_conf
}

/// Expected concept utility under NCM conditioning corruption (`ncmCorruptedExpectedConceptUtility`):
/// interpolates between confounded teacher-forcing `JEV` (`p_corr = 0`) and Pearl's
/// interventional `CEV` (`p_corr = 1`).
pub fn ncm_corrupted_expected_concept_utility(
    p_do_1: f64,
    u1: f64,
    u2: f64,
    p_corr: f64,
    b_conf: f64,
) -> f64 {
    cev_causal_do_expected_utility(p_do_1, 1.0 - p_do_1, u1, u2)
        + ncm_corruption_deconfounded_bias(p_corr, b_conf) * (u1 - u2)
}

/// Quantum Causal coherent pairwise concept probability (`qciNcmCoherentPairwiseCodeProb`):
/// replaces conditionally independent intra-level sampling by coherent `Gr_C(2,4)` / VRC
/// Plücker superposition `|w_A + w_B|^2`, vanishing identically at the destructive
/// constraint-exclusion resonance `w_B = -w_A` (`x_X = -1`).
pub fn qci_ncm_coherent_pairwise_code_prob(
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    (wa_re * wa_re + wa_im * wa_im)
        + (wb_re * wb_re + wb_im * wb_im)
        + qcdt_plucker_interference_term(wa_re, wa_im, wb_re, wb_im)
}

/// Full-sequence Diffusion Language Model (`DLM`) attention FLOP complexity across `T` steps
/// (`dlmFullSequenceAttentionComplexity`): `T * L^2 * d_head`.
pub fn dlm_full_sequence_attention_complexity(t_steps: f64, l_seq: f64, d_head: f64) -> f64 {
    t_steps * l_seq * l_seq * d_head
}

/// Block-diagonal NCM attention FLOP complexity across arbitrary level lengths `level_lengths`
/// (`ncmFourLevelBlockDiagonalAttentionComplexity` generalized to `K` levels):
/// `(sum_k l_k^2) * d_head`.
pub fn ncm_block_diagonal_attention_complexity(level_lengths: &[f64], d_head: f64) -> f64 {
    let sum_sq: f64 = level_lengths.iter().map(|&l| l * l).sum();
    sum_sq * d_head
}

/// Quantum Causal Grassmannian NCM (`QCI-G-NCM`) linear Plücker mixing FLOP complexity across
/// level lengths `level_lengths` (`qciGrassmannNcmFourLevelComplexity` generalized to `K` levels):
/// `(sum_k l_k) * m_lags * d_plucker`.
pub fn qci_grassmann_ncm_complexity(
    level_lengths: &[f64],
    m_lags: f64,
    d_plucker: f64,
) -> f64 {
    let sum_l: f64 = level_lengths.iter().sum();
    sum_l * m_lags * d_plucker
}

/// Function Evaluation (`NFE`) speedup ratio (`ncmNfeSpeedupRatio`): `nfe_baseline / nfe_ncm`.
pub fn ncm_nfe_speedup_ratio(nfe_baseline: f64, nfe_ncm: f64) -> Option<f64> {
    if nfe_ncm <= 0.0 || !nfe_baseline.is_finite() || !nfe_ncm.is_finite() {
        return None;
    }
    Some(nfe_baseline / nfe_ncm)
}

/// Pressed-LLM `LHAT` holographic tape + scale-selective coarse/fine active `N-LIG`/`B-LIG`
/// steering (`ncmPressedTwoScaleSteeredLatent`):
/// `(z_pressed_coarse + alpha_coarse * v_steer_coarse) + (z_pressed_fine + alpha_fine * v_steer_fine)`.
pub fn ncm_pressed_two_scale_steered_latent(
    z_pressed_coarse: f64,
    z_pressed_fine: f64,
    alpha_coarse: f64,
    v_steer_coarse: f64,
    alpha_fine: f64,
    v_steer_fine: f64,
) -> f64 {
    (z_pressed_coarse + alpha_coarse * v_steer_coarse)
        + (z_pressed_fine + alpha_fine * v_steer_fine)
}

/// Sequential single-GPU vs. OAM-multiplexed parallel Minimum Bayes Risk (`MBR`) decoding
/// step counts (`ncmSequentialMbrLatencySteps`, `ncmOamParallelMbrLatencySteps`).
pub fn ncm_sequential_vs_oam_parallel_mbr_steps(
    m_candidates: usize,
    k_levels: usize,
) -> (usize, usize) {
    (m_candidates * k_levels, k_levels)
}

/// Two-step partial flag manifold real dimension `dim_R Fl_R(l_1, l_2; L) = l_1(l_2 - l_1) + l_2(L - l_2)`
/// (`ncmFlagManifoldTwoStepRealDim`).
pub fn ncm_flag_manifold_two_step_real_dim(l1: usize, l2: usize, l_seq: usize) -> Option<usize> {
    if l1 > l2 || l2 > l_seq {
        return None;
    }
    Some(l1 * (l2 - l1) + l2 * (l_seq - l2))
}

/// Unnormalized NCM inverse-length per-position level loss weight (`ncmLevelLossWeightUnnorm`, Eq. (5)).
pub fn ncm_level_loss_weight_unnorm(l_k: f64) -> Option<f64> {
    if l_k <= 0.0 || !l_k.is_finite() {
        return None;
    }
    Some(1.0 / l_k)
}

/// Classifier-Free Guidance (`CFG`) concept logit extrapolation (`ncmClassifierFreeGuidedLogit`, Table 2):
/// `l_CFG = (1 + gamma_cfg) * l_cond - gamma_cfg * l_uncond`.
pub fn ncm_classifier_free_guided_logit(l_cond: f64, l_uncond: f64, gamma_cfg: f64) -> f64 {
    (1.0 + gamma_cfg) * l_cond - gamma_cfg * l_uncond
}

/// Nested-dropout active Bragg depth layer count (`ncmNestedDropoutActiveBraggLayers`, Eq. (3)):
/// `min(k_cutoff, k_total) <= k_total`.
pub fn ncm_nested_dropout_active_bragg_layers(k_cutoff: usize, k_total: usize) -> usize {
    k_cutoff.min(k_total)
}

/// C-ABI / WASM export: evaluates `ncm_counterfactual_concept_reconstruction`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_ncm_counterfactual_concept_reconstruction(
    z_obs: f64,
    z_coarse_obs: f64,
    z_coarse_int: f64,
) -> f64 {
    ncm_counterfactual_concept_reconstruction(z_obs, z_coarse_obs, z_coarse_int)
}

/// C-ABI / WASM export: evaluates `ncm_corrupted_expected_concept_utility`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_ncm_corrupted_expected_concept_utility(
    p_do_1: f64,
    u1: f64,
    u2: f64,
    p_corr: f64,
    b_conf: f64,
) -> f64 {
    ncm_corrupted_expected_concept_utility(p_do_1, u1, u2, p_corr, b_conf)
}

/// C-ABI / WASM export: evaluates `qci_ncm_coherent_pairwise_code_prob`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_qci_ncm_coherent_pairwise_code_prob(
    wa_re: f64,
    wa_im: f64,
    wb_re: f64,
    wb_im: f64,
) -> f64 {
    qci_ncm_coherent_pairwise_code_prob(wa_re, wa_im, wb_re, wb_im)
}

/// C-ABI / WASM export: evaluates `ncm_pressed_two_scale_steered_latent`.
#[unsafe(no_mangle)]
pub extern "C" fn signals_ncm_pressed_two_scale_steered_latent(
    z_pressed_coarse: f64,
    z_pressed_fine: f64,
    alpha_coarse: f64,
    v_steer_coarse: f64,
    alpha_fine: f64,
    v_steer_fine: f64,
) -> f64 {
    ncm_pressed_two_scale_steered_latent(
        z_pressed_coarse,
        z_pressed_fine,
        alpha_coarse,
        v_steer_coarse,
        alpha_fine,
        v_steer_fine,
    )
}

// ---------------------------------------------------------------------------
// 11. Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`)
//     Reimplementing Boullé, Halikias, Otto, & Townsend (2026, PNAS 123(47))
//     with Plabic/LGV Minors, Pearl do-Surgery, Gr_C(2,4) Quantum Switch,
//     Jeffrey's Kinematic Engine, QFIM = 4 g_FS, & Closed-Loop Landauer Heat
// ---------------------------------------------------------------------------

/// Result of rank-revealing column-pivoted Householder QR (`G P = Q R`) on an `m x n`
/// tested dictionary recovery matrix `G` (`Boullé et al. 2026` Algorithm 1 / `WIAS`).
#[derive(Clone, Debug)]
pub struct WiasQrAudit {
    pub rows: usize,
    pub cols: usize,
    pub rank: usize,
    pub sigma_min_est: f64,
    pub sigma_max_est: f64,
    pub cond_est: f64,
    pub gram_det: f64,
    pub coeffs: Vec<f64>,
    pub residual_norm: f64,
}

/// Exact Cauchy–Binet / Plücker 3x2 Gram determinant identity:
/// `det(G^T G) == Δ_01^2 + Δ_02^2 + Δ_12^2`.
pub fn osid_cauchy_binet_2x3_gram_and_plucker(a: [f64; 3], b: [f64; 3]) -> (f64, f64) {
    let norm_a_sq = a[0] * a[0] + a[1] * a[1] + a[2] * a[2];
    let norm_b_sq = b[0] * b[0] + b[1] * b[1] + b[2] * b[2];
    let dot_ab = a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    let gram_det = norm_a_sq * norm_b_sq - dot_ab * dot_ab;
    let d01 = plucker_2d_coord(a[0], a[1], b[0], b[1]);
    let d02 = plucker_2d_coord(a[0], a[2], b[0], b[2]);
    let d12 = plucker_2d_coord(a[1], a[2], b[1], b[2]);
    let plucker_norm_sq = d01 * d01 + d02 * d02 + d12 * d12;
    (gram_det, plucker_norm_sq)
}

/// Compute `det(G^T G)` via Gaussian elimination on the `n x n` normal matrix `G^T G`.
pub fn matrix_gram_det(g_rows: &[Vec<f64>]) -> f64 {
    if g_rows.is_empty() {
        return 0.0;
    }
    let n = g_rows[0].len();
    if n == 0 {
        return 1.0;
    }
    let mut gram = vec![vec![0.0; n]; n];
    for row in g_rows {
        for i in 0..n {
            for j in 0..n {
                gram[i][j] += row[i] * row[j];
            }
        }
    }
    let mut det = 1.0;
    for k in 0..n {
        let mut piv_row = k;
        let mut piv_val = gram[k][k].abs();
        for r in (k + 1)..n {
            if gram[r][k].abs() > piv_val {
                piv_val = gram[r][k].abs();
                piv_row = r;
            }
        }
        if piv_val <= 1e-18 {
            return 0.0;
        }
        if piv_row != k {
            gram.swap(k, piv_row);
            det = -det;
        }
        let diag = gram[k][k];
        det *= diag;
        for r in (k + 1)..n {
            let factor = gram[r][k] / diag;
            for c in k..n {
                gram[r][c] -= factor * gram[k][c];
            }
        }
    }
    det
}

/// Rank-revealing column-pivoted Householder QR (`G P = Q R`) and least-squares solver
/// for `G c = rhs`.
pub fn wias_column_pivoted_qr_solve(
    g_rows: &[Vec<f64>],
    rhs: &[f64],
    rank_tol: f64,
) -> Result<WiasQrAudit, &'static str> {
    let m = g_rows.len();
    if m == 0 || rhs.len() != m {
        return Err("mismatched row dimensions in wias_column_pivoted_qr_solve");
    }
    let n = g_rows[0].len();
    if n == 0 || g_rows.iter().any(|r| r.len() != n) {
        return Err("invalid column dimensions in wias_column_pivoted_qr_solve");
    }

    let mut r_mat = vec![vec![0.0; n]; m];
    for i in 0..m {
        for j in 0..n {
            r_mat[i][j] = g_rows[i][j];
        }
    }
    let mut qtb = rhs.to_vec();
    let mut perm: Vec<usize> = (0..n).collect();
    let steps = m.min(n);

    for k in 0..steps {
        // Choose remaining column with largest residual 2-norm
        let mut best_col = k;
        let mut best_norm_sq = -1.0;
        for j in k..n {
            let mut s = 0.0;
            for i in k..m {
                s += r_mat[i][j] * r_mat[i][j];
            }
            if s > best_norm_sq {
                best_norm_sq = s;
                best_col = j;
            }
        }
        if best_col != k {
            for i in 0..m {
                r_mat[i].swap(k, best_col);
            }
            perm.swap(k, best_col);
        }

        let norm_x = (k..m).map(|i| r_mat[i][k] * r_mat[i][k]).sum::<f64>().sqrt();
        if norm_x <= 1e-15 {
            continue;
        }
        let x0 = r_mat[k][k];
        let alpha = if x0 >= 0.0 { -norm_x } else { norm_x };
        let v0 = x0 - alpha;
        let mut v = vec![0.0; m - k];
        v[0] = 1.0;
        for i in 1..(m - k) {
            v[i] = r_mat[k + i][k] / v0;
        }
        let beta = 2.0 / v.iter().map(|x| x * x).sum::<f64>();

        for j in k..n {
            let dot: f64 = (0..(m - k)).map(|i| v[i] * r_mat[k + i][j]).sum();
            for i in 0..(m - k) {
                r_mat[k + i][j] -= beta * dot * v[i];
            }
        }
        let dot_rhs: f64 = (0..(m - k)).map(|i| v[i] * qtb[k + i]).sum();
        for i in 0..(m - k) {
            qtb[k + i] -= beta * dot_rhs * v[i];
        }
        r_mat[k][k] = alpha;
        for i in (k + 1)..m {
            r_mat[i][k] = 0.0;
        }
    }

    let r_diag: Vec<f64> = (0..steps).map(|i| r_mat[i][i].abs()).collect();
    let sigma_max_est = r_diag.iter().copied().fold(0.0_f64, f64::max);
    let scale = if sigma_max_est > 0.0 {
        sigma_max_est
    } else {
        1.0
    };
    let thresh = rank_tol * scale;
    let rank = r_diag.iter().filter(|&&d| d > thresh).count();
    let sigma_min_est = if steps < n {
        0.0
    } else {
        r_diag.iter().copied().fold(f64::INFINITY, f64::min)
    };
    let cond_est = if sigma_min_est > 1e-15 * scale {
        sigma_max_est / sigma_min_est
    } else {
        f64::INFINITY
    };
    let gram_det = if m < n {
        0.0
    } else {
        r_diag.iter().map(|&d| d * d).product()
    };

    // Back-substitution on the first `rank` pivoted columns
    let mut c_perm = vec![0.0; n];
    for idx in (0..rank).rev() {
        let mut s = qtb[idx];
        for j in (idx + 1)..rank {
            s -= r_mat[idx][j] * c_perm[j];
        }
        c_perm[idx] = s / r_mat[idx][idx];
    }
    let mut coeffs = vec![0.0; n];
    for (p_idx, &orig_idx) in perm.iter().enumerate() {
        coeffs[orig_idx] = c_perm[p_idx];
    }

    let mut res_sq = 0.0;
    for i in 0..m {
        let pred: f64 = (0..n).map(|j| g_rows[i][j] * coeffs[j]).sum();
        let diff = pred - rhs[i];
        res_sq += diff * diff;
    }

    Ok(WiasQrAudit {
        rows: m,
        cols: n,
        rank,
        sigma_min_est,
        sigma_max_est,
        cond_est,
        gram_det,
        coeffs,
        residual_norm: res_sq.sqrt(),
    })
}

/// Benchmark 1: 1D Allen–Cahn / Ginzburg–Landau PDE one-shot recovery
/// `c_1 u_xx + c_2 u + c_3 u^3 = f` on `(0, 1)` (`c^* = [-0.01, -1.0, 1.0]`).
/// Compares a generic multi-mode Gaussian-seeded probe (`rank == 3`) against a
/// single-mode harmonic degenerate state `u(x) = sin(pi x)` (`rank == 2 < 3`,
/// Example 30 of `arXiv:2611.30470`).
#[derive(Clone, Debug)]
pub struct OsidAllenCahnAudit {
    pub generic_rank: usize,
    pub generic_coeffs: [f64; 3],
    pub generic_max_coeff_err: f64,
    pub generic_sigma_min: f64,
    pub generic_gram_det: f64,
    pub degenerate_rank: usize,
    pub degenerate_sigma_min: f64,
    pub degenerate_gram_det: f64,
    pub cross_lag_q4_residual: f64,
}

pub fn audit_osid_allen_cahn_pde() -> OsidAllenCahnAudit {
    let c_true = [-0.01_f64, -1.0_f64, 1.0_f64];
    let n_grid = 256usize;
    let dx = 1.0 / (n_grid as f64);
    let r0 = 8usize;

    // Generic multi-mode state sampled from deterministic Gaussian-like modal weights
    let modal_weights = [0.85_f64, -0.62, 0.41, -0.33, 0.27, -0.19];

    let assemble_allen_cahn = |weights: &[f64]| -> (Vec<Vec<f64>>, Vec<f64>) {
        let mut g_mat = vec![vec![0.0_f64; 3]; r0];
        let mut rhs = vec![0.0_f64; r0];
        for p in 1..n_grid {
            let x = (p as f64) * dx;
            let mut u = 0.0;
            let mut u_xx = 0.0;
            for (m_idx, &w) in weights.iter().enumerate() {
                let k = (m_idx + 1) as f64 * std::f64::consts::PI;
                let s = (k * x).sin();
                u += w * s;
                u_xx -= w * k * k * s;
            }
            let u3 = u * u * u;
            let f_val = c_true[0] * u_xx + c_true[1] * u + c_true[2] * u3;
            for test_idx in 0..r0 {
                let k_test = (test_idx + 1) as f64 * std::f64::consts::PI;
                let psi = (k_test * x).sin() * dx;
                g_mat[test_idx][0] += u_xx * psi;
                g_mat[test_idx][1] += u * psi;
                g_mat[test_idx][2] += u3 * psi;
                rhs[test_idx] += f_val * psi;
            }
        }
        (g_mat, rhs)
    };

    let (g_gen, rhs_gen) = assemble_allen_cahn(&modal_weights);
    let qr_gen = wias_column_pivoted_qr_solve(&g_gen, &rhs_gen, 1e-10).unwrap();
    let max_err = (0..3)
        .map(|i| (qr_gen.coeffs[i] - c_true[i]).abs())
        .fold(0.0_f64, f64::max);

    // Degenerate single-harmonic state: u = sin(pi x) => u_xx = -pi^2 u (linearly dependent!)
    // Use 2-term sub-dictionary {u_xx, u} to show exact harmonic rank collapse
    let (g_deg_3, rhs_deg_3) = assemble_allen_cahn(&[1.0]);
    let g_deg_2: Vec<Vec<f64>> = g_deg_3.iter().map(|row| vec![row[0], row[1]]).collect();
    let rhs_deg_2: Vec<f64> = g_deg_3
        .iter()
        .map(|row| c_true[0] * row[0] + c_true[1] * row[1])
        .collect();
    let _ = rhs_deg_3;
    let qr_deg = wias_column_pivoted_qr_solve(&g_deg_2, &rhs_deg_2, 1e-10).unwrap();

    // Cross-lag 4D Klein quadric check escaping shared-anchor collapse
    let cross_q4 = plucker_quadric_4d_residual(0.85, 0.0, 0.0, 0.0, 0.0, -0.62);

    OsidAllenCahnAudit {
        generic_rank: qr_gen.rank,
        generic_coeffs: [qr_gen.coeffs[0], qr_gen.coeffs[1], qr_gen.coeffs[2]],
        generic_max_coeff_err: max_err,
        generic_sigma_min: qr_gen.sigma_min_est,
        generic_gram_det: qr_gen.gram_det,
        degenerate_rank: qr_deg.rank,
        degenerate_sigma_min: qr_deg.sigma_min_est,
        degenerate_gram_det: qr_deg.gram_det,
        cross_lag_q4_residual: cross_q4,
    }
}

/// Benchmark 2: Chaotic Lorenz ODE one-shot recovery from a single RK4 trajectory
/// plus Pearl `do`-deconfounding vs. observational confounding bias & Giarmatzi–Costa
/// abduction.
#[derive(Clone, Debug)]
pub struct OsidLorenzAudit {
    pub rank: usize,
    pub recovered_sigma: f64,
    pub recovered_rho: f64,
    pub recovered_beta: f64,
    pub max_param_err: f64,
    pub sigma_min: f64,
    pub obs_confounded_slope: f64,
    pub do_deconfounded_slope: f64,
    pub abduced_exogenous_u: f64,
}

pub fn audit_osid_lorenz_ode() -> OsidLorenzAudit {
    let sigma_true = 10.0_f64;
    let rho_true = 28.0_f64;
    let beta_true = 8.0_f64 / 3.0_f64;

    let rhs_lorenz = |s: [f64; 3]| -> [f64; 3] {
        [
            sigma_true * (s[1] - s[0]),
            s[0] * (rho_true - s[2]) - s[1],
            s[0] * s[1] - beta_true * s[2],
        ]
    };

    let n_steps = 3600usize;
    let dt = 0.001_f64;
    let mut traj = Vec::with_capacity(n_steps + 1);
    let mut state = [1.0_f64, 1.0_f64, 1.0_f64];
    traj.push(state);
    for _ in 0..n_steps {
        let k1 = rhs_lorenz(state);
        let k2 = rhs_lorenz([
            state[0] + 0.5 * dt * k1[0],
            state[1] + 0.5 * dt * k1[1],
            state[2] + 0.5 * dt * k1[2],
        ]);
        let k3 = rhs_lorenz([
            state[0] + 0.5 * dt * k2[0],
            state[1] + 0.5 * dt * k2[1],
            state[2] + 0.5 * dt * k2[2],
        ]);
        let k4 = rhs_lorenz([
            state[0] + dt * k3[0],
            state[1] + dt * k3[1],
            state[2] + dt * k3[2],
        ]);
        state = [
            state[0] + (dt / 6.0) * (k1[0] + 2.0 * k2[0] + 2.0 * k3[0] + k4[0]),
            state[1] + (dt / 6.0) * (k1[1] + 2.0 * k2[1] + 2.0 * k3[1] + k4[1]),
            state[2] + (dt / 6.0) * (k1[2] + 2.0 * k2[2] + 2.0 * k3[2] + k4[2]),
        ];
        traj.push(state);
    }

    // Weak-form dictionary D(s) = [x, y, z, x*y, x*z, y*z] on 12 sub-windows with Simpson 1/3 quadrature
    let n_windows = 12usize;
    let win_len = n_steps / n_windows; // 300 steps (even)
    let mut g_mat = vec![vec![0.0_f64; 6]; n_windows];
    let mut b_x = vec![0.0_f64; n_windows];
    let mut b_y = vec![0.0_f64; n_windows];
    let mut b_z = vec![0.0_f64; n_windows];

    for w in 0..n_windows {
        let i0 = w * win_len;
        let i1 = i0 + win_len;
        let dur = (win_len as f64) * dt;
        // Smooth C^1 compactly supported test function φ(τ) = sin^2(π τ) on [0, 1]:
        // φ(0)=φ(1)=0, φ'(τ) = π sin(2π τ) / dur
        for step in i0..=i1 {
            let rel = step - i0;
            let simp = if rel == 0 || rel == win_len {
                1.0
            } else if rel % 2 == 1 {
                4.0
            } else {
                2.0
            };
            let wt = simp * (dt / 3.0);
            let tau = (rel as f64) / (win_len as f64);
            let phi = (std::f64::consts::PI * tau).sin().powi(2);
            let dphi_dt = std::f64::consts::PI * (2.0 * std::f64::consts::PI * tau).sin() / dur;
            let [x, y, z] = traj[step];
            let terms = [x, y, z, x * y, x * z, y * z];
            for j in 0..6 {
                g_mat[w][j] += wt * phi * terms[j];
            }
            // Integration by parts: ∫ φ(t) u'(t) dt = -∫ φ'(t) u(t) dt
            b_x[w] -= wt * dphi_dt * x;
            b_y[w] -= wt * dphi_dt * y;
            b_z[w] -= wt * dphi_dt * z;
        }
    }

    let qr_x = wias_column_pivoted_qr_solve(&g_mat, &b_x, 1e-10).unwrap();
    let qr_y = wias_column_pivoted_qr_solve(&g_mat, &b_y, 1e-10).unwrap();
    let qr_z = wias_column_pivoted_qr_solve(&g_mat, &b_z, 1e-10).unwrap();

    let rec_sigma = qr_x.coeffs[1]; // coefficient of y in x' = sigma*(y - x)
    let rec_rho = qr_y.coeffs[0]; // coefficient of x in y' = rho*x - y - x*z
    let rec_beta = -qr_z.coeffs[2]; // -coefficient of z in z' = x*y - beta*z
    let err_vec = [
        (qr_x.coeffs[0] + sigma_true).abs(),
        (rec_sigma - sigma_true).abs(),
        (rec_rho - rho_true).abs(),
        (qr_y.coeffs[1] + 1.0).abs(),
        (qr_y.coeffs[4] + 1.0).abs(),
        (qr_z.coeffs[3] - 1.0).abs(),
        (rec_beta - beta_true).abs(),
    ];
    let max_param_err = err_vec.iter().copied().fold(0.0_f64, f64::max);

    // Pearl do-deconfounding & Giarmatzi-Costa abduction audit
    let obs_slope = causal_observational_transfer(sigma_true, 0.45);
    let do_slope = causal_interventional_do_transfer(sigma_true, 0.45);
    let u_abduced = abduced_exogenous_state(sigma_true, 2.0, 21.5);

    OsidLorenzAudit {
        rank: qr_x.rank.min(qr_y.rank).min(qr_z.rank),
        recovered_sigma: rec_sigma,
        recovered_rho: rec_rho,
        recovered_beta: rec_beta,
        max_param_err,
        sigma_min: qr_x.sigma_min_est,
        obs_confounded_slope: obs_slope,
        do_deconfounded_slope: do_slope,
        abduced_exogenous_u: u_abduced,
    }
}

/// Benchmark 3: Structured matrix families (`Circulant` 1-shot vs. `Hankel` 1-probe deficit
/// & 2-probe recovery) + Coherent `Gr_C(2,4)` Quantum Switch & Pole-Free `VRC` 1-shot probe.
#[derive(Clone, Debug)]
pub struct OsidMatrixAndSwitchAudit {
    pub circulant_rank_1shot: usize,
    pub circulant_max_err: f64,
    pub circulant_gram_det: f64,
    pub circulant_n40_rank: usize,
    pub circulant_n40_max_err: f64,
    pub hankel_1shot_rows: usize,
    pub hankel_1shot_cols: usize,
    pub hankel_1shot_rank: usize,
    pub hankel_2shot_rank: usize,
    pub hankel_2shot_max_err: f64,
    pub hankel_n40_1shot_rank: usize,
    pub hankel_n40_2shot_rank: usize,
    pub hankel_n40_2shot_max_err: f64,
    pub hankel_2x2_two_probe_det: f64,
    pub switch_e_sym: f64,
    pub switch_e_anti: f64,
    pub switch_plucker_ratio: f64,
    pub vrc_destructive_minor: f64,
}

pub fn audit_osid_matrix_circulant_hankel_and_switch() -> OsidMatrixAndSwitchAudit {
    // A. 4x4 Circulant matrix (N = 4): 1 random probe f = [1.2, -0.7, 0.5, 2.1]
    let c_circ_true = [2.0_f64, -1.0, 0.5, 3.0];
    let f_circ = [1.2_f64, -0.7, 0.5, 2.1];
    let mut g_circ = vec![vec![0.0_f64; 4]; 4];
    let mut u_circ = vec![0.0_f64; 4];
    for row in 0..4 {
        for basis_k in 0..4 {
            let val = f_circ[(row + 4 - basis_k) % 4];
            g_circ[row][basis_k] = val;
            u_circ[row] += c_circ_true[basis_k] * val;
        }
    }
    let qr_circ = wias_column_pivoted_qr_solve(&g_circ, &u_circ, 1e-10).unwrap();
    let circ_err = (0..4)
        .map(|i| (qr_circ.coeffs[i] - c_circ_true[i]).abs())
        .fold(0.0_f64, f64::max);

    // B. 3x3 Hankel matrix (N = 5 = 2*3 - 1): H_{ij} = c_{i+j}
    let c_hank_true = [1.5_f64, -0.8, 2.2, 0.4, -1.1];
    let f_h1 = [1.0_f64, 0.7, -0.4];
    let f_h2 = [-0.5_f64, 1.3, 0.9];
    let assemble_hankel_probe = |probe: &[f64; 3]| -> (Vec<Vec<f64>>, Vec<f64>) {
        let mut g = vec![vec![0.0_f64; 5]; 3];
        let mut u = vec![0.0_f64; 3];
        for r in 0..3 {
            for col in 0..3 {
                let k = r + col;
                g[r][k] += probe[col];
                u[r] += c_hank_true[k] * probe[col];
            }
        }
        (g, u)
    };
    let (g_h1, u_h1) = assemble_hankel_probe(&f_h1);
    let qr_h1 = wias_column_pivoted_qr_solve(&g_h1, &u_h1, 1e-10).unwrap();
    let (g_h2, u_h2) = assemble_hankel_probe(&f_h2);
    let mut g_h_both = g_h1.clone();
    g_h_both.extend(g_h2);
    let mut u_h_both = u_h1.clone();
    u_h_both.extend(u_h2);
    let qr_h2 = wias_column_pivoted_qr_solve(&g_h_both, &u_h_both, 1e-10).unwrap();
    let hank_err = (0..5)
        .map(|i| (qr_h2.coeffs[i] - c_hank_true[i]).abs())
        .fold(0.0_f64, f64::max);

    // Exact 2x2 Hankel 2-probe analytic determinant: -f1 * (f0*g1 - f1*g0)
    let h2_det = -f_h1[1] * plucker_2d_coord(f_h1[0], f_h1[1], f_h2[0], f_h2[1]);

    // B2. Large-dimension scaling check (n = 40, mirroring NBoulle/wias 05 & 06):
    // 40x40 Circulant (1-shot, N=40) vs. 40x79 Hankel (1-shot deficit -> 80x79 2-shot full rank)
    let n40 = 40_usize;
    let c40_true: Vec<f64> = (0..n40).map(|i| ((i as f64 + 1.0) * 0.37).sin()).collect();
    let f40: Vec<f64> = (0..n40).map(|i| ((i as f64 + 1.0) * 1.13).cos() + 0.15 * (i == 0) as i32 as f64).collect();
    let mut g_c40 = vec![vec![0.0_f64; n40]; n40];
    let mut u_c40 = vec![0.0_f64; n40];
    for r in 0..n40 {
        for k in 0..n40 {
            let val = f40[(r + n40 - k) % n40];
            g_c40[r][k] = val;
            u_c40[r] += c40_true[k] * val;
        }
    }
    let qr_c40 = wias_column_pivoted_qr_solve(&g_c40, &u_c40, 1e-10).unwrap();
    let c40_err = (0..n40)
        .map(|i| (qr_c40.coeffs[i] - c40_true[i]).abs())
        .fold(0.0_f64, f64::max);

    let n_hank40 = 2 * n40 - 1; // 79
    let ch40_true: Vec<f64> = (0..n_hank40).map(|i| ((i as f64 + 1.0) * 0.29).cos()).collect();
    let fh1: Vec<f64> = (0..n40).map(|i| ((i as f64 + 1.0) * 0.71).sin()).collect();
    let fh2: Vec<f64> = (0..n40).map(|i| ((i as f64 + 1.0) * 1.41).cos()).collect();
    let assemble_h40 = |probe: &[f64]| -> (Vec<Vec<f64>>, Vec<f64>) {
        let mut g = vec![vec![0.0_f64; n_hank40]; n40];
        let mut u = vec![0.0_f64; n40];
        for r in 0..n40 {
            for col in 0..n40 {
                let k = r + col;
                g[r][k] += probe[col];
                u[r] += ch40_true[k] * probe[col];
            }
        }
        (g, u)
    };
    let (g_h40_1, u_h40_1) = assemble_h40(&fh1);
    let qr_h40_1 = wias_column_pivoted_qr_solve(&g_h40_1, &u_h40_1, 1e-10).unwrap();
    let (g_h40_2, u_h40_2) = assemble_h40(&fh2);
    let mut g_h40_both = g_h40_1;
    g_h40_both.extend(g_h40_2);
    let mut u_h40_both = u_h40_1;
    u_h40_both.extend(u_h40_2);
    let qr_h40_2 = wias_column_pivoted_qr_solve(&g_h40_both, &u_h40_both, 1e-10).unwrap();
    let h40_err = (0..n_hank40)
        .map(|i| (qr_h40_2.coeffs[i] - ch40_true[i]).abs())
        .fold(0.0_f64, f64::max);

    // C. Coherent Quantum Switch 1-shot non-commuting probe:
    // U_A = cos(theta)*I + i*sin(theta)*X at theta = pi/6, U_B = Z on |0>
    let theta = std::f64::consts::FRAC_PI_6;
    let ua = [
        [(theta.cos(), 0.0), (0.0, theta.sin())],
        [(0.0, theta.sin()), (theta.cos(), 0.0)],
    ];
    let ub = [[(1.0, 0.0), (0.0, 0.0)], [(0.0, 0.0), (-1.0, 0.0)]];
    let psi0 = [(1.0, 0.0), (0.0, 0.0)];
    let (e_sym, e_anti, _) = evaluate_quantum_switch_2x2(&ua, &ub, &psi0);
    let (_, _, sw_ratio) = quantum_switch_gr24_plucker_channels(e_sym, e_anti);

    // Pole-free VRC destructive constraint cancellation at x_X = -1
    let vrc_dest = qci_ncm_coherent_pairwise_code_prob(0.75, 0.25, -0.75, -0.25);

    OsidMatrixAndSwitchAudit {
        circulant_rank_1shot: qr_circ.rank,
        circulant_max_err: circ_err,
        circulant_gram_det: qr_circ.gram_det,
        circulant_n40_rank: qr_c40.rank,
        circulant_n40_max_err: c40_err,
        hankel_1shot_rows: 3,
        hankel_1shot_cols: 5,
        hankel_1shot_rank: qr_h1.rank,
        hankel_2shot_rank: qr_h2.rank,
        hankel_2shot_max_err: hank_err,
        hankel_n40_1shot_rank: qr_h40_1.rank,
        hankel_n40_2shot_rank: qr_h40_2.rank,
        hankel_n40_2shot_max_err: h40_err,
        hankel_2x2_two_probe_det: h2_det,
        switch_e_sym: e_sym,
        switch_e_anti: e_anti,
        switch_plucker_ratio: sw_ratio,
        vrc_destructive_minor: vrc_dest,
    }
}

/// Benchmark 4: Soft-partition noisy `Jeffrey's Kinematic Engine`, `QFIM = 4 g_FS` QCRB,
/// and 1-shot vs. `M`-shot closed-loop Landauer heat.
#[derive(Clone, Debug)]
pub struct OsidNoisyJeffreyQfimLandauerAudit {
    pub jeffrey_do_estimate: f64,
    pub quantum_jeffrey_phase_avg: f64,
    pub qfim: f64,
    pub qcrb_1shot_var_bound: f64,
    pub qcrb_4shot_var_bound: f64,
    pub landauer_1shot_closed_heat: f64,
    pub landauer_10shot_closed_heat: f64,
}

pub fn audit_osid_noisy_jeffrey_qfim_landauer() -> OsidNoisyJeffreyQfimLandauerAudit {
    let q1 = 0.78_f64;
    let q2 = 0.22_f64;
    let c1_do = 10.0_f64;
    let c2_do = 2.0_f64;
    let j_do = jeffrey_kinematic_update(q1, q2, c1_do, c2_do);
    let qj_plus = quantum_jeffrey_plucker_kinematic_update(q1, q2, c1_do, c2_do, 0.5, 0.6, 0.2, 0.4, -0.3);
    let qj_minus =
        quantum_jeffrey_plucker_kinematic_update(q1, q2, c1_do, c2_do, 0.5, 0.6, 0.2, -0.4, 0.3);
    let phase_avg = 0.5 * (qj_plus + qj_minus);

    let g_fs = 1.25_f64;
    let qfim = 4.0 * g_fs;
    let qcrb_1 = 1.0 / qfim;
    let qcrb_4 = 1.0 / (4.0 * qfim);

    let kbt_ln2 = 1.0_f64;
    let fidelity = 0.99_f64;
    let q_oh = 0.25_f64;
    let h1 = closed_loop_erasure_and_memory_reset_heat(kbt_ln2, fidelity, q_oh);
    let h10 = 10.0 * h1;

    OsidNoisyJeffreyQfimLandauerAudit {
        jeffrey_do_estimate: j_do,
        quantum_jeffrey_phase_avg: phase_avg,
        qfim,
        qcrb_1shot_var_bound: qcrb_1,
        qcrb_4shot_var_bound: qcrb_4,
        landauer_1shot_closed_heat: h1,
        landauer_10shot_closed_heat: h10,
    }
}

/// Classical Jacobi eigenvalue decomposition for a small $n \times n$ real symmetric matrix,
/// returning `(sorted_eigenvalues_asc, column_eigenvectors)` in row-major `[n][n]`.
fn jacobi_symmetric_eigen(n: usize, a_in: &[f64]) -> (Vec<f64>, Vec<f64>) {
    let mut a = a_in.to_vec();
    let mut v = vec![0.0_f64; n * n];
    for i in 0..n {
        v[i * n + i] = 1.0;
    }
    for _sweep in 0..80 {
        let mut max_off = 0.0_f64;
        for p in 0..n {
            for q in (p + 1)..n {
                max_off = max_off.max(a[p * n + q].abs());
            }
        }
        if max_off < 1e-15 {
            break;
        }
        for p in 0..n {
            for q in (p + 1)..n {
                let apq = a[p * n + q];
                if apq.abs() < 1e-16 {
                    continue;
                }
                let app = a[p * n + p];
                let aqq = a[q * n + q];
                let tau = (aqq - app) / (2.0 * apq);
                let t = if tau >= 0.0 {
                    1.0 / (tau + (1.0 + tau * tau).sqrt())
                } else {
                    -1.0 / (-tau + (1.0 + tau * tau).sqrt())
                };
                let c = 1.0 / (1.0 + t * t).sqrt();
                let s = t * c;
                let h = s / (1.0 + c);

                a[p * n + p] = app - t * apq;
                a[q * n + q] = aqq + t * apq;
                a[p * n + q] = 0.0;
                a[q * n + p] = 0.0;

                for r in 0..n {
                    if r != p && r != q {
                        let arp = a[r * n + p];
                        let arq = a[r * n + q];
                        let new_rp = arp - s * (arq + h * arp);
                        let new_rq = arq + s * (arp - h * arq);
                        a[r * n + p] = new_rp;
                        a[p * n + r] = new_rp;
                        a[r * n + q] = new_rq;
                        a[q * n + r] = new_rq;
                    }
                }
                for r in 0..n {
                    let vrp = v[r * n + p];
                    let vrq = v[r * n + q];
                    v[r * n + p] = c * vrp - s * vrq;
                    v[r * n + q] = s * vrp + c * vrq;
                }
            }
        }
    }
    let mut order: Vec<usize> = (0..n).collect();
    order.sort_by(|&i, &j| {
        a[i * n + i]
            .partial_cmp(&a[j * n + j])
            .unwrap_or(std::cmp::Ordering::Equal)
    });
    let evals: Vec<f64> = order.iter().map(|&idx| a[idx * n + idx]).collect();
    let mut evecs = vec![0.0_f64; n * n];
    for (col_new, &col_old) in order.iter().enumerate() {
        for r in 0..n {
            evecs[r * n + col_new] = v[r * n + col_old];
        }
    }
    (evals, evecs)
}

/// Literature Benchmark 5 (`NBoulle/wias/examples/02_duffing.ipynb`, Fig. 1D):
/// Forced Duffing oscillator `u'' + δ u' + α u + β u^3 = γ cos(ω t)`
/// (`α=1, β=5, δ=0.02, γ=8, ω=0.5`, `u(0)=0.49671415, v(0)=0`)
/// with 11-term polynomial dictionary `[u'', 1, u, v, u^2, uv, v^2, u^3, u^2v, uv^2, v^3]`
/// and second-order weak integration by parts using compactly supported `sin^4(π τ)` test windows.
#[derive(Clone, Debug)]
pub struct OsidDuffingAudit {
    pub rank: usize,
    pub theta_udd: f64,
    pub recovered_alpha: f64,
    pub recovered_delta: f64,
    pub recovered_beta: f64,
    pub recovered_gamma: f64,
    pub max_coeff_err: f64,
    pub sigma_min: f64,
}

pub fn audit_osid_duffing_oscillator() -> OsidDuffingAudit {
    let alpha = 1.0_f64;
    let beta = 5.0_f64;
    let delta = 0.02_f64;
    let gamma = 8.0_f64;
    let omega = 0.5_f64;

    let dt = 0.001_f64;
    let n_steps = 32_000_usize;
    let mut us = Vec::with_capacity(n_steps + 1);
    let mut vs = Vec::with_capacity(n_steps + 1);
    let mut ts = Vec::with_capacity(n_steps + 1);
    let mut u = 0.49671415_f64;
    let mut v = 0.0_f64;

    let rhs = |t_val: f64, u_val: f64, v_val: f64| -> (f64, f64) {
        let du = v_val;
        let dv = -delta * v_val - alpha * u_val - beta * u_val * u_val * u_val
            + gamma * (omega * t_val).cos();
        (du, dv)
    };

    for step in 0..=n_steps {
        let t = step as f64 * dt;
        ts.push(t);
        us.push(u);
        vs.push(v);
        if step < n_steps {
            let (k1u, k1v) = rhs(t, u, v);
            let (k2u, k2v) = rhs(t + 0.5 * dt, u + 0.5 * dt * k1u, v + 0.5 * dt * k1v);
            let (k3u, k3v) = rhs(t + 0.5 * dt, u + 0.5 * dt * k2u, v + 0.5 * dt * k2v);
            let (k4u, k4v) = rhs(t + dt, u + dt * k3u, v + dt * k3v);
            u += (dt / 6.0) * (k1u + 2.0 * k2u + 2.0 * k3u + k4u);
            v += (dt / 6.0) * (k1v + 2.0 * k2v + 2.0 * k3v + k4v);
        }
    }

    // 28 overlapping sub-windows of length 4000 steps (4.0 s) on [0, 32]
    let n_rows = 28_usize;
    let n_cols = 11_usize; // [u'', 1, u, v, u^2, uv, v^2, u^3, u^2v, uv^2, v^3]
    let win_steps = 4_000_usize; // even for Simpson 1/3
    let stride = 1_000_usize;
    let win_dur = win_steps as f64 * dt;
    let pi = std::f64::consts::PI;

    let mut a_rows = Vec::with_capacity(n_rows);
    let mut b_rhs = Vec::with_capacity(n_rows);

    for k in 0..n_rows {
        let i0 = k * stride;
        let mut row = vec![0.0_f64; n_cols];
        let mut rhs_int = 0.0_f64;
        for m in 0..=win_steps {
            let simp = if m == 0 || m == win_steps {
                1.0
            } else if m % 2 == 1 {
                4.0
            } else {
                2.0
            };
            let w_simp = simp * dt / 3.0;
            let tau = m as f64 / win_steps as f64;
            let s = (pi * tau).sin();
            let c = (pi * tau).cos();
            let s2 = s * s;
            let phi = s2 * s2; // sin^4(pi tau)
            let dphi_dtau = 4.0 * pi * s2 * s * c;
            let d2phi_dtau2 = 4.0 * pi * pi * s2 * (3.0 * c * c - s2);
            let dphi = dphi_dtau / win_dur;
            let d2phi = d2phi_dtau2 / (win_dur * win_dur);

            let idx = i0 + m;
            let uk = us[idx];
            let vk = vs[idx];
            let tk = ts[idx];

            // Integration by parts: int phi u'' dt = int phi'' u dt (boundary = 0)
            row[0] += w_simp * d2phi * uk;
            row[1] += w_simp * phi * 1.0;
            row[2] += w_simp * phi * uk;
            row[3] += w_simp * (-dphi * uk); // weak velocity int phi u' = -int phi' u
            row[4] += w_simp * phi * (uk * uk);
            row[5] += w_simp * phi * (uk * vk);
            row[6] += w_simp * phi * (vk * vk);
            row[7] += w_simp * phi * (uk * uk * uk);
            row[8] += w_simp * phi * (uk * uk * vk);
            row[9] += w_simp * phi * (uk * vk * vk);
            row[10] += w_simp * phi * (vk * vk * vk);
            rhs_int += w_simp * phi * (gamma * (omega * tk).cos());
        }
        a_rows.push(row);
        b_rhs.push(rhs_int);
    }

    let qr = wias_column_pivoted_qr_solve(&a_rows, &b_rhs, 1e-10)
        .expect("Duffing weak system solve should succeed");
    let theta_udd = qr.coeffs[0];
    // Weak system: theta_0 * u'' + theta_1 * 1 + theta_2 * u + theta_3 * v + ... + theta_7 * u^3 = gamma cos(omega t)
    // True coefficients in normalized form u'' = sum_k c_k lib_k + gamma_rec cos(omega t)
    let norm_coeffs: Vec<f64> = qr.coeffs[1..].iter().map(|&c| -c / theta_udd).collect();
    let recovered_alpha = -norm_coeffs[1]; // -(-alpha)
    let recovered_delta = -norm_coeffs[2]; // -(-delta)
    let recovered_beta = -norm_coeffs[6]; // -(-beta)
    let recovered_gamma = gamma / theta_udd;

    let true_norm = [0.0, -alpha, -delta, 0.0, 0.0, 0.0, -beta, 0.0, 0.0, 0.0];
    let mut max_err = (recovered_gamma - gamma).abs();
    for j in 0..10 {
        max_err = max_err.max((norm_coeffs[j] - true_norm[j]).abs());
    }

    OsidDuffingAudit {
        rank: qr.rank,
        theta_udd,
        recovered_alpha,
        recovered_delta,
        recovered_beta,
        recovered_gamma,
        max_coeff_err: max_err,
        sigma_min: qr.sigma_min_est,
    }
}

/// Literature Benchmark 6 (`NBoulle/wias/examples/03_allen_cahn.ipynb`, `04_navier_stokes.ipynb`,
/// & `arXiv:2611.30470v1` Proposition 36):
/// 2D Quintic Allen–Cahn (`0.25 Δu - 5 u - u^3 + u^5 = f`), 2D Elliptic coprime ray
/// `(m, n) = (2, 3)` kernel collapse `ker = span{(9, -4)}`, and 2D Navier–Stokes continuity
/// nullspace (`Dx ux + Dy uy = 0`).
#[derive(Clone, Debug)]
pub struct Osid2dPdesAudit {
    pub allen_cahn_2d_rank: usize,
    pub allen_cahn_2d_max_coeff_err: f64,
    pub elliptic_coprime_rank: usize,
    pub elliptic_coprime_gram_det: f64,
    pub elliptic_coprime_ray_residual: f64,
    pub elliptic_multimode_rank: usize,
    pub elliptic_multimode_max_err: f64,
    pub ns_continuity_rank: usize,
    pub ns_continuity_sigma4: f64,
    pub ns_continuity_max_coeff_err: f64,
    pub ns_momentum_rank: usize,
    pub ns_momentum_recovered_nu: f64,
    pub ns_momentum_max_coeff_err: f64,
}

pub fn audit_osid_2d_pdes_allen_cahn_elliptic_ns() -> Osid2dPdesAudit {
    let pi = std::f64::consts::PI;
    let n_grid = 32_usize;
    let h = 1.0 / n_grid as f64;

    // 1. 2D Quintic Allen–Cahn: 0.25 (u_xx + u_yy) - 5 u - u^3 + u^5 = f on (0,1)^2
    let mut ac_rows = Vec::new();
    let mut ac_rhs = Vec::new();
    let modes = [
        (1, 1), (2, 1), (1, 2), (2, 2),
        (3, 1), (1, 3), (3, 2), (2, 3),
        (3, 3), (4, 1), (1, 4), (4, 2),
        (2, 4), (4, 3), (3, 4), (4, 4),
    ];
    // Use 4x4 overlapping localized compactly-supported test patches on (0,1)^2
    // so {1, u, u^2, u^3, u^4, u^5} are well-conditioned across varying local amplitudes.
    let patch_w = 0.4_f64;
    for px in 0..4_usize {
        for py in 0..4_usize {
            let x0 = 0.05 + 0.16 * px as f64;
            let y0 = 0.05 + 0.16 * py as f64;
            let mut row = vec![0.0_f64; 9]; // {u_xx, u_xy, u_yy, 1, u, u^2, u^3, u^4, u^5}
            let mut b_val = 0.0_f64;
            for ix in 0..=n_grid {
                let wx = if ix == 0 || ix == n_grid { 1.0 } else if ix % 2 == 1 { 4.0 } else { 2.0 };
                let x = ix as f64 * h;
                if x <= x0 || x >= x0 + patch_w {
                    continue;
                }
                let vx = (pi * (x - x0) / patch_w).sin().powi(2);
                for iy in 0..=n_grid {
                    let wy = if iy == 0 || iy == n_grid { 1.0 } else if iy % 2 == 1 { 4.0 } else { 2.0 };
                    let y = iy as f64 * h;
                    if y <= y0 || y >= y0 + patch_w {
                        continue;
                    }
                    let vy = (pi * (y - y0) / patch_w).sin().powi(2);
                    let w = (wx * h / 3.0) * (wy * h / 3.0);

                    // Smooth asymmetric Dirichlet state: u(x,y) = sin(pi x)sin(pi y) * g(x,y)
                    let sx = (pi * x).sin();
                    let sy = (pi * y).sin();
                    let cx = (pi * x).cos();
                    let cy = (pi * y).cos();
                    let g = 1.0 + 0.6 * x + 0.5 * y * y + 0.3 * x * y;
                    let gx = 0.6 + 0.3 * y;
                    let gy = y + 0.3 * x;
                    let gxx = 0.0;
                    let gyy = 1.0;
                    let gxy = 0.3;

                    let u = sx * sy * g;
                    let u_xx = sy * (-pi * pi * sx * g + 2.0 * pi * cx * gx + sx * gxx);
                    let u_yy = sx * (-pi * pi * sy * g + 2.0 * pi * cy * gy + sy * gyy);
                    let u_xy = pi * pi * cx * cy * g + pi * cx * sy * gy + pi * sx * cy * gx + sx * sy * gxy;
                    let f = 0.25 * (u_xx + u_yy) - 5.0 * u - u * u * u + u.powi(5);

                    let v = vx * vy;
                    row[0] += w * v * u_xx;
                    row[1] += w * v * u_xy;
                    row[2] += w * v * u_yy;
                    row[3] += w * v * 1.0;
                    row[4] += w * v * u;
                    row[5] += w * v * (u * u);
                    row[6] += w * v * (u * u * u);
                    row[7] += w * v * u.powi(4);
                    row[8] += w * v * u.powi(5);
                    b_val += w * v * f;
                }
            }
            ac_rows.push(row);
            ac_rhs.push(b_val);
        }
    }
    let qr_ac = wias_column_pivoted_qr_solve(&ac_rows, &ac_rhs, 1e-11)
        .expect("2D Allen-Cahn weak system solve should succeed");
    let ac_true = [0.25, 0.0, 0.25, 0.0, -5.0, 0.0, -1.0, 0.0, 1.0];
    let mut ac_err = 0.0_f64;
    for j in 0..9 {
        ac_err = ac_err.max((qr_ac.coeffs[j] - ac_true[j]).abs());
    }

    // 2. 2D Elliptic coprime ray (m=2, n=3) Proposition 36 degeneracy vs. multi-mode recovery
    let ell_tests = [(1, 1), (2, 3), (4, 6), (1, 2)];
    let mut deg_rows = Vec::new();
    let mut deg_rhs = Vec::new();
    let mut mul_rows = Vec::new();
    let mut mul_rhs = Vec::new();
    for &(kx, ky) in &ell_tests {
        let mut r_deg = vec![0.0_f64; 2];
        let mut b_deg = 0.0_f64;
        let mut r_mul = vec![0.0_f64; 2];
        let mut b_mul = 0.0_f64;
        for ix in 0..=n_grid {
            let wx = if ix == 0 || ix == n_grid { 1.0 } else if ix % 2 == 1 { 4.0 } else { 2.0 };
            let x = ix as f64 * h;
            for iy in 0..=n_grid {
                let wy = if iy == 0 || iy == n_grid { 1.0 } else if iy % 2 == 1 { 4.0 } else { 2.0 };
                let y = iy as f64 * h;
                let w = (wx * h / 3.0) * (wy * h / 3.0);
                let v = (kx as f64 * pi * x).sin() * (ky as f64 * pi * y).sin();

                // Coprime ray (m=2, n=3): k=1 and k=2
                let u_ray_xx = -pi * pi
                    * (4.0 * (2.0 * pi * x).sin() * (3.0 * pi * y).sin()
                        + 0.5 * 16.0 * (4.0 * pi * x).sin() * (6.0 * pi * y).sin());
                let u_ray_yy = -pi * pi
                    * (9.0 * (2.0 * pi * x).sin() * (3.0 * pi * y).sin()
                        + 0.5 * 36.0 * (4.0 * pi * x).sin() * (6.0 * pi * y).sin());
                r_deg[0] += w * v * u_ray_xx;
                r_deg[1] += w * v * u_ray_yy;
                b_deg += w * v * (2.0 * u_ray_xx + 3.0 * u_ray_yy);

                // Off-ray multi-mode: add sin(pi x)sin(2 pi y)
                let u_m_xx = u_ray_xx - pi * pi * (pi * x).sin() * (2.0 * pi * y).sin();
                let u_m_yy = u_ray_yy - 4.0 * pi * pi * (pi * x).sin() * (2.0 * pi * y).sin();
                r_mul[0] += w * v * u_m_xx;
                r_mul[1] += w * v * u_m_yy;
                b_mul += w * v * (2.0 * u_m_xx + 3.0 * u_m_yy);
            }
        }
        deg_rows.push(r_deg);
        deg_rhs.push(b_deg);
        mul_rows.push(r_mul);
        mul_rhs.push(b_mul);
    }
    let qr_deg = wias_column_pivoted_qr_solve(&deg_rows, &deg_rhs, 1e-10)
        .expect("2D elliptic coprime system solve should succeed");
    let qr_mul = wias_column_pivoted_qr_solve(&mul_rows, &mul_rhs, 1e-10)
        .expect("2D elliptic multimode system solve should succeed");
    let mul_err = (qr_mul.coeffs[0] - 2.0).abs().max((qr_mul.coeffs[1] - 3.0).abs());
    let mut ray_res = 0.0_f64;
    for r in &deg_rows {
        ray_res = ray_res.max((9.0 * r[0] - 4.0 * r[1]).abs());
    }

    // 3. 2D Navier–Stokes divergence-free continuity nullspace: {Dx ux, Dy uy, Dx uy, Dy ux}
    let mut ns_rows = Vec::new();
    for &(kx, ky) in &modes {
        let mut row = [0.0_f64; 4];
        for ix in 0..=n_grid {
            let wx = if ix == 0 || ix == n_grid { 1.0 } else if ix % 2 == 1 { 4.0 } else { 2.0 };
            let x = ix as f64 * h;
            for iy in 0..=n_grid {
                let wy = if iy == 0 || iy == n_grid { 1.0 } else if iy % 2 == 1 { 4.0 } else { 2.0 };
                let y = iy as f64 * h;
                let w = (wx * h / 3.0) * (wy * h / 3.0);
                // Streamfunction psi = sin^2(pi x) sin^2(pi y) -> u_x = psi_y, u_y = -psi_x
                let sx = (pi * x).sin();
                let _cx = (pi * x).cos();
                let sy = (pi * y).sin();
                let _cy = (pi * y).cos();
                let s2x = (2.0 * pi * x).sin();
                let c2x = (2.0 * pi * x).cos();
                let s2y = (2.0 * pi * y).sin();
                let c2y = (2.0 * pi * y).cos();

                let dx_ux = pi * pi * s2x * s2y;
                let dy_uy = -pi * pi * s2x * s2y;
                let dx_uy = -2.0 * pi * pi * c2x * sy * sy;
                let dy_ux = 2.0 * pi * pi * sx * sx * c2y;
                let q_test = (kx as f64 * pi * x).sin() * (ky as f64 * pi * y).sin();
                row[0] += w * q_test * dx_ux;
                row[1] += w * q_test * dy_uy;
                row[2] += w * q_test * dx_uy;
                row[3] += w * q_test * dy_ux;
            }
        }
        ns_rows.push(row);
    }
    let mut ns_gram = vec![0.0_f64; 16];
    for r in &ns_rows {
        for i in 0..4 {
            for j in 0..4 {
                ns_gram[i * 4 + j] += r[i] * r[j];
            }
        }
    }
    let (ns_evals, ns_evecs) = jacobi_symmetric_eigen(4, &ns_gram);
    let sigma4 = ns_evals[0].max(0.0).sqrt();
    let ns_rank = ns_evals.iter().filter(|&&ev| ev > 1e-18).count();
    let v0 = ns_evecs[0]; // row 0, col 0
    let scale = if v0.abs() > 1e-12 { 1.0 / v0 } else { 1.0 };
    let rec_c = [
        ns_evecs[0] * scale,
        ns_evecs[4] * scale,
        ns_evecs[8] * scale,
        ns_evecs[12] * scale,
    ];
    let ns_true = [1.0, 1.0, 0.0, 0.0];
    let mut ns_err = 0.0_f64;
    for j in 0..4 {
        ns_err = ns_err.max((rec_c[j] - ns_true[j]).abs());
    }

    // 4. 2D Navier–Stokes 16-term momentum equation (NBoulle/wias/examples/04_navier_stokes.ipynb, nu = 1e-3):
    // Columns 0..7: {Dx ux Dx vx, Dx ux Dy vx, Dy ux Dx vx, Dy ux Dy vx,
    //                Dx uy Dx vy, Dx uy Dy vy, Dy uy Dx vy, Dy uy Dy vy} (true = [nu, 0, 0, nu, nu, 0, 0, nu])
    // Columns 8..15: {ux Dx ux vx, ux Dy ux vx, uy Dx ux vx, uy Dy ux vx,
    //                 ux Dx uy vy, ux Dy uy vy, uy Dx uy vy, uy Dy uy vy} (true = [1, 0, 0, 1, 1, 0, 0, 1])
    let nu_true = 1e-3_f64;
    let mom_true = [
        nu_true, 0.0, 0.0, nu_true, nu_true, 0.0, 0.0, nu_true,
        1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0,
    ];
    let mut mom_rows = Vec::with_capacity(24);
    let mut mom_rhs = Vec::with_capacity(24);
    // Use 24 vector test functions v = (phi_{kx, ky}, 0) and (0, phi_{kx, ky}) across 3x4 modes
    let mom_modes = [
        (1, 1), (2, 1), (1, 2), (2, 2),
        (3, 1), (1, 3), (3, 2), (2, 3),
        (3, 3), (4, 1), (1, 4), (4, 2),
    ];
    for comp in 0..2_usize {
        for &(kx, ky) in &mom_modes {
            let mut row = vec![0.0_f64; 16];
            let mut rhs_val = 0.0_f64;
            for ix in 0..=n_grid {
                let wx = if ix == 0 || ix == n_grid { 1.0 } else if ix % 2 == 1 { 4.0 } else { 2.0 };
                let x = ix as f64 * h;
                for iy in 0..=n_grid {
                    let wy = if iy == 0 || iy == n_grid { 1.0 } else if iy % 2 == 1 { 4.0 } else { 2.0 };
                    let y = iy as f64 * h;
                    let w = (wx * h / 3.0) * (wy * h / 3.0);

                    // Non-symmetric divergence-free streamfunction:
                    // psi(x, y) = sin(pi x) sin(pi y) * (1.0 + 0.7 x + 0.5 y^2)
                    let sx = (pi * x).sin();
                    let cx = (pi * x).cos();
                    let sy = (pi * y).sin();
                    let cy = (pi * y).cos();
                    let g = 1.0 + 0.7 * x + 0.5 * y * y;
                    let gx = 0.7;
                    let gy = y;
                    let gxx = 0.0;
                    let gyy = 1.0;
                    let gxy = 0.0;

                    let ux = sx * (pi * cy * g + sy * gy);
                    let uy = -sy * (pi * cx * g + sx * gx);
                    let dx_ux = pi * cx * (pi * cy * g + sy * gy) + sx * (pi * cy * gx);
                    let dy_ux = sx * (-pi * pi * sy * g + 2.0 * pi * cy * gy + sy * gyy);
                    let dx_uy = -sy * (-pi * pi * sx * g + 2.0 * pi * cx * gx + sx * gxx);
                    let dy_uy = -(pi * cy * (pi * cx * g + sx * gx) + sy * (pi * cx * gy + sx * gxy));

                    let skx = (kx as f64 * pi * x).sin();
                    let ckx = (kx as f64 * pi * x).cos();
                    let sky = (ky as f64 * pi * y).sin();
                    let cky = (ky as f64 * pi * y).cos();
                    let v_val = skx * sky;
                    let dv_dx = kx as f64 * pi * ckx * sky;
                    let dv_dy = ky as f64 * pi * skx * cky;

                    let (vx, dx_vx, dy_vx, vy, dx_vy, dy_vy) = if comp == 0 {
                        (v_val, dv_dx, dv_dy, 0.0, 0.0, 0.0)
                    } else {
                        (0.0, 0.0, 0.0, v_val, dv_dx, dv_dy)
                    };

                    let terms = [
                        dx_ux * dx_vx,
                        dx_ux * dy_vx,
                        dy_ux * dx_vx,
                        dy_ux * dy_vx,
                        dx_uy * dx_vy,
                        dx_uy * dy_vy,
                        dy_uy * dx_vy,
                        dy_uy * dy_vy,
                        ux * dx_ux * vx,
                        ux * dy_ux * vx,
                        uy * dx_ux * vx,
                        uy * dy_ux * vx,
                        ux * dx_uy * vy,
                        ux * dy_uy * vy,
                        uy * dx_uy * vy,
                        uy * dy_uy * vy,
                    ];
                    let mut contrib = 0.0_f64;
                    for j in 0..16 {
                        row[j] += w * terms[j];
                        contrib += mom_true[j] * terms[j];
                    }
                    rhs_val += w * contrib;
                }
            }
            mom_rows.push(row);
            mom_rhs.push(rhs_val);
        }
    }
    let qr_mom = wias_column_pivoted_qr_solve(&mom_rows, &mom_rhs, 1e-11)
        .expect("2D Navier-Stokes 16-term momentum solve should succeed");
    let mut mom_err = 0.0_f64;
    for j in 0..16 {
        mom_err = mom_err.max((qr_mom.coeffs[j] - mom_true[j]).abs());
    }
    let mom_nu_rec = 0.25 * (qr_mom.coeffs[0] + qr_mom.coeffs[3] + qr_mom.coeffs[4] + qr_mom.coeffs[7]);

    Osid2dPdesAudit {
        allen_cahn_2d_rank: qr_ac.rank,
        allen_cahn_2d_max_coeff_err: ac_err,
        elliptic_coprime_rank: qr_deg.rank,
        elliptic_coprime_gram_det: qr_deg.gram_det,
        elliptic_coprime_ray_residual: ray_res,
        elliptic_multimode_rank: qr_mul.rank,
        elliptic_multimode_max_err: mul_err,
        ns_continuity_rank: ns_rank,
        ns_continuity_sigma4: sigma4,
        ns_continuity_max_coeff_err: ns_err,
        ns_momentum_rank: qr_mom.rank,
        ns_momentum_recovered_nu: mom_nu_rec,
        ns_momentum_max_coeff_err: mom_err,
    }
}

/// Literature Benchmark 7 (`Qi & Ranard 2019`, *Quantum* 3, 159, `arXiv:1712.01850v2` &
/// `Bairey, Arad, & Lindner 2019`, *PRL* 122, 020504, `arXiv:1807.04564v2`):
/// Exact 4-qubit ($d = 16$) disordered transverse + longitudinal Ising spin chain,
/// recovering all $N = 8$ Hamiltonian couplings up to scale from **one single ground eigenstate**
/// via Qi–Ranard's $k$-correlation matrix `M_{ij}(v) = (1/2)⟨{L_i, L_j}⟩ - ⟨L_i⟩⟨L_j⟩`,
/// and verifying Bairey–Arad–Lindner's commutator kernel `K c_true = 0`.
#[derive(Clone, Debug)]
pub struct OsidQiRanardHamiltonianAudit {
    pub num_qubits: usize,
    pub local_basis_dim: usize,
    pub hilbert_dim: usize,
    pub correlation_lambda1: f64,
    pub correlation_lambda2: f64,
    pub projective_angle_err_rad: f64,
    pub max_scaled_coeff_err: f64,
    pub qi_ranard_dk_lhs: f64,
    pub qi_ranard_dk_rhs: f64,
    pub bairey_commutator_residual: f64,
    pub bairey_ktk_lambda1: f64,
    pub bairey_ktk_lambda2: f64,
    pub bairey_recovered_max_err: f64,
}

pub fn audit_osid_qi_ranard_hamiltonian() -> OsidQiRanardHamiltonianAudit {
    let n_qubits = 4_usize;
    let dim = 16_usize;
    // Build real symmetric 16x16 Pauli operators on 4 qubits:
    // L_0..L_2 = Z_i Z_{i+1}, L_3..L_6 = X_i, L_7 = Z_0 (breaks Z2 parity)
    let pauli_z_at = |q: usize, basis: usize| -> f64 {
        let bit = (basis >> (n_qubits - 1 - q)) & 1;
        if bit == 0 { 1.0 } else { -1.0 }
    };
    let mut basis_ops: Vec<Vec<f64>> = Vec::with_capacity(8);
    // Z_i Z_{i+1}
    for i in 0..3 {
        let mut mat = vec![0.0_f64; dim * dim];
        for b in 0..dim {
            mat[b * dim + b] = pauli_z_at(i, b) * pauli_z_at(i + 1, b);
        }
        basis_ops.push(mat);
    }
    // X_i
    for i in 0..4 {
        let mut mat = vec![0.0_f64; dim * dim];
        let flip = 1_usize << (n_qubits - 1 - i);
        for b in 0..dim {
            mat[b * dim + (b ^ flip)] = 1.0;
        }
        basis_ops.push(mat);
    }
    // Z_0
    {
        let mut mat = vec![0.0_f64; dim * dim];
        for b in 0..dim {
            mat[b * dim + b] = pauli_z_at(0, b);
        }
        basis_ops.push(mat);
    }

    let c_true = [1.10_f64, -0.80, 1.30, 0.70, -0.50, 0.90, -0.40, 0.35];
    let n_basis = basis_ops.len();
    let mut h_mat = vec![0.0_f64; dim * dim];
    for (k, op) in basis_ops.iter().enumerate() {
        for idx in 0..(dim * dim) {
            h_mat[idx] += c_true[k] * op[idx];
        }
    }

    // Exact ground state |v0> via Jacobi eigensolver
    let (_evals_h, evecs_h) = jacobi_symmetric_eigen(dim, &h_mat);
    let v0: Vec<f64> = (0..dim).map(|r| evecs_h[r * dim]).collect();

    let matvec = |m: &[f64], vec: &[f64]| -> Vec<f64> {
        let mut out = vec![0.0_f64; dim];
        for r in 0..dim {
            let mut sum = 0.0;
            for c in 0..dim {
                sum += m[r * dim + c] * vec[c];
            }
            out[r] = sum;
        }
        out
    };
    let dot = |a: &[f64], b: &[f64]| -> f64 { a.iter().zip(b.iter()).map(|(&x, &y)| x * y).sum() };

    let lv: Vec<Vec<f64>> = basis_ops.iter().map(|op| matvec(op, &v0)).collect();
    let exp_l: Vec<f64> = lv.iter().map(|vec| dot(&v0, vec)).collect();

    let mut corr_m = vec![0.0_f64; n_basis * n_basis];
    for i in 0..n_basis {
        for j in i..n_basis {
            // (1/2)<v0|{L_i, L_j}|v0> = <L_i v0 | L_j v0> because L_i, L_j are Hermitian & real!
            let val = dot(&lv[i], &lv[j]) - exp_l[i] * exp_l[j];
            corr_m[i * n_basis + j] = val;
            corr_m[j * n_basis + i] = val;
        }
    }

    let (m_evals, m_evecs) = jacobi_symmetric_eigen(n_basis, &corr_m);
    let w_rec: Vec<f64> = (0..n_basis).map(|r| m_evecs[r * n_basis]).collect();
    let c_norm = dot(&c_true, &c_true).sqrt();
    let c_unit: Vec<f64> = c_true.iter().map(|&x| x / c_norm).collect();
    let raw_overlap = dot(&w_rec, &c_unit);
    let sign = if raw_overlap >= 0.0 { 1.0 } else { -1.0 };
    let overlap = raw_overlap.abs().min(1.0);
    let angle_err = overlap.acos();

    let mut max_scaled_err = 0.0_f64;
    for i in 0..n_basis {
        let rec_i = sign * w_rec[i] * c_norm;
        max_scaled_err = max_scaled_err.max((rec_i - c_true[i]).abs());
    }

    // Davis–Kahan empirical perturbation check (Qi & Ranard Eq. 3.7):
    // Inject deterministic perturbation ΔM of spectral norm ~ 1e-5 into M(v0)
    // and verify (1/2) sin(2 theta_noisy) <= ||ΔM||_2 / lambda_2.
    let mut delta_m = vec![0.0_f64; n_basis * n_basis];
    let eps_dm = 1e-5_f64;
    for i in 0..n_basis {
        for j in i..n_basis {
            let val = eps_dm * (((i + 1) * (j + 2)) as f64 * 0.73).sin();
            delta_m[i * n_basis + j] = val;
            delta_m[j * n_basis + i] = val;
        }
    }
    let (dm_evals, _) = jacobi_symmetric_eigen(n_basis, &delta_m);
    let dm_norm_2 = dm_evals.iter().map(|x| x.abs()).fold(0.0_f64, f64::max);
    let corr_m_pert: Vec<f64> = corr_m.iter().zip(delta_m.iter()).map(|(&a, &b)| a + b).collect();
    let (_, mp_evecs) = jacobi_symmetric_eigen(n_basis, &corr_m_pert);
    let w_pert: Vec<f64> = (0..n_basis).map(|r| mp_evecs[r * n_basis]).collect();
    let pert_overlap = dot(&w_pert, &c_unit).abs().min(1.0);
    let theta_pert = pert_overlap.acos();
    let dk_lhs = 0.5 * (2.0 * theta_pert).sin();
    let dk_rhs = dm_norm_2 / m_evals[1];

    // Independent Bairey–Arad–Lindner (2019) commutator matrix recovery:
    // K_{j, m} = <v0| [L_m, A_j] |v0> where A_j are 10 real-antisymmetric local 1- & 2-body operators:
    //   - i Y_q (q = 0..3)
    //   - i Y_q Z_{q+1} (q = 0..2)
    //   - i Z_q Y_{q+1} (q = 0..2)
    let mut anti_ops: Vec<Vec<f64>> = Vec::with_capacity(10);
    // 1. i Y_q
    for q in 0..4 {
        let flip = 1_usize << (n_qubits - 1 - q);
        let mut oy_mat = vec![0.0_f64; dim * dim];
        for b in 0..dim {
            let bit = (b >> (n_qubits - 1 - q)) & 1;
            let sgn = if bit == 0 { 1.0 } else { -1.0 };
            oy_mat[(b ^ flip) * dim + b] = sgn;
        }
        anti_ops.push(oy_mat);
    }
    // 2. i Y_q Z_{q+1}
    for q in 0..3 {
        let flip = 1_usize << (n_qubits - 1 - q);
        let mut mat = vec![0.0_f64; dim * dim];
        for b in 0..dim {
            let bit = (b >> (n_qubits - 1 - q)) & 1;
            let sgn = (if bit == 0 { 1.0 } else { -1.0 }) * pauli_z_at(q + 1, b);
            mat[(b ^ flip) * dim + b] = sgn;
        }
        anti_ops.push(mat);
    }
    // 3. i Z_q Y_{q+1}
    for q in 0..3 {
        let flip = 1_usize << (n_qubits - 1 - (q + 1));
        let mut mat = vec![0.0_f64; dim * dim];
        for b in 0..dim {
            let bit = (b >> (n_qubits - 1 - (q + 1))) & 1;
            let sgn = pauli_z_at(q, b) * (if bit == 0 { 1.0 } else { -1.0 });
            mat[(b ^ flip) * dim + b] = sgn;
        }
        anti_ops.push(mat);
    }

    let n_anti = anti_ops.len();
    let mut k_mat = vec![vec![0.0_f64; n_basis]; n_anti];
    let mut bairey_res = 0.0_f64;
    for (j, a_op) in anti_ops.iter().enumerate() {
        let av = matvec(a_op, &v0);
        for m_idx in 0..n_basis {
            // <v0| (L_m A_j - A_j L_m) |v0> = <L_m v0 | A_j v0> + <A_j v0 | L_m v0>
            // (since L_m^T = L_m and A_j^T = -A_j)
            k_mat[j][m_idx] = dot(&lv[m_idx], &av) + dot(&av, &lv[m_idx]);
        }
        let comm_true: f64 = (0..n_basis).map(|m_idx| k_mat[j][m_idx] * c_true[m_idx]).sum();
        bairey_res = bairey_res.max(comm_true.abs());
    }
    let mut ktk = vec![0.0_f64; n_basis * n_basis];
    for r in 0..n_anti {
        for p in 0..n_basis {
            for q in 0..n_basis {
                ktk[p * n_basis + q] += k_mat[r][p] * k_mat[r][q];
            }
        }
    }
    let (ktk_evals, ktk_evecs) = jacobi_symmetric_eigen(n_basis, &ktk);
    let w_bairey: Vec<f64> = (0..n_basis).map(|r| ktk_evecs[r * n_basis]).collect();
    let b_sign = if dot(&w_bairey, &c_unit) >= 0.0 { 1.0 } else { -1.0 };
    let mut bairey_rec_err = 0.0_f64;
    for i in 0..n_basis {
        let rec_i = b_sign * w_bairey[i] * c_norm;
        bairey_rec_err = bairey_rec_err.max((rec_i - c_true[i]).abs());
    }

    OsidQiRanardHamiltonianAudit {
        num_qubits: n_qubits,
        local_basis_dim: n_basis,
        hilbert_dim: dim,
        correlation_lambda1: m_evals[0],
        correlation_lambda2: m_evals[1],
        projective_angle_err_rad: angle_err,
        max_scaled_coeff_err: max_scaled_err,
        qi_ranard_dk_lhs: dk_lhs,
        qi_ranard_dk_rhs: dk_rhs,
        bairey_commutator_residual: bairey_res,
        bairey_ktk_lambda1: ktk_evals[0],
        bairey_ktk_lambda2: ktk_evals[1],
        bairey_recovered_max_err: bairey_rec_err,
    }
}

/// Literature Benchmark 8 (`Zhao, Yang, & Chiribella 2020`, *PRL* 124, 190503, `arXiv:1912.02449v4`,
/// `Goswami et al. 2018`, *PRL* 121, 090503, & `Rubino et al. 2017`, *Sci. Adv.* 3, e1602589):
/// Quantum Switch $1/N^2$ super-Heisenberg metrology (`Eqs. 5–7`, `Fig. 3` parameters) and
/// photonic experimental causal witness significance margins.
#[derive(Clone, Debug)]
pub struct OsidZhaoGoswamiBenchmarksAudit {
    pub zhao_n5_switch_fisher: f64,
    pub zhao_n5_switch_rmse_ideal: f64,
    pub zhao_n5_switch_rmse_het: f64,
    pub zhao_n5_fixed_heisenberg_bound: f64,
    pub zhao_n15_switch_fisher: f64,
    pub zhao_n15_switch_rmse_ideal: f64,
    pub zhao_n15_fixed_heisenberg_bound: f64,
    pub zhao_n15_advantage_ratio: f64,
    pub goswami_ideal_witness: f64,
    pub goswami_exp_witness: f64,
    pub goswami_sigma: f64,
    pub goswami_z_ideal_bound: f64,
    pub goswami_z_misaligned_bound: f64,
}

pub fn audit_osid_zhao_and_goswami_literature_benchmarks() -> OsidZhaoGoswamiBenchmarksAudit {
    let nu = 10.0_f64;
    let x_bar = 0.25_f64;
    let p_bar = 0.25_f64;
    let z_min = x_bar.abs().min(p_bar.abs());
    let zp_sq = x_bar * x_bar + p_bar * p_bar;

    let n5 = 5.0_f64;
    let e5 = 0.5_f64;
    let f5 = n5.powi(4);
    let rmse5_ideal = 1.0 / (nu.sqrt() * n5 * n5);
    let rmse5_het = rmse5_ideal * (zp_sq / (zp_sq + 1.0 / (n5 * n5))).sqrt();
    let fixed5 = z_min / (n5 * (8.0 * nu * e5).sqrt());

    let n15 = 15.0_f64;
    let e15 = 1.0_f64;
    let f15 = n15.powi(4);
    let rmse15_ideal = 1.0 / (nu.sqrt() * n15 * n15);
    let fixed15 = z_min / (n15 * (8.0 * nu * e15).sqrt());
    let ratio15 = fixed15 / rmse15_ideal;

    let g_ideal = -0.248_f64;
    let g_exp = -0.171_f64;
    let g_sig = 0.009_f64;
    let g_mis = -0.038_f64;
    let z_ideal = (0.0 - g_exp) / g_sig;
    let z_mis = (g_mis - g_exp) / g_sig;

    OsidZhaoGoswamiBenchmarksAudit {
        zhao_n5_switch_fisher: f5,
        zhao_n5_switch_rmse_ideal: rmse5_ideal,
        zhao_n5_switch_rmse_het: rmse5_het,
        zhao_n5_fixed_heisenberg_bound: fixed5,
        zhao_n15_switch_fisher: f15,
        zhao_n15_switch_rmse_ideal: rmse15_ideal,
        zhao_n15_fixed_heisenberg_bound: fixed15,
        zhao_n15_advantage_ratio: ratio15,
        goswami_ideal_witness: g_ideal,
        goswami_exp_witness: g_exp,
        goswami_sigma: g_sig,
        goswami_z_ideal_bound: z_ideal,
        goswami_z_misaligned_bound: z_mis,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn grassmannian_causal_do_calculus_and_quantum_switch_identities_hold() {
        // 1. Confounded diamond (U -> X, U -> Y, X -> Y):
        // Observational transfer from X (node 1) to Y (node 2) vs confounder U (node 0):
        // If we intervene do(X := x) on node 1, incoming edge 0 -> 1 is severed!
        let (t_obs, t_do) = causal_dag_do_surgery_3x3(2.0, 3.0, 4.0, 1);
        // Before do(X): U -> Y total transfer is w02 + w01*w12 = 3 + 2*4 = 11
        assert!((t_obs[0][2] - 11.0).abs() < 1e-12);
        // After do(X): edge U -> X (w01) is severed, so U -> X transfer is 0 and U -> Y is only direct w02 = 3
        assert!(t_do[0][1].abs() < 1e-12);
        assert!((t_do[0][2] - 3.0).abs() < 1e-12);
        // While the direct causal effect X -> Y (t_do[1][2] = 4.0) is preserved!
        assert!((t_do[1][2] - 4.0).abs() < 1e-12);

        assert!((causal_observational_transfer(5.0, 2.0) - 7.0).abs() < 1e-12);
        assert!((causal_interventional_do_transfer(5.0, 2.0) - 5.0).abs() < 1e-12);
        assert!((causal_confounding_bias(5.0, 2.0) - 2.0).abs() < 1e-12);

        // 2. Relativistic / DDF lightcone interval on Gr_C(2,4):
        assert!((causal_lightcone_interval(0.6) - 0.64).abs() < 1e-12);
        assert!(causal_lightcone_interval(1.0).abs() < 1e-12);
        assert!(causal_lightcone_interval(1.2) < 0.0);

        // 3. Pearl / Giarmatzi-Costa counterfactual abduction-action-prediction:
        assert!((abduced_exogenous_state(2.0, 3.0, 10.0) - 4.0).abs() < 1e-12);
        assert!((counterfactual_structural_outcome(2.0, 3.0, 10.0, 3.0) - 10.0).abs() < 1e-12);
        assert!((counterfactual_structural_outcome(2.0, 3.0, 10.0, 5.0) - 14.0).abs() < 1e-12);
        assert!(
            (counterfactual_interventional_difference(2.0, 3.0, 10.0, 5.0) - 4.0).abs() < 1e-12
        );

        // 4. Quantum Switch on 2x2 unitaries:
        // Case A: Commuting gates U_A = I, U_B = Z -> E_+ = 1, E_- = 0, delta_switch = +1
        let id_2x2 = [[(1.0, 0.0), (0.0, 0.0)], [(0.0, 0.0), (1.0, 0.0)]];
        let pauli_z = [[(1.0, 0.0), (0.0, 0.0)], [(0.0, 0.0), (-1.0, 0.0)]];
        let pauli_x = [[(0.0, 0.0), (1.0, 0.0)], [(1.0, 0.0), (0.0, 0.0)]];
        let psi_0 = [(1.0, 0.0), (0.0, 0.0)];
        let (e_sym_comm, e_anti_comm, delta_comm) =
            evaluate_quantum_switch_2x2(&id_2x2, &pauli_z, &psi_0);
        assert!((e_sym_comm - 1.0).abs() < 1e-12);
        assert!(e_anti_comm.abs() < 1e-12);
        assert!((delta_comm - 1.0).abs() < 1e-12);

        // Case B: Anticommuting Pauli gates U_A = X, U_B = Z ({X, Z} = 0) -> E_+ = 0, E_- = 1, delta_switch = -1
        let (e_sym_anti, e_anti_anti, delta_anti) =
            evaluate_quantum_switch_2x2(&pauli_x, &pauli_z, &psi_0);
        assert!(e_sym_anti.abs() < 1e-12);
        assert!((e_anti_anti - 1.0).abs() < 1e-12);
        assert!((delta_anti + 1.0).abs() < 1e-12);

        // Case C: Gr_C(2,4) Plücker ratio recovery for (E_+, E_-) = (3, 1):
        let (w_a_sq, w_b_sq, ratio) = quantum_switch_gr24_plucker_channels(3.0, 1.0);
        assert!((w_a_sq - 1.5).abs() < 1e-12);
        assert!((w_b_sq - 0.5).abs() < 1e-12);
        assert!((ratio - (1.0 / 3.0)).abs() < 1e-12);
        assert_eq!(quantum_choi_grassmannian_real_dim(4, 4, 4), 96);

        // Case D: Oreshkov-Costa-Brukner (2012) causal inequality violation:
        let (p_causal, p_quantum, adv) = ocb_causal_inequality_bounds();
        assert!((p_causal - 0.75).abs() < 1e-12);
        assert!((p_quantum - 0.853_553_390_593_273_7).abs() < 1e-12);
        assert!(adv > 0.103);
        assert!(((4.0 * p_quantum - 2.0).powi(2) - 2.0).abs() < 1e-12);
    }

    #[test]
    fn mpemba_landau_qrt_constructor_theory_and_entropy_siphon_audit_work() {
        // 1. Landau free-energy double well, 3D P-V-T surface / water ice-hump, & Strong Mpemba crossing:
        assert!(landau_free_energy(0.0, -2.0, 2.0, 0.0).abs() < 1e-12);
        assert!((landau_free_energy(1.0, -2.0, 2.0, 0.0) - (-0.5)).abs() < 1e-12);

        // 3D P-V-T van der Waals surface (`P_surface = (0.1 * T) / (V - 0.5) - 1 / V^2`) and water ice-hump:
        let p_hot_vdw = van_der_waals_pressure(0.1, 80.0, 2.0, 0.5, 1.0).unwrap();
        let p_cold_vdw = van_der_waals_pressure(0.1, 30.0, 2.0, 0.5, 1.0).unwrap();
        assert!(((p_hot_vdw - p_cold_vdw) - (0.1 * 50.0 / 1.5)).abs() < 1e-12);
        let v_liq = water_anomalous_freezing_volume(18.0, 1.62, 280.0, 273.15);
        let v_ice = water_anomalous_freezing_volume(18.0, 1.62, 265.0, 273.15);
        assert!((v_liq - 18.0).abs() < 1e-12);
        assert!((v_ice - 19.62).abs() < 1e-12);
        assert!(v_ice > v_liq);

        // Landau phase-transition complexity dichotomy across T_c = 273 K:
        let a_above = landau_order_coeff(1.0, 300.0, 273.0);
        assert!(a_above > 0.0);
        assert!(landau_free_energy(1.0, a_above, 2.0, 0.0) > 0.0);
        let a_below = landau_order_coeff(1.0, 271.0, 273.0);
        assert!((a_below - (-2.0)).abs() < 1e-12);
        let barrier = landau_double_well_barrier_height(1.0, 271.0, 273.0, 2.0).unwrap();
        assert!((barrier - 0.5).abs() < 1e-12);
        assert!(
            ((landau_free_energy(0.0, a_below, 2.0, 0.0)
                - landau_free_energy(1.0, a_below, 2.0, 0.0))
                - barrier)
                .abs()
                < 1e-12
        );
        assert!(
            (signals_landau_double_well_barrier_height(1.0, 271.0, 273.0, 2.0) - 0.5).abs() < 1e-12
        );

        // Strong Mpemba Gr_R(1,2) orthogonal complement projector for v_slow = (3/5, 4/5):
        let (proj, x_proj, slow_overlap) =
            apply_strong_mpemba_gr12_projector(0.6, 0.8, [5.0, 10.0]).unwrap();
        let tr = proj[0][0] + proj[1][1];
        let det = proj[0][0] * proj[1][1] - proj[0][1] * proj[1][0];
        assert!((tr - 1.0).abs() < 1e-12);
        assert!(det.abs() < 1e-12);
        assert!(slow_overlap.abs() < 1e-12);
        // Applying projector a second time is idempotent: P^2 x = P x
        let (_, x_proj_2, slow_overlap_2) =
            apply_strong_mpemba_gr12_projector(0.6, 0.8, x_proj).unwrap();
        assert!((x_proj_2[0] - x_proj[0]).abs() < 1e-12);
        assert!((x_proj_2[1] - x_proj[1]).abs() < 1e-12);
        assert!(slow_overlap_2.abs() < 1e-12);

        // Strong Mpemba: hot state (a2=0, a3=4) starts at D(0)=4 > D_cold(0)=2 (a2=1, a3=1)
        let d_hot_0 = mpemba_two_mode_trajectory(0.0, 4.0, 1.0, 3.0, 0.0);
        let d_cold_0 = mpemba_two_mode_trajectory(1.0, 1.0, 1.0, 3.0, 0.0);
        assert!(d_hot_0 > d_cold_0);
        let d_hot_1 = mpemba_two_mode_trajectory(0.0, 4.0, 1.0, 3.0, 1.0);
        let d_cold_1 = mpemba_two_mode_trajectory(1.0, 1.0, 1.0, 3.0, 1.0);
        assert!(d_hot_1 < d_cold_1);

        // Exact crossing time for (a2_hot=0, a3_hot=4) vs (a2_cold=1, a3_cold=0):
        let t_cross = strong_mpemba_crossing_time(4.0, 1.0, 1.0, 3.0).unwrap();
        let d_hot_cross = mpemba_two_mode_trajectory(0.0, 4.0, 1.0, 3.0, t_cross);
        let d_cold_cross = mpemba_two_mode_trajectory(1.0, 0.0, 1.0, 3.0, t_cross);
        assert!((d_hot_cross - d_cold_cross).abs() < 1e-12);

        // 2. QRT thermo-majorization & KL divergence:
        let gibbs = [0.6, 0.3, 0.1];
        let p_hot_shortcut = [0.2, 0.1, 0.7]; // Strongly non-equilibrium
        let q_closer = [0.5, 0.3, 0.2]; // Closer to Gibbs
        assert!(thermo_majorization_dominates(&p_hot_shortcut, &q_closer, &gibbs, 1e-12).unwrap());
        assert!(!thermo_majorization_dominates(&q_closer, &p_hot_shortcut, &gibbs, 1e-12).unwrap());
        let kl_hot = qrt_kl_divergence_bits(&p_hot_shortcut, &gibbs).unwrap();
        let kl_closer = qrt_kl_divergence_bits(&q_closer, &gibbs).unwrap();
        assert!(kl_closer < kl_hot);
        assert!(qrt_majorization_shortcut_gap(kl_hot, kl_closer) > 0.0);

        // 3. Constructor Theory tasks:
        let task_no_info = ConstructorTask {
            delta_system_entropy_bits: -1.0,
            work_supplied_joules: 0.0,
            side_info_resource_bits: 0.0,
        };
        let task_classical = ConstructorTask {
            delta_system_entropy_bits: -1.0,
            work_supplied_joules: 0.0,
            side_info_resource_bits: 1.0,
        };
        let task_quantum = ConstructorTask {
            delta_system_entropy_bits: -1.0,
            work_supplied_joules: 0.0,
            side_info_resource_bits: 2.0,
        };
        assert!(!task_no_info.is_possible(1.0));
        assert!(task_classical.is_possible(1.0));
        assert!(task_quantum.is_possible(1.0));
        assert!(task_classical.compose(&task_quantum).is_possible(1.0));

        // 4. Conditional Landauer (del Rio et al. 2011), Werner vs Linear conditional entropy, & Lignolux audit:
        assert!((del_rio_conditional_landauer_heat(1.0, 0.0) - 1.0).abs() < 1e-12);
        assert!(del_rio_conditional_landauer_heat(1.0, 0.5).abs() < 1e-12);
        assert!((del_rio_conditional_landauer_heat(1.0, 1.0) + 1.0).abs() < 1e-12);
        assert!((entropy_siphon_counterfactual_gain(1.0, 1.0, 0.0) + 2.0).abs() < 1e-12);
        assert!((closed_loop_erasure_and_memory_reset_heat(1.0, 0.99, 0.1) - 1.1).abs() < 1e-12);

        // Isotropic Werner state: at F = 0.25 (maximally mixed I/4), S(A|O) = 2 - 1 = +1 bit;
        // at F = 0.5 (entanglement threshold), S(A|O)_Werner = (1/2) log2(3) ≈ +0.79248125 bits > 0.5 > 0;
        // at F = 1.0 (pure Bell), S(A|O)_Werner = -1 bit.
        let s_werner_mix = exact_werner_conditional_entropy_bits(0.25).unwrap();
        let s_werner_half = exact_werner_conditional_entropy_bits(0.5).unwrap();
        let s_werner_bell = exact_werner_conditional_entropy_bits(1.0).unwrap();
        assert!((s_werner_mix - 1.0).abs() < 1e-12);
        assert!((s_werner_half - (0.5 * 3.0_f64.log2())).abs() < 1e-12);
        assert!(s_werner_half > 0.5);
        assert!((s_werner_bell + 1.0).abs() < 1e-12);

        // Exact Werner zero-cooling threshold:
        // Bell singlet fidelity F_* ≈ 0.8107103750847682 <-> Werner visibility p_* = (4F_* - 1)/3 ≈ 0.7476138334463576:
        let f_star = werner_cooling_threshold_fidelity();
        let p_star = werner_visibility_from_fidelity(f_star);
        assert!((f_star - 0.810_710_375_084_768_2).abs() < 1e-12);
        assert!((p_star - 0.747_613_833_446_357_6).abs() < 1e-12);
        assert!((werner_fidelity_from_visibility(p_star) - f_star).abs() < 1e-12);
        assert!((werner_fidelity_from_visibility(1.0 / 3.0) - 0.5).abs() < 1e-12);
        assert!(exact_werner_conditional_entropy_bits(f_star).unwrap().abs() < 1e-12);
        // At F = 0.75 (above p_* = 0.7476, but below F_* = 0.8107!), linear model claims cooling (-0.5),
        // yet the isotropic Werner state still heats!
        assert!(del_rio_conditional_landauer_heat(1.0, 0.75) < 0.0);
        assert!(del_rio_werner_conditional_landauer_heat(1.0, 0.75).unwrap() > 0.0);
        assert!(del_rio_werner_conditional_landauer_heat(1.0, 0.85).unwrap() < 0.0);

        // Lignolux tape audit: at T = 4.0 K, F = 0.99, N_anc = 2e8, f_qec = 1e8 Hz,
        // power is -7.499298e-7 W (-0.750 μW), and even at clock_rate = 1e12 Hz (1 THz)
        // it is -7.499298e-3 W (-7.50 mW) — NOT the -50 to -100 W claimed in the chat prose!
        let p_siphon_100mhz = lignolux_tape_siphon_power_watts(4.0, 0.99, 2.0e8, 1.0e8);
        let p_siphon_1thz = lignolux_tape_siphon_power_watts(4.0, 0.99, 2.0e8, 1.0e12);
        assert!((p_siphon_100mhz - (-7.499_297_98e-7)).abs() < 1e-12);
        assert!(p_siphon_100mhz.abs() < 1.0e-6);
        assert!((p_siphon_1thz - (-7.499_297_98e-3)).abs() < 1e-8);
        assert!(p_siphon_1thz.abs() < 1.0e-2);
    }

    #[test]
    fn jev_bundle_transformer_grassmann_flows_and_videogen_identities_hold() {
        // 1. JEV vs. CEV (do-calculus) vs. Quantum Causal Decision Theory (QCDT) & Jevons Rebound:
        let p_do = 0.6;
        let b_conf = 0.2;
        let u1 = 10.0;
        let u2 = 2.0;
        let jev = jev_evidential_expected_utility(p_do + b_conf, (1.0 - p_do) - b_conf, u1, u2);
        let cev = cev_causal_do_expected_utility(p_do, 1.0 - p_do, u1, u2);
        assert!(((jev - cev) - b_conf * (u1 - u2)).abs() < 1e-12);
        assert!(jev > cev);

        // Complex Grassmannian Plücker interference & pi-phase alternation law:
        let q_int = qcdt_plucker_interference_term(0.5, 0.25, 0.4, -0.1);
        let q_int_pi = qcdt_plucker_interference_term(0.5, 0.25, -0.4, 0.1);
        assert!((q_int + q_int_pi).abs() < 1e-12);
        let qcev = qcdt_quantum_causal_expected_utility(p_do, 1.0 - p_do, 0.25, u1, u2);
        assert!(((qcev - cev) - 0.25 * (u1 - u2)).abs() < 1e-12);

        // Jevons compute-energy rebound when demand elasticity excess eps_ex = 0.5 > 0:
        let e_rebound = jevons_total_compute_energy(10.0, 4.0, 100.0, 0.5).unwrap();
        assert!((e_rebound - 1500.0).abs() < 1e-12);
        assert!(e_rebound > 10.0 * 100.0);

        // 2. Zhang (2025, arXiv:2512.19428) & kanenorman/grassmann parameter and Plücker laws:
        assert_eq!(plucker_pair_dimension(32), 496);
        assert_eq!(multi_head_attention_block_params(256), 263_680);
        assert_eq!(kanenorman_grassmann_block_params(256, 32), 267_296);
        assert_eq!(12_607_168 + 6 * (256 * 256), 13_000_384);

        // Gating discrepancy between kanenorman additive residual and Zhang convex gating:
        let alpha = 0.7;
        let h_val = 2.0;
        let g_val = 5.0;
        let diff_gate = kanenorman_additive_gated_residual(alpha, h_val, g_val)
            - zhang_convex_gated_fusion(alpha, h_val, g_val);
        let expected_diff = (1.0 - alpha) * h_val + (2.0 * alpha - 1.0) * g_val;
        assert!((diff_gate - expected_diff).abs() < 1e-12);

        // Multi-lag Plücker bilinear collapse to single wedge product:
        let p1 = plucker_2d_coord(3.0, -2.0, 1.0, 4.0);
        let p2 = plucker_2d_coord(3.0, -2.0, -5.0, 2.0);
        let p_comb = plucker_2d_coord(
            3.0,
            -2.0,
            0.4 * 1.0 + 0.6 * (-5.0),
            0.4 * 4.0 + 0.6 * 2.0,
        );
        assert!(((0.4 * p1 + 0.6 * p2) - p_comb).abs() < 1e-12);
        let p_vec = causal_grassmann_plucker_vector(&[1.0, 0.0, 2.0], &[0.0, 3.0, 4.0], 1e-6)
            .unwrap();
        assert_eq!(p_vec.len(), 3);
        let p_norm_sq: f64 = p_vec.iter().map(|v| v * v).sum();
        assert!((p_norm_sq - 1.0).abs() < 1e-12);

        // 3. De Clercq (2026) Tautological Bundle-Transformer & Su et al. (2021) Fiber-RoPE:
        let tok_i = TautologicalBundleToken2D::from_qr_1d(3.0, 4.0, 5.0).unwrap();
        let tok_j = TautologicalBundleToken2D::from_qr_1d(4.0, -3.0, 2.0).unwrap();
        let v_i = tok_i.instance_vec();
        let v_i_proj = tok_i.project_onto_fiber(v_i[0], v_i[1]);
        assert!((v_i_proj[0] - v_i[0]).abs() < 1e-12);
        assert!((v_i_proj[1] - v_i[1]).abs() < 1e-12);
        // Orthogonal vector (-s * beta, c * beta) is filtered to zero by Π_Z:
        let v_orth_proj = tok_i.project_onto_fiber(-tok_i.z_s * 7.0, tok_i.z_c * 7.0);
        assert!(v_orth_proj[0].abs() < 1e-12);
        assert!(v_orth_proj[1].abs() < 1e-12);
        // Chordal distance between orthogonal subspaces is 1, self-distance is 0:
        assert!(tok_i.chordal_dist_sq(&tok_i).abs() < 1e-12);
        assert!((tok_i.chordal_dist_sq(&tok_j) - 1.0).abs() < 1e-12);
        assert!((bundle_concept_similarity(2.0, 1.0, 1.0, 0.5) - 2.0).abs() < 1e-12);
        assert!(
            (signals_bundle_hybrid_attention_score(0.5, 4.0, 0.5, 2.0) - 3.0).abs() < 1e-12
        );
        // Shared linear transport A = [[2, 1], [0, 3]] preserves v_tilde = A v in Z_new:
        let tok_trans = tok_i.linear_transport_2x2(2.0, 1.0, 0.0, 3.0).unwrap();
        let v_trans = tok_trans.instance_vec();
        let av_x = 2.0 * v_i[0] + 1.0 * v_i[1];
        let av_y = 0.0 * v_i[0] + 3.0 * v_i[1];
        assert!((v_trans[0] - av_x).abs() < 1e-12);
        assert!((v_trans[1] - av_y).abs() < 1e-12);

        // Fiber-RoPE preserves norm:
        let rot = rope_fiber_rotate(0.6, 0.8, 3.0, -4.0);
        assert!(((rot[0] * rot[0] + rot[1] * rot[1]) - (9.0 + 16.0)).abs() < 1e-12);

        // 4D Plücker Klein quadric rank-2 shared-anchor collapse vs. cross-lag rank-4 escape:
        let zc = [2.0, -1.0, 3.0, 4.0];
        let zp = [1.0, 5.0, -2.0, 0.5];
        let q_shared = plucker_quadric_4d_residual(
            plucker_2d_coord(zc[0], zc[1], zp[0], zp[1]),
            plucker_2d_coord(zc[0], zc[2], zp[0], zp[2]),
            plucker_2d_coord(zc[0], zc[3], zp[0], zp[3]),
            plucker_2d_coord(zc[1], zc[2], zp[1], zp[2]),
            plucker_2d_coord(zc[1], zc[3], zp[1], zp[3]),
            plucker_2d_coord(zc[2], zc[3], zp[2], zp[3]),
        );
        assert!(q_shared.abs() < 1e-12);
        let q_cross = plucker_quadric_4d_residual(2.0, 0.0, 0.0, 0.0, 0.0, 3.0);
        assert!((q_cross - 6.0).abs() < 1e-12);

        // Same-frame vs. anisotropic cross-frame RoPE gauge-mismatch residual:
        let u = [3.0, -2.0];
        let w = [4.0, 5.0];
        let u_rot = rope_fiber_rotate(0.6, 0.8, u[0], u[1]);
        let w_rot = rope_fiber_rotate(0.6, 0.8, w[0], w[1]);
        assert!(
            (rope_cross_frame_inner_product(u_rot, w_rot, 1.0)
                - rope_cross_frame_inner_product(u, w, 1.0))
                .abs()
                < 1e-12
        );
        let u_90 = rope_fiber_rotate(0.0, 1.0, u[0], u[1]);
        let w_90 = rope_fiber_rotate(0.0, 1.0, w[0], w[1]);
        let sigma2 = 0.4;
        let aniso_shift = rope_cross_frame_inner_product(u_90, w_90, sigma2)
            - rope_cross_frame_inner_product(u, w, sigma2);
        let expected_shift = (sigma2 - 1.0) * (u[0] * w[0] - u[1] * w[1]);
        assert!((aniso_shift - expected_shift).abs() < 1e-12);

        // 4. Spatiotemporal VideoGen Complexity, QRAM Latency, & rGO/A-CNT 100 ps Kapitza Steering:
        let c_vid_grass =
            signals_spatiotemporal_grassmann_video_complexity(16.0, 16.0, 16.0, 6.0, 496.0);
        let c_vid_attn = spatiotemporal_full_attention_complexity(16.0, 16.0, 16.0, 64.0);
        assert!(c_vid_grass < c_vid_attn);
        assert!(qft_associative_total_latency(100.0, 10.0) > 100.0);
        let k_diff = oam_log_polar_transverse_momentum(3.0, 2.0).unwrap()
            - oam_log_polar_transverse_momentum(1.0, 2.0).unwrap();
        assert!((k_diff - 1.0).abs() < 1e-12);
        assert!((rgo_vitrimer_kapitza_cool_time(5.0e-9, 2.0e6, 1.0e-8) - 1.0e-10).abs() < 1e-20);
    }

    #[test]
    fn splat_volumetric_6400x_efficiency_jeffrey_kinematics_and_quantum_graphrag_hold() {
        // 1. Beyond 6,400x Splat-Sparse Grassmannian Volumetric Efficiency:
        // Dense 16x16x16 volume (N=4096, d_head=64, m_lags=2, d_plucker=10):
        let eta_dense_16 =
            signals_volumetric_attention_efficiency_ratio(16.0, 16.0, 16.0, 64.0, 4096.0, 2.0, 10.0);
        assert!((eta_dense_16 - 13_107.2).abs() < 1e-9);
        assert!(eta_dense_16 > 6400.0);

        // Dense 32x32x32 surgical navigation volume (N=32768) or 16^3 with 8x splat sparsity (N_splats=512):
        let eta_dense_32 = volumetric_attention_efficiency_ratio(
            32.0, 32.0, 32.0, 64.0, 32_768.0, 2.0, 10.0,
        )
        .unwrap();
        let eta_sparse_16 =
            volumetric_attention_efficiency_ratio(16.0, 16.0, 16.0, 64.0, 512.0, 2.0, 10.0)
                .unwrap();
        assert!((eta_dense_32 - 104_857.6).abs() < 1e-8);
        assert!((eta_sparse_16 - 104_857.6).abs() < 1e-8);
        assert!(eta_dense_32 > 6400.0);

        // 32x32x40 endoscopic/OCT surgical slab (N=40960) with 10x splat sparsity (N_splats=4096):
        let eta_surgical =
            volumetric_attention_efficiency_ratio(32.0, 32.0, 40.0, 64.0, 4096.0, 2.0, 10.0)
                .unwrap();
        assert!((eta_surgical - 1_310_720.0).abs() < 1e-6);
        assert!(eta_surgical > 6400.0);

        // 2. Jeffrey's Kinematic Engine (`Probability Kinematics`, Jeffrey 1965) & Pearl do-deconfounding:
        let p1 = 0.3;
        let p2 = 0.7;
        let q1 = 0.8;
        let q2 = 0.2;
        let c1_do = 0.9;
        let c2_do = 0.1;
        let b1 = 0.05;
        let b2 = 0.25;
        // Exact conservation under zero sensor shift:
        assert!(jeffrey_kinematic_shift(p1, p2, p1, p2, c1_do, c2_do).abs() < 1e-12);
        // Binary partition reduction (p2 = 1 - p1, q2 = 1 - q1):
        let shift = jeffrey_kinematic_shift(p1, p2, q1, q2, c1_do, c2_do);
        assert!((shift - (q1 - p1) * (c1_do - c2_do)).abs() < 1e-12);
        // Confounding bias decomposition between observational and Pearl do-surgical Jeffrey kinematics:
        let q_obs = signals_jeffrey_kinematic_update(q1, q2, c1_do + b1, c2_do + b2);
        let q_do = signals_jeffrey_kinematic_update(q1, q2, c1_do, c2_do);
        let q_bias = signals_jeffrey_kinematic_update(q1, q2, b1, b2);
        assert!(((q_obs - q_do) - q_bias).abs() < 1e-12);

        // Quantum Lüders-Plücker interference cancellation under pi-phase shift:
        let q_qje_pos = signals_quantum_jeffrey_plucker_kinematic_update(
            q1, q2, c1_do, c2_do, 0.5, 0.6, 0.2, 0.4, -0.3,
        );
        let q_qje_neg = signals_quantum_jeffrey_plucker_kinematic_update(
            q1, q2, c1_do, c2_do, 0.5, 0.6, 0.2, -0.4, 0.3,
        );
        assert!(((0.5 * (q_qje_pos + q_qje_neg)) - q_do).abs() < 1e-12);

        // 3. 3D Volumetric Normed Tensor Gaussian Splat for Nanoimaging & Surgical Navigation:
        let splat = SurgicalVolumetricSplat3D::new([1.0, 2.0, 3.0], 1.2, [2.0, 1.5, 0.8]).unwrap();
        let splat_updated = splat
            .jeffrey_kinematic_weight_update(q1, q2, c1_do, c2_do)
            .unwrap();
        // Jeffrey rigidity: 3D covariance determinant & 2D orthographic trace are preserved!
        assert!((splat_updated.cov_det() - splat.cov_det()).abs() < 1e-12);
        assert!((splat_updated.ortho_2d_cov_trace() - splat.ortho_2d_cov_trace()).abs() < 1e-12);
        assert!((splat_updated.weight - q_do).abs() < 1e-12);

        // Adaptive two-child splitting along major axis reduces det(Sigma_3D) by 1/4 and conserves weight:
        let (child_plus, child_minus) = splat_updated.split_major_children();
        assert!(((child_plus.weight + child_minus.weight) - splat_updated.weight).abs() < 1e-12);
        assert!((child_plus.cov_det() - 0.25 * splat_updated.cov_det()).abs() < 1e-12);
        assert!((child_minus.cov_det() - 0.25 * splat_updated.cov_det()).abs() < 1e-12);

        // Holographic Gr_C(2,4) Plücker channel ratio recovers exact 3rd principal depth variance sigma_3^2:
        let r_depth = splat_updated.ortho_2d_cov_trace() / (splat_updated.sigma[2].powi(2));
        let recovered_sigma3_sq = splat_updated.recover_depth_variance_sq(r_depth).unwrap();
        assert!((recovered_sigma3_sq - splat_updated.sigma[2].powi(2)).abs() < 1e-12);

        // 4. Quantum Causal Semantic GraphRAG Subspace-Deconfounded Retrieval:
        let s_taut = 1.75;
        let score_obs = signals_quantum_causal_graphrag_score(
            s_taut,
            q1,
            q2,
            c1_do + b1,
            c2_do + b2,
            0.5,
            0.6,
            0.2,
            0.4,
            -0.3,
        );
        let score_do_pos = signals_quantum_causal_graphrag_score(
            s_taut, q1, q2, c1_do, c2_do, 0.5, 0.6, 0.2, 0.4, -0.3,
        );
        let score_do_neg = signals_quantum_causal_graphrag_score(
            s_taut, q1, q2, c1_do, c2_do, 0.5, 0.6, 0.2, -0.4, 0.3,
        );
        assert!(((score_obs - score_do_pos) - q_bias).abs() < 1e-12);
        assert!(((0.5 * (score_do_pos + score_do_neg)) - (s_taut + q_do)).abs() < 1e-12);

        // 5. Adversarial Critique & Gap Closure (Master Theorem 8):
        // (a) End-to-end speedup with 199x projection + radix-sort overhead (16,302,080 FLOPs) = 6,553.6x > 6,400x:
        let eta_overhead = signals_effective_volumetric_speedup_with_overhead(
            32.0,
            32.0,
            40.0,
            64.0,
            4096.0,
            2.0,
            10.0,
            16_302_080.0,
        );
        assert!((eta_overhead - 6553.6).abs() < 1e-9);
        assert!(eta_overhead > 6400.0);

        // (b) Partition-weighted Lüders-Jeffrey boundary rigidity at (1,0) and (0,1):
        let pw_10 = signals_partition_weighted_quantum_jeffrey_update(
            1.0, 0.0, c1_do, c2_do, 0.5, 0.6, 0.2, 0.4, -0.3,
        );
        let pw_01 = signals_partition_weighted_quantum_jeffrey_update(
            0.0, 1.0, c1_do, c2_do, 0.5, 0.6, 0.2, 0.4, -0.3,
        );
        assert!((pw_10 - c1_do).abs() < 1e-12);
        assert!((pw_01 - c2_do).abs() < 1e-12);

        // (c) Diaconis-Zabell (1982) sequential non-commutativity vs. log-odds commutativity:
        let lam = 0.4;
        let seq_diff =
            sequential_jeffrey_pool(0.5, q1, q2, lam, lam) - sequential_jeffrey_pool(0.5, q2, q1, lam, lam);
        assert!((seq_diff - lam * lam * (q2 - q1)).abs() < 1e-12);
        assert!(
            (diaconis_zabell_log_odds_update(0.2, 1.1, -0.4)
                - diaconis_zabell_log_odds_update(0.2, -0.4, 1.1))
                .abs()
                < 1e-12
        );

        // (d) Huygens-Steiner 0th, 1st, and 2nd central moment conservation of split_major_children:
        let mean_center_x = 0.5 * (child_plus.center[0] + child_minus.center[0]);
        assert!((mean_center_x - splat_updated.center[0]).abs() < 1e-12);
        let mom2_plus =
            child_plus.sigma[0].powi(2) + (child_plus.center[0] - splat_updated.center[0]).powi(2);
        let mom2_minus = child_minus.sigma[0].powi(2)
            + (child_minus.center[0] - splat_updated.center[0]).powi(2);
        let mixture_var = 0.5 * (mom2_plus + mom2_minus);
        assert!((mixture_var - splat_updated.sigma[0].powi(2)).abs() < 1e-12);

        // 6. Optional Complex VRC vs. Plabic Parameterization (Master Theorem 9):
        use crate::dft_plabic_vrc::C64;
        assert_eq!(
            qci_recommend_backend(false, false),
            GrassmannianCausalBackend::PlabicRationalChart
        );
        assert_eq!(
            qci_recommend_backend(true, false),
            GrassmannianCausalBackend::ComplexHomogeneousVrc
        );
        assert_eq!(
            qci_recommend_backend(false, true),
            GrassmannianCausalBackend::ComplexHomogeneousVrc
        );

        let x1_c = C64::new(0.4, 0.3);
        let x2_c = C64::new(0.7, -0.2);
        let xx_c = C64::new(1.2, 0.5);
        let p_plabic = qci_gr24_plucker_minors(
            GrassmannianCausalBackend::PlabicRationalChart,
            false,
            x1_c,
            x2_c,
            xx_c,
            false,
        );
        let p_vrc = qci_gr24_plucker_minors(
            GrassmannianCausalBackend::ComplexHomogeneousVrc,
            false,
            x1_c,
            x2_c,
            xx_c,
            false,
        );
        // Plücker quadratic identity holds for both backends:
        assert!(p_plabic.quadratic_relation().abs() < 1e-12);
        assert!(p_vrc.quadratic_relation().abs() < 1e-12);
        // Minors involving column 2 (p13, p23, p34) scale by x_X; others (p12, p14, p24) are equal:
        assert!((p_vrc.p12 - p_plabic.p12).abs() < 1e-12);
        assert!((p_vrc.p14 - p_plabic.p14).abs() < 1e-12);
        assert!((p_vrc.p24 - p_plabic.p24).abs() < 1e-12);
        assert!((p_vrc.p13 - xx_c * p_plabic.p13).abs() < 1e-12);
        assert!((p_vrc.p23 - xx_c * p_plabic.p23).abs() < 1e-12);
        assert!((p_vrc.p34 - xx_c * p_plabic.p34).abs() < 1e-12);

        // Both uncrossed channels w_A and w_B scale by x_X:
        let (wa_plab, wb_plab) = qci_gr24_uncrossed_channels(
            GrassmannianCausalBackend::PlabicRationalChart,
            false,
            x1_c,
            x2_c,
            xx_c,
            false,
        );
        let (wa_vrc, wb_vrc) = qci_gr24_uncrossed_channels(
            GrassmannianCausalBackend::ComplexHomogeneousVrc,
            false,
            x1_c,
            x2_c,
            xx_c,
            false,
        );
        assert!((wa_vrc - xx_c * wa_plab).abs() < 1e-12);
        assert!((wb_vrc - xx_c * wb_plab).abs() < 1e-12);

        // At the on-shell polariton resonance x_X = -1, mutated ComplexHomogeneousVrc is completely pole-free:
        let xx_res = C64::new(-1.0, 0.0);
        let p_vrc_res = qci_gr24_plucker_minors(
            GrassmannianCausalBackend::ComplexHomogeneousVrc,
            true,
            x1_c,
            x2_c,
            xx_res,
            false,
        );
        assert!(p_vrc_res.quadratic_relation().abs() < 1e-12);
        assert!((p_vrc_res.p12 - C64::ONE).abs() < 1e-12);
        assert!((p_vrc_res.p13 - C64::ZERO).abs() < 1e-12);
        assert!((p_vrc_res.p14 - x2_c).abs() < 1e-12);
        assert!((p_vrc_res.p23 - (x2_c - x1_c)).abs() < 1e-12);
        assert!((p_vrc_res.p24 - C64::ONE).abs() < 1e-12);
        assert!((p_vrc_res.p34 - (x1_c * x2_c - x2_c * x2_c)).abs() < 1e-12);

        // Pearl do-surgical severing (do_sever_backdoor = true) sets w_B = 0 and collapses to classical Jeffrey:
        let q_vrc_do = signals_qci_optional_vrc_jeffrey_kinematic_update(
            1, 1, q1, q2, c1_do, c2_do, 0.5, x1_c.re, x1_c.im, x2_c.re, x2_c.im, -1.0, 0.0, 1,
        );
        let score_vrc_do = signals_qci_optional_vrc_graphrag_score(
            1, 1, s_taut, q1, q2, c1_do, c2_do, 0.5, x1_c.re, x1_c.im, x2_c.re, x2_c.im, -1.0, 0.0,
            1,
        );
        assert!((q_vrc_do - q_do).abs() < 1e-12);
        assert!((score_vrc_do - (s_taut + q_do)).abs() < 1e-12);
    }

    #[test]
    fn qci_ncm_multiscale_counterfactual_corruption_vrc_and_pressed_llm_identities_hold() {
        // 1. Multiscale residual VQ-VAE telescoping & Giarmatzi-Costa / Pearl concept counterfactuals:
        let z = 12.5;
        let z_prev = 7.0;
        let delta_k = 3.25;
        let z_hat_k = ncm_cumulative_reconstruction_step(z_prev, delta_k);
        let z_res_k = ncm_residual_at_level(z, z_hat_k);
        assert!(((z_hat_k + z_res_k) - z).abs() < 1e-12);
        assert!((z_res_k - (ncm_residual_at_level(z, z_prev) - delta_k)).abs() < 1e-12);

        let z_obs = 10.0;
        let z_coarse_obs = 6.0;
        let z_coarse_int = 8.5;
        assert!(
            (signals_ncm_counterfactual_concept_reconstruction(z_obs, z_coarse_obs, z_coarse_obs)
                - z_obs)
                .abs()
                < 1e-12
        );
        let z_cf =
            signals_ncm_counterfactual_concept_reconstruction(z_obs, z_coarse_obs, z_coarse_int);
        assert!(((z_cf - z_obs) - (z_coarse_int - z_coarse_obs)).abs() < 1e-12);
        assert!((ncm_story_concept_composition(0.0, 4.0, 9.0) - 4.0).abs() < 1e-12);
        assert!((ncm_story_concept_composition(1.0, 4.0, 9.0) - 9.0).abs() < 1e-12);
        assert!((ncm_story_concept_composition(0.35, 4.0, 4.0) - 4.0).abs() < 1e-12);

        // 2. Deterministic Point-Mass Variational ELBO & KL Posterior Gap (arXiv:2610.14162 Appendix A):
        let elbo = ncm_point_mass_elbo(-6.0, -5.0);
        assert!((elbo - (-11.0)).abs() < 1e-12);
        let kl_gap = ncm_elbo_posterior_kl_gap(-10.0, -6.0, -5.0);
        assert!((kl_gap - 1.0).abs() < 1e-12);
        assert!(kl_gap >= 0.0);
        assert!(ncm_elbo_posterior_kl_gap(-11.0, -6.0, -5.0).abs() < 1e-12);

        // 3. Conditioning Corruption as Pearl Incoming-Edge do-Deconfounding:
        let p_do_1 = 0.6;
        let u1 = 10.0;
        let u2 = 2.0;
        let b_conf = 0.2;
        let jev_uncorrupted =
            signals_ncm_corrupted_expected_concept_utility(p_do_1, u1, u2, 0.0, b_conf);
        let cev_full_do =
            signals_ncm_corrupted_expected_concept_utility(p_do_1, u1, u2, 1.0, b_conf);
        let half_corrupted =
            signals_ncm_corrupted_expected_concept_utility(p_do_1, u1, u2, 0.5, b_conf);
        assert!(
            (jev_uncorrupted
                - jev_evidential_expected_utility(
                    p_do_1 + b_conf,
                    1.0 - p_do_1 - b_conf,
                    u1,
                    u2,
                ))
                .abs()
                < 1e-12
        );
        assert!(
            (cev_full_do - cev_causal_do_expected_utility(p_do_1, 1.0 - p_do_1, u1, u2)).abs()
                < 1e-12
        );
        assert!(ncm_corruption_deconfounded_bias(0.5, b_conf) < b_conf);
        assert!(half_corrupted < jev_uncorrupted && half_corrupted > cev_full_do);

        // 4. QCI-NCM Coherent Pairwise Concept Probability & Destructive Constraint Exclusion (x_X = -1):
        let wa_re = 0.6;
        let wa_im = -0.3;
        let wb_re = 0.4;
        let wb_im = 0.5;
        // Destructive resonance w_B = -w_A cancels constraint-violating parallel pairs to 0:
        assert!(
            signals_qci_ncm_coherent_pairwise_code_prob(wa_re, wa_im, -wa_re, -wa_im).abs()
                < 1e-12
        );
        let p_pos = signals_qci_ncm_coherent_pairwise_code_prob(wa_re, wa_im, wb_re, wb_im);
        let p_neg = signals_qci_ncm_coherent_pairwise_code_prob(wa_re, wa_im, -wb_re, -wb_im);
        let expected_sum = 2.0 * ((wa_re * wa_re + wa_im * wa_im) + (wb_re * wb_re + wb_im * wb_im));
        assert!(((p_pos + p_neg) - expected_sum).abs() < 1e-12);

        // 5. NFE, Training-Token, and Multi-Scale Grassmannian FLOP Speedup Ledgers (arXiv:2610.14162):
        assert!((ncm_nfe_speedup_ratio(128.0, 12.0).unwrap() - (32.0 / 3.0)).abs() < 1e-12);
        assert!((ncm_nfe_speedup_ratio(128.0, 8.0).unwrap() - 16.0).abs() < 1e-12);
        assert!((ncm_nfe_speedup_ratio(1024.0, 32.0).unwrap() - 32.0).abs() < 1e-12);
        assert!((ncm_nfe_speedup_ratio(64.0, 11.0).unwrap() - (64.0 / 11.0)).abs() < 1e-12);
        assert!((66.0 / 13.36) > 4.9);

        let ladder = [16.0, 32.0, 64.0, 128.0];
        let c_dlm = dlm_full_sequence_attention_complexity(128.0, 128.0, 64.0);
        let c_ncm_attn = ncm_block_diagonal_attention_complexity(&ladder, 64.0);
        let c_qci_g_ncm = qci_grassmann_ncm_complexity(&ladder, 2.0, 10.0);
        assert!((c_dlm - 134_217_728.0).abs() < 1e-6);
        assert!((c_ncm_attn - 1_392_640.0).abs() < 1e-6);
        assert!((c_qci_g_ncm - 4800.0).abs() < 1e-9);
        assert!(((c_dlm / c_ncm_attn) - (8192.0 / 85.0)).abs() < 1e-9);
        assert!((c_dlm / c_ncm_attn) > 96.0);
        assert!(((c_ncm_attn / c_qci_g_ncm) - (4352.0 / 15.0)).abs() < 1e-9);
        assert!((c_ncm_attn / c_qci_g_ncm) > 290.0);
        assert!(((c_dlm / c_qci_g_ncm) - (2_097_152.0 / 75.0)).abs() < 1e-9);
        assert!((c_dlm / c_qci_g_ncm) > 27_962.0);

        // 6. Pressed-LLM LHAT + Scale-Selective Coarse/Fine Active N-LIG/B-LIG Steering & OAM Parallel MBR:
        let z_c = 5.0;
        let z_f = 2.0;
        let alpha_c = 0.8;
        let v_c = 1.5;
        let alpha_f = -0.4;
        let v_f = 2.5;
        let z_steered =
            signals_ncm_pressed_two_scale_steered_latent(z_c, z_f, alpha_c, v_c, alpha_f, v_f);
        assert!(
            ((z_steered - (z_c + z_f)) - (alpha_c * v_c + alpha_f * v_f)).abs() < 1e-12
        );
        let (seq_xsum, oam_xsum) = ncm_sequential_vs_oam_parallel_mbr_steps(16, 8);
        assert_eq!(seq_xsum, 128);
        assert_eq!(oam_xsum, 8);
        assert!(oam_xsum < seq_xsum);

        // 7. Deep Gap Closure (Flag Manifold Dimension, Level Weights, CFG, Nested-Dropout Bragg Gating):
        assert_eq!(ncm_flag_manifold_two_step_real_dim(16, 32, 128), Some(3328));
        let w16 = ncm_level_loss_weight_unnorm(16.0).unwrap();
        let w32 = ncm_level_loss_weight_unnorm(32.0).unwrap();
        assert!(w32 < w16);
        assert!((16.0 * w16 - 1.0).abs() < 1e-12);
        let l_cond = 3.5;
        let l_uncond = 1.5;
        let gamma_cfg = 0.8;
        assert!((ncm_classifier_free_guided_logit(l_cond, l_uncond, 0.0) - l_cond).abs() < 1e-12);
        let cfg_shift = ncm_classifier_free_guided_logit(l_cond, l_uncond, gamma_cfg) - l_uncond;
        assert!((cfg_shift - (1.0 + gamma_cfg) * (l_cond - l_uncond)).abs() < 1e-12);
        let (seq_cfg_wmt, oam_cfg_wmt) = ncm_sequential_vs_oam_parallel_mbr_steps(2, 11);
        assert_eq!(seq_cfg_wmt, 22);
        assert_eq!(oam_cfg_wmt, 11);
        assert!(oam_cfg_wmt < seq_cfg_wmt);
        assert_eq!(ncm_nested_dropout_active_bragg_layers(5, 12), 5);
        assert!(ncm_nested_dropout_active_bragg_layers(20, 12) <= 12);
    }

    #[test]
    fn qci_osid_one_shot_system_identification_audits_hold() {
        // 1. Cauchy-Binet Plücker Gram identity on Gr_R(2, 3):
        let (gram_det, plucker_sq) =
            osid_cauchy_binet_2x3_gram_and_plucker([1.2, -0.5, 2.3], [0.4, 1.7, -0.9]);
        assert!(gram_det > 0.0);
        assert!((gram_det - plucker_sq).abs() < 1e-12);
        let (deg_det, deg_plucker) =
            osid_cauchy_binet_2x3_gram_and_plucker([1.2, -0.5, 2.3], [2.4, -1.0, 4.6]);
        assert!(deg_det.abs() < 1e-12);
        assert!(deg_plucker.abs() < 1e-12);

        // 2. Benchmark 1: 1D Allen-Cahn PDE 1-shot recovery vs harmonic degeneracy:
        let ac = audit_osid_allen_cahn_pde();
        assert_eq!(ac.generic_rank, 3);
        assert!(ac.generic_max_coeff_err < 1e-12);
        assert!(ac.generic_sigma_min > 1e-5);
        assert!(ac.generic_gram_det > 0.0);
        assert_eq!(ac.degenerate_rank, 1);
        assert!(ac.degenerate_sigma_min < 1e-12);
        assert!(ac.degenerate_gram_det.abs() < 1e-24);
        assert!(ac.cross_lag_q4_residual < 0.0);
        assert!(ac.cross_lag_q4_residual.abs() > 0.5);

        // 3. Benchmark 2: Chaotic Lorenz ODE 1-shot recovery + Pearl do-surgery:
        let lor = audit_osid_lorenz_ode();
        assert_eq!(lor.rank, 6, "{lor:?}");
        assert!(lor.max_param_err < 1e-6, "{lor:?}");
        assert!(lor.sigma_min > 1e-6);
        assert!((lor.obs_confounded_slope - 10.45).abs() < 1e-12);
        assert!((lor.do_deconfounded_slope - 10.0).abs() < 1e-12);
        assert!((lor.abduced_exogenous_u - 1.5).abs() < 1e-12);

        // 4. Benchmark 3: Circulant (1-shot) vs Hankel (1-probe deficit -> 2-probe) & Quantum Switch:
        let mat = audit_osid_matrix_circulant_hankel_and_switch();
        assert_eq!(mat.circulant_rank_1shot, 4);
        assert!(mat.circulant_max_err < 1e-12);
        assert!(mat.circulant_gram_det > 1.0);
        assert_eq!(mat.circulant_n40_rank, 40);
        assert!(mat.circulant_n40_max_err < 1e-12);
        assert_eq!(mat.hankel_1shot_rows, 3);
        assert_eq!(mat.hankel_1shot_cols, 5);
        assert_eq!(mat.hankel_1shot_rank, 3);
        assert_eq!(mat.hankel_2shot_rank, 5);
        assert!(mat.hankel_2shot_max_err < 1e-12);
        assert_eq!(mat.hankel_n40_1shot_rank, 40);
        assert_eq!(mat.hankel_n40_2shot_rank, 79);
        assert!(mat.hankel_n40_2shot_max_err < 1e-11);
        assert!(mat.hankel_2x2_two_probe_det.abs() > 0.5);
        assert!((mat.switch_e_sym + mat.switch_e_anti - 1.0).abs() < 1e-12);
        assert!((mat.switch_e_sym - 0.75).abs() < 1e-12);
        assert!((mat.switch_e_anti - 0.25).abs() < 1e-12);
        assert!((mat.switch_plucker_ratio - (1.0 / 3.0)).abs() < 1e-12);
        assert!(mat.vrc_destructive_minor.abs() < 1e-12);

        // 5. Benchmark 4: Jeffrey's Kinematic Engine + QFIM = 4 g_FS QCRB + Landauer:
        let qjl = audit_osid_noisy_jeffrey_qfim_landauer();
        assert!((qjl.jeffrey_do_estimate - 8.24).abs() < 1e-12);
        assert!((qjl.quantum_jeffrey_phase_avg - qjl.jeffrey_do_estimate).abs() < 1e-12);
        assert!((qjl.qfim - 5.0).abs() < 1e-12);
        assert!((qjl.qcrb_1shot_var_bound - 0.2).abs() < 1e-12);
        assert!((qjl.qcrb_4shot_var_bound - 0.05).abs() < 1e-12);
        assert!((qjl.landauer_1shot_closed_heat - 1.25).abs() < 1e-12);
        assert!((qjl.landauer_10shot_closed_heat - 12.5).abs() < 1e-12);
    }

    #[test]
    fn qci_osid_literature_check_figures_hold() {
        // 1. Forced Duffing (NBoulle/wias/examples/02_duffing.ipynb, Fig. 1D)
        let duf = audit_osid_duffing_oscillator();
        assert_eq!(duf.rank, 11);
        assert!((duf.recovered_alpha - 1.0).abs() < 1e-6);
        assert!((duf.recovered_delta - 0.02).abs() < 1e-6);
        assert!((duf.recovered_beta - 5.0).abs() < 1e-6);
        assert!((duf.recovered_gamma - 8.0).abs() < 1e-6);
        assert!(duf.max_coeff_err < 1e-6);

        // 2. 2D Quintic Allen-Cahn, Elliptic Prop. 36 degeneracy, & Navier-Stokes continuity + 16-term momentum
        let pdes = audit_osid_2d_pdes_allen_cahn_elliptic_ns();
        assert_eq!(pdes.allen_cahn_2d_rank, 9);
        assert!(pdes.allen_cahn_2d_max_coeff_err < 1e-10);
        assert_eq!(pdes.elliptic_coprime_rank, 1);
        assert!(pdes.elliptic_coprime_gram_det >= 0.0 && pdes.elliptic_coprime_gram_det < 1e-18);
        assert!(pdes.elliptic_coprime_ray_residual < 1e-12);
        assert_eq!(pdes.elliptic_multimode_rank, 2);
        assert!(pdes.elliptic_multimode_max_err < 1e-11);
        assert_eq!(pdes.ns_continuity_rank, 3);
        assert!(pdes.ns_continuity_sigma4 < 1e-12);
        assert!(pdes.ns_continuity_max_coeff_err < 1e-12);
        assert_eq!(pdes.ns_momentum_rank, 16);
        assert!((pdes.ns_momentum_recovered_nu - 1e-3).abs() < 1e-12);
        assert!(pdes.ns_momentum_max_coeff_err < 1e-10);

        // 3. Qi & Ranard (2019) single-eigenstate 4-qubit Hamiltonian & Bairey et al. (2019) independent K*c=0
        let qr = audit_osid_qi_ranard_hamiltonian();
        assert_eq!(qr.num_qubits, 4);
        assert_eq!(qr.local_basis_dim, 8);
        assert_eq!(qr.hilbert_dim, 16);
        assert!(qr.correlation_lambda1.abs() < 1e-12);
        assert!(qr.correlation_lambda2 > 1e-3);
        assert!(qr.projective_angle_err_rad < 1e-10);
        assert!(qr.max_scaled_coeff_err < 1e-10);
        assert!(qr.qi_ranard_dk_lhs > 0.0);
        assert!(qr.qi_ranard_dk_lhs <= qr.qi_ranard_dk_rhs);
        assert!(qr.bairey_commutator_residual < 1e-12);
        assert!(qr.bairey_ktk_lambda1.abs() < 1e-12);
        assert!(qr.bairey_ktk_lambda2 > 1e-4);
        assert!(qr.bairey_recovered_max_err < 1e-11);

        // 4. Zhao et al. (2020) super-Heisenberg Switch metrology & Goswami et al. (2018) witness
        let zg = audit_osid_zhao_and_goswami_literature_benchmarks();
        assert!((zg.zhao_n5_switch_fisher - 625.0).abs() < 1e-12);
        assert!(zg.zhao_n5_switch_rmse_het < zg.zhao_n5_switch_rmse_ideal);
        // At x_bar = p_bar = 0.25, E = 0.5, the 1/N^2 crossover occurs at N > sqrt(8E)/0.25 = 8;
        // at N = 15 (E = 1.0, threshold 11.31), the Quantum Switch strictly beats fixed causal order.
        assert!(zg.zhao_n5_fixed_heisenberg_bound < zg.zhao_n5_switch_rmse_ideal);
        assert!((zg.zhao_n15_switch_fisher - 50_625.0).abs() < 1e-12);
        assert!(zg.zhao_n15_switch_rmse_ideal < zg.zhao_n15_fixed_heisenberg_bound);
        assert!(zg.zhao_n15_advantage_ratio > 1.3);
        assert!(zg.goswami_z_ideal_bound >= 18.0);
        assert!(zg.goswami_z_misaligned_bound > 14.0);
    }
}
