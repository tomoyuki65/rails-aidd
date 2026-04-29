# Rails実装のルール定義

モジュラーモノリス + ドメイン駆動設計（DDD）を併用する

## 1. 目的

本ドキュメントはRailsにおける実装ルールを定義する。

アーキテクチャ判断は `architecture.md` と `boundaries.md` に従い、
本書は「Railsコードの書き方・制約」に特化する。

---

## 2. 基本原則

### 2-1. レイヤーの定義

- domainは業務ルール（状態と制約）を定義する
- use_caseは業務ルールを順番に実行する手順であり判断は持たない
- featuresはdomain化されていない一時的な手順の仮置きである

### 2-2. controllersは薄くする

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
- use_caseの組み立て（newや依存解決）

---

### 2-3. modelsは永続化専用

- ActiveRecordはデータ層として扱う
- ビジネスロジック禁止
- scope・validation・associationのみ許可

#### 禁止

- 業務ルール
- 計算ロジック
- ドメイン判断

---

### 2-4. domainsは純粋な業務ロジック

- ActiveRecordに依存しない
- 不変条件を保証する
- 副作用を外に出す

#### 特徴

- エンティティ
- 値オブジェクト
- ドメインサービス

#### ドメインサービスの使用条件

- ドメインサービスは以下の場合にのみ使用する：
  - 複数エンティティにまたがる業務ルール
  - 特定のエンティティに帰属しないロジック
- 単一エンティティに閉じるロジックはエンティティに実装すること

---

### 2-5. domainsのuse_caseはアプリケーション制御

- トランザクション境界を持つ
- domainを組み合わせる
- repository経由でデータアクセス
- 外部副作用（メール送信・通知・ログなど）はuse_caseまたは専用サービスで扱う
- 外部副作用はドメインロジックの成功後に実行する
- 副作用は「トランザクション成功後」にのみ実行する
- トランザクション内で副作用を実行してはならない
- 副作用の実行方法は以下に限定する：
  - トランザクション終了後に明示的に呼び出す（after_commit相当の仕組みを含む）
  - 非同期ジョブ（ActiveJob等）に委譲
- 同期的な外部I/Oは原則禁止とする
  - ただし以下の場合のみ例外として許可する：
    - ユーザーのリクエストに対して即時結果が必要な場合
    - 外部APIの結果が業務結果に直結する場合
  - 例外を許可する場合は「なぜ非同期にできないか」をコード上で明示すること
- use_caseは外部から呼ばれる単一の業務コマンドを表現する
  - 1 use_case = 1 外部トリガー（API / UI操作 / バッチ / イベント）
  - 内部の処理構造（domain操作・永続化・副作用）は分割理由にしない
  - use_caseはそれらをすべて内包して実行する
  - 内部処理が複雑化し、再利用可能な業務ルールになった場合はdomainへ移行する
- 1リクエストで複数のuse_caseを連続実行してはならない
- use_caseのネスト呼び出しは禁止する

#### 役割

- use_caseは「調整役」に徹し、業務ルールの主体を持たない
  - 業務ルールはdomainに記述する
  - 外部副作用は専用サービスに委譲する
  - use_caseはそれらを順序制御するのみとする
  - 条件分岐は「ドメインの結果に基づく分岐」のみ許可する
  - use_caseは「アプリケーション固有の判断（権限・フロー制御）」を持ってよい
    - ただし、業務ルールに関わる判断はdomainに委譲すること

#### 禁止

- UIロジック
- ActiveRecord直接操作（原則）

---

### 2-6. featuresはドメインに属さないUI/API補助レイヤー

featuresはdomain/use_caseに属さない軽量なアプリケーション補助レイヤーである。  
ActiveRecord（models）には直接アクセス可能であり、データ取得・整形・軽量な処理フローを担当する。  

#### 役割

- ドメインに属さない「表現・データ変換専用の手続き層」
- UI/APIのための最終出力を組み立てるレイヤー

#### 許可される処理

- データ構造変換（DTO / JSON / Hash）
- 表示用フォーマット変換（文字列・UI向け整形）
- データの正規化（nil / 空値 / キー構造の統一）
- 複数の変換処理の直列実行（※業務判断を含まないもののみ）

#### 条件分岐の扱い

- OK：構造・表示変換のための分岐（業務的な結果を変えないもの）
  - nilチェック
  - フォーマット切替
  - 表示形式の切替
  - UI都合の軽微な出力分岐
  - フラグに応じた表示・整形の切替

- NG：業務的な意思決定
  - 状態遷移（例：paid → refunded の決定）
  - 可否判断（Yes/No）
  - 状態の業務的解釈（statusの意味付け）
  - 権限・金額・期間などの判断

#### 禁止事項

- 業務的な意思決定（状態解釈・可否判断・Yes/No判断）
- domainロジックの再実装
- domain/use_caseへの依存
- コア業務ルールの実装
- ドメイン不変条件への関与

#### ActiveRecord

- 利用可能（取得・整形・軽量な加工のみ）
- ActiveRecordの結果に対する業務的な意味付けは禁止

