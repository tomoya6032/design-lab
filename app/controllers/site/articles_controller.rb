class Site::ArticlesController < ApplicationController
  layout 'site'
  before_action :load_site_setting
  before_action :set_article, only: [:show]
  
  def show
    # 公開済みの記事のみ表示
    unless @article.published? && @article.published_at <= Time.current
      redirect_to root_path, alert: '記事が見つかりません'
    end
  end
  
  private
  
  def set_article
    @article = Article.find_by(slug: params[:id]) || Article.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '記事が見つかりません'
  end
  
  def load_site_setting
    @site_setting = Setting.current
  end
end