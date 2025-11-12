class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.text :message, null: false
      t.string :ip_address
      t.text :user_agent
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    
    add_index :contacts, :status
    add_index :contacts, :created_at
    add_index :contacts, :email
  end
end
