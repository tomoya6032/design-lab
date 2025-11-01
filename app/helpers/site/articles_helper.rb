module Site::ArticlesHelper
  def safe_article_path(article)
    site_article_path(article.to_param)
  rescue => e
    Rails.logger.error "Article path generation error: #{e.message} for article #{article.id}"
    site_articles_path # 記事一覧にフォールバック
  end
end