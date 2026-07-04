# Fit Criteria and Evidence-Density Ranking

This document is the source of truth for two decisions the dig makes: whether a pattern pulled from the usage strata is a genuine plugin candidate, and how the survivors are ordered. It is not a checklist; it is the reasoning, so the right call can be made on a pattern these words did not anticipate.

## The forge digs the well, but only draws water worth carrying

The dig casts a wide net over the strata — command frequencies, prompt shapes, usage rhythm, recurring manual work — precisely because the value of history is that it shows what actually recurred rather than what feels reusable. But a wide net pulls up more than it should keep. The fit test below is the filter, and it lives after detection, not inside it: detect generously, then discard honestly. A candidate list padded with near-misses trains the user to skim past it, and once skimmed, the well-evidenced candidate is lost with the noise.

## The fit test: four disqualifiers

A pattern is a candidate only if it survives all four. Failing any one drops it, and the drop should be stated plainly rather than hidden.

**Is it implementable as plugin parts?** A plugin is built from commands, skills, hooks, agents, and MCP servers. A pattern that could be captured as one or more of these fits. A pattern whose value is really a change in the user's own workflow, a piece of external tooling, or a service the plugin system cannot reach does not — however often it recurs. The question is not "is this a good idea" but "is this a good idea that plugin parts can carry."

**Is it a duplicate of something the user already has?** This is the disqualifier the dig exists to enforce and the easiest to miss. A pattern that an installed plugin already handles is not a candidate — the structure is already encoded, and re-proposing it offers nothing however procedural it looks. The same holds for Claude Code's built-in features: its native slash commands, its file and search tools, its task and subagent machinery. A candidate that re-describes a built-in is a candidate to build something that already ships. Check every surviving pattern against the installed-plugin inventory and against the built-ins before proposing it.

**Is it general beyond one project?** A pattern that only makes sense inside one specific project — its stack, its layout, its conventions — belongs in that project's `CLAUDE.md`, not in a distributable plugin. A plugin's worth is that it travels; a pattern that cannot leave one repository is not plugin-shaped. When the evidence for a pattern all comes from a single project and concerns that project's specifics, treat it as project-local and drop it from the plugin candidates.

**Does it work without waiting for data to accumulate?** Some tempting patterns need a body of accumulated data to exist before they can function. A candidate whose value only appears after the user has already built up the very history it would analyze is putting the cart before the horse — it cannot help the user who installs it fresh. If the pattern presupposes accumulated data that does not yet exist for a new user, it is not a candidate the forge should propose from this dig.

## Ranking: evidence density, not novelty

Among the patterns that fit, the order is set by how much evidence backs each — not by how clever or novel it sounds. The strata are independent witnesses, and a candidate that more than one witness supports is more likely to be real.

Rank higher when:

- **Evidence converges across strata.** A prompt shape that recurs in `history.jsonl` *and* shows up as recurring manual work in the transcripts *and* has no covering plugin is triply attested. Convergence is the strongest signal the dig can produce.
- **The counts are high.** A shape typed forty times is stronger evidence than one typed three times. Frequency is not everything, but at equal fit it breaks ties.
- **The manual work is concrete and repeatable.** A hand-run procedure the transcripts show happening the same way more than once is stronger than an abstract-sounding pattern with one thin quote.

Rank lower, or drop entirely, when:

- The pattern rests on a single thin signal — one stratum, low count, no corroboration. It may still be real, but it does not earn a high slot, and if the signal is faint enough it does not earn a slot at all.
- The evidence is a rhythm observation with no accompanying content signal. Knowing the user works Tuesday mornings is not, by itself, a plugin candidate; rhythm corroborates a content pattern but rarely stands alone.

## Lead each candidate with its strongest evidence

When presenting a surviving candidate, lead with the single strongest piece of evidence that makes it a candidate, then name the plugin parts it would likely need and the one reason it is not already covered. One well-aimed piece of evidence persuades more than a recitation of every stratum. The proposal is not trying to win; it is giving the user enough to decide whether to hand this candidate to `pluginize` or `plugin-dev` to build.
