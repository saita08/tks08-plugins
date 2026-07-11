# Beyond SVG — the ceiling and the technology doctrine

## Where the SVG ceiling actually is

SVG animates whole elements: translate, rotate, scale, opacity, and (expensively) path morphing. It has no skeleton and no mesh, so nothing inside a filled shape can bend while the outline stays coherent. The expressions this forecloses:

- a cheek or belly compressing locally while the rest of the body holds
- breathing that travels as a wave through the torso rather than scaling it
- hair or fur that swings strand by strand with per-strand physics
- lip-sync or facial acting beyond swapping/scaling discrete parts

Per-part transforms (the technique in `motion-recipes.md`) fake these convincingly up to the level of a mascot, a loading character, an empty-state illustration. That is the ceiling. Recognize it by symptom: when iteration keeps adding smaller and smaller `<g>` wrappers trying to approximate a continuous deformation, the format is exhausted, not the idea.

## The branch to propose

When interior deformation is core to the product — a character brand whose acting quality carries the experience — stop iterating in SVG and propose the branch explicitly:

- **Rive** — mesh deformation, bones, and state machines driven by runtime inputs. Runtimes are open source with no runtime fee; publishing requires a paid editor plan (Cadet, ~$9/month as of 2026). The natural next step above SVG for interactive characters.
- **WebGL** (or Canvas with a deformation library) — full control, highest cost; justified when Rive's editor-centric pipeline does not fit.

Present this as a decision for the user with the cost on each side. Grinding against the ceiling in code wastes iterations; silently switching stacks violates scope.

## Animation technology selection doctrine

Chosen to minimize total cost — tokens spent generating plus debugging round-trips — for code-only generation with no asset pipeline:

- **UI animation: CSS standards.** Transitions, keyframes, View Transitions API, Scroll-driven Animations. As of 2026, View Transitions and Scroll-driven Animations are stable in Chromium and WebKit but behind a flag in stable Firefox — ship them as progressive enhancement behind `@supports`, with a functional non-animated fallback.
- **Games and simulations: Canvas + `requestAnimationFrame`,** hand-rolled. A game loop is a few dozen lines; an engine dependency costs more to integrate and debug than it saves at this scale.
- **3D only: Three.js** (MIT). Do not hand-roll WebGL for routine 3D.
- **GSAP: usable but not the default.** Since the 2025 Webflow acquisition it is free for commercial use (including the former Club plugins), but the license is proprietary and prohibits use in no-code animation builders competing with Webflow. Prefer CSS standards; reach for GSAP when a timeline's orchestration genuinely exceeds them.
- **Lottie / Rive as asset pipelines: the exception, not the rule.** They assume a designer-tool workflow and clash with a code-generation loop. Choose them only when character expressiveness beyond the SVG ceiling is the product's core — the branch described above.
