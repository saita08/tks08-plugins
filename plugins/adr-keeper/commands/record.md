---
description: Record a directional decision made in this session as an Architecture Decision Record under docs/adr/, following the project's existing ADR conventions if any.
argument-hint: <one-line summary of the decision (optional; inferred from context if omitted)>
allowed-tools: Read, Glob, Grep, Write, Bash
---

# Record an ADR

A directional decision has been made in this conversation — a choice about structure, responsibility, process, or approach that later sessions will need to respect and could otherwise reverse without knowing it was ever settled. Capture it as an Architecture Decision Record so the reasoning outlives this session.

The decision to record is `$ARGUMENTS` if provided. If no argument is given, look back over the recent conversation, identify the directional decision that was just reached, and state it back to the user in one sentence to confirm you have the right one before writing anything.

Before writing, read `${CLAUDE_PLUGIN_ROOT}/skills/adr-guardian/references/adr-format.md` for the standard ADR structure and how to fill each section well. Read `${CLAUDE_PLUGIN_ROOT}/skills/adr-guardian/references/what-to-record.md` if you are unsure whether this decision is even ADR-worthy — a passing implementation choice does not earn a record.

## Procedure

### 1. Find where ADRs live and how they are numbered

Do not assume `docs/adr/`. Discover the project's actual convention first:

```
ls -d docs/adr docs/adrs doc/adr adr .adr 2>/dev/null
```

Also glance for existing records with `Glob` (`**/adr/**/*.md`, `**/*decision*.md`). If the project already keeps ADRs, adopt whatever it already does: its directory, its filename pattern, its numbering width, its section headings, its status vocabulary. A project's established form outranks this plugin's defaults — matching it is the whole point, because a record that does not match the others will not be found where the team looks.

If the project has no ADRs yet, use the default convention: `docs/adr/NNNN-<kebab-slug>.md`, four-digit zero-padded numbers starting at `0001`.

### 2. Determine the next number

Take the highest existing ADR number and add one. If there are none, start at `0001` (or match the width the project uses). Derive a short kebab-case slug from the decision summary for the filename.

### 3. Write the record

Fill the standard sections — Status, Context, Decision, Consequences — following `references/adr-format.md`. The two sections that carry the value are **Context** (the forces and constraints that made this the right call, written so a stranger who was not in the conversation understands *why* — this is what stops a future session from reversing the decision blindly) and **Consequences** (what becomes easier and what becomes harder as a result, honestly, including the costs the team accepted).

Draw the content from what was actually decided and discussed in this session. Do not invent rationale the conversation did not contain; if a section's material is thin, say what is known and leave it honest rather than padding it.

Set `Status: Accepted` for a decision that was actually made and agreed. If it is still proposed and awaiting the user's ratification, use `Status: Proposed` and tell the user it needs their acceptance.

### 4. Confirm and point

After writing the file, tell the user the path and the one-line decision it captured. If this ADR supersedes an earlier one, note that in both records: mark the old one `Superseded by NNNN` and reference the old number from the new one's Status.

## Constraints

- Match the project's existing ADR convention over this plugin's defaults whenever one exists.
- One decision per record. If the conversation settled two independent decisions, write two ADRs rather than blurring them into one.
- Record what was decided, not a fabricated rationale. The Context section is only useful if it is true.
- Do not commit. Writing the file is this command's job; whether and when to commit is the user's.
