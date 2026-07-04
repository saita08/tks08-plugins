---
description: Muster the shikigami — list every familiar on active duty and show each one's latest report, so their unseen work becomes visible at a glance.
argument-hint: "[名（省略時は全員を招集）]"
allowed-tools: Read, Glob, Grep
---

# Muster the Shikigami

Call the roll. Show the user which familiars are on duty and what each has done since last seen, so the work that happened while they were away is laid out in front of them. A shikigami's whole justification is that its work is visible; muster is where that promise is kept.

## Step 1 — Read the register

Read `~/.claude/shikigami/register.md`. If it does not exist or holds no familiars, say so plainly — no shikigami have been summoned yet — and point the user to `/shikigami:summon`. Do not invent a roster.

If `$ARGUMENTS` names a shikigami, muster only that one.

## Step 2 — Gather each one's latest report

For every shikigami in the register, read the tail of its report file at `~/.claude/shikigami/reports/<name>.md`. Take the most recent dated entry — that is its latest word. If a familiar has a report file but no entries, note that it has run without reporting, which is itself a finding worth surfacing. If it has no report file at all, note that it has not yet fired.

## Step 3 — Present the roll

For each shikigami, show: its name, its duty in one line, its schedule, whether it is truly scheduled or dormant, and its latest report entry. Lead with anything that wants the user's attention — a proposal a shikigami has raised and is waiting on, a familiar that has gone silent, one that has flagged its own dismissal. A muster that buries the one report that needed action under routine all-clear entries has failed at its one job.

Then stop. Muster reads and reports; it does not act on what the familiars found. Acting on a proposal is the user's move to make, with their approval, after they have seen it.
