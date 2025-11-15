class Article < ApplicationRecord
  include MediaIntegration
  
  belongs_to :user
  has_one_attached :featured_image
  
  # カテゴリとタグの関連付け
  has_many :article_categories, dependent: :destroy
  has_many :categories, through: :article_categories
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags
  
  # メディア使用状況の関連付け
  has_many :media_usages, as: :mediable, dependent: :destroy
  has_many :media, through: :media_usages, source: :medium
  
  # ステータスのenum定義（Rails 8対応）
  enum :status, { draft: 0, published: 1, scheduled: 2, archived: 3, limited: 4 }
  
  # バリデーション
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true
  
  # コールバック
  before_validation :ensure_slug_present, :make_slug_unique
  before_save :set_published_at
  
  # スコープ
  scope :published, -> { where(status: :published).where('published_at IS NULL OR published_at <= ?', Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  # N+1クエリを防ぐためのeager loading用スコープ
  scope :with_featured_image, -> { includes(:featured_image_attachment) }
  scope :with_associations, -> { includes(:user, :featured_image_attachment) }
  
  # 検索用スコープ
  scope :search_by_text, ->(query) {
    return all if query.blank?
    
    search_term = "%#{query}%"
    where(
      "title ILIKE :term OR " \
      "content_json::text ILIKE :term OR " \
      "meta_description ILIKE :term OR " \
      "(content_json ->> 'blocks')::text ILIKE :term",
      term: search_term
    )
  }
  
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
  
  def set_published_at
    # publishedに変更された時、published_atが未設定の場合は現在時刻を設定
    if status_changed? && published? && published_at.nil?
      self.published_at = Time.current
    end
  end
end
