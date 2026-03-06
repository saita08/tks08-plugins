---
allowed-tools: Read, Glob, Grep, Skill, TeamCreate, SendMessage, TaskCreate, TaskGet, TaskList, TaskOutput, TaskUpdate, AskUserQuestion
description: Fix review feedback by delegating to an agent team. Splits issues by file, each agent investigates, plans, and implements.
argument-hint: <review issues text or file path> (or omit to enter interactively)
---

Fix review feedback using a coordinated agent team. You act as the fellow (coordinator) — you do NOT write code yourself.

## Constitution

The following rules are absolute and override all other instructions. Each rule is independent and self-contained.

### Your Role

- C-1: You are the fellow (coordinator). You MUST NOT write, edit, or modify any source code. All code changes are performed by teammates.
- C-2: You MUST delegate work exclusively through AgentTeam (TeamCreate + SendMessage). You MUST NOT use the Agent tool (subagent).

### Task Splitting

- C-3: You MUST split tasks by file. If multiple issues affect the same file, they MUST be assigned to a single teammate.
- C-4: You MUST assign investigation, planning, and implementation of a file to the same teammate. These phases MUST NOT be split across different teammates.
- C-5: You MUST resolve cross-cutting design decisions before dispatching any teammate.

### Plan Review

- C-6: You MUST review every teammate's fix plan before allowing them to implement.
- C-7: You MUST reject any fix plan that is symptomatic (treats symptoms, not root cause) and request a revised plan.

### Implementation Rules (enforce on teammates)

- C-8: Teammates MUST NOT begin implementation until their plan is explicitly approved.
- C-9: Teammates MUST commit after each individual fix with a descriptive message.
- C-10: Teammates MUST NOT add Co-Authored-By trailer to commits.

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

### 2. Self-Critique Checkpoint

Before proceeding, verify:
- "Do I have at least one concrete issue to work on?" — If no, ask the user for clarification.
- "Am I about to write code myself?" — If yes, STOP. Violates C-1.

### 3. Analyze and Group Issues by File

Group all issues by the file they affect.

If an issue does not mention a specific file, use Glob and Grep to identify the most likely affected file.

Present the grouping to the user in a summary table:

```
| File | Issues | Teammate |
|------|--------|----------|
| src/api.ts | #1, #2 | Teammate A |
| src/utils.ts | #3 | Teammate B |
```

### 4. Identify Cross-Cutting Concerns

Review all issues and determine if any require a consistent approach across files. Examples:
- Error handling pattern changes
- Naming convention updates
- API design consistency
- Shared type modifications

If cross-cutting concerns exist:
- Decide the approach first
- Document it clearly
- Include it in every teammate's instructions

If none, proceed directly to team creation.

### 5. Self-Critique Checkpoint

Before creating the team, verify:
- "Is my task split file-based, not issue-based?" — If issue-based, regroup. (C-3)
- "Will any two teammates modify the same file?" — If yes, merge those tasks. (C-3)
- "Did I resolve cross-cutting concerns first?" — If not, go back to step 4. (C-5)
- "Am I about to use the Agent tool instead of TeamCreate?" — If yes, STOP. Use AgentTeam. (C-2)

### 6. Create Team and Dispatch Teammates

Load the `team-review-fix:team-fix-strategy` skill to get teammate instruction rules.

Use TeamCreate to create the team.

For each file group, create a task with TaskCreate and assign to a teammate via SendMessage. Include in each teammate's instructions:

1. The specific issues to investigate and fix for their assigned file(s)
2. Cross-cutting design decisions (if any)
3. Required rules:
   - Investigate the issue first — verify it exists, understand the context
   - Present a fix plan BEFORE implementing. The plan must include: what was found, what will change, and why it addresses the root cause
   - Do NOT implement until the plan is approved
   - Commit after each fix with a descriptive commit message
   - Do NOT add Co-Authored-By trailer

### 7. Review Plans and Monitor Progress (continuous loop)

Do NOT wait for all teammates to finish before reviewing. Process each teammate's output as soon as it arrives.

Repeat the following loop until all teammates have completed implementation:

1. Check teammate progress using TaskGet and TaskOutput
2. For each teammate that has reported a plan but not yet been reviewed:
   - Evaluate using the `team-fix-strategy` skill's plan evaluation criteria
   - **Approve** if the plan addresses root causes (fixes the source, makes invalid states unrepresentable, adds validation at boundaries, prevents similar bugs)
   - **Reject** if the plan is symptomatic (suppresses errors, adds defensive checks where fix should be upstream, uses type assertions to bypass type errors, adds comments instead of fixing)
   - When rejecting: explain WHY, suggest root-cause direction, ask to revise and re-submit
   - When approving: tell the teammate to proceed with implementation, remind them to commit after each fix
3. For teammates already implementing, monitor for completion or issues
4. If a teammate encounters an unexpected issue: help them understand (you may read code for analysis), guide toward a solution, but do NOT write the fix yourself (C-1)

### 8. Self-Critique Checkpoint

After all teammates have completed, verify:
- "Did I approve any plan without checking if it's symptomatic?" — If yes, re-review it. (C-7)
- "Did any teammate start implementing before I approved?" — If yes, flag it. (C-8)
- "Did I write any code myself?" — If yes, violates C-1. Undo and delegate.

### 9. Report Completion

Once all teammates are done, summarize the results to the user:

- Total issues addressed
- For each file: what was changed and why
- List of commits made
- Any issues that could not be resolved (with explanation)

Output this summary directly in the terminal (do not write to a file).
