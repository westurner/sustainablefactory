# Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws in Lean 4 and Rust/WASM

**Author**: Wes Turner
**Companion Lean 4 Formalization**: [`src/signals/Signals/QuantumCausalInference.lean`](../src/signals/Signals/QuantumCausalInference.lean), [`src/signals/Signals/Plabic.lean`](../src/signals/Signals/Plabic.lean), [`src/signals/Signals/LayerCodes.lean`](../src/signals/Signals/LayerCodes.lean), [`src/signals/Signals/Pending.lean`](../src/signals/Signals/Pending.lean), [`src/signals/SignalsPending.lean`](../src/signals/SignalsPending.lean)
**Companion Rust / WASM Implementation**: [`src/signals/numerical_adapter/src/quantum_causal_inference.rs`](../src/signals/numerical_adapter/src/quantum_causal_inference.rs)
**Companion Papers**:
- [Unified Grassmannian Synthesis & 18-Domain Roadmap (`grassmannian-unification-applications-roadmap-paper.md`)](grassmannian-unification-applications-roadmap-paper.md)
- [Multi-Spectral & Multi-Array Grassmannian Imaging & 3D Layer-Coding `Plabic` Provenance (`grassmannian-multispectral-hubble-medical-nanoimaging-paper.md`)](grassmannian-multispectral-hubble-medical-nanoimaging-paper.md)
- [Causal Second-Sound Thermal Conduction, Inverse Compton, & Raman Thermometry (`grassmannian-thermal-compton-raman-paper.md`)](grassmannian-thermal-compton-raman-paper.md)
- [Huygens–Steiner Double-Slit, OAM, & Plabic LGV Networks (`grassmannian-huygens-double-slit-oam-paper.md`)](grassmannian-huygens-double-slit-oam-paper.md)

---

## Abstract

