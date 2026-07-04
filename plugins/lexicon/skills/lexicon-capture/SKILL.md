---
name: lexicon-capture
description: This skill should be used when, during a conversation, the user corrects or fixes the meaning of a term, defines a word, or asks to standardize on a wording — e.g. "それは〜じゃなくて〜のこと", "その用語の定義が違う", "この意味でこの言葉を使って", "統一して", "when I say X I mean Y", "that's not what I mean by X", "let's call it X". Use it to offer to record the agreed term into the project glossary so future sessions share the same vocabulary.
allowed-tools: Read, Edit, Write
---

# Capture an Agreed Term

When you and the user settle the meaning of a word, that agreement is worth keeping. Left in the conversation, it dies with the session, and the next session makes the same mistake — the user corrects the same term again. This skill turns a one-time correction into a durable entry in the project glossary at `.claude/lexicon.local.md`, which the plugin's SessionStart hook replays into every future session.

The whole value rests on one discipline: the glossary records what the user *agreed to*, not what you inferred. So you propose, and the user confirms, before anything is written. See `references/ledger-format.md` for the exact file format; read it before your first write in a session.

## When this applies

A term is a candidate for the glossary when the user does something like:

- corrects a definition you used ("それは〜じゃなくて〜", "that's not what I mean by X"),
- fixes or narrows the meaning of a word ("その用語の定義が違う"),
- asks to standardize on a particular wording ("この言葉で統一して", "let's always call it X"),
- gives a word a project-specific meaning that differs from its ordinary sense.

It does not apply to a passing mention, a definition you supplied that the user never engaged with, or ordinary domain vocabulary the user used correctly and never flagged. The signal is a *correction or a deliberate definition*, not merely a term appearing.

## Procedure

### 1. Notice and form the entry

When a term gets corrected or defined, form a candidate entry: the term, its agreed meaning in one line, and the one-line context in which it was agreed (what were you doing when it came up). Keep the meaning to the user's intent, not a dictionary gloss.

### 2. Offer to record it — do not write unbidden

Tell the user, in one sentence, that you can add this term to the project glossary, and show the entry you would write. Ask whether to record it. Wait for a yes.

This is not a formality. The glossary is injected into every future session, so a wrong or unwanted entry does lasting harm — it teaches future sessions the wrong thing, silently. Writing only on confirmation keeps the glossary trustworthy and keeps this skill from editing the user's project on its own initiative. Do not write, and do not create the file, before the user agrees.

### 3. Append the entry

On confirmation, append the row to `.claude/lexicon.local.md`, following `references/ledger-format.md`. If a row for the same term already exists, update that row rather than adding a duplicate — the glossary should hold one agreed meaning per term, and a later correction supersedes an earlier one. Create the file with its header if it does not yet exist.

### 4. Confirm briefly and move on

Say in one line that it is recorded, and return to the work. Do not restate the whole glossary; do not turn this into a ceremony.

## Constraints

- Never write to the glossary without the user's explicit confirmation of the specific entry. A general willingness to keep a glossary is not approval of this entry.
- One agreed meaning per term. A new correction updates the existing row; it does not append a second, contradictory one.
- The glossary lives in the project at `.claude/lexicon.local.md` — a place the user can see and edit. Do not keep this vocabulary in any private or hidden store.
- Keep each entry to one line of meaning and one line of context. The glossary is a quick-reference, not an essay; long entries defeat the injection budget.

## Resources

- `references/ledger-format.md` — the exact format of `.claude/lexicon.local.md` and how to append or update a row.
