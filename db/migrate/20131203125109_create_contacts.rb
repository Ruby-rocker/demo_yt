class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :tenant
      t.string :first_name
      t.string :last_name
      t.references :status_label
      t.references :user
      t.boolean :via_xps, :default => false, :null => false

      t.timestamps
    end
    add_index :contacts, :tenant_id
    add_index :contacts, :status_label_id
    add_index :contacts, :user_id
  end
end
