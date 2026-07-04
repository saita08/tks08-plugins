---
name: suggest-handoff
description: This skill should be used when a work session reaches a natural break or the user signals they are stepping away or pausing — phrases like "今日はここまで", "続きは明日", "一旦中断", "let's stop here", "pick this up later", "I'm out for today", or when a large unit of work just completed and the conversation is likely to end. Guides offering to bottle up the current state as a handoff for the next session.
allowed-tools: Read
---

# Suggest a Handoff Bottle

When a session is about to end with work still in flight, the state that lives only in this conversation — what is in progress, what was decided and why, what comes next — evaporates when the session closes. The next session then pays to reconstruct it. A handoff bottle catches that state in a human-readable file before it is lost.

This skill is the judgment for *when* to offer a bottle and *how* to offer it well. The writing itself is done by the `/handoff-bottle:write` command.

## When to offer

Offer a bottle when both are true: work is genuinely in flight (there is real state worth carrying), and the session is likely ending or pausing. Signals that the session is ending:

- The user says so, in any form: "今日はここまで", "続きは明日", "一旦置いておく", "また後で", "let's stop here", "I'll pick this up tomorrow", "stepping away".
- A large unit of work just finished and the natural next move belongs to a later sitting.
- The user's attention is visibly winding down — shorter replies, "ありがとう", a sign-off.

Do not offer when there is nothing in flight (a clean stopping point with no open thread carries nothing), when the user is mid-thought and simply paused to think, or when a bottle was already written this session and nothing material has changed since.

## How to offer

Offer once, in one plain line, and let the user decide. The suggestion names the concrete value: the next session picks up without you re-explaining the state. Do not write the bottle unasked — a handoff the user did not want is noise in their project, and the file is theirs to commit or not.

If the user agrees, run `/handoff-bottle:write`. If they pass, drop it and do not raise it again this session.

## What this is, and is not

A bottle is not the built-in `/resume` or automatic conversation summarization. Those recover a machine's internal session state, which the user cannot easily read or edit and which does not travel outside the tool. A bottle is a plain Markdown file the user can read, correct, hand to a colleague, or commit to the repo. Offer it as what it is: a deliberate, human-legible handoff, not a substitute for the built-in recovery. When the user only needs to resume the exact same session, the built-in resume is the lighter tool; the bottle earns its place when the handoff should be legible, editable, or durable across sessions and people.
