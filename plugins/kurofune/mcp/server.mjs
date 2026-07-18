#!/usr/bin/env node
/**
 * kurofune MCP server (stdio, local process).
 *
 * Exposes Grok Build as tools the main Claude conversation can call like a
 * subagent: task / resume / doctor. No cloud host — Claude Code spawns this
 * process on the user's machine and talks over stdin/stdout.
 *
 * Zero npm dependencies: speaks MCP JSON-RPC with Content-Length framing.
 */
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";
import fs from "node:fs";
import os from "node:os";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = path.resolve(__dirname, "..");
const SCRIPT = path.join(PLUGIN_ROOT, "scripts", "kurofune.sh");
const SERVER_NAME = "kurofune";
const SERVER_VERSION = "0.2.0";
const PROTOCOL_VERSION = "2024-11-05";

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
          description: "Grok model id. Default: grok-4.5 (or KUROFUNE_MODEL).",
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
          description: "Absolute path to the working directory (should match the original task).",
        },
        review: {
          type: "boolean",
          description: "Review (read-only) mode. Default false.",
          default: false,
        },
        model: {
          type: "string",
          description: "Grok model id. Default: grok-4.5 (or KUROFUNE_MODEL).",
        },
      },
      required: ["sessionId", "prompt"],
      additionalProperties: false,
    },
  },
];

function log(...args) {
  // MCP: stdout is the protocol channel. Logs go to stderr only.
  console.error("[kurofune-mcp]", ...args);
}

function sendMessage(msg) {
  const json = JSON.stringify(msg);
  const body = Buffer.from(json, "utf8");
  process.stdout.write(`Content-Length: ${body.length}\r\n\r\n`);
  process.stdout.write(body);
}

function sendResult(id, result) {
  sendMessage({ jsonrpc: "2.0", id, result });
}

function sendError(id, code, message, data) {
  const err = { code, message };
  if (data !== undefined) err.data = data;
  sendMessage({ jsonrpc: "2.0", id, error: err });
}

function runCommand(args, { timeoutMs } = {}) {
  return new Promise((resolve) => {
    const child = spawn("bash", [SCRIPT, ...args], {
      env: { ...process.env },
      // Stable cwd: the caller's shell may sit in a deleted temp dir.
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
    // last JSON object in stream
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
    // Cap thought size so the main context is not flooded.
    const copy = { ...payload };
    if (typeof copy.thought === "string" && copy.thought.length > 2000) {
      copy.thought = copy.thought.slice(0, 2000) + "…(truncated)";
    }
    if (copy.raw) {
      // raw is recoverable from resultFile; drop from tool body to save context
      delete copy.raw;
    }
    return JSON.stringify(copy, null, 2);
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

  // Grok coding tasks can take many minutes. 30 min default; override via env.
  const timeoutMs = Number(process.env.KUROFUNE_TIMEOUT_MS || 30 * 60 * 1000);
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

  // ok:false or non-zero exit => isError so the main model notices
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

  // Notifications (no id)
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
        sendResult(id, {
          protocolVersion: PROTOCOL_VERSION,
          capabilities: { tools: {} },
          serverInfo: { name: SERVER_NAME, version: SERVER_VERSION },
        });
        break;
      case "ping":
        sendResult(id, {});
        break;
      case "tools/list":
        sendResult(id, { tools: TOOLS });
        break;
      case "tools/call": {
        const result = await handleToolsCall(params);
        sendResult(id, result);
        break;
      }
      default:
        sendError(id, -32601, `Method not found: ${method}`);
    }
  } catch (err) {
    log("handler error", err);
    sendError(id, -32603, err?.message || String(err));
  }
}

// --- stdio framing (Content-Length, MCP / LSP style) ---

let buffer = Buffer.alloc(0);

function tryConsume() {
  while (true) {
    const headerEnd = buffer.indexOf("\r\n\r\n");
    if (headerEnd === -1) return;
    const header = buffer.slice(0, headerEnd).toString("utf8");
    const match = /Content-Length:\s*(\d+)/i.exec(header);
    if (!match) {
      // Resync: drop one byte
      buffer = buffer.slice(1);
      continue;
    }
    const length = parseInt(match[1], 10);
    const bodyStart = headerEnd + 4;
    if (buffer.length < bodyStart + length) return;
    const body = buffer.slice(bodyStart, bodyStart + length).toString("utf8");
    buffer = buffer.slice(bodyStart + length);
    let msg;
    try {
      msg = JSON.parse(body);
    } catch (e) {
      log("invalid JSON body", e.message);
      continue;
    }
    // Fire and forget; concurrent tool calls are serialized by await in handleMessage chain
    messageQueue.push(msg);
    drainQueue();
  }
}

const messageQueue = [];
let draining = false;

async function drainQueue() {
  if (draining) return;
  draining = true;
  while (messageQueue.length) {
    const msg = messageQueue.shift();
    await handleMessage(msg);
  }
  draining = false;
}

if (!fs.existsSync(SCRIPT)) {
  log(`wrapper missing: ${SCRIPT}`);
  process.exit(1);
}

process.stdin.on("data", (chunk) => {
  buffer = Buffer.concat([buffer, Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk)]);
  tryConsume();
});

process.stdin.on("end", () => {
  process.exit(0);
});

// Also accept newline-delimited JSON for manual debugging (optional).
// Only used when no Content-Length header path is active and a full line arrives.
// Disabled when Content-Length is present in the buffer — tryConsume handles that.

log(`ready script=${SCRIPT}`);
