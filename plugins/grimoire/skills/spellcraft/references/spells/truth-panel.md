# Spell: truth-panel

Put one claim before a panel of judges, each examining it through a different lens, then render a verdict from their combined findings. A PR that says it is correct, an assertion that a design is sound, a bug report that blames a particular cause — the panel contests it from several angles at once and reports whether it holds.

## When to use

Cast this when a single claim carries enough weight that it deserves adversarial scrutiny from more than one direction: a PR before it merges into something load-bearing, an architectural assertion before a team commits to it, a diagnosis before a fix is built on top of it. The value is that different lenses catch different failures — the correctness judge and the security judge and the maintainability judge each see what the others are blind to, and their disagreement is the signal.

Do not cast it on a claim with nothing to contest — a trivially true statement, a change so small one glance settles it. A panel convened over a one-line fix spends five judges' tokens to confirm the obvious. Do not cast it as a substitute for running the tests when the claim is mechanically checkable; a panel reasons about a claim, it does not replace a check that a machine can perform for certain.

## Args

- `claim` — required. The single thing under examination: a PR, a diff, an assertion, a diagnosis. Real value: `"this PR fixes the race condition without introducing a deadlock"`.
- `lenses` — optional, default correctness, security, maintainability, performance. The angles the judges examine from. One judge per lens.
- `context` — optional. What the judges need to examine the claim: the diff, the files, the surrounding design.

## Script

```js
export const meta = {
  name: 'truth-panel',
  description: 'One claim, contested by a panel through different lenses, then a verdict.',
  phases: [
    { title: 'Examine', detail: 'Each judge contests the claim through one lens' },
    { title: 'Verdict', detail: 'Combine the findings into a ruling' }
  ]
};

const lenses = args.lenses ?? [
  'correctness — does it actually hold for the real inputs, including the ugly ones?',
  'security — what does an adversary do with this?',
  'maintainability — what does living with this cost the next reader?',
  'performance — what does this cost at real scale?'
];

phase('Examine');
// Barrier: the verdict must weigh all judges together, so wait for the whole panel.
const opinions = await parallel(
  lenses.map((lens, i) => () =>
    agent(
      `The claim under examination: ${args.claim}\n\n` +
      (args.context ? `Context:\n${args.context}\n\n` : '') +
      `Contest this claim adversarially through exactly one lens: ${lens}\n` +
      `Try to break the claim. Report whether, through your lens, it holds or fails, and your strongest reason.`,
      {
        label: `judge-${i + 1}`,
        phase: 'Examine',
        schema: {
          type: 'object',
          properties: {
            lens: { type: 'string' },
            holds: { type: 'boolean' },
            strongest_point: { type: 'string' }
          },
          required: ['lens', 'holds', 'strongest_point']
        }
      }
    )
  )
);

const panel = opinions.filter(Boolean);

phase('Verdict');
const verdict = await agent(
  `A panel examined this claim: ${args.claim}\n\n` +
  `Their opinions, one per lens:\n${JSON.stringify(panel, null, 2)}\n\n` +
  `Render a verdict. Do not average the panel — weigh it. A single lens finding a real ` +
  `break can sink a claim the others approved. State the verdict, the dissent that matters, ` +
  `and what would have to change for the claim to hold.`,
  {
    label: 'verdict',
    phase: 'Verdict',
    schema: {
      type: 'object',
      properties: {
        verdict: { type: 'string' },
        holds: { type: 'boolean' },
        deciding_reason: { type: 'string' }
      },
      required: ['verdict', 'holds', 'deciding_reason']
    }
  }
);

log(`Verdict: ${verdict?.holds ? 'holds' : 'fails'} — ${verdict?.deciding_reason ?? ''}`);
```

The verdict weighs rather than averages, and that distinction is the spell's spine. A claim is not sound because most judges liked it; it is unsound the moment one lens finds a real break the others could not see. The panel exists precisely to let a single well-aimed objection outvote a comfortable majority, which is what makes it adversarial rather than a poll.
