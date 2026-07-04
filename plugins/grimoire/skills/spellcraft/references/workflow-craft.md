# Workflow Craft

The precise API a spell is built on. This is the primary source; transcribe from it, do not recall the shape from memory. Several of these rules fail silently when broken, so the details are load-bearing.

## The header

Every script begins with a metadata export, and it must be pure literals — no computed values, no interpolation:

```js
export const meta = {
  name: 'spell-name',
  description: 'One line of what it does.',
  phases: [
    { title: 'Phase One', detail: 'what happens here' },
    { title: 'Phase Two', detail: 'what happens here' }
  ]
};
```

The `phases` declared here drive the progress display the user sees. Because the export is read before the script runs, it cannot contain anything computed.

## agent()

`agent(prompt, opts)` dispatches one agent and returns a Promise resolving to its output. The options:

- `label` — a short name for the progress display.
- `phase` — which declared phase this agent belongs to.
- `schema` — a JSON Schema for structured output. See the object-wrap rule below.
- `model` — override the model for this agent.
- `effort` — the reasoning effort level.
- `isolation: 'worktree'` — run the agent in its own git worktree, so its file writes are isolated from the others. Costs a few hundred milliseconds per agent to set up; worth it only when agents write files in parallel and must not collide.

## parallel() versus pipeline() — pipeline is the default

- `parallel([...thunks])` is a **barrier**. It runs the thunks concurrently and waits for every one to finish before returning the array of results. A failed agent resolves to `null`, so filter the results: `.filter(Boolean)`. Reach for `parallel` only when the next step genuinely needs all results lined up together — a cross-comparison, a vote, a synthesis over the whole set.
- `pipeline(items, stage1, stage2, ...)` advances each item through the stages **independently**, with no barrier between items. Every stage callback receives `(prevResult, originalItem, index)` — a later stage can name or label its work by the original item without threading it through the first stage's return value. The great-migration spell relies on exactly this. Item three can be in stage two while item one is still in stage one. This is the default for per-item work, because it starts producing results immediately and does not let one slow item stall the rest.

The discipline: **default to pipeline, use a barrier only when the whole set must be reconciled at once.** Choosing `parallel` when `pipeline` would do forces every item to wait for the slowest, for no benefit.

## The schema object-wrap trap

The top level of any `schema` must be a JSON Schema `object`. Pass a top-level array and the API rejects it with a 400, and the agent returns empty — with no error surfaced into the script. This is the single most common silent failure in Workflow authoring, confirmed in practice.

Always wrap a list in an object:

```js
// WRONG — top-level array, silently returns nothing
schema: { type: 'array', items: { type: 'string' } }

// RIGHT
schema: {
  type: 'object',
  properties: {
    items: { type: 'array', items: { type: 'string' } }
  },
  required: ['items']
}
```

## The forbidden nondeterministic calls

A Workflow must be resumable: re-running it with `resumeFromRunId` replays completed `agent()` calls from cache and continues from where it stopped. That only works if the script is deterministic, so anything nondeterministic throws:

- `Date.now()`
- `Math.random()`
- `new Date()` with no argument.

Do not use them for ids, seeds, or timestamps. Derive ids from `args` or from a loop index instead.

## The rest of the toolkit

- `phase(title)` — mark the current phase for the progress display.
- `log(msg)` — write a line to the run log; use it to record decisions like a scaled-down fan-out.
- `args` — the input passed when the workflow was invoked.
- `budget.total`, `budget.spent()`, `budget.remaining()` — the token budget. Check `remaining()` before committing to a large fan-out.

## Concurrency and scale limits

Concurrent agents cap at roughly 10–16 at once; requesting more just queues the overflow, it does not run them all at once. The total agent count across a run caps at 1000. Worktree isolation adds its per-agent setup cost. So a fan-out of thousands is not thousands in flight — it is a queue draining through a window of about a dozen. Size the fan-out and the budget with that window in mind.

## Budget-linked scaling

Before a large fan-out, read `budget.remaining()` and scale the agent count to fit it. When you scale down from what was asked, `log()` that you did and why, so the run's smaller size is a recorded decision rather than a silent shortfall. Overspending the budget and under-delivering without a word are both worse than a logged adjustment.
