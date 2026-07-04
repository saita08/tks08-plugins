# Spell: deep-survey

Answer a question too broad for one agent to hold at once: fan out to investigate the facets in parallel, read the promising ones deeply, then synthesize a single report. Breadth first, then depth, then one coherent answer.

## When to use

Cast this when a question spans more ground than a single agent can survey and reason about in one pass: "how does authentication flow through this whole system", "what are the real options for replacing this dependency", "where does this codebase handle money and is any of it wrong". The value is the three-stage shape — a wide scan finds the facets, deep reads mine the ones that matter, and a synthesis stitches the findings into an answer that no single facet's investigator could have written.

Do not cast it on a question one agent can already answer well — a focused lookup, a single-file question, something a search would settle. The three-stage machinery is overhead when the question was never too big for one head. Do not cast it when the question is really a decision the user must make rather than information to gather; a survey informs a decision, it does not make one.

## Args

- `question` — required. The broad question to answer. Real value: `"how does this service authenticate requests end to end, and where are the weak points"`.
- `breadth` — optional, default 6. How many facets the initial scan splits the question into.
- `scope` — optional. Where to look: a repository, a subsystem, a set of docs.

## Script

```js
export const meta = {
  name: 'deep-survey',
  description: 'Scan broad, read deep, synthesize one report.',
  phases: [
    { title: 'Scan', detail: 'Split the question into facets and survey each' },
    { title: 'Deepen', detail: 'Read the promising facets closely' },
    { title: 'Synthesize', detail: 'Stitch the findings into one answer' }
  ]
};

const breadth = Math.min(args.breadth ?? 6, 12);

phase('Scan');
const map = await agent(
  `Split this question into ${breadth} distinct facets worth investigating separately: ${args.question}` +
  (args.scope ? `\nScope: ${args.scope}` : ''),
  {
    label: 'map',
    phase: 'Scan',
    schema: {
      type: 'object',
      properties: {
        facets: { type: 'array', items: { type: 'string' } }
      },
      required: ['facets']
    }
  }
);

const facets = (map?.facets ?? []).slice(0, breadth);
log(`Split into ${facets.length} facets.`);

// pipeline: each facet is scanned then deepened independently — no barrier until
// synthesis, so a deep read on one facet does not hold up the others.
const investigated = await pipeline(
  facets,
  (facet) =>
    agent(
      `Survey this facet of the question broadly: ${facet}\n` +
      `Report what you find and whether it is worth a closer read.`,
      {
        label: 'scan-facet',
        phase: 'Scan',
        schema: {
          type: 'object',
          properties: {
            facet: { type: 'string' },
            finding: { type: 'string' },
            worth_deepening: { type: 'boolean' }
          },
          required: ['facet', 'finding', 'worth_deepening']
        }
      }
    ),
  (scan) =>
    scan && scan.worth_deepening
      ? agent(
          `Read this facet closely and report what a shallow scan would have missed:\n` +
          `Facet: ${scan.facet}\nInitial finding: ${scan.finding}`,
          { label: 'deepen', phase: 'Deepen' }
        )
      : scan?.finding ?? ''
);

// Barrier is inherent here: synthesis needs every facet's result at once.
phase('Synthesize');
const report = await agent(
  `Synthesize one coherent answer to: ${args.question}\n\n` +
  `From these facet investigations:\n${JSON.stringify(investigated, null, 2)}\n\n` +
  `Do not just concatenate the facets — stitch them into a single answer that names the ` +
  `connections between them and calls out where they contradict.`,
  { label: 'synthesize', phase: 'Synthesize' }
);

log('Survey complete.');
```

The three stages are not decoration — each earns its place. The scan is wide and cheap so nothing is missed. The deepening is selective, spending the expensive close reads only on the facets the scan flagged, so budget goes where the substance is. And the synthesis is a real stitch rather than a staple: its whole job is to find the connections and contradictions across facets that no single facet's investigator was positioned to see.
