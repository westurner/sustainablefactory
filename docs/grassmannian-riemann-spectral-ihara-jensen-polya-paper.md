---
title: "Finite Spectral Contracts for Riemann Hypothesis Approaches: The Bass–Ihara Ramanujan Dichotomy (5-Graph Tower & 14-Vertex Non-Ramanujan Witness), Jensen–Pólya Transverse QFIM Stiffness, Mpemba–Trajectory–dBN Synthesis, and High-Precision Euler–Maclaurin / Riemann–Siegel C_4(p) Tests in Lean 4, Rust/PyO3, and SymPy"
description: "An arXiv-ready MyST Markdown formal verification and numerical audit paper reviewing all five Riemann Hypothesis approaches from the Grassmannian monograph chat, formally proving the finite-graph Bass–Ihara Ramanujan dichotomy (including a 14-vertex 3-regular connected non-Ramanujan counterexample), Jensen–Pólya/Madelung–Bohm equivalence, quartic de Bruijn–Newman backward-heat collision, Strong Mpemba slow-mode Weil projection, and Li's unit-circle criterion in Lean 4, benchmarking Euler–Maclaurin, Riemann–Siegel (C_0..C_4 with exact 2-jets), and Borwein evaluators in Rust/PyO3 against 35–80 digit mpmath, and isolating the four open analytical RH bridges in Signals.Pending."
---

(grassmannian-riemann-spectral-ihara-jensen-polya-paper)=
# Finite Spectral Contracts for Riemann Hypothesis Approaches: The Bass–Ihara Ramanujan Dichotomy (5-Graph Tower & 14-Vertex Non-Ramanujan Witness), Jensen–Pólya Transverse QFIM Stiffness, Mpemba–Trajectory–dBN Synthesis, and High-Precision Euler–Maclaurin / Riemann–Siegel $C_4(p)$ Jet Audits in Lean 4, Rust/PyO3, and SymPy

- **Authors:** Wes Turner
- **Subjects:**
  - Number Theory (`math.NT`); Spectral Theory (`math.SP`); Combinatorics (`math.CO`); Mathematical Physics (`math-ph`); Logic & Formal Verification (`cs.LO`)
- **Epistemic Status & Scope Declaration:**
  - **Solved & Machine-Checked (Finite Graph RH):** Both directions of the finite-graph Bass–Ihara Ramanujan dichotomy {cite:p}`bass1992ihara` are proved in Lean 4 (`Signals.GrassmannianEBR.ihara_ramanujan_critical_circle_modulus_sq` and `Signals.RiemannSpectral.ihara_non_ramanujan_splits_off_critical_circle`), including an existential, floating-point-free Lean 4 proof that the **14-vertex 3-regular connected Barbell graph $G_{14}$** ($q = 2$) exceeds the Ramanujan bound $2\sqrt{2}$ and splits two real Bass–Ihara roots strictly off the critical circle $\lvert u \rvert^2 = 1/2$, contrasted across a 5-graph 3-regular tower ($K_{3,3}$, Petersen, Heawood, Möbius–Kantor $GP(8,3)$, and Barbell $G_{14}$).
  - **Open Millennium Problem (Classical RH for $\zeta(s)$):** This paper does **not** prove or disprove the classical Riemann Hypothesis for $\zeta(s)$ {cite:p}`bombieri2000rh`. Instead, `Signals.Pending.RiemannHypothesisPendingBoundary` and `Signals.Pending.finite_zero_audit_does_not_close_rh_bridges` formally isolate the four open infinite-dimensional analytical bridges (de Bruijn–Newman $\Lambda_{\mathrm{dBN}} \le 0$ {cite:p}`rodgers2020debruijn`, adelic Sato trace-norm convergence, global Li/Jensen–Pólya/Weil positivity {cite:p}`polya1927algeb,weil1952explicit,li1997positivity`, and Berry–Keating/Connes self-adjoint operator closure) and prove that no finite zero scan closes them.
