# Templates

Skeletons for the entry-point files the shelving structure needs. Fill placeholders from what the repository actually shows; do not invent facts to complete a template. A template section that has nothing true to hold is deleted, not padded.

The skeletons are written in English. Render every generated file in the project's own documentation language — judge it from the existing README and docs, not from the user's conversation language — with one exception: **CLAUDE.md is always written in English**, whatever the project speaks. It is loaded into every session, so its tokens are paid on every conversation, and English is the cheapest language to pay them in. The structure is the template; the words are not.

`notes/` needs no template and no index: it is created the first time a task leaves something behind, holds free-form files, and its contents are promoted or deleted when their task closes.

## Root README.md — the documentation map section

Append to an existing README (or include in a new one). The prose around it stays the project's own.

```markdown
## Documentation

Knowledge in this repository lives on five shelves. The same content is never
written onto more than one of them. The contract is recorded in
[ADR-0002](adr/0002-adopt-shelved-documentation.md).

- **[CLAUDE.md](CLAUDE.md)** — the project's values and judgment criteria
- **[docs/](docs/README.md)** — what is true now: structure, procedures, contracts, conventions
- **[adr/](adr/README.md)** — why each choice was made: the decision records
- **[references/](references/)** — raw reference data used during development,
  kept to verify shapes when the live system is out of reach
- **notes/** — task-lifetime work products; promoted or deleted when their task closes

Before implementing, start from [docs/README.md](docs/README.md).
```

Omit the `references/` line when the project has no raw reference data, and the `notes/` line until the directory first exists. The `notes/` line is deliberately not a link: durable documents do not link into a disposable shelf.

## CLAUDE.md — seeded from the default constitution

A project CLAUDE.md is not generated from a blank skeleton. Start from the constitution body in `default-constitution.md` — the part below its divider — then:

1. Append the project's own values, if any are actually knowable: observed conventions, the owner's stated priorities, decisions already visible in the code. Each principle carries the reasoning that makes it true, written as prose a reader can argue with. A value stated without its why is a rule, and rules live in `docs/` as conventions, not here. If only two values are known, write two; where the owner's values are not yet knowable, ask — a values document written entirely by guessing is someone else's constitution.
2. Append the load-bearing contract section below.
3. Open the document with the orientation block below, so the constitution points at the other shelves instead of describing them.

The orientation block, placed after the title:

```markdown
This document explains the values and reasoning that should guide work in this
repository. It does not describe structure, commands, or data formats — those live
in `docs/`; the history of why each choice was made lives in `adr/`.

Before implementing, read [docs/README.md](docs/README.md) for the current state
and [adr/README.md](adr/README.md) for the decision history.
```

The load-bearing contract section, placed last:

```markdown
## The shelving contract is load-bearing

Knowledge here is split across shelves: this file holds the values, `docs/` holds
what is true now and the conventions to follow, `adr/` holds why each choice was
made, `references/` holds raw reference data, and `notes/` holds task-lifetime
work products that are promoted or deleted when their task closes. The same
content is never written onto more than one shelf. When the structure changes,
`docs/` moves with it and the ADR is written before the implementation lands.
This file is the hardest shelf to enter: only values that ground judgment across
situations live here; anything followable as written belongs in `docs/`.
Claude's private auto-memory is disabled in this project, attribution is left
to git, and no file carries an emoji; these are guaranteed by settings and
hooks in `.claude/`, not by this text.
```

## docs/README.md

```markdown
# <project> documentation

<One paragraph: what the project is, from the docs/ reader's point of view.>

## The role of this directory

`docs/` describes what exists right now and the conventions to follow. Why each
choice was made lives in [adr/](../adr/README.md); the project's values live in
the root [CLAUDE.md](../CLAUDE.md). The same content is never written in more
than one place, and each page links to the ADRs behind its subject.

Read selectively: pick the pages this task touches from the table below and
skip the rest. If the right page cannot be found from the table, that is a
defect in this index — fix the index, not the reading habit.

## Pages

| File | Purpose |
|---|---|
| <file>.md | <purpose> |

## Related decisions

- [ADR-0002](../adr/0002-adopt-shelved-documentation.md) — the shelved split of written knowledge
```

## adr/README.md

