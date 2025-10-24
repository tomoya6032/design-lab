class Admin::ThemeCustomizationController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_setting

  def edit
    @current_theme = @setting.theme || 'modern'
  end

  def update
    if @setting.update(theme_customization_params)
      redirect_to admin_theme_customization_path, notice: 'テーマ設定が保存されました。'
    else
      render :edit
    end
  end

  private

  def set_setting
    @setting = Setting.current
  end

  def theme_customization_params
    params.require(:setting).permit(
      :primary_color, :secondary_color, :accent_color,
      :font_family, :header_font,
      :header_height, :container_width, :sidebar_width,
      :border_radius, :box_shadow, :animation_speed
    )
  end
end