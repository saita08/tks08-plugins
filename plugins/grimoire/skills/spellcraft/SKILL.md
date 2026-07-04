---
name: spellcraft
description: This skill should be used when the user wants to write, adapt, or run a Claude Code Workflow script, asks about "workflow authoring", "how do I orchestrate agents in code", "agent()/parallel()/pipeline()", the Workflow schema trap, mentions "呪文", "workflow", "エージェントをプログラムで統率", or when Claude is casting, inscribing, or indexing a grimoire spell and needs the Workflow API and the discipline of writing spells. Carries the craft behind the /grimoire commands.
allowed-tools: Read, Glob, Grep
---

# Spellcraft

Commanding a team of agents in a conversation is one thing; commanding them with a deterministic program is a promotion. A Workflow script is that program — it dispatches agents, waits on barriers, scores with schemas, and resumes from where it stopped. This skill carries the craft of authoring Workflow scripts and the collection of battle-tested ones. Consult the reference that matches the task rather than loading all of them.

- `references/workflow-craft.md` — the Workflow API, precisely: the primitives, the schema object-wrap trap, the pipeline-versus-parallel default, the forbidden nondeterministic calls, and budget-linked scaling. Read before writing or adapting any spell.
- `references/spell-form.md` — the form a spell takes and the discipline of distilling a working Workflow into a reusable one. Read when inscribing.
- `references/spells/` — the bundled spells, each a complete script with when-to-use and args. Read the one being cast.

The bundled spells:

- `references/spells/exhaustive-audit.md` — loop until dry plus adversarial verification; audit a repository until no new findings surface.
- `references/spells/great-migration.md` — enumerate targets, convert each in an isolated worktree, verify; a mechanical change applied across many files.
- `references/spells/truth-panel.md` — one claim contested by N judges through N lenses, then a verdict; adversarial review of a PR or an assertion.
- `references/spells/deep-survey.md` — parallel investigation, deep reads, one synthesis; answer a broad question that no single agent can hold at once.

The idea under all of it: a Workflow is code, so it is repeatable, resumable, and auditable in a way a conversation is not. The craft is in choosing the right barrier, wrapping the schema correctly, and keeping the script deterministic so a resume returns the same run.
