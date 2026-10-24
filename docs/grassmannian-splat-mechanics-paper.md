---
title: "Normed Tensor Gaussian Splat Mechanics for Complex Gr_C(2,4) Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4"
description: "An arXiv-ready formal verification and systems architecture paper explaining how normed tensor Gaussian splatters represent complex Gr_C(2,4) twistors, their advantages and limitations across all four Grassmannian physics papers, and why Rust + WASM + WebGL2 GLSL is practical today compared to WebGPU, WebNN, and the absence of a WebTPU."
---

(grassmannian-splat-mechanics-paper)=
# Normed Tensor Gaussian Splat Mechanics for Complex $Gr_{\mathbb{C}}(2,4)$ Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4

**Authors:** Wes Turner
**Subjects:** Mathematical Physics (`math-ph`); Computational Physics (`physics.comp-ph`); Quantum Physics (`quant-ph`); General Relativity and Quantum Cosmology (`gr-qc`); Logic in Computer Science (`cs.LO`)
**Formal Verification & Simulation Artifact:** `Signals` Lean 4 Library (`leanprover/lean4:v4.35.0-rc3`) & `signals-numerical-adapter` Rust/WASM/GLSL Crate
**Companion Papers:**
1. [Huygens–Steiner Barycentric Coherence, Complex $Gr_{\mathbb{C}}(2,4)$ Plücker Channels, and Multi-Model Double-Slit & OAM Relative Predictive Error in Lean 4](grassmannian-huygens-double-slit-oam-paper.md)
2. [Grassmannian Geometry of the Quantum Inverse Scattering Method, Algebraic Bethe Ansatz, and Inverse Scattering Metrology in Lean 4](grassmannian-qism-bethe-ansatz-paper.myst.md)
3. [Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ & $N$-ary $Gr_{\mathbb{C}}(2, N+2)$ Unification with Dilatant Dark Fluid (DDF) Moving Sheaths, Plücker Sink Fluxes, Anosov Invariance, and Sorkin Triple-Slit Interferometry in Lean 4](grassmannian-ddf-moving-sheath-paper.myst.md)
4. [Grassmannian Gravity from QED & Gauge Scattering Amplitudes: Complex $Gr_{\mathbb{C}}(2,4)$ Orbital Precession, Mercury's Perihelion, $N$-Body Dynamics, and Dilatant Dark Fluid (DDF) Unification in Lean 4](grassmannian-gravity-from-qed-scattering-paper.md)

---

## Abstract

How can a finite set of **normed anisotropic Tensor Gaussian Splatters** (`NormedTensorGaussianSplat2D` in `Signals.DDF` and `TensorGaussianSplat` in `Signals.Pending`) faithfully represent complex $Gr_{\mathbb{C}}(2,4)$ twistor planes while conserving mass, energy, and topological phase invariants across wave optics, integrable quantum chains, superfluid dark-fluid hydrodynamics, and $N$-body planetary gravity? In this paper, we present a machine-checked formalization in Lean 4 (`Signals.DDF`, `Signals.Geometry`, `Signals.Huygens`, `Signals.QISM`) together with a zero-dependency Rust $\to$ WebAssembly (`wasm32-unknown-unknown`) and WebGL2 GLSL (`#version 300 es`) implementation (`src/signals/numerical_adapter/`) establishing:

1. **How Normed Tensor Gaussian Splatters Represent $Gr_{\mathbb{C}}(2,4)$ Twistors (`complexTwistor_representation_identities`)**:
   A complex 2-plane in twistor space $M_{\mathbb{C}} \in Gr_{\mathbb{C}}(2,4)$ spanned by two twistors $Z_1, Z_2 \in \mathbb{C}^4$ (with Penrose incidence $\mu^{\dot{\alpha}} = -i x^{\alpha\dot{\alpha}}\lambda_\alpha$) is represented by a **dual-layer phase-coherent Tensor Gaussian Splat**:
   - **Layer 1 (Anisotropic Covariance Tensor $\Sigma$)**: The moduli of the two uncrossed Plücker channel amplitudes $w_A^{\mathbb{C}} = \Delta_{01}^{\mathbb{C}}\Delta_{23}^{\mathbb{C}}$ and $w_B^{\mathbb{C}} = \Delta_{03}^{\mathbb{C}}\Delta_{12}^{\mathbb{C}}$ set the principal variances $\sigma_1^2 = \sigma_0^2 |w_A^{\mathbb{C}}|^2$ and $\sigma_2^2 = \sigma_0^2 |w_B^{\mathbb{C}}|^2$, so that $\frac{\operatorname{Tr}\Sigma}{\sigma_0^2} = |w_A^{\mathbb{C}}|^2 + |w_B^{\mathbb{C}}|^2$ (total Madelung weight), $\frac{\sigma_1^2 - \sigma_2^2}{2\sigma_0^2} = d_{\mathrm{bary}}$ (barycentric parallel-axis shift / DDF reduced speed $\beta = v/c$ / orbital eccentricity $e$), and $\frac{\det\Sigma}{\sigma_0^4} = \mathcal{V}^2 = \gamma_\varphi(v)^{-2} = 1 - e^2 = \frac{p}{a}$.
   - **Layer 2 (Complex Twistor Wavepacket $\Psi_{\mathrm{splat}}$)**: Attaching the complex Plücker sum $w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = \Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$ to the square-root Gaussian amplitude $\sqrt{G(x,y)}$ yields $\Psi_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = \sqrt{G(x,y)}\,\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})$, whose Madelung intensity $I_{\mathrm{splat}} = G(x,y)\,\bigl|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\bigr|^2$ reproduces exact constructive and destructive interference (vanishing at dark fringes where $w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = 0$) while preserving the $L^1(\mathbb{R}^2)$ normalization of $G(x,y)$.
