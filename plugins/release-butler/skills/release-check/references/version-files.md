# Version-Bearing Files by Ecosystem

To check that the version moved, you first have to find where the version lives. It lives in a different file in every ecosystem, and a project may hold several. This is the catalog to sweep, how to read each, and how to handle the multi-version cases.

## The catalog

| Ecosystem | File | Where the version is |
|---|---|---|
| Node / npm | `package.json` | `"version"` field |
| Claude Code plugin | `.claude-plugin/plugin.json` or `plugin.json` | `"version"` field |
| Python | `pyproject.toml` | `[project] version` or `[tool.poetry] version` |
| Python (legacy) | `setup.py`, `setup.cfg`, `__init__.py` | `version=` / `__version__ =` |
| Rust | `Cargo.toml` | `[package] version` |
| PHP | `composer.json` | `"version"` (often absent; may be tag-driven) |
| Ruby | `*.gemspec`, `lib/**/version.rb` | `spec.version` / `VERSION =` |
| Java (Gradle) | `build.gradle`, `gradle.properties` | `version` |
| Java (Maven) | `pom.xml` | `<version>` |
| Go | `git tag` (no version file by convention) | the tag itself |
| Generic | `VERSION`, `version.txt` | the file's contents |

Use `Glob` to find these rather than assuming which ecosystem the project is. A repository can mix several (a Node package with a Python tool alongside it), and each carries its own version to check.

Read only the small slice of each file that holds the version — the field, not the whole manifest. For TOML and JSON, the version is a named field near the top; there is no need to parse the entire file.

## Multi-version projects

**Monorepos.** Many repositories carry a version per package: a root manifest plus one under each `packages/*`, `plugins/*`, `crates/*`, or workspace member. When checking a monorepo:

- Enumerate every version-bearing file, and keep each version bound to its package. Do not collapse them into one "the version" — a monorepo has many, and a release usually moves only some.
- Match each package to its own changelog (a per-package `CHANGELOG.md`, or a section in a shared root changelog) and to its own tag pattern where the project uses per-package tags like `pkg-name-v1.2.3`.
- A change under one package should move that package's version and that package's changelog — not a sibling's. Reporting a sibling as out of sync because an unrelated package changed is a false positive.

**Index/manifest pairs.** Some projects keep an index file that declares versions for artifacts defined elsewhere — a plugin marketplace index listing plugins whose real manifests hold their own versions, a workspace catalog, a lockfile. Here the desync to watch is the index disagreeing with the manifest it points to: the index claims one version, the manifest another. When you find an index like this, check that its declared versions match the source-of-truth manifests, and flag any drift as its own mismatch.

## Reading the last released version

The version files tell you the *current* version. To know whether it *moved*, compare against the last release. The git tag is usually the anchor:

```
git describe --tags --abbrev=0
```

gives the most recent tag; comparing the current version-file value against it tells you whether a bump has happened since. In per-package-tag monorepos, filter tags to the package's pattern rather than taking the repo-wide latest, or the comparison will anchor on the wrong release. When there are no tags at all, there is no prior release to compare against — report that plainly and fall back to the version-vs-changelog checks, which still work without a tag.
