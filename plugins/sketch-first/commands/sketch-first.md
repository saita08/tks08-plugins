---
description: Interview the user about a vague goal before proposing anything, then summarize the answers into a one-page sketch and confirm it.
argument-hint: [what you are about to build or decide (optional)]
allowed-tools: AskUserQuestion, Read, Glob, Grep
---

# Sketch First

The user is about to build or decide something, and it is still abstract enough that several genuinely different things would all satisfy the words. Do NOT start proposing concrete options. Proposing first anchors the user on your first shape, and when each proposal is subtly wrong they get rejected one by one until the user gives up and re-explains the whole picture in a long paragraph — which is the exact cost this command exists to avoid.

Instead, run a short structured interview to draw out the picture already in the user's head, write it down as a one-page sketch, and get their confirmation. Only after the sketch is agreed do you move on to concrete proposals — and by then you are matching a target you can see, not guessing at one you cannot.

The subject of the interview is `$ARGUMENTS` if provided; otherwise it is whatever the user was just asking you to build.

## Before you start

Read `${CLAUDE_PLUGIN_ROOT}/skills/sketch-interview/references/interview-axes.md`. It defines the five axes to interview along and how to phrase each one inside the user's domain rather than yours. Do not skip this — the value of the sketch is entirely in asking the right questions, and the axes are what keep the questions about the product rather than the implementation.

If there is project context that would make your questions sharper (an existing README, similar features already in the repo, a design doc), glance at it first with Read/Glob/Grep so the interview builds on what is already there instead of asking about it.

## Procedure

### 1. Interview along the axes

Use `AskUserQuestion` to ask about the axes defined in the reference. Ask about the axes that actually carry ambiguity for this particular goal — do not mechanically ask all five if two of them are already obvious from what the user said. Each question is posed in the user's language: about who the thing is for, what "done well" looks like, what it resembles and what it must not resemble, what is non-negotiable, and what genuinely does not matter.

Batch related questions so the user answers in as few passes as possible. Offer concrete options where you can — a reference image the user reacts to ("more like A, less like B") pulls the picture out faster than an open-ended prompt. Always leave room for an answer you did not anticipate; the point is to surface the user's picture, not to make them pick from yours.

### 2. Draw the sketch

Collect the answers into a single short sketch — the one-page picture of what is to be built, in the user's own terms. It names who it is for, what success looks like, what it resembles and what it avoids, the hard constraints, and the explicit don't-cares. Keep it to something the user can take in at a glance. This is a requirements picture, not a design or an implementation plan.

Write the sketch to `.claude/sketch-first.local.md` in the project (create the `.claude/` directory if needed) so it survives the session and later work can refer to it. Use YAML frontmatter for the axis answers and Markdown prose for the sketch itself. If a sketch file already exists, show the user what is there and offer to refine it rather than silently overwriting.

### 3. Confirm before proposing

Show the sketch to the user and ask, in plain text, whether it matches the picture in their head. Correct it until they confirm. A correction is not a detour — it is the interview working. Do not move to concrete proposals until the sketch is confirmed.

### 4. Hand off to the real work

Once the sketch is confirmed, say plainly that the picture is agreed and now the concrete work can begin against it. From here you propose, design, or build as usual — but every proposal is now checkable against a target you both share. Do not re-run the interview; the sketch is the shared ground you build on.

## What this command does not do

- It does not produce an implementation plan. That is what the built-in plan mode is for. This command settles *what* to build; plan mode settles *how*. Running this first makes plan mode's job easier, because a plan against an agreed sketch is worth reviewing.
- It does not build anything or edit code. Its only artifact is the sketch file.
- It does not force all five axes. Ask only where real ambiguity lives.
