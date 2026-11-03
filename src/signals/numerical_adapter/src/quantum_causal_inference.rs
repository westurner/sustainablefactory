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
// 7. WASM32 / C-ABI Exports
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
}
