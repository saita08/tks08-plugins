# The Form of a Spell

A spell is a working Workflow that has been distilled into something castable again. This file is the form every spell takes and the discipline of distilling one, used when inscribing.

## The three parts

Every spell file, bundled or personal, has the same three parts:

1. **The when-to-use.** The shape of problem this spell fits, stated generally, plus the conditions under which casting it is waste. This comes first because it is the gate a cast checks before running anything.
2. **The args.** Each argument the spell takes: what it means, what a real value looks like, whether it is required. This is the interface between the caster's target and the script.
3. **The script.** The complete Workflow, ready to adapt. Not a sketch, not a fragment — a script that would run if its args were filled.

A file missing any of the three is not a spell. A script with no when-to-use cannot be cast safely because nothing tells the caster when to decline. A when-to-use with no script is a wish.

## Distilling: generalize, do not transcribe

The hardest part of inscribing is resisting the urge to save the exact script that just ran. That script was fitted to one target, with hardcoded paths and one case's specifics baked in. Saved as-is, it is a log entry that happens to be executable — useful for exactly the target that is now already done, and useless for the next one.

Distilling means lifting the target-specific values out of the body and into `args`, so the structure remains and the specifics become parameters. The phases stay. The choice of `parallel` versus `pipeline` stays, because that choice encodes something true about the problem's shape. The schemas stay. What changes is that "audit the files in src/parser" becomes "audit the files under `args.scope`". A spell reaches the next, unforeseen instance precisely to the degree that its author generalized instead of transcribed.

## Write the when-to-use for a stranger

The person who casts a spell six months from now was not in the session that inscribed it. The when-to-use has to carry, on its own, both the problem shape the spell fits and the conditions under which casting it wastes tokens. State the shape as a value — "when a broad question exceeds what one agent can hold at once" — not as the one case that produced it. Name the anti-conditions plainly, so a future cast can decline cheaply rather than run a spell against a target it does not fit.

## The personal grimoire extends, never overwrites

Inscribed spells land in `~/.claude/grimoire/`, the user's own book. The bundled spells are read-only. When a personal spell shares a name with a bundled one, the personal one wins at cast time — the user's own version of a spell overrides the shipped default. That is the extension model: the plugin ships a starting collection, and the user grows their own on top of it without ever editing the originals.
