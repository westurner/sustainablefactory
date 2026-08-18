"""
Synonym management for Meilisearch index settings.

Provides load/save/merge operations on the synonyms.yaml data file,
plus a corpus-scanning utility that suggests new synonym candidates.
"""

from __future__ import annotations

import re
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import yaml

logger = logging.getLogger(__name__)

# Default path: synonyms.yaml alongside this module
_DEFAULT_SYNONYMS_FILE = Path(__file__).parent / "synonyms.yaml"

# Patterns for acronym discovery in free text
# Matches: "carbon nanotubes (CNT)" or "carbon nanotube (CNTs)"
_FULL_THEN_ACRONYM = re.compile(
    r"\b([A-Za-z][a-z]+(?:[-\s][a-zA-Z]+){0,5})\s+\(([A-Z]{2,6}s?)\)",
    re.UNICODE,
)
# Matches: "CNT (carbon nanotube)"
_ACRONYM_THEN_FULL = re.compile(
    r"\b([A-Z]{2,6}s?)\s*\(([a-z][a-z]+(?:[-\s][a-zA-Z]+){0,5})\)",
    re.UNICODE,
)


class SynonymsManager:
    """Load, save, merge, and discover synonyms for Meilisearch indices."""

    DEFAULT_PATH: Path = _DEFAULT_SYNONYMS_FILE

    # ---------------------------------------------------------------------------
    # I/O
    # ---------------------------------------------------------------------------

    @staticmethod
    def load(path: Optional[Path] = None) -> Dict[str, List[str]]:
        """Load synonyms from a YAML file.

        Falls back to an empty dict when the file is missing.

        Args:
            path: Path to synonyms YAML file. Defaults to the bundled
                  ``synonyms.yaml`` alongside this module.

        Returns:
            Dict mapping canonical terms to lists of synonyms.
        """
        p = path or SynonymsManager.DEFAULT_PATH
        if not p.exists():
            logger.warning("Synonyms file not found: %s", p)
            return {}
        try:
            with open(p, encoding="utf-8") as fh:
                data = yaml.safe_load(fh) or {}
            # Keep only well-formed entries (str key, list value)
            return {
                str(k): [str(s) for s in v]
                for k, v in data.items()
                if isinstance(v, list)
            }
        except yaml.YAMLError as exc:
            logger.error("Failed to parse synonyms file %s: %s", p, exc)
            return {}

    @staticmethod
    def save(
        synonyms: Dict[str, List[str]],
        path: Optional[Path] = None,
    ) -> None:
        """Save synonyms to a YAML file (sorted keys, overwriting existing).

        Note: YAML comments are not preserved on round-trip.

        Args:
            synonyms: Dict mapping canonical terms to lists of synonyms.
            path: Destination path. Defaults to the bundled ``synonyms.yaml``.
        """
        p = path or SynonymsManager.DEFAULT_PATH
        p.parent.mkdir(parents=True, exist_ok=True)
        cleaned = {k: sorted(set(v)) for k, v in sorted(synonyms.items())}
        with open(p, "w", encoding="utf-8") as fh:
            yaml.dump(cleaned, fh, default_flow_style=False, allow_unicode=True)
        logger.info("Saved %d synonym entries to %s", len(cleaned), p)

    # ---------------------------------------------------------------------------
    # Merge
    # ---------------------------------------------------------------------------

    @staticmethod
    def merge(
        base: Dict[str, List[str]],
        additions: Dict[str, List[str]],
    ) -> Dict[str, List[str]]:
        """Merge *additions* into *base*, deduplicating synonym values.

        Args:
            base: Existing synonyms dict.
            additions: New synonyms to fold in.

        Returns:
            New merged dict (base is not mutated).
        """
        result: Dict[str, List[str]] = {k: list(v) for k, v in base.items()}
        for term, syns in additions.items():
            if term in result:
                existing = set(result[term])
                result[term] = sorted(existing | set(syns))
            else:
                result[term] = sorted(set(syns))
        return result

    # ---------------------------------------------------------------------------
    # Discovery
    # ---------------------------------------------------------------------------

    @staticmethod
    def suggest_from_text(text: str) -> Dict[str, List[str]]:
        """Extract candidate synonyms from a single text string.

        Recognises patterns like:
        - ``carbon nanotubes (CNT)``  →  ``cnt: [carbon nanotubes]``
        - ``CNT (carbon nanotubes)``  →  ``cnt: [carbon nanotubes]``

        Args:
            text: Arbitrary free text (markdown, HTML, plain).

        Returns:
            Dict of candidate {acronym: [full_form, ...]} entries.
        """
        candidates: Dict[str, List[str]] = {}

        def _add(acronym: str, full: str, lowercase=False) -> None:
            if lowercase:
                key = acronym.lower().rstrip("s")  # normalise plurals
                val = full.lower().strip()
                if not val or len(val) < 4:
                    return
                if key not in candidates:
                    candidates[key] = []
                if val not in candidates[key]:
                    candidates[key].append(val)
            else:
                key = acronym.rstrip("s")  # normalise plurals
                val = full.strip()
                if not val or len(val) < 4:
                    return
                if key not in candidates:
                    candidates[key] = []
                if val not in candidates[key]:
                    candidates[key].append(val)

        for m in _FULL_THEN_ACRONYM.finditer(text):
            _add(m.group(2), m.group(1))
        for m in _ACRONYM_THEN_FULL.finditer(text):
            _add(m.group(1), m.group(2))

        return candidates

    @staticmethod
    def suggest_from_files(
        source: Path,
        extensions: Tuple[str, ...] = (".md", ".txt", ".json"),
    ) -> List[Tuple[str, str, int]]:
        """Scan *source* directory and aggregate acronym candidates.

        Args:
            source: Directory to scan recursively.
            extensions: File extensions to consider.

        Returns:
            List of ``(acronym, full_form, count)`` tuples, sorted by
            descending occurrence count.
        """
        from collections import Counter

        counts: Counter = Counter()
        for ext in extensions:
            for path in sorted(source.rglob(f"*{ext}")):
                try:
                    text = path.read_text(encoding="utf-8", errors="ignore")
                    for acronym, fulls in SynonymsManager.suggest_from_text(text).items():
                        for full in fulls:
                            counts[(acronym, full)] += 1
                except OSError as exc:
                    logger.warning("Could not read %s: %s", path, exc)

        return [(a, f, c) for (a, f), c in counts.most_common()]
