"""Read a drawing made by an image generator as pixel art at the game's own dot size.

Image generators draw "pixel art" as a large picture: each of their dots is a block
several pixels wide, the blocks are not quite even, and the edges are soft. This
module finds that grid of blocks, reads one colour per block (the most common
colour inside it, not the average), puts every colour onto the game's palette,
and cleans what reading leaves behind: lone dots and doubled outlines. It also
measures how closely the result follows the original, so a drawing can be judged
by numbers as well as by eye.

The procedure and the reasons for it are in the SKILL.md beside this folder; readback.py
runs it from one JSON spec.
Needs Pillow and numpy."""
import base64
import io

import numpy as np
from PIL import Image


# ---- the sheet -------------------------------------------------------------

def keyed(path):
    """the sheet as RGBA, its magenta background transparent. Purple drawn on purpose
    (above r, b 120 with little green) goes too: keep such colours out of the order"""
    a = np.asarray(Image.open(path).convert("RGB")).astype(int)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    back = (r > 170) & (b > 170) & (g < 110)
    # the soft edge where a figure meets the magenta: still reddish-blue with little green
    back |= (r > 120) & (b > 120) & (g < .6 * np.minimum(r, b))
    return np.dstack([a, np.where(back, 0, 255)]).astype(np.uint8)


def _runs(on, gap):
    runs, start, last = [], None, None
    for i, v in enumerate(on):
        if not v:
            continue
        if start is None:
            start = i
        elif i - last > gap:
            runs.append((start, last + 1))
            start = i
        last = i
    if start is not None:
        runs.append((start, last + 1))
    return runs


def frame_columns(a, how):
    """the column range of each frame on the sheet, and the rows they share

    how: ("grid", n)          n equal cells across the sheet
         ("parts", gap, [i])   the separate things, left to right, the listed ones
         ("fill",)             the one thing on the sheet"""
    m = a[..., 3] > 0
    if how[0] == "grid":
        W = m.shape[1]
        cols = []
        for i in range(how[1]):
            x0, x1 = i * W // how[1], (i + 1) * W // how[1]
            c = np.flatnonzero(m[:, x0:x1].any(0))
            cols.append((x0 + c[0], x0 + c[-1] + 1))
    elif how[0] == "parts":
        runs = [r for r in _runs(m.any(0), how[1]) if r[1] - r[0] > 4]
        cols = [runs[i] for i in how[2]]
    else:
        c = np.flatnonzero(m.any(0))
        cols = [(c[0], c[-1] + 1)]
    rows = np.flatnonzero(m[:, min(c[0] for c in cols):max(c[1] for c in cols)].any(1))
    if how[0] == "parts":
        # separate things are each cut to their own height and stood on one baseline
        return [(x0, x1) + tuple(_rows(m[:, x0:x1])) for x0, x1 in cols]
    return [(x0, x1, rows[0], rows[-1] + 1) for x0, x1 in cols]


def _rows(m):
    r = np.flatnonzero(m.any(1))
    return r[0], r[-1] + 1


# ---- the generator's grid --------------------------------------------------

def _edges(a):
    c = a[..., :3].astype(int)
    return np.abs(np.diff(c, axis=1)).sum(2).sum(0), np.abs(np.diff(c, axis=0)).sum(2).sum(1)


def _strength(p, s):
    p = p - p.mean()
    return np.sum(p * np.exp(-2j * np.pi * np.arange(len(p)) / s))


def pitch(a, lo=3.0, hi=24.0):
    """the width in pixels of one of the generator's dots: the period at which colour edges
    repeat, found on each axis and averaged. Big shapes repeat too, at longer periods, so
    keep lo..hi near what was asked for (see sheet_frames)"""
    ex, ey = _edges(a)
    S = np.arange(lo, hi, .05)
    sx = S[np.argmax([abs(_strength(ex, s)) for s in S])]
    sy = S[np.argmax([abs(_strength(ey, s)) for s in S])]
    return float((sx + sy) / 2)


def _phase(p, s):
    return (-np.angle(_strength(p, s)) / (2 * np.pi) * s) % s + .5   # edges sit between pixels


