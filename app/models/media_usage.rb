class MediaUsage < ApplicationRecord
  belongs_to :medium
  belongs_to :mediable, polymorphic: true
  
  # 使用タイプのenum定義
  enum :usage_type, {
    featured_image: 0,    # アイキャッチ画像
    hero_image: 1,        # ヒーロー画像
    detail_image: 2,      # 詳細画像
    background_image: 3,  # 背景画像
    gallery_image: 4,     # ギャラリー画像
    content_image: 5,     # コンテンツ内画像
    thumbnail: 6,         # サムネイル
    attachment: 7         # 添付ファイル
  }
  
  validates :usage_type, presence: true
  validates :medium_id, uniqueness: { scope: [:mediable_type, :mediable_id, :usage_type, :context] }
  
  # スコープ
  scope :by_usage_type, ->(type) { where(usage_type: type) }
  scope :by_mediable_type, ->(type) { where(mediable_type: type) }
  
  # 使用状況の説明
  def usage_description
    type_name = I18n.t("enums.media_usage.usage_type.#{usage_type}", default: usage_type.humanize)
    "#{mediable_type}「#{mediable_title}」の#{type_name}"
  end
  
  # 使用タイプの日本語名
  def usage_type_name
    I18n.t("enums.media_usage.usage_type.#{usage_type}", default: usage_type.humanize)
  end
  
  private
  
  def mediable_title
    if mediable.respond_to?(:title)
      mediable.title
    elsif mediable.respond_to?(:name)
      mediable.name
    else
      "ID: #{mediable.id}"
    end
  end
end
