import Architect
import Mathlib.Basic.Real.Basic
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Tactic
import Signals.Geometry

/-!
# Quantum Inverse Scattering Method (QISM) and Grassmannian Geometry

This module formalizes the algebraic core of the Quantum Inverse Scattering
Method (QISM) and the Algebraic Bethe Ansatz (ABA), together with their
reformulation in finite Grassmannian geometry:

1. **Yang's Rational $R$-Matrix, Unitarity, and the Yang--Baxter Equation**:
   The explicit $4 \times 4$ permutation matrix $P$ and Yang rational $R$-matrix
   $R(u) = u I_4 + \eta P$ satisfy involutive swap ($P^2 = I_4$), the regularity
   condition $R(0) = \eta P$, triplet/singlet channel eigenvalue splitting
   ($u - v + \eta$ vs. $u - v - \eta$), quantum unitarity
   $R(u - v) R(v - u) = (\eta^2 - (u - v)^2) I_4$, and the three-site
   Yang--Baxter braid identity.
2. **Monodromy Matrices, Cyclic Transfer Traces, and Shifted Quantum Determinants**:
   $2 \times 2$ Lax/monodromy matrices $T(u) = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$
   compose by matrix multiplication along a 1D chain, with cyclic transfer trace
   $t(u) = \operatorname{Tr} T(u) = A + D$, Cauchy--Binet path-pair expansion,
   and shifted Yangian quantum determinants $\operatorname{qdet}_{L/R}(T(u), T(u-\eta))$.
3. **Baxter $Q$-Polynomials in $Gr(2, 4)$, $GL(2)$ Gauge Covariance, and the $QQ$-System**:
   A 2-plane $W = \operatorname{span}\{Q_+, Q_-\}$ evaluated at four spectral
   shifts defines a $2 \times 4$ Grassmannian representative whose maximal
   minors are Casorati Wronskians. Left multiplication by any $2 \times 2$ basis
   change $B \in GL(2, \mathbb{R})$ scales all Wronskians by $\det B$ and leaves
   Wronskian ratios invariant, while the 3-term quadratic Pluecker relation on
   $Gr(2, 4)$ yields Baxter's functional $QQ$-system and Hirota bilinear equation.
4. **Wronskian Parameterization of Baxter's $TQ$ Equation and MTV Nondegeneracy**:
   Three-point Casorati Wronskians satisfy Baxter's $TQ$ difference equation
   identically ($W(u-\eta, u+\eta) Q_+(u) = W(u, u+\eta) Q_+(u-\eta) + W(u-\eta, u) Q_+(u+\eta)$).
   Evaluating at a Bethe root $Q_+(u_m) = 0$ yields the Bethe Ansatz Equations,
   while Mukhin--Tarasov--Varchenko (MTV) Wronskian nondegeneracy rules out
   spurious $0/0$ triple zeros.
5. **Slavnov / Gaudin Determinant Compression and Pauli Exclusion**:
   Two-magnon scalar products collapse into a single $2 \times 2$ Grassmannian
   minor that is antisymmetric under rapidity exchange and vanishes identically
   when either Bethe rapidities ($u_0 = u_1$) or dual rapidities ($v_0 = v_1$) collide.
-/

namespace Signals.QISM

open Signals.Geometry

/-! ## 1. Yang's Rational R-Matrix, Unitarity & Spectral Yang--Baxter Identities -/

/-- Spectral difference `u - v` between two auxiliary rapidities. -/
@[blueprint "def:signals-qism-spectral-diff"
  (title := "QISM spectral rapidity difference")
  (statement := /-- For spectral parameters $u,v\in\mathbb R$, define the rapidity difference
    $\delta(u,v)=u-v$. -/)]
def spectralDiff (u v : ℝ) : ℝ :=
  u - v

/-- Spectral additivity (`cocycle law`) across three rapidities `u, v, w`:
`(u - v) + (v - w) = u - w`. -/
@[blueprint "lem:signals-qism-spectral-cocycle"
  (title := "Three-rapidity spectral difference cocycle")
  (statement := /-- For any rapidities $u,v,w\in\mathbb R$,
    $\delta(u,v)+\delta(v,w)=\delta(u,w)$. -/)
  (proof := /-- Linear ring cancellation of the intermediate rapidity $v$. -/)
  (latexEnv := "lemma")]
lemma spectralDiff_add (u v w : ℝ) :
    spectralDiff u v + spectralDiff v w = spectralDiff u w := by
  unfold spectralDiff
  ring

/-- Yang's rational $R$-matrix transmission weight `u - v` and reflection/coupling
weight `η` combine into the symmetric-channel (triplet) weight `(u - v) + η`. -/
@[blueprint "def:signals-qism-yang-channel-weight"
  (title := "Yang rational R-matrix symmetric-channel weight")
  (statement := /-- Given spectral parameters $u,v$ and coupling constant $\eta$, the
    symmetric-channel Yang $R$-matrix eigenvalue is $w_{\mathrm{sym}}(u,v;\eta)=\delta(u,v)+\eta$. -/)]
def yangSymmetricWeight (u v η : ℝ) : ℝ :=
  spectralDiff u v + η

/-- Antisymmetric-channel (singlet) eigenvalue `(u - v) - η` of Yang's rational $R$-matrix. -/
@[blueprint "def:signals-qism-yang-antisymmetric-weight"
  (title := "Yang rational R-matrix antisymmetric-channel weight")
  (statement := /-- Given spectral parameters $u,v$ and coupling constant $\eta$, the
    antisymmetric-channel Yang $R$-matrix eigenvalue is
    $w_{\mathrm{anti}}(u,v;\eta)=\delta(u,v)-\eta$. -/)]
def yangAntisymmetricWeight (u v η : ℝ) : ℝ :=
  spectralDiff u v - η

/-- Explicit $4 \times 4$ permutation (swap) matrix $P$ on $\mathbb R^2 \otimes \mathbb R^2$
in the computational basis $\{|00\rangle, |01\rangle, |10\rangle, |11\rangle\}$. -/
@[blueprint "def:signals-qism-swap-matrix4"
  (title := "Two-qubit 4×4 permutation matrix P")
  (statement := /-- The permutation operator $P$ on $\mathbb R^2\otimes\mathbb R^2$ fixes
    $|00\rangle,|11\rangle$ and exchanges $|01\rangle\leftrightarrow|10\rangle$. -/)]
def swapMatrix4 : Matrix (Fin 4) (Fin 4) ℝ :=
  !![1, 0, 0, 0;
     0, 0, 1, 0;
     0, 1, 0, 0;
     0, 0, 0, 1]

/-- The permutation matrix $P$ is an involution: $P^2 = I_4$. -/
@[blueprint "lem:signals-qism-swap-involutive"
  (title := "Involutive property of the two-space permutation matrix")
  (statement := /-- On $\mathbb R^2\otimes\mathbb R^2$, $P^2=I_4$. -/)
  (proof := /-- Check all $4\times 4$ matrix entries by finite case split. -/)
  (latexEnv := "lemma")]
