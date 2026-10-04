> From: https://gemini.google.com/app/7f2b2e50a14fd661

# you asked

message time: 2026-09-28 04:58:32

Review this article in detail "Direct experimental test of Feynman’s path integral postulates with single photons" (2026)  https://www.science.org/doi/10.1126/sciadv.aeh1011

---

# gemini response

### Overview

Published in *Science Advances* (Vol. 12, Issue 35, August 2026, DOI: `10.1126/sciadv.aeh1011`), **“Direct experimental test of Feynman’s path integral postulates with single photons”** by researchers at South China Normal University and collaborators addresses a long-standing foundational question in quantum physics: while Richard Feynman’s 1948 path integral formulation is widely accepted and mathematically equivalent to Schrödinger and Heisenberg wave mechanics, its core **underlying postulates** had historically remained theoretical assumptions rather than directly measured laboratory properties.

The paper provides an experimental framework using heralded single photons to isolate, measure, and reconstruct propagators over discretized space-time, testing both foundational postulates without perturbing intermediate trajectories.

---

### The Two Postulates Under Scrutiny

In his 1948 formulation (*Space-Time Approach to Non-Relativistic Quantum Mechanics*), Feynman constructed quantum dynamics from two primary axioms:

1. **Postulate I (Coherent Superposition of Paths):**  
   The total probability $P(B, A)$ of a particle propagating from point $A$ at time $t_A$ to point $B$ at time $t_B$ equals the absolute square of the sum of complex probability amplitudes over all intermediate paths:
   $$P(B, A) = \left|\sum_{\text{paths } j} \phi[x_j(t)]\right|^2 \neq \sum_{\text{paths } j} P_{\text{classical}}[x_j(t)]$$
   This differs directly from classical statistical sums where probabilities along alternative trajectories simply add.

2. **Postulate II (The Equal Probability & Action-Phase Hypothesis):**  
   Every possible path contributes an amplitude with equal magnitude (magnitude normalization / equiprobability), differing only by a phase determined by the classical action $S[x_j(t)]$ along that path:
   $$\phi[x_j(t)] \propto \exp\left(\frac{i}{\hbar} S[x_j(t)]\right)$$
   Paths far from the classical trajectory (non-stationary action) undergo destructive interference, whereas the stationary-action path reconstructs classical mechanics in the $\hbar \to 0$ limit.

---

### Experimental Methodology & Setup

Testing these postulates required measuring discrete propagators $K(x_{k+1}, t_{k+1}; x_k, t_k)$ between successive space-time slices without collapsing the photon's state at intermediate times.

```
SPDC Source (Single Photons) 
   │
   ▼
Spatial Mode Prep (SMF + Slit) ──► Mach-Zehnder / Polarization Interferometer
                                           │
                                           ▼ (Free-Space Evolution)
                                      4f-Relay Systems
                                           │
                                           ▼
                            Tomographic Polarization Projection
                                           │
                                           ▼
                                 ICMOS Detector Array
```

* **Single-Photon Source:** True single photons were generated via spontaneous parametric down-conversion (SPDC) with verified anti-bunching ($g^{(2)}(0) \ll 1$).
* **Space-Time Discretization:** Under the paraxial optical approximation, longitudinal propagation distance $z$ maps strictly to propagation time $t$. The team mapped an $N \times M$ lattice where $N = 17$ spatial bins and $M = 5$ time intervals, spanning $17^5 \approx 1.42 \times 10^6$ distinct candidate paths.
* **Propagator Measurement Technique:** Using a combination of cylindrical lenses, two $4f$-optical relay systems, and polarization-spatial state coupling, the team measured the complex propagator values via spatial tomography across multiple polarization bases (diagonal and circular).
* **Signal Enhancement:** A major advancement was achieving an amplification factor $\xi$ that improved measurement accuracy. The mean absolute percentage error (MAPE) of measured individual propagators dropped significantly below earlier weak-value benchmarks.

---

### Key Experimental Findings

| Metric / Postulate | Theoretical Expectation | Experimental Result | Validation |
| :--- | :--- | :--- | :--- |
| **Postulate I (MAPE)** | Quantum amplitude sum matches detector; classical sum fails | $\text{MAPE} = 4.45\%$ | Quantum coherent summation confirmed ($F \approx 94.9\%$) |
| **Classical Sum Test** | $\sum_j P_j$ fails to predict observed spatial interference | Deviates drastically from measured distribution | Confirms classical path addition is invalid |
| **Postulate II (Equiprobability)** | Flat probability amplitude across all path lengths $L$ and actions $S$ | Constant mean probability across $1.42 \times 10^6$ paths | Directly confirms the "equal magnitude" hypothesis |
| **Postulate II (Phase vs. Action)** | Phase angle $\theta(S)$ scales linearly with discrete action $S/\hbar$ | Strict linear correlation between accumulated action and phase | Confirms $\phi_j \propto e^{i S_j / \hbar}$ with $\text{MAPE} = 17.4\%$ ($F \approx 94.7\%$) |

