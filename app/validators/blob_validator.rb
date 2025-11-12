class BlobValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.respond_to?(:attached?) && value.attached?
    
    validate_content_type(record, attribute, value) if options[:content_type]
    validate_size(record, attribute, value) if options[:size]
  end
  
  private
  
  def validate_content_type(record, attribute, value)
    return unless value.blob
    
    allowed_types = Array(options[:content_type])
    content_type = value.blob.content_type
    
    if allowed_types.include?(:web_image_or_media)
      allowed_types = [
        # 画像
        'image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml',
        # 動画
        'video/mp4', 'video/webm', 'video/avi', 'video/quicktime',
        # 音声
        'audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp3',
        # ドキュメント
        'application/pdf', 
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      ]
    end
    
    unless allowed_types.include?(content_type)
      record.errors.add(attribute, "のファイル形式が対応していません。対応形式: #{allowed_types.join(', ')}")
    end
  end
  
  def validate_size(record, attribute, value)
    return unless value.blob
    
    max_size = options[:size]
    if value.blob.byte_size > max_size
      record.errors.add(attribute, "のサイズが大きすぎます。最大#{max_size / 1.megabyte}MBまでです。")
    end
  end
end