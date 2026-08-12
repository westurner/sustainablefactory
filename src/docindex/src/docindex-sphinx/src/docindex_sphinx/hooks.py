"""
Sphinx event hooks for Meilisearch integration.

This module integrates with Sphinx's event system to automatically index
documentation as it's built.
"""

import logging
import os
from pathlib import Path

from docindex_core import DocumentIndexer, DocIndexConfig

logger = logging.getLogger(__name__)


def setup_meilisearch_hooks(app):
    """Register Meilisearch/OxiRS event handlers with Sphinx.
    
    Add this to your Sphinx conf.py:
    
    from docindex_integration.hooks import setup_meilisearch_hooks
    
    def setup(app):
        setup_meilisearch_hooks(app)
    """
    
    # Initialize configuration
    if not hasattr(app.config, 'docindex_backend'):
        app.config.docindex_backend = os.getenv('DOCINDEX_BACKEND', 'oxirs').lower()

    if not hasattr(app.config, 'meilisearch_enabled'):
        app.config.meilisearch_enabled = os.getenv('MEILISEARCH_ENABLED', os.getenv('DOCINDEX_ENABLED', 'false')).lower() == 'true'
    
    if not hasattr(app.config, 'meilisearch_host'):
        app.config.meilisearch_host = os.getenv('MEILISEARCH_HOST', 'localhost')
    
    if not hasattr(app.config, 'meilisearch_port'):
        app.config.meilisearch_port = int(os.getenv('MEILISEARCH_PORT', '7700'))
    
    if not hasattr(app.config, 'meilisearch_api_key'):
        app.config.meilisearch_api_key = os.getenv('MEILISEARCH_API_KEY')

    if not hasattr(app.config, 'oxirs_url'):
        app.config.oxirs_url = os.getenv('OXIRS_URL')

    if not hasattr(app.config, 'oxirs_storage_path'):
        app.config.oxirs_storage_path = os.getenv('OXIRS_STORAGE_PATH')
    
    # Register event handlers
    app.connect('config-inited', on_config_inited)
    app.connect('build-finished', on_build_finished)


def on_config_inited(app, config):
    """Event handler called when Sphinx config is initialized."""
    if not config.meilisearch_enabled:
        logger.debug("Indexing disabled")
        return
    
    logger.info(
        f"Indexing integration enabled (backend: {getattr(config, 'docindex_backend', 'milli')})"
    )


def on_build_finished(app, exception):
    """Event handler called when Sphinx build completes.
    
    Automatically indexes the HTML output if build was successful.
    """
    # Skip if disabled or build failed
    if not app.config.meilisearch_enabled:
        return
    
    if exception:
        logger.warning(f"Build failed, skipping indexing: {exception}")
        return
    
    # Check if HTML build was performed
    if app.builder.name != 'html':
        logger.debug(f"Skipping indexing for builder: {app.builder.name}")
        return
    
    logger.info(f"Indexing Sphinx HTML output to {app.config.docindex_backend}...")
    
    try:
        config = DocIndexConfig(
            backend=app.config.docindex_backend,
            host=app.config.meilisearch_host,
            port=app.config.meilisearch_port,
            api_key=app.config.meilisearch_api_key,
            url=app.config.oxirs_url,
            storage_path=app.config.oxirs_storage_path
        )
        
        indexer = DocumentIndexer(config)
        
        # Index the HTML build output
        html_dir = Path(app.outdir)
        if html_dir.exists():
            stats = indexer.index_sphinx_html(html_dir)
            logger.info(
                f"✓ Indexed {stats.indexed_documents}/{stats.total_documents} documents "
                f"({stats.success_rate:.1f}% success rate)"
            )
        else:
            logger.error(f"HTML output directory not found: {html_dir}")
    
    except Exception as e:
        logger.error(f"Indexing failed: {e}")
        # Don't fail the build, just log the error


def setup(app):
    """Sphinx extension setup function.
    
    This allows the module to be used as a Sphinx extension in conf.py:
    
    extensions = [
        'docindex_integration.hooks'
    ]
    """
    setup_meilisearch_hooks(app)
    return {
        'version': '0.1.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }

