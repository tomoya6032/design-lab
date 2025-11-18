class AddHeroTextToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :hero_title, :string
    add_column :settings, :hero_description, :text
  end
end
