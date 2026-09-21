---
name: standard-architecture
description: This skill should be used when laying out the code skeleton of a new product or deciding where a piece of code belongs in one — when the user mentions "4ldk", "use my usual architecture", "the standard architecture", "my solo-dev architecture", "set up the project skeleton", "decide the directory structure", "which layer does this logic go in", "how to split controllers and services", "is this a part or a component", "add an MCP entry point", "should I stand up gateways", "can this go in lib", in any language, or starts a small-to-medium web product that ships as a single deployment. Provides the standard structure (models, controllers, services, repositories, views), the inward dependency rule, the per-layer disciplines, and the one-question classification of view parts.
user-invocable: false
allowed-tools: Read
---

# Standard Architecture

This skill carries the structure its owner adopts for every solo-developed product, small to medium and shipped as a single deployment, so that a project's skeleton is agreed on without being explained again.

One value sits at the core: a change should stop where it starts. Replacing the database stops at repositories, renewing the UI stops at views, adding an entry point never touches the business logic, and a business rule changes in one place that every entry point sees. Every rule in the document is that value applied to one boundary, which is how to judge a case the document did not list.

The architecture itself is stated in one place:

- `references/architecture.md` — the structure, the dependency rules, the sequence between layers, the discipline of each layer, the one-question classification of view parts, and the conditions under which all of this applies. It is the authoritative text. Read it in full before laying out a skeleton, placing a file, or answering a question about where something belongs; it is short, and a rule recalled from its summary is a rule half remembered.

Keep three postures when applying it.

First, a departure is made knowingly or not at all. When a request would break a rule, name the rule and its reason before writing the code, and let the owner decide. Do not comply silently, and do not refuse.

Second, layers beyond the base five exist only once their need is real. Do not stand up `mcp/`, `auth/`, `gateways/` or `lib/` in anticipation; an empty layer invites code that does not belong in it.

Third, the document has a range. When a project shows the signs named in its last section, several deployed services or contracted module boundaries between teams, say so rather than stretching the structure to fit.
