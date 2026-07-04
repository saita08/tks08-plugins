#!/usr/bin/env bash
# idea-forge: mine the statistical strata of usage.
#
# Reads ~/.claude/history.jsonl from the cursor's line offset forward (the
# prompt log: {display, project, timestamp, sessionId}) and ~/.claude/
# stats-cache.json in full (small and pre-aggregated). Prints slash-command
# frequencies, clustered prompt shapes, and the usage rhythm as JSON.
#
# The line offset lives in state.json under "history_offset" and is staged
# into "pending" so dig-commit.sh advances it. history.jsonl is append-mostly,
# so a line offset is a sound incremental cursor.

set -euo pipefail

state_dir="${HOME}/.claude/idea-forge"
state_file="${state_dir}/state.json"
history_file="${HOME}/.claude/history.jsonl"
stats_file="${HOME}/.claude/stats-cache.json"

python3 - "$state_file" "$history_file" "$stats_file" <<'PY'
import json, os, sys, re
from collections import Counter

state_file, history_file, stats_file = sys.argv[1], sys.argv[2], sys.argv[3]

cursor = {}
cursor_exists = os.path.exists(state_file)
if cursor_exists:
    try:
        with open(state_file, encoding="utf-8") as f:
            cursor = json.load(f) or {}
    except Exception:
        cursor = {}

start = int(cursor.get("history_offset", 0)) if isinstance(cursor, dict) else 0

command_freq = Counter()
# Prompt-shape clustering: strip a prompt down to a skeleton (drop quoted
# strings, paths, numbers, code) and count recurring skeletons. A skeleton
# that recurs is a prompt the user keeps re-typing by hand.
shape_freq = Counter()
shape_examples = {}
new_lines = 0
last_line = start

def skeleton(text):
    t = text.strip().lower()
    # Drop obvious volatile content so structurally-identical prompts collapse.
    t = re.sub(r'`[^`]*`', ' CODE ', t)
    t = re.sub(r'/[\w./~-]+', ' PATH ', t)
    t = re.sub(r'https?://\S+', ' URL ', t)
    t = re.sub(r'\d+', ' N ', t)
    t = re.sub(r'"[^"]*"', ' STR ', t)
    t = re.sub(r'\s+', ' ', t).strip()
    # First ~12 words carry the shape; the tail is usually the specifics.
    return " ".join(t.split()[:12])

if os.path.exists(history_file):
    with open(history_file, encoding="utf-8") as f:
        for i, line in enumerate(f):
            if i < start:
                continue
            last_line = i + 1
            new_lines += 1
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue
            disp = (d.get("display") or "").strip()
            if not disp:
                continue
            if disp.startswith("/"):
                cmd = disp.split()[0]
                command_freq[cmd] += 1
            else:
                sk = skeleton(disp)
                if len(sk) >= 12:  # ignore trivially short prompts
                    shape_freq[sk] += 1
                    shape_examples.setdefault(sk, disp[:200])

# Keep only prompt shapes that actually recurred; a shape seen once is noise.
prompt_shapes = [
    {"shape": sk, "count": c, "example": shape_examples.get(sk, "")}
    for sk, c in shape_freq.most_common(25) if c >= 2
]

# Rhythm from the pre-aggregated stats cache.
rhythm = {}
if os.path.exists(stats_file):
    try:
        with open(stats_file, encoding="utf-8") as f:
            stats = json.load(f)
        rhythm = {
            "total_sessions": stats.get("totalSessions"),
            "total_messages": stats.get("totalMessages"),
            "first_session_date": stats.get("firstSessionDate"),
            "hour_counts": stats.get("hourCounts"),
            "recent_daily_activity": (stats.get("dailyActivity") or [])[-14:],
        }
    except Exception:
        rhythm = {}

# Stage the new history offset for dig-commit.sh.
os.makedirs(os.path.dirname(state_file), exist_ok=True)
staged = dict(cursor) if isinstance(cursor, dict) else {}
staged.setdefault("history_offset", start)
staged["pending_history_offset"] = last_line
try:
    with open(state_file, "w", encoding="utf-8") as f:
        json.dump(staged, f, indent=2)
except Exception:
    pass

print(json.dumps({
    "command_freq": dict(command_freq.most_common(30)),
    "prompt_shapes": prompt_shapes,
    "rhythm": rhythm,
    "history_new_lines": new_lines,
    "cursor_exists": cursor_exists,
}))
PY
