"""
Chat export parser for indexing .json and .md chat files.
"""

from __future__ import annotations

import json
import logging
import re
from pathlib import Path
from typing import List, Optional, Generator
from datetime import datetime

from .config import Document, DocumentType, DocumentMetadata

logger = logging.getLogger(__name__)


class ChatParser:
    """Parse chat exports (JSON and Markdown) into indexable documents."""
    
    # Heading pattern for markdown splitting
    HEADING_PATTERN = re.compile(r"^#+\s+(.+)$", re.MULTILINE)
    
    # Separator patterns for turns in markdown
    TURN_SEPARATOR = re.compile(r"^(?:You asked:|Gemini Replied:|---+)$", re.MULTILINE)
    
    @staticmethod
    def parse_json_chat(filepath: Path) -> List[Document]:
        """Parse JSON chat export into documents.
        
        Args:
            filepath: Path to JSON chat file
            
        Returns:
            List of Document objects, one per turn/exchange
        """
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except Exception as e:
            logger.error(f"Failed to parse JSON chat {filepath}: {e}")
            return []
        
        documents = []
        stem = filepath.stem
        
        # Handle different JSON structures
        if isinstance(data, list):
            # Array of turns
            turns = data
        elif isinstance(data, dict):
            # Object with 'messages' or 'turns' key
            turns = data.get("messages") or data.get("turns") or [data]
        else:
            logger.warning(f"Unexpected JSON structure in {filepath}")
            return []
        
        for i, turn in enumerate(turns):
            if not isinstance(turn, dict):
                continue
            
            # Extract content from turn
            content = turn.get("content") or turn.get("text") or turn.get("message", "")
            if not content:
                continue
            
            role = turn.get("role") or turn.get("author", "unknown")
            title = turn.get("title") or f"{stem} - Turn {i+1}"
            
            # Create document for this turn
            doc = Document(
                id=f"chat_{stem}_{i}",
                type=DocumentType.CHAT,
                title=title,
                content=content,
                filename=filepath.name,
                summary=turn.get("summary"),
                metadata=DocumentMetadata(
                    source_file=str(filepath),
                    chat_type=ChatParser._detect_chat_type(filepath),
                    tags=[role] if role else [],
                    word_count=len(content.split())
                )
            )
            documents.append(doc)
            logger.debug(f"Parsed JSON turn {i+1} from {filepath.name}")
        
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
            content = filepath.read_text(encoding='utf-8')
        except Exception as e:
            logger.error(f"Failed to read markdown chat {filepath}: {e}")
            return []
        
        documents = []
        stem = filepath.stem
        
        # Try to split by major sections (heading level 1 or separator)
        sections = ChatParser._split_markdown_sections(content)
        
        for i, section in enumerate(sections):
            if not section.strip():
                continue
            
            # Extract title from first heading
            heading_match = ChatParser.HEADING_PATTERN.search(section)
            title = heading_match.group(1) if heading_match else f"{stem} - Section {i+1}"
            
            # Sanitize content
            section_clean = section.strip()
            
            doc = Document(
                id=f"chat_{stem}_{i}",
                type=DocumentType.CHAT,
                title=title,
                content=section_clean,
                filename=filepath.name,
                metadata=DocumentMetadata(
                    source_file=str(filepath),
                    chat_type=ChatParser._detect_chat_type(filepath),
                    word_count=len(section_clean.split())
                )
            )
            documents.append(doc)
            logger.debug(f"Parsed markdown section {i+1} from {filepath.name}")
        
        return documents
    
    @staticmethod
    def _split_markdown_sections(content: str, separator: Optional[str] = None) -> List[str]:
        """Split markdown content into logical sections.
        
        Args:
            content: Markdown content to split
            separator: Optional custom separator pattern
            
        Returns:
            List of section strings
        """
        # Split by "---" separators first (turn separators)
        if "---" in content:
            sections = content.split("\n---\n")
        else:
            # Fall back to heading-based splitting (H1 only)
            sections = re.split(r"^# ", content, flags=re.MULTILINE)
            if sections[0].strip() == "":
                sections = sections[1:]  # Remove empty first section
        
        return [s.strip() for s in sections if s.strip()]
    
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
        elif "copilot" in name_lower:
            return "copilot"
        elif "gpt" in name_lower or "openai" in name_lower:
            return "openai"
        else:
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
        
        if filepath.suffix.lower() == '.json':
            return ChatParser.parse_json_chat(filepath)
        elif filepath.suffix.lower() in ['.md', '.myst.md', '.chatexport_abc1.md']:
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
        patterns = ['*.json', '*.md', '*.myst.md', '*.chatexport_abc1.md']
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
                    logger.info(
                        f"Parsed {filepath.name}: {len(documents)} documents"
                    )
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
