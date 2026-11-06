---
name: sphinx-bibtex-citations
description: 'Diagnose and repair author-year citation-related myst.xref_missing warnings in Sphinx/MyST docs using sphinxcontrib-bibtex. Use when a Sphinx build reports missing citation anchors or when migrating Markdown bibliography links to BibTeX citations.'
---

# Sphinx BibTeX Citations

Use this workflow for scholarly citation references only. `myst.xref_missing`
also reports broken document links, chat sources, and heading anchors; do not
rewrite those as citations.

## Procedure

1. Rebuild the docs and keep the complete log under `.tmp/`, for example:

   ```sh
   mkdir -p .tmp && chmod 1777 .tmp
   make -C docs html 2>&1 | tee .tmp/sphinx-build.log
   ```

   This repository loads `docs/citations.bib` and keeps the shared directive in
   `docs/references.md`.

2. Run the citation fixer in report-only mode:

   ```sh
   python3 tools/fix_sphinx_bibtex_citations.py \
     --log .tmp/sphinx-build.log
   ```

   It examines only missing-target warnings whose source contains a local
   Markdown fragment link with an author-year label. It converts a link only
   when its exact or explicitly aliased key exists in a parsed `.bib` file.
   Other warnings are left alone.

3. Review `.tmp/sphinx-bibtex-citation-fixes.json`. For each unresolved
   citation, verify the source and bibliography. Add a complete, verified
   BibTeX record or map the old fragment ID to an existing key in
   `docs/bibtex-key-aliases.json`. Never invent metadata to silence a warning.

4. Re-run with `--fix` after reviewing the proposed conversions:

   ```sh
   python3 tools/fix_sphinx_bibtex_citations.py \
     --log .tmp/sphinx-build.log --fix
   ```

   The default role is `{cite:p}`. Use `--role t` for a textual citation.
   The script removes an enclosing parenthesis when the entire parenthesized
   group consists of citations; inspect punctuation in context afterward.

5. Ensure `sphinxcontrib.bibtex` is installed and enabled in `docs/conf.py`,
   `bibtex_bibfiles` includes the source `.bib` file, and a single
   `{bibliography}` directive is present in the docs tree. This repository
   keeps the shared directive in `docs/references.md`.

6. Rebuild the docs and verify that the citation warnings are gone. Review the
   report and source diff; this tool does not repair non-citation MyST
   cross-references or synthesize missing bibliographic records.