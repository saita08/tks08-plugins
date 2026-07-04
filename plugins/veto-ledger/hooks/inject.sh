#!/bin/sh
# veto-ledger injection hook.
#
# Runs on SessionStart. If the project has a ledger of rejected directions at
# .claude/veto-ledger.local.md, it injects them into the session as
# additionalContext, so this session knows what was already declined and does
# not re-propose it in a new form. When the ledger is absent or empty, it stays
# completely silent: no ledger, no output, exit 0. Many plugins hook
# SessionStart at once; a plugin with nothing to say must say nothing.
#
# Output contract (verified against the harness): SessionStart injects context
# by printing a JSON object with hookSpecificOutput.additionalContext to stdout
# and exiting 0.

set -eu

# --- Locate the ledger -----------------------------------------------------
project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
ledger="$project_dir/.claude/veto-ledger.local.md"

# No ledger -> nothing to inject. This is the common case; stay silent.
[ -f "$ledger" ] || exit 0

# jq carries the payload safely into JSON. Without it, degrade to silence
# rather than risk a malformed injection.
command -v jq >/dev/null 2>&1 || exit 0

# --- How many entries to inject --------------------------------------------
# A ledger that grows without bound would swell every session's context. Cap
# the injection at the most recent N rejections; the newest are appended at the
# bottom, so the tail is what we keep. Overridable via VETO_LEDGER_MAX_ENTRIES.
max_entries="${VETO_LEDGER_MAX_ENTRIES:-30}"
case "$max_entries" in
  ''|*[!0-9]*) max_entries=30 ;;
esac

# --- Pull the data rows out of the Markdown table --------------------------
rows="$(
  awk '
    /^\| *[Rr]ejected/ { next }        # header row
    /^\| *-+ *\|/       { next }        # separator row
    /^\|/               { print }       # data rows
  ' "$ledger"
)"

# No data rows -> the ledger exists but is empty. Stay silent.
[ -n "$rows" ] || exit 0

kept="$(printf '%s\n' "$rows" | tail -n "$max_entries")"

total="$(printf '%s\n' "$rows" | grep -c '^|' || true)"
shown="$(printf '%s\n' "$kept" | grep -c '^|' || true)"

note="This project keeps a ledger of directions the user has already rejected, each with the principle behind the rejection (in .claude/veto-ledger.local.md). Do not re-propose these directions, and do not reintroduce a rejected idea in a different form; the principle column tells you what class of proposal to avoid, not just the one instance. If the current work genuinely requires revisiting one of these, name the past rejection explicitly and ask, rather than quietly proposing it again."
if [ "$total" -gt "$shown" ]; then
  note="$note (Showing the $shown most recent of $total entries.)"
fi

context="$note

| Rejected direction | Principle behind the rejection | Date |
| --- | --- | --- |
$kept"

jq -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'

exit 0
