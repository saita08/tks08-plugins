---
description: Distill a Workflow you just built or designed into a reusable spell — script plus when-to-use — and append it to your personal grimoire.
argument-hint: "[呪文の名前（省略可）]"
allowed-tools: Read, Glob, Grep, Bash, Write
---

# Inscribe a Spell

Turn a Workflow you just assembled, or one designed in this conversation, into a spell the user can cast again. Inscribing distills the working script into the grimoire's form — a complete script, a note of when to use it, and the meaning of its arguments — and appends it to the user's personal grimoire, which extends the bundled collection.

## Step 1 — Locate the Workflow to distill

Find the Workflow this session produced: the script you assembled for a `/grimoire:cast`, a `/parallel-universe` run, or one worked out in the conversation. If nothing in the session is a Workflow script, say so and stop — inscription captures something that exists, it does not invent a spell from scratch. If several were built, ask which one, or take the name in `$ARGUMENTS` as the hint.

## Step 2 — Distill to the spell form

Read `${CLAUDE_PLUGIN_ROOT}/skills/spellcraft/SKILL.md` and `${CLAUDE_PLUGIN_ROOT}/skills/spellcraft/references/spell-form.md` for the form a spell takes and the discipline of writing one. Then distill:

- **Generalize the script.** The working version was fitted to one target with hardcoded paths and specifics. A spell is a template: lift the target-specific values into `args`, and leave the structure — phases, `parallel`/`pipeline`, schemas — intact. A spell pinned to the one case that produced it is a log entry, not a spell.
- **Write the when-to-use.** State the shape of problem the spell fits, generally enough to reach the next, unforeseen instance. Name the conditions under which casting it is waste, so a future cast can decline cheaply.
- **Document the args.** Each argument: what it means, what a real value looks like, whether it is required.

## Step 3 — Append to the personal grimoire

Write the spell as a Markdown file under `~/.claude/grimoire/`, named after the spell in kebab-case. Create the directory if it does not exist. If a spell of that name already exists there, show the user the difference and ask before overwriting — the personal grimoire is the user's own record, not yours to silently replace.

Do not touch the bundled spells under `${CLAUDE_PLUGIN_ROOT}`; those ship with the plugin and are read-only. The personal grimoire is the extension surface. Report where the spell was written and how to cast it: `/grimoire:cast <name> <target>`.
