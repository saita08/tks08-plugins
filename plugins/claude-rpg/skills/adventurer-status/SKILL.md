---
name: adventurer-status
description: This skill should be used when the user runs /claude-rpg:status, asks to "show my achievements", "check my adventurer status", "what have I unlocked", "claude rpg", or otherwise wants to see achievements judged from their real Claude Code usage stats. It reads the local usage data, judges each achievement from that data, persists the unlocked set, and displays the adventurer's status card. Never invents data it did not read.
allowed-tools: Read, Bash
---

# Adventurer Status

Turn the user's real Claude Code usage into an achievement log. Read their local
stats, judge each achievement purely from that data, record what is unlocked,
and show a status card. The one rule that governs everything here: **never claim
anything the data does not support.** An unlocked achievement must carry the
real number that earned it. If a data source is missing, say so plainly instead
of unlocking nothing in silence or making a value up.

Read the reference files as you need them; do not load them all up front.

- `references/achievements.md` — the ~20 achievements, each with its exact,
  data-decidable condition and which field it reads. This is the source of
  truth for judging.
- `references/status-display.md` — how to turn the judged set into the rank and
  the status card, including the "closest locked" gaps.
- `references/persistence.md` — the `achievements.json` read/judge/merge/write
  cycle and its silent-failure discipline.

## Procedure

### 1. Locate and read the data

The two sources are `~/.claude/stats-cache.json` and `~/.claude/history.jsonl`.
Read them with the tools available. `stats-cache.json` is small; read it
whole. `history.jsonl` can be large — you only need aggregates from it (distinct
slash commands, distinct projects), so compute those with a small `Bash`
one-liner (`jq`/`python3`/`awk`) rather than loading the entire file.

If **both** sources are missing or unreadable, do not fabricate a status. Tell
the user honestly that no usage record was found — the adventure has not been
recorded yet — and stop. If only one source is present, judge what that source
supports and note that the achievements depending on the missing source cannot
be evaluated this run.

### 2. Judge every achievement

Work through `references/achievements.md` and decide each achievement true or
false from the data you read. For anything requiring a computed value (a
consecutive-day streak, a distinct-command count, a duration in hours), compute
it explicitly from the fields the condition names. Do not approximate a
threshold you could check exactly.

### 3. Merge with the saved set and record

Follow `references/persistence.md`: read the prior `achievements.json`, take the
union with the freshly judged set, determine which are newly unlocked this run,
and write the merged file back. A missing or unwritable file must not stop the
display.

### 4. Show the status card

Render the card per `references/status-display.md`: newly-unlocked callouts
first (if any), then rank, vital stats, unlocked list with evidence, and the
closest locked achievements with their real gaps. Keep it in Japanese to match
the plugin's voice, celebratory but honest.

## Constraints

- Every unlocked line must reference the real value that cleared its bar. No
  generic congratulations without the number behind it.
- Never fabricate, round up past a threshold, or infer a value you did not read
  from the data. Uncertainty is reported, not smoothed over.
- Do not write anywhere except `~/.claude/claude-rpg/achievements.json`. This
  skill reads usage data and records its own unlocked set; it touches nothing
  else on the user's machine.
- Judging is monotonic: never revoke a previously unlocked achievement because
  current data (which may be trimmed) no longer shows the feat.

## Resources

- `references/achievements.md` — the achievement definitions and conditions.
- `references/status-display.md` — rank and status-card presentation.
- `references/persistence.md` — the unlocked-set persistence cycle.
