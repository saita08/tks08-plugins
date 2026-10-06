/* Shows a game's screen in frames of several sizes and checks that every frame
   gives the same picture: each element, measured on the reference (its place
   and size divided by the frame's scale, from the top left of the safe part),
   must sit where it sits when the screen is shown at the reference size itself.
   Pixels are not compared, since the same picture at another scale never
   rasterizes the same; sheet.png puts the frames side by side for the eye.

   node check.cjs <game dir> [--ref 390x760] [--desktop] [--eval "<js>"] [--out <dir>]

   It also lists text that leaves the box it sits in, on the reference frame:
   a line that runs out of its own box, or out of any box above it up to the
   first one that is painted or clips. A long value is made to fit its box, or
   the box is made to reach the room the value may use.

   --eval runs in the page after it loads, to reach a screen other than the
   first. Exits 1 when any frame moves an element or any text leaves its box. */
const http = require("http");
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

function playwright(){
  try { return require("playwright"); }
  catch { return require(path.join(execSync("npm root -g").toString().trim(), "playwright")); }
}

/* width, height, top inset, bottom inset. A phone game: the apps' sizes with
   the insets a real device reports, then browsers whose bars leave a low frame,
   then a PC window. A desktop game: common windows, then a phone. */
const PHONE = [
  [375, 667, 20, 0], [390, 844, 47, 34], [393, 852, 59, 34], [430, 932, 59, 34], [440, 956, 62, 34],
  [395, 615, 0, 0], [375, 560, 0, 0], [1280, 800, 0, 0],
];
const DESKTOP = [
  [1280, 720, 0, 0], [1920, 1080, 0, 0], [1366, 768, 0, 0], [1024, 768, 0, 0], [1440, 900, 0, 0], [390, 844, 47, 34],
];
const SLACK = 1; /* reference px an edge may stray from rounding alone */

const args = process.argv.slice(2);
const opt = (k, d) => { const i = args.indexOf(k); return i < 0 ? d : args[i + 1]; };
const dir = path.resolve(args[0] || ".");
const [W, H] = opt("--ref", "390x760").split("x").map(Number);
const frames = args.includes("--desktop") ? DESKTOP : PHONE;
const setup = opt("--eval", "");
const out = path.resolve(opt("--out", "."));

const TYPES = { ".html": "text/html", ".js": "text/javascript", ".mjs": "text/javascript", ".css": "text/css",
  ".png": "image/png", ".webp": "image/webp", ".jpg": "image/jpeg", ".svg": "image/svg+xml", ".woff2": "font/woff2", ".json": "application/json" };
const server = http.createServer((req, res) => {
  let f = path.join(dir, decodeURIComponent(req.url.split("?")[0]));
  if (fs.existsSync(f) && fs.statSync(f).isDirectory()) f = path.join(f, "index.html");
  if (!f.startsWith(dir) || !fs.existsSync(f)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { "content-type": TYPES[path.extname(f)] || "application/octet-stream" });
  fs.createReadStream(f).pipe(res);
});

