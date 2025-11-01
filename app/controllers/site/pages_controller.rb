class Site::PagesController < ApplicationController
  layout 'site'
  before_action :load_site_setting
  before_action :set_page, only: [:show]
  
  def index
    @pages = Page.published.order(:title)
  end
  
  def show
    unless @page.published?
      redirect_to root_path, alert: 'ページが見つかりません'
      return
    end
  end
  
  private
  
  def set_page
    return redirect_to root_path, alert: 'ページが見つかりません' if params[:id].blank?
    
    # まずslugで検索
    @page = Page.find_by(slug: params[:id])
    
    # slugで見つからなかった場合、IDで検索（数値の場合のみ）
    if @page.nil? && params[:id].match?(/\A\d+\z/)
      @page = Page.find_by(id: params[:id])
    end
    
    # ページが見つからない場合
    unless @page
      redirect_to root_path, alert: 'ページが見つかりません'
      return
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'ページが見つかりません'
  end
  
  def load_site_setting
    @site_setting = Setting.current
  end
end