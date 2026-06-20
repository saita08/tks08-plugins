---
name: company-migrate
description: >
  This skill should be used when the user asks to "migrate my AI company",
  "update my company to the new Agent Teams API", "fix my company's employee
  call procedure", "my company stopped working after a Claude Code update", or
  wants to bring an existing AI company repository onto the current Agent Teams
  API. Rewrites the removed-API spawn mechanism (TeamCreate / team_name /
  `claude --agent-teams`) into the current one (spawn a Teammate with the Agent
  tool's `name` parameter) after showing the diff and getting Owner approval.
version: 0.1.0
---

# AI Company Migration

Migration tool for AI company repositories that were built against the Agent Teams API that Claude Code removed in v2.1.178.

The company itself is fine. What broke is how its CLAUDE.md tells the CEO to call employees. The old procedure spawned employees with `TeamCreate` and an `Agent` spawn carrying `team_name`, and started the company with `claude --agent-teams`. Those tools and that flag no longer exist. The current API forms the team implicitly when the first teammate is spawned, and the CEO spawns each employee with the Agent tool's `name` parameter. This skill rewrites the procedure, and only the procedure, to match.

## Governing Principles

All behavior in this skill is governed by these principles. When in doubt, refer back here.

1. **Owner approval before any write** — Show the Owner the exact diff and wait for explicit approval before changing a single file. This mirrors `company-builder`'s Non-destruction principle: the plugin proposes, the Owner decides. Never rewrite silently.
2. **Touch only the call mechanism** — Rewrite only the wording that names the removed API. A company's world — its philosophy, its employees' personalities, its custom procedures — is not yours to edit. If a sentence would read the same on any company, it may be migration scope; if it carries this company's identity, leave it untouched.
3. **Evidence before action** — Migrate what you can point to. Every change must correspond to a specific old-API token found in a specific file at a specific line. Do not "improve" prose that happens to be nearby.
4. **Idempotent** — Running migration on an already-migrated company changes nothing. A company that names no removed-API tokens is already current; report that and stop.
5. **Report what changed and why** — After applying, summarize each file touched, the old wording, the new wording, and leave committing to the Owner.

## Prerequisites

The current working directory (or user-specified path) must be an AI company repository with at minimum:
- `CLAUDE.md`
- `COMPANY.md`
- `members/` directory

If these are missing, inform the user this doesn't appear to be an AI company repository and stop.

## What the removed API looks like

These are the tokens that mark a company as built against the removed API. Scan for them:

- `TeamCreate` — the removed team-creation tool
- `TeamDelete` — the removed team-deletion tool
- `team_name` — the deprecated, ignored `Agent` spawn input
- `claude --agent-teams` — the removed startup flag
- Phrasings like "spawn ... via TeamCreate", "Agent spawn with team_name", "open a new Claude Code session with `claude --agent-teams`"

## What the current API looks like

The replacement wording, consistent with what `company-builder` now generates:

- Spawn an employee: "Spawn the employee as a Teammate with the Agent tool, passing a `name`. The team forms implicitly when the first teammate is spawned, so there is no separate team-creation step."
- Start the company: "Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (in `settings.json` or the environment) and use Claude Code v2.1.178 or later, then open a new Claude Code session at the company." Replace a `claude --agent-teams` example with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude`.
- Shut an employee down: if the company describes ending a teammate's session, the current mechanism is a shutdown request sent by name, which the teammate approves. There is no `TeamDelete`.

## Where the removed API usually lives

Scan these, but go by what Grep finds, not by this list alone — a company may have customized file names:

- `CLAUDE.md` — the "Employee Call Procedure" and any "Standup" / startup instructions
- `standards/meeting-rules.md` — direct inter-employee messaging description
- `members/*.md` — a Collaboration section may describe how the employee is called or how they message colleagues
- Any `standards/*.md` or `docs/*.md` that documents how employees are spawned

## Execution Flow

1. **Confirm the repository path** with the user, and confirm it is an AI company repository (Prerequisites).
2. **Scan for removed-API tokens.** Use Grep across the repository for `TeamCreate`, `TeamDelete`, `team_name`, and `claude --agent-teams`. Collect every hit with its file and line.
3. **If there are no hits, stop and report** that the company is already on the current API (Principle 4). Make no changes.
4. **For each hit, compose the rewrite** using the current-API wording above. Rewrite only the clause that names the removed token; preserve the surrounding sentence, the company's voice, and any custom steps (Principle 2). When a hit sits inside this company's own custom prose, rewrite the mechanism and keep the rest verbatim.
5. **Show the Owner the full diff** — every file, every before/after — and ask for explicit approval (Principle 1). Use AskUserQuestion if a hit is ambiguous about whether it is mechanism wording or company identity; when unsure, ask rather than guess.
6. **On approval, apply the edits.** Do not commit — committing is the Owner's decision.
7. **Report** each file changed, what was rewritten, and what (if anything) you deliberately left untouched and why. Suggest the Owner run `/company-health-check` to confirm the Agent Teams readiness check now passes, and remind them to set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and use Claude Code v2.1.178 or later when running the company.
