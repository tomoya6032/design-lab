# AWS設定の初期化
# 開発・テスト環境では.envファイルから、本番環境ではRails credentialsから設定を読み込む

if Rails.env.development? || Rails.env.test?
  # .envファイルが存在する場合のみ処理
  env_file = Rails.root.join('.env')
  if File.exist?(env_file)
    Rails.logger.info "Loading AWS configuration from .env file"
    
    # 必要な環境変数が設定されているかチェック
    required_vars = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_BUCKET]
    missing_vars = required_vars.select { |var| ENV[var].blank? }
    
    if missing_vars.any?
      Rails.logger.warn "Missing AWS environment variables: #{missing_vars.join(', ')}"
      Rails.logger.warn "Please check your .env file"
    else
      Rails.logger.info "AWS configuration loaded successfully"
      Rails.logger.info "AWS Region: #{ENV['AWS_REGION']}"
      Rails.logger.info "AWS Bucket: #{ENV['AWS_BUCKET']}"
    end
  else
    Rails.logger.warn ".env file not found. Please copy .env.example to .env and configure your AWS settings"
  end
elsif Rails.env.production?
  # 本番環境でのcredentials確認
  aws_config = Rails.application.credentials.aws
  if aws_config.blank?
    Rails.logger.error "AWS credentials not configured for production environment"
  else
    Rails.logger.info "AWS configuration loaded from Rails credentials"
  end
end