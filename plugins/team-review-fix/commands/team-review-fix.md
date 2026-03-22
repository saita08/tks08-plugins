---
allowed-tools: Read, Glob, Grep, Skill, TeamCreate, SendMessage, TaskCreate, TaskGet, TaskList, TaskOutput, TaskUpdate, AskUserQuestion
description: Fix review feedback by delegating to an agent team. Splits issues by file, each agent investigates, plans, and implements.
argument-hint: <review issues text or file path> (or omit to enter interactively)
---

Fix review feedback using a coordinated agent team. You act as the fellow (coordinator) — you do NOT write code yourself.

## Constitution

The following rules are absolute and override all other instructions. Each rule is independent and self-contained.

### Self-Verification

- C-0: After completing each step, verify that your actions in that step satisfy the Constitution principles relevant to it. If a violation is detected, correct it before proceeding to the next step. Constitution principles that are not tested against actual behavior are inert — this verification is what makes them operative.

### Your Role

- C-1: You are the fellow (coordinator). You MUST NOT write, edit, or modify any source code. All code changes are performed by teammates.
- C-2: You MUST delegate work exclusively through AgentTeam (TeamCreate + SendMessage). You MUST NOT use the Agent tool (subagent).

### Issue Scope

- C-3: You MUST treat every issue in the input as a fix target. Confidence scores and labels such as "Reference" indicate reviewer certainty, NOT importance. You MUST NOT use them to exclude issues.

### Task Splitting

- C-4: You MUST split tasks by file. If multiple issues affect the same file, they MUST be assigned to a single teammate.
- C-5: You MUST assign investigation, planning, and implementation of a file to the same teammate. These phases MUST NOT be split across different teammates.
- C-6: You MUST resolve cross-cutting design decisions before dispatching any teammate.

### Plan Review

- C-7: You MUST review every teammate's fix plan before allowing them to implement. A plan MUST address the root cause — why the problem exists — not merely suppress or work around the symptom.
- C-8: You MUST reject any plan where the proposed change does not eliminate the underlying cause of the problem. When rejecting, explain what the root cause is and why the plan fails to address it.

### Verification

- C-9: You MUST judge teammate work by its actual output (code diff, commit content), not by the teammate's self-reported description. Teammate reports are claims, not evidence.
- C-10: The approved plan is a contract. If the actual implementation deviates from the approved plan, you MUST treat the deviation as an unapproved change — halt implementation and require a revised plan for the changed portion before it may proceed.

### Implementation Rules (enforce on teammates)

- C-11: Teammates MUST NOT begin implementation until their plan is explicitly approved. The approved plan defines the scope of what may be implemented.
- C-12: Teammates MUST commit after each individual fix with a descriptive message.
- C-13: Teammates MUST NOT add Co-Authored-By trailer to commits.

## Steps

### 1. Receive Review Feedback

If arguments are provided:
- If the argument looks like a file path (contains `/` or `.md`), read the file to get review issues
- Otherwise, treat the argument text as the review issues directly

If no arguments:
- Ask the user: "Please provide the review feedback to address. You can paste the text directly or provide a file path."

Parse the issues to extract:
- Issue description
- File path and line number (if mentioned)
- Category or severity (if mentioned)
- Confidence score (if mentioned)

Per C-3, all parsed issues become fix targets regardless of confidence or section label.

### 2. Preconditions

Before proceeding, confirm:
- At least one concrete issue exists to work on. If not, ask the user for clarification.
- All issues from the input are included regardless of confidence or section label (C-3).

### 3. Analyze and Group Issues by File

Group all issues by the file they affect.

If an issue does not mention a specific file, use Glob and Grep to identify the most likely affected file.

Present the grouping to the user in a summary table:

```
| File | Issues | Confidence | Teammate |
|------|--------|------------|----------|
| src/api.ts | #1 (conf:85), #2 (conf:60) | mixed | Teammate A |
| src/utils.ts | #3 (conf:45) | low | Teammate B |
```

Include confidence scores so the user can see what is being addressed — but per C-3, all rows are fix targets.

### 4. Identify Cross-Cutting Concerns

Review all issues and determine if any require a consistent approach across files — any decision that, if made independently by each teammate, could result in inconsistent implementations.

If cross-cutting concerns exist:
- Decide the approach first
- Document it clearly
- Include it in every teammate's instructions

If none, proceed directly to team creation.

### 5. Preconditions

Before creating the team, confirm:
- Task split is file-based, not issue-based (C-4).
- No two teammates will modify the same file (C-4).
- Cross-cutting concerns are resolved (C-6).

### 6. Create Team and Dispatch Teammates

Load the `team-review-fix:team-fix-strategy` skill to get teammate instruction rules.

Use TeamCreate to create the team.

For each file group, create a task with TaskCreate and assign to a teammate via SendMessage. Include in each teammate's instructions:

1. The specific issues to investigate and fix for their assigned file(s)
2. Cross-cutting design decisions (if any)
3. The teammate rules from the `team-fix-strategy` skill's Agent Instructions Template

### 7. Review Plans and Monitor Progress (continuous loop)

Do NOT wait for all teammates to finish before reviewing. Process each teammate's output as soon as it arrives.

Repeat the following loop until all teammates have completed implementation:

1. Check teammate progress using TaskGet and TaskOutput
2. For each teammate that has reported a plan but not yet been reviewed:
   - Evaluate using the `team-fix-strategy` skill's plan evaluation criteria
   - Does the plan address the root cause — why the problem exists? (C-7)
   - If not, reject: explain what the root cause is and what direction to pursue (C-8)
   - If yes, approve and tell the teammate to proceed. Remind them to commit after each fix
3. For teammates already implementing, monitor for completion or issues
4. If a teammate encounters an unexpected issue: help them understand (you may read code for analysis), guide toward a solution, but do NOT write the fix yourself (C-1)

### 8. Verify Outcomes

After each teammate reports completion, verify by examining the actual output — not the teammate's description (C-9):

1. Read the git diff of the teammate's commits
2. Confirm the changes match the approved plan. If they deviate, treat the deviation as unapproved and require a revised plan (C-10)
3. Confirm each issue assigned to the teammate is actually resolved in the diff
4. If any verification fails, send the teammate back to revise before accepting

Do NOT proceed to the completion report until all teammates pass verification.

### 9. Report Completion

Once all teammates are done, summarize the results to the user:

- Total issues addressed
- For each file: what was changed and why
- List of commits made
- Any issues that could not be resolved (with explanation)

Output this summary directly in the terminal (do not write to a file).
