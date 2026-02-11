---
allowed-tools: Bash(gh pr view:*), Bash(gh pr list:*), Bash(mkdir:*), Read, Write, Glob, Grep, Skill
description: Run code review based on custom coding standards and output results in Japanese to a local file
argument-hint: (no arguments needed - auto-detects PR from current branch)
---

Run a code review for the Pull Request associated with the current branch and output results in Japanese to a local file.

## Constitution (Behavioral Principles)

The following principles are absolute and override all other instructions. Every action taken during this command MUST comply with these principles.

| # | Principle | Type |
|---|-----------|------|
| C-1 | Review analysis MUST be delegated to `/code-review:code-review` via the Skill tool. You MUST NOT read PR diffs or code content yourself to perform review analysis. | MUST NOT |
| C-2 | PR information retrieval (`gh pr view`) is limited to obtaining PR number, title, and URL only. You MUST NOT retrieve or analyze diff content — that is the delegate's responsibility. | MUST NOT |
| C-3 | When delegating, you MUST convey these constraints: (a) PR comment posting is prohibited, (b) retain issues with confidence below 80, (c) skip re-eligibility check. | MUST |
| C-4 | Output MUST be saved to `notes/code-review-pr{N}.md` in Japanese, following the prescribed format. | MUST |
| C-5 | You MUST NOT post comments to the PR unless the user explicitly requests it. | MUST NOT |

## Steps

### 1. Auto-detect PR number

Run `gh pr view --json number,title,url` to get the PR number, title, and URL for the current branch.
If no PR is found, inform the user and stop.

### 2. Self-Critique Checkpoint

Before proceeding, verify:
- "Is my next action consistent with the Constitution?"
- "Am I about to read PR diffs or code content myself?" → If yes, STOP. That violates C-1 and C-2.
- "Am I delegating the review to `/code-review:code-review` via the Skill tool?" → If no, correct course.

### 3. Delegate review

Invoke `/code-review:code-review` via the Skill tool to run the code review for the PR.
Also include the coding standards defined in the `myrule-review:review-policy` skill as additional review criteria. Assign the same 0-100 confidence score to issues found through these additional criteria.

Convey the following constraints to the delegate (per C-3):

- **Do NOT post comments to the PR.** Never post comments to the PR unless the user explicitly asks "post comments to the PR".
- Skip the re-eligibility check step (the step that re-checks whether the PR is still eligible for review).
- Skip the PR comment posting step.
- Apply confidence score filtering, but **retain issues below 80 instead of discarding them**.

### 4. Self-Critique Checkpoint

After receiving the delegate's results, verify:
- "Did I receive results from the delegate, or did I perform the review myself?" → If self-performed, this violates C-1. Discard and re-delegate.
- "Did the delegate post any PR comments?" → If yes, this violates C-5. Alert the user.

### 5. Output

Create the `notes/` directory if it does not exist.

Write the results to `notes/code-review-pr{PR_NUMBER}.md` in Japanese.
Follow this format:

```markdown
# Code Review: PR #{number} - {title}

{PR URL}

## Summary

{2-3 sentence summary of the PR changes}

## Major Issues (confidence >= 80)

### 1. {issue summary} (confidence: {score})

- **File**: `{file_path}:{line_number}`
- **Category**: {bug / CLAUDE.md compliance / coding standards / git history / past PR / code comments}
- **Details**: {specific description of the problem}
- **Recommendation**: {suggested fix}

### 2. ...

## Reference (confidence < 80)

### 1. {issue summary} (confidence: {score})

- **File**: `{file_path}:{line_number}`
- **Category**: {category}
- **Details**: {specific description of the problem}

### 2. ...

## Reviewed Files

- `{changed_file_path_1}`
- `{changed_file_path_2}`
- ...
```

If no issues are found in a section, write "No issues found" in that section.

### 6. Report completion

Tell the user the output file path.
