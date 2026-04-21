#!/usr/bin/env bash

set -euo pipefail

# ===============================
# Usage:
# ./create_pr.sh "タイトル" "本文"
# ===============================

TITLE="${1:-}"
BODY="${2:-}"

# タイトルと本文の入力チェック
if [[ -z "$TITLE" || -z "$BODY" ]]; then
  echo "Usage: $0 \"タイトル\" \"本文\""
  exit 1
fi

# gh コマンド存在チェック
if ! command -v gh &> /dev/null; then
  echo "gh コマンドが見つかりません"
  exit 1
fi

# GitHub認証チェック
if ! gh auth status &> /dev/null; then
  echo "GitHubにログインしていません"
  echo "gh auth login を実行してください"
  exit 1
fi

echo "PRを作成中..."

# 一時ファイル作成
TMP_FILE=$(mktemp)

# 一時ファイルをスクリプト終了時に削除
trap 'rm -f "$TMP_FILE"' EXIT

# 本文を一時ファイルに書き込み
printf "%s" "$BODY" > "$TMP_FILE"

# PR作成
gh pr create \
  --title "$TITLE" \
  --body-file "$TMP_FILE"

echo "PR作成完了"