async function shoot(browser, url, [vw, vh, it, ib]){
  const page = await browser.newPage({ viewport: { width: vw, height: vh }, reducedMotion: "reduce" });
  await page.goto(url);
  if (setup) await page.evaluate(setup);
  /* a headless browser reports no insets, so stand in for the device's. They
     arrive after the first paint with no resize, as they do in an app's web
     view, so fit.js has to notice them by itself */
  await page.evaluate(([t, b]) => {
    document.documentElement.style.setProperty("--inset-t", t + "px");
    document.documentElement.style.setProperty("--inset-b", b + "px");
  }, [it, ib]);
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(600);
  const got = await page.evaluate(([W, H, it]) => {
    const cs = getComputedStyle(document.documentElement);
    const s = parseFloat(cs.getPropertyValue("--s")), safeT = parseFloat(cs.getPropertyValue("--safe-t"));
    if (!(s > 0)) throw new Error("no --s on the root: the page does not load fit.js");
    const x0 = (innerWidth - W * s) / 2, y0 = safeT * s;
    const name = e => e.id ? "#" + e.id : e.tagName.toLowerCase() + (e.classList.length ? "." + [...e.classList].join(".") : "");
    const parts = [];
    for (const e of document.body.querySelectorAll("*")) {
      const r = e.getBoundingClientRect();
      /* the scaled stage carries the covered margins, so it grows with them */
      if ((!r.width && !r.height) || (e.parentElement === document.body && getComputedStyle(e).transform !== "none")) continue;
      const path = []; for (let p = e; p && p !== document.body; p = p.parentElement) path.unshift(name(p));
      parts.push({ key: path.join(" > "), box: [(r.left - x0) / s, (r.top - y0) / s, r.width / s, r.height / s] });
    }
    /* text sideways out of its box: each box from the text's own up to the
       first painted or clipping one must hold it */
    const over = [];
    const paints = c => (parseFloat(c.borderLeftWidth) > 0 && c.borderLeftStyle !== "none") || c.backgroundImage !== "none" || c.backgroundColor !== "rgba(0, 0, 0, 0)" || c.overflowX !== "visible";
    const walk = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT);
    for (let n; (n = walk.nextNode());) {
      if (!n.textContent.trim() || !n.parentElement.checkVisibility({ opacityProperty: true, visibilityProperty: true })) continue;
      const rg = document.createRange(); rg.selectNodeContents(n);
      const rs = [...rg.getClientRects()].filter(r => r.width);
      if (!rs.length) continue;
      const l = Math.min(...rs.map(r => r.left)), r = Math.max(...rs.map(r => r.right));
      for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) {
        const c = getComputedStyle(a);
        if (c.display === "inline" || c.display === "contents") continue;
        if (a.parentElement === document.body && c.transform !== "none") break;
        const R = a.getBoundingClientRect(), by = Math.max(R.left - l, r - R.right) / s;
        if (R.width > 1 && by > 1) { over.push(`"${n.textContent.trim().slice(0, 20)}" leaves ${name(a)} by ${by.toFixed(0)}`); break; }
        if (paints(c)) break;
      }
    }
    return { s, parts, over, clip: { x: x0, y: y0, width: W * s, height: H * s } };
  }, [W, H, it]);
  const png = await page.screenshot({ clip: got.clip });
  await page.close();
  return { ...got, png };
}

function moved(ref, shot){
  const found = [];
  const n = Math.max(ref.parts.length, shot.parts.length);
  for (let i = 0; i < n; i++) {
    const a = ref.parts[i], b = shot.parts[i];
    if (!a || !b || a.key !== b.key) { found.push(`${(a || b).key}: shown in one frame only`); break; }
    /* what runs out under the covered margins (a background) grows with
       them by design; only the safe part is compared */
    const [x, y, w, h] = a.box;
    if (x < -SLACK || y < -SLACK || x + w > W + SLACK || y + h > H + SLACK) continue;
    const off = a.box.map((v, k) => Math.abs(v - b.box[k]));
    if (Math.max(...off) > SLACK)
      found.push(`${a.key}: ${a.box.map(v => v.toFixed(0)).join(",")} -> ${b.box.map(v => v.toFixed(0)).join(",")}`);
  }
  return found;
}

(async () => {
  await new Promise(r => server.listen(0, r));
  const url = `http://127.0.0.1:${server.address().port}/`;
  const browser = await playwright().chromium.launch();
  const ref = await shoot(browser, url, [W, H + 20, 0, 0]);
  const shots = [];
  for (const f of frames) shots.push({ f, ...(await shoot(browser, url, f)) });

  const page = await browser.newPage();
  const sheet = await page.evaluate(async ([W, H, pngs]) => {
    const load = b64 => new Promise(r => { const i = new Image(); i.onload = () => r(i); i.src = "data:image/png;base64," + b64; });
    const c = document.createElement("canvas");
    c.width = W * pngs.length; c.height = H;
    const x = c.getContext("2d");
    x.imageSmoothingQuality = "high";
    for (let k = 0; k < pngs.length; k++) x.drawImage(await load(pngs[k]), W * k, 0, W, H);
    return c.toDataURL("image/png").split(",")[1];
  }, [W, H, [ref, ...shots].map(s => s.png.toString("base64"))]);
  await browser.close();
  server.close();

  fs.mkdirSync(out, { recursive: true });
  fs.writeFileSync(path.join(out, "sheet.png"), Buffer.from(sheet, "base64"));
  let bad = 0;
  for (const { f: [vw, vh, it, ib], s, ...shot } of shots) {
    const found = moved(ref, shot);
    if (found.length) bad++;
    console.log(`${found.length ? "MOVED" : "same "}  ${vw}x${vh} insets ${it}/${ib}  scale ${s.toFixed(3)}  ${found.length ? found.length + " elements moved" : "nothing moved"}`);
    for (const m of found.slice(0, 5)) console.log(`       ${m}`);
  }
  for (const o of ref.over) console.log(`OVER   ${o}`);
  console.log(`sheet: ${path.join(out, "sheet.png")} (the reference first)`);
  process.exit(bad || ref.over.length ? 1 : 0);
})();
