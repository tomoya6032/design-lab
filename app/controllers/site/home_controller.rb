class Site::HomeController < ApplicationController
  layout 'site'
  before_action :load_site_setting
  before_action :load_navigation_pages
  
  def index
    @recent_articles = Article.published.recent.with_featured_image.limit(8)
    @featured_pages = Page.published.limit(3)
    @portfolios = Portfolio.published.ordered.limit(6)
    @featured_jobs = Job.published.ordered.limit(3)
    
    # サイドバー用データ
    @categories = get_categories
    @tags = get_tags
    @recent_sidebar_articles = Article.published.recent.with_featured_image.limit(5)
  end
  
  private
  
  def get_categories
    # カスタムフィールドからカテゴリーを集計
    categories = {}
    Article.published.each do |article|
      if article.custom_fields && article.custom_fields['category'].present?
        category = article.custom_fields['category']
        categories[category] = (categories[category] || 0) + 1
      end
    end
    categories.map { |name, count| { name: name, count: count } }.sort_by { |cat| -cat[:count] }
  end
  
  def get_tags
    # カスタムフィールドからタグを集計
    tags = {}
    Article.published.each do |article|
      if article.custom_fields && article.custom_fields['tags'].present?
        article_tags = article.custom_fields['tags'].split(',').map(&:strip)
        article_tags.each do |tag|
          tags[tag] = (tags[tag] || 0) + 1 if tag.present?
        end
      end
    end
    tags.map { |name, count| { name: name, count: count } }.sort_by { |tag| -tag[:count] }
  end
  
  def load_site_setting
    @site_setting = Setting.current
  end
end
