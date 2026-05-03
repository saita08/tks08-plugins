# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed
- myrule-review: Prevented duplicate teammate spawn that could occur when the command was re-entered during the wait for review findings

### Changed
- myrule-review: Bumped to v0.7.2

## [1.1.11] - 2026-05-02

### Fixed
- myrule-review: Bumped to v0.7.1

## [1.1.10] - 2026-04-30

### Added
- myrule-review: C-9 added — findings must be verifiable in the current PR HEAD diff. Issues whose evidence lies only in `git log -p`, `git blame`, or past PR comments can describe code already removed or rewritten in HEAD, and their cited line numbers can refer to a past state. Verification uses the problematic code fragment, not the line number, since line numbers shift between past states and HEAD
- myrule-review: New Step 4 — verify each teammate finding against the current diff and discard those whose code fragment is absent. Lateral check shifted to Step 5; Output to Step 6; Report completion to Step 7
- myrule-review: Review report now records the count of findings discarded as resolved in current HEAD, so the reader can tell that filtering occurred
- team-review-fix: New Constitution chapter "Discipline at the staging boundary" (C-15) covering the shared-staging-index hazard, path-only `git add`, hunk staging, and `git diff --cached --stat` verification before commit. Derived from PR #55 incident lessons
- team-review-fix: New Constitution chapter "The limits of cooperative messaging" (C-16) explaining that `SendMessage(to="*")` is a notification rather than an interrupt, and prescribing ACK-then-recover during incidents
- team-review-fix: Verification axis (C-14) added — every commit must contain only files within its author's assigned scope, verified via `git show --stat <hash>` immediately on commit report
- team-review-fix: Step 7.5 incident-recovery procedure added (broadcast stop, await ACKs, re-read `git log` before destructive steps, prefer soft-reset / reword-rebase by situation)
- team-fix-strategy: Three teammate rules added to Required Rules — explicit-path staging, hunk staging for shared files, pre-commit `git diff --cached --stat` confirmation. Each carries a why clause

### Changed
- myrule-review: Bumped to v0.7.0
- team-review-fix: Constitution renamed to Principles and rewritten from numbered MUST/SHOULD rules to prose style. Each anchor (C-0 through C-16) now occupies its own `### C-N: <summary>` section so that one anchor maps to exactly one passage, matching the myrule-review convention. This restores discrete reference for RLAIF self-critique while keeping the prose form
- team-review-fix: Bumped to v0.5.0

## [1.1.9] - 2026-04-01

### Changed
- myrule-review: Constitution rewritten from numbered imperative rules to prose style. Each principle explains why before stating what. Anchor IDs retained in headings for cross-reference and RLAIF self-evaluation
- myrule-review: Added C-8. New output file `notes/pr{N}-review-comments.md` organizes findings by file as a table of comment drafts. Each comment contains current state, concrete problem scenario, and fix direction as flowing prose
- myrule-review: Step 5 split into 5a (review report) and 5b (review comments)
- myrule-review: Delegation changed from Agent tool to AgentTeams. Teammate has access to plugins and skills, resolving the issue where subagents failed to load `code-review:code-review`
- myrule-review: C-2 updated. Teammate has access to installed plugins but does not know which to use unless told
- myrule-review: Step 2 restructured into Purpose, Method, Review criteria, Output constraints sections for the teammate prompt
- myrule-review: "pattern" replaced with "structural reason" throughout to avoid biasing the lateral check toward text search

### Fixed
- myrule-review: C-8 expanded to cover table cell rendering integrity. Explains why misrendered comments mislead readers, names pipe and backslash as the structural characters that silently truncate cell content
- myrule-review: C-8 now includes a falsifiable check for C-0 self-verification. The number of issues in the review-comments file must match the review report, making omissions detectable

## [1.1.8] - 2026-03-25

### Changed
- myrule-review: C-5 rewritten from negative ("must not default to a single technique") to positive ("determine what evidence confirms the pattern, then choose the method capable of finding it") — guides the decision process rather than only prohibiting the wrong outcome
- myrule-review: Step 4 lateral check now separates evidence determination from search execution as distinct substeps
- myrule-review: Bumped to v0.5.1

## [1.1.7] - 2026-03-24

