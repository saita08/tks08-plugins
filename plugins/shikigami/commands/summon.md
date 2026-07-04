---
description: Conjure one autonomous routine — a shikigami — through a short dialogue: pick its duty, its schedule, confirm its safety fences, and register it with the machine's scheduler.
argument-hint: "[務めの一言（省略可。夜間巡回・週次収穫・朝の定点報告など）]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, ToolSearch, CronCreate, CronList
---

# Summon a Shikigami

Conjure exactly one shikigami — a scheduled, autonomous routine that runs when the user is away and reports back every time. This command shapes one familiar through dialogue, confirms it will do nothing irreversible, and binds it to the scheduler. Summon one at a time; a batch of familiars conjured without deliberation is a batch the user cannot reason about.

Read `${CLAUDE_PLUGIN_ROOT}/skills/shikigami-craft/references/discipline.md` before conjuring anything — it is the code every shikigami is bound by, and the fences in step 3 come from it. Read `${CLAUDE_PLUGIN_ROOT}/skills/shikigami-craft/references/routines.md` for the duty templates offered in step 1.

## Step 1 — Choose the duty

Offer the user the templates from `routines.md` — the nightly sweep of every repository, the weekly retrospective harvest, the morning fixed-point report, the watch kept on a URL or a repository — or let them describe a duty of their own. Whichever they pick, write the duty down as a concrete, self-contained instruction: what the shikigami looks at, what it does with what it finds, and where the boundary of that work lies. A duty stated vaguely becomes a shikigami that wanders.

Every duty carries a token budget. Name it here — an upper bound on how much work one firing may spend — so a single run cannot expand without limit. The budget is part of the duty, not an afterthought.

## Step 2 — Set the schedule

Decide how often the shikigami wakes and at what local time. Translate it into a standard five-field cron expression. When the user's timing is approximate, nudge the minute off the :00 and :30 marks so many familiars across many machines do not all wake at the same instant.

## Step 3 — Confirm the fences

Walk the user through the code in `discipline.md` and confirm this shikigami honors it, in plain language:

- It takes no irreversible action. What it finds, it reports as a proposal; execution waits for the user's approval on their next visit.
- It stays inside its duty and its token budget.
- It writes a report every single time it runs, because a familiar whose work is never seen is no familiar at all.
- It can be dismissed at any moment with `/shikigami:dismiss`.
- If it has nothing new to say run after run, it proposes its own dismissal rather than repeating itself into wallpaper.

Do not proceed to registration until the user confirms the fences hold. This confirmation is the gate: it is where the user, not the tool, decides that this autonomous routine is safe to let loose.

## Step 4 — Find the scheduler

A shikigami is not magic; it is a cron job. Whether this environment can run one on a real schedule depends on what scheduling machinery is present. Discover it rather than assuming:

- Search for a scheduling tool with `ToolSearch` — query for `cron` and for `schedule`. If a `CronCreate`-style tool or a `/schedule` skill is available, that is the scheduler.
- If a scheduler is found, register the firing there: the cron expression from step 2, and a prompt that tells the woken session to load its duty from the register (below) and to obey `discipline.md`. Capture whatever job id or handle the scheduler returns, so `/shikigami:dismiss` can later remove it.
- If no scheduler is found, stop honestly. Do not pretend the shikigami is running. Tell the user plainly that this environment has no scheduling mechanism the command can reach, record the shikigami in the register as **dormant**, and give them the cron expression and duty prompt so they can register it by hand with whatever scheduler they do have (a system crontab, a CI schedule, a cloud routine). A dormant shikigami honestly labeled is worth more than a running one falsely claimed.

Be honest about a further limit: some schedulers are session-scoped — the routine lives only while this Claude session is alive and is gone when it exits, and may auto-expire after a fixed span. If the scheduler you find is one of these, say so, because a user who believes a familiar is standing guard for weeks when it vanishes at session end has been misled. Record what you learned about the scheduler's persistence in the register so `/shikigami:muster` can repeat it.

## Step 5 — Enter it in the register

Append the shikigami to `~/.claude/shikigami/register.md` (create the file and its parent directory if absent). Record its name, its duty, its schedule, its token budget, its report destination, the scheduler handle (or `dormant` with the hand-off cron line), and what is known about the scheduler's persistence. The register is the shared memory of which familiars exist; a shikigami that runs but is not written here cannot be mustered or dismissed.

Each shikigami reports to `~/.claude/shikigami/reports/<name>.md`, appending a dated entry every run. Create the reports directory now so the first firing has somewhere to write.

## Step 6 — Hand over

Tell the user what was conjured: the shikigami's name, its duty, when it will next wake, where it will report, and — stated plainly — whether it is truly scheduled or dormant awaiting their hand-off. Do not commit anything; the user reviews their own machine.
