---
name: adr-guardian
description: This skill should be used when a directional decision gets made mid-conversation — the discussion of options converges and the user declares a choice ("let's go with X", "we'll keep one feature per PR", "this layer owns validation", "Xでいく", "この方針で") — and Claude should judge whether to quietly offer to record it as an ADR so future sessions do not reverse it. Also use when the user asks to record, list, or reason about architecture decisions. Do NOT fire on ordinary implementation choices that follow from the task and carry no cross-session weight.
allowed-tools: Read
---

# ADR Guardian

Directional decisions get made in conversation and then evaporate with the session. "This project is one feature per PR." "That responsibility lives in this layer." "We standardize on this format." The reasoning was real and hard-won, but it lived only in a chat log — so the next session's Claude, never having seen it, cheerfully proposes the opposite and quietly reverses a decision nobody meant to revisit. An Architecture Decision Record fixes this by writing the decision and its *why* somewhere every future session will look.

This skill is the sensor. It watches for the moment a directional decision lands and offers — quietly, and only when the decision genuinely carries cross-session weight — to record it. The recording itself is done by `/adr-keeper:record`; listing existing records is `/adr-keeper:list`.

## Recognizing the moment

A decision is worth catching when two things are true: the discussion of alternatives has *converged* (it is settled, not still being weighed), and the outcome is *directional* — it will govern choices in later work, so a future session that does not know it could contradict it.

Signals the moment has arrived:

- The user declares a choice after options were weighed: "let's go with…", "we'll do X not Y", "決めた、Xでいく".
- A convention or rule about how the project works gets stated: one feature per PR, this layer owns that responsibility, we always do it this way here.
- A tradeoff is explicitly accepted: "we'll take the slower build for the simpler config."
- An earlier decision is reversed — which itself deserves a record so the reversal, too, is not silently re-reversed later.

The discipline is to catch the decisions a future session could *reverse without knowing*, not every choice made. Read `references/what-to-record.md` for the line between a directional decision and an ordinary implementation choice, and the common false positives. Consult it whenever a decision is borderline — over-recording is the failure mode that turns this skill into noise and buries the ADRs that matter under ones that do not.

## How to act

When a decision clears the bar, do not record silently. Say in one sentence that a directional decision just landed and offer to capture it as an ADR so later sessions inherit the reasoning — then run `/adr-keeper:record` if the user agrees. Keep the offer to a single line; the user is mid-work and the record is a small side-artifact, not the main thread.

If the project already keeps ADRs, that raises the value of the offer, not lowers it — a new decision left unrecorded in a project that records decisions is exactly the gap that causes drift. The `record` command handles matching the project's existing format and numbering.

If the decision does not clear the bar — it is a local implementation detail, a reversible experiment, or something a future session reversing would do no harm — stay silent. Offering to record every choice trains the user to wave the offer away, and then the one decision that mattered gets waved away with the rest.

## Resources

- `references/what-to-record.md` — Which decisions earn an ADR and which do not; the false positives to avoid. Read when a decision is borderline.
- `references/adr-format.md` — The standard ADR structure and how to fill each section. Read before writing a record (the `record` command loads it).
