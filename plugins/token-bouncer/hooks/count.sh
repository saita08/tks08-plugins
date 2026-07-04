#!/usr/bin/env bash
# token-bouncer waste watcher.
#
# One script, two hooks, distinguished by $1:
#   agent -> PreToolUse(Agent|Task). Counts spawns this session. Past a
#            threshold it warns, on the first crossing and on every spawn
#            beyond it, that a lot of subagents are running.
#   read  -> PreToolUse(Read). Counts how many times THIS file has been read
#            this session. On the Nth read of the same path it warns that the
#            file is being re-read.
#
# It never blocks. It emits, at most, a hookSpecificOutput.additionalContext
# advisory with NO permissionDecision, so the tool always proceeds exactly as
# requested. This is the honest posture: the harness does not hand hooks a
# token count, so this cannot measure tokens. It measures behavior that
# correlates with burning them, and nudges — it does not police.
#
# The discipline: this runs on every Read and every spawn, so it must be near
# free. One jq read of stdin, one counter file touched, one threshold compare,
# then exit. All errors are swallowed; a broken watcher must never break the
# tool it watches.

set -u

kind="${1:-}"

input="$(cat 2>/dev/null || true)"
[ -n "$input" ] || exit 0

# One jq call pulls the session id, cwd, and (for reads) the file path.
read -r session cwd path < <(
  printf '%s' "$input" | jq -r '
    [ (.session_id // "nosession"),
      (.cwd // ""),
      (.tool_input.file_path // "") ]
    | @tsv
  ' 2>/dev/null
) || exit 0
[ -n "$session" ] || session="nosession"

# --- Resolve thresholds ----------------------------------------------------
# Defaults, overridable per project via .claude/token-bouncer.local.md whose
# YAML frontmatter may set agent_threshold and/or read_threshold. Reading the
# file is cheap (a small sed/awk over frontmatter); if it is absent or
# unreadable the defaults stand.
agent_threshold=5
read_threshold=3
cfg=""
[ -n "$cwd" ] && cfg="$cwd/.claude/token-bouncer.local.md"
if [ -n "$cfg" ] && [ -f "$cfg" ]; then
  # Read only the frontmatter block (between the first two --- lines) and pull
  # the two keys. Pure awk, no dependency beyond what is already required.
  vals="$(
    awk '
      NR==1 && $0 ~ /^---[[:space:]]*$/ {infm=1; next}
      infm && $0 ~ /^---[[:space:]]*$/ {exit}
      infm {
        if ($0 ~ /^[[:space:]]*agent_threshold[[:space:]]*:/) {
          sub(/^[^:]*:[[:space:]]*/,""); gsub(/[^0-9]/,""); if ($0!="") print "a="$0
        }
        if ($0 ~ /^[[:space:]]*read_threshold[[:space:]]*:/) {
          sub(/^[^:]*:[[:space:]]*/,""); gsub(/[^0-9]/,""); if ($0!="") print "r="$0
        }
      }
    ' "$cfg" 2>/dev/null || true
  )"
  case "$vals" in *a=*) agent_threshold="$(printf '%s\n' "$vals" | sed -n 's/^a=//p' | head -1)";; esac
  case "$vals" in *r=*) read_threshold="$(printf '%s\n' "$vals" | sed -n 's/^r=//p' | head -1)";; esac
fi
[ "${agent_threshold:-0}" -ge 1 ] 2>/dev/null || agent_threshold=5
[ "${read_threshold:-0}" -ge 1 ] 2>/dev/null || read_threshold=3

# Per-session state directory.
state_dir="${HOME:-/tmp}/.claude/token-bouncer/$session"
mkdir -p "$state_dir" 2>/dev/null || exit 0

emit() {
  # Non-blocking advisory: additionalContext only, no permissionDecision.
  jq -cn --arg ctx "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: $ctx
    }
  }' 2>/dev/null || true
  exit 0
}

case "$kind" in
  agent)
    counter="$state_dir/agents"
    # Increment. Read-old, write-new; cheap and adequate for hook frequency.
    n=0
    [ -f "$counter" ] && n="$(cat "$counter" 2>/dev/null || echo 0)"
    case "$n" in ''|*[!0-9]*) n=0 ;; esac
    n=$((n + 1))
    printf '%s' "$n" > "$counter" 2>/dev/null || true

    # Warn on the crossing and on every spawn beyond it. The count is
    # incremented before the compare, so the warning first fires on the spawn
    # that reaches the threshold.
    if [ "$n" -ge "$agent_threshold" ]; then
      emit "token-bouncer: this session has already spawned ${n} subagents (threshold ${agent_threshold}). Each subagent is a full session that burns tokens independently. Confirm this spawn is genuinely needed rather than a reflex, and prefer reusing an existing agent via SendMessage over launching another. This is advisory only; proceed if it is warranted."
    fi
    exit 0
    ;;

  read)
    [ -n "$path" ] || exit 0
    log="$state_dir/reads"
    # Append this read, then count how many times this exact path appears.
    printf '%s\n' "$path" >> "$log" 2>/dev/null || true
    # grep -Fx: fixed-string, whole-line match, so paths do not partially
    # collide. -c counts matching lines.
    count="$(grep -Fxc -- "$path" "$log" 2>/dev/null || echo 0)"
    case "$count" in ''|*[!0-9]*) count=0 ;; esac

    if [ "$count" -ge "$read_threshold" ]; then
      base="$(basename "$path" 2>/dev/null || echo "$path")"
      emit "token-bouncer: ${base} has now been read ${count} times this session (threshold ${read_threshold}). Re-reading the same file re-spends its tokens each time. If you already have its contents, work from those; if you truly need a fresh read, proceed. This is advisory only."
    fi
    exit 0
    ;;

  *)
    exit 0
    ;;
esac
