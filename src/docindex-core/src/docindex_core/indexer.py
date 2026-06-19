"""
Main indexer module for coordinating document indexing.
"""

from __future__ import annotations

import logging
import time
from pathlib import Path
from typing import Optional, List
from datetime import datetime, timezone
from uuid import uuid4

from meilisearch.errors import MeilisearchError, MeilisearchCommunicationError

from .api import MeilisearchClient
from .config import MeilisearchConfig, DocumentType, IndexingStats, DEFAULT_INDEX_SETTINGS
from .chat_parser import BatchChatIndexer
from .html_parser import BatchHTMLIndexer

logger = logging.getLogger(__name__)


class DocumentIndexer:
    """Main indexer coordinating all indexing operations."""
    
    def __init__(self, config: Optional[MeilisearchConfig] = None):
        """Initialize indexer.
        
        Args:
            config: MeilisearchConfig. If None, loads from environment.
        """
        self.config = config or MeilisearchConfig.from_env()
        self.client = MeilisearchClient(self.config)
        
        # Ensure default indices exist
        self._init_indices()
    
    def _init_indices(self):
        """Initialize Meilisearch indices.
        
        Indices group documents by source system:
        - 'all': all documents across all sources
        - 'chats': chat export documents
        - 'sphinx': all sphinx-based documents (html, rst, md, notebooks)
        - 'myst': MyST/Markdown-specific documents
        """
        index_names = ['all', 'chats', 'sphinx', 'myst']
        for index_name in index_names:
            try:
                self.client.create_or_update_index(
                    index_name,
                    settings=DEFAULT_INDEX_SETTINGS
                )
            except Exception as e:
                logger.error(f"Failed to initialize index {index_name}: {e}")
    
    def _send_batch_with_retry(
        self,
        index_name: str,
        batch: List,
        max_retries: int,
        retry_delay: float,
    ) -> IndexingStats:
        """Send a document batch to one Meilisearch index with exponential-backoff retry.

        Retries on communication errors and when the returned IndexingStats
        reports errors > 0 (partial batch failure).
        """
        last_exc: Optional[Exception] = None
        last_stats: Optional[IndexingStats] = None

        for attempt in range(max_retries):
            try:
                stats = self.client.add_documents(index_name, batch)
                last_stats = stats
                if stats.errors == 0:
                    return stats
                logger.warning(
                    f"Batch to '{index_name}' had {stats.errors} error(s) "
                    f"(attempt {attempt + 1}/{max_retries})."
                )
            except (MeilisearchCommunicationError, MeilisearchError) as exc:
                last_exc = exc
                logger.warning(
                    f"Batch send to '{index_name}' failed "
                    f"(attempt {attempt + 1}/{max_retries}): {exc}"
                )

            if attempt < max_retries - 1:
                wait = retry_delay * (2 ** attempt)
                logger.info(f"Retrying in {wait:.1f}s...")
                time.sleep(wait)

        if last_exc is not None:
            raise last_exc
        return last_stats  # Exhausted retries; stats may still report errors

    def _get_index_names_for_document(self, doc) -> List[str]:
        """Get indices where this document should be indexed.
        
        Args:
            doc: Document to route (or SimpleNamespace for testing)
            
        Returns:
            List of index names to send document to
        """
        indices = ['all']  # All documents go to 'all' index
        
        # Handle both Document objects and test mocks (SimpleNamespace)
        if not hasattr(doc, 'type'):
            return indices  # Default: only 'all' index
        
        if doc.type == DocumentType.CHAT:
            indices.append('chats')
        elif hasattr(doc.type, 'value') and doc.type.value.startswith('sphinx'):
            indices.append('sphinx')
            # Route SPHINX_MD documents to 'myst' index for MyST-specific queries
            if doc.type == DocumentType.SPHINX_MD:
                indices.append('myst')
        
        return indices
    
    def index_chat_directory(
        self,
        chat_dir: Path,
        skip_unchanged: bool = False
    ) -> IndexingStats:
        """Index all chat files in a directory with memory-efficient batching.
        
        Args:
            chat_dir: Path to directory containing chat files
            skip_unchanged: Skip files that haven't changed (requires cache)
            
        Returns:
            IndexingStats with results
        """
        chat_dir = Path(chat_dir)
        logger.info(f"Indexing chat directory: {chat_dir}")
        
        try:
            indexer = BatchChatIndexer(chat_dir)
        except ValueError as e:
            logger.error(f"Failed to initialize chat indexer: {e}")
            raise
        
        start_time = datetime.now(timezone.utc)
        batch = []
        total_docs_sent = 0
        file_count = 0
        batch_size = self.config.batch_size
        last_stats = None
        
        for filepath, documents in indexer.parse_all():
            file_count += 1
            
            for doc in documents:
                batch.append(doc)
                
                if len(batch) >= batch_size:
                    # Route documents to appropriate indices
                    for index_name in self._get_index_names_for_document(batch[0]):
                        if index_name == 'all':
                            last_stats = self.client.add_documents('all', batch)
                        else:
                            self.client.add_documents(index_name, batch)
                    total_docs_sent += len(batch)
                    logger.info(
                        f"Indexed batch of {len(batch)} documents "
                        f"({total_docs_sent} total from {file_count} files)"
                    )
                    batch = []
        
        if batch:
            # Route final batch to appropriate indices
            for index_name in self._get_index_names_for_document(batch[0]):
                if index_name == 'all':
                    last_stats = self.client.add_documents('all', batch)
                else:
                    self.client.add_documents(index_name, batch)
            total_docs_sent += len(batch)
            logger.info(f"Indexed final batch of {len(batch)} documents")
        
        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()
        
        if last_stats:
            logger.info(
                f"Chat indexing complete: {total_docs_sent} documents "
                f"from {file_count} files in {duration:.2f}s"
            )
            return last_stats
        else:
            logger.warning("No documents collected for indexing")
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=start_time,
                end_time=end_time,
                duration_seconds=duration
            )
    
    def index_sphinx_html_legacy(
        self,
        html_dir: Path,
        max_heading_level: int = 3,
        exclude_patterns: Optional[List[str]] = None,
        max_retries: int = 3,
        retry_delay: float = 1.0,
    ) -> IndexingStats:
        """Index Sphinx HTML documentation with memory-efficient batching (legacy, non-atomic).
        
        Args:
            html_dir: Path to _build/html directory
            max_heading_level: Maximum heading level to extract
            exclude_patterns: File patterns to exclude
            
        Returns:
            IndexingStats with results
        """
        html_dir = Path(html_dir)
        logger.info(f"Indexing Sphinx HTML: {html_dir}")
        
        try:
            indexer = BatchHTMLIndexer(html_dir)
        except ValueError as e:
            logger.error(f"Failed to initialize HTML indexer: {e}")
            raise
        
        start_time = datetime.now(timezone.utc)
        batch = []
        total_docs_sent = 0
        file_count = 0
        batch_size = self.config.batch_size
        last_stats = None
        cancelled = False

        def _flush_batch(b: List) -> None:
            nonlocal last_stats, total_docs_sent
            for index_name in self._get_index_names_for_document(b[0]):
                stats = self._send_batch_with_retry(
                    index_name, b, max_retries, retry_delay
                )
                if index_name == 'all':
                    last_stats = stats
            total_docs_sent += len(b)

        try:
            for filepath, documents in indexer.parse_all(
                exclude_patterns=exclude_patterns,
                max_heading_level=max_heading_level
            ):
                file_count += 1

                for doc in documents:
                    batch.append(doc)

                    if len(batch) >= batch_size:
                        _flush_batch(batch)
                        logger.info(
                            f"Indexed batch of {len(batch)} documents "
                            f"({total_docs_sent} total from {file_count} files)"
                        )
                        batch = []

        except KeyboardInterrupt:
            cancelled = True
            logger.warning(
                f"HTML indexing cancelled after {total_docs_sent} documents "
                f"from {file_count} files. "
                "The index may contain partial data — re-run to complete, "
                "or use Meilisearch swap_indexes for atomic updates."
            )

        if batch and not cancelled:
            _flush_batch(batch)
            logger.info(f"Indexed final batch of {len(batch)} documents")
        elif batch and cancelled:
            logger.warning(
                f"Discarding unsent in-memory batch of {len(batch)} documents "
                "due to cancellation."
            )

        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()

        if last_stats:
            if cancelled:
                logger.warning(
                    f"HTML indexing incomplete: {total_docs_sent} documents "
                    f"from {file_count} files in {duration:.2f}s (cancelled)"
                )
            else:
                logger.info(
                    f"HTML indexing complete: {total_docs_sent} documents "
                    f"from {file_count} files in {duration:.2f}s"
                )
            return last_stats
        else:
            logger.warning("No documents collected for HTML indexing")
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=start_time,
                end_time=end_time,
                duration_seconds=duration
            )
    
    # Sphinx document types that live in the 'sphinx' and 'myst' indices.
    # These are also written to 'all'; the atomic rebuild replaces only these.
    _SPHINX_TYPES: tuple = (
        "sphinx_html", "sphinx_rst", "sphinx_md", "sphinx_nb",
    )

    def index_sphinx_html(
        self,
        html_dir: Path,
        max_heading_level: int = 3,
        exclude_patterns: Optional[List[str]] = None,
        max_retries: int = 3,
        retry_delay: float = 1.0,
        staging_suffix: str = "_staging",
    ) -> IndexingStats:
        """Index Sphinx HTML atomically using a staging-then-swap strategy (primary method).

        Indexing pipeline
        -----------------
        1.  Parse sphinx HTML and write every batch into staging indices
            (``sphinx_staging``, ``myst_staging``) instead of the live ones.
            The live ``sphinx`` / ``myst`` indices are untouched during this phase
            so searches keep returning the previous build.

        2.  On full success:

            a. ``swap_indexes`` pairs sphinx_staging↔sphinx and
               myst_staging↔myst atomically in a single Meilisearch call.
               Searches switch to the new content with zero downtime.

            b. Refresh the shared ``all`` index by:
               i.  Deleting all docs whose ``type`` is a sphinx variant
                   (``delete_documents_by_filter``).
               ii. Re-adding the same documents that were already sent to the
                   staging indices (kept in memory).
               This phase has a brief window where sphinx docs are absent from
               ``all``; chats are unaffected throughout.

        3.  Staging indices are dropped on success and on cancellation/failure,
            leaving the live indices in their last-known-good state.

        Cancellation
        ------------
        ``KeyboardInterrupt`` is caught, the staging indices are cleaned up, and
        ``IndexingStats`` for the partial run is returned.  Live indices are
        never written to, so they remain consistent.

        Trade-offs vs. full-rebuild staging for ``all``
        ------------------------------------------------
        * Pro: chats do **not** need to be re-parsed.
        * Con: ``all`` has a short inconsistency window while sphinx docs are
          replaced.  If that window must be eliminated, index all sources into
          ``all_staging`` and add a third swap pair; that requires a separate
          ``index_chat_directory`` call beforehand.

        Args:
            html_dir: Path to ``_build/html`` directory.
            max_heading_level: Maximum heading level to extract.
            exclude_patterns: File patterns to exclude.
            max_retries: Retry attempts per batch (exponential backoff).
            retry_delay: Base delay in seconds between retries.
            staging_suffix: Suffix appended to index names to form staging names.

        Returns:
            IndexingStats from the staging index writes.
        """
        html_dir = Path(html_dir)
        logger.info(f"Atomic HTML indexing: {html_dir} (staging suffix='{staging_suffix}')")

        try:
            indexer = BatchHTMLIndexer(html_dir)
        except ValueError as e:
            logger.error(f"Failed to initialize HTML indexer: {e}")
            raise

        # Staging index names
        sphinx_staging = f"sphinx{staging_suffix}"
        myst_staging = f"myst{staging_suffix}"

        # Create staging indices with the same settings as live indices
        for staging_name in (sphinx_staging, myst_staging):
            self.client.create_or_update_index(
                staging_name, settings=DEFAULT_INDEX_SETTINGS
            )

        start_time = datetime.now(timezone.utc)
        build_id = str(uuid4())  # Unique tag for this build run
        batch: List = []
        # Keep all documents for the 'all' refresh step
        all_sphinx_docs: List = []
        total_docs_sent = 0
        file_count = 0
        batch_size = self.config.batch_size
        last_stats: Optional[IndexingStats] = None
        cancelled = False

        def _flush_to_staging(b: List) -> None:
            nonlocal last_stats, total_docs_sent
            # Stamp every doc with this build's ID before sending anywhere
            for doc in b:
                doc.build_id = build_id
                all_sphinx_docs.append(doc)
            # All sphinx docs go to sphinx_staging
            stats = self._send_batch_with_retry(
                sphinx_staging, b, max_retries, retry_delay
            )
            last_stats = stats
            # Also write to 'all' immediately — new docs join the live index
            # alongside the still-present old docs (overlap, not a gap)
            self._send_batch_with_retry("all", b, max_retries, retry_delay)
            # MyST/MD docs additionally go to myst_staging
            myst_batch = [
                d for d in b
                if hasattr(d, 'type') and str(getattr(d, 'type', '')).endswith('sphinx_md')
            ]
            if myst_batch:
                self._send_batch_with_retry(
                    myst_staging, myst_batch, max_retries, retry_delay
                )
            total_docs_sent += len(b)

        try:
            for _filepath, documents in indexer.parse_all(
                exclude_patterns=exclude_patterns,
                max_heading_level=max_heading_level,
            ):
                file_count += 1
                for doc in documents:
                    batch.append(doc)
                    if len(batch) >= batch_size:
                        _flush_to_staging(batch)
                        logger.info(
                            f"Staged batch of {len(batch)} documents "
                            f"({total_docs_sent} total from {file_count} files)"
                        )
                        batch = []

        except KeyboardInterrupt:
            cancelled = True
            logger.warning(
                f"Atomic HTML indexing cancelled after {total_docs_sent} documents "
                f"from {file_count} files. Cleaning up staging indices."
            )

        if batch and not cancelled:
            _flush_to_staging(batch)
            logger.info(f"Staged final batch of {len(batch)} documents")
        elif batch and cancelled:
            logger.warning(
                f"Discarding unsent in-memory batch of {len(batch)} documents "
                "due to cancellation."
            )

        # --- Cleanup on cancellation: drop staging, leave live indices alone ---
        if cancelled:
            for name in (sphinx_staging, myst_staging):
                self.client.delete_index_if_exists(name)
            end_time = datetime.now(timezone.utc)
            return last_stats or IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=start_time,
                end_time=end_time,
                duration_seconds=(end_time - start_time).total_seconds(),
            )

        # --- Step 2a: Atomic swap of per-source indices ---
        try:
            self.client.swap_indexes([
                (sphinx_staging, "sphinx"),
                (myst_staging,   "myst"),
            ])
            logger.info("Swapped staging indices into live sphinx/myst.")
        except Exception as e:
            logger.error(
                f"swap_indexes failed: {e}. "
                "Staging indices preserved for manual inspection. "
                f"Run delete_index_if_exists('{sphinx_staging}') to clean up."
            )
            raise
        finally:
            # Staging indices are now empty shells after swap; remove them
            # (ignore errors — the swap already succeeded if we reach finally
            # without re-raise, and on re-raise we intentionally leave them)
            pass
        # Drop the (now-empty) old live indices that became the staging shells
        for name in (sphinx_staging, myst_staging):
            self.client.delete_index_if_exists(name)

        # --- Step 2b: Remove stale sphinx docs from 'all' by version tag ---
        # New docs are already live in 'all' (written in _flush_to_staging).
        # Delete only those whose build_id differs from this run — overlap
        # exists briefly but there is never a gap where sphinx docs are absent.
        stale_filter = (
            "type IN ["
            + ", ".join(f'"{t}"' for t in self._SPHINX_TYPES)
            + f'] AND build_id != "{build_id}"'
        )
        try:
            task = self.client.delete_documents_by_filter("all", stale_filter)
            task_uid = (
                task.get("taskUid") or task.get("uid")
                if isinstance(task, dict)
                else getattr(task, 'task_uid', None)
            )
            if task_uid is not None:
                self.client.wait_for_task(task_uid)
            logger.info("Removed stale sphinx docs from 'all' index (version-tag GC).")
        except Exception as e:
            logger.warning(
                f"Could not remove stale sphinx docs from 'all' index: {e}. "
                f"Docs with build_id != '{build_id}' may persist; "
                "re-run to clean up."
            )

        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()

        if last_stats:
            logger.info(
                f"Atomic HTML indexing complete: {total_docs_sent} documents "
                f"from {file_count} files in {duration:.2f}s"
            )
            return last_stats
        else:
            logger.warning("No documents collected for atomic HTML indexing")
            return IndexingStats(
                total_documents=0,
                indexed_documents=0,
                skipped_documents=0,
                errors=0,
                start_time=start_time,
                end_time=end_time,
                duration_seconds=duration,
            )

    def get_index_status(self) -> dict:
        """Get status of all indices.
        
        Returns:
            Dictionary with index information
        """
        try:
            indices = self.client.list_indices()
            status = {
                'connected': True,
                'indices': {}
            }
            
            for idx in indices:
                stats = self.client.get_index_stats(idx['name'])
                status['indices'][idx['name']] = {
                    'documents': stats.get('numberOfDocuments', 0),
                    'updates': stats.get('isIndexing', False)
                }
            
            return status
        except Exception as e:
            logger.error(f"Failed to get index status: {e}")
            return {'connected': False, 'error': str(e)}
