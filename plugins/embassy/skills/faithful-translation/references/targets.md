# Target Services: Formats and Constraints

Each AI service that can hold a standing instruction has its own shape, idiom, and limits. This file records them so a translation fits the target rather than being pasted in and truncated or ignored. When a target the user names is not here, do not invent its format — ask, or say the target is unsupported. A guessed constraint is a wrong constraint, and a translation built on it will be silently cut or malformed at the border.

The limits below are the kind of thing services change over time. Treat them as the current best understanding, and if the user reports the target rejected the paste for length, believe the user over this file and note the discrepancy so it can be corrected.

## ChatGPT — custom instructions

**Where it goes:** the "custom instructions" settings, which historically expose two boxes — roughly "what should the assistant know about you" and "how should the assistant respond". A standing constitution maps mostly to the second box (how to behave), with identity and role context in the first.

**Constraint:** each box has a hard character limit (on the order of 1500 characters per box in the classic form; verify against what the user's account actually enforces). This is the tightest common target and the one where the translation discipline matters most.

**Idiom:** direct second-person address to the assistant ("You prioritize...", "When unsure, you ask rather than guess"). No headings inside the box; it is a prose field. Dense, plain, imperative. There is no room for the reasoning paragraphs a full constitution carries, so each principle compresses to its value stated as an instruction — but stated as a general value, never as a list of specific cases.

**What to drop first under the limit:** meta-discussion about the document itself, worked examples, and anything that restates a value already stated. Keep the values; cut the scaffolding around them.

## Gemini — gem instructions

**Where it goes:** a Gem's instruction field. Gems are configured assistants with a persistent instruction set.

**Constraint:** more generous than ChatGPT's boxes, but still bounded; do not assume it is unlimited. Structure is tolerated better here than in the ChatGPT box.

**Idiom:** Gemini gem instructions accept light structure — a short role framing followed by grouped guidance. Second-person or role-declarative both read acceptably. Because there is more room, principles can keep a compressed clause of their reasoning, not only the bare value. Use the extra room to preserve generality, not to add examples.

## Generic system prompt

**Where it goes:** any place that takes a raw system prompt — an API `system` field, a self-hosted assistant, another tool's persona configuration.

**Constraint:** effectively set by whatever consumes it; often the most generous of the three, sometimes token-bounded. Ask the user if a specific limit applies.

**Idiom:** the closest to the source's own form. A system prompt can carry sectioned principles with their reasoning largely intact, so the translation here is mostly a re-voicing (second person, "You are an assistant that...") rather than a compression. This is the target that loses the least, and it is the right default when the user just wants the institution to travel without naming a specific consumer.

## The shared rule across targets

Whatever the target, the translation carries the source's *values*, re-voiced and re-fitted, never a different set of values. Fitting the format and the length is a presentation problem; preserving what the institution actually says is the substance, and the substance never bends to fit the box. When the box is too small for the substance, that is reported to the user as dropped principles (see `translation-discipline.md`), not resolved by quietly weakening what remains.
