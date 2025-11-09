class Admin::CategoriesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  
  def index
    @categories = Category.includes(:parent, :children).root_categories.ordered
    @all_categories = Category.ordered
  end

  def show
    @articles = @category.articles.published.recent.limit(10)
  end

  def new
    @category = Category.new
    @parent_categories = Category.root_categories.ordered
  end

  def create
    @category = Category.new(category_params)
    
    if @category.save
      redirect_to admin_categories_path, notice: 'カテゴリが作成されました。'
    else
      @parent_categories = Category.root_categories.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @parent_categories = Category.where.not(id: [@category.id] + @category.descendants.pluck(:id)).root_categories.ordered
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: 'カテゴリが更新されました。'
    else
      @parent_categories = Category.where.not(id: [@category.id] + @category.descendants.pluck(:id)).root_categories.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.articles.exists?
      redirect_to admin_categories_path, alert: 'このカテゴリには記事が紐づいているため削除できません。'
    else
      @category.destroy
      redirect_to admin_categories_path, notice: 'カテゴリが削除されました。'
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :slug, :description, :parent_id, :position)
  end
end
