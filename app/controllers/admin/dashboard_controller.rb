class Admin::DashboardController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  
  def index
    @recent_articles = Article.recent.limit(5)
    @setting = Setting.current
  end
end
