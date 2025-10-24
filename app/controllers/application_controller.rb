class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_site_setting, unless: -> { request.path.start_with?('/api/') }
  
  private
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :first_name, :last_name])
  end
  
  def load_site_setting
    @site_setting = Setting.current
  end
  
  # ログイン成功後のリダイレクト先
  def after_sign_in_path_for(resource)
    admin_root_path
  end
  
  # ログアウト後のリダイレクト先
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
