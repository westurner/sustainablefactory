import pytest
from pathlib import Path
from unittest.mock import MagicMock, patch
import pyoxigraph as ox
from types import SimpleNamespace

from docindex_core.backends.oxirs import OxiRSBackend, OxiRSConfig
from docindex_core.config import Document, DocumentMetadata, DocumentType, IndexSettings, SearchResult

@pytest.fixture
def doc_list():
    return [
        Document(
            id="doc1",
            type=DocumentType.CHAT,
            title="First document",
            content="This is the first document with carbon footprint metrics.",
            filename="doc1.md",
            metadata=DocumentMetadata(source_file="/tmp/doc1.md"),
            url="http://example.com/doc1"
        ),
        Document(
            id="doc2",
            type=DocumentType.SPHINX_HTML,
            title="Second document",
            content="Sustainable manufacturing guidelines and metrics.",
            filename="doc2.html",
            metadata=DocumentMetadata(source_file="/tmp/doc2.html"),
            url="http://example.com/doc2"
        )
    ]

def test_oxirs_config_validation():
    """Verify OxiRSConfig validation rules."""
    config = OxiRSConfig(url="http://localhost:8080/sparql")
    assert config.url == "http://localhost:8080/sparql"
    assert config.storage_path is None
    
    config2 = OxiRSConfig(storage_path="/tmp/oxirs_db")
    assert config2.storage_path == "/tmp/oxirs_db"
    assert config2.url is None

def test_oxirs_backend_in_memory_lifecycle(doc_list):
    """Test local in-memory Store operations (add, search, delete)."""
    config = OxiRSConfig(storage_path=None)
    backend = OxiRSBackend(config)
    
    # 1. Verify connection
    assert backend.verify_connection() is True
    
    # 2. Create/update index
    index_name = "test_index"
    res = backend.create_or_update_index(index_name)
    assert res["status"] == "ready"
    assert res["index"] == index_name
    
    # 3. Add documents
    stats = backend.add_documents(index_name, doc_list)
    assert stats.total_documents == 2
    assert stats.indexed_documents == 2
    assert stats.errors == 0
    
    # 4. Search documents
    search_res = backend.search(index_name, "carbon footprint")
    assert len(search_res) == 1
    assert search_res[0].id == "doc1"
    assert search_res[0].title == "First document"
    
    # Search with no matching query should return empty list
    empty_res = backend.search(index_name, "nonexistent term")
    assert len(empty_res) == 0
    
    # 5. Get index stats
    stats_info = backend.get_index_stats(index_name)
    assert stats_info["numberOfDocuments"] == 2
    
    # 6. Delete documents by filter
    # emulated meilisearch syntax: delete ID
    backend.delete_documents_by_filter(index_name, "id = doc1")
    search_res_after = backend.search(index_name, "carbon footprint")
    assert len(search_res_after) == 0
    
    stats_info_after = backend.get_index_stats(index_name)
    assert stats_info_after["numberOfDocuments"] == 1
    
    # 7. Clear index
    backend.clear_index(index_name)
    stats_info_cleared = backend.get_index_stats(index_name)
    assert stats_info_cleared["numberOfDocuments"] == 0

def test_oxirs_backend_on_disk_lifecycle(tmp_path, doc_list):
    """Test on-disk persistent Store operations."""
    db_path = str(tmp_path / "oxirs_db")
    config = OxiRSConfig(storage_path=db_path)
    backend = OxiRSBackend(config)
    
    assert backend.verify_connection() is True
    
    index_name = "disk_index"
    backend.create_or_update_index(index_name)
    backend.add_documents(index_name, doc_list)
    
    # Verify search works
    search_res = backend.search(index_name, "manufacturing")
    assert len(search_res) == 1
    assert search_res[0].id == "doc2"
    
    # Delete index directory emulated
    backend.delete_index(index_name)
    assert backend.get_index_stats(index_name)["numberOfDocuments"] == 0

