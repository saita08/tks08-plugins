---
name: draft-principle
description: This skill should be used when turning an observed, repeated friction (a correction, rejection, or rephrasing the user made to Claude more than once) into a principle proposal for a CLAUDE.md — for example when the user asks to "draft a principle", "turn this correction into a rule", "propose a CLAUDE.md addition", "write this as a constitution principle", "原則にする", or "憲法に載せる文案を書いて". Governs how the proposal text is written (as a general value, not the triggering symptom) and where it should be routed (personal versus project CLAUDE.md).
allowed-tools: Read
---

# Draft a principle from repeated friction

This skill governs the drafting step of a harvest: given friction that recurred two or more times, turn it into a principle the user could adopt into a `CLAUDE.md`. The output is a proposal, never an edit — the gardener drafts, the user judges and ratifies. Do not write to any `CLAUDE.md`.

The value of a constitution principle is entirely in its generality: a principle stated as a value, with the reasoning that makes it true, reaches cases that did not exist when it was written. A principle pinned to the specific symptom that spawned it does not. Everything here serves that.

Two reference files back this skill. Read the relevant one before acting; do not load both up front.

- `references/principle-writing.md` — how to write the proposed principle text: as a general value with its reasoning, with the observable behavior change it should produce, never pinned to the triggering incident. Read before drafting part 4 of a proposal.
- `references/friction-taxonomy.md` — the three kinds of friction, and the test for routing a principle to the personal versus a project `CLAUDE.md`. Read when interpreting friction events or deciding a proposal's target institution.

## The shape of a proposal

Each proposal has four parts, in order:

1. **Observed cases** — the concrete recurring events, with verbatim user quotes and the Claude action each corrected, and which session/project each came from. This is the evidence; without it the proposal is an assertion.
2. **Name of the failure class** — the general kind of failure, named so its next differently-shaped instance is still recognizable. Not the incident; the class the incident belongs to.
3. **Target institution** — personal `~/.claude/CLAUDE.md` or a specific project's `CLAUDE.md`, decided by the routing test in `friction-taxonomy.md`.
4. **Proposed principle text** — the paragraph the user could paste, written per `principle-writing.md`.

## The line the gardener does not cross

Drafting the proposal is the whole job. Do not edit any `CLAUDE.md`, do not commit, do not open a PR. The user is the constitution's author; the gardener only supplies a draft for them to accept, refine, or reject. This is not just a limitation — it is the proof that the tool cannot silently rewrite the rules it was asked to help improve.

## Resources

- `references/principle-writing.md` — Writing the principle as a general value; read before drafting proposal text.
- `references/friction-taxonomy.md` — The three friction kinds and the personal-vs-project routing test.
