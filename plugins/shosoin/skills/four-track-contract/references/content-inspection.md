# Content Inspection

How to verify that a document's content still tells the truth. Placement says where a book lives; inspection says whether the book can be trusted. The doctrine's ground for this is the principle that records describe a moment: every page was true when written, and the code has moved since.

## The standard of evidence

A staleness finding pairs the document's claim with the reality on disk: "the page says X, the repository shows Y", with both sides quoted or precisely located. A claim that cannot be checked against anything is reported as unverifiable, which is a verdict in its own right, not a failure of the inspection. Never report a claim as stale on suspicion alone.

## Mechanical checks, run on everything first

- Every relative link resolves to an existing file and anchor.
- Every index table row points to a file that exists, and every file in the directory appears in its index.
- Code fences naming commands, scripts, or make targets correspond to things that exist in the repository's manifests.

## Per-track checks

### docs/ — does the description match the disk?

Extract the checkable claims: file paths, directory layouts, function and class names, config keys, column definitions, command invocations, environment variables. Verify each against the repository. A `docs/` page earns one of three verdicts: current (claims verified), stale (specific claims contradicted, listed), or unverifiable (describes systems the inspection cannot reach — say which).

### adr/ — is the record still a record?

- Every record carries the expected sections: context, decision, consequences, and the alternatives that were considered. An ADR without alternatives is a memo wearing a uniform.
- Status values come from the project's declared vocabulary, supersede chains link both ways, and no record is marked superseded by a record that does not exist.
- Accepted records have not been rewritten after acceptance. Check with `git log --follow` on records whose status is Accepted: substantive edits after the acceptance date violate immutability. Status-line updates and link fixes are legitimate; changed reasoning is not.
- Consequences that name `docs/` pages point at pages that still exist.

### CLAUDE.md — are the values still principles?

- Each section states a value general enough to guide unanticipated situations. A section that has decayed into a list of specific cases is drift, and the doctrine's own test applies: would this sentence survive a rewrite of the codebase?
- Principles do not contradict each other, and none is contradicted by what the repository observably does. A value the codebase systematically violates is either a dead letter or a finding about the code — report it, do not judge which.

### references/ — has the snapshot drifted?

`references/` cannot be verified against the live system it snapshots — that is its documented weakness. What can be checked: whether the code's expectations still match the snapshot's shape. Column counts, field names, and index constants that appear in both code and reference data should agree. Where the code has moved past the snapshot, the snapshot is stale by proxy, and that is reportable evidence.

### README — is the front door honest?

Quickstart commands exist and match the manifests. The documentation map's links resolve. The project description does not promise features the repository visibly lacks.

## What inspection does not judge

Whether the prose is well written, whether the design described is good, and whether a decision was wise. Inspection verifies correspondence with reality, not quality of thought. A wrong-headed ADR that accurately records its wrong-headed reasoning is a healthy record.

## Fixing

Mechanical staleness — a renamed file, a moved path, a dead link, an index row — is offered as a fix the user can approve, executed with the same one-act discipline as any structure change. Substantive staleness — a page describing an architecture that no longer exists — is reported as writing work with a proposed owner, because rewriting knowledge requires knowledge, and inventing it to close a finding would replace stale truth with fresh fiction.
