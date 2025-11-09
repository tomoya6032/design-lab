class Category < ApplicationRecord
  # 階層構造
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  
  # 記事との関連付け
  has_many :article_categories, dependent: :destroy
  has_many :articles, through: :article_categories
  
  # バリデーション
  validates :name, presence: true, uniqueness: { scope: :parent_id }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-_]+\z/ }
  
  # スコープ
  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :name) }
  
  # コールバック
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  
  # インスタンスメソッド
  def root?
    parent_id.nil?
  end
  
  def has_children?
    children.any?
  end
  
  def ancestors
    return [] if root?
    [parent] + parent.ancestors
  end
  
  def descendants
    children + children.flat_map(&:descendants)
  end
  
  private
  
  def generate_slug
    self.slug = name.parameterize
  end
end
