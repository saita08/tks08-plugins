# Content Inspection

How to verify that a document's content still tells the truth. Placement says where a book lives; inspection says whether the book can be trusted. The contract's ground for this is the principle that records describe a moment: every page was true when written, and the code has moved since.

## The standard of evidence

A staleness finding pairs the document's claim with the reality on disk: "the page says X, the repository shows Y", with both sides quoted or precisely located. A claim that cannot be checked against anything is reported as unverifiable, which is a verdict in its own right, not a failure of the inspection. Never report a claim as stale on suspicion alone.

## Mechanical checks, run on everything first

- Every relative link resolves to an existing file and anchor.
- Every index table row points to a file that exists, and every file in the directory appears in its index.
- Code fences naming commands, scripts, or make targets correspond to things that exist in the repository's manifests.
- No link from `docs/`, `adr/`, CLAUDE.md, or the README points into `notes/` — a durable shelf depending on a disposable one is a dead link that has not happened yet.
- Where the project carries the guarantees, `autoMemoryEnabled: false`, the `attribution` block, and the shosoin hooks in `.claude/settings.json`, the hook entries still point at scripts that exist and are executable. A guarantee whose script has gone missing protects nothing while looking installed.

## Per-shelf checks

### docs/ — does the description match the disk?

Extract the checkable claims: file paths, directory layouts, function and class names, config keys, column definitions, command invocations, environment variables. Verify each against the repository. A `docs/` page earns one of three verdicts: current (claims verified), stale (specific claims contradicted, listed), or unverifiable (describes systems the inspection cannot reach — say which).

### adr/ — is the record still a record?

- Every record carries the expected sections: context, decision, consequences, and the alternatives that were considered. An ADR without alternatives is a memo wearing a uniform.
- Status values come from the project's declared vocabulary, supersede chains link both ways, and no record is marked superseded by a record that does not exist.
- Accepted records have not been rewritten after acceptance. Check with `git log --follow` on records whose status is Accepted: substantive edits after the acceptance date violate immutability. Status-line updates and link fixes are legitimate; changed reasoning is not.
- Consequences that name `docs/` pages point at pages that still exist.

### CLAUDE.md — are the values still values?

- Each section states a value general enough to guide unanticipated situations. A section that has decayed into a list of specific cases is drift, and the contract's own test applies: could several distinct rules still be derived from it?
- Principles do not contradict each other, and none is contradicted by what the repository observably does. A value the codebase systematically violates is either a dead letter or a finding about the code — report it, do not judge which.

### references/ — has the snapshot drifted?

`references/` cannot be verified against the live system it snapshots — that is its documented weakness. What can be checked: whether the code's expectations still match the snapshot's shape. Column counts, field names, and index constants that appear in both code and reference data should agree. Where the code has moved past the snapshot, the snapshot is stale by proxy, and that is reportable evidence.

### notes/ — is anything still alive in the morgue?

A note is trustworthy only while its task is. For each file, judge from the repository whether the task it served is visibly closed — the PR merged, the feature landed, the handover superseded by later work. A note whose task is closed and that was neither promoted nor deleted is a finding: its contents are outside trust, and anything durable inside it is knowledge parked where it is destined to be deleted. Report it as a promote-or-delete decision for the user; inspection does not judge which parts deserve promotion.

### README — is the front door honest?

Quickstart commands exist and match the manifests. The documentation map's links resolve. The project description does not promise features the repository visibly lacks.

## The language check, on project-language documents

Where the documentation language is not English, check each document's vocabulary against the contract's language rule: terms of art in their original form or that language's usual transliteration, process words as everyday words. A term of art translated into a literary calque is a finding, because later documents copy the collection's existing records as house style and the drift compounds with each one written. Report the word, where it appears, and the ordinary form; the fix is a word substitution and rides with the mechanical fixes. Flag only vocabulary the project's own readers would not use — never sentence style, and never the project's genuine domain terms.

## What inspection does not judge

Whether the prose is well written, whether the design described is good, and whether a decision was wise. Inspection verifies correspondence with reality, not quality of thought. A wrong-headed ADR that accurately records its wrong-headed reasoning is a healthy record. The language check above is the one vocabulary-shaped exception, and it reaches only translated terms of art, not writing.

## Fixing

Mechanical staleness — a renamed file, a moved path, a dead link, an index row — is offered as a fix the user can approve, executed with the same one-act discipline as any structure change. Substantive staleness — a page describing an architecture that no longer exists — is reported as writing work with a proposed owner, because rewriting knowledge requires knowledge, and inventing it to close a finding would replace stale truth with fresh fiction.
