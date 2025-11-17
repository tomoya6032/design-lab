namespace :aws do
  desc "Test AWS S3 connection"
  task test_s3: :environment do
    puts "Testing AWS S3 connection..."
    
    begin
      # Active Storageの設定を確認
      service = ActiveStorage::Blob.service
      
      if service.is_a?(ActiveStorage::Service::S3Service)
        puts "✅ Active Storage is configured to use S3"
        puts "Bucket: #{service.bucket.name}"
        puts "Region: #{service.client.config.region}"
        
        # バケットへの接続テスト
        service.bucket.exists?
        puts "✅ Successfully connected to S3 bucket"
        
        # テストファイルのアップロード（オプション）
        test_key = "test/connection_test_#{Time.current.to_i}.txt"
        test_content = "AWS S3 connection test - #{Time.current}"
        
        service.upload(test_key, StringIO.new(test_content))
        puts "✅ Test file uploaded successfully"
        
        # テストファイルの削除
        service.delete(test_key)
        puts "✅ Test file deleted successfully"
        
        puts "\n🎉 AWS S3 connection test completed successfully!"
        
      else
        puts "❌ Active Storage is not configured to use S3"
        puts "Current service: #{service.class.name}"
      end
      
    rescue Aws::S3::Errors::NoSuchBucket => e
      puts "❌ S3 Bucket not found: #{e.message}"
      puts "Please check your bucket name in the configuration"
      
    rescue Aws::Errors::ServiceError => e
      puts "❌ AWS Service Error: #{e.message}"
      puts "Please check your AWS credentials and permissions"
      
    rescue => e
      puts "❌ Error: #{e.message}"
      puts "Please check your AWS configuration"
    end
  end
  
  desc "Show current AWS configuration"
  task show_config: :environment do
    puts "Current AWS Configuration:"
    puts "========================="
    
    if Rails.env.development? || Rails.env.test?
      puts "Environment: #{Rails.env}"
      puts "AWS_ACCESS_KEY_ID: #{ENV['AWS_ACCESS_KEY_ID'].present? ? '✅ Set' : '❌ Not set'}"
      puts "AWS_SECRET_ACCESS_KEY: #{ENV['AWS_SECRET_ACCESS_KEY'].present? ? '✅ Set' : '❌ Not set'}"
      puts "AWS_REGION: #{ENV['AWS_REGION'] || '❌ Not set'}"
      puts "AWS_BUCKET: #{ENV['AWS_BUCKET'] || '❌ Not set'}"
    else
      aws_creds = Rails.application.credentials.aws
      if aws_creds
        puts "Environment: #{Rails.env}"
        puts "AWS_ACCESS_KEY_ID: #{aws_creds[:access_key_id].present? ? '✅ Set' : '❌ Not set'}"
        puts "AWS_SECRET_ACCESS_KEY: #{aws_creds[:secret_access_key].present? ? '✅ Set' : '❌ Not set'}"
        puts "AWS_REGION: #{aws_creds[:region] || '❌ Not set'}"
        puts "AWS_BUCKET: #{aws_creds[:bucket] || '❌ Not set'}"
      else
        puts "❌ AWS credentials not configured in Rails credentials"
      end
    end
    
    puts "\nActive Storage Configuration:"
    puts "Service: #{ActiveStorage::Blob.service.class.name}"
  end
end