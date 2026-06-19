"""
CLI interface for Meilisearch integration.
"""

import logging
import sys
from pathlib import Path
from typing import Optional

import click

from docindex_core import (
    DocumentIndexer,
    MeilisearchClient,
    MeilisearchConfig,
    SynonymsManager,
    GlossaryManager,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@click.group()
@click.option(
    '--host',
    default='localhost',
    help='Meilisearch host'
)
@click.option(
    '--port',
    type=int,
    default=7700,
    help='Meilisearch port'
)
@click.option(
    '--api-key',
    default=None,
    help='Meilisearch API key'
)
@click.pass_context
def cli(ctx, host: str, port: int, api_key: Optional[str]):
    """Meilisearch integration CLI for Sphinx documentation."""
    ctx.ensure_object(dict)
    ctx.obj['config'] = MeilisearchConfig(
        host=host,
        port=port,
        api_key=api_key
    )


@cli.command()
@click.option(
    '--source',
    type=click.Path(exists=True, path_type=Path),
    required=True,
    help='Directory containing chat files'
)
@click.option(
    '--batch-size',
    type=int,
    default=1000,
    help='Batch size for indexing'
)
@click.option(
    '--skip-unchanged',
    is_flag=True,
    help='Skip unchanged files'
)
@click.pass_context
def index_chats(ctx, source: Path, batch_size: int, skip_unchanged: bool):
    """Index chat exports to Meilisearch."""
    config = ctx.obj['config']
    config.batch_size = batch_size
    
    try:
        indexer = DocumentIndexer(config)
        stats = indexer.index_chat_directory(source, skip_unchanged=skip_unchanged)
        
        click.echo("\n✓ Chat indexing complete")
        click.echo(f"  Total: {stats.total_documents}")
        click.echo(f"  Indexed: {stats.indexed_documents}")
        click.echo(f"  Success rate: {stats.success_rate:.1f}%")
        click.echo(f"  Duration: {stats.duration_seconds:.1f}s")
    
    except Exception as e:  # pragma: no cover
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command(name='index-html')
@click.option(
    '--source',
    type=click.Path(exists=True, path_type=Path),
    required=True,
    help='Sphinx _build/html directory'
)
@click.option(
    '--headings',
    type=str,
    default='1-3',
    help='Heading levels to extract (e.g., 1-3)'
)
@click.option(
    '--exclude',
    multiple=True,
    help='Exclude page patterns'
)
@click.option(
    '--max-retries',
    type=int,
    default=3,
    help='Maximum retry attempts per batch (exponential backoff)'
)
@click.option(
    '--retry-delay',
    type=float,
    default=1.0,
    help='Base delay in seconds between retries'
)
@click.option(
    '--staging-suffix',
    type=str,
    default='_staging',
    help='Suffix for staging index names'
)
@click.pass_context
def index_html(
    ctx,
    source: Path,
    headings: str,
    exclude: tuple,
    max_retries: int,
    retry_delay: float,
    staging_suffix: str,
):
    """Index Sphinx HTML to Meilisearch with atomic guarantees (zero-gap updates).
    
    This command uses a version-tag strategy to achieve zero-gap updates:
    - New sphinx docs are written to the live 'all' index immediately
    - Per-source indices (sphinx, myst) use atomic index swaps
    - Stale docs are garbage-collected by build_id
    
    Zero downtime: searches never see a gap where sphinx docs are absent.
    Cancellation-safe: staging indices are cleaned up; live indices untouched.
    """
    config = ctx.obj['config']
    
    # Parse heading range
    try:
        start, end = headings.split('-')
        max_heading = int(end)
    except ValueError:
        max_heading = 3
    
    exclude_list = list(exclude) if exclude else None
    
    try:
        indexer = DocumentIndexer(config)
        stats = indexer.index_sphinx_html(
            source,
            max_heading_level=max_heading,
            exclude_patterns=exclude_list,
            max_retries=max_retries,
            retry_delay=retry_delay,
            staging_suffix=staging_suffix,
        )
        
        click.echo("\n✓ HTML indexing complete")
        click.echo(f"  Total: {stats.total_documents}")
        click.echo(f"  Indexed: {stats.indexed_documents}")
        click.echo(f"  Errors: {stats.errors}")
        click.echo(f"  Success rate: {stats.success_rate:.1f}%")
        click.echo(f"  Duration: {stats.duration_seconds:.1f}s")
        click.echo("\n  Strategy: Version-tag GC (zero gap, brief overlap)")
    
    except KeyboardInterrupt:
        click.echo("\n✗ Cancelled (staging indices cleaned up)", err=True)
        sys.exit(1)
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command(name='index-html-legacy')
@click.option(
    '--source',
    type=click.Path(exists=True, path_type=Path),
    required=True,
    help='Sphinx _build/html directory'
)
@click.option(
    '--headings',
    type=str,
    default='1-3',
    help='Heading levels to extract (e.g., 1-3)'
)
@click.option(
    '--exclude',
    multiple=True,
    help='Exclude page patterns'
)
@click.pass_context
def index_html_legacy(ctx, source: Path, headings: str, exclude: tuple):
    """Index Sphinx HTML to Meilisearch (legacy, non-atomic).
    
    DEPRECATED: Use 'index-html' instead for zero-gap atomic updates.
    This command is kept for backward compatibility only.
    """
    config = ctx.obj['config']
    
    # Parse heading range
    try:
        start, end = headings.split('-')
        max_heading = int(end)
    except ValueError:
        max_heading = 3
    
    exclude_list = list(exclude) if exclude else None
    
    try:
        indexer = DocumentIndexer(config)
        stats = indexer.index_sphinx_html_legacy(
            source,
            max_heading_level=max_heading,
            exclude_patterns=exclude_list
        )
        
        click.echo("\n✓ HTML indexing complete (legacy, non-atomic)")
        click.echo(f"  Total: {stats.total_documents}")
        click.echo(f"  Indexed: {stats.indexed_documents}")
        click.echo(f"  Success rate: {stats.success_rate:.1f}%")
        click.echo(f"  Duration: {stats.duration_seconds:.1f}s")
        click.echo("\n  ⚠ Note: Use 'index-html' for atomic zero-gap updates")
    
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.pass_context
def status(ctx):
    """Show Meilisearch status and indices."""
    config = ctx.obj['config']
    
    try:
        indexer = DocumentIndexer(config)
        status_info = indexer.get_index_status()
        
        if status_info['connected']:
            click.echo("✓ Meilisearch connected\n")
            click.echo("Indices:")
            for index_name, info in status_info['indices'].items():
                click.echo(f"  {index_name}: {info['documents']} documents")
        else:
            click.echo(f"✗ Connection failed: {status_info.get('error')}", err=True)
            sys.exit(1)
    
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.option(
    '--index',
    default='all',
    help='Index name'
)
@click.option(
    '--query',
    prompt='Search query',
    help='Search query'
)
@click.option(
    '--limit',
    type=int,
    default=10,
    help='Number of results'
)
@click.pass_context
def search(ctx, index: str, query: str, limit: int):
    """Search Meilisearch indices."""
    config = ctx.obj['config']
    
    try:
        client = MeilisearchClient(config)
        results = client.search(index, query, limit=limit)
        
        if results:
            click.echo(f"\n✓ Found {len(results)} results for '{query}':\n")
            for i, result in enumerate(results, 1):
                click.echo(f"{i}. {result.title}")
                click.echo(f"   Type: {result.type}")
                click.echo(f"   Score: {result.relevance_score:.2f}")
                click.echo(f"   {result.content_snippet}...")
                click.echo()
        else:
            click.echo(f"No results found for '{query}'")
    
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.pass_context
def list_indices(ctx):
    """List all Meilisearch indices."""
    config = ctx.obj['config']
    
    try:
        client = MeilisearchClient(config)
        indices = client.list_indices()
        
        if indices:
            click.echo("\nAvailable indices:")
            for idx in indices:
                click.echo(f"  - {idx.get('name', 'unknown')}")
        else:
            click.echo("No indices found")
    
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.option(
    '--index',
    default='all',
    help='Index name'
)
@click.option(
    '--confirm',
    is_flag=True,
    help='Skip confirmation'
)
@click.pass_context
def clear_index(ctx, index: str, confirm: bool):
    """Clear all documents from an index."""
    config = ctx.obj['config']
    
    if not confirm:
        if not click.confirm(f"Clear index '{index}'? This cannot be undone."):
            click.echo("Cancelled")
            return
    
    try:
        client = MeilisearchClient(config)
        client.clear_index(index)
        click.echo(f"✓ Cleared index '{index}'")
    
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.option(
    '--index',
    default='all',
    help='Index name'
)
@click.option(
    '--confirm',
    is_flag=True,
    help='Skip confirmation'
)
@click.pass_context
def delete_index(ctx, index: str, confirm: bool):
    """Delete an index."""
    config = ctx.obj['config']
    
    if not confirm:
        if not click.confirm(f"Delete index '{index}'? This cannot be undone."):
            click.echo("Cancelled")
            return
    
    try:
        client = MeilisearchClient(config)
        client.delete_index(index)
        click.echo(f"✓ Deleted index '{index}'")
    
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


# ---------------------------------------------------------------------------
# Synonym management commands
# ---------------------------------------------------------------------------

_ALL_INDEX_NAMES = ["all", "chats", "sphinx", "myst"]


@cli.command("update-synonyms")
@click.option(
    "--file",
    "synonyms_file",
    type=click.Path(path_type=Path),
    default=None,
    help="Path to synonyms YAML file (default: bundled synonyms.yaml)",
)
@click.option(
    "--indices",
    default=",".join(_ALL_INDEX_NAMES),
    show_default=True,
    help="Comma-separated list of index names to update",
)
@click.pass_context
def update_synonyms(ctx, synonyms_file: Optional[Path], indices: str):
    """Push synonyms.yaml to one or more Meilisearch indices.

    Reads the synonyms YAML file and replaces the synonym map on each
    specified index.  Run after every edit to synonyms.yaml.

    \b
    Examples:
      docindex update-synonyms
      docindex update-synonyms --file ./my_synonyms.yaml
      docindex update-synonyms --indices all,chats
    """
    config = ctx.obj["config"]
    synonyms = SynonymsManager.load(synonyms_file)
    if not synonyms:
        click.echo("✗ No synonyms loaded — check the file path.", err=True)
        sys.exit(1)

    click.echo(f"Loaded {len(synonyms)} synonym entries from "
               f"{synonyms_file or SynonymsManager.DEFAULT_PATH}")

    index_names = [n.strip() for n in indices.split(",") if n.strip()]
    try:
        client = MeilisearchClient(config)
        for name in index_names:
            try:
                client.update_synonyms(name, synonyms)
                click.echo(f"  ✓ {name}")
            except Exception as exc:
                click.echo(f"  ✗ {name}: {exc}", err=True)
    except Exception as e:
        click.echo(f"✗ Error connecting: {e}", err=True)
        sys.exit(1)


@cli.command("show-synonyms")
@click.option(
    "--index",
    default="all",
    show_default=True,
    help="Index name to fetch synonyms from",
)
@click.option(
    "--filter",
    "term_filter",
    default=None,
    help="Show only entries whose key contains this string",
)
@click.pass_context
def show_synonyms(ctx, index: str, term_filter: Optional[str]):
    """Display the synonym map currently stored in a Meilisearch index.

    Use this to review what's live before or after running update-synonyms.

    \b
    Examples:
      docindex show-synonyms
      docindex show-synonyms --index chats --filter carbon
    """
    config = ctx.obj["config"]
    try:
        client = MeilisearchClient(config)
        synonyms = client.get_synonyms(index)
    except Exception as e:
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)

    if not synonyms:
        click.echo(f"No synonyms configured on index '{index}'.")
        return

    if term_filter:
        synonyms = {k: v for k, v in synonyms.items() if term_filter.lower() in k.lower()}

    click.echo(f"\nSynonyms on index '{index}' ({len(synonyms)} entries):\n")
    for term, syns in sorted(synonyms.items()):
        click.echo(f"  {term}")
        for s in syns:
            click.echo(f"    → {s}")
    click.echo()


