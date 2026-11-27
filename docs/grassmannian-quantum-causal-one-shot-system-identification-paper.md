---
title: "Quantum-Causal Grassmannian One-Shot System Identification (QCI-OSID): Reimplementing the Zero-One Law of Boullé, Halikias, Otto, & Townsend (2026) with Plabic/LGV Minors, Pearl do-Surgery, Gr_C(2,4) Quantum Switches, Jeffrey Kinematics, and QFIM = 4 g_FS in Lean 4 and Rust/PyO3"
description: "An arXiv-ready MyST Markdown formal verification and applied quantum physics paper reimplementing and generalizing Boullé, Halikias, Otto, & Townsend (2026, PNAS 123(47):e2624491123) one-shot system identification using Grassmannian Quantum Causal Inference, Cauchy–Binet Plücker injectivity on Gr_R(N, r_0), Hankel-vs-Circulant probe dichotomies, Pearl do-deconfounding, coherent Gr_C(2,4) Quantum Switch and pole-free VRC single-shot operator probing, tautological fiber bundle separation, Jeffrey's Kinematic Engine, QFIM = 4 g_FS Quantum Cramér–Rao conditioning, and closed-loop conditional Landauer thermodynamics in Lean 4, Rust/PyO3, SymPy, and 45-digit mpmath."
---

(grassmannian-quantum-causal-one-shot-system-identification-paper)=
# Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`): Reimplementing the Zero-One Law of Boullé, Halikias, Otto, & Townsend (2026) in Lean 4 and Rust/PyO3

- **Authors:** Wes Turner
- **Subjects:**
  - Quantum Physics (`quant-ph`); Numerical Analysis (`math.NA`); Machine Learning (`cs.LG`); Dynamical Systems (`math.DS`); Algebraic Geometry (`math.AG`); Logic in Computer Science (`cs.LO`)
- **Primary External Attribution:**
  - Nicolas Boullé, Diana Halikias, Samuel E. Otto, & Alex Townsend (2026), *"A zero-one law for one-shot system identification"*, *Proceedings of the National Academy of Sciences* (`PNAS`) **123**(47), e2624491123 {cite:p}`boulle2026zeroone`, and companion manuscript *"One-shot identification of analytic systems"* {cite:p}`boulle2026oneshot_full`.
- **Written Implementation Plan:**
  - [Written Plan: Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`)](quantum-causal-one-shot-system-identification-plan.md) (`OSID-1`–`OSID-6`)
- **Companion Causal & Operator-Learning Papers:**
  - [Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws](grassmannian-quantum-causal-inference-mpemba-paper.md)
  - [Quantum Causal Grassmannian Transformers, JEV vs. $\operatorname{do}$-Calculus Decision Models, Tautological Fiber Bundles, and Spatiotemporal Video Generation](grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md)
  - [Beyond $6{,}400\times$ Volumetric Efficiency: Jeffrey's Kinematic Engine, Normed Tensor Gaussian Splat Nanoimaging & Surgical Navigation, and Quantum Causal Semantic GraphRAG](grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md)
  - [Quantum Causal Next-Concept Modeling (`QCI-NCM`): Coarse-to-Fine Parallel LLM Inference, Multiscale Residual Counterfactuals, Plücker/`VRC` Constraint Coupling, and Pressed-`LHAT` Scale-Selective Steering Hardware](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md)
- **Formal Verification & Computational Artifacts:**
  - `Signals` Lean 4 Library (`3,837` Lake jobs via `make signals_build`, zero `sorry`):
    - {download}`src/signals/Signals/QuantumCausalInference.lean <../src/signals/Signals/QuantumCausalInference.lean>` (Section 16: `qci_osid_cauchy_binet_hankel_do_qfim_and_landauer_identities`; Section 16.1: `qci_osid_literature_benchmarks_duffing_elliptic_qi_ranard_and_switch_identities`)
    - {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` (`OneShotQuantumSysIdPendingBoundary`, `BanachZeroOneAnalyticCertificate`, `NoisyDoProbeCalibrationCertificate`, `QuantumSwitchInterferometricProbeCertificate`, `.ofCertificates`, `.solved_of_certificates`, and `osid_finite_certs_do_not_close_banach_or_lab_gates`)
    - {download}`src/signals/SignalsPending.lean <../src/signals/SignalsPending.lean>`, {download}`src/signals/SignalsTests.lean <../src/signals/SignalsTests.lean>`, {download}`src/signals/SignalsPendingTests.lean <../src/signals/SignalsPendingTests.lean>`
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`quantum_causal_inference` unit tests `7/7` passing):
    - {download}`src/signals/numerical_adapter/src/quantum_causal_inference.rs <../src/signals/numerical_adapter/src/quantum_causal_inference.rs>` (Sections 11 & 11.1: `wias_column_pivoted_qr_solve`, `audit_osid_allen_cahn_pde`, `audit_osid_lorenz_ode`, `audit_osid_matrix_circulant_hankel_and_switch`, `audit_osid_noisy_jeffrey_qfim_landauer`, `audit_osid_duffing_oscillator`, `audit_osid_2d_pdes_allen_cahn_elliptic_ns`, `audit_osid_qi_ranard_hamiltonian`, `audit_osid_zhao_and_goswami_literature_benchmarks`)
    - {download}`src/signals/numerical_adapter/src/lib.rs <../src/signals/numerical_adapter/src/lib.rs>` (`py_audit_qci_one_shot_sysid`, `py_audit_qci_one_shot_sysid_literature_benchmarks`)
  - Python + SymPy + 45-Digit `mpmath` + PyO3 Verification Suite (`4/4` `pytest` tests passing):
    - {download}`sustainablefactory/one_shot_sysid.py <../sustainablefactory/one_shot_sysid.py>`
    - {download}`tests/test_one_shot_sysid_sympy_pyo3.py <../tests/test_one_shot_sysid_sympy_pyo3.py>`

---

## Abstract

