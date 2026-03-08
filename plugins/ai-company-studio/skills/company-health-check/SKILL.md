---
name: company-health-check
description: >
  This skill should be used when the user asks to "check company health",
  "diagnose my AI company", "run a health check", "how's my company doing",
  or wants to evaluate the current state of an existing AI company repository.
  Scans the repository structure, git history, and file contents to produce
  a diagnostic report with actionable next steps.
version: 0.1.0
---

# AI Company Health Check

Diagnostic tool for AI company repositories built by this plugin (or following its conventions).

Scans the repository and outputs a health report to `docs/health-check-{date}.md`.

## Prerequisites

The current working directory (or user-specified path) must be an AI company repository with at minimum:
- `CLAUDE.md`
- `COMPANY.md`
- `members/` directory

If these are missing, inform the user this doesn't appear to be an AI company repository.

## Diagnostic Categories

Run all 6 categories. Each produces a status (Healthy / Warning / Concern) and findings.

---

### 1. Structural Integrity

Check that the company's file structure is consistent and complete.

**Checks:**
- `CLAUDE.md` exists and contains: self-awareness section, organization table, employee call procedure, file reference map
- `COMPANY.md` exists and contains: philosophy, code of conduct, value hierarchy
- Every person listed in CLAUDE.md's organization table has a corresponding file in `members/`
- Every file in `members/` is listed in CLAUDE.md's organization table
- `standards/` contains at least: meeting-rules, deliverables, hiring-policy
- File reference map in CLAUDE.md matches actual directory structure (no dead references, no unlisted directories)
- ROOM.md exists in workspace directories (directories where work happens, not storage like `docs/` or `archive/`)

**Status criteria:**
- Healthy: All checks pass
- Warning: Minor mismatches (e.g., 1 unlisted directory)
- Concern: Missing core files or major inconsistencies

---

### 2. Activity & Freshness

Analyze git history and file dates to understand how active the company is.

**Checks:**
- Last commit date: how recently was the company active?
- `docs/` file count and date of most recent meeting minutes
- Frequency of commits over the last 30 days (if history exists)
- Are there any employees in `members/` who never appear in any `docs/` file? (potentially unused employees)

**Status criteria:**
- Healthy: Activity within the last 7 days
- Warning: Last activity 8-30 days ago
- Concern: No activity for 30+ days, or employees that appear unused

**Note:** Use `git log` for history analysis. If the repo has no git history (not initialized or no commits), note this and skip date-based checks.

---

### 3. Scale Alignment

Check whether the company's structure matches its actual size.

**Checks:**
- Count employees in `members/`
- If 5+ employees: are there department directories? (not required, but worth flagging)
- If department directories exist: does each have 2+ employees assigned?
- If 3-4 employees: are there department directories that might be unnecessary overhead?
- CLAUDE.md line count: is it under 200 lines? (over 200 = CEO wakes up slowly)

**Status criteria:**
- Healthy: Structure matches scale
- Warning: Minor misalignment (e.g., CLAUDE.md is 220 lines)
- Concern: Major mismatch (e.g., 3 employees with 5 department directories)

---

### 4. Policy Health

Check whether policies are being followed and are up to date.

**Checks:**
- `standards/` files: when were they last modified? (never modified since creation = potential concern)
- Meeting minutes format: do they follow the structure defined in `standards/deliverables.md`?
- Are there any meeting minutes? (a company with employees but no meetings is suspicious)
- `standards/operations.md`: does it exist? (companies built before this feature won't have one)

**Status criteria:**
- Healthy: Policies exist and show signs of being used/updated
- Warning: Policies exist but unchanged since creation
- Concern: Missing policies or no meeting minutes at all

---

### 5. Knowledge Management

Check whether the company is building institutional knowledge or just accumulating files.

**Checks:**
- `docs/` file count: more than 10 active meeting minutes? (suggest archival)
- Does `shared/knowledge-base/` or equivalent exist?
- If 10+ meeting minutes exist but no knowledge base: knowledge is trapped in logs
- `archive/` directory: does it exist? Are old files being moved there?

**Status criteria:**
- Healthy: Knowledge base exists and is maintained, archival is happening
- Warning: Many docs but no knowledge base, or no archival
- Concern: 20+ active docs with no organization system

---

### 6. Growth Readiness

Assess whether the company shows signs it needs to evolve.

**Checks (map to "Signs You're Ready for the Next Stage"):**
- Employee count approaching or exceeding current structure's capacity
- If flat structure with 5+ people: likely needs departments
- If no `standards/operations.md`: company may lack operational self-awareness
- Check meeting minutes (if any) for repeated topics or patterns (simple keyword frequency)

**Status criteria:**
- Healthy: Company is operating within its current structure comfortably
- Warning: Some growth signals detected
- Concern: Company has clearly outgrown its structure

---

## Output Format

Generate the report in the user's preferred language (match the language of CLAUDE.md or COMPANY.md).

Write the report to `docs/health-check-{YYYY-MM-DD}.md` with this structure:

```markdown
# Health Check — {date}

## Summary

| Category | Status | Key Finding |
|----------|--------|-------------|
| Structural Integrity | {status} | {one-line summary} |
| Activity & Freshness | {status} | {one-line summary} |
| Scale Alignment | {status} | {one-line summary} |
| Policy Health | {status} | {one-line summary} |
| Knowledge Management | {status} | {one-line summary} |
| Growth Readiness | {status} | {one-line summary} |

## Detailed Findings

### 1. Structural Integrity
{findings}

### 2. Activity & Freshness
{findings}

### 3. Scale Alignment
{findings}

### 4. Policy Health
{findings}

### 5. Knowledge Management
{findings}

### 6. Growth Readiness
{findings}

## Recommended Actions

Priority actions based on findings (max 5). Each action should be:
- Specific (not "improve quality" but "add output format section to members/alice.md")
- Actionable now (not "consider eventually")
- Ordered by impact
```

## Execution Flow

1. Confirm the company repository path with the user
2. Read `CLAUDE.md` and `COMPANY.md` to understand the company
3. Run all 6 diagnostic categories
4. Generate the report and save to `docs/`
5. Present a brief summary to the user with the top 3 findings

## Prohibitions

- Do NOT modify any company files (this is a read-only diagnostic)
- Do NOT make subjective judgments about business strategy or employee design
- Do NOT suggest organizational changes unless structural evidence supports it
- Do NOT generate the report to the plugin directory — always to the company's `docs/`
