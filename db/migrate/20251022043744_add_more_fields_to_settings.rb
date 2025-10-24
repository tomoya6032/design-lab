class AddMoreFieldsToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :contact_email, :string
    add_column :settings, :maintenance_mode, :boolean, default: false
    add_column :settings, :meta_title, :string
    add_column :settings, :meta_description, :text
    add_column :settings, :meta_keywords, :string
    add_column :settings, :google_analytics_id, :string
    add_column :settings, :twitter_url, :string
    add_column :settings, :facebook_url, :string
    add_column :settings, :instagram_url, :string
    add_column :settings, :youtube_url, :string
  end
end
