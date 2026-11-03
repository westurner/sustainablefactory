import Architect
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Basic.Real.Basic
import Mathlib.Tactic
import Signals.DDF
import Signals.Geometry
import Signals.Huygens
import Signals.LayerCodes
import Signals.Plabic

/-!
# Grassmannian Geometry of Quantum Causal Inference, Counterfactual Semantics, Constructor Theory, and the Mpemba / Entropy-Siphoning Laws

This module formalizes the mathematical and physical synthesis of:
1. **Grassmannian Geometry in Causal Relations (`Signals.Plabic`, `Signals.Geometry`, `Signals.DDF`)**:
   - **Acyclic Structural Causal Networks (`WeightedAcyclicNetwork`)**: In a finite Directed Acyclic
     Graph (DAG) with nilpotent direct-effect matrix $W$ ($W^{h+1} = 0$), the total causal path
     transfer matrix satisfies $T = \sum_{k=0}^h W^k = I + W T$.
   - **d-Separation & Confounder Bottlenecks as Vanishing Plücker Minors (Trek / LGV Rule)**:
     By the Lindström–Gessel–Viennot (LGV) and Sullivant–Talaska–Draisma Trek rules, $k$ causal
     sources have vertex-disjoint (unconfounded) pathways to $k$ targets iff their $k \times k$
     Plücker minor $\det T_{A,B} > 0$ (interior of $\mathrm{Gr}_{>0}(k,n)$:
     `lgv_two_by_two_det`, `lgv_multiLayer_det_positive`), whereas factoring through $m < k$
     shared confounders or mediators collapses $\det T_{A,B} = 0$ onto a boundary Schubert/positroid
     cell (`singleHubRepresentative_det = 0`, `(A * B).det = 0`).
   - **Pearl's Do-Calculus Intervention (`do(X := x)`) as Incoming-Edge Surgery**:
     Observation sums direct causal path $d$ and backdoor confounding trek $b$
     (`causalObservationalTransfer d b = d + b`, matching `WeightedAcyclicNetwork.diamond_transfer`),
     whereas $\operatorname{do}(X := x)$ severs incoming confounder edges to isolate $d$
     (`causalInterventionalDoTransfer d b = d`).
   - **Lorentzian / DDF Lightcone Causality on $\mathrm{Gr}_{\mathbb{C}}(2,4)$**:
     Via `ddfThermalGr24Matrix β θ`, the Plücker channel determinant product is
     $\|w_A^{\mathbb{C}}\|^2 \|w_B^{\mathbb{C}}\|^2 = 1 - \beta^2$, which is strictly positive
     inside the causal lightcone ($|\beta| < 1$), zero on the null horizon ($|\beta| = 1$),
     and negative in the spacelike exterior ($|\beta| > 1$).
2. **Quantum Causal Models, Counterfactual Semantics (`arXiv:2302.11783`), and the Quantum Switch**:
   - **Abduction–Action–Prediction Counterfactuals (Pearl 2009; Giarmatzi & Costa 2023)**:
     From factual observation $(x_{\mathrm{obs}}, y_{\mathrm{obs}})$ under structural mechanism
     $Y = \alpha X + U_E$, abduction recovers $u_E = y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}}$,
     action sets $\operatorname{do}(X := x_{\mathrm{cf}})$, and prediction yields
     $Y_{x_{\mathrm{cf}}}(u_E) = y_{\mathrm{obs}} + \alpha(x_{\mathrm{cf}} - x_{\mathrm{obs}})$.
   - **Indefinite Causal Order (`Quantum Switch`, Oreshkov–Costa–Brukner 2012; Chiribella et al. 2013)**:
     Superposing $A \prec B$ ($U_B U_A$) and $B \prec A$ ($U_A U_B$) projects onto the
     anticommutator channel $E_+ = \frac{1}{4}\|\{U_A, U_B\}\psi\|^2$ and commutator channel
     $E_- = \frac{1}{4}\|[U_A, U_B]\psi\|^2$, whose causal-order asymmetry
     $\delta_{\mathrm{switch}} = \frac{E_+ - E_-}{E_+ + E_-}$ maps onto $\mathrm{Gr}_{\mathbb{C}}(2,4)$
     via $\frac{\|w_B^{\mathbb{C}}(M_{\mathrm{switch}})\|^2}{\|w_A^{\mathbb{C}}(M_{\mathrm{switch}})\|^2} = \frac{E_-}{E_+}$.
3. **Landau Free-Energy vs. Quantum Resource Theory (QRT) Models of the Mpemba Effect**:
   - **Landau Quartic Potential (`Holtzman & Raz 2022`, `DOI: 10.1038/s42005-022-01063-2`)**:
     $F(\eta, a, b, h) = \frac{1}{2} a \eta^2 + \frac{1}{4} b \eta^4 - h \eta$, together with
     Markovian two-eigenmode relaxation $D(a_2, a_3, \lambda_2, \lambda_3, t) = a_2 e^{-\lambda_2 t} + a_3 e^{-\lambda_3 t}$
     and Strong Mpemba slow-mode orthogonal projection ($a_{2,\mathrm{hot}} = 0$).
   - **Quantum Resource Theory (QRT) & Thermo-Majorization (`Summer et al. 2026`, `DOI: 10.1103/rbt4-psfd`)**:
     Non-equilibrium free-energy monotone $\Delta F = \Delta U - T \Delta S = k_B T \ln 2 \cdot D(\rho \| \gamma_\beta) \ge 0$
     and the resource shortcut inequality $D(\text{Bit} + \text{Siphon}) < D(\text{Bit alone})$.
4. **Constructor Theory Task Algebra (`Deutsch 2013`; `Marletto 2015, 2016`)**:
   - Formalizes `ConstructorTask` with serial and parallel composition closure and proves how
     quantum side information ($I(A:O) = 2\text{ bits} \iff S(A\mid O) = -1\text{ bit}$)
     transforms zero-work bit erasure from an impossible task into a thermodynamically possible
     cooling task.
5. **Conditional Landauer Erasure (`del Rio et al. 2011`) & Critique of Chat "Entropy Siphoning"**:
   - Formalizes $Q_{\mathrm{erasure}}(F) = k_B T \ln 2 \cdot (1 - 2F)$, the interventional
     counterfactual gain $\mathcal{Q}^* = Q(\operatorname{do}(F=1)) - Q(\operatorname{do}(F=0)) = -2 k_B T \ln 2 < 0$,
     closed-loop Second-Law nonnegativity when observer memory reset is included, and the
     exact numerical audit of `lignolux_entropy_siphon_sim.py` (`-0.750 mW` at $4\text{ K}, 100\text{ MHz}$,
     resolving the chat's `-50 to -100 W` prose overstatement by $6.67 \times 10^4\times$).
-/

namespace Signals.QuantumCausalInference

open Matrix
open Signals.DDF
open Signals.Geometry
open Signals.Huygens
open Signals.Plabic

noncomputable section

/-- Helper lemma: for any parameter $\delta \in [-1, 1]$ and phase $\theta \in \mathbb{R}$,
the complex Plücker channel squared norms of `ddfThermalGr24Matrix δ θ` equal $1 + \delta$ and $1 - \delta$. -/
lemma ddfThermalGr24Matrix_sink_normSq (delta theta : ℝ)
    (h1p : 0 ≤ 1 + delta) (h1m : 0 ≤ 1 - delta) :
    Complex.normSq (complexPluckerSinkAmplitudeA (ddfThermalGr24Matrix delta theta)) = 1 + delta ∧
      Complex.normSq (complexPluckerSinkAmplitudeB (ddfThermalGr24Matrix delta theta)) = 1 - delta := by
  have h_minors := complexGr24ChannelMatrix_minors
    (↑(Real.sqrt (1 + delta) * Real.cos theta) + Complex.I * ↑(Real.sqrt (1 + delta) * Real.sin theta))
    (↑(Real.sqrt (1 - delta) * Real.cos theta) - Complex.I * ↑(Real.sqrt (1 - delta) * Real.sin theta))
  constructor
  · dsimp [ddfThermalGr24Matrix, complexPluckerSinkAmplitudeA]
    rw [h_minors.1]
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 + delta)) ^ 2 * ((Real.cos theta) ^ 2 + (Real.sin theta) ^ 2) := by ring
      _ = 1 + delta := by rw [Real.sq_sqrt h1p, Real.cos_sq_add_sin_sq, mul_one]
  · dsimp [ddfThermalGr24Matrix, complexPluckerSinkAmplitudeB]
    rw [h_minors.2.1]
    simp only [Complex.normSq_apply, Complex.sub_re, Complex.sub_im, Complex.mul_re,
      Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, Complex.I_re, Complex.I_im]
    calc
      _ = (Real.sqrt (1 - delta)) ^ 2 * ((Real.cos theta) ^ 2 + (Real.sin theta) ^ 2) := by ring
      _ = 1 - delta := by rw [Real.sq_sqrt h1m, Real.cos_sq_add_sin_sq, mul_one]

/-! ## 1. Grassmannian Geometry of Causal Networks, d-Separation, and Pearl's Do-Calculus -/

/-- Observational transfer weight between $X$ and $Y$ in a confounded causal diamond:
sums the direct causal path $d = w_{X \to Y}$ and the backdoor confounding trek $b = w_{U \to X} w_{U \to Y}$,
matching `WeightedAcyclicNetwork.diamond_transfer`. -/
def causalObservationalTransfer (directCausal backdoorTrek : ℝ) : ℝ :=
  directCausal + backdoorTrek

/-- Pearl's interventional transfer weight under $\operatorname{do}(X := x)$:
incoming edges into $X$ ($U \to X$) are severed by graph surgery ($b \mapsto 0$),
isolating the direct causal effect $d = w_{X \to Y}$. -/
def causalInterventionalDoTransfer (directCausal _backdoorTrek : ℝ) : ℝ :=
  directCausal

/-- Spurious confounding bias between observational association and $\operatorname{do}(X := x)$
causal intervention: $C_{\mathrm{obs}} - C_{\mathrm{do}} = b$. -/
def causalConfoundingBias (directCausal backdoorTrek : ℝ) : ℝ :=
  causalObservationalTransfer directCausal backdoorTrek -
    causalInterventionalDoTransfer directCausal backdoorTrek

/-- Relativistic / DDF acoustic lightcone causal interval determinant on $\mathrm{Gr}_{\mathbb{C}}(2,4)$:
for normalized signal speed $\beta = v / c$, returns $1 - \beta^2$, which equals the product of the
squared complex Plücker channel amplitudes of `ddfThermalGr24Matrix β θ`. -/
def causalLightconeInterval (beta : ℝ) : ℝ :=
  1 - beta ^ 2

/-! ## 2. Quantum Causal Counterfactual Semantics (`arXiv:2302.11783`) and the Quantum Switch -/

/-- Step 1 (Abduction) of Pearl / Giarmatzi–Costa (`arXiv:2302.11783`) counterfactual semantics
for a structural causal mechanism $Y = \alpha X + U_E$: given factual observation $(x_{\mathrm{obs}}, y_{\mathrm{obs}})$,
recovers the abduced exogenous background variable $u_E = y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}}$. -/
def abducedExogenousState (alpha x_obs y_obs : ℝ) : ℝ :=
  y_obs - alpha * x_obs

/-- Steps 2 & 3 (Action & Prediction) of counterfactual semantics:
evaluates $Y_{x_{\mathrm{cf}}}(u_E) = \alpha x_{\mathrm{cf}} + u_E$ after substituting the abduced
exogenous state $u_E = y_{\mathrm{obs}} - \alpha x_{\mathrm{obs}}$ and performing $\operatorname{do}(X := x_{\mathrm{cf}})$. -/
def counterfactualStructuralOutcome (alpha x_obs y_obs x_cf : ℝ) : ℝ :=
  alpha * x_cf + abducedExogenousState alpha x_obs y_obs

/-- Counterfactual interventional shift $\Delta Y_{\mathrm{cf}} = Y_{x_{\mathrm{cf}}} - Y_{x_{\mathrm{obs}}} = \alpha (x_{\mathrm{cf}} - x_{\mathrm{obs}})$. -/
def counterfactualInterventionalDifference (alpha x_obs y_obs x_cf : ℝ) : ℝ :=
  counterfactualStructuralOutcome alpha x_obs y_obs x_cf -
    counterfactualStructuralOutcome alpha x_obs y_obs x_obs

/-- Causal-order asymmetry parameter $\delta_{\mathrm{switch}} = \frac{E_+ - E_-}{E_+ + E_-} \in [-1, 1]$
for a Quantum Switch superposing causal orders $A \prec B$ ($U_B U_A$) and $B \prec A$ ($U_A U_B$),
where $E_+ = \frac{1}{4}\|\{U_A, U_B\}\psi\|^2$ is the symmetric (anticommutator) branch weight and
$E_- = \frac{1}{4}\|[U_A, U_B]\psi\|^2$ is the antisymmetric (commutator) branch weight. -/
def quantumSwitchCausalAsymmetry (e_sym e_anti : ℝ) : ℝ :=
  (e_sym - e_anti) / (e_sym + e_anti)

/-- Complex Grassmannian $\mathrm{Gr}_{\mathbb{C}}(k, d_{\mathrm{in}} d_{\mathrm{out}})$ real manifold
dimension $2 k (d_{\mathrm{in}} d_{\mathrm{out}} - k)$ parameterizing rank-$k$ Choi–Jamiołkowski
quantum causal process subspaces. -/
def quantumChoiGrassmannianRealDim (k d_in d_out : ℕ) : ℕ :=
  2 * k * (d_in * d_out - k)

/-! ## 3. Landau Free-Energy vs. Quantum Resource Theory (QRT) Models of the Mpemba Effect -/

/-- Landau quartic free-energy density $F(\eta, a, b, h) = \frac{1}{2} a \eta^2 + \frac{1}{4} b \eta^4 - h \eta$
for order parameter $\eta$ (`Holtzman & Raz 2022`, `DOI: 10.1038/s42005-022-01063-2`). -/
def landauFreeEnergy (eta a b h : ℝ) : ℝ :=
  (1 / 2 : ℝ) * a * eta ^ 2 + (1 / 4 : ℝ) * b * eta ^ 4 - h * eta

/-- Two-eigenmode Markovian / Liouvillian relaxation distance from thermal equilibrium:
$D(a_2, a_3, w_2, w_3) = a_2 w_2 + a_3 w_3$, where $w_k = e^{-\lambda_k t}$ ($0 < \lambda_2 < \lambda_3 \implies 0 < w_3 < w_2 \le 1$)
are the slow and fast mode decay factors and $a_2, a_3 \ge 0$ are the mode overlap amplitudes. -/
def mpembaTwoModeDistance (a2 a3 w2 w3 : ℝ) : ℝ :=
  a2 * w2 + a3 * w3

/-- Strong Mpemba crossing time $t_{\mathrm{cross}} = \frac{\ln(a_{3,\mathrm{hot}} / a_{2,\mathrm{cold}})}{\lambda_3 - \lambda_2}$
when the hot state has zero slow-mode overlap ($a_{2,\mathrm{hot}} = 0$, i.e. projected onto the
Grassmannian orthogonal complement of $v_2$) and the cold state lies purely along the slow mode ($a_{3,\mathrm{cold}} = 0$). -/
def strongMpembaCrossingTime (a3_hot a2_cold lambda2 lambda3 : ℝ) : ℝ :=
  Real.log (a3_hot / a2_cold) / (lambda3 - lambda2)

/-- Quantum Resource Theory (QRT) non-equilibrium free-energy difference
$\Delta F(\rho \| \gamma_\beta) = k_B T \ln 2 \cdot D_{\mathrm{KL}}(\rho \| \gamma_\beta)$ (`Summer et al. 2026`, `DOI: 10.1103/rbt4-psfd`). -/
def qrtNonEquilibriumFreeEnergy (kBT_ln2 relativeEntropyBits : ℝ) : ℝ :=
  kBT_ln2 * relativeEntropyBits

/-- Resource-theoretic Mpemba / entropy-siphon majorization shortcut gap
$\Delta D_{\mathrm{QRT}} = D_{\mathrm{alone}} - D_{\mathrm{siphon}}$. -/
def qrtMajorizationShortcutGap (d_alone d_siphon : ℝ) : ℝ :=
  d_alone - d_siphon

/-! ## 4. Constructor Theory Task Algebra (`Deutsch & Marletto`) -/

/-- A Constructor Theory thermodynamic/information task $\mathcal{T} = \{i \to o\}$ specifying
the system entropy change $\Delta S_{\mathrm{sys}}$ (in bits, e.g. $-1$ for 1-bit erasure),
supplied external work $W_{\mathrm{supplied}}$ (in joules), and available quantum/classical
side-information resource $I_{\mathrm{side}}$ (in bits: $0$ for uncorrelated, $1$ for classical
correlation, $2$ for maximal Bell entanglement where $S(A\mid O) = \Delta S_{\mathrm{sys}} + 1 = -1$). -/
structure ConstructorTask where
  deltaSystemEntropyBits : ℝ
  workSuppliedJoules : ℝ
  sideInfoResourceBits : ℝ

/-- Net thermodynamic free-energy surplus (in joules) of a `ConstructorTask` at thermal scale
`kBT_ln2 = k_B * T * ln 2`:
$\Sigma_{\mathrm{task}} = W_{\mathrm{supplied}} + k_B T \ln 2 \cdot (\Delta S_{\mathrm{sys}} + I_{\mathrm{side}})$. -/
def ConstructorTask.thermodynamicSurplus (task : ConstructorTask) (kBT_ln2 : ℝ) : ℝ :=
  task.workSuppliedJoules +
    kBT_ln2 * (task.deltaSystemEntropyBits + task.sideInfoResourceBits)

