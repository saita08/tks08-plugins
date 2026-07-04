# Independence Is the Whole Point

The value of a tournament is that its attempts have no shared anchor. The moment they can see each other, they lose that, and you have paid N times for one draft wearing N costumes. This file is about protecting independence in the Generate phase.

## Why contamination kills diversity

Ideas are contagious. If attempt B can see attempt A's work, B does not start from the task — it starts from A, and its own contribution shrinks to a reaction to A. This feels like collaboration and produces the opposite of what a tournament is for. Instead of five probes into the space of solutions, you get one probe and four echoes clustered around it. The diversity that would have mapped the target is gone before the judging even begins.

This is why each worker in the Generate phase is told the task and its assigned angle, and is never told that other attempts exist. Each one believes it is the only universe. That belief is what keeps its attempt anchored to the task rather than to a sibling.

## How isolation is enforced

Two mechanisms keep the universes apart:

- **Blind prompts.** No worker's prompt mentions the others, quotes their output, or hints at a comparison. The angle is framed as *the* way to approach the task, not as one of several. A worker that knows it is competing will hedge toward a defensible middle; a worker that thinks it is alone commits to its angle.
- **Worktree isolation.** Each attempt runs with `isolation: 'worktree'`, so it writes files into its own copy of the tree. This is not only about avoiding collisions when N workers edit the same paths in parallel — it is about ensuring no worker can read another's in-progress changes off the disk. The worktrees are sealed rooms.

Worktree isolation costs a few hundred milliseconds per worker to set up. That cost is worth paying whenever the attempts write files, which in this tournament they always do. The price of isolation is trivial next to the price of contamination, which silently voids the entire run.

## The one thing shared: the task

The workers share exactly one thing — the task itself, stated identically to each. Everything downstream of the task diverges. This is the correct and only shared input: a tournament measures different routes to the same destination, so the destination is fixed and the routes are free.
