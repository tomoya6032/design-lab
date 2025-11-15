class JobApplication < ApplicationRecord
  belongs_to :job

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, length: { maximum: 20 }
  validates :motivation, presence: true, length: { maximum: 2000 }
  validates :experience_years, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cover_letter, length: { maximum: 2000 }
  validates :portfolio_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # ファイルアップロード用（Active Storage）
  has_one_attached :resume_file

  # ステータス管理
  enum :status, {
    submitted: 0,      # 応募済み
    reviewing: 1,      # 選考中
    interview: 2,      # 面接予定
    accepted: 3,       # 採用決定
    rejected: 4        # 不採用
  }

  # ステータス表示用ヘルパー
  def status_display
    case status
    when 'submitted'
      '応募済み'
    when 'reviewing'
      '選考中'
    when 'interview'
      '面接予定'
    when 'accepted'
      '採用決定'
    when 'rejected'
      '不採用'
    else
      '不明'
    end
  end

  # ステータス色表示用ヘルパー
  def status_color
    case status
    when 'submitted'
      'primary'
    when 'reviewing'
      'warning'
    when 'interview'
      'info'
    when 'accepted'
      'success'
    when 'rejected'
      'danger'
    else
      'secondary'
    end
  end
end
