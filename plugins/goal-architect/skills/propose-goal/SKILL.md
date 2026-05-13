---
name: propose-goal
description: This skill should be used when the user asks to "propose a goal", "draft a /goal", "help me write a /goal condition", "what should my goal be", or otherwise needs help formulating a stopping condition for Claude Code's /goal command. Observes the project, confirms the user's intent in plain language, and proposes a verifiable /goal condition string for the user to run.
argument-hint: [何を終わらせたいか（省略可）]
allowed-tools: Read, Glob, Grep, Bash, WebSearch, WebFetch
---

# Propose a Goal

Help the user formulate a `/goal` condition that the evaluator can judge from the transcript. Two reference files back this skill. `references/goal-spec.md` records what `/goal` actually does — its mechanism, the evaluator, the surface flags. `references/constitution.md` records the principles that guide the work. Read both before proposing a condition, and re-consult either when something feels off.

The workflow has two phases and they must not collapse into one. First, intent confirmation: restate what the user wants in plain language and iterate until they explicitly say it is right. Second, condition formulation: translate the confirmed intent into a `/goal`-shaped sentence and present it for the user to copy and run. The boundary between phases prevents `/goal` from stopping on a condition the user did not actually want.

## Procedure

### 1. Read the spec and the constitution

Open `references/goal-spec.md` to confirm what `/goal` can and cannot do in its current form, then `references/constitution.md` to ground the judgment principles. Re-consult either when a situation feels ambiguous.

### 2. Hear what the user wants

If the invocation included an argument, treat it as the starting statement of intent. If not, ask in one sentence what they want to finish.

Ask one question, not a survey.

### 3. Observe the project

Gather evidence that bears on the user's statement. Stop as soon as enough is known to either confirm the intent or surface a hypothesis. Typical sources, used in roughly this order:

- `CLAUDE.md`, `README.md`, and any `docs/` material — stated intent and constraints
- Recent `git log`, current `git status`, the working branch name — what is in motion
- Failing tests, failing lint, broken builds — what is concretely unfinished
- `gh pr list`, `gh issue list` for the current repository — acknowledged work that may be relevant
- External documentation via `WebFetch` — only when the user's intent references a specification outside the repo

Treat what is found as evidence, not as the user's intent. The README is what someone wrote at some point. The user's intent is what they want now.

### 4. Confirm intent in plain language

State back what the user wants in one or two plain sentences. If observation surfaced something that might or might not be part of the goal, mention it as a hypothesis and ask. Iterate until the user explicitly confirms.

Do not propose a `/goal` condition during this phase. The user is being asked to agree about *what they want*, not about *how it will be checked*.

### 5. Formulate the condition

Once intent is confirmed, translate it into a sentence the evaluator can judge from the transcript. The condition must be verifiable by reading the conversation alone, without running commands or reading files.

Structure every condition as three layers, in this order:

1. **The goal in plain language.** Open the condition with one sentence stating what the user actually wants, in their words. "Finish the app to App Store submission readiness." "Refactor the auth module so login works under the new API." Without this layer, the working model and the evaluator both lose sight of the underlying purpose, and the condition becomes a target for the proxy that follows.
2. **The evidence that proves the goal.** Spell out what must be observable in the transcript for that goal to be considered met. When the evidence is a proxy — a status file, a checklist, a report — name the proxy and immediately pair each proxy item with an independent artifact the evaluator can see, such as a file at a specific path, a build exit code, or a test result. The proxy alone is never the stopping condition.
3. **Constraints and a bound.** Anything that must not change on the way there. For open-ended work, a turn or time clause such as "or stop after 20 turns".

Apply these four properties throughout:

- A single measurable end state — one thing that is either true or false, such as a test result, an exit code, a file count, or an empty queue.
- A stated check — how the condition will be demonstrated, in concrete terms.
- Constraints that matter — anything that must not change along the way.
- A bound — for open-ended work, a turn or time clause.

Avoid two specific traps. First, never let a condition open with a means — sentences like "Create file X" or "Fill in checklist Y" describe how to demonstrate the goal, not the goal itself, and belong in the evidence layer rather than at the head. Second, never end a condition with "Claude reports that this is done" or "all items are marked complete in the transcript." Reporting is not evidence; the evidence must be visible to the evaluator without trusting Claude's own assertion that it exists.

When more than one honest translation exists, present the alternatives briefly with what each catches and misses, and let the user choose. Do not list filler options to look thorough.

When the goal genuinely cannot be made verifiable without proxies, say so to the user, name the proxies the condition will rely on, and confirm that those proxies together would convince them the goal is met. The agreement is what stops the proxies from running away with the work.

### 6. Present the condition for the user to run

Show the final condition as a single code block in this form, so the user can copy it directly:

```
/goal <condition text>
```

Then stop. Do not register or run `/goal` on the user's behalf. Do not begin work toward the goal. Control returns to the user.

If the user adjusts the condition, first decide which kind of adjustment it is. When the adjustment changes *what they want*, return to step 4 and re-confirm intent before re-translating. When it only changes *how the condition is phrased*, refine the wording in place and re-present.

## Constraints

- Never skip intent confirmation, even when the user's request seems unambiguous. The explicit yes is the boundary that makes the rest of the workflow honest.
- Never produce a condition whose evidence the evaluator cannot read in the transcript.
- Never register or modify `/goal` without an explicit confirmation for this specific condition. Past permission for past goals does not carry over.
- Never expand the workflow beyond proposing the condition. Starting the work is not part of this skill.

## Resources

- `references/goal-spec.md` — What `/goal` is and the facts the skill relies on. Consult before asking surface questions about flags, limits, or the evaluator.
- `references/constitution.md` — Values and reasoning behind every judgment. Consult when a situation is ambiguous or when the user pushes back on a recommendation.
