# When Divergence Beats Polishing

A tournament pays off when the target is recognizable but not specifiable, and when the attempts can genuinely differ. When either condition fails, it burns N times the tokens for nothing. This file is the gate: decide here whether the task deserves a tournament before assembling one.

## The recognizable-but-not-specifiable test

Some targets you can describe completely in advance: "parse this date format", "add a null check here", "rename this symbol everywhere". For these, there is one correct answer, and any competent attempt lands on it. Running five universes produces five copies of the same code, and the judging phase is theater. Polishing a single attempt is strictly cheaper and just as good.

Other targets you cannot specify in advance but recognize instantly when you see them: the clean API shape, the error message that actually helps, the refactor that makes the module finally make sense, the layout that feels right. Here the specification lives in the user's judgment, not in words, and it comes out only in reaction to a concrete candidate. This is exactly where divergence wins. Each independent attempt is a probe into the space of what "right" means, and the user's reaction to five probes maps the target far faster than five rounds of "not quite, try again" against a single anchored draft.

The test to apply: *can I write down, right now, what a correct answer must contain?* If yes, polish one. If the honest answer is "I'll know it when I see it," diverge.

## The attempts-can-differ test

Divergence also requires that the task admits genuinely different approaches. A task with real design freedom — where minimal and robust and fast and elegant pull in different directions — gives the angles something to bite on. A task so constrained that every reasonable approach converges gives them nothing, and the five universes collapse into one regardless of how the prompts are seeded.

When both tests pass, the tournament is worth its price. When either fails, say so plainly and recommend a single attempt. Declining cheaply is part of the value: a tool that always runs five universes is a tool that bills five times for answers that did not need it.

## The stakes have to justify the multiplier

Even when both tests pass, the task has to be large enough to matter. Five universes on a trivial change is technically a valid tournament and a poor trade. Reserve divergence for the work whose outcome the user actually cares about getting right — the load-bearing design decision, the refactor they will live with, the feature whose shape sets a precedent. The bigger the consequence of the choice, the more the multiplier earns its keep.
