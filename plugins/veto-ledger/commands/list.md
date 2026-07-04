---
description: このプロジェクトで却下された方向と、その却下の軸を一覧表示する
allowed-tools: Read
---

The user wants to see the veto ledger — the directions this project has rejected and the principle behind each.

## What to do

1. Read `.claude/veto-ledger.local.md` from the project root.

2. If the file does not exist or has no data rows, say plainly that the ledger is empty — nothing has been recorded as rejected yet — and stop. Do not create the file.

3. Otherwise, present the entries clearly. Show each rejected direction alongside its principle and date. Keep the rendering faithful to what is stored; do not editorialize or re-derive principles.

4. If the ledger is long, you may group or summarize for readability, but every principle must remain visible — the principles are the point of the ledger, and hiding them would defeat it.

This command only reads. It does not add, edit, or remove entries.
