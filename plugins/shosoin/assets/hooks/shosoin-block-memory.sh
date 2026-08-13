#!/bin/sh
# shosoin: deny any tool call that touches Claude's private auto-memory.
# Knowledge written where no teammate can read it is hidden, not remembered;
# it belongs on the project's shelves instead.
#
# Registered as a PreToolUse hook for Write|Edit|NotebookEdit|Bash in
# .claude/settings.json. Reads the tool-call JSON from stdin, extracts the
# fields that can carry a path, and blocks when they reference the
# auto-memory directory (~/.claude/projects/<slug>/memory/).

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  targets=$(printf '%s' "$input" | jq -r '
    .tool_input
    | [.file_path, .notebook_path, .command]
    | map(select(. != null))
    | join("\n")' 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
  targets=$(printf '%s' "$input" | python3 -c '
import json, sys
ti = json.load(sys.stdin).get("tool_input", {})
print("\n".join(str(ti.get(k, "")) for k in ("file_path", "notebook_path", "command")))
' 2>/dev/null)
else
  # Coarse fallback: match against the whole payload. Rarely reached; may
  # over-block a command that merely mentions the path, which is recoverable.
  targets=$input
fi

case "$targets" in
  *".claude/projects/"*"memory"*)
    echo "Auto memory is disabled in this project. Do not read or write ~/.claude/projects/*/memory/. Put the knowledge on the project's shelves instead: notes/ for task-scoped findings, docs/ for current state, adr/ for decisions." >&2
    exit 2
    ;;
esac

exit 0
