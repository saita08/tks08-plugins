---
description: Map every document in the project to its proper track — CLAUDE.md, README, docs/, adr/, references/ — report misplacements with evidence, and reorganize after explicit approval.
argument-hint: "[監査対象のパス（省略時はカレントプロジェクト全体）]"
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Librarian Audit

Diagnose how well the project's written knowledge matches the four-track contract, report with evidence, and reorganize only after the user approves the shelving plan. Diagnosis and reorganization are separate acts: the report never assumes its own approval.

Read `${CLAUDE_PLUGIN_ROOT}/skills/four-track-contract/references/doctrine.md` before classifying anything, and `${CLAUDE_PLUGIN_ROOT}/skills/four-track-contract/references/placement-guide.md` before judging where content belongs. The placement guide's classification questions and misplacement table are the rubric; do not improvise a different one.

## Step 1 — Inventory

Collect the project's documents: every `*.md` outside dependency and build directories, plus data-shaped files that look like reference material. Exclude what the placement guide marks as unmovable: tool-owned files, `LICENSE`, `CHANGELOG.md`, configs, `.claude/`, `.github/`. If `$ARGUMENTS` names a path, scope the inventory to it.

## Step 2 — Classify

For each document, apply the classification questions. Read the file — classification by filename alone is guessing. For mixed files, classify per section and note which portions sit in the wrong track. Record, for every finding: the file, the misplaced content, which classification question it failed, and the proposed destination.

Also check the structural health of the tracks themselves:

- Do the entrances exist — root README's documentation map, `docs/README.md`, `adr/README.md`?
- Do the index tables match the actual files on disk?
- Is `adr/` at the repository root? A `docs/adr/` is itself a finding.
- Does the same content appear in more than one track?
- Are there orphan documents no index or page links to?

## Step 3 — Report

Present, in this order: a one-screen map of the current structure with each document's assigned track; the findings, most damaging first, each with its evidence; and the shelving plan — the ordered list of moves, splits, extractions, and index updates that would bring the project into contract. For each planned move, name every link and index entry that must move with it. If the project is already in contract, say so plainly and stop; a clean audit is a result, not a disappointment.

## Step 4 — Reorganize, only on approval

Wait for the user's explicit approval of the plan, in whole or by item. Then execute the approved items as one coherent act: move files with `git mv` so history follows, perform splits and extractions, update every cross-link and index table in the same pass. A move that leaves a dangling link is not done. Finish by re-running the Step 2 health checks on the touched areas and summarizing what changed. Do not commit; the user reviews the working tree.

Where a finding's destination is genuinely ambiguous — content that answers two classification questions equally — put the question to the user rather than deciding silently. The librarian proposes shelving; it does not decide what the books mean.
