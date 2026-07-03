# When a Goal Warrants a Sketch

This file sharpens the two-condition test from the skill body — ambiguous *and* expensive to redo — into concrete signals, names the false positives that make this skill annoying when it fires wrongly, and draws the boundary with the built-in plan mode.

## Signals that a goal is genuinely ambiguous

The words the user used would be satisfied by several materially different results. Watch for:

- **Abstract nouns with no adjectives.** "A dashboard", "an onboarding flow", "a landing page", "a CLI for this" — the category is named but nothing narrows it. Twenty different dashboards would all be "a dashboard".
- **Aesthetic or feel words with no reference.** "Make it clean", "something modern", "professional", "いい感じに" — these name a direction without a destination, and your idea of "clean" and theirs may not overlap.
- **A goal stated as a solution to an unstated problem.** "Add a settings page" — for whom, to change what? The stated artifact may not even be the thing that solves their actual problem.
- **The user themselves signaling uncertainty.** "Something like…", "I'm not sure exactly, but…", "maybe a…". They are telling you the picture is not yet sharp.

## Signals that redoing is expensive

The interview earns its cost only when guessing wrong is costly. Watch for:

- The work is large or slow to produce — a whole page, a multi-step flow, a schema, anything that takes real time to build and real time to throw away.
- Getting it wrong cascades — other work will be built on top of this, so a wrong foundation is not just this task's rebuild but everything downstream.
- The user has limited attention for iteration — they want to hand it off and come back, not sit in a tight loop of "no, more like this".

## Common false positives (do NOT propose sketching)

- **Well-specified requests.** "Add a `--verbose` flag that prints the config path" is ambiguous in no meaningful way. Just do it.
- **Cheap-to-redo work.** A single component you can regenerate in seconds, a color tweak, a copy edit. Here guessing and iterating is faster than interviewing, and the interview is pure overhead. The asymmetry that justifies the sketch is gone.
- **The user is mid-flow and moving fast.** If they are iterating quickly and clearly enjoying the loop, interrupting to interview breaks their momentum for a benefit they are not asking for.
- **You already have the picture.** If the surrounding project, an existing design, or the conversation so far already fixes what "good" means here, there is nothing to draw out. Sketching would ask questions whose answers you can already see.
- **A quick throwaway or exploration.** "Just rough something in so I can see it" is an explicit request to guess. Honor it.

When in doubt and genuinely torn, lean toward *not* interrupting. A missed sketch costs an iteration; an unwanted interview costs trust in the tool, and a tool the user has learned to wave off has lost the true positives along with the false ones.

## The boundary with plan mode

This is the distinction the README leads with, and it matters here too. The built-in plan mode plans *how* to implement something — the steps, the files, the sequence. It assumes the *what* is settled. A sketch settles the *what*: the shared picture of the thing to be built, in the user's terms, before any implementation question is on the table.

They compose rather than compete. Sketch first to agree on what to build; then plan mode to work out how. Running the sketch first is what makes a plan reviewable — a detailed plan for building the wrong thing is worse than no plan, because its very thoroughness makes the wrong target look decided. If you find yourself in plan mode unsure what the end product even is, that is the signal you skipped the sketch.
