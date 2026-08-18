# Frequency — Who Stops the Ads

## Two philosophies

Frequency control has two peer philosophies, and choosing between them is a design decision.

One is auto-capping. The app holds a per-session impression limit and a minimum interval between impressions, and the app protects the user from its own ads. This is the industry standard, and it is what AdMob and the mediation platforms offer by default in their dashboards. Behavior is predictable, and a mistake in funnel design cannot produce a high-frequency accident; it is the safe-side choice.

The other is user-driven control. The app holds no cooldown and no interval; firing is decided by probability alone, and the means of reducing ads is handed to the user as rewarded video. Watching a reward stops every ad for a fixed period, so the user creates the quiet period themselves. Behavior becomes explainable with just two words, probability and suspension, and the initiative over frequency moves from the app to the user. The source product chose this side.

What matters is refusing to treat the unchosen side as an omission. The source product has no capping, and that is not an implementation gap but a design decision recorded in an ADR. Unless not having something is itself written down as a decision, a successor, future self included, will add capping in good faith and quietly break the philosophy. When a design chooses not to have something, record the not-having.

## The conditions under which user-driven control holds

This philosophy holds only while the reward funnel actually reaches users. If the funnel does not reach them, the app is, from the user's seat, just a high-frequency ad app with no off switch. The source product keeps a permanent watch button in settings and additionally offers the reward by probability after an interstitial has shown. The offer goes to viewers who watched to the end, not only to those who skipped, because when the reward is the protagonist of frequency control its existence must reach everyone.

## The floor both philosophies must respect

Whichever philosophy is chosen, never show more than one ad at a single break. AdMob explicitly forbids the placement, and as an experience one interruption comes to weigh as two. Even under user-driven control, never fire a second ad from the same triggering event. Ads may still run back to back across adjacent but distinct breaks, for example returning to a list right after completing a copy; that is an accepted outcome of the user-driven philosophy, and if it is not acceptable, that is a reason to choose capping.

## Quiet periods and monotonic suspension merging

Set the effect of a rewarded view to stopping every kind of ad for a fixed period. The source set six hours, and the value is a tunable constant. When the ads stop, the post-ad reward offers stop with them, so the quiet is quiet from solicitation too. The user who chose to stop the ads gets genuinely quiet time.

Merge suspensions monotonically. When a new suspension would expire earlier than the one already in effect, do not shorten; the longer suspension always wins. With more than one suspension source, a timed reward suspension and a permanent remove-ads purchase for instance, the accident where a short suspension overwrites and shortens a long one happens silently and is found late. Implemented as monotonicity, it becomes a single invariant that tests can hold.

## The discipline of the reward economy

State the reward before the view: watching this video stops ads for six hours, or whatever the product's terms are, so the user knows what they are trading their time for before they tap. Grant only on completed views, after the SDK's completion callback. Granting on abandonment destroys the meaning of the reward; granting before the view is fraud against the advertiser.

Position the remove-ads purchase as the reward's superior form: the permanent version of the quiet period, a skip pass for every future rewarded view. Framed this way, the free path of watching and the paid path of purchasing lie on one line, and users choose by their own tolerance. Users who have felt ads stop through the reward are the ones who value making it permanent, which also matches where the industry has been heading.
