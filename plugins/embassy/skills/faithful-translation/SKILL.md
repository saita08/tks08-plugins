---
name: faithful-translation
description: This skill should be used when translating an institutional document (a CLAUDE.md, a personal constitution, a set of working principles) into another AI service's format — ChatGPT custom instructions, a Gemini gem, a generic system prompt — or when the user asks "adapt my CLAUDE.md for ChatGPT", "fit my instructions into Gemini", "make a system prompt from my constitution", or is deciding what to cut to meet a length limit. Also consult it when composing or reading the embassy state file.
allowed-tools: Read
---

# Faithful Translation

The value of a carefully grown institution is that its principles reach situations their author never enumerated. That reach lives in generality — a principle states a value and the reasoning behind it, and so applies to the next unforeseen case. The danger in translating such a document to a shorter, differently-shaped target is that the obvious way to shorten a principle is to replace it with a couple of examples, and that is precisely the move that destroys its reach. This skill exists to translate under a foreign service's constraints without committing that betrayal.

Three reference files back this skill. Read the ones the moment calls for; do not load all up front.

- `references/targets.md` — the format, idiom, and hard constraints of each supported target (ChatGPT custom instructions, Gemini gem instructions, generic system prompt, and others). Read this when drafting for a specific target, to know its shape and limits.
- `references/translation-discipline.md` — how to compress a set of principles to fit a limit without hollowing them: tighten the statement of the value, cut whole principles rather than gutting all of them, and report what was cut. Read this whenever a translation has to fit a hard limit.
- `references/state-format.md` — the exact shape of `~/.claude/embassy/state.json`, how the source hash is computed, and how to update one target's entry without disturbing others. Read this when recording a translation or when diffing.

## The one thing to hold onto

When a limit forces a choice, a shorter document of intact principles beats a complete-looking one of gutted principles. A principle compressed into a list of cases reads fine and fits the box, but it has stopped being a principle — the next reader treats the listed cases as the definition and misses everything the value would have covered. So the discipline under pressure is always: shorten by tightening the value's statement, and if that is not enough, drop whole principles and tell the user what you dropped. Never dilute a principle into examples to make it fit. `references/translation-discipline.md` carries this in full.
