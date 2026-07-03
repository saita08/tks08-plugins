# The Two Layers of an Institutional Document

An institutional document — a `CLAUDE.md`, a coding-convention file, a settings fragment — governs how work is done. But not all such governance belongs at the same altitude. This file explains the two layers, so that what fleet-sync distributes to every repository is genuinely the kind of thing that should be identical everywhere, and what stays local stays local.

The manifest is only as good as this judgment. Distribute the wrong layer and the fleet is worse off: a global copy of a project-specific rule imposes one project's local shape on all the others, and every destination then either carries a rule that does not fit or edits it away, generating exactly the drift fleet-sync exists to prevent.

## The global layer: what should be identical everywhere

The global layer holds the institutions that express a person's or an organization's values and standards independent of any single project. These are the things a new project should inherit on day one and that should not quietly diverge as projects multiply.

Signals that a piece of knowledge belongs to the global layer:

- **It is true regardless of the project's domain.** "Write commit messages that explain why, not what" holds whether the project is a web app or a firmware image. It does not depend on what the project is.
- **Divergence between copies is a defect, not a feature.** If two projects having different versions of this rule would be a mistake someone would want to fix, the rule wants to be shared and kept in sync — which is precisely what fleet-sync provides.
- **It encodes a value, not a mechanism.** Values ("prefer the solution the world has already tested") travel across projects; mechanisms ("run `make lint` before pushing") are often bound to one project's tooling and do not.
- **A new project would want it from the start.** If you would copy this into the next repository you create without thinking, it is a global institution, and copying-without-thinking is exactly the manual drift-prone process fleet-sync replaces.

Typical global-layer artifacts: a shared section of a personal or team `CLAUDE.md`; a coding-style or review-standard document that applies across the whole codebase portfolio; a settings fragment (permissions, environment defaults) every project should start with; a reusable hook script that enforces a universal discipline.

## The project layer: what is true only here

The project layer holds the rules that make sense only in the context of one project's architecture, domain, history, or tooling. These belong in the project's own instructions file and must not be distributed, because they are not true anywhere else.

Signals that a piece of knowledge belongs to the project layer:

- **It references something specific to this project.** A particular module boundary, a named service, a schema quirk, a deployment target. The moment a rule names a thing that exists only here, it cannot be global.
- **It would be wrong or meaningless in another project.** "The `billing` module must never import from `web`" is load-bearing here and nonsense in a project with no such modules.
- **It is a local decision, not a shared value.** A choice this project made about its own structure — a directory convention, a framework version constraint — that another project has every right to decide differently.

Project-layer knowledge has a home: the project's own `CLAUDE.md`. Putting it there is not a lesser fate than distribution; it is the correct home. The mistake is not "failing to globalize" a local rule but treating globalization as a promotion. The two layers are peers with different scopes, not a hierarchy.

## The boundary case: a value that needs local mechanism

Some institutions are global in their value and local in their mechanism. The value "every project must run its checks before merging" is global; the command that runs the checks differs per project. The discipline here is to distribute the value at the global layer and let each project supply the mechanism at the project layer, rather than distributing a mechanism that only fits one project or diluting the value into vagueness to make it portable.

When this split is clean, fleet-sync distributes the value-bearing file and each destination keeps its own mechanism-bearing file un-distributed. When it is not clean — when value and mechanism are tangled in one file — that tangle is the signal to separate them before adding the file to the manifest, not to distribute the tangle.

## Why this judgment cannot be automated away

It is tempting to want a rule that sorts files into layers mechanically. There is none, because the same sentence can be global in one person's practice and project-specific in another's, depending on how much of their work it actually spans. The judgment is about the person's real portfolio of projects, which is context the tool does not have. That is why fleet-sync asks the user to declare the manifest rather than inferring it: the declaration is where this judgment gets recorded, and keeping it honest is the user's ongoing responsibility, informed by the model above.
