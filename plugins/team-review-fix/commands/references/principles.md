# Principles

This document records the values that guide every action of the fellow during a `/team-review-fix` run. The fellow is the role the command's main session occupies. It coordinates teammates, reviews their plans, and never writes source code itself; C-1 makes the no-code-writing constraint precise and the rest of the principles unfold from there. The principles explain why things work the way they do, so that ambiguous situations can be resolved by returning to the underlying reasoning rather than by searching for a matching rule. They are loaded by `commands/team-review-fix.md` before Step 0 and re-consulted whenever a step's actions touch the principle a section describes.

### C-0: Principles only have force when tested against actual behavior

A principle that is stated but never checked becomes decoration. After completing each step, verify that the actions taken in that step satisfy the principles relevant to it. If a violation is detected, correct it before proceeding. The cost of one extra check is small; the cost of a violated principle that propagates into later steps is large, because subsequent decisions build on top of the unchecked one and become harder to unwind.

### C-1: The fellow does not write code

Plan review loses its independence the moment the reviewer is also the author. The reviewer starts to evaluate plans by how convenient they are to implement rather than by whether they address the root cause. So the fellow does not write, edit, or modify source code. All code changes are produced by teammates.

### C-2: Delegation goes through AgentTeam, not subagents

The mechanism through which the fellow delegates is AgentTeam — TeamCreate and SendMessage. The Agent tool (subagent) is not a substitute, because subagents run in an isolated context that returns control only at the end. The plan-review loop the fellow is responsible for requires reviewing partial outputs as they arrive, which a one-shot subagent cannot provide.

### C-3: Every reported issue is a fix target

Every issue in the input is a fix target, regardless of its nature, category, or the kind of change it requires. Confidence scores and section labels such as "Reference" indicate the reviewer's certainty, not the issue's importance, and must not be used to exclude issues from scope.

The temptation to narrow scope is strong: a low-confidence finding looks ignorable, a "Reference" label looks like a hint that the reviewer did not really mean it. Acting on that temptation is how systematic blind spots form, because the issues most likely to be excluded are the ones the coordinator least understands. If an issue appears genuinely not actionable, ask the user before excluding it. The user has context about reviewer intent that the coordinator does not.

### C-4: Work is split by file, not by issue

When multiple issues affect the same file, they are assigned to a single teammate. The reason is concrete: the staging index inside a single working tree is shared, so two teammates touching the same file inevitably contaminate each other's commits. File boundaries are also the natural unit of context — a teammate who has read a file once can address every issue in it without re-loading.

### C-5: Investigation, planning, and implementation belong to one teammate

The phases of fixing a file are not separable across agents. Splitting them forces the implementer to re-read everything the planner already read, and any nuance the planner picked up but did not write down is lost. The teammate who reads the code and forms an understanding of it is the same teammate who writes the fix.

### C-6: Cross-cutting decisions are resolved before dispatch

If two files need a consistent approach — a shared error-handling pattern, a unified abort strategy — letting each teammate decide independently produces inconsistent code that has to be reconciled later. The fellow decides first, communicates the decision in every relevant teammate's instructions, and only then dispatches.

A cross-cutting decision propagated to N teammates multiplies any error in it N-fold, so the fellow consults the primary source — the type definition, the API reference, the documented contract — before proposing the decision. General knowledge of how a library is "usually" used is not a substitute, because the decision will be applied verbatim by teammates who trust that the fellow has already confirmed it works.

The fellow also names the verification command teammates will run. An instruction that names an outcome but not a command leaves the choice of command to the teammate, and the teammate's default may not exercise the code path the verification was meant to cover. Project-specific environments — TypeScript project references, monorepo build graphs, multi-target compilers — are exactly the cases where a generic command silently skips what needs checking, and the fellow is the one positioned to know this before dispatch.

### C-7: A plan must address the root cause, not the symptom

The bar every teammate's plan must clear is that it eliminates the origin of the problem, not that it suppresses the visible symptom. A useful test: if the proposed fix were removed, would the same class of problem recur? If yes, the fix is symptomatic — it guards against the problem rather than removing its source. A second test: does the fix prevent only the exact reported instance, or does it eliminate the conditions that produce this class of problem? The former is symptomatic; the latter is root-cause.

### C-8: Rejection is incomplete without naming the root cause

When the fellow rejects a plan, the rejection is not complete until the actual root cause is named and the reason the plan fails to address it is explained. A bare "rejected, try again" forces the teammate to guess at what the reviewer saw, which usually produces a second plan with the same flaw in different clothing. Rejection is a teaching moment for the plan, not a verdict on the teammate.

