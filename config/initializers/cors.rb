# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 開発環境でNext.js/Nuxt.jsが動作するポート（例：3000）を許可
    origins 'localhost:3000', '127.0.0.1:3000', 'localhost:3001', '127.0.0.1:3001'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      # JWT認証に必要なヘッダーを公開
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client', 'authorization', 'X-CSRF-Token'],
      # 認証情報（Cookieなど）のやり取りを許可
      credentials: true
  end
end
