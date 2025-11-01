module ApplicationHelper
  def safe_article_path(article)
    return site_articles_path unless article && article.respond_to?(:to_param)
    
    param = article.to_param
    return site_articles_path if param.blank?
    
    site_article_path(param)
  rescue => e
    Rails.logger.error "Article path generation error: #{e.message} for article #{article&.id}"
    site_articles_path # 記事一覧にフォールバック
  end
  
  def article_featured_image_url(article)
    # eager loadingされていることを前提として最適化
    if article.featured_image.attached?
      url_for(article.featured_image)
    elsif article.image_url.present?
      article.image_url
    else
      nil
    end
  end
  
  def article_featured_image_tag(article, options = {})
    image_url = article_featured_image_url(article)
    return nil unless image_url
    
    default_options = {
      class: 'featured-image',
      alt: article.title,
      loading: 'lazy'
    }
    
    image_tag(image_url, default_options.merge(options))
  end
  
  def generate_table_of_contents(content)
    return nil if content.blank?
    
    # HTMLを解析してh2, h3, h4タグを抽出
    doc = Nokogiri::HTML::DocumentFragment.parse(content)
    headings = doc.css('h2, h3, h4')
    
    return nil if headings.empty?
    
    toc_items = []
    headings.each_with_index do |heading, index|
      # 見出しにIDを追加（既にない場合）
      heading_id = heading['id'] || "heading-#{index + 1}"
      heading['id'] = heading_id
      
      toc_items << {
        id: heading_id,
        text: heading.text.strip,
        level: heading.name.gsub('h', '').to_i
      }
    end
    
    # 目次のHTMLを生成
    toc_html = content_tag(:div, class: 'table-of-contents') do
      content_tag(:h3, '目次', class: 'toc-title') +
      content_tag(:ol, class: 'toc-list') do
        toc_items.map do |item|
          indent_class = case item[:level]
                        when 2 then 'toc-h2'
                        when 3 then 'toc-h3'
                        when 4 then 'toc-h4'
                        end
          
          content_tag(:li, class: "toc-item #{indent_class}") do
            link_to(item[:text], "##{item[:id]}", class: 'toc-link')
          end
        end.join.html_safe
      end
    end
    
    # 元のコンテンツも更新（見出しにIDが追加された状態）
    { toc: toc_html, content: doc.to_html.html_safe }
  end
end