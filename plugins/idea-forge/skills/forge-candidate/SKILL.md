---
name: forge-candidate
description: This skill should be used when judging whether a pattern dug out of accumulated Claude usage history is worth proposing as a plugin, and how to rank the survivors — for example when the user asks to "evaluate this plugin candidate", "is this worth a plugin", "rank these automation ideas", "filter my usage patterns", "候補を絞って", or "根拠の濃い順に並べて". Provides the fit test (implementable as plugin parts, not a duplicate of an existing plugin or built-in, not single-project-specific, not dependent on data that must accumulate first) and the evidence-density ranking discipline.
allowed-tools: Read
---

# Forge a candidate from usage history

This skill governs the judgment step of a dig: given patterns pulled from the usage strata (command frequency, prompt shapes, usage rhythm, recurring manual work), decide which ones are genuine plugin candidates and rank the survivors by evidence. The forge proposes; it does not build. Handoff goes to `pluginize` or `plugin-dev`.

Read `references/fit-criteria.md` before judging or ranking. It carries the fit test and the ranking discipline. Do not proceed on intuition when the file states the rule.

## The two questions

Every dug pattern faces two questions in order:

1. **Does it fit?** Is it implementable as plugin parts, free of duplication with what the user already has, general beyond one project, and useful without waiting for data to accumulate? A pattern that fails any of these is not a candidate — say so and drop it. The fit test is in `fit-criteria.md`.

2. **How strong is the evidence?** Among the patterns that fit, the ones backed by convergent evidence across strata rank above the ones resting on a single thin signal. Evidence density, not novelty or cleverness, sets the order. The ranking discipline is in `fit-criteria.md`.

## Propose, do not build; and do not pad

The forge's output is a ranked list of candidates, each led with its strongest evidence and paired with the plugin parts it would likely need and a line on why it is not already covered. That is the whole output. The forge does not build the plugin, does not launch a generation session, and does not publish. Building is handed off.

An honest short list beats a padded long one. A dig that surfaces one well-evidenced candidate, or none at all, has done its job. Do not inflate a faint single-stratum signal into a candidate to make the list look richer; a weak proposal the user has to reason past costs more attention than it saves.

## Resources

- `references/fit-criteria.md` — The fit test (four disqualifiers) and the evidence-density ranking discipline.