@cli.command("suggest-synonyms")
@click.option(
    "--source",
    type=click.Path(exists=True, file_okay=False, path_type=Path),
    required=True,
    help="Directory to scan for corpus files (.md, .txt, .json)",
)
@click.option(
    "--min-count",
    type=int,
    default=2,
    show_default=True,
    help="Minimum occurrence count to include a candidate",
)
@click.option(
    "--apply",
    is_flag=True,
    default=False,
    help="Merge accepted candidates into synonyms.yaml",
)
@click.option(
    "--file",
    "synonyms_file",
    type=click.Path(path_type=Path),
    default=None,
    help="Target synonyms YAML file for --apply (default: bundled synonyms.yaml)",
)
@click.pass_context
def suggest_synonyms(
    ctx,
    source: Path,
    min_count: int,
    apply: bool,
    synonyms_file: Optional[Path],
):
    """Discover synonym candidates by scanning corpus files.

    Scans .md, .txt, and .json files for patterns like
    ``carbon nanotubes (CNT)`` and outputs candidates ranked by occurrence.
    Review the suggestions, then optionally merge them into synonyms.yaml
    with --apply.

    \b
    Examples:
      docindex suggest-synonyms --source data/chats/
      docindex suggest-synonyms --source data/chats/ --min-count 1
      docindex suggest-synonyms --source data/chats/ --apply
    """
    click.echo(f"Scanning {source} …")
    candidates = SynonymsManager.suggest_from_files(source)

    if not candidates:
        click.echo("No acronym patterns found.")
        return

    existing = SynonymsManager.load(synonyms_file)
    new_entries: dict = {}
    skipped = 0

    click.echo(f"\nCandidates (min-count={min_count}):\n")
    for acronym, full, count in candidates:
        if count < min_count:
            skipped += 1
            continue
        already = full in existing.get(acronym, [])
        flag = "  (already in synonyms.yaml)" if already else ""
        click.echo(f"  {acronym:20s}  ← {full}  [{count}×]{flag}")
        if not already:
            if acronym not in new_entries:
                new_entries[acronym] = []
            if full not in new_entries[acronym]:
                new_entries[acronym].append(full)

    if skipped:
        click.echo(f"\n  ({skipped} candidates below min-count={min_count} hidden)")

    if not new_entries:
        click.echo("\nNo new candidates to add.")
        return

    click.echo(f"\n{len(new_entries)} new term(s) could be added to synonyms.yaml.")

    if apply:
        merged = SynonymsManager.merge(existing, new_entries)
        target = synonyms_file or SynonymsManager.DEFAULT_PATH
        SynonymsManager.save(merged, target)
        click.echo(f"✓ Merged into {target}")
        click.echo("  Run `docindex update-synonyms` to push to Meilisearch.")
    else:
        click.echo("\nRe-run with --apply to merge into synonyms.yaml.")


