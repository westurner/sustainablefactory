"""
Sphinx event hooks for Meilisearch integration.

This module integrates with Sphinx's event system to automatically index
documentation as it's built.
"""

import logging
import os
from pathlib import Path

try:
    from .indexer import DocumentIndexer
    from .config import MeilisearchConfig
except ImportError:
    # Handle imports when called from outside the package
    from sustainablefactory.meilisearch_integration.indexer import DocumentIndexer
    from sustainablefactory.meilisearch_integration.config import MeilisearchConfig

logger = logging.getLogger(__name__)


def setup_meilisearch_hooks(app):
    """Register Meilisearch event handlers with Sphinx.
    
    Add this to your Sphinx conf.py:
    
    from sustainablefactory.meilisearch_integration.hooks import setup_meilisearch_hooks
    
    def setup(app):
        setup_meilisearch_hooks(app)
    """
    
    # Initialize configuration
    if not hasattr(app.config, 'meilisearch_enabled'):
        app.config.meilisearch_enabled = os.getenv('MEILISEARCH_ENABLED', 'false').lower() == 'true'
    
    if not hasattr(app.config, 'meilisearch_host'):
        app.config.meilisearch_host = os.getenv('MEILISEARCH_HOST', 'localhost')
    
    if not hasattr(app.config, 'meilisearch_port'):
        app.config.meilisearch_port = int(os.getenv('MEILISEARCH_PORT', '7700'))
    
    if not hasattr(app.config, 'meilisearch_api_key'):
        app.config.meilisearch_api_key = os.getenv('MEILISEARCH_API_KEY')
    
    # Register event handlers
    app.connect('config-inited', on_config_inited)
    app.connect('build-finished', on_build_finished)


def on_config_inited(app, config):
    """Event handler called when Sphinx config is initialized."""
    if not config.meilisearch_enabled:
        logger.debug("Meilisearch indexing disabled")
        return
    
    logger.info(
        f"Meilisearch integration enabled: "
        f"{config.meilisearch_host}:{config.meilisearch_port}"
    )


def on_build_finished(app, exception):
    """Event handler called when Sphinx build completes.
    
    Automatically indexes the HTML output if build was successful.
    """
    # Skip if disabled or build failed
    if not app.config.meilisearch_enabled:
        return
    
    if exception:
        logger.warning(f"Build failed, skipping Meilisearch indexing: {exception}")
        return
    
    # Check if HTML build was performed
    if app.builder.name != 'html':
        logger.debug(f"Skipping Meilisearch indexing for builder: {app.builder.name}")
        return
    
    logger.info("Indexing Sphinx HTML output to Meilisearch...")
    
    try:
        config = MeilisearchConfig(
            host=app.config.meilisearch_host,
            port=app.config.meilisearch_port,
            api_key=app.config.meilisearch_api_key
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
        logger.error(f"Meilisearch indexing failed: {e}")
        # Don't fail the build, just log the error


def setup(app):
    """Sphinx extension setup function.
    
    This allows the module to be used as a Sphinx extension in conf.py:
    
    extensions = [
        'sustainablefactory.meilisearch_integration.hooks'
    ]
    """
    setup_meilisearch_hooks(app)
    return {
        'version': '0.1.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
