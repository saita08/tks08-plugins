---
description: Look — capture a visual surface per the recipe, actually read the screenshot, judge it against intent, and loop capture-fix-recapture until it matches or a decision must go back to the user.
argument-hint: "[面/状態（省略時はレシピの全面）]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Tengan Look

Capture a visual surface, look at it, and judge it. This is the command that closes the loop: it does not stop at "the screenshot was taken", it reads the image and reports what the image shows against what the work intended. Screenshots that no one looks at are the exact failure this plugin exists to end.

Read `.claude/tengan.local.md` for the capture recipe. If it does not exist, tell the user to run `/tengan:open` first and stop — there is no recipe to follow. Read `${CLAUDE_PLUGIN_ROOT}/skills/close-the-visual-loop/references/visual-judgment.md` before judging; it carries how to read a screenshot for real breakage rather than gut feeling.

## Step 1 — Select what to capture

If the argument names a surface or state, capture that. If it is empty, capture every surface in the recipe, in each of its recorded states. Capturing one happy state and calling the surface verified is the habit this plugin replaces.

## Step 2 — Capture

Run the recipe's capture command for each selected surface and state. Write the images to a place you can read back, and name them so the surface and state are unambiguous. If a capture command fails because its tool is missing, do not silently skip it — report which surface could not be captured and why, and point at the install suggestion the recipe already recorded.

## Step 3 — Look

Read each captured image with the Read tool. This is not optional and not something to infer from the command succeeding — the point of the whole plugin is that the model looks at the pixels. Judge each image with `references/visual-judgment.md`: layout breakage, overflow and clipping, contrast, visual hierarchy, whether each intended state is actually shown, and how it compares across viewports. Write observations as observable facts a reader could confirm by opening the same image, not as "looks clean".

## Step 4 — Loop or return

Compare what the image shows against the intent of the work.

- If it matches the intent, report that with the specific observations that make it match, and stop. The loop closed successfully.
- If there is a fixable breakage whose correct fix is unambiguous, fix it, recapture the affected surface and state, and look again. Repeat until it matches or until the next step would need the user.
- If the difference is a matter of taste, a design decision, or anything where you would be guessing at what the user wants, stop and return it to the user with the screenshot and the specific observation. This judgment is a net that catches obvious breakage before a human's eyes do; it is not a replacement for the person who owns the design.

Do not commit. Report the final state of each surface: matched, fixed-and-rematched, or returned-to-user with the open question.
