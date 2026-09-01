# The Contract: Five Shelves and One Entrance

This contract assigns every kind of written knowledge in a repository exactly one home. It exists because a project's knowledge, when mixed into one document, always rots: either the current state changes and overwrites the reasons behind past decisions, or the reasons are preserved and the description of the present goes stale. A document that is trusted but wrong is worse than no document, because nobody re-verifies what they trust.

Two axes drive the split. The first is lifespan: the present moves at the speed of the code, raw data drifts silently, and working notes die with their task. The second is role, which separates the two nearly-immutable kinds — values guide judgment, records preserve choices. The shelves are the image of these two axes, not a set of genres.

## The shelves

### CLAUDE.md (repository root) — values, and the hardest shelf to enter

Holds the project's values and judgment criteria: why certain things matter, stated generally enough to guide situations the document never anticipated. It does not describe structure, commands, or data formats — those are the present state and belong in `docs/`. It does not record why choices were made — that history belongs in `adr/`. It links to `docs/README.md` and `adr/README.md` as entrances.

The constitution is the last gate: only knowledge every other shelf has refused may apply to live here. It is loaded into every session, so everything admitted is paid for on every conversation; that economy is why it must stay small, and why it stays small only if it is the hardest shelf to enter.

The touchstone that guards the gate: if several distinct rules can be derived from a statement, it is a value and may live here; if the statement can be followed as written and checked mechanically, it is a rule, and rules live in `docs/` as conventions. A rule is a device that substitutes for judgment; a constitution exists to strengthen judgment, not to replace it. A second test agrees: if the codebase were rewritten from scratch tomorrow, would this sentence still hold? Values survive rewrites; rules and structure often do not — but note that a convention can survive a rewrite and still be a rule, which is why the touchstone, not the rewrite test, decides.

Because it is always loaded, CLAUDE.md is written in English regardless of the project's documentation language: it is read by the model on every session, and tokens spent on it are spent every time.

### docs/ — what is true now, and what must be followed now

Holds the present: architecture as it stands, directory structure, setup procedures, data contracts, verification steps — and the project's conventions, the rules a contributor follows as written. Each page links to the ADRs that explain its choices. `docs/README.md` is the entrance: it states the directory's role and carries an inventory table of every page with its purpose.

`docs/` governs. It is read before writing or moving code, not consulted afterward to justify what was already done. When the structure changes, `docs/` moves with it in the same act.

### adr/ (repository root) — why

Holds the decisions: what was chosen, why, and which alternatives were rejected. Records are numbered, time-ordered, and immutable once accepted — when a decision changes, a new ADR supersedes the old one, and the old one keeps its body as history. An ADR is written before the implementation lands, because an ADR written after the fact is a reconstruction that has already lost the alternatives that were live at the moment of choosing.

`adr/` lives at the repository root, beside `docs/`, not inside it. Decisions are a first-class shelf of knowledge, not a subfolder of current-state documentation. `adr/README.md` explains the practice and carries the index table; `adr/template.md` is the form new records copy.

`adr/` explains; it is consulted when a question of "why" comes up, not as a gate before every change. That asymmetry — docs/ governs, adr/ explains — is part of the contract, and it is what keeps the everyday reading load small.

### references/ — raw data

Holds raw reference data used during development: sample rows from a spreadsheet, a captured API response, a copy of an external system's schema. Not prose. Not processed. Not loaded by code. It exists because development environments often cannot reach the live systems whose shape the code must match, and a snapshot at hand beats a round-trip to whoever can look.

Its defining weakness is honest and permanent: nothing detects drift between a `references/` file and the real system. No build breaks, no test fails. It is a development aid to verify against by hand, never a source of truth to trust blindly.

### notes/ — task-lifetime work products

Holds what a task produces and a task outlives: working memos, review write-ups, prototypes, handover notes. A note is written at the seams where a coherent unit of work completes; when work pauses, the note carries what a successor with no memory of the conversation needs — the state, the decisions made, the next step.

`notes/` closes with its task. At the close, the contents are examined: findings worth keeping are promoted to their proper shelf, and the rest is deleted. A note that outlives its task without being promoted or deleted drops out of trust — it is exactly the rot the other shelves are protected from, kept in a place whose whole defense was that nothing stays.

Because everything here is destined to disappear, the durable shelves never link into `notes/`. A link into `notes/` is a future dead link, written in advance.

## The entrance: README.md (repository root)

The project's face for someone who just arrived: what this is, why it exists, the one-paragraph shape of how it works, and the map of the shelves with links into each. Quickstart commands may appear here; full procedures live in `docs/`. The README points inward; it does not duplicate what the shelves hold.

## The language of the shelves

Documents are written in the project's documentation language; CLAUDE.md alone is written in English, for the economy its shelf states. When that language is not English, terms of art keep their original form or that language's usual transliteration, and process words stay everyday words. A term of art translated into a literary calque reads as machine output, and a document that reads machine-made loses the reader's trust before its content is weighed. This rule governs conversation held under the contract as much as the files it produces, and it weighs heaviest on the first records a structure receives: later documents copy them as house style, so a calque planted at setup compounds with every record written after it.

## Reading is half the contract

Classification exists for selective loading. A reader's context — human or Claude — is finite, and reading everything is the same as choosing nothing. The shelves earn their keep only if they let a reader load the one kind of knowledge the moment needs and skip the rest, and what makes that selection possible is the entrances: the README map, and the inventory tables in `docs/README.md` and `adr/README.md`.

The reading order follows the shelves' roles. The constitution and the README map are the only unconditional loads. Resuming an interrupted task, read that task's note in `notes/` — nothing else there. Before touching code, pick the relevant pages from the `docs/` inventory and read only those. Open `adr/` only when a question of "why" arises, reached through the links a docs page carries. Open `references/` only in the moment a data shape must be checked.

"Reading everything just in case" is prohibited — not as a discipline of restraint but as a diagnostic: if the right pages cannot be found without reading everything, the defect is in the indexes or the classification, and the structure is what gets fixed.

Before acting on a file name, a config value, or a structure that a `docs/` page asserts, confirm it still matches the repository on disk. Every page was true when written; the code has moved since.

## The discipline that keeps it alive

- **One home per fact.** The same content is never written into more than one shelf. Duplication collapses the distinction, and the next reader can trust neither copy.
- **Cross-link, don't copy.** A `docs/` page links to the ADRs behind it; an ADR's Consequences link to the `docs/` pages it shaped. No durable shelf links into `notes/`.
- **A structure change is one act.** Update `docs/`, write or supersede the ADR, and update the index tables together — in the same change, not as a follow-up.
- **ADR before implementation.** The decision is recorded while the alternatives are still alive.
- **Records describe a moment.** Every page was true when written. Before relying on a document's claim about a file, a function, or a config value, confirm it still matches what is on disk.
- **Notes are promoted or deleted, never accumulated.** Closing a task includes closing its notes.
- **Nothing lives in Claude's private memory.** Auto memory is machine-local and invisible to every other contributor; knowledge written there is hidden, not remembered. Values go to CLAUDE.md, conventions and current state to `docs/`, task context to `notes/`. Projects set up under this contract disable auto memory outright.

## What this contract is not

It is not a demand that every project carry all five shelves from day one. A project with no external data needs no `references/`. A project with two files needs no `docs/` tree, and `notes/` is created the first time a task leaves something behind, not before. The contract states where each kind of knowledge lives when it exists; it does not require manufacturing knowledge to fill shelves. Empty structure is noise wearing a uniform.
