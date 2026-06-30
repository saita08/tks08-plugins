# Renaming a Plugin

Renaming a plugin touches more than its directory. The name is embedded in the
marketplace index, the plugin manifest, the command filename, the skill
namespace, and any cross-reference another plugin makes to it. Miss one and the
plugin breaks for users in a way that does not surface until they invoke it.
This document lists what moves together and how to carry users' settings forward.

## What moves together

For a plugin renamed from `<old>` to `<new>`:

- `plugins/<old>/` → `plugins/<new>/` (use `git mv` so history follows)
- `commands/<old>.md` → `commands/<new>.md` (the filename is the command name `/<new>`)
- `marketplace.json`: the entry's `name` and `source` (`source` must equal the directory name exactly, or marketplace resolution fails for every plugin, not just this one)
- `plugin.json`: `name`
- Any `<old>:<skill>` skill-namespace reference inside the plugin's own command or skill files (the namespace is the plugin name)
- Every `/<old>` mention in the plugin's README and reference docs
- Cross-references from other plugins (another plugin's README or command that names `<old>` or `/<old>`)

The skill directory and skill name do not change unless you are renaming the
skill itself — only the plugin-name half of `<plugin>:<skill>` moves.

Do not rewrite `notes/` or existing `CHANGELOG.md` entries. Those record past
events; rewriting them to the new name falsifies the history.

## Carrying user settings forward with `renames`

`marketplace.json` has a top-level `renames` map. When a plugin is not found
under its old name, the loader follows this map and migrates the user's
`enabledPlugins` key to the new name. Without it, every user who had the plugin
enabled must re-enable it by hand.

```json
{
  "plugins": [ { "name": "new-name", "source": "./plugins/new-name" } ],
  "renames": {
    "old-name": "new-name"
  }
}
```

- The map is flat: each key is an old name, each value is the current name (a string), or `null` when the plugin was removed rather than renamed.
- It is append-only. Keep old entries when you rename again — the loader follows chains (`a` → `b` → `c`), so a plugin renamed twice still resolves from its oldest name.
- Every non-null value must be the `name` of a plugin currently in `plugins[]`. A value that points nowhere is a validation error.

### When the migration fires

The migration runs during plugin resolution, not when the marketplace is
updated. After a user runs `/plugin marketplace update`, the key in
`~/.claude/settings.json` still reads the old name; it switches to the new name
the next time Claude Code starts and resolves plugins. This is expected — the
setting carries forward on its own, just one launch later.

## Version and changelog

A rename changes the command a user types, which breaks any hardcoded reference
they wrote. That is a breaking change: bump the plugin's `plugin.json` to the
next MAJOR (see `docs/versioning.md`). The `renames` map migrates the
enabled-plugins setting, but it does not fix a script or doc that calls the old
command name.

Record the rename in `CHANGELOG.md` under `[Unreleased]` as a user-facing
change, naming both the old and new command so a reader recognizes which plugin
moved. Per the repository's changelog discipline, each plugin a user notices
separately earns its own line.

## Checklist before opening the PR

- `marketplace.json`: each `source` equals its directory name equals the `plugin.json` `name`
- Every `renames` value resolves to a name in `plugins[]`
- No old name remains under `plugins/` (`grep -rn '<old>' plugins/` is empty)
- `claude plugin validate .` and `claude plugin validate plugins/<new>` pass
- All `plugin.json` and `marketplace.json` parse as valid JSON
