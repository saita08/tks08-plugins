#!/usr/bin/env bash
# claude-rpg SessionStart hook.
#
# On session start, re-judge achievements from the real usage data, compare
# against the saved unlocked set, and — only if something newly unlocked since
# last time — ask the session to offer a one-line congratulation via
# additionalContext. When nothing is new, emit nothing and exit 0: this hook is
# silent by default. Many plugins share the SessionStart event, so a slow or
# chatty hook here degrades everyone; this one does a light pure-Python judge
# and returns fast.
#
# The judging here MUST mirror skills/adventurer-status/references/
# achievements.md. It is deliberately a subset kept simple enough to run without
# an LLM: it needs only to detect *new* unlocks to decide whether to greet. The
# full, authoritative card is produced by the /claude-rpg:status command.

set -euo pipefail

STATS="${HOME}/.claude/stats-cache.json"
HISTORY="${HOME}/.claude/history.jsonl"
STATE_DIR="${HOME}/.claude/claude-rpg"
STATE="${STATE_DIR}/achievements.json"

# No data at all -> nothing to celebrate, stay completely silent.
[ -f "$STATS" ] || exit 0

# python3 is the only dependency beyond a POSIX shell. If it is missing, we
# cannot judge; stay silent rather than erroring into the session.
command -v python3 >/dev/null 2>&1 || exit 0

newly="$(
  python3 - "$STATS" "$HISTORY" "$STATE" <<'PY'
import sys, json, os, re
from datetime import date, datetime, timezone

# A real slash command, not any display that merely starts with "/". Excludes
# file paths (/Users/...) and prose beginning with a slash, which would inflate
# the distinct-command count. Kept in sync with achievements.md.
SLASH_CMD = re.compile(r"^/[A-Za-z0-9-]+(:[A-Za-z0-9-]+)?$")

stats_path, history_path, state_path = sys.argv[1], sys.argv[2], sys.argv[3]

