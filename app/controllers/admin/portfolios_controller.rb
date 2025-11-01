class Admin::PortfoliosController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_portfolio, only: [:show, :edit, :update, :destroy]
  
  def index
    @portfolios = Portfolio.ordered
  end
  
  def show
  end
  
  def new
    @portfolio = Portfolio.new
  end
  
  def create
    @portfolio = Portfolio.new(portfolio_params)
    
    if @portfolio.save
      redirect_to admin_portfolios_path, notice: '制作実績を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @portfolio.update(portfolio_params)
      redirect_to admin_portfolios_path, notice: '制作実績を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @portfolio.destroy
    redirect_to admin_portfolios_path, notice: '制作実績を削除しました。'
  end
  
  def destroy_image
    @portfolio = Portfolio.find(params[:portfolio_id])
    
    # Active Storage attachmentを直接IDで検索
    attachment = ActiveStorage::Attachment.find(params[:id])
    
    if attachment && attachment.record == @portfolio
      attachment.purge
      redirect_to edit_admin_portfolio_path(@portfolio), notice: '画像を削除しました。'
    else
      redirect_to edit_admin_portfolio_path(@portfolio), alert: '画像が見つかりませんでした。'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_admin_portfolio_path(@portfolio), alert: '画像が見つかりませんでした。'
  end
  
  private
  
  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end
  
  def portfolio_params
    params.require(:portfolio).permit(
      :title, :production_period, :description, :published, :display_order,
      pc_images: [], sp_images: []
    )
  end
end