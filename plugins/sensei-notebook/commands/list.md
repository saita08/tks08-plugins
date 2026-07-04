---
description: これまでに蓄積した学び(Q&A)の一覧を表示する
allowed-tools: Read
---

The user wants to see the learning notebook — the concepts captured in this project so far.

## What to do

1. Read `.claude/sensei-notebook.local.md` from the project root.

2. If the file does not exist or has no entries, say plainly that the notebook is empty — nothing has been captured yet, and entries get added as the user learns things worth keeping. Then stop. Do not create the file.

3. Otherwise, list the captured questions clearly. Showing the `## Q:` headings gives a quick index; include the answer gists too if the notebook is short enough that the full list stays readable. For a long notebook, lead with the list of questions and offer to expand any the user wants to revisit.

4. Keep the rendering faithful to what is stored. Do not re-answer or editorialize; this is a view of what was captured, not a fresh explanation.

This command only reads. It does not add, edit, or remove entries.
