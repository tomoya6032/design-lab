source "https://rubygems.org# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# AWS SDK for S3 storage
gem "aws-sdk-s3", require: falseBundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# API認証用 (JWT/トークン認証)
gem "devise"
gem "devise-jwt"

# View関連
gem "haml-rails"
gem "sassc-rails"
gem "image_processing", "~> 1.2"
gem "sprockets-rails"
gem "importmap-rails"

# 国際化・日本語化
gem "rails-i18n"

# フォーム・セキュリティ関連
gem "recaptcha", "~> 5.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # テストフレームワーク
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"      # テストデータの生成
  gem "shoulda-matchers"       # RSpecの便利なマッチャー
end

group :development do
  # デバッグ・開発ツール
  gem "faker"
  # ページング
  gem "kaminari"
  
  # 🚀 開発効率化ツール
  gem "better_errors"          # 美しいエラー画面
  gem "binding_of_caller"      # better_errorsでコンソール機能を有効化
  gem "pry-rails"              # 強力なデバッガー（rails consoleの置き換え）
  gem "pry-byebug"             # pryでブレークポイント機能
  # gem "annotate"             # モデルファイルにスキーマ情報を自動追加（Rails 8未対応のため一時的に無効）
  gem "rails-erd"              # データベース設計図(ERD)を自動生成
  gem "bullet"                 # N+1クエリ問題を検出
  gem "listen"                 # ファイル変更の監視（高速化）
  gem "spring"                 # アプリケーション起動の高速化
  gem "spring-watcher-listen"  # springでlistenを使用
  
  # 💎 コード品質・フォーマッター
  gem "rubocop-performance"    # パフォーマンス改善のRuboCop拡張
  gem "rubocop-rspec"          # RSpec用のRuboCop拡張
  
  # 📧 メール開発ツール
  gem "letter_opener"          # 送信メールをブラウザで確認
  
  # 🗂️ ログ・出力改善
  gem "awesome_print"          # 美しいオブジェクト出力
end
