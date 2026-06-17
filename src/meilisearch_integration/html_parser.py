"""
HTML parser for indexing Sphinx-built documentation.
"""

from __future__ import annotations

import logging
import re
from pathlib import Path
from typing import List, Generator, Optional
from html.parser import HTMLParser
from html import unescape

from .config import Document, DocumentType, DocumentMetadata

logger = logging.getLogger(__name__)


class HTMLSectionExtractor(HTMLParser):
    """Extract text sections from HTML by heading levels."""
    
    def __init__(self, max_heading_level: int = 3):
        """Initialize HTML extractor.
        
        Args:
            max_heading_level: Maximum heading level to extract (1-6)
        """
        super().__init__()
        self.max_heading_level = max_heading_level
        self.sections: List[dict] = []
        self.current_section: Optional[dict] = None
        self.current_text: List[str] = []
        self.in_code = False
        self.in_script = False
        self.in_style = False
        self.tag_stack = []
    
    def handle_starttag(self, tag: str, attrs: tuple):
        """Handle opening tags."""
        self.tag_stack.append(tag)
        
        if tag in ['script', 'style']:
            if tag == 'script':
                self.in_script = True
            else:
                self.in_style = True
        elif tag == 'code':
            self.in_code = True
        elif tag.startswith('h') and len(tag) == 2:
            # Heading tag
            level = int(tag[1])
            if level <= self.max_heading_level:
                # Save previous section
                if self.current_section:
                    self.sections.append(self.current_section)
                
                # Start new section
                self.current_section = {
                    'level': level,
                    'title': '',
                    'content': [],
                    'start_tag': tag
                }
                self.current_text = []
    
    def handle_endtag(self, tag: str):
        """Handle closing tags."""
        if self.tag_stack and self.tag_stack[-1] == tag:
            self.tag_stack.pop()
        
        if tag == 'script':
            self.in_script = False
        elif tag == 'style':
            self.in_style = False
        elif tag == 'code':
            self.in_code = False
        elif tag.startswith('h') and self.current_section and self.current_section['start_tag'] == tag:
            # End of heading
            self.current_section['title'] = ' '.join(self.current_text).strip()
            self.current_text = []
        elif tag == 'p':
            # End of paragraph
            if self.current_text:
                self.current_section['content'].append(' '.join(self.current_text))
                self.current_text = []
    
    def handle_data(self, data: str):
        """Handle text data."""
        if self.in_script or self.in_style:
            return
        
        # Clean up whitespace but preserve content
        text = data.strip()
        if text and not text.isspace():
            self.current_text.append(unescape(text))
    
    def get_sections(self) -> List[dict]:
        """Get extracted sections.
        
        Returns:
            List of section dictionaries
        """
        if self.current_section:
            self.sections.append(self.current_section)
        
        return self.sections


