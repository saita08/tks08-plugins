# Writing a Principle, Not a List of Cases

This document explains how to write the proposed principle text — part 4 of a harvest proposal — so that it earns a place in a `CLAUDE.md` and keeps earning it. It is the discipline that separates a principle from a patch. The reader is another instance of Claude, drafting a proposal from friction that has already been observed to recur.

## Why generality is the whole point

A constitution is read by a future Claude facing a situation its author never anticipated. Its value is that a principle stated as a value — with the reasoning that makes it true — applies to cases that did not exist when it was written. A rule pinned to the specific symptom that prompted it applies only to that symptom, and the next, differently-shaped instance of the same failure sails past it unrecognized.

So the drafting task is not "write down what the user corrected." It is "find the general value that the correction is an instance of, and state that value." The correction is evidence; the principle is the law the evidence points to.

## Do not name the triggering symptom in the principle

The most common failure in drafting is to write the incident into the principle's body. "Do not use tabs in Python files" is a symptom. The principle underneath it might be "match the surrounding file's existing conventions rather than imposing a personal default, because a diff that reformats untouched lines buries the real change." A future reader treats a symptom-level rule as the definition and overlooks it the moment the situation is not literally about tabs. A value-level principle catches the whole class.

If the originating case must be recorded at all, it belongs in the proposal's "observed cases" section and in commit history — not in the principle text. The principle body carries the value; the evidence lives beside it, not inside it.

## State the value, then the reasoning, then the observable change

A well-formed principle has three moving parts:

- **The value** — what should be true, stated generally. Not "when X happens do Y" but "this is what matters and why."
- **The reasoning** — the "because" that makes the value self-justifying, so a future reader can extend it to a case the words did not anticipate. A rule without its reason cannot be applied to a novel situation; the reader has nothing to reason from.
- **The observable behavior change** — what a reader should do differently after adopting it, concrete enough that one could tell whether it was followed. A principle that produces no observable change in behavior is decoration; naming the change is what makes the principle checkable and the proposal honest.

## Write in the constitution's voice

The proposed text will live next to principles the user already wrote. It should read as though it belongs there: the same register, the same "explanation of why this matters" stance rather than a terse rule list. When drafting, match the prose of the target `CLAUDE.md` if its style is known. New content that is stylistically indistinguishable from what surrounds it is what keeps a constitution coherent as it grows.

## State the principle so examples are unnecessary

A concrete example invites the reader to treat the listed case as the definition and miss the principle when reality does not match the list. State the value clearly enough that an example is not needed to understand it. If one genuinely helps, frame it explicitly as an illustration of the principle, never as a substitute for stating it.

## The proposal is a draft, not a decree

Everything here produces a draft for the user to ratify. The user may sharpen the value, reject the framing, or decide the friction was situational and not worth a principle at all. Draft it as well as if it were final, and hand it over as if it were provisional — because it is. The gardener's authority ends at the proposal; the constitution's authorship stays with the user.
