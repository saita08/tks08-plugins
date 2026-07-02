#!/bin/bash
# md-humanize — PostToolUse hook body.
# Write/Edit された Markdown を、隣に置く自己完結の読みやすい HTML へ包む。
# Markdown の解釈はテンプレート内の JavaScript が行うため、ここでやるのは
# 対象の判定と、本文を base64 でテンプレートへ埋め込むことだけ。bash と
# OS 標準のコマンド (grep / sed / awk / base64) 以外に依存しない。
# プレビュー生成の失敗がセッションを妨げてはならないため、判定できない
# 入力や異常はすべて静かに正常終了する。
set -u

quiet() { printf '{"suppressOutput":true}'; exit 0; }

input=$(cat) || quiet

# フック入力 JSON から文字列フィールドを取り出す。エスケープされた引用符を
# 含むパスは拾えないが、その場合は変換を諦めるだけで害はない。
field() {
  printf '%s' "$input" |
    grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 |
    sed 's/^[^:]*:[[:space:]]*"//; s/"$//'
}

file_path=$(field file_path)
cwd=$(field cwd)
[ -n "$file_path" ] || quiet

case "$file_path" in
  /*) abs=$file_path ;;
  *) [ -n "$cwd" ] || quiet; abs=$cwd/$file_path ;;
esac

lower=$(printf '%s' "$abs" | tr 'A-Z' 'a-z')
case "$lower" in *.md) ;; *) quiet ;; esac
[ -f "$abs" ] || quiet
case "$abs" in *../*|*/..) quiet ;; esac

# 作業プロジェクトの外 (ホーム設定や共有メモリ等) には手を出さない
if [ -n "$cwd" ]; then
  case "$abs" in "$cwd"/*) ;; *) quiet ;; esac
fi

# 定型ファイルは読み物ではなく設定・記録なので変換しない
base=$(basename "$abs" | tr 'A-Z' 'a-z')
case "$base" in
  claude.md|agents.md|changelog.md|readme.md|license.md|contributing.md|code_of_conduct.md|security.md) quiet ;;
esac
rel=${abs#"$cwd"/}
case "/$rel/" in */.claude/*|*/.git/*|*/node_modules/*) quiet ;; esac

plugin_root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
template=$plugin_root/assets/template.html
[ -f "$template" ] || quiet

body=$(mktemp) || quiet
trap 'rm -f "$body"' EXIT

# CR を落とし、先頭の YAML frontmatter を取り除く
sed 's/\r$//' "$abs" | awk '
  NR==1 && $0=="---" { fm=1; next }
  fm==1 { if ($0=="---") fm=2; next }
  { print }
' > "$body"

# タイトルは先頭の h1 から。無ければファイル名。<title> 用に HTML エスケープ
title=$(sed -n 's/^#[[:space:]]\{1,\}//p' "$body" | head -1 |
  sed 's/`\([^`]*\)`/\1/g; s/\*\*\([^*]*\)\*\*/\1/g; s/\*\([^*]*\)\*/\1/g; s/\[\([^]]*\)\]([^)]*)/\1/g')
[ -n "$title" ] || title=$(basename "$abs" | sed 's/\.[mM][dD]$//')
esc_html() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }
title=$(esc_html "$title")
source_path=$(esc_html "$rel")
generated_at=$(date '+%Y-%m-%d %H:%M')

# sed の置換値として安全にする (\ & / を退避)
esc_sed() { printf '%s' "$1" | sed 's/[&/\]/\\&/g'; }
t=$(esc_sed "$title"); sp=$(esc_sed "$source_path"); ga=$(esc_sed "$generated_at")

out=$(printf '%s' "$abs" | sed 's/\.[mM][dD]$/.preview.html/')

# テンプレートは {{CONTENT_B64}} だけの行を持つ。その前後を分けて出力し、
# 間に本文の base64 を挟む。base64 は置換文字と衝突しないため加工不要
{
  sed -n '1,/^{{CONTENT_B64}}$/p' "$template" | sed '$d' |
    sed "s/{{TITLE}}/$t/g; s/{{SOURCE_PATH}}/$sp/g; s/{{GENERATED_AT}}/$ga/g"
  base64 < "$body"
  sed -n '/^{{CONTENT_B64}}$/,$p' "$template" | sed '1d' |
    sed "s/{{TITLE}}/$t/g; s/{{SOURCE_PATH}}/$sp/g; s/{{GENERATED_AT}}/$ga/g"
} > "$out" 2>/dev/null || quiet

# 生成物がコミットされてゴミにならないよう、初回に限り
# リポジトリの .gitignore へパターンを足す
dir=$(dirname "$abs")
root=""
while [ "$dir" != "/" ] && [ -n "$dir" ]; do
  if [ -e "$dir/.git" ]; then root=$dir; break; fi
  dir=$(dirname "$dir")
done
if [ -n "$root" ]; then
  gi=$root/.gitignore
  if ! grep -qxF '*.preview.html' "$gi" 2>/dev/null; then
    {
      if [ -s "$gi" ]; then
        [ -n "$(tail -c 1 "$gi" 2>/dev/null)" ] && printf '\n'
        printf '\n'
      fi
      printf '# md-humanize (Claude Code plugin): generated HTML previews\n*.preview.html\n'
    } >> "$gi" 2>/dev/null && {
      printf '{"suppressOutput":true,"systemMessage":"md-humanize: added \\"*.preview.html\\" to %s so generated previews stay out of commits."}' "$gi"
      exit 0
    }
  fi
fi

quiet