def read(sub, sx, sy, ox=0.0, oy=0.0, inner=.25):
    """one colour per cell of a grid with steps sx, sy starting at ox, oy: the most common
    colour in the middle of the cell, so soft edges and stray specks do not tint it"""
    H, W = sub.shape[:2]
    xs, ys = np.arange(ox, W + sx, sx), np.arange(oy, H + sy, sy)
    out = np.zeros((len(ys) - 1, len(xs) - 1, 4), np.uint8)
    for j in range(len(ys) - 1):
        for i in range(len(xs) - 1):
            x0 = int(max(0, round(xs[i] + sx * inner))); x1 = int(min(W, round(xs[i + 1] - sx * inner)))
            y0 = int(max(0, round(ys[j] + sy * inner))); y1 = int(min(H, round(ys[j + 1] - sy * inner)))
            if x1 <= x0:
                x1 = min(W, x0 + 1)
            if y1 <= y0:
                y1 = min(H, y0 + 1)
            cell = sub[y0:y1, x0:x1].reshape(-1, 4)
            if not len(cell) or (cell[:, 3] > 0).mean() < .5:
                continue
            cell = cell[cell[:, 3] > 0]
            _, inv, cnt = np.unique(cell[:, :3] // 12, axis=0, return_inverse=True, return_counts=True)
            out[j, i, :3] = cell[inv.ravel() == cnt.argmax()][:, :3].mean(0)
            out[j, i, 3] = 255
    return out


def _pair(sub, sx, sy, ox=0.0, oy=0.0):
    """the cells read from sub, and beside them (channels 4..7) the same cells averaged:
    the yardstick score() compares against"""
    g = read(sub, sx, sy, ox, oy)
    h, w = g.shape[:2]
    pad = int(max(sx, sy) * 2) + 2
    big = np.pad(sub, ((pad, pad), (pad, pad), (0, 0)))
    im = Image.fromarray(big, "RGBA").convert("RGBa")
    box = (ox + pad, oy + pad, ox + pad + w * sx, oy + pad + h * sy)
    r = np.asarray(im.resize((w, h), Image.BOX, box=box).convert("RGBA")).copy()
    r[..., 3] = np.where(r[..., 3] >= 128, 255, 0)
    return np.dstack([g, r])


def _trim(g):
    on = g[..., 3] > 0
    if not on.any():
        return g
    r, c = np.flatnonzero(on.any(1)), np.flatnonzero(on.any(0))
    return g[r[0]:r[-1] + 1, c[0]:c[-1] + 1]


def _trim_cols(g):
    c = np.flatnonzero(g[..., 3].any(0))
    return g[:, c[0]:c[-1] + 1] if len(c) else g


def sheet_frames(path, how, cell, ordered=None, fill_ratio=.75, step=None):
    """the frames of one sheet, read at the game's dot size

    cell is the frame's size in game dots. When the generator's own grid fits the cell
    and fills at least fill_ratio of its height, every one of its dots becomes one game
    dot ("native"). Otherwise the frames are made to fit the cell ("fit"): when the
    generator's grid is finer than the cell, several of its dots are read as one; when
    it is coarser, its dots are read and each then covers one or two game dots.
    ordered is the frame's height in the dots the generator was asked for: generators
    draw up to about three times finer than asked, never coarser, which bounds the search
    for their grid. Returns the frames, the original averaged into the same cells (the
    yardstick for score()), and what was decided."""
    a = keyed(path)
    boxes = frame_columns(a, how)
    if step:
        p = step
    elif ordered:
        asked = max(b[3] - b[2] for b in boxes) / ordered
        p = pitch(a, max(2.5, asked / 3.2), min(24, asked * 1.25))
    else:
        p = pitch(a)
    cw, ch = cell
    fw = max(x1 - x0 for x0, x1, _, _ in boxes)
    fh = max(y1 - y0 for _, _, y0, y1 in boxes)
    nw, nh = fw / p, fh / p
    if how[0] != "fill" and nw <= cw + .5 and nh <= ch + .5 and nh >= fill_ratio * ch:
        mode, sx, sy = "native", p, p
    elif how[0] == "fill":
        mode, sx, sy = "fit", fw / cw, fh / ch
    else:
        mode = "fit"
        sx = sy = max(fw / cw, fh / ch)
    pad = int(p)
    frames = []
    if mode == "native":
        top = min(b[2] for b in boxes); bot = max(b[3] for b in boxes)
        _, ey = _edges(a[top:bot])
        oy = _phase(ey, p) - p
        for x0, x1, y0, y1 in boxes:
            sub = a[top:bot, max(0, x0 - pad):x1 + pad]
            ex, _ = _edges(sub)
            frames.append(_pair(sub, p, p, _phase(ex, p) - p, oy))
    else:
        for x0, x1, y0, y1 in boxes:
            if min(sx, sy) < p * .95:
                # the cell is finer than the generator's grid: read its dots, then let each
                # cover one or two game dots, rather than reading the noise inside a dot
                big = a[max(0, y0 - pad):y1 + pad, max(0, x0 - pad):x1 + pad]
                ex, ey = _edges(big)
                g = _trim(_pair(big, p, p, _phase(ex, p) - p, _phase(ey, p) - p))
                w = max(1, round(g.shape[1] * p / sx)); h = max(1, round(g.shape[0] * p / sy))
                g = np.dstack([np.asarray(Image.fromarray(np.ascontiguousarray(g[..., i:i + 4]), "RGBA")
                                          .resize((w, h), Image.NEAREST)) for i in (0, 4)])
                frames.append(g)
            elif how[0] == "fill":
                frames.append(_pair(a[y0:y1, x0:x1], sx, sy))
            else:
                # centre the grid on the frame so the leftover is split on both sides
                ox = ((x1 - x0) - round((x1 - x0) / sx) * sx) / 2
                frames.append(_pair(a[y0:y1, x0:x1], sx, sy, ox, 0))
    if how[0] == "fill":
        # a fill tiles: exactly the cell, or a seam shows
        frames = [np.dstack([np.asarray(Image.fromarray(np.ascontiguousarray(f[..., i:i + 4]), "RGBA")
                                        .resize((cw, ch), Image.NEAREST)) for i in (0, 4)]) for f in frames]
    elif how[0] == "parts":
        frames = [_trim(f) for f in frames]
    elif how[0] != "fill":
        # one height for all frames so their feet line up
        hmax = max(f.shape[0] for f in frames)
        frames = [np.pad(f, ((hmax - f.shape[0], 0), (0, 0), (0, 0))) for f in frames]
        rows = np.flatnonzero(np.any([f[..., 3].any(1) for f in frames], 0))
        frames = [_trim_cols(f[rows[0]:rows[-1] + 1]) for f in frames]
    return ([np.ascontiguousarray(f[..., :4]) for f in frames], [np.ascontiguousarray(f[..., 4:]) for f in frames],
            dict(pitch=p, mode=mode, step=(sx, sy), native=(nw, nh)))


# ---- the palette -----------------------------------------------------------

class Palette:
    """named ramps of colours, darkest first: {"k": ["060305", ...], ...} gives k0, k1, ..."""

    def __init__(self, ramps):
        self.names, self.rgb = [], []
        for k, v in ramps.items():
            for i, h in enumerate(v):
                self.names.append(k + str(i))
                self.rgb.append(tuple(int(h[j:j + 2], 16) for j in (0, 2, 4)))
        self.lab = lab(np.array(self.rgb, float).reshape(1, -1, 3)).reshape(-1, 3)

    def index(self, name):
        return self.names.index(name)

    def snap(self, g, names):
        """each dot to the nearest of the listed colours, by how different they look (Lab)"""
        idx = np.array([self.index(n) for n in names])
        d = ((lab(g.astype(float))[..., None, :] - self.lab[idx][None, None]) ** 2).sum(-1)
        return np.where(g[..., 3] > 0, idx[d.argmin(-1)], -1)

    def image(self, ix):
        out = np.zeros(ix.shape + (4,), np.uint8)
        on = ix >= 0
        out[on, :3] = np.array(self.rgb, np.uint8)[ix[on]]
        out[on, 3] = 255
        return out

    def remap(self, ix, pairs):
        """swap colours by name, {"n2": "r2", ...}: a costume of another colour"""
        out = ix.copy()
        for a, b in pairs.items():
            out[ix == self.index(a)] = self.index(b)
        return out


def lab(a):
    f = a[..., :3] / 255.0
    f = np.where(f > .04045, ((f + .055) / 1.055) ** 2.4, f / 12.92)
    M = np.array([[.4124, .3576, .1805], [.2126, .7152, .0722], [.0193, .1192, .9505]])
    xyz = f @ M.T / np.array([.9505, 1, 1.089])
    F = np.where(xyz > .008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.dstack([116 * F[..., 1] - 16, 500 * (F[..., 0] - F[..., 1]), 200 * (F[..., 1] - F[..., 2])])


# ---- cleaning --------------------------------------------------------------

N4 = [(1, 0), (-1, 0), (0, 1), (0, -1)]
N8 = N4 + [(1, 1), (-1, 1), (1, -1), (-1, -1)]


def _at(g, x, y):
    H, W = g.shape
    return g[y, x] if 0 <= x < W and 0 <= y < H else -1


def strays(g, keep=()):
    """a dot with no neighbour of its own colour takes its neighbours' most common colour
    (except colours in keep: eyes and highlights are meant to stand alone), and a dot that
    touches nothing on its four sides is removed"""
    H, W = g.shape
    out = g.copy()
    for y in range(H):
        for x in range(W):
            v = g[y, x]
            if v < 0 or v in keep:
                continue
            nb = [_at(g, x + dx, y + dy) for dx, dy in N8]
            if v not in nb:
                vals, cnt = np.unique(nb, return_counts=True)
                out[y, x] = vals[cnt.argmax()]
    for y in range(H):
        for x in range(W):
            if out[y, x] >= 0 and all(_at(out, x + dx, y + dy) < 0 for dx, dy in N4):
                out[y, x] = -1
    return out


def specks(g, keep=()):
    """grain inside a flat area: a dot (or a pair) whose eight neighbours hold at most one
    of its colour and at least seven of one other colour takes that colour. A line of one
    dot has two of its colour beside it, so lines stay"""
    H, W = g.shape
    out = g.copy()
    for y in range(1, H - 1):
        for x in range(1, W - 1):
            v = g[y, x]
            if v < 0 or v in keep:
                continue
            nb = [g[y + dy, x + dx] for dx, dy in N8]
            if nb.count(v) > 1:
                continue
            vals, cnt = np.unique(nb, return_counts=True)
            if cnt.max() >= 7 and vals[cnt.argmax()] >= 0:
                out[y, x] = vals[cnt.argmax()]
    return out


def thin_outline(g, dark):
    """an outline one dot thick: a dark dot just inside the edge's dark dot takes the colour inside it"""
    H, W = g.shape
    out = g.copy()

    def edge(x, y):
        return g[y, x] in dark and any(_at(g, x + dx, y + dy) < 0 for dx, dy in N4)

    for y in range(H):
        for x in range(W):
            if g[y, x] not in dark or edge(x, y):
                continue
            nb = [(x + dx, y + dy) for dx, dy in N4 if 0 <= x + dx < W and 0 <= y + dy < H]
            if not any(edge(a, b) for a, b in nb):
                continue
            inner = [g[b, a] for a, b in nb if g[b, a] >= 0 and g[b, a] not in dark]
            if inner:
                vals, cnt = np.unique(inner, return_counts=True)
                out[y, x] = vals[cnt.argmax()]
    return out


def rim_light(g, base, light, dark, rows=None):
    """the base colour next to the outline on the lit side (up and left) steps up to light"""
    H, W = g.shape
    out = g.copy()
    for y in range(H if rows is None else min(H, rows)):
        for x in range(W):
            if g[y, x] == base and any(_at(g, x + dx, y + dy) in dark or _at(g, x + dx, y + dy) < 0
                                       for dx, dy in ((-1, 0), (0, -1))):
                out[y, x] = light
    return out


def largest(g):
    """only the biggest connected piece: drops things drawn beside the figure"""
    H, W = g.shape
    lab_ = np.zeros((H, W), int)
    sizes = {}
    n = 0
    for y in range(H):
        for x in range(W):
            if g[y, x] < 0 or lab_[y, x]:
                continue
            n += 1
            st, c = [(x, y)], 0
            lab_[y, x] = n
            while st:
                px, py = st.pop()
                c += 1
                for dx, dy in N8:
                    qx, qy = px + dx, py + dy
                    if 0 <= qx < W and 0 <= qy < H and g[qy, qx] >= 0 and not lab_[qy, qx]:
                        lab_[qy, qx] = n
                        st.append((qx, qy))
            sizes[n] = c
    if not sizes:
        return g
    return np.where(lab_ == max(sizes, key=sizes.get), g, -1)


# ---- checking against the original ----------------------------------------

def score(ref, drawn):
    """how closely a drawn frame follows the original averaged into the same cells

    overlap: shared silhouette over combined silhouette (1 is exact). colour: mean
    difference in Lab where both have ink (about 2 is just visible, above 10 reads as
    another shade). Also a picture of the difference: grey where they agree, orange to
    red as the colour differs, red where only the original has ink, cyan where only the
    drawing has."""
    a, b = ref[..., 3] > 0, drawn[..., 3] > 0
    both = a & b
    de = np.sqrt(((lab(ref.astype(float)) - lab(drawn.astype(float))) ** 2).sum(2))
    t = np.clip(de / 40, 0, 1)
    pic = np.zeros(ref.shape, np.uint8)
    pic[both] = np.dstack([110 + 145 * t, 110 - 30 * t, 110 - 110 * t, np.full_like(t, 255)])[both]
    pic[a & ~b] = (230, 60, 60, 255)
    pic[b & ~a] = (60, 200, 230, 255)
    return dict(overlap=float(both.sum() / max(1, (a | b).sum())),
                colour=float(de[both].mean()) if both.any() else 0.0), pic


def extend(palette, colours, n, far=10.0, seed=0):
    """up to n colours to add to a palette so that the given colours (RGB rows, one per
    dot) all have a near one: k-means over the dots that are farther than far (Lab) from
    every colour already there. Returns hex strings, most used first."""
    L = lab(colours.reshape(1, -1, 3).astype(float)).reshape(-1, 3)
    d = np.sqrt(((L[:, None] - palette.lab[None]) ** 2).sum(-1)).min(1)
    X = L[d > far]
    if len(X) < n:
        return []
    rng = np.random.default_rng(seed)
    C = X[rng.choice(len(X), n, replace=False)]
    for _ in range(30):
        k = ((X[:, None] - C[None]) ** 2).sum(-1).argmin(1)
        C = np.array([X[k == i].mean(0) if (k == i).any() else C[i] for i in range(n)])
    used = np.bincount(k, minlength=n)
    rgb = colours.reshape(-1, 3)[d > far]
    out = []
    for i in np.argsort(-used):
        if used[i]:
            out.append("%02x%02x%02x" % tuple(np.median(rgb[k == i], 0).astype(int)))
    return out


def merge_rare(frames, palette, share=.01, near=14.0, keep=()):
    """a colour that covers less than share of a sprite's dots and has a commoner colour
    within near (Lab) becomes that colour: fewer colours per sprite, no speckle from two
    almost equal shades. Distinct accents (eyes, bolts) are kept however few."""
    allx = np.concatenate([f[f >= 0] for f in frames])
    cnt = np.bincount(allx, minlength=len(palette.names)) / max(1, len(allx))
    common = [i for i in np.argsort(-cnt) if cnt[i] >= share]
    swap = {}
    for i in np.flatnonzero((cnt > 0) & (cnt < share)):
        if i in keep or not common:
            continue
        d = np.sqrt(((palette.lab[common] - palette.lab[i]) ** 2).sum(-1))
        if d.min() < near:
            swap[i] = common[int(d.argmin())]
    out = []
    for f in frames:
        g = f.copy()
        for i, j in swap.items():
            g[f == i] = j
        out.append(g)
    return out


def png_uri(g, zoom=4):
    im = Image.fromarray(np.asarray(g, np.uint8), "RGBA")
    im = im.resize((im.width * zoom, im.height * zoom), Image.NEAREST)
    buf = io.BytesIO()
    im.save(buf, "PNG")
    return "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode()
