---
name: ad-design
description: This skill should be used when designing when and how a free app shows ads — when the user mentions "無料版に広告を入れたい", "広告の出しどき", "広告モデルの設計", "インタースティシャルをどこで出す", "リワード動画", "広告の頻度制御", "広告除去の IAP", "クロスプロモを混ぜたい", "App Open Ads", "ATT プロンプト", "AdMob の組み込み方", or plans a free-tier-with-ads monetization for an app. Provides product-agnostic principles for ad timing, frequency, presentation, and implementation, distilled from a shipped iOS app's ADRs and checked against industry practice as of 2026.
user-invocable: false
allowed-tools: Read
---

# 幕間の広告設計

無料版と広告で成り立つアプリにおいて、広告をいつ・どのように出すかの原則を収める。出典は出荷済みの iOS アプリで複数の ADR と実機検証を経て練られた判断であり、AdMob のガイドライン、App Store Review Guideline、ATT の実務といった 2026 年時点の業界定石と照合してプロダクト非依存の形に書き直してある。

中核は一つの価値である。広告の害は平均頻度ではなく最悪の一回で決まる。利用者が道具本来の仕事をしている最中——舞台の上、商談の途中、計測の最中——に出た一回の広告は、その道具への信頼を壊す。だから広告は幕間にだけ出す。すなわち、出してよい瞬間を作業の区切りとして限定列挙し、それ以外のすべてを禁止に倒し、この判定をすべての広告に先立つ共通ゲートに一箇所集約する。

参照ファイルは関心で分かれている。全部を一度に読まず、手元の設計課題に合うものだけを読む。

- `references/placement.md` — 出しどき。客前回避の絶対原則、発火可能ポイントの限定列挙、二段ゲート、初回セッションの保護、自作モーダルと App Open Ads という起動時広告の二方式の比較。広告をどこに置くかを決めるとき、また新しい広告枠の提案を評価するときに読む。
- `references/frequency.md` — 頻度。自動 capping とリワードへ移譲するユーザー主導という二つの思想、後者の成立条件、思想を問わず守る下限、静寂期間と停止の単調合成、リワード経済の規律。広告の頻度・リワード・広告除去 IAP を設計するときに読む。
- `references/presentation.md` — 出し方。予告画面と世界観の語彙による命名、自作モーダルの佇まい、ハウス広告の規律、App Store Review Guideline 2.5.18、ATT プロンプトの出しどき。広告の見た目・提示・審査要件を設計するときに読む。
- `references/engineering.md` — 実装。SDK シーム分離と実装順、乱数・時刻・シーン遷移の注入による決定的テスト、フォアグラウンド復帰の誤検知の教訓、クロスプロモの確率混合と三段フォールバック。広告コードを書く段になったら読む。

適用にあたって三つの姿勢を保つ。第一に、発火確率、停止時間、混合比率といった本文中の数値はすべて出典プロダクトの調整結果であって原則ではない。持ち帰るのは構造であり、数値は対象プロダクトで調整し直す定数として実装する。第二に、原則を対象プロダクトへ移すときは、その世界観の語彙で名付け直す。出典では予告画面を INTERMISSION と呼んだが、それは舞台の語彙を持つアプリだったからである。第三に、iOS と AdMob に固有の事項は本文でその旨を明示してあるので、他プラットフォームでは構造だけを移す。
