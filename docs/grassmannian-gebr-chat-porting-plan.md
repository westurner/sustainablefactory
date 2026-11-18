---
title: "Grassmannian EBR Chat-Code Porting Ledger and Phased Implementation Plan"
description: "Source-ordered audit of 64 code fences from Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md and phased implementation plan (WS-0 through WS-9) across Lean 4, Rust/PyO3 (maturin), Python/SymPy, and MyST documentation."
---

(grassmannian-gebr-chat-porting-plan)=
# Grassmannian EBR Chat-Code Porting Ledger

This engineering note and implementation plan records the ordered review and port of code fences in
`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`.
The source-line column points to each fence's opening line. The 64 blocks were
extracted in source order to `.tmp/chat-code-blocks/` with a numbered filename
and a TSV manifest. Re-running the extraction from the source export reproduces
that local working archive. The inventory contains 19 Lean, 3 Rust, 12 Python,
5 diff, 5 Markdown, 16 plain-text, 2 shell, 1 BibTeX, and 1 LaTeX block.

This is not an independent scholarly or experimental validation of the claims
in the chat. The disposition terms mean:

- **Ported**: corrected finite math or a working bounded implementation was
  added to the Signals source.
- **Reused**: an existing Signals definition or test already owns the behavior;
  no duplicate declaration was added.
- **Replaced**: an unverified heuristic was replaced by a deterministic reference
  implementation with tests.
- **Not adopted**: narrative, incomplete, unverified, or unsupported code was
  retained only in the chat source and numbered local archive.

## Extract And Apply CLI

The reusable parser is in `src/transform_md/transform_md/transform_md.py` and
the CLI is `src/transform_md/transform_md/chat_code_blocks.py`; the workspace
entry point is `tools/extract_chat_code_blocks.py`.

```bash
python3 tools/extract_chat_code_blocks.py extract data/chats/example.md \
  --destdir .tmp/chat-code-blocks --verbosity verbose
```

By default, output filenames start with their source-order sequence number,
and the manifest is `<destdir>/chatpatches.json`. Set `--no-sequence-prefix`
to use the source line number in filenames, or pass `--manifest` to choose a
manifest path. `--force` replaces an existing extraction; without it, the tool
reuses an intact manifest only when the source hash and extraction options
match.

Only fences labelled `diff` or `patch` are eligible for application. Every
patch is hash-checked and run through `git apply --check --recount` before
application. Progress is written into the JSON manifest after each patch, so
an already-applied block is not blindly applied twice.

```bash
python3 tools/extract_chat_code_blocks.py apply \
  --manifest .tmp/chat-code-blocks/chatpatches.json -i
```

Interactive mode pauses before each patch and offers retry, skip, or quit when
an applicability check fails. A noninteractive failure saves the failing block
and stops. Repair the worktree, then resume with `--continue`. After an
independent rebase/reset, `--reapply` resets completed states and checks each
patch against the current tree, skipping changes already present. The tool
does not run `git pull`, perform a rebase, commit, stage, or execute source
snippets; review each resulting diff and use the repository's normal Git
workflow.

The {download}`chat-code-patches skill <../.agents/skills/chat-code-patches/SKILL.md>`
documents this workflow for future agent sessions. Its retry/resume/reapply tests are in
`src/transform_md/tests/test_chat_code_blocks.py`.

## Source-Ordered Block Ledger

Every line number below refers to
`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`.

