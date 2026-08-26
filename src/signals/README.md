# Signals

`Signals` is a small Lean 4 project for checking the mathematics used in the
signal-processing parts of the sustainablefactory research notes. It is a
research companion, not a claim that the proposed hardware or physical
mechanisms have been experimentally validated.

## Current Scope

The first build deliberately starts with statements that have a clear
mathematical interpretation and an existing library foundation:

- `Signals.Units` provides named wrappers for frequency, length, and power.
- `Signals.IQ` represents an in-phase/quadrature sample as a complex baseband
  value and exposes its magnitude and principal phase.
- `Signals.Coherence` records the polarization/entanglement complementarity
   identity as explicit model data and states the scalar Huygens-Steiner
   parallel-axis identity.
- `Signals.OAM` represents a finite normalized OAM qudit and computes its basis
  state count. The exact identity `100^10 = 10^20` is a combinatorial result,
  not a performance or physical-realizability claim.
- `Signals.Physlib` imports Physlib's vacuum harmonic-wave model and proves a
  small interface lemma over its `FreeSpace` parameters.

The source chat's extracted Lean corpus is available at
`../../data/chats/IQ-Sampling-for-Signal-Phase.lean` from this project directory.
The consolidated library proposal in that corpus names the intended future
areas as units, spinors, twistors, Grassmannians, Amplituhedron forms,
Proca-SQG models, holography, quantum states, and thermodynamics. See
`../../data/chats/IQ-Sampling-for-Signal-Phase.md` around lines 6815-6887 and
10253-10418.

## Build

The project expects Lean `v4.33.0`, matching the current Physlib baseline.
From the repository root:

```text
make signals_build
```

Or from this directory:

```text
make lean-cache
make lean-build
```

The devcontainer builds Signals after the workspace is mounted, rather than
compiling it while the Docker image is built. It mounts the named volume
`sustainablefactory-${localWorkspaceFolderBasename}-signals-lake` at
`src/signals/.lake`, so compiled Mathlib, Physlib, and Signals artifacts remain
available when the container is recreated. The first workspace build can still
take time; subsequent builds are incremental.

The Lake file uses the sibling checkouts at `../mathlib4` and `../physlib`.
Those checkouts must target compatible revisions. At the time this project was
started, the local mathlib checkout reported `v4.34.0-rc2` while Physlib
reported `v4.33.0`; do not mix their build artifacts. A clean CI checkout pins
the matching dependency revisions before running Lean.

No Lean executable was available in the development environment when this
project was scaffolded, so CI is the authoritative executable build check
until Lean is installed locally.

## Development Plan

### Phase 1: Stabilize the base API

1. Keep the I/Q API aligned with Physlib's electromagnetic potential and plane
   wave definitions.
2. Add tests for phase conventions, zero magnitude, sign conventions, and
   principal-argument boundaries.
3. Replace scalar unit wrappers with a reviewed unit representation only when
   it prevents a demonstrated class of errors.

### Phase 2: Formalize standard signal and field models

1. Define a convention-record for carrier sign, quadrature sign, and phase
   range so receiver implementations cannot silently disagree.
2. Add band-limited sampling assumptions and prove the ordinary aliasing and
   reconstruction lemmas needed by the application.
3. Build on Physlib's Maxwell and harmonic-wave results before introducing new
   electromagnetic definitions.
4. Add a Proca field only as an explicit massive-vector mathematical model,
   with its mass, dispersion relation, medium, coupling, and boundary
   assumptions visible in the types.

### Phase 3: Add geometry and fabrication abstractions

1. Introduce spinors and twistors only after identifying reusable structures
   already available in Mathlib.
2. Implement finite matrix minors and Pluecker relations with correct index
   proofs; do not encode physical behavior as an unproved axiom.
3. Model masks, voxels, calibration, and thermal budgets as data plus proved
   bounds. Keep fabrication execution outside the theorem-proving core.
4. Keep OAM state-space counting separate from claims about computational
   speed, fault tolerance, or device capacity.

### Phase 4: Upstream contributions

- Candidate Physlib contributions: reusable mainstream definitions and lemmas
  for electromagnetic wave conventions, polarization, sampling interfaces,
  and massive-vector fields when they have a clear physics reference.
- Candidate Mathlib contributions: general theorems about finite-dimensional
  linear algebra, complex coordinates, matrix minors, or analysis that do not
  depend on a particular physical interpretation.
- The Signals repository should first carry an independently tested proposal,
  then submit small focused pull requests upstream. Each proposal must name
  its mathematical statement, references, assumptions, and proof dependencies.

## Research Boundaries

The chat includes claims about longitudinal optical waves in ordinary air,
SQG vacuum coupling, over-unity power generation, deterministic fusion, and
sub-diffraction lithography.

> Those claims are not represented by the current
> Lean library. Lean checks consequences of definitions and hypotheses; it does
> not turn unsupported physical premises into evidence. The relevant review
> starting point is the chat's own distinction between theorem proving and
> physical validation around lines 4350-4354.
