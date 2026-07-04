---
description: Show this session's bill — how many subagents were spawned and which files were read more than once — the waste-correlated behavior token-bouncer has been watching.
argument-hint: "[任意: 特定セッションIDを見たい場合のみ]"
allowed-tools: Bash
---

# token-bouncer tab

Present this session's bill: the behavior token-bouncer watches because it correlates with burning tokens. This is not a token count — the harness never hands the hook a token number — so do not present it as one. It is a count of spawns and re-reads.

Run the tally and read its JSON:

```
bash "${CLAUDE_PLUGIN_ROOT}/commands/tab.sh" $ARGUMENTS
```

It returns:

- `session_dir` — the session whose counters were read (null if nothing has been recorded yet).
- `agents` — how many subagents were spawned this session.
- `repeated_reads` — files read more than once, as `{path, count}`, most-repeated first.

Present it plainly and briefly:

- If `session_dir` is null, or `agents` is 0 and `repeated_reads` is empty, say the bill is clean — nothing worth flagging this session — and stop.
- Otherwise, lead with the agent spawn count, then list the repeated reads with their counts (a short table if there are several). Keep it to what is on the bill; do not moralize.
- State once, plainly, that these are proxies for waste, not a measured token cost. A high number is a prompt to reflect, not proof that anything was wasted — sometimes many spawns or re-reads are exactly right.

If the tally picked the wrong session (the user is on a different one than the most-recently-touched directory), they can pass a session id as an argument. Mention that only if the numbers look implausibly empty or stale.