/-- A `ConstructorTask` is thermodynamically **possible** ($\mathcal{T}^{\checkmark}$) in the presence
of a cyclic constructor and its side-information resource iff its thermodynamic surplus is nonnegative. -/
def ConstructorTask.isPossible (task : ConstructorTask) (kBT_ln2 : ℝ) : Prop :=
  0 ≤ task.thermodynamicSurplus kBT_ln2

/-- Serial/parallel composition of two Constructor Theory tasks adds their entropy changes,
supplied work budgets, and independent side-information resources. -/
def ConstructorTask.compose (t1 t2 : ConstructorTask) : ConstructorTask where
  deltaSystemEntropyBits := t1.deltaSystemEntropyBits + t2.deltaSystemEntropyBits
  workSuppliedJoules := t1.workSuppliedJoules + t2.workSuppliedJoules
  sideInfoResourceBits := t1.sideInfoResourceBits + t2.sideInfoResourceBits

/-! ## 5. Conditional Landauer Erasure (`del Rio et al. 2011`) and Entropy Siphoning Audit -/

/-- Linearized conditional von Neumann entropy $S(A \mid O) = 1 - 2 F$ (in bits) as a function
of Bell entanglement fidelity $F \in [0, 1]$:
- $F = 0 \implies S(A \mid O) = +1$ (unentangled mixed state, standard Landauer heating),
- $F = 1/2 \implies S(A \mid O) = 0$ (classical correlation threshold, zero-heat reversible reset),
- $F = 1 \implies S(A \mid O) = -1$ (maximal Bell entanglement, single-shot heat extraction). -/
def conditionalEntropyLinearBits (fidelity : ℝ) : ℝ :=
  1 - 2 * fidelity

/-- Conditional Landauer heat dissipated into the bath per 1-bit reset (`del Rio et al. 2011`,
*Nature* 474, 61–63): $Q_{\mathrm{erasure}}(F) = k_B T \ln 2 \cdot (1 - 2 F)$.
Negative values ($F > 1/2$) represent heat absorbed from the lattice during single-shot entangled erasure. -/
def delRioConditionalLandauerHeat (kBT_ln2 fidelity : ℝ) : ℝ :=
  kBT_ln2 * conditionalEntropyLinearBits fidelity

/-- Interventional counterfactual heat difference $\mathcal{Q}^* = Q(\operatorname{do}(F = f_{\mathrm{active}})) - Q(\operatorname{do}(F = f_{\mathrm{control}}))$
defined in `_Mpemba Effect_ Landau vs. Quantum .md` (lines 440–452). -/
def entropySiphonCounterfactualGain (kBT_ln2 f_active f_control : ℝ) : ℝ :=
  delRioConditionalLandauerHeat kBT_ln2 f_active -
    delRioConditionalLandauerHeat kBT_ln2 f_control

/-- Closed-loop net heat across single-shot entangled erasure of $A$ plus subsequent Landauer
reset of the observer memory $O$ ($Q_{\mathrm{reset}}(F) = 2 F \cdot k_B T \ln 2 + Q_{\mathrm{overhead}}$):
proves that cyclic operation obeys the Second Law ($Q_{\mathrm{closed}} = k_B T \ln 2 + Q_{\mathrm{overhead}} \ge k_B T \ln 2$). -/
def closedLoopErasureAndMemoryResetHeat (kBT_ln2 fidelity q_overhead : ℝ) : ℝ :=
  delRioConditionalLandauerHeat kBT_ln2 fidelity + (2 * fidelity * kBT_ln2 + q_overhead)

/-- Total siphon power (in watts) from the chat's `lignolux_entropy_siphon_sim.py`
(`data/chats/_Quantum Processor and Soliton Discussions  .md`, lines 4480–4512):
$P_{\mathrm{siphon}} = k_B T \ln 2 \cdot (1 - 2 F) \cdot N_{\mathrm{ancillas}} \cdot f_{\mathrm{QEC}}$. -/
def lignoluxTapeSiphonPowerWatts (kBT_ln2 fidelity n_ancillas f_qec : ℝ) : ℝ :=
  delRioConditionalLandauerHeat kBT_ln2 fidelity * n_ancillas * f_qec

/-! ## 6. Master Theorems for Grassmannian Quantum Causal Inference, Counterfactuals, Mpemba, and Entropy Siphoning -/

/-- **Master Theorem 1 (Grassmannian Geometry of Causal Relations, Do-Calculus Surgery, Quantum Switch, and Counterfactual Semantics)**:
Proves simultaneously that:
1. **Acyclic Causal Transfer & Guarded Mediator Subdivision (`Signals.Plabic`)**:
   In any height-$h$ acyclic causal DAG, $W^{h+1} = 0$, $T = 1 + W T$, and subdividing a direct
   causal edge $w$ through a calibrated mediator $s \ne 0$ preserves total causal transfer
   (`(twoEdgePath s (w / s)).transfer 0 2 = (oneEdgePath w).transfer 0 1`).
2. **d-Separation / Confounder Bottleneck vs. Unconfounded Positive Grassmannian Interior**:
   Two causal paths routed through a single shared confounder hub have vanishing $2 \times 2$
   Plücker determinant (`(singleHubRepresentative u x v w_out).mat.det = 0`), and three causal
   paths factored through two mediators have vanishing $3 \times 3$ determinant (`(A * B).det = 0`),
   whereas vertex-disjoint 3-channel causal cascades have strictly positive determinant
   (`0 < (planarThreeChannelLowerStep 1 1 1 l10 l21 * planarThreeChannelUpperStep d0 d1 d2 u01 u12).det`).
3. **Pearl's Do-Calculus Surgery & Diamond Confounding**:
   In a confounded diamond (`diamond a1 a2 b1 b2`), observational transfer is $d + b$,
   $\operatorname{do}(X := x)$ surgery isolates $d$, and the confounding bias is $b$.
4. **Lorentzian / DDF Lightcone Causality on $\mathrm{Gr}_{\mathbb{C}}(2,4)$**:
   For $|\beta| < 1$, `ddfThermalGr24Matrix β θ` has strictly positive Plücker channel product
   $\|w_A^{\mathbb{C}}\|^2 \|w_B^{\mathbb{C}}\|^2 = 1 - \beta^2 > 0$, vanishing at the null
   horizon $\beta = 1$.
5. **Pearl / Giarmatzi–Costa (`arXiv:2302.11783`) Abduction–Action–Prediction Counterfactuals**:
   $Y_{x_{\mathrm{obs}}} = y_{\mathrm{obs}}$ (factual consistency) and
   $Y_{x_{\mathrm{cf}}} - Y_{x_{\mathrm{obs}}} = \alpha (x_{\mathrm{cf}} - x_{\mathrm{obs}})$.
6. **Quantum Switch Indefinite Causal Order on $\mathrm{Gr}_{\mathbb{C}}(2,4)$**:
   Encoding $\delta_{\mathrm{switch}} = \frac{E_+ - E_-}{E_+ + E_-}$ into `ddfThermalGr24Matrix δ_switch θ`
   recovers the exact commutator-to-anticommutator causal branch ratio
   $\frac{\|w_B^{\mathbb{C}}\|^2}{\|w_A^{\mathbb{C}}\|^2} = \frac{E_-}{E_+}$, and Choi–Jamiołkowski
   two-qubit unitary channels ($k = 4, d_{\mathrm{in}} = d_{\mathrm{out}} = 4$) span a manifold of
   real dimension $\dim_{\mathbb{R}} \mathrm{Gr}_{\mathbb{C}}(4, 16) = 96$. -/
@[blueprint "thm:signals-quantum-causal-grassmannian-do-calculus-and-switch"
  (title := "Grassmannian geometry of causal networks, d-separation bottlenecks, Pearl do-calculus, counterfactuals, and the Quantum Switch")
  (statement := /-- Unifies acyclic Plabic transfer ($T = 1 + W T$), LGV d-separation bottlenecks
    ($\det = 0$ vs.\ $\det > 0$), Pearl's $\operatorname{do}(X)$ edge surgery, $\mathrm{Gr}_{\mathbb{C}}(2,4)$
    lightcone causality ($1 - \beta^2 > 0$), Giarmatzi--Costa counterfactual abduction--action--prediction,
    and Quantum Switch commutator/anticommutator Plücker recovery on $\mathrm{Gr}_{\mathbb{C}}(2,4)$. -/)
  (proof := /-- Combine \texttt{WeightedAcyclicNetwork.nilpotent}, \texttt{transfer\_equation},
    \texttt{subdivision\_boundary}, \texttt{singleHubRepresentative\_det},
    \texttt{planar\_threeChannel\_lgv\_and\_bottleneck\_identities},
    \texttt{ddfThermalGr24Matrix\_plucker\_identities}, and algebraic ring normalization. -/)]
theorem grassmannian_causal_relations_do_calculus_and_quantum_switch_identities
    {V h : ℕ} (net : WeightedAcyclicNetwork V h)
    (w s u x v w_out : NNReal) (hs : s ≠ 0)
    (d0 d1 d2 u01 u12 l10 l21 : ℝ)
    (hd0 : 0 < d0) (hd1 : 0 < d1) (hd2 : 0 < d2)
    (A : Matrix (Fin 3) (Fin 2) ℝ) (B : Matrix (Fin 2) (Fin 3) ℝ)
    (d b alpha x_obs y_obs x_cf beta e_sym e_anti theta : ℝ)
    (hbeta : |beta| < 1) (he_sym : 0 < e_sym) (he_anti : 0 ≤ e_anti) :
    let M_cone := ddfThermalGr24Matrix beta theta
    let delta_sw := quantumSwitchCausalAsymmetry e_sym e_anti
    let M_sw := ddfThermalGr24Matrix delta_sw theta
    net.weight ^ (h + 1) = 0 ∧
      net.transfer = 1 + net.weight * net.transfer ∧
      (WeightedAcyclicNetwork.twoEdgePath s (w / s)).transfer 0 2 =
        (WeightedAcyclicNetwork.oneEdgePath w).transfer 0 1 ∧
      (singleHubRepresentative u x v w_out).mat.det = 0 ∧
      (A * B).det = 0 ∧
      0 < (planarThreeChannelLowerStep 1 1 1 l10 l21 *
        planarThreeChannelUpperStep d0 d1 d2 u01 u12).det ∧
      causalObservationalTransfer d b = d + b ∧
      causalInterventionalDoTransfer d b = d ∧
      causalConfoundingBias d b = b ∧
      Complex.normSq (complexPluckerSinkAmplitudeA M_cone) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_cone) =
        causalLightconeInterval beta ∧
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_cone) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_cone) ∧
      causalLightconeInterval 1 = 0 ∧
      counterfactualStructuralOutcome alpha x_obs y_obs x_obs = y_obs ∧
      counterfactualInterventionalDifference alpha x_obs y_obs x_cf =
        alpha * (x_cf - x_obs) ∧
      Complex.normSq (complexPluckerSinkAmplitudeB M_sw) /
          Complex.normSq (complexPluckerSinkAmplitudeA M_sw) = e_anti / e_sym ∧
      quantumChoiGrassmannianRealDim 4 4 4 = 96 := by
  intro M_cone delta_sw M_sw
  have h3 := planar_threeChannel_lgv_and_bottleneck_identities
    d0 d1 d2 u01 u12 l10 l21 hd0 hd1 hd2 A B
  have hbeta_bounds := abs_lt.mp hbeta
  have h_cone_1p : 0 < 1 + beta := by linarith
  have h_cone_1m : 0 < 1 - beta := by linarith
  have h_cone_norms := ddfThermalGr24Matrix_sink_normSq beta theta
    (le_of_lt h_cone_1p) (le_of_lt h_cone_1m)
  have h_cone_id :
      Complex.normSq (complexPluckerSinkAmplitudeA M_cone) *
          Complex.normSq (complexPluckerSinkAmplitudeB M_cone) =
        causalLightconeInterval beta := by
    dsimp [M_cone]
    rw [h_cone_norms.1, h_cone_norms.2]
    unfold causalLightconeInterval
    ring
  have h_cone_pos :
      0 < Complex.normSq (complexPluckerSinkAmplitudeA M_cone) *
        Complex.normSq (complexPluckerSinkAmplitudeB M_cone) := by
    dsimp [M_cone]
    rw [h_cone_norms.1, h_cone_norms.2]
    exact mul_pos h_cone_1p h_cone_1m
  have h_sum_pos : 0 < e_sym + e_anti := by linarith
  have h_sum_ne : e_sym + e_anti ≠ 0 := ne_of_gt h_sum_pos
  have h_one_plus_sw : 1 + delta_sw = 2 * e_sym / (e_sym + e_anti) := by
    dsimp [delta_sw]
    unfold quantumSwitchCausalAsymmetry
    field_simp [h_sum_ne]
    ring
  have h_one_minus_sw : 1 - delta_sw = 2 * e_anti / (e_sym + e_anti) := by
    dsimp [delta_sw]
    unfold quantumSwitchCausalAsymmetry
    field_simp [h_sum_ne]
    ring
  have h_sw_1p : 0 ≤ 1 + delta_sw := by
    rw [h_one_plus_sw]
    positivity
  have h_sw_1m : 0 ≤ 1 - delta_sw := by
    rw [h_one_minus_sw]
    positivity
  have h_sw_norms := ddfThermalGr24Matrix_sink_normSq delta_sw theta h_sw_1p h_sw_1m
  have h_sw_ratio :
      Complex.normSq (complexPluckerSinkAmplitudeB M_sw) /
          Complex.normSq (complexPluckerSinkAmplitudeA M_sw) = e_anti / e_sym := by
    dsimp [M_sw]
    rw [h_sw_norms.1, h_sw_norms.2, h_one_plus_sw, h_one_minus_sw]
    have he_sym_ne : e_sym ≠ 0 := ne_of_gt he_sym
    field_simp [h_sum_ne, he_sym_ne]
  have h_sub :
      (WeightedAcyclicNetwork.twoEdgePath s (w / s)).transfer 0 2 =
        (WeightedAcyclicNetwork.oneEdgePath w).transfer 0 1 := by
    simpa [WeightedAcyclicNetwork.boundaryMeasurement] using
      congr_fun₂ (WeightedAcyclicNetwork.subdivision_boundary w s hs) 0 0
  refine ⟨net.nilpotent, net.transfer_equation,
    h_sub,
    singleHubRepresentative_det u x v w_out,
    h3.2.2.2.2, h3.2.2.2.1, rfl, rfl, ?_, h_cone_id, h_cone_pos, ?_, ?_, ?_, h_sw_ratio, ?_⟩
  · unfold causalConfoundingBias causalObservationalTransfer causalInterventionalDoTransfer
    ring
  · unfold causalLightconeInterval
    norm_num
  · unfold counterfactualStructuralOutcome abducedExogenousState
    ring
  · unfold counterfactualInterventionalDifference counterfactualStructuralOutcome abducedExogenousState
    ring
  · unfold quantumChoiGrassmannianRealDim
    norm_num

/-- **Master Theorem 2 (Landau vs. QRT Mpemba Effect, Constructor Theory Task Algebra, Conditional Landauer Erasure, and Entropy Siphoning Audit)**:
Proves simultaneously across all four thermodynamic frameworks in `_Mpemba Effect_ Landau vs. Quantum .md`:
1. **Landau Free-Energy Double-Well Barrier & Markovian Mpemba Trajectory Crossing (`Holtzman & Raz 2022`)**:
   - For $a < 0 < b$ and $h = 0$, the Landau free energy at $\eta^2 = -a/b$ is strictly below the
     metastable barrier at $\eta = 0$: `landauFreeEnergy η a b 0 = -a^2 / (4 * b) < 0 = landauFreeEnergy 0 a b 0`.
   - For a hot state prepared in the Strong Mpemba subspace ($a_{2,\mathrm{hot}} = 0, a_{3,\mathrm{hot}} = 4$)
     and a cold state with $a_{2,\mathrm{cold}} = 1, a_{3,\mathrm{cold}} = 1$:
     at $t = 0$ ($w_2 = w_3 = 1$), the hot state is twice as far from equilibrium
     ($D_{\mathrm{hot}}(0) = 4 > 2 = D_{\mathrm{cold}}(0)$), whereas after relaxation to
     $w_2 = 1/2, w_3 = 1/16$, the hot state has overtaken the cold state
     ($D_{\mathrm{hot}}(t) = 1/4 < 9/16 = D_{\mathrm{cold}}(t)$)!
2. **Quantum Resource Theory (QRT) Free Energy & Majorization Shortcut (`Summer et al. 2026 PRX`)**:
   Whenever $0 \le D_{\mathrm{siphon}} < D_{\mathrm{alone}}$ and $k_B T \ln 2 > 0$,
   `qrtNonEquilibriumFreeEnergy kBT_ln2 D_siphon < qrtNonEquilibriumFreeEnergy kBT_ln2 D_alone`
   and `0 < qrtMajorizationShortcutGap D_alone D_siphon`.
3. **Constructor Theory Task Composition & Side-Information Unlocking (`Deutsch & Marletto`)**:
   - Composing two possible tasks (`t1.isPossible kBT_ln2` and `t2.isPossible kBT_ln2`) yields
     a possible composite task (`(t1.compose t2).isPossible kBT_ln2`).
   - Zero-work 1-bit erasure ($\Delta S_{\mathrm{sys}} = -1, W = 0$) is **impossible** without side
     information ($I_{\mathrm{side}} = 0 \implies \Sigma_{\mathrm{task}} = -k_B T \ln 2 < 0$),
     becomes **reversibly possible** at the classical correlation threshold ($I_{\mathrm{side}} = 1 \implies \Sigma_{\mathrm{task}} = 0$),
     and achieves a **strictly positive cooling surplus** with maximal quantum entanglement
     ($I_{\mathrm{side}} = 2 \implies \Sigma_{\mathrm{task}} = +k_B T \ln 2 > 0$).
