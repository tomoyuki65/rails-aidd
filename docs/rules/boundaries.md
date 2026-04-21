# コード配置のルール定義・境界ルール定義

## 目的

業務重要度と役割に応じてコードの配置場所を決定する。

---

## ディレクトリ構造の前提

```
/src
 ├── /app
 |    ├── /controllers（コントローラー定義）
 |    |    |
 |    |    ├── /web
 |    |    |
 |    |    └── /api （将来的に利用する想定のAPIモード用）
 |    |
 |    ├── /models（アプリ全体の共通データ層・ActiveRecordモデル置き場）
 |    |
 |    ├── /views（Rails用のビュー）
 |    |
 |    ├── /domains（中核の業務領域・ドメイン駆動設計）
 |    |    |
 |    |    └── /[domain_name]
 |    |         |
 |    |         ├── /domain（ドメイン層）
 |    |         |    |
 |    |         |    ├── /entities（エンティティ）
 |    |         |    |
 |    |         |    ├── /value_objects（値オブジェクト）
 |    |         |    |
 |    |         |    ├── /services（ドメインサービス）
 |    |         |    |
 |    |         |    └── /repositories（リポジトリのインターフェース）
 |    |         |
 |    |         ├── /use_cases（ユースケース層）
 |    |         |
 |    |         └── /infrastructure（インフラストラクチャ層）
 |    |              |
 |    |              └── /repositories（リポジトリの実装）
 |    |                   |
 |    |                   ├── /command（書き込み）
 |    |                   |
 |    |                   └── /query（読み取り）
 |    |
 |    ├── /features（補完的な業務領域・トランザクションスクリプト）
 |    |    |
 |    |    └── /[feature_name]
 |    |         |
 |    |         └── /services（サービス層） 
 |    |
 |    ├── /resources（一般的な業務領域・アクティブレコード）
 |    |     ※例：user.rbやpayment_gateway.rbなどを置く
 |    |
 |    └── /shared（横断関心）
 |
 └── /spec（テストコード）
```

---

## レイヤー定義

### app/controllers（コントローラー）

