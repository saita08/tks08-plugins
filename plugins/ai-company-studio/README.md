# AI Company Studio

> "社員全員AI、オーナーだけ人間。それ、会社って呼んでいいのか？" -- 呼んでいい。

Git リポジトリの中に会社を建てるプラグイン。
ディレクトリが部屋で、Markdownファイルが社員。家賃はゼロ、給料もゼロ、でも会議では意見が割れる。

## これは何？

`/create-company` と打つと会社ができます。`/company-health-check` と打つと健康診断ができます。以上です。

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

## 構成

```
ai-company-studio/
├── commands/
│   ├── create-company.md        # 建設
│   └── company-health-check.md  # 健診
└── skills/
    ├── company-builder/          # 世界観設計の知見
    └── company-health-check/     # 診断ロジック
```

## FAQ

**Q: どんな業態でも作れる？**
A: 作れます。コンサル、メディア、探偵事務所、宇宙開発。ラーメン屋も理論上は可能ですが、麺の茹で加減はファイルに書けません。

**Q: 社員同士が仲悪くならない？**
A: 意見が割れるのは仕様です。全員「いいと思います」しか言わない会議に意味はありません。

**Q: 作った後、このプラグインは要る？**
A: `/create-company` は二度と使いません。建設業者に住み続けてもらう人はいないでしょう。`/company-health-check` だけ定期的に。

**Q: 既存の会社を作り直せる？**
A: 新規専用です。社員の入れ替えは `members/` を直接いじってください。入社も退職も git commit。人事部は不要です。

**Q: 会社がうまく回らない？**
A: `/company-health-check` を試してください。大抵の問題は「CEO の CLAUDE.md と実態がズレている」か「社内規定が初日のまま」です。
