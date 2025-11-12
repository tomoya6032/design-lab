# config/initializers/default_url_options.rb
Rails.application.configure do
  if Rails.env.development?
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    Rails.application.routes.default_url_options = { host: 'localhost', port: 3000 }
  end
end