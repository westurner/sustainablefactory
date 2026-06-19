"""
Meilisearch Integration Module
Configuration, models, and schemas for Sphinx document indexing.
"""

from __future__ import annotations

import os
from enum import Enum
from typing import Optional, List, Dict, Any
from datetime import datetime, timezone
from pathlib import Path

from pydantic import BaseModel, Field, ConfigDict


class DocumentType(str, Enum):
    """Types of documents that can be indexed."""
    CHAT = "chat"
    SPHINX = "sphinx"
    MYST = "myst"
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


class MeilisearchConfig(BaseModel):
    """Configuration for Meilisearch connection."""
    host: str = Field(default="localhost", description="Meilisearch host")
    port: int = Field(default=7700, description="Meilisearch port")
    api_key: Optional[str] = Field(default=None, description="Meilisearch API key")
    batch_size: int = Field(default=1000, description="Batch size for indexing")
    index_name: str = Field(default="all", description="Default index name")
    enabled: bool = Field(default=True, description="Enable Meilisearch indexing")
    
    @property
    def url(self) -> str:
        """Get Meilisearch URL."""
        return f"http://{self.host}:{self.port}"
    
    @classmethod
    def from_env(cls) -> MeilisearchConfig:
        """Load configuration from environment variables."""
        return cls(
            host=os.getenv("MEILISEARCH_HOST", "localhost"),
            port=int(os.getenv("MEILISEARCH_PORT", "7700")),
            api_key=os.getenv("MEILISEARCH_API_KEY"),
            batch_size=int(os.getenv("MEILISEARCH_BATCH_SIZE", "1000")),
            enabled=os.getenv("MEILISEARCH_ENABLED", "true").lower() == "true"
        )


class IndexSettings(BaseModel):
    """Meilisearch index settings."""
    searchable_attributes: List[str] = [
        "title",
        "content",
        "summary",
        "concepts"
    ]
    filterable_attributes: List[str] = [
        "type",
        "date_indexed",
        "filename",
        "chat_type"
    ]
    sortable_attributes: List[str] = [
        "date_indexed"
    ]
    synonyms: Dict[str, List[str]] = Field(
        default_factory=lambda: {
            "lignin": ["kraft lignin", "kraft-lignin", "lig"],
            "vitrimer": ["vitrimer polymer", "vitrimeric"],
            "cnt": ["carbon nanotube", "carbon nanotubes"],
            "rdf": ["resource description framework", "semantic web"],
            "myst": ["myst markdown", "markedly structured text"],
        }
    )


class SearchResult(BaseModel):
    """Result from a search query."""
    id: str
    type: DocumentType
    title: str
    url: Optional[str] = None
    content_snippet: str
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


# Default settings
DEFAULT_INDEX_SETTINGS = IndexSettings()
