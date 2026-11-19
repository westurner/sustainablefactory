---
title: "Written Plan: Error Minimization, Mpemba–Trajectory Synthesis, and Phased Workstreams (RB-1 to RB-6) for the Remaining Riemann Hypothesis Analytical Bridges in Lean 4, Rust/PyO3, and SymPy"
description: "Phased implementation plan connecting the De Bruijn–Newman Lehmer Collision Theorem, Strong Mpemba slow-mode projection, Three-Channel Plücker–Madelung–QFIM quantum trajectories, and numerical error-minimization upgrades (Gabcke C_3/C_4, analytic Z'/Z'', orthonormal Hermite–Gaussian Weil Gram conditioning, quartic dBN heat flow while preserving the strict epistemic boundary for the four open Millennium-Problem bridges."
---

(riemann-spectral-bridges-plan)=
# Written Plan: Error Minimization, Mpemba–Trajectory Synthesis, and Phased Workstreams (`RB-1`–`RB-6`) for the Remaining Riemann Hypothesis Analytical Bridges

- **Author:** Wes Turner
- **Owning Paper:** [Finite Spectral Contracts for Riemann Hypothesis Approaches](grassmannian-riemann-spectral-ihara-jensen-polya-paper.md)
- **Companion Papers Reused:**
  - [Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws](grassmannian-quantum-causal-inference-mpemba-paper.md)
  - [Quantum Trajectories in Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k,n)$, Three-Channel Plücker–Madelung–QFIM ($F_{\mu\nu} = 4\,g_{\mu\nu}^{\mathrm{FS}}$), Dual-Schubert `iGPE`, and Dilatant Dark Fluid (`DDF`) Mechanics](grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md)
  - [Verified Finite Contracts for Grassmannian EBR, All 80 Crystallographic Layer Groups, PSD Slavnov–Gram DPPs, Multi-Reference NOCI, `Tequila`-Compiled Grid DSLs, and Finite-Graph Ihara–Selberg Zeta Functions](grassmannian-gebr-layer-groups-dpp-noci-arc-paper.md)
- **Design Provenance:** {download}`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md <../data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md>` (lines `2348–5728`)

---

## 1. Epistemic Scope: What Can Be Proved & Minimized Now vs. Open Millennium Bridges

This plan distinguishes sharply between **five executable engineering and finite-mathematics workstreams (`RB-1` through `RB-5`)** that close every numerical, algorithmic, and finite-contract gap in our tri-language stack (`Lean 4`, `Rust/PyO3`, `Python/SymPy/mpmath`), and **Workstream `RB-6`**, which formally tracks the four open infinite-dimensional analytical theorems required to resolve the classical Riemann Hypothesis for $\zeta(s)$ (`Signals.Pending.RiemannHypothesisPendingBoundary`). No finite check, higher-order Riemann–Siegel expansion, or finite-dimensional Weil/GORZ probe proves classical RH; each executable workstream instead tightens error bounds by orders of magnitude, eliminates numerical failure modes, and sharpens the exact analytical obstructions.

---

## 2. Synthesis: Connecting the De Bruijn–Newman Lehmer Collision Theorem to Mpemba Relaxation and Three-Channel Quantum Trajectories

Three mechanisms from our companion papers interlock directly at the **De Bruijn–Newman Lehmer Collision Theorem** (`Signals.RiemannSpectral.dbnQuadraticHeat_collides_and_leaves_real_axis`):

