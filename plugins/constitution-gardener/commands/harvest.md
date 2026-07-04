---
description: Mine recent session transcripts for repeated corrections, rejections, and rephrasings, and draft the repeated ones into principle proposals for your CLAUDE.md.
argument-hint: "[最大セッション数（省略時は既定値）]"
allowed-tools: Bash, Read
---

# Harvest repeated friction into principle proposals

Your job is to walk the session transcripts that have appeared since the last harvest, find the moments where the user corrected, rejected, or re-instructed Claude, keep only the friction that recurred **two or more times** as the same kind of failure, and hand each survivor to the user as a principle proposal for their `CLAUDE.md`. You draft; the user judges and ratifies. Never write to any `CLAUDE.md`, never commit, never open a PR.

Read `${CLAUDE_PLUGIN_ROOT}/skills/draft-principle/references/friction-taxonomy.md` before interpreting friction, and `${CLAUDE_PLUGIN_ROOT}/skills/draft-principle/references/principle-writing.md` before drafting the proposal text. Do not load them until you reach the step that needs them.

## The cursor: never read the whole history

Transcripts can reach hundreds of megabytes. This command must be incremental. The cursor lives at `~/.claude/constitution-gardener/state.json` and records, per session file, how far into it the last harvest read. Each run processes only sessions modified since the last cursor, up to a cap, and advances the cursor when it finishes. Reading everything every time is a bug, not a thoroughness.

## Procedure

### 1. Select the sessions to mine

Run the selection script. It reads the cursor, lists transcript files newer than the cursor's high-water mark, caps the count, and prints the batch as JSON. The cap is the first argument to this command if given, otherwise the script's default.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/harvest-select.sh" ${ARGUMENTS:-}
```

The script prints a JSON object: `{"sessions": [{"path","project","mtime"}...], "cap": N, "cursor_exists": bool, "total_new": M}`. If `sessions` is empty, there is nothing new to mine — go straight to step 5 and celebrate the empty harvest. Do not invent work.

### 2. Extract friction from each session, in parallel subagents

For each selected session, extract the friction events with a lightweight `claude -p` call. Run these **synchronously** and stay within the cap — do not fan out unboundedly. Each call reads one transcript and returns the friction events it found, each paired with the Claude action that provoked it.

The extraction script wraps one session and enforces the recursion guard (a `claude -p` call fires its own hooks; the guard variable makes any nested constitution-gardener work exit immediately):

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/harvest-extract.sh" "<session-path>"
```

It prints a JSON array of friction events: `[{"kind","user_quote","claude_action","project"}...]`, where `kind` is `correction`, `rejection`, or `rephrasing`. An empty array means that session was frictionless. Consult `friction-taxonomy.md` for what each kind means and how the extraction reasons; the script carries the essence inline so it runs without loading the file, but when you interpret the results, reason from the taxonomy.

Collect the events from every session into one pool.

### 3. Cluster and keep only what recurred

A single friction event is not a candidate. It could be a one-off, a project-quirk, a bad mood. Only friction that recurred as **the same kind of failure, two or more times, across different moments** earns a proposal — recurrence is the evidence that it is a discipline and not an accident.

Group the pooled events by the underlying failure they express, not by surface wording. Two events belong to the same cluster when a single principle would have prevented both. Discard every cluster of size one. If nothing survives, go to step 5.

### 4. Draft a proposal for each surviving cluster

For each cluster of two or more, produce a proposal with four parts, in this order. Read `principle-writing.md` first; the draft in part 4 must obey its discipline (write the general value, not the triggering symptom; add the observable behavior change; never pin the principle to the incident that spawned it).

1. **Observed cases** — the concrete events in the cluster, each with its user quote, the Claude action it corrected, and which session/project it came from. Evidence, not paraphrase.
2. **Name of the failure class** — what kind of failure this is, named generally enough that its next, differently-shaped instance is still recognizable.
3. **Target institution** — whether this belongs in the user's personal `~/.claude/CLAUDE.md` (a discipline that should hold everywhere) or in a specific project's `CLAUDE.md` (a promise local to that project). Use `friction-taxonomy.md`'s routing test. When the events all come from one project and concern that project's conventions, route to the project; when they recur across projects or concern how Claude should work in general, route to the personal constitution.
4. **Proposed principle text** — the actual paragraph the user could paste, written as a principle: a value with the reasoning that makes it true, stated generally, with the observable change in behavior it should produce.

Present the proposals to the user as your final message. Do not write them to a file. Do not touch any `CLAUDE.md`.

### 5. Advance the cursor and report

Whether or not any proposal survived, advance the cursor so the next harvest starts where this one stopped:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/commands/harvest-commit.sh"
```

Then report:

- **If proposals survived**: present them (step 4). Add one line reminding the user that ratification is theirs — they can refine the wording with you, then paste it themselves; the gardener does not write to `CLAUDE.md`.
- **If nothing survived**: celebrate it honestly. A harvest that finds no repeated friction means the constitution is doing its job — the same friction is not recurring. Say that plainly. Do not manufacture a weak candidate to have something to show. An empty harvest is the healthy outcome, not a failed one.

## Constraints

- Never write to any `CLAUDE.md`, never commit, never open a PR. Drafting the proposal is the whole job; adoption happens in dialogue with the user.
- Never propose a cluster of size one. Recurrence is the bar; a single friction event does not clear it.
- Stay within the session cap. This command must remain incremental and bounded — advancing the cursor is what keeps the next run cheap.
- Do not pull raw transcript dumps into the conversation. Extraction happens in the subagents; the main context receives only structured friction events and the proposals built from them.
