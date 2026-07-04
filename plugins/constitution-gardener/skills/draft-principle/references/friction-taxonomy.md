# The Taxonomy of Friction, and Where a Principle Belongs

This document is the shared source of truth for two readers: the extraction step (`commands/harvest-extract.sh`), which decides what counts as friction in a transcript, and the drafting step (`SKILL.md`), which decides what a cluster of friction means and where the resulting principle should live. Both reason from the same definitions so that what extraction raises and what drafting concludes never contradict each other.

## What friction is, and why it matters

Friction is a moment where the user pushed back on what Claude did. A single friction event is ordinary — anyone corrects a collaborator now and then. The signal this tool cares about is *repeated* friction: the same kind of pushback, surfacing more than once, at different moments. Repetition is the evidence that the user is compensating, turn after turn, for something the constitution should have carried but did not. A repeated correction is a defect report against the constitution, filed in the only language the transcript has.

## The three kinds

**Correction.** The user overrode *how* Claude did something. Claude chose an approach, a format, a tone, a tool, and the user replaced that choice with their own: "no, do it this way", "that's wrong, use X". The friction is against a decision Claude made that the user did not want made that way.

**Rejection.** The user pushed back a proposal or a change Claude offered or performed: "don't do that", "revert that", "stop". The friction is against an action, not a style — Claude did or proposed something, and the user declined it.

**Rephrasing.** The user re-issued the same underlying request from a different angle because the first attempt missed the mark. This is subtler: it is not an explicit correction but a record that one pass did not land, and the user had to spend another turn steering. Repeated rephrasing of the same kind of request points at a standing gap between what the user means and what Claude does by default.

## What is not friction

Extraction stays disciplined because a loose definition floods the pool with noise that then fails to cluster. Do not count:

- Ordinary questions, clarifications, or a new unrelated request.
- The user simply moving to the next task.
- Approvals, thanks, or neutral acknowledgements.
- Any friction whose subject is this mining tooling itself.
- Any case where no specific Claude action can be identified as the thing pushed back on. Friction without a provoking action cannot become a principle, because a principle has to say what to do differently.

The bar is evidence, not plausibility. If a moment is not clearly one of the three kinds, it is left out. A pool of clean friction that clusters is worth far more than a large pool that does not.

## Routing: personal constitution or project constitution

Every surviving cluster has to be routed to a home, and the choice matters because a principle in the wrong home is either too narrow to help or too broad to be true.

Route to the **personal `~/.claude/CLAUDE.md`** when the friction concerns how Claude should work *in general* — a discipline that should hold across every project the user touches. Signals: the cluster's events span more than one project; the correction is about Claude's default behavior, tone, or method rather than any project's specifics; the value would still be true in a project that does not exist yet.

Route to a **project's `CLAUDE.md`** when the friction concerns a convention, constraint, or fact local to one project. Signals: every event in the cluster comes from the same project; the correction is about that project's stack, layout, naming, or house rules; the value would be wrong or meaningless in a different project.

When a cluster genuinely straddles both — a general value that also has a project-specific expression — say so in the proposal and let the user decide the split. The routing is a recommendation the user ratifies, not a verdict. When the evidence is ambiguous, prefer the project home for anything that smells project-specific and the personal home only for what is clearly general; a false-general principle pollutes every future session, while a false-local one is merely underused.

## The consumers of this taxonomy

The extraction script poses its detection question from the three kinds above and the "what is not friction" list; keep that prompt in agreement with this file when either changes. The drafting skill uses the routing test to fill the "target institution" part of each proposal. Detection raises the friction; the routing test decides where the principle it becomes should live.