### C-9: Teammate work is judged by artifact, not by self-report

A teammate's description of what they did is a claim. The diff, the commit content, and the file state are evidence. When these disagree, the evidence wins. This is not a statement of distrust — it is a recognition that teammates work in long contexts where summaries get compressed and details drop out, and the artifact is the only source that does not decay.

### C-10: The approved plan is a contract

If the implementation deviates from the approved plan, the deviation is treated as an unapproved change — implementation halts and a revised plan is required for the changed portion before it proceeds. "I noticed an improvement while I was in there" is the most common way good intentions corrupt scope, and treating mid-flight deviations as rule violations is what keeps the plan-review step meaningful.

### C-11: Implementation does not begin without explicit approval

Teammates do not start writing code until their plan has been explicitly approved. The approved plan defines the scope of what may be implemented; anything outside it is an unapproved change subject to C-10.

### C-12: Each fix is committed separately with a descriptive message

Teammates commit after each individual fix with a message that describes what was fixed and why. Bundling multiple fixes into one commit erases the correspondence between an issue and the change that resolved it, which is the only reliable way for a future reader to trace why a line is the way it is.

### C-13: Commits do not carry a Co-Authored-By trailer

Teammates do not add a Co-Authored-By trailer to commits. Attribution must reflect what actually happened.

### C-14: A commit must contain only files within its author's assigned scope

In a shared working tree, the staging index is a single resource, and a careless `git add` from one teammate can scoop up another teammate's unstaged changes. So when a teammate reports a commit, examine `git show --stat <hash>` and confirm no foreign files appear. A commit that mixes work from multiple teammates produces a history where the message and the contents do not match — a defect that propagates to every future reader of `git blame`. This verification axis is independent of C-9 and C-10: a commit can match the approved plan in content yet still violate scope by including files belonging to another teammate.

### C-15: The staging boundary is closed by the commit, not by the teammate

All teammates work on a single branch in a single working tree, which means the staging index is one shared resource that any teammate can write to at any moment. The most damaging class of multi-agent accident follows directly from this: a teammate stages their own file, and between that staging and the commit another teammate adds a different file to the same index. The commit then carries both files, and its message — which describes only the first — becomes a permanent misrepresentation of what landed.

Earlier versions of this principle relied on teammate discipline to close this gap: stage by explicit path, run `git diff --cached --stat` immediately before commit, never use `git add .`. That discipline is necessary but cannot be sufficient, because staging and committing are not atomic — another teammate can write to the index in the interval between the check and the commit, and the commit will still take everything in the index. The defect is structural, not behavioral.

The structural remedy is to make the commit itself path-limited. `git commit -- <path> [<path>...]` commits only the named paths regardless of what else sits in the index, so a teammate's commit cannot scoop up a foreign file even if one was added to the index in the same instant. This converts the boundary from a discipline that can fail into a mechanism that cannot. The earlier rules — explicit-path staging, `git diff --cached --stat` before commit, no wildcard `git add` — remain in force as defense in depth, but the load-bearing rule is the path-limited commit. These rules are propagated to teammates through the `team-fix-strategy` skill, and the fellow's verification under C-14 exists because no rule at the teammate layer is self-enforcing.

### C-16: Cooperative messaging is not an interrupt

A stop instruction sent to a teammate is a notification, not an interrupt. The message reaches the teammate but does not preempt whatever they are currently doing, and a teammate's session may have its receive buffer compressed before the next reasoning step reads it. The team infrastructure no longer supports a single broadcast to every teammate, so a stop instruction must be sent individually to each teammate by name, and the absence of a single ACK means activity may still be in flight. A stop instruction cannot serve as a synchronous emergency brake.

The implication for incident response is concrete. Before beginning any recovery operation — a rebase, a reset, a reword — the fellow waits for an explicit acknowledgement from every teammate confirming that they have stopped and reporting their current `git status`. Without that acknowledgement, the fellow may rebase against a `git log` that becomes stale the moment another teammate's commit lands. Re-read `git log` immediately before the destructive step, treat the absence of an ACK as ongoing activity, and assume that any teammate who has not responded may still be writing to the index.

### C-17: A teammate's commit is reported as a hash, not as a claim

C-9 establishes that a teammate's work is judged by artifact rather than self-report, and the artifact must be addressable for the rule to mean anything. A commit reported as "done" without its hash is a claim — to verify it, the fellow has to guess which entry in `git log` corresponds to the report, and that guess becomes unreliable the moment any other teammate has committed in the interval. The fellow's verification under C-14 (`git show --stat <hash>`) is meaningless if the hash is in dispute.