```markdown
# Architecture Decision Records

This directory records <project>'s design decisions in order. Each record
preserves why a choice was made; what exists right now is described in `docs/`.
The same content is never written in both.

## When to write one

When a choice is made that a future reader could not reconstruct: stack
selection, data formats, structural patterns. Small implementation details do
not qualify. Write the ADR before the implementation lands, and cross-link it
with `docs/` — a record written after the fact has already lost the
alternatives that were live at the moment of choosing.

## Status values

- `Proposed` — under discussion
- `Accepted` — adopted; implementation builds on it
- `Superseded by ADR-XXXX` — replaced by a later record; the body remains as history
- `Deprecated` — retired without a successor

An accepted record is never rewritten. When a decision changes, write a new
record, mark the old one superseded, and link the two.

## Index

| # | Title | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](0002-adopt-shelved-documentation.md) | Adopt the shelved documentation contract | Accepted |
```

## adr/template.md

```markdown
# NNNN. <Decision title, stated as the choice made>

- Status: Proposed
- Date: YYYY-MM-DD
- Deciders: <who>

## Context

<The forces at play: the problem, the constraints, what made a decision necessary.>

## Decision

<What was chosen, stated plainly.>

## Consequences

<What becomes easier, what becomes harder, what obligations this creates.
Link the docs/ pages this decision shapes.>

## Alternatives Considered

- **<Alternative>**: <why it was rejected>
```

## adr/0001 and 0002 — the records setup itself writes

A bootstrap is itself two decisions, and they are recorded like any other: `0001-record-architecture-decisions.md` records the adoption of ADRs, and `0002-adopt-shelved-documentation.md` records the adoption of the documentation contract, both dated the day setup ran, with Alternatives Considered filled honestly (one document for everything; a wiki; doing nothing). Write them from the template above. A structure that preaches "record your decisions" but cannot show the record of its own adoption starts life in contradiction with itself.

## The guarantees

Some of what a constitution used to ask for can be guaranteed by a setting or a hook, and what is guaranteed there leaves the text: a value that cannot be violated no longer needs to be stated, only understood. Setup installs three guarantees into the project's `.claude/`, so they belong to the project, keep working for every contributor, and survive the plugin being disabled.

**Private memory stays closed.** Three layers, because the official switch can be overridden by the `CLAUDE_CODE_DISABLE_AUTO_MEMORY=0` environment variable.

1. Merge `"autoMemoryEnabled": false` into `.claude/settings.json`. This stops both the writing and the session-start loading of Claude's private memory.
2. Copy `${CLAUDE_PLUGIN_ROOT}/assets/hooks/shosoin-block-memory.sh` to `.claude/hooks/shosoin-block-memory.sh`, executable. It denies any Write, Edit, NotebookEdit, or Bash call that touches the memory directory; Bash included, because appending with `echo` or a heredoc is the path of least resistance.
3. Copy `${CLAUDE_PLUGIN_ROOT}/assets/hooks/shosoin-clean-memory.sh` to `.claude/hooks/shosoin-clean-memory.sh`, executable. On every session start it deletes the project's memory directory, so anything written before the guarantee existed is gone by the next session. The slug derivation it relies on is an internal Claude Code convention; if that convention changes the script misses and deletes nothing, which is the safe direction.

**Attribution stays accurate.** Merge `"attribution": {"commit": "", "pr": "", "sessionUrl": false}` into `.claude/settings.json`. Without it Claude Code appends a co-author trailer to commits and a generated-with line to pull request bodies, while a constitution asking for accurate attribution pulls the other way; the setting removes the injection at its source, so there is nothing left to ask.

**No emoji reach a file.** Copy `${CLAUDE_PLUGIN_ROOT}/assets/hooks/shosoin-block-emoji.sh` to `.claude/hooks/shosoin-block-emoji.sh`, executable. It denies any Write, Edit, NotebookEdit, or Bash call whose text carries an emoji, in every file without exception. Escaped forms and data piped through from elsewhere pass; those are observed before they are chased.

Merge into `.claude/settings.json` (create the file if absent; merge, never overwrite, if present):

```json
{
  "autoMemoryEnabled": false,
  "attribution": { "commit": "", "pr": "", "sessionUrl": false },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit|Bash",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/shosoin-block-memory.sh" },
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/shosoin-block-emoji.sh" }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/shosoin-clean-memory.sh" }
        ]
      }
    ]
  }
}
```

If `.claude/settings.json` already declares `hooks.PreToolUse` or `hooks.SessionStart` entries, append these hook groups to the existing arrays rather than replacing them, and leave every unrelated key untouched. Report the installation in the handover: the user should know their project now deletes private memory on every session start, writes no attribution trailers, and refuses emoji in files, and that removing the pieces reverses each guarantee.
