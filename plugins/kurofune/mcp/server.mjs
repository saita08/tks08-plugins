#!/usr/bin/env node
/**
 * kurofune MCP server (stdio, local process).
 *
 * Exposes Grok Build as tools the main Claude conversation can call like a
 * subagent: task / resume / doctor. Claude Code spawns this process on the
 * user's machine and talks over stdin/stdout.
 *
 * Zero npm dependencies. MCP stdio framing is newline-delimited JSON-RPC
 * (messages MUST NOT contain embedded newlines). See
 * https://modelcontextprotocol.io/specification/2025-11-25/basic/transports
 */
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";
import fs from "node:fs";
import os from "node:os";
import readline from "node:readline";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = path.resolve(__dirname, "..");
const SCRIPT = path.join(PLUGIN_ROOT, "scripts", "kurofune.sh");
const PLUGIN_JSON = path.join(PLUGIN_ROOT, ".claude-plugin", "plugin.json");
const SERVER_NAME = "kurofune";

function readServerVersion() {
  try {
    const raw = fs.readFileSync(PLUGIN_JSON, "utf8");
    const v = JSON.parse(raw).version;
    if (typeof v === "string" && v.length > 0) return v;
  } catch {
    // fall through
  }
  return "0.0.0";
}

const SERVER_VERSION = readServerVersion();

// MCP wire-protocol revision labels from the official SDK and
// https://modelcontextprotocol.io/specification — current latest is 2025-11-25.
const LATEST_PROTOCOL_VERSION = "2025-11-25";
const SUPPORTED_PROTOCOL_VERSIONS = [
  "2025-11-25",
  "2025-06-18",
  "2025-03-26",
  "2024-11-05",
  "2024-10-07",
];

function negotiateProtocolVersion(requested) {
  if (requested && SUPPORTED_PROTOCOL_VERSIONS.includes(requested)) {
    return requested;
  }
  return LATEST_PROTOCOL_VERSION;
}

const TOOLS = [
  {
    name: "doctor",
    description:
      "Check that the Grok Build CLI is installed and authenticated, and that python3 is available for result packaging. Run this when a kurofune dispatch fails immediately or before the first use in a session.",
    inputSchema: {
      type: "object",
      properties: {},
      additionalProperties: false,
    },
  },
  {
    name: "task",
    description:
      "Start a new Grok Build headless session for a self-contained coding task. Returns sessionId (keep it for resume), Grok's text summary, stopReason, and a git status snapshot of cwd when available. The main conversation should call this directly — do not wrap it in another agent. Always include in the prompt: goal, relevant paths, constraints, observable done criteria, and 'Do not commit; leave changes in the working tree.' Default model is grok-4.5.",
    inputSchema: {
      type: "object",
      properties: {
        prompt: {
          type: "string",
          description: "Self-contained task brief for Grok. Grok sees none of the Claude conversation.",
        },
        cwd: {
          type: "string",
          description:
            "Absolute path to the git-tracked working directory Grok should edit. Prefer an absolute path.",
        },
        review: {
          type: "boolean",
          description:
            "If true, run in review mode: Grok cannot write files or run shell (read-only analysis). Default false.",
          default: false,
        },
        model: {
          type: "string",
          description: "Grok model id. Default: grok-4.5 or KUROFUNE_MODEL.",
        },
      },
      required: ["prompt"],
      additionalProperties: false,
    },
  },
  {
    name: "resume",
    description:
      "Continue an existing Grok Build session with follow-up instructions. Always pass the sessionId returned by a prior task or resume call. Use this for corrections ('test X fails with Y') instead of starting a new task.",
    inputSchema: {
      type: "object",
      properties: {
        sessionId: {
          type: "string",
          description: "Session id from a previous task/resume result.",
        },
        prompt: {
          type: "string",
          description: "Follow-up brief. May refer to work already done in the session.",
        },
        cwd: {
          type: "string",
          description: "Absolute path to the working directory. Should match the original task.",
        },
        review: {
          type: "boolean",
          description: "Review read-only mode. Default false.",
          default: false,
        },
        model: {
          type: "string",
          description: "Grok model id. Default: grok-4.5 or KUROFUNE_MODEL.",
        },
      },
      required: ["sessionId", "prompt"],
      additionalProperties: false,
    },
  },
];

function log(...args) {
  // stdout is the protocol channel. Logs go to stderr only.
  console.error("[kurofune-mcp]", ...args);
}

// Serialize writes so concurrent tool handlers do not interleave stdout bytes.
let writeChain = Promise.resolve();

function sendMessage(msg) {
  const line = JSON.stringify(msg) + "\n";
  writeChain = writeChain.then(
    () =>
      new Promise((resolve, reject) => {
        const ok = process.stdout.write(line, (err) => {
          if (err) reject(err);
          else resolve();
        });
        if (!ok) {
          process.stdout.once("drain", resolve);
        }
      })
  );
  return writeChain;
}

function sendResult(id, result) {
  return sendMessage({ jsonrpc: "2.0", id, result });
}

function sendError(id, code, message, data) {
  const err = { code, message };
  if (data !== undefined) err.data = data;
  return sendMessage({ jsonrpc: "2.0", id, error: err });
}

