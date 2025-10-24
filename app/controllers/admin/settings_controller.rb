class Admin::SettingsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_setting

  def show
    redirect_to edit_admin_settings_path
  end

  def edit
  end

  def update
    if @setting.update(setting_params)
      redirect_to edit_admin_settings_path, notice: 'サイト設定が更新されました。'
    else
      render :edit
    end
  end

  private

  def set_setting
    @setting = Setting.current
  end

  def setting_params
    params.require(:setting).permit(
      :site_name, :site_description, :contact_email, :maintenance_mode,
      :theme, :meta_title, :meta_description, :meta_keywords,
      :google_analytics_id, :twitter_url, :facebook_url, 
      :instagram_url, :youtube_url
    )
  end
end