| ID | Fence | Opening line | Disposition |
| --- | --- | ---: | --- |
| 001 | Plain diagram | 24 | Not executable; retained as source context. |
| 002 | Plain equations and diagram | 142 | Not executable; energy and speedup inputs are not measurements. |
| 003 | Plain architecture diagram | 311 | Not executable; retained as source context. |
| 004 | Lean cost ledger | 384 | Reused the existing volumetric cost model; the chat's sample counts and step counts are not benchmark evidence. |
| 005 | BibTeX | 532 | Candidate citation only; no bibliography entry was changed on the basis of this export. |
| 006 | Plain causal-sector diagram | 583 | Not executable; the causal labels are not consequences of the diagram. |
| 007 | Lean Landauer and Hodge model | 641 | Reused the conditional Landauer model; ported the coordinate Hodge involution. The combined Landauer-Bures inference bound was not adopted. |
| 008 | Rust two-phase kernel | 815 | Not ported verbatim: its numerical steps do not establish projector idempotency, isometric parallel transport, or physical tunneling. |
| 009 | Markdown paper section | 1086 | Not adopted; it interprets a proposed work equation as measured cooling during inference. |
| 010 | Lean step and dispersion models | 1142 | Ported as conditional rate arithmetic and a scalar dispersion model with explicit hypotheses. |
| 011 | Python simulation tests | 1350 | Replaced the claimed EBR simulation checks with finite Lean identities and exact Rust reference tests. |
| 012 | Markdown GraphRAG proposal | 1654 | Not implemented; the proposed causal and verifier-free guarantees are unsupported. |
| 013 | Markdown speedup table | 1767 | Not adopted as a benchmark; component ratios depend on unmeasured input values. |
| 014 | Lean speedup factorization | 1792 | Reused existing cost-model definitions; no multi-factor hardware speedup guarantee was added. |
| 015 | Plain UKS diagram | 1885 | Not executable; retained as source context. |
| 016 | Lean multi-reference model | 1943 | Ported the two-reference energy inequality with explicit overlap and coupling assumptions only. |
| 017 | Python H2/QCI-GXC simulation | 2104 | Not adopted as electronic-structure evidence; the source does not validate the proposed physical Hamiltonian. |
| 018 | Markdown QCI-GXC proposal | 2318 | Not adopted as a material or spin-restoration result. |
| 019 | Plain RH diagram | 2360 | Not executable; retained as source context. |
| 020 | Lean critical-line model | 2426 | Ported reflection fixed-point and even-polynomial identities; excluded the inference that positive model stiffness proves RH. |
| 021 | Plain RH diagram | 2545 | Not executable; retained as source context. |
| 022 | Python zero-discovery script | 2577 | Not ported; a numerical surrogate or seeded zero list cannot verify RH. |
| 023 | Lean Ihara/Sato/RH model | 2800 | Not adopted as a graph-RH or RH theorem; a finite determinant identity does not establish the proposed infinite-limit bridge. |
| 024 | Markdown Sato discussion | 2933 | Not executable; retained as source context. |
| 025 | Plain Sato diagram | 3004 | Not executable; retained as source context. |
| 026 | Lean Onsager/GUE/Sato models | 3064 | Reused the existing QFIM owner where applicable; did not promote the sine-kernel argument to a physical or RH result. |
| 027 | Python symbolic RH script | 3202 | Not ported; numerical and symbolic checks do not prove global zero locations. |
| 028 | Plain decomposition diagram | 3623 | Not executable; retained as source context. |
| 029 | Lean QFIM/VRC identities | 3679 | Reused existing DFT and QCI contracts rather than adding duplicate APIs. |
| 030 | Python VRC/RH tests | 3799 | Not ported as verification; existing VRC tests remain the owning checks. |
| 031 | Lean G-GKBA/EBR ledger | 4229 | Reused the existing G-GKBA complexity model; the combined adaptive EBR factors are not measured. |
| 032 | LaTeX speedup theorem | 4399 | Not executable; retained as a proposed equation, not a measured result. |
| 033 | Lean pair-excitation QNG model | 4467 | Not added as a new chemistry result; its scalar assumptions are not a validated electronic-structure calculation. |
| 034 | Python QFIM audit | 4532 | Reused existing QFIM/Madelung identities; the zero-search output is not an RH result. |
| 035 | Rust G-GKBA kernel | 4593 | Not ported; its operation counters are synthetic and do not benchmark cubic-history versus linear-history execution. |
| 036 | Plain factorization table | 4760 | Not executable; retained as source context. |
| 037 | Plain RH diagram | 4795 | Not executable; retained as source context. |
| 038 | Lean Jensen-Polya polynomial | 4841 | Ported the finite polynomial expansion and its conditional off-axis inequality; no Hardy-Zeta positivity claim was added. |
| 039 | Plain RH diagram | 4979 | Not executable; retained as source context. |
| 040 | Python zero audit | 5028 | Not ported as proof or benchmark; the generated numerical check does not establish RH. |
| 041 | Lean three-channel QFIM model | 5251 | Reused the existing QFIM and Madelung model in DFT. |
| 042 | Lean blockade formula | 5375 | Not adopted as a physical blockade law; the equation is an assumed finite model. |
| 043 | Python numerical audit | 5558 | Not ported; its numerical checks do not validate the proposed physical interpretation. |
| 044 | Plain model diagram | 5735 | Not executable; retained as source context. |
| 045 | Lean Hooke/QFIM strain model | 5785 | Ported the scalar Hooke energy-difference identity; it does not validate fabric mechanics or QFIM calibration. |
| 046 | Initial unified diff | 5975 | Rejected as a whole because of malformed/inconsistent hunks and stale crate context; selected finite identities were ported separately. |
| 047 | Bash patch command | 7111 | Not run; the patch failed applicability checks before mutation. |
| 048 | PyO3 layer-group diff | 7167 | Rejected: it targets obsolete Cargo features and a file that already exists in the current crate. |
| 049 | Bash build commands | 7894 | Retained as proposed commands; current crate tests were run using its actual manifest. |
| 050 | Lean p4m/Hooke model | 7949 | Ported the p4m check figures and conditional scalar energy drop; not the claim of validated layer-group physics. |
| 051 | Cumulative layer-group diff | 8096 | Rejected as a whole; approximate coordinate operations do not implement or verify all 80 layer groups. |
| 052 | Plain layer-group table | 8777 | Not executable; the group/application mapping was not independently verified. |
| 053 | Lean graphene/Chern model | 8822 | Reused the existing QAHE Chern model; excluded the proposed thermal-cooling and inductance conclusions. |
| 054 | Python graphene/Sudoku tests | 9011 | Ported a standard Sudoku reference solver; did not port the graphene hardware claims. |
| 055 | Plain video prompt | 9325 | Not executable; retained as source context. |
| 056 | Lean yarn/Schubert model | 9369 | Ported the decomposable-line identity and abstract Schubert multiplication table; omitted stitch-performance interpretations. |
| 057 | ARC/graph-coloring diff | 9538 | Rejected as a whole due to stale context; replaced its heuristic solver claims with exact bounded references. |
| 058 | Rust N-Queens heuristic | 10500 | Replaced by exact enumeration and D4 orbit canonicalization. |
| 059 | Python N-Queens fallback | 10740 | Replaced by Rust exact-solver tests; did not preserve the claimed Pass@1/Cov@20 guarantee. |
| 060 | Plain DPP diagram | 10891 | Not executable; retained as source context. |
| 061 | Lean McWeeny/orbit model | 10929 | Ported the scalar polynomial; exact Rust enumeration confirms 92 eight-queen boards in 11 size-8 and 1 size-4 D4 orbit. The DPP coverage guarantee was rejected. |
| 062 | Python Birkhoff-DPP solver | 10992 | Not ported as a solver; finite Sinkhorn normalization and scalar McWeeny checks are tested separately. |
| 063 | Birkhoff-DPP Rust diff | 11221 | Rejected as a whole because it depends on absent prior files and stale API context; exact solvers replace the heuristic. |
| 064 | Python combined tests | 11996 | Replaced the benchmark assertions with deterministic Rust unit tests. |

