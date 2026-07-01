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

from .config import DocIndexConfig, MeilisearchConfig, DocumentType, IndexingStats, DEFAULT_INDEX_SETTINGS
from .chat_parser import BatchChatIndexer
from .html_parser import BatchHTMLIndexer
from .backends.base import BaseSearchBackend
from .api import MeilisearchClient

logger = logging.getLogger(__name__)

try:
    from tqdm.auto import tqdm as _tqdm
    _HAS_TQDM = True
except ImportError:  # pragma: no cover
    _HAS_TQDM = False
    _tqdm = None


class DocumentIndexer:
    """Main indexer coordinating all indexing operations."""
    
    def __init__(
        self,
        config: Optional[DocIndexConfig | MeilisearchConfig] = None,
        backend: Optional[BaseSearchBackend] = None
    ):
        """Initialize indexer.
        
        Args:
            config: Config instance. If None, loads from environment.
            backend: Optional custom backend instance.
        """
        if backend is not None:
            self.client = backend
            self.config = getattr(backend, 'config', None)
        else:
            self.config = config or DocIndexConfig.from_env()
            
            # Dynamically import and build backend(s)
            backends_list = getattr(self.config, 'backends', [])
            if not backends_list:
                backends_list = [getattr(self.config, 'backend', 'oxirs') or 'oxirs']  # pragma: no cover

            clients = []
            for backend_type in backends_list:
                if backend_type == 'oxirs':
                    from .backends.oxirs import OxiRSBackend, OxiRSConfig
                    oxirs_conf = OxiRSConfig(
                        url=self.config.url,
                        storage_path=self.config.storage_path,
                        batch_size=self.config.batch_size,
                        enabled=self.config.enabled
                    )
                    clients.append(OxiRSBackend(oxirs_conf))
                else:
                    from .backends.milli import MilliBackend, MilliConfig
                    milli_conf = MilliConfig(
                        host=self.config.host,
                        port=self.config.port,
                        api_key=self.config.api_key,
                        batch_size=self.config.batch_size,
                        index_name=self.config.index_name,
                        enabled=self.config.enabled
                    )
                    clients.append(MeilisearchClient(milli_conf))

            if len(clients) > 1:
                from .backends.multi import MultiBackend
                self.client = MultiBackend(clients)
            elif clients:
                self.client = clients[0]
            else:
                raise ValueError("No active search backend configured.")  # pragma: no cover

        
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
        pending_tasks: dict,
        submit_counts: dict,
    ) -> None:
        """Submit one batch to *index_name* with exponential-backoff retry.

        Instead of waiting for task completion, the task uid is appended to
        *pending_tasks[index_name]* so the caller can finalize all indices in
        one consolidated wait at the end.
        """
        last_exc: Optional[Exception] = None

        for attempt in range(max_retries):
            try:
                tasks, n_ok, n_err = self.client._submit_batches(
                    index_name, batch, len(batch)
                )
                pending_tasks.setdefault(index_name, []).extend(tasks)
                prev = submit_counts.get(index_name, (0, 0))
                submit_counts[index_name] = (prev[0] + n_ok, prev[1] + n_err)
                return
            except Exception as exc:
                last_exc = exc
                logger.warning(
                    f"Batch submit to '{index_name}' failed "
                    f"(attempt {attempt + 1}/{max_retries}): {exc}"
                )
                if attempt < max_retries - 1:
                    wait = retry_delay * (2 ** attempt)
                    logger.info(f"Retrying in {wait:.1f}s…")
                    time.sleep(wait)

        if last_exc is not None:
            raise last_exc

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

        if str(doc.type).startswith('chat'):
            indices.append('chats')
        elif str(doc.type).startswith('sphinx'):
            indices.append('sphinx')
            # Route SPHINX_MD documents to 'myst' index for MyST-specific queries
            if doc.type in (DocumentType.SPHINX_MD, "sphinx_md"):
                indices.append('myst')

        return indices

    def index_chat_directory(
        self,
        chat_dir: Path,
        skip_unchanged: bool = False,
        progress: bool = True,
        total_estimate: Optional[int] = None,
        pipeline: bool = True,
    ) -> IndexingStats:
        """Index all chat files in a directory with memory-efficient batching.

        Args:
            chat_dir: Path to directory containing chat files
            skip_unchanged: Skip files that haven't changed (requires cache)
            progress: Show a tqdm progress bar.  Defaults to True.
            total_estimate: Expected total document count for the progress bar
                percentage.  Derived from file count when None.
            pipeline: When True (default) all batches are submitted without
                waiting and flushed in one consolidated wait at the end
                (faster).  When False each batch waits for its task to complete
                before the next submission (legacy / safer for debugging).

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

        # Use file count × rough average as estimate when caller doesn't provide one.
        if total_estimate is None:
            try:
                n_files = len(indexer.get_chat_files())
                total_estimate = n_files * 120  # ~120 docs/file heuristic
            except AttributeError:
                pass  # FakeBatchChat in tests may not expose this method

        start_time = datetime.now(timezone.utc)
        batch: List = []
        total_submitted = 0
        file_count = 0
        batch_size = self.config.batch_size

        # Per-index accumulators (fire-and-collect pattern)
        pending_tasks: dict = {}   # index_name → [(task_uid, batch_len)]
        submit_counts: dict = {}   # index_name → (n_ok, n_err)

        pbar = (
            _tqdm(
                total=total_estimate,
                desc=f"Indexing {chat_dir.name}",
                unit="doc",
            )
            if (progress and _HAS_TQDM)
            else None
        )
        try:
            for filepath, documents in indexer.parse_all():
                file_count += 1

                for doc in documents:
                    batch.append(doc)
                    if pbar is not None:
                        pbar.update(1)

                    if len(batch) >= batch_size:
                        for index_name in self._get_index_names_for_document(batch[0]):
                            tasks, n_ok, n_err = self.client._submit_batches(
                                index_name, batch, batch_size
                            )
                            pending_tasks.setdefault(index_name, []).extend(tasks)
                            prev = submit_counts.get(index_name, (0, 0))
                            submit_counts[index_name] = (prev[0] + n_ok, prev[1] + n_err)
                        total_submitted += len(batch)
                        logger.info(
                            f"Submitted batch of {len(batch)} docs "
                            f"({total_submitted} total from {file_count} files)"
                        )
                        batch = []

            if batch:
                for index_name in self._get_index_names_for_document(batch[0]):
                    tasks, n_ok, n_err = self.client._submit_batches(
                        index_name, batch, batch_size
                    )
                    pending_tasks.setdefault(index_name, []).extend(tasks)
                    prev = submit_counts.get(index_name, (0, 0))
                    submit_counts[index_name] = (prev[0] + n_ok, prev[1] + n_err)
                total_submitted += len(batch)
                logger.info(f"Submitted final batch of {len(batch)} docs")
        finally:
            if pbar is not None:
                pbar.set_postfix_str(f"{total_submitted} submitted")
                pbar.close()

        # ── Consolidated wait + verify ─────────────────────────────────────────
        logger.info(
            f"All batches submitted ({total_submitted} docs across "
            f"{len(pending_tasks)} index(es)). Waiting for tasks…"
        )
        last_stats = None
        for index_name, tasks in pending_tasks.items():
            n_ok, n_err = submit_counts.get(index_name, (0, 0))
            stats = self.client._finalize_tasks(
                index_name, tasks, n_ok, n_err, start_time, progress
            )
            if index_name == 'all':
                last_stats = stats

        try:
            self.client.optimize()
        except Exception as e:
            logger.warning(f"Failed to optimize search backend: {e}")

        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()

        if last_stats:
            logger.info(
                f"Chat indexing complete: {total_submitted} docs "
                f"from {file_count} files in {duration:.2f}s"
            )
            return last_stats

        logger.warning("No documents collected for indexing")
        return IndexingStats(
            total_documents=0,
            indexed_documents=0,
            skipped_documents=0,
            errors=0,
            start_time=start_time,
            end_time=end_time,
            duration_seconds=duration,
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
        """Index Sphinx HTML to Meilisearch with atomic guarantees (zero-gap updates).

        This command uses a version-tag strategy to achieve zero-gap updates:
        - New sphinx docs are written to the live 'all' index immediately
        - Per-source indices (sphinx, myst) use atomic index swaps
        - Stale docs are garbage-collected by build_id

        Zero downtime: searches never see a gap where sphinx docs are absent.
        Cancellation-safe: staging indices are cleaned up; live indices untouched.
        """
        html_dir = Path(html_dir)
        logger.info(f"Atomic HTML indexing: {html_dir} (staging suffix='{staging_suffix}')")

        try:
            indexer = BatchHTMLIndexer(html_dir)
        except ValueError as e:
            logger.error(f"Failed to initialize HTML indexer: {e}")
            raise

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
        total_docs_sent = 0
        file_count = 0
        batch_size = self.config.batch_size
        last_stats: Optional[IndexingStats] = None
        cancelled = False

        # Per-index accumulators for pipelined submission
        pending_tasks: dict = {}
        submit_counts: dict = {}

        def _flush_to_staging(b: List) -> None:
            nonlocal total_docs_sent
            # Stamp every doc with this build's ID
            for doc in b:
                doc.build_id = build_id
            # All sphinx docs go to sphinx_staging
            self._send_batch_with_retry(
                sphinx_staging, b, max_retries, retry_delay, pending_tasks, submit_counts
            )
            # Also write to 'all' immediately — new docs join the live index
            # alongside the still-present old docs (overlap, not a gap)
            self._send_batch_with_retry(
                "all", b, max_retries, retry_delay, pending_tasks, submit_counts
            )
            # MyST/MD docs additionally go to myst_staging
            myst_batch = [
                d for d in b
                if hasattr(d, 'type') and str(getattr(d, 'type', '')).endswith('sphinx_md')
            ]
            if myst_batch:
                self._send_batch_with_retry(
                    myst_staging, myst_batch, max_retries, retry_delay, pending_tasks, submit_counts
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

        # Wait for all staged batches before swapping
        for index_name, tasks in list(pending_tasks.items()):
            n_ok, n_err = submit_counts.get(index_name, (0, 0))
            stats = self.client._finalize_tasks(
                index_name, tasks, n_ok, n_err, start_time, False
            )
            if index_name == sphinx_staging:
                last_stats = stats

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

        try:
            self.client.optimize()
        except Exception as e:
            logger.warning(f"Failed to optimize search backend: {e}")

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

    def index_sphinx_html_legacy(
        self,
        html_dir: Path,
        max_heading_level: int = 3,
        exclude_patterns: Optional[List[str]] = None,
        max_retries: int = 3,
        retry_delay: float = 1.0,
        progress: bool = True,
        total_estimate: Optional[int] = None,
        pipeline: bool = True,
    ) -> IndexingStats:
        """Index Sphinx HTML with memory-efficient pipelined batching (non-atomic).

        Use --no-pipeline to flush each batch synchronously (legacy mode,
        easier to debug task failures at the cost of higher latency).

        DEPRECATED: Use index_sphinx_html for zero-gap atomic updates.
        """
        html_dir = Path(html_dir)
        logger.info(f"Indexing Sphinx HTML (legacy): {html_dir}")

        try:
            indexer = BatchHTMLIndexer(html_dir)
        except ValueError as e:
            logger.error(f"Failed to initialize HTML indexer: {e}")
            raise

        # Use file count × rough average as estimate when caller doesn't provide one.
        if total_estimate is None:
            try:
                n_files = len(indexer.get_html_files(exclude_patterns))
                total_estimate = n_files * 230  # ~230 docs/file heuristic
            except AttributeError:
                pass  # FakeBatchHtml in tests may not expose this method

        start_time = datetime.now(timezone.utc)
        batch: List = []
        total_submitted = 0
        file_count = 0
        batch_size = self.config.batch_size
        cancelled = False

        # Per-index accumulators (fire-and-collect pattern)
        pending_tasks: dict = {}   # index_name → [(task_uid, batch_len)]
        submit_counts: dict = {}   # index_name → (n_ok, n_err)

        pbar = (
            _tqdm(
                total=total_estimate,
                desc=f"Indexing {html_dir.name}",
                unit="doc",
            )
            if (progress and _HAS_TQDM)
            else None
        )

        def _flush_batch(b: List) -> None:
            for index_name in self._get_index_names_for_document(b[0]):
                self._send_batch_with_retry(
                    index_name, b, max_retries, retry_delay,
                    pending_tasks, submit_counts,
                )

        try:
            for filepath, documents in indexer.parse_all(
                exclude_patterns=exclude_patterns,
                max_heading_level=max_heading_level,
            ):
                file_count += 1

                for doc in documents:
                    batch.append(doc)
                    if pbar is not None:
                        pbar.update(1)

                    if len(batch) >= batch_size:
                        _flush_batch(batch)
                        total_submitted += len(batch)
                        logger.info(
                            f"Submitted batch of {len(batch)} docs "
                            f"({total_submitted} total from {file_count} files)"
                        )
                        batch = []

        except KeyboardInterrupt:
            cancelled = True
            logger.warning(
                f"HTML indexing cancelled after {total_submitted} docs "
                f"from {file_count} files. Index may be partial."
            )
        finally:
            if pbar is not None:
                pbar.set_postfix_str(f"{total_submitted} submitted")
                pbar.close()

        if batch and not cancelled:
            _flush_batch(batch)
            total_submitted += len(batch)
            logger.info(f"Submitted final batch of {len(batch)} docs")
        elif batch and cancelled:
            logger.warning(
                f"Discarding unsent in-memory batch of {len(batch)} docs "
                "due to cancellation."
            )

        # ── Consolidated wait + verify ─────────────────────────────────────────
        if not cancelled:
            logger.info(
                f"All batches submitted ({total_submitted} docs across "
                f"{len(pending_tasks)} index(es)). Waiting for tasks…"
            )

        last_stats = None
        for index_name, tasks in pending_tasks.items():
            n_ok, n_err = submit_counts.get(index_name, (0, 0))
            stats = self.client._finalize_tasks(
                index_name, tasks, n_ok, n_err, start_time, progress
            )
            if index_name == 'all':
                last_stats = stats

        end_time = datetime.now(timezone.utc)
        duration = (end_time - start_time).total_seconds()

        if last_stats:
            if cancelled:  # pragma: no cover
                logger.warning(
                    f"HTML indexing incomplete: {total_submitted} docs "
                    f"from {file_count} files in {duration:.2f}s (cancelled)"
                )
            else:
                logger.info(
                    f"HTML indexing complete: {total_submitted} docs "
                    f"from {file_count} files in {duration:.2f}s"
                )
            return last_stats

        logger.warning("No documents collected for HTML indexing")
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
