# kurofune

> 沖に見慣れぬ船影が四つ。
> 「攘夷だ！打ち払え！」
> 「お待ちください。あれは、コードが書けます」
> 「……上陸を許可する。ただし奉行の検分つきだ」

嘉永六年、黒船は日本を開国させました。このプラグインは逆をやります。xAI の Grok Build を港に迎え、**Claude 本体の会話からサブエージェントのように使役する**ための桟橋です。

## これは何？

`kurofune` は、Grok Build CLI をヘッドレスで走らせ、**メインの Claude 会話から直接**呼べる MCP ツールにします。

- `task` — 新しい Grok セッションを起こして実装を任せる
- `resume` — 同じ `sessionId` で追撃・修正する
- `doctor` — バイナリと認証を点検する

Docker やクラウドの常時サーバではありません。Claude Code があなたのマシン上でローカルプロセスを起動し、stdin/stdout で話すだけです。Grok を呼んだ分だけがコストです。

既定モデルは **grok-4.5** です（`KUROFUNE_MODEL` またはツール引数 `model` / `-m` で上書き）。

成果の正本は Grok の自己申告ではなく **作業ツリーの差分** です。ツール結果に `gitStatus` / `gitDiffStat` が載るので、メイン会話がその場で検分できます。完全な Grok 応答は `resultFile`（既定: `$TMPDIR/kurofune-results/`）にも残るので、表示が切れても `sessionId` を拾い直せます。

## 通商条約 五箇条

**一、入港は git の港に限る。** write モードで書き込んでよいのは git 管理下のディレクトリだけです。

**二、荷揚げは桟橋まで。commit はさせない。** 任務書には毎回「Do not commit」と明記します。

**三、積荷に機密を載せない。** 任務書は海を渡ります。

**四、艦長の自己申告は証拠にならない。** `text` ではなく diff とテストを見る。

**五、見学のみの上陸もある。** `review: true`（`-r`）では書き込みとシェルをツール水準で外します。`stopReason: Cancelled` は「write が必要だったか、もっと狭い読取任務にせよ」という信号です。

## 使い方

プラグインを入れたあと Claude Code を再起動すると、MCP ツールがメイン会話から使えます。

```
このリファクタ、Grokに投げて
さっきのセッションでテスト X が落ちてるから直させて
```

Claude は（skill の教義どおり）メインから `task` / `resume` を直接呼びます。間に監督用の Claude エージェントを挟まないのが正道です。

裏の CLI 面:

```
kurofune.sh task   [-r] [-C DIR] [-m MODEL] "任務書"
kurofune.sh resume [-r] [-C DIR] [-m MODEL] SESSION_ID "追撃"
kurofune.sh doctor
```

## 開国の手続き

1. `curl -fsSL https://x.ai/cli/install.sh | bash` で Grok Build を据え付ける
2. `grok login` で手形を得る（SuperGrok または X Premium+）
3. 心配なら `doctor` ツール、または `kurofune.sh doctor`

| 変数 | 意味 |
| --- | --- |
| `KUROFUNE_GROK_BIN` | `grok` バイナリの場所（既定 `~/.grok/bin/grok`） |
| `KUROFUNE_MODEL` | 既定モデル（既定 `grok-4.5`） |
| `KUROFUNE_RESULT_DIR` | 生 JSON の保存先 |
| `KUROFUNE_TIMEOUT_MS` | MCP 側の待ち上限（既定 30 分） |

## レガシー

`kurofune-worker` エージェントは **MCP が使えないときのフォールバック** です。通常はメイン会話から MCP ツールを直接呼んでください。
