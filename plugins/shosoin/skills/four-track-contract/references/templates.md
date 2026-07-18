# Templates

Skeletons for the entry-point files the four-track structure needs. Fill placeholders from what the repository actually shows; do not invent facts to complete a template. A template section that has nothing true to hold is deleted, not padded.

The skeletons are written in English. Render every generated file in the project's own documentation language — judge it from the existing README and docs, not from the user's conversation language. The structure is the template; the words are not.

## Root README.md — the documentation map section

Append to an existing README (or include in a new one). The prose around it stays the project's own.

```markdown
## Documentation

Knowledge in this repository lives in four tracks. The same content is never
written into more than one of them. The contract is recorded in
[ADR-0002](adr/0002-adopt-four-track-documentation.md).

- **[CLAUDE.md](CLAUDE.md)** — the project's values and judgment criteria
- **[docs/](docs/README.md)** — what is true now: structure, procedures, contracts
- **[adr/](adr/README.md)** — why each choice was made: the decision records
- **[references/](references/)** — raw reference data used during development,
  kept to verify shapes when the live system is out of reach

Before implementing, start from [docs/README.md](docs/README.md).
```

Omit the `references/` line when the project has no raw reference data.

## CLAUDE.md — values skeleton

Generate the opening and closing from this form; the middle principles must come from the project itself (observed conventions, the owner's stated priorities, decisions already visible in the code). Placeholder principles help no one — if only two values are known, write two.

Each principle carries the reasoning that makes it true, written as prose that a reader can argue with — enough that someone facing a situation the document never anticipated can reconstruct what the value demands. A value stated without its why is a rule, and rules only cover the cases already seen.

```markdown
# CLAUDE.md

This document explains the values and reasoning that should guide work in this
repository. It does not describe structure, commands, or data formats — those live
in `docs/`; the history of why each choice was made lives in `adr/`.

Before implementing, read [docs/README.md](docs/README.md) for the current state
and [adr/README.md](adr/README.md) for the decision history.

## <Principle name, stated as a value>

<Why this matters: the failure it prevents or the good it protects, reasoned
in full sentences. Written so that a reader facing an unanticipated situation
can derive what the value asks of them, not just recognize the cases listed.>

## The four-track knowledge contract is load-bearing

Knowledge here is split across tracks: this file holds the values, `docs/` holds
what is true now, `adr/` holds why each choice was made, and `references/` holds
raw reference data. The same content is never written into more than one track.
When the structure changes, `docs/` moves with it and the ADR is written before
the implementation lands.
```

## docs/README.md

```markdown
# <project> documentation

<One paragraph: what the project is, from the docs/ reader's point of view.>

## The role of this directory

`docs/` describes what exists right now. Why each choice was made lives in
[adr/](../adr/README.md); the project's values live in the root
[CLAUDE.md](../CLAUDE.md). The same content is never written in more than one
place, and each page links to the ADRs behind its subject.

## Pages

| File | Purpose |
|---|---|
| <file>.md | <purpose> |

## Related decisions

- [ADR-0002](../adr/0002-adopt-four-track-documentation.md) — the four-track split of written knowledge
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
| [0002](0002-adopt-four-track-documentation.md) | Adopt the four-track documentation contract | Accepted |
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

A bootstrap is itself two decisions, and they are recorded like any other: `0001-record-architecture-decisions.md` records the adoption of ADRs, and `0002-adopt-four-track-documentation.md` records the adoption of the documentation contract, both dated the day setup ran, with Alternatives Considered filled honestly (one document for everything; a wiki; doing nothing). Write them from the template above. A structure that preaches "record your decisions" but cannot show the record of its own adoption starts life in contradiction with itself.
