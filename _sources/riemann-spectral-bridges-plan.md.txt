---
title: "Written Plan: Error Minimization, Mpemba–Trajectory Synthesis, and Phased Workstreams (RB-1 to RB-6) for the Remaining Riemann Hypothesis Analytical Bridges in Lean 4, Rust/PyO3, and SymPy"
description: "Phased implementation plan connecting the De Bruijn–Newman Lehmer Collision Theorem, Strong Mpemba slow-mode projection, Three-Channel Plücker–Madelung–QFIM quantum trajectories, and numerical error-minimization upgrades (Gabcke C_3/C_4, analytic Z'/Z'', orthonormal Hermite–Gaussian Weil Gram conditioning, quartic dBN heat flow while preserving the strict epistemic boundary for the four open Millennium-Problem bridges."
---

(riemann-spectral-bridges-plan)=
# Written Plan: Error Minimization, Mpemba–Trajectory Synthesis, and Phased Workstreams (`RB-1`–`RB-6`) for the Remaining Riemann Hypothesis Analytical Bridges

- **Author:** Wes Turner
- **Owning Paper:** [Finite Spectral Contracts for Riemann Hypothesis Approaches](grassmannian-riemann-spectral-ihara-jensen-polya-paper.md)
- **Companion Papers Reused:**
  - [Celestial Holography, the Canonical Dictionary ($\Delta = 2s$), Plancherel–Unruh Graviton Loop Weights ($M_1 = 1/8, M_2 = 1/90$), and Integrated Turner Models 15a & 15b for Gravitons and Riemann Spectral Bridges](grassmannian-celestial-holography-graviton-turner-riemann-paper.md)
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
To discharge `Signals.Pending.RiemannHypothesisPendingBoundary.allFourBridgesClosed`, four global analytical theorems remain open in pure mathematics (none is discharged by `RB-1`–`RB-5`; see [sato-riemann-spectral-pending-closure-plan.md](sato-riemann-spectral-pending-closure-plan.md) and [unified-pending-closure-roadmap-plan.md](unified-pending-closure-roadmap-plan.md) for the constructive certificate contracts `RiemannHypothesisPendingBoundary.solved_of_certificates` and `SatoRiemannSpectralPendingBoundary.solved_of_certificates`):
1. **Bridge 1 (Global de Bruijn–Newman Upper Bound):** Prove $\Lambda_{\mathrm{dBN}} \le 0$ for all heights $\gamma \to \infty$ (combining with Rodgers–Tao 2020's $\Lambda_{\mathrm{dBN}} \ge 0$ to yield $\Lambda_{\mathrm{dBN}} = 0$).
2. **Bridge 2 (Adelic Sato Trace-Norm Convergence):** Prove that finite-prime Bass–Ihara / Plabic VRC transfer operators converge in trace norm on $\mathrm{Gr}_{\mathrm{Sato}}(\mathbb{A}_{\mathbb{Q}}/\mathbb{Q}^\times)$ to a Ramanujan-bounded operator without introducing off-circle spectral leakage.
3. **Bridge 3 (Global Positivity Across All Degrees/Dimensions):** Prove $J^{d,n}(X)$ is hyperbolic for **all** $(d, n)$ (beyond fixed-$d$ large-$n$ GORZ), equivalently $\lambda_n \ge 0$ for **all** $n \ge 1$, equivalently $W(g \ast \tilde{g}) \ge 0$ on the full Schwartz–Bruhat space.
4. **Bridge 4 (Self-Adjoint Spectral Operator Closure):** Construct a Hilbert space and essentially self-adjoint domain closure whose spectrum is the exact set of imaginary parts $\{\gamma_k\}$ of the nontrivial zeros of $\zeta(s)$.

## 5. Literature Status and Existing Partial Results (Reviewed 2026-11-19)

This is a targeted literature check, not a proof review. Primary papers and source records were checked for the four RB-6 claims. Targeted arXiv searches on 2026-11-19 for `adelic Sato Grassmannian trace norm`, `Plabic transfer operators trace norm Ramanujan`, and `trace-norm adelic Grassmannian` returned no exact results. That limited search is not evidence that no related work exists; the relevant finite graph and planar-network results below do not by themselves establish the proposed adelic limit.

| Bridge | Existing results and evidence status | Exact remaining gap |
| --- | --- | --- |
| 1. de Bruijn-Newman upper bound | Rodgers and Tao prove $\Lambda_{\mathrm{dBN}}\ge 0$ and state that RH is equivalent to $\Lambda_{\mathrm{dBN}}\le 0$ [Rodgers and Tao (2020)](#ref-rodgers-tao2020). The peer-reviewed Polymath15 work proves the positive upper bound $\Lambda_{\mathrm{dBN}}\le 0.22$ [Polymath (2019)](#ref-polymath2019). A newer arXiv preprint claims $\Lambda_{\mathrm{dBN}}<0.156821$ [Planat and Raymond (2026)](#ref-planat-raymond2026); separate 2026 Zenodo preprints claim $\Lambda_{\mathrm{dBN}}\le0.1811918082$ and $\Lambda_{\mathrm{dBN}}\le0.1875$ [Kornaus (2026)](#ref-kornaus2026), [Mosaic Intelligence (2026)](#ref-mosaic2026). These recent deposits are not peer-reviewed results in the records checked; this review has not independently validated their certificates. | All listed upper bounds are positive. None establishes $\Lambda_{\mathrm{dBN}}\le0$, so none proves RH or closes Bridge 1. The latest arXiv record itself distinguishes its claim from other unrefereed computational bounds. The Clay Mathematics Institute still lists RH as unsolved [Clay Mathematics Institute](#ref-clay-rh). |
| 2. Adelic Sato trace-norm limit | Bass develops the finite Ihara-Selberg zeta/determinant theory for tree lattices [Bass (1992)](#ref-bass1992). Postnikov shows how planar-network boundary measurements parametrize cells of the totally nonnegative Grassmannian [Postnikov (2006)](#ref-postnikov2006). These are relevant finite ingredients, not the proposed operator family or limit. | The targeted search found no source proving trace-norm convergence of finite-prime Bass-Ihara or Plabic VRC operators on the stated adelic Sato Grassmannian, with a Ramanujan-bounded limit and no off-circle leakage. The operator sequence, common trace-class space, norm estimates, and spectral convergence statement still need precise definitions and proofs. |
| 3. Global Li/Jensen-Polya/Weil positivity | Li's criterion characterizes RH by nonnegativity of every Li coefficient [Li (1997)](#ref-li1997). Pólya's Jensen-polynomial criterion is restated in the modern GORZ work [Pólya (1927)](#ref-polya1927), [Griffin et al. (2019)](#ref-griffin2019). The 2019 paper proves cases through degree 8 and density-one shift results; the later xi-function paper proves hyperbolicity for every fixed degree once the shift is sufficiently large, with an effective threshold [Griffin et al. (2022)](#ref-griffin2022). Farmer cautions that these asymptotic Hermite limits do not by themselves justify an RH proof strategy; this is a critique of that inference, not a disproof of the criterion [Farmer (2020)](#ref-farmer2020). | The criteria still require all Li indices, all Jensen degrees and shifts (including any finite exceptional shifts), or Weil's explicit-formula positivity on the full test-function space [Weil (1952)](#ref-weil1952). Finite prefixes and fixed-degree asymptotics do not establish those universal quantifiers. |
| 4. Self-adjoint spectral operator | Berry and Keating develop the spectral analogy and the $xp$ classical model, but describe the corresponding Hermitian operator as unknown [Berry and Keating (1999)](#ref-berrykeating1999). Connes gives a spectral interpretation in which critical zeros appear as an absorption spectrum and formulates a trace formula on the adele class space [Connes (1999)](#ref-connes1999). | These are candidate frameworks, not a construction of an essentially self-adjoint operator with domain closure and point spectrum exactly the zeta-zero ordinates. A trace-formula or absorption-spectrum interpretation is not that operator theorem. RH remains listed as unsolved by the Clay Mathematics Institute [Clay Mathematics Institute](#ref-clay-rh). |

### Scholarly References

(ref-rodgers-tao2020)=
<a id="rodgers-tao2020"></a> Rodgers, Brad and Terence Tao (2020). “The de Bruijn-Newman Constant Is Non-Negative.” *Forum of Mathematics, Pi* 8, e6. [DOI](https://doi.org/10.1017/fmp.2020.6); [arXiv:1801.05914](https://arxiv.org/abs/1801.05914).

(ref-polymath2019)=
<a id="polymath2019"></a> D. H. J. Polymath (2019). “Effective approximation of heat flow evolution of the Riemann xi function, and a new upper bound for the de Bruijn-Newman constant.” *Research in the Mathematical Sciences* 6(3). [DOI](https://doi.org/10.1007/s40687-019-0193-1); [arXiv:1904.12438](https://arxiv.org/abs/1904.12438).

(ref-planat-raymond2026)=
<a id="planat-raymond2026"></a> Michel Planat and Dale James Raymond (2026). “Certified Collision Exclusion and an Unconditional Upper Bound $\Lambda<0.156821$ for the de Bruijn-Newman Constant.” arXiv preprint, submitted 2026-11-04; no journal reference is listed on the arXiv record as of this review. [arXiv:2611.06245](https://arxiv.org/abs/2611.06245).

(ref-kornaus2026)=
<a id="kornaus2026"></a> Daniel Martin Kornaus (2026). “A certified upper bound of 0.1811918082 for the de Bruijn-Newman constant.” Zenodo preprint, released for independent verification and peer review. [Record](https://doi.org/10.5281/zenodo.21866666).

(ref-mosaic2026)=
<a id="mosaic2026"></a> Mosaic Intelligence (2026). “A certified unconditional upper bound $\Lambda\le0.1875$ for the de Bruijn-Newman constant.” Zenodo deposit; the record describes the work as fully AI-derived. [Record](https://doi.org/10.5281/zenodo.21175533).

(ref-bass1992)=
<a id="bass1992"></a> Bass, Hyman (1992). “The Ihara-Selberg Zeta Function of a Tree Lattice.” *International Journal of Mathematics* 3(6), 717-797. [DOI](https://doi.org/10.1142/S0129167X92000357).

(ref-postnikov2006)=
<a id="postnikov2006"></a> Postnikov, Alexander (2006). “Total Positivity, Grassmannians, and Networks.” [arXiv:math/0609764](https://arxiv.org/abs/math/0609764).

(ref-li1997)=
<a id="li1997"></a> Li, Xian-Jin (1997). “The Positivity of a Sequence of Numbers and the Riemann Hypothesis.” *Journal of Number Theory* 65(2), 325-333. [DOI](https://doi.org/10.1006/jnth.1997.2137).

(ref-polya1927)=
<a id="polya1927"></a> Pólya, George (1927). “Über die algebraisch-funktionentheoretischen Untersuchungen von J. L. W. V. Jensen.” *Kongelige Danske Videnskabernes Selskab, Mathematisk-Fysiske Meddelelser* 7, 3-33.

(ref-griffin2019)=
<a id="griffin2019"></a> Griffin, Michael, Ken Ono, Larry Rolen, and Don Zagier (2019). “Jensen Polynomials for the Riemann Zeta Function and Other Sequences.” *Proceedings of the National Academy of Sciences* 116(23), 11103-11110. [DOI](https://doi.org/10.1073/pnas.1902572116); [arXiv:1902.07321](https://arxiv.org/abs/1902.07321).

(ref-griffin2022)=
<a id="griffin2022"></a> Griffin, Michael, Ken Ono, Larry Rolen, Jesse Thorner, Zachary Tripp, and Ian Wagner (2022). “Jensen Polynomials for the Riemann Xi Function.” *Advances in Mathematics* 397, 108186. [DOI](https://doi.org/10.1016/j.aim.2022.108186); [arXiv:1910.01227](https://arxiv.org/abs/1910.01227).

(ref-farmer2020)=
<a id="farmer2020"></a> Farmer, David W. (2020). “Jensen Polynomials Are Not a Plausible Route to Proving the Riemann Hypothesis.” [arXiv:2008.07206](https://arxiv.org/abs/2008.07206).

(ref-weil1952)=
<a id="weil1952"></a> Weil, André (1952). “Sur les ‘formules explicites’ de la théorie des nombres premiers.” *Communications du Séminaire Mathématique de l'Université de Lund*, supplementary volume, 252-265.

(ref-berrykeating1999)=
<a id="berrykeating1999"></a> Berry, Michael V. and Jonathan P. Keating (1999). “The Riemann Zeros and Eigenvalue Asymptotics.” *SIAM Review* 41(2), 236-266. [DOI](https://doi.org/10.1137/S0036144598347497).

(ref-connes1999)=
<a id="connes1999"></a> Connes, Alain (1999). “Trace Formula in Noncommutative Geometry and the Zeros of the Riemann Zeta Function.” *Selecta Mathematica* 5, 29-106. [DOI](https://doi.org/10.1007/s000290050042); [arXiv:math/9811068](https://arxiv.org/abs/math/9811068).

(ref-clay-rh)=
<a id="clay-rh"></a> Clay Mathematics Institute. “The Riemann Hypothesis.” [Millennium Prize Problem status](https://www.claymath.org/millennium/riemann-hypothesis/), accessed 2026-11-19.

## 6. RB-6 Finite Contract Problem Definitions

The following finite problems make the four bridges testable at bounded scale. Each uses supplied finite data and proves only a consequence of those inputs. None provides evidence that its assumptions hold for the zeta function, proves convergence of an infinite family, or closes the corresponding global bridge.

### Contract 1: Bounded Quartic Heat on a Finite Box

**Instance:** Real coefficients $z_0,z_2,z_4$, time and spatial bounds $T,X$, coefficient bounds $B_0,B_2,B_4$, and a point $(t,\Delta z)$ satisfying $|z_j|\le B_j$ for $j\in\{0,2,4\}$, $|t|\le T$, $|\Delta z|\le X$, and $B_2,B_4\ge 0$.

**Finite claim:** At the center, prove $|H_t(0)|\le B_0+B_2T+\frac{1}{2}B_4T^2$. Uniformly over the full box $|t|\le T$, $|\Delta z|\le X$, prove

$$
|H_t(\Delta z)|\le B_0+B_2T+\frac{1}{2}B_4T^2+\frac{1}{2}(B_2+B_4T)X^2+\frac{1}{24}B_4X^4.
$$

The Lean contracts are `dbnQuarticHeat_peak_abs_le` and `dbnQuarticHeat_abs_le_on_box`.

**Finite Grassmannian interpretation:** Encode the coefficient vector as the plane generated by $(a_0,a_2,a_4,0)$ and $(0,0,0,1)$, with generator

$$
C(a_0,a_2,a_4)=\begin{pmatrix}a_0&a_2&a_4&0\\0&0&0&1\end{pmatrix},\qquad
(p_{12},p_{13},p_{14},p_{23},p_{24},p_{34})=(0,0,a_0,0,a_2,a_4).
$$

The Plucker relation holds identically. A nonzero coefficient triple gives a nonzero minor and hence a point in the real locus of $\mathrm{Gr}(2,4)$ (which embeds into $\mathrm{Gr}_{\mathbb C}(2,4)$); the zero triple gives the zero Plucker vector and is not itself a Grassmannian point. The heat step acts on the right by the invertible lower-triangular ambient matrix

$$
U_h=\begin{pmatrix}1&0&0&0\\-2h&1&0&0\\12h^2&-12h&1&0\\0&0&0&1\end{pmatrix},\qquad C(t+h)=C(t)U_h,\qquad U_{h_1}U_{h_2}=U_{h_1+h_2}.
$$

In Lean this is the finite coefficient-plane orbit (`DBNQuarticHeatGr24State`, `dbnQuarticHeatGr24GeneratorMatrix`, `dbnQuarticHeatGr24PluckerCoordinates`, and `dbnQuarticHeatGr24AmbientAction`). It is not the Sato Grassmannian, an operator model for zeta zeros, or a physical second-sound/temperature evolution.

**What remains to define:** This bounds a supplied quartic polynomial on a compact box, not the actual analytic heat flow or the de Bruijn-Newman constant. A finite approximation to the analytic problem must specify the height interval, how the coefficients are obtained from the relevant zeta-derived function, and a uniform Taylor-remainder bound relating the polynomial to the actual heat flow on that box. The global bridge additionally requires control uniformly over all heights.

### Contract 2: Finite Diagonal Transfer Error and Spectral Margin

**Instance:** Two real diagonal $N\times N$ matrices $A_N=\operatorname{diag}(a_i)$ and $B_N=\operatorname{diag}(b_i)$, with coordinate error $|a_i-b_i|\le\varepsilon$ for each $i\in\{1,\ldots,N\}$.

**Finite claim:** Since the trace norm of a diagonal matrix is the sum of the absolute values of its diagonal entries, prove $\|A_N-B_N\|_1=\sum_i|a_i-b_i|\le N\varepsilon$. If also $|b_i|\le R$ for each coordinate, prove $|a_i|\le R+\varepsilon$. The Lean contracts are `finiteDiagonalTransferTraceDistance_le` and `finiteDiagonalTransfer_radius_le`.

**What remains to define:** The proxy has no prime index, graph/plabic transfer construction, adelic state space, or limiting operator. The finite-prime problem must first define the operators and their common normed space, the truncation/index parameter, and a computable trace-norm residual. A limit claim then needs a Cauchy or explicit tail bound in that norm and a separate argument that the limiting spectrum obeys the required Ramanujan bound without off-circle leakage. Coordinatewise error in an arbitrary diagonal model is not that argument.

### Contract 3: Positivity of a Finite Li Prefix

**Instance:** A real sequence $c_n$ and a fixed integer cutoff $N\ge 1$.

**Finite claim:** Assume $c_n\ge 0$ for every $1\le n\le N$; prove both the finite-prefix predicate and its consequence $\sum_{n=1}^{N}c_n\ge 0$. The Lean contracts are `finiteLiPositivePrefix` and `finiteLiPrefixSum_nonneg`; the sequence is generic and is not yet identified in Lean with the Keiper–Li coefficients.

**What remains to define:** A nontrivial finite audit must instantiate $c_n$ with exact Li coefficients and supply proof-grade values or rational intervals whose lower endpoints are nonnegative for each index through $N$. Jensen-polynomial hyperbolicity and finite Weil-form positivity require their own bounded degree/dimension and test-function inputs. Even a certified prefix for a chosen $N$ says nothing about $n>N$ or positivity on the full Schwartz–Bruhat space.

### Contract 4: Finite Diagonal Spectral Model

**Instance:** A finite-dimensional real space $V_N=\mathbb{R}^N$ with its coordinate inner product and a supplied real list $d_1,\ldots,d_N$; define $D_Nx=(d_i x_i)_i$.

**Finite claim:** Prove $D_N$ is symmetric and that $\lambda$ is an eigenvalue exactly when $\lambda=d_i$ for some coordinate. The Lean contracts are `finiteDiagonalOperator_symmetric` and `finiteDiagonalEigenvalue_iff_mem_range`.

**What remains to define:** This model supplies its own spectrum by construction and has no unbounded operator, dense domain, or boundary conditions. A finite-section approximation to Bridge 4 must define matrices from a specified candidate operator and basis, preserve multiplicities, and provide a convergence criterion (for example, a resolvent comparison) that relates the finite spectra to the operator on a common Hilbert space. Essential self-adjointness and exact correspondence with all nontrivial zeta-zero ordinates remain separate global obligations.

### Finite-to-Global Promotion Gate

For all four contracts, record the finite input, cutoff, assumptions, and proof separately from any proposed global limit. Promotion requires a proved approximation theorem with explicit error control and a justified limit argument; increasing a numerical cutoff, checking more zeros, or compiling the finite Lean statements does not by itself satisfy that gate.