In *A zero-one law for one-shot system identification* {cite:p}`boulle2026zeroone,boulle2026oneshot_full`, Boullé, Halikias, Otto, and Townsend proved a foundational dichotomy for linearly parameterized analytic systems $\mathcal{L}(u, f) := \sum_{i=1}^N c_i^* \mathcal{D}_i(u, f) = \mathcal{D}_0(u, f)$: either *no* admissible input $f \in \mathcal{F}$ uniquely identifies $\mathbf{c}^* \in \mathbb{R}^N$ ($\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*) = \mathcal{F}$), or $\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*)$ is compactly slice-null and has measure zero under every nondegenerate Gaussian measure on $\mathcal{F}$. Their Weak Identification of Analytic Systems (`WIAS`) algorithm detects nondegeneracy *a posteriori* via rank-revealing column-pivoted QR factorization on a tested dictionary matrix $G_{ij} = \psi_i(\mathcal{D}_j(u, f))$.

As applied quantum physicists, we reimplement and generalize this one-shot framework using our **Grassmannian Quantum Causal Inference (`QCI`)** mechanics (`Signals.QuantumCausalInference`, `Signals.Plabic`, `Signals.DDF`), producing **Quantum-Causal Grassmannian One-Shot System Identification (`QCI-OSID`)**, verified across **Lean 4** (zero `sorry`), **Rust/PyO3**, **SymPy**, and **45-digit `mpmath`**:

1. **Cauchy–Binet / Plücker Grassmannian Injectivity & Schubert Degeneracy (`osidRecovery2x3GramDet`, `osidPlucker2x3NormSq`):** We prove that $G(f) \in \mathbb{R}^{r_0 \times N}$ defines an $N$-plane in $\mathrm{Gr}_{\mathbb{R}}(N, r_0)$ whose Gram determinant decomposes identically as the sum of squared Plücker minors $\det(G^\top G) = \Delta_{01}^2 + \Delta_{02}^2 + \Delta_{12}^2 \ge 0$ (`20.9892` on a generic $3 \times 2$ test; `0.0` on collinear/confounder bottlenecks), guaranteeing $\ker G = \{0\}$ whenever $\det(G^\top G) > 0$.
2. **Circulant vs. Hankel Zero-One Probe Dichotomy (`osid_hankel_vs_circulant`):** We prove in Lean 4 that $n \times n$ Circulant matrices ($N = n \le 1 \cdot n$) lie in alternative (i) with 1 Gaussian probe ($4\times 4$ recovery error $5.55 \times 10^{-15}$), whereas $n \times n$ Hankel matrices ($n \ge 2$, $N = 2n - 1 > n$) force *every* single classical right probe into alternative (ii) ($\mathrm{rank} \le 3 < 5$), and recover full rank $5$ in 2 probes ($6.66 \times 10^{-16}$ error) governed by the Plücker determinant $-f_1 \Delta(f, g)$.
3. **Pearl $\operatorname{do}(f := f_{\mathrm{probe}})$ Deconfounding & Giarmatzi–Costa Abduction:** Passive closed-loop observations introduce backdoor confounding bias $b_{\mathrm{conf}}$ (`10.45` vs. true `10.0` on a confounded Lorenz trajectory). Performing Pearl incoming-edge surgery $\operatorname{do}(f)$ annihilates $b_{\mathrm{conf}}$ while weak-form `WIAS` recovers $(\sigma, \rho, \beta) = (10, 28, 8/3)$ from a single chaotic RK4 trajectory to $7.66 \times 10^{-7}$ (`sigma_min = 0.00245`) and Giarmatzi–Costa abduction recovers exogenous state $u_E = 1.5$ in the same shot.
4. **Coherent $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch & Pole-Free `VRC` Single-Shot Operator Probing:** For non-commuting $2 \times 2$ operators $(U_A, U_B)$, a coherent control qubit $|+\rangle_c$ extracts both the anticommutator channel $E_+ = \cos^2(\pi/6) = 0.75$ and commutator channel $E_- = \sin^2(\pi/6) = 0.25$ via the $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker ratio $\lVert w_B^{\mathbb{C}}\rVert^2 / \lVert w_A^{\mathbb{C}}\rVert^2 = 1/3$ in **one coherent quantum shot**, while pole-free `.complexHomogeneousVRC` cancels destructive conflict states ($x_X = -1$) to exact `0.0`.
5. **Noisy Soft-Partition Jeffrey Kinematics, `QFIM = 4 g_FS` QCRB Conditioning, & Closed-Loop Landauer Thermodynamics:** Extending `WIAS` to noisy soft-partition measurements, **Jeffrey's Kinematic Engine** updates posterior coefficients linearly without Bayes certainty (`8.24`), $\pi$-phase averaging eliminates coherent cross-term bias (`0.0` residual), `QFIM = 4 g_FS` sets the Quantum Cramér–Rao variance bound $\mathrm{Var}(\hat{c}) \ge (4 M g_{\mathrm{FS}})^{-1}$ (`0.2` for 1 shot at $g_{\mathrm{FS}} = 1.25$), and closed-loop conditional Landauer accounting proves a strict $M$-fold cyclic heat reduction ($1.25$ vs. $12.5$ thermal units for $1$-shot vs. $10$-shot experiments).

---

## 1. From Classical `WIAS` (Boullé et al. 2026) to Quantum-Causal `QCI-OSID`

```{mermaid}
flowchart LR
    subgraph Classical["1. Classical WIAS (Boullé, Halikias, Otto, & Townsend 2026)"]
        C1["Analytic System: Σ c_i^* D_i(u, f) = D_0(u, f)\n• Sample f ~ Gaussian γ on Banach space F\n• Assemble G_{ij} = ψ_i(D_j(u, f)) ∈ R^{r_0 × N}\n• Column-Pivoted QR: G P = Q R\n• Rank N => Unique c^* (Zero-One Law)"]
    end

    subgraph Causal["2. Grassmannian & Pearl do-Surgery Layer"]
        G1["Plabic / LGV Grassmannian Geometry\n• N-plane in Gr_R(N, r_0): det(G^T G) = Σ Δ_I(G)^2 > 0\n• Confounder / Harmonic Bottleneck => det = 0\n• Pearl do(f := f_probe) severs U -> f backdoor b_conf\n• Giarmatzi–Costa Abduction recovers exogenous u_E"]
    end

    subgraph Quantum["3. Quantum Switch, Tautological Bundle, & Thermodynamics"]
        Q1["Applied Quantum Physics Extensions (QCI-OSID)\n• Gr_C(2,4) Quantum Switch extracts E_+ & E_- in 1 shot\n• Tautological Bundle (Z, v) + Cross-Lag Q_4 > 0\n• Soft Noisy Measurements -> Jeffrey's Kinematic Engine\n• QFIM = 4 g_FS sets QCRB & 1-shot saves M× Landauer heat"]
    end

    Classical -->|"Causal & Plücker\nreimplementation"| Causal -->|"Coherent probing, noise,\n& thermodynamics"| Quantum
```

