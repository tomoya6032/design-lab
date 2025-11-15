# Design Lab CMS - Heroku デプロイ & AWS S3 設定ガイド

## 前提条件
- Herokuアカウントが作成済み
- Heroku CLIがインストール済み
- AWS アカウントが作成済み
- Git リポジトリが準備済み

## 1. AWS S3 設定

### 1.1 S3バケット作成
1. AWS Management Console (https://console.aws.amazon.com/) にログイン
2. S3サービスに移動
3. 「バケットを作成」をクリック
4. 設定項目：
   - バケット名: `design-lab-cms-production` (ユニークな名前に変更)
   - リージョン: `アジアパシフィック (東京) ap-northeast-1`
   - パブリックアクセス: **「パブリックアクセスをすべてブロック」のチェックを外す**

### 1.2 バケットポリシー設定
バケット作成後、「アクセス許可」タブ → 「バケットポリシー」で以下を設定：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::design-lab-cms-production/*"
        }
    ]
}
```

### 1.3 IAMユーザー作成
1. IAMサービスに移動
2. 「ユーザー」 → 「ユーザーを追加」
3. 設定項目：
   - ユーザー名: `design-lab-s3-user`
   - アクセスタイプ: プログラムによるアクセス
   - 権限: `AmazonS3FullAccess` をアタッチ
4. **Access Key ID と Secret Access Key をメモ**

## 2. Rails Credentials 設定

```bash
# credentials.yml.enc を編集
EDITOR=nano bin/rails credentials:edit
```

以下の内容を追加：

```yaml
aws:
  access_key_id: YOUR_ACCESS_KEY_ID
  secret_access_key: YOUR_SECRET_ACCESS_KEY
  region: ap-northeast-1
  bucket: design-lab-cms-production
```

## 3. Herokuアプリ作成

```bash
# Herokuにログイン
heroku login

# Herokuアプリを作成
heroku create design-lab-cms

# PostgreSQLアドオンを追加
heroku addons:create heroku-postgresql:essential-0

# Rails master keyを環境変数に設定
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# 環境変数を設定
heroku config:set RAILS_ENV=production
heroku config:set RACK_ENV=production
```

## 4. デプロイ実行

```bash
# Gitにcommit
git add .
git commit -m "Setup for Heroku deployment and S3 integration"

# Herokuにデプロイ
git push heroku main

# データベースをマイグレーション
heroku run rails db:migrate

# データベースにシードデータを投入（必要に応じて）
heroku run rails db:seed

# アプリを開く
heroku open
```

## 5. 管理者ユーザー作成

```bash
# Heroku consoleで管理者ユーザーを作成
heroku run rails console

# consoleで実行
User.create!(
  email: 'admin@example.com',
  password: 'secure_password',
  password_confirmation: 'secure_password'
)
```

## 6. 確認事項

### 6.1 動作確認
- [ ] サイトが正常に表示される
- [ ] 管理画面にログインできる
- [ ] 画像アップロードが動作する（S3に保存される）
- [ ] 記事作成・編集が動作する
- [ ] 求人応募機能が動作する

### 6.2 セキュリティ確認
- [ ] HTTPS接続が有効
- [ ] 管理画面のログイン保護
- [ ] S3バケットの適切な権限設定

## 7. よくあるトラブルシューティング

### デプロイエラー
```bash
# ログを確認
heroku logs --tail

# アプリの状態を確認
heroku ps
```

### データベースエラー
```bash
# データベースをリセット（注意：全データ削除）
heroku pg:reset DATABASE_URL
heroku run rails db:migrate
heroku run rails db:seed
```

### 環境変数の確認
```bash
# 設定された環境変数を確認
heroku config
```

## 8. カスタムドメイン設定（オプション）

```bash
# カスタムドメインを追加
heroku domains:add www.yourdomain.com

# SSL証明書を有効化
heroku certs:auto:enable
```

## 注意事項
- master.key は絶対にGitにcommitしない
- AWSのアクセスキーは安全に管理する
- 本番環境では強固なパスワードを使用する
- 定期的なバックアップを推奨