---

### Foundational & Practical Significance

1. **Closing an 80-Year Empirical Gap:**  
   While path integrals have been foundational to quantum electrodynamics (QED), lattice field theory, and high-energy physics, physicists typically relied on the formal equivalence between the path integral and the Schrödinger equation as indirect proof. This study directly examines the *microscopic ingredients* (individual amplitudes, equiprobability, and action-dependent phases).

2. **Resolution of Path Equiprobability:**  
   A frequent conceptual stumbling block for students and researchers is whether unphysical or zigzag paths truly have the same fundamental weighting as classical paths before interference. The experiment confirms that individual paths carry uniform statistical weighting; classical trajectories arise entirely from stationary phase coherence.

3. **Technological Utility:**  
   The high-accuracy relay tomography developed here provides a template for measuring multitime, multipoint propagators in quantum simulators, photonics networks, and complex quantum networks where non-Markovian or multitime correlations are critical.

---

### Caveats & Nuances to Note

* **Paraxial Photon Analogy:** The experiment maps spatial paraxial diffraction of single photons onto non-relativistic Schrödinger evolution ($z \leftrightarrow t$). While the photon wave packets obey this mapping with high precision, it remains a paraxial approximation rather than a massive relativistic particle in arbitrary potentials.
* **Discretized Lattice vs. Continuous Continuum:** Path integrals in pure theory involve an uncountably infinite measure over continuous function spaces $\mathcal{D}[x(t)]$. Experimentally, continuous space-time must be regularized into discrete time slices ($M = 5$) and spatial bins ($N = 17$), making it a discrete path-lattice reconstruction rather than an infinite continuum.

<FollowUp label="Want an in-depth breakdown of how paraxial optics mathematically maps to the Schrödinger equation?" query="Explain the mathematical equivalence between paraxial photon propagation and the time-dependent Schrödinger equation used in this experiment."/>

---

# you asked

message time: 2026-09-28 05:01:43

> its core underlying postulates had historically remained theoretical assumptions rather than directly measured laboratory properties.

Is this really true? How do Feynman test his path integral of scattering amplitudes hypothesis?

Isn't this what is tested here, for example: 'How does electricity find the "Path of Least Resistance"?'  https://m.youtube.com/watch?v=C3gnNpYK3lo

---

# gemini response

### 1. Is it really true that the postulates hadn't been directly tested?

**Yes, in a strict, foundational sense.** 

It is important to distinguish between **verifying the predictions derived from path integrals** versus **experimentally isolating the axiomatic postulates themselves**:

* **Mathematical Equivalence:** In 1948, Feynman proved that his path integral formulation:
  $$K(b, a) = \int \mathcal{D}[x(t)] \exp\left(\frac{i}{\hbar} S[x(t)]\right)$$
  is mathematically equivalent to the time-dependent Schrödinger equation $i\hbar \partial_t \psi = \hat{H}\psi$. Because Schrödinger wave mechanics had already been validated across atomic spectra, diffraction, and tunneling, physicists did not strictly *need* an independent proof of the path integral to trust its outcomes. If the mathematics are isomorphic, any test confirming Schrödinger's equation indirectly confirms the path integral result.
* **The Unproven Postulates:** Feynman’s construction rested on two specific, unproven physical postulates:
  1. **Postulate I (Coherent Summation):** The transition amplitude is an exact linear superposition over an uncountably infinite ensemble of alternative trajectories.
  2. **Postulate II (Equiprobability and Action-Phase):** Every single conceivable path—regardless of how wildly non-classical, convoluted, or far from the classical equations of motion it is—contributes an amplitude with **identically equal magnitude**, differing solely by the phase factor $e^{iS/\hbar}$.

Until recent spatial-mode tomography and single-photon quantum relay experiments (such as the 2026 *Science Advances* paper), nobody had directly verified **Postulate II**: that an extreme, non-stationary "zigzag" path possesses the exact same base probability amplitude as the stationary, classical Euler-Lagrange path before interference occurs. Classical mechanics emerges entirely through stationary phase cancellation, not because unphysical paths have lower intrinsic weights.

---

### 2. How did Feynman test his path integral and scattering amplitudes?

