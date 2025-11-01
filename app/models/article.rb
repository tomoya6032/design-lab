class Article < ApplicationRecord
  belongs_to :user
  has_one_attached :featured_image
  
  # ステータスのenum定義（Rails 8対応）
  enum :status, { draft: 0, published: 1, scheduled: 2, archived: 3 }
  
  # バリデーション
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true
  
  # コールバック
  before_validation :ensure_slug_present, :make_slug_unique
  
  # スコープ
  scope :published, -> { where(status: :published, published_at: ..Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  # N+1クエリを防ぐためのeager loading用スコープ
  scope :with_featured_image, -> { includes(:featured_image_attachment) }
  scope :with_associations, -> { includes(:user, :featured_image_attachment) }
  
  # ルーティング用のパラメータ（slugが優先、なければid）
  def to_param
    if slug.present? && !slug.blank?
      slug
    elsif id.present?
      id.to_s
    else
      "temp-#{Time.current.to_i}"
    end
  end
  
  private
  
  def ensure_slug_present
    if slug.blank? && title.present?
      self.slug = title.parameterize
      # parameterizeの結果が空の場合（日本語のみのタイトルなど）は、IDベースのスラッグを生成
      if self.slug.blank?
        self.slug = "article-#{id || Time.current.to_i}"
      end
    elsif slug.present?
      # 手動入力されたスラッグをクリーンアップ
      self.slug = slug.strip.downcase.gsub(/[^a-z0-9\-_]/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')
    end
    
    # スラッグが依然として空の場合の最終的なフォールバック
    if slug.blank?
      self.slug = "article-#{id || Time.current.to_i}"
    end
  end
  
  def make_slug_unique
    return if slug.blank?
    
    original_slug = slug
    counter = 1
    
    while Article.where(slug: slug).where.not(id: id).exists?
      self.slug = "#{original_slug}-#{counter}"
      counter += 1
    end
  end
end
