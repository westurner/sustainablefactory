"""
Glossary management: load/save glossary.yaml, generate MyST output,
and merge synonym data from synonyms.yaml.

The glossary.yaml file is the single source of truth for project term
definitions.  The generated MyST file is consumed directly by Sphinx.
"""


import logging
import re
from pathlib import Path
from string import punctuation
from typing import Any
from urllib.parse import quote, urlsplit

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
    def load(path: Path) -> dict[str, Any]:
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
    def save(data: dict[str, Any], path: Path) -> None:
        """Save glossary data to a YAML file (sorted by category then term).

        Note: YAML comments are not preserved on round-trip.

        Args:
            data: Glossary dict (``terms`` + ``categories``).
            path: Destination path.
        """
        path.parent.mkdir(parents=True, exist_ok=True)

        # Re-order terms: category order first, then alphabetical within category
        categories: dict[str, str] = data.get("categories", {})
        cat_order = {k: i for i, k in enumerate(categories)}
        terms: dict[str, Any] = data.get("terms", {})

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
        data: dict[str, Any],
        synonyms: dict[str, list[str]],
    ) -> dict[str, Any]:
        """Fold synonym mappings into the glossary term entries.

        For each synonym key that matches (case-insensitively) an existing
        glossary term, the syList[nonym values are added to that term's ``synonyms``
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
        lower_map: dict[str, str] = {k.lower(): k for k in terms}

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
    def _escape_markdown(value: Any, allowed_punctuation: str = "") -> str:
        text = str(value).replace("\r", " ").replace("\n", " ").replace("\t", " ")
        return "".join(
            f"\\{char}"
            if char in punctuation and char not in allowed_punctuation
            else char
            for char in text
        )

    @staticmethod
    def _render_attribute_scalar(
        attribute: str, value: Any, categories: dict[str, str]
    ) -> str:
        attribute_name = attribute.lower()
        if attribute_name == "wikipedia" and isinstance(value, str):
            parsed_url = urlsplit(value)
            if parsed_url.scheme.lower() in {"http", "https"} and parsed_url.netloc:
                safe_url = quote(value, safe=":/?#[]@!$&'()*+,;=%")
                return f"<{safe_url}>"

        if attribute_name == "related" and isinstance(value, str):
            target = value.strip()
            if target and all(char.isalnum() or char in " _'.-" for char in target):
                return f"{{term}}`{target}`"
        if attribute_name == "definedby":
            return GlossaryManager._escape_markdown(
                value, allowed_punctuation="{}:`"
            )
        if attribute_name == "synonyms":
            return f"*{GlossaryManager._escape_markdown(value)}*"
        if attribute_name == "category" and isinstance(value, str):
            value = categories.get(value, value)

        return GlossaryManager._escape_markdown(value)

    @staticmethod
    def _render_attribute_items(
        attribute: str,
        value: Any,
        categories: dict[str, str],
        indent: str,
    ) -> list[str]:
        lines: list[str] = []
        if isinstance(value, (list, tuple)):
            for item in value:
                if item is None or item == "" or item == [] or item == {}:
                    continue
                if isinstance(item, (list, tuple, dict)):
                    lines.append(f"{indent}-")
                    lines.extend(
                        GlossaryManager._render_attribute_items(
                            attribute, item, categories, indent + "  "
                        )
                    )
                else:
                    rendered = GlossaryManager._render_attribute_scalar(
                        attribute, item, categories
                    )
                    lines.append(f"{indent}- {rendered}")
            return lines

        if isinstance(value, dict):
            for key, item in value.items():
                if item is None or item == "" or item == [] or item == {}:
                    continue
                if isinstance(item, (list, tuple, dict)):
                    lines.append(
                        f"{indent}- **{GlossaryManager._escape_markdown(key)}:**"
                    )
                    lines.extend(
                        GlossaryManager._render_attribute_items(
                            str(key), item, categories, indent + "  "
                        )
                    )
                else:
                    rendered = GlossaryManager._render_attribute_scalar(
                        str(key), item, categories
                    )
                    lines.append(
                        f"{indent}- **{GlossaryManager._escape_markdown(key)}:** "
                        f"{rendered}"
                    )
        return lines

    @staticmethod
    def to_myst(
        data: dict[str, Any],
        source_path: Path|None = None,
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
        categories: dict[str, str] = data.get("categories", {})
        terms: dict[str, Any] = data.get("terms", {})

        source_name = source_path.name if source_path else "glossary.yaml"
        lines: list[str] = []

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
        groups: dict[str, list[str]] = {k: [] for k in cat_order}
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
            category_lines: List[str] = []

            for term_key in term_keys:
                entry = terms[term_key]
                if not isinstance(entry, dict):
                    continue

                definition = (entry.get("definition") or "").strip()
                if not definition:
                    continue

                # Term line
                category_lines.append(term_key)

                # Definition — each line indented three spaces
                for def_line in definition.splitlines():
                    category_lines.append(
                        f"   {def_line}" if def_line.strip() else ""
                    )

                attributes = [
                    (name, value)
                    for name, value in entry.items()
                    if name != "definition"
                    and value is not None
                    and value != ""
                    and value != []
                    and value != {}
                ]
                if attributes:
                    category_lines.append("")
                    for name, value in attributes:
                        label = {"synonyms": "Also known as", "related": "See also"}.get(
                            name, name
                        )
                        escaped_label = GlossaryManager._escape_markdown(label)
                        if isinstance(value, (list, tuple, dict)):
                            category_lines.append(f"   - **{escaped_label}:**")
                            category_lines.extend(
                                GlossaryManager._render_attribute_items(
                                    name, value, categories, "     "
                                )
                            )
                        else:
                            rendered = GlossaryManager._render_attribute_scalar(
                                name, value, categories
                            )
                            category_lines.append(
                                f"   - **{escaped_label}:** {rendered}"
                            )

                category_lines.append("")  # blank line between entries

            longest_fence = max(
                (len(run) for run in re.findall(r"`+", "\n".join(category_lines))),
                default=0,
            )
            fence = "`" * max(3, longest_fence + 1)
            lines.append(f"{fence}{{glossary}}")
            lines.extend(category_lines)
            lines.append(fence)
            lines.append("")  # blank line after block

        return "\n".join(lines)

    # -------------------------------------------------------------------------
    # Diff-aware write
    # -------------------------------------------------------------------------

    @staticmethod
    def write_myst_if_changed(
        data: dict[str, Any],
        output_path: Path,
        source_path: Path|None = None,
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
    def extract_synonyms(data: dict[str, Any]) -> dict[str, list[str]]:
        """Extract synonym mappings from glossary data.

        Useful for seeding or updating ``synonyms.yaml`` from glossary entries.

        Args:
            data: Glossary dict.

        Returns:
            Dict compatible with :class:`~docindex_core.SynonymsManager`.
        """
        result: dict[str, list[str]] = {}
        for term_key, entry in data.get("terms", {}).items():
            if not isinstance(entry, dict):
                continue
            syns = entry.get("synonyms") or []
            if syns:
                result[term_key.lower()] = sorted(set(syns))
        return result