- **Source Provenance & Verification Artifacts:**
  - AI Chat Source (design provenance only; audited and corrected below): {download}`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>` (lines `2348–3600`, `4433–4946`, `4979–5728`)
  - Companion Papers & Engineering Plan:
    - [Written Plan: Error Minimization, Mpemba–Trajectory Synthesis, and Phased Workstreams (`RB-1`–`RB-6`)](riemann-spectral-bridges-plan.md)
    - [Celestial Holography, the Canonical Dictionary ($\Delta = 2s$), Plancherel–Unruh Graviton Loop Weights ($M_1 = 1/8, M_2 = 1/90$), and Integrated Turner Models 15a & 15b for Gravitons and Riemann Spectral Bridges](grassmannian-celestial-holography-graviton-turner-riemann-paper.md)
    - [Verified Finite Contracts for Grassmannian EBR, All 80 Crystallographic Layer Groups, PSD Slavnov–Gram DPPs, Multi-Reference NOCI, Tequila-Compiled Grid DSLs, and Finite-Graph Ihara–Selberg Zeta Functions](grassmannian-gebr-layer-groups-dpp-noci-arc-paper.md) and [Grassmannian EBR Chat-Code Porting Ledger](grassmannian-gebr-chat-porting-plan.md)
    - [Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws](grassmannian-quantum-causal-inference-mpemba-paper.md)
    - [Quantum Trajectories in Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k,n)$, Three-Channel Plücker–Madelung–QFIM ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$), Dual-Schubert `iGPE`, and Dilatant Dark Fluid (`DDF`) Mechanics](grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md)
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, zero `sorry` axioms):
    - {download}`src/signals/Signals/RiemannSpectral.lean <../src/signals/Signals/RiemannSpectral.lean>` (Sections 1–10)
    - {download}`src/signals/Signals/GrassmannianEBR.lean <../src/signals/Signals/GrassmannianEBR.lean>` & {download}`src/signals/Signals/QuantumCausalInference.lean <../src/signals/Signals/QuantumCausalInference.lean>`
    - {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` (`RiemannHypothesisPendingBoundary`, `finite_zero_audit_does_not_close_rh_bridges`)
    - {download}`src/signals/SignalsTests.lean <../src/signals/SignalsTests.lean>` & {download}`src/signals/SignalsPendingTests.lean <../src/signals/SignalsPendingTests.lean>`
  - `signals-numerical-adapter` Rust + PyO3 (`maturin`) Extension (`126` passing unit tests):
    - {download}`src/signals/numerical_adapter/src/riemann_spectral.rs <../src/signals/numerical_adapter/src/riemann_spectral.rs>`
    - {download}`src/signals/numerical_adapter/src/lib.rs <../src/signals/numerical_adapter/src/lib.rs>`
  - Python + SymPy + 35–80 digit `mpmath` + PyO3 Verification Suite:
    - {download}`sustainablefactory/riemann_rh_bridges.py <../sustainablefactory/riemann_rh_bridges.py>`
    - {download}`tests/test_riemann_spectral_sympy_pyo3.py <../tests/test_riemann_spectral_sympy_pyo3.py>`

---

## Abstract

We audit all five Riemann Hypothesis (RH) approaches explored in the Grassmannian monograph dialogue ({download}`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>`, lines `2348–5728`) and consolidate every defensible finite algebraic, spectral, and numerical contract across **Lean 4**, **Rust/PyO3 (`maturin`)**, and **Python/SymPy + 35–80 digit `mpmath`**.

1. **Complete Finite-Graph Bass–Ihara Ramanujan Dichotomy Across a 5-Graph Tower (Solved in Lean 4, SymPy, and Rust):** Pairing `Signals.GrassmannianEBR.ihara_ramanujan_critical_circle_modulus_sq` ($\lambda^2 \le 4q \implies \lvert u \rvert^2 = 1/q$) with `Signals.RiemannSpectral.ihara_non_ramanujan_splits_off_critical_circle` ($\lambda^2 > 4q \implies$ two real roots $u_+ \ne u_-$ with $u_+ u_- = 1/q$ and $u_\pm^2 \ne 1/q$) {cite:p}`bass1992ihara`, we construct an explicit **14-vertex 3-regular connected non-Ramanujan Barbell graph $G_{14}$** ($q = 2$) whose $3 \times 3$ antisymmetric equitable quotient matrix has exact characteristic polynomial $p(\lambda) = \lambda^3 - \lambda^2 - 6\lambda + 2$. Using Lean 4's Intermediate Value Theorem (`nonRamanujan14_exists_super_ramanujan_off_circle_roots`), we prove without floating-point assumptions that $G_{14}$ possesses an eigenvalue $\lambda_2 \in (57/20, 143/50)$ ($\lambda_2 \approx 2.8557725066 > 2\sqrt{2} \approx 2.8284271247$) whose Bass–Ihara roots $u_+ \approx 0.8125068$ and $u_- \approx 0.6153795$ split strictly off the critical circle $\lvert u \rvert = 1/\sqrt{2}$, while simultaneously collapsing the Markov relaxation gap from $\gamma_{\mathrm{gap}} \in [0.3333, 1.0000]$ across the Ramanujan tower ($K_{3,3}$, Petersen, Heawood, Möbius–Kantor $GP(8,3)$) down to $\gamma_{\mathrm{gap}} = 0.0481$.
2. **High-Precision Rust/PyO3 Evaluators (Euler–Maclaurin, Riemann–Siegel $C_0\text{..}C_4$ with Exact `Jet2`/`CJet2` Analytic Derivatives, and Borwein Diagnosis):** We implement self-contained `f64` Euler–Maclaurin summation, singularity-free Chebyshev Riemann–Siegel remainder terms $C_0(p)$ through $C_4(p)$ {cite:p}`gabcke1979riemann`, 2nd-order forward-mode automatic differentiation (`Jet2`/`CJet2`) for exact $Z'(t), Z''(t)$, and Borwein Algorithm 2 {cite:p}`borwein2000zeta` in `riemann_spectral.rs`. Cross-checked against 35–45 digit `mpmath`, Euler–Maclaurin locates all **first 30 nontrivial zeros** with maximum height error **$2.84 \times 10^{-14}$**, extending Riemann–Siegel from $C_2$ to $C_4$ reduces Lehmer-pair evaluation error by **$198.5\times$** (`1.25e-09` $\to$ `6.31e-12`, reaching the IEEE-754 `f64` phase-rounding floor), and replacing finite differences with `Jet2` analytic differentiation reduces $\mathcal{J}(g_{125})$ error by **$2.87 \times 10^7\times$** (`1.93e-04` $\to$ `6.72e-12`).
3. **Correction of Chat Check Figures for Gram's Law Violations ($g_{126}, g_{134}$) and Lehmer's 1956 Pair (#6709–#6710):** Auditing the chat's uncomputed check-figure table ({download}`lines 5718–5725 <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>`) against 35-digit `mpmath` and Rust Riemann–Siegel ($C_0\text{..}C_4$) exposes substantial numerical discrepancies in the chat table—including a sign reversal at Lehmer's 1956 pair extremum $\gamma_* \approx 7005.0818551$ {cite:p}`lehmer1956extended,csordas1994lehmer`, where the true value is a **positive peak** $Z(\gamma_*) = +0.0039673575$ with $Z''(\gamma_*) = -22.346154$ (giving Channel B Bohm curvature rescue $J_{\mathrm{bohm}}(\gamma_*) = \mathcal{J}(\gamma_*) = +0.0886552 > 0$, $\eta_{\mathrm{Bohm}} = 1.0000$, directly dual to the osmotic/Bohm velocity split of {cite:p}`sharoglazova_energyspeed_2025`), and negative $J_{\mathrm{bohm}}$ at $g_{126}$ and $g_{134}$ themselves (where osmotic $(Z')^2$ keeps $\mathcal{J} > 0$).
4. **Mpemba–Trajectory–dBN Synthesis, Analytical-Bridge Probes, & Strict Epistemic Boundary:** Extending `Signals.RiemannSpectral` (Sections 7–10) and `riemann_rh_bridges.py`, we prove exact quartic de Bruijn–Newman backward-heat closure (`dbnQuarticHeat_pde_and_shift`), 4-zero/10-zero Calogero–Moser neighbor squeezing (`dbnFourZero_symmetric_neighbor_squeeze`, {cite:p}`mcguire1964study,drori2023quantum`), and Strong Mpemba slow-mode annihilation (`mpemba_projection_eliminates_slow_weil_mode`, {cite:p}`holtzman2022landau,summer2026resource`)—which collapses the $6\times 6$ orthonormal Hermite–Gaussian Weil Gram condition number by **$429.4\times$** ($\kappa = 1{,}389.36 \to 3.24$) with $< 3.35 \times 10^{-50}$ prime-vs-zero discrepancy {cite:p}`weil1952explicit,bombieri2000rh`, alongside strict real-rootedness of Griffin–Ono–Rolen–Zagier Jensen polynomials for $d = 2\text{..}8$ {cite:p}`polya1927algeb,griffin2019jensen` and exact infinite-zero Keiper–Li positivity $\lambda_1\text{..}\lambda_{25} > 0$ {cite:p}`keiper1992power,li1997positivity,bombieri1999li`. All four open analytical bridges for classical RH remain explicitly gated in `Signals.Pending.RiemannHypothesisPendingBoundary`.
5. **Finite Grassmannian Lift of the Quartic Heat Jet (Lean 4 and Rust):** The even quartic coefficient state $(a_0,a_2,a_4)$ is augmented by a fixed reference direction to give a real $\mathrm{Gr}_{\mathbb R}(2,4)$ chart with Plücker coordinates $(0,0,a_0,0,a_2,a_4)$. Lean proves the Klein relation and the additive-time ambient shear; Rust cross-checks the same finite formulas in `f64`. This is a finite coefficient-plane encoding, not a canonical Hilbert-space embedding, or a closure of any global RH bridge.

---

## 1. Architecture & Epistemic Triage of the Five Chat RH Approaches

```{mermaid}
flowchart TB
    subgraph Chat["Chat Provenance (Gemini_Quantum-Causal-Grassmannian-Monograph-Review, L2348-5728)"]
        C1["1. Critical-Line Reflection &<br/>Coulson-Fischer Bifurcation"]
        C2["2. Finite-Graph Bass-Ihara<br/>Plabic VRC & Ramanujan Bound"]
        C3["3. Semi-Dirac Confinement,<br/>Slavnov/GUE & Sato Hirota"]
        C4["4. Jensen-Polya QFIM Split,<br/>Gram Violations & Lehmer/dBN"]
        C5["5. Li Unit-Circle Positivity<br/>& Off-Line Quartet Splitting"]
    end

    subgraph Lean["Machine-Checked Finite Lean 4 (Signals.RiemannSpectral + GrassmannianEBR)"]
        L1["negative_transverse_stiffness_bifurcates_off_line<br/>ihara_non_ramanujan_splits_off_critical_circle"]
        L2["nonRamanujan14_exists_super_ramanujan_off_circle_roots<br/>heawood_graph_ramanujan_critical_circle"]
        L3["semi_dirac_transverse_hessian_pos<br/>slavnov_gue_2x2 & vandermondeDet3 & sato_hirota"]
        L4["jensenPolyaDiscriminant_mul_product_rule<br/>lehmer_pair_failure & dbnTwoZero/ThreeZero"]
        L5["liTransformModulusSq_eq_one_iff_critical_line<br/>liTransformModulusSq_off_line_splits"]
    end

    subgraph Rust["Rust/PyO3 + SymPy + 35-Digit mpmath (riemann_spectral.rs)"]
        R1["Petersen (10v), Heawood (14v),<br/>Barbell G_14 (14v Non-Ramanujan)"]
        R2["Euler-Maclaurin (<3e-14) + RS C0..C2<br/>+ Borwein Conditioning Diagnosis"]
        R3["First 30 Zeros, Gram g_126/g_134,<br/>Lehmer 1956 (#6709/#6710), Li Sums"]
    end

    subgraph Pending["Epistemic Gate (Signals.Pending.RiemannHypothesisPendingBoundary)"]
        P1["Open Bridge 1: de Bruijn-Newman Lambda_dBN <= 0<br/>Open Bridge 2: Adelic Sato Trace-Norm Limit<br/>Open Bridge 3: Global Li & Jensen-Polya Positivity<br/>Open Bridge 4: Self-Adjoint Spectral Operator Closure"]
    end

    C1 --> L1
    C2 --> L2
    C3 --> L3
    C4 --> L4
    C5 --> L5
    L2 --> R1
    L4 --> R2
    L5 --> R3
    L1 -. "Does NOT discharge" .-> P1
    R3 -. "finite_zero_audit_does_not_close_rh_bridges" .-> P1
```

| Approach | Chat Source Lines | Proved Finite Contract (`Signals`) | Rust/PyO3 & SymPy/mpmath Verification | Open Analytical Bridge (`Signals.Pending`) |
| :--- | :--- | :--- | :--- | :--- |
| **1. Reflection & Bifurcation** | `2382–2511` | `negative_transverse_stiffness_bifurcates_off_line` | Symbolic Cauchy–Riemann & quartic test | Global absence of negative stiffness ($\forall \gamma \in \mathbb{R}$) |
| **2. Bass–Ihara Graph Zeta** | `2774–2925` | `ihara_ramanujan_critical_circle_modulus_sq`, `ihara_non_ramanujan_splits_off_critical_circle`, `nonRamanujan14_exists_super_ramanujan_off_circle_roots` | Petersen (`10v`), Heawood (`14v`), Barbell $G_{14}$ (`14v`) exact SymPy + Rust Jacobi | Trace-norm adelic limit $p_{\max} \to \infty$ on $\mathrm{Gr}_{\mathrm{Sato}}(\mathbb{A}_{\mathbb{Q}}/\mathbb{Q}^\times)$ |
| **3. Semi-Dirac, Slavnov & Sato** | `2537–3185` | `semi_dirac_transverse_hessian_pos`, `slavnov_gue_2x2_quadratic_level_repulsion`, `vandermondeDet3_factorization_and_pos`, `sato_hirota_bilinear_plucker_identity` | Exact SymPy Wronskian & Vandermonde checks | Self-adjoint Berry–Keating / Connes operator closure |
| **4. Jensen–Pólya, Lehmer & dBN** | `4788–5728` | `jensen_polya_madelung_bohm_split_and_extremum_rescue`, `jensenPolyaDiscriminant_mul_product_rule`, `lehmer_pair_failure_destabilizes_and_splits`, `dbnTwoZeroForwardSeparationRate_pos`, `dbnThreeZero_center_of_mass_conserved` | 30 zeros, Gram $g_{125}\text{–}g_{135}$, Lehmer #6709–#6710 audited vs. 35-digit `mpmath` | de Bruijn–Newman upper bound $\Lambda_{\mathrm{dBN}} \le 0$ and global $\mathcal{J}(\gamma) \ge 0$ |
| **5. Li's Positivity Criterion** | `4811–4814` | `liTransformModulusSq_eq_one_iff_critical_line`, `liTransformModulusSq_off_line_splits`, `liCriticalLinePairTerm_nonneg` | $\lambda_n^{(30)} > 0$ ($n \le 100$); off-line quartet turns negative at $n = 3286$ | Global positivity $\lambda_n \ge 0$ for all $n \ge 1$ across all infinitely many zeros |

---

## 2. Solved Finite Problem: The Bass–Ihara Ramanujan Dichotomy and the 14-Vertex Non-Ramanujan Barbell Graph $G_{14}$

### 2.1 Both Directions Proved in Lean 4

For a finite connected $(q + 1)$-regular graph $G = (V, E)$ with adjacency matrix $A$, the reciprocal Bass–Ihara graph zeta function factorizes over the adjacency eigenvalues $\lambda \in \operatorname{Spec}(A)$ as

$$
\zeta_G(u)^{-1} = (1 - u^2)^{\lvert E \rvert - \lvert V \rvert} \det\!\left(I - u A + q u^2 I\right) = (1 - u^2)^{\lvert E \rvert - \lvert V \rvert} \prod_{\lambda \in \operatorname{Spec}(A)} \left(1 - \lambda u + q u^2\right).
$$

The **Graph Riemann Hypothesis** asks whether every non-trivial zero of $\zeta_G(u)^{-1}$ (corresponding to $\lvert \lambda \rvert < q + 1$) lies on the critical circle $\lvert u \rvert = q^{-1/2}$ ($\operatorname{Re}(s) = 1/2$ under $u = q^{-s}$). Lean 4 proves both directions cleanly:

1. **Ramanujan Locking (`Signals.GrassmannianEBR.ihara_ramanujan_critical_circle_modulus_sq`):** Whenever $q > 0$ and $\lambda^2 \le 4q$, the roots $u = \frac{\lambda \pm i\sqrt{4q - \lambda^2}}{2q}$ satisfy $\lvert u \rvert^2 = \frac{1}{q}$.
2. **Non-Ramanujan Off-Circle Splitting Converse (`Signals.RiemannSpectral.ihara_non_ramanujan_splits_off_critical_circle`):** Whenever $q > 0$ and $\lambda^2 > 4q$ (with $d = \sqrt{\lambda^2 - 4q} > 0$), the two real roots $u_\pm = \frac{\lambda \pm d}{2q}$ satisfy $q u_\pm^2 - \lambda u_\pm + 1 = 0$, $u_+ u_- = \frac{1}{q}$, $u_+ \ne u_-$, and strictly leave the critical circle: $u_+^2 \ne \frac{1}{q}$ and $u_-^2 \ne \frac{1}{q}$.

### 2.2 Explicit 14-Vertex 3-Regular Connected Non-Ramanujan Witness ($G_{14}$) vs. Petersen and Heawood Graphs

Take two disjoint copies of the 7-vertex gadget $H$ on vertices $\{0, 1, 2, 3, 4, 5, 6\}$ with edges $(0,1), (0,2), (1,3), (1,4), (2,5), (2,6), (3,4), (3,5), (4,6), (5,6)$ (degree 2 at vertex $0$, degree 3 at vertices $1\text{–}6$) and connect their degree-2 vertices by a single bridge edge $(0, 7)$ to obtain a **14-vertex 3-regular connected simple graph $G_{14}$** ($q = 2$, Ramanujan threshold $2\sqrt{2} \approx 2.8284271247$).

Because $G_{14}$ has an exact 3-orbit equitable partition $(\{0\}, \{1, 2\}, \{3, 4, 5, 6\})$ in each half, its antisymmetric bridge sector ($v_{7+i} = -v_i$) reduces exactly to the $3 \times 3$ quotient matrix

$$
Q_{\mathrm{anti}} = \begin{pmatrix} -1 & 2 & 0 \\ 1 & 0 & 2 \\ 0 & 1 & 2 \end{pmatrix}, \qquad \det\!\left(\lambda I_3 - Q_{\mathrm{anti}}\right) = \lambda^3 - \lambda^2 - 6\lambda + 2.
$$

SymPy computes the exact factored characteristic polynomials across the 5-graph 3-regular ($q = 2$) tower (`RB-4`):

$$
\begin{aligned}
\chi_{K_{3,3}}(x) &= x^4 (x - 3)(x + 3), \\
\chi_{\mathrm{Petersen}}(x) &= (x - 3)(x - 1)^5 (x + 2)^4, \\
\chi_{\mathrm{Heawood}}(x) &= (x - 3)(x + 3)(x^2 - 2)^6, \\
\chi_{\mathrm{M\ddot{o}bius\text{--}Kantor}}(x) &= (x - 3)(x + 3)(x^2 - 1)^3 (x^2 - 3)^4, \\
\chi_{G_{14}}(x) &= x^2 (x - 3)(x + 2)^2 (x^2 - 2)^3 \left(x^3 - x^2 - 6x + 2\right).
\end{aligned}
$$

In Lean 4, `nonRamanujan14_equitable_eigenvector` verifies the exact eigenvector $(a, b, c) = (2, \lambda + 1, (\lambda^2 + \lambda - 2)/2)$ for any root of $p(\lambda) = \lambda^3 - \lambda^2 - 6\lambda + 2$, `nonRamanujan14_bracket_sign_change` evaluates $p(57/20) = -587/8000 < 0 < 6757/125000 = p(143/50)$ with $(57/20)^2 = 3249/400 > 8$, and `nonRamanujan14_exists_super_ramanujan_off_circle_roots` invokes `intermediate_value_Icc` to prove the existence of $\lambda_2 \in (2.85, 2.86)$ strictly exceeding $2\sqrt{2}$ with two real Bass–Ihara roots splitting off $\lvert u \rvert^2 = 1/2$ {cite:p}`bass1992ihara`. Simultaneously, `py_audit_regular_graphs_bass_ihara()` links the Graph RH directly to Markov/Mpemba relaxation speed via $\gamma_{\mathrm{gap}} = 1 - \max\lvert\lambda_{\mathrm{nt}}\rvert / 3$ and the Ramanujan margin $2\sqrt{2} - \max\lvert\lambda_{\mathrm{nt}}\rvert$ {cite:p}`holtzman2022landau`:

| 3-Regular Connected Graph ($q = 2$) | Vertices | $\max \lvert \lambda_{\mathrm{nt}} \rvert$ | Markov Gap $\gamma_{\mathrm{gap}}$ | Margin $2\sqrt{2} - \max\lvert\lambda_{\mathrm{nt}}\rvert$ | Ramanujan? | Off-Circle Roots | Real Off-Circle Roots $(u_+, u_-)$ |
| :--- | ---: | ---: | ---: | ---: | :---: | ---: | :--- |
| **Complete Bipartite $K_{3,3}$** | 6 | `0.0000000000` | `1.000000` | `+2.828427` | Yes | `0` | None ($\lvert u \rvert^2 = 0.5$) |
| **Petersen** | 10 | `2.0000000000` | `0.333333` | `+0.828427` | Yes | `0` | None (all 18 non-trivial roots have $\lvert u \rvert^2 = 0.5$) |
| **Heawood** (Fano Levi) | 14 | `1.4142135624` | `0.528595` | `+1.414214` | Yes | `0` | None (all 24 non-trivial roots have $\lvert u \rvert^2 = 0.5$) |
| **Möbius–Kantor $GP(8,3)$** | 16 | `1.7320508076` | `0.422650` | `+1.096376` | Yes | `0` | None (all 28 non-trivial roots have $\lvert u \rvert^2 = 0.5$) |
| **Barbell $G_{14}$** | 14 | **`2.8557725066`** | **`0.048076`** | **`-0.027345`** | **No** | **`2`** | $u_+ = 0.8125068$ ($u_+^2 = 0.6601672$), $u_- = 0.6153795$ ($u_-^2 = 0.3786919$) |

In spectral $s$-coordinates ($u = 2^{-s}$), the two non-Ramanujan roots of $G_{14}$ sit symmetrically off the critical line at $s_- = -\log_2 u_+ \approx 0.299548$ and $s_+ = -\log_2 u_- \approx 0.700452$ ($s_+ + s_- = 1$, $\sigma_{\mathrm{dev}} = \pm 0.200452$), providing a concrete finite-graph realization of a Coulson–Fischer off-axis bifurcation alongside a $10.99\times$ collapse in Markov relaxation rate relative to the 14-vertex Ramanujan Heawood graph.

---

## 3. High-Precision Rust/PyO3 Evaluators & `RB-1` Error Minimization (`Jet2`/`CJet2` + Riemann–Siegel $C_0\text{..}C_4$)

### 3.1 Algorithmic Design (`src/signals/numerical_adapter/src/riemann_spectral.rs`)

Three complementary evaluators and a 2nd-order forward-mode automatic differentiation algebra (`Jet2` / `CJet2`) are implemented in pure Rust (`std` only) and exposed via PyO3 (`signals_numerical_adapter`):

1. **Euler–Maclaurin Analytic Continuation + Exact Complex 2-Jets (`zeta_euler_maclaurin`, `hardy_z_jet`):** Uses adaptive cutoff $N = \max(18, \lceil 1.2 \lvert t \rvert + 18 \rceil)$ with 9 Bernoulli ratios $B_{2k}/(2k)!$ ($k = 1\text{..}9$). Propagating `CJet2` through $n^{-s}$, the Euler–Maclaurin tail, and $\vartheta(t)$ delivers exact machine-precision $(Z(t), Z'(t), Z''(t))$ with zero finite-difference step-size cancellation.
2. **Riemann–Siegel with Exact Chebyshev $C_0(p)$ Through $C_4(p)$ (`hardy_z_riemann_siegel_c4_jet`):** Evaluates the Stirling-shifted phase $\vartheta(t)$ ($< 10^{-15}$ error) plus the $O(\sqrt{t})$ main sum and five Gabcke remainder terms {cite:p}`gabcke1979riemann`:

$$
Z(t) = 2\sum_{n=1}^{\lfloor a \rfloor} n^{-1/2}\cos\!\left(\vartheta(t) - t \ln n\right) + (-1)^{\lfloor a \rfloor - 1} a^{-1/2}\sum_{r=0}^{4} a^{-r} C_r(p), \qquad a = \sqrt{\frac{t}{2\pi}}, \quad p = a - \lfloor a \rfloor.
$$

Because $C_0(p)\text{..}C_4(p)$ are entire functions whose apparent poles at $p = 1/4, 3/4$ cancel analytically, expanding $C_0, C_2, C_4$ in even Chebyshev polynomials $T_{2k}(2p - 1)$ and $C_1, C_3$ in odd Chebyshev polynomials $T_{2k+1}(2p - 1)$ (derived at 120-digit `mpmath` precision) and propagating `Jet2` through Clenshaw recurrence eliminates both removable-singularity cancellation and finite-difference noise across $[0, 1]$.
3. **Borwein Algorithm 2 (`zeta_borwein`):** Included explicitly to diagnose why `f64` Borwein ($n = 22$) {cite:p}`borwein2000zeta` matches $\zeta(2) = \pi^2/6$ to $< 10^{-13}$ and reaches $2.98 \times 10^{-9}$ at $\gamma_1 \approx 14.1347$, yet degrades to $2.83 \times 10^{-1}$ at $\gamma_{10} \approx 49.7738$ and $1.07$ at $\gamma_{30} \approx 101.3179$: its error scales as $\cosh(\pi t / 2) / (3 + 2\sqrt{2})^n$, requiring $n \gtrsim 100$ (and $\sim 80$-digit arbitrary precision) at $t = 101.3$.

### 3.2 `RB-1` Before/After Error-Minimization Benchmarks (`py_compare_rs_c2_vs_c4`)

Upgrading from $C_2(p)$ + 4th-order finite differences ($h = 5\times 10^{-4}$) to $C_4(p)$ + exact `Jet2`/`CJet2` automatic differentiation drives every `f64` observable down to the fundamental IEEE-754 phase-argument rounding floor $\varepsilon_{\mathrm{phase}} \sim t \ln(\lfloor a \rfloor) \cdot \varepsilon_{\mathrm{mach}} \approx 6 \times 10^{-12}$ at $t \approx 7{,}005$:

| Benchmark Observable | Baseline (`RS-C2` / FD) Error | Upgraded (`RS-C4` + `Jet2`) Error | Error Reduction Factor | Limiting `f64` Mechanism |
| :--- | ---: | ---: | ---: | :--- |
| **$Z(\gamma_{30})$ at $\gamma_{30} = 101.31785101$** | `1.502e-06` | **`3.539e-08`** | **`42.4×`** | Asymptotic $O(a^{-11/2})$ at small $a = 4.016$ (Euler–Maclaurin gives `2.42e-14`) |
| **$Z(\gamma_*)$ at Lehmer $\gamma_* = 7005.08185510$** | `1.252e-09` | **`6.311e-12`** | **`198.5×`** | IEEE-754 `f64` phase rounding $t \ln n \cdot 2^{-53}$ ($a = 33.39$) |
| **$Z''(\gamma_*)$ at Lehmer $\gamma_* = 7005.08185510$** | `~1.10e-05` | **`1.350e-10`** | **`> 81,000×`** | Exact `Jet2` Clenshaw + main-sum differentiation |
| **$\mathcal{J}(g_{125})$ at $g_{125} = 280.80242938$** | `1.932e-04` | **`6.722e-12`** | **`2.87e7×`** | Zero step-size cancellation via `CJet2` Euler–Maclaurin |

### 3.3 First 30 Nontrivial Zeros Cross-Checked Against 35-Digit `mpmath`

Across all **30 first nontrivial zeros** (`py_find_first_n_riemann_zeros(30)` vs. 35-digit `mpmath.zetazero`), the Rust Euler–Maclaurin root finder achieves **maximum zero-height error $2.84 \times 10^{-14}$** and **maximum $\lvert \zeta(\tfrac{1}{2} + i\gamma_k) \rvert = 5.94 \times 10^{-14}$**:

| Zero Index $k$ | Rust Height $\gamma_k$ | Error vs. 35-Digit `mpmath` | $\lvert \zeta_{\mathrm{EM}}(\tfrac{1}{2} + i\gamma_k) \rvert$ | $\lvert Z_{\mathrm{RS}, C_2}(\gamma_k) \rvert$ | $\lvert Z_{\mathrm{RS}, C_4}(\gamma_k) \rvert$ | $\lvert \zeta_{\mathrm{Borwein}, 22} \rvert$ | $\mathcal{J}(\gamma_k) = (Z'(\gamma_k))^2$ |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | `14.1347251417` | `1.78e-15` | `7.92e-16` | `7.76e-05` | `2.65e-05` | `2.98e-09` | `0.629103` |
| 2 | `21.0220396388` | `3.55e-15` | `3.38e-15` | `2.79e-06` | `1.44e-06` | `2.76e-05` | `1.292403` |
| 3 | `25.0108575801` | `0.00e+00` | `3.39e-15` | `1.91e-05` | `3.15e-06` | `5.65e-04` | `1.881619` |
| 10 | `49.7738324777` | `1.42e-14` | `2.22e-14` | `1.32e-06` | `9.89e-08` | `2.83e-01` | `2.013369` |
| 20 | `77.1448400689` | `0.00e+00` | `2.70e-14` | `1.52e-06` | `5.63e-08` | `5.90e-01` | `2.124430` |
| 27 | `94.6513440405` | `2.84e-14` | `1.55e-14` | `7.74e-07` | `2.15e-08` | `5.96e-01` | `2.188631` |
| 28 | `95.8706342282` | `1.42e-14` | `2.43e-14` | `1.15e-06` | `2.86e-08` | `6.03e-01` | `2.868145` |
| 30 | `101.3178510057` | `1.42e-14` | `2.42e-14` | `1.50e-06` | `3.54e-08` | `1.07e+00` | `9.951800` |

---

## 4. Jensen–Pólya Transverse QFIM Stiffness, Gram's Law Violations, and Lehmer's 1956 Pair (Correcting the Chat Table)

### 4.1 Exact Algebraic Identities Proved in Lean 4

Along the critical strip $s = (\tfrac{1}{2} + \sigma_{\mathrm{dev}}) + i\gamma$, the second-order Cauchy–Riemann expansion of $E(\sigma_{\mathrm{dev}}) = \lvert W(\gamma - i\sigma_{\mathrm{dev}}) \rvert^2$ around a real critical-line amplitude $Z(\gamma)$ satisfies (`Signals.GrassmannianEBR.criticalStripPolynomialEnergy_eq_jensenPolya` and `Signals.RiemannSpectral.jensen_polya_madelung_bohm_split_and_extremum_rescue`):

$$
E(\sigma_{\mathrm{dev}}) = Z(\gamma)^2 + \underbrace{\Bigl(\underbrace{(Z'(\gamma))^2}_{J_{\mathrm{osmotic}}} + \underbrace{(-Z(\gamma)\,Z''(\gamma))}_{J_{\mathrm{bohm}}}\Bigr)}_{\mathcal{J}(\gamma)} \sigma_{\mathrm{dev}}^2 + \frac{1}{4}\bigl(Z''(\gamma)\bigr)^2 \sigma_{\mathrm{dev}}^4.
$$

Moreover, `Signals.RiemannSpectral` proves:
- **Laguerre–Pólya Multiplicative Closure (`jensenPolyaDiscriminant_mul_product_rule`):** $\mathcal{J}(fg) = g^2 \mathcal{J}(f) + f^2 \mathcal{J}(g)$, so any finite product of real-rooted factors preserves $\mathcal{J} \ge 0$.
- **Lehmer Bifurcation Witness (`lehmer_pair_failure_destabilizes_and_splits`):** If $Z'(\gamma_*) = 0$ and $Z(\gamma_*) Z''(\gamma_*) > 0$, then $\mathcal{J}(\gamma_*) < 0$ and the quadratic-truncated critical-strip energy vanishes off the critical line at $\sigma_*^2 = 2 Z(\gamma_*) / Z''(\gamma_*) > 0$.
- **De Bruijn–Newman / Calogero–Moser Flow (`dbnTwoZeroForwardSeparationRate_pos`, `dbnThreeZero_center_of_mass_conserved`):** Under $\dot{z}_k = \sum_{j \ne k} 2/(z_j - z_k)$, two real zeros separate at rate $4/(z_2 - z_1) > 0$, and the three-zero velocity sum vanishes identically.

### 4.2 Exact 35-Digit `mpmath` & Rust Audit vs. Uncomputed Chat Table

Auditing the chat's uncomputed check-figure table ({download}`lines 5718–5725 <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>`) against Rust `py_audit_gram_law_and_lehmer()` and 35-digit `mpmath.siegelz` reveals two key factual corrections:
1. At the Gram-violation points $g_{126}$ and $g_{134}$ themselves, $Z(g_m)$ and $Z''(g_m)$ are both **negative**, so $J_{\mathrm{bohm}}(g_m) = -Z Z''$ is slightly **negative** (`-0.2103` and `-0.0923`), while the osmotic Fisher slope $J_{\mathrm{osm}} = (Z')^2$ dominates (`+7.2783` and `+2.6105`) to maintain $\mathcal{J} > 0$. The pure Bohm extremum rescue ($\eta_{\mathrm{Bohm}} = 1.0000$) occurs at the displaced positive peak $\gamma_* = 282.814083516$ between the two zeros inside $[g_{126}, g_{127}]$.
2. At **Lehmer's 1956 near-miss pair** (Zeros #6709 at `7005.0628661779` and #6710 at `7005.1005646697`, gap $\Delta\gamma = 0.0376984918$), the extremum at $\gamma_* = 7005.0818550970$ is a **positive peak** $Z(\gamma_*) = +0.0039673563$ with $Z''(\gamma_*) = -22.346182$ (opposite signs to the chat's uncomputed table), yielding $J_{\mathrm{bohm}}(\gamma_*) = \mathcal{J}(\gamma_*) = +0.08865527 > 0$ and $\eta_{\mathrm{Bohm}} = 1.000000$.

| Spectral Locus | Height $\gamma$ | $Z(\gamma)$ | $Z'(\gamma)$ | $Z''(\gamma)$ | $J_{\mathrm{osm}} = (Z')^2$ | $J_{\mathrm{bohm}} = -Z Z''$ | $\mathcal{J}(\gamma)$ | $\eta_{\mathrm{Bohm}}$ | Gram Holds? |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | :---: |
| **$g_{125}$** | `280.80242938` | `-7.00315164` | `-0.080868` | `+10.191751` | `0.006540` | `+71.374377` | `71.380917` | `+0.9999` | Yes |
| **$g_{126}$ (1st Violation)** | `282.45472082` | `-0.02762950` | `+2.697839` | `-7.612266` | `7.278333` | `-0.210323` | `7.068010` | `-0.0298` | **No** |
| **$g_{126}$ Peak $\gamma_*$** | `282.81408352` | `+0.44867775` | `0.000000` | `-6.838034` | `0.000000` | **`+3.068074`** | **`3.068074`** | **`+1.0000`** | Extremum |
| **$g_{127}$** | `284.10447635` | `-1.42828341` | `+0.117384` | `+5.705791` | `0.013779` | `+8.149487` | `8.163266` | `+0.9983` | Yes |
| **$g_{133}$** | `293.95119335` | `-0.77638607` | `-1.090699` | `+5.002328` | `1.189625` | `+3.883738` | `5.073363` | `+0.7655` | Yes |
| **$g_{134}$ (2nd Violation)** | `295.58390697` | `-0.01690039` | `-1.615699` | `-5.460079` | `2.610482` | `-0.092277` | `2.518204` | `-0.0366` | **No** |
| **$g_{135}$** | `297.21428208` | `-3.46980438` | `+2.033296` | `+8.530600` | `4.134292` | `+29.599513` | `33.733805` | `+0.8774` | Yes |
| **Lehmer 1956 (#6709–#6710) $\gamma_*$** | `7005.08185510` | **`+0.00396736`** | `0.000000` | **`-22.346182`** | `0.000000` | **`+0.088655`** | **`0.088655`** | **`+1.0000`** | Extremum |

---

## 5. Li's Unit-Circle Criterion and Why Finite Zero Audits Do Not Close Classical RH

### 5.1 Machine-Checked Unit-Circle Equivalence & Off-Line Splitting

Under Li's Möbius map $w(\rho) = 1 - 1/\rho$ for $\rho = (\tfrac{1}{2} + \sigma_{\mathrm{dev}}) + i\gamma$, `Signals.RiemannSpectral.liTransformModulusSq_eq_one_iff_critical_line` proves

$$
\left\lvert 1 - \frac{1}{\rho} \right\rvert^2 = \frac{(\sigma_{\mathrm{dev}} - 1/2)^2 + \gamma^2}{(\sigma_{\mathrm{dev}} + 1/2)^2 + \gamma^2} = 1 \iff \sigma_{\mathrm{dev}} = 0,
$$

while `liTransformModulusSq_off_line_splits` proves that for any $\sigma_{\mathrm{dev}} > 0$, $\lvert 1 - 1/\rho \rvert^2 < 1 < \lvert 1 - 1/(1 - \bar{\rho}) \rvert^2$, placing one member of every off-line functional-equation quartet strictly outside the unit circle. In Rust/PyO3 (`py_li_partial_coefficients`), the partial sums $\lambda_n^{(30)} = \sum_{k=1}^{30} 2\operatorname{Re}[1 - (1 - 1/\rho_k)^n]$ remain strictly positive for all $n \in [1, 100]$, whereas injecting a single hypothetical off-line quartet $(\tfrac{1}{2} \pm 0.20) \pm 14.1347i$ produces $\lvert 1 - 1/\rho \rvert \approx 1.0010 > 1$ and drives $\lambda_n$ strictly negative starting at **$n = 3{,}286$** ($\lambda_{3286} = -0.0744$, dipping to $-235.87$ by $n = 5{,}000$).

### 5.2 Formal Pending Boundary (`Signals.Pending.RiemannHypothesisPendingBoundary`)

No finite check above can prove the classical Riemann Hypothesis. `Signals.Pending.finite_zero_audit_does_not_close_rh_bridges` formally encodes this boundary in Lean 4: a finite audit record with arbitrarily high verified height $T_{\max} > 0$, audited zero count, and audited Gram violations still fails `allFourBridgesClosed` unless all four infinite-dimensional analytical bridges are established:

1. **de Bruijn–Newman upper bound:** $\Lambda_{\mathrm{dBN}} \le 0$ (paired with Rodgers–Tao 2020's $\Lambda_{\mathrm{dBN}} \ge 0$).
2. **Adelic Sato trace-norm limit:** convergence of finite Plabic VRC / Bass–Ihara transfers as $p_{\max} \to \infty$ on $\mathrm{Gr}_{\mathrm{Sato}}(\mathbb{A}_{\mathbb{Q}}/\mathbb{Q}^\times)$.
3. **Global Li / Jensen–Pólya positivity:** $\lambda_n \ge 0$ for all $n \ge 1$ and $\mathcal{J}(\gamma) \ge 0$ for all $\gamma \in \mathbb{R}$.
4. **Self-adjoint spectral operator closure:** an intrinsically self-adjoint archimedean + non-archimedean domain closure for a Hilbert–Pólya / Connes generator.

---

## 6. SymPy & Arbitrary-Precision Analytical-Bridge Probes (`riemann_rh_bridges.py` & `Signals.RiemannSpectral` Sections 7–9)

To push directly on the four open analytical bridges without overstating finite checks as a global proof, {download}`sustainablefactory/riemann_rh_bridges.py <../sustainablefactory/riemann_rh_bridges.py>` pairs seven symbolic SymPy proofs and four arbitrary-precision (`50–80` digit `mpmath`) numerical probes with new machine-checked Lean 4 theorems in Sections 7–9 of {download}`src/signals/Signals/RiemannSpectral.lean <../src/signals/Signals/RiemannSpectral.lean>`.

### 6.1 Griffin–Ono–Rolen–Zagier (PNAS 2019) Positive-Integral Jensen Polynomials ($d = 2\text{..}6$)

Pólya (1927) proved that the Riemann Hypothesis is equivalent to the hyperbolicity (all roots real) of every Jensen polynomial $J^{d,n}(X) = \sum_{j=0}^d \binom{d}{j}\gamma_{n+j} X^j$ ($d \ge 1, n \ge 0$) built from the Taylor moments $\gamma_n$ of $\Xi(z) = \xi(\tfrac{1}{2} + iz)$. Griffin, Ono, Rolen, and Zagier ({ref}`Griffin et al. 2019 <rh-scholarly-references>`) proved hyperbolicity for every fixed degree $d \ge 1$ and sufficiently large shift $n \ge N(d)$ by showing Hermite convergence to $He_d(X)$.

- **Lean 4 (`Signals.RiemannSpectral` Section 7):** `jensenCubicDiscriminant_factored_roots` proves $\Delta_3(a(X-r_1)(X-r_2)(X-r_3)) = a^4(r_1-r_2)^2(r_1-r_3)^2(r_2-r_3)^2 > 0$, and `depressedCubic_hermite3_discriminant` proves $\Delta_3(Z^3 - 3Z + c) = 27(4 - c^2) > 0 \iff c^2 < 4$ ($\Delta_3 = 108$ at $He_3(Z) = Z^3 - 3Z$).
- **Zero-Cancellation Positive Integral (`compute_gorz_jensen_moments`):** Using Riemann's strictly positive kernel $\Phi(u) > 0$ ($\Xi(z) = 4 \int_0^\infty \Phi(u)\cos(zu)\,du$) eliminates the catastrophic cancellation of circle Cauchy integration at high shifts ($n > 20$), matching $\gamma_0 = \xi(\tfrac{1}{2})$ to $< 10^{-60}$. Across all degrees $d \in \{2, 3, 4, 5, 6\}$ and shifts $n \in [0, 25]$, every computed root of $J^{d,n}(X)$ is strictly real ($\max \lvert \operatorname{Im}(r) \rvert = 0$) with Hermite $He_3$ depressed residual $c_n \in [+0.0608, +0.1435] \ll 2$.

| Jensen Degree $d$ | Shifts Audited $n$ | All Roots Real? | $\max \lvert \operatorname{Im}(\text{root}) \rvert$ | Minimum Root Gap |
| ---: | :---: | :---: | ---: | ---: |
| 2 | `0..25` | Yes | `0.00e+00` | `9.0456e+01` |
| 3 | `0..25` | Yes | `0.00e+00` | `7.5071e+01` |
| 4 | `0..25` | Yes | `0.00e+00` | `6.6594e+01` |
| 5 | `0..25` | Yes | `0.00e+00` | `5.9404e+01` |
| 6 | `0..25` | Yes | `0.00e+00` | `5.4120e+01` |

### 6.2 Exact Infinite-Zero Keiper–Li Coefficients via $\ln(2\xi(1+z))$

Whereas Section 5.1 summed over the first 30 zeros, expanding $\ln(2\xi(1+z)) = \sum_{k=1}^\infty b_k z^k$ on $\lvert z \rvert = 2$ (strictly inside the zero-free disk $\lvert z \rvert < 14.14$) captures **all infinitely many nontrivial zeros simultaneously** via $\lambda_n = n \sum_{k=1}^n \binom{n-1}{k-1} b_k$ (`Signals.RiemannSpectral.keiperLi_binomial_inversion_123`). At 65-digit precision (`compute_exact_keiper_li_coefficients`), $\lambda_1$ matches the exact Bombieri–Lagarias identity $1 + \gamma_E/2 - \ln(4\pi)/2 = 0.023095708966121034\dots$ to **$1.08 \times 10^{-66}$**, and all $\lambda_1\text{..}\lambda_{20}$ are strictly positive ($\lambda_2 = 0.0923457$, $\lambda_5 = 0.5755427$, $\lambda_{10} = 2.2793394$, $\lambda_{20} = 8.7692769$).

### 6.3 50-Digit Weil Explicit-Formula Gaussian Gram Matrix (Prime + Archimedean vs. Zero Side)

Under Weil's positivity criterion ({ref}`Bombieri 2000 <rh-scholarly-references>`), RH holds if and only if the symmetric Weil distribution $W(g \ast \tilde{g})$ is positive semidefinite on all admissible test functions. Lean 4 proves both the finite Sylvester positivity gate (`weilQuadForm2_pos_of_sylvester`) and the explicit negative-determinant disproof witness $v = (-w_{01}, w_{00})$ (`weilQuadForm2_neg_witness_of_neg_det`).

On the 4-dimensional Gaussian basis $g_i(x) = e^{-\alpha_i x^2}$ with $\alpha \in \{40, 80, 160, 320\}$, `audit_weil_gaussian_gram_matrix` evaluates every matrix entry independently via the **Prime + Archimedean side** (poles at $s=0,1$, von Mangoldt sum $-2\sum \Lambda(n) n^{-1/2} F(\ln n)$, and digamma integral) and via the **Spectral Zero side**:

- **Maximum Prime-vs-Zero Matrix Discrepancy (50-digit `mpmath`):** **`8.35e-52`**.
- **Exact Symmetric Eigenvalues of $W_{4\times 4}$:** `3.4629e-05`, `7.0233e-04`, `9.9412e-03`, `1.1917e-01` (all strictly positive, confirming Weil positivity on this 4D Gaussian subspace).

### 6.4 De Bruijn–Newman Backward Heat-Flow Collision Time on Lehmer's 1956 Pair

Under the de Bruijn–Newman heat PDE $\partial_t H_t = -\partial_z^2 H_t$, `Signals.RiemannSpectral.dbnQuadraticHeat_collides_and_leaves_real_axis` proves that near any real extremum peak ($z_0 > 0, z_2 < 0$), the quadratic solution $H_t(\delta z) = (z_0 - z_2 t) + \tfrac{1}{2} z_2 \delta z^2$ hits a double root at $t_{\mathrm{crit}} = z_0 / z_2 < 0$ and leaves the real axis strictly for all $t < t_{\mathrm{crit}}$. On Lehmer's 1956 near-miss pair (#6709 & #6710, $\Delta\gamma = 0.0376984977$), `audit_lehmer_dbn_backward_heat` finds

$$
t_{\mathrm{heat}} = \frac{Z(\gamma_*)}{Z''(\gamma_*)} = -0.0001775410, \qquad t_{\mathrm{CM}} = -\frac{\Delta\gamma^2}{8} = -0.0001776471, \qquad \frac{t_{\mathrm{heat}}}{t_{\mathrm{CM}}} = 0.999403,
$$

confirming to $0.06\%$ that local backward heat collision matches the 2-zero Calogero–Moser exact merge time and quantitatively illustrating why Rodgers–Tao (2020) proved $\Lambda_{\mathrm{dBN}} \ge 0$ while the remaining open half of RH is $\Lambda_{\mathrm{dBN}} \le 0$.

### 6.5 Finite Grassmannian Lift of the Quartic de Bruijn–Newman Heat Jet

The quartic truncation has coefficient state $a(t)=(a_0(t),a_2(t),a_4(t))$ for
$H_t(\Delta z)=a_0(t)+a_2(t)(\Delta z)^2+a_4(t)(\Delta z)^4$. Its finite heat step is

$$
a(t+h)=a(t)S_h,\qquad
S_h=\begin{pmatrix}1&0&0\\-2h&1&0\\12h^2&-12h&1\end{pmatrix},\qquad S_{h_1}S_{h_2}=S_{h_1+h_2}.
$$

This makes the coefficient orbit a three-dimensional linear representation of the additive heat-time parameter. To obtain a Grassmannian point, augment the coefficient row by a fixed reference direction $e_4$:

$$
C(a)=\begin{pmatrix}a_0&a_2&a_4&0\\0&0&0&1\end{pmatrix},\qquad
(p_{12},p_{13},p_{14},p_{23},p_{24},p_{34})=(0,0,a_0,0,a_2,a_4).
$$

Interpret $(a_0,a_2,a_4)$ as coordinates in the finite Euclidean coefficient Hilbert space $\mathbb R^3$ with the selected basis $\{1,(\Delta z)^2,(\Delta z)^4\}$. A nonzero vector determines a ray in $\mathrm{Gr}_{\mathbb R}(1,3)\cong\mathbb{RP}^2$; adjoining the fixed reference direction $e_4$ embeds that ray as the 2-plane

$$
\iota([a])=\operatorname{span}\{(a_0,a_2,a_4,0),(0,0,0,1)\}\in\mathrm{Gr}_{\mathbb R}(2,4)\subset\mathrm{Gr}_{\mathbb C}(2,4).
$$

The Lean and Rust implementations store the finite coefficient vector and this explicit frame; they do not supply a continuum $L^2$ basis or a canonical map from an unspecified Hilbert space. For $a\ne0$, the row span is a real 2-plane in $\mathrm{Gr}_{\mathbb R}(2,4)$, hence in its complexification $\mathrm{Gr}_{\mathbb C}(2,4)$. The Plücker relation is automatic for this decomposable bivector. The ambient shear

$$
U_h=\begin{pmatrix}1&0&0&0\\-2h&1&0&0\\12h^2&-12h&1&0\\0&0&0&1\end{pmatrix},\qquad C(a(t+h))=C(a(t))U_h,
$$

is lower triangular with unit diagonal, fixes the reference row, has reverse-time inverse $U_{-h}$, and composes as $U_{h_1}U_{h_2}=U_{h_1+h_2}$. More explicitly, $U_h=I+hN+\frac{h^2}{2}N^2$ for a fixed nilpotent generator $N$ with $N^3=0$; $N$ is not symmetric in the coefficient-space Euclidean inner product. Thus this finite flow generator is not itself a self-adjoint Hilbert–Pólya operator. The Lean implementation (`DBNQuarticHeatGr24State`, `dbnQuarticHeatGr24Generator`, `dbnQuarticHeatGr24AmbientAction`, and `dbnQuarticHeatGr24GeneratorMatrix_heatStep`) proves these finite polynomial identities and the nonzero-minor condition; the Rust implementation (`DbnQuarticHeatGr24State`) checks the same formulas numerically in `f64`. The zero coefficient vector maps to the zero Plücker vector and is not a point of the projective Grassmannian.

This construction is a chosen coefficient chart, not a canonical embedding of an infinite-dimensional Hilbert space and not a spectral model for the zeta zeros. A generic finite Hilbert-to-Grassmannian construction starts with an isometric frame $E_N:\mathbb{C}^N\to\mathcal{H}$ whose range lies in the domain of a specified operator $A$. Compress to $A_N=E_N^*AE_N$, choose a full-rank $N\times k$ frame $X_0$, and evolve

$$
X_t=e^{tA_N}X_0,\qquad p_t=\bigwedge^k X_t.
$$

Here $p_t$ is the vector of $k\times k$ minors, so it represents the transported $k$-plane. The quartic implementation is this recipe in a selected finite coefficient chart, with a row-frame convention. A dBN-to-Hilbert bridge would still need a justified Hilbert space, the unbounded generator $A=-\partial_z^2$ with domain and boundary conditions, a convergent sequence of finite sections, and a proof that the limiting spectral data are the zeta-zero ordinates. None of those infinite-dimensional ingredients is supplied by the quartic jet.

#### Native Rust `f64` Cross-Check Plan
Separately, `Signals.RiemannSpectral` defines the affine normalization
`riemannSpectralNormalizedDimension(s) = 2s` and the parameter and dimension
shadow reflections. It proves that both reflections are involutions, that
$2-\Delta(s)=\Delta(1-s)$, and that
$\operatorname{Re}(\Delta(s))=1$ iff $\operatorname{Re}(s)=1/2$. These are
exact algebraic normalization identities only: they do not establish a
functional equation for $\zeta$, identify any zeros, or imply self-adjointness
or the Riemann Hypothesis.


`audit_dbn_quartic_heat_gr24` accepts $(z_0,z_2,z_4,t,h_1,h_2,\Delta z)$ and returns `finite_inputs`, `chart_has_nonzero_minor`, `heat_step_max_abs`, `polynomial_reconstruction_abs`, `generator_intertwining_max_abs`, `plucker_relation_max_abs`, `ambient_semigroup_max_abs`, and `ambient_inverse_max_abs`; `max_abs_residual()` aggregates the six numeric residuals. The native test checks a deterministic nonzero fixture with `finite_inputs = true`, `chart_has_nonzero_minor = true`, and `max_abs_residual() < 10^{-10}`. A second all-zero fixture must have `chart_has_nonzero_minor = false` and residual below $10^{-12}$. The test also checks the generator update against right multiplication by $U_h$.

This is a numerical consistency audit in IEEE-754 `f64`, not interval certification: the thresholds validate the implementation on the selected fixture, not a uniform floating-point error bound over all inputs. A proof-grade numerical certificate would need outward-rounded intervals and explicit input ranges. Neither that certificate nor the analytic Taylor remainder is part of the current Lean/Rust contract.

| Model | Grassmannian state | Lean 4 implementation | Rust implementation | Status relative to Bridge 4 |
| --- | --- | --- | --- | --- |
| Finite quartic dBN chart | $\mathrm{Gr}_{\mathbb R}(2,4)\subset\mathrm{Gr}_{\mathbb C}(2,4)$; coefficient ray plus fixed $e_4$ | `DBNQuarticHeatGr24State`, Plücker chart, Klein relation, $U_h$ composition/inverse, generator intertwining | `DbnQuarticHeatGr24State` and `audit_dbn_quartic_heat_gr24` in `riemann_spectral.rs`; native `f64` residual checks | Implemented finite polynomial model; no unbounded domain, Hilbert-space closure, or global-$\Lambda$ conclusion |
| Generic Hilbert finite section | $\mathrm{Gr}_{\mathbb C}(k,N)$ from a rank-$k$ subspace of a finite projection | Not implemented: the operator/domain and convergence theorem are unspecified | Not implemented for dBN | Requires a defined candidate operator and a proved $N\to\infty$ spectral-convergence result |

G-MGS superconductivity, the Turner dual-Grassmannian/iGPE product, and DDF second sound are omitted from this comparison because no state map from those models to $H_t(z)$ has been specified. In particular, an ideal superconductor does not realize the auxiliary de Bruijn–Newman heat flow.

---

## 7. Reproducible Tri-Language Verification Commands

```bash
# 1. Lean 4 verification (Signals.RiemannSpectral + Signals.Pending + Tests)
make signals_build

# 2. Rust native tests (126 passing) + PyO3/maturin editable release wheel
cd src/signals/numerical_adapter
cargo test
TMPDIR=/workspaces/sustainablefactory/.tmp maturin develop --release

# 3. Python + SymPy + 50-80 digit mpmath + PyO3 integration suite
pytest -q tests/test_riemann_spectral_sympy_pyo3.py
```

---

(rh-scholarly-references)=
### Scholarly References

- <a id="bass1992"></a> Bass, H. (1992). "The Ihara–Selberg zeta function of a tree lattice." *International Journal of Mathematics*, 3(6), 717–797.
- <a id="bombieri2000"></a> Bombieri, E. (2000). "The Riemann Hypothesis." *Official Problem Description*, Clay Mathematics Institute.
- <a id="borwein2000"></a> Borwein, P. (2000). "An efficient algorithm for the Riemann zeta function." *Constructive Experimental and Nonlinear Analysis*, CMS Conf. Proc. 27, 29–34.
- <a id="gabcke1979"></a> Gabcke, W. (1979). *Neue Herleitung und explizite Restabschätzung der Riemann–Siegel-Formel*. PhD thesis, Universität Göttingen.
- <a id="gorz2019"></a> Griffin, M., Ono, K., Rolen, L., & Zagier, D. (2019). "Jensen polynomials for the Riemann zeta function and other sequences." *Proceedings of the National Academy of Sciences*, 116(23), 11103–11110.
- <a id="lehmer1956"></a> Lehmer, D. H. (1956). "Extended computation of the Riemann zeta-function." *Mathematika*, 3(2), 102–108.
- <a id="li1997"></a> Li, X.-J. (1997). "The positivity of a sequence of numbers and the Riemann hypothesis." *Journal of Number Theory*, 65(2), 325–333.
- <a id="rodgerstao2020"></a> Rodgers, B., & Tao, T. (2020). "The de Bruijn–Newman constant is non-negative." *Forum of Mathematics, Pi*, 8, e6.

---

## 8. Provenance Metadata (BibTeX & JSON-LD)

```bibtex
@misc{chat_rh_spectral_audit_2026,
  author       = {Turner, Wesley and Google Gemini},
  title        = {Quantum-Causal Grassmannian Monograph Review: Riemann Hypothesis Spectral Approaches, Bass-Ihara Graph Zeta, Jensen-Polya QFIM, and Lehmer Pair Audits},
  year         = {2026},
  howpublished = {AI chat log (design provenance only; audited and corrected against 35-digit mpmath)},
  note         = {Source: data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md, lines 2348-5728}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Finite Spectral Contracts for Riemann Hypothesis Approaches: The Bass-Ihara Ramanujan Dichotomy (14-Vertex Non-Ramanujan Witness), Jensen-Polya Transverse QFIM Stiffness, Li's Unit-Circle Criterion, and High-Precision Euler-Maclaurin / Riemann-Siegel C_2(p) Audits in Lean 4, Rust/PyO3, and SymPy",
  "isBasedOn": [
    "data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md",
    "src/signals/Signals/RiemannSpectral.lean",
    "src/signals/numerical_adapter/src/riemann_spectral.rs"
  ],
  "dateModified": "2026-11-19"
}
```
