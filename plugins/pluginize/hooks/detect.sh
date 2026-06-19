#!/usr/bin/env bash
# pluginize observation hook.
#
# Runs on Stop. Reads the transcript, asks a lightweight claude -p call whether
# the recent work contains a reusable-structure candidate, and stays silent
# unless it does. When it finds one, it emits a Stop-hook block decision so the
# main session is gently rewoken with the candidate.
#
# The judgment criteria live in the skill's references/detection-axes.md; this
# script only carries the question's essence inline so it can run without
# loading that file. Keep the two in agreement.

set -euo pipefail

# --- Recursion guard -------------------------------------------------------
# This hook calls `claude -p`, which is itself a Claude Code session and so
# fires its own Stop hook (verified empirically). Without a guard, that child
# Stop would run this script again, and so on. The guard variable is inherited
# by the child session's hooks, so a child exits immediately here.
if [ -n "${PLUGINIZE_GUARD:-}" ]; then
  exit 0
fi

# --- Read hook input -------------------------------------------------------
input="$(cat)"

transcript_path="$(
  printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get("transcript_path",""))
except Exception:
    print("")'
)"

# Nothing to look at -> stay silent.
[ -n "$transcript_path" ] || exit 0
[ -f "$transcript_path" ] || exit 0

# --- Build a compact summary of recent work --------------------------------
# Pull the text of the most recent user/assistant turns, dropping the giant
# slash-command/system blocks that would blow the budget and tell us nothing
# about what work actually happened.
recent="$(
  python3 - "$transcript_path" <<'PY'
import sys, json

path = sys.argv[1]
turns = []
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
            # Skip the bulky command/system payloads injected as user turns.
            if text.startswith("<command-") or "# Plugin Creation Workflow" in text:
                continue
            if len(text) > 1500:
                text = text[:1500]
            turns.append(f'{d.get("type")}: {text}')
except Exception:
    pass

# Keep the tail; that is where the just-finished unit of work lives.
print("\n".join(turns[-30:]))
PY
)"

# Nothing usable -> stay silent.
[ -n "$recent" ] || exit 0

# --- Ask claude -p whether there is a candidate ----------------------------
schema='{"type":"object","properties":{"candidate":{"type":"boolean"},"summary":{"type":"string"},"axis":{"type":"string"}},"required":["candidate","summary","axis"],"additionalProperties":false}'

prompt="You are watching a Claude Code session for reusable structure that could become a plugin.

Decide whether the recent work below contains a CANDIDATE worth proposing to turn into a plugin. Cast a wide net: any ONE of these axes is enough to make it a candidate.
- Repeatability: the same shape of work has recurred or plainly will recur across sessions/projects.
- Crystallized procedure: a sequence of steps has settled into a definite order that matters.
- Tacit knowledge: the work relied on something non-obvious and not written down where others would find it.

Do NOT raise a candidate for: a one-off solution, a standard practice documented elsewhere, a convention specific to this single project, or a rule a regex/validation could enforce.

If there is a candidate, set candidate=true, write a one-sentence summary of the reusable work, and name the single strongest axis (repeatability, procedure, or tacit). If there is no clear candidate, set candidate=false. When unsure, prefer candidate=false; silence is cheap to correct, a bad interruption is not.

Recent work:
$recent"

result_json="$(
  PLUGINIZE_GUARD=1 claude -p "$prompt" \
    --model haiku \
    --json-schema "$schema" \
    --output-format json \
    --disallowed-tools "Bash Edit Write Read Glob Grep WebFetch WebSearch Task" \
    2>/dev/null || true
)"

[ -n "$result_json" ] || exit 0

# --- Parse the verdict -----------------------------------------------------
verdict="$(
  printf '%s' "$result_json" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    s=d.get("structured_output") or {}
    if s.get("candidate") is True:
        summary=(s.get("summary") or "").strip()
        axis=(s.get("axis") or "").strip()
        print(json.dumps({"summary":summary,"axis":axis}))
except Exception:
    pass'
)"

# No candidate (or parse failure) -> stay silent. This is the common case.
[ -n "$verdict" ] || exit 0

summary="$(printf '%s' "$verdict" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("summary",""))')"
axis="$(printf '%s' "$verdict" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("axis",""))')"

[ -n "$summary" ] || exit 0

# --- Surface the candidate -------------------------------------------------
# Human-readable body goes to stderr; the Stop-hook decision goes to stdout.
reason="A reusable-structure candidate surfaced in your recent work (axis: ${axis}): ${summary}

If this looks worth turning into a plugin, run /pluginize:propose-plugin to review and approve it. The plugin will be generated in an isolated background session, so this conversation stays clean. If it is not worth it, ignore this and continue."

printf '%s\n' "$reason" >&2

printf '%s\n' "$(
  python3 -c 'import sys,json; print(json.dumps({
    "decision":"block",
    "reason":sys.argv[1],
    "rewakeSummary":"pluginize: a reusable-structure candidate surfaced"
  }))' "$reason"
)"

exit 0
