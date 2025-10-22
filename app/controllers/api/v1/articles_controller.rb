class Api::V1::ArticlesController < Api::V1::BaseController
  before_action :set_article, only: [:show, :update, :destroy]
  
  # GET /api/v1/articles
  def index
    @articles = Article.includes(:user)
    @articles = @articles.published if params[:published] == 'true'
    @articles = @articles.recent.page(params[:page])
    
    render json: {
      articles: @articles.map { |article| article_json(article) },
      meta: pagination_meta(@articles)
    }
  end
  
  # GET /api/v1/articles/:id
  def show
    render json: { article: article_json(@article) }
  end
  
  # POST /api/v1/articles
  def create
    @article = current_user.articles.build(article_params)
    
    if @article.save
      render json: { article: article_json(@article) }, status: :created
    else
      render json: { errors: @article.errors }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /api/v1/articles/:id
  def update
    if @article.update(article_params)
      render json: { article: article_json(@article) }
    else
      render json: { errors: @article.errors }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/articles/:id
  def destroy
    @article.destroy
    head :no_content
  end
  
  private
  
  def set_article
    @article = Article.find(params[:id])
  end
  
  def article_params
    params.require(:article).permit(
      :title, :slug, :status, :published_at, :meta_description, 
      :image_url, content_json: {}, custom_fields: {}
    )
  end
  
  def article_json(article)
    {
      id: article.id,
      title: article.title,
      slug: article.slug,
      content_json: article.content_json,
      status: article.status,
      published_at: article.published_at,
      meta_description: article.meta_description,
      custom_fields: article.custom_fields,
      image_url: article.image_url,
      created_at: article.created_at,
      updated_at: article.updated_at,
      user: {
        id: article.user.id,
        email: article.user.email
      }
    }
  end
  
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end
