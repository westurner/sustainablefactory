"""
CLI interface for Meilisearch integration.
"""

import logging
import sys
from pathlib import Path
from typing import Optional

import click

from docindex_core import DocumentIndexer, MeilisearchClient, MeilisearchConfig

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
        
        click.echo(f"\n✓ Chat indexing complete")
        click.echo(f"  Total: {stats.total_documents}")
        click.echo(f"  Indexed: {stats.indexed_documents}")
        click.echo(f"  Success rate: {stats.success_rate:.1f}%")
        click.echo(f"  Duration: {stats.duration_seconds:.1f}s")
    
    except Exception as e:  # pragma: no cover
        click.echo(f"✗ Error: {e}", err=True)
        sys.exit(1)


@cli.command()
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
def index_html(ctx, source: Path, headings: str, exclude: tuple):
    """Index Sphinx HTML to Meilisearch."""
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
            exclude_patterns=exclude_list
        )
        
        click.echo(f"\n✓ HTML indexing complete")
        click.echo(f"  Total: {stats.total_documents}")
        click.echo(f"  Indexed: {stats.indexed_documents}")
        click.echo(f"  Success rate: {stats.success_rate:.1f}%")
        click.echo(f"  Duration: {stats.duration_seconds:.1f}s")
    
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


if __name__ == '__main__':  # pragma: no cover
    cli(obj={})
