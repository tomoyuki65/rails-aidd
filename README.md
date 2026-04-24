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
- `.codex/skills/auto-commit` （修正したコードをステージングしたうえで差分を解析し、適切なコミットメッセージを生成してgit commitまでを自動で実行する）
- `.codex/skills/auto-pr` （直前のコミット内容をもとにPRタイトルと本文を生成し、GitHubのPR用フォーマットへ変換して自動登録する）

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
  
## Railsのディレクトリ構成

今回のRailsのディレクトリ構成は、モジュラーモノリスおよびドメイン駆動設計（DDD）を前提に設計しています。  
  
ただし、アプリケーション全体に対してDDDを全面的に適用することは、本質的ではないケースも多く、実装・運用コストも高くなりがちです。また、モジュラーモノリスやDDDを強く意識した設計は、Railsが本来持つシンプルさや生産性といった利点からは一定程度離れることにもなります。  
  
そこで本構成では、Railsの持つ開発効率の良さと、DDDによるドメインの明確化という両方の利点を活かすために、両者を組み合わせたハイブリッドなアプローチを採用しています。  
  
具体的には、システムを以下の3つの業務領域に分類することを前提としています。  
  
- 中核の業務領域
- 補完的な業務領域
- 一般的な業務領域
  
このうち、ビジネス上の競争優位性に直結する「中核の業務領域」に対してのみDDDを適用し、それ以外の領域についてはRailsの標準的な構成やシンプルな設計を採用します。  
  
これにより、重要なドメインには十分な設計投資を行いつつ、全体としては過度に複雑化しないバランスの取れた構成を目指しています。  
  
以上の方針を踏まえ、Railsのディレクトリ構成は以下のように設計しています。  
  
```
/src
 └── /app
      ├── /controllers（コントローラー定義）
      |    |
      |    ├── /web
      |    |
      |    └── /api （将来的に利用する想定のAPIモード用）
      |
      ├── /models（アプリ全体の共通データ層・ActiveRecordモデル置き場）
      |
      ├── /views（Rails用のビュー）
      |
      ├── /domains（中核の業務領域・ドメイン駆動設計）
      |    |
      |    └── /[domain_name]
      |         |
      |         ├── /domain（ドメイン層）
      |         |    |
      |         |    ├── /entities（エンティティ）
      |         |    |
      |         |    ├── /value_objects（値オブジェクト）
      |         |    |
      |         |    ├── /services（ドメインサービス）
      |         |    |
      |         |    └── /repositories（リポジトリのインターフェース）
      |         |
      |         ├── /use_cases（ユースケース層）
      |         |
      |         └── /infrastructure（インフラストラクチャ層）
      |              |
      |              └── /repositories（リポジトリの実装）
      |                   |
      |                   ├── /command（書き込み）
      |                   |
      |                   └── /query（読み取り）
      |
      ├── /features（補完的な業務領域・トランザクションスクリプト）
      |    |
      |    └── /[feature_name]
      |         |
      |         └── /services（サービス層） 
      |
      ├── /resources（一般的な業務領域・アクティブレコード）
      |     ※例：user.rbやpayment_gateway.rbなどを置く
      |
      └── /shared（横断関心）
```
  
<br />
  
## 動作要件

- Ruby: 4.0.2
- bundler: 4.0.10
- Rails: 8.1.3
- PostgreSQL: 18.3
- Lefthook（format/lint自動化ツール）
  - ※事前にbrewなどでインストールして下さい。 
  
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
  
## 本番環境用のDockerコンテナについて

本番環境用のDockerコンテナの作り方について、Rails8には最初から本番環境用を想定したDockerfileが入っているため、これを利用すると作れます。  
  
ローカル開発環境でビルドして確認したい場合は、以下の手順で行なって下さい。  
  
### 1. Dockerコンテナのビルド

以下のコマンドを実行し、Dockerコンテナをビルドします。  
  
```
docker build --no-cache -t rails-aidd-app:1.0.0 -f src/Dockerfile src
```
  
> ※事前に各種設定ファイル（src/config/environments/production.rbやsrc/config/database.ymlなど）の必要な箇所を修正しておいて下さい。この例では本番環境用を想定し、タグにはバージョン「1.0.0」を付けてます。
  
### 2. Dockerコンテナの起動

以下のコマンドを実行し、Dockerコンテナを起動します。
  
```
docker run -d \
-p 80:80 \
-e RAILS_MASTER_KEY={src/config/master.keyの中身の値} \
-e DB_HOST=host.docker.internal \
-e DB_USER=root \
-e DB_PASSWORD=root \
rails-aidd-app:1.0.0
```
  
> ※Dockerコンテナを起動するタイミングで環境変数を渡します。実際に本番環境で環境変数を設定する際は各種インフラにあるシークレットサービスを使って下さい。
  
<br />
  
## 参考記事  
  
[・Ruby on Railsで始めるAI駆動開発×TDD実践｜Codexとハーネスエンジニアリングで作るDDDモジュラーモノリス](https://tomoyuki65.com/rails-ai-tdd-ddd-modular-monolith)  
  