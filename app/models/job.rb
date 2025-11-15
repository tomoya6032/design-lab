class Job < ApplicationRecord
  include MediaIntegration
  
  # Active Storage attachments
  has_many_attached :hero_images
  has_many_attached :detail_images
  
  # メディア使用状況の関連付け
  has_many :media_usages, as: :mediable, dependent: :destroy
  has_many :media, through: :media_usages, source: :medium
  
  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :job_type, presence: true, length: { maximum: 50 }
  validates :description, presence: true
  validates :capacity, length: { maximum: 50 }
  validates :salary_range, length: { maximum: 100 }
  validates :display_order, presence: true, numericality: { only_integer: true }
  
  # Scopes
  scope :published, -> { where(published: true) }
  scope :ordered, -> { order(:display_order, :created_at) }
  scope :by_job_type, ->(job_type) { where(job_type: job_type) }
  
  # 検索用スコープ
  scope :search_by_text, ->(query) {
    return all if query.blank?
    
    search_term = "%#{query}%"
    where(
      "title ILIKE :term OR " \
      "job_type ILIKE :term OR " \
      "description ILIKE :term OR " \
      "expectations ILIKE :term OR " \
      "salary_range ILIKE :term OR " \
      "senior_message ILIKE :term",
      term: search_term
    )
  }
  
  # Class methods
  def self.job_types
    distinct.pluck(:job_type).compact.sort
  end
  
  # Instance methods
  def published?
    published
  end
  
  def hero_image
    hero_images.attached? ? hero_images.first : nil
  end
  
  def truncated_description(limit = 120)
    description.present? ? description.truncate(limit) : ''
  end
end
