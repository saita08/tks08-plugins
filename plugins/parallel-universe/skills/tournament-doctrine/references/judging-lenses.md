# Judging Lenses

Generation produces N attempts; judging turns them into a decision. A single overall score would collapse the trade-offs the tournament exists to surface and tend to crown whichever attempt is longest and most defensive. So judging is split across lenses, each a separate judge scoring one dimension, and the trade-offs are left visible for the user to weigh. This file is about designing those lenses.

## Three lenses, three judges

Use three judges, each reading all N attempts through exactly one lens:

- **Correctness.** Does it actually do the task, for the real inputs including the ugly ones? Does it introduce a bug, break an invariant, mishandle an edge? This lens is the veto: an elegant attempt that is wrong loses to a plain one that is right. Score what the code does, not how it reads.
- **Simplicity.** How much does a reader have to hold in their head to understand and maintain this? Fewer moving parts, less indirection, less cleverness that has to be decoded. This lens is the counterweight to the robustness and performance angles, which are always tempted to over-build. Score the cost of living with the code.
- **Intent-fit.** Does this match what the user was actually reaching for — the spirit of the task, not just its letter? An attempt can be correct and simple and still solve the wrong problem, or solve the right one in a way that fights the grain of the codebase. This lens is where the recognizable-but-not-specifiable target gets recognized.

Each judge is a separate `agent()` call so its lens is not diluted by the others. Each returns a structured score through a `schema` — a number per attempt plus a sentence of justification — so the report can lay them side by side.

## Why separate judges, not one judge with three criteria

One judge asked to weigh three things at once silently picks a favorite criterion and lets it dominate, and you cannot tell from the output that it did. Three judges each committed to one lens produce three honest, single-minded rankings, and the disagreement between them is the signal. When the correctness judge and the simplicity judge crown different attempts, that split is the trade-off the user needs to see — not a problem to average away.

## A rejection is data about the target

The judging table is not only a way to pick a winner. Every low score is a fact about what the target is *not*, and the user reading the table learns the shape of what they want by seeing what they rejected. This is why the report shows all attempts scored by all lenses, not just the winner. Even a run where the user rejects every universe has produced something: it has ruled out N approaches and narrowed the space. A direction the user rejected must not quietly return in the synthesis wearing new clothes.

## Synthesis: graft, do not average

The Synthesize phase takes the winning attempt as the base — the one that best balances the three lenses — and proposes folding in specific, named moves from the runners-up: this error-handling from the robustness universe, that data structure from the performance one. It grafts concrete parts, it does not blend the attempts into a mush. A graft is a decision the user can accept or reject move by move; an average is a fourth attempt nobody chose. Present the grafts as a list, each traceable to the universe it came from, so the user approves the composition, not a black box.
