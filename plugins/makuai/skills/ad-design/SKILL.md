---
name: ad-design
description: This skill should be used when designing when and how a free app shows ads — when the user mentions "無料版に広告を入れたい", "広告の出しどき", "広告モデルの設計", "インタースティシャルをどこで出す", "リワード動画", "広告の頻度制御", "広告除去の IAP", "クロスプロモを混ぜたい", "App Open Ads", "ATT プロンプト", "AdMob の組み込み方", or plans a free-tier-with-ads monetization for an app. Provides product-agnostic principles for ad timing, frequency, presentation, and implementation, distilled from a shipped iOS app's ADRs and checked against industry practice as of 2026.
user-invocable: false
allowed-tools: Read
---

# Ad Design for the Intermission

This skill holds the principles for when and how a free app shows ads. They originate in a shipped iOS app where they were forged through multiple ADRs and on-device iteration, then rewritten as product-agnostic principles checked against the industry practice of 2026: AdMob's guidelines, the App Store Review Guidelines, and ATT in the field.

One value sits at the core. The harm of advertising is decided not by average frequency but by the single worst impression. One ad shown while the user is doing the work the tool exists for, on stage, mid-negotiation, mid-measurement, destroys trust in the tool. Therefore ads appear only in the intermission: enumerate the allowed moments as breaks in the user's work, treat every other moment as forbidden by default, and concentrate that judgment in a single gate every ad must pass first.

The references are split by concern. Read only the one that matches the design question at hand rather than loading them all.

- `references/placement.md` — timing. The absolute rule of never showing ads mid-work, the whitelist of firing points, the two-stage gate, first-session protection, and the comparison of the two launch-ad approaches, a self-built modal versus App Open Ads. Read when deciding where ads may appear, or when evaluating a proposal for a new ad slot.
- `references/frequency.md` — frequency. The two peer philosophies, auto-capping and user-driven control that delegates cooldown to rewarded video, the conditions under which the latter holds, the floor both must respect, quiet periods and monotonic suspension merging, and the discipline of the reward economy. Read when designing ad frequency, rewarded video, or a remove-ads purchase.
- `references/presentation.md` — presentation. The pre-ad notice named in the product's own vocabulary, the bearing of a self-built modal, house ads under the same discipline, App Store Review Guideline 2.5.18, and the timing of the ATT prompt. Read when designing how ads look, present themselves, and pass review.
- `references/engineering.md` — implementation. The SDK seam and the ordering that leaves production values last, deterministic tests via injected randomness, time, and scene transitions, the lesson of the foreground-resume false positive, and cross-promo probability mixing with three-tier fallback. Read when it is time to write the ad code.

Keep three postures when applying these principles. First, numbers such as firing probability, suspension duration, and mixing ratio are the source product's tuning results, not principles; carry home the structure, and implement each number as a constant to be retuned for the target product. Second, when moving a principle into a target product, rename it in that product's own vocabulary; the source called its pre-ad notice INTERMISSION because it was an app built on stage vocabulary. Third, matters specific to iOS and AdMob are marked as such in the text, so on other platforms carry over only the structure.
