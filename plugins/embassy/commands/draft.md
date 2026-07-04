---
description: Translate an institutional document (your CLAUDE.md, or a named file) into another AI service's format and length limits, preserving the generality of its principles, and write the result to a file for you to paste.
argument-hint: "<対象サービス> [原本ファイルのパス（省略時はユーザーの CLAUDE.md）]"
allowed-tools: Read, Glob, Write, Bash
---

# Embassy Draft

Produce a version of a source institution — a personal constitution, a set of working principles — fitted to a target AI service's format and constraints, so that the same values reach you whichever assistant you are talking to. The translation is written to a file. Pasting it into the target service is your job; this command never sends anything anywhere.

Read `${CLAUDE_PLUGIN_ROOT}/skills/faithful-translation/references/targets.md` for the target's format and constraints, and `${CLAUDE_PLUGIN_ROOT}/skills/faithful-translation/references/translation-discipline.md` for how to compress without betraying the source. Read both before drafting — the discipline is the whole point, and a translation that summarizes by listing cases instead of stating principles has failed even if it fits the limit.

## 1. Resolve the source and the target

`$ARGUMENTS` names the target service first, then optionally a source file. Recognized targets are defined in `references/targets.md` (ChatGPT custom instructions, Gemini gem instructions, a generic system prompt, and others it lists). If the target is not recognized, list the recognized ones and ask which — do not invent a format.

If no source file is given, default to the user's `CLAUDE.md`. Look in the standard locations (`~/.claude/CLAUDE.md` for the global one, `./CLAUDE.md` for a project one) and, if both exist, ask which the user means rather than guessing. Read the source in full; the translation must be faithful to the whole of it.

## 2. Translate under the target's constraints

Each target imposes a format and often a hard length limit. `references/targets.md` carries both. Fit the source into them by following `references/translation-discipline.md`:

- Preserve the generality of each principle. A principle states a value and the reasoning that makes it true; that is what lets it apply to situations the source never enumerated. Compressing it into a list of specific cases destroys exactly that reach. Shorten by tightening the statement of the value, not by replacing it with examples.
- When a hard limit forces something out, cut whole principles rather than hollowing all of them into slogans, and record what was cut. A shorter document of intact principles serves better than a complete-looking one of gutted ones.
- Match the target's idiom. A ChatGPT custom-instruction box, a Gemini gem, and a raw system prompt each expect a different voice and structure; `references/targets.md` describes each.

## 3. Write the draft to a file

Write the translation to the output location. Default to `embassy/<target>.md` under the current directory (for example `embassy/chatgpt.md`), creating the directory if needed. If the user named an output path, honor it. The file holds the ready-to-paste text and nothing else — no meta-commentary inside the content the user will paste.

## 4. Report the translation, and what it cost

After writing, tell the user, in plain text (not in the file):

- where the draft landed,
- if a hard length limit forced anything out, exactly which principles or which content were dropped and why — so the loss is visible and the user can decide whether to re-target, shorten the source, or accept it,
- the reminder that pasting into the target service is theirs to do; embassy does not transmit anything.

## 5. Record the translation state

So that `/embassy:diff` can later tell whether a re-translation is needed, record this translation in `~/.claude/embassy/state.json`: the source path, the target, the output path, and a hash of the source content as translated. Read `${CLAUDE_PLUGIN_ROOT}/skills/faithful-translation/references/state-format.md` for the exact shape of this file and how to update it without clobbering other targets' entries.

## Constraints

- Never send, upload, or transmit anything to any external service. Embassy writes files; the human carries them across the border. This is the firm line the whole plugin holds.
- Never fabricate a target format. If the target is unknown, ask; the constraints of a service you are guessing at will be wrong.
- Never compress a principle into a list of examples to save length. Cut whole principles and say so instead. The generality is the value being translated.
- Do not write meta-commentary into the ready-to-paste file. Observations about the translation go in the chat report, not the artifact.
