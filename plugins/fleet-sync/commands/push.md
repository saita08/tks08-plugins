---
description: Copy the origin's shared files into each fleet destination's working tree where they have drifted, skipping re-import candidates and leaving the commit to each destination's owner.
argument-hint: "[配布先リポジトリ名で絞り込み（省略可）]"
allowed-tools: Read, Glob, Bash
---

# Fleet Sync Push

Bring the fleet's out-of-date copies back in line with the origin. This command writes into destination working trees; it does not commit. Where the delivery stops is a discipline, not a limitation — the reasoning is in the README's honest-constraints section, and it is why this command has no `git` step.

Run `/fleet-sync:status` first, or reproduce its analysis here, because push must act on the same drift model status reports. Read `${CLAUDE_PLUGIN_ROOT}/skills/distribution-layers/references/drift-model.md` before writing anything.

## 1. Load the manifest and classify

Read `.claude/fleet-sync.local.md` at the origin root for the `files` and `destinations` lists, exactly as `/fleet-sync:status` does. If `$ARGUMENTS` names a destination, restrict the push to that one. Classify every (file, destination) pair into: in sync, stale, missing, or re-import candidate.

## 2. Push only the stale and missing

For each pair that is **stale** or **missing**, copy the origin's version to the destination's path, creating parent directories as needed. This is the delivery. A missing file is a first delivery; a stale file is an update.

For each pair that is a **re-import candidate**, do not write. Collect it. These are the destinations that changed a shared file locally on purpose, and overwriting them would destroy the very information the user needs to decide whether the change belongs back in the origin.

## 3. Stop at the working tree

After copying, do nothing else in the destination. Do not `git add`, do not commit, do not push to any remote. Each destination is someone's repository with its own history and its own release discipline; the delivery lands in the working tree and the destination's owner decides when and how it enters their history. State this in the report so the user knows the changes are staged in the working tree awaiting their review, not silently committed.

## 4. Report what happened and what was withheld

Two lists, both by name:

- **Delivered** — every file written, to which destination, and whether it was an update or a first delivery.
- **Withheld as re-import candidates** — every pair skipped because the destination's local change looked deliberate. For each, give the user the concrete next choice: fold this change back into the origin, or discard it and re-run push to overwrite. This command does neither on its own; the judgment is the user's.

## Constraints

- Never overwrite a re-import candidate. When you cannot tell whether a destination's difference is deliberate, treat it as a re-import candidate and withhold it. The cost of withholding is one more cycle of drift; the cost of overwriting is a lost local edit.
- Never commit or push in any destination. The delivery ends at the working tree.
- This is a synchronization, not version control. The origin's history lives in the origin's git; this command carries the current state of the shared files outward, nothing more. Do not attempt to reconcile histories or replay commits.
- Do not distribute anything not declared in the manifest. The manifest is the boundary of what the fleet shares.
