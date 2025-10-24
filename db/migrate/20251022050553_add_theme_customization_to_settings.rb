class AddThemeCustomizationToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :primary_color, :string
    add_column :settings, :secondary_color, :string
    add_column :settings, :accent_color, :string
    add_column :settings, :font_family, :string
    add_column :settings, :header_font, :string
    add_column :settings, :header_height, :integer
    add_column :settings, :container_width, :integer
    add_column :settings, :sidebar_width, :integer
    add_column :settings, :border_radius, :integer
    add_column :settings, :box_shadow, :string
    add_column :settings, :animation_speed, :string
  end
end
