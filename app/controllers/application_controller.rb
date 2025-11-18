require 'cgi'

class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  # Handle CSRF verification failures gracefully. When a request fails authenticity
  # verification we reset the session (to clear any stale CSRF/session state),
  # log the event and return a user-friendly response. For HTML requests we
  # redirect back with an alert; for JSON/API requests we return 401.
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    # Log basic failure info
    Rails.logger.warn "InvalidAuthenticityToken: #{exception.message} (path=#{request.path}, params=#{request.filtered_parameters.except('controller','action')})"

    # Additional debug: log submitted token presence/length and whether session cookie exists.
    begin
      submitted_token = params[:authenticity_token]
      token_present = submitted_token.present?
      token_len = submitted_token.to_s.length
      session_key = Rails.application.config.session_options[:key]
      session_cookie = request.cookies[session_key]
      # Also log server-side token lengths and whether the submitted token equals the server's current token
      begin
        server_token = form_authenticity_token
        server_token_len = server_token.to_s.length
        server_token_head = server_token.to_s[0,8]
        session_raw = session[:_csrf_token].to_s
        session_raw_len = session_raw.length
        session_raw_head = session_raw[0,8]
        token_equals_server = submitted_token.to_s == server_token.to_s
        submitted_head = submitted_token.to_s[0,8]
      rescue => e
        Rails.logger.error "CSRF-rescue-debug: error obtaining server/session token: #{e.message}"
        server_token_len = nil
        session_raw_len = nil
        token_equals_server = false
        server_token_head = nil
        session_raw_head = nil
        submitted_head = submitted_token.to_s[0,8] rescue nil
      end

      # Use Rails helper to validate the submitted token against the session's raw token.
      begin
        valid = send(:valid_authenticity_token?, session, submitted_token)
      rescue => e
        Rails.logger.error "CSRF-rescue-debug: error calling valid_authenticity_token?: #{e.message}"
        valid = false
      end

      Rails.logger.info "CSRF-rescue-debug: token_present=#{token_present} token_len=#{token_len} submitted_head=#{submitted_head} session_cookie_present=#{session_cookie.present?} session_key=#{session_key} server_token_len=#{server_token_len} server_head=#{server_token_head} session_raw_len=#{session_raw_len} session_raw_head=#{session_raw_head} token_equals_server=#{token_equals_server} valid_authenticity_token=#{valid}"
    rescue => e
      Rails.logger.error "CSRF-rescue-debug: error reading token/session cookie: #{e.message}"
    end

    # Reset session to avoid carrying forward an invalid/stale session.
    reset_session
    respond_to do |format|
      format.html do
        redirect_back fallback_location: root_path, alert: 'セキュリティ上の理由によりセッションがリセットされました。もう一度お試しください。'
      end
      format.json { render json: { error: 'Invalid CSRF token' }, status: :unauthorized }
      format.any  { head :unauthorized }
    end
  end

  # Expose CSRF token to client via response header so SPA/frontends can read it
  # and send it on subsequent requests (e.g. axios.defaults.headers.common['X-CSRF-Token'] = res.headers['x-csrf-token'])
  after_action :set_csrf_token_header, unless: -> { request.format.json? || request.path.start_with?('/api/') }

  def set_csrf_token_header
    response.set_header('X-CSRF-Token', form_authenticity_token)
  end
  
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
