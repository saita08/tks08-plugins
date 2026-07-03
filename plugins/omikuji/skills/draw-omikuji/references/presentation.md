# Presentation and the once-per-day guard

## The mikuji form

Present the draw in the shape of a paper fortune (おみくじ), in Japanese, in
this order:

1. A header line naming it as today's mikuji with the date, e.g.
   `── 本日のみくじ（2026-07-04）──`.
2. **運勢: <grade>** — the fortune grade (大吉 / 中吉 / 小吉 / 末吉 / 凶) on its
   own line, prominent.
3. **ラッキーコマンド: <command>** — with the one-line reason (when it was last
   used). Omit this block entirely if Part B was skipped for lack of data.
4. **本日の戒め:** — the one-sentence caution, in mikuji register.
5. A closing line that quietly names the data the draw rested on, so the user
   can see it was a reflection, not a die — e.g.
   `（直近 N 日の記録より）`. This is not decoration; it is the receipt that the
   fortune was earned from real data.

Keep the whole thing short — a mikuji is a slip of paper, not an essay. The
register is a little archaic and ritual, but never ominous: even 凶 is framed as
advice to rest or focus, not doom.

Every visible claim must be traceable to a number you read. The closing receipt
line and the caution's grounding are what make that visible; do not drop them.

## The once-per-day guard

A mikuji drawn twice is not a mikuji. The draw is recorded so a second draw the
same day is refused.

- State file: `~/.claude/omikuji/last-draw`. Create the directory if needed.
- Contents: a small record of the last draw — at minimum the date (`YYYY-MM-DD`,
  the user's local date) and the grade drawn. Human-readable is preferred; a
  single line like `2026-07-04 中吉` is enough, or small JSON if you prefer.
- Before drawing: read the file. If its date equals today's local date, do NOT
  draw again. Instead reply, in the same gentle register, that today's mikuji
  has already been drawn — and it is kind to remind them what it said
  (`本日はもう引いています。今朝のみくじは「中吉」でした。`). Reading back the
  recorded grade turns the refusal into a small courtesy rather than a wall.
- After a successful draw: write today's date and the drawn grade to the file.
- If the file cannot be read or written (home not writable), degrade gracefully:
  a read failure is treated as "not yet drawn today"; a write failure means the
  guard cannot persist, so mention in one line that the once-a-day guard could
  not be saved, and still show the fortune. Never turn a guard failure into an
  error that swallows the draw.

The guard keys on the user's **local** calendar date, because "today" is a
human, local notion — the ritual is a morning one.
