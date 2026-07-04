# The Workflow Shape

This tournament is a Claude Code Workflow script — a deterministic program that orchestrates a team of agents. This file is the exact API the script is built on and the exact shape it takes. Transcribe carefully; the schema rule in particular is a real trap that silently returns nothing when violated.

## The primitives

- **`export const meta`** sits at the top of the script and must be pure literals — no computed values. Shape: `{ name, description, phases: [{ title, detail }] }`. The phases declared here are what the user sees as progress.
- **`agent(prompt, opts)`** dispatches one agent and returns a Promise. `opts`: `{ label, phase, schema, model, effort, isolation }`. `schema` gives structured output as JSON Schema; `isolation: 'worktree'` runs the agent in its own git worktree; `label` and `phase` are for progress display.
- **`parallel([...thunks])`** is a barrier: it runs the thunks concurrently and waits for all to finish. A failed agent comes back as `null`, so filter: `.filter(Boolean)`. Use `parallel` when you must line up all results and compare them — which the tournament does, twice.
- **`pipeline(items, stage1, stage2, ...)`** advances each item through the stages independently, with no barrier. Stage callbacks receive `(prevResult, originalItem, index)`. It is the default for per-item work; the tournament does not use it, because it genuinely needs the barrier.
- **`phase(title)`**, **`log(msg)`**, **`args`** (the invocation input), and **`budget`** (`budget.total`, `budget.spent()`, `budget.remaining()`) round out the toolkit.

## The schema object-wrap rule

The top level of any `schema` must be a JSON Schema `object`. Passing a top-level array is rejected by the API with a 400, and the agent returns empty — silently, with no error surfaced into the script. This is confirmed in practice and it is the single most common way a Workflow script fails quietly.

So a judge that wants to return a list of scores must wrap it:

```js
// WRONG — top-level array, rejected, returns nothing
schema: { type: 'array', items: { /* ... */ } }

// RIGHT — wrapped in an object
schema: {
  type: 'object',
  properties: {
    scores: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          attempt: { type: 'string' },
          score: { type: 'number' },
          reason: { type: 'string' }
        },
        required: ['attempt', 'score', 'reason']
      }
    }
  },
  required: ['scores']
}
```

## The forbidden calls

Workflow scripts must be resumable, so anything nondeterministic throws: `Date.now()`, `Math.random()`, and `new Date()` with no argument. Do not reach for them to generate ids or seeds — derive from `args` or the loop index instead.

## The three-phase shape

```js
export const meta = {
  name: 'parallel-universe',
  description: 'Independent attempts, judged by lenses, grafted.',
  phases: [
    { title: 'Generate', detail: 'Independent attempts in isolated worktrees' },
    { title: 'Judge', detail: 'Score each attempt through one lens' },
    { title: 'Synthesize', detail: 'Graft the winner with the best of the rest' }
  ]
};

const N = Math.min(Math.max(args.n ?? 3, 2), 5);
const angles = [
  'Optimize for the smallest change that fully solves the task.',
  'Optimize for what happens when things go wrong.',
  'Optimize for speed and resource use under real load.',
  'Optimize for the person on the other end of this code.',
  'Question the frame — try the approach the others would reject.'
];

phase('Generate');
// Barrier: line up all attempts before judging. Each is blind to the others.
const attempts = await parallel(
  Array.from({ length: N }, (_, i) => () =>
    agent(
      `Task: ${args.task}\n\nApproach: ${angles[i]}\n` +
      `You are the only one working on this. Produce a real diff in your worktree.`,
      { label: `universe-${i + 1}`, phase: 'Generate', isolation: 'worktree' }
    )
  )
);
const live = attempts.filter(Boolean);

phase('Judge');
const lenses = [
  ['correctness', 'Does it actually do the task, for real inputs including the ugly ones?'],
  ['simplicity', 'How much must a reader hold in their head to live with this?'],
  ['intent-fit', 'Does it match what the user was truly reaching for?']
];
const verdicts = await parallel(
  lenses.map(([name, question]) => () =>
    agent(
      `Score each attempt through one lens only: ${question}\n\nAttempts:\n` +
      live.map((a, i) => `universe-${i + 1}:\n${a}`).join('\n\n'),
      {
        label: `judge-${name}`,
        phase: 'Judge',
        schema: {
          type: 'object',
          properties: {
            scores: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  attempt: { type: 'string' },
                  score: { type: 'number' },
                  reason: { type: 'string' }
                },
                required: ['attempt', 'score', 'reason']
              }
            }
          },
          required: ['scores']
        }
      }
    )
  )
);

phase('Synthesize');
const synthesis = await agent(
  `Winner and runners-up below, with their scores. Take the winner as the base ` +
  `and propose specific grafts from the runners-up — name each graft and its source universe. ` +
  `Do not blend; graft.\n\n${JSON.stringify(verdicts)}`,
  { label: 'synthesize', phase: 'Synthesize' }
);
```

## Budget-linked scaling

Before committing to N, check `budget.remaining()`. Each universe is a full agent run in its own worktree, so N attempts cost roughly N times a single one, plus three judges. If the remaining budget cannot cover the requested N, scale N down and `log()` that you did, so the user knows they got a three-universe run instead of the five they asked for and why. Silently overspending or silently under-delivering are both worse than a logged adjustment.
