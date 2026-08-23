#!/bin/sh
# shosoin: deny any tool call that would write an emoji into a file.
# An emoji is a decoration standing where a thought should be, and it reads
# as generated rather than authored; nothing the project produces carries one.
#
# Registered as a PreToolUse hook for Write|Edit|NotebookEdit|Bash in
# .claude/settings.json. Reads the tool-call JSON from stdin, extracts the
# fields that can carry text bound for a file, and blocks when they contain
# an emoji. Bash is inspected because echo and heredocs write files too.
# Escaped forms and data piped through from elsewhere are not inspected.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  text=$(printf '%s' "$input" | jq -r '
    .tool_input
    | [.content, .new_string, .new_source, .command]
    | map(select(. != null))
    | join("\n")' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  text=$(printf '%s' "$input" | python3 -c '
import json, sys
ti = json.load(sys.stdin).get("tool_input", {})
print("\n".join(str(ti.get(k, "")) for k in ("content", "new_string", "new_source", "command")))
' 2>/dev/null)
else
  text=$input
fi

if [ -z "$text" ]; then
  exit 0
fi

found=$(printf '%s' "$text" | perl -CSD -ne '
  while (/(\p{Emoji_Presentation}|\x{FE0F}|\x{200D})/g) { printf "U+%04X ", ord($1); }
' 2>/dev/null | head -c 200)

if [ -n "$found" ]; then
  echo "Emoji are not written to any file in this project; the input contained $found. Rewrite it in plain text." >&2
  exit 2
fi

exit 0
