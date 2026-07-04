---
description: 直前の作業について「人間がやるべき検証」の手順書を生成し、notes/ 配下（なければ .claude/baton.local.md）に書き出す
argument-hint: [検証で特に見てほしい観点（省略可）]
allowed-tools: Read, Write, Edit, Bash
---

# Write a Baton

Claude's part of the work is done. What remains is the part only a human can do: checking it on real hardware, flipping it live in production, looking at it with human eyes. This command writes that human's part down as a concrete, copy-pasteable handoff sheet — the baton — so the pass from "Claude finished" to "human verifies" is never left to a spoken sentence that gets forgotten.

## Where the baton goes

Write to a `notes/` directory if the project has one (many repos keep human-facing notes there):

- If `notes/` exists at the project root, write `notes/baton-<YYYY-MM-DD-HHMM>.md`.
- Otherwise, write `.claude/baton.local.md`, creating `.claude/` if needed.

A baton is a fresh sheet each time, not a running log — the human reads the latest handoff, acts on it, and is done. When falling back to `.claude/baton.local.md`, overwrite the previous one.

## What goes in a baton

Fill this template from the actual work just completed. Every step must be something the human can literally do — a command they can paste, a URL they can open, a screen they can look at. Vague instructions ("check it works") defeat the purpose; the baton exists to remove the guesswork the human would otherwise have to supply.

```markdown
# バトン: <一行で、何を検証してほしいか>

書き出し日時: <YYYY-MM-DD HH:MM>

## 前提（何が終わっているか）
<What Claude finished, in a few sentences. What was changed, and the state it is in now. So the human knows exactly what they are picking up.>

## 手順（あなたがやること）
1. <A concrete action. If it is a command, write it in a code block so it can be pasted verbatim.>
2. <The next action. Number them; order matters.>
3. <...>

## 確認観点（何を見れば成功と言えるか）
- <The observable signal that means success. Not "it should work" but "the page shows X" / "the log prints Y" / "the LED turns green".>
- <Each thing worth checking, as its own line.>

## 失敗したときの戻し方
<How to revert or recover if verification fails. The exact command or steps to undo the change and return to the prior state. If truly nothing needs undoing, say so plainly — do not leave the human guessing.>
```

## Procedure

### 1. Gather the timestamp and location

```
date '+%Y-%m-%d %H:%M'
```

Decide the target path: `notes/` if it exists, else `.claude/baton.local.md`.

```
[ -d notes ] && echo "notes exists" || echo "fallback to .claude"
```

### 2. Compose the baton

Fill the template from the work just done. Pull the real commands, paths, and URLs from the session — the human should not have to look anything up. If the user passed an argument, treat it as their steer on which verification points matter most and lead with those.

Be honest about the revert path. If the change is hard to undo, say exactly how, and if it genuinely cannot be undone, say that too — the human deserves to know the stakes before they act, not after.

### 3. Write the file

Create the target directory if needed (`mkdir -p .claude` for the fallback), then write the baton.

### 4. Confirm briefly

Tell the user where the baton was written, in one line. Do not paste the whole sheet back.

## Constraints

- Never write a secret (token, key, password) into a baton. It is a file that may be committed. Refer to secrets by name; if a step needs one, tell the human where to get it, not what it is.
- Every step and every check must be observable and actionable by the human. If you cannot make a step concrete, that is a sign the work is not actually ready to hand off — say so rather than writing a vague step.
- The revert section is not optional. A handoff that tells the human how to apply a change but not how to back it out is an incomplete baton.
