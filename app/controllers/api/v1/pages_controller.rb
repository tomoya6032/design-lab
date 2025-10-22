class Api::V1::PagesController < Api::V1::BaseController
  before_action :set_page, only: [:show, :update, :destroy]
  
  # GET /api/v1/pages
  def index
    @pages = Page.includes(:user)
    @pages = @pages.published if params[:published] == 'true'
    @pages = @pages.order(:created_at)
    
    render json: {
      pages: @pages.map { |page| page_json(page) }
    }
  end
  
  # GET /api/v1/pages/:id
  def show
    render json: { page: page_json(@page) }
  end
  
  # POST /api/v1/pages
  def create
    @page = current_user.pages.build(page_params)
    
    if @page.save
      render json: { page: page_json(@page) }, status: :created
    else
      render json: { errors: @page.errors }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /api/v1/pages/:id
  def update
    if @page.update(page_params)
      render json: { page: page_json(@page) }
    else
      render json: { errors: @page.errors }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/pages/:id
  def destroy
    @page.destroy
    head :no_content
  end
  
  private
  
  def set_page
    @page = Page.find(params[:id])
  end
  
  def page_params
    params.require(:page).permit(
      :title, :slug, :status, :published_at, :meta_description, 
      :image_url, content_json: {}, custom_fields: {}
    )
  end
  
  def page_json(page)
    {
      id: page.id,
      title: page.title,
      slug: page.slug,
      content_json: page.content_json,
      status: page.status,
      published_at: page.published_at,
      meta_description: page.meta_description,
      custom_fields: page.custom_fields,
      image_url: page.image_url,
      created_at: page.created_at,
      updated_at: page.updated_at,
      user: {
        id: page.user.id,
        email: page.user.email
      }
    }
  end
end
