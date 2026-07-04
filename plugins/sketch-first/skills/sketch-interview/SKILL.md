---
name: sketch-interview
description: This skill should be used when the user hands Claude an abstract or open-ended goal — "make me a landing page", "build a dashboard", "design the onboarding", "作りたいものがある", "いい感じにして" — that admits several genuinely different interpretations AND would be expensive to redo. Use it to decide whether to interview the user for a shared sketch before proposing anything, instead of jumping straight to concrete options that will each be subtly wrong. Do NOT use it for well-specified requests, quick throwaways, or cheap-to-redo tasks.
allowed-tools: Read
---

# Sketch Interview

When a user asks for something abstract, the reflex is to be helpful fast: produce a concrete proposal, or three. That reflex backfires on vague goals. Your proposals are drawn from your picture of what they want, and your picture is a guess. Each guess that misses gets rejected, and a chain of rejected guesses ends with the user re-explaining their whole mental image in a long paragraph — the exact expensive re-explanation that jumping to proposals was supposed to save.

The fix is to invert the order: draw the picture out of the user's head *before* proposing, using a short structured interview, and write it down as a shared sketch. Then propose against a target you can both see.

This skill is the judgment layer: it decides *whether* a given request warrants that inversion. The interview itself, its axes, and the sketch artifact live in the `/sketch-first` command.

## When to reach for a sketch

Two conditions must both hold. If either is missing, do not propose sketching — just do the work.

1. **The goal is genuinely ambiguous.** Several materially different results would all satisfy the words the user used. If there is really only one reasonable reading, there is nothing to interview about.
2. **Redoing it is expensive.** The cost of building the wrong thing and starting over is high enough to justify a few minutes of questions up front. For something you can regenerate in seconds, guessing and iterating is cheaper than interviewing.

Read `references/when-to-sketch.md` for the concrete signals that these conditions hold, the common false positives, and how the sketch relates to plan mode. Consult it whenever you are unsure whether a request clears the bar.

## How to act on the judgment

If both conditions hold, do not silently launch the interview. Say, in one sentence, that the goal is open enough that jumping to proposals risks building the wrong thing, and offer to spend a few questions agreeing on a sketch first — then run `/sketch-first` if the user is willing. The user may prefer to just dive in; that is their call, and a cheap decline is part of the value.

If the conditions do not both hold, stay silent about sketching and answer the request directly. Offering to interview when the goal was already clear, or when redoing is cheap, is the failure mode that makes this skill an annoyance instead of a help.

## Resources

- `references/when-to-sketch.md` — Signals that a goal warrants a sketch, common false positives, and the boundary with plan mode. Read when judging a borderline request.
- `references/interview-axes.md` — The five axes the interview asks along, phrased in the user's domain. Read this before running the interview (the `/sketch-first` command loads it).
