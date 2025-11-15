class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_site_setting, unless: -> { request.path.start_with?('/api/') }
  before_action :load_navigation_pages, unless: -> { request.path.start_with?('/admin') || request.path.start_with?('/api/') }
  before_action :load_sidebar_data, if: -> { request.path.start_with?('/site') }
  
  # パンくずリスト用
  helper_method :breadcrumbs
  
  private
  
  def breadcrumbs
    @breadcrumbs ||= []
  end
  
  def add_breadcrumb(title, path = nil)
    @breadcrumbs ||= []
    @breadcrumbs << { title: title, path: path }
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :first_name, :last_name])
  end
  
  def load_site_setting
    @site_setting = Setting.current
  end
  
  def load_navigation_pages
    @navigation_pages = Page.where(show_in_navigation: true, status: :published).order(:title)
  end
  
  def load_sidebar_data
    # サイドバー用のカテゴリデータ（記事数付き）
    @categories = Category.joins(:articles)
                         .where(articles: { status: :published })
                         .group('categories.id', 'categories.name')
                         .order('categories.name')
                         .pluck('categories.name', 'COUNT(articles.id)')
                         .map { |name, count| { name: name, count: count } }
    
    # サイドバー用のタグデータ（記事数付き）
    @tags = Tag.joins(:articles)
               .where(articles: { status: :published })
               .group('tags.id', 'tags.name')
               .order('tags.name')
               .pluck('tags.name', 'COUNT(articles.id)')
               .map { |name, count| { name: name, count: count } }
    
    # 最近の記事
    @recent_sidebar_articles = Article.published.recent.includes(:user).limit(5)
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
