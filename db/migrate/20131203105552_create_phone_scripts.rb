class CreatePhoneScripts < ActiveRecord::Migration
  def change
    create_table :phone_scripts do |t|
      t.references :tenant
      t.references :business
      t.string :status
      t.string :name
      t.string :script_id # take_msg,book_appt,gather_info
      t.string :campaign_id   # from call center
      t.string :xps_phone   # from call center
      t.string :when_notify # call receive / agent action
      t.references :calendar
      t.boolean :record_call, :default => false, :null => false
      t.boolean :is_deleted, :default => false, :null => false
      t.boolean :has_audio, :default => false, :null => false   # own audio or default

      t.timestamps
    end
    add_index :phone_scripts, :tenant_id
    add_index :phone_scripts, :business_id
    add_index :phone_scripts, :calendar_id
  end
end