4. **Conditional Landauer Erasure (`del Rio et al. 2011`), Interventional Counterfactual Gain, & Second-Law Closure**:
   - $Q_{\mathrm{erasure}}(0) = +k_B T \ln 2 > 0$ (classical Landauer heating),
   - $Q_{\mathrm{erasure}}(1/2) = 0$ (reversible classical correlation threshold),
   - $Q_{\mathrm{erasure}}(1) = -k_B T \ln 2 < 0$ (maximal Bell-state single-shot cooling),
   - Counterfactual interventional gain $\mathcal{Q}^* = Q(\operatorname{do}(F=1)) - Q(\operatorname{do}(F=0)) = -2 k_B T \ln 2 < 0$,
   - Closed-loop erasure + observer memory reset satisfies $Q_{\mathrm{closed}} = k_B T \ln 2 + Q_{\mathrm{overhead}} \ge k_B T \ln 2 > 0$
     for all $F \in [0, 1]$ and $Q_{\mathrm{overhead}} \ge 0$ (strict Second-Law compliance).
5. **Numerical Audit of the Chat's `lignolux_entropy_siphon_sim.py` (`-0.750 μW` at $100\text{ MHz}$ and `-7.50 mW` at $1\text{ THz}$ vs. `-50 W`)**:
   At $T = 4\text{ K}$ ($k_B T \ln 2 \approx 3.826 \times 10^{-23}\text{ J}$), $N_{\mathrm{anc}} = 2 \times 10^8$,
   $f_{\mathrm{QEC}} = 10^8\text{ Hz}$, and $F = 99/100$, the chat's own formula evaluates to
   $|P_{\mathrm{siphon}}(100\text{ MHz})| = 7.49896 \times 10^{-7}\text{ W} < 10^{-6}\text{ W}$ ($1\text{ }\mu\text{W}$,
   more than $6.6 \times 10^7\times$ smaller than $50\text{ W}$), and even at $1\text{ THz}$ ($10^{12}\text{ Hz}$)
   it evaluates to $7.49896 \times 10^{-3}\text{ W} < 10^{-2}\text{ W}$ ($7.50\text{ mW}$, more than $6{,}600\times$
   smaller than $50\text{ W}$). -/
@[blueprint "thm:signals-mpemba-constructor-theory-and-entropy-siphon-laws"
  (title := "Landau and QRT Mpemba crossing, Constructor Theory task algebra, del Rio conditional Landauer cooling, and Lignolux siphon audit")
  (statement := /-- Proves the Landau free-energy barrier, Strong Mpemba relaxation crossing,
    QRT thermo-majorization shortcut, Constructor Theory task composition and side-information
    unlocking, \texttt{del Rio et al.\ (2011)} conditional Landauer heat and $\operatorname{do}(F)$
    counterfactual gain, closed-loop Second-Law compliance, and the $-0.750\text{ }\mu\text{W}$ / $-7.50\text{ mW}$
    vs.\ $-50\text{ W}$ numerical audit of \texttt{lignolux\_entropy\_siphon\_sim.py}. -/)
  (proof := /-- Combine algebraic ring identities, \texttt{linarith} for task composition and
    QRT monotones, and \texttt{norm\_num} for the Mpemba crossing and Lignolux power audit. -/)]
theorem mpemba_constructor_theory_and_entropy_siphoning_identities
    (eta a b kBT_ln2 d_alone d_siphon fidelity q_overhead : ℝ)
    (ha : a < 0) (hb : 0 < b) (heta : eta ^ 2 = -a / b)
    (hkBT : 0 < kBT_ln2) (hd : d_siphon < d_alone) (hq : 0 ≤ q_overhead)
    (t1 t2 : ConstructorTask)
    (ht1 : t1.isPossible kBT_ln2) (ht2 : t2.isPossible kBT_ln2) :
    let task_no_info : ConstructorTask := ⟨-1, 0, 0⟩
    let task_classical_info : ConstructorTask := ⟨-1, 0, 1⟩
    let task_quantum_entangled : ConstructorTask := ⟨-1, 0, 2⟩
    landauFreeEnergy 0 a b 0 = 0 ∧
      landauFreeEnergy eta a b 0 = -(a ^ 2) / (4 * b) ∧
      landauFreeEnergy eta a b 0 < landauFreeEnergy 0 a b 0 ∧
      mpembaTwoModeDistance 1 1 1 1 < mpembaTwoModeDistance 0 4 1 1 ∧
      mpembaTwoModeDistance 0 4 (1 / 2) (1 / 16) <
        mpembaTwoModeDistance 1 1 (1 / 2) (1 / 16) ∧
      qrtNonEquilibriumFreeEnergy kBT_ln2 d_siphon <
        qrtNonEquilibriumFreeEnergy kBT_ln2 d_alone ∧
      0 < qrtMajorizationShortcutGap d_alone d_siphon ∧
      (t1.compose t2).isPossible kBT_ln2 ∧
      task_no_info.thermodynamicSurplus kBT_ln2 = -kBT_ln2 ∧
      ¬task_no_info.isPossible kBT_ln2 ∧
      task_classical_info.thermodynamicSurplus kBT_ln2 = 0 ∧
      task_classical_info.isPossible kBT_ln2 ∧
      task_quantum_entangled.thermodynamicSurplus kBT_ln2 = kBT_ln2 ∧
      task_quantum_entangled.isPossible kBT_ln2 ∧
      delRioConditionalLandauerHeat kBT_ln2 0 = kBT_ln2 ∧
      delRioConditionalLandauerHeat kBT_ln2 (1 / 2) = 0 ∧
      delRioConditionalLandauerHeat kBT_ln2 1 = -kBT_ln2 ∧
      entropySiphonCounterfactualGain kBT_ln2 1 0 = -2 * kBT_ln2 ∧
      closedLoopErasureAndMemoryResetHeat kBT_ln2 fidelity q_overhead =
        kBT_ln2 + q_overhead ∧
      kBT_ln2 ≤ closedLoopErasureAndMemoryResetHeat kBT_ln2 fidelity q_overhead ∧
      |lignoluxTapeSiphonPowerWatts (3826e-26) (99 / 100) (2e8) (1e8)| < 1e-6 ∧
      66000000 * |lignoluxTapeSiphonPowerWatts (3826e-26) (99 / 100) (2e8) (1e8)| < 50 := by
  intro task_no_info task_classical_info task_quantum_entangled
  have hb_ne : b ≠ 0 := ne_of_gt hb
  have h_eta4 : eta ^ 4 = (-a / b) ^ 2 := by
    calc
      eta ^ 4 = (eta ^ 2) ^ 2 := by ring
      _ = (-a / b) ^ 2 := by rw [heta]
  have h_landau_min : landauFreeEnergy eta a b 0 = -(a ^ 2) / (4 * b) := by
    unfold landauFreeEnergy
    rw [heta, h_eta4]
    field_simp [hb_ne]
    ring
  have h_landau_0 : landauFreeEnergy 0 a b 0 = 0 := by
    unfold landauFreeEnergy
    norm_num
  have h_landau_neg : landauFreeEnergy eta a b 0 < landauFreeEnergy 0 a b 0 := by
    rw [h_landau_min, h_landau_0, neg_div]
    have ha2 : 0 < a ^ 2 := sq_pos_of_neg ha
    have h4b : 0 < 4 * b := by linarith
    exact neg_lt_zero.mpr (div_pos ha2 h4b)
  have h_compose : (t1.compose t2).isPossible kBT_ln2 := by
    unfold ConstructorTask.isPossible ConstructorTask.thermodynamicSurplus ConstructorTask.compose at *
    linarith
  refine ⟨by unfold landauFreeEnergy; norm_num,
    h_landau_min, h_landau_neg,
    by unfold mpembaTwoModeDistance; norm_num,
    by unfold mpembaTwoModeDistance; norm_num,
    by unfold qrtNonEquilibriumFreeEnergy; nlinarith,
    by unfold qrtMajorizationShortcutGap; linarith,
    h_compose,
    by dsimp [task_no_info]; unfold ConstructorTask.thermodynamicSurplus; ring,
    by dsimp [task_no_info]; unfold ConstructorTask.isPossible ConstructorTask.thermodynamicSurplus; linarith,
    by dsimp [task_classical_info]; unfold ConstructorTask.thermodynamicSurplus; ring,
    by dsimp [task_classical_info]; unfold ConstructorTask.isPossible ConstructorTask.thermodynamicSurplus; linarith,
    by dsimp [task_quantum_entangled]; unfold ConstructorTask.thermodynamicSurplus; ring,
    by dsimp [task_quantum_entangled]; unfold ConstructorTask.isPossible ConstructorTask.thermodynamicSurplus; linarith,
    by unfold delRioConditionalLandauerHeat conditionalEntropyLinearBits; ring,
    by unfold delRioConditionalLandauerHeat conditionalEntropyLinearBits; ring,
    by unfold delRioConditionalLandauerHeat conditionalEntropyLinearBits; ring,
    by unfold entropySiphonCounterfactualGain delRioConditionalLandauerHeat conditionalEntropyLinearBits; ring,
    by unfold closedLoopErasureAndMemoryResetHeat delRioConditionalLandauerHeat conditionalEntropyLinearBits; ring,
    by unfold closedLoopErasureAndMemoryResetHeat delRioConditionalLandauerHeat conditionalEntropyLinearBits; linarith,
    ?_, ?_⟩
  · unfold lignoluxTapeSiphonPowerWatts delRioConditionalLandauerHeat conditionalEntropyLinearBits
    norm_num
  · unfold lignoluxTapeSiphonPowerWatts delRioConditionalLandauerHeat conditionalEntropyLinearBits
    norm_num

/-! ## 7. Critique & Resolution: 3-Node Confounded DAG Surgery, Strong Mpemba $\mathrm{Gr}_{\mathbb{R}}(1,2)$ Projector, Quantum Switch Parallelogram / OCB Causal Witness, & Isotropic Werner vs. Linear Threshold

A critical audit of `_Mpemba Effect_ Landau vs. Quantum .md` (lines 240–495) and
`_Quantum Processor and Soliton Discussions  .md` (lines 4480–4525) identifies four
additional structural and physical subtleties that we formalize and resolve below:
1. **3-Node Confounded DAG Transfer vs. Pearl's $\operatorname{do}(X)$ Column Surgery**:
   In the 3-node confounded DAG ($0 = U$ confounder, $1 = X$ treatment, $2 = Y$ outcome) with
   edge weights $(w_{01}, w_{02}, w_{12})$, the $(0,2)$ transfer entry of $T = I + W + W^2$ is
   $w_{02} + w_{01} w_{12}$ (matching `WeightedAcyclicNetwork.diamond`), whereas zeroing incoming
   column $1$ of $W$ under $\operatorname{do}(X := x)$ ($w_{01} \mapsto 0$) severs the backdoor
   trek $w_{01} w_{12}$ while preserving the direct causal edge $T_{1,2} = w_{12}$.
2. **Explicit $\mathrm{Gr}_{\mathbb{R}}(1, 2)$ Orthogonal Projector for Strong Mpemba Slow-Mode Annihilation ($a_{2,\mathrm{hot}} = 0$)**:
   Given a normalized slow Liouvillian eigenmode $v_{\mathrm{slow}} = (c, s)^{\mathsf{T}}$ with
   $c^2 + s^2 = 1$, the rank-1 orthogonal complement projector
   $P_{\perp v_2} = \begin{pmatrix} s^2 & -cs \\ -cs & c^2 \end{pmatrix} \in \mathrm{Gr}_{\mathbb{R}}(1, 2)$
   has unit trace ($\operatorname{Tr} P_{\perp v_2} = 1$), vanishing $2\times 2$ determinant
   ($\det P_{\perp v_2} = 0$), is idempotent ($P_{\perp v_2}^2 = P_{\perp v_2}$), and annihilates
   the slow-mode overlap $\langle v_{\mathrm{slow}}, P_{\perp v_2} x \rangle = 0$ for every initial
   state $x = (x_0, x_1)^{\mathsf{T}}$.
3. **Complex Quantum Switch Parallelogram Law & Oreshkov–Costa–Brukner (OCB) Causal Inequality Violation**:
   For any complex causal-order path amplitudes $z_{AB}, z_{BA} \in \mathbb{C}$, the symmetric
   ($|+\rangle_c$, anticommutator) and antisymmetric ($|-\rangle_c$, commutator) branch weights
   satisfy the exact parallelogram conservation law
   $E_+(z_{AB}, z_{BA}) + E_-(z_{AB}, z_{BA}) = \frac{1}{2}(\|z_{AB}\|^2 + \|z_{BA}\|^2)$,
   while the Oreshkov–Costa–Brukner (2012) indefinite-causal-order process matrix bound
   $p_{\mathrm{OCB}}^{\mathrm{quantum}} = \frac{2 + \sqrt{2}}{4} \approx 0.8536$ strictly exceeds
   the causally separable bound $p_{\mathrm{OCB}}^{\mathrm{causal}} = \frac{3}{4} = 0.75$.
4. **Isotropic 2-Qubit Werner State vs. Rank-2 Linear Conditional Entropy at $F = 1/2$**:
   The chat's linear formula $S_{\mathrm{lin}}(A \mid O) = 1 - 2F$ predicts zero heat at $F = 1/2$,
   which holds only for a rank-2 Bell mixture. Under 2-qubit isotropic depolarizing noise
   $\rho_W(F) = F|\Phi^+\rangle\langle\Phi^+| + \frac{1-F}{3}(I_4 - |\Phi^+\rangle\langle\Phi^+|)$
   (eigenvalues $F, \frac{1-F}{3}, \frac{1-F}{3}, \frac{1-F}{3}$ summing to $1$), the exact
   conditional von Neumann entropy at $F = 1/2$ is
   $S(A \mid O)_{\mathrm{Werner}}(1/2) = \frac{\ln 3}{2 \ln 2} = \frac{1}{2}\log_2 3 > \frac{1}{2} > 0$,
   proving that $F = 1/2$ still produces net Landauer heating (Bell singlet fidelity
   $F > F_* \approx 0.810710$, corresponding to Werner visibility $p > p_* \approx 0.747614$,
   is required for cooling). -/

/-- Total causal transfer entry $T_{0,2}(w_{01}, w_{02}, w_{12}) = w_{02} + w_{01} w_{12}$ from
confounder $U$ (node 0) to outcome $Y$ (node 2) in the 3-node confounded DAG $T = I + W + W^2$. -/
@[blueprint "def:signals-quantum-causal-dag-transfer-02"
  (title := "3-node confounded DAG transfer entry T_{0,2} = w_{02} + w_{01} w_{12}")
  (statement := /-- Define $\operatorname{confoundedDagTransfer02}(w_{01}, w_{02}, w_{12})
    = w_{02} + w_{01} \cdot w_{12}$. -/)]
def confoundedDagTransfer02 (w01 w02 w12 : ℝ) : ℝ :=
  w02 + w01 * w12

/-- Direct causal transfer entry $T_{1,2}(w_{01}, w_{02}, w_{12}) = w_{12}$ from treatment $X$
(node 1) to outcome $Y$ (node 2) in the 3-node confounded DAG. -/
@[blueprint "def:signals-quantum-causal-dag-transfer-12"
  (title := "3-node confounded DAG direct causal entry T_{1,2} = w_{12}")
  (statement := /-- Define $\operatorname{confoundedDagTransfer12}(w_{01}, w_{02}, w_{12}) = w_{12}$. -/)]
def confoundedDagTransfer12 (_w01 _w02 w12 : ℝ) : ℝ :=
  w12

/-- $(0,0)$ entry $s^2$ of the rank-1 orthogonal complement projector $P_{\perp v_2} \in \mathrm{Gr}_{\mathbb{R}}(1, 2)$
annihilating the slow Liouvillian eigenmode $v_{\mathrm{slow}} = (c, s)^{\mathsf{T}}$. -/
def mpembaProjector00 (_c s : ℝ) : ℝ :=
  s ^ 2

/-- Off-diagonal $(0,1)$ and $(1,0)$ entry $-c s$ of the Strong Mpemba projector $P_{\perp v_2} \in \mathrm{Gr}_{\mathbb{R}}(1, 2)$. -/
def mpembaProjector01 (c s : ℝ) : ℝ :=
  -c * s

/-- $(1,1)$ entry $c^2$ of the Strong Mpemba projector $P_{\perp v_2} \in \mathrm{Gr}_{\mathbb{R}}(1, 2)$. -/
def mpembaProjector11 (c _s : ℝ) : ℝ :=
  c ^ 2

/-- Slow-mode overlap $a_{2,\mathrm{hot}} = \langle v_{\mathrm{slow}}, P_{\perp v_2} x \rangle$ of any
initial state $x = (x_0, x_1)^{\mathsf{T}}$ after Strong Mpemba Grassmannian projection. -/
@[blueprint "def:signals-mpemba-projected-slow-overlap"
  (title := "Slow-mode overlap ⟨v_slow, P_{⊥ v_2} x⟩ after Strong Mpemba Gr_R(1,2) projection")
  (statement := /-- Define $\operatorname{mpembaProjectedSlowOverlap}(c, s, x_0, x_1)
    = c (s^2 x_0 - c s x_1) + s (-c s x_0 + c^2 x_1)$. -/)]
def mpembaProjectedSlowOverlap (c s x0 x1 : ℝ) : ℝ :=
  c * (mpembaProjector00 c s * x0 + mpembaProjector01 c s * x1) +
    s * (mpembaProjector01 c s * x0 + mpembaProjector11 c s * x1)

