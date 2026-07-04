# Reading Drift: Stale Copy versus Deliberate Local Edit

When a distributed file differs between the origin and a destination, the difference means one of two very different things, and the whole safety of fleet-sync rests on telling them apart:

- **Stale copy** — the destination holds an older version of a shared file. The origin has moved on and the destination has not caught up. The right action is to refresh the destination from the origin. This is what `/fleet-sync:push` does.
- **Deliberate local edit** — someone changed the shared file *in the destination*, on purpose, to fit that project. Overwriting it would destroy a real decision. The right action is to withhold the file and surface it to the user as a re-import candidate, so they can decide whether the local change belongs back in the origin for the whole fleet.

Confusing the second for the first is the one unrecoverable failure this tool can commit. A stale copy left one cycle longer is a small, self-correcting cost. A deliberate local edit silently overwritten is lost work and lost intent, and the user may not even notice until much later. So the asymmetry is deliberate and absolute: when in doubt, treat a difference as a deliberate local edit and withhold it.

## How to tell them apart

There is no perfect signal, because fleet-sync is a synchronization tool and not a version-control system — it does not carry the history that would make the distinction certain. What it can do is weigh evidence. The following raise the likelihood that a difference is a *deliberate local edit* rather than a stale copy:

- **The destination's version is newer than the origin's** by modification time. A stale copy is older than the origin by definition; a destination file modified *after* the origin's was last changed is unlikely to be a copy that simply fell behind.
- **The destination's version contains content the origin never had.** A stale copy is a subset-or-earlier form of the origin's history — it lacks the origin's newer additions. A destination that has added something of its own, especially something project-specific, has diverged deliberately.
- **The destination is under git and the file shows local commits touching it.** If the destination's own history records someone editing this file there, that is direct evidence of intent. (Check this only when the destination is a git repository; do not assume it is.)
- **The change is small and local-looking** — a single value swapped, a project name substituted, a section added — rather than the destination lagging the origin's structure wholesale.

Conversely, a difference is more likely a *stale copy* when the destination's version is strictly older, lacks the origin's recent additions, and shows no sign of independent editing — it simply looks like an earlier snapshot of the same file.

## When the evidence is genuinely mixed

Sometimes the signals conflict or none is available — the destination is not a git repository, timestamps are unreliable, the diff is ambiguous. In that case, do not guess toward overwriting. Classify the difference as a re-import candidate and withhold it. The user reviewing one extra re-import candidate costs a moment of attention; a wrong overwrite costs lost work. The tie always breaks toward preservation.

## What "re-import candidate" hands back to the user

Flagging a re-import candidate is not the end of a decision; it is the start of one the user owns. Two paths lead out of it, and the tool takes neither on its own:

- **Fold the change back into the origin.** If the local edit is actually an improvement the whole fleet should have, the user copies it into the origin, and on the next cycle it distributes to everyone — including, now in sync, the destination that originated it.
- **Discard the local edit.** If the local change was a mistake or is no longer wanted, the user overwrites it deliberately by re-running push after acknowledging it, or by editing the destination themselves.

The tool's job ends at making the choice visible and clear. It distinguishes the copy that fell behind from the edit made on purpose, and it never resolves the second kind silently.