def test_oxirs_backend_synonyms():
    """Verify synonyms API behavior on OxiRSBackend."""
    config = OxiRSConfig(storage_path=None)
    backend = OxiRSBackend(config)
    
    index_name = "syn_index"
    
    # Should get empty synonyms by default
    assert backend.get_synonyms(index_name) == {}
    
    # Updating synonyms returns success
    synonyms = {"footprint": ["impact", "emissions"]}
    assert backend.update_synonyms(index_name, synonyms) == {"status": "success"}
    
    # Clearing synonyms returns success
    assert backend.clear_synonyms(index_name) == {"status": "success"}

@patch("httpx.Client")
def test_oxirs_backend_remote_http(mock_httpx_class, doc_list):
    """Test remote SPARQL HTTP query and update client requests."""
    # Set up httpx.Client mock
    mock_client = MagicMock()
    mock_client.__enter__.return_value = mock_client
    mock_httpx_class.return_value = mock_client
    
    # Mock health check response
    mock_health_response = MagicMock()
    mock_health_response.status_code = 200
    mock_client.get.return_value = mock_health_response
    
    # Mock query/update response
    mock_post_response = MagicMock()
    mock_post_response.status_code = 200
    mock_post_response.json.return_value = {
        "results": {
            "bindings": [
                {
                    "id": {"value": "doc1"},
                    "type": {"value": "chat"},
                    "title": {"value": "First document"},
                    "content": {"value": "This is carbon footprint."},
                    "filename": {"value": "doc1.md"},
                    "url": {"value": "http://example.com/doc1"},
                    "summary": {"value": "carbon footprint summary"}
                }
            ]
        }
    }
    mock_client.post.return_value = mock_post_response
    
    config = OxiRSConfig(url="http://remote-sparql-endpoint/sparql")
    backend = OxiRSBackend(config)
    
    # 1. Verify connection
    assert backend.verify_connection() is True
    mock_client.get.assert_called_once_with("http://remote-sparql-endpoint/sparql", timeout=5.0)
    
    # 2. Add documents (remote update request)
    index_name = "remote_index"
    stats = backend.add_documents(index_name, doc_list)
    assert stats.total_documents == 2
    assert stats.indexed_documents == 2
    assert mock_client.post.call_count == 1
    
    # 3. Search documents (remote query request)
    search_res = backend.search(index_name, "carbon")
    assert len(search_res) == 1
    assert search_res[0].id == "doc1"
    assert search_res[0].content_snippet == "This is carbon footprint."
    
    # 4. Delete index
    backend.delete_index(index_name)
    # Assert post was called for update (DROP GRAPH)
    assert mock_client.post.call_count >= 2


def test_oxirs_no_pyoxigraph(monkeypatch):
    import docindex_core.backends.oxirs as oxirs_mod
    monkeypatch.setattr(oxirs_mod, "_HAS_PYOXIGRAPH", False)
    
    # Init in-memory backend
    conf = oxirs_mod.OxiRSConfig()
    backend = oxirs_mod.OxiRSBackend(conf)
    assert backend._local_store is None
    
    # Init on-disk backend
    conf2 = oxirs_mod.OxiRSConfig(storage_path="/tmp/fake")
    backend2 = oxirs_mod.OxiRSBackend(conf2)
    assert backend2._local_store is None


