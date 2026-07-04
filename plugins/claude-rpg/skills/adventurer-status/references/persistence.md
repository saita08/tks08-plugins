# Persistence

Unlocked achievements are saved so that "newly unlocked since last time" is
meaningful and the SessionStart hook has something to compare against.

## Location and format

File: `~/.claude/claude-rpg/achievements.json`. Create the directory if absent.
It is machine state read by both this skill and the hook, so JSON is the right
format here (not Markdown). Keep it small and human-inspectable:

```json
{
  "version": 1,
  "unlocked": {
    "first-steps":  "2026-07-04T09:00:00Z",
    "night-owl":    "2026-07-04T09:00:00Z"
  },
  "lastCheckedDate": "2026-07-04"
}
```

- `unlocked` maps achievement `id` to the ISO timestamp it was first recorded
  as unlocked. Once an id is present, never remove it — an earned achievement
  stays earned even if later data is trimmed. This also makes unlocking
  monotonic, so a truncated `dailyActivity` can never revoke a real feat.
- `lastCheckedDate` is the calendar date of the last full judge, so the hook can
  cheaply decide whether to re-judge.

## The read / judge / merge / write cycle

1. Read the existing file if present. An absent or unparseable file is treated
   as an empty unlocked set — never an error that stops the status display.
2. Judge every achievement from the current data (see `achievements.md`).
3. The set to save is the **union** of the previously-unlocked ids and the
   newly-judged ones. Union, never overwrite: judging is monotonic.
4. The **newly unlocked** set is (judged-now) minus (previously-saved). That set
   is what the display's "新たに解除!" section and the hook's greeting use.
5. Write the merged file back, preserving original timestamps for ids that were
   already present and stamping `now` for the new ones.

## Failure is silent, not fatal

If the home directory is not writable, or the write fails, still show the status
from the in-memory judgment. Persistence is a convenience for tracking deltas,
not a precondition for the feature. Report the save failure in one plain line at
most; do not turn it into an error that derails the adventurer's card.
