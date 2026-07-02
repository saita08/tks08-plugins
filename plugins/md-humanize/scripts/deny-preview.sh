#!/bin/bash
# md-humanize — PreToolUse hook body.
# 生成物 (*.preview.html) は人間が読むためのもので、Claude が読み込むと
# コンテキストを浪費するだけになる。読み取りにあたる操作を却下し、
# 元の Markdown を読むよう促す。判定できない入力はすべて許可に倒す。
#
# 塞ぐ経路: Read / Write / Edit のファイル指定、Grep のファイル・glob 指定、
# Bash でファイル名を明示した内容読み出し (cat / grep / sed など)。
# ファイル名を指定しない再帰検索 (grep -r 等) は静的には判定できないため
# 塞がない。Grep ツール本体は ripgrep として .gitignore を尊重するので、
# 生成時に追記される "*.preview.html" が検索からの流入を防ぐ。
# rm / mv / ls / open など、内容をコンテキストへ運ばない操作は妨げない。
set -u

input=$(cat) || { printf '{}'; exit 0; }

field() {
  printf '%s' "$input" |
    grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 |
    sed 's/^[^:]*:[[:space:]]*"//; s/"$//'
}

deny() {
  # JSON 文字列として安全な文字だけ残す
  target=$(printf '%s' "$1" | tr -d '"\\')
  source=$(printf '%s' "$target" | sed 's/\.[pP][rR][eE][vV][iI][eE][wW]\.[hH][tT][mM][lL]$/.md/')
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"md-humanize: %s is a generated preview for humans; it is regenerated on every edit and reading it only wastes context. Read the source file instead: %s"}}' "$target" "$source"
  exit 0
}

tool=$(field tool_name)
PREVIEW='\.preview\.html'

case "$tool" in
  Bash)
    command=$(field command)
    if printf '%s' "$command" | grep -qiE "$PREVIEW" &&
       printf '%s' "$command" | grep -qwE 'cat|head|tail|less|more|grep|rg|ag|sed|awk|cut|sort|uniq|bat|strings|xxd|hexdump|od|diff|wc|tee|python3?|node|ruby|perl'; then
      target=$(printf '%s' "$command" | grep -oiE '[^" ]*\.preview\.html' | head -1)
      deny "${target:-*.preview.html}"
    fi
    ;;
  Grep)
    path=$(field path)
    glob=$(field glob)
    printf '%s' "$path" | grep -qiE "$PREVIEW" && deny "$path"
    printf '%s' "$glob" | grep -qiE "$PREVIEW" && deny "$glob"
    ;;
  Read|Write|Edit|MultiEdit)
    file_path=$(field file_path)
    printf '%s' "$file_path" | grep -qiE "${PREVIEW}$" && deny "$file_path"
    ;;
esac

printf '{}'
exit 0
