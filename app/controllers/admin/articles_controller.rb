class Admin::ArticlesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    @articles = Article.order(created_at: :desc)
  end

  def show
  end

  def new
    @article = Article.new
  end

  def create
    Rails.logger.debug "Article params: #{article_params.inspect}"
    @article = Article.new(article_params)
    @article.user = current_user  # 現在のユーザーを自動設定
    
    Rails.logger.debug "Article before save: title=#{@article.title}, slug=#{@article.slug}"
    
    if @article.save
      redirect_to admin_article_path(@article), notice: '記事が作成されました。'
    else
      Rails.logger.debug "Article errors: #{@article.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to admin_article_path(@article), notice: '記事が更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to admin_articles_path, notice: '記事が削除されました。'
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    permitted = params.require(:article).permit(
      :title, :slug, :content_json, :status, :published_at, 
      :meta_description, :image_url, custom_fields: {}
    )
    
    # カスタムフィールドを個別に処理
    if params[:article][:custom_fields]
      permitted[:custom_fields] = {
        tags: params[:article][:custom_fields][:tags],
        category: params[:article][:custom_fields][:category]
      }
    end
    
    permitted
  end
end