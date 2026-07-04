---
description: Verify each document's content against reality — stale claims in docs/, broken links, ADRs edited after acceptance, reference data the code has moved past — and report what can no longer be trusted.
argument-hint: "[点検対象のパス（省略時は全文書）]"
allowed-tools: Read, Glob, Grep, Bash, Edit
---

# Shosoin Inspect

Verify that the collection still tells the truth. Where the audit asks whether every book is on the right shelf, the inspection opens the books and checks their claims against the repository as it exists today. The two are deliberately separate: a perfectly shelved library can still be full of lies.

Read `${CLAUDE_PLUGIN_ROOT}/skills/four-track-contract/references/content-inspection.md` before inspecting anything — it carries the per-track checks, the standard of evidence, and the line between what inspection fixes and what it only reports. Read `${CLAUDE_PLUGIN_ROOT}/skills/four-track-contract/references/doctrine.md` if the track roles are not already loaded in this conversation.

## Step 1 — Scope

Inventory the documents to inspect: the tracks' contents plus the root README and CLAUDE.md. If `$ARGUMENTS` names a path, inspect only it. Exclude tool-owned files as the placement guide defines them.

## Step 2 — Mechanical pass

Run the mechanical checks from the reference across the whole scope first: link resolution, index-to-disk correspondence, named commands against the manifests. These are cheap, objective, and often explain the deeper findings.

## Step 3 — Claim verification

Apply the per-track checks from the reference. Read each document, extract its checkable claims, and verify them against the repository. Assign each document a verdict: current, stale with the contradicted claims listed, or unverifiable with the reason. For accepted ADRs, check immutability through git history as the reference describes.

## Step 4 — Report

Present the findings most damaging first: documents whose staleness would actively mislead a reader today, then broken mechanics, then unverifiable claims worth a note. Every staleness finding pairs the claim with the disk reality. Close with the collection's overall verdict — including a clean one, stated plainly, when the books check out.

## Step 5 — Fix, only on approval

Offer the mechanical fixes — dead links, renamed paths, index rows, supersede back-links — as an approvable list, and execute only what the user approves, updating each affected index and cross-link in the same act. Substantive rewrites are never performed silently: propose them as writing work, because closing a staleness finding by inventing content replaces stale truth with fresh fiction. Do not commit; the user reviews the working tree.
