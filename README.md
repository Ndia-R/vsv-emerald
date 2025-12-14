# vsv-emerald

VPS 2台構成のうち **VPS2（Webアプリケーション本体）** を管理するデプロイメント設定リポジトリです。Docker Composeを用いてマイクロサービス群を統合管理し、Nginxリバースプロキシ経由でサービスを提供します。

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

**vsv-emerald** は、以下の特徴を持つエンタープライズグレードのWebアプリケーションデプロイメント基盤です：

- **マイクロサービスアーキテクチャ**: フロントエンド、BFF、バックエンドAPIの完全分離
- **集中認証管理**: Keycloak（VPS1）によるOAuth2/OIDC認証
- **セキュアなBFFパターン**: トークンをクライアントに露出させない設計
- **マルチアプリケーション対応**: 最大5つのバックエンドサービスまで拡張可能
- **本番対応インフラ**: SSL/TLS、ヘルスチェック、依存関係管理完備

## システムアーキテクチャ

### VPS 2台構成

| サーバー | ホスト名 | 主な役割 |
|---------|---------|---------|
| **VPS1** | `vsv-crystal.skygroup.local` | 認証プロバイダー + Dockerレジストリ |
| **VPS2** | `vsv-emerald.skygroup.local` | Webアプリケーション本体（このプロジェクト） |

### VPS2コンポーネント

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

| サービス名 | イメージ | ポート | 役割 |
|-----------|---------|--------|------|
| `nginx-edge` | nginx:alpine | 80, 443 | HTTPSリバースプロキシ |
| `my-books-frontend` | Registry/my-books-frontend | 80 | フロントエンド（React + Vite） |
| `api-gateway-bff` | Registry/api-gateway-bff | 8080 | 認証ゲートウェイ（Spring Boot） |
| `my-books-api` | Registry/my-books-api | 8080 | リソースサーバー（Spring Boot） |
| `my-books-db` | mysql:8.0 | 3306 | アプリケーションDB |
| `redis` | redis:8.2 | 6379 | セッション/トークン管理 |

詳細なアーキテクチャ図とフローについては、[system-architecture-overview-vps2.md](system-architecture-overview-vps2.md) を参照してください。

## 前提条件

### VPS1（認証・レジストリサーバー）

以下のサービスが稼働していること：

- Keycloak（OAuth2/OIDC認証プロバイダー）
- Docker Registry（プライベートイメージレジストリ）
- Nginx（HTTPSリバースプロキシ）

### VPS2（このプロジェクト）

- Docker Engine 20.10以上
- Docker Compose 2.0以上
- SSL証明書（本番環境用）
- VPS1への接続性（Keycloak、Registry）

### アプリケーションイメージ

以下のイメージがVPS1 Registryに登録されていること：

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

### 3. SSL証明書の配置

#### 本番環境

本番環境用のSSL証明書を`nginx/ssl/`に配置：

```bash
# 既存のプレースホルダーファイルを削除
rm nginx/ssl/本番環境用のものにする_*

# 本番証明書をコピー
cp /path/to/your/certificate.crt nginx/ssl/vsv-emerald.skygroup.local.pem
cp /path/to/your/private-key.key nginx/ssl/vsv-emerald.skygroup.local-key.pem

# パーミッション設定
chmod 644 nginx/ssl/vsv-emerald.skygroup.local.pem
chmod 600 nginx/ssl/vsv-emerald.skygroup.local-key.pem
```

#### 開発環境

開発環境では`mkcert`で生成した証明書を使用（既に配置済み）：

```bash
ls nginx-dev/ssl/
# localhost.pem
# localhost-key.pem
```

### 4. Docker Registryへのログイン

VPS1のプライベートレジストリにログイン：

```bash
docker login vsv-crystal.skygroup.local
```

## デプロイ手順

### 本番環境へのデプロイ

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

### サービスの再起動

```bash
# 全サービス再起動
docker compose -f docker-compose.prod.yml restart

# 特定のサービスのみ再起動
docker compose -f docker-compose.prod.yml restart api-gateway-bff
```

### サービスの停止

```bash
# 停止（コンテナ削除）
docker compose -f docker-compose.prod.yml down

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

### Docker Registry設定

| 変数名 | 説明 | 設定例 |
|--------|------|--------|
| `REGISTRY_HOSTNAME` | VPS1のRegistryホスト名 | `vsv-crystal.skygroup.local` |
| `API_TAG` | APIイメージのタグ | `v1.0.0` |
| `BFF_TAG` | BFFイメージのタグ | `v1.0.0` |
| `FRONTEND_TAG` | フロントエンドイメージのタグ | `v1.0.0` |

### VPS設定

| 変数名 | 説明 | 設定例 |
|--------|------|--------|
| `VPS_HOSTNAME` | VPS2のホスト名 | `vsv-emerald.skygroup.local` |

### データベース設定

| 変数名 | 説明 | 設定例 |
|--------|------|--------|
| `DB_ROOT_PASSWORD` | MySQLのrootパスワード | `your-secure-root-password` |
| `DB_NAME` | アプリケーションDB名 | `my_books_db` |
| `DB_USER` | アプリケーションDBユーザー | `app_user` |
| `DB_PASSWORD` | アプリケーションDBパスワード | `your-secure-db-password` |

### OAuth2/OIDC設定

| 変数名 | 説明 | 設定例 |
|--------|------|--------|
| `KEYCLOAK_REALM` | Keycloakレルム名 | `test-user-realm` |
| `IDP_CLIENT_ID` | OAuth2クライアントID | `my-books-client` |
| `IDP_CLIENT_SECRET` | OAuth2クライアントシークレット | `your-client-secret` |
| `IDP_ISSUER_URI` | Keycloakのissuer URI | `https://vsv-crystal.skygroup.local/auth/realms/test-realm` |