In {cite:p}`boulle2026zeroone` and {cite:p}`boulle2026oneshot_full`, an unknown analytic model is parameterized linearly over a prescribed dictionary $\{\mathcal{D}_i\}_{i=0}^N$:

$$
\mathcal{L}(u, f) := \sum_{i=1}^N c_i^* \mathcal{D}_i(u, f) = \mathcal{D}_0(u, f),
$$

with well-posed analytic solution operator $\mathcal{G} : \mathcal{F} \to \mathcal{U}$ on a separable Banach space $\mathcal{F}$ possessing a countable Schauder basis. Defining the parameter-to-recovery linear map $L_{f,u}(\mathbf{a}) = \sum_{i=1}^N a_i \mathcal{D}_i(u, f)$ and the degenerate input set $\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*) = \{f \in \mathcal{F} \mid \ker L_{f,\mathcal{G}(f)} \neq \{0\}\}$, Theorem 1 of Boullé et al. {cite:p}`boulle2026zeroone` proves the sharp dichotomy:

1. Either $\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*)$ is **compactly slice-null** and $\gamma(\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*)) = 0$ for every nondegenerate Gaussian measure $\gamma$ on $\mathcal{F}$ (meaning a single random Gaussian probe identifies $\mathbf{c}^*$ almost surely), or
2. $\mathcal{F}_{\mathrm{deg}}(\mathbf{c}^*) = \mathcal{F}$ (no input identifies $\mathbf{c}^*$, forcing either a change of dictionary/symmetry-breaking or multi-shot stacking).

While mathematically sharp in the noiseless, unconfounded, classical Banach setting, deploying one-shot identification in **applied quantum and physical systems** exposes five structural challenges that motivate our `QCI-OSID` reimplementation:

| Aspect | Classical `WIAS` {cite:p}`boulle2026zeroone,boulle2026oneshot_full` | Quantum-Causal `QCI-OSID` (`Signals.QuantumCausalInference` Sec. 16) |
| --- | --- | --- |
| **Algebraic Certificate** | Determinant of tested square submatrix $\det(\Psi L_{f,\mathcal{G}(f)} E) \neq 0$ or column-pivoted QR rank $N$. | **Cauchy–Binet / Plücker Norm on $\mathrm{Gr}_{\mathbb{R}}(N, r_0)$**: $\det(G^\top G) = \sum_{\lvert I\rvert = N} \Delta_I(G)^2 > 0$; degeneracy $\det = 0$ is an LGV/Schubert boundary (`singleHubRepresentative_det = 0`). |
| **Confounding & Drift** | Assumes $(f, u)$ is free of hidden common causes $U$ ($U \to f, U \to u$). | **Pearl $\operatorname{do}(f := f_{\mathrm{probe}})$ Incoming-Edge Surgery** eliminates backdoor bias $b_{\mathrm{conf}}$, while **Giarmatzi–Costa Abduction** {cite:p}`giarmatzi2023semantics` extracts exogenous state $u_E$. |
| **When $N > n$ (e.g., Hankel)** | Requires $q_R \ge 2$ sequential right probes ($n < 2n - 1$). | **Coherent $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch** {cite:p}`oreshkov2012quantumCorrelations,chiribella2013switch` superposes causal/adjoint orders to extract $E_+, E_-$ in 1 quantum shot; pole-free `.complexHomogeneousVRC` eliminates rational-chart poles. |
| **Spatiotemporal Scaling & Soft Noise** | Dense weak/FEM projections; open question for noisy or partial observations. | **Tautological Bundle `(Z, v)`** {cite:p}`declercq2026bundleTransformer` + cross-lag $\mathcal{Q}_4 > 0$ {cite:p}`zhang2025grassmannFlows`; **Jeffrey's Kinematic Engine** {cite:p}`jeffrey1965logicOfDecision,diaconisZabell1982updating` updates soft noisy partitions linearly. |
| **Precision & Thermodynamic Cost** | Diagnostics via $\sigma_{\min}(G)$ and qualitative irreversibility motivation. | **Quantum Cramér–Rao Bound** via `QFIM = 4 g_FS` {cite:p}`braunstein1994statistical` ($\mathrm{Var}(\hat{c}) \ge (4 M g_{\mathrm{FS}})^{-1}$) and **$M$-fold Closed-Loop Landauer Bound** {cite:p}`delRio2011thermodynamicMeaning`. |

---

## 2. Cauchy–Binet Plücker Grassmannian Injectivity and the Hankel–Circulant Dichotomy

### 2.1 Plücker Sum-of-Squares Injectivity on $\mathrm{Gr}_{\mathbb{R}}(2, 3)$

When $r_0 \ge N$ linearly independent test functionals $\psi_1, \dots, \psi_{r_0} \in \mathcal{V}^*$ produce the tested recovery matrix $G \in \mathbb{R}^{r_0 \times N}$, the columns of $G$ span an $N$-dimensional subspace in $\mathrm{Gr}_{\mathbb{R}}(N, r_0)$ iff $G$ is injective ($\ker G = \{0\}$). In Lean 4 (`osidRecovery2x3GramDet`, `osidPlucker2x3NormSq`), we formalize the $r_0 = 3, N = 2$ case with columns $\mathbf{a} = (a_0, a_1, a_2)^\top$ and $\mathbf{b} = (b_0, b_1, b_2)^\top$, proving the exact Cauchy–Binet Plücker identity:

