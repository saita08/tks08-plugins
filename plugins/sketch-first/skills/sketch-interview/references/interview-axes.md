# The Interview Axes

The value of the sketch is entirely in the questions. A sketch built from the wrong questions is a confident picture of the wrong thing. These five axes are chosen because each one, when left implicit, is a common reason a concrete proposal gets rejected. Interviewing along them surfaces the disagreements *before* they cost a rebuild.

Every question is posed inside the user's domain — what the thing is, who it serves, how it should feel — never inside the implementation domain. A question the user can only answer by knowing how you would build it does not transfer their picture to you; it hides a decision behind jargon and extracts an approval that means nothing. If a question can only be parsed with knowledge of frameworks, data models, or architecture, it is on the wrong axis; rephrase it in terms of the product the user can see and judge.

## The five axes

**1. Who is it for?**
Who sits in front of this and uses it, and what do they already know when they arrive? A tool for the team that built it and a tool for a first-time visitor are different products wearing the same words. This axis anchors every other one: "good" is always good *for someone*.

**2. What changes when it succeeds?**
Not "what does it have" but "what is different in the world once it works." What can the user do that they could not before, or do faster, or stop worrying about? A feature list is a design; a description of the changed situation is a goal. Push for the latter — it is the thing you can later check a proposal against.

**3. What does it resemble, and what must it not resemble?**
Ask for references in both directions. "Like X" pulls the picture out of the user's head faster than any abstract description, because they recognize the target on sight even when they cannot specify it. "Not like Y" is often more informative still: the anti-reference rules out a whole region of the space you might otherwise have wandered into. Offer candidate references for the user to react to when you have them — reacting is easier than generating.

**4. What is non-negotiable?**
The hard constraints — the one or two things that, if violated, make the whole thing wrong regardless of how good everything else is. A required integration, a fixed brand rule, a hard deadline, an accessibility floor, a platform that must be supported. These are the walls of the sketch. Naming them keeps a proposal from being elegant and useless.

**5. What genuinely does not matter?**
The explicit don't-cares. This axis is as valuable as the constraints and is almost always skipped. When the user says a dimension is free — "I don't care what color", "any framework is fine", "the wording can be whatever" — that is permission to move fast there and stop agonizing over a choice the user was never going to judge. Don't-cares are where you reclaim the time the constraints cost you.

## Using the axes

- Ask only where ambiguity actually lives. If who-it-is-for is obvious from the request, do not ask it. Mechanically walking all five axes on a goal that only has one real open question wastes the user's attention — the very thing this whole approach is meant to protect.
- Batch related questions into as few passes as you can. An interview that takes ten separate prompts costs more than the rebuild it was avoiding.
- Where you can, give concrete options to react to rather than open prompts to fill. But always leave room for an answer you did not anticipate; the goal is to surface the user's picture, not to make them choose from yours.
- The output of the interview is a sketch, not a spec. Keep every answer at the altitude of intent and observable behavior. The moment an answer turns into an implementation detail, you have left the user's domain and the sketch stops being something they can confirm at a glance.