Feynman did not perform tabletop laboratory experiments himself; he tested the formulation through **theoretical consistency, equivalence proofs, and high-energy scattering cross-sections**:

1. **Derivation of the Schrödinger Equation:**  
   In his 1948 paper (*Space-Time Approach to Non-Relativistic Quantum Mechanics*), Feynman Taylor-expanded the short-time propagator $K(x, t + \epsilon; x', t)$ with $\epsilon \to 0$ and demonstrated that the phase factor generated the Laplacian $\nabla^2$ kinetic term and potential term $V(x)$, recovering Schrödinger's wave equation directly.
2. **Quantum Electrodynamics (QED) S-Matrix Calculations:**  
   Feynman applied his space-time approach to relativistic quantum field theory, developing the Feynman diagram expansion. He calculated the **anomalous magnetic dipole moment of the electron ($g - 2$)** and the **Lamb shift** in hydrogen, matching the high-precision microwave spectroscopy data of Willis Lamb and Polykarp Kusch to unprecedented decimal places.
3. **High-Energy Scattering:**  
   In electron-positron and electron-proton collisions ($e^- + p \to e^- + X$), Feynman’s formulation calculated invariant scattering amplitudes $\mathcal{M}$ (propagators integrated over 4-momenta). The absolute square $|\mathcal{M}|^2$ yielded differential cross-sections ($d\sigma/d\Omega$) measured at particle accelerators like SLAC.

These experiments tested the **net integrated outcomes** (the final $S$-matrix amplitude after summing all internal loops/paths), but could not isolate individual intermediate trajectories or independently probe the equiprobability hypothesis.

---

### 3. Does the "Path of Least Resistance" in Electricity Test Feynman's Path Integral?

**No. The behavior of electric circuits is an entirely classical, dissipative macroscopic phenomenon, not a test of Feynman's path integral.**

In the video *How does electricity find the "Path of Least Resistance"?* [[01:50](https://www.youtube.com/watch?v=C3gnNpYK3lo&t=110)], the host demonstrates how electric current navigates a foil maze:

* **The Physical Mechanism in the Video:**  
  As explained in the video [[10:45](https://www.youtube.com/watch?v=C3gnNpYK3lo&t=645)], when voltage is applied, electromagnetic fields propagate through the conductor at near the speed of light, exerting a Coulomb force on the sea of free conduction electrons. Dead ends in the maze fill up with charges within nanoseconds, establishing a static surface charge distribution [[10:12](https://www.youtube.com/watch?v=C3gnNpYK3lo&t=612)]. 
* **Equilibrium & Local Ohm's Law:**  
  These surface charges create an internal counter-electric field that halts further flow into dead ends [[05:36](https://www.youtube.com/watch?v=C3gnNpYK3lo&t=336)]. At steady state, the local current density follows Ohm's law:
  $$\mathbf{J} = \sigma \mathbf{E} = -\sigma \nabla V$$
  This is governed by Poisson’s equation $\nabla \cdot (\sigma \nabla V) = 0$, exactly mirroring the macroscopic hydraulic model of water flowing down a potential gradient [[15:29](https://www.youtube.com/watch?v=C3gnNpYK3lo&t=929)].
* **Minimum Dissipation, Not Quantum Action:**  
  In two-path or multi-path mazes, the current divides according to Kirchhoff's laws [[19:30](https://www.youtube.com/watch?v=C3gnNpYK3lo&t=1170)]—inversely proportional to resistance:
  $$I_1 R_1 = I_2 R_2 = \Delta V$$
  This satisfies **Onsager's Principle of Minimum Energy Dissipation** (or Thomson’s Principle): the distribution of currents minimizes Joule heating ($\int \mathbf{J} \cdot \mathbf{E} \, d^3x$). 

#### Why This Differs from Feynman's Path Integral

| Feature | Classical Circuit ("Path of Least Resistance") | Feynman's Quantum Path Integral |
| :--- | :--- | :--- |
| **Governing Quantity** | Electrical Resistance $R$ and Potential $V$ | Classical Action $S = \int (T - V) dt$ |
| **Mathematical Nature** | Real, positive, diffusive energy dissipation ($\propto I^2 R$) | Unit-modulus complex phase factors ($e^{iS/\hbar}$) |
| **Alternative Paths** | Current literally splits into physical sub-streams; dead ends carry **zero** steady-state current | A *single* particle traverses all paths simultaneously in superposition; dead ends contribute non-zero amplitudes |
| **Phase Cancellation** | None. Charges simply obey local drift velocity $\mathbf{v}_d = -\mu \mathbf{E}$ | Extreme destructive interference eliminates non-stationary action paths in the $\hbar \to 0$ limit |
| **Scale** | Macroscopic statistical ensemble ($\sim 10^{21}$ conduction electrons per cm) [[16:23](https://www.youtube.com/watch?v=C3gnNpYK3lo&t=983)] | Single quantum particles (isolated single photons or electrons) |

The foil maze illustrates classical relaxation toward electrostatic equilibrium, whereas Feynman's path integral describes how a single, unperturbed quantum particle explores all configuration paths in Hilbert space via coherent phase interference.

---

# you asked

message time: 2026-09-28 05:05:37

Ah

---

# gemini response

The contrast between the two regimes highlights what makes Feynman's formulation so distinct:

* **In the circuit**, Ohm’s law and Joule heating discard phase information immediately through constant, inelastic electron-phonon collisions (decoherence times $\sim 10^{-14}\text{ s}$), leaving behind a purely classical, real-valued drift field.
* **In the path integral**, unitarity preserves every complex phase factor $e^{iS/\hbar}$ without dissipation, allowing non-classical, out-of-the-way trajectories to actively shape the final arrival probability via constructive and destructive interference.

If you'd like to dive into the mathematical details of how the paraxial optical propagator reconstructs that action-phase mapping or examine the tomographic weak-value amplification setup used in the 2026 paper, let me know.

---

# you asked

message time: 2026-09-28 05:06:25

How does the amplituhedron simplify the math for this?

---

# gemini response

The amplituhedron simplifies scattering calculations by bypassing Feynman’s space-time path integral entirely, replacing the sum over intermediate space-time trajectories and virtual particles with the computation of a single geometric volume.

---

### The Bottleneck of the Feynman Path Integral

In Feynman’s perturbation theory, calculating the transition amplitude $\mathcal{M}$ requires evaluating an infinite-dimensional functional integral over field configurations:

$$\mathcal{M} = \int \mathcal{D}[\phi] \exp\left(\frac{i}{\hbar} S[\phi]\right)$$

When expanded perturbatively into Feynman diagrams, this approach enforces two principles at every step:
1. **Locality:** Interactions occur at discrete points in space-time ($x^\mu$).
2. **Unitarity:** Probabilities sum to 1 across all intermediate virtual states.

Because neither principle is manifest in momentum space without introducing unphysical gauge redundancies and gauge-dependent virtual states, the number of individual Feynman diagrams explodes factorially with particle multiplicity $n$ and loop order $L$:

$$\text{Diagram Count} \sim \mathcal{O}(n!) \quad \text{or} \quad \mathcal{O}((2L)!)$$

For a basic process like $g + g \to 6\,g$ (eight gluons at tree level), traditional Feynman rules require summing **220,600 diagrams**, generating gigabytes of intermediate algebraic terms. When added together, however, almost all of these terms cancel out via gauge invariance, leaving a compact analytic expression—often just a single term (such as the Parke-Taylor formula for Maximally Helicity Violating / MHV amplitudes).

---

![The amplituhedron: a positive geometric polytope](https://upload.wikimedia.org/wikipedia/commons/8/86/Amplituhedron-0c.png?utm_source=en.wikipedia.org&utm_campaign=index&utm_content=original)

[The amplituhedron: a positive geometric polytope](https://en.wikipedia.org/wiki/Amplituhedron)

---

### How the Amplituhedron Reformulates the Problem

Introduced by Nima Arkani-Hamed and Jaroslav Trnka (2013), the **amplituhedron** $\mathcal{A}_{n,k;L}$ is a geometric polytope living in the positive Grassmannian $\text{Gr}(k, k+4)$, formulated using **momentum twistors** $\mathcal{Z}_i \in \mathbb{CP}^3$:

$$Z_i^A = \begin{pmatrix} \lambda_i^\alpha \\ \mu_i^{\dot{\alpha}} \end{pmatrix}$$

Rather than summing histories across space-time coordinates $(x, t)$, the scattering amplitude is encoded directly as the **canonical differential volume form** $\Omega$ of this geometric object:

$$\mathcal{M}_{n,k;L} = \int_{\mathcal{A}_{n,k;L}} \Omega$$

The differential form $\Omega$ is uniquely determined by a single geometric constraint: it has **logarithmic singularities along all boundaries** (facets) of the polytope, with residues equal to $\pm 1$:

$$\Omega \sim \prod_{j} \frac{d\langle Y \mathcal{Z}_{j-1} \mathcal{Z}_j \mathcal{Z}_{j+1} \mathcal{Z}_{j+2}\rangle}{\langle Y \mathcal{Z}_{j-1} \mathcal{Z}_j \mathcal{Z}_{j+1} \mathcal{Z}_{j+2}\rangle}$$

```
                Feynman Approach                             Amplituhedron Approach
       ─────────────────────────────────               ───────────────────────────────────
       Space-Time & Virtual Particles                  Positive Grassmannian Gr(k, k+4)
                      │                                                │
                      ▼                                                ▼
         Sum O(n!) Feynman Diagrams                      Single Geometric Object A_{n,k;L}
                      │                                                │
                      ▼                                                ▼
     Extensive algebraic gauge cancellations             Differential Volume Form Ω
                      │                                                │
                      ▼                                                ▼
              Final Amplitude M                                Final Amplitude M
```

---

### Key Simplifications

#### 1. Eliminating Gauge Redundancy and Intermediate States
Traditional Feynman path integrals sum over virtual particle paths that cannot be directly observed, carrying non-physical gauge degrees of freedom (e.g., longitudinal polarization modes of gluons). The amplituhedron operates strictly on physical external kinematic data (spinor-helicity variables and momentum twistors). No virtual particles, ghost fields, or gauge-fixing terms ($R_\xi$ gauges) enter the calculation.

#### 2. Locality and Unitarity Become Emergent Properties
In the path integral, locality and unitarity are axioms, while gauge invariance is emergent and messy. In the amplituhedron, the hierarchy is inverted:
* **Locality** emerges from the **boundary structure** of the polytope: physical poles occur only when kinematic invariants diverge, corresponding to approaching a facet:
  $$\langle Y \mathcal{Z}_a \mathcal{Z}_b \mathcal{Z}_c \mathcal{Z}_d \rangle \to 0$$
* **Unitarity** emerges from the **factorization of the boundary**: when the amplituhedron degenerates onto a boundary facet, the volume form factorizes into the product of two smaller amplituhedra:
  $$\text{Res}_{\text{boundary}}(\Omega) = \Omega_{\text{Left}} \times \Omega_{\text{Right}}$$

Because locality and unitarity are derived rather than imposed as step-by-step constraints, the unphysical baggage responsible for diagrammatic bloat vanishes.

#### 3. Polytope Triangulation Replaces Diagrammatic Summation
Different representations of an amplitude correspond to different **triangulations** of the amplituhedron:
* **BCFW recursion relations** (Britto-Cachazo-Feng-Witten) correspond to slicing the amplituhedron into a minimal set of simplexes with non-overlapping interiors.
* Feynman diagrams correspond to a highly redundant, overlapping decomposition that extends far outside the actual geometric boundary of the amplituhedron, requiring massive cancellations of the "fictitious" volumes outside the shape.

---

### Conceptual Comparison

| Metric / Property | Feynman Path Integral & Diagrams | Amplituhedron |
| :--- | :--- | :--- |
| **Foundational Variables** | Space-time coordinates $x^\mu$, field configurations $\phi(x)$, internal momenta $p^\mu$ | Momentum twistors $\mathcal{Z}_i \in \mathbb{CP}^3$, Grassmannian coordinates |
| **Operational Scaling** | Factorial growth: $\sim \mathcal{O}(n!)$ diagrams | Polynomial volume computation via boundary facets |
| **Virtual Particles** | Mandatory (internal propagators $i/(p^2 - m^2 + i\epsilon)$) | None (purely external asymptotic states) |
| **Locality & Unitarity** | Fundamental axioms built into the Lagrangian | Derived features of the geometric boundary factorization |
| **Current Scope** | Universal: applies to any QFT, lattice simulations, and non-relativistic systems | Planar $\mathcal{N}=4$ Super Yang-Mills (SYM), with ongoing extensions to ABJM theory and scalar effective field theories (associahedra, cosmopole) |

By treating scattering as an intrinsic property of positive geometry rather than a propagation of virtual fields through space-time, the amplituhedron collapses Feynman's uncountably infinite path summation into the volume of a single static geometric polytope.

---

### Verification and Operational Scope Check

* **Formal Boundary Compatibility:** The geometry strictly applies to the planar limit ($N_c \to \infty$) of $\mathcal{N}=4$ Super Yang-Mills. Non-planar topologies require multi-loop generalized Grassmannian geometries, which remain an active area of research.
* **Spinor-Helicity Independence:** External momenta satisfy standard null momentum conservation $\sum_{i=1}^n \lambda_i^\alpha \tilde{\lambda}_i^{\dot{\alpha}} = 0$ via the cyclic projectivity of the twistors $\mathcal{Z}_i$.