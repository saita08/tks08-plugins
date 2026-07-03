#!/usr/bin/env bash
# handoff-bottle SessionStart hook.
#
# On session start, look for a handoff bottle in the project. If one exists,
# print its most recent bottle to stdout so it is injected as context for the
# new session, with a one-line note that this is a carried-over handoff so the
# session (and the user) knows where it came from. If there is no bottle, print
# nothing and exit 0 — silence is the common case and must stay cheap.
#
# stdout from a SessionStart hook is added to the session's context. This hook
# emits plain text, not a JSON decision block: a bottle is context to read, not
# a verdict to enforce.

set -euo pipefail

# --- Locate the bottle -----------------------------------------------------
# The project dir is where the session runs. CLAUDE_PROJECT_DIR is set by the
# harness for session hooks; fall back to the current directory if not.
project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
bottle="$project_dir/.claude/handoff-bottle.local.md"

[ -f "$bottle" ] || exit 0

# --- Extract the most recent bottle ----------------------------------------
# Bottles are stacked newest-first under "## 瓶 <timestamp>" headings, below a
# YAML frontmatter block and an intro paragraph. Print from the first bottle
# heading up to (but not including) the second one — that is the latest bottle.
latest="$(
  awk '
    /^## 瓶 / { count++ }
    count == 1 { print }
    count == 2 { exit }
  ' "$bottle"
)"

# No bottle heading found -> nothing to inject.
[ -n "$latest" ] || exit 0

# --- Inject it as carried-over context -------------------------------------
printf '%s\n' "前回のセッションから引き継ぎの瓶が届いています（handoff-bottle が注入しました）。以下は前回セッションが書き残した状態・決定・次の一歩です。今回の作業の出発点として踏まえてください。ユーザーの今回の依頼が瓶の内容と食い違う場合は、ユーザーの依頼を優先します。

---
$latest
---

（この引き継ぎは .claude/handoff-bottle.local.md から読み込みました。新しい瓶は /handoff-bottle:write で書けます。）"

exit 0
