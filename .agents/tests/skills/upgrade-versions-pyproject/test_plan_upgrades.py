import sys
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest

# Import the functions from the script
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / "skills" / "upgrade-versions-pyproject" / "scripts"))
from plan_upgrades import (
    find_pyproject_files,
    parse_pyproject_dependencies,
    extract_version_number,
    get_latest_version,
    plan_upgrades,
)


class TestFindPyprojectFiles:
    """Tests for find_pyproject_files()"""
    
    def test_find_single_file(self, temp_workspace, sample_pyproject_content):
        """Test finding a single pyproject.toml file."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_content)
        
        result = find_pyproject_files("pyproject.toml", temp_workspace)
        assert len(result) == 1
        assert result[0].name == "pyproject.toml"
    
    def test_find_single_file_not_exists(self, temp_workspace):
        """Test finding a nonexistent single file returns empty list."""
        result = find_pyproject_files("nonexistent.toml", temp_workspace)
        assert result == []
    
    def test_find_glob_pattern(self, temp_workspace, sample_pyproject_content):
        """Test finding files matching a glob pattern."""
        # Create nested structure
        (temp_workspace / "src" / "pkg1").mkdir(parents=True)
        (temp_workspace / "src" / "pkg2").mkdir(parents=True)
        
        (temp_workspace / "src" / "pkg1" / "pyproject.toml").write_text(sample_pyproject_content)
        (temp_workspace / "src" / "pkg2" / "pyproject.toml").write_text(sample_pyproject_content)
        
        result = find_pyproject_files("src/*/pyproject.toml", temp_workspace)
        assert len(result) == 2
        assert all(p.name == "pyproject.toml" for p in result)
    
    def test_find_all_pyproject_files(self, temp_workspace, sample_pyproject_content):
        """Test finding all pyproject.toml files with 'all' keyword."""
        (temp_workspace / "pyproject.toml").write_text(sample_pyproject_content)
        (temp_workspace / "src" / "pkg").mkdir(parents=True)
        (temp_workspace / "src" / "pkg" / "pyproject.toml").write_text(sample_pyproject_content)
        (temp_workspace / "tools").mkdir()
        (temp_workspace / "tools" / "pyproject.toml").write_text(sample_pyproject_content)
        
        result = find_pyproject_files("all", temp_workspace)
        assert len(result) == 3


class TestParseProjectDependencies:
    """Tests for parse_pyproject_dependencies()"""
    
    def test_parse_basic_dependencies(self, temp_workspace, sample_pyproject_content):
        """Test parsing basic dependencies."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_content)
        
        deps = parse_pyproject_dependencies(pyproject)
        assert "click" in deps
        assert deps["click"] == ">=8.1.0"
        assert "pytest" in deps
        assert deps["pytest"] == ">=7.0.0"
        assert "requests" in deps
    
    def test_parse_skips_local_paths(self, temp_workspace, sample_pyproject_with_locals):
        """Test that local paths (-e ./local) are skipped."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_with_locals)
        
        deps = parse_pyproject_dependencies(pyproject)
        assert "click" in deps
        assert "external-pkg" in deps
        # Local path should not be in deps
        assert not any("local" in str(k).lower() for k in deps.keys())
    
    def test_parse_invalid_toml(self, temp_workspace):
        """Test parsing invalid TOML file."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text("invalid toml [[[")
        
        deps = parse_pyproject_dependencies(pyproject)
        assert deps == {}
    
    def test_parse_missing_project_section(self, temp_workspace):
        """Test parsing file without [project] section."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text("[build-system]\nrequires = []")
        
        deps = parse_pyproject_dependencies(pyproject)
        assert deps == {}
    
    def test_parse_no_dependencies(self, temp_workspace):
        """Test parsing file with [project] but no dependencies."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text("[project]\nname = 'test'")
        
        deps = parse_pyproject_dependencies(pyproject)
        assert deps == {}


class TestExtractVersionNumber:
    """Tests for extract_version_number()"""
    
    def test_extract_from_gte_specifier(self):
        """Test extracting version from >= specifier."""
        version = extract_version_number(">=8.1.0")
        assert version == "8.1.0"
    
    def test_extract_from_lte_specifier(self):
        """Test extracting version from <= specifier."""
        version = extract_version_number("<=2.5.3")
        assert version == "2.5.3"
    
    def test_extract_from_exact_version(self):
        """Test extracting from exact version (==)."""
        version = extract_version_number("==1.2.3")
        assert version == "1.2.3"
    
    def test_extract_from_tilde_specifier(self):
        """Test extracting from ~= specifier."""
        version = extract_version_number("~=3.4.5")
        assert version == "3.4.5"
    
    def test_extract_two_digit_version(self):
        """Test extracting two-digit version (X.Y)."""
        version = extract_version_number(">=1.5")
        assert version == "1.5"
    
    def test_extract_from_empty_string(self):
        """Test extracting from empty string."""
        version = extract_version_number("")
        assert version is None
    
    def test_extract_from_no_version(self):
        """Test extracting from specifier without version."""
        version = extract_version_number(">==")
        assert version is None


class TestGetLatestVersion:
    """Tests for get_latest_version() with mocking"""
    
    @patch("plan_upgrades.subprocess.run")
    def test_get_latest_version_success(self, mock_run):
        """Test successfully getting latest version."""
        mock_run.return_value = MagicMock(
            stdout="Available versions: 8.4.1, 8.4.0\n  INSTALLED: 8.4.1\n  LATEST: 8.4.1\n"
        )
        
        version = get_latest_version("click")
        assert version == "8.4.1"
    
    @patch("plan_upgrades.subprocess.run")
    def test_get_latest_version_multi_digit(self, mock_run):
        """Test getting latest version with complex version numbers."""
        mock_run.return_value = MagicMock(
            stdout="  LATEST:    3.10.2\n"
        )
        
        version = get_latest_version("markdown")
        assert version == "3.10.2"
    
    @patch("plan_upgrades.subprocess.run")
    def test_get_latest_version_not_found(self, mock_run):
        """Test handling when latest version is not found."""
        mock_run.return_value = MagicMock(stdout="Available versions: ...")
        
        version = get_latest_version("nonexistent-package")
        assert version is None
    
    @patch("plan_upgrades.subprocess.run")
    def test_get_latest_version_exception(self, mock_run):
        """Test handling subprocess exceptions."""
        mock_run.side_effect = Exception("Network error")
        
        version = get_latest_version("click")
        assert version is None


class TestPlanUpgrades:
    """Tests for plan_upgrades()"""
    
    @patch("plan_upgrades.get_latest_version")
    def test_plan_upgradable_packages(self, mock_get_latest, temp_workspace, sample_pyproject_content):
        """Test planning upgrades for outdated packages."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_content)
        
        # Mock: click has upgrade, pytest is current, requests has upgrade
        def mock_latest(package):
            versions = {
                "click": "8.4.1",
                "pytest": "7.0.0",
                "requests": "2.31.0"
            }
            return versions.get(package)
        
        mock_get_latest.side_effect = mock_latest
        
        plan = plan_upgrades(pyproject)
        
        assert plan["file"] == str(pyproject)
        assert len(plan["upgrades"]) == 2  # click and requests
        assert len(plan["already_current"]) == 1  # pytest
        
        # Check specific upgrades
        upgrade_names = {u["package"] for u in plan["upgrades"]}
        assert "click" in upgrade_names
        assert "requests" in upgrade_names
    
    @patch("plan_upgrades.get_latest_version")
    def test_plan_with_exclusions(self, mock_get_latest, temp_workspace, sample_pyproject_content):
        """Test excluding specific packages from upgrade."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_content)
        
        mock_get_latest.return_value = "999.0.0"  # All "upgradable"
        
        plan = plan_upgrades(pyproject, exclude=["click", "pytest"])
        
        assert len(plan["skipped"]) == 2
        assert all(s["reason"] == "excluded" for s in plan["skipped"])
        assert len(plan["upgrades"]) == 1  # Only requests
    
    @patch("plan_upgrades.get_latest_version")
    def test_plan_handles_version_lookup_errors(self, mock_get_latest, temp_workspace, sample_pyproject_content):
        """Test handling errors when looking up versions."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_content)
        
        def mock_latest(package):
            if package == "click":
                return None  # Simulates lookup failure
            return "999.0.0"
        
        mock_get_latest.side_effect = mock_latest
        
        plan = plan_upgrades(pyproject)
        
        assert len(plan["errors"]) == 1
        assert plan["errors"][0]["package"] == "click"
        assert len(plan["upgrades"]) == 2  # pytest and requests still work
    
    @patch("plan_upgrades.get_latest_version")
    def test_plan_all_current(self, mock_get_latest, temp_workspace, sample_pyproject_content):
        """Test case where all packages are already current."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_content)
        
        def mock_latest(package):
            versions = {
                "click": "8.1.0",
                "pytest": "7.0.0",
                "requests": "2.25.0"
            }
            return versions.get(package)
        
        mock_get_latest.side_effect = mock_latest
        
        plan = plan_upgrades(pyproject)
        
        assert len(plan["upgrades"]) == 0
        assert len(plan["already_current"]) == 3
        assert len(plan["errors"]) == 0


class TestIntegration:
    """Integration tests for the full workflow"""
    
    @patch("plan_upgrades.get_latest_version")
    def test_full_upgrade_workflow(self, mock_get_latest, temp_workspace, sample_pyproject_content):
        """Test the full discovery → parse → plan workflow."""
        # Create multiple pyproject.toml files
        (temp_workspace / "pyproject.toml").write_text(sample_pyproject_content)
        (temp_workspace / "src" / "pkg").mkdir(parents=True)
        (temp_workspace / "src" / "pkg" / "pyproject.toml").write_text(sample_pyproject_content)
        
        # Mock latest versions
        mock_get_latest.return_value = "999.0.0"
        
        # Discover all files
        files = find_pyproject_files("all", temp_workspace)
        assert len(files) == 2
        
        # Plan upgrades for each
        all_plans = [plan_upgrades(f) for f in files]
        assert len(all_plans) == 2
        
        # Each should have 3 upgradable packages
        assert all(len(p["upgrades"]) == 3 for p in all_plans)
    
    @patch("plan_upgrades.get_latest_version")
    def test_workflow_with_mixed_results(self, mock_get_latest, temp_workspace, sample_pyproject_content):
        """Test workflow with mixed upgrade/current/error scenarios."""
        pyproject = temp_workspace / "pyproject.toml"
        pyproject.write_text(sample_pyproject_content)
        
        def mock_latest(package):
            if package == "click":
                return "8.4.1"  # Upgrade available
            elif package == "pytest":
                return "7.0.0"  # Already current
            else:  # requests
                return None  # Error looking up
        
        mock_get_latest.side_effect = mock_latest
        
        plan = plan_upgrades(pyproject)
        
        # Check all three scenarios are represented
        assert len(plan["upgrades"]) == 1
        assert len(plan["already_current"]) == 1
        assert len(plan["errors"]) == 1
        assert len(plan["skipped"]) == 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