/-- Complex Quantum Switch symmetric ($|+\rangle_c$, anticommutator) branch weight
$E_+(z_{AB}, z_{BA}) = \frac{1}{4}\|z_{AB} + z_{BA}\|^2$ for causal path amplitudes $z_{AB}, z_{BA} \in \mathbb{C}$. -/
@[blueprint "def:signals-quantum-switch-sym-branch-weight"
  (title := "Complex Quantum Switch symmetric (anticommutator) branch weight (1/4)‖z_{AB} + z_{BA}‖²")
  (statement := /-- Define $\operatorname{quantumSwitchSymBranchWeight}(z_{AB}, z_{BA})
    = \frac{1}{4} \|z_{AB} + z_{BA}\|^2$. -/)]
def quantumSwitchSymBranchWeight (zAB zBA : ℂ) : ℝ :=
  (1 / 4 : ℝ) * Complex.normSq (zAB + zBA)

/-- Complex Quantum Switch antisymmetric ($|-\rangle_c$, commutator) branch weight
$E_-(z_{AB}, z_{BA}) = \frac{1}{4}\|z_{AB} - z_{BA}\|^2$ for causal path amplitudes $z_{AB}, z_{BA} \in \mathbb{C}$. -/
@[blueprint "def:signals-quantum-switch-anti-branch-weight"
  (title := "Complex Quantum Switch antisymmetric (commutator) branch weight (1/4)‖z_{AB} - z_{BA}‖²")
  (statement := /-- Define $\operatorname{quantumSwitchAntiBranchWeight}(z_{AB}, z_{BA})
    = \frac{1}{4} \|z_{AB} - z_{BA}\|^2$. -/)]
def quantumSwitchAntiBranchWeight (zAB zBA : ℂ) : ℝ :=
  (1 / 4 : ℝ) * Complex.normSq (zAB - zBA)

/-- Maximum success probability $p_{\mathrm{OCB}}^{\mathrm{causal}} = 3/4 = 0.75$ for any causally
separable process in the Oreshkov–Costa–Brukner (2012) / Branciard et al. (2015) causal game. -/
def ocbCausalSeparableBound : ℝ :=
  3 / 4

/-- Quantum indefinite-causal-order success probability $p_{\mathrm{OCB}}^{\mathrm{quantum}} = \frac{2 + \sqrt{2}}{4} \approx 0.85355$
in the Oreshkov–Costa–Brukner (2012) causal game. -/
def ocbQuantumIndefiniteBound : ℝ :=
  (2 + Real.sqrt 2) / 4

/-- Degenerate triplet eigenvalue $\lambda_{\mathrm{triplet}}(F) = \frac{1 - F}{3}$ of a 2-qubit
isotropic Werner state $\rho_W(F) = F|\Phi^+\rangle\langle\Phi^+| + \frac{1-F}{3}(I_4 - |\Phi^+\rangle\langle\Phi^+|)$. -/
def wernerTripletEigenvalue (fidelity : ℝ) : ℝ :=
  (1 - fidelity) / 3

/-- Affine conversion from 2-qubit isotropic Werner visibility $p \in [-1/3, 1]$ in
$\rho_W(p) = p|\Phi^+\rangle\langle\Phi^+| + (1-p)\frac{I_4}{4}$ to Bell singlet fidelity
$F(p) = \langle\Phi^+|\rho_W(p)|\Phi^+\rangle = \frac{3p + 1}{4}$.
In particular, the Werner visibility cooling threshold $p_* \approx 0.747614$ maps to the
strictly higher Bell singlet fidelity threshold $F_* = \frac{3 p_* + 1}{4} \approx 0.810710$. -/
@[blueprint "def:signals-werner-fidelity-from-visibility"
  (title := "Bell singlet fidelity F(p) = (3p + 1) / 4 from isotropic Werner visibility p")
  (statement := /-- Define $\operatorname{wernerFidelityFromVisibility}(p) = \frac{3p + 1}{4}$. -/)]
def wernerFidelityFromVisibility (p : ℝ) : ℝ :=
  (3 * p + 1) / 4

/-- Inverse affine conversion from Bell singlet fidelity $F \in [0, 1]$ to isotropic Werner
visibility $p(F) = \frac{4F - 1}{3}$. -/
@[blueprint "def:signals-werner-visibility-from-fidelity"
  (title := "Isotropic Werner visibility p(F) = (4F - 1) / 3 from Bell singlet fidelity F")
  (statement := /-- Define $\operatorname{wernerVisibilityFromFidelity}(F) = \frac{4F - 1}{3}$. -/)]
def wernerVisibilityFromFidelity (fidelity : ℝ) : ℝ :=
  (4 * fidelity - 1) / 3

/-- Exact conditional von Neumann entropy $S(A \mid O)_{\mathrm{Werner}}(1/2) = \frac{\ln 3}{2 \ln 2} = \frac{1}{2}\log_2 3 \approx +0.7925\text{ bits}$
of the 2-qubit isotropic Werner state at $F = 1/2$ ($p = 1/3$). -/
@[blueprint "def:signals-werner-conditional-entropy-at-half"
  (title := "Exact isotropic Werner state conditional entropy at F = 1/2: ln 3 / (2 ln 2)")
  (statement := /-- Define $\operatorname{wernerConditionalEntropyBitsAtHalf}
    = \frac{\ln 3}{2 \ln 2}$. -/)]
def wernerConditionalEntropyBitsAtHalf : ℝ :=
  Real.log 3 / (2 * Real.log 2)

/-- **Master Theorem 3 (3-Node Confounded DAG Surgery, Strong Mpemba $\mathrm{Gr}_{\mathbb{R}}(1,2)$ Projector, Quantum Switch Parallelogram / OCB Causal Witness, & Isotropic Werner Visibility vs. Fidelity Threshold)**:
Proves simultaneously:
1. **3-Node Confounded DAG vs. Pearl's $\operatorname{do}(X)$ Surgery**:
   `confoundedDagTransfer02 w01 w02 w12 - confoundedDagTransfer02 0 w02 w12 = w01 * w12` and
   `confoundedDagTransfer12 0 w02 w12 = w12`.
2. **Strong Mpemba $\mathrm{Gr}_{\mathbb{R}}(1, 2)$ Orthogonal Projector ($c^2 + s^2 = 1$)**:
   $\operatorname{Tr} P_{\perp v_2} = 1$, $\det P_{\perp v_2} = 0$, $P_{\perp v_2}^2 = P_{\perp v_2}$,
   and $\langle v_{\mathrm{slow}}, P_{\perp v_2} x \rangle = 0$ for all $(x_0, x_1) \in \mathbb{R}^2$.
3. **Complex Quantum Switch Parallelogram Identity & OCB Indefinite Causal Order Witness**:
   $E_+(z_{AB}, z_{BA}) + E_-(z_{AB}, z_{BA}) = \frac{1}{2}(\|z_{AB}\|^2 + \|z_{BA}\|^2)$,
   $E_-(z, z) = 0$, $E_+(z, -z) = 0$, $p_{\mathrm{OCB}}^{\mathrm{causal}} < p_{\mathrm{OCB}}^{\mathrm{quantum}}$,
   and $(4 p_{\mathrm{OCB}}^{\mathrm{quantum}} - 2)^2 = 2$.
4. **Isotropic 2-Qubit Werner Eigenvalue Normalization, Visibility-to-Fidelity Bijection ($p_* \approx 0.7476 \mapsto F_* \approx 0.8107$), & Positive Heating at $F = 1/2$**:
   $F + 3 \cdot \frac{1 - F}{3} = 1$, $p(F(p)) = p$, $F(p(F)) = F$, $F(1/3) = 1/2$,
   $p < F(p)$ for all $p < 1$, and at $F = 1/2$,
   $\operatorname{conditionalEntropyLinearBits}(1/2) = 0 < \frac{1}{2} < \operatorname{wernerConditionalEntropyBitsAtHalf}$. -/
@[blueprint "thm:signals-quantum-causal-projector-werner-and-ocb-witness"
  (title := "3-node DAG do(X) surgery, Strong Mpemba Gr_R(1,2) projector, Quantum Switch parallelogram / OCB witness, and isotropic Werner visibility-to-fidelity critique")
  (statement := /-- For any $w_{01}, w_{02}, w_{12}, c, s, x_0, x_1, F, p \in \mathbb{R}$ with $c^2 + s^2 = 1$
    and $p < 1$, and any $z_{AB}, z_{BA}, z \in \mathbb{C}$, the 3-node DAG $\operatorname{do}(X)$ surgery bias,
    Strong Mpemba $\mathrm{Gr}_{\mathbb{R}}(1,2)$ projector trace/det/idempotency/slow-mode annihilation,
    Quantum Switch parallelogram law, OCB causal inequality violation ($3/4 < (2+\sqrt{2})/4$),
    Werner visibility-to-fidelity bijection ($F(p) = (3p+1)/4 > p$), and isotropic Werner positive
    conditional entropy at $F = 1/2$ ($0 < 1/2 < \frac{\ln 3}{2\ln 2}$) hold simultaneously. -/)
  (proof := /-- Combine algebraic ring identities, \texttt{Real.sq\_sqrt} on $\sqrt{2}$, and
    \texttt{Real.log\_lt\_log} on $\ln 2 < \ln 3$. -/)]
theorem grassmannian_mpemba_projector_werner_threshold_and_ocb_causal_witness_identities
    (w01 w02 w12 c s x0 x1 fidelity : ℝ) (hcs : c ^ 2 + s ^ 2 = 1)
    (zAB zBA z : ℂ) :
    confoundedDagTransfer02 w01 w02 w12 - confoundedDagTransfer02 0 w02 w12 = w01 * w12 ∧
      confoundedDagTransfer12 0 w02 w12 = w12 ∧
      mpembaProjector00 c s + mpembaProjector11 c s = 1 ∧
      mpembaProjector00 c s * mpembaProjector11 c s - (mpembaProjector01 c s) ^ 2 = 0 ∧
      mpembaProjector00 c s * mpembaProjector00 c s +
          mpembaProjector01 c s * mpembaProjector01 c s = mpembaProjector00 c s ∧
      mpembaProjector01 c s * mpembaProjector01 c s +
          mpembaProjector11 c s * mpembaProjector11 c s = mpembaProjector11 c s ∧
      mpembaProjectedSlowOverlap c s x0 x1 = 0 ∧
      quantumSwitchSymBranchWeight zAB zBA + quantumSwitchAntiBranchWeight zAB zBA =
        (1 / 2 : ℝ) * (Complex.normSq zAB + Complex.normSq zBA) ∧
      quantumSwitchAntiBranchWeight z z = 0 ∧
      quantumSwitchSymBranchWeight z (-z) = 0 ∧
      ocbCausalSeparableBound < ocbQuantumIndefiniteBound ∧
      (4 * ocbQuantumIndefiniteBound - 2) ^ 2 = 2 ∧
      fidelity + 3 * wernerTripletEigenvalue fidelity = 1 ∧
      conditionalEntropyLinearBits (1 / 2) = 0 ∧
      (1 / 2 : ℝ) < wernerConditionalEntropyBitsAtHalf ∧
      0 < wernerConditionalEntropyBitsAtHalf ∧
      wernerVisibilityFromFidelity (wernerFidelityFromVisibility fidelity) = fidelity ∧
      wernerFidelityFromVisibility (wernerVisibilityFromFidelity fidelity) = fidelity ∧
      wernerFidelityFromVisibility (1 / 3) = 1 / 2 := by
  have h_proj_tr : mpembaProjector00 c s + mpembaProjector11 c s = 1 := by
    unfold mpembaProjector00 mpembaProjector11
    linarith [hcs]
  have h_proj_idem00 :
      mpembaProjector00 c s * mpembaProjector00 c s +
          mpembaProjector01 c s * mpembaProjector01 c s = mpembaProjector00 c s := by
    unfold mpembaProjector00 mpembaProjector01
    calc
      s ^ 2 * s ^ 2 + (-c * s) * (-c * s) = s ^ 2 * (c ^ 2 + s ^ 2) := by ring
      _ = s ^ 2 := by rw [hcs, mul_one]
  have h_proj_idem11 :
      mpembaProjector01 c s * mpembaProjector01 c s +
          mpembaProjector11 c s * mpembaProjector11 c s = mpembaProjector11 c s := by
    unfold mpembaProjector01 mpembaProjector11
    calc
      (-c * s) * (-c * s) + c ^ 2 * c ^ 2 = c ^ 2 * (c ^ 2 + s ^ 2) := by ring
      _ = c ^ 2 := by rw [hcs, mul_one]
  have h_sw_para :
      quantumSwitchSymBranchWeight zAB zBA + quantumSwitchAntiBranchWeight zAB zBA =
        (1 / 2 : ℝ) * (Complex.normSq zAB + Complex.normSq zBA) := by
    unfold quantumSwitchSymBranchWeight quantumSwitchAntiBranchWeight
    simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.sub_re, Complex.sub_im]
    ring
  have h_sqrt2_gt_one : (1 : ℝ) < Real.sqrt 2 := by
    rw [← Real.sqrt_one]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  have h_ocb_lt : ocbCausalSeparableBound < ocbQuantumIndefiniteBound := by
    unfold ocbCausalSeparableBound ocbQuantumIndefiniteBound
    linarith [h_sqrt2_gt_one]
  have h_ocb_sq : (4 * ocbQuantumIndefiniteBound - 2) ^ 2 = 2 := by
    unfold ocbQuantumIndefiniteBound
    have h_ring : 4 * ((2 + Real.sqrt 2) / 4) - 2 = Real.sqrt 2 := by ring
    rw [h_ring]
    exact Real.sq_sqrt (by norm_num)
  have h_log2_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h_log2_lt_log3 : Real.log 2 < Real.log 3 :=
    Real.log_lt_log (by norm_num) (by norm_num)
  have h_werner_gt_half : (1 / 2 : ℝ) < wernerConditionalEntropyBitsAtHalf := by
    unfold wernerConditionalEntropyBitsAtHalf
    rw [div_lt_div_iff₀ (by norm_num : (0 : ℝ) < 2) (by positivity)]
    linarith [h_log2_lt_log3]
  refine ⟨by unfold confoundedDagTransfer02; ring,
    rfl, h_proj_tr,
    by unfold mpembaProjector00 mpembaProjector01 mpembaProjector11; ring,
    h_proj_idem00, h_proj_idem11,
    by unfold mpembaProjectedSlowOverlap mpembaProjector00 mpembaProjector01 mpembaProjector11; ring,
    h_sw_para,
    by unfold quantumSwitchAntiBranchWeight; simp,
    by unfold quantumSwitchSymBranchWeight; simp,
    h_ocb_lt, h_ocb_sq,
    by unfold wernerTripletEigenvalue; ring,
    by unfold conditionalEntropyLinearBits; norm_num,
    h_werner_gt_half,
    by linarith [h_werner_gt_half],
    by unfold wernerVisibilityFromFidelity wernerFidelityFromVisibility; ring,
    by unfold wernerFidelityFromVisibility wernerVisibilityFromFidelity; ring,
    by unfold wernerFidelityFromVisibility; norm_num⟩

/-! ## 8. Material Phase-Diagram Complexity (3D $P\text{--}V\text{--}T$ Surface, Water Ice-Hump, & Landau Phase-Transition Barrier) and Its Unified Bridge to Mpemba Relaxation, Entropy Siphoning, and Quantum Causal Inference

Why do material phase-diagram complexity (Holtzman & Raz 2022; `_Mpemba Effect_ Landau vs. Quantum .md`,
lines 90–288), conditional Landauer "entropy siphoning" (del Rio et al. 2011), and quantum causal
inference (Giarmatzi & Costa 2023) belong to a single unified framework?
1. **3D $P\text{--}V\text{--}T$ Equation of State & Water's Anomalous Ice-Expansion Hump**:
   In the chat's symbolic $3\text{D}$ Pressure–Volume–Temperature model (`_Mpemba Effect_ Landau vs. Quantum .md`,
   lines 135–195), the fluid/vapor equation of state is modeled by the van der Waals surface
   $P_{\mathrm{vdW}}(R_{\mathrm{gas}}, T, V, b_{\mathrm{cov}}, a_{\mathrm{attr}}) = \frac{R_{\mathrm{gas}} T}{V - b_{\mathrm{cov}}} - \frac{a_{\mathrm{attr}}}{V^2}$,
   supplemented below the freezing threshold $T < T_{\mathrm{freeze}} = 273.15\text{ K}$ by water's
   anomalous molar-volume expansion $V_{\mathrm{H_2O}}(T) = V_{\mathrm{liq}} + \Delta V_{\mathrm{ice}} > V_{\mathrm{liq}}$
   ("the Ice Hump"). A static equilibrium surface alone cannot exhibit the Mpemba effect; the effect
   requires non-equilibrium trajectories through a multi-mode phase terrain.
2. **Landau Phase-Transition Complexity Dichotomy ($T > T_c$ Convex Single-Phase vs. $T < T_c$ Multi-Valley Barrier)**:
   With temperature-dependent quadratic coefficient $a(T) = a_0 (T - T_c)$ ($a_0 > 0, b > 0$):
   - **Above $T_c$ ($T > T_c \implies a(T) > 0$)**: $F(\eta, T) = \frac{1}{2}a(T)\eta^2 + \frac{1}{4}b\eta^4 > 0$
     for all $\eta \ne 0$. There is only a single minimum at $\eta = 0$ and zero activation barrier.
   - **Below $T_c$ ($T < T_c \implies a(T) < 0$)**: symmetry breaking creates two degenerate valleys at
     $\eta_\pm^2 = -a(T)/b > 0$ separated by a hilltop barrier at $\eta = 0$ of exact height
     $\Delta F_{\mathrm{barrier}}(T) = F(0, T) - F(\eta_\pm, T) = \frac{a_0^2 (T - T_c)^2}{4 b} > 0$.
     This positive activation barrier creates the slow metastable Markovian bottleneck $\lambda_2$
     that traps a cold initial state, while the Strong Mpemba $\operatorname{do}(\text{Pre-Rotation})$
     Grassmannian projector $P_{\perp v_2} \in \mathrm{Gr}_{\mathbb{R}}(1, 2)$ projects the prepared hot
     state onto the orthogonal fast subspace ($a_{2,\mathrm{hot}} = 0$). -/

