module MediaIntegration
  extend ActiveSupport::Concern

  included do
    # Active Storage アタッチメント後にメディアライブラリに登録
    after_commit :register_attachments_to_media_library, on: [:create, :update]
  end

  private

  def register_attachments_to_media_library
    return unless respond_to?(:media_usages)
    
    Rails.logger.info "🎬 #{self.class.name} #{id}: メディア登録を開始"
    
    # 各 Active Storage アタッチメントを処理
    attachment_definitions.each do |attachment_name, config|
      attachment = send(attachment_name)
      
      next unless attachment.attached?
      
      # has_many_attached の場合
      if attachment.respond_to?(:each)
        attachment.each do |blob_attachment|
          register_single_attachment(blob_attachment, attachment_name)
        end
      # has_one_attached の場合
      else
        register_single_attachment(attachment, attachment_name)
      end
    end
  end

  def register_single_attachment(attachment, attachment_name)
    return unless attachment&.blob
    
    blob = attachment.blob
    
    # 既にメディアライブラリに登録されているかチェック
    existing_medium = Medium.joins(:file_attachment)
                           .where(active_storage_attachments: { blob_id: blob.id })
                           .first
    
    if existing_medium
      Rails.logger.info "  📁 既存メディアを使用: #{existing_medium.title}"
      medium = existing_medium
    else
      # 新しいメディアを作成
      medium = create_medium_from_blob(blob, attachment_name)
      Rails.logger.info "  ✨ 新規メディア作成: #{medium.title}"
    end
    
    return unless medium
    
    # 使用状況を記録
    usage_type = determine_usage_type(attachment_name)
    context = attachment_name.to_s
    
    media_usage = MediaUsage.find_or_initialize_by(
      medium: medium,
      mediable: self,
      usage_type: usage_type,
      context: context
    )
    
    if media_usage.new_record?
      media_usage.save!
      Rails.logger.info "  🔗 使用状況記録: #{usage_type} (#{context})"
    end
    
    medium
  rescue => e
    Rails.logger.error "❌ メディア登録エラー: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  def create_medium_from_blob(blob, attachment_name)
    # ファイル名からタイトルを生成
    title = generate_title_from_filename(blob.filename.to_s, attachment_name)
    
    # Userを設定（可能であれば）
    user = respond_to?(:user) ? self.user : User.first
    
    medium = Medium.new(
      title: title,
      description: "#{self.class.human_name}「#{display_title}」から自動登録",
      filename: blob.filename.to_s,
      file_type: blob.content_type,
      file_size: blob.byte_size,
      user: user
    )
    
    # Blobを直接アタッチ
    medium.file.attach(blob)
    
    if medium.save
      medium
    else
      Rails.logger.error "❌ メディア保存失敗: #{medium.errors.full_messages.join(', ')}"
      nil
    end
  end

  def generate_title_from_filename(filename, attachment_name)
    # 拡張子を除去
    base_name = File.basename(filename, File.extname(filename))
    
    # アタッチメント名に基づいてプレフィックスを追加
    prefix = case attachment_name.to_s
             when /featured_image|hero_image/
               "アイキャッチ"
             when /background/
               "背景画像"
             when /detail|gallery/
               "詳細画像"
             else
               "画像"
             end
    
    "#{prefix}: #{base_name}"
  end

  def determine_usage_type(attachment_name)
    case attachment_name.to_s
    when /featured_image/
      :featured_image
    when /hero.*image/
      :hero_image
    when /background.*image/
      :background_image
    when /detail.*image/
      :detail_image
    when /gallery|pc_images|sp_images/
      :gallery_image
    else
      :content_image
    end
  end

  def display_title
    if respond_to?(:title) && title.present?
      title
    elsif respond_to?(:name) && name.present?
      name
    else
      "ID: #{id}"
    end
  end

  def attachment_definitions
    # Active Storage のアタッチメント定義を取得
    self.class.reflect_on_all_attachments.map do |reflection|
      [reflection.name, reflection.options]
    end
  end

  class_methods do
    # 既存のメディアを一括登録するためのクラスメソッド
    def register_all_media_to_library
      Rails.logger.info "🚀 #{name} の全メディアを一括登録開始"
      
      find_each do |record|
        begin
          record.send(:register_attachments_to_media_library)
        rescue => e
          Rails.logger.error "❌ #{name} ID:#{record.id} のメディア登録失敗: #{e.message}"
        end
      end
      
      Rails.logger.info "✅ #{name} の全メディア一括登録完了"
    end
  end
end