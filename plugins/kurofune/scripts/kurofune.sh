#!/usr/bin/env bash
# kurofune.sh -- dispatch a coding task to Grok Build running headless,
# and continue its session so the worker keeps its context across turns.
#
# Usage:
#   kurofune.sh doctor
#   kurofune.sh task   [-r] [-C DIR] [-m MODEL] "PROMPT"
#   kurofune.sh resume [-r] [-C DIR] [-m MODEL] SESSION_ID "PROMPT"
#
#   -r      review mode: no write auto-approve; strip write/shell tools
#   -C DIR  working directory for the worker (defaults to current directory)
#   -m MODEL  Grok model id (default: $KUROFUNE_MODEL or grok-4.5)
#
# On success, stdout is a single JSON object:
#   { ok, sessionId, stopReason, text, thought?, model, cwd, resultFile,
#     gitStatus?, gitDiffStat?, usage?, num_turns? }
# On failure, stdout is still JSON when possible ({ ok:false, ... }) and
# exit status is non-zero. Full Grok envelope is always written to resultFile
# when Grok produced one, so a truncated caller can recover sessionId.
#
# This script is a thin shell entry: the implementation lives in
# ../mcp/cli.mjs and ../mcp/kurofune-core.mjs, shared with the MCP server.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if ! command -v node >/dev/null 2>&1; then
  echo "kurofune: node not found on PATH -- Node.js runs kurofune's dispatch and result packaging" >&2
  exit 1
fi

exec node "$SCRIPT_DIR/../mcp/cli.mjs" "$@"
