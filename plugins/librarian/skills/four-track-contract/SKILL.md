---
name: four-track-contract
description: This skill should be used when the user asks where a document or a piece of knowledge belongs in a repository, asks about the roles of CLAUDE.md vs README.md vs docs/ vs adr/ vs references/, mentions "ドキュメントを整理したい", "この情報どこに書くべき", "docsとREADMEの役割", or when Claude is about to create or move a documentation file and the correct home is not obvious. Provides the four-track knowledge contract that assigns every kind of written knowledge exactly one home.
allowed-tools: Read, Glob, Grep
---

# The Four-Track Knowledge Contract

A repository's written knowledge is split into four tracks plus one entrance. Each kind of content has exactly one home, and the same content is never written into more than one of them. This skill carries the contract; consult the reference that matches the task at hand rather than loading all of them.

- `references/doctrine.md` — the contract itself: what each track holds, why the split exists, and the operational discipline that keeps it alive. Read before auditing, reorganizing, or explaining the structure.
- `references/placement-guide.md` — the placement procedure: how to classify a given document or piece of content, the common misplacements and their fixes, and what must not be moved. Read when deciding where something belongs.
- `references/templates.md` — skeletons for every entry-point file the structure needs. Read when creating missing pieces or bootstrapping a project.

The one rule that outranks all others: when knowledge is written into two tracks, both copies become untrustworthy, because a reader can no longer tell which one moved with reality. Every placement decision serves that rule.

Two commands drive this skill's knowledge: `/librarian:audit` diagnoses and reorganizes an existing project, `/librarian:setup` bootstraps the structure in a project that has none. When the user asks placement questions in passing, answer from the references directly without invoking a command.