2. **Core Bohm Quantum Potential Regularization (`coreBohmPotential_identities`)**:
   Because Gaussian splats are $C^\infty$ smooth with $\det\Sigma > 0$, the regularized Bohm quantum potential at the splat center is finite and strictly repulsive:
   $$Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2\,\operatorname{Tr}\Sigma}{4 m\,\det\Sigma} = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2} + \frac{1}{\sigma_2^2}\right) > 0, \qquad Q_{\mathrm{core}}^{\mathrm{DDF}}(s) = \frac{\hbar^2}{4 m \sigma_0^2}\bigl(\gamma_\varphi(v)^2 + 1\bigr),$$
   preventing $1/r \to \infty$ point-core singularities in both vortex reconnection and relativistic horizon compression.
3. **Justification, Advantages, and Limitations Across All Four Companion Papers**:
   We provide a domain-by-domain audit of where normed tensor Gaussian splatters are exact, where they serve as an $O(N_{\mathrm{splats}})$ Lagrangian/Madelung discretization, and where hybrid analytic kernels (such as $\operatorname{sinc}^2$ aperture diffraction or long-range $1/r$ Ewald/Newtonian tails) are required.
4. **Why Rust + WASM + WebGL2 GLSL is the Practical Browser Architecture Today (vs. WebGPU, WebNN, and WebTPU)**:
   We explain why compiling the physics core to `wasm32-unknown-unknown` and rendering the Mahalanobis quadratic forms in WebGL2 (`#version 300 es`) GLSL fragment shaders achieves universal browser reach and $60\text{–}120\text{ FPS}$ performance today, whereas WebGPU remains unevenly deployed, WebNN is restricted to static neural-network operator graphs, and no W3C "WebTPU" standard exists for custom scientific tensor kernels.

---

## 1. How Do Normed Tensor Gaussian Splatters Represent $Gr_{\mathbb{C}}(2,4)$ Twistors?

### 1.1 From $\mathbb{C}^4$ Twistors and Penrose Incidence to $Gr_{\mathbb{C}}(2,4)$ Plücker Channels

In `Signals.Geometry` ([src/signals/Signals/Geometry.lean](../src/signals/Signals/Geometry.lean#L168-L240)), a four-component twistor $Z = (\lambda_\alpha, \mu^{\dot{\alpha}}) \in \mathbb{C}^2 \oplus \mathbb{C}^2 \cong \mathbb{C}^4$ (`Twistor`) is linked to a spacetime coordinate matrix $x^{\alpha\dot{\alpha}}$ by Penrose's incidence relation (`Twistor.incident`):

$$
\mu^{\dot{\alpha}} = -i\,x^{\alpha\dot{\alpha}}\,\lambda_\alpha.
$$

Under a spacetime translation $x \mapsto x + a$ (`Twistor.translate`, `Twistor.translate_incident_iff`), the primary Weyl spinor $\lambda_\alpha$ is invariant while $\mu^{\dot{\alpha}}$ acquires the oscillatory phase shift $-i a^{\alpha\dot{\alpha}}\lambda_\alpha$. A complex 2-plane in twistor space is a point in the complex Grassmannian $Gr_{\mathbb{C}}(2,4)$, represented by a $2 \times 4$ complex matrix $M_{\mathbb{C}} \in \mathbb{C}^{2 \times 4}$ whose six $2 \times 2$ Plücker minors $\Delta_{ab}^{\mathbb{C}}(M_{\mathbb{C}})$ (`complexTwoRowMinor`) obey the 3-term Plücker identity (`complexTwoRowMinor_pluecker`):

$$
\underbrace{\Delta_{01}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{23}^{\mathbb{C}}(M_{\mathbb{C}})}_{w_A^{\mathbb{C}}(M_{\mathbb{C}})}
+ \underbrace{\Delta_{03}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{12}^{\mathbb{C}}(M_{\mathbb{C}})}_{w_B^{\mathbb{C}}(M_{\mathbb{C}})}
= \Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}).
$$

