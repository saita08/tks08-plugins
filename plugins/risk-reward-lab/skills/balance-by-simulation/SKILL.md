---
name: balance-by-simulation
description: This skill should be used when deciding or changing a game's rules or numbers (starting money, probabilities, counts, prices, rewards), and when checking "難しすぎる", "簡単すぎる", "この仕組みは効いているか", "一つの手だけで勝てないか", "too hard", "too easy", "does this mechanic matter", "is there a dominant strategy", or "balance this". Plays the game's logic thousands of times without a screen and lays the before and after side by side in a table.
allowed-tools: Read, Write, Edit, Bash(node:*)
---

# Measure Numbers by Simulation Before Deciding Them

Numbers chosen by an expected feel often turn out, when measured, not to work: the difficulty does not rise in the later stages, a constraint put on the opponents almost never applies. Decide numbers only after running the play thousands of times without a screen and measuring.

The value at the core: a claim about a game's balance is a claim about the world, so it is measured, and a change is shown as a before and an after, never as a belief.

## Put in the measuring point

Put it in when the game starts. Adding it later needs the code to have the right shape.

1. Write the play logic so that storage, ads, randomness and the clock are passed in as arguments, not reached for. Keep them out of the domain model and inject them from the entry point.
2. Create `<game>/sim/run.mjs` that calls the play logic directly. It loads not one line of screen code.
   - Storage is replaced by a stand-in that does nothing, ads by one that never shows.
   - The clock is a stand-in advanced one step at a time, so even a game with waiting finishes in an instant.
   - The random seed is fixed. The same seed gives the same result.
3. Write strategies as functions. A strategy only returns which move to make, given the current state.

## Which strategies to line up

At least these three kinds:

- **Do nothing**: the floor. If this wins, the rules are broken.
- **Play by values not on screen**: an upper bound. The player can never reach it.
- **Play only by what is on screen**: close to the player's experience. Put a strategy that reads the clues and one that does not side by side; the gap between them is how much the reading mechanism is worth.

When a mechanism is added, run a strategy that uses it and one that does not, on the same seed.

In a game of choosing moves, line up every strategy that repeats a single move. Put the player's decision delay into the strategies too, and run a fast and a slow decider.

## Measure

```
node <game>/sim/run.mjs 1000
```

Report not only the mean but the bottom tenth, the median and the top tenth. Also report by the breaks the player feels: per stage within a run, and how many runs it takes to collect everything.

Read the rise of difficulty as the sequence of scores per stage. A flat stretch, or a jump at one stage, means the rise has broken. Growing the opponents' resources sharply in later stages makes a jump; a knob that only matters when a resource runs out stops making difficulty from the stage where it no longer runs out. Move one knob at a time, measure which stage it acts on, then choose.

## Check the shape of the play

Before balancing numbers, check that the play has not collapsed into one move. When the play changes, pass these five before it goes in.

1. No strategy that repeats one move wins.
2. The reading strategy scores above the best single move.
3. A slow decider does not lose to a fast one.
4. Rounds in which nothing can be done (dead ends) do not increase.
5. When a clue is added, the order is "reads both > reads only the board > reads only the clue > reads nothing". If reading only the clue reaches reading the board, the clue has become the answer.

When the non-reading strategy's score falls, record by how much, and teach how to read in the how-to-play pages. Measure the time each move takes as well, and confirm it is no slower than before.

## Decide and record

1. Produce the table before the change and the table after it, with the same seed and the same count, and set them side by side.
2. Record the chosen values and the values tried and discarded in a decision record (an ADR, where the project keeps them).
3. Write the chosen values into the game's specification, with the measured table and how to run it.
4. When a rule changes, fix the simulation's strategies in the same change and measure again. Do not leave an old table behind.

When someone else decides a number, show them the side-by-side tables and wait for their decision. Otherwise measure and decide, and report the value before and after.

A simulation does not replace the feel of playing. Leave in the specification what is still to be confirmed by playing.
