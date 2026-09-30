---
name: signals-evidence-modeling
description: 'Map chat-derived physics and engineering evidence into the Lean Signals library, Pending contracts, tests, and documentation without promoting unsupported claims. Use for Signals, Signals.Pending, chat-physics-catalog, or research README updates.'
argument-hint: 'What evidence-backed Signals model, test, or catalog entry should be added or reviewed?'
user-invocable: true
disable-model-invocation: false
---

# Signals Evidence Modeling

Turns a reviewed claim into the smallest defensible Lean and documentation
change. The workflow preserves the boundary between checked mathematics,
calibrated observations, proposals, and unsupported interpretations.

## When To Use

- Add or extend a model in `src/signals/Signals`.
- Decide between a verified module, `Signals.Pending`, and a process/catalog
  entry.
- Add compile-time examples in `SignalsTests` or `SignalsPendingTests`.
- Update the chat physics catalog, Signals README, or project guidance after a
  model change.

## Procedure

1. Start from one concrete anchor: the source claim, owning Lean symbol,
   nearby implementation, failing test, or documentation section. Read only
   enough nearby code to state one falsifiable local hypothesis and one cheap
   check that could disconfirm it.
2. Search the existing Signals API and tests before adding a type. Prefer an
   existing unit wrapper, observation record, accessor lemma, reference
   registry, or Pending boundary over a parallel abstraction.
3. Choose the evidence disposition before writing code:
   - ordinary algebra, dimensional identity, or bounded classical transfer
     with explicit inputs can live in `Signals`;
   - a checkable equation whose physical premise, hardware, or material is
     unvalidated belongs in `Signals.Pending`;
   - a manufacturing step, product, or supply-chain item belongs in the RDF or
     documentation catalog;
   - an unsupported energy, causality, quantum-advantage, massive-mode, or
     lossless-performance claim stays explicitly excluded.
4. Add the smallest finite record and laws that expose the assumptions. Keep
   units, power or energy, losses, calibration, uncertainty, controls,
   provenance, and experimental status as fields when they determine whether a
   conclusion is defensible. Accessor lemmas prove consequences of supplied
   fields; they do not prove that the fields were measured.
5. Keep proposal-specific names and interpretations out of verified modules.
   Use a compatibility alias only when the existing public API requires it, and
   document the precise meaning of the alias.
6. Add focused compile-time examples for the positive law, boundary case, and
   relevant rejection or Pending path. Avoid importing large external
   dependencies when a finite self-contained model tests the contract.
7. Update documentation in the same evidence vocabulary. For chat-derived
   claims, cite the searched source file and line; distinguish theory from
   experiment; list missing calibration or controls; and place future work in
  the recommended update order. Update [chat-physics-catalog.md](../../../docs/chat-physics-catalog.md),
  [docs/index.md](../../../docs/index.md), or [src/signals/README.md](../../../src/signals/README.md)
   only when the change affects that surface.
8. Validate the smallest scope first, then the owning project:
  - from the repository root, run a focused target with
    `make -C src/signals lean-cache lean-build`, or run the full
    `make signals_build` wrapper;
   - run `make -C docs html` when documentation changed;
   - run `git diff --check` before reporting completion.
   Record warnings separately from failures and do not hide unrelated dirty
   worktree changes.

## Decision Table

| Evidence or implementation state | Lean/documentation action |
| --- | --- |
| Existing verified contract covers the observable | Reuse it and add only the missing calibrated field or test. |
| Mathematical law is finite and clear, physical premise is open | Add a Pending record with explicit assumptions and boundary language. |
| Measurement is proposed but lacks units, uncertainty, or controls | Add a calibration-required observation contract, not a verified theorem. |
| Main output is a process, product, or application inventory | Update RDF/catalog documentation and link to any relevant existing model. |
| Claim exceeds equations, measurements, or conservation accounting | Keep it in exclusions or Pending; never infer validation from type-checking. |

## Completion Criteria

- The owning abstraction and evidence status are clear.
- No duplicate model or untracked physical premise was introduced.
- Units, losses, calibration, provenance, and uncertainty are explicit where
  they affect interpretation.
- Focused tests compile and the relevant build passes.
- Documentation links to the model and cites chat-derived claims with file and
  line references.
- The final summary says what was checked and what remains unvalidated.