@cli.command("export-synonyms")
@click.option(
    "--source",
    "glossary_yaml",
    type=click.Path(exists=True, path_type=Path),
    default=None,
    help="Path to glossary.yaml (default: docs/glossary.yaml)",
)
@click.option(
    "--output",
    "synonyms_file",
    type=click.Path(path_type=Path),
    default=None,
    help="Destination synonyms YAML (default: bundled synonyms.yaml)",
)
@click.option(
    "--mode",
    type=click.Choice(["merge", "replace"], case_sensitive=False),
    default="merge",
    show_default=True,
    help=(
        "merge: add glossary synonyms to existing synonyms.yaml entries; "
        "replace: overwrite with only what the glossary defines."
    ),
)
def export_synonyms(
    glossary_yaml: Optional[Path],
    synonyms_file: Optional[Path],
    mode: str,
):
    """Export synonym lists from glossary.yaml into synonyms.yaml.

    Reads the ``synonyms`` field of every glossary term and writes
    (or merges) them into synonyms.yaml so they can be pushed to
    Meilisearch with ``update-synonyms``.

    This is the reverse of ``generate-glossary --merge-synonyms``:

    \b
      generate-glossary --merge-synonyms  →  synonyms.yaml enriches glossary.md
      export-synonyms                     →  glossary.yaml enriches synonyms.yaml

    \b
    Examples:
      docindex export-synonyms
      docindex export-synonyms --mode replace
      docindex export-synonyms --source docs/glossary.yaml \\
          --output src/docindex-core/src/docindex_core/synonyms.yaml
    """
    cwd = Path.cwd()
    source = glossary_yaml or cwd / "docs" / "glossary.yaml"
    target = synonyms_file or SynonymsManager.DEFAULT_PATH

    try:
        data = GlossaryManager.load(source)
    except FileNotFoundError as e:
        click.echo(f"✗ {e}", err=True)
        sys.exit(1)
    except ValueError as e:
        click.echo(f"✗ YAML parse error: {e}", err=True)
        sys.exit(1)

    extracted = GlossaryManager.extract_synonyms(data)
    term_count = len(data.get("terms", {}))
    entry_count = sum(len(v) for v in extracted.values())
    click.echo(
        f"Extracted {len(extracted)} synonym groups "
        f"({entry_count} entries) from {term_count} terms in {source}"
    )

    if mode == "merge":
        existing = SynonymsManager.load(target)
        merged = SynonymsManager.merge(existing, extracted)
        added = len(merged) - len(existing)
        click.echo(
            f"Merging into {target}  "
            f"({len(existing)} existing → {len(merged)} total, +{added} new keys)"
        )
        SynonymsManager.save(merged, target)
    else:
        click.echo(f"Replacing {target} with glossary-derived synonyms")
        SynonymsManager.save(extracted, target)

    click.echo(f"✓ Written: {target}")
    click.echo("  Run `docindex update-synonyms` to push to Meilisearch.")




