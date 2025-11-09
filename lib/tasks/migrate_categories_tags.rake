namespace :articles do
  desc "Migrate categories and tags from custom_fields to proper models"
  task migrate_categories_tags: :environment do
    puts "既存記事からカテゴリとタグを移行中..."
    
    Article.all.each do |article|
      next unless article.custom_fields.is_a?(Hash)
      
      # カテゴリの移行
      if article.custom_fields['category'].present?
        category_name = article.custom_fields['category'].strip
        
        category = Category.find_by(name: category_name)
        unless category
          category = Category.new(
            name: category_name,
            description: "#{category_name}に関する記事"
          )
          
          # スラッグを手動で生成（日本語対応）
          base_slug = category_name.parameterize
          
          # 日本語などでparameterizeが空文字になった場合の対応
          if base_slug.blank?
            base_slug = category_name.gsub(/[^\w]/, '-').downcase
          end
          
          # それでも空の場合はIDベースのスラッグを生成
          if base_slug.blank?
            base_slug = "category-#{Time.current.to_i}-#{rand(1000)}"
          end
          
          slug = base_slug
          counter = 1
          
          while Category.exists?(slug: slug)
            slug = "#{base_slug}-#{counter}"
            counter += 1
          end
          
          category.slug = slug
          category.save!
        end
        
        puts "カテゴリ「#{category_name}」のID: #{category.id}"
        
        # 記事とカテゴリの関連付け
        unless article.article_categories.exists?(category: category)
          article.article_categories.create!(article_id: article.id, category_id: category.id)
          puts "記事「#{article.title}」にカテゴリ「#{category_name}」を関連付けました"
        end
      end
      
      # タグの移行
      if article.custom_fields['tags'].present?
        tag_names = article.custom_fields['tags'].split(',').map(&:strip)
        tag_names.each do |tag_name|
          next if tag_name.blank?
          
          tag = Tag.find_by(name: tag_name)
          unless tag
            tag = Tag.new(
              name: tag_name,
              description: "#{tag_name}に関する記事"
            )
            
            # スラッグを手動で生成（日本語対応）
            base_slug = tag_name.parameterize
            
            # 日本語などでparameterizeが空文字になった場合の対応
            if base_slug.blank?
              base_slug = tag_name.gsub(/[^\w]/, '-').downcase
            end
            
            # それでも空の場合はIDベースのスラッグを生成
            if base_slug.blank?
              base_slug = "tag-#{Time.current.to_i}-#{rand(1000)}"
            end
            
            slug = base_slug
            counter = 1
            
            while Tag.exists?(slug: slug)
              slug = "#{base_slug}-#{counter}"
              counter += 1
            end
            
            tag.slug = slug
            tag.save!
          end
          
          # 記事とタグの関連付け
          unless article.article_tags.exists?(tag: tag)
            article.article_tags.create!(article_id: article.id, tag_id: tag.id)
            puts "記事「#{article.title}」にタグ「#{tag_name}」を関連付けました"
          end
        end
      end
    end
    
    puts "移行が完了しました！"
    puts "カテゴリ数: #{Category.count}"
    puts "タグ数: #{Tag.count}"
  end
end