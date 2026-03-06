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

### What Makes a Plan "Symptomatic" (Reject)

A symptomatic fix treats the symptom, not the cause. Reject plans that:

- **Suppress errors** without fixing the source (e.g., wrapping in try-catch just to silence)
- **Add null checks** where the real fix is ensuring null never arrives
- **Add type assertions** (as any, !) to bypass type errors instead of fixing the type
- **Duplicate logic** to handle a case that should be handled upstream
- **Add comments** explaining broken behavior instead of fixing it
- **Disable rules** (eslint-disable, @ts-ignore) without addressing the underlying issue

### What Makes a Plan "Root-Cause" (Approve)

A root-cause fix addresses why the problem exists. Approve plans that:

- **Fix the source** of bad data rather than guarding against it downstream
- **Restructure code** to make the invalid state unrepresentable
- **Add validation at system boundaries** (input entry points, external API responses)
- **Refactor to eliminate the class of bug**, not just the instance
- **Update types** to accurately reflect the domain

### Ambiguous Cases

When it is unclear whether a plan is symptomatic or root-cause:
- Check if the fix would prevent similar bugs in the same area
- Check if removing the fix would re-expose the original issue AND other related issues
- If the plan addresses only the exact symptom reported and nothing deeper, it leans symptomatic

## Agent Instructions Template

When creating teammate agents, include these rules in their instructions:

### Required Rules for Teammates

1. **Commit after each fix** — do not batch multiple fixes into one commit
2. **Do NOT add Co-Authored-By trailer** to commit messages
3. **Write commit messages** that clearly describe what was fixed and why
4. **Do NOT implement before plan approval** — present your plan first, then wait for approval
5. **If plan is rejected**, revise based on the feedback and re-submit — do not implement the rejected plan

### Recommended Investigation Steps for Teammates

1. Read the relevant file(s) to understand the current code
2. Verify the issue actually exists (it may have been fixed already)
3. Understand the surrounding context — what calls this code? What does it depend on?
4. Formulate a root-cause fix plan
5. Present the plan with: what you found, what you will change, and why this addresses the root cause