1. **Strong Mpemba Orthogonal Projection ($P_{\perp v_2} \in \mathrm{Gr}_{\mathbb{R}}(N-1, N)$) & Spectral-Gap Conditioning:**
   - In `Signals.QuantumCausalInference` (`mpembaTwoModeDistance`, `strongMpembaCrossingTime`, `mpembaProjector00..11`) and `quantum_causal_inference.rs` (`apply_strong_mpemba_gr12_projector`), orthogonally projecting out the slowest relaxation eigenmode ($a_{2,\mathrm{hot}} = 0$) accelerates decay from $e^{-\lambda_2 t}$ to $e^{-\lambda_3 t}$.
   - Under the de Bruijn–Newman heat equation $\partial_t H_t = -\partial_z^2 H_t$ and the **Weil Explicit-Formula Gram operator** $W(g \ast \tilde{g})$, slow/near-singular modes play two dual roles:
     - **In Lehmer near-miss pairs** (#6709/#6710, $\Delta\gamma = 0.0376985$), the pair separation gap is anomalously small, creating a slow local mode with tiny backward collision time $t_{\mathrm{heat}} = Z(\gamma_*)/Z''(\gamma_*) = -0.0001775410 < 0$.
     - **In the finite-dimensional Weil Gram matrix** $W_{ij}$, projecting a test vector onto the Strong Mpemba fast complement $P_{\perp v_{\mathrm{slow}}}$ strictly raises the Rayleigh quotient from $\lambda_{\min}(W)$ to $\ge \lambda_2(W)$, improving numerical conditioning when probing higher-dimensional Weil subspaces alongside Cholesky PSD Slavnov–Gram DPP repulsion (`slavnov_dpp.rs`).
2. **Three-Channel Plücker–Madelung–QFIM Trajectories (`grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md`):**
   - Just as Channel 2 osmotic density-Fisher speed $v_{\mathrm{osm}} = \frac{\hbar}{2m}\lvert \partial_x \rho / \rho \rvert$ resolves the Sharoglazova–Klaers (*Nature* 2025) paradox where standard Bohmian phase velocity vanishes ($v_S = 0$), on the Riemann critical line $\sigma_{\mathrm{dev}} = 0$ at any Lehmer extremum ($Z'(\gamma_*) = 0$), Channel A osmotic slope $J_{\mathrm{osm}} = (Z')^2 = 0$ stalls while **Channel B Bohm curvature $J_{\mathrm{bohm}} = -Z(\gamma_*)Z''(\gamma_*) > 0$** supplies 100% of the transverse QFIM restoring stiffness ($\eta_{\mathrm{Bohm}} = 1.0000$).
   - Just as Drori et al. (*Science* 2023/2024) showed that pairwise 2-body models fail for $n \ge 3$ photons while $n$-body Grassmannian $\mathrm{Gr}_{\mathbb{C}}(n, 2n)$ blockade captures multi-body saturation, Lehmer pair dynamics under $\dot{z}_k = \sum_{j \ne k} 2/(z_j - z_k)$ depend not only on the isolated 2-zero gap $\Delta\gamma$ ($t_{\mathrm{CM}} = -\Delta\gamma^2 / 8$), but on the **$N$-zero Calogero–Moser neighbor pressure** from surrounding zeros (#6705..#6714) and the **4th-order Taylor curvature $Z^{(4)}(\gamma_*)$** in the quartic de Bruijn–Newman heat solution.
3. **Finite-Graph Mixing & Ramanujan Spectral Gap:**
   - On a finite connected $(q+1)$-regular graph, the Ramanujan bound $\lvert \lambda_{\mathrm{nt}} \rvert \le 2\sqrt{q}$ is simultaneously the **Graph Riemann Hypothesis** ($\lvert u \rvert^2 = 1/q$) and the **optimal Mpemba/Markov spectral gap** governing non-backtracking mixing. Comparing a tower of Ramanujan graphs ($K_{3,3}$, Petersen $V=10$, Heawood $V=14$, Möbius–Kantor $V=16$) against non-Ramanujan Barbell graphs ($G_{14}$, $G_{16}$) quantifies how super-Ramanujan eigenvalues slow mixing and split Bass–Ihara roots off the critical circle.

---

## 3. Quantitative Error-Minimization Budget

Our baseline `a3350536` implementation already achieved $2.84 \times 10^{-14}$ error on the first 30 zeros via Euler–Maclaurin, but left five concrete numerical/truncation error sources that this plan targets directly:

| Error Source | Baseline (`a3350536`) Error | Root Cause | Planned Upgrade | Target Error After Upgrade |
| :--- | :---: | :--- | :--- | :---: |
| **1. Riemann–Siegel Remainder at $t \approx 7005.08$** | `1.25e-09` (`7.76e-05` at $\gamma_1$) | Truncated at $C_2(p)$ ($O(a^{-5/2})$) | Add exact Gabcke Chebyshev $C_3(p), C_4(p)$ ($O(a^{-7/2}), O(a^{-9/2})$) in `riemann_spectral.rs` | **`< 1e-13`** at $t \approx 7005$ (`> 10,000×` reduction) |
| **2. Derivatives $Z'(\gamma), Z''(\gamma)$ & $\mathcal{J}(\gamma)$** | `~1.9e-04` at $g_{125}$; `~1e-05` at Lehmer | 4th-order central finite differences (`h = 5e-4`) lose $O(\epsilon/h^2)$ digits | Exact analytic derivatives $Z'(t), Z''(t)$ (term-by-term Euler–Maclaurin & Riemann–Siegel + analytic Chebyshev $C_k'(p), C_k''(p)$) | **`< 1e-11`** (`> 10^6×` reduction) |
| **3. Weil Gram Matrix Conditioning ($\kappa(W)$)** | `kappa(W_4) ~ 3,441` (raw Gaussians) | Non-orthogonal raw Gaussian basis $e^{-\alpha_i x^2}$ becomes exponentially collinear as $d$ grows | Orthonormal even Hermite–Gaussian basis $\phi_k(x) = c_k H_{2k}(\sqrt{2\alpha}\,x) e^{-\alpha x^2}$ + Strong Mpemba slow-mode projection $P_{\perp v_{\mathrm{slow}}}$ | Well-conditioned $d = 6$ / $d = 8$ Weil positivity probes to `< 1e-40` prime-vs-zero parity |
| **4. Lehmer Quadratic Heat Truncation ($t_{\mathrm{heat}} / t_{\mathrm{CM}}$)** | `0.06%` (`0.999403` vs. `1.0000`) | Truncated at $Z''(\gamma_*)$; ignored $Z^{(4)}(\gamma_*)$ and neighbor zeros | Exact quartic de Bruijn–Newman heat polynomial (`dbnQuarticHeatSolution`) + multi-zero Calogero–Moser neighbor-pressure ODE | Exact quartic collision root & quantified $N$-zero neighbor shift |
| **5. Citation / Cross-Reference Hygiene** | Manual HTML anchors / `{ref}` | References not yet wired through `docs/citations.bib` | Add verified BibTeX entries to `docs/citations.bib` and migrate paper to `sphinxcontrib-bibtex` `{cite:p}` + filtered `{bibliography}` | Zero `myst.xref_missing` or bibliography warnings |

---

## 4. Phased Implementation Workstreams (`RB-1` Through `RB-6`)

### `RB-1`: Rust/PyO3 Precision Upgrades (`C_3/C_4` Riemann–Siegel & Exact Analytic $Z', Z''$)
- **Files:** `src/signals/numerical_adapter/src/riemann_spectral.rs`, `src/signals/numerical_adapter/src/lib.rs`
- **Deliverables:**
  1. Generate 120-digit `mpmath` Chebyshev tables for Gabcke's $C_3(p)$ (odd $T_{2k+1}$) and $C_4(p)$ (even $T_{2k}$) on $x = 2p - 1 \in [-1, 1]$ and add `hardy_z_riemann_siegel_c4(t)`.
  2. Implement exact analytic differentiation for `riemann_siegel_theta_derivs(t)` ($\vartheta, \vartheta', \vartheta''$), `zeta_euler_maclaurin_derivs(sigma, t)` ($\zeta, \partial_t\zeta, \partial_t^2\zeta$), and `hardy_z_and_derivs_riemann_siegel(t)` (including analytic Chebyshev derivative evaluation of $C_0\text{..}C_4$ with chain rule $\frac{dp}{dt} = \frac{1}{4\pi a}$).
  3. Upgrade `evaluate_madelung_bohm_jensen_polya` to use exact analytic derivatives and add `py_compare_rs_c2_vs_c4_and_analytic_derivs` PyO3 binding.
- **Verification Gate:** `cargo test` verifies $< 10^{-11}$ error on $Z', Z'', \mathcal{J}$ across $g_{125}\text{..}g_{135}$ and $< 10^{-12}$ on Lehmer's 1956 pair vs. 40-digit `mpmath`.

### `RB-2`: Lean 4 Quartic de Bruijn–Newman Heat PDE, Strong Mpemba Slow-Mode Projection, & Multi-Zero Calogero–Moser
- **Files:** `src/signals/Signals/RiemannSpectral.lean`, `src/signals/SignalsTests.lean`
- **Deliverables:**
  1. `dbnQuarticHeatSolution (z0 z2 z4 t dz : ℝ)`: prove exact algebraic heat-PDE closure $\partial_t H_t + \partial_{dz}^2 H_t = 0$ (via polynomial coefficient identities) and exact quartic shift at $dz = 0$: $H_t(0) = z_0 - z_2 t + \frac{1}{2} z_4 t^2$, quantifying the exact $O(z_4 t^2)$ correction to the quadratic collision time $t_{\mathrm{quad}} = z_0 / z_2$.
  2. `mpembaProjectedWeilRayleigh`: reuse `Signals.QuantumCausalInference.mpembaProjector00..11` to prove that for a $2\times 2$ diagonalized Weil operator $\operatorname{diag}(\lambda_{\mathrm{slow}}, \lambda_{\mathrm{fast}})$ with $0 < \lambda_{\mathrm{slow}} < \lambda_{\mathrm{fast}}$, applying the Strong Mpemba orthogonal projector $P_{\perp v_{\mathrm{slow}}}$ strictly raises the normalized Rayleigh quotient from $\lambda_{\mathrm{slow}}$ to $\lambda_{\mathrm{fast}}$ and eliminates the slow-mode amplitude identically.
  3. `dbnFourZero_center_of_mass_conserved`: extend center-of-mass conservation to 4 interacting zeros (`#6708, #6709, #6710, #6711`) and prove the neighbor-squeezing sign theorem showing how outer zeros symmetrically accelerate or retard a Lehmer pair's collision velocity.
- **Verification Gate:** `make signals_build` compiles cleanly with zero `sorry` axioms.

### `RB-3`: SymPy / `mpmath` Orthonormal Hermite–Gaussian Weil Gram Conditioning, GORZ $d = 2\text{..}8$, & Multi-Zero Lehmer Neighbor Audit
- **Files:** `sustainablefactory/riemann_rh_bridges.py`, `tests/test_riemann_spectral_sympy_pyo3.py`
- **Deliverables:**
  1. Add `audit_weil_hermite_gaussian_gram_matrix` using the exact orthonormal even Hermite–Gaussian basis $\phi_k(x) = c_k H_{2k}(\sqrt{2\alpha}\,x) e^{-\alpha x^2}$ (for $k = 0\text{..}5$, $6\times 6$ matrix), proving exact prime-vs-zero agreement ($< 10^{-40}$), strict positive-definiteness, and direct condition-number comparison against raw Gaussians.
  2. Extend `audit_gorz_jensen_hyperbolicity` to degrees $d = 2\text{..}8$ and `compute_exact_keiper_li_coefficients` to $n = 1\text{..}25$.
  3. Add `audit_lehmer_quartic_heat_and_neighbor_pressure` computing exact $Z^{(4)}(\gamma_*)$, the quartic collision root $t_{\mathrm{quartic}}$, and the $N$-zero Calogero–Moser neighbor pressure from zeros #6705..#6714 around Lehmer's 1956 pair.
- **Verification Gate:** `pytest -q tests/test_riemann_spectral_sympy_pyo3.py` passes all symbolic, Rust/PyO3, and 50–80 digit `mpmath` assertions.

### `RB-4`: Finite-Graph Ramanujan Tower vs. Non-Ramanujan Mixing & Spectral-Gap Diagnostics
- **Files:** `src/signals/numerical_adapter/src/riemann_spectral.rs`, `src/signals/numerical_adapter/src/lib.rs`, `tests/test_riemann_spectral_sympy_pyo3.py`
- **Deliverables:**
  1. Extend `py_audit_regular_graphs_bass_ihara` with two additional 3-regular connected graphs: the 6-vertex Ramanujan utility graph $K_{3,3}$ and the 16-vertex Ramanujan Möbius–Kantor graph (contrasted with Petersen $V=10$, Heawood $V=14$, and Non-Ramanujan Barbell $G_{14}$).
  2. Report the Markov spectral gap $\gamma_{\mathrm{gap}} = 1 - \max\lvert\lambda_{\mathrm{nt}}\rvert / d$ and Ramanujan mixing margin $2\sqrt{q} - \max\lvert\lambda_{\mathrm{nt}}\rvert$ for each graph, linking the Bass–Ihara critical circle directly to Mpemba relaxation speed.

### `RB-5`: `sphinxcontrib-bibtex` `{cite:p}` Migration & Paper Integration
- **Files:** `docs/citations.bib`, `docs/grassmannian-riemann-spectral-ihara-jensen-polya-paper.md`
- **Deliverables:**
  1. Add complete verified BibTeX entries to `docs/citations.bib` (`bass1992ihara`, `bombieri2000rh`, `borwein2000zeta`, `csordas1994lehmer`, `gabcke1979riemann`, `griffin2019jensen`, `lehmer1956extended`, `li1997positivity`, `polya1927algeb`, `rodgers2020debruijn`, `weil1952explicit`).
  2. Replace all manual HTML/anchor citations in `docs/grassmannian-riemann-spectral-ihara-jensen-polya-paper.md` with `{cite:p}` and a filtered `{bibliography}` block (reusing existing keys `holtzman2022landau`, `summer2026resource`, `sharoglazova_energyspeed_2025`, `drori2023quantum`, `delRio2011thermodynamicMeaning`).
  3. Integrate the `RB-1` through `RB-4` results (Mpemba–Trajectory synthesis, error-minimization before/after tables, quartic dBN Lehmer collision, and Hermite–Gaussian Weil Gram conditioning) into the paper.
- **Verification Gate:** Zero scanner findings, zero Sphinx warnings on both the plan and the paper, and browser inspection confirming MathJax rendering and clickable `{cite:p}` links.

### `RB-6`: Open Infinite-Dimensional Millennium-Problem Bridges (`Signals.Pending` Epistemic Gate)
To discharge `Signals.Pending.RiemannHypothesisPendingBoundary.allFourBridgesClosed`, four global analytical theorems remain open in pure mathematics (none is discharged by `RB-1`–`RB-5`):
1. **Bridge 1 (Global de Bruijn–Newman Upper Bound):** Prove $\Lambda_{\mathrm{dBN}} \le 0$ for all heights $\gamma \to \infty$ (combining with Rodgers–Tao 2020's $\Lambda_{\mathrm{dBN}} \ge 0$ to yield $\Lambda_{\mathrm{dBN}} = 0$).
2. **Bridge 2 (Adelic Sato Trace-Norm Convergence):** Prove that finite-prime Bass–Ihara / Plabic VRC transfer operators converge in trace norm on $\mathrm{Gr}_{\mathrm{Sato}}(\mathbb{A}_{\mathbb{Q}}/\mathbb{Q}^\times)$ to a Ramanujan-bounded operator without introducing off-circle spectral leakage.
3. **Bridge 3 (Global Positivity Across All Degrees/Dimensions):** Prove $J^{d,n}(X)$ is hyperbolic for **all** $(d, n)$ (beyond fixed-$d$ large-$n$ GORZ), equivalently $\lambda_n \ge 0$ for **all** $n \ge 1$, equivalently $W(g \ast \tilde{g}) \ge 0$ on the full Schwartz–Bruhat space.
4. **Bridge 4 (Self-Adjoint Spectral Operator Closure):** Construct a Hilbert space and essentially self-adjoint domain closure whose spectrum is the exact set of imaginary parts $\{\gamma_k\}$ of the nontrivial zeros of $\zeta(s)$.
