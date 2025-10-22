# Design Lab CMS API

高速で多用途なウェブサイトを構築・運用可能なCMSシステムのAPIサーバーです。

## プロジェクト構成

- **バックエンド**: Ruby on Rails 8 (API Mode)
- **データベース**: PostgreSQL
- **認証**: Devise + JWT
- **テスト**: RSpec

## 主要機能

### データモデル

1. **User** - ユーザー管理（認証）
2. **Article** - ブログ記事管理
3. **Page** - 固定ページ管理
4. **Medium** - メディアファイル管理
5. **Setting** - サイト全体設定

### API エンドポイント

#### 記事 (Articles)
- `GET /api/v1/articles` - 記事一覧取得
- `GET /api/v1/articles/:id` - 記事詳細取得
- `POST /api/v1/articles` - 記事作成（認証必要）
- `PUT /api/v1/articles/:id` - 記事更新（認証必要）
- `DELETE /api/v1/articles/:id` - 記事削除（認証必要）

#### 固定ページ (Pages)
- `GET /api/v1/pages` - ページ一覧取得
- `GET /api/v1/pages/:id` - ページ詳細取得
- `POST /api/v1/pages` - ページ作成（認証必要）
- `PUT /api/v1/pages/:id` - ページ更新（認証必要）
- `DELETE /api/v1/pages/:id` - ページ削除（認証必要）

#### メディア (Media)
- `GET /api/v1/media` - メディア一覧取得（認証必要）
- `GET /api/v1/media/:id` - メディア詳細取得（認証必要）
- `POST /api/v1/media` - メディア作成（認証必要）
- `PUT /api/v1/media/:id` - メディア更新（認証必要）
- `DELETE /api/v1/media/:id` - メディア削除（認証必要）

#### サイト設定 (Settings)
- `GET /api/v1/settings` - サイト設定取得
- `PUT /api/v1/settings` - サイト設定更新（認証必要）

## セットアップ

### 必要な環境
- Ruby 3.4.1
- Rails 8.0.2
- PostgreSQL

### インストールと起動

1. 依存関係のインストール:
```bash
bundle install
```

2. データベースのセットアップ:
```bash
rails db:create
rails db:migrate
```

3. サーバー起動:
```bash
rails server -p 3001
```

## CORS設定

フロントエンド（Next.js/Nuxt.js）との連携のため、以下のオリジンからのアクセスを許可:
- `localhost:3000`
- `127.0.0.1:3000`
- `localhost:3001`
- `127.0.0.1:3001`

## 今後の開発予定

1. JWT認証の実装
2. ファイルアップロード機能の実装
3. テストケースの充実
4. フロントエンドアプリケーションの開発
5. デプロイメント設定の最適化

## 開発者向け情報

### バージョン管理
このプロジェクトはGitで管理されています。
- **SourceTree連携**: 詳細は `SOURCETREE_GUIDE.md` を参照
- **リポジトリパス**: `/Users/mac-user/cms-lab/design-lab`

### テスト実行
```bash
bundle exec rspec
```

### コードチェック
```bash
bundle exec rubocop
```

### セキュリティチェック
```bash
bundle exec brakeman
```