def load_json(p):
    try:
        with open(p, encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return {}

stats = load_json(stats_path)
daily = stats.get("dailyActivity") or []
hours = stats.get("hourCounts") or {}
longest = stats.get("longestSession") or {}
model_usage = stats.get("modelUsage") or {}

total_sessions = stats.get("totalSessions")
total_messages = stats.get("totalMessages")
if total_messages is None and daily:
    total_messages = sum((d.get("messageCount") or 0) for d in daily)

def active_dates():
    out = set()
    for d in daily:
        if (d.get("messageCount") or 0) > 0 and d.get("date"):
            out.add(d["date"])
    return out

def longest_run(dates):
    if not dates:
        return 0
    ds = sorted(datetime.strptime(x, "%Y-%m-%d").date() for x in dates)
    best = run = 1
    for i in range(1, len(ds)):
        if (ds[i] - ds[i-1]).days == 1:
            run += 1
            best = max(best, run)
        else:
            run = 1
    return best

def hour_sum(hs):
    return sum((hours.get(str(h)) or 0) for h in hs)

# --- history.jsonl aggregates (distinct slash commands, distinct projects) ---
distinct_cmds = set()
distinct_projects = set()
try:
    with open(history_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                h = json.loads(line)
            except Exception:
                continue
            disp = (h.get("display") or "").strip()
            if disp:
                tok = disp.split()[0]
                if SLASH_CMD.match(tok):
                    distinct_cmds.add(tok)
            proj = h.get("project")
            if proj:
                distinct_projects.add(proj)
except Exception:
    pass

dates = active_dates()
streak = longest_run(dates)

# firstSession -> latest active date span in days
span_days = None
try:
    fs = stats.get("firstSessionDate")
    if fs and dates:
        fsd = datetime.fromisoformat(fs.replace("Z", "+00:00")).date()
        last = max(datetime.strptime(x, "%Y-%m-%d").date() for x in dates)
        span_days = (last - fsd).days
except Exception:
    span_days = None

def ge(v, n):
    return v is not None and v >= n

# Each entry: id -> bool. Mirrors achievements.md. Only conditions that are
# cheaply and exactly computable here are judged; the command does the full set.
judged = {}
judged["first-steps"] = ge(total_sessions, 1)
judged["regular"] = ge(total_sessions, 50)
judged["veteran"] = ge(total_sessions, 200)
judged["centurion"] = ge(total_messages, 10000)
judged["myriad"] = ge(total_messages, 40000)
judged["marathon"] = ge(longest.get("duration"), 3600000)
judged["ultramarathon"] = ge(longest.get("duration"), 21600000)
judged["dialogue-master"] = ge(longest.get("messageCount"), 500)
judged["productive-day"] = any((d.get("messageCount") or 0) >= 1000 for d in daily)
judged["tool-storm"] = any((d.get("toolCallCount") or 0) >= 500 for d in daily)
judged["tireless"] = any((d.get("sessionCount") or 0) >= 20 for d in daily)
judged["three-day-streak"] = streak >= 3
judged["week-streak"] = streak >= 7
judged["seasoned"] = ge(span_days, 90)
judged["night-owl"] = hour_sum([0, 1, 2, 3, 4]) > 0
judged["deep-night-regular"] = hour_sum([0, 1, 2, 3, 4]) >= 20
judged["dawn-riser"] = hour_sum([5, 6, 7]) > 0
judged["round-the-clock"] = sum(1 for h in range(24) if (hours.get(str(h)) or 0) > 0) >= 20
judged["command-curious"] = len(distinct_cmds) >= 5
judged["command-connoisseur"] = len(distinct_cmds) >= 15
judged["many-worlds"] = len(distinct_projects) >= 10
judged["model-explorer"] = len(model_usage) >= 2

now_ids = {k for k, v in judged.items() if v}

# Human-readable titles for the greeting (kept in sync with achievements.md).
titles = {
    "first-steps": "はじめの一歩", "regular": "常連", "veteran": "熟練者",
    "centurion": "百戦錬磨", "myriad": "万の言葉", "marathon": "マラソンセッション",
    "ultramarathon": "ウルトラマラソン", "dialogue-master": "対話の達人",
    "productive-day": "実りある一日", "tool-storm": "ツールの嵐", "tireless": "不眠不休",
    "three-day-streak": "三日坊主返上", "week-streak": "七日連続",
    "seasoned": "季節をまたぐ者", "night-owl": "夜ふかしの徒",
    "deep-night-regular": "常夜の住人", "dawn-riser": "朝駆けの者",
    "round-the-clock": "不夜城", "command-curious": "コマンド探検家",
    "command-connoisseur": "コマンド通", "many-worlds": "多元世界の渡り",
    "model-explorer": "モデル遍歴",
}

# --- merge with saved state -------------------------------------------------
state = load_json(state_path)
if not isinstance(state, dict):
    state = {}
saved = state.get("unlocked")
if not isinstance(saved, dict):
    saved = {}

first_run = len(saved) == 0
newly = [i for i in now_ids if i not in saved]

now_iso = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
merged = dict(saved)
for i in now_ids:
    merged.setdefault(i, now_iso)

state["version"] = 1
state["unlocked"] = merged
state["lastCheckedDate"] = date.today().isoformat()

# Persist the merged state (best-effort; failure must not break the session).
try:
    os.makedirs(os.path.dirname(state_path), exist_ok=True)
    with open(state_path, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
except Exception:
    pass

# On the very first run there is no prior baseline, so everything would look
# "new" — that is not a delta worth interrupting the session for. Greet only on
# genuine deltas against an existing record.
if first_run or not newly:
    print("")
else:
    print(" / ".join(titles.get(i, i) for i in newly))
PY
)"

# Nothing newly unlocked (or first run) -> silence.
[ -n "$newly" ] || exit 0

# Ask the session, once and quietly, to congratulate. additionalContext is
# supplementary; it must not derail whatever the user came to do.
python3 - "$newly" <<'PY'
import sys, json
newly = sys.argv[1]
msg = (
    "claude-rpg: the user just newly unlocked achievement(s) from their real "
    "usage stats: " + newly + ". In one short, warm Japanese line, congratulate "
    "them and name the achievement(s). Do not show a full status card here and "
    "do not interrupt the user's task — mention /claude-rpg:status only if it "
    "fits naturally. Keep it to a single line."
)
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": msg
    }
}))
PY

exit 0
