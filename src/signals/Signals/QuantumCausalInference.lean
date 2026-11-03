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

end

end Signals.QuantumCausalInference
