## IaaC サーバーレス開発環境構築
---
### 概要
ローカルにサーバレスアプリケーションの開発環境を構築する。
- 使用するツール
  - Vagrant
  - Terraform
  - localstack
- 構築するリソース
  - API Gateway
  - Lambda
  - DynamoDB
- 動作確認用のサンプルアプリケーション
  - ユーザーIDを指定して、取得・追加・削除を行うのみのWeb API
	- Pythonで作成
	- フレームワークはFastAPIを使用し、MangumによってLambdaのイベントをASGIインターフェースに対応させる
	- リソース
		- /user
			- GET ・・・ ユーザーID一覧の取得
			- POST ・・・ 新規ユーザーIDの登録
			- DELETE ・・・ 指定したユーザーIDを削除
  - ユーザーIDの操作・表示を行うためのWeb UI
	- Reactで作成
	- 構成要素
		- ユーザーIDを入力する入力欄
		- 入力したユーザーIDを追加するADDボタン
		- 入力したユーザーIDを削除するDELETEボタン
---
### フォルダ構成
```
.
├── README.md
├── Vagrantfile
├── api
│   ├── Makefile
│   ├── Pipfile
│   ├── Pipfile.lock
│   ├── app.py
│   └── function
├── container
│   ├── Dockerfile
│   └── docker-compose.yaml
├── infra
│   ├── api
│   └── db
└── web
    ├── README.md
    ├── node_modules
    ├── package-lock.json
    ├── package.json
    ├── public
    └── src
```
---
### 使用方法
- 開発環境作成 & 起動 (VagrantのProvisioning, Triggerによって自動的にコンテナ起動・localstackリソース作成)

  > $ vagrant up

- 開発環境停止 (VagrantのTriggerによって自動的にコンテナ停止)

  > $ vagrant halt

- 開発環境破棄 (VagrantのTriggerによって自動的にコンテナ停止・localstackリソース削除)

  > $ vagrant destroy
---
### ポートフォワード
- Host:3000 <-> VM:3000 <-> react-app-starter:3000
- Host4566 <-> VM:4566 <-> localstack:4566
---
### ファイル同期
- Host:./api <-> VM:/opt/api
- Host:./web <-> VM:/opt/web <-> react-app-starter:/opt/web
- Host:./infra <-> VM:/opt/infra
- Host:./container <-> VM:/opt/container
---
### vagrant up, halt, destroy時の主な処理
- vagrant up
  - ※ 初回起動時のみの処理 (Provisioning)
    - ツールのインストール (make, jq, zip, docker-compose, terraform)
    - 一時的にlocalstackコンテナを作成、terraformによりDBリソースのみ作成
  - vagrant up時、毎回行われる処理 (Trigger)
    - APIのコードをLambdaアップロード用にzip圧縮
    - docker-composeによりコンテナ群の立ち上げ
    - terraformにより、Lambda, API Gatewayのリソース作成
      ※ localstackにより永続化されないため、毎回作成する必要あり
      ※ zip圧縮したAPIのコードは、terraformでのリソース作成と同時にLambda Functionにアップロード
    - 新しいAPI GatewayのIDをreact-app-starterの環境変数に埋め込むため、コンテナを再起動
- vagrant halt
  - コンテナを停止
  - terraformによって作成された、Lambda, API Gatewayの状態ファイルを削除
- vagrant destroy
  - コンテナを停止
  - terraformによって作成された、Lambda, API Gatewayの状態ファイルを削除
  - terraformによって作成された、DynamoDBの状態ファイルを削除
  - localstackの永続化ファイルを削除 (DB内のデータも削除される)
---
### 注意点
- Reactによるフロントエンド開発時
  - APIへのアクセス時、環境変数 REACT_APP_API_ENDPOINT を使用してURLを指定する必要あり
    ※ localstackの仕様上、API Gatewayは永続化されないため毎度生成する必要があり、エンドポイントが変わるため
  ※ 例: let url = `${process.env.REACT_APP_API_ENDPOINT}/users` (web/src/App.js 16行目に記載)
  
- ホストマシンから、terraformによってリソースを変更・追加・削除する場合
  - `terraform init -reconfigure`を実行する必要あり (初回のみ)
    ※ terraformの仕様上、初回の`terraform init`を行ったパス (今回だとVM内のパス)と違う場所で実行しようとした場合、
    　エラーが発生する。`terraform init -reconfigure`によって構成ファイルを再構築することで実行可能となる。

