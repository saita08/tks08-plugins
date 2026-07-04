# Placement Guide

How to decide where a document, a section, or a single paragraph belongs. Apply to whole files first, then to the sections inside files that turn out to be mixed.

## The classification questions

Ask in this order; the first yes wins.

1. **Is it a value or judgment criterion that would survive a rewrite of the codebase?** → `CLAUDE.md`.
2. **Is it the record of a choice: what was decided, why, what was rejected?** → `adr/`.
3. **Is it raw data — rows, schemas, captured payloads — kept for reference rather than read as prose?** → `references/`.
4. **Does it describe what exists right now: structure, procedures, contracts, how to verify?** → `docs/`.
5. **Is it the first thing a stranger should read: what this project is and where everything lives?** → root `README.md`.

Content that answers none of these is usually not documentation: scratch notes, generated output, tool state. Leave it alone or question its existence, but do not force it into a track.

## Common misplacements and their fixes

| Symptom | Diagnosis | Fix |
|---|---|---|
| CLAUDE.md describes directory layout, commands, or column names | Present-state content in the values track | Move to `docs/` and leave a link; CLAUDE.md keeps only the why-it-matters |
| A docs/ page explains why an approach was chosen over alternatives | Decision history in the present-state track | Extract into an ADR, link both ways |
| Sample data embedded in a docs/ page | Raw data in a prose track; data updates and prose updates now share one diff | Move rows to `references/`, keep the prose description in docs/ with a link |
| README carries full setup procedures, troubleshooting, API details | The entrance trying to be the building | Keep quickstart; move the rest to `docs/setup.md` and link |
| An ADR keeps getting edited to match reality | It is describing the present, so it is not a decision record | Its stable decision core stays as the ADR; the moving parts belong in `docs/` |
| The same explanation appears in two tracks | Duplication; both copies are now suspect | Decide the true home by the questions above, keep one, link from the other location's natural neighbor |
| `docs/adr/` exists | Decisions filed as a subfolder of the present state | Move to root `adr/`, update every link and the index; this is one act, not a rename plus follow-ups |
| An orphan document no index or page links to | Knowledge that exists but cannot be found | Add it to the owning track's index, or fold its content into an existing page |

## What must not be moved

- Files owned by tools and conventions: `LICENSE`, `CHANGELOG.md`, `package.json`, `.github/`, `.claude/`, editor and linter configs. They have externally-defined homes.
- Code comments. A comment glued to a specific line is at the right altitude; do not exile it to `docs/` for tidiness.
- Anything whose move breaks published URLs or external references, without flagging that breakage explicitly in the proposal.

## Judging mixed files

Most real files are mixtures: a README that is one-third face, one-third setup manual, one-third design essay. Classify per section. Propose a split only when the misplaced portion is substantial enough that a stranger would look for it in the wrong place; a single stray sentence is fixed by moving the sentence, not by ceremony.

## The audit's standard of evidence

Every finding in an audit names the file, quotes or precisely describes the misplaced content, states which question above it failed, and proposes the destination. A finding that cannot cite its evidence is an opinion, and opinions do not move books.
