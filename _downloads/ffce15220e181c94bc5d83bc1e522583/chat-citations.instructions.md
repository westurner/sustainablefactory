---
description: 'Use when producing chat-derived evidence summaries, reports, or docs. Enforce file+line citations and provide optional BibTeX and schema.org metadata for research workflows including Jupyter Book.'
---

# Chat Evidence Citation Instruction

When presenting claims derived from chat logs, use traceable citations and optionally emit machine-readable metadata.

## Required Citation Minimum
- Each substantive claim must include at least one source file and line reference.
- If confidence is uncertain, mark it explicitly.
- Do not cite a source that was not directly searched.

## In-Document Citation Linking (HTML Anchors)
When presenting a research brief or synthesis with scholarly references:
- Create a `### Scholarly References` section.
- Precede each reference entry with an HTML anchor tag using a standardized ID (e.g., `<a id="author2026"></a> Author, A. (2026)...`).
- In the text or Evidence Table, link to these references using standard Markdown anchor links (e.g., `[Author 2026](#author2026)`).

## BibTeX Support (Jupyter Book / sphinxcontrib-bibtex)
When requested, provide a BibTeX entry for each cited chat artifact.

Preferred entry type:
- Use `@misc` for chat logs unless a stricter publication type is known.

Recommended fields:
- `author` (person or organization; use `{{unknown}}` if unavailable)
- `title` (chat title)
- `year` (or best available year)
- `howpublished` (e.g., "AI chat log")
- `note` (file path and line range used)
- `url` (if a stable URL exists)

Example:
```bibtex
@misc{chat_algae_nitrogen,
  author       = {Unknown},
  title        = {Algae: A Natural Nitrogen Fertilizer},
  year         = {2026},
  howpublished = {AI chat log},
  note         = {Source: data/chats/_Algae_ A Natural Nitrogen Fertilizer  .md, lines 12-28}
}
```

## schema.org Support
When requested, emit JSON-LD using schema.org.

Type guidance:
- Represent a chat log as `schema:Conversation` (a `schema:CreativeWork` subclass).
- Represent a scholarly synthesis/report as `schema:ScholarlyArticle`.

Minimal JSON-LD for chat log:
```json
{
  "@context": "https://schema.org",
  "@type": "Conversation",
  "name": "Algae: A Natural Nitrogen Fertilizer",
  "isBasedOn": "data/chats/_Algae_ A Natural Nitrogen Fertilizer  .md",
  "about": ["nitrogen fertilizer", "algae"],
  "dateModified": "2026-04-02"
}
```

Minimal JSON-LD for synthesis:
```json
{
  "@context": "https://schema.org",
  "@type": "ScholarlyArticle",
  "headline": "Findings from AI Chat Corpus on Sustainable Factory Topics",
  "isBasedOn": [
    "data/chats/_Algae_ A Natural Nitrogen Fertilizer  .md"
  ],
  "dateModified": "2026-04-02"
}
```

## Output Behavior
- If user asks for both human summary and metadata, provide:
1. Human-readable findings with citations
2. BibTeX block
3. JSON-LD block
- Keep metadata consistent with cited files and lines.
