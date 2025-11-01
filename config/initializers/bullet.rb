# Bullet設定 - N+1クエリ検出
if defined?(Bullet) && Rails.env.development?
  Bullet.enable = true
  Bullet.alert = false # ポップアップを無効化
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
  Bullet.add_footer = true # フッターに表示
end