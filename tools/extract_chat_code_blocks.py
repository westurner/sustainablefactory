#!/usr/bin/env python3
"""Workspace entry point for transform_md's chat-code-block CLI."""

from __future__ import annotations

import sys
from pathlib import Path

TRANSFORM_MD_ROOT = Path(__file__).resolve().parents[1] / "src" / "transform_md"
if str(TRANSFORM_MD_ROOT) not in sys.path:
    sys.path.insert(0, str(TRANSFORM_MD_ROOT))

from transform_md.chat_code_blocks import main


if __name__ == "__main__":
    raise SystemExit(main())