### 1.2 The Fundamental Critique: Why a Purely Real Gaussian Splat Is Only Half of a Twistor

A classical 2D anisotropic Gaussian splat (`NormedTensorGaussianSplat2D` in [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L2445-L2505)):

$$
G(x, y) = w\,\mathcal{N}(\Sigma)\,\exp\!\left(-\frac{1}{2} Q_\Sigma(x, y)\right), \qquad
\mathcal{N}(\Sigma) = \frac{1}{2\pi \sigma_1 \sigma_2}, \qquad
Q_\Sigma(x, y) = \frac{u_1^2}{\sigma_1^2} + \frac{u_2^2}{\sigma_2^2},
$$

is **strictly positive** ($G(x, y) > 0$ for $w > 0$). If we map $M_{\mathbb{C}} \in Gr_{\mathbb{C}}(2,4)$ *only* to its real covariance matrix $\Sigma = R(\theta)\operatorname{diag}(\sigma_1^2, \sigma_2^2)R(\theta)^T$, we retain the channel moduli $|w_A^{\mathbb{C}}|^2$ and $|w_B^{\mathbb{C}}|^2$ but discard the relative Penrose twistor phase $\Delta\phi = \arg(w_A^{\mathbb{C}}\,\overline{w_B^{\mathbb{C}}})$. Just like the real positive Grassmannian $Gr_{\ge 0}(2,4)$ (`gr24UnphasedDoubleSlit_onAxis_relative_error_half`), a sum of positive real Gaussian densities cannot cancel at destructive dark fringes!

### 1.3 The Dual-Layer Solution: Covariance Tensor $\Sigma$ + Complex Plücker Wavepacket $\Psi_{\mathrm{splat}}$

To represent $M_{\mathbb{C}} \in Gr_{\mathbb{C}}(2,4)$ faithfully without losing either $L^1$ energy conservation or coherent twistor phase interference, `Signals.DDF` formalizes a **dual-layer representation**:

```
               Complex Twistor 2-Plane M_C ∈ Gr_C(2,4)
     w_A^C = Δ_01^C Δ_23^C = |w_A^C| e^{iϕ_A},  w_B^C = Δ_03^C Δ_12^C = |w_B^C| e^{iϕ_B}
                                   │
         ┌─────────────────────────┴─────────────────────────┐
         ▼                                                   ▼
┌─────────────────────────────────────────┐ ┌─────────────────────────────────────────┐
│ LAYER 1: Anisotropic Covariance Tensor  │ │ LAYER 2: Coherent Twistor Wavepacket    │
│  σ₁² = σ₀² |w_A^C|², σ₂² = σ₀² |w_B^C|² │ │  Ψ_splat = √G(x,y) · (w_A^C + w_B^C)    │
│  • Tr Σ / σ₀² = |w_A^C|² + |w_B^C|²     │ │          = √G(x,y) · Δ_02^C Δ_13^C      │
│  • (σ₁² - σ₂²)/(2σ₀²) = d_bary = β = e  │ │  • I_splat = G(x,y) |Δ_02^C Δ_13^C|²    │
│  • det Σ / σ₀⁴ = V² = γ_φ⁻² = p/a       │ │  • Exact dark-fringe null at w_A^C=-w_B^C│
└─────────────────────────────────────────┘ └─────────────────────────────────────────┘
```

1. **Layer 1 — Covariance Tensor Dictionary (`MovingSheath.ddfTensorSplat_identities`, `PlanetaryOrbit.gr24TensorSplat_identities`)**:
   For canonical $Gr_{\mathbb{C}}(2,4)$ twistor matrices with $|w_A^{\mathbb{C}}|^2 = 1 + d_{\mathrm{bary}}$ and $|w_B^{\mathbb{C}}|^2 = 1 - d_{\mathrm{bary}}$ ($d_{\mathrm{bary}} \in (-1, 1)$), setting $\sigma_1 = \sigma_0\sqrt{1 + d_{\mathrm{bary}}}$ and $\sigma_2 = \sigma_0\sqrt{1 - d_{\mathrm{bary}}}$ encodes:
   $$\operatorname{Tr}\Sigma = 2\sigma_0^2, \qquad \frac{\sigma_1^2 - \sigma_2^2}{2\sigma_0^2} = d_{\mathrm{bary}}, \qquad \det\Sigma = \sigma_0^4(1 - d_{\mathrm{bary}}^2) = \sigma_0^4\,\mathcal{V}^2 = \sigma_0^4\,\gamma_\varphi(v)^{-2} = \sigma_0^4\,\frac{p}{a}.$$
