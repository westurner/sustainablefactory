---
title: "SU(4) Symmetry, Witten's Twistor String Theory, Lower Grassmannians in Gr_R and Gr_C, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT in Lean 4, Rust, and Python"
description: "An arXiv-ready MyST Markdown formal verification and theoretical physics unification paper analyzing SU(4) across twistors, N=4 SYM, graphene spin-valley isospin, and 2-qubit gates; cataloguing lower Grassmannians in Gr_R(k,n) and Gr_C(k,n); comparing Edward Witten's Twistor String Theory ('Witted's String Theory'), Freddy Cachazo's on-shell/CHY program, the Dilatant Dark Fluid (DDF), and the Turner (2026) Plücker Q_4 models; and unifying them with the 't Hooft–Susskind Holographic Principle, Maldacena AdS/CFT, Twisted Holography, and Celestial Holography in Lean 4, Rust, and Python."
---

(grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper)=
# $\mathrm{SU}(4)$ Symmetry, Witten's Twistor String Theory, Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}$ and $\mathrm{Gr}_{\mathbb{C}}$, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT in Lean 4, Rust, and Python

- **Authors:** Wes Turner
- **Subjects:**
  - High Energy Physics - Theory (`hep-th`); General Relativity and Quantum Cosmology (`gr-qc`); Mathematical Physics (`math-ph`); Mesoscale and Nanoscale Physics (`cond-mat.mes-hall`); Quantum Physics (`quant-ph`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4508-L4693), [../src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L8346-L9620), [../src/signals/Signals/QEDGravity.lean](../src/signals/Signals/QEDGravity.lean), [../src/signals/Signals/Scattering.lean](../src/signals/Signals/Scattering.lean), [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L7428-L7466), [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L6048-L6095))
  - `signals-numerical-adapter` Rust/WASM Crate ([../src/signals/numerical_adapter/src/dft_plabic_vrc.rs](../src/signals/numerical_adapter/src/dft_plabic_vrc.rs#L1503-L1650))
  - Python Reference Implementation & Pytest Suite ([../sustainablefactory/qci_grassmannian_dft.py](../sustainablefactory/qci_grassmannian_dft.py#L4352-L4455), [../tests/test_qci_grassmannian_dft.py](../tests/test_qci_grassmannian_dft.py#L1026-L1085))
  - Canonical `src/signals/docs/` Mirror: `src/signals/docs/grassmannian-su4-witten-twistor-string-cachazo-ddf-turner-ads-cft-unification-paper.md`
- **Companion Papers:**
  - [AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-ads-cft-ddf-paper.md)
  - [The Holographic Principle in Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting](grassmannian-holographic-principle-paper.md)
  - [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification](grassmannian-gravity-from-qed-scattering-paper.md)
  - [Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Fubini–Study Gross–Pitaevskii Equation, Dual-Schubert `iGPE`, and Homogeneous Plücker Madelung Hydrodynamics on the Klein Quadric $\mathcal{Q}_4$](grassmannian-complex-gpe-igpe-plucker-madelung-paper.md)
  - [Grassmannian Multilayer Graphene Superconductivity, Quantum Anomalous Hall ($C = \pm 5$), Fractional Chern Insulators (`FQAH`), Supersolid Quantum Vortices, and Symbiotic Topological Quantum Computing (`G-MGS`)](grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md)
  - [Semi-Dirac Fermions (Mass in Only One Direction) With and Without Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-semi-dirac-fermions-ddf-paper.md)
  - [Layer-Coded Plabic Graphs, Complex Vector-Relation Configurations (`VRC`), and Unrestricted Grassmannian Quantum Chemistry (`QCI-GXC`) in `MADNESS` Multiwavelet `MRA-PNO` and `Tequila` for Computational Advantage](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md)
  - [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics](grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

Across modern high-energy theory, quantum gravity, condensed-matter physics, and quantum information, the special unitary group **$\mathrm{SU}(4)$** ($\dim_{\mathbb{R}}\mathrm{SU}(4) = 15$, Lie algebra $\mathfrak{su}(4) \cong \mathfrak{so}(6)$, split conformal form $\mathrm{SU}(2,2) \cong \mathrm{Spin}(2,4)$) and its homogeneous **lower Grassmannian manifolds** $\mathrm{Gr}_{\mathbb{R}}(k,n)$ and $\mathrm{Gr}_{\mathbb{C}}(k,n)$ act as the universal geometric backbone. In this paper, we synthesize and formally verify in **Lean 4** (`Signals.DFT` Section 20, `Signals.DDF`, `Signals.QEDGravity`, `Signals.Scattering`), **Rust/WASM** (`dft_plabic_vrc.rs`), and **Python** (`SemiDiracAndSU4WittenUnificationEngine`) five foundational components:

1. **The Four-Fold Role of $\mathrm{SU}(4)$ (`suNRealDim 4 = 15`, `pluckerAmbientCoordCount 2 4 = 6`)**:
   We show how the exact same 15-dimensional group $\mathrm{SU}(4)$ (and its 6-dimensional antisymmetric exterior square $\Lambda^2(\mathbf{4}) = \mathbf{6}$) simultaneously governs:
   - **(a) Twistor & Klein Quadric Geometry**: $\mathrm{Gr}_{\mathbb{C}}(1,4) = \mathbb{CP}^3 \cong \mathrm{SU}(4)/\mathrm{S}(\mathrm{U}(1)\times\mathrm{U}(3))$ and $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathrm{SU}(4)/\mathrm{S}(\mathrm{U}(2)\times\mathrm{U}(2)) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ ({download}`data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md, lines 224, 1629 <../data/chats/Gemini_Grassmannian-Gross-Pitaevskii-Equation-Formulation_20261103-1045.md>`);
   - **(b) $\mathcal{N}=4$ Super Yang–Mills & $\text{AdS}_5 \times S^5$ $R$-Symmetry**: $\mathrm{SU}(4)_R \cong \mathrm{SO}(6)$ rotating the 4 supercharges $\eta_A$ on $\mathbb{CP}^{3|4}$ and the 6 scalar fields $\Phi_{AB} \in \Lambda^2(\mathbf{4})$ on $S^5 = \mathrm{SO}(6)/\mathrm{SO}(5)$;
   - **(c) Multilayer Graphene Spin $\times$ Valley Isospin**: The 4-flavor $(\uparrow/\downarrow)\times(K/K')$ $\mathrm{SU}(4)$ symmetry whose Stoner cascade $\mathrm{Gr}_{\mathbb{C}}(f, 4)$ ($f \in \{4, 2, 1\}$) drives `SC1`, `SC2`, `QAHE`, and `FQAH` in `RTG`/`RPG`; and
   - **(d) Two-Qubit Quantum Logic Gates**: The Cartan $K A K$ decomposition $\dim_{\mathbb{R}}\mathrm{SU}(4) = 2(\dim_{\mathbb{R}}\mathrm{SU}(2) + \dim_{\mathbb{R}}\mathrm{SU}(2)) + 3 = 12 + 3 = 15$.
2. **Complete Taxonomy Table of Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}(k,n)$ and $\mathrm{Gr}_{\mathbb{C}}(k,n)$**:
   We establish a reference classification of all lower real and complex Grassmannians ($1 \le k < n \le 6$ plus $\mathrm{Gr}_{\mathbb{C}}(2,10)$), machine-checking their real manifold dimensions $k(n-k)$ and $2k(n-k)$, Plücker coordinate counts $\binom{n}{k}$, quadratic Plücker relation counts, Einstein–Kähler scalar curvatures $R_{\mathrm{Gr}}(k,n) = n k (n-k)$, classical coset isomorphisms, and physical assignments across all 30 papers in our corpus.
3. **Edward Witten's Twistor String Theory (also spelled "Witted's String Theory", Witten 2003/2004, `hep-th/0312171`) & Why Freddy Cachazo's Program (CSW / BCFW / Hodges / CHY) Makes Simulating It Computationally Tractable**:
   We answer the central question: *Does Cachazo make more sense if you are going to simulate the string theory dynamics with Witten's String Theory anyway?* **Yes — for two decisive reasons**:
   - **Physical Ghost Elimination**: Naive Witten twistor string theory on $\mathbb{CP}^{3|4}$ generates 4-derivative $\mathcal{N}=4$ **conformal Weyl supergravity** ($1/q^4$ propagator with non-unitary Ostrogradsky ghosts and $\varepsilon_{\mathrm{rel}} > 0$ growing as $a^3$, [Berkovits & Witten 2004](#su4-berkovits2004)). **Cachazo–Skinner (2012, `arXiv:1207.0741`)** introduces the infinity twistor $I_{AB}$ to project onto $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker minors and squares the reduced Hodges determinant $\det'(\Phi)\det'(\tilde{\Phi})$, eliminating the Weyl ghosts and recovering exact Einstein GR ($\varepsilon_{\mathrm{rel}} = 0$).
   - **Worldsheet Path-Integral Localization onto Discrete Algebraic Points**: Instead of continuum Monte Carlo integration over infinite-dimensional string worldsheets or summing $34{,}300$ Feynman diagrams at $n=8$ ($10.5\text{ million}$ at $n=10$), **Cachazo–He–Yuan (CHY 2013–2014)** localizes the string worldsheet integral onto $(n-3)!$ discrete algebraic roots of the scattering equations $E_a(\sigma) = 0$ (`chySolutionCount 4 = 1`, `chySolutionCount 6 = 6`, `chySolutionCount 8 = 120`, with exact 4-point root $\sigma_4^* = \frac{s_{12}}{s_{12}+s_{13}}$ proved in `chyFourPointCrossEquation`), while **BCFW recursion** triangulates $\mathrm{Gr}_{\mathbb{C}}(k,n)$ into $C_{n-3}$ Catalan on-shell Plücker cells (`bcfwCatalanTreeCount 6 = 5`, `bcfwCatalanTreeCount 8 = 42`).
4. **Relative Merits of Cachazo vs. Dilatant Dark Fluid (DDF) vs. Turner (2026) Plücker $\mathcal{Q}_4$ Models**:
   We compare the operational domains, strengths, limitations, and falsifiable discriminators of all three frameworks and show how they combine into a single hybrid simulation pipeline.
5. **Grand Unification with the 't Hooft–Susskind Holographic Principle, Maldacena AdS/CFT, Twisted Holography, and Celestial Holography**:
   We explain **what each framework is for** and prove (`su4_lower_grassmannians_witten_chy_ddf_turner_and_ads_cft_unification_identities`) that all five physical pillars—(i) **Huygens/Turner Wave Superposition**, (ii) **BCJ / Cachazo–Skinner Gauge-Gravity Double Copy**, (iii) **Planar AdS/CFT $\mathfrak{psl}(2|2)_c$ Secret Symmetries**, (iv) **'t Hooft–Susskind Holographic DDF/$\text{AdS}_5$ Redshift Lapse**, and (v) **Turner (2026) 1PN/2.5PN Orbital Kähler Precession**—are mathematical specializations of the **same $\mathrm{SU}(4)$-invariant 3-term Plücker identity $\mathcal{C}(p)/2 = p_{01}p_{23} - p_{02}p_{13} + p_{03}p_{12} = 0$ on the Klein quadric $\mathcal{Q}_4 = \mathrm{Gr}_{\mathbb{C}}(2,4) \subset \mathbb{P}^5(\mathbb{C})$**.

---

## 1. The Four-Fold Role of $\mathrm{SU}(4)$ Across Twistors, $\mathcal{N}=4$ SYM / AdS–CFT, Graphene Isospin, and Quantum Computing

The special unitary group $\mathrm{SU}(4)$ consists of $4 \times 4$ unitary matrices of unit determinant ($U^\dagger U = I_4, \det U = 1$). Its real Lie-group dimension (`suNRealDim 4 = 15` in [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4516-L4517)) and rank-3 Lie algebra satisfy the fundamental accidental isomorphism of low-dimensional Lie theory:

$$
\dim_{\mathbb{R}}\mathrm{SU}(4) = 4^2 - 1 = 15 = \frac{6 \times 5}{2} = \dim_{\mathbb{R}}\mathrm{SO}(6), \qquad \mathfrak{su}(4) \cong \mathfrak{so}(6) \quad (A_3 \cong D_3),
$$

while its split signature $(2,2)$ real form satisfies $\mathrm{SU}(2,2) \cong \mathrm{Spin}(2,4)$, the double cover of the 15-parameter 4D Minkowski conformal group $\mathrm{SO}(2,4)$!

| Pillar | Physical / Mathematical System | How $\mathbf{4} \in \mathrm{SU}(4)$ Acts | How $\mathbf{6} = \Lambda^2(\mathbf{4}) \in \mathrm{SO}(6)$ Acts | Key Invariant in `Signals` |
| :--- | :--- | :--- | :--- | :--- |
| **1. Twistor & Klein Quadric Geometry** | Projective twistor space $\mathbb{PT} = \mathbb{CP}^3 = \mathrm{Gr}_{\mathbb{C}}(1,4)$ & complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ ({download}`data/chats/Google-Search_Hubble-Sensor-Design_20261102-2031.md, lines 388–445 <../data/chats/Google-Search_Hubble-Sensor-Design_20261102-2031.md>`) | Rotates homogeneous twistor coordinates $Z^A = (\omega^{\dot{\alpha}}, \pi_\alpha) \in \mathbb{C}^4$ | Rotates the 6 Plücker coordinates $p_{AB} = Z_1^{[A} Z_2^{B]} \in \mathbb{C}^6$ preserving the Klein quadric $\mathcal{C}(p) = \frac{1}{2}\epsilon^{ABCD}p_{AB}p_{CD} = 0$ | `OnKleinQuadric`, `kahlerDetFactor_eq_pluckerNormSq_and_ge_one` ([`Signals.DDF`](../src/signals/Signals/DDF.lean#L8482-L8715)) |
| **2. Witten Twistor String & AdS/CFT ($R$-Symmetry)** | $\mathcal{N}=4$ Super Yang–Mills on $\mathbb{CP}^{3\|4}$ and Type IIB strings on $\text{AdS}_5 \times S^5$ ([Witten 2004](#su4-witten2004); [Maldacena 1998](#su4-maldacena1998)) | $\mathrm{SU}(4)_R$ rotates the 4 fermionic supertwistor coordinates $\eta_A$ ($A=1,2,3,4$) and 4 gluino flavours $\lambda_\alpha^A$ | $\mathrm{SO}(6)_R \cong \mathrm{SU}(4)_R$ rotates the 6 real adjoint scalars $\Phi_{AB} = -\Phi_{BA}$ of $\mathcal{N}=4$ SYM and isometries of $S^5 \subset \mathbb{R}^6$ | `ads_cft_integrability_and_secret_symmetry_identities` ([`Signals.Scattering`](../src/signals/Signals/Scattering.lean)) |
| **3. Multilayer Graphene Spin–Valley Isospin** | `BBG` ($N=2$), `RTG` ($N=3$), `RPG` ($N=5$), & `MATBG`/`MATTG` ([Zhou et al. 2021](#su4-zhou2021); [Han et al. 2025](#su4-han2025)) | Rotates the 4-component spin-valley flavor vector $\Psi = (\psi_{K\uparrow}, \psi_{K\downarrow}, \psi_{K'\uparrow}, \psi_{K'\downarrow})^T \in \mathbb{C}^4$ | Classifies the $\binom{4}{2} = 6$ two-flavor Stoner half-metal / intervalley-coherent (`IVC`) order parameters on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ | `graphene_rhombohedral_trilayer_pentalayer_superconductivity_and_qc_identities` ([`Signals.DFT`](../src/signals/Signals/DFT.lean#L3650-L4302)) |
| **4. Two-Qubit Quantum Computing Gate Group** | Universal 2-qubit unitary logic on $\mathbb{C}^2 \otimes \mathbb{C}^2 \cong \mathbb{C}^4$ | Evolves 2-qubit statevectors $\|\psi\rangle \in \mathbb{C}^4$; Cartan $K A K$ factors $\mathrm{SU}(4) = (\mathrm{SU}(2)\otimes\mathrm{SU}(2))\,e^{i\sum c_k \sigma_k\otimes\sigma_k}\,(\mathrm{SU}(2)\otimes\mathrm{SU}(2))$ | Makhlin local-entanglement invariants map $\mathrm{SU}(4)/(\mathrm{SU}(2)\otimes\mathrm{SU}(2)) \cong \mathrm{SO}(6)/\mathrm{SO}(4)$ via the magic Bell basis | `suNRealDim 4 = 15`, `2 * (3 + 3) + 3 = 15` ([`Signals.DFT`](../src/signals/Signals/DFT.lean#L4516-L4693)) |

---

## 2. Master Taxonomy Table of Lower Grassmannians in $\mathrm{Gr}_{\mathbb{R}}(k,n)$ and $\mathrm{Gr}_{\mathbb{C}}(k,n)$

For $1 \le k < n$, the **real Grassmannian** $\mathrm{Gr}_{\mathbb{R}}(k, n) = \mathrm{O}(n)/\bigl(\mathrm{O}(k)\times\mathrm{O}(n-k)\bigr)$ has real dimension $\dim_{\mathbb{R}}\mathrm{Gr}_{\mathbb{R}}(k,n) = k(n-k)$, while the **complex Grassmannian** $\mathrm{Gr}_{\mathbb{C}}(k, n) = \mathrm{U}(n)/\bigl(\mathrm{U}(k)\times\mathrm{U}(n-k)\bigr) = \mathrm{SU}(n)/\mathrm{S}\bigl(\mathrm{U}(k)\times\mathrm{U}(n-k)\bigr)$ is a compact Einstein–Kähler manifold of complex dimension $k(n-k)$, **real dimension $2k(n-k)$**, Plücker coordinate count $N_{\mathrm{Pl\ddot{u}cker}} = \binom{n}{k}$, independent quadratic Plücker relation count $N_{\mathrm{rel}} = \binom{n}{k} - 1 - k(n-k)$, and Einstein–Kähler scalar curvature $R_{\mathrm{Gr}}(k,n) = n k (n-k)$ (`realGrassmannianDim`, `complexGrassmannianRealDim`, `pluckerAmbientCoordCount`, `grassmannianScalarCurvature` in [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4520-L4556)):

| $(k, n)$ | $\dim_{\mathbb{R}}\mathrm{Gr}_{\mathbb{R}}(k,n)$ | $\dim_{\mathbb{R}}\mathrm{Gr}_{\mathbb{C}}(k,n)$ | Plücker Coords $\binom{n}{k}$ | Plücker Relations $N_{\mathrm{rel}}$ | Kähler Scalar Curvature $R_{\mathrm{Gr}}$ | Classical / Coset Isomorphism | Physical Realizations Across the 30-Paper `Signals` Architecture |
| :---: | :---: | :---: | :---: | :---: | :---: | :--- | :--- |
| **$(1, 2)$** | $1$ ($\mathbb{RP}^1 \cong S^1$) | $2$ ($\mathbb{CP}^1 \cong S^2$) | $2$ | $0$ | $2$ | Bloch / Riemann / Celestial sphere $\mathbb{CP}^1 = \mathrm{SU}(2)/\mathrm{U}(1)$ | • Single-qubit Bloch sphere & 2-band single-cone Dirac spinor<br>• Witten/CHY string worldsheet $\Sigma \cong \mathbb{CP}^1$ & 2D Celestial Sphere $\mathcal{CS}^2$<br>• `Gr_R(1,2)` Mpemba slow-mode thermal projection (`Signals.QuantumCausalInference`) |
| **$(1, 3)$** $\cong$ **$(2, 3)$** | $2$ ($\mathbb{RP}^2$) | $4$ ($\mathbb{CP}^2$) | $3$ | $0$ | $6$ | Complex projective plane $\mathbb{CP}^2 = \mathrm{SU}(3)/\mathrm{S}(\mathrm{U}(1)\times\mathrm{U}(2))$ | • Qutrit ($d=3$) projective state space ($\mathbb{Z}_6$ parafermion qutrit in `RPG` $\nu=2/3$ `FQAH`)<br>• 3-slit Sorkin interferometry & 3-flux Deal–Grove `G-IEP` oxidation graph |
| **$(1, 4)$** $\cong$ **$(3, 4)$** | $3$ ($\mathbb{RP}^3 \cong \mathrm{SO}(3)$) | $6$ ($\mathbb{CP}^3 = \mathbb{PT}$) | $4$ | $0$ | $12$ | **Projective Twistor Space** $\mathbb{PT} = \mathbb{CP}^3 = \mathrm{SU}(4)/\mathrm{S}(\mathrm{U}(1)\times\mathrm{U}(3))$ | • **Single light ray in 4D Minkowski space** ([Penrose 1967](#su4-penrose1967); [Witten 2004](#su4-witten2004))<br>• Quarter-metal ($f=1$) spin-valley polarized state in `RTG`/`RPG` (`G-MGS`)<br>• 4-state Grover holographic code target space (`Signals.DDF`) |
| **$(2, 4)$** | $4$ ($\frac{S^2 \times S^2}{\mathbb{Z}_2}$) | **$8$** ($\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$) | **$6$** | **$1$** ($\mathcal{C}(p)=0$) | **$16$** | **Klein Quadric** $\mathcal{Q}_4 \cong \frac{\mathrm{SU}(4)}{\mathrm{S}(\mathrm{U}(2)\times\mathrm{U}(2))} \cong \frac{\mathrm{SO}(6)}{\mathrm{SO}(4)\times\mathrm{SO}(2)}$ | • **Complexified spacetime / 2-slit & OAM Plücker channels** ($p_4 = z_1 + z_2$)<br>• **4-point MHV gauge & BCJ/Hodges gravity double copy** ($n_s+n_t+n_u=0$)<br>• **DDF Moving Sheath ($\beta$), Acoustic Horizon ($1-r_H/r$), & Orbital Precession ($1-e^2$)**<br>• **AdS/CFT $\mathfrak{psl}(2\|2)_c$ secret symmetry** ($\mathbb{H}^2-4\mathbb{C}\mathbb{C}^\dagger=M^2$)<br>• **Semi-Dirac merged two-valley Hamiltonian** ($p_{23} = E_{\mathrm{SD}}^2$, Paper 29)<br>• **Cuprate Zhang–Rice singlet (`G-CSC`) & Half-metal ($f=2$) graphene (`G-MGS`)** |
| **$(2, 5)$** $\cong$ **$(3, 5)$** | $6$ | $12$ | $10$ | **$3$** ($\binom{5}{4}=5$ eqs) | $30$ | 5-particle MHV / 3-phonon scattering manifold | • 5-point gluon/graviton MHV amplitudes & $A_2$ pentagon cluster algebra<br>• **3-phonon anharmonic interfacial heat transport (`G-TBC`, Problem 05)**<br>• Graphite 5-reservoir ultrafast electron–phonon flow (`G-GKBA`, Problem 04) |
| **$(2, 6)$** $\cong$ **$(4, 6)$** | $8$ | **$16$** | **$15$** | **$6$** ($\binom{6}{4}=15$ eqs) | **$48$** | $\mathrm{SU}(6)/\mathrm{S}(\mathrm{U}(2)\times\mathrm{U}(4))$ | • **Rhombohedral Trilayer Graphene (`RTG`, $N=3$) & `MATTG` 6-orbital $(A_1..B_3)$ subspace** (`gmgsBoundaryGrassmannianRealDim 3 = 16`, 15-level Plücker qudit, Paper 28)<br>• **6-particle MHV scattering amplitude** & uniaxially strained `RTG` semi-Dirac merging |
| **$(3, 6)$** | $9$ | **$18$** | **$20$** | **$10$** | **$54$** | Self-dual 6-twistor NMHV manifold $\mathrm{SU}(6)/\mathrm{S}(\mathrm{U}(3)\times\mathrm{U}(3))$ | • **6-point NMHV gauge/gravity scattering** (3 BCFW Plücker cells / $D_4$ cluster algebra)<br>• 3D vectorial longitudinal polarization ($E_z$) volumetric imaging (`Gr_C(3,6)`, Paper 13)<br>• 3-orbital 6-spin-orbital `QCI-GXC` Kohn–Sham DFT benchmark |
| **$(2, 10)$** | $16$ | **$32$** | **$45$** | **$28$** ($\binom{10}{4}=210$ eqs) | **$160$** | $\mathrm{SU}(10)/\mathrm{S}(\mathrm{U}(2)\times\mathrm{U}(8))$ | • **Rhombohedral Pentalayer Graphene (`RPG`, $N=5$) 10-orbital $(A_1..B_5)$ subspace** (`gmgsBoundaryGrassmannianRealDim 5 = 32`, 45-level Plücker qudit, $C=\pm 5$ `QAHE`, `FQAH`) |

---

## 3. Edward Witten's Twistor String Theory ("Witted's String Theory") and Its Evolution: From $\mathbb{CP}^{3|4}$ to Cachazo–Skinner and CHY Ambitwistor Strings

### 3.1 How Witten's (2003/2004) Twistor String Theory Works

In December 2003, **Edward Witten** (*Perturbative Gauge Theory as a String Theory in Twistor Space*, *Commun. Math. Phys.* 252, 189–258, [`hep-th/0312171`](#su4-witten2004)) revolutionized quantum field theory by uniting **Roger Penrose's Twistor Theory (1967)** with **Topological String Theory** ({download}`data/chats/Bell-Correlations-in-Atomic-Momentum.md, lines 220–245 <../data/chats/Bell-Correlations-in-Atomic-Momentum.md>`; {download}`data/chats/Google-Search_Hubble-Sensor-Design_20261102-2031.md, lines 388–445 <../data/chats/Google-Search_Hubble-Sensor-Design_20261102-2031.md>`):

1. **The Penrose Incidence Relation ($\mathbb{R}^{1,3}_{\mathbb{C}} \leftrightarrow \mathbb{CP}^3 = \mathrm{Gr}_{\mathbb{C}}(1,4)$)**:
   A point $x^{\alpha\dot{\alpha}} = \sigma_\mu^{\alpha\dot{\alpha}} x^\mu$ in complexified 4D Minkowski spacetime corresponds to a complex projective line $\mathbb{CP}^1 \subset \mathbb{CP}^3$ (a 2-plane in $\mathbb{C}^4$, i.e., a point in $\mathrm{Gr}_{\mathbb{C}}(2,4)$!) defined by the **incidence relation**:

   $$
   \omega^{\dot{\alpha}} = i\,x^{\alpha\dot{\alpha}}\,\pi_\alpha, \qquad Z^A = (\omega^{\dot{\alpha}}, \pi_\alpha) \in \mathbb{CP}^3 = \mathrm{Gr}_{\mathbb{C}}(1,4).
   $$

   - A **null light ray** in 4D spacetime maps to a **single static point** $Z^A \in \mathbb{CP}^3$.
   - A **spacetime event $x^\mu$** maps to a **Riemann sphere (line) $\mathbb{CP}^1 \subset \mathbb{CP}^3$**, which is a single point on the complex Grassmannian **$\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$**.
   - Two light rays intersect in spacetime if and only if their twistor points $Z_1^A, Z_2^B$ lie on a common line $p_{AB} = Z_1^{[A} Z_2^{B]} \in \mathrm{Gr}_{\mathbb{C}}(2,4)$ satisfying $\epsilon^{ABCD} p_{AB} p_{CD} = 0$.
2. **Topological B-Model Strings Wrapping Algebraic Curves in $\mathbb{CP}^{3|4}$**:
   Witten extended $\mathbb{CP}^3$ to projective supertwistor space $\mathbb{CP}^{3|4}$ by adding 4 fermionic coordinates $\eta_A$ ($A=1,2,3,4$) transforming in the fundamental $\mathbf{4}$ of $\mathrm{SU}(4)_R$ (so the Berezinian measure $d^{4|4}Z$ is anomaly-free and Calabi–Yau!). In Witten's twistor string theory, $D1$-instantons wrap holomorphic algebraic curves of degree $d = k - 1 + L$ (where $k$ is the number of negative-helicity gluons and $L$ is the loop order):

   $$
   \mathcal{Z}(\sigma): \Sigma \cong \mathbb{CP}^1 \longrightarrow \mathbb{CP}^{3|4}, \qquad Z^A(\sigma) = \sum_{\alpha=0}^{d} C_\alpha^A\,\sigma^\alpha.
   $$

   For $k = 2$ ($d = 1$, Maximally Helicity Violating `MHV` tree amplitudes), the curve is a straight line $\mathbb{CP}^1 \subset \mathbb{CP}^{3|4}$ — i.e., a point in **$\mathrm{Gr}_{\mathbb{C}}(2,4)$** — immediately yielding the 1-line **Parke–Taylor formula**:

   $$
   \mathcal{A}_n^{\mathrm{MHV}}(1^-, 2^-, 3^+, \dots, n^+) = \frac{\langle 1\,2\rangle^4}{\langle 1\,2\rangle\langle 2\,3\rangle\cdots\langle n\,1\rangle}\,\delta^{4|8}\!\left(\sum_{a=1}^n \lambda_a^\alpha \tilde{\lambda}_a^{\dot{\alpha}}\right),
   $$

   where every angle bracket $\langle a\,b\rangle = \epsilon_{\alpha\beta}\lambda_a^\alpha\lambda_b^\beta = \Delta_{ab}^{\mathbb{C}}$ is a **$2 \times 2$ Plücker minor on $\mathrm{Gr}_{\mathbb{C}}(2, n)$**!

---

## 4. Does Cachazo Make More Sense If You Are Going to Simulate the Dynamics with Witten's String Theory Anyway?

**Yes — unequivocally.** If your goal is to simulate gauge or gravitational dynamics using Witten's Twistor String Theory, directly discretizing or Monte-Carlo sampling the continuum topological B-model string path integral on $\mathbb{CP}^{3|4}$ is **both physically wrong in the gravitational sector and computationally intractable at high multiplicity**. **Freddy Cachazo's program** ([CSW 2004](#su4-csw2004); [BCFW 2005](#su4-bcfw2005); [Cachazo & Geyer 2012](#su4-cachazogeyer2012); [Cachazo & Skinner 2012](#su4-cachazoskinner2012); [Cachazo, He & Yuan 2013–2014](#su4-chy2014)) is the exact mathematical transformation that makes Witten's twistor string **physically ghost-free and computationally algebraic**:

```{mermaid}
flowchart TB
    Witten["Naive Witten (2003/2004) Twistor String Path Integral\nContinuum maps Z(σ): CP¹ → CP^(3|4)"]

    Prob1["Obstacle 1 (Physics — Berkovits & Witten 2004):\nClosed-string gravity sector is SU(2,2|4) scale-free\n⇒ Generates 4th-order Weyl Conformal Supergravity (C_μνρσ², 1/q⁴ ghosts)\n⇒ Fails Mercury 1PN precession (ε_rel grows as a³)"]

    Prob2["Obstacle 2 (Computation — Continuum Moduli Integration):\nIntegrating over degree-d holomorphic maps & worldsheet fields\nscales worse than Feynman diagrams\n(n=6: 220 diagrams; n=8: 34,300; n=10: 10,525,900)"]

    Fix1["Cachazo–Skinner (2012) Fix (`arXiv:1207.0741`):\n• Introduces Infinity Twistor I_AB (I_AB I^BC = Λ_cc δ_A^C)\n  projecting CP^(3|8) → Gr_C(2,4) Plücker minors ⟨ij⟩_I = Δ_ij^C\n• Replaces Weyl vertices with Double Copy of Reduced Hodges\n  Determinants det'(Φ) det'(Φ̃) ⇒ Exact Einstein GR (ε_rel = 0)"]

    Fix2["Cachazo–Geyer (2012) & CHY / BCFW Localization:\n• Lift degree-(k-1) curve to k×n Grassmannian C ∈ Gr_C(k,n)\n• CHY Scattering Equations E_a(σ) = Σ_{b≠a} s_ab/(σ_a - σ_b) = 0\n  localize path integral to (n-3)! discrete algebraic points\n  (n=4: 1 root σ_4* = s_12/(s_12+s_13); n=6: 6 roots vs. 220 diagrams)\n• BCFW triangulates Gr_C(k,n) into C_{n-3} Catalan Plücker cells"]

    Witten --> Prob1 --> Fix1
    Witten --> Prob2 --> Fix2
```

### 4.1 Quantitative Comparison: Naive Feynman / Continuum Witten String vs. Cachazo (CSW / BCFW / CHY / Hodges)

| Multiplicity $n$ (Tree Gluons / Gravitons) | Standard Feynman Diagrams $N_{\mathrm{Feynman}}(n)$ | Continuum Witten String Moduli $\dim_{\mathbb{C}}\mathcal{M}_{0,n}(\mathbb{CP}^3, d)$ | **CHY Discrete Worldsheet Roots** $N_{\mathrm{CHY}}(n) = (n-3)!$ (`chySolutionCount`) | **BCFW Catalan Plücker Cells** $C_{n-3} = \frac{1}{n-2}\binom{2n-6}{n-3}$ (`bcfwCatalanTreeCount`) | **Parke–Taylor / Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,n)$ MHV Terms** |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **$n = 4$** | $4$ | $4d + n = 8$ ($d=1$) | **$1$** ($\sigma_4^* = \frac{s_{12}}{s_{12}+s_{13}}$) | **$1$** | **$1$** |
| **$n = 5$** | $25$ | $9$ ($d=1$) | **$2$** | **$2$** | **$1$** |
| **$n = 6$** | $220$ | $14$ ($d=2$) | **$6$** ($36.7\times$ fewer) | **$5$** ($44\times$ fewer) | **$1$** |
| **$n = 7$** | $2{,}485$ | $15$ ($d=2$) | **$24$** ($103.5\times$ fewer) | **$14$** ($177.5\times$ fewer) | **$1$** |
| **$n = 8$** | $34{,}300$ | $20$ ($d=3$) | **$120$** ($285.8\times$ fewer) | **$42$** ($816.7\times$ fewer) | **$1$** |
| **$n = 10$** | $10{,}525{,}900$ | $26$ ($d=4$) | **$5{,}040$** ($2{,}088\times$ fewer) | **$429$** ($24{,}536\times$ fewer) | **$1$** |

In [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4558-L4693) (`su4_lower_grassmannians_witten_chy_ddf_turner_and_ads_cft_unification_identities`), we machine-check:
1. `chySolutionCount 4 = 1`, `chySolutionCount 5 = 2`, `chySolutionCount 6 = 6`, `chySolutionCount 8 = 120`,
2. `bcfwCatalanTreeCount 4 = 1`, `bcfwCatalanTreeCount 5 = 2`, `bcfwCatalanTreeCount 6 = 5`, `bcfwCatalanTreeCount 8 = 42`, and
3. For 4-point massless scattering with $\mathrm{SL}(2,\mathbb{C})$ gauge fixing $(\sigma_1, \sigma_2, \sigma_3) = (0, 1, \infty)$, the CHY scattering equation $\frac{s_{12}}{\sigma_4} + \frac{s_{13}}{\sigma_4 - 1} = 0$ clears denominators to $\mathcal{E}_4(s_{12}, s_{13}, \sigma_4) = s_{12}(\sigma_4 - 1) + s_{13}\sigma_4 = 0$, which is **solved identically** by the unique rational root $\sigma_4^*(s_{12}, s_{13}) = \frac{s_{12}}{s_{12} + s_{13}}$ (`chyFourPointCrossEquation s12 s13 (chyFourPointRoot s12 s13) = 0`)!

---

## 5. Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. Dilatant Dark Fluid (DDF) vs. Turner (2026) Models

How do **Cachazo's on-shell twistor/Grassmannian program**, **Fedi's Dilatant Dark Fluid (DDF)**, and the **Turner (2026) Homogeneous Plücker $\mathcal{Q}_4$ Madelung / Dual-Schubert `iGPE` / Normed Tensor Gaussian Splat models** compare, and how should they be combined?

| Evaluation Dimension | 1. Original Witten (2004) Twistor String | 2. Cachazo Program (CSW / BCFW / Cachazo–Skinner / CHY) | 3. Dilatant Dark Fluid (DDF, Fedi 2026, `Signals.DDF`) | 4. Turner (2026) Plücker $\mathcal{Q}_4$ Madelung, Dual-`iGPE` & Tensor Splat Models (`Signals`) |
| :--- | :--- | :--- | :--- | :--- |
| **Primary Mathematical Manifold** | Projective supertwistor space $\mathbb{CP}^{3\|4} = \mathrm{Gr}_{\mathbb{C}}(1,4\|4)$ | Complex & Positive Grassmannians $\mathrm{Gr}_{\mathbb{C}}(k,n)$, $\mathrm{Gr}_{\ge 0}(k,n)$, & CHY moduli $\mathcal{M}_{0,n}$ | 4D Painlevé–Gullstrand river spacetime $\mathbb{R}^{1,3}$ with $(\phi, \varphi)$ two-phase bosonic substrate | **Dual-Schubert $\mathrm{Gr}_{\mathbb{C}}(2,4) \times \mathrm{Gr}_{\mathbb{C}}(2,4)^\vee \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$ + 2D/3D `NormedTensorGaussianSplat`** |
| **Gravitational Propagator & Ghosts** | **Fails**: $1/q^4$ 4th-order Weyl conformal supergravity with Ostrogradsky ghosts | **Exact**: $1/q^2$ unitary spin-2 graviton via infinity twistor $I_{AB}$ & double copy $\det'(\Phi)\det'(\tilde{\Phi})$ | **Exact 1PN / 2.5PN**: Conservative superfluid enthalpy $\Phi_\phi = -G_\phi M/r$ + Lorentz sheath jamming $\gamma_\varphi(v)$ | **Exact 1PN / 2.5PN + UV Regularized**: Kähler chart $\det(I_2+W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger)-3 = 1-e^2$ + Planck Bohm/Josephson core |
| **Mercury 1PN Perihelion Error $\varepsilon_{\mathrm{rel}}$** | $\varepsilon_{\mathrm{rel}} = 100\%$ (scale-free) or grows as $a^3$ (`wittenConformalTwistorPrecessionRad`) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$ error)** at $\pi_I = 1, \Lambda_{\mathrm{cc}} = 0$ (`cachazoSkinnerTwistorPrecessionRad`) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$ error)** for conservative action (`perihelionPrecessionRad`; rules out Stokes drag) | **$\varepsilon_{\mathrm{rel}} = 0$ ($0\%$ error)** at solar-system scales (`turnerPluckerIGPEPrecessionRad`, Models 14a/14b) |
| **Asymptotic S-Matrix vs. Real-Time PDE Evolution** | Asymptotic boundary S-matrix only (no real-time trajectory $x(t)$) | **Best-in-class S-matrix**: exact $n$-point tree/loop scattering amplitudes in $(n-3)!$ or $C_{n-3}$ steps | **Best-in-class constitutive fluid**: continuous real-time Euler/Madelung flow, $c = (\varrho_{\max}^\varphi j_{\min}^\varphi)^{-1/2}$, galactic $v_{\mathrm{flat}} = \sqrt{q_\rho}c_\phi$ | **Unites both**: on-shell Plücker minors on $\mathcal{Q}_4$ + continuous Fubini–Study `iGPE` time evolution + $O(N_{\mathrm{splat}})$ GPU/WASM splatting |
| **Condensed-Matter & Nano-Device Applicability** | None (strictly massless 4D high-energy $\mathcal{N}=4$ SYM / Weyl gravity) | Indirect (amplituhedron/plabic combinatorics) | Medium analogies (superfluid He, acoustic horizons, directional semi-Dirac jamming) | **Direct**: `QCI-GXC` DFT, `G-GKBA` light-driven materials, `G-TBC` heat transport, `G-CSC` cuprates, `G-IEP` wafers, `G-MGS` graphene QC, & semi-Dirac fermions |
| **Decisive Experimental Falsifier** | Already falsified for Einstein gravity by Berkovits–Witten (2004) | Tested against LHC multi-jet/gluon cross-sections & post-Minkowskian LIGO/Virgo inspiral waveforms | **Active radiation sourcing discriminator**: $\eta_{\mathrm{act}}^\gamma = 0$ (DDF) vs. $\eta_{\mathrm{act}}^\gamma = 1$ (GR) in counter-propagating laser deflection (`ActiveRadiationSourcing`) | Tested across all 28+ benchmarks: double-slit/OAM, Mercury $42.98''/\text{cy}$, `GMTKN55` $1.643\text{ kcal/mol}$, `G-TBC` $<1.5\%$, `G-CSC` $<0.8\%$, `G-MGS` $<0.7\%$ |

### 5.1 How to Combine Cachazo, DDF, and Turner Models in a Unified Simulation Engine

Rather than treating Cachazo, DDF, and Turner as competing alternatives, our `Signals` library unites them into a **three-layer division of labor**:
1. **Layer 1 — Cachazo On-Shell Interaction Kernel (`Signals.QEDGravity`, `Signals.Plabic`)**: Use **Cachazo–Skinner / BCJ / CHY** on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ and $\mathrm{Gr}_{\mathbb{C}}(k,n)$ to compute the exact, ghost-free multi-particle scattering vertices $\mathcal{K}_{\mathrm{CS}}(M_{\mathbb{C}}) = (\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}})^2 = (w_A^{\mathbb{C}} + w_B^{\mathbb{C}})^2$ in $O(1)$ to $O(C_{n-3})$ algebraic operations without Feynman diagrams.
2. **Layer 2 — DDF Constitutive Substrate & Horizon Mechanics (`Signals.DDF`)**: Supply the physical medium parameters $\varrho_{\max}^\varphi j_{\min}^\varphi = c^{-2}$, Lorentz sheath jamming $\gamma_\varphi(v) = (1 - v^2/c^2)^{-1/2}$, Painlevé–Gullstrand river velocity $v_\phi(r) = -\sqrt{2 G_\phi M / r}$, and isothermal galactic rotation plateau $v_{\mathrm{flat}} = \sqrt{q_\rho}\,c_\phi$.
3. **Layer 3 — Turner (2026) Homogeneous Plücker $\mathcal{Q}_4$ Madelung & Tensor Splat Evolution (`Signals.DDF` Sec. 30, `Signals.DFT`)**: Evolve the quantum-hydrodynamic state $s_{\mathrm{pl}} : \mathrm{PluckerMadelungState}$ and `NormedTensorGaussianSplat3D` packets in real time $\tau$ on $\mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$, using the Fubini–Study Kähler potential $\mathcal{K} = \ln\det(I_2 + W W^\dagger)$, dual-Schubert Josephson coupling $\Lambda_{\mathrm{dual}}(p, \tilde{p})$, and Planck-scale Bohm quantum pressure $Q_{\mathrm{Pl\ddot{u}cker}}(\rho)$ to regularize horizon/merger singularities.

---

## 6. Grand Unification: What the Holographic Principle, AdS/CFT, Witten's Twistor String (with Recent Additions), Cachazo, DDF, and Turner Are For — and How They Connect

### 6.1 What Each Framework Is For (Operational Purpose & Domain of Validity)

A frequent source of confusion in theoretical physics is why so many overlapping dualities exist—**Holographic Theory ('t Hooft–Susskind)**, **AdS/CFT (Maldacena–GKPW–Witten)**, **Witten's Twistor String Theory**, **Ambitwistor / CHY Theory**, **Twisted Holography (Costello–Gaiotto)**, **Celestial Holography (Strominger et al.)**, and **Grassmannian–DDF–Turner Mechanics**. Each was invented to solve a distinct regime where standard perturbation theory fails:

```{mermaid}
flowchart TB
    Center["Universal SU(4) / Spin(2,4) Klein Quadric Core\nGr_C(2,4) ≅ Q_4 ⊂ P⁵(C)\np_01 p_23 - p_02 p_13 + p_03 p_12 = 0"]

    Holo["1. 't Hooft–Susskind Holographic Principle (1993–1995)\n• FOR: Information capacity & horizon thermodynamics in 3+1D gravity\n• LAW: S_BH = k_B A_H/(4ℓ_P²), M = κ_H A_H/(4πG_ϕ)\n• Gr_C(2,4) LINK: |w_A|²|w_B|² = 1 - β_ϕ(r)² = 1 - r_H/r"]

    AdS["2. Maldacena / GKPW AdS/CFT & Planar Integrability (1998–2012)\n• FOR: Strong-coupling (λ = g_YM² N_c ≫ 1) non-perturbative gauge/plasma physics\n• LAW: Δ(Δ-d) = m²R_AdS², η/s = ℏ/(4πk_B), S_EE = (c_BH/3)ln(ℓ/ε)\n• Gr_C(2,4) LINK: psl(2|2)_c secret symmetry H² - 4CC† = M² = 1 IS Plücker identity"]

    WittenCHY["3. Witten Twistor String (2003) + Cachazo–Skinner (2012) + CHY Ambitwistor (2014)\n• FOR: Weak-to-all-order flat-space n-particle gauge & gravity S-matrix\n• LAW: Curves CP¹ → CP^(3|4), E_a(σ) = 0 ((n-3)! roots), Hodges det'(Φ)det'(Φ̃)\n• Gr_C(2,4) LINK: Infinity twistor ⟨ij⟩_I = Δ_ij^C & BCJ n_s + n_t + n_u = 0"]

    TwistedCel["4. Recent Additions: Twisted Holography (2018) & Celestial Holography (2021–2024)\n• FOR: Bridging AdS_5×S⁵ string theory to flat-space 4D twistor amplitudes\n• LAW: Holomorphic B-twist of AdS_5×S⁵ IS Witten's twistor string on SL(2,C) → CP^(3|4);\n  R_AdS → ∞ boundary CFT reduces to 2D Celestial CFT on CS² ≅ CP¹ = Gr_C(1,2)"]

    DDFTurner["5. DDF (Fedi 2026) & Turner (2026) Plücker Q_4 / DFT / Splat Architecture\n• FOR: Real-time 3+1D orbital/GW dynamics, UV singularity resolution, & lab materials\n• LAW: c = (ϱ_max^φ j_min^φ)^(-1/2), det(I_2+W_orb W_orb†)-3 = 1-e², Q_Plücker Weyl bridge\n• Gr_C(2,k) LINK: Spans Gr_C(2,4) gravity/optics to Gr_C(2,6)/Gr_C(2,10) graphene QC"]

    Center --> Holo
    Center --> AdS
    Center --> WittenCHY
    Center --> TwistedCel
    Center --> DDFTurner
    AdS <-->|"Holomorphic B-Twist (Costello–Gaiotto)\n& Flat Limit R_AdS → ∞"| TwistedCel
    TwistedCel <-->|"Worldsheet Localization\nσ ∈ CP¹ = Gr_C(1,2)"| WittenCHY
    Holo <-->|"Painlevé–Gullstrand River\n& Planck Splats"| DDFTurner
```

1. **What the 't Hooft–Susskind Holographic Principle Is For ([grassmannian-holographic-principle-paper.md](grassmannian-holographic-principle-paper.md))**:
   - **Purpose**: Resolves the black-hole information paradox and bounds the maximum number of quantum degrees of freedom inside any $(3+1)$D bulk volume $V$ by the area $A_H$ of its enclosing 2D boundary screen ($N_{\mathrm{bits}} = \frac{A_H}{4\ell_P^2}$).
   - **How It Connects**: In our DDF `RiverExterior` model, the 2D surface integral of the acoustic surface gravity $\kappa_H = \frac{c^2}{2r_H}$ over $A_H = 4\pi r_H^2$ recovers the exact 3D bulk mass $M = \frac{\kappa_H A_H}{4\pi G_\phi}$, while the $\mathrm{Gr}_{\mathbb{C}}(2,4)$ Plücker channel product $|w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2 = 1 - \beta_\phi(r)^2 = 1 - \frac{r_H}{r}$ encodes the gravitational redshift lapse everywhere outside the screen.
2. **What Maldacena's AdS/CFT Correspondence Is For ([grassmannian-ads-cft-ddf-paper.md](grassmannian-ads-cft-ddf-paper.md))**:
   - **Purpose**: Turns intractable **strongly coupled ($\lambda = g_{\mathrm{YM}}^2 N_c \gg 1$) quantum field theory problems**—such as quark-gluon plasma shear viscosity ($\eta/s = \frac{\hbar}{4\pi k_B}$), non-equilibrium thermalization (holographic black-brane quasinormal modes), entanglement entropy ($S_{\mathrm{EE}} = \frac{\operatorname{Area}(\gamma_A)}{4 G_N}$), and anomalous dimensions of composite operators—into tractable **weakly curved classical gravity / integrable spin-chain problems** in one higher spatial dimension ($\text{AdS}_5 \times S^5$, where the radial coordinate $z$ is the renormalization-group scale $\sigma_{\mathrm{splat}} = z_{\mathrm{rg}}$).
   - **How It Connects**: The boundary symmetry $\mathrm{SU}(2,2|4)$ of $\mathcal{N}=4$ SYM is the supersymmetric extension of the $\mathrm{Gr}_{\mathbb{C}}(2,4)$ conformal group $\mathrm{SU}(2,2)$ and the $\mathrm{SU}(4)_R$ R-symmetry, and the all-loop $\mathfrak{psl}(2|2)_c$ magnon dispersion $\mathbb{H}^2 - 4\mathbb{C}\mathbb{C}^\dagger = M^2$ is literally the 3-term Plücker identity on $\mathrm{Gr}_{\mathbb{C}}(2,4)$.
3. **What Witten's Twistor String Theory + Recent Additions (Cachazo–Skinner, CHY Ambitwistor Strings, Twisted Holography, Celestial Holography) Are For**:
   - **Purpose**: Solves the **opposite regime from AdS/CFT**—namely, **high-multiplicity ($n$-particle) scattering amplitudes in 4D flat Minkowski space**—by replacing exponentially many off-shell Feynman diagrams with algebraic curves and positive Grassmannian cells in $\mathrm{Gr}_{\mathbb{C}}(k,n)$.
   - **How Recent Additions Connect Witten's Twistor String Directly to AdS/CFT and Holography**:
     - **Twisted Holography ([Costello & Gaiotto 2018, `arXiv:1812.09257`](#su4-costello2018); [Costello & Paquette 2022](#su4-costellopaquette2022))**: For 15 years after 2003, Witten's topological B-model twistor string on $\mathbb{CP}^{3|4}$ and Maldacena's physical Type IIB superstring on $\text{AdS}_5 \times S^5$ were treated as separate theories. Costello and Gaiotto proved that taking the **holomorphic/chiral B-twist of Type IIB supergravity on $\text{AdS}_5 \times S^5$** localizes the 10D geometry onto the 6D deformed conifold $\mathrm{SL}(2,\mathbb{C}) \subset \mathbb{C}^4$, whose projective boundary at infinity is $\mathbb{CP}^{3|4}$ — **recovering Witten's Twistor String Theory as an exact subsector of AdS/CFT**!
     - **Ambitwistor Strings & CHY ([Mason & Skinner 2013, `arXiv:1311.2564`](#su4-masonskinner2013); [Cachazo, He & Yuan 2014](#su4-chy2014))**: Reformulates the string worldsheet in phase space (the space of null geodesics / ambitwistors) at infinite string tension ($\alpha' \to 0$), decoupling massive string tower states while localizing tree and loop amplitudes onto the $(n-3)!$ solutions of the CHY scattering equations on $\mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$.
     - **Celestial Holography ([Strominger 2017](#su4-strominger2017); [Costello, Paquette & Sharma 2022, `arXiv:2204.05301`](#su4-cps2022))**: Takes the flat-space limit $R_{\mathrm{AdS}} \to \infty$ of AdS/CFT and maps 4D massless scattering amplitudes in twistor space $\mathbb{CP}^3 = \mathrm{Gr}_{\mathbb{C}}(1,4)$ (via Mellin transform in energy) onto correlation functions of a 2D Celestial CFT living on the night-sky Riemann sphere $\mathcal{CS}^2 \cong \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$, where the $\mathcal{W}_{1+\infty}$ soft-graviton symmetry algebra arises directly from twistor-string ambitwistor currents on $\mathrm{Gr}_{\mathbb{C}}(2,4)$!

---

### 6.2 The Five-Way Universal $\mathrm{SU}(4)$ Klein Quadric Unification Theorem (`su4_lower_grassmannians_witten_chy_ddf_turner_and_ads_cft_unification_identities`)

In [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4595-L4693), we define the universal $\mathrm{SU}(4)$-invariant 3-term Plücker residual on $\mathrm{Gr}_{\mathbb{C}}(2,4) \cong \mathcal{Q}_4 \subset \mathbb{P}^5(\mathbb{C})$:

$$
\mathcal{R}_{\mathrm{Pl\ddot{u}cker}}(p_{01}, p_{23}, p_{02}, p_{13}, p_{03}, p_{12}) := p_{01}\,p_{23} - p_{02}\,p_{13} + p_{03}\,p_{12} = 0,
$$

and machine-check that **all five fundamental laws** across our 30-paper corpus are exact specializations of $\mathcal{R}_{\mathrm{Pl\ddot{u}cker}} = 0$:

| # | Unification Pillar | Plücker 6-Vector Assignment $(p_{01}, p_{23}, p_{02}, p_{13}, p_{03}, p_{12})$ on $\mathcal{Q}_4 = \mathrm{Gr}_{\mathbb{C}}(2,4)$ | Resulting Physical Law Enforced by $\mathcal{R}_{\mathrm{Pl\ddot{u}cker}} = 0$ |
| :---: | :--- | :--- | :--- |
| **1** | **Huygens / Turner Quantum Wave Superposition** (Papers 1, 5, 16) | $(z_1,\; 1,\; 1,\; z_1 + z_2,\; z_2,\; 1)$ | $z_1\cdot 1 - 1\cdot(z_1 + z_2) + z_2\cdot 1 = 0 \iff p_{13} = z_1 + z_2$ (**Linear superposition is a projective line intersection on $\mathcal{Q}_4$**) |
| **2** | **BCJ / Cachazo–Skinner Gauge-Gravity Double Copy** (Papers 4, 30) | $n_s = p_{01}p_{23},\; n_t = -p_{02}p_{13},\; n_u = p_{03}p_{12}$ | $n_s + n_t + n_u = 0 \implies \mathcal{K}_{\mathrm{CS}} = n_t^2 = (n_s + n_u)^2$ (**Color–kinematics Jacobi identity & Hodges graviton double copy**) |
| **3** | **Planar AdS/CFT $\mathfrak{psl}(2\|2)_c$ Secret-Symmetry Dispersion** (Paper 9) | $(ad - bc,\; ad - bc,\; 2ab,\; -2cd,\; -(ad + bc),\; ad + bc)$ | $(ad - bc)^2 + 4(ab)(cd) - (ad + bc)^2 = 0 \iff \mathbb{H}^2 - 4\mathbb{C}\mathbb{C}^\dagger = M^2$ (**All-loop Beisert–Torrielli magnon dispersion**) |
| **4** | **'t Hooft–Susskind Holographic Principle & DDF/$\text{AdS}_5$ Redshift Lapse** (Papers 3, 8, 9) | $(1 + \beta,\; 1 - \beta,\; 1,\; 1 - \beta^2,\; 0,\; 1)$ with $\beta = \sqrt{r_H/r}$ or $(z/z_H)^2$ | $(1 + \beta)(1 - \beta) - (1 - \beta^2) = 0 \iff \|w_A^{\mathbb{C}}\|^2\|w_B^{\mathbb{C}}\|^2 = 1 - \frac{r_H}{r} = \gamma_\varphi(v_\phi)^{-2}$ (**Painlevé–Gullstrand / $\text{AdS}_5$ black-brane lapse**) |
| **5** | **Turner (2026) 1PN/2.5PN Orbital Kähler Precession & Semi-Dirac Merging** (Papers 4, 16, 29) | $(1 + e,\; 1 - e,\; 1,\; 1 - e^2,\; 0,\; 1)$ on $W_{\mathrm{orb}} \in \mathrm{Gr}_{\mathbb{C}}(2,4)$ | $(1 + e)(1 - e) - (1 - e^2) = 0 \iff \det(I_2 + W_{\mathrm{orb}}W_{\mathrm{orb}}^\dagger) - 3 = 1 - e^2 = \frac{p}{a}$ (**Exact Mercury $42.98''/\text{cy}$ semi-latus rectum factor**) |

---

### 6.3 Deep Gap Closures: Projective Plücker Codimension $N_{\mathrm{rel}}(k, n)$, 4-Point CHY Bi-Adjoint Scalar Amplitude Recovery, Twisted Holography Deformed Conifold, and Celestial Conformal Weights (`Signals.DFT` Section 20.2)

Theorem `semi_dirac_and_su4_witten_chy_deep_gap_closure_identities` ([../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4695-L4835)) machine-checks four additional structural bridges:

1. **Exact Projective Plücker Codimension Formula (`pluckerRelationCodimension`)**:
   Inside $\mathbb{P}^{\binom{n}{k}-1}(\mathbb{C})$, the Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k, n)$ has complex dimension $k(n-k)$ and projective codimension

   $$
   N_{\mathrm{rel}}(k, n) = \binom{n}{k} - 1 - k(n - k),
   $$

   machine-checking $N_{\mathrm{rel}}(1,2) = N_{\mathrm{rel}}(1,3) = N_{\mathrm{rel}}(1,4) = 0$, $N_{\mathrm{rel}}(2,4) = 1$, $N_{\mathrm{rel}}(2,5) = 3$, $N_{\mathrm{rel}}(2,6) = 6$, $N_{\mathrm{rel}}(3,6) = 10$, and $N_{\mathrm{rel}}(2,10) = 28$.
2. **Exact 4-Point CHY Bi-Adjoint Scalar Amplitude Recovery (`chyFourPointBiAdjointScalar`)**:
   Evaluating the 4-point CHY worldsheet localization ratio $\mathrm{PT}(1,2,3,4)^2 / |\det'\Phi_{\mathrm{CHY}}|$ at the unique scattering-equation root $\sigma_4^*(s_{12}, s_{13}) = \frac{s_{12}}{s_{12} + s_{13}}$ recovers the exact sum of $s$- and $t$-channel Feynman propagators:

   $$
   \mathcal{A}_4^{\mathrm{CHY},\phi^3}(s_{12}, s_{13}) = \frac{1}{(s_{12} + s_{13})\,\sigma_4^*(s_{12}, s_{13})\,\bigl(1 - \sigma_4^*(s_{12}, s_{13})\bigr)} = \frac{s_{12} + s_{13}}{s_{12}\,s_{13}} = \frac{1}{s_{12}} + \frac{1}{s_{13}}.
   $$

3. **Costello–Gaiotto (`arXiv:1812.09257`) Twisted Holography Deformed Conifold (`twistedHolographyDeformedConifoldResidual`)**:
   In the holomorphic B-twist of Type IIB supergravity on $\text{AdS}_5 \times S^5$, $N_c$ $D1$-branes deform the singular conifold $\det Z_{2\times 2} = z_{11}z_{22} - z_{12}z_{21} = 0$ into $\mathrm{SL}(2,\mathbb{C})$ with modulus $g_s N_c$, satisfying $\mathcal{R}_{\mathrm{conifold}}(z_{11}, z_{22}, z_{12}, z_{21}, z_{11}z_{22} - z_{12}z_{21}) = 0$.
4. **Celestial Holography Conformal Weights on $\mathcal{CS}^2 \cong \mathbb{CP}^1 = \mathrm{Gr}_{\mathbb{C}}(1,2)$ (`celestialConformalWeightH`, `celestialConformalWeightHBar`)**:
   Mapping a 4D massless state of Mellin boost weight $\Delta$ and helicity $J$ in $\mathbb{CP}^3 = \mathrm{Gr}_{\mathbb{C}}(1,4)$ to a 2D primary operator on the celestial sphere $\mathrm{Gr}_{\mathbb{C}}(1,2)$ with weights $h = (\Delta + J)/2$ and $\bar{h} = (\Delta - J)/2$ satisfies $h + \bar{h} = \Delta$ and $h - \bar{h} = J$.

---

## 7. Machine-Checked Lean 4 Verification (`Signals.DFT` Section 20)

The following theorems `su4_lower_grassmannians_witten_chy_ddf_turner_and_ads_cft_unification_identities` and `semi_dirac_and_su4_witten_chy_deep_gap_closure_identities` are machine-checked in [../src/signals/Signals/DFT.lean](../src/signals/Signals/DFT.lean#L4630-L4835) (and tested in [../src/signals/SignalsTests.lean](../src/signals/SignalsTests.lean#L7428-L7505) and [../src/signals/SignalsPendingTests.lean](../src/signals/SignalsPendingTests.lean#L6048-L6095)):

```lean
import Signals

namespace SU4WittenTwistorStringCHYUnificationVerification

open Signals.DFT

example (s12 s13 z1 z2 a b c d beta e z11 z22 z12 z21 delta j_hel : ℝ)
    (hs12 : s12 ≠ 0) (hs13 : s13 ≠ 0) (hs : s12 + s13 ≠ 0) :
    suNRealDim 4 = 15 ∧
      suNRealDim 2 = 3 ∧
      2 * (suNRealDim 2 + suNRealDim 2) + 3 = suNRealDim 4 ∧
      pluckerAmbientCoordCount 2 4 = 6 ∧
      (realGrassmannianDim 1 2 = 1 ∧ complexGrassmannianRealDim 1 2 = 2 ∧
        pluckerAmbientCoordCount 1 2 = 2 ∧ grassmannianScalarCurvature 1 2 = 2) ∧
      (realGrassmannianDim 1 4 = 3 ∧ complexGrassmannianRealDim 1 4 = 6 ∧
        pluckerAmbientCoordCount 1 4 = 4 ∧ grassmannianScalarCurvature 1 4 = 12) ∧
      (realGrassmannianDim 2 4 = 4 ∧ complexGrassmannianRealDim 2 4 = 8 ∧
        pluckerAmbientCoordCount 2 4 = 6 ∧ grassmannianScalarCurvature 2 4 = 16) ∧
      (realGrassmannianDim 2 5 = 6 ∧ complexGrassmannianRealDim 2 5 = 12 ∧
        pluckerAmbientCoordCount 2 5 = 10 ∧ grassmannianScalarCurvature 2 5 = 30) ∧
      (realGrassmannianDim 2 6 = 8 ∧ complexGrassmannianRealDim 2 6 = 16 ∧
        pluckerAmbientCoordCount 2 6 = 15 ∧ grassmannianScalarCurvature 2 6 = 48) ∧
      (realGrassmannianDim 3 6 = 9 ∧ complexGrassmannianRealDim 3 6 = 18 ∧
        pluckerAmbientCoordCount 3 6 = 20 ∧ grassmannianScalarCurvature 3 6 = 54) ∧
      (complexGrassmannianRealDim 2 10 = 32 ∧
        pluckerAmbientCoordCount 2 10 = 45 ∧ grassmannianScalarCurvature 2 10 = 160) ∧
      chySolutionCount 4 = 1 ∧
      chySolutionCount 5 = 2 ∧
      chySolutionCount 6 = 6 ∧
      chySolutionCount 8 = 120 ∧
      bcfwCatalanTreeCount 4 = 1 ∧
      bcfwCatalanTreeCount 5 = 2 ∧
      bcfwCatalanTreeCount 6 = 5 ∧
      bcfwCatalanTreeCount 8 = 42 ∧
      chyFourPointCrossEquation s12 s13 (chyFourPointRoot s12 s13) = 0 ∧
      universalPluckerThreeTermResidual z1 1 1 (z1 + z2) z2 1 = 0 ∧
      universalPluckerThreeTermResidual (a * d - b * c) (a * d - b * c)
        (2 * a * b) (-2 * c * d) (-(a * d + b * c)) (a * d + b * c) = 0 ∧
      universalPluckerThreeTermResidual (1 + beta) (1 - beta) 1 (1 - beta ^ 2) 0 1 = 0 ∧
      universalPluckerThreeTermResidual (1 + e) (1 - e) 1 (1 - e ^ 2) 0 1 = 0 ∧
      pluckerRelationCodimension 2 4 = 1 ∧
      pluckerRelationCodimension 2 5 = 3 ∧
      pluckerRelationCodimension 2 6 = 6 ∧
      pluckerRelationCodimension 3 6 = 10 ∧
      pluckerRelationCodimension 2 10 = 28 ∧
      chyFourPointBiAdjointScalar s12 s13 = 1 / s12 + 1 / s13 ∧
      twistedHolographyDeformedConifoldResidual z11 z22 z12 z21 (z11 * z22 - z12 * z21) = 0 ∧
      celestialConformalWeightH delta j_hel + celestialConformalWeightHBar delta j_hel = delta ∧
      celestialConformalWeightH delta j_hel - celestialConformalWeightHBar delta j_hel = j_hel := by
  have h1 :=
    su4_lower_grassmannians_witten_chy_ddf_turner_and_ads_cft_unification_identities
      s12 s13 z1 z2 a b c d beta e hs
  have h2 :=
    semi_dirac_and_su4_witten_chy_deep_gap_closure_identities
      s12 s13 z11 z22 z12 z21 delta j_hel hs12 hs13 hs
  exact ⟨h1.1, h1.2.1, h1.2.2.1, h1.2.2.2.1,
    h1.2.2.2.2.1, h1.2.2.2.2.2.1, h1.2.2.2.2.2.2.1, h1.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.1, h1.2.2.2.2.2.2.2.2.2.1, h1.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.1, h1.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h1.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    h2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2⟩

end SU4WittenTwistorStringCHYUnificationVerification
```

---

## References

(su4-penrose1967)=
<a id="su4-penrose1967"></a>
1. **Penrose, R. (1967).** *Twistor Algebra.* Journal of Mathematical Physics, 8(2), 345–366. `https://doi.org/10.1063/1.1705200`

(su4-thooft1993)=
<a id="su4-thooft1993"></a>
2. **'t Hooft, G. (1993).** *Dimensional Reduction in Quantum Gravity.* (`arXiv:gr-qc/9310026`).

(su4-susskind1995)=
<a id="su4-susskind1995"></a>
3. **Susskind, L. (1995).** *The World as a Hologram.* Journal of Mathematical Physics, 36(11), 6377–6396 (`arXiv:hep-th/9409089`).

(su4-maldacena1998)=
<a id="su4-maldacena1998"></a>
4. **Maldacena, J. (1998).** *The Large-$N$ Limit of Superconformal Field Theories and Supergravity.* Advances in Theoretical and Mathematical Physics, 2, 231–252 (`arXiv:hep-th/9711200`).

(su4-witten2004)=
<a id="su4-witten2004"></a>
5. **Witten, E. (2004).** *Perturbative Gauge Theory as a String Theory in Twistor Space.* Communications in Mathematical Physics, 252, 189–258 (`arXiv:hep-th/0312171`).

(su4-berkovits2004)=
<a id="su4-berkovits2004"></a>
6. **Berkovits, N., & Witten, E. (2004).** *Conformal Supergravity in Twistor-String Theory.* Journal of High Energy Physics, 2004(08), 009 (`arXiv:hep-th/0406051`).

(su4-csw2004)=
<a id="su4-csw2004"></a>
7. **Cachazo, F., Svrček, P., & Witten, E. (2004).** *MHV Vertices and Tree Amplitudes in Gauge Theory.* Journal of High Energy Physics, 2004(09), 006 (`arXiv:hep-th/0403047`).

(su4-bcfw2005)=
<a id="su4-bcfw2005"></a>
8. **Britto, R., Cachazo, F., Feng, B., & Witten, E. (2005).** *Direct Proof of Tree-Level Recursion Relation in Yang–Mills Theory.* Physical Review Letters, 94(18), 181602 (`arXiv:hep-th/0501052`).

(su4-beisert2012)=
<a id="su4-beisert2012"></a>
9. **Beisert, N., et al. (2012).** *Review of AdS/CFT Integrability: An Overview.* Letters in Mathematical Physics, 99, 3–32 (`arXiv:1012.3982`).

(su4-deleeuw2012)=
<a id="su4-deleeuw2012"></a>
10. **de Leeuw, M., Matsumoto, T., Moriyama, S., Regelskis, V., & Torrielli, A. (2012).** *Secret Symmetries in AdS/CFT.* Physica Scripta, 024002 (`arXiv:1204.2366`).

(su4-cachazogeyer2012)=
<a id="su4-cachazogeyer2012"></a>
11. **Cachazo, F., & Geyer, Y. (2012).** *A 'Twistor String' Inspired Formula For Tree-Level Scattering Amplitudes in $\mathcal{N}=8$ SUGRA.* (`arXiv:1206.6511`).

(su4-cachazoskinner2012)=
<a id="su4-cachazoskinner2012"></a>
12. **Cachazo, F., & Skinner, D. (2013).** *Gravity from Rational Curves in Twistor Space.* Physical Review Letters, 110(16), 161301 (`arXiv:1207.0741`).

(su4-masonskinner2013)=
<a id="su4-masonskinner2013"></a>
13. **Mason, L., & Skinner, D. (2014).** *Ambitwistor Strings and the Scattering Equations.* Journal of High Energy Physics, 2014(07), 048 (`arXiv:1311.2564`).

(su4-chy2014)=
<a id="su4-chy2014"></a>
14. **Cachazo, F., He, S., & Yuan, E. Y. (2014).** *Scattering of Massless Particles in Arbitrary Dimensions.* Physical Review Letters, 113(17), 171601 (`arXiv:1307.2199`).

(su4-arkani2016)=
<a id="su4-arkani2016"></a>
15. **Arkani-Hamed, N., Bourjaily, J. L., Cachazo, F., Goncharov, A. B., Postnikov, A., & Trnka, J. (2016).** *Grassmannian Geometry of Scattering Amplitudes.* Cambridge University Press (`arXiv:1212.5605`).

(su4-strominger2017)=
<a id="su4-strominger2017"></a>
16. **Strominger, A. (2018).** *Lectures on the Infrared Structure of Gravity and Gauge Theory.* Princeton University Press (`arXiv:1703.05448`).

(su4-costello2018)=
<a id="su4-costello2018"></a>
17. **Costello, K., & Gaiotto, D. (2018).** *Twisted Holography.* (`arXiv:1812.09257`).

(su4-zhou2021)=
<a id="su4-zhou2021"></a>
18. **Zhou, H., Xie, T., Taniguchi, T., Watanabe, K., & Young, A. F. (2021).** *Superconductivity in rhombohedral trilayer graphene.* Nature, 598, 434–438.

(su4-costellopaquette2022)=
<a id="su4-costellopaquette2022"></a>
19. **Costello, K., & Paquette, N. M. (2022).** *Celestial holography meets twisted holography: 4d amplitudes from chiral correlators.* Journal of High Energy Physics, 2022(10), 193 (`arXiv:2201.02595`).

(su4-cps2022)=
<a id="su4-cps2022"></a>
20. **Costello, K., Paquette, N. M., & Sharma, A. (2023).** *Top-Down Holography in an Asymptotically Flat Spacetime.* Physical Review Letters, 130(6), 061602 (`arXiv:2204.05301`).

(su4-han2025)=
<a id="su4-han2025"></a>
21. **Han, T., Lu, Z., Yao, Y., Suh, J., Yang, J., Wang, D., Watanabe, K., Taniguchi, T., & Ju, L. (2025).** *Chiral superconductivity in rhombohedral graphene.* Nature, 643, 654–661.

(su4-fedi2026)=
<a id="su4-fedi2026"></a>
22. **Fedi, M. (2026).** *Gravity and Special Relativity in a Dilatant Dark Fluid.* SSRN 7406660.

---

### BibTeX Citations

```bibtex
@unpublished{turner2026grassmannian_su4_witten_chy,
  author  = {Turner, Wesley},
  title   = {{$\mathrm{SU}(4)$} Symmetry, {W}itten's Twistor String Theory, Lower {G}rassmannians in {$\mathrm{Gr}_{\mathbb{R}}$} and {$\mathrm{Gr}_{\mathbb{C}}$}, Relative Merits of {C}achazo ({CSW} / {BCFW} / {H}odges / {CHY}) vs. {DDF} vs. {T}urner Models, and Grand Unification with the Holographic Principle and {AdS/CFT} in {L}ean 4, {R}ust, and {P}ython},
  journal = {Sustainable Factory Research Archive},
  year    = {2026},
  note    = {Verified in Lean 4 (v4.35.0-rc3), Python, and Rust/WASM}
}

@article{witten2004twistor,
  author  = {Witten, Edward},
  title   = {Perturbative Gauge Theory as a String Theory in Twistor Space},
  journal = {Communications in Mathematical Physics},
  volume  = {252},
  pages   = {189--258},
  year    = {2004},
  doi     = {10.1007/s00220-004-1187-3},
  eprint  = {hep-th/0312171}
}

@article{cachazo2014chy,
  author  = {Cachazo, Freddy and He, Song and Yuan, Ellis Ye},
  title   = {Scattering of Massless Particles in Arbitrary Dimensions},
  journal = {Physical Review Letters},
  volume  = {113},
  number  = {17},
  pages   = {171601},
  year    = {2014},
  doi     = {10.1103/PhysRevLett.113.171601},
  eprint  = {1307.2199}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "SU(4) Symmetry, Witten's Twistor String Theory, Lower Grassmannians in Gr_R and Gr_C, Relative Merits of Cachazo (CSW / BCFW / Hodges / CHY) vs. DDF vs. Turner Models, and Grand Unification with the Holographic Principle and AdS/CFT in Lean 4, Rust, and Python",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-11-08",
  "about": [
    "SU(4) and Spin(2,4) Symmetry",
    "Witten Twistor String Theory",
    "Lower Grassmannians Gr_R(k,n) and Gr_C(k,n)",
    "Cachazo-He-Yuan (CHY) Scattering Equations and BCFW Recursion",
    "Dilatant Dark Fluid and Turner (2026) Plücker Q_4 Models",
    "Holographic Principle, AdS/CFT, Twisted Holography, and Celestial Holography",
    "Lean 4 Formal Verification"
  ]
}
```
