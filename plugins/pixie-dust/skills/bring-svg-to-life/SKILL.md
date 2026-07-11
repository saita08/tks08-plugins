---
name: bring-svg-to-life
description: This skill should be used whenever Claude is about to generate or edit SVG or CSS animation of any kind — characters, mascots, illustrations, icons, loading indicators, spinners, empty states, decorative blobs, logo reveals, staggered UI entrances — read it BEFORE writing the first path or keyframe. Triggers on "SVGでキャラクター", "マスコットを描いて", "SVGアニメーション", "ローディングアニメーション", "アイコンを動かして", "スピナー", "キャラを動かして", "draw a character in SVG", "make a mascot", "animate this SVG", "loading spinner", "empty state illustration", or any request whose output is a figure or a motion rendered in SVG/CSS. Provides the principles that separate lifelike, crafted output from the flat machine-made default — asymmetric organic shapes, layered tinted shadows, anticipation, squash and stretch, follow-through, arcs, designed easing — and the boundary where SVG should be handed over to Rive or WebGL.
user-invocable: false
allowed-tools: Read
---

# Bring SVG to Life

A generative model, left to its defaults, regresses to the mode of its training distribution: perfect circles, mirror symmetry, flat gray shadows, `linear` easing, whole groups translated as one rigid block. Each of those choices is the mathematically cheapest one, and their sum is the flat, lifeless output users describe as "のぺっとしている". The crafted feel lives in deliberate deviation from that center. This is the SVG-domain instance of a general principle — what ships should feel authored rather than generated — and this skill turns it into observable rules to apply before drawing anything.

The rules are not invented here. The motion principles are the subset of Disney's twelve principles of animation (Thomas & Johnston, *The Illusion of Life*) that practitioners have found translate strongest to CSS/SVG, and the timing and shadow rules follow the consensus of the major motion design systems. Apply them to characters and to non-character work alike — spinners, icons, empty states, blobs; the machine-made default is the same everywhere.

Three factors produce the lifeless default. Motion is the largest of them, but the shape and shadow rules apply to static images too.

## Factor 1 — Shape: life lives in asymmetry

Never build a character's body from `<circle>`, `<ellipse>`, or `<rect>` primitives. Draw the body as an organic blob: a `<path>` of cubic Bézier segments (`C` commands) whose control points are deliberately uneven, so no two quadrants of the outline mirror each other. A quick test: if the path would survive `scale(-1,1)` unchanged, it is still symmetric — nudge it.

Apply the same rule at the feature level. Place eyes, mouth, and attached parts a few pixels off mirror symmetry — one eye 2–3px higher, ears of different lengths and angles. These offsets are below conscious notice but above the threshold where the brain reads "template". The same construction governs decorative blobs: points displaced from a circle by *different* amounts, joined by Béziers — uniform displacement reads machine-made.

## Factor 2 — Shading and shadow: reject the flat fill and the gray ellipse

The default fill is a single flat color; the default shadow is one flat gray ellipse. Both are tells.

For volume, use `radialGradient` with the highlight offset toward the light source — never centered — and `feTurbulence` where a material surface is implied. When the deliverable is animation-first and the figure is small or fast-moving, flat fills are acceptable; do not spend complexity where motion will dominate perception.

Shadows have structure and color. Build a ground shadow from two stacked shapes: a small, darker, sharper **contact core** at the contact point, inside a wider, gradient-faded **soft spread** (a radial gradient to transparent — cheaper and safer to animate than blur filters). Never tint a shadow pure black or neutral gray: use the ground or palette hue with saturation and lightness dropped. Decide one light source before drawing and keep every cue in agreement — highlight toward the light, shadow away from it. A highlight upper-left over a shadow dead-center is the "fake" tell viewers feel but cannot name. Full construction in `references/shadow-and-light.md`.

## Factor 3 — Motion: the seven principles

This is the dominant factor. The lifeless default is a group translated linearly from A to B. Every animated character must satisfy the following; treat them as requirements, not garnish.

