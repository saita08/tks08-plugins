#!/usr/bin/env bash
# kurofune.sh -- dispatch a coding task to Grok Build running headless,
# and continue its session so the worker keeps its context across turns.
#
# Usage:
#   kurofune.sh doctor
#   kurofune.sh task   [-r] [-C DIR] [-m MODEL] "PROMPT"
#   kurofune.sh resume [-r] [-C DIR] [-m MODEL] SESSION_ID "PROMPT"
#
#   -r      review mode: no write auto-approve; strip write/shell tools
#   -C DIR  working directory for the worker (defaults to current directory)
#   -m MODEL  Grok model id (default: $KUROFUNE_MODEL or grok-4.5)
#
# On success, stdout is a single JSON object:
#   { ok, sessionId, stopReason, text, thought?, model, cwd, resultFile,
#     gitStatus?, gitDiffStat?, usage?, num_turns? }
# On failure, stdout is still JSON when possible ({ ok:false, ... }) and
# exit status is non-zero. Full Grok envelope is always written to resultFile
# when Grok produced one, so a truncated caller can recover sessionId.
set -euo pipefail

GROK_BIN="${KUROFUNE_GROK_BIN:-$HOME/.grok/bin/grok}"
DEFAULT_MODEL="${KUROFUNE_MODEL:-grok-4.5}"
RESULT_DIR="${KUROFUNE_RESULT_DIR:-${TMPDIR:-/tmp}/kurofune-results}"

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
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
  echo "default model: $DEFAULT_MODEL"
  if ! command -v python3 >/dev/null 2>&1; then
    echo "kurofune: python3 not found on PATH — result packaging needs it" >&2
    exit 1
  fi
  echo "python3 present: $(command -v python3)"
}

# Build the machine-readable summary. Paths to files avoid huge env vars.
# Env: KU_OK KU_EXIT KU_MODEL KU_CWD KU_RESULT_FILE KU_ERROR
#      KU_GIT_STATUS_FILE KU_GIT_DIFF_FILE KU_RAW_FILE
emit_result() {
  python3 - <<'PY'
import json, os

def read_text(path):
    if not path:
        return None
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None

raw = None
raw_path = os.environ.get("KU_RAW_FILE") or ""
if raw_path:
    raw_s = read_text(raw_path)
    if raw_s:
        try:
            raw = json.loads(raw_s)
        except json.JSONDecodeError:
            # try last object
            s = raw_s
            for i in range(s.rfind("{"), -1, -1):
                if i < 0:
                    break
                try:
                    raw = json.loads(s[i:])
                    if isinstance(raw, dict):
                        break
                except json.JSONDecodeError:
                    continue
            else:
                raw = None

def git_field(env_key):
    path = os.environ.get(env_key) or ""
    if not path:
        return None
    text = read_text(path)
    return text if text is not None else None

out = {
    "ok": os.environ.get("KU_OK", "false") == "true",
    "sessionId": (raw or {}).get("sessionId"),
    "stopReason": (raw or {}).get("stopReason"),
    "text": (raw or {}).get("text"),
    "model": os.environ.get("KU_MODEL"),
    "cwd": os.environ.get("KU_CWD") or None,
    "resultFile": os.environ.get("KU_RESULT_FILE") or None,
    "exitCode": int(os.environ.get("KU_EXIT", "0") or "0"),
}
if raw and raw.get("thought"):
    thought = raw["thought"]
    if isinstance(thought, str) and len(thought) > 4000:
        out["thought"] = thought[:4000] + "…(truncated)"
    else:
        out["thought"] = thought
gs = git_field("KU_GIT_STATUS_FILE")
if gs:
    out["gitStatus"] = gs
gd = git_field("KU_GIT_DIFF_FILE")
if gd:
    out["gitDiffStat"] = gd
if os.environ.get("KU_ERROR"):
    out["error"] = os.environ["KU_ERROR"]
if raw:
    for k in ("usage", "num_turns", "requestId", "total_cost_usd", "modelUsage"):
        if k in raw:
            out[k] = raw[k]
print(json.dumps(out, ensure_ascii=False))
PY
}

