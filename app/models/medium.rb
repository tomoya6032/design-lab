class Medium < ApplicationRecord
  belongs_to :user
  
  # バリデーション
  validates :filename, presence: true
  validates :url, presence: true
  validates :alt_text, presence: true
  
  # スコープ
  scope :recent, -> { order(created_at: :desc) }
end
