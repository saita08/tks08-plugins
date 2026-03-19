# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed
- myrule-review: Added output principles C-7 (lateral check must lead with conclusion) and C-8 (must show extracted pattern per issue) to Constitution
- myrule-review: Lateral check output template updated with Result line and pattern table
- myrule-review: Step 5 simplified to principle-based references, removed specific commands
- myrule-review: Section-level "no issues" instructions split by section type (Major/Reference vs Lateral Check)
- myrule-review: Bumped to v0.2.1

## [1.1.0] - 2026-03-17

### Changed
- team-review-fix: Added Issue Scope principle (C-3) to Constitution — prohibits excluding issues based on confidence scores or section labels
- team-review-fix: Added C-3 violation check to Self-Critique Checkpoints
- team-review-fix: Added Confidence column to summary table for visibility
- team-review-fix: Bumped to v0.3.0
- myrule-review: Constitution restructured from table to concern-based sections (Code Review / Lateral Check / Output)
- myrule-review: C-1 narrowed from "don't read code" to "don't perform code review" — enables lateral checks without contradiction
- myrule-review: C-2 now requires passing review-policy full text to delegate explicitly
- myrule-review: Added lateral check step — searches changed files for additional occurrences of delegate-reported patterns
- myrule-review: Bumped to v0.2.0

## [1.0.10] - 2026-03-09

### Changed
- ai-company-studio: Employee Call Procedure simplified — specifies Agent Teams (TeamCreate + Agent spawn with team_name) as the mechanism, prohibition lists removed in favor of correct procedure only
- ai-company-studio: health check Agent Teams readiness checks simplified to verify correct mechanism is specified
- ai-company-studio: removed redundant spawn restrictions from employee file templates and spawn prompts
- ai-company-studio: bumped to v0.3.1

## [1.0.9] - 2026-03-09

### Changed
- ai-company-studio: Agent Teams is now the assumed runtime (CEO = Team Lead, employees = Teammates)
- ai-company-studio: Employee Call Procedure rewritten as spawn prompt template — explicitly prohibits both CEO role-play and Agent tool subagent usage
- ai-company-studio: inter-employee communication uses Agent Teams direct messages (not CEO relay)
- ai-company-studio: employee files include Collaboration section and spawn restriction in Boundaries
- ai-company-studio: design-principles.md updated for Agent Teams spawn and direct messaging
- ai-company-studio: health check category 1 now includes Agent Teams readiness checks
- ai-company-studio: startup command changed to `claude --agent-teams`
- ai-company-studio: bumped to v0.3.0

## [1.0.8] - 2026-03-09

### Fixed
- ai-company-studio: SKILL.md phase count corrected (5 → 6) to match actual implementation
- ai-company-studio: Phase 4f description now includes growth stage triggers as a required section
- ai-company-studio: CLAUDE.md template standup step 3 aligned with operations.md template wording
- ai-company-studio: bumped to v0.2.1

## [1.0.7] - 2026-03-08

### Added
- ai-company-studio plugin — design and generate AI-only companies as repositories
- ai-company-studio: `/company-health-check` command — diagnose existing AI company repositories with 6-category analysis
- ai-company-studio: `company-health-check` skill — structural integrity, activity, scale alignment, policy health, knowledge management, growth readiness
- ai-company-studio: growth stage triggers in operations.md template ("Signs You're Ready for the Next Stage")

### Changed
- ai-company-studio: governing principles integrated into both skills as constitutional AI behavior (replaces separate Prohibitions sections)
- ai-company-studio: bumped to v0.2.0

## [1.0.6] - 2026-03-06

### Changed
- team-review-fix: Constitution restructured by concern area (Your Role / Task Splitting / Plan Review / Implementation Rules)
- team-review-fix: Plan review changed to streaming — reviews each plan as it arrives instead of waiting for all plans
- team-review-fix: Bumped to v0.2.0

## [1.0.5] - 2026-03-06

### Added
- team-review-fix plugin — delegate review feedback fixes to an agent team with file-based task splitting

## [1.0.4] - 2026-02-11

### Added
- easter-egg plugin — plant delightful easter eggs in your codebase

## [1.0.3] - 2026-02-10

### Added
- myrule-review plugin — custom coding standards code review with local Japanese output

## [1.0.2] - 2026-01-06

### Added
- my-favorite-mcp plugin — frequently used MCP servers collection

## [1.0.1] - 2025-12-31

### Added
- gas-deploy plugin — Google Apps Script deployment management with clasp

## [1.0.0] - 2025-12-31

### Added
- Initial release