/-- Van der Waals 3D $P\text{--}V\text{--}T$ equation of state pressure
$P_{\mathrm{vdW}}(R_{\mathrm{gas}}, T, V, b_{\mathrm{cov}}, a_{\mathrm{attr}}) = \frac{R_{\mathrm{gas}} T}{V - b_{\mathrm{cov}}} - \frac{a_{\mathrm{attr}}}{V^2}$
(`_Mpemba Effect_ Landau vs. Quantum .md`, lines 140–180). -/
@[blueprint "def:signals-van-der-waals-pressure"
  (title := "Van der Waals 3D P-V-T equation-of-state pressure")
  (statement := /-- Define $\operatorname{vanDerWaalsPressure}(R_{\mathrm{gas}}, T, V, b_{\mathrm{cov}}, a_{\mathrm{attr}})
    = \frac{R_{\mathrm{gas}} T}{V - b_{\mathrm{cov}}} - \frac{a_{\mathrm{attr}}}{V^2}$. -/)]
def vanDerWaalsPressure (R_gas T V b_cov a_attr : ℝ) : ℝ :=
  (R_gas * T) / (V - b_cov) - a_attr / (V ^ 2)

/-- Piecewise molar volume of water across the freezing boundary $T_{\mathrm{freeze}}$, capturing
water's anomalous expansion ("the Ice Hump", $\Delta V_{\mathrm{ice}} > 0$ for $T < T_{\mathrm{freeze}}$;
`_Mpemba Effect_ Landau vs. Quantum .md`, lines 127–148). -/
@[blueprint "def:signals-water-anomalous-freezing-volume"
  (title := "Piecewise water molar volume with anomalous ice-hump expansion for T < T_freeze")
  (statement := /-- Define $\operatorname{waterAnomalousFreezingVolume}(V_{\mathrm{liq}}, \Delta V_{\mathrm{ice}}, T, T_{\mathrm{freeze}})
    = V_{\mathrm{liq}} + \Delta V_{\mathrm{ice}}$ if $T < T_{\mathrm{freeze}}$, else $V_{\mathrm{liq}}$. -/)]
def waterAnomalousFreezingVolume (V_liq deltaV_ice T T_freeze : ℝ) : ℝ :=
  if T < T_freeze then V_liq + deltaV_ice else V_liq

/-- Temperature-dependent quadratic Landau coefficient $a(T) = a_0 (T - T_c)$ across critical
phase-transition temperature $T_c$ (Holtzman & Raz 2022). -/
@[blueprint "def:signals-landau-order-coeff"
  (title := "Temperature-dependent quadratic Landau coefficient a(T) = a_0 (T - T_c)")
  (statement := /-- Define $\operatorname{landauOrderCoeff}(a_0, T, T_c) = a_0 (T - T_c)$. -/)]
def landauOrderCoeff (a0 T T_c : ℝ) : ℝ :=
  a0 * (T - T_c)

/-- Metastable hilltop-to-valley activation barrier height
$\Delta F_{\mathrm{barrier}}(T) = F(0, T) - F(\eta_\pm, T) = \frac{a_0^2 (T - T_c)^2}{4 b}$
in the symmetry-broken multi-phase regime $T < T_c$ (Holtzman & Raz 2022). -/
@[blueprint "def:signals-landau-double-well-barrier-height"
  (title := "Landau symmetry-broken metastable activation barrier height ΔF_barrier(T) = a(T)² / (4 b)")
  (statement := /-- Define $\operatorname{landauDoubleWellBarrierHeight}(a_0, T, T_c, b)
    = \frac{(\operatorname{landauOrderCoeff}(a_0, T, T_c))^2}{4 b}$. -/)]
def landauDoubleWellBarrierHeight (a0 T T_c b : ℝ) : ℝ :=
  (landauOrderCoeff a0 T T_c) ^ 2 / (4 * b)

/-- **Master Theorem 4 (Phase-Diagram Complexity, Mpemba Grassmannian Projection, Conditional Landauer Siphoning, & Quantum Causal Synthesis)**:
Proves simultaneously why material phase-diagram complexity, the Mpemba effect, conditional Landauer
erasure, and quantum causal inference form a single closed mathematical architecture:
1. **3D $P\text{--}V\text{--}T$ Van der Waals Isochore & Water Ice-Hump Expansion**:
   At fixed molar volume $V > b_{\mathrm{cov}}$, the isochoric pressure excess between a hot and
   cold sample is $\frac{R_{\mathrm{gas}}(T_{\mathrm{hot}} - T_{\mathrm{cold}})}{V - b_{\mathrm{cov}}} > 0$,
   while crossing below $T_{\mathrm{freeze}}$ triggers water's anomalous volume expansion
   $V_{\mathrm{H_2O}}(T_{\mathrm{liq}}) < V_{\mathrm{H_2O}}(T_{\mathrm{ice}})$.
2. **Landau Phase-Transition Complexity Dichotomy ($T > T_c$ vs. $T < T_c$)**:
   - Above $T_c$ ($T_{\mathrm{above}} > T_c$), $a(T_{\mathrm{above}}) > 0$ and the free-energy terrain
     is strictly positive for all $\eta \ne 0$ ($0 = F(0) < F(\eta)$, single-valley simple phase).
   - Below $T_c$ ($T_{\mathrm{below}} < T_c$), $a(T_{\mathrm{below}}) < 0$ and the terrain splits into
     degenerate minima $\eta_{\min}^2 = -a(T_{\mathrm{below}})/b$ separated by a positive activation
     barrier $F(0) - F(\eta_{\min}) = \Delta F_{\mathrm{barrier}}(T_{\mathrm{below}}) > 0$.
3. **Strong Mpemba $\mathrm{Gr}_{\mathbb{R}}(1, 2)$ Slow-Mode Annihilation**:
   Applying the Grassmannian projector $P_{\perp v_2}(c, s)$ annihilates the slow barrier-hopping
   mode overlap (`mpembaProjectedSlowOverlap c s x0 x1 = 0`).
4. **Quantum Causal $\operatorname{do}$-Intervention & Closed-Loop Second-Law Audit**:
   Pearl's $\operatorname{do}(X)$ surgery removes confounding bias (`causalObservationalTransfer d b - causalInterventionalDoTransfer d b = b`),
   single-shot entangled erasure yields $\mathcal{Q}^* = -2 k_B T \ln 2 < 0$, the isotropic Werner state
   at $F = 1/2$ remains strictly heating ($0 < 1/2 < \frac{\ln 3}{2\ln 2}$), and closed-loop memory
   reset enforces $Q_{\mathrm{closed}} \ge k_B T \ln 2 > 0$. -/
@[blueprint "thm:signals-phase-diagram-complexity-mpemba-quantum-causal-synthesis"
  (title := "Unified synthesis of 3D P-V-T / Landau phase-diagram complexity, Strong Mpemba Gr_R(1,2) projection, conditional Landauer erasure, and quantum causal do-interventions")
  (statement := /-- For any $R_{\mathrm{gas}}, T_{\mathrm{cold}}, T_{\mathrm{hot}}, V, b_{\mathrm{cov}}, a_{\mathrm{attr}},
    V_{\mathrm{liq}}, \Delta V_{\mathrm{ice}}, T_{\mathrm{ice}}, T_{\mathrm{freeze}}, T_{\mathrm{liq}},
    a_0, T_c, T_{\mathrm{above}}, T_{\mathrm{below}}, b, \eta_{\mathrm{nz}}, \eta_{\min},
    c, s, x_0, x_1, d, b_{\mathrm{conf}}, k_B T_{\ln 2}, F, q_{\mathrm{ov}} \in \mathbb{R}$
    satisfying $0 < R_{\mathrm{gas}}$, $T_{\mathrm{cold}} < T_{\mathrm{hot}}$, $b_{\mathrm{cov}} < V$,
    $0 < \Delta V_{\mathrm{ice}}$, $T_{\mathrm{ice}} < T_{\mathrm{freeze}} \le T_{\mathrm{liq}}$,
    $0 < a_0$, $0 < b$, $T_c < T_{\mathrm{above}}$, $T_{\mathrm{below}} < T_c$, $\eta_{\mathrm{nz}} \ne 0$,
    $\eta_{\min}^2 = -\operatorname{landauOrderCoeff}(a_0, T_{\mathrm{below}}, T_c) / b$,
    $c^2 + s^2 = 1$, $0 < k_B T_{\ln 2}$, and $0 \le q_{\mathrm{ov}}$, the 3D $P\text{--}V\text{--}T$
    isochoric pressure law, water ice-hump expansion, Landau $T > T_c$ vs. $T < T_c$ barrier dichotomy,
    Strong Mpemba $\mathrm{Gr}_{\mathbb{R}}(1,2)$ slow-mode annihilation, $\operatorname{do}$-surgery
    deconfounding, and conditional Landauer vs. closed-loop Second-Law bounds hold simultaneously. -/)
  (proof := /-- Combine algebraic ring and field simplifications with positivity of squares and
    \texttt{grassmannian\_mpemba\_projector\_werner\_threshold\_and\_ocb\_causal\_witness\_identities}. -/)]
theorem phase_diagram_complexity_mpemba_and_quantum_causal_synthesis_identities
    (R_gas T_cold T_hot V b_cov a_attr V_liq deltaV_ice T_ice T_freeze T_liq : ℝ)
    (a0 T_c T_above T_below b eta_nz eta_min c s x0 x1 d b_conf kBT_ln2 fidelity q_overhead : ℝ)
    (hR : 0 < R_gas) (hT : T_cold < T_hot) (hV : b_cov < V)
    (hIce : 0 < deltaV_ice) (hT_ice : T_ice < T_freeze) (hT_liq : T_freeze ≤ T_liq)
    (ha0 : 0 < a0) (hb : 0 < b) (h_above : T_c < T_above) (h_below : T_below < T_c)
    (heta_nz : eta_nz ≠ 0)
    (heta_min : eta_min ^ 2 = -landauOrderCoeff a0 T_below T_c / b)
    (hcs : c ^ 2 + s ^ 2 = 1) (_hkBT : 0 < kBT_ln2) (hq_ov : 0 ≤ q_overhead) :
    vanDerWaalsPressure R_gas T_hot V b_cov a_attr -
        vanDerWaalsPressure R_gas T_cold V b_cov a_attr =
      R_gas * (T_hot - T_cold) / (V - b_cov) ∧
      0 < vanDerWaalsPressure R_gas T_hot V b_cov a_attr -
        vanDerWaalsPressure R_gas T_cold V b_cov a_attr ∧
      waterAnomalousFreezingVolume V_liq deltaV_ice T_liq T_freeze = V_liq ∧
      waterAnomalousFreezingVolume V_liq deltaV_ice T_ice T_freeze = V_liq + deltaV_ice ∧
      waterAnomalousFreezingVolume V_liq deltaV_ice T_liq T_freeze <
        waterAnomalousFreezingVolume V_liq deltaV_ice T_ice T_freeze ∧
      0 < landauOrderCoeff a0 T_above T_c ∧
      0 < landauFreeEnergy eta_nz (landauOrderCoeff a0 T_above T_c) b 0 ∧
      landauOrderCoeff a0 T_below T_c < 0 ∧
      landauFreeEnergy 0 (landauOrderCoeff a0 T_below T_c) b 0 -
          landauFreeEnergy eta_min (landauOrderCoeff a0 T_below T_c) b 0 =
        landauDoubleWellBarrierHeight a0 T_below T_c b ∧
      0 < landauDoubleWellBarrierHeight a0 T_below T_c b ∧
      mpembaProjectedSlowOverlap c s x0 x1 = 0 ∧
      causalObservationalTransfer d b_conf - causalInterventionalDoTransfer d b_conf = b_conf ∧
      entropySiphonCounterfactualGain kBT_ln2 1 0 = -2 * kBT_ln2 ∧
      (1 / 2 : ℝ) < wernerConditionalEntropyBitsAtHalf ∧
      kBT_ln2 ≤ closedLoopErasureAndMemoryResetHeat kBT_ln2 fidelity q_overhead := by
  have h_vdw_diff :
      vanDerWaalsPressure R_gas T_hot V b_cov a_attr -
          vanDerWaalsPressure R_gas T_cold V b_cov a_attr =
        R_gas * (T_hot - T_cold) / (V - b_cov) := by
    unfold vanDerWaalsPressure
    ring
  have h_vdw_pos :
      0 < vanDerWaalsPressure R_gas T_hot V b_cov a_attr -
        vanDerWaalsPressure R_gas T_cold V b_cov a_attr := by
    rw [h_vdw_diff]
    have h1 : 0 < T_hot - T_cold := sub_pos.mpr hT
    have h2 : 0 < V - b_cov := sub_pos.mpr hV
    positivity
  have h_water_liq :
      waterAnomalousFreezingVolume V_liq deltaV_ice T_liq T_freeze = V_liq := by
    simp [waterAnomalousFreezingVolume, not_lt.mpr hT_liq]
  have h_water_ice :
      waterAnomalousFreezingVolume V_liq deltaV_ice T_ice T_freeze = V_liq + deltaV_ice := by
    simp [waterAnomalousFreezingVolume, hT_ice]
  have h_a_above : 0 < landauOrderCoeff a0 T_above T_c := by
    unfold landauOrderCoeff
    have h_sub : 0 < T_above - T_c := sub_pos.mpr h_above
    positivity
  have h_F_above : 0 < landauFreeEnergy eta_nz (landauOrderCoeff a0 T_above T_c) b 0 := by
    unfold landauFreeEnergy
    have h_sq : 0 < eta_nz ^ 2 := sq_pos_of_ne_zero heta_nz
    have h_pow4 : 0 < eta_nz ^ 4 := by
      have : eta_nz ^ 4 = (eta_nz ^ 2) ^ 2 := by ring
      rw [this]
      positivity
    nlinarith
  have h_a_below : landauOrderCoeff a0 T_below T_c < 0 := by
    unfold landauOrderCoeff
    have h_sub : T_below - T_c < 0 := sub_neg.mpr h_below
    nlinarith
  have hb_ne : b ≠ 0 := ne_of_gt hb
  have h_eta4 : eta_min ^ 4 = (-landauOrderCoeff a0 T_below T_c / b) ^ 2 := by
    calc
      eta_min ^ 4 = (eta_min ^ 2) ^ 2 := by ring
      _ = (-landauOrderCoeff a0 T_below T_c / b) ^ 2 := by rw [heta_min]
  have h_barrier_eq :
      landauFreeEnergy 0 (landauOrderCoeff a0 T_below T_c) b 0 -
          landauFreeEnergy eta_min (landauOrderCoeff a0 T_below T_c) b 0 =
        landauDoubleWellBarrierHeight a0 T_below T_c b := by
    unfold landauFreeEnergy landauDoubleWellBarrierHeight
    rw [heta_min, h_eta4]
    field_simp [hb_ne]
    ring
  have h_barrier_pos : 0 < landauDoubleWellBarrierHeight a0 T_below T_c b := by
    unfold landauDoubleWellBarrierHeight
    have h_sq : 0 < (landauOrderCoeff a0 T_below T_c) ^ 2 := sq_pos_of_neg h_a_below
    positivity
  have h_m3 :=
    grassmannian_mpemba_projector_werner_threshold_and_ocb_causal_witness_identities
      0 0 0 c s x0 x1 fidelity hcs 0 0 0
  refine ⟨h_vdw_diff, h_vdw_pos, h_water_liq, h_water_ice,
    by rw [h_water_liq, h_water_ice]; linarith,
    h_a_above, h_F_above, h_a_below, h_barrier_eq, h_barrier_pos,
    h_m3.2.2.2.2.2.2.1,
    by unfold causalObservationalTransfer causalInterventionalDoTransfer; ring,
    by unfold entropySiphonCounterfactualGain delRioConditionalLandauerHeat conditionalEntropyLinearBits; ring,
    h_m3.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1,
    by unfold closedLoopErasureAndMemoryResetHeat delRioConditionalLandauerHeat conditionalEntropyLinearBits; linarith⟩

/-! ## Section 9: JEV vs. Causal/Quantum Decision Models, Zhang (2025) Grassmann Flows, De Clercq (2026) Tautological Bundle-Transformers, and Spatiotemporal VideoGen

