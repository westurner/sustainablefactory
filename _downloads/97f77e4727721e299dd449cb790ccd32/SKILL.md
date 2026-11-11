---
name: search-chats
description: 'Search chat markdown files in data/chats/*.md using fast, reproducible steps. Use for finding topics, exact phrases, regex patterns, and source snippets with file and line citations.'
argument-hint: 'What should I search for in data/chats/*.md? (keywords, phrase, or regex)'
user-invocable: true
disable-model-invocation: false
---

# Search Chats

Searches markdown chat files in `data/chats/*.md` and returns precise, reviewable results.

## When To Use
- Find where a topic appears across chat exports.
- Locate exact wording for quotes or references.
- Build a focused set of source files before deeper analysis.
- Validate whether a claim appears in chat records.

## Inputs
- Search intent: `keyword`, `exact phrase`, or `regex pattern`
- Optional mode prefixes: `regex:` and `phrase:` (preferred when the user provides them)
- Optional filters: date terms, process terms, chemistry terms, filename hints
- Optional result limit: maximum files or matches

## Procedure
1. Normalize the request into one search mode:
- If the query starts with `regex:` use regex mode.
- If the query starts with `phrase:` use exact phrase mode.
- Otherwise infer best mode automatically from the query text.
- Literal keyword search for broad discovery.
- Exact phrase search when wording matters.
- Regex search for pattern variants.

2. Confirm the target corpus exists:
- Path: `data/chats/*.md`
- If no files match, report that clearly and stop.

3. Run fast scoped search first:
- Preferred: `rg --line-number --glob 'data/chats/*.md' '<pattern>'`
- Use `-F` for exact literal, `-i` for case-insensitive, and `-P` only when advanced regex is required.

4. Branch based on result volume:
- If too many hits: tighten query with quoted phrase, additional terms, or filename filters.
- If zero hits: retry with relaxed casing, singular/plural variants, and common synonyms.
- If results are still noisy: constrain with `--max-count` or file globs.

5. Summarize with traceable evidence (default format):
- Start with counts by file and topic clusters.
- Then provide top matches, formatting file paths and line numbers as Copilot Chat-clickable markdown links: `[path/to/file.md](path/to/file.md#L10)`. Ensure space characters in URLs are correctly escaped using `%20` (e.g., `[path/My File.md](path/My%20File.md#L10)`).
- Include short snippets around each match.
- Group similar hits and remove near-duplicates.

6. Close with next-step options:
- Offer follow-up query refinements.
- Offer export of matching files or counts by topic.
- Offer to search for and extract scholarly citations (DOIs, academic journals, `et al.`) from the matched chats. If chosen, use these to update the research brief's evidence table and adjust confidence scores based on the academic support found. Ensure any extracted in-text scholarly citations link to a `### Scholarly References` section using Markdown anchor links (e.g., `[Author 2026](#author2026)`), which resolve to HTML anchors (`<a id="author2026"></a>`) defined in the references list.

## Decision Points
- Choose literal vs phrase vs regex based on precision needed.
- Choose case-sensitive vs insensitive based on domain terms.
- Choose broad scan first, then narrow, instead of over-constraining initially.

## Quality Checks
- Every reported claim has a file and line reference.
- Query mode is stated (literal, phrase, regex).
- Search scope is explicitly limited to `data/chats/*.md`.
- Empty-result cases include at least one fallback attempt.
- Final response includes either actionable results or a clear no-match report.

## Example Prompts
- `/search-chats carbothermic reduction in aluminum`
- `/search-chats "natural nitrogen fertilizer"`
- `/search-chats regex:(electrolytic|plasma)\s+aluminum`
- `/search-chats find references to induction welding and rail`
