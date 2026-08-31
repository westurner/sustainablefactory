from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parents[1] / "src"))
from docindex_workspace import SUBREPOS


WORKSPACE_ROOT = Path(__file__).parents[1]


def test_workspace_members_are_present():
    subrepos = WORKSPACE_ROOT / "src" / "subrepos"

    assert tuple(path.name for path in sorted(subrepos.iterdir())) == tuple(
        sorted(SUBREPOS)
    )
    assert all((subrepos / name / "pyproject.toml").is_file() for name in SUBREPOS)
