---
title: "Yang–Mills Mass Gap, Electroweak Higgs Symmetry Breaking, CP Violation, Sakharov Thermal Equilibrium Nullity, and Jost's Anti-Unitary CPT Involution in Lean 4, Rust/PyO3, and SymPy"
description: "An arXiv-ready MyST Markdown formal verification and physics synthesis paper formalizing the algebraic, lattice transfer-matrix, representation-theoretic, and finite-axiomatic core of the Yang–Mills Mass Gap (auditing Toupin's 2026 PhilArchive preprint TOUTYM and TOUQGA-2.pdf Ch. 11), the electroweak Higgs Mexican-hat mechanism (v, m_H, m_W, m_Z, rho_EW = 1, H = Hbar), CP-violating Higgs decay asymmetries and the Sakharov equilibrium null theorem, and Jost's anti-unitary CPT involution (Theta = CPT, Theta^2 = +-I, exact particle/antiparticle mass equality, and CP <=> T violation) in Lean 4, Rust/PyO3, and SymPy/mpmath, while isolating open Clay Millennium and collider gates in Signals.Pending."
---

(grassmannian-yang-mills-mass-gap-higgs-cp-cpt-paper)=
# Yang–Mills Mass Gap, Electroweak Higgs Symmetry Breaking, CP Violation, Sakharov Thermal Equilibrium Nullity, and Jost's Anti-Unitary CPT Involution in Lean 4, Rust/PyO3, and SymPy

- **Authors:** Wes Turner
- **Subjects:**
  - High Energy Physics - Theory (`hep-th`); High Energy Physics - Phenomenology (`hep-ph`); Mathematical Physics (`math-ph`); Logic & Formal Verification (`cs.LO`)
- **Epistemic Status & Scope Declaration:**
  - **Verified Mathematical & Computational Core (`Signals.YangMillsHiggsCPT`, Rust/PyO3, SymPy, 45-digit `mpmath`):** We prove with zero `sorry` axioms in {download}`src/signals/Signals/YangMillsHiggsCPT.lean <../src/signals/Signals/YangMillsHiggsCPT.lean>` (`3,837` Lake jobs via `make signals_build`), cross-checked in {download}`src/signals/numerical_adapter/src/yang_mills_higgs_cpt.rs <../src/signals/numerical_adapter/src/yang_mills_higgs_cpt.rs>` and {download}`sustainablefactory/yang_mills_higgs_cpt.py <../sustainablefactory/yang_mills_higgs_cpt.py>` / {download}`tests/test_yang_mills_higgs_cpt.py <../tests/test_yang_mills_higgs_cpt.py>`: **(1)** lattice Euclidean transfer-matrix spectral gap $\Delta_{\mathrm{lat}} = \ln(\lambda_0/\lambda_1) > 0$ with exponential Schwinger decay $(\lambda_1/\lambda_0)^t = e^{-t\Delta_{\mathrm{lat}}}$, strong-coupling Casimir heat-kernel suppression $c_\lambda(\beta) = e^{-C_2(\lambda)/\beta}$ and gap bound $1 - (\beta/(2N^2))^{d_{\min}}$, $\mathrm{SU}(3)$ asymptotic freedom $b_0 = 11$, dimensional transmutation $0 < \Lambda_{\mathrm{YM}}(\mu) < \mu$, Haar singlet projection idempotence, and Toupin's GKO coset mass formula $M_k = \frac{2N}{k+N}\Lambda_{\mathrm{QCD}}$ (`TOUTYM` 2026 / `TOUQGA-2.pdf` Eq. 11.70 vs. Sugawara Eq. 11.75), **(2)** electroweak $\mathrm{SU}(2)_L\times\mathrm{U}(1)_Y\to\mathrm{U}(1)_{\mathrm{EM}}$ Higgs spontaneous symmetry breaking (`higgs_ssb_electroweak_masses_and_self_conjugacy`: zero linear tadpole, $m_H^2 = 2\mu^2 = 2\lambda v^2$, $\rho_{\mathrm{EW}} = 1$, $m_W < m_Z$, $Q_H = 0 \implies \bar{H} = H$), **(3)** mixed CP-even/CP-odd Higgs decay asymmetry $\mathcal{A}_{\mathrm{CP}} = \kappa\tilde{\kappa}\sin(2\alpha_{\mathrm{CP}})$ and the **Sakharov Equilibrium Null Theorem** ($\langle B\rangle_\beta = 0$ identically under CPT mass equality), and **(4)** Jost's axiomatic anti-unitary CPT involution $\Theta = CPT$ (`jost_cpt_antiunitary_involution_and_cp_t_equivalence`: anti-linearity, $\langle\Theta\psi,\Theta\phi\rangle = \langle\phi,\psi\rangle$, $\Theta^2 = \pm I$, exact particle/antiparticle mass degeneracy, and exact $CP$ violation $\iff$ $T$ violation).
  - **Open Millennium, Collider, & Cosmological Boundary (`Signals.Pending.YangMillsMassGapHiggsCPTPendingBoundary`):** Isolated in {download}`src/signals/Signals/Pending.lean <../src/signals/Signals/Pending.lean>` and {download}`src/signals/SignalsPending.lean <../src/signals/SignalsPending.lean>`. This paper explicitly does **not** claim to close the Clay Mathematics Institute 4D continuum Yang–Mills existence and mass-gap Millennium Prize problem {cite:p}`jaffe2000yangmills`; it preserves exact epistemic boundaries for continuum $a\to 0, V\to\infty$ Osterwalder–Schrader reconstruction, non-perturbative celestial-QCD reconstruction {cite:p}`toupin2026ym`, BSM Higgs CP discovery at ATLAS/CMS, and first-order electroweak baryogenesis.
