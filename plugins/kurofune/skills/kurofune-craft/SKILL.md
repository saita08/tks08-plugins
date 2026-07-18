---
name: kurofune-craft
description: This skill should be used when the user wants to delegate implementation work to Grok Build or Grok 4.5, mentions "Grokに投げて", "Grokにやらせて", "grok build", "kurofune", or asks Claude to use Grok like a subagent from the main conversation. Provides the doctrine for calling kurofune MCP tools (task / resume / doctor) from the main context.
user-invocable: false
allowed-tools: Bash, Read
---

# Kurofune Craft

Kurofune turns xAI's Grok Build into a **main-context tool**, not a hidden warehouse worker. Claude stays the orchestrator in the same conversation the user is talking to: it designs, dispatches Grok, reads the returned result, verifies the working tree, and resumes the same Grok session when a correction is needed. Grok is the hand that types; Claude is the judgment that decides what was worth typing.

## Call the MCP tools from the main conversation

Prefer the plugin MCP tools (names are prefixed by Claude Code, and include `task`, `resume`, and `doctor` on the `kurofune` server):

| Tool | When |
| --- | --- |
| `task` | First dispatch of a self-contained implementation job |
| `resume` | Every correction or follow-up on that same job |
| `doctor` | Immediate failure, missing binary, or first-time setup check |

Do **not** spawn a separate Claude agent solely to wrap these tools. That double hop is how session ids and completion results get dropped. Call the tools yourself, keep `sessionId` in this conversation, and verify.

If MCP is unavailable, the same surface exists as a script:

```
"$CLAUDE_PLUGIN_ROOT/scripts/kurofune.sh" task   [-r] [-C DIR] [-m MODEL] "PROMPT"
"$CLAUDE_PLUGIN_ROOT/scripts/kurofune.sh" resume [-r] [-C DIR] [-m MODEL] SESSION_ID "PROMPT"
"$CLAUDE_PLUGIN_ROOT/scripts/kurofune.sh" doctor
```

Default model is `grok-4.5` (`KUROFUNE_MODEL` or `-m` / tool `model` overrides it).

## What to delegate

Delegate what is mechanical and specified: implementations against an agreed interface, known refactors, boilerplate, test suites for settled behavior. Keep what requires judgment: design decisions, cross-cutting changes, anything whose specification is still forming, and final review. A task is ready for Grok exactly when its "done" can be stated observably in the prompt; if it cannot, finish the specification first.

## How to write the prompt

Grok sees none of this conversation. Every `task` prompt must include:

- the goal
- the relevant file paths
- project conventions and constraints that matter
- what "done" looks like as an observation
- always: `Do not commit; leave changes in the working tree.`

Point `cwd` at a **git-tracked** directory so every change is reviewable and revertible. Never put secrets in a prompt.

## Sessions are Grok's memory

One job is one Grok session. The first `task` returns `sessionId`; every correction uses `resume` with that id. Starting a fresh `task` to "fix" a previous run throws the worker's context away. Keep `sessionId` until the job is closed.

## Trust the tree, not the speech

Whatever Grok claims in `text`, the evidence is `gitStatus` / `gitDiffStat` in the tool result, the files on disk, and the project's tests. Read the diff. Run the tests when they exist. After two or three `resume` rounds without convergence, stop and report failure honestly.

Review-only work sets `review: true` (or `-r` on the script). That path forces a default permission mode and strips write/shell tools. A `stopReason` of `Cancelled` in review mode means the job needed write mode or a narrower read-only brief — not a blind retry.

## Parallelism

Split only into areas that touch disjoint files. Run one `task` per area (each gets its own session). Merge and review in this conversation. If two areas cannot be made disjoint, they are one task.

## Prerequisites

The owner installs Grok Build (`curl -fsSL https://x.ai/cli/install.sh | bash`) and runs `grok login` (SuperGrok or X Premium+). `doctor` checks both. Full Grok envelopes are also written under `$TMPDIR/kurofune-results/` (`resultFile` in the tool payload) so a truncated view can still recover `sessionId`.
