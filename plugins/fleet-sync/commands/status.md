---
description: Compare the origin's shared files against every fleet destination and report drift as a repo × file matrix, distinguishing local edits worth re-importing from stale copies.
argument-hint: "[配布先リポジトリ名で絞り込み（省略可）]"
allowed-tools: Read, Glob, Bash
---

# Fleet Sync Status

Report where the fleet has drifted from the origin, without changing anything. This command reads; it does not write. `/fleet-sync:push` is the command that writes.

Read `${CLAUDE_PLUGIN_ROOT}/skills/distribution-layers/references/drift-model.md` before interpreting diffs — the distinction between an out-of-date copy and a re-import candidate is the whole point of this report, and getting it wrong is how a destination's deliberate local edit gets silently flagged for overwrite.

## 1. Load the manifest

The origin repository declares what it distributes and where, in `.claude/fleet-sync.local.md` at the origin's root. Read it. Its YAML frontmatter carries two lists:

- `files` — paths, relative to the origin root, of the shared artifacts being distributed (a common `CLAUDE.md` section file, a `settings.json` fragment, a hook script, a coding-convention doc).
- `destinations` — absolute paths (or `~`-relative paths) to the root of each project in the fleet.

If the manifest is missing, say so plainly and stop. Point the user at the README's setup section rather than inventing a manifest for them; what the fleet contains is the user's declaration, not something to guess. If `$ARGUMENTS` names a destination, restrict the report to that one.

## 2. Diff each file against each destination

For every declared file, and every destination, compare the origin's copy against the destination's copy at the same relative path. Use `diff` so the comparison is exact rather than impressionistic. Three outcomes matter, and `drift-model.md` defines them:

- **In sync** — identical. Nothing to do.
- **Stale** — the destination differs, and the origin is the newer intent. This is a push candidate.
- **Missing** — the destination has no copy at that path yet. Also a push candidate (a first delivery).
- **Re-import candidate** — the destination differs *and there is evidence the destination's version is a deliberate local change*, not merely an old copy. `drift-model.md` describes how to tell these apart; when you genuinely cannot, treat it as a re-import candidate, because the failure that matters is overwriting a real local edit, not leaving a stale copy one cycle longer.

## 3. Report as a matrix

Present a compact table: destinations down the side, distributed files across the top, each cell carrying its state. Below the matrix, call out by name every re-import candidate — these are the ones `/fleet-sync:push` will refuse to touch, and the user needs to see them to decide whether to fold the local change back into the origin.

Lead the summary with the single number that matters: how many files are out of sync across the fleet, and how many of those are re-import candidates the user must judge rather than push.

## Constraints

- Never modify any file. This command's entire output is a report.
- Never treat a diff as stale when you cannot rule out a deliberate local edit. The asymmetry is deliberate: a stale copy left one more cycle is recoverable; a clobbered local edit may not be.
- Do not assume the destinations are git repositories or that they are clean. Read them as directories on disk.
