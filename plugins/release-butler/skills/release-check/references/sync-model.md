# The Three-Way Sync Model

A release is honest when three artifacts agree about the same set of changes:

1. **The code** — what actually changed since the last release.
2. **The version** — the number that names this release, in whatever file the ecosystem carries it.
3. **The CHANGELOG** — the human-readable statement of what changed, that users read to decide whether to upgrade.

"In sync" means: every substantive change in the code since the last tag is reflected in a version movement *and* a changelog entry, and neither the version nor the changelog asserts a change the others do not support. When the three agree, the tag CI generates matches the reality it claims to describe. When they disagree, the tag lies — and a lying tag is not a bug you can fix later, because the tag and its release are immutable history once CI writes them.

## Why the desync is dangerous specifically

The damage is not that a step was skipped. It is that the skip is *silent and permanent*. Nothing errors when the version and the changelog disagree; the release simply ships mislabeled, and the mislabeling is baked into a tag and a GitHub release that others may already have installed, cached, and depended on before anyone notices. The whole point of checking before the release is that this is the last moment the correspondence can be fixed cheaply. After the tag, it can only be patched, never corrected.

## The common ways it breaks

Each of these is a distinct mismatch worth reporting on its own:

- **Code moved, version did not.** Real commits since the last tag, but the version file still reads the tagged number. A release now would ship new behavior under the old version — users pin to a number that no longer means what they think.
- **Code moved, changelog silent.** Changes exist, but nothing under `[Unreleased]` or the latest section describes them. Users get behavior the changelog never mentions, which is exactly the surprise a changelog exists to prevent.
- **Changelog claims a change, version did not move.** Entries were written but the bump was forgotten. The changelog promises a release that the version says did not happen.
- **Version moved, changelog silent.** A bump with no documentation of what it contains. A number changed for reasons no user can discover.
- **A version-and-date heading committed for unreleased work.** A `## [1.4.0] - 2026-03-01` section written while the change is still unreleased. This pre-commits two decisions the release step owns — the version and the date — and the date in particular will almost always be wrong by the time the change actually ships. Where the project's discipline is to keep entries under `## [Unreleased]` until release, a premature dated heading is a desync in waiting: CI may read it as the release version, tagging the wrong number on the wrong day. Flag it against the project's own convention.
- **Version files disagree with each other.** Two files that should share a version but hold different ones. Most common in monorepos, and in marketplace indexes where an index entry's declared version drifts from the manifest it points to.

## What counts as a "substantive" change

Not every commit since the tag demands a version bump and a changelog line. A typo fix in a comment, a test-only change, a CI tweak — these may legitimately ride along without a user-facing entry. This is exactly where the check must *not* assert a verdict. Whether a given change is user-visible enough to require an entry is a product judgment that belongs to the user. The check's job is to surface "here are the commits since the tag, and here is what the changelog covers" and let the user decide where the line falls — not to declare a violation on a change that was correctly silent. Reporting a false desync trains the user to ignore the checker, which loses the real desyncs too.

## Following the project's own discipline

A project often documents its own release rules — a `docs/versioning.md`, a `CONTRIBUTING` section, a `CHANGELOG.md` that states where unreleased entries go. When it does, that discipline outranks the generic model here. Read it and check against it: which version component to bump, where unreleased entries live, whether the changelog speaks to users or maintainers, how the tag is derived. The generic model is the fallback for a project that has not written its rules down; a project that has written them down has already decided, and the check's job is to hold it to its own decision.