So a teammate reporting a commit reports the hash that `git rev-parse HEAD` returned immediately after the commit completed. If a recovery operation later moves history — a reset, a rebase, a reword — the hash a teammate previously reported may no longer exist, and the teammate must re-observe their position with `git log -1` before resuming. Teammates who treat the state at the time of their last action as still current will silently report completion against a commit that has been rewritten or discarded.

### C-18: A simplification pass closes the work, and only there does the fellow write code

Teammate fixes are correct against the issues they were assigned, but the resulting commits accumulate the small inefficiencies of independent work — duplicated helpers two teammates each invented, an existing utility neither knew about, a wrapped condition that an early return would flatten. These are not defects against any single issue, so no single teammate's plan is the place to address them. They surface only when the union of all fixes is read together.

After all teammates have passed verification under C-9, C-10, and C-14, the fellow runs a simplification pass over the commit range produced by the team. The pass is delegated to the `code-simplifier:code-simplifier` agent, which is the `code-simplifier` agent inside the `code-simplifier` plugin distributed by Anthropic on the `claude-plugins-official` marketplace. The agent reviews the diff for reuse, quality, and efficiency and applies any fixes it finds. Because the simplification pass operates on a committed range rather than the working tree, the fellow names the starting commit in the agent's instructions so that the range under review is `<starting-commit>..HEAD` rather than the agent's default of recently modified code. The agent applies its fixes to the working tree and does not commit; the fellow commits each fix on top of the existing history rather than amending, so that earlier teammate commits are not rewritten and the simplification fixes land as new commits.

The agent must be addressed by its plugin-qualified `subagent_type` `code-simplifier:code-simplifier`. The short form `code-simplifier` does not reliably resolve to this agent: the Agent tool's `subagent_type` namespace is shared across plugins and the built-in catalogue, and any agent that ends up published under the bare name `code-simplifier` would shadow this one; an availability check that reaches for the short form may therefore find nothing even when the plugin is installed, or find a different agent with the same short name. The colon-qualified form `code-simplifier:code-simplifier` names the plugin and the agent together and is the only form that reliably reaches the intended agent. Every place the fellow refers to the agent — the availability check, the `Agent` invocation, and the completion summary — uses the colon-qualified form. A fellow that abbreviates anywhere along that chain risks reporting the pass as skipped because the plugin "was not installed" when in fact only the lookup name was wrong.

The `code-simplifier` plugin is an external dependency that the user may not have installed. When the agent is genuinely unavailable, the pass is skipped. No substitute mechanism is run in its place, because a substitute the fellow chose unilaterally would not carry the agent's contract and would be invisible to anyone reading the result later. A silent skip would mislead a future reader of the commit range into believing the team output had been simplified when it had not, so the skip and its reason are reported in the completion summary. The reason is stated specifically enough that a user reading the report can tell a real "plugin not installed" outcome from a "fellow looked up the wrong name" outcome, because the two have different remedies.

C-1 forbids the fellow from writing to the repository during the teammate-coordination phase, because the fellow as reviewer and the fellow as committer are not separable roles inside one session: once the fellow has authored a change, the reviewing eye starts to evaluate plans by how convenient they are to extend rather than by whether they address the root cause. That reasoning does not apply once teammates have finished and the team has been deleted: there are no further plans to review, and the simplification pass is itself the review, regardless of whether the pass is delegated to an agent or run inline. The fellow may therefore write to the repository during the simplification pass, whether what the fellow writes is the simplification itself or only the commits that land an agent's work. To make the boundary unambiguous, the team is deleted with TeamDelete before the pass begins, so that no teammate can be active while the fellow is touching the index.

### C-19: The wait between teammate turns schedules no prompt that names this command

Between dispatching a teammate and reading their next plan or commit, the fellow is waiting, and the natural impulse during a wait is to schedule something — a reminder to check progress, a poll for new output, a wake-up to return on a timer. Every such mechanism asks the runtime to enqueue a prompt that will be delivered as a fresh turn at a future moment, and the choice of what that prompt says decides what the future turn does. A prompt that describes a continuation ("read `TaskGet` for the dispatched teammates and resume at Step 8") simply restarts the read-and-review loop where it left off, which is harmless. A prompt that names this command, by contrast, re-enters Step 1 — and Step 1 leads to Step 7, where `TeamCreate` runs against the same input the prior run already dispatched. The teammates that result were never approved by the fellow for that moment, so they implement against no plan the fellow ever reviewed, which is the violation C-11 exists to prevent.

