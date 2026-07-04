#!/bin/sh
# lexicon injection hook.
#
# Runs on SessionStart. If the project has a glossary at
# .claude/lexicon.local.md, it injects the agreed terms into the session as
# additionalContext, so this session speaks the same language the last one
# settled on. When the glossary is absent or empty, it stays completely
# silent: no glossary, no output, exit 0. This matters because many plugins
# hook SessionStart at once; a plugin that has nothing to say must say nothing.
#
# Output contract (verified against the harness): SessionStart injects context
# by printing a JSON object with hookSpecificOutput.additionalContext to stdout
# and exiting 0. Plain stdout would also reach the model, but the JSON form is
# explicit and lets the payload be framed as agreed context rather than raw text.

set -eu

# --- Locate the glossary ---------------------------------------------------
# CLAUDE_PROJECT_DIR is the project root the session opened in. Fall back to
# the current directory if the harness did not export it.
project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
ledger="$project_dir/.claude/lexicon.local.md"

# No glossary -> nothing to inject. This is the common case; stay silent.
[ -f "$ledger" ] || exit 0

# jq carries the payload safely into JSON. Without it we cannot emit valid
# output, so degrade to silence rather than risk a malformed injection.
command -v jq >/dev/null 2>&1 || exit 0

# --- How many entries to inject --------------------------------------------
# A glossary that grows without bound would swell every session's context. Cap
# the injection at the most recent N terms. The newest entries are appended at
# the bottom, so the tail is what we keep. Overridable per project via the
# LEXICON_MAX_ENTRIES environment variable.
max_entries="${LEXICON_MAX_ENTRIES:-40}"
case "$max_entries" in
  ''|*[!0-9]*) max_entries=40 ;;
esac

# --- Pull the term rows out of the Markdown table --------------------------
# The glossary body is a Markdown table whose data rows begin with "| ". The
# header row and the "| --- |" separator are skipped. We keep only the tail so
# the freshest agreements win when the table is long.
rows="$(
  awk '
    /^\| *[Tt]erm *\|/ { next }        # header row
    /^\| *-+ *\|/       { next }        # separator row
    /^\|/               { print }       # data rows
  ' "$ledger"
)"

# No data rows -> the glossary exists but is empty. Stay silent.
[ -n "$rows" ] || exit 0

kept="$(printf '%s\n' "$rows" | tail -n "$max_entries")"

# Count what we are injecting and whether we truncated, so the note can be honest.
total="$(printf '%s\n' "$rows" | grep -c '^|' || true)"
shown="$(printf '%s\n' "$kept" | grep -c '^|' || true)"

note="This project keeps a glossary of terms you and the user have agreed on (in .claude/lexicon.local.md). Use these definitions when the user uses these words; if you are about to use one of these terms differently, prefer the agreed meaning. Do not restate the glossary to the user unprompted."
if [ "$total" -gt "$shown" ]; then
  note="$note (Showing the $shown most recent of $total entries.)"
fi

context="$note

| Term | Meaning | Agreed in the context of |
| --- | --- | --- |
$kept"

jq -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'

exit 0
