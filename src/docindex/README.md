# docindex workspace

This package is the development workspace for the split docindex repositories.

The four workspace members are available under `src/subrepos/`:

- `docindex-core`
- `docindex-sphinx`
- `docindex-cli`
- `docindex-sustainablefactory`

The member directories are links to the canonical package roots in the parent
workspace. This keeps local workspace tooling and standalone package extraction
in sync without duplicating source files.

Install the workspace in editable mode with:

```bash
pip install -e ./src/docindex
```
