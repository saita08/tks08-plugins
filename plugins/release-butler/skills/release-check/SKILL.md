---
name: release-check
description: This skill should be used when the conversation turns to cutting a release, tagging a version, bumping a version number, publishing a package, or committing changes that ought to be released — and Claude should recall the three-way sync between code, version, and CHANGELOG before the release goes out. Triggers on "release", "cut a version", "bump the version", "tag", "publish", "リリース", "バージョンを上げる", and on committing changes to a versioned package. Use it to recognize when to run /release-butler:check.
allowed-tools: Read
---

# Release Check

Three artifacts have to move together for a release to be honest: the code that changed, the version number that names the release, and the CHANGELOG entry that tells users what is in it. When one lags, the tag stops matching its contents — and because CI usually generates the tag and the GitHub release from these files, the moment they are out of sync at commit time, the recorded history becomes permanently wrong. The failure is quiet: nothing errors, the release just ships mislabeled.

This skill is the reminder that surfaces the three-way check at the moments it matters, so the drift is caught before it is committed rather than discovered after it is tagged. The actual inspection is done by `/release-butler:check`.

## When to reach for the check

The right time is *before* a release is finalized, when there is still room to fix a gap. Recognize these moments:

- The user is about to cut a release, tag a version, or publish a package.
- The user is bumping a version number, or asks whether the version should move.
- Changes are being committed to a package that carries a version, and a release will eventually be built from those commits.
- The user asks whether things are "ready to release" or in a releasable state.

At any of these, offer to run `/release-butler:check` first — a one-line offer, not a lecture. The check is cheap and read-only; catching a missing changelog entry before the tag costs a moment, while catching it after costs a corrected release and a permanently wrong tag in between.

## What the check looks for

The full model of what "in sync" means, and the specific ways it breaks, lives in `references/sync-model.md`. The catalog of version-bearing files across ecosystems, and how to read each, lives in `references/version-files.md`. Read them when running or explaining the check — the command loads them too. The essence: every substantive change since the last tag should be reflected in *both* a version movement and a CHANGELOG entry, and neither the version nor the changelog should claim a change the other does not.

Two project shapes need care, and the references cover both:

- **Monorepos** where each package carries its own version. The root and every package must be checked, and each version matched to its own changelog section and its own tag pattern.
- **Marketplace-style indexes** where an index file declares versions that must agree with the manifests they point to. A drift between index and manifest is its own kind of desync.

## Acting on the result

The check reports; it never fixes. When it surfaces a mismatch, present it and let the user decide how to close the gap — bump the version, write the changelog entry, or judge that a commit was not user-visible after all. That last judgment is the user's: whether a given change counts as releasable is a product call, not something to resolve silently. Do not bump, write entries, commit, or tag as a reflex of finding a gap; the fix is a separate, user-directed step.

## Resources

- `references/sync-model.md` — What three-way sync means and the common ways it breaks. Read when running or explaining the check.
- `references/version-files.md` — Version-bearing files by ecosystem and how to read each. Read when locating versions, especially in an unfamiliar project or a monorepo.
