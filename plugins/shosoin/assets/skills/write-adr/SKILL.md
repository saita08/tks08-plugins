---
name: write-adr
description: Records an architecture decision in adr/ before the implementation lands, and moves docs/ and the indexes in the same change. Use when a choice is being made that a future reader could not reconstruct — a structure, a data format, a stack, a distribution mechanism — or when a change to the repository's structure is about to start. Triggers on "write an ADR", "record this decision", "why did we choose this", "restructure", "change the directory layout".
---

# Write an ADR

When this is done, the decision is on record while its alternatives are still live, and every page it shapes says the same thing.

1. Find the next number: list `adr/`, take the highest `NNNN`, add one.
2. Copy `adr/template.md` to `adr/NNNN-<the-choice-as-a-phrase>.md`. The title states the choice that was made, not the topic it belongs to.
3. Fill Context, Decision, Consequences, and Alternatives Considered. Each alternative carries the reason it was rejected. When no alternative is known, ask the owner what else was on the table; do not invent one to fill the section.
4. Set Status to `Proposed`. It becomes `Accepted` when the owner accepts it, and from then on the body is not rewritten.
5. Add the row to the index in `adr/README.md`.
6. When the record replaces an earlier one: set the earlier record's Status to `Superseded by ADR-NNNN`, update its index row, and link the two both ways. Leave the earlier body as it is.
7. In the same change, update the `docs/` pages the decision shapes, link them from Consequences, and link the record from those pages. When a page is added or removed, update the table in `docs/README.md`.
8. Only then implement.

Verify: every link written above resolves, and the index in `adr/README.md` lists exactly the records on disk.

The rule these steps serve: [adr/README.md](../../../adr/README.md).
