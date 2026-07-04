# The Embassy State File

`/embassy:diff` can only tell which foreign versions have fallen behind the source if `/embassy:draft` left a record of what the source looked like when each was translated. That record is `~/.claude/embassy/state.json`. This file defines its shape and the rules that keep the two commands in agreement, so that a hash written by draft is the same hash diff recomputes.

## Location

`~/.claude/embassy/state.json` — machine-scoped, under the user's Claude home, because a person's institution and its translations are theirs across all projects, not per-repository. Create the `~/.claude/embassy/` directory if it does not exist.

## Shape

A single JSON object whose top-level key is `translations`, an array of entries — one per (source, target) pair:

```json
{
  "translations": [
    {
      "source": "/absolute/path/to/CLAUDE.md",
      "target": "chatgpt",
      "output": "/absolute/path/to/embassy/chatgpt.md",
      "source_hash": "sha256:9f2b...c1",
      "translated_at": "2026-07-04T12:00:00Z"
    }
  ]
}
```

- `source` — absolute path to the institutional document that was translated.
- `target` — the target service identifier, matching the names in `targets.md` (`chatgpt`, `gemini`, `system-prompt`, ...).
- `output` — absolute path to the file the draft was written to.
- `source_hash` — the hash of the source content as translated (see below).
- `translated_at` — ISO 8601 timestamp of when the draft was made, for the user's reference.

The identity of an entry is the (`source`, `target`) pair. Re-drafting the same source for the same target updates that entry in place; it does not append a second one.

## The hash: what and how

`source_hash` is a SHA-256 of the exact bytes of the source file as read at translation time, prefixed with `sha256:`. Compute it with whatever is available and portable:

```
shasum -a 256 "$source"   # macOS and most Linux
sha256sum "$source"       # GNU coreutils
```

Take the hex digest, prefix it with `sha256:`, and store that. Both `/embassy:draft` (when recording) and `/embassy:diff` (when comparing) hash the *whole source file as it currently exists on disk* — not the translated output, not a normalized form. Hashing the raw source is what makes "has the source changed since we translated it" a reliable question. If draft ever hashed a normalized or trimmed version, diff would have to reproduce that normalization exactly or every comparison would falsely read as stale; hashing raw bytes keeps the two commands trivially in agreement.

## Updating without clobbering

The state holds every target's record together, so an update must be surgical. When `/embassy:draft` records a translation:

1. Read the existing `state.json` if present; start from `{"translations": []}` if not.
2. Find the entry whose `source` and `target` both match the one just drafted.
3. If found, update its `source_hash`, `output`, and `translated_at` in place. If not, append a new entry.
4. Write the whole object back.

Never rewrite the file from only the current translation — that would erase every other target's record and make `/embassy:diff` blind to them. The read-modify-write over the full array is what preserves the other embassies' state.

## When an entry's source has moved

If `/embassy:diff` finds an entry whose `source` path no longer exists, it does not silently drop the entry. It flags it: the record points at a file that moved or was deleted, and the user decides whether to re-point the entry at the new location or prune it. The state is the user's record of their embassies; pruning it is their call, not the tool's.
