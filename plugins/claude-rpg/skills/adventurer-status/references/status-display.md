# Status display

How to turn the judged achievement set into the adventurer's status card. This
is presentation only; the truth lives in the judged data.

## Rank by unlocked count

The rank is a function of how many achievements are unlocked out of the total
defined. It is flavor derived honestly from the count — nothing more.

- 0 unlocked: "見習い" (Apprentice)
- 1–4: "駆け出し冒険者" (Novice Adventurer)
- 5–9: "冒険者" (Adventurer)
- 10–14: "熟練の冒険者" (Veteran Adventurer)
- 15–18: "英雄" (Hero)
- 19–20: "伝説" (Legend)

State the rank with the raw count beside it, e.g. `伝説 (19/20 解除)`. Never
imply a rank the count does not support.

## The status card

Show, in this order:

1. **称号 (Rank)** — the rank above, with `解除数/総数`.
2. **冒険者の記録 (Vital stats)** — a few real numbers pulled straight from the
   data, each labeled with what it is: total sessions, total messages, longest
   session (format the ms duration as `Xh Ym`), first session date. Only show a
   number you actually read; omit any that is missing rather than guessing.
3. **解除済みの実績 (Unlocked)** — list each unlocked achievement as
   `title — one-line note of what earned it, with the real number`. The note
   must reference the actual value that cleared the bar (e.g. "最長セッション
   6h 12m" not just "長時間セッション"). This is the anti-lie rule: every
   unlocked line carries its evidence.
4. **次に近い実績 (Closest locked)** — pick the 1–3 locked achievements whose
   condition the data is nearest to meeting, and for each show how far off it is
   in real terms (e.g. "常連まであと 3 セッション", "七日連続まであと 2 日").
   Compute the gap from the same fields the condition reads. If a locked
   achievement's distance cannot be computed (its data source is missing), do
   not list it as "close".

## Tone

Celebratory but never inflating. The numbers are already impressive on their
own; the job is to frame them as feats, not to exaggerate them. If the record
is thin (a brand-new install), say so warmly — the adventure is just starting —
rather than dressing up an empty log.

## Newly unlocked this run

If the persistence step reports achievements that were newly unlocked on this
invocation (not present in the prior saved set), call them out first, above the
card, as a short "新たに解除!" line each. If nothing is newly unlocked, skip
that section entirely.
