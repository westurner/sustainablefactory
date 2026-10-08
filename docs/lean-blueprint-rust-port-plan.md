# Lean Blueprint and SphinxDocRs Roadmap

Status as of 2026-10-04. This plan extends dsport's existing SphinxDocRs H14
work; it does not restart the Rust port of Sphinx.

## Current Baseline

- Signals uses Lean `v4.35.0-rc3` and pins Mathlib to the matching release. Its
  `blueprint` target runs LeanArchitect's package-wide facet for all four
  Signals libraries, then renders the HTML with plasTeX. The package-wide
  facet passes, and the blueprint currently contains two tagged propagation
  theorems and their dependency edge. See
  `src/signals/Makefile:2,27-32`,
  `src/signals/lakefile.toml:5-15`, and
  `src/signals/Signals/Propagation.lean:162-197`.
- The Sphinx HTML build runs that target, copies its output under
  `signals-blueprint/`, and exposes it through the documentation TOC. The PDF
  target still uses `latexmk` and TeX Live. See `docs/conf.py:202-238`,
  `docs/_toc.yml:43`, `docs/signals-blueprint.md:1-13`, and
  `src/signals/Makefile:31-32`.
- `leoliu0/ratex` is cloned at `v0.5.2` under `src/ratex`; it is a complete,
  self-contained TeX engine. The local checkout occupies about 1.2 GB. Building
  it from source requires Rust 1.88. See `src/ratex/Cargo.toml:17` and
  `src/ratex/README.md:50-52,399-406`.
- dsport is cloned at `af216e1` under `src/dsport`. Its H14 work already
  includes a versioned source-analysis model, Arborium-based Lean syntax
  analysis, a Lean domain/xref path, and source-neutral autodoc. H14 explicitly
  says Lean analysis is syntax-level, not elaboration or typeclass information.
  See `src/dsport/README.md:273-285`,
  `src/dsport/docs/sphinxdocrs-port-plan.md:2196-2212,2349-2380,2436-2475`,
  and `src/dsport/src/sphinxdocrs/src/source_analysis/lean.rs:1-4`.
- dsport has a separate source-documentation LSP integration plan, but it is
  marked proposed, not implemented. It recommends static analysis by default
  with opt-in `lsp` and `hybrid` modes. Its planned LSP mapping covers symbols,
  source ranges, detail/signature text, hover, locations, and diagnostics; it
  leaves visibility, aliases, `noindex`, and stable IDs to static analysis.
  See `src/dsport/docs/source-docs-lsp-integration-plan.md:3,45,368-399`.
- The dsport Sphinx submodule is an exception: its gitlink requests
  `4ef6748f097b4315a9989d039f29408d5bde0e7d`, which was unavailable from both
  declared upstream and the westurner fork. The worktree is restored at the
  available upstream master `b04a210`; dsport reports this submodule as
  modified. Resolve and record a valid upstream pin before using that checkout
  for version-sensitive parity tests. The URL is in `src/dsport/.gitmodules:25-27`.
- dsport also has a `src/RaTeX` submodule from `erweixin/RaTeX`, a math renderer.
  It is distinct from the full TeX engine `leoliu0/ratex` cloned at
  `src/ratex`. See `src/dsport/.gitmodules:4-6`.

## Design Boundaries

- Lean's elaborated environment remains authoritative for declaration identity,
  proof status, and inferred dependencies. Do not infer `leanok`, `sorry`
  status, `uses`, or `proofUses` from Arborium syntax.
- LSP is a useful route to elaborated symbol details, but generic LSP responses
  are not automatically blueprint evidence. The proposed dsport adapter maps
  document symbols, hover, definitions, references, and diagnostics; it does
  not specify theorem proof-completion or `uses`/`proofUses` extraction. Keep
  LeanArchitect's Lake export authoritative for those fields unless a
  Lean-specific RPC or equivalent semantic export is implemented and parity-
  tested. See `src/dsport/docs/source-docs-lsp-integration-plan.md:61,368,389`.
- Keep blueprint records separate from generic `SourceDeclaration`. The latter
  is suitable for names, signatures, documentation, visibility, and source
  spans; blueprint readiness and proof/dependency semantics need their own
  schema. See `src/dsport/src/sphinxdocrs/src/source_analysis.rs:15,151,270-362`.
