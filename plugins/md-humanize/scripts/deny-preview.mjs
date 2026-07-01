// md-humanize — PreToolUse hook body.
// 生成物 (*.preview.html) は人間が読むためのもので、Claude が読み込むと
// コンテキストを浪費するだけになる。読み取りにあたる操作を却下し、
// 元の Markdown を読むよう促す。判定できない入力はすべて許可に倒す。
//
// 塞ぐ経路: Read / Write / Edit のファイル指定、Grep のファイル・glob 指定、
// Bash でファイル名を明示した内容読み出し (cat / grep / sed など)。
// ファイル名を指定しない再帰検索 (grep -r 等) は静的には判定できないため
// 塞がない。Grep ツール本体は ripgrep として .gitignore を尊重するので、
// 生成時に追記される "*.preview.html" が検索からの流入を防ぐ。
// rm / mv / ls / open など、内容をコンテキストへ運ばない操作は妨げない。

import fs from "node:fs";

const PREVIEW = /\.preview\.html\b/i;
const CONTENT_READERS =
  /\b(cat|head|tail|less|more|grep|rg|ag|sed|awk|cut|sort|uniq|bat|strings|xxd|hexdump|od|diff|wc|tee|python3?|node|ruby|perl)\b/;

function out(obj) {
  process.stdout.write(JSON.stringify(obj));
  process.exit(0);
}

function deny(target) {
  const source = target.replace(/\.preview\.html$/i, ".md");
  out({
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason:
        `md-humanize: ${target} is a generated preview for humans; it is ` +
        `regenerated on every edit and reading it only wastes context. ` +
        `Read the source file instead: ${source}`,
    },
  });
}

let input;
try {
  input = JSON.parse(fs.readFileSync(0, "utf8"));
} catch {
  out({});
}

const toolName = input?.tool_name;
const toolInput = input?.tool_input ?? {};

if (toolName === "Bash") {
  const command = typeof toolInput.command === "string" ? toolInput.command : "";
  if (PREVIEW.test(command) && CONTENT_READERS.test(command)) {
    deny(command.match(/\S*\.preview\.html/i)?.[0] ?? "*.preview.html");
  }
} else if (toolName === "Grep") {
  const path = typeof toolInput.path === "string" ? toolInput.path : "";
  const glob = typeof toolInput.glob === "string" ? toolInput.glob : "";
  if (PREVIEW.test(path)) deny(path);
  if (PREVIEW.test(glob)) deny(glob);
} else {
  const filePath = toolInput.file_path;
  if (typeof filePath === "string" && PREVIEW.test(filePath)) deny(filePath);
}

out({});
