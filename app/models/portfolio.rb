class Portfolio < ApplicationRecord
  has_many_attached :pc_images
  has_many_attached :sp_images
  
  validates :title, presence: true
  validates :production_period, presence: true
  validates :description, presence: true
  
  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:display_order, :created_at) }
  
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
end
