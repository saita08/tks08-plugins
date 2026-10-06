/* The screen is laid out at one reference size and the whole of it is scaled
   to the frame it is shown in, as a game's canvas is. The reference is the
   safe part of the frame, the part no notch, home bar or host's header covers,
   so every frame shows the same picture at its own scale and nothing inside is
   sized or placed by the frame. The covered margins are added round it at the
   same scale, and so is whatever a frame of another shape leaves above and
   below it, so the background runs to the frame's edges; to the sides the
   ground colour shows round it. Loaded in the head after the stylesheet, so
   the first paint is already at its size. */
(function(){
  /* W, H: the reference. FOOT: the least room kept at the bottom where the
     page is not told the inset (a browser tab), since a home bar may be there
     all the same; 0 for a game that only runs in a desktop window. */
  var W = 390, H = 760, FOOT = 20;
  var root = document.documentElement;
  /* A web view in an app learns its insets only once it is on screen, after
     the first measure and with no resize to tell of it, so the insets are read
     from two boxes that stay in the page and are measured again whenever
     either changes size. */
  function probe(side){
    var p = document.createElement("div");
    p.style.cssText = "position:fixed;left:0;top:0;visibility:hidden;pointer-events:none;width:0;height:var(--inset-" + side + ",0px)";
    root.appendChild(p);
    return p;
  }
  var pt = probe("t"), pb = probe("b");
  function fit(){
    var vw = window.innerWidth, vh = window.innerHeight;
    var it = pt.getBoundingClientRect().height, ib = Math.max(pb.getBoundingClientRect().height, FOOT);
    var s = Math.min(vw / W, (vh - it - ib) / H);
    /* the safe part sits in the middle of what the covered margins leave */
    var spare = Math.max(0, vh - it - ib - H * s) / 2;
    root.style.setProperty("--s", s.toFixed(4));
    root.style.setProperty("--w", W + "px");
    root.style.setProperty("--lh", (vh / s).toFixed(2) + "px");
    root.style.setProperty("--safe-t", ((it + spare) / s).toFixed(2) + "px");
    root.style.setProperty("--safe-b", ((ib + spare) / s).toFixed(2) + "px");
  }
  fit();
  window.addEventListener("resize", fit);
  document.addEventListener("DOMContentLoaded", fit);
  if (window.ResizeObserver) {
    var watch = new ResizeObserver(fit);
    watch.observe(pt);
    watch.observe(pb);
  }
})();
