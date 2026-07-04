---
description: 却下された方向とその軸(原則)を供養帳に手動で記録する
argument-hint: <却下された方向> | <却下の軸（原則）>（軸は個別事例でなく原則で書く）
allowed-tools: Read, Edit, Write
---

The user wants to record a rejection in the veto ledger directly, without waiting for it to surface in conversation.

The requested entry is:

$ARGUMENTS

## What to do

1. Parse the argument into a **rejected direction** and a **principle**. The usual separator is `|` (direction on the left, principle on the right). If only one part is given, treat it as the direction and derive the principle from context; if you cannot, ask the user for the principle in one short question.

2. Check the principle before writing. The ledger's value is that the principle catches the *class* of proposals, not just this instance. If the given principle only describes the one rejected direction, generalize it to the shared reason — or ask the user what the underlying reason is. See `${CLAUDE_PLUGIN_ROOT}/skills/veto-capture/references/ledger-format.md` for how to write a principle rather than an incident.

3. Append the entry to `.claude/veto-ledger.local.md`, following that format, with today's date:
   - Create the file with its frontmatter, heading, and table header if it does not exist.
   - New rows go at the bottom of the table.
   - If an existing row already captures the same principle, prefer refining it over adding a near-duplicate.
   - Escape any literal `|` in the values as `\|`.

4. Confirm in one line that it is logged, showing the row you wrote.

Because the user asked for this explicitly, no separate approval step is needed — the invocation is the approval.