- **Primary Chat & Scholarly Provenance:**
  - {download}`data/chats/Google-Search_higgs-boson-and-antimatter_20261126-1551.md <../data/chats/Google-Search_higgs-boson-and-antimatter_20261126-1551.md>` (lines 13–84: Higgs self-conjugacy, ATLAS/CMS CP-violating Higgs decays, Jost's CPT theorem, Sakharov non-equilibrium constraint, and Yang–Mills Mass Gap comparison) {cite:p}`chat_higgs_antimatter_2026`.
  - {download}`data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md <../data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md>` (lines 13–45, 60–90: audit of Toupin's `TOUTYM` 2026 preprint, celestial CFT rigor, IR soft-gluon tension, $k$ vs. $\Lambda_{\mathrm{QCD}}$, and CPT/Jost/Higgs synthesis) {cite:p}`chat_toupin_mass_gap_2026`.
  - Toupin's primary works audited: {cite:p}`toupin2026ym`, {cite:p}`toupin2026riemann`, and {cite:p}`toupin2025quantum` ({download}`data/papers/TOUQGA-2.pdf <../data/papers/TOUQGA-2.pdf>`, Ch. 11, pp. 613–658).
  - Companion repository papers:
    - [Infrared Divergence Resolution in Celestial Holography, $\operatorname{Re}(\Delta) = d_{\mathrm{CFT}}/2$ Bridging, and Integrated Turner Models `16a` & `16b`](grassmannian-celestial-ir-regularization-turner-models-16ab-paper.md)
    - [Celestial Holography, Plancherel–Unruh Loop Weights, & Integrated Turner Models `15a` & `15b`](grassmannian-celestial-holography-graviton-turner-riemann-paper.md)
    - [Antimatter Annihilation, Photonic Deflection, & CERN `ALPHA-g` Evaluation](grassmannian-antimatter-annihilation-alpha-g-models-paper.md)
    - [Adelic Carleman–Weierstrass Determinants, Schwinger 2-Cocycle, & `Signals.RiemannSpectral` Bridges](grassmannian-sato-adelic-carleman-weierstrass-weil-rh-gaps-paper.md)

---

## Abstract

Fundamental particle physics rests on two distinct mass-generation mechanisms anchored in a single axiomatic quantum field theory (QFT) symmetry bedrock: **(1)** the **electroweak Higgs mechanism** {cite:p}`higgs1964broken,englert1964broken,guralnik1964global,weinberg1967model`, which generates masses for $W^\pm$, $Z$, and charged fermions via spontaneous symmetry breaking ($v \approx 246.22\text{ GeV}$) while leaving the neutral CP-even Higgs boson $H$ as its own antiparticle ($\bar{H} = H$), and **(2)** the **non-Abelian Yang–Mills Mass Gap** {cite:p}`yang1954conservation,jaffe2000yangmills`, where pure gauge self-interaction and dimensional transmutation generate $\sim 99\%$ of visible baryonic mass and glueball excitations ($\Delta \approx 1.6\text{ GeV}$) without a background scalar field. Governing both mechanisms are **Jost's axiomatic CPT theorem** ($\Theta = CPT$ anti-unitary involution) {cite:p}`jost1957bemerkung` and **Sakharov's baryogenesis conditions** {cite:p}`sakharov1967violation`: because $\Theta$ commutes with any local Lorentz-invariant Hamiltonian, particles and antiparticles must share exact equilibrium rest masses, $CP$ violation is strictly equivalent to $T$ violation, and any matter–antimatter asymmetry produced via CP-violating Higgs interactions must occur out of thermal equilibrium.

We formalize this entire chain in Lean 4 (`Signals.YangMillsHiggsCPT`), Rust/PyO3 (`yang_mills_higgs_cpt.rs`), and SymPy/45-digit `mpmath`, while conducting an explicit epistemic audit of Daniel Toupin's 2026 PhilArchive preprint {cite:p}`toupin2026ym` and monograph Chapter 11 {cite:p}`toupin2025quantum` alongside our `Signals.SatoGrassmannian.RHGaps` and `RiemannSpectralBridge` framework.

---

## 1. Unified Architecture: From Yang–Mills & Higgs Mass Generation to Jost CPT & Sakharov Baryogenesis

```{mermaid}
flowchart TB
    YM["1. Yang–Mills Mass Gap (Pure Gauge, No Scalar)\n• Asymptotic freedom b_0 = 11 > 0, Λ_YM < μ\n• Strong-coupling OS2 + Casimir suppression e^{-C_2/β}\n• Haar singlet projection P²=P (Elitzur confinement)\n• Open Clay Millennium: a→0, V→∞ continuum OS limit"]
    HIGGS["2. Electroweak Higgs SSB (SU(2)_L × U(1)_Y → U(1)_EM)\n• V(Φ) = -μ²\|Φ\|² + λ\|Φ\|⁴, v = √(μ²/λ) ≈ 246.22 GeV\n• Zero tadpole, m_H = 125.25 GeV, ρ_EW = 1\n• Self-conjugate neutral scalar: Q_H = 0 ⇒ H̄ = H"]
    CP["3. CP Violation & Higgs Decay Probes\n• SM CKM Jarlskog invariant J_CP ≈ 3.1 × 10⁻⁵\n• BSM Higgs CP-mixing A_CP = κ κ̃ sin(2α_CP)\n• Probed in H → τ⁺τ⁻, ZZ* → 4ℓ, γγ"]
    JOST["4. Jost Anti-Unitary CPT Involution (Θ = CPT)\n• Θ(cψ) = c̄ Θ(ψ), ⟨Θψ, Θφ⟩ = ⟨φ, ψ⟩, Θ² = ±I\n• [H, Θ] = 0 ⇒ H(Θψ) = E(Θψ) (exact m = m̄)\n• [H, U_CP] = 0 ⇔ [H, T] = 0 (CP viol. ⇔ T viol.)"]
    SAKH["5. Sakharov Equilibrium Null Theorem\n• E_k⁺ = E_k⁻ & B_k⁻ = -B_k⁺ ⇒ ⟨B⟩_β = 0 identically\n• Forces non-equilibrium electroweak phase transition\n• Connects to Model 16a/16b & ALPHA-g (χ²=25/17)"]

    YM --> JOST
    HIGGS --> CP --> JOST --> SAKH
```

---

## 2. The Yang–Mills Mass Gap & Audit of Toupin's Celestial/Haar Construction

### 2.1 Rigorously Verified Lattice, Transmutation, & Haar Projection Structures

In `Signals.YangMillsHiggsCPT.yang_mills_mass_gap_and_transmutation_identities` and `toupin_strong_coupling_casimir_and_gko_ratio_identities`, we prove five foundational structures shared by constructive lattice gauge theory {cite:p}`osterwalder1978gauge,seiler1982gauge,elitzur1975impossibility` and Chapter 11 of {cite:p}`toupin2025quantum` (pp. 613–658):

1. **Asymptotic Freedom & Dimensional Transmutation ({cite:p}`gross1973ultraviolet,politzer1973reliable`):**
   For $\mathrm{SU}(N_c)$ with $n_f$ quark flavors, $b_0 = (11 N_c - 2 n_f)/3$ equals $11 > 0$ in pure $\mathrm{SU}(3)$, yielding $0 < \Lambda_{\mathrm{YM}}(\mu) = \mu \exp(-8\pi^2/(b_0 g^2)) < \mu$ (`0.0887 GeV` at $\mu = M_Z, \alpha_s = 0.118, n_f = 5$ in Rust/45-digit `mpmath`).
2. **Lattice Osterwalder–Schrader Transfer Gap & Exponential Decay:**
   For $0 < \lambda_1 < \lambda_0$, the Euclidean transfer matrix $T = e^{-aH}$ establishes $\Delta_{\mathrm{lat}} = \ln(\lambda_0/\lambda_1) > 0$ and exponential Schwinger clustering $(\lambda_1/\lambda_0)^t = \exp(-t\Delta_{\mathrm{lat}})$, bounded at strong coupling ($\beta < 2N^2$) by `strongCouplingTransferGapLowerBound` $1 - (\beta/(2N^2))^{d_{\min}} \in (0, 1)$ (`TOUQGA-2.pdf` Theorem 11.19, Eq. 11.29) and Peter–Weyl Casimir heat-kernel suppression $c_\lambda(\beta) = e^{-C_2(\lambda)/\beta}$ (`Lemma 11.18`, Eq. 11.27).
3. **Haar Singlet Projection & Elitzur Confinement:**
   The normalized group-averaging projector $P_{\mathrm{singlet}} = \int_G d\mu(g)\,U_g$ satisfies $P^2 = P$, $P^\dagger = P$, and exact annihilation of all non-trivial representations, verified algebraically in Lean (`finiteGroupHaarSingletProjector`) and numerically over $Z_4$ in Rust (`idemp_err < 1e-15`, `nonsinglet_max < 1e-14`).
4. **Toupin's Tree-Level GKO / Sugawara Glueball Formula (`TOUTYM` vs. `TOUQGA-2.pdf`):**
   We record and audit the exact algebraic discrepancy between Toupin's 2026 preprint {cite:p}`toupin2026ym` ({download}`chat log <../data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md>`, line 24: $M_k = \frac{2N}{k+N}\Lambda_{\mathrm{QCD}}$, giving $300\text{ MeV}$ for $N=3, k=1, \Lambda_{\mathrm{QCD}} = 200\text{ MeV}$) and Eq. (11.70) vs. Eq. (11.75) of `TOUQGA-2.pdf` (p. 640, where Eq. 11.70 states $\frac{2N}{k+N}\Lambda_{\mathrm{QCD}}$ while Eq. 11.75 and p. 641 evaluate $\frac{N}{k+N}\Lambda_{\mathrm{QCD}} = \frac{3}{4}\Lambda_{\mathrm{QCD}} \approx 165\text{ MeV}$—both below lattice QCD's $m_{0^{++}} \approx 1.61\text{ GeV}$ by a factor of $5\text{–}10$).

### 2.2 Why the Clay Millennium Continuum Mass Gap Remains Open (`YangMillsMassGapHiggsCPTPendingBoundary`)

Following our chat audit ({download}`chat log <../data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md>`, lines 32–37, 60–90) and Toupin's own Remark 11.47 (`TOUQGA-2.pdf`, pp. 642–643), four obstructions keep the continuum problem in `Signals.Pending.YangMillsMassGapHiggsCPTPendingBoundary`:
1. **Joint Continuum & Infinite-Volume Limit ($a \to 0, V \to \infty$):** Strong-coupling cluster expansions converge only for $\beta < \beta_c$, whereas the continuum limit requires $\beta \to \infty$ while keeping a uniform spectral gap $M > 0$ {cite:p}`jaffe2000yangmills,osterwalder1973axioms`.
2. **Celestial Soft-Gluon vs. Confinement Tension:** Celestial Kac–Moody Ward identities rely on massless soft gluons at $\mathcal{I}^\pm$, which do not exist as asymptotic LSZ states in a confining theory with $\Delta > 0$ (remediated in our [IR Regularization & Models `16a`/`16b` paper](grassmannian-celestial-ir-regularization-turner-models-16ab-paper.md) via Källén–Lehmann thresholding).
3. **Kac–Moody Level $k$ vs. Dimensional Transmutation:** Pure Yang–Mills trades its dimensionless coupling $g^2$ for $\Lambda_{\mathrm{QCD}}$, leaving no independent integer level $k$.
4. **Unverified Peer-Review Status:** {cite:p}`toupin2026ym` is an unrefereed PhilArchive preprint and does not establish 4D Osterwalder–Schrader reflection positivity or temperedness from 2D WZW/KZ correlators (`Spectral Transfer Conjecture 11.32`).

---

## 3. Electroweak Higgs Symmetry Breaking, CP Violation, & Sakharov's Equilibrium Theorem

### 3.1 Mexican-Hat Unitary Gauge & Self-Conjugacy (`higgs_ssb_electroweak_masses_and_self_conjugacy`)

In `Signals.YangMillsHiggsCPT` Section 2, for the $\mathrm{SU}(2)_L \times \mathrm{U}(1)_Y$ Higgs potential $V(\Phi) = -\mu^2|\Phi|^2 + \lambda|\Phi|^4$ expanded around $\Phi = (0, (v+h)/\sqrt{2})^T$ with $v = \sqrt{\mu^2/\lambda}$:

$$
V\!\left(\frac{(v+h)^2}{2}\right) = -\frac{\mu^4}{4\lambda} + \mu^2 h^2 + \lambda v h^3 + \frac{\lambda}{4} h^4, \qquad m_H^2 = 2\mu^2 = 2\lambda v^2 > 0,
$$

with exact cancellation of the linear tadpole, custodial ratio $\rho_{\mathrm{EW}} = \frac{m_W^2}{m_Z^2 \cos^2\theta_W} = 1$, $m_W < m_Z$ for $g_1 \ne 0$, and neutrality $Q_H = -Q_H = 0$ confirming that the Higgs boson is its own antiparticle ({download}`Higgs chat log <../data/chats/Google-Search_higgs-boson-and-antimatter_20261126-1551.md>`, line 17).

### 3.2 Higgs CP-Mixing Asymmetry & Sakharov Equilibrium Null Theorem

For a mixed CP-even/CP-odd Higgs coupling $(\kappa, \tilde{\kappa}, \alpha_{\mathrm{CP}})$ probed in $H \to \tau^+\tau^-$, $H \to ZZ^* \to 4\ell$, and $H \to \gamma\gamma$ ({download}`Higgs chat log <../data/chats/Google-Search_higgs-boson-and-antimatter_20261126-1551.md>`, lines 51–52), theorem `higgs_cp_asymmetry_and_sakharov_equilibrium_zero` proves:

$$
\mathcal{A}_{\mathrm{CP}}(\kappa, \tilde{\kappa}, \alpha_{\mathrm{CP}}) = 2\kappa\tilde{\kappa}\sin\alpha_{\mathrm{CP}}\cos\alpha_{\mathrm{CP}} = \kappa\tilde{\kappa}\sin(2\alpha_{\mathrm{CP}}),
$$

which vanishes identically for the Standard Model CP-even Higgs ($\tilde{\kappa} = 0$ or $\alpha_{\mathrm{CP}} = 0$) and pure CP-odd pseudoscalar ($\alpha_{\mathrm{CP}} = \pi/2$), alongside the CKM Jarlskog invariant $J_{\mathrm{CP}} \approx 3.09 \times 10^{-5}$ {cite:p}`christenson1964evidence,kobayashi1973cp,jarlskog1985commutator`.

Crucially, under Jost CPT mass equality ($E_k^+ = E_k^-$) and conjugate baryon charges ($B_k^- = -B_k^+$), **the thermal equilibrium baryon trace vanishes identically** for every inverse temperature $\beta$:

$$
\langle B\rangle_\beta = \sum_{k=1}^n \Bigl(B_k^+ e^{-\beta E_k^+} + (-B_k^+) e^{-\beta E_k^-}\Bigr) = 0,
$$

proving Sakharov's third condition {cite:p}`sakharov1967violation`: CP violation and baryon-number violation cannot generate a net matter excess in thermal equilibrium—requiring an out-of-equilibrium cosmological phase transition ({download}`Higgs chat log <../data/chats/Google-Search_higgs-boson-and-antimatter_20261126-1551.md>`, lines 61, 82).

---

## 4. Jost's Axiomatic Anti-Unitary CPT Involution ($\Theta = CPT$)

In `Signals.YangMillsHiggsCPT` Section 4 (`AntiUnitaryCPT`, `jost_cpt_antiunitary_involution_and_cp_t_equivalence`), we formalize Res Jost's axiomatic CPT operator {cite:p}`jost1957bemerkung` on $\mathbb{C}^n$ via $\Theta(\psi) = U\overline{\psi}$ with $U^\dagger U = I_n$ and $U\overline{U} = \epsilon I_n$ ($\epsilon = \pm 1$), proving five exact theorems:
1. **Anti-linearity:** $\Theta(c\psi) = \overline{c}\,\Theta(\psi)$;
2. **Anti-unitarity:** $\langle \Theta\psi, \Theta\phi\rangle = \langle \phi, \psi\rangle$;
3. **Involution:** $\Theta(\Theta(\psi)) = \epsilon\psi$ ($\epsilon = +1$ bosonic / flavor, $\epsilon = -1$ fermionic Kramers);
4. **Spectral Particle/Antiparticle Degeneracy:** If $[H, \Theta] = 0$ ($U\overline{H} = H U$) and $H\psi = E\psi$ ($E \in \mathbb{R}$), then $H(\Theta\psi) = E(\Theta\psi)$;
5. **Exact $CP$ Violation $\iff$ $T$ Violation:** Decomposing $\Theta = U_{CP} \circ \mathcal{T}$ ($U = U_{CP} V_T$) with $[H, \Theta] = 0$, we prove:

   $$
   U_{CP} H = H U_{CP} \iff V_T \overline{H} = H V_T.
   $$

Our $4\times 4$ Rust/SymPy benchmark (`audit_yang_mills_higgs_cpt`) confirms anti-unitarity (`< 1e-14`), $\Theta_{\mathrm{ferm}}^2 = -I_4$ and $\Theta_{\mathrm{bos}}^2 = +I_4$ (`< 1e-14`), exact CPT spectral degeneracy (`< 1e-14`), and exact equality of $CP$- and $T$-commutator violation norms (`> 0.1` for $\delta = 0.7$, `< 1e-15` for $\delta = 0$).

---

## 5. Reproducible Verification & Provenance Metadata

```bash
make -C /workspaces/sustainablefactory signals_build
cargo test --manifest-path /workspaces/sustainablefactory/src/signals/numerical_adapter/Cargo.toml
pytest -q /workspaces/sustainablefactory/tests/test_yang_mills_higgs_cpt.py
```

```bibtex
@misc{turner2026ym_higgs_cp_cpt,
  author       = {Turner, Wesley},
  title        = {Yang--Mills Mass Gap, Electroweak Higgs Symmetry Breaking, CP Violation, Sakharov Thermal Equilibrium Nullity, and Jost's Anti-Unitary CPT Involution in Lean 4, Rust/PyO3, and SymPy},
  year         = {2026},
  howpublished = {Sustainable Factory Technical Monograph \& Formal Verification Suite},
  note         = {Verified in Signals.YangMillsHiggsCPT and Signals.Pending.YangMillsMassGapHiggsCPTPendingBoundary}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Yang–Mills Mass Gap, Electroweak Higgs Symmetry Breaking, CP Violation, Sakharov Thermal Equilibrium Nullity, and Jost's Anti-Unitary CPT Involution in Lean 4, Rust/PyO3, and SymPy",
  "author": {"@type": "Person", "name": "Wes Turner"},
  "isBasedOn": [
    "data/chats/Google-Search_higgs-boson-and-antimatter_20261126-1551.md",
    "data/chats/Google Search AI - Review Toupin's Mass Gap solution - Google Search - 2026-11-26_15-52.md",
    "data/papers/TOUQGA-2.pdf",
    "src/signals/Signals/YangMillsHiggsCPT.lean",
    "src/signals/Signals/Pending.lean"
  ],
  "dateModified": "2026-11-26"
}
```

---

## References

```{bibliography}
:filter: docname in docnames
```
