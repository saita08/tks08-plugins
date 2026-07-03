---
description: Check whether the source institution has changed since each target was last translated, and report which foreign-service versions need re-drafting.
argument-hint: "[原本ファイルのパス（省略時は記録された全原本）]"
allowed-tools: Read, Glob, Bash
---

# Embassy Diff

Tell the user which translated versions have fallen behind the source. When a personal constitution is revised, every foreign-service version drafted from it becomes stale — but silently, because nothing links them. This command surfaces that staleness so the user knows which embassies to re-brief.

Read `${CLAUDE_PLUGIN_ROOT}/skills/faithful-translation/references/state-format.md` for the shape of the state file before reading it.

## 1. Load the translation state

Read `~/.claude/embassy/state.json`. It records, per (source, target) pair, the source path, the output path, and a hash of the source content as it stood when that target was last drafted. If the file is missing or empty, there is nothing to compare — say so and point the user at `/embassy:draft` to create the first translation.

If `$ARGUMENTS` names a source path, restrict the check to that source; otherwise check every source recorded in the state.

## 2. Compare the current source against the recorded hash

For each recorded (source, target) pair, hash the source file as it stands now and compare it to the hash stored at last translation. Two outcomes:

- **Current** — the hashes match. The source has not changed since this target was drafted. No action.
- **Stale** — the hashes differ. The source has been revised since this target was last translated, so the target's version no longer reflects the current institution and should be re-drafted.

Compute the hash the same way `/embassy:draft` records it; `state-format.md` specifies which hash and over what content, so the two commands agree.

## 3. Report which embassies need re-briefing

List each target and whether its translation is current or stale. For the stale ones, give the user the exact command to refresh each: `/embassy:draft <target> <source>`. If a recorded source file no longer exists at its path, flag it separately — the state points at something that moved or was deleted, and the user should decide whether to re-point or prune the entry.

Lead with the count: how many translations are stale out of how many recorded.

## Constraints

- This command only reads and compares. It does not re-translate; it reports what needs re-translating and hands the user the command to do it. Re-drafting is `/embassy:draft`'s job, and keeping the two separate lets the user choose which targets to refresh.
- Never transmit anything anywhere. Like every part of embassy, this command works entirely on local files.
- Do not modify the state file. Recording new translation state is `/embassy:draft`'s responsibility; diff is read-only against it.
