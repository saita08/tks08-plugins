---
description: List the project's Architecture Decision Records with their numbers, titles, and statuses.
argument-hint: [filter, e.g. a status like "accepted" or a keyword (optional)]
allowed-tools: Read, Glob, Grep, Bash
---

# List ADRs

Show the user the Architecture Decision Records the project already holds, so they can see what has been decided before deciding again — or before this session risks reversing something.

## Procedure

### 1. Locate the ADRs

Find where records live without assuming a fixed path:

```
ls -d docs/adr docs/adrs doc/adr adr .adr 2>/dev/null
```

Also sweep with `Glob` for `**/adr/**/*.md` and any `**/*decision-record*.md`. If no ADRs exist anywhere, say so plainly and mention that `/adr-keeper:record` can start the first one. Do not create anything here — listing is read-only.

### 2. Read the headers, not the whole files

For each record, read only enough to extract its number, title, status, and date. The Status line and the title heading are near the top; do not load entire ADR bodies just to list them.

### 3. Present the list

Show the records ordered by number, oldest to newest. For each: its number, its title, and its status. Keep statuses visible — a reader scanning for what is in force needs to see at a glance which records are Accepted, which are Proposed, and which are Superseded (and by what).

If `$ARGUMENTS` was given, use it to filter — by status (show only Accepted, say) or by keyword in the title. Otherwise show them all.

### 4. Surface superseded chains

Where one ADR supersedes another, make that relationship visible in the listing rather than showing the two as unrelated rows. A reader needs to know that decision 0003 replaced 0001, not just that both exist.

## Constraints

- Read-only. This command never writes, renumbers, or edits a record.
- Do not read full ADR bodies to build the list; headers are enough and keep the command fast.