- HTTPリクエストを受け取り、レスポンスを返すための薄いレイヤー
- パラメータの受け取り・バリデーション・認証/認可の入口を担う
- ユースケース層（app/domains/*/use_cases or app/features/*/services or app/resources/*）を呼び出す
- 業務ロジックは持たない（持ってはいけない）
- レスポンス整形（JSON / HTML）は行うが、ビジネス判断は行わない

#### 依存ルール

- controllers → ユースケース（app/domains/*/use_cases or app/features/*/services or app/resources/*）
- controllers → views（HTMLの場合）

---

### app/models（データ層 / ActiveRecordモデル置き場）

- ActiveRecordベースのDBテーブルとのマッピングを担う
- スキーマ表現・リレーション・スコープなどの永続化に近い関心を持つ
- コールバックやロジックは極力最小限に抑える
- ドメイン層から直接使わず、Infrastructure層経由で利用するのが基本
- 「Fat Model」にしない（ビジネスロジックはドメインへ）

#### 依存ルール

- models ← infrastructure（repositoryなど）

---

### app/views（Rails用のビュー）

- HTMLテンプレートの描画を担う
- 表示ロジック（フォーマット・簡単な条件分岐）のみ許容
- 業務ロジックやドメイン知識は持たない
- instance変数はcontrollerから受け取る

#### 依存ルール

- views ← controllers

---

### app/domains（中核の業務領域 / ドメイン駆動設計）

- アプリケーションの最も重要なビジネスロジックを集約
- 境界づけられたコンテキスト（= domain_name）単位で分割

#### domain/entities

- 同一性（ID）を持つオブジェクト
- ビジネスルール・不変条件を保持
- 永続化手段（ActiveRecordなど）に依存しない

#### domain/value_objects

- 不変オブジェクト
- 値による等価性で比較される
- ドメインルールを内包可能（例：金額、メールアドレス）

#### domain/services

- エンティティやVOに属さないドメインロジック
- 複数のエンティティにまたがるビジネスルールを表現

#### domain/repositories

- リポジトリのインターフェース定義
- 実装部分はinfrastructure/repositoriesで行う
- コマンド・クエリ責務分離（CQRS）設計とし、command（書き込み）とquery（読み取り）に分ける

#### use_cases

- アプリケーションのユースケース単位の処理
- トランザクション境界を管理
- ドメインオブジェクトを組み合わせて処理を実行
- 外部I/F（repositoryなど）はインターフェース経由で利用

#### infrastructure/repositories

- 永続化の具体実装
- ActiveRecord（app/models）を利用してDBアクセスを行う
- ドメイン層に定義されたRepositoryインターフェースを実装
- 外部APIや他システム連携もここに含めてよい

#### 依存ルール

- domain層は他のレイヤーに依存しない
- use_casesはdomainに依存するが、infrastructureの詳細には依存しない（DI前提）
- infrastructureはdomainに依存してよい

---

### app/features（補完的な業務領域 / トランザクションスクリプト）

- ドメインとして切り出すほどではないが、機能としてまとまりがある処理
- シンプルな業務ロジックを扱う
- サービスとして実装する

#### services

- 1サービス1ユースケースとして表現
- ActiveRecord（app/models）を直接利用してよい
- 複雑化したらdomainsへ昇格させる前提

#### 位置づけ

- 軽量なユースケース層
- DDDの厳密さを求めない代わりにスピードを優先

#### 依存ルール

- features → models はOK
- features → domains は原則避ける

---

### app/resources（一般的な業務領域 / アクティブレコード）

- 単純なCRUD処理など、共通の仕組みを利用するような処理

#### 例

- ActiveRecordベースのシンプルなCRUD処理
  - 例：User、PaymentGatewayなど
- 外部サービスのような共通の仕組みを利用する単純な処理
- ビジネスルールが薄い処理

#### 役割

- ドメインに昇格しないActiveRecordベースの共通処理置き場

---

### app/shared（横断関心）

- 全レイヤーから参照可能な共通処理

#### 例

- /utils
- /constants
- /types
- /errors
- /validators
- /formatters
- /time
- /pagenation

---

### spec（テストコード）

#### 基本方針

- レイヤーごとに責務に応じたテストを行う
- 下位レイヤーほど高速・純粋、上位レイヤーほど統合的に検証する
- 「どこで何を保証するか」を明確にし、テストの重複を避ける
- ビジネスロジックは domainsで担保する（他レイヤーで重複して検証しない）

--- 

#### 主な分類

- controllers：インテグレーションテスト → リクエストスペック
  - HTTPリクエスト/レスポンスの検証（ステータスコード、JSON構造など）
  - 認証・認可の動作確認
  - ユースケースが正しく呼ばれていることの間接確認
  - 業務ロジックの詳細までは検証しない
  - 可能な限りモックを使わず、実際のスタックに近い形で検証する

- models：ユニットテスト → モデルスペック
  - スコープ・バリデーション・リレーションの検証
  - DBに近い振る舞い（クエリ結果など）の確認
  - コールバックは必要最小限にし、テストも最小限に留める
  - ビジネスロジックはテストしない（domainで担保）

- views：E2Eテスト → システムスペック
  - ユーザー操作を通した画面表示の検証
  - フォーム入力〜結果表示までの一連のフロー確認
  - 表示崩れや重要なUI要素の存在確認
  - 細かい文言やHTML構造には依存しすぎない
  - JavaScriptを含む挙動もここで検証

- domains：ユニットテスト
  - ビジネスルール・不変条件の検証
  - エンティティ・ValueObject・ドメインサービスの振る舞い確認
  - 外部依存（DB・API）は排除し、純粋なオブジェクトとしてテスト
  - 境界値・異常系を重点的にテストする
  - 最も網羅的かつ信頼できるテスト層

- features：インテグレーションテスト
  - Request Specを利用
  - サービス単位でのユースケース検証
  - ActiveRecordを含めた一連の処理の動作確認
  - 複雑な分岐や副作用（レコード作成・更新）を検証
  - controller経由 or 直接サービス呼び出しのどちらでもよい
  - domainに昇格すべきロジックが混ざっていないかの検知にも使う

- resources：E2Eテスト
  - API：request spec（統合テスト） / View：system spec（E2Eテスト）
    - API：クライアント視点でリクエストの連携が成立することを担保
    - View：ユーザー操作として一連の体験が成立することを担保
  - 主要なフロー（登録 → 認証 → 操作）の検証
  - 認証・認可・決済など横断的関心の動作確認
  - クライアント視点でAPIが正しく連携できることを担保
  - 成功パターンを中心に最小限のケースに絞る
  - 詳細なバリデーションや分岐ロジックは下位レイヤーで担保

---

#### 補足ポリシー

- ドメイン層は最速で実行できるテストにする（DBアクセス禁止）
- インフラ層（repositoryなど）は必要に応じて統合テストを行う
- モックは「外部境界」に限定して使用する（DB・外部APIなど）
- テストが壊れやすい構造（過度なモック、内部実装依存）を避ける
- 迷った場合は「その責務はどのレイヤーか」に立ち返って配置する

---

## ユースケース呼び出しルール

- controllerは各レイヤーに定義されたユースケースのみ呼び出す。
- 内部実装やモデルは直接呼ばない。

### 例

- domains/use_casesのユースケース
- features/servicesのユースケース
- resourcesのユースケース

---

## 配置判断基準

- HTTP処理 → controllers
- ActiveRecordモデル（永続化） → models
- 画面表示 → views
- ビジネスルール（純粋ロジック） → domains
- ユースケースの流れ制御 → features
- DBに対する単純操作（ロジックなし） → resources
- 共通処理 → shared

---

## 禁止事項

- domainsにCRUDロジックを混ぜる
- controllerに業務ロジックを書く
- レイヤー内部を直接呼び出す
