# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.site_key = Rails.application.credentials.recaptcha&.dig(:site_key) || ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = Rails.application.credentials.recaptcha&.dig(:secret_key) || ENV['RECAPTCHA_SECRET_KEY']
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
  
  # Skip verification in test and development environments
  config.skip_verify_env = ['test', 'development']
end