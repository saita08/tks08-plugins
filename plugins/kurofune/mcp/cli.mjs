#!/usr/bin/env node
/**
 * kurofune CLI — the same surface as scripts/kurofune.sh, which execs this
 * file. Parsing mirrors the historical getopts contract: options come before
 * positionals, and the envelope printed to stdout is the one built by
 * kurofune-core.mjs.
 */
import { doctor, runGrok } from "./kurofune-core.mjs";

const USAGE = `kurofune.sh -- dispatch a coding task to Grok Build running headless,
and continue its session so the worker keeps its context across turns.

Usage:
  kurofune.sh doctor
  kurofune.sh task   [-r] [-C DIR] [-m MODEL] "PROMPT"
  kurofune.sh resume [-r] [-C DIR] [-m MODEL] SESSION_ID "PROMPT"

  -r      review mode: no write auto-approve; strip write/shell tools
  -C DIR  working directory for the worker (defaults to current directory)
  -m MODEL  Grok model id (default: $KUROFUNE_MODEL or grok-4.5)

On success, stdout is a single JSON object:
  { ok, sessionId, stopReason, text, thought?, model, cwd, resultFile,
    gitStatus?, gitDiffStat?, usage?, num_turns? }
On failure, stdout is still JSON when possible ({ ok:false, ... }) and
exit status is non-zero. Full Grok envelope is always written to resultFile
when Grok produced one, so a truncated caller can recover sessionId.`;

function usage() {
  console.log(USAGE);
  process.exit(2);
}

function parseRunArgs(argv) {
  const opts = { review: false, cwd: "", model: "" };
  let i = 0;
  for (; i < argv.length; i++) {
    const a = argv[i];
    if (a === "-r") opts.review = true;
    else if (a === "-C") {
      if (i + 1 >= argv.length) usage();
      opts.cwd = argv[++i];
    } else if (a === "-m") {
      if (i + 1 >= argv.length) usage();
      opts.model = argv[++i];
    } else if (a.startsWith("-") && a !== "-") usage();
    else break;
  }
  return { opts, positionals: argv.slice(i) };
}

async function runDoctor() {
  const d = await doctor();
  for (const line of d.lines) {
    if (line.startsWith("kurofune:")) console.error(line);
    else console.log(line);
  }
  process.exit(d.ok ? 0 : 1);
}

async function runDispatch(mode, argv) {
  const { opts, positionals } = parseRunArgs(argv);
  let sessionId;
  let prompt;
  if (mode === "resume") {
    if (positionals.length !== 2) usage();
    [sessionId, prompt] = positionals;
  } else {
    if (positionals.length !== 1) usage();
    [prompt] = positionals;
  }
  const { envelope, exitCode } = await runGrok({
    mode,
    sessionId,
    prompt,
    cwd: opts.cwd || undefined,
    review: opts.review,
    model: opts.model || undefined,
  });
  console.log(JSON.stringify(envelope));
  process.exit(exitCode);
}

const [cmd, ...rest] = process.argv.slice(2);
switch (cmd) {
  case "doctor":
    await runDoctor();
    break;
  case "task":
  case "resume":
    await runDispatch(cmd, rest);
    break;
  default:
    usage();
}
