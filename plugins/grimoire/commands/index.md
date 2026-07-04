---
description: List every spell in the grimoire — the bundled collection and your personal additions — with what each is for.
argument-hint: ""
allowed-tools: Read, Glob, Grep
---

# Grimoire Index

Show the user the full catalogue of spells available to cast, from both the bundled collection and their personal grimoire.

## Gather from both books

Read the spell files from two locations:

- `${CLAUDE_PLUGIN_ROOT}/skills/spellcraft/references/spells/*.md` — the bundled spells shipped with the plugin.
- `~/.claude/grimoire/*.md` — the user's personal spells. If the directory does not exist, there simply are none yet; do not treat its absence as an error.

For each spell, read its title and its "when to use" section — do not print the full script here; the index is a table of contents, not the book itself.

## Present the catalogue

List the spells grouped by origin, bundled first, then personal. For each, show its name, a one-line statement of what it is for, and the shape of its `args`. Where a personal spell shares a name with a bundled one, note that the personal version is the one `/grimoire:cast` will use.

Close by telling the user how to act on the list: `/grimoire:cast <name> <target>` to cast, `/grimoire:inscribe` to add one of their own. Keep the whole thing to one screen if the collection allows; a catalogue that scrolls off the top has stopped being a catalogue.
