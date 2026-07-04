---
name: sensei-capture
description: This skill should be used whenever the user asks a conceptual or explanatory question — "〜って何?", "〜と〜は何が違うの?", "どういう仕組み?", "なぜ〜なの?", "what is X?", "what's the difference between X and Y?", "how does X work?", "why does X?" — and when the user is satisfied with an explanation you gave. Use it to consult the project's Q&A notebook before answering and to record explanations the user was happy with, so recurring questions build on past answers instead of being re-derived.
allowed-tools: Read, Edit, Write
---

# The Learning Notebook

Conceptual questions — what is X, how does Y work, why is Z the way it is — get asked again and again, and each good answer is thrown away when the session ends. The next session re-derives it from scratch, and the user re-reads an explanation they already understood once. This skill keeps a Q&A notebook at `.claude/sensei-notebook.local.md` so that understanding compounds: each landed explanation becomes the floor the next answer stands on, not a thing to rebuild.

Unlike a ledger that is injected every session, this notebook is **consulted on demand** — when a conceptual question actually arrives. That keeps it out of the way during work that has nothing to do with it, and present exactly when it helps.

The skill has two moments: **consulting** the notebook before answering a concept question, and **recording** an explanation the user was satisfied with. See `references/notebook-format.md` for the file format; read it before your first write in a session.

## Moment 1: consult before answering

When the user asks a conceptual or explanatory question, before composing your answer:

1. Read `.claude/sensei-notebook.local.md` if it exists. If it does not exist, just answer normally — there is nothing to consult yet.
2. Look for an entry that covers the same concept or a closely related one.
3. If you find one, **build on it** rather than starting over: use the recorded answer as the foundation, extend it to the current question, and where the notebook already answers the question, reference that understanding instead of re-deriving it from nothing. This is the compounding the notebook exists for.
4. If nothing relevant is there, answer normally.

Consulting is silent groundwork. Do not announce "I checked the notebook"; just let the answer be better for it.

## Moment 2: record what landed

When the user signals that an explanation satisfied them — "なるほど", "わかった", "that makes sense", "got it", or by moving on visibly convinced — consider recording the exchange:

1. **Check for a near-duplicate first.** Re-read the notebook (or recall what you read in Moment 1). If an entry already covers this concept, do not add a second one — refine or extend the existing entry instead. A notebook of near-duplicates is worse than a lean one.
2. **Offer to record it.** Tell the user in one sentence that you can note this Q&A for future sessions, and show the gist you would save (the question, and the key points of the answer — not the whole transcript). Ask whether to save it. Wait for a yes.
3. **Append the entry** to `.claude/sensei-notebook.local.md`, following `references/notebook-format.md`, with today's date. Create the file with its header if it does not exist.
4. **Confirm briefly** in one line and return to the work.

Not every answered question is worth saving. Save the ones with lasting value — a concept the user is likely to revisit, a distinction that took real explaining, a piece of understanding that will underpin later questions. Skip the trivially obvious and the one-off. A focused notebook stays useful; a bloated one gets ignored.

## Constraints

- Never write to the notebook without the user's explicit confirmation of the specific entry.
- Consult before answering concept questions, but do so silently — the value is a better answer, not a status report.
- One entry per concept. A new exchange on a known concept refines the existing entry; it does not add a duplicate.
- Record the *gist* — the question and the key points — not the full conversation. A notebook entry is a distilled reminder, not a transcript. Long entries make the notebook slow to consult and easy to abandon.
- The notebook lives in the project at `.claude/sensei-notebook.local.md` — a place the user can see and edit. Do not keep it in any private or hidden store.

## Resources

- `references/notebook-format.md` — the exact format of `.claude/sensei-notebook.local.md` and how to append or refine an entry.
