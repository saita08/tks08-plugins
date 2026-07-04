---
description: 用語と定義を明示的にプロジェクトの用語辞書へ登録する
argument-hint: <用語>: <定義>（例: ledger: セッションを跨いで残る追記専用のプロジェクトファイル）
allowed-tools: Read, Edit, Write
---

The user wants to register a term in the project glossary directly, without waiting for a correction to surface it in conversation.

The requested entry is:

$ARGUMENTS

## What to do

1. Parse the argument into a **term** and a **meaning**. The usual form is `term: meaning`. If the argument is empty or you cannot tell the term from the meaning, ask the user for the term and its meaning in one short question, then continue.

2. For the **context** column, use a brief note of what the user is currently working on, or if that is unclear, a short phrase like "registered directly by the user". Do not block on this — one line is enough.

3. Append the entry to `.claude/lexicon.local.md`, following the format in `${CLAUDE_PLUGIN_ROOT}/skills/lexicon-capture/references/ledger-format.md`:
   - Create the file with its frontmatter, heading, and table header if it does not exist.
   - New rows go at the bottom of the table.
   - If a row for the same term already exists (case-insensitively), update it in place instead of adding a duplicate — a later definition supersedes the earlier one.
   - Escape any literal `|` in the values as `\|`.

4. Confirm in one line that the term is recorded, showing the row you wrote. Do not restate the whole glossary.

Because the user asked for this explicitly, no separate approval step is needed — the invocation is the approval. Everything else follows the same discipline as the skill: one meaning per term, one line each, stored in the visible project file.
