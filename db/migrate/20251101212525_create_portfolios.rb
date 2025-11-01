class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.string :title, null: false
      t.string :production_period
      t.text :description
      t.boolean :published, default: false
      t.integer :display_order, default: 0

      t.timestamps
    end
    
    add_index :portfolios, :published
    add_index :portfolios, :display_order
  end
end
