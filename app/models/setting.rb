class Setting < ApplicationRecord
  # シングルトンパターンでサイト設定を管理
  validates :site_name, presence: true
  
  # サイト設定の取得（シングルトン）
  def self.current
    first_or_create!(
      site_name: 'Design Lab',
      site_description: 'モダンで高速なCMSサイト',
      social_links: {},
      seo_settings: {}
    )
  end
  
  # デフォルト値の設定
  after_initialize :set_defaults
  
  private
  
  def set_defaults
    self.social_links ||= {}
    self.seo_settings ||= {}
  end
end
