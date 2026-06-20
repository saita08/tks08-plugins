# AI Company Studio

> "社員全員AI、オーナーだけ人間。それ、会社って呼んでいいのか？" -- 呼んでいい。

Git リポジトリの中に会社を建てるプラグイン。
ディレクトリが部屋で、Markdownファイルが社員。家賃はゼロ、給料もゼロ、でも会議では意見が割れる。

## これは何？

`/create-company` と打つと会社ができます。`/company-health-check` と打つと健康診断ができます。`/migrate-company` と打つと古い会社を新しい Agent Teams API に移します。以上です。

もう少し正確に言うと、「どんな会社？」「社員は？」「部屋は？」と聞かれるので答えてください。答え終わると、CEO が住む CLAUDE.md、社員証が並ぶ `members/`、社内規定が詰まった `standards/`、その他もろもろが一式生成されます。できた会社は Claude Code の Agent Teams でそのまま動きます。

## 使い方

```
/create-company
```

1. 「どんな会社？」（投資顧問でもゲームスタジオでもラーメン屋でも）
2. 「社員は何人？」（CEO が全員の名前を覚えられる程度に）
3. 「部屋はどうする？」（提案するので選ぶだけ）
4. 全ファイルを一括生成
5. 整合性チェック（「CEO がこの CLAUDE.md で目覚めたら、混乱せずに出勤できるか？」を検証）

```
/company-health-check
```

会社の人間ドック。結果は `docs/` に残ります。ドックだけに。処方箋付き。ただし手術はしません。

```
/migrate-company
```

古い会社の引っ越し業者。Claude Code v2.1.178 で Agent Teams の仕様が変わり、`TeamCreate` や `team_name` を使う旧来の社員呼び出し手順は動かなくなりました。このコマンドは既存会社の CLAUDE.md などを新しい呼び出し方（`Agent` ツールの `name` でチームメイトを召喚）に書き換えます。健診で「旧APIのままですよ」と指摘されたらこれを。書き換える前に差分を見せて確認を取ります。勝手に手術はしません。

## 生成されるもの

```
your-company/
  CLAUDE.md      -- CEO の意識。毎朝ここから目覚める（比喩ではない）
  COMPANY.md     -- 会社の憲法。破ったら CEO に怒られる
  members/       -- 社員証置き場。入社も退職も git commit
  standards/     -- 社内規定。増えるのは何か失敗した時
  docs/          -- 議事録の墓場。でも CEO は毎朝ここを読む
  shared/        -- 給湯室。ナレッジとメッセージが置いてある
```

業態に応じて `projects/` や `clients/` など、仕事のための部屋が追加されます。

## インストール

```bash
claude plugin add tks08/ai-company-studio
```

または tks08-plugins マーケットプレイスから:

```bash
claude plugin add --marketplace github:tks08/tks08-plugins ai-company-studio
```

## 動作要件

生成された会社は Claude Code の Agent Teams 機能（実験的）の上で動きます。会社を動かすには2つ必要です。

- **Claude Code v2.1.178 以降** — 社員（チームメイト）を `Agent` ツールの `name` で召喚する現行APIのため。
- **`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`** — `settings.json` の `env` か環境変数で設定。これが無いとチームが結成されず、CEO は社員を呼べません。

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

会社を建てる `/create-company` 自体はファイルを生成するだけなので、この要件は会社を**動かすとき**に必要です。

## 構成

```
ai-company-studio/
├── commands/
│   ├── create-company.md        # 建設
│   ├── company-health-check.md  # 健診
│   └── migrate-company.md       # 引っ越し（旧API会社の移行）
└── skills/
    ├── company-builder/          # 世界観設計の知見
    ├── company-health-check/     # 診断ロジック
    └── company-migrate/          # 移行ロジック
```

## FAQ

**Q: どんな業態でも作れる？**
A: 作れます。コンサル、メディア、探偵事務所、宇宙開発。ラーメン屋も理論上は可能ですが、麺の茹で加減はファイルに書けません。

**Q: 社員同士が仲悪くならない？**
A: 意見が割れるのは仕様です。全員「いいと思います」しか言わない会議に意味はありません。

**Q: 作った後、このプラグインは要る？**
A: `/create-company` は二度と使いません。建設業者に住み続けてもらう人はいないでしょう。`/company-health-check` だけ定期的に。

**Q: 既存の会社を作り直せる？**
A: `/create-company` は新規専用です。社員の入れ替えは `members/` を直接いじってください。入社も退職も git commit。人事部は不要です。ただし古いAPIで建てた会社を新しい Agent Teams API に**移す**なら `/migrate-company` があります。作り直しではなく、社員呼び出し手順だけを今の仕様に書き換えます。

**Q: 前に作った会社が動かなくなった？**
A: Claude Code v2.1.178 で Agent Teams の仕様が変わり、`TeamCreate` や `team_name` を使う旧来の呼び出し手順は動かなくなりました。`/company-health-check` で旧APIのままか分かります。`/migrate-company` で現行APIへ移せます。

**Q: 会社がうまく回らない？**
A: `/company-health-check` を試してください。大抵の問題は「CEO の CLAUDE.md と実態がズレている」か「社内規定が初日のまま」です。