$$
\det(G^\top G) = \|\mathbf{a}\|^2 \|\mathbf{b}\|^2 - \langle \mathbf{a}, \mathbf{b}\rangle^2 = \Delta_{01}(G)^2 + \Delta_{02}(G)^2 + \Delta_{12}(G)^2 \ge 0,
$$

where $\Delta_{ij}(G) = a_i b_j - a_j b_i$ (`plucker2DCoord`) are the Plücker coordinates of the 2-plane in $\mathrm{Gr}_{\mathbb{R}}(2, 3)$. Master Theorem 11 (`qci_osid_cauchy_binet_hankel_do_qfim_and_landauer_identities`) proves that:
- Under any collinear/confounder bottleneck ($\mathbf{b} = \lambda \mathbf{a}$), every Plücker minor vanishes and $\det(G^\top G) = 0$;
- Whenever $\det(G^\top G) > 0$, any kernel relation $c_1 \mathbf{a} + c_2 \mathbf{b} = \mathbf{0}$ satisfies $c_k \Delta_{ij}(G) = 0$ for all $(i,j)$, forcing $c_1^2 \det(G^\top G) = c_2^2 \det(G^\top G) = 0 \implies c_1 = c_2 = 0$ (strict injectivity of $L_{f,u}$).

### 2.2 Circulant (1-Shot) vs. Hankel (1-Probe Deficit & 2-Probe Plücker Recovery)

For structured matrix families $A(\mathbf{c}^*) = \sum_{i=1}^N c_i^* A_i \in \mathbb{R}^{n \times n}$ observed via right matrix-vector products $A \mathbf{f} \in \mathbb{R}^n$ {cite:p}`halikias2024matrix,boulle2026zeroone`, our dimension-counting and determinant theorems in Lean 4 establish the exact boundary between alternative (i) and alternative (ii):
- **$n \times n$ Circulant Family ($N = n$):** One right probe provides $1 \cdot n = n \ge N$ equations. For $n = 2$, the recovery determinant $\det G_{\mathrm{circ}}^{(2)}(\mathbf{f}) = f_0^2 - f_1^2 = (f_0 - f_1)(f_0 + f_1)$ vanishes only on the codimension-1 union of lines $f_0 = \pm f_1$. In general $n$, $\det G_{\mathrm{circ}}^{(n)}(\mathbf{f}) = \prod_{k=0}^{n-1} \hat{f}_k$, so any Gaussian probe with nonzero DFT modes recovers $\mathbf{c}^*$ in **1 shot** (`4x4` Rust/45-digit `mpmath` audit: $\det(G^\top G) = 60.014460$, max coefficient error $5.55 \times 10^{-15}$).
- **$n \times n$ Hankel Family ($n \ge 2$, $N = 2n - 1$):** One right probe yields only $n < 2n - 1$ linear equations (`osidMultiProbeEquationCount 1 n < osidHankelParamCount n`), placing every single-probe input in $\mathcal{F}_{\mathrm{deg}}^{(1)} = \mathcal{F}$ (zero-one alternative (ii), verified in Rust on $3 \times 3$ Hankel: $3$ rows, $5$ columns, $\mathrm{rank} = 3 < 5$). Stacking $q_R = 2$ probes $(\mathbf{f}, \mathbf{g})$ yields $2n \ge 2n - 1$ equations; for $n = 2$ ($N = 3$), the $3 \times 3$ recovery determinant is exactly:

$$
\det \begin{pmatrix} f_0 & f_1 & 0 \\ 0 & f_0 & f_1 \\ g_0 & g_1 & 0 \end{pmatrix} = -f_1 \bigl(f_0 g_1 - f_1 g_0\bigr) = -f_1\,\operatorname{plucker2DCoord}(f_0, f_1, g_0, g_1),
$$

requiring $f_1 \neq 0$ and a nonzero Plücker wedge $\mathbf{f} \wedge \mathbf{g} \neq 0$. For $3 \times 3$ Hankel ($N=5$), 2 probes recover full rank $5$ with max coefficient error $6.66 \times 10^{-16}$.

---

## 3. Pearl $\operatorname{do}$-Surgery, Quantum Switch Super-Resolution, & Soft-Noise Jeffrey/QFIM/Landauer Bounds

### 3.1 Eliminating Closed-Loop Confounding & Abducing Exogenous State (`do`-Calculus + Giarmatzi–Costa)

In physical systems where an ambient drift or feedback loop $U$ simultaneously modulates the probe $f$ and observed response $u$, passive observational regression recovers a biased slope (`osidObservationalSlope c_true b_conf = c_true + b_conf`). Applying **Pearl's incoming-edge surgery** $\operatorname{do}(f := f_{\mathrm{probe}})$ {cite:p}`pearl2009causality` severs $U \to f$, recovering the exact unbiased coefficient $c^*$ (`10.0` vs. confounded `10.45` in our Lorenz audit), while **Giarmatzi–Costa Abduction–Action–Prediction** {cite:p}`giarmatzi2023semantics` extracts the exogenous nuisance shift $u_E = y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}}$ (`1.5`) from the very same single trajectory.

### 3.2 Coherent $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch & Pole-Free `VRC` 1-Shot Operator Probing

When classical single-shot probing fails due to $N > n$ or non-commuting operator structure, our **Quantum Switch** (`evaluate_quantum_switch_2x2` on $\mathrm{Gr}_{\mathbb{C}}(2,4)$) routes a single system state $|\psi\rangle$ and a single control qubit $|+\rangle_c = \frac{1}{\sqrt{2}}(|0\rangle_c + |1\rangle_c)$ through two operations $(U_A, U_B)$ in superposition of $A \prec B$ and $B \prec A$:

$$
\mathcal{S}(U_A, U_B)\bigl(|+\rangle_c \otimes |\psi\rangle\bigr)
= |+\rangle_c \otimes \frac{\{U_A, U_B\}}{2}|\psi\rangle + |-\rangle_c \otimes \frac{[U_B, U_A]}{2}|\psi\rangle.
$$

