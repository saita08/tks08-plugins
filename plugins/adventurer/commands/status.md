---
description: 実際の Claude Code 利用統計から実績を判定し、冒険者ステータスを表示する
argument-hint: (引数なし)
allowed-tools: Read, Bash
---

Use the `adventurer-status` skill to show the user's Claude Code RPG status.

Read the real usage data at `~/.claude/stats-cache.json` and
`~/.claude/history.jsonl`, judge each achievement strictly from that data,
persist the unlocked set to `~/.claude/claude-rpg/achievements.json`, and
display the adventurer's status card: rank, vital stats, unlocked achievements
(each with the real number that earned it), and the achievements closest to
unlocking with their real gaps.

The governing rule is honesty: never claim anything the data does not support,
and if the usage record is missing, say so plainly rather than inventing a
status. The skill's reference files carry the achievement conditions, the
display format, and the persistence cycle.
