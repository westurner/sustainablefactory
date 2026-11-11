---
name: research-evidence-triage
description: 'Review chat-derived research claims with reproducible searches, scholarly provenance, file-and-line citations, and explicit evidence statuses. Use for physics, engineering, process, product, or application catalogs sourced from data/chats.'
argument-hint: 'What topic or claim should be searched and triaged?'
user-invocable: true
disable-model-invocation: false
---

# Research Evidence Triage

Builds a traceable evidence packet from the sustainablefactory chat corpus and
related scholarly sources. Chat text is design evidence and provenance; it is
not a measurement by itself.

## When To Use

- Review a physics or engineering claim from `data/chats/`.
- Build or extend an application, process, or product catalog.
- Decide whether a claim belongs in verified Signals, Pending, RDF/process
  data, or an explicit exclusion list.
- Prepare a research brief with citations, confidence, and next measurements.

## Inputs

- A topic, claim, application, process, or product.
- A requested corpus scope, defaulting to `data/chats/*.md` and
  `data/chats/*.json`.
- Optional DOI, title, author, or paper identifier for scholarly follow-up.

## Procedure

1. Define the question and the evidence boundary before searching. Separate
   the claimed mechanism, the observable quantity, and the implied product or
   performance claim.
2. Discover the source set. For Markdown-only work, follow
   [search-chats](../search-chats/SKILL.md). For corpus-wide coverage, use the
   deduplication procedure and script in
   [search-chats-sources](../search-chats-sources/SKILL.md), retaining one
   source per Markdown/JSON basename.
3. Search narrowly with `rg` first. State whether the query is literal,
   phrase, or regex. If there are no results, retry with casing, singular or
   plural variants, and one common synonym; record the no-match result if it
   remains empty.
4. Capture the smallest useful context with file paths and line numbers.
   Use `nl -ba` or an equivalent line-aware view. Generated match lists or
   intermediate files belong under the repository `.tmp/` directory, never a
   system temporary directory.
5. Classify each substantive claim independently:
   - `measured`: a directly reported observation with method, units, and
     enough calibration or controls to interpret it;
   - `scholarly theory`: an equation or established model without local device
     validation;
   - `calibration-required`: a finite model whose inputs, losses, uncertainty,
     or controls are still missing;
   - `proposal`: a chat design or target rather than an observation;
   - `unsupported`: a claim that exceeds the supplied evidence or violates
     conservation, causality, or known model boundaries.
6. Search scholarly provenance only when it can discriminate the claim. Record
   DOI, title, year, and source type, and distinguish a review or theory paper
   from an experiment. Do not present a paper as validation of a different
   material, geometry, scale, or operating regime.
7. Produce a compact evidence table with claim, source citation, status,
   confidence, existing model, missing control, and next check. Every
   substantive chat-derived statement needs at least one directly searched
   file-and-line citation. Keep duplicate chat exports out of the table.
8. When requested, append BibTeX `@misc` entries for chat artifacts and JSON-LD
   for conversations or syntheses. Keep metadata paths and dates consistent
   with the cited evidence.

## Decision Rules

| Finding | Disposition |
| --- | --- |
| Existing finite equation or invariant already has a Signals model | Reuse or extend it; do not create a duplicate record. |
| Equation is checkable but device/material premise is unvalidated | Keep the mathematical layer explicit and put the physical premise in Pending. |
| Observation lacks units, calibration, loss, uncertainty, or controls | Mark `calibration-required`; do not promote it to verification. |
| Claim is mainly a manufacturing step, product description, or supply-chain fact | Keep it in process/RDF or catalog documentation. |
| Claim asserts unsupported energy, causality, quantum, or massive-mode behavior | Exclude from verified promotion and preserve the boundary explicitly. |

## Quality Checks

- Search scope and query mode are stated.
- Every reported claim has a directly searched file and line reference.
- Evidence status is assigned per claim, not per conversation.
- Scholarly sources are matched to the actual material, geometry, scale, and
  measurement being discussed.
- Missing calibration, controls, conservation accounting, and uncertainty are
  named as next checks.
- The final report distinguishes observations, theory, proposals, and
  exclusions instead of averaging them into one confidence score.
