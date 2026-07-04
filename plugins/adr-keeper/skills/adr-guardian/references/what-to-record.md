# Which Decisions Earn an ADR

An ADR is expensive in exactly one currency: attention. Every record a project holds is something a future reader might have to scan. So the value of recording is not "capture everything decided" — it is "capture the decisions whose loss would cause a future session to drift or reverse course wrongly." The filter is the whole point. A directory full of ADRs for trivial choices is worse than a small directory of ones that matter, because it buries the load-bearing decisions under noise until nobody reads any of them.

The test is a single question: **would a future session, not knowing this was decided, be at risk of contradicting it and causing harm?** If yes, record it. If a future session reversing it would be harmless or even fine, do not.

## Record it when the decision is directional

These are the decisions worth an ADR:

- **A structural or architectural choice.** Which layer owns a responsibility, how modules are bounded, what the data flows through, why a boundary is where it is. These govern later work and are exactly what a fresh session, seeing only the code, might undo.
- **A process or convention the project commits to.** One feature per PR, a branching model, a testing bar, a release discipline, a naming rule that carries meaning. Conventions are invisible in the code and so are the first thing a new session violates.
- **A consequential tradeoff that was explicitly accepted.** Choosing the slower-but-simpler path, accepting a limitation to gain something else, picking one tool over a viable competitor for stated reasons. The record preserves *why the rejected option was rejected*, which is what stops the team from relitigating it every few months.
- **A reversal of an earlier decision.** When a prior direction is abandoned, the reversal itself is a directional decision. Recording it — and marking the superseded record — keeps the pendulum from swinging back on autopilot.

The common thread: the decision constrains future choices, and the reasoning behind it is not recoverable from the code alone.

## Do not record it when the decision is local

These look like decisions but do not earn a record:

- **Ordinary implementation choices that follow from the task.** Naming a variable, structuring one function, picking a loop over a map here. A future session choosing differently costs nothing; there is no direction to preserve.
- **Reversible experiments.** "Let's try X and see." The point of a trial is that it is not yet a decision. Record it if and when it hardens into a commitment.
- **Choices already governed by an existing rule.** If an ADR, a `CLAUDE.md`, or a style guide already settles this, a new record duplicates it. Point to the existing home instead.
- **Facts discoverable from the code or the docs.** If a stranger reading the repository would see the decision plainly in the structure, the code is already the record. An ADR earns its keep by holding the *why* that the code cannot show, not by restating the *what* the code already shows.
- **Mechanical constraints a check could enforce.** If a linter, a CI gate, or a validation could hold the line, encode it there. A rule that only lives in prose gets skipped; a rule in a check does not.

## The altitude of an ADR

An ADR records intent and reasoning, not implementation. It answers "what did we decide, and why was that the right call given the forces at the time" — the level at which a human judges a decision. If a draft is drifting into how-to detail, it has left the ADR's altitude; pull it back up to the decision and its rationale. The how belongs in the code and the plan; the ADR holds the why, because the why is the only part that does not survive on its own.
