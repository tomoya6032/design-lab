class Site::HomeController < ApplicationController
  before_action :load_site_setting
  
  def index
    @recent_articles = Article.published.recent.limit(6)
    @featured_pages = Page.published.limit(3)
  end
  
  private
  
  def load_site_setting
    @site_setting = Setting.current
  end
end