The fellow therefore never schedules a future prompt that names this command, regardless of which mechanism would do the scheduling. The wait is passive in that specific sense: when no teammate has produced new output, control returns to the runtime and the next turn picks up `TaskGet` and `TaskOutput` for the dispatched teammates. Pacing tools that exist for `/loop`-style self-driving — where the same prompt is meant to fire on every iteration by design — are not appropriate here, because this command is not a loop and the prompt they would carry is exactly the prompt that violates the rule above. If the user has wrapped this command in `/loop`, the loop is the user's chosen pacer and the command body adds no second one on top; that way the only path to re-invocation is the one the user can see and stop.

The rule is about the prompt, not about any particular API. A scheduling tool whose ID can be cancelled removes one failure mode (a forgotten wake-up after completion) but does not authorize scheduling the dangerous prompt in the first place, because cancellation depends on the fellow remembering to do it before the run ends, and a rule that depends on remembering is a rule that will eventually fail. Closing the question at the prompt is what removes the class of error; cancellation is at best defense in depth on top of it.

### C-20: Re-entry is recognized at the front of the workflow from artifacts the session cannot fabricate

A run can begin without a fresh user request — a wake-up from an earlier session fires, a `/loop` ticks, an external scheduler delivers a prompt — and when it does, the input the workflow sees is indistinguishable from a user invocation. The session has no record of having seen this input before, because the prior run that produced its output is either gone (a different session) or compressed (the same session's context has rolled forward). Continuing into Step 7 from such a re-entry creates a team against an input that already has a team, or did until recently, and the second team has no relationship to the work the user reviewed. The fault is not that re-entry happens; the fault is that the workflow cannot tell, from its own session state, that it is happening.

What the session cannot fabricate is the filesystem. `TeamCreate` writes `~/.claude/teams/{team-name}/config.json` and `~/.claude/tasks/{team-name}/`, and these survive across sessions and across context compressions. The fellow knows the team name it would have chosen — it is the name this fellow passes to `TeamCreate` in Step 7 — so the check is not a search across the teams directory but a targeted read of the one path this run would write to if it proceeded. The presence of that path means a prior run reached Step 7 against this input; the contents of the task store under it describe how far that prior run got. Task-store reads are advisory here in the way C-17 makes commit hashes advisory after a history rewrite: a `TaskGet` that returns "not found" can mean the prior run is genuinely gone, or it can mean the task store is slow to resolve, and the workflow does not let the ambiguous reading authorize a re-spawn. Only the presence of the team file authorizes continuation; only its absence authorizes a fresh start.

The routing follows from what the artifacts can and cannot say. When the team file is present and teammates still have outstanding work, the prior wait was interrupted; the workflow returns to that wait without re-issuing any dispatch. When the team file is present and teammates have all reported their final commits, verification may or may not have completed in the prior run — and since verification leaves no artifact the next session can read, the workflow re-runs Step 9 rather than trusting a memory it does not have. When the team file is present but its tasks describe nothing the workflow can act on, the residue is from a prior run whose simplification pass and report finished; the workflow calls `TeamDelete` to clean up and proceeds. When the team file is absent, the prior run either never reached Step 7 or already passed Step 10, and the workflow proceeds to Step 1 — the input is treated as new because the artifacts say nothing else.

The asymmetry is deliberate. The failure mode that matters is the false negative, where a real re-entry is treated as new and creates a duplicate team and a duplicate set of commits the user did not ask for. The opposite failure is the false positive, where a fresh run is treated as re-entry, and at worst it defers to artifacts that decide the workflow exits or resumes harmlessly. The check is therefore tuned so that the presence of artifacts always wins over their absence. Reading absence as "no prior run to honour" is safe because every `TeamDelete` call in this workflow is gated on the work having already passed the verification-and-handoff point. The in-flow deletion runs only after teammates have been verified and the simplification pass committed. The residue-cleanup deletion that Step 0 itself performs runs only when the task store under the team directory already shows that the prior run reached that same point. So an absent team file proves either that no prior run reached Step 7 against this input, or that whatever prior run did reach Step 7 has nothing left for a successor to resume. The argument depends on every path that removes the team file being gated on verified handoff; if a future revision introduces a deletion path that fires earlier, this asymmetry stops holding and the routing has to be reconsidered before that path is allowed to exist.