Measuring the control in $|\pm\rangle_c$ yields the anticommutator channel weight $E_+ = \frac{1}{4}\lVert\{U_A, U_B\}|\psi\rangle\rVert^2$ and commutator channel weight $E_- = \frac{1}{4}\lVert[U_B, U_A]|\psi\rangle\rVert^2$, whose asymmetry $\delta_{\mathrm{switch}} = \frac{E_+ - E_-}{E_+ + E_-}$ encodes into `ddfThermalGr24Matrix` so that $\lVert w_B^{\mathbb{C}}\rVert^2 / \lVert w_A^{\mathbb{C}}\rVert^2 = E_- / E_+$. For $U_A = \exp(i \frac{\pi}{6} X)$ and $U_B = Z$ acting on $|0\rangle$, Rust and 45-digit `mpmath` agree to $1.11 \times 10^{-16}$ on $E_+ = 0.75$, $E_- = 0.25$, and Plücker ratio $1/3$ from **one coherent shot**. Simultaneously, replacing rational Plabic charts with pole-free `.complexHomogeneousVRC` preserves finite coordinates at the destructive resonance $x_X = -1$, annihilating spurious conflict states (`qciNcmCoherentPairwiseCodeProb = 0.0`).

### 3.3 Soft-Partition Jeffrey Kinematics, `QFIM = 4 g_FS` QCRB, & Closed-Loop Landauer Heat

Addressing the open noise and irreversibility questions highlighted in {cite:p}`boulle2026zeroone`:
1. **Noisy Soft-Partition Updates (`Jeffrey's Kinematic Engine`):** When a single noisy measurement only updates probabilities $(q_1, q_2)$ across a sensor partition $\{E_1, E_2\}$ rather than fixing $u = \mathcal{G}(f)$ noiselessly, `jeffreyKinematicUpdate` preserves the $\operatorname{do}$-invariant conditional mechanism $(c_1^{\operatorname{do}}, c_2^{\operatorname{do}})$ (`8.24`), and $\pi$-phase averaging of `quantumJeffreyPluckerKinematicUpdate` cancels coherent interference bias to `0.0`.
2. **Quantum Cramér–Rao Conditioning (`QFIM = 4 g_FS`):** For any quantum probe manifold with Fubini–Study metric $g_{\mathrm{FS}} > 0$, `osidQfimFromFubiniStudy` $= 4 g_{\mathrm{FS}}$ governs the single-shot Quantum Cramér–Rao variance floor (`osidQcrbVarianceLowerBound 1 g_fs = 1 / (4 g_fs)` = `0.2` at $g_{\mathrm{FS}} = 1.25$) {cite:p}`braunstein1994statistical`.
3. **Closed-Loop Thermodynamic Justification for 1-Shot Probing:** Even using single-shot entangled readout (`delRioConditionalLandauerHeat`, {cite:p}`delRio2011thermodynamicMeaning`), resetting the probe memory obeys the Second Law (`closedLoopErasureAndMemoryResetHeat = k_B T ln 2 + q_overhead`), so $M$-shot system identification incurs at least $M \cdot k_B T \ln 2$ cyclic heat (`1.25` vs. `12.5` for $1$ vs. $10$ shots).

---

## 4. Tri-Language Verification Ledger (Lean 4, Rust/PyO3, SymPy, & 45-Digit `mpmath`)

Running `make signals_build` (`3,837` Lake jobs, zero `sorry`), `cargo test --lib quantum_causal_inference` (`7/7` tests passing), and `pytest -q tests/test_one_shot_sysid_sympy_pyo3.py` (`4/4` tests passing) yields exact agreement across all core and literature benchmarks:

| Benchmark / Quantity Audited | Parameters / Setting | Lean 4 / Exact Theory | Rust/PyO3 (`f64`) | Discrepancy vs. 45-Digit `mpmath` / Exact |
| --- | --- | --- | --- | --- |
| Cauchy–Binet Plücker $\det(G^\top G)$ | $3 \times 2$ generic vs. collinear | $\Delta_{01}^2 + \Delta_{02}^2 + \Delta_{12}^2$ (`Master Thm 11`) | `20.9892` (collinear `0.0`) | $3.55 \times 10^{-15}$ |
| Allen–Cahn PDE 1-shot (`generic`) | $u_{xx}, u, u^3$ ($c^* = [-0.01, -1, 1]$) | $\mathrm{rank} = 3$, $\det(G^\top G) > 0$ | $\sigma_{\min} = 0.24333$, $\det = 167.745$ | Max coeff err $1.11 \times 10^{-15}$ |
| Allen–Cahn harmonic degeneracy | $u = \sin(\pi x)$, $\{u_{xx}, u\}$ | $\det = 0$ (`Example 30` {cite:p}`boulle2026oneshot_full`) | $\mathrm{rank} = 1 < 2$, $\sigma_{\min} = 1.22 \times 10^{-17}$ | $\det(G^\top G) = 0.0$ |
| Cross-lag 4D Klein quadric $\mathcal{Q}_4$ | Escaping shared-anchor collapse | $\mathcal{Q}_4 \neq 0$ (`Sec. 2.2` [Paper 20](grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md)) | `-0.527` | Exact non-collapse |
| Chaotic Lorenz ODE (1 trajectory) | 6-term dictionary, Simpson weak form | $\mathrm{rank} = 6$, $(\sigma,\rho,\beta)=(10,28,8/3)$ | $\hat{\sigma}=9.9999994$, $\hat{\rho}=28.0000007$, $\hat{\beta}=2.66666669$ | Max err $7.66 \times 10^{-7}$ ($\beta$: $2.39 \times 10^{-8}$) |
| Pearl $\operatorname{do}$-deconfounding & abduction | $b_{\mathrm{conf}} = 0.45$, $y_{\mathrm{obs}} = 21.5$ | `obs - do = b_conf`, $u_E = 1.5$ | `obs = 10.45`, `do = 10.0`, `u_E = 1.5` | Exact (`0.0`) |
| $4 \times 4$ & $40 \times 40$ Circulant (1 Gaussian probe) | $N = n$, 1 right probe $\mathbf{f}$ | $N \le 1 \cdot n$, $\prod_k \lvert\hat{f}_k\rvert^2$ | $4\times 4$ $\mathrm{rank}=4$, $\det=60.01446$; $40\times 40$ $\mathrm{rank}=40$ | $3.48\times 10^{-13}$ (coeff $5.55\times 10^{-15}$ / $5.00\times 10^{-15}$) |
| $3 \times 3$ & $40 \times 40$ Hankel (1 vs. 2 probes) | $N = 2n - 1$, $n = 3, 40$ | $1 \cdot n < 2n - 1 \le 2 \cdot n$ (`Master Thm 11`) | 1-shot $\mathrm{rank} = 3, 40$; 2-shot $\mathrm{rank} = 5, 79$ | 2-shot max err $6.66\times 10^{-16}$ ($n=3$), $1.02\times 10^{-14}$ ($n=40$) |
| $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch | $U_A = e^{i\frac{\pi}{6}X}, U_B = Z$ | $(E_+, E_-) = (\cos^2 \tfrac{\pi}{6}, \sin^2 \tfrac{\pi}{6})$ | `E_+ = 0.75`, `E_- = 0.25`, ratio `1/3` | $1.11 \times 10^{-16}$ |
| Pole-free `.complexHomogeneousVRC` | Destructive resonance $x_X = -1$ | `qciNcmCoherentPairwiseCodeProb = 0` | `0.0` | Exact (`0.0`) |
| Jeffrey Kinematics, QCRB, & Landauer | $g_{\mathrm{FS}} = 1.25$, $M = 1$ vs. $10$ | `QFIM = 5`, QCRB `0.2`, $10\times$ heat | `8.24`, `0.2` vs. `0.05`, `1.25` vs. `12.5` | Exact (`0.0`) |

