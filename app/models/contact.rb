class Contact < ApplicationRecord
  # ステータスのenum定義
  enum :status, { pending: 0, processing: 1, completed: 2, spam: 3 }
  
  # バリデーション
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, length: { maximum: 200 }
  validates :message, presence: true, length: { maximum: 5000 }
  validates :status, presence: true
  
  # スコープ
  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(status: :pending) }
  
  # メソッド
  def display_status
    case status
    when 'pending'
      '未対応'
    when 'processing'
      '対応中'
    when 'completed'
      '対応完了'
    when 'spam'
      'スパム'
    else
      '不明'
    end
  end
end
