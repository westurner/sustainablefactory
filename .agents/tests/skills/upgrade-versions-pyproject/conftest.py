import tempfile
from pathlib import Path
import pytest


@pytest.fixture
def temp_workspace():
    """Create a temporary workspace directory."""
    with tempfile.TemporaryDirectory() as tmpdir:
        yield Path(tmpdir)


@pytest.fixture
def sample_pyproject_content():
    """Sample pyproject.toml content."""
    return """[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "test-package"
version = "0.1.0"
description = "Test package"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
  "click>=8.1.0",
  "pytest>=7.0.0",
  "requests>=2.25.0"
]

[project.optional-dependencies]
dev = [
  "sphinx>=5.0.0",
  "black>=22.0.0"
]
"""


@pytest.fixture
def sample_pyproject_with_locals():
    """pyproject.toml with local path dependencies."""
    return """[project]
name = "test-package"
dependencies = [
  "-e ./local/package",
  "click>=8.1.0",
  "external-pkg>=1.0.0"
]
"""


@pytest.fixture
def sample_pyproject_with_extras():
    """pyproject.toml with optional dependencies."""
    return """[project]
name = "test-package"
dependencies = [
  "package1>=1.0.0",
  "package2>=2.0.0"
]

[project.optional-dependencies]
test = [
  "pytest>=7.0.0",
  "coverage>=6.0.0"
]

docs = [
  "sphinx>=5.0.0"
]
"""