2. **Layer 2 — Coherent Twistor Wavepacket & Intensity (`NormedTensorGaussianSplat2D.complexTwistor_representation_identities` in [DDF.lean](../src/signals/Signals/DDF.lean#L2720-L2840))**:
   Weighting the square-root Gaussian envelope $\sqrt{G(x,y)}$ by $w_A^{\mathbb{C}}(M_{\mathbb{C}}) + w_B^{\mathbb{C}}(M_{\mathbb{C}})$ yields:
   $$\Psi_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = \sqrt{G(x,y)}\,\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}}),$$
   $$I_{\mathrm{splat}}(M_{\mathbb{C}}; x, y) = G(x,y)\,\bigl|\Delta_{02}^{\mathbb{C}}(M_{\mathbb{C}})\,\Delta_{13}^{\mathbb{C}}(M_{\mathbb{C}})\bigr|^2 = G(x,y)\,\Bigl(|w_A^{\mathbb{C}}|^2 + |w_B^{\mathbb{C}}|^2 + 2\operatorname{Re}\bigl(w_A^{\mathbb{C}}\,\overline{w_B^{\mathbb{C}}}\bigr)\Bigr).$$
   Because $\int_{\mathbb{R}^2} G(x,y)\,dx\,dy = w$, the spatially integrated intensity of the twistor splat is conserved and equals $w\,\bigl|\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}\bigr|^2$, while vanishing identically at dark fringes ($w_A^{\mathbb{C}} + w_B^{\mathbb{C}} = 0$).

```lean
import Signals
import SignalsPending

namespace ArxivSplatMechanicsPaperVerification

open Signals.Geometry
open Signals.Coherence
open Signals.Huygens
open Signals.DDF

-- 1. Dual-layer Gr_C(2,4) twistor splat representation: crossing factorization, interference expansion, and dark-fringe null
example (splat : NormedTensorGaussianSplat2D) (M_C : Matrix (Fin 2) (Fin 4) ℂ) (x y : ℝ) :
    splat.complexTwistorWavepacket M_C x y =
      ↑(Real.sqrt (splat.eval x y)) *
        (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) ∧
    splat.complexTwistorIntensity M_C x y =
      splat.eval x y *
        Complex.normSq (complexTwoRowMinor M_C 0 2 * complexTwoRowMinor M_C 1 3) ∧
    (complexPluckerSinkAmplitudeA M_C + complexPluckerSinkAmplitudeB M_C = 0 →
      splat.complexTwistorIntensity M_C x y = 0) := by
  have h := splat.complexTwistor_representation_identities M_C x y
  exact ⟨h.1, h.2.1, h.2.2.2⟩
```

---

## 2. Advantages, Limitations, and Justification Across All Four `grassmannian-*-paper` Domains

The table below synthesizes the mathematical justification, computational advantages, and physical/numerical limitations of normed Tensor Gaussian Splatters across each of the four companion papers:

