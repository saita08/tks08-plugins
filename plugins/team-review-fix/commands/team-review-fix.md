---
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Skill, Agent, SendMessage, TaskCreate, TaskGet, TaskList, TaskUpdate, AskUserQuestion
description: Fix review feedback by delegating to an agent team. Splits issues by file, each agent investigates, plans, and implements.
argument-hint: <review issues text or file path> (or omit to enter interactively)
---

Fix review feedback using a coordinated agent team. You act as the fellow, which is the role this session occupies for the duration of the run. The fellow coordinates teammates and reviews their plans, and does not write source code itself — C-1 in the principles file explains why this constraint is structural rather than stylistic.

The judgment principles that govern every action below are recorded in `commands/references/principles.md` as C-0 through C-20. Read that file before Step 0 and re-consult the relevant section whenever a step's actions touch the principle it describes. The Steps below reference those anchors by ID; the reasoning behind each anchor lives in the principles file, not here.

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

Per C-3, all parsed issues become fix targets regardless of their nature, confidence, or section label.

### 2. Preconditions

Before proceeding, confirm:
- At least one concrete issue exists to work on. If not, ask the user for clarification.
- All issues from the input are included regardless of type, confidence, or section label (C-3).

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

### 6. Record the Starting Commit

Before any teammate writes to the repository, run `git rev-parse HEAD` and remember the hash. This becomes the lower bound of the commit range that the simplification pass in step 10 will review. Recording it here, rather than later, ensures that the range covers exactly the work the team produced — no earlier commits the user did not ask to revisit, no later commits made outside the team.

### 7. Dispatch Teammates

Load the `team-review-fix:team-fix-strategy` skill. The skill itself records the splitting and evaluation criteria the fellow uses; the teammate-facing rules that must be forwarded at dispatch live in `skills/team-fix-strategy/references/teammate-rules.md`, which the skill directs the fellow to read.

There is no explicit team-creation step. The team forms implicitly the moment the first teammate is spawned, with this session as the lead (C-2).

For each file group:

1. Create a task with TaskCreate describing the work for that file group, then assign it by setting its owner to the teammate's name with TaskUpdate.
2. Spawn the teammate with the Agent tool, passing a stable `name` tied to the file group (for example `teammate-api` for `src/api.ts`) and `run_in_background: true` so the fellow can review partial output as it arrives rather than waiting for a one-shot return (C-2). The fellow refers to the teammate by this name for the rest of the run, so choose it at dispatch and remember it.

The teammate's spawn prompt must include:

1. The specific issues to investigate and fix for their assigned file(s)
2. Cross-cutting design decisions (if any)
3. The full contents of `skills/team-fix-strategy/references/teammate-rules.md`, forwarded verbatim. Do not paraphrase the rules; the "why" clauses on each rule are what teach the teammate when it applies, and a summary loses them

Every subsequent instruction to a teammate — plan approvals, rejections, the stand-down at Step 10 — goes through `SendMessage` addressed to that teammate's name.

### 8. Review Plans and Monitor Progress (continuous loop)

Do NOT wait for all teammates to finish before reviewing. Process each teammate's output as soon as it arrives.

The wait between iterations of this loop is passive (C-19). When no teammate has produced new output, control returns to the runtime rather than being held by a scheduled future prompt. Do not schedule a wake-up, a cron job, or any other future prompt whose body names this command — such a prompt, when it fires, re-enters Step 1 against the same input and produces a second team the fellow never approved.

Repeat the following loop until all teammates have completed implementation:

1. Check teammate progress: read each teammate's task state with TaskGet, and read the plans and commits they report through `SendMessage`. Teammate messages arrive automatically; the fellow does not poll for them
2. For each teammate that has reported a plan but not yet been reviewed:
   - Evaluate using the `team-fix-strategy` skill's plan evaluation criteria
   - Does the plan address the root cause — why the problem exists? (C-7)
   - If not, reject and name what the root cause actually is and what direction to pursue (C-8)
   - If yes, approve and tell the teammate to proceed. Remind them to commit after each fix
3. For each teammate that has just reported a commit, require the commit hash in the report (C-17) and immediately run `git show --stat <hash>` to confirm only files within that teammate's assigned scope appear. If foreign files have been swept in, halt that teammate and any teammate whose work was scooped up, and treat it as an incident under the procedure in step 7.5 (C-14)
4. For teammates already implementing, monitor for completion or issues
5. If a teammate encounters an unexpected issue: help them understand (you may read code for analysis), guide toward a solution, but do NOT write the fix yourself (C-1)

### 8.5 If a staging incident occurs

