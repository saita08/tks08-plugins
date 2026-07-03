---
description: Dig your accumulated Claude usage history — command frequency, prompt shapes, usage rhythm, and recurring manual work — dedupe against what you already have, and propose plugin candidates ranked by evidence.
argument-hint: "[サンプリングする最大トランスクリプト数（省略時は既定値）]"
allowed-tools: Bash, Read
---

# Dig the usage history for plugin candidates

Your job is to read the strata of the user's accumulated Claude usage, find the patterns that want to become automation, drop anything they already have, and propose the survivors ranked by how much evidence backs each. You propose; you do not build. Building is handed to `pluginize` or `plugin-dev`.

Read `${CLAUDE_PLUGIN_ROOT}/skills/forge-candidate/references/fit-criteria.md` before you judge or rank a candidate. Do not load it until you reach that step.

## The cursor: never read the whole history

`history.jsonl` has thousands of lines and transcripts run to hundreds of megabytes. This command is incremental. The cursor at `~/.claude/idea-forge/state.json` records how far into `history.jsonl` the last dig read and which transcripts it sampled. Each run digs from there, up to a cap, and advances the cursor when it finishes.

## Procedure

### 1. Mine the statistical strata

Run the stats script. It reads `history.jsonl` from the cursor forward and `stats-cache.json` in full (it is small and pre-aggregated), and prints command frequencies, prompt-shape clusters, and the usage rhythm as JSON.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/dig-stats.sh" ${ARGUMENTS:-}
```

It prints `{"command_freq":{...}, "prompt_shapes":[...], "rhythm":{...}, "history_new_lines":N, "cursor_exists":bool}`. `command_freq` counts slash-command usage; `prompt_shapes` clusters recurring non-command prompt skeletons; `rhythm` summarizes the daily/hourly activity from stats-cache. These are the frequency and rhythm strata.

### 2. Sample transcripts for recurring manual work

Run the transcript sampler. It selects transcripts newer than the cursor (capped), and for each asks a lightweight `claude -p` call to spot recurring manual procedures or hand-run sequences — work that looks like it wants automation.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/dig-transcripts.sh" ${ARGUMENTS:-}
```

It prints `{"manual_work":[{"pattern","evidence","project"}...], "sampled":N}`. Each `manual_work` item is a recurring hand-run pattern one session surfaced. Run bounded and synchronously — the sampler enforces the cap and the recursion guard internally.

### 3. Enumerate what the user already has

Run the inventory script to list installed plugins and their commands/skills, so candidates that merely re-describe existing capability can be dropped.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/dig-inventory.sh"
```

It prints `{"plugins":[{"name","commands":[...],"skills":[...]}...]}`. Also keep in mind Claude Code's built-in features (its native slash commands, file tools, task and subagent machinery) — a candidate that duplicates a built-in is not a candidate. `fit-criteria.md` spells out the dedup test.

### 4. Assemble, dedupe, and rank

Pool the strata: command frequencies, prompt shapes, usage rhythm, and manual-work patterns. Then, reasoning from `fit-criteria.md`:

- **Drop non-fits.** Remove anything that is not implementable as plugin parts (command/skill/hook/agent/MCP), duplicates an installed plugin or a built-in, is specific to one single project, or needs accumulated data to exist before it can work.
- **Rank by evidence density.** A candidate backed by convergent evidence across strata — a prompt shape that recurs *and* shows up as manual work *and* has no existing plugin — ranks above one supported by a single thin signal. Lead each candidate with its strongest evidence. Candidates with only a faint, single-stratum signal sink to the bottom or drop out entirely; do not pad the list.

### 5. Advance the cursor and report

Advance the cursor whether or not any candidate survived:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/dig-commit.sh"
```

Then present the surviving candidates, richest evidence first, as your final message. For each: what the automation would be, which strata's evidence supports it (with the concrete counts/quotes), the plugin parts it would likely need, and one line on why it is not already covered by what the user has.

Close by pointing the user to the next step: to actually build a candidate, hand it to `pluginize` (if it is live in current work) or `/plugin-dev:create-plugin` (to build it in dialogue). The forge proposes; it does not build.

If nothing survived, say so plainly. A dig that surfaces no candidate means either the history is still shallow or the user's automations already cover their patterns — both are fine outcomes. Do not manufacture a weak candidate to have something to show.

## Constraints

- Do not build any plugin. The forge proposes candidates and hands them off; construction belongs to `pluginize` or `plugin-dev`.
- Stay within the cap and advance the cursor. The command must remain incremental and bounded.
- Do not propose a candidate that duplicates an installed plugin or a built-in feature. Deduping against what the user already has is part of the job, not an afterthought.
- Do not pull raw transcript dumps into the conversation. Sampling happens in the subagents; the main context receives only structured findings.
- Read only — this command analyzes `~/.claude/` data and never sends any of it to an external service.
