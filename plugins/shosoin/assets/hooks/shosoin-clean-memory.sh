#!/bin/sh
# shosoin: delete Claude's private auto-memory for this project.
# Runs on SessionStart so that anything written before the shut-off was
# installed — or slipped past it — is gone by the next session.
#
# The auto-memory directory lives at ~/.claude/projects/<slug>/memory/,
# where <slug> is the project path with every non-alphanumeric character
# replaced by "-". That derivation is an internal Claude Code convention,
# not a documented contract: if it changes, this script deletes nothing
# and fails quiet. Deletion is structurally confined to
# ~/.claude/projects/*/memory, so a wrong slug can only miss, never stray.

root="${CLAUDE_PROJECT_DIR:-$PWD}"

# Worktrees share the main repository's memory directory, so resolve the
# main checkout before deriving the slug.
common=$(git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
case "$common" in
  */.git) root="${common%/.git}" ;;
esac

slug=$(printf '%s' "$root" | sed 's/[^a-zA-Z0-9]/-/g')
dir="$HOME/.claude/projects/$slug/memory"

if [ -n "$slug" ] && [ -d "$dir" ]; then
  rm -rf "$dir"
fi

exit 0