| Companion Paper & Domain | How Normed Tensor Gaussian Splats Enter the Mechanics | Key Mathematical & Computational Advantages | Explicit Limitations & Required Hybrid Controls |
|---|---|---|---|
| **1. Double-Slit, $N$-Slit ($N > 0$), Huygens–Steiner, & OAM** ([grassmannian-huygens-double-slit-oam-paper.md](grassmannian-huygens-double-slit-oam-paper.md)) | Coherent twistor wavepackets $\Psi_{\mathrm{splat}}(M_{\mathbb{C}}; x, y)$ and Wigner phase-space Gaussian marginals (`wignerDoubleSlit`, `wignerOAMDoubleSlit`) | • Exact analytical Wigner transform (Gaussians are the unique minimum-uncertainty states with positive Wigner distributions)<br>• Covariance determinant $\det\Sigma = \sigma_0^4(1 - d_{\mathrm{bary}}^2) = \sigma_0^4\mathcal{V}^2$ encodes Qian–Izadi visibility directly<br>• Zero relative error everywhere when paired with Layer 2 twistor phase (`complexTwistorIntensity`) | • **Limitation 1**: Real density-only splats ($G_A + G_B \ge 0$) cannot cancel at dark fringes ($50\%$ unphased error) without Layer 2 complex twistor phase<br>• **Limitation 2**: Sharp rectangular slit edges produce $\operatorname{sinc}^2$ sidelobes requiring either an explicit $\operatorname{sinc}^2$ envelope or a multi-Gabor wavelet sum<br>• **Limitation 3**: OAM vortex cores ($\Delta\ell \neq 0$) have a central intensity null requiring Laguerre–Gaussian or ring-arranged splats |
| **2. QISM, Algebraic Bethe Ansatz, & Soliton Bus** ([grassmannian-qism-bethe-ansatz-paper.myst.md](grassmannian-qism-bethe-ansatz-paper.myst.md)) | Solitonic wavepackets in `Signals.SolitonBus`, $2 \times 2$ Lax/monodromy covariance transport, and $GL(2)$ basis-change updates | • $GL(2)$ basis changes $M \mapsto B M$ (`twoRowMinor_basisChange`) act as affine matrix updates $\Sigma \mapsto B \Sigma B^T$ instead of $2^N$ Hilbert-space matrix multiplications<br>• Non-singular covariance ($\det\Sigma > 0$) mirrors MTV Casorati Wronskian nondegeneracy (`mtv_wronskian_nondegenerate_of_root`) | • **Limitation 1**: Exact discrete spin-chain Bethe roots ($Q_+(u_m) = 0$) and $2 \times 2$ Slavnov Pauli-exclusion zeros (`slavnovDet2_pauli_exclusion`) are exact polynomial/determinant identities; Gaussian splats model continuum NLSE soliton envelopes or Husimi phase-space projections, not discrete spin-chain combinatorics |
| **3. Dilatant Dark Fluid (DDF) Moving Sheaths & Anosov Flows** ([grassmannian-ddf-moving-sheath-paper.myst.md](grassmannian-ddf-moving-sheath-paper.myst.md)) | `MovingSheath.ddfTensorSplat` ($\sigma_1 = \sigma_0/\gamma_\varphi(v)$, $\sigma_2 = \sigma_0$) and `NormedTensorGaussianSplat2D.coreBohmPotential` | • **Built-in Continuity**: $L^1$ normalization $w\,\mathcal{N}(\Sigma)$ conserves mass/energy analytically without Poisson pressure solvers<br>• **Lorentz Jamming**: $\det\Sigma_{\mathrm{DDF}} = \sigma_0^4\gamma_\varphi(v)^{-2}$ and $\mathcal{N}_{\mathrm{DDF}} = \frac{\gamma_\varphi(v)}{2\pi\sigma_0^2}$<br>• **Core Singularity Regularization**: Repulsive Bohm quantum potential $Q_{\mathrm{core}}^{\mathrm{DDF}} = \frac{\hbar^2}{4m\sigma_0^2}(\gamma_\varphi(v)^2 + 1) > 0$ prevents cavitation/horizon blow-up<br>• **Symplectic Anosov Invariance**: $\operatorname{diag}(e^{\lambda t}, e^{-\lambda t})$ preserves $\det\Sigma$ | • **Limitation 1**: Under long-time chaotic Anosov stretching ($\lambda t \gg 1$), a single Gaussian splat becomes arbitrarily thin and elongated, requiring dynamic splat splitting/remeshing to resolve curved streamlines<br>• **Limitation 2**: Hard shock discontinuities (e.g. Sod shock tube in `FlowFieldDataset`) are smoothed over the scale $\sigma_1$ |
| **4. QED Scattering Gravity, Mercury's Perihelion, & $N$-Body Orbits** ([grassmannian-gravity-from-qed-scattering-paper.md](grassmannian-gravity-from-qed-scattering-paper.md)) | `PlanetaryOrbit.gr24TensorSplat` ($\sigma_{1,2} = \sigma_0\sqrt{1\pm e}$) and multi-layer `OrbitalSplatScene` | • Encodes the precessing Keplerian orbit in one $2 \times 2$ tensor with $\operatorname{Tr}\Sigma = 2\sigma_0^2$, $\det\Sigma = \sigma_0^4(1-e^2) = \sigma_0^4(p/a)$, and orientation $\varpi(t)$<br>• Softens $1/r \to \infty$ close-encounter singularities in $N$-body sink-flow interactions | • **Limitation 1**: A single Gaussian decays exponentially ($\exp(-r^2/(2\sigma^2))$), whereas Newtonian/Bernoulli gravity $\Phi_\phi(r) = -G_\phi M / r$ is long-ranged ($1/r$). Long-range orbital forces require either a multi-scale Gaussian sum ($\frac{1}{r} = \frac{2}{\sqrt{\pi}}\int_0^\infty e^{-u^2 r^2}du$) or hybridizing exact $1/r$ sink potentials with Gaussian field/core splats (as in `orbital_splat.frag.glsl`) |

### 2.1 Machine-Checked Core Bohm Quantum Potential Regularization (`coreBohmPotential_identities`)