A staging incident means a commit contains files outside its author's assigned scope, or a teammate's unstaged work was swept into another teammate's commit. Recovery requires care because cooperative messaging does not preempt teammates mid-step (C-16). The procedure below applies to incidents detected during the monitoring loop in step 8; the same procedure is used for incidents detected during verification in step 9.

1. Send a stop instruction to each teammate individually by name, and require an explicit ACK from every teammate that includes their current `git status`. Do not begin recovery until all ACKs are in.
2. Re-read `git log` immediately before any destructive step — a teammate who had not yet read the stop instruction may have committed in the interim.
3. Choose the recovery method by what the history allows. If no commits have been built on top of the bad one, prefer `git reset --soft HEAD^` and re-commit with correct staging. If subsequent commits exist that cannot be cleanly recreated, use `git rebase -i <commit>^` with `reword` to make the message match the actual contents — this preserves history and carries no merge-conflict risk.
4. After recovery, send the new `HEAD` to every teammate individually and instruct them to re-observe their position with `git log -1` before resuming, per C-17.

### 9. Verify Outcomes

After each teammate reports completion, verify by examining the actual output — not the teammate's description (C-9):

1. Read the git diff of the teammate's commits
2. Confirm the changes match the approved plan. If they deviate, treat the deviation as unapproved and require a revised plan (C-10)
3. Confirm each commit contains only files within the teammate's assigned scope (C-14)
4. Confirm each issue assigned to the teammate is actually resolved in the diff
5. If any verification fails, send the teammate back to revise before accepting

Do NOT proceed to the simplification pass until all teammates pass verification.

### 10. Stand Down the Teammates

The new team infrastructure has no single-operation team deletion. What it has instead is per-teammate shutdown, and the boundary this step exists to draw — no teammate is active once the fellow starts writing to the index — is drawn by standing every teammate down explicitly.

Once every teammate has passed verification, send each teammate a `shutdown_request` through `SendMessage`, individually by name (C-16). A teammate approves with a `shutdown_response` and its process exits. Do not treat the request as the stand-down: a cooperative message is not an interrupt (C-16), so the teammate is down only once it has approved. Confirm the whole team is down by reading the `members` array in `~/.claude/teams/{team-name}/config.json` and seeing that only the lead remains; that confirmation is the structural successor to the old single `TeamDelete` call.

This stand-down is what reopens the fellow's permission to write code. The simplification pass that follows is the fellow's responsibility: the fellow is the one writing to the index when commits land, whether the pass itself is delegated to a skill or run inline. With no teammate active, there is no risk that a stray teammate writes to the index while the fellow is committing, and the C-1 relaxation applies only to the simplification pass, never to any phase in which teammates are still running (C-18).

### 11. Run the Simplification Pass

The simplification pass is delegated to Claude Code's built-in `/simplify`, invoked through the Skill tool with the skill name `simplify`. This is the cleanup-only review — it improves the quality of the changed code for reuse, simplification, efficiency, and altitude without hunting for correctness bugs (C-18). It is part of Claude Code itself, so there is no plugin to install and no availability check to perform; the requirement is only that Claude Code is recent enough to ship it (see the README).

The pass must review the commit range the team produced, not its default target of the working tree or the upstream diff. Pass the range `<starting-commit>..HEAD` — built from the starting commit recorded in step 6 — to the skill as its argument. If the skill does not accept the range through its argument, state in the invocation that the scope under review is exactly the diff `<starting-commit>..HEAD` so the range is unambiguous either way.

`/simplify` applies its fixes to the working tree. It must not commit them: committing is the fellow's responsibility under the path-limited rule in C-15. State this in the invocation.

After the pass returns, the fellow lands the result:

- Read the working tree with `git status` and the diff. For each file the pass modified, commit it with `git commit -- <path>` and a message describing what was simplified and why, consistent with C-15. Earlier teammate commits are not amended; the simplification fixes land as new commits on top.
- If the pass committed on its own despite the instruction, do not amend. Confirm with `git log` and `git show --stat <hash>` that each new commit contains only files within the team's commit range and does not sweep in foreign files; if a commit violates C-15, treat it as a staging incident and recover under the step 8.5 procedure.
- If the pass reports no changes, no commit is added.

Report the pass result in step 12 so the user can see that it ran, whether it changed anything or found nothing.

### 12. Report Completion

Once the simplification pass has finished, summarize the results to the user:

- Total issues addressed
- For each file: what was changed and why
- List of commits made by teammates
- The simplification pass result: what it changed, or that it ran and found nothing
- Any issues that could not be resolved (with explanation)

Output this summary directly in the terminal (do not write to a file).