class SphinxHTMLParser:
    """Parse Sphinx-built HTML files into indexable documents."""
    
    # Common navigation/footer elements to exclude
    EXCLUDE_PATTERNS = [
        'genindex', 'modindex', 'search', 'searchresults',
        'sitemap', 'robots', '404', 'notfound'
    ]
    
    @staticmethod
    def parse_html_file(
        filepath: Path,
        max_heading_level: int = 3,
        min_content_length: int = 50
    ) -> List[Document]:
        """Parse HTML file into documents.
        
        Args:
            filepath: Path to HTML file
            max_heading_level: Maximum heading level to extract
            min_content_length: Minimum characters for content section
            
        Returns:
            List of Document objects
        """
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                html_content = f.read()
        except Exception as e:
            logger.error(f"Failed to read HTML file {filepath}: {e}")
            return []
        
        # Extract sections
        extractor = HTMLSectionExtractor(max_heading_level=max_heading_level)
        try:
            extractor.feed(html_content)
        except Exception as e:
            logger.warning(f"Error parsing HTML {filepath}: {e}")
        
        sections = extractor.get_sections()
        if not sections:
            logger.warning(f"No sections extracted from {filepath}")
            return []
        
        documents = []
        stem = filepath.stem
        
        for i, section in enumerate(sections):
            # Extract content
            content = ' '.join(section['content']).strip()
            
            # Skip if content is too short
            if len(content) < min_content_length:
                continue
            
            title = section.get('title') or f"{stem} - Section {i+1}"
            
            # Calculate relative URL
            url = SphinxHTMLParser._calculate_url(filepath, stem)
            if section.get('title'):
                url = f"{url}#{SphinxHTMLParser._slugify(section['title'])}"
            
            doc = Document(
                id=f"html_{stem}_{i}",
                type=DocumentType.SPHINX,
                title=title,
                content=content,
                filename=filepath.name,
                url=url,
                metadata=DocumentMetadata(
                    source_file=str(filepath),
                    heading_level=section.get('level'),
                    word_count=len(content.split()),
                    breadcrumb=[title]  # Could be enhanced with actual breadcrumb
                )
            )
            documents.append(doc)
        
        logger.debug(
            f"Extracted {len(documents)} documents from {filepath.name}"
        )
        return documents
    
    @staticmethod
    def _calculate_url(filepath: Path, stem: str) -> str:
        """Calculate relative URL for HTML file.
        
        Args:
            filepath: Path to HTML file
            stem: File stem (name without extension)
            
        Returns:
            Relative URL path
        """
        # Remove _build/html prefix if present
        parts = filepath.parts
        try:
            idx = parts.index('html')
            rel_parts = parts[idx+1:]
        except ValueError:
            rel_parts = parts
        
        # Construct URL
        if rel_parts:
            url = '/'.join(rel_parts)
        else:
            url = f"{stem}.html"
        
        return url.replace(f"{stem}.html", stem).rstrip('/')
    
    @staticmethod
    def _slugify(text: str) -> str:
        """Convert text to URL-friendly slug.
        
        Args:
            text: Text to slugify
            
        Returns:
            Slugified text
        """
        text = text.lower().strip()
        text = re.sub(r'[^\w\s-]', '', text)
        text = re.sub(r'[-\s]+', '-', text)
        return text.strip('-')


class BatchHTMLIndexer:
    """Batch process Sphinx HTML output directory."""
    
    def __init__(self, html_dir: Path):
        """Initialize HTML indexer.
        
        Args:
            html_dir: Path to Sphinx HTML build directory (_build/html)
        """
        self.html_dir = Path(html_dir)
        if not self.html_dir.exists():
            raise ValueError(f"HTML directory does not exist: {html_dir}")
    
    def get_html_files(self, exclude_patterns: Optional[List[str]] = None) -> List[Path]:
        """Get all HTML files to index.
        
        Args:
            exclude_patterns: File patterns to exclude
            
        Returns:
            List of HTML file paths
        """
        if exclude_patterns is None:
            exclude_patterns = SphinxHTMLParser.EXCLUDE_PATTERNS
        
        html_files = []
        for html_file in self.html_dir.rglob('*.html'):
            # Skip excluded files
            if any(pattern in html_file.name for pattern in exclude_patterns):
                continue
            
            # Skip index files that aren't main pages
            if html_file.name == 'index.html' and html_file.parent != self.html_dir:
                continue
            
            html_files.append(html_file)
        
        return sorted(html_files)
    
    def parse_all(
        self,
        exclude_patterns: Optional[List[str]] = None,
        max_heading_level: int = 3
    ) -> Generator[tuple[Path, List[Document]], None, None]:
        """Parse all HTML files in directory.
        
        Args:
            exclude_patterns: Patterns to exclude
            max_heading_level: Maximum heading level to extract
            
        Yields:
            Tuples of (filepath, documents) for each HTML file
        """
        files = self.get_html_files(exclude_patterns)
        logger.info(f"Found {len(files)} HTML files in {self.html_dir}")
        
        for filepath in files:
            try:
                documents = SphinxHTMLParser.parse_html_file(
                    filepath,
                    max_heading_level=max_heading_level
                )
                if documents:
                    yield filepath, documents
                    logger.info(
                        f"Parsed {filepath.relative_to(self.html_dir)}: "
                        f"{len(documents)} documents"
                    )
            except Exception as e:
                logger.error(f"Error parsing {filepath}: {e}")
                continue
    
    def get_total_documents(self, exclude_patterns: Optional[List[str]] = None) -> int:
        """Count total documents from all HTML files.
        
        Args:
            exclude_patterns: Patterns to exclude
            
        Returns:
            Total number of documents
        """
        total = 0
        for _, documents in self.parse_all(exclude_patterns):
            total += len(documents)
        return total