### 4.1 Cross-Literature Check Figures & Experimental Benchmarks (`Master Theorem 11.1`)

To anchor `QCI-OSID` directly against published numerical and experimental check figures across classical one-shot system identification, single-eigenstate quantum Hamiltonian learning, and indefinite causal order metrology, Section 16.1 of `Signals.QuantumCausalInference` (`qci_osid_literature_benchmarks_duffing_elliptic_qi_ranard_and_switch_identities`), Section 11.1 of `quantum_causal_inference.rs` (`py_audit_qci_one_shot_sysid_literature_benchmarks`), and `verify_symbolic_literature_check_figures` / `audit_qci_literature_benchmarks_high_precision` implement and verify five external benchmark families:

1. **Forced Duffing Oscillator (`02_duffing.ipynb`, Fig. 1D of {cite:p}`boulle2026zeroone`):** For $u'' + \delta u' + \alpha u + \beta u^3 = \gamma \cos(\omega t)$ with $\alpha = 1.0$, $\beta = 5.0$, $\delta = 0.02$, $\gamma = 8.0$, $\omega = 0.5$, and $u(0) = 0.49671415$, $v(0) = 0$ over the 11-term second-order dictionary $[u'', 1, u, v, u^2, uv, v^2, u^3, u^2 v, uv^2, v^3]$ (`build_weak_system_second_order`), Boullé et al.'s `CPQR_solver` reports coefficient errors $5.15 \times 10^{-11}$ ($u$), $4.04 \times 10^{-11}$ ($v$), $-1.01 \times 10^{-10}$ ($u^3$), and $1.05 \times 10^{-10}$ (forcing). Lean 4 proves exact scaling invariance of `osidDuffingNormalizedCoeff` ($-\theta_j / \theta_{u''}$), while our Rust RK4 + $\sin^4(\pi\tau)$ second-order integration-by-parts `CPQR` recovers `rank = 11`, $\theta_{u''} = 1.0000000000015592$, and max coefficient error $3.864 \times 10^{-11}$ ($\sigma_{\min} = 0.5372$).
2. **2D Quintic Allen–Cahn (`03_allen_cahn.ipynb`), 2D Elliptic Coprime Degeneracy (`arXiv:2611.30470v1` Prop. 36), 2D Navier–Stokes Continuity & 16-Term Momentum (`04_navier_stokes.ipynb`), & Large-Matrix Scaling (`05_hankel_matrix.ipynb`, `06_circulant_matrix.ipynb`) {cite:p}`boulle2026zeroone,boulle2026oneshot_full`:**
   - On 2D quintic Allen–Cahn ($0.25\Delta u - 5 u - u^3 + u^5 = f$ on $(0,1)^2$), `wias` reports errors $0\text{–}1.124\times 10^{-12}$ on a $10{,}201 \times 10$ FEM weak system; our Rust overlapping-patch `CPQR` audit achieves full `rank = 9` with max error $4.803 \times 10^{-11}$.
   - For the 2D elliptic operator $a^* u_{xx} + b^* u_{yy} = f$, Proposition 36 of {cite:t}`boulle2026oneshot_full` proves that any state in $\overline{\mathrm{span}\{\psi_{km}\otimes\psi_{kn}\}}$ with $\gcd(m,n)=1$ has kernel $(a, b) = (n^2, -m^2)$. Lean 4 proves `osidEllipticModeKernelResidual (n^2) (-m^2) k m n = 0` identically; Rust (using QR-diagonal $\det(G^\top G) = \prod R_{ii}^2 \ge 0$ to avoid $\kappa(G)^2$ cancellation) confirms for $(m, n) = (2, 3)$ and $(a^*, b^*) = (2, 3)$ that the coprime ray collapses to `rank = 1` ($\det(G^\top G) = 1.222 \times 10^{-24}$, ray residual $1.71 \times 10^{-13}$ for $(9, -4)$), whereas adding one off-ray mode restores `rank = 2` with error $7.55 \times 10^{-15}$.
   - On steady incompressible 2D Navier–Stokes ($\nu = 10^{-3}$, $\mathrm{Re} = 1000$, `04_navier_stokes.ipynb`), `wias` reports continuity singular values $[3.96\times 10^{-2}, 2.70\times 10^{-2}, 1.21\times 10^{-2}, 1.71\times 10^{-16}]$, nullspace residual $2.358 \times 10^{-16}$, and 16-term momentum max error $4.605 \times 10^{-14}$; our Rust streamfunction audit achieves continuity `rank = 3`, $\sigma_4 = 0.0$ (max err $0.0$), and full 16-term momentum `rank = 16`, recovering $\hat{\nu} = 0.00100000000000001$ with max coefficient error $5.063 \times 10^{-12}$. On large structured matrices (`05_hankel_matrix.ipynb`, `06_circulant_matrix.ipynb`), `wias` at $n = 1000$ records $1$-shot Circulant error $1.96 \times 10^{-13}$, $1$-shot Hankel failure $1.98 \times 10^2$ ($1000 \times 1999$, deficit $999$), and $2$-shot Hankel recovery $2.82 \times 10^{-11}$ ($2000 \times 1999$), matching our $n = 40$ Rust `CPQR` scaling check ($40 \times 40$ Circulant err $5.00 \times 10^{-15}$; $40 \times 79 \to 80 \times 79$ Hankel err $1.02 \times 10^{-14}$).
