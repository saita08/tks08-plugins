#!/usr/bin/env bash
# idea-forge: advance the cursor after a dig completes.
#
# Folds the staged history offset and the sampled-transcript batch into the
# durable cursor, so the next dig starts where this one stopped. Run this
# whether or not any candidate survived: the strata were read either way, and
# re-reading them would waste work and resurface the same candidates.

set -euo pipefail

state_dir="${HOME}/.claude/idea-forge"
state_file="${state_dir}/state.json"

[ -f "$state_file" ] || exit 0

python3 - "$state_file" <<'PY'
import json, os, sys, datetime

state_file = sys.argv[1]
try:
    with open(state_file, encoding="utf-8") as f:
        state = json.load(f) or {}
except Exception:
    sys.exit(0)

# Advance the history line offset if a newer one was staged.
pending_offset = state.get("pending_history_offset")
if pending_offset is not None:
    try:
        state["history_offset"] = max(int(state.get("history_offset", 0)), int(pending_offset))
    except Exception:
        pass
state.pop("pending_history_offset", None)

# Fold the sampled-transcript batch in, keeping the newest mtime per file.
sampled = state.get("sampled_transcripts", {}) or {}
pending = state.get("pending_transcripts", {}) or {}
for path, mtime in pending.items():
    prev = sampled.get(path)
    sampled[path] = max(float(mtime), float(prev)) if prev is not None else float(mtime)
state["sampled_transcripts"] = sampled
state["pending_transcripts"] = {}

state["last_dig"] = datetime.datetime.now(datetime.timezone.utc).isoformat()

tmp = state_file + ".tmp"
try:
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2)
    os.replace(tmp, state_file)
except Exception:
    pass
PY
