class AddThemeToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :theme, :string, default: 'modern'
  end
end
