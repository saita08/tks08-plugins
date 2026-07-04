# Fortune logic

The fortune is a mirror, not a die. Every part of the draw is derived from the
user's real recent usage data, and every part must be able to point back to the
number that produced it. This file defines how the three parts are computed. If
you cannot back a claim with data, do not make it.

Data sources (same as the rest of Claude Code stats):

- `~/.claude/stats-cache.json` — `dailyActivity[]` (`date`, `messageCount`,
  `sessionCount`, `toolCallCount`), `hourCounts`, `longestSession`,
  `totalSessions`, `firstSessionDate`.
- `~/.claude/history.jsonl` — one object per prompt: `display`, `timestamp` (ms
  epoch), `project`, `sessionId`.

"Recent" means the most recent activity present in the data, working backward
from the latest recorded date. It does not mean literally yesterday if the data
does not reach yesterday — read what is actually there and describe it in those
terms ("直近の稼働" not "昨日" unless the data really is yesterday's).

## Part A — 今日の運勢 (the fortune grade)

Grade is one of 大吉 / 中吉 / 小吉 / 末吉 / 凶, chosen from signals about how
healthy and sustainable the recent rhythm looks. The point is a gentle nudge
toward balance, so a frantic recent pace leans toward caution and a steady one
leans auspicious. Read these signals from the data:

1. **Rhythm** — the recent daily `messageCount` values. A wildly spiking day
   (far above the user's own recent typical) suggests overreach; a steady band
   suggests balance. Compare recent days to the user's own median, not an
   absolute.
2. **Rest** — gaps between active dates. Working every single recent day with no
   gap leans toward a caution grade (burnout risk); a recent day off leans
   auspicious (rested).
3. **Late nights** — recent `hourCounts` weight in hours 0–4. Heavy deep-night
   weight leans toward caution.
4. **Intensity** — recent `toolCallCount` and `sessionCount` relative to the
   user's own recent norm. A huge outlier leans caution.

Combine them by judgment, not a rigid formula — but the grade you choose MUST be
justifiable by naming which signals drove it. A cautious grade (凶/末吉) is not
a punishment; frame it as the mikuji advising rest or focus. An auspicious grade
(大吉/中吉) rewards a balanced, sustainable recent rhythm. When the signals are
mixed or middling, 小吉 is the honest center. Never pick a grade you cannot tie
to a signal.

The **戒め (the day's caution)** in Part C carries the reasoning; the grade is
its headline.

## Part B — ラッキーコマンド (the lucky command)

Pick one slash command the user **owns but has not run recently**, and offer it
as today's lucky command — a nudge to rediscover something they have.

- The pool of "owned" commands: the distinct slash commands that appear in
  `history.jsonl` at all. This is the honest definition of "commands they have"
  from the data available — a command they have used at least once is provably
  theirs.
- Identifying a real slash command is stricter than "the display starts with a
  slash". A submitted prompt often begins with a `/` that is a file path
  (`/Users/...`, `/etc/...`) or ordinary text, and those are NOT commands. Count
  a token as a slash command only when it matches the shape of one: a leading
  `/`, then a name of letters, digits, and hyphens, optionally with one
  `plugin:` namespace segment (e.g. `/clear`, `/code-review:code-review`), and
  no path separators, spaces, or dots inside it. Concretely, keep only first
  tokens matching `^/[A-Za-z0-9-]+(:[A-Za-z0-9-]+)?$`; discard anything with a
  second `/`, a space, or a `.`. Offering a file path as a "lucky command" is
  precisely the lie-dressed-as-luck this plugin forbids, so this filter is not
  optional.
- "Not recently": rank owned commands by how long ago they last appeared
  (max `timestamp` per command). Pick from the least-recently-used end.
- If several qualify, choose the one whose reappearance would be a pleasant
  surprise, but you must be able to say when it was last used ("最後に使ったの
  は N 日前") — that recency is the data backing.
- If the history has too few distinct commands to make a meaningful pick (fewer
  than 2 owned commands), say so honestly and skip Part B rather than inventing
  a command the user may not have.

Do not recommend a command the user has never run — the lucky command must come
from their own history, or it is a lie dressed as luck.

## Part C — 本日の戒め (the day's caution)

One sentence of counsel, in mikuji register, **derived from an actual recent
pattern** and stating the pattern as its grounds. This is the soul of the
plugin: the fortune is a reflection wearing a fortune's clothes. Examples of the
shape (derive your own from the real data, do not reuse these verbatim):

- If recent days show many agent/subagent launches or a spike in tool calls:
  a caution about 多重召喚 (spawning too much), grounded in the count.
- If deep-night hours dominate recent activity: a caution about 夜の深追い,
  grounded in the late-hour weight.
- If one project dominates recent `history.jsonl`: a caution about 視野狭窄 /
  a nudge to look up, grounded in the concentration.
- If sessions are very long recently (`longestSession` or recent message
  spikes): a caution about 長考のしすぎ / remembering to commit and rest.
- If the recent rhythm is healthy and varied: an auspicious 戒め that affirms
  the balance rather than warning — honesty cuts both ways.

The caution must name the real pattern it came from ("直近はエージェント起動が
目立ちました" / "昨日のツール呼び出しは普段の約3倍でした"). A caution with no
data behind it is exactly the random-fortune failure this plugin exists to
avoid.

## The blank mikuji (no data)

If neither data source is readable, or the data is empty, do not draw a fortune.
Present a **白紙のみくじ** (a blank mikuji): explain honestly that there is no
record yet to divine from, that a fortune here would be pure invention, and
invite the user to come back once they have some history. This is the honest
face of the plugin — a fortune-teller who admits when the cup is empty is worth
more than one who always has an answer.
