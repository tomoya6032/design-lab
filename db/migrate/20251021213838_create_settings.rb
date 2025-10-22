class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.string :site_name
      t.text :site_description
      t.string :logo_url
      t.string :favicon_url
      t.text :custom_css
      t.text :custom_js
      t.jsonb :social_links
      t.jsonb :seo_settings

      t.timestamps
    end
  end
end
