#!/usr/bin/env bash
# idea-forge: sample recent transcripts for recurring manual work.
#
# Selects transcripts newer than the cursor (capped), and for each asks a
# lightweight `claude -p` call to spot recurring manual procedures or hand-run
# sequences that look like they want automation. Prints the findings as JSON.
#
# The set of transcripts already sampled lives in state.json under
# "sampled_transcripts" and the batch is staged into "pending_transcripts" for
# dig-commit.sh. Reading everything each run would be a bug: transcripts reach
# hundreds of megabytes.

set -euo pipefail

# --- Recursion guard -------------------------------------------------------
# This script calls `claude -p`, itself a Claude Code session firing its own
# hooks. The guard variable is inherited by the child, so a nested idea-forge
# sampling exits immediately.
if [ -n "${IDEA_FORGE_GUARD:-}" ]; then
  printf '{"manual_work":[],"sampled":0}\n'
  exit 0
fi

DEFAULT_CAP=12

cap="$DEFAULT_CAP"
if [ "${1:-}" ] && printf '%s' "$1" | grep -Eq '^[0-9]+$' && [ "$1" -gt 0 ]; then
  cap="$1"
fi

state_dir="${HOME}/.claude/idea-forge"
state_file="${state_dir}/state.json"
projects_dir="${HOME}/.claude/projects"

# --- Select the batch and stage it -----------------------------------------
batch="$(
  python3 - "$state_file" "$projects_dir" "$cap" <<'PY'
import json, os, sys, glob

state_file, projects_dir, cap = sys.argv[1], sys.argv[2], int(sys.argv[3])

cursor = {}
if os.path.exists(state_file):
    try:
        with open(state_file, encoding="utf-8") as f:
            cursor = json.load(f) or {}
    except Exception:
        cursor = {}

sampled = cursor.get("sampled_transcripts", {}) if isinstance(cursor, dict) else {}

candidates = []
if os.path.isdir(projects_dir):
    for path in glob.glob(os.path.join(projects_dir, "*", "*.jsonl")):
        try:
            mtime = os.path.getmtime(path)
        except OSError:
            continue
        seen = sampled.get(path)
        if seen is None or mtime > float(seen) + 0.5:
            candidates.append((path, mtime))

candidates.sort(key=lambda t: t[1])  # oldest-first, capped
batch = candidates[:cap]

# Stage the batch.
os.makedirs(os.path.dirname(state_file), exist_ok=True)
staged = dict(cursor) if isinstance(cursor, dict) else {}
staged["sampled_transcripts"] = sampled
staged["pending_transcripts"] = {p: m for (p, m) in batch}
try:
    with open(state_file, "w", encoding="utf-8") as f:
        json.dump(staged, f, indent=2)
except Exception:
    pass

for p, _ in batch:
    print(p)
PY
)"

manual_json="[]"
sampled_count=0

if [ -n "$batch" ]; then
  # Accumulate findings across the sampled transcripts.
  tmp_findings="$(mktemp)"
  trap 'rm -f "$tmp_findings"' EXIT
  printf '[' > "$tmp_findings"
  first=1

  # The Anthropic API requires the top-level structured-output schema to be an
  # object, not an array (a bare array schema is rejected with a 400). The
  # patterns array is wrapped under "patterns"; the parse reads
  # structured_output.patterns.
  schema='{"type":"object","properties":{"patterns":{"type":"array","items":{"type":"object","properties":{"pattern":{"type":"string"},"evidence":{"type":"string"}},"required":["pattern","evidence"],"additionalProperties":false}}},"required":["patterns"],"additionalProperties":false}'

  while IFS= read -r tpath; do
    [ -n "$tpath" ] || continue
    [ -f "$tpath" ] || continue
    sampled_count=$((sampled_count + 1))
    project="$(basename "$(dirname "$tpath")")"

    turns="$(
      python3 - "$tpath" <<'PY'
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
            if text.startswith("<command-") or text.startswith("<local-command"):
                continue
            if len(text) > 1000:
                text = text[:1000]
            out.append(f'{d.get("type")}: {text}')
except Exception:
    pass
print("\n".join(out[-100:]))
PY
    )"

    [ -n "$turns" ] || continue

    prompt="You are reading one Claude Code session for RECURRING MANUAL WORK — hand-run procedures or step sequences the user drove manually that look like they want automation. Report only patterns with a repeatable shape, not one-off tasks.

For each pattern found:
- pattern: a one-line description of the repeatable manual procedure.
- evidence: a short quote or paraphrase from the session showing it happening.

Do NOT report:
- Work already carried out by an existing slash command, skill, or plugin.
- One-off implementation, a feature or bugfix whose steps follow from the task.
- Work whose subject is building/testing/debugging a plugin or skill.
- Anything you cannot ground in a concrete moment in the session.

Judge from evidence, not plausibility. Return an empty array if nothing clearly recurring and manual is present.

Session turns:
$turns"

    result_json="$(
      IDEA_FORGE_GUARD=1 claude -p "$prompt" \
        --model haiku \
        --json-schema "$schema" \
        --output-format json \
        --disallowed-tools "Bash Edit Write Read Glob Grep WebFetch WebSearch Task" \
        2>/dev/null || true
    )"

    [ -n "$result_json" ] || continue

    items="$(
      printf '%s' "$result_json" | python3 -c '
import sys, json
project = sys.argv[1]
try:
    d = json.load(sys.stdin)
except Exception:
    print(""); sys.exit(0)
so = d.get("structured_output") or {}
events = so.get("patterns") if isinstance(so, dict) else None
if not isinstance(events, list):
    print(""); sys.exit(0)
out = []
for e in events:
    if not isinstance(e, dict):
        continue
    out.append(json.dumps({
        "pattern": e.get("pattern", ""),
        "evidence": e.get("evidence", ""),
        "project": project,
    }))
print("\n".join(out))
' "$project"
    )"

    while IFS= read -r item; do
      [ -n "$item" ] || continue
      if [ "$first" -eq 1 ]; then
        first=0
      else
        printf ',' >> "$tmp_findings"
      fi
      printf '%s' "$item" >> "$tmp_findings"
    done <<< "$items"
  done <<< "$batch"

  printf ']' >> "$tmp_findings"
  manual_json="$(cat "$tmp_findings")"
fi

python3 -c '
import sys, json
manual = json.loads(sys.argv[1]) if sys.argv[1] else []
print(json.dumps({"manual_work": manual, "sampled": int(sys.argv[2])}))
' "$manual_json" "$sampled_count"