### バックエンドサービス設定

| 変数名 | 説明 | 設定例 |
|--------|------|--------|
| `SERVICE_01_URL` | バックエンドAPIのURL | `http://my-books-api:8080` |
| `SERVICE_01_PATH_PREFIX` | APIのパスプレフィックス | `/my-books` |

複数のバックエンドサービスを追加する場合は、`SERVICE_02_URL`から`SERVICE_05_URL`まで設定可能です。

### ログ設定

| 変数名 | 説明 | 設定値 |
|--------|------|--------|
| `LOG_LEVEL` | ログレベル | `INFO`（本番）/ `DEBUG`（開発） |

## プロジェクト構成

```
vsv-emerald/
├── README.md                              # このファイル
├── system-architecture-overview-vps2.md   # 詳細アーキテクチャドキュメント
├── .env                                   # 環境変数（Git管理外）
├── .env.example                           # 環境変数テンプレート
├── .gitignore                             # Git除外設定
├── docker-compose.yml                     # 開発用設定（Git管理外）
├── docker-compose.dev.yml                 # 開発環境テンプレート
├── docker-compose.prod.yml                # 本番環境設定
├── nginx/                                 # 本番環境Nginx設定
│   ├── nginx.conf                         # Nginxメイン設定
│   ├── conf.d/
│   │   └── default.conf                   # サーバーブロック設定
│   └── ssl/
│       ├── vsv-emerald.skygroup.local.pem     # 本番SSL証明書
│       └── vsv-emerald.skygroup.local-key.pem # 本番SSL秘密鍵
└── nginx-dev/                             # 開発環境Nginx設定
    ├── nginx.conf                         # 開発用Nginxメイン設定
    ├── conf.d/
    │   └── default.conf                   # 開発用サーバーブロック
    └── ssl/
        ├── localhost.pem                  # 開発環境SSL証明書
        └── localhost-key.pem              # 開発環境SSL秘密鍵
```

## 開発環境

### 開発環境でのNginxのみ起動

開発時は、フロントエンド・BFF・APIはローカルで個別に起動し、Nginxのみコンテナで起動する構成が可能です。

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
- フロントエンド: `http://localhost:5173`（Vite開発サーバー）
- BFF: `http://localhost:8081`（Spring Boot）
- API: `http://localhost:8080`（Spring Boot）

上記サービスをローカルで起動し、Nginxが`https://localhost`でリバースプロキシとして機能します。

### 各コンポーネントの開発

各コンポーネントの開発手順については、それぞれのプロジェクトリポジトリを参照してください：

- **my-books-frontend**: React + Viteフロントエンド
- **api-gateway-bff**: Spring Boot認証ゲートウェイ
- **my-books-api**: Spring Bootリソースサーバー

## トラブルシューティング

### サービスが起動しない

```bash
# ログを確認
docker compose -f docker-compose.prod.yml logs <service-name>

# ヘルスチェック状態を確認
docker compose -f docker-compose.prod.yml ps

# コンテナ内部でヘルスチェックを手動実行
docker compose -f docker-compose.prod.yml exec my-books-api curl -f http://localhost:8080/actuator/health
```

### データベース接続エラー

```bash
# DBコンテナの状態確認
docker compose -f docker-compose.prod.yml logs my-books-db

# DBへ接続確認
docker compose -f docker-compose.prod.yml exec my-books-db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME}
```

### Keycloak認証エラー

1. VPS1のKeycloakが起動しているか確認
2. `.env`の`IDP_ISSUER_URI`が正しいか確認
3. Keycloakのクライアント設定を確認：
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

### SSL証明書エラー

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

# start_periodを延長してみる（docker-compose.prod.ymlを編集）
```

## ライセンス

プロジェクトのライセンスについては、プロジェクト管理者にお問い合わせください。

## サポート

問題が発生した場合は、以下を確認してください：

1. [system-architecture-overview-vps2.md](system-architecture-overview-vps2.md) - 詳細なアーキテクチャドキュメント
2. 各コンポーネントのログ
3. VPS1（vsv-crystal）の稼働状態

さらなるサポートが必要な場合は、プロジェクト管理者にお問い合わせください。
