---
name: propose-plugin
description: This skill should be used when the user wants to act on a pluginize suggestion or asks to "pluginize this", "turn this into a plugin", "is this worth a plugin", "propose a plugin", or wants to review and approve a reusable-structure candidate that surfaced during their work. Presents the candidate with the value of building it, takes explicit approval, and then launches the plugin generation in an isolated background session so the main conversation stays clean.
argument-hint: [候補の要約（省略可。hook が出した候補をそのまま渡してもよい）]
allowed-tools: Read, Glob, Grep, Bash
---

# Propose a Plugin

Help the user decide whether a reusable-structure candidate is worth turning into a plugin, take their explicit approval, and then hand the heavy work off to an isolated background session. The main conversation does the noticing, proposing, and launching; it does not build the plugin. Building is delegated to the dedicated creation workflow running in the background, where the user can join the dialogue directly.

Three reference files back this skill. Read the relevant one before acting; do not load all of them up front.

- `references/detection-axes.md` — what is worth pluginizing, and whether a candidate genuinely wants a plugin rather than a plain skill. Consult when judging or summarizing a candidate.
- `references/plugin-value.md` — the concrete benefits of pluginizing, used to tell the user *why* this is worth building. Consult when presenting a candidate.
- `references/constitution.md` — the values behind every step here. Consult when a situation is ambiguous or the user pushes back.

The single requirement that shapes everything: the heavy generation must not pollute the main context. The main session ends its job at handoff.

## Procedure

### 1. Establish the candidate

If the invocation included an argument, or a `pluginize` hook surfaced a candidate, treat that as the candidate. If neither is present, look at what the user just did and form a candidate from it, reasoning with `references/detection-axes.md`. Keep the candidate to one or two sentences: what the reusable work is, and which axis makes it one.

If the work does not actually clear the bar in `detection-axes.md` — a one-off, a project-specific convention, a mechanically enforceable rule — say so plainly and stop. Not every suggestion should become a plugin, and declining cheaply is part of the value.

### 2. Present the candidate with its value

Show the candidate to the user, and pair it with the concrete benefit of building it, drawn from `references/plugin-value.md`. Lead with the one benefit that fits the candidate's strongest axis rather than listing every possible gain — a candidate that recurs leads with reuse, one that needs automatic timing leads with event-driven firing, one whose value is coordination leads with cooperating components.

If the candidate is real but is better as a plain skill than a full plugin, say that here. An honest framing serves the user better than inflating a single technique into a plugin.

### 3. Take explicit approval

Ask the user, in plain text, whether to proceed with generating the plugin. Wait for their answer. Do not use a selection prompt; a plain question keeps this skill to least privilege.

Nothing heavy happens before an explicit yes. The approval means two things at once: it confirms the user actually wants this candidate built, and it is the proof that this tool does not act on the user's machine unbidden. Because it carries both meanings, it cannot be assumed or inferred from prior willingness, and a yes to an earlier candidate does not carry over. Until the user approves, do not assemble the launch, do not start a background session, and do not edit any files toward building the plugin.

### 4. Assemble the generation prompt

Once approved, open `references/generation-prompt.md` and fill its template from the candidate: what it is, why it is worth capturing, its sketched component shape, and a short note of origin context. Keep it concise — it seeds a dialogue, not a specification. The template already carries the two constraints the creation workflow needs (scope is a flag not a fork; publication is recommended never performed), so do not restate plugin-building guidance beyond what the template holds.

### 5. Launch the isolated background session

Start the generation in an isolated session and capture its session id:

```
claude --bg --name "pluginize: <short candidate name>" "/plugin-dev:create-plugin <filled-in generation prompt>"
```

The background session is a full, isolated Claude Code session. Its file edits are isolated to a worktree, and the user can join it through the agent view to shape the plugin in dialogue — which is exactly where the creation workflow's back-and-forth belongs.

### 6. Hand off and stop

Leave the main conversation only the minimum it needs to follow up, and nothing of the generation's weight:

- the background session id and its name,
- how to reach it: `claude logs <id>`, `claude attach <id>`, or the agent view,
- one line that generation is underway in a separate session and the user should join it there to finish the plugin.

Then stop. The main session's job is done. Do not pull the generation's progress back into this conversation, do not begin building the plugin here, and do not act on publication.

## Constraints

- Do not launch the background session, or edit any file toward building the plugin, before the user's explicit approval of this specific candidate. Past approvals do not carry over.
- Do not do the plugin-building work in the main session. Generation is delegated to the background session; the main session only notices, proposes, and launches.
- Do not publish, push to a marketplace, or assume a marketplace exists. Publication is the user's decision; the most this tool does is recommend considering it, and that recommendation happens inside the generated plugin's workflow, not here.
- Do not pull the background generation's dialogue or output into the main context. Keeping the main context clean is the requirement this skill exists to serve.

## Resources

- `references/detection-axes.md` — What is worth pluginizing, and plugin-versus-skill judgment.
- `references/plugin-value.md` — The benefits of pluginizing, for explaining the value to the user.
- `references/generation-prompt.md` — The template handed to the background session.
- `references/constitution.md` — Values and reasoning behind every step. Consult when ambiguous or when the user pushes back.
