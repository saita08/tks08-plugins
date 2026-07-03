---
name: distribution-layers
description: This skill should be used when the user is deciding what belongs in a shared, fleet-distributed institution versus a single project, when they ask "should this go in the global CLAUDE.md or the project one", "is this worth distributing to every repo", "what should fleet-sync distribute", or when composing or reviewing a fleet-sync manifest. Also consult it when interpreting drift between an origin and its destinations.
allowed-tools: Read
---

# Distribution Layers

The value of fleet-sync depends entirely on distributing the right things. Distribute a project-specific convention to every repository and you have imposed one project's local rule on the whole fleet; fail to distribute a genuinely shared institution and it drifts into a dozen diverging copies. This skill carries the judgment that keeps the manifest honest, and the model that keeps drift detection honest.

Two reference files back this skill. Read the one that fits the moment; do not load both up front.

- `references/institution-layers.md` — the two-layer model of institutional documents (a global constitution versus a project's own rules) and how to decide which layer a given piece of knowledge belongs to. Read this when composing or auditing a manifest, or when the user asks whether something should be shared across the fleet.
- `references/drift-model.md` — how to read a difference between the origin and a destination: when it is a stale copy to refresh, and when it is a deliberate local edit to preserve and consider re-importing. Read this when running status or push, or when interpreting a diff.

## The one thing to hold onto

A file earns a place in the fleet manifest only when it is the kind of institution that *should* be identical everywhere. Shared coding conventions, a common section of a personal constitution, a settings fragment every project wants — these are global institutions, and drift between copies of them is a defect. A rule that only makes sense for one project's architecture is not a global institution however useful it is locally, and distributing it makes the fleet worse, not better. When unsure which layer something belongs to, read `references/institution-layers.md`; it exists to resolve exactly that question.
