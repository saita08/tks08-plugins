---
description: 直前の会話内容や指定内容を、出典つきのカプセルとして ~/.claude/paste-tube/ に保管する（別セッションへ持ち出せる）
argument-hint: <ラベル> — カプセルの短い名前（何を運ぶかがわかる語）
allowed-tools: Read, Write, Bash
---

# Send a Capsule

Take a piece of content — the report you just pasted, a review result, an error log, something worth carrying to another session — and seal it in a capsule with its source and date, so it does not vanish when this conversation scrolls away. The capsule lands in `~/.claude/paste-tube/`, a machine-level store any session on this machine can later receive from.

The label is required: it is how the capsule is recognized later in a list. `$ARGUMENTS` holds it.

## What is captured

Capture the content the user means to carry. In order of preference:

1. If the user pointed at something specific (a pasted block, a named file, "this error log above"), capture exactly that.
2. Otherwise, capture the most recent substantive content in the conversation that fits the label — the report, log, or result the label names.

Do not editorialize or summarize the content into your own words. A capsule carries the thing itself, verbatim, so the receiving session sees what was actually said. If the content is genuinely long, capture it in full anyway; the capsule's job is fidelity, not brevity.

## Capsule format

A capsule is a Markdown file with YAML frontmatter recording where it came from. The frontmatter is what makes a capsule more than a loose paste: the receiving session, and the user reading a list months later, can see the origin.

```markdown
---
label: <the label from $ARGUMENTS>
source_project: <the current project directory, absolute path>
source_project_name: <the basename of the project directory>
created: <YYYY-MM-DD HH:MM>
---

<the captured content, verbatim>
```

## Procedure

### 1. Require a label

If `$ARGUMENTS` is empty, ask the user for a short label and stop. A capsule without a label is unfindable later.

### 2. Gather metadata

```
date '+%Y-%m-%d %H:%M'
```

Use the current working directory as `source_project` (its basename as `source_project_name`).

### 3. Build the capsule path

Capsules live in `~/.claude/paste-tube/`. The filename is the timestamp plus a slugified label, so it sorts newest-last by name and is human-scannable:

```
mkdir -p ~/.claude/paste-tube
```

Filename: `<YYYYMMDD-HHMM>-<slug>.md`, where `<slug>` is the label lowercased with spaces and unsafe characters replaced by hyphens.

### 4. Write the capsule

Write the frontmatter and the verbatim content to the file.

### 5. Confirm briefly

Tell the user the capsule was sealed, its label, and that it can be received from another session with `/paste-tube:receive`. One line.

## Constraints

- Capture content verbatim. Do not paraphrase or summarize — the capsule's value is that the other session sees the original.
- Never write a secret into a capsule if you can avoid it. Capsules persist in `~/.claude/` on this machine. If the content the user is carrying contains a credential, flag it to the user before sealing rather than silently persisting it — deletion from disk does not guarantee erasure.
- Do not send content to any external service. A capsule is a local file. Carrying it elsewhere is the user's move, not this command's.
