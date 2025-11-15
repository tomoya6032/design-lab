class Portfolio < ApplicationRecord
  include MediaIntegration
  
  has_many_attached :pc_images
  has_many_attached :sp_images
  
  # メディア使用状況の関連付け  
  has_many :media_usages, as: :mediable, dependent: :destroy
  has_many :media, through: :media_usages, source: :medium
  
  validates :title, presence: true
  validates :production_period, presence: true
  validates :description, presence: true
  
  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:display_order, :created_at) }
  
  # 検索用スコープ
  scope :search_by_text, ->(query) {
    return all if query.blank?
    
    search_term = "%#{query}%"
    where(
      "title ILIKE :term OR " \
      "description ILIKE :term OR " \
      "production_period ILIKE :term",
      term: search_term
    )
  }
  
  def published?
    published
  end
  
  # 後方互換性のためのメソッド
  def pc_image
    pc_images.first
  end
  
  def sp_image
    sp_images.first
  end
  
  # ビューで使用するメソッド
  def featured_image
    pc_images.first || sp_images.first
  end
  
  def images
    pc_images + sp_images
  end
end
