---
name: shelve-knowledge
description: Decides which shelf a piece of written knowledge belongs on — CLAUDE.md, README, docs/, a skill in .claude/skills/, adr/, references/, or notes/ — before it is written. Use when about to create, extend, or move a documentation file, a docs/ page above all, or when someone asks where something should be written down. Triggers on "where should this go", "document this", "write this down", "add it to the docs", "should this be a skill".
---

# Shelve a piece of knowledge

When this is done, the knowledge has exactly one home, its shelf's index points to it, and a reader who needs it will meet it.

1. Take the content one kind at a time. A page that mixes kinds is split, and each part is asked the questions separately.
2. Ask in this order; the first yes decides. The order matters: CLAUDE.md is asked last because it is loaded in every session and must stay the hardest shelf to enter.
   1. Does it stop mattering when its task ends — a memo, a review write-up, a prototype, a handover? → `notes/`
   2. Is it the record of a choice: what was decided, why, what was rejected? → `adr/`, through `write-adr`
   3. Is it raw data — rows, schemas, captured payloads — kept to check shapes against? → `references/`
   4. Is it carried out rather than known — steps with a moment they begin and an order to follow? → a skill in `.claude/skills/`. That someone is writing the steps down is evidence enough that they repeat.
   5. Does it describe what exists now, or state a rule to follow now? → a `docs/` page
   6. Is it the first thing a stranger should read: what this is and where everything lives? → root `README.md`
   7. Is it a value from which several distinct rules could be derived? → `CLAUDE.md`. A statement that can be followed as written and checked mechanically is a rule, and goes back to question 5.
3. When a rule and the steps that serve it arrive together, split them: the steps become the skill, the rule and its reason stay on the `docs/` page, and the skill links to the page.
4. When the content landed in `docs/`, ask once more: when this page is needed, will its reader know to come looking? If not, give the page a trigger — a rule in `.claude/rules/` with `paths` when the moment can be named by the files involved, otherwise a skill whose description names the situation. The trigger holds the condition and a link to the page, and nothing else. Never write a rule without `paths`, and never name a moment another trigger already names.
5. Before writing, search the shelves for the same content. When it already has a home, extend it there or link to it; do not write a second copy.
6. Write it in the form of its shelf, and update that shelf's index in the same change: the table in `docs/README.md` for pages and for procedure skills, the index in `adr/README.md` for records.
7. When the content reads as both a value and a rule, or fits two shelves equally, ask the owner. What a piece of knowledge means is theirs to say.

Verify: the new content is reachable from its shelf's index, and no durable shelf links into `notes/`.

The rule these steps serve: the contract section of [CLAUDE.md](../../../CLAUDE.md) and the documentation map in the root [README.md](../../../README.md).