## Ported Contracts

`Signals.GrassmannianEBR` contains finite algebraic models and explicitly
conditional results:

- The Pluecker lift of an affine 3D line satisfies the Klein relation, and the
  coordinate Hodge map is an involution preserving that residual.
- The integral Schubert multiplication table gives the stated divisor-square
  and degree-four check figure.
- The even-square p4m orbit-count arithmetic, layer-order product, and scalar
  Hooke energy drop are checked from their supplied formulas.
- The McWeeny scalar polynomial fixes 0 and 1, moves values below/above 1/2 in
  the corresponding direction, and leaves 1/2 fixed. It is not a Birkhoff
  projection and does not eliminate every fractional value.
- The two-reference energy inequality, two-phase step comparison, dispersion
  inequalities, reflection symmetry, and Jensen-Polya polynomial expansion
  hold only under their stated scalar assumptions.

The Rust `finite_constraint_solvers` module provides exact bounded references for
N-Queens, proper graph colorings, a 9-by-9 Sudoku, and a 32-element D4/glide/
palette-transform family. Its Sinkhorn function performs a finite number of
normalizations and is approximate in general. It does not claim general ARC-AGI
solving, EBR convergence, DPP diversity guarantees, or physical symmetry.

## Reused Owners

- `Signals.QuantumCausalInference.delRioConditionalLandauerHeat` already owns
  the conditional Landauer heat expression (`src/signals/Signals/QuantumCausalInference.lean`, line 236).
