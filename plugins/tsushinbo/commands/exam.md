---
description: Sit the exam — have a fresh, knowledge-free examinee solve each subject, grade it with the fixed grader run several times and taken at the median, and append the score with an environment fingerprint.
argument-hint: "[科目名（複数可、省略時は全科目）]"
allowed-tools: Read, Glob, Grep, Bash
---

# Sit the Exam

Administer the registered subjects and record the grades. The result of this command is not a feeling that things improved; it is a number, appended to a durable ledger alongside a fingerprint of the environment that produced it, so a later reader can tell which configuration earned which score.

Read `${CLAUDE_PLUGIN_ROOT}/skills/subject-craft/references/subject-craft.md` if the grading discipline — fixed grader, several sittings, the median, reading the trend not the absolute — is not already clear. The reference carries why each of these exists; this command carries out the procedure.

## Step 1 — Select the subjects

Read the subjects in `~/.claude/tsushinbo/subjects/`. If `$ARGUMENTS` names one or more, sit only those. If none are named, sit all of them. If the directory is empty, say so and point the user to `/tsushinbo:register`; there is nothing to examine.

## Step 2 — Take the environment fingerprint

Before any sitting, capture what environment this exam runs under, so the scores can later be tied to the configuration that produced them. The fingerprint is two hashes:

- A hash of the active `CLAUDE.md` files — the project `CLAUDE.md` and the user's global `~/.claude/CLAUDE.md` if present. Concatenate and hash them.
- A hash of the enabled-plugins set. Read the enabled plugins from the Claude settings and hash the sorted list of their names.

Compute both with a stable tool (`shasum` or `sha256sum`), and keep the first several characters of each. The fingerprint's purpose is identity, not secrecy: two exams with the same fingerprint ran under the same configuration, and a change in either hash marks the boundary where something was altered. Do not embed the file contents themselves in the ledger — only the hashes.

## Step 3 — Sit each subject with a fresh examinee

For each subject, have the assignment solved by an examinee that carries no prior knowledge — not this conversation's context, not the subject's rubric, not the fact that it is being graded. Knowing the rubric would let the examinee teach to the test, and a score earned that way measures the rubric's leakage, not the setup's ability. Run the examinee as a separate `claude -p` invocation given only the subject's assignment prompt, so it starts clean.

Capture the examinee's answer verbatim. That answer, and nothing about how it was produced, is what gets graded.

## Step 4 — Grade with the fixed grader, several times, at the median

Grade each answer with the subject's grader prompt, exactly as frozen in the subject file — not a paraphrase, not an improved version. Run the grader several times as separate invocations, because an LLM grader's ruler wobbles from one run to the next, and a single grading inherits that wobble whole. Take the median of the several scores as the subject's grade for this sitting. The median, not the mean, so one wild grading does not drag the result.

Run each grading as its own `claude -p` invocation given the frozen grader prompt and the examinee's answer. Do not let the grader see how the answer was produced or what the environment was; it grades the answer against the rubric and nothing else.

## Step 5 — Append to the ledger

Append one line per subject to `~/.claude/tsushinbo/grades.jsonl` (create it if absent). Each line is a JSON object with: the timestamp, the subject name, the median score, and the environment fingerprint's two hashes. Append only — never rewrite past lines, because the ledger's value is that it is an untampered history. Keeping it as JSONL means one sitting is one line and the file stays both machine-readable and human-inspectable.

## Step 6 — Report the sitting

Tell the user what was sat and the score each subject earned this time, and where the ledger is. Keep the framing honest: a single sitting is one noisy sample, and the number means little until it can be read against other sittings. Point them to `/tsushinbo:report` to read the trend. Do not commit anything; the user reviews their own machine.
