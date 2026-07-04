# Duties a Shikigami Can Be Given

A shikigami is only as good as the duty it carries. This file offers a handful of proven duties to conjure from, and — more important than any single template — the shape that makes a duty good. Adapt these to the master's world; they are starting points, not a menu to be read verbatim.

## What makes a duty good

A good duty is concrete, bounded, and reporting-shaped.

Concrete means the familiar knows exactly what it looks at and what it produces. "Watch the project" is not a duty; "read the last day of commits on the main branch of these three repositories and note any that touch the release configuration" is. The vaguer the charge, the more the familiar improvises, and improvisation unwatched is the thing the fences exist to prevent.

Bounded means the duty names where it stops. A firing has a token budget and a scope, and a good duty fits inside both with room to spare. A duty that can only be done by reading an entire monorepo is not bounded; narrow it to the part that actually matters, or split it across several familiars with narrower charges.

Reporting-shaped means the duty's output is naturally something the master reads and acts on, not something the familiar is tempted to act on itself. A duty phrased as "find X and fix it" pulls against the first fence; the same duty phrased as "find X and report it with a proposed fix" sits comfortably inside the code. Write duties as the second kind.

A good duty also earns its schedule. A familiar that would file an identical report every morning because nothing it watches changes daily is mis-scheduled, not useful; match the firing frequency to how often the watched thing actually moves.

## Template — the nightly sweep

Wakes once a night. Reads recent activity across a named set of repositories — new commits, opened issues, failing checks, dependency alerts — and files a single digest of what changed and what, if anything, looks like it wants the master's attention in the morning. Proposes; never acts. Its budget is set so it skims rather than deeply analyzing every change; anything that warrants a deep look is flagged for the master to pull on, not chased down in the dark.

## Template — the weekly retrospective harvest

Wakes once a week. Gathers the week's finished work from wherever it accumulates — merged pull requests, closed issues, the week's notes — and drafts a retrospective: what shipped, what recurred, what patterns are worth naming. Files it as a draft the master edits, never as a published summary. This familiar's value is that it does the tedious gathering so the master arrives at the thinking already holding the material.

## Template — the morning fixed-point report

Wakes early each working day. Reports a fixed set of vital signs the master wants to see before starting — the state of the main branch, open review requests waiting on them, the day's calendar if reachable, anything overdue. The value is constancy: the same fixed points, at the same time, so a change stands out against a familiar baseline. This familiar must guard hard against the wallpaper trap — a fixed-point report that says the same thing every day is exactly the kind that trains its reader to stop looking — so it leads with what differs from yesterday and states the all-clear briefly.

## Template — the watch

Wakes on a schedule to check one specific thing for change — a URL, a repository, a file, a status page — and reports only when it has moved, or reports the all-clear briefly when it has not. A watch is the familiar most prone to going stale, because most of the time nothing changes. Bind it tightly: it should speak loudly when the watched thing moves and be nearly silent when it does not, and it should propose its own dismissal when the thing it watches has been still for long enough that the watch has stopped earning its firings.

## Writing a duty of the master's own

When the master describes a duty not covered here, hold it against the three properties above before conjuring it. If it is not concrete, ask what exactly the familiar looks at and produces. If it is not bounded, find where it stops. If it is shaped to act rather than report, rephrase it until its output is a proposal the master reads. A duty that cannot be made to fit all three is a duty that does not belong to a shikigami — it belongs to the master, in the light, where irreversible work is safe to do.
