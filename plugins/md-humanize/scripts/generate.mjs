// md-humanize — PostToolUse hook body.
// Write/Edit された Markdown を、隣に置く自己完結の読みやすい HTML へ
// 決定的に変換する。LLM もネットワークも使わない。
// プレビュー生成の失敗がセッションを妨げてはならないため、
// あらゆる異常系は静かに正常終了する。

import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const PLUGIN_ROOT = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

const SUFFIX = ".preview.html";
const GITIGNORE_PATTERN = "*.preview.html";

// 定型ファイルは読み物ではなく設定・記録なので変換しない
const EXCLUDED_BASENAMES = new Set([
  "claude.md",
  "agents.md",
  "changelog.md",
  "readme.md",
  "license.md",
  "contributing.md",
  "code_of_conduct.md",
  "security.md",
]);

const EXCLUDED_DIR_SEGMENTS = new Set([".claude", ".git", "node_modules"]);

function quiet() {
  process.stdout.write(JSON.stringify({ suppressOutput: true }));
  process.exit(0);
}

function escapeHtml(s) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

function shouldConvert(filePath, cwd) {
  if (!filePath || !/\.md$/i.test(filePath)) return false;
  const abs = path.resolve(cwd || ".", filePath);
  if (!fs.existsSync(abs)) return false;
  // 作業プロジェクトの外 (ホーム設定や共有メモリ等) には手を出さない
  if (cwd && !abs.startsWith(path.resolve(cwd) + path.sep)) return false;
  if (EXCLUDED_BASENAMES.has(path.basename(abs).toLowerCase())) return false;
  const rel = cwd ? path.relative(path.resolve(cwd), abs) : abs;
  for (const seg of rel.split(path.sep)) {
    if (EXCLUDED_DIR_SEGMENTS.has(seg)) return false;
  }
  return true;
}

function stripFrontmatter(md) {
  const m = md.match(/^---\r?\n[\s\S]*?\r?\n---\r?\n/);
  return m ? md.slice(m[0].length) : md;
}

// タイトルは先頭の h1 から取る (無ければファイル名)。h1 自体は本文に
// 残し、章の構造はテンプレート側のレイアウト構築層が組み立てる。
// 先頭章の h1 はヒーローと二重になるため描かれない (md-rebuilder 準拠)。
function extractTitle(md, fallback) {
  const m = md.match(/^\s*#\s+(.+)\r?\n?/);
  if (!m) return fallback;
  return m[1]
    .replace(/`([^`]*)`/g, "$1")
    .replace(/\*\*?([^*]*)\*\*?/g, "$1")
    .replace(/\[([^\]]*)\]\([^)]*\)/g, "$1")
    .trim() || fallback;
}

// md-rebuilder の変換層 (render.ts) と同じ構造で出力する。コードは
// figure.code-block (言語ラベル + コピーボタン付き) に包み、言語が
// 判明すればその言語で、不明なら highlightAuto で着色する。
function renderMarkdown(md) {
  const { Marked } = require(path.join(PLUGIN_ROOT, "vendor", "marked.min.js"));
  const hljs = require(path.join(PLUGIN_ROOT, "vendor", "highlight.min.js"));
  const marked = new Marked({ gfm: true, breaks: false });
  marked.use({
    renderer: {
      code(code, infostring) {
        const language = (infostring || "").trim().split(/\s+/)[0];
        const known = language && hljs.getLanguage(language);
        const highlighted = known
          ? hljs.highlight(code, { language, ignoreIllegals: true }).value
          : hljs.highlightAuto(code).value;
        const label = escapeHtml(known ? language : "text");
        return (
          `<figure class="code-block" data-lang="${label}">` +
          `<figcaption class="code-head">` +
          `<span class="code-lang">${label}</span>` +
          `<button type="button" class="code-copy">コピー</button>` +
          `</figcaption>` +
          `<pre><code class="hljs language-${label}">${highlighted}</code></pre>` +
          `</figure>`
        );
      },
    },
  });
  return marked.parse(md);
}

function formatNow() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`;
}

function findGitRoot(startDir) {
  let dir = startDir;
  for (;;) {
    if (fs.existsSync(path.join(dir, ".git"))) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

// 生成物がコミットされてゴミにならないよう、初回に限り
// リポジトリの .gitignore へパターンを足す
function ensureGitignore(mdAbsPath) {
  const root = findGitRoot(path.dirname(mdAbsPath));
  if (!root) return null;
  const gitignorePath = path.join(root, ".gitignore");
  let body = "";
  if (fs.existsSync(gitignorePath)) {
    body = fs.readFileSync(gitignorePath, "utf8");
    const lines = body.split(/\r?\n/).map((l) => l.trim());
    if (lines.includes(GITIGNORE_PATTERN)) return null;
  }
  const entry = `# md-humanize (Claude Code plugin): generated HTML previews\n${GITIGNORE_PATTERN}\n`;
  const sep = body === "" || body.endsWith("\n") ? "" : "\n";
  fs.appendFileSync(gitignorePath, sep + (body === "" ? "" : "\n") + entry);
  return path.join(root, ".gitignore");
}

function main() {
  const raw = readStdin();
  if (!raw) quiet();

  let input;
  try {
    input = JSON.parse(raw);
  } catch {
    quiet();
  }

  const filePath = input?.tool_input?.file_path;
  const cwd = input?.cwd;
  if (!shouldConvert(filePath, cwd)) quiet();

  const abs = path.resolve(cwd || ".", filePath);
  const md = fs.readFileSync(abs, "utf8");

  const sourceName = path.basename(abs);
  const sourcePath = cwd ? path.relative(path.resolve(cwd), abs) : abs;
  const body = stripFrontmatter(md);
  const title = extractTitle(body, sourceName.replace(/\.md$/i, ""));
  const charCount = body.replace(/\s/g, "").length;

  const template = fs.readFileSync(path.join(PLUGIN_ROOT, "assets", "template.html"), "utf8");
  const html = template
    .split("{{TITLE}}").join(escapeHtml(title))
    .split("{{SOURCE_NAME}}").join(escapeHtml(sourceName))
    .split("{{SOURCE_PATH}}").join(escapeHtml(sourcePath))
    .split("{{GENERATED_AT}}").join(formatNow())
    .split("{{CHAR_COUNT}}").join(`${charCount.toLocaleString("en-US")} 字`)
    .split("{{CONTENT}}").join(renderMarkdown(body));

  const outPath = abs.replace(/\.md$/i, SUFFIX);
  fs.writeFileSync(outPath, html);

  let touchedGitignore = null;
  try {
    touchedGitignore = ensureGitignore(abs);
  } catch {
    // gitignore への追記失敗はプレビュー生成の成否に影響させない
  }

  const out = { suppressOutput: true };
  if (touchedGitignore) {
    out.systemMessage =
      `md-humanize: added "${GITIGNORE_PATTERN}" to ${touchedGitignore} so generated previews stay out of commits.`;
  }
  process.stdout.write(JSON.stringify(out));
  process.exit(0);
}

try {
  main();
} catch {
  quiet();
}
