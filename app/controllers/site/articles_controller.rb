class Site::ArticlesController < ApplicationController
  layout 'site'
  before_action :load_site_setting
  before_action :set_article, only: [:show]
  
  def index
    add_breadcrumb('コラム', site_articles_path)
    
    @articles = Article.published.recent
    
    # 検索機能
    @articles = @articles.search_by_text(params[:search]) if params[:search].present?
    
    # カテゴリによるフィルタリング
    if params[:category].present?
      category = Category.find_by(name: params[:category])
      @articles = @articles.joins(:categories).where(categories: { id: category.id }) if category
      @current_category = params[:category]
      add_breadcrumb(@current_category) if @current_category
    end
    
    # タグによるフィルタリング
    if params[:tag].present?
      tag = Tag.find_by(name: params[:tag])
      @articles = @articles.joins(:tags).where(tags: { id: tag.id }) if tag
      @current_tag = params[:tag]
      add_breadcrumb(@current_tag) if @current_tag
    end
    
    # 必要な関連データと一緒に取得（eager loading）
    @articles = @articles.includes(:featured_image_attachment, :categories, :tags).limit(20)
  end
  
  def show
    add_breadcrumb('コラム', site_articles_path)
    add_breadcrumb(@article.title)
    
    # 公開済みの記事または限定公開記事を表示
    # 下書きの記事は表示しない
    if @article.status == 'draft'
      redirect_to root_path, alert: '記事が見つかりません'
      return
    end
    
    # 公開記事の場合は公開日時もチェック
    if @article.status == 'published' && @article.published_at && @article.published_at > Time.current
      redirect_to root_path, alert: '記事が見つかりません'
      return
    end
    
    # サイドバー用のデータを読み込み
    @recent_articles = Article.published.recent.with_featured_image.limit(5).where.not(id: @article.id)
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
  

end