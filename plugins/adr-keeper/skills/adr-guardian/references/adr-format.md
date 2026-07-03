# The ADR Format

An Architecture Decision Record is a short, standard document capturing one decision, its context, and its consequences. The format below is the widely used Nygard-style ADR — the de-facto standard the world converged on for this purpose, which is why it is the default here. When a project already uses a different ADR template, follow the project's; a record that matches its siblings is worth more than one that follows this file to the letter.

## The standard sections

```markdown
# NNNN. <Short imperative title of the decision>

- Status: <Proposed | Accepted | Deprecated | Superseded by NNNN>
- Date: <YYYY-MM-DD>

## Context

<The forces at play: the problem, the constraints, the pressures, and what
was true at the time that made a decision necessary. Written for a stranger
who was not in the room. This is the section that stops the decision from
being reversed blindly — a future reader who understands the forces can tell
whether they still hold.>

## Decision

<What was decided, stated plainly and in the active voice: "We will ...".
One decision. If the discussion produced two, they are two records.>

## Consequences

<What becomes easier and what becomes harder as a result — honestly, both
sides. The costs the team knowingly accepted belong here, because a
consequence hidden at decision time is the thing that later looks like a
mistake when it was actually a considered tradeoff.>
```

## How to fill each section well

**Title.** State the decision, not the topic. "Use one feature per PR" beats "PR policy". A reader scanning titles should see the decisions, not the subjects.

**Status.** `Accepted` for a decision actually made and agreed. `Proposed` if it still awaits the user's ratification — and say so to the user. When a new record replaces an old one, set the old one to `Superseded by NNNN` and reference the old number from the new record's Status. This two-way link is what keeps a reader from acting on a decision that has been overtaken.

**Context.** This is the load-bearing section. It carries the *why*, and the why is the only part of a decision that does not survive in the code on its own. Write the forces and constraints as they were at the time. Do not write the solution here — that is the Decision. A good Context makes the Decision feel almost inevitable, and lets a future reader judge whether the forces still apply.

**Decision.** Short and unambiguous. Active voice, committed tense. The reader should finish this section knowing exactly what they are and are not allowed to do.

**Consequences.** Honest on both sides. Listing only the benefits turns the record into an advertisement and destroys its value as a decision log — the whole point is that someone later can see the tradeoff was made with eyes open. Name what got harder, and name the cost that was accepted.

## What to keep out

- Implementation detail. An ADR is at the altitude of intent and reasoning, not code. The how lives in the code and the plan.
- Fabricated rationale. If the conversation did not produce a reason, do not invent one to fill the Context. An honest "decided for the following stated reasons; other factors not discussed" is better than a plausible fiction, because a fiction in the record misleads every reader who trusts it.
- Multiple decisions in one file. One record, one decision. Bundling them makes each one harder to find, supersede, and reason about.