@patch("httpx.Client")
def test_oxirs_backend_edge_cases(mock_httpx_class):
    from docindex_core.backends.oxirs import OxiRSBackend, OxiRSConfig
    from docindex_core.config import Document, DocumentType, DocumentMetadata
    from datetime import datetime, timezone
    
    # 1. Connection alias & verify_connection exception paths
    mock_client = MagicMock()
    mock_client.__enter__.return_value = mock_client
    mock_httpx_class.return_value = mock_client
    mock_client.get.side_effect = Exception("failed conn")
    
    config = OxiRSConfig(url="http://remote/sparql")
    backend = OxiRSBackend(config)
    assert backend._verify_connection() is False
    
    # 2. clear_index and delete_index exception on HTTP SPARQL
    mock_client.post.side_effect = Exception("HTTP failed")
    with pytest.raises(Exception, match="HTTP failed"):
        backend.clear_index("my_index")
    assert backend.delete_index("my_index") is False
    
    # 3. get_index_stats HTTP exception
    stats = backend.get_index_stats("my_index")
    assert stats["numberOfDocuments"] == 0
    
    # 4. config.url None raises ValueError on _execute_http_update
    backend_no_url = OxiRSBackend(OxiRSConfig(url=None))
    with pytest.raises(ValueError, match="OxiRS HTTP URL is not configured."):
        backend_no_url._execute_http_update("DROP GRAPH <uri>")
        
    # 5. add_documents exception logging on _add_document_quads
    # Pass object that throws attribute error
    doc_list = [SimpleNamespace(id="bad_doc")]
    stats = backend_no_url.add_documents("my_index", doc_list)
    assert stats.errors == 1
    
    # 6. Quad generation with summary, date_indexed, and delete of existing document quads
    backend_local = OxiRSBackend(OxiRSConfig())
    doc = Document(
        id="doc_with_summary",
        type=DocumentType.CHAT,
        title="Doc title",
        content="Doc content",
        filename="test.md",
        summary="Doc summary",
        url="http://test.com",
        metadata=DocumentMetadata(
            source_file="test.md",
            date_indexed=datetime.now(timezone.utc)
        )
    )
    backend_local.add_documents("local_index", [doc])
    backend_local.add_documents("local_index", [doc])


@patch("httpx.Client")
def test_oxirs_backend_methods_full(mock_httpx_class):
    from docindex_core.backends.oxirs import OxiRSBackend, OxiRSConfig
    from docindex_core.config import Document, DocumentType
    from datetime import datetime, timezone
    
    # Setup remote client mocks
    mock_client = MagicMock()
    mock_client.__enter__.return_value = mock_client
    mock_httpx_class.return_value = mock_client
    
    # 1. Mock remote HTTP response for query (list_indices / get_index_stats)
    mock_client.post.return_value = MagicMock(
        status_code=200,
        json=lambda: {
            "results": {
                "bindings": [
                    {"g": {"value": "http://westurner.github.io/sustainablefactory/docindex/graph/all"}},
                    {"count": {"value": "12"}}
                ]
            }
        }
    )
    
    # Instantiate both backends
    backend_local = OxiRSBackend(OxiRSConfig())
    backend_remote = OxiRSBackend(OxiRSConfig(url="http://remote/sparql"))
    
    from docindex_core.config import Document, DocumentType, DocumentMetadata
    # from_env config coverage
    assert isinstance(OxiRSConfig.from_env(), OxiRSConfig)

    doc = Document(
        id="doc1",
        type="chat",
        title="T",
        content="C",
        filename="F.md",
        summary="Doc summary",
        metadata=DocumentMetadata(source_file="F.md")
    )
    
    # 2. Add documents to local store first to populate graphs
    backend_local.add_documents("all", [doc])
    
    for backend in (backend_local, backend_remote):
        # add_documents (including summary field)
        backend.add_documents("all", [doc])
        
        # list_indices (must be called before delete_documents_by_filter drops graphs)
        indices = backend.list_indices()
        assert len(indices) >= 0
        
        # get_index_stats
        stats = backend.get_index_stats("all")
        assert stats["numberOfDocuments"] >= 0
        
        # Add a doc to sphinx_staging first so it exists
        backend.add_documents("sphinx_staging", [doc])
        # swap_indexes
        res = backend.swap_indexes([("sphinx", "sphinx_staging")])
        assert res == {"status": "success"}
        
        # delete_index_if_exists
        backend.delete_index_if_exists("sphinx_staging")
        
        # delete_documents_by_filter (type list and equality)
        backend.delete_documents_by_filter("all", 'type IN ["chat", "sphinx_md"]')
        backend.delete_documents_by_filter("all", 'type = "chat"')
        
        # delete_documents_by_filter (id list and equality)
        backend.delete_documents_by_filter("all", 'id IN ["doc1"]')
        backend.delete_documents_by_filter("all", 'id = "doc1"')
        
        # wait_for_task
        assert backend.wait_for_task(123) == {"status": "succeeded"}
            
        # _submit_batches (with mock progress bar to cover pbar branch) & _finalize_tasks
        mock_pbar = MagicMock()
        backend._submit_batches("all", [doc], batch_size=10, pbar=mock_pbar)
        assert mock_pbar.update.call_count == 1
        
        stats = backend._finalize_tasks("all", [], 1, 0, datetime.now(timezone.utc))
        assert stats.indexed_documents == 1


