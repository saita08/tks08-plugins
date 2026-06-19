# Generation Prompt Template

This file holds the prompt that the proposal skill hands to the isolated background session after the user approves a candidate. The background session runs the dedicated plugin-creation workflow; this prompt is what seeds it with the candidate and frames the few constraints that the creation workflow does not already enforce on its own.

The skill builds the launch command by filling the placeholders below and passing the result as the argument to `/plugin-dev:create-plugin` inside `claude --bg`. Keep the filled-in summary concise: it is a starting point for a dialogue, not a specification. The background session and the user will refine everything in conversation.

## Why this prompt stays thin

The knowledge of how to build a good plugin lives in the creation workflow, not here. Duplicating that guidance in this prompt would only let the two drift apart. So this template carries exactly three things the creation workflow would not otherwise know: what the candidate is, where the artifact must land, and how scope and publication are to be handled. Everything else is left to the workflow.

## The template

Fill each `<...>` placeholder from the approved candidate, then pass the whole block as the argument.

```
We are turning a reusable pattern observed during a session into a Claude Code plugin. Here is the candidate, captured at the moment of approval:

- What it is: <one or two sentences naming the reusable work>
- Why it is worth capturing: <which axis it scored on — repeatability, crystallized procedure, or tacit knowledge — and the concrete benefit>
- Sketched shape: <which components it likely needs: skill / hook / agent / command / MCP, and for skills, whether it reads as a Technique, Pattern, or Reference>
- Origin context: <a short note on what was happening when this surfaced, enough to ground the work without requiring the original conversation>

Build this plugin to the point where it lands as files in the user's local project. Two constraints govern the work:

1. Scope is a flag, not a fork. Decide whether this looks like a project-specific plugin or a candidate that could be useful published more widely, and record that judgment — but the generated artifact lands locally either way. Local is where it gets validated before any wider claim is made.

2. Publication is recommended, never performed. If the plugin looks broadly useful, end by recommending that the user consider publishing it, and explain why. Do not publish, do not push to any marketplace, and do not assume a marketplace exists. Whether, where, and how to publish belongs to the user.

Proceed through the creation workflow with the user from here.
```

## Notes on filling the placeholders

- Draw every placeholder from what was already established with the user during the proposal. The background session should not have to re-derive the candidate from nothing.
- If the proposal concluded that the candidate is better as a plain skill than a full plugin, say so in the "Sketched shape" line rather than forcing a plugin framing. The creation workflow can build a single-skill plugin, and an honest sketch serves the work better than an inflated one.
- Keep "Origin context" to what grounds the work. The point is to give the background session enough footing to start, not to transplant the entire main conversation into it — that would defeat the isolation the whole design exists to preserve.
