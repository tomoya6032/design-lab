class AddShowTableOfContentsToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :show_table_of_contents, :boolean
  end
end
