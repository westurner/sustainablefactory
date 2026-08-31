"""
Glossary management: load/save glossary.yaml, generate MyST output,
and merge synonym data from synonyms.yaml.

The glossary.yaml file is the single source of truth for project term
definitions.  The generated MyST file is consumed directly by Sphinx.
"""

from __future__ import annotations

import logging
from pathlib import Path
from typing import Dict, List, Optional, Any

import yaml

logger = logging.getLogger(__name__)

# Sentinel used in generated files so tooling can identify them
_GENERATED_MARKER = "AUTO-GENERATED from glossary.yaml"


class GlossaryManager:
    """Load, save, merge, and render the project glossary.

    The YAML schema understood by this class::

        categories:           # ordered dict of id → display label
          knowledge-representation: Knowledge Representation
          materials: Materials & Chemistry

        terms:
          IOF:                # canonical label for Sphinx :term:`IOF`
            definition: |
              Industrial Ontologies Foundry — ...
            synonyms:         # optional; fed to Meilisearch synonyms too
              - industrial ontology foundry
            abbreviation: IOF # optional
            related:          # optional list of other term keys
              - BFO
            category: knowledge-representation  # optional
    """

    # -------------------------------------------------------------------------
    # I/O
    # -------------------------------------------------------------------------

    @staticmethod
    def load(path: Path) -> Dict[str, Any]:
        """Load a glossary YAML file.

        Args:
            path: Path to the ``glossary.yaml`` file.

        Returns:
            Dict with ``terms`` and optionally ``categories`` keys.

        Raises:
            FileNotFoundError: If *path* does not exist.
            ValueError: If the YAML is malformed.
        """
        if not path.exists():
            raise FileNotFoundError(f"Glossary file not found: {path}")
        try:
            with open(path, encoding="utf-8") as fh:
                data = yaml.safe_load(fh) or {}
        except yaml.YAMLError as exc:
            raise ValueError(f"Failed to parse glossary YAML {path}: {exc}") from exc

        if "terms" not in data:
            data["terms"] = {}
        if "categories" not in data:
            data["categories"] = {}
        return data

    @staticmethod
    def save(data: Dict[str, Any], path: Path) -> None:
        """Save glossary data to a YAML file (sorted by category then term).

        Note: YAML comments are not preserved on round-trip.

        Args:
            data: Glossary dict (``terms`` + ``categories``).
            path: Destination path.
        """
        path.parent.mkdir(parents=True, exist_ok=True)

        # Re-order terms: category order first, then alphabetical within category
        categories: Dict[str, str] = data.get("categories", {})
        cat_order = {k: i for i, k in enumerate(categories)}
        terms: Dict[str, Any] = data.get("terms", {})

        def _sort_key(item):
            entry = item[1] if isinstance(item[1], dict) else {}
            cat = entry.get("category", "")
            return (cat_order.get(cat, 999), item[0].lower())

        sorted_terms = dict(sorted(terms.items(), key=_sort_key))
        out = {"categories": categories, "terms": sorted_terms}

        with open(path, "w", encoding="utf-8") as fh:
            yaml.dump(
                out, fh, default_flow_style=False, allow_unicode=True, sort_keys=False
            )
        logger.info("Saved glossary (%d terms) to %s", len(sorted_terms), path)

    # -------------------------------------------------------------------------
    # Merge
    # -------------------------------------------------------------------------

    @staticmethod
    def merge_synonyms(
        data: Dict[str, Any],
        synonyms: Dict[str, List[str]],
    ) -> Dict[str, Any]:
        """Fold synonym mappings into the glossary term entries.

        For each synonym key that matches (case-insensitively) an existing
        glossary term, the synonym values are added to that term's ``synonyms``
        list.  Unmatched synonym keys are silently skipped (they are
        Meilisearch-only entries with no glossary definition yet).

        Args:
            data: Glossary dict (not mutated).
            synonyms: Dict from :class:`~docindex_core.SynonymsManager.load`.

        Returns:
            New glossary dict with synonym lists enriched.
        """
        import copy

        result = copy.deepcopy(data)
        terms = result.setdefault("terms", {})

        # Build a lowercase key → canonical key lookup
        lower_map: Dict[str, str] = {k.lower(): k for k in terms}

        for syn_key, syn_values in synonyms.items():
            canonical = lower_map.get(syn_key.lower())
            if canonical is None:
                continue
            entry = terms[canonical]
            if not isinstance(entry, dict):
                continue
            existing = set(entry.get("synonyms") or [])
            entry["synonyms"] = sorted(existing | set(syn_values))

        return result

    # -------------------------------------------------------------------------
    # MyST generation
    # -------------------------------------------------------------------------

    @staticmethod
    def to_myst(
        data: Dict[str, Any],
        source_path: Optional[Path] = None,
        label: str = "glossary",
        title: str = "Glossary",
    ) -> str:
        """Render glossary data as a MyST Markdown document for Sphinx.

        Terms are grouped into ``{glossary}`` blocks by category (uncategorised
        terms appear last).  Within each group terms are sorted alphabetically.

        Args:
            data: Glossary dict from :meth:`load`.
            source_path: Path of the YAML file (used in the header comment).
            label: Sphinx cross-reference label placed above the H1 heading.
            title: H1 heading text.

        Returns:
            String containing the complete MyST document.
        """
        categories: Dict[str, str] = data.get("categories", {})
        terms: Dict[str, Any] = data.get("terms", {})

        source_name = source_path.name if source_path else "glossary.yaml"
        lines: List[str] = []

        # ── Header ────────────────────────────────────────────────────────────
        lines += [
            f"({label})=",
            f"# {title}",
            "",
            f"% {_GENERATED_MARKER}",
            f"% Source: {source_name}",
            "% Run `docindex generate-glossary` to update.",
            "",
        ]

        # ── Group terms by category ───────────────────────────────────────────
        cat_order = list(categories.keys())
        groups: Dict[str, List[str]] = {k: [] for k in cat_order}
        groups["_uncategorised"] = []

        for term_key in sorted(terms.keys(), key=str.lower):
            entry = terms[term_key]
            cat = entry.get("category", "") if isinstance(entry, dict) else ""
            if cat in groups:
                groups[cat].append(term_key)
            else:
                groups["_uncategorised"].append(term_key)

        # ── Render each category group ─────────────────────────────────────────
        for cat_key, cat_label in list(categories.items()) + [
            ("_uncategorised", "Other")
        ]:
            term_keys = groups.get(cat_key, [])
            if not term_keys:
                continue

            lines += [f"## {cat_label}", ""]
            lines += ["```{glossary}"]

            for term_key in term_keys:
                entry = terms[term_key]
                if not isinstance(entry, dict):
                    continue

                definition = (entry.get("definition") or "").strip()
                if not definition:
                    continue

                # Term line
                lines.append(term_key)

                # Definition — each line indented three spaces
                for def_line in definition.splitlines():
                    lines.append(f"   {def_line}" if def_line.strip() else "")

                # Optional synonym note (inline, italic)
                synonyms = entry.get("synonyms")
                if synonyms:
                    syn_str = ", ".join(f"*{s}*" for s in synonyms)
                    lines.append(f"   *Also known as*: {syn_str}.")

                # Optional related terms cross-reference
                related = entry.get("related")
                if related:
                    rel_str = ", ".join(f"{{term}}`{r}`" for r in related)
                    lines.append(f"   *See also*: {rel_str}.")

                lines.append("")  # blank line between entries

            lines.append("```")
            lines.append("")  # blank line after block

        return "\n".join(lines)

    # -------------------------------------------------------------------------
    # Diff-aware write
    # -------------------------------------------------------------------------

    @staticmethod
    def write_myst_if_changed(
        data: Dict[str, Any],
        output_path: Path,
        source_path: Optional[Path] = None,
        **kwargs,
    ) -> bool:
        """Write the MyST file only when the content has changed.

        Args:
            data: Glossary dict.
            output_path: Destination ``.md`` file.
            source_path: YAML source path (for the header comment).
            **kwargs: Passed through to :meth:`to_myst`.

        Returns:
            ``True`` if the file was written, ``False`` if unchanged.
        """
        content = GlossaryManager.to_myst(data, source_path=source_path, **kwargs)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        if output_path.exists():
            existing = output_path.read_text(encoding="utf-8")
            if existing == content:
                logger.debug("Glossary unchanged: %s", output_path)
                return False

        output_path.write_text(content, encoding="utf-8")
        logger.info("Wrote glossary to %s", output_path)
        return True

    # -------------------------------------------------------------------------
    # Synonym extraction (reverse: glossary → synonyms dict)
    # -------------------------------------------------------------------------

    @staticmethod
    def extract_synonyms(data: Dict[str, Any]) -> Dict[str, List[str]]:
        """Extract synonym mappings from glossary data.

        Useful for seeding or updating ``synonyms.yaml`` from glossary entries.

        Args:
            data: Glossary dict.

        Returns:
            Dict compatible with :class:`~docindex_core.SynonymsManager`.
        """
        result: Dict[str, List[str]] = {}
        for term_key, entry in data.get("terms", {}).items():
            if not isinstance(entry, dict):
                continue
            syns = entry.get("synonyms") or []
            if syns:
                result[term_key.lower()] = sorted(set(syns))
        return result
