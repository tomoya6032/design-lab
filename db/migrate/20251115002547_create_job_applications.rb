class CreateJobApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :job_applications do |t|
      t.references :job, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.text :resume
      t.text :cover_letter
      t.string :portfolio_url
      t.integer :experience_years
      t.text :motivation

      t.timestamps
    end
  end
end
