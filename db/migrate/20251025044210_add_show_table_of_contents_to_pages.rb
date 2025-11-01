class AddShowTableOfContentsToPages < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :show_table_of_contents, :boolean
  end
end
