# vsv-emerald

VPS 2 台構成のうち **VPS2（Web アプリケーション本体）** を管理するデプロイメント設定リポジトリです。Docker Compose を用いてマイクロサービス群を統合管理し、Nginx リバースプロキシ経由でサービスを提供します。

## 目次

- [概要](#概要)
- [システムアーキテクチャ](#システムアーキテクチャ)
- [前提条件](#前提条件)
- [セットアップ](#セットアップ)
- [デプロイ手順](#デプロイ手順)
- [環境変数設定](#環境変数設定)
- [プロジェクト構成](#プロジェクト構成)
- [開発環境](#開発環境)
- [トラブルシューティング](#トラブルシューティング)

## 概要

**vsv-emerald** は、以下の特徴を持つエンタープライズグレードの Web アプリケーションデプロイメント基盤です：

- **マイクロサービスアーキテクチャ**: フロントエンド、BFF、バックエンド API の完全分離
- **集中認証管理**: Keycloak（VPS1）による OAuth2/OIDC 認証
- **セキュアな BFF パターン**: トークンをクライアントに露出させない設計
- **マルチアプリケーション対応**: 最大 5 つのバックエンドサービスまで拡張可能
- **複数環境対応**: 本番環境、開発環境、VirtualBox VM 環境に対応
- **本番対応インフラ**: SSL/TLS、ヘルスチェック、依存関係管理完備

## システムアーキテクチャ

### VPS 2 台構成

| サーバー | ホスト名                     | 主な役割                                     |
| -------- | ---------------------------- | -------------------------------------------- |
| **VPS1** | `vsv-crystal.skygroup.local` | 認証プロバイダー + Docker レジストリ         |
| **VPS2** | `vsv-emerald.skygroup.local` | Web アプリケーション本体（このプロジェクト） |

### VPS2 コンポーネント

```
ユーザー (HTTPS)
    ↓
nginx-edge (リバースプロキシ)
    ├─ / → my-books-frontend (React SPA)
    └─ /api → api-gateway-bff (認証ゲートウェイ)
              ├─ VPS1 Keycloak (OIDC認証)
              ├─ Redis (トークン管理)
              └─ my-books-api (バックエンドAPI)
                   └─ my-books-db (MySQL)
```

### 起動するサービス

| サービス名          | イメージ                   | ポート  | 役割                            |
| ------------------- | -------------------------- | ------- | ------------------------------- |
| `nginx-edge`        | nginx:alpine               | 80, 443 | HTTPS リバースプロキシ          |
| `my-books-frontend` | Registry/my-books-frontend | 80      | フロントエンド（React + Vite）  |
| `api-gateway-bff`   | Registry/api-gateway-bff   | 8080    | 認証ゲートウェイ（Spring Boot） |
| `my-books-api`      | Registry/my-books-api      | 8080    | リソースサーバー（Spring Boot） |
| `my-books-db`       | mysql:8.0                  | 3306    | アプリケーション DB             |
| `redis`             | redis:8.2                  | 6379    | セッション/トークン管理         |

詳細なアーキテクチャ図とフローについては、[system-architecture-overview-vps2.md](system-architecture-overview-vps2.md) を参照してください。

## 前提条件

### VPS1（認証・レジストリサーバー）

以下のサービスが稼働していること：

- Keycloak（OAuth2/OIDC 認証プロバイダー）
- Docker Registry（プライベートイメージレジストリ）
- Nginx（HTTPS リバースプロキシ）

### VPS2（このプロジェクト）

- Docker Engine 20.10 以上
- Docker Compose 2.0 以上
- SSL 証明書（本番環境用）
- VPS1 への接続性（Keycloak、Registry）

### アプリケーションイメージ

以下のイメージが VPS1 Registry に登録されていること：

- `vsv-crystal.skygroup.local/my-books-frontend:v1.0.0`
- `vsv-crystal.skygroup.local/api-gateway-bff:v1.0.0`
- `vsv-crystal.skygroup.local/my-books-api:v1.0.0`

## セットアップ

### 1. リポジトリのクローン

```bash
git clone <repository-url>
cd vsv-emerald
```

### 2. 環境変数の設定

`.env.example`をコピーして`.env`を作成：

```bash
cp .env.example .env
```

`.env`ファイルを編集して、環境に応じた値を設定：

```bash
vi .env
```

主要な設定項目については、[環境変数設定](#環境変数設定)を参照してください。

### 3. SSL 証明書の配置

このプロジェクトは 3 つの環境に対応しており、それぞれ異なる SSL 証明書が必要です：

#### 本番環境

本番環境用の SSL 証明書を`nginx/ssl/`に配置：

```bash
# 本番証明書をコピー
cp /path/to/your/certificate.crt nginx/ssl/vsv-emerald.skygroup.local.pem
cp /path/to/your/private-key.key nginx/ssl/vsv-emerald.skygroup.local-key.pem

# パーミッション設定
chmod 644 nginx/ssl/vsv-emerald.skygroup.local.pem
chmod 600 nginx/ssl/vsv-emerald.skygroup.local-key.pem
```

#### VirtualBox VM 環境

VirtualBox VM 環境用の SSL 証明書を`nginx-vm/ssl/`に配置：

```bash
# mkcertで証明書を生成（初回のみ）
mkcert -install
mkcert -cert-file nginx-vm/ssl/vsv-emerald.skygroup.local.pem \
       -key-file nginx-vm/ssl/vsv-emerald.skygroup.local-key.pem \
       vsv-emerald.skygroup.local

# パーミッション設定
chmod 644 nginx-vm/ssl/vsv-emerald.skygroup.local.pem
chmod 600 nginx-vm/ssl/vsv-emerald.skygroup.local-key.pem
```

#### 開発環境（localhost）

開発環境では`mkcert`で生成した localhost 用証明書を使用（既に配置済み）：

```bash
ls nginx-dev/ssl/
# localhost.pem
# localhost-key.pem
```

### 4. Docker Registry へのログイン

VPS1 のプライベートレジストリにログイン：

```bash
docker login vsv-crystal.skygroup.local
```

## デプロイ手順

### 本番環境へのデプロイ

本番環境用の`docker-compose.prod.yml`を使用します：

```bash
# イメージのプル
docker compose -f docker-compose.prod.yml pull

# サービスの起動
docker compose -f docker-compose.prod.yml up -d

# 起動確認
docker compose -f docker-compose.prod.yml ps

# ログ確認
docker compose -f docker-compose.prod.yml logs -f
```

### VirtualBox VM 環境へのデプロイ

VirtualBox VM 環境用の`docker-compose.vm.yml`を使用します：

```bash
# イメージのプル
docker compose -f docker-compose.vm.yml pull

# サービスの起動
docker compose -f docker-compose.vm.yml up -d

# 起動確認
docker compose -f docker-compose.vm.yml ps

# ログ確認
docker compose -f docker-compose.vm.yml logs -f
```

### サービスの再起動

```bash
# 本番環境: 全サービス再起動
docker compose -f docker-compose.prod.yml restart

# VM環境: 全サービス再起動
docker compose -f docker-compose.vm.yml restart

# 特定のサービスのみ再起動
docker compose -f docker-compose.prod.yml restart api-gateway-bff
```

### サービスの停止

```bash
# 本番環境: 停止（コンテナ削除）
docker compose -f docker-compose.prod.yml down

# VM環境: 停止（コンテナ削除）
docker compose -f docker-compose.vm.yml down

# 停止 + ボリューム削除（データベースも削除）
docker compose -f docker-compose.prod.yml down -v
```

### デプロイの更新

新しいバージョンをデプロイする場合：

```bash
# .envファイルでイメージタグを更新
vi .env
# API_TAG=v1.0.1
# BFF_TAG=v1.0.1
# FRONTEND_TAG=v1.0.1

# 新しいイメージをプル
docker compose -f docker-compose.prod.yml pull

# サービスを再作成（ダウンタイムあり）
docker compose -f docker-compose.prod.yml up -d

# または、ローリングアップデート（サービス単位）
docker compose -f docker-compose.prod.yml up -d --no-deps my-books-api
docker compose -f docker-compose.prod.yml up -d --no-deps api-gateway-bff
docker compose -f docker-compose.prod.yml up -d --no-deps my-books-frontend
```

## 環境変数設定

`.env`ファイルで設定する主要な環境変数：

### Docker Registry 設定

| 変数名              | 説明                         | 設定例                       |
| ------------------- | ---------------------------- | ---------------------------- |
| `REGISTRY_HOSTNAME` | VPS1 の Registry ホスト名    | `vsv-crystal.skygroup.local` |
| `API_TAG`           | API イメージのタグ           | `v1.0.0`                     |
| `BFF_TAG`           | BFF イメージのタグ           | `v1.0.0`                     |
| `FRONTEND_TAG`      | フロントエンドイメージのタグ | `v1.0.0`                     |

### VPS 設定

| 変数名         | 説明            | 設定例                       |
| -------------- | --------------- | ---------------------------- |
| `VPS_HOSTNAME` | VPS2 のホスト名 | `vsv-emerald.skygroup.local` |

### データベース設定

| 変数名             | 説明                           | 設定例                      |
| ------------------ | ------------------------------ | --------------------------- |
| `DB_ROOT_PASSWORD` | MySQL の root パスワード       | `your-secure-root-password` |
| `DB_NAME`          | アプリケーション DB 名         | `my_books_db`               |
| `DB_USER`          | アプリケーション DB ユーザー   | `app_user`                  |
| `DB_PASSWORD`      | アプリケーション DB パスワード | `your-secure-db-password`   |

### OAuth2/OIDC 設定

| 変数名              | 説明                            | 設定例                                                      |
| ------------------- | ------------------------------- | ----------------------------------------------------------- |
| `KEYCLOAK_REALM`    | Keycloak レルム名               | `test-user-realm`                                           |
| `IDP_CLIENT_ID`     | OAuth2 クライアント ID          | `my-books-client`                                           |
| `IDP_CLIENT_SECRET` | OAuth2 クライアントシークレット | `your-client-secret`                                        |
| `IDP_ISSUER_URI`    | Keycloak の issuer URI          | `https://vsv-crystal.skygroup.local/auth/realms/test-realm` |

### バックエンドサービス設定

| 変数名                   | 説明                     | 設定例                     |
| ------------------------ | ------------------------ | -------------------------- |
| `SERVICE_01_URL`         | バックエンド API の URL  | `http://my-books-api:8080` |
| `SERVICE_01_PATH_PREFIX` | API のパスプレフィックス | `/my-books`                |

複数のバックエンドサービスを追加する場合は、`SERVICE_02_URL`から`SERVICE_05_URL`まで設定可能です。

### データベース詳細設定（オプション）

| 変数名                        | 説明                              | デフォルト値 |
| ----------------------------- | --------------------------------- | ------------ |
| `SPRING_JPA_SHOW_SQL`         | SQL クエリをログに出力            | `false`      |
| `SPRING_JPA_FORMAT_SQL`       | SQL クエリを整形して出力          | `false`      |
| `DATASOURCE_POOL_MAX_SIZE`    | DB コネクションプール最大サイズ   | `20`         |
| `DATASOURCE_POOL_MIN_IDLE`    | DB コネクションプール最小アイドル | `10`         |
| `DATASOURCE_CONNECTION_TIMEOUT` | DB 接続タイムアウト（ミリ秒）    | `30000`      |

### エラーレスポンス設定（オプション）

| 変数名                          | 説明                          | デフォルト値 |
| ------------------------------- | ----------------------------- | ------------ |
| `SERVER_ERROR_INCLUDE_MESSAGE`  | エラーレスポンスにメッセージ含める | `never`      |
| `SERVER_ERROR_INCLUDE_STACKTRACE` | エラーレスポンスにスタックトレース含める | `never`      |

### ログ設定

| 変数名      | 説明       | 設定値                          |
| ----------- | ---------- | ------------------------------- |
| `LOG_LEVEL` | ログレベル | `INFO`（本番）/ `DEBUG`（開発） |
| `LOGGING_LEVEL` | API のログレベル | `INFO`（本番）/ `DEBUG`（開発） |

## プロジェクト構成

```
vsv-emerald/
├── README.md                              # このファイル
├── system-architecture-overview-vps2.md   # 詳細アーキテクチャドキュメント
├── .env                                   # 環境変数（Git管理外）
├── .env.example                           # 環境変数テンプレート
├── .gitignore                             # Git除外設定
├── docker-compose.yml                     # 開発用設定（Git管理外）
├── docker-compose.dev.yml                 # 開発環境テンプレート（Nginxのみ）
├── docker-compose.prod.yml                # 本番環境設定
├── docker-compose.vm.yml                  # VirtualBox VM環境設定
├── db/                                    # データベース関連
│   ├── my.cnf                             # MySQL設定ファイル
│   └── my-books-backup-YYYYMMDD.sql       # データベースバックアップ
├── nginx/                                 # 本番環境Nginx設定
│   ├── nginx.conf                         # Nginxメイン設定
│   ├── conf.d/
│   │   └── default.conf                   # サーバーブロック設定
│   └── ssl/
│       └── 本番環境用の証明書を配置.txt   # 証明書配置ガイド
├── nginx-dev/                             # 開発環境Nginx設定（localhost用）
│   ├── nginx.conf                         # 開発用Nginxメイン設定
│   ├── conf.d/
│   │   └── default.conf                   # 開発用サーバーブロック
│   └── ssl/
│       ├── localhost.pem                  # 開発環境SSL証明書（mkcert）
│       └── localhost-key.pem              # 開発環境SSL秘密鍵（mkcert）
└── nginx-vm/                              # VirtualBox VM環境Nginx設定
    ├── nginx.conf                         # VM用Nginxメイン設定
    ├── conf.d/
    │   └── default.conf                   # VM用サーバーブロック
    └── ssl/
        ├── vsv-emerald.skygroup.local.pem     # VM環境SSL証明書（mkcert）
        └── vsv-emerald.skygroup.local-key.pem # VM環境SSL秘密鍵（mkcert）
```

## 開発環境

### 環境の種類

このプロジェクトは 3 つの環境をサポートしています：

| 環境         | Compose ファイル           | ホスト名                     | 用途                                     |
| ------------ | -------------------------- | ---------------------------- | ---------------------------------------- |
| **本番環境** | `docker-compose.prod.yml`  | `vsv-emerald.skygroup.local` | 本番VPSサーバー                          |
| **VM環境**   | `docker-compose.vm.yml`    | `vsv-emerald.skygroup.local` | VirtualBox仮想マシン（本番環境テスト用） |
| **開発環境** | `docker-compose.dev.yml`   | `localhost`                  | ローカル開発（Nginxのみ）                |

### 開発環境での Nginx のみ起動

開発時は、フロントエンド・BFF・API はローカルで個別に起動し、Nginx のみコンテナで起動する構成が可能です。

```bash
# docker-compose.dev.ymlをdocker-compose.ymlとしてコピー
cp docker-compose.dev.yml docker-compose.yml

# 外部ネットワーク作成
docker network create vsv-emerald-network

# Nginxのみ起動
docker compose up -d

# 確認
docker compose ps
```

この構成では：

- フロントエンド: `http://localhost:5173`（Vite 開発サーバー）
- BFF: `http://localhost:8081`（Spring Boot）
- API: `http://localhost:8080`（Spring Boot）

上記サービスをローカルで起動し、Nginx が`https://localhost`でリバースプロキシとして機能します。

### VirtualBox VM 環境での開発

本番環境に近い形でテストしたい場合は、VirtualBox VM 環境を使用します：

```bash
# VM環境の起動
docker compose -f docker-compose.vm.yml up -d

# 確認
docker compose -f docker-compose.vm.yml ps
```

この構成では、全てのサービス（フロントエンド、BFF、API、DB、Redis、Nginx）がコンテナとして起動します。

### 各コンポーネントの開発

各コンポーネントの開発手順については、それぞれのプロジェクトリポジトリを参照してください：

- **my-books-frontend**: React + Vite フロントエンド
- **api-gateway-bff**: Spring Boot 認証ゲートウェイ
- **my-books-api**: Spring Boot リソースサーバー

## トラブルシューティング

### サービスが起動しない

```bash
# ログを確認（適宜、-f オプションを使用）
docker compose -f docker-compose.prod.yml logs <service-name>  # 本番環境
docker compose -f docker-compose.vm.yml logs <service-name>    # VM環境

# ヘルスチェック状態を確認
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.vm.yml ps

# コンテナ内部でヘルスチェックを手動実行
docker compose -f docker-compose.prod.yml exec my-books-api curl -f http://localhost:8080/actuator/health
```

### データベース接続エラー

```bash
# DBコンテナの状態確認
docker compose -f docker-compose.prod.yml logs my-books-db

# DBへ接続確認
docker compose -f docker-compose.prod.yml exec my-books-db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME}

# DBバックアップからの復元（VM環境など）
docker compose -f docker-compose.vm.yml exec -i my-books-db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < db/my-books-backup-YYYYMMDD.sql
```

### Keycloak 認証エラー

1. VPS1 の Keycloak が起動しているか確認
2. `.env`の`IDP_ISSUER_URI`が正しいか確認
3. Keycloak のクライアント設定を確認：
   - Client ID: `IDP_CLIENT_ID`と一致
   - Client Secret: `IDP_CLIENT_SECRET`と一致
   - Redirect URIs: `https://${VPS_HOSTNAME}/bff/login/oauth2/code/idp`が登録されているか

### イメージがプルできない

```bash
# Registryへの接続確認
curl -k https://vsv-crystal.skygroup.local/v2/_catalog

# ログイン状態確認
docker login vsv-crystal.skygroup.local

# 証明書エラーの場合、VPS1のCA証明書をインストール
sudo cp /path/to/ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

### SSL 証明書エラー

```bash
# 証明書の有効期限確認
openssl x509 -in nginx/ssl/vsv-emerald.skygroup.local.pem -noout -dates

# 証明書とキーのペア確認
openssl x509 -in nginx/ssl/vsv-emerald.skygroup.local.pem -noout -modulus | openssl md5
openssl rsa -in nginx/ssl/vsv-emerald.skygroup.local-key.pem -noout -modulus | openssl md5
# 上記2つのハッシュ値が一致すること
```

### ヘルスチェックが失敗する

```bash
# 各サービスのヘルスチェックエンドポイントを直接確認
docker compose -f docker-compose.prod.yml exec my-books-api curl http://localhost:8080/actuator/health
docker compose -f docker-compose.prod.yml exec api-gateway-bff curl http://localhost:8080/actuator/health
docker compose -f docker-compose.prod.yml exec my-books-frontend curl http://localhost:80/

# start_periodを延長してみる（docker-compose.prod.ymlまたはdocker-compose.vm.ymlを編集）
```

### VirtualBox VM 環境での注意点

VM 環境で起動する場合は、以下の点に注意してください：

1. **ホスト名の設定**: ホストマシンの`/etc/hosts`に以下を追加
   ```
   192.168.56.XXX  vsv-emerald.skygroup.local
   ```

2. **SSL 証明書**: `nginx-vm/ssl/`に mkcert で生成した証明書を配置

3. **Keycloak への接続**: VM から VPS1（vsv-crystal）への接続を確認
   ```bash
   curl -k https://vsv-crystal.skygroup.local/auth/realms/test-realm/.well-known/openid-configuration
   ```

## ライセンス

プロジェクトのライセンスについては、プロジェクト管理者にお問い合わせください。

## サポート

問題が発生した場合は、以下を確認してください：

1. [system-architecture-overview-vps2.md](system-architecture-overview-vps2.md) - 詳細なアーキテクチャドキュメント
2. 各コンポーネントのログ
3. VPS1（vsv-crystal）の稼働状態

さらなるサポートが必要な場合は、プロジェクト管理者にお問い合わせください。
