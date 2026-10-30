---
title: "AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian Gr_C(2,4) and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and psl(2|2)_c Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4"
description: "An arXiv-ready formal verification and numerical simulation paper formalizing the Maldacena/GKPW AdS/CFT correspondence, planar N=4 SYM / AdS_5 x S^5 integrability (Beisert et al. 2012, arXiv:1012.3982), indented Yangian secret symmetries (de Leeuw et al. 2012, arXiv:1204.2366), and their unification with Complex Grassmannian Gr_C(2,4) and Dilatant Dark Fluid (DDF) mechanics, both without splats and with Normed Tensor Gaussian Splats in Lean 4 and Rust/WASM."
---

(grassmannian-ads-cft-ddf-paper)=
# AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and $\mathfrak{psl}(2|2)_c$ Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4

- **Authors:** Wes Turner
- **Subjects:**
  - High Energy Physics - Theory (`hep-th`); Mathematical Physics (`math-ph`); Quantum Algebra (`math.QA`); General Relativity and Quantum Cosmology (`gr-qc`); Logic in Computer Science (`cs.LO`)
- **Formal Verification & Simulation Artifacts:**
  - `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`, `Signals.Scattering`, `Signals.DDF`, `Signals.QISM`, `Signals.Geometry`)
  - `signals-numerical-adapter` Rust/WASM Crate (`src/signals/numerical_adapter/src/polariton_spp.rs`)
