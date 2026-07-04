---
name: close-the-visual-loop
description: This skill should be used whenever work touches anything visual — a UI screen, a web page, a video render, a chart, a layout, a Chrome extension, a generated image — and Claude is about to conclude it works without having looked at it. Triggers on "does this look right", "check the UI", "見た目を確認", "スクリーンショットを撮って", "レイアウトが崩れてないか", "ちゃんと表示されてる", finishing a frontend change, rendering a video, or any moment where the honest state is "it should work" but no pixels have been seen. Provides the doctrine and procedure for capturing a visual surface, actually reading the screenshot, and judging it against intent instead of leaving the looking to the user's eyes.
allowed-tools: Read, Glob, Grep, Bash
---

# Close the Visual Loop

Most work on something visual ends at "I implemented it, it should render correctly." The looking — the part where someone confirms the pixels match the intent — is silently handed to the user's eyes. This is the gap this skill closes. Claude can read images natively; a screenshot is not a foreign artifact but something to open and judge directly. The doctrine is simple and it is the whole point: **do not conclude that a visual surface works until you have looked at it.**

"Looked at it" means captured a screenshot and read the actual image, not reasoned that the code should produce the right output. Code review predicts the render; it does not observe it. A `flex` that should center, a color that should have enough contrast, a container that should not overflow — every one of these is a claim about pixels, and a claim about pixels is verified by looking at the pixels.

## When this applies

Any time the finished work has a visual surface and the honest status is "it should look right" with nothing seen. Frontend changes, video renders, chart generation, a new screen in an app, a layout adjustment, a generated or edited image. The tell is the phrase "should work" attached to something that produces pixels. If you catch yourself about to write it, that is the signal to capture and look instead.

This does not apply to work with no visual surface to observe — pure logic, data transforms, backend endpoints without a rendered view. There is nothing to photograph, so there is nothing to close.

## How to close it

The two commands do the heavy lifting; this skill is the judgment about *when* to reach for them and *how* to look once you have.

1. If the project has no capture recipe yet (`.claude/tengan.local.md` is absent), run `/tengan:open` to detect its visual surfaces and write the recipe. This is a one-time survey per project.
2. Run `/tengan:look` to capture the relevant surface and state, read the screenshot, and judge it. For a surface not yet in the recipe, open the eye first.

When the situation is small enough that a full command is overkill — a single generated image, one PDF, one SVG — just read it directly with the Read tool and judge it. The doctrine is the same; only the ceremony shrinks.

## Reading before judging

The two references carry the parts that do not fit in the head:

- `references/capture-recipes.md` — how to detect each kind of visual surface and the exact command to capture it, across all targets: iOS simulator, headless web, Remotion, plain video files, Chrome extensions, deployed URLs, and static images. Read when capturing, or when writing the recipe during `/tengan:open`.
- `references/visual-judgment.md` — how to read a screenshot for real breakage: layout collapse, overflow, contrast, hierarchy, state coverage, viewport comparison, and matching against design intent. How to write an observation as an observable fact rather than "looks nice". Read when judging a captured image.

## What the judgment is and is not

The looking catches obvious breakage — the overflow, the invisible text, the empty state that was never handled — before it reaches a human's eyes. It is a net, not a designer. When the difference is a matter of taste or a design decision, the loop's job is to surface the screenshot and the observation and hand the choice back to the user, not to guess at what they wanted. Closing the loop means the model looks first; it does not mean the model owns the aesthetic.