#### domains移行基準

以下に該当した場合、featuresからdomainsへ即時移行する：

- 条件分岐が業務的な意味を持ち始めた場合
- 状態（status・state・flag）の解釈を含む場合
- 複数の業務概念が登場する場合
- ルール変更が仕様変更に直結する場合
- 処理が再利用可能な業務ルールになった場合

---

### 2-7. resourcesはCRUD専用

- 単純なデータ操作のみ
- ビジネス判断を持たない
- マスタ・設定・ログなど

---

## 3. 依存ルール

### 基本方針

依存は一方向のみ（上位 → 下位）

---

### 3-1. controllers

- controllers → container
  - controllerはcontainer経由でuse_caseを取得する
  - use_caseを直接newしてはいけない
  - DIが必要なfeaturesはcontainer経由で取得する
- controllers → features/[feature_name]/services
- controllers → resources

#### ルール

- controllerは業務判断を持たない
- HTTP入出力のみに責務を限定する
- domainsはcontainer経由で呼び出す
- featuresは原則として直接呼び出す
- controllerはfeaturesの選択ロジックを持たない（エンドポイント設計時に固定する）
- resourcesは直接呼び出す
- 呼び出し先の選択はエンドポイント単位で固定する
- 業務ルールに関わる判断は禁止
- 表示・フォーマット・入力バリエーションの分岐は許可

---

### 3-2. models

- models（ActiveRecordのモデルを集約） → DB永続化専用

---

### 3-3. domains（中核の業務領域）

#### domain/*

- domains/*/domain → 無依存（完全独立）
- repositories
  - repositoryは「ドメインモデルの永続化を抽象化するもの」とする
  - repositoryはドメインオブジェクトのみを入出力とする（ActiveRecordを返さない）
    - Query RepositoryはDTOまたは読み取り専用構造のみ返す（ActiveRecordは禁止）
    - DTOへの変換はuse_caseで行う
    - Command Repositoryはドメインオブジェクトを扱う
  - repositoryは集約単位でデータを扱うこと
    - 部分更新・部分取得は原則禁止
    - 必要な場合はQuery Repositoryとして別に定義する
    - 集約ルートのみをrepositoryの操作対象とする
    - 子エンティティ単体の永続化操作を公開してはならない
    - パフォーマンス上の理由で必要な場合は例外を許可する（理由必須）
  - domains/*/domain/repositories（interface）はインターフェース定義のみ
  - 実装はdomains/*/infrastructure/repositories（implementation）

#### use_cases

- domains/*/use_cases → domains/*/domain
- domains/*/use_cases → domains/*/domain/repositories（interface）
- 入出力ルール：
  - use_caseの入出力は明示的なDTO（データ構造）を定義する
  - controllerはDTOに変換してuse_caseに渡す
  - use_caseはDTOをdomainオブジェクト（エンティティ・値オブジェクト）に変換して扱う
  - domain層にはDTOを直接渡さない（必ずドメインオブジェクトに変換する）
  - use_caseの出力もDTOとして定義する
  - controllerはDTOをHTTPレスポンスに変換する

#### infrastructure

- リポジトリの実装を行う
- infrastructureは外部I/O（DB・API・メール・キャッシュ等）の実装を担う
- domains/*/infrastructure/repositories（implementation） → models
- コマンド・クエリ責務分離（CQRS）設計とし、command（書き込み）とquery（読み取り）に分ける

---

### 3-4. features（補完的な業務領域）

