---
description: Scout Claude Code's latest release notes and translate each new feature into a concrete suggestion for your own setup.
allowed-tools: WebFetch, Read, Write, Glob
---

# New Toys Scout

Claude Code ships new features quickly. Reading the release notes is one thing;
knowing *where each new feature lands in your own workflow* is another. This
command scouts the latest changes and reports each new feature with a suggestion
tailored to how the user actually works — their settings and their installed
plugins — then remembers what has been seen so it only ever reports the unread.

## 1. Fetch the release notes

Fetch the Claude Code CHANGELOG:

- Primary source: `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`
- If that fails, fall back to the rendered file at
  `https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md`

The CHANGELOG is organized as `## <version>` sections, newest at the top, each
listing that release's changes as bullets. Parse out the version headings and
their entries. If the fetch fails entirely, say so plainly and stop — do not
invent features from memory. The whole point is to report what actually shipped.

## 2. Determine what is unread

Read `~/.claude/new-toys/last-seen.json` if it exists. Its shape:

```json
{ "last_version": "1.2.3", "seen_at": "2026-07-04T09:00:00Z" }
```

Everything in the CHANGELOG newer than `last_version` is unread. Compare by the
order versions appear in the CHANGELOG (newest first), not by parsing semver by
hand — the file's own ordering is the source of truth.

If `last-seen.json` does not exist, this is a first run. Do not dump the entire
history — that buries the signal. Report the most recent one or two versions'
worth of features as the unread set, and note that this was a first run so the
baseline is now set.

If there is nothing newer than `last_version`, report exactly one line —
"新しいおもちゃはありません" (no new toys) — and skip to step 4 to refresh the
timestamp. Do not manufacture something to say.

## 3. Translate each new feature into a suggestion for this user

For each unread feature, do not just restate the CHANGELOG line. Read the user's
own context and say where the feature applies to *them*:

- Read `~/.claude/settings.json` (read-only) for their hooks, permissions,
  env, model, and status line configuration.
- Look at their installed plugins. Check `~/.claude/plugins/` and, if present,
  any `.claude/settings.json` in the current project, to see what plugins and
  components are already in play.

Then, per feature, write:

- **What it is** — one line, in the user's own terms, not marketing copy.
- **あなたへの適用案 (how it applies to you)** — the concrete hook it could
  replace, the permission it could tighten, the plugin it pairs with, or the
  workflow it unblocks. If a feature genuinely does not fit this user's setup,
  say so briefly rather than inventing a use — an honest "this one is not for
  you" keeps the rest of the report trustworthy.

Read only. Do not modify `settings.json`, hooks, or any plugin. This command
reports and suggests; acting on a suggestion is the user's move.

## 4. Update the baseline

After reporting (including the "no new toys" case), write
`~/.claude/new-toys/last-seen.json` with the newest version seen and the current
timestamp. Create the `~/.claude/new-toys/` directory if needed. This is the one
thing the command writes, and it is what makes the next run report only the
newly-unread.

Do not update the baseline if the fetch in step 1 failed — leaving it unchanged
means the next run retries the same range rather than silently skipping features
that were never actually read.

## Constraints

- Read-only against the user's configuration. The sole write is
  `~/.claude/new-toys/last-seen.json`.
- Never invent features. If the source cannot be fetched, report that and stop.
- On a first run, set the baseline from recent history rather than replaying the
  entire CHANGELOG.
- Suggestions are proposals. Do not edit settings, hooks, or plugins to act on
  them.
