---
name: subject-craft
description: This skill should be used when the user wants to measure whether a change to their Claude setup actually helped — evaluating a CLAUDE.md edit or a plugin, building a personal eval, writing a scoring rubric or an LLM grader, or asks "評価基盤を作りたい", "この設定変更で良くなったか測りたい", "evalの科目を作りたい", "採点のブレをどうにかしたい". Carries the craft of good subjects, observable rubrics, and stable grading behind the register, exam, and report commands.
allowed-tools: Read, Glob, Grep
---

# The Craft of the Subject

Almost everyone changes their CLAUDE.md or installs a plugin, feels that things got better, and stops there. A report card refuses that ending. It measures, so that "better" becomes a comparison with an observed before and an observed after rather than an anecdote. This skill carries what makes such a measurement trustworthy — because an eval built carelessly produces numbers that look like evidence and are not, which is worse than having no numbers at all.

- `references/subject-craft.md` — what makes a subject worth registering (representativeness, stability, gradability, the right cost per sitting), how to write a rubric that observes instead of gushing, and how to keep the grading steady enough that scores stay comparable across sittings. Read before registering a subject, and whenever the discipline behind exam or report is not already clear.

Three commands drive this skill. `/tsushinbo:register` turns a task into a subject, `/tsushinbo:exam` sits the subjects and records the grades with an environment fingerprint, and `/tsushinbo:report` issues the report card that ties score movements to configuration changes.

The one truth that outranks the rest: the grades this produces are handed down by an LLM, and an LLM's ruler wobbles. That is not a defect to hide but the fact that shapes every other choice here. The subject is fixed so the input does not drift, the grader prompt is frozen word for word so the ruler does not change between sittings, each answer is graded several times and taken at the median so one wild reading cannot dominate, and the report card is read as a trend rather than an absolute so the wobble averages out over time. A report card read as absolute truth misleads; read as a direction of travel, it is the most honest instrument most setups will ever have.
