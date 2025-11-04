class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.string :job_type, null: false
      t.text :description
      t.string :capacity
      t.string :salary_range
      t.text :expectations
      t.text :senior_message
      t.boolean :published, default: false
      t.integer :display_order, default: 0

      t.timestamps
    end
    
    add_index :jobs, :published
    add_index :jobs, :display_order
    add_index :jobs, :job_type
  end
end