- Keep the current LeanArchitect/leanblueprint path available until Rust output
  passes parity checks. Ratex replaces only the print/PDF engine; it does not
  replace Lean extraction or the HTML renderer.
- Prefer an incremental SphinxDocRs extension and its existing Python/Rust
  compatibility boundary over replacing the complete Sphinx application in
  one step. Existing H14 domain, source-analysis, and autodoc behavior should
  be reused.

## Proposed Phases

### Phase 0: Pin and Capture the Baseline

- Resolve dsport's missing Sphinx gitlink. Either recover the exact object or
  intentionally update the parent gitlink to an available commit and record
  the new parity baseline. Do not silently treat the current master fallback
  as the recorded version.
- Record the Signals toolchain, Mathlib/Physlib revisions, LeanArchitect tag,
  dsport revision, and Ratex tag used for each comparison.
- Save reproducible outputs from the current workflow: package-wide
  LeanArchitect JSON/TeX, blueprint HTML, dependency graph, and print source.
- Acceptance: a clean build can regenerate all four library indexes and the
  current HTML graph from pinned inputs.

### Phase 1: Ratex PDF Compatibility Spike

- Build or install Ratex `v0.5.2`; for source builds, use the documented Rust
  1.88+ toolchain. Test the existing `blueprint/src/print.tex` with explicit
  XeLaTeX mode and the Ratex multipass driver.
- Check `unicode-math`, `expl3`, `mathtools`, `hyperref`, `geometry`, local
  macro files, links, theorem text, and generated Lean inputs. Compare PDF text,
  page count, and link destinations against a TeX Live reference.
- If compatible, add a configurable `RATEX` backend to `blueprint-pdf`, keeping
  TeX Live as a fallback until CI passes. If it is not compatible, retain the
  current PDF target while recording the unsupported package or command.
