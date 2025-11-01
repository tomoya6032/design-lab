module Admin::ArticlesHelper
  def safe_admin_article_path(article, action = :show)
    case action
    when :show
      admin_article_path(article)
    when :edit
      edit_admin_article_path(article)
    else
      admin_article_path(article)
    end
  rescue => e
    Rails.logger.error "Admin article path generation error: #{e.message} for article #{article&.id}"
    admin_articles_path
  end
end