- features/*/services → models

#### ルール

- featuresは「ドメイン知識を増やさない」こと
- featuresはドメインオブジェクトを生成しない
- ドメインルールを再実装してはならない（重複禁止）
- featuresはdomainの代替ではない。
- domain化されていないロジックの一時置き場であり、業務判断を含む時点で即domain移行対象
- domainで表現できる概念をfeaturesに追加してはならない
- 単純な業務フローのみ扱う
  - 「単純」とは以下をすべて満たすもの：
    - 強い不変条件を持たない（軽微な条件分岐は許可）
      - ※「軽微な条件分岐」とは、業務的な意味変化を伴わないUI/データ整形上の分岐のみを指す
    - 複雑な状態遷移を持たない（単純なフラグ変更は許可）
    - 処理結果が入力に対して一意に決まる（分岐があっても業務判断ではない）
- 複雑化した場合はdomainsへ移行
- 複数のドメインルールや状態遷移を含む場合は必ずdomainsへ移行する
- featuresは原則として直接インスタンス化して利用する（DIしない）
- 以下のいずれかに該当する場合のみ、container経由で取得する：
  - 外部I/O（API・メール・ファイル等）に依存する
  - 実行結果をテスト時に差し替える必要がある
  - 複数の依存オブジェクトを持つ
- 上記の例外が発生した場合は「domainへ移行すべきサイン」として扱う
- 依存が増加した場合や業務ロジックが複雑化した場合は必ずdomainsへ移行する
- 条件分岐が「業務ルールの表現」になった場合はdomainへ移行する
- featuresに業務判断（状態解釈・可否判断・次処理の決定）が含まれた場合は即domainへ移行する（例外なし）
- featuresはdomainに存在する業務ルールの再実装を禁止する
- ※featuresにおける判断基準は 2-6（features定義）を優先する

#### 呼び出し・依存モデル（重要）

- featuresはcontrollerから直接呼び出される
- featuresはdomain/use_caseを含むすべてのドメインレイヤーに依存禁止（完全に孤立したレイヤー）
- featuresはActiveRecord（models）に直接アクセスしてよい
  - ActiveRecordは「取得・整形のためのデータアクセス」に限定し、状態解釈を伴う判断は禁止する
- featuresはHTTP入力またはcontrollerで整形されたデータのみを入力とする
- featuresはdomainオブジェクト・DTO・use_case出力構造を前提にしてはならない

---

### 3-5. resources（一般的な業務領域）

- resources → models

#### ルール

- 単純なCRUD処理（業務上の意味を持たないデータに限定する）
- ビジネスロジック禁止

---

### 3-6. shared（横断関心）

- shared → 全レイヤーから参照可能
- sharedは「技術的関心（共通ライブラリ・ユーティリティ）」のみ許可
- 業務ロジックの配置は禁止

---

### 3-7. container（DIコンテナ層）

- アプリケーションのcomposition rootとする
  - ※依存関係（use_case・repository・serviceなど）を最終的に組み立てる唯一の場所
- オブジェクトの生成・依存解決のみを担当する

#### 責務

- use_caseのインスタンス生成
- repository interfaceに対するimplementationの注入
- 外部サービス（APIクライアント等）の注入
- controllerにuse_caseを提供する（実行は行わない）
- controllerおよび「外部依存を持つオブジェクト」に対して依存解決済みインスタンスを提供する
  - （依存関係の解決のみであり、呼び出し順や処理フローには関与しない）

#### 依存

- container → domains/*/use_cases
- container → domains/*/infrastructure
- container → features/*/services（外部I/O依存またはテスト差し替えが必要なもののみ）
  - featuresのDIは原則行わない
    - ただし以下の場合のみcontainer管理対象とする：
      - 外部I/O（API・メール・ファイル・外部サービス）に依存する場合
        - ただしここでいう外部I/O依存とは「HTTP / SMTP / 外部SDKなどのネットワーク境界を持つもの」に限定する
        - DBアクセス（ActiveRecord）は外部I/Oとして扱わない
      - テスト時に差し替え（mock/stub）が必要な場合
      - 複数の依存オブジェクトを持つ場合
        - ここでいう「依存オブジェクト」とは外部境界（ネットワークI/O・外部サービス）のみを指す
        - 例：
          - HTTP API（外部サービス）
          - メール送信（SMTP / SendGrid）
          - 外部ストレージ（S3等）
          - 外部SDKクライアント

#### ルール

- 業務ロジック禁止
- containerは処理を「実行しない」
- 条件分岐は「依存解決のための切り替え」のみ許可
  - 例：環境ごとの実装切り替え（mock / 本番）
- orchestration禁止
  - ※orchestrationとは：
    業務処理の流れ（どの処理をどの順番で実行するか）を制御すること
  - ※複数use_caseの呼び出し順制御・条件分岐はuse_caseに記述すること

#### 責務の分離（重要）

- container：依存を組み立てるだけ（実行しない）
- use_case：業務処理の流れを実行する

---

### 3-8. 例外の責務（例外ハンドリング方針）

- domain：
  - 業務ルール違反を例外として表現する
  - 技術的例外（DBエラー等）は扱わない

- use_case：
  - domain例外を捕捉する
  - アプリケーションの結果（成功 / 失敗）に変換する
  - use_caseは例外を外部に送出しない
  - すべての結果は明示的な戻り値（DTOまたはResultオブジェクト）として返す
  - 戻り値は Success / Failure を持つResultオブジェクトに統一する
  - 予期しない技術例外はuse_caseで捕捉し、Failureとして扱うか、アプリケーション例外としてラップする

- controller：
  - use_caseの結果をHTTPレスポンスに変換する
  - 例外をそのまま外部に漏らさない

---

### 3-9. 全体制約

#### domainの絶対ルール

- domainはRailsに依存しない
- domainはActiveRecordを知らない
- domainは純粋なビジネスロジックのみ
- 外部副作用（メール送信・通知・ログ出力など）はdomainに記述しない

#### infrastructureルール

- infrastructure（repositories実装）はmodelsに依存する
- コマンド・クエリ責務分離（CQRS）設計とする

---

### 依存方向まとめ

#### 中核の業務領域

```
controller
  ↓
container
  ↓
domains/*/use_cases 
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
features/*/services/*
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
  - トランザクションはuse_caseの開始から終了までの全体を対象とする
  - use_case内でトランザクションを分割してはならない
- トランザクションはrepository操作をまたぐ単位で定義する
- repositoryはトランザクションを開始・終了してはならない
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
- 同一責務・類似処理のfeaturesの乱立
- domainへ移行すべきロジックのfeaturesへの滞留
- ルールを無視した直書き実装
