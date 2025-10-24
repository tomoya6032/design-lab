class Admin::PagesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = Page.order(created_at: :desc)
  end

  def show
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    
    if @page.save
      redirect_to admin_page_path(@page), notice: 'ページが作成されました。'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @page.update(page_params)
      redirect_to admin_page_path(@page), notice: 'ページが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_pages_path, notice: 'ページが削除されました。'
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :content, :excerpt, :slug, :template, :status, :meta_title, :meta_description)
  end
end