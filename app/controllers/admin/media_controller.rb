class Admin::MediaController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_medium, only: [:show, :edit, :update, :destroy]

  def index
    @media = Medium.includes(:media_usages).order(created_at: :desc)
    @total_media = @media.count
    @recent_media = @media.where('created_at > ?', 1.week.ago).count
    @used_media = @media.joins(:media_usages).distinct.count
    @unused_media = @total_media - @used_media
    
    # 使用状況の詳細統計
    @usage_stats = MediaUsage.group(:usage_type).count
    @model_usage_stats = MediaUsage.group(:mediable_type).count
  end
  
  # メディア選択用のモーダル表示
  def select
    @media = Medium.order(created_at: :desc)
    @media = @media.images if params[:type] == 'image'
    @media = @media.videos if params[:type] == 'video'
    @media = @media.documents if params[:type] == 'document'
    
    render layout: false if request.xhr?
  end

  def show
  end

  def new
    @medium = Medium.new
  end

  def create
  def create
    @medium = Medium.new(medium_params)
    @medium.user = current_user

    if @medium.save
      redirect_to admin_media_path, notice: 'メディアが正常にアップロードされました。'
    else
      render :new
    end
  end
  end

  def edit
  end

  def update
    begin
      if @medium.update(medium_params)
        # JSONリクエストの場合はJSONレスポンスを返す
        if request.format.json?
          render json: { status: 'success', message: 'メディアが更新されました。' }
        else
          redirect_to admin_medium_path(@medium), notice: 'メディア情報が更新されました。'
        end
      else
        Rails.logger.error "Medium update failed: #{@medium.errors.full_messages}"
        if request.format.json?
          render json: { status: 'error', errors: @medium.errors.full_messages, message: 'バリデーションエラーが発生しました。' }
        else
          render :edit
        end
      end
    rescue => e
      Rails.logger.error "Medium update exception: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      if request.format.json?
        render json: { status: 'error', message: "更新中にエラーが発生しました: #{e.message}" }
      else
        redirect_to edit_admin_medium_path(@medium), alert: "更新中にエラーが発生しました: #{e.message}"
      end
    end
  end

  def destroy
    @medium.destroy
    redirect_to admin_media_path, notice: 'メディアが削除されました。'
  end

  private

  def set_medium
    @medium = Medium.find(params[:id])
  end

  def medium_params
    params.require(:medium).permit(:title, :description, :alt_text, :file)
  end
end