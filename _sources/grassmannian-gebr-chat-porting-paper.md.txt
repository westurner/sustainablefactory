# Grassmannian EBR Chat-Code Porting Ledger

This engineering note records the ordered review and port of code fences in
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

These are explicit incomplete objectives from the source chat, not results.
Each milestone must pass its acceptance gate before its claim moves from
proposal or Pending into a verified Signals statement.

| Objective | Current port status | Next implementation milestone | Acceptance gate and chat source |
| --- | --- | --- | --- |
| Knitting performance | The line-to-Pluecker identity and abstract Schubert ring are formalized; textile behavior is not. | Add a dimensioned textile-observation record for yarn geometry, tension, boundary conditions, material, and uncertainty. Compare measured loop/contact geometry against the model and a control fabric. | Repeated calibrated samples and residual/error bounds are required before claims about curl or stitch performance. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 9369 and 9011. |
| Quantum cooling | Existing conditional Landauer arithmetic is reused; the proposed inference Landauer-Bures balance is not derived. | Add a `Signals.Pending` cycle contract with system/memory state, conditional entropy units, memory preparation/reset, controller work, heat reservoirs, and a no-entanglement control. | Derive the bound from an explicit operation and full cycle; report calibrated heat/work with uncertainty before claiming cooling. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 641 and 1086. |
| EBR efficiency | The Rust additions are exact search references, not an EBR implementation or benchmark. | Pin an upstream EBR revision and benchmark data; implement its published objective and adaptive stopping separately from deterministic baselines. | Accuracy-matched runs must include pass@1, coverage, wall time, FLOPs, device/power data, seeds, and raw results. The chat's multiplied FLOP ledger is not empirical evidence. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 1767 and 5975. |
| DPP diversity | No global Slavnov-Gram DPP solver or coverage guarantee was ported. | Specify the kernel, PSD/regularization conditions, stable log-determinant and gradient, and a deterministic small-instance oracle before integrating it with search. | Tests must prove kernel properties and show coverage on exhaustive instances; no 100% Cov@K claim without benchmark results. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 11221 and 11996. |
| All 80 layer groups and G-MGS | Only p4m count arithmetic and an order product are checked; the group catalogue/actions and graphene measurements are absent. | Add the cited authoritative catalogue and affine actions for each group; test identity, closure, inverses, orbit-stabilizer, and known unit cells before application mappings. | Reproduce all 80 groups from the source catalogue and independently source Chern, gap, and transport data. Symmetry order alone cannot validate QAHE, zero resistance, or cooling. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 7167, 8096, and 8822. |
| ARC-AGI | The finite Rust rule finder covers only 32 D4/glide/palette transforms; it is not an ARC-AGI solver. | Implement a compositional rule language and search procedure that handles object, color, count, and multi-step transformations; pin public task versions and split policy. | Evaluate held-out tasks with pass@1/pass@k, runtime, baselines, and exact task manifest. Continue to label the current implementation a finite symmetry-rule finder. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 9538 and 11996. |
| QCI-GXC multi-reference | Only a conditional two-reference energy inequality is formalized; there is no NOCI or multi-reference SCF implementation. | Implement complex overlap/Hamiltonian matrices, rank and conditioning checks, a Hermitian generalized eigensolve, symmetry action, and explicit spin observables; compare with an independent chemistry code. | Reproduce named molecules/geometries and basis sets with convergence, energy, and spin-contamination tolerances. The two-state identity alone does not establish a ground state. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 1943 and 2104. |
| RH locking | No RH-locking result is claimed; only finite reflection and polynomial identities are retained. | Treat positivity of the actual Jensen-Polya discriminant on the required domain as a separate analytic-number-theory problem. Formalize only independently established lemmas and assumptions. | Do not infer RH from a symmetric toy energy, finite determinant, analogy, or numerical zero search. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 2426, 2800, and 4841. |
| Dispersion physics | The sign trichotomy and scalar check figures are now proved; the physical correspondence is not. | Add units and a correctly typed real four-vector/Pluecker map with a fixed metric convention; prove the map preserves the quadratic form before labeling physical modes. | Algebraic signs remain abstract until polarization, frequency, wavevector, and boundary-condition measurements support a Maxwell/Proca/evanescent interpretation. Chat: `data/chats/Gemini_Quantum-Causal-Grassmannian-Monograph-Review_20261118-1629.md`, lines 1142 and 1240. |

### Porting Order

1. Keep chat extraction source-ordered and content-hashed; automatically apply
  only reviewed unified-diff fences. Other code blocks remain artifacts until
  an owner and test are selected.
2. Reuse existing Signals APIs before adding types. Add finite algebra with
  explicit assumptions to verified modules; put unvalidated physical premises
  in `Signals.Pending` with units, uncertainty, controls, and provenance.
3. Keep exact N-Queens, graph-coloring, Sudoku, and finite-grid solvers as
  correctness baselines. Do not label their outputs EBR, DPP, 80-layer-group,
  or ARC-AGI benchmark performance.
4. Add performance claims only after reproducible, accuracy-matched benchmarks
  on pinned datasets/hardware; add physical claims only after calibrated
  measurements and full energy accounting.

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