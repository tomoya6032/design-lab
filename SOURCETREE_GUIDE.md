# SourceTreeでの開発ガイド

## プロジェクトをSourceTreeで開く

### 方法1: SourceTreeからリポジトリを追加
1. SourceTreeを起動
2. 「新規」→「ローカルリポジトリを追加」を選択
3. パスに `/Users/mac-user/cms-lab/design-lab` を指定
4. 「追加」をクリック

### 方法2: Finderから直接開く
1. Finderで `/Users/mac-user/cms-lab/design-lab` フォルダを開く
2. フォルダをSourceTreeのアイコンにドラッグ&ドロップ

## 開発フロー

### 1. 日常的な開発作業
- **変更の確認**: SourceTreeの「作業コピー」タブで変更されたファイルを確認
- **ステージング**: 変更をコミットに含めるファイルを選択してステージング
- **コミット**: 意味のあるコミットメッセージを書いてコミット

### 2. おすすめのコミットメッセージ形式
```
種類: 簡潔な変更内容

詳細な説明（必要に応じて）

例:
feat: 記事投稿機能を追加
fix: ユーザー認証のバグを修正
style: 管理画面のUIを改善
docs: README.mdを更新
```

### 3. ブランチ戦略
```
main         本番環境用（安定版）
├── develop  開発統合用ブランチ
├── feature/記事管理機能
├── feature/ユーザー管理機能
└── hotfix/緊急修正
```

## 重要なファイルとディレクトリ

### Gitで管理されるファイル
- `app/` - アプリケーションのメインコード
- `config/` - 設定ファイル
- `db/` - データベース関連
- `spec/` - テストファイル
- `Gemfile` - 依存関係
- `README.md` - プロジェクト説明

### Gitで無視されるファイル（.gitignoreに記載）
- `log/` - ログファイル
- `tmp/` - 一時ファイル
- `storage/` - アップロードファイル
- `.DS_Store` - macOSシステムファイル
- `/config/master.key` - 機密情報

## SourceTreeでの便利な機能

### 1. 変更の差分確認
- ファイルを選択して差分ビューで変更内容を確認
- 行単位でのステージングが可能

### 2. ブランチ管理
- 「ブランチ」右クリックで新しいブランチを作成
- ブランチの切り替えとマージが簡単

### 3. リモートリポジトリ（今後の設定）
```bash
# GitHubやGitLabにリポジトリを作成後
git remote add origin https://github.com/username/design-lab-cms.git
git push -u origin main
```

## 開発時の注意点

### 1. コミット前の確認事項
- [ ] テストが通ることを確認
- [ ] 不要なファイル（ログ、一時ファイル）がコミットに含まれていない
- [ ] 機密情報（パスワード、APIキー）がコミットに含まれていない

### 2. 定期的な作業
- 定期的にコミットを作成（機能単位）
- 意味のあるコミットメッセージを記入
- 大きな変更の前にブランチを作成

### 3. 緊急時のコマンド
```bash
# 作業を一時的に退避
git stash

# 退避した作業を復元
git stash pop

# 前のコミットに戻す（注意して使用）
git reset --hard HEAD~1
```

## プロジェクト固有の情報

### データベース
- PostgreSQL使用
- 開発環境では `design_lab_development` データベース

### サーバー起動
```bash
cd /Users/mac-user/cms-lab/design-lab
rails server
```

### テスト実行
```bash
cd /Users/mac-user/cms-lab/design-lab
bundle exec rspec
```

このガイドを参考に、SourceTreeを使って効率的にDesign Lab CMSの開発を進めてください。