# Timing — Only in the Intermission

## The absolute rule: never in front of the audience

Never show an ad while the user is doing the work the tool exists for, regardless of probability or frequency. What decides the quality of an ad experience is not the total number of impressions but the single worst one, and an ad shown mid-work is an accident from the user's point of view. In a tool used in front of other people it is a professional accident; even in private, broken concentration carries the same weight. A modest average frequency does not justify that one impression.

Absolute means the rule is enforced by structure, not by lowering a probability. Being mid-work must by itself prevent the lottery from even running. A state where an ad can appear mid-work one percent of the time is not a state where the rule is 99 percent kept; it is a state where the rule is broken.

This rule is consistent with the placement principle AdMob recommends as natural break points, meaning ads shown at natural pauses in content. Understand it not as private asceticism but as a stricter form of the platform's own convention.

## Enumerate the allowed moments, not the forbidden ones

Count the moments where ads may appear rather than the moments where they must not. A blocklist leaks every time a new screen or operation is added, while under an allowlist any moment missing from the enumeration is forbidden by default. A safe default stands on the side of the rule.

What the allowed moments share is that the user has just closed a unit of work by their own decision. In the source product the enumeration was: cold start of the app, immediately after opening or closing the history review screen, immediately after opening or closing settings, immediately after confirming a reset-all, and immediately after completing an export. Operations that begin work, and any moment during work, never enter the enumeration however attractive they look as inventory.

When a proposal for a new ad slot arrives, judge it first against this enumeration and the absolute rule. Additions happen only as updates to the document that records the rule, an ADR or its equivalent. When future maintainers, the original author included, are tempted by revenue, that document is the brake.

## The two-stage gate

Place one common gate ahead of every ad and ask only two questions there. Is the user mid-work right now? Are ads suspended, whether by a rewarded view or a remove-ads purchase? If either answer is yes, reject without looking at ad type, firing point, or probability.

Scattering the avoidance rule across per-firing-point conditionals guarantees an omission as firing points multiply. Concentration in one place turns a change of the rule into a change in one place, and turns verifying the rule into one test. Together with the whitelist this forms a double defense: narrowing the firing points to non-work moments defends at the wiring level, and the gate rejecting whatever still arrives defends at the judgment level.

## Protect the first session

Show no ads during the first session or before onboarding completes. An ad shown to a user who has not yet experienced the product's value produces churn, not revenue. Day-one retention is the lifeline of a free-with-ads model, and first-day ad revenue is far too cheap a thing to trade it for. This is industry convention, and it stands on the same reasoning as the official App Open Ads recommendation described below, to unlock only after several uses.

## What to show at launch — two approaches

AdMob forbids standard interstitials at app launch and exit, and a full-screen ad overlapping the app's load can be treated as invalid traffic. If a launch ad slot is wanted, two approaches exist.

One is a self-built modal holding a static image. It gives complete control of shape, content, and presentation timing, displays instantly without a load wait, integrates into the product's visual world, and lets house cross-promotion share the same slot. The costs are using inventory that pays less than the standard formats, banners for example, and carrying the responsibility for presentation, close affordances, and labeling yourself. That responsibility is covered in `presentation.md`.

The other is App Open Ads, the official format built for launch and resume. It is light to implement and earns standard-format rates. Google's official recommendation is to unlock it not from the first launch but after the user has used the app several times, which stands on the same reasoning as first-session protection. The cost is that format and timing belong to the SDK, so integration with the product's world is out of reach.

Neither is the correct answer on its own. Choosing the self-built modal prioritizes control of the product's world; choosing App Open Ads prioritizes revenue efficiency and implementation cost. Record the reason for the choice. The source product judged that an SDK-controlled full-screen ad could not coexist with its restrained visual language, and chose the former.
