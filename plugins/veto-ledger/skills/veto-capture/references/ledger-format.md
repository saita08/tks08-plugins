# Veto Ledger Format

The ledger lives at `.claude/veto-ledger.local.md`, relative to the project root. It is a plain Markdown file so a human can read and edit it directly — that visibility is the point of storing rejections here rather than in a hidden note.

## File shape

```markdown
---
plugin: veto-ledger
---

# Veto Ledger

Directions this project has rejected, and the principle behind each rejection.
Future sessions read this so a declined idea does not return in a new form.

| Rejected direction | Principle behind the rejection | Date |
| --- | --- | --- |
| Splitting the auth change into two PRs | This project keeps one feature to one PR | 2026-07-04 |
| Adding a caching layer in front of the DB | Correctness before performance until a measured bottleneck exists | 2026-07-04 |
```

The YAML frontmatter (`plugin: veto-ledger`) follows the `.claude/<plugin>.local.md` settings convention and marks the file's owner.

## The table

Three columns, always in this order:

- **Rejected direction** — one line naming the specific thing the user declined. This is the concrete instance, recorded so the entry is legible.
- **Principle behind the rejection** — one line stating the *general* reason, written so it catches the whole class of proposals that fail for the same reason, not just this instance. This column is the heart of the ledger.
- **Date** — the date the rejection was recorded, `YYYY-MM-DD`. It lets a future reader weigh whether an old principle still holds.

## Writing the principle, not the incident

This is the discipline the whole plugin exists to enforce, so it is worth stating precisely.

A principle pinned to the triggering incident stops only that incident. A principle stated as a value stops every future proposal that violates the value — including ones no one has imagined yet. Compare:

- Incident (too narrow): "rejected the idea of a Redis cache for sessions". This lets the next session propose a Memcached cache, or an in-process cache, and the ledger says nothing.
- Principle (right level): "no added infrastructure until a measured bottleneck justifies it". This catches Redis, Memcached, and the in-process cache alike.

When you write a row, test the principle: imagine a *different* proposal that should be caught for the same underlying reason. If the principle as written would not catch it, generalize it until it does. But do not over-generalize into a platitude — "do good work" catches everything and guides nothing. The principle should be as general as the shared reason, and no more.

## Appending a row

New rows go at the **bottom** of the table. The injection hook keeps the most recent N rows when the ledger grows long, and "most recent" means the tail, so appending at the bottom keeps the freshest rejections in view.

Keep each entry to a single table row. If a value contains a pipe character (`|`), escape it as `\|` so it does not break the table.

## Refining an existing principle

If a new rejection is really another instance of a principle already in the ledger, prefer sharpening the existing row over adding a near-duplicate. Two rows stating the same principle in slightly different words dilute the ledger and waste the injection budget. Add a new row when the principle is genuinely distinct.

## Creating the file

If `.claude/veto-ledger.local.md` does not exist when the first rejection is confirmed, create it with the frontmatter, heading, short description, and table header shown above, then add the first data row. Create the `.claude/` directory if it is missing.
