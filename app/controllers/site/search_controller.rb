class Site::SearchController < ApplicationController
  layout 'site'
  before_action :load_site_setting

  def index
    add_breadcrumb('サイト内検索')
    
    @query = params[:q]&.strip
    @results = {}
    @total_count = 0

    if @query.present?
      # 各モデルから検索
      @results[:articles] = Article.published.search_by_text(@query).with_associations.limit(10)
      @results[:pages] = Page.published.search_by_text(@query).with_featured_image.limit(10)
      @results[:jobs] = Job.published.search_by_text(@query).ordered.limit(10)
      @results[:portfolios] = Portfolio.published.search_by_text(@query).ordered.limit(10)

      # 総件数計算
      @total_count = @results.values.sum(&:count)
      
      # 各カテゴリの件数
      @counts = {
        articles: @results[:articles].count,
        pages: @results[:pages].count,
        jobs: @results[:jobs].count,
        portfolios: @results[:portfolios].count
      }
    else
      @results = { articles: [], pages: [], jobs: [], portfolios: [] }
      @counts = { articles: 0, pages: 0, jobs: 0, portfolios: 0 }
    end
  end

  private

  def load_site_setting
    @site_setting = Setting.first || Setting.new
  end
end