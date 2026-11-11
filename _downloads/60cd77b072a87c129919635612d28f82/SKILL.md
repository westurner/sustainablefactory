---
name: upgrade-versions-pyproject
description: 'Upgrade Python package versions in pyproject.toml files to their latest releases. Use for updating project dependencies across individual or multiple pyproject.toml files.'
argument-hint: 'Which pyproject.toml file(s) should be upgraded? (file path, glob pattern, or "all")'
user-invocable: true
disable-model-invocation: false
---

# Upgrade Versions in pyproject.toml

Automatically discovers and upgrades Python package versions in `pyproject.toml` files to their latest available releases.

## When To Use
- Keep dependencies current across a repository or monorepo.
- Update multiple `pyproject.toml` files at once to avoid version mismatches.
- Systematically upgrade both pinned versions (>=X.Y.Z) and loose specifiers.
- Document version changes for review and tracking.

## Inputs
- **Target specification**: Single file path (e.g., `src/mypackage/pyproject.toml`), glob pattern (e.g., `src/*/pyproject.toml`), or literal `all` to process all pyproject.toml files in the workspace.
- **Scope preference** (optional): `dependencies-only`, `all-dependencies` (includes optional-dependencies), or default (smart detection).
- **Exclusions** (optional): Comma-separated package names to skip (e.g., `pytest,sphinx`).

## Procedure

### 1. Discover Target Files
- If input is a single file path: validate it exists.
- If input is a glob pattern: use `file_search` to find matching files.
- If input is `all`: use `file_search` with pattern `**/pyproject.toml` to discover all files.
- If no files match: report clearly and stop.

### 2. Parse pyproject.toml Files
- For each target file, read the `[project]` section.
- Identify `dependencies` array (always present).
- Identify `optional-dependencies` section if present and scope allows.
- Extract package name and current version specifier (e.g., `package>=1.0.0` → name: `package`, version: `1.0.0`).
- Filter out local paths (e.g., `-e ./local/package`) unless explicitly requested.

### 3. Query Latest Versions
- Use `pip index versions <package>` to check latest release for each package.
- Parse output to extract the `LATEST:` version line.
- Skip if package lookup fails (report as skipped with reason).
- Build a mapping of `{package_name: latest_version}`.

### 4. Plan Upgrades
- For each dependency:
  - Compare current version specifier to latest version.
  - If latest is newer: mark as upgradable.
  - If current version already equals latest: mark as already-current.
  - If current uses pre-release and latest is stable: mark as upgradable.
  - Apply exclusions list: skip packages in the exclude list.
- Summarize upgrade plan with counts (upgradable, already-current, skipped, errors).

### 5. Update pyproject.toml Files
- For each file with upgradable packages:
  - Use `replace_string_in_file` or `multi_replace_string_in_file` to update version specifiers.
  - Preserve original spacing and formatting.
  - Include 3-5 lines of unchanged context before and after each replacement.
  - Example change: `"package>=1.0.0"` → `"package>=2.5.0"`.

### 6. Verify and Report
- After all updates, read the modified files to confirm changes.
- Generate a summary table with:
  - File path
  - Package name
  - Old version specifier
  - New version specifier
  - Status (upgraded, skipped, error)
- Report any files that failed validation or had no changes.

## Example Workflow

```bash
# Upgrade a single file
Agent: Upgrade src/mypackage/pyproject.toml
→ Finds 5 dependencies
→ Queries pip for latest versions
→ Upgrades 3 packages, 2 already current
→ Shows summary table and reports success

# Upgrade all files in a monorepo
Agent: Upgrade all pyproject.toml files in this workspace
→ Discovers 8 pyproject.toml files
→ Processes each independently
→ Aggregates results with per-file summaries
```

## Implementation Notes

- **Concurrent queries**: Use `run_in_terminal` to batch multiple `pip index versions` calls efficiently.
- **Safe updates**: Always include context lines and verify exact match before replacement.
- **Error handling**: If a package lookup fails, report clearly and continue with others.
- **Idempotency**: Re-running on an already-upgraded file should report "already-current" for all packages.
- **User review**: Always show the summary table so users can verify changes before they're persisted.

## Exit Criteria

Skill completes successfully when:
1. All target files have been scanned.
2. Upgrade plan has been generated and reviewed.
3. All upgradable packages have been updated in their respective files.
4. A final summary report has been generated and shown to the user.

If target files cannot be found or all packages are already current, report this clearly without error.
