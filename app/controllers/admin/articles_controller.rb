require 'open-uri'

class Admin::ArticlesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    @articles = Article.order(created_at: :desc)
  end

  def show
  end

  def new
    @article = Article.new
    load_taxonomy_data
  end

  def create
    Rails.logger.debug "Article params: #{article_params.inspect}"
    @article = Article.new(article_params)
    @article.user = current_user  # 現在のユーザーを自動設定
    
    Rails.logger.debug "Article before save: title=#{@article.title}, slug=#{@article.slug}"
    
    if @article.save
      # 保存後にslugが確実に設定されるようにする
      if @article.slug.blank?
        @article.update_column(:slug, "article-#{@article.id}")
      end
      redirect_to admin_article_path(@article), notice: '記事が作成されました。'
    else
      Rails.logger.debug "Article errors: #{@article.errors.full_messages}"
      # エラー時にもタクソノミーデータを読み込み
      load_taxonomy_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_taxonomy_data
  end

  def update
    if @article.update(article_params)
      redirect_to admin_article_path(@article), notice: '記事が更新されました。'
    else
      # エラー時にもタクソノミーデータを読み込み
      load_taxonomy_data
      render :edit, status: :unprocessable_entity
    end
  end
  
  def edit
    load_taxonomy_data
  end

  def update
    Rails.logger.debug "Updating article with params: #{article_params.inspect}"
    
    if @article.update(article_params)
      redirect_to [:admin, @article], notice: '記事が更新されました'
    else
      load_taxonomy_data
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to admin_articles_path, notice: '記事が削除されました'
  end
  
  def upload_images
    begin
      image_urls = []
      
      if params[:images].present?
        params[:images].each do |index, image_file|
          # Active Storageを使用して画像をアップロード
          blob = ActiveStorage::Blob.create_and_upload!(
            io: image_file,
            filename: image_file.original_filename,
            content_type: image_file.content_type
          )
          
          # 画像URLを生成
          image_url = Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true)
          image_urls << image_url
        end
      end
      
      render json: { success: true, image_urls: image_urls }
    rescue => e
      Rails.logger.error "Image upload error: #{e.message}"
      render json: { success: false, error: e.message }
    end
  end

  def fetch_ogp
    url = params[:url]
    
    begin
      # URLの妥当性チェック
      uri = URI.parse(url)
      unless uri.scheme&.match?(/\Ahttps?\z/) && uri.host
        raise ArgumentError, "無効なURLです"
      end
      
      # HTTPSまたはHTTPのみ許可
      html = uri.open(
        'User-Agent' => 'Mozilla/5.0 (compatible; OGP-fetcher)',
        redirect: true,
        read_timeout: 10
      ).read
      
      doc = Nokogiri::HTML(html)
      
      ogp_data = {
        title: extract_ogp_content(doc, 'og:title') || doc.css('title').first&.text&.strip,
        description: extract_ogp_content(doc, 'og:description') || doc.css('meta[name="description"]').first&.[]('content'),
        image: extract_ogp_content(doc, 'og:image'),
        site_name: extract_ogp_content(doc, 'og:site_name') || uri.host
      }
      
      render json: { success: true, ogp: ogp_data }
    rescue ArgumentError => e
      Rails.logger.error "OGP fetch error: #{e.message}"
      render json: { success: false, error: e.message }
    rescue OpenURI::HTTPError => e
      Rails.logger.error "OGP fetch HTTP error: #{e.message}"
      render json: { success: false, error: "ページにアクセスできませんでした" }
    rescue Timeout::Error => e
      Rails.logger.error "OGP fetch timeout error: #{e.message}"
      render json: { success: false, error: "タイムアウトしました" }
    rescue => e
      Rails.logger.error "OGP fetch error: #{e.message}"
      render json: { success: false, error: "OGP情報を取得できませんでした" }
    end
  end

  private

  def set_article
    Rails.logger.debug "Admin set_article: Searching for article with param: '#{params[:id]}'"
    
    # まずslugで検索、見つからなければIDで検索（数値の場合のみ）
    @article = Article.find_by(slug: params[:id])
    Rails.logger.debug "Admin set_article: Found by slug: #{@article ? 'YES' : 'NO'}"
    
    if @article.nil? && params[:id].match?(/\A\d+\z/)
      @article = Article.find_by(id: params[:id])
      Rails.logger.debug "Admin set_article: Found by ID: #{@article ? 'YES' : 'NO'}"
    end
    
    unless @article
      Rails.logger.warn "Admin set_article: Article not found for param: '#{params[:id]}'"
      redirect_to admin_articles_path, alert: '記事が見つかりません'
      return
    end
    
    Rails.logger.debug "Admin set_article: Found article ID: #{@article.id}, Slug: '#{@article.slug}'"
  end

  def article_params
    permitted = params.require(:article).permit(
      :title, :slug, :content_json, :status, :published_at, 
      :meta_description, :image_url, :featured_image, :show_table_of_contents, custom_fields: {}
    )
    
    # カスタムフィールドを個別に処理
    if params[:article][:custom_fields]
      permitted[:custom_fields] = {
        tags: params[:article][:custom_fields][:tags],
        category: params[:article][:custom_fields][:category]
      }
    end
    
    permitted
  end
  
  def load_taxonomy_data
    # カテゴリとタグのデータを既存記事のcustom_fieldsから取得
    articles_with_data = Article.where.not(custom_fields: nil)
    
    # カテゴリの一覧を取得（空の配列で初期化）
    @existing_categories = articles_with_data
                          .pluck(:custom_fields)
                          .map { |cf| cf&.dig('category') }
                          .compact
                          .uniq
                          .sort || []
    
    # タグの一覧を取得（文字列として保存されている場合の処理、空の配列で初期化）
    @existing_tags = articles_with_data
                    .pluck(:custom_fields)
                    .map { |cf| 
                      tags = cf&.dig('tags')
                      if tags.is_a?(String)
                        tags.split(',').map(&:strip)
                      else
                        tags
                      end
                    }
                    .compact
                    .flatten
                    .uniq
                    .sort || []
  rescue => e
    Rails.logger.error "Error loading taxonomy data: #{e.message}"
    @existing_categories = []
    @existing_tags = []
  end
  
  def extract_ogp_content(doc, property)
    # og:プロパティを探す
    meta = doc.css("meta[property='#{property}']").first
    return meta['content'] if meta
    
    # name属性も確認
    meta = doc.css("meta[name='#{property}']").first
    return meta['content'] if meta
    
    nil
  end
end