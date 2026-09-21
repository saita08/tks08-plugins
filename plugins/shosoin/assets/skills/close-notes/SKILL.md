---
name: close-notes
description: Closes a task's notes by promoting what deserves a durable shelf and deleting the rest. Use when a task is closing — its pull request is merging, its feature has landed, its handover has been picked up — and notes/ holds what the task left behind. Triggers on "close the task", "clean up the notes", "the PR is merged", "wrap this up".
---

# Close a task's notes

When this is done, `notes/` holds nothing from the closed task, and what was worth keeping lives on the shelf where its next reader will look.

1. List the files in `notes/` that belong to the closing task. Notes of tasks still open are left alone.
2. Read each file and sort what it holds: a choice and its reasons go to `adr/` through `write-adr`; a convention or a description of what now exists goes to a `docs/` page; steps go to a skill in `.claude/skills/`; raw data goes to `references/`. Everything else has no destination.
3. Show the owner two lists — what will be promoted and where, and what will be deleted — and wait for their answer. What a note means is theirs to say.
4. Promote by writing the content on its destination shelf in that shelf's form, and update the shelf's index. A note file is never moved onto a durable shelf as it is.
5. Delete the task's note files with `git rm`.

Verify: `grep -rn "notes/" README.md CLAUDE.md docs adr .claude/skills` shows no link into `notes/`.

The rule these steps serve: the contract section of [CLAUDE.md](../../../CLAUDE.md).
