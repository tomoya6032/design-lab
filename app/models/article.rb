class Article < ApplicationRecord
  belongs_to :user
  
  # ステータスのenum定義（Rails 8対応）
  enum :status, { draft: 0, published: 1, scheduled: 2, archived: 3 }
  
  # バリデーション
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true
  
  # コールバック
  before_validation :ensure_slug_present
  
  # スコープ
  scope :published, -> { where(status: :published, published_at: ..Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  
  private
  
  def ensure_slug_present
    if slug.blank? && title.present?
      self.slug = title.parameterize
    elsif slug.present?
      # 手動入力されたスラッグをクリーンアップ
      self.slug = slug.strip.downcase.gsub(/[^a-z0-9\-_]/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')
    end
  end
end