extract_json_file() {
  # $1 = path that may contain a JSON object (possibly with noise). Rewrites in place if needed.
  local f=$1
  python3 - "$f" <<'PY'
import json, sys, re
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        s = fh.read()
except OSError:
    sys.exit(1)
if not s.strip():
    sys.exit(1)
try:
    obj = json.loads(s)
    if isinstance(obj, dict):
        sys.exit(0)
except json.JSONDecodeError:
    pass
for m in re.finditer(r"\{", s):
    chunk = s[m.start():]
    # progressive shrink from end is expensive; try full chunk first then common ends
    try:
        obj = json.loads(chunk)
        if isinstance(obj, dict):
            with open(path, "w", encoding="utf-8") as fh:
                json.dump(obj, fh)
            sys.exit(0)
    except json.JSONDecodeError:
        pass
# brace-scan decoder
decoder = json.JSONDecoder()
for i, ch in enumerate(s):
    if ch != "{":
        continue
    try:
        obj, _ = decoder.raw_decode(s, i)
        if isinstance(obj, dict):
            with open(path, "w", encoding="utf-8") as fh:
                json.dump(obj, fh)
            sys.exit(0)
    except json.JSONDecodeError:
        continue
sys.exit(1)
PY
}

git_snapshot_files() {
  local dir=$1
  local status_f=$2
  local diff_f=$3
  : >"$status_f"
  : >"$diff_f"
  if [ -z "$dir" ] || [ ! -d "$dir" ]; then
    return 0
  fi
  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi
  git -C "$dir" status --short >"$status_f" 2>/dev/null || true
  git -C "$dir" diff --stat HEAD >"$diff_f" 2>/dev/null || true
}

run() {
  local mode=$1
  shift
  local review=0 dir="" model="$DEFAULT_MODEL" opt OPTIND=1
  while getopts "rC:m:" opt; do
    case $opt in
      r) review=1 ;;
      C) dir=$OPTARG ;;
      m) model=$OPTARG ;;
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

  if [ ! -x "$GROK_BIN" ]; then
    KU_OK=false KU_MODEL="$model" KU_CWD="$dir" KU_ERROR="grok binary not found at $GROK_BIN" KU_EXIT=1 \
      emit_result
    exit 1
  fi

  mkdir -p "$RESULT_DIR"
  local stamp result_file err_file status_file diff_file
  stamp=$(date +%Y%m%dT%H%M%S)_$$
  result_file="$RESULT_DIR/${mode}_${stamp}.json"
  err_file="$RESULT_DIR/${mode}_${stamp}.stderr"
  status_file="$RESULT_DIR/${mode}_${stamp}.gitstatus"
  diff_file="$RESULT_DIR/${mode}_${stamp}.gitdiff"

  local args=(--no-auto-update --output-format json -m "$model")
  [ -n "$dir" ] && args+=(--cwd "$dir")
  if [ "$review" -eq 0 ]; then
    args+=(--always-approve)
  else
    # Config-level yolo can re-enable writes if we only omit --always-approve.
    args+=(--permission-mode default)
    args+=(--disallowed-tools "search_replace,run_terminal_cmd")
  fi
  [ -n "$session" ] && args+=(--resume "$session")
  args+=(-p "$prompt")

  set +e
  "$GROK_BIN" "${args[@]}" >"$result_file" 2>"$err_file"
  local rc=$?
  set -e

  if [ -s "$result_file" ]; then
    extract_json_file "$result_file" || true
  fi

  git_snapshot_files "$dir" "$status_file" "$diff_file"

  export KU_MODEL="$model" KU_CWD="$dir" KU_RESULT_FILE="$result_file" KU_EXIT="$rc"
  export KU_RAW_FILE="$result_file"
  export KU_GIT_STATUS_FILE="$status_file" KU_GIT_DIFF_FILE="$diff_file"

  if [ -s "$result_file" ] && python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$result_file" 2>/dev/null; then
    local stop_reason
    stop_reason=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("stopReason") or "")' "$result_file")
    if [ "$rc" -eq 0 ] && [ "$stop_reason" != "Cancelled" ]; then
      export KU_OK=true
      emit_result
      exit 0
    fi
    export KU_OK=false
    if [ "$stop_reason" = "Cancelled" ]; then
      export KU_ERROR="Grok stopped with stopReason=Cancelled (often review mode blocked a write, or a permission prompt had no TTY)"
    elif [ "$rc" -ne 0 ]; then
      export KU_ERROR="grok exited with status $rc"
    else
      export KU_ERROR="grok finished unsuccessfully"
    fi
    emit_result
    exit 1
  fi

  local err_snip
  err_snip=$(head -c 2000 "$err_file" 2>/dev/null || true)
  export KU_OK=false
  export KU_ERROR="${err_snip:-no JSON envelope from grok (exit $rc)}"
  # keep result file path even when empty for debugging
  emit_result
  exit "${rc:-1}"
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
