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
  # 本番環境では環境変数またはcredentialsから読み込み
  aws_config = Rails.application.credentials.aws
  
  # 環境変数の確認
  required_env_vars = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_S3_BUCKET]
  env_vars_present = required_env_vars.all? { |var| ENV[var].present? }
  
  if env_vars_present
    Rails.logger.info "AWS configuration loaded from environment variables"
    Rails.logger.info "AWS Region: #{ENV['AWS_REGION']}"
    Rails.logger.info "AWS Bucket: #{ENV['AWS_S3_BUCKET']}"
  elsif aws_config.present?
    Rails.logger.info "AWS configuration loaded from Rails credentials"
  else
    Rails.logger.error "AWS credentials not configured for production environment"
    Rails.logger.error "Either set environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, AWS_S3_BUCKET) or configure Rails credentials"
  end
end