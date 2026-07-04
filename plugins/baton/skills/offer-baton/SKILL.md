---
name: offer-baton
description: This skill should be used when Claude has just finished a unit of work whose final verification belongs to a human — anything that needs checking on real hardware, a real device, staging or production, a browser, a physical result, or a human's eyes. Triggers when reporting completion of such work, or when the user says things like "実機で確認する", "本番に反映", "あとで目視でチェック", "test it on the device", "deploy this", "verify on prod". Guides bridging the gap between "Claude is done" and "the human verifies" with a baton handoff sheet.
allowed-tools: Read
---

# Offer a Baton

Claude's work can be complete and still not verified. When the last check belongs to a human — a real device to flash, a production toggle to flip, a rendered page to eyeball, a physical outcome to observe — there is a gap between "Claude reports done" and "the human confirms it actually works." That gap is usually crossed with a spoken sentence, and spoken sentences get dropped: the human forgets a step, checks the wrong thing, or never verifies at all and ships on faith.

The idea this skill carries: between the report of completion and the start of human verification, there must always be a bridge. The baton is that bridge — a written, concrete handoff of exactly what the human must do, look for, and undo. This skill is the judgment for *when* to build the bridge; the `/baton:write` command builds it.

## When to offer

Offer a baton whenever the work you just finished cannot be fully verified by you, and its real confirmation requires a human to act in the physical or external world. Concretely:

- Firmware, hardware, or embedded work that must be flashed and observed on a device.
- Anything that must be deployed, flipped live, or run in an environment you cannot reach.
- Visual or UX work whose correctness is a human judgment ("does this look right").
- Changes whose effect only shows up under real data, real users, or real load.

Do not offer when your work is fully verifiable in-session (tests you can run, output you can read) and nothing is left for a human to check. If you already proved it works end to end, there is no baton to pass — say it works and stop. A baton for work that needs no human check is ceremony, and ceremony trains the user to ignore the real ones.

## How to offer

When you report completion of such work, do not stop at "done." Name the human's remaining part in the same breath, and offer to write it down: "実機での確認が要ります。手順書（バトン）を書いておきますか。" One line. The value is concrete — the human gets a copy-pasteable checklist instead of reconstructing the steps from memory, and nothing gets skipped.

If the user agrees, run `/baton:write`. If they decline, drop it; the offer was the bridge, and they chose to cross it their own way.

## The principle behind it

The completion report and the human verification are two different events, and the space between them is where work silently fails — not because anything was wrong, but because the pass was never made. Always build the bridge. A finished task that a human still has to check is not finished until the human knows exactly how to check it. That knowledge is Claude's to hand over, in writing, not the human's to reconstruct.
