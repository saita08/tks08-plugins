---
description: Dismiss a shikigami — remove its schedule from the scheduler and strike it from the register, so a familiar that is no longer wanted stops running.
argument-hint: "<解任する式神の名>"
allowed-tools: Read, Glob, Grep, Bash, Edit, ToolSearch, CronDelete, CronList
---

# Dismiss a Shikigami

Release a familiar from duty. Dismissal must be complete: a shikigami struck from the register but still firing on the scheduler is a ghost that works unseen, and one removed from the scheduler but left in the register misleads every future muster. Both halves move together, or the dismissal is not done.

## Step 1 — Find the shikigami

Read `~/.claude/shikigami/register.md` and locate the shikigami named in `$ARGUMENTS`. If no name was given, list the familiars on the register and ask which one to dismiss — do not guess. If the named shikigami is not on the register, say so and stop; there is nothing to dismiss.

## Step 2 — Remove its schedule

Read the shikigami's scheduler handle from its register entry.

- If it holds a scheduler job id or handle, remove that firing. Find the scheduler's deletion tool with `ToolSearch` — query for `cron` and for `schedule` — and use it to cancel the job by its handle. Confirm the removal succeeded.
- If the shikigami is recorded as **dormant** (it was never registered with a reachable scheduler, only handed off for manual registration), there is nothing for this command to cancel. Tell the user plainly that if they registered it by hand with some other scheduler, they must remove it there themselves — this command cannot reach a scheduler it never wrote to.

## Step 3 — Strike it from the register

Remove the shikigami's entry from `~/.claude/shikigami/register.md`. Leave its report file at `~/.claude/shikigami/reports/<name>.md` in place; it is the record of what the familiar did while it served, and a dismissal is not a reason to erase history. Tell the user the report remains and where it is, in case they want to keep or clear it themselves.

## Step 4 — Confirm

Tell the user the shikigami is dismissed: its schedule cancelled (or, if dormant, that there was none to cancel and what they must do by hand), and its entry struck from the register. Do not commit anything; the user reviews their own machine.
