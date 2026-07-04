# Achievements

Every achievement below is decidable from real usage data alone. The two data
sources are:

- `~/.claude/stats-cache.json` — aggregate stats. Relevant fields:
  - `dailyActivity[]`: `{ date (YYYY-MM-DD), messageCount, sessionCount, toolCallCount }`
  - `totalSessions`, `totalMessages`
  - `longestSession`: `{ duration (ms), messageCount, timestamp }`
  - `firstSessionDate` (ISO 8601)
  - `hourCounts`: map of hour-of-day (`"0"`..`"23"`) to a count
  - `modelUsage`: map of model id to token/usage counts
  - `dailyModelTokens[]`: `{ date, tokensByModel }`
- `~/.claude/history.jsonl` — one JSON object per submitted prompt:
  `{ display, timestamp (ms epoch), project, sessionId, pastedContents }`

A field that is absent in a given install simply means the achievements that
depend on it cannot be judged yet. Do not invent a value to fill a gap. If a
whole data source is missing, report that honestly rather than unlocking
nothing silently — see the skill body.

Each achievement has a stable `id` (never reuse or renumber — the persistence
file keys on it), a title, the exact condition, and the data it reads. The tier
is flavor only; it does not change the logic.

## Session volume

- `first-steps` — Bronze — "はじめの一歩"
  Condition: `totalSessions >= 1`. Reads: `stats.totalSessions`.
  The moment you have any recorded session, the adventure has begun.

- `regular` — Bronze — "常連"
  Condition: `totalSessions >= 50`. Reads: `stats.totalSessions`.

- `veteran` — Silver — "熟練者"
  Condition: `totalSessions >= 200`. Reads: `stats.totalSessions`.

- `centurion` — Silver — "百戦錬磨"
  Condition: sum of `messageCount` across `dailyActivity` (or `totalMessages`
  if present) `>= 10000`. Reads: `stats.totalMessages` or `dailyActivity`.

- `myriad` — Gold — "万の言葉"
  Condition: total messages `>= 40000`. Reads: `stats.totalMessages`.

## Single-session feats

- `marathon` — Silver — "マラソンセッション"
  Condition: `longestSession.duration >= 3600000` (at least one session ran an
  hour or longer). Reads: `stats.longestSession.duration`.

- `ultramarathon` — Gold — "ウルトラマラソン"
  Condition: `longestSession.duration >= 21600000` (six hours or longer).
  Reads: `stats.longestSession.duration`.

- `dialogue-master` — Silver — "対話の達人"
  Condition: `longestSession.messageCount >= 500`. Reads:
  `stats.longestSession.messageCount`.

## Daily intensity

- `productive-day` — Bronze — "実りある一日"
  Condition: some day in `dailyActivity` has `messageCount >= 1000`.
  Reads: `dailyActivity[].messageCount`.

- `tool-storm` — Silver — "ツールの嵐"
  Condition: some day in `dailyActivity` has `toolCallCount >= 500`.
  Reads: `dailyActivity[].toolCallCount`.

- `tireless` — Silver — "不眠不休"
  Condition: some day in `dailyActivity` has `sessionCount >= 20`.
  Reads: `dailyActivity[].sessionCount`.

## Rhythm and streaks

- `three-day-streak` — Bronze — "三日坊主返上"
  Condition: `dailyActivity` contains at least one run of 3 consecutive
  calendar days (each present with `messageCount > 0`). Reads: the set of
  active dates in `dailyActivity`.

- `week-streak` — Gold — "七日連続"
  Condition: a run of 7 consecutive active calendar days exists. Reads: active
  dates in `dailyActivity`.

- `seasoned` — Silver — "季節をまたぐ者"
  Condition: `firstSessionDate` is 90 or more days before the latest active
  date. Reads: `stats.firstSessionDate` and the max date in `dailyActivity`.

## Hours of the day

- `night-owl` — Bronze — "夜ふかしの徒"
  Condition: `hourCounts` shows any activity in hours `0,1,2,3,4` (sum > 0).
  Reads: `stats.hourCounts`.

- `deep-night-regular` — Silver — "常夜の住人"
  Condition: the sum of `hourCounts` for hours `0..4` is `>= 20`.
  Reads: `stats.hourCounts`.

- `dawn-riser` — Bronze — "朝駆けの者"
  Condition: `hourCounts` shows any activity in hours `5,6,7` (sum > 0).
  Reads: `stats.hourCounts`.

- `round-the-clock` — Gold — "不夜城"
  Condition: `hourCounts` has a nonzero count for at least 20 distinct hours of
  the 24. Reads: `stats.hourCounts`.

## Commands and breadth (history.jsonl)

- `command-curious` — Bronze — "コマンド探検家"
  Condition: at least 5 distinct slash commands appear in `history.jsonl`.
  Reads: `history`. A "slash command" is counted strictly, not "starts with a
  slash": the first token of `display` must match `^/[A-Za-z0-9-]+(:[A-Za-z0-9-]+)?$`
  — a leading `/`, a hyphenated name, an optional `plugin:` namespace, and no
  path separators, spaces, or dots. This excludes file paths (`/Users/...`) and
  prose that merely begins with a slash, which would otherwise inflate the count
  and unlock the achievement on something that is not a command.

- `command-connoisseur` — Silver — "コマンド通"
  Condition: at least 15 distinct slash commands appear in `history.jsonl`.
  Reads: `history`.

- `many-worlds` — Silver — "多元世界の渡り"
  Condition: at least 10 distinct `project` paths appear in `history.jsonl`.
  Reads: `history`.

- `model-explorer` — Bronze — "モデル遍歴"
  Condition: at least 2 distinct model ids appear in `modelUsage` (or across
  `dailyModelTokens[].tokensByModel`). Reads: `stats.modelUsage`.

## Notes on judging

- Consecutive-day runs count calendar days, not sessions. A day is "active" if
  it appears in `dailyActivity` with `messageCount > 0`.
- When both `totalMessages` and the `dailyActivity` sum are available and they
  disagree, prefer `totalMessages` — it is the authoritative aggregate; the
  daily list may be truncated.
- Thresholds are deliberately reachable by real, sustained use and not by a
  single trick. If a future data field makes a cleaner condition possible,
  change the condition here rather than working around it in the skill body.
