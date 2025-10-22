class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_site_setting, unless: -> { request.path.start_with?('/api/') }
  
  private
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end
  
  def load_site_setting
    @site_setting = Setting.current
  end
end
