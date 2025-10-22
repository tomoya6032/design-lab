class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.jsonb :content_json
      t.string :slug
      t.integer :status
      t.datetime :published_at
      t.string :meta_description
      t.jsonb :custom_fields
      t.string :image_url
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :articles, :slug, unique: true
  end
end
