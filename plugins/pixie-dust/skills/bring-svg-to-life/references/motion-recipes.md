# Motion Recipes

The patterns below are stated as proportions of the animated event, because that is the transferable part. The concrete keyframe block at the end is one verified instance — a 2.4s hop, proven by same-shape comparison — included as an illustration of the ratios, never as a template. Deriving fresh numbers from the ratios for the motion actually being built (a dash, an entrance, a wave, a stir) is the job; transplanting the hop's numbers into a non-hop is exactly the anchoring this skill exists to break.

## Layering structure

Give each motion principle its own group to act on, whatever the figure is:

```
<g class="travel">            <!-- displacement of the whole figure along its path -->
  <g class="deform">          <!-- scale deformation; transform-origin at the contact/attachment point -->
    <path class="body" .../>
    <g class="lag-part">...</g>   <!-- each loose part (ear, tail, hair, pendant) in its own group -->
    <g class="idle-noise">...</g> <!-- blink/breath, on its own period -->
  </g>
</g>
<ellipse class="shadow" .../>  <!-- outside the travel group: the ground does not move -->
```

In SVG, `transform-origin` in CSS needs `transform-box: fill-box` on the element (or explicit user-unit coordinates); without it the origin resolves against the viewport and the deformation drifts.

All keyframe sets expressing one physical event (travel, deformation, lag, environment) run at the **same duration** so their percentages describe the same moments. Idle noise runs on its own, coprime duration — that difference is the point.

## The patterns, as proportions

- **Anticipation** — a counter-move filling roughly the first 10–20% of the event, with amplitude a few percent of the main travel. Sink before rising, lean back before darting, contract before expanding.
- **Deformation** — squash into the anticipation and at impact (scale up ~10–20% across the travel axis, down ~15–25% along it, preserving apparent volume), stretch while accelerating (the inverse, milder). Origin at the contact or attachment point, never the center.
- **Lag** — loose parts start their swing ~10–15% of the event after the body, reach maximum deflection while the body is already decelerating, and settle through 2–3 swings of decaying amplitude *after* the body has stopped. Sibling parts get slightly different amplitudes or delays so they never mirror.
- **Environmental response** — whatever the figure touches or shades tracks the event on the same clock, inversely to separation: a shadow shrinks and fades as the figure leaves the ground, its sharp contact core nearly vanishing off-ground, and both swell briefly past rest size at impact.
- **Idle noise** — one small life-sign (blink, breath) whose duration is coprime with the main loop (2.4s against 3.7s), so the composite never visibly repeats.
- **Settle** — after the main event, a small overshoot (a few percent of travel) before rest; nothing stops dead on its final frame.

## Easing values that work

- Overshoot into a pose: `cubic-bezier(.2, 1.4, .4, 1)`
- Heavy, settling travel: `cubic-bezier(.36, 0, .24, 1)`
- Snappy anticipation release: `cubic-bezier(.6, -.28, .35, 1)` (negative y1 adds a wind-up dip)

A y-value outside [0,1] is what produces overshoot and wind-up, which no stock keyword can express.

## One verified instance: a 2.4s hop

Same-shape comparison confirmed the effect of these exact numbers. Read them as the ratios above made concrete — anticipation at 18%, impact at 62%, lag settling through 86% — and derive equivalents for the event at hand.

```css
@keyframes travel {            /* 予備動作 → 上昇 → 滞空 → 着地 → 戻り揺れ */
  0%        { transform: translateY(0); }
  18%       { transform: translateY(2px); }
  30%       { transform: translateY(-46px); }
  46%       { transform: translateY(-52px); }
  62%       { transform: translateY(0); }
  70%       { transform: translateY(3px); }
  80%       { transform: translateY(-6px); }
  88%, 100% { transform: translateY(0); }
}
@keyframes deform {            /* 同周期。origin は接地点 */
  0%        { transform: scale(1,1); }
  18%       { transform: scale(1.14,.82); }
  30%       { transform: scale(.9,1.14); }
  62%       { transform: scale(1.18,.78); }
  72%       { transform: scale(.95,1.06); }
  82%, 100% { transform: scale(1,1); }
}
@keyframes lagPart {           /* 静止後も減衰しながら揺れ戻す */
  0%, 14% { transform: rotate(0deg); }
  26%     { transform: rotate(16deg); }
  44%     { transform: rotate(-8deg); }
  60%     { transform: rotate(12deg); }
  74%     { transform: rotate(-14deg); }
  86%     { transform: rotate(5deg); }
  100%    { transform: rotate(0deg); }
}
@keyframes idleNoise {         /* 主ループと互いに素な周期で */
  0%, 88%, 100% { transform: scaleY(1); }
  92%, 96%      { transform: scaleY(.08); }
}
```
