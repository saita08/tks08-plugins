# Diversity Angles

Independence keeps attempts from copying each other, but it does not by itself make them different. Two blind workers given the same task and the same instructions will still converge, because they are the same model reasoning the same way. Divergence has to be forced, and the way to force it is to hand each worker a different value to optimize for. This file holds the ordered set of angles and the reasoning behind each.

Assign angles in this order, taking as many as the count N requires. The order front-loads the angles that most often produce usefully different code.

## 1. Minimal-first

Optimize for the smallest change that fully solves the task. Prefer deleting to adding, reusing to building, the standard library to a dependency. This angle asks: what is the least that could possibly work? Its attempts expose how much of the other universes' code was actually necessary.

## 2. Robustness-first

Optimize for what happens when things go wrong. Handle the empty input, the malformed input, the concurrent access, the partial failure. Validate at the boundary. This angle asks: where does this break, and what does breaking cost? Its attempts expose the failure modes the minimal one waved past.

## 3. Performance-first

Optimize for speed and resource use under real load. Choose the data structure that makes the hot path cheap, avoid the redundant pass, consider the large-N case. This angle asks: what does this cost at scale? Its attempts expose where the elegant approach is quietly quadratic.

## 4. UX-first

Optimize for the person on the other end — the caller of the API, the reader of the error, the user of the interface. Make the common case obvious and the mistake hard. This angle asks: what is it like to actually use this? Its attempts expose where the clever internals leaked into an ugly surface.

## 5. Convention-breaking

Optimize by questioning the frame. Maybe the task as stated is the wrong task; maybe the obvious structure is obvious only because everyone copies it. Try the approach the other four would reject on sight. This angle asks: what if the standard answer is wrong here? Most of the time it produces the discard — and occasionally it produces the insight none of the disciplined angles could reach, which is exactly why it is worth one slot.

## Why these, in this order

The first four are the classic axes along which a design decision trades off — size, safety, speed, usability — and a good solution usually can't max all four at once, so forcing each into its own universe surfaces the real trade-offs for the judges to weigh. The fifth is the wildcard that keeps the tournament from being a vote among four flavors of conventional wisdom. Taking them in order means a 2-universe run pits minimal against robust (the sharpest and most common tension), and each higher N adds the next most productive axis.
