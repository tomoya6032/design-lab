class Site::PortfoliosController < ApplicationController
  layout 'site'
  before_action :load_site_setting
  before_action :set_portfolio, only: [:show]
  
  def index
    add_breadcrumb('制作実績', site_portfolios_path)
    @portfolios = Portfolio.published.order(created_at: :desc)
    @portfolios = @portfolios.page(params[:page]).per(12)
  end
  
  def show
    add_breadcrumb('制作実績', site_portfolios_path)
    add_breadcrumb(@portfolio.title) if @portfolio
    redirect_to site_portfolios_path unless @portfolio
  end
  
  private
  
  def set_portfolio
    @portfolio = Portfolio.published.find_by(id: params[:id])
  end
  

end