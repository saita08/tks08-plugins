# CLAUDE.md

Claude Code プラグインリポジトリ。

## Structure

- `plugins/` - 各プラグインを配置
- `.claude-plugin/marketplace.json` - プラグイン登録
- `docs/` - リポジトリ運用ルール
- `CHANGELOG.md` - 変更履歴（[Keep a Changelog](https://keepachangelog.com/) 形式）

## Plugin Types

1. **MCP Plugin**: `.mcp.json` で MCP サーバーを定義
2. **Skill Plugin**: `skills/<name>/SKILL.md` でスキルを定義

## Adding New Plugin

1. `plugins/<name>/` を作成
2. `.claude-plugin/plugin.json` を追加
3. `marketplace.json` に登録

## Updating a Plugin

1. `plugin.json` の `version` を更新する（semver に従う）
2. `CHANGELOG.md` に変更内容を記録する
3. マージ後にリポジトリのタグを打つ（ルールは `docs/versioning.md` を参照）

## Rules

- marketplace.json の source と実際のディレクトリ名を一致させる
- Skill の allowed-tools は必要最小限に
- バージョニングは `docs/versioning.md` のルールに従う
- 変更時は `CHANGELOG.md` を更新する

## Reference

- [Plugin Marketplaces - Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
