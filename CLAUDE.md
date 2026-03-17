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
2. `CHANGELOG.md` に変更内容を記録する（タグとリリースは CI が自動作成）

## Rules

- marketplace.json の source と実際のディレクトリ名を一致させる
- Skill の allowed-tools は必要最小限に
- バージョニングは `docs/versioning.md` のルールに従う
- 変更時は `CHANGELOG.md` を更新する
- プラグインの変更は、関連ファイル（plugin.json の version、CHANGELOG.md）の更新まで含めて1つの変更単位とする。コード修正だけコミットして version/CHANGELOG が後回しになると、リリースとの対応が崩れる
- 繰り返し可能なミスや振る舞いの問題が発生した場合、CLAUDE.md への原則追加を提案する。ルールとして定着させないと同じ問題が再発する


## Reference

- [Plugin Marketplaces - Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
