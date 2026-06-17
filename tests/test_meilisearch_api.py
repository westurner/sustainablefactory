from types import SimpleNamespace

import pytest

from meilisearch_integration.config import (
    Document,
    DocumentMetadata,
    DocumentType,
    IndexSettings,
    MeilisearchConfig,
)


class FakeIndex:
    def __init__(self):
        self.settings_updated = None
        self.docs = []
        self.fail_add = False
        self.fail_search = False
        self.fail_stats = False
        self.fail_clear = False

    def update_settings(self, settings):
        self.settings_updated = settings

    def add_documents(self, docs):
        if self.fail_add:
            from meilisearch.errors import MeilisearchError

            raise MeilisearchError("batch failed")
        self.docs.extend(docs)
        return {"taskUid": 1}

    def search(self, query, options):
        if self.fail_search:
            from meilisearch.errors import MeilisearchError

            raise MeilisearchError("search failed")
        return {
            "hits": [
                {
                    "id": "1",
                    "type": "chat",
                    "title": "A",
                    "url": "/a",
                    "content": "content",
                    "_rankingScore": 0.9,
                    "_matchedFields": ["title"],
                }
            ]
        }

    def get_stats(self):
        if self.fail_stats:
            from meilisearch.errors import MeilisearchError

            raise MeilisearchError("stats failed")
        return {"numberOfDocuments": len(self.docs), "isIndexing": False}

    def delete_all_documents(self):
        if self.fail_clear:
            from meilisearch.errors import MeilisearchError

            raise MeilisearchError("clear failed")
        self.docs.clear()


class FakeClient:
    def __init__(self):
        self.idx = FakeIndex()
        self.fail_health = False
        self.create_raises = None
        self.fail_delete = False
        self.fail_list = False

    def health(self):
        if self.fail_health:
            from meilisearch.errors import MeilisearchCommunicationError

            raise MeilisearchCommunicationError("down")
        return {"status": "available"}

    def create_index(self, index_name, payload):
        if self.create_raises is not None:
            raise self.create_raises
        return self.idx

    def index(self, name):
        return self.idx

    def delete_index(self, name):
        if self.fail_delete:
            from meilisearch.errors import MeilisearchError

            raise MeilisearchError("delete failed")

    def get_indexes(self):
        if self.fail_list:
            from meilisearch.errors import MeilisearchError

            raise MeilisearchError("list failed")
        return [SimpleNamespace(get_dict=lambda: {"name": "all"})]


@pytest.fixture
def api_mod(monkeypatch):
    import meilisearch_integration.api as api

    fake = FakeClient()

    def fake_ctor(url, api_key=None):
        return fake

    monkeypatch.setattr(api.meilisearch, "Client", fake_ctor)
    return api, fake


@pytest.fixture
def docs():
    return [
        Document(
            id=f"d{i}",
            type=DocumentType.CHAT,
            title="t",
            content="c",
            filename="f.md",
            metadata=DocumentMetadata(source_file="/tmp/f.md"),
        )
        for i in range(3)
    ]


def test_verify_connection_false_branch(api_mod):
    api, fake = api_mod
    fake.fail_health = True
    c = api.MeilisearchClient(MeilisearchConfig())
    assert c._verify_connection() is False


def test_client_property_connection_error(monkeypatch):
    import meilisearch_integration.api as api
    from meilisearch.errors import MeilisearchCommunicationError

    def raise_ctor(url, api_key=None):
        raise MeilisearchCommunicationError("connect failed")

    monkeypatch.setattr(api.meilisearch, "Client", raise_ctor)
    client = api.MeilisearchClient(MeilisearchConfig())
    with pytest.raises(MeilisearchCommunicationError):
        _ = client.client


def test_create_or_update_index_new_and_existing(api_mod):
    api, fake = api_mod
    c = api.MeilisearchClient(MeilisearchConfig())

    out = c.create_or_update_index("all")
    assert out["status"] == "ready"
    assert fake.idx.settings_updated is not None

    # already exists branch
    from meilisearch.errors import MeilisearchError

    fake.create_raises = MeilisearchError("already exists")
    out2 = c.create_or_update_index("all")
    assert out2["index"] == "all"

    # unexpected error branch
    fake.create_raises = MeilisearchError("different")
    with pytest.raises(MeilisearchError):
        c.create_or_update_index("all")


def test_create_or_update_index_with_explicit_settings(api_mod):
    api, _ = api_mod
    c = api.MeilisearchClient(MeilisearchConfig())
    custom = IndexSettings(searchable_attributes=["title"])
    out = c.create_or_update_index("all", settings=custom)
    assert out["status"] == "ready"


def test_add_documents_empty_and_batches(api_mod, docs):
    api, fake = api_mod
    c = api.MeilisearchClient(MeilisearchConfig(batch_size=2))

    empty_stats = c.add_documents("all", [])
    assert empty_stats.total_documents == 0

    stats = c.add_documents("all", docs, batch_size=2)
    assert stats.total_documents == 3
    assert stats.indexed_documents == 3

    fake.idx.fail_add = True
    stats2 = c.add_documents("all", docs, batch_size=2)
    assert stats2.errors == 3


def test_add_documents_outer_exception(api_mod, docs, monkeypatch):
    api, fake = api_mod
    c = api.MeilisearchClient(MeilisearchConfig(batch_size=2))

    class BadDoc:
        def model_dump(self):
            raise RuntimeError("serialize failed")

    with pytest.raises(RuntimeError):
        c.add_documents("all", [BadDoc()])


def test_search_and_error_branch(api_mod):
    api, fake = api_mod
    c = api.MeilisearchClient(MeilisearchConfig())

    results = c.search("all", "query")
    assert len(results) == 1
    assert results[0].type == "chat"

    fake.idx.fail_search = True
    from meilisearch.errors import MeilisearchError

    with pytest.raises(MeilisearchError):
        c.search("all", "query")


def test_delete_get_stats_list_clear_and_errors(api_mod):
    api, fake = api_mod
    c = api.MeilisearchClient(MeilisearchConfig())

    assert c.delete_index("all") is True
    assert c.get_index_stats("all")["isIndexing"] is False
    assert c.list_indices()[0]["name"] == "all"
    assert c.clear_index("all") is True

    from meilisearch.errors import MeilisearchError

    fake.fail_delete = True
    with pytest.raises(MeilisearchError):
        c.delete_index("all")

    fake.idx.fail_stats = True
    with pytest.raises(MeilisearchError):
        c.get_index_stats("all")

    fake.fail_list = True
    with pytest.raises(MeilisearchError):
        c.list_indices()

    fake.idx.fail_clear = True
    with pytest.raises(MeilisearchError):
        c.clear_index("all")
