# Implementation — Judgment Pure, Injection Last

## The SDK seam

Close all ad logic behind a protocol boundary. Firing judgment, meaning probability, gating, and suspension state, lives on the near side of the boundary as pure logic that knows nothing of the SDK; only presentation, the actual SDK calls, lives on the far side. When judgment and presentation fuse, the judgment cannot be tested without the SDK and cannot be swapped for a mock. With the boundary in place, configurations that show no ads, the paid tier and the test suite alike, inject a mock, and the unreachability of ad code becomes a compile-level guarantee.

## Ordering — production values last

Introducing an ad SDK has three layers: implementing the firing logic in code, linking the SDK binary, and injecting the production values, meaning the app ID and the ad unit IDs. Only the last layer requires an ad account, so place only that layer at the very end of the work. The first two layers complete their development and testing on test IDs and mocks, so waiting for account review never stalls the project. With the protocol boundary already built, the final layer shrinks to plugging values into a socket, with no rework.

Force test unit IDs in development builds through code structure, a build-configuration branch for example, never through operational discipline. Hitting production IDs during development is treated by ad networks as invalid traffic and risks account suspension. Prevent the accident by structure, not by care. When a release build finds a value missing or empty, fail toward not showing that ad type.

Record one trap. Some SDKs run their own initialization the moment the framework loads, without passing through any app code. Google Mobile Ads is one: linked without an app ID in Info.plist, it crashes at launch, and no guard in app code can prevent it. At the very start of an integration, check the SDK's documentation for which values become mandatory the moment it is linked.

## Deterministic tests — inject randomness, time, and scene transitions

For ads that fire by probability, inject the randomness source as a closure returning a value from zero up to but not including one, and in tests pass fixed values to verify firing inside the threshold and silence outside it. For timed suspensions, inject the time source and verify the boundary at the expiry instant. Tests that depend on real randomness and real clocks are flaky and cannot examine the boundaries at all.

For ads that react to the app's lifecycle, its scene transitions, extract the judgment into a pure state machine and test it by feeding transition sequences. A lesson from the field lives here. Implementing foreground resume naively as any transition to active also counts the opening and closing of purchase sheets, notification center, and system alerts, which stop at inactive and never reach background. In the source product this false positive produced the worst possible sequence: an ad shown immediately after the user cancelled an in-app purchase. Fix the definition, not the symptom of a flag suppressing ads during the purchase flow: only a transition to active that passed through background counts as a resume. With the judgment extracted as a pure state machine, that definition is verified deterministically against sheet round-trips, screen locks, and app switches.

## Mixing cross-promo with third-party ads

When house cross-promotion and third-party ads share one slot, mix them by probability, not by priority. The source used 30 percent house and 70 percent third-party, and the ratio is a tunable constant. A rule of house first whenever house inventory exists zeroes the slot's ad revenue the moment a single house app is registered. A probability mix keeps the house funnel and the revenue coexisting, and rebalancing is a one-constant change. When the winning side has no inventory, fall back to the other; when neither yields anything, show nothing that round.

Supply the cross-promo inventory through three tiers of fallback: remote JSON, then disk cache, then a bundled default. The remote tier swaps inventory after release without an app update; the cache serves offline launches; the bundled default covers first launch and cache loss. Treat an empty array as a valid result. Zero inventory is not an error; the slot simply falls back to the third-party side.