@cli.command("generate-glossary")
@click.option(
    "--source",
    "glossary_yaml",
    type=click.Path(exists=True, path_type=Path),
    default=None,
    help="Path to glossary.yaml (default: docs/glossary.yaml)",
)
@click.option(
    "--output",
    "output_md",
    type=click.Path(path_type=Path),
    default=None,
    help="Destination .md file (default: docs/glossary.md)",
)
@click.option(
    "--merge-synonyms",
    "synonyms_file",
    type=click.Path(exists=True, path_type=Path),
    default=None,
    help="Path to synonyms.yaml to fold into glossary synonym lists",
)
@click.option(
    "--export-synonyms",
    "export_synonyms_file",
    type=click.Path(path_type=Path),
    default=None,
    is_flag=False,
    flag_value="",   # empty string signals "use default path"
    help=(
        "Also write glossary synonym lists back into a synonyms.yaml. "
        "Omit a path to use the default bundled synonyms.yaml."
    ),
)
@click.option(
    "--label",
    default="glossary",
    show_default=True,
    help="Sphinx cross-reference label placed above the title",
)
@click.option(
    "--title",
    default="Glossary",
    show_default=True,
    help="H1 heading text",
)
@click.option(
    "--force",
    is_flag=True,
    default=False,
    help="Write output even when content is unchanged",
)
def generate_glossary(
    glossary_yaml: Optional[Path],
    output_md: Optional[Path],
    synonyms_file: Optional[Path],
    export_synonyms_file,   # None | "" | Path
    label: str,
    title: str,
    force: bool,
):
    """Generate docs/glossary.md from docs/glossary.yaml.

    Reads the YAML glossary, optionally merges synonym entries from
    synonyms.yaml, then writes (or refreshes) the MyST Markdown file
    consumed by Sphinx.

    Use ``--export-synonyms`` to simultaneously write glossary synonym
    lists back into synonyms.yaml (the reverse of ``--merge-synonyms``).

    \b
    Examples:
      docindex generate-glossary
      docindex generate-glossary --source docs/glossary.yaml
      docindex generate-glossary --merge-synonyms src/docindex-core/src/docindex_core/synonyms.yaml
      docindex generate-glossary --export-synonyms
      docindex generate-glossary --export-synonyms my_synonyms.yaml
      docindex generate-glossary --force
    """
    # Resolve default paths relative to cwd
    cwd = Path.cwd()
    source = glossary_yaml or cwd / "docs" / "glossary.yaml"
    output = output_md or cwd / "docs" / "glossary.md"

    try:
        data = GlossaryManager.load(source)
    except FileNotFoundError as e:
        click.echo(f"\u2717 {e}", err=True)
        sys.exit(1)
    except ValueError as e:
        click.echo(f"\u2717 YAML parse error: {e}", err=True)
        sys.exit(1)

    term_count = len(data.get("terms", {}))
    click.echo(f"Loaded {term_count} terms from {source}")

    if synonyms_file:
        synonyms = SynonymsManager.load(synonyms_file)
        data = GlossaryManager.merge_synonyms(data, synonyms)
        click.echo(f"Merged synonyms from {synonyms_file}")

    if force:
        content = GlossaryManager.to_myst(data, source_path=source,
                                          label=label, title=title)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(content, encoding="utf-8")
        click.echo(f"\u2713 Written: {output}")
    else:
        changed = GlossaryManager.write_myst_if_changed(
            data, output, source_path=source, label=label, title=title
        )
        if changed:
            click.echo(f"\u2713 Updated: {output}")
        else:
            click.echo(f"  (unchanged) {output}")

    # Optional reverse-export of synonyms back into synonyms.yaml.
    # Click converts flag_value="" to Path("") → Path("."), so we treat "."
    # and "" both as "use the default bundled synonyms.yaml".
    if export_synonyms_file is not None:
        raw = str(export_synonyms_file)
        target = SynonymsManager.DEFAULT_PATH if raw in ("", ".") else Path(raw)
        extracted = GlossaryManager.extract_synonyms(data)
        existing = SynonymsManager.load(target)
        merged = SynonymsManager.merge(existing, extracted)
        SynonymsManager.save(merged, target)
        click.echo(f"\u2713 Synonyms exported to {target}")
        click.echo("  Run `docindex update-synonyms` to push to Meilisearch.")



if __name__ == '__main__':  # pragma: no cover
    cli(obj={})
