# Tests for upgrade-versions-pyproject Skill

This directory contains tests for the `upgrade-versions-pyproject` skill's helper script.

## Running Tests

### Run all tests
```bash
pytest .agents/tests/skills/upgrade-versions-pyproject/ -v
```

### Run specific test class
```bash
pytest .agents/tests/skills/upgrade-versions-pyproject/test_plan_upgrades.py::TestFindPyprojectFiles -v
```

### Run specific test
```bash
pytest .agents/tests/skills/upgrade-versions-pyproject/test_plan_upgrades.py::TestFindPyprojectFiles::test_find_single_file -v
```

### Run with coverage
```bash
pytest .agents/tests/skills/upgrade-versions-pyproject/ -v --cov=.agents/skills/upgrade-versions-pyproject/scripts --cov-report=html
```

## Test Structure

### conftest.py
Pytest fixtures for:
- `temp_workspace` - Temporary directory for file operations
- `sample_pyproject_content` - Standard pyproject.toml content
- `sample_pyproject_with_locals` - pyproject.toml with local path dependencies
- `sample_pyproject_with_extras` - pyproject.toml with optional dependencies

### test_plan_upgrades.py

**TestFindPyprojectFiles**
- `test_find_single_file` - Finding a single pyproject.toml
- `test_find_single_file_not_exists` - Handling nonexistent files
- `test_find_glob_pattern` - Using glob patterns
- `test_find_all_pyproject_files` - Finding all files with "all" keyword

**TestParseProjectDependencies**
- `test_parse_basic_dependencies` - Parsing standard dependencies
- `test_parse_skips_local_paths` - Correctly skipping local paths (-e ./...)
- `test_parse_invalid_toml` - Handling invalid TOML
- `test_parse_missing_project_section` - Handling missing [project] section
- `test_parse_no_dependencies` - Handling files without dependencies

**TestExtractVersionNumber**
- `test_extract_from_gte_specifier` - Extracting from >= specifiers
- `test_extract_from_lte_specifier` - Extracting from <= specifiers
- `test_extract_from_exact_version` - Extracting from == specifiers
- `test_extract_from_tilde_specifier` - Extracting from ~= specifiers
- `test_extract_two_digit_version` - Handling two-digit versions (X.Y)
- `test_extract_from_empty_string` - Handling empty strings
- `test_extract_from_no_version` - Handling invalid specs

**TestGetLatestVersion**
- `test_get_latest_version_success` - Successfully retrieving latest version
- `test_get_latest_version_multi_digit` - Handling complex version numbers
- `test_get_latest_version_not_found` - Handling missing versions
- `test_get_latest_version_exception` - Handling subprocess exceptions

**TestPlanUpgrades**
- `test_plan_upgradable_packages` - Identifying upgradable packages
- `test_plan_with_exclusions` - Excluding specific packages
- `test_plan_handles_version_lookup_errors` - Handling lookup failures
- `test_plan_all_current` - Case where all packages are current

**TestIntegration**
- `test_full_upgrade_workflow` - Full discovery → parse → plan workflow
- `test_workflow_with_mixed_results` - Mixed upgrade/current/error scenarios

## Mocking

Tests use `unittest.mock` to mock:
- `subprocess.run()` for `pip index versions` calls
- File system operations via temporary directories

This allows tests to run without needing real network calls or modifying actual files.

## Adding New Tests

When adding new functionality to `plan_upgrades.py`:

1. Add fixtures to `conftest.py` if needed
2. Create a new test class in `test_plan_upgrades.py`
3. Use `@patch` decorators for external dependencies
4. Use `temp_workspace` fixture for file operations
5. Document expected behavior in test docstrings

## CI Integration

These tests can be integrated into CI/CD pipelines:

```bash
# Run tests and fail on coverage drop
pytest .agents/tests/ --cov --cov-fail-under=80
```