Does **Grassmannian geometry** govern causal relations, counterfactual interventions, and quantum causal inference? And how do the four thermodynamic and causal frameworks discussed in [`data/chats/_Mpemba Effect_ Landau vs. Quantum .md`](../data/chats/_Mpemba%20Effect_%20Landau%20vs.%20Quantum%20.md)—**(1) Landau Free-Energy Landscapes** ([Holtzman & Raz 2022](#holtzman2022landau)), **(2) Quantum Resource Theory (QRT) & Thermo-Majorization** ([Summer et al. 2026](#summer2026resource)), **(3) Constructor Theory of Thermodynamics & Information** ([Deutsch 2013](#deutsch2013constructor); [Marletto 2015](#marletto2015info)), and **(4) Quantum Causal Models & Counterfactual Semantics** ([Giarmatzi & Costa 2023](#giarmatzi2023semantics); [Oreshkov, Costa, & Brukner 2012](#oreshkov2012process))—relate to conditional Landauer erasure ([del Rio et al. 2011](#delrio2011negative)) and the chat corpus's proposed **"entropy siphoning"**?

In this paper, we establish the exact mathematical and physical bridges and implement them in Lean 4 ([`Signals.QuantumCausalInference`](../src/signals/Signals/QuantumCausalInference.lean), [`Signals.Pending`](../src/signals/Signals/Pending.lean)) and zero-dependency Rust/WASM ([`quantum_causal_inference.rs`](../src/signals/numerical_adapter/src/quantum_causal_inference.rs)):

1. **Five Grassmannian Structures in Classical and Quantum Causal Relations**:
   - **Acyclic Causal Transfer & Plabic Positroid Cells ($\mathrm{Gr}_{\ge 0}(k, n)$)**: In any finite Directed Acyclic Graph (DAG) with nilpotent direct-effect matrix $W$ ($W^{h+1} = 0$), the total causal path transfer matrix is $T = \sum_{r=0}^h W^r = I + W T$ (`WeightedAcyclicNetwork.transfer_equation`). By the **Sullivant–Talaska–Draisma Trek Rule** ([Sullivant et al. 2010](#sullivant2010trek)) and **Lindström–Gessel–Viennot (LGV) Lemma** (`lgv_two_by_two_det`, `planar_threeChannel_lgv_and_bottleneck_identities`), $k$ causes act on $k$ effects through vertex-disjoint (unconfounded) pathways iff the $k \times k$ Plücker minor $\det T_{A,B} > 0$ (interior of $\mathrm{Gr}_{>0}(k,n)$). Whenever $k$ causal pathways factor through $m < k$ shared confounders or mediators (**d-separation bottleneck**), the Plücker minor vanishes identically ($\det T_{A,B} = 0$, e.g. `singleHubRepresentative_det = 0` for $2\times 2$ through 1 confounder hub and `(A * B).det = 0` for $3\times 3$ through 2 mediators), placing the causal model on a boundary Schubert/positroid cell of $\mathrm{Gr}(k, n)$.
   - **Pearl's Do-Calculus (`do(X := x)`) as Plabic Incoming-Edge Surgery & Subspace Projection**: In a confounded diamond ($U \to X, U \to Y, X \to Y$), observational transfer sums the direct causal path $d$ and the backdoor trek $b$ ($C_{\mathrm{obs}} = d + b$, matching `WeightedAcyclicNetwork.diamond_transfer`), whereas $\operatorname{do}(X := x)$ zeroes column $X$ of $W$ ($w_{U \to X} \mapsto 0$), isolating the pure causal effect $C_{\mathrm{do}} = d$ and exposing the confounding bias $C_{\mathrm{obs}} - C_{\mathrm{do}} = b$.
   - **Lorentzian & DDF Acoustic Lightcone Causality on $\mathrm{Gr}_{\mathbb{C}}(2,4)$**: In Penrose twistor theory and our Dilatant Dark Fluid (`Signals.DDF`), Minkowski spacetime is the Klein quadric of $\mathrm{Gr}_{\mathbb{C}}(2,4)$, and subluminal causal propagation ($|\beta| = |v|/c < 1$) is equivalent to the strict positivity of the Plücker channel determinant product $\|w_A^{\mathbb{C}}(M_{\mathrm{cone}})\|^2 \|w_B^{\mathbb{C}}(M_{\mathrm{cone}})\|^2 = 1 - \beta^2 > 0$, vanishing on the null horizon ($|\beta| = 1$).
   - **Choi–Jamiołkowski Quantum Causal Subspaces on $\mathrm{Gr}_{\mathbb{C}}(k, d_{\mathrm{in}} d_{\mathrm{out}})$**: A rank-$k$ quantum instrument or isometric channel $V : \mathcal{H}_{\mathrm{in}} \to \mathcal{H}_{\mathrm{out}}$ corresponds via the Choi–Jamiołkowski isomorphism to a $k$-dimensional subspace in $\mathrm{Gr}_{\mathbb{C}}(k, d_{\mathrm{in}} d_{\mathrm{out}})$ of real dimension $2 k (d_{\mathrm{in}} d_{\mathrm{out}} - k)$ ($\dim_{\mathbb{R}} \mathrm{Gr}_{\mathbb{C}}(4, 16) = 96$ for 2-qubit unitary causal channels).
   - **Indefinite Causal Order (`Quantum Switch`) on $\mathrm{Gr}_{\mathbb{C}}(2,4)$**: Superposing causal orders $A \prec B$ ($U_B U_A$) and $B \prec A$ ($U_A U_B$) projects onto the symmetric anticommutator branch $E_+ = \frac{1}{4}\|\{U_A, U_B\}\psi\|^2$ and antisymmetric commutator branch $E_- = \frac{1}{4}\|[U_B, U_A]\psi\|^2$. Encoding the causal-order asymmetry $\delta_{\mathrm{switch}} = \frac{E_+ - E_-}{E_+ + E_-}$ into `ddfThermalGr24Matrix δ_switch θ` recovers the exact commutator-to-anticommutator causal witness $\frac{\|w_B^{\mathbb{C}}\|^2}{\|w_A^{\mathbb{C}}\|^2} = \frac{E_-}{E_+}$.
2. **Comparison of the Four Mpemba & Counterfactual Frameworks (`_Mpemba Effect_ Landau vs. Quantum .md`)**:
   - We formalize and compare Landau quartic potentials and Strong Mpemba slow-mode orthogonal projection ($a_{2,\mathrm{hot}} = 0$ on the Grassmannian codimension-1 subspace $v_2^\perp$), QRT non-equilibrium free energy $\Delta F = k_B T \ln 2 \cdot D_{\mathrm{KL}}(\rho \| \gamma_\beta)$ and piecewise-linear Lorenz thermo-majorization ($\rho \succ_{\mathrm{th}} \sigma$), Constructor Theory task algebra (`ConstructorTask.compose`, side-information task unlocking), and Giarmatzi–Costa (`arXiv:2302.11783`) Abduction–Action–Prediction counterfactuals.
3. **Thermodynamic Critique & Numerical Audit of Chat "Entropy Siphoning"**:
   - We prove the single-shot conditional Landauer formula $Q_{\mathrm{erasure}}(F) = k_B T \ln 2 \cdot (1 - 2F)$ ([del Rio et al. 2011](#delrio2011negative)) and its interventional counterfactual gain $\mathcal{Q}^* = Q(\operatorname{do}(F=1)) - Q(\operatorname{do}(F=0)) = -2 k_B T \ln 2 < 0$, while proving three critical physical and numerical corrections to the chat corpus:
     1. **Closed-Loop Second-Law Compliance**: Including the observer memory reset ($Q_{\mathrm{reset}} \ge 2 F \, k_B T \ln 2$), the net cyclic heat is $Q_{\mathrm{closed}} = k_B T \ln 2 + Q_{\mathrm{overhead}} \ge k_B T \ln 2 > 0$.
     2. **Isotropic Werner State vs. Rank-2 Linear Conditional Entropy**: For an isotropic 2-qubit Werner state $\rho_W(F)$, $S(A \mid O)_{\mathrm{Werner}} < 0$ requires $F > F_* \approx 0.747614$ (at $F = 0.5$, $S(A \mid O)_{\mathrm{Werner}} \approx +0.541\text{ bits} > 0$), whereas the chat's linear formula $1 - 2F$ applies to a rank-2 Bell mixture.
     3. **$6.67 \times 10^7\times$ Numerical Audit of `lignolux_entropy_siphon_sim.py`**: In [`data/chats/_Quantum Processor and Soliton Discussions  .md`, lines 4480–4525](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L4480-L4525), the chat's own Python script (`T = 4.0 K`, `F = 0.99`, `n_ancillas = 2e8`, `qec_frequency = 1e8 Hz`) evaluates to **$P_{\mathrm{siphon}} = -7.50 \times 10^{-7}\text{ W} = -0.750\text{ }\mu\text{W}$** (and even at $1\text{ THz}$, $-7.50\text{ mW}$)—not the `-50 to -100 Watts` claimed in the chat prose!

---

## 1. Is There Grassmannian Geometry in Causal Relations?

Yes—causal relations exhibit **five distinct, mathematically exact Grassmannian structures** spanning classical structural causal models (SCMs), relativistic spacetime causality, and quantum causal processes:

```{mermaid}
flowchart TD
    subgraph DAG["1. Classical DAG & Plabic Causal Networks: Gr_>=0(k, n)"]
        Transfer["Nilpotent Direct-Effect Matrix W (W^(h+1) = 0)\nTotal Causal Transfer T = (I - W)^(-1) = I + W T\nGuarded Mediator Subdivision: w = s * (w/s)"]
        Trek["LGV & Trek Rule for k-Input -> k-Output Minors det T_{A,B}\n• Unconfounded Disjoint Paths: det T_{A,B} > 0 (Interior of Gr_>0(k,n))\n• Shared Confounder / Mediator Bottleneck (m < k): det T_{A,B} = 0\n  (Boundary Schubert / Positroid Cell: singleHubRepresentative_det = 0)"]
        DoCalc["Pearl's do(X := x) Intervention as Incoming-Edge Surgery\nC_obs = d + b (Direct + Backdoor Trek) -> C_do = d (Pure Causal Effect)"]
        Transfer --> Trek --> DoCalc
    end

    subgraph Lightcone["2. Relativistic & DDF Lightcone Causality: Gr_C(2,4)"]
        Cone["Penrose Klein Quadric & DDF Second-Sound Characteristic Cone\nM_cone = ddfThermalGr24Matrix(β, θ) with β = v / c\nPlücker Product |w_A^C|² |w_B^C|² = 1 - β²\n• Timelike Causal (|β| < 1): > 0\n• Null Horizon (|β| = 1): = 0\n• Spacelike Acausal (|β| > 1): < 0"]
    end

    subgraph QuantumCausal["3. Quantum Causal Models & Indefinite Causal Order"]
        Choi["Choi-Jamiołkowski Process Subspaces\nRank-k Quantum Instrument V: H_in -> H_out\nSubspace in Gr_C(k, d_in * d_out)\ndim_R Gr_C(4, 16) = 96 (Two-Qubit Unitary Channels)"]
        Switch["Quantum Switch (A ≺ B) + (B ≺ A) on Gr_C(2,4)\nE_+ = (1/4)||{U_A, U_B}ψ||² (Anticommutator)\nE_- = (1/4)||[U_B, U_A]ψ||² (Commutator)\nPlücker Ratio |w_B^C|² / |w_A^C|² = E_- / E_+"]
        MpembaProj["Strong Mpemba & Counterfactual Abduction\nOrthogonal Projection P_{⊥ v_2} onto Fast Liouvillian Subspace\n(a_{2,hot} = 0 in Gr_R(N-1, N))"]
        Choi --> Switch --> MpembaProj
    end

    DAG --> Lightcone --> QuantumCausal
```

### 1.1 Acyclic Structural Causal Networks, Trek / LGV Minors, and Pearl's `do(X)` Surgery (`Signals.Plabic` & `Signals.QuantumCausalInference`)

In Pearl's Structural Causal Models ([Pearl 2009](#pearl2009causality)) and Wright's path analysis on a finite Directed Acyclic Graph (DAG) with $V$ vertices and height bound $h$, let $W_{ij}$ be the direct causal effect of node $i$ on node $j$. Because the graph is acyclic, $W^{h+1} = 0$ (`WeightedAcyclicNetwork.nilpotent`), and the total causal effect matrix summing all directed causal paths of length $0 \le r \le h$ is:

$$
T = \sum_{r=0}^h W^r = (I - W)^{-1}, \qquad T = I + W T
\quad (\text{proved in } \texttt{WeightedAcyclicNetwork.transfer\_equation}).
$$

How does the Grassmannian $\mathrm{Gr}(k, n)$ enter?
- **The LGV / Trek Determinant Criterion for Causal Bottlenecks and Confounding ([Sullivant, Talaska, & Draisma 2010](#sullivant2010trek); [Lindström 1973](#lindstrom1973lgv); [Gessel & Viennot 1985](#gessel1985lgv))**:
  Given $k$ intervention/source variables $A = \{a_1, \dots, a_k\}$ and $k$ outcome variables $B = \{b_1, \dots, b_k\}$, the $k \times k$ submatrix $T_{A,B}$ is a Plücker coordinate of the $k$-plane spanned by the causal response vectors in $\mathrm{Gr}(k, V)$:
  1. **Unconfounded Vertex-Disjoint Causal Channels ($\det T_{A,B} > 0$)**: When $k$ causal pathways travel through $k$ independent, non-intersecting mediators (`planarThreeChannelLowerStep * planarThreeChannelUpperStep`), all $k!$ non-identity path permutations are blocked or positive, placing the causal system in the interior of the totally positive Grassmannian cell $\mathrm{Gr}_{>0}(k, n)$:

     $$
     \det\!\left(E_{\mathrm{lower}}^{(3)}(l_{10}, l_{21}) \, E_{\mathrm{upper}}^{(3)}(d_0, d_1, d_2, u_{01}, u_{12})\right) = d_0 d_1 d_2 > 0.
     $$

  2. **Shared Confounder / Mediator Bottleneck ($\det T_{A,B} = 0$ — d-Separation)**: If $k$ causes influence $k$ outcomes solely through $m < k$ intermediate mediators or a single common-cause confounder hub, the causal transfer matrix factors as $T_{A,B} = A_{k \times m} B_{m \times k}$ and its $k \times k$ Plücker minor vanishes identically:

     $$
     \det(\operatorname{singleHubRepresentative}(u, x, v, w_{\mathrm{out}})) = 0 \quad (k=2, m=1),
     \qquad
     \det(A_{3\times 2} B_{2\times 3}) = 0 \quad (k=3, m=2).
     $$

     Geometrically, **d-separation and unmeasured confounding correspond to degenerating from the open top cell $\mathrm{Gr}_{>0}(k, n)$ onto a lower-rank positroid / Schubert boundary stratum where $\Delta_I = 0$**!
- **Pearl's `do(X := x)` Intervention as Plabic Incoming-Edge Surgery (`causalObservationalTransfer`, `causalInterventionalDoTransfer`, `causal_dag_do_surgery_3x3`)**:
  Consider a 3-node confounded DAG with unobserved confounder $U$ (node $0$), treatment $X$ (node $1$), and outcome $Y$ (node $2$), with edge weights $w_{01} = w_{U \to X}$, $w_{02} = w_{U \to Y}$, and $w_{12} = w_{X \to Y} = d$:

  $$
  W_{\mathrm{obs}} = \begin{pmatrix} 0 & w_{01} & w_{02} \\ 0 & 0 & w_{12} \\ 0 & 0 & 0 \end{pmatrix}
  \implies
  T_{\mathrm{obs}} = I + W_{\mathrm{obs}} + W_{\mathrm{obs}}^2 = \begin{pmatrix} 1 & w_{01} & w_{02} + w_{01} w_{12} \\ 0 & 1 & w_{12} \\ 0 & 0 & 1 \end{pmatrix}.
  $$

  In observational data, the total association between $X$ and $Y$ is contaminated by the backdoor confounding trek $b = w_{U \to X} w_{U \to Y}$ (`causalObservationalTransfer d b = d + b`, matching `WeightedAcyclicNetwork.diamond_transfer`). Pearl's intervention $\operatorname{do}(X := x)$ performs **graph surgery** by zeroing column $1$ of $W$ ($w_{01} \mapsto 0$), yielding:

  $$
  W_{\mathrm{do}(X)} = \begin{pmatrix} 0 & 0 & w_{02} \\ 0 & 0 & w_{12} \\ 0 & 0 & 0 \end{pmatrix}
  \implies
  C_{\mathrm{do}} = d = w_{12}, \qquad
  C_{\mathrm{obs}} - C_{\mathrm{do}} = b.
  $$

### 1.2 Relativistic and DDF Lightcone Causality on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ (`causalLightconeInterval`)

In relativistic physics ([Penrose & Rindler 1986](#penrose1986spinors)) and our Dilatant Dark Fluid (`Signals.DDF`, [grassmannian-ddf-moving-sheath-paper.md](grassmannian-ddf-moving-sheath-paper.md)), complexified Minkowski spacetime is the Klein quadric of 2-planes in twistor space $\mathbb{C}^4$, i.e. $\mathrm{Gr}_{\mathbb{C}}(2,4)$. For a signal or thermal second-sound wave propagating at normalized velocity $\beta = v / c$, the $\mathrm{Gr}_{\mathbb{C}}(2,4)$ twistor matrix $M_{\mathrm{cone}} = \operatorname{ddfThermalGr24Matrix}(\beta, \theta)$ has complex Plücker channel amplitudes satisfying:

$$
\|w_A^{\mathbb{C}}(M_{\mathrm{cone}})\|^2 = 1 + \beta, \qquad
\|w_B^{\mathbb{C}}(M_{\mathrm{cone}})\|^2 = 1 - \beta, \qquad
\|w_A^{\mathbb{C}}(M_{\mathrm{cone}})\|^2 \, \|w_B^{\mathbb{C}}(M_{\mathrm{cone}})\|^2 = 1 - \beta^2 = \frac{d\tau^2}{dt^2}.
$$

Thus:
- **Timelike Causal Interior ($|\beta| < 1$)**: Both Plücker channel norms are strictly positive and $\|w_A^{\mathbb{C}}\|^2 \|w_B^{\mathbb{C}}\|^2 = 1 - \beta^2 > 0$.
- **Null Lightcone / Horizon Boundary ($|\beta| = 1$)**: One Plücker channel vanishes ($\|w_B^{\mathbb{C}}\|^2 = 0$), degenerating onto a rank-deficient boundary of the positive Grassmannian (`causalLightconeInterval 1 = 0`).
- **Spacelike Acausal Exterior ($|\beta| > 1$)**: The interval $1 - \beta^2 < 0$ flips sign, violating positivity.

---

## 2. Quantum Causal Models, Counterfactual Semantics (`arXiv:2302.11783`), and Indefinite Causal Order (`Quantum Switch`)

### 2.1 Quantum Causal Models and Giarmatzi–Costa Counterfactual Semantics (`arXiv:2302.11783`)

In classical Pearl SCMs ([Pearl 2009](#pearl2009causality)), a counterfactual query *"Given that we observed $(X = x_{\mathrm{obs}}, Y = y_{\mathrm{obs}})$, what would $Y$ have been had we intervened $\operatorname{do}(X := x_{\mathrm{cf}})$?"* (Rung 3 of Pearl's Ladder of Causation) is evaluated by the three-step **Abduction–Action–Prediction** algorithm:
1. **Abduction**: Update the distribution over the exogenous background variables $U_E$ from the factual evidence $(x_{\mathrm{obs}}, y_{\mathrm{obs}})$: for $Y = \alpha X + U_E$, $u_E = y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}}$ (`abducedExogenousState`).
2. **Action**: Replace the structural mechanism for $X$ by the intervention $\operatorname{do}(X := x_{\mathrm{cf}})$.
3. **Prediction**: Compute the counterfactual outcome in the modified model using the abduced $u_E$:

   $$
   Y_{x_{\mathrm{cf}}}(u_E) = \alpha x_{\mathrm{cf}} + (y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}}) = y_{\mathrm{obs}} + \alpha(x_{\mathrm{cf}} - x_{\mathrm{obs}}), \qquad
   \Delta Y_{\mathrm{cf}} = Y_{x_{\mathrm{cf}}} - Y_{x_{\mathrm{obs}}} = \alpha(x_{\mathrm{cf}} - x_{\mathrm{obs}}).
   $$

Why is extending counterfactuals to quantum mechanics subtle? By Bell's theorem and the Kochen–Specker theorem, quantum systems do not possess pre-existing deterministic values for unperformed measurements. In **Giarmatzi & Costa (2023)** ([`arXiv:2302.11783`](#giarmatzi2023semantics)) and **Allen, Barrett, Horsman, Lee, & Spekkens (2017)** ([Allen et al. 2017](#allen2017qcm)), a **Quantum Causal Model (QCM)** resolves this by shifting causal determinism from hidden outcome values to **unitary channels and purified exogenous environment ancillas**:
- Every quantum node $A$ is governed by a unitary interaction $U_A : \mathcal{H}_{A_{\mathrm{in}}} \otimes \mathcal{H}_{E_A} \to \mathcal{H}_{A_{\mathrm{out}}} \otimes \mathcal{H}_{F_A}$ with an exogenous auxiliary state $\rho_{E_A}$.
- Under the **Choi–Jamiołkowski isomorphism**, a rank-$k$ quantum instrument or isometric channel between $\mathcal{H}_{\mathrm{in}}$ ($\dim = d_{\mathrm{in}}$) and $\mathcal{H}_{\mathrm{out}}$ ($\dim = d_{\mathrm{out}}$) is a $k$-dimensional subspace in $\mathrm{Gr}_{\mathbb{C}}(k, d_{\mathrm{in}} d_{\mathrm{out}})$, whose real manifold dimension is (`quantumChoiGrassmannianRealDim`):

  $$
  \dim_{\mathbb{R}} \mathrm{Gr}_{\mathbb{C}}(k, d_{\mathrm{in}} d_{\mathrm{out}}) = 2 k (d_{\mathrm{in}} d_{\mathrm{out}} - k)
  \qquad (\dim_{\mathbb{R}} \mathrm{Gr}_{\mathbb{C}}(4, 16) = 96 \text{ for } k = d_{\mathrm{in}} = d_{\mathrm{out}} = 4).
  $$

- In a quantum counterfactual ([Giarmatzi & Costa 2023](#giarmatzi2023semantics)), **Abduction** projects the exogenous environment state $\rho_E$ onto the subspace compatible with the factual instrument outcome via a Grassmannian projector $P_E \in \mathrm{Gr}_{\mathbb{C}}(k_E, \dim \mathcal{H}_E)$, **Action** replaces the channel at node $X$ with a counterfactual intervention channel $\operatorname{do}(X := \mathcal{I}_{x_{\mathrm{cf}}})$, and **Prediction** contracts the updated exogenous state through the modified quantum comb / process matrix!

### 2.2 Indefinite Causal Order and the Quantum Switch on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ (`quantumSwitchCausalAsymmetry`, `evaluate_quantum_switch_2x2`)

In standard causal DAGs, either event $A$ precedes $B$ ($A \prec B$) or $B$ precedes $A$ ($B \prec A$). In quantum mechanics, **Oreshkov, Costa, & Brukner (2012)** ([Oreshkov et al. 2012](#oreshkov2012process)) and **Chiribella, D'Ariano, Perinotti, & Valiron (2013)** ([Chiribella et al. 2013](#chiribella2013switch)) showed that quantum operations $U_A, U_B$ can be placed in a coherent superposition of causal orders via the **Quantum Switch**:

$$
\mathcal{S}(U_A, U_B)\!\left(\frac{|0\rangle_c + |1\rangle_c}{\sqrt{2}} \otimes |\psi\rangle\right)
= \frac{1}{\sqrt{2}}|0\rangle_c (U_B U_A|\psi\rangle) + \frac{1}{\sqrt{2}}|1\rangle_c (U_A U_B|\psi\rangle)
= |+\rangle_c \frac{\{U_A, U_B\}}{2}|\psi\rangle + |-\rangle_c \frac{[U_B, U_A]}{2}|\psi\rangle.
$$

Measuring the control qubit in the $|\pm\rangle_c$ basis projects onto two orthogonal causal interference branches with probabilities:

$$
E_+ = \frac{1}{4}\bigl\|\{U_A, U_B\}|\psi\rangle\bigr\|^2, \qquad
E_- = \frac{1}{4}\bigl\|[U_B, U_A]|\psi\rangle\bigr\|^2, \qquad
E_+ + E_- = 1.
$$

In Theorem `grassmannian_causal_relations_do_calculus_and_quantum_switch_identities` ([`QuantumCausalInference.lean`](../src/signals/Signals/QuantumCausalInference.lean#L230-L395)) and `evaluate_quantum_switch_2x2` ([`quantum_causal_inference.rs`](../src/signals/numerical_adapter/src/quantum_causal_inference.rs#L130-L185)), we prove that encoding the causal-order asymmetry $\delta_{\mathrm{switch}} = \frac{E_+ - E_-}{E_+ + E_-}$ into the complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(2,4)$ twistor matrix $M_{\mathrm{sw}} = \operatorname{ddfThermalGr24Matrix}(\delta_{\mathrm{switch}}, \theta)$ yields:

$$
\|w_A^{\mathbb{C}}(M_{\mathrm{sw}})\|^2 = 1 + \delta_{\mathrm{switch}} = \frac{2 E_+}{E_+ + E_-}, \qquad
\|w_B^{\mathbb{C}}(M_{\mathrm{sw}})\|^2 = 1 - \delta_{\mathrm{switch}} = \frac{2 E_-}{E_+ + E_-}, \qquad
\frac{\|w_B^{\mathbb{C}}(M_{\mathrm{sw}})\|^2}{\|w_A^{\mathbb{C}}(M_{\mathrm{sw}})\|^2} = \frac{E_-}{E_+}.
$$

- **Compatible / Commuting Causal Operations ($[U_A, U_B] = 0$, e.g. $U_A = I, U_B = Z$)**: $E_- = 0, E_+ = 1 \implies \delta_{\mathrm{switch}} = +1$ and $\|w_B^{\mathbb{C}}\|^2 = 0$.
- **Anticommuting Pauli Operations ($\{U_A, U_B\} = 0$, e.g. $U_A = X, U_B = Z$)**: $E_+ = 0, E_- = 1 \implies \delta_{\mathrm{switch}} = -1$ and $\|w_A^{\mathbb{C}}\|^2 = 0$, providing a $100\%$ deterministic witness of indefinite causal order!

---

## 3. Review and Comparison of the Four Mpemba & Counterfactual Models (`_Mpemba Effect_ Landau vs. Quantum .md`)

In [`data/chats/_Mpemba Effect_ Landau vs. Quantum .md`](../data/chats/_Mpemba%20Effect_%20Landau%20vs.%20Quantum%20.md#L40-L495), four frameworks are compared for modeling non-equilibrium relaxation, the Mpemba effect, and counterfactual reasoning. Below is our formal mathematical synthesis and Lean 4 / Rust comparison across all four frameworks:

| Dimension | 1. Landau Free-Energy & Markovian Modes ([Holtzman & Raz 2022](#holtzman2022landau)) | 2. Quantum Resource Theory (QRT) of Athermality ([Summer et al. 2026](#summer2026resource)) | 3. Constructor Theory of Thermodynamics ([Deutsch & Marletto 2015](#marletto2015info); [CT FAQ Q3](#deutschmarletto2021constructor)) | 4. Quantum Causal Models (QCMs) ([Giarmatzi & Costa 2023](#giarmatzi2023semantics)) |
|---|---|---|---|---|
| **Fundamental Ontology** | Order-parameter landscape $F(\eta, T)$ & Fokker–Planck / Liouvillian eigenmodes $\{v_k\}$ | Density states $\rho$, Gibbs state $\gamma_\beta$, & Thermal Operations ($\mathcal{E}(\gamma_\beta) = \gamma_\beta$) | Substrate-independent **Tasks** $\mathcal{T} = \{i \to o\}$ & cyclic **Constructors** $C$ | Directed unitary networks $U_A$ / process matrices $W$ & purified exogenous ancillas $\rho_E$ |
| **Mathematical Representation of Free Energy / Resource** | Quartic Landau functional $F(\eta) = \frac{1}{2}a\eta^2 + \frac{1}{4}b\eta^4 - h\eta$; double-well minimum $F(\pm\sqrt{-a/b}) = -\frac{a^2}{4b} < 0$ (`landauFreeEnergy`) | Rényi / KL non-equilibrium free energy $\Delta F = k_B T \ln 2 \cdot D_{\mathrm{KL}}(\rho \| \gamma_\beta)$ & piecewise-linear Lorenz curve (`qrtNonEquilibriumFreeEnergy`, `thermo_majorization_dominates`) | Task thermodynamic surplus $\Sigma_{\mathrm{task}} = W_{\mathrm{sup}} + k_B T \ln 2\,(\Delta S_{\mathrm{sys}} + I_{\mathrm{side}}) \ge 0$ (`ConstructorTask.thermodynamicSurplus`) | Interventional causal capacity $\Delta\mathcal{Q}^* = \mathbb{E}[Q \mid \operatorname{do}(K=1)] - \mathbb{E}[Q \mid \operatorname{do}(K=0)]$ (`entropySiphonCounterfactualGain`) |
| **Mechanism of the Mpemba Effect** | **Slow-mode overlap suppression**: $\|a_2^{\mathrm{hot}}\| < \|a_2^{\mathrm{cold}}\|$ (Weak Mpemba) or $a_2^{\mathrm{hot}} = 0$ (Strong Mpemba exponential speedup at rate $\lambda_3 > \lambda_2$) | **Majorization / Resource Shortcut**: Hotter state (or state after unitary pre-rotation) thermo-majorizes $\gamma_\beta$ along a faster trajectory ($D_{\mathrm{siphon}} < D_{\mathrm{alone}}$) | **Task Possibility Asymmetry**: Task $\mathcal{T}_{\mathrm{cool}}(\tau)$ is possible ($\mathcal{T}^{\checkmark}$) from prepared hot/correlated state within time $\tau$, but impossible ($\mathcal{T}^{\times}$) from trapped cold state | **Causal Path Selection**: $\operatorname{do}(\text{Pre-Rotation / Entanglement})$ severs the slow metastable causal bottleneck (`singleHubRepresentative` $\to$ fast channel) |
| **Semantics of Counterfactuals** | **Alternative Trajectory**: Compare $p_{\mathrm{hot}}(t)$ vs. $p_{\mathrm{cold}}(t)$ on the same potential $F(\eta)$ (`mpembaTwoModeDistance`) | **State-Space Preorder**: $\rho \succ_{\mathrm{th}} \sigma$ checks whether transformation $\rho \to \sigma$ is permitted under Thermal Operations | **First-Class Primitive**: Physical laws are statements of which tasks are Possible ($\mathcal{T}^{\checkmark}$) vs. Impossible ($\mathcal{T}^{\times}$) (`ConstructorTask.isPossible`) | **Abduction–Action–Prediction**: Infer exogenous $\rho_E$ from observation, apply $\operatorname{do}(X := x_{\mathrm{cf}})$, and propagate forward (`counterfactualStructuralOutcome`) |
| **Grassmannian Realization in `Signals`** | Strong Mpemba $a_2^{\mathrm{hot}} = 0$ is an orthogonal projection $P_{\perp v_2}$ onto a codimension-1 subspace in $\mathrm{Gr}_{\mathbb{R}}(N-1, N)$ | Unitary pre-cooling rotates the eigenframe of $\rho_0$ on the complex flag / Grassmannian manifold $\mathrm{Gr}_{\mathbb{C}}(k, N)$ | Parallel/serial task composition corresponds to disjoint vs. serial Plabic network concatenation in `Signals.Plabic` | Choi subspaces in $\mathrm{Gr}_{\mathbb{C}}(k, d_{\mathrm{in}}d_{\mathrm{out}})$ and Quantum Switch Plücker ratios on $\mathrm{Gr}_{\mathbb{C}}(2,4)$ |

### 3.1 Strong Mpemba Crossing Proof (`mpembaTwoModeDistance`, `strong_mpemba_crossing_time`)

Consider a two-eigenmode relaxation process with slow decay rate $\lambda_2 > 0$ and fast decay rate $\lambda_3 > \lambda_2$, so that $w_2(t) = e^{-\lambda_2 t}$ and $w_3(t) = e^{-\lambda_3 t}$ satisfy $0 < w_3(t) < w_2(t) < 1$ for all $t > 0$. In `mpemba_constructor_theory_and_entropy_siphoning_identities` ([`QuantumCausalInference.lean`](../src/signals/Signals/QuantumCausalInference.lean#L430-L515)):
- Let the **cold state** have mode overlaps $(a_{2,\mathrm{cold}}, a_{3,\mathrm{cold}}) = (1, 1)$, and let the **hot state** be prepared in the **Strong Mpemba Grassmannian subspace** orthogonal to the slow mode, $(a_{2,\mathrm{hot}}, a_{3,\mathrm{hot}}) = (0, 4)$:
  - At $t = 0$ ($w_2 = w_3 = 1$), the hot state is twice as far from equilibrium as the cold state:

    $$
    D_{\mathrm{cold}}(0) = 1 \cdot 1 + 1 \cdot 1 = 2 \;<\; D_{\mathrm{hot}}(0) = 0 \cdot 1 + 4 \cdot 1 = 4.
    $$

  - At a later time $t > 0$ where $w_2(t) = 1/2$ and $w_3(t) = 1/16$ (for $\lambda_3 = 4\lambda_2$), the hot state has bypassed the slow bottleneck and overtaken the cold state:

    $$
    D_{\mathrm{hot}}(t) = 0 \cdot \frac{1}{2} + 4 \cdot \frac{1}{16} = \frac{1}{4} = \frac{4}{16}
    \;<\;
    D_{\mathrm{cold}}(t) = 1 \cdot \frac{1}{2} + 1 \cdot \frac{1}{16} = \frac{9}{16}.
    $$

  - More generally, for a pure slow-mode cold state $(a_{2,\mathrm{cold}}, 0)$ and Strong Mpemba hot state $(0, a_{3,\mathrm{hot}})$ with $a_{3,\mathrm{hot}} > a_{2,\mathrm{cold}} > 0$, the exact trajectory crossing $D_{\mathrm{hot}}(t_{\mathrm{cross}}) = D_{\mathrm{cold}}(t_{\mathrm{cross}})$ occurs at (`strongMpembaCrossingTime`, `strong_mpemba_crossing_time`):

    $$
    t_{\mathrm{cross}} = \frac{\ln(a_{3,\mathrm{hot}} / a_{2,\mathrm{cold}})}{\lambda_3 - \lambda_2} > 0.
    $$

---

## 4. Review, Critique, and Thermodynamic Audit of "Entropy Siphoning" (`del Rio et al. 2011` vs. Chat Claims)

### 4.1 What Is Mathematically and Physically True: Single-Shot Conditional Landauer Erasure ([del Rio et al. 2011](#delrio2011negative))

In classical thermodynamics, Landauer's principle ([Landauer 1961](#landauer1961irreversibility)) states that erasing 1 bit of information at temperature $T$ dissipates at least $+k_B T \ln 2$ of heat into the environment. In **del Rio, Åberg, Renner, Dahlsten, & Vedral (2011)** ([*Nature* 474, 61–63](#delrio2011negative)), this bound is generalized to the quantum regime where the system $A$ being erased is correlated or entangled with a quantum memory $O$ held by the observer:

$$
Q_{\mathrm{erasure}}(A \mid O) = k_B T \ln 2 \cdot S(A \mid O), \qquad S(A \mid O) = S(\rho_{AO}) - S(\rho_O).
$$

In `delRioConditionalLandauerHeat` ([`QuantumCausalInference.lean`](../src/signals/Signals/QuantumCausalInference.lean#L185-L225)), using the linear Bell-mixture parameterization $S_{\mathrm{lin}}(A \mid O) = 1 - 2F$ for Bell fidelity $F \in [0, 1]$, we prove the three canonical regimes and the counterfactual $\operatorname{do}(F)$ intervention gain:

1. **Control ($\operatorname{do}(F = 0)$, Unentangled Classical Bit)**: $S(A \mid O) = +1 \implies Q_{\mathrm{erasure}}(0) = +k_B T \ln 2 > 0$ (standard Landauer heating).
2. **Reversible Threshold ($F = 1/2$, Classical Correlation)**: $S(A \mid O) = 0 \implies Q_{\mathrm{erasure}}(1/2) = 0$ (zero-heat reversible reset).
3. **Maximal Quantum Entanglement ($\operatorname{do}(F = 1)$, Pure Bell Pair $|\Phi^+\rangle_{AO}$)**: $S(\rho_{AO}) = 0$ while $S(\rho_O) = 1$, so $S(A \mid O) = -1 < 0$ and:

   $$
   Q_{\mathrm{erasure}}(1) = -k_B T \ln 2 < 0, \qquad
   \mathcal{Q}^* = Q(\operatorname{do}(F = 1)) - Q(\operatorname{do}(F = 0)) = -2\,k_B T \ln 2 < 0.
   $$

   In Constructor Theory (`ConstructorTask` in [`QuantumCausalInference.lean`](../src/signals/Signals/QuantumCausalInference.lean#L150-L182)), zero-work 1-bit erasure ($\Delta S_{\mathrm{sys}} = -1, W_{\mathrm{supplied}} = 0$) is **impossible** with $I_{\mathrm{side}} = 0$ ($\Sigma_{\mathrm{task}} = -k_B T \ln 2 < 0$), becomes **reversibly possible** at $I_{\mathrm{side}} = 1$ ($\Sigma_{\mathrm{task}} = 0$), and achieves a **positive cooling surplus** at $I_{\mathrm{side}} = 2$ ($\Sigma_{\mathrm{task}} = +k_B T \ln 2 > 0$).

### 4.2 Three Critical Flaws in the Chat Corpus's "Entropy Siphoning" Claims (and Their Formal Resolution)

Following our research-evidence triage rules ([AGENTS.md](../AGENTS.md); [`docs/chat-physics-catalog.md`, lines 16, 137](chat-physics-catalog.md#L16)), we audit the chat claims in [`_Mpemba Effect_ Landau vs. Quantum .md`, lines 298–495](../data/chats/_Mpemba%20Effect_%20Landau%20vs.%20Quantum%20.md#L298-L495) and [`_Quantum Processor and Soliton Discussions  .md`, lines 4470–4700](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L4470-L4700):

1. **Critique 1 — Closed-Loop Second-Law Accounting (`closedLoopErasureAndMemoryResetHeat`)**:
   Negative conditional entropy $S(A \mid O) < 0$ is **not** a free perpetual-motion refrigerant: erasing $A$ consumes the entanglement between $A$ and $O$ and leaves the observer memory $O$ in a mixed state of entropy $\Delta S_O = +2F$ bits (for the linear model). To operate a continuous cyclic QEC loop, the memory $O$ must itself be reset (or fresh entanglement must be generated by external laser/microwave work $W_{\mathrm{pump}} \ge 2 F \, k_B T \ln 2 + Q_{\mathrm{overhead}}$). Summing the single-shot siphon heat and the memory reset cost gives:

   $$
   Q_{\mathrm{closed}}(F) = \underbrace{k_B T \ln 2 \cdot (1 - 2F)}_{Q_{\mathrm{erasure}}(A \mid O) \,<\, 0} + \underbrace{2F\,k_B T \ln 2 + Q_{\mathrm{overhead}}}_{Q_{\mathrm{reset}}(O) \,>\, 0} = k_B T \ln 2 + Q_{\mathrm{overhead}} \ge k_B T \ln 2 > 0.
   $$

   Thus, entangled erasure can **spatially relocate** heat away from the data qubits (if the ancilla/memory is physically transported or optically reset at a remote heat sink), but it **cannot** reduce the total closed-loop entropy production below Landauer's $+k_B T \ln 2$ per erased bit!
2. **Critique 2 — Isotropic 2-Qubit Werner State vs. Linearized Conditional Entropy (`exact_werner_conditional_entropy_bits`)**:
   In `lignolux_entropy_siphon_sim.py` (line 4504), the chat writes `heat_per_reset = k_B * T_ambient * np.log(2) * (1 - 2 * fidelity)` and claims that cooling begins whenever `fidelity > 0.5`. However, if hardware depolarizing noise produces an isotropic 2-qubit Werner state $\rho_W(F) = F|\Phi^+\rangle\langle\Phi^+| + \frac{1-F}{3}(I_4 - |\Phi^+\rangle\langle\Phi^+|)$, the exact conditional von Neumann entropy is:

   $$
   S(A \mid O)_{\mathrm{Werner}}(F) = -F\log_2 F - (1 - F)\log_2\!\left(\frac{1 - F}{3}\right) - 1.
   $$

   As verified in `exact_werner_conditional_entropy_bits` ([`quantum_causal_inference.rs`](../src/signals/numerical_adapter/src/quantum_causal_inference.rs#L390-L420)), at $F = 0.5$, $S(A \mid O)_{\mathrm{Werner}}(0.5) \approx +0.5409\text{ bits} > 0$ (heating!), and the true cooling threshold $S(A \mid O)_{\mathrm{Werner}}(F_*) = 0$ requires **$F > F_* \approx 0.747614$** ($74.76\%$ Bell fidelity).
3. **Critique 3 — $6.67 \times 10^7\times$ Numerical Error in `lignolux_entropy_siphon_sim.py` (`-0.750 μW` vs. `-50 to -100 Watts`)**:
   In [`data/chats/_Quantum Processor and Soliton Discussions  .md`, lines 4487–4525](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L4487-L4525), the chat specifies:
   - $k_B = 1.38 \times 10^{-23}\text{ J/K}$, $T_{\mathrm{ambient}} = 4.0\text{ K} \implies k_B T \ln 2 \approx 3.82617 \times 10^{-23}\text{ J}$,
   - $N_{\mathrm{ancillas}} = 2 \times 10^8$, $f_{\mathrm{QEC}} = 10^8\text{ Hz}$, and $F = 0.99 \implies 1 - 2F = -0.98$.
   Evaluating the chat's own line 4507 (`total_power_watts = heat_per_reset * n_ancillas * qec_frequency`) in Lean 4 (`lignoluxTapeSiphonPowerWatts`) and Rust (`lignolux_tape_siphon_power_watts`) yields:

   $$
   P_{\mathrm{siphon}}(4\text{ K}, 100\text{ MHz}) = (3.82617 \times 10^{-23}\text{ J}) \times (-0.98) \times (2 \times 10^{16}\text{ s}^{-1}) = -7.4993 \times 10^{-7}\text{ W} = -0.750\text{ }\mu\text{W},
   $$

   which is **$6.67 \times 10^7\times$ smaller** than the `-50 to -100 Watts` claimed in the chat prose at line 4520! Even if one replaced `qec_frequency = 1e8` by `clock_rate = 1e12` ($1\text{ THz}$), the ideal single-shot cooling power at $4\text{ K}$ would be $-7.50\text{ mW}$, still four orders of magnitude below $-50\text{ W}$. Accordingly, hardware claims of net QPU refrigeration are isolated in `QuantumCausalMpembaSynthesisContract` ([`Signals/Pending.lean`](../src/signals/Signals/Pending.lean#L5395-L5510)), which enforces closed-loop Second-Law accounting, unentangled $\operatorname{do}(F=0)$ control subtraction, and N-LIG TES bolometer calibration.

---

## 5. Evidence Triage Table (`research-evidence-triage`)

| Claim / Model Component | Source Citation | Evidence Status | Confidence | Owning Lean 4 / Rust Symbol | Missing Control / Next Check |
|---|---|---|---|---|---|
| **Plabic / LGV Causal Transfer & d-Separation Bottlenecks ($\det T_{A,B} = 0$ vs. $> 0$)** | [Sullivant et al. 2010](#sullivant2010trek); [Postnikov 2006](#postnikov2006plabic) | `scholarly theory` (verified math) | High | `grassmannian_causal_relations_do_calculus_and_quantum_switch_identities`, `causal_dag_do_surgery_3x3` | Apply to empirical multi-node sensor DAG covariance matrices |
| **Quantum Causal Counterfactuals (`Abduction–Action–Prediction`) & Quantum Switch on $\mathrm{Gr}_{\mathbb{C}}(2,4)$** | [`_Mpemba Effect_ Landau vs. Quantum .md`, lines 390–455](../data/chats/_Mpemba%20Effect_%20Landau%20vs.%20Quantum%20.md#L390-L455); [Giarmatzi & Costa 2023](#giarmatzi2023semantics); [Chiribella et al. 2013](#chiribella2013switch) | `scholarly theory` (verified math) | High | `counterfactualStructuralOutcome`, `quantumSwitchCausalAsymmetry`, `evaluate_quantum_switch_2x2` | Interferometric visibility calibration on photonic Quantum Switch bench |
| **Landau Quartic Potential & Strong Mpemba Slow-Mode Orthogonal Projection ($a_{2,\mathrm{hot}} = 0$)** | [`_Mpemba Effect_ Landau vs. Quantum .md`, lines 45–75, 240–272](../data/chats/_Mpemba%20Effect_%20Landau%20vs.%20Quantum%20.md#L45-L75); [Holtzman & Raz 2022](#holtzman2022landau) | `scholarly theory` (verified math) | High | `landauFreeEnergy`, `mpembaTwoModeDistance`, `strongMpembaCrossingTime` | Measure Liouvillian decay rates $\lambda_2, \lambda_3$ in target spin/phonon bath |
| **Quantum Resource Theory (QRT) Thermo-Majorization & Constructor Theory Task Algebra** | [`_Mpemba Effect_ Landau vs. Quantum .md`, lines 78–110, 355–435](../data/chats/_Mpemba%20Effect_%20Landau%20vs.%20Quantum%20.md#L78-L110); [Summer et al. 2026](#summer2026resource); [Marletto 2015](#marletto2015info) | `scholarly theory` (verified math) | High | `qrtNonEquilibriumFreeEnergy`, `ConstructorTask`, `thermo_majorization_dominates` | Tomographic state reconstruction of $\rho(t)$ relative to $\gamma_\beta$ |
| **Single-Shot Conditional Landauer Cooling ($S(A\mid O) < 0 \implies Q < 0$) vs. Closed-Loop Reset** | [`_Mpemba Effect_ Landau vs. Quantum .md`, lines 298–325, 440–480](../data/chats/_Mpemba%20Effect_%20Landau%20vs.%20Quantum%20.md#L298-L325); [del Rio et al. 2011](#delrio2011negative) | `scholarly theory` (single-shot) / `calibration-required` (cyclic) | High | `delRioConditionalLandauerHeat`, `closedLoopErasureAndMemoryResetHeat`, `exact_werner_conditional_entropy_bits` | Include ancilla memory reset heat $Q_{\mathrm{reset}}$ and Werner threshold $F_* \approx 0.748$ |
| **Lignolux Tape `-50 to -100 W` Entropy-Siphon Refrigeration Claim** | [`_Quantum Processor and Soliton Discussions  .md`, lines 4480–4525](../data/chats/_Quantum%20Processor%20and%20Soliton%20Discussions%20%20.md#L4480-L4525) | `unsupported` ($-0.750\text{ }\mu\text{W}$ formula mismatch; `Pending` contract only) | High (audit) | `lignoluxTapeSiphonPowerWatts`, `QuantumCausalMpembaSynthesisContract` (`Signals.Pending`) | Keep in `Signals.Pending`; require $\operatorname{do}(F=0)$ control subtraction & TES calibration |

---

## 6. Self-Contained Machine-Checked Lean 4 Verification Block

The following Lean 4 verification block compiles directly against `Signals` and `SignalsPending` (`cd src/signals && lake env lean`):

```lean
import Signals
import SignalsPending

namespace QuantumCausalInferenceMpembaPaperVerification

open Signals
open Signals.DDF
open Signals.Geometry
open Signals.Plabic
open Signals.QuantumCausalInference
open Signals.Pending

-- 1. Verification of Grassmannian causal transfer (W^3 = 0, T = 1 + W * T),
-- guarded mediator subdivision, shared-hub confounder bottleneck (det = 0),
-- 3-through-2 mediator bottleneck (det(A * B) = 0) vs. 3-channel disjoint positivity (det > 0),
-- Pearl's do(X) incoming-edge surgery, Gr_C(2,4) lightcone causality (1 - β² > 0),
-- Giarmatzi-Costa counterfactual abduction-action-prediction, and the Quantum Switch on Gr_C(2,4)
example (theta : ℝ) (A : Matrix (Fin 3) (Fin 2) ℝ) (B : Matrix (Fin 2) (Fin 3) ℝ) :
    let net := WeightedAcyclicNetwork.diamond (2 : NNReal) (3 : NNReal) (4 : NNReal) (5 : NNReal)
    let M_cone := ddfThermalGr24Matrix (3 / 5) theta
    let delta_sw := quantumSwitchCausalAsymmetry 3 1
    let M_sw := ddfThermalGr24Matrix delta_sw theta
    net.weight ^ 3 = 0 ∧
      net.transfer = 1 + net.weight * net.transfer ∧
      (WeightedAcyclicNetwork.twoEdgePath (2 : NNReal) ((6 : NNReal) / 2)).transfer 0 2 =
        (WeightedAcyclicNetwork.oneEdgePath (6 : NNReal)).transfer 0 1 ∧
      (singleHubRepresentative (2 : NNReal) (3 : NNReal) (4 : NNReal) (5 : NNReal)).mat.det = 0 ∧
      (A * B).det = 0 ∧
      0 < (planarThreeChannelLowerStep 1 1 1 5 7 *
        planarThreeChannelUpperStep 2 3 4 6 8).det ∧
      causalObservationalTransfer 5 2 = 5 + 2 ∧
      causalInterventionalDoTransfer 5 2 = 5 ∧
      causalConfoundingBias 5 2 = 2 ∧
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_cone) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_cone) ∧
      causalLightconeInterval 1 = 0 ∧
      counterfactualStructuralOutcome 2 3 10 3 = 10 ∧
      counterfactualInterventionalDifference 2 3 10 5 = 2 * (5 - 3) ∧
      Complex.normSq (complexPluckerSinkAmplitudeB M_sw) /
          Complex.normSq (complexPluckerSinkAmplitudeA M_sw) = (1 : ℝ) / 3 ∧
      quantumChoiGrassmannianRealDim 4 4 4 = 96 := by
  intro net M_cone delta_sw M_sw
  have hc := grassmannian_causal_relations_do_calculus_and_quantum_switch_identities
    net 6 2 2 3 4 5 (by norm_num) 2 3 4 6 8 5 7 (by norm_num) (by norm_num) (by norm_num)
    A B 5 2 2 3 10 5 (3 / 5) 3 1 theta
    (by norm_num [abs_of_pos]) (by norm_num) (by norm_num)
  exact ⟨hc.1, hc.2.1, hc.2.2.1, hc.2.2.2.1, hc.2.2.2.2.1, hc.2.2.2.2.2.1,
    hc.2.2.2.2.2.2.1, hc.2.2.2.2.2.2.2.1, hc.2.2.2.2.2.2.2.2.1,
    hc.2.2.2.2.2.2.2.2.2.2.1, hc.2.2.2.2.2.2.2.2.2.2.2.1,
    hc.2.2.2.2.2.2.2.2.2.2.2.2.1, hc.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    hc.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1, hc.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2⟩

-- 2. Verification of Landau double-well barrier, Strong Mpemba trajectory crossing,
-- QRT thermo-majorization shortcut, Constructor Theory task composition & side-information unlocking,
-- del Rio conditional Landauer cooling, Second-Law closed-loop reset, and Lignolux -0.750 μW audit
example (contract : QuantumCausalMpembaSynthesisContract) :
    let task_no_info : ConstructorTask := ⟨-1, 0, 0⟩
    let task_classical_info : ConstructorTask := ⟨-1, 0, 1⟩
    let task_quantum_entangled : ConstructorTask := ⟨-1, 0, 2⟩
    landauFreeEnergy 1 (-2) 2 0 < landauFreeEnergy 0 (-2) 2 0 ∧
      mpembaTwoModeDistance 1 1 1 1 < mpembaTwoModeDistance 0 4 1 1 ∧
      mpembaTwoModeDistance 0 4 (1 / 2) (1 / 16) <
        mpembaTwoModeDistance 1 1 (1 / 2) (1 / 16) ∧
      ¬task_no_info.isPossible 1 ∧
      task_classical_info.isPossible 1 ∧
      task_quantum_entangled.isPossible 1 ∧
      delRioConditionalLandauerHeat 1 0 = 1 ∧
      delRioConditionalLandauerHeat 1 (1 / 2) = 0 ∧
      delRioConditionalLandauerHeat 1 1 = -1 ∧
      entropySiphonCounterfactualGain 1 1 0 = -2 ∧
      (1 : ℝ) ≤ closedLoopErasureAndMemoryResetHeat 1 (99 / 100) (1 / 10) ∧
      |lignoluxTapeSiphonPowerWatts (3826e-26) (99 / 100) (2e8) (1e8)| < 1e-6 ∧
      66000000 * |lignoluxTapeSiphonPowerWatts (3826e-26) (99 / 100) (2e8) (1e8)| < 50 ∧
      contract.layerCode.topologicalDimension = 3 ∧
      delRioConditionalLandauerHeat contract.thermalScaleJoules contract.bellFidelity < 0 ∧
      contract.thermalScaleJoules ≤
        closedLoopErasureAndMemoryResetHeat
          contract.thermalScaleJoules contract.bellFidelity
          contract.opticalAndMemoryOverheadJoules := by
  intro task_no_info task_classical_info task_quantum_entangled
  let t0 : ConstructorTask := ⟨0, 0, 0⟩
  have ht0 : t0.isPossible 1 := by
    unfold ConstructorTask.isPossible ConstructorTask.thermodynamicSurplus
    norm_num [t0]
  have hm := mpemba_constructor_theory_and_entropy_siphoning_identities
    1 (-2) 2 1 4 1 (99 / 100) (1 / 10)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    t0 t0 ht0 ht0
  have hp := SignalsPending.quantum_causal_mpemba_and_entropy_siphon_bounds contract
  exact ⟨hm.2.2.1, hm.2.2.2.1, hm.2.2.2.2.1,
    hm.2.2.2.2.2.2.2.2.2.1, hm.2.2.2.2.2.2.2.2.2.2.2.1,
    hm.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    by unfold delRioConditionalLandauerHeat conditionalEntropyLinearBits; norm_num,
    hm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    by unfold delRioConditionalLandauerHeat conditionalEntropyLinearBits; norm_num,
    by unfold entropySiphonCounterfactualGain delRioConditionalLandauerHeat conditionalEntropyLinearBits; norm_num,
    hm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    hm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    hm.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2,
    hp.1, hp.2.2.2.1, hp.2.2.2.2.2.1⟩

end QuantumCausalInferenceMpembaPaperVerification
```

---

### Scholarly References

(holtzman2022landau)=
<a id="holtzman2022landau"></a>
1. Holtzman, R., & Raz, O. (2022). Landau theory for the Mpemba effect through phase transitions. *Communications Physics*, 5(1), 280. DOI: `10.1038/s42005-022-01063-2`. [https://doi.org/10.1038/s42005-022-01063-2](https://doi.org/10.1038/s42005-022-01063-2).

(summer2026resource)=
<a id="summer2026resource"></a>
2. Summer, A., Moroder, M., Bettmann, L. P., Turkeshi, X., Marvian, I., & Goold, J. (2026). Resource-Theoretical Unification of Mpemba Effects: Classical and Quantum. *Physical Review X*, 16, 011050. DOI: `10.1103/rbt4-psfd`. [https://doi.org/10.1103/rbt4-psfd](https://doi.org/10.1103/rbt4-psfd).

(giarmatzi2023semantics)=
<a id="giarmatzi2023semantics"></a>
3. Giarmatzi, C., & Costa, F. (2023). A Semantics for Counterfactuals in Quantum Causal Models. `arXiv:2302.11783`. [https://arxiv.org/abs/2302.11783](https://arxiv.org/abs/2302.11783).

(delrio2011negative)=
<a id="delrio2011negative"></a>
4. del Rio, L., Åberg, J., Renner, R., Dahlsten, O., & Vedral, V. (2011). The thermodynamic meaning of negative entropy. *Nature*, 474(7349), 61–63. DOI: `10.1038/nature10123`. [https://doi.org/10.1038/nature10123](https://doi.org/10.1038/nature10123).

(deutsch2013constructor)=
<a id="deutsch2013constructor"></a>
5. Deutsch, D. (2013). Constructor theory. *Synthese*, 190(18), 4331–4359. DOI: `10.1007/s11229-013-0279-z`.

(marletto2015info)=
<a id="marletto2015info"></a>
6. Deutsch, D., & Marletto, C. (2015). Constructor theory of information. *Proceedings of the Royal Society A*, 471(2174), 20140540. DOI: `10.1098/rspa.2014.0540`; and Marletto, C. (2016). Constructor Theory of Thermodynamics. `arXiv:1608.02625`.

(deutschmarletto2021constructor)=
<a id="deutschmarletto2021constructor"></a>
7. Deutsch, D., & Marletto, C. (2021). *Constructor Theory Frequently Asked Questions (Q3: How does Constructor Theory differ from the framework of Resource Theories?)*. [https://www.constructortheory.org/faqs/](https://www.constructortheory.org/faqs/).

(oreshkov2012process)=
<a id="oreshkov2012process"></a>
8. Oreshkov, O., Costa, F., & Brukner, Č. (2012). Quantum correlations with no causal order. *Nature Communications*, 3, 1092. DOI: `10.1038/ncomms2076`.

(chiribella2013switch)=
<a id="chiribella2013switch"></a>
9. Chiribella, G., D'Ariano, G. M., Perinotti, P., & Valiron, B. (2013). Quantum computations without definite causal structure. *Physical Review A*, 88(2), 022318. DOI: `10.1103/PhysRevA.88.022318`.

(allen2017qcm)=
<a id="allen2017qcm"></a>
10. Allen, J.-M. A., Barrett, J., Horsman, D. C., Lee, C. M., & Spekkens, R. W. (2017). Quantum Common Causes and Quantum Causal Models. *Physical Review X*, 7(3), 031021. DOI: `10.1103/PhysRevX.7.031021`.

(sullivant2010trek)=
<a id="sullivant2010trek"></a>
11. Sullivant, S., Talaska, K., & Draisma, J. (2010). Trek separation for Gaussian graphical models. *The Annals of Statistics*, 38(3), 1665–1685. DOI: `10.1214/09-AOS760`.

(pearl2009causality)=
<a id="pearl2009causality"></a>
12. Pearl, J. (2009). *Causality: Models, Reasoning, and Inference* (2nd ed.). Cambridge University Press. DOI: `10.1017/CBO9780511803161`.

(landauer1961irreversibility)=
<a id="landauer1961irreversibility"></a>
13. Landauer, R. (1961). Irreversibility and Heat Generation in the Computing Process. *IBM Journal of Research and Development*, 5(3), 183–191. DOI: `10.1147/rd.53.0183`.

(penrose1986spinors)=
<a id="penrose1986spinors"></a>
14. Penrose, R., & Rindler, W. (1986). *Spinors and Space-Time, Vol. 2: Spinor and Twistor Methods in Space-Time Geometry*. Cambridge University Press.

(postnikov2006plabic)=
<a id="postnikov2006plabic"></a>
15. Postnikov, A. (2006). Total positivity, Grassmannians, and networks. `arXiv:math/0609764`.

(lindstrom1973lgv)=
<a id="lindstrom1973lgv"></a>
16. Lindström, B. (1973). On the vector representations of induced matroids. *Bulletin of the London Mathematical Society*, 5(1), 85–90; and Gessel, I., & Viennot, G. (1985). Binomial determinants, paths, and hook length formulae. *Advances in Mathematics*, 58(3), 300–321.

(mpemba-chat2026)=
<a id="mpemba-chat2026"></a>
17. Provenance Chat Logs (2026). *Mpemba Effect: Landau vs. Quantum Resource Theory, Constructor Theory, Counterfactual Semantics in Quantum Causal Models, and Entropy Siphoning*. Local corpus: {download}`data/chats/_Mpemba Effect_ Landau vs. Quantum .md, lines 1–555 <../data/chats/_Mpemba Effect_ Landau vs. Quantum .md>` and {download}`data/chats/_Quantum Processor and Soliton Discussions  .md, lines 4470–4700 <../data/chats/_Quantum Processor and Soliton Discussions  .md>`.

```bibtex
@article{holtzman2022landau,
  title   = {Landau theory for the Mpemba effect through phase transitions},
  author  = {Holtzman, Roi and Raz, Oren},
  journal = {Communications Physics},
  volume  = {5},
  number  = {1},
  pages   = {280},
  year    = {2022},
  doi     = {10.1038/s42005-022-01063-2}
}

@article{summer2026resource,
  title   = {Resource-Theoretical Unification of Mpemba Effects: Classical and Quantum},
  author  = {Summer, Alessandro and Moroder, Mattia and Bettmann, Laetitia P. and Turkeshi, Xhek and Marvian, Iman and Goold, John},
  journal = {Physical Review X},
  volume  = {16},
  year    = {2026},
  doi     = {10.1103/rbt4-psfd}
}

@article{giarmatzi2023semantics,
  title   = {A Semantics for Counterfactuals in Quantum Causal Models},
  author  = {Giarmatzi, Christina and Costa, Fabio},
  journal = {arXiv preprint arXiv:2302.11783},
  year    = {2023},
  url     = {https://arxiv.org/abs/2302.11783}
}

@article{delrio2011negative,
  title   = {The thermodynamic meaning of negative entropy},
  author  = {del Rio, L{\'\i}dia and {\AA}berg, Johan and Renner, Renato and Dahlsten, Oscar and Vedral, Vlatko},
  journal = {Nature},
  volume  = {474},
  number  = {7349},
  pages   = {61--63},
  year    = {2011},
  doi     = {10.1038/nature10123}
}

@misc{chat_mpemba_landau_quantum_2026,
  author       = {{Google Gemini / User}},
  title        = {Mpemba Effect: Landau vs. Quantum, Constructor Theory, Counterfactuals in Quantum Causal Models, and Entropy Siphoning},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/_Mpemba Effect_ Landau vs. Quantum .md, lines 1--555; data/chats/_Quantum Processor and Soliton Discussions  .md, lines 4470--4700}
}
```

```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws in Lean 4 and Rust/WASM",
  "author": {
    "@type": "Person",
    "name": "Wes Turner"
  },
  "dateModified": "2026-11-03",
  "isBasedOn": [
    "data/chats/_Mpemba Effect_ Landau vs. Quantum .md",
    "data/chats/_Quantum Processor and Soliton Discussions  .md",
    "src/signals/Signals/QuantumCausalInference.lean",
    "src/signals/numerical_adapter/src/quantum_causal_inference.rs"
  ],
  "about": [
    "Grassmannian Geometry of Causal Networks and d-Separation",
    "Quantum Causal Models and Interventional Counterfactual Semantics",
    "Indefinite Causal Order and the Quantum Switch on Gr_C(2,4)",
    "Landau Free-Energy and Quantum Resource Theory Mpemba Effects",
    "Constructor Theory of Thermodynamics and Information",
    "Conditional Landauer Erasure and Entropy Siphoning Audit"
  ]
}
```
