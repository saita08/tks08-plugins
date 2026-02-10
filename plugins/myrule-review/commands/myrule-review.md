---
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr list:*), Bash(gh issue view:*), Bash(gh search:*), Bash(mkdir:*), Read, Write, Glob, Grep, Task
description: Run code review based on custom coding standards and output results in Japanese to a local file
argument-hint: (no arguments needed - auto-detects PR from current branch)
---

Run a code review for the Pull Request associated with the current branch and output results in Japanese to a local file.

## Steps

### 1. Auto-detect PR number

Run `gh pr view --json number,title,url` to get the PR number, title, and URL for the current branch.
If no PR is found, inform the user and stop.

### 2. Run review

Invoke `/code-review:code-review` via the Skill tool to run the code review for the PR.
Also include the coding standards defined in the `myrule-review:review-policy` skill as additional review criteria. Assign the same 0-100 confidence score to issues found through these additional criteria.

Override the following behaviors:

- **Do NOT post comments to the PR.** Never post comments to the PR unless the user explicitly asks "post comments to the PR".
- Skip the re-eligibility check step (the step that re-checks whether the PR is still eligible for review).
- Skip the PR comment posting step.
- Apply confidence score filtering, but **retain issues below 80 instead of discarding them**.

### 3. Output

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

### 4. Report completion

Tell the user the output file path.