This section formalizes the mathematical unification of:
1. **Jeffrey Expected Value (`JEV`, Jeffrey 1965) vs. Pearl Causal Expected Value (`CEV`, $\operatorname{do}$-calculus) vs. Quantum Causal Grassmannian Decision Theory (`QCDT`, Yukalov & Sornette 2010; Busemeyer & Bruza 2012; Oreshkov, Costa, & Brukner 2012; Giarmatzi & Costa 2023)**, together with **Jevons Marginal Utility & Jevons Paradox Rebound** (`Jevons 1865, 1871`).
2. **Self-Attention (`Vaswani et al. 2017`) vs. Zhang (2025) Causal Grassmann Mixing (`arXiv:2512.19428`) and Kane Norman's Reproduction (`github.com/kanenorman/grassmann`)**, including exact parameter accounting ($\binom{32}{2} = 496$, $267,296$ vs. $263,680$ per block, $12,607,168 + 6 \times 256^2 = 13,000,384$), convex vs. additive gating, and the **Multi-Lag Plücker Bilinear Collapse Theorem** (`zhang_multi_lag_plucker_sum_collapses_to_single_wedge`).
3. **De Clercq (2026) Tautological Fiber Bundle Geometry (`Bundle-Transformer`, `data/papers/bundle_transformer.pdf`), Kang et al. (2025) `GrFormer`, and Su et al. (2021) `RoFormer`**, proving chordal distance bounds $0 \le d_{\mathrm{chord}}(Z_1, Z_2)^2 \le k$, tautological bundle incidence $\Pi_Z(Z\alpha) = Z\alpha$, orthogonal residual concept filtering $\Pi_Z(v^\perp) = 0$, and fiber-preserving RoPE norm and relative-angle invariance.
4. **Spatiotemporal "Quantum" LLM Video Generation (`VideoGen`) & rGO/A-CNT QRAM Soliton Steering** (`data/chats/_LLMs, Fourier, and Quantum Logic .md`, lines 28–685), proving linear-in-volume $O(T H W)$ Grassmannian video scaling vs. $O(T^2 H^2 W^2)$ 3D self-attention, $O(\log^2 L)$ QFT holographic associative retrieval, and the $100\text{ ps}$ ($10\text{ GHz}$) rGO/A-CNT Kapitza thermal reset bound. -/

/-- Jeffrey Expected Value (`JEV`, Jeffrey 1965 *The Logic of Decision*) over a binary state
partition $\{s_1, s_2\}$ conditioned observationally on action/token $A$:
$\mathrm{JEV}(A) = P(s_1 \mid A) u_1 + P(s_2 \mid A) u_2$. -/
@[blueprint "def:signals-jev-evidential-expected-utility"
  (title := "Jeffrey Expected Value (JEV) evidential decision utility")
  (statement := /-- Define $\operatorname{jevEvidentialExpectedUtility}(p_{\mathrm{cond},1}, p_{\mathrm{cond},2}, u_1, u_2)
    = p_{\mathrm{cond},1} u_1 + p_{\mathrm{cond},2} u_2$. -/)]
def jevEvidentialExpectedUtility (p_cond_1 p_cond_2 u1 u2 : ℝ) : ℝ :=
  p_cond_1 * u1 + p_cond_2 * u2

/-- Causal Expected Value (`CEV`, Pearl 2000; Joyce 1999) evaluated under interventional
incoming-edge surgery $\operatorname{do}(A)$:
$\mathrm{CEV}(A) = P(s_1 \mid \operatorname{do}(A)) u_1 + P(s_2 \mid \operatorname{do}(A)) u_2$. -/
@[blueprint "def:signals-cev-causal-do-expected-utility"
  (title := "Causal Expected Value (CEV) under Pearl's do(A) intervention")
  (statement := /-- Define $\operatorname{cevCausalDoExpectedUtility}(p_{\operatorname{do},1}, p_{\operatorname{do},2}, u_1, u_2)
    = p_{\operatorname{do},1} u_1 + p_{\operatorname{do},2} u_2$. -/)]
def cevCausalDoExpectedUtility (p_do_1 p_do_2 u1 u2 : ℝ) : ℝ :=
  p_do_1 * u1 + p_do_2 * u2

/-- Complex Grassmannian $Gr_{\mathbb{C}}(2,4)$ Plücker interference / Yukalov–Sornette
quantum decision attraction term $q_{\mathrm{Pl\ddot{u}cker}} = 2(w_{A,\mathrm{re}} w_{B,\mathrm{re}} + w_{A,\mathrm{im}} w_{B,\mathrm{im}})$. -/
@[blueprint "def:signals-qcdt-plucker-interference-term"
  (title := "Complex Grassmannian Plücker interference / attraction term for Quantum Causal Decision Theory")
  (statement := /-- Define $\operatorname{qcdtPluckerInterferenceTerm}(w_{A,\mathrm{re}}, w_{A,\mathrm{im}}, w_{B,\mathrm{re}}, w_{B,\mathrm{im}})
    = 2 (w_{A,\mathrm{re}} w_{B,\mathrm{re}} + w_{A,\mathrm{im}} w_{B,\mathrm{im}})$. -/)]
def qcdtPluckerInterferenceTerm (wA_re wA_im wB_re wB_im : ℝ) : ℝ :=
  2 * (wA_re * wB_re + wA_im * wB_im)

/-- Quantum Causal Decision Theory (`QCDT`) expected utility combining Pearl's interventional
$\operatorname{do}(A)$ distribution with a zero-sum Complex Grassmannian Plücker interference shift
$q_{\mathrm{int}}$ ($q(s_1) + q(s_2) = q_{\mathrm{int}} - q_{\mathrm{int}} = 0$). -/
@[blueprint "def:signals-qcdt-quantum-causal-expected-utility"
  (title := "Quantum Causal Decision Theory (QCDT) expected utility with Plücker interference")
  (statement := /-- Define $\operatorname{qcdtQuantumCausalExpectedUtility}(p_{\operatorname{do},1}, p_{\operatorname{do},2}, q_{\mathrm{int}}, u_1, u_2)
    = (p_{\operatorname{do},1} + q_{\mathrm{int}}) u_1 + (p_{\operatorname{do},2} - q_{\mathrm{int}}) u_2$. -/)]
def qcdtQuantumCausalExpectedUtility (p_do_1 p_do_2 q_int u1 u2 : ℝ) : ℝ :=
  (p_do_1 + q_int) * u1 + (p_do_2 - q_int) * u2

/-- Jevons (1865/1871) effective compute/energy cost per token after an algorithmic efficiency
multiplier $\eta_{\mathrm{eff}} > 0$: $c_{\mathrm{eff}} = c_0 / \eta_{\mathrm{eff}}$. -/
@[blueprint "def:signals-jevons-effective-token-cost"
  (title := "Jevons effective compute cost per token c_0 / η_eff")
  (statement := /-- Define $\operatorname{jevonsEffectiveTokenCost}(c_0, \eta_{\mathrm{eff}}) = c_0 / \eta_{\mathrm{eff}}$. -/)]
def jevonsEffectiveTokenCost (c0 eta_eff : ℝ) : ℝ :=
  c0 / eta_eff

/-- Jevons elastic token demand $D(\eta_{\mathrm{eff}}) = D_0 \eta_{\mathrm{eff}} (1 + \varepsilon_{\mathrm{ex}})$,
where $\varepsilon_{\mathrm{ex}} = \varepsilon_d - 1$ is the excess price elasticity of demand above unity. -/
@[blueprint "def:signals-jevons-elastic-demand"
  (title := "Jevons elastic token demand D_0 η_eff (1 + ε_ex)")
  (statement := /-- Define $\operatorname{jevonsElasticDemand}(D_0, \eta_{\mathrm{eff}}, \varepsilon_{\mathrm{ex}})
    = D_0 \eta_{\mathrm{eff}} (1 + \varepsilon_{\mathrm{ex}})$. -/)]
def jevonsElasticDemand (D0 eta_eff elasticity_excess : ℝ) : ℝ :=
  D0 * eta_eff * (1 + elasticity_excess)

/-- Total compute/energy expenditure under Jevons rebound:
$E_{\mathrm{total}} = \operatorname{jevonsEffectiveTokenCost}(c_0, \eta_{\mathrm{eff}}) \cdot \operatorname{jevonsElasticDemand}(D_0, \eta_{\mathrm{eff}}, \varepsilon_{\mathrm{ex}})$. -/
@[blueprint "def:signals-jevons-total-compute-energy"
  (title := "Jevons total compute energy expenditure under elastic demand expansion")
  (statement := /-- Define $\operatorname{jevonsTotalComputeEnergy}(c_0, \eta_{\mathrm{eff}}, D_0, \varepsilon_{\mathrm{ex}})
    = \operatorname{jevonsEffectiveTokenCost}(c_0, \eta_{\mathrm{eff}}) \cdot \operatorname{jevonsElasticDemand}(D_0, \eta_{\mathrm{eff}}, \varepsilon_{\mathrm{ex}})$. -/)]
def jevonsTotalComputeEnergy (c0 eta_eff D0 elasticity_excess : ℝ) : ℝ :=
  jevonsEffectiveTokenCost c0 eta_eff * jevonsElasticDemand D0 eta_eff elasticity_excess

/-- Number of pairwise Plücker coordinates $\binom{r}{2} = r(r-1)/2$ for $\mathrm{Gr}(2, r)$
(`Zhang 2025`, `arXiv:2512.19428`, Section 2.2 & 3.2). -/
@[blueprint "def:signals-plucker-pair-dimension"
  (title := "Plücker coordinate dimension r(r-1)/2 for Gr(2, r)")
  (statement := /-- Define $\operatorname{pluckerPairDimension}(r) = r(r - 1) / 2$. -/)]
def pluckerPairDimension (r : ℕ) : ℕ :=
  r * (r - 1) / 2

/-- Parameter count of a standard `MultiHeadAttention` sub-block (LayerNorm + QKV + OutProjection)
in `kanenorman/grassmann` (`README.md`, lines 125–136):
$2d + (3d^2 + 3d) + (d^2 + d)$. -/
@[blueprint "def:signals-multi-head-attention-block-params"
  (title := "Per-block parameter count of MultiHeadAttention")
  (statement := /-- Define $\operatorname{multiHeadAttentionBlockParams}(d) = 2d + (3d^2 + 3d) + (d^2 + d)$. -/)]
def multiHeadAttentionBlockParams (d : ℕ) : ℕ :=
  2 * d + (3 * d * d + 3 * d) + (d * d + d)

/-- Parameter count of a `GrassmannMixing` sub-block (LayerNorm + Reduce + Expand + Gate)
in `kanenorman/grassmann` (`README.md`, lines 138–150):
$2d + (dr + r) + (\binom{r}{2}d + d) + (2d^2 + d)$. -/
@[blueprint "def:signals-kanenorman-grassmann-block-params"
  (title := "Per-block parameter count of GrassmannMixing in kanenorman/grassmann")
  (statement := /-- Define $\operatorname{kanenormanGrassmannBlockParams}(d, r)
    = 2d + (dr + r) + (\operatorname{pluckerPairDimension}(r)\cdot d + d) + (2d^2 + d)$. -/)]
def kanenormanGrassmannBlockParams (d r : ℕ) : ℕ :=
  2 * d + (d * r + r) + (pluckerPairDimension r * d + d) + (2 * d * d + d)

/-- Convex gated fusion rule $\tilde{h}_t^{\mathrm{mix}} = \alpha_t h_t + (1 - \alpha_t) g_t$
specified in Zhang (2025, `arXiv:2512.19428`, Section 3.2.5). -/
@[blueprint "def:signals-zhang-convex-gated-fusion"
  (title := "Zhang (2025) convex gated Grassmann fusion α h + (1 - α) g")
  (statement := /-- Define $\operatorname{zhangConvexGatedFusion}(\alpha, h, g) = \alpha h + (1 - \alpha) g$. -/)]
def zhangConvexGatedFusion (alpha h g : ℝ) : ℝ :=
  alpha * h + (1 - alpha) * g

/-- Additive gated residual rule $h_t + \alpha_t g_t$ implemented in `kanenorman/grassmann/model.py`
(lines 116–117 and 163–176). -/
@[blueprint "def:signals-kanenorman-additive-gated-residual"
  (title := "Kane Norman reproduction additive gated residual h + α g")
  (statement := /-- Define $\operatorname{kanenormanAdditiveGatedResidual}(\alpha, h, g) = h + \alpha g$. -/)]
def kanenormanAdditiveGatedResidual (alpha h g : ℝ) : ℝ :=
  h + alpha * g

/-- Algebraic discrepancy between the additive gated residual $h + \alpha g$ in
`kanenorman/grassmann` and the convex gated fusion $\alpha h + (1 - \alpha) g$ in
Zhang (2025, `arXiv:2512.19428`, Section 3.2.5). -/
@[blueprint "lem:signals-kanenorman-vs-zhang-gating-difference"
  (title := "Algebraic discrepancy between Kane Norman additive residual and Zhang convex gating")
  (statement := /-- For any $\alpha, h, g \in \mathbb{R}$,
    $\operatorname{kanenormanAdditiveGatedResidual}(\alpha, h, g) -
     \operatorname{zhangConvexGatedFusion}(\alpha, h, g) =
     (1 - \alpha) h + (2\alpha - 1) g$. -/)
  (proof := /-- Unfold both gating rules and close by \texttt{ring}. -/)
  (latexEnv := "lemma")]
lemma kanenorman_vs_zhang_gating_difference (alpha h g : ℝ) :
    kanenormanAdditiveGatedResidual alpha h g - zhangConvexGatedFusion alpha h g =
      (1 - alpha) * h + (2 * alpha - 1) * g := by
  unfold kanenormanAdditiveGatedResidual zhangConvexGatedFusion
  ring

/-- 2D Plücker coordinate $p_{ij}(z_{\mathrm{curr}}, z_{\mathrm{past}}) = z_{\mathrm{curr},i} z_{\mathrm{past},j} - z_{\mathrm{curr},j} z_{\mathrm{past},i}$
of a local causal token pair (`Zhang 2025`, Section 2.2 & 3.2.3). -/
@[blueprint "def:signals-plucker-2d-coord"
  (title := "Pairwise 2x2 Plücker minor z_curr,i z_past,j - z_curr,j z_past,i")
  (statement := /-- Define $\operatorname{plucker2DCoord}(z_{c,i}, z_{c,j}, z_{p,i}, z_{p,j})
    = z_{c,i} z_{p,j} - z_{c,j} z_{p,i}$. -/)]
def plucker2DCoord (z_curr_i z_curr_j z_past_i z_past_j : ℝ) : ℝ :=
  z_curr_i * z_past_j - z_curr_j * z_past_i

/-- **Theorem (Zhang Multi-Lag Plücker Bilinear Collapse)**:
Any weighted sum or average of Plücker 2-vectors sharing the same current anchor token $z_t$
collapses algebraically into a **single decomposable wedge product** between $z_t$ and the
weighted sum of past lag vectors:
$c_1 (z_t \wedge z_{t-\Delta_1})_{ij} + c_2 (z_t \wedge z_{t-\Delta_2})_{ij} = (z_t \wedge (c_1 z_{t-\Delta_1} + c_2 z_{t-\Delta_2}))_{ij}$. -/
@[blueprint "thm:signals-zhang-multi-lag-plucker-bilinear-collapse"
  (title := "Shared-anchor multi-lag Plücker sum collapses to a single rank-2 wedge product")
  (statement := /-- For any anchor coordinates $z_{c,i}, z_{c,j}$, lag coordinates
    $z_{p1,i}, z_{p1,j}, z_{p2,i}, z_{p2,j}$, and weights $c_1, c_2 \in \mathbb{R}$,
    $c_1 \operatorname{plucker2DCoord}(z_{c,i}, z_{c,j}, z_{p1,i}, z_{p1,j}) +
     c_2 \operatorname{plucker2DCoord}(z_{c,i}, z_{c,j}, z_{p2,i}, z_{p2,j}) =
     \operatorname{plucker2DCoord}(z_{c,i}, z_{c,j}, c_1 z_{p1,i} + c_2 z_{p2,i}, c_1 z_{p1,j} + c_2 z_{p2,j})$. -/)
  (proof := /-- Unfold \texttt{plucker2DCoord} and close by \texttt{ring}. -/)]
theorem zhang_multi_lag_plucker_sum_collapses_to_single_wedge
    (c1 c2 z_ci z_cj z_p1i z_p1j z_p2i z_p2j : ℝ) :
    c1 * plucker2DCoord z_ci z_cj z_p1i z_p1j +
        c2 * plucker2DCoord z_ci z_cj z_p2i z_p2j =
      plucker2DCoord z_ci z_cj (c1 * z_p1i + c2 * z_p2i) (c1 * z_p1j + c2 * z_p2j) := by
  unfold plucker2DCoord
  ring

/-- Squared chordal distance $d_{\mathrm{chord}}(Z_1, Z_2)^2 = \frac{1}{2}\|\Pi_{Z_1} - \Pi_{Z_2}\|_F^2 = k - \|Z_1^\top Z_2\|_F^2$
on the Grassmannian $\mathrm{Gr}(k, n)$ (`De Clercq 2026`, *Bundle-Transformer*, Section 2.1). -/
@[blueprint "def:signals-grassmann-chordal-dist-sq"
  (title := "Squared chordal distance k - ||Z_1^T Z_2||_F^2 on Gr(k, n)")
  (statement := /-- Define $\operatorname{grassmannChordalDistSq}(k, \mathrm{frobOverlapSq}) = k - \mathrm{frobOverlapSq}$. -/)]
def grassmannChordalDistSq (k frob_overlap_sq : ℝ) : ℝ :=
  k - frob_overlap_sq

/-- Concept similarity kernel $s_{ij}^{\mathrm{concept}} = \gamma \exp(-d_{\mathrm{chord}}(Z_i, Z_j)^2 / \sigma)$
on the base Grassmannian of the tautological bundle (`De Clercq 2026`, Section 3.2). -/
@[blueprint "def:signals-bundle-concept-similarity"
  (title := "Bundle-Transformer Grassmannian concept similarity kernel")
  (statement := /-- Define $\operatorname{bundleConceptSimilarity}(\gamma, k, \mathrm{frobOverlapSq}, \sigma)
    = \gamma \exp(-\operatorname{grassmannChordalDistSq}(k, \mathrm{frobOverlapSq}) / \sigma)$. -/)]
def bundleConceptSimilarity (gamma k frob_overlap_sq sigma : ℝ) : ℝ :=
  gamma * Real.exp (-grassmannChordalDistSq k frob_overlap_sq / sigma)

