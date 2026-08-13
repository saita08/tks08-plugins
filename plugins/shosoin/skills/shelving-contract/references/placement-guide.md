# Placement Guide

How to decide where a document, a section, or a single paragraph belongs. Apply to whole files first, then to the sections inside files that turn out to be mixed.

## The classification questions

Ask in this order; the first yes wins. The order is load-bearing: the constitution comes last because it must be the hardest shelf to enter — only knowledge every other shelf has refused may apply to live there. Asking it first inverts the gate and grows the one document every session pays for.

1. **Is it a work product that stops mattering when its task ends — a memo, a review write-up, a prototype, a handover?** → `notes/`.
2. **Is it the record of a choice: what was decided, why, what was rejected?** → `adr/`.
3. **Is it raw data — rows, schemas, captured payloads — kept for reference rather than read as prose?** → `references/`.
4. **Does it describe what exists right now, or state a rule to follow now: structure, procedures, contracts, conventions, environment constraints?** → `docs/`.
5. **Is it the first thing a stranger should read: what this project is and where everything lives?** → root `README.md`.
6. **Is it a value that grounds judgment across situations — one from which several distinct rules could be derived?** → `CLAUDE.md`.

Content that answers none of these is usually not documentation: generated output, tool state. Leave it alone or question its existence, but do not force it into a shelf.

The boundary between questions 4 and 6 is the touchstone from the contract: a statement from which several distinct rules can be derived is a value; a statement followable as written and mechanically checkable is a rule, and rules live in `docs/` as conventions. Knowledge that reads as both is not classified silently — ask the human who owns its meaning.

## Common misplacements and their fixes

| Symptom | Diagnosis | Fix |
|---|---|---|
| CLAUDE.md describes directory layout, commands, or column names | Present-state content in the values shelf | Move to `docs/` and leave a link; CLAUDE.md keeps only the why-it-matters |
| CLAUDE.md states rules that can be followed as written and checked mechanically | Rules in the constitution; the gate was entered from the wrong side | Move to a `docs/` conventions page; keep in CLAUDE.md only the value the rules derive from, if one is actually stated |
| A docs/ page explains why an approach was chosen over alternatives | Decision history in the present-state shelf | Extract into an ADR, link both ways |
| Sample data embedded in a docs/ page | Raw data in a prose shelf; data updates and prose updates now share one diff | Move rows to `references/`, keep the prose description in docs/ with a link |
| README carries full setup procedures, troubleshooting, API details | The entrance trying to be the building | Keep quickstart; move the rest to `docs/setup.md` and link |
| An ADR keeps getting edited to match reality | It is describing the present, so it is not a decision record | Its stable decision core stays as the ADR; the moving parts belong in `docs/` |
| A note in `notes/` has outlived its task | The disposable shelf is being used as an archive; its contents are outside trust | Examine it: promote what deserves a durable shelf, delete the rest |
| Durable knowledge — a convention, a decision, a data contract — sits only in `notes/` | Knowledge parked where it is destined to be deleted | Promote to the shelf the questions above assign, then close the note |
| A docs/ page or ADR links into `notes/` | A durable shelf depending on a disposable one; the link is a future dead link | Promote the linked content, or restate what the page needs and drop the link |
| The same explanation appears in two shelves | Duplication; both copies are now suspect | Decide the true home by the questions above, keep one, link from the other location's natural neighbor |
| `docs/adr/` exists | Decisions filed as a subfolder of the present state | Move to root `adr/`, update every link and the index; this is one act, not a rename plus follow-ups. When ADR tooling or a site generator pins that path, report the finding but leave the move to the user |
| An orphan document no index or page links to | Knowledge that exists but cannot be found | Add it to the owning shelf's index, or fold its content into an existing page |

## Destinations outside the repository

Some knowledge belongs to a home the shelves do not own:

- **Code comments** hold the "why" that is glued to a specific line. A comment at the right altitude is not exiled to `docs/` for tidiness.
- **The user-scope CLAUDE.md** (`~/.claude/CLAUDE.md`) holds personal standards that are true in every project. Nothing about any one project's current state lives there.
- **Claude's private auto-memory** holds nothing. It is machine-local and invisible to every other contributor, so knowledge written there is hidden, not remembered. Values go to CLAUDE.md, conventions and current state to `docs/`, task context to `notes/`.

## What must not be moved

- Files owned by tools and conventions: `LICENSE`, `CHANGELOG.md`, `package.json`, `.github/`, `.claude/`, editor and linter configs. They have externally-defined homes.
- A docs tree owned by a static site generator. When `mkdocs.yml`, `docusaurus.config.*`, `conf.py`, or `book.toml` sits beside `docs/`, the tree's internal layout is defined by the tool and wired into navigation and builds. Findings inside it are reported as proposals; the librarian does not move files there, because the breakage belongs to the user to weigh.
- Anything whose move breaks published URLs or external references, without flagging that breakage explicitly in the proposal.

## Judging mixed files

Most real files are mixtures: a README that is one-third face, one-third setup manual, one-third design essay. Classify per section. Propose a split only when the misplaced portion is substantial enough that a stranger would look for it in the wrong place; a single stray sentence is fixed by moving the sentence, not by ceremony.

## The audit's standard of evidence

Every finding in an audit names the file, quotes or precisely describes the misplaced content, states which question above it failed, and proposes the destination. A finding that cannot cite its evidence is an opinion, and opinions do not move books.
