# The Craft of a Good Subject

A report card is only as trustworthy as the subjects it grades. A careless subject produces a number that carries the authority of measurement without its substance, and a setup steered by such numbers drifts confidently in the wrong direction. This file records what makes a subject worth registering, how to write a rubric that measures rather than flatters, and how to keep the grading steady enough that one sitting can be compared to the next. These are values, not a checklist; when a case is not covered, reason from why each property matters rather than reaching for a rule.

## What a good subject has

**Representativeness.** A subject is a proxy: its score stands in for how well the setup does a whole class of real work. So a subject must be drawn from work the user actually does and cares about, not from a puzzle that is easy to grade but that nobody's day depends on. A high score on an unrepresentative subject is a comfort, not a signal. When choosing what to register, prefer the task whose improvement the user would genuinely feel over the task that merely scores cleanly.

**Stability.** A subject must produce the same conditions every time it is sat, because a score that moves for reasons other than the setup's ability is noise dressed as signal. This is the property most often broken by accident. An assignment that reads today's date, calls a live service whose answers change, depends on a file that other work rewrites, or reaches a network resource that may be down will score differently across sittings for reasons that have nothing to do with what is being measured. Fix every input as part of the subject: embed the data the task needs, name exact paths to frozen files, and strip out anything that drifts. If a task cannot be made stable, it cannot be a subject — measuring against a moving target measures nothing.

**Gradability.** A subject must have an answer a grader can score the same way twice. A task whose quality is a matter of taste, or whose correctness no one can state in observable terms, will get a different score each time it is graded regardless of the answer, and that variance swamps the signal. Before registering a subject, ask whether its rubric can be written in checkable terms. If it cannot, the task is not yet a subject; sharpen it until success is something a grader can point at.

**The right cost per sitting.** A subject should cost enough to exercise the setup meaningfully and little enough that sitting the whole report card is not a decision the user avoids. A subject so trivial it always scores full marks measures nothing, because it cannot move when the setup changes. A subject so vast that one sitting takes an hour and a fortune will be sat once and never again, and a subject sat once produces no trend. Aim for the middle: substantial enough to discriminate between a better and a worse setup, cheap enough to sit often.

## Writing a rubric that observes

A rubric is a set of criteria, each stating a specific checkable thing about the answer and what it is worth. The discipline is a single ban: no criterion may turn on a word like "good", "clear", "well-written", or "high-quality". Those words hand the grader a judgment call, and a judgment call is exactly the wobble the whole design fights to remove. Replace each with what it is standing in for.

"The answer is well-structured" becomes "the answer addresses each of the three required parts in a separate section". "The code is good" becomes "the function handles the empty-input case and does not throw on it". "The explanation is clear" becomes "the explanation names the specific cause, not just the symptom". Each rewrite turns a feeling into something a grader can find present or absent by looking. A criterion two careful graders would score differently is not yet a criterion; it is a preference, and it belongs in the assignment as a requirement or nowhere.

Weight the criteria so the ones that matter most carry the most, and keep the total to a fixed scale so scores are comparable across subjects. A rubric that lists twenty equally-weighted trivia lets a setup ace the trivia and fail the substance while scoring well; a rubric weighted toward what actually matters cannot be gamed that way.

## Keeping the grading steady

Even a perfect rubric is applied by an LLM, and an LLM grades the same answer differently from one run to the next. The design answers this wobble in four places, and each matters:

**Fix the grader prompt word for word.** The grader prompt is frozen when the subject is registered and never edited. This is the subtlest and most important discipline. If the grader prompt changes between two sittings, the two scores were produced by two different instruments and cannot be compared — and the entire purpose of the report card is comparison. An improvement to a grader prompt is not an improvement to an existing subject; it is a new subject, with its own fresh score history. Treat editing a grader prompt as starting over, because that is what it does.

**Grade the examinee blind.** The examinee that sits the subject must not know the rubric or that it is being graded. An examinee shown the rubric teaches to the test, and its score measures how well the rubric leaked rather than how well the setup works. Keep the assignment and the rubric strictly apart: the examinee sees only the assignment.

**Grade several times and take the median.** One grading inherits the wobble whole. Several gradings of the same answer, reduced to their median, cancel the outliers — the median rather than the mean, so a single wild reading cannot drag the result. This is the cheapest large gain in reliability available, and it is why a sitting runs the grader more than once.

**Read the trend, never the absolute.** The number a subject scores on any one sitting is not a truth about the setup; it is one noisy sample. Meaning lives in the movement across sittings, especially across the boundaries where the configuration changed. A single sitting says almost nothing. A report card with two subjects and three sittings is still mostly noise, and saying so plainly is more honest than pretending three points make a line. The instrument earns its trust only as the ledger fills, and until then its own thinness is the most important thing to report.