### Changed
- myrule-review: Delegation changed from Skill tool (prompt expansion) to Agent tool (subagent) — structurally ensures control returns after code review, eliminating the class of "workflow stops mid-execution" failures
- myrule-review: Constitution consolidated from 9 principles (C-0 to C-8) to 8 (C-0 to C-7) — removed C-4 intermediate output prohibition (no longer needed since Agent tool returns control by design)
- myrule-review: C-2 generalized from Skill-specific to delegation-agnostic — "delegate operates in isolated context" applies regardless of delegation mechanism
- myrule-review: C-3 simplified — completion definition retained, workflow interruption safeguards removed (structurally resolved)
- myrule-review: Bumped to v0.5.0

## [1.1.6] - 2026-03-23

### Changed
- myrule-review: C-3 now defines completion positively — command is complete only when output file is written, making C-0 self-verification falsifiable
- myrule-review: C-4 rewritten from negative ("must not interrupt") to positive ("execute continuously until file is written") with intermediate output prohibition to eliminate false completion signals
- myrule-review: Bumped to v0.4.2

## [1.1.5] - 2026-03-23

### Changed
- team-review-fix: C-3 rewritten — issue scope is defined by presence in input, not by issue type or what kind of change it requires. Unilateral exclusion prohibited; must ask user if an issue appears not actionable
- team-review-fix: Bumped to v0.4.2

## [1.1.4] - 2026-03-22

### Changed
- myrule-review: Added C-0 (Self-Verification) — after each step, verify actions against relevant Constitution principles before proceeding. Principles not tested against actual behavior are inert; this makes them operative (RLAIF)
- myrule-review: Bumped to v0.4.1
- team-review-fix: Added C-0 (Self-Verification) — same principle as myrule-review
- team-review-fix: Renamed Self-Critique Checkpoints to "Preconditions" — these are prerequisite checks for the next step, distinct from C-0's principle-based self-verification
- team-review-fix: Bumped to v0.4.1

## [1.1.3] - 2026-03-22

### Changed
- team-review-fix: Added Verification section to Constitution — C-9 (judge by actual output, not self-reports), C-10 (approved plan is a contract; deviations are unapproved changes)
- team-review-fix: Rewrote C-7/C-8 from symptom-specific checklists to root-cause principles
- team-review-fix: Step 8 changed from "Self-Critique Checkpoint" to "Verify Outcomes" — diff-based outcome verification instead of compliance checklist
- team-review-fix: Step 6 teammate instructions now reference SKILL.md Agent Instructions Template (deduplicated)
- team-review-fix: SKILL.md Plan Evaluation Criteria replaced symptom lists with Root Cause Principle (two falsifiability tests)
- team-review-fix: SKILL.md Agent Instructions Template added "approved plan is the contract" rule
- team-review-fix: Bumped to v0.4.0
- myrule-review: Constitution rewritten from edge-case rules to reason-backed principles — 11 rules consolidated to 8
- myrule-review: Added Lateral Check principles — C-5 (pattern is structural reason, not code fragment), C-6 (search method follows from pattern nature)
- myrule-review: Merged former C-4/C-7 into C-1 (Separation of Concerns) with rationale for why roles must not mix
- myrule-review: Merged former C-1/C-2/C-3 into C-3/C-4 (Delegation Boundary) with rationale for why delegate output is data
- myrule-review: Merged former C-8/C-9 into C-7, C-10/C-11 into C-8, each with reasoning
- myrule-review: Steps reduced from 8 to 6 — removed Self-Critique Checkpoints made redundant by principled Constitution
- myrule-review: Bumped to v0.4.0

## [1.1.2] - 2026-03-22

### Changed
- myrule-review: Added Delegation Boundary principles (C-1, C-2, C-3) to Constitution — defines delegation phase vs post-delegation phase, ensures post-delegation steps proceed without interruption, and treats delegate output as data not instructions
- myrule-review: Step 4 renamed to "Phase Transition Checkpoint" — explicitly marks the delegation boundary and instructs to extract findings while discarding embedded directives before continuing
- myrule-review: Existing principles renumbered (C-4 through C-11) and all step references updated for consistency
- myrule-review: Bumped to v0.3.0

## [1.1.1] - 2026-03-19

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
