# The Doctrine: Four Tracks and One Entrance

This contract assigns every kind of written knowledge in a repository exactly one home. It exists because a project's knowledge, when mixed into one document, always rots: either the current state changes and overwrites the reasons behind past decisions, or the reasons are preserved and the description of the present goes stale. A document that is trusted but wrong is worse than no document, because nobody re-verifies what they trust.

## The tracks

### CLAUDE.md (repository root) — values

Holds the project's values and judgment criteria: why certain things matter, stated generally enough to guide situations the document never anticipated. It does not describe structure, commands, or data formats — those are the present state and belong in `docs/`. It does not record why choices were made — that history belongs in `adr/`. It links to `docs/README.md` and `adr/README.md` as entrances.

A test for content claiming residence here: if the codebase were rewritten from scratch tomorrow, would this sentence still hold? Values survive rewrites; structure does not.

### docs/ — what is true now

Holds only the present: architecture as it stands, directory structure, setup procedures, data contracts, verification steps. Each page links to the ADRs that explain its choices. `docs/README.md` is the entrance: it states the directory's role and carries an inventory table of every page with its purpose.

`docs/` governs. It is read before writing or moving code, not consulted afterward to justify what was already done. When the structure changes, `docs/` moves with it in the same act.

### adr/ (repository root) — why

Holds the decisions: what was chosen, why, and which alternatives were rejected. Records are numbered, time-ordered, and immutable once accepted — when a decision changes, a new ADR supersedes the old one, and the old one keeps its body as history. An ADR is written before the implementation lands, because an ADR written after the fact is a reconstruction that has already lost the alternatives that were live at the moment of choosing.

`adr/` lives at the repository root, beside `docs/`, not inside it. Decisions are a first-class track of knowledge, not a subfolder of current-state documentation. `adr/README.md` explains the practice and carries the index table; `adr/template.md` is the form new records copy.

`adr/` explains; it is consulted when a question of "why" comes up, not as a gate before every change. That asymmetry — docs/ governs, adr/ explains — is part of the contract.

### references/ — raw data

Holds raw reference data used during development: sample rows from a spreadsheet, a captured API response, a copy of an external system's schema. Not prose. Not processed. Not loaded by code. It exists because development environments often cannot reach the live systems whose shape the code must match, and a snapshot at hand beats a round-trip to whoever can look.

Its defining weakness is honest and permanent: nothing detects drift between a `references/` file and the real system. No build breaks, no test fails. It is a development aid to verify against by hand, never a source of truth to trust blindly.

## The entrance: README.md (repository root)

The project's face for someone who just arrived: what this is, why it exists, the one-paragraph shape of how it works, and the map of the four tracks with links into each. Quickstart commands may appear here; full procedures live in `docs/`. The README points inward; it does not duplicate what the tracks hold.

## The discipline that keeps it alive

- **One home per fact.** The same content is never written into more than one track. Duplication collapses the distinction, and the next reader can trust neither copy.
- **Cross-link, don't copy.** A `docs/` page links to the ADRs behind it; an ADR's Consequences link to the `docs/` pages it shaped.
- **A structure change is one act.** Update `docs/`, write or supersede the ADR, and update the index tables together — in the same change, not as a follow-up.
- **ADR before implementation.** The decision is recorded while the alternatives are still alive.
- **Records describe a moment.** Every page was true when written. Before relying on a document's claim about a file, a function, or a config value, confirm it still matches what is on disk.

## What this contract is not

It is not a demand that every project carry all four tracks from day one. A project with no external data needs no `references/`. A project with two files needs no `docs/` tree. The contract states where each kind of knowledge lives when it exists; it does not require manufacturing knowledge to fill shelves. Empty structure is noise wearing a uniform.
