---
name: auto-pr
description: 直前のコミット内容をもとにPRタイトルと本文を生成し、GitHubのPR用フォーマットへ変換して自動登録する
---

# auto-pr

## 概要

このスキルは、直前のコミット内容をもとにPRタイトルと本文を生成し、GitHubのPR用フォーマットへ変換して自動登録します。

## 参照ファイル

このスキルを実行する際は、以下のファイルを必ず読み込んで使用してください。

- PRテンプレート: `assets/template.md`
- PR作成スクリプト: `scripts/create_pr.sh`

## 入力

直前のコミット情報

## 出力

GitHubのPR（gh pr create により自動登録）

---

## 実行手順

### 1. 直前のコミット情報と変更内容を取得する

```bash
git log -1 --pretty=format:"%h%n%s%n%b"
git show --no-color
```

- git log: 意図（タイトル・背景）
- git show: 変更内容（diff）

---

### 2. 解析して以下を生成する

- summary（概要）
- background（背景・目的）
- implementation（実装内容：箇条書き）
- test_items（テスト確認項目：チェックリスト形式）
- impact（影響範囲：箇条書き）
- future_work（未対応・今後の課題：箇条書き）

---

### 3. PR本文を生成する

`assets/template.md` を読み込み、以下ルールで置換する：

- {{summary}} → summary
- {{background}} → background
- {{implementation}} → implementation
- {{test_items}} → test_items
- {{impact}} → impact
- {{future_work}} → future_work

---

### 4. PRタイトルを生成する

フォーマット：

```text
auto: <summaryの短縮版>
```

---

### 5. PRを作成する

現在のブランチをGitHubへ反映し、そのブランチを元にPRを作成する。

#### 5-1. 現在のブランチをGitHubへプッシュ

以下のコマンドを実行し、現在のブランチをGitHubへプッシュします。

```bash
git push -u origin HEAD
```

※ pushに失敗した場合は処理を中断する

#### 5-2. PR作成

`scripts/create_pr.sh` を利用し、生成したPRタイトルと本文をGitHubのプルリクエストに登録します。

---

## 補足ルール

- implementation / impact / future_work は必ず箇条書きで出力する
- test_items はチェックリスト形式（- [ ]）で出力する
- diff（git show）を必ず参照し、推測のみで生成しない
