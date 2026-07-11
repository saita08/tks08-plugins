# Timing and Easing

The keyframe recipes say *how* to move; this file says *how fast* and *along what curve*. The values below are the consensus of the major motion design systems — deviate deliberately, not by omission.

## Duration bands

- Under 100ms reads as instantaneous; use for immediate feedback (toggles, key presses)
- 100–200ms: small elements — hovers, icon micro-interactions
- 250–400ms: larger surfaces — modals, panels, screen transitions
- 500ms and above reads as lag for UI motion; reserve longer durations for decorative/character loops, where 1.5–3s cycles are normal
- Duration scales with size and travel distance: a switch takes ~100ms, a full-screen transition ~400ms
- Entrances run slightly longer than exits (roughly 4:3), entering with a decelerating curve, exiting with an accelerating one

Character loops sit outside these bands on cycle length, but inside them on event length: within a 2.4s hop loop, the landing impact itself still spans roughly 200–400ms of the timeline.

## Easing vocabulary from the design systems

Useful as starting points when designing a `cubic-bezier()`; the rule in SKILL.md stands — write the value out, never the keyword:

- Material 3 emphasized-decelerate (entrances, expressive): `cubic-bezier(.05,.7,.1,1)`
- Material 3 emphasized-accelerate (exits): `cubic-bezier(.3,0,.8,.15)`
- Material 3 standard (small utilitarian moves): `cubic-bezier(.2,0,0,1)`
- Carbon productive (efficient, data-dense UI): `cubic-bezier(.2,0,.38,.9)`
- Carbon expressive (page-level, celebratory): `cubic-bezier(.4,.14,.3,1)`
- Back-out overshoot (snapping into a pose): `cubic-bezier(.34,1.56,.64,1)` — y > 1 produces the overshoot
- Wind-up anticipation: `cubic-bezier(.6,-.28,.35,1)` — y < 0 produces the dip

The single legitimate use of `linear` is continuous rotation (a spinner's rotate); everything that starts or stops eases.

## Arcs

Natural motion between two points on different axes follows a curved path, never a straight diagonal (Disney's "arcs"; Material's movement spec). In SVG/CSS, produce an arc without a path library by splitting the movement into two transforms with *different* easings — e.g. translateX on a near-linear curve and translateY on a strongly eased one, on nested groups. `offset-path` is the explicit alternative when the trajectory matters precisely.

## Coprime periods

When layering loops (body bounce + blink + background drift), give them durations whose ratio is not a small integer — 2.4s and 3.2s, or better 2.4s and 3.7s. The composite takes a long time to realign, so the loop never visibly repeats. Identical or integer-ratio periods are what make an idle animation read as a machine cycle.

## Reduced motion is part of the deliverable

Ship every animated SVG with a `@media (prefers-reduced-motion: reduce)` block (WCAG 2.3.3). The craft version is not a blanket `animation: none`: replace *movement* (translation, scaling, rotation) with opacity-level calm, and keep what is informative. For a decorative character loop, stopping entirely is correct; for a spinner, a slow opacity pulse still communicates "working".
