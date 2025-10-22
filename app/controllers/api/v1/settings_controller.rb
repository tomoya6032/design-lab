class Api::V1::SettingsController < Api::V1::BaseController
  before_action :authenticate_user!, only: [:update]
  
  # GET /api/v1/settings
  def show
    @setting = Setting.current
    render json: { setting: setting_json(@setting) }
  end
  
  # PATCH/PUT /api/v1/settings
  def update
    @setting = Setting.current
    
    if @setting.update(setting_params)
      render json: { setting: setting_json(@setting) }
    else
      render json: { errors: @setting.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def setting_params
    params.require(:setting).permit(
      :site_name, :site_description, :logo_url, :favicon_url, 
      :custom_css, :custom_js, social_links: {}, seo_settings: {}
    )
  end
  
  def setting_json(setting)
    {
      id: setting.id,
      site_name: setting.site_name,
      site_description: setting.site_description,
      logo_url: setting.logo_url,
      favicon_url: setting.favicon_url,
      custom_css: setting.custom_css,
      custom_js: setting.custom_js,
      social_links: setting.social_links,
      seo_settings: setting.seo_settings,
      created_at: setting.created_at,
      updated_at: setting.updated_at
    }
  end
end
