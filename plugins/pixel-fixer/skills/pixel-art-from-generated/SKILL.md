---
name: pixel-art-from-generated
description: This skill should be used when turning art made by an image generator (ChatGPT, Midjourney and the like) into pixel art a game can animate — when the user mentions "ドットに打ち直して", "GPT の絵をスプライトにして", "絵がにじむ", "コマごとに絵がブレる", "元絵と比べて", "make this a sprite", "the pixel art is blurry", "the dots are uneven", "convert to a palette", or hands over a sheet of generated "pixel art" to use in a game. Reads the original's dots back one by one, puts them on a fixed palette, removes stray dots and doubled outlines, and checks the result against the original by overlap and colour difference.
allowed-tools: Read, Write, Bash(python3:*)
---

# Read Generated Art Back as Pixel Art

Generated "pixel art" only looks like pixel art. Each of its dots is a soft block several pixels wide, and the size and colour of the blocks differ from drawing to drawing. Shrinking it blurs it; redrawing it by hand drifts away from it. Treat the original as the model, and read its blocks back one by one into real dots.

The value at the core: the original decides the shape, the game decides the grid and the colours, and the result is judged against the original by numbers and by eye, never by belief.

The tools are in `scripts/`: `pixelart.py` holds the steps, `readback.py` runs them over a whole set of sheets from one JSON spec. Both need Python 3 with Pillow and numpy.

## Decide before ordering

1. **One dot size.** Decide how many reference pixels of the game's screen one dot of art takes, and use that one size for every drawing. Dots of different sizes side by side are the most visible flaw pixel art can have.
2. **Frames.** Decide each drawing's size in that dot: for example 32×40 for a character.
3. **One palette.** Decide the colours every drawing shares, in ramps ordered darkest first. A dozen ramps of four or five colours is a reasonable start.
4. **The order.** Ask the generator for the size, the frame count and the colours, on a magenta (#FF00FF) ground. Purple and pink are keyed out with the magenta, so keep them out of the drawing. Keep the size and frame count you asked for: the tool uses the asked height to bound its search for the generator's grid.

## Read back

Write a spec with the palette and one entry per sheet: its name, file, how to cut it, its frame size in game dots, the height asked for, and how to clean it. The format is at the top of `readback.py`.

```
python3 scripts/readback.py spec.json <originals folder> <out folder> report.html
```

For each sheet it does the following.

1. Keys out the magenta, cuts the frames, and finds the generator's grid as the period at which colour edges repeat, searched near the asked height (generators draw up to about three times finer than asked, never coarser).
2. When one block fits the frame and fills at least 75% of its height, one block becomes one game dot (`native`). Otherwise the drawing is read at the step that fits the frame (`fit`). Each dot takes the most common colour in the middle of its block, never the average.
3. Puts every dot on the palette, measuring colour difference in Lab, which follows how different colours look.
4. Cleans:
   - `merge_rare`: a colour used by few dots with a commoner colour near it becomes that colour
   - `strays`: a dot with no neighbour of its own colour takes its neighbours' colour, and a dot touching nothing is removed
   - `specks`: one or two grains inside a flat area take the area's colour; a line one dot wide stays
   - `thin_outline` (`"clean": "figure"`): a doubled outline becomes one dot thick
   - `largest` (`"clean": "body"`): things drawn apart from the body are dropped
   - colours listed in `keep` (eyes, highlights) are meant to stand alone and are protected
5. A recoloured costume is made inside the palette by swapping ramp for ramp (`Palette.remap`), never with a colour from outside it.

When a project needs its own packing (a sprite atlas, a map for the game's code), write a driver of its own that imports `pixelart.py`, with `readback.py` as the model.

## Check

The report page sets every frame beside its original: the original averaged into the same cells, the drawing, and the difference.

| Number | Meaning | Rough target |
|---|---|---|
| Overlap | shared silhouette over combined silhouette | 95% or more. Lower means the tool dropped something, or the cut is wrong |
| Colour | mean Lab difference where both have ink | about 10 for figures and objects, about 6 for walls and doors. Never 0: the averaged original blurs every edge |

In the difference picture, grey agrees, orange to red is a colour difference, red is in the original only, cyan is in the drawing only. Look after reading the numbers. Three things barely show in them:

- **Grain**: dots of another colour scattered in a flat area. Two near colours sit side by side in the palette, or the original is rough. Check `merge_rare` and `specks`.
- **Uneven coarseness**: when the original's blocks are coarser than the frame (the page says "read at … to fit" with a step smaller than the original dot), each block becomes one or two game dots. Order the drawing again at the right size, or touch it up by hand.
- **Colours the palette lacks**: when many drawings differ strongly in colour, `pixelart.extend` works out the missing colours from all of them; add them to the palette as ramps and note why beside it.

Finally, run the game and look at the art on the real screen, in the scenes where it appears.

## Ordering again

Services made for pixel art (PixelLab, Retro Diffusion) draw to a set size and palette, but they cost money and do not promise that frames match each other. Use one only when a new motion is needed that no original has, and ask the owner first with the expected cost.
