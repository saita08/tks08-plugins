# Visual Judgment

How to read a screenshot for real breakage instead of a gut feeling that it "looks clean". A judgment is only useful if a reader could open the same image and confirm it, so every observation is written as an observable fact tied to a location in the frame, not as an adjective. "Looks nice" is not a finding; "the submit button's label is clipped on its right edge, the last two characters are cut off" is.

## What to look for

Read the image against this checklist. Each item is a class of breakage that survives code review because code review predicts the render rather than observing it.

**Layout collapse.** Elements that should sit in a row have stacked, a grid has lost its columns, a centered block sits against the left edge, spacing that should be even is ragged. Name the elements and where they landed versus where they should be.

**Overflow and clipping.** Text or a container extends past its bounds: a label cut off mid-word, a card whose content spills over its border, a horizontal scrollbar on something that should fit, text running under a fixed header. Overflow is the most common breakage and the easiest to miss in code, because it only appears at a specific content length or viewport width.

**Contrast and legibility.** Text that is too close in color to its background to read, a disabled state indistinguishable from an enabled one, an icon that vanishes against its surface, a placeholder darker than the entered text. If you cannot read a piece of text in the screenshot, that is the finding — do not fill it in from the code.

**Visual hierarchy.** The most important element is not the most prominent one, a primary and secondary action look identical, everything is the same weight so nothing leads the eye. State what draws attention first and whether that is what should.

**State coverage.** The single most valuable thing visual verification catches: a screen that works when full and populated but was never built for its other states. Check that each intended state was actually captured and actually holds — the empty state (no data), the error state, the loading state, and the extreme-content state (a very long name, a paragraph where a line was expected, a number with many digits). A missing empty-state design shows as a blank void or a broken layout, and only a screenshot of that state reveals it.

**Viewport comparison.** When the same surface was captured at more than one width, compare them directly. A layout that holds on desktop and collapses on mobile is the canonical responsive bug. Look for elements that overflow only at the narrow width, touch targets that shrink below usability, and content that reflows into an unreadable order.

**Timing and motion, for video surfaces.** Across the sampled frames, check that elements appear and leave when they should, that text animating in is fully on-screen at the frame it should be readable, and that nothing that should have exited is still lingering. A single frame cannot show this — the judgment is in the comparison across the start, middle, and end stills.

## Matching against intent

Breakage is only half the judgment. The other half is whether the surface does what the work meant it to do — the design's aim, not just its structural soundness. A screen can be free of overflow and still miss the point: the call to action the task wanted emphasized is buried, the mood the design aimed for is not there, the thing the user asked to be visible is technically present but lost. State the intent as you understand it, then say whether the image serves it, and where it falls short.

When you do not know the intent well enough to judge it, that gap is itself the report — capture the surface, describe what it shows, and ask the user what the intended emphasis or behavior was rather than inventing one.

## Writing the observation

- Anchor every finding to a location: which element, which corner, which state, which viewport. A finding without a location cannot be confirmed or fixed.
- Describe what is there, not how it feels. "The three cards have unequal vertical gaps, the second gap is roughly twice the first" beats "the spacing feels off".
- Separate breakage from taste. A clipped label is breakage and you fix it. A color choice you find unappealing is taste and you return it to the user. Conflating the two either lets real bugs pass as opinion or imposes your aesthetic as if it were a bug.
- When you fix and recapture, say what changed in the new image versus the old one, so the fix is verified by observation and not by assumption.

## Where the judgment stops

This looking is a net for obvious breakage, cast before the work reaches a human's eyes. It is not a designer and does not replace one. Its successful outcome is either "no breakage found, here is what I observed" or "here is the specific breakage, fixed and re-verified" or "here is a difference that is a design decision, and here is the screenshot for you to decide". Guessing at the user's taste and silently acting on it is outside the net's job; surfacing the screenshot so they can decide is inside it.
