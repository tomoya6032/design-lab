class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
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
    add_index :pages, :slug, unique: true
  end
end
