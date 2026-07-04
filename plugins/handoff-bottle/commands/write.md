---
description: 現在の作業状態を定型テンプレートで瓶詰めし、次のセッションが拾えるよう .claude/handoff-bottle.local.md に書き出す
argument-hint: [補足メモ（省略可。瓶に添える一言）]
allowed-tools: Read, Write, Edit, Bash
---

# Write a Handoff Bottle

Capture the current state of the work into a bottle so a future session — which remembers nothing of this conversation — can pick it up. Write to `.claude/handoff-bottle.local.md` in the project. A bottle is written for a stranger: it must stand on its own without the context of this conversation.

## What goes in a bottle

Fill this template from the actual work in this session. Do not invent detail; if a field has nothing real to say, write a short honest line rather than padding it.

```markdown
## 瓶 <YYYY-MM-DD HH:MM>

### いまの状態
<What is in progress right now, in a few sentences. Where the work stands, what is done and what is not. Enough that a stranger knows the situation without reading the whole history.>

### この作業で下した決定とその理由
<The decisions made during this session and why each was made. This is the part that evaporates most easily and costs the most to reconstruct. A decision without its reason forces the next session to re-litigate it.>

### 次の一歩
<The single most concrete next action. Not a wishlist — the one thing to do next, specific enough to start on.>

### 触っていたファイル
<The files touched or being worked on, as paths, with a word on each. So the next session opens the right files first.>
```

## Procedure

### 1. Gather the timestamp

Get the current local time for the bottle heading:

```
date '+%Y-%m-%d %H:%M'
```

### 2. Compose the bottle

Fill the template above from what actually happened in this session: the state, the decisions with their reasons, the one next step, and the files touched. If the user passed an argument, weave it in as context — it is their steer on what matters most.

### 3. Prepend, do not overwrite

A bottle is added to the front of the file; older bottles sink below it. This keeps a short history rather than losing the previous one.

- If `.claude/handoff-bottle.local.md` does not exist, create it with the header block below followed by the new bottle.
- If it exists, insert the new bottle immediately after the header block, above the previous bottles.
- Keep at most the three most recent bottles. When prepending a fourth, drop the oldest (the one at the bottom).

Header block for a new file:

```markdown
---
plugin: handoff-bottle
---

# 引き継ぎの瓶

このファイルは handoff-bottle が書き出したセッション引き継ぎです。最新の瓶が上、古い瓶が下に沈みます（直近3本まで）。人間が読んで編集してよい普通のMarkdownです。次のセッション開始時に最新の1本が自動で読み込まれます。
```

Create the `.claude/` directory first if it does not exist:

```
mkdir -p .claude
```

### 4. Confirm briefly

Tell the user the bottle was written and where, in one line. Do not paste the whole bottle back — they just watched you write it.

## Constraints

- Never write a secret (token, key, password) into a bottle. The file lives in the project and may be committed. If the work involved a secret, refer to it by name, not value.
- Do not overwrite existing bottles; prepend. The point is that the previous session's bottle survives.
- The bottle is for a stranger. Do not rely on anything only visible in this conversation — spell it out.
