# Rails専用のルール定義

## 概要

このディレクトリ（src）はRails実装の「実行領域」であり、
設計判断はすべて docs/rules 側に集約されている。

src内では設計判断を行わず、既存ルールを適用するのみとする。

---

## ルール参照構造

すべての実装は以下のルールに従う：

- `docs/rules/architecture.md`（設計思想）
- `docs/rules/boundaries.md`（配置判断）
- `docs/rules/rails.md`（Rails実装ルール）
- `docs/rules/database.md`（データ制約）
- `docs/rules/testing.md`（テスト方針）

---

## src配下の責務

srcは「実装のみを行う領域」であり、
以下の責務に限定される：

- MVC構造の具体的実装
- モジュラーモノリス構造のコード配置
- `docs/rules/rails.md` に従った実装

---

## 実装ルール（重要）

srcでは以下を行ってはならない：

- ルールの解釈や再定義
- 設計判断
- 技術選定の追加判断

実装は常に docs/rules を唯一の判断基準として適用すること。

---

## このディレクトリの役割

- Railsコードの実装専用領域
- MVC構造の具体的なコード表現
- モジュラーモノリス構造の物理実装

---

## 禁止事項

- src配下に設計判断を書くこと
- domains / features / resourcesの定義を再説明すること
- database設計方針を記述すること
- テスト戦略を記述すること
- docs側のルールを上書きすること

---

## エージェントの振る舞い

- 判断はすべて docs/rules に従う
- srcは「適用のみ」を行う
- 迷った場合は `docs/rules/boundaries.md` を最優先で参照する
