#!/usr/bin/env bash
# constitution-gardener: select the batch of transcripts to mine this run.
#
# Reads the cursor at ~/.claude/constitution-gardener/state.json, lists session
# transcripts modified since the cursor's high-water mark, caps the count, and
# prints the batch as JSON. Also stages the batch into state.json under
# "pending" so harvest-commit.sh can advance the cursor once extraction is done.
#
# Transcripts can be hundreds of megabytes in aggregate; selecting incrementally
# from a cursor is what keeps each run bounded. Reading everything is a bug.

set -euo pipefail

DEFAULT_CAP=15

# First argument, if a positive integer, overrides the cap.
cap="$DEFAULT_CAP"
if [ "${1:-}" ] && printf '%s' "$1" | grep -Eq '^[0-9]+$' && [ "$1" -gt 0 ]; then
  cap="$1"
fi

state_dir="${HOME}/.claude/constitution-gardener"
state_file="${state_dir}/state.json"
projects_dir="${HOME}/.claude/projects"

python3 - "$state_file" "$projects_dir" "$cap" <<'PY'
import json, os, sys, glob

state_file, projects_dir, cap = sys.argv[1], sys.argv[2], int(sys.argv[3])

cursor = {}
cursor_exists = os.path.exists(state_file)
if cursor_exists:
    try:
        with open(state_file, encoding="utf-8") as f:
            cursor = json.load(f) or {}
    except Exception:
        cursor = {}

# processed: {session_path: last_mtime_seen}
processed = cursor.get("processed", {}) if isinstance(cursor, dict) else {}

candidates = []
if os.path.isdir(projects_dir):
    for path in glob.glob(os.path.join(projects_dir, "*", "*.jsonl")):
        try:
            mtime = os.path.getmtime(path)
        except OSError:
            continue
        seen = processed.get(path)
        # New file, or file touched since we last read it.
        if seen is None or mtime > float(seen) + 0.5:
            candidates.append((path, mtime))

# Oldest-first: mine in the order work happened, so the cursor advances
# monotonically and a capped run leaves the newest sessions for next time.
candidates.sort(key=lambda t: t[1])
total_new = len(candidates)
batch = candidates[:cap]

def project_of(path):
    # Parent directory name is the project slug (dashes for slashes).
    return os.path.basename(os.path.dirname(path))

sessions = [
    {"path": p, "project": project_of(p), "mtime": m}
    for (p, m) in batch
]

# Stage the batch so harvest-commit.sh can fold it into the cursor.
os.makedirs(os.path.dirname(state_file), exist_ok=True)
staged = dict(cursor) if isinstance(cursor, dict) else {}
staged["processed"] = processed
staged["pending"] = {p: m for (p, m) in batch}
try:
    with open(state_file, "w", encoding="utf-8") as f:
        json.dump(staged, f, indent=2)
except Exception:
    pass

print(json.dumps({
    "sessions": sessions,
    "cap": cap,
    "cursor_exists": cursor_exists,
    "total_new": total_new,
}))
PY
