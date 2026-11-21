---
name: chat-code-patches
description: "Use when extracting fenced code blocks from chat exports, reviewing unified-diff patch series, or applying/resuming chat-derived patches safely."
user-invocable: true
disable-model-invocation: false
---

# Chat Code Patches

Extract chat code fences into numbered files and a manifest, then review and
apply only explicit unified-diff blocks. The implementation is shared with
`src/transform_md`; the workspace wrapper is
`tools/extract_chat_code_blocks.py`.

## Extract

Run from the repository root:

```bash
python3 tools/extract_chat_code_blocks.py extract data/chats/example.md \
  --destdir .tmp/chat-code-blocks --verbosity verbose
```

The default manifest is `.tmp/chat-code-blocks/chatpatches.json`. Output
filenames are sequence-prefixed by default; `--no-sequence-prefix` uses source
line numbers instead. Existing same-source manifests are reused without
resetting their apply statuses. Use `--force` only to replace an extraction.

Review the manifest's source hash, source-line spans, fence labels, and files
before applying anything. Python, Rust, Lean, shell, and other snippet blocks
are never executed or guessed into target files by the apply command.

## Apply And Resume

Only `diff` and `patch` fenced blocks are candidates for `git apply`; each gets
`git apply --check --recount` first. The tool does not stage, commit, rebase,
run code, or apply arbitrary snippets.

```bash
python3 tools/extract_chat_code_blocks.py apply \
  --manifest .tmp/chat-code-blocks/chatpatches.json
```

For a stepwise review, use `-i` / `--interactive`. It pauses before each patch;
on a failed applicability check, repair the worktree and choose retry, skip, or
quit. Noninteractive failures are written to the manifest. After repairing the
worktree, resume with:

```bash
python3 tools/extract_chat_code_blocks.py apply \
  --manifest .tmp/chat-code-blocks/chatpatches.json --continue
```

After a rebase/reset, `--reapply` resets recorded applied states and checks each
patch against the current tree. Patches already present are detected in reverse
and skipped; remaining patches are checked and applied in sequence.

## Validation And Evidence

- Inspect the resulting diff after each series; successful patch application is
  not semantic validation.
- Run focused tests and `git diff --check` after applying patches.
- For chat-derived Signals models, use the
  [Signals evidence modeling skill](../signals-evidence-modeling/SKILL.md): keep
  unsupported physical, energy, benchmark, causality, or RH claims out of
  verified modules, and preserve source file plus line citations in docs.
- For searching the chat corpus, use the
  [search-chats skill](../search-chats/SKILL.md) and scope searches to the
  intended `data/chats/` sources.
