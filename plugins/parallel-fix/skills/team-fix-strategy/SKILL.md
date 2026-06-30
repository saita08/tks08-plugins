---
description: "Use this skill when the user asks to fix review feedback with a team, split review issues into tasks, delegate review fixes, handle code review responses, or coordinate parallel fixes for review comments. Also triggers on phrases like 'review fix', 'fix review issues', 'team fix', or 'address review feedback'."
user-invocable: false
---

# Team Review Fix Strategy

The fellow loads this skill from Step 7 of the `/parallel-fix` command, and reads it for two distinct purposes that point at different audiences.

The first audience is the fellow itself. Two sections below speak to that audience: Task Splitting Principles records how the fellow groups issues into file-based tasks, and Plan Evaluation Criteria records how the fellow decides whether a teammate's plan addresses the root cause. The fellow consults both while preparing dispatch and while reviewing plans.

The second audience is each teammate. The rules the teammate must follow during investigation, planning, and committing live in `references/teammate-rules.md`. The fellow reads that file and copies its contents verbatim into the spawn prompt that dispatches each teammate (the `Agent` prompt that launches it). The teammate never sees this `SKILL.md`; the teammate only sees what the fellow forwards. Paraphrasing the rules during forwarding loses the "why" clauses that teach when each rule applies, so the fellow forwards them as written.

## Task Splitting Principles

### Split by File, Not by Issue Number

When multiple review issues exist, group them by the file they affect, not by issue number.

Why:
- One file read serves multiple issues — avoids redundant context loading
- Prevents edit conflicts — no two agents modify the same file
- Natural parallelization boundary

Example — Given issues #1 (src/api.ts:30), #2 (src/api.ts:55), #3 (src/utils.ts:15):
- CORRECT: Agent A handles #1 and #2 (both in src/api.ts), Agent B handles #3 (src/utils.ts)
- WRONG: Agent A handles #1, Agent B handles #2, Agent C handles #3

### One Agent Does Investigation, Planning, AND Implementation

Never separate planning and implementation into different agents. The agent who reads the code and understands the context must be the one who writes the fix. Splitting these phases across agents forces the implementer to re-read everything the planner already read.

### Cross-Cutting Design Decisions First

If multiple files need a consistent approach (e.g., unifying error handling patterns, adopting a common AbortController strategy), decide the approach BEFORE dispatching agents. Communicate the decided approach to each agent as part of their instructions.

Confirm the decision against the primary source — the type definition, the API reference, the documented contract — before propagating it. A cross-cutting decision applied by N agents multiplies any error in it N-fold, and general knowledge of how a library is "usually" used is not a substitute for reading the actual contract.

Name the verification command each agent will run. "Run the type checker" leaves the command choice to the agent, and the agent's default may not exercise the code path the verification was meant to cover (e.g., `tsc --noEmit` does not resolve TypeScript project references; `tsc -b` does). The fellow is positioned to know these environment-specific traps before dispatch.

## Plan Evaluation Criteria

### Root Cause Principle

Every fix must answer the question: "Why does this problem exist?" A plan that addresses the *why* is a root-cause fix. A plan that only addresses the *what* (the visible symptom) is symptomatic.

**Test:** If the fix were removed, would the same class of problem recur? If yes, the fix is symptomatic — it guards against the problem rather than eliminating its source.

**Test:** Does the fix prevent only the exact reported instance, or does it eliminate the conditions that produce this class of problem? The former is symptomatic; the latter is root-cause.

### Evaluation

Approve a plan when it eliminates the origin of the problem such that the symptom can no longer arise.

Reject a plan when it leaves the origin intact and instead intercepts, suppresses, or works around the symptom downstream. When rejecting, identify what the root cause is and why the plan fails to address it.

### What the evaluation produces

The criteria above are how the fellow judges a plan; what the fellow sends back is the judgment itself. An approval reaches the teammate as approval and a go-ahead. A rejection reaches the teammate as the root cause the plan left intact and the direction that would address it (C-8) — that is what lets the teammate revise on the next try rather than guess at what the reviewer saw. The tests the fellow applied to reach the judgment are the reasoning behind it, and they stay with the fellow; the teammate acts on the decision and its grounds. This is C-21 applied to plan review.

## Teammate Rules to Forward at Dispatch

Read `references/teammate-rules.md` and include its contents in every teammate's spawn prompt (the `Agent` prompt that launches it), alongside the file-specific issues and any cross-cutting decisions the fellow has made. Forward the rules verbatim; do not paraphrase, summarise, or extract "just the gist" of them — the wording of each rule is what carries the discipline, and a summary loses the "why" clauses that decide when the rule applies.
