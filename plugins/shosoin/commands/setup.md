---
description: Bootstrap the shelved documentation structure — CLAUDE.md, docs/, adr/, references/, a README map — and install the guarantees that close private memory, keep attribution accurate, and keep emoji out of files, all in a project that does not have them yet.
argument-hint: "[セットアップ対象のパス（省略時はカレントプロジェクト）]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Shosoin Setup

Stand up the shelving structure in a project that lacks it. Setup is for shelves that do not exist yet; if the project already has a substantial documentation tree, stop and recommend `/shosoin:audit` instead — reorganizing existing knowledge without a diagnosis loses it.

Read `${CLAUDE_PLUGIN_ROOT}/skills/shelving-contract/references/contract.md` for what each shelf holds and `${CLAUDE_PLUGIN_ROOT}/skills/shelving-contract/references/templates.md` for the skeletons and the guarantees. Fill every template from what the repository actually shows — its code, its configs, its git history. Do not invent facts to make a template look complete, and delete template sections that have nothing true to hold.

## Step 1 — Survey before building

Read the repository: what it is, what stack it runs, what documentation already exists, and what language its documentation speaks — every file setup creates is written in that language, except CLAUDE.md, which is always written in English as the templates reference explains. An existing README is inherited, not replaced — the documentation map is appended to it. An existing CLAUDE.md is likewise inherited; if it mixes values with structure or history, disentangling it is an audit's job, not a setup's. A handful of existing documents can be adopted into the new structure as part of setup; report where each will live. More than a handful means this is an audit, not a setup.

Ask the owner one question before building: is this project personal, or shared with collaborators? The answer decides how the constitution is seeded in Step 2 — a personal project whose owner already carries these values in their user-scope `~/.claude/CLAUDE.md` would load them twice, while a shared project needs the full seed in the repository because collaborators do not share anyone's user scope.

## Step 2 — Erect the shelves

Create, from the templates:

- The documentation map section in the root `README.md`
- `CLAUDE.md`, in English, seeded from `${CLAUDE_PLUGIN_ROOT}/skills/shelving-contract/references/default-constitution.md` as the templates reference describes: the constitution body, then the project's own values, then the load-bearing contract section. On a shared project, plant the full seed. On a personal project whose owner's user scope already carries equivalent values, offer to plant only the orientation block, the project's own values, and the contract section — and record in the handover that the constitution then lives in user scope, invisible to any future collaborator. Where the owner's values are not yet knowable, ask — a values document written entirely by guessing is someone else's constitution
- `docs/README.md` with the role statement and an inventory of pages worth writing for this project, listed as planned rows rather than empty stub files
- `adr/README.md`, `adr/template.md`, and the first two real records: `0001-record-architecture-decisions.md` and `0002-adopt-shelved-documentation.md`, dated today, alternatives filled honestly
- `references/` only if the project actually has raw reference data to hold; an empty specimen room is not furniture, it is dust
- `notes/` is not created — it comes into being the first time a task leaves something behind

## Step 3 — Install the guarantees

Install the guarantees exactly as the templates reference specifies: merge `autoMemoryEnabled: false`, the `attribution` block, and the hook registrations into `.claude/settings.json` — merging into any existing file, never overwriting it — and copy the three hook scripts from `${CLAUDE_PLUGIN_ROOT}/assets/hooks/` into `.claude/hooks/`, made executable. These pieces belong to the project afterward: they keep working for every contributor and survive this plugin being disabled or removed. They are also why the constitution seed says nothing about memory, attribution, or emoji: what a setting or a hook guarantees is not asked for in the text.

## Step 4 — Hand over

Report what was created, what was inherited, and — most important — what only the user can fill in: the values that need their voice, the docs/ pages that need their knowledge of the system, the reference data only they can export. State plainly that auto memory is now disabled and the project deletes its private memory directory at every session start, that commits and pull requests carry no generated attribution, and that writes containing emoji are refused; name the pieces so the user knows what removing each guarantee would take. Setup builds the shelves and labels them; the books are the owner's. Do not commit; the user reviews the working tree.
