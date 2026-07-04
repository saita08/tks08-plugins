# The Honest Economics

A tournament costs what N attempts cost, plus the judges. There is no version of this that is cheap. The doctrine earns its price only on the tasks that need it, and this file exists so the price is never hidden — from the user or from the reasoning that decides to spend it.

## What N universes actually cost

Each universe is a full agent run: it reads the codebase, reasons about the task, and writes a diff, all in its own worktree. Five universes is five of those. Then three judges each read all five attempts and score them, which is not free either, since each judge processes the full text of every attempt. The synthesis is one more agent on top. A five-universe run is, in round numbers, six-to-eight agents' worth of tokens to answer one question.

That is the multiplier the user is buying. It is worth stating to them in the same breath as the offer, because the value proposition of the whole tool depends on the user understanding they are trading tokens for faster convergence on a hard target — and choosing to.

## When the price buys nothing

The multiplier is pure waste in exactly the cases `when-to-diverge.md` rules out:

- **A specifiable task.** If the correct answer can be written down in advance, all N universes converge on it and the judges rank five identical answers. The user paid five times for one answer and a pointless ranking.
- **A constrained task.** If the task admits only one reasonable approach, the diversity angles have nothing to bite on, and the universes collapse regardless of the prompts. Same waste, different cause.
- **A trivial task.** Even when divergence is possible, a change small enough that a single attempt would have been fine does not justify the multiplier. The tournament is for decisions the user will live with, not for one-line fixes.

In each case the right move is to decline and recommend a single attempt. Spending the multiplier on a task that did not need it does not just waste tokens — it teaches the user the tool is profligate, and a tool they think is profligate is a tool they stop reaching for even when it would have helped.

## Judging the trade

The question to hold is not "can I run a tournament here?" but "does this target's difficulty justify N times the tokens?" The harder the target is to specify and the more the user cares about getting it right, the more the multiplier earns its keep. When the answer is a clear yes, run it and say what it cost. When it is a maybe, the honest move is to name the cost and let the user decide, because the budget is theirs to spend.
