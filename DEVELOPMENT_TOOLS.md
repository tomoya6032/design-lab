# 開発ツール使い方ガイド

## 🚀 追加された開発用Gem一覧

### エラー・デバッグツール

#### Better Errors（美しいエラー画面）
- **機能**: エラー画面を見やすく、インタラクティブに表示
- **使い方**: 自動的に動作、エラー発生時に美しいエラー画面が表示される
- **特徴**: 
  - スタックトレースが見やすい
  - 変数の中身を確認可能
  - ブラウザでREPL（コンソール）が使える

#### Pry（強力なデバッガー）
- **機能**: `rails console`の置き換え、ブレークポイント設定
- **使い方**:
  ```bash
  # コンソール起動
  rails console
  
  # コード内にブレークポイント設定
  binding.pry
  ```
- **コマンド**:
  - `ls` - オブジェクトのメソッド一覧
  - `show-method メソッド名` - メソッドのソース表示
  - `cd オブジェクト` - オブジェクトのコンテキストに移動

### パフォーマンス・品質ツール

#### Bullet（N+1クエリ検出）
- **機能**: データベースクエリの問題を検出・警告
- **設定**: 自動的に動作、ブラウザとログに警告表示
- **警告例**:
  - N+1クエリ
  - 不要なクエリ
  - カウンタキャッシュ推奨

#### Awesome Print（美しい出力）
- **機能**: オブジェクトを見やすく出力
- **使い方**:
  ```ruby
  # 通常のp
  p user
  
  # awesome_print
  ap user
  ```

### テストツール

#### Factory Bot（テストデータ生成）
- **機能**: テスト用のダミーデータを簡単生成
- **使い方**:
  ```ruby
  # ファクトリー定義例（spec/factories/users.rb）
  FactoryBot.define do
    factory :user do
      email { Faker::Internet.email }
      password { "password123" }
    end
  end
  
  # テストで使用
  user = create(:user)
  ```

#### Shoulda Matchers（RSpec拡張）
- **機能**: Railsに特化したRSpecマッチャー
- **使い方**:
  ```ruby
  # モデルのテスト例
  describe User do
    it { should validate_presence_of(:email) }
    it { should have_many(:articles) }
  end
  ```

### メール開発

#### Letter Opener（メール確認）
- **機能**: 送信メールをブラウザで確認
- **設定**: 自動適用済み
- **使い方**: メール送信後、自動でブラウザが開く

### その他便利ツール

#### Rails ERD（ER図生成）
- **機能**: データベース設計図を自動生成
- **使い方**:
  ```bash
  # GraphVizをインストール（初回のみ）
  brew install graphviz
  
  # ER図生成
  rails erd
  ```
- **出力**: `erd.pdf`ファイルが生成される

#### Spring（高速化）
- **機能**: アプリケーション起動の高速化
- **使い方**: 自動的に動作
- **管理**:
  ```bash
  # Spring停止
  spring stop
  
  # Spring状態確認
  spring status
  ```

## 🛠️ 開発フロー

### 1. エラー発生時
1. Better Errorsで美しいエラー画面を確認
2. 必要に応じて`binding.pry`でブレークポイント設定
3. Pryコンソールで変数やメソッドを調査

### 2. パフォーマンス改善
1. Bulletの警告をチェック
2. N+1クエリがあれば`includes`で修正
3. 不要なクエリを削除

### 3. テスト作成
1. Factory Botでテストデータ定義
2. Shoulda Matchersで簡潔なテスト記述
3. RSpecでテスト実行

### 4. コード品質向上
1. RuboCopでコード品質チェック
2. Brakeman でセキュリティチェック
3. Rails ERDでデータベース設計確認

## 🎯 おすすめコマンド

```bash
# 全体的な品質チェック
bundle exec rubocop
bundle exec brakeman
bundle exec rspec

# ER図生成（要GraphViz）
rails erd

# アセット関連のトラブル時
rails assets:clobber
rails assets:precompile

# Spring関連のトラブル時
spring stop
```

これらのツールを活用して、効率的にDesign Lab CMSの開発を進めましょう！