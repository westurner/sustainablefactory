"""
Chat export parser for indexing .json and .md chat files.
"""

from __future__ import annotations

import json
import logging
import re
from pathlib import Path
from typing import List, Optional, Generator

from .config import Document, DocumentType, DocumentMetadata

# Precompile regex patterns for efficiency
_SPLIT_PATTERN = re.compile(r"^# ", re.MULTILINE)
_WORD_SPLIT_PATTERN = re.compile(r"\S+")
# Meilisearch IDs must be alphanumeric, hyphens, or underscores (max 511 bytes).
_INVALID_ID_CHARS = re.compile(r"[^a-zA-Z0-9_-]")

# Map role strings (from JSON turn 'role' field) to DocumentType.
_ROLE_TO_DOC_TYPE: dict[str, DocumentType] = {
    # User / human turns
    "user": DocumentType.CHAT_INPUT,
    "human": DocumentType.CHAT_INPUT,
    "you": DocumentType.CHAT_INPUT,
    # Model / assistant response turns
    "model": DocumentType.CHAT_OUTPUT,
    "assistant": DocumentType.CHAT_OUTPUT,
    "gemini": DocumentType.CHAT_OUTPUT,
    "chatgpt": DocumentType.CHAT_OUTPUT,
    "claude": DocumentType.CHAT_OUTPUT,
    "bot": DocumentType.CHAT_OUTPUT,
    # Thinking / reasoning turns (some providers expose these)
    "thinking": DocumentType.CHAT_THINKING,
    "thought": DocumentType.CHAT_THINKING,
    "reasoning": DocumentType.CHAT_THINKING,
}

# Patterns that identify a markdown section as a particular chat role.
_MD_INPUT_PATTERN = re.compile(
    r"^(?:You asked:|User:|Human:|Q:|\*\*You\*\*)", re.IGNORECASE | re.MULTILINE
)
_MD_THINKING_PATTERN = re.compile(
    r"^(?:Thinking:|<think>|\*thinking\*)", re.IGNORECASE | re.MULTILINE
)
_MD_OUTPUT_PATTERN = re.compile(
    r"^(?:Gemini Replied:|Assistant:|AI:|A:|\*\*Gemini\*\*|\*\*Assistant\*\*)",
    re.IGNORECASE | re.MULTILINE,
)


def _role_to_doc_type(role: str) -> DocumentType:
    """Map a role string to the appropriate DocumentType."""
    return _ROLE_TO_DOC_TYPE.get(role.lower().strip(), DocumentType.CHAT_OUTPUT)


def _md_section_doc_type(section: str) -> DocumentType:
    """Heuristically determine the DocumentType of a markdown chat section."""
    if _MD_THINKING_PATTERN.search(section):
        return DocumentType.CHAT_THINKING
    if _MD_INPUT_PATTERN.search(section):
        return DocumentType.CHAT_INPUT
    if _MD_OUTPUT_PATTERN.search(section):
        return DocumentType.CHAT_OUTPUT
    return DocumentType.CHAT


def _sanitize_id(value: str) -> str:
    """Replace characters invalid in Meilisearch document IDs with underscores."""
    return _INVALID_ID_CHARS.sub("_", value)[:511]


logger = logging.getLogger(__name__)


