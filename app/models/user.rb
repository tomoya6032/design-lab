class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  
  # 関連付け
  has_many :articles, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :media, dependent: :destroy
  
  # バリデーション
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[user editor admin] }
  
  # ロール管理
  def self.role_options
    {
      'user' => 'ユーザー',
      'editor' => '編集者',
      'admin' => '管理者'
    }
  end
  
  def role_display_name
    self.class.role_options[role] || 'ユーザー'
  end
  
  def admin?
    role == 'admin'
  end
  
  def editor?
    role == 'editor'
  end
  
  def full_name
    if first_name.present? || last_name.present?
      "#{first_name} #{last_name}".strip
    else
      email
    end
  end
  
  def trackable_enabled?
    respond_to?(:last_sign_in_at)
  end
  
  def last_login_display
    return '未ログイン' unless trackable_enabled? && last_sign_in_at
    last_sign_in_at.strftime('%Y年%m月%d日 %H:%M')
  end
  
  def login_count_display
    return '0回' unless trackable_enabled?
    "#{sign_in_count || 0}回"
  end
  
  # デフォルト値の設定
  after_initialize :set_defaults
  
  private
  
  def set_defaults
    self.role ||= 'user'
  end
end