function runCommand(args, { timeoutMs } = {}) {
  return new Promise((resolve) => {
    const child = spawn("bash", [SCRIPT, ...args], {
      env: { ...process.env },
      cwd: process.env.HOME || os.tmpdir() || PLUGIN_ROOT,
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

    child.on("close", (code, signal) => {
      if (timer) clearTimeout(timer);
      resolve({
        code: code ?? (signal ? 1 : 0),
        signal,
        stdout,
        stderr,
        timedOut,
      });
    });
  });
}

function parseToolPayload(stdout) {
  const trimmed = (stdout || "").trim();
  if (!trimmed) return null;
  try {
    return JSON.parse(trimmed);
  } catch {
    const start = trimmed.lastIndexOf("{");
    if (start >= 0) {
      try {
        return JSON.parse(trimmed.slice(start));
      } catch {
        return null;
      }
    }
    return null;
  }
}

function formatToolResult(payload, fallback) {
  if (payload) {
    const copy = { ...payload };
    if (typeof copy.thought === "string" && copy.thought.length > 2000) {
      copy.thought = copy.thought.slice(0, 2000) + "…(truncated)";
    }
    if (copy.raw) {
      delete copy.raw;
    }
    // Compact single-line JSON so embedded newlines never break stdio framing
    // if a client ever re-embeds this text into an NDJSON channel.
    return JSON.stringify(copy);
  }
  return fallback;
}

async function callDoctor() {
  const { code, stdout, stderr } = await runCommand(["doctor"], {
    timeoutMs: 60_000,
  });
  const text = [stdout, stderr].filter(Boolean).join("\n").trim();
  return {
    isError: code !== 0,
    content: [{ type: "text", text: text || `doctor exited ${code}` }],
  };
}

async function callTaskOrResume(kind, args) {
  const cli = [kind];
  if (args.review) cli.push("-r");
  if (args.cwd) cli.push("-C", args.cwd);
  if (args.model) cli.push("-m", args.model);
  if (kind === "resume") {
    if (!args.sessionId) {
      return {
        isError: true,
        content: [{ type: "text", text: "sessionId is required for resume" }],
      };
    }
    cli.push(args.sessionId, args.prompt);
  } else {
    cli.push(args.prompt);
  }

  // Match / slightly under the MCP server idle budget so the client does not
  // kill us first. Default 45 minutes; override with KUROFUNE_TIMEOUT_MS.
  const timeoutMs = Number(process.env.KUROFUNE_TIMEOUT_MS || 45 * 60 * 1000);
  const { code, stdout, stderr, timedOut } = await runCommand(cli, { timeoutMs });
  const payload = parseToolPayload(stdout);

  if (timedOut) {
    const recovery = payload
      ? formatToolResult(payload, "")
      : `Timed out after ${timeoutMs}ms. stderr:\n${stderr.slice(0, 2000)}`;
    return {
      isError: true,
      content: [
        {
          type: "text",
          text: `kurofune ${kind} timed out after ${timeoutMs}ms. Partial/recovered payload:\n${recovery}`,
        },
      ],
    };
  }

  const body = formatToolResult(
    payload,
    `Non-JSON output (exit ${code}).\nstdout:\n${stdout.slice(0, 4000)}\nstderr:\n${stderr.slice(0, 2000)}`
  );

  const isError = code !== 0 || (payload && payload.ok === false);
  return {
    isError,
    content: [{ type: "text", text: body }],
  };
}

async function handleToolsCall(params) {
  const name = params?.name;
  const args = params?.arguments || {};
  switch (name) {
    case "doctor":
      return callDoctor();
    case "task":
      if (!args.prompt || typeof args.prompt !== "string") {
        return {
          isError: true,
          content: [{ type: "text", text: "prompt is required" }],
        };
      }
      return callTaskOrResume("task", args);
    case "resume":
      if (!args.prompt || typeof args.prompt !== "string") {
        return {
          isError: true,
          content: [{ type: "text", text: "prompt is required" }],
        };
      }
      return callTaskOrResume("resume", args);
    default:
      return {
        isError: true,
        content: [{ type: "text", text: `Unknown tool: ${name}` }],
      };
  }
}

async function handleMessage(msg) {
  if (!msg || typeof msg !== "object") return;

  if (msg.method && msg.id === undefined) {
    if (msg.method === "notifications/initialized") {
      log("initialized");
    }
    return;
  }

  if (!msg.method) return;

  const { id, method, params } = msg;

  try {
    switch (method) {
      case "initialize":
        await sendResult(id, {
          protocolVersion: negotiateProtocolVersion(params?.protocolVersion),
          capabilities: { tools: {} },
          serverInfo: { name: SERVER_NAME, version: SERVER_VERSION },
        });
        break;
      case "ping":
        await sendResult(id, {});
        break;
      case "tools/list":
        await sendResult(id, { tools: TOOLS });
        break;
      case "tools/call": {
        const result = await handleToolsCall(params);
        await sendResult(id, result);
        break;
      }
      default:
        await sendError(id, -32601, `Method not found: ${method}`);
    }
  } catch (err) {
    log("handler error", err);
    await sendError(id, -32603, err?.message || String(err));
  }
}

// Concurrent dispatch: long tools/call must not block ping or a second task.
function dispatch(msg) {
  handleMessage(msg).catch((err) => {
    log("unhandled dispatch error", err);
  });
}

if (!fs.existsSync(SCRIPT)) {
  log(`wrapper missing: ${SCRIPT}`);
  process.exit(1);
}

const rl = readline.createInterface({
  input: process.stdin,
  crlfDelay: Infinity,
});

rl.on("line", (line) => {
  const trimmed = line.trim();
  if (!trimmed) return;
  let msg;
  try {
    msg = JSON.parse(trimmed);
  } catch (e) {
    log("invalid JSON line", e.message);
    return;
  }
  dispatch(msg);
});

rl.on("close", () => {
  process.exit(0);
});

log(`ready script=${SCRIPT} version=${SERVER_VERSION}`);
