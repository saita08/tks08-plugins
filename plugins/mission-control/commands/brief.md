---
description: Brief you on stalled PRs, failing CI, and pending reviews across your repositories, gathered into one morning report.
argument-hint: "[追加で見たいリポジトリ owner/repo（省略可、複数可）]"
allowed-tools: Bash, Read, Glob
---

# Mission Control Brief

Gather a single situational briefing across the user's repositories: which pull
requests are stalled, where CI is failing, and what is waiting on their review.
The goal is to replace a manual morning round of clicking through several repos
with one report they can read in a glance.

## 1. Decide which repositories to cover

Look for a project settings file at `.claude/mission-control.local.md` in the
current directory. If it exists, read its YAML frontmatter for a `repos:` list
(entries are `owner/repo`). Those are the repositories to cover.

If the file is absent or lists no repos, cover only the current repository. Do
not guess or expand beyond that — surveying repositories the user did not name
is both slow and surprising.

If the invocation included arguments, treat each as an additional `owner/repo`
to cover on top of whatever the settings file resolved to.

An example settings file:

```markdown
---
repos:
  - tks08/tks08-plugins
  - tks08/some-service
# webhook: https://hooks.slack.com/services/...   # optional, shared with the notify hook
---

Notes for humans can live here in the markdown body.
```

## 2. Check prerequisites cheaply

Confirm `gh` is available and authenticated with one quick call (for example
`gh auth status`). If it is not, say so plainly and stop — this command is a
thin front-end over the GitHub CLI and cannot do its job without it. Do not try
to install or authenticate anything on the user's behalf.

For the current repository (no `owner/repo` needed), `gh` commands work as-is.
For each named `owner/repo`, pass `--repo owner/repo`.

## 3. Gather the three signals per repository

For each repository in scope, gather these with `gh`. Keep each call bounded so
the briefing stays fast even across several repos:

- **Stalled PRs** — open PRs, oldest first, so the ones rotting at the top of
  the list surface. For example:
  `gh pr list --state open --limit 30 --json number,title,author,updatedAt,isDraft,reviewDecision`
- **Failing CI** — for the open PRs, whether their checks are red. `gh pr checks <number>`
  reports check state for a PR; sample the open PRs rather than every historical
  run. `gh run list --limit 10 --json conclusion,name,headBranch,event` gives a
  recent workflow-run view when you want branch-level CI health.
- **Waiting on review** — PRs where review is requested from the user, or where
  `reviewDecision` is `REVIEW_REQUIRED`. `gh pr list --search "review-requested:@me"`
  narrows to the ones actually pointed at the user.

Do not modify anything. This command only reads: no merging, closing,
commenting, or re-running of workflows.

## 4. Assemble one briefing

Write a single, scannable briefing in the user's language. Lead with what needs
attention, not with a repo-by-repo data dump. A workable shape:

- A one-line headline: the total counts that matter (stalled PRs, red CI,
  reviews waiting).
- **Needs your review** — PRs pointed at the user, each as `owner/repo #123 —
  title (author, age)`.
- **CI is red** — PRs or branches with failing checks, with the failing check
  named where cheap to include.
- **Stalled** — open PRs untouched for a while (say, several days), oldest
  first, so the ones drifting out of memory surface.

Omit a section entirely when it is empty. If everything is clean, say so in one
line rather than printing three empty headings — a quiet morning is a valid
report.

## 5. Offer to post it, only if a webhook is configured

If `.claude/mission-control.local.md` carries a `webhook:` line (the same one
the notify hook uses), offer to post the briefing to Slack, and post it only if
the user says yes. If no webhook is configured, do not mention Slack at all —
this stays a read-only local report unless the user has opted in to the channel.

## Running it every morning

This command pairs naturally with a scheduler: point Claude Code's built-in
`/schedule` (or any cron that runs `claude`) at `/mission-control:brief` to get
the briefing each morning without asking. This plugin does not ship a scheduler
of its own; it provides the briefing and leaves the timing to yours.

## Constraints

- Read-only. Never merge, close, comment, re-run, or otherwise change state on
  GitHub.
- Cover only the repositories that were resolved from settings, the current
  repo, or explicit arguments. Do not survey repos the user did not name.
- Post to Slack only on an explicit yes, and only when a webhook is already
  configured. Never post unprompted.
- If `gh` is missing or unauthenticated, report that and stop rather than
  attempting to set it up.
