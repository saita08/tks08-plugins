---
description: Report which of your installed plugins, skills, and slash commands have actually fired — counts, last-fired dates, and what has never fired once — plus a best-effort estimate of chances a skill should have fired but did not.
argument-hint: "[任意: 集計の観点や絞り込み。例: このプロジェクトだけ / 直近1週間]"
allowed-tools: Bash, Read
---

# dogfood-lab report

Tell the user which of the things they installed are actually alive. The value is not the firing counts of what works; it is naming what never fired, because a skill that never triggers leaves no trace of its own absence. This report is the trace.

## 1. Gather the aggregated data

Run the aggregator once and read its JSON output:

```
bash "${CLAUDE_PLUGIN_ROOT}/commands/report.sh"
```

It returns an object with:

- `log_path` — where the event log lives.
- `rotated` — non-null if the log exceeded 10MB and was archived this run. If set, mention it once so the user knows older events moved aside.
- `installed_plugins` — plugins known to be installed (from settings' enabledPlugins and the on-disk cache).
- `components` — the skills and commands each installed plugin ships: `{plugin, type, name}`.
- `firings` — per-name aggregates from the log: `{event, name, count, last, projects}`. `event` is `command` or `skill`; `name` is the slash-command token (like `/foo:bar`) or the skill name.

If the aggregator returns an `error`, or `firings` is empty and `installed_plugins` is empty, the log has not collected anything yet. Say so plainly — the loggers only start recording once the plugin is installed and used — and stop. Do not invent numbers.

## 2. Cross-reference fired against installed

Build the report by matching what fired against the full inventory:

- For each installed plugin, sum the firings of its components. A plugin whose every component has zero firings is the headline finding: installed but never once alive.
- List, per plugin, each skill and command with its firing count and `last` date. Skill firings match on the skill `name`; command firings match on the slash-command token, which for a plugin command looks like `/<plugin>:<name>`.
- Call out the **never fired** set explicitly and first — the components present in `components` that have no matching entry in `firings`. This is what the user cannot see any other way.
- Where a firing name has no matching installed component (an ad-hoc skill, or a plugin no longer installed), still report it under a short "seen in the log but not currently installed" note, rather than dropping it.

Keep counts honest. The log only holds slash-command uses and skill firings — it does not see plugins whose value is a hook or an agent, so absence from the log is not proof a plugin is idle, only that its *skills and commands* never fired. Say this where it matters.

## 3. Best-effort: chances that should have fired but did not

This section is an estimate, and you must label it as such. The goal is to catch skills whose trigger conditions were plainly present in recent work yet the skill never ran — the most valuable and least visible failure a plugin author has.

Do this cheaply and honestly:

- Sample a small amount of recent transcript. Find the current project's transcript directory under `~/.claude/projects/` (the directory name is the cwd with slashes turned to dashes) and read the tail of the most recent one or two `.jsonl` files. Keep the sample small; this is a spot check, not an audit.
- For a handful of skills that have **never fired** (from step 2), read their `description` from the on-disk `SKILL.md` (under the plugin's cache dir; the skill file is `<plugin cache>/skills/<name>/SKILL.md`). The description's "should be used when ..." clause names the trigger phrases.
- Look for those trigger phrases appearing in the sampled user turns. When a trigger phrase clearly showed up but the skill never fired, note it as a candidate missed opportunity.

Frame every item here as "possible" and explain the method in one sentence, so the user knows this is pattern-matching on a small sample, not a guarantee. If the sample shows nothing, say the spot check found no obvious missed triggers rather than implying everything is fine.

## 4. Present it

Lead with the never-fired set — the plugins and components that have never once fired — because that is the finding the user installed this plugin to get. Then the alive components with their counts and last-fired dates. Then the best-effort missed-trigger estimate, clearly labeled. Keep it scannable; a short table for the per-component counts reads better than prose. If the user passed an argument narrowing the scope (a project, a time window), honor it in what you emphasize.
