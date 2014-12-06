class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.references :tenant
      t.references :calendar
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :repeat, :null => false, :default => false
      t.text :schedule
      t.string  :timezone
      t.references :contact
      t.references :phone_script
      t.boolean :via_xps, :null => false, :default => false
      t.references :user

      t.timestamps
    end
    add_index :appointments, :tenant_id
    add_index :appointments, :calendar_id
    add_index :appointments, :contact_id
    add_index :appointments, :user_id
    add_index :appointments, :phone_script_id
  end
end
