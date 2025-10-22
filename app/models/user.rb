class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # 関連付け
  has_many :articles, dependent: :destroy
  has_many :pages, dependent: :destroy
  has_many :media, dependent: :destroy
  
  # バリデーション
  validates :email, presence: true, uniqueness: true
end
