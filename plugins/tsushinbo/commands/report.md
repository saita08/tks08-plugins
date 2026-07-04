---
description: Issue the report card — per-subject score trends, the configuration boundaries where the fingerprint changed, and which subjects rose or fell when you altered your setup.
argument-hint: "[科目名（省略時は全科目の通信簿）]"
allowed-tools: Read, Glob, Grep, Bash
---

# Issue the Report Card

Read the grade ledger and turn it into something a person can act on: how each subject has moved over time, where the environment changed, and how the scores responded to those changes. The report card's job is to answer the one question the whole plugin exists for — did that change to my setup actually help, and where?

Read `${CLAUDE_PLUGIN_ROOT}/skills/subject-craft/references/subject-craft.md` if it is not already clear why these grades must be read as trends rather than absolutes. The reference carries the discipline; this command presents the result under it.

## Step 1 — Read the ledger

Read `~/.claude/tsushinbo/grades.jsonl`. If it is absent or empty, say so and point the user to `/tsushinbo:exam`; a report card with no sittings behind it is blank. If `$ARGUMENTS` names subjects, restrict the report to them.

## Step 2 — Trace each subject over time

For each subject, order its sittings by timestamp and show how the score moved. A single point is not a trend; when a subject has only one or two sittings, say so rather than drawing conclusions from noise. The reader should be able to see, per subject, whether it is climbing, sliding, or holding steady within the wobble.

## Step 3 — Mark the configuration boundaries

The environment fingerprint is what makes this more than a chart. Find the points in each subject's history where a fingerprint hash changed — a `CLAUDE.md` edit, a plugin enabled or disabled — and mark them as boundaries. These boundaries are the events the report card is really about: they are the moments the user changed something, and the scores on either side are the before-and-after that says whether the change helped.

## Step 4 — Attribute the movement, carefully

For each boundary, report which subjects rose and which fell across it, so the user can read a configuration change as a set of effects rather than a single verdict — a change that lifts one subject may sink another, and that trade-off is exactly what the report card should expose. Attribute with care: a score that moved by less than the grader's run-to-run wobble has not clearly moved at all, and a boundary with only one sitting on either side is a hint, not a finding. Say which movements are strong enough to believe and which are still noise, rather than dressing every wiggle as a result.

## Step 5 — Present the card

Present, in order: the per-subject trends; the configuration boundaries and what changed at each; and the attributions — which subjects each change appears to have lifted or lowered, with the noisy ones honestly flagged. Lead with the clearest signal the ledger actually supports, and if the ledger is still too thin to support any, say that plainly. A report card that admits it does not yet have enough data serves the user better than one that manufactures a conclusion from three sittings.
