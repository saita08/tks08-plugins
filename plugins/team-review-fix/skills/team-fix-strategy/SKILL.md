---
description: "Use this skill when the user asks to fix review feedback with a team, split review issues into tasks, delegate review fixes, handle code review responses, or coordinate parallel fixes for review comments. Also triggers on phrases like 'review fix', 'fix review issues', 'team fix', or 'address review feedback'."
---

# Team Review Fix Strategy

Knowledge base for splitting review feedback into file-based tasks, evaluating fix plans, and coordinating parallel agent teams.

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

## Plan Evaluation Criteria

### Root Cause Principle

Every fix must answer the question: "Why does this problem exist?" A plan that addresses the *why* is a root-cause fix. A plan that only addresses the *what* (the visible symptom) is symptomatic.

**Test:** If the fix were removed, would the same class of problem recur? If yes, the fix is symptomatic — it guards against the problem rather than eliminating its source.

**Test:** Does the fix prevent only the exact reported instance, or does it eliminate the conditions that produce this class of problem? The former is symptomatic; the latter is root-cause.

### Evaluation

Approve a plan when it eliminates the origin of the problem such that the symptom can no longer arise.

Reject a plan when it leaves the origin intact and instead intercepts, suppresses, or works around the symptom downstream. When rejecting, identify what the root cause is and why the plan fails to address it.

## Agent Instructions Template

When creating teammate agents, include these rules in their instructions:

### Required Rules for Teammates

1. **Plan before implementation** — present your fix plan and wait for explicit approval before writing any code
2. **The approved plan is the contract** — if you discover during implementation that the approach needs to change, stop and re-submit a revised plan. Do not implement unapproved changes, even if you believe they are improvements
3. **If plan is rejected**, revise based on the feedback and re-submit — do not implement the rejected plan
4. **Commit after each fix** with a commit message that describes what was fixed and why
5. **Do NOT add Co-Authored-By trailer** to commit messages
6. **Stage by explicit path only** — never `git add .`, `git add -A`, or `git commit -a`. Why: the staging index is shared across teammates in the same working tree, and wildcard staging will sweep up another teammate's in-progress edits into your commit
7. **Use `git add -p` for files that other teammates may also touch** — stage by hunk so that only your changes enter the index. Why: file-level assignment is not a guarantee against cross-cutting edits to shared files (e.g., a common types module)
8. **Run `git diff --cached --stat` immediately before every commit** — visually confirm that only files you own are staged. If anything foreign appears, run `git restore --staged <path>` to unstage it before committing. Why: a commit whose message and contents disagree is a permanent defect in history; the cost of one extra check is far smaller than the cost of recovering from a contaminated commit

### Investigation Approach for Teammates

1. Read the relevant file(s) to understand the current code
2. Verify the issue actually exists (it may have been fixed already)
3. Understand the surrounding context — what calls this code? What does it depend on?
4. Identify the root cause: why does this problem exist?
5. Present the plan with: what you found, what you will change, and why this eliminates the root cause
