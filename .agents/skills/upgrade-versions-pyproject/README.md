# upgrade-versions-pyproject Skill

This skill helps upgrade Python package versions in `pyproject.toml` files to their latest releases.

## Quick Start

### Invoke as an Agent Skill

Ask the agent to upgrade pyproject.toml files:

```
@agent Upgrade all pyproject.toml files in src/*/
```

Or for a single file:

```
@agent Upgrade src/docindex-cli/pyproject.toml
```

### Use the Helper Script Directly

```bash
# Plan upgrades for all pyproject.toml files
python .agents/skills/upgrade-versions-pyproject/scripts/plan_upgrades.py --format table

# Plan upgrades for a specific glob pattern
python .agents/skills/upgrade-versions-pyproject/scripts/plan_upgrades.py \
  --target 'src/*/pyproject.toml' \
  --format json

# Plan upgrades excluding certain packages
python .agents/skills/upgrade-versions-pyproject/scripts/plan_upgrades.py \
  --target all \
  --exclude pytest,sphinx \
  --format table
```

## How It Works

1. **Discover** - Finds all target `pyproject.toml` files (single file, glob pattern, or all files)
2. **Parse** - Extracts dependencies from each file's `[project]` section
3. **Query** - Checks the latest available version for each package using `pip index`
4. **Plan** - Builds an upgrade plan comparing current vs. latest versions
5. **Update** - Applies updates to pyproject.toml files (when invoked as skill)
6. **Report** - Generates a summary of changes

## Features

- **Multi-file support**: Upgrade multiple `pyproject.toml` files at once
- **Selective upgrades**: Skip specific packages with `--exclude`
- **Safe updates**: Preserves formatting and includes context lines in replacements
- **Clear reporting**: Summary table showing old → new versions
- **Flexible discovery**: Support for glob patterns and single files

## Script Options

| Flag | Description |
|------|-------------|
| `--target` | File path, glob pattern, or `all` (default: `all`) |
| `--exclude` | Comma-separated package names to skip |
| `--format` | Output format: `table` or `json` (default: `table`) |
| `--workspace` | Workspace root directory (default: current dir) |

## Example Output

```
src/docindex-cli/pyproject.toml
--------------------------------------------------------------------------------
  Upgradable (5):
    click: 8.1.0 → 8.4.1
    python-dotenv: 1.0.0 → 1.2.2
    markdown: 3.4.0 → 3.10.2
    bleach: 6.0.0 → 6.4.0
    markdownify: 0.11.0 → 1.2.2

  Already Current (2):
    docindex-core: 0.1.0
    requests: 2.31.0

================================================================================
Summary: 5 upgradable, 2 current, 0 errors
```

## Implementation Details

When invoked as a skill, the agent will:

1. Run the planning script to generate an upgrade plan
2. Show you the summary before making changes
3. Apply updates using `multi_replace_string_in_file` for efficiency
4. Verify the changes were applied correctly
5. Report the final status

## Troubleshooting

**Package lookup fails**: Check that the package name is correct and the package is published on PyPI.

**Already-current version doesn't update**: The helper script detects if a version is already at the latest; re-running is safe.

**Permission denied on script**: Make the script executable: `chmod +x .agents/skills/upgrade-versions-pyproject/scripts/plan_upgrades.py`

## Integration with Other Skills

This skill works well with:
- **agent-customization**: Store upgrade preferences in your project's agent config
- **suggest-fix-issue**: Automate dependency updates as part of CI/CD

## See Also

- [SKILL.md](./SKILL.md) - Full skill definition and workflow
- [Scripts](./scripts/) - Helper utilities
