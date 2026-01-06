# CLAUDE.md

Claude Code プラグインリポジトリ。

## Structure

- `plugins/` - 各プラグインを配置
- `.claude-plugin/marketplace.json` - プラグイン登録

## Plugin Types

1. **MCP Plugin**: `.mcp.json` で MCP サーバーを定義
2. **Skill Plugin**: `skills/<name>/SKILL.md` でスキルを定義

## Adding New Plugin

1. `plugins/<name>/` を作成
2. `.claude-plugin/plugin.json` を追加
3. `marketplace.json` に登録

## Rules

- marketplace.json の source と実際のディレクトリ名を一致させる
- Skill の allowed-tools は必要最小限に

## Reference

- [Plugin Marketplaces - Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
