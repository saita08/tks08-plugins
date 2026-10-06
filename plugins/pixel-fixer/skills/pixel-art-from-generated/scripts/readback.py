"""Read generated sprite sheets back as pixel art, as one JSON spec describes them.

    python3 readback.py <spec.json> <the folder that holds the originals> <out folder> [report.html]

The spec names the palette every sprite shares and, for each sheet, how to cut it,
the frame's size in game dots, the height the generator was asked for, and how to
clean it:

    {
      "density": 1,
      "palette": {"k": ["060305", "1d1009"], "n": ["19203d", "3c4d80", "6a7fb6"]},
      "dark": ["k0", "k1"],
      "keep": ["k0"],
      "sheets": [
        {"name": "hero-run", "file": "hero-run.png", "cut": ["grid", 6],
         "cell": [16, 20], "ordered": 20, "clean": "figure"}
      ]
    }

density is how many dots of the image make one pixel of the game's screen. dark is
the outline colours, keep the colours meant to stand alone (eyes, highlights).
cut is ["grid", n] for n equal cells across the sheet, ["parts", gap, [i, ...]] for
the separate things on it, left to right, or ["fill"] for one thing read to fill the
cell. clean is "" for plain cleaning, "figure" to also thin a doubled outline, and
"body" to also drop what is drawn apart from the body.

Each sprite is written as <name>.png, its frames left to right on a shared bottom
edge with one clear column between them. With a fourth argument a page sets every
frame beside its original with the difference measured. Needs Pillow and numpy."""
import html
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pixelart import Palette, sheet_frames, strays, specks, thin_outline, largest, merge_rare, score, png_uri


def draw(pal, sheet, folder, density, dark, keep):
    cw, ch = sheet["cell"]
    raw, refs, info = sheet_frames(folder / sheet["file"], tuple(sheet["cut"]), (cw * density, ch * density),
                                   sheet.get("ordered"))
    out = [pal.snap(f, pal.names) for f in raw]
    out = merge_rare(out, pal, keep=dark | keep)
    out = [specks(strays(g, keep=dark | keep), keep=dark | keep) for g in out]
    if sheet.get("clean") in ("figure", "body"):
        out = [thin_outline(g, dark) for g in out]
    if sheet.get("clean") == "body":
        out = [largest(g) for g in out]
    return out, refs, info


def strip(pal, frames):
    """the frames left to right on one bottom edge, one clear column between them"""
    H = max(f.shape[0] for f in frames)
    W = sum(f.shape[1] for f in frames) + len(frames) - 1
    out = np.zeros((H, W, 4), np.uint8)
    x = 0
    for f in frames:
        out[H - f.shape[0]:, x:x + f.shape[1]] = pal.image(f)
        x += f.shape[1] + 1
    return out


def write_report(path, rows):
    zoom = lambda g: 6 if g.shape[0] < 60 else 3 if g.shape[0] < 130 else 2
    body = []
    for name, info, frames in rows:
        ov = np.mean([s["overlap"] for _, _, s, _ in frames]); de = np.mean([s["colour"] for _, _, s, _ in frames])
        how = "one dot of the original to one dot" if info["mode"] == "native" else \
            "read at %.1f px to fit the cell (original dot %.1f px)" % (info["step"][1], info["pitch"])
        cells = "".join('<figure><img src="%s"><img src="%s"><img src="%s"><figcaption>%.0f%% / %.1f</figcaption></figure>'
                        % (png_uri(r, zoom(r)), png_uri(d, zoom(r)), png_uri(p, zoom(r)), s["overlap"] * 100, s["colour"])
                        for r, d, s, p in frames)
        body.append('<section><h2>%s <small>%.0f%% / %.1f &middot; %s</small></h2><div class="row">%s</div></section>'
                    % (html.escape(name), ov * 100, de, how, cells))
    Path(path).write_text("""<!doctype html><meta charset="utf-8"><title>Sprite check</title>
<style>body{font:14px system-ui;background:#1b1611;color:#eee;margin:16px}h2{font-size:15px;margin:18px 0 6px}
small{color:#aaa;font-weight:normal}.row{display:flex;flex-wrap:wrap;gap:12px}figure{margin:0;display:flex;gap:4px;align-items:flex-end;flex-wrap:wrap}
figcaption{width:100%%;color:#ccc;font-size:12px}img{image-rendering:pixelated;background:#3a2f26}</style>
<p>Each frame: the original averaged into the same dots, the drawing, and the difference (grey agrees; orange to red, colour differs;
red, only the original; cyan, only the drawing). Numbers: shared outline, then mean colour difference (Lab).</p>%s""" % "".join(body))


def main():
    spec = json.loads(Path(sys.argv[1]).read_text())
    folder, out = Path(sys.argv[2]), Path(sys.argv[3])
    report = sys.argv[4] if len(sys.argv) > 4 else None
    out.mkdir(parents=True, exist_ok=True)
    pal = Palette(spec["palette"])
    dark = {pal.index(n) for n in spec.get("dark", [])}
    keep = {pal.index(n) for n in spec.get("keep", [])}
    density = spec.get("density", 1)
    rows = []
    for sheet in spec["sheets"]:
        frames, refs, info = draw(pal, sheet, folder, density, dark, keep)
        Image.fromarray(strip(pal, frames), "RGBA").save(out / (sheet["name"] + ".png"))
        if report:
            rows.append((sheet["name"], info, [(r, pal.image(d)) + score(r, pal.image(d)) for r, d in zip(refs, frames)]))
        print("%-16s %-6s dot %5.2f px  %d frames" % (sheet["name"], info["mode"], info["pitch"], len(frames)))
    if report:
        write_report(report, rows)


main()
