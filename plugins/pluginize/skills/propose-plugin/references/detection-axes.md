# What Is Worth Turning Into a Plugin

This document explains how to judge whether something that happened during a session is worth proposing as a plugin. It is the shared source of truth for two readers: the observation hook (`hooks/detect.sh`), which decides whether to surface a candidate at all, and the proposal skill (`SKILL.md`), which decides what to say about a candidate once the user is looking at it. Both should reason from the same criteria, so that what the hook raises and what the skill explains never contradict each other.

It is not a checklist. It is the reasoning behind the judgment, written so that the right call can be made in a situation these words did not anticipate.

## Cast the net wide; let rejection do the filtering

The cost structure of this work is asymmetric. A candidate that is surfaced and then declined costs the user a moment of attention. A candidate that is never surfaced costs them the entire benefit of a plugin they would have wanted — silently, with no way to know it was missed. So the observation side should err toward raising things, and the filtering should live in the user's accept-or-decline, not in a narrow detector that only fires when it is certain.

This is why the axes below are joined by "any one of," not "all of." A fragment of work that scores on a single axis is already worth a glance. Demanding that it score on all of them would push the filter back into detection, which is exactly where it does not belong.

The asymmetry has a boundary, and the boundary is the credibility of the channel itself. A declined candidate costs "a moment of attention" only while proposals are rare enough to be read; a detector that speaks at every other break trains the user to stop reading it, and once the channel is ignored, every future true positive is lost as surely as if it had never been raised. Two disciplines keep the net wide without crossing that line. First, a candidate is raised on evidence visible in the work — an axis must have actually shown itself, not merely be conceivable — because almost any substantive work is *plausibly* reusable, and a filter that passes almost everything is not a filter. Second, a session gets at most one proposal: a candidate the user has let pass does not return at the next break wearing the same clothes.

## The three axes (the recurring signals)

Three properties of a piece of work tend to mark it as reusable. Any one of them is enough to make it a candidate.

**Repeatability.** The same shape of work has shown up before, or plainly will again — across sessions, across projects, across people. Repetition is the clearest signal that encoding the work once will pay for itself many times.

**Crystallization of procedure.** A sequence of steps has settled into a definite order that matters: do this, then that, check this before proceeding. When a procedure has hardened to the point where the steps and their order carry the value, writing them down stops them from being rediscovered or skipped each time.

**Tacit knowledge.** The work depended on something that was not obvious and is not written down anywhere the next person would find it — a non-intuitive technique, a hard-won workaround, a piece of judgment that took effort to acquire. The less discoverable it was, the more value there is in capturing it.

## The foundation: is this worth making reusable at all?

Before asking what *form* a reusable artifact should take, ask whether the work is the kind of thing worth capturing in the first place. This judgment operates at the level of a single technique or piece of knowledge, and it borrows directly from established practice on when to write a reusable skill.

Lean toward capturing when:

- The technique was not intuitively obvious — someone had to figure it out.
- It would be referenced again across projects, not just this one.
- It applies broadly rather than to one specific situation.
- Someone other than the author would benefit from it.

Lean away from capturing when:

- It was carried out by running an existing command, skill, or plugin. This is the most seductive false positive, because such work displays every mark of reusable structure — it is procedural, it recurs, it was designed to. But the structure is already encoded; what the observation is seeing is a plugin that exists, not one that is missing.
- It was a one-off solution to a problem that will not recur.
- It is a standard practice already well documented elsewhere; pointing to that documentation serves better than re-encoding it.
- It is a convention specific to this one project. That belongs in the project's own instructions file (`CLAUDE.md`), not in a distributable plugin.
- It is a mechanical constraint that a regex or a validation step could enforce. If it can be automated as a check, automate it rather than writing prose about it.

These last two are the most common false positives, and worth holding onto: project-specific conventions and mechanically enforceable rules look like reusable knowledge but are better served by other homes.

## The upper layer: why a *plugin*, specifically?

The foundation above decides whether something is worth making reusable. It does not yet decide that the right vessel is a plugin. A plugin is a larger unit than a single skill — it can bundle skills, hooks, agents, commands, and MCP servers together — and that larger unit earns its keep only when the work needs what the larger unit provides.

A single piece of reference knowledge or one self-contained technique may want to be just a skill. The signals that a candidate genuinely wants to be a *plugin* are these:

- **It should fire on an event, not only on request.** If the value depends on something happening automatically at the right moment — on a stop, on an edit, on a commit — that is a hook, and a hook ships inside a plugin. (This plugin itself is an example: it bundles a hook that watches, with a skill that proposes.)
- **It delegates to autonomous work.** If part of the value is handing a sub-task to an agent that runs on its own, that is an agent, and agents ship inside plugins.
- **Several components have to cooperate.** If the work only makes sense as a skill *and* a hook *and* maybe an agent pulling in one direction, the thing that binds them is a plugin.

So the judgment has two stages. First, is the work worth making reusable (the foundation)? Then, does it need bundling or event-driven automation that only a plugin gives (this layer)? A candidate that passes the first stage but not the second is better proposed as a plain skill, and the proposal should say so.

## Sketching the shape of the candidate

When a candidate does warrant a plugin, it helps to sketch which components it would need — skill, hook, agent, command, or MCP server — because that sketch is what the generation step will start from, and it is part of what makes the value concrete to the user. Within the skills, three familiar shapes recur, and naming which one a candidate fits sharpens the sketch:

- **Technique** — a concrete method with steps to follow.
- **Pattern** — a way of thinking about a class of problems.
- **Reference** — documentation of an API, a syntax, or a tool.

This is a rough sketch to aid the proposal and seed the generation prompt, not a binding specification. The background session that actually builds the plugin will refine it in dialogue with the user.

## Where these criteria are used

The criteria here do two distinct jobs, and it is worth keeping them straight.

First, they are the substance of the detection prompt. When the hook asks a lightweight `claude -p` call whether the recent work contains a candidate, the question it poses is built from the axes and the foundation above. Detection should stay generous, per the wide-net principle.

Second, they are the basis of the scope judgment that happens later, during generation. The "lean away" signals are the same ones that sort a candidate into where it belongs: a project-specific convention is steered toward the project's instructions rather than a plugin, and a broadly applicable pattern is the kind of thing that may eventually be worth proposing for publication. Detection raises the candidate; this judgment decides where it should live.
