class Medium < ApplicationRecord
  belongs_to :user
  
  # Active Storage関連付け
  has_one_attached :file
  
  # メディア使用状況の関連付け
  has_many :media_usages, dependent: :destroy
  has_many :articles, through: :media_usages, source: :mediable, source_type: 'Article'
  has_many :pages, through: :media_usages, source: :mediable, source_type: 'Page'
  has_many :portfolios, through: :media_usages, source: :mediable, source_type: 'Portfolio'
  has_many :jobs, through: :media_usages, source: :mediable, source_type: 'Job'
  has_many :settings, through: :media_usages, source: :mediable, source_type: 'Setting'
  
  # バリデーション
  validates :title, presence: true
  validates :file, presence: true, blob: { content_type: :web_image_or_media, size: 20.megabytes }
  validates :alt_text, presence: true, if: -> { image? && new_record? }
  
  # コールバック
  before_save :set_file_metadata, if: -> { file.present? && file.attached? }
  
  # スコープ
  scope :recent, -> { order(created_at: :desc) }
  scope :images, -> { where(file_type: ['image/jpeg', 'image/png', 'image/gif', 'image/webp']) }
  scope :videos, -> { where(file_type: ['video/mp4', 'video/webm', 'video/avi']) }
  scope :documents, -> { where(file_type: ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']) }
  scope :audio, -> { where(file_type: ['audio/mpeg', 'audio/wav', 'audio/ogg']) }
  
  # ファイルタイプ判定メソッド
  def image?
    file_type&.start_with?('image/')
  end
  
  def video?
    file_type&.start_with?('video/')
  end
  
  def audio?
    file_type&.start_with?('audio/')
  end
  
  def document?
    file_type&.start_with?('application/')
  end
  
  # ファイルURL取得
  def file_url
    return nil unless file.attached?
    
    begin
      Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
    rescue => e
      Rails.logger.error "Error generating file URL: #{e.message}"
      nil
    end
  end

  def thumbnail_url(size: '200x150')
    return nil unless file.attached?
    
    begin
      if image?
        Rails.application.routes.url_helpers.rails_representation_url(
          file.variant(resize_to_fit: [200, 150]),
          only_path: true
        )
      else
        file_url
      end
    rescue => e
      Rails.logger.error "Error generating thumbnail URL: #{e.message}"
      file_url
    end
  end
  
  def thumbnail_url
    return file_url unless file.attached? && image?
    
    # 画像の場合はリサイズされたバージョンを返す
    Rails.application.routes.url_helpers.url_for(file.variant(resize_to_limit: [200, 200]))
  end
  
  # ファイル名取得
  def display_filename
    filename.presence || file.filename.to_s
  end
  
  # メディア使用状況の確認
  def used?
    media_usages.exists?
  end
  
  def usage_count
    media_usages.count
  end
  
  def usage_summary
    return "未使用" unless used?
    
    usage_types = media_usages.group(:usage_type).count
    summary_parts = []
    
    usage_types.each do |type, count|
      type_name = MediaUsage.usage_types.key(type)
      summary_parts << "#{MediaUsage.human_enum_name(:usage_type, type_name)}(#{count})"
    end
    
    summary_parts.join(", ")
  end
  
  def used_by_models
    media_usages.group(:mediable_type).count
  end
  
  private
  
  def set_file_metadata
    if file.attached?
      blob = file.blob
      self.filename = blob.filename.to_s if filename.blank?
      self.file_type = blob.content_type
      self.file_size = blob.byte_size
    end
  end
end
