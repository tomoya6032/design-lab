class Setting < ApplicationRecord
  # シングルトンパターンでサイト設定を管理
  validates :site_name, presence: true
  validates :theme, inclusion: { in: %w[modern classic minimal] }
  
  # サイト設定の取得（シングルトン）
  def self.current
    first_or_create!(
      site_name: 'Design Lab',
      site_description: 'モダンで高速なCMSサイト',
      theme: 'modern',
      social_links: {},
      seo_settings: {}
    )
  end
  
  # 利用可能なテーマ一覧
  def self.theme_options
    {
      'modern' => 'モダンテーマ',
      'classic' => 'クラシックテーマ',
      'minimal' => 'ミニマルテーマ'
    }
  end
  
  # テーマの表示名
  def theme_display_name
    self.class.theme_options[theme] || 'モダンテーマ'
  end
  
  # テーマカスタマイズのデフォルト値
  def self.theme_defaults
    {
      primary_color: '#007bff',
      secondary_color: '#6c757d',
      accent_color: '#ffc107',
      font_family: 'system-ui, sans-serif',
      header_font: 'bold',
      header_height: 60,
      container_width: 1200,
      sidebar_width: 300,
      border_radius: 4,
      box_shadow: '0 2px 4px rgba(0,0,0,0.1)',
      animation_speed: '0.2s'
    }
  end

  # デフォルト値の設定
  after_initialize :set_defaults
  
  private
  
  def set_defaults
    self.social_links ||= {}
    self.seo_settings ||= {}
    self.theme ||= 'modern'
    self.maintenance_mode = false if maintenance_mode.nil?
    
    # テーマカスタマイズのデフォルト値
    defaults = self.class.theme_defaults
    defaults.each do |key, value|
      self.send("#{key}=", value) if self.send(key).blank?
    end
  end
end
