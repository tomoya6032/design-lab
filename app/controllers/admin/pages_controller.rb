require 'open-uri'

class Admin::PagesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = Page.order(created_at: :desc)
    @navigation_pages = Page.where(show_in_navigation: true, status: :published).order(:title).limit(3)
    @available_pages = Page.where(status: :published).order(:title)
  end

  def show
  end

  def new
    @page = Page.new
  end

  def create
    Rails.logger.debug "Page params: #{page_params.inspect}"
    @page = Page.new(page_params)
    @page.user = current_user
    
    if @page.save
      redirect_to admin_page_path(@page.id), notice: 'ページが作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @page.update(page_params)
      redirect_to admin_page_path(@page.id), notice: 'ページが更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_pages_path, notice: 'ページが削除されました。'
  end
  
  def bulk_action
    page_ids = params[:page_ids]
    bulk_action = params[:bulk_action]
    
    if page_ids.blank?
      redirect_to admin_pages_path, alert: '操作するページが選択されていません。'
      return
    end
    
    if bulk_action.blank?
      redirect_to admin_pages_path, alert: '一括操作を選択してください。'
      return
    end
    
    success_count = 0
    error_count = 0
    
    page_ids.each do |id|
      page = Page.find_by(id: id)
      next unless page
      
      case bulk_action
      when 'published'
        if page.update(status: 'published')
          success_count += 1
        else
          error_count += 1
        end
      when 'draft'
        if page.update(status: 'draft')
          success_count += 1
        else
          error_count += 1
        end
      when 'limited'
        if page.update(status: 'limited')
          success_count += 1
        else
          error_count += 1
        end
      when 'delete'
        if page.destroy
          success_count += 1
        else
          error_count += 1
        end
      end
    end
    
    action_names = {
      'published' => '公開',
      'draft' => '下書きに変更',
      'limited' => '限定公開',
      'delete' => '削除'
    }
    
    action_name = action_names[bulk_action]
    
    if success_count > 0 && error_count == 0
      redirect_to admin_pages_path, notice: "#{success_count}件のページを#{action_name}しました。"
    elsif success_count > 0 && error_count > 0
      redirect_to admin_pages_path, notice: "#{success_count}件のページを#{action_name}しました。#{error_count}件でエラーが発生しました。"
    else
      redirect_to admin_pages_path, alert: "ページの#{action_name}に失敗しました。"
    end
  end

  def update_navigation
    # 全ページのshow_in_navigationをfalseに設定
    Page.update_all(show_in_navigation: false)
    
    # 選択されたページのshow_in_navigationをtrueに設定
    selected_page_ids = []
    (1..3).each do |position|
      page_id = params["navigation_page_#{position}"]
      if page_id.present? && page_id != ""
        selected_page_ids << page_id.to_i
      end
    end
    
    if selected_page_ids.any?
      Page.where(id: selected_page_ids).update_all(show_in_navigation: true)
    end
    
    redirect_to admin_pages_path, notice: 'ナビゲーション設定が更新されました。'
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

  def set_page
    if params[:id].match?(/\A\d+\z/)
      # 数値の場合はIDで検索
      @page = Page.find(params[:id])
    else
      # 文字列の場合はスラッグで検索
      @page = Page.find_by!(slug: params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_pages_path, alert: 'ページが見つかりません'
  end

  def page_params
    params.require(:page).permit(:title, :content_json, :slug, :status, :meta_description, :show_table_of_contents, :show_in_navigation, custom_fields: {})
  end
  
  def extract_ogp_content(doc, property)
    doc.css("meta[property='#{property}']").first&.[]('content') ||
    doc.css("meta[name='#{property}']").first&.[]('content')
  end
end