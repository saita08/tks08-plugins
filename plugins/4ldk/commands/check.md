---
description: Inspect a project that follows the standard architecture for violations — imports that point outward, entry points calling each other, fetch outside views/api, parts that know the domain, misplaced logic — and report each with its evidence, without fixing anything.
argument-hint: "[path or layer to check (defaults to the whole project)]"
allowed-tools: Read, Glob, Grep
---

# Check

The architecture exists to stop a change from propagating: replacing the database stops at repositories, renewing the UI stops at views, adding an entry point never touches the business logic. Each violation is a place where that guarantee has quietly stopped holding, and it costs nothing until the day the change it was meant to contain arrives. This command finds those places and reports them. It does not fix anything; whether a finding is a mistake or a departure made on purpose is the owner's to say.

Read `${CLAUDE_PLUGIN_ROOT}/skills/standard-architecture/references/architecture.md` first. It is the single statement of the rules; every finding cites the rule it breaks from there. If the project carries an adoption note (`docs/architecture.md` or a README section written by `/4ldk:scaffold`), read it too: a departure recorded there is known, and is listed as such rather than as a violation.

If `$ARGUMENTS` names a path or a layer, scope the check to it. Otherwise check the whole source tree.

## Step 1 — Map the tree onto the layers

Find the source root and identify which directory is which layer, including the optional ones (`mcp/` or other entry points, `auth/`, `gateways/`, `lib/`), and which file is the entry file that starts the application and assembles the implementations. Learn the project's import syntax and path aliases from its language and configuration, so that an aliased import is resolved to the layer it really reaches. Report any top-level directory under the source root that is none of the known layers; a layer the document does not describe is a finding in itself, since it stands up no layer only for conversion or for a local library's convenience.

If the tree does not follow this architecture at all, say so and stop. Measuring a differently shaped project against these rules produces noise, not findings.

## Step 2 — Mechanical checks

These are decided by imports and calls, and each holds or does not. Run every one of them as a search over the whole layer, not as an impression from the files already read: list each layer's import lines with Grep and compare them with the rule, and search all of `views/` for network calls rather than recalling where they were seen. A check that was not searched is reported as not run, never as passed.

A mechanical rule that is broken is a violation, however reasonable the code looks. Do not soften it into an ambiguity or move it to the judgment findings; whether it was done on purpose is the owner's to say, and the adoption note is where they say it.

- **models** import nothing from any other layer. A library imported into models is reported as well, since the document admits none there as a rule; name the library so the owner can judge the exception.
- **services** import no entry point, no `auth/`, and nothing from `views/`. They import nothing from `repositories/` or `gateways/`, not even a type: the boundary types are theirs to declare, and the implementation arrives as an argument. They import no database driver, no SDK of an external service and no HTTP framework; that knowledge belongs to repositories, gateways and the entry points.
- **Entry points** (`controllers/`, `mcp/` and their siblings) do not import each other. They reach persistence and the outside world only through services, and they do not import `repositories/` or `gateways/` at all, not even to pass one on: assembling the implementations belongs to the entry file alone.
- **The entry file** is the one place that imports repositories and gateways to hand them to services. A second place that assembles them is a violation, wherever it is.
- **repositories and gateways** import no entry point and nothing from `views/`. They may import from services the types that services decided for the boundary, and nothing else from there: a type import is the rule working, a value import is a dependency pointing outward.
- **views** import nothing from the server side except `models/`. Inside views, network calls (`fetch` or an HTTP client) appear only under `views/api/`.
- **views/parts** import nothing from `models/`, `views/components/`, `views/pages/` or `views/api/`.
- **lib** imports no layer.

## Step 3 — Judgment checks

These need reading, not matching. Report them separately from the mechanical findings and say what was seen, since the owner may read the same code differently.

- A service file named after an entity rather than a feature, or one that has grown to hold several unrelated use cases.
- The same entity rule (a state-transition constraint, a derived value) written in more than one service instead of once in models.
- Logic in an entry point beyond interpreting the request, validating its form, calling services and shaping the response; in particular a business rule validated at the entry point, or the same rule implemented separately in two entry points.
- A service that decides an HTTP status or another entry point's representation, instead of throwing a domain error for the entry point to convert.
- A library's own type crossing out of its layer: a database row type or an SDK response type appearing in a service's signature, a framework request object passed into services.
- A part in `views/parts/` that carries the product's name or domain vocabulary in its name, props or text, even without importing models.
- Something in `lib/` that carries a layer's knowledge and would have passed one of the layer checkpoints.

## Step 4 — Report, do not fix

Present a short report: the layer map as found, then the mechanical violations, then the judgment findings, then the departures already recorded in the adoption note. Each finding gives the file and line, the import or code that shows it, the rule it breaks, and in one sentence which change it lets propagate. Group repeated instances of one cause together; a pattern is reported as a pattern, not as forty lines. If nothing was found, say which checks ran and that they passed.

Then stop. Do not edit, move or rename anything. Acting on the report is a separate step the owner directs.

## Constraints

- Report only. This command reads; it never edits, moves, or creates files.
- A finding without evidence is not a finding. Cite the line.
- The report is the findings alone, without working notes before it and without emoji or status icons; a finding's weight is in its evidence.
- When a case is ambiguous, surface the ambiguity instead of resolving it silently.
- The rules come from the document. Do not invent stricter ones, and do not flag general code-quality matters that the architecture does not speak to.
