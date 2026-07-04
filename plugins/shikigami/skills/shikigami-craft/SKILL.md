---
name: shikigami-craft
description: This skill should be used when the user wants a Claude Code routine that runs on a schedule while they are away — a recurring automated task, a nightly or weekly agent, a scheduled watch on a repository or URL — or asks "式神を作りたい", "常駐で回したい", "自動で夜間に走らせたい", "定期的にレポートさせたい", or when Claude is about to set up scheduled autonomous work and must know the fences that keep it safe. Carries the shikigami discipline and the duty templates behind the summon, muster, and dismiss commands.
allowed-tools: Read, Glob, Grep
---

# The Craft of the Shikigami

A shikigami is a familiar — a scheduled, autonomous Claude routine that carries out a duty when its master is not watching, and reports back every time it wakes. The onmyoji does not do the night's rounds himself; he sends a paper familiar and reads its report in the morning. This skill carries what a shikigami is bound by and what duties it can be given. Consult the reference that fits the task rather than loading both.

- `references/discipline.md` — the code every shikigami is bound by: no irreversible action, a duty and a token budget, the obligation to report, dismissal on demand, and self-dismissal when it has nothing new to say. Read before conjuring a familiar or when judging whether a proposed duty is safe to let loose.
- `references/routines.md` — the duty templates a shikigami can be given, and the shape of a good duty. Read when helping the user choose or write what their familiar will do.

Three commands drive this skill. `/shikigami:summon` conjures one familiar through dialogue and binds it to the scheduler, `/shikigami:muster` calls the roll and shows each one's latest report, and `/shikigami:dismiss` releases a familiar from duty. When the user asks in passing what a shikigami may or may not do, answer from `discipline.md` directly without invoking a command.

The one truth that outranks the rest: a shikigami is not magic, it is a cron job. Whether one can truly run on a schedule depends on the scheduling machinery the environment provides, and honesty about that limit is part of the craft. A familiar falsely claimed to be standing guard is worse than none, because the master stops watching a post that no one holds.
