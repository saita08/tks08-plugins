# Versioning Policy

This repository follows [Semantic Versioning](https://semver.org/) with the rules below.

## Version Format

`MAJOR.MINOR.PATCH` (e.g. `v1.0.5`)

## When to Bump

### PATCH (1.0.x)

- Add a new plugin
- Fix or improve an existing plugin
- Update documentation or CHANGELOG

### MINOR (1.x.0)

- Structural changes that affect multiple plugins
- Changes to the marketplace itself (marketplace.json schema, plugin discovery mechanism, etc.)
- Significant milestones (e.g. "all review-related plugins are complete")

### MAJOR (x.0.0)

- Breaking changes to the marketplace or plugin format
- Changes that require users to reinstall or reconfigure plugins

## Tagging and Release

Tags and GitHub Releases are created automatically by CI (`.github/workflows/release.yml`).

When `CHANGELOG.md` is updated on main, CI extracts the latest version and:
1. Creates a git tag `vMAJOR.MINOR.PATCH`
2. Creates a GitHub Release with the changelog section as release notes

Manual tagging is not needed.

## Plugin-Level Versioning

Each plugin has its own version in `.claude-plugin/plugin.json`. Plugin versions are independent of the repository version and follow the same semver rules scoped to that plugin's changes.
