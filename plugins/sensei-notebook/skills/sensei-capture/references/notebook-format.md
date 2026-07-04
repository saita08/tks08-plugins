# Notebook Format

The notebook lives at `.claude/sensei-notebook.local.md`, relative to the project root. It is a plain Markdown file so a human can read, review, and edit it directly — that visibility is the point of storing learnings here rather than in a hidden note.

## File shape

Each entry is a small section: the question as a heading, the answer's key points beneath it, and a date. This form is chosen over a table because answers carry a few points that read badly squeezed into a cell.

```markdown
---
plugin: sensei-notebook
---

# Learning Notebook

Concepts explained in this project that were worth keeping. Each entry is a
question the user asked and the gist of the answer that satisfied them, so a
later question in the same area can build on it instead of starting over.

## Q: What is the difference between a hook and a skill?
- A hook is code the harness runs automatically at an event (a stop, an edit); a skill is knowledge Claude loads when relevant.
- A hook fires on timing you do not control; a skill is pulled in by context.
- They often ship together in a plugin: the hook watches, the skill knows what to do.
_2026-07-04_

## Q: Why does the injection cap the number of entries?
- Injected context is spent every session; an unbounded ledger would swell it.
- Capping to the most recent N keeps the freshest, most relevant entries in view.
_2026-07-04_
```

The YAML frontmatter (`plugin: sensei-notebook`) follows the `.claude/<plugin>.local.md` settings convention and marks the file's owner.

## An entry

- **Question** — a level-2 heading beginning `## Q: `, phrased as the user asked it, condensed to the core question. This heading is what you scan when consulting the notebook, so keep it recognizable.
- **Answer gist** — a short bullet list of the key points. Distill; do not transcribe. Three or four bullets that carry the understanding beat a paragraph that reproduces the conversation.
- **Date** — an italic `_YYYY-MM-DD_` line closing the entry, recording when it was captured.

## Appending an entry

New entries go at the **bottom** of the file, after the last existing entry. Order is chronological, which keeps the file's history legible; unlike the injected ledgers, this notebook is read in full when consulted, so position does not affect what gets seen.

## Refining an existing entry

Before adding an entry, look for a heading that already covers the same concept. If one exists, extend or sharpen it — add a missing point, correct an outdated one — rather than adding a second entry for the same concept. One concept, one entry. Duplicates make the notebook slower to consult and dilute its value.

## Creating the file

If `.claude/sensei-notebook.local.md` does not exist when the first entry is confirmed, create it with the frontmatter, heading, and short description shown above, then add the first entry. Create the `.claude/` directory if it is missing.