- `Signals.QuantumCausalInference.effectiveVolumetricSpeedupWithOverhead`
  already owns the volumetric arithmetic model (`src/signals/Signals/QuantumCausalInference.lean`, line 1813).
- `Signals.DFT.mcweenyPurificationPoly`, G-GKBA complexity, and QAHE Chern
  definitions already live in DFT (`src/signals/Signals/DFT.lean`, lines 111,
  791, and 3400 respectively).

These are mathematical or code-level contracts over supplied parameters. None
of them confirms a physical realization, benchmark speed, materials property,
zero-backaction operation, or energy efficiency measurement.

## Explicit Exclusions

- The proposed inference Landauer-Bures sum is not derived from the existing
  conditional Landauer contract; its QFIM-action term has no validated unit or
  thermodynamic premise here.
- The proposed 490,000x and larger speedups combine assumed FLOPs, trajectory
  counts, and halting steps. No device-level profiling or accuracy-matched
  baseline was provided.
- The G-EBR and DPP code does not establish that all trajectories reach distinct
  valid solutions. The exact N-Queens tests establish counts for the finite
  puzzle only; they do not establish EBR Pass@1 or Cov@20.
- A symmetric transverse polynomial with positive supplied curvature does not
  prove the Riemann Hypothesis. The chat blocks do not establish positivity for
  the actual Jensen-Polya discriminant at every height.
- The p6/mmm order product, QAHE Chern inputs, zero-resistance routing,
  sub-nanometer imaging, and knitted-fabric mechanics are not experimental
  measurements or validations in this port.

## Deferred Objective Plan

These are explicit incomplete objectives from the source chat, not verified physical
results. Each workstream separates **(a) verified finite algebraic or numerical contracts**,
**(b) `Signals.Pending` measurement/benchmark acceptance gates**, and
**(c) explicit non-claims**. Per `docs/normative-language-plan.md`, new Lean workstreams
must avoid bloating `Huygens.lean`, `DDF.lean`, or `DFT.lean`; instead, place finite math in
focused domain modules (`Signals.Proca`, `Signals.QISM`, `Signals.QuantumCooling`,
`Signals.GrassmannianEBR`, or dedicated modules such as `Signals.LayerGroups` and
`Signals.MultiReferenceNOCI`) and place unvalidated physical/benchmark premises in
`Signals.Pending` using dimensioned types from `Signals.Units`.

### Objective Summary Matrix

