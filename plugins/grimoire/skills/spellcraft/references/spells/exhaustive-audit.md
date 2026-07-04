# Spell: exhaustive-audit

Audit a target until it is dry — until a fresh pass of adversarial reviewers surfaces no new findings. A single audit pass finds what it finds and stops; this spell repeats the pass, feeding each round the findings already known so it hunts only for what earlier rounds missed, until a round comes back empty.

## When to use

Cast this when a target is important enough that "we looked once" is not good enough — a security-sensitive module, a release candidate, a subtle refactor whose bugs hide behind other bugs. The value is in the loop: the first pass finds the obvious problems, and only with those cleared can a later pass see the ones they were hiding.

Do not cast it on a target with a small, bounded surface a single review covers completely, or on trivial code where a second pass is guaranteed to come back empty on the first try. The loop earns its cost only when there is genuinely a deep pile to work through. It also spends tokens proportional to how many rounds it takes to go dry, so a target that never quite dries out can run long — cap the rounds.

## Args

- `scope` — required. What to audit: a path, a set of files, a module. Real value: `"src/auth"` or `"the payment reconciliation flow"`.
- `maxRounds` — optional, default 4. The ceiling on audit rounds, so a target that never fully dries does not run forever.
- `lens` — optional, default `"correctness and security"`. What the reviewers hunt for.

## Script

```js
export const meta = {
  name: 'exhaustive-audit',
  description: 'Audit a target in rounds until an adversarial pass finds nothing new.',
  phases: [
    { title: 'Audit', detail: 'Adversarial reviewers hunt for findings' },
    { title: 'Verify', detail: 'A skeptic confirms each finding is real' }
  ]
};

const scope = args.scope;
const maxRounds = args.maxRounds ?? 4;
const lens = args.lens ?? 'correctness and security';

const found = [];

for (let round = 1; round <= maxRounds; round++) {
  phase('Audit');
  log(`Round ${round}: auditing ${scope} through the lens of ${lens}.`);

  // Barrier: three reviewers hunt in parallel, then we reconcile before verifying.
  const reviewers = await parallel(
    [1, 2, 3].map((r) => () =>
      agent(
        `Audit ${scope} for ${lens}. Hunt adversarially for defects.\n` +
        `These findings are already known — do not repeat them, find what they missed:\n` +
        (found.length ? found.map((f) => `- ${f.claim}`).join('\n') : '(none yet)'),
        {
          label: `reviewer-${round}-${r}`,
          phase: 'Audit',
          schema: {
            type: 'object',
            properties: {
              findings: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    claim: { type: 'string' },
                    location: { type: 'string' },
                    severity: { type: 'string' }
                  },
                  required: ['claim', 'location', 'severity']
                }
              }
            },
            required: ['findings']
          }
        }
      )
    )
  );

  const fresh = reviewers
    .filter(Boolean)
    .flatMap((r) => r.findings ?? []);

  if (fresh.length === 0) {
    log(`Round ${round} came back dry. The target is exhausted.`);
    break;
  }

  phase('Verify');
  // Each candidate finding is confirmed independently — pipeline, no barrier needed.
  const confirmed = await pipeline(
    fresh,
    (f) =>
      agent(
        `A reviewer claims: "${f.claim}" at ${f.location} (severity ${f.severity}).\n` +
        `You are a skeptic. Confirm it is real and reproducible, or reject it as a false positive. ` +
        `Explain which and why.`,
        {
          label: `verify`,
          phase: 'Verify',
          schema: {
            type: 'object',
            properties: {
              claim: { type: 'string' },
              real: { type: 'boolean' },
              reasoning: { type: 'string' }
            },
            required: ['claim', 'real', 'reasoning']
          }
        }
      )
  );

  const real = confirmed.filter((c) => c && c.real);
  found.push(...real);
  log(`Round ${round}: ${fresh.length} raised, ${real.length} confirmed real.`);
}

log(`Audit complete. ${found.length} confirmed findings across all rounds.`);
```

The adversarial split is deliberate: the reviewers hunt and the skeptic confirms, so a reviewer's false positive does not enter the record and does not get counted as progress toward "dry". A round is dry when the hunters find nothing new to raise, not when the skeptic rejects everything — those are different states, and only the first ends the loop.
