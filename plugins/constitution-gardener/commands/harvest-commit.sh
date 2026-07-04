#!/usr/bin/env bash
# constitution-gardener: advance the cursor after a harvest completes.
#
# Folds the "pending" batch staged by harvest-select.sh into "processed", so the
# next harvest starts where this one stopped. Run this whether or not any
# proposal survived: the sessions were read either way, and re-reading them
# next time would waste work and resurface declined candidates.

set -euo pipefail

state_dir="${HOME}/.claude/constitution-gardener"
state_file="${state_dir}/state.json"

[ -f "$state_file" ] || exit 0

python3 - "$state_file" <<'PY'
import json, os, sys

state_file = sys.argv[1]
try:
    with open(state_file, encoding="utf-8") as f:
        state = json.load(f) or {}
except Exception:
    sys.exit(0)

processed = state.get("processed", {}) or {}
pending = state.get("pending", {}) or {}

# Merge the pending batch in, keeping the newest mtime seen per file.
for path, mtime in pending.items():
    prev = processed.get(path)
    processed[path] = max(float(mtime), float(prev)) if prev is not None else float(mtime)

state["processed"] = processed
state["pending"] = {}

import datetime
state["last_harvest"] = datetime.datetime.now(datetime.timezone.utc).isoformat()

tmp = state_file + ".tmp"
try:
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2)
    os.replace(tmp, state_file)
except Exception:
    pass
PY
