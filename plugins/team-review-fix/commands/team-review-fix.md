---
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Skill, Agent, TeamCreate, TeamDelete, SendMessage, TaskCreate, TaskGet, TaskList, TaskOutput, TaskUpdate, AskUserQuestion
description: Fix review feedback by delegating to an agent team. Splits issues by file, each agent investigates, plans, and implements.
argument-hint: <review issues text or file path> (or omit to enter interactively)
---

Fix review feedback using a coordinated agent team. You act as the fellow (coordinator) — you do NOT write code yourself.

The judgment principles that govern every action below are recorded in `commands/references/principles.md` as C-0 through C-20. Read that file before Step 0 and re-consult the relevant section whenever a step's actions touch the principle it describes. The Steps below reference those anchors by ID; the reasoning behind each anchor lives in the principles file, not here.

## Steps

### 0. Re-entry Guard

Before Step 1 reads input, check whether the team this run would create in Step 7 already exists from a prior run (C-20). The check is a targeted read of `~/.claude/teams/{team-name}/config.json` for the team name this fellow would pass to `TeamCreate`, not a search across the teams directory — the workflow only needs to know about its own prior runs, and the name is one the fellow knows.

If that team file is absent, the prior run either never reached Step 7 or finished and was cleaned up by Step 10; proceed to Step 1 and treat the input as new.

If the team file is present, the prior run reached Step 7 against this input. Read the task store under `~/.claude/tasks/{team-name}/` and route by what it says:

- Any teammate still has outstanding work (a task that is not `completed`, or a `completed` task whose final commit hash has not been reported) → the prior wait was interrupted. Return to Step 8 and resume the review-and-monitor loop against the existing team. Do not call `TeamCreate`, `TaskCreate`, or `SendMessage` for any new work, since the team and its tasks already exist.
- All teammates have reported their final commits → verification may or may not have completed in the prior run. Verification leaves no artifact this run can read, so resume from Step 9 rather than from Step 10; re-running Step 9 against an already-verified team is harmless because the diff inspection it performs is idempotent.
- The task store under the team directory is empty or describes only completed work that has already been reported — the residue is from a run whose simplification pass and report finished but whose `TeamDelete` never ran. Call `TeamDelete` to remove the residue, then proceed to Step 1.

The check intentionally does not look at the working tree. Whether the tree is clean or dirty is not evidence of re-entry — a fresh run against a dirty tree is the normal case for this command — so the routing rests on the team file alone.

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

### 7. Create Team and Dispatch Teammates

Load the `team-review-fix:team-fix-strategy` skill. The skill itself records the splitting and evaluation criteria the fellow uses; the teammate-facing rules that must be forwarded at dispatch live in `skills/team-fix-strategy/references/teammate-rules.md`, which the skill directs the fellow to read.

Use TeamCreate to create the team.

For each file group, create a task with TaskCreate and assign to a teammate via SendMessage. Include in each teammate's instructions:

1. The specific issues to investigate and fix for their assigned file(s)
2. Cross-cutting design decisions (if any)
3. The full contents of `skills/team-fix-strategy/references/teammate-rules.md`, forwarded verbatim. Do not paraphrase the rules; the "why" clauses on each rule are what teach the teammate when it applies, and a summary loses them

### 8. Review Plans and Monitor Progress (continuous loop)

Do NOT wait for all teammates to finish before reviewing. Process each teammate's output as soon as it arrives.

The wait between iterations of this loop is passive (C-19). When no teammate has produced new output, control returns to the runtime rather than being held by a scheduled future prompt. Do not schedule a wake-up, a cron job, or any other future prompt whose body names this command — such a prompt, when it fires, re-enters Step 1 against the same input and produces a second team the fellow never approved.

Repeat the following loop until all teammates have completed implementation:

1. Check teammate progress using TaskGet and TaskOutput
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

### 10. Delete the Team

Once every teammate has passed verification, delete the team with TeamDelete. The team has no further work, and the simplification pass that follows is the fellow's responsibility: the fellow is the one writing to the index when commits land, whether the pass itself is delegated to an agent or run inline. Deleting the team here makes that boundary structural rather than conventional. With no teammates active, there is no risk that a stray teammate writes to the index while the fellow is committing, and the C-1 relaxation applies only to the simplification pass, never to any phase in which teammates are still running (C-18).

### 11. Run the Simplification Pass

The simplification pass is delegated to the `code-simplifier:code-simplifier` agent. The colon-qualified name resolves to the `code-simplifier` agent inside the `code-simplifier` plugin distributed by Anthropic on the `claude-plugins-official` marketplace. Before invoking, confirm the agent is available by looking for the exact string `code-simplifier:code-simplifier` in the Agent tool's list of `subagent_type` values. The lookup uses the colon-qualified form, never the short form `code-simplifier`, because the short form may match nothing or may match a different agent (C-18). If the colon-qualified entry is not listed, the plugin is not installed; skip this step, record the skip reason for step 12 as "plugin `code-simplifier:code-simplifier` not found in subagent list", and proceed.

If the agent is available, invoke it with Agent and `subagent_type: "code-simplifier:code-simplifier"`. The colon-qualified form is required here for the same reason it was required in the availability check. The prompt must include:

- The starting commit recorded in step 6, with the instruction that the scope under review is the diff `<starting-commit>..HEAD` rather than the agent's default of recently modified code in the working tree
- An explicit instruction to apply any fixes to the working tree but not to commit them, because committing is the fellow's responsibility under the path-limited rule in C-15
- A request to report, on completion, what was changed and why, or that nothing was changed

If the agent appeared available but the Agent invocation still fails, treat it as the unavailable case: skip the pass and record the actual error message from the Agent invocation, verbatim, as the skip reason for step 12. Do not paraphrase the error. The availability check and the invocation can disagree when the plugin is listed but the agent cannot be loaded, and both paths must lead to the same skip behavior so that a partial-installation state does not produce a half-finished pass. Recording the verbatim error matters because a `subagent_type not recognised` message, which would be the symptom of accidentally invoking with the short form, looks superficially like a "plugin not installed" outcome but has a different remedy.

After the agent returns, read the working tree diff. For each file the agent modified, commit it with `git commit -- <path>` and a message describing what was simplified and why, consistent with C-15. Earlier teammate commits are not amended; the simplification fixes land as new commits on top.

If the agent reports no changes, no commit is added. Report this state in step 12 so the user can see that the pass ran and found nothing.

### 12. Report Completion

Once the simplification pass has finished, summarize the results to the user:

- Total issues addressed
- For each file: what was changed and why
- List of commits made by teammates
- The simplification pass result: what it changed, that it ran and found nothing, or that it was skipped. When skipped, the reason is stated in the exact form recorded in step 11, which is either the verbatim error message from the failed Agent invocation or the "plugin `code-simplifier:code-simplifier` not found in subagent list" notice. The user reads this line to decide whether to install the plugin, fix the invocation, or accept the skip
- Any issues that could not be resolved (with explanation)

Output this summary directly in the terminal (do not write to a file).