- **Companion Papers:**
  1. [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](grassmannian-huygens-double-slit-oam-paper.md)
  2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.md)
  3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.md)
  4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)
  5. [Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4](grassmannian-splat-mechanics-paper.md)
  6. [Inelastic Scattering and the Heat Problem in Unified Grassmannian–DDF Mechanics: Inverse Compton, Stokes/Anti-Stokes Raman, Fourier vs. Cattaneo–Vernotte, and Subluminal Second-Sound Tensor Splatting in Lean 4](grassmannian-thermal-compton-raman-paper.md)
  7. [Polaritons and Surface Plasmon Polaritons (SPPs) in Unified Grassmannian–DDF Mechanics: Hopfield–Rabi Anticrossing, Lyddane–Sachs–Teller Reststrahlen Bands, $Gr_{\mathbb{C}}(2,4)$ Evanescent Skin-Depth Duality, and Sub-Wavelength Tensor Splatting in Lean 4](grassmannian-polariton-spp-mechanics-paper.md)
  8. [The Holographic Principle in Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: 't Hooft–Susskind Horizon Entropy, Gauss–Smarr Bulk Mass Recovery, Plücker Redshift Lapse, and Planck Tensor Splatting in Lean 4](grassmannian-holographic-principle-paper.md)
  9. [Unification, Engineering Applications, and Research Roadmap of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and Dilatant Dark Fluid (DDF) Mechanics: Cross-Domain Plücker Invariants, Photonic–Thermal–Quantum Systems, and Formal Verification in Lean 4](grassmannian-unification-applications-roadmap-paper.md)

---

## Abstract

Since **Juan Maldacena's (1998)** discovery of the **AdS/CFT correspondence** ([`hep-th/9711200`](#adscft-maldacena1998)) and its field-operator formulation by **Gubser, Klebanov, and Polyakov (1998)** ([`hep-th/9802109`](#adscft-gkp1998)) and **Witten (1998)** ([`hep-th/9802150`](#adscft-witten1998)), two major developments have transformed exact gauge–string duality:
1. **Planar AdS/CFT Integrability** ([Minahan & Zarembo 2003](#adscft-minahan2003); [Beisert et al. 2012, *Review of AdS/CFT Integrability: An Overview*, `arXiv:1012.3982`](#adscft-beisert2012)), which solves the spectral and scattering problems of planar $\mathcal{N}=4$ Super Yang–Mills (SYM) and free Type IIB superstrings on $\text{AdS}_5 \times S^5$ across all values of the 't Hooft coupling $\lambda = g_{\mathrm{YM}}^2 N_c = 4\pi^2 T_{\mathrm{str}}^2$ via the centrally extended $\mathfrak{psl}(2|2)_c = D(2,1;-1)$ $S$-matrix, Baxter $TQ$/Hirota $Y$-systems, and Grassmannian scattering integrals; and
2. **Secret (Bonus) Symmetries in AdS/CFT** ([Matsumoto, Moriyama & Torrielli 2007, `arXiv:0708.1285`](#adscft-matsumoto2007); [Beisert & Schwab 2011, `arXiv:1103.0646`](#adscft-beisert2011); [Berkovits & Mikhailov 2011, `arXiv:1103.1228`](#adscft-berkovits2011); [de Leeuw, Matsumoto, Moriyama, Regelskis & Torrielli 2012, *Secret Symmetries in AdS/CFT*, `arXiv:1204.2366`](#adscft-deleeuw2012)), which reveal an *indented Yangian* hypercharge generator $\widehat{\mathbb{B}} = B_0\operatorname{diag}(1,1,-1,-1)$ present at level $1$ (and odd levels) with non-vanishing supertrace $\operatorname{STr}(\widehat{\mathbb{B}}) = 4 B_0 \neq 0$, despite the absence of its level-$0$ partner $\mathbb{B}$ due to $\text{fermion} \otimes \text{fermion} \leftrightarrow \text{boson} \otimes \text{boson}$ scattering.

In this paper, we formalize AdS/CFT, planar integrability, and secret symmetries in **Lean 4** (`Signals.Scattering` and `Signals.DDF`) and **Rust/WASM** (`polariton_spp.rs`), and unify them with our **Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$** and **Dilatant Dark Fluid (DDF)** mechanics both **without splats** (splat-free continuum Plücker and hydrodynamic laws) and **with Normed 2D Tensor Gaussian Splats**:

1. **Maldacena/GKPW AdS/CFT Dictionary, Breitenlohner–Freedman Bound, Ryu–Takayanagi Entanglement Entropy, & KSS Viscosity Bound (`ads_cft_integrability_and_secret_symmetry_identities`)**:
   We prove the exact GKPW conformal dimension identities $\Delta_+ + \Delta_- = d$, $\Delta_+\Delta_- = -m^2 R_{\mathrm{AdS}}^2$, and $\Delta_+(\Delta_+ - d) = m^2 R_{\mathrm{AdS}}^2$ above the Breitenlohner–Freedman stability bound $m_{\mathrm{BF}}^2 R_{\mathrm{AdS}}^2 = -d^2 / 4$, the Ryu–Takayanagi $\text{AdS}_3/\text{CFT}_2$ relation $S_{\mathrm{EE}} = \frac{c_{\mathrm{BH}}}{3}\ln(\ell/\epsilon_{\mathrm{UV}})$, and positivity of the Kovtun–Son–Starinets shear viscosity bound $(\eta/s)_{\mathrm{KSS}} = \frac{\hbar}{4\pi k_B} > 0$.
2. **Planar Integrability (`arXiv:1012.3982`) & $\mathfrak{psl}(2|2)_c$ Secret Symmetries (`arXiv:1204.2366`)**:
   We formalize the all-loop bound-state magnon dispersion $E^2(M, \lambda, p) = M^2 + \frac{\lambda}{\pi^2}\sin^2(p/2)$, the exact one-loop Konishi ($L=4, M=2$, $u_{\mathrm{K}} = \pm \frac{1}{2\sqrt{3}}$) anomalous dimension check figure $2\,\delta D_1(\lambda, u_{\mathrm{K}}) = \frac{3\lambda}{4\pi^2}$, the braided $\mathfrak{psl}(2|2)_c$ central-charge identity $\mathbb{C}(p)\mathbb{C}^\dagger(p) + \mathbb{C}(p) + \mathbb{C}^\dagger(p) = 0$ and quasi-cocommutative coproduct $(1+\mathbb{C}(p_1))(1+\mathbb{C}(p_2)) = 1 + \Delta(\mathbb{C})$, the short vs. long $\mathfrak{gl}(2|2)$ multiplet compression $4 M < 16(M + 1)$, the indented Yangian secret supertrace $\operatorname{STr}(\widehat{\mathbb{B}}) = 4 B_0$ with $\operatorname{Tr}(\widehat{\mathbb{B}}) = 0$, and the degeneracy $\operatorname{Tr}(DA) = \det(DA) = 0$ of the $q$-deformed Hubbard affine Cartan matrix $DA$.
3. **Without Splats: Exact 3-Term Plücker Realization of the $\mathfrak{psl}(2|2)_c$ Secret Outer Automorphism & Universal $\text{AdS}_5$/DDF Redshift Product (`RiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification`)**:
   Embedding the Beisert–Torrielli $\mathfrak{psl}(2|2)_c$ outer-automorphism parameters $(a,b,c,d)$ (`arXiv:1204.2366`, Eq. (2.11)) into $Gr_{\mathbb{C}}(2,4)$ via
   $$W_{\mathrm{sec}}(a,b,c,d) = \begin{pmatrix} a & b & a & -b \\ c & d & -c & d \end{pmatrix} \in \mathbb{C}^{2 \times 4}$$
   proves that its 6 Plücker minors satisfy $\Delta_{01}^{\mathbb{C}} = \Delta_{23}^{\mathbb{C}} = ad - bc = M$, $\Delta_{03}^{\mathbb{C}} = -\Delta_{12}^{\mathbb{C}} = ad + bc = \mathbb{H}$, and $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = -4(ab)(cd) = -4\mathbb{C}\mathbb{C}^\dagger$, so the **3-term quadratic Plücker identity on $Gr_{\mathbb{C}}(2,4)$ IS IDENTICALLY the $\mathfrak{psl}(2|2)_c$ central-charge dispersion relation**:
   $$\mathbb{H}^2 - 4\,\mathbb{C}\,\mathbb{C}^\dagger = (ad + bc)^2 - 4(ab)(cd) = (ad - bc)^2 = M^2 = 1 \quad (ad - bc = 1).$$
   Simultaneously, the $Gr_{\mathbb{C}}(2,4)$ channel product $|w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2 = 1 - \beta^2$ reproduces both the Poincaré $\text{AdS}_5$ planar black-brane emblackening factor $1 - (z/z_H)^4$ ($\beta = (z/z_H)^2$) and the 4D DDF Painlevé–Gullstrand lapse $1 - r_H/r$ ($\beta = \sqrt{r_H/r}$).
4. **With Normed Tensor Gaussian Splats: Holographic RG Scale-Radius Flow (`adsHolographicRGSplat`)**:
   Identifying the bulk Poincaré $\text{AdS}$ radial coordinate $z_{\mathrm{rg}} > 0$ with the boundary CFT Tensor Gaussian Splat coarse-graining width $\sigma_1 = \sigma_2 = z_{\mathrm{rg}}$ proves that an UV-to-IR coarse-graining dilatation $z_{\mathrm{UV}} \mapsto \lambda_{\mathrm{rg}}\,z_{\mathrm{UV}}$ ($\lambda_{\mathrm{rg}} > 1$) scales the phase-space covariance determinant by $\det\Sigma_{\mathrm{IR}} = \lambda_{\mathrm{rg}}^4\det\Sigma_{\mathrm{UV}} > \det\Sigma_{\mathrm{UV}}$ and relaxes the repulsive Madelung core Bohm quantum potential by the exact conformal weight:
   $$Q_{\mathrm{core}}(\Sigma_{\mathrm{IR}}) = \frac{1}{\lambda_{\mathrm{rg}}^2}\,Q_{\mathrm{core}}(\Sigma_{\mathrm{UV}}) \le Q_{\mathrm{core}}(\Sigma_{\mathrm{UV}}).$$

---

## 1. The AdS/CFT Correspondence: Maldacena (1998), GKPW Dictionary, KSS Fluid/Gravity Bound, and Ryu–Takayanagi Entanglement

### 1.1 Maldacena's Large-$N_c$ Decoupling Limit & Coupling–Tension Dictionary

In his seminal 1998 paper ([Maldacena 1998, `arXiv:hep-th/9711200`](#adscft-maldacena1998)), Juan Maldacena considered a stack of $N_c$ coincident $D3$-branes in Type IIB superstring theory and took the low-energy decoupling limit $\alpha' \to 0$ with fixed radial coordinate $U = r / \alpha'$. This established an exact duality between four-dimensional $\mathcal{N}=4$ $SU(N_c)$ Super Yang–Mills (SYM) theory on the conformally flat boundary $\partial\text{AdS}_5 \cong \mathbb{R}^{1,3}$ and Type IIB superstring theory on $\text{AdS}_5 \times S^5$ with equal curvature radii $R_{\mathrm{AdS}} = R_{S^5}$:

$$
\lambda = g_{\mathrm{YM}}^2 N_c = \frac{R_{\mathrm{AdS}}^4}{\alpha'^2} = 4\pi^2 T_{\mathrm{str}}^2, \qquad
T_{\mathrm{str}} = \frac{R_{\mathrm{AdS}}^2}{2\pi\alpha'} = \frac{\sqrt{\lambda}}{2\pi}, \qquad
\frac{1}{N_c} = \frac{g_{\mathrm{str}}}{4\pi^2 T_{\mathrm{str}}^2}
$$

(`adsTftHooftCoupling` and `adsCouplingFromStringTension` in [src/signals/Signals/Scattering.lean](../src/signals/Signals/Scattering.lean#L1562-L1579); [Beisert et al. 2012, `arXiv:1012.3982`](#adscft-beisert2012), Section *Parameter Space*).

### 1.2 The Gubser–Klebanov–Polyakov–Witten (GKPW) Mass–Dimension Dictionary & Breitenlohner–Freedman Bound

By [Gubser, Klebanov, and Polyakov (1998)](#adscft-gkp1998) and [Witten (1998)](#adscft-witten1998), the bulk string partition function with boundary field values $\phi|_{\partial\text{AdS}_{d+1}} = J$ equals the generating functional of connected correlation functions in $\text{CFT}_d$:

$$
Z_{\mathrm{string}}\bigl[\phi\big|_{\partial\text{AdS}_{d+1}} = J\bigr] = \left\langle \exp\!\left(\int_{\partial\text{AdS}_{d+1}} d^d x\,J(x)\,\mathcal{O}(x)\right) \right\rangle_{\text{CFT}_d}.
$$

Near the Poincaré boundary $z \to 0$ of $\text{AdS}_{d+1}$ ($ds^2 = \frac{R_{\mathrm{AdS}}^2}{z^2}(dz^2 + \eta_{\mu\nu}dx^\mu dx^\nu)$), a bulk scalar field of mass $m$ scales as $\phi(z,x) \sim z^{\Delta_-} J(x) + z^{\Delta_+} \langle\mathcal{O}(x)\rangle$, where $\Delta_\pm$ (`adsCftScalingDimensionPlus`, `adsCftScalingDimensionMinus`) solve the characteristic quadratic equation $\Delta(\Delta - d) = m^2 R_{\mathrm{AdS}}^2$:

$$
\Delta_\pm(d, m^2 R_{\mathrm{AdS}}^2) = \frac{d}{2} \pm \sqrt{\left(\frac{d}{2}\right)^2 + m^2 R_{\mathrm{AdS}}^2}, \qquad
m^2 R_{\mathrm{AdS}}^2 \ge m_{\mathrm{BF}}^2 R_{\mathrm{AdS}}^2 = -\frac{d^2}{4}
$$

([Breitenlohner & Freedman 1982](#adscft-bf1982)). Theorem `ads_cft_integrability_and_secret_symmetry_identities` machine-checks the Vieta and boundary identities:
- $\Delta_+ + \Delta_- = d$ (shadow dimension pairing),
- $\Delta_+\,\Delta_- = -m^2 R_{\mathrm{AdS}}^2$,
- $\Delta_+(\Delta_+ - d) = m^2 R_{\mathrm{AdS}}^2$,
- $\Delta_+(d, -d^2/4) = d/2$ (saturation at the Breitenlohner–Freedman bound),
- $\Delta_+(d, 0) = d$ and $\Delta_-(d, 0) = 0$ (marginal operator dual to a massless bulk scalar such as the axion-dilaton in $\text{AdS}_5/\text{CFT}_4$).

### 1.3 Fluid/Gravity Duality (KSS Bound) & Ryu–Takayanagi Entanglement Entropy

At finite temperature, a planar black brane in $\text{AdS}_5$ is dual to a strongly coupled thermal $\mathcal{N}=4$ SYM plasma ([Provenance Chat Log: Fluid/Gravity Duality (2026)](#adscft-chat-fluidgravity2026), lines 136–325). Absorbing low-frequency gravitons on the bulk horizon yields the **Kovtun–Son–Starinets (KSS) universal lower bound** ([Kovtun, Son & Starinets 2005](#adscft-kss2005), `kssShearViscosityEntropyBound`):

$$
\left(\frac{\eta_{\mathrm{shear}}}{s_{\mathrm{ent}}}\right)_{\mathrm{KSS}} = \frac{\hbar}{4\pi k_B} > 0.
$$

Similarly, in $\text{AdS}_3/\text{CFT}_2$, the **Brown–Henneaux central charge** ([Brown & Henneaux 1986](#adscft-brown1986), `brownHenneauxCentralCharge`) $c_{\mathrm{BH}} = \frac{3 R_{\mathrm{AdS}}}{2 G_N^{(3)}}$ and the **Ryu–Takayanagi minimal geodesic formula** ([Ryu & Takayanagi 2006](#adscft-ryu2006), `ryuTakayanagiEntanglementEntropyAdS3`) satisfy:

$$
S_{\mathrm{EE}}(\ell, \epsilon_{\mathrm{UV}}) = \frac{L_{\mathrm{geod}}(\ell, \epsilon_{\mathrm{UV}})}{4 G_N^{(3)}} = \frac{R_{\mathrm{AdS}}}{2 G_N^{(3)}}\ln\!\left(\frac{\ell}{\epsilon_{\mathrm{UV}}}\right) = \frac{c_{\mathrm{BH}}}{3}\ln\!\left(\frac{\ell}{\epsilon_{\mathrm{UV}}}\right).
$$

---

## 2. Planar AdS/CFT Integrability: Spin Chains, Spectral Curves, Magnon Dispersion, and the Konishi Benchmark (`arXiv:1012.3982`)

As synthesized in the 23-chapter coordinated review by **Beisert et al. (2012)** (*Review of AdS/CFT Integrability: An Overview*, *Lett. Math. Phys.* 99, 3–32, [`arXiv:1012.3982`](#adscft-beisert2012)), planar ($N_c \to \infty$) $\mathcal{N}=4$ SYM and free ($g_{\mathrm{str}} = 0$) Type IIB strings on $\text{AdS}_5 \times S^5$ form an **exact quantum integrable system** bridging weak coupling ($\lambda \ll 1$, perturbative Feynman diagrams) and strong coupling ($\lambda \gg 1$, semiclassical worldsheet sigma model):

1. **Spin-Chain Mapping & One-Loop Bethe Ansatz** ([Minahan & Zarembo 2003](#adscft-minahan2003); `arXiv:1012.3982` Sec. I.1):
   Single-trace gauge-invariant operators $\mathcal{O} = \operatorname{Tr}(Z Z \Phi Z \cdots)$ of length $L$ with $M$ impurity magnons map to states of an integrable $\mathfrak{psu}(2,2|4)$ spin chain. At one loop in the $\mathfrak{su}(2)$ sector, the Bethe rapidities $u_k$ satisfy:
   $$\left(\frac{u_k + i/2}{u_k - i/2}\right)^L = \prod_{j \neq k}^M \frac{u_k - u_j + i}{u_k - u_j - i}, \qquad \prod_{j=1}^M \frac{u_j + i/2}{u_j - i/2} = 1, \qquad \delta D_1 = \sum_{j=1}^M \frac{\lambda}{8\pi^2\bigl(u_j^2 + \frac{1}{4}\bigr)}$$
   (`betheOneLoopMagnonEnergy` in `Signals.Scattering`).
2. **The Konishi Operator Check Figure ($L=4, M=2$)** (`arXiv:1012.3982` Sec. I.2):
   For the simplest non-protected local operator ($L=4, M=2$), the cyclicity and Bethe equations fix $u_1 = -u_2 = \frac{1}{2\sqrt{3}}$ ($u_k^2 = \frac{1}{12}$, so $u_k^2 + \frac{1}{4} = \frac{1}{3}$). Summing the two magnons yields the exact one-loop Konishi anomalous dimension proved in `ads_cft_integrability_and_secret_symmetry_identities`:
   $$\delta D_{\mathrm{Konishi}}^{(1)}(\lambda) = 2 \cdot \frac{\lambda}{8\pi^2(1/12 + 1/4)} = \frac{3\lambda}{4\pi^2},$$
   which extends at four loops (`arXiv:1012.3982` Sec. I.2) to:
   $$\delta D_{\mathrm{Konishi}}(\lambda) = \frac{3\lambda}{4\pi^2} - \frac{3\lambda^2}{16\pi^4} + \frac{21\lambda^3}{256\pi^6} - \frac{\bigl(78 - 18\zeta(3) + 45\zeta(5)\bigr)\lambda^4}{2048\pi^8} + \mathcal{O}(\lambda^5).$$
3. **All-Loop $\mathfrak{psu}(2|2)^2 \ltimes \mathbb{R}^3$ Bound-State Magnon Dispersion Relation** ([Beisert 2005](#adscft-beisert2005); [Dorey 2006](#adscft-dorey2006); `arXiv:1012.3982` Sec. III.2):
   Representation theory of the centrally extended $\mathfrak{psu}(2|2)^2 \ltimes \mathbb{R}^3$ residual symmetry algebra above the BMN vacuum $\operatorname{Tr}(Z^J)$ fixes the exact all-loop dispersion relation for an $M$-magnon bound state (`adsMagnonDispersionSq`, `adsMagnonDispersion`):
   $$E_{\mathrm{mag}}(M, \lambda, p) = \sqrt{M^2 + \frac{\lambda}{\pi^2}\sin^2\!\left(\frac{p}{2}\right)} = \sqrt{M^2 + 4 g_{\mathrm{int}}^2\sin^2\!\left(\frac{p}{2}\right)} \ge M.$$
4. **Cusp Anomalous Dimension $D_{\mathrm{cusp}}(\lambda)$ Interpolating Benchmark** (`arXiv:1012.3982` Sec. III.4):
   For large-spin twist-2 operators, the BES integral equation smoothly interpolates between weak and strong coupling:
   $$D_{\mathrm{cusp}}(\lambda) = \frac{\lambda}{2\pi^2} - \frac{\lambda^2}{96\pi^2} + \frac{11\lambda^3}{23040\pi^2} - \cdots \;\underset{\lambda\to\infty}{=}\; \frac{\sqrt{\lambda}}{\pi} - \frac{3\ln 2}{\pi} - \frac{\mathrm{K}_{\mathrm{Catalan}}}{\pi\sqrt{\lambda}} - \cdots.$$

---

## 3. Secret Symmetries in AdS/CFT: Centrally Extended $\mathfrak{psl}(2|2)_c$, Braided Coproducts, and Indented Yangians (`arXiv:1204.2366`)

In **de Leeuw, Matsumoto, Moriyama, Regelskis, and Torrielli (2012)** (*Secret Symmetries in AdS/CFT*, *Physica Scripta* 86, 028502, [`arXiv:1204.2366`](#adscft-deleeuw2012)), the authors review the remarkable discovery ([Matsumoto, Moriyama & Torrielli 2007](#adscft-matsumoto2007)) that the AdS/CFT integrable system possesses a **secret (bonus) quantum-group symmetry** $\widehat{\mathbb{B}}$ at Yangian level $1$ (and odd levels) that has **no level-$0$ partner**:

### 3.1 Level-0 Centrally Extended $\mathfrak{psl}(2|2)_c = D(2,1;-1)$ and Braided Central Charges

The level-$0$ algebra $\mathfrak{psl}(2|2)_c$ has even part $\mathfrak{sl}(2)_L \oplus \mathfrak{sl}(2)_R \oplus \operatorname{span}\{\mathbb{H}, \mathbb{C}, \mathbb{C}^\dagger\}$ and odd supercharges $\mathbb{Q}_\alpha^a, \mathbb{G}_a^\alpha$ satisfying (`arXiv:1204.2366`, Sec. 2.1):

$$
\{\mathbb{Q}_\alpha^a, \mathbb{Q}_\beta^b\} = \epsilon_{\alpha\beta}\epsilon^{ab}\mathbb{C}, \qquad
\{\mathbb{G}_a^\alpha, \mathbb{G}_b^\beta\} = \epsilon^{\alpha\beta}\epsilon_{ab}\mathbb{C}^\dagger, \qquad
\{\mathbb{Q}_\alpha^a, \mathbb{G}_b^\beta\} = \delta_b^a \mathbb{R}_\alpha^\beta + \delta_\alpha^\beta \mathbb{L}_b^a + \frac{1}{2}\delta_b^a\delta_\alpha^\beta \mathbb{H}.
$$

Its braided Hopf coproduct $\Delta(\mathbb{J}^A) = \mathbb{J}^A \otimes \mathbb{1} + e^{i[[A]]p} \otimes \mathbb{J}^A$ (`Eq. (2.1)`) is quasi-cocommutative ($\Delta^{\mathrm{op}}(\mathbb{C}) = \Delta(\mathbb{C})$) if and only if the central charges are linked to the worldsheet momentum braiding operator $e^{\pm ip}$ by (`Eq. (2.4)–(2.5)`, `psl22BraidedCentralChargeC`, `psl22BraidedCentralChargeCDag`, `psl22BraidedCoproductC`):

$$
e^{ip} = \mathbb{C}(p) + \mathbb{1}, \qquad e^{-ip} = \mathbb{C}^\dagger(p) + \mathbb{1}
\implies \Delta(\mathbb{C}) = \mathbb{C} \otimes \mathbb{1} + \mathbb{1} \otimes \mathbb{C} + \mathbb{C} \otimes \mathbb{C} = \Delta^{\mathrm{op}}(\mathbb{C}).
$$

As machine-checked in `ads_cft_integrability_and_secret_symmetry_identities`, this immediately enforces the nonlinear central-charge constraint:

$$
\mathbb{C}(p)\,\mathbb{C}^\dagger(p) + \mathbb{C}(p) + \mathbb{C}^\dagger(p) = (e^{ip} - 1)(e^{-ip} - 1) + (e^{ip} - 1) + (e^{-ip} - 1) = 0,
$$

and the two-magnon momentum factorization $(1 + \mathbb{C}(p_1))(1 + \mathbb{C}(p_2)) = 1 + \Delta(\mathbb{C})(\mathbb{C}(p_1), \mathbb{C}(p_2)) = e^{i(p_1 + p_2)}$.

### 3.2 Why the Secret Symmetry $\widehat{\mathbb{B}}$ Is Indented (Absent at Level 0, Present at Level 1)

In the $(2|2)$-graded module $\mathbb{C}^{2|2}$ (`arXiv:1204.2366`, Sec. 2.3 & Sec. 3.1), generic long representations of $\mathfrak{gl}(2|2)$ have dimension $\dim V_{\mathrm{long}}(j_1, j_2) = 16(2 j_1 + 1)(2 j_2 + 1)$ (`gl22LongRepDim`), whereas physical $M$-magnon bound states live in atypical short representations of dimension $\dim V_{\mathrm{short}}(M) = 4 M < 16(M + 1)$ (`psl22ShortBoundStateDim`, with $\dim = 4$ for the fundamental $M=1$ multiplet $(|\phi^1\rangle, |\phi^2\rangle \mid |\psi^1\rangle, |\psi^2\rangle)$).

Every generator of $Y(\mathfrak{psl}(2|2)_c)$ is **supertraceless** ($\operatorname{STr}(J) = J_{00} + J_{11} - J_{22} - J_{33} = 0$). By contrast, the secret hypercharge generator (`secretSymmetryMatrix` in `Signals.Scattering`):

$$
\widehat{\mathbb{B}}(B_0) = B_0\,\operatorname{diag}(1, 1, -1, -1)
$$

has **vanishing ordinary trace** ($\operatorname{Tr}(\widehat{\mathbb{B}}) = 0$) but **non-vanishing supertrace** (`supertrace22`):

$$
\operatorname{STr}\bigl(\widehat{\mathbb{B}}(B_0)\bigr) = B_0\bigl((1 + 1) - (-1 - 1)\bigr) = 4 B_0 \neq 0.
$$

Why does the level-$0$ operator $\Delta(\mathbb{B}) = \mathbb{B} \otimes \mathbb{1} + \mathbb{1} \otimes \mathbb{B}$ fail to commute with the AdS/CFT $R$-matrix, while the level-$1$ braided operator (`arXiv:1204.2366`, Eq. (3.1)–(3.2)):

$$
\Delta(\widehat{\mathbb{B}}) = \widehat{\mathbb{B}} \otimes \mathbb{1} + \mathbb{1} \otimes \widehat{\mathbb{B}} + e^{\frac{i}{2}p}\mathbb{G}_a^\alpha \otimes \mathbb{Q}_\alpha^a + e^{-\frac{i}{2}p}\mathbb{Q}_\alpha^a \otimes \mathbb{G}_a^\alpha
$$

satisfies $\Delta^{\mathrm{op}}(\widehat{\mathbb{B}})\,R = R\,\Delta(\widehat{\mathbb{B}})$?
- **Level-0 Breakdown**: Beisert's $R$-matrix includes the two-body conversion process $\text{fermion} \otimes \text{fermion} \longrightarrow \text{boson} \otimes \text{boson}$ ($|\psi^1\psi^2\rangle \leftrightarrow |\phi^1\phi^2\rangle$), which changes the naive fermionic grading $\Delta(\mathbb{B})$ by $\Delta B = (+2) - (-2) = +4$.
- **Level-1 Restoration & Level-Raising Property**: The bilinear supercharge tail $e^{\frac{i}{2}p}\mathbb{G}\otimes\mathbb{Q} + e^{-\frac{i}{2}p}\mathbb{Q}\otimes\mathbb{G}$ supplies the exact off-diagonal $|\psi^1\psi^2\rangle \leftrightarrow |\phi^1\phi^2\rangle$ counterterm, and commuting $\widehat{\mathbb{B}}$ with the level-$0$ supercharges raises the Yangian level (`arXiv:1204.2366`, Eq. (3.5) & Sec. 3.3):
  $$\widehat{\mathbb{Q}}_\alpha^a = [\widehat{\mathbb{B}}, \mathbb{Q}_\alpha^a] + i(1 + e^{-ip})\epsilon^{ab}\epsilon_{\alpha\beta}\mathbb{G}_b^\beta, \qquad [\widehat{\mathfrak{B}}, \mathfrak{Q}^{\alpha b}] = +\widehat{\mathfrak{Q}}^{\alpha b}.$$

Across the five sectors reviewed in [de Leeuw et al. (2012, `arXiv:1204.2366`)](#adscft-deleeuw2012), the secret symmetry manifests as:
1. **Worldsheet $S$-Matrix / Spectral Problem** (Sec. 3.1): $\Delta^{\mathrm{op}}(\widehat{\mathbb{B}}) R = R \Delta(\widehat{\mathbb{B}})$ for all bound-state representations $4 M$. In `Signals.Scattering`, we formalize the full $16 \times 16$ $\mathbb{Z}_2$-graded permutation matrix $\Pi_{16}$ (`psl22GradedSwap16`), the 6-parameter $16 \times 16$ worldsheet $R$-matrix $R_{16}(A_B, B_B, D_F, E_F, G_{BF}, L_{BF})$ (`psl22WorldsheetRMatrix16`), the diagonal secret coproduct $\Delta_{\mathrm{diag}}(\widehat{\mathbb{B}})(B_1, B_2)$ (`psl22SecretCoproductDiag16`), and the antisymmetric off-diagonal Yangian tail $\Delta_{\mathrm{tail}}\bigl((B_1 - B_2)L_{BF}\bigr)$ (`psl22YangianTail16`), proving (`psl22_rmatrix16_secret_coproduct_intertwining`):
   - $\Pi_{16}^2 = I_{16}$ and $\Delta_{\mathrm{diag}}^{\mathrm{op}}(\widehat{\mathbb{B}})(B_1, B_2)\,\Pi_{16} = \Pi_{16}\,\Delta_{\mathrm{diag}}(\widehat{\mathbb{B}})(B_1, B_2)$,
   - When $B_1 \neq B_2$ and $L_{BF} \neq 0$, the diagonal secret coproduct alone leaves a mixed boson–fermion diagonal residual $2(B_2 - B_1)L_{BF}$ at $|\phi^1 \otimes \psi^1\rangle$,
   - Adding the off-diagonal Yangian tail $\Delta_{\mathrm{full}}(\widehat{\mathbb{B}})(B_1, B_2, G_{BF}, L_{BF}) = G_{BF}\Delta_{\mathrm{diag}}(\widehat{\mathbb{B}})(B_1, B_2) + \Delta_{\mathrm{tail}}\bigl((B_1 - B_2)L_{BF}\bigr)$ (`psl22SecretCoproductFull16`) cancels this residual identically across all $16 \times 16$ entries:
     $$\Delta_{\mathrm{full}}^{\mathrm{op}}(\widehat{\mathbb{B}})(B_1, B_2, G_{BF}, L_{BF})\,R_{16}(A_B, B_B, D_F, E_F, G_{BF}, L_{BF}) = R_{16}(A_B, B_B, D_F, E_F, G_{BF}, L_{BF})\,\Delta_{\mathrm{full}}(\widehat{\mathbb{B}})(B_1, B_2, G_{BF}, L_{BF}).$$
2. **Open-String Boundary $K$-Matrices** (Sec. 3.2): Twisted secret charges $\widetilde{\mathbb{Q}}_{\alpha,\pm 1}^2, \widetilde{\mathbb{G}}_{2,\pm 1}^\alpha$ for $Y=0$ maximal giant gravitons ($D3$-branes) and horizontal/vertical $D5$-branes.
3. **Planar $n$-Point Scattering Amplitudes & Grassmannian Integral** (Sec. 3.3; [Beisert & Schwab 2011](#adscft-beisert2011)): The bonus level-$1$ generator $\widehat{\mathfrak{B}}$ leaves the Grassmannian integral formula ([Arkani-Hamed et al. 2010](#adscft-arkani2010)) invariant and satisfies the length-changing anomaly equation $\widehat{\mathfrak{B}}\mathcal{A}_n + \widehat{\mathfrak{B}}^+\mathcal{A}_{n-1} = 0$.
4. **Pure-Spinor Worldsheet Sigma Model** (Sec. 3.4; [Berkovits & Mikhailov 2011](#adscft-berkovits2011)): Lifting $T(z) \in PSU(2,2|4)$ to $SU(2,2|4)$ and supertracing with the hypercharge matrix $s = \operatorname{diag}(\mathbb{1}_4, -\mathbb{1}_4)$ generates BRST-closed nonlocal bonus charges $\operatorname{STr}(s\log T(z))$ at **odd levels only**.
5. **Quantum-Deformed Hubbard Affine Algebra $\widehat{Q} = U_q(\widehat{\mathfrak{sl}}(2|2))_c$** (Sec. 3.5; [de Leeuw, Regelskis & Torrielli 2011](#adscft-deleeuw2011)): With symmetric Cartan matrix (`qDeformedHubbardCartanDA` in `Signals.Scattering`):
   $$DA = \begin{pmatrix} 2 & -1 & 0 & -1 \\ -1 & 0 & 1 & 0 \\ 0 & 1 & -2 & 1 \\ -1 & 0 & 1 & 0 \end{pmatrix}, \qquad \operatorname{Tr}(DA) = 0, \qquad \det(DA) = 0,$$
   the bound-state $R$-matrix admits a pair of $q$-deformed secret symmetries $(\Delta\mathbb{B}_E, \Delta\mathbb{B}_F)$ at levels $+1$ and $-1$ that coalesce into $\Delta\widehat{\mathbb{B}}$ as $q \to 1$.

---

## 4. Unification of Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ and DDF Mechanics with AdS/CFT and Secret Symmetries (With and Without Splats)

### 4.1 Without Splats: The 3-Term Plücker Identity on $Gr_{\mathbb{C}}(2,4)$ Is the $\mathfrak{psl}(2|2)_c$ Outer-Automorphism Central-Charge Dispersion Law

In `arXiv:1204.2366` Section 2.3 (Eqs. (2.10)–(2.11)), any short representation of $\mathfrak{psl}(2|2)_c$ is constructed by an $\mathfrak{sl}(2)$ outer automorphism parameterized by four complex numbers $(a, b, c, d)$:

$$
\mathbb{Q}_\alpha^a = a\,E_{\alpha a} + b\,\epsilon_{\alpha\beta}\epsilon^{ab} E_{b\beta}, \qquad
\mathbb{G}_a^\alpha = c\,\epsilon_{ab}\epsilon^{\alpha\beta} E_{\beta b} + d\,E_{a\alpha},
$$

subject to the unimodularity constraint $a d - b c = 1$ (or $a d - b c = M$ for an $M$-magnon bound state), with central charges $\mathbb{H} = a d + b c$, $\mathbb{C} = a b$, and $\mathbb{C}^\dagger = c d$.

In `Signals.DDF`, we embed $(a, b, c, d)$ directly into the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ via (`psl22SecretAutomorphismGr24Matrix`):

$$
W_{\mathrm{sec}}(a, b, c, d) = \begin{pmatrix} a & b & a & -b \\ c & d & -c & d \end{pmatrix} \in \mathbb{C}^{2 \times 4}.
$$

Theorem `RiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification` proves that the six $2 \times 2$ Plücker minors $\Delta_{ij}^{\mathbb{C}}(W_{\mathrm{sec}})$ evaluate to:
- **Uncrossed Minors ($\Delta_{01}^{\mathbb{C}}, \Delta_{23}^{\mathbb{C}}$)**:
  $$\Delta_{01}^{\mathbb{C}}(W_{\mathrm{sec}}) = a d - b c = M, \qquad \Delta_{23}^{\mathbb{C}}(W_{\mathrm{sec}}) = a d - (-b)(-c) = a d - b c = M,$$
- **Crossed Minors ($\Delta_{03}^{\mathbb{C}}, \Delta_{12}^{\mathbb{C}}$)**:
  $$\Delta_{03}^{\mathbb{C}}(W_{\mathrm{sec}}) = a d - (-b)c = a d + b c = \mathbb{H}, \qquad \Delta_{12}^{\mathbb{C}}(W_{\mathrm{sec}}) = b(-c) - a d = -(a d + b c) = -\mathbb{H},$$
- **Collector Minors ($\Delta_{02}^{\mathbb{C}}, \Delta_{13}^{\mathbb{C}}$)**:
  $$\Delta_{02}^{\mathbb{C}}(W_{\mathrm{sec}}) = -2 a c, \qquad \Delta_{13}^{\mathbb{C}}(W_{\mathrm{sec}}) = 2 b d \implies \Delta_{02}^{\mathbb{C}}(W_{\mathrm{sec}})\,\Delta_{13}^{\mathbb{C}}(W_{\mathrm{sec}}) = -4(a b)(c d) = -4\,\mathbb{C}\,\mathbb{C}^\dagger.$$

Substituting these into the universal 3-term quadratic Plücker identity $\Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}} - \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} + \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}} = 0$ on $Gr_{\mathbb{C}}(2,4)$ yields:

$$
(a d - b c)^2 - \bigl(-4(a b)(c d)\bigr) - (a d + b c)^2 = 0 \iff \mathbb{H}^2 - 4\,\mathbb{C}\,\mathbb{C}^\dagger = (a d - b c)^2 = M^2!
$$

Thus, **the 3-term Plücker identity on $Gr_{\mathbb{C}}(2,4)$ is the exact geometric origin of the $\mathfrak{psl}(2|2)_c$ outer-automorphism central-charge invariant $\mathbb{H}^2 - 4\mathbb{C}\mathbb{C}^\dagger = M^2$ and the all-loop AdS/CFT magnon dispersion relation $E^2 - \frac{\lambda}{\pi^2}\sin^2(p/2) = M^2$!**

### 4.2 Without Splats: Universal $Gr_{\mathbb{C}}(2,4)$ Plücker Redshift Law & Physical Discriminators Between AdS/CFT and DDF

In Poincaré $\text{AdS}_{d+1}$ ($d=4$ for $\text{AdS}_5$), a planar black brane with horizon at radial depth $z_H > 0$ has metric emblackening factor (`adsPlanarBlackBraneEmblackening`):

$$
f_{\text{AdS}_5}(z) = 1 - \left(\frac{z}{z_H}\right)^4 > 0 \qquad (0 < z < z_H).
$$

Theorem `RiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification` proves that the **same** splat-free $Gr_{\mathbb{C}}(2,4)$ twistor matrix family $\operatorname{ddfThermalGr24Matrix}(\beta, \theta)$ governs both $\text{AdS}_5$ planar black branes (with $\beta_{\text{AdS}_5}(z) = (z/z_H)^2$) and 4D DDF Painlevé–Gullstrand acoustic horizons (with $\beta_{\mathrm{DDF}}(r) = \sqrt{r_H/r}$):

$$
\bigl|w_A^{\mathbb{C}}(M_{\text{AdS}_5}(z))\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\text{AdS}_5}(z))\bigr|^2 = 1 - \left(\frac{z}{z_H}\right)^4, \qquad
\bigl|w_A^{\mathbb{C}}(M_{\mathrm{DDF}}(r))\bigr|^2\,\bigl|w_B^{\mathbb{C}}(M_{\mathrm{DDF}}(r))\bigr|^2 = 1 - \frac{r_H}{r}.
$$

At the same time, our formalization maintains a strict physical boundary between $\text{AdS}_5/\text{CFT}_4$ and $(3+1)$-dimensional $Gr_{\mathbb{C}}(2,4)$/DDF mechanics ([Provenance Chat Log: Dilatant Fluid vs. GR & AdS/CFT (2026)](#adscft-chat-fluidgravity2026), lines 299–325):

| Physical Observable / Regime | $\text{AdS}_5/\text{CFT}_4$ & Planar Integrability (`Signals.Scattering`) | Unified $Gr_{\mathbb{C}}(2,4)$ & DDF Mechanics (`Signals.DDF`) | Machine-Checked Lean 4 Theorem |
|---|---|---|---|
| **Spacetime Geometry & Asymptotics** | 5D Anti-de Sitter bulk ($\Lambda < 0$) with 4D conformal boundary $\partial\text{AdS}_5$ | 4D Painlevé–Gullstrand river flow (`RiverExterior`) with asymptotically flat ($r\to\infty$) Minkowski acoustic metric | `material_minkowski_interval`, `RiverExterior.horizon_velocity_matches_c` |
| **Solar-System Ephemerides (Mercury Perihelion)** | Not directly applicable ($\Lambda < 0$ saddle boundary conditions) | Exact 1PN perihelion precession $\Delta\varpi = \frac{3\pi r_H}{a(1-e^2)} = 42.98''/\text{cy}$ encoded in `PlanetaryOrbit.gr24PrecessionMatrix` | `mercury_perihelion_precession_arcsec_per_century_bounds`, `gr24PrecessionMatrix_orbital_identities` |
| **Galactic Outer-Disk Rotation Curves** | Requires dark matter or modified bulk profile | Isothermal superfluid barotrope yields flat plateau $v_{\mathrm{flat}} = \sqrt{q_\rho}c_\phi = \sqrt{2}c_\phi$ ($q_\rho=2$) without dark matter halos | `isothermal_sphere_flat_velocity` |
| **Quantum Fluid Viscosity vs. Superfluidity** | Thermal boundary plasma saturates KSS bound $\eta/s = \frac{\hbar}{4\pi k_B} > 0$ | Frictionless superflow below Landau critical velocity ($\Delta E > 0$); dilatant shear jamming $\gamma_\varphi(v)$ at high stress | `kssShearViscosityEntropyBound`, `subcritical_no_dissipation` |
| **Active Photon-Photon Gravitational Deflection** | Bulk GR supergravity ($\eta_{\mathrm{act}}^\gamma = 1$): non-parallel light beams gravitate | Passive phonon excitations ($\eta_{\mathrm{act}}^\gamma = 0$): mutual gravitational deflection of non-co-propagating laser beams vanishes | `ddf_photon_deflection_null`, `gr_photon_deflection_active` |

### 4.3 With Normed Tensor Gaussian Splats: Holographic RG Scale-Radius Flow (`adsHolographicRGSplat`)

In AdS/CFT, the Poincaré radial coordinate $z > 0$ is the **renormalization group (RG) coarse-graining length scale** of the boundary CFT ($z \to 0$ is the UV boundary; $z \to z_H$ is the IR thermal horizon). Representing a localized boundary CFT state at RG scale $z_{\mathrm{rg}} > 0$ by `adsHolographicRGSplat cx cy weight z_rg` ($\sigma_1 = \sigma_2 = z_{\mathrm{rg}}$), Theorem `RiverExterior.grassmannian_ads_cft_ddf_and_secret_symmetry_unification` proves that under an RG scale dilatation $z_{\mathrm{UV}} \mapsto z_{\mathrm{IR}} = \lambda_{\mathrm{rg}}\,z_{\mathrm{UV}}$ ($\lambda_{\mathrm{rg}} > 1$):

$$
\det\Sigma_{\mathrm{RG}}(\lambda_{\mathrm{rg}} z_{\mathrm{UV}}) = \lambda_{\mathrm{rg}}^4\,\det\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}}) > \det\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}}),
$$

$$
Q_{\mathrm{core}}\bigl(\Sigma_{\mathrm{RG}}(\lambda_{\mathrm{rg}} z_{\mathrm{UV}})\bigr) = \frac{\hbar^2}{2 m\,(\lambda_{\mathrm{rg}} z_{\mathrm{UV}})^2} = \frac{1}{\lambda_{\mathrm{rg}}^2}\,Q_{\mathrm{core}}\bigl(\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}})\bigr) \le Q_{\mathrm{core}}\bigl(\Sigma_{\mathrm{RG}}(z_{\mathrm{UV}})\bigr).
$$

---

## 5. Catalog of Check Figures & Quantitative Benchmarks Across AdS/CFT, Integrability (`arXiv:1012.3982`), Secret Symmetries (`arXiv:1204.2366`), $Gr_{\mathbb{C}}(2,4)$, and DDF

To enable rapid verification and cross-checking across analytical, numerical (Rust/WASM), and formal (Lean 4) implementations, the table below compiles **18 exact check figures** implemented and tested in `Signals` and `signals-numerical-adapter`:

| # | Domain & Source Citation | Observable / Benchmark Quantity | Exact Formula / Input Parameters | Check Figure / Verified Value | Lean 4 / Rust Verification |
|---|---|---|---|---|---|
| **1** | Maldacena (1998) / Beisert et al. (`arXiv:1012.3982`, p. 8) | 't Hooft coupling at unit string tension $T_{\mathrm{str}} = 1$ | $\lambda = 4\pi^2 T_{\mathrm{str}}^2$ | $\lambda = 4\pi^2 \approx 39.478418$ | `adsCouplingFromStringTension` |
| **2** | Breitenlohner & Freedman (1982) / GKPW (1998) | $\text{AdS}_5/\text{CFT}_4$ ($d=4$) BF stability bound & scaling dimension | $m_{\mathrm{BF}}^2 R_{\mathrm{AdS}}^2 = -d^2/4$, $\Delta_+(4, -4)$ | $m_{\mathrm{BF}}^2 R_{\mathrm{AdS}}^2 = -4$, $\Delta_+ = \Delta_- = 2$ | `ads_cft_integrability_and_secret_symmetry_identities` |
| **3** | GKPW (1998, `hep-th/9802109`, `hep-th/9802150`) | Massless bulk scalar ($m^2 R_{\mathrm{AdS}}^2 = 0$) in $\text{AdS}_5/\text{CFT}_4$ | $\Delta_\pm(4, 0) = 2 \pm \sqrt{4 + 0}$ | $\Delta_+ = 4$ (marginal), $\Delta_- = 0$ | `ads_cft_integrability_and_secret_symmetry_identities` |
| **4** | GKPW (1998) | Massive bulk scalar with $m^2 R_{\mathrm{AdS}}^2 = 5$ in $\text{AdS}_5/\text{CFT}_4$ | $\Delta_\pm(4, 5) = 2 \pm \sqrt{4 + 5}$ | $\Delta_+ = 5$, $\Delta_- = -1$, $\Delta_+ + \Delta_- = 4$, $\Delta_+\Delta_- = -5$ | `SignalsTests.lean` (`Δ_p = 5, Δ_m = -1`) |
| **5** | Kovtun, Son & Starinets (2005, `hep-th/0405231`) | Holographic shear-viscosity-to-entropy-density bound | $(\eta/s)_{\mathrm{KSS}} = \frac{\hbar}{4\pi k_B}$ ($\hbar = k_B = 1$) | $\frac{1}{4\pi} \approx 0.07957747$ | `kssShearViscosityEntropyBound` |
| **6** | Brown & Henneaux (1986) / Ryu & Takayanagi (2006) | $\text{AdS}_3/\text{CFT}_2$ central charge & entanglement ($R_{\mathrm{AdS}}=6, G_N^{(3)}=3, \ell/\epsilon=5$) | $c_{\mathrm{BH}} = \frac{3 R_{\mathrm{AdS}}}{2 G_N^{(3)}}$, $S_{\mathrm{EE}} = \frac{c_{\mathrm{BH}}}{3}\ln(\ell/\epsilon)$ | $c_{\mathrm{BH}} = 3$, $S_{\mathrm{EE}} = \ln 5 \approx 1.609438$ | `ryuTakayanagiEntanglementEntropyAdS3` |
| **7** | Minahan & Zarembo (2003) / Beisert et al. (`arXiv:1012.3982`, p. 15) | Konishi ($L=4, M=2$) one-loop Bethe roots & anomalous dimension | $u_{1,2} = \pm \frac{1}{2\sqrt{3}}$ ($u_k^2 = \frac{1}{12}$), $\delta D_{\mathrm{K}}^{(1)} = \sum_{k=1}^2 \frac{\lambda}{8\pi^2(u_k^2+1/4)}$ | $\delta D_{\mathrm{Konishi}}^{(1)}(\lambda) = \frac{3\lambda}{4\pi^2}$ (at $\lambda=16$: $\frac{12}{\pi^2} \approx 1.215854$) | `ads_cft_integrability_and_secret_symmetry_identities` |
| **8** | Beisert (2005) / Beisert et al. (`arXiv:1012.3982`, p. 20) | All-loop bound-state magnon energy at $p=0$ and $p=\pi$ ($M=3, \lambda=16\pi^2$) | $E(M,\lambda,p) = \sqrt{M^2 + \frac{\lambda}{\pi^2}\sin^2(p/2)}$ | $E(3, 16\pi^2, 0) = 3$; $E(3, 16\pi^2, \pi) = \sqrt{9+16} = 5$ | `adsMagnonDispersion` |
| **9** | Beisert et al. (`arXiv:1012.3982`, p. 21) | Cusp anomalous dimension $D_{\mathrm{cusp}}(\lambda)$ weak vs. strong coefficients | $c_1^{\mathrm{weak}} = \frac{1}{2\pi^2}$, $c_0^{\mathrm{strong}} = \frac{1}{\pi}$, $c_1^{\mathrm{strong}} = -\frac{3\ln 2}{\pi}$ | $c_1^{\mathrm{weak}} \approx 0.050661$, $c_1^{\mathrm{strong}} \approx -0.661907$ | `AdsCftIntegrabilitySecretModel` |
| **10** | de Leeuw et al. (`arXiv:1204.2366`, Eq. (2.4)–(2.5)) | $\mathfrak{psl}(2\|2)_c$ braided central-charge quadratic constraint | $\mathbb{C}(p)\mathbb{C}^\dagger(p) + \mathbb{C}(p) + \mathbb{C}^\dagger(p)$ for $\mathbb{C}(p) = e^{ip}-1$ | $0$ (identically for all $p \in \mathbb{R}$) | `ads_cft_integrability_and_secret_symmetry_identities` |
| **11** | de Leeuw et al. (`arXiv:1204.2366`, Sec. 2.3) | $\mathfrak{gl}(2\|2)$ long vs. $\mathfrak{psl}(2\|2)_c$ short bound-state multiplet dimensions | $\dim V_{\mathrm{long}}(0,0) = 16(1)(1)$; $\dim V_{\mathrm{short}}(M) = 4M$ | $\dim V_{\mathrm{long}}(0,0) = 16$; $\dim V_{\mathrm{short}}(1) = 4$, $\dim V_{\mathrm{short}}(2) = 8$ | `gl22LongRepDim`, `psl22ShortBoundStateDim` |
| **12** | de Leeuw et al. (`arXiv:1204.2366`, Eq. (3.2) & Sec. 3.4) | Indented Yangian secret generator $\widehat{\mathbb{B}} = B_0\operatorname{diag}(1,1,-1,-1)$ trace vs. supertrace | $\operatorname{Tr}(\widehat{\mathbb{B}})$, $\operatorname{STr}(\widehat{\mathbb{B}}) = B_{00}+B_{11}-B_{22}-B_{33}$ | $\operatorname{Tr}(\widehat{\mathbb{B}}) = 0$, $\operatorname{STr}(\widehat{\mathbb{B}}) = 4 B_0$ (at $B_0=2.5$: $\operatorname{STr} = 10$) | `secretSymmetryMatrix`, `supertrace22` |
| **13** | de Leeuw et al. (`arXiv:1204.2366`, Eq. (3.15)) | Quantum-deformed Hubbard affine Cartan matrix $DA$ invariants | $\operatorname{Tr}(DA)$, $\det(DA)$, row sums of $DA$ | $\operatorname{Tr}(DA) = 0$, $\det(DA) = 0$, $DA\cdot(1,1,1,1)^T = 0$ | `qDeformedHubbardCartanDA` |
| **14** | This Work (`Signals.DDF`, `arXiv:1204.2366` Eq. (2.11)) | $Gr_{\mathbb{C}}(2,4)$ Plücker minors of $W_{\mathrm{sec}}(2,1,1,1)$ ($ad-bc = 1$) | $\Delta_{01}^{\mathbb{C}} = \Delta_{23}^{\mathbb{C}} = 1$, $\Delta_{03}^{\mathbb{C}} = \mathbb{H} = 3$, $\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}} = -8$ | $\mathbb{H}^2 - 4\mathbb{C}\mathbb{C}^\dagger = 3^2 - 8 = 1^2 = 1$ | `psl22SecretAutomorphismGr24Matrix` |
| **15** | This Work (`Signals.DDF`) | Splat-free $Gr_{\mathbb{C}}(2,4)$ Plücker product for $\text{AdS}_5$ black brane ($z=1, z_H=2$) | $|w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2 = 1 - (z/z_H)^4$ | $1 - (1/2)^4 = \frac{15}{16} = 0.9375$ | `adsPlanarBlackBraneEmblackening` |
| **16** | This Work (`Signals.DDF`) | Splat-free $Gr_{\mathbb{C}}(2,4)$ Plücker product for DDF acoustic horizon ($r_H=1, r=4$) | $|w_A^{\mathbb{C}}|^2|w_B^{\mathbb{C}}|^2 = 1 - r_H / r$ | $1 - \frac{1}{4} = \frac{3}{4} = 0.75$ | `RiverExterior.inflowBeta` |
| **17** | This Work (`Signals.DDF`) | Holographic RG Tensor Gaussian Splat flow ($z_{\mathrm{UV}}=1/2, \lambda_{\mathrm{rg}}=2$) | $\det\Sigma_{\mathrm{IR}} / \det\Sigma_{\mathrm{UV}} = \lambda_{\mathrm{rg}}^4$, $Q_{\mathrm{core}}^{\mathrm{IR}} / Q_{\mathrm{core}}^{\mathrm{UV}} = \lambda_{\mathrm{rg}}^{-2}$ | $\det\Sigma_{\mathrm{IR}} / \det\Sigma_{\mathrm{UV}} = 16$, $Q_{\mathrm{core}}^{\mathrm{IR}} / Q_{\mathrm{core}}^{\mathrm{UV}} = \frac{1}{4} = 0.25$ | `adsHolographicRGSplat` |
| **18** | Companion Paper 4 (`Signals.DDF`) | 1PN Mercury perihelion precession in $Gr_{\mathbb{C}}(2,4)$/DDF (`RiverExterior`) | $\Delta\varpi_{\mathrm{cy}} = \frac{1944000\,r_{H,\odot}}{a(1-e^2)} \cdot N_{\mathrm{orbits/cy}}$ | $42.98''/\text{century}$ ($42.98 < \Delta\varpi_{\mathrm{cy}} < 42.99$) | `mercury_perihelion_precession_arcsec_per_century_bounds` |
| **19** | de Leeuw et al. (`arXiv:1204.2366`, Eq. (3.1)–(3.3)) | Full $16 \times 16$ $\mathfrak{psl}(2\|2)_c$ worldsheet $R$-matrix & Yangian tail secret intertwining | $\Delta_{\mathrm{full}}^{\mathrm{op}}(\widehat{\mathbb{B}})\,R_{16} - R_{16}\,\Delta_{\mathrm{full}}(\widehat{\mathbb{B}})$ | $0_{16 \times 16}$ (for all $B_1, B_2, A_B, B_B, D_F, E_F, G_{BF}, L_{BF}$) | `psl22_rmatrix16_secret_coproduct_intertwining` |

---

## 6. Machine-Checked Lean 4 Verification (`Signals.Scattering` & `Signals.DDF`)

The following self-contained Lean 4 proof block typechecks directly against `Signals` and verifies the GKPW mass–dimension dictionary, Breitenlohner–Freedman bound, Ryu–Takayanagi entanglement entropy, KSS viscosity bound, all-loop magnon dispersion, Konishi one-loop check figure, $\mathfrak{psl}(2|2)_c$ braided central charges, indented Yangian secret supertrace, $q$-deformed Hubbard Cartan degeneracy, full $16 \times 16$ worldsheet $R$-matrix secret coproduct intertwining with the Yangian tail, and the $Gr_{\mathbb{C}}(2,4)$/DDF unification theorems both with and without splats:

```lean
import Signals

namespace ArxivGrassmannianAdsCftDdfVerification

open Signals.Geometry
open Signals.Scattering
open Signals.DDF

-- Unified verification of AdS/CFT (Maldacena 1998, GKPW 1998, KSS 2005, Ryu-Takayanagi 2006),
-- Planar Integrability (Beisert et al. 2012, arXiv:1012.3982), Secret Symmetries (de Leeuw et al. 2012, arXiv:1204.2366),
-- and Complex Gr_C(2,4) & DDF Mechanics (with and without Normed Tensor Gaussian Splats)
example {sub : DDFSubstrate} (re : RiverExterior sub)
    (hr : re.horizonRadius < 4) (p p1 p2 B0 B1 B2 θ : ℝ) :
    let Δ_p := adsCftScalingDimensionPlus 4 5
    let Δ_m := adsCftScalingDimensionMinus 4 5
    let C_p := psl22BraidedCentralChargeC p
    let CDag_p := psl22BraidedCentralChargeCDag p
    let C_1 := psl22BraidedCentralChargeC p1
    let C_2 := psl22BraidedCentralChargeC p2
    let W_sec := psl22SecretAutomorphismGr24Matrix 2 1 1 1
    let M_ads5 := ddfThermalGr24Matrix ((1 / 2 : ℝ) ^ 2) θ
    let M_ddf := ddfThermalGr24Matrix (re.inflowBeta 4) θ
    let splat_uv := adsHolographicRGSplat 0 0 1 (1 / 2) (by norm_num) (by norm_num) θ
    let splat_ir := adsHolographicRGSplat 0 0 1 (2 * (1 / 2)) (by norm_num) (by norm_num) θ
    -- (1) GKPW AdS/CFT mass-dimension dictionary, BF bound, Ryu-Takayanagi entropy, & KSS viscosity bound:
    Δ_p + Δ_m = 4 ∧
    Δ_p * Δ_m = -5 ∧
    Δ_p * (Δ_p - 4) = 5 ∧
    adsCftScalingDimensionPlus 4 (adsBreitenlohnerFreedmanBound 4) = 4 / 2 ∧
    adsCftScalingDimensionPlus 4 0 = 4 ∧
    ryuTakayanagiEntanglementEntropyAdS3 6 3 10 2 =
      (brownHenneauxCentralCharge 6 3 / 3) * Real.log (10 / 2) ∧
    0 < kssShearViscosityEntropyBound 1 1 ∧
    adsCouplingFromStringTension (Real.sqrt 16 / (2 * Real.pi)) = 16 ∧
    -- (2) Planar Integrability (arXiv:1012.3982): BPS magnon dispersion, Konishi 1-loop, & cusp dimension:
    adsMagnonDispersion 2 16 0 = 2 ∧
    adsMagnonDispersionSq 2 (adsCouplingFromStringTension 3) Real.pi = 2 ^ 2 + 4 * 3 ^ 2 ∧
    (2 : ℝ) ^ 2 ≤ adsMagnonDispersionSq 2 16 p ∧
    2 * betheOneLoopMagnonEnergy 16 (1 / (2 * Real.sqrt 3)) =
      konishiOneLoopAnomalousDim 16 ∧
    konishiOneLoopAnomalousDim 16 = (3 / 2) * cuspAnomalousDimOneLoop 16 ∧
    -- (3) Secret Symmetries in AdS/CFT (arXiv:1204.2366): braided central charges, supertrace, Cartan DA, & 16x16 R-matrix:
    C_p * CDag_p + C_p + CDag_p = 0 ∧
    (1 + C_1) * (1 + C_2) = 1 + psl22BraidedCoproductC C_1 C_2 ∧
    gl22LongRepDim 0 0 = 16 ∧
    psl22ShortBoundStateDim 1 = 4 ∧
    Matrix.trace (secretSymmetryMatrix B0) = 0 ∧
    supertrace22 (secretSymmetryMatrix B0) = 4 * B0 ∧
    Matrix.mulVec qDeformedHubbardCartanDA ![1, 1, 1, 1] = 0 ∧
    Matrix.det qDeformedHubbardCartanDA = 0 ∧
    psl22SecretCoproductFullOp16 B1 B2 7 8 * psl22WorldsheetRMatrix16 3 4 5 6 7 8 =
      psl22WorldsheetRMatrix16 3 4 5 6 7 8 * psl22SecretCoproductFull16 B1 B2 7 8 ∧
    -- (4) Without Splats: Gr_C(2,4) Plücker realization of psl(2|2)_c secret outer automorphism & AdS_5/DDF lapse:
    complexTwoRowMinor W_sec 0 1 = 1 ∧
    complexTwoRowMinor W_sec 0 3 = 3 ∧
    (complexTwoRowMinor W_sec 0 3) ^ 2 +
        complexTwoRowMinor W_sec 0 2 * complexTwoRowMinor W_sec 1 3 =
      complexTwoRowMinor W_sec 0 1 * complexTwoRowMinor W_sec 2 3 ∧
    Complex.normSq (complexPluckerSinkAmplitudeA M_ads5) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_ads5) =
      adsPlanarBlackBraneEmblackening 1 2 4 ∧
    Complex.normSq (complexPluckerSinkAmplitudeA M_ddf) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_ddf) =
      1 - re.horizonRadius / 4 ∧
    continuumBohmPotentialMode 1 1 ((1 / (1 / 2)) / 2) =
      (1 / 2 ^ 2) * continuumBohmPotentialMode 1 1 (1 / (1 / 2)) ∧
    -- (5) With Normed Tensor Gaussian Splats: Holographic RG scale-radius covariance & Bohm potential flow:
    splat_ir.covDet = 2 ^ 4 * splat_uv.covDet ∧
    splat_ir.coreBohmPotential 1 1 = (1 / 2 ^ 2) * splat_uv.coreBohmPotential 1 1 := by
  intro Δ_p Δ_m C_p CDag_p C_1 C_2 W_sec M_ads5 M_ddf splat_uv splat_ir
  have hu_K : (1 / (2 * Real.sqrt 3 : ℝ)) ^ 2 = 1 / 12 := by
    have h3 : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    calc
      (1 / (2 * Real.sqrt 3 : ℝ)) ^ 2 = 1 / (4 * (Real.sqrt 3) ^ 2) := by ring
      _ = 1 / 12 := by rw [h3]; norm_num
  have h_ads := ads_cft_integrability_and_secret_symmetry_identities
    4 5 1 1 6 3 10 2 2 16 3 p (1 / (2 * Real.sqrt 3)) p1 p2 B0
    (by norm_num) (by norm_num [adsBreitenlohnerFreedmanBound])
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) hu_K
  have h_r16 := (psl22_rmatrix16_secret_coproduct_intertwining B1 B2 B0 3 4 5 6 7 8).2.2.2.2.2
  have h_unif := re.grassmannian_ads_cft_ddf_and_secret_symmetry_unification
    2 1 1 1 1 2 4 0 0 1 (1 / 2) 2 1 1 θ
    (by norm_num) (by norm_num) (by norm_num) hr
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_w01 : complexTwoRowMinor W_sec 0 1 = 1 := by rw [h_unif.1]; norm_num
  have h_w03 : complexTwoRowMinor W_sec 0 3 = 3 := by rw [h_unif.2.2.1]; norm_num
  rcases h_ads with ⟨ha1, ha2, ha3, ha4, ha5, _ha6, ha7, ha8, ha9, ha10,
    ha11, ha12, ha13, ha14, _ha15, ha16, _ha17, ha18, ha19, ha20, _ha21,
    ha22, ha23, _ha24, ha25, _ha26, ha27⟩
  rcases h_unif with ⟨_hu1, _hu2, _hu3, _hu4, _hu5, _hu6, _hu7, hu8,
    hu9, _hu10, hu11, hu12, hu13, _hu14, hu15, _hu16⟩
  exact ⟨ha1, ha2, ha3, ha4, ha5, ha7, ha8, ha9,
    ha10, ha11, ha12, ha13, ha14,
    ha16, ha18, ha19, ha20, ha22, ha23, ha25, ha27, h_r16,
    h_w01, h_w03, hu8, hu9, hu11, hu12, hu13, hu15⟩

end ArxivGrassmannianAdsCftDdfVerification
```

---

### Scholarly References

<a id="adscft-maldacena1998"></a>
1. Maldacena, J. M. (1998). *The Large N Limit of Superconformal Field Theories and Supergravity*. Advances in Theoretical and Mathematical Physics 2, 231–252; International Journal of Theoretical Physics 38, 1113–1133 (1999). [DOI: 10.4310/ATMP.1998.v2.n2.a1](https://doi.org/10.4310/ATMP.1998.v2.n2.a1); [arXiv:hep-th/9711200](https://arxiv.org/abs/hep-th/9711200).

<a id="adscft-gkp1998"></a>
2. Gubser, S. S., Klebanov, I. R., and Polyakov, A. M. (1998). *Gauge Theory Correlators from Non-Critical String Theory*. Physics Letters B 428(1–2), 105–114. [DOI: 10.1016/S0370-2693(98)00377-3](https://doi.org/10.1016/S0370-2693(98)00377-3); [arXiv:hep-th/9802109](https://arxiv.org/abs/hep-th/9802109).

<a id="adscft-witten1998"></a>
3. Witten, E. (1998). *Anti De Sitter Space And Holography*. Advances in Theoretical and Mathematical Physics 2, 253–291. [DOI: 10.4310/ATMP.1998.v2.n2.a2](https://doi.org/10.4310/ATMP.1998.v2.n2.a2); [arXiv:hep-th/9802150](https://arxiv.org/abs/hep-th/9802150).

<a id="adscft-bf1982"></a>
4. Breitenlohner, P., and Freedman, D. Z. (1982). *Stability in Gauged Extended Supergravity*. Annals of Physics 144(2), 249–281. [DOI: 10.1016/0003-4916(82)90116-6](https://doi.org/10.1016/0003-4916(82)90116-6).

<a id="adscft-minahan2003"></a>
5. Minahan, J. A., and Zarembo, K. (2003). *The Bethe-Ansatz for N=4 Super Yang-Mills*. Journal of High Energy Physics 2003(03), 013. [DOI: 10.1088/1126-6708/2003/03/013](https://doi.org/10.1088/1126-6708/2003/03/013); [arXiv:hep-th/0212208](https://arxiv.org/abs/hep-th/0212208).

<a id="adscft-kss2005"></a>
6. Kovtun, P. K., Son, D. T., and Starinets, A. O. (2005). *Viscosity in Strongly Interacting Quantum Field Theories from Black Hole Physics*. Physical Review Letters 94(11), 111601. [DOI: 10.1103/PhysRevLett.94.111601](https://doi.org/10.1103/PhysRevLett.94.111601); [arXiv:hep-th/0405231](https://arxiv.org/abs/hep-th/0405231).

<a id="adscft-beisert2005"></a>
7. Beisert, N. (2008). *The su(2|2) Dynamic S-Matrix*. Advances in Theoretical and Mathematical Physics 12(5), 945–979. [DOI: 10.4310/ATMP.2008.v12.n5.a1](https://doi.org/10.4310/ATMP.2008.v12.n5.a1); [arXiv:hep-th/0511082](https://arxiv.org/abs/hep-th/0511082).

<a id="adscft-dorey2006"></a>
8. Dorey, N. (2006). *Magnon Bound States and the AdS/CFT Correspondence*. Journal of Physics A: Mathematical and General 39(41), 13119–13128. [DOI: 10.1088/0305-4470/39/41/S18](https://doi.org/10.1088/0305-4470/39/41/S18); [arXiv:hep-th/0604175](https://arxiv.org/abs/hep-th/0604175).

<a id="adscft-brown1986"></a>
9. Brown, J. D., and Henneaux, M. (1986). *Central Charges in the Canonical Realization of Asymptotic Symmetries: An Example from Three-Dimensional Gravity*. Communications in Mathematical Physics 104(2), 207–226. [DOI: 10.1007/BF01211590](https://doi.org/10.1007/BF01211590).

<a id="adscft-ryu2006"></a>
10. Ryu, S., and Takayanagi, T. (2006). *Holographic Derivation of Entanglement Entropy from AdS/CFT*. Physical Review Letters 96(18), 181602. [DOI: 10.1103/PhysRevLett.96.181602](https://doi.org/10.1103/PhysRevLett.96.181602); [arXiv:hep-th/0603001](https://arxiv.org/abs/hep-th/0603001).

<a id="adscft-matsumoto2007"></a>
11. Matsumoto, T., Moriyama, S., and Torrielli, A. (2007). *A Secret Symmetry of the AdS/CFT S-Matrix*. Journal of High Energy Physics 2007(09), 099. [DOI: 10.1088/1126-6708/2007/09/099](https://doi.org/10.1088/1126-6708/2007/09/099); [arXiv:0708.1285](https://arxiv.org/abs/0708.1285).

<a id="adscft-arkani2010"></a>
12. Arkani-Hamed, N., Cachazo, F., Cheung, C., and Kaplan, J. (2010). *A Duality For The S Matrix*. Journal of High Energy Physics 2010(03), 020. [DOI: 10.1007/JHEP03(2010)020](https://doi.org/10.1007/JHEP03(2010)020); [arXiv:0907.5418](https://arxiv.org/abs/0907.5418).

<a id="adscft-beisert2011"></a>
13. Beisert, N., and Schwab, B. U. W. (2011). *Bonus Yangian Symmetry for the Planar S-Matrix of N=4 Super Yang-Mills*. Physical Review Letters 106(23), 231602. [DOI: 10.1103/PhysRevLett.106.231602](https://doi.org/10.1103/PhysRevLett.106.231602); [arXiv:1103.0646](https://arxiv.org/abs/1103.0646).

<a id="adscft-berkovits2011"></a>
14. Berkovits, N., and Mikhailov, A. (2011). *Nonlocal Charges for Bonus Yangian Symmetries of Super-Yang-Mills*. Journal of High Energy Physics 2011(07), 125. [DOI: 10.1007/JHEP07(2011)125](https://doi.org/10.1007/JHEP07(2011)125); [arXiv:1103.1228](https://arxiv.org/abs/1103.1228).

<a id="adscft-deleeuw2011"></a>
15. de Leeuw, M., Regelskis, V., and Torrielli, A. (2012). *The Quantum Affine Origin of the AdS/CFT Secret Symmetry*. Journal of Physics A: Mathematical and Theoretical 45(17), 175202. [DOI: 10.1088/1751-8113/45/17/175202](https://doi.org/10.1088/1751-8113/45/17/175202); [arXiv:1112.4989](https://arxiv.org/abs/1112.4989).

<a id="adscft-beisert2012"></a>
16. Beisert, N., Ahn, C., Alday, L. F., Bajnok, Z., Drummond, J. M., et al. (2012). *Review of AdS/CFT Integrability: An Overview*. Letters in Mathematical Physics 99(1–3), 3–32. [DOI: 10.1007/s11005-011-0529-2](https://doi.org/10.1007/s11005-011-0529-2); [arXiv:1012.3982](https://arxiv.org/abs/1012.3982).

<a id="adscft-deleeuw2012"></a>
17. de Leeuw, M., Matsumoto, T., Moriyama, S., Regelskis, V., and Torrielli, A. (2012). *Secret Symmetries in AdS/CFT*. Physica Scripta 86(2), 028502. [DOI: 10.1088/0031-8949/86/02/028502](https://doi.org/10.1088/0031-8949/86/02/028502); [arXiv:1204.2366](https://arxiv.org/abs/1204.2366).

<a id="adscft-chat-fluidgravity2026"></a>
18. Provenance Chat Log (2026). *Gravity Models: Dilatant Fluid vs. GR (AdS/CFT Fluid/Gravity Duality, KSS Viscosity Bound, and Mercury Ephemerides)*. ({download}`data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md, lines 136-325 <../data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md>`).

<a id="adscft-chat-bell2026"></a>
19. Provenance Chat Log (2026). *Bell Correlations in Atomic Momentum (Massive Twistors in Gr(2,4), Positive Grassmannians Gr^+(k,n), and Yangian Symmetry Y(psu(2,2|4)))*. ({download}`data/chats/Bell-Correlations-in-Atomic-Momentum.md, lines 410-445 <../data/chats/Bell-Correlations-in-Atomic-Momentum.md>`).

---

### BibTeX Citations

```bibtex
@article{maldacena1998large,
  author  = {Maldacena, Juan Martin},
  title   = {The Large {N} Limit of Superconformal Field Theories and Supergravity},
  journal = {Advances in Theoretical and Mathematical Physics},
  volume  = {2},
  pages   = {231--252},
  year    = {1998},
  doi     = {10.4310/ATMP.1998.v2.n2.a1},
  eprint  = {hep-th/9711200},
  url     = {https://doi.org/10.4310/ATMP.1998.v2.n2.a1}
}

@article{beisert2012review,
  author  = {Beisert, Niklas and Ahn, Changrim and Alday, Luis F. and Bajnok, Zoltan and Drummond, James M. and others},
  title   = {Review of {AdS/CFT} Integrability: An Overview},
  journal = {Letters in Mathematical Physics},
  volume  = {99},
  pages   = {3--32},
  year    = {2012},
  doi     = {10.1007/s11005-011-0529-2},
  eprint  = {1012.3982},
  url     = {https://doi.org/10.1007/s11005-011-0529-2}
}

@article{deleeuw2012secret,
  author  = {de Leeuw, Marius and Matsumoto, Takuya and Moriyama, Sanefumi and Regelskis, Vidas and Torrielli, Alessandro},
  title   = {Secret Symmetries in {AdS/CFT}},
  journal = {Physica Scripta},
  volume  = {86},
  number  = {2},
  pages   = {028502},
  year    = {2012},
  doi     = {10.1088/0031-8949/86/02/028502},
  eprint  = {1204.2366},
  url     = {https://doi.org/10.1088/0031-8949/86/02/028502}
}

@misc{chat_gravity_models_adscft_2026,
  author       = {Unknown},
  title        = {Gravity Models: Dilatant Fluid vs. GR},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md, lines 136-325},
  url          = {../data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "AdS/CFT Correspondence, Planar Integrability, and Secret Symmetries in Unified Complex Grassmannian Gr_C(2,4) and Dilatant Dark Fluid (DDF) Mechanics: From Maldacena and psl(2|2)_c Yangians to Plücker Outer Automorphisms and Holographic RG Tensor Splatting in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-24",
  "about": [
    "AdS/CFT Correspondence",
    "Juan Maldacena",
    "AdS/CFT Integrability",
    "Secret Symmetries in AdS/CFT",
    "Centrally Extended psl(2|2)_c",
    "Complex Grassmannian Gr_C(2,4)",
    "Dilatant Dark Fluid",
    "Normed Tensor Gaussian Splatting",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "data/chats/_Gravity-Models-Dilatant-Fluid-vs.-GR.md",
    "data/chats/Bell-Correlations-in-Atomic-Momentum.md",
    "src/signals/Signals/Scattering.lean",
    "src/signals/Signals/DDF.lean",
    "src/signals/Signals/QISM.lean",
    "src/signals/numerical_adapter/src/polariton_spp.rs"
  ]
}
```
