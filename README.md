# RailsによるAI駆動開発のサンプル

Ruby on RailsのMVCアプリかつモジュラーモノリス（DDD）構成で、AI駆動開発 × テスト駆動開発（TDD）で行うためのサンプルです。  
  
<br />
  
## AIツールとハーネス設計

AIツールはOpenAIの`Codex`を利用する例としており、ハーネス設計もしています。

### 1. コーデックスの設定

- `.codex/config.toml`

### 2. コーデックスのサンドボックス外禁止コマンド設定

- `.codex/rules/default.rules`

### 3. マルチエージェント設定

- `.codex/agents/pm.toml` （プロダクトマネージャー・指揮者）
- `.codex/agents/tester.toml` （テスター）
- `.codex/agents/implementer.toml` （実装者）
- `.codex/agents/reviewer.toml` （レビュワー）

### 4. ワークフロー設定

- `.codex/workflows/tdd_flow.md` （TDD開発フロー）

### 5. Agent Skills

- `.codex/skills/plan-to-issue` （プランモードで作成した開発計画をGitHubのIssue用のフォーマットへ変換して自動登録する）
- `.codex/skills/auto-commit/SKILL.md` （修正したコードをステージングしたうえで差分を解析し、適切なコミットメッセージを生成してgit commitまでを自動で実行する）
- `.codex/skills/auto-pr/SKILL.md` （直前のコミット内容をもとにPRタイトルと本文を生成し、GitHubのPR用フォーマットへ変換して自動登録する）

### 6. プロジェクト用

- `AGENTS.md` （全体のルール定義）
- `src/AGENTS.md` （Rails専用のルール定義）
- docs/rules （各種ルールの詳細定義）
  - `architecture.md` （アーキテクチャ設計のルール定義）
  - `boundaries.md` （コード配置のルール定義・境界ルール定義）
  - `database.md` （データベース設計のルール定義）
  - `rails.md` （Rails実装のルール定義）
  - `testing.md` （テストのルール定義）
  
<br />

## 動作要件

- Ruby: 4.0.2
- bundler: 4.0.10
- Rails: 8.1.3
- PostgreSQL: 18.3
  
<br />
  
## ローカル開発環境構築

### 1. 環境変数ファイルをリネーム
```
cp ./.env.example ./.env
```  
  
### 2. コンテナのビルドと起動
```
docker compose build --no-cache
docker compose up -d
```  
  
### 3. DB作成 + マイグレーションの実行
```
docker compose run --rm app bundle exec rails db:prepare
```

### 4. コンテナの停止・削除
```
docker compose down
```  
> ※ボリュームも合わせて削除したい場合は、オプション「-v」を付けて実行して下さい。（例：docker compose down -v）  
  
<br />
  
## Railsアプリの確認

ローカルサーバー起動後、ブラウザで「http://localhost:3000 」を開く
  
<br />
  
## コード修正後に使うコマンド

ローカルサーバー起動中に以下のコマンドを実行可能です。  
  
### 1. フォーマット修正
```
docker compose run --rm app bundle exec rubocop -A --only Layout
```  
  
### 2. 静的コード解析
```
docker compose run --rm app bundle exec rubocop
```  
  
### 3. erb用の静的コード解析
```
docker compose run --rm app bundle exec erb_lint app/views
```  
  
### 4. Railsの脆弱性チェック
```
docker compose run --rm app bundle exec brakeman --no-pager
```  
  
### 5. テスト実行
```
docker compose exec -T app bundle exec rspec
```  
  
<br />
  
## 参考記事  
  
<!-- [・Ruby on Railsで始めるAI駆動開発×TDD実践｜Codexとハーネスエンジニアリングで作るDDDモジュラーモノリス]()   -->
  