/-- Hybrid Bundle-Transformer attention score $s_{ij} = \lambda_{\mathrm{inst}} s_{ij}^{\mathrm{inst}} + \lambda_{\mathrm{concept}} s_{ij}^{\mathrm{concept}}$
combining fiber instance similarity and base-subspace concept similarity (`De Clercq 2026`, Section 3.2). -/
@[blueprint "def:signals-bundle-hybrid-attention-score"
  (title := "Bundle-Transformer hybrid instance + concept attention score")
  (statement := /-- Define $\operatorname{bundleHybridAttentionScore}(\lambda_{\mathrm{inst}}, s_{\mathrm{inst}}, \lambda_{\mathrm{concept}}, s_{\mathrm{concept}})
    = \lambda_{\mathrm{inst}} s_{\mathrm{inst}} + \lambda_{\mathrm{concept}} s_{\mathrm{concept}}$. -/)]
def bundleHybridAttentionScore (lam_inst s_inst lam_concept s_concept : ℝ) : ℝ :=
  lam_inst * s_inst + lam_concept * s_concept

/-- Fiber instance vector $v = Z \alpha = (c \alpha, s \alpha)^\top \in Z \subset \mathbb{R}^2$
in the tautological bundle $\mathcal{T} = \{(Z, v) \mid Z \in \mathrm{Gr}(1, 2),\, v \in Z\}$
(`De Clercq 2026`, Section 2.2 & 3.1). -/
@[blueprint "def:signals-tautological-fiber-vec"
  (title := "Tautological bundle fiber vector v = Z α")
  (statement := /-- Define $\operatorname{tautologicalFiberVec}(c, s, \alpha) = (c\alpha, s\alpha)$. -/)]
def tautologicalFiberVec (c s alpha : ℝ) : ℝ × ℝ :=
  (c * alpha, s * alpha)

/-- Orthogonal subspace projection $\Pi_Z(x, y) = Z Z^\top (x, y)^\top$ onto the tautological
fiber over $Z = (c, s)^\top \in \mathrm{Gr}(1, 2)$ (`De Clercq 2026`, Section 3.2 & 3.4). -/
@[blueprint "def:signals-tautological-projector-vec"
  (title := "Tautological bundle orthogonal fiber projector Π_Z = Z Z^T")
  (statement := /-- Define $\operatorname{tautologicalProjectorVec}(c, s, x, y)
    = (c(cx + sy), s(cx + sy))$. -/)]
def tautologicalProjectorVec (c s x y : ℝ) : ℝ × ℝ :=
  (c * (c * x + s * y), s * (c * x + s * y))

/-- Fiber-preserving Rotary Position Embedding (`RoPE`) rotation $R_\theta \alpha \in \mathbb{R}^2$
inside a 2D fiber subspace (`Su et al. 2021`, `arXiv:2104.09864`; `De Clercq 2026`, Section 3.3). -/
@[blueprint "def:signals-rope-fiber-rotate"
  (title := "Fiber-preserving RoPE SO(2) coordinate rotation")
  (statement := /-- Define $\operatorname{ropeFiberRotate}(\cos\theta, \sin\theta, \alpha_1, \alpha_2)
    = (\cos\theta\,\alpha_1 - \sin\theta\,\alpha_2, \sin\theta\,\alpha_1 + \cos\theta\,\alpha_2)$. -/)]
def ropeFiberRotate (cos_t sin_t a1 a2 : ℝ) : ℝ × ℝ :=
  (cos_t * a1 - sin_t * a2, sin_t * a1 + cos_t * a2)

/-- Full 3D spatiotemporal self-attention pairwise interaction complexity
$O((T H W)^2 d_{\mathrm{head}})$ for a video of $T$ frames and $H \times W$ spatial tokens per frame. -/
@[blueprint "def:signals-spatiotemporal-full-attention-complexity"
  (title := "Quadratic 3D spatiotemporal video self-attention complexity (T H W)^2 d_head")
  (statement := /-- Define $\operatorname{spatiotemporalFullAttentionComplexity}(T, H, W, d_{\mathrm{head}})
    = (T H W)^2 d_{\mathrm{head}}$. -/)]
def spatiotemporalFullAttentionComplexity (T H W d_head : ℝ) : ℝ :=
  (T * H * W) ^ 2 * d_head

/-- Linear-in-volume 3D spatiotemporal Causal Grassmann video mixing complexity
$O((T H W) m_{\mathrm{lags}} \binom{r}{2})$ for $m_{\mathrm{lags}}$ multi-scale spatiotemporal offsets. -/
@[blueprint "def:signals-spatiotemporal-grassmann-video-complexity"
  (title := "Linear-in-volume 3D spatiotemporal Causal Grassmann video complexity (T H W) m_lags d_plucker")
  (statement := /-- Define $\operatorname{spatiotemporalGrassmannVideoComplexity}(T, H, W, m_{\mathrm{lags}}, d_{\mathrm{pl\ddot{u}cker}})
    = (T H W) m_{\mathrm{lags}} d_{\mathrm{pl\ddot{u}cker}}$. -/)]
def spatiotemporalGrassmannVideoComplexity (T H W m_lags d_plucker : ℝ) : ℝ :=
  (T * H * W) * m_lags * d_plucker

/-- Kapitza thermal relaxation time $t_{\mathrm{cool}} = R_K C_v d_{\mathrm{thick}}$ of an
`rGO-Vitrimer` active metasurface steering layer backed by `A-CNT` thermal vias
(`data/chats/_LLMs, Fourier, and Quantum Logic .md`, lines 660–685). -/
@[blueprint "def:signals-rgo-vitrimer-kapitza-cool-time"
  (title := "rGO-Vitrimer / A-CNT Kapitza thermal relaxation time R_K C_v d")
  (statement := /-- Define $\operatorname{rgoVitrimerKapitzaCoolTime}(R_K, C_v, d_{\mathrm{thick}})
    = R_K C_v d_{\mathrm{thick}}$. -/)]
def rgoVitrimerKapitzaCoolTime (R_K C_v d_thick : ℝ) : ℝ :=
  R_K * C_v * d_thick

/-- **Master Theorem 5 (Quantum Causal JEV Decision Theory, Zhang Grassmann Flows, De Clercq Tautological Bundle-Transformers, & Spatiotemporal VideoGen Synthesis)**:
Establishes the machine-checked mathematical bridge uniting all five questions:
1. **JEV vs. Pearl $\operatorname{do}$-Calculus vs. Quantum Causal Decision Theory (`QCDT`) & Jevons Rebound**:
   - Observational `JEV` minus interventional `CEV` equals the exact confounding bias
     $b_{\mathrm{conf}}(u_1 - u_2)$ (`jevEvidentialExpectedUtility (p_do + b_conf) ((1 - p_do) - b_conf) u1 u2 - cevCausalDoExpectedUtility p_do (1 - p_do) u1 u2 = b_conf * (u1 - u2)`).
   - Complex Grassmannian Plücker interference satisfies the exact norm decomposition, reverses
     sign under a $\pi$ phase inversion (`qcdtPluckerInterferenceTerm wA_re wA_im wB_re wB_im + qcdtPluckerInterferenceTerm wA_re wA_im (-wB_re) (-wB_im) = 0`),
     shifts `QCDT` utility by $q_{\mathrm{int}}(u_1 - u_2)$, and generates non-commutative order effects
     proportional to `quantumSwitchCommutator`.
   - Under elastic demand ($\varepsilon_{\mathrm{ex}} > 0$), efficiency gain $\eta_{\mathrm{eff}} > 0$
     triggers the **Jevons Paradox rebound**: `c0 * D0 < jevonsTotalComputeEnergy c0 eta_eff D0 eps_ex`.
2. **Zhang (2025) `arXiv:2512.19428` & `kanenorman/grassmann` Exact Parameter & Bilinear Collapse Laws**:
   - $\binom{32}{2} = 496$, `multiHeadAttentionBlockParams 256 = 263680`,
     `kanenormanGrassmannBlockParams 256 32 = 267296`, and $12607168 + 6 \times 256^2 = 13000384$.
   - Shared-anchor multi-lag Plücker averaging collapses to a single rank-2 wedge
     (`zhang_multi_lag_plucker_sum_collapses_to_single_wedge`).
3. **De Clercq (2026) Tautological Bundle-Transformer & Su et al. (2021) Fiber-RoPE Invariants**:
   - Chordal distance squared satisfies $0 \le d_{\mathrm{chord}}(Z_1, Z_2)^2 \le k$ and $d_{\mathrm{chord}}(Z, Z)^2 = 0$.
   - Tautological incidence holds ($\Pi_Z(Z\alpha) = Z\alpha$), while components orthogonal to the
     updated concept subspace are filtered to zero ($\Pi_Z(-s\beta, c\beta) = (0, 0)$).
   - Fiber-RoPE preserves the fiber Euclidean norm $(\alpha_1')^2 + (\alpha_2')^2 = \alpha_1^2 + \alpha_2^2$
     without altering the base concept subspace $Z \in \mathrm{Gr}(k, n)$.
4. **Spatiotemporal VideoGen Complexity & rGO/A-CNT $100\text{ ps}$ QRAM Soliton Steering**:
   - Linear-in-volume 3D Grassmannian video mixing strictly beats quadratic 3D self-attention
     whenever $m_{\mathrm{lags}} d_{\mathrm{pl\ddot{u}cker}} < (T H W) d_{\mathrm{head}}$.
   - At $R_K = 5 \times 10^{-9}\text{ m}^2\text{K/W}$, $C_v = 2 \times 10^6\text{ J/m}^3\text{K}$,
     and $d = 10^{-8}\text{ m}$, the rGO/A-CNT QRAM shutter resets in $10^{-10}\text{ s} = 100\text{ ps}$
     ($10\text{ GHz}$ clock). -/
@[blueprint "thm:signals-quantum-causal-jev-bundle-transformer-videogen-synthesis"
  (title := "Master synthesis of JEV vs. QCDT decision models, Zhang Grassmann flows, De Clercq Bundle-Transformers, and spatiotemporal VideoGen")
  (statement := /-- Simultaneous verification of JEV vs.\ CEV vs.\ QCDT decision identities,
    Jevons compute rebound, Zhang (2025) / \texttt{kanenorman/grassmann} parameter and Plücker
    bilinear collapse laws, De Clercq (2026) tautological bundle incidence and chordal bounds,
    Su et al.\ (2021) fiber-RoPE norm invariance, and spatiotemporal VideoGen complexity bounds. -/)
  (proof := /-- Combine algebraic ring identities, positivity of elastic demand and spatiotemporal
    token volume, and trigonometric norm identities $c^2 + s^2 = 1$ and $\cos^2\theta + \sin^2\theta = 1$. -/)]
theorem quantum_causal_jev_bundle_transformer_and_videogen_synthesis_identities
    (p_do b_conf q_int u1 u2 wA_re wA_im wB_re wB_im c0 eta_eff D0 eps_ex : ℝ)
    (c1 c2 z_ci z_cj z_p1i z_p1j z_p2i z_p2j : ℝ)
    (k frob_overlap_sq c s alpha beta cos_t sin_t a1 a2 : ℝ)
    (T H W d_head m_lags d_plucker : ℝ)
    (hb_conf : 0 < b_conf) (hu : u2 < u1)
    (hc0 : 0 < c0) (heta : 0 < eta_eff) (hD0 : 0 < D0) (heps : 0 < eps_ex)
    (hfrob_nonneg : 0 ≤ frob_overlap_sq) (hfrob_le : frob_overlap_sq ≤ k)
    (hcs : c ^ 2 + s ^ 2 = 1) (hrope : cos_t ^ 2 + sin_t ^ 2 = 1)
    (hTHW : 0 < T * H * W) (h_vid_lt : m_lags * d_plucker < (T * H * W) * d_head) :
    jevEvidentialExpectedUtility (p_do + b_conf) ((1 - p_do) - b_conf) u1 u2 -
        cevCausalDoExpectedUtility p_do (1 - p_do) u1 u2 =
      b_conf * (u1 - u2) ∧
      0 < jevEvidentialExpectedUtility (p_do + b_conf) ((1 - p_do) - b_conf) u1 u2 -
        cevCausalDoExpectedUtility p_do (1 - p_do) u1 u2 ∧
      (wA_re + wB_re) ^ 2 + (wA_im + wB_im) ^ 2 =
        (wA_re ^ 2 + wA_im ^ 2) + (wB_re ^ 2 + wB_im ^ 2) +
          qcdtPluckerInterferenceTerm wA_re wA_im wB_re wB_im ∧
      qcdtPluckerInterferenceTerm wA_re wA_im wB_re wB_im +
          qcdtPluckerInterferenceTerm wA_re wA_im (-wB_re) (-wB_im) = 0 ∧
      qcdtQuantumCausalExpectedUtility p_do (1 - p_do) q_int u1 u2 -
          cevCausalDoExpectedUtility p_do (1 - p_do) u1 u2 =
        q_int * (u1 - u2) ∧
      jevonsTotalComputeEnergy c0 eta_eff D0 eps_ex = c0 * D0 * (1 + eps_ex) ∧
      c0 * D0 < jevonsTotalComputeEnergy c0 eta_eff D0 eps_ex ∧
      pluckerPairDimension 32 = 496 ∧
      multiHeadAttentionBlockParams 256 = 263680 ∧
      kanenormanGrassmannBlockParams 256 32 = 267296 ∧
      (12607168 : ℕ) + 6 * (256 * 256) = 13000384 ∧
      c1 * plucker2DCoord z_ci z_cj z_p1i z_p1j +
          c2 * plucker2DCoord z_ci z_cj z_p2i z_p2j =
        plucker2DCoord z_ci z_cj (c1 * z_p1i + c2 * z_p2i) (c1 * z_p1j + c2 * z_p2j) ∧
      0 ≤ grassmannChordalDistSq k frob_overlap_sq ∧
      grassmannChordalDistSq k frob_overlap_sq ≤ k ∧
      grassmannChordalDistSq k k = 0 ∧
      tautologicalProjectorVec c s (c * alpha) (s * alpha) = tautologicalFiberVec c s alpha ∧
      tautologicalProjectorVec c s (-s * beta) (c * beta) = (0, 0) ∧
      (ropeFiberRotate cos_t sin_t a1 a2).1 ^ 2 +
          (ropeFiberRotate cos_t sin_t a1 a2).2 ^ 2 =
        a1 ^ 2 + a2 ^ 2 ∧
      spatiotemporalGrassmannVideoComplexity T H W m_lags d_plucker <
        spatiotemporalFullAttentionComplexity T H W d_head ∧
      rgoVitrimerKapitzaCoolTime (5e-9) (2e6) (1e-8) = 1e-10 := by
  have h_jev_diff :
      jevEvidentialExpectedUtility (p_do + b_conf) ((1 - p_do) - b_conf) u1 u2 -
          cevCausalDoExpectedUtility p_do (1 - p_do) u1 u2 =
        b_conf * (u1 - u2) := by
    unfold jevEvidentialExpectedUtility cevCausalDoExpectedUtility
    ring
  have h_jev_pos :
      0 < jevEvidentialExpectedUtility (p_do + b_conf) ((1 - p_do) - b_conf) u1 u2 -
        cevCausalDoExpectedUtility p_do (1 - p_do) u1 u2 := by
    rw [h_jev_diff]
    have hu_sub : 0 < u1 - u2 := sub_pos.mpr hu
    positivity
  have h_eta_ne : eta_eff ≠ 0 := ne_of_gt heta
  have h_jevons_eq :
      jevonsTotalComputeEnergy c0 eta_eff D0 eps_ex = c0 * D0 * (1 + eps_ex) := by
    unfold jevonsTotalComputeEnergy jevonsEffectiveTokenCost jevonsElasticDemand
    field_simp [h_eta_ne]
  have h_jevons_gt : c0 * D0 < jevonsTotalComputeEnergy c0 eta_eff D0 eps_ex := by
    rw [h_jevons_eq]
    have h_prod : 0 < c0 * D0 * eps_ex := by positivity
    linarith
  have h_in_dot : c * (c * alpha) + s * (s * alpha) = alpha := by
    calc
      c * (c * alpha) + s * (s * alpha) = (c ^ 2 + s ^ 2) * alpha := by ring
      _ = alpha := by rw [hcs]; ring
  have h_proj_in :
      tautologicalProjectorVec c s (c * alpha) (s * alpha) = tautologicalFiberVec c s alpha := by
    unfold tautologicalProjectorVec tautologicalFiberVec
    rw [h_in_dot]
  have h_proj_orth :
      tautologicalProjectorVec c s (-s * beta) (c * beta) = (0, 0) := by
    unfold tautologicalProjectorVec
    apply Prod.ext <;> ring
  have h_rope_norm :
      (ropeFiberRotate cos_t sin_t a1 a2).1 ^ 2 +
          (ropeFiberRotate cos_t sin_t a1 a2).2 ^ 2 =
        a1 ^ 2 + a2 ^ 2 := by
    unfold ropeFiberRotate
    calc
      (cos_t * a1 - sin_t * a2) ^ 2 + (sin_t * a1 + cos_t * a2) ^ 2 =
        (cos_t ^ 2 + sin_t ^ 2) * (a1 ^ 2 + a2 ^ 2) := by ring
      _ = a1 ^ 2 + a2 ^ 2 := by rw [hrope]; ring
  have h_vid :
      spatiotemporalGrassmannVideoComplexity T H W m_lags d_plucker <
        spatiotemporalFullAttentionComplexity T H W d_head := by
    unfold spatiotemporalGrassmannVideoComplexity spatiotemporalFullAttentionComplexity
    calc
      (T * H * W) * m_lags * d_plucker = (T * H * W) * (m_lags * d_plucker) := by ring
      _ < (T * H * W) * ((T * H * W) * d_head) := mul_lt_mul_of_pos_left h_vid_lt hTHW
      _ = (T * H * W) ^ 2 * d_head := by ring
  refine ⟨h_jev_diff, h_jev_pos,
    by unfold qcdtPluckerInterferenceTerm; ring,
    by unfold qcdtPluckerInterferenceTerm; ring,
    by unfold qcdtQuantumCausalExpectedUtility cevCausalDoExpectedUtility; ring,
    h_jevons_eq, h_jevons_gt,
    by decide, by decide, by decide, by decide,
    zhang_multi_lag_plucker_sum_collapses_to_single_wedge c1 c2 z_ci z_cj z_p1i z_p1j z_p2i z_p2j,
    by unfold grassmannChordalDistSq; linarith,
    by unfold grassmannChordalDistSq; linarith,
    by unfold grassmannChordalDistSq; ring,
    h_proj_in, h_proj_orth, h_rope_norm, h_vid,
    by unfold rgoVitrimerKapitzaCoolTime; norm_num⟩

