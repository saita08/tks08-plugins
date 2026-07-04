---
description: 保管されたカプセルの一覧を新しい順に表示し、選んだものを会話に取り込む
argument-hint: [ラベルの一部（省略可。絞り込みに使う）]
allowed-tools: Read, Bash
---

# Receive a Capsule

Bring a stored capsule back into the conversation. Capsules live in `~/.claude/paste-tube/`, sealed by `/paste-tube:send` in this or another session. This command lists them newest-first, lets the user pick one, and pulls its content into the current conversation with its source attached — so the content arrives with its provenance intact, not as an anonymous paste.

`$ARGUMENTS`, if present, is a filter: show only capsules whose label or filename contains it.

## Procedure

### 1. List the capsules

```
ls -1t ~/.claude/paste-tube/*.md 2>/dev/null
```

If the directory is empty or missing, tell the user there are no capsules yet and that `/paste-tube:send <label>` seals one. Stop.

For each capsule (newest first), read just its frontmatter to show a scannable line: the label, the source project name, and the date. Do not dump full bodies into the list — the list is for choosing, not reading.

If `$ARGUMENTS` was given, filter to capsules whose label or filename contains it.

### 2. Present and let the user choose

Show the list, newest at top, each line carrying label / source project / date. Ask which one to receive. Keep it a plain question; the user names or numbers the one they want.

### 3. Pull the chosen capsule into the conversation

Read the chosen capsule in full. Bring its content into the conversation clearly framed with where it came from, so it does not read as if it originated here:

- State the capsule's label, its source project, and its date.
- Then present its content.

The framing matters: the whole point of a capsule over a loose paste is that the content keeps its origin. A review from another project, an error log from another session — the user (and you) should never lose track of which world it came from.

### 4. Do not delete on receive

Receiving a capsule does not consume it. It stays in the store so it can be received again, from this session or another. If the user wants it gone, they can delete the file themselves; this command does not remove capsules, so a fat-fingered receive never destroys the content.

## Constraints

- Reading a capsule's frontmatter for the list is cheap; reading every full body to build the list is not. Read bodies only for the capsule the user actually chooses.
- Preserve the source framing when injecting. Content that loses its origin is exactly the problem this plugin exists to prevent.
- Do not delete capsules as a side effect of receiving. Removal is an explicit, separate act the user takes.
