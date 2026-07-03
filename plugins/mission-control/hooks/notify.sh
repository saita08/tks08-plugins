#!/usr/bin/env bash
# mission-control notify hook.
#
# Runs on Stop. When a Slack webhook is configured — either the SLACK_WEBHOOK_URL
# environment variable or a `webhook:` line in .claude/mission-control.local.md —
# it extracts the gist of the session's final assistant message from the
# transcript and posts it to Slack. When no webhook is configured it prints
# nothing and exits 0: this marketplace runs many hooks at once, so an
# unconfigured hook must be invisible, never a source of noise or errors.
#
# Sending to Slack is a side effect on the outside world, so it is strictly
# opt-in: absent explicit configuration, this hook does nothing at all.

set -euo pipefail

# --- Read hook input -------------------------------------------------------
input="$(cat)"

parsed="$(
  printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get("transcript_path",""))
    print(d.get("session_id",""))
    print(d.get("cwd",""))
except Exception:
    pass'
)"
transcript_path="$(printf '%s\n' "$parsed" | sed -n 1p)"
session_id="$(printf '%s\n' "$parsed" | sed -n 2p)"
cwd="$(printf '%s\n' "$parsed" | sed -n 3p)"

[ -n "$transcript_path" ] || exit 0
[ -f "$transcript_path" ] || exit 0

# --- Resolve the webhook (env first, then project .local.md) ----------------
# The environment variable wins so a machine-wide default can be set once. The
# .local.md value lets a single project override or opt in on its own. Reading
# stops at the first `webhook:` line in the YAML frontmatter.
webhook="${SLACK_WEBHOOK_URL:-}"

if [ -z "$webhook" ] && [ -n "$cwd" ]; then
  settings="$cwd/.claude/mission-control.local.md"
  if [ -f "$settings" ]; then
    webhook="$(
      python3 - "$settings" <<'PY'
import sys, re
path = sys.argv[1]
in_fm = False
seen = 0
try:
    with open(path, encoding="utf-8") as f:
        for line in f:
            s = line.rstrip("\n")
            if s.strip() == "---":
                seen += 1
                in_fm = seen == 1
                if seen >= 2:
                    break
                continue
            if in_fm:
                m = re.match(r'\s*webhook\s*:\s*(.+?)\s*$', s)
                if m:
                    val = m.group(1).strip().strip('"').strip("'")
                    print(val)
                    break
except Exception:
    pass
PY
    )"
  fi
fi

# No webhook configured -> stay silent. This is the common, correct case.
[ -n "$webhook" ] || exit 0

# --- One post per session --------------------------------------------------
# A Stop hook can fire more than once in a session (continuation, subagent
# boundaries). The webhook is an external side effect, so guard against a
# double post with a per-session marker.
state_dir="${TMPDIR:-/tmp}/mission-control-state-$(id -u)"
marker="$state_dir/notified-${session_id:-unknown}"
if [ -n "$session_id" ] && [ -e "$marker" ]; then
  exit 0
fi

# --- Extract the gist of the final assistant message -----------------------
# The value of a completion notice is *what* completed. Pull the last assistant
# turn's text: a few leading lines for the gist, plus any line that reads like a
# result/summary marker so the outcome travels with the notice.
gist="$(
  python3 - "$transcript_path" <<'PY'
import sys, json

path = sys.argv[1]
last_text = ""
try:
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue
            if d.get("type") != "assistant":
                continue
            if d.get("isMeta"):
                continue
            msg = d.get("message", {}) or {}
            content = msg.get("content")
            text = ""
            if isinstance(content, str):
                text = content
            elif isinstance(content, list):
                for b in content:
                    if isinstance(b, dict) and b.get("type") == "text":
                        text += b.get("text", "")
            text = text.strip()
            if text:
                last_text = text
except Exception:
    pass

if not last_text:
    sys.exit(0)

lines = [ln.rstrip() for ln in last_text.splitlines()]
lines = [ln for ln in lines if ln.strip()]

head = lines[:5]

# Pull out lines that look like an explicit result/summary marker, so the
# outcome is not lost if it sat below the first few lines.
markers = []
pat = ("result:", "summary:", "結果:", "まとめ:", "完了:", "done:")
for ln in lines:
    low = ln.strip().lower()
    if low.startswith(pat):
        if ln not in head and ln not in markers:
            markers.append(ln)

out = list(head)
for m in markers[:3]:
    if m not in out:
        out.append(m)

gist = "\n".join(out).strip()
if len(gist) > 1200:
    gist = gist[:1200].rstrip() + "…"
print(gist)
PY
)"

# Nothing meaningful to report -> stay silent rather than post an empty notice.
[ -n "$gist" ] || exit 0

# --- Build a project label -------------------------------------------------
project="$(basename "${cwd:-session}" 2>/dev/null || echo session)"

# --- Post to Slack ---------------------------------------------------------
# Compose the Slack payload with python's json so the message text is always
# correctly escaped regardless of what the transcript contained.
payload="$(
  python3 - "$project" "$gist" <<'PY'
import sys, json
project = sys.argv[1]
gist = sys.argv[2]
text = f":white_check_mark: *{project}* — session finished\n{gist}"
print(json.dumps({"text": text}))
PY
)"

# Record the marker before sending so a slow or failing POST cannot lead to a
# duplicate on a re-fire.
if [ -n "$session_id" ]; then
  mkdir -p "$state_dir" 2>/dev/null || true
  : > "$marker" 2>/dev/null || true
fi

# Post quietly. Any failure (network, bad webhook) stays out of the
# conversation: the notice is a convenience, not part of the user's task.
curl -sS -m 10 -X POST -H 'Content-type: application/json' \
  --data "$payload" "$webhook" >/dev/null 2>&1 || true

exit 0