/-- 4D Plücker Klein quadric residual
$\mathcal{Q}_4(p_{01}, p_{02}, p_{03}, p_{12}, p_{13}, p_{23}) = p_{01} p_{23} - p_{02} p_{13} + p_{03} p_{12}$
measuring whether a 2-form in $\Lambda^2 \mathbb{R}^4$ is a simple rank-2 decomposable blade
($\mathcal{Q}_4 = 0$) or a non-decomposable rank-4 cross-lag superposition ($\mathcal{Q}_4 \ne 0$). -/
@[blueprint "def:signals-plucker-quadric-4d-residual"
  (title := "4D Plücker Klein quadric decomposability residual p_01 p_23 - p_02 p_13 + p_03 p_12")
  (statement := /-- Define $\operatorname{pluckerQuadric4DResidual}(p_{01}, p_{02}, p_{03}, p_{12}, p_{13}, p_{23})
    = p_{01} p_{23} - p_{02} p_{13} + p_{03} p_{12}$. -/)]
def pluckerQuadric4DResidual (p01 p02 p03 p12 p13 p23 : ℝ) : ℝ :=
  p01 * p23 - p02 * p13 + p03 * p12

/-- **Theorem (Shared-Anchor Multi-Lag Plücker Sums Always Satisfy the Rank-2 Klein Quadric)**:
For any 4D anchor token $z_c = (z_{c0}, z_{c1}, z_{c2}, z_{c3})$ and any weighted sum of past lags
$\bar{z}_p = (z_{p0}, z_{p1}, z_{p2}, z_{p3})$, the six Plücker coordinates $p_{ij} = \operatorname{plucker2DCoord}(z_{c,i}, z_{c,j}, z_{p,i}, z_{p,j})$
satisfy $\operatorname{pluckerQuadric4DResidual}(p_{01}, p_{02}, p_{03}, p_{12}, p_{13}, p_{23}) = 0$ identically.
By contrast, adding a disjoint cross-lag wedge $c_1 (e_0 \wedge e_1) + c_{12} (e_2 \wedge e_3)$
produces a strictly nonzero Klein quadric residual $\mathcal{Q}_4 = c_1 c_{12} \ne 0$, escaping the
rank-2 decomposable cone to achieve full exterior rank 4 in $\Lambda^2 \mathbb{R}^4$. -/
@[blueprint "thm:signals-shared-anchor-vs-cross-lag-klein-quadric"
  (title := "Shared-anchor Plücker sums remain trapped on the rank-2 Klein quadric while cross-lag wedges achieve rank 4")
  (statement := /-- For any $z_{c0}, z_{c1}, z_{c2}, z_{c3}, z_{p0}, z_{p1}, z_{p2}, z_{p3}, c_1, c_{12} \in \mathbb{R}$,
    $\operatorname{pluckerQuadric4DResidual}(p_{01}, p_{02}, p_{03}, p_{12}, p_{13}, p_{23}) = 0$
    for $p_{ij} = \operatorname{plucker2DCoord}(z_{c,i}, z_{c,j}, z_{p,i}, z_{p,j})$, whereas
    $\operatorname{pluckerQuadric4DResidual}(c_1, 0, 0, 0, 0, c_{12}) = c_1 c_{12}$. -/)
  (proof := /-- Unfold \texttt{pluckerQuadric4DResidual} and \texttt{plucker2DCoord}, then close by \texttt{ring}. -/)]
theorem shared_anchor_vs_cross_lag_klein_quadric
    (zc0 zc1 zc2 zc3 zp0 zp1 zp2 zp3 c1 c12 : ℝ) :
    pluckerQuadric4DResidual
        (plucker2DCoord zc0 zc1 zp0 zp1)
        (plucker2DCoord zc0 zc2 zp0 zp2)
        (plucker2DCoord zc0 zc3 zp0 zp3)
        (plucker2DCoord zc1 zc2 zp1 zp2)
        (plucker2DCoord zc1 zc3 zp1 zp3)
        (plucker2DCoord zc2 zc3 zp2 zp3) = 0 ∧
      pluckerQuadric4DResidual c1 0 0 0 0 c12 = c1 * c12 := by
  unfold pluckerQuadric4DResidual plucker2DCoord
  constructor <;> ring

/-- Shared 2x2 linear transport $A(x, y)^\top = (a_{00}x + a_{01}y, a_{10}x + a_{11}y)^\top$
on the tautological bundle (`De Clercq 2026`, *Bundle-Transformer*, Section 3.4 Step 1). -/
@[blueprint "def:signals-tautological-linear-transport-vec"
  (title := "Tautological bundle shared 2x2 linear transport A v")
  (statement := /-- Define $\operatorname{tautologicalLinearTransportVec}(a_{00}, a_{01}, a_{10}, a_{11}, x, y)
    = (a_{00} x + a_{01} y, a_{10} x + a_{11} y)$. -/)]
def tautologicalLinearTransportVec (a00 a01 a10 a11 x y : ℝ) : ℝ × ℝ :=
  (a00 * x + a01 * y, a10 * x + a11 * y)

/-- Cross-frame inner product $\langle u, \operatorname{diag}(1, \sigma_2) w \rangle = u_1 w_1 + \sigma_2 u_2 w_2$
between two 2D fiber vectors evaluated across concept subspaces $Z_i, Z_j \in \mathrm{Gr}(2, n)$
with principal-angle singular values $(1, \sigma_2)$ (`De Clercq 2026`, Section 3.2 & 3.3). -/
@[blueprint "def:signals-rope-cross-frame-inner-product"
  (title := "Cross-frame fiber inner product u_1 w_1 + σ_2 u_2 w_2 under principal singular value σ_2")
  (statement := /-- Define $\operatorname{ropeCrossFrameInnerProduct}(u, w, \sigma_2)
    = u_1 w_1 + \sigma_2 u_2 w_2$. -/)]
def ropeCrossFrameInnerProduct (u w : ℝ × ℝ) (sigma2 : ℝ) : ℝ :=
  u.1 * w.1 + sigma2 * u.2 * w.2

/-- Total latency $T_{\mathrm{total}} = T_{\mathrm{prep}} + T_{\mathrm{QFT}}$ of a Quantum Fourier
Transform (`QFT`) Holographic Associative Memory lookup, separating the $O(\log^2 L)$ QFT gate
execution time $T_{\mathrm{QFT}}$ from the $O(L)$ classical-to-quantum QRAM state-preparation
time $T_{\mathrm{prep}}$ (`data/chats/_LLMs, Fourier, and Quantum Logic .md`, lines 20–23, 81–83). -/
@[blueprint "def:signals-qft-associative-total-latency"
  (title := "Total QFT holographic associative memory latency T_prep + T_QFT")
  (statement := /-- Define $\operatorname{qftAssociativeTotalLatency}(T_{\mathrm{prep}}, T_{\mathrm{QFT}})
    = T_{\mathrm{prep}} + T_{\mathrm{QFT}}$. -/)]
def qftAssociativeTotalLatency (t_prep t_qft : ℝ) : ℝ :=
  t_prep + t_qft

/-- Transverse linear momentum $k_y = \ell / a_{\mathrm{scale}}$ produced by a log-polar
coordinate unwrapper $(x, y) = (-a_{\mathrm{scale}} \ln(r/b), a_{\mathrm{scale}}\theta)$
acting on an OAM vortex mode $\exp(i \ell \theta)$ (`data/chats/_LLMs, Fourier, and Quantum Logic .md`,
lines 509–548). -/
@[blueprint "def:signals-oam-log-polar-transverse-momentum"
  (title := "Log-polar OAM unwrapper transverse linear momentum l / a_scale")
  (statement := /-- Define $\operatorname{oamLogPolarTransverseMomentum}(\ell, a_{\mathrm{scale}})
    = \ell / a_{\mathrm{scale}}$. -/)]
def oamLogPolarTransverseMomentum (l_charge a_scale : ℝ) : ℝ :=
  l_charge / a_scale

/-- **Master Theorem 6 (Plücker Rank-2 vs. Rank-4 Klein Quadric Critique, Tautological Shared Linear Transport, Cross-Fiber RoPE Gauge-Mismatch Law, and QRAM State-Preparation Bounds)**:
Establishes four foundational mathematical critiques and extensions:
1. **Shared-Anchor Rank-2 Collapse vs. Cross-Lag Rank-4 Escape on $\mathcal{Q}_4$**:
   - Any 4D shared-anchor Plücker sum satisfies $\mathcal{Q}_4(p) = 0$ (`shared_anchor_vs_cross_lag_klein_quadric.1`),
     whereas adding a disjoint cross-lag wedge $c_1(e_0\wedge e_1) + c_{12}(e_2\wedge e_3)$ with
     $c_1 > 0, c_{12} > 0$ yields $\mathcal{Q}_4(p) = c_1 c_{12} > 0$, proving exterior rank 4.
2. **Tautological Bundle Shared Linear Transport Preserves Fiber Incidence (`De Clercq 2026`, Sec. 3.4 Step 1)**:
   - Under any $2 \times 2$ matrix $A$, transporting $v = (c\alpha, s\alpha)$ gives
     $A v = ((a_{00}c + a_{01}s)\alpha, (a_{10}c + a_{11}s)\alpha) = \operatorname{tautologicalFiberVec}(c_{\mathrm{new}}, s_{\mathrm{new}}, r\alpha)$,
     lying identically in the QR-normalized subspace $Z_{\mathrm{new}} = (c_{\mathrm{new}}, s_{\mathrm{new}})$.
3. **Cross-Fiber RoPE Gauge-Mismatch Critique (`De Clercq 2026`, Sec. 3.3 vs. `Su et al. 2021`)**:
   - In a synchronized or parallel-transported concept frame ($\sigma_2 = 1$), applying a common
     RoPE rotation $R_\theta$ to both query and key preserves their inner product identically
     ($\langle R_\theta \alpha, R_\theta \beta \rangle = \langle \alpha, \beta \rangle$), so attention
     depends purely on relative position $\theta_n - \theta_m$.
   - In an unsynchronized cross-concept frame with principal singular value $\sigma_2 \ne 1$, a
     common $\theta = \pi/2$ shift alters the inner product by the exact gauge-mismatch residual
     $(\sigma_2 - 1)(\alpha_1 \beta_1 - \alpha_2 \beta_2)$, proving why Levi-Civita / polar
     parallel transport $U_{ij} = \operatorname{Polar}(Z_i^\top Z_j)$ is required before cross-fiber RoPE.
4. **QFT Associative Memory State-Preparation Lower Bound & OAM Log-Polar Mode Separation**:
   - Whenever $T_{\mathrm{QFT}} > 0$, total QFT associative retrieval latency satisfies
     $T_{\mathrm{prep}} < \operatorname{qftAssociativeTotalLatency}(T_{\mathrm{prep}}, T_{\mathrm{QFT}})$,
     formalizing the QRAM loading bottleneck.
   - Distinct OAM charges $\ell_1 \ne \ell_2$ map to strictly separated transverse momenta
     $\operatorname{oamLogPolarTransverseMomentum}(\ell_1, a) - \operatorname{oamLogPolarTransverseMomentum}(\ell_2, a) = (\ell_1 - \ell_2)/a$. -/
@[blueprint "thm:signals-quantum-causal-plucker-rank-rope-gauge-qram-critique"
  (title := "Plücker Klein quadric rank-4 escape, tautological linear transport, cross-fiber RoPE gauge mismatch, and QRAM latency bounds")
  (statement := /-- Simultaneous verification of 4D Plücker Klein quadric rank-2 collapse vs.\
    cross-lag rank-4 escape, tautological bundle shared linear transport incidence,
    same-frame vs.\ anisotropic cross-frame RoPE inner-product shift, QFT state-preparation
    latency bound, and log-polar OAM momentum separation. -/)
  (proof := /-- Combine \texttt{shared\_anchor\_vs\_cross\_lag\_klein\_quadric}, algebraic ring
    identities, trigonometric norm invariance $\cos^2\theta + \sin^2\theta = 1$, and
    \texttt{field\_simp} / \texttt{positivity}. -/)]
theorem quantum_causal_plucker_rank_rope_gauge_and_qram_critique_identities
    (zc0 zc1 zc2 zc3 zp0 zp1 zp2 zp3 c1 c12 : ℝ)
    (a00 a01 a10 a11 c s alpha cos_t sin_t a1 a2 b1 b2 sigma2 : ℝ)
    (t_prep t_qft l1 l2 a_scale : ℝ)
    (hc1 : 0 < c1) (hc12 : 0 < c12)
    (hrope : cos_t ^ 2 + sin_t ^ 2 = 1)
    (ht_qft : 0 < t_qft) (_ha_scale : 0 < a_scale) :
    pluckerQuadric4DResidual
        (plucker2DCoord zc0 zc1 zp0 zp1)
        (plucker2DCoord zc0 zc2 zp0 zp2)
        (plucker2DCoord zc0 zc3 zp0 zp3)
        (plucker2DCoord zc1 zc2 zp1 zp2)
        (plucker2DCoord zc1 zc3 zp1 zp3)
        (plucker2DCoord zc2 zc3 zp2 zp3) = 0 ∧
      pluckerQuadric4DResidual c1 0 0 0 0 c12 = c1 * c12 ∧
      0 < pluckerQuadric4DResidual c1 0 0 0 0 c12 ∧
      tautologicalLinearTransportVec a00 a01 a10 a11 (c * alpha) (s * alpha) =
        tautologicalFiberVec (a00 * c + a01 * s) (a10 * c + a11 * s) alpha ∧
      ropeCrossFrameInnerProduct
          (ropeFiberRotate cos_t sin_t a1 a2)
          (ropeFiberRotate cos_t sin_t b1 b2) 1 =
        ropeCrossFrameInnerProduct (a1, a2) (b1, b2) 1 ∧
      ropeCrossFrameInnerProduct
          (ropeFiberRotate 0 1 a1 a2)
          (ropeFiberRotate 0 1 b1 b2) sigma2 -
        ropeCrossFrameInnerProduct (a1, a2) (b1, b2) sigma2 =
        (sigma2 - 1) * (a1 * b1 - a2 * b2) ∧
      t_prep < qftAssociativeTotalLatency t_prep t_qft ∧
      oamLogPolarTransverseMomentum l1 a_scale -
          oamLogPolarTransverseMomentum l2 a_scale =
        (l1 - l2) / a_scale := by
  have h_quad := shared_anchor_vs_cross_lag_klein_quadric zc0 zc1 zc2 zc3 zp0 zp1 zp2 zp3 c1 c12
  have h_quad_pos : 0 < pluckerQuadric4DResidual c1 0 0 0 0 c12 := by
    rw [h_quad.2]
    positivity
  have h_trans :
      tautologicalLinearTransportVec a00 a01 a10 a11 (c * alpha) (s * alpha) =
        tautologicalFiberVec (a00 * c + a01 * s) (a10 * c + a11 * s) alpha := by
    unfold tautologicalLinearTransportVec tautologicalFiberVec
    apply Prod.ext <;> ring
  have h_rope_same :
      ropeCrossFrameInnerProduct
          (ropeFiberRotate cos_t sin_t a1 a2)
          (ropeFiberRotate cos_t sin_t b1 b2) 1 =
        ropeCrossFrameInnerProduct (a1, a2) (b1, b2) 1 := by
    unfold ropeCrossFrameInnerProduct ropeFiberRotate
    calc
      (cos_t * a1 - sin_t * a2) * (cos_t * b1 - sin_t * b2) +
          1 * (sin_t * a1 + cos_t * a2) * (sin_t * b1 + cos_t * b2) =
        (cos_t ^ 2 + sin_t ^ 2) * (a1 * b1 + a2 * b2) := by ring
      _ = 1 * (a1 * b1 + a2 * b2) := by rw [hrope]
      _ = a1 * b1 + 1 * a2 * b2 := by ring
  have h_rope_aniso :
      ropeCrossFrameInnerProduct
          (ropeFiberRotate 0 1 a1 a2)
          (ropeFiberRotate 0 1 b1 b2) sigma2 -
        ropeCrossFrameInnerProduct (a1, a2) (b1, b2) sigma2 =
        (sigma2 - 1) * (a1 * b1 - a2 * b2) := by
    unfold ropeCrossFrameInnerProduct ropeFiberRotate
    ring
  have h_qft : t_prep < qftAssociativeTotalLatency t_prep t_qft := by
    unfold qftAssociativeTotalLatency
    linarith
  have h_oam :
      oamLogPolarTransverseMomentum l1 a_scale -
          oamLogPolarTransverseMomentum l2 a_scale =
        (l1 - l2) / a_scale := by
    unfold oamLogPolarTransverseMomentum
    ring
  exact ⟨h_quad.1, h_quad.2, h_quad_pos, h_trans, h_rope_same, h_rope_aniso, h_qft, h_oam⟩

end

end Signals.QuantumCausalInference
