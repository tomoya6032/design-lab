class CreateMediaUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :media_usages do |t|
      t.references :medium, null: false, foreign_key: true
      t.references :mediable, polymorphic: true, null: false
      t.string :usage_type
      t.string :context

      t.timestamps
    end
  end
end
