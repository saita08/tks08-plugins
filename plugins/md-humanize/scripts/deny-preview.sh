#!/bin/bash
# md-humanize PreToolUse hook entry. node が無い環境では生成物も存在しない
# ため、判定せず許可に倒す。
command -v node >/dev/null 2>&1 || exit 0
exec node "${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}/scripts/deny-preview.mjs"