class ChatParser:
    """Parse chat exports (JSON and Markdown) into indexable documents."""

    # Precompiled regex patterns
    HEADING_PATTERN = re.compile(r"^#+\s+(.+)$", re.MULTILINE)
    TURN_SEPARATOR = re.compile(r"^(?:You asked:|Gemini Replied:|---+)$", re.MULTILINE)
    SECTION_SPLIT_PATTERN = re.compile(r"\n---\n")

    @staticmethod
    def _count_words(text: str) -> int:
        """Count words efficiently without creating intermediate list.

        Uses regex findall instead of split() to avoid memory overhead.
        """
        return len(_WORD_SPLIT_PATTERN.findall(text))

    @staticmethod
    def parse_json_chat(filepath: Path) -> List[Document]:
        """Parse JSON chat export into documents.

        Args:
            filepath: Path to JSON chat file

        Returns:
            List of Document objects, one per turn/exchange
        """
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            logger.error(f"Failed to parse JSON chat {filepath}: {e}")
            return []

        documents = []
        stem = filepath.stem
        filename = filepath.name
        source_file = str(filepath)
        chat_type = ChatParser._detect_chat_type(filepath)

        # Handle different JSON structures
        if isinstance(data, list):
            turns = data
        elif isinstance(data, dict):
            turns = data.get("messages") or data.get("turns") or [data]
        else:
            logger.warning(f"Unexpected JSON structure in {filepath}")
            return []

        for i, turn in enumerate(turns):
            if not isinstance(turn, dict):
                continue

            # Extract content from turn (prefer 'content' field)
            content = turn.get("content") or turn.get("text") or turn.get("message", "")
            if not content:
                continue

            role = turn.get("role") or turn.get("author", "unknown")
            title = turn.get("title") or f"{stem} - Turn {i + 1}"
            doc_type = (
                _role_to_doc_type(role)
                if role and role != "unknown"
                else DocumentType.CHAT
            )

            # Create document for this turn
            doc = Document(
                id=f"chat_{_sanitize_id(stem)}_{i}",
                type=doc_type,
                title=title,
                content=content,
                filename=filename,
                summary=turn.get("summary"),
                metadata=DocumentMetadata(
                    source_file=source_file,
                    chat_type=chat_type,
                    tags=[role] if role else [],
                    word_count=ChatParser._count_words(content),
                ),
            )
            documents.append(doc)
            logger.debug(f"Parsed JSON turn {i + 1} from {filename}")

        return documents

    @staticmethod
    def parse_markdown_chat(filepath: Path) -> List[Document]:
        """Parse Markdown chat export into documents by sections/turns.

        Args:
            filepath: Path to Markdown chat file

        Returns:
            List of Document objects, one per major section
        """
        try:
            content = filepath.read_text(encoding="utf-8")
        except Exception as e:
            logger.error(f"Failed to read markdown chat {filepath}: {e}")
            return []

        documents = []
        stem = filepath.stem
        filename = filepath.name
        source_file = str(filepath)
        chat_type = ChatParser._detect_chat_type(filepath)

        # Try to split by major sections (heading level 1 or separator)
        sections = ChatParser._split_markdown_sections(content)

        for i, section in enumerate(sections):
            section = section.strip()
            if not section:  # pragma: no cover
                continue

            # Extract title from first heading
            heading_match = ChatParser.HEADING_PATTERN.search(section)
            title = (
                heading_match.group(1) if heading_match else f"{stem} - Section {i + 1}"
            )
            doc_type = _md_section_doc_type(section)

            doc = Document(
                id=f"chat_{_sanitize_id(stem)}_{i}",
                type=doc_type,
                title=title,
                content=section,
                filename=filename,
                metadata=DocumentMetadata(
                    source_file=source_file,
                    chat_type=chat_type,
                    word_count=ChatParser._count_words(section),
                ),
            )
            documents.append(doc)
            logger.debug(f"Parsed markdown section {i + 1} from {filename}")

        return documents

    @staticmethod
    def _split_markdown_sections(
        content: str, separator: Optional[str] = None
    ) -> List[str]:
        """Split markdown content into logical sections.

        Prefers "---" separators but falls back to H1 headings.

        Args:
            content: Markdown content to split
            separator: Ignored; kept for compatibility

        Returns:
            List of section strings
        """
        # Split by "---" separators first (turn separators)
        if "---" in content:
            sections = ChatParser.SECTION_SPLIT_PATTERN.split(content)
        else:
            # Fall back to heading-based splitting (H1 only)
            sections = _SPLIT_PATTERN.split(content)
            # Remove empty first section if present
            if sections and not sections[0].strip():
                sections = sections[1:]

        # Return non-empty sections (avoid intermediate list comprehension)
        return sections

    @staticmethod
    def _detect_chat_type(filepath: Path) -> str:
        """Detect chat source from filename.

        Args:
            filepath: Path to chat file

        Returns:
            Chat type string (e.g., 'gemini', 'copilot', 'custom')
        """
        name_lower = filepath.name.lower()
        if "gemini" in name_lower:
            return "gemini"
        if "copilot" in name_lower:
            return "copilot"
        if "gpt" in name_lower:  # pragma: no branch
            return "openai"
        if "openai" in name_lower:  # pragma: no branch
            return "openai"
        return "custom"

    @staticmethod
    def parse_chat_file(filepath: Path) -> List[Document]:
        """Parse any chat file format (JSON or Markdown).

        Args:
            filepath: Path to chat file

        Returns:
            List of Document objects
        """
        if not filepath.exists():
            logger.error(f"Chat file does not exist: {filepath}")
            return []

        if filepath.suffix.lower() == ".json":
            return ChatParser.parse_json_chat(filepath)
        elif filepath.suffix.lower() in [".md", ".myst.md", ".chatexport_abc1.md"]:
            return ChatParser.parse_markdown_chat(filepath)
        else:
            logger.warning(f"Unknown chat file format: {filepath}")
            return []


class BatchChatIndexer:
    """Batch process and index multiple chat files."""

    def __init__(self, chat_dir: Path):
        """Initialize indexer for a directory of chats.

        Args:
            chat_dir: Directory containing chat files
        """
        self.chat_dir = Path(chat_dir)
        if not self.chat_dir.exists():
            raise ValueError(f"Chat directory does not exist: {chat_dir}")

    def get_chat_files(self) -> List[Path]:
        """Get all chat files in directory.

        Returns:
            List of chat file paths
        """
        patterns = ["*.json", "*.myst.md"]
        files = []
        for pattern in patterns:
            files.extend(self.chat_dir.glob(pattern))
        return sorted(set(files))  # Remove duplicates and sort

    def parse_all(self) -> Generator[tuple[Path, List[Document]], None, None]:
        """Parse all chat files in directory.

        Yields:
            Tuples of (filepath, documents) for each chat file
        """
        files = self.get_chat_files()
        logger.info(f"Found {len(files)} chat files in {self.chat_dir}")

        for filepath in files:
            try:
                documents = ChatParser.parse_chat_file(filepath)
                if documents:
                    yield filepath, documents
                    logger.info(f"Parsed {filepath.name}: {len(documents)} documents")
                else:
                    logger.warning(f"No documents extracted from {filepath}")
            except Exception as e:
                logger.error(f"Error parsing {filepath}: {e}")
                continue

    def get_total_documents(self) -> int:
        """Count total documents across all chat files.

        Returns:
            Total number of documents that will be indexed
        """
        total = 0
        for _, documents in self.parse_all():
            total += len(documents)
        return total
