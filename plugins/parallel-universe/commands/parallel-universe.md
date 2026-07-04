---
description: Solve one task with several independent parallel attempts, judge them through different lenses, and propose a grafted synthesis of the winner and the runners-up.
argument-hint: "<課題> [--n 数（既定3、最大5）]"
allowed-tools: Read, Glob, Grep, Bash, Write
---

# Parallel Universe

Take one task and open it into several parallel universes. In each, a different version of the same worker attempts the task in isolation, blind to the others. Then judges score the attempts through different lenses, a winner is chosen, and the best parts of the losers are grafted onto it. The user approves before any of it touches their real tree.

This command runs a Claude Code Workflow script — a deterministic program that commands a team of agents. Read `${CLAUDE_PLUGIN_ROOT}/skills/tournament-doctrine/SKILL.md` and its references before assembling the script; the doctrine there decides when this is worth the cost, how to keep the attempts genuinely independent, and how to design the judging lenses. Invoking a Workflow from a slash command is the sanctioned, opt-in way to use it, so build the script openly.

## Step 1 — Read the task and settle the count

The task is in `$ARGUMENTS`. Parse an optional `--n` (default 3, clamp to the range 2–5). If the task is one sentence of intent with no detail, ask the user the one or two questions that would most change how an attempt is made before spending N times the tokens on a vague target. A divergent tournament run against an underspecified goal buys N variations of the same misunderstanding.

Judge whether the task even wants this. The doctrine's `references/when-to-diverge.md` draws the line: divergence beats polishing when the target is recognizable on sight but hard to specify in advance, and when the attempts can genuinely differ. A task with one obvious correct implementation does not want five universes — say so and stop, rather than billing the user for five copies of the same answer.

## Step 2 — Assemble the Workflow script

Write a Workflow script to a temp file. It must have three phases. Follow `${CLAUDE_PLUGIN_ROOT}/skills/tournament-doctrine/references/workflow-shape.md` for the exact API — the schema object-wrap rule and the diversity-injection pattern are load-bearing, not decoration.

The script's shape:

- `export const meta` with the three phases declared as pure literals: Generate, Judge, Synthesize.
- **Generate**: N calls to `agent(prompt, { label, phase, isolation: 'worktree' })`, run under `parallel([...])` so the barrier waits for all of them. Each attempt gets a different angle injected into its prompt — draw the angles in order from `references/diversity-angles.md` (minimal-first, robustness-first, performance-first, UX-first, convention-breaking). Each worker is told the task and its angle, and is never told the others exist. Worktree isolation is required here because the attempts write files in parallel and must not collide.
- **Judge**: three `agent()` calls, each a judge reading all N attempts through one lens (correctness, simplicity, intent-fit), each returning a structured score via a `schema`. The schema's top level must be an `object` — wrap any array as `{ "items": [...] }`, or the API rejects it and the judge returns nothing.
- **Synthesize**: one `agent()` call that takes the winning attempt as the base and proposes grafting the best specific moves from the runners-up onto it.

Keep the worker prompts pointed at producing a real diff in their worktree, not a description of one. Scale N down from the requested count if `budget.remaining()` is thin, and log that you did.

## Step 3 — Run it and report

Run the script with the Workflow runner. When it finishes, report to the user, and only report — nothing lands in their working tree yet:

- a short diff summary of the winning universe, named by its worktree,
- the judging table: each attempt scored by each lens, so the user sees not just who won but why and how close it was,
- the synthesis proposal: the specific grafts from the runners-up worth folding into the winner.

## Step 4 — Apply only on approval

The whole tournament happened in isolated worktrees; the user's real tree is untouched. Ask which they want: the winning universe as-is, the grafted synthesis, or nothing. Apply only after they choose. A rejected universe is not a waste — it is data about the target, and if the user rejects all of them, that rejection has narrowed what they actually want. Do not commit; the user reviews the working tree.
