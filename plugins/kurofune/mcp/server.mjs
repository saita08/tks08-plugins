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
import { fileURLToPath } from "node:url";
import path from "node:path";
import fs from "node:fs";
import readline from "node:readline";
import { doctor, runGrok } from "./kurofune-core.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = path.resolve(__dirname, "..");
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
      "Check that the Grok Build CLI is installed and authenticated. Run this when a kurofune dispatch fails immediately or before the first use in a session.",
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

function formatToolResult(envelope) {
  const copy = { ...envelope };
  if (typeof copy.thought === "string" && copy.thought.length > 2000) {
    copy.thought = copy.thought.slice(0, 2000) + "…(truncated)";
  }
  // Compact single-line JSON so embedded newlines never break stdio framing
  // if a client ever re-embeds this text into an NDJSON channel.
  return JSON.stringify(copy);
}

async function callDoctor() {
  const d = doctor();
  return {
    isError: !d.ok,
    content: [{ type: "text", text: d.lines.join("\n") }],
  };
}

async function callTaskOrResume(kind, args) {
  if (kind === "resume" && !args.sessionId) {
    return {
      isError: true,
      content: [{ type: "text", text: "sessionId is required for resume" }],
    };
  }

  // Match / slightly under the MCP server idle budget so the client does not
  // kill us first. Default 45 minutes; override with KUROFUNE_TIMEOUT_MS.
  const timeoutMs = Number(process.env.KUROFUNE_TIMEOUT_MS || 45 * 60 * 1000);
  const { envelope, timedOut } = await runGrok({
    mode: kind,
    sessionId: args.sessionId,
    prompt: args.prompt,
    cwd: args.cwd,
    review: !!args.review,
    model: args.model,
    timeoutMs,
  });

  const body = formatToolResult(envelope);

  if (timedOut) {
    return {
      isError: true,
      content: [
        {
          type: "text",
          text: `kurofune ${kind} timed out after ${timeoutMs}ms. Partial/recovered payload:\n${body}`,
        },
      ],
    };
  }

  return {
    isError: !envelope.ok,
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

log(`ready version=${SERVER_VERSION}`);