| Workstream | Objective | Current port status | Companion papers & existing `Signals` owners | Acceptance gate and chat source |
| --- | --- | --- | --- | --- |
| **WS-0** | Submodule & CLI self-containment | `transform_md` commit `e0bd794` ready; root gitlink needs sync. | `tools/extract_chat_code_blocks.py`, `src/transform_md` | Fresh checkout runs `tools/extract_chat_code_blocks.py` cleanly. |
| **WS-1** | Dispersion physics | Sign trichotomy and scalar witnesses proved; dimensioned 4-vector map pending. | [Thermo-EM](grassmannian-thermo-electro-magnetics-lord-shulman-paper.md), [Maxwell/Twistors](grassmannian-maxwell-electromagnetism-twistors-ez-oam-solitons-gravity-models-paper.md), [Quantum Trajectories](grassmannian-quantum-trajectories-bohmian-weak-nonlinear-optics-paper.md), [Flat Light Plan](flat-light-proca-nlig-validation-plan.md); `Signals.Proca`, `Signals.Units`, `CWProcaEmissionHypothesis` | Prove quadratic-form preservation with SI units and fixed `(+,-,-,-)` metric; physical Maxwell/Proca/evanescent labels remain gated on polarization/loss measurements. Chat: lines 623–770, 1110–1296. |
| **WS-2** | Quantum cooling & Landauer–Bures | Conditional Landauer reused; `QuantumCooling.lean` vs. `Pending.lean` split; inference Landauer–Bures balance unverified. | [Quantum Causal & Mpemba](grassmannian-quantum-causal-inference-mpemba-paper.md), [QFIM $= 4 g^{\mathrm{FS}}$](grassmannian-qfim-fubini-study-kahler-madelung-unification-paper.md); `Signals.QuantumCausalInference`, `Signals.QuantumCooling`, `QuantumCausalMpembaSynthesisContract` | Add dimensioned closed-cycle contract (prep, erasure, reset, controller work, reservoirs, `do(F=0)` control); prove closed-cycle Second Law; no cooling claim without calibrated calorimetry. Chat: lines 522–695, 1082–1221. |
| **WS-3** | All 80 layer groups (decoupled from `G-MGS`) | Only `p4m` count arithmetic and `12 * 2 = 24` product checked; 80-group catalogue absent. | [Rhombohedral Graphene `G-MGS`](grassmannian-rhombohedral-graphene-superconductivity-qc-paper.md), [Graphene Plan](rhombohedral-graphene-superconductivity-plan.md); `RhombohedralGrapheneSuperconductivityPendingHypothesis` | Exact rational affine actions for all 80 groups (International Tables Vol. E) verified for identity, closure, inverses, orders, and 17-wallpaper projections; keep QAHE/transport claims decoupled. Chat: lines 7165–9010. |
| **WS-4** | Slavnov–Gram DPP diversity | Exact N-Queens / Petersen oracles exist; no PSD-verified Gram DPP solver ported. | [QISM & Bethe Ansatz](grassmannian-qism-bethe-ansatz-paper.md); `Signals.QISM.slavnovDet2_pauli_exclusion`, `finite_constraint_solvers.rs` | Prove PSD + duplicate collapse + small-$K$ log-det gradient; implement Cholesky log-det/gradient in Rust + PyO3; evaluate empirical `Pass@1`/`Cov@K` with seeds (no universal 100% guarantee). Chat: lines 2901–2929, 10873–12155. |
| **WS-5** | `QCI-GXC` multi-reference NOCI & VRC-3 | Only conditional 2-state secular inequality formalized; no complex NOCI or VRC-3 proof. | [Kohn–Sham DFT & VRC](grassmannian-kohn-sham-dft-complex-plabic-vrc-paper.md), [Speed–Accuracy](grassmannian-speed-accuracy-barrier-quantum-chemistry-paper.md), [MADNESS/Tequila](grassmannian-madness-tequila-quantum-chemistry-plabic-vrc-paper.md), [Tequila PyO3](grassmannian-tequila-rust-pyo3-quantum-simulator-paper.md); `Signals.Plabic`, `QuantumCausalGrassmannianDFTHypothesis`, `qci_grassmannian_dft.py` | Prove VRC-3 $\Delta\varepsilon=0$ regularity & $1/4$ QNG step; implement $M$-state Hermitian generalized eigensolve $H c = E S c$ with Löwdin conditioning & $\langle \hat{S}^2 \rangle$; cross-check against independent FCI/reference values. Chat: lines 1879–2343, 4449–4590. |
| **WS-6** | EBR efficiency & benchmark harness | Exact search baselines exist; no EBR objective, Reverse-SXM, or accuracy-matched harness ported. | [Bundle-Transformer/VideoGen](grassmannian-quantum-causal-jev-bundle-transformer-videogen-paper.md), [Splat/GraphRAG](grassmannian-quantum-causal-splat-nanoimaging-surgical-graphrag-paper.md), [QCI-NCM](grassmannian-quantum-causal-next-concept-modeling-pressed-llm-kicad-paper.md), [Tuning with Light](grassmannian-tuning-materials-with-light-paper.md) | Reference Chen et al. (`arXiv:2611.08977`, `wwillchen/ebr`); separate energy/halting search from exact baselines; verify projector idempotency before complex descent; log wall time, `Pass@1`, `Cov@K`, seeds (no multiplied FLOP-ledger claims). Chat: lines 253–502, 785–1081, 1297–1878. |
| **WS-7** | Compositional ARC-AGI rule DSL | 32-element finite D4/glide/palette symmetry finder only; not an ARC-AGI solver. | `finite_constraint_solvers.rs` (`GridTransform`, `score_grid_transforms`) | Build typed compositional grid DSL (objects, crop/tile/translate, color maps, counts, multi-step composition) with reproducible task manifest and held-out `Pass@1`/`Pass@2` metrics; keep 32-transform scorer labeled a symmetry finder. Chat: lines 9511–10463, 11992–12155. |
| **WS-8** | Knitting & textile observation contract | Line-to-Plücker Klein identity and abstract Schubert ring formalized; no dimensioned textile contract. | [DDF Fracture vs. ER=EPR](grassmannian-ddf-fracture-communication-vs-er-epr-wormholes-paper.md); `Signals.GrassmannianEBR`, `Signals.Units` | Add dimensioned `TextileObservationContract` in `Signals.Pending` tying Stockinette ($\mathcal{L}_7$), $1\times 1$ Rib ($\mathcal{L}_{19}$), and Garter ($\mathcal{L}_{37}$) to WS-3 layer groups, gauge, load, stiffness, uncertainty, and control-fabric residuals. Chat: lines 5729–5913, 7936–8072, 9308–9510. |
| **WS-9** | Isolated analytic number theory (Ihara–Selberg / RH) | Reflection symmetry and Jensen–Pólya polynomial expansion retained; no RH claim. | `Signals.GrassmannianEBR`, `Signals.Plabic`, `Signals.QISM` | Keep strictly separate from performance/materials tracks; formalize only finite-graph Ihara–Selberg Bass determinant & Ramanujan critical-circle equivalence ($\lambda^2 \le 4q \iff \|u\|^2 = 1/q$), explicitly noting the missing bridge to $\zeta(s)$. Chat: lines 2344–3598, 4788–5728. |

