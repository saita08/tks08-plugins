---
name: veto-capture
description: This skill should be used when the user rejects a proposal, vetoes a direction, or forbids an approach — e.g. "それはやめて", "その方針は無し", "却下", "そういうやり方はしない", "don't do that", "no, not like that", "we're not going to X", "I don't want X". Use it to record the rejected direction and the principle behind it into the project's veto ledger, so future sessions do not re-propose what was already declined.
allowed-tools: Read, Edit, Write
---

# Record a Rejection

A rejected idea that comes back in a new form is one of the fastest ways to lose a user's trust: they already spent the effort to decline it, and here it is again. The reason it recurs is that the rejection lived only in the conversation, and the next session never saw it. This skill records rejections into `.claude/veto-ledger.local.md`, which the plugin's SessionStart hook replays into every future session — so a "no" said once is a "no" that holds.

The single discipline that gives the ledger its value: record the **principle**, not the incident. A row that says "rejected the idea of splitting this into two PRs" only stops that exact proposal; a row that says "this project keeps one feature to one PR" stops the whole class of proposals it belongs to, including the ones no one has thought of yet. See `references/ledger-format.md` for the format; read it before your first write in a session.

## When this applies

Record a rejection when the user clearly declines a direction or forbids an approach:

- rejects a proposal you made ("それはやめて", "却下", "no, not that"),
- forbids a way of working ("そのやり方はしない", "we don't do X here"),
- rules out a direction for the future ("Xはもう提案しないで", "we're never going to X").

It does not apply to a minor course-correction within an agreed direction, a "not right now" that is about timing rather than the idea, or a preference the user voiced in passing without deciding anything. The signal is a *decision to not go a certain way*, not any expression of mild dislike. When in doubt about whether something rises to a ledger entry, it is better to ask than to record noise — a ledger full of trivia trains the user to ignore it.

## Procedure

### 1. Identify the rejection and its principle

Name two things: the **direction that was rejected** (in one line), and the **principle behind the rejection** — the general reason that makes this and similar directions wrong for this project. Deriving the principle is the real work. Ask yourself: if a future session proposed a *different* idea that fails for the same reason, would this principle catch it? If the principle only describes this one instance, generalize it until it names the class.

If you genuinely cannot tell why the direction was rejected, ask the user for the reason in one short question. The principle is what makes the ledger useful; a rejection recorded without its reason is nearly worthless.

### 2. Offer to record it — modestly, and confirm first

Tell the user, in one sentence, that you can log this rejection so future sessions do not re-propose it, and show the row you would write (direction and principle). Ask whether to record it. Keep this light; it is a quick confirmation, not a negotiation. Wait for a yes before writing.

Confirmation matters here because the ledger constrains every future session: a wrong or over-broad principle would silently suppress good proposals later. Recording only what the user confirms keeps the ledger trustworthy and keeps this skill from editing the user's project unbidden.

### 3. Append the entry

On confirmation, append the row to `.claude/veto-ledger.local.md`, following `references/ledger-format.md`, with today's date. Create the file with its header if it does not exist. If an existing row already captures the same principle, prefer updating or refining it over adding a near-duplicate.

### 4. Confirm briefly and move on

Say in one line that it is logged, and return to the work. Do not restate the whole ledger.

## Constraints

- Never write to the ledger without the user's explicit confirmation of the specific entry.
- Record the principle, not just the instance. A row whose principle only matches the one rejected proposal has failed at its job.
- The ledger lives in the project at `.claude/veto-ledger.local.md` — a place the user can see and edit. Do not keep rejections in any private or hidden store.
- Keep each entry to one line of direction and one line of principle. Long entries defeat the injection budget and bury the principle.

## Resources

- `references/ledger-format.md` — the exact format of `.claude/veto-ledger.local.md` and how to write a principle rather than an incident.
