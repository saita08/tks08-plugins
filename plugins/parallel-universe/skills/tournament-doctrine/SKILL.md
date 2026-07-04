---
name: tournament-doctrine
description: This skill should be used when the user wants to generate several independent attempts at a task and pick the best, asks to "run a tournament", "try N approaches in parallel", "give me a few different versions and choose", mentions "並列で複数案", "多元宇宙", "分身", or when Claude is about to assemble a divergent multi-attempt Workflow and needs to judge whether divergence beats polishing, keep the attempts independent, or design the judging lenses. Carries the doctrine behind the /parallel-universe command.
allowed-tools: Read, Glob, Grep
---

# Tournament Doctrine

Generating several genuinely independent attempts at a task and then selecting among them converges on a good result faster than polishing a single draft — but only for the right kind of task, and only if the attempts stay independent. This skill carries the reasoning that makes a divergent tournament pay off, and the mechanics of building one. Consult the reference that matches the decision in front of you rather than loading all of them.

- `references/when-to-diverge.md` — when divergence beats polishing, and when it wastes N times the tokens on N copies of the same answer. Read when deciding whether a task deserves a tournament at all.
- `references/independence.md` — why cross-contamination between attempts kills the diversity the whole method depends on, and how the worktree isolation and blind prompts preserve it. Read when writing the Generate phase.
- `references/diversity-angles.md` — the ordered set of angles injected into each attempt to force real divergence, and the reasoning behind each. Read when assigning angles to workers.
- `references/judging-lenses.md` — how to design the judging lenses so that scoring surfaces genuine trade-offs rather than crowning the most verbose attempt, and why a rejection is data about the target. Read when writing the Judge and Synthesize phases.
- `references/workflow-shape.md` — the exact Workflow API this doctrine is built on: the three-phase structure, the schema object-wrap rule, budget-linked scaling. Read when assembling the script.
- `references/cost.md` — the honest economics: a tournament costs N times a single attempt, and when that price buys nothing. Read when weighing N, or when explaining the cost to the user.

The single idea under all of it: a lone draft anchors everyone on its first shape, and every later edit negotiates with that anchor instead of the target. Several independent drafts have no shared anchor, so the selection is made against the target itself. That is the whole reason to pay N times the price — and the reason the attempts must be independent, because the moment they can see each other, they collapse back toward one shape and you have paid N times for one draft.
