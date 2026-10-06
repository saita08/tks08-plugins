---
name: reference-screen
description: This skill should be used when laying the screen foundation of a new browser-based game, when fixing how a game's screen looks on different devices or window sizes, or when checking a game's screen against device sizes before merging — when the user mentions "画面の土台", "端末ごとに見え方が違う", "iPhone で崩れる", "ノッチ", "safe area", "縦持ちのゲームの画面", "レターボックス", "fixed aspect ratio", "scale the whole screen", "reference resolution", or builds an HTML game that will run in phone browsers and app web views. Lays the screen out at one reference size and scales the whole of it to the frame, and measures that every frame shows the same picture.
allowed-tools: Read, Write, Edit, Bash(node:*), Bash(cp:*)
---

# Lay the Screen Out at One Reference Size

A game's screen is a picture, not a document. A document reflows to the window; a picture keeps its composition and is scaled into whatever frame it hangs in. This skill lays a browser game's screen out at one reference size and scales the whole of it, the way a game engine scales its canvas, so every phone, tablet, browser tab and app web view shows the same picture at its own scale and nothing inside is sized or placed by the frame.

The value at the core: a layout decision is made once, at the reference, and checked once. Every rule below is that value applied to one source of variation — the frame's size, the device's insets, the moment the insets arrive, the length of the text.

## The rules

- One reference size, and only one. It is the safe part of the frame: the width and height inside the notch, the home bar and any host's header. Start at 390×760 for a portrait phone game and 1280×720 for a game played in a desktop window.
- Everything on screen lives inside `.stage` and is sized in reference px. Do not use `vw`, `vh`, size conditions in `@media`, or sizes measured from `innerWidth`. When something does not fit, remove parts or rearrange them; never switch the arrangement by the frame's size.
- The covered margins (notch, home bar) are added round the stage at the same scale as `--safe-t` and `--safe-b`. Only the background runs into them. Nothing pressable and no text sits there.
- Text never leaves the box it sits in. A long value is made to fit its box, or the box is made to reach the room the value may use.

## Lay the foundation

1. Choose the reference size (above).
2. Copy the three files in `template/` into the game's directory. Keep the load order in `index.html`: the stylesheet, then `fit.js`, both in the head, so the first paint is already at the reference size.
3. Set `W` and `H` at the top of `fit.js` to the reference, and `FOOT` to the least room kept at the bottom where the page is not told the inset: 20 for a game played on phones, 0 for one that only runs in a desktop window. Set `--ground` in `stage.css` to the game's ground colour.
4. Build the screen inside `.stage` in reference px.
   - A game drawn on a canvas makes the canvas at the reference size and puts it in `.stage`. A pointer position comes from `getBoundingClientRect()` and is divided by the scale `--s` to return to reference coordinates.
5. Check (next section).

`fit.js` measures the insets again whenever they change. An app's web view learns its insets only after it is on screen, after the first measure and with no resize event to announce them; a foundation that measures once shows a strip of the wrong colour, or a home bar over the buttons, only inside the app.

## Check

```
node check.cjs <game dir> [--ref 390x760] [--desktop] [--eval "<js>"] [--out <dir>]
```

`check.cjs` sits beside this file. It opens the game at the sizes and insets of real phones (the insets handed over after the first paint with no resize, as an app's web view does), at browser frames made low by their bars, and at a desktop window (`--desktop` swaps in common desktop windows and one phone). It returns every element to reference coordinates and compares it with the screen opened at the reference size itself. Any element that moves by more than 1 px is reported as `MOVED` with its path, and the script exits 1. What runs out under the covered margins (the stage, a background) grows with them by design and is not compared.

On the reference frame it also reports text that leaves its box sideways as `OVER`, and exits 1. The boxes checked run from the text's own box outward to the first one that paints a ground or a border, or clips. To check a long value, put it on screen with `--eval` first.

`--out` receives `sheet.png`: the reference frame at the left, then the safe part of each frame returned to the reference size. Element positions can match while a background image slips or a glyph is cut; that shows only in the picture, so open it and look.

A screen other than the first is reached with `--eval` (for example `--eval "document.getElementById('play').click()"`). The script needs Playwright with Chromium (`npm i -g playwright` and `npx playwright install chromium`).

Run the full set of frames once, together with the other checks made before merging. While building, looking at the real device size is enough.
