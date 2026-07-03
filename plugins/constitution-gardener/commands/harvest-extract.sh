#!/usr/bin/env bash
# constitution-gardener: extract friction events from one transcript.
#
# Given one session transcript path, pulls the user/assistant turns, asks a
# lightweight `claude -p` (Haiku) call to identify the moments where the user
# corrected, rejected, or re-instructed Claude — each paired with the Claude
# action that provoked it — and prints them as a JSON array. An empty array
# means the session was frictionless.
#
# The judgment criteria live in skills/draft-principle/references/
# friction-taxonomy.md; this script carries the essence inline so it runs
# without loading that file. Keep the two in agreement.

set -euo pipefail

# --- Recursion guard -------------------------------------------------------
# This script calls `claude -p`, itself a Claude Code session that fires its
# own hooks. The guard variable is inherited by the child, so any nested
# constitution-gardener extraction exits immediately instead of recursing.
if [ -n "${CONSTITUTION_GARDENER_GUARD:-}" ]; then
  printf '[]\n'
  exit 0
fi

transcript_path="${1:-}"
[ -n "$transcript_path" ] || { printf '[]\n'; exit 0; }
[ -f "$transcript_path" ] || { printf '[]\n'; exit 0; }

# --- Build a compact user/assistant turn log -------------------------------
# Injected slash-command expansions and skill bodies arrive as user turns
# flagged isMeta; they are instructions, not something the user did, so they
# are dropped. We keep pairs of (assistant action -> user reply) because a
# correction only means something against the action it corrects.
turns="$(
  python3 - "$transcript_path" <<'PY'
import sys, json

path = sys.argv[1]
out = []
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
            if d.get("type") not in ("user", "assistant"):
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
            text = " ".join(text.split())
            if not text:
                continue
            # Slash-command invocation wrappers injected as user turns.
            if text.startswith("<command-") or text.startswith("<local-command"):
                continue
            if len(text) > 1200:
                text = text[:1200]
            out.append(f'{d.get("type")}: {text}')
except Exception:
    pass

# Keep a bounded window; friction is dense enough that the tail suffices and
# the whole transcript would blow the budget.
print("\n".join(out[-120:]))
PY
)"

[ -n "$turns" ] || { printf '[]\n'; exit 0; }

project="$(basename "$(dirname "$transcript_path")")"

# The Anthropic API requires the top-level structured-output schema to be an
# object, not an array (a bare array schema is rejected with a 400). So the
# events array is wrapped in an object under "events", and the parse below
# reads structured_output.events.
schema='{"type":"object","properties":{"events":{"type":"array","items":{"type":"object","properties":{"kind":{"type":"string","enum":["correction","rejection","rephrasing"]},"user_quote":{"type":"string"},"claude_action":{"type":"string"}},"required":["kind","user_quote","claude_action"],"additionalProperties":false}}},"required":["events"],"additionalProperties":false}'

prompt="You are reading one Claude Code session transcript to find FRICTION: moments where the user pushed back on what Claude did. Return only genuine friction, each paired with the Claude action it was reacting to.

Three kinds of friction:
- correction: the user overrode how Claude did something (\"no, do it this way\", \"that's wrong, use X instead\").
- rejection: the user pushed back a proposal or change (\"don't do that\", \"revert that\", \"stop\").
- rephrasing: the user re-issued the same request from a different angle because the first attempt missed — a record that one pass did not land.

For each friction event, capture:
- kind: one of correction, rejection, rephrasing.
- user_quote: a short verbatim quote of the user's pushback (trim to the essential phrase).
- claude_action: a one-line description of what Claude had just done that provoked it.

Do NOT report:
- Ordinary questions, clarifications, or new unrelated requests.
- The user simply moving on to the next task.
- Approvals, thanks, or neutral acknowledgements.
- Friction whose subject is the transcript-mining or plugin tooling itself.
- Cases where you cannot identify a specific Claude action being pushed back on.

Judge from evidence, not plausibility. If it is not clearly one of the three kinds, leave it out. Return an empty array if there is no genuine friction.

Transcript turns:
$turns"

result_json="$(
  CONSTITUTION_GARDENER_GUARD=1 claude -p "$prompt" \
    --model haiku \
    --json-schema "$schema" \
    --output-format json \
    --disallowed-tools "Bash Edit Write Read Glob Grep WebFetch WebSearch Task" \
    2>/dev/null || true
)"

[ -n "$result_json" ] || { printf '[]\n'; exit 0; }

# Pull the structured array out of the claude -p envelope and stamp each event
# with the project it came from.
printf '%s' "$result_json" | python3 -c '
import sys, json
project = sys.argv[1]
try:
    d = json.load(sys.stdin)
except Exception:
    print("[]"); sys.exit(0)
so = d.get("structured_output") or {}
events = so.get("events") if isinstance(so, dict) else None
if not isinstance(events, list):
    print("[]"); sys.exit(0)
out = []
for e in events:
    if not isinstance(e, dict):
        continue
    out.append({
        "kind": e.get("kind", ""),
        "user_quote": e.get("user_quote", ""),
        "claude_action": e.get("claude_action", ""),
        "project": project,
    })
print(json.dumps(out))
' "$project"
