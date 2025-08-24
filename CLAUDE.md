# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際のClaude Code (claude.ai/code) への指針を提供します。

## プロジェクト概要

これは「My Books」アプリケーション - 日本の書籍管理システムで、ユーザー認証、書籍カタログの閲覧、レビュー、お気に入り、ブックマーク機能をサポートしています。マルチバージョンAPIアーキテクチャで構築され、Nginxリバースプロキシを通してコンテンツを配信しています。

## アーキテクチャ

アプリケーションは以下のコンポーネントを持つコンテナ化されたマイクロサービスアーキテクチャに従っています：

### サービス
- **データベース**: MySQL 8.0 (`my-books-db`) 書籍データとスキーマがプリロード済み
- **APIサービス**: 並列実行される3つのバージョン化されたSpring Bootアプリケーション：
  - `my-books-api-v0` (port 8080)
  - `my-books-api-v1` (port 8080) 
  - `my-books-api-v2` (port 8080)
- **Webサーバー**: SSL終端を持つNginxリバースプロキシ (ports 80/443)

### 主要機能
- JWTトークン（アクセストークンとリフレッシュトークン）によるユーザー認証
- 画像、評価、レビュー、ジャンル付きの書籍カタログ
- ユーザーお気に入りとブックマークシステム
- 後方互換性のためのマルチバージョンAPIサポート
- WebP画像最適化を備えたSSL対応ウェブインターフェース
- 全サービスのヘルスチェック

## 開発コマンド

### アプリケーションの実行
```bash
# 全サービスを開始（事前に.envファイルの設定が必要）
docker-compose up -d

# ログを表示
docker-compose logs -f [service-name]

# 全サービスを停止
docker-compose down

# 特定サービスをリビルド
docker-compose build [service-name]
docker-compose up -d [service-name]
```

### データベース操作
```bash
# MySQLデータベースにアクセス
docker-compose exec my-books-db mysql -u root -p

# データベース初期化ログを表示
docker-compose logs my-books-db
```

### APIテスト
- API v0: サービス開始時に利用可能（最初に初期化）
- API v1: v0が正常になった後に開始
- API v2: v1が正常になった後に開始
- 各APIバージョンには独自のSwagger UI設定があります
- ヘルスエンドポイント: 各APIサービスの`/health`

## 環境設定

アプリケーションには以下の変数を含む`.env`ファイルが必要です：
- データベース接続設定（`DB_URL`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`）
- JWT設定（`JWT_SECRET`, `JWT_ACCESS_EXPIRATION`, `JWT_REFRESH_EXPIRATION`）
- 各サービス用のAPIバージョン設定（v0, v1, v2）
- 各バージョンのSwagger UI設定
- 各サービスのログレベル

## データベーススキーマ

MySQLデータベースには以下の主要エンティティが含まれます：
- `users` - ロール付きユーザーアカウント
- `books` - メタデータ、評価、人気度メトリクス付きの書籍カタログ
- `genres` - 書籍のカテゴリ分類
- `reviews` - ユーザー書籍レビュー
- `favorites` - ユーザーお気に入り書籍
- `bookmarks` - ユーザー読書進行状況追跡
- `book_chapters`と`book_chapter_page_contents` - 書籍コンテンツ構造

データベースはコンテナ起動時にCSVファイルからサンプルデータで初期化されます。

## ファイル構成

- `/api/my-books-api/v{0,1,2}/` - 各APIバージョン用のSpring Boot JARファイルとDockerfile
- `/db/my-books-db/` - データベース初期化スクリプト、スキーマ、サンプルデータ
- `/web/` - Nginx設定、SSL証明書、静的画像アセット
- `docker-compose.yml` - マルチサービスコンテナオーケストレーション
- `.env` - 環境変数（リポジトリには含まれません）

## 開発メモ

- 全サービスはAsia/Tokyoタイムゾーンを使用
- 画像は最適化のため元形式とWebP形式の両方で配信
- システムは順次ヘルス依存起動をサポート（DB → API v0 → v1 → v2 → Web）
- ローカル開発用SSL証明書が含まれています
- アプリケーションはMySQLデータ読み込み用にセキュアファイル権限を使用