### Phased Execution Plan

#### Phase A — Verified Formal Bridges on Existing Owners (WS-1 & WS-2)
1. **WS-1 (Dimensioned Four-Vector / Plücker Dispersion Bridge)**:
   - Extend `Signals.Proca` / `Signals.GrassmannianEBR` with SI-dimensioned wavevector conversion (`Signals.Units.Frequency`, `Signals.Units.Speed`, `Signals.Units.Length`) into `Proca.FourVector`, a Hermitian $2\times 2$ Pauli/spinor map $K(k)$ satisfying $\det K(k) = \operatorname{minkowskiDot}(k, k)$ in signature $(+,-,-,-)$, and direct equivalence with `gr24DispersionInterval`.
   - Expose deterministic dispersion-sector classification in Rust (`finite_constraint_solvers.rs` / PyO3) and verify symbolically in SymPy.
2. **WS-2 (Closed-Cycle Conditional Landauer & QFIM–Bures Audit)**:
   - Update `Signals.QuantumCooling` to quarantine speculative vacuum-extraction commentary and cross-link `Signals.QuantumCausalInference.closedLoopErasureAndMemoryResetHeat`.
   - Add `InferenceThermodynamicCycleContract` in `Signals.Pending` with `Units.Energy`, `Units.Temperature`, preparation/erasure/reset/controller work, explicit dimensional QFIM–Bures action dissipation, unentangled $\operatorname{do}(F=0)$ control, and a proved closed-cycle Second-Law bound ($Q_{\mathrm{closed}} \ge k_B T \ln 2 \cdot N_{\mathrm{reset}}$).
   - Add Lean tests in `SignalsTests.lean` and `SignalsPendingTests.lean` plus SymPy dimensional checks.

#### Phase B — Exact Group Theory & PSD-Verified Gram DPP (WS-3 & WS-4)
3. **WS-3 (Exact 80 Crystallographic Layer Groups)**:
   - Add `Signals.LayerGroups` (Lean 4) formalizing exact layer-group affine actions $(R, \mathbf{t})$ on $\mathbb{R}^3 / (\mathbb{Z}^2 \times \{0\})$, group axioms, order divisibility, and Stockinette ($\mathcal{L}_7$), $1\times 1$ Rib ($\mathcal{L}_{19}$), Garter ($\mathcal{L}_{37}$), `p4m` ($\mathcal{L}_{55}$), `p4/mmm` ($\mathcal{L}_{61}$), and `p6/mmm` ($\mathcal{L}_{80}$) check figures.
   - Add `src/signals/numerical_adapter/src/layer_groups.rs` implementing all **80 crystallographic layer groups** ($\mathcal{L}_1\text{–}\mathcal{L}_{80}$, International Tables Vol. E) via exact rational generators (`i32` matrices + exact 12th-unit translation fractions modulo $\mathbb{Z}^2 \times \{0\}$), with exhaustive Rust tests verifying closure, identity, inverses, orders, and 17-wallpaper projections for every single group $1\text{..=}80$.
   - Expose PyO3 bindings (`list_layer_groups`, `verify_layer_group`, `layer_group_orbit`) via `maturin`.
