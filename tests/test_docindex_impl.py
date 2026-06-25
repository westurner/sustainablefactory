"""Tests for docindex_impl module re-exports."""

import pytest
from sustainablefactory import docindex_impl

# Expected exports from docindex_impl module
EXPECTED_EXPORTS = [
    'MeilisearchClient',
    'Document',
    'DocumentType',
    'MeilisearchConfig',
    'IndexSettings',
    'SearchResult',
    'IndexingStats',
    'DocumentMetadata',
    'DocumentIndexer',
    'ChatParser',
    'BatchChatIndexer',
    'SphinxHTMLParser',
    'BatchHTMLIndexer',
]


class TestDocindexImplExports:
    """Test that docindex_impl properly re-exports all required classes and functions."""

    def test_meilisearch_client_available(self):
        """Test MeilisearchClient is imported."""
        assert hasattr(docindex_impl, 'MeilisearchClient')

    def test_document_available(self):
        """Test Document is imported."""
        assert hasattr(docindex_impl, 'Document')

    def test_document_type_available(self):
        """Test DocumentType is imported."""
        assert hasattr(docindex_impl, 'DocumentType')

    def test_meilisearch_config_available(self):
        """Test MeilisearchConfig is imported."""
        assert hasattr(docindex_impl, 'MeilisearchConfig')

    def test_index_settings_available(self):
        """Test IndexSettings is imported."""
        assert hasattr(docindex_impl, 'IndexSettings')

    def test_search_result_available(self):
        """Test SearchResult is imported."""
        assert hasattr(docindex_impl, 'SearchResult')

    def test_indexing_stats_available(self):
        """Test IndexingStats is imported."""
        assert hasattr(docindex_impl, 'IndexingStats')

    def test_document_metadata_available(self):
        """Test DocumentMetadata is imported."""
        assert hasattr(docindex_impl, 'DocumentMetadata')

    def test_document_indexer_available(self):
        """Test DocumentIndexer is imported."""
        assert hasattr(docindex_impl, 'DocumentIndexer')

    def test_chat_parser_available(self):
        """Test ChatParser is imported."""
        assert hasattr(docindex_impl, 'ChatParser')

    def test_batch_chat_indexer_available(self):
        """Test BatchChatIndexer is imported."""
        assert hasattr(docindex_impl, 'BatchChatIndexer')

    def test_sphinx_html_parser_available(self):
        """Test SphinxHTMLParser is imported."""
        assert hasattr(docindex_impl, 'SphinxHTMLParser')

    def test_batch_html_indexer_available(self):
        """Test BatchHTMLIndexer is imported."""
        assert hasattr(docindex_impl, 'BatchHTMLIndexer')

    @pytest.mark.parametrize("export_name", EXPECTED_EXPORTS)
    def test_all_exports_in_all(self, export_name):
        """Test that all exports are listed in __all__ using parametrize."""
        assert export_name in docindex_impl.__all__

    def test_all_list_not_empty(self):
        """Test __all__ list is not empty."""
        assert len(docindex_impl.__all__) > 0

    def test_all_list_has_correct_length(self):
        """Test __all__ list has all expected exports."""
        assert len(docindex_impl.__all__) == len(EXPECTED_EXPORTS)

    def test_module_docstring_exists(self):
        """Test module has a docstring."""
        assert docindex_impl.__doc__ is not None
        assert len(docindex_impl.__doc__) > 0

    def test_all_exports_are_exported(self):
        """Test all items in __all__ are actually exported."""
        for name in docindex_impl.__all__:
            assert hasattr(docindex_impl, name), f"{name} listed in __all__ but not exported"

    def test_no_unexpected_exports(self):
        """Test there are no unexpected exports outside of __all__."""
        # Get all non-private attributes
        all_attrs = [name for name in dir(docindex_impl) if not name.startswith('_')]
        # Should only have __all__ items and no extras
        unexpected = set(all_attrs) - set(docindex_impl.__all__)
        assert len(unexpected) == 0, f"Unexpected exports: {unexpected}"
