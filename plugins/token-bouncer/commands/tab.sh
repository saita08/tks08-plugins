#!/usr/bin/env bash
# token-bouncer tab (the bill).
#
# Tallies this session's watched behavior: how many subagents were spawned and
# which files were read more than once. The /token-bouncer:tab command runs
# this and presents the result.
#
# A slash command is not handed a session id, so this reads the most recently
# touched session directory under the store — in practice the current session,
# because its counters were just being written. Output is one JSON object.

set -u

store="${HOME:-/tmp}/.claude/token-bouncer"
if [ ! -d "$store" ]; then
  printf '%s\n' '{"session_dir":null,"agents":0,"repeated_reads":[]}'
  exit 0
fi

# Most recently modified session directory. If a session id is passed as $1,
# prefer it (lets the command target a specific session when it knows one).
sdir=""
if [ -n "${1:-}" ] && [ -d "$store/$1" ]; then
  sdir="$store/$1"
else
  # Portable "newest subdirectory": stat mtime, sort, take the last.
  sdir="$(
    for d in "$store"/*/; do
      [ -d "$d" ] || continue
      # macOS stat and GNU stat differ; try both, fall back to ls.
      m="$(stat -f %m "$d" 2>/dev/null || stat -c %Y "$d" 2>/dev/null || echo 0)"
      printf '%s\t%s\n' "$m" "$d"
    done | sort -n | tail -1 | cut -f2-
  )"
fi

if [ -z "$sdir" ] || [ ! -d "$sdir" ]; then
  printf '%s\n' '{"session_dir":null,"agents":0,"repeated_reads":[]}'
  exit 0
fi

# Agent spawn count.
agents=0
[ -f "$sdir/agents" ] && agents="$(cat "$sdir/agents" 2>/dev/null || echo 0)"
case "$agents" in ''|*[!0-9]*) agents=0 ;; esac

# Repeated reads: paths that appear more than once in the read log, with their
# counts, most-repeated first.
reads_json='[]'
if [ -f "$sdir/reads" ]; then
  reads_json="$(
    sort "$sdir/reads" 2>/dev/null | uniq -c 2>/dev/null \
      | awk '$1 > 1 { count=$1; $1=""; sub(/^ /,""); print count"\t"$0 }' \
      | sort -rn \
      | jq -R -s 'split("\n") | map(select(. != "")) | map(
          (split("\t")) | {path: .[1], count: (.[0] | tonumber)}
        )' 2>/dev/null || echo '[]'
  )"
fi
[ -n "$reads_json" ] || reads_json='[]'

jq -n \
  --arg sdir "$sdir" \
  --argjson agents "${agents:-0}" \
  --argjson reads "$reads_json" \
  '{session_dir: $sdir, agents: $agents, repeated_reads: $reads}' 2>/dev/null \
  || printf '%s\n' '{"session_dir":null,"agents":0,"repeated_reads":[]}'
