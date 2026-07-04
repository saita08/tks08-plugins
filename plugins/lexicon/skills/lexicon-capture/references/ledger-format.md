# Glossary Format

The project glossary lives at `.claude/lexicon.local.md`, relative to the project root. It is a plain Markdown file so a human can read and edit it directly — that visibility is the point of storing agreements here rather than in a hidden note.

## File shape

```markdown
---
plugin: lexicon
---

# Project Glossary

Terms this project has agreed on, so every session speaks the same language.
Each row is one term the user and Claude settled on together.

| Term | Meaning | Agreed in the context of |
| --- | --- | --- |
| ledger | An append-only project file that survives across sessions | while naming the .claude/*.local.md files |
| pluginize | To turn recurring work into a Claude Code plugin | when discussing the pluginize plugin's purpose |
```

The YAML frontmatter (`plugin: lexicon`) follows the `.claude/<plugin>.local.md` settings convention and marks the file's owner. It is optional context, not something the injection hook depends on.

## The table

Three columns, always in this order:

- **Term** — the word or phrase being fixed. Write it as the user uses it.
- **Meaning** — one line, the agreed sense in the user's intent. Not a dictionary definition; the meaning *this project* settled on.
- **Agreed in the context of** — one short line recording what was happening when the agreement was made. This is what lets a future reader judge whether the agreement still applies.

## Appending a row

New rows go at the **bottom** of the table. The injection hook keeps the most recent N rows when the table grows long, and "most recent" means the tail, so appending at the bottom is what keeps the freshest agreements in view.

Write real newlines between rows; keep each entry to a single table row. If a value contains a pipe character (`|`), escape it as `\|` so it does not break the table.

## Updating an existing term

If the table already has a row whose **Term** matches (case-insensitively) the one being recorded, edit that row in place rather than adding a second one. A glossary holds one agreed meaning per term; a later correction supersedes the earlier meaning. Keeping duplicates would inject two conflicting definitions and defeat the purpose.

## Creating the file

If `.claude/lexicon.local.md` does not exist when the first term is confirmed, create it with the frontmatter, the heading, the short description, and the table header shown above, then add the first data row. Create the `.claude/` directory if it is missing.
