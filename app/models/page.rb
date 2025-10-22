class Page < ApplicationRecord
  belongs_to :user
  
  # ステータスのenum定義（Rails 8対応）
  enum :status, { draft: 0, published: 1, scheduled: 2, archived: 3 }
  
  # バリデーション
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true
  
  # コールバック
  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  
  # スコープ
  scope :published, -> { where(status: :published, published_at: ..Time.current) }
  
  private
  
  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
