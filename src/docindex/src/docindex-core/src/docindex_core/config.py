"""
Meilisearch Integration Module
Configuration, models, and schemas for Sphinx document indexing.
"""

from __future__ import annotations

import os
from enum import Enum
from typing import Optional, List, Any
from datetime import datetime, timezone

from pydantic import BaseModel, Field, ConfigDict


class DocumentType(str, Enum):
    """Types of documents that can be indexed.

    Format-specific types enable targeted parsing, format-aware ranking,
    and proper routing through the indexing pipeline.
    """

    CHAT = "chat"  # generic / undifferentiated chat section
    CHAT_INPUT = "chat_input"  # user / human turn
    CHAT_THINKING = "chat_thinking"  # model reasoning / thinking turn
    CHAT_OUTPUT = "chat_output"  # model / assistant response turn
    SPHINX_RST = "sphinx_rst"  # reStructuredText source files
    SPHINX_MD = "sphinx_md"  # MyST or Markdown source files
    SPHINX_NB = "sphinx_nb"  # Jupyter Notebook source files
    SPHINX_HTML = "sphinx_html"  # Post-build Sphinx HTML output
    JSON = "json"


class CodeSnippet(BaseModel):
    """Code snippet embedded in document."""

    language: str
    code: str
    line_start: Optional[int] = None
    line_end: Optional[int] = None


class DocumentMetadata(BaseModel):
    """Metadata for indexed documents."""

    source_file: str
    date_indexed: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    chat_type: Optional[str] = None
    tags: List[str] = Field(default_factory=list)
    concepts: List[str] = Field(default_factory=list)
    word_count: Optional[int] = None
    heading_level: Optional[int] = None
    breadcrumb: Optional[List[str]] = None
    last_built: Optional[datetime] = None
    sphinx_role: Optional[str] = None


class Document(BaseModel):
    """Document to be indexed in Meilisearch."""

    model_config = ConfigDict(use_enum_values=True)

    id: str
    type: DocumentType
    title: str
    content: str
    filename: str
    url: Optional[str] = None
    summary: Optional[str] = None
    code_snippets: List[CodeSnippet] = Field(default_factory=list)
    metadata: DocumentMetadata
    build_id: Optional[str] = None


class DocIndexConfig(BaseModel):
    """General configuration for docindex backends."""

    backend: str = Field(
        default="oxirs",
        description="Backend to use: 'oxirs', 'milli', or comma-separated list like 'oxirs,milli'",
    )
    host: str = Field(default="localhost", description="Host (Meilisearch)")
    port: int = Field(default=7700, description="Port (Meilisearch)")
    api_key: Optional[str] = Field(default=None, description="API key (Meilisearch)")
    url: Optional[str] = Field(default=None, description="HTTP URL (OxiRS / custom)")
    storage_path: Optional[str] = Field(
        default=None, description="Local database storage path (OxiRS)"
    )
    batch_size: int = Field(default=1000, description="Batch size for indexing")
    index_name: str = Field(default="all", description="Default index/graph name")
    enabled: bool = Field(default=True, description="Enable indexing")

    @property
    def backends(self) -> List[str]:
        """Parsed list of active search backends."""
        return [b.strip() for b in self.backend.split(",") if b.strip()]

    @classmethod
    def from_env(cls) -> DocIndexConfig:
        """Load configuration from environment variables."""
        return cls(
            backend=os.getenv("DOCINDEX_BACKEND", "oxirs").lower(),
            host=os.getenv("MEILISEARCH_HOST", "localhost"),
            port=int(os.getenv("MEILISEARCH_PORT", "7700")),
            api_key=os.getenv("MEILISEARCH_API_KEY"),
            url=os.getenv("OXIRS_URL"),
            storage_path=os.getenv("OXIRS_STORAGE_PATH"),
            batch_size=int(
                os.getenv(
                    "DOCINDEX_BATCH_SIZE", os.getenv("MEILISEARCH_BATCH_SIZE", "1000")
                )
            ),
            enabled=os.getenv(
                "DOCINDEX_ENABLED", os.getenv("MEILISEARCH_ENABLED", "true")
            ).lower()
            == "true",
        )


class SearchResult(BaseModel):
    """Result from a search query."""

    id: str
    type: DocumentType
    title: str
    url: Optional[str] = None
    source_uri: Optional[str] = None
    content: str = ""
    content_snippet: str
    date_indexed: Optional[str] = None
    relevance_score: float
    matched_fields: List[str] = Field(default_factory=list)


class IndexingStats(BaseModel):
    """Statistics from indexing operation."""

    total_documents: int
    indexed_documents: int
    skipped_documents: int
    errors: int
    start_time: datetime
    end_time: datetime
    duration_seconds: float

    @property
    def success_rate(self) -> float:
        """Calculate success rate as percentage."""
        if self.total_documents == 0:
            return 0.0
        return (self.indexed_documents / self.total_documents) * 100


# Default settings (lazy imports for backward compatibility to prevent circular import)
def __getattr__(name: str) -> Any:
    if name in ("IndexSettings", "DEFAULT_INDEX_SETTINGS", "MeilisearchConfig"):
        from .backends.milli import IndexSettings, DEFAULT_INDEX_SETTINGS, MilliConfig

        if name == "IndexSettings":
            return IndexSettings
        elif name == "DEFAULT_INDEX_SETTINGS":
            return DEFAULT_INDEX_SETTINGS
        elif name == "MeilisearchConfig":
            return MilliConfig
    raise AttributeError(f"module '{__name__}' has no attribute '{name}'")
