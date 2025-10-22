class Api::V1::MediaController < Api::V1::BaseController
  before_action :set_medium, only: [:show, :update, :destroy]
  
  # GET /api/v1/media
  def index
    @media = current_user.media.recent
    
    render json: {
      media: @media.map { |medium| medium_json(medium) }
    }
  end
  
  # GET /api/v1/media/:id
  def show
    render json: { medium: medium_json(@medium) }
  end
  
  # POST /api/v1/media
  def create
    @medium = current_user.media.build(medium_params)
    
    if @medium.save
      render json: { medium: medium_json(@medium) }, status: :created
    else
      render json: { errors: @medium.errors }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /api/v1/media/:id
  def update
    if @medium.update(medium_params)
      render json: { medium: medium_json(@medium) }
    else
      render json: { errors: @medium.errors }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/media/:id
  def destroy
    @medium.destroy
    head :no_content
  end
  
  private
  
  def set_medium
    @medium = current_user.media.find(params[:id])
  end
  
  def medium_params
    params.require(:medium).permit(:filename, :url, :alt_text)
  end
  
  def medium_json(medium)
    {
      id: medium.id,
      filename: medium.filename,
      url: medium.url,
      alt_text: medium.alt_text,
      created_at: medium.created_at,
      updated_at: medium.updated_at,
      user: {
        id: medium.user.id,
        email: medium.user.email
      }
    }
  end
end
