# Rails専用のルール定義

## 概要

このディレクトリ（src）はRails実装の「実行領域」であり、
設計判断はすべて docs/rules 側に集約されている。

src内では設計判断を行わず、既存ルールを適用するのみとする。

---

## Railsの設計思想（重要）

本プロジェクトはRailsの思想である  
**「設計より規約（Convention over Configuration）」を強く採用する。**

そのため以下を前提とする：

- 明示的な設計よりも、規約（Rails標準・docs/rules）を優先する
- 個別判断やカスタム設計は原則として禁止する
- 「設計を考えること」自体をsrcでは行わない

---

## 規約と設計の関係

本プロジェクトにおける「規約」とは以下を指す：

- Railsのフレームワーク規約
- `docs/rules/*` に定義されたプロジェクト規約

これらは実質的に**設計そのものの代替物**であり、
srcはそれを機械的に適用するだけの層である。

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
- 「どう設計するか」は考えない
- 「どの規約に従うか」だけを選択する
- 規約が曖昧な場合のみ docs/rules 側に遷移する

---

## 補足（重要）

srcは「設計を実装する場所」ではなく  
**「規約をコードに写像する機械である」**

---

## 実装後の必須チェック（重要）

コード修正・追加が一段落した場合、エージェントは必ず以下のコマンドを順番に実行し、
警告・エラーが存在しない状態を維持すること。

### コマンド一覧

#### 1. フォーマット修正（レイアウトのみ自動修正）

`docker compose run --rm app bundle exec rubocop -A --only Layout`

---

#### 2. 静的コード解析（Rubocop）

`docker compose run --rm app bundle exec rubocop`

---

#### 3. ビューLint（ビュー変更時のみ）

※ app/views に変更があった場合のみ実行

`docker compose run --rm app bundle exec erb_lint app/views`

---

#### 4. 脆弱性チェック（Brakeman）

`docker compose run --rm app bundle exec brakeman --no-pager`

---

#### 5. テスト実行（RSpec）

`docker compose exec -T app bundle exec rspec`

---

### 実行ルール

- 上記は「実装完了後に必ず順番に実行する」
- エラー・警告がある状態で完了としてはならない
- フォーマット（Layout）のみ自動修正を許可する（rubocop -A --only Layout）
- 上記以外の rubocop の自動修正（-A）は使用してはならない
- rubocop の指摘は自動修正に依存せず、必ずコード側で修正する
- テストが失敗している状態で終了してはならない
- すべてのチェックが通過するまで修正と再実行を繰り返す

---

### 位置づけ

これらのチェックは「設計判断」ではなく、  
**規約の適用結果を検証する工程**である。

したがって src の責務に含まれる。
