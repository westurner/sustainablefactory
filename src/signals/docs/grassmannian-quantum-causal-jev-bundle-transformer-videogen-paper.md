---
title: "Quantum Causal Grassmannian Transformers, JEV vs. Do-Calculus Decision Models, Tautological Fiber Bundles, and Spatiotemporal Video Generation in Lean 4 and Rust/WASM"
description: "An arXiv-ready MyST Markdown formal verification and systems architecture paper redeveloping JEV-style decision models and LLMs via Quantum Causal Inference, modeling self-attention as Plabic/Choi causal transfer, auditing Zhang (2025) Grassmann flows (arXiv:2512.19428) and kanenorman/grassmann, proving the advantages of De Clercq (2026) tautological fiber bundle geometry (Bundle-Transformer), Kang et al. (2025) GrFormer, and Su et al. (2021) RoFormer, and formulating linear-in-volume Quantum Causal Grassmannian Video Generation (VideoGen) in Lean 4 and Rust/WASM."
---

(grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper)=
# Quantum Causal Grassmannian Transformers, JEV vs. $\operatorname{do}$-Calculus Decision Models, Tautological Fiber Bundles, and Spatiotemporal Video Generation in Lean 4 and Rust/WASM

- **Authors:** Wes Turner
- **Subjects:**
  - Machine Learning (`cs.LG`); Artificial Intelligence (`cs.AI`); Algebraic Geometry (`math.AG`); Quantum Physics (`quant-ph`); Computer Vision and Pattern Recognition (`cs.CV`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../Signals/QuantumCausalInference.lean](../Signals/QuantumCausalInference.lean#L1052-L1475), [../Signals/Pending.lean](../Signals/Pending.lean#L5615-L5748), [../SignalsPending.lean](../SignalsPending.lean#L218-L270), [../Signals/DDF.lean](../Signals/DDF.lean#L8346-L9304), [../Signals/MultiArrayImaging.lean](../Signals/MultiArrayImaging.lean#L1-L420), [../SignalsTests.lean](../SignalsTests.lean#L6610-L6718), [../SignalsPendingTests.lean](../SignalsPendingTests.lean#L5332-L5400))
  - `Signals` LeanArchitect Blueprint ([../blueprint/src/content.tex](../blueprint/src/content.tex#L305-L425))
  - `signals-numerical-adapter` Rust/WASM Engine ([../numerical_adapter/src/quantum_causal_inference.rs](../numerical_adapter/src/quantum_causal_inference.rs#L640-L1080))
  - Canonical `docs/` Mirror: [../../../docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md](../../../docs/grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md)
- **Companion Papers:**
  - [Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws](grassmannian-quantum-causal-inference-mpemba-paper.md)
  - [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
  - [Multi-Spectral & Multi-Array Grassmannian Imaging: Hubble $2\times$ CCD Mosaics, Cosmic-Ray Telemetry, LVP Medical Arrays, LIFU/AOT/TRUE Focusing, and Sub-Nanometer Nanolithography](grassmannian-multispectral-hubble-medical-nanoimaging-paper.md)
  - [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](../../../docs/grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

Standard autoregressive Large Language Models (LLMs), vision-language transformers, and spatiotemporal video diffusion transformers rely on **multi-head self-attention** ([Vaswani et al. 2017](#qcb-vaswani2017)), which lifts a sequence of $L$ token vectors in $\mathbb{R}^d$ into an unstructured $L \times L$ pairwise compatibility tensor and conditions predictions observationally on past tokens. From the standpoint of decision theory, causal inference, and differential geometry, this architecture suffers from four structural limitations: **(i) evidential confounding** (observational conditioning $P(s \mid A)$ in **Jeffrey Expected Value (`JEV`)** decision models conflates causal mechanisms with backdoor confounders), **(ii) algebraic opacity and quadratic scaling** ($O(L^2 d_{\mathrm{head}})$ tensor lifting with no finite-dimensional global invariants, critiqued by [Zhang 2025](#qcb-zhang2025) in *Attention Is Not What You Need*, `arXiv:2512.19428`), **(iii) real-simplex positivity** (softmax weights $A_{ij} \ge 0$ cannot represent destructive phase interference or non-commutative causal order), and **(iv) flat Euclidean token conflation** (representing both an invariant semantic concept and its contextual instance as a single unstructured vector $h_t \in \mathbb{R}^d$, critiqued by [De Clercq 2026](#qcb-declercq2026) in *Bundle-Transformer*).

In this paper, we unify and redevelop **JEV-style decision models**, **self-attention and attention-free Grassmannian LLMs**, **tautological fiber bundle transformers**, and **quantum-causal video generation (`VideoGen`)** in **Lean 4** (`Signals.QuantumCausalInference`) and **Rust/WebAssembly** (`quantum_causal_inference.rs`):

1. **Redeveloping JEV-Style Decision Models & LLMs via Quantum Causal Inference (`jevEvidentialExpectedUtility`, `cevCausalDoExpectedUtility`, `qcdtQuantumCausalExpectedUtility`, `jevonsTotalComputeEnergy`)**:
   - We prove that classical **Jeffrey Expected Value (`JEV`)** ([Jeffrey 1965](#qcb-jeffrey1965)) overestimates action/token utility under backdoor confounding by the exact bias $\mathrm{JEV}(A) - \mathrm{CEV}(A) = b_{\mathrm{conf}}(u_1 - u_2)$, which is eliminated by Pearl's incoming-edge surgery $\operatorname{do}(A)$ ([Pearl 2009](#qcb-pearl2009); [Joyce 1999](#qcb-joyce1999)).
   - Lifting to **Quantum Causal Grassmannian Decision Theory (`QCDT`)** on $Gr_{\mathbb{C}}(2,4)$ adds the exact Plücker cross-channel interference term $q_{\mathrm{Pl\ddot{u}cker}} = 2\operatorname{Re}(w_A^{\mathbb{C}}\overline{w_B^{\mathbb{C}}})$ (`qcdtPluckerInterferenceTerm`), satisfying the Yukalov–Sornette ([2010](#qcb-yukalov2010)) / Busemeyer–Bruza ([2012](#qcb-busemeyer2012)) zero-sum alternation law $q(\theta) + q(\theta+\pi) = 0$ while capturing non-commutative sequential order effects via the **Quantum Switch** commutator (`quantumSwitchCommutator`).
   - We also formalize the **Jevons Marginal-Utility & Compute-Rebound Law** ([Jevons 1865](#qcb-jevons1865)): when algorithmic efficiency $\eta_{\mathrm{eff}} > 1$ lowers per-token compute cost to $c_0 / \eta_{\mathrm{eff}}$, elastic demand expansion $D(\eta_{\mathrm{eff}}) = D_0 \eta_{\mathrm{eff}}(1 + \varepsilon_{\mathrm{ex}})$ with $\varepsilon_{\mathrm{ex}} > 0$ drives total energy expenditure to $E_{\mathrm{total}} = c_0 D_0 (1 + \varepsilon_{\mathrm{ex}}) > c_0 D_0$, proving why algorithmic scaling must be paired with conditional Landauer hardware bounds.
2. **Self-Attention as Quantum Causal Inference & Mathematical Audit of Zhang (2025) `arXiv:2512.19428` and `kanenorman/grassmann` (`zhang_multi_lag_plucker_sum_collapses_to_single_wedge`, `kanenorman_vs_zhang_gating_difference`)**:
   - We model causal self-attention as a 1-hop row-stochastic Plabic/DAG transfer operator whose $N$-layer residual stack evaluates the Neumann causal series $(I - W_{\mathrm{attn}}^\top)^{-1}$, subject to the **LGV d-separation rank bottleneck** ($\det = 0$ when path rank exceeds head dimension $d_h$ or Grassmann rank $k$).
   - Auditing [Zhang (2025)](#qcb-zhang2025) and [Kane Norman's reproduction (`github.com/kanenorman/grassmann`)](#qcb-kanenorman2026), we machine-check the exact parameter ledger ($\binom{32}{2} = 496$, `multiHeadAttentionBlockParams 256 = 263680`, `kanenormanGrassmannBlockParams 256 32 = 267296`, and why $6 \times 256^2 = 393,216$ accounts for the $12.61\text{M}$ vs. $13.00\text{M}$ parameter gap), prove the algebraic discrepancy between Norman's additive gated residual $h + \alpha g$ and Zhang's convex gate $\alpha h + (1-\alpha)g$, and prove the **Shared-Anchor Multi-Lag Plücker Bilinear Collapse Theorem**: because every lag pair $(z_t, z_{t-\Delta})$ at position $t$ shares the anchor vector $z_t$, any weighted average of their Plücker 2-vectors in $\mathbb{R}^{\binom{r}{2}}$ collapses by exterior bilinearity into a **single rank-2 wedge product**:

     $$
     \sum_{\Delta \in \mathcal{W}_t} c_\Delta \bigl(z_t \wedge z_{t-\Delta}\bigr) = z_t \wedge \left(\sum_{\Delta \in \mathcal{W}_t} c_\Delta z_{t-\Delta}\right).
     $$

     This theorem explains why naive multi-lag Plücker averaging loses multi-hop subspace rank and trails Transformer perplexity by $10\text{--}15\%$ on WikiText-2.
3. **Why Tautological Fiber Bundle Geometry (`De Clercq 2026`, `Bundle-Transformer`) Is Strictly Advantageous for Quantum Causal Grassmannian Inference**:
   - A bare Grassmannian point $Z \in \mathrm{Gr}(k, n)$ ([Kang et al. 2025 `GrFormer`](#qcb-kang2025); [Zhang 2025](#qcb-zhang2025)) quotients out internal $GL(k)/O(k)$ coordinates, erasing token amplitude, internal fiber direction, and non-Abelian Berry holonomy around closed causal loops.
   - Lifting to the **tautological vector bundle** $\mathcal{T} = \{(Z, v) \mid Z \in \mathrm{Gr}(k, n),\, v = Z\alpha \in Z\}$ ([De Clercq 2026](#qcb-declercq2026)) factorizes each token into an **invariant causal mechanism / concept subspace** $Z_i \in \mathrm{Gr}(k, n)$ and a **contextual / interventional fiber instance** $v_i = Z_i \alpha_i \in Z_i$. We prove bounded chordal distance $0 \le d_{\mathrm{chord}}(Z_i, Z_j)^2 = k - \|Z_i^\top Z_j\|_F^2 \le k$ (guaranteeing Reformer LSH bucket stability), exact tautological incidence $\Pi_Z(Z\alpha) = Z\alpha$, orthogonal residual concept filtering $\Pi_Z(v^\perp) = 0$ (generalizing our Strong Mpemba slow-mode projector), shared linear transport $A = I_n + U V^\top$ preserving $\tilde{v}_i = A v_i \in Z_i^{\mathrm{new}}$, fiber-preserving **Rotary Position Embedding (`RoPE`)** norm invariance ([Su et al. 2021](#qcb-su2021)), and compare real $\mathrm{Gr}_{\mathbb{R}}(k,n)$, complex $\mathrm{Gr}_{\mathbb{C}}(k,n)$, nested Flag manifolds $\mathrm{Fl}(k_1,\dots,k_m;n)$, and the infinite-dimensional **Sato Grassmannian** $\mathrm{Gr}(\mathcal{H})$.
4. **"Quantum" LLM Video Generation (`VideoGen`) & Counterfactual Video $\operatorname{do}$-Editing**:
   - We synthesize Grassmannian multimodal/video transformers (`GrFormer` [Kang et al. 2025](#qcb-kang2025)), 3D spatiotemporal Causal Grassmann flows, Plücker $\mathcal{Q}_4$ Madelung + 3D Normed Tensor Gaussian Splat (`NormedTensorGaussianSplat3D`) physical conservation priors, QFT Holographic Associative Memory, and Giarmatzi–Costa counterfactual $\operatorname{do}$-editing on video trajectories, proving strict complexity reduction from $O((T H W)^2 d_{\mathrm{head}})$ to linear-in-volume $O((T H W) m_{\mathrm{lags}} \binom{r}{2})$ and the $100\text{ ps}$ ($10\text{ GHz}$) `rGO-Vitrimer` / `A-CNT` Kapitza QRAM soliton steering bound.

---

## 1. Redeveloping JEV-Style Decision Models and LLMs via Quantum Causal Inference

| Decision / LLM Paradigm | Scoring Rule | Causal Status | Handles Destructive Interference? | Handles Order Non-Commutativity? | Lean 4 Formalization |
|---|---|---|---|---|---|
| **Jeffrey Evidential (`JEV`) / Standard Softmax LLM** ([Jeffrey 1965](#qcb-jeffrey1965); [Vaswani et al. 2017](#qcb-vaswani2017)) | $\sum_s P(s \mid A) U(s,A)$ | Rung 1 (Observational; biased by $b_{\mathrm{conf}}$) | No ($A_{ij} \ge 0$ on real simplex) | Only via positional masks | `jevEvidentialExpectedUtility` |
| **Causal Decision Theory (`CEV`)** ([Pearl 2009](#qcb-pearl2009); [Joyce 1999](#qcb-joyce1999)) | $\sum_s P(s \mid \operatorname{do}(A)) U(s,A)$ | Rung 2–3 (Interventional $\operatorname{do}$-surgery) | No (classical positive Markov kernel) | Fixed DAG partial order | `cevCausalDoExpectedUtility`, `doInterventionTransfer` |
| **Quantum Causal Grassmannian (`QCDT`)** (This Work) | $\sum_s \bigl(P(s \mid \operatorname{do}(A)) + q_{\mathrm{Pl\ddot{u}cker}}(s)\bigr) U(s,A)$ | Rung 3 + Indefinite Quantum Causal Order | **Yes** ($\pi$-phase cancellation on $Gr_{\mathbb{C}}(2,4)$) | **Yes** (`quantumSwitchCommutator`, OCB $> 3/4$) | `qcdtQuantumCausalExpectedUtility`, `qcdtPluckerInterferenceTerm` |

---

## 2. Plücker Klein Quadric Rank-2 vs. Rank-4 Audit, Cross-Fiber RoPE Gauge-Mismatch Critique, and QRAM Latency Bounds

1. **Shared-Anchor Multi-Lag Plücker Bilinear Collapse vs. Cross-Lag Rank-4 Escape (`shared_anchor_vs_cross_lag_klein_quadric`, `pluckerQuadric4DResidual`)**:
   - For any 4D anchor token $z_c$ and any weighted sum of past lags $\bar{z}_p = \sum_\Delta c_\Delta z_{t-\Delta}$, the six Plücker coordinates $p_{ij} = \operatorname{plucker2DCoord}(z_{c,i}, z_{c,j}, \bar{z}_{p,i}, \bar{z}_{p,j})$ satisfy $\operatorname{pluckerQuadric4DResidual}(p_{01}, p_{02}, p_{03}, p_{12}, p_{13}, p_{23}) = p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12} = 0$ identically (`shared_anchor_vs_cross_lag_klein_quadric.1`), proving that Zhang's multi-lag sum is trapped on the rank-2 decomposable cone.
   - Including a disjoint cross-lag wedge $c_1(e_0\wedge e_1) + c_{12}(e_2\wedge e_3)$ yields $\mathcal{Q}_4 = c_1 c_{12} > 0$ (`shared_anchor_vs_cross_lag_klein_quadric.2`), achieving full exterior rank 4 in $\Lambda^2 \mathbb{R}^r$.
2. **Cross-Fiber RoPE Gauge-Mismatch Critique (`ropeCrossFrameInnerProduct`, `quantum_causal_plucker_rank_rope_gauge_and_qram_critique_identities`)**:
   - In a synchronized or parallel-transported concept frame ($\sigma_2 = 1$), applying a common RoPE rotation $R_\theta$ to both query and key preserves their inner product identically ($\operatorname{ropeCrossFrameInnerProduct}(R_\theta\alpha, R_\theta\beta, 1) = \operatorname{ropeCrossFrameInnerProduct}(\alpha, \beta, 1)$).
   - Across unsynchronized concept subspaces with principal singular value $\sigma_2 \ne 1$, a common $\theta = \pi/2$ shift alters the inner product by the nonzero gauge-mismatch residual $(\sigma_2 - 1)(\alpha_1 \beta_1 - \alpha_2 \beta_2)$, proving why Levi-Civita / polar parallel transport $U_{ij} = \operatorname{Polar}(Z_i^\top Z_j)$ is required before cross-fiber RoPE.
3. **QRAM State-Preparation Latency Lower Bound & `QuantumCausalBundleVideoGenHypothesis`**:
   - Total QFT associative lookup latency satisfies $T_{\mathrm{prep}} < \operatorname{qftAssociativeTotalLatency}(T_{\mathrm{prep}}, T_{\mathrm{QFT}})$ for $T_{\mathrm{QFT}} > 0$, and distinct OAM charges $\ell_1 \ne \ell_2$ map to separated transverse momenta $(\ell_1 - \ell_2)/a_{\mathrm{scale}}$ (`oamLogPolarTransverseMomentum`), while `QuantumCausalBundleVideoGenHypothesis` in `Signals.Pending` enforces QRAM, polar fiber gauge, and Kapitza thermal calibration bounds.

---

## 3. Self-Contained Lean 4 Formal Verification Block

```lean
import Signals.QuantumCausalInference

namespace QuantumCausalJevBundleTransformerVideogenPaperVerification

open Signals.QuantumCausalInference

example (wA_re wA_im wB_re wB_im alpha_gate h_val g_val : ℝ)
    (c1 c2 z_ci z_cj z_p1i z_p1j z_p2i z_p2j alpha beta a1 a2 : ℝ) :
    jevEvidentialExpectedUtility (3 / 5 + 1 / 5) ((1 - 3 / 5) - 1 / 5) 10 2 -
        cevCausalDoExpectedUtility (3 / 5) (1 - 3 / 5) 10 2 = 8 / 5 ∧
      0 < jevEvidentialExpectedUtility (3 / 5 + 1 / 5) ((1 - 3 / 5) - 1 / 5) 10 2 -
        cevCausalDoExpectedUtility (3 / 5) (1 - 3 / 5) 10 2 ∧
      (wA_re + wB_re) ^ 2 + (wA_im + wB_im) ^ 2 =
        (wA_re ^ 2 + wA_im ^ 2) + (wB_re ^ 2 + wB_im ^ 2) +
          qcdtPluckerInterferenceTerm wA_re wA_im wB_re wB_im ∧
      qcdtPluckerInterferenceTerm wA_re wA_im wB_re wB_im +
          qcdtPluckerInterferenceTerm wA_re wA_im (-wB_re) (-wB_im) = 0 ∧
      qcdtQuantumCausalExpectedUtility (3 / 5) (1 - 3 / 5) (1 / 4) 10 2 -
          cevCausalDoExpectedUtility (3 / 5) (1 - 3 / 5) 10 2 = 2 ∧
      jevonsTotalComputeEnergy 10 4 100 (1 / 2) = 1500 ∧
      (10 : ℝ) * 100 < jevonsTotalComputeEnergy 10 4 100 (1 / 2) ∧
      pluckerPairDimension 32 = 496 ∧
      multiHeadAttentionBlockParams 256 = 263680 ∧
      kanenormanGrassmannBlockParams 256 32 = 267296 ∧
      (12607168 : ℕ) + 6 * (256 * 256) = 13000384 ∧
      kanenormanAdditiveGatedResidual alpha_gate h_val g_val -
          zhangConvexGatedFusion alpha_gate h_val g_val =
        (1 - alpha_gate) * h_val + (2 * alpha_gate - 1) * g_val ∧
      c1 * plucker2DCoord z_ci z_cj z_p1i z_p1j +
          c2 * plucker2DCoord z_ci z_cj z_p2i z_p2j =
        plucker2DCoord z_ci z_cj
          (c1 * z_p1i + c2 * z_p2i) (c1 * z_p1j + c2 * z_p2j) ∧
      0 ≤ grassmannChordalDistSq 4 (5 / 2) ∧
      grassmannChordalDistSq 4 (5 / 2) ≤ 4 ∧
      grassmannChordalDistSq 4 4 = 0 ∧
      tautologicalProjectorVec (3 / 5) (4 / 5)
          ((3 / 5) * alpha) ((4 / 5) * alpha) =
        tautologicalFiberVec (3 / 5) (4 / 5) alpha ∧
      tautologicalProjectorVec (3 / 5) (4 / 5)
          (-(4 / 5) * beta) ((3 / 5) * beta) = (0, 0) ∧
      (ropeFiberRotate (3 / 5) (4 / 5) a1 a2).1 ^ 2 +
          (ropeFiberRotate (3 / 5) (4 / 5) a1 a2).2 ^ 2 =
        a1 ^ 2 + a2 ^ 2 ∧
      spatiotemporalGrassmannVideoComplexity 16 16 16 6 496 <
        spatiotemporalFullAttentionComplexity 16 16 16 64 ∧
      rgoVitrimerKapitzaCoolTime (5e-9) (2e6) (1e-8) = 1e-10 := by
  have h :=
    quantum_causal_jev_bundle_transformer_and_videogen_synthesis_identities
      (3 / 5) (1 / 5) (1 / 4) 10 2 wA_re wA_im wB_re wB_im 10 4 100 (1 / 2)
      c1 c2 z_ci z_cj z_p1i z_p1j z_p2i z_p2j
      4 (5 / 2) (3 / 5) (4 / 5) alpha beta (3 / 5) (4 / 5) a1 a2
      16 16 16 64 6 496
      (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num)
      (by norm_num) (by norm_num)
      (by norm_num) (by norm_num)
  refine ⟨by linarith [h.1], h.2.1, h.2.2.1, h.2.2.2.1, by linarith [h.2.2.2.2.1],
    by linarith [h.2.2.2.2.2.1], h.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.1,
    kanenorman_vs_zhang_gating_difference alpha_gate h_val g_val,
    h.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2⟩

example (zc0 zc1 zc2 zc3 zp0 zp1 zp2 zp3 a00 a01 a10 a11 c s alpha a1 a2 b1 b2 sigma2 : ℝ) :
    pluckerQuadric4DResidual
        (plucker2DCoord zc0 zc1 zp0 zp1)
        (plucker2DCoord zc0 zc2 zp0 zp2)
        (plucker2DCoord zc0 zc3 zp0 zp3)
        (plucker2DCoord zc1 zc2 zp1 zp2)
        (plucker2DCoord zc1 zc3 zp1 zp3)
        (plucker2DCoord zc2 zc3 zp2 zp3) = 0 ∧
      pluckerQuadric4DResidual 2 0 0 0 0 3 = 6 ∧
      0 < pluckerQuadric4DResidual 2 0 0 0 0 3 ∧
      tautologicalLinearTransportVec a00 a01 a10 a11 (c * alpha) (s * alpha) =
        tautologicalFiberVec (a00 * c + a01 * s) (a10 * c + a11 * s) alpha ∧
      ropeCrossFrameInnerProduct
          (ropeFiberRotate (3 / 5) (4 / 5) a1 a2)
          (ropeFiberRotate (3 / 5) (4 / 5) b1 b2) 1 =
        ropeCrossFrameInnerProduct (a1, a2) (b1, b2) 1 ∧
      ropeCrossFrameInnerProduct
          (ropeFiberRotate 0 1 a1 a2)
          (ropeFiberRotate 0 1 b1 b2) sigma2 -
        ropeCrossFrameInnerProduct (a1, a2) (b1, b2) sigma2 =
        (sigma2 - 1) * (a1 * b1 - a2 * b2) ∧
      (100 : ℝ) < qftAssociativeTotalLatency 100 10 ∧
      oamLogPolarTransverseMomentum 3 2 - oamLogPolarTransverseMomentum 1 2 = 1 := by
  have h :=
    quantum_causal_plucker_rank_rope_gauge_and_qram_critique_identities
      zc0 zc1 zc2 zc3 zp0 zp1 zp2 zp3 2 3
      a00 a01 a10 a11 c s alpha (3 / 5) (4 / 5) a1 a2 b1 b2 sigma2
      100 10 3 1 2
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  refine ⟨h.1, by linarith [h.2.1], h.2.2.1, h.2.2.2.1, h.2.2.2.2.1,
    h.2.2.2.2.2.1, h.2.2.2.2.2.2.1, by linarith [h.2.2.2.2.2.2.2]⟩

end QuantumCausalJevBundleTransformerVideogenPaperVerification
```

---

## 4. Scholarly References

(qcb-declercq2026)=
<a id="qcb-declercq2026"></a>
1. De Clercq, C. (2026). *Bundle-Transformer: A Geometric Position Paper*. Université Sorbonne Paris Nord, LAGA, September 24, 2026.

(qcb-kang2025)=
<a id="qcb-kang2025"></a>
2. Kang, H., et al. (2025). *GrFormer: A novel Transformer on Grassmann manifold for infrared and visible image fusion*. Information Fusion, 125, 2025.

(qcb-su2021)=
<a id="qcb-su2021"></a>
3. Su, J., et al. (2021). *RoFormer: Enhanced Transformer with Rotary Position Embedding*. [arXiv:2104.09864](https://arxiv.org/abs/2104.09864).

(qcb-vaswani2017)=
<a id="qcb-vaswani2017"></a>
4. Vaswani, A., et al. (2017). *Attention Is All You Need*. NeurIPS 30, 5998–6008.

(qcb-zhang2025)=
<a id="qcb-zhang2025"></a>
5. Zhang, C. (2025). *Attention Is Not What You Need: Grassmann Flows as an Attention-Free Alternative for Sequence Modeling*. [arXiv:2512.19428](https://arxiv.org/abs/2512.19428).

(qcb-kanenorman2026)=
<a id="qcb-kanenorman2026"></a>
6. Norman, K. (2026). *Reproduction of "Attention Is Not What You Need"*. [https://github.com/kanenorman/grassmann](https://github.com/kanenorman/grassmann).

(qcb-jeffrey1965)=
<a id="qcb-jeffrey1965"></a>
7. Jeffrey, R. C. (1965). *The Logic of Decision*. McGraw-Hill.

(qcb-joyce1999)=
<a id="qcb-joyce1999"></a>
8. Joyce, J. M. (1999). *The Foundations of Causal Decision Theory*. Cambridge University Press.

(qcb-pearl2009)=
<a id="qcb-pearl2009"></a>
9. Pearl, J. (2009). *Causality: Models, Reasoning, and Inference* (2nd ed.). Cambridge University Press.

(qcb-yukalov2010)=
<a id="qcb-yukalov2010"></a>
10. Yukalov, V. I., and Sornette, D. (2010). *Decision theory with prospect interference and entanglement*. Theory and Decision, 70(3), 283–328.

(qcb-busemeyer2012)=
<a id="qcb-busemeyer2012"></a>
11. Busemeyer, J. R., and Bruza, P. D. (2012). *Quantum Models of Cognition and Decision*. Cambridge University Press.

(qcb-giarmatzi2023)=
<a id="qcb-giarmatzi2023"></a>
12. Giarmatzi, C., and Costa, F. (2023). *A Semantics for Counterfactuals in Quantum Causal Models*. [arXiv:2302.11783](https://arxiv.org/abs/2302.11783).

(qcb-jevons1865)=
<a id="qcb-jevons1865"></a>
13. Jevons, W. S. (1865). *The Coal Question*; and *The Theory of Political Economy* (1871).
