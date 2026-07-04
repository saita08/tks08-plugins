# Templates

Skeletons for the entry-point files the four-track structure needs. Fill placeholders from what the repository actually shows; do not invent facts to complete a template. A template section that has nothing true to hold is deleted, not padded.

## Root README.md — the documentation map section

Append to an existing README (or include in a new one). The prose around it stays the project's own.

```markdown
## ドキュメント

このリポジトリは知識を四層で管理する。同じ内容を複数に書かない。取り決めは
[ADR-0002](adr/0002-adopt-four-track-documentation.md)。

- **[CLAUDE.md](CLAUDE.md)** — このプロジェクトの価値観・判断基準
- **[docs/](docs/README.md)** — 今どうなっているか。構成・手順・データ契約
- **[adr/](adr/README.md)** — なぜそう決めたか。設計判断の記録
- **[references/](references/)** — 開発時に参照する生データ。実機に当たれない環境で形を確認するためだけに使う

実装を始める前に [docs/README.md](docs/README.md) を入り口として読む。
```

Omit the `references/` line when the project has no raw reference data.

## CLAUDE.md — values skeleton

Generate the opening and closing from this form; the middle principles must come from the project itself (observed conventions, the owner's stated priorities, decisions already visible in the code). Placeholder principles help no one — if only two values are known, write two.

```markdown
# CLAUDE.md

This document explains the values and reasoning that should guide work in this
repository. It does not describe structure, commands, or data formats — those live
in `docs/`; the history of why each choice was made lives in `adr/`.

Before implementing, read [docs/README.md](docs/README.md) for the current state
and [adr/README.md](adr/README.md) for the decision history.

## <Principle name, stated as a value>

<Why it matters, general enough to guide unanticipated situations.>

## The four-track knowledge contract is load-bearing

Knowledge here is split across tracks: this file holds the values, `docs/` holds
what is true now, `adr/` holds why each choice was made, and `references/` holds
raw reference data. The same content is never written into more than one track.
When the structure changes, `docs/` moves with it and the ADR is written before
the implementation lands.
```

## docs/README.md

```markdown
# <project> ドキュメント

<One paragraph: what the project is, from the docs/ reader's point of view.>

## このディレクトリの役割

`docs/` は「今この瞬間に何があるか」を記述する。なぜそう決めたかは
[adr/](../adr/README.md) に、価値観はルートの [CLAUDE.md](../CLAUDE.md) にある。
同じ内容を複数箇所には書かない。各ドキュメントは関連する判断の ADR へリンクする。

## ドキュメント一覧

| ファイル | 目的 |
|---|---|
| <file>.md | <purpose> |
```

## adr/README.md

```markdown
# Architecture Decision Records

このディレクトリは、<project> の設計判断を時系列で記録する。各レコードは
「なぜそう決めたか」を後から辿れるようにするためのものであり、「今どうなっているか」は
`docs/` 側に記述する。同じ内容を両方には書かない。

## 書くタイミング

後から見て判断理由がわからなくなりそうな選択をしたとき。「なぜこの道を選び、どの道を
捨てたか」が論点になるものを書く。小さな実装詳細は対象外。設計判断をしたら ADR を先に書き、
`docs/` と相互リンクを張ってから実装する。

## ステータス遷移

- `Proposed` — 提案中。議論の対象
- `Accepted` — 採用。実装の前提となる
- `Superseded by ADR-XXXX` — 後続の ADR に置き換えられた。本文は履歴として残す
- `Deprecated` — 廃止。置き換え先はない

採用済みの ADR は書き換えない。判断が変わったら新しい ADR を起こし、古い方のステータスを
更新して相互にリンクする。

## 一覧

| # | タイトル | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
```

## adr/template.md

```markdown
# NNNN. <Decision title, stated as the choice made>

- Status: Proposed
- Date: YYYY-MM-DD
- Deciders: <who>

## Context

<The forces at play: the problem, the constraints, what made a decision necessary.>

## Decision

<What was chosen, stated plainly.>

## Consequences

<What becomes easier, what becomes harder, what obligations this creates.
Link the docs/ pages this decision shapes.>

## Alternatives Considered

- **<Alternative>**: <why it was rejected>
```

## adr/0001 and 0002 — the records setup itself writes

A bootstrap is itself two decisions, and they are recorded like any other: `0001-record-architecture-decisions.md` records the adoption of ADRs, and `0002-adopt-four-track-documentation.md` records the adoption of the documentation contract, both dated the day setup ran, with Alternatives Considered filled honestly (one document for everything; a wiki; doing nothing). Write them from the template above. A structure that preaches "record your decisions" but cannot show the record of its own adoption starts life in contradiction with itself.