4. **WS-4 (PSD-Verified Slavnov–Gram DPP)**:
   - Extend `Signals.QISM` / `Signals.GrassmannianEBR` with finite $2\times 2$ Gram PSD positivity ($\det(X^\top X + \varepsilon I) > 0$), duplicate-column determinant collapse ($\det(X^\top X) = 0$), and exact $2\times 2$ log-det inverse-matrix derivative identities.
   - Add `src/signals/numerical_adapter/src/slavnov_dpp.rs` with Cholesky-based regularized Gram log-determinant $\log\det(X^\top X + \varepsilon I)$, analytical gradient $2 X (X^\top X + \varepsilon I)^{-1}$, finite-difference gradient tests, and seeded empirical diversity trials against exact N-Queens and Petersen coloring oracles in `finite_constraint_solvers.rs` (logging actual `Pass@1` and `Cov@K`).
   - Expose PyO3 bindings and verify symbolic gradients in SymPy.

#### Phase C — Multi-Reference Chemistry, EBR Harness, & Compositional ARC DSL (WS-5, WS-6, WS-7)
5. **WS-5 (`QCI-GXC` Multi-Reference NOCI & VRC-3 Regularity)**:
   - Add Lean finite contracts in `Signals.GrassmannianEBR` (or a dedicated `Signals.MultiReferenceNOCI` module) for: (a) VRC-3 pair-excitation amplitude regularity at $\Delta\varepsilon = 0$ and the $1/4$ QNG step from $F_{\mu\nu} = 4 g_{\mu\nu}^{\mathrm{FS}}$, and (b) $2\times 2$ symmetric/Hermitian generalized eigenvalue lowering under positive-definite overlap ($S_{00}=S_{11}=1, |S_{01}| < 1$).
   - Add a real/complex $M$-state NOCI solver with Löwdin canonical orthogonalization (condition-number diagnostics, rank cutoff), Hermitian generalized eigensolver $H c = E S c$, and spin-expectation $\langle \hat{S}^2 \rangle$ evaluation in Rust (`src/signals/numerical_adapter/src/multi_reference_noci.rs` + PyO3) and Python/SymPy, benchmarked on stretched $\mathrm{H}_2$ (minimal-basis exact FCI reference) with energy error and $\langle \hat{S}^2 \rangle$ tolerances.
6. **WS-6 (EBR Energy/Halting Solver & Accuracy-Matched Benchmark Harness)**:
   - Add a dedicated EBR-style continuous-relaxation + adaptive gradient-norm halting + optional DPP repulsion solver in Rust (`src/signals/numerical_adapter/src/ebr_benchmark.rs` + PyO3), cleanly separated from exact backtracking in `finite_constraint_solvers.rs`.
   - Prove projector idempotency / retraction check figures ($P^2 = P$) and report reproducible seeded runs (`Pass@1`, `Cov@K`, halting steps, wall-clock ms) on 8-Queens, 10-Queens, Petersen 3-coloring, and 9x9 Sudoku puzzles (noting upstream reference `arXiv:2611.08977` / `wwillchen/ebr`).
7. **WS-7 (Compositional ARC-AGI Grid DSL)**:
   - Add `src/signals/numerical_adapter/src/arc_dsl.rs` (+ PyO3 bindings) implementing a typed compositional grid program language (connected-component objects, crop, recolor, flood/mirror/rotate/translate, tiling, overlay, multi-step beam search) with deterministic unit tests on compositional multi-step grid tasks, explicitly preserving the distinction between the 32-transform symmetry finder and general ARC-AGI evaluation.

