#!/usr/bin/env bash
# pluginize observation hook.
#
# Runs on Stop as an asyncRewake hook. Reads the transcript, asks a lightweight
# claude -p call whether the recent work contains a reusable-structure
# candidate, and stays silent unless it does. When it finds one, it prints the
# proposal to stderr and exits with code 2 — that is the asyncRewake contract
# (verified against the harness end to end): the model is woken only when an
# async hook exits with code 2, and what it is shown is the hook's stderr.
# Exit code 0 means silence. A JSON block decision on stdout is the
# synchronous Stop-hook protocol and is discarded for async hooks.
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

parsed="$(
  printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get("transcript_path",""))
    print(d.get("session_id",""))
except Exception:
    pass'
)"
transcript_path="$(printf '%s\n' "$parsed" | sed -n 1p)"
session_id="$(printf '%s\n' "$parsed" | sed -n 2p)"

# Nothing to look at -> stay silent.
[ -n "$transcript_path" ] || exit 0
[ -f "$transcript_path" ] || exit 0

# --- One proposal per session ----------------------------------------------
# A proposal the user let pass must not return at the next stop. Repeats teach
# the user to ignore the channel, and an ignored channel loses the true
# positives too. The marker is written only when a proposal actually fires,
# so silent stops do not consume the session's one slot.
state_dir="${TMPDIR:-/tmp}/pluginize-state-$(id -u)"
marker="$state_dir/proposed-${session_id:-unknown}"
if [ -n "$session_id" ] && [ -e "$marker" ]; then
  exit 0
fi

# --- Build a compact summary of recent work --------------------------------
# Pull the text of the most recent user/assistant turns. Injected payloads —
# slash-command expansions and skill bodies arrive as user turns flagged
# isMeta — are dropped: they describe instructions, not work that happened,
# and they would both blow the budget and read as reusable structure when they
# are the output of structure that already exists.
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
            # Injected command/skill payloads, not something anyone did.
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
            # Skip the command-invocation wrappers injected as user turns.
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

Decide whether the recent work below contains a CANDIDATE worth proposing to turn into a plugin. A candidate must show CONCRETE EVIDENCE in the work itself on at least one of these axes:
- Repeatability: the same shape of work visibly recurred, or the user said it recurs across sessions/projects.
- Crystallized procedure: a sequence of steps settled during this work into a definite order that matters.
- Tacit knowledge: the work relied on something non-obvious that is not written down where others would find it.

Do NOT raise a candidate for:
- Work that was carried out by running an existing slash command, skill, or plugin. That structure is already encoded; proposing it again offers nothing, however procedural the work looks.
- Work whose subject is itself building, testing, or debugging a plugin or skill.
- A one-off solution, a standard practice documented elsewhere, a convention specific to this single project, or a rule a regex/validation could enforce.
- Ordinary implementation work (a feature, a bugfix, a refactor) whose steps follow from the task at hand rather than from a reusable procedure.

Judge from evidence, not plausibility. If an axis is merely conceivable rather than visible in the work, or you are uncertain, set candidate=false.

If there is a candidate, set candidate=true, write a one-sentence summary of the reusable work, and name the single strongest axis (repeatability, procedure, or tacit).

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
# Record the marker first, so this session never proposes twice even if the
# rewake itself is lost.
if [ -n "$session_id" ]; then
  mkdir -p "$state_dir" 2>/dev/null || true
  : > "$marker" 2>/dev/null || true
fi

printf '%s\n' "A reusable-structure candidate surfaced in your recent work (axis: ${axis}): ${summary}

If this looks worth turning into a plugin, run /pluginize:propose-plugin to review and approve it. The plugin will be generated in an isolated background session, so this conversation stays clean. If it is not worth it, ignore this and continue." >&2

exit 2
