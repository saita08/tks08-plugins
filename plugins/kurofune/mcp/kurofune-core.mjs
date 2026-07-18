/**
 * kurofune core — dispatch Grok Build headless and package the result.
 *
 * Single source of truth for the result envelope, shared by the MCP server
 * (server.mjs) and the CLI entry (cli.mjs, wrapped by scripts/kurofune.sh).
 * The envelope always carries sessionId and resultFile so a truncated caller
 * can recover the session, and gitStatus/gitDiffStat so the working tree,
 * not the worker's claim, is the evidence.
 */
import { spawn, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

export const GROK_BIN =
  process.env.KUROFUNE_GROK_BIN || path.join(os.homedir(), ".grok", "bin", "grok");
export const DEFAULT_MODEL = process.env.KUROFUNE_MODEL || "grok-4.5";
export const RESULT_DIR =
  process.env.KUROFUNE_RESULT_DIR ||
  path.join(process.env.TMPDIR || "/tmp", "kurofune-results");

function isExecutable(file) {
  try {
    fs.accessSync(file, fs.constants.X_OK);
    return fs.statSync(file).isFile();
  } catch {
    return false;
  }
}

function safeCwd() {
  // The caller's shell may sit in a deleted temp dir.
  try {
    return process.cwd();
  } catch {
    return os.homedir() || os.tmpdir();
  }
}

function timestamp() {
  const d = new Date();
  const p = (n, w = 2) => String(n).padStart(w, "0");
  return (
    `${d.getFullYear()}${p(d.getMonth() + 1)}${p(d.getDate())}` +
    `T${p(d.getHours())}${p(d.getMinutes())}${p(d.getSeconds())}`
  );
}

/**
 * Pull the last parseable JSON object out of a string that may carry noise
 * around it (progress lines, warnings, an earlier stray JSON message). The
 * envelope is the final thing grok prints, so the last object wins. Returns
 * null when none is found.
 */
export function extractJsonObject(s) {
  const trimmed = (s || "").trim();
  if (!trimmed) return null;
  try {
    const obj = JSON.parse(trimmed);
    if (obj && typeof obj === "object" && !Array.isArray(obj)) return obj;
  } catch {
    // fall through to the brace scan
  }
  let found = null;
  for (let i = 0; i < trimmed.length; i++) {
    if (trimmed[i] !== "{") continue;
    let depth = 0;
    let inString = false;
    let escaped = false;
    for (let j = i; j < trimmed.length; j++) {
      const ch = trimmed[j];
      if (inString) {
        if (escaped) escaped = false;
        else if (ch === "\\") escaped = true;
        else if (ch === '"') inString = false;
      } else if (ch === '"') {
        inString = true;
      } else if (ch === "{") {
        depth++;
      } else if (ch === "}") {
        depth--;
        if (depth === 0) {
          try {
            const obj = JSON.parse(trimmed.slice(i, j + 1));
            if (obj && typeof obj === "object") {
              found = obj;
              i = j; // skip past this object; keep scanning for a later one
            }
          } catch {
            // balanced but unparsable — the next outer pass tries the
            // braces inside this region
          }
          break;
        }
      }
    }
  }
  return found;
}

function gitSnapshot(dir) {
  if (!dir) return {};
  try {
    if (!fs.statSync(dir).isDirectory()) return {};
  } catch {
    return {};
  }
  const opts = { cwd: dir, encoding: "utf8", timeout: 10_000 };
  const inTree = spawnSync("git", ["rev-parse", "--is-inside-work-tree"], opts);
  if (inTree.status !== 0) return {};
  const out = {};
  const status = spawnSync("git", ["status", "--short"], opts);
  if (status.status === 0 && status.stdout) out.gitStatus = status.stdout;
  const diff = spawnSync("git", ["diff", "--stat", "HEAD"], opts);
  if (diff.status === 0 && diff.stdout) out.gitDiffStat = diff.stdout;
  return out;
}

/**
 * Check the Grok Build install without touching the user's environment.
 * Returns { ok, lines }; lines that start with "kurofune:" are complaints.
 */
export function doctor() {
  if (!isExecutable(GROK_BIN)) {
    return {
      ok: false,
      lines: [
        `kurofune: grok binary not found at ${GROK_BIN}`,
        "Install Grok Build yourself: curl -fsSL https://x.ai/cli/install.sh | bash",
      ],
    };
  }
  const lines = [];
  const version = spawnSync(GROK_BIN, ["--version"], { encoding: "utf8", timeout: 60_000 });
  lines.push((version.stdout || version.stderr || "").trim());
  const authPath = path.join(os.homedir(), ".grok", "auth.json");
  if (!fs.existsSync(authPath)) {
    lines.push(
      "kurofune: no auth cache at ~/.grok/auth.json -- run 'grok login' yourself (subscription required)"
    );
    return { ok: false, lines };
  }
  lines.push("auth cache present: ~/.grok/auth.json");
  lines.push(`default model: ${DEFAULT_MODEL}`);
  return { ok: true, lines };
}

let dispatchSeq = 0;

/**
 * Run one headless Grok dispatch and package the outcome.
 *
 * mode is "task" or "resume" (resume also needs sessionId). Resolves to
 * { envelope, exitCode, timedOut }; it never rejects — every failure is an
 * ok:false envelope so callers always have something machine-readable.
 */
export function runGrok({
  mode,
  sessionId,
  prompt,
  cwd,
  review = false,
  model,
  timeoutMs,
} = {}) {
  return new Promise((resolve) => {
    const useModel = model || DEFAULT_MODEL;
    const envelope = {
      ok: false,
      sessionId: null,
      stopReason: null,
      text: null,
      model: useModel,
      cwd: cwd || null,
      resultFile: null,
      exitCode: 0,
    };

    if (!isExecutable(GROK_BIN)) {
      envelope.exitCode = 1;
      envelope.error = `grok binary not found at ${GROK_BIN}`;
      resolve({ envelope, exitCode: 1, timedOut: false });
      return;
    }

    fs.mkdirSync(RESULT_DIR, { recursive: true });
    // pid alone cannot disambiguate: the MCP server dispatches concurrent
    // tasks from one process, so a per-process sequence keeps files apart.
    const stamp = `${timestamp()}_${process.pid}_${++dispatchSeq}`;
    const resultFile = path.join(RESULT_DIR, `${mode}_${stamp}.json`);
    const errFile = path.join(RESULT_DIR, `${mode}_${stamp}.stderr`);

    const args = ["--no-auto-update", "--output-format", "json", "-m", useModel];
    if (cwd) args.push("--cwd", cwd);
    if (review) {
      // Config-level yolo can re-enable writes if we only omit --always-approve.
      args.push("--permission-mode", "default");
      args.push("--disallowed-tools", "search_replace,run_terminal_cmd");
    } else {
      args.push("--always-approve");
    }
    if (sessionId) args.push("--resume", sessionId);
    args.push("-p", prompt);

    let spawnCwd = safeCwd();
    if (cwd) {
      try {
        if (fs.statSync(cwd).isDirectory()) spawnCwd = cwd;
      } catch {
        // grok will complain about --cwd itself
      }
    }

    const child = spawn(GROK_BIN, args, {
      cwd: spawnCwd,
      env: { ...process.env },
      stdio: ["ignore", "pipe", "pipe"],
    });
    let stdout = "";
    let stderr = "";
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (c) => {
      stdout += c;
    });
    child.stderr.on("data", (c) => {
      stderr += c;
    });

    let timedOut = false;
    let timer;
    if (timeoutMs && timeoutMs > 0) {
      timer = setTimeout(() => {
        timedOut = true;
        child.kill("SIGTERM");
        setTimeout(() => child.kill("SIGKILL"), 5000).unref?.();
      }, timeoutMs);
    }

    child.on("error", (err) => {
      if (timer) clearTimeout(timer);
      envelope.exitCode = 1;
      envelope.error = `failed to start grok: ${err.message}`;
      resolve({ envelope, exitCode: 1, timedOut });
    });

    child.on("close", (code, signal) => {
      if (timer) clearTimeout(timer);
      const rc = code ?? (signal ? 1 : 0);
      envelope.resultFile = resultFile;
      envelope.exitCode = rc;
      try {
        fs.writeFileSync(resultFile, stdout);
        fs.writeFileSync(errFile, stderr);
      } catch {
        // packaging must not lose the run over a disk hiccup
      }

      let raw = null;
      const trimmed = stdout.trim();
      if (trimmed) {
        raw = extractJsonObject(trimmed);
        if (raw) {
          let clean = false;
          try {
            JSON.parse(trimmed);
            clean = true;
          } catch {
            // raw was recovered from noise; persist the clean object
          }
          if (!clean) {
            try {
              fs.writeFileSync(resultFile, JSON.stringify(raw));
            } catch {
              // keep the noisy original
            }
          }
        }
      }

      if (raw) {
        envelope.sessionId = raw.sessionId ?? null;
        envelope.stopReason = raw.stopReason ?? null;
        envelope.text = raw.text ?? null;
        if (raw.thought) {
          envelope.thought =
            typeof raw.thought === "string" && raw.thought.length > 4000
              ? raw.thought.slice(0, 4000) + "…(truncated)"
              : raw.thought;
        }
      }

      Object.assign(envelope, gitSnapshot(cwd));

      if (raw) {
        const cancelled = raw.stopReason === "Cancelled";
        if (rc === 0 && !cancelled && !timedOut) {
          envelope.ok = true;
        } else if (timedOut) {
          envelope.error = `timed out after ${timeoutMs}ms; partial envelope recovered`;
        } else if (cancelled) {
          envelope.error =
            "Grok stopped with stopReason=Cancelled (often review mode blocked a write, or a permission prompt had no TTY)";
        } else if (rc !== 0) {
          envelope.error = `grok exited with status ${rc}`;
        } else {
          envelope.error = "grok finished unsuccessfully";
        }
        for (const k of ["usage", "num_turns", "requestId", "total_cost_usd", "modelUsage"]) {
          if (k in raw) envelope[k] = raw[k];
        }
        resolve({ envelope, exitCode: envelope.ok ? 0 : 1, timedOut });
        return;
      }

      const errSnip = stderr.slice(0, 2000).trim();
      envelope.error = timedOut
        ? `timed out after ${timeoutMs}ms`
        : errSnip || `no JSON envelope from grok (exit ${rc})`;
      resolve({ envelope, exitCode: rc || 1, timedOut });
    });
  });
}