#### Phase D — Dimensioned Textile Contract & Isolated Finite-Graph Ihara–Selberg (WS-8 & WS-9)
8. **WS-8 (Dimensioned Textile-Observation Contract)**:
   - Add `TextileObservationContract` in `Signals.Pending` referencing `Units.Length`, `Units.Force`, stitch layer-group index ($\mathcal{L}_7, \mathcal{L}_{19}, \mathcal{L}_{37}$), uncertainty bounds, and control-fabric residual gates.
   - Add a Python/SymPy discrete centerline Plücker audit verifying Klein residual $= 0$ across sampled 3D stitch splines without claiming mechanical performance validation.
9. **WS-9 (Isolated Finite-Graph Ihara–Selberg / Ramanujan Equivalence)**:
   - Add finite-graph Bass determinant & $(q+1)$-regular Ramanujan critical-circle equivalence ($\lambda^2 \le 4q \implies |u|^2 = 1/q$) in Lean (`Signals.GrassmannianEBR`) and exact SymPy/Rust checks on $K_4$ / Petersen ($q=2$, 3-regular Ramanujan graph with eigenvalues $\{3, 1, -2\}$, $\lambda^2 \le 4 < 8$), strictly isolating it from $\zeta(s)$ and RH claims.

#### Phase E — Companion MyST Paper, PyO3/Maturin Build, & Cross-Document Sync
10. Build and install `signals_numerical_adapter` with `maturin develop --release` in `.venv`, exposing all new Rust solvers to Python.
11. Add comprehensive Python + SymPy + PyO3 test suites under `tests/` verifying symbolic identities against Lean check figures and Rust numerical outputs.
12. Author companion MyST paper `docs/grassmannian-gebr-layer-groups-dpp-noci-arc-paper.md` (with Lean 4, Rust/PyO3/`maturin`, Python/SymPy code & verified tables, explicit epistemic boundaries, and BibTeX/JSON-LD provenance) and link it alongside this plan in `docs/_toc.yml`, `docs/plan-index.md`, `docs/index.md`, and `docs/grassmannian-unification-applications-roadmap-paper.md`.

### Porting Order

1. Commit this plan and sync `src/transform_md` (WS-0).
2. Execute Phase A (WS-1 & WS-2) $\to$ run focused Lean, Rust, and SymPy tests.
3. Execute Phase B (WS-3 & WS-4) $\to$ verify all 80 layer groups and Cholesky DPP gradients.
4. Execute Phase C (WS-5, WS-6, WS-7) $\to$ verify NOCI vs. exact minimal-basis FCI, seeded EBR harness, and compositional ARC DSL.
5. Execute Phase D (WS-8 & WS-9) $\to$ verify dimensioned textile contract and finite Ramanujan Ihara–Selberg checks.
6. Build PyO3/maturin wheel, run full Lean + Rust + pytest/SymPy suites, author companion MyST paper, run math-hygiene audits, build Sphinx HTML, and inspect in browser.

## Validation

- `make signals_build` passed under the Signals-pinned Lean toolchain (3,630
  Lake jobs).
- `cargo test --manifest-path src/signals/numerical_adapter/Cargo.toml` passed
  all 110 Rust tests, including the finite-constraint-solver tests.
- `pytest -q src/transform_md/tests` passed all 72 tests, including extraction,
  interactive pause, failure resume, idempotency, and reapply-after-reset cases.
- `pytest -q tests/test_markdown_display_math_spacing.py
  tests/test_markdown_table_math_pipes.py` passed all 11 tests. The report-only
  audits found zero table-math pipe issues and zero display-math spacing issues.
- `make -C docs html` succeeded with 30 warnings after adding the CLI and plan.
  The log includes an unresolved
  `search` document reference in `docs/index.md` and HTML section-extraction
  diagnostics for aggregate pages; neither points to the new paper.
- The generated paper was opened in the browser; it rendered with the expected
  title/headings and zero MathJax error nodes.
- `cargo fmt --check` could not run because `cargo-fmt` is not installed in the
  container. Rust formatting remains unverified.

## Source Record

The source is an AI-generated chat export, not a scholarly publication:
`data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`.
The sequence numbers in the ledger correspond to `.tmp/chat-code-blocks/001-*`
through `.tmp/chat-code-blocks/064-*`; the local manifest records fence labels,
opening/closing lines, and content lengths.