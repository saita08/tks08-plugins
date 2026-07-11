# Shadow and Light

The single flat gray ellipse under a character is the shadow equivalent of the perfect circle: the cheapest shape in the distribution, and the loudest "machine-made" tell. Real shadows have structure, color, and a light source they agree with. All three are cheap to express in SVG.

## Structure: a shadow has zones, never one shape

A real cast shadow is darkest and sharpest at the contact point (occlusion shadow — where even bounced ambient light cannot reach) and grows softer and lighter with distance from the occluder. One uniform ellipse cannot express this. Minimum construction, two stacked shapes:

- **Contact core** — small, darker, relatively sharp ellipse directly under the feet/base
- **Soft spread** — a wider ellipse around it at much lower opacity, filled with a radial gradient fading to fully transparent at the edge

```xml
<radialGradient id="shadowFade" cx="50%" cy="50%" r="50%">
  <stop offset="0%"  stop-color="#5a4038" stop-opacity=".38"/>
  <stop offset="55%" stop-color="#5a4038" stop-opacity=".22"/>
  <stop offset="100%" stop-color="#5a4038" stop-opacity="0"/>
</radialGradient>
<ellipse class="shadow-soft" cx="128" cy="210" rx="52" ry="10" fill="url(#shadowFade)"/>
<ellipse class="shadow-core" cx="126" cy="210" rx="24" ry="5"  fill="#4a332c" opacity=".30"/>
```

The gradient-filled ellipse is the right default in SVG: `feGaussianBlur`/`feDropShadow` give truer blur but recomputing a filter every animation frame is expensive, while a gradient fill is GPU-friendly and safe to animate. Reach for filters only on static images where the region is small.

## Color: never pure black or neutral gray

Neutral gray reads dead because real shadows are filled by bounced and sky light. Two equivalent working rules:

- Painter's rule: the shadow leans toward the complement of the light — warm light, relatively cool shadow; cool light, relatively warm shadow
- Web rule (Josh Comeau): take the surface/background hue, drop saturation and lightness — on `hsl(220 100% 80%)` ground, shadow around `hsl(220 60% 50%)` at low alpha, never `hsl(0 0% 0%)`

When the ground is undefined (transparent background), tint the shadow with a desaturated, darkened version of the character's own palette so the two read as one scene.

## The light source: one, and everything agrees with it

Decide where the light is before drawing, then keep every cue consistent:

- Gradient highlights sit toward the light (off-center — a centered highlight is another distribution-mode tell)
- Shadow offsets away from the light, opposite the highlight
- If anything casts a directional shadow, all offsets share the ratio (vertical offset ≈ 2× horizontal reads as natural overhead-ish light)

A highlight upper-left with a shadow centered exactly under the body is the primary "fake" tell reviewers cannot name but always feel.

## Shadow during motion

The ground shadow stays on the ground plane, outside the group that moves, and tracks separation inversely on the same timeline as the movement:

- separation grows → shadow scales down, opacity drops, contact core fades fastest (it exists only near contact)
- contact returns → both swell briefly past rest size with the impact, then settle

Animate `transform: scale()` and `opacity` on the gradient ellipses, not a filter's `stdDeviation`. The contact core should nearly vanish at the apex while the soft spread merely shrinks — losing the core is what makes the character read as airborne.

For UI elevation rather than characters, the same physics: as an element rises, offset and blur grow while opacity falls. Layered shadows (4–6 stacked, offset and blur doubling per layer, ~0.1 alpha each) approximate an eased falloff that a single shadow cannot.
