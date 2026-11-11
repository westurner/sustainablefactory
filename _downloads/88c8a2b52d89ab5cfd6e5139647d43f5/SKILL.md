---
name: search-chats-sources
description: 'Search chat exports in data/chats/*.md and data/chats/*.json with deduplication. Use for corpus-wide evidence retrieval while skipping duplicate md/json pairs.'
argument-hint: 'What should I search across chat sources? (keyword, phrase, or regex)'
user-invocable: true
disable-model-invocation: false
---

# Search Chats Sources

Searches both markdown and JSON chat exports while avoiding duplicate reporting when the same chat exists in both formats.

## When To Use
- You want maximum coverage across `data/chats/*.md` and `data/chats/*.json`.
- You need one deduplicated evidence set for analysis.
- You need path+line traceability for citations.

## Inputs
- Query text or explicit mode prefix: `phrase:` or `regex:`
- Optional source preference: `prefer:md` or `prefer:json` (default: `prefer:md`)
- Optional constraints: filename hint, topic terms, max matches

## Procedure
1. Discover candidate files in both sets:
- `data/chats/*.md`
- `data/chats/*.json`

2. Build duplicate groups by basename (filename without extension).
- Use [dedupe_chat_sources.py](./scripts/dedupe_chat_sources.py) to generate the retained file list.

3. Deduplicate before searching:
- If both `.md` and `.json` exist for the same basename, keep only one according to preference.
- Default preference is `.md`.
- If only one exists, keep that file.
- Example: `python .agents/skills/search-chats-sources/scripts/dedupe_chat_sources.py --prefer md --format json`

4. Choose query mode:
- `regex:` prefix => regex search
- `phrase:` prefix => exact phrase search
- otherwise infer mode automatically

5. Run scoped search on deduplicated file set:
- Use fast search first and tighten only if noisy.
- Capture file path, line number, and short snippet.

6. Return structured results:
- Counts by retained source type (`md` vs `json`) and by file
- Top matches with citations
- Note whether any duplicates were skipped and which preference was applied

## Decision Points
- Coverage priority: search both formats or one preferred format
- Duplicate resolution: `prefer:md` (default) or `prefer:json`
- Precision mode: regex, phrase, or inferred literal

## Quality Checks
- Duplicate pairs are never reported twice.
- Output states deduplication rule used.
- Every result includes file and line.
- No out-of-scope files are searched.

## Example Prompts
- `/search-chats-sources electrolysis efficiency`
- `/search-chats-sources phrase:natural nitrogen fertilizer prefer:json`
- `/search-chats-sources regex:(induction\s+welding|rail)`

## Resources
- [dedupe_chat_sources.py](./scripts/dedupe_chat_sources.py): builds the deduplicated `.md`/`.json` source set before search.
