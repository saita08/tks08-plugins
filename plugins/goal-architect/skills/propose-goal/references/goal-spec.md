# `/goal` Spec — What This Skill Relies On

This file records the facts about Claude Code's `/goal` command that this skill's behavior depends on. Read it before producing a condition. When something here turns out to be wrong or outdated, fix it here, in one place.

The authoritative source is the official documentation at <https://code.claude.com/docs/en/goal>. Fetch it when a question is not answered by this file.

## What `/goal` does

`/goal` registers a session-scoped completion condition. After every turn, a separate evaluation model reads the conversation and decides whether the condition holds. If it does not, Claude continues working. If it does, the goal clears and control returns to the user.

The goal lives only for the current session. `/clear` removes it. A goal that was still active when a session ended is restored on `--resume` or `--continue`; an achieved or cleared goal is not.

## The two facts that shape every condition

Two properties of the mechanism shape how a condition must be written.

The evaluator cannot run tools. It only reads what has already been surfaced in the conversation. A condition that depends on a fact the evaluator cannot observe in the transcript will never resolve, regardless of whether the fact is true. A goal must be writable as something Claude's own output can demonstrate within the transcript.

The evaluator is also a different model from the working model. It does not share the working model's accumulated context. It reads the condition as a literal statement and judges it against the visible evidence. Ambiguity in the condition becomes ambiguity in the stopping decision.

Goal-setting is a translation problem: take what the user wants in human terms and produce a sentence that a fresh, tool-less reader can judge from a transcript.

## Surface details (current as of this writing; verify against the docs)

- The condition string can be up to **4,000 characters**.
- `/goal` with no argument shows the current state (active condition, turns evaluated, token spend, evaluator's most recent reason). If a goal was achieved earlier in the session, the achieved condition is shown instead.
- `/goal clear` removes an active goal. Aliases accepted: `stop`, `off`, `reset`, `none`, `cancel`.
- Non-interactive use: `claude -p "/goal <condition>"` runs the loop to completion in a single invocation. Ctrl+C interrupts it.
- The default evaluator is the "small fast model" for the session's provider (Haiku by default). Evaluation tokens are billed on that model.
- `/goal` requires the workspace to have accepted the trust dialog. It is unavailable when `disableAllHooks` is set in managed policy settings.

These surface details may shift between Claude Code releases. When something in this list contradicts behavior observed live, trust the live behavior and update the file.

## Adjacent mechanisms (not the same as `/goal`)

To avoid confusing them in user conversations:

- **`/loop`** runs a prompt on a time interval. `/goal` runs until a condition holds.
- **A custom Stop hook** also fires after every turn but lives in settings and applies across sessions. `/goal` is a session-scoped shortcut around the same hook mechanism.
- **Auto mode** approves tool calls within a turn but does not start new turns. `/goal` and auto mode compose: auto mode removes per-tool prompts, `/goal` removes per-turn prompts.

## When to consult the live docs

Re-fetch <https://code.claude.com/docs/en/goal> when:

- The user asks about a flag or behavior not covered here.
- A condition that should work according to this file does not resolve in practice.
- A Claude Code release notes mentions changes to `/goal`, hooks, the evaluator model, or auto mode.

Update this file when the live docs disagree with what is recorded above. Mechanism facts belong here, not in the constitution.
