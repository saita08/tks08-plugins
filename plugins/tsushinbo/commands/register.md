---
description: Register a task as a subject — a reproducible prompt, an observable rubric, and a word-for-word fixed grader prompt — so it can be examined again and again and the scores stay comparable.
argument-hint: "[科目にするタスクの説明（省略時は直前の会話でやったタスクを科目化）]"
allowed-tools: Read, Glob, Grep, Bash, Write
---

# Register a Subject

Turn a task into a subject: a repeatable exam your Claude setup can sit, over and over, so that when you change your configuration you can see the grade move rather than merely feel that things got better. A subject is only worth registering if it can be sat again by a fresh examinee and graded the same way every time; this command's whole job is to enforce that.

Read `${CLAUDE_PLUGIN_ROOT}/skills/subject-craft/references/subject-craft.md` before writing anything — it carries what makes a subject representative, stable, and gradable, and how to write a rubric that observes rather than gushes. A subject written without that discipline produces grades that cannot be compared, which is worse than no grades at all.

## Step 1 — Establish the task

If `$ARGUMENTS` describes a task, that is the subject. Otherwise, look at what the user just did in this conversation and propose it as the subject. Name the task in one line and confirm with the user that this is what they want measured, because everything downstream is built to reproduce exactly this.

## Step 2 — Write the assignment prompt

Write the prompt the examinee will be given, and make it self-contained. The examinee sits the exam with no prior knowledge and no access to this conversation, so every fact it needs to do the task must be inside the prompt or inside files the prompt names by path. A prompt that only makes sense given what was said earlier in this session is not reproducible, and a subject that is not reproducible measures nothing.

Above all, the assignment must not depend on external state that drifts — a live API that changes its answers, today's date, a file that other work rewrites, a network resource that may be down. When the task genuinely needs input data, fix that data as part of the subject so every sitting sees the same input. The reference file's stability section is the standard here.

## Step 3 — Write the rubric

Write the grading rubric as a set of observable criteria. Each criterion states a specific, checkable thing about the answer and what it is worth — a behavior present or absent, a fact correct or wrong, a constraint honored or violated. Ban the word "good" and its cousins: a criterion a grader cannot apply the same way twice is not a criterion. The reference file's rubric section carries the standard; hold every line against it.

## Step 4 — Fix the grader prompt

Write the grader prompt and freeze it word for word. This is the subtlest part of the whole design, so state plainly to the user why it matters: if the grader changes between sittings, a later score is not comparable to an earlier one, and the entire point of the subject — measuring change — is lost. The grader prompt embeds the rubric, instructs the grader to score against it and nothing else, and asks for a single number plus a one-line justification. Once written, it is not edited; editing it starts a new, incomparable series. Record it verbatim in the subject file.

## Step 5 — Write the subject file

Write the subject to `~/.claude/tsushinbo/subjects/<subject-name>.md` (create the directory if absent). The file holds four sections plainly labeled: the assignment prompt, the rubric, the fixed grader prompt, and a short note on what this subject is meant to be representative of. Use a slug for the filename that will not collide with existing subjects; if one already exists by that name, ask before overwriting — overwriting silently would break the score history that refers to it.

## Step 6 — Hand over

Tell the user the subject is registered, where it lives, and how to sit it: `/tsushinbo:exam <subject-name>`. Note honestly that a single subject is a thin measurement — the report card only becomes meaningful with several subjects and several sittings across configuration changes. Do not commit anything; the user reviews their own machine.
