# Search Package Split Plan (src-based)

This repository now contains extraction-ready package roots under src:

- src/docindex-core
- src/docindex-sphinx
- src/docindex-cli
- src/docindex-sustainablefactory

Each directory is structured like an independent repository:

- pyproject.toml
- README.md
- src/<python_package>/

## Package Responsibilities

## docindex-core

Path: src/docindex-core
Python package: docindex_core

Contains reusable, framework-agnostic search/indexing logic:

- config models
- meilisearch API wrapper
- chat parser
- html parser
- index coordinator

## docindex-sphinx

Path: src/docindex-sphinx
Python package: docindex_sphinx

Contains Sphinx-specific integration:

- Sphinx extension hooks
- build-finished indexing lifecycle wiring

Depends on docindex-core.

## docindex-cli

Path: src/docindex-cli
Python package: docindex_cli

Contains command-line UX:

- index/search/status commands
- operational tooling for indexing workflows

Depends on docindex-core.

## docindex-sustainablefactory

Path: src/docindex-sustainablefactory
Python package: docindex_sustainablefactory

Contains project-specific implementation and compatibility wiring for this repository.

This means sustainablefactory is one implementation of the reusable docindex components.

## Extract to Separate Repositories

You can split each package root into its own repository with git subtree:

```bash
git subtree split --prefix=src/docindex-core -b split/docindex-core
git subtree split --prefix=src/docindex-sphinx -b split/docindex-sphinx
git subtree split --prefix=src/docindex-cli -b split/docindex-cli
git subtree split --prefix=src/docindex-sustainablefactory -b split/docindex-sustainablefactory
```

Then push each branch to a new remote repository:

```bash
git push <remote-core> split/docindex-core:main
git push <remote-sphinx> split/docindex-sphinx:main
git push <remote-cli> split/docindex-cli:main
git push <remote-sustainablefactory> split/docindex-sustainablefactory:main
```

## Publish Order

1. Publish docindex-core
2. Publish docindex-sphinx
3. Publish docindex-cli
4. Publish docindex-sustainablefactory

## Monorepo Compatibility

The existing monolithic module in src/docindex_integration remains present for compatibility during migration.

Additionally, the local implementation entrypoint for this repository is:

- sustainablefactory/docindex_impl.py
