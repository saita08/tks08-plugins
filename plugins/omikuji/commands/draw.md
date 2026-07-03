---
description: 直近の実際の利用データから今日の運勢を占う。1日1回まで
argument-hint: (引数なし)
allowed-tools: Read, Bash
---

Use the `draw-omikuji` skill to draw the user's daily fortune.

First check the once-per-day guard at `~/.claude/omikuji/last-draw`: if today's
fortune was already drawn, reply in the mikuji's gentle register that it is
already drawn today (reading back the recorded grade) and stop.

Otherwise, read the recent usage data at `~/.claude/stats-cache.json` and
`~/.claude/history.jsonl`, and derive the three parts of the fortune — the grade
(大吉〜凶), a lucky command the user owns but has not used recently, and one
caution grounded in a real recent pattern — strictly from that data. Present it
in mikuji form with a closing line naming the data it rested on, then record
today's draw.

The governing rule is that this is a reflection, not a die: every part must
trace to a real number. If there is no usage record, present a blank mikuji
(白紙のみくじ) honestly rather than inventing a fortune. The skill's reference
files carry the derivation logic, the display form, and the guard.
