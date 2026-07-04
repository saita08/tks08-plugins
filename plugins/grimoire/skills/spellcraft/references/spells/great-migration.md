# Spell: great-migration

Apply one mechanical change across many targets, each converted in its own isolated worktree and verified independently. Enumerate the targets, transform each in parallel without them colliding, check each result, and report which converted cleanly and which need a human.

## When to use

Cast this when the same transformation must land on many files and the transformation is mechanical enough to describe once: rename an API across a codebase, migrate a framework's call sites, convert a config format, apply a codemod that has edge cases too gnarly for a plain find-and-replace. The value is that each target is handled by its own agent that can reason about that file's specifics, in a worktree isolated from the others, so a hard case gets real attention without blocking the easy ones.

Do not cast it when a mechanical find-and-replace would do the whole job — that is cheaper and more predictable, and dispatching an agent per file to do what `sed` does is waste. Do not cast it when the change is not actually uniform across targets, because then it is not one migration but many different changes wearing one name, and the shared prompt will mistranslate the ones that differ.

## Args

- `targets` — required. What to migrate: a glob, a list of files, or an instruction to enumerate. Real value: `"**/*.test.js"` or `"every call site of the old logger"`.
- `change` — required. The transformation, described once for all targets. Real value: `"replace calls to oldLog(x) with logger.info(x), preserving the message"`.
- `verify` — optional, default `"the file still parses and its tests pass"`. How to confirm one target converted correctly.

## Script

```js
export const meta = {
  name: 'great-migration',
  description: 'Convert many targets by the same rule, each in an isolated worktree, then verify.',
  phases: [
    { title: 'Enumerate', detail: 'List the targets to migrate' },
    { title: 'Convert', detail: 'Transform each target in its own worktree' },
    { title: 'Verify', detail: 'Confirm each conversion is correct' }
  ]
};

phase('Enumerate');
const enumeration = await agent(
  `List the concrete targets to migrate for: ${args.targets}. ` +
  `Return one entry per target — a file path or an identifiable unit of work.`,
  {
    label: 'enumerate',
    phase: 'Enumerate',
    schema: {
      type: 'object',
      properties: {
        targets: { type: 'array', items: { type: 'string' } }
      },
      required: ['targets']
    }
  }
);

const targets = enumeration?.targets ?? [];
log(`Enumerated ${targets.length} targets to migrate.`);

// Scale to the budget: each target is a full agent in a worktree.
const budgetPerTarget = 40_000; // rough tokens per convert-and-verify chain; tune per spell
const affordable = Math.floor(budget.remaining() / budgetPerTarget);
const batch = targets.slice(0, Math.min(targets.length, affordable));
if (batch.length < targets.length) {
  log(`Budget covers ${batch.length} of ${targets.length} targets this run.`);
}

// pipeline: each target converts and verifies on its own, no barrier — a slow
// file must not stall the rest, and there is nothing to reconcile across them.
phase('Convert');
const results = await pipeline(
  batch,
  (target) =>
    agent(
      `In your isolated worktree, apply this change to ${target}:\n${args.change}\n` +
      `Make only this change. Preserve everything else. Produce a real diff.`,
      { label: `convert`, phase: 'Convert', isolation: 'worktree' }
    ),
  (converted, target) =>
    agent(
      `The migration of ${target} is done. Verify: ${args.verify ?? 'the file still parses and its tests pass'}.\n` +
      `Report whether it converted cleanly or needs a human, and why.\n\n${converted}`,
      {
        label: `verify`,
        phase: 'Verify',
        schema: {
          type: 'object',
          properties: {
            target: { type: 'string' },
            clean: { type: 'boolean' },
            note: { type: 'string' }
          },
          required: ['target', 'clean', 'note']
        }
      }
    )
);

const clean = results.filter((r) => r && r.clean);
const needsHuman = results.filter((r) => r && !r.clean);
log(`Migration: ${clean.length} clean, ${needsHuman.length} need a human.`);
```

Worktree isolation is what makes the parallel conversion safe: every target's agent edits its own copy of the tree, so two agents touching neighboring files never trip over each other's half-written changes. The verify stage runs per target rather than as a final barrier, so the report tells you exactly which files converted cleanly and which need a human, without one hard file holding up the news about the easy ones.
