# Rails実装のルール定義

モジュラーモノリス + ドメイン駆動設計（DDD）を併用する

## 1. 目的

本ドキュメントはRailsにおける実装ルールを定義する。

アーキテクチャ判断は `architecture.md` と `boundaries.md` に従い、
本書は「Railsコードの書き方・制約」に特化する。

---

## 2. 基本原則

### 2-1. controllersは薄くする

- HTTP入出力のみ担当
- 業務ロジック禁止
- 必ずユースケース層を呼び出す

#### 許可される処理

- パラメータ取得
- 認証・認可の入口処理
- ユースケースの呼び出し
- レスポンス整形

#### 禁止

- 条件分岐による業務判断
- DB操作
- ドメインロジック

---

### 2-2. modelsは永続化専用

- ActiveRecordはデータ層として扱う
- ビジネスロジック禁止
- scope・validation・associationのみ許可

#### 禁止

- 業務ルール
- 計算ロジック
- ドメイン判断

---

### 2-3. domainsは純粋な業務ロジック

- ActiveRecordに依存しない
- 不変条件を保証する
- 副作用を外に出す

#### 特徴

- エンティティ
- 値オブジェクト
- ドメインサービス

---

### 2-4. domainsのuse_caseはアプリケーション制御

- トランザクション境界を持つ
- domainを組み合わせる
- repository経由でデータアクセス

#### 禁止

- UIロジック
- ActiveRecord直接操作（原則）

---

### 2-5. featuresは軽量ユースケース

- 単純な業務フローを扱う
- ActiveRecord利用OK
- 複雑化したらdomainへ移行

---

### 2-6. resourcesはCRUD専用

- 単純なデータ操作のみ
- ビジネス判断を持たない
- マスタ・設定・ログなど

---

## 3. 依存ルール

### 基本方針

依存は一方向のみ（上位 → 下位）

---

### 3-1. controllers

- controllers → domains/[domain_name]/use_cases
- controllers → features/[feature_name]/services
- controllers → resources

#### ルール

- controllerは業務判断を持たない
- HTTP入出力のみに責務を限定する
- domains/[domain_name] / features/[feature_name] / resourcesのどれを呼ぶかの判断のみ行う

---

### 3-2. models

- models（ActiveRecordのモデルを集約） → DB永続化専用

---

### 3-3. domains（中核の業務領域）

#### domain/*

- domains/*/domain → 無依存（完全独立）
- repositories
  - domains/*/domain/repositories（interface）はインターフェース定義のみ
  - 実装はdomains/*/infrastructure/repositories（implementation）

#### use_cases

- domains/*/use_cases → domains/*/domain
- domains/*/use_cases → domains/*/domain/repositories（interface）

#### infrastructure

- リポジトリの実装を行う
- domains/*/infrastructure/repositories（implementation） → models
- コマンド・クエリ責務分離（CQRS）設計とし、command（書き込み）とquery（読み取り）に分ける

---

### 3-3. features（補完的な業務領域）

- features/*/services → models

#### ルール

- 単純な業務フローのみ扱う
- 複雑化した場合はdomainsへ移行

---

### 3-4. resources（一般的な業務領域）

- resources → models

#### ルール

- 単純なCRUD処理
- ビジネスロジック禁止

---

### 3-5. shared（横断関心）

- shared → 全レイヤーから参照可能

---

### 3-6. 全体制約

#### domainの絶対ルール

- domainはRailsに依存しない
- domainはActiveRecordを知らない
- domainは純粋なビジネスロジックのみ

#### infrastructureルール

- infrastructure（repositories実装）はmodelsに依存する
- コマンド・クエリ責務分離（CQRS）設計とする

---

### 依存方向まとめ

#### 中核の業務領域

```
controller
  ↓
domains/*/domain/use_cases 
  ↓
domain（entities / value_objects / services / repositories（interface））
  ↓
infrastructure/repositories（implementation）
  ↓
models（ActiveRecord実装）
```

#### 補完的な業務領域

```
controller
  ↓
features/*/services
  ↓
models（ActiveRecord実装）
```

#### 一般的な業務領域

```
controller
  ↓
resources
  ↓
models（ActiveRecord実装）
```

#### 共通処理

sharedは例外的に全方向参照可能

---

## 4. Rails特有の制約

### ActiveRecordの扱い

- domainsからは直接参照せず、repository経由でのみアクセスする
- featuresやresourcesは直接参照可能
- modelは純粋なデータ表現

---

### repositoryの責務分離（CQRS）

- Query Repository（読み取り専用）
  - データ取得
  - キャッシュ利用可能
  - パフォーマンス最適化OK
  - domainロジック禁止

- Command Repository（書き込み専用）
  - 作成・更新・削除
  - トランザクション管理の対象
  - domainルールの反映

---

### コールバック禁止方針

- callbackに業務ロジックを書かない
- 副作用はユースケースに集約する

---

### Fat Model禁止

- modelにロジックを集約しない
- 複雑化した場合はドメインモデルへ移動

---

## 5. トランザクション管理

- ユースケース層が唯一のトランザクション境界
- featuresでは必要最小限にし、以下に該当したらdomainsへ移行する
  - 条件分岐が増える
  - 状態遷移（ステータス変更ロジック）が含まれる
  - 複数のドメインルールが絡む
  - ルール変更の影響範囲が広い
  - ビジネス判断がコード内に現れ始める
- modelでは管理しない

---

## 6. 例外ルール

### 許可される例

- modelのバリデーション
- scopeによるクエリ
- 軽量なフォーマット処理（表示用途）

---

### 禁止される例

- 金額計算などの業務ロジック
- 状態遷移の判断
- 複雑な条件分岐

---

## 7. 設計判断基準

実装前に必ず判断する：

### 7-1. Q1: 複雑な業務ルールがあるか？

→ domains

### 7-2. Q2: 複雑な業務ルールはなく、処理フロー中心か？

→ features

### 7-3. Q3: 単純なCRUD処理や、外部サービスなどの共通処理か？

→ resource

### 7-4. Q4: 各レイヤーで共通利用するものか？

→ shared

---

## 8. エージェントルール

- 実装前に必ず配置先を決める
- controllerから設計を始めない
- domains または features または resource から設計を始める
- 判断に迷った場合は `boundaries.md` を参照すること

---

## 9. 禁止事項

- controllersへのロジック追加
- model肥大化
- domainsでの直接のActiveRecord使用
- featuresの無制限増殖
- ルールを無視した直書き実装
