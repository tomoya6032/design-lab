class Admin::MediaController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_medium, only: [:show, :edit, :update, :destroy]

  def index
    @media = Medium.order(created_at: :desc)
    @total_media = @media.count
    @recent_media = @media.where('created_at > ?', 1.week.ago).count
  end

  def show
  end

  def new
    @medium = Medium.new
  end

  def create
    @medium = Medium.new(medium_params)
    
    if @medium.save
      redirect_to admin_medium_path(@medium), notice: 'メディアがアップロードされました。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @medium.update(medium_params)
      redirect_to admin_medium_path(@medium), notice: 'メディア情報が更新されました。'
    else
      render :edit
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
    params.require(:medium).permit(:title, :description, :file_url, :file_type, :file_size, :alt_text)
  end
end