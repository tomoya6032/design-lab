# Herokuデプロイメントガイド

## 前提条件

- Heroku CLIがインストールされていること
- AWS S3バケットが作成されていること
- AWS IAMユーザーにS3への適切な権限が設定されていること

## デプロイ手順

### 1. Herokuアプリの作成

```bash
# Herokuにログイン
heroku login

# アプリを作成
heroku create your-app-name

# または地域を指定
heroku create your-app-name --region us

# PostgreSQLアドオンを追加
heroku addons:create heroku-postgresql:essential-0
```

### 2. 環境変数の設定

```bash
# Rails master keyを設定
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# AWS設定
heroku config:set AWS_ACCESS_KEY_ID=your_access_key_id
heroku config:set AWS_SECRET_ACCESS_KEY=your_secret_access_key
heroku config:set AWS_REGION=ap-northeast-1
heroku config:set AWS_BUCKET=your-bucket-name

# その他の設定
heroku config:set RAILS_ENV=production
heroku config:set RAILS_MAX_THREADS=5
heroku config:set WEB_CONCURRENCY=2
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set RAILS_LOG_TO_STDOUT=true

# 日本時間を設定
heroku config:set TZ=Asia/Tokyo
```

### 3. デプロイ

```bash
# Gitリポジトリにコミット
git add .
git commit -m "Add Heroku configuration"

# Herokuにデプロイ
git push heroku main

# または developmentブランチからデプロイする場合
git push heroku development:main
```

### 4. データベースの初期化

```bash
# マイグレーション実行
heroku run rails db:migrate

# シードデータの投入（必要に応じて）
heroku run rails db:seed

# 管理者ユーザーの作成（必要に応じて）
heroku run rails console
# User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
```

### 5. ログの確認

```bash
# アプリケーションログを確認
heroku logs --tail

# 特定のプロセスのログを確認
heroku logs --source app --tail
```

## トラブルシューティング

### よくある問題と解決方法

1. **Rails Master Key のエラー**
   ```bash
   heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
   ```

2. **アセットの問題**
   ```bash
   heroku config:set RAILS_SERVE_STATIC_FILES=true
   ```

3. **データベース接続エラー**
   ```bash
   # データベースの状態を確認
   heroku pg:info
   
   # データベースをリセット（注意: データが消えます）
   heroku pg:reset DATABASE_URL
   heroku run rails db:migrate
   ```

4. **S3接続エラー**
   - AWS認証情報が正しく設定されているか確認
   - S3バケットのCORS設定を確認

### 便利なコマンド

```bash
# アプリの状態確認
heroku ps

# 設定変数の確認
heroku config

# データベースの確認
heroku pg:info

# Rails consoleの起動
heroku run rails console

# 一時的なbashセッション
heroku run bash

# アプリのURL確認
heroku info
```

## 本番環境での注意事項

1. **セキュリティ**
   - 定期的にRails master keyを更新
   - AWS認証情報の定期的な更新
   - HTTPS通信の確認

2. **パフォーマンス**
   - 適切なプラン（dyno）の選択
   - データベースプランの監視
   - CDNの導入検討

3. **モニタリング**
   - ログの定期的な確認
   - エラー追跡サービスの導入検討
   - パフォーマンス監視の設定

## 自動デプロイの設定

GitHub Actionsを使用した自動デプロイの設定例は、`.github/workflows/deploy.yml`を参照してください。