---
name: carry-between-sessions
description: This skill should be used when the user is moving content between sessions or projects by hand — pasting a report, review, or error log from elsewhere, or wanting to take something to another session. Triggers on phrases like "これを別セッションに持っていきたい", "あっちのセッションでこう言われた", "別のプロジェクトのレビュー結果", "この前のエラーログを貼るね", "carry this over", "in the other session they said", "take this to another window". Guides using paste-tube to capsule the content with its source instead of losing it in the scroll.
allowed-tools: Read
---

# Carry Content Between Sessions

Users routinely move content between sessions by hand: they copy a review result out of one window and paste it into another, they carry an error log across projects, they relay "the other session said X." Two things go wrong when this is done as a loose paste. The content loses its origin — three turns later, nobody remembers whether that log came from staging or prod, from this project or a sibling. And the content is ephemeral — once the conversation scrolls, it is gone, and it must be pasted again from wherever it originally lived.

`paste-tube` fixes both by sealing the content in a capsule that records where it came from and persists on disk. This skill is the judgment for *when* to suggest the capsule; the `/paste-tube:send` and `/paste-tube:receive` commands do the sealing and retrieving.

## When to suggest sending

Suggest sealing a capsule when the user is handing you content that clearly originated elsewhere and clearly has a life beyond this turn:

- They paste a report, review, log, or result and signal it came from another session or project ("あっちで言われた", "別プロジェクトのレビュー").
- They say they want to take something to another session or window ("これ別のところに持っていきたい").
- Content arrives that you can tell will be referred back to, but whose origin would be lost if it just sits in the scroll.

When you see this, offer it in one line: sealing it as a capsule keeps its source attached and lets another session pull it in with `/paste-tube:receive`. If the user agrees, run `/paste-tube:send <label>`, choosing a label that names what the content is.

## When to suggest receiving

Suggest receiving when the user is looking for something they carried in earlier, or starts work that plainly needs content sealed elsewhere ("この前のレビュー結果どこいった", "あのエラーログ持ってきて"). Point them at `/paste-tube:receive`, which lists capsules newest-first with their source and date.

## Do not over-suggest

Not every paste is a capsule. A quick snippet the user is using right now and will not refer back to does not need sealing — offering a capsule for it is noise. Suggest the tube when content has both a lost origin and a life beyond the turn; otherwise stay quiet and just use the content. The value is in provenance and persistence, and content that needs neither gains nothing from a capsule.
