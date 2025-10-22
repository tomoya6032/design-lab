class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  respond_to :json
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  
  private
  
  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
  
  def unprocessable_entity(exception)
    render json: { error: exception.record.errors }, status: :unprocessable_entity
  end
end