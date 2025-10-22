class CreateMedia < ActiveRecord::Migration[8.0]
  def change
    create_table :media do |t|
      t.string :filename
      t.string :url
      t.string :alt_text
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
