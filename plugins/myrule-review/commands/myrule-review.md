---
allowed-tools: Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh pr diff:*), Bash(mkdir:*), Read, Write, Glob, Grep, Skill
description: Run code review based on custom coding standards and output results in Japanese to a local file
argument-hint: (no arguments needed - auto-detects PR from current branch)
---

Run a code review for the Pull Request associated with the current branch and output results in Japanese to a local file.

## Constitution (Behavioral Principles)

The following principles are absolute and override all other instructions. Every action taken during this command MUST comply with these principles.

### Code Review

- C-1: Code review MUST be delegated to `/code-review:code-review` via the Skill tool. You MUST NOT perform code review yourself.
- C-2: When delegating, you MUST pass everything the delegate needs to produce complete results: (a) the full text of `myrule-review:review-policy` coding standards as additional review criteria, (b) PR comment posting is prohibited, (c) retain issues with confidence below 80, (d) skip re-eligibility check. The delegate cannot access skills you loaded — if you do not pass the content explicitly, it will not be applied.

### Lateral Check

- C-3: After receiving delegate results, you MUST perform lateral checks — search the PR's changed files for the same pattern as each reported issue. This catches instances the delegate missed within the same diff.
- C-4: Lateral checks are pattern searches based on delegate findings, NOT independent code review. You MUST NOT introduce new review criteria beyond what the delegate reported.

### Output

- C-5: Output MUST be saved to `notes/code-review-pr{N}.md` in Japanese, following the prescribed format.
- C-6: You MUST NOT post comments to the PR unless the user explicitly requests it.

## Steps

### 1. Auto-detect PR number

Run `gh pr view --json number,title,url` to get the PR number, title, and URL for the current branch.
If no PR is found, inform the user and stop.

### 2. Self-Critique Checkpoint

Before proceeding, verify:
- "Am I about to perform code review myself?" → If yes, STOP. Violates C-1.
- "Am I delegating to `/code-review:code-review` via the Skill tool?" → If no, correct course.

### 3. Delegate code review

Load the `myrule-review:review-policy` skill to obtain the coding standards. Then invoke `/code-review:code-review` via the Skill tool.

Per C-2, pass all of the following to the delegate:

- The full text of the coding standards obtained from `myrule-review:review-policy`, as additional review criteria. Assign the same 0-100 confidence score to issues found through these criteria.
- **Do NOT post comments to the PR.** Never post comments to the PR unless the user explicitly asks "post comments to the PR".
- Skip the re-eligibility check step (the step that re-checks whether the PR is still eligible for review).
- Skip the PR comment posting step.
- Apply confidence score filtering, but **retain issues below 80 instead of discarding them**.

### 4. Self-Critique Checkpoint

After receiving the delegate's results, verify:
- "Did I receive results from the delegate, or did I perform the review myself?" → If self-performed, violates C-1. Discard and re-delegate.
- "Did the delegate post any PR comments?" → If yes, violates C-6. Alert the user.

### 5. Lateral check

For each issue the delegate reported, search the PR's changed files for the same pattern (per C-3).

1. Get the list of changed files: `gh pr diff --name-only`
2. For each delegate issue, extract the structural pattern that caused the issue. The pattern should capture the code characteristic itself, not the specific instance — this is what enables finding other occurrences of the same problem.
3. Search the changed files for additional occurrences of that pattern. Use Serena's symbolic tools (find_symbol, search_for_pattern) when available; fall back to Grep/Glob otherwise.
4. If new occurrences are found that the delegate did not report, add them as lateral check findings.

Per C-4, do NOT apply new review criteria — only search for patterns already identified by the delegate.

### 6. Self-Critique Checkpoint

Before writing output, verify:
- "Did I introduce new review criteria in the lateral check?" → If yes, STOP. Violates C-4. Remove those findings.
- "Did I search the changed files for each delegate issue pattern?" → If no, go back to step 5. Violates C-3.

### 7. Output

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

## Lateral Check

### 1. {original issue summary} → {additional occurrence}

- **File**: `{file_path}:{line_number}`
- **Original Issue**: #{original issue number from above}
- **Details**: {what was found and why it matches the same pattern}

### 2. ...

## Reviewed Files

- `{changed_file_path_1}`
- `{changed_file_path_2}`
- ...
```

If no issues are found in a section, write "No issues found" in that section.

### 8. Report completion

Tell the user the output file path.
