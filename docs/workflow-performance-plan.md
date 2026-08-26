# Workflow Simplification and Performance Plan

This plan covers the path from source chats to searchable Sphinx documentation:

```text
data/chats + docs/_toc.yml
    |
    +--> tagged symlink map (chat overlays)
    |
    +--> transform-md --> docs/chats/*.myst.md [canonical searchable source]
        \--> docs/chats/*.ipynb   [optional notebook artifact]
    |
    +--> sphinx-build --> docs/_build/html
        +--> search.html + _static/searchtools.js
    |
    +--> docindex --> OxiRS or Meilisearch
```

## Current baseline

The current workspace contains approximately:

- 325 top-level source Markdown/JSON documents
- 172 generated MyST documents
- 172 generated notebooks
- 206 generated HTML files
- 46 MB of selected source input
- 24 MB of generated MyST input

The main avoidable costs are repeated file discovery, transforming each input
again for each output format, rebuilding or parsing unchanged documents, and
parsing rendered HTML after Sphinx has already resolved the document tree.

## Design principles

1. `docs/_toc.yml` is the only project workflow configuration file. Its
   Jupyter Book keys remain standard (`format`, `root`, `chapters`, `parts`),
   while project-specific settings live under
   `sustainablefactory.chat_sources`.
2. ReST and MyST are the canonical searchable/documentation formats. Notebook output is a
   secondary artifact and should not be required for a documentation-only or
   search-only build.
3. Every stage consumes a manifest produced by the preceding stage instead of
   independently rescanning directories.
4. Incremental work is keyed by content hash plus relevant configuration, not
   only modification time.
5. Each stage writes atomically and reports enough counters to explain a slow
   build or an unexpected index size.

## Phase 0: establish one manifest

Add a small generated manifest under `.tmp/workflow/` containing, for each
selected source document:

- source path and stable document key
- content hash and byte size
- extracted tags and normalized tag paths
- selected output paths
- transform configuration/version
- last successful transform and indexing status

`create_symlinks.py` should produce the selection portion of this manifest and
use it to remove stale tag symlinks. It should not follow generated tag-folder
symlinks while selecting source files. The manifest should be reproducible from
`docs/_toc.yml` and should make the selected file list inspectable in CI.

## Phase 1: make transform-md incremental

1. Add a manifest-aware batch mode that transforms only new or changed source
   files.
2. Parse and normalize each source once, then fan out the in-memory result to
   MyST and notebook serializers. The current per-output loop can otherwise
   repeat input parsing and transformation work.
3. Keep MyST as the default output for `transform_md_all`; move notebook
   generation behind an explicit output flag or separate target when notebooks
   are not needed.
4. Write outputs to a temporary sibling and rename them into place. Do not
   update the manifest until every requested output succeeds.
5. Remove stale generated files when their source disappears from the manifest.
6. Add bounded worker parallelism only after measuring parser memory. Prefer
   process workers for CPU-heavy parsing and avoid creating one worker per file.

Acceptance criteria:

- A no-op transform performs zero content transformations.
- A one-file source edit rewrites only that source's outputs.
- MyST-only mode does not create or read notebook outputs.
- A failed transform leaves the previous valid output and manifest intact.

## Phase 2: make Sphinx consume the manifest and TOC

1. Keep `toctreeyaml` responsible for the navigational tree and native Sphinx
   toctree resolution. Do not duplicate document discovery in a second TOC
   implementation.
2. Use normal incremental Sphinx builds by default. Reserve `-E` for clean
   rebuilds and make `-j auto` an opt-in after checking extension safety.
3. Register generated chat pages only through the TOC or an explicit generated
   subtree; do not make Sphinx discover every artifact in `docs/chats/`.
4. Keep large aggregate documents such as `tables_and_figures.myst` as an
   explicit project choice. If their build cost dominates, split them into
   stable topic documents and include those in `_toc.yml`.
5. Ensure extensions invalidate only the documents they actually affect. The
   YAML TOC extension should record the TOC file as a dependency so changing
   `_toc.yml` invalidates the root navigation without forcing unrelated source
   rewrites.
6. Keep the Sphinx theme optional in development, but test the configured theme
   in CI so fallback behavior does not conceal a packaging failure.
7. Treat Sphinx's generated `search.html`, `_static/searchtools.js`, and
   `searchindex.js` as the static search UI contract. Do not copy Sphinx's
   versioned search assets into the repository; verify their presence in the
   built output instead.
8. Keep the optional enhanced UI behind the boolean
   `enhanced_searchtools`. Its `searchtools` configuration keeps
   native Sphinx, OxiRS, and Meilisearch results visibly separate.

Acceptance criteria:

- A source-free documentation edit does not rerun transform-md.
- A TOC-only edit rebuilds navigation and affected pages only.
- A no-op Sphinx build does not rewrite HTML files.
- The build log reports changed, copied, and skipped document counts.

## Phase 3: reduce docindex work

1. Stop treating the entire HTML output directory as the change set. Feed
   docindex the manifest's changed HTML pages, or consume Sphinx's build
   environment/inventory to identify changed documents.
2. Preserve the current project exclusion in `docs/conf.py`; generic docindex
   defaults should remain project-neutral.
3. Add an incremental index mode that upserts changed documents and deletes
   documents whose source key disappeared. Keep the existing atomic full rebuild
   as a recovery command.
4. Prefer indexing canonical MyST/chat records directly when their schema is
   sufficient. Use HTML section parsing for rendered pages that need public URL
   and heading extraction, rather than reparsing both representations.
5. For OxiRS and Meilisearch, select one backend for normal local builds. Use
   the multi-backend path only for an intentional replication run.
6. Keep batch submission and task polling asynchronous, but measure batch size,
   queue latency, retry count, and bytes submitted. Tune these against the
   selected backend rather than using one universal batch size.
7. Avoid calling optimize after every small incremental update. Schedule
   optimization after a threshold of updates or as a separate maintenance
   target.

Acceptance criteria:

- An unchanged Sphinx build submits zero index batches.
- A one-page change submits only that page and its stale replacements.
- A deleted page is removed from all relevant indices.
- Full rebuild remains available and produces the same document keys as the
  incremental path.

## Phase 4: observability and regression protection

Record per-stage metrics in `.tmp/workflow/last-run.json` and print a concise
summary:

- selected, changed, skipped, failed, and deleted files
- input/output bytes
- transform, Sphinx, parse, submit, and wait durations
- index document counts and batch counts
- cache hit rate and retry count

Add tests for manifest determinism, stale symlink cleanup, incremental output
selection, TOC dependency invalidation, and incremental index deletion. Add a
small fixture benchmark to CI; do not benchmark the full chat corpus on every
pull request.

## Recommended implementation order

1. Finish the merged `_toc.yml` schema and manifest-producing overlay command.
2. Add transform-md MyST-only and manifest-aware incremental mode.
3. Make the Makefile and `manage.py` call the same staged commands.
4. Add Sphinx changed-document instrumentation and TOC dependency tracking.
5. Add docindex incremental upsert/delete with full rebuild fallback.
6. Tune parallelism, batch sizes, and optimization thresholds from recorded
   measurements.

This order keeps the workflow behavior stable while making each performance
improvement measurable and reversible.
