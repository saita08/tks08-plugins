#!/bin/bash
# md-humanize hook entry. node が無い環境ではプレビューを諦めて静かに抜ける。
command -v node >/dev/null 2>&1 || exit 0
exec node "${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}/scripts/generate.mjs"
