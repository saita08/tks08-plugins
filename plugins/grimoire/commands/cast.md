---
description: Read a spell from the grimoire, adapt its arguments and prompts to the given target, run it as a Workflow, and report the result.
argument-hint: "<呪文名> [対象・引数]"
allowed-tools: Read, Glob, Grep, Bash, Write
---

# Cast a Spell

A spell is a battle-tested Workflow script — a deterministic program that commands a team of agents. Casting one means reading it, fitting it to the target in front of you, running it, and reporting what it found. The user is casting deliberately from the slash menu, which is the sanctioned, opt-in way to invoke a Workflow, so run it openly.

## Step 1 — Find the spell

The spell name is the first token of `$ARGUMENTS`; the rest is the target and any arguments. Look for the spell in two places, personal grimoire first so a user's own version overrides the bundled one:

- `~/.claude/grimoire/*.md` — the user's personal spells, added by `/grimoire:inscribe`.
- `${CLAUDE_PLUGIN_ROOT}/skills/spellcraft/references/spells/*.md` — the bundled spells shipped with the plugin.

If the name matches nothing, list the available spells by their titles and stop. Do not improvise a spell that does not exist. If it matches more than one, prefer the personal one and say you did.

## Step 2 — Read the spell and its contract

Each spell file carries three things: the complete Workflow script, a "when to use" section, and the meaning of its `args`. Read all three. The "when to use" section is a gate — if the target plainly does not fit what the spell is for, say so and stop rather than casting it anyway. A `truth-panel` cast at a target with nothing to contest, or a `great-migration` with nothing to migrate, just spends tokens to confirm the obvious.

Before assembling, read `${CLAUDE_PLUGIN_ROOT}/skills/spellcraft/SKILL.md` and the reference it points to for the Workflow API. The schema object-wrap rule and the pipeline-versus-parallel default are load-bearing; a spell adapted in violation of them fails quietly.

## Step 3 — Adapt to the target

A spell is a template, not a fixed incantation. Fit it to this target: fill the `args` from the invocation, and adapt the agent prompts so they name the real files, the real claim, the real migration at hand. Preserve the spell's structure — its phases, its use of `parallel` versus `pipeline`, its schemas — and change only what the target requires. Scale the agent count to the budget: check `budget.remaining()` and, if it is thin, reduce the fan-out and `log()` that you did.

## Step 4 — Cast and report

Write the adapted script to a temp file and run it with the Workflow runner. When it finishes, report what the spell was for: the audit's findings, the migration's per-target results, the panel's verdict, the survey's synthesis. Attribute the result to the spell so the user knows which incantation produced it. If the spell wrote files in isolated worktrees, the user's tree is untouched until they approve applying the changes — say so, and wait. Do not commit; the user reviews the working tree.