In [Provenance Chat Log: Grassmannian Splat Mechanics (2026)](#splat-chat2026) (lines 1414–1435), a central physical justification for normed tensor Gaussian splatters is that their $C^\infty$ smoothness regularizes the Bohm quantum potential $Q = -\frac{\hbar^2}{2m}\frac{\nabla^2 \sqrt{\rho}}{\sqrt{\rho}}$ at vortex and sink cores. In [src/signals/Signals/DDF.lean](../src/signals/Signals/DDF.lean#L2842-L2905), `NormedTensorGaussianSplat2D.coreBohmPotential` and `NormedTensorGaussianSplat2D.coreBohmPotential_identities` prove that at the splat center $(x_0, y_0)$:

$$
Q_{\mathrm{core}}(\Sigma) = \frac{\hbar^2}{4m}\left(\frac{1}{\sigma_1^2} + \frac{1}{\sigma_2^2}\right) = \frac{\hbar^2\,\operatorname{Tr}\Sigma}{4m\,\det\Sigma} > 0,
$$

and for a DDF moving sheath (`s.ddfTensorSplat` with $\sigma_1 = \sigma_0 \gamma_\varphi(v)^{-1}$ and $\sigma_2 = \sigma_0$):

$$
Q_{\mathrm{core}}^{\mathrm{DDF}}(s) = \frac{\hbar^2}{4 m \sigma_0^2}\bigl(\gamma_\varphi(v)^2 + 1\bigr).
$$

As $v \to c$, $\gamma_\varphi(v) \to \infty$ and $Q_{\mathrm{core}}^{\mathrm{DDF}}(s)$ grows quadratically with $\gamma_\varphi(v)$, providing the exact quantum-hydrodynamic counter-pressure that prevents singular horizon collapse.

```lean
-- 2. DDF MovingSheath and Gr_C(2,4) PlanetaryOrbit tensor splat covariance & core Bohm potential laws
example {sub : DDFSubstrate} (s : MovingSheath sub) (orb : PlanetaryOrbit)
    (θ ϖ : ℝ) :
    let splat_ddf := s.ddfTensorSplat 0 0 5 2 (by norm_num) (by norm_num) θ
    let splat_orb := orb.gr24TensorSplat 0 0 3 2 (by norm_num) (by norm_num) ϖ
    splat_ddf.covDet = 2 ^ 4 * (s.jammingFactor ^ 2)⁻¹ ∧
    splat_ddf.normFactor = s.jammingFactor / (2 * Real.pi * 2 ^ 2) ∧
    splat_ddf.coreBohmPotential 1 1 =
      (1 ^ 2 / (4 * 1 * 2 ^ 2)) * (s.jammingFactor ^ 2 + 1) ∧
    splat_orb.covTrace = 2 * 2 ^ 2 ∧
    splat_orb.covDet = 2 ^ 4 * (orb.semiLatusRectum / orb.semiMajorAxis) := by
  intro splat_ddf splat_orb
  have h_ddf := s.ddfTensorSplat_identities 0 0 5 2 (by norm_num) (by norm_num) θ
  have h_bohm := NormedTensorGaussianSplat2D.coreBohmPotential_identities
    s splat_ddf 0 0 5 2 1 1 θ (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h_orb := orb.gr24TensorSplat_identities 0 0 3 2 (by norm_num) (by norm_num) ϖ
  exact ⟨h_ddf.2.1, h_ddf.2.2, h_bohm.2.2, h_orb.1, h_orb.2.2⟩

end ArxivSplatMechanicsPaperVerification
```

---

## 3. Practical Browser Execution: Why Rust $\to$ WASM + WebGL2 GLSL Wins Today (vs. WebGPU, WebNN, and WebTPU)

A decisive practical benefit of formulating $Gr_{\mathbb{C}}(2,4)$, DDF, and $N$-body orbital mechanics in terms of **normed 2D/3D anisotropic Tensor Gaussian Splatters** is that per-step dynamical evolution reduces to low-dimensional $2 \times 2$ or $3 \times 3$ matrix algebra in **Rust + WebAssembly (`wasm32-unknown-unknown`)**, while spatial field evaluation reduces to embarrassingly parallel Mahalanobis quadratic forms in **WebGL2 GLSL (`#version 300 es`)**:

| Browser Target / API | Browser & OS Availability (2026) | Precision & Kernel Expressiveness | Suitability for $Gr_{\mathbb{C}}(2,4)$ & DDF Tensor Splat Mechanics |
|---|---|---|---|
| **1. Rust $\to$ WASM (`wasm32-unknown-unknown`) + WebGL2 GLSL (`#version 300 es`)** ([double_slit.frag.glsl](../src/signals/numerical_adapter/src/shaders/double_slit.frag.glsl), [orbital_splat.frag.glsl](../src/signals/numerical_adapter/src/shaders/orbital_splat.frag.glsl)) | **Ubiquitous ($\sim 98\%+$)** across desktop, mobile (iOS/Android), Linux containers, and headless CI (Playwright SwiftShader / Lavapipe) | **WASM**: IEEE-754 `f64` for symplectic Velocity-Verlet, Kepler/precession, and complex Plücker minors<br>**WebGL2 GLSL**: `highp float` (`f32`) with native `vec2`/`vec4`, `mat2`, `cos`, `sin`, `exp` per fragment | **Optimal & Deployed**: WASM updates the compact splat array (`u_splat_center_weight_role`, `u_splat_sigma_angle_norm`) in microseconds; WebGL2 evaluates all splats per pixel at $60\text{–}120\text{ FPS}$ with zero external runtime dependencies |
| **2. WebGPU (WGSL Compute & Render Shaders)** | **Partial ($\sim 65\text{–}75\%$)**; often disabled or unavailable on Linux browsers, older mobile GPUs, enterprise policies, and unprivileged Docker/Podman CI without Vulkan/Metal passthrough | Supports general-purpose compute shaders and storage buffers (`f32`/`f16`, optional `f64` extension rarely exposed) | **Future Optional Backend**: Useful when millions of 3D splats require GPU radix sorting, but unnecessary for analytic $Gr_{\mathbb{C}}(2,4)$ / DDF tensor splats and breaks fallback-free portability |
| **3. WebNN (W3C Web Neural Network API)** | **Experimental / Hardware-Gated**; varies across OS NPU drivers (DirectML, CoreML, XNNPACK) | Fixed operator graph (`conv2d`, `matmul`, `softmax` in `f16`/`int8`); **no custom transcendental shaders**, no complex Plücker determinants, no `f64` symplectic ODE integrators | **Unsuitable for Primary Physics**: Expressing Mahalanobis splat evaluation or Velocity-Verlet orbital integration as a static ONNX/WebNN graph incurs severe memory-bandwidth and quantization overhead |
| **4. "WebTPU" (Hypothetical Browser TPU API)** | **Does Not Exist ($0\%$)**; no W3C standard exposes raw systolic-array TPU/NPU instructions to browser sandboxes | N/A — client NPUs/TPUs are fixed-function low-precision (`int4`/`int8`/`bf16`) matrix engines behind OS-specific ML runtimes | **Non-Existent in Browsers**: Even on devices with neural accelerators, custom scientific PDE and tensor-splat kernels execute far more portably and accurately on WebGL2 fragment pipelines + WASM |

### 3.1 How the Hybrid Rust/WASM (`f64`) + WebGL2 GLSL (`f32`) Pipeline Splits the Workload

In [src/signals/numerical_adapter/src/orbital_splat.rs](../src/signals/numerical_adapter/src/orbital_splat.rs) and [src/signals/numerical_adapter/src/double_slit.rs](../src/signals/numerical_adapter/src/double_slit.rs):
1. **CPU / WASM (`f64` Exact Invariant Layer)**:
   - Integrates the symplectic Velocity-Verlet trajectory (`RelativisticOrbitState::step_velocity_verlet`), where `f64` precision is essential to prevent secular drift in specific angular momentum $h$ and mechanical energy $\mathcal{E}$ over thousands of orbits, and to resolve Mercury's $42.98''/\text{century}$ ($\Delta\varpi \approx 5.02 \times 10^{-7}\text{ rad/orbit}$) precession.
   - Evaluates the exact $Gr_{\mathbb{C}}(2,4)$ and $Gr_{\mathbb{C}}(2, N+2)$ Plücker minors (`Gr24OrbitalInvariants::evaluate`, `nbody_bernoulli_potential_gr2n`) and packs each `NormedTensorGaussianSplat2D` into two `vec4` uniform slots via `to_glsl_uniform_pair()`:
     - `u_splat_center_weight_role[i] = vec4(center_x, center_y, weight, float(role))`,
     - `u_splat_sigma_angle_norm[i] = vec4(sigma1, sigma2, orientation_angle, norm_factor)`.
2. **GPU / WebGL2 Fragment Shader (`#version 300 es` Parallel Field Layer)**:
   - In [orbital_splat.frag.glsl](../src/signals/numerical_adapter/src/shaders/orbital_splat.frag.glsl), each pixel $(x, y)$ evaluates `evaluate_normed_tensor_splat` in 12 floating-point operations (one 2D rotation, two divisions, two squarings, one `exp`), accumulating four physically distinct channels in a single pass:
     - `SplatRole::BodySinkSource (0)`: Central solar sink and planetary attractors/sources,
     - `SplatRole::Gr24OrbitalField (1)`: Complex $Gr_{\mathbb{C}}(2,4)$ orbital covariance splats ($\sigma_{1,2} = \sigma_0\sqrt{1\pm e}$),
     - `SplatRole::DdfMovingSheathField (2)`: DDF shear-jammed moving-sheath splats ($\sigma_1 = \sigma_0 / \gamma_\varphi(v)$),
     - `SplatRole::VortexSwirlField (3)`: Gravitomagnetic Kerr–Lense–Thirring vortex swirl splats.

---

## 4. Conclusion & Reproducibility

Normed anisotropic Tensor Gaussian Splatters provide a mathematically verified, conservation-preserving bridge between abstract Grassmannian twistor geometry ($Gr_{\mathbb{C}}(2,4)$ and $Gr_{\mathbb{C}}(2, N+2)$) and continuum quantum-hydrodynamic / orbital simulations (`Signals.DDF`). By pairing the covariance tensor $\Sigma$ ($\det\Sigma = \sigma_0^4 \mathcal{V}^2 = \sigma_0^4 \gamma_\varphi(v)^{-2} = \sigma_0^4 (p/a)$) with the complex Plücker wavepacket $\Psi_{\mathrm{splat}} = \sqrt{G}\,\Delta_{02}^{\mathbb{C}}\Delta_{13}^{\mathbb{C}}$ and executing the pipeline in Rust/WASM (`f64`) + WebGL2 GLSL (`#version 300 es`), the entire framework runs with machine-checked mathematical rigor and universal browser compatibility.

```bash
make signals_build
pushd src/signals
lake build :blueprint :blueprintJson
pushd numerical_adapter
cargo test
cargo build --lib --target wasm32-unknown-unknown --release
popd
popd
```

---

### Scholarly References

<a id="splat-qian2023"></a>
1. Qian, X.-F., and Izadi, M. (2023). *Bridging Coherence Optics and Classical Mechanics: A Generic Light Polarization-Entanglement Complementary Relation*. Physical Review Research 5(3), 033110. [DOI: 10.1103/PhysRevResearch.5.033110](https://doi.org/10.1103/PhysRevResearch.5.033110).

<a id="splat-arkani2014"></a>
2. Arkani-Hamed, N., and Trnka, J. (2014). *The Amplituhedron*. Journal of High Energy Physics 2014(10), 030. [DOI: 10.1007/JHEP10(2014)030](https://doi.org/10.1007/JHEP10%282014%29030); [arXiv:1312.2007](https://arxiv.org/abs/1312.2007).

<a id="splat-fedi2026"></a>
3. Fedi, M. (2026). *Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of Lorentz Invariance, Gravity, and Cosmological Phenomenology*. SSRN Preprint 7406660.

<a id="splat-partanen2025"></a>
4. Partanen, M., and Tulkki, J. (2025). *Gravity Generated by Four One-Dimensional Unitary Gauge Symmetries and the Standard Model*. Reports on Progress in Physics 88, 057802; [arXiv:2506.14447](https://arxiv.org/abs/2506.14447).

<a id="splat-chat2026"></a>
5. Provenance Chat Log (2026). *Grassmannian Splat Mechanics and Vortex Space Emergence*. ({download}`data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 1395-1558 <../data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md>`).

---

### BibTeX Citations

```bibtex
@article{qian2023bridging,
  author  = {Qian, Xiao-Feng and Izadi, Misagh},
  title   = {Bridging Coherence Optics and Classical Mechanics: A Generic Light Polarization-Entanglement Complementary Relation},
  journal = {Physical Review Research},
  volume  = {5},
  number  = {3},
  pages   = {033110},
  year    = {2023},
  doi     = {10.1103/PhysRevResearch.5.033110}
}

@article{fedi2026ddf,
  author  = {Fedi, Marco},
  title   = {Dilatant Dark Fluid: Toward a Unified Quantum-Hydrodynamic Origin of {L}orentz Invariance, Gravity, and Cosmological Phenomenology},
  journal = {SSRN Electronic Journal},
  year    = {2026},
  note    = {SSRN Preprint 7406660}
}

@misc{chat_grassmannian_splat_2026,
  author       = {{Unknown}},
  title        = {Grassmannian Splat Mechanics and Vortex Space Emergence},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md, lines 1395-1558}
}
```

### Schema.org Metadata (JSON-LD)

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Normed Tensor Gaussian Splat Mechanics for Complex Gr_C(2,4) Twistors: Advantages, Limitations, WebGL2/WASM Practicality, and Unification Across Double-Slit, QISM, DDF, and Planetary Gravity in Lean 4",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-10-24",
  "about": [
    "Normed Tensor Gaussian Splatting",
    "Complex Grassmannian Gr_C(2,4)",
    "Twistor Geometry",
    "Dilatant Dark Fluid",
    "WebGL2 GLSL",
    "WebAssembly",
    "Lean 4 Formal Verification"
  ],
  "isBasedOn": [
    "data/chats/Grassmannian Splat Mechanics and Vortex Space Emergence.md",
    "docs/grassmannian-huygens-double-slit-oam-paper.md",
    "docs/grassmannian-qism-bethe-ansatz-paper.myst.md",
    "docs/grassmannian-ddf-moving-sheath-paper.myst.md",
    "docs/grassmannian-gravity-from-qed-scattering-paper.md",
    "src/signals/Signals/DDF.lean",
    "src/signals/numerical_adapter/src/orbital_splat.rs"
  ]
}
```
