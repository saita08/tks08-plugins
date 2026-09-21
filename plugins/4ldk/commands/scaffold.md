---
description: Lay out the standard architecture's skeleton in a project — the five layers, plus only the optional layers the product already needs — show the plan, and build it after approval without touching existing code.
argument-hint: "[path to scaffold (defaults to the current project)]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Scaffold

Stand up the skeleton of the standard architecture in a project that does not have it yet. Scaffolding is for a skeleton that does not exist; if the project already has a substantial source tree in another shape, stop and say so — moving existing code between layers is a migration the owner designs, and `/4ldk:check` is the way to see how far the tree is from the rules.

Read `${CLAUDE_PLUGIN_ROOT}/skills/standard-architecture/references/architecture.md` first. It is the single statement of the structure and its rules; this command only builds what it describes.

If `$ARGUMENTS` names a path, scaffold there. Otherwise scaffold the current project.

## Step 1 — Survey before building

Read what the project already is: its language and framework, its build setup, whether a source root exists and what it is called, and what the product is for, from the README, the manifests and the conversation so far. The skeleton goes under the project's existing source root; create `src/` only when there is none.

Check the scale against the document's last section, on where it applies. A product that already needs several deployed services or contracted module boundaries between teams is outside this architecture's range; say so and stop rather than building a skeleton that will be stretched.

## Step 2 — Decide which layers to stand up

The base structure is always built: `models/`, `controllers/`, `services/`, `repositories/`, and `views/` with `pages/`, `components/`, `parts/`, `api/` and `assets/`. A product with no screen of its own gets no `views/`; say that it was left out and why.

The optional layers are built only when the need is already real, because the document adds them on need and an empty layer invites code that does not belong in it:

- `mcp/`, or another entry point, when the product is known to expose one
- `auth/` when the product is known to authenticate its callers
- `gateways/` when an external service the product calls can be named
- `lib/` is never scaffolded. It comes into being when the first function fails every layer's checkpoint

Take the need from what the owner has said and what the repository shows. When neither settles it, ask once, naming the layers in question, rather than guessing in either direction.

## Step 3 — Show the plan and wait

Present the tree that will be created, marking which directories already exist and will be left alone, which optional layers are included and on what evidence, and the text of the adoption note from Step 4. Then wait for approval. Nothing is written before the owner says yes.

## Step 4 — Build

Create the directories. Keep each empty one in version control with a `.gitkeep`, to be deleted by whoever adds the first real file. Write no placeholder source files, no sample entity and no per-directory README: a skeleton that arrives with invented code has to be cleaned before it can be used.

Never overwrite, move or edit an existing file; the one exception is appending the adoption note below to a README, which was shown in the plan. Where the build setup has to know that only `views/` goes through the browser build, report what needs to change and leave the configuration to the owner unless they ask for the edit.

Record the adoption, so that a later session knows which rules govern this tree without being told. Write a short note where the project keeps what is true now — `docs/architecture.md` when a `docs/` exists, otherwise a section of the README, in the language the project's documentation speaks — saying that the project follows the standard architecture of the 4ldk plugin, which optional layers exist today, and which were left out and what would bring them in. Do not restate the rules there; the note points at the rules and records only what is specific to this project.

## Step 5 — Hand over

Verify the build by listing the tree from disk and comparing it with the approved plan. Report what was created, what already existed, what was left out and why, and what only the owner can do next. Do not commit; the owner reviews the working tree.