1. **Anticipation** — before any major action, move briefly against it: sink before rising, lean back before darting, contract before expanding. A motion that starts at full velocity from rest reads as mechanical.
2. **Squash and stretch** — during the action, deform the body along the axis of motion: stretch while accelerating, squash into the anticipation and at impact, preserving apparent volume (one axis grows as the other shrinks). Run this as a `scale` animation synchronized to the same duration and timeline as the displacement, with `transform-origin` at the contact or attachment point, never the center — center-origin deformation floats.
3. **Follow-through** — loose parts (ears, hair, tails, pendants, trailing edges) lag one beat behind the body and keep swinging with decaying amplitude after the body stops. Wrap each such part in its own `<g>` and give it keyframes phase-shifted from the body's, settling later than the body settles.
4. **Overshoot** — arrive past the target and settle back. Use easing of the `cubic-bezier(.2, 1.4, .4, 1)` family (a y-value above 1 produces the overshoot) on any motion that snaps into a pose. In UI micro-interactions keep it subtle — the user meets it many times a day.
5. **Arcs** — motion across two axes follows a curved path, never a straight diagonal. Split the movement into two transforms with different easings on nested groups, or use `offset-path` when the trajectory matters precisely.
6. **Environmental coupling** — the world reacts to the figure, on the figure's own timeline: the ground shadow shrinks and fades as separation grows and swells back at contact, a surface responds to a touch. This coupling is the primary source of perceived contact; a figure animated over a static shadow hovers.
7. **Biological noise** — layer an idle sign of life (blinking, breathing) with a period *different from* the main animation's — coprime durations like 2.4s against 3.7s — so the two never align twice the same way. Identical periods read as a machine loop.

**Easing is designed, not picked.** Never use the keywords `ease`, `ease-in`, `ease-out`, or `linear` on character motion. Write `cubic-bezier()` values chosen for the physical event: heavy settle, springy overshoot, snappy anticipation. The one legitimate `linear` is continuous rotation. Starting points from the design systems' vocabularies are in `references/timing-and-easing.md`, along with the duration bands (100–200ms for small elements, 250–400ms for large surfaces, 1.5–3s for character loops).

## Not only characters

Spinners, icons, staggered entrances, blob backgrounds, and logo reveals regress to the same defaults and answer to the same principles: a spinner needs a second motion layered on the rotation (dash-length breathing), a group entrance needs stagger (first item at zero delay, ~20–100ms per item after), a reveal needs follow-through (fill fades in as the stroke completes). Techniques in `references/beyond-characters.md`.

## Pre-delivery checklist

Before presenting any SVG figure or animation, verify against the output itself:

- [ ] Body/blob outline is a Bézier path, not an ellipse/circle/rect; outline and features are asymmetric
- [ ] Fills have off-center gradients where static quality matters; one light source, all cues agreeing
- [ ] Shadow is layered (contact core + gradient-faded spread) and tinted, not flat gray
- [ ] Every major action has anticipation, and its launches and impacts deform the body with `transform-origin` at the contact point
- [ ] Secondary parts live in their own groups with phase-shifted, late-settling keyframes
- [ ] Two-axis movement arcs; all character easing is explicit `cubic-bezier()`
- [ ] Shadow tracks the motion on the same timeline
- [ ] An idle life-sign runs on a period coprime with the main loop
- [ ] A `prefers-reduced-motion` block ships with the file

## The ceiling: when to leave SVG

SVG has no bones and no mesh deformation, so smoothly warping the interior of a filled shape — a cheek compressing, a torso rippling with breath, hair swinging strand by strand — can only be faked with per-part transforms, and that fake has a visible ceiling. When that level of deformation is the core of the product, do not grind against the format: propose the branch explicitly to the user — Rive (mesh deformation plus state machines; OSS runtimes with no runtime fee, publishing from ~$9/month) or WebGL — instead of burning iterations on what SVG cannot express. Naming the ceiling is part of the craft, not a failure.

## Additional resources

- **`references/motion-recipes.md`** — the motion patterns as proportions of the event (anticipation fraction, lag phase, decay counts), the layering structure, and one verified keyframe instance to derive from; read before writing keyframes
- **`references/shadow-and-light.md`** — the two-layer shadow construction, shadow color rules, light-source consistency, and shadow behavior during motion
- **`references/timing-and-easing.md`** — duration bands, the design systems' easing vocabulary, arcs, coprime periods, reduced-motion
- **`references/beyond-characters.md`** — spinners, stagger choreography, organic blobs, line-drawing reveals, micro-interactions
- **`references/beyond-svg.md`** — the SVG ceiling in detail, the Rive/WebGL branch, and the wider animation-technology selection doctrine (CSS standards, Canvas, Three.js, GSAP licensing)