- The prior Ubuntu 24.04 package estimate for a minimal XeLaTeX/latexmk setup
  was roughly 0.4 GB installed; reserve about 0.5 GB because apt dependencies
  and recommends vary. `latexmk` itself is under 1 MB installed. Package
  references: [latexmk](https://packages.ubuntu.com/noble/latexmk),
  [XeTeX](https://packages.ubuntu.com/noble/texlive-xetex), and
  [LaTeX extras](https://packages.ubuntu.com/noble/texlive-latex-extra).
- Acceptance: the current print document builds reproducibly with Ratex in CI
  and has no unexplained differences from the reference PDF.

### Phase 2: Define a Versioned Blueprint Export

- Use LeanArchitect's Lake JSON facet as the producer. Inspect its exact current
  JSON output before fixing a Rust schema; normalize it into a versioned
  `BlueprintSnapshot` containing nodes, labels, node kinds, statements/proofs,
  Lean declarations, module/source locations, `uses`, `proofUses`, readiness,
  and diagnostics.
- Keep source declarations linked by stable IDs, but store blueprint metadata
  independently. Preserve the distinction between declaration existence and
  proof readiness.
- Capture fixtures for all four Signals libraries, including custom labels,
  multiple Lean declarations per node, missing dependencies, `sorry`, and
  theorem-to-theorem edges.
- Acceptance: deterministic JSON with explicit schema/toolchain/backend
  versions; invalid labels or references fail validation with actionable
  diagnostics.

### Phase 2.5: Optional Lean LSP Semantic Enrichment

- Reuse dsport's planned `SourceLspClient` and source-provider boundary rather
  than creating a blueprint-specific LSP process manager. Start with its
  `static`, `lsp`, `hybrid`, and `auto` policy; static remains the default for
  reproducible CI. The current dsport document explicitly marks this LSP path
  proposed, so first land and verify that provider independently.
- Configure the Lean server per Signals workspace, initially through the
  Lake-selected toolchain and a command such as `lake env lean --server`. Probe
  the exact server version, capabilities, workspace root, initialize/open
  lifecycle, request limits, and shutdown behavior. Do not assume that an
  editor's already-running server has loaded the same Lake environment.
- Use standard document-symbol, hover, definition/reference, and diagnostic
  responses to enrich declaration names, spans, signatures, source links, and
  diagnostics. Reconcile to static declarations by canonical file URI, source
  range, then qualified name. Preserve static IDs and policy metadata; report
  conflicts instead of silently choosing a value.
- Separately probe whether the pinned Lean server exposes a supported
  Lean-specific RPC for declaration constants, theorem proof completion, and
  proof dependencies. `textDocument/hover`, references, and diagnostics alone
  are not sufficient to set `leanok` or derive `uses`/`proofUses`.
- Until such an RPC is verified, merge LSP-enriched source records with the
  authoritative LeanArchitect JSON nodes. If a future RPC produces blueprint
  semantics, compare it field-for-field with `lake build :blueprintJson` before
  allowing it to replace those fields.
- Keep LSP opt-in, timeout-bounded, shell-free, and explicit about fallback.
  Default documentation builds must not start a language server. Protected LSP
  mode requires process/stdio lifecycle and platform sandbox guarantees; do not
  label an unsandboxed child as protected. See
  `src/dsport/docs/source-docs-lsp-integration-plan.md:399,536`.
- Acceptance: the static path works without an installed server; `lsp` mode
  fails clearly when the configured server is unavailable; `hybrid` mode is
  deterministic; and the fixture matrix records exactly which fields came
  from static analysis, LSP, or LeanArchitect semantic output.

### Phase 3: Rust Importer and Validator

- Add a focused Rust module in `sphinxdocrs` (or a separate crate only if the
  interface warrants it) to read the export, validate node identity and edges,
  and map declaration IDs into dsport's existing source-domain records.
- Preserve snapshots and cache identity using the source hashes and request
  identity already present in dsport's source-analysis model.
- Do not make the Rust importer parse Lean source or interpret generic LSP
  responses to reconstruct proof status or dependency edges. The Arborium
  adapter remains useful for syntax; LSP may enrich declaration details; the
  LeanArchitect export remains the semantic source until a tested Lean RPC
  replacement exists.
- Acceptance: Rust round-trips the fixture schema deterministically and reports
  unsupported schema versions instead of dropping fields.

### Phase 4: SphinxDocRs Blueprint Extension

- Add a small extension that consumes a validated snapshot and registers
  blueprint theorem/definition nodes, cross-references, source links, and
  dependency edges through the existing SphinxDocRs extension/domain pipeline.
- First run it through the current Python Sphinx build with the Rust extension
  behind dsport's compatibility bridge. This isolates blueprint parity from
  remaining native builder/theme gaps.
- Render both the graph and an accessible textual dependency list. Reuse
  existing Lean domain anchors; do not duplicate declarations in a parallel
  object index.
- Acceptance: the Sphinx page has stable URLs, working theorem links, searchable
  labels, and graph edges exactly matching LeanArchitect's export.

### Phase 5: Rust leanblueprint-Compatible CLI

- Add a Rust command layer for `extract`, `validate`, `web`, and `pdf`. Initially
  `extract` orchestrates the existing Lake facet; `web` uses the SphinxDocRs
  extension; `pdf` delegates to the proven Ratex target.
- Keep `leanblueprint new` and its existing Python path until a separate
  non-interactive project-init contract is defined. Do not port setup prompts
  merely for nominal API parity.
- Acceptance: a single documented command builds the JSON, site, and optional
  PDF while preserving Python fallback and clear error reporting.

### Phase 6: Parity, CI, and Cutover

- Compare Rust and current outputs for every fixture: labels, declarations,
  statements, proof-ready status, dependency edges, source links, rendered
  graph, and PDF artifacts. For LSP-enabled fixtures, also compare each
  enriched field, provenance, fallback decision, and cache invalidation against
  the static-plus-LeanArchitect baseline.
- Run both paths in CI until the Rust route is stable. Then make the Rust route
  the default while keeping an opt-in Python fallback for at least one release
  cycle.
- Remove leanblueprint Python dependencies only after output parity, failure
  diagnostics, docs deployment, and the rollback path are verified.

## Immediate Next Steps

1. Decide whether to repair dsport's Sphinx pin to a known reachable commit.
2. Inspect `lake build :blueprintJson` output and save a small baseline fixture.
3. Read and reconcile dsport's proposed `source-docs-lsp-integration-plan.md`
  with this blueprint-specific semantic contract.
4. Prototype the Lean LSP provider on one propagation declaration, recording
  symbol/type/location responses separately from blueprint proof/dependency
  metadata.
5. Build Ratex and compile the existing `print.tex` before changing the PDF
  target.
6. Prototype one Rust importer for the two existing propagation nodes and their
  single dependency edge; do not begin with a whole-library rewrite.