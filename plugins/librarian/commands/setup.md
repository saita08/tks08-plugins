---
description: Bootstrap the four-track documentation structure — CLAUDE.md, docs/, adr/, references/, and a README map — in a project that does not have one yet.
argument-hint: "[セットアップ対象のパス（省略時はカレントプロジェクト）]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Librarian Setup

Stand up the four-track structure in a project that lacks it. Setup is for shelves that do not exist yet; if the project already has a substantial documentation tree, stop and recommend `/librarian:audit` instead — reorganizing existing knowledge without a diagnosis loses it.

Read `${CLAUDE_PLUGIN_ROOT}/skills/four-track-contract/references/doctrine.md` for what each track holds and `${CLAUDE_PLUGIN_ROOT}/skills/four-track-contract/references/templates.md` for the skeletons. Fill every template from what the repository actually shows — its code, its configs, its git history. Do not invent facts to make a template look complete, and delete template sections that have nothing true to hold.

## Step 1 — Survey before building

Read the repository: what it is, what stack it runs, what documentation already exists, and what language its documentation speaks — every file setup creates is written in that language, with the templates' Japanese serving as reference form only. An existing README is inherited, not replaced — the documentation map is appended to it. An existing CLAUDE.md is likewise inherited; if it mixes values with structure or history, disentangling it is an audit's job, not a setup's. A handful of existing documents can be adopted into the new structure as part of setup; report where each will live. More than a handful means this is an audit, not a setup.

## Step 2 — Erect the tracks

Create, from the templates:

- The documentation map section in the root `README.md`
- `CLAUDE.md` with the values that are actually observable in the project, plus the load-bearing contract section. Where the owner's values are not yet knowable, ask — a values document written entirely by guessing is someone else's constitution
- `docs/README.md` with the role statement and an inventory of pages worth writing for this project, listed as planned rows rather than empty stub files
- `adr/README.md`, `adr/template.md`, and the first two real records: `0001-record-architecture-decisions.md` and `0002-adopt-four-track-documentation.md`, dated today, alternatives filled honestly
- `references/` only if the project actually has raw reference data to hold; an empty specimen room is not furniture, it is dust

## Step 3 — Hand over

Report what was created, what was inherited, and — most important — what only the user can fill in: the values that need their voice, the docs/ pages that need their knowledge of the system, the reference data only they can export. Setup builds the shelves and labels them; the books are the owner's. Do not commit; the user reviews the working tree.