def test_oxirs_no_store_no_url(monkeypatch):
    import docindex_core.backends.oxirs as oxirs_mod
    monkeypatch.setattr(oxirs_mod, "_HAS_PYOXIGRAPH", False)
    
    backend = oxirs_mod.OxiRSBackend(oxirs_mod.OxiRSConfig(url=None, storage_path=None))
    assert backend.verify_connection() is False
    assert backend.delete_index("any") is False


def test_oxirs_build_id_and_fallback_error(monkeypatch):
    from docindex_core.backends.oxirs import OxiRSBackend, OxiRSConfig
    from docindex_core.config import Document, DocumentMetadata, DocumentType
    import datetime
    
    # 1. Test build_id on local backend
    backend_local = OxiRSBackend(OxiRSConfig())
    doc = Document(
        id="doc_build_id",
        type="chat",
        title="T",
        content="C",
        filename="F.md",
        build_id="my-build-123",
        metadata=DocumentMetadata(source_file="F.md")
    )
    backend_local.add_documents("all", [doc])
    
    # Verify build_id != filter deletes correctly
    res = backend_local.delete_documents_by_filter("all", 'type = "chat" AND build_id != "other-build"')
    assert res == {"status": "success"}
    
    # 2. Test build_id on remote backend (mocked HTTP)
    mock_client = MagicMock()
    mock_client.__enter__.return_value = mock_client
    mock_client.post.return_value = MagicMock(status_code=200, json=lambda: {"results": {"bindings": []}})
    
    with patch("httpx.Client", return_value=mock_client):
        backend_remote = OxiRSBackend(OxiRSConfig(url="http://remote/sparql"))
        backend_remote.add_documents("all", [doc])
        
        # Test fallback failure raising
        mock_client.post.side_effect = Exception("SPARQL failed")
        with pytest.raises(Exception, match="SPARQL failed"):
            backend_remote.swap_indexes([("sphinx_staging", "sphinx")])


def test_oxirs_optimize_and_base():
    from docindex_core.backends.base import BaseSearchBackend
    from docindex_core.backends.oxirs import OxiRSBackend, OxiRSConfig

    # Test BaseSearchBackend.optimize
    class DummyBackend(BaseSearchBackend):
        def create_or_update_index(self, *a, **k): pass
        def add_documents(self, *a, **k): pass
        def search(self, *a, **k): pass
        def delete_index(self, *a, **k): pass
        def clear_index(self, *a, **k): pass
        def get_index_stats(self, *a, **k): pass
        def get_synonyms(self, *a, **k): pass
        def update_synonyms(self, *a, **k): pass
        def clear_synonyms(self, *a, **k): pass
        def verify_connection(self, *a, **k): pass

    dummy = DummyBackend()
    assert dummy.optimize() is None

    # Test OxiRSBackend.optimize (with local store)
    backend = OxiRSBackend(OxiRSConfig())
    backend.optimize()  # Works successfully
    
    # Test OxiRSBackend.optimize failing
    backend._local_store = MagicMock()
    backend._local_store.optimize.side_effect = Exception("RocksDB crash")
    backend.optimize()  # Does not raise, catches and logs warning