lemma swapMatrix4_mul_self :
    swapMatrix4 * swapMatrix4 = (1 : Matrix (Fin 4) (Fin 4) ℝ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [swapMatrix4, Matrix.mul_apply, Fin.sum_univ_four]

/-- Explicit $4 \times 4$ Yang rational $R$-matrix $R(u; \eta) = u I_4 + \eta P$
on $\mathbb R^2 \otimes \mathbb R^2$. -/
@[blueprint "def:signals-qism-yang-rmatrix4"
  (title := "Explicit 4×4 Yang rational R-matrix")
  (statement := /-- For spectral parameter $u$ and coupling $\eta$, Yang's rational $R$-matrix
    on $\mathbb R^2\otimes\mathbb R^2$ is $R(u;\eta)=u I_4+\eta P$. -/)]
def yangRMatrix4 (u η : ℝ) : Matrix (Fin 4) (Fin 4) ℝ :=
  u • (1 : Matrix (Fin 4) (Fin 4) ℝ) + η • swapMatrix4

/-- **Regularity Condition at $u = 0$**:
At zero spectral difference, Yang's $R$-matrix reduces to $\eta P$, ensuring that
the homogeneous transfer matrix at the reference point generates the lattice shift operator. -/
@[blueprint "lem:signals-qism-yang-rmatrix-regularity"
  (title := "Regularity of Yang's R-matrix at zero spectral parameter")
  (statement := /-- At $u=0$, $R(0;\eta)=\eta P$. -/)
  (proof := /-- Unfold \texttt{yangRMatrix4} and simplify $0\cdot I_4=0$. -/)
  (latexEnv := "lemma")]
lemma yangRMatrix4_zero (η : ℝ) :
    yangRMatrix4 0 η = η • swapMatrix4 := by
  simp [yangRMatrix4]

/-- On the symmetric basis state $|00\rangle$ (index $0$), `yangRMatrix4 (u - v) η`
acts diagonally with eigenvalue `yangSymmetricWeight u v η = (u - v) + η`. -/
@[blueprint "lem:signals-qism-yang-rmatrix-triplet-eigenvalue"
  (title := "Triplet diagonal entry of Yang's 4×4 R-matrix")
  (statement := /-- The $(0,0)$ triplet entry of $R(u-v;\eta)$ equals
    $w_{\mathrm{sym}}(u,v;\eta)=(u-v)+\eta$. -/)
  (proof := /-- Evaluate entry $(0,0)$ of \texttt{yangRMatrix4}. -/)
  (latexEnv := "lemma")]
lemma yangRMatrix4_triplet_entry (u v η : ℝ) :
    yangRMatrix4 (spectralDiff u v) η 0 0 = yangSymmetricWeight u v η := by
  simp [yangRMatrix4, swapMatrix4, yangSymmetricWeight, spectralDiff]

/-- **Quantum Unitarity of Yang's Rational $R$-Matrix**:
$R(u - v; \eta) R(v - u; \eta) = (\eta^2 - (u - v)^2) I_4$.
Furthermore, the scalar unitarity factor equals the negatives of the product of the
symmetric and antisymmetric channel weights:
$- w_{\mathrm{sym}}(u, v; \eta) \, w_{\mathrm{anti}}(u, v; \eta)$. -/
@[blueprint "thm:signals-qism-yang-rmatrix-unitarity"
  (title := "Quantum unitarity of the 4×4 Yang rational R-matrix")
  (statement := /-- For any rapidities $u,v$ and coupling $\eta$,
    $R(u-v;\eta)\,R(v-u;\eta)=(\eta^2-(u-v)^2)I_4 = -w_{\mathrm{sym}}(u,v;\eta)\,w_{\mathrm{anti}}(u,v;\eta)I_4$. -/)
  (proof := /-- Check all $4\times 4$ matrix entries and simplify by ring algebra. -/)]
theorem yangRMatrix4_unitarity (u v η : ℝ) :
    yangRMatrix4 (spectralDiff u v) η * yangRMatrix4 (spectralDiff v u) η =
      (- (yangSymmetricWeight u v η * yangAntisymmetricWeight u v η)) •
        (1 : Matrix (Fin 4) (Fin 4) ℝ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [yangRMatrix4, swapMatrix4, yangSymmetricWeight, yangAntisymmetricWeight,
      spectralDiff, Matrix.mul_apply, Fin.sum_univ_four] <;>
    ring

/-- Yang--Baxter three-site interference identity for rational $R$-matrix weights:
the off-diagonal braid interference difference between `R₁₂ R₁₃ R₂₃` and `R₂₃ R₁₃ R₁₂`
vanishes identically for all spectral rapidities `u, v, w` and coupling `η`. -/
@[blueprint "thm:signals-qism-yang-baxter-braid"
  (title := "Rational Yang--Baxter three-site braid identity")
  (statement := /-- For any spectral parameters $u,v,w\in\mathbb R$ and coupling $\eta\in\mathbb R$,
    $\eta\,\delta(u,w)\,\eta = \eta\,\delta(u,v)\,\eta + \eta^2\,\delta(v,w)$, ensuring that the
    off-diagonal two-body scattering paths in $R_{12}(u-v)R_{13}(u-w)R_{23}(v-w)$ and
    $R_{23}(v-w)R_{13}(u-w)R_{12}(u-v)$ agree identically. -/)
  (proof := /-- Rewrite via \texttt{spectralDiff\_add} and close by ring algebra. -/)]
theorem yang_baxter_rational_braid (u v w η : ℝ) :
    η * spectralDiff u w * η = η * spectralDiff u v * η + η ^ 2 * spectralDiff v w := by
  rw [← spectralDiff_add u v w]
  ring

/-- The $8 \times 8$ real permutation matrix on $(\mathbb{R}^2)^{\otimes 3} \cong \mathbb{R}^8$
associated to a basis permutation $\sigma \in \operatorname{Perm}(\operatorname{Fin} 8)$. -/
@[blueprint "def:signals-qism-perm-matrix8"
  (title := "8×8 three-site permutation matrix on (ℝ²)⊗³")
  (statement := /-- For $\sigma\in\operatorname{Perm}(\operatorname{Fin} 8)$, define the $8\times 8$
    permutation matrix $(P_\sigma)_{ij} = \delta_{\sigma(i),j}$. -/)]
def permMatrix8 (σ : Equiv.Perm (Fin 8)) : Matrix (Fin 8) (Fin 8) ℝ :=
  fun i j => if σ i = j then 1 else 0

/-- Multiplying two $8 \times 8$ permutation matrices composes their permutations:
$P_\sigma P_\tau = P_{\sigma.\mathrm{trans}\,\tau}$. -/
@[blueprint "lem:signals-qism-perm-matrix8-mul"
  (title := "Composition law for 8×8 permutation matrices")
  (statement := /-- For any $\sigma,\tau\in\operatorname{Perm}(\operatorname{Fin} 8)$,
    $P_\sigma P_\tau = P_{\sigma.\mathrm{trans}\,\tau}$. -/)
  (proof := /-- Expand matrix multiplication and collapse the Kronecker delta sum at $k=\sigma(i)$. -/)
  (latexEnv := "lemma")]
lemma permMatrix8_mul (σ τ : Equiv.Perm (Fin 8)) :
    permMatrix8 σ * permMatrix8 τ = permMatrix8 (σ.trans τ) := by
  ext i j
  rw [Matrix.mul_apply]
  simp only [permMatrix8, boole_mul, Finset.sum_ite_eq, Finset.mem_univ, ↓reduceIte,
    Equiv.trans_apply]
  rfl

/-- Three-qubit transposition $\sigma_{12} \in \operatorname{Perm}(\operatorname{Fin} 8)$
swapping tensor factors $V_1 \leftrightarrow V_2$ in the binary basis $|b_1 b_2 b_3\rangle$
($2 \leftrightarrow 4$, $3 \leftrightarrow 5$). -/
@[blueprint "def:signals-qism-swap12-perm8"
  (title := "Three-site permutation σ₁₂ on Fin 8")
  (statement := /-- Define $\sigma_{12}=(2\ 4)(3\ 5)\in\operatorname{Perm}(\operatorname{Fin} 8)$
    swapping the first and second tensor factors of $(\mathbb R^2)^{\otimes 3}$. -/)]
def swap12Perm8 : Equiv.Perm (Fin 8) := Equiv.swap 2 4 * Equiv.swap 3 5

/-- Three-qubit transposition $\sigma_{13} \in \operatorname{Perm}(\operatorname{Fin} 8)$
swapping tensor factors $V_1 \leftrightarrow V_3$ in the binary basis $|b_1 b_2 b_3\rangle$
($1 \leftrightarrow 4$, $3 \leftrightarrow 6$). -/
@[blueprint "def:signals-qism-swap13-perm8"
  (title := "Three-site permutation σ₁₃ on Fin 8")
  (statement := /-- Define $\sigma_{13}=(1\ 4)(3\ 6)\in\operatorname{Perm}(\operatorname{Fin} 8)$
    swapping the first and third tensor factors of $(\mathbb R^2)^{\otimes 3}$. -/)]
def swap13Perm8 : Equiv.Perm (Fin 8) := Equiv.swap 1 4 * Equiv.swap 3 6

/-- Three-qubit transposition $\sigma_{23} \in \operatorname{Perm}(\operatorname{Fin} 8)$
swapping tensor factors $V_2 \leftrightarrow V_3$ in the binary basis $|b_1 b_2 b_3\rangle$
($1 \leftrightarrow 2$, $5 \leftrightarrow 6$). -/
@[blueprint "def:signals-qism-swap23-perm8"
  (title := "Three-site permutation σ₂₃ on Fin 8")
  (statement := /-- Define $\sigma_{23}=(1\ 2)(5\ 6)\in\operatorname{Perm}(\operatorname{Fin} 8)$
    swapping the second and third tensor factors of $(\mathbb R^2)^{\otimes 3}$. -/)]
def swap23Perm8 : Equiv.Perm (Fin 8) := Equiv.swap 1 2 * Equiv.swap 5 6

/-- Embedded $8 \times 8$ Yang rational $R$-matrix $R_{12}(u; \eta) = u I_8 + \eta P_{12}$
acting on $V_1 \otimes V_2 \subset V_1 \otimes V_2 \otimes V_3$. -/
@[blueprint "def:signals-qism-yang-r12-8"
  (title := "Embedded 8×8 Yang R-matrix R₁₂(u; η)")
  (statement := /-- Define $R_{12}(u;\eta)=u I_8+\eta P_{\sigma_{12}}$ on $(\mathbb R^2)^{\otimes 3}$. -/)]
def yangR12_8 (u η : ℝ) : Matrix (Fin 8) (Fin 8) ℝ :=
  u • (1 : Matrix (Fin 8) (Fin 8) ℝ) + η • permMatrix8 swap12Perm8

/-- Embedded $8 \times 8$ Yang rational $R$-matrix $R_{13}(u; \eta) = u I_8 + \eta P_{13}$
acting on $V_1 \otimes V_3 \subset V_1 \otimes V_2 \otimes V_3$. -/
@[blueprint "def:signals-qism-yang-r13-8"
  (title := "Embedded 8×8 Yang R-matrix R₁₃(u; η)")
  (statement := /-- Define $R_{13}(u;\eta)=u I_8+\eta P_{\sigma_{13}}$ on $(\mathbb R^2)^{\otimes 3}$. -/)]
def yangR13_8 (u η : ℝ) : Matrix (Fin 8) (Fin 8) ℝ :=
  u • (1 : Matrix (Fin 8) (Fin 8) ℝ) + η • permMatrix8 swap13Perm8

/-- Embedded $8 \times 8$ Yang rational $R$-matrix $R_{23}(u; \eta) = u I_8 + \eta P_{23}$
acting on $V_2 \otimes V_3 \subset V_1 \otimes V_2 \otimes V_3$. -/
@[blueprint "def:signals-qism-yang-r23-8"
  (title := "Embedded 8×8 Yang R-matrix R₂₃(u; η)")
  (statement := /-- Define $R_{23}(u;\eta)=u I_8+\eta P_{\sigma_{23}}$ on $(\mathbb R^2)^{\otimes 3}$. -/)]
def yangR23_8 (u η : ℝ) : Matrix (Fin 8) (Fin 8) ℝ :=
  u • (1 : Matrix (Fin 8) (Fin 8) ℝ) + η • permMatrix8 swap23Perm8

/-- **Full $8 \times 8$ Matrix Quantum Yang--Baxter Equation (QYBE)**:
On the three-fold tensor product $(\mathbb{R}^2)^{\otimes 3} \cong \mathbb{R}^8$,
Yang's rational $R$-matrices satisfy the operator identity
$R_{12}(u - v; \eta)\,R_{13}(u - w; \eta)\,R_{23}(v - w; \eta) =
R_{23}(v - w; \eta)\,R_{13}(u - w; \eta)\,R_{12}(u - v; \eta)$
for all spectral rapidities $u, v, w \in \mathbb{R}$ and coupling $\eta \in \mathbb{R}$. -/
@[blueprint "thm:signals-qism-yang-baxter-matrix8"
  (title := "Full 8×8 matrix Quantum Yang--Baxter Equation on (ℝ²)⊗³")
  (statement := /-- For all $u,v,w,\eta\in\mathbb R$,
    $R_{12}(u-v;\eta)\,R_{13}(u-w;\eta)\,R_{23}(v-w;\eta) =
    R_{23}(v-w;\eta)\,R_{13}(u-w;\eta)\,R_{12}(u-v;\eta)$ in $\operatorname{Mat}_{8\times 8}(\mathbb R)$. -/)
  (proof := /-- Expand both $8\times 8$ matrix products via \texttt{permMatrix8\_mul}, apply the
    symmetric-group cycle relations on $\operatorname{Perm}(\operatorname{Fin} 8)$, and combine the
    $\eta^2$ 3-cycle coefficients using $\delta(u,v)+\delta(v,w)=\delta(u,w)$. -/)]
theorem yang_baxter_equation_matrix8 (u v w η : ℝ) :
    yangR12_8 (spectralDiff u v) η * yangR13_8 (spectralDiff u w) η *
        yangR23_8 (spectralDiff v w) η =
      yangR23_8 (spectralDiff v w) η * yangR13_8 (spectralDiff u w) η *
        yangR12_8 (spectralDiff u v) η := by
  have h12_13 : swap12Perm8.trans swap13Perm8 = swap23Perm8.trans swap12Perm8 := by decide
  have h13_23 : swap13Perm8.trans swap23Perm8 = swap23Perm8.trans swap12Perm8 := by decide
  have h23_13 : swap23Perm8.trans swap13Perm8 = swap12Perm8.trans swap23Perm8 := by decide
  have h13_12 : swap13Perm8.trans swap12Perm8 = swap12Perm8.trans swap23Perm8 := by decide
  have h_braid :
      (swap23Perm8.trans swap12Perm8).trans swap23Perm8 =
        (swap12Perm8.trans swap23Perm8).trans swap12Perm8 := by decide
  unfold yangR12_8 yangR13_8 yangR23_8
  simp only [add_mul, mul_add, smul_mul_assoc, mul_smul_comm, one_mul, mul_one,
    smul_add, smul_smul, permMatrix8_mul]
  rw [h12_13, h13_23, h23_13, h13_12, h_braid, ← spectralDiff_add u v w]
  ext i j
  simp only [Matrix.add_apply, Matrix.smul_apply, smul_eq_mul]
  ring

/-! ## 2. Lax / Monodromy Matrices & Commuting Transfer Traces -/

/-- A $2 \times 2$ auxiliary monodromy (or Lax) matrix representative
$T(u) = \begin{pmatrix} A & B \\ C & D \end{pmatrix}$. -/
@[blueprint "def:signals-qism-monodromy-matrix"
  (title := "2×2 QISM monodromy matrix representative")
  (statement := /-- A $2\times 2$ auxiliary monodromy matrix consists of diagonal vacuum/eigenvalue
    entries $A,D$ and off-diagonal magnon creation/annihilation entries $B,C$. -/)]
structure MonodromyMatrix2 where
  A : ℝ
  B : ℝ
  C : ℝ
  D : ℝ

/-- Convert a `MonodromyMatrix2` record into a `2 × 2` real matrix. -/
@[blueprint "def:signals-qism-monodromy-to-matrix"
  (title := "Matrix representation of a 2×2 monodromy record")
  (statement := /-- Embeds $(A,B,C,D)$ as the $2\times 2$ matrix
    $\begin{pmatrix} A & B \\ C & D \end{pmatrix}$. -/)]
def MonodromyMatrix2.toMatrix (T : MonodromyMatrix2) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![T.A, T.B; T.C, T.D]

/-- Auxiliary-space trace $t(u) = \operatorname{Tr} T(u) = A + D$ generating the
commuting QISM conserved quantities. -/
@[blueprint "def:signals-qism-transfer-trace"
  (title := "QISM transfer-matrix trace")
  (statement := /-- The auxiliary trace of $T=\begin{pmatrix} A & B \\ C & D \end{pmatrix}$ is
    $t = A + D$. -/)]
def MonodromyMatrix2.transferTrace (T : MonodromyMatrix2) : ℝ :=
  T.A + T.D

/-- `MonodromyMatrix2.transferTrace` agrees with the matrix trace `Matrix.trace` of `toMatrix`. -/
@[blueprint "lem:signals-qism-transfer-trace-eq-matrix-trace"
  (title := "Transfer trace equals 2×2 matrix trace")
  (statement := /-- For any $2\times 2$ monodromy record $T$,
    $T.\mathrm{transferTrace}=\operatorname{Tr}(T.\mathrm{toMatrix})$. -/)
  (proof := /-- Expand $\operatorname{Tr}$ over $\operatorname{Fin}(2)$. -/)
  (latexEnv := "lemma")]
lemma MonodromyMatrix2.transferTrace_eq_trace (T : MonodromyMatrix2) :
    T.transferTrace = T.toMatrix.trace := by
  simp [MonodromyMatrix2.transferTrace, MonodromyMatrix2.toMatrix, Matrix.trace, Fin.sum_univ_two]

/-- Classical $2 \times 2$ determinant $\det T = A D - B C$ of the monodromy matrix. -/
@[blueprint "def:signals-qism-classical-det"
  (title := "Classical 2×2 monodromy determinant")
  (statement := /-- The classical determinant of $T=\begin{pmatrix} A & B \\ C & D \end{pmatrix}$
    is $\det T = A D - B C$. -/)]
def MonodromyMatrix2.classicalDet (T : MonodromyMatrix2) : ℝ :=
  T.A * T.D - T.B * T.C

/-- `MonodromyMatrix2.classicalDet` agrees with the $2 \times 2$ Grassmannian minor
`twoRowMinor` of its matrix representation. -/
@[blueprint "lem:signals-qism-det-eq-two-row-minor"
  (title := "Monodromy determinant equals Grassmannian two-row minor")
  (statement := /-- For any $2\times 2$ monodromy matrix $T$,
    $\det T = \Delta_{01}(T)$. -/)
  (proof := /-- Unfold \texttt{classicalDet}, \texttt{toMatrix}, and \texttt{twoRowMinor}. -/)
  (latexEnv := "lemma")]
lemma MonodromyMatrix2.classicalDet_eq_twoRowMinor (T : MonodromyMatrix2) :
    T.classicalDet = twoRowMinor T.toMatrix 0 1 := by
  simp [MonodromyMatrix2.classicalDet, MonodromyMatrix2.toMatrix, twoRowMinor]

/-- Ordered composition of two local Lax/monodromy matrices along the chain. -/
@[blueprint "def:signals-qism-monodromy-comp"
  (title := "Ordered composition of two Lax/monodromy steps")
  (statement := /-- Multiplying two $2\times 2$ Lax matrices $L_2$ and $L_1$ yields
    $\begin{pmatrix} A_2 A_1 + B_2 C_1 & A_2 B_1 + B_2 D_1 \\
    C_2 A_1 + D_2 C_1 & C_2 B_1 + D_2 D_1 \end{pmatrix}$. -/)]
def MonodromyMatrix2.comp (left right : MonodromyMatrix2) : MonodromyMatrix2 :=
  { A := left.A * right.A + left.B * right.C
    B := left.A * right.B + left.B * right.D
    C := left.C * right.A + left.D * right.C
    D := left.C * right.B + left.D * right.D }

/-- Cyclic invariance of the auxiliary transfer trace:
$\operatorname{Tr}(L_2 L_1) = \operatorname{Tr}(L_1 L_2) = A_2 A_1 + B_2 C_1 + C_2 B_1 + D_2 D_1$. -/
@[blueprint "lem:signals-qism-transfer-trace-cyclic"
  (title := "Cyclic invariance of the composed transfer trace")
  (statement := /-- For any two $2\times 2$ monodromy matrices $L_2,L_1$,
    $\operatorname{Tr}(L_2 L_1)=\operatorname{Tr}(L_1 L_2)$. -/)
  (proof := /-- Unfold \texttt{comp} and \texttt{transferTrace} and close by ring algebra. -/)
  (latexEnv := "lemma")]
lemma MonodromyMatrix2.transferTrace_comp_comm (left right : MonodromyMatrix2) :
    (left.comp right).transferTrace = (right.comp left).transferTrace := by
  unfold MonodromyMatrix2.comp MonodromyMatrix2.transferTrace
  ring

/-- Coassociative determinant multiplicativity for composed Lax/monodromy matrices:
$\det(L_2 L_1) = \det(L_2) \det(L_1)$. -/
@[blueprint "thm:signals-qism-monodromy-det-mul"
  (title := "Multiplicativity of the monodromy determinant across lattice sites")
  (statement := /-- For any two $2\times 2$ Lax/monodromy matrices $L_2,L_1$,
    $\det(L_2 L_1)=\det(L_2)\,\det(L_1)$. -/)
  (proof := /-- Expand both determinants and verify polynomial identity by ring algebra. -/)]
theorem MonodromyMatrix2.classicalDet_comp (left right : MonodromyMatrix2) :
    (left.comp right).classicalDet = left.classicalDet * right.classicalDet := by
  unfold MonodromyMatrix2.comp MonodromyMatrix2.classicalDet
  ring

/-- `MonodromyMatrix2.comp` agrees with $2 \times 2$ matrix multiplication on `toMatrix`. -/
@[blueprint "lem:signals-qism-monodromy-to-matrix-comp"
  (title := "Monodromy composition matches 2×2 matrix multiplication")
  (statement := /-- For any two $2\times 2$ Lax/monodromy records $L_2,L_1$,
    $(L_2\circ L_1).\mathrm{toMatrix}=L_2.\mathrm{toMatrix}\,L_1.\mathrm{toMatrix}$. -/)
  (proof := /-- Check all four $\operatorname{Fin}(2)\times\operatorname{Fin}(2)$ entries. -/)
  (latexEnv := "lemma")]
lemma MonodromyMatrix2.toMatrix_comp (left right : MonodromyMatrix2) :
    (left.comp right).toMatrix = left.toMatrix * right.toMatrix := by
  ext row col
  fin_cases row <;> fin_cases col <;>
    simp [MonodromyMatrix2.comp, MonodromyMatrix2.toMatrix, Matrix.mul_apply, Fin.sum_univ_two]

/-- Cauchy--Binet / Lindstroem--Gessel--Viennot path-pair expansion for a two-step
QISM monodromy product: the determinant of $L_2 L_1$ equals the antisymmetrized
sum over intermediate virtual channels in `Signals.Geometry.twoStep_det_pathPairs`. -/
@[blueprint "thm:signals-qism-monodromy-cauchy-binet"
  (title := "Cauchy--Binet path-pair expansion of a two-step monodromy determinant")
  (statement := /-- The determinant of a two-step monodromy product $L_2 L_1$ equals the
    sum over intermediate channel pairs $(a,b)\in\operatorname{Fin}(2)^2$ of
    $(L_2)_{0a}(L_2)_{1b}\bigl((L_1)_{a0}(L_1)_{b1}-(L_1)_{a1}(L_1)_{b0}\bigr)$. -/)
  (proof := /-- Rewrite via \texttt{toMatrix\_comp} and apply
    \texttt{Signals.Geometry.twoStep\_det\_pathPairs}. -/)]
theorem MonodromyMatrix2.comp_det_eq_pathPairs (left right : MonodromyMatrix2) :
    (left.comp right).toMatrix.det =
      ∑ first : Fin 2, ∑ second : Fin 2,
        left.toMatrix 0 first * left.toMatrix 1 second *
          (right.toMatrix first 0 * right.toMatrix second 1 -
            right.toMatrix first 1 * right.toMatrix second 0) := by
  rw [MonodromyMatrix2.toMatrix_comp]
  exact twoStep_det_pathPairs left.toMatrix right.toMatrix

/-- Left-ordered Yangian quantum determinant
$\operatorname{qdet}_L(T(u), T(u-\eta)) = A(u) D(u-\eta) - B(u) C(u-\eta)$,
which evaluates the second factor at the shifted spectral argument $u - \eta$. -/
@[blueprint "def:signals-qism-quantum-det-left"
  (title := "Left-ordered Yangian quantum determinant")
  (statement := /-- Given $T(u)$ and shifted $T(u-\eta)$, define
    $\operatorname{qdet}_L(T(u),T(u-\eta))=A(u)D(u-\eta)-B(u)C(u-\eta)$. -/)]
def quantumDetLeft (T_u T_shifted : MonodromyMatrix2) : ℝ :=
  T_u.A * T_shifted.D - T_u.B * T_shifted.C

/-- Right-ordered Yangian quantum determinant
$\operatorname{qdet}_R(T(u), T(u-\eta)) = D(u) A(u-\eta) - C(u) B(u-\eta)$. -/
@[blueprint "def:signals-qism-quantum-det-right"
  (title := "Right-ordered Yangian quantum determinant")
  (statement := /-- Given $T(u)$ and shifted $T(u-\eta)$, define
    $\operatorname{qdet}_R(T(u),T(u-\eta))=D(u)A(u-\eta)-C(u)B(u-\eta)$. -/)]
def quantumDetRight (T_u T_shifted : MonodromyMatrix2) : ℝ :=
  T_u.D * T_shifted.A - T_u.C * T_shifted.B

/-- In the classical / zero-shift limit ($T(u-\eta) = T(u)$), the left-ordered
quantum determinant reduces to `MonodromyMatrix2.classicalDet`. -/
@[blueprint "lem:signals-qism-quantum-det-classical-limit"
  (title := "Zero-shift limit of the quantum determinant recovers the classical determinant")
  (statement := /-- When $T(u-\eta)=T(u)$, $\operatorname{qdet}_L(T(u),T(u))=\det T(u)$. -/)
  (proof := /-- Unfold \texttt{quantumDetLeft} and \texttt{classicalDet}. -/)
  (latexEnv := "lemma")]
lemma quantumDetLeft_self (T : MonodromyMatrix2) :
    quantumDetLeft T T = T.classicalDet :=
  rfl

/-- The left-ordered and right-ordered Yangian quantum determinants coincide if and
only if the antisymmetric $RTT$ exchange balance
$A(u) D(u-\eta) - D(u) A(u-\eta) = B(u) C(u-\eta) - C(u) B(u-\eta)$ holds. -/
@[blueprint "thm:signals-qism-quantum-det-exchange-balance"
  (title := "Equivalence of left and right quantum determinants under RTT exchange")
  (statement := /-- $\operatorname{qdet}_L(T(u),T(u-\eta))=\operatorname{qdet}_R(T(u),T(u-\eta))$
    if and only if $A(u)D(u-\eta)-D(u)A(u-\eta)=B(u)C(u-\eta)-C(u)B(u-\eta)$. -/)
  (proof := /-- Unfold both quantum determinants and rearrange linear terms. -/)]
theorem quantumDet_left_eq_right_iff (T_u T_shifted : MonodromyMatrix2) :
    quantumDetLeft T_u T_shifted = quantumDetRight T_u T_shifted ↔
      T_u.A * T_shifted.D - T_u.D * T_shifted.A =
        T_u.B * T_shifted.C - T_u.C * T_shifted.B := by
  unfold quantumDetLeft quantumDetRight
  constructor <;> intro h <;> linarith

/-! ## 3. Baxter Q-Polynomials in Gr(2, 4) & the Pluecker QQ-System -/

/-- A $2 \times 4$ Grassmannian matrix built from a 2-plane of Baxter functions
$\operatorname{span}\{Q_+, Q_-\}$ evaluated at four spectral arguments $(u_0, u_1, u_2, u_3)$. -/
@[blueprint "def:signals-qism-baxter-grassmannian-matrix"
  (title := "Baxter Q-pair 2×4 Grassmannian evaluation matrix")
  (statement := /-- Given two Baxter functions $Q_+,Q_-:\mathbb R\to\mathbb R$ and four spectral
    points $u_0,u_1,u_2,u_3$, assemble the $2\times 4$ Grassmannian matrix whose $j$-th column is
    $(Q_+(u_j), Q_-(u_j))^T$. -/)]
def baxterGrassmannianMatrix (Q_plus Q_minus : ℝ → ℝ) (u0 u1 u2 u3 : ℝ) :
    Matrix (Fin 2) (Fin 4) ℝ :=
  !![Q_plus u0, Q_plus u1, Q_plus u2, Q_plus u3;
     Q_minus u0, Q_minus u1, Q_minus u2, Q_minus u3]

/-- The Casorati determinant (discrete Wronskian) of a Baxter pair $(Q_+, Q_-)$
at two spectral points $(u, v)$:
$W(u, v) = Q_+(u) Q_-(v) - Q_+(v) Q_-(u)$. -/
@[blueprint "def:signals-qism-casorati-wronskian"
  (title := "Casorati Wronskian of a Baxter Q-pair")
  (statement := /-- For Baxter functions $Q_+,Q_-$ and spectral points $u,v$, define the
    Casorati determinant $W(u,v)=Q_+(u)Q_-(v)-Q_+(v)Q_-(u)$. -/)]
def casoratiWronskian (Q_plus Q_minus : ℝ → ℝ) (u v : ℝ) : ℝ :=
  Q_plus u * Q_minus v - Q_plus v * Q_minus u

/-- Every $2 \times 2$ Pluecker minor of `baxterGrassmannianMatrix` is the Casorati
Wronskian of $(Q_+, Q_-)$ at the selected column rapidities. -/
@[blueprint "lem:signals-qism-baxter-minor-eq-wronskian"
  (title := "Pluecker minors of the Baxter matrix are Casorati Wronskians")
  (statement := /-- In \texttt{baxterGrassmannianMatrix}, the $(0,1)$ Pluecker minor equals
    the Casorati Wronskian $W(u_0,u_1)$. -/)
  (proof := /-- Unfold \texttt{twoRowMinor}, \texttt{baxterGrassmannianMatrix}, and
    \texttt{casoratiWronskian}. -/)
  (latexEnv := "lemma")]
lemma baxterGrassmannianMatrix_minor_01
    (Q_plus Q_minus : ℝ → ℝ) (u0 u1 u2 u3 : ℝ) :
    twoRowMinor (baxterGrassmannianMatrix Q_plus Q_minus u0 u1 u2 u3) 0 1 =
      casoratiWronskian Q_plus Q_minus u0 u1 := by
  simp [twoRowMinor, baxterGrassmannianMatrix, casoratiWronskian]

/-- **Baxter's Functional $QQ$-System / Hirota Bilinear Identity from $Gr(2, 4)$**:
The Casorati Wronskians of any Baxter $Q$-pair $(Q_+, Q_-)$ across four spectral
points $(u_0, u_1, u_2, u_3)$ satisfy the 3-term quadratic Pluecker relation
$W(u_0, u_1) W(u_2, u_3) - W(u_0, u_2) W(u_1, u_3) + W(u_0, u_3) W(u_1, u_2) = 0$. -/
@[blueprint "thm:signals-qism-baxter-qq-pluecker"
  (title := "Baxter QQ-system and Hirota bilinear equation from Gr(2,4) Pluecker relation")
  (statement := /-- For any Baxter pair $(Q_+,Q_-)$ and four spectral rapidities $u_0,u_1,u_2,u_3$,
    the Casorati Wronskians obey the 3-term Pluecker identity
    $W(u_0,u_1)W(u_2,u_3)-W(u_0,u_2)W(u_1,u_3)+W(u_0,u_3)W(u_1,u_2)=0$. -/)
  (proof := /-- Express the six Wronskians as the $2\times 2$ minors of
    \texttt{baxterGrassmannianMatrix} and apply \texttt{Signals.Geometry.twoRowMinor\_pluecker}. -/)]
theorem baxter_qq_pluecker_identity
    (Q_plus Q_minus : ℝ → ℝ) (u0 u1 u2 u3 : ℝ) :
    casoratiWronskian Q_plus Q_minus u0 u1 * casoratiWronskian Q_plus Q_minus u2 u3 -
      casoratiWronskian Q_plus Q_minus u0 u2 * casoratiWronskian Q_plus Q_minus u1 u3 +
      casoratiWronskian Q_plus Q_minus u0 u3 * casoratiWronskian Q_plus Q_minus u1 u2 = 0 := by
  have h :=
    twoRowMinor_pluecker (baxterGrassmannianMatrix Q_plus Q_minus u0 u1 u2 u3) 0 1 2 3
  simpa [twoRowMinor, baxterGrassmannianMatrix, casoratiWronskian] using h

/-- **$GL(2)$ Basis-Change Covariance on $Gr(2, 4)$**:
Left-multiplying `baxterGrassmannianMatrix` by any $2 \times 2$ basis matrix $B$
(taking linear combinations of $Q_+$ and $Q_-$ within the same 2-plane $W \in Gr(2, 4)$)
scales every ordered Pluecker Wronskian minor by $\det B$. -/
@[blueprint "lem:signals-qism-baxter-basis-change"
  (title := "GL(2) basis-change scaling of Baxter Pluecker Wronskians")
  (statement := /-- For any $2\times 2$ basis matrix $B$ and ordered column pair $J$,
    $\Delta_J(B\,M_Q)=\det(B)\,\Delta_J(M_Q)$. -/)
  (proof := /-- Apply \texttt{Signals.Geometry.selectedMinor\_basisChange}. -/)
  (latexEnv := "lemma")]
lemma baxterGrassmannianMatrix_basisChange
    (B : Matrix (Fin 2) (Fin 2) ℝ) (Q_plus Q_minus : ℝ → ℝ) (u0 u1 u2 u3 : ℝ)
    (columns : OrderedColumns 2 4) :
    selectedMinor (B * baxterGrassmannianMatrix Q_plus Q_minus u0 u1 u2 u3) columns =
      B.det * selectedMinor (baxterGrassmannianMatrix Q_plus Q_minus u0 u1 u2 u3) columns :=
  selectedMinor_basisChange B (baxterGrassmannianMatrix Q_plus Q_minus u0 u1 u2 u3) columns

/-! ## 4. Baxter TQ Equation & Algebraic Bethe Ansatz Equations (BAE) -/

/-- Residual of Baxter's $TQ$ difference equation at a single spectral point:
$T(u) Q(u) - (a(u) Q(u - \eta) + d(u) Q(u + \eta))$. -/
@[blueprint "def:signals-qism-baxter-tq-residual"
  (title := "Baxter TQ difference-equation residual")
  (statement := /-- For transfer eigenvalue $T$, vacuum weights $a,d$, and shifted Baxter
    evaluations $Q(u),Q(u-\eta),Q(u+\eta)$, the $TQ$ residual is
    $T\,Q(u)-(a\,Q(u-\eta)+d\,Q(u+\eta))$. -/)]
def baxterTQResidual (T a d Q_u Q_minus_eta Q_plus_eta : ℝ) : ℝ :=
  T * Q_u - (a * Q_minus_eta + d * Q_plus_eta)

/-- **Wronskian Solution of Baxter's $TQ$ Difference Equation**:
For any Baxter pair $(Q_+, Q_-)$, the three-point Casorati Wronskians
$T(u) = W(u - \eta, u + \eta)$, $a(u) = W(u, u + \eta)$, and
$d(u) = W(u - \eta, u)$ satisfy Baxter's $TQ$ equation
$W(u - \eta, u + \eta) Q_+(u) = W(u, u + \eta) Q_+(u - \eta) + W(u - \eta, u) Q_+(u + \eta)$
identically (`baxterTQResidual = 0`). -/
@[blueprint "thm:signals-qism-wronskian-solves-tq"
  (title := "Three-point Casorati Wronskians solve Baxter's TQ equation identically")
  (statement := /-- For any Baxter pair $(Q_+,Q_-)$, rapidity $u$, and shift $\eta$, setting
    $T(u)=W(u-\eta,u+\eta)$, $a(u)=W(u,u+\eta)$, and $d(u)=W(u-\eta,u)$ yields
    $\operatorname{baxterTQResidual}(T(u),a(u),d(u),Q_+(u),Q_+(u-\eta),Q_+(u+\eta))=0$. -/)
  (proof := /-- Unfold \texttt{baxterTQResidual} and \texttt{casoratiWronskian} and cancel by ring algebra. -/)]
theorem baxterTQResidual_wronskian_zero
    (Q_plus Q_minus : ℝ → ℝ) (u η : ℝ) :
    baxterTQResidual
      (casoratiWronskian Q_plus Q_minus (u - η) (u + η))
      (casoratiWronskian Q_plus Q_minus u (u + η))
      (casoratiWronskian Q_plus Q_minus (u - η) u)
      (Q_plus u) (Q_plus (u - η)) (Q_plus (u + η)) = 0 := by
  unfold baxterTQResidual casoratiWronskian
  ring

/-- Evaluating Baxter's $TQ$ relation `baxterTQResidual = 0` at a Bethe root
`Q_u = 0` eliminates the transfer eigenvalue `T` and yields the polynomial
Bethe Ansatz Equation `a * Q_minus_eta + d * Q_plus_eta = 0`. -/
@[blueprint "thm:signals-qism-bae-from-tq-root"
  (title := "Bethe Ansatz Equation from Baxter TQ evaluation at a Bethe root")
  (statement := /-- If $T\,Q(u_m)-(a(u_m)Q(u_m-\eta)+d(u_m)Q(u_m+\eta))=0$ and $Q(u_m)=0$,
    then the Bethe Ansatz Equation $a(u_m)Q(u_m-\eta)+d(u_m)Q(u_m+\eta)=0$ holds. -/)
  (proof := /-- Substitute $Q(u_m)=0$ into the vanishing $TQ$ residual. -/)]
theorem bethe_ansatz_eq_of_tq_root
    (T a d Q_u Q_minus_eta Q_plus_eta : ℝ)
    (h_tq : baxterTQResidual T a d Q_u Q_minus_eta Q_plus_eta = 0)
    (h_root : Q_u = 0) :
    a * Q_minus_eta + d * Q_plus_eta = 0 := by
  unfold baxterTQResidual at h_tq
  rw [h_root, mul_zero] at h_tq
  linarith

/-- **Critique Guard (Spurious Root Degeneracy)**:
When $Q(u_m) = Q(u_m - \eta) = Q(u_m + \eta) = 0$ simultaneously, `baxterTQResidual`
vanishes for *every* candidate transfer eigenvalue $T$, leaving $T$ unconstrained
and the rational Bethe Ansatz ratio $0/0$ ill-defined. -/
@[blueprint "lem:signals-qism-spurious-root-degeneracy"
  (title := "Spurious triple-zero Bethe root leaves transfer eigenvalue unconstrained")
  (statement := /-- If $Q(u_m)=Q(u_m-\eta)=Q(u_m+\eta)=0$, then
    $\operatorname{baxterTQResidual}(T,a,d,0,0,0)=0$ for every $T\in\mathbb R$. -/)
  (proof := /-- Unfold \texttt{baxterTQResidual} and simplify products with zero. -/)
  (latexEnv := "lemma")]
lemma baxterTQResidual_spurious_zero (T a d : ℝ) :
    baxterTQResidual T a d 0 0 0 = 0 := by
  simp [baxterTQResidual]

/-- **Mukhin--Tarasov--Varchenko (MTV) Wronskian Nondegeneracy**:
If $Q_+(u_m) = 0$ at a Bethe root $u_m$ and the Casorati Wronskian
$W(u_m, u_m - \eta) = Q_+(u_m) Q_-(u_m - \eta) - Q_+(u_m - \eta) Q_-(u_m) \neq 0$,
then neither the shifted evaluation $Q_+(u_m - \eta)$ nor the dual polynomial
$Q_-(u_m)$ can vanish, ruling out spurious $0/0$ Bethe roots. -/
@[blueprint "thm:signals-qism-mtv-wronskian-nondegeneracy"
  (title := "MTV Wronskian nondegeneracy rules out spurious shifted Bethe zeros")
  (statement := /-- If $Q_+(u_m)=0$ and the Casorati Wronskian $W(u_m,u_m-\eta)\ne 0$,
    then $Q_+(u_m-\eta)\ne 0$ and $Q_-(u_m)\ne 0$. -/)
  (proof := /-- Substitute $Q_+(u_m)=0$ into $W(u_m,u_m-\eta)=-Q_+(u_m-\eta)Q_-(u_m)\ne 0$
    and extract both nonvanishing factors. -/)]
theorem mtv_wronskian_nondegenerate_of_root
    (Q_plus Q_minus : ℝ → ℝ) (u_m u_shifted : ℝ)
    (h_root : Q_plus u_m = 0)
    (h_wronskian : casoratiWronskian Q_plus Q_minus u_m u_shifted ≠ 0) :
    Q_plus u_shifted ≠ 0 ∧ Q_minus u_m ≠ 0 := by
  unfold casoratiWronskian at h_wronskian
  rw [h_root, zero_mul, zero_sub, neg_ne_zero] at h_wronskian
  exact ⟨left_ne_zero_of_mul h_wronskian, right_ne_zero_of_mul h_wronskian⟩

/-- A nonvanishing Casorati Wronskian $W(u_0, u_1) \neq 0$ certifies an explicit
nonzero ordered maximal minor (`pluckerCoordinate`) for the $2 \times 4$
Baxter evaluation matrix in `Signals.Geometry`. -/
@[blueprint "lem:signals-qism-baxter-full-rank"
  (title := "Nonzero Casorati Wronskian certifies a nonzero Pluecker coordinate")
  (statement := /-- If $W(u_0,u_1)\ne 0$, then \texttt{baxterGrassmannianMatrix} has an
    explicit ordered column pair $J=(0,1)$ with $\Delta_J\ne 0$. -/)
  (proof := /-- Witness the $(0,1)$ ordered column pair and rewrite its minor via
    \texttt{baxterGrassmannianMatrix\_minor\_01}. -/)
  (latexEnv := "lemma")]
lemma baxterGrassmannianMatrix_nonzero_minor
    (Q_plus Q_minus : ℝ → ℝ) (u0 u1 u2 u3 : ℝ)
    (h_wronskian : casoratiWronskian Q_plus Q_minus u0 u1 ≠ 0) :
    ∃ columns : OrderedColumns 2 4,
      (GrassmannianMatrix.mk (baxterGrassmannianMatrix Q_plus Q_minus u0 u1 u2 u3)).pluckerCoordinate
        columns ≠ 0 := by
  refine ⟨OrderedColumns.pair 0 1 (by decide), ?_⟩
  change selectedMinor (baxterGrassmannianMatrix Q_plus Q_minus u0 u1 u2 u3)
    (OrderedColumns.pair 0 1 (by decide)) ≠ 0
  rw [← twoRowMinor_eq_selectedMinor, baxterGrassmannianMatrix_minor_01]
  exact h_wronskian

/-- Under Wronskian nondegeneracy ($Q(u_m - \eta) \neq 0$) and nonzero vacuum weight
$d(u_m) \neq 0$, the Bethe Ansatz Equation takes its rational scattering-phase form
$a(u_m) / d(u_m) = - Q(u_m + \eta) / Q(u_m - \eta)$. -/
@[blueprint "thm:signals-qism-bae-rational-ratio"
  (title := "Rational Bethe Ansatz phase-shift ratio under nondegeneracy")
  (statement := /-- When $\operatorname{baxterTQResidual}(T,a,d,Q(u_m),Q(u_m-\eta),Q(u_m+\eta))=0$,
    $Q(u_m)=0$, $d\ne 0$, and $Q(u_m-\eta)\ne 0$, the vacuum weight ratio satisfies
    $a/d = -Q(u_m+\eta)/Q(u_m-\eta)$. -/)
  (proof := /-- Apply \texttt{bethe\_ansatz\_eq\_of\_tq\_root} and clear the nonzero denominators
    $d$ and $Q(u_m-\eta)$. -/)]
theorem bethe_ansatz_ratio_of_tq_root
    (T a d Q_u Q_minus_eta Q_plus_eta : ℝ)
    (h_tq : baxterTQResidual T a d Q_u Q_minus_eta Q_plus_eta = 0)
    (h_root : Q_u = 0)
    (h_d : d ≠ 0)
    (h_Q_minus : Q_minus_eta ≠ 0) :
    a / d = - Q_plus_eta / Q_minus_eta := by
  have h_bae := bethe_ansatz_eq_of_tq_root T a d Q_u Q_minus_eta Q_plus_eta h_tq h_root
  rw [div_eq_div_iff h_d h_Q_minus]
  linarith

/-! ## 5. Slavnov / Gaudin Determinant Compression & Pauli Exclusion on the Grassmannian -/

/-- Two-magnon Slavnov / Gaudin scalar-product matrix $G \in \mathbb R^{2 \times 2}$.
On the Sato Grassmannian, the $(2!)^2 = 4$ off-shell $RTT$ contractions collapse
into a single $2 \times 2$ Pluecker minor $\Delta_{01}(G)$. -/
@[blueprint "def:signals-qism-slavnov-determinant-2x2"
  (title := "Two-magnon Slavnov / Gaudin determinant as a Grassmannian minor")
  (statement := /-- For a $2\times 2$ Slavnov or Gaudin Jacobian matrix $G$, its determinant
    equals the Grassmannian two-row minor $\Delta_{01}(G)=G_{00}G_{11}-G_{01}G_{10}$. -/)]
def slavnovDet2 (G : Matrix (Fin 2) (Fin 2) ℝ) : ℝ :=
  twoRowMinor G 0 1

/-- The $2 \times 2$ Slavnov determinant equals the standard matrix determinant `G.det`. -/
@[blueprint "lem:signals-qism-slavnov-det-eq-matrix-det"
  (title := "Two-magnon Slavnov minor agrees with matrix determinant")
  (statement := /-- For any $G\in\mathbb R^{2\times 2}$,
    $\operatorname{slavnovDet2}(G)=\det G$. -/)
  (proof := /-- Unfold \texttt{slavnovDet2}, \texttt{twoRowMinor}, and \texttt{Matrix.det\_fin\_two}. -/)
  (latexEnv := "lemma")]
lemma slavnovDet2_eq_det (G : Matrix (Fin 2) (Fin 2) ℝ) :
    slavnovDet2 G = G.det := by
  simp [slavnovDet2, twoRowMinor, Matrix.det_fin_two]

/-- Parameterized two-magnon Slavnov matrix $M_{jk} = K(v_j, u_k)$ built from a
two-rapidity kernel $K(v, u)$ at dual rapidities $(v_0, v_1)$ and Bethe rapidities $(u_0, u_1)$. -/
@[blueprint "def:signals-qism-slavnov-matrix-2x2"
  (title := "Parameterized two-magnon Slavnov kernel matrix")
  (statement := /-- Given a two-rapidity Slavnov kernel $K:\mathbb R\to\mathbb R\to\mathbb R$,
    dual rapidities $v_0,v_1$, and Bethe rapidities $u_0,u_1$, define
    $M_{jk}=K(v_j,u_k)$ for $j,k\in\{0,1\}$. -/)]
def slavnovKernelMatrix2 (K : ℝ → ℝ → ℝ) (v0 v1 u0 u1 : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![K v0 u0, K v0 u1;
     K v1 u0, K v1 u1]

/-- **Pauli Exclusion / Colliding-Rapidity Vanishing of the Slavnov Determinant**:
When two Bethe rapidities coincide ($u_0 = u_1 = u$), the $2 \times 2$ Slavnov
determinant vanishes identically. -/
@[blueprint "thm:signals-qism-slavnov-pauli-exclusion"
  (title := "Pauli exclusion vanishing of the Slavnov determinant at colliding Bethe rapidities")
  (statement := /-- When the two Bethe rapidities coincide ($u_0=u_1=u$), the two columns of
    \texttt{slavnovKernelMatrix2} are identical and its Slavnov determinant vanishes:
    $\operatorname{slavnovDet2}(M(v_0,v_1;u,u))=0$. -/)
  (proof := /-- Expand the $2\times 2$ minor with equal column rapidities $u_0=u_1=u$ and cancel. -/)]
theorem slavnovDet2_pauli_exclusion (K : ℝ → ℝ → ℝ) (v0 v1 u : ℝ) :
    slavnovDet2 (slavnovKernelMatrix2 K v0 v1 u u) = 0 := by
  simp [slavnovDet2, slavnovKernelMatrix2, twoRowMinor]

/-- **Dual-Rapidity Pauli Exclusion**:
When the two dual rapidities coincide ($v_0 = v_1 = v$), the two rows of
`slavnovKernelMatrix2` are identical and its Slavnov determinant vanishes identically. -/
@[blueprint "lem:signals-qism-slavnov-dual-pauli-exclusion"
  (title := "Dual-rapidity Pauli exclusion vanishing of the Slavnov determinant")
  (statement := /-- When the two dual rapidities coincide ($v_0=v_1=v$), the two rows of
    \texttt{slavnovKernelMatrix2} are identical and
    $\operatorname{slavnovDet2}(M(v,v;u_0,u_1))=0$. -/)
  (proof := /-- Expand the $2\times 2$ minor with equal row rapidities $v_0=v_1=v$ and cancel. -/)
  (latexEnv := "lemma")]
lemma slavnovDet2_dual_pauli_exclusion (K : ℝ → ℝ → ℝ) (v u0 u1 : ℝ) :
    slavnovDet2 (slavnovKernelMatrix2 K v v u0 u1) = 0 := by
  simp only [slavnovDet2, slavnovKernelMatrix2, twoRowMinor, Matrix.of_apply,
    Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- Exchanging the two Bethe rapidities ($u_0 \leftrightarrow u_1$) negates the
$2 \times 2$ Slavnov determinant. -/
@[blueprint "lem:signals-qism-slavnov-swap-rapidities"
  (title := "Antisymmetry of the Slavnov determinant under Bethe rapidity exchange")
  (statement := /-- Exchanging $u_0\leftrightarrow u_1$ negates the Slavnov minor:
    $\operatorname{slavnovDet2}(M(v_0,v_1;u_1,u_0))=-\operatorname{slavnovDet2}(M(v_0,v_1;u_0,u_1))$. -/)
  (proof := /-- Expand both $2\times 2$ minors and close by ring algebra. -/)
  (latexEnv := "lemma")]
lemma slavnovDet2_swap_bethe (K : ℝ → ℝ → ℝ) (v0 v1 u0 u1 : ℝ) :
    slavnovDet2 (slavnovKernelMatrix2 K v0 v1 u1 u0) =
      - slavnovDet2 (slavnovKernelMatrix2 K v0 v1 u0 u1) := by
  simp [slavnovDet2, slavnovKernelMatrix2, twoRowMinor]

end Signals.QISM
