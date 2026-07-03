#!/usr/bin/env bash
# dogfood-lab liveness logger.
#
# Two hooks share this one script, distinguished by $1:
#   prompt  -> UserPromptSubmit. Records ONLY slash-command use: if the prompt
#              begins with "/", the command token is logged. Anything else is
#              ignored, because plain prompts say nothing about which of your
#              own plugins fired.
#   skill   -> PreToolUse(Skill). Records the skill that is about to run.
#
# The discipline this script lives by: it runs on every prompt and every skill
# call, so it must be nearly free. One jq read, at most one appended line, then
# exit. It never blocks, never prints to the conversation, and never fails the
# tool call — a logger that breaks the thing it observes is worse than no
# logger. All errors are swallowed and the script exits 0 regardless.

set -u

kind="${1:-}"

# Read stdin once. Empty or unreadable input is not worth a single cycle more.
input="$(cat 2>/dev/null || true)"
[ -n "$input" ] || exit 0

# One jq call extracts everything we need: the field for this hook, plus the
# session id and cwd for the record. Fields absent in this event come back
# empty. jq failing (malformed input) must not fail the hook.
read -r name session cwd < <(
  printf '%s' "$input" | jq -r --arg kind "$kind" '
    def field:
      if $kind == "skill" then
        (.tool_input.skill // .tool_input.name // .tool_input.skill_name // "")
      else
        (.prompt // "")
      end;
    [ (field | gsub("\t";" ") | gsub("\n";" ")),
      (.session_id // ""),
      (.cwd // "") ]
    | @tsv
  ' 2>/dev/null
) || exit 0

case "$kind" in
  prompt)
    # Only slash-command use is liveness signal. Bare prompts are dropped.
    case "$name" in
      /*) : ;;
      *) exit 0 ;;
    esac
    # Keep just the command token: "/foo:bar rest of prompt" -> "/foo:bar".
    name="${name%%[[:space:]]*}"
    event="command"
    ;;
  skill)
    [ -n "$name" ] || exit 0
    event="skill"
    ;;
  *)
    exit 0
    ;;
esac

# Derive a short, stable project label from the cwd basename. This is only a
# hint for the report; it is not used for correctness.
project=""
[ -n "$cwd" ] && project="$(basename "$cwd" 2>/dev/null || true)"

# Machine-scoped store. The report reads and rotates this same file.
store_dir="${HOME:-/tmp}/.claude/dogfood-lab"
mkdir -p "$store_dir" 2>/dev/null || exit 0

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || true)"

# One compact JSONL line, built by jq so the strings are escaped correctly.
line="$(
  jq -cn \
    --arg ts "$ts" \
    --arg event "$event" \
    --arg name "$name" \
    --arg project "$project" \
    '{ts:$ts, event:$event, name:$name, project:$project}' 2>/dev/null
)" || exit 0

[ -n "$line" ] || exit 0
printf '%s\n' "$line" >> "$store_dir/events.jsonl" 2>/dev/null || true

exit 0
