---
name: kurofune-craft
description: This skill should be used when the user wants to delegate implementation work to Grok Build or an external coding CLI, mentions "Grokに投げて", "Grokにやらせて", "grok build", "ワーカーエージェント", or asks how Claude Code can orchestrate Grok as a worker, or when Claude is about to dispatch or parallelize kurofune-worker agents and needs the division-of-labor doctrine. Provides the orchestration discipline for supervised Grok Build workers.
allowed-tools: Bash, Read
---

# Kurofune Craft

Kurofune turns xAI's Grok Build CLI into a supervised worker fleet. Claude Code stays the orchestrator -- it designs, splits, reviews, and integrates -- while Grok Build sessions execute well-specified implementation work headlessly. Dispatching goes through the `kurofune-worker` agent; this skill carries the doctrine for using it well.

## Division of labor

Delegate to a worker what is mechanical and specified: implementations against an agreed interface, known refactors, boilerplate, test suites for settled behavior. Keep with the orchestrator what requires judgment: design decisions, cross-cutting changes, anything whose specification is still forming, and all review. A task is ready for delegation exactly when its "done" can be stated observably in the prompt; if it cannot, the specification work is not finished.

## Sessions are the worker's memory

One task is one Grok session. The first dispatch returns a `sessionId`; every correction and follow-up resumes that session, because the feedback only makes sense inside the context the worker built up. Starting a new session to "fix" a previous one throws that context away and pays full price to rebuild it. Keep the sessionId in the conversation until the task is closed.

## Parallel execution

Parallelism is created by the orchestrator's task splitting, not by machinery. Split the job into areas that touch disjoint files, spawn one `kurofune-worker` agent per area, and let each drive its own Grok session. The workers never coordinate with each other; the orchestrator merges and reviews. If two areas cannot be made disjoint, they are one task, not two.

## Trust boundary

Workers write to the working tree of a git-tracked directory and never commit. Whatever a worker claims, the evidence is `git diff`, the changed files, and the project's own tests -- the supervising agent verifies before reporting, and the orchestrator reviews before anything enters history. Review-only work runs in review mode (`-r`), which removes the worker's ability to write at the permission level rather than by request.

## Prerequisites and failure modes

The owner installs Grok Build (`curl -fsSL https://x.ai/cli/install.sh | bash`) and runs `grok login` themselves; a SuperGrok or X Premium+ subscription is required. `"$CLAUDE_PLUGIN_ROOT/scripts/kurofune.sh" doctor` checks both. Headless runs have no TTY: in write mode the worker auto-approves its own tools, and in review mode any tool call that would need approval cancels the run -- a cancelled review run means the task needed write mode or a narrower scope, not a retry.
