# Beyond Characters

The machine-made default is not a character problem. Spinners, icons, empty-state illustrations, background blobs, and logo reveals regress to the same distribution mode — constant speed, perfect symmetry, zero choreography. The same parent principle applies; these are the non-character techniques.

## Spinners: never a constant-speed arc

The generic spinner is a fixed arc rotating at constant speed — the one legitimate use of `linear` is continuous rotation, and it is also why generic spinners feel dead: rotation is their *only* motion. The crafted spinner layers a second motion on top: animate `stroke-dasharray`/`stroke-dashoffset` with ease-in-out inside the loop so the arc's head and tail move at different phases — the arc grows and shrinks each cycle while the whole rotates (the Material spinner construction, ~1.4s loop). Use `pathLength="100"` to make dash math readable, and `stroke-linecap="round"` on arc ends — a small, consistent craft marker.

## Stagger: choreography, not simultaneity

When several elements enter (list items, icon parts, illustration pieces), never animate them as one block and never give them identical delays:

- First item starts at zero delay — a delayed first item reads as breakage
- Subsequent items offset by a fixed interval, ~20–100ms per item (`animation-delay: calc(var(--i) * 50ms)`)
- Total choreography still fits the normal duration budget; shrink the per-item delay as the count grows
- Too little stagger reads as a glued block; too much disintegrates the group into unrelated parts

## Organic blobs: irregularity is the construction, not a flaw

Decorative blob shapes are built by placing anchor points around a circle, displacing each radially by a *different* amount, and joining with cubic Béziers whose handles stay tangent to the circle. Uniform displacement or mirror-symmetric points reads machine-made — the irregularity is what signals "drawn by a hand". To animate, morph the `d` attribute among 3–4 variants of the same blob (identical command count and types — a hard requirement for `d` interpolation) with ease-in-out for a breathing effect, or apply `feTurbulence` + `feDisplacementMap` for continuous organic distortion.

## Line drawing and reveals

For logos, icons, and empty-state illustrations, the stroke-draw reveal: set `pathLength="1"` on the path, `stroke-dasharray: 1; stroke-dashoffset: 1;`, and animate offset to 0 — no JavaScript path-length measurement needed. Pair with a fill fade-in that starts as the stroke completes (follow-through applied to a reveal).

## Micro-interactions

The "alive" signal in UI motion is small temporal offsets between related properties: child elements settle a fraction after their parent, the shadow fades a beat after the panel, the icon overshoots slightly into its final pose. One element animating all its properties on one clock is the block-translation of the UI world. Apply anticipation and squash & stretch at low amplitude — overshoot in UI stays subtle (~5–20%, e.g. `cubic-bezier(.34,1.56,.64,1)`) because the user meets it many times a day.
