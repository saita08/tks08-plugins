---
name: draw-omikuji
description: This skill should be used when the user runs /omikuji:draw, asks to "draw a fortune", "draw omikuji", "today's fortune", "占って", "おみくじ", or otherwise wants their daily Claude Code fortune. It divines a fortune grade, a lucky command, and a caution — each derived from the user's real recent usage data, not from randomness — and enforces one draw per day. When there is no usage record, it honestly presents a blank mikuji rather than inventing a fortune.
allowed-tools: Read, Bash
---

# Draw Omikuji

Draw the user's daily fortune for their Claude Code work. The defining rule:
this is not a random fortune. Every part of the draw is **derived from the
user's real recent usage data**, and every part must carry the number that
produced it. A fortune with no data behind it is exactly what this plugin exists
not to be. It is a reflection wearing a fortune's clothes.

Read the reference files as you need them; do not load them all up front.

- `references/fortune-logic.md` — how to compute the three parts (fortune grade,
  lucky command, caution) from the data, and the blank-mikuji fallback when
  there is no data. This is the core.
- `references/presentation.md` — the mikuji display form and the once-per-day
  guard at `~/.claude/omikuji/last-draw`.

## Procedure

### 1. Check the once-per-day guard first

Before anything else, read `~/.claude/omikuji/last-draw` per
`references/presentation.md`. If it records today's local date, do not draw
again — reply in the mikuji's gentle register that today's fortune is already
drawn, reading back the recorded grade as a courtesy, and stop. A missing or
unreadable guard file means "not drawn yet today"; proceed.

### 2. Read the recent usage data

Read `~/.claude/stats-cache.json` (small; read whole) and aggregate what you
need from `~/.claude/history.jsonl` (potentially large; use a small `Bash`
one-liner with `jq`/`python3`/`awk` for the per-command last-used times and
distinct projects rather than loading the whole file).

If **neither** source is readable or the data is empty, present the **白紙の
みくじ** (blank mikuji) from `references/fortune-logic.md` and stop. Do not draw
a fortune from nothing.

### 3. Derive the three parts

Follow `references/fortune-logic.md`:

- **運勢 (grade)** — from the recent-rhythm signals; you must be able to name
  which signals drove the grade.
- **ラッキーコマンド** — a command the user owns (appears in their history) but
  has not run recently; you must be able to say when it was last used. Skip this
  part honestly if the history is too thin.
- **本日の戒め** — one sentence of counsel derived from an actual recent
  pattern, stating that pattern as its grounds.

Each part must trace back to a real number. If you cannot ground a part, drop it
rather than inventing.

### 4. Present the mikuji and record the draw

Render the fortune in the mikuji form from `references/presentation.md`,
including the closing "receipt" line naming the data the draw rested on. Then
write today's local date and the drawn grade to `~/.claude/omikuji/last-draw`.
A write failure is mentioned in one line but does not swallow the fortune.

## Constraints

- Never fabricate a fortune, a lucky command, or a caution that the data does
  not support. Randomness dressed as divination is the one thing this plugin
  must not do.
- Every visible claim traces to a real number the user could verify. The
  caution's grounding and the closing receipt line make that traceability
  visible; keep them.
- Enforce one draw per local calendar day. Reading back the prior grade turns
  the refusal into a courtesy.
- Do not write anywhere except `~/.claude/omikuji/last-draw`.
- There is no hook. Drawing the mikuji is a deliberate act the user performs;
  that deliberateness is what makes it a ritual.

## Resources

- `references/fortune-logic.md` — deriving the three parts from data; blank-mikuji fallback.
- `references/presentation.md` — the mikuji form and the once-per-day guard.
