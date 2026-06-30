# Teammate Rules

This document is read by the fellow during the dispatch step and passed verbatim to every teammate inside their initial SendMessage. The teammate is the audience here, not the fellow. The fellow's job is to copy the rules into the teammate's instructions; the teammate's job is to follow them while working on the assigned files. The fellow does not paraphrase or summarise — the wording of each rule is what carries the discipline, and a paraphrase loses the "why" clauses that teach when the rule applies.

## Required Rules for Teammates

1. **Plan before implementation** — present your fix plan and wait for explicit approval before writing any code
2. **The approved plan is the contract** — if you discover during implementation that the approach needs to change, stop and re-submit a revised plan. Do not implement unapproved changes, even if you believe they are improvements
3. **If plan is rejected**, revise based on the feedback and re-submit — do not implement the rejected plan
4. **Commit after each fix** with a commit message that describes what was fixed and why
5. **Do NOT add Co-Authored-By trailer** to commit messages
6. **Commit with explicit paths** — use `git commit -- <path> [<path>...]` instead of bare `git commit`. Why: all teammates share one staging index, and bare `git commit` takes everything in the index — including foreign files added by another teammate in the instant between your stage and your commit. Path-limited commit closes this race structurally, regardless of what else sits in the index
7. **Stage by explicit path only** — never `git add .`, `git add -A`, or `git commit -a`. Why: even with path-limited commit (rule 6), wildcard staging fills the shared index with files you do not own, which makes another teammate's path-limited commit harder to construct and your own pre-commit verification noisier
8. **Use `git add -p` for files that other teammates may also touch** — stage by hunk so that only your changes enter the index. Why: file-level assignment is not a guarantee against cross-cutting edits to shared files (e.g., a common types module)
9. **Run `git diff --cached --stat` immediately before every commit** — confirm only files you own are staged; remove anything foreign with `git restore --staged <path>`. Why: defense in depth on top of rule 6 — the path-limited commit is the load-bearing rule, this check is the second line that catches mistakes in the path list itself
10. **Report each commit with its hash** — run `git rev-parse HEAD` immediately after committing and include the hash in your report to the fellow. Why: the fellow verifies your work via `git show --stat <hash>`, and a report without a hash forces the fellow to guess which entry in `git log` you meant — a guess that becomes wrong the moment any teammate commits in the interval
11. **Re-observe `git log -1` before resuming after any incident** — if the fellow has performed a reset, rebase, or reword, the hash you previously reported may no longer exist. Do not trust your memory of where HEAD was; read it again. Why: teammates who treat their last-observed state as still current will report completion against a commit that has been rewritten or discarded
12. **Run the verification command the fellow specified, not your default** — if the fellow names a command (e.g., `tsc -b` rather than `tsc --noEmit`), use it verbatim. Why: project-specific environments make generic commands silently skip what needs checking, and the fellow has already chosen the command that exercises the relevant code path

## Investigation Approach for Teammates

1. Read the relevant file(s) to understand the current code
2. Verify the issue actually exists (it may have been fixed already)
3. Understand the surrounding context — what calls this code? What does it depend on?
4. Identify the root cause: why does this problem exist?
5. Present the plan with: what you found, what you will change, and why this eliminates the root cause