3. **Single-Eigenstate Local Hamiltonian Identification — Qi & Ranard (2019) & Bairey, Arad, & Lindner (2019) {cite:p}`qi2019determining,bairey2019learning`:** For a $k$-local Hamiltonian $H = \sum_{i=1}^N c_i^* L_i$ and a **single eigenstate** $\lvert v\rangle$, Qi and Ranard {cite:p}`qi2019determining` (Eq. 1.1) form the connected $k$-correlation matrix

   $$
   M_{ij}(v) = \frac{1}{2}\langle v \rvert \{L_i, L_j\} \lvert v\rangle - \langle v \rvert L_i \lvert v\rangle \langle v \rvert L_j \lvert v\rangle,
   $$

   proving $\mathbf{w}^\top M(v)\mathbf{w} = \langle O^2\rangle_v - \langle O\rangle_v^2 = 0 \iff O\lvert v\rangle = \alpha\lvert v\rangle$, so $H$ is uniquely identified up to scale (paralleling Remark 9 of {cite:t}`boulle2026oneshot_full`) whenever $\lambda_1(v) = 0 < \lambda_2(v)$, with $12 n < 2^{n+1}$ parameter compression on periodic 1D chains for all $n \ge 10$ ($120 < 2048$ at $n=10$; $144 < 8192$ at $n=12$) and Davis–Kahan conditioning $\frac{1}{2}\sin 2\theta \le \epsilon \lVert\Delta M(v)\rVert / \lambda_2(v)$ (Eq. 3.7). Similarly, Bairey, Arad, and Lindner {cite:p}`bairey2019learning` recover $\mathbf{c}^*$ via the linear local-commutator nullspace $K_{j,m} = i\langle \psi \rvert [h_m, \mathcal{O}_j]\lvert\psi\rangle$, $K\mathbf{c} = \mathbf{0}$. Lean 4 proves the positive-semidefinite quadratic form, the induction compression theorem `osidQiRanard_spin_chain_dim_lt_hilbert` ($\forall n \ge 10,\, 12n < 2^{n+1}$), and Davis–Kahan monotonicity (`osidQiRanardCorrQuadForm2`, `osidQiRanardDavisKahanBound`); SymPy verifies exact 2-qubit kernels for both $M(v_0)$ (`< 1e-25`) and $K\mathbf{c}=\mathbf{0}$ (`rank = 3`); and Rust Jacobi diagonalization on a 4-qubit ($d=16, N=8$) disordered Ising chain yields $\lambda_1(M) = -1.82 \times 10^{-15}$, $\lambda_2(M) = 4.985 \times 10^{-3}$, projective angle error $0.0\text{ rad}$, max scaled error $1.704 \times 10^{-14}$, empirical Davis–Kahan check $\tfrac{1}{2}\sin(2\theta_{\mathrm{noisy}}) = 2.015 \times 10^{-4} \le 5.991 \times 10^{-3}$, and independent Bairey–Arad–Lindner nullspace recovery ($\lambda_1(K^\top K) = -2.57 \times 10^{-16}$, $\lambda_2(K^\top K) = 1.085 \times 10^{-3}$, max recovered error $1.551 \times 10^{-13}$).
