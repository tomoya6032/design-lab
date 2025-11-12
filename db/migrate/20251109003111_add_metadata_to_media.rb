class AddMetadataToMedia < ActiveRecord::Migration[8.0]
  def change
    add_column :media, :title, :string
    add_column :media, :description, :text
    add_column :media, :file_type, :string
    add_column :media, :file_size, :integer
  end
end
