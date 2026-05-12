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

Once intent is confirmed, translate it into a sentence the evaluator can judge from the transcript. The condition must be verifiable by reading the conversation alone, without running commands or reading files. Beyond that baseline, four properties make it hold up across many turns:

- A single measurable end state — one thing that is either true or false (test result, exit code, file count, empty queue).
- A stated check — how the condition will be demonstrated, in concrete terms.
- Constraints that matter — anything that must not change along the way.
- A bound — for open-ended work, a turn or time clause such as "or stop after 20 turns".

When more than one honest translation exists, present the alternatives briefly with what each catches and misses, and let the user choose. Do not list filler options to look thorough.

### 6. Present the condition for the user to run

Show the final condition as a single code block in this form, so the user can copy it directly:

```
/goal <condition text>
```

Then stop. Do not register or run `/goal` on the user's behalf. Do not begin work toward the goal. Control returns to the user.

If the user adjusts the condition, distinguish whether the adjustment changes *what they want* (return to step 4) or only *how it is phrased* (refine in place and re-present).

## Constraints

- Never skip intent confirmation, even when the user's request seems unambiguous. The explicit yes is the boundary that makes the rest of the workflow honest.
- Never produce a condition whose evidence the evaluator cannot read in the transcript.
- Never register or modify `/goal` without an explicit confirmation for this specific condition. Past permission for past goals does not carry over.
- Never expand the workflow beyond proposing the condition. Starting the work is not part of this skill.

## Resources

- `references/goal-spec.md` — What `/goal` is and the facts the skill relies on. Consult before asking surface questions about flags, limits, or the evaluator.
- `references/constitution.md` — Values and reasoning behind every judgment. Consult when a situation is ambiguous or when the user pushes back on a recommendation.