4. **Super-Heisenberg Quantum Switch Metrology & Photonic Causal Witness Margins — Zhao, Yang, & Chiribella (2020), Rubino et al. (2017), & Goswami et al. (2018) {cite:p}`zhao2020metrology,rubino2017experimental,goswami2018indefinite`:** When estimating the displacement product $A = \bar{x}\bar{p}$ across $N$ position and $N$ momentum shifts with energy $E$ and $\nu$ repetitions, fixed causal order obeys the Heisenberg limit $\Delta A_{\mathrm{fixed}} \ge \frac{\min(\lvert\bar{x}\rvert,\lvert\bar{p}\rvert)}{N\sqrt{8\nu E}}$ ($O(1/N)$), whereas the Quantum Switch achieves Fisher information $F_A = N^4$ (`Eq. 5`) and **super-Heisenberg** precision $\Delta A_{\mathrm{switch}} = \frac{1}{\sqrt{\nu}\,N^2}$ (`Eq. 6`; heterodyne bound `Eq. 7`: $\Delta A'_{\mathrm{switch}} = \Delta A_{\mathrm{switch}}\sqrt{\frac{\bar{x}^2+\bar{p}^2}{\bar{x}^2+\bar{p}^2+1/N^2}}$) {cite:p}`zhao2020metrology`. Lean 4 proves the universal crossover (`8 * E < z_min^2 * N^2` $\implies$ $\Delta A_{\mathrm{switch}}^2 < \Delta A_{\mathrm{fixed}}^2$) and universal strict heterodyne improvement (`osidZhaoSwitchHeterodyneRmseSq < osidZhaoSwitchRmseSq`). Experimentally, photonic Quantum Switch witnesses violate definite causal order bounds at $\sim 7\sigma$ {cite:p}`rubino2017experimental` and at $\langle S\rangle_{\mathrm{exp}} = -0.171 \pm 0.009$ (ideal $-0.248$), giving $19.00\sigma$ ($\ge 18\sigma$) below the ideal separable bound $0$ and $14.78\sigma$ ($> 14\sigma$) below the misalignment-corrected bound $-0.038$ {cite:p}`goswami2018indefinite`. These published interferometric benchmarks quantify the empirical target for `QuantumSwitchInterferometricProbeCertificate` (which enforces $0 < E_+ + E_-$ and a $\ge 3\sigma$ causal witness margin) while keeping uncalibrated apparatus telemetry in `OneShotQuantumSysIdPendingBoundary`.

| Published Check Figure & Source | Published Literature Reference Value | `QCI-OSID` Lean 4 / SymPy / Rust / 45-Digit `mpmath` Result |
| --- | --- | --- |
| Forced Duffing (`02_duffing.ipynb` {cite:p}`boulle2026zeroone`) | `CPQR` coeff err $5.15\times 10^{-11}\text{–}1.05\times 10^{-10}$ | Lean invariance + Rust 11-term `rank = 11`, max err $3.864 \times 10^{-11}$ ($\sigma_{\min} = 0.5372$) |
| 2D Allen–Cahn (`03_allen_cahn.ipynb` {cite:p}`boulle2026zeroone`) | $10{,}201 \times 10$ FEM err $0\text{–}1.124 \times 10^{-12}$ | Rust 9-term overlapping-patch `rank = 9`, max err $4.803 \times 10^{-11}$ |
| 2D Elliptic Prop. 36 {cite:p}`boulle2026oneshot_full` | Coprime $\psi_{km}\otimes\psi_{kn}$ $\ker = \mathrm{span}\{(n^2,-m^2)\}$ | Lean + SymPy exact $0$; Rust $(2,3)$ `rank = 1`, $\det = 1.22\times 10^{-24}$ (res $1.71\times 10^{-13}$) vs. `rank = 2` ($7.55\times 10^{-15}$) |
| 2D Navier–Stokes & Matrices (`04–06` {cite:p}`boulle2026zeroone`) | $\sigma_4 = 1.71\times 10^{-16}$, mom. $4.61\times 10^{-14}$; Circ. $1.96\times 10^{-13}$; Hank. $1.98\times 10^2 \to 2.82\times 10^{-11}$ | Rust NS continuity `rank = 3` ($\sigma_4 = 0$), 16-term momentum `rank = 16` ($\hat{\nu} = 10^{-3}$, err $5.06\times 10^{-12}$); $n=40$ Circ. $5.00\times 10^{-15}$, Hank. $1.02\times 10^{-14}$ |
| Single-Eigenstate Hamiltonian {cite:p}`qi2019determining,bairey2019learning` | $\lambda_1(v) = 0 < \lambda_2(v)$, $12n < 2^{n+1}$, $\theta \approx 10^{-10}$, $K\mathbf{c}=\mathbf{0}$ | Lean $\forall n\ge 10$; SymPy 2-qubit exact; Rust 4-qubit: $\lambda_1 = -1.82\times 10^{-15}$, DK $2.02\times 10^{-4} \le 5.99\times 10^{-3}$, Bairey rec err $1.55\times 10^{-13}$ |
| Quantum Switch Metrology {cite:p}`zhao2020metrology` | $F_A = N^4$, $\Delta A'_{\mathrm{switch}} < \Delta A_{\mathrm{switch}} < \Delta A_{\mathrm{fixed}}$ | Lean universal crossover + heterodyne theorem; Rust/`mpmath` $F_{15} = 50{,}625$, $\Delta A_{\mathrm{switch}} = 0.001405 < 0.001863$ ($1.326\times$) |
| Photonic Switch Causal Witness {cite:p}`goswami2018indefinite,rubino2017experimental` | $\langle S\rangle = -0.171 \pm 0.009$ ($18\sigma$ / $14\sigma$); {cite:t}`rubino2017experimental` $\sim 7\sigma$ | Lean + SymPy exact $19\sigma \ge 18\sigma$, $\tfrac{133}{9}\sigma > 14\sigma$; Rust/`mpmath` diff $< 10^{-13}$ |

---

## 5. Epistemic Boundary (`Signals.Pending.OneShotQuantumSysIdPendingBoundary`)

In strict alignment with `AGENTS.md` and our seven-boundary closure architecture ({download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>`), `OneShotQuantumSysIdPendingBoundary` separates what our Lean 4, Rust/PyO3, and `mpmath` stack **proves** from three open external obligations:

1. **`banachZeroOneAnalyticClosed`:** Finite-dimensional Cauchy–Binet Plücker injectivity and $n$-vs-$(2n-1)$ Hankel/Circulant bounds do not themselves formalize infinite-dimensional separable Banach Schauder-basis analyticity and Bogachev Gaussian-measure disintegration on $\mathcal{F}$ (which remain cited to Boullé et al. {cite:p}`boulle2026zeroone,boulle2026oneshot_full`).
2. **`noisyDoProbeCalibrated`:** Symbolic Pearl $\operatorname{do}$-deconfounding and synthetic Lorenz/Allen–Cahn checks do not establish calibrated laboratory actuator isolation (`ControlledMeasurement`) in physical experiments with unknown hardware drift.
3. **`quantumSwitchProbeValidated`:** Algebraic $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Quantum Switch and `QFIM = 4 g_FS` / Landauer bounds do not certify physical photonic or superconducting Quantum Switch hardware visibility without interferometric calibration telemetry.

Supplying verified external witness certificates `(c1 : BanachZeroOneAnalyticCertificate)`, `(c2 : NoisyDoProbeCalibrationCertificate)`, and `(c3 : QuantumSwitchInterferometricProbeCertificate)` into `OneShotQuantumSysIdPendingBoundary.solved_of_certificates` discharges `allOsidGatesClosed` constructively, whereas `osid_finite_certs_do_not_close_banach_or_lab_gates` proves that finite checks alone never close those three gates.

---

## References

```{bibliography}
:filter: docname in docnames
:list: bullet
```
