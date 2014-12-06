class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :tenant
      t.references :appointment
      t.references :contact
      t.references :user
      t.boolean :via_xps, :null => false, :default => false
      t.text :content

      t.timestamps
    end
    add_index :notes, :tenant_id
    add_index :notes, :appointment_id
    add_index :notes, :contact_id
    add_index :notes, :user_id
  end
end
