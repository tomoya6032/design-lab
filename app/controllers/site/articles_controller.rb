class Site::ArticlesController < ApplicationController
  layout 'site'
  before_action :load_site_setting
  before_action :set_article, only: [:show]
  
  def index
    @articles = Article.published.recent
    
    # 検索機能
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @articles = @articles.where("title ILIKE ? OR content_json ILIKE ? OR meta_description ILIKE ?", 
                                 search_term, search_term, search_term)
    end
    
    # PostgreSQLのJSONB検索を使用してカテゴリーフィルター
    if params[:category].present?
      @articles = @articles.where("custom_fields ->> 'category' = ?", params[:category])
    end
    
    # PostgreSQLのJSONB検索を使用してタグフィルター
    if params[:tag].present?
      @articles = @articles.where("custom_fields ->> 'tags' ILIKE ?", "%#{params[:tag]}%")
    end
    
    # 必要な関連データと一緒に取得（eager loading）
    @articles = @articles.includes(:featured_image_attachment).limit(20)
    
    # サイドバー用データ
    @categories = get_categories
    @tags = get_tags
    @recent_sidebar_articles = Article.published.recent.with_featured_image.limit(5)
  end
  
  def show
    # 公開済みの記事のみ表示
    unless @article.published? && @article.published_at <= Time.current
      redirect_to root_path, alert: '記事が見つかりません'
      return
    end
    
    # サイドバー用のデータを読み込み
    @recent_articles = Article.published.recent.with_featured_image.limit(5).where.not(id: @article.id)
    @categories = get_categories
    @tags = get_tags
  end
  
  private
  
  def set_article
    return redirect_to root_path, alert: '記事が見つかりません' if params[:id].blank?
    
    @article = Article.includes(:user, :featured_image_attachment).find_by(slug: params[:id])
    
    # slugで見つからなかった場合、IDで検索（数値の場合のみ）
    if @article.nil? && params[:id].match?(/\A\d+\z/)
      @article = Article.includes(:user, :featured_image_attachment).find_by(id: params[:id])
    end
    
    # 記事が見つからない場合
    unless @article
      redirect_to root_path, alert: '記事が見つかりません'
      return
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '記事が見つかりません'
  end
  
  def load_site_setting
    @site_setting = Setting.current
  end
  
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
end