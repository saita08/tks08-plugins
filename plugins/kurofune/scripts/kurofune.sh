#!/usr/bin/env bash
# kurofune.sh -- dispatch a coding task to Grok Build running headless,
# and continue its session so the worker keeps its context across turns.
#
# Usage:
#   kurofune.sh doctor
#   kurofune.sh task   [-r] [-C DIR] "PROMPT"
#   kurofune.sh resume [-r] [-C DIR] SESSION_ID "PROMPT"
#
#   -r      review mode: omit --always-approve so Grok cannot mutate files
#   -C DIR  working directory for the worker (defaults to current directory)
#
# stdout is Grok's JSON envelope: {text, stopReason, sessionId, requestId, thought}.
# Extract sessionId (jq -r .sessionId) and pass it to `resume` for follow-ups.
set -euo pipefail

GROK_BIN="${KUROFUNE_GROK_BIN:-$HOME/.grok/bin/grok}"

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

doctor() {
  if [ ! -x "$GROK_BIN" ]; then
    echo "kurofune: grok binary not found at $GROK_BIN" >&2
    echo "Install Grok Build yourself: curl -fsSL https://x.ai/cli/install.sh | bash" >&2
    exit 1
  fi
  "$GROK_BIN" --version
  if [ ! -f "$HOME/.grok/auth.json" ]; then
    echo "kurofune: no auth cache at ~/.grok/auth.json -- run 'grok login' yourself (subscription required)" >&2
    exit 1
  fi
  echo "auth cache present: ~/.grok/auth.json"
}

run() {
  local mode=$1
  shift
  local review=0 dir="" opt OPTIND=1
  while getopts "rC:" opt; do
    case $opt in
      r) review=1 ;;
      C) dir=$OPTARG ;;
      *) usage ;;
    esac
  done
  shift $((OPTIND - 1))

  local session="" prompt=""
  if [ "$mode" = "resume" ]; then
    [ $# -eq 2 ] || usage
    session=$1
    prompt=$2
  else
    [ $# -eq 1 ] || usage
    prompt=$1
  fi

  local args=(--no-auto-update --output-format json)
  [ -n "$dir" ] && args+=(--cwd "$dir")
  [ "$review" -eq 0 ] && args+=(--always-approve)
  [ -n "$session" ] && args+=(--resume "$session")
  args+=(-p "$prompt")

  exec "$GROK_BIN" "${args[@]}"
}

[ $# -ge 1 ] || usage
cmd=$1
shift
case "$cmd" in
  doctor) doctor ;;
  task) run task "$@" ;;
  resume) run resume "$@" ;;
  *) usage ;;
esac
