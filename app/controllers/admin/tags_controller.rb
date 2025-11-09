class Admin::TagsController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_tag, only: [:show, :edit, :update, :destroy]
  
  def index
    @tags = Tag.includes(:articles).ordered
    @popular_tags = Tag.popular.limit(10)
  end

  def show
    @articles = @tag.articles.published.recent.limit(10)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    
    if @tag.save
      redirect_to admin_tags_path, notice: 'タグが作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_path, notice: 'タグが更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @tag.articles.exists?
      redirect_to admin_tags_path, alert: 'このタグには記事が紐づいているため削除できません。'
    else
      @tag.destroy
      redirect_to admin_tags_path, notice: 'タグが削除されました。'
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :slug, :description)
  end
end
